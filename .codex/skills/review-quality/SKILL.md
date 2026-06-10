---
name: review-quality
description: "Load this skill when auditing overall repo quality, hotspots, contract drift, and tool-reported quality findings. Skip it for narrow module implementation tasks with clear requested edits."
---
# review-quality

## Mission
- Audit overall quality signals and convert tool findings into fixable owner-scoped work.

## When To Load
- Auditing overall repo quality, hotspots, contract drift, and tool-reported quality findings.

## When To Skip
- Narrow module implementation tasks with clear requested edits.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run quality report before broad file reads.
- Group findings by severity and owner subsystem.
- Verify tool findings against source before recommending or applying fixes.
- If edit-capable and fixes are requested, address narrow high-confidence issues and rerun the report.
- If read-only, produce findings-first output and owner handoff.
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
- Contracts: `AGENTS.md`, `src/AGENTS.md`, `tools/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "quality report hotspots contract drift" --profile all --limit 10`, `tools/python.cmd tools/audit/quality_report.py`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `reviewer`

## Common RAG Queries
- Start with: `quality report hotspots contract drift`, `review audits quality performance specs tests`, `review quality report hotspots`
- Focus areas first: `tools/audit/`, `tests/`, `docs/`, `src/`, root `AGENTS.md`
- For a narrower audit, append the module, subsystem, or contract path

## References
- `contracts: AGENTS.md, src/AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "quality report hotspots contract drift" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
