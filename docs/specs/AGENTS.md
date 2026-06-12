# Specs Contract

## Mission & Scope
- Own per-module contracts for `src/<module>/` and public Lua APIs.
- Keep generated sections separate from hand-written intent.

## Files
- `README.md`: Spec index and tiering guide.
- `SPEC_TEMPLATE.md`: New spec template.
- `*.md`: Module specs.

## Rules
- Treat each spec as a strict source/behavior contract.
- `## Summary` is hand-written.
- `## General Info`, `## Imports`, `## Files`, and `## Lua API Ref` are generator-owned.
- Update `README.md` when adding, removing, or retiering top-level modules.
- Rebuild specs after Rust Lua API signature changes.

## Workflow
- Run `python tools/docs/gen_module_specs.py` or `python tools/gen_all_docs.py`.
- Run `python tools/validate/validate_module_coverage.py`.
- Run `python tools/audit/doc_coverage.py`.
