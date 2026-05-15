#!/usr/bin/env python3
"""validate_param_types.py — Verify that @param type tags match Rust closure type inference.

For every registered Lua function in src/lua_api/*_api.rs:
  1. Re-parse the Rust closure signature to extract (name, inferred_lua_type, is_optional).
  2. Compare each documented ``@param | name | type | desc`` pair:
       - TYPE check: documented Lua type must match the Rust-inferred type for all
         verifiable primitives (number, integer, string, boolean, table, function).
       - NAME check: documented param name must not wildly diverge from the Rust
         variable name (allows descriptive aliases; only flags clear mismatches).
       - ORDER check: implicit — the count check already lives in validate_lua_api.py;
         here the position-by-position comparison enforces order consistency.

Skipped intentionally:
  - ``any`` in docs (developer chose to be permissive about Lua's dynamic typing).
  - UserData / LuaValue Rust types (inferred_type = raw Rust name or "any").
  - Variadic (``...`` param).
  - Functions whose inferred signature cannot be determined (empty inferred_typed).

Usage:
    python tools/validate/validate_param_types.py [src/lua_api/]

Exit codes:
    0  all checks pass
    1  one or more type/name mismatches found
"""

import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LUA_API_DIR = ROOT / "src" / "lua_api"
GEN_LUA_API_PATH = ROOT / "tools" / "docs" / "gen_lua_api.py"

# ─── load gen_lua_api ─────────────────────────────────────────────────────────

def _load_gen_lua_api():
    spec = importlib.util.spec_from_file_location("gen_lua_api", GEN_LUA_API_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {GEN_LUA_API_PATH}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

GEN = _load_gen_lua_api()

# Lua types we can verify from the Rust type system (primitives only).
_VERIFIABLE: set[str] = {"number", "integer", "string", "boolean", "table", "function", "nil"}

_errors: list[str] = []
_warnings: list[str] = []


def _err(file: str, line: int, lua_name: str, msg: str) -> None:
    _errors.append(f"  ERROR  {file}:{line}  {lua_name}  --  {msg}")


def _warn(file: str, line: int, lua_name: str, msg: str) -> None:
    _warnings.append(f"  WARN   {file}:{line}  {lua_name}  --  {msg}")


# ─── typed-param inference ────────────────────────────────────────────────────

def _infer_typed_params(lines: list[str], decl_line_0: int) -> list[tuple[str, str, bool]]:
    """Return (param_name, inferred_lua_type, is_optional) for each Rust closure param.

    Parses the closure header at or near *decl_line_0* (0-based).  Returns ``[]``
    when the closure pattern is not recognisable.
    """
    # Collect the header — stop once we have consumed the closing ``|``.
    parts: list[str] = []
    found_first_pipe = False
    pipe_count = 0
    for ln in lines[decl_line_0 : decl_line_0 + 8]:
        s = ln.strip()
        if not found_first_pipe:
            if "|" not in s:
                continue
            found_first_pipe = True
        parts.append(s)
        pipe_count += s.count("|")
        if pipe_count >= 2:
            break

    text = " ".join(parts)
    if not text:
        return []

    def _to_lua(rust_t: str) -> tuple[str, bool]:
        """Return (lua_type, is_optional)."""
        lua = GEN._rust_type_to_lua(rust_t.strip())
        opt = lua.endswith("?")
        return (lua[:-1] if opt else lua, opt)

    # ── (a, b): (TypeA, TypeB) ──────────────────────────────────────────────
    m = re.search(r"\|[^|]*?,\s*\(([^)]+)\):\s*\(([^)]+)\)", text)
    if m:
        names = [n.strip().lstrip("_") for n in m.group(1).split(",")]
        types_raw = [t.strip() for t in m.group(2).split(",")]
        result = []
        for name, rust_t in zip(names, types_raw):
            if rust_t == "LuaMultiValue":
                result.append(("...", "any", False))
                continue
            lua_t, is_opt = _to_lua(rust_t)
            result.append((name, lua_t, is_opt))
        return result

    # ── scalar: |_, a: TypeA| ───────────────────────────────────────────────
    m = re.search(
        r"\|[^|]*?,\s*([a-z_][a-z0-9_]*):\s*([A-Za-z][A-Za-z0-9_<>, ]+?)\|",
        text,
    )
    if m:
        name = m.group(1).lstrip("_")
        rust_t = m.group(2).strip()
        if "LuaMultiValue" in rust_t:
            return [("...", "any", False)]
        lua_t, is_opt = _to_lua(rust_t)
        return [(name, lua_t, is_opt)]

    # ── single-element tuple: |_, (a,): (TypeA,)| ───────────────────────────
    m = re.search(r"\|[^|]*?,\s*\(([a-z_][a-z0-9_]*)\s*,?\):\s*\(([^)]+)\)", text)
    if m:
        name = m.group(1).lstrip("_")
        rust_t = m.group(2).strip()
        if "LuaMultiValue" in rust_t:
            return [("...", "any", False)]
        lua_t, is_opt = _to_lua(rust_t)
        return [(name, lua_t, is_opt)]

    return []


# ─── documented-param extraction ─────────────────────────────────────────────

def _doc_params(docstring: str) -> list[tuple[str, str, bool]]:
    """Return (name, lua_type, is_optional) from @param lines in the docstring."""
    result = []
    for line in docstring.splitlines():
        s = line.strip()
        m = re.match(r"@param\s*\|\s*(\w+\??|\.\.\.)\s*\|\s*([^|]+)\s*\|", s)
        if not m:
            continue
        raw_name = m.group(1)
        is_optional = raw_name.endswith("?")
        name = raw_name.rstrip("?")
        raw_type = m.group(2).strip()
        # Strip trailing ? from type (optional marker)
        lua_type = raw_type.rstrip("?").strip()
        result.append((name, lua_type, is_optional))
    return result


# ─── per-file check ───────────────────────────────────────────────────────────

def _check_file(api_file: Path) -> int:
    """Check one *_api.rs file. Returns count of errors found."""
    try:
        lines = api_file.read_text(encoding="utf-8").splitlines()
    except OSError as e:
        _err(str(api_file), 0, "?", f"cannot read file: {e}")
        return 1

    functions = GEN.extract_lua_functions(api_file)
    rel = str(api_file.relative_to(ROOT)).replace("\\", "/")
    file_errors = 0

    for fn in functions:
        decl_0 = fn.line - 1  # convert 1-based → 0-based
        inferred = _infer_typed_params(lines, decl_0)
        if not inferred:
            continue

        doc = _doc_params(fn.full_doc)
        if not doc:
            continue

        # ── self-stripping: add_function with @param|self| ──────────────────
        # The generator strips self from the method signature; mirror that here.
        had_self = bool(doc) and doc[0][0] == "self"
        if had_self:
            doc = doc[1:]
            if inferred and len(inferred) == len(doc) + 1:
                inferred = inferred[1:]

        # ── position-by-position comparison ─────────────────────────────────
        for idx, (inferred_name, inferred_type, inferred_opt) in enumerate(inferred):
            if idx >= len(doc):
                break

            doc_name, doc_type, doc_opt = doc[idx]

            # Skip variadic
            if doc_name == "..." or inferred_name == "...":
                continue

            # Skip when inferred type is not a known primitive
            if inferred_type not in _VERIFIABLE:
                continue

            # Normalise doc type: strip leading/trailing ?, take first arm of union
            clean_doc_type = doc_type.strip().lstrip("?").rstrip("?").strip().split("|")[0].strip()

            # ── TYPE CHECK ───────────────────────────────────────────────────
            if clean_doc_type not in ("any", "") and clean_doc_type != inferred_type:
                _err(
                    rel, fn.line, fn.lua_name,
                    f"param [{idx + 1}] `{doc_name}`: documented type `{doc_type}` "
                    f"but Rust infers `{inferred_type}`",
                )
                file_errors += 1

            # ── NAME CHECK (warning-level, not error) ────────────────────────
            # Allow intentionally descriptive Lua-facing names (e.g. "x" for Rust "px").
            # Only warn when the names share no common root and are both non-trivial.
            norm_doc = doc_name.lower().lstrip("_")
            norm_rust = inferred_name.lower().lstrip("_")
            if (
                norm_doc != norm_rust
                and len(norm_doc) > 1
                and len(norm_rust) > 1
                and norm_rust not in norm_doc
                and norm_doc not in norm_rust
                and not norm_doc.startswith(norm_rust[:3])
                and not norm_rust.startswith(norm_doc[:3])
            ):
                _warn(
                    rel, fn.line, fn.lua_name,
                    f"param [{idx + 1}] name: documented `{doc_name}` vs Rust `{inferred_name}` "
                    f"(type: {inferred_type})",
                )

    return file_errors


# ─── entry point ─────────────────────────────────────────────────────────────

def main(argv: list[str] | None = None) -> int:
    args = argv if argv is not None else sys.argv[1:]
    errors_only = "--errors-only" in args
    positional = [a for a in args if not a.startswith("--")]

    if positional:
        target = Path(positional[0]).resolve()
        if target.is_dir():
            api_files = sorted(target.glob("*_api.rs"))
        else:
            api_files = [target]
    else:
        api_files = sorted(LUA_API_DIR.glob("*_api.rs"))

    total_errors = 0
    for api_file in api_files:
        n = _check_file(api_file)
        total_errors += n

    if not errors_only and _warnings:
        print(f"\nParam-name divergences (documentation names differ from Rust variables):")
        for w in _warnings:
            print(w)

    if _errors:
        print(f"\n{'=' * 72}")
        print(f"TYPE MISMATCH: {total_errors} error(s) across {len(api_files)} files")
        print(f"{'=' * 72}")
        for e in _errors:
            print(e)
        return 1

    msg_parts = [f"OK {len(api_files)} files checked"]
    if _warnings:
        msg_parts.append(f"{len(_warnings)} name-divergence warning(s)")
    else:
        msg_parts.append("0 type errors, 0 name-divergence warnings")
    print(", ".join(msg_parts))
    return 0


if __name__ == "__main__":
    sys.exit(main())
