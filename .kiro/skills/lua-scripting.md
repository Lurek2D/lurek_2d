---
inclusion: manual
---

# lua-scripting

## Mission
Own Lua game-script structure, `lurek.*` usage, and script-level clarity.

## When To Use
- Write a Lua game script.
- Review `lurek.*` usage in content or tests.
- Build a script example or demo.
- Check Lua-side structure and callback flow.

## When To Skip
- Engine Rust code, public API design.

## Rules

### Namespace Rule
Use `lurek.*` only. No bare globals, no engine-prefixed names, no alternative top-level tables. A script calling `engine.draw()` or bare `draw()` is broken.

### State Lifecycle
- `lurek.game.on_init` — sets up state.
- `lurek.game.on_process(dt)` — mutates state.
- `lurek.game.on_render` — draws from state.

Do not mutate game state inside `on_render`. Do not call draw functions inside `on_process`. Mixing these callbacks causes undefined behavior.

### Delta Time
Multiply all movement, physics, tween, and timer increments by `dt`. Hardcoded per-frame increments break at non-60-FPS rates and in headless tests.

### Local Variable Scope
Keep state in `local` variables or explicit state tables, never in module-level upvalues that persist across scene transitions. Stale upvalues from a previous scene are a common source of hard-to-trace bugs.

### Asset Paths
Must be relative to the game's content root (the folder containing `conf.lua`). Use forward slashes. Never hardcode absolute paths or `..` traversal — GameFS will reject them.

### Content Structure
- `content/examples/<module>/` — single-concept demos for one API.
- `content/games/<name>/` — multi-file playable demos with `conf.lua` and `main.lua`.
- `tests/lua/unit/` — assertion-only proof files that call `test_summary()` at the end.
Do not mix these styles.

### Test Assertions
Harness-registered Lua test files must end with `test_summary()` and use `assert_equal`, `assert_true`, `assert_false`, `assert_near` from the test harness. Do not use plain `assert()`.

### Library Usage
`local Inv = lurek.require("library/inventory")`. The library must not call `lurek.game.on_*` — it provides state and logic that the game script wires to callbacks.

### Validation
Run `python tools/validate/validate_game.py` on new game folders to verify `conf.lua` structure, required files, and harness registration before committing.

## References
- `content/games/`
- `content/examples/`
- `tests/lua/`
- `docs/api/lurek.md`
