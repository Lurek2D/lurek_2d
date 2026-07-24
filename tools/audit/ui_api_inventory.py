#!/usr/bin/env python3
"""Validate the canonical generated inventory for the public ``lurek.ui`` API.

The Lua API generator is the sole source for namespace functions and userdata
methods. This audit rejects missing metadata, duplicate machine IDs, malformed
aliases, and entries that cannot be resolved to a stable canonical API name.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "docs"))
import module_registry

# Coverage and documentation tools resolve this exact canonical generated path.
# Do not point this validator at the legacy log mirror, or a stale mirror can
# make otherwise matching UI coverage denominators silently diverge.
DEFAULT_API = module_registry.lua_api_json_path()
REQUIRED = {"inventory_id", "lua_name", "kind", "owner_type", "file", "line", "lifecycle", "canonical_lua_name", "alias_of"}
LIFECYCLES = {"stable", "experimental", "deprecated", "removed"}


def entries(payload: dict, module: str = "ui") -> list[dict]:
    owner = payload.get("lua_api", payload).get("modules", {}).get(module, {})
    result = list(owner.get("functions") or [])
    for cls in (owner.get("classes") or {}).values():
        result.extend(cls.get("methods") or [])
    return result


def validate(payload: dict, module: str = "ui") -> list[str]:
    failures: list[str] = []
    inventory = payload.get("lua_api", payload)
    if inventory.get("inventory_schema") != "lurek2d.lua_api_inventory.v1":
        failures.append("missing or unsupported inventory_schema")
    all_entries = entries(payload, module)
    names = {entry.get("lua_name") for entry in all_entries}
    ids: set[str] = set()
    for entry in all_entries:
        label = str(entry.get("lua_name", "<unnamed>"))
        missing = sorted(REQUIRED - set(entry))
        if missing:
            failures.append(f"{label}: missing {', '.join(missing)}")
            continue
        if entry["inventory_id"] in ids:
            failures.append(f"{label}: duplicate inventory_id {entry['inventory_id']}")
        ids.add(entry["inventory_id"])
        if entry["lifecycle"] not in LIFECYCLES:
            failures.append(f"{label}: invalid lifecycle {entry['lifecycle']}")
        alias = entry["alias_of"]
        canonical = entry["canonical_lua_name"]
        if alias is None and canonical != entry["lua_name"]:
            failures.append(f"{label}: canonical entry must name itself")
        if alias is not None and alias not in names:
            failures.append(f"{label}: alias target {alias} is not in the inventory")
    return sorted(failures)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api-json", type=Path, default=DEFAULT_API)
    parser.add_argument("--module", default="ui")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    payload = json.loads(args.api_json.read_text(encoding="utf-8"))
    failures = validate(payload, args.module)
    report = {"module": args.module, "total": len(entries(payload, args.module)), "failures": failures}
    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    elif failures:
        print("\n".join(failures))
    else:
        print(f"[OK] canonical {args.module} inventory: {report['total']} entries")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
