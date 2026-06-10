---
name: create-integration-test
description: "Load this skill when creating or modifying Lua integration tests that prove interactions between two or more modules. Skip it for single-module unit tests, Rust-only internal tests, or performance stress tests."
---
# create-integration-test

## Mission
- Create or modify integration tests that verify cross-module public Lua behavior.

## When To Load
- Creating or modifying Lua integration tests that prove interactions between two or more modules.

## When To Skip
- Single-module unit tests, Rust-only internal tests, or performance stress tests.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing integration tests and involved API specs before writing.
- Modify an existing integration file for the module pair when present; create under `tests/lua/integration/` only for new coverage.
- Use public `lurek.*` APIs and explicit state assertions.
- Add or confirm harness registration when a new file is introduced.
- Run integration coverage and `cargo test --test lua_tests`, then rerun coverage.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `tests/AGENTS.md`, `tests/lua/AGENTS.md`, `content/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua integration tests module interaction" --profile game --limit 10`, `tools/python.cmd tools/audit/integration_coverage.py`, `cargo test --test lua_tests`
- Owner profile: `tester`

## Common RAG Queries
- Use when finding existing multi-module test patterns:
  - `Lua integration tests module interaction`
  - `tests lua integration scene input physics`
  - `assert helper fixture register`
- Common areas to inspect after top hits:
  - `tests/lua/`
  - `tests/harness/`
  - `library/`
  - touched modules in `src/` or `content/`

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua integration tests module interaction" --profile game --limit 10, tools/python.cmd tools/audit/integration_coverage.py, cargo test --test lua_tests`
- `agent: tester`
