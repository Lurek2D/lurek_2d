#!/usr/bin/env python3
"""Merge content/examples2/<module>_NN.lua into content/examples/<module>.lua.

Rules:
- Group source files by module prefix.
- Sort each group by numeric suffix.
- Preserve the real example blocks as-is.
- Strip only the per-file trailing print("...lua") line from each source chunk.
- Overwrite content/examples/<module>.lua for every merged module.
- Remove stale root-level .lua files in content/examples/ that were generated
  earlier but no longer have a source group in content/examples2/.
- Leave subdirectories in content/examples/ untouched.

Usage:
    python tools/fix/merge_examples2_into_examples.py [--dry-run]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
EXAMPLES2 = ROOT / "content" / "examples2"
EXAMPLES = ROOT / "content" / "examples"

SOURCE_RE = re.compile(r"^([a-z0-9]+)_(\d+)\.lua$")
TRAILING_PRINT_RE = re.compile(r'^print\(".*?\.lua"\)\s*$')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge content/examples2 parts into content/examples module files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Report what would change without writing files",
    )
    return parser.parse_args()


def group_sources() -> dict[str, list[Path]]:
    groups: dict[str, list[tuple[int, Path]]] = {}
    for path in sorted(EXAMPLES2.glob("*.lua")):
        match = SOURCE_RE.match(path.name)
        if not match:
            continue
        module = match.group(1)
        order = int(match.group(2))
        groups.setdefault(module, []).append((order, path))

    ordered: dict[str, list[Path]] = {}
    for module, items in groups.items():
        ordered[module] = [path for _, path in sorted(items, key=lambda item: item[0])]
    return ordered


def trim_source_chunk(text: str) -> str:
    text = text.replace("\r\n", "\n").lstrip("\ufeff")
    lines = text.split("\n")

    while lines and not lines[-1].strip():
        lines.pop()

    if lines and TRAILING_PRINT_RE.match(lines[-1].strip()):
        lines.pop()

    while lines and not lines[-1].strip():
        lines.pop()

    return "\n".join(lines).strip("\n")


def build_output(module: str, sources: list[Path]) -> str:
    header = [
        f"-- content/examples/{module}.lua",
        (
            f"-- Auto-generated from content/examples2/{module}_*.lua "
            f"by tools/fix/merge_examples2_into_examples.py"
        ),
        f"-- Run: cargo run -- content/examples/{module}.lua",
    ]

    chunks = ["\n".join(header)]
    for source in sources:
        chunk = trim_source_chunk(source.read_text(encoding="utf-8"))
        if chunk:
            chunks.append(chunk)

    chunks.append(f'print("content/examples/{module}.lua")')
    return "\n\n".join(chunks) + "\n"


def write_outputs(groups: dict[str, list[Path]], dry_run: bool) -> int:
    changed = 0
    EXAMPLES.mkdir(parents=True, exist_ok=True)

    generated_names: set[str] = set()

    for module, sources in sorted(groups.items()):
        target = EXAMPLES / f"{module}.lua"
        generated_names.add(target.name)
        content = build_output(module, sources)
        previous = target.read_text(encoding="utf-8") if target.exists() else None
        if previous == content:
            print(f"OK     {target.relative_to(ROOT)} ({len(sources)} source files)")
            continue

        changed += 1
        print(f"WRITE  {target.relative_to(ROOT)} ({len(sources)} source files)")
        if not dry_run:
            target.write_text(content, encoding="utf-8")

    stale_targets = [
        path
        for path in sorted(EXAMPLES.glob("*.lua"))
        if path.name not in generated_names
    ]
    for stale in stale_targets:
        changed += 1
        print(f"REMOVE {stale.relative_to(ROOT)}")
        if not dry_run:
            stale.unlink()

    return changed


def main() -> int:
    args = parse_args()
    if not EXAMPLES2.exists():
        print(f"Missing source directory: {EXAMPLES2}", file=sys.stderr)
        return 1

    groups = group_sources()
    if not groups:
        print("No content/examples2/<module>_NN.lua files found", file=sys.stderr)
        return 1

    changed = write_outputs(groups, dry_run=args.dry_run)
    print(f"Done. Modules: {len(groups)}  Changed: {changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())