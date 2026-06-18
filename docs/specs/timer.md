# timer

## TL;DR

- Clock system with smoothed deltas, FPS telemetry, and schedulers for timed callbacks and coroutines.

## General Info

- Module group: `Core Runtime`
- Source path: `src/timer/`
- Binding: `src/lua_api/timer_api.rs`
- Namespace: `lurek.timer`
- Lua API surface: `21` functions, `1` types, `28` methods
- Rust test path(s): tests/rust/unit/timer_tests.rs, tests/fixtures/timer_api_fixture.rs, plus inline unit coverage in src/timer/scheduler.rs
- Lua test path(s): tests/lua/unit/test_timer.lua, tests/lua/stress/test_timer_stress.lua, tests/lua/integration/test_timer_math.lua, tests/lua/integration/test_physics_timer.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_animation_timer.lua

## Summary

- The `timer` module is the shared time-management surface for users who need clocks, delayed callbacks, repeating work, and timing queries to behave consistently.
- Clocks, accumulators, schedulers, and sleep helpers work together so the same module can cover frame deltas, elapsed-time tracking, wall-time waits, and callback scheduling.
- That matters because several systems rely on time, but they do not all need time in the same way; some need smooth frame metrics, others need deferred events, and others need accumulated timing without drift.
- Scheduling support is especially important because many features need explicit future work rather than only current elapsed time. Delayed callbacks, repeating intervals, and cancelable timer handles give gameplay and tooling code a structured way to express that work.
- Deterministic accumulation also matters for scripted sequences, cooldowns, UI feedback, analytics sampling, and automated tests where time should be queryable and comparable instead of buried in scattered frame math.
- The module is therefore useful both as a low-level clock source and as a coordination surface for anything that must happen later, repeatedly, or after a measured duration.
- That common layer also reduces drift between systems, because UI, gameplay, automation, and diagnostics can all schedule work against the same timing vocabulary.
- Read it as the common timing layer for the engine. Neighboring modules depend on time, but `timer` is where time becomes a reusable, queryable, and schedulable runtime resource.


## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### accumulator.rs

- `src/timer/accumulator.rs` owns the microsecond accumulation helper used to turn scaled frame deltas into stable totals.
- It clamps negative inputs, carries fractional micros forward, and updates elapsed counters without drift.
- Open this file when time-scaling math, drift behavior, or elapsed-microsecond accumulation rules need to change.

### clock.rs

- `src/timer/clock.rs` owns the frame clock that measures delta time, total elapsed time, frame count, and FPS.
- `Clock` stores both raw instants and derived metrics so the runtime can query current timing without recomputing it.
- `tick` updates one-second FPS windows and a rolling delta buffer, giving callers both live and averaged frame timing.
- This file is the owner of clock semantics such as elapsed-versus-total reporting and zero-state initialization behavior.
- Read it when frame measurement policy, FPS smoothing, or public timing queries for the runtime loop must change.

### mod.rs

- `src/timer/mod.rs` is the module index that exposes clocks, scheduling, sleep helpers, and accumulation support.
- It reexports `Clock`, `Scheduler`, and `sleep` so runtime code and Lua bindings consume one stable timing surface.
- No live timer state lives here; this file only declares child modules and chooses which timing symbols become public.
- Read this index when wiring frame progression, because it shows where clock metrics, delayed work, and sleeps are split.
- Changes here reshape the timing boundary, since reexports decide what engine code may import without deep module paths.
- This module keeps accumulation internals private while exposing the timing tools other engine systems are meant to use.

### scheduler.rs

- `src/timer/scheduler.rs` owns delayed and repeating timer events for both wall-time seconds and frame-count triggers.
- It defines `ScheduledEvent`, `FrameEvent`, and `Scheduler`, keeping timer data and control operations under one owner.
- Named scheduling, replacement, cancellation, pause, resume, interval mutation, and remaining-time queries live here.
- The scheduler applies a global time scale to second-based updates while frame-based events stay on counts.
- `update` and `update_frames` advance queues, emit fired IDs, and remove expired entries from both timer tracks.
- This file is where runtime timer policy lives; higher layers should treat it as the scheduling boundary.
- Open it when event lifetime rules, time-scale semantics, or timer-control APIs for gameplay orchestration need changes.

### sleep.rs

- `src/timer/sleep.rs` owns the blocking sleep helper used when runtime code needs wall-clock delay on the current thread.
- It intentionally stays minimal: non-positive durations are ignored, and positive values forward to `std::thread::sleep`.
- Read this file when blocking-delay semantics, no-op guards, or platform-facing sleep behavior need to change.



## Lua API Ref

### Functions

- `lurek.timer.afterReal(delay, func) -> nil`: Schedules a one-shot callback based on real (wall-clock) time, unaffected by game pausing or time scaling. Use for UI fade-outs, notifications, or anything that should run on real time.
- `lurek.timer.chain(steps) -> LScheduler`: Creates a scheduler pre-loaded with a sequence of delayed callbacks. Each step is a table with an optional `delay` (seconds) and optional `func` (callback). Delays accumulate so each step fires after the sum of all preceding delays. Returns the scheduler for manual update calls.
- `lurek.timer.getAverageDelta() -> number`: Returns the smoothed average delta time in seconds over a recent window of frames. More stable than getDelta for display or adaptive logic.
- `lurek.timer.getDelta() -> number`: Returns the time in seconds elapsed since the last frame. Use this to make movement and animations frame-rate independent.
- `lurek.timer.getFPS() -> number`: Returns the current frames-per-second count. Useful for performance monitoring overlays and debug HUDs.
- `lurek.timer.getFrameCount() -> integer`: Returns the total number of frames rendered since the engine started.
- `lurek.timer.getMicroTime() -> number`: Returns high-resolution elapsed time in seconds since engine start. Useful for precise benchmarking and profiling.
- `lurek.timer.getPhysicsDelta() -> number`: Returns the fixed timestep used for physics simulation in seconds. The default is typically 1/60.
- `lurek.timer.getPhysicsMaxSteps() -> number`: Returns the maximum number of physics steps allowed per frame. Prevents the spiral of death when the game runs slowly.
- `lurek.timer.getSmoothedDelta() -> number`: Returns an exponentially smoothed delta time in seconds, reducing frame-to-frame jitter. Call once per frame for consistent results. The smoothing factor is set via setSmoothingFactor.
- `lurek.timer.getTime() -> number`: Returns the total elapsed game time in seconds since the engine started. Useful for time-based animations, effects, and shader uniforms.
- `lurek.timer.newScheduler() -> LScheduler`: Creates a new LScheduler instance for managing timed and frame-based callbacks independently from the global timer. Each scheduler has its own time scale and event list.
- `lurek.timer.setPhysicsDelta(dt) -> nil`: Sets the fixed timestep for physics simulation. Clamped between 1/240 and 1/10 seconds. Lower values increase accuracy but cost more CPU.
- `lurek.timer.setPhysicsMaxSteps(n) -> nil`: Sets the maximum number of physics steps allowed per frame. Clamped between 1 and 64. Higher values improve accuracy under lag but cost more CPU.
- `lurek.timer.setSmoothingFactor(alpha) -> nil`: Sets the exponential smoothing factor used by getSmoothedDelta. Lower values produce smoother (more lagged) results; higher values track changes faster. Clamped to [0.01, 1.0].
- `lurek.timer.sleep(seconds) -> nil`: Blocks the current thread for the given number of seconds. Use sparingly â€” this halts the entire game loop. Intended for loading screens or synchronization.
- `lurek.timer.step() -> number`: Advances the internal clock by one tick and returns the delta time for that tick. Typically called by the engine loop; game scripts rarely need this.
- `lurek.timer.tickRealTimers() -> integer`: Checks all real-time timers and fires any whose deadline has passed. Returns the number of callbacks that fired. Call this once per frame after afterReal scheduling.
- `lurek.timer.tickWaits() -> integer`: Checks all pending waitSeconds and waitFrames coroutines, resumes any whose deadline or frame target has been reached, and cleans up completed entries. Returns the number of coroutines that were resumed. Call once per frame.
- `lurek.timer.waitFrames(frames) -> nil`: Yields the current coroutine for the given number of frames. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the target frame count has been reached.
- `lurek.timer.waitSeconds(seconds) -> nil`: Yields the current coroutine for the given number of real-time seconds. Must be called from within a coroutine. The coroutine is resumed automatically when tickWaits is called and the deadline has passed.

### Callbacks

- `LScheduler:after` param `func` (`function`): Callback to invoke when the delay elapses.
- `LScheduler:afterFrames` param `func` (`function`): Callback to invoke when the frame count elapses.
- `LScheduler:afterNamed` param `func` (`function`): Callback to invoke when the delay elapses.
- `LScheduler:every` param `func` (`function`): Callback to invoke on each interval tick.
- `LScheduler:everyFrames` param `func` (`function`): Callback to invoke on each frame-interval tick.
- `LScheduler:everyNamed` param `func` (`function`): Callback to invoke on each interval tick.
- `lurek.timer.afterReal` param `func` (`function`): Callback to invoke when the real-time deadline is reached.

### Enums

- No documented module-level enums/constants.

### Types

#### LScheduler Type

- A Lua-exposed event scheduler that fires callbacks after timed delays or frame counts, with support for repeating intervals, named entries, pausing, and time-scaling.

##### Fields

- No documented fields.

##### Methods

- `LScheduler:after(delay, func) -> integer`: Schedules a one-shot callback to fire after the given delay in seconds. Returns an event ID that can be used to cancel, pause, or query the event.
- `LScheduler:afterFrames(n, func) -> integer`: Schedules a one-shot callback to fire after the given number of frames. Returns an event ID for management.
- `LScheduler:afterNamed(name, delay, func) -> integer`: Schedules a named one-shot callback after a delay in seconds. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for debouncing or resettable delays.
- `LScheduler:cancel(id) -> boolean`: Cancels a scheduled event by its ID. Returns true if the event was found and removed, false if it did not exist.
- `LScheduler:cancelAll() -> integer`: Cancels all scheduled events in this scheduler and frees their callbacks. Returns the number of events that were removed.
- `LScheduler:cancelNamed(name) -> boolean`: Cancels a named scheduled event. Returns true if the named event was found and removed.
- `LScheduler:every(interval, func, count?) -> integer`: Schedules a repeating callback that fires at a fixed interval in seconds. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.
- `LScheduler:everyFrames(n, func, count?) -> integer`: Schedules a repeating callback that fires every N frames. Pass a positive count to limit repetitions, or omit/pass -1 to repeat indefinitely.
- `LScheduler:everyNamed(name, interval, func, count?) -> integer`: Schedules a named repeating callback at a fixed interval. If a callback with the same name already exists, the old one is cancelled and replaced. Useful for restartable periodic effects like health regeneration or status ticks.
- `LScheduler:getCount() -> integer`: Returns the total number of active scheduled events in this scheduler.
- `LScheduler:getInterval(id) -> boolean`: Returns the interval duration in seconds for a repeating event. The first return value indicates whether the event was found; the second is the interval (0.0 if not found).
- `LScheduler:getRemaining(id) -> boolean`: Returns the remaining time in seconds before the event fires. The first return value indicates whether the event was found; the second is the remaining time (0.0 if not found).
- `LScheduler:getRepeatCount(id) -> boolean`: Returns the remaining repeat count for a repeating event. The first return value indicates whether the event was found; the second is the count (0 if not found). A value of -1 means infinite repeats.
- `LScheduler:getTimeScale() -> number`: Returns the current time scale multiplier for this scheduler.
- `LScheduler:isEmpty() -> boolean`: Returns true if the scheduler has no active events.
- `LScheduler:isPaused(id) -> boolean`: Checks whether a scheduled event is currently paused.
- `LScheduler:isPausedNamed(name) -> boolean`: Checks whether a named scheduled event is currently paused.
- `LScheduler:pause(id) -> boolean`: Pauses a scheduled event so it stops accumulating time. Returns true if the event was found and paused.
- `LScheduler:pauseNamed(name) -> boolean`: Pauses a named scheduled event. Returns true if the named event was found and paused.
- `LScheduler:resetEvent(id) -> boolean`: Resets the elapsed time of a scheduled event back to zero, restarting its delay or interval countdown. Returns true if the event was found and reset.
- `LScheduler:resume(id) -> boolean`: Resumes a previously paused event so it continues accumulating time. Returns true if the event was found and resumed.
- `LScheduler:resumeNamed(name) -> boolean`: Resumes a previously paused named event. Returns true if the named event was found and resumed.
- `LScheduler:setInterval(id, interval) -> boolean`: Changes the interval duration in seconds for an existing repeating event. Returns true if the event was found and updated.
- `LScheduler:setTimeScale(scale) -> nil`: Sets the time scale multiplier for this scheduler. A value of 2.0 makes events fire twice as fast; 0.5 makes them fire at half speed. Does not affect frame-based events.
- `LScheduler:type() -> string`: Returns the type name of this object as a string.
- `LScheduler:typeOf(name) -> boolean`: Checks whether this object matches the given type name. Accepts "LScheduler" or "Object".
- `LScheduler:update(dt) -> integer`: Advances all time-based events by dt seconds, fires any callbacks whose delay has elapsed, and cleans up completed one-shot events. Call this once per frame with delta time. Returns the number of callbacks that fired.
- `LScheduler:updateFrames() -> integer`: Advances all frame-based events by one frame, fires any callbacks whose frame count has been reached, and cleans up completed one-shot events. Call this once per frame. Returns the number of callbacks that fired.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
