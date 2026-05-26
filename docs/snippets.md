# Snippet System (Lua + VS Code)

## TL;DR

- This system provides high-utility Lua snippets for developers working without AI assistance.


## Purpose


The target is reusable gameplay building blocks, not single-API examples.

Source-of-truth files are handcrafted and live in `content/snippets/*.lua`.
Generated VS Code snippets live in `extensions/vscode/data/snippets.json`.

## Why This Exists

- Non-AI workflow needs fast scaffolding for common game patterns.
- Existing `content/examples/*.lua` focuses on API showcasing, not production building blocks.
- Snippet coverage should be measured per module, not by strict per-function parity.
- Every snippet should be manually justified from real use-cases, API behavior, and existing Rust/examples evidence.

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

Generator converts them into VS Code placeholders in output JSON:

- `${1:state}`
- `${2:arg1}`
- `${10:event_name}`

This keeps snippet source files parseable by Lua tooling while still giving tab-stop UX in VS Code.

## Handcrafted Rule

- No mass auto-generation of snippet source files.
- Each snippet must have a concrete usage rationale in `@description` (when/why to use it).
- Snippet body should compose multiple APIs into one reusable workflow block.

## Commands

Generate VS Code snippet artifact:

`python tools/snippets/gen_vscode_snippets.py`

Validate snippet source and generated JSON:

`python tools/validate/validate_snippets.py`

Coverage report per module:

`python tools/audit/snippet_coverage.py`

## Coverage Model

Coverage is module-level:

- API item count per module: from `logs/data/lua_api_data.json`
- Snippet count per module: count of `-- @snippet` blocks in `content/snippets/<module>.lua`
- Metric: snippets per 100 API items

Report output:

- `logs/reports/snippet_coverage.md`

## Research Notes (Love2D / Godot / Solar2D)

Research focus was practical snippet ergonomics in VS Code ecosystems:

- Love2D extensions in marketplace emphasize autocomplete and generators; snippet-oriented packs exist (for example `lwz7512.love2d-made-easy`, `abyo-software.love2d-dev-tools`).
- Godot tooling in VS Code (`geequlim.godot-tools`) emphasizes language features, debugger, and typed workflows more than dedicated snippet catalogs.
- Solar2D/Corona snippet packs were not consistently discoverable in current marketplace query results, which suggests relying on first-party snippet catalogs inside this repo is safer than external dependence.

Design decision for Lurek2D:

- Keep snippet content first-party in `content/snippets/`.
- Keep snippet authoring handcrafted and domain-driven.
- Keep JSON generation deterministic and local.
- Keep module coverage auditable in CI-style scripts.
