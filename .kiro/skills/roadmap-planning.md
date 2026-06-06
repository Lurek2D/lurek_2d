---
inclusion: manual
---

# roadmap-planning

## Mission
Own the phase file format, dependency graph rules, acceptance gate authoring, status tracking, and roadmap consistency checks.

## When To Use
- Creating a new roadmap phase file.
- Updating status or acceptance gates on an existing phase.
- Auditing the dependency graph for cycles or missing phases.
- Writing acceptance gates for a feature or milestone.

## When To Skip
- Implementing code, designing APIs, writing tests.

## Rules

### Planning Artifacts Location
Current planning artifacts live in `ideas/` (raw ideas) and `work/` (active session plans). Do not create roadmap files that reference non-existent infrastructure.

### Valid Roadmap Phase (4 required fields)
- **Owner** — one role or team.
- **Done When** — a binary, runnable test or validator command.
- **Inputs** — existing artifacts this phase depends on.
- **Produces** — concrete artifact this phase creates.

Phases without Done When are wishlist items, not roadmap entries.

### Dependency Direction Rule
Phase B requiring phase A's output must list A's artifact as an Input. Circular phase dependencies mean the phases are wrong. Consolidate or split until the graph is a DAG.

### Slice Size Rule
A phase touching more than 5 files in `src/`, more than 2 spec files, or more than 1 test suite is too large. Split by artifact class (code, docs, tests).

### Scope-Creep Guard
Every phase description must include a one-line statement of what is explicitly NOT in scope.

### Quality Gate Alignment
Done When for any phase touching `src/` must include `cargo test` and `cargo clippy -- -D warnings`. Done When for any phase touching `docs/` must include `python tools/gen_all_docs.py` with clean diff.

### Ideas-to-Phases Pipeline
`ideas/` items are triaged to: WONTDO (add rejection note), INVESTIGATE (goes to Planner or Architect for discovery), or PHASE (ready to add to roadmap). Do not move an idea directly to a phase without a brief investigation note.

### API Change Phases
When a phase changes a public API, it must include sub-steps for migration notes in `docs/specs/<module>.md` and an update to `docs/CHANGELOG.md`. These are not optional follow-up tasks.

### Roadmap Artifact Location
Live in `work/{session}/plan.md` during planning. May be promoted to a docs location only when finalized and reviewed. Do not commit in-progress plans to `docs/`.

## References
- `ideas/`
- `docs/architecture/`
- `docs/handbook.md`
- `work/`
