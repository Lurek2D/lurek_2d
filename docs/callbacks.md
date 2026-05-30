# Callback Hooks

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

## Callback Inventory

- `lurek.draw` — `function lurek.draw()`
  - Called every frame for world rendering.
- `lurek.draw_ui` — `function lurek.draw_ui()`
  - Called every frame after `draw` for UI rendering.
- `lurek.errorhandler` — `function lurek.errorhandler(msg)`
  - Called for unhandled Lua errors.
- `lurek.exit` — `function lurek.exit()`
  - Called when the engine is shutting down.
- `lurek.fixedUpdate` — `function lurek.fixedUpdate(dt)`
  - Deprecated alias for `process_physics`.
- `lurek.focus` — `function lurek.focus(has_focus)`
  - Called when window focus changes.
- `lurek.gamepadaxis` — `function lurek.gamepadaxis(id, axis, value)`
  - Called when a gamepad axis value changes.
- `lurek.gamepadpressed` — `function lurek.gamepadpressed(id, button)`
  - Called when a gamepad button is pressed.
- `lurek.gamepadreleased` — `function lurek.gamepadreleased(id, button)`
  - Called when a gamepad button is released.
- `lurek.init` — `function lurek.init()`
  - Called once when the engine initialises.
- `lurek.joystickadded` — `function lurek.joystickadded(id)`
  - Called when a gamepad is connected.
- `lurek.joystickremoved` — `function lurek.joystickremoved(id)`
  - Called when a gamepad is disconnected.
- `lurek.keypressed` — `function lurek.keypressed(key, scancode, isrepeat)`
  - Called when a keyboard key is pressed.
- `lurek.keyreleased` — `function lurek.keyreleased(key, scancode)`
  - Called when a keyboard key is released.
- `lurek.mousemoved` — `function lurek.mousemoved(x, y, dx, dy)`
  - Called when the mouse cursor moves.
- `lurek.mousepressed` — `function lurek.mousepressed(x, y, button)`
  - Called when a mouse button is pressed.
- `lurek.mousereleased` — `function lurek.mousereleased(x, y, button)`
  - Called when a mouse button is released.
- `lurek.process` — `function lurek.process(dt)`
  - Called every frame for variable-step gameplay logic.
- `lurek.process_late` — `function lurek.process_late(dt)`
  - Called every frame after `process`.
- `lurek.process_physics` — `function lurek.process_physics(dt)`
  - Called on the fixed physics step.
- `lurek.quit` — `function lurek.quit()`
  - Called before shutdown; return true to cancel quit.
- `lurek.ready` — `function lurek.ready()`
  - Called once after init, when runtime state is ready.
- `lurek.resize` — `function lurek.resize(w, h)`
  - Called when window size changes.
- `lurek.textedited` — `function lurek.textedited(text, start, length)`
  - Called when IME composition text changes.
- `lurek.textinput` — `function lurek.textinput(text)`
  - Called when text input is received.
- `lurek.touchmoved` — `function lurek.touchmoved(id, x, y, dx, dy, pressure)`
  - Called when a touch point moves.
- `lurek.touchpressed` — `function lurek.touchpressed(id, x, y, dx, dy, pressure)`
  - Called when a touch begins.
- `lurek.touchreleased` — `function lurek.touchreleased(id, x, y, dx, dy, pressure)`
  - Called when a touch ends.
- `lurek.visible` — `function lurek.visible(is_visible)`
  - Called when window visibility changes.
- `lurek.wheelmoved` — `function lurek.wheelmoved(x, y)`
  - Called when the mouse wheel moves.

## Callback Details

### `lurek.draw`

Called every frame for world rendering.

```lua
function lurek.draw()
```

#### Parameters

*No parameters.*

### `lurek.draw_ui`

Called every frame after `draw` for UI rendering.

```lua
function lurek.draw_ui()
```

#### Parameters

*No parameters.*

### `lurek.errorhandler`

Called for unhandled Lua errors.

```lua
function lurek.errorhandler(msg)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `msg` | string | Error message text. |

### `lurek.exit`

Called when the engine is shutting down.

```lua
function lurek.exit()
```

#### Parameters

*No parameters.*

### `lurek.fixedUpdate`

Deprecated alias for `process_physics`.

```lua
function lurek.fixedUpdate(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Fixed-step delta time in seconds. |

### `lurek.focus`

Called when window focus changes.

```lua
function lurek.focus(has_focus)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `has_focus` | boolean | True when focused. |

### `lurek.gamepadaxis`

Called when a gamepad axis value changes.

```lua
function lurek.gamepadaxis(id, axis, value)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gamepad id. |
| `axis` | string | Axis name. |
| `value` | number | Axis value in range -1..1. |

### `lurek.gamepadpressed`

Called when a gamepad button is pressed.

```lua
function lurek.gamepadpressed(id, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gamepad id. |
| `button` | string | Button name. |

### `lurek.gamepadreleased`

Called when a gamepad button is released.

```lua
function lurek.gamepadreleased(id, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gamepad id. |
| `button` | string | Button name. |

### `lurek.init`

Called once when the engine initialises.

```lua
function lurek.init()
```

#### Parameters

*No parameters.*

### `lurek.joystickadded`

Called when a gamepad is connected.

```lua
function lurek.joystickadded(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gamepad id. |

### `lurek.joystickremoved`

Called when a gamepad is disconnected.

```lua
function lurek.joystickremoved(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gamepad id. |

### `lurek.keypressed`

Called when a keyboard key is pressed.

```lua
function lurek.keypressed(key, scancode, isrepeat)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Key name. |
| `scancode` | string | Platform scancode. |
| `isrepeat` | boolean | True when key repeat generated the event. |

### `lurek.keyreleased`

Called when a keyboard key is released.

```lua
function lurek.keyreleased(key, scancode)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Key name. |
| `scancode` | string | Platform scancode. |

### `lurek.mousemoved`

Called when the mouse cursor moves.

```lua
function lurek.mousemoved(x, y, dx, dy)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |
| `dx` | number | Horizontal delta. |
| `dy` | number | Vertical delta. |

### `lurek.mousepressed`

Called when a mouse button is pressed.

```lua
function lurek.mousepressed(x, y, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |
| `button` | number | Button index. |

### `lurek.mousereleased`

Called when a mouse button is released.

```lua
function lurek.mousereleased(x, y, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |
| `button` | number | Button index. |

### `lurek.process`

Called every frame for variable-step gameplay logic.

```lua
function lurek.process(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

### `lurek.process_late`

Called every frame after `process`.

```lua
function lurek.process_late(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

### `lurek.process_physics`

Called on the fixed physics step.

```lua
function lurek.process_physics(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Fixed-step delta time in seconds. |

### `lurek.quit`

Called before shutdown; return true to cancel quit.

```lua
function lurek.quit()
```

#### Parameters

*No parameters.*

### `lurek.ready`

Called once after init, when runtime state is ready.

```lua
function lurek.ready()
```

#### Parameters

*No parameters.*

### `lurek.resize`

Called when window size changes.

```lua
function lurek.resize(w, h)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `w` | number | New window width. |
| `h` | number | New window height. |

### `lurek.textedited`

Called when IME composition text changes.

```lua
function lurek.textedited(text, start, length)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Composition text. |
| `start` | number | Cursor start offset. |
| `length` | number | Selection length. |

### `lurek.textinput`

Called when text input is received.

```lua
function lurek.textinput(text)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Input text fragment. |

### `lurek.touchmoved`

Called when a touch point moves.

```lua
function lurek.touchmoved(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Touch id. |
| `x` | number | Touch x coordinate. |
| `y` | number | Touch y coordinate. |
| `dx` | number | Horizontal delta. |
| `dy` | number | Vertical delta. |
| `pressure` | number | Touch pressure. |

### `lurek.touchpressed`

Called when a touch begins.

```lua
function lurek.touchpressed(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Touch id. |
| `x` | number | Touch x coordinate. |
| `y` | number | Touch y coordinate. |
| `dx` | number | Horizontal delta. |
| `dy` | number | Vertical delta. |
| `pressure` | number | Touch pressure. |

### `lurek.touchreleased`

Called when a touch ends.

```lua
function lurek.touchreleased(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Touch id. |
| `x` | number | Touch x coordinate. |
| `y` | number | Touch y coordinate. |
| `dx` | number | Horizontal delta. |
| `dy` | number | Vertical delta. |
| `pressure` | number | Touch pressure. |

### `lurek.visible`

Called when window visibility changes.

```lua
function lurek.visible(is_visible)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `is_visible` | boolean | True when visible. |

### `lurek.wheelmoved`

Called when the mouse wheel moves.

```lua
function lurek.wheelmoved(x, y)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Horizontal wheel delta. |
| `y` | number | Vertical wheel delta. |

## Sources

- [Spec callbacks](specs/callbacks.md)
- [Generated API (Markdown)](api/lurek.md)
