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
PAGES_INPUT = ROOT / "lurek_2d_pages" / ".source"
GENERATED_HEADER = "<!-- GENERATED FILE."
MOJIBAKE_MARKERS = ("Ã", "Â", "â€™", "â€œ", "â€", "â€”", "â€“", "â€¦")
TEXT_DOC_ROOTS = (
    "docs/index.md",
    "docs/lua-api.md",
)
TEXT_DOC_DIRS = (
    "docs/guides",
    "docs/contributing",
    "docs/architecture",
    "docs/templates",
)
TEXT_DOC_DIR_EXCLUDES: set[str] = set()


def api_module_name(module: str) -> str:
    namespace = module_registry.module_namespace(module)
    if namespace.startswith("lurek."):
        return namespace.split(".", 1)[1]
    return module


def rel(path: Path, root: Path = ROOT) -> str:
    return path.relative_to(root).as_posix()


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


def check_module_pages_indexed(errors: list[str]) -> None:
    mkdocs_text = (ROOT / "mkdocs.yml").read_text(encoding="utf-8")
    guide_text = (PAGES_INPUT / "module-guides.md").read_text(encoding="utf-8")
    required_public_pages = [
        "guides/index.md",
        "guides/getting-started.md",
        "guides/first-game.md",
        "guides/project-structure.md",
        "guides/examples.md",
        "guides/recipes.md",
        "guides/reference-games.md",
        "contributing/index.md",
        "contributing/build-and-distribution.md",
        "contributing/rust-file-docstrings.md",
        "api/lurek.md",
        "api/lureksome.md",
    ]
    for path in required_public_pages:
        if not re.search(rf"^\s*-\s+.*:\s+{re.escape(path)}\s*$", mkdocs_text, re.MULTILINE):
            errors.append(f"MISSING_PAGES_NAV {path}")
        if re.search(rf"^\s+{re.escape(path)}\s*$", mkdocs_text, re.MULTILINE):
            errors.append(f"FORBIDDEN_PAGES_EXCLUDE {path}")
    if "  index.md" in mkdocs_text:
        errors.append("FORBIDDEN_PAGES_EXCLUDE index.md")

    forbidden_headings = {"Foundations", "Core Runtime", "Platform Services", "Feature Systems", "Edge/Integration"}
    for heading in forbidden_headings:
        if re.search(rf"^##\s+{re.escape(heading)}\s*$", guide_text, re.MULTILINE):
            errors.append(f"FORBIDDEN_MODULE_GUIDE_SECTION {heading}")

    guide_labels = re.findall(r"^\| \[([^\]]+)\]\(modules/[^)]+\.md\) \|", guide_text, re.MULTILINE)
    if guide_labels != sorted(guide_labels, key=str.casefold):
        errors.append("MODULE_GUIDE_NOT_ALPHABETICAL")

    expected_refs = {
        f"modules/{api_module_name(module)}.md"
        for module in module_registry.user_facing_modules()
    }
    nav_module_refs = set(re.findall(r"^\s*-\s+[^:\n]+:\s+(modules/[^\s#]+\.md)\s*$", mkdocs_text, re.MULTILINE))
    for module_page in (PAGES_INPUT / "modules").glob("*.md"):
        module_ref = f"modules/{module_page.name}"
        if module_ref not in expected_refs:
            errors.append(f"FORBIDDEN_NON_API_MODULE_PAGE docs/{module_ref}")

    for module_ref in sorted(nav_module_refs):
        if module_ref not in expected_refs:
            errors.append(f"STALE_MKDOCS_MODULE_NAV {module_ref}")

    for module in module_registry.user_facing_modules():
        api_module = api_module_name(module)
        module_path = PAGES_INPUT / "modules" / f"{api_module}.md"
        module_ref = f"modules/{api_module}.md"
        if not module_path.exists():
            errors.append(f"MISSING_MODULE_PAGE docs/modules/{api_module}.md")
        if module_ref not in mkdocs_text:
            errors.append(f"MISSING_MKDOCS_MODULE_NAV {module_ref}")
        if re.search(rf"^  - [^:\n]+:\s+{re.escape(module_ref)}\s*$", mkdocs_text, re.MULTILINE):
            errors.append(f"FORBIDDEN_TOP_LEVEL_MODULE_NAV {module_ref}")
        if f"]({module_ref})" not in guide_text:
            errors.append(f"MISSING_MODULE_GUIDE_LINK {module_ref}")
        if module_path.exists():
            module_text = module_path.read_text(encoding="utf-8")
            if "Runnable example owner:" in module_text:
                errors.append(f"FORBIDDEN_PAGES_EXAMPLE_OWNER docs/modules/{api_module}.md")
            if re.search(r"See `content/examples/[^`]+`", module_text):
                errors.append(f"FORBIDDEN_PAGES_TEXT_EXAMPLE_LINK docs/modules/{api_module}.md")
            if "No public API documented yet." in module_text:
                errors.append(f"EMPTY_MODULE_API_PAGE docs/modules/{api_module}.md")
            if "No callback parameters documented in this module." in module_text:
                errors.append(f"FORBIDDEN_EMPTY_CALLBACK_SECTION docs/modules/{api_module}.md")
            if api_module != module and f"{module} module" in module_text.lower():
                errors.append(f"FORBIDDEN_INTERNAL_MODULE_ALIAS_TEXT docs/modules/{api_module}.md")

    guide_lower = guide_text.lower()
    for module in module_registry.user_facing_modules():
        api_module = api_module_name(module)
        if api_module != module and f"{module} module" in guide_lower:
            errors.append(f"FORBIDDEN_INTERNAL_MODULE_ALIAS_TEXT docs/module-guides.md:{module}")

    callbacks_text = (ROOT / "docs" / "api" / "callbacks.md").read_text(encoding="utf-8")
    if "No callbacks found" in callbacks_text or "No callback details available" in callbacks_text:
        errors.append("EMPTY_CALLBACKS_PAGE docs/api/callbacks.md")
    if not re.search(r"^### `lurek\.[A-Za-z_]+`", callbacks_text, re.MULTILINE):
        errors.append("MISSING_CALLBACK_DETAILS docs/api/callbacks.md")


def check_dead_architecture_links(errors: list[str]) -> None:
    target = ROOT / "docs" / "architecture" / "test-framework.md"
    if target.exists():
        return
    roots = [ROOT / "README.md", ROOT / "tests" / "README.md", ROOT / "docs", ROOT / ".codex"]
    for root in roots:
        paths = [root] if root.is_file() else sorted(root.rglob("*.md"))
        for path in paths:
            if not path.exists() or not path.is_file():
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            if "test-framework.md" in text:
                errors.append(f"DEAD_TEST_FRAMEWORK_LINK {rel(path)}")


def check_relative_text_docs(root: Path, errors: list[str]) -> None:
    targets: list[Path] = []
    for relative in TEXT_DOC_ROOTS:
        path = root / relative
        if path.exists():
            targets.append(path)
    for relative in TEXT_DOC_DIRS:
        path = root / relative
        if path.is_dir():
            for child in sorted(child for child in path.rglob("*.md") if child.is_file()):
                parts = child.relative_to(path).parts
                if parts and parts[0] in TEXT_DOC_DIR_EXCLUDES:
                    continue
                if child.name == "AGENTS.md":
                    continue
                targets.append(child)

    link_re = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
    for path in targets:
        rel_path = rel(path, root)
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            errors.append(f"NON_UTF8_TEXT {rel_path}")
            continue

        for marker in MOJIBAKE_MARKERS:
            if marker in text:
                errors.append(f"MOJIBAKE_TEXT {rel_path} {marker!r}")
                break

        for target in link_re.findall(text):
            link = target.split()[0].strip("<>")
            if not link or link.startswith("#"):
                continue
            if re.match(r"^[A-Za-z][A-Za-z0-9+.-]*://", link) or link.startswith("mailto:"):
                continue
            if re.match(r"^(?:[A-Za-z]:[\\/]|/)", link):
                errors.append(f"ABSOLUTE_LINK {rel_path} -> {link}")
                continue
            link_path = re.split(r"[?#]", link, maxsplit=1)[0]
            normalized_parts = [
                part
                for part in Path(link_path).parts
                if part not in {".", ".."}
            ]
            if normalized_parts and normalized_parts[0] == "modules":
                continue
            resolved = (path.parent / link_path).resolve()
            if not resolved.exists():
                errors.append(f"BROKEN_RELATIVE_LINK {rel_path} -> {link}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit docs ownership, generated headers, and docs coverage gates")
    parser.parse_args()
    errors: list[str] = []
    check_specs(errors)
    check_coverage(errors)
    check_module_pages_indexed(errors)
    check_dead_architecture_links(errors)
    check_relative_text_docs(ROOT, errors)
    if errors:
        print("Docs quality failed:")
        for error in errors:
            print(f"  {error}")
        return 1
    print("Docs quality passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
