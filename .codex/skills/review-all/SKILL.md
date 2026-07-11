---
name: review-all
description: "Load this skill when running a coordinated audit and fix sweep across API, docs, examples, performance, quality, specs, and tests. Skip it for single-area reviews where a narrower review skill is enough."
---
# review-all

## Mission
- Coordinate review skills, aggregate findings, and route fixes to the correct existing owner profile.

## When To Load
- Running a coordinated audit and fix sweep across API, docs, examples, performance, quality, specs, and tests.

## When To Skip
- Single-area reviews where a narrower review skill is enough.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run RAG and read root plus relevant contracts before starting the sweep.
- Run reviews in this order: API, tests, examples, specs, docstrings, architecture, performance, quality.
- Aggregate findings by owner profile and severity before fixing.
- Use owner profiles that already exist under `.codex/agents/`.
- If a needed owner profile is missing, report the gap instead of inventing one.
- If edit-capable and fixes are requested, dispatch fixes through the matching create/review skill and rerun audits.
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
- Contracts: `AGENTS.md`, `tools/AGENTS.md`, `.codex/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "review audits quality performance specs tests" --profile all --limit 10`, `tools/python.cmd tools/audit/quality_report.py`, `tools/python.cmd tools/audit/perf_regression_gate.py`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `reviewer`

## Common RAG Queries
- Use when scoping a broad audit before reading many files:
  - `review audits quality performance specs tests`
  - `api docs examples specs drift`
  - `quality report perf regression validation`
- Common areas to inspect after top hits:
  - `docs/`
  - `tests/`
  - `tools/audit/`
  - touched owner paths from findings

## References
- `contracts: AGENTS.md, tools/AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "review audits quality performance specs tests" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
