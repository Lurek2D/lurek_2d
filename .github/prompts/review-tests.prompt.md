---
name: review-tests
description: Review unit lua test coverage and fix all gaps, ensure all practices are followed.
---

# GOAL
- Audit and improve the Lua unit testing suite to guarantee full functional coverage.

# INPUTS REQUIRED
- Target module
= User defines the module for test review
- Agent must collect output from `lua_api_test_coverage.py` and `lua_test_structure_audit.py`

# STEPS TO DO
1. Load skills: testing-rust, lua-scripting.
2. Execute `python tools/audit/lua_test_structure_audit.py`. Note any structural violations.
3. Execute `python tools/audit/lua_api_test_coverage.py`. Note the current test coverage percentage.
4. Write new tests in `tests/lua/` to target missing functions, adhering to the one-file-per-module rule.
5. Execute `cargo test --test lua_tests`. If the tests fail (exit code >0), fix your logic.
6. Execute both audit tools again. If structure errors >0 or coverage <100%, repeat step 4.

# OUTPUTS PROVIDED
- Updated test files in `tests/lua/`
- Complete test coverage and structure reports

# SUCCESS CRITERIA
- `cargo test --test lua_tests` exits with code 0.
- `python tools/audit/lua_test_structure_audit.py` reports exactly 0 structural violations.
- `python tools/audit/lua_api_test_coverage.py` reports exactly 100% test coverage.

# ANIT PATTERNS
- Using mocked internal states instead of testing via the public Lua API.
- Ignoring structural rules and placing tests in random directories.

# REFERENCES
- skills: testing-rust, quality-pipeline, lua-scripting
- tools: python tools/audit/lua_api_test_coverage.py, python tools/audit/lua_test_structure_audit.py, cargo test
- agent: Tester
