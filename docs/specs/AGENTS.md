# Specs Contract

This file adds local rules for work under `docs/specs/`.

## Mission
- Own the per-module reference layer for `src/<module>/`.
- Keep manual intent and generated structure clearly separated.

## Scope
- `docs/specs/*.md` module spec files.
- `docs/specs/README.md` and spec navigation updates.
- Spec generator and validator sync for module coverage.

## Local map
- `README.md` is the index and production guide for the whole spec corpus.
- `SPEC_TEMPLATE.md` is the structure reference for new or reworked specs.
- `tools/docs/gen_module_specs.py` rebuilds the generated sections.
- `tools/validate/validate_module_coverage.py` is the coverage gate for top-level `src/` modules.

## Local rules
- Treat each `docs/specs/<module>.md` as the contract for one top-level `src/<module>/` directory.
- `## Summary` is hand-curated prose; `## General Info`, `## Imports`, `## Files`, and `## Lua API Ref` are generator-owned.
- Do not hand-edit generated sections; fix source annotations or generators and regenerate instead.
- Keep the spec index updated when modules are added, removed, renamed, or re-tiered.
- If a change affects `lurek.*`, keep the spec aligned with generated API docs and the matching example or test surfaces.

## Workflow
- Read the module source, its current spec, and the spec index before editing.
- Regenerate specs after structural module changes with `python tools/docs/gen_module_specs.py` or `python tools/gen_all_docs.py`.
- Run `python tools/validate/validate_module_coverage.py` after adding, removing, or renaming a top-level module.
- Run `python tools/audit/doc_coverage.py` when editing many specs or reshaping manual prose.

## References
- `docs/specs/README.md`
- `docs/templates/SPEC_TEMPLATE.md`
- `tools/docs/gen_module_specs.py`
- `tools/validate/validate_module_coverage.py`
