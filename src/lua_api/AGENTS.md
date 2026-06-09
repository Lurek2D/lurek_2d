# Lua API Contract

This file adds local rules for work under `src/lua_api/`.

## Mission
- Own the `lurek.*` API surface, binding docstrings, registrations, and generated API artifacts.
- Keep the public Lua contract stable, thin, and consistent.

## Scope
- `src/lua_api/*_api.rs` files and their registrations.
- `lurek.*` naming, defaults, and callable shapes.
- Generated docs, examples, and API validation output.

## Local map
- `register.rs` is the module registration hub; check it whenever a new `*_api.rs` file should become reachable from Lua.
- `mod.rs` should stay export-only.
- `lua_module.rs` and `lua_types.rs` hold shared binding helpers and conversions; reuse them before inventing local glue.
- `callback_registry.rs` is the callback ownership seam; changes there have cross-module lifetime impact.
- `engine_api.rs` and `system_api.rs` are foundation-level touchpoints and deserve extra care because they shape top-level `lurek.*` behavior.
- Keep `*_api.rs` names aligned with the corresponding engine module and spec whenever the API mirrors a top-level subsystem.

## Local rules
- Keep files thin: registration, conversions, `LuaUserData`, and boundary validation only.
- Validate argument ranges and shapes at the Lua boundary.
- Validate integer casts, enum-like strings, and boundary-only clamps before values enter domain modules.
- Keep names, defaults, and return shapes consistent with existing `lurek.*` patterns.
- Move domain logic into `src/`.
- Avoid ad hoc API novelty; follow nearby `lurek.*` conventions first.
- Do not hand-edit generated API docs.
- Prefer explicit, short docstrings that reflect the actual callable contract.
- Persist callbacks with `lua.create_registry_value(...)` and never let a borrowed `LuaFunction` escape the current call stack.
- Exposed `UserData` should wrap handles or shared references, not raw engine structs with fragile lifetimes.
- Keep `LuaUserData::add_methods` side-effect free: registration only, no lazy global mutation.
- Lua-visible runtime errors should name the failing `lurek.<module>.<function>` call when practical.
- Run generators and validators after contract changes.

## Workflow
- Read the nearest Rust module and specs before touching binding code.
- Use this file plus the matching `src/` and `docs/specs/` contracts as the source of truth for API-boundary work.
- Update docstrings in `*_api.rs`, regenerate docs, and sync examples when the API changes.
- If a new API file is added, wire it through `mod.rs` and `register.rs` in the same task.
- Check coverage and examples for any public surface addition or signature change.

## Expected outputs
- Binding changes with regenerated docs.
- Updated examples and migration notes when needed.
- Validation proof for the touched API surface.

## Anti-patterns
- Put business logic in the binding layer.
- Use loose conversions that hide invalid Lua inputs.
- Change the public shape without regenerating docs or examples.

## References
- `src/`
- `docs/specs/`
- `content/examples/`
- `tests/lua/`
