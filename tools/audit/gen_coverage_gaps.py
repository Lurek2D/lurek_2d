#!/usr/bin/env python3
"""
gen_coverage_gaps.py — Generate an API gap report for Lurek2D.

Reads rust_api_data.json and lua_api_data.json, then produces a Markdown report
showing three categories of issues:

  1. Rust methods that exist publicly but are NOT exposed to Lua (no matching entry in
     lua_api_data.json). This highlights functionality that game developers cannot access.

  2. Rust public items with missing or very short docstrings (< 25 chars). These will
     produce "(undocumented)" entries in rust-api.md.

  3. Lua API functions and classes with missing descriptions. These will appear without
     helpful documentation in lua-api.md.

Usage:
    python tools/gen_coverage_gaps.py                    # -> logs/reports/coverage_gaps.md
    python tools/gen_coverage_gaps.py --output FILE      # custom output path
    python tools/gen_coverage_gaps.py --rust-input FILE  # custom Rust JSON
    python tools/gen_coverage_gaps.py --lua-input FILE   # custom Lua JSON

Exit codes:
    0 — success
    1 — fatal error (missing input)
"""

import argparse
import json
import re
import sys
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
RUST_INPUT = WORKSPACE_ROOT / "logs" / "data" / "rust_api_data.json"
LUA_INPUT = WORKSPACE_ROOT / "logs" / "data" / "lua_api_data.json"
OUTPUT_FILE = WORKSPACE_ROOT / "logs" / "reports" / "coverage_gaps.md"

# Minimum description length to be considered "documented"
_MIN_DESC_LENGTH = 25

SRC_LUA_API_DIR = WORKSPACE_ROOT / "src" / "lua_api"
_RUST_USE_RE = re.compile(r"use\s+crate::(.*?);", re.DOTALL)
_PRIVATE_FN_RE = re.compile(r"(?m)^fn\s+(\w+)\b[^\{]*\{")
_PUBLIC_FN_RE = re.compile(r"(?m)^pub(?:\([^)]*\))?\s+fn\s+(\w+)\b[^\{]*\{")
_SET_BLOCK_START_RE = re.compile(r"\.set\(\s*\"")
_ADD_METHODS_RE = re.compile(r"fn\s+add_methods\b")
_CALL_TOKEN_RE = re.compile(r"(?<!\.)\b(crate::[A-Za-z_][A-Za-z0-9_:]*|[A-Za-z_][A-Za-z0-9_]*)\s*\(")
_PATH_TOKEN_RE = re.compile(r"(?<!\.)\bcrate::[A-Za-z_][A-Za-z0-9_:]*|(?<!\.)\b[A-Za-z_][A-Za-z0-9_]*::[A-Za-z_][A-Za-z0-9_:]*")
_RUST_KEYWORDS = {
    "if", "for", "while", "loop", "match", "return", "Ok", "Err", "Some", "None",
}


def _split_top_level(text: str, delimiter: str = ",") -> list[str]:
    parts: list[str] = []
    current: list[str] = []
    depth = 0
    for char in text:
        if char == "{":
            depth += 1
        elif char == "}":
            depth = max(0, depth - 1)
        if char == delimiter and depth == 0:
            part = "".join(current).strip()
            if part:
                parts.append(part)
            current = []
            continue
        current.append(char)
    part = "".join(current).strip()
    if part:
        parts.append(part)
    return parts


def _expand_use_tree(expr: str, imports: dict[str, str], prefix: str = "") -> None:
    expr = re.sub(r"\s+", " ", expr.strip())
    if not expr:
        return
    if "{" not in expr:
        target = f"{prefix}::{expr}" if prefix else expr
        alias_match = re.match(r"(.+?)\s+as\s+(\w+)$", target)
        if alias_match:
            target = alias_match.group(1).strip()
            local_name = alias_match.group(2).strip()
        else:
            local_name = target.split("::")[-1]
        if local_name != "*":
            imports[local_name] = target
        return

    prefix_part, remainder = expr.split("{", 1)
    new_prefix = prefix_part.rstrip(": ")
    if prefix:
        new_prefix = f"{prefix}::{new_prefix}" if new_prefix else prefix
    inner = remainder.rsplit("}", 1)[0]
    for part in _split_top_level(inner):
        _expand_use_tree(part, imports, new_prefix)


def _collect_imports(source: str) -> dict[str, str]:
    imports: dict[str, str] = {}
    for match in _RUST_USE_RE.finditer(source):
        _expand_use_tree(match.group(1), imports)
    return imports


def _extract_block(source: str, start_index: int, open_char: str, close_char: str) -> tuple[str, int]:
    depth = 0
    end_index = start_index
    for end_index in range(start_index, len(source)):
        char = source[end_index]
        if char == open_char:
            depth += 1
        elif char == close_char:
            depth -= 1
            if depth == 0:
                return source[start_index + 1:end_index], end_index
    return "", len(source)


def _extract_create_function_arg(block: str) -> str:
    marker = "create_function"
    marker_index = block.find(marker)
    if marker_index == -1:
        return ""
    paren_index = block.find("(", marker_index)
    if paren_index == -1:
        return ""
    inner, _ = _extract_block(block, paren_index, "(", ")")
    return inner.strip()


def _normalize_rust_path(path: str) -> tuple[str, str] | None:
    cleaned = path.strip()
    if cleaned.startswith("crate::"):
        cleaned = cleaned[len("crate::"):]
    if "::" not in cleaned:
        return None
    module, name = cleaned.rsplit("::", 1)
    return module, name


def _collect_call_targets(expr: str, imports: dict[str, str]) -> set[str]:
    targets: set[str] = set()
    for match in _CALL_TOKEN_RE.finditer(expr):
        token = match.group(1)
        if token in _RUST_KEYWORDS:
            continue
        if token.startswith("crate::"):
            targets.add(token)
            continue
        resolved = imports.get(token)
        if resolved:
            targets.add(resolved)
            continue
        targets.add(token)
    for match in _PATH_TOKEN_RE.finditer(expr):
        token = match.group(0)
        if token in _RUST_KEYWORDS:
            continue
        targets.add(token)
    return targets


def _collect_private_fn_bodies(source: str) -> dict[str, str]:
    bodies: dict[str, str] = {}
    for match in _PRIVATE_FN_RE.finditer(source):
        fn_name = match.group(1)
        brace_index = source.find("{", match.start())
        if brace_index == -1:
            continue
        body, _ = _extract_block(source, brace_index, "{", "}")
        bodies[fn_name] = body
    return bodies


def _collect_public_fn_bodies(source: str) -> dict[str, str]:
    bodies: dict[str, str] = {}
    for match in _PUBLIC_FN_RE.finditer(source):
        fn_name = match.group(1)
        brace_index = source.find("{", match.start())
        if brace_index == -1:
            continue
        body, _ = _extract_block(source, brace_index, "{", "}")
        bodies[fn_name] = body
    return bodies


def _collect_set_blocks(source: str) -> list[tuple[str, str]]:
    blocks: list[tuple[str, str]] = []
    scan_index = 0
    while True:
        match = _SET_BLOCK_START_RE.search(source, scan_index)
        if not match:
            break
        line_start = source.rfind("\n", 0, match.start()) + 1
        open_paren = source.find("(", match.start())
        if open_paren == -1:
            break
        block_inner, close_paren = _extract_block(source, open_paren, "(", ")")
        block = source[line_start:close_paren + 1]
        name_match = re.search(r'\.set\(\s*"([^"]+)"', block)
        if name_match and "create_function" in block:
            blocks.append((name_match.group(1), block))
        scan_index = close_paren + 1
    return blocks


def _collect_add_methods_blocks(source: str) -> list[str]:
    blocks: list[str] = []
    for match in _ADD_METHODS_RE.finditer(source):
        brace_index = source.find("{", match.end())
        if brace_index == -1:
            continue
        block, _ = _extract_block(source, brace_index, "{", "}")
        blocks.append(block)
    return blocks


def _resolve_public_targets(
    target: str,
    helper_calls: dict[str, set[str]],
    public_fn_keys: set[tuple[str, str]],
    public_fn_names: dict[str, set[tuple[str, str]]],
    memo: dict[str, set[tuple[str, str]]],
    stack: set[str],
) -> set[tuple[str, str]]:
    if target in memo:
        return memo[target]
    if target in stack:
        return set()

    if target in helper_calls:
        stack.add(target)
        resolved: set[tuple[str, str]] = set()
        for nested_target in helper_calls[target]:
            resolved.update(
                _resolve_public_targets(
                    nested_target,
                    helper_calls,
                    public_fn_keys,
                    public_fn_names,
                    memo,
                    stack,
                )
            )
        stack.remove(target)
        memo[target] = resolved
        return resolved

    rust_key = _normalize_rust_path(target)
    resolved: set[tuple[str, str]] = set()
    if rust_key in public_fn_keys:
        resolved = {rust_key}
    elif rust_key:
        name_matches = public_fn_names.get(rust_key[1], set())
        if len(name_matches) == 1:
            resolved = set(name_matches)
    memo[target] = resolved
    return resolved


def _collect_lua_exposed_rust_fns(public_fn_keys: set[tuple[str, str]]) -> set[tuple[str, str]]:
    exposed: set[tuple[str, str]] = set()
    if not SRC_LUA_API_DIR.exists():
        return exposed

    public_fn_names: dict[str, set[tuple[str, str]]] = {}
    for rust_key in public_fn_keys:
        public_fn_names.setdefault(rust_key[1], set()).add(rust_key)

    for api_file in sorted(SRC_LUA_API_DIR.glob("*_api.rs")):
        try:
            source = api_file.read_text(encoding="utf-8")
        except OSError:
            continue

        imports = _collect_imports(source)
        helper_bodies = _collect_private_fn_bodies(source)
        helper_calls = {
            fn_name: _collect_call_targets(body, imports)
            for fn_name, body in helper_bodies.items()
        }
        memo: dict[str, set[tuple[str, str]]] = {}

        for _, block in _collect_set_blocks(source):
            create_function_arg = _extract_create_function_arg(block)
            if not create_function_arg:
                continue
            direct_targets = _collect_call_targets(create_function_arg, imports)
            for target in direct_targets:
                exposed.update(
                    _resolve_public_targets(
                        target,
                        helper_calls,
                        public_fn_keys,
                        public_fn_names,
                        memo,
                        set(),
                    )
                )

        for block in _collect_add_methods_blocks(source):
            direct_targets = _collect_call_targets(block, imports)
            for target in direct_targets:
                exposed.update(
                    _resolve_public_targets(
                        target,
                        helper_calls,
                        public_fn_keys,
                        public_fn_names,
                        memo,
                        set(),
                    )
                )

    return exposed


def _collect_candidate_rust_modules(exposed_rust_fns: set[tuple[str, str]]) -> set[str]:
    return {module for module, _ in exposed_rust_fns}


def _collect_public_helper_fns(
    rust_data: dict,
    directly_exposed_rust_fns: set[tuple[str, str]],
) -> set[tuple[str, str]]:
    helpers: set[tuple[str, str]] = set()
    modules = rust_data["rust_api"]["modules"]

    for mod_path, mod_data in modules.items():
        public_names = {
            item["name"]
            for item in mod_data.get("items", [])
            if item.get("kind") == "fn"
        }
        if not public_names:
            continue

        source_file = mod_data.get("source_file")
        if not source_file:
            continue

        source_path = WORKSPACE_ROOT / source_file
        try:
            source = source_path.read_text(encoding="utf-8")
        except OSError:
            continue

        call_graph: dict[str, set[str]] = {}
        for fn_name, body in _collect_public_fn_bodies(source).items():
            callees: set[str] = set()
            for target in _collect_call_targets(body, {}):
                rust_key = _normalize_rust_path(target)
                if rust_key and rust_key[0] == mod_path and rust_key[1] in public_names:
                    callees.add(rust_key[1])
                    continue
                if target in public_names:
                    callees.add(target)
            call_graph[fn_name] = callees

        stack = [name for module, name in directly_exposed_rust_fns if module == mod_path]
        seen: set[str] = set(stack)
        while stack:
            caller = stack.pop()
            for callee in call_graph.get(caller, set()):
                if callee in seen:
                    continue
                seen.add(callee)
                stack.append(callee)
                helpers.add((mod_path, callee))

    return helpers


def _collect_lua_names(lua_data: dict) -> set[str]:
    """Collect all (module, name) pairs from the Lua API data for cross-reference."""
    names: set[str] = set()
    for mod_name, mod_data in lua_data.items():
        for fn in mod_data.get("functions", []):
            lua_name = fn.get("lua_name") or fn.get("name") or ""
            if lua_name:
                # lua_name may already be fully qualified (e.g. "lurek.math.inBack"); avoid double prefix
                names.add(lua_name if lua_name.startswith("lurek.") else f"{mod_name}.{lua_name}")
        for cls_name, cls_data in mod_data.get("classes", {}).items():
            if cls_name == "mlua":
                continue  # skip spurious mlua pseudo-class entries
            names.add(f"{mod_name}.{cls_name}")
            for method in cls_data.get("methods", []):
                mname = method.get("lua_name") or method.get("name") or ""
                if mname:
                    names.add(f"{mod_name}.{cls_name}:{mname}")
    return names


def _rust_public_fns(rust_data: dict, candidate_modules: set[str] | None = None) -> list[dict]:
    """Return public Rust function items, optionally narrowed to Lua-reachable modules."""
    results = []
    for mod_path, mod_data in rust_data["rust_api"]["modules"].items():
        if candidate_modules is not None and mod_path not in candidate_modules:
            continue
        for item in mod_data.get("items", []):
            if item.get("kind") == "fn":
                results.append({
                    "module": mod_path,
                    "name": item["name"],
                    "desc": item.get("description", "") or "",
                    "file": item.get("file", ""),
                    "line": item.get("line", 0),
                })
    return results


def _rust_undocumented(rust_data: dict) -> list[dict]:
    """Return all Rust public items with missing/short docstrings."""
    results = []
    for mod_path, mod_data in sorted(rust_data["rust_api"]["modules"].items()):
        for item in mod_data.get("items", []):
            desc = (item.get("description", "") or "").strip()
            if len(desc) < _MIN_DESC_LENGTH:
                results.append({
                    "module": mod_path,
                    "kind": item.get("kind", "fn"),
                    "name": item["name"],
                    "desc": desc,
                    "file": item.get("file", ""),
                    "line": item.get("line", 0),
                })
    return results


def _lua_undocumented(lua_data: dict) -> list[dict]:
    """Return all Lua API items (functions, classes, methods) with missing descriptions."""
    results = []
    for mod_name, mod_data in sorted(lua_data.items()):
        # Module-level description
        mod_desc = (mod_data.get("description", "") or "").strip()
        if len(mod_desc) < _MIN_DESC_LENGTH:
            results.append({
                "module": mod_name,
                "kind": "module",
                "name": f"lurek.{mod_name}",
                "desc": mod_desc,
            })

        for fn in mod_data.get("functions", []):
            desc = (fn.get("description", "") or "").strip()
            if len(desc) < _MIN_DESC_LENGTH:
                lua_name = fn.get("lua_name") or fn.get("name") or "?"
                results.append({
                    "module": mod_name,
                    "kind": "function",
                    # lua_name may already be fully qualified; avoid double prefix
                    "name": lua_name if lua_name.startswith("lurek.") else f"lurek.{mod_name}.{lua_name}",
                    "desc": desc,
                })

        for cls_name, cls_data in sorted(mod_data.get("classes", {}).items()):
            if cls_name == "mlua":
                continue  # skip spurious mlua pseudo-class entries
            cls_desc = (cls_data.get("description", "") or "").strip()
            if len(cls_desc) < _MIN_DESC_LENGTH:
                results.append({
                    "module": mod_name,
                    "kind": "class",
                    "name": f"lurek.{mod_name}.{cls_name}",
                    "desc": cls_desc,
                })
            for method in cls_data.get("methods", []):
                mdesc = (method.get("description", "") or "").strip()
                if len(mdesc) < _MIN_DESC_LENGTH:
                    mname = method.get("lua_name") or method.get("name") or "?"
                    # lua_name is already "ClassName:methodName"; avoid double class prefix
                    display = mname if mname.startswith(f"{cls_name}:") else f"{cls_name}:{mname}"
                    results.append({
                        "module": mod_name,
                        "kind": "method",
                        "name": display,
                        "desc": mdesc,
                    })
    return results


def generate_report(rust_data: dict, lua_data: dict) -> str:
    # lua_api_data.json nests the modules under ["lua_api"]["modules"];
    # fall back to treating the whole dict as the modules map for older formats.
    lua_modules = lua_data.get("lua_api", {}).get("modules", lua_data)
    lua_names = _collect_lua_names(lua_modules)
    all_rust_fns = _rust_public_fns(rust_data)
    public_fn_keys = {(item["module"], item["name"]) for item in all_rust_fns}
    exposed_rust_fns = _collect_lua_exposed_rust_fns(public_fn_keys)
    candidate_modules = _collect_candidate_rust_modules(exposed_rust_fns)
    rust_fns = _rust_public_fns(rust_data, candidate_modules)
    helper_rust_fns = _collect_public_helper_fns(rust_data, exposed_rust_fns)
    rust_bad_docs = _rust_undocumented(rust_data)
    lua_bad_docs = _lua_undocumented(lua_modules)

    # Section 1: Rust fns not in Lua
    # Matching: try exact substring, then underscore-stripped (camelCase), then ease_ prefix stripped
    unexposed: list[dict] = []
    for item in rust_fns:
        if (item["module"], item["name"]) in exposed_rust_fns:
            continue
        if (item["module"], item["name"]) in helper_rust_fns:
            continue
        fn_name_lower = item["name"].lower()
        mod_lower = item["module"].split("::")[-1].lower()
        # Normalize by removing underscores (handles snake_case vs camelCase)
        fn_no_us = fn_name_lower.replace("_", "")
        # Handle easing convention: ease_in_* -> in*, ease_out_* -> out*
        fn_ease = re.sub(r"^ease_", "", fn_name_lower).replace("_", "")
        found = any(
            fn_name_lower in lua_key.lower()
            or fn_no_us in lua_key.lower().replace("_", "")
            or fn_ease in lua_key.lower().replace("_", "")
            or mod_lower + "." + fn_name_lower in lua_key.lower()
            for lua_key in lua_names
        )
        if not found:
            unexposed.append(item)

    lines: list[str] = []
    lines.append("# Lurek2D API Coverage Gaps")
    lines.append("")
    lines.append("*Auto-generated by `tools/gen_coverage_gaps.py`. Do not edit manually.*")
    lines.append("")
    lines.append("This report identifies three categories of coverage issues:")
    lines.append("")
    lines.append("1. **Rust→Lua Gaps** — Public Rust functions not exposed to the Lua API")
    lines.append("2. **Rust Docstring Issues** — Rust public items with missing/short docstrings")
    lines.append("3. **Lua Docstring Issues** — Lua API items with missing descriptions")
    lines.append("")
    lines.append("---")
    lines.append("")

    # ── Section 1: Unexposed Rust functions ──────────────────────────────────
    lines.append(f"## 1. Rust→Lua Gaps ({len(unexposed)} items)")
    lines.append("")
    lines.append("These public Rust functions are **not exposed** to the `lurek.*` Lua API.")
    lines.append("This may be intentional (engine internals) or an oversight.")
    lines.append("")

    if unexposed:
        by_mod: dict[str, list] = {}
        for item in unexposed:
            by_mod.setdefault(item["module"], []).append(item)
        for mod in sorted(by_mod.keys()):
            lines.append(f"### `{mod}`")
            lines.append("")
            for item in sorted(by_mod[mod], key=lambda x: x["name"]):
                loc = f"`{item['file']}:{item['line']}`" if item["file"] else ""
                desc_note = f" — {item['desc'][:60]}" if item["desc"] else ""
                lines.append(f"- `{item['name']}`{desc_note} {loc}")
            lines.append("")
    else:
        lines.append("*All public Rust functions appear to be exposed to Lua.*")
        lines.append("")

    lines.append("---")
    lines.append("")

    # ── Section 2: Rust docstring issues ─────────────────────────────────────
    lines.append(f"## 2. Rust Docstring Issues ({len(rust_bad_docs)} items)")
    lines.append("")
    lines.append(f"Public Rust items with missing or very short descriptions (< {_MIN_DESC_LENGTH} chars).")
    lines.append("These appear as `// (undocumented)` in `docs/api/rust.md`.")
    lines.append("")

    if rust_bad_docs:
        by_mod2: dict[str, list] = {}
        for item in rust_bad_docs:
            by_mod2.setdefault(item["module"], []).append(item)
        for mod in sorted(by_mod2.keys()):
            lines.append(f"### `{mod}`")
            lines.append("")
            for item in sorted(by_mod2[mod], key=lambda x: (x["kind"], x["name"])):
                kind = item["kind"]
                name = item["name"]
                loc = f"`{item['file']}:{item['line']}`" if item["file"] else ""
                lines.append(f"- `{kind}` **{name}** {loc}")
            lines.append("")
    else:
        lines.append("*All public Rust items have adequate docstrings.*")
        lines.append("")

    lines.append("---")
    lines.append("")

    # ── Section 3: Lua docstring issues ──────────────────────────────────────
    lines.append(f"## 3. Lua Docstring Issues ({len(lua_bad_docs)} items)")
    lines.append("")
    lines.append(f"Lua API items with missing or very short descriptions (< {_MIN_DESC_LENGTH} chars).")
    lines.append("These appear without documentation in `docs/api/lurek.md` and IntelliSense.")
    lines.append("")

    if lua_bad_docs:
        by_mod3: dict[str, list] = {}
        for item in lua_bad_docs:
            by_mod3.setdefault(item["module"], []).append(item)
        for mod in sorted(by_mod3.keys()):
            lines.append(f"### `{mod}`")
            lines.append("")
            for item in sorted(by_mod3[mod], key=lambda x: (x["kind"], x["name"])):
                kind = item["kind"]
                name = item["name"]
                desc = item["desc"]
                if desc:
                    lines.append(f"- `{kind}` **`{name}`** — *\"{desc}\"* (too short)")
                else:
                    lines.append(f"- `{kind}` **`{name}`** — *(no description)*")
            lines.append("")
    else:
        lines.append("*All Lua API items have adequate descriptions.*")
        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append("## Fixing These Issues")
    lines.append("")
    lines.append("**Rust docstrings:** Add `///` doc comments above `pub fn`, `pub struct`, `pub enum`.")
    lines.append("Then run: `python tools/gen_rust_api_data.py`")
    lines.append("")
    lines.append("**Lua docstrings:** Add `/// description` above the `lurek.set(\"name\", ...)` call")
    lines.append("in the appropriate `src/lua_api/*_api.rs` file.")
    lines.append("Then run: `python tools/gen_lua_api_data.py`")
    lines.append("")
    lines.append("**Rust→Lua gaps:** If the function should be in Lua, add a binding in `src/lua_api/`.")
    lines.append("If this is a false positive, make the binding traceable from `src/lua_api/*.rs` instead of adding a manual exception.")
    lines.append("")
    lines.append("*Re-generate this file: `python tools/gen_coverage_gaps.py`*")

    return "\n".join(lines)


def main() -> int:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/audit/gen_coverage_gaps.py

  # Show all arguments
  python tools/audit/gen_coverage_gaps.py --help
"""
    parser = argparse.ArgumentParser(
        description="Generate Lurek2D API coverage gap report.",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument("--rust-input", default=str(RUST_INPUT))
    parser.add_argument("--lua-input", default=str(LUA_INPUT))
    parser.add_argument("--output", default=str(OUTPUT_FILE))
    args = parser.parse_args()

    rust_path = Path(args.rust_input)
    lua_path = Path(args.lua_input)

    if not rust_path.exists():
        print(f"[ERROR] Rust input not found: {rust_path}", file=sys.stderr)
        print("Run: python tools/gen_rust_api_data.py", file=sys.stderr)
        return 1
    if not lua_path.exists():
        print(f"[ERROR] Lua input not found: {lua_path}", file=sys.stderr)
        print("Run: python tools/gen_lua_api_data.py", file=sys.stderr)
        return 1

    rust_data = json.loads(rust_path.read_text(encoding="utf-8"))
    lua_data = json.loads(lua_path.read_text(encoding="utf-8"))

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    content = generate_report(rust_data, lua_data)
    output_path.write_text(content, encoding="utf-8")

    lines = content.count("\n")
    try:
        rel = output_path.relative_to(WORKSPACE_ROOT)
    except ValueError:
        rel = output_path
    print(f"[OK] Coverage gap report → {rel} ({lines} lines)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
