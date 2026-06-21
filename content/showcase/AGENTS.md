# Showcase Contract

## Mission & Scope
- Own runnable feature showcases, API labs, and app-like experiments that are not complete games.
- Keep `content/games/` focused on finished playable games and mini games.

## Files
- `README.md`: Showcase shelf overview.
- `<category>/<name>/main.lua`: Optional runnable showcase entry point.
- `<category>/<name>/README.md`: Feature notes and run command when present.

## Rules
- Do not present showcase entries as complete games.
- Prefer `content/examples/` for small single-file per-API examples.
- Prefer `tests/lua/evidence/` when the main value is a generated artifact or proof output rather than an interactive runnable lab.
- Use this folder for API demonstrations that need more room than one example block but still do not justify staying in `content/games/`.
- Do not keep thin scaffolds whose only value is "module boots without crashing" or "next step" notes; convert that value into module-owned evidence or delete the scaffold.
- Keep moved entries runnable when they already had a `main.lua`.

## Workflow
- Run `tools/python.cmd tools/demos/audit_showcase.py` before broad showcase cleanup.
- Validate moved Lua with `tools/python.cmd tools/validate/validate_game.py <showcase-dir>` when APIs change.
- Use `tools/python.cmd tools/demos/smoke_sweep.py --kind game --games-root content/showcase --only <name>` for runnable smoke checks when needed.
