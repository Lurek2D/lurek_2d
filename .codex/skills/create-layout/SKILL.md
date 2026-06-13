---
name: create-layout
description: "Load this skill when creating or modifying TOML UI layouts under content/layouts and producing visual/evidence validation. Skip it for HTML UI, engine renderer internals, or non-layout Lua examples."
---
# create-layout

## Mission
- Create or modify layout assets that follow current content rules and visual evidence expectations.

## When To Load
- Creating or modifying TOML UI layouts under content/layouts and producing visual/evidence validation.

## When To Skip
- HTML UI, engine renderer internals, or non-layout Lua examples.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing layouts and UI primitives before editing.
- Modify a matching layout when present; create a new TOML layout only when no existing asset owns the screen.
- Keep layout dimensions, anchors, and naming consistent with content conventions.
- Run snap-to-grid and layout fixer after hand edits.
- Render evidence or preview output and iterate on visual alignment.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `content/AGENTS.md`, `content/layouts/AGENTS.md`, `content/examples/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content layouts TOML UI primitives" --profile game --limit 10`, `tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive`, `tools/python.cmd tools/ui/fix_layouts.py content/layouts/ --recursive --fix`, `tests/lua/evidence/test_ui_evidence.lua`
- Owner profile: `content`

## Common RAG Queries
- Use when locating current UI layout conventions:
  - `content layouts TOML UI primitives`
  - `content layouts button label stack`
  - `hud menu overlay layout`
- Common areas to inspect after top hits:
  - `content/layouts/`
  - `content/games/`
  - `docs/` UI or layout notes
  - rendering support in `src/`

## References
- `contracts: content/AGENTS.md, content/layouts/AGENTS.md, content/examples/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content layouts TOML UI primitives" --profile game --limit 10, tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive, tools/python.cmd tools/ui/fix_layouts.py content/layouts/ --recursive --fix, tests/lua/evidence/test_ui_evidence.lua`
- `agent: content`
