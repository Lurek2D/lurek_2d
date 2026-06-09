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
- When debugging, start from an existing failing test, demo, or save fixture before reading large areas of `src/`.
- Keep bindings thin and move business logic into engine modules.
- Do not hold `borrow_mut()` or equivalent shared-state borrows across Lua callbacks.
- Prefer explicit imports and narrow visibility.
- Prefer `pub(crate)` over broad `pub` when a seam exists only for tests.
- If a `pub(crate)` seam exists only for tests, say so in the doc comment so it does not drift into public API by accident.
- Prefer `Path` and `PathBuf` semantics over hardcoded separators or platform-specific path strings.
- Avoid `unsafe` unless there is no safe alternative and the invariant is explicit.
- Every `unsafe` block needs a focused `// SAFETY:` comment that explains the exact invariant.
- Prefer `winit` or `wgpu` abstractions before introducing platform-specific `cfg` branches.
- If a `cfg` branch is necessary, keep it small and explain why it exists.
- Keep `mod.rs` files export-only.
- Closures that cross into Lua must return `mlua::Result` and attach module or call-site context before the error reaches scripts.
- When public behavior changes, update matching specs and tests in the same task.
- Common high-frequency bug classes here are borrow panics across Lua callbacks, stale registry state after reloads, callback ordering mistakes, skipped runtime init transitions, and dropped thread/channel results. Check those before assuming a novel failure mode.

## Workflow
- Read the nearest spec and tests before editing engine code.
- Use this file, the nearest spec, and the relevant architecture notes as the source of truth when the task spans multiple modules.
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
