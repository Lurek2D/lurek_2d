#!/usr/bin/env python3
"""Generate per-module MkDocs pages in docs/lua/ from:
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
LUA_API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"
EXAMPLES_DIR = ROOT / "content" / "examples"
OUT_DIR = ROOT / "docs" / "modules"  # MkDocs input - Lua API module markdown documentation
CALLBACKS_MD = ROOT / "docs" / "callbacks.md"

# ---------------------------------------------------------------------------
# Spec description extraction
# ---------------------------------------------------------------------------

def extract_spec_sections(spec_path: Path) -> dict[str, str]:
    """Return selected sections from docs/specs/<module>.md."""
    if not spec_path.exists():
        return {"tldr": "", "general_info": "", "summary": "", "files": ""}
    text = spec_path.read_text(encoding="utf-8")
    sections: dict[str, str] = {"tldr": "", "general_info": "", "summary": "", "files": ""}

    for key, heading in (("tldr", "TL;DR"), ("general_info", "General Info"), ("summary", "Summary"), ("files", "Files")):
        m = re.search(rf"## {re.escape(heading)}\s*\n(.*?)(?=\n## |\Z)", text, re.DOTALL)
        if m:
            sections[key] = m.group(1).strip()

    return sections


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
    module_fields: dict[str, list] = {}
    class_methods: dict[str, list] = {}
    class_fields: dict[str, list] = {}

    # Parse class field metadata from @class/@field blocks.
    for idx, line in enumerate(lines):
        cm = re.match(r'^---@class\s+(L\w+)', line)
        if not cm:
            continue
        class_name = cm.group(1)
        field_rows: list[dict] = []
        j = idx + 1
        while j < len(lines):
            fld = re.match(r'^---@field\s+(\S+)\s+(\S+)\s*(.*)', lines[j])
            if not fld:
                break
            field_rows.append({
                "name": fld.group(1),
                "type": fld.group(2),
                "description": fld.group(3).strip(),
            })
            j += 1
        if field_rows:
            class_fields[class_name] = field_rows

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

        # --- module field/constant: lurek.X.Y = <value>
        mfld = re.match(r'^(lurek\.(\w+)\.(\w+))\s*=\s*(.+)$', line)
        if mfld and "function(" not in line:
            full_name = mfld.group(1)
            module = mfld.group(2)
            field_name = mfld.group(3)
            value_expr = mfld.group(4).strip()
            # Skip module table init e.g. lurek.render = {}
            if value_expr == "{}":
                i += 1
                continue
            doc_lines = []
            j = i - 1
            while j >= 0 and (lines[j].startswith("---") or lines[j].strip() == ""):
                if lines[j].startswith("---"):
                    doc_lines.insert(0, lines[j])
                j -= 1
            entry = dict(
                name=field_name,
                full_name=full_name,
                value=value_expr,
                doc_lines=doc_lines,
            )
            module_fields.setdefault(module, []).append(entry)
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

    return module_fns, module_fields, class_methods, class_fields


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


def _type_anchor(type_name: str) -> str:
    return anchor_slug(type_name)


def _type_link(type_name: str, current_module: str, class_owner: dict[str, str], local_types: set[str]) -> str:
    if type_name in local_types:
        return f"[{type_name}](#{_type_anchor(type_name)})"
    owner = class_owner.get(type_name)
    if owner:
        return f"[{type_name}]({owner}.md#{_type_anchor(type_name)})"
    return type_name


def _link_lurek_types(text: str, *, current_module: str, class_owner: dict[str, str], local_types: set[str]) -> str:
    """Convert LType tokens into links to local or owning module type headers."""
    if not text:
        return ""

    def repl_md_link(match: re.Match[str]) -> str:
        token = match.group(1)
        return _type_link(token, current_module, class_owner, local_types)

    # Rewrite legacy absolute lua-docs class links first.
    text = re.sub(r"\[\s*(L[A-Z][A-Za-z0-9_]*)\s*\]\(\s*/lua-docs/classes/[A-Za-z0-9_]+\.html\s*\)", repl_md_link, text)

    def repl(match: re.Match[str]) -> str:
        token = match.group(0)
        return _type_link(token, current_module, class_owner, local_types)

    return re.sub(r"\bL[A-Z][A-Za-z0-9_]*\b", repl, text)


def format_params(params: list[str], *, current_module: str, class_owner: dict[str, str], local_types: set[str]) -> list[str]:
    """Format @param lines into a markdown table row."""
    rows = []
    for p in params:
        # @param name type? description
        m = re.match(r'@param\s+(\w+\??)\s+(\S+)\s*(.*)', p)
        if m:
            p_name = m.group(1)
            p_type = _link_lurek_types(m.group(2), current_module=current_module, class_owner=class_owner, local_types=local_types)
            p_desc = _link_lurek_types(m.group(3).strip(), current_module=current_module, class_owner=class_owner, local_types=local_types)
            rows.append(f"| `{p_name}` | {p_type} | {p_desc} |")
        else:
            rows.append(f"| — | — | {_link_lurek_types(p, current_module=current_module, class_owner=class_owner, local_types=local_types)} |")
    return rows


def format_returns(returns: list[str], *, current_module: str, class_owner: dict[str, str], local_types: set[str]) -> list[str]:
    rows = []
    for r in returns:
        m = re.match(r'@return\s+(\S+)\s*(.*)', r)
        if m:
            r_type = _link_lurek_types(m.group(1), current_module=current_module, class_owner=class_owner, local_types=local_types)
            r_desc = _link_lurek_types(m.group(2).strip(), current_module=current_module, class_owner=class_owner, local_types=local_types)
            rows.append(f"| {r_type} | {r_desc} |")
        else:
            rows.append(f"| — | {_link_lurek_types(r, current_module=current_module, class_owner=class_owner, local_types=local_types)} |")
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


def render_entry(entry: dict, examples: dict, *, current_module: str, class_owner: dict[str, str], local_types: set[str], heading_level: str = "###") -> list[str]:
    lines = []
    desc, params, returns = doc_to_parts(entry["doc_lines"])
    sig = render_signature(entry)

    lines.append(f"{heading_level} `{entry['full_name']}`")
    lines.append("")
    if desc:
        lines.append(_link_lurek_types(desc, current_module=current_module, class_owner=class_owner, local_types=local_types))
        lines.append("")

    lines.append(f"```lua")
    lines.append(f"{sig}")
    lines.append(f"```")
    lines.append("")

    if params:
        lines.append("**Parameters**")
        lines.append("")
        lines.append("| Name | Type | Description |")
        lines.append("|------|------|-------------|")
        lines.extend(format_params(params, current_module=current_module, class_owner=class_owner, local_types=local_types))
        lines.append("")

    if returns:
        lines.append("**Returns**")
        lines.append("")
        lines.append("| Type | Description |")
        lines.append("|------|-------------|")
        lines.extend(format_returns(returns, current_module=current_module, class_owner=class_owner, local_types=local_types))
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


def callback_rows(entry: dict) -> list[str]:
    """Extract callback parameter contracts from @param lines."""
    rows: list[str] = []
    _, params, _ = doc_to_parts(entry.get("doc_lines", []))
    for p in params:
        m = re.match(r'@param\s+(\w+\??)\s+(\S+)\s*(.*)', p)
        if not m:
            continue
        p_name, p_type, p_desc = m.group(1), m.group(2), m.group(3).strip()
        if "function" not in p_type.lower():
            continue
        rows.append(f"- `{entry['full_name']}` param `{p_name}` (`{p_type}`): {p_desc}")
    return rows


def anchor_slug(value: str) -> str:
    text = value.strip().lower()
    text = re.sub(r"[^a-z0-9\s-]", "", text)
    text = re.sub(r"\s+", "-", text)
    text = re.sub(r"-+", "-", text)
    return text.strip("-")


def load_module_enums() -> dict[str, list[dict]]:
    if not LUA_API_JSON.exists():
        return {}
    try:
        data = json.loads(LUA_API_JSON.read_text(encoding="utf-8"))
    except Exception:
        return {}
    modules = (data.get("lua_api", {}).get("modules", {}) or {})
    out: dict[str, list[dict]] = {}
    for module_name, module_data in modules.items():
        enums = module_data.get("enums") or []
        if enums:
            out[module_name] = [e for e in enums if isinstance(e, dict)]
    return out


def load_module_classes() -> dict[str, list[str]]:
    if not LUA_API_JSON.exists():
        return {}
    try:
        data = json.loads(LUA_API_JSON.read_text(encoding="utf-8"))
    except Exception:
        return {}

    modules = (data.get("lua_api", {}).get("modules", {}) or {})
    out: dict[str, list[str]] = {}
    for module_name, module_data in modules.items():
        classes = sorted((module_data.get("classes") or {}).keys())
        if classes:
            out[module_name] = classes
    return out


def build_page(
    module: str,
    module_fns: dict,
    module_fields: dict,
    class_methods: dict,
    class_fields: dict,
    module_enums: dict[str, list[dict]],
    module_classes: dict[str, list[str]],
    class_owner: dict[str, str],
) -> str:
    spec_path = SPECS_DIR / f"{module}.md"
    spec = extract_spec_sections(spec_path)
    summary_text = spec.get("summary", "")
    # Rust file descriptions are intentionally kept out of Lua module docs.
    examples = load_examples(module)

    # Which classes belong to this module? Prefer classes referenced by this
    # module's examples and docs.
    relevant_classes = set()
    for key in examples:
        # e.g. LImage:draw -> LImage
        m = re.match(r'(L\w+)[:.]', key)
        if m:
            relevant_classes.add(m.group(1))

    for f in module_fns.get(module, []):
        entry_desc, params, returns = doc_to_parts(f.get("doc_lines", []))
        for text in [entry_desc] + params + returns:
            for token in re.findall(r"\bL[A-Z][A-Za-z0-9_]*\b", text or ""):
                if token in class_methods:
                    relevant_classes.add(token)

    for cls in module_classes.get(module, []):
        relevant_classes.add(cls)

    # Keep only documented userdata types that actually expose fields or methods.
    relevant_classes = {
        cls for cls in relevant_classes
        if class_methods.get(cls) or class_fields.get(cls)
    }

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

    if summary_text:
        out.append("## Summary")
        out.append("")
        out.append(summary_text)
        out.append("")

    if not unique_fns and not relevant_classes and not module_enums.get(module):
        out.append("*No public API documented yet.*")
        return "\n".join(out)

    local_types = set(relevant_classes)

    out.append("## Functions")
    out.append("")
    if unique_fns:
        for entry in sorted(unique_fns, key=lambda e: e["name"]):
            out.extend(render_entry(entry, examples, current_module=module, class_owner=class_owner, local_types=local_types))
    else:
        out.append("*No standalone module functions documented.*")
        out.append("")

    out.append("## Module Fields")
    out.append("")
    module_field_entries = module_fields.get(module, [])
    if module_field_entries:
        for entry in sorted(module_field_entries, key=lambda e: e["name"]):
            desc, _, _ = doc_to_parts(entry.get("doc_lines", []))
            out.append(f"### `{entry['full_name']}`")
            out.append("")
            if desc:
                out.append(_link_lurek_types(desc, current_module=module, class_owner=class_owner, local_types=local_types))
                out.append("")
            out.append("```lua")
            out.append(f"{entry['full_name']} = {entry.get('value', '')}")
            out.append("```")
            out.append("")
            out.append("---")
            out.append("")
    else:
        out.append("*No module-level fields documented.*")
        out.append("")

    out.append("## Callbacks")
    out.append("")
    callback_lines = []
    for entry in sorted(unique_fns, key=lambda e: e["name"]):
        callback_lines.extend(callback_rows(entry))
    if callback_lines:
        out.extend(callback_lines)
    else:
        out.append("*No callback parameters documented in this module.*")
    out.append("")

    out.append("## Enums")
    out.append("")
    enums = module_enums.get(module, [])
    if enums:
        for enum in sorted(enums, key=lambda e: e.get("name", "")):
            e_name = enum.get("name", "<enum>")
            e_desc = enum.get("description", "")
            out.append(f"### `{e_name}`")
            if e_desc:
                out.append("")
                out.append(_link_lurek_types(e_desc, current_module=module, class_owner=class_owner, local_types=local_types))
            values = enum.get("values") or []
            if values:
                out.append("")
                out.append("- Values: " + ", ".join(f"`{v}`" for v in values))
            out.append("")
    else:
        out.append("*No module-specific enums documented.*")
    out.append("")

    out.append("## Types")
    out.append("")
    if relevant_classes:
        for cls in sorted(relevant_classes):
            out.append(f"- [{cls}](#{_type_anchor(cls)})")
    else:
        out.append("*No Lua userdata types detected for this module.*")
    out.append("")

    # Type-level blocks.
    for cls in sorted(relevant_classes):
        out.append(f"## {cls}")
        out.append("")

        out.append("### Type Fields")
        out.append("")
        fields = class_fields.get(cls, [])
        if fields:
            out.append("| Name | Type | Description |")
            out.append("|------|------|-------------|")
            for field in fields:
                f_name = field.get("name", "")
                f_type = _link_lurek_types(field.get("type", "any"), current_module=module, class_owner=class_owner, local_types=local_types)
                f_desc = _link_lurek_types(field.get("description", ""), current_module=module, class_owner=class_owner, local_types=local_types)
                out.append(f"| `{f_name}` | {f_type} | {f_desc} |")
            out.append("")
        else:
            out.append("*No documented fields for this handle.*")
            out.append("")

        out.append("### Type Methods")
        out.append("")
        methods = class_methods.get(cls, [])
        if methods:
            seen_m = set()
            for entry in sorted(methods, key=lambda e: e["name"]):
                if entry["full_name"] in seen_m:
                    continue
                seen_m.add(entry["full_name"])
                out.extend(render_entry(entry, examples, current_module=module, class_owner=class_owner, local_types=local_types, heading_level="####"))
        else:
            out.append("*No documented methods for this handle.*")
            out.append("")

    return "\n".join(out)


def build_callbacks_page() -> str:
    spec = extract_spec_sections(SPECS_DIR / "callbacks.md")
    general_info = (spec.get("general_info") or "").strip()
    summary = (spec.get("summary") or "").strip()

    callbacks = []
    if LUA_API_JSON.exists():
        try:
            data = json.loads(LUA_API_JSON.read_text(encoding="utf-8"))
            callbacks = sorted(data.get("engine_callbacks", []) or [], key=lambda c: c.get("name", ""))
        except Exception:
            callbacks = []

    out: list[str] = []
    out.append("# Callback Hooks")
    out.append("")

    out.append("## General Info")
    out.append("")
    out.append(general_info if general_info else "*No `General Info` section found in callbacks spec.*")
    out.append("")

    out.append("## Summary")
    out.append("")
    out.append(summary if summary else "*No `Summary` section found in callbacks spec.*")
    out.append("")

    out.append("## Callback Inventory")
    out.append("")
    if callbacks:
        for cb in callbacks:
            name = cb.get("name", "")
            sig = cb.get("signature", "")
            desc = cb.get("description", "")
            out.append(f"- `lurek.{name}` — `{sig}`")
            if desc:
                out.append(f"  - {desc}")
    else:
        out.append("*No callbacks found in `logs/data/lua_api_data.json`.*")
    out.append("")

    out.append("## Callback Details")
    out.append("")
    if callbacks:
        for cb in callbacks:
            name = cb.get("name", "")
            sig = cb.get("signature", "")
            desc = cb.get("description", "")
            params = cb.get("parameters", []) or []

            out.append(f"### `lurek.{name}`")
            out.append("")
            if desc:
                out.append(desc)
                out.append("")
            if sig:
                out.append("```lua")
                out.append(sig)
                out.append("```")
                out.append("")

            if params:
                out.append("#### Parameters")
                out.append("")
                out.append("| Name | Type | Description |")
                out.append("|------|------|-------------|")
                for p in params:
                    pname = p.get("name", "")
                    ptype = p.get("type", "any")
                    pdesc = p.get("description", "")
                    optional = p.get("optional", False)
                    if optional and not str(pname).endswith("?"):
                        pname = f"{pname}?"
                    out.append(f"| `{pname}` | {ptype} | {pdesc} |")
                out.append("")
            else:
                out.append("#### Parameters")
                out.append("")
                out.append("*No parameters.*")
                out.append("")
    else:
        out.append("*No callback details available.*")
        out.append("")

    out.append("## Sources")
    out.append("")
    out.append("- [Spec callbacks](specs/callbacks.md)")
    out.append("- [Generated API (Markdown)](api/lurek.md)")
    out.append("")

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
    module_fns, module_fields, class_methods, class_fields = parse_stub(STUB_FILE)
    module_enums = load_module_enums()
    module_classes = load_module_classes()
    class_owner: dict[str, str] = {}
    for mod_name, classes in module_classes.items():
        for cls in classes:
            class_owner[cls] = mod_name

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    generated = []
    for module in targets:
        if module not in module_fns:
            # Still generate if spec or examples exist
            if not (SPECS_DIR / f"{module}.md").exists() and not (EXAMPLES_DIR / f"{module}.lua").exists():
                continue

        page = build_page(
            module,
            module_fns,
            module_fields,
            class_methods,
            class_fields,
            module_enums,
            module_classes,
            class_owner,
        )
        out_file = OUT_DIR / f"{module}.md"
        out_file.write_text(page, encoding="utf-8")
        fn_count = len(module_fns.get(module, []))
        print(f"  {module}.md  ({fn_count} functions)")
        generated.append(module)

    print(f"\nDone — {len(generated)} Lua module pages in {OUT_DIR}")

    callbacks_md = build_callbacks_page()
    CALLBACKS_MD.write_text(callbacks_md, encoding="utf-8")
    print("Updated docs/api/callbacks.md from callbacks spec/json")

    return generated


if __name__ == "__main__":
    main()
