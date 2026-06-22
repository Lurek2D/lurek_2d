#!/usr/bin/env python3
"""Generate build/docs-data/evidence_manifest.json for module specs."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import module_registry


ROOT = Path(__file__).resolve().parents[2]
DOCS_DATA = module_registry.DOCS_DATA
LEGACY_LOGS_DATA = module_registry.LEGACY_LOGS_DATA
OUTPUT = DOCS_DATA / "evidence_manifest.json"


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def infer_module_from_name(path: Path) -> str | None:
    stem = path.stem
    candidates = module_registry.list_modules()
    for module in sorted(candidates, key=len, reverse=True):
        patterns = [
            f"test_{module}_",
            f"{module}_",
            module,
        ]
        if any(stem.startswith(pattern) for pattern in patterns):
            return module
    for part in path.parts:
        if part in candidates:
            return part
    return None


def add(manifest: dict[str, dict[str, list[str]]], module: str | None, key: str, path: Path) -> None:
    if not module:
        return
    manifest.setdefault(
        module,
        {
            "evidence_tests": [],
            "golden_tests": [],
            "current_artifacts": [],
            "baseline_artifacts": [],
        },
    )[key].append(rel(path))


def scan() -> dict[str, dict[str, list[str]]]:
    manifest: dict[str, dict[str, list[str]]] = {}
    roots = [
        (ROOT / "tests" / "lua" / "evidence", "evidence_tests"),
        (ROOT / "tests" / "lua" / "golden", "golden_tests"),
        (ROOT / "tests" / "artifacts" / "current", "current_artifacts"),
        (ROOT / "tests" / "artifacts" / "baselines", "baseline_artifacts"),
    ]
    for root, key in roots:
        if not root.exists():
            continue
        for path in sorted(p for p in root.rglob("*") if p.is_file()):
            module = infer_module_from_name(path)
            add(manifest, module, key, path)
    for entry in manifest.values():
        for key, values in entry.items():
            entry[key] = sorted(set(values))
    return dict(sorted(manifest.items()))


def main() -> int:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    manifest = scan()
    OUTPUT.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Generated {rel(OUTPUT)} for {len(manifest)} modules")
    return 0


if __name__ == "__main__":
    sys.exit(main())
