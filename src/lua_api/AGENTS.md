# Lua API Contract

Covers work under `src/lua_api/`.

## Mission
- Own the `lurek.*` API surface, binding docstrings, registrations, and generated API artifacts.
- Keep the public Lua contract stable, thin, and consistent.

## Scope
- `src/lua_api/*_api.rs` files and their registrations.
- `lurek.*` naming, defaults, callable shapes, and generated API output.

## Local map
- `register.rs` is the module registration hub.
- `mod.rs` should stay export-only.
- `lua_module.rs` and `lua_types.rs` hold shared helpers and conversions.
- `callback_registry.rs` owns callback lifetime.
- `engine_api.rs` and `system_api.rs` shape top-level `lurek.*` behavior.

## Rules
- Keep files thin: registration, conversions, `LuaUserData`, and boundary validation only.
- Validate argument ranges and shapes at the Lua boundary.
- Clamp or reject integer casts and enum-like strings before values enter domain modules.
- Keep names, defaults, and return shapes aligned with existing `lurek.*` patterns.
- Move domain logic into `src/`.
- Do not hand-edit generated API docs.
- Use short docstrings that match the actual callable contract.
- Persist callbacks with `lua.create_registry_value(...)`; do not let a borrowed `LuaFunction` escape the call stack.
- Wrap handles or shared references in exposed `UserData`, not raw engine structs.
- Keep `LuaUserData::add_methods` registration-only.
- Lua-visible runtime errors should name the failing `lurek.<module>.<function>` call when practical.

## Workflow
- Read the nearest Rust module and specs before touching binding code.
- Update docstrings in `*_api.rs`, regenerate docs, and sync examples when the API changes.
- Wire new API files through `mod.rs` and `register.rs` in the same task.
- Check coverage and examples for any public surface addition or signature change.

## References
- `src/`
- `docs/specs/`
- `content/examples/`
- `tests/lua/`
