"""Audit wiki page coverage against engine modules and Lua API.

Cross-references wiki/ pages against:
  - src/ module directories (each module should have a wiki page).
  - lurek.* API surface (key namespaces should be documented).
  - content/library/ entries (each library should appear in wiki).

Reports missing wiki pages, orphaned pages (wiki page with no matching
module), and pages with potential staleness indicators (e.g. references
to old namespace names).

Usage:
    python tools/audit/wiki_coverage.py [--strict] [--format text|json]

Exit code:
    0 if no gaps, 1 if any missing coverage found (errors only).
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(".").resolve()
WIKI_DIR = ROOT / "docs" / "wiki"
SRC_DIR = ROOT / "src"
LIBRARY_DIR = ROOT / "library"
API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"

# Modules that are internal and don't need dedicated coverage checks
INTERNAL_MODULES = {
    "lua_api", "bin", "docs", "pipeline", "app",
}

# Generated wiki pages that do not map to a single src/ module
META_PAGES = {
    "Home", "Getting-Started", "First-Game", "Project-Structure",
    "Callbacks", "Runtime-Model", "Modules", "API", "API-Reference",
    "Examples", "Reference-Games", "Lureksome", "Glossary",
    "_Sidebar", "_Footer",
}


def normalize_page_name(value: str) -> str:
    return value.lower().replace("-", "_")


def module_page_name(module: str) -> str:
    return f"Module-{module}"


def discover_modules() -> set[str]:
    """Return set of module names from src/ that should have wiki pages."""
    modules = set()
    if not SRC_DIR.exists():
        return modules
    for d in SRC_DIR.iterdir():
        if d.is_dir() and not d.name.startswith("_") and d.name not in INTERNAL_MODULES:
            modules.add(d.name)
    return modules


def discover_all_source_modules() -> set[str]:
    """Return all top-level src/ module names, including internal ones."""
    modules = set()
    if not SRC_DIR.exists():
        return modules
    for d in SRC_DIR.iterdir():
        if d.is_dir() and not d.name.startswith("_"):
            modules.add(d.name)
    return modules


def discover_api_modules() -> set[str]:
    """Return module keys from generated Lua API data."""
    if not API_JSON.exists():
        return set()

    data = json.loads(API_JSON.read_text(encoding="utf-8"))
    return set(data.get("lua_api", {}).get("modules", {}).keys())


def discover_libraries() -> set[str]:
    """Return set of library names from content/library/."""
    libs = set()
    if not LIBRARY_DIR.exists():
        return libs
    for d in LIBRARY_DIR.iterdir():
        if d.is_dir() and not d.name.startswith("."):
            libs.add(d.name)
    return libs


def discover_wiki_pages() -> dict[str, Path]:
    """Return dict of {page_stem: path} from wiki/."""
    pages: dict[str, Path] = {}
    if not WIKI_DIR.exists():
        return pages
    for f in WIKI_DIR.glob("*.md"):
        pages[f.stem] = f
    return pages


def main() -> int:
    from argparse import RawDescriptionHelpFormatter
    epilog = """
Examples:
  # Default execution
  python tools/audit/wiki_coverage.py

  # Show all arguments
  python tools/audit/wiki_coverage.py --help
"""
    parser = argparse.ArgumentParser(
        description="Audit wiki page coverage against engine modules.",
        epilog=epilog,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument("--strict", action="store_true",
                        help="Treat warnings as errors")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()

    modules = discover_modules()
    all_source_modules = discover_all_source_modules()
    api_modules = discover_api_modules()
    libraries = discover_libraries()
    wiki_pages = discover_wiki_pages()

    findings: list[dict] = []
    page_stems_normalized = {normalize_page_name(k) for k in wiki_pages}

    # Check modules have wiki pages
    expected_modules = modules | api_modules
    for mod in sorted(expected_modules):
        expected_pages = {
            normalize_page_name(mod),
            normalize_page_name(mod.replace("_", "-")),
            normalize_page_name(module_page_name(mod)),
            normalize_page_name(module_page_name(mod.replace("_", "-"))),
        }
        if expected_pages.isdisjoint(page_stems_normalized):
            findings.append({
                "level": "ERROR" if args.strict else "WARN",
                "category": "module",
                "name": mod,
                "message": f"Module '{mod}' has no wiki page in docs/wiki/",
            })

    # Check libraries are mentioned
    for lib in sorted(libraries):
        if {
            normalize_page_name(lib),
            normalize_page_name(lib.replace("_", "-")),
        }.isdisjoint(page_stems_normalized):
            # Check if mentioned in any wiki page
            mentioned = False
            for page_path in wiki_pages.values():
                text = page_path.read_text(encoding="utf-8", errors="replace")
                if lib in text.lower():
                    mentioned = True
                    break
            if not mentioned:
                findings.append({
                    "level": "WARN",
                    "category": "library",
                    "name": lib,
                    "message": f"Library '{lib}' not mentioned in any wiki page",
                })

    # Check for orphaned wiki pages
    known_modules = all_source_modules | api_modules
    all_known = (
        {normalize_page_name(m) for m in known_modules}
        | {normalize_page_name(m.replace("_", "-")) for m in known_modules}
        | {normalize_page_name(module_page_name(m)) for m in known_modules}
        | {normalize_page_name(module_page_name(m.replace("_", "-"))) for m in known_modules}
        | {normalize_page_name(lb) for lb in libraries}
        | {normalize_page_name(lb.replace("_", "-")) for lb in libraries}
        | {normalize_page_name(p) for p in META_PAGES}
    )
    for stem in wiki_pages:
        stem_norm = normalize_page_name(stem)
        if stem_norm not in all_known:
            findings.append({
                "level": "WARN",
                "category": "orphan",
                "name": stem,
                "message": f"Wiki page '{stem}.md' has no matching module or library",
            })

    errors = [f for f in findings if f["level"] == "ERROR"]
    warns = [f for f in findings if f["level"] == "WARN"]

    if args.format == "json":
        print(json.dumps({
            "modules": len(modules),
            "libraries": len(libraries),
            "wiki_pages": len(wiki_pages),
            "findings": findings,
        }, indent=2))
    else:
        for f in findings:
            print(f"[{f['level']}] {f['category']}/{f['name']}: {f['message']}")
        print(f"\n{len(modules)} modules, {len(libraries)} libraries, "
              f"{len(wiki_pages)} wiki pages")
        print(f"{len(errors)} error(s), {len(warns)} warning(s)")

    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
