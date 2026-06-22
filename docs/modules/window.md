# Window

## Purpose

Manages OS window lifecycles, displays, VSync syncs, and viewport scaling with native dialogs.

## When To Use

- Event-loop display data, staged window-management requests, and viewport conversion helpers work together so a project can reason about screen state without embedding platform-specific code in gameplay modules.
- Fullscreen choices, placement, resizing, file-dialog support, and coordinate conversion matter because the window is both a presentation target and a user-facing operating-system object.
- The module is useful for settings screens, startup configuration, tool windows, and any feature that needs to query or change how the engine occupies the desktop.

## Minimal Example

From the `lurek.window.getDimensions` example block:

```lua
do
    local w, h = lurek.window.getDimensions()
    local pixel_w, pixel_h = lurek.window.getPixelDimensions()
    local dpi = lurek.window.getDPIScale()
    local title = lurek.window.getTitle()
    lurek.log.info("window '" .. title .. "' dimensions = " .. w .. "x" .. h)
    lurek.log.info("pixel size = " .. pixel_w .. "x" .. pixel_h .. " dpi=" .. dpi)
end
```

## Common Patterns

- Start with `lurek.window.close` when exploring this module.
- Start with `lurek.window.flash` when exploring this module.
- Start with `lurek.window.focus` when exploring this module.
- Start with `lurek.window.fromPixels` when exploring this module.
- Start with `lurek.window.getCurrentDisplay` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/window.lua`

## Summary

- The `window` module is the desktop-window control surface for users who need display selection, viewport scaling, mode changes, and OS-facing window behavior under one runtime API.
- Event-loop display data, staged window-management requests, and viewport conversion helpers work together so a project can reason about screen state without embedding platform-specific code in gameplay modules.
- Fullscreen choices, placement, resizing, file-dialog support, and coordinate conversion matter because the window is both a presentation target and a user-facing operating-system object.
- The module is useful for settings screens, startup configuration, tool windows, and any feature that needs to query or change how the engine occupies the desktop.
- DPI-aware scaling and coordinate conversion are especially important because modern desktop behavior is not one-to-one with raw pixels; the window surface must mediate between OS display rules and engine-facing view logic.
- It also supports editor-style and multi-display workflows while the runtime stays alive.
- Read it as the owner of desktop-window policy and scaling behavior. Other modules render or process input within the window, but `window` decides how that host surface is configured and managed.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.window.close`

Closes the window and signals the engine to shut down.

```lua
lurek.window.close()
```

**Example**

```lua
do
    -- Call lurek.window.close() to programmatically end the session, e.g. from a Quit button.
    -- Safe to query the function exists before calling it in a headless test context.
    local close_available = type(lurek.window.close) == "function"
    local open = lurek.window.isOpen()
    local title = lurek.window.getTitle()
    lurek.log.info("close available = " .. tostring(close_available))
    lurek.log.info("window '" .. title .. "' open before close request = " .. tostring(open))
end
```

---

### `lurek.window.flash`

Flashes the window briefly to attract the user's attention.

```lua
lurek.window.flash()
```

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.focus`

Requests keyboard focus for the window. The request is applied by the app loop on the next frame.

```lua
lurek.window.focus()
```

**Example**

```lua
do
    local before = lurek.window.hasFocus()
    lurek.window.focus()
    local after = lurek.window.hasFocus()
    local title = lurek.window.getTitle()
    lurek.log.info("focus request for '" .. title .. "'")
    lurek.log.info("focus before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

### `lurek.window.fromPixels`

Converts a value from physical pixel units to logical (DPI-independent) units using the current DPI scale.

```lua
lurek.window.fromPixels(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | The value in physical pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | The value in logical units. |

**Example**

```lua
do
    local logical = lurek.window.fromPixels(200)
    local pixels = lurek.window.toPixels(100)
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("200 px -> logical " .. logical)
    lurek.log.info("100 logical -> px " .. pixels .. " native scale=" .. native)
end
```

---

### `lurek.window.getCurrentDisplay`

Returns the index of the display that currently contains the window.

```lua
lurek.window.getCurrentDisplay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The zero-based index of the current display. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end
```

---

### `lurek.window.getDPIScale`

Returns the current DPI scale factor of the window. A value of 2.0 means the display uses 2x scaling (e.g., Retina).

```lua
lurek.window.getDPIScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The DPI scale factor. |

**Example**

```lua
do
    local s = lurek.window.getDPIScale()
    local native = lurek.window.getNativeDPIScale()
    local px = lurek.window.toPixels(100)
    lurek.log.info("DPI scale = " .. s)
    lurek.log.info("native scale = " .. native .. " logical100->px" .. px)
end
```

---

### `lurek.window.getDesktopDimensions`

Returns the desktop resolution of a specific display, or the current display if none is specified.

```lua
lurek.window.getDesktopDimensions(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display?` | number | Zero-based display index. Uses the current display if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| number | Desktop width in pixels. |
| number | Desktop height in pixels. |

**Example**

```lua
do
    local dw, dh = lurek.window.getDesktopDimensions()
    example_print_log("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    example_print_log("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end
```

---

### `lurek.window.getDimensions`

Returns the current window width and height in logical pixels.

```lua
lurek.window.getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The window width. |
| number | The window height. |

**Example**

```lua
do
    local w, h = lurek.window.getDimensions()
    local pixel_w, pixel_h = lurek.window.getPixelDimensions()
    local dpi = lurek.window.getDPIScale()
    local title = lurek.window.getTitle()
    lurek.log.info("window '" .. title .. "' dimensions = " .. w .. "x" .. h)
    lurek.log.info("pixel size = " .. pixel_w .. "x" .. pixel_h .. " dpi=" .. dpi)
end
```

---

### `lurek.window.getDisplayCount`

Returns the number of connected displays (monitors).

```lua
lurek.window.getDisplayCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The total number of available displays. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end
```

---

### `lurek.window.getDisplayName`

Returns the human-readable name of a display. Returns "Unknown" if the display cannot be identified.

```lua
lurek.window.getDisplayName(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display?` | number | Zero-based display index. Uses the current display if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| string | The display name. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end
```

---

### `lurek.window.getDisplayOrientation`

Returns the display orientation based on the window's aspect ratio.

```lua
lurek.window.getDisplayOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "landscape" if width >= height, "portrait" otherwise. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.getDisplays`

Returns a list of all connected displays with their properties. Each entry contains index, name, position (x, y), resolution (width, height), scale factor, refresh rate, and whether it is the primary monitor.

```lua
lurek.window.getDisplays()
```

**Returns**

| Type | Description |
|------|-------------|
| LWindowGetDisplaysResult | Array of display info tables with fields: index, name, x, y, width, height, scale, refreshRate, primary. |

**Example**

```lua
do
    local dw, dh = lurek.window.getDesktopDimensions()
    example_print_log("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    example_print_log("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end
```

---

### `lurek.window.getFullscreen`

Returns the current fullscreen state and type.

```lua
lurek.window.getFullscreen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the window is in fullscreen mode. |

**Example**

```lua
do
    local enabled, fsType = lurek.window.getFullscreen()
    local flag = lurek.window.isFullscreen()
    local w, h = lurek.window.getDimensions()
    lurek.log.info("fullscreen enabled = " .. tostring(enabled))
    lurek.log.info("fullscreen type = " .. fsType .. " current size=" .. w .. "x" .. h .. " flag=" .. tostring(flag))
end
```

---

### `lurek.window.getFullscreenModes`

Returns a list of all supported fullscreen video modes across all monitors. Each entry contains width, height, and refresh rate.

```lua
lurek.window.getFullscreenModes()
```

**Returns**

| Type | Description |
|------|-------------|
| LWindowGetFullscreenModesResult | Array of mode tables with fields: width (number), height (number), refreshRate (number). |

**Example**

```lua
do
    local modes = lurek.window.getFullscreenModes()
    local m = modes[1] or { width = 0, height = 0, refreshRate = 0 }
    local count = #modes
    local label = m.width .. "x" .. m.height .. "@" .. m.refreshRate
    lurek.log.info("fullscreen modes available = " .. count)
    lurek.log.info("first mode = " .. label)
end
```

---

### `lurek.window.getGameHeight`

Returns the logical game height as defined by the current scale mode and game configuration.

```lua
lurek.window.getGameHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The game height in logical units. |

**Example**

```lua
do
    local gw = lurek.window.getGameWidth()
    local gh = lurek.window.getGameHeight()
    local info = lurek.window.getScaleInfo()
    lurek.log.info("game height = " .. gh)
    lurek.log.info("paired width = " .. gw .. " scale_y=" .. info.scale_y)
end
```

---

### `lurek.window.getGameWidth`

Returns the logical game width as defined by the current scale mode and game configuration.

```lua
lurek.window.getGameWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The game width in logical units. |

**Example**

```lua
do
    local gw = lurek.window.getGameWidth()
    local gh = lurek.window.getGameHeight()
    local info = lurek.window.getScaleInfo()
    lurek.log.info("game width = " .. gw)
    lurek.log.info("paired height = " .. gh .. " scale_x=" .. info.scale_x)
end
```

---

### `lurek.window.getHeight`

Returns the current window height in logical (DPI-independent) pixels.

```lua
lurek.window.getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The window height. |

**Example**

```lua
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    local ratio = w / h
    lurek.log.info("window size = " .. w .. "x" .. h)
    lurek.log.info("focused=" .. tostring(focused) .. " aspect=" .. string.format("%.3f", ratio))
end
```

---

### `lurek.window.getMode`

Returns the current window display mode: width, height, and a flags table containing fullscreen state, fullscreen type, and VSync mode.

```lua
lurek.window.getMode()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The window width. |
| number | The window height. |
| LWindowGetModeResult | Flags table with fields: fullscreen (boolean); fullscreentype (string); vsync (number). |

**Example**

```lua
do
    local w, h, flags = lurek.window.getMode()
    local title = lurek.window.getTitle()
    local fullscreen = tostring(flags.fullscreen)
    local vsync = tostring(flags.vsync)
    lurek.log.info("mode for " .. title .. " = " .. w .. "x" .. h)
    lurek.log.info("fullscreen=" .. fullscreen .. " type=" .. flags.fullscreentype .. " vsync=" .. vsync)
end
```

---

### `lurek.window.getNativeDPIScale`

Returns the native DPI scale factor reported by the operating system.

```lua
lurek.window.getNativeDPIScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The native DPI scale. |

**Example**

```lua
do
    local s = lurek.window.getNativeDPIScale()
    local runtime = lurek.window.getDPIScale()
    local logical = lurek.window.fromPixels(200)
    lurek.log.info("native DPI scale = " .. s)
    lurek.log.info("runtime scale = " .. runtime .. " px200->logical " .. logical)
end
```

---

### `lurek.window.getPixelDimensions`

Returns the window dimensions in actual physical pixels, accounting for DPI scaling.

```lua
lurek.window.getPixelDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The pixel width. |
| number | The pixel height. |

**Example**

```lua
do
    local pw, ph = lurek.window.getPixelDimensions()
    local lw, lh = lurek.window.getDimensions()
    local scale = lurek.window.getDPIScale()
    lurek.log.info("pixel dimensions = " .. pw .. "x" .. ph)
    lurek.log.info("logical=" .. lw .. "x" .. lh .. " dpi=" .. scale)
end
```

---

### `lurek.window.getPosition`

Returns the window position on screen in pixels.

```lua
lurek.window.getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The x-coordinate of the window's top-left corner. |
| number | The y-coordinate of the window's top-left corner. |

**Example**

```lua
do
    local x, y = lurek.window.getPosition()
    local w, h = lurek.window.getDimensions()
    local display = lurek.window.getCurrentDisplay()
    local label = x .. "," .. y
    lurek.log.info("window position = " .. label)
    lurek.log.info("display=" .. display .. " size=" .. w .. "x" .. h)
end
```

---

### `lurek.window.getSafeArea`

Returns the safe drawing area of the window. On desktop this is the full window area. Useful for compatibility with mobile-style layout code.

```lua
lurek.window.getSafeArea()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X offset (always 0 on desktop). |
| number | Y offset (always 0 on desktop). |
| number | Safe area width. |
| number | Safe area height. |

**Example**

```lua
do
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    local w, h = lurek.window.getDimensions()
    local padding_x = w - sw
    local padding_y = h - sh
    lurek.log.info("safe area = " .. sx .. "," .. sy .. " " .. sw .. "x" .. sh)
    lurek.log.info("outside safe area padding = " .. padding_x .. "x" .. padding_y)
end
```

---

### `lurek.window.getScaleInfo`

Returns detailed scaling information including scale factors, offsets, and logical game dimensions. Useful for coordinate conversion between screen space and game space.

```lua
lurek.window.getScaleInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| LWindowGetScaleInfoResult | Table with fields: scale_x (number), scale_y (number), offset_x (number), offset_y (number), game_width (number), game_height (number). |

**Example**

```lua
do
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode("none")
    lurek.log.info("scale info for mode " .. mode)
    lurek.log.info("scale=" .. info.scale_x .. "," .. info.scale_y .. " game=" .. info.game_width .. "x" .. info.game_height)
end
```

---

### `lurek.window.getScaleMode`

Returns the current content scale mode name (e.g., "stretch", "letterbox", "pixel-perfect").

```lua
lurek.window.getScaleMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The active scale mode. |

**Example**

```lua
do
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode("none")
    lurek.log.info("queried scale mode = " .. mode)
    lurek.log.info("game area = " .. info.game_width .. "x" .. info.game_height)
end
```

---

### `lurek.window.getSystemTheme`

Returns the operating system's current color theme. Desktop currently returns "unknown".

```lua
lurek.window.getSystemTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The system theme name. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.getTitle`

Returns the current window title bar text.

```lua
lurek.window.getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The current window title. |

**Example**

```lua
do
    local title = lurek.window.getTitle()
    local has_focus = lurek.window.hasFocus()
    local is_open = lurek.window.isOpen()
    lurek.log.info("window title = " .. title)
    lurek.log.info("open=" .. tostring(is_open) .. " focus=" .. tostring(has_focus))
end
```

---

### `lurek.window.getVSync`

Returns the current VSync mode. This function is exposed to Lua scripts.

```lua
lurek.window.getVSync()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The VSync mode: 0 = off, 1 = on, -1 = adaptive. |

**Example**

```lua
do
    lurek.window.setVSync(1)
    example_print_log("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    example_print_log("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    example_print_log("adaptive vsync:", lurek.window.getVSync())
end
```

---

### `lurek.window.getWidth`

Returns the current window width in logical (DPI-independent) pixels.

```lua
lurek.window.getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The window width. |

**Example**

```lua
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    local pixel_w, pixel_h = lurek.window.getPixelDimensions()
    lurek.log.info("window width = " .. w .. " height=" .. h)
    lurek.log.info("focused=" .. tostring(focused) .. " pixel size=" .. pixel_w .. "x" .. pixel_h)
end
```

---

### `lurek.window.hasFocus`

Returns whether the window currently has keyboard focus.

```lua
lurek.window.hasFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window has keyboard input focus. |

**Example**

```lua
do
    local before = lurek.window.hasFocus()
    lurek.window.focus()
    local after = lurek.window.hasFocus()
    local mouse = lurek.window.hasMouseFocus()
    lurek.log.info("focus before=" .. tostring(before) .. " after=" .. tostring(after))
    lurek.log.info("mouse focus = " .. tostring(mouse))
end
```

---

### `lurek.window.hasMouseFocus`

Returns whether the mouse cursor is inside the window.

```lua
lurek.window.hasMouseFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the mouse cursor is within the window bounds. |

**Example**

```lua
do
    local v = lurek.window.hasMouseFocus()
    local cursor_focus = lurek.window.cursor.hasFocus()
    local win_focus = lurek.window.hasFocus()
    lurek.log.info("mouse focus = " .. tostring(v))
    lurek.log.info("cursor focus = " .. tostring(cursor_focus) .. " window focus=" .. tostring(win_focus))
end
```

---

### `lurek.window.isFullscreen`

Returns whether the window is currently in fullscreen mode.

```lua
lurek.window.isFullscreen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window is fullscreen. |

**Example**

```lua
do
    local v = lurek.window.isFullscreen()
    local enabled, mode = lurek.window.getFullscreen()
    local scale_mode = lurek.window.getScaleMode()
    lurek.log.info("is fullscreen = " .. tostring(v))
    lurek.log.info("fullscreen tuple=" .. tostring(enabled) .. "/" .. mode .. " scale=" .. scale_mode)
end
```

---

### `lurek.window.isHighDPIAllowed`

Returns whether high-DPI rendering is allowed. Currently always returns false on desktop.

```lua
lurek.window.isHighDPIAllowed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if high-DPI mode is enabled. |

**Example**

```lua
do
    local v = lurek.window.isHighDPIAllowed()
    local runtime = lurek.window.getDPIScale()
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("high DPI allowed = " .. tostring(v))
    lurek.log.info("runtime/native scale = " .. runtime .. "/" .. native)
end
```

---

### `lurek.window.isMaximized`

Returns whether the window is currently maximized.

```lua
lurek.window.isMaximized()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window is maximized. |

**Example**

```lua
do
    lurek.window.maximize()
    local maximized = lurek.window.isMaximized()
    lurek.window.restore()
    local restored = lurek.window.isMaximized()
    lurek.log.info("maximized state after request = " .. tostring(maximized))
    lurek.log.info("after restore maximized = " .. tostring(restored))
end
```

---

### `lurek.window.isMinimized`

Returns whether the window is currently minimized to the taskbar.

```lua
lurek.window.isMinimized()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window is minimized. |

**Example**

```lua
do
    lurek.window.minimize()
    local minimized = lurek.window.isMinimized()
    lurek.window.restore()
    local restored = lurek.window.isMinimized()
    lurek.log.info("minimized state after request = " .. tostring(minimized))
    lurek.log.info("after restore minimized = " .. tostring(restored))
end
```

---

### `lurek.window.isOpen`

Returns whether the window is currently open. Always returns true while the game is running.

```lua
lurek.window.isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window exists. |

**Example**

```lua
do
    local open = lurek.window.isOpen()
    local visible = lurek.window.isVisible()
    local maximized = lurek.window.isMaximized()
    local minimized = lurek.window.isMinimized()
    lurek.log.info("is open = " .. tostring(open))
    lurek.log.info("visible=" .. tostring(visible) .. " max=" .. tostring(maximized) .. " min=" .. tostring(minimized))
end
```

---

### `lurek.window.isResizable`

Returns whether the window can be resized by the user.

```lua
lurek.window.isResizable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window is resizable. |

**Example**

```lua
do
    local resizable = lurek.window.isResizable()
    local open = lurek.window.isOpen()
    local visible = lurek.window.isVisible()
    local maximized = lurek.window.isMaximized()
    lurek.log.info("is resizable = " .. tostring(resizable))
    lurek.log.info("open=" .. tostring(open) .. " visible=" .. tostring(visible) .. " max=" .. tostring(maximized))
end
```

---

### `lurek.window.isVisible`

Returns whether the window is currently visible on screen.

```lua
lurek.window.isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the window is visible. |

**Example**

```lua
do
    local visible = lurek.window.isVisible()
    local open = lurek.window.isOpen()
    local resizable = lurek.window.isResizable()
    local minimized = lurek.window.isMinimized()
    lurek.log.info("is visible = " .. tostring(visible))
    lurek.log.info("open=" .. tostring(open) .. " resizable=" .. tostring(resizable) .. " minimized=" .. tostring(minimized))
end
```

---

### `lurek.window.maximize`

Maximizes the window to fill the screen.

```lua
lurek.window.maximize()
```

**Example**

```lua
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.minimize`

Minimizes the window to the taskbar.

```lua
lurek.window.minimize()
```

**Example**

```lua
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.onDpiChange`

Registers a callback function that is called whenever the DPI scale factor changes (e.g., when the window is moved to a different monitor). Only one callback can be active at a time; setting a new one replaces the previous.

```lua
lurek.window.onDpiChange(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving the new DPI scale as a number. |

**Example**

```lua
do
    local last_scale = 0
    lurek.window.onDpiChange(function(scale) last_scale = scale end)
    local currentScale = lurek.window.pollDpiChange()
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("dpi callback registered, last callback scale = " .. last_scale)
    lurek.log.info("poll scale = " .. currentScale .. " native=" .. native)
end
```

---

### `lurek.window.openFileDialog`

Opens a native file picker dialog and returns the selected file paths. Blocks until the user picks file(s) or cancels.

```lua
lurek.window.openFileDialog(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional config table with fields: title (string), defaultPath (string), multiple (boolean), filters (table of {name, extensions}). |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Selected file path strings. Empty table if cancelled. |

**Example**

```lua
do
    local opts = { title = "Select file", multiple = true }
    local interactive = lurek.runtime.getEnv("LUREK_RUN_INTERACTIVE_DIALOGS") == "1"
    if interactive then
        local files = lurek.window.openFileDialog(opts)
        example_print_log("selected file count:", #files)
        example_print_log("first file:", tostring(files[1]))
    else
        example_print_log("set LUREK_RUN_INTERACTIVE_DIALOGS=1 to run the blocking file dialog example")
        example_print_log("dialog title:", opts.title)
    end
end
```

---

### `lurek.window.pollDpiChange`

Checks if the DPI scale has changed since the last poll and fires the onDpiChange callback if so. Call this once per frame in your update loop to detect monitor changes.

```lua
lurek.window.pollDpiChange()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The current DPI scale factor. |

**Example**

```lua
do
    local callback_hits = 0
    lurek.window.onDpiChange(function(_scale) callback_hits = callback_hits + 1 end)
    local currentScale = lurek.window.pollDpiChange()
    local runtime = lurek.window.getDPIScale()
    local logical = lurek.window.fromPixels(200)
    lurek.log.info("pollDpiChange returned " .. currentScale .. " callback hits=" .. callback_hits)
    lurek.log.info("runtime scale = " .. runtime .. " px200->logical " .. logical)
end
```

---

### `lurek.window.requestAttention`

Requests user attention by flashing the taskbar icon. Useful for notifying the player when the window is in the background.

```lua
lurek.window.requestAttention()
```

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.restore`

Restores the window from minimized or maximized state to its previous size and position.

```lua
lurek.window.restore()
```

**Example**

```lua
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.setDisplay`

Moves the window to the specified display. Throws an error if the index is negative.

```lua
lurek.window.setDisplay(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display` | number | Zero-based index of the target display. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.setFullscreen`

Enables or disables fullscreen mode. Supports "desktop" (borderless) and "exclusive" types.

```lua
lurek.window.setFullscreen(enabled, fstype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Whether to enter fullscreen. |
| `fstype?` | string | Fullscreen type: "desktop" (default) or "exclusive". |

**Example**

```lua
do
    local before_enabled, before_type = lurek.window.getFullscreen()
    lurek.window.setFullscreen(true, "desktop")
    local enabled_now = lurek.window.isFullscreen()
    lurek.window.setFullscreen(false)
    local disabled_now = lurek.window.isFullscreen()
    lurek.window.setFullscreen(before_enabled, before_type)
    lurek.log.info("enabled fullscreen temporarily = " .. tostring(enabled_now))
    lurek.log.info("disabled again = " .. tostring(disabled_now))
end
```

---

### `lurek.window.setIcon`

Sets the window icon from an image file. The file must exist in the game's filesystem. Supports PNG and other common image formats.

```lua
lurek.window.setIcon(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to the icon image file. |

**Example**

```lua
do
    lurek.window.setIcon("content/examples/assets/images/sample_icon.png")
    local title = lurek.window.getTitle()
    local w, h = lurek.window.getDimensions()
    lurek.log.info("icon set for window '" .. title .. "'")
    lurek.log.info("window size while setting icon = " .. w .. "x" .. h)
end
```

---

### `lurek.window.setMode`

Sets the window display mode with a specific resolution and optional flags. Use this to resize the window and configure fullscreen or VSync at the same time.

```lua
lurek.window.setMode(w, h, flags)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | The desired window width in pixels. |
| `h` | number | The desired window height in pixels. |
| `flags?` | table | Optional table with fields: fullscreen (boolean), fullscreentype (string), vsync (number). |

**Example**

```lua
do
    local old_w, old_h, old_flags = lurek.window.getMode()
    lurek.window.setMode(1280, 720, { fullscreen = false, fullscreentype = "desktop", vsync = 1 })
    local nw, nh, nflags = lurek.window.getMode()
    lurek.window.setMode(old_w, old_h, old_flags)
    local rw, rh = lurek.window.getDimensions()
    lurek.log.info("temporary mode = " .. nw .. "x" .. nh .. " vsync=" .. tostring(nflags.vsync))
    lurek.log.info("restored dimensions = " .. rw .. "x" .. rh)
end
```

---

### `lurek.window.setPosition`

Moves the window to the specified screen position.

```lua
lurek.window.setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | The x-coordinate for the window's top-left corner. |
| `y` | number | The y-coordinate for the window's top-left corner. |

**Example**

```lua
do
    local x, y = lurek.window.getPosition()
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    lurek.window.setPosition(x, y)
    local restored_x, restored_y = lurek.window.getPosition()
    lurek.log.info("temporary position = " .. nx .. "," .. ny)
    lurek.log.info("restored position = " .. restored_x .. "," .. restored_y)
end
```

---

### `lurek.window.setScaleMode`

Sets the content scale mode. Controls how the game's logical resolution maps to the window size.

```lua
lurek.window.setScaleMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | The scale mode name (e.g., "stretch", "letterbox", "pixel-perfect"). |

**Example**

```lua
do
    local previous = lurek.window.getScaleMode()
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode(previous)
    lurek.log.info("scale mode set to " .. mode)
    lurek.log.info("scale=" .. info.scale_x .. "," .. info.scale_y .. " offset=" .. info.offset_x .. "," .. info.offset_y)
end
```

---

### `lurek.window.setTitle`

Sets the window title bar text. This function is exposed to Lua scripts.

```lua
lurek.window.setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The new window title to display. |

**Example**

```lua
do
    local previous = lurek.window.getTitle()
    lurek.window.setTitle("My Game - Level 1")
    local current = lurek.window.getTitle()
    lurek.window.setTitle(previous)
    lurek.log.info("title changed " .. previous .. " -> " .. current)
    lurek.log.info("title restored = " .. lurek.window.getTitle())
end
```

---

### `lurek.window.setVSync`

Sets the vertical sync mode. Controls how frame presentation is synchronized with the display.

```lua
lurek.window.setVSync(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | number | VSync mode: 0 = off, 1 = on, -1 = adaptive. |

**Example**

```lua
do
    lurek.window.setVSync(1)
    example_print_log("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    example_print_log("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    example_print_log("adaptive vsync:", lurek.window.getVSync())
end
```

---

### `lurek.window.showMessageBox`

Displays a native OS message box dialog. Blocks execution until the user dismisses it.

```lua
lurek.window.showMessageBox(title, message, box_type, btn_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | The dialog title. |
| `message` | string | The message body text. |
| `box_type?` | string | Dialog icon type: "info" (default), "warning", or "error". |
| `btn_type?` | string | Button layout: "ok" (default), "okcancel", or "yesno". |

**Returns**

| Type | Description |
|------|-------------|
| string | The button the user clicked. |

**Example**

```lua
do
    local title = "Save?"
    local message = "Do you want to save before exit?"
    local box_type = "warning"
    local btn_type = "yesno"
    local interactive = lurek.runtime.getEnv("LUREK_RUN_INTERACTIVE_DIALOGS") == "1"
    if interactive then
        local result = lurek.window.showMessageBox(title, message, box_type, btn_type)
        example_print_log("message box result:", result)
    else
        example_print_log("set LUREK_RUN_INTERACTIVE_DIALOGS=1 to run the blocking message box example")
    end
end
```

---

### `lurek.window.toPixels`

Converts a value from logical (DPI-independent) units to physical pixel units using the current DPI scale.

```lua
lurek.window.toPixels(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | The value in logical units. |

**Returns**

| Type | Description |
|------|-------------|
| number | The value in physical pixels. |

**Example**

```lua
do
    local logical = lurek.window.fromPixels(200)
    local pixels = lurek.window.toPixels(100)
    local runtime = lurek.window.getDPIScale()
    lurek.log.info("100 logical -> px " .. pixels)
    lurek.log.info("reverse check 200px->logical " .. logical .. " runtime scale=" .. runtime)
end
```

---

### `lurek.window.windowConfig`

Applies multiple window settings at once from a configuration table. Supports title, width, height, fullscreen, fullscreentype, vsync, position (x, y), scaleMode, and display index.

```lua
lurek.window.windowConfig(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Configuration table with optional fields: title (string), width (number), height (number), fullscreen (boolean), fullscreentype (string), vsync (number), x (number), y (number), scaleMode (string), display (number). |

**Example**

```lua
do
    local previous = lurek.window.getTitle()
    lurek.window.windowConfig({ title = "Configured Window", width = 1024, height = 768, fullscreen = false, vsync = 1, scaleMode = "letterbox" })
    local title = lurek.window.getTitle()
    local w, h = lurek.window.getDimensions()
    lurek.window.setTitle(previous)
    lurek.log.info("windowConfig applied title=" .. title)
    lurek.log.info("configured dimensions = " .. w .. "x" .. h .. " then restored title")
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.window.onDpiChange` param `func` (`function`): Callback receiving the new DPI scale as a number.

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
