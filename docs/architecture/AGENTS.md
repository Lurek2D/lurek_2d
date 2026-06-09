# Architecture Contract

Covers work under `docs/architecture/`.

## Mission
- Own architecture decisions, boundaries, dependency direction, migration paths, and option analysis.
- Keep design work separate from implementation work.

## Scope
- `docs/architecture/` design notes and decisions.
- Cross-module contracts, dependency maps, and migration paths.

## Local map
- `developer-ecosystem.md` is the current CAG doctrine.
- `cag-system.md` is only a compatibility pointer.
- `developer-workflow.md` is for contributor-flow or setup changes.
- `engine-core.md`, `render-pipeline.md`, and `scripting-bridge.md` are the main technical anchors.
- `quality-assurance.md` and `build-and-distribution.md` cover delivery and validation.

## Rules
- Define ownership, dependency direction, and gates before large refactors.
- Compare real options when the choice is non-trivial.
- Keep option sets small and include status quo when no change may be needed.
- Prefer small migration steps with fallback and rollback paths.
- Flag cyclic dependencies, boundary leaks, and missing fallback paths.
- Keep notes decision-oriented.
- Follow the authority chain: binding constraints -> engine structure -> module specs -> CAG layer.
- Record the chosen path, rejected alternatives, residual risk, and next owner.
- If a task uses TOGAF, read `togaf.md` first and treat it as an analysis lens.
- Keep generic architecture assets in `docs/architecture/`; keep module or workflow detail in specs and nested contracts.

## Workflow
- Read the nearest specs, module layout, and existing architecture notes first.
- Use this file plus the affected specs and notes as the authority for design work.
- Write the chosen path, rejected alternatives, and the gate the implementer should use.
- Keep the change sequence small enough to review independently.

## References
- `docs/specs/`
- `src/`
- `tests/`
