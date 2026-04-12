#!/usr/bin/env python3
"""Audit and normalize Lua BDD test structure under tests/lua.

This tool standardizes the repository rules for Lua test file headers,
suite/case descriptions, and test_summary placement.

Audited rules:
- Every Lua test file must start with a plain prose header comment block.
- Every describe() must have a preceding -- @description line.
- Every describe() docstring block may contain only -- @description.
- Every it() must have a preceding -- @description line.
- Legacy -- @description: syntax is forbidden; use -- @description <text>.
- Legacy -- @category: markers are forbidden.
- test_summary() must appear exactly once and be the last non-empty line.
- return test_summary() is forbidden; use a bare test_summary() call.

Safe auto-fixes provided by --fix:
- Normalize -- @description: -> -- @description
- Remove -- @category: lines
- Remove stray inline UTF-8 BOM characters
- Normalize / dedupe / move test_summary() to the file end

This tool deliberately does NOT auto-generate missing descriptions. Those must
be written by hand.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable, List


ROOT = Path(__file__).resolve().parents[2]
TESTS_ROOT = ROOT / "tests" / "lua"
UTF8_BOM = b"\xef\xbb\xbf"

BLOCK_RE = re.compile(r'^(?P<indent>\s*)(?P<kind>describe|it)\(\s*["\'](?P<label>.*?)["\']\s*,\s*function\s*\(')
DESCRIPTION_RE = re.compile(r'^\s*--\s*@description\b')
DESCRIPTION_COLON_RE = re.compile(r'^(?P<indent>\s*)--\s*@description:\s*(?P<text>.*)$')
CATEGORY_RE = re.compile(r'^\s*--\s*@category:\s*\w+\s*$')
SUMMARY_RE = re.compile(r'^\s*test_summary\(\)\s*$')
RETURN_SUMMARY_RE = re.compile(r'^\s*return\s+test_summary\(\)\s*$')
MARKER_RE = re.compile(r'^\s*--\s*@(?P<name>\w+)\b')


@dataclass
class Finding:
    path: Path
    line: int
    code: str
    message: str

    def as_dict(self) -> dict[str, object]:
        return {
            "path": self.path.as_posix(),
            "line": self.line,
            "code": self.code,
            "message": self.message,
        }


def iter_lua_test_files(path_filter: str | None) -> Iterable[Path]:
    if path_filter:
        target = (ROOT / path_filter).resolve()
        if target.is_file():
            yield target
            return
        if target.is_dir():
            yield from sorted(target.rglob("*.lua"))
            return
        raise FileNotFoundError(path_filter)

    yield from sorted(TESTS_ROOT.rglob("*.lua"))


def has_description_before(lines: List[str], index: int) -> bool:
    cursor = index - 1
    while cursor >= 0:
        line = lines[cursor]
        if not line.strip():
            cursor -= 1
            continue
        if line.lstrip().startswith("--"):
            if DESCRIPTION_RE.search(line):
                return True
            cursor -= 1
            continue
        break
    return False


def get_preceding_markers(lines: List[str], index: int) -> List[tuple[int, str]]:
    markers: List[tuple[int, str]] = []
    cursor = index - 1
    while cursor >= 0:
        line = lines[cursor]
        if not line.strip():
            cursor -= 1
            continue
        if line.lstrip().startswith("--"):
            marker = MARKER_RE.match(line)
            if marker:
                markers.insert(0, (cursor + 1, marker.group("name")))
            cursor -= 1
            continue
        break
    return markers


def has_plain_file_header(lines: List[str]) -> bool:
    cursor = 0
    total = len(lines)

    while cursor < total and not lines[cursor].strip():
        cursor += 1

    if cursor >= total:
        return False

    line = lines[cursor]
    if DESCRIPTION_RE.search(line) or line.lstrip().startswith("-- @"):
        return False

    if line.lstrip().startswith("--"):
        return True

    return False


def audit_file(path: Path, strict_describe_docstrings: bool = True) -> List[Finding]:
    findings: List[Finding] = []
    raw = path.read_bytes()
    lines = raw.decode("utf-8-sig").splitlines()

    if path.name == "init.lua":
        return findings

    if raw.startswith(UTF8_BOM):
        findings.append(Finding(path, 1, "utf8-bom", "Remove the UTF-8 BOM; Lua test files must be plain UTF-8."))

    if any("\ufeff" in line for line in lines):
        first_inline_bom = next(i for i, line in enumerate(lines, start=1) if "\ufeff" in line)
        findings.append(Finding(path, first_inline_bom, "inline-bom", "Remove stray inline UTF-8 BOM characters from the file header or comments."))

    if not has_plain_file_header(lines):
        findings.append(Finding(path, 1, "missing-file-header", "Add a plain prose file-level header comment before any @covers, @description, or test blocks."))

    summary_lines: List[int] = []

    for index, line in enumerate(lines, start=1):
        if CATEGORY_RE.match(line):
            findings.append(Finding(path, index, "legacy-category", "Remove legacy -- @category markers."))

        if DESCRIPTION_COLON_RE.match(line):
            findings.append(Finding(path, index, "legacy-description-colon", "Use '-- @description <text>' without a colon."))

        if SUMMARY_RE.match(line) or RETURN_SUMMARY_RE.match(line):
            summary_lines.append(index)

    for index, line in enumerate(lines):
        block = BLOCK_RE.match(line)
        if not block:
            continue

        kind = block.group("kind")
        label = block.group("label")
        if not has_description_before(lines, index):
            findings.append(
                Finding(
                    path,
                    index + 1,
                    f"missing-{kind}-description",
                    f"Add -- @description directly above {kind}(\"{label}\", ...).",
                )
            )

        if strict_describe_docstrings and kind == "describe":
            markers = get_preceding_markers(lines, index)
            non_description = [(line_no, name) for line_no, name in markers if name != "description"]
            if non_description:
                first_line, _ = non_description[0]
                marker_names = ", ".join(sorted({name for _, name in non_description}))
                findings.append(
                    Finding(
                        path,
                        first_line,
                        "describe-non-description-marker",
                        f"describe() docstrings may only contain @description; move {marker_names} markers to the owning it() block.",
                    )
                )

    if not summary_lines:
        findings.append(Finding(path, len(lines), "missing-test-summary", "Add test_summary() as the last non-empty line."))
    else:
        if len(summary_lines) > 1:
            findings.append(Finding(path, summary_lines[1], "multiple-test-summary", "Keep exactly one test_summary() call at file end."))

        last_non_empty_index = None
        for idx in range(len(lines) - 1, -1, -1):
            if lines[idx].strip():
                last_non_empty_index = idx + 1
                break

        if last_non_empty_index is not None:
            last_line = lines[last_non_empty_index - 1].strip()
            if last_line != "test_summary()":
                findings.append(
                    Finding(
                        path,
                        last_non_empty_index,
                        "test-summary-not-last",
                        "The last non-empty line must be a bare test_summary() call.",
                    )
                )
        if any(RETURN_SUMMARY_RE.match(lines[idx - 1]) for idx in summary_lines):
            first_return = next(idx for idx in summary_lines if RETURN_SUMMARY_RE.match(lines[idx - 1]))
            findings.append(Finding(path, first_return, "return-test-summary", "Use 'test_summary()' without return."))

    return findings


def fix_file(path: Path) -> bool:
    if path.name == "init.lua":
        return False

    raw = path.read_bytes()
    original_text = raw.decode("utf-8-sig")
    original = [line.replace("\ufeff", "") for line in original_text.splitlines()]
    fixed: List[str] = []

    for line in original:
        if CATEGORY_RE.match(line):
            continue
        colon = DESCRIPTION_COLON_RE.match(line)
        if colon:
            text = colon.group("text").strip()
            if text:
                fixed.append(f"{colon.group('indent')}-- @description {text}")
            else:
                fixed.append(f"{colon.group('indent')}-- @description")
            continue
        if RETURN_SUMMARY_RE.match(line) or SUMMARY_RE.match(line):
            continue
        fixed.append(line)

    while fixed and not fixed[-1].strip():
        fixed.pop()
    fixed.append("test_summary()")

    new_text = "\n".join(fixed) + "\n"
    if new_text == original_text and not raw.startswith(UTF8_BOM):
        return False

    path.write_text(new_text, encoding="utf-8")
    return True


def print_human(findings: List[Finding]) -> None:
    if not findings:
        print("PASS: no Lua test structure issues found")
        return

    counts = Counter(f.code for f in findings)
    print("FAIL: Lua test structure issues found")
    for code, count in sorted(counts.items()):
        print(f"  {code}: {count}")
    print()
    for finding in findings:
        rel = finding.path.relative_to(ROOT).as_posix()
        print(f"{rel}:{finding.line}: {finding.code}: {finding.message}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit and optionally fix Lua BDD test structure.")
    parser.add_argument("--path", help="File or directory to audit relative to repo root.")
    parser.add_argument("--fix", action="store_true", help="Apply safe structural fixes (category markers, description colon form, test_summary placement).")
    parser.add_argument("--allow-legacy-describe-markers", action="store_true", help="Temporarily relax the default rule that describe() docstring blocks may contain only @description.")
    parser.add_argument("--json", action="store_true", help="Print findings as JSON.")
    args = parser.parse_args()

    try:
        files = list(iter_lua_test_files(args.path))
    except FileNotFoundError as exc:
        print(f"ERROR: path not found: {exc}", file=sys.stderr)
        return 2

    changed = 0
    if args.fix:
        for path in files:
            if fix_file(path):
                changed += 1

    findings: List[Finding] = []
    for path in files:
        findings.extend(audit_file(path, strict_describe_docstrings=not args.allow_legacy_describe_markers))

    if args.json:
        payload = {
            "changed_files": changed,
            "issue_count": len(findings),
            "issues": [finding.as_dict() for finding in findings],
        }
        print(json.dumps(payload, indent=2))
    else:
        if args.fix:
            print(f"Fixed {changed} file(s)")
        print_human(findings)

    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
