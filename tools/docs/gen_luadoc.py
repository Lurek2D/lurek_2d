#!/usr/bin/env python3
"""
gen_luadoc.py â€” Generate LuaCATS type-annotation stubs for the Lurek2D VS Code extension.

Reads logs/data/lua_api_data.json and emits docs/api/lurek.lua â€” a LuaCATS
stub file that gives the VS Code Lua language server full type information
for the lurek.* API. Consumed by the vscode-extension IntelliSense provider.

Usage:
    python tools/docs/gen_luadoc.py                 # -> docs/api/lurek.lua
"""
import json
import os
import re

# Lua reserved keywords â€” cannot be used as parameter names in stub declarations.
LUA_KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for",
    "function", "goto", "if", "in", "local", "nil", "not", "or",
    "repeat", "return", "then", "true", "until", "while",
}

WORKSPACE_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INPUT_FILE = os.path.join(WORKSPACE_ROOT, "logs", "data", "lua_api_data.json")
OUTPUT_FILE = os.path.join(WORKSPACE_ROOT, "docs", "api", "lurek.lua")

BUILTIN_TYPES = {
    "any", "nil", "boolean", "number", "string", "table",
    "function", "userdata", "thread", "unknown", "self", "LuaValue",
}

UNKNOWN_SENTINEL = "unknown"
DYNAMIC_LUA_TYPE = "LuaValue"

TYPE_NORMALIZATIONS = {
    "any": "any",
    "bool": "boolean",
    "int": "number",
    "u8": "number",
    "u16": "number",
    "u32": "number",
    "u64": "number",
    "usize": "number",
    "isize": "number",
    "f32": "number",
    "f64": "number",
    "index": "number",
    "count": "number",
    "integer": "number",
    "Thread": "ThreadHandle",
    "Style": "table",
    "unknown": DYNAMIC_LUA_TYPE,
    "void": "nil",
}

# Populated in main() from discovered declared L* types.
LEGACY_TO_L_TYPES = {}


def _is_canonical_l_type(type_name: str) -> bool:
    return bool(type_name) and len(type_name) > 1 and type_name[0] == "L" and type_name[1].isupper()


def split_top_level_types(text):
    parts = []
    current = []
    depth_angle = 0
    depth_brace = 0
    depth_paren = 0
    depth_bracket = 0

    for ch in text:
        if ch == "<":
            depth_angle += 1
        elif ch == ">" and depth_angle > 0:
            depth_angle -= 1
        elif ch == "{":
            depth_brace += 1
        elif ch == "}" and depth_brace > 0:
            depth_brace -= 1
        elif ch == "(":
            depth_paren += 1
        elif ch == ")" and depth_paren > 0:
            depth_paren -= 1
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]" and depth_bracket > 0:
            depth_bracket -= 1

        if ch == "," and depth_angle == 0 and depth_brace == 0 and depth_paren == 0 and depth_bracket == 0:
            part = "".join(current).strip()
            if part:
                parts.append(part)
            current = []
            continue

        current.append(ch)

    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return parts


def normalize_type(type_name):
    if not type_name:
        return DYNAMIC_LUA_TYPE

    type_name = type_name.strip()
    type_name = re.sub(r"\s*([<>|,{}()\[\]])\s*", r"\1", type_name)

    for old, new in TYPE_NORMALIZATIONS.items():
        type_name = re.sub(rf"\b{re.escape(old)}\b", new, type_name)

    # Map legacy non-L type spellings (e.g. Image) to canonical L-prefixed
    # types (e.g. LImage) so the public stub surface stays consistent.
    for old, new in LEGACY_TO_L_TYPES.items():
        type_name = re.sub(rf"\b{re.escape(old)}\b", new, type_name)

    # Collapse duplicate union members, e.g. table|table -> table.
    if "|" in type_name:
        parts = [p.strip() for p in type_name.split("|") if p.strip()]
        deduped = []
        seen = set()
        for p in parts:
            if p in seen:
                continue
            seen.add(p)
            deduped.append(p)
        type_name = "|".join(deduped)

    return type_name or DYNAMIC_LUA_TYPE


def extract_return_from_full_doc(full_doc):
    """Extract @return type(s) from a full docstring.

    When multiple ``@return`` lines are present (e.g. one per return value), collect all
    type tokens and join them as a comma-separated list so that write_function_doc can
    emit one ``---@return`` annotation per value.
    """
    types = []
    for line in full_doc.splitlines():
        stripped = line.strip()
        pipe_match = re.match(r"^@return\s*\|\s*([^|]+?)\s*\|\s*(.+)$", stripped)
        if pipe_match:
            types.append(pipe_match.group(1).strip())
    if not types:
        return ""
    if len(types) == 1:
        return types[0]
    # Multiple @return lines â†’ join as comma-separated so parse_returns can split them.
    return ", ".join(types)


def extract_return_entries_from_full_doc(full_doc):
    """Extract typed @return entries with their descriptions from a full docstring."""
    entries = []
    for line in full_doc.splitlines():
        stripped = line.strip()
        pipe_match = re.match(r"^@return\s*\|\s*([^|]+?)\s*\|\s*(.+)$", stripped)
        if not pipe_match:
            continue
        raw_types = pipe_match.group(1).strip()
        description = pipe_match.group(2).strip()
        for part in split_top_level_types(raw_types):
            entries.append((normalize_type(part.strip()), description))
    return entries


def extract_field_entries_from_full_doc(full_doc):
    """Extract @field entries from a full docstring for table return shapes."""
    if not full_doc:
        return []
    entries = []
    for line in full_doc.splitlines():
        stripped = line.strip()
        m = re.match(r"^@field\s*\|\s*(\w+)\s*\|\s*([^|]+?)\s*\|\s*(.+)$", stripped)
        if m:
            entries.append({"name": m.group(1), "type": m.group(2).strip(), "description": m.group(3).strip()})
    return entries


def extract_overload_entries_from_full_doc(full_doc):
    """Extract custom @overload entries for alternative single-return call shapes.

    Supported source format:
    @overload | param_name | param_type | return_type | description
    """
    if not full_doc:
        return []
    entries = []
    for line in full_doc.splitlines():
        stripped = line.strip()
        m = re.match(
            r"^@overload\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(.+)$",
            stripped,
        )
        if not m:
            continue
        entries.append(
            {
                "param_name": m.group(1).strip(),
                "param_type": normalize_type(m.group(2).strip()),
                "return_type": normalize_type(m.group(3).strip()),
                "description": m.group(4).strip(),
            }
        )
    return entries


def _derive_class_name(fn_name):
    """Derive a PascalCase class name from a stub function name."""
    class_name = ""
    if ":" in fn_name:
        owner, method = fn_name.split(":", 1)
        class_name = owner + method[0].upper() + method[1:] + "Result"
    elif "." in fn_name:
        parts = fn_name.split(".")
        tail = parts[-2:] if len(parts) >= 2 else parts
        class_name = "".join(p[0].upper() + p[1:] for p in tail) + "Result"
    else:
        class_name = fn_name[0].upper() + fn_name[1:] + "Result"

    return class_name if _is_canonical_l_type(class_name) else f"L{class_name}"


def extract_generated_result_class(fn, name):
    """Build a generated result class from @field entries, if present."""
    field_entries = extract_field_entries_from_full_doc(fn.get("full_doc", ""))
    if not field_entries:
        return None

    class_name = _derive_class_name(name)
    fields = []
    for fe in field_entries:
        fields.append(
            {
                "name": fe["name"],
                "type": normalize_type(fe["type"]),
                "description": fe.get("description", "").strip(),
            }
        )
    return class_name, fields


def merge_generated_result_class(store, class_name, fields):
    """Merge generated class fields by name so duplicate emit sites stay stable."""
    if class_name not in store:
        store[class_name] = {"fields": {}}
    for field in fields:
        fname = field["name"]
        if fname not in store[class_name]["fields"]:
            store[class_name]["fields"][fname] = field


def collect_generated_result_classes(lua_api, lua_namespace_map):
    """Collect all @field-derived result classes before writing function stubs."""
    generated = {}

    for mod_name in sorted(lua_api.keys()):
        lua_ns = lua_namespace_map.get(mod_name, mod_name)
        mod_data = lua_api[mod_name]

        classes = mod_data.get("classes", {})
        for class_name in sorted(classes.keys()):
            methods = classes[class_name].get("methods", [])
            methods.sort(key=lambda x: x.get("name", ""))
            for method in methods:
                name = method.get("lua_name", f"{class_name}:{method['name']}")
                if ":" not in name and ("." not in name):
                    name = f"{class_name}:{method['name']}"
                elif "." in name and ":" not in name:
                    last_dot = name.rfind(".")
                    name = name[:last_dot] + ":" + name[last_dot + 1:]

                maybe_class = extract_generated_result_class(method, name)
                if maybe_class:
                    generated_name, fields = maybe_class
                    merge_generated_result_class(generated, generated_name, fields)

        functions = mod_data.get("functions", [])
        functions.sort(key=lambda x: (x.get("kind", "function"), x.get("name", "")))
        for func in functions:
            name = func.get("lua_name", f"lurek.{lua_ns}.{func['name']}")
            if ":" in name:
                continue
            if mod_name != lua_ns and name.startswith(f"lurek.{mod_name}."):
                name = f"lurek.{lua_ns}." + name[len(f"lurek.{mod_name}."):]

            maybe_class = extract_generated_result_class(func, name)
            if maybe_class:
                generated_name, fields = maybe_class
                merge_generated_result_class(generated, generated_name, fields)

    return generated


def collect_nested_namespaces(lua_api, lua_namespace_map):
    nested_by_module = {}
    for mod_name in sorted(lua_api.keys()):
        lua_ns = lua_namespace_map.get(mod_name, mod_name)
        nested = set()

        for func in lua_api[mod_name].get("functions", []):
            lua_name = (func.get("lua_name") or "").strip()
            if not lua_name.startswith("lurek."):
                continue
            parts = lua_name.split(".")
            if len(parts) < 4:
                continue
            if parts[1] != lua_ns:
                continue
            nested.add(parts[2])

        if nested:
            nested_by_module[mod_name] = sorted(nested)

    return nested_by_module


def collect_namespace_declarations(lua_api, lua_namespace_map, nested_namespaces):
    decls = []
    for mod_name in sorted(lua_api.keys()):
        lua_ns = lua_namespace_map.get(mod_name, mod_name)
        nested = list(nested_namespaces.get(mod_name, []))
        decls.append(
            {
                "mod_name": mod_name,
                "lua_ns": lua_ns,
                "nested": nested,
            }
        )
    return decls


def collect_userdata_class_declarations(lua_api):
    decls = []
    ui_non_widget = {
        "LTheme",
        "LLineChart",
        "LBarChart",
        "LScatterPlot",
        "LPieChart",
        "LAreaChart",
        "LUiWidget",
    }
    for mod_name in sorted(lua_api.keys()):
        classes = lua_api[mod_name].get("classes", {})
        for class_name in sorted(classes.keys()):
            class_data = classes[class_name]
            decl = class_name
            if mod_name == "ui" and class_name not in ui_non_widget:
                decl = f"{class_name} : LUiWidget"
            decls.append(
                {
                    "mod_name": mod_name,
                    "class_name": class_name,
                    "class_decl": decl,
                    "description": class_data.get("description", "").strip(),
                    "fields": class_data.get("fields", []),
                }
            )
    return decls


def get_return_entries(fn):
    full_doc_entries = extract_return_entries_from_full_doc(fn.get("full_doc", ""))
    if full_doc_entries:
        return full_doc_entries, True

    ret = parse_returns(fn)
    ret_desc = fn.get("return_description", "").strip()
    if not ret:
        return [], False

    return [(part.strip(), ret_desc) for part in split_top_level_types(ret)], False


def normalize_param_type(type_name, is_optional=False):
    # Some parsed @param payloads can accidentally include the beginning of
    # the prose description after the type token. Keep only the type fragment.
    m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_<>{}\[\]|?,.]*)", type_name or "")
    if m:
        type_name = m.group(1)
    normalized = normalize_type(type_name)
    if normalized.endswith("?"):
        normalized = normalized[:-1] or DYNAMIC_LUA_TYPE
    return normalized


def _normalize_return_text(text):
    normalized = text.strip().lower()
    normalized = re.sub(r"^returns?\s*:?\s*", "", normalized)
    normalized = re.sub(r"\b(a|an|the)\b", " ", normalized)
    normalized = re.sub(r"[^a-z0-9]+", " ", normalized)
    return re.sub(r"\s+", " ", normalized).strip()


def is_redundant_nil_return(ret_type, ret_desc):
    if normalize_type(ret_type) != "nil":
        return False
    normalized = _normalize_return_text(ret_desc)
    return normalized in {
        "no return",
        "no returns",
        "no return value",
        "no return values",
        "no value",
        "no values",
        "no value is returned",
        "no values are returned",
        "nothing",
        "nothing is returned",
        "nothing returned",
        "nil",
    }


def format_return_description(ret_desc):
    cleaned = ret_desc.strip()
    cleaned = re.sub(r"^returns?\s*:?\s*", "", cleaned, flags=re.IGNORECASE)
    return cleaned


def sanitize_return_name(name, fallback):
    cleaned = name.strip().lower()
    cleaned = re.sub(r"[^a-z0-9]+", "_", cleaned)
    cleaned = cleaned.strip("_")
    if not cleaned:
        cleaned = fallback
    if cleaned[0].isdigit():
        cleaned = f"value_{cleaned}"
    if cleaned in LUA_KEYWORDS:
        cleaned = f"{cleaned}_"
    return cleaned


def infer_return_name_candidates(ret_desc):
    normalized = format_return_description(ret_desc).strip().lower()
    if not normalized:
        return []

    pattern_candidates = [
        (r"\bsuccess flag,\s*event name,\s*and\s*payload array\b", ["success", "event_name", "payload"]),
        (r"\bvalidation result flag and array of error records\b", ["ok", "errors"]),
        (r"\bdocumented entry count and live entry count\b", ["documented_count", "live_count"]),
        (r"\bstatus and payload\b", ["status", "payload"]),
        (r"\blatitude,\s*longitude,\s*and\s*zoom\b", ["latitude", "longitude", "zoom"]),
        (r"\bred,\s*green,\s*blue,\s*and\s*alpha\b", ["red", "green", "blue", "alpha"]),
        (r"\bhue,\s*saturation,\s*and\s*lightness\b", ["hue", "saturation", "lightness"]),
        (r"\bconstant,\s*linear,\s*and\s*quadratic\b", ["constant", "linear", "quadratic"]),
        (r"\bwidth and height\b", ["width", "height"]),
        (r"\bspeed and strength\b", ["speed", "strength"]),
        (r"\bx,\s*y,\s*width,\s*and\s*height\b", ["x", "y", "width", "height"]),
        (r"\bminimum x,\s*minimum y,\s*maximum x,\s*and\s*maximum y\b", ["min_x", "min_y", "max_x", "max_y"]),
        (r"\btranslation x,\s*translation y,\s*angle,\s*scale x,\s*and\s*scale y\b", ["translation_x", "translation_y", "angle", "scale_x", "scale_y"]),
        (r"\bx and y\b", ["x", "y"]),
        (r"\bx,\s*y,\s*and\s*z\b", ["x", "y", "z"]),
    ]

    for pattern, candidates in pattern_candidates:
        if re.search(pattern, normalized):
            return candidates

    return []


def infer_single_return_name_candidate(ret_desc):
    normalized = format_return_description(ret_desc).strip().lower()
    if not normalized:
        return None

    phrase_patterns = [
        r"\b(?:the same|new|started|returned|created|updated|current|standalone|requested|registered)\s+([a-z][a-z0-9 /_-]*?)\s+handle\b",
        r"\b([a-z][a-z0-9 /_-]*?)\s+handle\b",
        r"\b(?:the same|new|started|created|current|standalone)\s+([a-z][a-z0-9 /_-]*?)\s+state\b",
        r"\bcopy of (?:the )?([a-z][a-z0-9 /_-]*?)\b(?: at call time)?$",
    ]
    for pattern in phrase_patterns:
        match = re.search(pattern, normalized)
        if match:
            phrase = match.group(1).strip()
            phrase = re.sub(r"\b(?:this|that|current|requested|registered|provided|same|new|started|standalone|active|named|literal|lua-visible|world|agent)\b", " ", phrase)
            phrase = re.sub(r"\b(?:for|of|to|at|the|a|an)\b", " ", phrase)
            phrase = re.sub(r"\s+", " ", phrase).strip()
            if phrase:
                return sanitize_return_name(phrase, "value")

    single_return_patterns = [
        (r"\bcontrol point count\b", "count"),
        (r"\bnoise value\b", "noise"),
        (r"\bangle\b", "angle"),
        (r"\bwidth\b", "width"),
        (r"\bheight\b", "height"),
        (r"\blatitude\b", "latitude"),
        (r"\blongitude\b", "longitude"),
        (r"\bzoom\b", "zoom"),
        (r"\bx(?: |-)?coordinate\b", "x"),
        (r"\by(?: |-)?coordinate\b", "y"),
        (r"\bz(?: |-)?coordinate\b", "z"),
        (r"\bx(?: |-)?position\b", "x"),
        (r"\by(?: |-)?position\b", "y"),
        (r"\bz(?: |-)?position\b", "z"),
        (r"\bx(?: |-)?component\b", "x"),
        (r"\by(?: |-)?component\b", "y"),
        (r"\bz(?: |-)?component\b", "z"),
        (r"\bx(?: |-)?value\b", "x"),
        (r"\by(?: |-)?value\b", "y"),
        (r"\bz(?: |-)?value\b", "z"),
        (r"\bx axis\b", "x"),
        (r"\by axis\b", "y"),
        (r"\bz axis\b", "z"),
        (r"\bred component\b", "r"),
        (r"\bgreen component\b", "g"),
        (r"\bblue component\b", "b"),
        (r"\balpha component\b", "a"),
        (r"\bred channel\b", "r"),
        (r"\bgreen channel\b", "g"),
        (r"\bblue channel\b", "b"),
        (r"\balpha channel\b", "a"),
        (r"\bhorizontal\b", "x"),
        (r"\bvertical\b", "y"),
        (r"\btype name\b", "type_name"),
        (r"\bblackboard\b", "blackboard"),
        (r"\beasing names\b", "easing_names"),
        (r"\bevent tables\b", "events"),
        (r"\bframe count\b", "frame_count"),
        (r"\bclip name\b", "clip_name"),
        (r"\bprogress\b", "progress"),
        (r"\bresult\b", "result"),
        (r"\bexists\b", "exists"),
        (r"\bmatches\b", "matches"),
        (r"\bcontains\b", "contains"),
        (r"\boverlaps\b", "overlaps"),
        (r"\bintersects\b", "intersects"),
        (r"\bis empty\b", "is_empty"),
    ]

    for pattern, candidate in single_return_patterns:
        if re.search(pattern, normalized):
            return candidate

    return None


def infer_return_name(ret_type, ret_desc, index, total, fn_name=None):
    candidates = infer_return_name_candidates(ret_desc)
    if len(candidates) == total:
        return sanitize_return_name(candidates[index], f"value{index + 1}")

    normalized_ret_type = normalize_type(ret_type)
    normalized_ret_desc = format_return_description(ret_desc).strip().lower()

    if total == 1 and normalized_ret_type == "boolean":
        predicate_patterns = [
            (r"\bmatches\b", "matches"),
            (r"\bexists\b", "exists"),
            (r"\bcontains\b", "contains"),
            (r"\boverlaps\b", "overlaps"),
            (r"\bintersects\b", "intersects"),
            (r"\bis empty\b", "is_empty"),
        ]
        for pattern, candidate in predicate_patterns:
            if re.search(pattern, normalized_ret_desc):
                return candidate

    single_candidate = infer_single_return_name_candidate(ret_desc)
    if single_candidate:
        return sanitize_return_name(single_candidate, f"value{index + 1}")

    if total == 1:
        if fn_name:
            bare_name = fn_name.split(":")[-1].split(".")[-1]
            if re.match(r"^(is|has|can)[A-Z_]", bare_name):
                snake = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", bare_name).lower()
                return sanitize_return_name(snake, "result")
            if bare_name in {"contains", "exists", "matches", "intersects", "overlaps"}:
                return sanitize_return_name(bare_name, "result")
        if normalized_ret_type == "table":
            return "result"
        if re.match(r"^L[A-Z]", normalized_ret_type):
            stripped = normalized_ret_type[1:]
            stripped = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", stripped).lower()
            stripped = re.sub(r"^ai_", "", stripped)
            return sanitize_return_name(stripped, "value")
        return None

    return None


def should_emit_return_description(desc, ret_desc):
    if not ret_desc:
        return False
    if not desc:
        return True

    normalized_desc = _normalize_return_text(desc)
    normalized_ret = _normalize_return_text(ret_desc)
    if not normalized_desc or not normalized_ret:
        return True

    return normalized_desc != normalized_ret


def is_low_signal_return_description(ret_desc):
    normalized = _normalize_return_text(ret_desc)
    if normalized in {
        "literal type name",
        "lua visible type name",
        "type name for this userdata",
        "current type name",
    }:
        return True

    if re.match(r"^(same|new|started|current|created|returned|requested|registered)\s+.+\s+(handle|state|widget|object)$", normalized):
        return True

    return False


def collect_declared_and_referenced_types(lua_api):
    declared = set(BUILTIN_TYPES)
    referenced = set()

    def collect_from_type(type_name):
        normalized = normalize_type(type_name)
        for token in re.findall(r"[A-Za-z_][A-Za-z0-9_]*", normalized):
            lowered = token.lower()
            if lowered in BUILTIN_TYPES or token == "lurek":
                continue
            referenced.add(token)

    for mod_name, mod_data in lua_api.items():
        declared.add(mod_name)
        for class_name, class_data in mod_data.get("classes", {}).items():
            declared.add(class_name)
            for method in class_data.get("methods", []):
                for param in method.get("typed_params", []):
                    if len(param) > 1:
                        collect_from_type(param[1])
                collect_from_type(method.get("inferred_return", ""))
        for func in mod_data.get("functions", []):
            for param in func.get("typed_params", []):
                if len(param) > 1:
                    collect_from_type(param[1])
            collect_from_type(func.get("inferred_return", ""))

    return declared, referenced

def guess_type(text, is_return=False):
    t = text.lower()
    if is_return:
        if "two numbers" in t or "width, height" in t or "x, y" in t or "x and y" in t:
            return "number, number"
        elif "two strings" in t or "min, mag" in t:
            return "string, string"
        elif "width, height, channels" in t:
            return "number, number, number"
        if "quad, x, y" in t:
            return "LQuad, number, number"

    if "string" in t or "path" in t or "filename" in t or "mode" in t:
        return "string"
    elif "int" in t or "number" in t or "float" in t or "id" in t or "index" in t or "radius" in t or "width" in t or "height" in t or "x" in t or "y" in t or "angle" in t or "scale" in t:
        return "number"
    elif "bool" in t or "true" in t or "false" in t:
        return "boolean"
    elif "table" in t:
        return "table"
    elif "function" in t or "callback" in t:
        return "function"
    elif "image" in t:
        return "LImage"
    elif "font" in t:
        return "LFont"
    elif "canvas" in t:
        return "LCanvas"
    elif "spritebatch" in t:
        return "LSpriteBatch"
    elif "mesh" in t:
        return "LMesh"
    elif "shader" in t:
        return "LShader"
    elif "sounddata" in t:
        return "LSoundData"
    elif "imagedata" in t:
        return "LImageData"
    elif "quad" in t:
        return "LQuad"
    elif "filehandle" in t:
        return "LFileHandle"
    elif "audio source" in t or "audiosource" in t or "source" in t:
        return "LSource"
    return UNKNOWN_SENTINEL

def parse_params(fn):
    pkeys = []
    ptype_map = {}
    pdesc_map = {}
    popt_map = {}

    typed = fn.get("typed_params", [])
    if typed:
        for p in typed:
            pname = p[0].strip()
            ptype = p[1].strip() if len(p) > 1 else UNKNOWN_SENTINEL
            is_opt = p[2] if len(p) > 2 else False
            param_desc = p[3].strip() if len(p) > 3 else ""
            pname_clean = pname if pname == "..." else re.sub(r'[^a-zA-Z0-9_]', '', pname.replace(' ', '_'))
            if pname_clean and pname_clean not in pkeys:
                pkeys.append(pname_clean)
                ptype_map[pname_clean] = normalize_param_type(ptype, is_opt)
                popt_map[pname_clean] = is_opt
                if param_desc:
                    pdesc_map[pname_clean] = param_desc
                elif is_opt:
                    pdesc_map[pname_clean] = "(optional)"
                else:
                    pdesc_map[pname_clean] = ""
        return pkeys, ptype_map, pdesc_map, popt_map

    # 1. Start with params_doc
    params_doc = fn.get("params_doc", "")
    for line in params_doc.splitlines():
        # Match lines like `- \`name\`` or `- \`n1\`, \`n2\`` followed by weird characters or typical separators
        m = re.match(r'^-\s+`([^`]+)`(?:,\s*`([^`]+)`)?\s*(?:[-:â€”\u2014]+|Ä‚.Ä‚.Ä‚.|\xef\xbf\xbd.+)?\s*(.*)$', line.strip())
        if not m:
            m = re.match(r'^-\s+`([^`]+)`(.*?)$', line.strip())

        if m:
            names = []
            desc = ""
            if len(m.groups()) == 3:
                n1, n2, parsed_desc = m.groups()
                names.append(n1)
                if n2: names.append(n2)
                desc = parsed_desc
            else:
                n1, rest = m.groups()
                names.append(n1)
                desc = re.sub(r'^(?:[-:â€”\u2014]+|Ä‚.Ä‚.Ä‚.|\xef\xbf\xbd.+)?\s*', '', rest)

            for n in names:
                n_clean = n if n == "..." else re.sub(r'[^a-zA-Z0-9_]', '', n.replace(' ', '_'))
                if n_clean and n_clean not in pkeys:
                    pkeys.append(n_clean)
                    ptype_map[n_clean] = normalize_param_type(guess_type(desc))
                    pdesc_map[n_clean] = desc.strip()

    # 2. Fallback to inferred_sig if params_doc yielded nothing
    if not pkeys:
        inferred_sig = fn.get("inferred_sig", "").strip()
        if inferred_sig.startswith("(") and inferred_sig.endswith(")"):
            inner = inferred_sig[1:-1].strip()
            if inner:
                parts = [p.strip() for p in inner.split(',')]
                for p in parts:
                    is_opt = False
                    name = p
                    if name.startswith('[') and name.endswith(']'):
                        name = name[1:-1].strip()
                        is_opt = True
                    elif name.endswith('?'):
                        name = name[:-1].strip()
                        is_opt = True

                    name_clean = name if name == "..." else re.sub(r'[^a-zA-Z0-9_]', '', name.replace(' ', '_'))
                    if name_clean and name_clean not in pkeys:
                        pkeys.append(name_clean)
                        ptype_map[name_clean] = normalize_param_type(UNKNOWN_SENTINEL, is_opt)
                        popt_map[name_clean] = is_opt
                        pdesc_map[name_clean] = "(optional)" if is_opt else ""

    return pkeys, ptype_map, pdesc_map, popt_map


def parse_returns(fn):
    ret_doc = fn.get('returns_doc', '').strip()
    if not ret_doc:
        ret_doc = extract_return_from_full_doc(fn.get('full_doc', ''))

    if ret_doc:
        # If it looks like a class/type name (starts with uppercase), use it directly
        # without the heuristic guess_type, which can false-match on substrings like "y".
        if ret_doc and ret_doc[0].isupper():
            return normalize_type(ret_doc)
        # Extract just the type token (before 2+ spaces / inline description).
        # e.g. "table  {x, y, width, height}" â†’ "table" to avoid heuristic
        # false-matches on description words (e.g. "width, height" â†’ "number, number").
        type_token = re.split(r'\s{2,}', ret_doc)[0].strip()
        # Handle comma-separated primitive type lists, e.g. "@return number, number, number".
        # Without this, guess_type collapses "number, number" to just "number".
        if ',' in type_token and re.match(r'^[a-z][a-z0-9_?|]*(?:,\s*[a-z][a-z0-9_?|]*)*$', type_token):
            return type_token
        res = guess_type(type_token, is_return=True)
        if res != UNKNOWN_SENTINEL:
            return normalize_type(res)
        if re.match(r'^[A-Za-z_][A-Za-z0-9_<>{}, |?]*$', ret_doc):
            return normalize_type(ret_doc)

    inferred = fn.get('inferred_return', '').strip()
    if inferred:
        if inferred == "()":
            return None
        return normalize_type(inferred)
    if ret_doc:
        return DYNAMIC_LUA_TYPE
    return None

def write_function_doc(out, fn, name):

    desc = fn.get("description", "").strip()
    if desc:
        for line in desc.splitlines():
            out.append(f"--- {line}")

    overload_entries = extract_overload_entries_from_full_doc(fn.get("full_doc", ""))
    overload_param_names = {entry["param_name"] for entry in overload_entries}

    pkeys, ptyp, pdesc, popt = parse_params(fn)

    # For colon-notation methods, self is implicit in LuaLS — skip it from
    # both annotations and the signature parameter list.
    if ':' in name and pkeys and pkeys[0] == "self":
        pkeys = pkeys[1:]

    param_names = []

    for k in pkeys:
        raw_key = k
        pd = pdesc.get(k, "")
        t = ptyp.get(k, DYNAMIC_LUA_TYPE)
        k = k.replace("?", "")

        is_optional = popt.get(k, False)

        if is_optional and raw_key.replace("?", "") in overload_param_names:
            continue

        if k == "...":
            if pd:
                out.append(f"---@param ... {t} {pd}".strip())
            else:
                out.append(f"---@param ... {t}".strip())
            param_names.append("...")
        else:
            safe_k = (k + "_") if k in LUA_KEYWORDS else k
            if is_optional:
                # LuaCATS optional syntax: name? type (NOT name type|nil)
                clean_parts = [part.strip() for part in t.split('|') if part.strip() and part.strip() != 'nil']
                clean_t = '|'.join(clean_parts) or DYNAMIC_LUA_TYPE
                if pd and pd != "(optional)":
                    out.append(f"---@param {safe_k}? {clean_t} {pd}".strip())
                else:
                    out.append(f"---@param {safe_k}? {clean_t}".strip())
            elif pd:
                out.append(f"---@param {safe_k} {t} {pd}".strip())
            else:
                out.append(f"---@param {safe_k} {t}".strip())
            param_names.append(safe_k)

    maybe_generated_class = extract_generated_result_class(fn, name)
    generated_class_name = maybe_generated_class[0] if maybe_generated_class else None

    ret_entries, has_explicit_return_entries = get_return_entries(fn)
    ret_desc_values = [desc.strip() for _, desc in ret_entries]
    duplicated_multi_return_desc = (
        len(ret_entries) > 1
        and bool(ret_desc_values)
        and len(set(ret_desc_values)) == 1
        and bool(ret_desc_values[0])
    )
    for i, (ret_type, ret_desc) in enumerate(ret_entries):
        if generated_class_name and normalize_type(ret_type) == "table":
            ret_type = generated_class_name
        raw_ret_desc = ret_desc.strip()
        # Keep descriptions without synthetic return variable names.
        # For multi-return entries where source docs omit per-value details,
        # emit a positional fallback description to avoid empty @return lines.
        if not raw_ret_desc:
            raw_ret_desc = (
                "Return value."
                if len(ret_entries) == 1
                else f"Return value {i + 1}."
            )
        elif duplicated_multi_return_desc:
            raw_ret_desc = f"{raw_ret_desc} (value {i + 1})."
        if len(ret_entries) > 1:
            raw_ret_desc = raw_ret_desc.replace(",", ";")
        out.append(f"---@return {ret_type} {raw_ret_desc}")

    for overload in overload_entries:
        overload_param_name = overload["param_name"]
        overload_param_type = overload["param_type"]
        overload_return_type = overload["return_type"]
        overload_desc = overload["description"]

        overload_signatures = []
        if overload_param_name == "...":
            overload_signatures.append(f"...: {overload_param_type}")
        else:
            safe_param_name = (
                overload_param_name + "_"
                if overload_param_name in LUA_KEYWORDS
                else overload_param_name
            )
            overload_signatures.append(f"{safe_param_name}: {overload_param_type}")
            if ':' in name:
                owner_name = name.split(':', 1)[0].split('.')[-1]
                overload_signatures.append(
                    f"self: {owner_name}, {safe_param_name}: {overload_param_type}"
                )

        for overload_signature in overload_signatures:
            if overload_desc:
                out.append(
                    f"---@overload fun({overload_signature}): {overload_return_type} # {overload_desc}"
                )
            else:
                out.append(f"---@overload fun({overload_signature}): {overload_return_type}")

    signature = ', '.join(param_names)
    if ':' in name:
        out.append(f"function {name}({signature}) end")
    else:
        out.append(f"{name} = function({signature}) end")
    out.append("")


def write_callback_doc(out, callback):
    desc = callback.get("description", "").strip()
    if desc:
        for line in desc.splitlines():
            out.append(f"--- {line}")
    if desc.lower().startswith("deprecated"):
        out.append(f"---@deprecated {desc}")

    params = callback.get("parameters", [])
    arg_names = []
    for param in params:
        raw_name = str(param.get("name", "arg")).strip() or "arg"
        safe_name = (raw_name + "_") if raw_name in LUA_KEYWORDS else raw_name
        param_type = normalize_param_type(str(param.get("type", UNKNOWN_SENTINEL)), bool(param.get("optional", False)))
        param_desc = str(param.get("description", "")).strip()
        if param.get("optional", False):
            clean_type = re.sub(r"\|nil$", "", param_type) or DYNAMIC_LUA_TYPE
            if param_desc:
                out.append(f"---@param {safe_name}? {clean_type} {param_desc}".strip())
            else:
                out.append(f"---@param {safe_name}? {clean_type}".strip())
        elif param_desc:
            out.append(f"---@param {safe_name} {param_type} {param_desc}".strip())
        else:
            out.append(f"---@param {safe_name} {param_type}".strip())
        arg_names.append(safe_name)

    signature = ", ".join(arg_names)
    out.append(f"function lurek.{callback['name']}({signature}) end")
    out.append("")

def main():
    if not os.path.exists(INPUT_FILE):
        print(f"API data not found at {INPUT_FILE}")
        return

    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    lua_api = data.get("lua_api", {}).get("modules", {})

    # Maps internal json key â†’ actual Lua namespace (for modules that register under a different name)
    _LUA_NAMESPACE = {}

    source_enums = data.get("lua_api", {}).get("enums", {})

    out = []
    out.append("---@meta")
    out.append("--- Auto-generated Lurek2D API documentation for LuaCATS.")
    out.append("")
    out.append("lurek = {}")
    out.append("")
    out.append("---@alias LuaValue nil|boolean|number|string|table|function|userdata|thread")
    out.append("")

    declared_types, referenced_types = collect_declared_and_referenced_types(lua_api)
    opaque_types = sorted(
        token for token in referenced_types
        if token not in declared_types and (token[0].isupper() or token in {"Lua", "LuaValue", "Thread"})
    )

    # Old-name -> L-prefix aliases: if a referenced type "Foo" has a declared
    # counterpart "LFoo", emit an alias instead of a duplicate stub class.
    _l_declared_lower = {("l" + n[1:]).lower(): n for n in declared_types if n.startswith("L")}
    _OPAQUE_ALIASES: dict[str, str] = {}
    for type_name in opaque_types:
        lname = "L" + type_name
        if lname in declared_types:
            _OPAQUE_ALIASES[type_name] = lname
        else:
            candidate = ("l" + type_name).lower()
            if candidate in _l_declared_lower:
                _OPAQUE_ALIASES[type_name] = _l_declared_lower[candidate]

    # Build legacy no-prefix -> canonical L-prefixed type map (Image -> LImage).
    LEGACY_TO_L_TYPES.clear()
    for declared in sorted(declared_types):
        if _is_canonical_l_type(declared):
            LEGACY_TO_L_TYPES.setdefault(declared[1:], declared)

    for type_name in opaque_types:
        # Keep public class universe L-prefixed and avoid creating free-floating
        # non-L classes in the global stub namespace.
        if not _is_canonical_l_type(type_name):
            continue
        if type_name in _OPAQUE_ALIASES:
            out.append(f"---@alias {type_name} {_OPAQUE_ALIASES[type_name]}")
            out.append("")
        else:
            out.append(f"---@class {type_name}")
            out.append(f"{type_name} = {{}}")
            out.append("")

    for enum_name in sorted(source_enums.keys()):
        values = source_enums[enum_name]
        if not values:
            continue
        union = "|".join(json.dumps(value) for value in values)
        out.append(f"---@alias {enum_name} {union}")
        out.append("")

    generated_result_classes = collect_generated_result_classes(lua_api, _LUA_NAMESPACE)
    for class_name in sorted(generated_result_classes.keys()):
        out.append(f"---@class {class_name}")
        fields = generated_result_classes[class_name]["fields"]
        for field_name in sorted(fields.keys()):
            field = fields[field_name]
            if field["description"]:
                out.append(f"---@field {field['name']} {field['type']} {field['description']}")
            else:
                out.append(f"---@field {field['name']} {field['type']}")
        out.append(f"{class_name} = {{}}")
        out.append("")

    nested_namespaces = collect_nested_namespaces(lua_api, _LUA_NAMESPACE)

    namespace_decls = collect_namespace_declarations(
        lua_api,
        _LUA_NAMESPACE,
        nested_namespaces,
    )

    for ns in namespace_decls:
        out.append(f"---@class lurek.{ns['lua_ns']}")
        out.append(f"lurek.{ns['lua_ns']} = {{}}")
        out.append("")
        for sub_ns in ns["nested"]:
            out.append(f"---@class lurek.{ns['lua_ns']}.{sub_ns}")
            out.append(f"lurek.{ns['lua_ns']}.{sub_ns} = {{}}")
            out.append("")

    for cls in collect_userdata_class_declarations(lua_api):
        if cls["description"]:
            for line in cls["description"].splitlines():
                out.append(f"--- {line}")
        out.append(f"---@class {cls['class_decl']}")
        class_name = cls["class_name"]
        for field in cls.get("fields", []):
            fname = field.get("name", "").strip()
            if not fname:
                continue
            ftype = normalize_type(field.get("type", "any"))
            fdesc = field.get("description", "").strip()
            if fdesc:
                out.append(f"---@field {fname} {ftype} {fdesc}")
            else:
                out.append(f"---@field {fname} {ftype}")
        out.append(f"{class_name} = {{}}")
        out.append("")

    for mod_name in sorted(lua_api.keys()):
        lua_ns = _LUA_NAMESPACE.get(mod_name, mod_name)
        mod_data = lua_api[mod_name]

        classes = mod_data.get("classes", {})
        for class_name in sorted(classes.keys()):
            class_data = classes[class_name]
            methods = class_data.get("methods", [])
            methods.sort(key=lambda x: x.get("name", ""))

            for method in methods:
                name = method.get("lua_name", f"{class_name}:{method['name']}")
                # fallback for missing lua_name:
                if ":" not in name and ("." not in name):
                    name = f"{class_name}:{method['name']}"
                # Class methods must use : notation so LuaLS treats self as implicit.
                # Some lua_name values use ClassName.method (dot) instead of ClassName:method.
                elif "." in name and ":" not in name:
                    last_dot = name.rfind(".")
                    name = name[:last_dot] + ":" + name[last_dot + 1:]
                write_function_doc(out, method, name)

        functions = mod_data.get("functions", [])
        functions.sort(key=lambda x: (x.get("kind", "function"), x.get("name", "")))

        for func in functions:
            name = func.get("lua_name", f"lurek.{lua_ns}.{func['name']}")
            if ":" in name:
                continue
            # Remap stored lua_name only when the module folder name differs from
            # the Lua namespace (e.g. timerâ†’time, eventâ†’signal).  When mod_name==lua_ns
            # the lua_name is already correct â€” preserve nested paths (keyboard.isDown etc.).
            if mod_name != lua_ns and name.startswith(f"lurek.{mod_name}."):
                name = f"lurek.{lua_ns}." + name[len(f"lurek.{mod_name}."):]
            write_function_doc(out, func, name)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(out))

    print(f"Generated {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
