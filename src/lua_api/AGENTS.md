# Lua API Contract

Adds local rules for `src/lua_api/`.

## Mission & Scope
- Manage the public `lurek.*` Lua API surface.
- Maintain API registration, docstrings, type conversion, and Lua-to-Rust boundaries.

## Files
- `mod.rs`: Defines the module entry point, public structures, and visibility boundaries.
- Peer files: Contain concrete logic, algorithms, and local structures.

## Rules
- Keep binding files thin; restrict content to registration, conversions, `LuaUserData` implementations, and parameter validation.
- Validate argument ranges, patterns, and sizes at the Lua boundary before parsing.
- Clamp or reject integer casts and enum-like strings at the entry boundary.
- Do not use Lua type casts here. Use `any` in Rust bindings if a looser type is needed.
- Keep naming conventions, default parameters, and returns consistent with `lurek.*` specs.
- Do not manually edit generated Lua documentation files (`docs/api/lurek.lua`).
- Use concise docstrings matching the actual Rust-exposed callable signature.
- Persist script callbacks with `lua.create_registry_value(...)`; do not let borrowed `LuaFunction` handles escape the call stack.
- Wrap internal engine indices or shared handles in exposed `UserData`, never raw Rust structs.
- Keep `LuaUserData::add_methods` registration-only.
- Include the exact name of the failing `lurek.<module>.<method>` in runtime errors when raising exceptions.

## Workflow
- Run `python tools/gen_all_docs.py` after editing docstrings to regenerate the Lua definitions.
- Verify API changes against both unit tests and example projects to check for typing issues.

## References
- src/lua_api/register.rs
- src/lua_api/lua_types.rs
- src/lua_api/callback_registry.rs
