#!/usr/bin/env python3
"""Fix Lua test structure violations."""

import re
import sys
from pathlib import Path

def fix_describe_non_describe_marker(content):
    """Remove @covers and other non-@describe markers from describe() docstrings."""
    # Pattern: -- @describe ... followed by lines with other @markers, then describe(
    # We want to keep only the @describe line and remove blank lines between it and describe()
    
    lines = content.split('\n')
    result = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this is a @describe marker line
        if re.match(r'\s*--\s*@describe\s', line):
            # Add the @describe line
            result.append(line)
            i += 1
            
            # Skip all following @covers, @integration, @evidence, etc. markers and blank lines
            # until we hit the describe( call
            while i < len(lines):
                next_line = lines[i]
                # Keep lines that aren't markers or blank
                if (not re.match(r'\s*--\s*@', next_line) and 
                    next_line.strip() != '' and 
                    'describe(' not in next_line):
                    # This is a regular comment or code, keep it
                    result.append(next_line)
                    i += 1
                elif 'describe(' in next_line:
                    # Found the describe() call, add it and break
                    result.append(next_line)
                    i += 1
                    break
                elif re.match(r'\s*--\s*@', next_line):
                    # Skip this marker (not @describe)
                    i += 1
                elif next_line.strip() == '':
                    # Skip blank lines in this section
                    i += 1
                else:
                    # Shouldn't reach here, but keep the line
                    result.append(next_line)
                    i += 1
        else:
            result.append(line)
            i += 1
    
    return '\n'.join(result)

def add_describe_marker(content):
    """Add -- @describe marker before describe() if missing."""
    # Find describe() calls that don't have @describe marker right before them
    lines = content.split('\n')
    result = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this is a describe( call
        if re.match(r'\s*describe\s*\(\s*["\']', line):
            # Look back to see if there's a @describe marker
            if i > 0 and '@describe' in lines[i-1]:
                # Already has @describe, keep it
                result.append(line)
            else:
                # Extract the describe name
                match = re.search(r'describe\s*\(\s*["\']([^"\']+)["\']', line)
                if match:
                    name = match.group(1)
                    # Add @describe marker before the describe() call
                    result.append(f'-- @describe {name}')
                result.append(line)
        else:
            result.append(line)
        
        i += 1
    
    return '\n'.join(result)

def fix_file(file_path):
    """Fix a single test file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Apply fixes
    content = fix_describe_non_describe_marker(content)
    content = add_describe_marker(content)
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    """Fix all test files in tests/lua directory."""
    base_path = Path('tests/lua')
    fixed_count = 0
    
    for test_file in base_path.rglob('test_*.lua'):
        if fix_file(test_file):
            print(f'Fixed: {test_file}')
            fixed_count += 1
    
    print(f'\nTotal files fixed: {fixed_count}')

if __name__ == '__main__':
    main()
