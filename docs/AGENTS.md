# Docs Contract

Covers work under `docs/`.

## Mission
- Own repository docs, specs, contributor docs, and generated-doc policy.
- Keep docs aligned with code and generators.

## Scope
- `docs/specs/`, `docs/architecture/`, `docs/api/`, and `docs/templates/`.
- Root docs, indexes, and contributor-facing references.

## Local map
- `specs/` is the contract layer for module behavior.
- `architecture/` holds design doctrine and migration notes.
- `api/` is generated output.
- `templates/` holds starter files for repo-local docs and guidance.
- `modules/` and `wiki/` are downstream surfaces.
- Root topic docs are downstream surfaces.

## Rules
- Treat `docs/specs/` as canonical.
- Do not hand-edit generated API output.
- Resolve code drift before expanding prose.
- Update the spec before dependent docs.
- Keep one audience per section.
- When Lua API docs drift, fix `src/lua_api/` and regenerate.
- After large doc reshapes, run `python tools/audit/doc_coverage.py`.

## Workflow
- Read the production code and affected spec first.
- Update the spec, then the index, then dependent docs.
- Preserve manual `Summary` content in `docs/specs/` and regenerate structure.

## References
- `docs/specs/`
- `CONTRIBUTING.md`
- `README.md`
- `docs/templates/`
