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
- Keep real option sets to 2-4 choices and include status quo when the repo may not need a change yet.
- Prefer small migration steps that another implementer can execute safely.
- Flag cyclic dependencies, boundary leaks, and missing fallback paths.
- Keep architecture notes decision-oriented rather than tutorial-like.
- Include fallback and rollback paths when a change carries migration risk.
- Follow the authority chain: binding constraints -> engine structure -> module specs -> CAG layer. Lower layers may refine, not contradict, higher ones.
- Treat code-vs-doc divergence as a governance gap; record the gap in `work/` when the fix is not completed in the same task.
- A cross-module architecture change is not settled until it updates the relevant architecture note, affected specs, and at least one enforcement mechanism or validator.
- Record the chosen path, rejected alternatives, residual risk, and next owner so the handoff is executable.
- When a task explicitly uses TOGAF, read `togaf.md` first and keep TOGAF as an analysis lens rather than forcing every concept into a repo convention.
- Apply the four-domain lens concretely to this repo: contributor workflow and adoption goals, serialized/runtime data contracts, engine/application structure, and tooling/runtime infrastructure.
- If a TOGAF comparison finds no meaningful repo equivalent, name the mismatch instead of padding the note with checkbox mapping.
- Keep generic architecture assets in `docs/architecture/`; keep module- or workflow-specific detail in specs and nested contracts below this layer.

## Workflow
- Read the nearest specs, module layout, and existing architecture notes first.
- Use this file together with the affected specs and architecture notes as the authority for design work.
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
