"""
gen_game_readmes.py — Generate or repair README.md files for content/games/ projects.

Scans each game directory for main.lua and conf.lua, extracts lurek.* API
references, and produces a well-structured README.md matching the canonical
template from content/games/arcade/asteroids/README.md.

Usage:
    python tools/demos/gen_game_readmes.py [options]

Arguments:
    --game PATH      Path to one game directory (e.g. content/games/action/platformer)
    --all            Process all game directories under content/games/
    --dry-run        Print generated README to stdout, don't write files
    --threshold N    Only update READMEs shorter than N lines (default: 30)
    --force          Regenerate even if README is already extensive

Examples:
    # Preview generated README for one game (no file write)
    python tools/demos/gen_game_readmes.py --dry-run --game content/games/rpg/loot_rpg

    # Fix all short READMEs (under 30 lines, default threshold)
    python tools/demos/gen_game_readmes.py --all

    # Regenerate all regardless of current length
    python tools/demos/gen_game_readmes.py --all --force

    # Raise threshold so READMEs under 60 lines are regenerated
    python tools/demos/gen_game_readmes.py --all --threshold 60

Exit codes:
    0   All targeted READMEs written (or dry-run completed) successfully.
    1   At least one game directory was not found or main.lua was missing.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Repository root detection
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
GAMES_ROOT = REPO_ROOT / "content" / "games"

# ---------------------------------------------------------------------------
# Known API module descriptions
# These are used when a module is detected in main.lua.
# Keys must match the second component of the lurek.X call (e.g. "render",
# "input", "camera"…).
# ---------------------------------------------------------------------------
API_DESCRIPTIONS: dict[str, str] = {
    "render":   "draws shapes, text, and configures background colour.",
    "graphic":  "draws sprites, shapes, and text (render API namespace).",
    "input":    "keyboard bindings and action query (pressed/held/just-pressed).",
    "window":   "sets the window title and background colour.",
    "event":    "signals clean engine shutdown.",
    "camera":   "creates and positions the 2D viewport camera.",
    "particle": "particle system creation and per-frame emission.",
    "tween":    "smooth value animation with `tween.to`.",
    "timer":    "FPS target, elapsed time, and delta helpers.",
    "audio":    "plays and manages sound effects and music.",
    "math":     "engine math utilities (Vec2, Rect, clamp, lerp).",
    "data":     "serialise and deserialise game state.",
    "save":     "load and persist save files.",
    "scene":    "scene graph and entity management.",
    "physics":  "rigid-body simulation and collision detection.",
    "tilemap":  "tile map loading and rendering.",
    "sprite":   "sprite sheet animation and drawing.",
    "ui":       "built-in UI widget layer.",
    "net":      "network state synchronisation.",
    "thread":   "background worker threads via Channel.",
    "fs":       "file system read / write helpers.",
    "debug":    "in-game debug overlays and logging helpers.",
}

# ---------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------

def _find_lurek_modules(lua_text: str) -> list[str]:
    """Return sorted unique lurek.<module> roots referenced in *lua_text*."""
    hits = re.findall(r"\blurek\.([a-zA-Z_][a-zA-Z0-9_]*)\b", lua_text)
    # Drop bare 'lurek.init', 'lurek.process', 'lurek.draw', etc. (callbacks)
    CALLBACKS = {"init", "process", "draw", "render_ui", "draw_ui", "update"}
    modules: set[str] = set()
    for h in hits:
        if h not in CALLBACKS:
            modules.add(h)
    return sorted(modules)


def _parse_conf(conf_path: Path) -> dict:
    """Extract title, description, and window dims from conf.lua (best-effort)."""
    info: dict = {}
    if not conf_path.exists():
        return info
    text = conf_path.read_text(encoding="utf-8", errors="replace")
    # title = "..."
    m = re.search(r'title\s*=\s*"([^"]+)"', text)
    if m:
        info["title"] = m.group(1)
    # description = "..."
    m = re.search(r'description\s*=\s*"([^"]+)"', text)
    if m:
        info["description"] = m.group(1)
    # width / height
    m = re.search(r'\bwidth\s*=\s*(\d+)', text)
    if m:
        info["width"] = m.group(1)
    m = re.search(r'\bheight\s*=\s*(\d+)', text)
    if m:
        info["height"] = m.group(1)
    return info


def _game_rel_path(game_dir: Path) -> str:
    """Return 'content/games/category/name' relative to repo root."""
    try:
        return game_dir.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return str(game_dir)


def _title_from_dir(game_dir: Path) -> str:
    """Convert directory name to a Title Case display name."""
    return game_dir.name.replace("_", " ").title()

# ---------------------------------------------------------------------------
# README generator
# ---------------------------------------------------------------------------

def generate_readme(game_dir: Path) -> str:
    """Return a full README.md string for the game at *game_dir*."""
    main_lua = game_dir / "main.lua"
    conf_lua = game_dir / "conf.lua"
    existing_readme = game_dir / "README.md"

    if not main_lua.exists():
        raise FileNotFoundError(f"main.lua not found in {game_dir}")

    lua_text = main_lua.read_text(encoding="utf-8", errors="replace")
    conf = _parse_conf(conf_lua)

    # --- Title ---
    title = conf.get("title") or _title_from_dir(game_dir)

    # --- Tagline: try to pull a description from conf.lua or first comment ---
    tagline = conf.get("description", "")
    if not tagline:
        # Try to extract from first -- comment block in main.lua
        first_comment = re.search(r"^--\s*(.+?)(?:\n|$)", lua_text, re.MULTILINE)
        if first_comment:
            candidate = first_comment.group(1).strip(" -=")
            # Reject pure separator lines or category/engine lines
            if len(candidate) > 12 and "=" not in candidate and "Category" not in candidate:
                tagline = candidate
    if not tagline:
        tagline = f"A {_title_from_dir(game_dir)} game built with Lurek2D."

    # --- Run path ---
    rel = _game_rel_path(game_dir)

    # --- Controls: try to extract from existing README if present ---
    controls_table = _extract_controls(existing_readme, lua_text)

    # --- Gameplay paragraph ---
    gameplay = _extract_gameplay(existing_readme)

    # --- APIs Used ---
    modules = _find_lurek_modules(lua_text)
    api_lines: list[str] = []
    for mod in modules:
        desc = API_DESCRIPTIONS.get(mod, "engine bindings used by this game.")
        api_lines.append(f"- `lurek.{mod}` — {desc}")

    if not api_lines:
        api_lines = ["- _(API references not detected — check main.lua manually)_"]

    # --- Changes from Original Demo ---
    changes = _extract_changes(existing_readme)

    # --- Build output ---
    lines: list[str] = [
        f"# {title}",
        "",
        f"_{tagline}_",
        "",
        "## Run",
        "",
        "```powershell",
        f"cargo run -- {rel}",
        "```",
        "",
        "## Controls",
        "",
    ]
    lines.extend(controls_table)
    lines += [
        "",
        "## Gameplay",
        "",
        gameplay,
        "",
        "## APIs Used",
        "",
        "**`lurek.*` engine bindings**",
        "",
    ]
    lines.extend(api_lines)
    lines += [
        "",
        "**Lureksome (`library/`) modules**",
        "",
        "_None._",
        "",
        "## Changes from Original Demo",
        "",
        changes,
    ]

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Section extractors — pull existing content when available to avoid discarding
# manually written prose.
# ---------------------------------------------------------------------------

def _extract_controls(readme: Path, lua_text: str) -> list[str]:
    """Return markdown table rows for the Controls section."""
    if readme.exists():
        text = readme.read_text(encoding="utf-8", errors="replace")
        # Find ## Controls section
        m = re.search(
            r"##\s+Controls\s*\n(.*?)(?=\n##|\Z)", text, re.DOTALL
        )
        if m:
            block = m.group(1).strip()
            if block:
                return block.splitlines()

    # Fall back: try to extract bindings from lua_text
    rows = _extract_bindings_from_lua(lua_text)
    if rows:
        return rows
    return [
        "| Key    | Action |",
        "| ------ | ------ |",
        "| Escape | Quit   |",
    ]


def _extract_bindings_from_lua(lua_text: str) -> list[str]:
    """Heuristic: extract bind/action lines from lurek.input calls."""
    rows: list[tuple[str, str]] = []
    seen: set[str] = set()

    # lurek.input.bind("action", "key")
    for m in re.finditer(
        r'lurek\.input\.bind\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)', lua_text
    ):
        action, key = m.group(1), m.group(2)
        label = key.capitalize()
        desc = action.replace("_", " ").title()
        if action not in seen:
            rows.append((label, desc))
            seen.add(action)

    # lurek.input.action("name", {"key", ...})
    for m in re.finditer(
        r'lurek\.input\.action\(\s*"([^"]+)"\s*,\s*\{([^}]+)\}', lua_text
    ):
        action = m.group(1)
        keys_raw = m.group(2)
        keys = re.findall(r'"([^"]+)"', keys_raw)
        key = keys[0] if keys else "?"
        desc = action.replace("_", " ").title()
        if action not in seen:
            rows.append((key.capitalize(), desc))
            seen.add(action)

    if not rows:
        return []

    # Pad columns for readability
    key_w = max(len(r[0]) for r in rows)
    act_w = max(len(r[1]) for r in rows)
    header = f"| {'Key':<{key_w}} | {'Action':<{act_w}} |"
    sep = f"| {'-' * key_w} | {'-' * act_w} |"
    result = [header, sep]
    for key, action in rows:
        result.append(f"| {key:<{key_w}} | {action:<{act_w}} |")
    return result


def _extract_gameplay(readme: Path) -> str:
    """Return the Gameplay prose paragraph from an existing README, or a stub."""
    if readme.exists():
        text = readme.read_text(encoding="utf-8", errors="replace")
        # Check common section names for prose
        for section in ("## Gameplay", "## How to Play", "## Mechanics", "## Features"):
            m = re.search(
                re.escape(section) + r"\s*\n(.*?)(?=\n##|\Z)", text, re.DOTALL
            )
            if m:
                block = m.group(1).strip()
                # Return first prose paragraph (not a list or table)
                for para in re.split(r"\n\n+", block):
                    para = para.strip()
                    if para and not para.startswith("|") and not para.startswith("-"):
                        return para
                # If only list items, return them verbatim as a joined sentence
                if block:
                    return block
    return "<!-- STUB: describe the gameplay loop here. -->"


def _extract_changes(readme: Path) -> str:
    """Return the Changes section text or a generic original-game note."""
    if readme.exists():
        text = readme.read_text(encoding="utf-8", errors="replace")
        m = re.search(
            r"##\s+Changes from Original Demo\s*\n(.*?)(?=\n##|\Z)",
            text, re.DOTALL
        )
        if m:
            block = m.group(1).strip()
            if block:
                return block
    return (
        "This is an original game created for Lurek2D — no prior demo existed. "
        "Built from scratch following the patterns established in the "
        "`content/games/` collection."
    )

# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

def find_all_game_dirs() -> list[Path]:
    """Return all directories under GAMES_ROOT that contain a main.lua."""
    result: list[Path] = []
    for root, dirs, files in os.walk(GAMES_ROOT):
        dirs.sort()
        if "main.lua" in files:
            result.append(Path(root))
    return sorted(result)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Generate or repair README.md files for content/games/ projects.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--game", metavar="PATH",
        help="Path to one game directory (e.g. content/games/rpg/loot_rpg).",
    )
    group.add_argument(
        "--all", action="store_true",
        help="Process all game directories under content/games/.",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print generated README to stdout; do not write any files.",
    )
    parser.add_argument(
        "--threshold", type=int, default=30, metavar="N",
        help="Only update READMEs shorter than N lines (default: 30). "
             "Ignored when --force is set.",
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Regenerate even if the README already meets the threshold.",
    )
    args = parser.parse_args(argv)

    if args.all:
        targets = find_all_game_dirs()
    else:
        p = Path(args.game)
        if not p.is_absolute():
            p = REPO_ROOT / p
        targets = [p]

    errors = 0
    updated = 0
    skipped = 0

    for game_dir in targets:
        if not game_dir.exists():
            print(f"ERROR: directory not found: {game_dir}", file=sys.stderr)
            errors += 1
            continue

        main_lua = game_dir / "main.lua"
        if not main_lua.exists():
            print(f"ERROR: no main.lua in {game_dir}", file=sys.stderr)
            errors += 1
            continue

        readme_path = game_dir / "README.md"
        current_lines = 0
        if readme_path.exists():
            current_lines = len(readme_path.read_text(encoding="utf-8", errors="replace").splitlines())

        if not args.force and current_lines >= args.threshold:
            if args.all:
                skipped += 1
            else:
                print(
                    f"SKIP {_game_rel_path(game_dir)}: README has {current_lines} lines "
                    f"(threshold {args.threshold}). Use --force to regenerate.",
                    file=sys.stderr,
                )
            continue

        try:
            content = generate_readme(game_dir)
        except Exception as exc:  # noqa: BLE001
            print(f"ERROR generating README for {game_dir}: {exc}", file=sys.stderr)
            errors += 1
            continue

        if args.dry_run:
            print(f"--- {_game_rel_path(game_dir)}/README.md ---")
            print(content)
        else:
            readme_path.write_text(content, encoding="utf-8")
            new_lines = len(content.splitlines())
            print(f"WROTE {_game_rel_path(game_dir)}/README.md ({new_lines} lines)")
            updated += 1

    if args.all and not args.dry_run:
        print(f"\nSummary: {updated} updated, {skipped} skipped, {errors} errors.")

    return 0 if errors == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
