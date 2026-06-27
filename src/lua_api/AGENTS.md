# Lua API Contract

## Mission & Scope
- Own the public `lurek.*` Lua API surface and Rust binding edge.
- Keep registration, docstrings, conversions, and error behavior consistent.

## Files
- `mod.rs`: Module entry point and visibility.
- Peer files: Registration, conversions, userdata, and local helpers.

## Rules
- Keep bindings thin: registration, conversion, `LuaUserData`, and validation only.
- Public binding additions must flow through generated Lua API data before updating examples or unit-test `@covers` markers.
- Validate ranges, patterns, sizes, casts, and enum-like strings at the boundary.
- Use `any` in Rust bindings when Lua needs a loose type; do not fake Lua casts.
- Match names, defaults, returns, and docstrings to `lurek.*` specs.
- Do not edit generated `docs/api/lurek.lua`.
- Store callbacks with `lua.create_registry_value(...)`.
- Expose handles as `UserData`, not raw Rust structs.
- Keep `LuaUserData::add_methods` registration-only.
- Include failing `lurek.<module>.<method>` names in runtime errors.

## Workflow
- Run `python tools/gen_all_docs.py` after docstring edits.
- Verify API changes with unit tests and example projects.
