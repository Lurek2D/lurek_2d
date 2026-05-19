#!/usr/bin/env python3
"""Collapse consecutive identical do...end stub blocks into stacked markers + one body.

After fix_examples2_stubs.py expanded slash-format stubs by duplicating bodies,
this script reverses that: consecutive blocks with identical bodies and the same
description line are merged into N stacked --@api-stub: markers followed by
the description and the body once.

Usage:
    python tools/fix/collapse_duplicate_stubs.py [--dry-run] [--file NAME]
"""
from __future__ import annotations
import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXAMPLES2 = ROOT / "content" / "examples2"


@dataclass
class Block:
    """One do...end unit from a Lua file."""
    stubs: list[str]          # --@api-stub: X values (stripped)
    desc_lines: list[str]     # comment lines between marker and do
    body_lines: list[str]     # lines INSIDE do...end (the raw text lines)
    trailing_blanks: list[str]  # blank lines after `end`


def _body_key(body: list[str]) -> str:
    """Normalised key for body comparison (strip whitespace variance)."""
    return "\n".join(ln.strip() for ln in body if ln.strip())


def parse_blocks(lines: list[str]) -> tuple[list, list[str]]:
    """Parse file into (blocks_or_raw_chunks, ...).

    Returns a list where each element is either:
      - a Block (a do...end unit with --@api-stub: markers), or
      - a str  (raw line that doesn't belong to any block)
    """
    result: list = []
    i = 0
    n = len(lines)

    while i < n:
        raw = lines[i]
        stripped = raw.strip()

        # Start of a stub block
        if stripped.startswith("--@api-stub:"):
            stubs: list[str] = []
            desc_lines: list[str] = []
            body_lines: list[str] = []
            trailing_blanks: list[str] = []

            # Collect all consecutive --@api-stub: lines
            while i < n and lines[i].strip().startswith("--@api-stub:"):
                stubs.append(lines[i].strip()[len("--@api-stub:"):].strip())
                i += 1

            # Collect description / comment lines before `do`
            while i < n and lines[i].strip().startswith("--") and not lines[i].strip().startswith("--@"):
                desc_lines.append(lines[i])
                i += 1

            # Expect `do` line
            if i < n and re.match(r'^\s*do\s*(?:--.*)?$', lines[i].strip()):
                i += 1  # skip `do`
                depth = 1
                while i < n and depth > 0:
                    bl = lines[i]
                    s = bl.strip()
                    opens = sum([
                        1 if re.match(r'^do(?:\s*--.*)?$', s) else 0,
                        1 if re.match(r'^(?:local\s+)?function\b', s) else 0,
                        1 if re.match(r'^if\b.*\bthen(?:\s*--.*)?$', s) and not s.startswith('elseif') else 0,
                        1 if re.match(r'^for\b.*\bdo(?:\s*--.*)?$', s) else 0,
                        1 if re.match(r'^while\b.*\bdo(?:\s*--.*)?$', s) else 0,
                        1 if re.match(r'^repeat(?:\s*--.*)?$', s) else 0,
                    ])
                    closes = sum([
                        1 if re.match(r'^end(?:\s*--.*)?$', s) else 0,
                        1 if re.match(r'^until\b', s) else 0,
                    ])
                    depth += opens - closes
                    if depth <= 0:
                        i += 1
                        break
                    body_lines.append(bl)
                    i += 1

                # Collect trailing blank lines
                while i < n and lines[i].strip() == "":
                    trailing_blanks.append(lines[i])
                    i += 1

                result.append(Block(stubs, desc_lines, body_lines, trailing_blanks))
            else:
                # No `do` block — emit stubs and desc as raw lines
                for s in stubs:
                    result.append(f"--@api-stub: {s}\n")
                for d in desc_lines:
                    result.append(d)
        else:
            result.append(raw)
            i += 1

    return result


def collapse(items: list) -> tuple[list, int]:
    """Merge consecutive Blocks that have identical bodies into stacked markers.

    Returns (new_items, count_collapsed).
    """
    out: list = []
    collapsed = 0
    i = 0
    n = len(items)

    while i < n:
        item = items[i]
        if not isinstance(item, Block):
            out.append(item)
            i += 1
            continue

        # Try to merge with subsequent blocks that have same body and desc
        run: list[Block] = [item]
        j = i + 1
        while j < n:
            candidate = items[j]
            if not isinstance(candidate, Block):
                break
            # Must have same body and same description
            if (_body_key(candidate.body_lines) == _body_key(run[0].body_lines)
                    and "".join(candidate.desc_lines).strip() == "".join(run[0].desc_lines).strip()):
                run.append(candidate)
                j += 1
            else:
                break

        if len(run) > 1:
            # Merge: stack all stub markers, use one body
            merged_stubs = []
            for blk in run:
                merged_stubs.extend(blk.stubs)
            merged = Block(
                stubs=merged_stubs,
                desc_lines=run[0].desc_lines,
                body_lines=run[0].body_lines,
                trailing_blanks=run[-1].trailing_blanks,
            )
            out.append(merged)
            collapsed += len(run) - 1
        else:
            out.append(item)

        i = j

    return out, collapsed


def render(items: list) -> str:
    parts: list[str] = []
    for item in items:
        if isinstance(item, Block):
            for s in item.stubs:
                parts.append(f"--@api-stub: {s}\n")
            for d in item.desc_lines:
                parts.append(d if d.endswith("\n") else d + "\n")
            parts.append("do\n")
            for bl in item.body_lines:
                parts.append(bl if bl.endswith("\n") else bl + "\n")
            parts.append("end\n")
            for t in item.trailing_blanks:
                parts.append(t if t.endswith("\n") else t + "\n")
        else:
            parts.append(item if item.endswith("\n") else item + "\n")
    return "".join(parts)


def process_file(path: Path, dry_run: bool) -> int:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    items = parse_blocks(lines)
    items, count = collapse(items)

    if count:
        result = render(items)
        if not dry_run:
            path.write_text(result, encoding="utf-8")
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--file", metavar="NAME", help="Only process this filename")
    args = parser.parse_args()

    files = sorted(EXAMPLES2.glob("*.lua"))
    if args.file:
        files = [f for f in files if f.name == args.file]

    total = 0
    for f in files:
        count = process_file(f, args.dry_run)
        if count:
            label = "[DRY] " if args.dry_run else ""
            print(f"{label}{f.name}: collapsed={count}")
        total += count

    print(f"\nTotal blocks collapsed: {total} ({'DRY RUN' if args.dry_run else 'WRITTEN'})")


if __name__ == "__main__":
    main()
