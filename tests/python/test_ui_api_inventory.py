"""Fixtures for the canonical UI API inventory audit."""
from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("ui_api_inventory", ROOT / "tools/audit/ui_api_inventory.py")
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def payload(entries: list[dict], classes: dict | None = None) -> dict:
    return {
        "lua_api": {
            "inventory_schema": "lurek2d.lua_api_inventory.v1",
            "modules": {"ui": {"functions": entries, "classes": classes or {}}},
        }
    }


def entry(name: str, ident: str) -> dict:
    return {"inventory_id": ident, "lua_name": name, "kind": "function", "owner_type": "", "file": "src/lua_api/ui_api.rs", "line": 1, "lifecycle": "stable", "canonical_lua_name": name, "alias_of": None}


class UiApiInventoryTests(unittest.TestCase):
    def test_accepts_namespace_userdata_overload_alias_and_removed_entries(self) -> None:
        canonical = entry("lurek.ui.clear", "ui:function:namespace:lurek.ui.clear")
        alias = entry("lurek.ui.clearLegacy", "ui:function:namespace:lurek.ui.clearLegacy")
        alias.update({"lifecycle": "deprecated", "canonical_lua_name": "lurek.ui.clear", "alias_of": "lurek.ui.clear"})
        removed = entry("lurek.ui.removedThing", "ui:function:namespace:lurek.ui.removedThing")
        removed["lifecycle"] = "removed"
        first_overload = entry("LButton:setText", "ui:method:LButton:LButton:setText")
        second_overload = entry("LLabel:setText", "ui:method:LLabel:LLabel:setText")
        classes = {"LButton": {"methods": [first_overload]}, "LLabel": {"methods": [second_overload]}}
        self.assertEqual([], MODULE.validate(payload([canonical, alias, removed], classes)))

    def test_rejects_duplicate_ids_and_unknown_aliases(self) -> None:
        first = entry("lurek.ui.clear", "duplicate")
        second = entry("lurek.ui.reset", "duplicate")
        second["alias_of"] = "missing"
        second["canonical_lua_name"] = "missing"
        failures = MODULE.validate(payload([first, second]))
        self.assertTrue(any("duplicate inventory_id" in failure for failure in failures))
        self.assertTrue(any("alias target" in failure for failure in failures))


if __name__ == "__main__":
    unittest.main()
