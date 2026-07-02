# Cursor

## Purpose

Manages contextual custom cursors, motion trails, and magnifiers.

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- The runtime now treats cursor behavior as one shared active controller rather than isolated per-manager state, which lets hover, click, wheel, trails, bursts, and zoom resolve against one authoritative pointer state each frame.
- State switching is no longer just a manual `if` chain in Lua. `defineState`, `defineEffect`, `addRule`, and `addSource` let projects describe cursor policy declaratively and feed semantic hover hits into the same resolver.
- Trail effects, zoom-lens support, locking, visibility control, click bursts, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.cursor.newAnimated`

Creates an animated cursor that can cycle through custom cursor frames.

```lua
lurek.cursor.newAnimated(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | boolean | True to loop after the last frame, or false to stop on the final frame. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimatedCursor](#lanimatedcursor) | Animated cursor handle. |

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    local frame_count = animated:frameCount()
    local scale = animated:currentScale()
    lurek.log.info("animated cursor frames=" .. frame_count .. " scale=" .. scale)
end
```

---

### `lurek.cursor.newCustom`

Creates a custom RGBA cursor image with an explicit hotspot.

```lua
lurek.cursor.newCustom(w, h, hx, hy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Cursor width in pixels. |
| `h` | number | Cursor height in pixels. |
| `hx` | number | Hotspot X coordinate in pixels. |
| `hy` | number | Hotspot Y coordinate in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LCustomCursor](#lcustomcursor) | Custom cursor handle. |

**Example**

```lua
do

    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    cursor:setPixel(2, 2, 255, 255, 255, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    lurek.log.info("custom cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end
```

---

### `lurek.cursor.newManager`

Returns a handle to the shared runtime cursor controller.

```lua
lurek.cursor.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCursorManager](#lcursormanager) | Cursor manager handle bound to the active shared runtime cursor. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setContext("default")
    local visible = manager:isVisible()
    local context = manager:getContext()
    lurek.log.info("manager visible=" .. tostring(visible) .. " context=" .. context)
end
```

---

### `lurek.cursor.systemCursors`

Returns the list of system cursor names supported by the cursor module.

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
    lurek.log.info("system cursor count=" .. count .. " sample=" .. first .. "," .. second)
end
```

---

## Module Fields

*No module-level fields documented.*

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

Appends one frame to the animated cursor sequence.

```lua
LAnimatedCursor:addFrame(cursor, duration_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LCustomCursor](#lcustomcursor) | Frame image to append. |
| `duration_ms` | number | Frame duration in milliseconds. |

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    local first = lurek.cursor.newCustom(16, 16, 2, 2)
    local second = lurek.cursor.newCustom(16, 16, 3, 3)
    animated:addFrame(first, 100)
    animated:addFrame(second, 120)
    lurek.log.info("animated cursor frame count after addFrame=" .. animated:frameCount())
end
```

---

#### `LAnimatedCursor:clearPulse`

Disables pulse scaling for the animated cursor.

```lua
LAnimatedCursor:clearPulse()
```

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:clearPulse()
    animated:update(0.10)
    lurek.log.info("pulse cleared scale=" .. animated:currentScale())
end
```

---

#### `LAnimatedCursor:currentIndex`

Returns the currently active frame index.

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

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:update(0.03)
    local index = animated:currentIndex()
    local count = animated:frameCount()
    lurek.log.info("animated cursor current index=" .. index .. " of " .. count .. " frames")
end
```

---

#### `LAnimatedCursor:currentScale`

Returns the current pulse scale multiplier.

```lua
LAnimatedCursor:currentScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active scale multiplier. |

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    lurek.log.info("animated cursor pulse scale=" .. scale)
end
```

---

#### `LAnimatedCursor:frameCount`

Returns the number of frames stored in this animated cursor.

```lua
LAnimatedCursor:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total frame count. |

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 100)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 4, 4), 100)
    local count = animated:frameCount()
    lurek.log.info("animated cursor frame count=" .. count)
end
```

---

#### `LAnimatedCursor:reset`

Resets playback to the first frame and clears accumulated animation time.

```lua
LAnimatedCursor:reset()
```

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:update(0.20)
    local before = animated:currentIndex()
    animated:reset()
    local after = animated:currentIndex()
    lurek.log.info("animated cursor reset from " .. before .. " to " .. after)
end
```

---

#### `LAnimatedCursor:setPulse`

Enables pulse scaling for the animated cursor.

```lua
LAnimatedCursor:setPulse(min_scale, max_scale, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_scale` | number | Minimum scale multiplier. |
| `max_scale` | number | Maximum scale multiplier. |
| `speed` | number | Pulse speed in oscillations per second. |

**Example**

```lua
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    lurek.log.info("pulse configured current scale=" .. scale)
end
```

---

#### `LAnimatedCursor:update`

Advances animated cursor playback and pulse state.

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

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    local before = animated:currentIndex()
    animated:update(0.05)
    local after = animated:currentIndex()
    lurek.log.info("animated cursor index advanced from " .. before .. " to " .. after)
end
```

---

## LCursorManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCursorManager:addRule`

Registers a legacy context rule or a v2 runtime rule table for hover, click, release, leave, wheel, or context state resolution.

```lua
LCursorManager:addRule(context_or_rule, cursor_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `context_or_rule` | string|table | Legacy context name, or a v2 rule table with `priority`, `event`, `context`, `target`, `state`, `effect`, and `duration_ms`. |
| `cursor_name?` | string | System cursor name used by the legacy `(context, cursor_name)` shorthand. |

**Returns**

| Type | Description |
|------|-------------|
| number? | Rule id for v2 table calls, or `nil` for the legacy shorthand. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:defineState("inspect", { system = "crosshair" })
    local id = manager:addRule({
        priority = 25,
        event = "context",
        context = "ui_button",
        state = "inspect",
    })
    manager:setContext("ui_button")
    local state = manager:getActiveState()
    lurek.log.info("v2 cursor rule id = " .. id)
    lurek.log.info("v2 cursor rule state kind = " .. state.kind)
end
```

---

#### `LCursorManager:addSource`

Registers a hover source that feeds semantic cursor hits into the shared runtime resolver.

```lua
LCursorManager:addSource(source_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source_tbl` | table | Source table with `kind = "globe"`, `"raycaster_last"`, or `"callback"`, plus source-specific fields such as `globe`, `marker_radius`, or `callback`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Source id used with `removeSource`. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local id = manager:addSource({
        kind = "callback",
        callback = function(x, y)
            return {
                module = "example",
                kind = "hover",
                surface = "surface",
                id = string.format("%.0f:%.0f", x, y),
                attrs = {
                    cursor_state = "inspect",
                },
            }
        end,
    })
    lurek.log.info("cursor source id = " .. id)
end
```

---

#### `LCursorManager:defineEffect`

Defines a reusable cursor-local burst effect preset for hover or click rules.

```lua
LCursorManager:defineEffect(name, spec)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique effect name used by rules or hit attrs such as `cursor_effect`. |
| `spec` | table | Effect table with `shape`, `color`, `texture`, `shader`, `count`, `spread`, `lifetime`, `speed`, `size`, `blend`, and optional `button`. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:defineEffect("click_spark", {
        shape = "ring",
        count = 10,
        spread = math.pi,
        lifetime = 0.18,
        speed = 96,
        size = 5,
        button = 0,
    })
    lurek.log.info("defined click_spark cursor effect")
end
```

---

#### `LCursorManager:defineState`

Defines a reusable named cursor state for rule-driven runtime selection.

```lua
LCursorManager:defineState(name, spec)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique state name used by rules or hit attrs such as `cursor_state`. |
| `spec` | table | State table with one of `system`, `custom`, or `animated`, plus optional `scale`, `offset_x`, `offset_y`, `native_preferred`, `trail`, and `zoom`. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:defineState("inspect", {
        system = "crosshair",
        scale = 1.2,
        offset_x = 1,
        offset_y = -1,
        trail = {
            mode = "ribbon",
            width = 6,
            lifetime = 0.35,
        },
        zoom = {
            magnification = 2.25,
            radius = 44,
        },
    })
    manager:defineState("paint", {
        custom = lurek.cursor.newCustom(16, 16, 2, 2),
        native_preferred = false,
    })
    local preview = manager:getActiveState()
    lurek.log.info("defined cursor states inspect and paint")
    lurek.log.info("preview cursor kind = " .. preview.kind)
end
```

---

#### `LCursorManager:disableTrail`

Disables the current cursor trail.

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
    lurek.log.info("trail disabled while cursor remains visible=" .. tostring(manager:isVisible()))
end
```

---

#### `LCursorManager:disableZoom`

Disables the live cursor zoom lens.

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
    lurek.log.info("zoom disabled context=" .. manager:getContext())
end
```

---

#### `LCursorManager:enableLineTrail`

Enables a simple connected line trail behind the cursor.

```lua
LCursorManager:enableLineTrail(r, g, b, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel in the 0.0 through 1.0 range. |
| `g` | number | Green channel in the 0.0 through 1.0 range. |
| `b` | number | Blue channel in the 0.0 through 1.0 range. |
| `width` | number | Trail line width in pixels. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    manager:update(220, 160, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("line trail enabled near position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:enableTrail`

Enables a simple fading point trail behind the cursor.

```lua
LCursorManager:enableTrail(r, g, b, lifetime)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel in the 0.0 through 1.0 range. |
| `g` | number | Green channel in the 0.0 through 1.0 range. |
| `b` | number | Blue channel in the 0.0 through 1.0 range. |
| `lifetime` | number | Trail point lifetime in seconds. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 0.5, 0.0, 0.8)
    manager:update(200, 140, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("trail enabled near position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:enableZoom`

Enables the live zoom lens centered on the runtime cursor.

```lua
LCursorManager:enableZoom(mag, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mag` | number | Lens magnification multiplier. |
| `radius` | number | Lens radius in screen pixels. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:enableZoom(2.0, 80)
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("zoom enabled around position=" .. x .. "," .. y)
end
```

---

#### `LCursorManager:getActiveState`

Returns the currently resolved cursor state after context, hover, and override rules have been applied.

```lua
LCursorManager:getActiveState()
```

**Returns**

| Type | Description |
|------|-------------|
| LCursorManagerGetActiveStateResult | Active state info table. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setSystem("hand")
    manager:setContext("example_active_state")
    local state = manager:getActiveState()
    lurek.log.info("active cursor kind = " .. state.kind)
    lurek.log.info("active cursor prefers native = " .. tostring(state.native_preferred))
    lurek.log.info("active cursor scale = " .. tostring(state.scale))
end
```

---

#### `LCursorManager:getContext`

Returns the current named cursor context.

```lua
LCursorManager:getContext()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active cursor context name. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setContext("menu")
    local first = manager:getContext()
    manager:setContext("gameplay")
    lurek.log.info("context changed from " .. first .. " to " .. manager:getContext())
end
```

---

#### `LCursorManager:getLastHit`

Returns the most recent semantic hover hit seen by the runtime cursor.

```lua
LCursorManager:getLastHit()
```

**Returns**

| Type | Description |
|------|-------------|
| table? | Last hover hit table, or `nil` when nothing is currently resolved. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:addSource({
        kind = "callback",
        callback = function()
            return {
                module = "example",
                kind = "marker",
                surface = "surface",
                id = "hover-01",
            }
        end,
    })
    manager:update(48, 64, 0.016)
    local hit = manager:getLastHit()
    lurek.log.info("cursor last hit exists = " .. tostring(hit ~= nil))
    lurek.log.info("cursor last hit kind = " .. tostring(hit and hit.kind))
    lurek.log.info("cursor last hit id = " .. tostring(hit and hit.id))
end
```

---

#### `LCursorManager:getPosition`

Returns the current runtime cursor position.

```lua
LCursorManager:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:update(640, 360, 0.016)
    local x, y = manager:getPosition()
    local context = manager:getContext()
    lurek.log.info("cursor position x=" .. x .. " y=" .. y .. " context=" .. context)
end
```

---

#### `LCursorManager:isLocked`

Returns whether the runtime cursor is currently marked as locked.

```lua
LCursorManager:isLocked()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cursor is locked. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local before = manager:isLocked()
    manager:setLocked(true)
    local after = manager:isLocked()
    lurek.log.info("isLocked before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCursorManager:isVisible`

Returns whether the runtime cursor is currently visible.

```lua
LCursorManager:isVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cursor is visible. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local before = manager:isVisible()
    manager:setVisible(false)
    local after = manager:isVisible()
    lurek.log.info("visibility before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LCursorManager:removeRule`

Removes a legacy context rule that was registered with the `(context, cursor_name)` shorthand.

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
    lurek.log.info("context after removeRule=" .. manager:getContext())
end
```

---

#### `LCursorManager:removeSource`

Removes a previously registered hover source.

```lua
LCursorManager:removeSource(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Source id returned by `addSource`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a source with that id was removed. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local id = manager:addSource({
        kind = "callback",
        callback = function()
            return nil
        end,
    })
    local removed = manager:removeSource(id)
    lurek.log.info("cursor source removed = " .. tostring(removed))
end
```

---

#### `LCursorManager:setAnimated`

Switches the active runtime cursor to an animated cursor immediately.

```lua
LCursorManager:setAnimated(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LAnimatedCursor](#lanimatedcursor) | Animated cursor handle to display. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    manager:setAnimated(animated)
    manager:setContext("combat")
    lurek.log.info("animated cursor active for context=" .. manager:getContext())
end
```

---

#### `LCursorManager:setContext`

Sets the named cursor context used by legacy rules and context-sensitive state resolution.

```lua
LCursorManager:setContext(ctx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ctx` | string | Context name such as `"default"`, `"menu"`, or `"gameplay"`. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:setContext("gameplay")
    local context = manager:getContext()
    lurek.log.info("manager context switched to " .. context)
end
```

---

#### `LCursorManager:setCustom`

Switches the active runtime cursor to a custom RGBA cursor immediately.

```lua
LCursorManager:setCustom(cursor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cursor` | [LCustomCursor](#lcustomcursor) | Custom cursor handle to display. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    manager:setCustom(cursor)
    manager:setContext("editor")
    lurek.log.info("custom cursor active for context=" .. manager:getContext())
end
```

---

#### `LCursorManager:setLocked`

Locks or unlocks the runtime cursor according to the active platform policy.

```lua
LCursorManager:setLocked(locked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locked` | boolean | True to request cursor lock, or false to release it. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setLocked(true)
    local locked = manager:isLocked()
    manager:setLocked(false)
    lurek.log.info("lock toggled true=" .. tostring(locked) .. " final=" .. tostring(manager:isLocked()))
end
```

---

#### `LCursorManager:setSystem`

Switches the active runtime cursor to a named system cursor immediately.

```lua
LCursorManager:setSystem(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | System cursor name such as `"arrow"`, `"hand"`, or `"crosshair"`. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setSystem("arrow")
    manager:setContext("menu")
    local context = manager:getContext()
    lurek.log.info("system cursor set for context=" .. context)
end
```

---

#### `LCursorManager:setVisible`

Shows or hides the runtime cursor.

```lua
LCursorManager:setVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | True to show the cursor, or false to hide it. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:setVisible(false)
    local hidden = manager:isVisible()
    manager:setVisible(true)
    lurek.log.info("visibility toggled hidden=" .. tostring(hidden) .. " final=" .. tostring(manager:isVisible()))
end
```

---

#### `LCursorManager:type`

Returns the Lua handle type name for this cursor manager userdata.

```lua
LCursorManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Lua userdata type tag. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    local manager_type = manager:type()
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    lurek.log.info("cursor manager type = " .. manager_type)
    lurek.log.info("cursor manager position = " .. x .. "," .. y)
    lurek.log.info("cursor manager visible = " .. tostring(visible))
end
```

---

#### `LCursorManager:update`

Overrides the runtime cursor position and advances cursor-local effects for one frame.

```lua
LCursorManager:update(x, y, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Cursor X position in screen pixels. |
| `y` | number | Cursor Y position in screen pixels. |
| `dt` | number | Delta time in seconds for this manual update step. |

**Example**

```lua
do

    local manager = lurek.cursor.newManager()
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    lurek.log.info("manager update position=" .. x .. "," .. y .. " visible=" .. tostring(visible))
end
```

---

## LCustomCursor

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCustomCursor:getHotspot`

Returns the hotspot used when positioning this custom cursor.

```lua
LCustomCursor:getHotspot()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Hotspot X coordinate. |
| number | Hotspot Y coordinate. |

**Example**

```lua
do

    local cursor = lurek.cursor.newCustom(32, 32, 16, 16)
    cursor:setPixel(16, 16, 255, 255, 255, 255)
    local hx, hy = cursor:getHotspot()
    local w, h = cursor:getSize()
    lurek.log.info("cursor hotspot=" .. hx .. "," .. hy .. " size=" .. w .. "x" .. h)
end
```

---

#### `LCustomCursor:getPixel`

Reads one RGBA pixel from the custom cursor image.

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
    lurek.log.info("sampled pixel rgba=" .. r .. "," .. g .. "," .. b .. "," .. a .. " red=" .. tostring(sample_is_red))
end
```

---

#### `LCustomCursor:getSize`

Returns the custom cursor image size.

```lua
LCustomCursor:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do

    local cursor = lurek.cursor.newCustom(24, 24, 12, 12)
    cursor:setPixel(12, 12, 255, 255, 0, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    lurek.log.info("cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end
```

---

#### `LCustomCursor:setPixel`

Writes one RGBA pixel into the custom cursor image.

```lua
LCustomCursor:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel in the 0 through 255 range. |
| `g` | number | Green channel in the 0 through 255 range. |
| `b` | number | Blue channel in the 0 through 255 range. |
| `a` | number | Alpha channel in the 0 through 255 range. |

**Example**

```lua
do

    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(8, 8, 255, 255, 255, 255)
    cursor:setPixel(9, 8, 0, 200, 255, 255)
    local r, g, b, a = cursor:getPixel(8, 8)
    lurek.log.info("custom pixel set rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---
