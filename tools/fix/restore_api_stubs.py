#!/usr/bin/env python3
"""Restore --@api-stub: markers and description comments above do-blocks in content/examples/*.lua.

For each `do -- <callable_name>` block found in an example file, this script
inserts:
  --@api-stub: <callable_name>
  -- <description from lua_api_data.json>
immediately above the do-line, if not already present.

Existing code inside do/end blocks is NOT touched.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
EXAMPLES_DIR = ROOT / "content" / "examples"
API_DATA = ROOT / "logs" / "data" / "lua_api_data.json"


def load_descriptions() -> dict[str, str]:
    """Build a map from callable key -> description."""
    data = json.loads(API_DATA.read_text(encoding="utf-8-sig"))
    modules = data.get("lua_api", {}).get("modules", {})
    descs: dict[str, str] = {}

    for mod_name, mod_data in modules.items():
        for func in mod_data.get("functions", []) or []:
            lua_name = func.get("lua_name", "") or f"lurek.{mod_name}.{func.get('name', '')}"
            desc = (func.get("description", "") or "").strip()
            if lua_name and desc:
                descs[lua_name] = desc
            elif lua_name:
                descs[lua_name] = f"API function from lurek.{mod_name}."

        for class_name, class_data in (mod_data.get("classes", {}) or {}).items():
            for method in class_data.get("methods", []) or []:
                name = method.get("name", "")
                key = f"{class_name}:{name}"
                desc = (method.get("description", "") or "").strip()
                if key and desc:
                    descs[key] = desc
                elif key:
                    descs[key] = f"Method on {class_name}."

    return descs


def first_sentence(text: str) -> str:
    """Extract first sentence, max 120 chars."""
    text = re.sub(r"\s+", " ", text).strip()
    match = re.search(r"(.+?[.!?])(?:\s|$)", text)
    result = match.group(1) if match else text[:120]
    return result[:120]


def process_file(path: Path, descs: dict[str, str]) -> int:
    """Add --@api-stub and description above do-blocks. Returns count of insertions."""
    lines = path.read_text(encoding="utf-8-sig").replace("\r\n", "\n").split("\n")
    new_lines: list[str] = []
    insertions = 0

    i = 0
    while i < len(lines):
        line = lines[i]
        # Match `do -- <callable_name>`
        do_match = re.match(r"^do\s+--\s+(.+?)\s*$", line)
        if do_match:
            target = do_match.group(1).strip()

            # Check if --@api-stub already exists above
            has_stub = False
            # Look at previous non-empty lines (up to 3 back)
            for back in range(1, 4):
                idx = len(new_lines) - back
                if idx < 0:
                    break
                prev = new_lines[idx].strip()
                if not prev:
                    continue
                if prev.startswith("--@api-stub:") and target in prev:
                    has_stub = True
                    break
                if prev.startswith("--@api-stub:") or prev.startswith("do "):
                    break
                # If it's a separator or other comment, keep checking
                if not prev.startswith("--"):
                    break

            if not has_stub:
                # Get description
                desc = descs.get(target, "")
                if not desc:
                    # Try without prefix for methods like LCamera:attach
                    for key, val in descs.items():
                        if key.lower() == target.lower():
                            desc = val
                            break
                if not desc:
                    desc = f"Example for {target}."

                short_desc = first_sentence(desc)

                # Insert separator, stub marker, and description
                # Check if separator already exists
                last_nonempty = ""
                for back in range(1, 4):
                    idx = len(new_lines) - back
                    if idx < 0:
                        break
                    if new_lines[idx].strip():
                        last_nonempty = new_lines[idx].strip()
                        break

                if not last_nonempty.startswith("-- ---- Example:"):
                    new_lines.append(f"-- ---- Example: {target} ----")

                new_lines.append(f"--@api-stub: {target}")
                new_lines.append(f"-- {short_desc}")
                insertions += 1

        new_lines.append(line)
        i += 1

    if insertions > 0:
        path.write_text("\n".join(new_lines), encoding="utf-8", newline="\n")

    return insertions


def main() -> None:
    descs = load_descriptions()
    print(f"Loaded {len(descs)} callable descriptions from lua_api_data.json")

    total = 0
    for lua_file in sorted(EXAMPLES_DIR.glob("*.lua")):
        count = process_file(lua_file, descs)
        if count > 0:
            print(f"  {lua_file.name}: +{count} stubs restored")
            total += count

    print(f"\nTotal: {total} stubs restored across all files.")


if __name__ == "__main__":
    main()
