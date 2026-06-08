---
name: create-integration-test
description: "Create or update integration lua test combining 2 or more modules together."
---
# create-integration-test

## Goal
- Create comprehensive integration tests that verify the interaction and data flow between multiple modules.

## Required inputs
- List of modules to integrate (e.g., `physics` and `graphics`)
- Expected interaction behavior
- User must define which modules are interacting and the expected outcome
- Agent must collect API surfaces of all involved modules

## Profile hint
- `manager`

## Load these skills
- `testing-ecosystem`
- `lua-scripting`

## Steps
- Load skills: testing-ecosystem, lua-scripting.
- Execute `python tools/audit/integration_coverage.py` to identify missing links between the targeted modules.
- Write a Lua script under `tests/lua/integration/` that initializes and feeds output from Module A into Module B, asserting the final combined state.
- Execute `cargo test --test lua_tests` ensuring the integration folder is included in the test runner. If tests fail, fix the integration script.
- Re-run `python tools/audit/integration_coverage.py`. If the cross-module link still reports as uncovered (0%), return to step 3 and fix the test implementation.

## Outputs
- Integration test scripts in `tests/lua/integration/` (or similar appropriate path)
- Test execution summary

## Success criteria
- [ ] `cargo test --test lua_tests` exits with code 0.
- [ ] `python tools/audit/integration_coverage.py` reports exactly 100% integration coverage for the target module pair.

## Stop conditions
- Writing integration tests that mock the interaction layer.
- Coupling the test too tightly to the internal implementation of either module.

## References
- `skills: testing-ecosystem, lua-scripting`
- `tools: python tools/audit/integration_coverage.py`
- `agent: Tester`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

