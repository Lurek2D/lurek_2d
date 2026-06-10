---
name: review-specs
description: "Load this skill when auditing and fixing module specs, generated sections, hand-written summaries, and spec coverage. Skip it for architecture prose or source docstrings without spec impact."
---
# review-specs

## Mission
- Audit and fix module specs while respecting generated-vs-hand-written section ownership.

## When To Load
- Auditing and fixing module specs, generated sections, hand-written summaries, and spec coverage.

## When To Skip
- Architecture prose or source docstrings without spec impact.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run spec generation and spec coverage for the selected scope.
- Compare regenerated output with source and existing `docs/specs/` files.
- Do not hand-edit generated sections; only rewrite `## Summary` when code reality is clear.
- If edit-capable, fix summaries/catalog coverage and rerun generation/audits.
- If read-only, hand off exact spec files and missing coverage.
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
- Contracts: `AGENTS.md`, `docs/AGENTS.md`, `docs/specs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "module specs generated summary coverage" --profile engine --limit 10`, `tools/python.cmd tools/docs/gen_module_specs.py`, `tools/python.cmd tools/audit/lua_spec_coverage.py`, `tools/python.cmd tools/validate/validate_module_coverage.py`
- Owner profile: `doc_writer`

## Common RAG Queries
- Start with: `module specs generated summary coverage`, `review specs generated summary coverage docs`, `architecture docs specs engine boundaries`
- Focus areas first: `docs/specs/`, `docs/architecture/`, `src/`, `tools/docs/`
- Append the module or subsystem name such as `input`, `render`, `physics`, `ui`

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "module specs generated summary coverage" --profile engine --limit 10, tools/python.cmd tools/docs/gen_module_specs.py, tools/python.cmd tools/audit/lua_spec_coverage.py, tools/python.cmd tools/validate/validate_module_coverage.py`
- `agent: doc_writer`
