---
name: create-test-lua
description: Create or update lua test for specific module and check test coverage.
---

# GOAL
- Create or update unit tests in Lua for a specific module to ensure its behavior is fully covered.

# INPUTS REQUIRED
- Module name
- Target functions or behaviors to test
= User must provide the scope of changes or the specific module
- Agent must collect current test coverage metrics and existing test files

# STEPS TO DO
1. Load skills: testing-rust, lua-scripting, quality-pipeline.
2. Execute `python tools/audit/test_coverage.py --module <module>` to get the baseline test coverage percentage.
3. Review the missing coverage areas identified by the script output.
4. Create or update `tests/lua/test_<module>_<layer>.lua`. Write test cases to cover the missing logic paths, including negative testing.
5. Execute `cargo test --test lua_tests` to verify that your new test cases compile and run successfully.
6. Execute `python tools/validate/cag_validate.py` to ensure the new files respect project constraints.
7. Execute `python tools/audit/test_coverage.py --module <module>` again to measure the new test coverage. If the output coverage is strictly less than 100%, repeat step 4 to write more tests until 100% coverage is achieved.

# OUTPUTS PROVIDED
- New or updated test files in `tests/lua/`
- Console output showing passed tests and updated coverage report

# SUCCESS CRITERIA
- `cargo test --test lua_tests` exits with code 0 (0 failed tests).
- `python tools/audit/test_coverage.py` reports exactly 100% test coverage for the target module.
- `python tools/validate/cag_validate.py` returns exactly 0 validation errors.

# ANIT PATTERNS
- Writing tests that test implementation details instead of the public API.
- Skipping negative or boundary condition tests.
- Modifying module source code within this prompt.

# REFERENCES
- skills: testing-rust, lua-scripting, quality-pipeline
- tools: python tools/validate/cag_validate.py, python tools/audit/test_coverage.py
- agent: Tester
