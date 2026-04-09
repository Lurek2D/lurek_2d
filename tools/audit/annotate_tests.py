#!/usr/bin/env python3
"""
annotate_tests.py — Auto-insert @tests annotations into Lua unit test files.

Scans each it() block for lurek.module.func and ClassName:method references,
then inserts the corresponding -- @tests annotation at the top of the block body,
skipping blocks that already have one.

This converts heuristic coverage into explicit declarations so that strict-mode
`unit_test_api_coverage.py --strict` reports accurate results.

Usage:
    python tools/audit/annotate_tests.py --dry-run      # preview, no writes
    python tools/audit/annotate_tests.py                # write files in-place
    python tools/audit/annotate_tests.py --module timer # one module only
    python tools/audit/annotate_tests.py --file tests/lua/unit/test_math.lua

IMPORTANT: After running, review the annotated files. Auto-generated annotations
are heuristic — some may be wrong (e.g. a helper named like an API function).
Remove incorrect ones manually.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / "docs" / "logs" / "lua_api_data.json"
LUA_UNIT_TESTS = ROOT / "tests" / "lua" / "unit"

# ── Load API ───────────────────────────────────────────────────────────────────


def load_api_names(module_filter: Optional[str] = None) -> Tuple[Set[str], Dict[str, Set[str]]]:
    """
    Returns:
        all_lua_names   — full set of known lua_names
        known_methods   — owner_type -> set of method names
    """
    try:
        data = json.loads(API_JSON.read_text(encoding="utf-8"))
    except FileNotFoundError:
        sys.exit(f"[ERROR] {API_JSON!s} not found. Run gen_lua_api_data.py first.")

    all_lua_names: Set[str] = set()
    known_methods: Dict[str, Set[str]] = {}

    for mod_name, mod in data["lua_api"]["modules"].items():
        if module_filter and mod_name != module_filter:
            continue
        for fn in (mod.get("functions") or []):
            all_lua_names.add(fn["lua_name"])
        for cls_name, cls in (mod.get("classes") or {}).items():
            method_names: Set[str] = set()
            for meth in (cls.get("methods") or []):
                all_lua_names.add(meth["lua_name"])
                method_names.add(meth["name"])
            if method_names:
                known_methods[cls_name] = method_names

    return all_lua_names, known_methods


# ── Annotation finder ──────────────────────────────────────────────────────────

_LUREK_REF_RE = re.compile(r"\blurek\.([a-z_]\w*)\.([a-zA-Z_]\w*)")
_METHOD_CALL_RE = re.compile(r"\w+\s*:\s*([a-zA-Z_]\w*)\s*\(")
_EXPLICIT_RE = re.compile(r"--\s*@tests\s+\S")


def _collect_refs_in_body(
    body: str,
    all_lua_names: Set[str],
    known_methods: Dict[str, Set[str]],
) -> List[str]:
    """Find API references in an it() block body, return sorted lua_names."""
    found: Set[str] = set()

    for m in _LUREK_REF_RE.finditer(body):
        lua_name = f"lurek.{m.group(1)}.{m.group(2)}"
        if lua_name in all_lua_names:
            found.add(lua_name)

    # ClassName:method patterns — try all known methods
    for meth_m in _METHOD_CALL_RE.finditer(body):
        meth_name = meth_m.group(1)
        for owner_type, method_names in known_methods.items():
            if meth_name in method_names:
                lua_name = f"{owner_type}:{meth_name}"
                if lua_name in all_lua_names:
                    found.add(lua_name)

    return sorted(found)


# ── File annotator ─────────────────────────────────────────────────────────────


def _extract_it_blocks(content: str) -> List[Tuple[int, int, int, int, str]]:
    """
    Find all it() blocks in content.

    Returns list of (it_start, func_body_start, func_body_end, content_end, desc)
    where:
      it_start      = index of 'i' in `it(`
      func_body_start = index right after `function()` (newline or first char of body)
      func_body_end   = index of the `end` that closes the function body
      content_end   = index just past the closing `)` of the whole it() call
      desc          = description string
    """
    results = []
    i = 0
    n = len(content)

    while i < n:
        # Find `it(` with word boundary
        m = re.search(r'\bit\s*\(', content[i:])
        if not m:
            break
        it_pos = i + m.start()
        after_it = i + m.end()

        # Extract description
        desc = ""
        desc_m = re.match(r'\s*["\']([^"\']*)["\']', content[after_it:after_it+300])
        if desc_m:
            desc = desc_m.group(1)

        # Find `function()` within 300 chars
        func_m = re.search(r'\bfunction\s*\(\s*\)', content[after_it:after_it+300])
        if not func_m:
            i = it_pos + 1
            continue

        func_body_start = after_it + func_m.end()
        # Advance past any newline immediately after function()
        while func_body_start < n and content[func_body_start] in (' ', '\t'):
            func_body_start += 1

        # Track depth: we already consumed one `function` → depth=1
        # Walk forward counting function/end to find matching end
        depth = 1
        j = func_body_start

        while j < n and depth > 0:
            # Skip comments
            if content[j:j+2] == '--':
                while j < n and content[j] != '\n':
                    j += 1
                continue
            # Skip strings
            if content[j] in ('"', "'"):
                q = content[j]
                j += 1
                while j < n and content[j] != q:
                    if content[j] == '\\':
                        j += 1
                    j += 1
                j += 1
                continue
            # Long strings [[ ... ]]
            if content[j:j+2] == '[[':
                j += 2
                while j < n and content[j:j+2] != ']]':
                    j += 1
                j += 2
                continue
            # Keywords
            kw_m = re.match(
                r'\b(function|do|if|while|for|repeat)\b',
                content[j:]
            )
            if kw_m:
                depth += 1
                j += kw_m.end()
                continue
            end_m = re.match(r'\bend\b', content[j:])
            if end_m:
                depth -= 1
                func_body_end = j
                j += end_m.end()
                if depth == 0:
                    # Skip optional `)` that closes the it() call
                    while j < n and content[j] in (' ', ',', '\n', '\r', '\t'):
                        pass_once = content[j]
                        if pass_once == ')':
                            j += 1
                            break
                        j += 1
                    results.append((it_pos, func_body_start, func_body_end, j, desc))
                    break
                continue
            j += 1

        i = it_pos + 1

    return results


def annotate_file(
    path: Path,
    all_lua_names: Set[str],
    known_methods: Dict[str, Set[str]],
    dry_run: bool,
) -> Tuple[int, int]:
    """
    Annotate a single Lua test file in-place.

    Returns: (it_blocks_found, annotations_added)
    """
    content = path.read_text(encoding="utf-8")

    it_blocks = _extract_it_blocks(content)
    it_count = len(it_blocks)
    added_count = 0

    # Process from end to beginning so offsets stay valid
    out = list(content)  # mutable character list

    for (it_pos, body_start, body_end, block_end, desc) in reversed(it_blocks):
        body = content[body_start:body_end]

        # Skip if already annotated
        if _EXPLICIT_RE.search(body):
            continue

        refs = _collect_refs_in_body(body, all_lua_names, known_methods)
        if not refs:
            continue

        # Determine indentation: look at first non-blank line in the body
        indent = "        "  # default 8 spaces
        for line in body.splitlines():
            stripped = line.lstrip()
            if stripped and not stripped.startswith("--"):
                indent = line[: len(line) - len(stripped)]
                break

        annotation_text = "".join(f"{indent}-- @tests {ref}\n" for ref in refs)

        # Insert right after the newline following `function()`, i.e. at body_start
        insert_pos = body_start
        # Advance past the newline that follows function()
        if insert_pos < len(content) and content[insert_pos] == '\n':
            insert_pos += 1

        out[insert_pos:insert_pos] = list(annotation_text)
        added_count += len(refs)

    new_content = "".join(out)

    if dry_run:
        if added_count > 0:
            print(f"  DRY-RUN {path.name}: would add {added_count} annotation(s) across {it_count} it() blocks")
    else:
        if added_count > 0:
            path.write_text(new_content, encoding="utf-8")
            print(f"  Updated {path.name}: added {added_count} annotation(s) across {it_count} it() blocks")

    return it_count, added_count


# ── Entry point ────────────────────────────────────────────────────────────────


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Auto-insert -- @tests annotations into Lua unit test files.",
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview changes without writing files")
    parser.add_argument("--module", metavar="NAME",
                        help="Only process tests/lua/unit/test_<NAME>.lua")
    parser.add_argument("--file", metavar="PATH",
                        help="Process a specific file instead of the whole unit/ dir")
    args = parser.parse_args()

    all_lua_names, known_methods = load_api_names()

    if args.file:
        files = [Path(args.file).resolve()]
    elif args.module:
        candidate = LUA_UNIT_TESTS / f"test_{args.module}.lua"
        if not candidate.exists():
            sys.exit(f"[ERROR] {candidate} not found")
        files = [candidate]
    else:
        files = sorted(LUA_UNIT_TESTS.glob("test_*.lua"))

    total_it = 0
    total_added = 0

    print(f"{'DRY-RUN: ' if args.dry_run else ''}Annotating {len(files)} test file(s)...")

    for f in files:
        it_count, added = annotate_file(f, all_lua_names, known_methods, dry_run=args.dry_run)
        total_it += it_count
        total_added += added

    action = "Would add" if args.dry_run else "Added"
    print(f"\n{action} {total_added} annotation(s) across {len(files)} file(s) ({total_it} it() blocks)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
