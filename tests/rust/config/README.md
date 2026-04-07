# tests/rust/config — Config Tests

Tests for `Config` loading, validation, and field defaults.

## Naming

`config_tests.rs` — `conf_lua_<scenario>_<expected>`

## Coverage

- `conf.lua` happy path
- Missing fields → safe defaults
- Invalid types → descriptive error
- Feature-flag combinations

## Registration

All binaries registered in `Cargo.toml` under `[[test]]`.
