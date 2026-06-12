# Tests Contract

Adds local rules for `tests/`.

## Mission & Scope
- Own test strategy, validation harnesses, and coverage rules.
- Enforce Lua-first testing for public `lurek.*` APIs and Rust tests for internal engine code.
- Maintain regression suites, smoke runners, and asset checks.

## Files
- `lua_reorg/`: canonical Lua test tree with per-module and per-category files.
- `rust/`: Rust-specific unit tests verifying engine internal logic.
- `fixtures/`: Static assets for deterministic validation.
- `artifacts/current/`: Current generated evidence artifacts.
- `artifacts/baselines/`: Committed golden baselines referenced by golden tests.
- `demo_smoke_tests.rs` / `games_load_test.rs`: Root integration tests for demo load paths.

## Rules
- Direct all public API tests to the Lua layer; do not test `lurek.*` features using Rust unit test files.
- If a behavior is reachable from `lurek.*`, keep canonical coverage in `tests/lua_reorg/unit/`. Reserve `tests/rust/unit/` for private seams, helper logic, and wrapper glue.
- Keep `tests/lua_reorg/` as the canonical home for `lurek.*` tests.
- Keep `tests/rust/unit/` for internal Rust unit tests only.
- For Lua unit coverage, enforce exact ownership: `1 API = 1 unit it() = 1 directly-adjacent -- @covers`.
- Only Lua unit tests must reach `100%` public API coverage.
- Keep exactly one canonical unit file per module and category: `test_<module>_unit.lua`, `test_<modules>_integration.lua`, `test_<module>_stress.lua`, and similar category suffixes.
- Inside each canonical unit file, order tests as: public `lurek.<module>.*` functions first, then userdata/object method coverage for that module.
- Do not leave unit `it()` blocks without a directly preceding `-- @covers`.
- Do not put multiple `-- @covers` markers on one unit `it()` unless fixture setup makes the block intentionally shared and you are fixing structure later; canonical end state is still one owner API per `it()`.
- Do not duplicate the same `-- @covers` API across multiple Lua unit `it()` blocks.
- For canonical `stress` and `security` suites, enforce `1 API = 1 primary marker = 1 it()`.
- For canonical `evidence` suites, treat the file as an artifact generator, not as a correctness oracle. The `it()` block passes when it successfully produces the intended evidence artifact.
- For canonical `evidence` suites, allow one `it()` block to carry multiple directly-adjacent `-- @evidence` markers when that single artifact meaningfully demonstrates each marked API. Do not require marking every helper API used in the block.
- For canonical `evidence` suites, keep exactly one owning `test_<module>_evidence.lua` file per public module whenever the owner is known.
- For canonical `golden` suites, treat the file as a comparison test against a stored reference artifact or baseline captured earlier. The `it()` block passes only when the newly produced artifact matches the expected golden contract.
- For canonical `integration` suites, keep one file per module-pair or module-set and make `-- @integration` markers match the APIs actually exercised in each `it()` block.
- Put demos in `tests/lua_reorg/demos/`.
- Put demo screenshot smoke coverage in `tests/demo_smoke_tests.rs`. Keep Rust golden screenshots and other evidence in their current test-specific locations.
- Keep one top-level Lua artifact root only: `tests/artifacts/`.
- Write fresh evidence only under `tests/artifacts/current/`.
- Prefer module-owned evidence directories such as `tests/artifacts/current/ui/` or `tests/artifacts/current/procgen/`.
- Prefer descriptive evidence file names that state the artifact subject rather than generic buckets like `advanced`, `combined`, or `misc`.
- Store committed Lua golden baselines only under `tests/artifacts/baselines/`.
- Do not create or keep parallel Lua artifact roots such as `tests/output/`, `tests/samples/`, or `save/golden_text/`.
- Use one test file per module per layer: `test_<module>_<layer>.lua`.
- Keep tests deterministic; use epsilon ranges for floats.
- Register new Lua test suites inside `tests/lua_reorg_tests.rs`; `tests/lua_reorg_tests.rs` includes that canonical registration file for the default test target.
- Use explicit state assertions rather than side-effect checks when verifying frame changes.

## Workflow
- Run `cargo test`, then audit Lua ownership and structure with `python tools/audit/unit_test_api_coverage.py`, `python tools/audit/lua_nonunit_test_coverage.py`, and `python tools/audit/lua_test_structure_audit.py --path tests/lua_reorg/unit`.
- Rebuild committed Lua golden baselines from fresh evidence with `python tools/audit/reseed_lua_artifacts.py --clean` whenever evidence or golden paths change.
- Fill missing unit ownership module by module; complete one module to 100% before broadening to the next when doing coverage work.
- Treat these counts as the source of truth: total Lua APIs, APIs with exactly one unit owner test, APIs with no Lua unit owner test, and APIs duplicated across multiple Lua unit `it()` blocks. Lua artifact maintenance tools serialize baseline access through `tests/artifacts/.lua_artifacts.lock`; prefer the canonical scripts so audits do not read a half-reseeded baseline tree.

## References
- tests/lua_reorg/
- tests/rust/
- tools/audit/lua_api_test_coverage.py
