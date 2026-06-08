---
name: create-test-evidence
description: Create or update lua tests with evidences/artifacts for a specific module and check test coverage.
---

# GOAL
- Write Lua tests that produce tangible evidence (like logs, screenshots, or golden files) for a specific module.

# INPUTS REQUIRED
- Module name
- Artifact type required (e.g., golden screenshot, structured log)
= User must provide the specific module and desired evidence type
- Agent must collect existing golden files and module API

# STEPS TO DO
1. Load skills: testing-ecosystem, demo-creation.
2. Execute `python tools/audit/lua_evidence_golden_contract_audit.py` to check the current evidence baseline and identify missing artifacts.
3. Write the test script to trigger the target API and save output (e.g., visual snapshot, structured log output) to the baseline artifact directory.
4. Execute `python tools/audit/golden_test.py` to compare new evidence against established baselines.
5. Execute `python tools/audit/lua_evidence_golden_contract_audit.py` to verify gap closure. If the audit reports >0 missing contracts, return to step 3 and generate the remaining missing artifacts.

# OUTPUTS PROVIDED
- Updated Lua test files
- Generated artifact files (golden data, logs)
- Coverage report

# SUCCESS CRITERIA
- [ ] `python tools/audit/golden_test.py` exits with code 0 (0 differences detected between output and baseline).
- [ ] `python tools/audit/lua_evidence_golden_contract_audit.py` reports exactly 0 missing contracts.

# ANTI-PATTERNS
- Creating non-deterministic tests that produce varying evidence on each run.
- Overwriting baseline golden files without explicit user approval.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: testing-ecosystem, lua-scripting, demo-creation
- tools: python tools/audit/lua_evidence_golden_contract_audit.py, python tools/audit/golden_test.py
- agent: Tester


