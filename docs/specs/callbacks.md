# callbacks

## TL;DR

This spec is the central inventory of global `lurek.*` engine callbacks, kept separate from module specs and synchronized from generated callback metadata.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `30` engine callbacks
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `callbacks` spec defines the global callback surface that the engine can call on the `lurek` table during runtime. It covers lifecycle, input, update, render, and shutdown callback names so teams have one clear list of entry points for script-side integration.

Its main function is contract visibility. Instead of spreading callback ownership across many module specs, this file keeps one dedicated inventory that explains what callback hooks exist and why they are part of the global runtime surface.

The file is intentionally metadata-driven. It is generated from callback extraction data, which helps keep the inventory aligned with actual engine behavior and reduces drift from manually maintained lists.

This spec does not duplicate full signature details. It owns callback discovery and scope context, while parameter-level and signature-level definitions remain in generated API reference documents. That split keeps this page concise and keeps deep API details in the canonical generated sources.

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
