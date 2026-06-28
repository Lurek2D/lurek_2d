<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/callbacks.md or source docstrings instead. -->

# callbacks

## TL;DR

Global `lurek.*` callbacks are documented here as a dedicated generated spec, independent from thin-wrapper module specs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `29` engine callbacks

## Summary

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `build/docs-data/lua_api.json` (`engine_callbacks`) with `logs/data/lua_api_data.json` compatibility fallback so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`).

## Imports

- Global callback contracts are sourced from generated Lua API data (`engine_callbacks`).

## Files

### callback contracts

- Generated from engine callback metadata extracted during Lua API data generation.

## Lua API Ref

### Callback Inventory

- `lurek.draw() -> nil`: Called every frame to queue world render commands.
- `lurek.draw_ui() -> nil`: Called every frame after world drawing to queue UI and HUD render commands.
- `lurek.exit() -> nil`: Called before the runtime exits after an explicit close path.
- `lurek.fixedUpdate(dt) -> nil`: Deprecated fixed-step update callback; use `lurek.process_physics(dt)`.
- `lurek.focus(focused) -> nil`: Called when the application window gains or loses focus.
- `lurek.gamepadaxis(id, axis, value) -> nil`: Called when a connected gamepad axis changes.
- `lurek.gamepadconnected(id) -> nil`: Called when a gamepad connects.
- `lurek.gamepaddisconnected(id) -> nil`: Called when a gamepad disconnects.
- `lurek.gamepadpressed(id, button) -> nil`: Called when a gamepad button is pressed.
- `lurek.gamepadreleased(id, button) -> nil`: Called when a gamepad button is released.
- `lurek.init() -> nil`: Called once after the Lua VM, shared state, and `lurek.*` modules are ready.
- `lurek.joystickadded(id) -> nil`: Compatibility callback called when a gamepad connects.
- `lurek.joystickremoved(id) -> nil`: Compatibility callback called when a gamepad disconnects.
- `lurek.keypressed(key, scancode, isrepeat) -> nil`: Called when a keyboard key is pressed and UI did not consume it.
- `lurek.keyreleased(key, scancode) -> nil`: Called when a keyboard key is released.
- `lurek.mousemoved(x, y, dx, dy) -> nil`: Called when the pointer moves in game coordinates and UI did not consume it.
- `lurek.mousepressed(x, y, button) -> nil`: Called when a mouse button is pressed and UI did not consume it.
- `lurek.mousereleased(x, y, button) -> nil`: Called when a mouse button is released and UI did not consume it.
- `lurek.process(dt) -> nil`: Called every frame for game logic.
- `lurek.process_late(dt) -> nil`: Called every frame after `process` and fixed-step physics callbacks.
- `lurek.process_physics(dt) -> nil`: Called at the fixed timestep zero or more times per rendered frame.
- `lurek.ready() -> nil`: Called once after startup when the first frame resources are ready.
- `lurek.resize(width, height) -> nil`: Called after the renderer and viewport are resized.
- `lurek.textinput(text) -> nil`: Called when committed text input arrives and UI did not consume it.
- `lurek.touchmoved(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point moves.
- `lurek.touchpressed(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point starts.
- `lurek.touchreleased(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point ends or is cancelled.
- `lurek.visible(visible) -> nil`: Called when the window occlusion/visibility state changes.
- `lurek.wheelmoved(dx, dy) -> nil`: Called when mouse-wheel input arrives and UI did not consume it.

### API Details

- Full signatures and parameter contracts are intentionally kept in generated API docs:
  - `docs/api/lurek.md`
  - `docs/api/lurek.lua`
