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

At the core of the engine's main loop sits the `Clock`, which meticulously tracks per-frame delta time, accumulated total elapsed time, and a rolling frames-per-second (FPS) measurement. To ensure smooth gameplay and stable adaptive logic, it calculates a rolling average delta using a fixed-size ring buffer, which mitigates frame-time jitter. Furthermore, its internal microsecond accumulation employs fractional sub-microsecond carry, completely preventing time-drift errors across frames.

Beyond basic timekeeping, the module provides a highly versatile `Scheduler` for managing deferred and recurring logic. The scheduler handles both time-based (seconds) and frame-based (tick counts) events, offering one-shot and repeating modes. Events can be assigned string names, enabling automatic deduplication—where registering a new named event transparently cancels and replaces any existing event with the same name. Developers have fine-grained lifecycle control over scheduled events, with the ability to pause, resume, reset, or mutate the interval of active timers. Crucially, the scheduler supports a global time-scale multiplier, allowing developers to easily implement slow-motion or fast-forward effects that apply universally to all scheduled callbacks without affecting the underlying wall-clock timers.

The module also caters to diverse asynchronous scripting patterns. It provides real-time timers (`afterReal`) that bypass the global time-scale and game pauses, making them ideal for UI animations or system notifications. For coroutine-based scripting, the module offers `waitSeconds` and `waitFrames`, which yield the current coroutine and auto-resume it once the deadline passes, vastly simplifying complex sequence scripting. Supported by swap-remove compaction to maintain O(1) performance even with thousands of active timers, the `lurek.timer.*` API gives developers robust, high-performance control over the flow of time in their games.

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
