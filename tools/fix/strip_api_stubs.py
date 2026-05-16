"""Strip --@api-stub: lines and their trailing comment preambles from example files.

Keeps the real `do -- <name> ... end` blocks intact.

Logic per line:
- If line starts with `--@api-stub:`, enter "skip" mode.
- In skip mode, also skip subsequent lines that are pure comments (start with `--`)
  or blank lines, UNLESS the comment is a section separator (-- ==, -- ──)
  that we also want to keep.
- Stop skipping when we hit a non-comment, non-blank line (the `do` block).
- Special: lines like `-- do  --` (commented-out do blocks) are also skipped.
"""

import re
import sys
from pathlib import Path


def strip_stubs(filepath: Path) -> int:
    lines = filepath.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    stubs_removed = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Detect stub marker
        if stripped.startswith("--@api-stub:"):
            stubs_removed += 1
            i += 1
            # Skip trailing comment lines (description, signature, instructions)
            while i < len(lines):
                next_stripped = lines[i].strip()
                # Stop at non-comment, non-blank lines (the `do` block)
                if not next_stripped.startswith("--") and next_stripped != "":
                    break
                # Also stop at section separators we want to keep
                # like "-- == ..." or "-- ── ..."
                if (next_stripped.startswith("-- ==") or
                    next_stripped.startswith("-- \u2500") or
                    next_stripped.startswith("-- \u2550")):
                    break
                # Skip this comment/blank line
                i += 1
            continue
        else:
            out.append(line)
            i += 1

    filepath.write_text("".join(out), encoding="utf-8")
    return stubs_removed


def main():
    root = Path(__file__).resolve().parents[2]
    files = [
        root / "content" / "examples" / "pathfind.lua",
        root / "content" / "examples" / "dataframe.lua",
        root / "content" / "examples" / "camera.lua",
    ]

    for f in files:
        if not f.exists():
            print(f"ERROR: {f} not found")
            sys.exit(1)
        count = strip_stubs(f)
        print(f"{f.name}: removed {count} stub markers")

    print("\nDone.")


if __name__ == "__main__":
    main()
