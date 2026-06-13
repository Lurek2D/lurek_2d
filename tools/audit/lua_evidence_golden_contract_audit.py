#!/usr/bin/env python3
"""Audit Lua evidence and golden test contract compliance.

Rules enforced:
- In tests/lua/evidence, evidence it() blocks must rely on prose rationale comments, not -- @evidence markers.
- In mixed evidence suites, non-evidence it() blocks are forbidden.
- Evidence files must not carry file-level -- @covers markers.
- Evidence blocks must explain what they do, what the artifact should show,
  which artifact is written, and why the artifact is meaningful.
- In tests/lua/golden, generation logic is forbidden; golden tests compare only.
- Golden sample references must point at committed files.

Optional strict mode:
- Evidence rationale fields are treated as contract failures when missing.

Safe autofix currently supports:
- remove obvious non-evidence precheck blocks from evidence suites.

Usage:
```
usage: lua_evidence_golden_contract_audit.py [-h] [--path PATH] [--fix]
                                             [--json] [--require-descriptions]

Audit Lua evidence/golden contract compliance.

options:
  -h, --help   show this help message and exit
  --path PATH  Optional file or directory relative to repo root.
  --fix        Remove obvious non-evidence precheck blocks from evidence
               suites.
  --json       Emit JSON findings.
  --require-descriptions
               Treat missing evidence rationale fields as contract failures.

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

from lua_artifact_lock import lua_artifact_lock

ROOT = Path(__file__).resolve().parents[2]
CANONICAL_EVIDENCE_DIR = ROOT / "tests" / "lua" / "evidence"
CANONICAL_GOLDEN_DIR = ROOT / "tests" / "lua" / "golden"
LEGACY_EVIDENCE_DIR = CANONICAL_EVIDENCE_DIR
LEGACY_GOLDEN_DIR = CANONICAL_GOLDEN_DIR

IT_RE = re.compile(r'^(?P<indent>\s*)it\(\s*["\'](?P<label>.*?)["\']\s*,\s*function\s*\(')
LEGACY_EVIDENCE_RE = re.compile(r'^\s*--\s*@evidence\s+(?P<kind>.+?)\s*$')
SAMPLE_PATH_RE = re.compile(r'["\'](?P<path>tests/artifacts/baselines/[^"\']+)["\']')
COVERS_RE = re.compile(r'^\s*--\s*@covers\s+(?P<kind>.+?)\s*$')

RATIONALE_PREFIXES = {
    "does": "-- Does:",
    "shows": "-- Shows:",
    "artifact": "-- Artifact:",
    "why": "-- Why:",
}

SAVE_HINTS = (
    "savePNG(",
    "saveGIF(",
    "saveWAV(",
    "io.open(",
    "write_file(",
    "lurek.filesystem.write(",
    "expect_evidence_created(",
)
SAVE_HELPER_RE = re.compile(r"\b(?:save|write|export)(?:_[A-Za-z0-9_]+|[A-Z][A-Za-z0-9_]*)?\s*\(")

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
    has_legacy_evidence: bool
    rationale_fields: dict[str, str]
    body: str

    @property
    def writes_file(self) -> bool:
        return any(token in self.body for token in SAVE_HINTS) or SAVE_HELPER_RE.search(self.body) is not None

    @property
    def has_rationale(self) -> bool:
        return any(value.strip() for value in self.rationale_fields.values())

    @property
    def has_complete_rationale(self) -> bool:
        return all(self.rationale_fields.get(key, "").strip() for key in RATIONALE_PREFIXES)


def default_dirs() -> tuple[Path, Path]:
    if CANONICAL_EVIDENCE_DIR.exists() and CANONICAL_GOLDEN_DIR.exists():
        return CANONICAL_EVIDENCE_DIR, CANONICAL_GOLDEN_DIR
    return LEGACY_EVIDENCE_DIR, LEGACY_GOLDEN_DIR


def iter_files(path_filter: str | None) -> Iterable[Path]:
    evidence_dir, golden_dir = default_dirs()
    if path_filter:
        target = (ROOT / path_filter).resolve()
        if target.is_file():
            yield target
            return
        if target.is_dir():
            yield from sorted(target.rglob("*.lua"))
            return
        raise FileNotFoundError(path_filter)

    yield from sorted(evidence_dir.glob("*.lua"))
    yield from sorted(golden_dir.glob("*.lua"))


def collect_it_blocks(lines: List[str]) -> List[ItBlock]:
    blocks: List[ItBlock] = []
    total = len(lines)

    for idx, line in enumerate(lines):
        match = IT_RE.match(line)
        if not match:
            continue

        has_legacy_evidence = False
        rationale_fields: dict[str, str] = {}
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
                ev = LEGACY_EVIDENCE_RE.match(prev)
                if ev:
                    has_legacy_evidence = True
                stripped = prev.strip()
                for key, prefix in RATIONALE_PREFIXES.items():
                    if stripped.startswith(prefix):
                        rationale_fields.setdefault(key, stripped[len(prefix) :].strip())
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

        blocks.append(
            ItBlock(
                start_line_index,
                idx,
                cursor,
                match.group("indent"),
                match.group("label"),
                has_legacy_evidence,
                rationale_fields,
                "\n".join(body_lines),
            )
        )

    return blocks


def audit_evidence_file(
    path: Path, lines: List[str], require_descriptions: bool = False
) -> List[Finding]:
    findings: List[Finding] = []
    blocks = collect_it_blocks(lines)
    has_any_evidence = any(block.writes_file or block.has_rationale for block in blocks)

    for idx, line in enumerate(lines, start=1):
        if IT_RE.match(line):
            break
        if COVERS_RE.match(line):
            findings.append(
                Finding(
                    path,
                    idx,
                    "evidence-top-covers",
                    "Remove file-level '-- @covers' markers from evidence files; evidence ownership is file-level and described by the rationale comments above each block.",
                )
            )

    for block in blocks:
        line_no = block.line_index + 1
        if block.has_legacy_evidence:
            findings.append(
                Finding(
                    path,
                    line_no,
                    "legacy-evidence-marker",
                    "Remove legacy '-- @evidence ...' markers; use prose rationale comments only.",
                )
            )

        if require_descriptions:
            for key, prefix in RATIONALE_PREFIXES.items():
                value = block.rationale_fields.get(key, "").strip()
                if not value:
                    findings.append(
                        Finding(
                            path,
                            line_no,
                            f"missing-evidence-{key}",
                            f"Add a '{prefix}' line above this evidence block.",
                        )
                    )
                elif len(value) < 16:
                    findings.append(
                        Finding(
                            path,
                            line_no,
                            f"thin-evidence-{key}",
                            f"Expand '{prefix}' so it explains the evidence intent concretely.",
                        )
                    )

        if has_any_evidence and not block.writes_file and not block.has_complete_rationale:
            findings.append(Finding(path, line_no, "mixed-unit-check-in-evidence", "Move this non-evidence it() block to a unit test file or remove it from the evidence suite."))

    return findings


def audit_golden_file(path: Path, lines: List[str]) -> List[Finding]:
    findings: List[Finding] = []
    text = "\n".join(lines)
    for idx, line in enumerate(lines, start=1):
        stripped = line.lstrip()
        if stripped.startswith("--"):
            continue
        for token in GOLDEN_FORBIDDEN:
            if token in line:
                findings.append(Finding(path, idx, "golden-generation-logic", f"Golden tests must not generate content; remove '{token}' logic and compare evidence only."))
                break
    for match in SAMPLE_PATH_RE.finditer(text):
        sample_rel = match.group("path")
        sample_path = ROOT / sample_rel
        if sample_path.exists():
            continue
        line_no = text[: match.start()].count("\n") + 1
        findings.append(
            Finding(
                path,
                line_no,
                "missing-golden-sample",
                f"Golden sample path does not exist: '{sample_rel}'",
            )
        )
    return findings


def strip_mixed_prechecks(path: Path, lines: List[str]) -> bool:
    blocks = collect_it_blocks(lines)
    has_any_evidence = any(block.writes_file or block.has_rationale for block in blocks)
    to_remove: List[tuple[int, int]] = []

    if not has_any_evidence:
        return False

    for block in blocks:
        if not block.writes_file and not block.has_complete_rationale:
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
    parser.add_argument("--fix", action="store_true", help="Remove obvious non-evidence precheck blocks from evidence suites.")
    parser.add_argument("--json", action="store_true", help="Emit JSON findings.")
    parser.add_argument(
        "--require-descriptions",
        action="store_true",
        help="Treat missing or thin @description lines as contract failures.",
    )
    args = parser.parse_args()
    with lua_artifact_lock("lua_evidence_golden_contract_audit.py"):
        evidence_dir, golden_dir = default_dirs()

        try:
            files = list(iter_files(args.path))
        except FileNotFoundError as exc:
            print(f"ERROR: path not found: {exc}", file=sys.stderr)
            return 2

        changed = 0
        findings: List[Finding] = []
        for path in files:
            lines = path.read_text(encoding="utf-8").splitlines()
            if args.fix and str(path).startswith(str(evidence_dir)):
                if strip_mixed_prechecks(path, lines):
                    changed += 1
                    lines = path.read_text(encoding="utf-8").splitlines()

            if str(path).startswith(str(evidence_dir)):
                findings.extend(
                    audit_evidence_file(
                        path, lines, require_descriptions=args.require_descriptions
                    )
                )
            elif str(path).startswith(str(golden_dir)) and path.name != "README.md":
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
