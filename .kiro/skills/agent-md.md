---
inclusion: manual
---

# agent-md (Module Spec Structure)

## Mission
Own `docs/specs/<module>.md` structure, sync rules, and validation flow.

## When To Use
- Create a new merged module spec.
- Update `docs/specs/<module>.md` after source changes.
- Check section order or spec sync rules.

## When To Skip
- Rust implementation, test writing, Lua script work.

## Rules

### Spec Scope
- `docs/specs/<module>.md` describes exactly one module — one `src/<module>/` directory. If the spec describes two modules, split it.

### Required Sections
Overview, Ownership, Public API, Invariants, Dependencies, Test Coverage, References.
- Public API is auto-populated from docstrings via `python tools/docs/gen_module_specs.py`. Fix the Rust docstring, then regenerate. Never hand-edit auto-sections.

### Invariants Section
Must state: preconditions before any public function is called, postconditions guaranteed, and what the module refuses to do. An empty Invariants section is a coverage gap.

### Dependencies Section
Must list tier relationships: which tier this module belongs to, which lower-tier modules it imports from, and which higher-tier modules must NOT import from it. This enforces T-01/T-02.

### Ownership Language
Spec prose must answer: "I own X. I do not own Y (that is module Z's job). Callers must guarantee A. I guarantee B. Never call me during state C."

### Version of Truth
`docs/specs/<module>.md` is authoritative for what the module does, what it owns, and what it does not own.

### After Structural Changes
After any `src/` change (new module, renamed module, moved type), run `python tools/validate/validate_module_coverage.py`. It confirms the spec roster matches `src/` and that `docs/specs/README.md` has a row for each module.

### Retired Pattern
Do not recreate `src/<module>/AGENT.md` patterns — they are retired. All module-scoped documentation belongs in `docs/specs/<module>.md`.

### Archiving
When a module is removed or merged, move the old spec to an archive folder or add a `<!-- archived: merged into <module> -->` comment. Do not delete — historical specs are evidence for architecture decisions.

## References
- `docs/specs/`
- `docs/specs/SPEC_TEMPLATE.md`
- `tools/docs/gen_module_specs.py`
- `tools/validate/validate_module_coverage.py`
