# Cursor

## Summary

The `cursor` module owns cursor presentation and behavior policy, including system cursor selection, custom image cursors, animated cursor sequences, context-based switching, trail effects, and cursor magnifier support. It provides a single stateful surface for cursor concerns instead of scattering cursor logic across input and UI code.

Submodules map directly to feature domains: `system_cursor` for native cursor kinds, `custom_cursor` for image/hotspot management, `animated_cursor` for timed frame cycling and pulse behavior, `context` for dynamic mode switching, `trail` for visual trails, and `zoom` for cursor-centered magnification.

The design keeps input capture and cursor rendering conceptually separate. Input modules report state; cursor modules decide representation and visual behavior. This improves maintainability when adding context-sensitive visuals or accessibility-oriented cursor modes.

In practice, cursor behavior should remain deterministic and low-latency, with clear fallback paths between native/system cursors and custom/animated variants.

Implementation detail and boundary guarantees for cursor: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: animated_cursor.rs: Animated cursor: frame sequences with per-frame timing and pulse scale effects.; config.rs: Global cursor system configuration shared across the cursor manager.; context.rs: Context-sensitive cursor switching: maps named contexts to cursor states.; custom_cursor.rs: Custom image cursor built from RGBA pixel data with configurable hotspot offset.; mod.rs: Cursor management system.; system_cursor.rs: System cursor shapes available on all desktop platforms.; trail.rs: Cursor trail effects: fading dot trails, connected line trails, and particle modes.; zoom.rs: Cursor magnifier lens: a configurable zoom window that follows the cursor.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### animated_cursor.rs

- Implements animated cursor state using frame sequences and time-based frame advancement.
- Supports optional pulse scaling driven by oscillation parameters independent of frame stepping.
- Maintains deterministic timing behavior through per-frame duration tracking.
- Integrates as an active cursor-state variant within context-aware cursor orchestration.
- Serves as the runtime animation layer for custom cursors with motion feedback.

### config.rs

- Defines cursor-system configuration values loaded from project settings and startup defaults.
- Controls feature toggles and behavior for trail effects, zoom lens, contexts, and idle visibility.
- Serves as the shared config contract consumed by cursor runtime orchestration.

### context.rs

- Implements context-sensitive cursor switching by mapping named runtime contexts to cursor states.
- Supports system, custom, and animated cursor variants under one discriminated state model.
- Applies context changes immediately while preserving a deterministic default fallback path.
- Integrates optional trail and zoom behavior into active cursor presentation state.
- Serves as the policy layer for script-driven cursor-mode transitions.

### custom_cursor.rs

- Implements custom cursor images built from RGBA pixel buffers and hotspot metadata.
- Validates buffer dimensions at construction to prevent malformed cursor payload usage.
- Supports standalone custom cursors and animated-frame reuse through shared image structure.
- Serves as the pixel-defined cursor asset contract for script-driven cursor customization.

### mod.rs

- Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior.
- Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface.
- Serves as the composition entry for engine and script-side cursor control workflows.

### system_cursor.rs

- Defines cross-platform system cursor shape variants used by runtime cursor state.
- Maps engine-facing cursor variants to platform-native icon representations.
- Supports case-insensitive string parsing for config and script-driven selection.
- Serves as the canonical enum contract for system cursor mode requests.

### trail.rs

- Implements cursor-trail effects with fading points, connected strokes, and particle-style variants.
- Tracks trail samples as timestamped points with alpha decay progression over update ticks.
- Maintains bounded point history through capped storage to control runtime memory pressure.
- Supports multiple trail render modes selected by explicit trail behavior configuration.
- Serves as the visual motion-feedback layer for cursor movement presentation.

### zoom.rs

- Implements cursor-following zoom-lens state for magnified local inspection around pointer position.
- Stores radius, magnification, and border settings used by post-process cursor-lens rendering.
- Serves as the magnifier feature contract controlled through cursor config and scripting paths.

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
| [LAnimatedCursor](#lanimatedcursor-handle) | A new animated cursor instance. |

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
| [LCustomCursor](#lcustomcursor-handle) | A new custom cursor instance. |

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
lurek.cursor.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCursorManager](#lcursormanager-handle) | A new cursor manager instance. |

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
lurek.cursor.systemCursors()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of system cursor name strings. |

**Example**

```lua
do
    local list = lurek.cursor.systemCursors()
    print("lurek.cursor.systemCursors count=" .. #list)
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LAnimatedCursor Handle](#lanimatedcursor-handle)
- [LCursorManager Handle](#lcursormanager-handle)
- [LCustomCursor Handle](#lcustomcursor-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LAnimatedCursor Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LAnimatedCursor:addFrame`

Add a frame from a custom cursor image.

```lua
LAnimatedCursor:addFrame(cursor, duration_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LCustomCursor](#lcustomcursor-handle) | Frame image. |
| `duration_ms` | number | Frame duration in milliseconds. |

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

#### `LAnimatedCursor:clearPulse`

Disable pulse animation for this object.

```lua
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
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentIndex=" .. c:currentIndex())
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
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentScale=" .. c:currentScale())
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
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    print("LAnimatedCursor:frameCount=" .. c:frameCount())
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
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:update(0.2)
    c:reset()
    print("LAnimatedCursor:reset idx=" .. c:currentIndex())
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
    local c = lurek.cursor.newAnimated(true)
    c:setPulse(0.8, 1.2, 1.5)
    print("LAnimatedCursor:setPulse scale=" .. c:currentScale())
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
    local c = lurek.cursor.newAnimated(true)
    local frame = lurek.cursor.newCustom(16, 16, 0, 0)
    c:addFrame(frame, 100)
    c:update(0.05)
    print("LAnimatedCursor:update idx=" .. c:currentIndex())
end
```

---

## LCursorManager Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    local cm = lurek.cursor.newManager()
    cm:addRule("gameplay", "crosshair")
    cm:setContext("gameplay")
    print("LCursorManager:addRule ok")
    print("context = " .. cm:getContext())
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
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 1.0, 1.0, 0.5)
    cm:disableTrail()
    print("LCursorManager:disableTrail ok")
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
    local cm = lurek.cursor.newManager()
    cm:enableZoom(1.5, 60)
    cm:disableZoom()
    print("LCursorManager:disableZoom ok")
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
    local cm = lurek.cursor.newManager()
    cm:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    print("LCursorManager:enableLineTrail ok")
    print("locked = " .. tostring(cm:isLocked()))
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
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 0.5, 0.0, 0.8)
    print("LCursorManager:enableTrail ok")
    print("visible = " .. tostring(cm:isVisible()))
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
    local cm = lurek.cursor.newManager()
    cm:enableZoom(2.0, 80)
    print("LCursorManager:enableZoom ok")
    print("context = " .. cm:getContext())
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
    local cm = lurek.cursor.newManager()
    cm:setContext("menu")
    print("LCursorManager:getContext=" .. cm:getContext())
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
    local cm = lurek.cursor.newManager()
    local x, y = cm:getPosition()
    print("LCursorManager:getPosition x=" .. x .. " y=" .. y)
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
    local cm = lurek.cursor.newManager()
    cm:setLocked(false)
    print("LCursorManager:isLocked=" .. tostring(cm:isLocked()))
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
    local cm = lurek.cursor.newManager()
    cm:setVisible(false)
    print("LCursorManager:isVisible=" .. tostring(cm:isVisible()))
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
    local cm = lurek.cursor.newManager()
    cm:addRule("ui", "hand")
    cm:removeRule("ui")
    print("LCursorManager:removeRule ok")
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
| `cursor` | [LAnimatedCursor](#lanimatedcursor-handle) | Animated cursor object. |

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
    local cm = lurek.cursor.newManager()
    cm:setContext("gameplay")
    print("LCursorManager:setContext=" .. cm:getContext())
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
| `cursor` | [LCustomCursor](#lcustomcursor-handle) | Custom cursor object. |

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
    local cm = lurek.cursor.newManager()
    cm:setLocked(true)
    print("LCursorManager:setLocked=" .. tostring(cm:isLocked()))
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
    local cm = lurek.cursor.newManager()
    cm:setSystem("arrow")
    print("LCursorManager:setSystem ok")
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
    local cm = lurek.cursor.newManager()
    cm:setVisible(true)
    print("LCursorManager:setVisible=" .. tostring(cm:isVisible()))
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
    local cm = lurek.cursor.newManager()
    cm:update(320, 180, 0.016)
    local x, y = cm:getPosition()
    print("LCursorManager:update ok")
    print("position = " .. x .. ", " .. y)
end
```

---

## LCustomCursor Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    local c = lurek.cursor.newCustom(32, 32, 16, 16)
    local hx, hy = c:getHotspot()
    print("LCustomCursor:getHotspot hx=" .. hx .. " hy=" .. hy)
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
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = c:getPixel(4, 4)
    print("LCustomCursor:getPixel r=" .. r)
    print("pixel rgba = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    local c = lurek.cursor.newCustom(24, 24, 12, 12)
    local w, h = c:getSize()
    print("LCustomCursor:getSize=" .. w .. "x" .. h)
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
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(8, 8, 255, 255, 255, 255)
    print("LCustomCursor:setPixel ok")
end
```

---
