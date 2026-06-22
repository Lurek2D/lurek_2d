#!/usr/bin/env python3
"""Load the canonical Lurek2D module registry.

The registry is the single source of truth for module tiers, source paths,
Lua binding paths, namespaces, examples, tests, plugin tier metadata, and
canonical API ownership exceptions used by docs generators and audits.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - Python < 3.11 fallback.
    tomllib = None  # type: ignore[assignment]


ROOT = Path(__file__).resolve().parents[2]
MODULES_TOML = ROOT / "docs" / "meta" / "modules.toml"
DOCS_DATA = ROOT / "build" / "docs-data"
LEGACY_LOGS_DATA = ROOT / "logs" / "data"

REQUIRED_FIELDS = {
    "tier",
    "source",
    "lua_binding",
    "namespace",
    "example_file",
    "lua_unit_test",
    "user_facing",
    "plugin_tier",
}
SPECIAL_SECTIONS = {"aliases", "canonical_owner", "canonical_api"}

_CACHE: dict[str, Any] | None = None


def _load_toml(path: Path) -> dict[str, Any]:
    if tomllib is None:
        raise RuntimeError(
            "tools/docs/module_registry.py requires Python 3.11+ tomllib support"
        )
    if not path.exists():
        raise FileNotFoundError(f"module registry not found: {path}")
    return tomllib.loads(path.read_text(encoding="utf-8"))


def load_registry() -> dict[str, Any]:
    """Return the raw modules.toml payload including special sections."""
    global _CACHE
    if _CACHE is None:
        _CACHE = _load_toml(MODULES_TOML)
        _validate(_CACHE)
    return _CACHE


def load_modules() -> dict[str, dict[str, Any]]:
    """Return canonical module entries keyed by module name."""
    data = load_registry()
    return {
        name: value
        for name, value in data.items()
        if name not in SPECIAL_SECTIONS and isinstance(value, dict)
    }


def _validate(data: dict[str, Any]) -> None:
    errors: list[str] = []
    for name, value in data.items():
        if name in SPECIAL_SECTIONS:
            continue
        if not isinstance(value, dict):
            errors.append(f"{name}: expected table")
            continue
        missing = sorted(REQUIRED_FIELDS - set(value))
        if missing:
            errors.append(f"{name}: missing {', '.join(missing)}")
    if errors:
        raise ValueError("invalid docs/meta/modules.toml:\n" + "\n".join(errors))


def get_module(name: str) -> dict[str, Any]:
    modules = load_modules()
    if name not in modules:
        raise KeyError(f"unknown module: {name}")
    return modules[name]


def list_modules(include_non_user_facing: bool = True) -> list[str]:
    modules = load_modules()
    names = []
    for name, meta in modules.items():
        if include_non_user_facing or bool(meta.get("user_facing")):
            names.append(name)
    return sorted(names)


def module_tier(name: str) -> str:
    return str(get_module(name).get("tier", ""))


def module_namespace(name: str) -> str:
    return str(get_module(name).get("namespace", ""))


def module_source_path(name: str) -> str:
    return str(get_module(name).get("source", ""))


def module_lua_binding_path(name: str) -> str:
    return str(get_module(name).get("lua_binding", ""))


def module_example_file(name: str) -> str:
    return str(get_module(name).get("example_file", ""))


def module_lua_unit_test(name: str) -> str:
    return str(get_module(name).get("lua_unit_test", ""))


def module_plugin_tier(name: str) -> str:
    return str(get_module(name).get("plugin_tier", ""))


def user_facing_modules() -> list[str]:
    return list_modules(include_non_user_facing=False)


def aliases() -> dict[str, str]:
    return dict(load_registry().get("aliases", {}))


def canonical_owner(symbol: str) -> str | None:
    owner = load_registry().get("canonical_owner", {}).get(symbol)
    return str(owner) if owner is not None else None


def canonical_api_owner(api_name: str) -> str | None:
    owner = load_registry().get("canonical_api", {}).get(api_name)
    return str(owner) if owner is not None else None


def docs_data_file(name: str, legacy_name: str | None = None) -> Path:
    """Return the preferred generated docs-data file, falling back to logs/data."""
    preferred = DOCS_DATA / name
    if preferred.exists():
        return preferred
    return LEGACY_LOGS_DATA / (legacy_name or name)


def lua_api_json_path() -> Path:
    return docs_data_file("lua_api.json", "lua_api_data.json")


def rust_api_json_path() -> Path:
    return docs_data_file("rust_api.json", "rust_api_data.json")


def test_coverage_json_path() -> Path:
    return docs_data_file("test_coverage.json")


def doc_coverage_json_path() -> Path:
    return docs_data_file("doc_coverage.json")


def lua_api_test_coverage_json_path() -> Path:
    return docs_data_file("lua_api_test_coverage.json")


def api_coverage_report_json_path() -> Path:
    return docs_data_file("api_coverage_report.json")


def _main() -> int:
    parser = argparse.ArgumentParser(description="Inspect docs/meta/modules.toml")
    sub = parser.add_subparsers(dest="command")
    list_parser = sub.add_parser("list", help="Print registered modules")
    list_parser.add_argument("--user-facing", action="store_true", help="Only print user-facing modules")
    list_parser.add_argument("--json", action="store_true", help="Emit JSON")
    show_parser = sub.add_parser("show", help="Print one module entry")
    show_parser.add_argument("module")
    args = parser.parse_args()

    if args.command == "show":
        print(json.dumps(get_module(args.module), indent=2, sort_keys=True))
        return 0

    names = list_modules(include_non_user_facing=not getattr(args, "user_facing", False))
    if getattr(args, "json", False):
        print(json.dumps(names, indent=2))
    else:
        for name in names:
            meta = get_module(name)
            print(f"{name}\t{meta['tier']}\t{meta['namespace'] or '-'}")
    return 0


if __name__ == "__main__":
    sys.exit(_main())
