# Src Contract

Covers work under `src/`.

## Mission
- Own the Rust engine path: runtime, renderer, physics, audio, assets, and internal glue.
- Keep `src/lua_api/` thin and contract-only.

## Scope
- `src/` Rust modules, services, and internal runtime flow.
- Engine subsystems and cross-module refactors that stay inside engine code.
- Narrow testability seams that do not widen the public API.

## Local map
- `lib.rs` is the shared crate surface; `main.rs` is the desktop entrypoint.
- `lua_api/` is the binding edge.
- `app/`, `runtime/`, `window/`, `input/`, `event/`, and `timer/` cover runtime and platform flow.
- `asset/`, `filesystem/`, `serialize/`, and `save/` cover asset and persistence work.
- `render/`, `sprite/`, `tilemap/`, `ui/`, `layout/`, `camera/`, `effect/`, and `visibility/` cover rendering and scene composition.

## Nested contracts
- Keep `docs/specs/<module>.md` as the default contract layer for top-level `src/<module>/` directories.
- Add a nested `AGENTS.md` only when a subtree has durable, module-specific rules that are not already covered by the spec and would otherwise be rediscovered on repeat work.
- The current intentional exceptions are `src/lua_api/`, `src/runtime/`, `src/render/`, `src/thread/`, `src/filesystem/`, `src/log/`, and `src/ai/`.
- If a nested contract is added or removed, keep the matching spec, examples, and coverage in sync in the same task.

## Rules
- Find the root cause before broad refactors.
- Start from a failing test, demo, or save fixture before reading large areas.
- Keep bindings thin and move logic into engine modules.
- Do not hold `borrow_mut()` or equivalent across Lua callbacks.
- Prefer explicit imports and narrow visibility.
- Use `pub(crate)` for test-only seams and say so in the doc comment.
- Prefer `Path` and `PathBuf` over hardcoded separators.
- Avoid `unsafe`; if needed, add a focused `// SAFETY:` comment with the exact invariant.
- Keep `mod.rs` export-only.
- Lua-crossing closures must return `mlua::Result` and add context before the error reaches scripts.
- When public behavior changes, update matching specs and tests in the same task.
- Common bug classes here are borrow panics across Lua callbacks, stale registry state after reloads, callback ordering mistakes, skipped runtime init transitions, and dropped thread or channel results.

## Workflow
- Read the nearest spec and tests before editing engine code.
- Use this file, the nearest spec, and the relevant architecture notes as the source of truth.
- Make the smallest edit that satisfies the gate.
- Validate with the narrowest relevant test or benchmark first, then the broader gate.
- If a change touches `lurek.*`, keep `src/lua_api/` and generated docs in sync.

## References
- `docs/specs/`
- `tests/rust/unit/`
- `tests/lua/`
- `src/lua_api/`
