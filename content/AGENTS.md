# Content Contract

## Mission & Scope
- Own Lua examples, layouts, snippets, registries, and config templates.
- Keep content runnable, validator-safe, and aligned with the public Lua API lifecycle.

## Files
- `examples/`: Single-file, per-API reference examples.
- `layouts/`: TOML UI layouts.
- `snippets/`: Sources for VS Code snippets.

## Rules
- Use real `lurek.*` calls, not stubs or placeholder tables.
- Keep examples, layouts, and snippets in their own child folders.
- Put finished games and reusable Lua packages in `lurek_2d_content/`.
- Scale movement, fades, and tweens by `dt`.
- Keep state in locals, modules, or context tables; avoid globals.
- Use forward slashes in asset paths.
- Use `lurek.log.*` instead of raw print calls.
- Do not hide warnings with local editor settings or diagnostic-disable comments.

## Workflow
- Run only validators and smoke flows for the edited content type.
- For examples, run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`.
- For layouts, run `tools/python.cmd tools/ui/fix_layouts.py` and `tools/python.cmd tools/ui/snap_to_grid.py`, then verify visual output.
