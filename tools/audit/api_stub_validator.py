#!/usr/bin/env python3
"""API Stub Validator -- Validate --@api-stub: block structure and content.

Each API stub block must:
  1. Have NO comments on the marker line (--@api-stub: NAME)
  2. Have a 'do' block immediately following (no blank lines between)
  3. Block body must have minimum 5 non-empty lines before 'end'

This ensures stub blocks are properly structured and substantive.

Usage:
    python tools/audit/api_stub_validator.py                   # full check
    python tools/audit/api_stub_validator.py --examples-dir PATH
    python tools/audit/api_stub_validator.py --json            # JSON report
    python tools/audit/api_stub_validator.py --report          # exit 1 if errors

Exit codes:
    0  - all stub blocks valid
    1  - structural issues found (--report only)
    2  - fatal error
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Optional

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_EXAMPLES_DIR = ROOT / 'content' / 'examples'
OUTPUT_JSON = ROOT / 'logs' / 'data' / 'stub_validation_report.json'

MIN_BODY_LINES = 3

STUB_MARKER_RE = re.compile(r'^--@api-stub:\s*(.+)$')
DO_BLOCK_RE = re.compile(r'^do\s*$')
END_BLOCK_RE = re.compile(r'^end\s*$')

@dataclass
class StubViolation:
    """Record a single stub validation error."""
    file: str
    line_num: int
    marker_name: str
    violation_type: str  # "comment_on_marker", "no_do_block", "too_few_lines", etc.
    detail: str = ""


def validate_stub_blocks(lua_file: Path) -> List[StubViolation]:
    """Scan a Lua file for --@api-stub: blocks and validate their structure."""
    violations: List[StubViolation] = []
    
    try:
        content = lua_file.read_text(encoding='utf-8', errors='replace')
        lines = content.splitlines()
    except Exception as e:
        print(f"ERROR reading {lua_file}: {e}", file=sys.stderr)
        return violations
    
    rel = str(lua_file.relative_to(ROOT)).replace("\\", "/")
    
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        m = STUB_MARKER_RE.match(stripped)
        if not m:
            i += 1
            continue
        
        marker_name = m.group(1).strip()
        marker_line = i + 1
        
        # V1: Check for comments on the marker line
        # Marker line should be EXACTLY: --@api-stub: NAME (no trailing comment)
        if '--' in line[line.index('--@api-stub:') + len('--@api-stub:'):]:
            violations.append(StubViolation(
                file=rel,
                line_num=marker_line,
                marker_name=marker_name,
                violation_type="comment_on_marker",
                detail="Marker line has trailing comment; clean it up",
            ))
        
        # V2: Check for 'do' block immediately after
        if i + 1 >= len(lines):
            violations.append(StubViolation(
                file=rel,
                line_num=marker_line,
                marker_name=marker_name,
                violation_type="no_do_block",
                detail="Stub marker not followed by 'do' block",
            ))
            i += 1
            continue
        
        next_line = lines[i + 1].strip()
        
        # Allow one blank line, then look for 'do'
        if not next_line:
            if i + 2 >= len(lines):
                violations.append(StubViolation(
                    file=rel,
                    line_num=marker_line,
                    marker_name=marker_name,
                    violation_type="no_do_block",
                    detail="Stub marker followed by blank line but no 'do' block",
                ))
                i += 1
                continue
            next_line = lines[i + 2].strip()
            do_line_idx = i + 2
        else:
            do_line_idx = i + 1
        
        if not DO_BLOCK_RE.match(next_line):
            violations.append(StubViolation(
                file=rel,
                line_num=marker_line,
                marker_name=marker_name,
                violation_type="no_do_block",
                detail=f"Expected 'do' block at line {do_line_idx + 1}, got: {next_line[:40]}",
            ))
            i += 1
            continue
        
        # V3: Count non-empty lines in the block body
        body_start = do_line_idx + 1
        body_lines = []
        depth = 1  # Already seen 'do'
        
        for j in range(body_start, len(lines)):
            block_line = lines[j].strip()
            
            # Count structural changes
            depth += block_line.count('do') + block_line.count('then') + block_line.count('repeat')
            depth -= block_line.count('end') + block_line.count('until')
            
            if block_line:
                body_lines.append(block_line)
            
            # Check if we've reached the matching 'end'
            if depth <= 0:
                break
        
        if len(body_lines) < MIN_BODY_LINES:
            violations.append(StubViolation(
                file=rel,
                line_num=marker_line,
                marker_name=marker_name,
                violation_type="insufficient_body",
                detail=f"Block body has {len(body_lines)} non-empty lines but requires {MIN_BODY_LINES}",
            ))
        
        i += 1
    
    return violations


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate --@api-stub: block structure in example files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--examples-dir", metavar="PATH",
                        help="Path to examples directory (default: content/examples)")
    parser.add_argument("--json", action="store_true",
                        help="Output full JSON report")
    parser.add_argument("--report", action="store_true",
                        help="Exit 1 if any violations found")
    args = parser.parse_args(argv)
    
    # Resolve paths
    examples_dir = Path(args.examples_dir) if args.examples_dir else DEFAULT_EXAMPLES_DIR
    if not examples_dir.is_absolute():
        examples_dir = ROOT / examples_dir
    
    if not examples_dir.is_dir():
        print(f"ERROR: examples directory not found: {examples_dir}", file=sys.stderr)
        return 2
    
    # Scan all Lua files
    all_violations: List[StubViolation] = []
    for lua_file in sorted(examples_dir.glob("*.lua")):
        all_violations.extend(validate_stub_blocks(lua_file))
    
    # Group violations by type
    by_type = {}
    by_file = {}
    for v in all_violations:
        by_type[v.violation_type] = by_type.get(v.violation_type, 0) + 1
        by_file.setdefault(v.file, []).append(v)
    
    # Build report
    report_data = {
        "total_violations": len(all_violations),
        "by_type": by_type,
        "files_with_violations": len(by_file),
        "violations": [
            {
                "file": v.file,
                "line": v.line_num,
                "marker": v.marker_name,
                "type": v.violation_type,
                "detail": v.detail,
            }
            for v in all_violations
        ]
    }
    
    # Write JSON
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(json.dumps(report_data, indent=2), encoding='utf-8')
    
    if args.json:
        print(json.dumps(report_data, indent=2))
        return 0
    
    # Human-readable summary
    print(f"\n=== API Stub Block Validator ===")
    print(f"Total violations: {len(all_violations)}")
    
    if by_type:
        print("By violation type:")
        type_labels = {
            "comment_on_marker": "Marker line has trailing comment",
            "no_do_block": "No 'do' block immediately after marker",
            "insufficient_body": f"Block body has fewer than {MIN_BODY_LINES} lines",
        }
        for vtype, count in sorted(by_type.items(), key=lambda x: -x[1]):
            label = type_labels.get(vtype, vtype)
            print(f"  {label}: {count}")
        print()
    
    if by_file:
        print("By file:")
        for file_path, violations in sorted(by_file.items()):
            type_counts = {}
            for v in violations:
                type_counts[v.violation_type] = type_counts.get(v.violation_type, 0) + 1
            detail = ", ".join(f"{k}:{v}" for k, v in sorted(type_counts.items()))
            print(f"  {file_path}: {detail}")
        print()
    
    print(f"Report: {OUTPUT_JSON}")
    
    if len(all_violations) == 0:
        print("[OK] All stub blocks are valid.")
    else:
        print(f"[!] {len(all_violations)} violations found.")
        if args.report:
            return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
