# Docs Contract

## Mission & Scope
- Own source docs, specs, API reference inputs, templates, and design notes.
- Keep docs aligned with code, Lua annotations, and generated output.

## Files
- `specs/`: Module contracts and Lua signatures.
- `architecture/`: System design and platform constraints.
- `api/`: Generated API reference outputs.
- `templates/`: Doc, spec, role, and skill templates.

## Rules
- Do not edit generated API outputs directly; update source doc comments under `src/lua_api/`.
- Do not edit generated module specs directly; update `docs/specs/manual/<module>.md` for durable intent.
- Keep Markdown links valid after moves or renames.
- Treat `docs/meta/modules.toml` as the module metadata source of truth.
- Write contributor docs for developers and modders in clear terms.

## Workflow
- Run strict link checks after structural doc edits.
- Rebuild generated API refs only when binding docs or generator inputs change.
