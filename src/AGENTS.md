# Src Contract

Adds local rules for `src/`.

## Mission & Scope
- Own the Rust engine runtime, including render, physics, audio, assets, and windowing.
- Keep the Lua-to-Rust binding edge (`src/lua_api/`) thin. Keep gameplay logic and state in Rust modules under `src/`.
- Maintain decoupled module boundaries and narrow test seams without exposing internal data.

## Files
- `lib.rs`: Entrypoint library exposing engine subsystems.
- `main.rs`: Standalone binary that boots the window, graphics, and event loop.
- `lua_api/`: Binding layer exposing the public `lurek.*` namespaces.
- `app/` / `runtime/`: App orchestration and execution frameworks.

## Rules
- Do not add `#[cfg(test)]` to files under `src/`.
- Do not hold mutable borrow locks (`borrow_mut()`) on shared state across mlua callbacks or yielding frames.
- Use `pub(crate)` to expose test seams and document the invariant.
- Document any `unsafe` block with a clear, verifiable `// SAFETY:` invariant comment.
- Keep `mod.rs` files strictly export-only; do not write business logic or types directly inside them.
- Ensure all mlua-crossing closures handle errors gracefully and return `mlua::Result` instead of panicking.

## Workflow
- Run local unit tests with `cargo test` and code checks with `cargo clippy -- -D warnings`.
- If an mlua binding signature is changed, rebuild all public interfaces via `python tools/gen_all_docs.py`.

## References
- docs/specs/
- tests/rust/
- src/lua_api/
