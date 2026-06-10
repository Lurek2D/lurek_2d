---
name: create-test-stress
description: "Load this skill when creating or modifying stress tests, ceilings, or heavy-load validation for a module. Skip it for normal unit tests, integration tests, or benchmark-free code reviews."
---
# create-test-stress

## Mission
- Create or modify stress coverage that records realistic load ceilings and failure behavior.

## When To Load
- Creating or modifying stress tests, ceilings, or heavy-load validation for a module.

## When To Skip
- Normal unit tests, integration tests, or benchmark-free code reviews.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect current stress reports, existing stress tests, and user threshold before editing.
- Modify an existing stress case when it owns the module; create a new stress path only for missing load coverage.
- Keep load deterministic and record artifacts under `work/<short-chat-name>/` when temporary output is needed.
- Run the stress script and monitor OOM, timeout, and frame-time behavior.
- Rerun `stress_report.py` and compare against the expected ceiling.
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
- Contracts: `tests/AGENTS.md`, `tests/lua/AGENTS.md`, `tools/audit/AGENTS.md`, `work/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "stress tests performance ceilings" --profile engine --limit 10`, `tools/python.cmd tools/audit/stress_report.py`
- Owner profile: `tester`

## Common RAG Queries
- Use when locating load tests and perf ceilings:
  - `stress tests performance ceilings`
  - `benchmark stress report threshold`
  - `perf regression scenario workload`
- Common areas to inspect after top hits:
  - `tests/`
  - `tools/audit/`
  - `work/` reports
  - suspect hot paths in `src/`

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "stress tests performance ceilings" --profile engine --limit 10, tools/python.cmd tools/audit/stress_report.py`
- `agent: tester`
