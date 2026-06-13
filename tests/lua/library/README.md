# tests/lua/library - Lua Library Tests

One canonical test file per `library/` module.

## Naming

`test_<library>_library.lua` - for example `test_battle_library.lua` and `test_inventory_library.lua`

## Coverage

These tests exercise the library module public API using only `lurek.*` engine primitives.
Do not depend on Rust internals from library test code.

## Harness

Dispatched by `tests/lua_tests.rs` through `tests/lua_tests.rs`, one `#[test]` per canonical file.
