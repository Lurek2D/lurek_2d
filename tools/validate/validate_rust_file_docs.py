"""validate_rust_file_docs.py — Check that every Rust source file in src/
(excluding src/lua_api/) has a multi-line //! file-level doc comment with at
least 2 bullet lines (//! - ...).

Usage:
    python tools/validate/validate_rust_file_docs.py           # all files
    python tools/validate/validate_rust_file_docs.py --errors-only
    python tools/validate/validate_rust_file_docs.py src/foo/bar.rs
Exit code 0 = all pass, 1 = failures found.
"""

from __future__ import annotations
import argparse
import sys
from pathlib import Path


def check_file(path: Path) -> list[str]:
    """Return list of failure messages for *path*, or empty list if OK."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        return [f"{path}: cannot read — {e}"]

    lines = text.splitlines()
    doc_lines = [l for l in lines if l.startswith("//!")]
    bullet_lines = [l for l in doc_lines if l.startswith("//! -")]

    failures: list[str] = []
    if len(doc_lines) < 2:
        failures.append(
            f"{path}: only {len(doc_lines)} //! line(s) — need at least 2 "
            f"(multi-line block with bullet points)"
        )
    elif len(bullet_lines) < 2:
        failures.append(
            f"{path}: has {len(doc_lines)} //! line(s) but only "
            f"{len(bullet_lines)} '//! -' bullet line(s) — need at least 2"
        )
    return failures


def collect_targets(roots: list[Path]) -> list[Path]:
    """Collect all .rs files under *roots*, skipping lua_api."""
    result: list[Path] = []
    for root in roots:
        if root.is_file():
            if "lua_api" not in root.parts:
                result.append(root)
        else:
            for f in sorted(root.rglob("*.rs")):
                if "lua_api" not in f.parts:
                    result.append(f)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "paths",
        nargs="*",
        default=["src"],
        help="Files or directories to check (default: src/)",
    )
    parser.add_argument(
        "--errors-only",
        action="store_true",
        help="Only print failures, not the OK summary.",
    )
    args = parser.parse_args()

    targets = collect_targets([Path(p) for p in args.paths])
    all_failures: list[str] = []

    for t in targets:
        all_failures.extend(check_file(t))

    if all_failures:
        for msg in sorted(all_failures):
            print(f"[FAIL] {msg}")
        print(f"\n{len(all_failures)} file(s) need a multi-line //! doc block.")
        return 1

    if not args.errors_only:
        print(
            f"[OK] All {len(targets)} Rust files (excl. lua_api) have "
            f"multi-line //! doc blocks."
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
