# Layouts Contract

Adds local rules for `content/layouts/`.

## Mission & Scope
- Own TOML UI layout files for alignments, flexboxes, and nodes.
- Keep layouts valid for standalone apps and games.
- Keep coordinates structured and snapped to stable pixel boundaries.

## Files
- `apps/`: UI layouts for tools and debug overlays.
- `games/`: In-game HUDs, health bars, inventory grids, and main menus.

## Rules
- Component IDs must use `snake_case` and remain unique within a single layout file.
- Always snap layout coordinates to an 8-pixel grid.
- Prefer flexbox directions, wrapping, and alignment over hardcoded offsets when possible.
- Never add custom/undocumented keys that are not supported by the engine layout deserializer.

## Workflow
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` to enforce grid snapping.
- Auto-format layout syntax using `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix`.
- Verify visual output with GUI evidence tests or another checked-in layout render path.

## References
- tools/ui/snap_to_grid.py
- tools/ui/fix_layouts.py
- tests/lua/evidence/test_gui_evidence.lua
