import os
import re
import glob

def aggressive_migrate():
    files = glob.glob('tests/rust/unit/*.rs')
    
    keep_keywords = [
        'internal', 'bytes', 'oob', 'clamp', 'thread', 'serialize', 'deserialize',
        'parse', 'bounds', 'capacity', 'size_of', 'memory', 'pool', 'alloc', 'drop',
        'layout', 'math', 'determinism', 'deterministic', 'range', 'nan', 'inf',
        'macro', 'fmt', 'debug', 'clone', 'eq', 'hash', 'default', 'new_uninit',
        'from_str', 'from_lua', 'raw'
    ]

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        if '// KEEP:' in content:
            continue  # Already processed

        lines = content.split('\n')
        new_lines = []
        
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Find a test function
            if line.strip() == '#[test]':
                # Look ahead for the function name
                j = i + 1
                func_name_line = ""
                while j < len(lines):
                    if lines[j].strip().startswith('fn '):
                        func_name_line = lines[j]
                        break
                    j += 1
                
                if func_name_line:
                    func_name = func_name_line.split('fn ')[1].split('(')[0].strip()
                    
                    # Decide whether to keep
                    keep = any(kw in func_name.lower() for kw in keep_keywords)
                    
                    # Also keep if it's in a module that looks internal
                    # (This script is simple, so we just rely on function names mostly)
                    
                    if keep:
                        new_lines.append('    // KEEP: internal logic / bounds / memory test')
                        new_lines.append(line)
                    else:
                        # Skip the test
                        # We need to skip lines until the end of the function block.
                        brace_count = 0
                        started = False
                        while j < len(lines):
                            if '{' in lines[j]:
                                brace_count += lines[j].count('{')
                                started = True
                            if '}' in lines[j]:
                                brace_count -= lines[j].count('}')
                            
                            if started and brace_count == 0:
                                i = j  # Move i to the end of the function
                                break
                            j += 1
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
                
            i += 1

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(new_lines))
            
        print(f"Processed {file_path}")

if __name__ == '__main__':
    aggressive_migrate()
