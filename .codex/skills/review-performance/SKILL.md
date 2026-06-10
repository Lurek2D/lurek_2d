---
name: review-performance
description: "Load this skill when auditing performance regressions, baselines, and stress/perf reports before deciding fixes. Skip it for functional testing without performance evidence."
---
# review-performance

## Mission
- Audit performance data, identify regressions, and route or apply fixes with validation evidence.

## When To Load
- Auditing performance regressions, baselines, and stress/perf reports before deciding fixes.

## When To Skip
- Functional testing without performance evidence.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Collect baseline data with the perf gate or stress report before inspecting code broadly.
- Record scenario, threshold, environment, and suspect module.
- If running as read-only reviewer, provide findings and owner handoff.
- If edit-capable and fix scope is clear, fix the bottleneck or stress setup and rerun the same report.
- Store temporary reports under `work/<short-chat-name>/`.
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
- Contracts: `.codex/AGENTS.md`, `tools/audit/AGENTS.md`, `work/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "performance regression gate baseline" --profile engine --limit 10`, `tools/python.cmd tools/audit/perf_regression_gate.py`, `tools/python.cmd tools/audit/stress_report.py`
- Owner profile: `reviewer`

## Common RAG Queries
- Use when locating current perf baselines and hot paths:
  - `performance regression gate baseline`
  - `stress report frame time allocation`
  - `perf workload threshold regression`
- Common areas to inspect after top hits:
  - `tools/audit/`
  - `work/`
  - hot code paths in `src/`
  - performance notes in `docs/`

## References
- `contracts: .codex/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "performance regression gate baseline" --profile engine --limit 10, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/audit/stress_report.py`
- `agent: reviewer`
