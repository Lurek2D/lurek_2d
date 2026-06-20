#!/usr/bin/env python3
"""Generate content/games/README.md and catalog.json from audited metadata.

The generated README is a public-facing catalog. It does not list skeletons or
feature-only examples as ready games; migrated entries live on their owning
shelf, while unresolved duplicates remain visible in a migration queue.

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
    return f"`cargo run -- content/games/{row.id}`"


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
        f"| [{row.title}](./{row.id}) | `{row.category}` | `{row.decision}` | "
        f"{status} | {_api_cell(row)} | {_preview_cell(row)} | {_run_cell(row)} |"
    )


def _section(title: str, rows: list[audit_games.GameAudit], empty: str) -> list[str]:
    lines = [f"## {title}", ""]
    if not rows:
        lines += [empty, ""]
        return lines
    lines += [
        "| Demo | Type | Decision | Status | APIs | Preview | Run |",
        "|---|---|---|---|---|---|---|",
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
        "games_root": "content/games",
        "decision_descriptions": game_catalog.DECISION_DESCRIPTIONS,
        "demos": [asdict(row) for row in rows],
    }


def build_readme(rows: list[audit_games.GameAudit]) -> str:
    rows = sorted(rows, key=lambda r: (game_catalog.category_sort_key(r.category), r.name))
    ready = [
        row for row in rows
        if row.decision == "KEEP" and row.readme_status.lower() not in {"skeleton", "design"}
    ]
    rewrite_or_trim = [row for row in rows if row.decision in {"REWRITE_API", "TRIM"}]
    migration = [row for row in rows if not game_catalog.is_public_decision(row.decision)]
    review = [row for row in rows if row.decision == "REVIEW"]

    lines: list[str] = [
        "# Lurek2D Demo Catalog",
        "",
        "This catalog is generated from runnable `content/games/<category>/<name>` folders and the product decisions in issue #30.",
        "It separates playable catalog candidates from rewrite and trim work so skeletons are not presented as complete games.",
        "",
        "## Run",
        "",
        "```powershell",
        "cargo run -- content/games/<category>/<name>",
        "python tools/demos/audit_games.py",
        "python tools/demos/gen_demo_catalog.py",
        "```",
        "",
        "## Status Rules",
        "",
        "- `KEEP` rows are public catalog candidates once README, screen, preview GIF, validation, and smoke evidence are current.",
        "- `REWRITE_API` and `TRIM` rows stay visible as priority public work, but are not advertised as finished.",
        "- `MOVE_EXAMPLE` and `MOVE_INCUBATOR` rows belong on `content/showcase/` or `content/games/_incubator/` once migrated.",
        "- Unresolved `MERGE_OR_DROP` rows are listed only while duplicate ownership remains unresolved.",
        "",
    ]
    lines += _section("Catalog Candidates", ready, "No ready catalog candidates found.")
    lines += _section("Rewrite Or Trim Queue", rewrite_or_trim, "No rewrite or trim candidates found.")
    if migration:
        lines += _section("Migration Queue", migration, "No migration candidates found.")
    if review:
        lines += _section("Needs Classification", review, "No unclassified demos found.")

    return "\n".join(lines).rstrip() + "\n"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate content/games/README.md and catalog.json.",
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
