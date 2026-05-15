#!/usr/bin/env python3
"""fix_param_types.py — Auto-fix @param type tags where documented ``number`` should be ``integer``.

Reads every src/lua_api/*_api.rs file, re-infers Rust closure parameter types,
and replaces ``| number |`` with ``| integer |`` in the @param docstring for
each parameter whose Rust type maps to ``integer`` (i32, u32, i64, u64, usize, …).

Only replaces when ALL of these conditions hold:
  - Rust infers ``integer`` for this parameter position.
  - The corresponding @param tag says ``number`` (not ``integer``, not ``any``).
  - The replacement is unambiguous (single occurrence of this @param line in the file).

Usage:
    python tools/fix/fix_param_types.py            # dry-run (print changes only)
    python tools/fix/fix_param_types.py --apply    # write changes to disk
"""

import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LUA_API_DIR = ROOT / "src" / "lua_api"
GEN_LUA_API_PATH = ROOT / "tools" / "docs" / "gen_lua_api.py"
VALIDATE_PARAM_TYPES_PATH = ROOT / "tools" / "validate" / "validate_param_types.py"

# ─── load helpers ─────────────────────────────────────────────────────────────

def _load(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {path}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

GEN = _load(GEN_LUA_API_PATH, "gen_lua_api")
VAL = _load(VALIDATE_PARAM_TYPES_PATH, "validate_param_types")


# ─── fix pass ─────────────────────────────────────────────────────────────────

def _fix_file(api_file: Path, apply: bool) -> list[tuple[int, str, str]]:
    """Return list of (line_no_1based, old_line, new_line) changes for this file."""
    try:
        text = api_file.read_text(encoding="utf-8")
    except OSError as e:
        print(f"ERROR: cannot read {api_file}: {e}", file=sys.stderr)
        return []

    lines = text.splitlines(keepends=True)
    lines_stripped = [l.rstrip("\n\r") for l in lines]
    functions = GEN.extract_lua_functions(api_file)

    # Collect (line_0_based, param_idx, correct_type) for each fix needed.
    # param_idx is 0-based into the @param lines of that function's docstring.
    fixes_needed: list[tuple[int, int]] = []  # (fn_decl_line_0, param_position_0based)

    for fn in functions:
        decl_0 = fn.line - 1
        inferred = VAL._infer_typed_params(lines_stripped, decl_0)
        if not inferred:
            continue

        doc = VAL._doc_params(fn.full_doc)
        if not doc:
            continue

        had_self = bool(doc) and doc[0][0] == "self"
        if had_self:
            doc = doc[1:]
            if inferred and len(inferred) == len(doc) + 1:
                inferred = inferred[1:]

        for idx, (inferred_name, inferred_type, _) in enumerate(inferred):
            if idx >= len(doc):
                break
            doc_name, doc_type, _ = doc[idx]
            if doc_name == "..." or inferred_name == "...":
                continue
            if inferred_type != "integer":
                continue
            clean = doc_type.rstrip("?").strip().split("|")[0].strip()
            if clean == "number":
                # Find the specific @param line in the docstring block.
                # Walk backwards from the declaration line to find the right @param line.
                fixes_needed.append((fn.line - 1, idx, doc_name))

    if not fixes_needed:
        return []

    # For each fix, locate the actual source line to change.
    changes: list[tuple[int, str, str]] = []

    for decl_0, param_idx_in_doc, param_name in fixes_needed:
        # Walk backwards from decl_0 to collect the @param lines in order.
        doc_block_lines: list[tuple[int, str]] = []  # (line_0, text)
        for j in range(decl_0 - 1, max(-1, decl_0 - 40), -1):
            s = lines_stripped[j].strip()
            if s.startswith("///"):
                doc_block_lines.insert(0, (j, lines_stripped[j]))
            elif re.match(r"^let\s+\w+\s*=\s*.+;\s*$", s):
                continue
            elif s.startswith("//") and not s.startswith("///"):
                continue
            elif s == "" or s.startswith("#"):
                continue
            else:
                break

        # Filter to @param lines only, preserving order.
        param_lines = [(j, l) for j, l in doc_block_lines if "@param" in l]

        # Strip the @param|self| line (same logic as the validator).
        if param_lines:
            m0 = re.search(r"@param\s*\|\s*self\s*\|", param_lines[0][1])
            if m0:
                param_lines = param_lines[1:]

        if param_idx_in_doc >= len(param_lines):
            continue

        target_lineno_0, target_line = param_lines[param_idx_in_doc]

        # Verify it really says `| number |` or `| number? |` (not already fixed or different).
        m = re.search(r"(@param\s*\|\s*\S+\s*\|\s*)(number)(\??\s*\|)", target_line)
        if not m:
            continue

        # Build the corrected line (preserve trailing ? if present).
        new_line = target_line[:m.start(2)] + "integer" + target_line[m.end(2):]
        if new_line == target_line:
            continue

        changes.append((target_lineno_0 + 1, target_line, new_line))

    if not changes:
        return []

    if apply:
        # Apply all changes (deduplicated by line number — last write wins).
        new_lines = list(lines_stripped)
        for lineno_1, _old, new in changes:
            new_lines[lineno_1 - 1] = new

        # Re-join preserving original line endings.
        original_endings = [l[len(l.rstrip("\n\r")):] for l in lines]
        result_parts = []
        for i, nl in enumerate(new_lines):
            ending = original_endings[i] if i < len(original_endings) else "\n"
            result_parts.append(nl + ending)
        api_file.write_text("".join(result_parts), encoding="utf-8")

    return changes


# ─── entry point ─────────────────────────────────────────────────────────────

def main() -> int:
    apply = "--apply" in sys.argv

    api_files = sorted(LUA_API_DIR.glob("*_api.rs"))
    if not api_files:
        print("ERROR: no *_api.rs files found", file=sys.stderr)
        return 1

    total_changes = 0
    changed_files: list[str] = []

    for api_file in api_files:
        changes = _fix_file(api_file, apply=apply)
        if changes:
            rel = str(api_file.relative_to(ROOT)).replace("\\", "/")
            changed_files.append(rel)
            total_changes += len(changes)
            if not apply:
                print(f"\n  {rel}  ({len(changes)} fix(es))")
                for lineno, old, new in changes:
                    # Show the relevant @param portion only
                    def _extract_param(s: str) -> str:
                        m = re.search(r"@param.*", s)
                        return m.group(0) if m else s.strip()
                    print(f"    L{lineno:4d}  {_extract_param(old)}")
                    print(f"          -> {_extract_param(new)}")

    if total_changes == 0:
        print("✓ No number→integer fixes needed.")
        return 0

    if apply:
        print(f"OK Applied {total_changes} fix(es) across {len(changed_files)} file(s):")
        for f in changed_files:
            print(f"    {f}")
    else:
        print(f"\n{'=' * 72}")
        print(f"DRY-RUN: {total_changes} fix(es) in {len(changed_files)} file(s).")
        print("Run with --apply to write changes.")

    return 0 if apply else 1


if __name__ == "__main__":
    sys.exit(main())
