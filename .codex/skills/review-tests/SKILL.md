---
name: review-tests
description: "Review unit lua test coverage and fix all gaps, ensure all practices are followed."
---
# review-tests

## Goal
- Audit and improve the Lua unit testing suite to guarantee full functional coverage.

## Required inputs
- Target module
- User defines the module for test review
- Agent must collect output from `python tools/audit/lua_api_test_coverage.py` and `python tools/audit/lua_test_structure_audit.py`

## Profile hint
- `reviewer`

## Read these contracts
- `AGENTS.md`
- `tests/AGENTS.md`
- `tests/lua/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Run `python tools/audit/lua_api_test_coverage.py` and `python tools/audit/lua_test_structure_audit.py` for the selected module.
- Compare the audit output with the actual files under `tests/lua/` and confirm the naming, placement, and coverage paths match the current conventions.
- Record findings first, with severity and exact file or line evidence where possible.
- Return a binary accept or reject decision with explicit follow-up gate conditions.

## Outputs
- Findings-first review report
- File and line evidence
- Accept or reject decision with follow-up conditions

## Success criteria
- The review stays read-only unless the user explicitly expands scope to include fixes.
- The output lists concrete findings and an explicit gate condition.
- The decision is binary and supported by evidence.

## Stop conditions
- Do not mutate source or write tests during pure review work.
- Do not return vague opinions without file-backed evidence.
- Do not merge review and implementation into the same pass unless the user explicitly asks for both.

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: python tools/audit/lua_api_test_coverage.py, python tools/audit/lua_test_structure_audit.py, cargo test`
- `agent: Tester`


