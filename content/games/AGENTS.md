# Games Contract

This file adds local rules for work under `content/games/`.

## Mission
- Own runnable demo and game folders under the category tree.
- Keep headless checks and real runtime entry points aligned.

## Scope
- `content/games/<category>/<name>/`
- Demo `main.lua` files and optional local config files.

## Local rules
- Each game folder needs a real `main.lua` entry point.
- `main.lua` should expose an entry callback (`lurek.init` or `lurek.load`), a tick callback (`lurek.process` or `lurek.update`), and `lurek.draw`.
- Optional `conf.toml` or `conf.lua` files must still declare meaningful window settings.
- Do not call `lurek.window.present` directly from demo code; headless checks treat that as a bug.
- Keep the category split honest: use the existing `action`, `arcade`, `apps`, `retro`, `rpg`, `showcase`, `simulation`, `sports`, `strategy`, and `test` buckets instead of inventing ad hoc top-level groupings.

## Workflow
- Read `tests/lua/demos/_common_checks.lua` before changing shared demo structure.
- Use the narrowest relevant `tests/lua/demos/test_<name>.lua` or other game-facing validation first.

## References
- `tests/lua/demos/_common_checks.lua`
- `tests/games_load_test.rs`
