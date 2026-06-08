#!/usr/bin/env python3
"""API Occurrence Validator -- Check that each lurek.* API has examples.

This tool validates coverage: each API should have at least one --@api-stub:
marker across all example files. It counts stub markers only (not actual usage).

Usage:
    python tools/audit/api_occurrence_validator.py                # coverage report
    python tools/audit/api_occurrence_validator.py --json         # JSON report
    python tools/audit/api_occurrence_validator.py --report       # exit 1 if gaps

Exit codes:
    0  - all APIs have at least one stub
    1  - some APIs missing from examples (--report only)
    2  - fatal error
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / 'logs' / 'data' / 'lua_api_data.json'
DEFAULT_EXAMPLES_DIR = ROOT / 'content' / 'examples'
OUTPUT_JSON = ROOT / 'logs' / 'data' / 'api_coverage_report.json'

@dataclass
class CoverageReport:
    """Track if API has at least one stub marker."""
    api_name: str
    has_stub: bool = False
    files: list[str] = field(default_factory=list)


def load_api_entries(json_path: Path) -> Set[str]:
    """Load all API names from lua_api_data.json."""
    try:
        data = json.loads(json_path.read_text(encoding='utf-8'))
        apis = set()
        mods = data.get('lua_api', {}).get('modules', {})

        for module_name, module_data in mods.items():
            if module_name == 'collision':
                continue

            # Functions
            for fn in module_data.get('functions', []):
                lua_name = fn.get('lua_name') or f"lurek.{module_name}.{fn['name']}"
                apis.add(lua_name)

            # Classes and methods
            for class_name, class_data in module_data.get('classes', {}).items():
                for method in class_data.get('methods', []):
                    lua_name = method.get('lua_name') or f"{class_name}:{method['name']}"
                    apis.add(lua_name)

        return apis
    except Exception as e:
        print(f"ERROR loading API registry: {e}", file=sys.stderr)
        return set()


def scan_example_stubs(examples_dir: Path) -> Dict[str, List[str]]:
    """Scan all example files for --@api-stub: markers.

    Returns dict: api_name -> list of files where it appears
    """
    stubs: Dict[str, List[str]] = {}

    for lua_file in examples_dir.glob('*.lua'):
        try:
            content = lua_file.read_text(encoding='utf-8', errors='replace')
            for line in content.splitlines():
                if line.strip().startswith('--@api-stub:'):
                    marker = line.strip()[len('--@api-stub:'):].strip()
                    if marker:
                        if marker not in stubs:
                            stubs[marker] = []
                        stubs[marker].append(lua_file.name)
        except Exception as e:
            print(f"ERROR reading {lua_file}: {e}", file=sys.stderr)

    return stubs


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Check that each lurek.* API has example stubs.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--examples-dir", metavar="PATH",
                        help="Path to examples directory (default: content/examples)")
    parser.add_argument("--json", action="store_true",
                        help="Output full JSON report")
    parser.add_argument("--report", action="store_true",
                        help="Exit 1 if any APIs missing from examples")
    args = parser.parse_args(argv)

    # Resolve paths
    examples_dir = Path(args.examples_dir) if args.examples_dir else DEFAULT_EXAMPLES_DIR
    if not examples_dir.is_absolute():
        examples_dir = ROOT / examples_dir

    if not examples_dir.is_dir():
        print(f"ERROR: examples directory not found: {examples_dir}", file=sys.stderr)
        return 2

    if not API_JSON.is_file():
        print(f"ERROR: API registry not found: {API_JSON}", file=sys.stderr)
        return 2

    # Load APIs and stubs
    all_apis = load_api_entries(API_JSON)
    stubs = scan_example_stubs(examples_dir)

    if not all_apis:
        print(f"ERROR: No APIs found in registry", file=sys.stderr)
        return 2

    # Determine coverage
    covered = len(all_apis & set(stubs.keys()))
    missing = sorted(all_apis - set(stubs.keys()))

    # Build report
    report_data = {
        "total_apis": len(all_apis),
        "covered": covered,
        "missing": len(missing),
        "missing_apis": missing,
        "stub_counts": {api: len(files) for api, files in stubs.items()},
    }

    # Write JSON
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(json.dumps(report_data, indent=2), encoding='utf-8')

    if args.json:
        print(json.dumps(report_data, indent=2))
        return 0

    # Human-readable summary
    pct = (covered / len(all_apis) * 100) if all_apis else 0
    print(f"\n=== API Example Coverage ===")
    print(f"Total APIs: {len(all_apis)}")
    print(f"With stubs: {covered} ({pct:.1f}%)")
    print(f"Missing: {len(missing)}")
    print()

    if missing:
        print("Missing API stubs:")
        for api in missing[:20]:
            print(f"  - {api}")
        if len(missing) > 20:
            print(f"  ... and {len(missing) - 20} more")
        print()

    print(f"Report: {OUTPUT_JSON}")

    if missing and args.report:
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
