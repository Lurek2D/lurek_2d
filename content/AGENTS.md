# Content Contract

Adds local rules for `content/`.

## Mission & Scope
- Own Lua game demos, API examples, layout assets, and editor snippets.
- Keep scripts, configs, and layouts runnable and validator-safe.
- Maintain content registries and default config templates.

## Files
- `examples/`: Single-file API examples.
- `games/`: Runnable multi-file game folders and indices.
- `layouts/`: TOML flexbox layouts for menus and overlays.
- `snippets/`: Source templates for the VS Code snippet generator.

## Rules
- Use fully functional `lurek.*` calls; do not add stub calls or placeholder tables.
- Scale movement, fades, and tweens by `dt`.
- Keep game state contained in local variables or context state tables; avoid global variable pollution.
- Format file lookup strings with forward slashes exclusively.
- Use `lurek.log.*` channels instead of raw print functions to support category filtering.
- Do not silence warnings in `.vscode/settings.json` or hide Lua API issues with `---@diagnostic disable`.


## Workflow
- Start from the nearest nested content contract before subtree-specific changes.
- Run only the validators and smoke flows that match the edited content type.
- For layout edits, use `tools/ui/fix_layouts.py` and `tools/ui/snap_to_grid.py`, then verify visual output.

## References
- `../library/`
- `../docs/specs/`
- `../tests/lua_reorg/`
