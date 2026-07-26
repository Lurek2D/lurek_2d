# Architecture Contract

## Mission & Scope
- Own current high-level engine architecture, dependencies, state ownership, and boundaries.
- Keep durable design constraints aligned with specs and code.

## Files
- `index.md`: Architecture map and document ownership.
- `engine-core.md`, `render-pipeline.md`, `scripting-bridge.md`: Core design.
- `module-scope-boundaries.md`, `runtime-tooling-boundaries.md`, `philosophy.md`: Durable constraints.
- `docs-system.md`: Source and generated documentation topology.

## Rules
- Before large refactors, record options, trade-offs, risks, and rollback paths.
- Flag cyclic dependencies, state leaks, and missing API fallback paths.
- Keep docs aligned with root constraints, specs, and current code.
- Keep low-level module details in `docs/specs/`, not here.
- Keep aspirational roadmaps and product visions out of this folder.
- When a durable constraint changes, update the canonical spec or architecture doc first.

## Workflow
- Run `python tools/audit/cag_link_check.py --strict`.
- Review `docs/specs/` before design changes.
