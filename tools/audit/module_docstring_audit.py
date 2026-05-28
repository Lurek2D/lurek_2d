#!/usr/bin/env python3
"""
module_docstring_audit.py -- Audit Rust source files for adequate module-level //! docstrings.

For every .rs file under src/, checks that the leading //! block meets a
minimum line count proportional to the file's LOC (total source lines).

LOC tiers and required minimum //! lines:
    1  –   30  →  1  (summary only)
    31 –   80  →  3  (summary + blank + 1 bullet)
    81 –  200  →  4  (summary + blank + 2 bullets)
   201 –  400  →  5  (summary + blank + 3 bullets)
   401 –  800  →  6  (summary + blank + 4 bullets)
   801 – 2000  →  8  (summary + blank + 6 bullets)
  2001+        → 10  (summary + blank + 8 bullets)

Writes:
    logs/data/module_docstring_audit.json  -- machine-readable violations
    stdout                                 -- human-readable summary

Usage:
    python tools/audit/module_docstring_audit.py               # full audit
    python tools/audit/module_docstring_audit.py --src src/render  # scope to dir
    python tools/audit/module_docstring_audit.py --check       # exit 1 on violations
    python tools/audit/module_docstring_audit.py --json        # JSON only to stdout
    python tools/audit/module_docstring_audit.py --summary     # counts only, no file list

Exit codes:
    0  no violations (or default mode without --check)
    1  violations found (--check only)
    2  fatal error
"""

import argparse
import json
import sys
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
SRC_DIR = WORKSPACE_ROOT / "src"
OUTPUT_JSON = WORKSPACE_ROOT / "logs" / "data" / "module_docstring_audit.json"

# LOC tiers: (max_loc_inclusive, min_doc_lines)
LOC_TIERS: list[tuple[float, int]] = [
    (30,        1),
    (80,        3),
    (200,       4),
    (400,       5),
    (800,       6),
    (2000,      8),
    (float("inf"), 10),
]


def min_doc_lines(loc: int) -> int:
    """Return the minimum //! line count required for a file of *loc* total lines."""
    for max_loc, minimum in LOC_TIERS:
        if loc <= max_loc:
            return minimum
    return 10  # unreachable but satisfies type checker


def count_leading_doc_lines(lines: list[str]) -> int:
    """Count the contiguous leading //! block at the top of the file.

    Blank lines before the first //! are ignored (e.g. a shebang-free file with
    an empty first line).  Once a non-//! non-blank line is encountered the
    count stops, so scattered //! deeper in the file are not included.
    """
    count = 0
    seen_first = False
    for line in lines:
        stripped = line.rstrip()
        if stripped.startswith("//!"):
            count += 1
            seen_first = True
        elif not seen_first and stripped == "":
            # allow blank lines before the first //! line
            continue
        else:
            # first non-//! line after the block (or before, if no block found)
            break
    return count


def audit_file(path: Path) -> dict | None:
    """Audit one .rs file.  Returns a violation dict or None when OK."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"WARNING: cannot read {path}: {exc}", file=sys.stderr)
        return None

    lines = text.splitlines()
    loc = len(lines)
    if loc == 0:
        return None

    actual = count_leading_doc_lines(lines)
    required = min_doc_lines(loc)

    if actual >= required:
        return None

    return {
        "file": str(path.relative_to(WORKSPACE_ROOT)).replace("\\", "/"),
        "loc": loc,
        "actual_doc_lines": actual,
        "required_doc_lines": required,
        "deficit": required - actual,
    }


def run_audit(src_root: Path) -> list[dict]:
    """Scan all .rs files under *src_root* and return violation records."""
    violations: list[dict] = []
    for rs_path in sorted(src_root.rglob("*.rs")):
        result = audit_file(rs_path)
        if result is not None:
            violations.append(result)
    return violations


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Audit Rust source files for adequate module-level //! docstrings."
    )
    parser.add_argument(
        "--src",
        default=str(SRC_DIR),
        help="Root directory to scan (default: src/)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit with code 1 when violations are found.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_only",
        help="Write JSON to stdout instead of a human-readable report.",
    )
    parser.add_argument(
        "--summary",
        action="store_true",
        help="Print counts only, not the full file list.",
    )
    args = parser.parse_args()

    src_root = Path(args.src).resolve()
    if not src_root.is_dir():
        print(f"ERROR: {src_root} is not a directory", file=sys.stderr)
        return 2

    violations = run_audit(src_root)

    # Sort by severity (deficit desc, then LOC desc)
    violations.sort(key=lambda v: (-v["deficit"], -v["loc"]))

    # Write JSON report
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(json.dumps(violations, indent=2), encoding="utf-8")

    if args.json_only:
        print(json.dumps(violations, indent=2))
        return 1 if (args.check and violations) else 0

    # Human-readable output
    total_rs = sum(1 for _ in src_root.rglob("*.rs"))
    ok_count = total_rs - len(violations)

    if not args.summary:
        if violations:
            print(f"\nModule docstring violations ({len(violations)} files):\n")
            print(f"  {'FILE':<55} {'LOC':>6}  {'ACTUAL':>7}  {'REQUIRED':>9}  {'DEFICIT':>7}")
            print("  " + "-" * 90)
            for v in violations:
                f = v["file"]
                if len(f) > 53:
                    f = "…" + f[-52:]
                print(
                    f"  {f:<55} {v['loc']:>6}  {v['actual_doc_lines']:>7}  "
                    f"{v['required_doc_lines']:>9}  {v['deficit']:>7}"
                )
            print()

    # Summary line
    if violations:
        print(
            f"FAIL  {len(violations)} violation(s) across {total_rs} files "
            f"({ok_count} OK).  "
            f"Report: {OUTPUT_JSON.relative_to(WORKSPACE_ROOT)}"
        )
    else:
        print(f"PASS  All {total_rs} Rust source files meet docstring requirements.")

    if args.check and violations:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
