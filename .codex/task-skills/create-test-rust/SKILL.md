---
name: create-test-rust
description: "Create or update rust test for specific module and check test coverage."
---
# create-test-rust

## Goal
- Write or update Rust unit tests for internal logic and internal systems of a specific module.

## Required inputs
- Rust module path (e.g., `src/physics`)
- Internal structures or functions to test
- User must provide the module path and the specific behavior to test
- Agent must collect the internal implementation details and existing Rust tests

## Profile hint
- `tester`

## Load these skills
- `testing-ecosystem`
- `rust-coding`

## Steps
- Load skills: testing-ecosystem, rust-coding.
- Execute `cargo test --package lurek2d --test unit_tests` to gather baseline pass rates and ensure the workspace is currently clean.
- Navigate to `tests/rust/unit/` corresponding to the target module. Add `#[test]` functions covering the missing internal logic.
- Execute `cargo test --package lurek2d --test unit_tests` to isolate and verify the newly written tests. If the test runner reports any test failures, return to step 3 and fix the test assertions or module code.
- Execute `cargo clippy -- -D warnings` to verify test code quality and ensure no `#[cfg(test)]` leaked into `src/`.

## Outputs
- Updated or newly created `tests/rust/unit/` files
- Successful `cargo test` execution log

## Success criteria
- [ ] `cargo test` exits with code 0 (100% of the unit tests pass).
- [ ] `cargo clippy -- -D warnings` exits with code 0 (0 warnings or errors).
- [ ] 0 instances of `#[cfg(test)]` are found inside `src/`.

## Stop conditions
- Placing tests inside `src/` modules using `#[cfg(test)]`.
- Testing Lua APIs via Rust unit tests (Lua APIs should be tested via Lua).

## References
- `skills: testing-ecosystem, rust-coding`
- `tools: cargo test, cargo clippy`
- `agent: Tester`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

