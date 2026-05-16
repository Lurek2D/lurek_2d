"""One-shot transform for content/examples/*.lua:
1. Reduce file header to 3 lines.
2. Merge description from lua_api_data.json into each @api-stub marker:
     --@api-stub: X               <- append description from api data
     do -- X                      <- keep
   Separator lines (-- ---- Example: ... ----) and standalone description
   comment lines are removed.
3. Idempotent: re-running does not change already-correct files.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent.parent
EXAMPLES = ROOT / "content" / "examples"
API_DATA = ROOT / "logs" / "data" / "lua_api_data.json"

SEPARATOR_RE = re.compile(r"^-- -{4,} Example: .+ -{4,}\s*$")
STUB_RE = re.compile(r"^(--@api-stub:\s*(\S+))(\s+--\s+.+)?$")
DESC_RE = re.compile(r"^-- (.+)$")
DO_RE = re.compile(r"^\s*do\s+--\s+lurek\.")


def load_descriptions() -> dict[str, str]:
    """Build callable_name → first-sentence description from lua_api_data.json."""
    data = json.loads(API_DATA.read_text(encoding="utf-8"))
    descs: dict[str, str] = {}

    def first_sentence(text: str) -> str:
        text = text.strip()
        if not text:
            return ""
        # Take up to first period or newline
        for i, ch in enumerate(text):
            if ch in (".", "\n") or (ch == "@" and i > 0):
                return text[:i].rstrip()
        return text.split("\n")[0].strip()

    mods = data["lua_api"]["modules"]
    for mod_name, mod in mods.items():
        for fn in mod.get("functions", []):
            key = fn.get("lua_name") or f"lurek.{mod_name}.{fn['name']}"
            desc = first_sentence(fn.get("description", "") or fn.get("full_doc", ""))
            if desc:
                descs[key] = desc
        for cls in mod.get("classes", {}).values():
            for method in cls.get("methods", []):
                key = method.get("lua_name") or f"{cls.get('lua_name', cls.get('name', ''))}:{method['name']}"
                desc = first_sentence(method.get("description", "") or method.get("full_doc", ""))
                if desc:
                    descs[key] = desc

    return descs


def extract_brief_from_header(lines: list[str]) -> str:
    """Extract a one-line brief from old header for file-level comment."""
    file_exts = (".lua", ".py", ".rs", ".toml", ".json", ".md", ".txt")
    skip_prefixes = ("hand-written", "run:", "pcall", "content/", "lurek.", "-")
    for line in lines:
        m = DESC_RE.match(line.rstrip())
        if m:
            text = m.group(1).strip()
            low = text.lower()
            if (text
                    and not any(low.startswith(p) for p in skip_prefixes)
                    and "/" not in text
                    and not any(text.endswith(e) for e in file_exts)):
                return text
    return ""


def transform_file(path: Path, descs: dict[str, str]) -> tuple[int, int]:
    """Returns (separators_removed, stubs_updated). Writes file only if changed."""
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)

    # ── 1. Find header end ──
    header_end = 0
    for i, ln in enumerate(lines):
        stripped = ln.strip()
        if SEPARATOR_RE.match(stripped) or DO_RE.match(stripped) or STUB_RE.match(stripped):
            header_end = i
            break
    else:
        header_end = len(lines)

    header_lines = [l.rstrip("\n\r") for l in lines[:header_end]]

    # Build compact 3-line header
    module = path.stem
    filename_line = f"-- content/examples/{path.name}"
    run_line = f"-- Run: cargo run -- content/examples/{path.name}"
    brief = extract_brief_from_header(header_lines)
    if brief and not brief.lower().endswith(".lua"):
        module_line = f"-- lurek.{module}: {brief.rstrip('.')}."
    else:
        module_line = f"-- lurek.{module} API examples."
    new_header = [filename_line, module_line, run_line, ""]

    # ── 2. Transform stub blocks in the body ──
    body_lines = lines[header_end:]
    out: list[str] = []
    sep_removed = 0
    stubs_updated = 0

    i = 0
    while i < len(body_lines):
        ln = body_lines[i]
        stripped = ln.strip()

        # Remove separator lines
        if SEPARATOR_RE.match(stripped):
            sep_removed += 1
            i += 1
            continue

        sm = STUB_RE.match(stripped)
        if sm:
            stub_prefix = sm.group(1)   # "--@api-stub: lurek.x.y"
            callable_name = sm.group(2) # "lurek.x.y" or "LClass:method"
            existing_desc = sm.group(3) # " -- Existing desc." or None

            # Skip following standalone description comment lines (eat them)
            j = i + 1
            while j < len(body_lines):
                next_stripped = body_lines[j].strip()
                if not next_stripped or DO_RE.match(next_stripped) or STUB_RE.match(next_stripped):
                    break
                if DESC_RE.match(next_stripped):
                    j += 1  # consume standalone description line
                else:
                    break

            # Choose description: prefer api_data, fallback to existing in marker
            api_desc = descs.get(callable_name, "")
            if api_desc:
                new_line = f"{stub_prefix} -- {api_desc}\n"
            elif existing_desc:
                new_line = f"{stub_prefix}{existing_desc}\n"
            else:
                new_line = f"{stub_prefix}\n"

            if new_line != ln:
                stubs_updated += 1
            out.append(new_line)
            i = j
            continue

        out.append(ln)
        i += 1

    result = "".join(l + "\n" for l in new_header) + "".join(out)
    if result != original:
        path.write_text(result, encoding="utf-8")

    return sep_removed, stubs_updated


def main():
    descs = load_descriptions()
    print(f"Loaded {len(descs)} descriptions from lua_api_data.json")
    files = sorted(EXAMPLES.glob("*.lua"))
    total_sep = 0
    total_upd = 0
    for f in files:
        s, u = transform_file(f, descs)
        if s or u:
            print(f"  {f.name}: {s} separators removed, {u} stubs updated")
        total_sep += s
        total_upd += u
    print(f"\nDone. {len(files)} files, {total_sep} separators removed, {total_upd} stubs updated.")


if __name__ == "__main__":
    main()
