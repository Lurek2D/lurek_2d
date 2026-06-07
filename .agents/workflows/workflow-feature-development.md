---
trigger: manual
description: "Deliver scoped feature slices with Lua-first tests, thin lua_api wrappers, full API/example/Lua-unit/spec coverage, and synced Rust docstrings."
expected_agent: "Manager"
---
# Workflow Feature Development

## Goal
- Deliver one scoped feature end-to-end with Lua-first behavioral tests, thin-wrapper-only `src/lua_api`, full API/example/Lua-unit/spec coverage, no unrequested `library/` edits, and refreshed Rust item plus file-level docstrings.

## Inputs
- Feature goal.
- Accepted source of truth.
- Constraints.
- Required final gate.

## Steps
1. Load [skill: module-architecture](../skills/module-architecture/SKILL.md), [skill: docs-general](../skills/docs-general/SKILL.md), [skill: testing-ecosystem](../skills/testing-ecosystem/SKILL.md), and [skill: roadmap-planning](../skills/roadmap-planning/SKILL.md) before acting.
2. Normalize the feature into goal, constraints, out-of-scope items, and the proof needed to call it done.
3. Split the work into the smallest valid owner slices and keep docs and tests sync attached to the slices that actually move.
4. Enforce test-layer placement under TST-01: behavior reachable through `lurek.*` must be covered in `tests/lua/unit/` first; Rust tests must not duplicate Lua-reachable behavior.
5. Enforce thin-wrapper-only `src/lua_api/*_api.rs`: bindings, registration, and conversion only; business logic must live in `src/<module>/`.
6. For every touched module, update and regenerate its spec artifact in `docs/specs/<module>.md` before final close.
7. For every touched Rust file, ensure item-level doc comments are current and file-level `//!` docs reflect the implemented behavior.
8. Enforce marker granularity in both `tests/lua/unit/` and `content/examples/`: `1 API = 1 marker = 1 direct method/function block`; do not group multiple APIs under one marker.
9. Do not add or modify `library/` content unless the user explicitly requested library scope; use `content/examples/` for coverage work.
10. Require a focused validation after the first meaningful edit in each slice before allowing more reading or more patching.
11. Track unmet user-request items explicitly before closing; any requested item not delivered must be listed with file/scope and reason.
12. Close only when all required coverage and sync gates are green for touched modules: API coverage + example coverage + Lua unit coverage + spec update/regeneration.

## Success Criteria
- [ ] The workflow outcome is complete: scoped feature delivered with Lua-first tests, full coverage, and synced specs/docs.
- [ ] The controlling files, checks, or owners were identified.
- [ ] Required validation or gate output is attached.
- [ ] Lua-reachable behavior is validated in Lua unit tests first, with no duplicate Rust coverage for the same behavior.
- [ ] `src/lua_api/*_api.rs` remains thin-wrapper-only and module logic stays in `src/<module>/`.
- [ ] Lua unit and example markers follow `1 API = 1 marker = 1 direct method/function block` (no grouping).
- [ ] API coverage, example coverage, and Lua unit coverage are all green for touched modules.
- [ ] `docs/specs/<module>.md` is updated and regenerated for each touched module.
- [ ] No unrequested `library/` edits were introduced.
- [ ] Touched Rust files have current item doc comments and refreshed file-level `//!` docs.
- [ ] Remaining blockers or risks are explicit.

## Anti-patterns
- Let the workflow widen with no clear owner or gate.
- Skip the first focused check and rely on narrative confidence.
- Add Rust tests for behavior already reachable via `lurek.*` instead of adding Lua unit tests.
- Put business logic in `src/lua_api/*_api.rs` instead of `src/<module>/`.
- Group multiple APIs under one marker in Lua unit tests or examples.
- Skip spec regeneration after touching a module implementation.
- Edit `library/` even though the request only asked for examples/coverage updates.
- Leave touched Rust files without refreshed item doc comments or file-level `//!` docs.
- Finish while part of the explicit user request is still not delivered.
- Close the task while blockers, warnings, or failed gates are still open.

## Example Invocation
- /workflow-feature-development feature=save_slots source=docs/specs/save.md

## CAG Metadata
Mode: agent
Loads skills: module-architecture, docs-general, testing-ecosystem, roadmap-planning
Inputs required: Feature goal., Accepted source of truth., Constraints., Required final gate.
