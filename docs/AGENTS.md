# Docs Contract

## Mission & Scope
- Own source docs, generated-reference inputs, contributor guidance, and templates.
- Keep docs aligned with code, Lua annotations, and generated output.

## Files
- `specs/`: Module contracts and Lua signatures.
- `architecture/`: System design and platform constraints.
- `api/`: Generated API reference outputs.
- `guides/`: Public user documentation.
- `contributing/`: Maintainer, build, quality, and CAG documentation.
- `templates/`: Contract, role, skill, and manual-overlay scaffolds.
- `assets/`: MkDocs logo and stylesheet.
- `meta/modules.toml`: Module registry consumed by documentation generators and audits.

## Rules
- Do not edit generated API outputs directly; update source doc comments under `src/lua_api/`.
- Do not edit generated module specs directly; update `docs/specs/manual/<module>.md` for durable intent.
- Keep Markdown links valid after moves or renames.
- Treat `docs/meta/modules.toml` as the module metadata source of truth.
- Keep architecture limited to current system boundaries and durable constraints.

## Workflow
- Run strict link checks after structural doc edits.
- Regenerate module guides after changing their generator or publishing route.
