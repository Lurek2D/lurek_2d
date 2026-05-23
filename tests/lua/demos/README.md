# Headless demo contract tests

One `test_<slug>.lua` per showcase/arcade demo that also has a screenshot smoke entry in `tests/demo_smoke_tests.rs`.

## Pattern

1. `dofile("tests/lua/demos/_common_checks.lua")` for shared helpers.
2. Static analysis of `content/games/.../main.lua` (lifecycle callbacks, config sanity).
3. `test_summary()` as the last line.

Colocated `content/games/**/test.lua` files are still discovered by `lua_demo_colocated_games` in `harness.rs`. This folder centralizes the screenshot-smoke demo set.

## Regenerate

```powershell
python tools/audit/gen_demo_lua_tests.py
```

## Run

```powershell
cargo test --test lua_tests lua_demos_headless_all -- --test-threads=1
```
