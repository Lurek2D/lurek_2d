#!/usr/bin/env python3
"""
lua_nonunit_test_coverage.py - Audit canonical non-unit Lua tests in tests/lua_reorg.

Unit tests remain the only category that must reach 100% public API coverage.
This tool audits the remaining canonical Lua suites so they can still be
tracked consistently:

- integration: markers should name the APIs actually exercised by the scenario
- stress:      1 API = 1 @stress marker = 1 it() block
- security:    1 API = 1 @security marker = 1 it() block
- evidence:    one it() block may declare one or more @evidence markers,
               but each marker must point at an API the block actually
               generates evidence for

The report also builds a non-unit API ownership map:
    API -> category -> file -> it() description

Usage:
    python tools/audit/lua_nonunit_test_coverage.py
    python tools/audit/lua_nonunit_test_coverage.py --json
    python tools/audit/lua_nonunit_test_coverage.py --category stress
    python tools/audit/lua_nonunit_test_coverage.py --path tests/lua_reorg/evidence
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, List, NamedTuple, Optional, Set


def _configure_stdout_utf8() -> None:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass


ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"
TESTS_ROOT = ROOT / "tests" / "lua_reorg"


class ApiEntry(NamedTuple):
    module: str
    lua_name: str
    name: str
    is_method: bool
    owner_type: str


class ItBlock(NamedTuple):
    description: str
    body: str
    line: int


@dataclass(frozen=True)
class CategoryRule:
    name: str
    marker: str
    name_pattern: str
    require_exactly_one: bool
    validate_against_known_api: bool
    require_min_markers: int = 1


@dataclass(frozen=True)
class Finding:
    file: str
    line: int
    category: str
    code: str
    message: str
    it_description: str = ""
    api_ref: str = ""

    def as_dict(self) -> dict[str, object]:
        return {
            "file": self.file,
            "line": self.line,
            "category": self.category,
            "code": self.code,
            "message": self.message,
            "it_description": self.it_description,
            "api_ref": self.api_ref,
        }


@dataclass(frozen=True)
class MarkerOccurrence:
    api_ref: str
    category: str
    file: str
    line: int
    it_description: str


CATEGORY_RULES: dict[str, CategoryRule] = {
    "integration": CategoryRule(
        name="integration",
        marker="integration",
        name_pattern=r"^test_[a-z0-9_]+_integration\.lua$",
        require_exactly_one=False,
        validate_against_known_api=True,
    ),
    "stress": CategoryRule(
        name="stress",
        marker="stress",
        name_pattern=r"^test_[a-z0-9_]+_stress\.lua$",
        require_exactly_one=True,
        validate_against_known_api=True,
    ),
    "security": CategoryRule(
        name="security",
        marker="security",
        name_pattern=r"^test_[a-z0-9_]+_security\.lua$",
        require_exactly_one=True,
        validate_against_known_api=True,
    ),
    "evidence": CategoryRule(
        name="evidence",
        marker="evidence",
        name_pattern=r"^test_[a-z0-9_]+_evidence\.lua$",
        require_exactly_one=False,
        validate_against_known_api=True,
    ),
    "golden": CategoryRule(
        name="golden",
        marker="golden",
        name_pattern=r"^test_[a-z0-9_]+_golden\.lua$",
        require_exactly_one=False,
        validate_against_known_api=False,
        require_min_markers=0,
    ),
    "library": CategoryRule(
        name="library",
        marker="library",
        name_pattern=r"^test_[a-z0-9_]+_library\.lua$",
        require_exactly_one=False,
        validate_against_known_api=False,
    ),
    "config": CategoryRule(
        name="config",
        marker="covers",
        name_pattern=r"^test_[a-z0-9_]+(?:_config|_runtime_config)\.lua$",
        require_exactly_one=False,
        validate_against_known_api=True,
        require_min_markers=0,
    ),
}


_IT_OPEN_RE = re.compile(r"\bit\s*\(")
_MARKER_RE = re.compile(r"^\s*--\s*@(?P<name>\w+)\s+(?P<ref>[^\s].*?)\s*$")
_LUREK_REF_RE = re.compile(r"\blurek\.[a-z_]\w*\.[A-Za-z_]\w*\b")
_FUNCTION_ASSIGN_RE = re.compile(
    r"\blocal\s+(?P<var>[a-z_][A-Za-z0-9_]*)\s*=\s*(?P<api>lurek\.[a-z_]\w*\.[A-Za-z_]\w*)\s*\("
)
_METHOD_CALL_RE = re.compile(r"\b(?P<var>[a-z_][A-Za-z0-9_]*)\s*:\s*(?P<method>[A-Za-z_]\w*)\s*\(")


def load_api() -> List[ApiEntry]:
    try:
        data = json.loads(API_JSON.read_text(encoding="utf-8"))
    except FileNotFoundError:
        sys.exit(f"[ERROR] API JSON not found: {API_JSON}\nRun: python tools/docs/gen_lua_api_data.py first.")
    except json.JSONDecodeError as exc:
        sys.exit(f"[ERROR] JSON parse error in {API_JSON}: {exc}")

    entries: List[ApiEntry] = []
    modules = data["lua_api"]["modules"]
    for mod_name, mod in modules.items():
        for fn in mod.get("functions") or []:
            entries.append(
                ApiEntry(
                    module=mod_name,
                    lua_name=fn["lua_name"],
                    name=fn["name"],
                    is_method=False,
                    owner_type="",
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
                    )
                )
    return entries


def build_return_type_map(entries: List[ApiEntry]) -> dict[str, str]:
    try:
        data = json.loads(API_JSON.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return {}

    result: dict[str, str] = {}
    modules = data["lua_api"]["modules"]
    for _mod_name, mod in modules.items():
        for fn in mod.get("functions") or []:
            lua_name = fn.get("lua_name")
            inferred = fn.get("inferred_return") or fn.get("returns_doc") or ""
            if lua_name and isinstance(inferred, str):
                clean = inferred.strip().rstrip("?")
                if clean.startswith("L"):
                    result[lua_name] = clean
        for cls_name, cls in (mod.get("classes") or {}).items():
            for meth in cls.get("methods") or []:
                lua_name = meth.get("lua_name")
                inferred = meth.get("inferred_return") or meth.get("returns_doc") or ""
                if lua_name and isinstance(inferred, str):
                    clean = inferred.strip().rstrip("?")
                    if clean.startswith("L"):
                        result[lua_name] = clean
    return result


def _line_number_at(content: str, pos: int) -> int:
    return content.count("\n", 0, pos) + 1


def parse_it_blocks(content: str) -> List[ItBlock]:
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


def collect_preceding_markers(lines: List[str], it_line: int) -> List[tuple[str, str]]:
    markers: List[tuple[str, str]] = []
    cursor = it_line - 2
    while cursor >= 0:
        stripped = lines[cursor].strip()
        if not stripped:
            cursor -= 1
            continue
        match = _MARKER_RE.match(lines[cursor])
        if not match:
            break
        markers.append((match.group("name"), match.group("ref").strip().rstrip(".,;")))
        cursor -= 1
    markers.reverse()
    return markers


def strip_lua_comments_and_strings(code: str) -> str:
    lines: List[str] = []
    for raw_line in code.splitlines():
        line = raw_line
        comment_pos = line.find("--")
        if comment_pos != -1:
            line = line[:comment_pos]
        line = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', '""', line)
        line = re.sub(r"'[^'\\]*(?:\\.[^'\\]*)*'", "''", line)
        lines.append(line)
    return "\n".join(lines)


def heuristic_api_refs(body: str, return_types: dict[str, str], known_apis: Set[str]) -> Set[str]:
    code = strip_lua_comments_and_strings(body)
    refs: Set[str] = set(_LUREK_REF_RE.findall(code))

    var_types: dict[str, str] = {}
    for match in _FUNCTION_ASSIGN_RE.finditer(code):
        api_name = match.group("api")
        ltype = return_types.get(api_name)
        if ltype:
            var_types[match.group("var")] = ltype

    for match in _METHOD_CALL_RE.finditer(code):
        ltype = var_types.get(match.group("var"))
        if not ltype:
            continue
        candidate = f"{ltype}:{match.group('method')}"
        if candidate in known_apis:
            refs.add(candidate)

    return {ref for ref in refs if ref in known_apis}


def iter_test_files(path_filter: Optional[str], category_filter: Optional[str]) -> Iterable[Path]:
    if path_filter:
        target = (ROOT / path_filter).resolve()
        if target.is_file():
            yield target
            return
        if target.is_dir():
            yield from sorted(target.rglob("*.lua"))
            return
        raise FileNotFoundError(path_filter)

    if category_filter:
        category_dir = TESTS_ROOT / category_filter
        if category_dir.exists():
            yield from sorted(category_dir.glob("*.lua"))
        return

    for category in sorted(CATEGORY_RULES):
        category_dir = TESTS_ROOT / category
        if category_dir.exists():
            yield from sorted(category_dir.glob("*.lua"))


def detect_category(path: Path) -> Optional[str]:
    if path.parent == TESTS_ROOT:
        return None
    category = path.parent.name
    if category in CATEGORY_RULES:
        return category
    return None


def audit_file(
    path: Path,
    known_apis: Set[str],
    return_types: dict[str, str],
    heuristic_body_check: bool,
) -> tuple[List[Finding], List[MarkerOccurrence], dict[str, object]]:
    category = detect_category(path)
    if not category:
        return [], [], {}

    rule = CATEGORY_RULES[category]
    content = path.read_text(encoding="utf-8")
    lines = content.splitlines()
    blocks = parse_it_blocks(content)
    rel = path.relative_to(ROOT).as_posix()

    findings: List[Finding] = []
    occurrences: List[MarkerOccurrence] = []
    stats = {
        "file": rel,
        "category": category,
        "it_blocks": len(blocks),
        "marked_blocks": 0,
        "unique_markers": 0,
        "apis": set(),
    }

    if not re.match(rule.name_pattern, path.name):
        findings.append(
            Finding(
                file=rel,
                line=1,
                category=category,
                code="bad-file-name",
                message=f"Expected file name matching {rule.name_pattern!r}.",
            )
        )

    seen_primary: dict[str, List[tuple[int, str]]] = defaultdict(list)

    for block in blocks:
        markers = collect_preceding_markers(lines, block.line)
        primary_refs = [ref for name, ref in markers if name == rule.marker]
        marker_names = [name for name, _ in markers]
        used_apis = heuristic_api_refs(block.body, return_types, known_apis)

        if primary_refs:
            stats["marked_blocks"] += 1

        if not primary_refs and rule.require_min_markers > 0:
            findings.append(
                Finding(
                    file=rel,
                    line=block.line,
                    category=category,
                    code="missing-primary-marker",
                    message=f"{category} it() block must have a directly-adjacent -- @{rule.marker} marker.",
                    it_description=block.description,
                )
            )
        elif rule.require_exactly_one and len(primary_refs) != 1:
            findings.append(
                Finding(
                    file=rel,
                    line=block.line,
                    category=category,
                    code="multiple-primary-markers",
                    message=f"{category} it() block must have exactly one -- @{rule.marker} marker; found {len(primary_refs)}.",
                    it_description=block.description,
                )
            )

        for marker_name in marker_names:
            if marker_name == "covers" and category != "config":
                findings.append(
                    Finding(
                        file=rel,
                        line=block.line,
                        category=category,
                        code="foreign-covers-marker",
                        message=f"Do not use -- @covers inside {category} tests; use -- @{rule.marker}.",
                        it_description=block.description,
                    )
                )
                break

        for api_ref in primary_refs:
            stats["apis"].add(api_ref)
            is_allowed_security_pseudo = category == "security" and api_ref.startswith("sandbox.")
            if rule.validate_against_known_api and api_ref not in known_apis and not is_allowed_security_pseudo:
                findings.append(
                    Finding(
                        file=rel,
                        line=block.line,
                        category=category,
                        code="unknown-marker",
                        message=f"Marker '{api_ref}' does not match a known Lurek API symbol.",
                        it_description=block.description,
                        api_ref=api_ref,
                    )
                )
            occurrences.append(
                MarkerOccurrence(
                    api_ref=api_ref,
                    category=category,
                    file=rel,
                    line=block.line,
                    it_description=block.description,
                )
            )
            seen_primary[api_ref].append((block.line, block.description))

        if heuristic_body_check and rule.require_exactly_one and len(used_apis) > 1:
            findings.append(
                Finding(
                    file=rel,
                    line=block.line,
                    category=category,
                    code="multi-api-body",
                    message=f"{category} it() block heuristically references {len(used_apis)} known APIs; split it so one block owns one API.",
                    it_description=block.description,
                )
            )

        if category == "integration" and primary_refs:
            marker_set = {ref for ref in primary_refs if ref in known_apis}
            missing_markers = sorted(used_apis - marker_set)
            for api_ref in missing_markers:
                findings.append(
                    Finding(
                        file=rel,
                        line=block.line,
                        category=category,
                        code="unmarked-used-api",
                        message=f"Integration block uses '{api_ref}' but does not declare it with -- @integration.",
                        it_description=block.description,
                        api_ref=api_ref,
                    )
                )
    for api_ref, locs in seen_primary.items():
        if len(locs) > 1 and rule.require_exactly_one:
            first_line, _ = locs[0]
            for line, desc in locs[1:]:
                findings.append(
                    Finding(
                        file=rel,
                        line=line,
                        category=category,
                        code="duplicate-primary-marker",
                        message=f"{category} API '{api_ref}' is marked by multiple it() blocks in the same category.",
                        it_description=desc,
                        api_ref=api_ref,
                    )
                )
            findings.append(
                Finding(
                    file=rel,
                    line=first_line,
                    category=category,
                    code="duplicate-primary-marker",
                    message=f"{category} API '{api_ref}' is marked by multiple it() blocks in the same category.",
                    api_ref=api_ref,
                )
            )

    stats["unique_markers"] = len(stats["apis"])
    stats["apis"] = sorted(stats["apis"])
    return findings, occurrences, stats


def aggregate(
    findings: List[Finding],
    occurrences: List[MarkerOccurrence],
    file_stats: List[dict[str, object]],
) -> dict[str, object]:
    category_summary: dict[str, dict[str, object]] = {}
    file_finding_counts = Counter(f.file for f in findings)

    for category, rule in CATEGORY_RULES.items():
        stats = [item for item in file_stats if item.get("category") == category]
        cat_findings = [f for f in findings if f.category == category]
        category_summary[category] = {
            "files": len(stats),
            "it_blocks": sum(int(item["it_blocks"]) for item in stats),
            "marked_blocks": sum(int(item["marked_blocks"]) for item in stats),
            "unique_markers": len({api for item in stats for api in item.get("apis", [])}),
            "violations": len(cat_findings),
            "codes": dict(sorted(Counter(f.code for f in cat_findings).items())),
            "require_exactly_one": rule.require_exactly_one,
        }

    api_map: dict[str, list[dict[str, object]]] = defaultdict(list)
    for occ in sorted(occurrences, key=lambda item: (item.api_ref, item.category, item.file, item.line)):
        api_map[occ.api_ref].append(
            {
                "category": occ.category,
                "file": occ.file,
                "line": occ.line,
                "it_description": occ.it_description,
            }
        )

    top_files = [
        {"file": file, "violations": count}
        for file, count in file_finding_counts.most_common(20)
    ]

    return {
        "generated": datetime.now(timezone.utc).isoformat(),
        "summary": category_summary,
        "findings": [f.as_dict() for f in findings],
        "top_files": top_files,
        "api_map": dict(sorted(api_map.items())),
        "files": file_stats,
    }


def render_text(report: dict[str, object]) -> str:
    lines = [
        "Lurek2D non-unit Lua test audit",
        "",
        "Rules:",
        "- unit tests alone must reach 100% public API coverage",
        "- stress/security: 1 API = 1 marker = 1 it()",
        "- evidence: one it() may carry multiple @evidence markers for APIs that the artifact actually demonstrates",
        "- integration: markers should match the APIs actually used in the scenario",
        "",
        "Category summary:",
    ]

    summary: dict[str, dict[str, object]] = report["summary"]  # type: ignore[assignment]
    for category, stats in summary.items():
        lines.append(
            f"- {category}: files={stats['files']}, it()={stats['it_blocks']}, "
            f"marked={stats['marked_blocks']}, unique APIs={stats['unique_markers']}, "
            f"violations={stats['violations']}"
        )
        codes = stats.get("codes") or {}
        if codes:
            code_bits = ", ".join(f"{name}={count}" for name, count in codes.items())
            lines.append(f"  codes: {code_bits}")

    top_files = report.get("top_files") or []
    if top_files:
        lines.extend(["", "Top impacted files:"])
        for item in top_files:
            lines.append(f"- {item['file']}: {item['violations']} violation(s)")

    return "\n".join(lines)


def main() -> int:
    _configure_stdout_utf8()

    parser = argparse.ArgumentParser(description="Audit canonical non-unit Lua tests in tests/lua_reorg.")
    parser.add_argument("--json", action="store_true", help="Print the full report as JSON.")
    parser.add_argument("--path", metavar="PATH", help="Limit audit to a file or directory relative to repo root.")
    parser.add_argument(
        "--category",
        choices=sorted(CATEGORY_RULES),
        help="Limit audit to one non-unit test category.",
    )
    parser.add_argument(
        "--heuristic-body-check",
        action="store_true",
        help="Also flag strict-category blocks that heuristically reference multiple known APIs.",
    )
    args = parser.parse_args()

    entries = load_api()
    known_apis = {entry.lua_name for entry in entries}
    return_types = build_return_type_map(entries)

    findings: List[Finding] = []
    occurrences: List[MarkerOccurrence] = []
    file_stats: List[dict[str, object]] = []

    for path in iter_test_files(args.path, args.category):
        category = detect_category(path)
        if category is None:
            continue
        f, o, stats = audit_file(path, known_apis, return_types, args.heuristic_body_check)
        findings.extend(f)
        occurrences.extend(o)
        if stats:
            file_stats.append(stats)

    report = aggregate(findings, occurrences, file_stats)
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print(render_text(report))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
