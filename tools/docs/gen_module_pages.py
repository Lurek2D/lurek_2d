#!/usr/bin/env python3
"""Generate per-module MkDocs pages in docs/modules/ from:
  - docs/specs/<module>.md  -> description (TL;DR + Summary)
  - docs/api/lurek.lua      -> function/method signatures + param/return docs
  - content/examples/<module>.lua -> code examples per symbol

Usage:
    python tools/docs/gen_module_pages.py
    python tools/docs/gen_module_pages.py render audio physics
"""
import re
import sys
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPECS_DIR = ROOT / "docs" / "specs"
STUB_FILE = ROOT / "docs" / "api" / "lurek.lua"
EXAMPLES_DIR = ROOT / "content" / "examples"
OUT_DIR = ROOT / "docs" / "modules"

# ---------------------------------------------------------------------------
# Spec description extraction
# ---------------------------------------------------------------------------

def extract_spec_description(spec_path: Path) -> str:
    """Return TL;DR bullets + Summary paragraph from a spec file."""
    if not spec_path.exists():
        return ""
    text = spec_path.read_text(encoding="utf-8")
    parts = []

    # TL;DR section
    m = re.search(r"## TL;DR\s*\n(.*?)(?=\n## |\Z)", text, re.DOTALL)
    if m:
        parts.append(m.group(1).strip())

    # Summary section
    m = re.search(r"## Summary\s*\n(.*?)(?=\n## |\Z)", text, re.DOTALL)
    if m:
        parts.append(m.group(1).strip())

    return "\n\n".join(parts)


# ---------------------------------------------------------------------------
# lurek.lua stub parser
# ---------------------------------------------------------------------------

def parse_stub(stub_file: Path):
    """Parse docs/api/lurek.lua and return two dicts:
      module_fns[module]   = list of {name, full_name, params_line, doc_lines}
      class_methods[class] = list of {name, full_name, params_line, doc_lines}
    """
    text = stub_file.read_text(encoding="utf-8")
    lines = text.splitlines()

    module_fns: dict[str, list] = {}
    class_methods: dict[str, list] = {}

    i = 0
    while i < len(lines):
        line = lines[i]

        # --- module function: lurek.X.Y = function(...) end
        mf = re.match(r'^(lurek\.(\w+)\.(\w+))\s*=\s*function\((.*?)\)\s*end', line)
        if mf:
            full_name = mf.group(1)
            module = mf.group(2)
            fname = mf.group(3)
            params_line = mf.group(4)
            # collect preceding doc/annotation lines
            doc_lines = []
            j = i - 1
            while j >= 0 and (lines[j].startswith("---") or lines[j].strip() == ""):
                if lines[j].startswith("---"):
                    doc_lines.insert(0, lines[j])
                j -= 1
            entry = dict(name=fname, full_name=full_name,
                         params_line=params_line, doc_lines=doc_lines)
            module_fns.setdefault(module, []).append(entry)
            i += 1
            continue

        # --- module function: function lurek.X.Y(...) end
        mf2 = re.match(r'^function (lurek\.(\w+)\.(\w+))\((.*?)\)\s*end', line)
        if mf2:
            full_name = mf2.group(1)
            module = mf2.group(2)
            fname = mf2.group(3)
            params_line = mf2.group(4)
            doc_lines = []
            j = i - 1
            while j >= 0 and (lines[j].startswith("---") or lines[j].strip() == ""):
                if lines[j].startswith("---"):
                    doc_lines.insert(0, lines[j])
                j -= 1
            entry = dict(name=fname, full_name=full_name,
                         params_line=params_line, doc_lines=doc_lines)
            module_fns.setdefault(module, []).append(entry)
            i += 1
            continue

        # --- class method: function LClass:method(...) end
        cm = re.match(r'^function (L\w+):(\w+)\((.*?)\)\s*end', line)
        if cm:
            class_name = cm.group(1)
            mname = cm.group(2)
            params_line = cm.group(3)
            full_name = f"{class_name}:{mname}"
            doc_lines = []
            j = i - 1
            while j >= 0 and (lines[j].startswith("---") or lines[j].strip() == ""):
                if lines[j].startswith("---"):
                    doc_lines.insert(0, lines[j])
                j -= 1
            entry = dict(name=mname, full_name=full_name,
                         params_line=params_line, doc_lines=doc_lines)
            class_methods.setdefault(class_name, []).append(entry)
            i += 1
            continue

        i += 1

    return module_fns, class_methods


def doc_to_parts(doc_lines: list[str]) -> tuple[str, list[str], list[str]]:
    """Split doc_lines into (description, param_lines, return_lines)."""
    desc_parts = []
    params = []
    returns = []
    for l in doc_lines:
        body = l.lstrip("-").strip()
        if body.startswith("@param"):
            params.append(body)
        elif body.startswith("@return"):
            returns.append(body)
        elif body.startswith("@"):
            pass  # skip other annotations
        else:
            if body:
                desc_parts.append(body)
    return " ".join(desc_parts), params, returns


def format_params(params: list[str]) -> str:
    """Format @param lines into a markdown table row."""
    rows = []
    for p in params:
        # @param name type? description
        m = re.match(r'@param\s+(\w+\??)\s+(\S+)\s*(.*)', p)
        if m:
            rows.append(f"| `{m.group(1)}` | `{m.group(2)}` | {m.group(3).strip()} |")
        else:
            rows.append(f"| — | — | {p} |")
    return rows


def format_returns(returns: list[str]) -> str:
    rows = []
    for r in returns:
        m = re.match(r'@return\s+(\S+)\s*(.*)', r)
        if m:
            rows.append(f"| `{m.group(1)}` | {m.group(2).strip()} |")
        else:
            rows.append(f"| — | {r} |")
    return rows


# ---------------------------------------------------------------------------
# Example extractor
# ---------------------------------------------------------------------------

def load_examples(module: str) -> dict[str, str]:
    """Return {full_name: code_body} from content/examples/<module>.lua."""
    lua_file = EXAMPLES_DIR / f"{module}.lua"
    if not lua_file.exists():
        return {}
    text = lua_file.read_text(encoding="utf-8")
    result = {}
    # Match --@api-stub: Symbol followed by do...end block
    pattern = re.compile(
        r'--@api-stub:\s*([\w.:]+)\s*\n(do\b.*?^end)',
        re.DOTALL | re.MULTILINE
    )
    for m in pattern.finditer(text):
        key = m.group(1).strip()
        body = m.group(2).strip()
        # Keep first occurrence only
        if key not in result:
            result[key] = body
    return result


# ---------------------------------------------------------------------------
# Page renderer
# ---------------------------------------------------------------------------

def render_signature(entry: dict) -> str:
    """Render function signature line."""
    params = entry["params_line"]
    if ":" in entry["full_name"]:
        # class method — self already implicit
        params_clean = re.sub(r'^self\s*,?\s*', '', params).strip()
        sig = f"{entry['full_name']}({params_clean})"
    else:
        sig = f"{entry['full_name']}({params})"
    return sig


def render_entry(entry: dict, examples: dict) -> list[str]:
    lines = []
    desc, params, returns = doc_to_parts(entry["doc_lines"])
    sig = render_signature(entry)

    lines.append(f"### `{entry['full_name']}`")
    lines.append("")
    if desc:
        lines.append(desc)
        lines.append("")

    lines.append(f"```lua")
    lines.append(f"-- signature")
    lines.append(f"{sig}")
    lines.append(f"```")
    lines.append("")

    if params:
        lines.append("**Parameters**")
        lines.append("")
        lines.append("| Name | Type | Description |")
        lines.append("|------|------|-------------|")
        lines.extend(format_params(params))
        lines.append("")

    if returns:
        lines.append("**Returns**")
        lines.append("")
        lines.append("| Type | Description |")
        lines.append("|------|-------------|")
        lines.extend(format_returns(returns))
        lines.append("")

    # Find example — try full_name, then short name variants
    example_code = (examples.get(entry["full_name"])
                    or examples.get(entry["full_name"].replace(":", ".")))
    if example_code:
        lines.append("**Example**")
        lines.append("")
        lines.append("```lua")
        lines.append(example_code)
        lines.append("```")
        lines.append("")

    lines.append("---")
    lines.append("")
    return lines


def build_page(module: str, module_fns: dict, class_methods: dict) -> str:
    spec_path = SPECS_DIR / f"{module}.md"
    desc = extract_spec_description(spec_path)
    examples = load_examples(module)

    # Which classes belong to this module?
    # Heuristic: classes whose methods reference lurek.<module> in examples
    # or whose name contains the module keyword.
    # Simpler: we just include all classes that appear in the module's examples stubs
    relevant_classes = set()
    for key in examples:
        # e.g. LImage:draw -> LImage
        m = re.match(r'(L\w+)[:.]', key)
        if m:
            relevant_classes.add(m.group(1))

    fns = module_fns.get(module, [])
    # Deduplicate by full_name (lurek.lua sometimes has duplicates)
    seen = set()
    unique_fns = []
    for f in fns:
        if f["full_name"] not in seen:
            seen.add(f["full_name"])
            unique_fns.append(f)

    out = []
    out.append(f"# {module.title()}")
    out.append("")

    if desc:
        out.append(desc)
        out.append("")

    if not unique_fns and not relevant_classes:
        out.append("*No public API documented yet.*")
        return "\n".join(out)

    if unique_fns:
        out.append("## Functions")
        out.append("")
        for entry in sorted(unique_fns, key=lambda e: e["name"]):
            out.extend(render_entry(entry, examples))

    for cls in sorted(relevant_classes):
        methods = class_methods.get(cls, [])
        if not methods:
            continue
        seen_m = set()
        unique_m = []
        for m in methods:
            if m["full_name"] not in seen_m:
                seen_m.add(m["full_name"])
                unique_m.append(m)
        out.append(f"## {cls}")
        out.append("")
        for entry in sorted(unique_m, key=lambda e: e["name"]):
            out.extend(render_entry(entry, examples))

    return "\n".join(out)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

KNOWN_MODULES = [
    "agent", "ai", "animation", "app", "audio", "automation", "binary",
    "camera", "charts", "color", "compute", "cursor", "dataframe",
    "debugbridge", "devtools", "dialog", "docs", "dsp", "ecs", "effect",
    "event", "filesystem", "flownet", "font", "globe", "grep", "html",
    "i18n", "image", "input", "layout", "learning", "light", "log",
    "mapblock", "math", "midi", "minimap", "mods", "network", "overlay",
    "parallax", "particle", "pathfind", "patterns", "physics", "pipeline",
    "procgen", "province", "raycaster", "render", "repl", "runtime",
    "save", "scene", "serialize", "spine", "sprite", "terminal", "thread",
    "tilemap", "timer", "tween", "ui", "validator", "visibility", "window",
]


def main():
    targets = sys.argv[1:] if len(sys.argv) > 1 else KNOWN_MODULES

    print("Parsing docs/api/lurek.lua ...")
    module_fns, class_methods = parse_stub(STUB_FILE)

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    generated = []
    for module in targets:
        if module not in module_fns:
            # Still generate if spec or examples exist
            if not (SPECS_DIR / f"{module}.md").exists() and not (EXAMPLES_DIR / f"{module}.lua").exists():
                continue

        page = build_page(module, module_fns, class_methods)
        out_file = OUT_DIR / f"{module}.md"
        out_file.write_text(page, encoding="utf-8")
        fn_count = len(module_fns.get(module, []))
        print(f"  {module}.md  ({fn_count} functions)")
        generated.append(module)

    print(f"\nDone — {len(generated)} module pages in docs/modules/")
    return generated


if __name__ == "__main__":
    main()
