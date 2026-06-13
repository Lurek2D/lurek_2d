---
name: review-tests
description: "Load this skill when auditing and fixing Lua unit test coverage, structure, harness registration, and public API test gaps. Skip it for Rust-only internal tests or non-test code reviews."
---
# review-tests

## Mission
- Audit and fix Lua test coverage and structure for public `lurek.*` APIs.
- Enforce canonical ownership in `tests/lua/unit/`: `1 API = 1 unit it() = 1 directly-adjacent @covers`.
- For canonical non-unit suites, enforce:
  - `stress/security`: `1 API = 1 family marker = 1 it()`
  - `evidence`: module-owned files should use prose rationale comments above each `it()` and produce artifacts that genuinely demonstrate the owner module
  - `golden`: compare current artifacts to stored reference artifacts or baselines and fail on unacceptable drift
  - `integration`: markers should match the APIs actually exercised by each scenario

## When To Load
- Auditing and fixing Lua unit test coverage, structure, harness registration, and public API test gaps.

## When To Skip
- Rust-only internal tests or non-test code reviews.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run Lua API coverage and structure audits before reading many test files.
- Start unit-suite status with `tools/python.cmd tools/audit/unit_test_api_coverage.py` and read these counts first: total Lua APIs, APIs with exactly one unit owner test, APIs with no Lua unit owner test, APIs duplicated across multiple unit `it()` blocks.
- For non-unit suites, run `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py` and read these counts first: category totals, duplicate primary markers in `stress/security`, evidence file ownership and rationale compliance, and integration marker mismatches.
- Compare audit output with `tests/lua/` canonical files and harness registration.
- Report missing `@covers`, structure issues, uncovered public APIs, and duplicated API owners first.
- For non-unit findings, report file naming issues, missing family markers, duplicate primary markers in `stress/security`, stale evidence markers or weak rationale blocks, and integration marker mismatches.
- Keep canonical unit ownership module-local: one `test_<module>_unit.lua` file per module, with `lurek.<module>.*` tests before userdata/object method coverage.
- If edit-capable, fix tests and rerun coverage, structure audit, and `cargo test --test lua_tests`.
- If read-only, hand off to `tester` with exact missing API coverage.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- Audit output was collected before fixes or handoff.
- Findings are either fixed and revalidated, or handed off with an explicit owner profile and blocker.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `AGENTS.md`, `tests/AGENTS.md`, `tests/lua/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10`, `tools/python.cmd tools/audit/unit_test_api_coverage.py`, `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py`, `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`, `cargo test --test lua_tests`
- Owner profile: `tester`

## Common RAG Queries
- Start with: `Lua test coverage structure harness public API`, `Lua unit tests public API coverage`, `tests contract Lua API coverage harness`
- Focus areas first: `tests/lua/unit/`, `tests/lua/`, `tests/`, `content/examples/`, `docs/specs/`
- Append the target module, API path, or failing test file before broad reads

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests`
- `agent: tester`
