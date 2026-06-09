# Src Contract

Covers work under `src/`.

## Mission & Scope
- Own the Rust engine runtime codebase, including the renderer, physics, audio, asset manager, and main window.
- Keep the Lua-to-Rust binding edge (`src/lua_api/`) thin; keep gameplay logic and state management inside dedicated Rust modules in `src/`.
- Maintain decoupled internal module boundaries and narrow testability seams without exposing internal data structures.

## Files
- `lib.rs`: Entrypoint library exposing subsystems to the main runner.
- `main.rs`: Standalone binary bootstrapping the game window, graphics context, and event loop.
- `lua_api/`: Binding layer exposing the public `lurek.*` namespaces.
- `app/` / `runtime/`: Application core orchestrators and execution frameworks.

## Rules
- Do not add `#[cfg(test)]` to files under `src/`.
- Do not hold mutable borrow locks (`borrow_mut()`) on shared state across mlua callbacks or yielding frames.
- Use `pub(crate)` visibility to expose test seams and document the testing invariant.
- Document any `unsafe` block with a clear, verifiable `// SAFETY:` invariant comment.
- Keep `mod.rs` files strictly export-only; do not write business logic or types directly inside them.
- Ensure all mlua-crossing closures handle errors gracefully and return `mlua::Result` instead of panicking.

## Workflow
- Run local unit tests using `cargo test` and format using `cargo clippy -- -D warnings`.
- If an mlua binding signature is changed, rebuild all public interfaces via `python tools/gen_all_docs.py`.

## References
- docs/specs/
- tests/rust/
- src/lua_api/
