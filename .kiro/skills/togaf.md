---
inclusion: manual
---

# togaf

## Mission
Own TOGAF terminology, source handling, and repo-to-TOGAF comparison logic.

## When To Use
- Research TOGAF concepts (ADM, Fundamental Content, architecture domains, Enterprise Continuum, governance).
- Compare Lurek2D docs, CAG artifacts, or validation rules to TOGAF concepts.
- Write TOGAF-aware architecture notes, gap analysis, or adoption cautions.

## When To Skip
- High-level architecture work that does not mention TOGAF.
- Module-boundary design or dependency fixes.
- Engine implementation, testing, or API naming.

## Rules

### Source of Truth
`docs/architecture/togaf.md` is the authoritative TOGAF alignment doc. Read it before any TOGAF-aware task. Never claim Lurek2D is TOGAF-compliant; the doc describes a TOGAF-aware architecture, not a certified one.

### Applying the ADM Lens
The ADM is a lifecycle, not a checklist. Map to Lurek2D concretely:
- Architecture requirements → binding constraints in `copilot-instructions.md`.
- Architecture decisions → `docs/architecture/philosophy.md`.
- Review and gate → `tools/validate/cag_validate.py`, `cargo clippy`, quality gates.

### Four Architecture Domains — Lurek2D Translations
- **Business** — contributor workflow, persona coverage, product adoption goals, license constraints.
- **Data** — Lua/TOML/JSON serialized formats, `lurek.serial`, `lurek.save`, runtime state contracts, generated docs schemas.
- **Application** — runtime subsystems (`src/<module>/`), Lua API surface (`lurek.*`), CAG agent layer, VS Code extension, library modules.
- **Technology** — Rust 1.78+, LuaJIT via mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9, CI toolchain.

### Identifying Gaps
Run the four-domain lens against the current docs inventory. When a domain is poorly documented, that is the gap to surface — not a requirement to add TOGAF boilerplate.

### Architecture Repository Mapping
- Architecture Principles = binding constraints in `copilot-instructions.md`.
- Architecture Decisions = `docs/architecture/philosophy.md`.
- Standards = quality gates and validator rules.
- Building blocks = module specs in `docs/specs/` and CAG skills in `.github/skills/`.
- Solutions = `content/games/` and `library/` modules.

### Governance Mapping
Architecture compliance checking = `python tools/validate/cag_validate.py` + `cargo clippy`. Change requests = GitHub issues/PRs. Architecture board = Manager + Architect routing.

### Avoid Checkbox Gap Analyses
If a TOGAF concept has no meaningful Lurek2D equivalent (e.g., procurement governance), name the mismatch explicitly and scope the comparison note rather than forcing a mapping.

## References
- `docs/architecture/togaf.md`
- `docs/architecture/philosophy.md`
- `docs/architecture/cag-system.md`
