---
name: review-tests
description: "Load this skill when auditing and fixing Lua unit test coverage, structure, harness registration, and public API test gaps. Skip it for Rust-only internal tests or non-test code reviews."
---
# review-tests

## Mission
- Audit and fix Lua test coverage and structure for public `lurek.*` APIs.

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
- Compare audit output with `tests/lua/` files and harness registration.
- Report missing `@covers`, structure issues, and uncovered public APIs first.
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
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10`, `tools/python.cmd tools/audit/lua_api_test_coverage.py --module <module>`, `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/`, `cargo test --test lua_tests`
- Owner profile: `tester`

## Common RAG Queries
- Start with: `Lua test coverage structure harness public API`, `Lua unit tests public API coverage`, `tests contract Lua API coverage harness`
- Focus areas first: `tests/lua/`, `tests/`, `content/examples/`, `docs/specs/`
- Append the target module, API path, or failing test file before broad reads

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10, tools/python.cmd tools/audit/lua_api_test_coverage.py --module <module>, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/, cargo test --test lua_tests`
- `agent: tester`
