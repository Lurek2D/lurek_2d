# Games Contract

Covers work under `content/games/`.

## Mission
- Own runnable demo and game folders under the category tree.
- Keep headless checks and runtime entry points aligned.

## Scope
- `content/games/<category>/<name>/`.
- Demo `main.lua` files and optional local config files.

## Local map
- Category folders group runnable projects.
- `main.lua` is the required entry point.
- `conf.toml` and `conf.lua` are optional local config files.

## Rules
- Each game folder needs a real `main.lua`.
- `main.lua` should expose an entry callback, a tick callback, and `lurek.draw`.
- Optional config files must still declare meaningful window settings.
- Do not call `lurek.window.present` directly from demo code.
- Use the existing category buckets instead of inventing ad hoc top-level groups.

## Workflow
- Read `tests/lua/demos/_common_checks.lua` before changing shared demo structure.
- Use the narrowest relevant `tests/lua/demos/test_<name>.lua` or other game-facing validation first.

## References
- `tests/lua/demos/_common_checks.lua`
- `tests/games_load_test.rs`
