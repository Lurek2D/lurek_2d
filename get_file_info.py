import os
from pathlib import Path

ROOT = Path('docs/specs')

files = sorted([p for p in ROOT.glob('*.md') if p.name != 'README.md'], key=lambda p: p.name.lower())

print(f"{'Filename':<25} | {'Length (chars)':<15} | {'Target Min':<10} | {'Target Max':<10}")
print("-" * 70)
for p in files:
    content = p.read_text(encoding='utf-8', errors='ignore')
    l = len(content)
    min_l = int(l * 0.08)
    max_l = int(l * 0.12)
    print(f"{p.name:<25} | {l:<15} | {min_l:<10} | {max_l:<10}")
