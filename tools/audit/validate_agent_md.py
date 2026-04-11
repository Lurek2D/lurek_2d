#!/usr/bin/env python3
"""Validate merged docs/specs/<module>.md module references.

The script name is retained for compatibility with existing tasks and docs, but
it now validates the merged specs-only format after the retirement of
src/<module>/AGENT.md.

Usage:
    python tools/audit/validate_agent_md.py
    python tools/audit/validate_agent_md.py --module physics
    python tools/audit/validate_agent_md.py --all
    python tools/audit/validate_agent_md.py --scaffold physics
    python tools/audit/validate_agent_md.py --scaffold physics --write
    python tools/audit/validate_agent_md.py --strict
    python tools/audit/validate_agent_md.py --json
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

WORKSPACE = Path(__file__).resolve().parent.parent.parent
SRC = WORKSPACE / "src"
SPECS = WORKSPACE / "docs" / "specs"
LUA_API = SRC / "lua_api"

PASS = "PASS"
WARN = "WARN"
ERROR = "ERROR"

REQUIRED_SECTIONS = [
    "General Info",
    "Summary",
    "Files",
    "Types",
    "Functions",
    "References",
    "Notes",
]


@dataclass
class Finding:
    code: str
    name: str
    severity: str
    detail: str

    def to_dict(self) -> dict:
        return {
            "code": self.code,
            "name": self.name,
            "severity": self.severity,
            "detail": self.detail,
        }


def _read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return ""


def _doc_path(module: str) -> Path:
    return SPECS / f"{module}.md"


def _section_body(content: str, heading: str) -> str:
    pattern = rf"## {re.escape(heading)}\s*\n(.*?)(?=\n## |\Z)"
    match = re.search(pattern, content, re.DOTALL)
    return match.group(1).strip() if match else ""


def _has_section(content: str, heading: str) -> bool:
    return bool(re.search(rf"^## {re.escape(heading)}", content, re.MULTILINE))


def _module_dir(module: str) -> Path:
    return SRC / module


def _rs_files(module: str) -> set[str]:
    return {path.relative_to(_module_dir(module)).as_posix() for path in _module_dir(module).rglob("*.rs")}


def _public_type_names(module: str) -> set[str]:
    names: set[str] = set()
    pattern = re.compile(r"^\s*pub(?:\([^)]*\))?\s+(?:struct|enum|trait|type)\s+(\w+)", re.MULTILINE)
    for path in _module_dir(module).rglob("*.rs"):
        names.update(pattern.findall(_read(path)))
    return names


def _public_function_names(module: str) -> set[str]:
    names: set[str] = set()
    pattern = re.compile(r"^\s*pub(?:\([^)]*\))?\s+(?:unsafe\s+|async\s+|const\s+)?fn\s+(\w+)", re.MULTILINE)
    for path in _module_dir(module).rglob("*.rs"):
        names.update(pattern.findall(_read(path)))
    return names


def _lua_api_path(module: str) -> Optional[Path]:
    file_path = LUA_API / f"{module}_api.rs"
    dir_path = LUA_API / f"{module}_api"
    if file_path.exists():
        return file_path
    if dir_path.is_dir():
        return dir_path
    return None


def _load_lua_parser():
    spec = importlib.util.spec_from_file_location("gen_lua_api", WORKSPACE / "tools" / "docs" / "gen_lua_api.py")
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def _lua_exposed_fns(module: str) -> list[str]:
    if _lua_api_path(module) is None:
        return []
    try:
        lua_parser = _load_lua_parser()
        all_functions = lua_parser.collect_all_functions(WORKSPACE / "src" / "lua_api")
        functions = all_functions.get(module, [])
        labels = []
        for function in functions:
            if function.lua_name:
                labels.append(function.lua_name)
            elif function.name:
                labels.append(function.name)
        return sorted(set(labels))
    except Exception:
        api = _lua_api_path(module)
        sources = [_read(path) for path in api.rglob("*.rs")] if api and api.is_dir() else [_read(api)] if api else []
        names: set[str] = set()
        for source in sources:
            names.update(re.findall(r'(?:tbl|luna|table)\.set\("([^\"]+)"', source))
        return sorted(names)


def _extract_first_code_token_per_bullet(section: str) -> set[str]:
    tokens: set[str] = set()
    for line in section.splitlines():
        stripped = line.strip()
        if not stripped.startswith("- "):
            continue
        match = re.search(r"`([^`]+)`", stripped)
        if not match:
            continue
        token = match.group(1)
        if token.endswith(".rs"):
            continue
        tokens.add(token.split("::")[-1].split(":")[-1])
    return tokens


def validate(module: str) -> list[Finding]:
    results: list[Finding] = []
    spec_path = _doc_path(module)

    if not spec_path.exists():
        results.append(Finding("M-00", "Module reference exists", ERROR, f"Spec not found at {spec_path.relative_to(WORKSPACE)}"))
        return results

    content = _read(spec_path)

    missing_sections = [section for section in REQUIRED_SECTIONS if not _has_section(content, section)]
    if _lua_api_path(module) and not _has_section(content, "Lua API Reference"):
        missing_sections.append("Lua API Reference")
    if missing_sections:
        results.append(Finding("M-01", "Required sections", ERROR, f"Missing sections: {', '.join(missing_sections)}"))
    else:
        results.append(Finding("M-01", "Required sections", PASS, "All required sections present"))

    summary = _section_body(content, "Summary")
    if not summary:
        results.append(Finding("M-02", "Summary quality", ERROR, "## Summary section missing or empty"))
    else:
        length = len(summary)
        if length < 300:
            results.append(Finding("M-02", "Summary quality", ERROR, f"Summary too short ({length} chars; minimum 300 required)"))
        elif length < 500:
            results.append(Finding("M-02", "Summary quality", WARN, f"Summary marginal ({length} chars; target is 500+)") )
        else:
            results.append(Finding("M-02", "Summary quality", PASS, f"Summary is {length} chars"))

    general_info = _section_body(content, "General Info")
    info_requirements = ["Module group", "Source path", "Rust test path(s)", "Lua test path(s)"]
    missing_info = [label for label in info_requirements if label not in general_info]
    if missing_info:
        results.append(Finding("M-03", "General Info", ERROR, f"Missing General Info facts: {', '.join(missing_info)}"))
    else:
        results.append(Finding("M-03", "General Info", PASS, "General Info includes the required facts"))

    listed_files = set(re.findall(r"`([^`]+\.rs)`", _section_body(content, "Files")))
    actual_files = _rs_files(module)
    missing_files = sorted(actual_files - listed_files)
    extra_files = sorted(listed_files - actual_files)
    if missing_files:
        results.append(Finding("M-04", "Files sync", ERROR, f"Files on disk not listed: {', '.join(missing_files[:8])}"))
    elif extra_files:
        results.append(Finding("M-04", "Files sync", WARN, f"Files listed but not on disk: {', '.join(extra_files[:8])}"))
    else:
        results.append(Finding("M-04", "Files sync", PASS, f"Files section matches disk ({len(actual_files)} files)"))

    types_in_spec = _extract_first_code_token_per_bullet(_section_body(content, "Types"))
    types_in_code = _public_type_names(module)
    missing_types = sorted(types_in_code - types_in_spec)
    if missing_types:
        results.append(Finding("M-05", "Types coverage", WARN, f"Public types missing from spec: {', '.join(missing_types[:8])}"))
    else:
        results.append(Finding("M-05", "Types coverage", PASS, f"Types section covers {len(types_in_code)} public types"))

    functions_in_spec = _extract_first_code_token_per_bullet(_section_body(content, "Functions"))
    functions_in_code = _public_function_names(module)
    missing_functions = sorted(functions_in_code - functions_in_spec)
    if missing_functions:
        results.append(Finding("M-06", "Functions coverage", WARN, f"Public functions missing from spec: {', '.join(missing_functions[:8])}"))
    else:
        results.append(Finding("M-06", "Functions coverage", PASS, f"Functions section covers {len(functions_in_code)} public functions"))

    if _lua_api_path(module):
        lua_api_body = _section_body(content, "Lua API Reference")
        exposed = _lua_exposed_fns(module)
        missing_lua = [name for name in exposed if name not in lua_api_body]
        if missing_lua:
            results.append(Finding("M-07", "Lua API coverage", WARN, f"Lua bindings missing from spec: {', '.join(missing_lua[:8])}"))
        else:
            results.append(Finding("M-07", "Lua API coverage", PASS, f"Lua API section covers {len(exposed)} bindings"))
    else:
        results.append(Finding("M-07", "Lua API coverage", PASS, "No dedicated Lua API file for this module"))

    references = _section_body(content, "References")
    if not references:
        results.append(Finding("M-08", "References section", ERROR, "## References section missing or empty"))
    else:
        results.append(Finding("M-08", "References section", PASS, "References section present"))

    notes = _section_body(content, "Notes")
    if not notes:
        results.append(Finding("M-09", "Notes section", ERROR, "## Notes section missing or empty"))
    else:
        results.append(Finding("M-09", "Notes section", PASS, "Notes section present"))

    todo_count = len(re.findall(r"\bTODO\b", content, re.IGNORECASE))
    if todo_count:
        results.append(Finding("M-10", "No TODO placeholders", WARN, f"{todo_count} TODO placeholder(s) remain"))
    else:
        results.append(Finding("M-10", "No TODO placeholders", PASS, "No TODO placeholders found"))

    return results


def _load_spec_generator():
    spec = importlib.util.spec_from_file_location("gen_module_specs", WORKSPACE / "tools" / "docs" / "gen_module_specs.py")
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def scaffold(module: str) -> str:
    generator = _load_spec_generator()
    lua_parser = generator.load_lua_parser()
    content, _ = generator.build_spec(module, lua_parser)
    return content


_COLORS = {ERROR: "\033[31m", WARN: "\033[33m", PASS: "\033[32m"}
_RESET = "\033[0m"


def _fmt(finding: Finding, use_color: bool = True) -> str:
    color = _COLORS.get(finding.severity, "") if use_color else ""
    reset = _RESET if use_color else ""
    return f"  {color}{finding.severity:<5}{reset}  [{finding.code}] {finding.name}: {finding.detail}"


def report_module(module: str, findings: list[Finding], color: bool = True) -> int:
    errors = [finding for finding in findings if finding.severity == ERROR]
    warns = [finding for finding in findings if finding.severity == WARN]
    passes = [finding for finding in findings if finding.severity == PASS]

    verdict = "FAIL" if errors else ("WARN" if warns else "PASS")
    verdict_color = {"FAIL": "\033[31m", "WARN": "\033[33m", "PASS": "\033[32m"}.get(verdict, "") if color else ""
    reset = _RESET if color else ""
    print(f"\n{verdict_color}[{verdict}]{reset}  docs/specs/{module}.md")
    for finding in findings:
        print(_fmt(finding, color))
    print(f"  --- {len(passes)} passed, {len(warns)} warnings, {len(errors)} errors")
    return 1 if errors else 0


def _discover_modules() -> list[str]:
    return sorted(path.name for path in SRC.iterdir() if path.is_dir())


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(
        description="Validate and scaffold merged docs/specs/<module>.md files for Lurek2D src modules.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--module", "-m", nargs="+", metavar="NAME", help="Module(s) to validate")
    parser.add_argument("--all", "-a", action="store_true", help="Validate all src/ modules")
    parser.add_argument("--scaffold", "-s", metavar="NAME", help="Print a generated module spec for MODULE to stdout")
    parser.add_argument("--write", action="store_true", help="With --scaffold: write the output to docs/specs/MODULE.md")
    parser.add_argument("--strict", action="store_true", help="Treat WARN as ERROR")
    parser.add_argument("--json", action="store_true", help="Output results as JSON")
    parser.add_argument("--no-color", action="store_true", help="Suppress ANSI color codes")
    args = parser.parse_args()

    use_color = not args.no_color and sys.stdout.isatty()

    if args.scaffold:
        module = args.scaffold
        if not _module_dir(module).is_dir():
            print(f"ERROR: src/{module}/ does not exist", file=sys.stderr)
            return 2
        text = scaffold(module)
        if args.write:
            out_path = _doc_path(module)
            out_path.write_text(text.rstrip() + "\n", encoding="utf-8")
            print(f"Written: {out_path.relative_to(WORKSPACE)}")
        else:
            print(text)
        return 0

    if args.all:
        modules = _discover_modules()
    elif args.module:
        modules = args.module
    else:
        modules = _discover_modules()

    if not modules:
        print("No modules to validate -- use --module or --all", file=sys.stderr)
        return 2

    all_results: dict[str, list[dict]] = {}
    exit_code = 0
    for module in modules:
        findings = validate(module)
        if args.strict:
            findings = [
                Finding(f.code, f.name, ERROR if f.severity == WARN else f.severity, f.detail)
                for f in findings
            ]
        all_results[module] = [finding.to_dict() for finding in findings]
        if any(finding.severity == ERROR for finding in findings):
            exit_code = 1

    if args.json:
        print(json.dumps(all_results, indent=2))
        return exit_code

    total_errors = 0
    total_warns = 0
    for module in modules:
        findings = [Finding(**data) for data in all_results[module]]
        report_module(module, findings, use_color)
        total_errors += sum(1 for finding in findings if finding.severity == ERROR)
        total_warns += sum(1 for finding in findings if finding.severity == WARN)

    print()
    print(f"Validated {len(modules)} module(s): {total_errors} error(s), {total_warns} warning(s)")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
