#!/usr/bin/env python3
"""
unit_test_api_coverage.py - Lurek2D unit-test API coverage analysis.

Each Lua unit-test `it()` block must declare exactly one API it exercises with
one explicit marker:

    it("getDelta returns a number", function()
        -- @covers lurek.timer.getDelta
        local dt = lurek.timer.getDelta()
        expect_type("number", dt)
    end)

For class methods use the bare ClassName:method form:

    it("World:step advances physics", function()
        -- @covers World:step
        world:step(1/60)
    end)

Unit-test coverage is counted with the same granularity as example coverage:

    1 it() block = 1 @covers marker = 1 Lurek API

The tool reports structural violations when a block has no marker, has more
than one marker, uses an unknown API symbol, or duplicates the same marker in
multiple `it()` blocks.

The script also runs a heuristic pass: inside it() blocks it looks for
references matching known lua_names and marks those as heuristic-covered
without counting them as explicit coverage.

Usage:
    python tools/audit/unit_test_api_coverage.py
    python tools/audit/unit_test_api_coverage.py --json
    python tools/audit/unit_test_api_coverage.py --save
    python tools/audit/unit_test_api_coverage.py --module math
    python tools/audit/unit_test_api_coverage.py --strict
    python tools/audit/unit_test_api_coverage.py --gaps
    python tools/audit/unit_test_api_coverage.py --suggest
    python tools/audit/unit_test_api_coverage.py --threshold 30

Exit codes:
    0 - success (or coverage >= threshold)
    1 - coverage below threshold
    2 - fatal error
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, NamedTuple, Optional, Set, Tuple


def _configure_stdout_utf8() -> None:
    """Avoid Windows codepage failures for report output."""
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass


ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"
LUA_UNIT_TESTS = ROOT / "tests" / "lua" / "unit"
OUTPUT_JSON = ROOT / "logs" / "data" / "unit_test_coverage.json"
OUTPUT_MD = ROOT / "logs" / "reports" / "unit_test_coverage.md"


class ApiEntry(NamedTuple):
    """A single API function or method."""

    module: str
    lua_name: str
    name: str
    is_method: bool
    owner_type: str
    source_file: str
    source_line: int


class CoverageResult(NamedTuple):
    """Coverage status of a single API entry."""

    api: ApiEntry
    explicit: bool
    heuristic: bool
    test_locations: List[str]


class MarkerOccurrence(NamedTuple):
    """One explicit marker attached to a single it() block."""

    api_ref: str
    file: str
    line: int
    it_description: str


class StructureViolation(NamedTuple):
    """A unit-test structure problem that invalidates explicit coverage."""

    file: str
    line: int
    code: str
    message: str
    it_description: str = ""
    api_ref: str = ""


class ItBlock(NamedTuple):
    """One parsed it() block."""

    description: str
    body: str
    line: int


def load_api(module_filter: Optional[str] = None) -> List[ApiEntry]:
    """Load every API entry from the generated JSON."""
    try:
        data = json.loads(API_JSON.read_text(encoding="utf-8"))
    except FileNotFoundError:
        sys.exit(f"[ERROR] API JSON not found: {API_JSON}\nRun: python tools/docs/gen_lua_api_data.py first.")
    except json.JSONDecodeError as exc:
        sys.exit(f"[ERROR] JSON parse error in {API_JSON}: {exc}")

    modules = data["lua_api"]["modules"]
    entries: List[ApiEntry] = []

    for mod_name, mod in modules.items():
        if module_filter and mod_name != module_filter:
            continue
        src = mod.get("source_file", "")

        for fn in mod.get("functions") or []:
            entries.append(
                ApiEntry(
                    module=mod_name,
                    lua_name=fn["lua_name"],
                    name=fn["name"],
                    is_method=False,
                    owner_type="",
                    source_file=fn.get("file", src),
                    source_line=fn.get("line", 0),
                )
            )

        for cls_name, cls in (mod.get("classes") or {}).items():
            for meth in cls.get("methods") or []:
                entries.append(
                    ApiEntry(
                        module=mod_name,
                        lua_name=meth["lua_name"],
                        name=meth["name"],
                        is_method=True,
                        owner_type=cls_name,
                        source_file=meth.get("file", src),
                        source_line=meth.get("line", 0),
                    )
                )

    return entries


_EXPLICIT_RE = re.compile(
    r"--\s*@(covers|tests)\s+([a-zA-Z_][\w.:]*(?::[a-zA-Z_]\w*)?)",
    re.IGNORECASE,
)
_IT_OPEN_RE = re.compile(r"\bit\s*\(")
_LUREK_REF_RE = re.compile(r"\blurek\.([a-z_]\w*)\.([a-zA-Z_]\w*)")
_METHOD_CALL_RE = re.compile(r"\b([A-Z][a-zA-Z_]*)\s*:\s*([a-zA-Z_]\w*)\s*\(")


def _line_number_at(content: str, pos: int) -> int:
    """Convert a byte offset into a 1-based line number."""
    return content.count("\n", 0, pos) + 1


def _parse_it_blocks(content: str) -> List[ItBlock]:
    """Extract all top-level it() block descriptions, bodies, and start lines."""
    results: List[ItBlock] = []
    length = len(content)

    for match in _IT_OPEN_RE.finditer(content):
        start = match.end()
        if start >= length:
            continue

        desc = ""
        desc_match = re.match(r'\s*["\']([^"\']*)["\']', content[start : start + 200])
        if desc_match:
            desc = desc_match.group(1)

        func_match = re.search(r"\bfunction\s*\(\s*\)", content[start : start + 300])
        if not func_match:
            continue

        func_start = start + func_match.end()
        depth = 1
        cursor = func_start
        while cursor < length and depth > 0:
            if content[cursor] in {'"', "'"}:
                quote = content[cursor]
                cursor += 1
                while cursor < length and content[cursor] != quote:
                    if content[cursor] == "\\":
                        cursor += 1
                    cursor += 1
                cursor += 1
                continue
            if content[cursor : cursor + 2] == "--":
                while cursor < length and content[cursor] != "\n":
                    cursor += 1
                continue
            func_kw = re.match(r"\bfunction\b", content[cursor : cursor + 8])
            if func_kw:
                depth += 1
                cursor += func_kw.end()
                continue
            end_kw = re.match(r"\bend\b", content[cursor : cursor + 3])
            if end_kw:
                depth -= 1
                if depth == 0:
                    results.append(
                        ItBlock(
                            description=desc,
                            body=content[func_start:cursor],
                            line=_line_number_at(content, match.start()),
                        )
                    )
                    break
                cursor += end_kw.end()
                continue
            cursor += 1

    return results


def _collect_preceding_markers(lines: List[str], it_line: int) -> List[str]:
    """Collect contiguous @covers/@tests markers immediately preceding one it()."""
    markers: List[str] = []
    cursor = it_line - 2
    while cursor >= 0:
        stripped = lines[cursor].strip()
        if not stripped:
            cursor -= 1
            continue
        if stripped.startswith("--"):
            marker = _EXPLICIT_RE.match(stripped)
            if marker:
                markers.append(marker.group(2).strip().rstrip(".,;"))
            cursor -= 1
            continue
        break
    markers.reverse()
    return markers


def scan_file(
    lua_path: Path,
    known_lua_names: Set[str],
    known_methods: Dict[str, Set[str]],
    validate_unknown_markers: bool = True,
) -> Tuple[List[MarkerOccurrence], Set[str], Dict[str, List[str]], List[StructureViolation], int]:
    """Scan a single Lua test file."""
    try:
        content = lua_path.read_text(encoding="utf-8")
    except OSError:
        return [], set(), {}, [], 0

    filename = lua_path.name
    lines = content.splitlines()
    explicit_candidates: List[MarkerOccurrence] = []
    heuristic_set: Set[str] = set()
    locations: Dict[str, List[str]] = defaultdict(list)
    violations: List[StructureViolation] = []

    for block in _parse_it_blocks(content):
        loc = f"{filename}:{block.description}" if block.description else filename
        markers = _collect_preceding_markers(lines, block.line)
        unique_markers = list(dict.fromkeys(markers))

        if not markers:
            violations.append(
                StructureViolation(
                    file=filename,
                    line=block.line,
                    code="missing-marker",
                    message="Unit-test it() block must have exactly one preceding @covers marker.",
                    it_description=block.description,
                )
            )
        elif len(markers) != 1:
            violations.append(
                StructureViolation(
                    file=filename,
                    line=block.line,
                    code="multiple-markers",
                    message=f"Unit-test it() block must have exactly one preceding @covers marker; found {len(markers)}.",
                    it_description=block.description,
                )
            )
        elif validate_unknown_markers and markers[0] not in known_lua_names:
            violations.append(
                StructureViolation(
                    file=filename,
                    line=block.line,
                    code="unknown-marker",
                    message=f"Marker '{markers[0]}' does not match a known Lurek API symbol.",
                    it_description=block.description,
                    api_ref=markers[0],
                )
            )
        else:
            explicit_candidates.append(
                MarkerOccurrence(
                    api_ref=markers[0],
                    file=filename,
                    line=block.line,
                    it_description=block.description,
                )
            )
            locations[markers[0]].append(loc)

        for ref_match in _LUREK_REF_RE.finditer(block.body):
            lua_name = f"lurek.{ref_match.group(1)}.{ref_match.group(2)}"
            if lua_name in known_lua_names and lua_name not in unique_markers:
                heuristic_set.add(lua_name)
                tagged = f"{loc} [heuristic]"
                if tagged not in locations[lua_name]:
                    locations[lua_name].append(tagged)

        for ref_match in _METHOD_CALL_RE.finditer(block.body):
            lua_name = f"{ref_match.group(1)}:{ref_match.group(2)}"
            if lua_name in known_lua_names and lua_name not in unique_markers:
                heuristic_set.add(lua_name)
                tagged = f"{loc} [heuristic]"
                if tagged not in locations[lua_name]:
                    locations[lua_name].append(tagged)

        for method_match in re.finditer(r"\w+\s*:\s*([a-zA-Z_]\w*)\s*\(", block.body):
            method_name = method_match.group(1)
            for owner_type, method_names in known_methods.items():
                if method_name not in method_names:
                    continue
                lua_name = f"{owner_type}:{method_name}"
                if lua_name in known_lua_names and lua_name not in unique_markers:
                    heuristic_set.add(lua_name)
                    tagged = f"{loc} [heuristic]"
                    if tagged not in locations[lua_name]:
                        locations[lua_name].append(tagged)

    return explicit_candidates, heuristic_set, dict(locations), violations, len(_parse_it_blocks(content))


def scan_all_tests(
    test_dir: Path,
    api_entries: List[ApiEntry],
    validate_unknown_markers: bool = True,
) -> Tuple[List[CoverageResult], dict]:
    """Scan all Lua unit tests and return coverage results plus structure diagnostics."""
    known_lua_names: Set[str] = {entry.lua_name for entry in api_entries}
    known_methods: Dict[str, Set[str]] = defaultdict(set)
    for entry in api_entries:
        if entry.is_method:
            known_methods[entry.owner_type].add(entry.name)

    explicit_occurrences: Dict[str, List[MarkerOccurrence]] = defaultdict(list)
    all_heuristic: Set[str] = set()
    all_locations: Dict[str, List[str]] = defaultdict(list)
    violations: List[StructureViolation] = []
    total_it_blocks = 0

    for lua_path in sorted(test_dir.rglob("*.lua")):
        explicit, heuristic, locs, file_violations, it_count = scan_file(
            lua_path,
            known_lua_names,
            known_methods,
            validate_unknown_markers=validate_unknown_markers,
        )
        for occurrence in explicit:
            explicit_occurrences[occurrence.api_ref].append(occurrence)
        all_heuristic.update(heuristic)
        for key, values in locs.items():
            all_locations[key].extend(values)
        violations.extend(file_violations)
        total_it_blocks += it_count

    all_explicit: Set[str] = set()
    duplicate_api_refs = 0
    for api_ref, occurrences in explicit_occurrences.items():
        if len(occurrences) == 1:
            all_explicit.add(api_ref)
            continue
        duplicate_api_refs += 1
        first = occurrences[0]
        for occurrence in occurrences:
            violations.append(
                StructureViolation(
                    file=occurrence.file,
                    line=occurrence.line,
                    code="duplicate-marker",
                    message=(
                        f"Marker '{api_ref}' is duplicated across multiple it() blocks; "
                        f"first seen at {first.file}:{first.line}."
                    ),
                    it_description=occurrence.it_description,
                    api_ref=api_ref,
                )
            )

    structure_items = [
        {
            "file": violation.file,
            "line": violation.line,
            "code": violation.code,
            "message": violation.message,
            "it_description": violation.it_description,
            "api_ref": violation.api_ref,
        }
        for violation in sorted(violations, key=lambda item: (item.file, item.line, item.code, item.api_ref))
    ]
    by_code: Dict[str, int] = defaultdict(int)
    for item in structure_items:
        by_code[item["code"]] += 1

    structure = {
        "total_it_blocks": total_it_blocks,
        "valid_single_marker_blocks": len(all_explicit),
        "invalid_it_blocks": sum(by_code.values()),
        "duplicate_api_markers": duplicate_api_refs,
        "by_code": dict(sorted(by_code.items())),
        "violations": structure_items,
    }

    results: List[CoverageResult] = []
    for entry in api_entries:
        explicit = entry.lua_name in all_explicit
        heuristic = (not explicit) and (entry.lua_name in all_heuristic)
        results.append(
            CoverageResult(
                api=entry,
                explicit=explicit,
                heuristic=heuristic,
                test_locations=all_locations.get(entry.lua_name, []),
            )
        )

    return results, structure


def build_analytics(results: List[CoverageResult], structure: dict, strict: bool = False) -> dict:
    """Compute summary plus per-module breakdown from coverage results."""
    total = len(results)
    explicit_count = sum(1 for result in results if result.explicit)
    heuristic_count = sum(1 for result in results if result.heuristic)
    covered_any = explicit_count + heuristic_count

    def pct(value: int, base: int) -> float:
        return round(value / base * 100, 2) if base else 100.0

    by_module: Dict[str, List[CoverageResult]] = defaultdict(list)
    for result in results:
        by_module[result.api.module].append(result)

    modules: Dict[str, dict] = {}
    for module_name, module_results in sorted(by_module.items()):
        total_module = len(module_results)
        explicit_module = sum(1 for result in module_results if result.explicit)
        heuristic_module = sum(1 for result in module_results if result.heuristic)
        covered_module = explicit_module + heuristic_module
        modules[module_name] = {
            "total": total_module,
            "covered_explicit": explicit_module,
            "covered_heuristic": heuristic_module,
            "covered_any": covered_module,
            "uncovered": total_module - explicit_module,
            "uncovered_any": total_module - covered_module,
            "pct_explicit": pct(explicit_module, total_module),
            "pct_any": pct(covered_module, total_module),
            "uncovered_apis": [
                {
                    "lua_name": result.api.lua_name,
                    "name": result.api.name,
                    "is_method": result.api.is_method,
                    "owner_type": result.api.owner_type,
                    "source_file": result.api.source_file,
                    "source_line": result.api.source_line,
                    "coverage_hint": "heuristic" if result.heuristic else "none",
                    "locations": result.test_locations[:5],
                }
                for result in module_results
                if not result.explicit
            ],
            "uncovered_any_apis": [
                {
                    "lua_name": result.api.lua_name,
                    "name": result.api.name,
                    "is_method": result.api.is_method,
                    "owner_type": result.api.owner_type,
                    "source_file": result.api.source_file,
                    "source_line": result.api.source_line,
                }
                for result in module_results
                if not result.explicit and not result.heuristic
            ],
        }

    return {
        "generated": datetime.now(timezone.utc).isoformat(),
        "generator": "tools/audit/unit_test_api_coverage.py",
        "strict_mode": strict,
        "structure": structure,
        "summary": {
            "total_apis": total,
            "covered_explicit": explicit_count,
            "covered_heuristic": heuristic_count,
            "covered_any": covered_any,
            "uncovered": total - explicit_count,
            "uncovered_any": total - covered_any,
            "pct_explicit": pct(explicit_count, total),
            "pct_any": pct(covered_any, total),
            "total_modules": len(modules),
        },
        "modules": modules,
    }


def format_summary(data: dict, strict: bool) -> str:
    """Render a compact human-readable summary."""
    summary = data["summary"]
    structure = data.get("structure", {})
    lines = [
        "Lurek2D Unit-Test API Coverage",
        "================================",
        "",
        f"Generated: {data['generated'][:19]}",
        "Requirement: 1 it() block = 1 @covers marker = 1 API",
        "Heuristic hits are hints only and do not count as explicit coverage.",
        "",
        f"it() blocks scanned:  {structure.get('total_it_blocks', 0)}",
        f"Structure violations: {len(structure.get('violations', []))}",
        f"Duplicate markers:    {structure.get('duplicate_api_markers', 0)}",
        "",
        f"Total APIs:           {summary['total_apis']}",
        f"Covered (explicit):   {summary['covered_explicit']} ({summary['pct_explicit']:.1f}%)",
        f"Heuristic-only hits:  {summary['covered_heuristic']} ({summary['pct_any'] - summary['pct_explicit']:.1f}%)",
        f"Missing @covers:      {summary['uncovered']} ({100 - summary['pct_explicit']:.1f}%)",
        f"Zero evidence:        {summary['uncovered_any']} ({100 - summary['pct_any']:.1f}%)",
        "",
    ]
    if structure.get("by_code"):
        lines.append("Structure diagnostics:")
        for code, count in structure["by_code"].items():
            lines.append(f"  - {code}: {count}")
        lines.append("")

    lines.append("Module breakdown (worst to best explicit coverage):")
    for module_name, module_data in sorted(data["modules"].items(), key=lambda item: item[1]["pct_explicit"]):
        lines.append(
            f"  {module_name:<16} {module_data['pct_explicit']:>5.1f}% "
            f"({module_data['covered_explicit']}/{module_data['total']})"
        )
    return "\n".join(lines)


def format_markdown(data: dict, strict: bool) -> str:
    """Render the saved Markdown report."""
    summary = data["summary"]
    structure = data.get("structure", {})
    markdown = [
        "# Lurek2D Unit-Test API Coverage",
        "",
        f"*Generated: {data['generated'][:19]} - exactly one `@covers` marker per unit-test `it()` block*",
        "",
        "## Summary",
        "",
        "| Metric | Value |",
        "|--------|-------|",
        f"| Total APIs | {summary['total_apis']} |",
        f"| Unit `it()` blocks | {structure.get('total_it_blocks', 0)} |",
        f"| Structure violations | {len(structure.get('violations', []))} |",
        f"| Duplicate API markers | {structure.get('duplicate_api_markers', 0)} |",
        f"| Covered (explicit `@covers`) | {summary['covered_explicit']} ({summary['pct_explicit']:.1f}%) |",
        f"| Heuristic-only hits | {summary['covered_heuristic']} ({summary['pct_any'] - summary['pct_explicit']:.1f}%) |",
        f"| Missing explicit `@covers` | {summary['uncovered']} ({100 - summary['pct_explicit']:.1f}%) |",
        f"| Zero-evidence APIs | {summary['uncovered_any']} ({100 - summary['pct_any']:.1f}%) |",
        "",
    ]

    if structure.get("violations"):
        markdown.extend(
            [
                "## Structure Violations",
                "",
                "| File | Line | Code | Message |",
                "|------|------|------|---------|",
            ]
        )
        for violation in structure["violations"][:100]:
            markdown.append(
                f"| `{violation['file']}` | {violation['line']} | `{violation['code']}` | {violation['message']} |"
            )
        if len(structure["violations"]) > 100:
            markdown.append(
                f"| ... | ... | ... | {len(structure['violations']) - 100} more violations omitted |"
            )
        markdown.append("")

    markdown.extend(
        [
            "## Module Coverage",
            "",
            "| Module | Total | Explicit | Heuristic-only | Explicit% | Missing `@covers` | Zero-evidence |",
            "|--------|-------|----------|----------------|-----------|-------------------|---------------|",
        ]
    )
    for module_name, module_data in sorted(data["modules"].items()):
        markdown.append(
            f"| `{module_name}` | {module_data['total']} | {module_data['covered_explicit']} | "
            f"{module_data['covered_heuristic']} | {module_data['pct_explicit']:.1f}% | "
            f"{module_data['uncovered']} | {module_data['uncovered_any']} |"
        )

    markdown.extend(
        [
            "",
            "## Missing Explicit `@covers` Coverage",
            "",
            "> These APIs still need exactly one explicit `-- @covers ...` annotation in one unit-test `it()` block.",
            "",
        ]
    )
    for module_name, module_data in sorted(data["modules"].items(), key=lambda item: -item[1]["uncovered"]):
        if not module_data["uncovered_apis"]:
            continue
        markdown.append(f"### `lurek.{module_name}` - {module_data['uncovered']} still need `@covers`")
        markdown.append("")
        for api in module_data["uncovered_apis"][:50]:
            label = f"`{api['lua_name']}`"
            if api["is_method"]:
                label = f"`{api['lua_name']}` *(method on {api['owner_type']})*"
            if api["coverage_hint"] == "heuristic":
                markdown.append(f"- {label} - referenced in tests, but still missing an explicit `@covers` annotation")
            else:
                markdown.append(f"- {label}")
        if len(module_data["uncovered_apis"]) > 50:
            markdown.append(f"  *... {len(module_data['uncovered_apis']) - 50} more*")
        markdown.append("")

    markdown.extend(
        [
            "## Annotation Convention",
            "",
            "Add exactly one `-- @covers <lua_name>` inside each `it()` block to declare the single API it exercises:",
            "",
            "```lua",
            'it("getDelta returns a number", function()',
            "    -- @covers lurek.timer.getDelta",
            "    local dt = lurek.timer.getDelta()",
            '    expect_type("number", dt)',
            "end)",
            "```",
            "",
            "Blocks with zero markers, multiple markers, or duplicated markers are invalid.",
        ]
    )
    return "\n".join(markdown)


def format_gaps(data: dict) -> str:
    """Render only uncovered APIs grouped by module."""
    lines = [
        "Lurek2D - APIs Missing Explicit @covers Coverage",
        "================================================",
        "",
    ]
    for module_name, module_data in sorted(data["modules"].items()):
        if not module_data["uncovered_apis"]:
            continue
        lines.append(f"[{module_name}] {module_data['uncovered']} missing @covers / {module_data['total']} total")
        for api in module_data["uncovered_apis"]:
            suffix = " [heuristic]" if api["coverage_hint"] == "heuristic" else ""
            lines.append(f"  {api['lua_name']}{suffix}")
        lines.append("")
    return "\n".join(lines)


def format_suggest(data: dict) -> str:
    """Render suggested it() stubs for uncovered APIs."""
    lines = [
        "-- Lurek2D - suggested unit test stubs for APIs missing explicit @covers coverage",
        "-- Add these to the appropriate tests/lua/unit/test_<module>.lua file",
        "",
    ]
    for module_name, module_data in sorted(data["modules"].items()):
        if not module_data["uncovered_apis"]:
            continue
        lines.append(f"-- {module_name}")
        for api in module_data["uncovered_apis"][:20]:
            lines.extend(
                [
                    f'it("{api["lua_name"]} works", function()',
                    f"    -- @covers {api['lua_name']}",
                    f"    -- TODO: add assertion for {api['name']}",
                    "end)",
                    "",
                ]
            )
        if len(module_data["uncovered_apis"]) > 20:
            lines.append(f"-- ... {len(module_data['uncovered_apis']) - 20} more uncovered in {module_name}")
            lines.append("")
    return "\n".join(lines)


def main() -> int:
    """CLI entry point."""
    _configure_stdout_utf8()
    parser = argparse.ArgumentParser(
        description="Lurek2D unit-test API coverage analyser.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Exit codes:")[1],
    )
    parser.add_argument("--json", action="store_true", help="Print JSON to stdout")
    parser.add_argument("--save", action="store_true", help=f"Save JSON to {OUTPUT_JSON} and Markdown to {OUTPUT_MD}")
    parser.add_argument("--module", metavar="NAME", help="Filter to a single module")
    parser.add_argument("--strict", action="store_true", help="Retained for compatibility; explicit @covers are always the primary metric")
    parser.add_argument("--gaps", action="store_true", help="Only list uncovered APIs")
    parser.add_argument("--suggest", action="store_true", help="Print it() stub templates for uncovered APIs")
    parser.add_argument("--threshold", type=float, default=0, metavar="PCT", help="Exit 1 if explicit @covers coverage is below this percentage")
    args = parser.parse_args()

    api_entries = load_api(module_filter=args.module)
    if not api_entries:
        sys.exit("[ERROR] No API entries loaded. Check --module name or re-run gen_lua_api_data.py.")

    results, structure = scan_all_tests(
        LUA_UNIT_TESTS,
        api_entries,
        validate_unknown_markers=args.module is None,
    )
    data = build_analytics(results, structure, strict=args.strict)

    if args.json:
        print(json.dumps(data, indent=2))
        return 0

    if args.gaps:
        print(format_gaps(data))
    elif args.suggest:
        print(format_suggest(data))
    else:
        print(format_summary(data, strict=args.strict))

    if args.save:
        OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT_MD.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT_JSON.write_text(json.dumps(data, indent=2), encoding="utf-8")
        OUTPUT_MD.write_text(format_markdown(data, strict=args.strict), encoding="utf-8")
        print(f"\nSaved JSON   -> {OUTPUT_JSON.relative_to(ROOT)}")
        print(f"Saved report -> {OUTPUT_MD.relative_to(ROOT)}")

    pct_explicit = data["summary"]["pct_explicit"]
    if args.threshold > 0 and pct_explicit < args.threshold:
        print(f"\n[FAIL] Explicit coverage {pct_explicit:.1f}% is below threshold {args.threshold:.1f}%")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
