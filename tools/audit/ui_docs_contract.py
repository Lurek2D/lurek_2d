#!/usr/bin/env python3
"""Check source-backed UI documentation claims and UI-owned architecture links."""
from __future__ import annotations

import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANUAL = ROOT / "docs/specs/manual/ui.md"
LIMITS = ROOT / "src/ui/limits.rs"
REQUIRED_LINKS = (
    "docs/architecture/module-scope-boundaries.md",
    "docs/architecture/render-pipeline.md",
    "docs/architecture/scripting-bridge.md",
    "docs/architecture/runtime-tooling-boundaries.md",
)
UI_DOC_FILES = (
    "docs/specs/manual/ui.md",
    "docs/specs/ui.md",
    "docs/modules/ui.md",
    "docs/wiki/Module-ui.md",
)
REMOVED_SYMBOLS = ("attachToEntity", "detachFromEntity")
BOILERPLATE = (
    "owns the ui",
    "keeps related runtime rules local",
    "defines how ui",
    "documents the boundary where ui",
    "while keeping call sites explicit",
)


def failures(root: Path = ROOT) -> list[str]:
    manual = (root / "docs/specs/manual/ui.md").read_text(encoding="utf-8")
    source = (root / "src/ui/limits.rs").read_text(encoding="utf-8")
    found: list[str] = []
    for name, value in re.findall(r"\b(max_\w+):\s*([0-9_]+(?:\s*\*\s*[0-9_]+)*)", source):
        factors = [int(part.strip().replace("_", "")) for part in value.split("*")]
        rendered = str(math.prod(factors))
        if rendered not in manual:
            found.append(f"docs/specs/manual/ui.md: UiLimits `{name}` value `{rendered}` is undocumented")
    for relative in REQUIRED_LINKS:
        link_name = Path(relative).name
        if link_name not in manual:
            found.append(f"docs/specs/manual/ui.md: missing architecture link `{relative}`")
        elif not (root / relative).exists():
            found.append(f"docs/specs/manual/ui.md: broken architecture link `{relative}`")
    for removed in REMOVED_SYMBOLS:
        for path in (
            root / "src/lua_api/ui_api.rs",
            root / "content/examples/ui.lua",
            root / "tests/lua/unit/test_ui_unit.lua",
        ):
            if removed in path.read_text(encoding="utf-8"):
                found.append(f"{path.relative_to(root).as_posix()}: removed API `{removed}` is still live")
    api_source = (root / "src/lua_api/ui_api.rs").read_text(encoding="utf-8")
    for stale in ("table|number", "widget table or widget index"):
        if stale in api_source:
            found.append(f"src/lua_api/ui_api.rs: stale numeric widget-reference documentation `{stale}`")
    for phrase in (
        "Use `loadLayoutFile(path)`; this alias",
        "canonical form is `(width, height, path)`",
        "legacy `(path, width, height)` form",
    ):
        if phrase not in api_source:
            found.append(f"src/lua_api/ui_api.rs: missing compatibility documentation `{phrase}`")
    for path in (root / "src/ui").rglob("*.rs"):
        lines = path.read_text(encoding="utf-8").splitlines()
        docs = [line[3:].strip().lower() for line in lines if line.startswith("//!")]
        if len(docs) < 3:
            found.append(f"{path.relative_to(root).as_posix()}: UI file documentation needs at least three concrete lines")
            continue
        joined = "\n".join(docs)
        for phrase in BOILERPLATE:
            if phrase in joined:
                found.append(f"{path.relative_to(root).as_posix()}: boilerplate UI file documentation `{phrase}`")
    example = (root / "content/examples/ui.lua").read_text(encoding="utf-8")
    if "loadLayoutGameFile deprecated ok:" not in example or "use loadLayoutFile instead:" not in example:
        found.append("content/examples/ui.lua: deprecated loader lacks a concrete canonical migration example")
    if "-- TODO:" in example or "--@api-stub:" in example:
        found.append("content/examples/ui.lua: unfinished UI example marker")
    return sorted(found)


def main() -> int:
    found = failures()
    if found:
        print("\n".join(found))
        return 1
    print("[OK] UI docs contract matches limits, links, lifecycle migrations, and qualitative documentation rules")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
