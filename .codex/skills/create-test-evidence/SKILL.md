---
name: create-test-evidence
description: "Create or update lua tests with evidences/artifacts for a specific module and check test coverage."
---
# create-test-evidence

## Goal
- Write Lua tests that produce tangible evidence (like logs, screenshots, or golden files) for a specific module.

## Required inputs
- Module name
- Artifact type required (e.g., golden screenshot, structured log)
- User must provide the specific module and desired evidence type
- Agent must collect existing golden files and module API

## Profile hint
- `tester`

## Read these contracts
- `tests/AGENTS.md`
- `tests/lua/AGENTS.md`
- `content/games/AGENTS.md`

## Steps
- Read the listed contracts before adding evidence coverage.
- Execute `python tools/audit/lua_evidence_golden_contract_audit.py` to check the current evidence baseline and identify missing artifacts.
- Write the test script to trigger the target API and save output (e.g., visual snapshot, structured log output) to the baseline artifact directory.
- Execute `python tools/audit/golden_test.py` to compare new evidence against established baselines.
- Execute `python tools/audit/lua_evidence_golden_contract_audit.py` to verify gap closure. If the audit reports >0 missing contracts, return to step 3 and generate the remaining missing artifacts.

## Outputs
- Updated Lua test files
- Generated artifact files (golden data, logs)
- Coverage report

## Success criteria
- [ ] `python tools/audit/golden_test.py` exits with code 0 (0 differences detected between output and baseline).
- [ ] `python tools/audit/lua_evidence_golden_contract_audit.py` reports exactly 0 missing contracts.

## Stop conditions
- Creating non-deterministic tests that produce varying evidence on each run.
- Overwriting baseline golden files without explicit user approval.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/games/AGENTS.md`
- `tools: python tools/audit/lua_evidence_golden_contract_audit.py, python tools/audit/golden_test.py`
- `agent: Tester`


