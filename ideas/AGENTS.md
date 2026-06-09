# Ideas Contract

This file adds local rules for work under `ideas/`.

## Mission
- Own the discovery backlog, pre-phase idea notes, and opportunity candidates.
- Keep idea capture separate from committed implementation plans.

## Local rules
- Treat `ideas/` as the primary discovery backlog, not as a hidden roadmap directory.
- Distinguish opportunities from tasks: an opportunity describes a problem space with multiple possible solutions; a task already assumes one solution.
- Cluster new findings by affected layer first, then by pain type such as missing capability, fragile boundary, documentation gap, test gap, or tooling gap.
- Triage idea entries explicitly to `WONTDO`, `INVESTIGATE`, or `PHASE`. Do not silently promote a raw idea into implementation work.
- A valid phase candidate must define `Owner`, `Done When`, `Inputs`, and `Produces`. Without those four fields, it is still only an idea.
- Every scoped phase must say what is not in scope so adjacent work does not accrete by accident.
- When an idea depends on another artifact, name that dependency as an input rather than implying it in prose.
- If an idea changes a public API, include migration-note work in the downstream spec update instead of treating it as optional follow-up.

## Workflow
- Refresh evidence from tests, docs, or quality reports before ranking ideas that claim current coverage or gap data.
- Promote planning-ready material into `work/` when it becomes an executable phase or investigation artifact.

## References
- `work/`
- `tools/audit/test_coverage.py`
- `tools/audit/doc_coverage.py`
- `docs/architecture/`
