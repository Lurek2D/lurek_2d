# Layouts Contract

Covers work under `content/layouts/`.

## Mission
- Own TOML UI layout assets used by the engine UI system.
- Keep layout data clean, grid-aligned, and compatible with engine evidence paths.

## Scope
- `content/layouts/apps/` and `content/layouts/games/`.
- TOML layout authoring conventions and layout maintenance helpers.

## Local map
- `apps/` is for standalone application layouts.
- `games/` is for in-game HUD or menu layouts.

## Rules
- Use `snake_case` IDs and keep them unique within a file.
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` before finalizing coordinate-heavy edits.
- Run `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix` after hand-editing.
- Do not rely on the removed `tools/ui/render_layout.py` flow.

## Workflow
- Use engine-driven validation paths such as `tests/lua/evidence/test_gui_evidence.lua` or the layout renderer game under `content/games/tools/` when you need visual proof.

## References
- `tools/ui/snap_to_grid.py`
- `tools/ui/fix_layouts.py`
- `tests/lua/evidence/test_gui_evidence.lua`
- `content/games/tools/layout_toml_renderer/`
