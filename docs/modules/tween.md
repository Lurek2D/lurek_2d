# Tween

- The `tween` module is a versatile Feature Systems tier component responsible for smooth value interpolation, easing, and spring-physics animations.

It provides a robust engine for animating numeric properties over time, making it ideal for UI transitions, camera movements, and gameplay juice. At its core, `LuaTween` interpolates a single numeric property (or multiple numeric fields on a single Lua table) from a start value to a target value over a specified duration. Developers can choose from over 30 built-in easing curves—including linear, quadratic, cubic, elastic, bounce, and back—or register custom easing functions to achieve the exact feel required. Tweens support full lifecycle callbacks (`onUpdate`, `onComplete`, `onCancel`) and can be configured to repeat infinitely, yoyo (reverse direction on repeat), or operate in relative mode where targets act as offsets.

To handle complex animation choreography, the module provides powerful combinators. `LuaTweenSequence` enables the chaining of multiple tweens, delays, and callbacks into an ordered execution pipeline, where each step seamlessly transitions to the next while carrying over leftover frame delta time. Conversely, `LuaTweenParallel` groups multiple tweens together, executing them simultaneously and completing only when the longest-running child finishes. For a more organic, physics-driven feel, `SpringSystem` offers damped spring interpolation with configurable stiffness and damping. This eliminates fixed durations in favor of natural settling dynamics, which is particularly effective for responsive UI elements or following camera logic.

The entire system is driven by a centralized `TweenEngine` that efficiently updates all active tweens, sequences, parallels, and springs every frame. The module is fully integrated with Lua coroutines via the `await()` method, allowing developers to yield execution until an animation completes, drastically simplifying sequential scripting without callback hell. Exposed via the comprehensive `lurek.tween.*` Lua API, this module is an essential tool for bringing fluid, polished motion to Lurek2D games.

## Functions

### `lurek.tween.cancelAll`

Immediately cancels all active tweens, sequences, parallels, and springs managed by the tween engine.

```lua
-- signature
lurek.tween.cancelAll()
```

**Example**

```lua
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end
```

---

### `lurek.tween.delay`

Creates a one-shot delay. After the specified seconds elapse, the optional callback is invoked.

```lua
-- signature
lurek.tween.delay(seconds, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Duration to wait in seconds. |
| `cb?` | `function` | Optional callback fired when the delay completes. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | A sequence handle representing the delay. |

**Example**

```lua
do
    local d = lurek.tween.delay(1.5, function() print("  delay complete") end)
    print("delay active = " .. tostring(d:isActive()))
    lurek.tween.update(1.5)
    print("delay done = " .. tostring(not d:isActive()))
end
```

---

### `lurek.tween.getActiveCount`

Returns the total number of currently active tweens, sequences, and parallels.

```lua
-- signature
lurek.tween.getActiveCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of active tween objects. |

**Example**

```lua
do
    local a = { x = 0 }
    local b = { y = 0 }
    lurek.tween.tween(1.0, a, { x = 10 })
    lurek.tween.tween(2.0, b, { y = 20 })
    print("active count = " .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("after cancelAll = " .. lurek.tween.getActiveCount())
end
```

---

### `lurek.tween.getEasingNames`

Returns an array of all available easing function names, including both built-in and custom-registered easings.

```lua
-- signature
lurek.tween.getEasingNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Easing name strings. |

**Example**

```lua
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())
    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end
```

---

### `lurek.tween.newState`

Creates a standalone tween state for manual interpolation. Useful when you need eased progress without automatic property updates.

```lua
-- signature
lurek.tween.newState(duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenState` | The new tween state handle. |

**Example**

```lua
do
    local state = lurek.tween.newState(2.0, "easeInOutCubic")
    print("type = " .. state:type())
    print("complete = " .. tostring(state:isComplete()))

    state:tick(1.0)
    local val = state:lerp(0.0, 1.0)
    print("at 1.0s: eased value = " .. string.format("%.3f", val))
    print("raw t = " .. string.format("%.3f", state:t()))

    local interp = state:lerp(100, 200)
    print("lerp(100, 200) = " .. string.format("%.1f", interp))
    state:tick(1.0)
    print("complete = " .. tostring(state:isComplete()))
end
```

---

### `lurek.tween.parallel`

Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.

```lua
-- signature
lurek.tween.parallel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTweenParallel` | The new parallel group handle. |

**Example**

```lua
do
    local a = { x = 0 }
    local b = { y = 0 }
    local c = { rot = 0 }
    local par = lurek.tween.parallel()
    print("type = " .. par:type())

    par:tween(1.0, a, { x = 200 }, "linear")
    par:tween(1.0, b, { y = 150 }, "easeOutQuad")
    par:tween(1.0, c, { rot = 360 }, "easeInOutSine")
    par:start()

    print("active = " .. tostring(par:isActive()))
    lurek.tween.update(0.5)
    print("midpoint: x=" .. a.x .. " y=" .. string.format("%.0f", b.y) .. " rot=" .. c.rot)
    lurek.tween.update(0.5)
    print("done: x=" .. a.x .. " y=" .. b.y .. " rot=" .. c.rot)
end
```

---

### `lurek.tween.registerEasing`

Registers a custom easing function by name. The function receives a progress value (0..1) and must return an eased value.

```lua
-- signature
lurek.tween.registerEasing(name, f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for the custom easing. |
| `f` | `function` | Easing function `f(t) -> number` where t is 0..1. |

**Example**

```lua
do
    lurek.tween.registerEasing("bounce3", function(t)
        return 1 - math.abs(math.cos(t * math.pi * 3)) * (1 - t)
    end)

    local names = lurek.tween.getEasingNames()
    local obj = { v = 0 }
    print("available easings: " .. #names)
    lurek.tween.tween(1.0, obj, { v = 1 }, "bounce3")
    lurek.tween.update(0.5)
    print("custom easing at 0.5: " .. string.format("%.3f", obj.v))
end
```

---

### `lurek.tween.sequence`

Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.

```lua
-- signature
lurek.tween.sequence()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | The new sequence handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local seq = lurek.tween.sequence()
    print("type = " .. seq:type())

    seq:tween(0.5, obj, { x = 100 }, "easeOutQuad")
    seq:tween(0.5, obj, { y = 100 }, "easeInQuad")
    seq:start()

    print("active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    print("after step 1: x=" .. obj.x .. " y=" .. obj.y)
    lurek.tween.update(0.5)
    print("after step 2: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.spring`

Creates a spring-physics animation that smoothly drives table fields toward target values with bounce and settle behavior.

```lua
-- signature
lurek.tween.spring(target, fields, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `table` | The table whose fields will be animated by the spring. |
| `fields` | `table` | Key-value pairs mapping field names to their spring target values. |
| `opts?` | `table` | Optional settings: `stiffness` (default 100), `damping` (default 10), `precision` (default 0.001). |

**Returns**

| Type | Description |
|------|-------------|
| `LSpring` | The active spring handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local spring = lurek.tween.spring(obj, { x = 100, y = 50 }, {
        stiffness = 200,
        damping = 15,
        precision = 0.01,
    })

    print("type = " .. spring:type())
    print("active = " .. tostring(spring:isActive()))
    for i = 1, 10 do spring:update(1 / 60) end
    print("after 10 frames: x=" .. string.format("%.1f", obj.x) .. " y=" .. string.format("%.1f", obj.y))
    print("settled = " .. tostring(spring:isSettled()))
end
```

---

### `lurek.tween.to`

Creates and starts a property tween with a different parameter order: target first, then fields, duration, easing.

```lua
-- signature
lurek.tween.to(target, fields, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `table` | The table whose fields will be animated. |
| `fields` | `table` | Key-value pairs mapping field names to their target end values. |
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The active tween handle. |

**Example**

```lua
do
    local pos = { x = 100, y = 200 }
    lurek.tween.to(pos, { x = 0, y = 0 }, 0.5, "easeOutBounce")
    lurek.tween.update(0.5)
    print("moved to: x=" .. pos.x .. " y=" .. pos.y)
end
```

---

### `lurek.tween.tween`

Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.

```lua
-- signature
lurek.tween.tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | `number` | Duration in seconds for the tween. |
| `target` | `table` | The table whose fields will be animated. |
| `fields` | `table` | Key-value pairs mapping field names to their target end values. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The active tween handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local tw = lurek.tween.tween(1.0, obj, { x = 100, y = 50 })
    print("type = " .. tw:type())
    lurek.tween.update(0.5)
    print("at 0.5s: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.tweenChain`

Creates a sequence from a table of step descriptors. Each step is a table with `duration`, `target`, `fields`, optional `easing`, optional `callback`, or a `delay` key for pauses.

```lua
-- signature
lurek.tween.tweenChain(steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | `table` | Array of step tables describing the chain. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | The active sequence handle. |

**Example**

```lua
do
    local obj = { x = 0, y = 0 }
    local chain = lurek.tween.tweenChain({
        { duration = 0.5, target = obj, fields = { x = 100 }, easing = "easeOutQuad" },
        { duration = 0.5, target = obj, fields = { y = 100 }, easing = "easeInQuad" },
    })

    print("chain active = " .. tostring(chain:isActive()))
    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
    print("chain result: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `lurek.tween.tweenColor`

Creates and starts a color tween that smoothly interpolates r, g, b, and/or a fields on the target table.

```lua
-- signature
lurek.tween.tweenColor(duration, target, color, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | `number` | Duration in seconds. |
| `target` | `table` | The table containing color fields (`r`, `g`, `b`, `a`). |
| `color` | `table` | Target color values as `{r=, g=, b=, a=}`. Only present keys are tweened. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The active tween handle. |

**Example**

```lua
do
    local color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
    local tw = lurek.tween.tweenColor(2.0, color, { r = 0.0, g = 0.0, b = 1.0 }, "linear")

    lurek.tween.update(1.0)
    print("midpoint: r=" .. string.format("%.2f", color.r) .. " g=" .. string.format("%.2f", color.g) .. " b=" .. string.format("%.2f", color.b))
    lurek.tween.update(1.0)
    print("end: r=" .. color.r .. " b=" .. color.b)
end
```

---

### `lurek.tween.update`

Advances all active tweens, sequences, parallels, and springs by the given delta time. Call once per frame.

```lua
-- signature
lurek.tween.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds since the last frame. |

**Example**

```lua
do
    local pos = { x = 100, y = 200 }
    lurek.tween.to(pos, { x = 0, y = 0 }, 0.5, "easeOutBounce")
    lurek.tween.update(0.5)
    print("moved to: x=" .. pos.x .. " y=" .. pos.y)
end
```

---

## LSpring

### `LSpring:cancel`

Cancels this spring animation and cleans up the on-settle callback if one was registered.

```lua
-- signature
LSpring:cancel()
```

**Example**

```lua
do
    local obj = { val = 0 }
    local spring = lurek.tween.spring(obj, { val = 100 })
    spring:update(1 / 60)
    spring:cancel()
    print("active after cancel = " .. tostring(spring:isActive()))
end
```

---

### `LSpring:getPosition`

Returns the current position of the given spring axis, or `nil` if the axis does not exist.

```lua
-- signature
LSpring:getPosition(field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | `string` | Name of the axis to query. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Current position value, or nil when the axis does not exist. |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:update(1 / 10)

    local pos = spring:getPosition("size")
    print("size = " .. string.format("%.1f", obj.size))
    print("getPosition = " .. tostring(pos))
end
```

---

### `LSpring:isActive`

Returns whether this spring is still actively animating.

```lua
-- signature
LSpring:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if active. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end
```

---

### `LSpring:isSettled`

Returns whether all spring axes have reached their targets within the precision threshold.

```lua
-- signature
LSpring:isSettled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the spring has settled. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end
```

---

### `LSpring:setDamping`

Sets the spring damping for all axes. Higher values reduce oscillation and overshoot.

```lua
-- signature
LSpring:setDamping(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `number` | Damping coefficient (default 10). |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setDamping(20)
    spring:update(1 / 10)
    print("size after damping = " .. string.format("%.1f", obj.size))
    print("settled = " .. tostring(spring:isSettled()))
end
```

---

### `LSpring:setStiffness`

Sets the spring stiffness for all axes. Higher values make the spring snap faster.

```lua
-- signature
LSpring:setStiffness(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `number` | Stiffness coefficient (default 100). |

**Example**

```lua
do
    local obj = { size = 50 }
    local spring = lurek.tween.spring(obj, { size = 100 })
    spring:setStiffness(300)
    spring:update(1 / 10)
    print("size after stronger spring = " .. string.format("%.1f", obj.size))
    print("position = " .. tostring(spring:getPosition("size")))
end
```

---

### `LSpring:setTarget`

Changes the spring target values for one or more axes. Re-activates the spring if it was settled.

```lua
-- signature
LSpring:setTarget(fields)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fields` | `table` | Key-value pairs mapping axis names to new target values. |

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
    print("size = " .. string.format("%.1f", obj.size))

    spring:setTarget({ size = 0 })
    for i = 1, 60 do
        spring:update(1 / 60)
    end

    local pos = spring:getPosition("size")
    print("retargeted size = " .. string.format("%.1f", obj.size))
    print("getPosition = " .. tostring(pos))
end
```

---

### `LSpring:type`

Returns the type name of this object.

```lua
-- signature
LSpring:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LSpring"`. |

**Example**

```lua
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end
```

---

### `LSpring:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LSpring:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against (`"LSpring"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches. |

**Example**

```lua
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end
```

---

### `LSpring:update`

Manually advances this spring by the given delta time and writes updated positions to the target table. Returns `true` if still animating, `false` if settled.

```lua
-- signature
LSpring:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the spring is still moving, `false` if settled. |

**Example**

```lua
do
    local obj = { x = 0 }
    local sp = lurek.tween.spring(obj, { x = 100 }, { stiffness = 200, damping = 20 })
    local still_active = sp:update(0.016)
    print("spring x:", obj.x)
    print("spring still active:", still_active)
end
```

---

## LTween

### `LTween:addValue`

Adds a value track to this tween. This method is available to Lua scripts.

```lua
-- signature
LTween:addValue(start, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | `number` | Start value. |
| `target` | `number` | Target value. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based index of the new value track. |

---

### `LTween:await`

Yields the current coroutine until this tween completes or is cancelled. Must be called from inside a coroutine.

```lua
-- signature
LTween:await()
```

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    local co = coroutine.create(function()
        tw:await()
        print("await resumed at x=" .. target.x)
    end)

    coroutine.resume(co)
    lurek.tween.update(1.0)
    print("coroutine status = " .. coroutine.status(co))
end
```

---

### `LTween:cancel`

Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it.

```lua
-- signature
LTween:cancel()
```

**Example**

```lua
do
    local obj = { w = 100 }
    local tw = lurek.tween.tween(1.0, obj, { w = 200 })

    lurek.tween.update(0.3)
    print("before cancel: w=" .. obj.w)
    tw:cancel()
    print("active after cancel = " .. tostring(tw:isActive()))
    lurek.tween.update(1.0)
    print("after update: w=" .. obj.w)
end
```

---

### `LTween:getAllValues`

Returns all current tween values. This method is available to Lua scripts.

```lua
-- signature
LTween:getAllValues()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Numeric tween values. |

---

### `LTween:getClock`

Returns this tween clock time. This method is available to Lua scripts.

```lua
-- signature
LTween:getClock()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current time in seconds. |

---

### `LTween:getDuration`

Returns this tween duration. This method is available to Lua scripts.

```lua
-- signature
LTween:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("duration=" .. tw:getDuration())
    print("remaining=" .. tw:getRemaining())
end
```

---

### `LTween:getEasingName`

Returns this tween easing function name.

```lua
-- signature
LTween:getEasingName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Easing function name. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("easing=" .. tw:getEasingName())
    print("typeOf=" .. tostring(tw:typeOf("LTween")))
end
```

---

### `LTween:getElapsed`

Returns the number of seconds that have elapsed since the tween started.

```lua
-- signature
LTween:getElapsed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Elapsed time in seconds. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    print("elapsed=" .. tw:getElapsed())
    print("x=" .. target.x)
end
```

---

### `LTween:getFields`

Returns an array of field names being tweened on the target table.

```lua
-- signature
LTween:getFields()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Field name strings. |

**Example**

```lua
do
    local obj = { a = 0, b = 0, c = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { a = 1, b = 2, c = 3 })
    local fields = tw:getFields()
    print("fields: " .. table.concat(fields, ", "))
end
```

---

### `LTween:getProgress`

Returns the eased progress of this tween as a value from 0.0 to 1.0.

```lua
-- signature
LTween:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Eased progress ratio. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.5)
    print("progress=" .. tw:getProgress())
    print("x=" .. target.x)
end
```

---

### `LTween:getRemaining`

Returns the number of seconds remaining until this tween completes.

```lua
-- signature
LTween:getRemaining()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Remaining time in seconds. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    lurek.tween.update(0.25)
    print("remaining=" .. tw:getRemaining())
    print("active=" .. tostring(tw:isActive()))
end
```

---

### `LTween:getTime`

Returns this tween clock time. This method is available to Lua scripts.

```lua
-- signature
LTween:getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current time in seconds. |

---

### `LTween:getValue`

Returns one tween value by one-based index or all values when no index is provided.

```lua
-- signature
LTween:getValue(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | `number` | One-based value index; omit to return all values as a table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Tween value at the given index, or a table of all values when index is omitted. |

---

### `LTween:getValueCount`

Returns the number of values animated by this tween.

```lua
-- signature
LTween:getValueCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Tween value count. |

---

### `LTween:isActive`

Returns whether this tween is still running (not cancelled or completed).

```lua
-- signature
LTween:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the tween is active. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("active before = " .. tostring(tw:isActive()))
    tw:cancel()
    print("active after = " .. tostring(tw:isActive()))
end
```

---

### `LTween:isComplete`

Returns whether this tween is complete.

```lua
-- signature
LTween:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when complete. |

---

### `LTween:onCancel`

Sets a callback to fire when the tween is cancelled. Returns the tween for chaining.

```lua
-- signature
LTween:onCancel(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback fired when the tween is cancelled. |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The same tween handle for chaining. |

**Example**

```lua
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onCancel(function() print("  cancelled") end)
    tw:cancel()
end
```

---

### `LTween:onComplete`

Sets a callback to fire when the tween completes. Returns the tween for chaining.

```lua
-- signature
LTween:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback fired when the tween finishes. |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The same tween handle for chaining. |

**Example**

```lua
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onComplete(function() print("  completed! scale=" .. obj.scale) end)
    lurek.tween.update(0.5)
end
```

---

### `LTween:onUpdate`

Sets a callback to fire every frame while the tween is active. Returns the tween for chaining.

```lua
-- signature
LTween:onUpdate(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Callback fired each frame with the current progress `t` (0..1). |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The same tween handle for chaining. |

**Example**

```lua
do
    local obj = { scale = 1 }
    local tw = lurek.tween.tween(1.0, obj, { scale = 2 })
    tw:onUpdate(function(t) print("  update t=" .. string.format("%.2f", t)) end)
    lurek.tween.update(0.5)
end
```

---

### `LTween:pause`

Pauses this tween so it stops advancing until resumed.

```lua
-- signature
LTween:pause()
```

**Example**

```lua
do
    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    print("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    print("while paused: " .. obj.rotation)
end
```

---

### `LTween:relative`

Chainable version of `setRelative`. Returns the tween for fluent API usage.

```lua
-- signature
LTween:relative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | `true` for relative mode, `false` for absolute. |

**Returns**

| Type | Description |
|------|-------------|
| `LTween` | The same tween handle for chaining. |

**Example**

```lua
do
    local obj = { x = 50, y = 50 }
    ---@type LTween
    local tw = lurek.tween.tween(1.0, obj, { x = 30, y = -20 }):relative(true)
    lurek.tween.update(1.0)
    print("relative result: x=" .. obj.x .. " y=" .. obj.y)
end
```

---

### `LTween:reset`

Resets the tween clock to the beginning.

```lua
-- signature
LTween:reset()
```

---

### `LTween:resume`

Resumes a paused tween so it continues advancing.

```lua
-- signature
LTween:resume()
```

**Example**

```lua
do
    local obj = { rotation = 0 }
    local tw = lurek.tween.tween(2.0, obj, { rotation = 360 })

    lurek.tween.update(0.5)
    print("before pause: " .. obj.rotation)
    tw:pause()
    lurek.tween.update(1.0)
    print("while paused: " .. obj.rotation)

    tw:resume()
    lurek.tween.update(0.5)
    print("after resume: " .. obj.rotation)
end
```

---

### `LTween:set`

Sets this tween clock time. This method is available to Lua scripts.

```lua
-- signature
LTween:set(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | New time in seconds. |

---

### `LTween:setRelative`

Sets whether the tween end values are relative to the start values instead of absolute.

```lua
-- signature
LTween:setRelative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | `true` for relative mode, `false` for absolute. |

**Example**

```lua
do
    local target = { x = 10.0 }
    local tw = lurek.tween.to(target, { x = 5 }, 1.0, "linear")
    tw:setRelative(true)
    lurek.tween.update(1.0)
    print("relative x=" .. target.x)
    print("type=" .. tw:type())
end
```

---

### `LTween:setRepeat`

Sets how many times the tween should repeat after the first play. Use -1 for infinite repeat.

```lua
-- signature
LTween:setRepeat(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of additional repeats (0 = play once, -1 = infinite). |

**Example**

```lua
do
    local obj = { x = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(0.5, obj, { x = 100 })
    tw:setRepeat(3)
    print("repeat set")
end
```

---

### `LTween:setTime`

Sets this tween clock time. This method is available to Lua scripts.

```lua
-- signature
LTween:setTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | New time in seconds. |

---

### `LTween:setYoyo`

Enables or disables yoyo mode, which reverses the tween direction on each repeat cycle.

```lua
-- signature
LTween:setYoyo(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | `true` to enable yoyo, `false` to disable. |

**Example**

```lua
do
    local obj = { x = 0 }
    ---@type LTween
    local tw = lurek.tween.tween(0.5, obj, { x = 100 })
    tw:setYoyo(true)
    print("yoyo set")
end
```

---

### `LTween:type`

Returns the Lua-visible type name for this tween handle.

```lua
-- signature
LTween:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LTween`. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("type=" .. tw:type())
    print("active=" .. tostring(tw:isActive()))
end
```

---

### `LTween:typeOf`

Returns whether this tween handle matches a supported type name.

```lua
-- signature
LTween:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LTween` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("typeOf LTween = " .. tostring(tw:typeOf("LTween")))
    print("typeOf Object = " .. tostring(tw:typeOf("Object")))
end
```

---

### `LTween:update`

Advances the tween clock and returns whether it is complete.

```lua
-- signature
LTween:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the tween is complete. |

---

## LTweenParallel

### `LTweenParallel:add`

Adds an existing tween handle to this parallel group. The tween becomes owned by the group.

```lua
-- signature
LTweenParallel:add(tw_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw_ud` | `LTween` | The tween handle returned by `lurek.tween.tween()` to add to this group. |

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
    par:onComplete(function() print("  parallel group done") end)
    par:start()

    lurek.tween.update(0.8)
    print("alpha=" .. obj1.alpha .. " scale=" .. obj2.scale)
end
```

---

### `LTweenParallel:cancel`

Cancels all tweens in this parallel group immediately.

```lua
-- signature
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
    print("cancelled: active=" .. tostring(par:isActive()))
    print("x=" .. a.x .. " y=" .. b.y)
end
```

---

### `LTweenParallel:isActive`

Returns whether this parallel group is still running.

```lua
-- signature
LTweenParallel:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if any tween in the group is still active. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

### `LTweenParallel:onComplete`

Sets a callback to fire when all tweens in this parallel group have finished. Returns the group for chaining.

```lua
-- signature
LTweenParallel:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Function to call when all tweens in the group complete. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenParallel` | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

### `LTweenParallel:start`

Starts all tweens in this parallel group simultaneously.

```lua
-- signature
LTweenParallel:start()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTweenParallel` | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

### `LTweenParallel:tween`

Creates and adds a new tween step directly to this parallel group.

```lua
-- signature
LTweenParallel:tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | `number` | Duration in seconds. |
| `target` | `table` | The table whose fields will be animated. |
| `fields` | `table` | Key-value pairs mapping field names to target end values. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenParallel` | This parallel group for chaining. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

### `LTweenParallel:type`

Returns the type name of this object.

```lua
-- signature
LTweenParallel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LTweenParallel"`. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

### `LTweenParallel:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LTweenParallel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against (`"LTweenParallel"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches. |

**Example**

```lua
do
    local a = { x = 0.0 } ; local b = { y = 0.0 } ; local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear") ; par:tween(0.5, b, { y = 20 }, "easeinquad") ; local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra) ; par:onComplete(function() print("parallel_done") end) ; print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type()) ; print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start() ; par:cancel()
end
```

---

## LTweenSequence

### `LTweenSequence:await`

Yields the current coroutine until this sequence completes or is cancelled. Must be called from inside a coroutine.

```lua
-- signature
LTweenSequence:await()
```

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    local co = coroutine.create(function()
        seq:await()
        print("sequence await resumed at x=" .. obj.x)
    end)

    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    coroutine.resume(co)
    lurek.tween.update(0.5)
    print("coroutine status = " .. coroutine.status(co))
end
```

---

### `LTweenSequence:callback`

Appends a callback step to this sequence that fires when reached during playback.

```lua
-- signature
LTweenSequence:callback(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Function called when this step is reached during playback. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | This sequence for chaining. |

**Example**

```lua
do
    local obj = { scale = 1 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { scale = 2 })
    seq:callback(function() print("  halfway callback! scale=" .. obj.scale) end)
    seq:tween(0.5, obj, { scale = 1 })
    seq:onComplete(function() print("  sequence complete") end)
    seq:start()

    lurek.tween.update(0.5)
    lurek.tween.update(0.5)
end
```

---

### `LTweenSequence:cancel`

Cancels this sequence immediately and resumes any coroutines waiting on it.

```lua
-- signature
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

    print("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    print("active after cancel = " .. tostring(seq:isActive()))
end
```

---

### `LTweenSequence:delay`

Appends a delay step to this sequence. Optionally fires a callback when the delay elapses.

```lua
-- signature
LTweenSequence:delay(seconds, cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Duration to wait in seconds. |
| `cb?` | `function` | Optional callback fired when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | This sequence for chaining. |

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
    print("fade in done: alpha=" .. obj.alpha)
    lurek.tween.update(0.5)
    print("after delay: alpha=" .. obj.alpha)
    lurek.tween.update(0.3)
    print("fade out done: alpha=" .. obj.alpha)
end
```

---

### `LTweenSequence:getProgress`

Returns the overall progress ratio of this sequence from 0.0 to 1.0.

```lua
-- signature
LTweenSequence:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Progress ratio. |

**Example**

```lua
do
    local obj = { w = 0 }
    local seq = lurek.tween.sequence()
    seq:tween(1.0, obj, { w = 100 })
    seq:tween(1.0, obj, { w = 0 })
    seq:start()
    lurek.tween.update(1.0)

    print("progress at midpoint = " .. seq:getProgress())
    seq:cancel()
    print("active after cancel = " .. tostring(seq:isActive()))
end
```

---

### `LTweenSequence:isActive`

Returns whether this sequence is still running.

```lua
-- signature
LTweenSequence:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the sequence is active. |

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    print("seq active before = " .. tostring(seq:isActive()))
    seq:start()
    print("seq active after = " .. tostring(seq:isActive()))
end
```

---

### `LTweenSequence:onComplete`

Sets a callback to fire when the sequence finishes all steps. Returns the sequence for chaining.

```lua
-- signature
LTweenSequence:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | `function` | Function to call when the sequence completes. |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:onComplete(function() print("seq_done") end)
    seq:start()
    lurek.tween.update(0.5)
    print("seq active = " .. tostring(seq:isActive()))
end
```

---

### `LTweenSequence:start`

Starts playback of this sequence from the first step.

```lua
-- signature
LTweenSequence:start()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:start()
    print("seq active = " .. tostring(seq:isActive()))
    lurek.tween.update(0.5)
    print("seq x = " .. obj.x)
end
```

---

### `LTweenSequence:tween`

Appends a tween step to this sequence that animates numeric fields on the target table.

```lua
-- signature
LTweenSequence:tween(duration, target, fields, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | `number` | Duration in seconds. |
| `target` | `table` | The table whose fields will be animated. |
| `fields` | `table` | Key-value pairs mapping field names to target end values. |
| `easing?` | `string` | Easing function name (default `"linear"`). |

**Returns**

| Type | Description |
|------|-------------|
| `LTweenSequence` | This sequence for chaining. |

**Example**

```lua
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:start()
    lurek.tween.update(0.5)
    print("seq x=" .. obj.x)
    print("seq active = " .. tostring(seq:isActive()))
end
```

---

### `LTweenSequence:type`

Returns the type name of this object.

```lua
-- signature
LTweenSequence:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LTweenSequence"`. |

**Example**

```lua
do
    local seq = lurek.tween.sequence()
    print("seq type = " .. seq:type())
    print("seq typeOf = " .. tostring(seq:typeOf("LTweenSequence")))
end
```

---

### `LTweenSequence:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LTweenSequence:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against (`"LTweenSequence"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches. |

**Example**

```lua
do
    local seq = lurek.tween.sequence()
    print("typeOf LTweenSequence = " .. tostring(seq:typeOf("LTweenSequence")))
    print("typeOf Object = " .. tostring(seq:typeOf("Object")))
end
```

---

## LTweenState

### `LTweenState:isComplete`

Returns whether this tween state has finished its full duration.

```lua
-- signature
LTweenState:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the tween has reached its end. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

### `LTweenState:lerp`

Linearly interpolates between two values using the current eased progress.

```lua
-- signature
LTweenState:lerp(start, finish)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | `number` | Value at progress 0. |
| `finish` | `number` | Value at progress 1. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Interpolated value. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

### `LTweenState:reset`

Resets the tween state to the beginning so it can be replayed.

```lua
-- signature
LTweenState:reset()
```

**Example**

```lua
do
    local state = lurek.tween.newState(1.0)
    state:tick(1.0)
    print("done = " .. tostring(state:isComplete()))
    state:reset()
    print("after reset, done = " .. tostring(state:isComplete()))
    print("t = " .. state:t())
end
```

---

### `LTweenState:t`

Returns the raw (un-eased) progress value from 0.0 to 1.0.

```lua
-- signature
LTweenState:t()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Linear progress ratio. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

### `LTweenState:tick`

Advances the tween state by the given delta time and returns the eased interpolation value (0..1).

```lua
-- signature
LTweenState:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds to advance. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Eased value between 0 and 1. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

### `LTweenState:type`

Returns the type name of this object.

```lua
-- signature
LTweenState:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LTweenState"`. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---

### `LTweenState:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LTweenState:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against (`"LTweenState"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches. |

**Example**

```lua
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end
```

---
