---
trigger: model_decision
description: "Load this skill when researching TOGAF, mapping repo architecture to TOGAF concepts, or writing TOGAF-aware gap analysis and governance notes. Skip it for generic architecture work with no TOGAF angle, module structure fixes, or engine implementation."
---
# togaf

## Mission
- Own TOGAF terminology, source handling, and repo-to-TOGAF comparison logic.

## When To Load
- Research TOGAF concepts such as ADM, Fundamental Content, Series Guides, architecture domains, Enterprise Continuum, repository, or governance.
- Compare Lurek2D docs, CAG artifacts, or validation rules to TOGAF concepts.
- Write TOGAF-aware architecture notes, gap analysis, or adoption cautions.
- Decide whether a TOGAF concept should stay an analysis lens or become a repo convention.

## When To Skip
- High-level architecture work that does not mention TOGAF or enterprise architecture frameworks.
- Module-boundary design or dependency fixes.
- Engine implementation, testing, or API naming.

## Domain Knowledge
- docs/architecture/togaf.md is the authoritative TOGAF alignment doc for this repo. Read it before any architecture comparison or TOGAF-aware task — it defines the four-domain mapping, artifact taxonomy, governance model, and scope boundaries.
- **How to apply the ADM lens.** The Architecture Development Method is a lifecycle, not a checklist. When assessing Lurek2D, ask: where does the repo express architecture requirements, where does it capture architecture decisions, and where does it review and gate changes?
- **How to map the four architecture domains.** For Lurek2D, translate B/D/A/T concretely: Business = contributor workflow, persona coverage, product adoption goals, and license constraints. Data = Lua/TOML/JSON serialized formats, lurek.serial, lurek.save, runtime state contracts, and generated docs schemas.
- **How to identify gaps using TOGAF.** Run the four-domain lens against the current docs inventory: does each domain have a governing spec? Does the architecture repository contain viewpoints for all four domains?
- **How to use Enterprise Continuum.** Map architecture assets on the spectrum from generic to specific. Generic assets belong in docs/architecture/; specific assets belong in agent/skill files and specs.
- **Architecture repository mapping.** Lurek2D already has a lightweight architecture repository. The mapping is: Architecture Principles = binding constraints in copilot-instructions.md.
- **Governance and change control.** TOGAF governance maps to the repo quality gates and CAG validator chain. Architecture compliance checking = python ttttools/validate/cag_validate.py + cargo clippy.
- Avoid checkbox gap analyses. If a TOGAF concept has no meaningful Lurek2D equivalent, name the mismatch explicitly and scope the comparison note rather than forcing a mapping that adds no insight.
## Companion File Index
- None.

## References
- docs/architecture/togaf.md
- docs/architecture/philosophy.md
- docs/architecture/cag-system.md
- .github/agents/aarchitect.agent.md
- .github/agents/cag-aarchitect.agent.md