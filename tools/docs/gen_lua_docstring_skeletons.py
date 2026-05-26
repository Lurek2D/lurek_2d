#!/usr/bin/env python3
"""gen_lua_docstring_skeletons.py -- Rebuild Lua API docstring skeletons from Rust source only.

This generator reads only `src/lua_api/**/*.rs`. It ignores existing `///`
docstrings and derives fresh skeleton blocks from Rust definitions:

- public Rust items (`pub struct`, `pub enum`, `pub fn`, ...)
- Lua-exposed table functions (`tbl.set(..., lua.create_function(...))`)
- Lua userdata methods (`methods.add_method*`, `methods.add_function`)
- Lua userdata field accessors (`fields.add_field_method_get/set`)

It writes a reviewable file with regenerated `///` blocks so the current source
can be re-documented from definitions instead of reusing stale descriptions.

Usage:
    python tools/docs/gen_lua_docstring_skeletons.py
    python tools/docs/gen_lua_docstring_skeletons.py src/lua_api/timer_api.rs
    python tools/docs/gen_lua_docstring_skeletons.py --format markdown
    python tools/docs/gen_lua_docstring_skeletons.py --output logs/data/custom_docstrings.json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Iterable, List, Optional

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_TARGET = WORKSPACE_ROOT / "src" / "lua_api"
DEFAULT_MD_OUTPUT = WORKSPACE_ROOT / "logs" / "reports" / "lua_docstring_skeletons.md"
DEFAULT_JSON_OUTPUT = WORKSPACE_ROOT / "logs" / "data" / "lua_docstring_skeletons.json"

PUBLIC_ITEM_RE = re.compile(
    r"^\s*pub\s+(?:unsafe\s+)?(struct|enum|fn|trait|type|const|static)\s+([A-Za-z_]\w*)"
)
STRUCT_RE = re.compile(r"^\s*pub\s+struct\s+([A-Za-z_]\w*)")
ENUM_RE = re.compile(r"^\s*pub\s+enum\s+([A-Za-z_]\w*)")
ENUM_VARIANT_RE = re.compile(r"^\s*([A-Z][A-Za-z0-9_]*)\s*(?:,|\(|\{|=)")
PUBLIC_FN_RE = re.compile(r"^\s*pub\s+fn\s+([A-Za-z_]\w*)\s*\(")
TYPE_NAME_IMPL_RE = re.compile(r"^\s*impl(?:<[^>]*>)?\s+LunaType\s+for\s+(\w+)")
USERDATA_IMPL_RE = re.compile(r"^\s*impl(?:<[^>]*>)?\s+LuaUserData\s+for\s+(\w+)")
METHOD_RE = re.compile(r'\bmethods\.add_method(?:_mut)?\(\s*"([^"]+)"')
CLASS_FUNCTION_RE = re.compile(r'\bmethods\.add_function\(\s*"([^"]+)"')
FIELD_GET_RE = re.compile(r'\bfields\.add_field_method_get\(\s*"([^"]+)"')
FIELD_SET_RE = re.compile(r'\bfields\.add_field_method_set\(\s*"([^"]+)"')
SET_START_RE = re.compile(r"\.set\s*\(")
SET_NAME_RE = re.compile(r'^\s*"([^"]+)"\s*,')
CREATE_FUNCTION_RE = re.compile(r"create_function(?:_mut)?\s*\(")
MODULE_SET_RE = re.compile(r'\b(?:lurek|luna|luna_table|lurek_table)\.set\(\s*"([^"]+)"')
FIELD_RE = re.compile(r"^\s*([A-Za-z_]\w*)\s*:\s*([^,]+),?\s*$")


@dataclass
class Param:
    name: str
    rust_type: str
    lua_type: str


@dataclass
class Entry:
    file: str
    line: int
    kind: str
    name: str
    signature: str
    description: str
    owner: Optional[str] = None
    namespace: Optional[str] = None
    params: List[Param] = field(default_factory=list)
    returns: List[str] = field(default_factory=list)

    def to_doc_lines(self) -> List[str]:
        lines = [f"/// {self.description}"]
        for param in self.params:
            lines.append(f"/// @param {param.name} {param.lua_type}")
        if self.returns:
            lines.append(f"/// @return {', '.join(self.returns)}")
        return lines


def resolve_relative(path: Path) -> str:
    return str(path.resolve().relative_to(WORKSPACE_ROOT.resolve())).replace("\\", "/")


def read_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8").splitlines()


def split_top_level(text: str, separator: str = ",") -> List[str]:
    parts: List[str] = []
    current: List[str] = []
    angle = 0
    paren = 0
    bracket = 0
    brace = 0
    for char in text:
        if char == "<":
            angle += 1
        elif char == ">" and angle > 0:
            angle -= 1
        elif char == "(":
            paren += 1
        elif char == ")" and paren > 0:
            paren -= 1
        elif char == "[":
            bracket += 1
        elif char == "]" and bracket > 0:
            bracket -= 1
        elif char == "{":
            brace += 1
        elif char == "}" and brace > 0:
            brace -= 1

        if char == separator and angle == 0 and paren == 0 and bracket == 0 and brace == 0:
            part = "".join(current).strip()
            if part:
                parts.append(part)
            current = []
            continue
        current.append(char)

    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return parts


def humanize(name: str) -> List[str]:
    normalized = name.replace("_", " ")
    normalized = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", normalized)
    normalized = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1 \2", normalized)
    return [part.lower() for part in normalized.split() if part]


def title_words(words: Iterable[str]) -> str:
    return " ".join(word.capitalize() for word in words if word)


def strip_common_wrappers(type_expr: str) -> str:
    result = type_expr.strip()
    wrappers = (
        ("Rc<RefCell<", ">>"),
        ("Arc<Mutex<", ">>"),
        ("RefCell<", ">"),
        ("Rc<", ">"),
        ("Arc<", ">"),
        ("Box<", ">"),
        ("Option<", ">"),
    )
    changed = True
    while changed:
        changed = False
        for prefix, suffix in wrappers:
            if result.startswith(prefix) and result.endswith(suffix):
                result = result[len(prefix) : len(result) - len(suffix)].strip()
                changed = True
    return result


def build_type_name_map(files: List[Path]) -> dict[str, str]:
    type_names: dict[str, str] = {}
    for path in files:
        lines = read_lines(path)
        index = 0
        while index < len(lines):
            match = TYPE_NAME_IMPL_RE.match(lines[index])
            if not match:
                index += 1
                continue
            owner = match.group(1)
            depth = 0
            saw_open = False
            block: List[str] = []
            cursor = index
            while cursor < len(lines):
                raw = lines[cursor]
                stripped = raw.strip()
                if not stripped.startswith("//"):
                    for char in raw:
                        if char == "{":
                            depth += 1
                            saw_open = True
                        elif char == "}" and depth > 0:
                            depth -= 1
                block.append(raw)
                if saw_open and depth <= 0:
                    break
                cursor += 1
            block_text = "\n".join(block)
            type_match = re.search(r'const TYPE_NAME[^=]*=\s*"([^"]+)"', block_text)
            if type_match:
                type_names[owner] = type_match.group(1)
            index = cursor + 1
    return type_names


def map_rust_type(type_expr: str, type_names: dict[str, str]) -> str:
    type_expr = type_expr.strip()
    if not type_expr:
        return "any"
    if type_expr.startswith("&"):
        return map_rust_type(type_expr[1:].strip(), type_names)
    if type_expr.startswith("LuaResult<") and type_expr.endswith(">"):
        return map_rust_type(type_expr[len("LuaResult<") : -1], type_names)
    if type_expr.startswith("Result<") and type_expr.endswith(">"):
        inner_parts = split_top_level(type_expr[len("Result<") : -1])
        if inner_parts:
            return map_rust_type(inner_parts[0], type_names)
    if type_expr.startswith("Option<") and type_expr.endswith(">"):
        inner = map_rust_type(type_expr[7:-1], type_names)
        return inner if inner.endswith("?") else f"{inner}?"
    if type_expr.startswith("Vec<") and type_expr.endswith(">"):
        inner = map_rust_type(type_expr[4:-1], type_names)
        return f"{inner}[]" if inner not in {"any", "table"} else "table"
    if type_expr.startswith("(") and type_expr.endswith(")"):
        inner = [map_rust_type(part, type_names) for part in split_top_level(type_expr[1:-1])]
        return ", ".join(inner) if inner else "nil"

    scalar_map = {
        "()": "nil",
        "bool": "boolean",
        "f32": "number",
        "f64": "number",
        "i8": "integer",
        "i16": "integer",
        "i32": "integer",
        "i64": "integer",
        "isize": "integer",
        "u8": "integer",
        "u16": "integer",
        "u32": "integer",
        "u64": "integer",
        "usize": "integer",
        "String": "string",
        "str": "string",
        "Lua": "lua_vm",
        "LuaString": "string",
        "LuaTable": "table",
        "LuaValue": "any",
        "LuaMultiValue": "any...",
        "LuaFunction": "function",
        "LuaAnyUserData": "userdata",
        "LuaRegistryKey": "registry_key",
    }
    if type_expr in scalar_map:
        return scalar_map[type_expr]

    if type_expr in type_names:
        return type_names[type_expr]

    stripped = strip_common_wrappers(type_expr)
    if stripped != type_expr:
        return map_rust_type(stripped, type_names)

    tail = type_expr.split("::")[-1]
    if tail in type_names:
        return type_names[tail]
    if tail.startswith("Lua"):
        return type_names.get(tail, tail[3:] or tail)
    return tail


def find_block_end(lines: List[str], start_index: int) -> int:
    depth = 0
    saw_open = False
    limit = min(len(lines), start_index + 160)
    for cursor in range(start_index, limit):
        stripped = lines[cursor].strip()
        if stripped.startswith("//"):
            continue
        for char in lines[cursor]:
            if char == "{":
                depth += 1
                saw_open = True
            elif char == "}" and depth > 0:
                depth -= 1
        if saw_open and depth <= 0:
            return cursor
        if not saw_open and stripped.endswith(");"):
            return cursor
    return min(len(lines) - 1, start_index + 40)


def closure_signature_text(lines: List[str], start_index: int) -> str:
    parts: List[str] = []
    pipe_count = 0
    started = False
    for raw in lines[start_index : min(len(lines), start_index + 8)]:
        stripped = raw.strip()
        if not started and "|" not in stripped:
            continue
        started = True
        parts.append(stripped)
        pipe_count += stripped.count("|")
        if pipe_count >= 2:
            break
    return " ".join(parts)


def extract_closure_params(
    lines: List[str],
    start_index: int,
    type_names: dict[str, str],
    *,
    skip_implicit_this: bool,
) -> List[Param]:
    text = closure_signature_text(lines, start_index)
    if not text:
        return []

    multi_match = re.search(r"\|[^|]*?,\s*\(([^)]+)\):\s*\(([^)]+)\)", text)
    if multi_match:
        names = [name.strip().lstrip("_") for name in split_top_level(multi_match.group(1))]
        types = [type_part.strip() for type_part in split_top_level(multi_match.group(2))]
        params = [
            Param(name, type_part.strip(), map_rust_type(type_part, type_names))
            for name, type_part in zip(names, types)
            if name and name not in {"lua", "_lua", "this"}
        ]
        if skip_implicit_this:
            return [param for param in params if param.name != "this"]
        return params

    single_tuple_match = re.search(r"\|[^|]*?,\s*\(([a-z_]\w*)\s*,?\):\s*\(([^,)]+),?\)", text)
    if single_tuple_match:
        name = single_tuple_match.group(1).lstrip("_")
        if skip_implicit_this and name == "this":
            return []
        raw_type = single_tuple_match.group(2).strip()
        return [Param(name, raw_type, map_rust_type(raw_type, type_names))]

    params_match = re.search(r"\|([^|]+)\|", text)
    if not params_match:
        return []

    raw_params = [part.strip() for part in split_top_level(params_match.group(1))]
    if raw_params:
        raw_params = raw_params[1:]
    if skip_implicit_this and raw_params:
        first = raw_params[0]
        if first == "this" or first.startswith("this:"):
            raw_params = raw_params[1:]

    params: List[Param] = []
    for raw_param in raw_params:
        if raw_param in {"()", "_", ""}:
            continue
        if ":" not in raw_param:
            continue
        name, type_expr = raw_param.split(":", 1)
        clean_name = name.strip().lstrip("_")
        if not clean_name:
            continue
        raw_type = type_expr.strip()
        params.append(Param(clean_name, raw_type, map_rust_type(raw_type, type_names)))
    return params


def extract_public_fn_signature(lines: List[str], start_index: int, name: str, type_names: dict[str, str]) -> tuple[List[Param], List[str], str]:
    block_parts: List[str] = []
    for raw in lines[start_index : min(len(lines), start_index + 12)]:
        block_parts.append(raw.strip())
        if "{" in raw or raw.strip().endswith(";"):
            break
    signature = " ".join(block_parts)
    open_paren = signature.find("(")
    close_paren = -1
    if open_paren != -1:
        depth = 0
        for offset, char in enumerate(signature[open_paren:], start=open_paren):
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    close_paren = offset
                    break
    params: List[Param] = []
    if open_paren != -1 and close_paren != -1 and close_paren > open_paren:
        for raw_param in split_top_level(signature[open_paren + 1 : close_paren]):
            if not raw_param or raw_param in {"self", "&self", "&mut self"}:
                continue
            if ":" not in raw_param:
                continue
            param_name, type_expr = raw_param.split(":", 1)
            raw_type = type_expr.strip()
            params.append(Param(param_name.strip(), raw_type, map_rust_type(raw_type, type_names)))

    returns: List[str] = []
    ret_match = re.search(r"->\s*([^\{;]+)", signature)
    if ret_match:
        mapped = map_rust_type(ret_match.group(1).strip(), type_names)
        if mapped:
            returns = [part.strip() for part in split_top_level(mapped) if part.strip()]
    return params, returns, signature


def infer_return_from_body(lines: List[str], start_index: int, type_names: dict[str, str]) -> List[str]:
    end_index = find_block_end(lines, start_index)
    body = "\n".join(lines[start_index : end_index + 1])

    match = re.search(r"Ok\(Some\(lua_(\w+)_new\(", body)
    if match:
        created = "Lua" + "".join(part.capitalize() for part in match.group(1).split("_"))
        return [map_rust_type(created, type_names) + "?"]

    match = re.search(r"Ok\(lua_(\w+)_new\(", body)
    if match:
        created = "Lua" + "".join(part.capitalize() for part in match.group(1).split("_"))
        return [map_rust_type(created, type_names)]

    if "create_table()" in body and re.search(r"Ok\((?:tbl|table)\b", body):
        return ["table"]
    if "create_sequence_from" in body:
        return ["table"]
    if "create_string" in body:
        return ["string"]
    if re.search(r"Ok\s*\(\s*\(\s*\)\s*\)", body):
        return ["nil"]
    if re.search(r"Ok\((true|false)\b", body):
        return ["boolean"]
    if re.search(r"\.is_[a-z_]+\(|\.has_[a-z_]+\(|\.contains\(|\.eq\(", body):
        return ["boolean"]
    if re.search(r"\.len\(\)|\.count\(\)|\.size\(\)| as u(?:8|16|32|64|size)| as i(?:8|16|32|64|size)", body):
        return ["integer"]
    if re.search(r" as f(?:32|64)|\.elapsed_time\(|\.delta\(|\.dt\b", body):
        return ["number"]
    if re.search(r"\.to_string\(\)|String::|LuaString", body):
        return ["string"]
    borrow_match = re.search(r"borrow::<(Lua\w+)>", body)
    if borrow_match:
        return [map_rust_type(borrow_match.group(1), type_names)]
    ok_match = re.search(r"Ok\(([^\n]+)\)", body)
    if ok_match:
        payload = ok_match.group(1).strip()
        if payload.startswith("(") and payload.endswith(")"):
            mapped = map_rust_type(payload, type_names)
            return [part.strip() for part in split_top_level(mapped) if part.strip()]
        if payload in {"None", "nil"}:
            return ["nil"]
        return ["any"]
    return ["any"]


def namespace_for_file(lines: List[str], file_path: Path) -> str:
    matches = [match.group(1) for line in lines for match in MODULE_SET_RE.finditer(line)]
    if matches:
        return f"lurek.{matches[-1]}"
    return f"lurek.{file_path.stem.replace('_api', '')}"


def describe_from_name(name: str, params: List[Param], returns: List[str], *, kind: str, namespace: Optional[str] = None) -> str:
    words = humanize(name)
    rest = " ".join(words[1:]).strip()
    first = words[0] if words else name.lower()
    has_callback = any(param.lua_type == "function" or param.name in {"func", "callback", "fn", "f"} for param in params)
    has_delay = any(param.name in {"delay", "interval", "seconds", "time_horizon", "duration"} for param in params)
    has_frames = any(param.name in {"n", "frames", "frame_count"} for param in params) or "frames" in name.lower()

    if kind == "register" and namespace:
        return f"Registers `{namespace}` in the Lua VM."
    if kind == "field_get":
        return f"Returns the `{name}` field."
    if kind == "field_set":
        return f"Sets the `{name}` field."
    if name == "type":
        return "Returns the type name."
    if name == "typeOf":
        return "Returns whether the value matches a type name."
    if first == "new":
        return f"Creates a new {rest or 'value'}."
    if first in {"create", "make", "build"}:
        return f"Creates {rest or 'a value'}."
    if first in {"get", "fetch", "read"}:
        return f"Returns {rest or 'a value'}."
    if first in {"set", "write", "assign"}:
        return f"Sets {rest or 'a value'}."
    if first in {"is", "has", "can", "contains"}:
        return f"Returns whether {rest or name} is true."
    if first in {"add", "append", "push", "insert"}:
        return f"Adds {rest or 'a value'}."
    if first in {"remove", "delete", "pop"}:
        return f"Removes {rest or 'a value'}."
    if first in {"clear", "reset"}:
        return f"Clears {rest or 'the state'}."
    if first in {"update", "refresh", "step"}:
        return f"Updates {rest or 'the state'}."
    if first == "load":
        return f"Loads {rest or 'data'}."
    if first == "save":
        return f"Saves {rest or 'data'}."
    if first == "pause":
        return f"Pauses {rest or 'the state'}."
    if first == "resume":
        return f"Resumes {rest or 'the state'}."
    if first == "cancel":
        return f"Cancels {rest or 'the operation'}."
    if first == "after" and has_callback and has_frames:
        return "Schedules a callback after a number of frames."
    if first == "after" and has_callback and has_delay:
        return "Schedules a callback after a delay."
    if first == "after" and has_callback:
        return "Schedules a callback to run later."
    if first == "every" and has_callback and has_frames:
        return "Schedules a callback to run every number of frames."
    if first == "every" and has_callback:
        return "Schedules a callback to run repeatedly."
    if first == "wait" and has_frames:
        return "Waits for a number of frames."
    if first == "wait":
        return "Waits for completion."
    if first == "on" and has_callback:
        return f"Registers a callback for {rest or 'an event'}."
    if first == "from":
        return f"Creates a value from {rest or 'input data'}."
    if returns == ["boolean"]:
        return f"Returns whether {rest or title_words(words)} is available."
    return f"Handles {rest or title_words(words)}."


def describe_struct(name: str, lines: List[str], start_index: int, type_names: dict[str, str]) -> str:
    end_index = find_block_end(lines, start_index)
    preferred_field_type: Optional[str] = None
    for raw in lines[start_index + 1 : end_index + 1]:
        field_match = FIELD_RE.match(raw)
        if not field_match:
            continue
        field_name, type_expr = field_match.group(1), field_match.group(2).strip()
        if field_name in {"callbacks", "named_ids", "registry", "inner_callbacks"}:
            continue
        preferred_field_type = strip_common_wrappers(type_expr)
        if field_name in {"inner", "scheduler", "world", "state", "manager", "font", "image", "mesh"}:
            break
    if preferred_field_type:
        mapped = map_rust_type(preferred_field_type, type_names)
        return f"Lua-side wrapper around `{mapped}`."
    if name.startswith("Lua"):
        return f"Lua-side wrapper for `{type_names.get(name, name[3:] or name)}`."
    return f"Represents `{name}`."


def describe_enum(name: str) -> str:
    return f"Enumerates available {title_words(humanize(name)) or name} values."


def describe_variant(enum_name: str, variant_name: str) -> str:
    return f"Represents the {title_words(humanize(variant_name)) or variant_name} state of `{enum_name}`."


def detect_table_function_name(lines: List[str], start_index: int) -> Optional[str]:
    window = lines[start_index : min(len(lines), start_index + 8)]
    block = "\n".join(window)
    if ".set" not in lines[start_index] or not CREATE_FUNCTION_RE.search(block):
        return None

    inline = re.search(r'\.set\s*\(\s*"([^"]+)"\s*,', block)
    if inline:
        return inline.group(1)

    saw_set = False
    for raw in window:
        if not saw_set and SET_START_RE.search(raw):
            saw_set = True
            continue
        if not saw_set:
            continue
        stripped = raw.strip()
        if not stripped or stripped.startswith("//"):
            continue
        match = SET_NAME_RE.match(stripped)
        if match:
            return match.group(1)
        break
    return None


def collect_entries(path: Path, type_names: dict[str, str]) -> List[Entry]:
    lines = read_lines(path)
    namespace = namespace_for_file(lines, path)
    entries: List[Entry] = []

    for index, raw in enumerate(lines):
        stripped = raw.strip()
        if stripped.startswith("//"):
            continue

        struct_match = STRUCT_RE.match(raw)
        if struct_match:
            name = struct_match.group(1)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="rust_struct",
                    name=name,
                    signature=stripped,
                    description=describe_struct(name, lines, index, type_names),
                )
            )
            continue

        enum_match = ENUM_RE.match(raw)
        if enum_match:
            enum_name = enum_match.group(1)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="rust_enum",
                    name=enum_name,
                    signature=stripped,
                    description=describe_enum(enum_name),
                )
            )
            end_index = find_block_end(lines, index)
            for variant_index in range(index + 1, end_index + 1):
                variant_match = ENUM_VARIANT_RE.match(lines[variant_index].strip())
                if not variant_match:
                    continue
                variant_name = variant_match.group(1)
                entries.append(
                    Entry(
                        file=resolve_relative(path),
                        line=variant_index + 1,
                        kind="rust_enum_variant",
                        name=f"{enum_name}.{variant_name}",
                        signature=lines[variant_index].strip(),
                        description=describe_variant(enum_name, variant_name),
                    )
                )
            continue

        public_match = PUBLIC_ITEM_RE.match(raw)
        if public_match and public_match.group(1) != "enum" and public_match.group(1) != "struct":
            kind, name = public_match.group(1), public_match.group(2)
            params: List[Param] = []
            returns: List[str] = []
            signature = stripped
            if kind == "fn":
                params, returns, signature = extract_public_fn_signature(lines, index, name, type_names)
            description_kind = "register" if name == "register" else kind
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind=f"rust_{kind}",
                    name=name,
                    signature=signature,
                    description=describe_from_name(name, params, returns, kind=description_kind, namespace=namespace),
                    namespace=namespace if name == "register" else None,
                    params=params,
                    returns=returns,
                )
            )

    current_owner: Optional[str] = None
    current_owner_display: Optional[str] = None
    brace_depth = 0
    owner_depth = 0

    for index, raw in enumerate(lines):
        stripped = raw.strip()
        if not stripped.startswith("//"):
            brace_depth += raw.count("{") - raw.count("}")

        owner_match = USERDATA_IMPL_RE.match(raw)
        if owner_match:
            current_owner = owner_match.group(1)
            current_owner_display = type_names.get(current_owner, current_owner)
            owner_depth = brace_depth

        if current_owner is not None and brace_depth < owner_depth:
            current_owner = None
            current_owner_display = None
            owner_depth = 0

        if stripped.startswith("//"):
            continue

        method_match = METHOD_RE.search(raw)
        if method_match and not method_match.group(1).startswith("__"):
            name = method_match.group(1)
            params = extract_closure_params(lines, index, type_names, skip_implicit_this=True)
            returns = infer_return_from_body(lines, index, type_names)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="lua_method",
                    name=f"{current_owner_display or current_owner or 'LuaUserData'}.{name}",
                    signature=stripped,
                    description=describe_from_name(name, params, returns, kind="method"),
                    owner=current_owner_display or current_owner,
                    namespace=namespace,
                    params=params,
                    returns=returns,
                )
            )
            continue

        class_fn_match = CLASS_FUNCTION_RE.search(raw)
        if class_fn_match and not class_fn_match.group(1).startswith("__"):
            name = class_fn_match.group(1)
            params = extract_closure_params(lines, index, type_names, skip_implicit_this=False)
            returns = infer_return_from_body(lines, index, type_names)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="lua_class_function",
                    name=f"{current_owner_display or current_owner or 'LuaUserData'}.{name}",
                    signature=stripped,
                    description=describe_from_name(name, params, returns, kind="class_function"),
                    owner=current_owner_display or current_owner,
                    namespace=namespace,
                    params=params,
                    returns=returns,
                )
            )
            continue

        field_get_match = FIELD_GET_RE.search(raw)
        if field_get_match and not field_get_match.group(1).startswith("__"):
            name = field_get_match.group(1)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="lua_field_get",
                    name=f"{current_owner_display or current_owner or 'LuaUserData'}.{name}",
                    signature=stripped,
                    description=describe_from_name(name, [], ["any"], kind="field_get"),
                    owner=current_owner_display or current_owner,
                    namespace=namespace,
                    returns=infer_return_from_body(lines, index, type_names),
                )
            )
            continue

        field_set_match = FIELD_SET_RE.search(raw)
        if field_set_match and not field_set_match.group(1).startswith("__"):
            name = field_set_match.group(1)
            params = extract_closure_params(lines, index, type_names, skip_implicit_this=True)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="lua_field_set",
                    name=f"{current_owner_display or current_owner or 'LuaUserData'}.{name}",
                    signature=stripped,
                    description=describe_from_name(name, params, ["nil"], kind="field_set"),
                    owner=current_owner_display or current_owner,
                    namespace=namespace,
                    params=params,
                    returns=["nil"],
                )
            )
            continue

        table_function_name = detect_table_function_name(lines, index)
        if table_function_name and not table_function_name.startswith("__"):
            params = extract_closure_params(lines, index, type_names, skip_implicit_this=False)
            returns = infer_return_from_body(lines, index, type_names)
            entries.append(
                Entry(
                    file=resolve_relative(path),
                    line=index + 1,
                    kind="lua_function",
                    name=f"{namespace}.{table_function_name}",
                    signature=stripped,
                    description=describe_from_name(table_function_name, params, returns, kind="function"),
                    namespace=namespace,
                    params=params,
                    returns=returns,
                )
            )

    return entries


def format_markdown(entries: List[Entry], target: Path) -> str:
    lines = [
        "# Lua API Docstring Skeletons",
        "",
        "Generated from Rust definitions only. Existing `///` docstrings were ignored.",
        "",
        f"Target: `{target}`",
        "",
    ]

    by_file: dict[str, List[Entry]] = {}
    for entry in entries:
        by_file.setdefault(entry.file, []).append(entry)

    for file_path in sorted(by_file):
        lines.append(f"## `{file_path}`")
        lines.append("")
        for entry in sorted(by_file[file_path], key=lambda item: (item.line, item.name)):
            lines.append(f"### {entry.kind}: `{entry.name}`")
            lines.append("")
            lines.append(f"Source: line {entry.line}")
            lines.append("")
            lines.append("```rust")
            for doc_line in entry.to_doc_lines():
                lines.append(doc_line)
            lines.append("```")
            lines.append("")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def serialize_entry(entry: Entry) -> dict:
    return {
        "file": entry.file,
        "line": entry.line,
        "kind": entry.kind,
        "name": entry.name,
        "owner": entry.owner,
        "namespace": entry.namespace,
        "signature": entry.signature,
        "description": entry.description,
        "params": [
            {
                "name": param.name,
                "rust_type": param.rust_type,
                "lua_type": param.lua_type,
            }
            for param in entry.params
        ],
        "returns": entry.returns,
        "doc_lines": entry.to_doc_lines(),
    }


def choose_default_output(fmt: str) -> Path:
    return DEFAULT_JSON_OUTPUT if fmt == "json" else DEFAULT_MD_OUTPUT


def collect_files(target: Path) -> List[Path]:
    if target.is_file():
        return [target.resolve()]
    if target.is_dir():
        return sorted(path.resolve() for path in target.glob("*.rs") if path.is_file())
    raise FileNotFoundError(f"Target not found: {target}")


def main(argv: Optional[List[str]] = None) -> int:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/docs/gen_lua_docstring_skeletons.py

  # Show all arguments
  python tools/docs/gen_lua_docstring_skeletons.py --help
"""
    parser = argparse.ArgumentParser(
        description="Rebuild Lua API docstring skeletons from Rust source only.",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "target",
        nargs="?",
        default=str(DEFAULT_TARGET),
        help="Path to src/lua_api file or directory (default: src/lua_api).",
    )
    parser.add_argument(
        "--format",
        choices=("markdown", "json"),
        default="json",
        help="Output file format.",
    )
    parser.add_argument(
        "--output",
        help="Output path. Defaults to logs/data/lua_docstring_skeletons.json or logs/reports/lua_docstring_skeletons.md.",
    )
    args = parser.parse_args(argv)

    try:
        target = Path(args.target).resolve()
        files = collect_files(target)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    type_names = build_type_name_map(files)
    entries: List[Entry] = []
    for path in files:
        entries.extend(collect_entries(path, type_names))

    output_path = Path(args.output).resolve() if args.output else choose_default_output(args.format)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if args.format == "json":
        payload = {
            "target": str(target),
            "source_only": True,
            "ignored_existing_docstrings": True,
            "entry_count": len(entries),
            "entries": [serialize_entry(entry) for entry in entries],
        }
        output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    else:
        output_path.write_text(format_markdown(entries, target), encoding="utf-8")

    print(f"Wrote {len(entries)} source-derived docstring skeleton entries to {output_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
