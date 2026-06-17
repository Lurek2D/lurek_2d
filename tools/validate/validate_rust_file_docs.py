"""Validate Rust file-level //! docs with the repository docstring coverage policy."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIT_DIR = ROOT / "tools" / "audit"
if str(AUDIT_DIR) not in sys.path:
    sys.path.insert(0, str(AUDIT_DIR))

from module_docstring_audit import (  # noqa: E402
    MAX_DOC_BODY_CHARS,
    MIN_DOC_BODY_CHARS,
    render_text,
    run_audit,
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="*", default=["src"], help="Rust files or directories to validate.")
    parser.add_argument("--errors-only", action="store_true", help="Suppress passing summary details.")
    parser.add_argument(
        "--min-doc-body-chars",
        type=int,
        default=MIN_DOC_BODY_CHARS,
        help="Minimum nonblank characters required after each //! prefix.",
    )
    parser.add_argument(
        "--max-doc-body-chars",
        type=int,
        default=MAX_DOC_BODY_CHARS,
        help="Maximum nonblank characters allowed after each //! prefix.",
    )
    args = parser.parse_args()

    if args.min_doc_body_chars > args.max_doc_body_chars:
        print("ERROR: --min-doc-body-chars cannot be greater than --max-doc-body-chars", file=sys.stderr)
        return 2

    reports = [
        run_audit(
            (ROOT / path).resolve() if not Path(path).is_absolute() else Path(path),
            args.min_doc_body_chars,
            args.max_doc_body_chars,
        )
        for path in args.paths
    ]
    merged_files = [item for report in reports for item in report["files"]]
    violations = [item for item in merged_files if not item["ok"]]
    total = len(merged_files)
    passing = total - len(violations)
    coverage = round((passing / total) * 100, 2) if total else 100.0
    report = {
        "summary": {
            "total_files": total,
            "passing_files": passing,
            "violating_files": len(violations),
            "coverage_pct": coverage,
        },
        "violations": violations,
    }

    if violations or not args.errors_only:
        print(render_text(report, summary_only=args.errors_only and not violations))
    return 1 if violations else 0


if __name__ == "__main__":
    raise SystemExit(main())
