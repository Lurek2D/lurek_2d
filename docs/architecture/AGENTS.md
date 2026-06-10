# Architecture Contract

Adds local rules for `docs/architecture/`.

## Mission & Scope
- Design the main architecture patterns, dependencies, and boundaries for Lurek2D.
- Maintain high-level design docs such as the render pipeline and scripting bridge.
- Record major technical decisions and compare options before execution.

## Files
- `developer-ecosystem.md`: Active CAG and role guidance.
- `developer-workflow.md`: Workflow, setup, and branch guidance.
- `engine-core.md` / `render-pipeline.md` / `scripting-bridge.md`: Core engine design docs.
- `quality-assurance.md` / `build-and-distribution.md`: Testing and distribution docs.

## Rules
- Identify options, trade-offs, risks, and rollback paths before large refactors.
- Strictly flag cyclic module dependencies, state leaks, and missing API fallback paths.
- Keep architecture docs aligned with root constraints, active specs, and current engine code.
- Keep high-level architecture docs here. Do not duplicate low-level module specs.
- When a durable constraint changes, update the canonical spec or architecture document first, then adjust related summaries here only if needed.

## Workflow
- Run `python tools/audit/cag_link_check.py --strict` to verify internal document link integrity.
- Review current specs in `docs/specs/` before drafting any design change proposal.

## References
- `AGENTS.md`
- docs/specs/
- src/
- docs/architecture/developer-ecosystem.md
