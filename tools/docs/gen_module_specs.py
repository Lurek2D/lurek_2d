#!/usr/bin/env python3
"""Generate merged docs/specs/<module>.md files for top-level src modules.

This tool treats docs/specs/<module>.md as the canonical long-form module
reference. During the AGENT.md retirement migration it can seed missing manual
content from src/<module>/AGENT.md or src/<module>/AGENT.legacy.md, but after
that transition it continues to work from the existing spec plus source code.

Manual sections preserved from the existing spec when present:
- TL;DR
- Summary

Auto-collected sections rebuilt from source code and Lua binding data:
- General Info
- References
- Files
- Callbacks (when the module owns global engine callback contracts)
- Lua API Reference
- Notes

Usage:
```
usage: gen_module_specs.py [-h] [--module MODULE]

Generate merged docs/specs/*.md files for top-level src modules.

options:
  -h, --help       show this help message and exit
  --module MODULE  Only generate the named module (can be repeated).

Examples:
  # Default execution
  python tools/docs/gen_module_specs.py

  # Show all arguments
  python tools/docs/gen_module_specs.py --help
```
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Optional


ROOT = Path(__file__).resolve().parent.parent.parent
SRC = ROOT / "src"
SPECS = ROOT / "docs" / "specs"
README = SPECS / "README.md"
SESSION_DATA = ROOT / "work" / "module-specs-20260411" / "data" / "module_inventory.json"


GROUPS = {
    "Foundations": {
        "math",
        "log",
        "data",
        "serialize",
        "compute",
        "dataframe",
        "graph",
        "procgen",
        "patterns",
    },
    "Core Runtime": {
        "runtime",
        "event",
        "timer",
        "thread",
        "network",
        "filesystem",
    },
    "Platform Services": {
        "render",
        "audio",
        "physics",
        "input",
        "image",
        "window",
        "camera",
        "light",
        "effect",
    },
    "Feature Systems": {
        "ecs",
        "scene",
        "animation",
        "tween",
        "particle",
        "tilemap",
        "parallax",
        "minimap",
        "raycaster",
        "ui",
        "terminal",
        "ai",
        "pathfind",
        "save",
        "mods",
        "i18n",
        "automation",
        "sprite",
        "spine",
        "globe",
    },
    "Edge/Integration": {
        "app",
        "lua_api",
        "devtools",
        "debugbridge",
        "docs",
        "pipeline",
        "bin",
    },
}


SECTION_ALIASES = {
    "general_info": ["General Info", "Module Info"],
    "summary": ["Summary", "Module Purpose", "Purpose"],
    "source_docs": ["Source Documentation", "File Descriptions"],
    "types": ["Types", "Key Types"],
    "functions": ["Methods", "Functions"],
    "lua_api": ["Lua API Ref", "Lua API Reference", "Lua API", "Lua API Summary"],
    "references": ["Imports", "References"],
    "notes": ["Notes", "Constraints"],
    "tldr": ["TL;DR"],
}


USE_RE = re.compile(r"(?:use\s+crate::|crate::)([A-Za-z_][A-Za-z0-9_]*)")
TYPE_RE = re.compile(
    r'^\s*pub(?:\([^)]*\))?\s+'
    r'(?:unsafe\s+|async\s+|const\s+|extern\s+"[^\"]*"\s+)?'
    r'(struct|enum|trait|type)\s+([A-Za-z_][A-Za-z0-9_]*)'
)
FUNCTION_RE = re.compile(
    r'^\s*pub(?:\([^)]*\))?\s+'
    r'(?:unsafe\s+|async\s+|const\s+)?fn\s+([A-Za-z_][A-Za-z0-9_]*)'
)
IMPL_RE = re.compile(
    r'^\s*impl(?:<[^>{}]+>)?\s+'
    r'(?:(?:[A-Za-z_][A-Za-z0-9_:<>]+)\s+for\s+)?'
    r'([A-Za-z_][A-Za-z0-9_:<>]*)'
)
PUB_FIELD_RE = re.compile(
    r'^\s*pub(?:\([^)]*\))?\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^,]+),?'
)
ENUM_VARIANT_RE = re.compile(
    r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:\(|\{|=|,|$)'
)
SET_RE = re.compile(r'\b(?:lurek|lurek)\.set\(\s*"([^\"]+)"')
LUA_API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"

# Some Lua API bindings are grouped under legacy/top-level names that do not
# match docs/specs module stems. Merge them into the target spec module.
LUA_API_MODULE_ALIASES: dict[str, list[str]] = {
    "runtime": ["system", "engine"],
    "vector": ["svg"],
}


# `lua_api` is a thin wrapper layer and should not have a standalone module
# spec; callback contracts are documented in docs/specs/callbacks.md generated
# from engine callback metadata.
MODULE_SPEC_EXCLUDE = {"lua_api"}
SPECIAL_SPECS = ["callbacks"]


def load_lua_parser():
    spec = importlib.util.spec_from_file_location(
        "gen_lua_api", ROOT / "tools" / "docs" / "gen_lua_api.py"
    )
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def module_group(module: str) -> str:
    for group, modules in GROUPS.items():
        if module in modules:
            return group
    return "Edge/Integration"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig") if path.exists() else ""


def normalize_space(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def clean_doc_text(text: str) -> str:
    text = text.replace("```", " ")
    text = re.split(r"\s+#\s+(?:Fields|Variants|Returns|Parameters)\b", text, maxsplit=1)[0]
    text = normalize_space(text)
    if not text:
        return ""
    sentence_match = re.match(r"(.{1,280}?[.!?])(?:\s|$)", text)
    if sentence_match:
        return sentence_match.group(1).strip()
    return text[:280].rstrip()


def split_section(text: str, heading: str) -> str:
    pattern = re.compile(rf"^##\s+{re.escape(heading)}\s*$", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return ""
    start = match.end()
    rest = text[start:]
    next_heading = re.search(r"^##\s+", rest, re.MULTILINE)
    if next_heading:
        rest = rest[: next_heading.start()]
    rest = re.sub(r"(^|\n)---+\s*(?=\n|$)", "\n", rest)
    return rest.strip()


def parse_doc_sections(text: str) -> dict[str, str]:
    sections: dict[str, str] = {}
    for key, aliases in SECTION_ALIASES.items():
        sections[key] = ""
        for alias in aliases:
            body = split_section(text, alias)
            if body:
                sections[key] = body
                break
    return sections


def normalize_pair_key(text: str) -> str:
    key = text.strip().strip("`")
    key = re.sub(r"\s+\([^)]*\)$", "", key)
    key = key.strip().strip("`")
    return key


def parse_bullet_pairs(section: str) -> dict[str, str]:
    items: dict[str, str] = {}
    for line in section.splitlines():
        stripped = line.strip()
        if not stripped.startswith("- "):
            continue
        body = stripped[2:]
        if ":" in body:
            left, right = body.split(":", 1)
        elif " - " in body:
            left, right = body.split(" - ", 1)
        else:
            continue
        key = normalize_pair_key(left)
        value = right.strip()
        if key and value:
            items[key] = value
    return items


def parse_markdown_table(section: str) -> dict[str, str]:
    items: dict[str, str] = {}
    for line in section.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|"):
            continue
        cells = [c.strip() for c in stripped.strip("|").split("|")]
        if len(cells) < 2:
            continue
        if set(cells[0]) == {"-"}:
            continue
        header = cells[0].lower()
        if header in {"file", "type", "function", "method", "module", "property", "kind"}:
            continue
        key = normalize_pair_key(cells[0])
        value = cells[1].strip()
        if key and value:
            items[key] = value
    return items


def parse_section_pairs(section: str) -> dict[str, str]:
    merged = parse_markdown_table(section)
    merged.update(parse_bullet_pairs(section))
    return merged


def collect_doc_above(lines: list[str], index: int) -> str:
    docs: list[str] = []
    j = index - 1
    while j >= 0:
        stripped = lines[j].strip()
        if stripped.startswith("///"):
            docs.insert(0, stripped[3:].lstrip())
        elif stripped.startswith("#") or stripped == "":
            pass
        else:
            break
        j -= 1
    return clean_doc_text(" ".join(docs))


def first_module_doc_line(lines: list[str]) -> str:
    parts: list[str] = []
    for raw in lines:
        stripped = raw.strip()
        if stripped.startswith("//!"):
            parts.append(stripped[3:].lstrip())
        elif parts:
            break
    return clean_doc_text(" ".join(parts))


def collect_all_file_docs(lines: list[str]) -> list[str]:
    """Collect all //! doc lines from the top of a file as individual bullet points."""
    docs: list[str] = []
    for raw in lines:
        stripped = raw.strip()
        if stripped.startswith("//!"):
            content = stripped[3:].strip()
            if content:
                if content.startswith("@engine-callback |") or content.startswith("@engine-param |"):
                    continue
                # Strip leading '- ' if present to normalize
                if content.startswith("- "):
                    content = content[2:]
                docs.append(content)
        elif docs:
            break
        elif stripped and not stripped.startswith("//"):
            break
    return docs


def normalize_impl_target(raw: str) -> str:
    target = raw.split("<", 1)[0].strip().rstrip("{")
    return target.split("::")[-1]


def extract_public_struct_fields(lines: list[str], start_index: int) -> list[str]:
    start_line = lines[start_index]
    if "{" not in start_line:
        return []

    fields: list[str] = []
    depth = start_line.count("{") - start_line.count("}")
    i = start_index + 1
    while i < len(lines) and depth > 0:
        line = lines[i]
        stripped = line.strip()
        if depth == 1 and stripped and not stripped.startswith("//") and not stripped.startswith("#"):
            match = PUB_FIELD_RE.match(line)
            if match:
                field_name = match.group(1)
                field_type = normalize_space(match.group(2))
                fields.append(f"{field_name}: {field_type}")
        depth += line.count("{") - line.count("}")
        i += 1
    return fields


def extract_enum_variants(lines: list[str], start_index: int) -> list[str]:
    start_line = lines[start_index]
    if "{" not in start_line:
        return []

    variants: list[str] = []
    depth = start_line.count("{") - start_line.count("}")
    i = start_index + 1
    while i < len(lines) and depth > 0:
        line = lines[i]
        stripped = line.strip()
        if depth == 1 and stripped and not stripped.startswith("//") and not stripped.startswith("#"):
            match = ENUM_VARIANT_RE.match(stripped)
            if match:
                variant = match.group(1)
                if variant != "pub":
                    variants.append(variant)
        depth += line.count("{") - line.count("}")
        i += 1
    return variants


def scan_module_sources(module: str) -> dict:
    module_dir = SRC / module
    file_info = []
    file_docs: dict[str, list[str]] = {}
    types_by_file: dict[str, list[dict]] = defaultdict(list)
    functions_by_file: dict[str, list[dict]] = defaultdict(list)
    refs: set[str] = set()
    counts = {"struct": 0, "enum": 0, "function": 0}

    for path in sorted(module_dir.rglob("*.rs")):
        rel = path.relative_to(module_dir).as_posix()
        lines = read_text(path).splitlines()
        purpose = first_module_doc_line(lines)
        all_docs = collect_all_file_docs(lines)
        if all_docs:
            file_docs[rel] = all_docs
        if not purpose:
            for idx, line in enumerate(lines):
                if TYPE_RE.match(line) or FUNCTION_RE.match(line):
                    purpose = collect_doc_above(lines, idx)
                    break
        file_info.append({"file": rel, "purpose": purpose or "Public API and internal module logic."})

        brace_depth = 0
        pending_impl: Optional[str] = None
        impl_stack: list[dict[str, object]] = []

        for idx, line in enumerate(lines):
            stripped = line.strip()
            is_comment = stripped.startswith("//")

            if not is_comment:
                impl_match = IMPL_RE.match(line)
                if impl_match:
                    pending_impl = normalize_impl_target(impl_match.group(1))

                type_match = TYPE_RE.match(line)
                if type_match:
                    kind, name = type_match.group(1), type_match.group(2)
                    desc = collect_doc_above(lines, idx)
                    fields = extract_public_struct_fields(lines, idx) if kind == "struct" else []
                    variants = extract_enum_variants(lines, idx) if kind == "enum" else []
                    types_by_file[rel].append(
                        {
                            "kind": kind,
                            "name": name,
                            "description": desc,
                            "qualified": f"{module}::{Path(rel).stem}::{name}",
                            "fields": fields,
                            "variants": variants,
                            "methods": [],
                        }
                    )
                    if kind in counts:
                        counts[kind] += 1

                fn_match = FUNCTION_RE.match(line)
                if fn_match:
                    fn_name = fn_match.group(1)
                    desc = collect_doc_above(lines, idx)
                    owner = impl_stack[-1]["name"] if impl_stack else None
                    label = f"{owner}::{fn_name}" if owner else fn_name
                    functions_by_file[rel].append(
                        {
                            "name": label,
                            "short_name": fn_name,
                            "owner": owner,
                            "description": desc,
                            "qualified": f"{module}::{Path(rel).stem}::{label}",
                        }
                    )
                    counts["function"] += 1

                for ref in USE_RE.findall(line):
                    if ref != module and (SRC / ref).is_dir():
                        refs.add(ref)

            opens = line.count("{")
            closes = line.count("}")
            if pending_impl and opens > closes:
                impl_stack.append({"name": pending_impl, "depth": brace_depth + opens - closes})
                pending_impl = None
            brace_depth += opens - closes
            while impl_stack and brace_depth < int(impl_stack[-1]["depth"]):
                impl_stack.pop()

    methods_by_owner: dict[str, list[dict]] = defaultdict(list)
    for items in functions_by_file.values():
        for fn in items:
            owner = fn.get("owner")
            if owner:
                methods_by_owner[owner].append(
                    {
                        "name": fn["short_name"],
                        "description": fn["description"],
                    }
                )

    for items in types_by_file.values():
        for item in items:
            owner_methods = methods_by_owner.get(item["name"], [])
            item["methods"] = sorted(owner_methods, key=lambda m: m["name"])

    return {
        "files": file_info,
        "file_docs": file_docs,
        "types_by_file": types_by_file,
        "functions_by_file": functions_by_file,
        "references": sorted(refs),
        "counts": counts,
    }


def collect_lua_api(module: str, lua_parser, seed_texts: list[str]) -> dict:
    module_functions = []
    classes: dict[str, dict] = {}
    module_enums: list[dict] = []
    module_constants: list[dict] = []
    namespace_prefixes: list[str] = []
    global_callbacks: list[dict] = []

    if LUA_API_JSON.exists():
        data = json.loads(read_text(LUA_API_JSON))
        all_modules = (data.get("lua_api", {}).get("modules", {}) or {})
        if module in {"app", "lua_api"}:
            global_callbacks = data.get("engine_callbacks") or []
        module_names = [module] + LUA_API_MODULE_ALIASES.get(module, [])

        for module_name in module_names:
            module_data = all_modules.get(module_name, {})

            for fn in module_data.get("functions", []) or []:
                lua_name = fn.get("lua_name") or fn.get("name")
                if lua_name and "." in lua_name:
                    namespace_prefixes.append(lua_name.rsplit(".", 1)[0])
                module_functions.append(
                    {
                        "name": fn.get("name") or "",
                        "lua_name": lua_name,
                        "description": fn.get("description") or "Lua-facing function documented in the binding source.",
                        "full_doc": fn.get("full_doc") or "",
                        "typed_params": fn.get("typed_params") or [],
                        "inferred_sig": fn.get("inferred_sig") or "",
                        "inferred_return": fn.get("inferred_return") or "",
                        "returns_doc": fn.get("returns_doc") or "",
                        "return_description": fn.get("return_description") or "",
                    }
                )

            for cls_name, cls in (module_data.get("classes") or {}).items():
                fields = []
                for field in cls.get("fields", []) or []:
                    fields.append(
                        {
                            "name": field.get("name") or "",
                            "type": field.get("type") or "any",
                            "description": field.get("description") or "Lua-visible field.",
                        }
                    )

                methods = []
                for method in cls.get("methods", []) or []:
                    methods.append(
                        {
                            "name": method.get("name") or "",
                            "lua_name": method.get("lua_name") or f"{cls_name}:{method.get('name','')}",
                            "description": method.get("description") or "Lua-visible method.",
                            "full_doc": method.get("full_doc") or "",
                            "typed_params": method.get("typed_params") or [],
                            "inferred_sig": method.get("inferred_sig") or "",
                            "inferred_return": method.get("inferred_return") or "",
                            "returns_doc": method.get("returns_doc") or "",
                            "return_description": method.get("return_description") or "",
                        }
                    )

                if cls_name in classes:
                    existing = classes[cls_name]
                    existing_fields = {f.get("name", ""): f for f in existing.get("fields", [])}
                    for field in fields:
                        key = field.get("name", "")
                        if key and key not in existing_fields:
                            existing_fields[key] = field
                    existing["fields"] = sorted(existing_fields.values(), key=lambda item: item["name"])

                    existing_methods = {(m.get("lua_name") or m.get("name") or ""): m for m in existing.get("methods", [])}
                    for method in methods:
                        key = method.get("lua_name") or method.get("name") or ""
                        if key and key not in existing_methods:
                            existing_methods[key] = method
                    existing["methods"] = sorted(existing_methods.values(), key=lambda item: item["name"])
                else:
                    classes[cls_name] = {
                        "description": cls.get("description") or "Lua-visible object type.",
                        "fields": fields,
                        "methods": methods,
                    }

            # Optional module-scoped constants/enums if present in source JSON shape.
            for const in module_data.get("constants", []) or []:
                module_constants.append(
                    {
                        "name": const.get("name") or "",
                        "value": const.get("value"),
                        "description": const.get("description") or "Lua-visible constant.",
                    }
                )
            for enum in module_data.get("enums", []) or []:
                module_enums.append(
                    {
                        "name": enum.get("name") or "",
                        "values": enum.get("values") or [],
                        "description": enum.get("description") or "Lua-visible enum.",
                    }
                )
    else:
        # Fallback for environments without generated JSON.
        all_functions = lua_parser.collect_all_functions(ROOT / "src" / "lua_api")
        funcs = all_functions.get(module, [])
        for fn in funcs:
            if fn.lua_name and "." in fn.lua_name:
                namespace_prefixes.append(fn.lua_name.rsplit(".", 1)[0])
            entry = {
                "name": fn.name,
                "lua_name": fn.lua_name,
                "description": fn.description or "Lua-facing function documented in the binding source.",
                "typed_params": [],
                "inferred_sig": "",
                "inferred_return": "",
                "returns_doc": "",
                "return_description": "",
            }
            if fn.kind == "function":
                module_functions.append(entry)
            else:
                owner = fn.owner_type or "Object"
                if owner not in classes:
                    classes[owner] = {"description": "Lua-visible object type.", "fields": [], "methods": []}
                classes[owner]["methods"].append(entry)

    namespace = namespace_prefixes[0] if namespace_prefixes else ""
    for text in seed_texts:
        if not text:
            continue
        for pattern in [
            r"`(lurek\.[A-Za-z0-9_.]+)`",
            r"Namespace:\s*`(lurek\.[A-Za-z0-9_.]+)`",
            r"Primary Lua namespace:\s*`(lurek\.[A-Za-z0-9_.]+)`",
        ]:
            match = re.search(pattern, text)
            if match:
                namespace = match.group(1)
                break
        if namespace:
            break

    api_file = ROOT / "src" / "lua_api" / f"{module}_api.rs"
    api_dir = ROOT / "src" / "lua_api" / f"{module}_api"
    if not namespace and api_file.exists():
        match = SET_RE.search(read_text(api_file))
        if match:
            namespace = f"lurek.{match.group(1)}"

    binding_path = ""
    if api_file.exists():
        binding_path = api_file.relative_to(ROOT).as_posix()
    elif api_dir.is_dir():
        binding_path = api_dir.relative_to(ROOT).as_posix() + "/"

    return {
        "namespace": namespace,
        "binding_path": binding_path,
        "module_functions": sorted(module_functions, key=lambda item: item["lua_name"] or item["name"]),
        "module_constants": sorted(module_constants, key=lambda item: item["name"]),
        "module_enums": sorted(module_enums, key=lambda item: item["name"]),
        "global_callbacks": sorted(global_callbacks, key=lambda item: item.get("name", "")),
        "classes": {
            k: {
                "description": v.get("description") or "Lua-visible object type.",
                "fields": sorted(v.get("fields", []), key=lambda item: item["name"]),
                "methods": sorted(v.get("methods", []), key=lambda item: item["name"]),
            }
            for k, v in sorted(classes.items())
        },
    }


def extract_field_entries_from_full_doc(full_doc: str) -> list[dict[str, str]]:
    """Extract @field entries from a docstring in pipe-tag format."""
    if not full_doc:
        return []

    entries: list[dict[str, str]] = []
    for raw_line in full_doc.splitlines():
        line = raw_line.strip()
        match = re.match(r"^@field\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(.+)$", line)
        if match:
            entries.append(
                {
                    "name": match.group(1).strip(),
                    "type": match.group(2).strip(),
                    "description": match.group(3).strip(),
                }
            )
    return entries


def derive_generated_result_class_name(lua_name: str) -> str:
    """Derive a stable result-class name from a Lua function/method name."""
    if ":" in lua_name:
        owner, method = lua_name.split(":", 1)
        base = owner + method[:1].upper() + method[1:] + "Result"
    elif "." in lua_name:
        parts = lua_name.split(".")
        tail = parts[-2:] if len(parts) >= 2 else parts
        base = "".join(p[:1].upper() + p[1:] for p in tail) + "Result"
    else:
        base = lua_name[:1].upper() + lua_name[1:] + "Result"

    if base.startswith("L") and len(base) > 1 and base[1].isupper():
        return base
    return f"L{base}"


def merge_generated_result_classes(lua_api: dict) -> None:
    """Add synthetic result classes derived from @field tags on functions/methods."""
    classes = lua_api.get("classes") or {}

    def add_or_merge(class_name: str, fields: list[dict[str, str]]) -> None:
        if class_name not in classes:
            classes[class_name] = {
                "description": "Generated result shape from @field tags.",
                "fields": [],
                "methods": [],
            }

        existing = {f.get("name"): f for f in classes[class_name].get("fields", [])}
        for field in fields:
            field_name = field.get("name", "").strip()
            if not field_name:
                continue
            if field_name not in existing:
                existing[field_name] = {
                    "name": field_name,
                    "type": field.get("type", "any").strip() or "any",
                    "description": field.get("description", "").strip() or "Lua-visible field.",
                }

        classes[class_name]["fields"] = sorted(existing.values(), key=lambda item: item["name"])

    for fn in lua_api.get("module_functions", []):
        lua_name = (fn.get("lua_name") or fn.get("name") or "").strip()
        if not lua_name:
            continue
        fields = extract_field_entries_from_full_doc(fn.get("full_doc") or "")
        if fields:
            add_or_merge(derive_generated_result_class_name(lua_name), fields)

    for class_name, class_data in list(classes.items()):
        for method in class_data.get("methods", []):
            lua_name = (method.get("lua_name") or "").strip()
            if not lua_name:
                method_name = (method.get("name") or "").strip()
                lua_name = f"{class_name}:{method_name}" if method_name else ""
            if not lua_name:
                continue
            fields = extract_field_entries_from_full_doc(method.get("full_doc") or "")
            if fields:
                add_or_merge(derive_generated_result_class_name(lua_name), fields)

    lua_api["classes"] = dict(sorted(classes.items()))


def normalize_info_key(key: str) -> str:
    lowered = key.lower().replace("`", "")
    lowered = re.sub(r"[^a-z0-9]+", " ", lowered)
    return normalize_space(lowered)


def build_info_maps(spec_text: str, spec_sections: dict[str, str], agent_text: str, agent_sections: dict[str, str], legacy_text: str) -> list[dict[str, str]]:
    maps = [
        parse_section_pairs(spec_sections["general_info"]),
        parse_section_pairs(agent_sections["general_info"]),
        parse_markdown_table(spec_text),
        parse_markdown_table(agent_text),
        parse_markdown_table(legacy_text),
    ]
    normalized_maps: list[dict[str, str]] = []
    for info_map in maps:
        normalized_maps.append({normalize_info_key(k): v for k, v in info_map.items()})
    return normalized_maps


def lookup_info(info_maps: list[dict[str, str]], *labels: str) -> str:
    normalized_labels = [normalize_info_key(label) for label in labels]
    for info_map in info_maps:
        for label in normalized_labels:
            if label in info_map:
                return info_map[label]
    return ""


def combine_pair_maps(*sections: str) -> dict[str, str]:
    merged: dict[str, str] = {}
    for section in sections:
        for key, value in parse_section_pairs(section).items():
            merged.setdefault(key, value)
    return merged


def first_non_empty(*values: str) -> str:
    for value in values:
        if value and value.strip():
            return value.strip()
    return ""


def strip_backticks(text: str) -> str:
    return text.replace("`", "").strip()


def build_scope_boundary(module: str, refs: list[str], group: str) -> str:
    if refs:
        ref_text = ", ".join(f"`{ref}`" for ref in refs[:8])
        if len(refs) > 8:
            ref_text += ", and adjacent engine modules"
        return (
            f"This module primarily collaborates with {ref_text}. "
            f"Its responsibility should stay inside the {group} group rather than absorb behavior owned by those neighbors."
        )
    return (
        f"This module is mostly self-contained inside the {group} group. "
        "Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here."
    )


def resolve_item_description(overrides: dict[str, str], *keys: str, fallback: str) -> str:
    for key in keys:
        normalized = normalize_pair_key(key)
        if normalized in overrides:
            return overrides[normalized]
    return fallback


def format_general_info(module: str, group: str, rust_tests: str, lua_tests: str, lua_api: dict) -> str:
    lua_paths = f"`{lua_api['binding_path']}`" if lua_api["binding_path"] else "None direct"
    namespace = f"`{lua_api['namespace']}`" if lua_api["namespace"] else "None direct"
    function_count = len(lua_api.get("module_functions", []))
    type_count = len(lua_api.get("classes", {}))
    method_count = sum(len(meta.get("methods", [])) for meta in lua_api.get("classes", {}).values())
    return "\n".join(
        [
            f"- Module group: `{strip_backticks(group)}`",
            f"- Source path: `src/{module}/`",
            f"- Binding: {lua_paths}",
            f"- Namespace: {namespace}",
            f"- Lua API surface: `{function_count}` functions, `{type_count}` types, `{method_count}` methods",
            f"- Rust test path(s): {strip_backticks(rust_tests) or 'None found in the workspace'}",
            f"- Lua test path(s): {strip_backticks(lua_tests) or 'None found in the workspace'}",
        ]
    )


def format_files(file_rows: list[dict], overrides: dict[str, str]) -> str:
    lines = []
    for row in file_rows:
        lines.extend([f"### {row['file']}", ""])
        doc_lines = row.get("doc_lines") or []
        if doc_lines:
            for doc_line in doc_lines:
                lines.append(f"- {doc_line}")
        else:
            desc = resolve_item_description(overrides, row["file"], fallback=row["purpose"])
            lines.append(f"- {desc}")
        lines.append("")
    return "\n".join(lines).strip()


def format_callback_line(cb: dict) -> str:
    name = cb.get("name") or "<callback>"
    signature = cb.get("signature") or f"function lurek.{name}()"
    signature = re.sub(r"^\s*function\s+", "", signature).strip()
    description = cb.get("description") or "Engine callback."
    return_type = "boolean?" if re.search(r"\breturn true\b", description, flags=re.IGNORECASE) else "nil"
    return f"- `{signature} -> {return_type}`: {description}"


def format_global_callbacks(callbacks: list[dict]) -> str:
    if not callbacks:
        return "- No global engine callback metadata was found for this module."

    lines: list[str] = []
    for cb in callbacks:
        lines.append(format_callback_line(cb))
    return "\n".join(lines)


def format_source_docs(file_docs: dict[str, list[str]]) -> str:
    """Unused in current output layout; retained as helper for future migrations."""
    if not file_docs:
        return ""
    lines: list[str] = []
    for rel_path, docs in sorted(file_docs.items()):
        lines.append(f"### `{rel_path}`")
        for doc in docs:
            lines.append(f"- {doc}")
        lines.append("")
    return "\n".join(lines).rstrip()


def format_types(module: str, file_rows: list[dict], types_by_file: dict[str, list[dict]], overrides: dict[str, str]) -> str:
    lines: list[str] = []
    for row in file_rows:
        for item in types_by_file.get(row["file"], []):
            desc = resolve_item_description(
                overrides,
                item["qualified"],
                f"{Path(row['file']).stem}::{item['name']}",
                item["name"],
                fallback=item["description"] or f"Public {item['kind']} in `{row['file']}`.",
            )
            desc = re.split(r"\s+Details:\s+", desc, maxsplit=1)[0].strip()
            detail_parts: list[str] = []
            if item.get("fields"):
                detail_parts.append("fields: " + ", ".join(item["fields"]))
            if item.get("variants"):
                detail_parts.append("variants: " + ", ".join(item["variants"]))
            if item.get("methods"):
                method_labels = [
                    f"{m['name']} ({m['description'] or 'public method'})" for m in item["methods"]
                ]
                detail_parts.append("methods: " + "; ".join(method_labels))
            details = f" Details: {' | '.join(detail_parts)}" if detail_parts else ""
            lines.append(f"- `{item['name']}` (`{item['kind']}`, `{row['file']}`): {desc}{details}")
    if not lines:
        return "- No public Rust types are currently exposed from this module."
    return "\n".join(lines)


def format_functions(module: str, file_rows: list[dict], functions_by_file: dict[str, list[dict]], overrides: dict[str, str]) -> str:
    lines: list[str] = []
    for row in file_rows:
        for item in functions_by_file.get(row["file"], []):
            desc = resolve_item_description(
                overrides,
                item["qualified"],
                f"{Path(row['file']).stem}::{item['name']}",
                item["name"],
                fallback=item["description"] or f"Public function or method declared in `{row['file']}`.",
            )
            desc = re.split(r"\s+Details:\s+", desc, maxsplit=1)[0].strip()
            lines.append(f"- `{item['name']}` (`{row['file']}`): {desc}")
    if not lines:
        return "- No public Rust functions are currently exposed from this module."
    return "\n".join(lines)


def extract_callback_entries_from_doc(full_doc: str) -> list[dict[str, str]]:
    """Extract callback-like params from pipe-tag @param lines.

    A callback is currently inferred from parameter type tokens that include
    `function` (including optional forms like `function?`).
    """
    if not full_doc:
        return []

    out: list[dict[str, str]] = []
    for raw_line in full_doc.splitlines():
        line = raw_line.strip()
        match = re.match(r"^@param\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(.+)$", line)
        if not match:
            continue
        param_name = match.group(1).strip()
        param_type = match.group(2).strip()
        description = match.group(3).strip()
        if "function" not in param_type.lower():
            continue
        invocation = ""
        invoke_match = re.search(r"(callback\([^)]*\))", description, flags=re.IGNORECASE)
        if invoke_match:
            invocation = invoke_match.group(1)
        out.append(
            {
                "name": param_name,
                "type": param_type,
                "description": description,
                "invocation": invocation,
            }
        )
    return out


def collect_lua_callbacks(lua_api: dict) -> list[dict[str, str]]:
    """Collect callback parameter contracts from module functions and methods."""
    rows: list[dict[str, str]] = []

    for fn in lua_api.get("module_functions", []) or []:
        label = (fn.get("lua_name") or fn.get("name") or "").strip()
        if not label:
            continue
        for cb in extract_callback_entries_from_doc(fn.get("full_doc") or ""):
            rows.append(
                {
                    "owner": label,
                    "param": cb.get("name", "callback"),
                    "type": cb.get("type", "function"),
                    "description": cb.get("description", "Callback parameter."),
                    "invocation": cb.get("invocation", ""),
                }
            )

    for class_name, class_meta in (lua_api.get("classes") or {}).items():
        for method in class_meta.get("methods", []) or []:
            label = (method.get("lua_name") or "").strip()
            if not label:
                method_name = (method.get("name") or "").strip()
                if method_name:
                    label = f"{class_name}:{method_name}"
            if not label:
                continue
            for cb in extract_callback_entries_from_doc(method.get("full_doc") or ""):
                rows.append(
                    {
                        "owner": label,
                        "param": cb.get("name", "callback"),
                        "type": cb.get("type", "function"),
                        "description": cb.get("description", "Callback parameter."),
                        "invocation": cb.get("invocation", ""),
                    }
                )

    # Deduplicate while preserving stable order.
    deduped: list[dict[str, str]] = []
    seen: set[tuple[str, str, str, str]] = set()
    for row in sorted(rows, key=lambda r: (r["owner"], r["param"])):
        key = (row["owner"], row["param"], row["type"], row["description"])
        if key in seen:
            continue
        seen.add(key)
        deduped.append(row)
    return deduped


def format_lua_signature(entry: dict) -> str:
    typed_params = entry.get("typed_params") or []
    if typed_params:
        parts: list[str] = []
        for item in typed_params:
            if isinstance(item, list) and len(item) >= 2:
                pname = str(item[0]).strip() or "arg"
                ptype = str(item[1]).strip() or ""
                optional = bool(item[2]) if len(item) > 2 else ptype.endswith("?")
                if optional and not pname.endswith("?"):
                    pname = f"{pname}?"
                parts.append(pname)
        if parts:
            return f"({', '.join(parts)})"

    inferred_sig = (entry.get("inferred_sig") or "").strip()
    if inferred_sig:
        return inferred_sig

    return "()"


def format_lua_return(entry: dict) -> str:
    return_type = (entry.get("inferred_return") or entry.get("returns_doc") or "").strip()
    return return_type or "nil"


def format_lua_api(lua_api: dict) -> str:
    if (
        not lua_api["namespace"]
        and not lua_api["module_functions"]
        and not lua_api["module_constants"]
        and not lua_api["module_enums"]
        and not lua_api["classes"]
    ):
        return "- No dedicated direct `lurek.*` namespace is exposed by this module."

    lines: list[str] = []
    global_callbacks = lua_api.get("global_callbacks", []) or []
    if global_callbacks:
        lines.extend(["### Global Callbacks", ""])
        for cb in global_callbacks:
            name = cb.get("name", "")
            signature = cb.get("signature") or (f"function lurek.{name}()" if name else "function lurek.<callback>()")
            description = cb.get("description") or "Engine callback."
            lines.append(f"- `{signature}`: {description}")
            params = cb.get("parameters") or []
            for param in params:
                pname = param.get("name", "arg")
                ptype = param.get("type", "any")
                pdesc = param.get("description", "")
                popt = "?" if param.get("optional") else ""
                detail = f" — {pdesc}" if pdesc else ""
                lines.append(f"  - `{pname}` (`{ptype}{popt}`){detail}")
        lines.append("")

    lines.extend(["### Functions", ""])
    if lua_api["module_functions"]:
        for fn in lua_api["module_functions"]:
            label = fn["lua_name"] or fn["name"]
            signature = format_lua_signature(fn)
            return_info = format_lua_return(fn)
            lines.append(f"- `{label}{signature} -> {return_info}`: {fn['description']}")
    else:
        lines.append("- No documented module-level functions.")

    lines.extend(["", "### Callbacks", ""])
    callback_rows = collect_lua_callbacks(lua_api)
    if callback_rows:
        for cb in callback_rows:
            tail = f" Invocation: `{cb['invocation']}`." if cb.get("invocation") else ""
            lines.append(
                f"- `{cb['owner']}` param `{cb['param']}` (`{cb['type']}`): {cb['description']}{tail}"
            )
    else:
        lines.append("- No documented callback parameters in this module.")

    lines.extend(["", "### Enums", ""])
    emitted_any_enum_like = False
    for const in lua_api["module_constants"]:
        emitted_any_enum_like = True
        value = const.get("value")
        value_str = f" = {value}" if value is not None else ""
        lines.append(f"- `{const['name']}`{value_str}: {const['description']}")
    for enum in lua_api["module_enums"]:
        emitted_any_enum_like = True
        values = enum.get("values") or []
        value_text = ", ".join(str(v) for v in values) if values else "(no values)"
        lines.append(f"- `{enum['name']}`: {enum['description']} Values: {value_text}")
    if not emitted_any_enum_like:
        lines.append("- No documented module-level enums/constants.")

    lines.extend(["", "### Types", ""])
    if lua_api["classes"]:
        for class_name, class_meta in sorted(lua_api["classes"].items()):
            lines.extend([f"#### {class_name} Type", ""])

            class_description = (class_meta.get("description") or "").strip()
            if class_description:
                lines.append(f"- {class_description}")
                lines.append("")

            lines.extend(["##### Fields", ""])
            fields = class_meta.get("fields", [])
            if fields:
                for field in fields:
                    lines.append(
                        f"- `{field['name']}` (`{field['type']}`): {field['description']}"
                    )
            else:
                lines.append("- No documented fields.")

            lines.extend(["", "##### Methods", ""])
            methods = class_meta.get("methods", [])
            if methods:
                for method in methods:
                    label = method.get("lua_name") or f"{class_name}:{method.get('name','')}"
                    signature = format_lua_signature(method)
                    return_info = format_lua_return(method)
                    lines.append(
                        f"- `{label}{signature} -> {return_info}`: {method.get('description') or 'Lua-visible method.'}"
                    )
            else:
                lines.append("- No documented methods.")
            lines.append("")
    else:
        lines.append("- No documented module types.")

    return "\n".join(lines).strip()


def with_global_callbacks(lua_api: dict, callbacks: list[dict]) -> dict:
    updated = dict(lua_api)
    updated["global_callbacks"] = callbacks
    return updated


def reference_note(group: str, dep_group: str) -> str:
    if group == dep_group:
        return f"Dependency stays inside `{group}` and should remain acyclic."
    return f"Cross-group dependency from `{group}` into `{dep_group}`."


def format_references(group: str, refs: list[str], overrides: dict[str, str]) -> str:
    if not refs:
        return "- No top-level `crate::<module>` imports were detected in this module's Rust source files."

    lines = []
    for ref in refs:
        desc = resolve_item_description(
            overrides,
            ref,
            fallback=f"Imports or references `src/{ref}/`. {reference_note(group, module_group(ref))}",
        )
        lines.append(f"- `{ref}`: {desc}")
    return "\n".join(lines)


def build_default_notes(module: str, lua_api: dict) -> str:
    return "- No additional module-specific notes."


def discover_lua_tests(module: str) -> str:
    candidates = [
        ROOT / "tests" / "lua" / "unit" / f"test_{module}_unit.lua",
    ]
    found = [path.relative_to(ROOT).as_posix() for path in candidates if path.exists()]
    return ", ".join(found)


def build_spec(module: str, lua_parser) -> tuple[str, dict]:
    spec_path = SPECS / f"{module}.md"
    spec_text = read_text(spec_path)
    agent_text = read_text(SRC / module / "AGENT.md")
    legacy_text = read_text(SRC / module / "AGENT.legacy.md")

    spec_sections = parse_doc_sections(spec_text)
    agent_sections = parse_doc_sections(agent_text)
    legacy_sections = parse_doc_sections(legacy_text)
    source = scan_module_sources(module)
    lua_api = collect_lua_api(module, lua_parser, [spec_text, agent_text, legacy_text])
    merge_generated_result_classes(lua_api)

    info_maps = build_info_maps(spec_text, spec_sections, agent_text, agent_sections, legacy_text)
    rust_tests = lookup_info(info_maps, "Rust test path(s)", "Rust Tests") or "None found in the workspace"
    lua_tests = lookup_info(info_maps, "Lua test path(s)", "Lua Tests") or "None found in the workspace"
    discovered_lua_tests = discover_lua_tests(module)
    if discovered_lua_tests and lua_tests.lower().startswith("none found"):
        lua_tests = discovered_lua_tests

    group = module_group(module)
    if group == "Edge/Integration":
        # Fall back to spec/agent metadata only if not explicitly in GROUPS
        meta_group = lookup_info(info_maps, "Module group", "Group")
        if meta_group and module not in {m for mods in GROUPS.values() for m in mods}:
            group = meta_group
    summary_text = first_non_empty(spec_sections["summary"], agent_sections["summary"], legacy_sections["summary"])
    if not summary_text:
        summary_text = (
            f"The `{module}` module is documented from the current source tree and existing module reference data.\n\n"
            f"{build_scope_boundary(module, source['references'], group)}"
        )
    elif "\n\n" not in summary_text:
        summary_text = summary_text + "\n\n" + build_scope_boundary(module, source["references"], group)

    # Legacy Rust Types/Functions sections are intentionally ignored.
    # Specs now focus on module contract, ownership, and Lua-visible API.
    reference_overrides = combine_pair_maps(spec_sections["references"], legacy_sections["references"])
    notes_text = first_non_empty(
        spec_sections["notes"],
        agent_sections["notes"],
        legacy_sections["notes"],
        build_default_notes(module, lua_api),
    )

    tldr_text = first_non_empty(spec_sections.get("tldr", ""), agent_sections.get("tldr", ""), legacy_sections.get("tldr", ""))

    general_info = format_general_info(module, group, rust_tests, lua_tests, lua_api)
    # Files should include file-level docs inline, no dedicated Source Documentation section.
    files_with_docs: list[dict] = []
    for row in source["files"]:
        file_key = row["file"]
        docs = source["file_docs"].get(file_key, [])
        files_with_docs.append({
            "file": file_key,
            "purpose": row["purpose"],
            "doc_lines": docs,
        })

    files_text = format_files(files_with_docs, {})
    callbacks_text = ""
    if module == "app":
        callbacks_text = format_global_callbacks(lua_api.get("global_callbacks", []) or [])
    lua_api_for_spec = lua_api if module != "app" else with_global_callbacks(lua_api, [])
    lua_api_text = format_lua_api(lua_api_for_spec)
    imports_text = format_references(group, source["references"], reference_overrides)
    references_text = format_references(group, source["references"], reference_overrides)

    content = f"""# {module}

## TL;DR

{tldr_text}

## General Info

{general_info}

## Summary

{summary_text}

## Imports

{imports_text}

## Files

{files_text}

{"## Callbacks\n\n" + callbacks_text + "\n\n" if callbacks_text else ""}

## Lua API Ref

{lua_api_text}

## References

{references_text}

## Notes

{notes_text}
"""

    inventory = {
        "group": group,
        "namespace": lua_api["namespace"],
        "rust_tests": rust_tests,
        "lua_tests": lua_tests,
        "references": source["references"],
        "file_count": len(source["files"]),
        "type_count": sum(len(items) for items in source["types_by_file"].values()),
        "function_count": sum(len(items) for items in source["functions_by_file"].values()),
        "lua_api_count": len(lua_api["module_functions"]) + sum(len(v) for v in lua_api["classes"].values()),
    }
    return content, inventory


def load_engine_callbacks() -> list[dict]:
    if not LUA_API_JSON.exists():
        return []
    try:
        data = json.loads(read_text(LUA_API_JSON))
    except Exception:
        return []
    callbacks = data.get("engine_callbacks") or []
    if not isinstance(callbacks, list):
        return []
    return sorted(
        [cb for cb in callbacks if isinstance(cb, dict) and cb.get("name")],
        key=lambda cb: cb.get("name", ""),
    )


def build_callbacks_spec() -> tuple[str, dict]:
    callbacks = load_engine_callbacks()

    general_info = "\n".join(
        [
            "- Module group: `Edge/Integration`",
            "- Source path: `src/app/`",
            "- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)",
            "- Namespace: `lurek.<callback>` (global callbacks)",
            f"- Callback surface: `{len(callbacks)}` engine callbacks",
            "- Rust test path(s): None found in the workspace",
            "- Lua test path(s): None found in the workspace",
        ]
    )

    summary = (
        "This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. "
        "It is generated from `logs/data/lua_api_data.json` (`engine_callbacks`) so callback contracts stay in sync "
        "with Rust+Lua API extraction without hardcoded lists.\n\n"
        "Scope boundary: this file owns only callback inventory and ownership context. "
        "Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`)."
    )

    callback_lines: list[str] = []
    if callbacks:
        callback_lines.extend(["### Callback Inventory", ""])
        for cb in callbacks:
            callback_lines.append(format_callback_line(cb))
        callback_lines.append("")
    else:
        callback_lines.append("- No callback metadata available in `logs/data/lua_api_data.json`.")

    callback_lines.extend(
        [
            "### API Details",
            "",
            "- Full signatures and parameter contracts are intentionally kept in generated API docs:",
            "  - `docs/api/lurek.md`",
            "  - `docs/api/lurek.lua`",
        ]
    )

    content = f"""# callbacks

## TL;DR

Global `lurek.*` callbacks are documented here as a dedicated generated spec, independent from thin-wrapper module specs.

## General Info

{general_info}

## Summary

{summary}

## Imports

- Global callback contracts are sourced from `logs/data/lua_api_data.json` (`engine_callbacks`).

## Files

### callback contracts

- Generated from engine callback metadata extracted during Lua API data generation.

## Lua API Ref

{"\n".join(callback_lines).strip()}
"""

    inventory = {
        "group": "Edge/Integration",
        "namespace": "lurek.<callback>",
        "rust_tests": "None found in the workspace",
        "lua_tests": "None found in the workspace",
        "references": [],
        "file_count": 1,
        "type_count": 0,
        "function_count": 0,
        "lua_api_count": len(callbacks),
    }
    return content, inventory


def rewrite_readme(modules: list[str]) -> None:
    text = read_text(README)
    marker = "## Modules\n"
    if marker not in text:
        return
    prefix = text[: text.index(marker) + len(marker)]
    lines = [f"- [{module}]({module}.md)" for module in modules]
    README.write_text(prefix + "\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/docs/gen_module_specs.py

  # Show all arguments
  python tools/docs/gen_module_specs.py --help
"""
    parser = argparse.ArgumentParser(
        description="Generate merged docs/specs/*.md files for top-level src modules.",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument("--module", action="append", help="Only generate the named module (can be repeated).")
    args = parser.parse_args()

    lua_parser = load_lua_parser()
    modules = sorted(
        p.name for p in SRC.iterdir() if p.is_dir() and p.name not in MODULE_SPEC_EXCLUDE
    )
    if args.module:
        selected = set(args.module)
        modules = [module for module in modules if module in selected]
        emit_callbacks_spec = "callbacks" in selected
    else:
        emit_callbacks_spec = True

    SPECS.mkdir(parents=True, exist_ok=True)
    SESSION_DATA.parent.mkdir(parents=True, exist_ok=True)

    inventory: dict[str, dict] = {}
    for module in modules:
        content, meta = build_spec(module, lua_parser)
        (SPECS / f"{module}.md").write_text(content.rstrip() + "\n", encoding="utf-8")
        inventory[module] = meta

    if emit_callbacks_spec:
        callbacks_content, callbacks_meta = build_callbacks_spec()
        (SPECS / "callbacks.md").write_text(callbacks_content.rstrip() + "\n", encoding="utf-8")
        inventory["callbacks"] = callbacks_meta

    # Ensure deprecated thin-wrapper spec is removed and not reintroduced.
    deprecated_spec = SPECS / "lua_api.md"
    if deprecated_spec.exists() and (not args.module or "lua_api" in (set(args.module) if args.module else set())):
        deprecated_spec.unlink()

    if not args.module:
        readme_modules = sorted(
            [p.name for p in SRC.iterdir() if p.is_dir() and p.name not in MODULE_SPEC_EXCLUDE]
            + SPECIAL_SPECS
        )
        rewrite_readme(readme_modules)

    SESSION_DATA.write_text(json.dumps(inventory, indent=2, sort_keys=True), encoding="utf-8")
    print(f"Generated {len(modules)} module spec files.")


if __name__ == "__main__":
    main()
