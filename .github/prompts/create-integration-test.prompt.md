---
name: create-integration-test
description: Create or update integration lua test combining 2 or more modules together.
---

# GOAL
- Create comprehensive integration tests that verify the interaction and data flow between multiple modules.

# INPUTS REQUIRED
- List of modules to integrate (e.g., `physics` and `graphics`)
- Expected interaction behavior
= User must define which modules are interacting and the expected outcome
- Agent must collect API surfaces of all involved modules

# STEPS TO DO
1. Load skills: testing-ecosystem, lua-scripting.
2. Execute `python tools/audit/integration_coverage.py` to identify missing links between the targeted modules.
3. Write a Lua script under `tests/lua/integration/` that initializes and feeds output from Module A into Module B, asserting the final combined state.
4. Execute `cargo test --test lua_tests` ensuring the integration folder is included in the test runner. If tests fail, fix the integration script.
5. Re-run `python tools/audit/integration_coverage.py`. If the cross-module link still reports as uncovered (0%), return to step 3 and fix the test implementation.

# OUTPUTS PROVIDED
- Integration test scripts in `tests/lua/integration/` (or similar appropriate path)
- Test execution summary

# SUCCESS CRITERIA
- [ ] `cargo test --test lua_tests` exits with code 0.
- [ ] `python tools/audit/integration_coverage.py` reports exactly 100% integration coverage for the target module pair.

# ANTI-PATTERNS
- Writing integration tests that mock the interaction layer.
- Coupling the test too tightly to the internal implementation of either module.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: testing-ecosystem, lua-scripting
- tools: python tools/audit/integration_coverage.py
- agent: Tester


