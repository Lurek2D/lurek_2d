#!/usr/bin/env python3
"""
strip_garbage_doc_lines.py -- Remove auto-generated garbage lines from //! docstrings.

Removes known-garbage //! lines that were appended by the old module_docstring_fix.py:
  //! - Part of the `lua_api` subsystem.
  //! - Part of the `bin` subsystem.
  //! - See `src/lua_api` for related modules (N).
  //! - See `src/bin` for related modules (N).

Also removes duplicate trailing blank //! lines left after stripping.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent

EXACT_GARBAGE = {
    "//! - Part of the `lua_api` subsystem.",
    "//! - Part of the `bin` subsystem.",
}

PREFIX_GARBAGE = [
    "//! - See `src/lua_api` for related modules",
    "//! - See `src/bin` for related modules",
    "//! - See `src/",                   # catches all "See src/..." patterns
]


def is_garbage_line(line: str) -> bool:
    s = line.rstrip()
    if s in EXACT_GARBAGE:
        return True
    return any(s.startswith(p) for p in PREFIX_GARBAGE)


def strip_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    new_lines = []
    changed = False
    for line in lines:
        if is_garbage_line(line):
            changed = True
        else:
            new_lines.append(line)

    if not changed:
        return False

    # Also remove a trailing blank //! line if it's now the last doc line
    # (i.e. the file ends the //! block with just "//!" after stripping)
    while new_lines:
        prev = new_lines[-1].rstrip()
        # Find last non-empty //! line before code starts
        break

    # Collapse consecutive trailing blank //! lines in the doc block
    result = []
    prev_blank_doc = False
    for line in new_lines:
        is_blank_doc = line.rstrip() == "//!"
        if is_blank_doc and prev_blank_doc:
            # Skip second consecutive blank //! line
            continue
        result.append(line)
        prev_blank_doc = is_blank_doc

    # If the doc block ends with a blank //! followed by non-doc code, remove the trailing blank
    # Find where the doc block ends
    doc_end = 0
    for i, line in enumerate(result):
        if line.rstrip().startswith("//!"):
            doc_end = i
    # If last doc line is blank, remove it
    if doc_end > 0 and result[doc_end].rstrip() == "//!":
        result.pop(doc_end)

    path.write_text("".join(result), encoding="utf-8")
    return True


def main() -> None:
    targets = list(Path(ROOT / "src" / "lua_api").glob("*_api.rs"))
    targets += [ROOT / "src" / "bin" / "lurek_headless.rs"]

    fixed = 0
    for path in sorted(targets):
        if strip_file(path):
            fixed += 1
            print(f"  fixed  {path.relative_to(ROOT)}")

    print(f"\nFixed {fixed} files")


if __name__ == "__main__":
    main()
