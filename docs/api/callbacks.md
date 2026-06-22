# Callback Hooks

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `29` engine callbacks
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `build/docs-data/lua_api.json` (`engine_callbacks`) with `logs/data/lua_api_data.json` compatibility fallback so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures and parameters are listed below on this page.

## Callback Inventory

- `lurek.draw` - `function lurek.draw()`
  - Called every frame to queue world render commands.
- `lurek.draw_ui` - `function lurek.draw_ui()`
  - Called every frame after world drawing to queue UI and HUD render commands.
- `lurek.exit` - `function lurek.exit()`
  - Called before the runtime exits after an explicit close path.
- `lurek.fixedUpdate` - `function lurek.fixedUpdate(dt)`
  - Deprecated fixed-step update callback; use `lurek.process_physics(dt)`.
- `lurek.focus` - `function lurek.focus(focused)`
  - Called when the application window gains or loses focus.
- `lurek.gamepadaxis` - `function lurek.gamepadaxis(id, axis, value)`
  - Called when a connected gamepad axis changes.
- `lurek.gamepadconnected` - `function lurek.gamepadconnected(id)`
  - Called when a gamepad connects.
- `lurek.gamepaddisconnected` - `function lurek.gamepaddisconnected(id)`
  - Called when a gamepad disconnects.
- `lurek.gamepadpressed` - `function lurek.gamepadpressed(id, button)`
  - Called when a gamepad button is pressed.
- `lurek.gamepadreleased` - `function lurek.gamepadreleased(id, button)`
  - Called when a gamepad button is released.
- `lurek.init` - `function lurek.init()`
  - Called once after the Lua VM, shared state, and `lurek.*` modules are ready.
- `lurek.joystickadded` - `function lurek.joystickadded(id)`
  - Compatibility callback called when a gamepad connects.
- `lurek.joystickremoved` - `function lurek.joystickremoved(id)`
  - Compatibility callback called when a gamepad disconnects.
- `lurek.keypressed` - `function lurek.keypressed(key, scancode, isrepeat)`
  - Called when a keyboard key is pressed and UI did not consume it.
- `lurek.keyreleased` - `function lurek.keyreleased(key, scancode)`
  - Called when a keyboard key is released.
- `lurek.mousemoved` - `function lurek.mousemoved(x, y, dx, dy)`
  - Called when the pointer moves in game coordinates and UI did not consume it.
- `lurek.mousepressed` - `function lurek.mousepressed(x, y, button)`
  - Called when a mouse button is pressed and UI did not consume it.
- `lurek.mousereleased` - `function lurek.mousereleased(x, y, button)`
  - Called when a mouse button is released and UI did not consume it.
- `lurek.process` - `function lurek.process(dt)`
  - Called every frame for game logic.
- `lurek.process_late` - `function lurek.process_late(dt)`
  - Called every frame after `process` and fixed-step physics callbacks.
- `lurek.process_physics` - `function lurek.process_physics(dt)`
  - Called at the fixed timestep zero or more times per rendered frame.
- `lurek.ready` - `function lurek.ready()`
  - Called once after startup when the first frame resources are ready.
- `lurek.resize` - `function lurek.resize(width, height)`
  - Called after the renderer and viewport are resized.
- `lurek.textinput` - `function lurek.textinput(text)`
  - Called when committed text input arrives and UI did not consume it.
- `lurek.touchmoved` - `function lurek.touchmoved(id, x, y, dx, dy, pressure)`
  - Called when a touch point moves.
- `lurek.touchpressed` - `function lurek.touchpressed(id, x, y, dx, dy, pressure)`
  - Called when a touch point starts.
- `lurek.touchreleased` - `function lurek.touchreleased(id, x, y, dx, dy, pressure)`
  - Called when a touch point ends or is cancelled.
- `lurek.visible` - `function lurek.visible(visible)`
  - Called when the window occlusion/visibility state changes.
- `lurek.wheelmoved` - `function lurek.wheelmoved(dx, dy)`
  - Called when mouse-wheel input arrives and UI did not consume it.

## Callback Details

### `lurek.draw`

Called every frame to queue world render commands.

```lua
function lurek.draw()
```

#### Parameters

*No parameters.*

### `lurek.draw_ui`

Called every frame after world drawing to queue UI and HUD render commands.

```lua
function lurek.draw_ui()
```

#### Parameters

*No parameters.*

### `lurek.exit`

Called before the runtime exits after an explicit close path.

```lua
function lurek.exit()
```

#### Parameters

*No parameters.*

### `lurek.fixedUpdate`

Deprecated fixed-step update callback; use `lurek.process_physics(dt)`.

```lua
function lurek.fixedUpdate(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Fixed timestep in seconds. |

### `lurek.focus`

Called when the application window gains or loses focus.

```lua
function lurek.focus(focused)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `focused` | boolean | True when the window is focused. |

### `lurek.gamepadaxis`

Called when a connected gamepad axis changes.

```lua
function lurek.gamepadaxis(id, axis, value)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |
| `axis` | string | Axis name. |
| `value` | number | Axis value reported by the backend. |

### `lurek.gamepadconnected`

Called when a gamepad connects.

```lua
function lurek.gamepadconnected(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |

### `lurek.gamepaddisconnected`

Called when a gamepad disconnects.

```lua
function lurek.gamepaddisconnected(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |

### `lurek.gamepadpressed`

Called when a gamepad button is pressed.

```lua
function lurek.gamepadpressed(id, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |
| `button` | string | Button name. |

### `lurek.gamepadreleased`

Called when a gamepad button is released.

```lua
function lurek.gamepadreleased(id, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |
| `button` | string | Button name. |

### `lurek.init`

Called once after the Lua VM, shared state, and `lurek.*` modules are ready.

```lua
function lurek.init()
```

#### Parameters

*No parameters.*

### `lurek.joystickadded`

Compatibility callback called when a gamepad connects.

```lua
function lurek.joystickadded(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |

### `lurek.joystickremoved`

Compatibility callback called when a gamepad disconnects.

```lua
function lurek.joystickremoved(id)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Gamepad slot id. |

### `lurek.keypressed`

Called when a keyboard key is pressed and UI did not consume it.

```lua
function lurek.keypressed(key, scancode, isrepeat)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Normalized key name. |
| `scancode` | string | Normalized physical scancode, or an empty string when unavailable. |
| `isrepeat` | boolean | True when the key press is an OS repeat event. |

### `lurek.keyreleased`

Called when a keyboard key is released.

```lua
function lurek.keyreleased(key, scancode)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Normalized key name. |
| `scancode` | string | Normalized physical scancode, or an empty string when unavailable. |

### `lurek.mousemoved`

Called when the pointer moves in game coordinates and UI did not consume it.

```lua
function lurek.mousemoved(x, y, dx, dy)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Pointer x coordinate in game space. |
| `y` | number | Pointer y coordinate in game space. |
| `dx` | number | Delta x since the previous pointer event. |
| `dy` | number | Delta y since the previous pointer event. |

### `lurek.mousepressed`

Called when a mouse button is pressed and UI did not consume it.

```lua
function lurek.mousepressed(x, y, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Pointer x coordinate in game space. |
| `y` | number | Pointer y coordinate in game space. |
| `button` | integer | One-based mouse button index. |

### `lurek.mousereleased`

Called when a mouse button is released and UI did not consume it.

```lua
function lurek.mousereleased(x, y, button)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Pointer x coordinate in game space. |
| `y` | number | Pointer y coordinate in game space. |
| `button` | integer | One-based mouse button index. |

### `lurek.process`

Called every frame for game logic.

```lua
function lurek.process(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Frame delta time in seconds. |

### `lurek.process_late`

Called every frame after `process` and fixed-step physics callbacks.

```lua
function lurek.process_late(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Frame delta time in seconds. |

### `lurek.process_physics`

Called at the fixed timestep zero or more times per rendered frame.

```lua
function lurek.process_physics(dt)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Fixed timestep in seconds. |

### `lurek.ready`

Called once after startup when the first frame resources are ready.

```lua
function lurek.ready()
```

#### Parameters

*No parameters.*

### `lurek.resize`

Called after the renderer and viewport are resized.

```lua
function lurek.resize(width, height)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `width` | integer | Window width in pixels after clamping. |
| `height` | integer | Window height in pixels after clamping. |

### `lurek.textinput`

Called when committed text input arrives and UI did not consume it.

```lua
function lurek.textinput(text)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Committed text. |

### `lurek.touchmoved`

Called when a touch point moves.

```lua
function lurek.touchmoved(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Touch identifier. |
| `x` | number | Touch x coordinate in game space. |
| `y` | number | Touch y coordinate in game space. |
| `dx` | number | Delta x since the previous touch event. |
| `dy` | number | Delta y since the previous touch event. |
| `pressure?` | number | Normalized pressure when available. |

### `lurek.touchpressed`

Called when a touch point starts.

```lua
function lurek.touchpressed(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Touch identifier. |
| `x` | number | Touch x coordinate in game space. |
| `y` | number | Touch y coordinate in game space. |
| `dx` | number | Initial delta x, normally `0`. |
| `dy` | number | Initial delta y, normally `0`. |
| `pressure?` | number | Normalized pressure when available. |

### `lurek.touchreleased`

Called when a touch point ends or is cancelled.

```lua
function lurek.touchreleased(id, x, y, dx, dy, pressure)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `id` | integer | Touch identifier. |
| `x` | number | Touch x coordinate in game space. |
| `y` | number | Touch y coordinate in game space. |
| `dx` | number | Delta x since the previous touch event. |
| `dy` | number | Delta y since the previous touch event. |
| `pressure?` | number | Normalized pressure when available. |

### `lurek.visible`

Called when the window occlusion/visibility state changes.

```lua
function lurek.visible(visible)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | True when the window is visible. |

### `lurek.wheelmoved`

Called when mouse-wheel input arrives and UI did not consume it.

```lua
function lurek.wheelmoved(dx, dy)
```

#### Parameters

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | Horizontal wheel delta. |
| `dy` | number | Vertical wheel delta. |

## Sources

- [Spec callbacks](https://github.com/Lurek2D/lurek_2d/blob/main/docs/specs/callbacks.md)
