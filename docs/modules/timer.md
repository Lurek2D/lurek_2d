# Timer

## Purpose

Clock system with smoothed deltas, FPS telemetry, and schedulers for timed callbacks and coroutines.

## When To Use

- Clocks, accumulators, schedulers, and sleep helpers live together here so one module can cover frame deltas, elapsed tracking, wall-time waits, and callback scheduling.
- That matters because different systems rely on time in different ways: some need smooth frame metrics, some need deferred events, and some need accumulated timing without drift or ad hoc frame math.
- Delayed callbacks, repeating intervals, and cancelable timer handles give gameplay, UI, and tooling code a structured way to express future work instead of scattering timing state through unrelated systems.

## Minimal Example

From the `lurek.timer.getDelta` example block:

```lua
do
    local dt = lurek.timer.getDelta()
    local fps = lurek.timer.getFPS()
    local avg = lurek.timer.getAverageDelta()
    local smoothed = lurek.timer.getSmoothedDelta()
    lurek.log.info("frame delta = " .. dt .. " seconds")
    lurek.log.info("fps=" .. fps .. " avg=" .. avg .. " smoothed=" .. smoothed)
end
```

## Common Patterns

- Start with `lurek.timer.afterReal` when exploring this module.
- Start with `lurek.timer.chain` when exploring this module.
- Start with `lurek.timer.getAverageDelta` when exploring this module.
- Start with `lurek.timer.getDelta` when exploring this module.
- Start with `lurek.timer.getFPS` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/timer.lua`

## Summary

- The `timer` module is the shared time-management surface for users who need clocks, delayed callbacks, repeating work, and timing queries to behave consistently.
- Clocks, accumulators, schedulers, and sleep helpers live together here so one module can cover frame deltas, elapsed tracking, wall-time waits, and callback scheduling.
- That matters because different systems rely on time in different ways: some need smooth frame metrics, some need deferred events, and some need accumulated timing without drift or ad hoc frame math.
- Delayed callbacks, repeating intervals, and cancelable timer handles give gameplay, UI, and tooling code a structured way to express future work instead of scattering timing state through unrelated systems.
- Deterministic accumulation is especially valuable for scripted sequences, cooldowns, analytics sampling, and automated tests where time should stay queryable and comparable.
- That shared scheduling layer also helps systems agree on cadence instead of inventing separate delay bookkeeping.
- It keeps deferred work inspectable.
- The module therefore serves both as a low-level clock source and as a coordination surface for anything that must happen later, repeatedly, or after a measured duration.
- Read `timer` as the engine's common timing layer: neighboring modules consume time, but this module turns it into a reusable, schedulable runtime resource.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.timer.afterReal`

Schedules a one-shot callback based on real (wall-clock) time, unaffected by game pausing or time scaling. Use for UI fade-outs, notifications, or anything that should run on real time.

```lua
lurek.timer.afterReal(delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `delay` | number | Real-time delay in seconds before the callback fires. |
| `func` | function | Callback to invoke when the real-time deadline is reached. |

**Example**

```lua
do
    local callback_count = 0
    lurek.timer.afterReal(0.0, function() callback_count = callback_count + 1 end)
    local fired = lurek.timer.tickRealTimers()
    local second = lurek.timer.tickRealTimers()
    lurek.log.info("real timers fired = " .. fired)
    lurek.log.info("callback count=" .. callback_count .. " second tick=" .. second)
end
```

---

### `lurek.timer.chain`

Creates a scheduler pre-loaded with a sequence of delayed callbacks. Each step is a table with an optional `delay` (seconds) and optional `func` (callback). Delays accumulate so each step fires after the sum of all preceding delays. Returns the scheduler for manual update calls.

```lua
lurek.timer.chain(steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | table | Array of step tables, each with optional fields `delay` (number) and `func` (function). |

**Returns**

| Type | Description |
|------|-------------|
| [LScheduler](#lscheduler) | A new scheduler pre-loaded with the chained events. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.chain({
        { delay = 0.5, func = function() count = count + 1 end },
        { delay = 1.0, func = function() count = count + 1 end },
    })

    sched:update(0.5)
    sched:update(1.0)
    lurek.log.info("chain steps = " .. count)
end
```

---

### `lurek.timer.getAverageDelta`

Returns the smoothed average delta time in seconds over a recent window of frames. More stable than getDelta for display or adaptive logic.

```lua
lurek.timer.getAverageDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Average delta time in seconds. |

**Example**

```lua
do
    local avg = lurek.timer.getAverageDelta()
    local dt = lurek.timer.getDelta()
    local smoothed = lurek.timer.getSmoothedDelta()
    local fps = lurek.timer.getFPS()
    lurek.log.info("average delta = " .. avg)
    lurek.log.info("current=" .. dt .. " smoothed=" .. smoothed .. " fps=" .. fps)
end
```

---

### `lurek.timer.getDelta`

Returns the time in seconds elapsed since the last frame. Use this to make movement and animations frame-rate independent.

```lua
lurek.timer.getDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Delta time in seconds. |

**Example**

```lua
do
    local dt = lurek.timer.getDelta()
    local fps = lurek.timer.getFPS()
    local avg = lurek.timer.getAverageDelta()
    local smoothed = lurek.timer.getSmoothedDelta()
    lurek.log.info("frame delta = " .. dt .. " seconds")
    lurek.log.info("fps=" .. fps .. " avg=" .. avg .. " smoothed=" .. smoothed)
end
```

---

### `lurek.timer.getFPS`

Returns the current frames-per-second count. Useful for performance monitoring overlays and debug HUDs.

```lua
lurek.timer.getFPS()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current FPS. |

**Example**

```lua
do
    local fps = lurek.timer.getFPS()
    local dt = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    local frames = lurek.timer.getFrameCount()
    lurek.log.info("current FPS = " .. fps)
    lurek.log.info("dt=" .. dt .. " avg=" .. avg .. " frames=" .. frames)
end
```

---

### `lurek.timer.getFrameCount`

Returns the total number of frames rendered since the engine started.

```lua
lurek.timer.getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total frame count. |

**Example**

```lua
do
    local frames = lurek.timer.getFrameCount()
    local time = lurek.timer.getTime()
    local fps = lurek.timer.getFPS()
    local warm = frames > 60
    lurek.log.info("total frames = " .. frames)
    lurek.log.info("time=" .. time .. " fps=" .. fps .. " warmed=" .. tostring(warm))
end
```

---

### `lurek.timer.getMicroTime`

Returns high-resolution elapsed time in seconds since engine start. Useful for precise benchmarking and profiling.

```lua
lurek.timer.getMicroTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Elapsed time in seconds with sub-microsecond precision. |

**Example**

```lua
do
    local start = lurek.timer.getMicroTime()
    local sum = 0
    for i = 1, 10000 do sum = sum + i end
    local elapsed = lurek.timer.getMicroTime() - start
    lurek.log.info("loop took " .. elapsed .. " seconds")
end
```

---

### `lurek.timer.getPhysicsDelta`

Returns the fixed timestep used for physics simulation in seconds. The default is typically 1/60.

```lua
lurek.timer.getPhysicsDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Fixed physics delta time in seconds. |

**Example**

```lua
do
    local pdt = lurek.timer.getPhysicsDelta()
    local max_steps = lurek.timer.getPhysicsMaxSteps()
    local per_second = 1 / pdt
    local dt = lurek.timer.getDelta()
    lurek.log.info("physics delta = " .. pdt)
    lurek.log.info("steps/sec=" .. per_second .. " maxSteps=" .. max_steps .. " frameDt=" .. dt)
end
```

---

### `lurek.timer.getPhysicsMaxSteps`

Returns the maximum number of physics steps allowed per frame. Prevents the spiral of death when the game runs slowly.

```lua
lurek.timer.getPhysicsMaxSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum physics steps per frame. |

**Example**

```lua
do
    local max = lurek.timer.getPhysicsMaxSteps()
    lurek.timer.setPhysicsMaxSteps(8)
    local updated = lurek.timer.getPhysicsMaxSteps()
    local pdt = lurek.timer.getPhysicsDelta()
    lurek.log.info("max physics steps = " .. max)
    lurek.log.info("set to " .. updated .. " with physics dt=" .. pdt)
end
```

---

### `lurek.timer.getSmoothedDelta`

Returns an exponentially smoothed delta time in seconds, reducing frame-to-frame jitter. Call once per frame for consistent results. The smoothing factor is set via setSmoothingFactor.

```lua
lurek.timer.getSmoothedDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Smoothed delta time in seconds. |

**Example**

```lua
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    local raw = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    lurek.log.info("smoothed delta (alpha=0.1) = " .. sd)
    lurek.log.info("raw=" .. raw .. " avg=" .. avg)
end
```

---

### `lurek.timer.getTime`

Returns the total elapsed game time in seconds since the engine started. Useful for time-based animations, effects, and shader uniforms.

```lua
lurek.timer.getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total elapsed time in seconds. |

**Example**

```lua
do
    local t = lurek.timer.getTime()
    local frames = lurek.timer.getFrameCount()
    local fps = lurek.timer.getFPS()
    local uptime_per_frame = frames > 0 and (t / frames) or 0
    lurek.log.info("elapsed time = " .. t .. " seconds")
    lurek.log.info("frames=" .. frames .. " fps=" .. fps .. " sec/frame=" .. uptime_per_frame)
end
```

---

### `lurek.timer.newScheduler`

Creates a new [LScheduler](#lscheduler) instance for managing timed and frame-based callbacks independently from the global timer. Each scheduler has its own time scale and event list.

```lua
lurek.timer.newScheduler()
```

**Returns**

| Type | Description |
|------|-------------|
| [LScheduler](#lscheduler) | A new scheduler object. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local type_name = sched:type()
    local is_sched = sched:typeOf("LScheduler")
    local empty = sched:isEmpty()
    local count = sched:getCount()
    lurek.log.info("scheduler type = " .. type_name)
    lurek.log.info("isScheduler=" .. tostring(is_sched) .. " empty=" .. tostring(empty) .. " count=" .. count)
end
```

---

### `lurek.timer.setPhysicsDelta`

Sets the fixed timestep for physics simulation. Clamped between 1/240 and 1/10 seconds. Lower values increase accuracy but cost more CPU.

```lua
lurek.timer.setPhysicsDelta(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Desired fixed delta time in seconds. |

**Example**

```lua
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    local steps = lurek.timer.getPhysicsMaxSteps()
    local per_second = 1 / pd
    lurek.log.info("physics_delta=" .. pd)
    lurek.log.info("steps/sec=" .. per_second .. " maxSteps=" .. steps)
end
```

---

### `lurek.timer.setPhysicsMaxSteps`

Sets the maximum number of physics steps allowed per frame. Clamped between 1 and 64. Higher values improve accuracy under lag but cost more CPU.

```lua
lurek.timer.setPhysicsMaxSteps(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum physics steps per frame. |

**Example**

```lua
do
    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    local pdt = lurek.timer.getPhysicsDelta()
    local total_budget = pm * pdt
    lurek.log.info("physics_max_steps=" .. pm)
    lurek.log.info("maximum catch-up seconds=" .. total_budget)
end
```

---

### `lurek.timer.setSmoothingFactor`

Sets the exponential smoothing factor used by getSmoothedDelta. Lower values produce smoother (more lagged) results; higher values track changes faster. Clamped to [0.01, 1.0].

```lua
lurek.timer.setSmoothingFactor(alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `alpha` | number | Smoothing factor between 0.01 and 1.0. |

**Example**

```lua
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    local raw = lurek.timer.getDelta()
    local avg = lurek.timer.getAverageDelta()
    lurek.log.info("smoothed_delta=" .. sd)
    lurek.log.info("raw=" .. raw .. " avg=" .. avg)
end
```

---

### `lurek.timer.sleep`

Blocks the current thread for the given number of seconds. Use sparingly â€” this halts the entire game loop. Intended for loading screens or synchronization.

```lua
lurek.timer.sleep(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Duration to sleep in seconds. |

**Example**

```lua
do
    local before = lurek.timer.getMicroTime()
    lurek.timer.sleep(0)
    local after_zero = lurek.timer.getMicroTime()
    lurek.timer.sleep(0.01)
    local after_sleep = lurek.timer.getMicroTime()
    lurek.log.info("sleep(0) elapsed = " .. (after_zero - before))
    lurek.log.info("sleep(0.01) elapsed = " .. (after_sleep - after_zero))
end
```

---

### `lurek.timer.step`

Advances the internal clock by one tick and returns the delta time for that tick. Typically called by the engine loop; game scripts rarely need this.

```lua
lurek.timer.step()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Delta time in seconds for the step. |

**Example**

```lua
do
    local dt = lurek.timer.step()
    local after = lurek.timer.getDelta()
    local fps = lurek.timer.getFPS()
    local frames = lurek.timer.getFrameCount()
    lurek.log.info("step produced dt = " .. dt)
    lurek.log.info("stored dt=" .. after .. " fps=" .. fps .. " frames=" .. frames)
end
```

---

### `lurek.timer.tickRealTimers`

Checks all real-time timers and fires any whose deadline has passed. Returns the number of callbacks that fired. Call this once per frame after afterReal scheduling.

```lua
lurek.timer.tickRealTimers()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of real-time callbacks that fired. |

**Example**

```lua
do
    local fired = lurek.timer.tickRealTimers()
    local fired2 = lurek.timer.tickRealTimers()
    local now = lurek.timer.getTime()
    lurek.log.info("real timers fired = " .. fired)
    lurek.log.info("second tick=" .. fired2 .. " time=" .. now)
end
```

---

### `lurek.timer.tickWaits`

Checks all pending waitSeconds and waitFrames coroutines, resumes any whose deadline or frame target has been reached, and cleans up completed entries. Returns the number of coroutines that were resumed. Call once per frame.

```lua
lurek.timer.tickWaits()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of coroutines resumed. |

**Example**

```lua
do
    local co = coroutine.create(function()
        lurek.timer.waitFrames(1)
        lurek.timer.waitSeconds(0)
    end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. coroutine.status(co))
end
```

---

### `lurek.timer.waitFrames`

Yields the current coroutine for the given number of frames. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the target frame count has been reached.

```lua
lurek.timer.waitFrames(frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frames` | number | Number of frames to wait. |

**Example**

```lua
do
    local co = coroutine.create(function() lurek.timer.waitFrames(1) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. coroutine.status(co))
end
```

---

### `lurek.timer.waitSeconds`

Yields the current coroutine for the given number of real-time seconds. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the deadline has passed.

```lua
lurek.timer.waitSeconds(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Real-time seconds to wait. |

**Example**

```lua
do
    local co = coroutine.create(function() lurek.timer.waitSeconds(0) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    local status = coroutine.status(co)
    local resumed = lurek.timer.tickWaits()
    lurek.log.info("wait coroutine = " .. status)
    lurek.log.info("second tick resumed = " .. resumed)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.timer.afterReal` param `func` (`function`): Callback to invoke when the real-time deadline is reached.

## Enums

*No module-specific enums documented.*

## Types

- [LScheduler](#lscheduler)

## LScheduler

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScheduler:after`

Schedules a one-shot callback to fire after the given delay in seconds. Returns an event ID that can be used to cancel, pause, or query the event.

```lua
LScheduler:after(delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `delay` | number | Time in seconds before the callback fires. |
| `func` | function | Callback to invoke when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    local id = sched:after(0.5, function() fired = fired + 1 end)
    local before = sched:getCount()
    local callbacks = sched:update(0.5)
    lurek.log.info("scheduled one-shot id = " .. id .. " countBefore=" .. before)
    lurek.log.info("callbacks=" .. callbacks .. " fired=" .. fired)
end
```

---

#### `LScheduler:afterFrames`

Schedules a one-shot callback to fire after the given number of frames. Returns an event ID for management.

```lua
LScheduler:afterFrames(n, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of frames to wait before the callback fires. |
| `func` | function | Callback to invoke when the frame count elapses. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local fired_count = 0
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function() fired_count = fired_count + 1 end)
    sched:updateFrames()
    sched:updateFrames()
    local fired = sched:updateFrames()
    lurek.log.info("frame events = " .. fired)
    lurek.log.info("callback count = " .. fired_count)
end
```

---

#### `LScheduler:afterNamed`

Schedules a named one-shot callback after a delay in seconds. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for debouncing or resettable delays.

```lua
LScheduler:afterNamed(name, delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this scheduled event. |
| `delay` | number | Time in seconds before the callback fires. |
| `func` | function | Callback to invoke when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    sched:afterNamed("save", 2.0, function() fired = fired + 1 end)
    local count = sched:getCount()
    local paused = sched:isPausedNamed("save")
    lurek.log.info("named timer scheduled for save")
    lurek.log.info("count=" .. count .. " paused=" .. tostring(paused) .. " fired=" .. fired)
end
```

---

#### `LScheduler:cancel`

Cancels a scheduled event by its ID. Returns true if the event was found and removed, false if it did not exist.

```lua
LScheduler:cancel(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID returned by after, every, or their variants. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event was found and cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(3.0, function() end)
    local id = sched:after(2.0, function() end)
    local ok = sched:cancel(id)
    lurek.log.info("cancel id = " .. tostring(ok))
    lurek.log.info("count after = " .. sched:getCount())
end
```

---

#### `LScheduler:cancelAll`

Cancels all scheduled events in this scheduler and frees their callbacks. Returns the number of events that were removed.

```lua
LScheduler:cancelAll()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of events that were cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(2.0, function() end)
    sched:after(3.0, function() end)
    local removed = sched:cancelAll()
    lurek.log.info("cancelAll removed = " .. removed)
    lurek.log.info("empty = " .. tostring(sched:isEmpty()))
end
```

---

#### `LScheduler:cancelNamed`

Cancels a named scheduled event. Returns true if the named event was found and removed.

```lua
LScheduler:cancelNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The name used when scheduling with afterNamed or everyNamed. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the named event was found and cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    local cancelled = sched:cancelNamed("save")
    local empty = sched:isEmpty()
    local count = sched:getCount()
    lurek.log.info("cancelled named timer = " .. tostring(cancelled))
    lurek.log.info("empty=" .. tostring(empty) .. " count=" .. count)
end
```

---

#### `LScheduler:every`

Schedules a repeating callback that fires at a fixed interval in seconds. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.

```lua
LScheduler:every(interval, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | number | Time in seconds between each invocation. |
| `func` | function | Callback to invoke on each interval tick. |
| `count?` | number | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this repeating callback. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:every(0.25, function() count = count + 1 end, 2)
    sched:update(0.25)
    sched:update(0.25)
    lurek.log.info("final count = " .. count)
end
```

---

#### `LScheduler:everyFrames`

Schedules a repeating callback that fires every N frames. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.

```lua
LScheduler:everyFrames(n, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of frames between each invocation. |
| `func` | function | Callback to invoke on each frame-interval tick. |
| `count?` | number | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this repeating callback. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyFrames(2, function() count = count + 1 end, 2)
    sched:updateFrames()
    sched:updateFrames()
    sched:updateFrames()
    sched:updateFrames()
    lurek.log.info("frame ticks = " .. count)
end
```

---

#### `LScheduler:everyNamed`

Schedules a named repeating callback at a fixed interval. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for restartable periodic effects like health regeneration or status ticks.

```lua
LScheduler:everyNamed(name, interval, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for this repeating event. |
| `interval` | number | Time in seconds between each invocation. |
| `func` | function | Callback to invoke on each interval tick. |
| `count?` | number | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| number | Unique event ID for this repeating callback. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyNamed("regen", 1.0, function() count = count + 1 end)
    sched:update(1.0)
    sched:update(1.0)
    lurek.log.info("ticks = " .. count)
end
```

---

#### `LScheduler:getCount`

Returns the total number of active scheduled events in this scheduler.

```lua
LScheduler:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of active events. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local before = sched:getCount()
    sched:after(1.0, function() lurek.log.info("after timer fired") end)
    local after = sched:getCount()
    local empty = sched:isEmpty()
    lurek.log.info("count before = " .. before)
    lurek.log.info("count after = " .. after .. " empty=" .. tostring(empty))
end
```

---

#### `LScheduler:getInterval`

Returns the interval duration in seconds for a repeating event. The first return value indicates whether the event was found; the second is the interval (0.0 if not found).

```lua
LScheduler:getInterval(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event exists. |
| number | Interval in seconds; or 0.0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found2, interval = sched:getInterval(id)
    local _, repeats = sched:getRepeatCount(id)
    local _, remaining = sched:getRemaining(id)
    lurek.log.info("interval found=" .. tostring(found2) .. " value=" .. interval)
    lurek.log.info("repeat count=" .. repeats .. " remaining=" .. remaining)
end
```

---

#### `LScheduler:getRemaining`

Returns the remaining time in seconds before the event fires. The first return value indicates whether the event was found; the second is the remaining time (0.0 if not found).

```lua
LScheduler:getRemaining(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event exists. |
| number | Remaining time in seconds; or 0.0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    sched:update(0.2)
    local found2, remaining2 = sched:getRemaining(id)
    lurek.log.info("remaining found=" .. tostring(found) .. " time=" .. remaining)
    lurek.log.info("after update found=" .. tostring(found2) .. " time=" .. remaining2)
end
```

---

#### `LScheduler:getRepeatCount`

Returns the remaining repeat count for a repeating event. The first return value indicates whether the event was found; the second is the count (0 if not found). A value of -1 means infinite repeats.

```lua
LScheduler:getRepeatCount(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event exists. |
| number | Remaining repeat count; or 0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found3, repeats = sched:getRepeatCount(id)
    sched:update(0.5)
    local _, repeats_after = sched:getRepeatCount(id)
    lurek.log.info("repeat count found=" .. tostring(found3) .. " value=" .. repeats)
    lurek.log.info("after one tick repeats = " .. repeats_after)
end
```

---

#### `LScheduler:getTimeScale`

Returns the current time scale multiplier for this scheduler.

```lua
LScheduler:getTimeScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time scale (1.0 = normal speed). |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    local scale = sched:getTimeScale()
    local count = sched:getCount()
    local type_name = sched:type()
    lurek.log.info("time scale = " .. scale)
    lurek.log.info("scheduler count=" .. count .. " type=" .. type_name)
end
```

---

#### `LScheduler:isEmpty`

Returns true if the scheduler has no active events.

```lua
LScheduler:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no events are scheduled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local empty_before = sched:isEmpty()
    sched:after(1.0, function() end)
    local empty_with_timer = sched:isEmpty()
    sched:cancelAll()
    local empty_after = sched:isEmpty()
    lurek.log.info("empty before = " .. tostring(empty_before) .. " withTimer=" .. tostring(empty_with_timer))
    lurek.log.info("empty after cancelAll = " .. tostring(empty_after))
end
```

---

#### `LScheduler:isPaused`

Checks whether a scheduled event is currently paused.

```lua
LScheduler:isPaused(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event is paused, false if running or not found. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    local paused = sched:isPaused(id)
    sched:resume(id)
    local resumed = sched:isPaused(id)
    lurek.log.info("paused state = " .. tostring(paused))
    lurek.log.info("after resume paused = " .. tostring(resumed))
end
```

---

#### `LScheduler:isPausedNamed`

Checks whether a named scheduled event is currently paused.

```lua
LScheduler:isPausedNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the named event is paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local paused = sched:isPausedNamed("named_once")
    local count = sched:getCount()
    sched:resumeNamed("named_once")
    lurek.log.info("paused_named=" .. tostring(paused))
    lurek.log.info("count=" .. count .. " resumed=" .. tostring(sched:isPausedNamed("named_once")))
end
```

---

#### `LScheduler:pause`

Pauses a scheduled event so it stops accumulating time. Returns true if the event was found and paused.

```lua
LScheduler:pause(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to pause. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event exists and was paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    local paused = sched:isPaused(id)
    local found, remaining = sched:getRemaining(id)
    local count = sched:getCount()
    lurek.log.info("paused event id=" .. id .. " paused=" .. tostring(paused))
    lurek.log.info("found=" .. tostring(found) .. " remaining=" .. remaining .. " count=" .. count)
end
```

---

#### `LScheduler:pauseNamed`

Pauses a named scheduled event. Returns true if the named event was found and paused.

```lua
LScheduler:pauseNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the named event exists and was paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local paused = sched:isPausedNamed("named_once")
    local cancelled = sched:cancelNamed("named_once")
    lurek.log.info("paused_named=" .. tostring(paused))
    lurek.log.info("cancelled after pause = " .. tostring(cancelled))
end
```

---

#### `LScheduler:resetEvent`

Resets the elapsed time of a scheduled event back to zero, restarting its delay or interval countdown. Returns true if the event was found and reset.

```lua
LScheduler:resetEvent(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to reset. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event was found and reset. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    sched:update(0.3)
    sched:resetEvent(id)
    local found, remaining = sched:getRemaining(id)
    lurek.log.info("after reset, remaining = " .. remaining)
end
```

---

#### `LScheduler:resume`

Resumes a previously paused event so it continues accumulating time. Returns true if the event was found and resumed.

```lua
LScheduler:resume(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID to resume. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event exists and was resumed. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    sched:resume(id)
    lurek.log.info("resumed, paused = " .. tostring(sched:isPaused(id)))
end
```

---

#### `LScheduler:resumeNamed`

Resumes a previously paused named event. Returns true if the named event was found and resumed.

```lua
LScheduler:resumeNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the named event exists and was resumed. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local resumed = sched:resumeNamed("named_once")
    lurek.log.info("resumeNamed ok = " .. tostring(resumed))
    lurek.log.info("paused_named = " .. tostring(sched:isPausedNamed("named_once")))
end
```

---

#### `LScheduler:setInterval`

Changes the interval duration in seconds for an existing repeating event. Returns true if the event was found and updated.

```lua
LScheduler:setInterval(id, interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Event ID of the repeating event. |
| `interval` | number | New interval duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the event was found and its interval updated. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function() end)
    sched:setInterval(id, 0.5)
    local found, interval = sched:getInterval(id)
    local _, remaining = sched:getRemaining(id)
    lurek.log.info("interval changed to 0.5 found=" .. tostring(found))
    lurek.log.info("interval=" .. interval .. " remaining=" .. remaining)
end
```

---

#### `LScheduler:setTimeScale`

Sets the time scale multiplier for this scheduler. A value of 2.0 makes events fire twice as fast; 0.5 makes them fire at half speed. Does not affect frame-based events.

```lua
LScheduler:setTimeScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Time scale multiplier (1.0 = normal speed). |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    local scale = sched:getTimeScale()
    local fired = 0
    sched:after(1.0, function() fired = fired + 1 end)
    local callbacks = sched:update(0.5)
    lurek.log.info("time scale = " .. scale)
    lurek.log.info("callbacks=" .. callbacks .. " fired=" .. fired)
end
```

---

#### `LScheduler:type`

Returns the type name of this object as a string.

```lua
LScheduler:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LScheduler](#lscheduler)". |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local type_name = sched:type()
    local is_sched = sched:typeOf("LScheduler")
    local is_object = sched:typeOf("LObject")
    lurek.log.info("type=" .. type_name)
    lurek.log.info("isScheduler=" .. tostring(is_sched) .. " isObject=" .. tostring(is_object))
end
```

---

#### `LScheduler:typeOf`

Checks whether this object matches the given type name. Accepts "[LScheduler](#lscheduler)" or "Object".

```lua
LScheduler:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local is_sched = sched:typeOf("LScheduler")
    local is_object = sched:typeOf("LObject")
    local is_window = sched:typeOf("LWindow")
    lurek.log.info("typeOf LScheduler = " .. tostring(is_sched))
    lurek.log.info("is object = " .. tostring(is_object) .. " window=" .. tostring(is_window))
end
```

---

#### `LScheduler:update`

Advances all time-based events by dt seconds, fires any callbacks whose delay has elapsed, and cleans up completed one-shot events. Call this once per frame with delta time. Returns the number of callbacks that fired.

```lua
LScheduler:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since the last update. |

**Returns**

| Type | Description |
|------|-------------|
| number | Count of callbacks that fired during this update. |

**Example**

```lua
do
    local fired = 0
    local sched = lurek.timer.newScheduler()
    sched:after(0.5, function() fired = fired + 1 end)
    sched:update(0.5)
    lurek.log.info("fired = " .. fired)
end
```

---

#### `LScheduler:updateFrames`

Advances all frame-based events by one frame, fires any callbacks whose frame count has been reached, and cleans up completed one-shot events. Call this once per frame. Returns the number of callbacks that fired.

```lua
LScheduler:updateFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of callbacks that fired during this frame update. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local fired = 0
    sched:afterFrames(1, function() fired = fired + 1 end)
    local callbacks = sched:updateFrames()
    local empty = sched:isEmpty()
    lurek.log.info("frame events = " .. callbacks)
    lurek.log.info("callback count=" .. fired .. " empty=" .. tostring(empty))
end
```

---
