# Tween

## Purpose

Timed interpolation engine supporting easing curves, spring dynamics, and sequence composition with coroutine awaiting.

## When To Use

- Tweens, handles, chains, grouped sequences, interpolators, and springs all live together here so one-off transitions and larger scripted motion can share one model.
- This matters because many features need shaped progression, not just endpoint changes: UI reveals, camera motion, gameplay feedback, and scripted effects all depend on timing semantics.
- Easing and spring behavior give the module expressive range, while handle-based control makes active transitions inspectable, cancelable, and synchronizable.

## Minimal Example

From the `lurek.tween.tween` example block:

```lua
do
    local obj = { x = 0, y = 0 }
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    example_print_log("type = " .. tw:type())
    lurek.tween.update(0.5)
    example_print_log("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
end
```

## Common Patterns

- Start with `lurek.tween.cancelAll` when exploring this module.
- Start with `lurek.tween.delay` when exploring this module.
- Start with `lurek.tween.getActiveCount` when exploring this module.
- Start with `lurek.tween.getEasingNames` when exploring this module.
- Start with `lurek.tween.newChain` when exploring this module.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/tween.lua`

## Summary

- The `tween` module is the engine's interpolation and motion-sequencing surface for users who want values to change over time without hand-writing frame-by-frame update loops.
- Tweens, handles, chains, grouped sequences, interpolators, and springs all live together here so one-off transitions and larger scripted motion can share one model.
- This matters because many features need shaped progression, not just endpoint changes: UI reveals, camera motion, gameplay feedback, and scripted effects all depend on timing semantics.
- Easing and spring behavior give the module expressive range, while handle-based control makes active transitions inspectable, cancelable, and synchronizable.
- The sequencing surface is important because many real transitions happen in stages instead of one linear interpolation.
- Parallel and chained motion therefore belong in the same subsystem as simple tweens, which keeps authored timing workflows coherent instead of scattering them across unrelated feature code.
- This makes the module suitable not only for decorative polish, but also for stateful workflows where motion is part of how a feature behaves instead of merely how it looks.
- The feature is useful whenever another system decides what should move but still needs reusable rules for how that movement advances over time.
- That separation is what lets several domains share one timing model without sharing any domain-specific update semantics.
- It also gives tools and gameplay code the same language for staged motion and timed value changes.
- The same model also helps previews and iteration stay controllable while motion is active.
- It is therefore as much a sequencing tool as a visual-polish helper.
- The module improves consistency across UI, cameras, overlays, and feedback systems by giving them one temporal vocabulary.
- Read `tween` as the engine's reusable workflow for interpolation, sequencing, and spring-like motion.

This module primarily collaborates with `math`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.tween.cancelAll`

Immediately cancels all active tweens, sequences, parallels, and springs managed by the tween engine.

```lua
lurek.tween.cancelAll()
```

**Example**

```lua
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    example_print_log("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    example_print_log("easing_count=" .. #names)
end
```

---

### `lurek.tween.delay`

Creates a one-shot delay. After the specified seconds elapse, the optional callback is invoked.

```lua
lurek.tween.delay(seconds, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Duration to wait in seconds. |
| `cb?` | function | Optional callback fired when the delay completes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | A sequence handle representing the delay. |

**Example**

```lua
do
    local gate = { locked = true, alpha = 0.0 }
    local d = lurek.tween.delay(1.5, function()
        gate.locked = false
        gate.alpha = 1.0
    end)
    lurek.tween.update(0.75)
    lurek.log.info("gate warning visible=" .. string.format("%.1f", gate.alpha))
    lurek.tween.update(0.75)
    lurek.log.info("gate unlocked=" .. tostring(not gate.locked))
end
```

---

### `lurek.tween.getActiveCount`

Returns the total number of currently active tweens, sequences, and parallels.

```lua
lurek.tween.getActiveCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of active tween objects. |

**Example**

```lua
do
    local a = { x = 0 }
    local b = { y = 0 }
    lurek.tween.tween(1.0, a, { x = 10 })
    lurek.tween.tween(2.0, b, { y = 20 })
    example_print_log("active count = " .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("after cancelAll = " .. lurek.tween.getActiveCount())
end
```

---

### `lurek.tween.getEasingNames`

Returns an array of all available easing function names, including both built-in and custom-registered easings.

```lua
lurek.tween.getEasingNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Easing name strings. |

**Example**

```lua
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    example_print_log("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    example_print_log("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    example_print_log("easing_count=" .. #names)
end
```

---

### `lurek.tween.newChain`

Creates a sequential tween chain for cinematic value-interpolation sequences.

```lua
lurek.tween.newChain(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping?` | boolean | True to loop back to step 0 after the last step (default false). |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | New tween chain handle. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "raise_platform" })
    chain:push({ from = 1.0, to = 0.8, duration = 0.1, label = "settle_platform" })
    chain:tick(0.2)
    lurek.log.info("platform cue value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("platform cue steps=" .. tostring(chain:len()))
end
```

---

### `lurek.tween.newState`

Creates a standalone tween state for manual interpolation. Useful when you need eased progress without automatic property updates.

```lua
lurek.tween.newState(duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenState](#ltweenstate) | The new tween state handle. |

**Example**

```lua
do
    local state = lurek.tween.newState(2.0, "easeInOutCubic")
    example_print_log("type = " .. state:type())
    example_print_log("complete = " .. tostring(state:isComplete()))

    state:tick(1.0)
    local val = state:lerp(0.0, 1.0)
    example_print_log("at 1.0s: eased value = " .. string.format("%.3f", val))
    example_print_log("raw t = " .. string.format("%.3f", state:t()))

    local interp = state:lerp(100, 200)
    example_print_log("lerp(100, 200) = " .. string.format("%.1f", interp))
    state:tick(1.0)
    example_print_log("complete = " .. tostring(state:isComplete()))
end
```

---

### `lurek.tween.parallel`

Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.

```lua
lurek.tween.parallel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenParallel](#ltweenparallel) | The new parallel group handle. |

**Example**

```lua
do
    local a = { x = 0 }
    local b = { y = 0 }
    local c = { rot = 0 }
    local par = lurek.tween.parallel()
    example_print_log("type = " .. par:type())

    par:tween(1.0, a, { x = 200 }, "linear")
    par:tween(1.0, b, { y = 150 }, "easeOutQuad")
    par:tween(1.0, c, { rot = 360 }, "easeInOutSine")
    par:start()

    example_print_log("active = " .. tostring(par:isActive()))
    lurek.tween.update(0.5)
    example_print_log("midpoint: x=" .. a.x .. " y=" .. string.format("%.0f", b.y) .. " rot=" .. c.rot)
    lurek.tween.update(0.5)
    example_print_log("done: x=" .. a.x .. " y=" .. b.y .. " rot=" .. c.rot)
end
```

---

### `lurek.tween.registerEasing`

Registers a custom easing function by name. The function receives a progress value (0..1) and must return an eased value.

```lua
lurek.tween.registerEasing(name, f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for the custom easing. |
| `f` | function | Easing function `f(t) -> number` where t is 0..1. |

**Example**

```lua
do
    lurek.tween.registerEasing("bounce3", function(t)
        return 1 - math.abs(math.cos(t * math.pi * 3)) * (1 - t)
    end)

    local names = lurek.tween.getEasingNames()
    local obj = { v = 0 }
    example_print_log("available easings: " .. #names)
    lurek.tween.tween(1.0, obj, { v = 1 }, "bounce3")
    lurek.tween.update(0.5)
    example_print_log("custom easing at 0.5: " .. string.format("%.3f", obj.v))
end
```

---

### `lurek.tween.sequence`

Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.

```lua
lurek.tween.sequence()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | The new sequence handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local seq = lurek.tween.sequence()
    example_print_log("type = " .. seq:type())

    seq:tween(0.5, obj, { x = 100 }, "easeOutQuad")
    seq:tween(0.5, obj, { y = 100 }, "easeInQuad")
    seq:start()

    example_print_log("active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    example_print_log("after step 1: x=" .. obj.x .. " y=" .. obj.y)
    lurek.tween.update(0.5)
    example_print_log("after step 2: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.spring`

Creates a spring-physics animation that smoothly drives table fields toward target values with bounce and settle behavior.

```lua
lurek.tween.spring(target, fields, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | table | The table whose fields will be animated by the spring. |
| `fields` | table | Key-value pairs mapping field names to their spring target values. |
| `opts?` | table | Optional settings: `stiffness` (default 100), `damping` (default 10), `precision` (default 0.001). |

**Returns**

| Type | Description |
|------|-------------|
| [LSpring](#lspring) | The active spring handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local spring = lurek.tween.spring(obj, { x = 100, y = 50 }, {
        stiffness = 200,
        damping = 15,
        precision = 0.01,
    })

    example_print_log("type = " .. spring:type())
    example_print_log("active = " .. tostring(spring:isActive()))
    for i = 1, 10 do spring:update(1 / 60) end
    example_print_log("after 10 frames: x=" .. string.format("%.1f", obj.x) .. " y=" .. string.format("%.1f", obj.y))
    example_print_log("settled = " .. tostring(spring:isSettled()))
end
```

---

### `lurek.tween.to`

Creates and starts a property tween with a different parameter order: target first, then fields, duration, easing.

```lua
lurek.tween.to(target, fields, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | table | The table whose fields will be animated. |
| `fields` | table | Key-value pairs mapping field names to their target end values. |
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The active tween handle. |

**Example**

```lua
do
    local bossBar = { width = 24, alpha = 0.2 }
    local reveal = lurek.tween.to(bossBar, { width = 220, alpha = 1.0 }, 0.8, "easeOutCubic")
    lurek.log.info("boss bar fields=" .. table.concat(reveal:getFields(), ", "))
    lurek.tween.update(0.4)
    lurek.log.info("boss bar width=" .. string.format("%.1f", bossBar.width))
    lurek.tween.update(0.4)
    lurek.log.info("boss bar remaining=" .. string.format("%.2f", reveal:getRemaining()))
end
```

---

### `lurek.tween.tween`

Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.

```lua
lurek.tween.tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds for the tween. |
| `target` | table | The table whose fields will be animated. |
| `fields` | table | Key-value pairs mapping field names to their target end values. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The active tween handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    example_print_log("type = " .. tw:type())
    lurek.tween.update(0.5)
    example_print_log("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.tweenChain`

Creates a sequence from a table of step descriptors. Each step is a table with `duration`, `target`, `fields`, optional `easing`, optional `callback`, or a `delay` key for pauses.

```lua
lurek.tween.tweenChain(steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | table | Array of step tables describing the chain. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | The active sequence handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local chain = lurek.tween.tweenChain({
        { duration = 0.5, target = obj, fields = { x = 100 }, easing = "easeOutQuad" },
        { duration = 0.5, target = obj, fields = { y = 100 }, easing = "easeInQuad" },
    })

    example_print_log("chain active = " .. tostring(chain:isActive()))
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
    example_print_log("chain result: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.tweenColor`

Creates and starts a color tween that smoothly interpolates r, g, b, and/or a fields on the target table.

```lua
lurek.tween.tweenColor(duration, target, color, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds. |
| `target` | table | The table containing color fields (`r`, `g`, `b`, `a`). |
| `color` | table | Target color values as `{r=, g=, b=, a=}`. Only present keys are tweened. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The active tween handle. |

**Example**

```lua
do
    local color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
    local tw = lurek.tween.tweenColor(2.0, color, { r = 0.0, g = 0.0, b = 1.0 }, "linear")

    lurek.tween.update(1.0)
    example_print_log("midpoint: r=" .. string.format("%.2f", color.r) .. " g=" .. string.format("%.2f", color.g) .. " b=" .. string.format("%.2f", color.b))
    lurek.tween.update(1.0)
    example_print_log("end: r=" .. color.r .. " b=" .. color.b)
end
```

---

### `lurek.tween.update`

Advances all active tweens, sequences, parallels, and springs by the given delta time. Call once per frame.

```lua
lurek.tween.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since the last frame. |

**Example**

```lua
do
    local camera = { x = -240, y = 96 }
    local focus = { x = 0, y = 64 }
    local pan = lurek.tween.to(camera, focus, 0.6, "easeOutQuad")
    lurek.tween.update(0.3)
    lurek.log.info("camera midpoint x=" .. string.format("%.1f", camera.x) .. " y=" .. string.format("%.1f", camera.y))
    lurek.tween.update(0.3)
    lurek.log.info("camera settled active=" .. tostring(pan:isActive()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.tween.delay` param `cb?` (`function`): Optional callback fired when the delay completes.
- `lurek.tween.registerEasing` param `f` (`function`): Easing function `f(t) -> number` where t is 0..1.

## Enums

*No module-specific enums documented.*

## Types

- [LSpring](#lspring)
- [LTween](#ltween)
- [LTweenChain](#ltweenchain)
- [LTweenParallel](#ltweenparallel)
- [LTweenSequence](#ltweensequence)
- [LTweenState](#ltweenstate)

## LSpring

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpring:cancel`

Cancels this spring animation and cleans up the on-settle callback if one was registered.

```lua
LSpring:cancel()
```

**Example**

```lua
do
    local obj = { val = 0 }
    local spring = lurek.tween.spring(obj, { val = 100 })
    spring:update(1 / 60)
    spring:cancel()
    example_print_log("active after cancel = " .. tostring(spring:isActive()))
end
```

---

#### `LSpring:getPosition`

Returns the current position of the given spring axis, or `nil` if the axis does not exist.

```lua
LSpring:getPosition(field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | string | Name of the axis to query. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Current position value, or nil when the axis does not exist. |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:update(1 / 10)

    local pos = spring:getPosition("size")
    example_print_log("size = " .. string.format("%.1f", obj.size))
    example_print_log("getPosition = " .. tostring(pos))
end
```

---

#### `LSpring:isActive`

Returns whether this spring is still actively animating.

```lua
LSpring:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if active. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    example_print_log("spring active:", active, "settled:", settled)
end
```

---

#### `LSpring:isSettled`

Returns whether all spring axes have reached their targets within the precision threshold.

```lua
LSpring:isSettled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the spring has settled. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    example_print_log("spring active:", active, "settled:", settled)
end
```

---

#### `LSpring:setDamping`

Sets the spring damping for all axes. Higher values reduce oscillation and overshoot.

```lua
LSpring:setDamping(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Damping coefficient (default 10). |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setDamping(20)
    spring:update(1 / 10)
    example_print_log("size after damping = " .. string.format("%.1f", obj.size))
    example_print_log("settled = " .. tostring(spring:isSettled()))
end
```

---

#### `LSpring:setStiffness`

Sets the spring stiffness for all axes. Higher values make the spring snap faster.

```lua
LSpring:setStiffness(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Stiffness coefficient (default 100). |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:update(1 / 10)
    example_print_log("size after stronger spring = " .. string.format("%.1f", obj.size))
    example_print_log("position = " .. tostring(spring:getPosition("size")))
end
```

---

#### `LSpring:setTarget`

Changes the spring target values for one or more axes. Re-activates the spring if it was settled.

```lua
LSpring:setTarget(fields)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fields` | table | Key-value pairs mapping axis names to new target values. |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:setDamping(20)

    for i = 1, 30 do
        spring:update(1 / 60)
    end
    example_print_log("size = " .. string.format("%.1f", obj.size))

    spring:setTarget({ size = 0 })
    for i = 1, 60 do
        spring:update(1 / 60)
    end

    local pos = spring:getPosition("size")
    example_print_log("retargeted size = " .. string.format("%.1f", obj.size))
    example_print_log("getPosition = " .. tostring(pos))
end
```

---

#### `LSpring:type`

Returns the type name of this object.

```lua
LSpring:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSpring](#lspring)"`. |

**Example**

```lua
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    example_print_log("spring type:", t, "typeOf:", ok)
end
```

---

#### `LSpring:typeOf`

Checks whether this object matches the given type name.

```lua
LSpring:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against (`"[LSpring](#lspring)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches. |

**Example**

```lua
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    example_print_log("spring type:", t, "typeOf:", ok)
end
```

---

#### `LSpring:update`

Manually advances this spring by the given delta time and writes updated positions to the target table. Returns `true` if still animating, `false` if settled.

```lua
LSpring:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the spring is still moving, `false` if settled. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    local still_active = sp:update(0.016)
    example_print_log("spring x:", obj.x)
    example_print_log("spring still active:", still_active)
end
```

---

## LTween

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTween:addValue`

Adds a value track to this tween. This method is available to Lua scripts.

```lua
LTween:addValue(start, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | Start value. |
| `target` | number | Target value. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the new value track. |

---

#### `LTween:await`

Yields the current coroutine until this tween completes or is cancelled. Must be called from inside a coroutine.

```lua
LTween:await()
```

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local co = coroutine.create(function()
        tw:await()
        example_print_log("await resumed at x=" .. target.x)
    end)

    coroutine.resume(co)
    lurek.tween.update(1.0)
    example_print_log("coroutine status = " .. coroutine.status(co))
end
```

---

#### `LTween:cancel`

Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it.

```lua
LTween:cancel()
```

**Example**

```lua
do
    local obj = { w = 100 }
    local tw = lurek.tween.tween(1.0, obj, { w = 200 })

    lurek.tween.update(0.3)
    example_print_log("before cancel: w=" .. obj.w)
    tw:cancel()
    example_print_log("active after cancel = " .. tostring(tw:isActive()))
    lurek.tween.update(1.0)
    example_print_log("after update: w=" .. obj.w)
end
```

---

#### `LTween:getAllValues`

Returns all current tween values. This method is available to Lua scripts.

```lua
LTween:getAllValues()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric tween values. |

---

#### `LTween:getClock`

Returns this tween clock time. This method is available to Lua scripts.

```lua
LTween:getClock()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time in seconds. |

---

#### `LTween:getDuration`

Returns this tween duration. This method is available to Lua scripts.

```lua
LTween:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local popup = { x = -64.0, alpha = 0.0 }
    local tw = lurek.tween.to(popup, { x = 16.0, alpha = 1.0 }, 1.0, "linear")
    lurek.log.info("popup duration=" .. string.format("%.2f", tw:getDuration()))
    lurek.tween.update(0.25)
    lurek.log.info("popup remaining=" .. string.format("%.2f", tw:getRemaining()))
    lurek.log.info("popup elapsed=" .. string.format("%.2f", tw:getElapsed()))
    lurek.log.info("popup alpha=" .. string.format("%.2f", popup.alpha))
end
```

---

#### `LTween:getEasingName`

Returns this tween easing function name.

```lua
LTween:getEasingName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Easing function name. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local ok, easing = pcall(function()
        return tw:getEasingName()
    end)
    example_print_log("easing=" .. tostring(ok and easing or "unavailable"))
    example_print_log("typeOf=" .. tostring(tw:typeOf("LTween")))
end
```

---

#### `LTween:getElapsed`

Returns the number of seconds that have elapsed since the tween started.

```lua
LTween:getElapsed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Elapsed time in seconds. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    example_print_log("elapsed=" .. tw:getElapsed())
    example_print_log("x=" .. target.x)
end
```

---

#### `LTween:getFields`

Returns an array of field names being tweened on the target table.

```lua
LTween:getFields()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Field name strings. |

**Example**

```lua
do
    local panel = { alpha = 0.0, x = -320, y = 24 }
    local tw = lurek.tween.tween(0.5, panel, { alpha = 1.0, x = 16, y = 40 })
    local fields = tw:getFields()
    lurek.log.info("panel fields=" .. table.concat(fields, ", "))
    lurek.tween.update(0.25)
    lurek.log.info("panel midpoint x=" .. string.format("%.1f", panel.x))
    lurek.tween.update(0.25)
    lurek.log.info("panel alpha=" .. string.format("%.2f", panel.alpha))
end
```

---

#### `LTween:getProgress`

Returns the eased progress of this tween as a value from 0.0 to 1.0.

```lua
LTween:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Eased progress ratio. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.5)
    example_print_log("progress=" .. tw:getProgress())
    example_print_log("x=" .. target.x)
end
```

---

#### `LTween:getRemaining`

Returns the number of seconds remaining until this tween completes.

```lua
LTween:getRemaining()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Remaining time in seconds. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    example_print_log("remaining=" .. tw:getRemaining())
    example_print_log("active=" .. tostring(tw:isActive()))
end
```

---

#### `LTween:getTime`

Returns this tween clock time. This method is available to Lua scripts.

```lua
LTween:getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time in seconds. |

---

#### `LTween:getValue`

Returns one tween value by one-based index or all values when no index is provided.

```lua
LTween:getValue(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | number | One-based value index; omit to return all values as a table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tween value at the given index, or a table of all values when index is omitted. |

---

#### `LTween:getValueCount`

Returns the number of values animated by this tween.

```lua
LTween:getValueCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tween value count. |

---

#### `LTween:isActive`

Returns whether this tween is still running (not cancelled or completed).

```lua
LTween:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the tween is active. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    example_print_log("active before = " .. tostring(tw:isActive()))
    tw:cancel()
    example_print_log("active after = " .. tostring(tw:isActive()))
end
```

---

#### `LTween:isComplete`

Returns whether this tween is complete.

```lua
LTween:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when complete. |

---

#### `LTween:onCancel`

Sets a callback to fire when the tween is cancelled. Returns the tween for chaining.

```lua
LTween:onCancel(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired when the tween is cancelled. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

**Example**

```lua
do
    local shutter = { y = 0 }
    local cancelled = false
    local tw = lurek.tween.tween(1.0, shutter, { y = -180 })
    tw:onCancel(function() cancelled = true end)
    lurek.tween.update(0.2)
    tw:cancel()
    lurek.log.info("shutter cancelled=" .. tostring(cancelled))
    lurek.log.info("shutter active=" .. tostring(tw:isActive()))
end
```

---

#### `LTween:onComplete`

Sets a callback to fire when the tween completes. Returns the tween for chaining.

```lua
LTween:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired when the tween finishes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

**Example**

```lua
do
    local chest = { scale = 0.8, glow = 0.0 }
    local tw = lurek.tween.tween(0.6, chest, { scale = 1.2, glow = 1.0 })
    tw:onComplete(function() lurek.log.info("chest reveal complete scale=" .. string.format("%.2f", chest.scale)) end)
    lurek.tween.update(0.3)
    lurek.log.info("chest reveal active=" .. tostring(tw:isActive()))
    lurek.tween.update(0.3)
    lurek.log.info("chest glow=" .. string.format("%.2f", chest.glow))
end
```

---

#### `LTween:onUpdate`

Sets a callback to fire every frame while the tween is active. Returns the tween for chaining.

```lua
LTween:onUpdate(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired each frame with the current progress `t` (0..1). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

**Example**

```lua
do
    local waypoint = { x = 0, y = 0 }
    local lastT = 0.0
    local tw = lurek.tween.tween(0.5, waypoint, { x = 96, y = 32 })
    tw:onUpdate(function(t) lastT = t end)
    lurek.tween.update(0.25)
    lurek.log.info("patrol progress=" .. string.format("%.2f", lastT))
    lurek.tween.update(0.25)
    lurek.log.info("patrol x=" .. string.format("%.1f", waypoint.x))
end
```

---

#### `LTween:pause`

Pauses this tween so it stops advancing until resumed.

```lua
LTween:pause()
```

**Example**

```lua
do
    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    example_print_log("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    example_print_log("while paused: " .. obj.rotation)
end
```

---

#### `LTween:relative`

Chainable version of `setRelative`. Returns the tween for fluent API usage.

```lua
LTween:relative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` for relative mode, `false` for absolute. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

**Example**

```lua
do
    local player = { x = 48, y = 96 }
    local tw = lurek.tween.tween(0.4, player, { x = 32, y = -16 }):relative(true)
    lurek.tween.update(0.2)
    lurek.log.info("dash midpoint x=" .. string.format("%.1f", player.x) .. " y=" .. string.format("%.1f", player.y))
    lurek.tween.update(0.2)
    lurek.log.info("dash end x=" .. string.format("%.1f", player.x) .. " y=" .. string.format("%.1f", player.y))
end
```

---

#### `LTween:reset`

Resets the tween clock to the beginning.

```lua
LTween:reset()
```

---

#### `LTween:resume`

Resumes a paused tween so it continues advancing.

```lua
LTween:resume()
```

**Example**

```lua
do
    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    example_print_log("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    example_print_log("while paused: " .. obj.rotation)

    tw:resume()
    lurek.tween.update(0.5)
    example_print_log("after resume: " .. obj.rotation)
end
```

---

#### `LTween:set`

Sets this tween clock time. This method is available to Lua scripts.

```lua
LTween:set(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | New time in seconds. |

---

#### `LTween:setRelative`

Sets whether the tween end values are relative to the start values instead of absolute.

```lua
LTween:setRelative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` for relative mode, `false` for absolute. |

**Example**

```lua
do
    local target = { x = 10.0 }
    local tw = lurek.tween.to(target, { x = 5 }, 1.0, "linear")
    tw:setRelative(true)
    lurek.tween.update(1.0)
    example_print_log("relative x=" .. target.x)
    example_print_log("type=" .. tw:type())
end
```

---

#### `LTween:setRepeat`

Sets how many times the tween should repeat after the first play. Use -1 for infinite repeat.

```lua
LTween:setRepeat(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of additional repeats (0 = play once, -1 = infinite). |

**Example**

```lua
do
    local beacon = { alpha = 0.0 }
    local tw = lurek.tween.tween(0.2, beacon, { alpha = 1.0 })
    tw:setRepeat(2)
    lurek.tween.update(0.2)
    lurek.log.info("beacon pulse alpha=" .. string.format("%.2f", beacon.alpha))
    lurek.tween.update(0.2)
    lurek.log.info("beacon pulse active=" .. tostring(tw:isActive()))
end
```

---

#### `LTween:setTime`

Sets this tween clock time. This method is available to Lua scripts.

```lua
LTween:setTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | New time in seconds. |

---

#### `LTween:setYoyo`

Enables or disables yoyo mode, which reverses the tween direction on each repeat cycle.

```lua
LTween:setYoyo(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` to enable yoyo, `false` to disable. |

**Example**

```lua
do
    local prompt = { y = 0 }
    local tw = lurek.tween.tween(0.2, prompt, { y = -14 })
    tw:setRepeat(1)
    tw:setYoyo(true)
    lurek.tween.update(0.2)
    lurek.tween.update(0.2)
    lurek.log.info("jump prompt returned y=" .. string.format("%.1f", prompt.y))
end
```

---

#### `LTween:type`

Returns the Lua-visible type name for this tween handle.

```lua
LTween:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTween](#ltween)`. |

**Example**

```lua
do
    local cursor = { x = 0.0, alpha = 0.3 }
    local tw = lurek.tween.to(cursor, { x = 48.0, alpha = 1.0 }, 1.0, "linear")
    lurek.log.info("cursor tween type=" .. tw:type())
    lurek.log.info("cursor tween active=" .. tostring(tw:isActive()))
    lurek.tween.update(0.5)
    lurek.log.info("cursor tween progress=" .. string.format("%.2f", tw:getProgress()))
    lurek.log.info("cursor alpha=" .. string.format("%.2f", cursor.alpha))
end
```

---

#### `LTween:typeOf`

Returns whether this tween handle matches a supported type name.

```lua
LTween:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTween](#ltween)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local reticle = { scale = 0.6 }
    local tw = lurek.tween.to(reticle, { scale = 1.0 }, 1.0, "linear")
    lurek.log.info("reticle typeOf LTween=" .. tostring(tw:typeOf("LTween")))
    lurek.log.info("reticle typeOf Object=" .. tostring(tw:typeOf("Object")))
    lurek.tween.update(0.5)
    lurek.log.info("reticle type=" .. tw:type())
    lurek.log.info("reticle scale=" .. string.format("%.2f", reticle.scale))
end
```

---

#### `LTween:update`

Advances the tween clock and returns whether it is complete.

```lua
LTween:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tween is complete. |

---

## LTweenChain

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTweenChain:call`

Adds a fluent callback step that executes once at this point in the chain.

```lua
LTweenChain:call(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback to execute. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local called = false
    local chain = lurek.tween.newChain()
    chain:call(function() called = true end)
    chain:start()
    lurek.tween.update(0.01)
    example_print_log("called = " .. tostring(called))
end
```

---

#### `LTweenChain:clear`

Clears all fluent and legacy steps.

```lua
LTweenChain:clear()
```

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "windup" })
    chain:push({ from = 1.0, to = 0.4, duration = 0.1, label = "release" })
    lurek.log.info("camera shake steps before clear=" .. tostring(chain:len()))
    chain:clear()
    lurek.log.info("camera shake steps after clear=" .. tostring(chain:len()))
    lurek.log.info("camera shake cursor=" .. tostring(chain:cursor()))
end
```

---

#### `LTweenChain:cursor`

Returns one-based current legacy step index.

```lua
LTweenChain:cursor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Step index. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "charge" })
    chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "release" })
    lurek.log.info("beam cursor before tick=" .. tostring(chain:cursor()))
    chain:tick(0.12)
    lurek.log.info("beam cursor after tick=" .. tostring(chain:cursor()))
    lurek.log.info("beam value=" .. string.format("%.2f", chain:value()))
end
```

---

#### `LTweenChain:getIteration`

Returns current iteration number.

```lua
LTweenChain:getIteration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Iteration (0 before first start). |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("iteration = " .. tostring(chain:getIteration()))
end
```

---

#### `LTweenChain:getProgress`

Returns normalized fluent chain progress in range `[0, 1]`.

```lua
LTweenChain:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Progress ratio. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.2, "linear")
    chain:start()
    lurek.tween.update(0.1)
    example_print_log("progress = " .. tostring(chain:getProgress()))
end
```

---

#### `LTweenChain:isActive`

Returns whether fluent playback is active.

```lua
LTweenChain:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Active flag. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    example_print_log("isActive = " .. tostring(chain:isActive()))
end
```

---

#### `LTweenChain:isComplete`

Returns whether fluent playback reached final completion.

```lua
LTweenChain:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Completion flag. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.05, "linear")
    chain:start()
    lurek.tween.update(0.06)
    example_print_log("isComplete = " .. tostring(chain:isComplete()))
end
```

---

#### `LTweenChain:isFinished`

Returns whether legacy playback reached completion for the active pass.

```lua
LTweenChain:isFinished()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Finished flag. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 0.5, duration = 0.01, label = "flare_in" })
    chain:push({ from = 0.5, to = 0.0, duration = 0.01, label = "flare_out" })
    lurek.log.info("muzzle flash finished before=" .. tostring(chain:isFinished()))
    chain:tick(0.01)
    chain:tick(0.02)
    lurek.log.info("muzzle flash finished after=" .. tostring(chain:isFinished()))
end
```

---

#### `LTweenChain:isLooping`

Returns whether chain is in infinite loop mode.

```lua
LTweenChain:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Looping flag. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "radar_ping" })
    chain:setLooping(true)
    lurek.log.info("radar looping before tick=" .. tostring(chain:isLooping()))
    chain:tick(0.15)
    lurek.log.info("radar cursor=" .. tostring(chain:cursor()))
    lurek.log.info("radar looping after tick=" .. tostring(chain:isLooping()))
end
```

---

#### `LTweenChain:jumpTo`

Jumps legacy chain cursor to given one-based step.

```lua
LTweenChain:jumpTo(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | number | Step index (one-based). |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "a" })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1, label = "b" })
    chain:jumpTo(2)
    example_print_log("cursor after jump = " .. tostring(chain:cursor()))
end
```

---

#### `LTweenChain:len`

Returns legacy step count currently stored in this tween chain.

```lua
LTweenChain:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Step count. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "intro" })
    chain:push({ from = 1.0, to = 2.0, duration = 0.1, label = "hold" })
    chain:push({ from = 2.0, to = 0.0, duration = 0.1, label = "outro" })
    lurek.log.info("warning banner steps=" .. tostring(chain:len()))
    chain:tick(0.1)
    lurek.log.info("warning banner cursor=" .. tostring(chain:cursor()))
end
```

---

#### `LTweenChain:loop`

Sets fluent loop count where `0` means infinite looping behavior.

```lua
LTweenChain:loop(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of passes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 1 }, 0.01, "linear"):loop(2)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("iteration = " .. tostring(chain:getIteration()))
end
```

---

#### `LTweenChain:onComplete`

Sets callback fired after the final fluent pass fully completes.

```lua
LTweenChain:onComplete(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Completion callback. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local done = false
    local chain = lurek.tween.newChain()
    chain:wait(0.01):onComplete(function() done = true end)
    chain:start()
    lurek.tween.update(0.02)
    example_print_log("complete callback = " .. tostring(done))
end
```

---

#### `LTweenChain:onLoop`

Sets callback fired when entering the next fluent loop iteration.

```lua
LTweenChain:onLoop(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback receiving iteration number. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local loops = 0
    local chain = lurek.tween.newChain()
    chain:to({ x = 0 }, { x = 1 }, 0.01, "linear"):loop(2):onLoop(function() loops = loops + 1 end)
    chain:start()
    lurek.tween.update(0.03)
    example_print_log("loops = " .. tostring(loops))
end
```

---

#### `LTweenChain:pause`

Pauses fluent playback while preserving timeline progress and cursor state.

```lua
LTweenChain:pause()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    lurek.tween.update(0.05)
    chain:pause()
    example_print_log("progress after pause = " .. tostring(chain:getProgress()))
end
```

---

#### `LTweenChain:push`

Appends a legacy scalar step to the compatibility chain.

```lua
LTweenChain:push(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Step descriptor: `from`, `to`, `duration`, `easing?`, `label?`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based index of the new step. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    local fadeIn = chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "fade_in" })
    local fadeOut = chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "fade_out" })
    lurek.log.info("toast fade in index=" .. tostring(fadeIn))
    lurek.log.info("toast fade out index=" .. tostring(fadeOut))
    chain:tick(0.1)
    lurek.log.info("toast alpha=" .. string.format("%.2f", chain:value()))
end
```

---

#### `LTweenChain:reset`

Resets both fluent and legacy playback cursors.

```lua
LTweenChain:reset()
```

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0 })
    chain:tick(0.5)
    chain:reset()
    example_print_log("value after reset = " .. tostring(chain:value()))
end
```

---

#### `LTweenChain:resume`

Resumes fluent playback from the previously paused timeline position.

```lua
LTweenChain:resume()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:pause()
    chain:resume()
    example_print_log("active after resume = " .. tostring(chain:isActive()))
end
```

---

#### `LTweenChain:setLooping`

Enables/disables infinite loop compatibility mode.

```lua
LTweenChain:setLooping(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | boolean | Looping flag. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "alarm_on" })
    chain:setLooping(true)
    chain:tick(0.15)
    lurek.log.info("alarm looping=" .. tostring(chain:isLooping()))
    lurek.log.info("alarm value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("alarm cursor=" .. tostring(chain:cursor()))
end
```

---

#### `LTweenChain:start`

Starts fluent chain playback and registers this chain in the update queue.

```lua
LTweenChain:start()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    example_print_log("active = " .. tostring(chain:isActive()))
end
```

---

#### `LTweenChain:stop`

Stops fluent playback and leaves the chain ready for a later restart.

```lua
LTweenChain:stop()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.1, "linear")
    chain:start()
    chain:stop()
    example_print_log("active after stop = " .. tostring(chain:isActive()))
end
```

---

#### `LTweenChain:tick`

Advances the legacy scalar chain and returns completion events.

```lua
LTweenChain:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of event tables. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.1, label = "charge" })
    chain:push({ from = 1.0, to = 0.0, duration = 0.1, label = "cooldown" })
    local events = chain:tick(0.2)
    lurek.log.info("laser cue events=" .. tostring(#events))
    lurek.log.info("laser cue value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("laser cue finished=" .. tostring(chain:isFinished()))
end
```

---

#### `LTweenChain:to`

Adds a fluent tween step to this chain.

```lua
LTweenChain:to(target, fields, dur, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | table | Target table. |
| `fields` | table | Field-to-value map. |
| `dur` | number | Duration in seconds. |
| `easing?` | string | Easing name (default `linear`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local obj = { x = 0 }
    local chain = lurek.tween.newChain()
    chain:to(obj, { x = 10 }, 0.25, "linear")
    chain:start()
    lurek.tween.update(0.25)
    example_print_log("x = " .. tostring(obj.x))
end
```

---

#### `LTweenChain:type`

Returns the Lua-visible type name.

```lua
LTweenChain:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTweenChain](#ltweenchain)`. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "charge" })
    lurek.log.info("chain type=" .. tostring(chain:type()))
    lurek.log.info("chain typeOf LTweenChain=" .. tostring(chain:typeOf("LTweenChain")))
    chain:tick(0.1)
    lurek.log.info("chain value=" .. string.format("%.2f", chain:value()))
end
```

---

#### `LTweenChain:typeOf`

Returns whether this handle matches the given type name.

```lua
LTweenChain:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when matched. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 1.0, duration = 0.2, label = "shield_up" })
    lurek.log.info("shield typeOf LTweenChain=" .. tostring(chain:typeOf("LTweenChain")))
    lurek.log.info("shield typeOf Object=" .. tostring(chain:typeOf("Object")))
    chain:tick(0.1)
    lurek.log.info("shield type=" .. tostring(chain:type()))
end
```

---

#### `LTweenChain:value`

Returns current legacy scalar value.

```lua
LTweenChain:value()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current value. |

**Example**

```lua
do
    local chain = lurek.tween.newChain()
    chain:push({ from = 0.0, to = 5.0, duration = 1.0, label = "danger_fill" })
    chain:tick(0.5)
    lurek.log.info("danger meter value=" .. string.format("%.2f", chain:value()))
    lurek.log.info("danger meter cursor=" .. tostring(chain:cursor()))
    chain:tick(0.5)
    lurek.log.info("danger meter finished=" .. tostring(chain:isFinished()))
end
```

---

#### `LTweenChain:wait`

Adds a fluent delay step to the chain timeline and keeps fluent chaining enabled.

```lua
LTweenChain:wait(seconds, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Delay duration. |
| `callback?` | function | Optional callback fired after wait. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenChain](#ltweenchain) | This chain. |

**Example**

```lua
do
    local fired = false
    local chain = lurek.tween.newChain()
    chain:wait(0.1, function() fired = true end)
    chain:start()
    lurek.tween.update(0.1)
    example_print_log("wait fired = " .. tostring(fired))
end
```

---

## LTweenParallel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTweenParallel:add`

Adds an existing tween handle to this parallel group. The tween becomes owned by the group.

```lua
LTweenParallel:add(tw_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw_ud` | [LTween](#ltween) | The tween handle returned by `lurek.tween.tween()` to add to this group. |

**Example**

```lua
do
    local obj1 = { alpha = 1 }
    local obj2 = { scale = 1 }
    local tw1 = lurek.tween.tween(0.8, obj1, { alpha = 0 })
    local tw2 = lurek.tween.tween(0.8, obj2, { scale = 3 })
    local par = lurek.tween.parallel()

    par:add(tw1)
    par:add(tw2)
    par:onComplete(function() example_print_log("  parallel group done") end)
    par:start()

    lurek.tween.update(0.8)
    example_print_log("alpha=" .. obj1.alpha .. " scale=" .. obj2.scale)
end
```

---

#### `LTweenParallel:cancel`

Cancels all tweens in this parallel group immediately.

```lua
LTweenParallel:cancel()
```

**Example**

```lua
do
    local a = { x = 0 }
    local b = { y = 0 }
    local par = lurek.tween.parallel()
    par:tween(2.0, a, { x = 100 })
    par:tween(2.0, b, { y = 100 })
    par:start()

    lurek.tween.update(1.0)
    par:cancel()
    example_print_log("cancelled: active=" .. tostring(par:isActive()))
    example_print_log("x=" .. a.x .. " y=" .. b.y)
end
```

---

#### `LTweenParallel:isActive`

Returns whether this parallel group is still running.

```lua
LTweenParallel:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if any tween in the group is still active. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

#### `LTweenParallel:onComplete`

Sets a callback to fire when all tweens in this parallel group have finished. Returns the group for chaining.

```lua
LTweenParallel:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Function to call when all tweens in the group complete. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenParallel](#ltweenparallel) | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

#### `LTweenParallel:start`

Starts all tweens in this parallel group simultaneously.

```lua
LTweenParallel:start()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenParallel](#ltweenparallel) | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

#### `LTweenParallel:tween`

Creates and adds a new tween step directly to this parallel group.

```lua
LTweenParallel:tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds. |
| `target` | table | The table whose fields will be animated. |
| `fields` | table | Key-value pairs mapping field names to target end values. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenParallel](#ltweenparallel) | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

#### `LTweenParallel:type`

Returns the type name of this object.

```lua
LTweenParallel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTweenParallel](#ltweenparallel)"`. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

#### `LTweenParallel:typeOf`

Checks whether this object matches the given type name.

```lua
LTweenParallel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against (`"[LTweenParallel](#ltweenparallel)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() example_print_log("parallel_done") end) ; example_print_log("par_active=" .. tostring(par:isActive()))
    example_print_log("par_type=" .. par:type()) ; example_print_log("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

## LTweenSequence

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTweenSequence:await`

Yields the current coroutine until this sequence completes or is cancelled. Must be called from inside a coroutine.

```lua
LTweenSequence:await()
```

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    local co = coroutine.create(function()
        seq:await()
        example_print_log("sequence await resumed at x=" .. obj.x)
    end)

    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    coroutine.resume(co)
    lurek.tween.update(0.5)
    example_print_log("coroutine status = " .. coroutine.status(co))
end
```

---

#### `LTweenSequence:callback`

Appends a callback step to this sequence that fires when reached during playback.

```lua
LTweenSequence:callback(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Function called when this step is reached during playback. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | This sequence for chaining. |

**Example**

```lua
do
    local obj = { scale = 1 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { scale = 2 })
    seq:callback(function() example_print_log("  halfway callback! scale=" .. obj.scale) end)
    seq:tween(0.5, obj, { scale = 1 })
    seq:onComplete(function() example_print_log("  sequence complete") end)
    seq:start()

    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end
```

---

#### `LTweenSequence:cancel`

Cancels this sequence immediately and resumes any coroutines waiting on it.

```lua
LTweenSequence:cancel()
```

**Example**

```lua
do
    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    example_print_log("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    example_print_log("active after cancel = " .. tostring(seq:isActive()))
end
```

---

#### `LTweenSequence:delay`

Appends a delay step to this sequence. Optionally fires a callback when the delay elapses.

```lua
LTweenSequence:delay(seconds, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Duration to wait in seconds. |
| `cb?` | function | Optional callback fired when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | This sequence for chaining. |

**Example**

```lua
do
    local obj = { alpha = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.3, obj, { alpha = 1 })
    seq:delay(0.5)
    seq:tween(0.3, obj, { alpha = 0 })
    seq:start()

    lurek.tween.update(0.3)
    example_print_log("fade in done: alpha=" .. obj.alpha)
    lurek.tween.update(0.5)
    example_print_log("after delay: alpha=" .. obj.alpha)
    lurek.tween.update(0.3)
    example_print_log("fade out done: alpha=" .. obj.alpha)
end
```

---

#### `LTweenSequence:getProgress`

Returns the overall progress ratio of this sequence from 0.0 to 1.0.

```lua
LTweenSequence:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Progress ratio. |

**Example**

```lua
do
    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    example_print_log("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    example_print_log("active after cancel = " .. tostring(seq:isActive()))
end
```

---

#### `LTweenSequence:isActive`

Returns whether this sequence is still running.

```lua
LTweenSequence:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the sequence is active. |

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    example_print_log("seq active before = " .. tostring(seq:isActive()))
    seq:start()
    example_print_log("seq active after = " .. tostring(seq:isActive()))
end
```

---

#### `LTweenSequence:onComplete`

Sets a callback to fire when the sequence finishes all steps. Returns the sequence for chaining.

```lua
LTweenSequence:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Function to call when the sequence completes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:onComplete(function() example_print_log("seq_done") end)
    seq:start()
    lurek.tween.update(0.5)
    example_print_log("seq active = " .. tostring(seq:isActive()))
end
```

---

#### `LTweenSequence:start`

Starts playback of this sequence from the first step.

```lua
LTweenSequence:start()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    example_print_log("seq active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    example_print_log("seq x = " .. obj.x)
end
```

---

#### `LTweenSequence:tween`

Appends a tween step to this sequence that animates numeric fields on the target table.

```lua
LTweenSequence:tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds. |
| `target` | table | The table whose fields will be animated. |
| `fields` | table | Key-value pairs mapping field names to target end values. |
| `easing?` | string | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTweenSequence](#ltweensequence) | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()
    lurek.tween.update(0.5)
    example_print_log("seq x=" .. obj.x)
    example_print_log("seq active = " .. tostring(seq:isActive()))
end
```

---

#### `LTweenSequence:type`

Returns the type name of this object.

```lua
LTweenSequence:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTweenSequence](#ltweensequence)"`. |

**Example**

```lua
do
    local panel = { alpha = 0.0, x = -100.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.2, panel, { alpha = 1.0, x = 0.0 }, "linear")
    seq:delay(0.1)
    lurek.log.info("sequence type=" .. seq:type())
    lurek.log.info("sequence typeOf=" .. tostring(seq:typeOf("LTweenSequence")))
    seq:start()
    lurek.tween.update(0.2)
    lurek.log.info("sequence panel x=" .. string.format("%.1f", panel.x))
end
```

---

#### `LTweenSequence:typeOf`

Checks whether this object matches the given type name.

```lua
LTweenSequence:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against (`"[LTweenSequence](#ltweensequence)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches. |

**Example**

```lua
do
    local alert = { alpha = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.2, alert, { alpha = 1.0 }, "linear")
    lurek.log.info("alert typeOf LTweenSequence=" .. tostring(seq:typeOf("LTweenSequence")))
    lurek.log.info("alert typeOf Object=" .. tostring(seq:typeOf("Object")))
    seq:start()
    lurek.tween.update(0.2)
    lurek.log.info("alert sequence type=" .. seq:type())
    lurek.log.info("alert alpha=" .. string.format("%.2f", alert.alpha))
end
```

---

## LTweenState

### Type Fields

| Name | Type | Description |
|------|------|-------------|
| `paused` | any |  |

### Type Methods

#### `LTweenState:isComplete`

Returns whether this tween state has finished its full duration.

```lua
LTweenState:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the tween has reached its end. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

#### `LTweenState:lerp`

Linearly interpolates between two values using the current eased progress.

```lua
LTweenState:lerp(start, finish)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | Value at progress 0. |
| `finish` | number | Value at progress 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Interpolated value. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

#### `LTweenState:reset`

Resets the tween state to the beginning so it can be replayed.

```lua
LTweenState:reset()
```

**Example**

```lua
do
    local state = lurek.tween.newState(1.0)
    state:tick(1.0)
    example_print_log("done = " .. tostring(state:isComplete()))
    state:reset()
    example_print_log("after reset, done = " .. tostring(state:isComplete()))
    example_print_log("t = " .. state:t())
end
```

---

#### `LTweenState:t`

Returns the raw (un-eased) progress value from 0.0 to 1.0.

```lua
LTweenState:t()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Linear progress ratio. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

#### `LTweenState:tick`

Advances the tween state by the given delta time and returns the eased interpolation value (0..1).

```lua
LTweenState:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds to advance. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value between 0 and 1. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

#### `LTweenState:type`

Returns the type name of this object.

```lua
LTweenState:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTweenState](#ltweenstate)"`. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

#### `LTweenState:typeOf`

Checks whether this object matches the given type name.

```lua
LTweenState:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against (`"[LTweenState](#ltweenstate)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    example_print_log("t=" .. state:t())
    example_print_log("lerp=" .. state:lerp(0, 100))
    example_print_log("complete=" .. tostring(state:isComplete()))
    example_print_log("type=" .. state:type())
    example_print_log("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---
