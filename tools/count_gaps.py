#!/usr/bin/env python3
import re
from collections import Counter
from pathlib import Path

c = Path("docs/API/coverage_gaps.md").read_text(encoding="utf-8")
mods = Counter()
for line in c.splitlines():
    line = line.strip()
    m = re.match(r"\| (luna\.\w+)\.\w+", line)
    if m:
        mods[m.group(1)] += 1

total = sum(mods.values())
print(f"Total Section 3 items: {total}")
print()
for mod, cnt in mods.most_common(30):
    print(f"  {mod}: {cnt}")
