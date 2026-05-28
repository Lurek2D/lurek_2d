#!/usr/bin/env python3
"""Generate Rust HTML documentation and publish it to pages/rust-docs/.

Runs `cargo doc --no-deps` (or a custom command via --cargo-args), then copies
the full build/doc/ tree into pages/rust-docs/ so GitHub Pages can serve it.

The root of the Rust doc site (build/doc/) contains the shared search index,
static files, and per-crate subdirectories.  The whole tree is copied so that
cross-crate links work correctly.

Usage:
    python tools/docs/gen_rust_html_docs.py
    python tools/docs/gen_rust_html_docs.py --no-deps          # default, skip dependency docs
    python tools/docs/gen_rust_html_docs.py --all-deps         # include dependency docs
    python tools/docs/gen_rust_html_docs.py --dry-run          # print actions, write nothing
    python tools/docs/gen_rust_html_docs.py --skip-cargo       # skip cargo doc, just copy existing build/doc/

Exit codes:
    0 — success
    1 — cargo doc failed or build/doc/ not found
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
SRC_DIR = WORKSPACE_ROOT / "build" / "doc"
DST_DIR = WORKSPACE_ROOT / "pages" / "rust-docs"


def run(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Generate Rust HTML docs into pages/rust-docs/."
    )
    parser.add_argument(
        "--no-deps",
        action="store_true",
        default=True,
        help="Pass --no-deps to cargo doc (default).",
    )
    parser.add_argument(
        "--all-deps",
        action="store_true",
        help="Include dependency docs (overrides --no-deps).",
    )
    parser.add_argument(
        "--skip-cargo",
        action="store_true",
        help="Skip running cargo doc; only copy existing build/doc/ to pages/rust-docs/.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned actions without running cargo or writing files.",
    )
    args = parser.parse_args(argv)

    no_deps = not args.all_deps

    # Step 1: run cargo doc
    if not args.skip_cargo:
        command = ["cargo", "doc"]
        if no_deps:
            command.append("--no-deps")
        print(f"[cargo doc] {' '.join(command)}")
        if not args.dry_run:
            result = subprocess.run(command, cwd=WORKSPACE_ROOT)
            if result.returncode != 0:
                print(f"[cargo doc] FAILED (exit {result.returncode})")
                return 1
            print("[cargo doc] done")
    else:
        print("[cargo doc] skipped (--skip-cargo)")

    # Step 2: copy build/doc/ -> pages/rust-docs/
    print(f"[copy] {SRC_DIR.relative_to(WORKSPACE_ROOT).as_posix()} -> {DST_DIR.relative_to(WORKSPACE_ROOT).as_posix()}")
    if not args.dry_run:
        if not SRC_DIR.exists():
            print(f"[copy] FAILED: {SRC_DIR.relative_to(WORKSPACE_ROOT).as_posix()} not found — run cargo doc first")
            return 1
        if DST_DIR.exists():
            shutil.rmtree(DST_DIR)
        shutil.copytree(SRC_DIR, DST_DIR)
        file_count = sum(1 for _ in DST_DIR.rglob("*") if _.is_file())
        print(f"[OK] pages/rust-docs/ ({file_count} files)")
    else:
        print("[dry-run] would copy build/doc/ -> pages/rust-docs/")

    return 0


if __name__ == "__main__":
    raise SystemExit(run(sys.argv[1:]))
