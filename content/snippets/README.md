# Lurek2D Snippet System

`content/snippets/` owns handcrafted Lua snippet sources that generate IDE autocomplete templates for the VS Code extension.

## Purpose

- Snippets are reusable gameplay and tooling building blocks, not one-file API examples.
- Source-of-truth files live in `content/snippets/*.lua`.
- Generated VS Code snippets live in `lurek_2d_extension/data/snippets.json`.

## Why This Exists

- Non-AI workflows need fast scaffolding for common game patterns.
- `content/examples/*.lua` focuses on public API demonstration, not reusable authoring blocks.
- Snippet coverage should be measured per module, not by strict per-function parity.
- Every snippet should be justified by a real use case and composed from actual `lurek.*` calls.

## File Format

Each snippet block uses strict markers:

- `-- @snippet <symbol>`
- `-- @prefix <trigger>`
- `-- @module <module>`
- `-- @description <text>`
- `-- @body`
- body lines
- `-- @end`

Template file: `content/snippets/_template.lua`

## Placeholder Model

Source files use Lua-valid placeholder tokens:

- `SNIP_1_state`
- `SNIP_2_arg1`
- `SNIP_10_event_name`

The generator converts them into VS Code placeholders in output JSON:

- `${1:state}`
- `${2:arg1}`
- `${10:event_name}`

This keeps snippet source files parseable by Lua tooling while still giving tab-stop UX in VS Code.

## Commands

Generate the VS Code snippet artifact:

```powershell
tools/python.cmd tools/snippets/gen_vscode_snippets.py
```

Validate snippet source and generated JSON:

```powershell
tools/python.cmd tools/validate/validate_snippets.py
```

Coverage report per module:

```powershell
tools/python.cmd tools/audit/snippet_coverage.py
```

## Coverage Model

Coverage is module-level:

- API item count per module comes from `logs/data/lua_api_data.json`.
- Snippet count per module comes from `-- @snippet` blocks in `content/snippets/<module>.lua`.
- The main metric is snippets per 100 API items.
