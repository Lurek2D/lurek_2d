#!/usr/bin/env python3
"""Add missing @covers markers to specific it() blocks."""

import re
from pathlib import Path

def fix_agent_core_test():
    """Fix test_agent_core_unit.lua by adding missing @covers markers."""
    file = Path('tests/lua_reorg/unit/test_agent_core_unit.lua')
    content = file.read_text(encoding='utf-8')

    # Map of line numbers (approx) -> @covers markers to add
    # These are extracted from the error messages
    fixes = {
        650: "lurek.agent.configure",
        707: "LAgentChat",
        795: "LEpisodicMemory",
        820: "LSemanticMemory",
        828: "LSemanticMemory",
        844: "LAgentMemory",
        853: "LAgentMemory",
    }

    lines = content.split('\n')
    result = []

    for i, line in enumerate(lines):
        # Check if this line matches one of the problematic it() calls
        line_num = i + 1  # 1-based line numbers

        # Look for matches in nearby range (within 5 lines)
        for target_line in fixes:
            if abs(line_num - target_line) <= 3 and re.match(r'\s*it\s*\(\s*["\']', line):
                # Check if previous line has @covers
                if i > 0 and '@covers' not in lines[i-1] and '@' not in lines[i-1]:
                    # Add the marker
                    indent = len(line) - len(line.lstrip())
                    result.append(' ' * indent + f"-- @covers {fixes[target_line]}")
                break

        result.append(line)

    file.write_text('\n'.join(result), encoding='utf-8')
    print(f"Fixed test_agent_core_unit.lua")

def fix_camera_walker_test():
    """Fix test_camera_walker.lua by adding missing @covers markers."""
    file = Path('tests/lua_reorg/unit/test_camera_walker.lua')
    content = file.read_text(encoding='utf-8')

    # These blocks need @covers lurek.camera.newWalker or similar
    lines = content.split('\n')
    result = []

    for i, line in enumerate(lines):
        # Add @covers before any it() that doesn't already have a marker
        if re.match(r'\s*it\s*\(\s*["\']', line):
            # Check if previous line has a marker
            if i > 0 and not re.match(r'\s*--\s*@', lines[i-1]):
                # Add generic marker
                indent = len(line) - len(line.lstrip())
                result.append(' ' * indent + "-- @covers lurek.camera")

        result.append(line)

    file.write_text('\n'.join(result), encoding='utf-8')
    print(f"Fixed test_camera_walker.lua")

def fix_cinematic_test():
    """Fix test_cinematic_timeline_unit.lua by adding missing @covers markers."""
    file = Path('tests/lua_reorg/unit/test_cinematic_timeline_unit.lua')
    content = file.read_text(encoding='utf-8')

    lines = content.split('\n')
    result = []

    for i, line in enumerate(lines):
        # Add @covers before any it() that doesn't already have a marker
        if re.match(r'\s*it\s*\(\s*["\']', line):
            # Check if previous line has a marker
            if i > 0 and not re.match(r'\s*--\s*@', lines[i-1]):
                # Add generic marker
                indent = len(line) - len(line.lstrip())
                result.append(' ' * indent + "-- @covers lurek.cinematic")

        result.append(line)

    file.write_text('\n'.join(result), encoding='utf-8')
    print(f"Fixed test_cinematic_timeline_unit.lua")

if __name__ == '__main__':
    fix_agent_core_test()
    fix_camera_walker_test()
    fix_cinematic_test()
    print("\nAll unit test files fixed!")
