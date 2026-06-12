# Content Contract

## Mission & Scope
- Own Lua demos, examples, layouts, snippets, registries, and config templates.
- Keep content runnable, validator-safe, and aligned with public APIs.

## Files
- `examples/`: Single-file public API examples.
- `games/`: Runnable multi-file game demos.
- `layouts/`: TOML UI layouts.
- `snippets/`: Sources for VS Code snippets.

## Rules
- Use real `lurek.*` calls, not stubs or placeholder tables.
- Scale movement, fades, and tweens by `dt`.
- Keep state in locals, modules, or context tables; avoid globals.
- Use forward slashes in asset paths.
- Use `lurek.log.*` instead of raw print calls.
- Do not hide warnings with `.vscode/settings.json` or `---@diagnostic disable`.

## Workflow
- Read the nearest nested content contract first.
- Run only validators and smoke flows for the edited content type.
- For layouts, run `tools/ui/fix_layouts.py` and `tools/ui/snap_to_grid.py`, then verify visual output.
