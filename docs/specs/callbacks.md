# callbacks

## TL;DR

Global `lurek.*` callbacks are documented here as a dedicated generated spec, independent from thin-wrapper module specs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `30` engine callbacks
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `logs/data/lua_api_data.json` (`engine_callbacks`) so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`).

## Imports

- Global callback contracts are sourced from `logs/data/lua_api_data.json` (`engine_callbacks`).

## Files

### callback contracts

- Generated from engine callback metadata extracted during Lua API data generation.

## Lua API Ref

### Callback Inventory

- `lurek.draw() -> nil`: Called every frame for world rendering.
- `lurek.draw_ui() -> nil`: Called every frame after `draw` for UI rendering.
- `lurek.errorhandler(msg) -> nil`: Called for unhandled Lua errors.
- `lurek.exit() -> nil`: Called when the engine is shutting down.
- `lurek.fixedUpdate(dt) -> nil`: Deprecated alias for `process_physics`.
- `lurek.focus(has_focus) -> nil`: Called when window focus changes.
- `lurek.gamepadaxis(id, axis, value) -> nil`: Called when a gamepad axis value changes.
- `lurek.gamepadpressed(id, button) -> nil`: Called when a gamepad button is pressed.
- `lurek.gamepadreleased(id, button) -> nil`: Called when a gamepad button is released.
- `lurek.init() -> nil`: Called once when the engine initialises.
- `lurek.joystickadded(id) -> nil`: Called when a gamepad is connected.
- `lurek.joystickremoved(id) -> nil`: Called when a gamepad is disconnected.
- `lurek.keypressed(key, scancode, isrepeat) -> nil`: Called when a keyboard key is pressed.
- `lurek.keyreleased(key, scancode) -> nil`: Called when a keyboard key is released.
- `lurek.mousemoved(x, y, dx, dy) -> nil`: Called when the mouse cursor moves.
- `lurek.mousepressed(x, y, button) -> nil`: Called when a mouse button is pressed.
- `lurek.mousereleased(x, y, button) -> nil`: Called when a mouse button is released.
- `lurek.process(dt) -> nil`: Called every frame for variable-step gameplay logic.
- `lurek.process_late(dt) -> nil`: Called every frame after `process`.
- `lurek.process_physics(dt) -> nil`: Called on the fixed physics step.
- `lurek.quit() -> boolean?`: Called before shutdown; return true to cancel quit.
- `lurek.ready() -> nil`: Called once after init, when runtime state is ready.
- `lurek.resize(w, h) -> nil`: Called when window size changes.
- `lurek.textedited(text, start, length) -> nil`: Called when IME composition text changes.
- `lurek.textinput(text) -> nil`: Called when text input is received.
- `lurek.touchmoved(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point moves.
- `lurek.touchpressed(id, x, y, dx, dy, pressure) -> nil`: Called when a touch begins.
- `lurek.touchreleased(id, x, y, dx, dy, pressure) -> nil`: Called when a touch ends.
- `lurek.visible(is_visible) -> nil`: Called when window visibility changes.
- `lurek.wheelmoved(x, y) -> nil`: Called when the mouse wheel moves.

### API Details

- Full signatures and parameter contracts are intentionally kept in generated API docs:
  - `docs/api/lurek.md`
  - `docs/api/lurek.lua`
