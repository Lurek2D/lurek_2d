# Content Contract

## Mission & Scope
- Own Lua examples, games, layouts, snippets, registries, and config templates.
- Keep content runnable, validator-safe, and aligned with the public Lua API lifecycle.

## Files
- `examples/`: Single-file, per-API reference examples.
- `games/`: Finished playable games and mini games only.
- `layouts/`: TOML UI layouts.
- `snippets/`: Sources for VS Code snippets.

## Rules
- Use real `lurek.*` calls, not stubs or placeholder tables.
- Keep the ownership chain clear: public API docs feed `content/examples/`, examples feed Lua unit tests, evidence/golden prove selected behavior, and only complete products belong in `content/games/`.
- API examples must use exact `--@api:` marker-owned `do ... end` blocks; do not add shared helpers or setup outside those blocks.
- Put API showcases, mechanic labs, and feature demonstrations in `content/examples/` or `tests/lua/evidence/`, not in `content/games/`.
- Scale movement, fades, and tweens by `dt`.
- Keep state in locals, modules, or context tables; avoid globals.
- Use forward slashes in asset paths.
- Use `lurek.log.*` instead of raw print calls.
- Do not hide warnings with `.vscode/settings.json` or `---@diagnostic disable`.

## Workflow
- Read the nearest nested content contract first.
- Run only validators and smoke flows for the edited content type.
- For examples, run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`; for games, use `tools/python.cmd tools/demos/audit_games.py` first and `tools/python.cmd tools/demos/gen_demo_catalog.py` only after the catalog metadata is current.
- For layouts, run `tools/ui/fix_layouts.py` and `tools/ui/snap_to_grid.py`, then verify visual output.
