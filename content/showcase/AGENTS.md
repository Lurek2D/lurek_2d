# Showcase Contract

## Mission & Scope
- Own runnable feature showcases and API labs that are not complete games.
- Keep `content/games/` focused on catalog-ready playable demos.

## Files
- `README.md`: Showcase shelf overview.
- `<category>/<name>/main.lua`: Optional runnable showcase entry point.
- `<category>/<name>/README.md`: Feature notes and run command when present.

## Rules
- Do not present showcase entries as complete games.
- Prefer `content/examples/` for small single-file API examples.
- Keep moved entries runnable when they already had a `main.lua`.

## Workflow
- Validate moved Lua with `python tools/validate/validate_game.py <showcase-dir>` when APIs change.
- Use `python tools/demos/smoke_sweep.py --kind game --games-root content/showcase --only <name>` for runnable smoke checks when needed.
