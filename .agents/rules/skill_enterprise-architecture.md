---
trigger: model_decision
description: "Load this skill when writing, comparing, or governing high-level architecture across docs, artifacts, stakeholders, and validation rules. Skip it for module-level boundary fixes, engine implementation, or framework-specific TOGAF analysis."
---
# enterprise-architecture

## Mission
- Own high-level architecture doctrine, governance, artifact mapping, and cross-document structure above single-module design.

## When To Load
- Write or revise docs/architecture/ as system-level doctrine.
- Compare architecture principles, artifacts, and governance across repo surfaces.
- Decide where a rule belongs between docs/architecture, docs/specs, .github, tools/validate, and work/ artifacts.
- Map stakeholder, capability, repository, or lifecycle concerns without dropping straight into code structure.

## When To Skip
- Module boundaries, dependency direction, or crate layout.
- Engine implementation work.
- Pure TOGAF terminology or TOGAF gap analysis with no broader architecture decision.

## Domain Knowledge
- Architecture authority chain: binding constraints → engine structure → module contracts → CAG layer. Each tier may restrict but not contradict its parent.
- Five binding constraint categories each govern a distinct area: T = topology/cycles, A = scope limits, B = runtime stack, C = Lua namespace, TST = test placement. Cross-category constraint proposals require explicit philosophy.md changes, not just spec changes.
- A proposed architectural change is "settled" when it passes all three tests: consistent with binding constraints, reflected in at least one validated spec, has at least one enforcement mechanism. Aspirational diagrams without enforcement are not architecture.
- Governance gap pattern: when a codebase behavior diverges from its documented constraints, that is a governance gap, not a bug. Document the gap in `work/{session}/gaps/` and route it to the appropriate owner: structural gaps to Architect, spec gaps to Doc-Writer, test coverage gaps to Tester, CAG routing gaps to CAG-Architect.
- Architectural risk classification: HIGH = violates a binding constraint or creates a cycle; MEDIUM = introduces a new module tier or cross-tier dependency without spec update; LOW = changes within a single module without tier impact. Only HIGH risks require Architect sign-off before implementation.
- When mapping Lurek2D to an external framework, identify which existing repo artifact maps to each framework concept. Do not create new artifacts to satisfy a framework ceremony if an existing repo file already serves that role.
- Architecture decisions that affect more than one module must produce: updated docs/architecture/ file or new ADR, updated dependency direction note in affected specs, a validator or audit rule that enforces the decision going forward.
- The five module tiers in order: Foundations → Core Runtime → Platform Services → Feature Systems → Edge/Integration. Any import going from a higher tier to a lower tier is valid.

## Companion File Index
- None.

## References
- docs/architecture/philosophy.md
- docs/architecture/engine-architecture.md
- docs/architecture/cag-system.md
- docs/specs/README.md
- .github/copilot-instructions.md