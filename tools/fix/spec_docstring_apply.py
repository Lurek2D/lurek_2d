#!/usr/bin/env python3
"""
spec_docstring_apply.py -- Apply Source Documentation from specs to Rust //! docstrings.

Reads each docs/specs/<module>.md, extracts the "## Source Documentation" section,
maps each ### filename.rs entry to src/<module>/filename.rs, and replaces the
leading //! block with the human-written bullet descriptions from the spec.

This is NOT a generator -- it only applies content written by humans in specs.
If a file in the spec has only 1 bullet and the file is large, the script will
warn but still apply whatever the spec has.  Thin specs need human expansion first.

Usage:
    python tools/fix/spec_docstring_apply.py               # apply all
    python tools/fix/spec_docstring_apply.py --dry-run     # show diffs, no write
    python tools/fix/spec_docstring_apply.py --module agent  # one module only
    python tools/fix/spec_docstring_apply.py --check-thin  # report modules with thin specs
    python tools/fix/spec_docstring_apply.py --skip-thin N # skip files where spec has < N bullets

Exit codes: 0 OK, 1 some skipped/thin, 2 fatal error
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
SPECS_DIR = ROOT / "docs" / "specs"
SRC_DIR   = ROOT / "src"

LOC_TIERS: list[tuple[float, int]] = [
    (30,         1),
    (80,         3),
    (200,        4),
    (400,        5),
    (800,        6),
    (2000,       8),
    (float("inf"), 10),
]


def min_doc_lines(loc: int) -> int:
    for max_loc, minimum in LOC_TIERS:
        if loc <= max_loc:
            return minimum
    return 10


# ---------------------------------------------------------------------------
# Spec parsing
# ---------------------------------------------------------------------------

def parse_source_docs(spec_path: Path) -> dict[str, list[str]]:
    """
    Returns {filename: [bullet_text, ...]} from the '## Source Documentation' section.
    bullet_text strips the leading '- ' prefix.
    """
    text = spec_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    in_section = False
    current_file: str | None = None
    result: dict[str, list[str]] = {}

    for line in lines:
        if re.match(r"^## Source Documentation\s*$", line):
            in_section = True
            continue
        if in_section and re.match(r"^## ", line):
            break  # next section
        if not in_section:
            continue

        m = re.match(r"^### `([^`]+)`\s*$", line)
        if m:
            current_file = m.group(1)
            result[current_file] = []
            continue

        if current_file and re.match(r"^- ", line):
            result[current_file].append(line[2:].strip())

    return result


# ---------------------------------------------------------------------------
# Rust file helpers
# ---------------------------------------------------------------------------

def read_leading_doc(lines: list[str]) -> tuple[list[str], int]:
    """
    Returns (doc_lines, end_idx) where end_idx is the first line after the //! block.
    doc_lines includes the '//!' prefix strings.
    """
    doc: list[str] = []
    i = 0
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped.startswith("//!"):
            doc.append(stripped)
        else:
            return doc, i
    return doc, len(lines)


def build_docstring(bullets: list[str]) -> list[str]:
    """
    Convert a list of bullet strings into //! lines.

    For a single bullet: just one //! line (summary).
    For multiple:  first bullet becomes the summary line, rest become //!
    bullet items separated by a blank //! line.
    """
    if not bullets:
        return []

    result: list[str] = []
    # First bullet = summary (no leading dash)
    result.append(f"//! {bullets[0]}")

    if len(bullets) > 1:
        result.append("//!")
        for b in bullets[1:]:
            result.append(f"//! - {b}")

    return result


def apply_docstring(rs_path: Path, bullets: list[str], dry_run: bool) -> str:
    """
    Replace the leading //! block in rs_path with content from bullets.
    Returns 'applied', 'unchanged', or 'skipped:<reason>'.
    """
    old_text = rs_path.read_text(encoding="utf-8")
    lines = old_text.splitlines(keepends=True)

    old_doc, end_idx = read_leading_doc([l.rstrip("\n") for l in lines])
    new_doc_lines = build_docstring(bullets)

    if not new_doc_lines:
        return "skipped:empty_spec"

    # Compare normalised (strip trailing whitespace)
    old_normalised = [l.rstrip() for l in old_doc]
    new_normalised  = new_doc_lines  # already clean

    if old_normalised == new_normalised:
        return "unchanged"

    # Build new file content
    suffix = lines[end_idx:]
    new_content = (
        "\n".join(new_doc_lines)
        + ("\n" if suffix else "")
        + "".join(suffix)
    )

    # Warn if LOC requirement not met
    loc = len(lines)
    needed = min_doc_lines(loc)
    actual = len(new_doc_lines)
    if actual < needed:
        print(f"  WARN {rs_path.relative_to(ROOT)}: spec has {actual} lines, needs {needed} for {loc} LOC")

    if not dry_run:
        rs_path.write_text(new_content, encoding="utf-8")

    return "applied"


# ---------------------------------------------------------------------------
# Module → src path mapping
# ---------------------------------------------------------------------------

def spec_to_src_dir(spec_path: Path) -> Path | None:
    """Map docs/specs/<module>.md to src/<module>/."""
    module = spec_path.stem
    candidate = SRC_DIR / module
    if candidate.is_dir():
        return candidate
    # Some specs cover lua_api files — handled separately per file below
    return None


def find_rs_file(module_dir: Path, filename: str) -> Path | None:
    """Find filename.rs inside module_dir (direct child only)."""
    candidate = module_dir / filename
    if candidate.exists():
        return candidate
    return None


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dry-run", action="store_true", help="Show what would change, no writes")
    ap.add_argument("--module", metavar="NAME", help="Process only this module (spec stem)")
    ap.add_argument("--check-thin", action="store_true", help="Report modules with avg < 2 bullets/file")
    ap.add_argument("--skip-thin", type=int, default=0, metavar="N",
                    help="Skip files where the spec section has fewer than N bullets")
    args = ap.parse_args()

    specs = sorted(SPECS_DIR.glob("*.md"))
    if args.module:
        specs = [s for s in specs if s.stem == args.module]
        if not specs:
            print(f"ERROR: no spec found for module '{args.module}'", file=sys.stderr)
            return 2

    if args.check_thin:
        print("Modules with avg < 3 bullets per file:")
        for spec in specs:
            src_docs = parse_source_docs(spec)
            if not src_docs:
                continue
            total = sum(len(v) for v in src_docs.values())
            avg = total / len(src_docs)
            if avg < 3:
                print(f"  {spec.name}: {len(src_docs)} files, avg {avg:.1f} bullets")
        return 0

    applied = unchanged = skipped = warned = 0

    for spec in specs:
        src_docs = parse_source_docs(spec)
        if not src_docs:
            continue

        src_dir = spec_to_src_dir(spec)
        if src_dir is None:
            continue

        for filename, bullets in src_docs.items():
            if args.skip_thin and len(bullets) < args.skip_thin:
                skipped += 1
                continue

            rs_path = find_rs_file(src_dir, filename)
            if rs_path is None:
                # Try lua_api path (some specs document *_api.rs)
                api_path = SRC_DIR / "lua_api" / filename
                if api_path.exists():
                    rs_path = api_path
                else:
                    continue

            result = apply_docstring(rs_path, bullets, args.dry_run)
            rel = rs_path.relative_to(ROOT)

            if result == "applied":
                applied += 1
                if args.dry_run:
                    print(f"  WOULD APPLY  {rel}")
                    if len(bullets) <= 6:
                        for b in bullets:
                            print(f"    //! {b}")
                else:
                    print(f"  applied      {rel}")
            elif result == "unchanged":
                unchanged += 1
            elif result.startswith("skipped"):
                skipped += 1
                print(f"  skipped ({result[8:]})  {rel}")
            if "WARN" in result:
                warned += 1

    label = "DRY RUN" if args.dry_run else "DONE"
    print(f"\n[{label}] applied={applied}  unchanged={unchanged}  skipped={skipped}  warned={warned}")
    return 1 if warned else 0


if __name__ == "__main__":
    sys.exit(main())
