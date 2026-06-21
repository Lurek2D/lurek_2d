---
name: create-test-lua
description: "Load this skill when creating or modifying Lua tests for public lurek APIs under tests/lua. Skip it for Rust-only internals, integration-only coverage, or visual evidence tests."
---
# create-test-lua

## Mission
- Create or modify Lua tests that are canonical coverage for public `lurek.*` APIs.
- Keep canonical unit owners in `tests/lua/unit/` with `1 API = 1 unit it() = 1 directly-adjacent @covers`.
- Keep non-unit suites separated by purpose: integration for scenarios, evidence for artifact generation, golden for artifact comparison.

## When To Load
- Creating or modifying Lua tests for public lurek APIs under tests/lua.

## When To Skip
- Rust-only internals, integration-only coverage, or visual evidence tests.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing test files, harness registration, and coverage output before writing.
- Start from `tools/python.cmd tools/audit/unit_test_api_coverage.py` so the target module is framed by exact counts: total APIs, exactly-one-owner APIs, missing-owner APIs, and duplicated-owner APIs.
- When editing non-unit canonical suites, also read `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py` for category-specific structural debt before changing files.
- Modify the matching canonical `tests/lua/unit/test_<module>_unit.lua` file when present; create a new file only for uncovered module coverage.
- Keep one public API in one owning `it()` block, but put every required assertion for that API inside that same block.
- Keep module functions first in the file, then userdata/object method coverage for that same module.
- Register new files in `tests/lua_tests.rs`; that file is the canonical Lua test target registration.
- Run Lua test target, structure audit, coverage audit, and CAG validation when needed.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Public Lua API coverage stays 100% with exact owners and no duplicated unit owners.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `tests/AGENTS.md`, `tests/lua/AGENTS.md`, `content/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua unit tests public API coverage" --profile game --limit 10`, `tools/python.cmd tools/audit/unit_test_api_coverage.py`, `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`, `cargo test --test lua_tests`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `tester`

## Common RAG Queries
- Start with: `Lua unit tests public API coverage`, `Lua test coverage structure harness public API`, `tests contract Lua API coverage harness`
- Focus areas first: `tests/lua/unit/`, `tests/lua/`, `content/examples/`, `docs/specs/`
- Append the target API or module name such as `input`, `render`, `physics`, `scene`

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua unit tests public API coverage" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests, tools/python.cmd tools/validate/cag_validate.py`
- `agent: tester`
