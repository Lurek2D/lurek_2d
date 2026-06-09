# Architecture Contract

Covers work under `docs/architecture/`.

## Mission & Scope
- Design the overarching architectural patterns, dependency structures, and boundary directions for Lurek2D.
- Maintain comprehensive, high-level design documents (such as rendering pipeline logic and scripting bridges).
- Document and govern major technical decisions, comparing concrete design options before execution.

## Files
- `developer-ecosystem.md`: Doctrine for active context-augmented guidance (CAG) and roles.
- `developer-workflow.md`: Contributor workflow guidelines, setup procedures, and branch conventions.
- `engine-core.md` / `render-pipeline.md` / `scripting-bridge.md`: Technical anchor documents detailing engine internals.
- `quality-assurance.md` / `build-and-distribution.md`: Governance files covering testing frameworks and deployment.

## Rules
- Always identify architectural options, comparing trade-offs, residual risks, and rollback strategies before large refactors.
- Strictly flag cyclic module dependencies, state leaks, and missing API fallback paths.
- Ensure architecture docs stay aligned with the canonical project constraints defined in the root `AGENTS.md`, active specs, and current engine implementation.
- Keep high-level architecture documents in this folder; do not duplicate low-level module implementation specifications.
- When a durable constraint changes, update the canonical spec or architecture document first, then adjust related summaries here only if needed.

## Workflow
- Run `python tools/audit/cag_link_check.py --strict` to verify internal document link integrity.
- Review current specs in `docs/specs/` before drafting any design change proposal.

## References
- `AGENTS.md`
- docs/specs/
- src/
- docs/architecture/developer-ecosystem.md
