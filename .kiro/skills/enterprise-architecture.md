---
inclusion: manual
---

# enterprise-architecture

## Mission
Own high-level architecture doctrine, governance, artifact mapping, and cross-document structure above single-module design.

## When To Use
- Write or revise `docs/architecture/` as system-level doctrine.
- Compare architecture principles, artifacts, and governance across repo surfaces.
- Decide where a rule belongs between `docs/architecture`, `docs/specs`, `.github`, `tools/validate`, and `work/` artifacts.

## When To Skip
- Module boundaries, dependency direction, or crate layout.
- Engine implementation work.
- Pure TOGAF terminology with no broader architecture decision.

## Rules

### Architecture Authority Chain
binding constraints (`philosophy.md`) → engine structure (`engine-architecture.md`) → module contracts (`docs/specs/*.md`) → CAG layer (`.github/`). Each tier may restrict but not contradict its parent.

### Five Binding Constraint Categories
- T = topology/cycles
- A = scope limits (desktop, 2D, no editor in binary)
- B = runtime stack (wgpu 22, LuaJIT, 60 FPS)
- C = Lua namespace
- TST = test placement

Cross-category constraint proposals require explicit `philosophy.md` changes, not just spec changes.

### "Settled" Change Test
A proposed architectural change is settled when it: (1) is consistent with binding constraints, (2) is reflected in at least one validated spec, (3) has at least one enforcement mechanism (validator, test, or Clippy lint). Aspirational diagrams without enforcement are not architecture.

### Governance Gap Pattern
When codebase behavior diverges from its documented constraints, that is a governance gap, not a bug. Document the gap in `work/{session}/gaps/` and route to the appropriate owner: structural gaps to Architect, spec gaps to Doc-Writer, test coverage gaps to Tester.

### Architectural Risk Classification
- HIGH = violates a binding constraint or creates a cycle. Requires Architect sign-off before implementation.
- MEDIUM = introduces a new module tier or cross-tier dependency without spec update.
- LOW = changes within a single module without tier impact.

### Architecture Decisions Affecting Multiple Modules
Must produce: (1) updated `docs/architecture/` file or new ADR, (2) updated dependency direction note in affected specs, (3) a validator or audit rule that enforces the decision going forward.

### Five Module Tiers (low to high)
Foundations (math, log, data) → Core Runtime (runtime, event) → Platform Services (filesystem, window, audio, input) → Feature Systems (render, physics, sprite, animation, etc.) → Edge/Integration (lua_api, app, network). Any import from a lower tier to a higher tier is T-01 violation.

## References
- `docs/architecture/philosophy.md`
- `docs/architecture/engine-architecture.md`
- `docs/architecture/cag-system.md`
- `docs/specs/README.md`
- `.github/copilot-instructions.md`
