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

- `lurek.draw`: Called every frame for world rendering.
- `lurek.draw_ui`: Called every frame after `draw` for UI rendering.
- `lurek.errorhandler`: Called for unhandled Lua errors.
- `lurek.exit`: Called when the engine is shutting down.
- `lurek.fixedUpdate`: Deprecated alias for `process_physics`.
- `lurek.focus`: Called when window focus changes.
- `lurek.gamepadaxis`: Called when a gamepad axis value changes.
- `lurek.gamepadpressed`: Called when a gamepad button is pressed.
- `lurek.gamepadreleased`: Called when a gamepad button is released.
- `lurek.init`: Called once when the engine initialises.
- `lurek.joystickadded`: Called when a gamepad is connected.
- `lurek.joystickremoved`: Called when a gamepad is disconnected.
- `lurek.keypressed`: Called when a keyboard key is pressed.
- `lurek.keyreleased`: Called when a keyboard key is released.
- `lurek.mousemoved`: Called when the mouse cursor moves.
- `lurek.mousepressed`: Called when a mouse button is pressed.
- `lurek.mousereleased`: Called when a mouse button is released.
- `lurek.process`: Called every frame for variable-step gameplay logic.
- `lurek.process_late`: Called every frame after `process`.
- `lurek.process_physics`: Called on the fixed physics step.
- `lurek.quit`: Called before shutdown; return true to cancel quit.
- `lurek.ready`: Called once after init, when runtime state is ready.
- `lurek.resize`: Called when window size changes.
- `lurek.textedited`: Called when IME composition text changes.
- `lurek.textinput`: Called when text input is received.
- `lurek.touchmoved`: Called when a touch point moves.
- `lurek.touchpressed`: Called when a touch begins.
- `lurek.touchreleased`: Called when a touch ends.
- `lurek.visible`: Called when window visibility changes.
- `lurek.wheelmoved`: Called when the mouse wheel moves.

### API Details

- Full signatures and parameter contracts are intentionally kept in generated API docs:
  - `docs/api/lurek.md`
  - `docs/api/lurek.lua`
