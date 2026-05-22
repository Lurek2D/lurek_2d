# tools/ui/

Standalone utilities for Lurek2D UI layout tooling.
Grid snapping and layout fixing are Python utilities; PNG rendering is now engine-driven.

## Engine Layout Renderer — Layout PNG Preview

Layout PNG previews are rendered by the Lurek2D engine runtime itself.
Use the dedicated renderer game at `content/games/tools/layout_toml_renderer`.

### Usage

```powershell
# Render TOML layouts to PNG via engine runtime
cargo run --bin lurek2d -- content/games/tools/layout_toml_renderer

# Output PNG files are written into save/layout_toml_renderer/
```

### Layout file format

A layout file is a `.toml` file with a `[root]` section (a `WidgetDef` tree).

Resolution (output PNG size) is determined in this order:
1. `resolution = [1280, 720]`  — top-level explicit key  (**preferred**)
2. `root.w` × `root.h`         — root widget size
3. `1280 × 720`                 — hardcoded fallback

## snap_to_grid.py — Snap layouts to grid

Snap every pixel-coordinate field in Lurek2D TOML layout files to a grid (default 8 px). Idempotent.

```powershell
python tools/ui/snap_to_grid.py content/layouts/hud.layout.toml
python tools/ui/snap_to_grid.py --all content/ --grid 8
python tools/ui/snap_to_grid.py --all content/ --dry-run
```

## fix_layouts.py — Repair layout files

Validate and auto-repair common errors in TOML layout files: missing widget IDs, out-of-bounds coordinates, malformed widget tables.

```powershell
python tools/ui/fix_layouts.py content/layouts/hud.layout.toml
python tools/ui/fix_layouts.py --all content/ --dry-run
```

## Filename index

`fix_layouts.py`, `snap_to_grid.py`

