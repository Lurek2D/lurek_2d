# tests/lua_reorg/golden — Lua Golden Tests

Deterministic output tests. The Lua script produces a known string or value and it is asserted to match exactly.

## Purpose

- Catch accidental changes to serialization, formatting, or math output
- Complement Rust golden tests in `tests/rust/golden/`

## Harness

Dispatched by `tests/lua_reorg_tests.rs` — one `#[test]` per file.
