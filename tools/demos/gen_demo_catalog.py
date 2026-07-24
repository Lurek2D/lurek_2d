#!/usr/bin/env python3
"""Generate lurek_2d_content/games/README.md and catalog.json from audited metadata.

The generated README is a public-facing catalog. It lists only finished catalog
candidates. Backlog and migration work stays in work/games-audit.* outputs.

Examples:
    python tools/demos/gen_demo_catalog.py
    python tools/demos/gen_demo_catalog.py --audit-json work/games-audit.json
    python tools/demos/gen_demo_catalog.py --dry-run
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from pathlib import Path
from typing import Any

import audit_games
import game_catalog

REPO_ROOT = game_catalog.REPO_ROOT
DEFAULT_README = game_catalog.DEFAULT_GAMES_ROOT / "README.md"
DEFAULT_CATALOG = game_catalog.DEFAULT_GAMES_ROOT / "catalog.json"


def _load_rows_from_json(path: Path) -> list[audit_games.GameAudit]:
    data = json.loads(path.read_text(encoding="utf-8"))
    for row in data:
        row.setdefault("known_failing", False)
        row.setdefault("known_failing_owner", "")
        row.setdefault("known_failing_reason", "")
    return [audit_games.GameAudit(**row) for row in data]


def _preview_cell(row: audit_games.GameAudit) -> str:
    base = f"./{row.id}"
    if row.has_preview_gif:
        return f"![]({base}/preview.gif)"
    if row.has_screen_png:
        return f"![]({base}/screen.png)<br>`preview.gif missing`"
    return "`missing`"


def _run_cell(row: audit_games.GameAudit) -> str:
    return f"`cargo run -- lurek_2d_content/games/{row.id}`"


def _api_cell(row: audit_games.GameAudit) -> str:
    if not row.apis:
        return "-"
    shown = ", ".join(f"`{api}`" for api in row.apis[:7])
    if len(row.apis) > 7:
        shown += f", +{len(row.apis) - 7}"
    return shown


def _row(row: audit_games.GameAudit) -> str:
    status = row.readme_status
    if row.validate_status == "FAIL":
        status += f"; validate:{row.validate_issues}"
    elif row.validate_status == "NOT_RUN":
        status += "; validate:not-run"
    if row.smoke_status != "NOT_RUN":
        status += f"; smoke:{row.smoke_status}"
    if row.known_failing:
        status += f"; known-failing:{row.known_failing_owner} ({row.known_failing_reason})"
    if not row.has_preview_gif:
        status += "; gif:missing"
    return (
        f"| [{row.title}](./{row.id}) | `{row.category}` | `{row.scale}` | `{row.decision}` | "
        f"{status} | {_api_cell(row)} | {_preview_cell(row)} | {_run_cell(row)} |"
    )


def _section(title: str, rows: list[audit_games.GameAudit], empty: str) -> list[str]:
    lines = [f"## {title}", ""]
    if not rows:
        lines += [empty, ""]
        return lines
    lines += [
        "| Demo | Type | Scale | Decision | Status | APIs | Preview | Run |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for row in rows:
        lines.append(_row(row))
    lines.append("")
    return lines


def build_catalog_json(rows: list[audit_games.GameAudit]) -> dict[str, Any]:
    return {
        "schema": 1,
        "source_issue": "https://github.com/Lurek2D/lurek_2d/issues/30",
        "generated_by": "tools/demos/gen_demo_catalog.py",
        "games_root": "lurek_2d_content/games",
        "decision_descriptions": game_catalog.DECISION_DESCRIPTIONS,
        "demos": [asdict(row) for row in rows],
    }


def build_readme(rows: list[audit_games.GameAudit]) -> str:
    rows = sorted(rows, key=lambda r: (game_catalog.category_sort_key(r.category), r.name))
    ready = [
        row for row in rows
        if game_catalog.is_public_decision(row.decision) and row.readme_status.lower() not in {"skeleton", "design"}
    ]
    backlog = [row for row in rows if game_catalog.is_backlog_decision(row.decision)]
    migration = [row for row in rows if game_catalog.is_non_public_decision(row.decision)]
    review = [row for row in rows if row.decision == "REVIEW"]

    lines: list[str] = [
        "# Lurek2D Demo Catalog",
        "",
        "This catalog is generated from runnable `lurek_2d_content/games/<name>` folders and the current product decisions.",
        "It lists only finished catalog candidates. Showcase-like entries, migration targets, and backlog cleanup stay out of this public catalog.",
        "",
        "## Run",
        "",
        "```powershell",
        "cargo run -- lurek_2d_content/games/<name>",
        "python tools/demos/audit_games.py",
        "python tools/demos/gen_demo_catalog.py",
        "```",
        "",
        "## Status Rules",
        "",
        "- Only `KEEP` rows appear here.",
        "- Each row should declare `Scale: game` or `Scale: minigame` in its local README.",
        "- `REWRITE_API`, `TRIM`, and migration decisions stay in `work/games-audit.md` and `work/games-audit.json` until they are cleaned up.",
        "",
    ]
    lines += _section("Catalog Candidates", ready, "No ready catalog candidates found.")
    if backlog or migration or review:
        lines += [
            "## Internal Backlog",
            "",
            "Non-catalog rows remain in `work/games-audit.md` and `work/games-audit.json` until they are rewritten, migrated, or removed.",
            "",
        ]

    return "\n".join(lines).rstrip() + "\n"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate lurek_2d_content/games/README.md and catalog.json.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--games-root", type=Path, default=game_catalog.DEFAULT_GAMES_ROOT)
    parser.add_argument("--readme", type=Path, default=DEFAULT_README)
    parser.add_argument("--catalog-json", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--audit-json", type=Path, help="Use an existing audit JSON report.")
    parser.add_argument("--validate", action="store_true", help="Run static validate_game.py checks while generating.")
    parser.add_argument(
        "--smoke-report",
        type=Path,
        action="append",
        help="Existing smoke_sweep JSON report to merge. Repeatable.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print README to stdout; do not write files.")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.audit_json:
        rows = _load_rows_from_json(args.audit_json)
    else:
        rows = audit_games.collect_audit(
            games_root=args.games_root,
            only=None,
            validate=args.validate,
            smoke_report=args.smoke_report,
        )

    readme = build_readme(rows)
    catalog = build_catalog_json(rows)

    if args.dry_run:
        print(readme)
        return 0

    args.readme.parent.mkdir(parents=True, exist_ok=True)
    args.readme.write_text(readme, encoding="utf-8")
    args.catalog_json.write_text(json.dumps(catalog, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"WROTE {game_catalog.rel_to_repo(args.readme)}")
    print(f"WROTE {game_catalog.rel_to_repo(args.catalog_json)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
