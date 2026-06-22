#!/usr/bin/env python3
"""Audit documentation source/generated ownership and coverage gates."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "docs"))
import module_registry

SPECS = ROOT / "docs" / "specs"
MANUAL = SPECS / "manual"
GENERATED_HEADER = "<!-- GENERATED FILE."


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}
    return data if isinstance(data, dict) else {}


def check_specs(errors: list[str]) -> None:
    modules = set(module_registry.list_modules())
    user_modules = set(module_registry.user_facing_modules())
    allowed_special = {"callbacks"}

    spec_files = {
        path.stem: path
        for path in SPECS.glob("*.md")
        if path.name not in {"README.md", "AGENTS.md", "SPEC_TEMPLATE.md"}
    }
    manual_files = {
        path.stem: path
        for path in MANUAL.glob("*.md")
        if path.name not in {"README.md", "AGENTS.md"}
    } if MANUAL.exists() else {}

    for module in sorted(user_modules):
        if module not in manual_files:
            errors.append(f"MISSING_MANUAL_OVERLAY docs/specs/manual/{module}.md")

    for module, path in sorted(spec_files.items()):
        if module not in modules and module not in allowed_special:
            errors.append(f"ORPHAN_SPEC {rel(path)}")
        text = path.read_text(encoding="utf-8-sig")
        if not text.startswith(GENERATED_HEADER):
            errors.append(f"MISSING_GENERATED_HEADER {rel(path)}")

    for module, path in sorted(manual_files.items()):
        if module not in modules and module not in allowed_special:
            errors.append(f"ORPHAN_MANUAL_OVERLAY {rel(path)}")


def check_coverage(errors: list[str]) -> None:
    example_report = load_json(module_registry.api_coverage_report_json_path())
    missing_apis = example_report.get("missing_apis") or []
    if missing_apis:
        errors.append(f"EXAMPLE_COVERAGE_MISSING {len(missing_apis)} APIs")

    test_report = load_json(module_registry.lua_api_test_coverage_json_path())
    modules = test_report.get("modules") or {}
    for module_name, module_data in sorted(modules.items()):
        uncovered = module_data.get("uncovered") or []
        if uncovered:
            errors.append(f"TEST_COVERAGE_MISSING {module_name}: {len(uncovered)} APIs")


def check_dead_architecture_links(errors: list[str]) -> None:
    target = ROOT / "docs" / "architecture" / "test-framework.md"
    if target.exists():
        return
    roots = [ROOT / "README.md", ROOT / "tests" / "README.md", ROOT / "docs", ROOT / ".github", ROOT / ".codex"]
    for root in roots:
        paths = [root] if root.is_file() else sorted(root.rglob("*.md"))
        for path in paths:
            if not path.exists() or not path.is_file():
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            if "test-framework.md" in text:
                errors.append(f"DEAD_TEST_FRAMEWORK_LINK {rel(path)}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit docs ownership, generated headers, and docs coverage gates")
    parser.parse_args()
    errors: list[str] = []
    check_specs(errors)
    check_coverage(errors)
    check_dead_architecture_links(errors)
    if errors:
        print("Docs quality failed:")
        for error in errors:
            print(f"  {error}")
        return 1
    print("Docs quality passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
