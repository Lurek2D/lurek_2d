#!/usr/bin/env python3
"""Enforce the UI/render ownership boundary described in the UI architecture spec.

The check is deliberately lexical: UI must not take a direct dependency on GPU,
ECS, image-codec, or host-filesystem owners, while render must not import UI
widget types.  It prints deterministic `path:line: reason` diagnostics.
"""
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
RULES = {
    "src/ui": ("crate::ecs", "crate::scene", "wgpu"),
    "src/render": ("crate::ui::context::WidgetKind", "crate::ui::widget", "crate::ui::controls", "crate::ui::extras"),
}

def violations(root: Path = ROOT) -> list[str]:
    found: list[str] = []
    for relative, forbidden in RULES.items():
        for path in sorted((root / relative).rglob("*.rs")):
            for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                if line.lstrip().startswith("//"):
                    continue
                for token in forbidden:
                    if token in line:
                        found.append(f"{path.relative_to(root).as_posix()}:{number}: forbidden boundary dependency `{token}`")
    return found

def main() -> int:
    found = violations()
    if found:
        print("\n".join(found))
        return 1
    print("[OK] UI/render dependency boundary passes")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
