# Layouts Contract

This file adds local rules for work under `content/layouts/`.

## Mission
- Own TOML UI layout assets consumed by the engine UI system.
- Keep layout data clean, grid-aligned, and compatible with engine-driven evidence paths.

## Scope
- `content/layouts/apps/`
- `content/layouts/games/`
- TOML layout authoring conventions and layout maintenance helpers.

## Local rules
- Keep `apps/` for standalone application-style layouts and `games/` for in-game HUD or menu layouts.
- Use `snake_case` IDs and keep them unique within a file.
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` before finalizing coordinate-heavy edits.
- Run `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix` after hand-editing to normalize formatting and field order.
- Do not rely on the removed `tools/ui/render_layout.py` flow; layout rendering evidence now goes through the engine path.

## Workflow
- Use engine-driven validation paths such as `tests/lua/evidence/test_gui_evidence.lua` or the layout renderer game under `content/games/tools/` when you need visual proof.

## References
- `tools/ui/snap_to_grid.py`
- `tools/ui/fix_layouts.py`
- `tests/lua/evidence/test_gui_evidence.lua`
- `content/games/tools/layout_toml_renderer/`
