# Tests Contract

Adds local rules for `tests/`.

## Mission & Scope
- Own test strategy, validation harnesses, and coverage rules.
- Enforce Lua-first testing for public `lurek.*` APIs and Rust tests for internal engine code.
- Maintain regression suites, smoke runners, and asset checks.

## Files
- `lua/`: Lua unit and integration test scripts.
- `rust/`: Rust-specific unit tests verifying engine internal logic.
- `fixtures/` / `samples/`: Static assets for deterministic validation.
- `demo_smoke_tests.rs` / `games_load_test.rs`: Root integration tests for demo load paths.

## Rules
- Direct all public API tests to the Lua layer; do not test `lurek.*` features using Rust unit test files.
- If a behavior is reachable from `lurek.*`, keep canonical coverage in `tests/lua/unit/`. Reserve `tests/rust/unit/` for private seams, helper logic, and wrapper glue.
- Keep `tests/lua/` as the home for `lurek.*` tests.
- Keep `tests/rust/unit/` for internal Rust unit tests only.
- For Lua unit coverage, enforce exact ownership: `1 API = 1 unit it() = 1 directly-adjacent -- @covers`.
- Do not leave unit `it()` blocks without a directly preceding `-- @covers`.
- Do not put multiple `-- @covers` markers on one unit `it()` unless fixture setup makes the block intentionally shared and you are fixing structure later; canonical end state is still one owner API per `it()`.
- Do not duplicate the same `-- @covers` API across multiple Lua unit `it()` blocks.
- Put demos in `tests/lua/demos/`.
- Put demo screenshot smoke coverage in `tests/demo_smoke_tests.rs`. Keep Rust golden screenshots and other evidence in their current test-specific locations.
- Use one test file per module per layer: `test_<module>_<layer>.lua`.
- Keep tests deterministic; use epsilon ranges for floats.
- Register new Lua test suites inside `tests/lua/harness.rs` to wire them into the default test runners.
- Use explicit state assertions rather than side-effect checks when verifying frame changes.

## Workflow
- Run the full test suite with `cargo test`.
- Audit Lua unit API ownership with `python tools/audit/unit_test_api_coverage.py`.
- Treat these counts as the source of truth: total Lua APIs, APIs with exactly one unit owner test, APIs with no Lua unit owner test, and APIs duplicated across multiple Lua unit `it()` blocks.

## References
- tests/lua/
- tests/rust/
- tools/audit/lua_api_test_coverage.py
