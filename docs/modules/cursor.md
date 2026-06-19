# Cursor

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- Trail effects, zoom-lens support, locking, visibility control, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

## Functions

### `lurek.cursor.newAnimated`

Creates a new animated cursor that can cycle through frames.

```lua
lurek.cursor.newAnimated(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | boolean | Whether the animation loops continuously. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimatedCursor](#lanimatedcursor) | A new animated cursor instance. |

**Example**

```lua
do
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(make_custom_cursor(16, 2), 16)
    local frame_count = animated:frameCount()
    local scale = animated:currentScale()
    cursor_log("animated cursor frames=" .. frame_count .. " scale=" .. scale)
end
```

---

### `lurek.cursor.newCustom`

Creates a new custom cursor with specified dimensions and hotspot position.

```lua
lurek.cursor.newCustom(w, h, hx, hy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width of the cursor image in pixels. |
| `h` | number | Height of the cursor image in pixels. |
| `hx` | number | Hotspot X offset from cursor origin. |
| `hy` | number | Hotspot Y offset from cursor origin. |

**Returns**

| Type | Description |
|------|-------------|
| [LCustomCursor](#lcustomcursor) | A new custom cursor instance. |

**Example**

```lua
do
    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    cursor:setPixel(2, 2, 255, 255, 255, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    cursor_log("custom cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end
```

---

### `lurek.cursor.newManager`

Creates a new cursor manager for handling cursor state and visibility.

```lua
lurek.cursor.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCursorManager](#lcursormanager) | A new cursor manager instance. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:setContext("default")
    local visible = manager:isVisible()
    local context = manager:getContext()
    cursor_log("manager visible=" .. tostring(visible) .. " context=" .. context)
end
```

---

### `lurek.cursor.systemCursors`

Returns a list of all available system cursor names as a string array.

```lua
lurek.cursor.systemCursors()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of system cursor name strings. |

**Example**

```lua
do
    local names = lurek.cursor.systemCursors()
    local first = names[1] or "none"
    local second = names[2] or "none"
    local count = #names
    cursor_log("system cursor count=" .. count .. " sample=" .. first .. "," .. second)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LAnimatedCursor](#lanimatedcursor)
- [LCursorManager](#lcursormanager)
- [LCustomCursor](#lcustomcursor)

## LAnimatedCursor

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimatedCursor:addFrame`

Add a frame from a custom cursor image.

```lua
LAnimatedCursor:addFrame(cursor, duration_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LCustomCursor](#lcustomcursor) | Frame image. |
| `duration_ms` | number | Frame duration in milliseconds. |

**Example**

```lua
do
    local animated = lurek.cursor.newAnimated(true)
    local first = make_custom_cursor(16, 2)
    local second = make_custom_cursor(16, 3)
    animated:addFrame(first, 100)
    animated:addFrame(second, 120)
    cursor_log("animated cursor frame count after addFrame=" .. animated:frameCount())
end
```

---

#### `LAnimatedCursor:clearPulse`

Disable pulse animation for this object.

```lua
LAnimatedCursor:clearPulse()
```

**Example**

```lua
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:clearPulse()
    animated:update(0.10)
    cursor_log("pulse cleared scale=" .. animated:currentScale())
end
```

---

#### `LAnimatedCursor:currentIndex`

Get current frame index for this object.

```lua
LAnimatedCursor:currentIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based frame index. |

**Example**

```lua
do
    local animated = make_animated_cursor()
    animated:update(0.03)
    local index = animated:currentIndex()
    local count = animated:frameCount()
    cursor_log("animated cursor current index=" .. index .. " of " .. count .. " frames")
end
```

---

#### `LAnimatedCursor:currentScale`

Get current scale from pulse animation.

```lua
LAnimatedCursor:currentScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current scale factor. |

**Example**

```lua
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    cursor_log("animated cursor pulse scale=" .. scale)
end
```

---

#### `LAnimatedCursor:frameCount`

Get total frame count for this object.

```lua
LAnimatedCursor:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of frames. |

**Example**

```lua
do
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(make_custom_cursor(16, 2), 100)
    animated:addFrame(make_custom_cursor(16, 4), 100)
    local count = animated:frameCount()
    cursor_log("animated cursor frame count=" .. count)
end
```

---

#### `LAnimatedCursor:reset`

Reset the cursor animation playback to the first frame.

```lua
LAnimatedCursor:reset()
```

**Example**

```lua
do
    local animated = make_animated_cursor()
    animated:update(0.20)
    local before = animated:currentIndex()
    animated:reset()
    local after = animated:currentIndex()
    cursor_log("animated cursor reset from " .. before .. " to " .. after)
end
```

---

#### `LAnimatedCursor:setPulse`

Set the pulse animation speed and scale factor parameters.

```lua
LAnimatedCursor:setPulse(min_scale, max_scale, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_scale` | number | Minimum scale. |
| `max_scale` | number | Maximum scale. |
| `speed` | number | Pulse speed. |

**Example**

```lua
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    cursor_log("pulse configured current scale=" .. scale)
end
```

---

#### `LAnimatedCursor:update`

Update animation (call each frame).

```lua
LAnimatedCursor:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local animated = make_animated_cursor()
    local before = animated:currentIndex()
    animated:update(0.05)
    local after = animated:currentIndex()
    cursor_log("animated cursor index advanced from " .. before .. " to " .. after)
end
```

---

## LCursorManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCursorManager:addRule`

Add a context rule that maps a context to a system cursor.

```lua
LCursorManager:addRule(ctx, cursor_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | string | Context name. |
| `cursor_name` | string | System cursor name. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:addRule("dialogue", "text")
    manager:setContext("dialogue")
    cursor_log("context rule applied for " .. manager:getContext())
end
```

---

#### `LCursorManager:disableTrail`

Disable cursor trail for this object.

```lua
LCursorManager:disableTrail()
```

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 1.0, 1.0, 0.5)
    manager:disableTrail()
    manager:update(200, 120, 0.016)
    cursor_log("trail disabled while cursor remains visible=" .. tostring(manager:isVisible()))
end
```

---

#### `LCursorManager:disableZoom`

Disable cursor zoom for this object.

```lua
LCursorManager:disableZoom()
```

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:enableZoom(1.5, 60)
    manager:disableZoom()
    manager:setContext("default")
    cursor_log("zoom disabled context=" .. manager:getContext())
end
```

---

#### `LCursorManager:enableLineTrail`

Enable cursor trail with line mode.

```lua
LCursorManager:enableLineTrail(r, g, b, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red (0-1). |
| `g` | number | Green (0-1). |
| `b` | number | Blue (0-1). |
| `width` | number | Line width in pixels. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    manager:update(220, 160, 0.016)
    local x, y = manager:getPosition()
    cursor_log("line trail enabled near position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:enableTrail`

Enable cursor trail with fade points mode.

```lua
LCursorManager:enableTrail(r, g, b, lifetime)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red (0-1). |
| `g` | number | Green (0-1). |
| `b` | number | Blue (0-1). |
| `lifetime` | number | Seconds before trail fades. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 0.5, 0.0, 0.8)
    manager:update(200, 140, 0.016)
    local x, y = manager:getPosition()
    cursor_log("trail enabled near position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:enableZoom`

Enable zoom/magnifier at cursor position.

```lua
LCursorManager:enableZoom(magnification, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `magnification` | number | Zoom factor (1-10). |
| `radius` | number | Lens radius in pixels. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:enableZoom(2.0, 80)
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    cursor_log("zoom enabled around position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:getContext`

Get current context name for this object.

```lua
LCursorManager:getContext()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active context name. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:setContext("menu")
    local first = manager:getContext()
    manager:setContext("gameplay")
    cursor_log("context changed from " .. first .. " to " .. manager:getContext())
end
```

---

#### `LCursorManager:getPosition`

Get cursor position for this object.

```lua
LCursorManager:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X position. |
| number | Y position. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:update(640, 360, 0.016)
    local x, y = manager:getPosition()
    local context = manager:getContext()
    cursor_log("cursor position x=" .. x .. " y=" .. y .. " context=" .. context)
end
```

---

#### `LCursorManager:isLocked`

Get cursor lock state for this object.

```lua
LCursorManager:isLocked()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the cursor is locked. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    local before = manager:isLocked()
    manager:setLocked(true)
    local after = manager:isLocked()
    cursor_log("isLocked before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCursorManager:isVisible`

Get cursor visibility for this object.

```lua
LCursorManager:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the cursor is visible. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    local before = manager:isVisible()
    manager:setVisible(false)
    local after = manager:isVisible()
    cursor_log("visibility before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCursorManager:removeRule`

Remove a context rule for this object.

```lua
LCursorManager:removeRule(ctx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | string | Context name to remove. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:addRule("ui", "hand")
    manager:setContext("ui")
    manager:removeRule("ui")
    manager:setContext("default")
    cursor_log("context after removeRule=" .. manager:getContext())
end
```

---

#### `LCursorManager:setAnimated`

Set the active cursor to an animated cursor.

```lua
LCursorManager:setAnimated(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LAnimatedCursor](#lanimatedcursor) | Animated cursor object. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    local animated = make_animated_cursor()
    manager:setAnimated(animated)
    manager:setContext("combat")
    cursor_log("animated cursor active for context=" .. manager:getContext())
end
```

---

#### `LCursorManager:setContext`

Set the current context for context-sensitive switching.

```lua
LCursorManager:setContext(ctx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | string | Context name (default, raycaster, globe, tilemap, ui_button, etc.). |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:setContext("gameplay")
    local context = manager:getContext()
    cursor_log("manager context switched to " .. context)
end
```

---

#### `LCursorManager:setCustom`

Set the active cursor to a custom image cursor.

```lua
LCursorManager:setCustom(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LCustomCursor](#lcustomcursor) | Custom cursor object. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    local cursor = make_custom_cursor(16, 2)
    manager:setCustom(cursor)
    manager:setContext("editor")
    cursor_log("custom cursor active for context=" .. manager:getContext())
end
```

---

#### `LCursorManager:setLocked`

Lock the cursor position using the system grab mode.

```lua
LCursorManager:setLocked(locked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locked` | boolean | Whether the cursor is locked. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:setLocked(true)
    local locked = manager:isLocked()
    manager:setLocked(false)
    cursor_log("lock toggled true=" .. tostring(locked) .. " final=" .. tostring(manager:isLocked()))
end
```

---

#### `LCursorManager:setSystem`

Set the active cursor to a system cursor by name.

```lua
LCursorManager:setSystem(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | System cursor name (arrow, hand, crosshair, ibeam, wait, no, etc.). |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:setSystem("arrow")
    manager:setContext("menu")
    local context = manager:getContext()
    cursor_log("system cursor set for context=" .. context)
end
```

---

#### `LCursorManager:setVisible`

Set cursor visibility for this object.

```lua
LCursorManager:setVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | Whether the cursor is visible. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:setVisible(false)
    local hidden = manager:isVisible()
    manager:setVisible(true)
    cursor_log("visibility toggled hidden=" .. tostring(hidden) .. " final=" .. tostring(manager:isVisible()))
end
```

---

#### `LCursorManager:update`

Update cursor state (call each frame).

```lua
LCursorManager:update(x, y, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Cursor X position. |
| `y` | number | Cursor Y position. |
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local manager = lurek.cursor.newManager()
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    cursor_log("manager update position=" .. x .. "," .. y .. " visible=" .. tostring(visible))
end
```

---

## LCustomCursor

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCustomCursor:getHotspot`

Get hotspot position for this object.

```lua
LCustomCursor:getHotspot()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Hotspot X. |
| number | Hotspot Y. |

**Example**

```lua
do
    local cursor = lurek.cursor.newCustom(32, 32, 16, 16)
    cursor:setPixel(16, 16, 255, 255, 255, 255)
    local hx, hy = cursor:getHotspot()
    local w, h = cursor:getSize()
    cursor_log("cursor hotspot=" .. hx .. "," .. hy .. " size=" .. w .. "x" .. h)
end
```

---

#### `LCustomCursor:getPixel`

Get the pixel color at the specified cursor image position.

```lua
LCustomCursor:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red. |
| number | Green. |
| number | Blue. |
| number | Alpha. |

**Example**

```lua
do
    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = cursor:getPixel(4, 4)
    local sample_is_red = r == 255 and g == 0 and b == 0 and a == 255
    cursor_log("sampled pixel rgba=" .. r .. "," .. g .. "," .. b .. "," .. a .. " red=" .. tostring(sample_is_red))
end
```

---

#### `LCustomCursor:getSize`

Get the pixel width and height of the cursor image.

```lua
LCustomCursor:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width. |
| number | Height. |

**Example**

```lua
do
    local cursor = lurek.cursor.newCustom(24, 24, 12, 12)
    cursor:setPixel(12, 12, 255, 255, 0, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    cursor_log("cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end
```

---

#### `LCustomCursor:setPixel`

Set a pixel color â€” Lua userdata object exposed by the engine.

```lua
LCustomCursor:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red (0-255). |
| `g` | number | Green (0-255). |
| `b` | number | Blue (0-255). |
| `a` | number | Alpha (0-255). |

**Example**

```lua
do
    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(8, 8, 255, 255, 255, 255)
    cursor:setPixel(9, 8, 0, 200, 255, 255)
    local r, g, b, a = cursor:getPixel(8, 8)
    cursor_log("custom pixel set rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---
