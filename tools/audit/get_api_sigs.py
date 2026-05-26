"""Extract all lurek.* namespace-level function signatures from docs/api/lurek.lua

Usage:
```
Usage:
    python tools/audit/get_api_sigs.py
```
"""
import re, os

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
with open(os.path.join(ROOT, 'docs', 'api', 'lurek.lua'), encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
for i, line in enumerate(lines):
    if 'function lurek.' in line:
        print(f'{i+1}: {line.strip()}')
