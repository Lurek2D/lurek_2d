---
name: ui-layout
description: "Load this skill when designing or reviewing TOML UI layouts in content/layouts/ and related layout tools. Skip it for Rust UI code or Lua game logic."
---
# ui-layout

## Mission
- Own the TOML UI layout format: grid system, widget types, naming conventions, hierarchy rules, and the layout tooling pipeline.

## When To Load
- Creating or editing `content/layouts/*.toml` files.
- Choosing widget types or layout structure for a game screen.
- Running layout validation or rendering tools.
- Snapping coordinates to the grid system.

## When To Skip
- Rust engine UI code â€” see `src/ui/`.
- Lua game-logic scripting â€” use `lua-scripting` skill.

## Domain Knowledge
- TOML layout schema: every file has a `[root]` table with `widget_type`, `id`, `x`, `y`, `w`, `h` fields, then `[[root.children]]` array entries for child widgets. Supported `widget_type` values are: `panel`, `label`, `button`, `progressbar`, `checkbox`, `image`, `slider`, `list`.
- Coordinate system: x and y are top-left pixel offsets from the parent's top-left corner, not the screen origin. For root-level widgets, `x` and `y` are screen-absolute.
- Grid discipline: run `tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` to snap `x`, `y`, `w`, `h` to 8-pixel multiples. Run this before committing any layout change.
- How to validate a layout: run `tools/python.cmd tools/ui/render_layout.py content/layouts/games/my_layout.toml` to produce a PNG preview. Compare against the `.png` reference file that lives beside each `.toml` file.
- How to run `fix_layouts.py`: `tools/python.cmd tools/ui/fix_layouts.py content/layouts/` normalises field ordering, strips extra whitespace, and enforces TOML array formatting. Run it after hand-editing to avoid diff noise from formatting differences.
- ID naming rules: `snake_case`, prefixed by widget role. IDs must be unique within a file.
- `apps/` layouts are for standalone UI demos. `games/` layouts are in-game HUDs and menus.
## Companion File Index
- None.

## References
- content/layouts/
- tools/ui/
- src/ui/
