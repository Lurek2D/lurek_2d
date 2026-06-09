# Tests Contract

Covers work under `tests/`.

## Mission & Scope
- Own the repository's test execution strategies, validation harnesses, and test coverage rules.
- Enforce the "Lua-first" testing convention for public `lurek.*` namespaces and Rust unit testing for internal engine packages.
- Maintain regression test suites, smoke test runners, and asset loading verification systems.

## Files
- `lua/`: Lua unit and integration test scripts.
- `rust/`: Rust-specific unit tests verifying engine internal logic.
- `fixtures/` / `samples/`: Static input assets used for deterministic validation checks.
- `demo_smoke_tests.rs` / `games_load_test.rs`: Root-level integration tests checking demo load paths.

## Rules
- Direct all public API tests to the Lua layer; do not test `lurek.*` features using Rust unit test files.
- If a behavior is reachable from `lurek.*`, keep the canonical coverage in `tests/lua/unit/` and reserve `tests/rust/unit/` for private Rust seams, helper logic, and wrapper-only glue.
- Keep `tests/lua/` as the home for `lurek.*` tests.
- Keep `tests/rust/unit/` for internal Rust unit tests only.
- Put demos in `tests/lua/demos/`.
- Put demo screenshot smoke coverage in `tests/demo_smoke_tests.rs`; keep Rust golden screenshots and other evidence in their existing test-specific locations.
- Use one test file per module per layer: `test_<module>_<layer>.lua`.
- Keep test executions completely deterministic; float checks must use epsilon tolerance ranges.
- Register new Lua test suites inside `tests/lua/harness.rs` to wire them into the default test runners.
- Use explicit state assertions rather than side-effect checks when verifying frame changes.

## Workflow
- Run the full test suite using `cargo test` and verify format correctness.
- Audit public Lua API test coverage by running `python tools/audit/lua_api_test_coverage.py`.

## References
- tests/lua/
- tests/rust/
- tools/audit/lua_api_test_coverage.py
