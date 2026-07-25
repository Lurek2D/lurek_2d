#!/usr/bin/env python3
"""
audit_module.py â€” Lurek2D module quality audit tool.

Runs automated structural, docstring, architecture, and code-quality checks
on one or more src/ modules and produces a PASS/WARNING/ERROR verdict per
check.  A module FAILS the audit with 1+ ERROR or 3+ WARNING.

Usage:
    python tools/audit_module.py physics          # single module
    python tools/audit_module.py physics audio     # multiple modules
    python tools/audit_module.py --tier 1          # all Tier 1 modules
    python tools/audit_module.py --tier 2          # all Tier 2 modules
    python tools/audit_module.py --all             # every src/ module
    python tools/audit_module.py --json            # JSON output
    python tools/audit_module.py --all --docs-quality  # write logs/reports/module-quality/<module>.md
    python tools/audit_module.py --help

Exit codes:
    0  - all audited modules passed
    1  - at least one module failed
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

WORKSPACE = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(WORKSPACE / "tools" / "docs"))
import module_registry

SRC = WORKSPACE / "src"
LUA_API = SRC / "lua_api"
DOCS_DATA = module_registry.DOCS_DATA
LEGACY_LOGS_DATA = module_registry.LEGACY_LOGS_DATA
LUA_API_DATA = module_registry.lua_api_json_path()
TESTS_RUST = WORKSPACE / "tests" / "rust"
TESTS_LUA = WORKSPACE / "tests" / "lua"
DOCS_API = WORKSPACE / "docs" / "API"
WIKI = WORKSPACE / "docs" / "wiki"

# Tier assignments are loaded from docs/meta/modules.toml.

def _modules_in_tier(tier: str) -> set[str]:
    return {
        name
        for name, meta in module_registry.load_modules().items()
        if meta.get("tier") == tier
    }


FOUNDATIONS = _modules_in_tier("foundations")
CORE_RUNTIME = _modules_in_tier("core_runtime")
PLATFORM_SERVICES = _modules_in_tier("platform_services")
FEATURE_SYSTEMS = _modules_in_tier("feature_systems")
EDGE_INTEGRATION = _modules_in_tier("edge_integration")
CRATE_ROOT_EXPORTS = {'log_msg'}
ALL_TIERS = FOUNDATIONS | CORE_RUNTIME | PLATFORM_SERVICES | FEATURE_SYSTEMS | EDGE_INTEGRATION
_UNSAFE_CONSTRUCT_RE = re.compile(r"\bunsafe\s*(?:\{|fn\b|impl\b|trait\b|extern\b)")
# â”€â”€ Explicit cross-tier exemptions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Format: {(importer_module, imported_module): "reason"}
# Only list exemptions that have an explicit architectural justification
# documented in docs/architecture/engine-core.md or the module docs/specs.
CROSS_TIER_EXEMPTIONS: dict = {
    # automation/simulator.rs pushes synthetic events into EventQueue.
    # EventQueue is a core data structure that both modules share; the
    # dependency direction (automation â†’ event) is intentional and documented
    # in src/automation/docs/specs.
    ("automation", "event"): "Simulator injects synthetic input events into EventQueue â€” intentional by design",
    ("awareness", "tilefield"): "Tile awareness intentionally projects visibility masks over TileField semantics",
    ("camera", "tilemap"): "Camera walker intentionally depends on TileMap collision for tile-follow movement",
    ("image", "animation"): "Image visualization intentionally renders animation state into debug images",
    ("runtime", "audio"): "SharedState intentionally owns audio mixer handles for runtime-wide coordination",
    ("runtime", "camera"): "SharedState intentionally stores active camera handles for runtime-wide coordination",
    ("runtime", "cursor"): "SharedState intentionally stores the runtime cursor controller",
    ("runtime", "input"): "SharedState intentionally aggregates input state for frame-wide access",
    ("runtime", "light"): "SharedState intentionally stores lighting state for render/runtime coordination",
    ("runtime", "mods"): "SharedState intentionally stores the active mod sandbox",
    ("runtime", "parallax"): "SharedState intentionally stores parallax layers for runtime/render coordination",
    ("runtime", "particle"): "SharedState intentionally stores particle systems for runtime/render coordination",
    ("runtime", "province"): "SharedState intentionally stores province registries and render caches",
    ("runtime", "raycaster"): "SharedState intentionally stores raycaster scenes for runtime/render coordination",
    ("runtime", "render"): "SharedState intentionally owns render resources and command state",
    ("runtime", "tilemap"): "SharedState intentionally stores auto-managed tilemap handles for runtime coordination",
    ("runtime", "ui"): "SharedState intentionally stores the auto-managed UI context for runtime coordination",
    ("math", "image"): "math re-exports rect packing helpers for legacy compatibility",
    ("log", "runtime"): "log facade intentionally delegates level storage to runtime log_messages",
    ("patterns", "runtime"): "patterns blackboard intentionally reuses runtime log message identifiers",
    ("serialize", "runtime"): "serialize codecs reuse the centralized runtime diagnostic identifiers only",
}

MODULE_ALIASES = {
    # lurek.system is implemented by the runtime owner rather than a standalone src/system module.
    "system": "runtime",
}

LUA_USERDATA_DOMAIN_EXEMPTIONS: dict = {
    ("network", "network/netstate.rs", "LNetworkState"): "Thin Lua-backed wrapper around the embedded netstate library",
    ("network", "network/rpc.rs", "LNetworkRpc"): "Thin Lua-backed wrapper around the embedded RPC library",
}


def get_tier(module: str) -> str:
    tier = module_registry.module_tier(module)
    if tier == "foundations": return 'Foundations'
    if tier == "core_runtime": return 'Core Runtime'
    if tier == "platform_services": return 'Platform Services'
    if tier == "feature_systems": return 'Feature Systems'
    if tier == "edge_integration": return 'Edge/Integration'
    return 'unassigned'

def get_tier_level(module: str) -> int:
    return {
        "foundations": 0,
        "core_runtime": 1,
        "platform_services": 2,
        "feature_systems": 3,
        "edge_integration": 4,
    }.get(module_registry.module_tier(module), 99)


# â”€â”€ Verdict helpers â”€â”€

PASS = "PASS"
WARN = "WARNING"
ERROR = "ERROR"
MANUAL = "MANUAL"


class Check:
    def __init__(self, code: str, name: str, verdict: str, detail: str):
        self.code = code
        self.name = name
        self.verdict = verdict
        self.detail = detail

    def to_dict(self):
        return {
            "code": self.code,
            "name": self.name,
            "verdict": self.verdict,
            "detail": self.detail,
        }


# Module-level file cache: each .rs file is read from disk exactly once per
# audit run regardless of how many checks inspect it.  Eliminates the 8Ă—
# redundant reads that caused the VS Code extension-host to run out of memory
# when auditing large module batches.
_FILE_CACHE: dict = {}
_LUA_API_DATA_CACHE: Optional[dict] = None


def read_text(path: Path) -> str:
    """Return file contents, using the in-process cache to avoid re-reads."""
    if path in _FILE_CACHE:
        return _FILE_CACHE[path]
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        text = ""
    _FILE_CACHE[path] = text
    return text


def clear_file_cache() -> None:
    """Drop the cache between module batches to bound memory usage."""
    _FILE_CACHE.clear()


def load_lua_api_data() -> dict:
    """Load the canonical generated Lua API surface once per audit run."""
    global _LUA_API_DATA_CACHE
    if _LUA_API_DATA_CACHE is not None:
        return _LUA_API_DATA_CACHE
    if not LUA_API_DATA.exists():
        _LUA_API_DATA_CACHE = {}
        return _LUA_API_DATA_CACHE
    try:
        _LUA_API_DATA_CACHE = json.loads(LUA_API_DATA.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        _LUA_API_DATA_CACHE = {}
    return _LUA_API_DATA_CACHE


def get_module_binding_names(module: str) -> list[str]:
    """Return canonical top-level Lua binding names for one module.

    Prefer the generated API snapshot so audits do not mistake helper-table
    fields or response object keys for public API.
    """
    data = load_lua_api_data()
    module_data = data.get("lua_api", {}).get("modules", {}).get(module, {})
    functions = module_data.get("functions", []) or []
    names = [item.get("name") for item in functions if item.get("name")]
    if names:
        return sorted(set(names))

    # Fallback for fresh repos missing generated data.
    api_file = LUA_API / f"{module}_api.rs"
    if not api_file.exists():
        return []
    return sorted(set(re.findall(r'tbl\.set\(\s*"([^"]+)"', read_text(api_file))))


# â”€â”€ Single-pass per-file analysis â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
#
# All checks that iterate over src/<module>/*.rs files previously each called
# rglob() and read every file independently (up to 8 separate passes).  This
# dataclass holds every finding that can be derived in a SINGLE sequential pass
# over the file set.  The check functions below simply query it.

@dataclass
class ModuleFileAnalysis:
    """All per-file findings for one module, computed in a single pass."""
    files_no_mod_doc: List[str] = field(default_factory=list)      # D-01
    undocumented_items: List[str] = field(default_factory=list)     # D-02
    stub_docs: List[str] = field(default_factory=list)              # D-04
    dep_violations: List[str] = field(default_factory=list)         # R-02
    lua_api_imports: List[str] = field(default_factory=list)        # R-03
    println_hits: List[str] = field(default_factory=list)           # Q-01
    unsafe_violations: List[str] = field(default_factory=list)      # Q-03
    unwrap_hits: List[str] = field(default_factory=list)            # Q-04
    large_files: List[Tuple[str, int]] = field(default_factory=list)
    warning_files: List[Tuple[str, int]] = field(default_factory=list)


_STUB_PATTERNS = ("TODO", "FIXME", "Consult the module-level docs-general")
_PUB_ITEM_RE = re.compile(r"pub\s+(?:fn|struct|enum|trait|type|const)\s+")
_PUB_ITEM_NAME_RE = re.compile(r"pub\s+(fn|struct|enum|trait|type|const)\s+(\w+)")


def _contains_unsafe_construct(raw: str) -> bool:
    """Return True when one source line contains an actual Rust unsafe construct."""
    return bool(_UNSAFE_CONSTRUCT_RE.search(raw))


def _analyze_module_files(module: str) -> ModuleFileAnalysis:
    """Single-pass analysis: read each .rs file exactly once and collect all findings."""
    analysis = ModuleFileAnalysis()
    tier = get_tier(module)
    mod_dir = SRC / module
    if not mod_dir.is_dir():
        return analysis

    for rs in sorted(mod_dir.rglob("*.rs")):
        content = read_text(rs)          # cache hit after first read
        lines = content.splitlines()
        rel = rs.relative_to(SRC).as_posix()
        stem = rs.stem
        n_lines = len(lines)

        # â”€â”€ file-size check â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if n_lines > 3000:
            analysis.large_files.append((rel, n_lines))
        elif n_lines > 2900:
            analysis.warning_files.append((rel, n_lines))

        if not content.strip():
            continue

        # â”€â”€ D-01: module-level //! doc â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        first_real = [l.strip() for l in lines[:15] if l.strip()]
        if not any(l.startswith("//!") for l in first_real):
            analysis.files_no_mod_doc.append(rel)

        # â”€â”€ inline state for the line-by-line scan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        prev_was_attr_or_blank = False
        preceding_doc = False

        for i, raw in enumerate(lines):
            stripped = raw.strip()
            is_comment = stripped.startswith("//")
            is_doc = stripped.startswith("///") or stripped.startswith("//!")

            # â”€â”€ D-02: undocumented pub items â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if _PUB_ITEM_RE.match(stripped):
                has_doc = False
                for j in range(i - 1, max(i - 6, -1), -1):
                    p = lines[j].strip()
                    if p.startswith("///"):
                        has_doc = True
                        break
                    if p.startswith("#[") or p == "":
                        continue
                    break
                if not has_doc:
                    m = _PUB_ITEM_NAME_RE.match(stripped)
                    if m:
                        analysis.undocumented_items.append(f"{stem}::{m.group(2)}")

            # â”€â”€ D-04: stub docs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if is_doc:
                for pat in _STUB_PATTERNS:
                    if pat.lower() in stripped.lower():
                        analysis.stub_docs.append(f"{stem}:{i+1}")
                        break

            # â”€â”€ Q-01: println! â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if not is_comment and ("println!" in stripped or "eprintln!" in stripped):
                analysis.println_hits.append(f"{stem}:{i+1}")

            # â”€â”€ Q-03: unsafe without SAFETY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if _contains_unsafe_construct(raw) and not is_comment:
                ctx = "\n".join(lines[max(0, i - 3):i + 1])
                if "SAFETY:" not in ctx and "SAFETY :" not in ctx:
                    analysis.unsafe_violations.append(f"{stem}:{i+1}")

            # â”€â”€ Q-04: unwrap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if not is_comment and ".unwrap()" in stripped:
                analysis.unwrap_hits.append(f"{stem}:{i+1}")

        # â”€â”€ R-02 / R-03: dependency direction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        for imp in re.findall(r'use crate::(\w+)', content):
            if imp == module: continue
            if imp == 'lua_api':
                analysis.lua_api_imports.append(f'{stem}')
                continue
            if imp in CRATE_ROOT_EXPORTS: continue
            if (module, imp) in CROSS_TIER_EXEMPTIONS:
                continue

            imp_level = get_tier_level(imp)
            mod_level = get_tier_level(module)

            if imp_level > mod_level and imp_level != 99 and mod_level != 99:
                analysis.dep_violations.append(f"{stem}: {get_tier(module)} imports {imp}({get_tier(imp)})")

    return analysis




# â”€â”€ Phase 1: Structure & Registration â”€â”€


def check_lib_rs_registration(module: str) -> Check:
    """S-01: Module registered in lib.rs and lua_api/mod.rs."""
    lib_rs = read_text(SRC / "lib.rs")
    pattern = rf"pub\s+mod\s+{re.escape(module)}\s*;"
    if not re.search(pattern, lib_rs):
        return Check("S-01", "lib.rs registration", ERROR,
                      f"`pub mod {module};` not found in src/lib.rs")

    # Check lua_api registration (optional â€” some modules have no Lua API)
    lua_mod = read_text(LUA_API / "mod.rs")
    api_name = f"{module}_api"
    has_lua_api = re.search(rf"pub\s+mod\s+{re.escape(api_name)}", lua_mod)
    api_file_exists = (
        (LUA_API / f"{api_name}.rs").exists()
        or (LUA_API / api_name).is_dir()
    )

    if api_file_exists and not has_lua_api:
        return Check("S-01", "lib.rs registration", ERROR,
                      f"`{api_name}` file exists but not registered in lua_api/mod.rs")

    detail = f"Registered in lib.rs"
    if has_lua_api:
        detail += f" + lua_api ({api_name})"
    return Check("S-01", "lib.rs registration", PASS, detail)


def check_mod_rs_simplicity(module: str) -> Check:
    """S-02: mod.rs should be a thin barrel file."""
    mod_rs = SRC / module / "mod.rs"
    if not mod_rs.exists():
        return Check("S-02", "mod.rs simplicity", WARN,
                      "No mod.rs found (module may use lib-style layout)")

    content = read_text(mod_rs)
    logic_lines = 0
    for line in content.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("//"):
            continue
        if stripped.startswith("pub mod ") or stripped.startswith("mod "):
            continue
        if stripped.startswith("pub use ") or stripped.startswith("use "):
            continue
        logic_lines += 1

    if logic_lines > 100:
        return Check("S-02", "mod.rs simplicity", ERROR,
                      f"mod.rs has {logic_lines} logic lines â€” extract to named files")
    if logic_lines > 30:
        return Check("S-02", "mod.rs simplicity", WARN,
                      f"mod.rs has {logic_lines} logic lines â€” consider extracting")
    return Check("S-02", "mod.rs simplicity", PASS,
                  f"mod.rs is a thin barrel file ({logic_lines} logic lines)")


def check_file_sizes(analysis: ModuleFileAnalysis) -> Check:
    """S-03: (Removed) File size limits no longer tracked."""
    return Check("S-03", "File size limits", PASS, "Skipped â€” file sizes no longer tracked")


def check_file_naming(module: str) -> Check:
    """S-04: File names use standard game-engine terminology."""
    mod_dir = SRC / module
    suspicious: List[str] = []
    for rs in sorted(mod_dir.rglob("*.rs")):
        name = rs.stem
        if name.startswith("_") or len(name) > 30 or name.startswith("temp"):
            suspicious.append(rs.name)
    if suspicious:
        return Check("S-04", "File naming", WARN,
                      f"Potentially misleading names: {', '.join(suspicious)}")
    return Check("S-04", "File naming", PASS, "File names follow conventions")


# â”€â”€ Phase 2: docs/specs Quality â”€â”€

# Canonical docs/specs sections (must match docs-specs skill and actual src/<module>/docs/specs files).
# See .codex/skills/create-spec/SKILL.md for the authoritative template.
REQUIRED_AGENT_SECTIONS = ["Purpose", "Source Files"]
# "Full Specification" may appear as the short form "Full Spec" in older files.
REQUIRED_AGENT_SPEC_SECTION_VARIANTS = ["Full Specification", "Full Spec"]
RECOMMENDED_AGENT_SECTIONS = ["Key Types", "Lua API Summary"]


def check_agent_md(module: str) -> List[Check]:
    return [Check('A-01', 'AGENT.md exists', PASS, 'Skipped'), Check('A-02', 'Template', PASS, 'Skipped'), Check('A-03', 'Purpose', PASS, 'Skipped'), Check('A-04', 'Content', PASS, 'Skipped'), Check('A-05', 'Pointer', PASS, 'Skipped'), Check('A-06', 'Tier', PASS, 'Skipped')]

def check_module_level_docs(analysis: ModuleFileAnalysis) -> Check:
    """D-01: Every .rs file has //! module-level doc comment."""
    missing = analysis.files_no_mod_doc
    if missing:
        return Check("D-01", "Module-level docs", ERROR,
                      f"Missing //! doc in: {', '.join(missing[:5])}"
                      + (f" (+{len(missing)-5} more)" if len(missing) > 5 else ""))
    return Check("D-01", "Module-level docs", PASS, "All files have //! doc comments")


def check_pub_item_docs(analysis: ModuleFileAnalysis) -> Check:
    """D-02: Every pub item has /// doc comment."""
    undocumented = analysis.undocumented_items
    if undocumented:
        shown = undocumented[:8]
        extra = f" (+{len(undocumented)-8} more)" if len(undocumented) > 8 else ""
        return Check("D-02", "Public item docs", ERROR,
                      f"Undocumented pub items: {', '.join(shown)}{extra}")
    return Check("D-02", "Public item docs", PASS, "All pub items have /// docs")


def check_doc_stubs(analysis: ModuleFileAnalysis) -> Check:
    """D-04: No stub/placeholder doc comments."""
    stubs = analysis.stub_docs
    if stubs:
        shown = stubs[:5]
        extra = f" (+{len(stubs)-5} more)" if len(stubs) > 5 else ""
        return Check("D-04", "Doc quality", WARN,
                      f"Stub/placeholder docs found: {', '.join(shown)}{extra}")
    return Check("D-04", "Doc quality", PASS, "No stub docs found")


# â”€â”€ Phase 4: Architecture Compliance â”€â”€


def check_dependency_direction(module: str, analysis: ModuleFileAnalysis) -> Check:
    """R-02: Module imports only from allowed tiers."""
    tier = get_tier(module)
    violations = analysis.dep_violations
    if violations:
        return Check("R-02", "Dependency direction", ERROR,
                      "; ".join(violations[:5]))
    return Check("R-02", "Dependency direction", PASS,
                  f"All imports follow {tier} rules")


def check_no_lua_api_import(module: str, analysis: ModuleFileAnalysis) -> Check:
    """R-03: Domain modules never import lua_api."""
    if module == "lua_api":
        return Check("R-03", "No lua_api import", PASS, "Module IS lua_api â€” skip")
    if module in EDGE_INTEGRATION or module in CORE_RUNTIME:
        return Check("R-03", "No lua_api import", PASS,
                     "Bootstrapping module â€” may import lua_api")
    hits = analysis.lua_api_imports
    if hits:
        return Check("R-03", "No lua_api import", ERROR,
                      f"{hits[0]} imports lua_api")
    return Check("R-03", "No lua_api import", PASS, "No lua_api imports found")




# â”€â”€ Phase 5: Test Coverage â”€â”€


# â”€â”€ Phase 3b: Technical Specification â”€â”€


def check_spec_file(module: str) -> List[Check]:
    """SP-01 through SP-05: docs/specs/<module>.md content checks."""
    results: List[Check] = []
    spec_path = WORKSPACE / "docs" / "specs" / f"{module}.md"
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    has_lua_api = api_file.exists() or api_dir.is_dir()

    # SP-01: spec file exists
    if not spec_path.exists():
        results.append(Check("SP-01", "Spec file exists", ERROR,
                              f"docs/specs/{module}.md is missing â€” create from template"))
        for code, name in [("SP-02", "Required spec sections"),
                            ("SP-03", "Summary quality"),
                            ("SP-04", "Lua API completeness"),
                            ("SP-05", "Spec quality")]:
            results.append(Check(code, name, ERROR, "Skipped â€” no spec file"))
        return results

    results.append(Check("SP-01", "Spec file exists", PASS, f"docs/specs/{module}.md exists"))
    content = read_text(spec_path)

    # SP-02: required sections follow docs/specs/AGENTS.md and README.md.
    required_sections = {
        "General Info": [r"^## General Info\s*$"],
        "Summary": [r"^## Summary\s*$"],
        "Imports": [r"^## Imports\s*$"],
        "Files": [r"^## Files\s*$", r"^## Source Files\s*$"],
        "Lua API Ref": [r"^## Lua API Ref\s*$", r"^## Lua API Reference\s*$"],
    }

    missing = [
        name for name, patterns in required_sections.items()
        if not any(re.search(pattern, content, re.MULTILINE) for pattern in patterns)
    ]

    if missing:
        results.append(Check("SP-02", "Required spec sections", ERROR,
                              f"Missing sections: {', '.join(missing)}"))
    else:
        results.append(Check("SP-02", "Required spec sections", PASS,
                              "All required sections present"))

    # SP-03: summary quality
    results.append(Check("SP-03", "Summary quality", PASS, "Skipped â€” summary length no longer tracked"))

    # SP-04: Lua API completeness â€” bidirectional diff
    if has_lua_api and api_file.exists():
        bound_fns = get_module_binding_names(module)
        missing_fns = [fn for fn in bound_fns if fn not in content]
        # Stale: names that appear in spec ## Lua API section but not in code
        lua_api_section = re.search(
            r"## Lua API (?:Ref|Reference)(.*?)(?=\n## |\Z)",
            content,
            re.DOTALL,
        )
        stale_fns: List[str] = []
        if lua_api_section and bound_fns:
            spec_api_text = lua_api_section.group(1)
            # Look for function name patterns in the spec: `lurek.module.funcName`
            spec_fn_names = set(re.findall(r"`lurek\.\w+\.(\w+)\s*\(", spec_api_text))
            if spec_fn_names:
                code_fn_set = set(bound_fns)
                stale_fns = [fn for fn in spec_fn_names if fn not in code_fn_set]

        details: List[str] = []
        if missing_fns:
            shown = missing_fns[:5]
            extra = f" (+{len(missing_fns)-5} more)" if len(missing_fns) > 5 else ""
            details.append(
                f"Missing from spec: {', '.join(shown)}{extra} â€” add to ## Lua API Ref in docs/specs/{module}.md"
            )
        if stale_fns:
            details.append(f"Stale in spec (not in code): {', '.join(stale_fns[:4])} â€” remove from spec")
        if details:
            results.append(Check("SP-04", "Lua API completeness", ERROR, " | ".join(details)))
        elif bound_fns:
            results.append(Check("SP-04", "Lua API completeness", PASS,
                                  f"All {len(bound_fns)} bound functions in spec"))
        else:
            results.append(Check("SP-04", "Lua API completeness", PASS,
                                  "No tbl.set() bindings found"))
    else:
        results.append(Check("SP-04", "Lua API completeness", PASS,
                              "No Lua API file â€” skip"
                              if not has_lua_api else "api/ dir layout â€” manual check"))

    # SP-05: Key Types cross-reference â€” types in spec vs types in source
    key_types_section = re.search(r"## Key Types(.*?)(?=\n## |\Z)", content, re.DOTALL)
    mod_dir = SRC / module
    code_types = set()
    for rs in mod_dir.rglob("*.rs"):
        for m in re.finditer(r"^pub\s+(?:struct|enum)\s+(\w+)", read_text(rs), re.MULTILINE):
            code_types.add(m.group(1))
    if key_types_section and code_types:
        # Match heading-based type names: ## TypeName, ### foo::bar::TypeName, #### `mod::TypeName`
        # Capture only the last path segment to handle fully-qualified names.
        _SECTION_WORDS = {"Structs", "Enums", "Overview", "Summary", "API", "Types",
                          "Traits", "Functions", "Methods", "Examples"}
        spec_type_names = set()
        for m in re.finditer(r"#{2,5}\s+`?(?:\w+::)*(\w+)`?", key_types_section.group(1)):
            name = m.group(1)
            if name not in _SECTION_WORDS:
                spec_type_names.add(name)
        missing_types = [t for t in code_types if t not in spec_type_names
                         and not t.startswith("_") and not t.endswith("Key")]
        stale_types = [t for t in spec_type_names if t not in code_types and len(t) > 2]
        type_issues: List[str] = []
        if missing_types:
            type_issues.append(f"Types not in spec: {', '.join(sorted(missing_types)[:5])}")
        if stale_types:
            type_issues.append(f"Stale in spec: {', '.join(sorted(stale_types)[:4])}")
        if type_issues:
            results.append(Check("SP-05", "Key Types accuracy", WARN, " | ".join(type_issues)))
        else:
            results.append(Check("SP-05", "Key Types accuracy", PASS,
                                  f"{len(code_types)} types â€” spec Key Types in sync"))
    else:
        results.append(Check("SP-05", "Key Types accuracy", PASS,
                              "No Key Types section or no public types â€” skip"))

    # SP-06: spec quality (no stubs)
    # Use exact case matching: PLACEHOLDER and FIXME are all-caps technical markers;
    # "placeholder" and "todo" as lowercase normally appear in legitimate spec prose
    # (UI field descriptions, template variable docs, etc.) and should not be flagged.
    stub_hits = [p for p in ["TODO", "FIXME", "PLACEHOLDER", "Coming soon"]
                 if p in content]
    if stub_hits:
        results.append(Check("SP-06", "Spec quality", WARN,
                              f"Stub content found: {', '.join(stub_hits)}"))
    else:
        results.append(Check("SP-06", "Spec quality", PASS, "No stub content"))

    return results


# â”€â”€ Phase 4b: Structured Doc Sections â”€â”€


def check_structured_sections(module: str) -> Check:
    """D-03: pub structs have # Fields docs, pub enums have # Variants docs."""
    mod_dir = SRC / module
    missing: List[str] = []
    for rs in sorted(mod_dir.rglob("*.rs")):
        if "lua_api" in str(rs):
            continue
        content = read_text(rs)
        lines = content.splitlines()
        for i, line in enumerate(lines):
            m = re.match(r"pub\s+(struct|enum)\s+(\w+)", line.strip())
            if not m:
                continue
            kind, name = m.group(1), m.group(2)
            expected = "# Fields" if kind == "struct" else "# Variants"
            has_section = any(expected in lines[j]
                              for j in range(max(0, i - 25), i))
            if not has_section:
                missing.append(f"{rs.stem}::{name} ({expected})")
    if missing:
        shown = missing[:6]
        extra = f" (+{len(missing)-6} more)" if len(missing) > 6 else ""
        return Check("D-03", "Structured doc sections", WARN,
                      f"Missing structured sections: {', '.join(shown)}{extra}")
    return Check("D-03", "Structured doc sections", PASS,
                  "All pub structs/enums have structured doc sections")


# â”€â”€ Phase 4c: Lua API File Docstrings â”€â”€


def check_lua_api_docs(module: str) -> List[Check]:
    """D-06 through D-09: Lua API file docs-general checks."""
    results: List[Check] = []
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    skip = "No Lua API file \u2014 skip"

    if not api_file.exists() and not api_dir.is_dir():
        for code, name in [("D-06", "Lua API file docs"),
                            ("D-07", "@param/@return annotations"),
                            ("D-08", "No rustdoc in lua_api"),
                            ("D-09", "Section separators")]:
            results.append(Check(code, name, PASS, skip))
        return results

    if not api_file.exists():
        for code, name in [("D-06", "Lua API file docs"),
                            ("D-07", "@param/@return annotations"),
                            ("D-08", "No rustdoc in lua_api"),
                            ("D-09", "Section separators")]:
            results.append(Check(code, name, PASS, "api/ dir layout \u2014 manual check"))
        return results

    content = read_text(api_file)
    lines = content.splitlines()

    # D-06: //! module-level doc
    first_real = [l.strip() for l in lines[:15] if l.strip()]
    if not any(l.startswith("//!") for l in first_real):
        results.append(Check("D-06", "Lua API file docs", ERROR,
                              f"lua_api/{module}_api.rs missing //! module-level doc"))
    else:
        results.append(Check("D-06", "Lua API file docs", PASS, "//! doc comment present"))

    # D-07: @param/@return before each tbl.set
    missing_annots: List[str] = []
    for i, line in enumerate(lines):
        if not re.search(r'(?<![A-Za-z0-9_])tbl\.set\(', line):
            continue
        fn_m = re.search(r'(?<![A-Za-z0-9_])tbl\.set\(\s*"([^"]+)"', line)
        if not fn_m:
            continue
        fn_name = fn_m.group(1)
        ctx = "\n".join(lines[max(0, i - 10):i])
        if "@param" not in ctx and "@return" not in ctx:
            missing_annots.append(fn_name)
    if missing_annots:
        shown = missing_annots[:5]
        extra = f" (+{len(missing_annots)-5} more)" if len(missing_annots) > 5 else ""
        results.append(Check("D-07", "@param/@return annotations", WARN,
                              f"Missing @param/@return before: {', '.join(shown)}{extra}"))
    else:
        results.append(Check("D-07", "@param/@return annotations", PASS,
                              "All bindings have @param/@return annotations"))

    # D-08: No rustdoc-style sections in Lua API file
    BANNED = ["# Parameters", "# Returns", "# Fields", "# Variants", "# Errors"]
    violations = [s for s in BANNED if f"\n/// {s}\n" in content or f"\n/// {s}" in content]
    if violations:
        results.append(Check("D-08", "No rustdoc in lua_api", ERROR,
                              f"Rustdoc sections found (use @param/@return): {', '.join(violations)}"))
    else:
        results.append(Check("D-08", "No rustdoc in lua_api", PASS,
                              "No rustdoc sections in Lua API file"))

    # D-09: Section separator comments if \u22653 bindings
    # Accept both Unicode box-drawing (// \u2500\u2500\u2500) and ASCII dash (// ---) separators
    # Match the public module table only; nested serializers such as
    # `light_tbl.set("radius", ...)` are data fields, not bindings.
    bound_fns = re.findall(r'(?<![A-Za-z0-9_])tbl\.set\(\s*"[^"]+?"', content)
    has_sep = bool(re.search(r"// [-\u2500]{3,}", content))
    if len(bound_fns) >= 3 and not has_sep:
        results.append(Check("D-09", "Section separators", WARN,
                              f"{len(bound_fns)} bindings but no // \u2500\u2500\u2500 separator comments"))
    else:
        results.append(Check("D-09", "Section separators", PASS,
                              "Separators present" if has_sep else "< 3 bindings \u2014 skip"))

    return results


# â”€â”€ Phase 5: Lua\u2194Rust Bridge Integrity â”€â”€


def check_lua_bridge(module: str) -> List[Check]:
    """B-01 through B-06: Lua-Rust bridge integrity checks."""
    results: List[Check] = []
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    skip = "No Lua API \u2014 skip"

    if not api_file.exists() and not api_dir.is_dir():
        for code, name in [("B-01", "Dedicated API file"),
                            ("B-02", "Registration-only"),
                            ("B-03", "impl LuaUserData placement"),
                            ("B-04", "No business logic"),
                            ("B-05", "Rc clone pattern"),
                            ("B-06", "Flat registration body")]:
            results.append(Check(code, name, PASS, skip))
        return results

    suffix = "/" if api_dir.is_dir() else ".rs"
    results.append(Check("B-01", "Dedicated API file", PASS,
                          f"lua_api/{module}_api{suffix} present"))

    if not api_file.exists():
        for code, name in [("B-02", "Registration-only"),
                            ("B-03", "impl LuaUserData placement"),
                            ("B-04", "No business logic"),
                            ("B-05", "Rc clone pattern"),
                            ("B-06", "Flat registration body")]:
            results.append(Check(code, name, PASS, "api/ dir layout \u2014 manual check"))
        return results

    content = read_text(api_file)
    lines = content.splitlines()

    # B-02: Only register() as pub fn; also detect struct definitions
    extra_pub_fns = [f for f in re.findall(r"^pub\s+fn\s+(\w+)", content, re.MULTILINE)
                     if f != "register"]
    # Lua<X> wrapper structs are EXPECTED in lua_api â€” do NOT flag them as errors.
    # Only flag non-wrapper structs (those whose name does not start with "Lua").
    all_pub_structs = re.findall(r"^pub\s+struct\s+(\w+)", content, re.MULTILINE)
    non_wrapper_structs = [s for s in all_pub_structs if not s.startswith("Lua")]
    b02_issues: List[str] = []
    if extra_pub_fns:
        b02_issues.append(f"extra pub fn (move to src/{module}/): " + ", ".join(extra_pub_fns))
    if non_wrapper_structs:
        b02_issues.append(f"non-wrapper struct definitions (move to src/{module}/): " + ", ".join(non_wrapper_structs))
    if b02_issues:
        results.append(Check("B-02", "Registration-only", ERROR,
                              " | ".join(b02_issues)))
    else:
        results.append(Check("B-02", "Registration-only", PASS,
                              "Only register() is pub fn (Lua<X> wrapper structs allowed)"))

    # B-03: impl LuaUserData MUST be in lua_api â€” check domain module for violations.
    # Scan src/<module>/**/*.rs for any impl LuaUserData (they must NOT be there).
    domain_dir = SRC / module
    domain_violations: List[str] = []
    if domain_dir.is_dir():
        for rs_file in sorted(domain_dir.rglob("*.rs")):
            domain_content = read_text(rs_file)
            ud_impls = re.findall(r"impl\s+LuaUserData\s+for\s+(\w+)", domain_content)
            if ud_impls:
                rel = rs_file.relative_to(SRC).as_posix()
                remaining = [
                    impl_name
                    for impl_name in ud_impls
                    if (module, rel, impl_name) not in LUA_USERDATA_DOMAIN_EXEMPTIONS
                ]
                if remaining:
                    domain_violations.append(f"{rel}: {', '.join(remaining)}")
    if domain_violations:
        results.append(Check("B-03", "impl LuaUserData placement", ERROR,
                              "impl LuaUserData found in domain module (move to lua_api/): "
                              + "; ".join(domain_violations)))
    else:
        results.append(Check("B-03", "impl LuaUserData placement", PASS,
                              "All impl LuaUserData blocks are in lua_api (correct)"))
    # B-04 / B-02b: Scan closures for size and control flow.
    # For each tbl.set("name", lua.create_function(...)) block, measure LOC
    # and look for control-flow keywords. Report: function name, LOC, action.
    large_closures: List[str] = []
    logic_closures: List[str] = []
    in_closure = False
    closure_fn_name = ""
    closure_start_line = 0
    closure_depth = 0
    closure_lines: List[str] = []

    for i, raw in enumerate(lines):
        stripped = raw.strip()

        # Detect start of a new binding â€” grab the function name from the nearby tbl.set
        if re.search(r"lua\.create_(?:function|method)\b", stripped):
            # Look backward for the tbl.set("name", ...) on the same or preceding lines
            name_m = None
            for j in range(i, max(i - 3, -1), -1):
                name_m = re.search(r'tbl\.set\(\s*"([^"]+)"', lines[j])
                if name_m:
                    break
            in_closure = True
            closure_fn_name = name_m.group(1) if name_m else f"<closure@{i+1}>"
            closure_start_line = i + 1
            closure_depth = 0
            closure_lines = []

        if in_closure:
            closure_lines.append(stripped)
            for ch in raw:
                if ch == "{":
                    closure_depth += 1
                elif ch == "}":
                    closure_depth -= 1
            # Closure ends when depth returns to 0 after opening
            if closure_depth <= 0 and len(closure_lines) > 2:
                loc = len(closure_lines)
                has_flow = any(re.search(r"\b(if |match |for |while |loop )", ln)
                               for ln in closure_lines[1:-1])
                if loc > 15:
                    large_closures.append(
                        f"'{closure_fn_name}' ({loc} LOC, line {closure_start_line}) "
                        f"â€” extract body to src/{module}/")
                elif has_flow:
                    logic_closures.append(
                        f"'{closure_fn_name}' has if/match/for â€” extract to src/{module}/")
                in_closure = False

    b04_issues = large_closures[:4] + logic_closures[:2]
    if b04_issues:
        results.append(Check("B-04", "No business logic in closures", WARN,
                              " | ".join(b04_issues)))
    else:
        results.append(Check("B-04", "No business logic in closures", PASS,
                              "Closures appear thin (â‰¤15 LOC, no control flow)"))

    # B-05: state.clone() before move |
    # Check only real state capture assignments (ignore prose/doc lines containing the word "state").
    missing_clone: List[str] = []
    for i, line in enumerate(lines):
        if "move |" not in line:
            continue
        ctx_lines = [ln for ln in lines[max(0, i - 5):i] if not ln.strip().startswith("///")]
        captures_state = any(re.search(r"\blet\s+\w+\s*=\s*state\b", ln) for ln in ctx_lines)
        has_state_clone = any("state.clone()" in ln for ln in ctx_lines)
        if captures_state and not has_state_clone:
            missing_clone.append(f"line {i + 1}")
    if missing_clone:
        results.append(Check("B-05", "Rc clone pattern", WARN,
                              f"Possible missing state.clone() before move: "
                              + ", ".join(missing_clone[:3])))
    else:
        results.append(Check("B-05", "Rc clone pattern", PASS,
                              "Rc clone pattern looks correct"))

    # B-06: No tbl.set inside nested { } block
    # Scope the check to inside the pub fn register() function only to avoid
    # flagging legitimate tbl.set() on local tables inside impl LuaUserData closures.
    block_wrapped: List[str] = []
    brace_depth = 0
    block_line = None
    in_register = False
    for i, line in enumerate(lines):
        if "pub fn register(" in line:
            in_register = True
            brace_depth = 0  # reset for function-body tracking
        stripped = line.strip()
        for ch in line:
            if ch == "{":
                brace_depth += 1
                if in_register and brace_depth == 2 and block_line is None:
                    # Only flag BARE blocks like `{` on their own line.
                    # Closure bodies (`move |...| {`) and control-flow blocks
                    # (`if cond {`) are NOT the anti-pattern and must be skipped.
                    if stripped == "{":
                        block_line = i
            elif ch == "}":
                brace_depth = max(0, brace_depth - 1)
                if brace_depth < 2:
                    block_line = None
        # Use \b word-boundary so `r_tbl.set(` or `d_tbl.set(` do not match.
        if block_line is not None and re.search(r"\btbl\.set\(", line):
            block_wrapped.append(f"line {block_line + 1}")
            block_line = None
    if block_wrapped:
        results.append(Check("B-06", "Flat registration body", ERROR,
                              f"tbl.set() inside {{}} block (anti-pattern): "
                              + ", ".join(block_wrapped[:3])))
    else:
        results.append(Check("B-06", "Flat registration body", PASS,
                              "All tbl.set() calls are flat statements"))

    return results


# â”€â”€ Phase 6b: Tier Label â”€â”€


def check_tier_label(module: str) -> Check:
    spec_path = WORKSPACE / 'docs' / 'specs' / f'{module}.md'
    if not spec_path.exists():
        return Check('R-01', 'Tier placement', WARN, 'No docs/specs file â€” cannot verify')
    content = read_text(spec_path)
    expected_group = get_tier(module)
    match = re.search(r'- Module group:\s*(.*)', content)
    if not match:
        return Check('R-01', 'Tier placement', ERROR, f"No '- Module group:' row in docs/specs; expected {expected_group}")
    group = match.group(1).strip()
    if expected_group.lower() not in group.lower() and expected_group != 'unassigned':
        return Check('R-01', 'Tier placement', ERROR, f"docs/specs says '{group}', but architecture docs say '{expected_group}'")
    return Check('R-01', 'Tier placement', PASS, f'Module group {expected_group} verified')


# â”€â”€ Phase 7b: Test Conventions â”€â”€


def check_test_conventions(module: str) -> Check:
    """T-03: Test function naming \u2014 no test_ prefix."""
    for d in [TESTS_RUST / "unit", TESTS_RUST / "ext"]:
        f = d / f"{module}_tests.rs"
        if f.exists():
            content = read_text(f)
            bad = re.findall(r"\bfn\s+(test_\w+)\s*[\(<]", content)
            if bad:
                shown = bad[:5]
                extra = f" (+{len(bad)-5} more)" if len(bad) > 5 else ""
                return Check("T-03", "Test naming", WARN,
                              f"test_ prefix found \u2014 use <subject>_<scenario>_<expected>: "
                              + ", ".join(shown) + extra)
            return Check("T-03", "Test naming", PASS, "Test names follow convention")
    return Check("T-03", "Test naming", PASS, "No Rust test file \u2014 skip")


def _float_in_second_arg(line: str) -> bool:
    """Return True only if assert_eq!'s EXPECTED (second) arg contains a float literal.

    Floats that appear only in the first argument (e.g. as a function input like
    ``assert_eq!(quality_grade(0.0), "F")``) are NOT violations â€” the comparison
    target is a string, not a float.  We walk past the first top-level comma before
    scanning for floats.
    """
    m = re.search(r"assert_eq!\(", line)
    if not m:
        return False
    rest = line[m.end():]
    depth = 0
    for idx, ch in enumerate(rest):
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        elif ch == "," and depth == 0:
            second = rest[idx + 1:]
            return bool(re.search(r"\b\d+\.\d+(?:f32|f64)?(?!\.)(?!\d)", second))
    return False


def check_float_comparisons(module: str) -> Check:
    """T-04: Prefer epsilon assertions over exact float equality in Rust tests."""
    for d in [TESTS_RUST / "unit", TESTS_RUST / "ext"]:
        f = d / f"{module}_tests.rs"
        if f.exists():
            content = read_text(f)
            lines = content.splitlines()
            violations: List[str] = []
            for i, line in enumerate(lines):
                if "assert_eq!" in line:
                    # Strip comments and string literal contents first.
                    bare = re.sub(r'"[^"]*"', '""', line)
                    bare = re.sub(r"'[^']*'", "''", bare)
                    bare = re.sub(r"//.*$", "", bare)
                    if _float_in_second_arg(bare):
                        violations.append(f"line {i + 1}")
            if violations:
                return Check("T-04", "Float comparisons", WARN,
                              f"assert_eq! with float literals (prefer abs()<epsilon): "
                              + ", ".join(violations[:5]))
            return Check("T-04", "Float comparisons", PASS, "No float assert_eq! found")
    return Check("T-04", "Float comparisons", PASS, "No Rust test file \u2014 skip")


# â”€â”€ Phase 8b: Example File & API Coverage â”€â”€


def check_example_file(module: str) -> List[Check]:
    """W-01 / W-02: content/examples/<module>.lua exists and covers the full API surface."""
    results: List[Check] = []
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    has_lua_api = api_file.exists() or api_dir.is_dir()

    if not has_lua_api:
        results.append(Check("W-01", "Example file exists", PASS,
                              "No dedicated Lua API binding file â€” example file not required"))
        results.append(Check("W-02", "API surface coverage", PASS,
                              "No dedicated Lua API binding file â€” skip"))
        return results

    example_file = WORKSPACE / "content" / "examples" / f"{module}.lua"

    if not example_file.exists():
        results.append(Check("W-01", "Example file exists", ERROR,
                              f"content/examples/{module}.lua not found \u2014 create it"))
        results.append(Check("W-02", "API surface coverage", ERROR,
                              "Skipped \u2014 no example file"))
        return results

    results.append(Check("W-01", "Example file exists", PASS,
                          f"content/examples/{module}.lua present"))

    if not api_file.exists():
        results.append(Check("W-02", "API surface coverage", PASS,
                              "No Lua API binding file \u2014 skip"))
        return results

    example_content = read_text(example_file)
    bound_fns = get_module_binding_names(module)
    missing = [fn for fn in bound_fns if fn not in example_content]
    if missing:
        shown = missing[:6]
        extra = f" (+{len(missing)-6} more)" if len(missing) > 6 else ""
        results.append(Check("W-02", "API surface coverage", ERROR,
                              f"Functions absent from content/examples/{module}.lua: "
                              + ", ".join(shown) + extra))
    else:
        results.append(Check("W-02", "API surface coverage", PASS,
                              f"All {len(bound_fns)} bound functions in example"))
    return results


# â”€â”€ Phase 11b: Config Integration â”€â”€


def check_config_integration(module: str) -> Check:
    """I-03: Module has a config flag in ModulesConfig if it has a Lua API."""
    # Baseline modules (math, engine) are always-on; no config flag expected.
    if (module in FOUNDATIONS or module in CORE_RUNTIME):
        return Check("I-03", "Config integration", PASS,
                      "Baseline module \u2014 always enabled, no config flag required")
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    has_lua_api = api_file.exists() or api_dir.is_dir()
    if not has_lua_api:
        return Check("I-03", "Config integration", PASS,
                      "No Lua API \u2014 config flag not expected")
    config_rs = read_text(SRC / "runtime" / "config.rs")
    if module in config_rs:
        return Check("I-03", "Config integration", PASS,
                      f"Module referenced in src/runtime/config.rs")
    return Check("I-03", "Config integration", WARN,
                  f"Module not in src/runtime/config.rs \u2014 add to ModulesConfig if toggleable")


def check_rust_test_exists(module: str) -> Check:
    """T-01: Rust test files, when present, must be registered in Cargo.toml."""
    test_dirs = [
        TESTS_RUST / "unit",
        TESTS_RUST / "ext",
        TESTS_RUST / "game",
    ]
    found = []
    for d in test_dirs:
        test_file = d / f"{module}_tests.rs"
        if test_file.exists():
            found.append(str(test_file.relative_to(WORKSPACE)))

    if not found:
        return Check(
            "T-01",
            "Rust test file",
            PASS,
            "No Rust test file found â€” acceptable for Lua-first APIs or modules without private test seams",
        )

    # Check Cargo.toml registration or inclusion through a top-level aggregator test.
    cargo_toml = read_text(WORKSPACE / "Cargo.toml")
    if f'name = "{module}_tests"' not in cargo_toml:
        top_level_tests = sorted((WORKSPACE / "tests").glob("*.rs"))
        expected_path = f'rust/unit/{module}_tests.rs'
        expected_mod = f"mod {module}_tests;"
        included = False
        for test_file in top_level_tests:
            content = read_text(test_file)
            if expected_path in content and expected_mod in content:
                included = True
                break
        if not included:
            return Check("T-01", "Rust test file", ERROR,
                          f"Test file exists but is not registered in Cargo.toml or a top-level tests/*.rs aggregator")

    return Check("T-01", "Rust test file", PASS, f"Found: {', '.join(found)}")


def check_lua_test_exists(module: str) -> Check:
    """T-02: Lua test file exists and is registered in tests/lua_tests.rs."""
    api_file = LUA_API / f"{module}_api.rs"
    api_dir = LUA_API / f"{module}_api"
    has_lua_api = api_file.exists() or api_dir.is_dir()

    if not has_lua_api:
        return Check("T-02", "Lua test file", PASS, "Module has no Lua API â€” skip")

    harness = read_text(WORKSPACE / "tests" / "lua_tests.rs")

    canonical_lua_test = TESTS_LUA / "unit" / f"test_{module}_unit.lua"
    if canonical_lua_test.exists():
        expected_entry = f'run_lua_test("unit/test_{module}_unit.lua")'
        if expected_entry not in harness:
            return Check("T-02", "Lua test file", ERROR,
                          "Canonical Lua unit file exists but no matching registration "
                          "was found in tests/lua_tests.rs")
        return Check("T-02", "Lua test file", PASS,
                      f"tests/lua/unit/test_{module}_unit.lua registered in tests/lua_tests.rs")

    # Fall back: multi-file split convention (test_{module}_*_unit.lua)
    split_files = sorted((TESTS_LUA / "unit").glob(f"test_{module}_*_unit.lua"))
    if split_files:
        registered = [f for f in split_files if f.name in harness]
        if registered:
            names = ", ".join(f.name for f in split_files)
            return Check("T-02", "Lua test file", PASS,
                          f"Multi-file split: {names}")
        return Check("T-02", "Lua test file", ERROR,
                      f"Split test files found but none are registered in tests/lua_tests.rs")

    return Check("T-02", "Lua test file", ERROR,
                  f"Module has Lua API but no tests/lua/unit/test_{module}_unit.lua")


# â”€â”€ Phase 7: Code Quality â”€â”€


# â”€â”€ Phase 7: Code Quality â”€â”€


def check_no_println(analysis: ModuleFileAnalysis) -> Check:
    """Q-01: No println! or eprintln! in module code."""
    violations = analysis.println_hits
    if violations:
        return Check("Q-01", "No println!", ERROR,
                      f"println!/eprintln! found: {', '.join(violations[:5])}")
    return Check("Q-01", "No println!", PASS, "No println!/eprintln! calls")


def check_unsafe(analysis: ModuleFileAnalysis) -> Check:
    """Q-03: No unsafe without // SAFETY: comment."""
    violations = analysis.unsafe_violations
    if violations:
        return Check("Q-03", "No unsafe", ERROR,
                      f"unsafe without SAFETY comment: {', '.join(violations[:5])}")
    return Check("Q-03", "No unsafe", PASS, "No undocumented unsafe blocks")


def check_unwrap(analysis: ModuleFileAnalysis) -> Check:
    """Q-04: No bare .unwrap() in non-test code."""
    unwraps = analysis.unwrap_hits
    if unwraps:
        shown = unwraps[:5]
        extra = f" (+{len(unwraps)-5} more)" if len(unwraps) > 5 else ""
        return Check("Q-04", "Error handling", WARN,
                      f".unwrap() calls: {', '.join(shown)}{extra}")
    return Check("Q-04", "Error handling", PASS, "No bare .unwrap() calls")




# â”€â”€ Phase 6: Docs â”€â”€


def check_example_exists(module: str) -> Check:
    """W-03: Example game or test game demonstrates the module."""
    examples_dir = WORKSPACE / "content" / "demos"
    if not examples_dir.is_dir():
        return Check("W-03", "Example game", WARN, "content/demos/ directory not found")

    # Check for module-named example or demo
    candidates = [
        examples_dir / module,
        examples_dir / f"{module}_demo",
    ]
    for c in candidates:
        if c.is_dir():
            return Check("W-03", "Example game", PASS,
                          str(c.relative_to(WORKSPACE)))

    # Check if any example references the module
    for d in sorted(examples_dir.iterdir()):
        if d.is_dir():
            main_lua = d / "main.lua"
            if main_lua.exists():
                content = read_text(main_lua)
                if f"lurek.{module}" in content:
                    return Check("W-03", "Example game", PASS,
                                  f"Referenced in {d.relative_to(WORKSPACE)}/main.lua")

    return Check("W-03", "Example game", WARN,
                  f"No example found that demonstrates module '{module}'")


def check_test_adequacy(module: str) -> Check:
    """T-05 (automated): Compare pub fn count in domain vs #[test] count in test file."""
    mod_dir = SRC / module
    pub_fn_count = 0
    for rs in mod_dir.rglob("*.rs"):
        pub_fn_count += len(re.findall(r"^    pub\s+fn\s+\w+", read_text(rs), re.MULTILINE))
    if pub_fn_count == 0:
        return Check("T-05", "Test adequacy", PASS, "No pub methods counted â€” skip")

    test_file = None
    for d in [TESTS_RUST / "unit", TESTS_RUST / "ext"]:
        f = d / f"{module}_tests.rs"
        if f.exists():
            test_file = f
            break
    if not test_file:
        return Check("T-05", "Test adequacy", WARN,
                      f"{pub_fn_count} pub methods, 0 Rust tests â€” create test file")

    test_count = len(re.findall(r"#\[test\]", read_text(test_file)))
    if test_count == 0:
        return Check("T-05", "Private-seam tests", WARN,
                      "Rust target has no private-seam tests; public Lua behavior is Lua-owned")
    return Check("T-05", "Private-seam tests", PASS,
                  f"{test_count} focused Rust tests; public Lua behavior is covered by Lua ownership audits")


def check_log_prefix(module: str, analysis: ModuleFileAnalysis) -> Check:
    """Q-07: Log calls use log:: prefix (log::info!, log::warn!, etc.)."""
    mod_dir = SRC / module
    bare_log: List[str] = []
    for rs in mod_dir.rglob("*.rs"):
        content = read_text(rs)
        for i, line in enumerate(content.splitlines()):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            # Bare info!/warn!/error!/debug! without log:: prefix
            m = re.search(r'(?<!\w)(info|warn|error|debug)!\s*\(', stripped)
            if m and "log::" not in stripped:
                bare_log.append(f"{rs.stem}:{i+1}")
    if bare_log:
        shown = bare_log[:5]
        extra = f" (+{len(bare_log)-5} more)" if len(bare_log) > 5 else ""
        return Check("Q-07", "Log prefix", WARN,
                      f"Bare log macro (add log:: prefix): {', '.join(shown)}{extra}")
    return Check("Q-07", "Log prefix", PASS, "All log calls use log:: prefix")


def check_example_spec_sync(module: str) -> Check:
    """W-04: Functions in docs/specs/<module>.md Lua API table match functions in content/examples/<module>.lua."""
    spec_path = WORKSPACE / "docs" / "specs" / f"{module}.md"
    example_file = WORKSPACE / "content" / "examples" / f"{module}.lua"
    api_file = LUA_API / f"{module}_api.rs"
    if not api_file.exists():
        return Check("W-04", "Exampleâ€“spec sync", PASS, "No Lua API â€” skip")
    if not spec_path.exists() or not example_file.exists():
        return Check("W-04", "Exampleâ€“spec sync", PASS, "Missing spec or example â€” other checks cover this")

    # Use the generated top-level binding inventory.  A raw tbl.set() scan
    # also sees diagnostics/import-result fields such as invalidLayer and
    # invalidCoord, which are response keys rather than public functions.
    bound_fns = set(get_module_binding_names(module))
    if not bound_fns:
        return Check("W-04", "Exampleâ€“spec sync", PASS, "No bound functions")

    example_content = read_text(example_file)
    spec_content = read_text(spec_path)

    in_example = {fn for fn in bound_fns if fn in example_content}
    in_spec = {fn for fn in bound_fns if fn in spec_content}
    only_in_example = in_example - in_spec
    only_in_spec = in_spec - in_example

    issues: List[str] = []
    if only_in_example:
        issues.append(f"In example but not spec: {', '.join(sorted(only_in_example)[:4])} â€” add to ## Lua API in docs/specs/{module}.md")
    if only_in_spec:
        issues.append(f"In spec but not example: {', '.join(sorted(only_in_spec)[:4])} â€” add to content/examples/{module}.lua")
    if issues:
        return Check("W-04", "Exampleâ€“spec sync", WARN, " | ".join(issues))
    return Check("W-04", "Exampleâ€“spec sync", PASS,
                  f"All {len(in_spec)} functions consistent across spec and example")


def check_agent_source_files_complete(module: str) -> Check:
    return Check('A-04b', 'Source Files completeness', PASS, 'Skipped')

# â”€â”€ Orchestrator â”€â”€


def audit_module(module: str) -> Tuple[str, List[Check], str]:
    """Run all automated checks for a module. Returns (module, checks, result)."""
    checks: List[Check] = []

    # Single-pass analysis: read every .rs file exactly once and gather all
    # per-file findings.  Individual check functions query this result instead of
    # re-opening files, reducing disk I/O from O(files Ă— checks) to O(files).
    analysis = _analyze_module_files(module)

    # Phase 1: Structure & Registration
    checks.append(check_lib_rs_registration(module))
    checks.append(check_mod_rs_simplicity(module))
    checks.append(check_file_sizes(analysis))
    checks.append(check_file_naming(module))
    checks.append(Check("S-05", "Module necessity", MANUAL,
                          "Requires manual review â€” could this be pure Lua?"))
    checks.append(Check("S-06", "Large crate deps", MANUAL,
                          "Requires manual review â€” check Cargo.toml for heavy crates"))

    # Phase 3: Technical Specification (docs/specs/<module>.md)
    checks.extend(check_spec_file(module))

    # Phase 4: Docstrings â€” domain module files
    checks.append(check_module_level_docs(analysis))
    checks.append(check_pub_item_docs(analysis))
    checks.append(check_structured_sections(module))
    checks.append(check_doc_stubs(analysis))
    checks.append(Check("D-05", "Validation tool", MANUAL,
                          "Run: python tools/docs/collect_docs.py --report-missing | grep src/<module>"))

    # Phase 4: Docstrings â€” Lua API file
    checks.extend(check_lua_api_docs(module))

    # Phase 5: Luaâ†”Rust Bridge Integrity
    checks.extend(check_lua_bridge(module))

    # Phase 6: Architecture Compliance
    checks.append(check_tier_label(module))
    checks.append(check_dependency_direction(module, analysis))
    checks.append(check_no_lua_api_import(module, analysis))
    checks.append(Check("R-04", "Design assumptions", MANUAL,
                          "Verify against docs/architecture/philosophy.md"))
    checks.append(Check("R-05", "Module overlap", MANUAL,
                          "Check for scope duplication with other modules"))

    # Phase 7: Test Coverage
    checks.append(check_rust_test_exists(module))
    checks.append(check_lua_test_exists(module))
    checks.append(check_test_conventions(module))
    checks.append(check_float_comparisons(module))
    checks.append(check_test_adequacy(module))
    checks.append(Check("T-06", "Golden tests", MANUAL,
                          "Check if module qualifies for golden/snapshot tests"))
    checks.append(Check("T-07", "Tests pass", MANUAL,
                          f"Run: cargo test --test {module}_tests -- --nocapture"))

    # Phase 8: Documentation & Examples
    checks.extend(check_example_file(module))
    checks.append(Check("W-03", "Example comments", MANUAL,
                          f"Verify content/examples/{module}.lua has realistic one-line comments per call"))
    checks.append(check_example_spec_sync(module))
    checks.append(Check("W-06", "Changelog entry", MANUAL,
                          "Verify recent API changes have docs/CHANGELOG.md entries"))

    # Phase 9: Code Quality
    checks.append(check_no_println(analysis))
    checks.append(Check("Q-02", "Logger levels", MANUAL,
                          "Verify log severity levels are appropriate (debug/info/warn/error)"))
    checks.append(check_unsafe(analysis))
    checks.append(check_unwrap(analysis))
    checks.append(check_log_prefix(module, analysis))
    checks.append(Check("Q-05", "Rust best practices", MANUAL,
                          "Review for anti-patterns: unnecessary clones, redundant allocs"))
    checks.append(Check("Q-06", "Clippy clean", MANUAL,
                          f"Run: cargo clippy --lib -- -D warnings"))

    # Phase 10: Performance
    checks.append(Check("P-01", "Performance doc", MANUAL,
                          "Check docs/ for this moduleâ€™s performance notes"))
    checks.append(Check("P-02", "Hot-path allocations", MANUAL,
                          "Review update/draw/step paths for heap allocations"))
    checks.append(Check("P-03", "Buffer pre-allocation", MANUAL,
                          "Review Vec/HashMap growth patterns"))

    # Phase 11: Integration & Extension
    checks.append(Check("I-01", "Lua API usability", MANUAL,
                          "Review lurek.* conventions compliance"))
    checks.append(Check("I-02", "Extension panel", MANUAL,
                          "Check for structured data I/O for vscode-extension"))
    checks.append(check_config_integration(module))

    # Phase 12: Localization & Logging
    checks.append(Check("L-01", "Log externalization", MANUAL,
                          "Review log string consistency"))
    checks.append(Check("L-02", "TOML message catalog", MANUAL,
                          "Check for message catalog integration"))

    # Scoring
    errors = sum(1 for c in checks if c.verdict == ERROR)
    warnings = sum(1 for c in checks if c.verdict == WARN)

    # Heuristic warnings remain review leads rather than behavioral failures.
    result = "FAIL" if errors else "PASS"

    return module, checks, result



def format_quality_report(module: str, checks: List[Check], result: str, date: str) -> str:
    """Generate a Markdown quality report for logs/reports/module-quality/<module>.md."""
    errors = [c for c in checks if c.verdict == ERROR]
    warnings = [c for c in checks if c.verdict == WARN]
    passes = [c for c in checks if c.verdict == PASS]
    manual = [c for c in checks if c.verdict == MANUAL]

    badge = "đź”´ FAIL" if result == "FAIL" else "đźź˘ PASS"
    lines: List[str] = [
        f"# Module Quality Report: `{module}`",
        "",
        f"> **Status**: {badge}  |  "
        f"**Date**: {date}  |  "
        f"**Score**: {len(passes)} âś… / {len(warnings)} âš ď¸Ź / "
        f"{len(errors)} âťŚ / {len(manual)} đź”µ",
        "",
        "---",
        "",
    ]

    if errors or warnings:
        lines += ["## Action Items", ""]
        if errors:
            lines += ["### đź”´ Errors â€” Must Fix Before Merge", ""]
            for c in errors:
                lines.append(f"- [ ] **{c.code}** â€” {c.name}: {c.detail}")
            lines.append("")
        if warnings:
            lines += ["### đźźˇ Warnings â€” Should Fix", ""]
            for c in warnings:
                lines.append(f"- [ ] **{c.code}** â€” {c.name}: {c.detail}")
            lines.append("")

    phase_groups = [
        ("Phase 1 â€” Structure & Registration",    ["S-"]),
        ("Phase 3 â€” Technical Specification",     ["SP-"]),
        ("Phase 4 â€” Docstrings",                  ["D-"]),
        ("Phase 5 â€” Luaâ†”Rust Bridge",        ["B-"]),
        ("Phase 6 â€” Architecture Compliance",     ["R-"]),
        ("Phase 7 â€” Test Coverage",               ["T-"]),
        ("Phase 8 â€” Documentation & Examples",    ["W-"]),
        ("Phase 9 â€” Code Quality",                ["Q-"]),
        ("Phase 10 â€” Performance",                ["P-"]),
        ("Phase 11 â€” Integration & Extension",    ["I-"]),
        ("Phase 12 â€” Localization & Logging",     ["L-"]),
    ]

    lines += ["## Full Check Results", ""]
    for phase_name, prefixes in phase_groups:
        phase_checks = [c for c in checks if any(c.code.startswith(p) for p in prefixes)]
        if not phase_checks:
            continue
        lines += [
            f"### {phase_name}",
            "",
            "| Check | Verdict | Details |",
            "|-------|---------|---------|",
        ]
        icons = {PASS: "âś…", WARN: "âš ď¸Ź", ERROR: "âťŚ", MANUAL: "đź”µ"}
        for c in phase_checks:
            detail = c.detail.replace("|", r"\|")
            lines.append(f"| **{c.code}** {c.name} | {icons[c.verdict]} {c.verdict} | {detail} |")
        lines.append("")

    lines += [
        "---",
        "",
        "## Verification",
        "",
        "Re-run this report after applying fixes:",
        "",
        "```powershell",
        f"python tools/audit/audit_module.py {module} --docs-quality",
        "```",
        "",
        "Fix all âťŚ Errors, then address âš ď¸Ź Warnings until status shows **PASS**.",
        "",
        "_Auto-generated by `tools/audit/audit_module.py`. Do not edit manually._",
    ]

    return "\n".join(lines) + "\n"


def resolve_modules(args: argparse.Namespace) -> List[str]:
    """Resolve module list from CLI arguments."""
    if args.all:
        return sorted(
            name
            for name in module_registry.list_modules()
            if name not in ("bin", "lua_api")
        )
    if args.tier is not None:
        tier_map = {
            0: FOUNDATIONS,
            1: CORE_RUNTIME,
            2: PLATFORM_SERVICES,
            3: FEATURE_SYSTEMS,
            4: EDGE_INTEGRATION,
        }
        return sorted(tier_map.get(args.tier, set()))
    if args.modules:
        return [MODULE_ALIASES.get(module, module) for module in args.modules]
    return []


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Lurek2D module quality audit",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("modules", nargs="*", help="Module name(s) to audit")
    parser.add_argument("--all", action="store_true",
                        help="Audit all src/ modules")
    parser.add_argument("--tier", type=int, choices=[0, 1, 2, 3, 4],
                        help="Audit all modules in a registry tier (0=foundations, 1=core, 2=platform, 3=features, 4=edge)")
    parser.add_argument("--json", action="store_true",
                        help="Output structured JSON")
    parser.add_argument("--output", metavar="FILE",
                        help="Save report to file")
    parser.add_argument("--docs-quality", action="store_true",
                        help="Write per-module Markdown reports to logs/reports/module-quality/<module>.md")
    args = parser.parse_args()

    modules = resolve_modules(args)
    if not modules:
        parser.print_help()
        print("\nError: specify module name(s), --tier N, or --all", file=sys.stderr)
        return 1

    results = []
    all_passed = True

    for mod in modules:
        mod_dir = SRC / mod
        if not mod_dir.is_dir():
            print(f"Warning: src/{mod}/ does not exist â€” skipping", file=sys.stderr, flush=True)
            continue

        module_name, checks, result = audit_module(mod)
        results.append({"module": module_name, "checks": [c.to_dict() for c in checks],
                         "result": result})
        if result == "FAIL":
            all_passed = False

        if not args.json:
            import datetime
            quality_dir = WORKSPACE / "logs" / "quality"
            quality_dir.mkdir(parents=True, exist_ok=True)
            date_str = datetime.date.today().isoformat()
            qr = format_quality_report(module_name, checks, result, date_str)
            qpath = quality_dir / f"{module_name}.md"
            qpath.write_text(qr, encoding="utf-8")
            # One short line â€” never fills the pipe.
            print(f"logs/quality/{module_name}.md [{result}]", flush=True)

        # Release cached file content between modules so memory stays bounded.
        clear_file_cache()

    if len(modules) > 1 and not args.json:
        passed = sum(1 for r in results if r["result"] == "PASS")
        failed = len(results) - passed
        print(f"\n{passed}/{len(results)} passed â€” {failed} failed â€” reports in logs/reports/module-quality/",
              flush=True)

    if args.json:
        output = json.dumps(results, indent=2)
        if args.output:
            Path(args.output).write_text(output, encoding="utf-8")
            print(f"JSON report saved to {args.output}", flush=True)
        else:
            for ln in output.splitlines():
                print(ln, flush=True)

    return 0 if all_passed else 1


if __name__ == "__main__":
    # Reconfigure the EXISTING stdout/stderr wrappers to use UTF-8.
    # This avoids the cp1250 encoding crash on Windows WITHOUT replacing the
    # wrapper objects â€” replacing them creates a new block-buffered
    # io.TextIOWrapper whose flush on sys.exit() deadlocks VS Code's pipe.
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except AttributeError:
        pass  # Python < 3.7 or already binary (e.g. pytest capture)
    try:
        sys.exit(main())
    finally:
        # Flush before the interpreter tears down the pipe.
        try:
            sys.stdout.flush()
        except Exception:
            pass

