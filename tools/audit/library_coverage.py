#!/usr/bin/env python3
"""library_coverage.py — Audit Lureksome library coverage across three dimensions.

Measures:

  1. **Docstring coverage** — What % of public functions in library/*/init.lua
     have LDoc comment blocks (``---`` preceding the function declaration).
     Also tracks ``@param`` and ``@return`` annotation completeness.

  2. **API doc coverage** — What % of public functions are present in
      ``docs/api/lureksome.md`` (the generated human-readable API reference).

  3. **Test coverage** — What % of public functions have a ``@covers`` marker
     in the corresponding ``tests/lua/library/test_library_<name>.lua``.

Usage:
    python tools/audit/library_coverage.py              # all libraries, text report
    python tools/audit/library_coverage.py --library battle   # single library
    python tools/audit/library_coverage.py --json       # JSON output
    python tools/audit/library_coverage.py --output logs/reports/library_coverage.md
    python tools/audit/library_coverage.py --threshold 60  # exit 1 if avg < 60%

Exit codes:
    0  all libraries meet threshold (default 0)
    1  one or more libraries below threshold
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import List, Optional

REPO = Path(__file__).resolve().parent.parent.parent
LIB_DIR = REPO / "library"
TEST_LIB_DIR = REPO / "tests" / "lua" / "library"
API_MD = REPO / "docs" / "api" / "lureksome.md"

# ── Lua source parsers ────────────────────────────────────────────────────────

_FUNC_RE = re.compile(r"^\s*function\s+([\w.:]+)\s*\(")
_M_ASSIGN_RE = re.compile(r"^\s*M\.([\w]+)\s*=\s*function\s*\(")
_LOCAL_FUNC_RE = re.compile(r"^\s*local\s+function\s+(\w+)\s*\(")
_LEADING_DOC_RE = re.compile(r"^\s*---")
_AT_LOCAL_RE = re.compile(r"@local")
_PARAM_RE = re.compile(r"@(?:param|tparam)\s+\S+")
_RETURN_RE = re.compile(r"@(?:return|treturn)\s+")


def _is_public_func(name: str) -> bool:
    """Heuristic: names that look like private/internal helpers."""
    parts = name.split(".")
    local_name = parts[-1] if parts else name
    # Skip local functions and names starting with underscore or lowercase module prefix
    if local_name.startswith("_"):
        return False
    return True


def parse_library_functions(init_lua: Path) -> list[dict]:
    """
    Return a list of dicts per public function found in init.lua.
    Each dict has: name, has_doc, has_param, has_return, is_local_only.
    """
    text = init_lua.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    n = len(lines)
    results = []

    i = 0
    while i < n:
        line = lines[i]
        # Check for local function (always skip — not public API)
        if _LOCAL_FUNC_RE.match(line):
            i += 1
            continue

        # Collect doc block preceding this line (walk backwards)
        doc_block: list[str] = []
        j = i - 1
        while j >= 0 and (lines[j].strip().startswith("---") or lines[j].strip().startswith("--")):
            doc_block.insert(0, lines[j])
            j -= 1

        # Try M.fn = function(...) pattern
        m = _M_ASSIGN_RE.match(line)
        if m:
            fn_name = m.group(1)
            if _is_public_func(fn_name):
                is_local = any(_AT_LOCAL_RE.search(l) for l in doc_block)
                if not is_local:
                    has_doc = len(doc_block) > 0 and any(_LEADING_DOC_RE.match(l) for l in doc_block)
                    doc_text = "\n".join(doc_block)
                    has_param = bool(_PARAM_RE.search(doc_text))
                    has_return = bool(_RETURN_RE.search(doc_text))
                    results.append({
                        "name": fn_name,
                        "has_doc": has_doc,
                        "has_param": has_param,
                        "has_return": has_return,
                    })
            i += 1
            continue

        # Try function Module.fn(...) or function Class:method(...) etc.
        m = _FUNC_RE.match(line)
        if m:
            fn_name = m.group(1)
            if _is_public_func(fn_name):
                is_local = any(_AT_LOCAL_RE.search(l) for l in doc_block)
                if not is_local:
                    has_doc = len(doc_block) > 0 and any(_LEADING_DOC_RE.match(l) for l in doc_block)
                    doc_text = "\n".join(doc_block)
                    has_param = bool(_PARAM_RE.search(doc_text))
                    has_return = bool(_RETURN_RE.search(doc_text))
                    results.append({
                        "name": fn_name,
                        "has_doc": has_doc,
                        "has_param": has_param,
                        "has_return": has_return,
                    })
            i += 1
            continue

        i += 1

    return results


def _test_covered_names(test_lua: Path) -> set[str]:
    """Return set of bare function names appearing in @covers markers."""
    if not test_lua.exists():
        return set()
    text = test_lua.read_text(encoding="utf-8", errors="replace")
    # @covers library.battle.newStatusEffect  → "newStatusEffect"
    names: set[str] = set()
    for m in re.finditer(r"@covers\s+library\.\w+\.(\w+)", text):
        names.add(m.group(1))
    # Also match class method patterns: @covers library.battle.Combatant:method
    for m in re.finditer(r"@covers\s+library\.\w+\.\w+:(\w+)", text):
        names.add(m.group(1))
    return names


def _api_md_names(lib_name: str) -> set[str]:
    """Return bare function names documented in docs/api/lureksome.md for a library."""
    if not API_MD.exists():
        return set()
    text = API_MD.read_text(encoding="utf-8", errors="replace")
    # Find the section for this library
    pattern = rf"## `library\.{re.escape(lib_name)}`.*?(?=\n## `library\.|\Z)"
    m = re.search(pattern, text, re.DOTALL)
    if not m:
        return set()
    section = m.group(0)
    names: set[str] = set()
    # Module-level: library.{lib}.funcname(
    for fn_m in re.finditer(rf'library\.{re.escape(lib_name)}\.(\w+)\s*\(', section):
        names.add(fn_m.group(1))
    # Class methods: ClassName:methodname(
    for fn_m in re.finditer(r'\b\w+:(\w+)\s*\(', section):
        names.add(fn_m.group(1))
    return names


def _bare_name(full_name: str) -> str:
    """Extract the bare function name from Module.fn or Class:method."""
    # Module.fn → fn;  Class:method → method
    if ":" in full_name:
        return full_name.split(":")[-1]
    if "." in full_name:
        return full_name.split(".")[-1]
    return full_name


def audit_library(lib_name: str) -> dict:
    """Audit one library and return a metrics dict."""
    init_lua = LIB_DIR / lib_name / "init.lua"
    test_lua = TEST_LIB_DIR / f"test_library_{lib_name}.lua"

    result: dict = {
        "library": lib_name,
        "has_init": init_lua.exists(),
        "has_test": test_lua.exists(),
        "total_functions": 0,
        # Docstring coverage
        "with_doc": 0,
        "with_param": 0,
        "with_return": 0,
        "doc_pct": 0.0,
        "param_pct": 0.0,
        "return_pct": 0.0,
        # API doc coverage
        "in_api_md": 0,
        "api_md_pct": 0.0,
        "api_md_missing": [],
        # Test coverage
        "test_covered": 0,
        "test_pct": 0.0,
        "test_missing": [],
    }

    if not init_lua.exists():
        return result

    funcs = parse_library_functions(init_lua)
    result["total_functions"] = len(funcs)

    if not funcs:
        return result

    # Docstring coverage
    with_doc = sum(1 for f in funcs if f["has_doc"])
    with_param = sum(1 for f in funcs if f["has_param"])
    with_return = sum(1 for f in funcs if f["has_return"])
    result["with_doc"] = with_doc
    result["with_param"] = with_param
    result["with_return"] = with_return
    result["doc_pct"] = round(with_doc / len(funcs) * 100, 1)
    result["param_pct"] = round(with_param / len(funcs) * 100, 1)
    result["return_pct"] = round(with_return / len(funcs) * 100, 1)

    # API doc coverage (docs/api/lureksome.md)
    api_names = _api_md_names(lib_name)
    bare_names = {_bare_name(f["name"]) for f in funcs}
    in_api = {n for n in bare_names if n in api_names}
    missing_api = sorted(bare_names - api_names)
    result["in_api_md"] = len(in_api)
    result["api_md_pct"] = round(len(in_api) / len(funcs) * 100, 1) if funcs else 0.0
    result["api_md_missing"] = missing_api[:20]

    # Test coverage (@covers in test file)
    covered = _test_covered_names(test_lua)
    in_test = {n for n in bare_names if n in covered}
    missing_test = sorted(bare_names - covered)
    result["test_covered"] = len(in_test)
    result["test_pct"] = round(len(in_test) / len(funcs) * 100, 1) if funcs else 0.0
    result["test_missing"] = missing_test[:20]

    return result


def _find_libraries() -> list[str]:
    """Discover all library names from library/ subdirectories."""
    names = []
    if LIB_DIR.exists():
        for d in sorted(LIB_DIR.iterdir()):
            if d.is_dir() and not d.name.startswith("_") and (d / "init.lua").exists():
                names.append(d.name)
    return names


def _render_text(results: list[dict]) -> str:
    lines = ["Library Coverage Audit", "=" * 90]
    lines.append(
        f"  {'Library':20s}  {'Funcs':>5}  "
        f"{'Doc%':>5}  {'Param%':>6}  {'Ret%':>5}  "
        f"{'API%':>5}  {'Test%':>5}  Test?"
    )
    lines.append("  " + "-" * 86)
    for r in results:
        test_flag = "Y" if r["has_test"] else "N"
        lines.append(
            f"  {r['library']:20s}  {r['total_functions']:>5}  "
            f"{r['doc_pct']:>5.1f}  {r['param_pct']:>6.1f}  {r['return_pct']:>5.1f}  "
            f"{r['api_md_pct']:>5.1f}  {r['test_pct']:>5.1f}  {test_flag}"
        )
    lines.append("=" * 90)

    # Per-library gap details
    gap_libs = [r for r in results if r["test_missing"] or r["api_md_missing"]]
    if gap_libs:
        lines.append("")
        lines.append("Gaps (test coverage — first 10 missing per library):")
        for r in gap_libs:
            if r["test_missing"]:
                shown = r["test_missing"][:10]
                lines.append(f"  {r['library']}: missing @covers for: {', '.join(shown)}")

    return "\n".join(lines)


def _render_markdown(results: list[dict]) -> str:
    from datetime import date
    lines = [
        "# Library Coverage",
        "",
        f"_Auto-generated {date.today().isoformat()} — `python tools/audit/library_coverage.py`_",
        "",
        "## Overview",
        "",
        "| Library | Funcs | Doc% | @param% | @return% | API doc% | Test% | Test file? |",
        "| ------- | ----: | ---: | ------: | -------: | -------: | ----: | :--------: |",
    ]
    for r in results:
        test_flag = "✅" if r["has_test"] else "❌"
        lines.append(
            f"| `{r['library']}` | {r['total_functions']} | {r['doc_pct']} | "
            f"{r['param_pct']} | {r['return_pct']} | {r['api_md_pct']} | "
            f"{r['test_pct']} | {test_flag} |"
        )

    # Summary stats
    total_fns = sum(r["total_functions"] for r in results)
    avg_doc = round(sum(r["doc_pct"] for r in results) / len(results), 1) if results else 0.0
    avg_api = round(sum(r["api_md_pct"] for r in results) / len(results), 1) if results else 0.0
    avg_test = round(sum(r["test_pct"] for r in results) / len(results), 1) if results else 0.0
    lines += [
        "",
        "## Summary",
        "",
        f"- Libraries audited: **{len(results)}**",
        f"- Total public functions: **{total_fns}**",
        f"- Average docstring coverage: **{avg_doc}%**",
        f"- Average API doc coverage: **{avg_api}%**",
        f"- Average test coverage: **{avg_test}%**",
        "",
    ]

    # Gaps
    gap_libs = [r for r in results if r["test_missing"] or r["api_md_missing"]]
    if gap_libs:
        lines += ["## Gaps", ""]
        for r in gap_libs:
            lines.append(f"### `{r['library']}`")
            if r["api_md_missing"]:
                listed = ", ".join(f"`{n}`" for n in r["api_md_missing"][:15])
                more = f" (+{len(r['api_md_missing'])-15} more)" if len(r["api_md_missing"]) > 15 else ""
                lines.append(f"- **Not in API doc**: {listed}{more}")
            if r["test_missing"]:
                listed = ", ".join(f"`{n}`" for n in r["test_missing"][:15])
                more = f" (+{len(r['test_missing'])-15} more)" if len(r["test_missing"]) > 15 else ""
                lines.append(f"- **No @covers**: {listed}{more}")
            lines.append("")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--library", metavar="NAME", help="Audit only this library")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--output", metavar="PATH", help="Write Markdown report to file")
    parser.add_argument("--threshold", type=float, default=0,
                        help="Exit 1 if average test coverage < THRESHOLD percent")
    args = parser.parse_args()

    if args.library:
        libraries = [args.library]
    else:
        libraries = _find_libraries()

    results = [audit_library(lib) for lib in libraries]

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print(_render_text(results))

    if args.output:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(_render_markdown(results), encoding="utf-8")
        print(f"\n→ {args.output}")

    if args.threshold > 0:
        avg_test = sum(r["test_pct"] for r in results) / len(results) if results else 0.0
        if avg_test < args.threshold:
            print(f"\nFAIL: test coverage {avg_test:.1f}% < threshold {args.threshold}%", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
