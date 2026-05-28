# Cursor

- The `cursor` module manages OS cursor state, custom image cursors, animated frame sequences, context-sensitive switching, visual trail effects, and a magnifying zoom lens for Lurek2D games.

The `cursor` module provides complete cursor lifecycle management for Lurek2D games. At its foundation, the `CursorManager` centralizes all cursor state: it can display native OS system cursors (arrow, crosshair, hand, IBeam, and resize variants), custom RGBA image cursors with configurable hotspot offsets, or smooth animated frame sequences built from `AnimatedCursor`. Each animated cursor supports per-frame durations and an independent sine-driven `PulseConfig` scale animation, creating subtle breathing or emphasis effects without additional scripting.

Context-sensitive switching is a first-class feature. Developers register `ContextRule` mappings from named string contexts (e.g., `"dialog"`, `"combat"`, `"menu"`) to specific cursor states. Activating a context via `setContext` instantly swaps to the registered cursor, allowing the cursor to always reflect the current game interaction mode without polling game state from the rendering layer.

The module also provides two post-process visual effects layered on top of the hardware cursor. The `CursorTrail` records a ring buffer of recent cursor positions (`TrailPoint`), each with linearly decaying alpha, and renders them in one of three modes: fading dots, connected line segments, or particle clusters. The `CursorZoom` lens composites a configurable magnifying glass (1.1× to 8.0×) around the cursor position as a post-process scissored blit, useful for map editors or accessibility features. All cursor behavior — visibility, hardware lock for FPS-style grabs, trail, zoom, and context rules — is fully accessible via the `lurek.cursor.*` Lua API.

## Functions

### `lurek.cursor.newAnimated`

Creates a new animated cursor that can cycle through frames.

```lua
-- signature
lurek.cursor.newAnimated(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | `boolean` | Whether the animation loops continuously. |

**Returns**

| Type | Description |
|------|-------------|
| `LAnimatedCursor` | A new animated cursor instance. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    print("animated frame count = " .. c:frameCount())
    print("animated scale = " .. c:currentScale())
end
```

---

### `lurek.cursor.newCustom`

Creates a new custom cursor with specified dimensions and hotspot position.

```lua
-- signature
lurek.cursor.newCustom(w, h, hx, hy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Width of the cursor image in pixels. |
| `h` | `number` | Height of the cursor image in pixels. |
| `hx` | `number` | Hotspot X offset from cursor origin. |
| `hy` | `number` | Hotspot Y offset from cursor origin. |

**Returns**

| Type | Description |
|------|-------------|
| `LCustomCursor` | A new custom cursor instance. |

**Example**

```lua
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    local w, h = c:getSize()
    print("custom cursor size = " .. w .. "x" .. h)
    print("hotspot = 0,0")
end
```

---

### `lurek.cursor.newManager`

Creates a new cursor manager for handling cursor state and visibility.

```lua
-- signature
lurek.cursor.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| `LCursorManager` | A new cursor manager instance. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    print("manager visible = " .. tostring(cm:isVisible()))
    print("manager context = " .. cm:getContext())
end
```

---

### `lurek.cursor.systemCursors`

Returns a list of all available system cursor names as a string array.

```lua
-- signature
lurek.cursor.systemCursors()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of system cursor name strings. |

**Example**

```lua
do
    local list = lurek.cursor.systemCursors()
    print("lurek.cursor.systemCursors count=" .. #list)
end
```

---

## LAnimatedCursor

### `LAnimatedCursor:addFrame`

Add a frame from a custom cursor image.

```lua
-- signature
LAnimatedCursor:addFrame(cursor, duration_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | `LuaCustomCursor` | Frame image. |
| `duration_ms` | `number` | Frame duration in milliseconds. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    local frame = lurek.cursor.newCustom(16, 16, 0, 0)
    c:addFrame(frame, 100)
    print("LAnimatedCursor:addFrame count=" .. c:frameCount())
end
```

---

### `LAnimatedCursor:clearPulse`

Disable pulse animation for this object.

```lua
-- signature
LAnimatedCursor:clearPulse()
```

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    c:setPulse(0.8, 1.2, 1.5)
    c:clearPulse()
    print("LAnimatedCursor:clearPulse scale=" .. c:currentScale())
end
```

---

### `LAnimatedCursor:currentIndex`

Get current frame index for this object.

```lua
-- signature
LAnimatedCursor:currentIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based frame index. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentIndex=" .. c:currentIndex())
end
```

---

### `LAnimatedCursor:currentScale`

Get current scale from pulse animation.

```lua
-- signature
LAnimatedCursor:currentScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current scale factor. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentScale=" .. c:currentScale())
end
```

---

### `LAnimatedCursor:frameCount`

Get total frame count for this object.

```lua
-- signature
LAnimatedCursor:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of frames. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    print("LAnimatedCursor:frameCount=" .. c:frameCount())
end
```

---

### `LAnimatedCursor:reset`

Reset the cursor animation playback to the first frame.

```lua
-- signature
LAnimatedCursor:reset()
```

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:update(0.2)
    c:reset()
    print("LAnimatedCursor:reset idx=" .. c:currentIndex())
end
```

---

### `LAnimatedCursor:setPulse`

Set the pulse animation speed and scale factor parameters.

```lua
-- signature
LAnimatedCursor:setPulse(min_scale, max_scale, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_scale` | `number` | Minimum scale. |
| `max_scale` | `number` | Maximum scale. |
| `speed` | `number` | Pulse speed. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    c:setPulse(0.8, 1.2, 1.5)
    print("LAnimatedCursor:setPulse scale=" .. c:currentScale())
end
```

---

### `LAnimatedCursor:update`

Update animation (call each frame).

```lua
-- signature
LAnimatedCursor:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local c = lurek.cursor.newAnimated(true)
    local frame = lurek.cursor.newCustom(16, 16, 0, 0)
    c:addFrame(frame, 100)
    c:update(0.05)
    print("LAnimatedCursor:update idx=" .. c:currentIndex())
end
```

---

## LCursorManager

### `LCursorManager:addRule`

Add a context rule that maps a context to a system cursor.

```lua
-- signature
LCursorManager:addRule(ctx, cursor_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | `string` | Context name. |
| `cursor_name` | `string` | System cursor name. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:addRule("gameplay", "crosshair")
    cm:setContext("gameplay")
    print("LCursorManager:addRule ok")
    print("context = " .. cm:getContext())
end
```

---

### `LCursorManager:disableTrail`

Disable cursor trail for this object.

```lua
-- signature
LCursorManager:disableTrail()
```

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 1.0, 1.0, 0.5)
    cm:disableTrail()
    print("LCursorManager:disableTrail ok")
end
```

---

### `LCursorManager:disableZoom`

Disable cursor zoom for this object.

```lua
-- signature
LCursorManager:disableZoom()
```

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:enableZoom(1.5, 60)
    cm:disableZoom()
    print("LCursorManager:disableZoom ok")
end
```

---

### `LCursorManager:enableLineTrail`

Enable cursor trail with line mode.

```lua
-- signature
LCursorManager:enableLineTrail(r, g, b, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red (0-1). |
| `g` | `number` | Green (0-1). |
| `b` | `number` | Blue (0-1). |
| `width` | `number` | Line width in pixels. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    print("LCursorManager:enableLineTrail ok")
    print("locked = " .. tostring(cm:isLocked()))
end
```

---

### `LCursorManager:enableTrail`

Enable cursor trail with fade points mode.

```lua
-- signature
LCursorManager:enableTrail(r, g, b, lifetime)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red (0-1). |
| `g` | `number` | Green (0-1). |
| `b` | `number` | Blue (0-1). |
| `lifetime` | `number` | Seconds before trail fades. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 0.5, 0.0, 0.8)
    print("LCursorManager:enableTrail ok")
    print("visible = " .. tostring(cm:isVisible()))
end
```

---

### `LCursorManager:enableZoom`

Enable zoom/magnifier at cursor position.

```lua
-- signature
LCursorManager:enableZoom(magnification, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `magnification` | `number` | Zoom factor (1-10). |
| `radius` | `number` | Lens radius in pixels. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:enableZoom(2.0, 80)
    print("LCursorManager:enableZoom ok")
    print("context = " .. cm:getContext())
end
```

---

### `LCursorManager:getContext`

Get current context name for this object.

```lua
-- signature
LCursorManager:getContext()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Active context name. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setContext("menu")
    print("LCursorManager:getContext=" .. cm:getContext())
end
```

---

### `LCursorManager:getPosition`

Get cursor position for this object.

```lua
-- signature
LCursorManager:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X position. |
| `number` | b Y position. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    local x, y = cm:getPosition()
    print("LCursorManager:getPosition x=" .. x .. " y=" .. y)
end
```

---

### `LCursorManager:isLocked`

Get cursor lock state for this object.

```lua
-- signature
LCursorManager:isLocked()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether the cursor is locked. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setLocked(false)
    print("LCursorManager:isLocked=" .. tostring(cm:isLocked()))
end
```

---

### `LCursorManager:isVisible`

Get cursor visibility for this object.

```lua
-- signature
LCursorManager:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether the cursor is visible. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setVisible(false)
    print("LCursorManager:isVisible=" .. tostring(cm:isVisible()))
end
```

---

### `LCursorManager:removeRule`

Remove a context rule for this object.

```lua
-- signature
LCursorManager:removeRule(ctx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | `string` | Context name to remove. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:addRule("ui", "hand")
    cm:removeRule("ui")
    print("LCursorManager:removeRule ok")
end
```

---

### `LCursorManager:setAnimated`

Set the active cursor to an animated cursor.

```lua
-- signature
LCursorManager:setAnimated(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | `LuaAnimatedCursor` | Animated cursor object. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    local c = lurek.cursor.newAnimated(true)
    cm:setAnimated(c)
    print("LCursorManager:setAnimated ok")
end
```

---

### `LCursorManager:setContext`

Set the current context for context-sensitive switching.

```lua
-- signature
LCursorManager:setContext(ctx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | `string` | Context name (default, raycaster, globe, tilemap, ui_button, etc.). |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setContext("gameplay")
    print("LCursorManager:setContext=" .. cm:getContext())
end
```

---

### `LCursorManager:setCustom`

Set the active cursor to a custom image cursor.

```lua
-- signature
LCursorManager:setCustom(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | `LuaCustomCursor` | Custom cursor object. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    cm:setCustom(c)
    print("LCursorManager:setCustom ok")
end
```

---

### `LCursorManager:setLocked`

Lock the cursor position using the system grab mode.

```lua
-- signature
LCursorManager:setLocked(locked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locked` | `boolean` | Whether the cursor is locked. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setLocked(true)
    print("LCursorManager:setLocked=" .. tostring(cm:isLocked()))
end
```

---

### `LCursorManager:setSystem`

Set the active cursor to a system cursor by name.

```lua
-- signature
LCursorManager:setSystem(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | System cursor name (arrow, hand, crosshair, ibeam, wait, no, etc.). |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setSystem("arrow")
    print("LCursorManager:setSystem ok")
end
```

---

### `LCursorManager:setVisible`

Set cursor visibility for this object.

```lua
-- signature
LCursorManager:setVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | `boolean` | Whether the cursor is visible. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:setVisible(true)
    print("LCursorManager:setVisible=" .. tostring(cm:isVisible()))
end
```

---

### `LCursorManager:update`

Update cursor state (call each frame).

```lua
-- signature
LCursorManager:update(x, y, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Cursor X position. |
| `y` | `number` | Cursor Y position. |
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local cm = lurek.cursor.newManager()
    cm:update(320, 180, 0.016)
    local x, y = cm:getPosition()
    print("LCursorManager:update ok")
    print("position = " .. x .. ", " .. y)
end
```

---

## LCustomCursor

### `LCustomCursor:getHotspot`

Get hotspot position for this object.

```lua
-- signature
LCustomCursor:getHotspot()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Hotspot X. |
| `number` | b Hotspot Y. |

**Example**

```lua
do
    local c = lurek.cursor.newCustom(32, 32, 16, 16)
    local hx, hy = c:getHotspot()
    print("LCustomCursor:getHotspot hx=" .. hx .. " hy=" .. hy)
end
```

---

### `LCustomCursor:getPixel`

Get the pixel color at the specified cursor image position.

```lua
-- signature
LCustomCursor:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red. |
| `number` | b Green. |
| `number` | c Blue. |
| `number` | d Alpha. |

**Example**

```lua
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = c:getPixel(4, 4)
    print("LCustomCursor:getPixel r=" .. r)
    print("pixel rgba = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `LCustomCursor:getSize`

Get the pixel width and height of the cursor image.

```lua
-- signature
LCustomCursor:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width. |
| `number` | b Height. |

**Example**

```lua
do
    local c = lurek.cursor.newCustom(24, 24, 12, 12)
    local w, h = c:getSize()
    print("LCustomCursor:getSize=" .. w .. "x" .. h)
end
```

---

### `LCustomCursor:setPixel`

Set a pixel color — Lua userdata object exposed by the engine.

```lua
-- signature
LCustomCursor:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `r` | `number` | Red (0-255). |
| `g` | `number` | Green (0-255). |
| `b` | `number` | Blue (0-255). |
| `a` | `number` | Alpha (0-255). |

**Example**

```lua
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(8, 8, 255, 255, 255, 255)
    print("LCustomCursor:setPixel ok")
end
```

---
