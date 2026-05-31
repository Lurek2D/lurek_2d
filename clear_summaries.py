import re
from pathlib import Path

ROOT = Path('docs/specs')

def clear_summary_in_file(path: Path):
    text = path.read_text(encoding='utf-8', errors='ignore')
    if '## Summary' not in text:
        print(f"Skipping {path.name}: no Summary section found")
        return False
    
    # We want to replace the content between ## Summary and the next heading (starting with ##)
    # The pattern matches ## Summary\n\n followed by anything until \n\n##
    pattern = r'(## Summary\s*\n\n)(.*?)(\n\n##\s)'
    
    # Let's see if we can perform the replacement
    new_text, count = re.subn(pattern, r'\1\3', text, flags=re.S)
    if count > 0:
        path.write_text(new_text, encoding='utf-8', newline='\n')
        print(f"Cleared Summary in {path.name}")
        return True
    else:
        print(f"Could not clear Summary in {path.name} with standard pattern")
        return False

files = sorted([p for p in ROOT.glob('*.md') if p.name != 'README.md'], key=lambda p: p.name.lower())
cleared = 0
for p in files:
    if clear_summary_in_file(p):
        cleared += 1

print(f"Successfully cleared summaries in {cleared} files.")
