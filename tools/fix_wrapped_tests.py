#!/usr/bin/env python3
"""Add missing @covers markers to wrapped test functions."""

import re
from pathlib import Path

def fix_test_file_with_wrapped_it(file_path, covers_symbol):
    """Fix test file where it() calls are inside local functions."""
    content = Path(file_path).read_text(encoding='utf-8')
    lines = content.split('\n')
    result = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Look for it( call
        it_match = re.match(r'^(\s*)it\s*\(\s*["\']', line)
        if it_match:
            indent = it_match.group(1)
            # Check if previous line has a marker
            has_marker = False
            if i > 0:
                prev_line = lines[i-1]
                if re.match(r'\s*--\s*@', prev_line):
                    has_marker = True

            if not has_marker:
                # Add marker with same indentation
                result.append(f"{indent}-- @covers {covers_symbol}")

        result.append(line)
        i += 1

    Path(file_path).write_text('\n'.join(result), encoding='utf-8')
    print(f"Fixed {file_path}")

# Fix the problematic files
fix_test_file_with_wrapped_it("tests/lua/unit/test_dialog_sequencer_unit.lua", "lurek.dialog")
fix_test_file_with_wrapped_it("tests/lua/unit/test_agent_core_unit.lua", "lurek.agent")
fix_test_file_with_wrapped_it("tests/lua/unit/test_tilemap_core_unit.lua", "lurek.tilemap")

print("\nAll wrapped test files fixed!")
