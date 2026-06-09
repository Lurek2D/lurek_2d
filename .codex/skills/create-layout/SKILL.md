---
name: create-layout
description: "Create or update new user interface layout and review it, regenerate to png."
---
# create-layout

## Goal
- Design and author a TOML UI layout under `content/layouts/`, review its structure, and generate visual previews.

## Required inputs
- Layout name
- UI components and hierarchy
- User must define the required UI elements and their visual arrangement
- Agent must collect available UI primitives from the engine

## Profile hint
- `content`

## Read these contracts
- `content/AGENTS.md`
- `content/layouts/AGENTS.md`
- `content/examples/AGENTS.md`

## Steps
- Read the listed contracts before authoring the layout.
- Author the UI layout in TOML format within `content/layouts/apps/` or `content/layouts/games/`, explicitly setting anchors, alignment, and hierarchical node structures.
- Write a small Lua script under `content/examples/` or use the existing evidence harness to load the new TOML file.
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` and `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix` after hand editing.
- Use `tests/lua/evidence/test_gui_evidence.lua` to render the layout and verify the generated PNG preview. If anchors are misaligned or the evidence path fails, adjust the TOML file and rerun the evidence flow.

## Outputs
- TOML layout file
- Generated PNG preview
- Supporting Lua evidence or load script

## Success criteria
- [ ] The TOML parser exits with code 0 (0 syntax errors).
- [ ] 1 valid PNG file is successfully generated reflecting the intended layout.

## Stop conditions
- Using hardcoded pixel values where relative anchors are required.
- Defining invalid or unsupported style properties in TOML.

## References
- `contracts: content/AGENTS.md, content/layouts/AGENTS.md, content/examples/AGENTS.md`
- `tools: python tools/ui/snap_to_grid.py, python tools/ui/fix_layouts.py, tests/lua/evidence/test_gui_evidence.lua`
- `agent: content`


