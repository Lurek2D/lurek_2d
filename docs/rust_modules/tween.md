# tween

## General Info

- Module group: `Feature Systems`
- Source path: `src/tween/`
- Binding: `src/lua_api/tween_api.rs`
- Namespace: `lurek.tween`
- Lua API surface: `15` functions, `6` types, `82` methods
- Rust test path(s): tests/rust/unit/tween_tests.rs
- Lua test path(s): tests/lua/unit/test_tween.lua, tests/lua/stress/test_tween_stress.lua, tests/lua/integration/test_tween_ecs.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tween_animation.lua

## Summary

It provides a robust engine for animating numeric properties over time, making it ideal for UI transitions, camera movements, and gameplay juice. At its core, `LuaTween` interpolates a single numeric property (or multiple numeric fields on a single Lua table) from a start value to a target value over a specified duration. Developers can choose from over 30 built-in easing curves—including linear, quadratic, cubic, elastic, bounce, and back—or register custom easing functions to achieve the exact feel required. Tweens support full lifecycle callbacks (`onUpdate`, `onComplete`, `onCancel`) and can be configured to repeat infinitely, yoyo (reverse direction on repeat), or operate in relative mode where targets act as offsets.

To handle complex animation choreography, the module provides powerful combinators. `LuaTweenSequence` enables the chaining of multiple tweens, delays, and callbacks into an ordered execution pipeline, where each step seamlessly transitions to the next while carrying over leftover frame delta time. Conversely, `LuaTweenParallel` groups multiple tweens together, executing them simultaneously and completing only when the longest-running child finishes. For a more organic, physics-driven feel, `SpringSystem` offers damped spring interpolation with configurable stiffness and damping. This eliminates fixed durations in favor of natural settling dynamics, which is particularly effective for responsive UI elements or following camera logic.

The entire system is driven by a centralized `TweenEngine` that efficiently updates all active tweens, sequences, parallels, and springs every frame. The module is fully integrated with Lua coroutines via the `await()` method, allowing developers to yield execution until an animation completes, drastically simplifying sequential scripting without callback hell. Exposed via the comprehensive `lurek.tween.*` Lua API, this module is an essential tool for bringing fluid, polished motion to Lurek2D games.

## Files

### [chain.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/chain.rs)

- This file provides composable tween chains for staged motion and timing choreography.
- It supports sequential and grouped progression so animation beats can be orchestrated clearly.
- It carries optional step labels that let scripts react to completion boundaries.
- It advances with frame delta while preserving deterministic chain state transitions.
- It translates complex cinematic timing into a readable structure for runtime execution.
- It keeps multi-step animation flow explicit for tools, debugging, and script control.

### [engine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/engine.rs)

- This file provides the active tween engine that updates all running animation handles.
- It tracks tweens, sequences, parallels, and springs through one coordinated update surface.
- It resolves easing behavior and value writes directly onto Lua-owned target tables.
- It manages lifecycle cleanup so completed animations exit without stale runtime state.
- It keeps tween progression synchronous with frame updates for deterministic visual output.

### [handle.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/handle.rs)

- This file provides Lua-facing tween handle types that expose animation control to scripts.
- It defines single tweens, sequences, and parallel groups with a consistent lifecycle contract.
- It stores progression state, target bindings, and callback hooks close to each animation unit.
- It writes interpolated values to Lua tables each frame through explicit field mappings.
- It supports repeat, yoyo, relative targets, and custom easing for expressive motion design.
- It coordinates sequence boundaries with carry-over delta to avoid timing gaps between steps.
- It advances parallel lanes together and resolves completion only when all lanes settle.
- It resumes waiting coroutines on completion so asynchronous script flow stays ergonomic.

### [interpolator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/interpolator.rs)

- This file provides the multi-channel interpolator that converts progress into animated values.
- It resolves easing names through flexible aliases so script-facing naming remains forgiving.
- It keeps independent tween clocks with reset and seek support for controlled playback.
- It interpolates registered channels each frame using the resolved easing curve semantics.
- It falls back to linear behavior when easing names are unknown to preserve continuity.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/mod.rs)

- This module delivers the motion interpolation stack used for scripted and systemic animation.
- It combines timed easing, spring dynamics, and composition primitives in one cohesive surface.
- It gives the runtime one predictable path for updating all active tween workflows.

### [spring.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/spring.rs)

- This file provides damped spring simulation for motion that should feel physical and responsive.
- It models spring parameters and settle rules so values converge smoothly toward targets.
- It groups named spring axes under shared defaults for coordinated multi-field behaviors.
- It integrates state each tick and snaps on settle to remove micro-jitter residue.
- It offers a natural animation path where fixed-duration easing is not a good fit.

### [state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tween/state.rs)

- This file provides canonical tween progress state shared across animation handle types.
- It tracks elapsed time, duration, pause state, and resolved easing behavior in one unit.
- It resolves easing names case-insensitively with aliases that match common script habits.
- It exposes built-in easing catalog data for tooling, validation, and autocomplete features.
- It keeps progress semantics stable so tween updates remain deterministic across runtime paths.
