#!/usr/bin/env python3
"""Regenerate the full Lurek2D documentation pipeline in one command.

Phases:
    data     - generated machine-readable docs data
    specs    - generated module specs from source + manual overlays
    api      - generated API references and LuaCATS stubs
    pages    - generated module pages and site input
    reports  - generated coverage and quality reports

Usage:
    python tools/gen_all_docs.py
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path


if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

TOOLS_DIR = Path(__file__).parent
ROOT = TOOLS_DIR.parent
DOCS_DATA_PAIRS = [
    ("logs/data/lua_api_data.json", "build/docs-data/lua_api.json"),
    ("logs/data/rust_api_data.json", "build/docs-data/rust_api.json"),
    ("logs/data/doc_coverage.json", "build/docs-data/doc_coverage.json"),
    ("logs/data/test_coverage.json", "build/docs-data/test_coverage.json"),
    ("logs/data/lua_api_test_coverage.json", "build/docs-data/lua_api_test_coverage.json"),
    ("logs/data/api_coverage_report.json", "build/docs-data/api_coverage_report.json"),
]

PHASES: list[tuple[str, list[tuple[str, list[str], str]]]] = [
    ("data", [
        ("docs/gen_rust_api_data.py", [], "Rust JSON (logs/data/rust_api_data.json)"),
        ("docs/gen_lua_api_data.py", [], "Lua JSON (logs/data/lua_api_data.json)"),
        ("docs/gen_evidence_manifest.py", [], "Evidence manifest (build/docs-data/evidence_manifest.json)"),
    ]),
    ("specs", [
        ("docs/gen_module_specs.py", [], "Generated module specs (docs/specs/<module>.md)"),
    ]),
    ("api", [
        ("docs/gen_extension_api.py", [], "VS Code extension API (lurek_2d_extension/data/lurek-api.json)"),
        ("docs/gen_luadoc.py", [], "LuaCATS stubs (docs/api/lurek.lua)"),
        ("docs/gen_docs_lua.py", [], "Lua API reference (docs/api/lurek.md)"),
        ("docs/gen_docs_lua_html.py", [], "Lua API HTML redirects (lurek_2d_pages/lua-docs)"),
        ("docs/gen_docs_rust.py", [], "Rust API reference (docs/api/rust.md)"),
        ("docs/gen_lib_docs.py", [], "Library API (docs/api/lureksome.md + docs/api/lureksome.lua)"),
    ]),
    ("pages", [
        ("docs/gen_module_pages.py", [], "Lua module pages (lurek_2d_pages/.source/modules/<module>.md)"),
    ]),
    ("reports", [
        ("audit/doc_coverage.py", [], "Doc coverage analytics (logs/data/doc_coverage.json)"),
        ("audit/test_coverage.py", [], "Test coverage analytics (logs/data/test_coverage.json)"),
        ("audit/api_occurrence_validator.py", [], "Example API coverage data (build/docs-data/api_coverage_report.json)"),
        ("docs/gen_test_docs.py", ["--mode", "rust", "--output", "logs/reports/test_docs_rust.md"], "Rust test docs"),
        ("docs/gen_test_docs.py", ["--mode", "lua", "--output", "logs/reports/test_docs_lua.md"], "Lua test docs"),
        ("audit/example_coverage.py", ["--markdown", "logs/reports/example_coverage.md"], "Example coverage"),
        ("audit/gen_coverage_gaps.py", [], "Coverage gaps"),
        ("audit/test_coverage.py", ["--output", "logs/reports/test_coverage.md"], "Test coverage report"),
        ("audit/lua_api_test_coverage.py", ["--report", "--output", "logs/reports/lua_test_coverage.md"], "Lua API test coverage"),
        ("audit/docs_quality.py", [], "Docs quality gate"),
    ]),
]


def run_script(script_name: str, extra_args: list[str], label: str) -> bool:
    script = TOOLS_DIR / script_name
    print(f"  [{label}]")
    t0 = time.monotonic()
    env = {**os.environ, "PYTHONIOENCODING": "utf-8"}
    result = subprocess.run(
        [sys.executable, str(script)] + extra_args,
        capture_output=True,
        text=True,
        encoding="utf-8",
        env=env,
    )
    elapsed = time.monotonic() - t0
    if result.returncode != 0:
        print(f"    FAILED ({elapsed:.1f}s)")
        for stream_name, stream in [("stdout", result.stdout), ("stderr", result.stderr)]:
            if stream:
                for line in stream.strip().split("\n")[-8:]:
                    print(f"    {stream_name}: {line}")
        return False
    lines = [line for line in result.stdout.strip().split("\n") if line.strip()]
    if lines:
        print(f"    {lines[-1]}")
    print(f"    done in {elapsed:.1f}s")
    return True


def sync_docs_data_cache() -> None:
    """Keep build/docs-data preferred JSONs and logs/data compatibility copies in sync."""
    for legacy_rel, preferred_rel in DOCS_DATA_PAIRS:
        legacy = ROOT / legacy_rel
        preferred = ROOT / preferred_rel
        if legacy.exists() and (
            not preferred.exists()
            or legacy.stat().st_mtime_ns > preferred.stat().st_mtime_ns
        ):
            preferred.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(legacy, preferred)
        elif preferred.exists() and (
            not legacy.exists()
            or preferred.stat().st_mtime_ns > legacy.stat().st_mtime_ns
        ):
            legacy.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(preferred, legacy)


def build_pages_site() -> bool:
    """Build generated MkDocs input into the nested static Pages repository."""
    print("  [MkDocs static site (lurek_2d_pages)]")
    t0 = time.monotonic()
    pages_input = ROOT / "lurek_2d_pages" / ".source"
    generated_modules = pages_input / "modules"
    generated_index = pages_input / "module-guides.md"
    if not generated_modules.exists() or not generated_index.exists():
        print("    FAILED: generated module pages are missing")
        return False
    with tempfile.TemporaryDirectory(prefix="lurek-pages-") as temp_dir:
        staging_root = Path(temp_dir)
        staged_docs = staging_root / "site-input"
        config_path = staging_root / "mkdocs.yml"
        shutil.copytree(ROOT / "docs", staged_docs)
        shutil.copytree(generated_modules, staged_docs / "modules", dirs_exist_ok=True)
        shutil.copy2(generated_index, staged_docs / "guides" / "module-guides.md")
        config_text = (ROOT / "mkdocs.yml").read_text(encoding="utf-8")
        config_text = config_text.replace("docs_dir: docs", "docs_dir: site-input")
        config_text = config_text.replace(
            "site_dir: lurek_2d_pages",
            f"site_dir: {str(ROOT / 'lurek_2d_pages').replace('\\\\', '/')}",
        )
        config_path.write_text(config_text, encoding="utf-8")
        result = subprocess.run(
            # The Pages repository also owns deployment metadata and its README.
            # Keep those files while refreshing generated static artifacts.
            [sys.executable, "-m", "mkdocs", "build", "--config-file", str(config_path), "--dirty"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            env={**os.environ, "PYTHONIOENCODING": "utf-8"},
        )
    elapsed = time.monotonic() - t0
    if result.returncode != 0:
        print(f"    FAILED ({elapsed:.1f}s)")
        for stream_name, stream in [("stdout", result.stdout), ("stderr", result.stderr)]:
            if stream:
                for line in stream.strip().split("\n")[-8:]:
                    print(f"    {stream_name}: {line}")
        return False
    print(f"    done in {elapsed:.1f}s")
    return True


def main() -> None:
    print("Lurek2D doc pipeline")
    print("=" * 60)
    failed: list[str] = []
    for phase_name, scripts in PHASES:
        print(f"\nPhase: {phase_name}")
        for script_name, extra_args, label in scripts:
            if not run_script(script_name, extra_args, label):
                failed.append(f"{script_name} {' '.join(extra_args)}".strip())
            sync_docs_data_cache()
    print("\nPhase: site")
    if not build_pages_site():
        failed.append("mkdocs build --dirty")
    print("=" * 60)
    if failed:
        print(f"FAILED: {', '.join(failed)}")
        sys.exit(1)
    print("All docs generated successfully.")


if __name__ == "__main__":
    main()
