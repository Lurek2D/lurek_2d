#!/usr/bin/env python3
"""Audit Lua evidence and golden test contract compliance.

Rules enforced:
- In tests/lua/evidence, it() blocks that save files should carry -- @evidence file.
- In mixed evidence suites, non-evidence it() blocks are forbidden.
- Evidence block descriptions should be expanded, not one-line stubs.
- In tests/lua/golden, generation logic is forbidden; golden tests compare only.

Safe autofix currently supports:
- add missing -- @evidence file markers to it() blocks that clearly write files.

Usage:
```
usage: lua_evidence_golden_contract_audit.py [-h] [--path PATH] [--fix]
                                             [--json]

Audit Lua evidence/golden contract compliance.

options:
  -h, --help   show this help message and exit
  --path PATH  Optional file or directory relative to repo root.
  --fix        Add missing -- @evidence file markers where file-writing logic
               is obvious.
  --json       Emit JSON findings.

Examples:
  # Default execution
  python tools/audit/lua_evidence_golden_contract_audit.py

  # Show all arguments
  python tools/audit/lua_evidence_golden_contract_audit.py --help
```
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE_DIR = ROOT / "tests" / "lua" / "evidence"
GOLDEN_DIR = ROOT / "tests" / "lua" / "golden"

IT_RE = re.compile(r'^(?P<indent>\s*)it\(\s*["\'](?P<label>.*?)["\']\s*,\s*function\s*\(')
DESCRIPTION_RE = re.compile(r'^\s*--\s*@description\s+(?P<text>.+?)\s*$')
EVIDENCE_RE = re.compile(r'^\s*--\s*@evidence\s+(?P<kind>\w+)\s*$')

SAVE_HINTS = (
    "savePNG(",
    "saveWAV(",
    "io.open(",
    "expect_evidence_created(",
)

GOLDEN_FORBIDDEN = (
    "ensure_evidence_dir(",
    "expect_evidence_created(",
    "io.open(",
    "savePNG(",
    "saveWAV(",
    "lurek.",
)


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


@dataclass
class ItBlock:
    start_line_index: int
    line_index: int
    end_line_index: int
    indent: str
    label: str
    has_evidence: bool
    description_text: str | None
    body: str

    @property
    def writes_file(self) -> bool:
        return any(token in self.body for token in SAVE_HINTS)


def iter_files(path_filter: str | None) -> Iterable[Path]:
    if path_filter:
        target = (ROOT / path_filter).resolve()
        if target.is_file():
            yield target
            return
        if target.is_dir():
            yield from sorted(target.rglob("*.lua"))
            return
        raise FileNotFoundError(path_filter)

    yield from sorted(EVIDENCE_DIR.glob("*.lua"))
    yield from sorted(GOLDEN_DIR.glob("*.lua"))


def collect_it_blocks(lines: List[str]) -> List[ItBlock]:
    blocks: List[ItBlock] = []
    total = len(lines)

    for idx, line in enumerate(lines):
        match = IT_RE.match(line)
        if not match:
            continue

        has_evidence = False
        description_text = None
        start_line_index = idx
        cursor = idx - 1
        while cursor >= 0:
            prev = lines[cursor]
            if not prev.strip():
                start_line_index = cursor
                cursor -= 1
                continue
            if prev.lstrip().startswith("--"):
                start_line_index = cursor
                ev = EVIDENCE_RE.match(prev)
                if ev:
                    has_evidence = True
                desc = DESCRIPTION_RE.match(prev)
                if desc and description_text is None:
                    description_text = desc.group("text")
                cursor -= 1
                continue
            break

        body_lines: List[str] = []
        depth = 1
        cursor = idx + 1
        while cursor < total:
            current = lines[cursor]
            if re.match(r'^\s*function\b', current):
                depth += 1
            if re.match(r'^\s*end\)?\s*$', current):
                depth -= 1
                if depth == 0:
                    break
            body_lines.append(current)
            cursor += 1

        blocks.append(ItBlock(start_line_index, idx, cursor, match.group("indent"), match.group("label"), has_evidence, description_text, "\n".join(body_lines)))

    return blocks


def audit_evidence_file(path: Path, lines: List[str]) -> List[Finding]:
    findings: List[Finding] = []
    blocks = collect_it_blocks(lines)
    has_any_evidence = any(block.has_evidence or block.writes_file for block in blocks)

    for block in blocks:
        line_no = block.line_index + 1
        if block.writes_file and not block.has_evidence:
            findings.append(Finding(path, line_no, "missing-evidence-marker", "Add '-- @evidence file' above this evidence-producing it() block."))

        if block.has_evidence:
            if not block.description_text:
                findings.append(Finding(path, line_no, "missing-evidence-description", "Add an expanded -- @description line above this evidence block."))
            elif len(block.description_text.strip()) < 60:
                findings.append(Finding(path, line_no, "thin-evidence-description", "Expand the evidence description so it explains what artifact is produced and what behavior it proves."))

        if has_any_evidence and not block.has_evidence and not block.writes_file:
            findings.append(Finding(path, line_no, "mixed-unit-check-in-evidence", "Move this non-evidence it() block to a unit test file or remove it from the evidence suite."))

    return findings


def audit_golden_file(path: Path, lines: List[str]) -> List[Finding]:
    findings: List[Finding] = []
    for idx, line in enumerate(lines, start=1):
        stripped = line.lstrip()
        if stripped.startswith("--"):
            continue
        for token in GOLDEN_FORBIDDEN:
            if token in line:
                findings.append(Finding(path, idx, "golden-generation-logic", f"Golden tests must not generate content; remove '{token}' logic and compare evidence only."))
                break
    return findings


def fix_evidence_markers(path: Path, lines: List[str]) -> bool:
    changed = False
    blocks = collect_it_blocks(lines)
    inserts: List[tuple[int, str]] = []
    for block in blocks:
        if block.writes_file and not block.has_evidence:
            inserts.append((block.line_index, f"{block.indent}-- @evidence file"))

    if not inserts:
        return False

    for line_index, text in reversed(inserts):
        lines.insert(line_index, text)
        changed = True

    if changed:
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return changed


def strip_mixed_prechecks(path: Path, lines: List[str]) -> bool:
    blocks = collect_it_blocks(lines)
    has_any_evidence = any(block.has_evidence or block.writes_file for block in blocks)
    to_remove: List[tuple[int, int]] = []

    if not has_any_evidence:
        return False

    for block in blocks:
        if not block.has_evidence and not block.writes_file:
            to_remove.append((block.start_line_index, block.end_line_index))

    if not to_remove:
        return False

    for start, end in reversed(to_remove):
        del lines[start : end + 1]
        while start < len(lines) and not lines[start].strip():
            del lines[start]

    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    return True


def main() -> int:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/audit/lua_evidence_golden_contract_audit.py

  # Show all arguments
  python tools/audit/lua_evidence_golden_contract_audit.py --help
"""
    parser = argparse.ArgumentParser(
        description="Audit Lua evidence/golden contract compliance.",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument("--path", help="Optional file or directory relative to repo root.")
    parser.add_argument("--fix", action="store_true", help="Add missing -- @evidence file markers where file-writing logic is obvious.")
    parser.add_argument("--json", action="store_true", help="Emit JSON findings.")
    args = parser.parse_args()

    try:
        files = list(iter_files(args.path))
    except FileNotFoundError as exc:
        print(f"ERROR: path not found: {exc}", file=sys.stderr)
        return 2

    changed = 0
    findings: List[Finding] = []
    for path in files:
        lines = path.read_text(encoding="utf-8").splitlines()
        if args.fix and str(path).startswith(str(EVIDENCE_DIR)):
            if fix_evidence_markers(path, lines):
                changed += 1
                lines = path.read_text(encoding="utf-8").splitlines()
            if strip_mixed_prechecks(path, lines):
                changed += 1
                lines = path.read_text(encoding="utf-8").splitlines()

        if str(path).startswith(str(EVIDENCE_DIR)):
            findings.extend(audit_evidence_file(path, lines))
        elif str(path).startswith(str(GOLDEN_DIR)) and path.name != "README.md":
            findings.extend(audit_golden_file(path, lines))

    if args.json:
        print(json.dumps({"changed_files": changed, "issue_count": len(findings), "issues": [f.as_dict() for f in findings]}, indent=2))
    else:
        if args.fix:
            print(f"Fixed {changed} file(s)")
        if findings:
            print("FAIL: Lua evidence/golden contract issues found")
            for finding in findings:
                rel = finding.path.relative_to(ROOT).as_posix()
                print(f"{rel}:{finding.line}: {finding.code}: {finding.message}")
        else:
            print("PASS: Lua evidence/golden contract audit passed")

    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
