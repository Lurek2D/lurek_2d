#!/usr/bin/env python3
"""Add missing @covers markers to it() blocks in Lua tests."""

import re
from pathlib import Path

def extract_function_name_from_it(it_text):
    """Extract the likely function name from it() description."""
    # Match: it("description with lurek.module.function or LType:method", ...)
    match = re.search(r'it\s*\(\s*["\']([^"\']+)["\']', it_text)
    if match:
        desc = match.group(1)
        
        # Try to extract lurek.* or Type: patterns
        covers = []
        
        # Pattern 1: lurek.module.function
        lurek_matches = re.findall(r'lurek\.([a-zA-Z_][a-zA-Z0-9_.]*)', desc)
        for match_text in lurek_matches:
            covers.append(f"lurek.{match_text}")
        
        # Pattern 2: LType:method or Type:method
        method_matches = re.findall(r'(L?[A-Z][a-zA-Z0-9]*):([a-zA-Z_][a-zA-Z0-9_]*)', desc)
        for type_name, method_name in method_matches:
            covers.append(f"{type_name}:{method_name}")
        
        # Pattern 3: returns (capitalized), creates (capitalized), has (capitalized)
        if 'returns' in desc.lower():
            # Look for Type names after "returns"
            ret_match = re.search(r'returns?\s+(?:a\s+)?(?:the\s+)?(L?[A-Z][a-zA-Z0-9]*)', desc, re.IGNORECASE)
            if ret_match:
                type_name = ret_match.group(1)
                if not type_name.startswith('L'):
                    type_name = 'L' + type_name
                covers.append(type_name)
        
        return covers
    
    return []

def add_missing_it_markers(content):
    """Add @covers markers to it() blocks that don't have them."""
    lines = content.split('\n')
    result = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this is an it( call
        if re.match(r'\s*it\s*\(\s*["\']', line):
            # Check if the previous non-blank line has @covers
            has_marker = False
            j = len(result) - 1
            while j >= 0 and result[j].strip() == '':
                j -= 1
            
            if j >= 0 and '@covers' in result[j]:
                # Already has a marker
                has_marker = True
            
            # Check for any marker (including @integration, @evidence, etc)
            if j >= 0 and re.match(r'\s*--\s*@', result[j]):
                has_marker = True
            
            if not has_marker:
                # Try to extract likely function from the it() description
                covers = extract_function_name_from_it(line)
                if covers:
                    # Add markers for each extracted function
                    for cover in covers:
                        result.append(f"    -- @covers {cover}")
            
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
    content = add_missing_it_markers(content)
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    """Fix all test files with missing it() markers."""
    base_path = Path('tests/lua/unit')
    fixed_count = 0
    
    for test_file in sorted(base_path.glob('*.lua')):
        if fix_file(test_file):
            print(f'Fixed: {test_file.name}')
            fixed_count += 1
    
    print(f'\nTotal unit test files fixed: {fixed_count}')

if __name__ == '__main__':
    main()
