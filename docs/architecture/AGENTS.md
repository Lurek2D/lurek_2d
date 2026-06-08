# Architecture Contract

This file adds local rules for work under `docs/architecture/`.

## Mission
- Own architecture decisions, boundaries, dependency direction, migration paths, and option analysis.
- Keep design work separate from implementation work.

## Scope
- `docs/architecture/` design notes and decisions.
- Cross-module contracts, dependency maps, and migration paths.
- Boundary reviews for major refactors or subsystem splits.

## Local map
- `developer-ecosystem.md` is the current CAG doctrine and ecosystem overview.
- `cag-system.md` is only a compatibility pointer; update the canonical doctrine instead of expanding the pointer.
- `developer-workflow.md` is the right target for contributor-flow or setup changes.
- `engine-core.md`, `render-pipeline.md`, and `scripting-bridge.md` are the main technical architecture anchors.
- `quality-assurance.md` and `build-and-distribution.md` cover delivery and validation policy.
- `philosophy.md`, `use_cases.md`, and `market-positioning.md` are framing docs; do not hide hard implementation rules there if a technical architecture note is the correct home.

## Local rules
- Define ownership, dependency direction, and gates before large refactors.
- Compare real options when the design choice is non-trivial.
- Prefer small migration steps that another implementer can execute safely.
- Flag cyclic dependencies, boundary leaks, and missing fallback paths.
- Keep architecture notes decision-oriented rather than tutorial-like.
- Include fallback and rollback paths when a change carries migration risk.

## Workflow
- Read the nearest specs, module layout, and existing architecture notes first.
- Load `architecture-decisions`, `enterprise-architecture`, and `module-architecture` when the task is a real design problem.
- Write the chosen path, the rejected alternatives, and the gate the implementer should use.
- Keep the change sequence small enough to be executed and reviewed independently.

## Expected outputs
- Decision-ready architecture notes.
- Boundary rules and migration steps.
- A clear owner or handoff path for downstream implementation work.

## Anti-patterns
- Over-design for future possibilities.
- Produce a design with no migration path.
- Mix implementation code into architecture docs.

## References
- `docs/specs/`
- `src/`
- `tests/`
