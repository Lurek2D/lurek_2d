#!/usr/bin/env python3
"""Shared discovery and classification helpers for content/games catalogs."""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_GAMES_ROOT = REPO_ROOT / "content" / "games"

CATEGORY_ORDER = ["games"]

PUBLIC_DECISIONS = {"KEEP"}
BACKLOG_DECISIONS = {"REWRITE_API", "TRIM"}
NON_PUBLIC_DECISIONS = {"MOVE_EXAMPLE", "MOVE_INCUBATOR", "MERGE_OR_DROP", "DROP_OR_IDEA", "REVIEW"}

TITLE_OVERRIDES = {
    "eu2": "Europa Universalis 2 Lite",
    "finance_app": "Household Finance Lab",
    "hex_logistics": "Hex Logistics",
    "music_composer": "Music Composer",
    "tactical_mech_shooter": "Tactical Mech Shooter",
}

DECISION_DESCRIPTIONS = {
    "KEEP": "Catalog candidate after metadata, preview, validation, and smoke evidence are current.",
    "REWRITE_API": "Keep the concept, but rewrite around current idiomatic lurek.* APIs.",
    "TRIM": "Keep only a small playable vertical slice.",
    "MOVE_EXAMPLE": "Move to content/examples or tests/lua/evidence.",
    "MOVE_INCUBATOR": "Move to an incubator until it is implemented and smoke-testable.",
    "MERGE_OR_DROP": "Resolve duplicate ownership, then keep one clear public demo or drop the duplicate.",
    "DROP_OR_IDEA": "Move to ideas or drop from maintained demo content.",
    "REVIEW": "Not covered by issue #30; needs manual classification.",
}

# Product decisions for the current flat `content/games/<name>` catalog.
GAME_DECISIONS: dict[str, tuple[str, str]] = {
    "cannon_fodder": ("KEEP", "Tactical action game kept in the current flat catalog."),
    "dungeon_crawler": ("KEEP", "Raycaster dungeon game kept in the current flat catalog."),
    "eu2": ("KEEP", "Playable province strategy slice kept in the current flat catalog."),
    "finance_app": ("KEEP", "Data-heavy finance dashboard app kept in the current flat catalog."),
    "hex_logistics": ("KEEP", "Hex logistics mini game kept in the current flat catalog."),
    "music_composer": ("KEEP", "Interactive music composition app kept in the current flat catalog."),
    "sensible_soccer": ("KEEP", "Top-down soccer game kept in the current flat catalog."),
    "tactical_mech_shooter": ("KEEP", "Complete tactical mech campaign with current validation, regression, and smoke evidence."),
}

CALLBACKS = {
    "init",
    "process",
    "process_physics",
    "process_late",
    "draw",
    "draw_ui",
    "render_ui",
    "load",
    "update",
    "keypressed",
    "keyreleased",
    "mousepressed",
    "mousereleased",
    "mousemoved",
    "wheelmoved",
    "touchpressed",
    "touchmoved",
    "touchreleased",
    "focus",
    "visible",
    "resize",
    "quit",
    "errhand",
}

STATUS_RE = re.compile(r"\*\*Status:\*\*\s*([^\n\r|]+)|\bStatus:\s*([^\n\r|]+)", re.I)
SCALE_RE = re.compile(r"\*\*Scale:\*\*\s*([^\n\r|]+)|\bScale:\s*([^\n\r|]+)", re.I)
API_RE = re.compile(r"\blurek\.([a-zA-Z_][a-zA-Z0-9_]*)\b")


def rel_to_repo(path: Path) -> str:
    try:
        return path.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def game_id(game_dir: Path, games_root: Path = DEFAULT_GAMES_ROOT) -> str:
    return game_dir.relative_to(games_root).as_posix()


def split_game_identifier(identifier: str) -> tuple[str, str]:
    if "/" in identifier:
        return identifier.split("/", 1)
    return "games", identifier


def title_from_id(identifier: str) -> str:
    if identifier in TITLE_OVERRIDES:
        return TITLE_OVERRIDES[identifier]
    return identifier.rsplit("/", 1)[-1].replace("_", " ").replace("-", " ").title()


def category_sort_key(category: str) -> tuple[int, str]:
    try:
        return CATEGORY_ORDER.index(category), category
    except ValueError:
        return len(CATEGORY_ORDER), category


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def discover_game_dirs(games_root: Path = DEFAULT_GAMES_ROOT) -> list[Path]:
    out: list[Path] = []
    if not games_root.is_dir():
        return out
    for main_lua in sorted(games_root.rglob("main.lua")):
        rel = main_lua.parent.relative_to(games_root)
        if any(part.startswith("_") for part in rel.parts):
            continue
        out.append(main_lua.parent)
    return out


def find_lurek_modules(game_dir: Path) -> list[str]:
    modules: set[str] = set()
    for lua_file in sorted(game_dir.rglob("*.lua")):
        text = read_text(lua_file)
        for hit in API_RE.findall(text):
            if hit not in CALLBACKS:
                modules.add(hit)
    return sorted(modules)


def extract_status(readme_text: str) -> str:
    match = STATUS_RE.search(readme_text)
    if not match:
        return "unspecified"
    raw = (match.group(1) or match.group(2) or "").strip()
    raw = raw.strip(" _*`.")
    return raw or "unspecified"


def extract_scale(readme_text: str) -> str:
    match = SCALE_RE.search(readme_text)
    if not match:
        return "unspecified"
    raw = (match.group(1) or match.group(2) or "").strip().lower()
    raw = raw.strip(" _*`.")
    if raw in {"game", "minigame"}:
        return raw
    return "unspecified"


def extract_description(game_dir: Path) -> str:
    readme = read_text(game_dir / "README.md")
    for line in readme.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(("#", "|", "!", "[", "- ", "* ", "```")):
            continue
        if stripped.lower().startswith(("category:", "**category", "**status", "status:")):
            continue
        return stripped[:220]

    main_lua = read_text(game_dir / "main.lua")
    for match in re.finditer(r"^\s*--\s*(.+)$", main_lua, re.M):
        text = match.group(1).strip(" -=\t")
        if len(text) >= 16 and "category" not in text.lower():
            return text[:220]
    return "No description available."


def decision_for(identifier: str) -> tuple[str, str]:
    return GAME_DECISIONS.get(identifier, ("REVIEW", DECISION_DESCRIPTIONS["REVIEW"]))


def is_public_decision(decision: str) -> bool:
    return decision in PUBLIC_DECISIONS


def is_backlog_decision(decision: str) -> bool:
    return decision in BACKLOG_DECISIONS


def is_non_public_decision(decision: str) -> bool:
    return decision in NON_PUBLIC_DECISIONS
