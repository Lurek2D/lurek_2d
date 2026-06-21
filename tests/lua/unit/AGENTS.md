# Lua Unit Contract

## Mission & Scope
- Own the canonical behavioral proof for the full public `lurek.*` API.
- Keep this folder at 100% explicit `@covers` coverage.

## Files
- `test_<module>_unit.lua`: Canonical unit owner for one public module.

## Rules
- One file per module: `test_<module>_unit.lua`.
- One API = one `it()` = one directly-adjacent `-- @covers`.
- Put every assertion needed for that API inside its owning `it()` block.
- Do not split one API across multiple unit tests.
- Do not leave helper-only `it()` blocks in this folder.
- Test namespace functions first, then userdata/object methods for that same module.

## Workflow
- Run `tools/python.cmd tools/audit/unit_test_api_coverage.py`.
- Run `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Run `cargo test --test lua_tests`.
