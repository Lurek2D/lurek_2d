#!/usr/bin/env python3
"""Migrate hand-written spec sections into docs/specs/manual overlays.

This is a one-time migration helper. It reads existing docs/specs/*.md files,
extracts durable manual sections, writes docs/specs/manual/<module>.md, and
leaves existing specs in place for the generator to overwrite afterwards.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPECS = ROOT / "docs" / "specs"
MANUAL = SPECS / "manual"
GENERATED_HEADER_RE = re.compile(r"^<!--\s*GENERATED FILE\.", re.IGNORECASE)
MANUAL_HEADINGS = ["TL;DR", "Summary", "Notes", "Architecture Links"]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig") if path.exists() else ""


def split_section(text: str, heading: str) -> str:
    pattern = re.compile(rf"^##\s+{re.escape(heading)}\s*$", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return ""
    rest = text[match.end():]
    next_heading = re.search(r"^##\s+", rest, re.MULTILINE)
    if next_heading:
        rest = rest[: next_heading.start()]
    return rest.strip()


def normalize_heading(module: str) -> str:
    return f"# {module} manual spec overlay"


def build_overlay(module: str, source_text: str) -> str:
    sections = {heading: split_section(source_text, heading) for heading in MANUAL_HEADINGS}
    lines = [normalize_heading(module), ""]
    for heading in MANUAL_HEADINGS:
        body = sections.get(heading, "").strip()
        lines.extend([f"## {heading}", ""])
        if body:
            lines.extend([body, ""])
        elif heading == "TL;DR":
            lines.extend(["- Intentionally empty; generated fallback is allowed.", ""])
        elif heading == "Summary":
            lines.extend(["Intentionally empty; generated fallback is allowed.", ""])
        elif heading == "Architecture Links":
            lines.extend(["- Intentionally empty.", ""])
        else:
            lines.extend(["- Intentionally empty.", ""])
    return "\n".join(lines).rstrip() + "\n"


def migrate(overwrite: bool) -> list[Path]:
    MANUAL.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for spec in sorted(SPECS.glob("*.md")):
        if spec.name in {"README.md", "AGENTS.md", "SPEC_TEMPLATE.md"}:
            continue
        source_text = read_text(spec)
        if not source_text.strip():
            continue
        if GENERATED_HEADER_RE.match(source_text):
            continue
        target = MANUAL / spec.name
        if target.exists() and not overwrite:
            continue
        target.write_text(build_overlay(spec.stem, source_text), encoding="utf-8")
        written.append(target)
    return written


def main() -> int:
    parser = argparse.ArgumentParser(description="Migrate docs/specs manual sections into overlays")
    parser.add_argument("--overwrite", action="store_true", help="Rewrite existing manual overlays")
    parser.add_argument("--skip-generate", action="store_true", help="Do not run gen_module_specs.py afterwards")
    args = parser.parse_args()

    written = migrate(args.overwrite)
    for path in written:
        print(f"wrote {path.relative_to(ROOT).as_posix()}")
    print(f"manual overlays written: {len(written)}")

    if not args.skip_generate:
        subprocess.run([sys.executable, str(ROOT / "tools" / "docs" / "gen_module_specs.py")], check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
