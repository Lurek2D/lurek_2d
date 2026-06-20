#!/usr/bin/env python3
"""Move non-public game catalog entries into explicit holding shelves.

This tool applies the product decisions from issue #30 in small, reversible
steps. It only moves whole demo directories within the workspace and refuses to
overwrite existing destinations.

Examples:
    python tools/demos/migrate_game_shelves.py --decision MOVE_INCUBATOR
    python tools/demos/migrate_game_shelves.py --decision MOVE_INCUBATOR --apply
"""

from __future__ import annotations

import argparse
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path

import game_catalog

REPO_ROOT = game_catalog.REPO_ROOT
GAMES_ROOT = game_catalog.DEFAULT_GAMES_ROOT

DESTINATION_ROOTS = {
    "MOVE_INCUBATOR": GAMES_ROOT / "_incubator",
    "MOVE_EXAMPLE": REPO_ROOT / "content" / "showcase",
}


@dataclass(frozen=True)
class MovePlan:
    identifier: str
    decision: str
    source: Path
    destination: Path


def _is_within(path: Path, root: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except ValueError:
        return False


def _build_plan(decisions: set[str], only: str | None) -> list[MovePlan]:
    plans: list[MovePlan] = []
    for identifier, (decision, _note) in sorted(game_catalog.GAME_DECISIONS.items()):
        if decision not in decisions:
            continue
        if only and only not in identifier and only != identifier.rsplit("/", 1)[-1]:
            continue
        if decision not in DESTINATION_ROOTS:
            raise SystemExit(f"ERROR: no destination shelf configured for {decision}")

        source = GAMES_ROOT / identifier
        if not source.is_dir():
            continue
        if decision == "MOVE_EXAMPLE" and identifier.startswith("showcase/"):
            destination = DESTINATION_ROOTS[decision] / identifier.split("/", 1)[1]
        else:
            destination = DESTINATION_ROOTS[decision] / identifier
        plans.append(MovePlan(identifier, decision, source, destination))
    return plans


def _validate_plan(plans: list[MovePlan]) -> None:
    for plan in plans:
        if not _is_within(plan.source, GAMES_ROOT):
            raise SystemExit(f"ERROR: source outside games root: {plan.source}")
        destination_root = DESTINATION_ROOTS[plan.decision]
        if not _is_within(plan.destination, destination_root):
            raise SystemExit(f"ERROR: destination outside configured shelf: {plan.destination}")
        if not _is_within(plan.destination, REPO_ROOT / "content"):
            raise SystemExit(f"ERROR: destination outside content root: {plan.destination}")
        if any(part in {"", ".", ".."} for part in plan.destination.relative_to(destination_root).parts):
            raise SystemExit(f"ERROR: unsafe destination path: {plan.destination}")
        if not plan.source.is_dir():
            raise SystemExit(f"ERROR: source missing: {plan.source}")
        if plan.destination.exists():
            raise SystemExit(f"ERROR: destination already exists: {plan.destination}")


def _write_incubator_readme() -> None:
    readme = GAMES_ROOT / "_incubator" / "README.md"
    content = """# Game Incubator

This shelf holds design-only, skeleton, or incomplete game/app demos moved out
of the public `content/games/<category>/<name>` catalog.

Entries here are intentionally not discovered by `tools/demos/smoke_sweep.py`
or the generated public demo catalog. Promote an entry back to
`content/games/<category>/<name>` only after it has real gameplay, README,
screen, preview GIF, static validation, and smoke evidence.
"""
    readme.parent.mkdir(parents=True, exist_ok=True)
    readme.write_text(content, encoding="utf-8")


def _write_showcase_contract() -> None:
    showcase_root = REPO_ROOT / "content" / "showcase"
    readme = showcase_root / "README.md"
    readme_content = """# Lurek2D Feature Showcase

This shelf holds runnable feature showcases and API labs that are not complete
catalog game demos. These entries used to live under `content/games/`, but issue
#30 keeps the public games catalog focused on complete playable games and apps.

Use `content/examples/` for small single-file API examples. Use
`content/games/` only when the entry has a complete game/app loop, README,
screen, preview GIF, validation, and smoke evidence.
"""
    agents = showcase_root / "AGENTS.md"
    agents_content = """# Showcase Contract

## Mission & Scope
- Own runnable feature showcases and API labs that are not complete games.
- Keep `content/games/` focused on catalog-ready playable demos.

## Files
- `README.md`: Showcase shelf overview.
- `<category>/<name>/main.lua`: Optional runnable showcase entry point.
- `<category>/<name>/README.md`: Feature notes and run command when present.

## Rules
- Do not present showcase entries as complete games.
- Prefer `content/examples/` for small single-file API examples.
- Keep moved entries runnable when they already had a `main.lua`.

## Workflow
- Validate moved Lua with `python tools/validate/validate_game.py <showcase-dir>` when APIs change.
- Use `python tools/demos/smoke_sweep.py --kind game --games-root content/showcase --only <name>` for runnable smoke checks when needed.
"""
    showcase_root.mkdir(parents=True, exist_ok=True)
    if not readme.exists():
        readme.write_text(readme_content, encoding="utf-8")
    if not agents.exists():
        agents.write_text(agents_content, encoding="utf-8")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Move non-public game catalog entries into explicit holding shelves.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--decision",
        action="append",
        required=True,
        choices=sorted(DESTINATION_ROOTS),
        help="Decision class to migrate. Repeatable.",
    )
    parser.add_argument("--only", help="Only migrate a matching id substring or demo name.")
    parser.add_argument("--apply", action="store_true", help="Perform moves. Omit for dry-run.")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    plans = _build_plan(set(args.decision), args.only)
    if not plans:
        print("No matching source folders found.")
        return 0

    _validate_plan(plans)
    for plan in plans:
        src = game_catalog.rel_to_repo(plan.source)
        dst = game_catalog.rel_to_repo(plan.destination)
        if args.apply:
            plan.destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(plan.source), str(plan.destination))
            print(f"MOVED {plan.decision:<14} {src} -> {dst}")
        else:
            print(f"DRY-RUN {plan.decision:<14} {src} -> {dst}")

    if args.apply and "MOVE_INCUBATOR" in set(args.decision):
        _write_incubator_readme()
        print(f"WROTE {game_catalog.rel_to_repo(GAMES_ROOT / '_incubator' / 'README.md')}")
    if args.apply and "MOVE_EXAMPLE" in set(args.decision):
        _write_showcase_contract()
        print(f"WROTE {game_catalog.rel_to_repo(REPO_ROOT / 'content' / 'showcase' / 'README.md')}")
        print(f"WROTE {game_catalog.rel_to_repo(REPO_ROOT / 'content' / 'showcase' / 'AGENTS.md')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
