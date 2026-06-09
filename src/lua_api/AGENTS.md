# Lua API Contract

Covers work under `src/lua_api/`.

## Mission & Scope
- Manage the public `lurek.*` Lua API surface.
- Maintain API registration, documentation string generation, types conversion, and Lua-to-Rust binding boundaries.

## Files
- `mod.rs`: Defines the module entry point, public structures, and visibility boundaries.
- Peer implementation files: Contain the concrete logic, algorithms, and local structures.

## Rules
- Keep binding files thin; restrict content to registration, conversions, `LuaUserData` implementations, and parameter validation.
- Validate argument ranges, patterns, and sizes at the Lua boundary before parsing.
- Clamp or reject integer casts and enum-like strings at the entry boundary.
- Do not use Lua type casts here. Use `any` in Rust bindings if a looser type is needed.
- Keep naming conventions, default parameters, and returns consistent with `lurek.*` specs.
- Do not manually edit generated Lua documentation files (`docs/api/lurek.lua`).
- Use concise docstrings matching the actual Rust-exposed callable signature.
- Persist script callbacks using `lua.create_registry_value(...)`; do not let borrowed `LuaFunction` handles escape the call stack.
- Wrap internal engine indices or shared handles in exposed `UserData`, never raw Rust structs.
- Maintain `LuaUserData::add_methods` as registration-only blocks without embedded logic.
- Include the exact name of the failing `lurek.<module>.<method>` in runtime errors when raising exceptions.

## Workflow
- Run `python tools/gen_all_docs.py` after editing docstrings to regenerate the Lua definitions.
- Verify API changes against both unit tests and example projects to check for typing issues.

## References
- src/lua_api/register.rs
- src/lua_api/lua_types.rs
- src/lua_api/callback_registry.rs
