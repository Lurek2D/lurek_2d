---
name: create-test-evidence
description: "Load this skill when creating or modifying Lua tests that produce evidence artifacts such as logs, snapshots, or golden files. Skip it for ordinary unit tests without artifacts or performance stress tests."
---
# create-test-evidence

## Mission
- Create or modify evidence tests that produce durable artifacts for public Lua behavior.
- Keep canonical `tests/lua_reorg/evidence/test_<module>_evidence.lua` markers aligned with the APIs that a produced artifact genuinely demonstrates. One `it()` may carry multiple `@evidence` markers when one artifact proves several related APIs.
- Treat evidence as artifact generation: the block should pass when it successfully emits the intended screenshot, audio, text, JSON, or similar proof artifact.
- Treat golden as a separate comparison layer: a golden test should validate a newly produced artifact against a stored baseline rather than merely producing the artifact.

## When To Load
- Creating or modifying Lua tests that produce evidence artifacts such as logs, snapshots, or golden files.

## When To Skip
- Ordinary unit tests without artifacts or performance stress tests.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing evidence tests, golden files, and target API before editing.
- Modify an existing evidence path when it covers the module; create new artifact coverage only for missing contracts.
- Keep `@evidence` markers directly adjacent to the `it()` block and include only APIs that the emitted artifact genuinely proves. Split a block only when one artifact no longer serves as meaningful evidence for all marked APIs.
- Save evidence in the established baseline artifact location.
- Run golden comparison and evidence contract audit when the workflow also updates or depends on stored golden baselines. Use the canonical scripts so the shared Lua artifact lock serializes reseed/audit access to `tests/artifacts/baselines/`.
- Rerun `python tools/audit/lua_nonunit_test_coverage.py --category evidence`.
- Iterate until missing contracts close or the blocker is explicit.
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
- Contracts: `tests/AGENTS.md`, `tests/lua_reorg/AGENTS.md`, `content/games/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua evidence tests golden artifacts" --profile game --limit 10`, `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category evidence`, `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py`, `tools/python.cmd tools/audit/golden_test.py`
- Owner profile: `tester`

## Common RAG Queries
- Use when locating golden files, snapshots, and evidence emitters:
  - `Lua evidence tests golden artifacts`
  - `work artifact snapshot compare`
  - `golden file evidence test`
- Common areas to inspect after top hits:
  - `tests/`
  - `work/`
  - evidence helpers in `tools/`
  - related fixtures or snapshot assets

## References
- `contracts: tests/AGENTS.md, tests/lua_reorg/AGENTS.md, content/games/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua evidence tests golden artifacts" --profile game --limit 10, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category evidence, tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py, tools/python.cmd tools/audit/golden_test.py`
- `agent: tester`
