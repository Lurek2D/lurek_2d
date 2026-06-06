---
inclusion: manual
---

# ui-layout

## Mission
Own the TOML UI layout format: grid system, widget types, naming conventions, hierarchy rules, and the layout tooling pipeline.

## When To Use
- Creating or editing `content/layouts/*.toml` files.
- Choosing widget types or layout structure for a game screen.
- Running layout validation or rendering tools.
- Snapping coordinates to the grid system.

## When To Skip
- Rust engine UI code (`src/ui/`), Lua game-logic scripting.

## Rules

### TOML Layout Schema
Every file has a `[root]` table with `widget_type`, `id`, `x`, `y`, `w`, `h` fields, then `[[root.children]]` array entries for child widgets. Supported `widget_type` values: `panel`, `label`, `button`, `progressbar`, `checkbox`, `image`, `slider`, `list`. Check `content/layouts/games/fps_hud.toml` for a minimal real example.

### Coordinate System
x and y are top-left pixel offsets from the parent's top-left corner, not the screen origin. For root-level widgets, `x` and `y` are screen-absolute. Viewport comment at the top of each file (e.g., `# Viewport: 1280 × 720`) documents the design canvas size.

### Grid Discipline
Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive` to snap geometry to 8-pixel multiples before committing. Fine adjustments use `--grid 4`. The tool only modifies geometry fields.

### Validation
Run `python tools/ui/render_layout.py content/layouts/games/my_layout.toml` to produce a PNG preview. Compare against the `.png` reference file beside each `.toml` file. If rendered output differs from the reference, that is a visual regression. Update the reference PNG in the same commit as the layout change.

### fix_layouts.py
`python tools/ui/fix_layouts.py content/layouts/` normalizes field ordering, strips extra whitespace, and enforces TOML array formatting. Run after hand-editing.

### ID Naming Rules
`snake_case`, prefixed by widget role (e.g., `hp_bar`, `score_label`, `pause_btn`). IDs must be unique within a file. IDs are referenced from Lua via `lurek.ui.getElementById("id")` — changing an ID breaks the wiring silently.

### Category Separation
- `apps/` — standalone UI demos (calculator, login form, dashboard). Should not assume a game is running.
- `games/` — in-game HUDs and menus. Should assume a game is running.
Do not add game-specific IDs (e.g., `hp_bar`) to `apps/` layouts.

## References
- `content/layouts/`
- `tools/ui/`
- `src/ui/`
