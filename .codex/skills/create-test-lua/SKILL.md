---
name: create-test-lua
description: "Create or update lua test for specific module and check test coverage."
---
# create-test-lua

## Goal
- Create or update unit tests in Lua for a specific module to ensure its behavior is fully covered.

## Required inputs
- Module name
- Target functions or behaviors to test
- User must provide the scope of changes or the specific module
- Agent must collect current test coverage metrics and existing test files

## Profile hint
- `tester`

## Read these contracts
- `tests/AGENTS.md`
- `tests/lua/AGENTS.md`
- `content/AGENTS.md`

## Steps
- Read the listed contracts before writing the test.
- Execute `python tools/audit/test_coverage.py --module <module>` to get the baseline test coverage percentage.
- Review the missing coverage areas identified by the script output.
- Create or update the matching Lua test under `tests/lua/` using the existing `unit`, `integration`, `demos`, `stress`, or `library` conventions as appropriate for the target module.
- Execute `cargo test --test lua_tests` to verify that the new test cases compile and run successfully.
- Execute `python tools/validate/cag_validate.py` to ensure the new files respect project constraints.
- Execute `python tools/audit/test_coverage.py --module <module>` again to measure the new test coverage. If the output coverage is below 100%, add the missing cases and rerun the audit.

## Outputs
- New or updated test files in `tests/lua/`
- Console output showing passed tests and updated coverage report

## Success criteria
- [ ] `cargo test --test lua_tests` exits with code 0 (0 failed tests).
- [ ] `python tools/audit/test_coverage.py` reports exactly 100% test coverage for the target module.
- [ ] `python tools/validate/cag_validate.py` returns exactly 0 validation errors.

## Stop conditions
- Writing tests that test implementation details instead of the public API.
- Skipping negative or boundary condition tests.
- Modifying module source code within this prompt.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: python tools/validate/cag_validate.py, python tools/audit/test_coverage.py`
- `agent: Tester`


