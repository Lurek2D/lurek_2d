---
name: testing-ecosystem
description: "Load this skill when writing or reviewing Rust unit tests, Lua API tests, Lua game logic tests, or test coverage rules. Skip it for feature implementation or non-test game scripting."
---
# testing-ecosystem

## Use when
- Writing Rust unit tests for internal code in tests/rust/unit/
- Writing Lua tests for lurek.* API surface in tests/lua/
- Understanding which test layer to use for a given behaviour
- Checking test coverage metrics

## Avoid when
- Implementing features -> use rust-coding skill
- Lua scripting unrelated to tests -> use lua-scripting skill

## Repo rules
- Lua-first split: behavior reachable through `lurek.*` belongs in `tests/lua/unit/test_<module>_<layer>.lua`, Rust-only private internals in `tests/rust/unit/<module>_tests.rs`. When in doubt, the Lua layer is preferred â€” if it can be tested via the public API, it must be.
- Never put `#[cfg(test)]` in `src/`. Every test that uses `src/` code but is about private internals lives in `tests/rust/unit/<module>_tests.rs` as a separate binary target.
- File naming is enforced: Rust test files are `<module>_tests.rs`, Lua unit test files are `test_<module>_<layer>.lua`. A file that does not follow the naming convention is not discoverable by `parallel_cargo.py` or the Lua harness.
- Lua test file structure: each file ends with `test_summary()` and every test case uses `assert_equal`, `assert_true`, `assert_near`, or `assert_error` from the harness â€” not bare `assert()`. Missing `test_summary()` means the harness reports 0 tests, not a pass.
- New Lua test files must be registered in `tests/lua/harness.rs` under the correct suite. New Rust test binaries must be added to `Cargo.toml` as `[[test]]` targets with the correct `name` and `path`.
- Float comparison: use `assert_near(a, b, epsilon)` always. Direct `==` on floats in tests is a defect â€” CI will catch it intermittently on different build profiles or OS.
- Determinism checklist: fixed random seed, fixed `dt` value, no filesystem reads outside `tests/fixtures/`, no wall-clock time, no window.
- Test granularity: one failing reason per test. `test_body_position_after_one_step()` tests exactly that.
- Evidence strength: prefer state-readback assertions over side-effect checks. `assert_equal(body.position.x, 5.0)` is stronger than `assert_true(on_contact_called)`.
- After adding tests, run `python tools/audit/test_coverage.py` and `python tools/audit/lua_api_test_coverage.py` to confirm that coverage registration matches the touched suite.
- Folder marker rules:
- `tests/lua/unit/` -> `-- @covers ...`
- `tests/lua/security/` -> `-- @security ...`
- `tests/lua/integration/` -> `-- @integration ...`
- `tests/lua/stress/` -> `-- @stress ...`
- `tests/lua/evidence/` -> `-- @evidence ...`
- Marker lines must sit directly above the `it()` they annotate and be indented exactly like that `it()`.
- For `@covers` in unit tests: mark only symbols that are called and assertion-backed in that same `it()`.
- `-- @tests` is **forbidden**.
- Manual cleanup workflow for existing suites:
- Work in batches of **max 3 Lua files**.
- Read each file fully before editing.
- Apply **manual** marker corrections.
- After each 3-file batch, run `python tools/audit/lua_test_structure_audit.py --path <file>` for each touched file and proceed only if all pass.
- Use helper scripts only for detection/reporting, not for blind mass edits.
- Demo tests go in `tests/lua/demos/test_<name>.lua` and `tests/demo_smoke_tests.rs` â€” not in `tests/lua/unit/`. Optional colocated `content/games/**/test.lua` files run via `lua_demo_colocated_games`.

## Checks
- `python tools/audit/test_coverage.py`
- `python tools/audit/lua_test_structure_audit.py --path <file>`

## References
- `tests/lua/`
- `tests/rust/unit/`
- `tools/audit/test_coverage.py`
- `tools/audit/lua_api_test_coverage.py`

