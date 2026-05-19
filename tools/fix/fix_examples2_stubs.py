#!/usr/bin/env python3
"""Fix --@api-stub: markers in content/examples2/*.lua files.

Problem 1 (inline format): `do --@api-stub: X` — the coverage tool
  checks `stripped.startswith('--@api-stub:')` which is False when
  the line starts with `do`. The marker is never registered.
  Fix: move the marker to its own line before `do`.

Problem 2 (slash format): `--@api-stub: X / Y / Z` — the whole
  string becomes the dict key, never matching any single API name.
  Fix: split into N separate full do...end blocks, one per API,
  each containing the same body code.

Usage:
    python tools/fix/fix_examples2_stubs.py [--dry-run]
"""
from __future__ import annotations
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXAMPLES2 = ROOT / "content" / "examples2"

SLASH_STUB_RE = re.compile(r"^(--@api-stub:)\s*(.+)$")


def fix_inline_format(lines: list[str]) -> tuple[list[str], int]:
    """Fix `do --@api-stub: X` → separate marker + do lines.

    Returns (new_lines, count_fixed).
    """
    out: list[str] = []
    fixed = 0
    for ln in lines:
        stripped = ln.rstrip("\n\r")
        # Match: `do --@api-stub: <marker>` with optional leading whitespace
        m = re.match(r'^(\s*)do\s+(--@api-stub:\s*.+)$', stripped)
        if m:
            indent = m.group(1)
            marker = m.group(2)
            # Emit the marker line (no indent — top-level), then plain `do`
            out.append(marker + "\n")
            out.append(indent + "do\n")
            fixed += 1
        else:
            out.append(ln if ln.endswith("\n") else ln + "\n")
    return out, fixed


def fix_slash_format(lines: list[str]) -> tuple[list[str], int]:
    """Fix `--@api-stub: X / Y / Z` → N separate do...end blocks.

    For each slash-separated stub, the SAME body block is repeated.
    Returns (new_lines, count_fixed).
    """
    out: list[str] = []
    fixed = 0
    i = 0
    while i < len(lines):
        ln = lines[i].rstrip("\n\r")
        m = SLASH_STUB_RE.match(ln.lstrip())
        if m:
            raw_ids = m.group(2)
            raw_parts = [p.strip() for p in raw_ids.split("/")]
            # Propagate class prefix: "LFoo:addItem / getItem" → "LFoo:addItem / LFoo:getItem"
            # Detect prefix as everything up to and including the last ":" or "."
            prefix = ""
            m2 = re.match(r'^((?:\w+[:.]))', raw_parts[0])
            if m2:
                prefix = m2.group(1)
            parts = []
            for p in raw_parts:
                if ":" not in p and "." not in p and prefix:
                    parts.append(prefix + p)
                else:
                    parts.append(p)
                    # Update prefix from this part if it has a qualifier
                    m3 = re.match(r'^((?:\w+[:.]))', p)
                    if m3:
                        prefix = m3.group(1)
            if len(parts) <= 1:
                # Not a slash list — keep as-is
                out.append(lines[i] if lines[i].endswith("\n") else lines[i] + "\n")
                i += 1
                continue

            # Consume the description line (optional -- comment after marker)
            desc_line: str | None = None
            j = i + 1
            if j < len(lines) and lines[j].lstrip().startswith("--") and not lines[j].lstrip().startswith("--@"):
                desc_line = lines[j].rstrip("\n\r")
                j += 1

            # Consume the do...end block
            body_lines: list[str] = []
            if j < len(lines) and lines[j].rstrip() in ("do", "do\r"):
                j += 1  # skip the `do` line itself
                depth = 1
                while j < len(lines) and depth > 0:
                    bl = lines[j].rstrip("\n\r")
                    stripped_bl = bl.strip()
                    # Track depth
                    opens = sum([
                        1 if re.match(r'^do(?:\s*--.*)?$', stripped_bl) else 0,
                        1 if re.match(r'^(?:local\s+)?function\b', stripped_bl) else 0,
                        1 if re.match(r'^if\b.*\bthen(?:\s*--.*)?$', stripped_bl) and not stripped_bl.startswith('elseif') else 0,
                        1 if re.match(r'^for\b.*\bdo(?:\s*--.*)?$', stripped_bl) else 0,
                        1 if re.match(r'^while\b.*\bdo(?:\s*--.*)?$', stripped_bl) else 0,
                        1 if re.match(r'^repeat(?:\s*--.*)?$', stripped_bl) else 0,
                    ])
                    closes = sum([
                        1 if re.match(r'^end(?:\s*--.*)?$', stripped_bl) else 0,
                        1 if re.match(r'^until\b', stripped_bl) else 0,
                    ])
                    depth += opens - closes
                    if depth <= 0:
                        j += 1
                        break
                    body_lines.append(lines[j])
                    j += 1
            else:
                # No `do` block found — keep original and continue
                out.append(lines[i] if lines[i].endswith("\n") else lines[i] + "\n")
                i += 1
                continue

            # Emit one full do...end block per API id
            for k, api_id in enumerate(parts):
                out.append(f"--@api-stub: {api_id}\n")
                if desc_line:
                    out.append(desc_line + "\n")
                out.append("do\n")
                out.extend(body_lines)
                out.append("end\n")
                if k < len(parts) - 1:
                    out.append("\n")

            fixed += len(parts) - 1  # original 1 became N
            i = j
            continue

        out.append(lines[i] if lines[i].endswith("\n") else lines[i] + "\n")
        i += 1

    return out, fixed


def fix_file(path: Path, dry_run: bool) -> tuple[int, int]:
    """Fix one file. Returns (inline_fixed, slash_fixed)."""
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    lines, inline_count = fix_inline_format(lines)
    lines, slash_count = fix_slash_format(lines)

    if inline_count or slash_count:
        result = "".join(lines)
        if not dry_run:
            path.write_text(result, encoding="utf-8")
    return inline_count, slash_count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true",
                        help="Report changes without writing files")
    parser.add_argument("--file", metavar="NAME",
                        help="Only process this filename (e.g. ui_04.lua)")
    args = parser.parse_args()

    files = sorted(EXAMPLES2.glob("*.lua"))
    if args.file:
        files = [f for f in files if f.name == args.file]

    total_inline = 0
    total_slash = 0
    for f in files:
        inline, slash = fix_file(f, args.dry_run)
        if inline or slash:
            label = "[DRY] " if args.dry_run else ""
            print(f"{label}{f.name}: inline_fixed={inline} slash_expanded={slash}")
        total_inline += inline
        total_slash += slash

    print(f"\nTotal: inline_fixed={total_inline} slash_expanded={total_slash} "
          f"({'DRY RUN' if args.dry_run else 'WRITTEN'})")


if __name__ == "__main__":
    main()
