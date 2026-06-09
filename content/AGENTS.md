# Content Contract

Covers work under `content/`.

## Mission & Scope
- Own Lua-based game demos, API-teaching examples, layout coordinates assets, and editor snippet files.
- Keep all script examples, configs, and layout documents fully runnable and validate-safe.
- Maintain content-side registration lists and default config templates.

## Files
- `examples/`: Single-file scripts demonstrating individual API concepts.
- `games/`: Runnable multi-file game directories and category indices.
- `layouts/`: TOML-formatted flexbox configurations for menus and overlays.
- `snippets/`: Target templates consumed by the VS Code editor snippet generator.

## Rules
- Use fully functional `lurek.*` calls; do not add stub calls or placeholder tables.
- Scale frame-based movements, color fades, and tweens by delta time (`dt`) for frame-rate independence.
- Keep game state contained in local variables or context state tables; avoid global variable pollution.
- Format file lookup strings with forward slashes exclusively.
- Use `lurek.log.*` channels instead of raw print functions to support category filtering.
- Do not silence warnings in `.vscode/settings.json` or hide Lua API issues with `---@diagnostic disable`.


## Workflow
- Start from the nearest nested content contract (`content/examples/`, `content/games/`, `content/layouts/`, or `content/snippets/`) before making subtree-specific changes.
- Run only the validators and smoke flows that match the edited content type.
- For layout edits, use `tools/ui/fix_layouts.py` and `tools/ui/snap_to_grid.py`, then verify visual output.

## References
- `library/`
- `docs/specs/`
- `tests/lua/`
