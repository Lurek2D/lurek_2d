---
name: lua-scripting
description: "Load this skill when writing or reviewing Lua game scripts and lurek.* usage. Skip it for engine Rust or API design."
---
# lua-scripting

## Use when
- Write a Lua game script.
- Review lurek.* usage in content or tests.
- Build a script example or demo.
- Check Lua-side structure and callback flow.

## Avoid when
- Engine Rust code.
- Public API design.

## Repo rules
- Use `lurek.*` only â€” no bare globals, no engine-prefixed names, no alternative top-level tables. All public engine API is under `lurek.*`.
- State lifecycle rule: `lurek.game.on_init` sets up state, `lurek.game.on_process(dt)` mutates state, `lurek.game.on_render` draws from state. Do not mutate game state inside `on_render`; do not call draw functions inside `on_process`.
- Multiply all movement, physics, tween, and timer increments by `dt`. Hardcoded per-frame increments break at non-60-FPS rates and in headless tests.
- Local variable scope: keep state in `local` variables or explicit state tables, never in module-level upvalues that persist across scene transitions. Stale upvalues from a previous scene are a common source of hard-to-trace bugs.
- Asset paths must be relative to the game's content root. Use forward slashes.
- Content structure: `content/examples/<module>/` holds single-concept demos for one API; `content/games/<name>/` holds multi-file playable demos with a `conf.lua` and `main.lua`; `tests/lua/unit/` holds assertion-only proof files that call `test_summary()` at the end. Do not mix these styles.
- When writing a demo or example, every `lurek.*` call used must also appear in `docs/api/lurek.md`. If you find a call that does not appear there, either it is undocumented or it is a private function that should not be called from content.
- Harness-registered Lua test files must end with `test_summary()` and use `assert_equal`, `assert_true`, `assert_false`, `assert_near` from the test harness. Do not use plain `assert()` â€” it gives no context on failure.
- Library modules under `library/<name>/init.lua` expose a single table. Usage: `local Inv = lurek.require("library/inventory")`.
- `conf.lua` fields map directly to `src/runtime/config.rs` fields. The source of truth for valid keys and defaults is that file.
- Run `python tools/validate/validate_game.py` on new game folders to verify `conf.lua` structure, required files, and harness registration before committing.

## Checks
- `python tools/validate/validate_game.py`

## References
- `content/games/`
- `content/examples/`
- `tests/lua/`
- `docs/api/lurek.md`

