# timer

## General Info

- Module group: `Core Runtime`
- Source path: `src/timer/`
- Lua API path(s): `src/lua_api/timer_api.rs`
- Primary Lua namespace: `lurek.time`
- Rust test path(s): tests/rust/unit/timer_tests.rs, tests/fixtures/timer_api_fixture.rs, plus inline unit coverage in src/timer/scheduler.rs
- Lua test path(s): tests/lua/unit/test_timer.lua, tests/lua/stress/test_timer_stress.lua, tests/lua/integration/test_timer_math.lua, tests/lua/integration/test_physics_timer.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_animation_timer.lua

## Summary

The timer module owns Lurek2D's generic notion of time. It provides the frame clock used to derive delta time, total uptime, rolling FPS, and average frame duration, and it provides a standalone scheduler for delayed or repeating callbacks that can run at a caller-controlled time scale.

This module exists so time measurement and timer-driven behavior are consistent across the engine. `SharedState` keeps a `Clock` as the canonical per-frame timing source, while Lua scripts can create independent `Scheduler` instances for gameplay timing without having to implement their own event bookkeeping, repeat counts, pause state, or named timer replacement.

It intentionally does not own interpolation systems, animation state machines, or the engine's overall fixed-step orchestration. Tweening belongs in `tween`, animation playback belongs in `animation`, and the app loop decides when frame and physics callbacks run. The Lua wrapper in `src/lua_api/timer_api.rs` owns callback registry management; the core timer module only manages timing data and event IDs.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Core Runtime responsibility boundary defined in the architecture docs.

## Files

- `clock.rs`: `Clock` struct � frame delta, total time, FPS, and rolling average
- `mod.rs`: Re-exports `Clock` and `Scheduler`; provides free function `sleep()`
- `scheduler.rs`: `Scheduler` and `ScheduledEvent` � delayed and repeating events

## Types

- `Clock` (`struct`, `clock.rs`): Tracks per-frame delta time, accumulated total time, and a rolling FPS measurement.
- `ScheduledEvent` (`struct`, `scheduler.rs`): A single scheduled event with optional name and pause state.
- `Scheduler` (`struct`, `scheduler.rs`): Manages a collection of timed events (one-shot and repeating).

## Functions

- `Clock::new` (`clock.rs`): Creates a new `Clock`, recording the current instant as the start time.
- `Clock::tick` (`clock.rs`): Advances the clock by one frame, updating delta time, total time, and rolling FPS.
- `Clock::delta` (`clock.rs`): Returns the delta time for the most recently completed frame in seconds.
- `Clock::total` (`clock.rs`): Returns the total elapsed time since the clock was created, in seconds.
- `Clock::fps` (`clock.rs`): Returns the rolling frames-per-second measurement.
- `Clock::frame_count` (`clock.rs`): Returns the total number of frames that have elapsed since the clock was created.
- `Clock::elapsed` (`clock.rs`): Returns a live high-resolution elapsed time since the clock was created, in seconds.
- `Clock::average_delta` (`clock.rs`): Returns the average delta time over the last N frames (up to 60).
- `sleep` (`mod.rs`): Suspends the current thread for the given number of seconds.
- `Scheduler::new` (`scheduler.rs`): Create a new empty Scheduler with time-scale 1.0.
- `Scheduler::after` (`scheduler.rs`): Schedule a one-shot callback after `delay` seconds.
- `Scheduler::after_named` (`scheduler.rs`): Schedule a one-shot callback with a `name` for cancel-by-name support.
- `Scheduler::every` (`scheduler.rs`): Schedule a repeating callback at `interval` seconds.
- `Scheduler::every_named` (`scheduler.rs`): Schedule a named repeating callback.
- `Scheduler::cancel` (`scheduler.rs`): Cancel a scheduled event by its ID.
- `Scheduler::cancel_named` (`scheduler.rs`): Cancel a scheduled event by its name.
- `Scheduler::cancel_all` (`scheduler.rs`): Cancel all scheduled events.
- `Scheduler::pause` (`scheduler.rs`): Pause a single event by ID.
- `Scheduler::resume` (`scheduler.rs`): Resume a previously paused event by ID.
- `Scheduler::is_paused` (`scheduler.rs`): Returns `true` if the event with `id` is currently paused.
- `Scheduler::get_remaining` (`scheduler.rs`): Returns the time remaining until the next fire for event `id`, or `None` if not found.
- `Scheduler::get_interval` (`scheduler.rs`): Returns the base interval for event `id`, or `None` if not found.
- `Scheduler::get_repeat_count` (`scheduler.rs`): Returns the repeat count remaining for event `id` (-1 = infinite), or `None` if not found.
- `Scheduler::set_interval` (`scheduler.rs`): Change the interval of a repeating event.
- `Scheduler::reset_event` (`scheduler.rs`): Reset an event's remaining time to its original interval.
- `Scheduler::set_time_scale` (`scheduler.rs`): Set the global time-scale multiplier for this scheduler.
- `Scheduler::get_time_scale` (`scheduler.rs`): Returns the current global time-scale.
- `Scheduler::update` (`scheduler.rs`): Advance all non-paused timers by `dt * time_scale` seconds.
- `Scheduler::count` (`scheduler.rs`): Get the number of active (non-expired) scheduled events.
- `Scheduler::active_ids` (`scheduler.rs`): Get the IDs of all active events.
- `Scheduler::is_empty` (`scheduler.rs`): Returns `true` if no events are scheduled.

## Lua API Reference

- Binding path(s): `src/lua_api/timer_api.rs`
- Namespace: `lurek.time`

### Module Functions
- `lurek.timer.getDelta`: Returns the delta time in seconds for the current frame.
- `lurek.timer.getFPS`: Returns the current frames-per-second measurement.
- `lurek.timer.getTime`: Returns the total elapsed time since engine start in seconds.
- `lurek.timer.getAverageDelta`: Returns the rolling-average frame delta time in seconds.
- `lurek.timer.step`: Advances the timer by one frame, returning the delta time.
- `lurek.timer.getMicroTime`: Returns the high-resolution elapsed time since engine start in seconds.
- `lurek.timer.getPhysicsDelta`: Returns the fixed timestep used by `process_physics` callbacks (seconds).
- `lurek.timer.setPhysicsDelta`: Sets the fixed timestep for `process_physics` callbacks (seconds).
- `lurek.timer.sleep`: Suspends execution for the given number of seconds.
- `lurek.timer.newScheduler`: Creates a new independent Scheduler for managing timed callbacks.

### `Scheduler` Methods
- `Scheduler:after`: Schedules a callback to fire once after a delay.
- `Scheduler:cancel`: Cancels a scheduled event by its numeric ID.
- `Scheduler:cancelNamed`: Cancels a scheduled event by its string name.
- `Scheduler:cancelAll`: Cancels all scheduled events and returns the count removed.
- `Scheduler:pause`: Pauses a scheduled event by its ID.
- `Scheduler:resume`: Resumes a paused event by its ID.
- `Scheduler:isPaused`: Returns whether the given event is currently paused.
- `Scheduler:getRemaining`: Returns the seconds remaining until the next fire for an event, or nil.
- `Scheduler:getInterval`: Returns the base interval in seconds for an event, or nil.
- `Scheduler:getRepeatCount`: Returns the repeat count remaining for an event, or nil.
- `Scheduler:getCount`: Returns the number of active scheduled events.
- `Scheduler:isEmpty`: Returns whether the scheduler has no active events.
- `Scheduler:setInterval`: Changes the repeat interval of an existing event.
- `Scheduler:resetEvent`: Resets an event's remaining time back to its original interval.
- `Scheduler:setTimeScale`: Sets a global time-scale multiplier for this scheduler.
- `Scheduler:getTimeScale`: Returns the current time-scale multiplier.
- `Scheduler:update`: Advances all timers by dt seconds, firing due callbacks.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/timer/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
