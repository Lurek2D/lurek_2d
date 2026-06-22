# Specs Contract

## Mission & Scope
- Own per-module contracts for `src/<module>/` and public Lua APIs.
- Keep generated sections separate from hand-written intent.

## Files
- `README.md`: Spec index and tiering guide.
- `SPEC_TEMPLATE.md`: New spec template.
- `manual/*.md`: Hand-written module intent overlays.
- `*.md`: Generated module specs.

## Rules
- Treat `docs/specs/*.md` as generated output.
- Edit `docs/specs/manual/<module>.md` for `TL;DR`, `Summary`, `Notes`, and architecture links.
- Edit source docstrings, tests, examples, or `docs/meta/modules.toml` when generated facts are wrong.
- Never copy generated spec prose back into Rust docstrings.
- Rebuild specs after Rust Lua API signature or docs metadata changes.

## Workflow
- Run `python tools/docs/gen_module_specs.py` or `python tools/gen_all_docs.py`.
- Run `python tools/validate/validate_module_coverage.py`.
- Run `python tools/audit/docs_quality.py`.
