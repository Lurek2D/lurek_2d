"""Remove all leading //! doc-comment lines from every .rs file under src/,
skipping src/lua_api/ entirely."""

import pathlib, re

SRC = pathlib.Path(__file__).parents[2] / "src"
SKIP = SRC / "lua_api"

changed = 0
for path in SRC.rglob("*.rs"):
    if path.is_relative_to(SKIP):
        continue
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    # Strip leading block of //! lines (file-level docstring at top)
    i = 0
    while i < len(lines) and lines[i].lstrip().startswith("//!"):
        i += 1
    # Also eat one blank line right after the block if present
    if i < len(lines) and lines[i].strip() == "":
        i += 1
    if i == 0:
        continue
    new_text = "".join(lines[i:])
    path.write_text(new_text, encoding="utf-8")
    print(f"  stripped {i} line(s): {path.relative_to(SRC.parent)}")
    changed += 1

print(f"\nDone — {changed} file(s) updated.")
