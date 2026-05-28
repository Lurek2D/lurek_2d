# Window

- The `window` module is an essential Platform Services tier component responsible for OS-level window lifecycle and multi-monitor management.

Built upon the robust `winit` 0.30 backend, it controls window creation, sizing, positioning, and input acquisition while insulating the game loop from native platform quirks. To ensure frame-perfect consistency, the `WindowState` system employs a deferred update strategy: requests to change properties like title, size, position, fullscreen mode, or cursor visibility are queued during the frame and applied atomically just before the next event poll, completely eliminating mid-frame tearing or inconsistent state reads.

Handling modern display environments is a primary focus of this module. It provides comprehensive multi-monitor enumeration (`get_displays`), returning detailed `DisplayInfo` snapshots that include resolution, DPI scale, refresh rate, and physical layout coordinates. This allows the engine to intelligently select startup monitors, center windows across distinct screens, and adapt to DPI scaling changes on the fly. The viewport system (`viewport.rs`) works in tandem with the window manager to decouple the logical game resolution from the physical window size. It provides coordinate conversion helpers that automatically translate OS-level mouse coordinates into game-space coordinates based on the active scale mode (e.g., stretch, letterbox, pixel-perfect).

The module also handles critical rendering integration points. VSync configuration can be toggled between immediate (uncapped), FIFO (standard vsync), and mailbox modes, giving developers tight control over frame presentation and latency. Fullscreen operations support both exclusive mode for maximum performance and borderless desktop mode for seamless multitasking. Additionally, the module exposes native platform features—such as asynchronous file dialogs via `rfd` and OS-level message boxes—allowing for standard file picking and alert interactions without blocking the primary game loop. Fully accessible through the `lurek.window.*` API, this module provides the dependable foundation required to host the engine on any supported desktop OS.

## Functions

### `lurek.window.close`

Closes the window and signals the engine to shut down.

```lua
-- signature
lurek.window.close()
```

**Example**

```lua
do
    -- Call lurek.window.close() to programmatically end the session, e.g. from a Quit button.
    -- Safe to query the function exists before calling it in a headless test context.
    print("close available = " .. tostring(type(lurek.window.close) == "function"))
end
```

---

### `lurek.window.flash`

Flashes the window briefly to attract the user's attention.

```lua
-- signature
lurek.window.flash()
```

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.focus`

Requests keyboard focus for the window. No-op if already focused.

```lua
-- signature
lurek.window.focus()
```

**Example**

```lua
do
    print("before focus = " .. tostring(lurek.window.hasFocus()))
    lurek.window.focus()
    print("after focus = " .. tostring(lurek.window.hasFocus()))
end
```

---

### `lurek.window.fromPixels`

Converts a value from physical pixel units to logical (DPI-independent) units using the current DPI scale.

```lua
-- signature
lurek.window.fromPixels(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `number` | The value in physical pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The value in logical units. |

**Example**

```lua
do
    local logical = lurek.window.fromPixels(200)
    print("200 pixels in logical:", logical)
    local pixels = lurek.window.toPixels(100)
    print("100 logical in pixels:", pixels)
end
```

---

### `lurek.window.getCurrentDisplay`

Returns the index of the display that currently contains the window.

```lua
-- signature
lurek.window.getCurrentDisplay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The zero-based index of the current display. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end
```

---

### `lurek.window.getDPIScale`

Returns the current DPI scale factor of the window. A value of 2.0 means the display uses 2x scaling (e.g., Retina).

```lua
-- signature
lurek.window.getDPIScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The DPI scale factor. |

**Example**

```lua
do
    local s = lurek.window.getDPIScale()
    print("DPI scale:", s)
end
```

---

### `lurek.window.getDesktopDimensions`

Returns the desktop resolution of a specific display, or the current display if none is specified.

```lua
-- signature
lurek.window.getDesktopDimensions(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display?` | `number` | Zero-based display index. Uses the current display if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Desktop width in pixels. |
| `number` | b Desktop height in pixels. |

**Example**

```lua
do
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    print("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end
```

---

### `lurek.window.getDimensions`

Returns the current window width and height in logical pixels.

```lua
-- signature
lurek.window.getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The window width. |
| `number` | b The window height. |

**Example**

```lua
do
    local w, h = lurek.window.getDimensions()
    print("window dimensions:", w, h)
end
```

---

### `lurek.window.getDisplayCount`

Returns the number of connected displays (monitors).

```lua
-- signature
lurek.window.getDisplayCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The total number of available displays. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end
```

---

### `lurek.window.getDisplayName`

Returns the human-readable name of a display. Returns "Unknown" if the display cannot be identified.

```lua
-- signature
lurek.window.getDisplayName(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display?` | `number` | Zero-based display index. Uses the current display if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The display name. |

**Example**

```lua
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end
```

---

### `lurek.window.getDisplayOrientation`

Returns the display orientation based on the window's aspect ratio.

```lua
-- signature
lurek.window.getDisplayOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "landscape" if width >= height, "portrait" otherwise. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.getDisplays`

Returns a list of all connected displays with their properties. Each entry contains index, name, position (x, y), resolution (width, height), scale factor, refresh rate, and whether it is the primary monitor.

```lua
-- signature
lurek.window.getDisplays()
```

**Returns**

| Type | Description |
|------|-------------|
| `WindowGetDisplaysResult` | Array of display info tables with fields: index, name, x, y, width, height, scale, refreshRate, primary. |

**Example**

```lua
do
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    print("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end
```

---

### `lurek.window.getFullscreen`

Returns the current fullscreen state and type.

```lua
-- signature
lurek.window.getFullscreen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether the window is in fullscreen mode. |

**Example**

```lua
do
    local enabled, fsType = lurek.window.getFullscreen()
    print("fullscreen enabled:", enabled)
    print("fullscreen type:", fsType)
end
```

---

### `lurek.window.getFullscreenModes`

Returns a list of all supported fullscreen video modes across all monitors. Each entry contains width, height, and refresh rate.

```lua
-- signature
lurek.window.getFullscreenModes()
```

**Returns**

| Type | Description |
|------|-------------|
| `WindowGetFullscreenModesResult` | Array of mode tables with fields: width (number), height (number), refreshRate (number). |

**Example**

```lua
do
    local modes = lurek.window.getFullscreenModes()
    print("fullscreen modes available:", #modes)
    local m = modes[1] or { width = 0, height = 0, refreshRate = 0 }
    print("first mode:", m.width .. "x" .. m.height, "@", m.refreshRate, "Hz")
end
```

---

### `lurek.window.getGameHeight`

Returns the logical game height as defined by the current scale mode and game configuration.

```lua
-- signature
lurek.window.getGameHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The game height in logical units. |

**Example**

```lua
do
    print("game width:", lurek.window.getGameWidth())
    print("game height:", lurek.window.getGameHeight())
end
```

---

### `lurek.window.getGameWidth`

Returns the logical game width as defined by the current scale mode and game configuration.

```lua
-- signature
lurek.window.getGameWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The game width in logical units. |

**Example**

```lua
do
    print("game width:", lurek.window.getGameWidth())
    print("game height:", lurek.window.getGameHeight())
end
```

---

### `lurek.window.getHeight`

Returns the current window height in logical (DPI-independent) pixels.

```lua
-- signature
lurek.window.getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The window height. |

**Example**

```lua
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    print("window size:", w, h, "focused:", focused)
end
```

---

### `lurek.window.getMode`

Returns the current window display mode: width, height, and a flags table containing fullscreen state, fullscreen type, and VSync mode.

```lua
-- signature
lurek.window.getMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The window width. |
| `number` | b The window height. |
| `WindowGetModeResult` | c Flags table with fields: fullscreen (boolean), fullscreentype (string), vsync (number). |

**Example**

```lua
do
    local w, h, flags = lurek.window.getMode()
    print("mode:", w, "x", h)
    print("fullscreen:", flags.fullscreen)
    print("fullscreen type:", flags.fullscreentype, "vsync:", flags.vsync)
end
```

---

### `lurek.window.getNativeDPIScale`

Returns the native DPI scale factor reported by the operating system.

```lua
-- signature
lurek.window.getNativeDPIScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The native DPI scale. |

**Example**

```lua
do
    local s = lurek.window.getNativeDPIScale()
    print("native DPI scale:", s)
end
```

---

### `lurek.window.getPixelDimensions`

Returns the window dimensions in actual physical pixels, accounting for DPI scaling.

```lua
-- signature
lurek.window.getPixelDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The pixel width. |
| `number` | b The pixel height. |

**Example**

```lua
do
    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel dimensions:", pw, ph)
end
```

---

### `lurek.window.getPosition`

Returns the window position on screen in pixels.

```lua
-- signature
lurek.window.getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a The x-coordinate of the window's top-left corner. |
| `number` | b The y-coordinate of the window's top-left corner. |

**Example**

```lua
do
    local x, y = lurek.window.getPosition()
    print("position:", x, y)
end
```

---

### `lurek.window.getSafeArea`

Returns the safe drawing area of the window. On desktop this is the full window area. Useful for compatibility with mobile-style layout code.

```lua
-- signature
lurek.window.getSafeArea()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X offset (always 0 on desktop). |
| `number` | b Y offset (always 0 on desktop). |
| `number` | c Safe area width. |
| `number` | d Safe area height. |

**Example**

```lua
do
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    print("safe area:", sx, sy, sw, sh)
end
```

---

### `lurek.window.getScaleInfo`

Returns detailed scaling information including scale factors, offsets, and logical game dimensions. Useful for coordinate conversion between screen space and game space.

```lua
-- signature
lurek.window.getScaleInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| `WindowGetScaleInfoResult` | Table with fields: scale_x (number), scale_y (number), offset_x (number), offset_y (number), game_width (number), game_height (number). |

**Example**

```lua
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end
```

---

### `lurek.window.getScaleMode`

Returns the current content scale mode name (e.g., "stretch", "letterbox", "pixel-perfect").

```lua
-- signature
lurek.window.getScaleMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The active scale mode. |

**Example**

```lua
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end
```

---

### `lurek.window.getSystemTheme`

Returns the operating system's current color theme. Desktop currently returns "unknown".

```lua
-- signature
lurek.window.getSystemTheme()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The system theme name. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.getTitle`

Returns the current window title bar text.

```lua
-- signature
lurek.window.getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The current window title. |

**Example**

```lua
do
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
end
```

---

### `lurek.window.getVSync`

Returns the current VSync mode. This function is exposed to Lua scripts.

```lua
-- signature
lurek.window.getVSync()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The VSync mode: 0 = off, 1 = on, -1 = adaptive. |

**Example**

```lua
do
    lurek.window.setVSync(1)
    print("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    print("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    print("adaptive vsync:", lurek.window.getVSync())
end
```

---

### `lurek.window.getWidth`

Returns the current window width in logical (DPI-independent) pixels.

```lua
-- signature
lurek.window.getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The window width. |

**Example**

```lua
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    print("window size:", w, h, "focused:", focused)
end
```

---

### `lurek.window.hasFocus`

Returns whether the window currently has keyboard focus.

```lua
-- signature
lurek.window.hasFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window has keyboard input focus. |

**Example**

```lua
do
    print("before focus = " .. tostring(lurek.window.hasFocus()))
    lurek.window.focus()
    print("after focus = " .. tostring(lurek.window.hasFocus()))
end
```

---

### `lurek.window.hasMouseFocus`

Returns whether the mouse cursor is inside the window.

```lua
-- signature
lurek.window.hasMouseFocus()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the mouse cursor is within the window bounds. |

**Example**

```lua
do
    local v = lurek.window.hasMouseFocus()
    print("mouse focus = " .. tostring(v))
end
```

---

### `lurek.window.isFullscreen`

Returns whether the window is currently in fullscreen mode.

```lua
-- signature
lurek.window.isFullscreen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window is fullscreen. |

**Example**

```lua
do
    local v = lurek.window.isFullscreen()
    print("is fullscreen:", v)
end
```

---

### `lurek.window.isHighDPIAllowed`

Returns whether high-DPI rendering is allowed. Currently always returns false on desktop.

```lua
-- signature
lurek.window.isHighDPIAllowed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if high-DPI mode is enabled. |

**Example**

```lua
do
    local v = lurek.window.isHighDPIAllowed()
    print("high DPI allowed:", v)
end
```

---

### `lurek.window.isMaximized`

Returns whether the window is currently maximized.

```lua
-- signature
lurek.window.isMaximized()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window is maximized. |

**Example**

```lua
do
    lurek.window.maximize()
    print("is maximized = " .. tostring(lurek.window.isMaximized()))
    lurek.window.restore()
end
```

---

### `lurek.window.isMinimized`

Returns whether the window is currently minimized to the taskbar.

```lua
-- signature
lurek.window.isMinimized()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window is minimized. |

**Example**

```lua
do
    lurek.window.minimize()
    print("is minimized = " .. tostring(lurek.window.isMinimized()))
    lurek.window.restore()
end
```

---

### `lurek.window.isOpen`

Returns whether the window is currently open. Always returns true while the game is running.

```lua
-- signature
lurek.window.isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window exists. |

**Example**

```lua
do
    print("is open:", lurek.window.isOpen())
    print("visible/resizable/maximized/minimized:", lurek.window.isVisible(), lurek.window.isResizable(), lurek.window.isMaximized(), lurek.window.isMinimized())
end
```

---

### `lurek.window.isResizable`

Returns whether the window can be resized by the user.

```lua
-- signature
lurek.window.isResizable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window is resizable. |

**Example**

```lua
do
    print("is resizable:", lurek.window.isResizable())
    print("open/visible/maximized/minimized:", lurek.window.isOpen(), lurek.window.isVisible(), lurek.window.isMaximized(), lurek.window.isMinimized())
end
```

---

### `lurek.window.isVisible`

Returns whether the window is currently visible on screen.

```lua
-- signature
lurek.window.isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the window is visible. |

**Example**

```lua
do
    print("is visible:", lurek.window.isVisible())
    print("open/resizable/maximized/minimized:", lurek.window.isOpen(), lurek.window.isResizable(), lurek.window.isMaximized(), lurek.window.isMinimized())
end
```

---

### `lurek.window.maximize`

Maximizes the window to fill the screen.

```lua
-- signature
lurek.window.maximize()
```

**Example**

```lua
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.minimize`

Minimizes the window to the taskbar.

```lua
-- signature
lurek.window.minimize()
```

**Example**

```lua
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.onDpiChange`

Registers a callback function that is called whenever the DPI scale factor changes (e.g., when the window is moved to a different monitor). Only one callback can be active at a time; setting a new one replaces the previous.

```lua
-- signature
lurek.window.onDpiChange(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | `function` | Callback receiving the new DPI scale as a number. |

**Example**

```lua
do
    lurek.window.onDpiChange(function(scale) print("dpi changed:", scale) end)
    local currentScale = lurek.window.pollDpiChange()
    print("current dpi scale:", currentScale)
end
```

---

### `lurek.window.openFileDialog`

Opens a native file picker dialog and returns the selected file paths. Blocks until the user picks file(s) or cancels.

```lua
-- signature
lurek.window.openFileDialog(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Optional config table with fields: title (string), defaultPath (string), multiple (boolean), filters (table of {name, extensions}). |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Selected file path strings. Empty table if cancelled. |

**Example**

```lua
do
    local files = lurek.window.openFileDialog({ title = "Select file", multiple = true })
    print("selected file count:", #files)
    print("first file:", tostring(files[1]))
end
```

---

### `lurek.window.pollDpiChange`

Checks if the DPI scale has changed since the last poll and fires the onDpiChange callback if so. Call this once per frame in your update loop to detect monitor changes.

```lua
-- signature
lurek.window.pollDpiChange()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The current DPI scale factor. |

**Example**

```lua
do
    lurek.window.onDpiChange(function(scale) print("dpi changed:", scale) end)
    local currentScale = lurek.window.pollDpiChange()
    print("current dpi scale:", currentScale)
end
```

---

### `lurek.window.requestAttention`

Requests user attention by flashing the taskbar icon. Useful for notifying the player when the window is in the background.

```lua
-- signature
lurek.window.requestAttention()
```

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.restore`

Restores the window from minimized or maximized state to its previous size and position.

```lua
-- signature
lurek.window.restore()
```

**Example**

```lua
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end
```

---

### `lurek.window.setDisplay`

Moves the window to the specified display. Throws an error if the index is negative.

```lua
-- signature
lurek.window.setDisplay(display)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `display` | `number` | Zero-based index of the target display. |

**Example**

```lua
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end
```

---

### `lurek.window.setFullscreen`

Enables or disables fullscreen mode. Supports "desktop" (borderless) and "exclusive" types.

```lua
-- signature
lurek.window.setFullscreen(enabled, fstype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | Whether to enter fullscreen. |
| `fstype?` | `string` | Fullscreen type: "desktop" (default) or "exclusive". |

**Example**

```lua
do
    lurek.window.setFullscreen(true, "desktop")
    print("after enable:", lurek.window.isFullscreen())
    lurek.window.setFullscreen(false)
    print("after disable:", lurek.window.isFullscreen())
end
```

---

### `lurek.window.setIcon`

Sets the window icon from an image file. The file must exist in the game's filesystem. Supports PNG and other common image formats.

```lua
-- signature
lurek.window.setIcon(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to the icon image file. |

**Example**

```lua
do
    lurek.window.setIcon("content/examples/assets/images/sample_icon.png")
    print("icon set")
end
```

---

### `lurek.window.setMode`

Sets the window display mode with a specific resolution and optional flags. Use this to resize the window and configure fullscreen or VSync at the same time.

```lua
-- signature
lurek.window.setMode(w, h, flags)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | The desired window width in pixels. |
| `h` | `number` | The desired window height in pixels. |
| `flags?` | `table` | Optional table with fields: fullscreen (boolean), fullscreentype (string), vsync (number). |

**Example**

```lua
do
    lurek.window.setMode(1280, 720, { fullscreen = false, fullscreentype = "desktop", vsync = 1 })
    local nw, nh, nflags = lurek.window.getMode()
    print("new mode:", nw, "x", nh, "vsync:", nflags.vsync)
end
```

---

### `lurek.window.setPosition`

Moves the window to the specified screen position.

```lua
-- signature
lurek.window.setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | The x-coordinate for the window's top-left corner. |
| `y` | `number` | The y-coordinate for the window's top-left corner. |

**Example**

```lua
do
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    print("new position:", nx, ny)
end
```

---

### `lurek.window.setScaleMode`

Sets the content scale mode. Controls how the game's logical resolution maps to the window size.

```lua
-- signature
lurek.window.setScaleMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | The scale mode name (e.g., "stretch", "letterbox", "pixel-perfect"). |

**Example**

```lua
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end
```

---

### `lurek.window.setTitle`

Sets the window title bar text. This function is exposed to Lua scripts.

```lua
-- signature
lurek.window.setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The new window title to display. |

**Example**

```lua
do
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
end
```

---

### `lurek.window.setVSync`

Sets the vertical sync mode. Controls how frame presentation is synchronized with the display.

```lua
-- signature
lurek.window.setVSync(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `number` | VSync mode: 0 = off, 1 = on, -1 = adaptive. |

**Example**

```lua
do
    lurek.window.setVSync(1)
    print("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    print("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    print("adaptive vsync:", lurek.window.getVSync())
end
```

---

### `lurek.window.showMessageBox`

Displays a native OS message box dialog. Blocks execution until the user dismisses it.

```lua
-- signature
lurek.window.showMessageBox(title, message, box_type, btn_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | The dialog title. |
| `message` | `string` | The message body text. |
| `box_type?` | `string` | Dialog icon type: "info" (default), "warning", or "error". |
| `btn_type?` | `string` | Button layout: "ok" (default), "okcancel", or "yesno". |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The button the user clicked. |

**Example**

```lua
do
    local title = "Save?"
    local message = "Do you want to save before exit?"
    local box_type = "warning"
    local btn_type = "yesno"
    local result = lurek.window.showMessageBox(title, message, box_type, btn_type)
    print("message box result:", result)
end
```

---

### `lurek.window.toPixels`

Converts a value from logical (DPI-independent) units to physical pixel units using the current DPI scale.

```lua
-- signature
lurek.window.toPixels(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `number` | The value in logical units. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The value in physical pixels. |

**Example**

```lua
do
    local logical = lurek.window.fromPixels(200)
    print("200 pixels in logical:", logical)
    local pixels = lurek.window.toPixels(100)
    print("100 logical in pixels:", pixels)
end
```

---

### `lurek.window.windowConfig`

Applies multiple window settings at once from a configuration table. Supports title, width, height, fullscreen, fullscreentype, vsync, position (x, y), scaleMode, and display index.

```lua
-- signature
lurek.window.windowConfig(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Configuration table with optional fields: title (string), width (number), height (number), fullscreen (boolean), fullscreentype (string), vsync (number), x (number), y (number), scaleMode (string), display (number). |

**Example**

```lua
do
    lurek.window.windowConfig({ title = "Configured Window", width = 1024, height = 768, fullscreen = false, vsync = 1, scaleMode = "letterbox" })
    print("title after config:", lurek.window.getTitle())
    print("dimensions after config:", lurek.window.getDimensions())
end
```

---
