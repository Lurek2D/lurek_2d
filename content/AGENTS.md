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
- Keep the ownership chain clear: public API docs feed `content/examples/`, examples feed Lua unit tests, and evidence/golden prove selected behavior.
- API examples must use exact `--@api:` marker-owned `do ... end` blocks; do not add shared helpers or setup outside those blocks.
- Put API showcases, mechanic labs, and feature demonstrations in `content/examples/` or `tests/lua/evidence/`; finished products belong in the separate content repository.
- Scale movement, fades, and tweens by `dt`.
- Keep state in locals, modules, or context tables; avoid globals.
- Use forward slashes in asset paths.
- Use `lurek.log.*` instead of raw print calls.
- Do not hide warnings with `.vscode/settings.json` or `---@diagnostic disable`.

## Workflow
- Run only validators and smoke flows for the edited content type.
- For examples, run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`.
- For layouts, run `tools/ui/fix_layouts.py` and `tools/ui/snap_to_grid.py`, then verify visual output.
