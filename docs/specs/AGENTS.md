# Specs Contract

This file adds local rules for work under `docs/specs/`.

## Mission & Scope
- Own the per-module reference layer for internal and external APIs in `src/<module>/`.
- Keep hand-written intent and generated sections clearly separate.
- Maintain a complete coverage index so engine changes stay synced with specs.

## Files
- `README.md`: Master index and tiering guide for the specification corpus.
- `SPEC_TEMPLATE.md`: Template for new specs.
- `*.md` files such as `physics.md` and `render.md`: Module specs.

## Rules
- Treat each spec file as a strict contract; do not allow source implementation to drift from its specification.
- The `## Summary` section is hand-written. `## General Info`, `## Imports`, `## Files`, and `## Lua API Ref` are generator-owned and must not be edited by hand.
- When adding, removing, or tiering a top-level module, update the catalog entries in the main index.
- If a Lua API function signature is updated in Rust code, the specification must be rebuilt to reflect the exact changes.

## Workflow
- Rebuild spec layouts using `python tools/docs/gen_module_specs.py` or `python tools/gen_all_docs.py`.
- Run coverage verification using `python tools/validate/validate_module_coverage.py`.
- Audit doc completeness with `python tools/audit/doc_coverage.py`.

## References
- docs/specs/README.md
- docs/templates/SPEC_TEMPLATE.md
- tools/docs/gen_module_specs.py
- tools/validate/validate_module_coverage.py
