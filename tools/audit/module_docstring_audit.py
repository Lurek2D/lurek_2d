#!/usr/bin/env python3
"""Audit Rust source files for exact file-level //! documentation coverage."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Any

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
SRC_DIR = WORKSPACE_ROOT / "src"
OUTPUT_JSON = WORKSPACE_ROOT / "logs" / "data" / "module_docstring_audit.json"
OUTPUT_MD = WORKSPACE_ROOT / "logs" / "reports" / "module_docstring_coverage.md"
MIN_DOC_BODY_CHARS = 90
MAX_DOC_BODY_CHARS = 120

# LOC tiers: (max_loc_inclusive, exact_doc_lines)
LOC_TIERS: list[tuple[float, int]] = [
    (49, 3),
    (100, 4),
    (200, 5),
    (300, 6),
    (450, 7),
    (600, 8),
    (800, 9),
    (1000, 10),
    (1250, 11),
    (1500, 12),
    (2000, 13),
    (3000, 14),
    (float("inf"), 15),
]


@dataclass(frozen=True)
class DocLine:
    """One leading //! line with its source location and body text."""

    line_number: int
    text: str

    @property
    def body(self) -> str:
        raw = self.text[3:]
        if raw.startswith(" "):
            raw = raw[1:]
        return raw

    @property
    def body_len(self) -> int:
        return len(self.body.strip())


def _repo_rel(path: Path) -> str:
    return str(path.relative_to(WORKSPACE_ROOT)).replace("\\", "/")


def is_lua_api_file(path: Path) -> bool:
    """Return True for Rust files under src/lua_api, including src/lua_api/mod.rs."""

    try:
        rel_parts = path.relative_to(WORKSPACE_ROOT).parts
    except ValueError:
        rel_parts = path.parts
    return len(rel_parts) >= 3 and rel_parts[0] == "src" and rel_parts[1] == "lua_api"


def base_doc_lines_for_loc(loc: int) -> int:
    """Return the base exact //! line count required for a file of this LOC size."""

    for max_loc, required in LOC_TIERS:
        if loc <= max_loc:
            return required
    return LOC_TIERS[-1][1]


def required_doc_lines(path: Path, loc: int) -> int:
    """Return the exact leading //! line count required by repository policy."""

    if is_lua_api_file(path):
        return 1
    required = base_doc_lines_for_loc(loc)
    if path.name == "mod.rs":
        required *= 2
    return required


def collect_leading_doc_lines(lines: list[str]) -> list[DocLine]:
    """Collect the contiguous leading //! block, ignoring only blank lines before it starts."""

    docs: list[DocLine] = []
    seen_doc = False
    for index, line in enumerate(lines, start=1):
        stripped = line.rstrip()
        if stripped.startswith("//!"):
            docs.append(DocLine(index, stripped))
            seen_doc = True
        elif not seen_doc and stripped == "":
            continue
        else:
            break
    return docs


def rewrite_instruction(path: Path, required: int, min_chars: int, max_chars: int) -> str:
    """Build a concrete repair instruction for the report."""

    if is_lua_api_file(path):
        return (
            f"Rewrite the leading //! block to exactly 1 line between {min_chars} and {max_chars} characters; "
            "summarize lurek.* registration, validation, conversions, and exposed userdata or callbacks."
        )
    if path.name == "mod.rs":
        return (
            f"Rewrite the leading //! block to exactly {required} lines between {min_chars} and {max_chars} characters each; "
            "describe the index role, exported submodules, reexports, and navigation value for agents."
        )
    return (
        f"Rewrite the leading //! block to exactly {required} lines between {min_chars} and {max_chars} characters each; "
        "describe file ownership, delivered behavior, local data, public helpers, and subsystem boundaries."
    )


def audit_file(path: Path, min_chars: int, max_chars: int) -> dict[str, Any]:
    """Audit one Rust source file and return its full coverage record."""

    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        rel = str(path)
        return {
            "file": rel,
            "loc": 0,
            "required_doc_lines": 0,
            "actual_doc_lines": 0,
            "short_doc_lines": [],
            "long_doc_lines": [],
            "out_of_range_doc_lines": [],
            "shortest_doc_body_chars": 0,
            "longest_doc_body_chars": 0,
            "issues": [{"code": "read_error", "message": f"cannot read file: {exc}"}],
            "ok": False,
            "rewrite_instruction": "Fix file read permissions before auditing file-level Rust docs.",
        }

    lines = text.splitlines()
    loc = len(lines)
    docs = collect_leading_doc_lines(lines)
    required = required_doc_lines(path, loc)
    issues: list[dict[str, Any]] = []
    short_doc_lines: list[dict[str, int]] = []
    long_doc_lines: list[dict[str, int]] = []

    if not docs:
        issues.append(
            {
                "code": "missing_header",
                "message": "missing contiguous leading //! file-level doc block before the first code item",
            }
        )

    if len(docs) != required:
        direction = "too_few" if len(docs) < required else "too_many"
        issues.append(
            {
                "code": direction,
                "message": f"found {len(docs)} leading //! line(s), expected exactly {required}",
            }
        )

    for doc in docs:
        if doc.body_len < min_chars:
            short_doc_lines.append({"line": doc.line_number, "body_chars": doc.body_len})
        elif doc.body_len > max_chars:
            long_doc_lines.append({"line": doc.line_number, "body_chars": doc.body_len})

    if short_doc_lines:
        issues.append(
            {
                "code": "short_line",
                "message": (
                    f"{len(short_doc_lines)} leading //! line(s) have fewer than {min_chars} body characters"
                ),
            }
        )
    if long_doc_lines:
        issues.append(
            {
                "code": "long_line",
                "message": (
                    f"{len(long_doc_lines)} leading //! line(s) have more than {max_chars} body characters"
                ),
            }
        )

    shortest = min((doc.body_len for doc in docs), default=0)
    longest = max((doc.body_len for doc in docs), default=0)
    rel = _repo_rel(path)
    return {
        "file": rel,
        "loc": loc,
        "required_doc_lines": required,
        "actual_doc_lines": len(docs),
        "short_doc_lines": short_doc_lines,
        "long_doc_lines": long_doc_lines,
        "out_of_range_doc_lines": [*short_doc_lines, *long_doc_lines],
        "shortest_doc_body_chars": shortest,
        "longest_doc_body_chars": longest,
        "issues": issues,
        "ok": not issues,
        "rewrite_instruction": rewrite_instruction(path, required, min_chars, max_chars),
    }


def collect_targets(src_root: Path) -> list[Path]:
    """Return all Rust source files under the selected root."""

    if src_root.is_file():
        return [src_root] if src_root.suffix == ".rs" else []
    return sorted(src_root.rglob("*.rs"))


def run_audit(
    src_root: Path,
    min_chars: int = MIN_DOC_BODY_CHARS,
    max_chars: int = MAX_DOC_BODY_CHARS,
) -> dict[str, Any]:
    """Scan Rust files under src_root and return a complete coverage report."""

    if min_chars > max_chars:
        raise ValueError("min_chars cannot be greater than max_chars")

    targets = collect_targets(src_root)
    files = [audit_file(path, min_chars, max_chars) for path in targets]
    violations = [item for item in files if not item["ok"]]
    files.sort(key=lambda item: item["file"])
    violations.sort(
        key=lambda item: (
            item["ok"],
            -abs(item["required_doc_lines"] - item["actual_doc_lines"]),
            -(len(item["short_doc_lines"]) + len(item["long_doc_lines"])),
            item["shortest_doc_body_chars"],
            -item["longest_doc_body_chars"],
            -item["loc"],
            item["file"],
        )
    )
    total = len(files)
    passing = total - len(violations)
    coverage = round((passing / total) * 100, 2) if total else 100.0
    return {
        "schema": "lurek2d.rust_file_doc_coverage.v3",
        "generated_on": date.today().isoformat(),
        "policy": {
            "prefix": "//!",
            "min_doc_body_chars": min_chars,
            "max_doc_body_chars": max_chars,
            "line_count": "exact LOC tier count",
            "mod_rs_multiplier": 2,
            "lua_api_exact_lines": 1,
            "loc_tiers": [
                {"max_loc": "inf" if max_loc == float("inf") else int(max_loc), "lines": lines}
                for max_loc, lines in LOC_TIERS
            ],
        },
        "summary": {
            "total_files": total,
            "passing_files": passing,
            "violating_files": len(violations),
            "coverage_pct": coverage,
        },
        "violations": violations,
        "files": files,
    }


def render_markdown(report: dict[str, Any]) -> str:
    """Render a full Markdown coverage report for agents and reviewers."""

    summary = report["summary"]
    policy = report["policy"]
    min_chars = policy["min_doc_body_chars"]
    max_chars = policy["max_doc_body_chars"]
    lines = [
        "# Rust File-Level Docstring Coverage",
        "",
        f"_Auto-generated {report['generated_on']} by `tools/audit/module_docstring_audit.py`._",
        "",
        "## Summary",
        "",
        f"- Coverage: **{summary['coverage_pct']}%** ({summary['passing_files']}/{summary['total_files']} files passing)",
        f"- Violations: **{summary['violating_files']}**",
        f"- Required format: leading `//!` block, exact LOC-tier line count, and line lengths in the {min_chars}-{max_chars} range.",
        "- `mod.rs` files require twice the normal LOC-tier line count.",
        "- `src/lua_api/*.rs` files require exactly one file-level line because callable docs live on item docstrings.",
        "",
        "## Violations",
        "",
    ]
    violations = report["violations"]
    if not violations:
        lines.append("All Rust source files satisfy the file-level docstring coverage policy.")
        return "\n".join(lines) + "\n"

    lines.append("| File | LOC | Actual | Required | Short | Long | Shortest | Longest | Action |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |")
    for item in violations:
        action = item["rewrite_instruction"].replace("|", "\\|")
        lines.append(
            f"| `{item['file']}` | {item['loc']} | {item['actual_doc_lines']} | "
            f"{item['required_doc_lines']} | {len(item['short_doc_lines'])} | {len(item['long_doc_lines'])} | "
            f"{item['shortest_doc_body_chars']} | {item['longest_doc_body_chars']} | {action} |"
        )
    return "\n".join(lines) + "\n"


def render_text(report: dict[str, Any], *, summary_only: bool = False) -> str:
    """Render a concise terminal report."""

    summary = report["summary"]
    lines = [
        (
            f"Rust file doc coverage: {summary['coverage_pct']}% "
            f"({summary['passing_files']}/{summary['total_files']} passing, "
            f"{summary['violating_files']} violating)"
        )
    ]
    if summary_only or not report["violations"]:
        if not report["violations"]:
            lines.append(f"PASS  Full report: {OUTPUT_MD.relative_to(WORKSPACE_ROOT)}")
        return "\n".join(lines)

    lines.extend(
        [
            "",
            f"Violations ({len(report['violations'])} files):",
            f"{'FILE':<60} {'LOC':>6} {'ACT':>4} {'REQ':>4} {'SHORT':>5} {'LONG':>5} {'MIN':>4} {'MAX':>4}",
            "-" * 98,
        ]
    )
    for item in report["violations"]:
        file_name = item["file"]
        if len(file_name) > 58:
            file_name = "..." + file_name[-55:]
        lines.append(
            f"{file_name:<60} {item['loc']:>6} {item['actual_doc_lines']:>4} "
            f"{item['required_doc_lines']:>4} {len(item['short_doc_lines']):>5} "
            f"{len(item['long_doc_lines']):>5} {item['shortest_doc_body_chars']:>4} "
            f"{item['longest_doc_body_chars']:>4}"
        )
        lines.append(f"  -> {item['rewrite_instruction']}")
    lines.append("")
    lines.append(f"Full report: {OUTPUT_MD.relative_to(WORKSPACE_ROOT)}")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", default=str(SRC_DIR), help="Rust file or directory to scan (default: src/).")
    parser.add_argument("--check", action="store_true", help="Exit 1 when any violation is found.")
    parser.add_argument("--json", action="store_true", dest="json_only", help="Write JSON report to stdout.")
    parser.add_argument("--summary", action="store_true", help="Print summary only.")
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

    src_root = Path(args.src).resolve()
    if not src_root.exists():
        print(f"ERROR: {src_root} does not exist", file=sys.stderr)
        return 2

    report = run_audit(src_root, args.min_doc_body_chars, args.max_doc_body_chars)
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(json.dumps(report, indent=2), encoding="utf-8")
    OUTPUT_MD.write_text(render_markdown(report), encoding="utf-8")

    if args.json_only:
        print(json.dumps(report, indent=2))
    else:
        print(render_text(report, summary_only=args.summary))

    if args.check and report["summary"]["violating_files"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
