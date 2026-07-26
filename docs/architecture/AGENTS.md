# Architecture Contract

## Mission & Scope
- Own high-level engine architecture, decisions, dependencies, and boundaries.
- Keep durable design constraints aligned with specs and code.

## Files
- `engine-core.md`, `render-pipeline.md`, `scripting-bridge.md`: Core design.
- `quality-assurance.md`, `build-and-distribution.md`: QA and release design.
- `developer-ecosystem.md`, `developer-workflow.md`: CAG and workflow docs.

## Rules
- Before large refactors, record options, trade-offs, risks, and rollback paths.
- Flag cyclic dependencies, state leaks, and missing API fallback paths.
- Keep docs aligned with root constraints, specs, and current code.
- Keep low-level module details in `docs/specs/`, not here.
- When a durable constraint changes, update the canonical spec or architecture doc first.

## Workflow
- Run `python tools/audit/cag_link_check.py --strict`.
- Review `docs/specs/` before design changes.
