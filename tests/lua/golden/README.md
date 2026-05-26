# tests/lua/golden — Lua Golden Tests

Deterministic output tests. The Lua script produces a known string or value and it is asserted to match exactly.

## Purpose

- Catch accidental changes to serialization, formatting, or math output
- Complement Rust golden tests in `tests/rust/golden/`

## Harness

Dispatched by `tests/lua/harness.rs` — one `#[test]` per file.
