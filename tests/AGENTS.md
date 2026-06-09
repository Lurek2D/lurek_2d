# Tests Contract

Covers work under `tests/`.

## Mission
- Own the repository testing strategy and file placement.
- Keep Lua-first coverage for `lurek.*` behavior and Rust unit coverage for private engine details.

## Scope
- `tests/lua/`, `tests/rust/`, and root-level test binaries.
- Harness registration, naming rules, evidence artifacts, demos, and stress or integration coverage.

## Local map
- Root `demo_smoke_tests.rs`, `engine_tests.rs`, `examples_load_test.rs`, and `games_load_test.rs` are broad checks.
- `lua/` is the Lua-first contract layer.
- `rust/` holds internal Rust test layers.
- `fixtures/` and `samples/` are reusable test inputs.
- `output/` is disposable evidence.
- `python/` is test-support tooling.

## Rules
- Prefer Lua tests first for behavior reachable through `lurek.*`.
- Keep private Rust internals in `tests/rust/unit/`.
- Use deterministic fixtures, fixed inputs, and one failure reason per test.
- Respect Lua marker, naming, and harness registration rules.
- Do not fix production code when the task is pure review or test authoring.
- Use state readback over side-effect-only assertions when possible.
- Keep float assertions tolerant and deterministic.
- Register new Lua test files in `tests/lua/harness.rs` and new Rust test binaries in `Cargo.toml`.
- Rust test filenames are `<module>_tests.rs`; Lua unit tests are `test_<module>_<layer>.lua`.
- For Lua harness failures, use `python tools/audit/parse_test_log.py`.
- Keep new repros deterministic and in the narrowest test layer that shows the failure.

## Workflow
- Read the nearest spec and production code path before picking the test layer.
- Use this file, `tests/lua/AGENTS.md`, and the relevant source contract as the authority for test placement and coverage work.
- Register new Lua or Rust test files in the correct harness or Cargo manifest.
- Run the narrowest relevant test target first, then the layer-level checks.

## References
- `tests/lua/`
- `tests/rust/unit/`
- `tools/audit/test_coverage.py`
- `tools/audit/lua_api_test_coverage.py`
