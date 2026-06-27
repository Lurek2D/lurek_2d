# Layouts Contract

## Mission & Scope
- Own TOML UI layouts for apps, games, HUDs, menus, and overlays.
- Keep layout files valid, stable, and visually verifiable.

## Files
- `apps/`: Tool and debug overlay layouts.
- `games/`: In-game UI layouts.

## Rules
- Use unique `snake_case` component IDs per file.
- Snap coordinates to an 8-pixel grid.
- Use `w` and `h` geometry keys, not `width` or `height`.
- Use bitmap font sizes supported by validators: 8, 10, 12, 16, 20, 24, or 30.
- Prefer flexbox direction, wrapping, and alignment over hardcoded offsets.
- Do not add keys unsupported by the engine layout deserializer.

## Workflow
- Run `python tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive`.
- Run `python tools/ui/fix_layouts.py content/layouts/ --recursive --fix`.
- Verify rendered output with checked-in visual or GUI evidence tests.
