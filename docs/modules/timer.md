# Timer

- The `timer` module is a fundamental Core Runtime tier component responsible for precise frame timing, fixed-step accumulation, and deferred callback scheduling.

At the core of the engine's main loop sits the `Clock`, which meticulously tracks per-frame delta time, accumulated total elapsed time, and a rolling frames-per-second (FPS) measurement. To ensure smooth gameplay and stable adaptive logic, it calculates a rolling average delta using a fixed-size ring buffer, which mitigates frame-time jitter. Furthermore, its internal microsecond accumulation employs fractional sub-microsecond carry, completely preventing time-drift errors across frames.

Beyond basic timekeeping, the module provides a highly versatile `Scheduler` for managing deferred and recurring logic. The scheduler handles both time-based (seconds) and frame-based (tick counts) events, offering one-shot and repeating modes. Events can be assigned string names, enabling automatic deduplication—where registering a new named event transparently cancels and replaces any existing event with the same name. Developers have fine-grained lifecycle control over scheduled events, with the ability to pause, resume, reset, or mutate the interval of active timers. Crucially, the scheduler supports a global time-scale multiplier, allowing developers to easily implement slow-motion or fast-forward effects that apply universally to all scheduled callbacks without affecting the underlying wall-clock timers.

The module also caters to diverse asynchronous scripting patterns. It provides real-time timers (`afterReal`) that bypass the global time-scale and game pauses, making them ideal for UI animations or system notifications. For coroutine-based scripting, the module offers `waitSeconds` and `waitFrames`, which yield the current coroutine and auto-resume it once the deadline passes, vastly simplifying complex sequence scripting. Supported by swap-remove compaction to maintain O(1) performance even with thousands of active timers, the `lurek.timer.*` API gives developers robust, high-performance control over the flow of time in their games.

## Functions

### `lurek.timer.afterReal`

Schedules a one-shot callback based on real (wall-clock) time, unaffected by game pausing or time scaling. Use for UI fade-outs, notifications, or anything that should run on real time.

```lua
-- signature
lurek.timer.afterReal(delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `delay` | `number` | Real-time delay in seconds before the callback fires. |
| `func` | `function` | Callback to invoke when the real-time deadline is reached. |

**Example**

```lua
do
    lurek.timer.afterReal(1.0, function() end)
    local fired = lurek.timer.tickRealTimers()
    print("real timers fired = " .. fired)
end
```

---

### `lurek.timer.chain`

Creates a scheduler pre-loaded with a sequence of delayed callbacks. Each step is a table with an optional `delay` (seconds) and optional `func` (callback). Delays accumulate so each step fires after the sum of all preceding delays. Returns the scheduler for manual update calls.

```lua
-- signature
lurek.timer.chain(steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `steps` | `table` | Array of step tables, each with optional fields `delay` (number) and `func` (function). |

**Returns**

| Type | Description |
|------|-------------|
| `LScheduler` | A new scheduler pre-loaded with the chained events. |

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
    print("chain steps = " .. count)
end
```

---

### `lurek.timer.getAverageDelta`

Returns the smoothed average delta time in seconds over a recent window of frames. More stable than getDelta for display or adaptive logic.

```lua
-- signature
lurek.timer.getAverageDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Average delta time in seconds. |

**Example**

```lua
do
    local avg = lurek.timer.getAverageDelta()
    print("average delta = " .. avg)
end
```

---

### `lurek.timer.getDelta`

Returns the time in seconds elapsed since the last frame. Use this to make movement and animations frame-rate independent.

```lua
-- signature
lurek.timer.getDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Delta time in seconds. |

**Example**

```lua
do
    local dt = lurek.timer.getDelta()
    print("delta time = " .. dt .. " seconds")
end
```

---

### `lurek.timer.getFPS`

Returns the current frames-per-second count. Useful for performance monitoring overlays and debug HUDs.

```lua
-- signature
lurek.timer.getFPS()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current FPS. |

**Example**

```lua
do
    local fps = lurek.timer.getFPS()
    print("current FPS = " .. fps)
end
```

---

### `lurek.timer.getFrameCount`

Returns the total number of frames rendered since the engine started.

```lua
-- signature
lurek.timer.getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total frame count. |

**Example**

```lua
do
    local frames = lurek.timer.getFrameCount()
    print("total frames = " .. frames)
end
```

---

### `lurek.timer.getMicroTime`

Returns high-resolution elapsed time in seconds since engine start. Useful for precise benchmarking and profiling.

```lua
-- signature
lurek.timer.getMicroTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Elapsed time in seconds with sub-microsecond precision. |

**Example**

```lua
do
    local start = lurek.timer.getMicroTime()
    local sum = 0
    for i = 1, 10000 do sum = sum + i end
    local elapsed = lurek.timer.getMicroTime() - start
    print("loop took " .. elapsed .. " seconds")
end
```

---

### `lurek.timer.getPhysicsDelta`

Returns the fixed timestep used for physics simulation in seconds. The default is typically 1/60.

```lua
-- signature
lurek.timer.getPhysicsDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Fixed physics delta time in seconds. |

**Example**

```lua
do
    local pdt = lurek.timer.getPhysicsDelta()
    print("physics delta = " .. pdt)
end
```

---

### `lurek.timer.getPhysicsMaxSteps`

Returns the maximum number of physics steps allowed per frame. Prevents the spiral of death when the game runs slowly.

```lua
-- signature
lurek.timer.getPhysicsMaxSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum physics steps per frame. |

**Example**

```lua
do
    local max = lurek.timer.getPhysicsMaxSteps()
    print("max physics steps = " .. max)
    lurek.timer.setPhysicsMaxSteps(8)
    print("set to 8: " .. lurek.timer.getPhysicsMaxSteps())
end
```

---

### `lurek.timer.getSmoothedDelta`

Returns an exponentially smoothed delta time in seconds, reducing frame-to-frame jitter. Call once per frame for consistent results. The smoothing factor is set via setSmoothingFactor.

```lua
-- signature
lurek.timer.getSmoothedDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Smoothed delta time in seconds. |

**Example**

```lua
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed delta (alpha=0.1) = " .. sd)
end
```

---

### `lurek.timer.getTime`

Returns the total elapsed game time in seconds since the engine started. Useful for time-based animations, effects, and shader uniforms.

```lua
-- signature
lurek.timer.getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total elapsed time in seconds. |

**Example**

```lua
do
    local t = lurek.timer.getTime()
    print("elapsed time = " .. t .. " seconds")
end
```

---

### `lurek.timer.newScheduler`

Creates a new LScheduler instance for managing timed and frame-based callbacks independently from the global timer. Each scheduler has its own time scale and event list.

```lua
-- signature
lurek.timer.newScheduler()
```

**Returns**

| Type | Description |
|------|-------------|
| `LScheduler` | A new scheduler object. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    print("type = " .. sched:type())
    print("is LScheduler = " .. tostring(sched:typeOf("LScheduler")))
    print("empty = " .. tostring(sched:isEmpty()))
end
```

---

### `lurek.timer.setPhysicsDelta`

Sets the fixed timestep for physics simulation. Clamped between 1/240 and 1/10 seconds. Lower values increase accuracy but cost more CPU.

```lua
-- signature
lurek.timer.setPhysicsDelta(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Desired fixed delta time in seconds. |

**Example**

```lua
do
    lurek.timer.setPhysicsDelta(1/60)
    local pd = lurek.timer.getPhysicsDelta()
    print("physics_delta=" .. pd)
end
```

---

### `lurek.timer.setPhysicsMaxSteps`

Sets the maximum number of physics steps allowed per frame. Clamped between 1 and 64. Higher values improve accuracy under lag but cost more CPU.

```lua
-- signature
lurek.timer.setPhysicsMaxSteps(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Maximum physics steps per frame. |

**Example**

```lua
do
    lurek.timer.setPhysicsMaxSteps(5)
    local pm = lurek.timer.getPhysicsMaxSteps()
    print("physics_max_steps=" .. pm)
end
```

---

### `lurek.timer.setSmoothingFactor`

Sets the exponential smoothing factor used by getSmoothedDelta. Lower values produce smoother (more lagged) results; higher values track changes faster. Clamped to [0.01, 1.0].

```lua
-- signature
lurek.timer.setSmoothingFactor(alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `alpha` | `number` | Smoothing factor between 0.01 and 1.0. |

**Example**

```lua
do
    lurek.timer.setSmoothingFactor(0.1)
    local sd = lurek.timer.getSmoothedDelta()
    print("smoothed_delta=" .. sd)
end
```

---

### `lurek.timer.sleep`

Blocks the current thread for the given number of seconds. Use sparingly — this halts the entire game loop. Intended for loading screens or synchronization.

```lua
-- signature
lurek.timer.sleep(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Duration to sleep in seconds. |

**Example**

```lua
do
    print("sleeping 0.01s...")
    lurek.timer.sleep(0.01)
    print("woke up")
end
```

---

### `lurek.timer.step`

Advances the internal clock by one tick and returns the delta time for that tick. Typically called by the engine loop; game scripts rarely need this.

```lua
-- signature
lurek.timer.step()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Delta time in seconds for the step. |

**Example**

```lua
do
    local dt = lurek.timer.step()
    print("stepped, dt = " .. dt)
end
```

---

### `lurek.timer.tickRealTimers`

Checks all real-time timers and fires any whose deadline has passed. Returns the number of callbacks that fired. Call this once per frame after afterReal scheduling.

```lua
-- signature
lurek.timer.tickRealTimers()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of real-time callbacks that fired. |

**Example**

```lua
do
    local fired = lurek.timer.tickRealTimers()
    print("real timers fired = " .. fired)
end
```

---

### `lurek.timer.tickWaits`

Checks all pending waitSeconds and waitFrames coroutines, resumes any whose deadline or frame target has been reached, and cleans up completed entries. Returns the number of coroutines that were resumed. Call once per frame.

```lua
-- signature
lurek.timer.tickWaits()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of coroutines resumed. |

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
    print("wait coroutine = " .. coroutine.status(co))
end
```

---

### `lurek.timer.waitFrames`

Yields the current coroutine for the given number of frames. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the target frame count has been reached.

```lua
-- signature
lurek.timer.waitFrames(frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frames` | `number` | Number of frames to wait. |

**Example**

```lua
do
    local co = coroutine.create(function() lurek.timer.waitFrames(1) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end
```

---

### `lurek.timer.waitSeconds`

Yields the current coroutine for the given number of real-time seconds. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the deadline has passed.

```lua
-- signature
lurek.timer.waitSeconds(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Real-time seconds to wait. |

**Example**

```lua
do
    local co = coroutine.create(function() lurek.timer.waitSeconds(0) end)
    coroutine.resume(co)
    lurek.timer.tickWaits()
    print("wait coroutine = " .. coroutine.status(co))
end
```

---

## LScheduler

### `LScheduler:after`

Schedules a one-shot callback to fire after the given delay in seconds. Returns an event ID that can be used to cancel, pause, or query the event.

```lua
-- signature
LScheduler:after(delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `delay` | `number` | Time in seconds before the callback fires. |
| `func` | `function` | Callback to invoke when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(0.5, function() end)
    print("scheduled id = " .. id)
end
```

---

### `LScheduler:afterFrames`

Schedules a one-shot callback to fire after the given number of frames. Returns an event ID for management.

```lua
-- signature
LScheduler:afterFrames(n, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of frames to wait before the callback fires. |
| `func` | `function` | Callback to invoke when the frame count elapses. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local fired_count = 0
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(3, function() fired_count = fired_count + 1 end)
    sched:updateFrames()
    sched:updateFrames()
    local fired = sched:updateFrames()
    print("frame events = " .. fired)
    print("callback count = " .. fired_count)
end
```

---

### `LScheduler:afterNamed`

Schedules a named one-shot callback after a delay in seconds. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for debouncing or resettable delays.

```lua
-- signature
LScheduler:afterNamed(name, delay, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this scheduled event. |
| `delay` | `number` | Time in seconds before the callback fires. |
| `func` | `function` | Callback to invoke when the delay elapses. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this scheduled callback. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    print("named timer scheduled")
end
```

---

### `LScheduler:cancel`

Cancels a scheduled event by its ID. Returns true if the event was found and removed, false if it did not exist.

```lua
-- signature
LScheduler:cancel(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID returned by after, every, or their variants. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event was found and cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(3.0, function() end)
    local id = sched:after(2.0, function() end)
    local ok = sched:cancel(id)
    print("cancel id = " .. tostring(ok))
    print("count after = " .. sched:getCount())
end
```

---

### `LScheduler:cancelAll`

Cancels all scheduled events in this scheduler and frees their callbacks. Returns the number of events that were removed.

```lua
-- signature
LScheduler:cancelAll()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of events that were cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:after(1.0, function() end)
    sched:after(2.0, function() end)
    sched:after(3.0, function() end)
    local removed = sched:cancelAll()
    print("cancelAll removed = " .. removed)
    print("empty = " .. tostring(sched:isEmpty()))
end
```

---

### `LScheduler:cancelNamed`

Cancels a named scheduled event. Returns true if the named event was found and removed.

```lua
-- signature
LScheduler:cancelNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The name used when scheduling with afterNamed or everyNamed. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the named event was found and cancelled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("save", 2.0, function() end)
    local cancelled = sched:cancelNamed("save")
    print("cancelled = " .. tostring(cancelled))
end
```

---

### `LScheduler:every`

Schedules a repeating callback that fires at a fixed interval in seconds. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.

```lua
-- signature
LScheduler:every(interval, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | `number` | Time in seconds between each invocation. |
| `func` | `function` | Callback to invoke on each interval tick. |
| `count?` | `number` | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this repeating callback. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:every(0.25, function() count = count + 1 end, 2)
    sched:update(0.25)
    sched:update(0.25)
    print("final count = " .. count)
end
```

---

### `LScheduler:everyFrames`

Schedules a repeating callback that fires every N frames. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.

```lua
-- signature
LScheduler:everyFrames(n, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of frames between each invocation. |
| `func` | `function` | Callback to invoke on each frame-interval tick. |
| `count?` | `number` | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this repeating callback. |

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
    print("frame ticks = " .. count)
end
```

---

### `LScheduler:everyNamed`

Schedules a named repeating callback at a fixed interval. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for restartable periodic effects like health regeneration or status ticks.

```lua
-- signature
LScheduler:everyNamed(name, interval, func, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for this repeating event. |
| `interval` | `number` | Time in seconds between each invocation. |
| `func` | `function` | Callback to invoke on each interval tick. |
| `count?` | `number` | Maximum number of times to fire. Defaults to -1 (infinite). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Unique event ID for this repeating callback. |

**Example**

```lua
do
    local count = 0
    local sched = lurek.timer.newScheduler()
    sched:everyNamed("regen", 1.0, function() count = count + 1 end)
    sched:update(1.0)
    sched:update(1.0)
    print("ticks = " .. count)
end
```

---

### `LScheduler:getCount`

Returns the total number of active scheduled events in this scheduler.

```lua
-- signature
LScheduler:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of active events. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    print("count=" .. sched:getCount())

    sched:after(1.0, function() print("after") end)
    print("count_after=" .. sched:getCount())
end
```

---

### `LScheduler:getInterval`

Returns the interval duration in seconds for a repeating event. The first return value indicates whether the event was found; the second is the interval (0.0 if not found).

```lua
-- signature
LScheduler:getInterval(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True if the event exists. |
| `number` | b Interval in seconds, or 0.0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found2, interval = sched:getInterval(id)
    print("interval = " .. interval)
end
```

---

### `LScheduler:getRemaining`

Returns the remaining time in seconds before the event fires. The first return value indicates whether the event was found; the second is the remaining time (0.0 if not found).

```lua
-- signature
LScheduler:getRemaining(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True if the event exists. |
| `number` | b Remaining time in seconds, or 0.0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found, remaining = sched:getRemaining(id)
    print("found = " .. tostring(found) .. ", remaining = " .. remaining)
end
```

---

### `LScheduler:getRepeatCount`

Returns the remaining repeat count for a repeating event. The first return value indicates whether the event was found; the second is the count (0 if not found). A value of -1 means infinite repeats.

```lua
-- signature
LScheduler:getRepeatCount(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True if the event exists. |
| `number` | b Remaining repeat count, or 0 if not found. |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    local found3, repeats = sched:getRepeatCount(id)
    print("repeat count = " .. repeats)
end
```

---

### `LScheduler:getTimeScale`

Returns the current time scale multiplier for this scheduler.

```lua
-- signature
LScheduler:getTimeScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current time scale (1.0 = normal speed). |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
end
```

---

### `LScheduler:isEmpty`

Returns true if the scheduler has no active events.

```lua
-- signature
LScheduler:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when no events are scheduled. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    print("empty=" .. tostring(sched:isEmpty()))
    sched:cancelAll()
    print("empty_after=" .. tostring(sched:isEmpty()))
end
```

---

### `LScheduler:isPaused`

Checks whether a scheduled event is currently paused.

```lua
-- signature
LScheduler:isPaused(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event is paused, false if running or not found. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
end
```

---

### `LScheduler:isPausedNamed`

Checks whether a named scheduled event is currently paused.

```lua
-- signature
LScheduler:isPausedNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the named event is paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
end
```

---

### `LScheduler:pause`

Pauses a scheduled event so it stops accumulating time. Returns true if the event was found and paused.

```lua
-- signature
LScheduler:pause(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to pause. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event exists and was paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    print("paused = " .. tostring(sched:isPaused(id)))
end
```

---

### `LScheduler:pauseNamed`

Pauses a named scheduled event. Returns true if the named event was found and paused.

```lua
-- signature
LScheduler:pauseNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the named event exists and was paused. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    print("paused_named=" .. tostring(sched:isPausedNamed("named_once")))
end
```

---

### `LScheduler:resetEvent`

Resets the elapsed time of a scheduled event back to zero, restarting its delay or interval countdown. Returns true if the event was found and reset.

```lua
-- signature
LScheduler:resetEvent(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to reset. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event was found and reset. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(0.5, function() end, 10)
    sched:update(0.3)
    sched:resetEvent(id)
    local found, remaining = sched:getRemaining(id)
    print("after reset, remaining = " .. remaining)
end
```

---

### `LScheduler:resume`

Resumes a previously paused event so it continues accumulating time. Returns true if the event was found and resumed.

```lua
-- signature
LScheduler:resume(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID to resume. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event exists and was resumed. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:after(1.0, function() end)
    sched:pause(id)
    sched:resume(id)
    print("resumed, paused = " .. tostring(sched:isPaused(id)))
end
```

---

### `LScheduler:resumeNamed`

Resumes a previously paused named event. Returns true if the named event was found and resumed.

```lua
-- signature
LScheduler:resumeNamed(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The name used when scheduling. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the named event exists and was resumed. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterNamed("named_once", 2.0, function() end)
    sched:pauseNamed("named_once")
    local resumed = sched:resumeNamed("named_once")
    print("resumeNamed ok = " .. tostring(resumed))
    print("paused_named = " .. tostring(sched:isPausedNamed("named_once")))
end
```

---

### `LScheduler:setInterval`

Changes the interval duration in seconds for an existing repeating event. Returns true if the event was found and updated.

```lua
-- signature
LScheduler:setInterval(id, interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Event ID of the repeating event. |
| `interval` | `number` | New interval duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the event was found and its interval updated. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    local id = sched:every(1.0, function() end)
    sched:setInterval(id, 0.5)
    print("interval changed to 0.5")
end
```

---

### `LScheduler:setTimeScale`

Sets the time scale multiplier for this scheduler. A value of 2.0 makes events fire twice as fast; 0.5 makes them fire at half speed. Does not affect frame-based events.

```lua
-- signature
LScheduler:setTimeScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | `number` | Time scale multiplier (1.0 = normal speed). |

**Example**

```lua
do
    ---@type LScheduler
    local sched = lurek.timer.newScheduler()
    sched:setTimeScale(2.0)
    print("time scale = " .. sched:getTimeScale())
end
```

---

### `LScheduler:type`

Returns the type name of this object as a string.

```lua
-- signature
LScheduler:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LScheduler". |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    print("type=" .. sched:type())
end
```

---

### `LScheduler:typeOf`

Checks whether this object matches the given type name. Accepts "LScheduler" or "Object".

```lua
-- signature
LScheduler:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    print("typeOf=" .. tostring(sched:typeOf("LScheduler")))
end
```

---

### `LScheduler:update`

Advances all time-based events by dt seconds, fires any callbacks whose delay has elapsed, and cleans up completed one-shot events. Call this once per frame with delta time. Returns the number of callbacks that fired.

```lua
-- signature
LScheduler:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds since the last update. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of callbacks that fired during this update. |

**Example**

```lua
do
    local fired = 0
    local sched = lurek.timer.newScheduler()
    sched:after(0.5, function() fired = fired + 1 end)
    sched:update(0.5)
    print("fired = " .. fired)
end
```

---

### `LScheduler:updateFrames`

Advances all frame-based events by one frame, fires any callbacks whose frame count has been reached, and cleans up completed one-shot events. Call this once per frame. Returns the number of callbacks that fired.

```lua
-- signature
LScheduler:updateFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of callbacks that fired during this frame update. |

**Example**

```lua
do
    local sched = lurek.timer.newScheduler()
    sched:afterFrames(1, function() end)
    print("frame events = " .. sched:updateFrames())
end
```

---
