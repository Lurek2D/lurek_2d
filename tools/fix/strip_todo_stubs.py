#!/usr/bin/env python3
"""Strip TODO stub blocks added by example_add_missing.py from examples2 files.

Removes blocks matching the pattern:
  --
  -- ---- Stub: <name> ...
  --@api-stub: <name>
  -- <description>
  -- TODO: replace this stub ...
  <lua call>
  -- (replace ...)
  --

Usage:
    python tools/fix/strip_todo_stubs.py [--dry-run]
"""
from __future__ import annotations
import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXAMPLES2 = ROOT / "content" / "examples2"

# The separator pattern used by example_add_missing.py
SEP_RE = re.compile(r'^--\s*-{4,}\s*Stub:')


def strip_todo_stubs(text: str) -> tuple[str, int]:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    removed = 0
    i = 0
    n = len(lines)

    while i < n:
        stripped = lines[i].rstrip()

        # Detect start of a TODO stub block: separator line OR --@api-stub: followed by TODO
        if SEP_RE.match(stripped):
            # Consume the whole stub block:
            # -- ---- Stub: name ---...
            # (optional blank)
            # --@api-stub: name
            # -- description
            # -- TODO: ...
            # <call line>
            # -- (replace ...)
            # (blank)
            block_start = i
            # Skip until we hit a blank line or next separator or end of TODO marker
            found_todo = False
            j = i
            while j < n:
                sl = lines[j].rstrip()
                if '-- TODO:' in sl:
                    found_todo = True
                # End of block: blank line after the call/replace comment
                if j > block_start and sl == '' and found_todo:
                    j += 1
                    break
                # Next real block starts
                if j > block_start + 1 and (SEP_RE.match(sl) or (sl.startswith('--@api-stub:') and j > block_start + 2)):
                    break
                j += 1

            if found_todo:
                removed += 1
                i = j
                continue
            # Not a TODO stub — keep
            out.append(lines[i])
            i += 1
            continue

        out.append(lines[i])
        i += 1

    # Strip trailing blank lines that may have accumulated
    result = "".join(out).rstrip() + "\n"
    return result, removed


def process_file(path: Path, dry_run: bool) -> int:
    text = path.read_text(encoding="utf-8")
    result, count = strip_todo_stubs(text)
    if count and not dry_run:
        path.write_text(result, encoding="utf-8")
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    total = 0
    for f in sorted(EXAMPLES2.glob("*.lua")):
        count = process_file(f, args.dry_run)
        if count:
            label = "[DRY] " if args.dry_run else ""
            print(f"{label}{f.name}: removed={count}")
        total += count

    print(f"\nTotal TODO stubs removed: {total} ({'DRY RUN' if args.dry_run else 'WRITTEN'})")


if __name__ == "__main__":
    main()
