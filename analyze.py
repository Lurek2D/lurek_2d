import os
import re

api_dir = "src/lua_api"
files = [f for f in os.listdir(api_dir) if f.endswith(".rs")]

print(f"Total files: {len(files)}")

violations = {}

for f in files:
    path = os.path.join(api_dir, f)
    with open(path, "r", encoding="utf-8") as file:
        content = file.read()
        lines = content.split('\n')
        
        # Simple heuristic: find 'lua.create_function' or 'add_method' blocks
        # and check their sizes and contents.
        # But even simpler: just count the number of lines.
        # If a file is > 1000 lines, it probably has too much logic.
        
        if len(lines) > 500:
            violations[f] = len(lines)

for f, count in sorted(violations.items(), key=lambda x: x[1], reverse=True):
    print(f"{f}: {count} lines")

