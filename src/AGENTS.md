# Src Contract

## Mission & Scope
- Own the Rust engine runtime: render, physics, audio, assets, windowing, and runtime orchestration.
- Keep each subsystem in its own module. Child contracts define local rules.

## Files
- `lib.rs`: Module exports and shared engine entry points.
- `main.rs`: Desktop binary entry point.
- `lua_api/`: Public `lurek.*` binding layer.
- Other child folders: Engine subsystem owners.

## Rules
- Keep gameplay logic and state in Rust modules; keep `src/lua_api/` thin.
- Register new top-level modules in `docs/meta/modules.toml` unless a repo tool excludes them.
- Every `.rs` file needs `//!` docs for purpose, state, and boundaries. Follow `docs/contributing/rust-file-docstrings.md`.
- Public items and Lua-facing helpers need factual `///` docs.
- Do not add `#[cfg(test)]`, `mod tests`, or inline test fixtures under `src/`.
- Put private Rust tests under `tests/rust/`. Test public `lurek.*` behavior in Lua.
- Do not hold `borrow_mut()` locks across mlua callbacks or yielding frames.
- Add clear `// SAFETY:` comments for every `unsafe` block.
- Keep `mod.rs` export-only.
- Return `mlua::Result` across Lua boundaries instead of panicking.

## Workflow
- Run `cargo test` and `cargo clippy -- -D warnings`.
- If a binding signature changes, run `tools/python.cmd tools/gen_all_docs.py`.
