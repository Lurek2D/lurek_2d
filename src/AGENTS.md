# Src Contract

## Mission & Scope
- Own the Rust engine runtime: render, physics, audio, assets, windowing, and runtime orchestration.
- Keep modules decoupled and Lua-facing behavior synced with specs.

## Files
- `lib.rs`: Engine subsystem entry point.
- `main.rs`: Standalone app boot path.
- `lua_api/`: Public `lurek.*` binding layer.
- `app/`, `runtime/`: App and execution frameworks.

## Rules
- Keep gameplay logic and state in Rust modules; keep `src/lua_api/` thin.
- New top-level `src/<module>/` owners need matching `docs/meta/modules.toml`, `docs/specs/<module>.md`, example, and Lua unit-test registry entries unless intentionally excluded by tools.
- Every `.rs` file needs `//!` file docs stating purpose, owned state, and boundary.
- Follow `docs/architecture/rust_file_docstring_guidelines.md` for qualitative file-level `//!` writing rules.
- Public structs, enums, fields, methods, and Lua-facing helpers need factual `///` docs.
- Method docs must state units, defaults, bounds, errors, and side effects when relevant.
- Do not add `#[cfg(test)]`, `mod tests`, or inline test fixtures under `src/`.
- Put Rust tests in `tests/rust/unit|ext|golden` and public API tests in Lua.
- Do not hold `borrow_mut()` locks across mlua callbacks or yielding frames.
- Use `pub(crate)` for test seams and document the invariant.
- Add clear `// SAFETY:` comments for every `unsafe` block.
- Keep `mod.rs` export-only.
- Return `mlua::Result` across Lua boundaries instead of panicking.

## Workflow
- Run `cargo test` and `cargo clippy -- -D warnings`.
- If a binding signature changes, run `python tools/gen_all_docs.py`.
