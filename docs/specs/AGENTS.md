# Specs Contract

This file adds local rules for work under `docs/specs/`.

## Mission & Scope
- Own the per-module reference layer detailing internal and external APIs for every `src/<module>/` package.
- Keep hand-written architectural intent and programmatically generated documentation clearly separated.
- Maintain a complete coverage index, ensuring that all engine changes sync with their respective specifications.

## Files
- `README.md`: Master index and tiering guide for the specification corpus.
- `SPEC_TEMPLATE.md`: Template outline showing the required section layout for a new specification.
- `*.md` files (e.g., `physics.md`, `render.md`): Module-specific specifications.

## Rules
- Treat each spec file as a strict contract; do not allow source implementation to drift from its specification.
- The `## Summary` section is hand-curated; the sections `## General Info`, `## Imports`, `## Files`, and `## Lua API Ref` are generator-owned and must never be edited manually.
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
