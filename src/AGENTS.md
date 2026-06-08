# Src Contract

This file adds local rules for work under `src/`.

## Mission
- Own the Rust engine code path: runtime, renderer, physics, audio, assets, and internal glue.
- Keep the engine layered and maintainable.
- Keep `src/lua_api/` thin and contract-only.

## Scope
- `src/` Rust modules, services, and internal runtime flow.
- `src/render/`, `src/physics/`, `src/audio/`, and other engine subsystems.
- Cross-module refactors that stay inside engine code.
- Narrow testability seams that do not widen the public API unnecessarily.

## Local map
- `lib.rs` is the shared crate surface; `main.rs` is the desktop entrypoint.
- `README.md` is the fastest local inventory of engine modules before browsing deeper.
- `lua_api/` is the binding edge; treat it as a downstream consumer of engine modules, not a place to move logic into.
- Runtime and platform flow live around `app/`, `runtime/`, `window/`, `input/`, `event/`, and `timer/`.
- Asset and persistence work usually lands in `asset/`, `filesystem/`, `serialize/`, and `save/`.
- Rendering and scene composition usually land in `render/`, `sprite/`, `tilemap/`, `ui/`, `layout/`, `camera/`, `effect/`, and `visibility/`.
- New public-facing modules should keep naming aligned across `src/<module>/`, `src/lua_api/<module>_api.rs`, and `docs/specs/<module>.md`.

## Local rules
- Find the root cause before broad refactors.
- Keep bindings thin and move business logic into engine modules.
- Do not hold `borrow_mut()` or equivalent shared-state borrows across Lua callbacks.
- Prefer explicit imports and narrow visibility.
- Prefer `pub(crate)` over broad `pub` when a seam exists only for tests.
- Avoid `unsafe` unless there is no safe alternative and the invariant is explicit.
- Keep `mod.rs` files export-only.
- When public behavior changes, update matching specs and tests in the same task.

## Workflow
- Read the nearest spec and tests before editing engine code.
- Load `rust-coding`, `error-handling`, and `module-architecture` when the task spans multiple files.
- Make the smallest edit that satisfies the gate.
- Validate with the narrowest relevant test or benchmark first, then the broader gate.
- If a change touches `lurek.*`, make sure `src/lua_api/` and generated docs stay in sync.

## Expected outputs
- Focused Rust code changes.
- Narrow validation proof.
- Spec sync when the contract changed.
- Clear notes on any boundary or borrow-risk decisions.

## Anti-patterns
- Move engine logic into binding files.
- Add new public surface before checking contract impact.
- Hold shared-state borrows across Lua callbacks.
- Do large refactors without a visible migration path.

## References
- `docs/specs/`
- `tests/rust/unit/`
- `tests/lua/`
- `src/lua_api/`
