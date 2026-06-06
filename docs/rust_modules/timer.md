# timer

## General Info

- Module group: `Core Runtime`
- Source path: `src/timer/`
- Binding: `src/lua_api/timer_api.rs`
- Namespace: `lurek.timer`
- Lua API surface: `21` functions, `1` types, `28` methods
- Rust test path(s): tests/rust/unit/timer_tests.rs, tests/fixtures/timer_api_fixture.rs, plus inline unit coverage in src/timer/scheduler.rs
- Lua test path(s): tests/lua/unit/test_timer.lua, tests/lua/stress/test_timer_stress.lua, tests/lua/integration/test_timer_math.lua, tests/lua/integration/test_physics_timer.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_animation_timer.lua

## Summary

This module serves as the core timing backbone for the game runtime, ensuring that delta times, elapsed sessions, and frame-rate calculations remain highly stable and precise. By integrating a drift-safe microsecond accumulator that retains fractional carry between updates, the system eliminates rounding errors over long sessions. Clocking metrics provide both raw delta times and smoothed averages, reducing frame jitter for movement interpolations.

For game physics and performance diagnostics, the module exposes robust timestep configurations and diagnostic tools. It manages fixed physics intervals alongside step limits to prevent performance degradations under heavy rendering loads. High-resolution benchmarking timers and rolling average FPS counters offer precise performance telemetry, while safe thread-sleeping wrappers block execution without wasting CPU cycles.

Finally, the subsystem includes a powerful scheduler for coordinating timed and frame-based callbacks. Developers can register one-shot, repeating, or named debouncing events, and control them using local time-scaling factors, pauses, and cancellations. This scheduling engine also coordinates coroutine yielding, letting gameplay scripts pause task execution for a specific duration or frame count before resuming.

## Files

### [accumulator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/timer/accumulator.rs)

- This file provides drift-safe microsecond accumulation for scaled runtime timekeeping.
- It preserves fractional carry between ticks so long sessions avoid rounding erosion.
- It clamps negative inputs to keep elapsed time monotonic and scheduler-safe.

### [clock.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/timer/clock.rs)

- This file provides the core frame clock that drives delta, elapsed time, and fps metrics.
- It computes stable per-frame timing and rolling averages for smoother runtime decisions.
- It maintains one-second fps windows so performance telemetry stays readable and comparable.
- It exposes one tick-driven timeline that other subsystems can trust each frame.
- It anchors deterministic game-loop timing for update, scheduling, and diagnostics paths.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/timer/mod.rs)

- This module delivers the runtime time backbone for clocks, accumulation, sleeping, and scheduling.
- It keeps frame progression measurable and controllable across gameplay and engine services.
- It unifies timing primitives so deferred logic behaves consistently under load.

### [scheduler.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/timer/scheduler.rs)

- This file provides a scheduler for time-based and frame-based deferred execution flows.
- It supports one-shot and repeating events with stable identifiers for external control.
- It handles named event replacement so restartable behaviors stay clean and predictable.
- It applies global time scaling while preserving safe clamping boundaries for runtime stability.
- It exposes pause, resume, interval mutation, and remaining-time inspection for live orchestration.
- It removes expired events efficiently to keep update costs steady at larger event counts.
- It serves as the central dispatch surface for timer callbacks used by Lua bindings.
- It keeps callback timing coherent even when many scheduled entries mutate concurrently.

### [sleep.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/timer/sleep.rs)

- This file provides the blocking sleep primitive used by timer-facing runtime code.
- It treats non-positive durations as no-op calls to preserve predictable behavior.
- It delegates to standard thread sleeping without busy waiting or spin loops.
