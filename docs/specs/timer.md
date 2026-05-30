# timer

## TL;DR

- The `timer` module is a fundamental Core Runtime tier component responsible for precise frame timing, fixed-step accumulation, and deferred callback scheduling.

## General Info

- Module group: `Core Runtime`
- Source path: `src/timer/`
- Lua API path(s): `src/lua_api/timer_api.rs`
- Primary Lua namespace: `lurek.timer`
- Rust test path(s): tests/rust/unit/timer_tests.rs, tests/fixtures/timer_api_fixture.rs, plus inline unit coverage in src/timer/scheduler.rs
- Lua test path(s): tests/lua/unit/test_timer.lua, tests/lua/stress/test_timer_stress.lua, tests/lua/integration/test_timer_math.lua, tests/lua/integration/test_physics_timer.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_animation_timer.lua

## Summary

At the core of the engine's main loop sits the `Clock`, which meticulously tracks per-frame delta time, accumulated total elapsed time, and a rolling frames-per-second (FPS) measurement. To ensure smooth gameplay and stable adaptive logic, it calculates a rolling average delta using a fixed-size ring buffer, which mitigates frame-time jitter. Furthermore, its internal microsecond accumulation employs fractional sub-microsecond carry, completely preventing time-drift errors across frames.

Beyond basic timekeeping, the module provides a highly versatile `Scheduler` for managing deferred and recurring logic. The scheduler handles both time-based (seconds) and frame-based (tick counts) events, offering one-shot and repeating modes. Events can be assigned string names, enabling automatic deduplication—where registering a new named event transparently cancels and replaces any existing event with the same name. Developers have fine-grained lifecycle control over scheduled events, with the ability to pause, resume, reset, or mutate the interval of active timers. Crucially, the scheduler supports a global time-scale multiplier, allowing developers to easily implement slow-motion or fast-forward effects that apply universally to all scheduled callbacks without affecting the underlying wall-clock timers.

The module also caters to diverse asynchronous scripting patterns. It provides real-time timers (`afterReal`) that bypass the global time-scale and game pauses, making them ideal for UI animations or system notifications. For coroutine-based scripting, the module offers `waitSeconds` and `waitFrames`, which yield the current coroutine and auto-resume it once the deadline passes, vastly simplifying complex sequence scripting. Supported by swap-remove compaction to maintain O(1) performance even with thousands of active timers, the `lurek.timer.*` API gives developers robust, high-performance control over the flow of time in their games.

## Files

### accumulator.rs

- This file provides drift-safe microsecond accumulation for scaled runtime timekeeping.
- It preserves fractional carry between ticks so long sessions avoid rounding erosion.
- It clamps negative inputs to keep elapsed time monotonic and scheduler-safe.

### clock.rs

- This file provides the core frame clock that drives delta, elapsed time, and fps metrics.
- It computes stable per-frame timing and rolling averages for smoother runtime decisions.
- It maintains one-second fps windows so performance telemetry stays readable and comparable.
- It exposes one tick-driven timeline that other subsystems can trust each frame.
- It anchors deterministic game-loop timing for update, scheduling, and diagnostics paths.

### mod.rs

- This module delivers the runtime time backbone for clocks, accumulation, sleeping, and scheduling.
- It keeps frame progression measurable and controllable across gameplay and engine services.
- It unifies timing primitives so deferred logic behaves consistently under load.

### scheduler.rs

- This file provides a scheduler for time-based and frame-based deferred execution flows.
- It supports one-shot and repeating events with stable identifiers for external control.
- It handles named event replacement so restartable behaviors stay clean and predictable.
- It applies global time scaling while preserving safe clamping boundaries for runtime stability.
- It exposes pause, resume, interval mutation, and remaining-time inspection for live orchestration.
- It removes expired events efficiently to keep update costs steady at larger event counts.
- It serves as the central dispatch surface for timer callbacks used by Lua bindings.
- It keeps callback timing coherent even when many scheduled entries mutate concurrently.

### sleep.rs

- This file provides the blocking sleep primitive used by timer-facing runtime code.
- It treats non-positive durations as no-op calls to preserve predictable behavior.
- It delegates to standard thread sleeping without busy waiting or spin loops.

## Lua API Ref

- Binding: `src/lua_api/timer_api.rs`
- Namespace: `lurek.timer`

### Functions

- `lurek.timer.afterReal`: Schedules a one-shot callback based on real (wall-clock) time, unaffected by game pausing or time scaling. Use for UI fade-outs, notifications, or anything that should run on real time.
- `lurek.timer.chain`: Creates a scheduler pre-loaded with a sequence of delayed callbacks. Each step is a table with an optional `delay` (seconds) and optional `func` (callback). Delays accumulate so each step fires after the sum of all preceding delays. Returns the scheduler for manual update calls.
- `lurek.timer.getAverageDelta`: Returns the smoothed average delta time in seconds over a recent window of frames. More stable than getDelta for display or adaptive logic.
- `lurek.timer.getDelta`: Returns the time in seconds elapsed since the last frame. Use this to make movement and animations frame-rate independent.
- `lurek.timer.getFPS`: Returns the current frames-per-second count. Useful for performance monitoring overlays and debug HUDs.
- `lurek.timer.getFrameCount`: Returns the total number of frames rendered since the engine started.
- `lurek.timer.getMicroTime`: Returns high-resolution elapsed time in seconds since engine start. Useful for precise benchmarking and profiling.
- `lurek.timer.getPhysicsDelta`: Returns the fixed timestep used for physics simulation in seconds. The default is typically 1/60.
- `lurek.timer.getPhysicsMaxSteps`: Returns the maximum number of physics steps allowed per frame. Prevents the spiral of death when the game runs slowly.
- `lurek.timer.getSmoothedDelta`: Returns an exponentially smoothed delta time in seconds, reducing frame-to-frame jitter. Call once per frame for consistent results. The smoothing factor is set via setSmoothingFactor.
- `lurek.timer.getTime`: Returns the total elapsed game time in seconds since the engine started. Useful for time-based animations, effects, and shader uniforms.
- `lurek.timer.newScheduler`: Creates a new LScheduler instance for managing timed and frame-based callbacks independently from the global timer. Each scheduler has its own time scale and event list.
- `lurek.timer.setPhysicsDelta`: Sets the fixed timestep for physics simulation. Clamped between 1/240 and 1/10 seconds. Lower values increase accuracy but cost more CPU.
- `lurek.timer.setPhysicsMaxSteps`: Sets the maximum number of physics steps allowed per frame. Clamped between 1 and 64. Higher values improve accuracy under lag but cost more CPU.
- `lurek.timer.setSmoothingFactor`: Sets the exponential smoothing factor used by getSmoothedDelta. Lower values produce smoother (more lagged) results; higher values track changes faster. Clamped to [0.01, 1.0].
- `lurek.timer.sleep`: Blocks the current thread for the given number of seconds. Use sparingly — this halts the entire game loop. Intended for loading screens or synchronization.
- `lurek.timer.step`: Advances the internal clock by one tick and returns the delta time for that tick. Typically called by the engine loop; game scripts rarely need this.
- `lurek.timer.tickRealTimers`: Checks all real-time timers and fires any whose deadline has passed. Returns the number of callbacks that fired. Call this once per frame after afterReal scheduling.
- `lurek.timer.tickWaits`: Checks all pending waitSeconds and waitFrames coroutines, resumes any whose deadline or frame target has been reached, and cleans up completed entries. Returns the number of coroutines that were resumed. Call once per frame.
- `lurek.timer.waitFrames`: Yields the current coroutine for the given number of frames. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the target frame count has been reached.
- `lurek.timer.waitSeconds`: Yields the current coroutine for the given number of real-time seconds. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the deadline has passed.

### Enums

- No documented module-level enums/constants.

### Types

#### LScheduler Type

- A Lua-exposed event scheduler that fires callbacks after timed delays or frame counts, with support for repeating intervals, named entries, pausing, and time-scaling.

##### Fields

- No documented fields.

##### Methods

- `LScheduler:after`: Schedules a one-shot callback to fire after the given delay in seconds. Returns an event ID that can be used to cancel, pause, or query the event.
- `LScheduler:afterFrames`: Schedules a one-shot callback to fire after the given number of frames. Returns an event ID for management.
- `LScheduler:afterNamed`: Schedules a named one-shot callback after a delay in seconds. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for debouncing or resettable delays.
- `LScheduler:cancel`: Cancels a scheduled event by its ID. Returns true if the event was found and removed, false if it did not exist.
- `LScheduler:cancelAll`: Cancels all scheduled events in this scheduler and frees their callbacks. Returns the number of events that were removed.
- `LScheduler:cancelNamed`: Cancels a named scheduled event. Returns true if the named event was found and removed.
- `LScheduler:every`: Schedules a repeating callback that fires at a fixed interval in seconds. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.
- `LScheduler:everyFrames`: Schedules a repeating callback that fires every N frames. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.
- `LScheduler:everyNamed`: Schedules a named repeating callback at a fixed interval. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for restartable periodic effects like health regeneration or status ticks.
- `LScheduler:getCount`: Returns the total number of active scheduled events in this scheduler.
- `LScheduler:getInterval`: Returns the interval duration in seconds for a repeating event. The first return value indicates whether the event was found; the second is the interval (0.0 if not found).
- `LScheduler:getRemaining`: Returns the remaining time in seconds before the event fires. The first return value indicates whether the event was found; the second is the remaining time (0.0 if not found).
- `LScheduler:getRepeatCount`: Returns the remaining repeat count for a repeating event. The first return value indicates whether the event was found; the second is the count (0 if not found). A value of -1 means infinite repeats.
- `LScheduler:getTimeScale`: Returns the current time scale multiplier for this scheduler.
- `LScheduler:isEmpty`: Returns true if the scheduler has no active events.
- `LScheduler:isPaused`: Checks whether a scheduled event is currently paused.
- `LScheduler:isPausedNamed`: Checks whether a named scheduled event is currently paused.
- `LScheduler:pause`: Pauses a scheduled event so it stops accumulating time. Returns true if the event was found and paused.
- `LScheduler:pauseNamed`: Pauses a named scheduled event. Returns true if the named event was found and paused.
- `LScheduler:resetEvent`: Resets the elapsed time of a scheduled event back to zero, restarting its delay or interval countdown. Returns true if the event was found and reset.
- `LScheduler:resume`: Resumes a previously paused event so it continues accumulating time. Returns true if the event was found and resumed.
- `LScheduler:resumeNamed`: Resumes a previously paused named event. Returns true if the named event was found and resumed.
- `LScheduler:setInterval`: Changes the interval duration in seconds for an existing repeating event. Returns true if the event was found and updated.
- `LScheduler:setTimeScale`: Sets the time scale multiplier for this scheduler. A value of 2.0 makes events fire twice as fast; 0.5 makes them fire at half speed. Does not affect frame-based events.
- `LScheduler:type`: Returns the type name of this object as a string.
- `LScheduler:typeOf`: Checks whether this object matches the given type name. Accepts "LScheduler" or "Object".
- `LScheduler:update`: Advances all time-based events by dt seconds, fires any callbacks whose delay has elapsed, and cleans up completed one-shot events. Call this once per frame with delta time. Returns the number of callbacks that fired.
- `LScheduler:updateFrames`: Advances all frame-based events by one frame, fires any callbacks whose frame count has been reached, and cleans up completed one-shot events. Call this once per frame. Returns the number of callbacks that fired.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
