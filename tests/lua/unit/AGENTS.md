# Lua Unit Contract

## Mission & Scope
- Own the canonical behavioral proof for the full public `lurek.*` API.
- Keep this folder at 100% explicit `@covers` coverage.

## Files
- `test_<module>_unit.lua`: Canonical unit owner for one public module.

## Rules
- Each `it()` has one directly-adjacent marker. Use `-- @covers <generated-lua-name>` for the canonical owner; use `-- @covers-case <generated-lua-name>` for an additional regression/edge-case block that must not claim a second owner.
- The `-- @covers` symbol must match a known generated Lua API name; object methods use the generated `lua_name`.
- Keep marker indentation identical to the following `it()` line.
- Do not leave helper-only `it()` blocks in this folder.
- Keep the plain file header, `-- @describe` markers, and final bare `test_summary()` structure required by `lua_test_structure_audit.py`.

## Workflow
- Run `tools/python.cmd tools/audit/unit_test_api_coverage.py`.
- Run `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Run `cargo test --test lua_tests`.
