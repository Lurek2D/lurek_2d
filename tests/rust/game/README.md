# tests/rust/game — Retired Game Tests

> **Status: RETIRED** — Game system logic has moved to Lunasome `library/` (Tier 3 pure-Lua).
> New tests for game systems belong in `tests/lua/library/`.

## History

This directory held Rust integration tests for game-like features (AI, minimap) that were migrated to pure-Lua libraries.
Two active tests remain while migration is in progress:

- `ai_tests.rs` — AI module Rust tests (pending Lua library migration)
- `minimap_tests.rs` — Minimap module Rust tests (pending Lua library migration)

## Policy

Do not add new test files here. Add new game system tests to `tests/lua/library/`.
