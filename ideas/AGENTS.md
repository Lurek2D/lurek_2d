# Ideas Contract

Covers work under `ideas/`.

## Mission
- Own the discovery backlog, pre-phase notes, and opportunity candidates.
- Keep idea capture separate from implementation plans.

## Scope
- `ideas/` discovery notes and triage entries.

## Local map
- `work/` is for executable phases or investigation artifacts.

## Rules
- Treat `ideas/` as the discovery backlog, not a hidden roadmap.
- Separate opportunities from tasks.
- Cluster findings by affected layer first, then by pain type.
- Triage entries to `WONTDO`, `INVESTIGATE`, or `PHASE`.
- A valid phase candidate must define `Owner`, `Done When`, `Inputs`, and `Produces`.
- Every scoped phase must say what is out of scope.
- Name dependencies as inputs.
- If an idea changes a public API, include migration-note work in the downstream spec update.

## Workflow
- Refresh evidence from tests, docs, or quality reports before ranking ideas that claim current coverage or gap data.
- Move planning-ready material into `work/` when it becomes an executable phase or investigation artifact.

## References
- `work/`
- `tools/audit/test_coverage.py`
- `tools/audit/doc_coverage.py`
- `docs/architecture/`
