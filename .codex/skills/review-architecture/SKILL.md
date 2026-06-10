---
name: review-architecture
description: "Load this skill when auditing and fixing architecture docs against specs, source, and current API boundaries. Skip it for low-level code review without durable architecture impact."
---
# review-architecture

## Mission
- Audit and fix architecture documentation drift against current specs and engine code.

## When To Load
- Auditing and fixing architecture docs against specs, source, and current API boundaries.

## When To Skip
- Low-level code review without durable architecture impact.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run strict link checking before semantic review.
- Compare architecture docs with specs, source modules, and public Lua API.
- List drift findings before editing.
- If edit-capable, update canonical specs or architecture docs in the right order and rerun link checks.
- If read-only, hand off to `architect` with concrete files and expected edits.
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
- Contracts: `AGENTS.md`, `docs/AGENTS.md`, `docs/architecture/AGENTS.md`, `docs/specs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "architecture docs specs engine boundaries" --profile engine --limit 10`, `tools/python.cmd tools/audit/cag_link_check.py --strict`
- Owner profile: `architect`

## Common RAG Queries
- Use when locating architecture sources of truth:
  - `architecture docs specs engine boundaries`
  - `system design module api boundary`
  - `docs architecture runtime pipeline`
- Common areas to inspect after top hits:
  - `docs/architecture/`
  - `src/`
  - root and nested `AGENTS.md`
  - specs tied to touched subsystems

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "architecture docs specs engine boundaries" --profile engine --limit 10, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: architect`
