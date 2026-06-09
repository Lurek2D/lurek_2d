# Tests Contract

This file adds local rules for work under `tests/`.

## Mission
- Own the repository testing strategy and file placement.
- Keep Lua-first coverage for `lurek.*` behavior.
- Keep Rust unit coverage for private engine details.

## Scope
- Lua-facing tests in `tests/lua/`.
- Rust internal tests in `tests/rust/unit/`.
- Harness registration and naming rules.
- Evidence artifacts, demos, and stress or integration coverage.

## Local map
- Root-level `demo_smoke_tests.rs`, `engine_tests.rs`, `examples_load_test.rs`, and `games_load_test.rs` are broad entry checks; do not use them as the first debugging loop when a narrow target exists.
- `lua/` holds the Lua-first contract layer, including `harness/`, `integration/`, `stress/`, `golden/`, `security/`, and per-domain directories such as `pathfind/` and `visibility/`.
- `rust/` is for internal Rust test layers; keep private engine checks there rather than in `src/`.
- `rust/` contains explicit Rust-only layers for unit, golden, config, security, and stress coverage with Cargo-registered binaries.
- `fixtures/` and `samples/` are reusable test inputs; prefer them over ad hoc inline data when the same scenario repeats.
- `output/` is evidence-oriented and disposable; do not treat it as product source.
- `python/` is for test-support tooling, not for replacing the main Lua or Rust test contracts.

## Local rules
- Prefer Lua tests first for behavior reachable through `lurek.*`.
- Keep private Rust internals in `tests/rust/unit/`.
- Use deterministic fixtures, fixed inputs, and one failure reason per test.
- Respect Lua marker, naming, and harness registration rules.
- Keep tests narrow and reproducible.
- Do not fix production code when the task is pure review or test authoring.
- Use state readback over side-effect-only assertions when possible.
- Keep float assertions tolerant and deterministic.
- New Lua test files must be registered in `tests/lua/harness.rs`; new Rust test binaries belong in `Cargo.toml`.
- Rust test filenames are `<module>_tests.rs`; Lua unit tests are `test_<module>_<layer>.lua`.
- For Lua harness failures, prefer `python tools/audit/parse_test_log.py` over scanning raw `cargo test` output by hand.
- If a bug investigation needs a new repro, make it deterministic first and keep it in the narrowest test layer that demonstrates the failure.

## Workflow
- Read the nearest spec and the production code path before picking the test layer.
- Use this file, `tests/lua/AGENTS.md`, and the relevant source contract as the authority for test placement and coverage work.
- Register new Lua or Rust test files in the correct harness or Cargo manifest.
- Run the narrowest relevant test target first, then the layer-level checks.

## Expected outputs
- Correctly placed tests with narrow execution proof.
- Harness or Cargo registration updates when required.
- Coverage or evidence notes when the work touches gaps.

## Anti-patterns
- Put tests inside `src/`.
- Cover `lurek.*` behavior only from Rust when a Lua test is possible.
- Mix unrelated failure reasons in one test.

## References
- `tests/lua/`
- `tests/rust/unit/`
- `tools/audit/test_coverage.py`
- `tools/audit/lua_api_test_coverage.py`
