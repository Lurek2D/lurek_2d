# Layouts Contract

Covers work under `content/layouts/`.

## Mission & Scope
- Own TOML UI layout coordinate files defining screen alignments, flexboxes, and node structures.
- Maintain coordinate alignment and syntax validity for all standalone apps and game layouts.
- Keep coordinate data structured and snapped to consistent pixel boundaries for multi-resolution support.

## Files
- `apps/`: UI layouts for standalone tools and debug overlays (e.g., settings panels, debugger).
- `games/`: In-game HUDs, health bars, inventory grids, and main menus.

## Rules
- Component IDs must use `snake_case` and remain unique within a single layout file.
- Always snap layout coordinates to an 8-pixel boundary to prevent subpixel layout rendering issues.
- Prefer dynamic flexbox directions, wrapping, and alignment properties over hardcoded coordinate offsets where possible.
- Never add custom/undocumented keys that are not supported by the engine layout deserializer.

## Workflow
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` to enforce grid snapping.
- Auto-format layout syntax using `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix`.
- Verify visual output with `tests/lua/evidence/test_gui_evidence.lua` or `content/games/tools/layout_toml_renderer/`.

## References
- tools/ui/snap_to_grid.py
- tools/ui/fix_layouts.py
- tests/lua/evidence/test_gui_evidence.lua
