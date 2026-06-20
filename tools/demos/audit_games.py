#!/usr/bin/env python3
"""Audit content/games readiness for the public demo catalog.

The audit is intentionally non-destructive. It scans each
content/games/<category>/<name> folder, applies the product decision map from
issue #30, checks catalog assets, detects lurek.* modules, and can run the
static validate_game.py checks in-process.

Examples:
    python tools/demos/audit_games.py
    python tools/demos/audit_games.py --no-validate
    python tools/demos/audit_games.py --only arcade/tetris --json-only
    python tools/demos/audit_games.py --smoke-report work/smoke-sweep/reports/smoke_results.json
    python tools/demos/audit_games.py --run-smoke --smoke-scope public --smoke-frames 300
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

import game_catalog

REPO_ROOT = game_catalog.REPO_ROOT
DEFAULT_MD = REPO_ROOT / "work" / "games-audit.md"
DEFAULT_JSON = REPO_ROOT / "work" / "games-audit.json"
DEFAULT_SMOKE_JSON = REPO_ROOT / "work" / "games-audit" / "smoke_results.json"


@dataclass
class GameAudit:
    id: str
    category: str
    name: str
    path: str
    title: str
    description: str
    decision: str
    decision_note: str
    public_candidate: bool
    readme_status: str
    has_main_lua: bool
    has_readme: bool
    has_screen_png: bool
    has_preview_gif: bool
    apis: list[str]
    validate_status: str
    validate_issues: int
    validate_summary: list[str]
    smoke_status: str
    smoke_error: str
    known_failing: bool
    known_failing_owner: str
    known_failing_reason: str


def _load_validate_manifest() -> dict[str, set[str]]:
    sys.path.insert(0, str(REPO_ROOT / "tools" / "validate"))
    import validate_game  # type: ignore[import-not-found]

    return validate_game._build_api_manifest()


def _validate_one(game_dir: Path, manifest: dict[str, set[str]]) -> tuple[str, int, list[str]]:
    sys.path.insert(0, str(REPO_ROOT / "tools" / "validate"))
    import validate_game  # type: ignore[import-not-found]

    results = validate_game.validate_game_folder(game_dir, manifest)
    issues: list[str] = []
    for rel_file, file_issues in sorted(results.items()):
        for issue in file_issues:
            issues.append(
                "{file}:{line} {kind} {call}".format(
                    file=rel_file,
                    line=issue.get("line", 0),
                    kind=issue.get("type", "issue"),
                    call=issue.get("call", ""),
                )
            )
    return ("PASS" if not issues else "FAIL", len(issues), issues[:5])


def _index_smoke_rows(data: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    out: dict[str, dict[str, Any]] = {}
    for row in data:
        label = str(row.get("label", ""))
        if label:
            out[label] = row
    return out


def _load_smoke_reports(paths: list[Path] | None) -> dict[str, dict[str, Any]]:
    if not paths:
        return {}
    out: dict[str, dict[str, Any]] = {}
    for path in paths:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except OSError as exc:
            raise SystemExit(f"ERROR: could not read smoke report {path}: {exc}") from exc
        except json.JSONDecodeError as exc:
            raise SystemExit(f"ERROR: invalid smoke report JSON {path}: {exc}") from exc
        out.update(_index_smoke_rows(data))
    return out


def _run_smoke_sweep(
    *,
    identifiers: list[str],
    frames: int,
    timeout: float,
    output: Path,
) -> dict[str, dict[str, Any]]:
    output.parent.mkdir(parents=True, exist_ok=True)
    partial_dir = output.parent / "partials"
    partial_dir.mkdir(parents=True, exist_ok=True)
    combined: list[dict[str, Any]] = []
    smoke_script = REPO_ROOT / "tools" / "demos" / "smoke_sweep.py"

    for index, identifier in enumerate(identifiers, 1):
        safe_name = identifier.replace("/", "__").replace("\\", "__")
        partial = partial_dir / f"{safe_name}.json"
        screen_path = REPO_ROOT / "content" / "games" / identifier / "screen.png"
        screen_backup = screen_path.read_bytes() if screen_path.exists() else None
        cmd = [
            sys.executable,
            str(smoke_script),
            "--kind",
            "game",
            "--only",
            identifier,
            "--frames",
            str(frames),
            "--timeout",
            str(timeout),
            "--report",
            str(partial),
        ]
        proc = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            errors="replace",
        )
        status = "ERROR"
        expected_label = f"content/games/{identifier}"
        if partial.exists():
            try:
                rows = [
                    row for row in json.loads(partial.read_text(encoding="utf-8"))
                    if row.get("label") == expected_label
                ]
                combined.extend(rows)
                if rows:
                    status = str(rows[0].get("bucket", status))
                    if status != "PASS" and screen_backup is not None and not screen_path.exists():
                        screen_path.write_bytes(screen_backup)
            except json.JSONDecodeError:
                status = "BAD_REPORT"
        elif proc.returncode == 0:
            status = "NO_REPORT"
            if screen_backup is not None and not screen_path.exists():
                screen_path.write_bytes(screen_backup)
        print(f"[{index:3d}/{len(identifiers)}] SMOKE {status:<10} {identifier}", flush=True)
        if proc.returncode != 0 and not partial.exists():
            tail = (proc.stderr or proc.stdout or "").splitlines()[-3:]
            for line in tail:
                print(f"           {line}", flush=True)

    output.write_text(json.dumps(combined, indent=2), encoding="utf-8")
    return _index_smoke_rows(combined)


def collect_audit(
    *,
    games_root: Path,
    only: str | None,
    validate: bool,
    smoke_report: list[Path] | None,
    run_smoke: bool = False,
    smoke_scope: str = "public",
    smoke_frames: int = 300,
    smoke_timeout: float = 30.0,
    smoke_output: Path = DEFAULT_SMOKE_JSON,
) -> list[GameAudit]:
    game_dirs = game_catalog.discover_game_dirs(games_root)
    if only:
        game_dirs = [
            path for path in game_dirs
            if only in game_catalog.game_id(path, games_root) or only == path.name
        ]
    smoke = _load_smoke_reports(smoke_report)
    if run_smoke:
        smoke_ids = []
        for path in game_dirs:
            identifier = game_catalog.game_id(path, games_root)
            decision = game_catalog.decision_for(identifier)[0]
            if smoke_scope == "all" or game_catalog.is_public_decision(decision):
                smoke_ids.append(identifier)
        smoke.update(
            _run_smoke_sweep(
                identifiers=smoke_ids,
                frames=smoke_frames,
                timeout=smoke_timeout,
                output=smoke_output,
            )
        )
    manifest = _load_validate_manifest() if validate else None

    rows: list[GameAudit] = []
    for game_dir in game_dirs:
        identifier = game_catalog.game_id(game_dir, games_root)
        category, name = identifier.split("/", 1)
        decision, decision_note = game_catalog.decision_for(identifier)
        readme_text = game_catalog.read_text(game_dir / "README.md")
        validate_status = "NOT_RUN"
        validate_issues = 0
        validate_summary: list[str] = []
        if manifest is not None:
            validate_status, validate_issues, validate_summary = _validate_one(game_dir, manifest)

        smoke_label = f"content/games/{identifier}"
        smoke_row = smoke.get(smoke_label)
        smoke_status = str(smoke_row.get("bucket", "NOT_RUN")) if smoke_row else "NOT_RUN"
        smoke_error = str(smoke_row.get("error_head", "")) if smoke_row else ""
        known_failing = smoke_status not in {"PASS", "NOT_RUN"}
        known_reason = smoke_error or f"smoke_sweep.py reported {smoke_status}"

        rows.append(
            GameAudit(
                id=identifier,
                category=category,
                name=name,
                path=game_catalog.rel_to_repo(game_dir),
                title=game_catalog.title_from_id(identifier),
                description=game_catalog.extract_description(game_dir),
                decision=decision,
                decision_note=decision_note,
                public_candidate=game_catalog.is_public_decision(decision),
                readme_status=game_catalog.extract_status(readme_text),
                has_main_lua=(game_dir / "main.lua").exists(),
                has_readme=(game_dir / "README.md").exists(),
                has_screen_png=(game_dir / "screen.png").exists(),
                has_preview_gif=(game_dir / "preview.gif").exists(),
                apis=game_catalog.find_lurek_modules(game_dir),
                validate_status=validate_status,
                validate_issues=validate_issues,
                validate_summary=validate_summary,
                smoke_status=smoke_status,
                smoke_error=smoke_error,
                known_failing=known_failing,
                known_failing_owner="content-demo-maintainers" if known_failing else "",
                known_failing_reason=known_reason if known_failing else "",
            )
        )
    return sorted(rows, key=lambda r: (game_catalog.category_sort_key(r.category), r.name))


def _status_cell(row: GameAudit) -> str:
    missing: list[str] = []
    if not row.has_readme:
        missing.append("README")
    if not row.has_screen_png:
        missing.append("screen")
    if not row.has_preview_gif:
        missing.append("gif")
    if row.validate_status == "FAIL":
        missing.append(f"validate:{row.validate_issues}")
    if row.smoke_status not in {"PASS", "NOT_RUN"}:
        missing.append(f"smoke:{row.smoke_status}")
    return "ok" if not missing else ", ".join(missing)


def write_markdown(rows: list[GameAudit], output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    decision_counts = Counter(row.decision for row in rows)
    category_counts = Counter(row.category for row in rows)
    public_rows = [row for row in rows if row.public_candidate]
    missing_preview = [row for row in public_rows if not row.has_preview_gif]
    missing_screen = [row for row in public_rows if not row.has_screen_png]
    validation_failures = [row for row in public_rows if row.validate_status == "FAIL"]
    smoke_failures = [row for row in public_rows if row.smoke_status not in {"PASS", "NOT_RUN"}]

    lines: list[str] = [
        "# Games Audit",
        "",
        "Generated by `python tools/demos/audit_games.py`.",
        "",
        "## Summary",
        "",
        f"- Total runnable folders: {len(rows)}",
        f"- Public candidates (KEEP/REWRITE_API/TRIM): {len(public_rows)}",
        f"- Public candidates missing `screen.png`: {len(missing_screen)}",
        f"- Public candidates missing `preview.gif`: {len(missing_preview)}",
        f"- Public candidates with validate failures: {len(validation_failures)}",
        f"- Public candidates with smoke failures in supplied report: {len(smoke_failures)}",
        f"- Public candidates with known failing smoke entries: {len([row for row in public_rows if row.known_failing])}",
        "",
        "## Decisions",
        "",
    ]
    for decision, count in sorted(decision_counts.items()):
        lines.append(f"- {decision}: {count}")

    lines += ["", "## Categories", ""]
    for category, count in sorted(category_counts.items(), key=lambda kv: game_catalog.category_sort_key(kv[0])):
        lines.append(f"- {category}: {count}")

    grouped: dict[str, list[GameAudit]] = defaultdict(list)
    for row in rows:
        grouped[row.category].append(row)

    lines += [
        "",
        "## Detail",
        "",
        "| Demo | Decision | Status | APIs | Validation | Smoke | Known failing | Gaps |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for category in sorted(grouped, key=game_catalog.category_sort_key):
        for row in sorted(grouped[category], key=lambda r: r.name):
            api_text = ", ".join(row.apis[:8])
            if len(row.apis) > 8:
                api_text += f", +{len(row.apis) - 8}"
            api_text = api_text or "-"
            lines.append(
                "| [{id}](../{path}) | {decision} | {status} | {apis} | {validate} | {smoke} | {known} | {gaps} |".format(
                    id=row.id,
                    path=row.path,
                    decision=row.decision,
                    status=row.readme_status,
                    apis=api_text,
                    validate=(
                        row.validate_status if row.validate_status != "FAIL"
                        else f"FAIL ({row.validate_issues})"
                    ),
                    smoke=row.smoke_status,
                    known=(
                        f"{row.known_failing_owner}: {row.known_failing_reason}"
                        if row.known_failing else "-"
                    ),
                    gaps=_status_cell(row),
                )
            )

    if validation_failures:
        lines += ["", "## Validation Failures", ""]
        for row in validation_failures[:30]:
            lines.append(f"### {row.id}")
            for item in row.validate_summary:
                lines.append(f"- {item}")
            if row.validate_issues > len(row.validate_summary):
                lines.append(f"- ... {row.validate_issues - len(row.validate_summary)} more")
            lines.append("")

    if smoke_failures:
        lines += ["", "## Known Smoke Failures", ""]
        for row in sorted(smoke_failures, key=lambda r: r.id):
            lines.append(
                f"- `{row.id}` - owner `{row.known_failing_owner}` - "
                f"{row.known_failing_reason}"
            )

    output.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit content/games readiness for the public demo catalog.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--games-root", type=Path, default=game_catalog.DEFAULT_GAMES_ROOT)
    parser.add_argument("--output-md", type=Path, default=DEFAULT_MD)
    parser.add_argument("--output-json", type=Path, default=DEFAULT_JSON)
    parser.add_argument("--only", help="Substring or demo name to audit.")
    parser.add_argument("--no-validate", action="store_true", help="Skip static validate_game.py checks.")
    parser.add_argument(
        "--smoke-report",
        type=Path,
        action="append",
        help="Existing smoke_sweep JSON report to merge. Repeatable.",
    )
    parser.add_argument(
        "--run-smoke",
        action="store_true",
        help="Run smoke_sweep.py for matching demos and merge the results.",
    )
    parser.add_argument(
        "--smoke-scope",
        choices=("public", "all"),
        default="public",
        help="When --run-smoke is set, run public candidates only or every matching demo.",
    )
    parser.add_argument("--smoke-frames", type=int, default=300)
    parser.add_argument("--smoke-timeout", type=float, default=30.0)
    parser.add_argument("--smoke-output", type=Path, default=DEFAULT_SMOKE_JSON)
    parser.add_argument("--json-only", action="store_true", help="Write JSON but skip Markdown output.")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    rows = collect_audit(
        games_root=args.games_root,
        only=args.only,
        validate=not args.no_validate,
        smoke_report=args.smoke_report,
        run_smoke=args.run_smoke,
        smoke_scope=args.smoke_scope,
        smoke_frames=args.smoke_frames,
        smoke_timeout=args.smoke_timeout,
        smoke_output=args.smoke_output,
    )
    if not rows:
        print("ERROR: no game folders found", file=sys.stderr)
        return 1

    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(
        json.dumps([asdict(row) for row in rows], indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    if not args.json_only:
        write_markdown(rows, args.output_md)
        print(f"WROTE {game_catalog.rel_to_repo(args.output_md)}")
    print(f"WROTE {game_catalog.rel_to_repo(args.output_json)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
