# Rust Tests Contract

## Mission & Scope
- Own Rust-side tests for private engine behavior and Lua-unreachable seams.
- Keep these tests narrow, deterministic, and headless in normal Cargo flows.

## Files
- `unit/`: Crate-level private helper and module tests.
- `golden/`: Deterministic snapshot tests.
- `fixtures/`: Checked-in data and configs.

## Rules
- Keep Rust unit files under `tests/rust/unit/` with `_tests.rs` suffix.
- Do not test public `lurek.*` behavior here when Lua can verify it.
- Public Rust methods that are exposed through Lua belong in Lua unit coverage, not Rust unit coverage.
- Rust unit coverage does not need to be 100%; it exists only where private seams need direct proof.
- Use Rust tests for private internals, wrapper glue, and serialization.
- Use golden tests only for deterministic structures such as coordinates or static TOML layouts.
- Use checked-in fixtures; do not download files or depend on global resources.

## Workflow
- Run targeted tests with `cargo test --test <name>`.
- Run `cargo clippy --all-targets -- -D warnings`.
