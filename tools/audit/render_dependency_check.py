#!/usr/bin/env python3
"""Enforce the province/render GPU ownership boundary.

Province may prepare CPU snapshots, but it must not use `wgpu`. Render may
consume those snapshots, but it must not depend on `ProvinceRegistry` or the
retired province GPU-upload module. Diagnostics are deterministic and use
workspace-relative paths.
"""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
RULES = {
    "src/province": ("wgpu",),
    "src/render": (
        "crate::province::registry",
        "ProvinceRegistry",
        "crate::province::gpu_upload",
    ),
}


def violations(root: Path = ROOT) -> list[str]:
    """Return sorted source locations that violate the ownership boundary."""
    found: list[str] = []
    for relative, forbidden in RULES.items():
        for path in sorted((root / relative).rglob("*.rs")):
            for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                if line.lstrip().startswith("//"):
                    continue
                for token in forbidden:
                    if token in line:
                        found.append(
                            f"{path.relative_to(root).as_posix()}:{number}: "
                            f"forbidden boundary dependency `{token}`"
                        )
    return found


def main() -> int:
    """Run the read-only ownership check."""
    found = violations()
    if found:
        print("\n".join(found))
        return 1
    print("[OK] province/render dependency boundary passes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
