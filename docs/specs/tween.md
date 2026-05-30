# tween

## TL;DR

- The `tween` module is a versatile Feature Systems tier component responsible for smooth value interpolation, easing, and spring-physics animations.

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

## Imports

- `math`: Imports or references `math` from `src/math/`.

## Files

### chain.rs

- This file provides composable tween chains for staged motion and timing choreography.
- It supports sequential and grouped progression so animation beats can be orchestrated clearly.
- It carries optional step labels that let scripts react to completion boundaries.
- It advances with frame delta while preserving deterministic chain state transitions.
- It translates complex cinematic timing into a readable structure for runtime execution.
- It keeps multi-step animation flow explicit for tools, debugging, and script control.

### engine.rs

- This file provides the active tween engine that updates all running animation handles.
- It tracks tweens, sequences, parallels, and springs through one coordinated update surface.
- It resolves easing behavior and value writes directly onto Lua-owned target tables.
- It manages lifecycle cleanup so completed animations exit without stale runtime state.
- It keeps tween progression synchronous with frame updates for deterministic visual output.

### handle.rs

- This file provides Lua-facing tween handle types that expose animation control to scripts.
- It defines single tweens, sequences, and parallel groups with a consistent lifecycle contract.
- It stores progression state, target bindings, and callback hooks close to each animation unit.
- It writes interpolated values to Lua tables each frame through explicit field mappings.
- It supports repeat, yoyo, relative targets, and custom easing for expressive motion design.
- It coordinates sequence boundaries with carry-over delta to avoid timing gaps between steps.
- It advances parallel lanes together and resolves completion only when all lanes settle.
- It resumes waiting coroutines on completion so asynchronous script flow stays ergonomic.

### interpolator.rs

- This file provides the multi-channel interpolator that converts progress into animated values.
- It resolves easing names through flexible aliases so script-facing naming remains forgiving.
- It keeps independent tween clocks with reset and seek support for controlled playback.
- It interpolates registered channels each frame using the resolved easing curve semantics.
- It falls back to linear behavior when easing names are unknown to preserve continuity.

### mod.rs

- This module delivers the motion interpolation stack used for scripted and systemic animation.
- It combines timed easing, spring dynamics, and composition primitives in one cohesive surface.
- It gives the runtime one predictable path for updating all active tween workflows.

### spring.rs

- This file provides damped spring simulation for motion that should feel physical and responsive.
- It models spring parameters and settle rules so values converge smoothly toward targets.
- It groups named spring axes under shared defaults for coordinated multi-field behaviors.
- It integrates state each tick and snaps on settle to remove micro-jitter residue.
- It offers a natural animation path where fixed-duration easing is not a good fit.

### state.rs

- This file provides canonical tween progress state shared across animation handle types.
- It tracks elapsed time, duration, pause state, and resolved easing behavior in one unit.
- It resolves easing names case-insensitively with aliases that match common script habits.
- It exposes built-in easing catalog data for tooling, validation, and autocomplete features.
- It keeps progress semantics stable so tween updates remain deterministic across runtime paths.

## Lua API Ref

### Functions

- `lurek.tween.cancelAll`: Immediately cancels all active tweens, sequences, parallels, and springs managed by the tween engine.
- `lurek.tween.delay`: Creates a one-shot delay. After the specified seconds elapse, the optional callback is invoked.
- `lurek.tween.getActiveCount`: Returns the total number of currently active tweens, sequences, and parallels.
- `lurek.tween.getEasingNames`: Returns an array of all available easing function names, including both built-in and custom-registered easings.
- `lurek.tween.newChain`: Creates a sequential tween chain for cinematic value-interpolation sequences.
- `lurek.tween.newState`: Creates a standalone tween state for manual interpolation. Useful when you need eased progress without automatic property updates.
- `lurek.tween.parallel`: Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.
- `lurek.tween.registerEasing`: Registers a custom easing function by name. The function receives a progress value (0..1) and must return an eased value.
- `lurek.tween.sequence`: Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.
- `lurek.tween.spring`: Creates a spring-physics animation that smoothly drives table fields toward target values with bounce and settle behavior.
- `lurek.tween.to`: Creates and starts a property tween with a different parameter order: target first, then fields, duration, easing.
- `lurek.tween.tween`: Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.
- `lurek.tween.tweenChain`: Creates a sequence from a table of step descriptors. Each step is a table with `duration`, `target`, `fields`, optional `easing`, optional `callback`, or a `delay` key for pauses.
- `lurek.tween.tweenColor`: Creates and starts a color tween that smoothly interpolates r, g, b, and/or a fields on the target table.
- `lurek.tween.update`: Advances all active tweens, sequences, parallels, and springs by the given delta time. Call once per frame.

### Callbacks

- `LTween:onCancel` param `f` (`function`): Callback fired when the tween is cancelled.
- `LTween:onComplete` param `f` (`function`): Callback fired when the tween finishes.
- `LTween:onUpdate` param `f` (`function`): Callback fired each frame with the current progress `t` (0..1).
- `LTweenChain:call` param `fn` (`function`): Callback to execute.
- `LTweenChain:onComplete` param `fn` (`function`): Completion callback.
- `LTweenChain:onLoop` param `fn` (`function`): Callback receiving iteration number.
- `LTweenChain:wait` param `callback` (`function?`): Optional callback fired after wait.
- `LTweenParallel:onComplete` param `f` (`function`): Function to call when all tweens in the group complete.
- `LTweenSequence:callback` param `f` (`function`): Function called when this step is reached during playback.
- `LTweenSequence:delay` param `cb` (`function?`): Optional callback fired when the delay elapses.
- `LTweenSequence:onComplete` param `f` (`function`): Function to call when the sequence completes.
- `lurek.tween.delay` param `cb` (`function?`): Optional callback fired when the delay completes.
- `lurek.tween.registerEasing` param `f` (`function`): Easing function `f(t) -> number` where t is 0..1.

### Enums

- No documented module-level enums/constants.

### Types

#### LSpring Type

- Lua-exposed spring physics simulation that smoothly animates table fields toward target values with configurable stiffness and damping.

##### Fields

- No documented fields.

##### Methods

- `LSpring:cancel`: Cancels this spring animation and cleans up the on-settle callback if one was registered.
- `LSpring:getPosition`: Returns the current position of the given spring axis, or `nil` if the axis does not exist.
- `LSpring:isActive`: Returns whether this spring is still actively animating.
- `LSpring:isSettled`: Returns whether all spring axes have reached their targets within the precision threshold.
- `LSpring:setDamping`: Sets the spring damping for all axes. Higher values reduce oscillation and overshoot.
- `LSpring:setStiffness`: Sets the spring stiffness for all axes. Higher values make the spring snap faster.
- `LSpring:setTarget`: Changes the spring target values for one or more axes. Re-activates the spring if it was settled.
- `LSpring:type`: Returns the type name of this object.
- `LSpring:typeOf`: Checks whether this object matches the given type name.
- `LSpring:update`: Manually advances this spring by the given delta time and writes updated positions to the target table. Returns `true` if still animating, `false` if settled.

#### LTween Type

- Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.

##### Fields

- No documented fields.

##### Methods

- `LTween:await`: Yields the current coroutine until this tween completes or is cancelled. Must be called from inside a coroutine.
- `LTween:cancel`: Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it.
- `LTween:getDuration`: Returns the total duration of this tween in seconds.
- `LTween:getElapsed`: Returns the number of seconds that have elapsed since the tween started.
- `LTween:getFields`: Returns an array of field names being tweened on the target table.
- `LTween:getProgress`: Returns the eased progress of this tween as a value from 0.0 to 1.0.
- `LTween:getRemaining`: Returns the number of seconds remaining until this tween completes.
- `LTween:isActive`: Returns whether this tween is still running (not cancelled or completed).
- `LTween:onCancel`: Sets a callback to fire when the tween is cancelled. Returns the tween for chaining.
- `LTween:onComplete`: Sets a callback to fire when the tween completes. Returns the tween for chaining.
- `LTween:onUpdate`: Sets a callback to fire every frame while the tween is active. Returns the tween for chaining.
- `LTween:pause`: Pauses this tween so it stops advancing until resumed.
- `LTween:relative`: Chainable version of `setRelative`. Returns the tween for fluent API usage.
- `LTween:resume`: Resumes a paused tween so it continues advancing.
- `LTween:setRelative`: Sets whether the tween end values are relative to the start values instead of absolute.
- `LTween:setRepeat`: Sets how many times the tween should repeat after the first play. Use -1 for infinite repeat.
- `LTween:setYoyo`: Enables or disables yoyo mode, which reverses the tween direction on each repeat cycle.
- `LTween:type`: Returns the type name of this object.
- `LTween:typeOf`: Checks whether this object matches the given type name.

#### LTweenChain Type

- Lua-side wrapper for a sequential tween chain.

##### Fields

- No documented fields.

##### Methods

- `LTweenChain:call`: Adds a fluent callback step that executes once at this point in the chain.
- `LTweenChain:clear`: Clears all fluent and legacy steps.
- `LTweenChain:cursor`: Returns one-based current legacy step index.
- `LTweenChain:getIteration`: Returns current iteration number.
- `LTweenChain:getProgress`: Returns normalized fluent chain progress in range `[0, 1]`.
- `LTweenChain:isActive`: Returns whether fluent playback is active.
- `LTweenChain:isComplete`: Returns whether fluent playback reached final completion.
- `LTweenChain:isFinished`: Returns whether legacy playback reached completion for the active pass.
- `LTweenChain:isLooping`: Returns whether chain is in infinite loop mode.
- `LTweenChain:jumpTo`: Jumps legacy chain cursor to given one-based step.
- `LTweenChain:len`: Returns legacy step count currently stored in this tween chain.
- `LTweenChain:loop`: Sets fluent loop count where `0` means infinite looping behavior.
- `LTweenChain:onComplete`: Sets callback fired after the final fluent pass fully completes.
- `LTweenChain:onLoop`: Sets callback fired when entering the next fluent loop iteration.
- `LTweenChain:pause`: Pauses fluent playback while preserving timeline progress and cursor state.
- `LTweenChain:push`: Appends a legacy scalar step to the compatibility chain.
- `LTweenChain:reset`: Resets both fluent and legacy playback cursors.
- `LTweenChain:resume`: Resumes fluent playback from the previously paused timeline position.
- `LTweenChain:setLooping`: Enables/disables infinite loop compatibility mode.
- `LTweenChain:start`: Starts fluent chain playback and registers this chain in the update queue.
- `LTweenChain:stop`: Stops fluent playback and leaves the chain ready for a later restart.
- `LTweenChain:tick`: Advances the legacy scalar chain and returns completion events.
- `LTweenChain:to`: Adds a fluent tween step to this chain.
- `LTweenChain:type`: Returns the Lua-visible type name.
- `LTweenChain:typeOf`: Returns whether this handle matches the given type name.
- `LTweenChain:value`: Returns current legacy scalar value.
- `LTweenChain:wait`: Adds a fluent delay step to the chain timeline and keeps fluent chaining enabled.

#### LTweenParallel Type

- Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.

##### Fields

- No documented fields.

##### Methods

- `LTweenParallel:add`: Adds an existing tween handle to this parallel group. The tween becomes owned by the group.
- `LTweenParallel:cancel`: Cancels all tweens in this parallel group immediately.
- `LTweenParallel:isActive`: Returns whether this parallel group is still running.
- `LTweenParallel:onComplete`: Sets a callback to fire when all tweens in this parallel group have finished. Returns the group for chaining.
- `LTweenParallel:start`: Starts all tweens in this parallel group simultaneously.
- `LTweenParallel:tween`: Creates and adds a new tween step directly to this parallel group.
- `LTweenParallel:type`: Returns the type name of this object.
- `LTweenParallel:typeOf`: Checks whether this object matches the given type name.

#### LTweenSequence Type

- Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.

##### Fields

- No documented fields.

##### Methods

- `LTweenSequence:await`: Yields the current coroutine until this sequence completes or is cancelled. Must be called from inside a coroutine.
- `LTweenSequence:callback`: Appends a callback step to this sequence that fires when reached during playback.
- `LTweenSequence:cancel`: Cancels this sequence immediately and resumes any coroutines waiting on it.
- `LTweenSequence:delay`: Appends a delay step to this sequence. Optionally fires a callback when the delay elapses.
- `LTweenSequence:getProgress`: Returns the overall progress ratio of this sequence from 0.0 to 1.0.
- `LTweenSequence:isActive`: Returns whether this sequence is still running.
- `LTweenSequence:onComplete`: Sets a callback to fire when the sequence finishes all steps. Returns the sequence for chaining.
- `LTweenSequence:start`: Starts playback of this sequence from the first step.
- `LTweenSequence:tween`: Appends a tween step to this sequence that animates numeric fields on the target table.
- `LTweenSequence:type`: Returns the type name of this object.
- `LTweenSequence:typeOf`: Checks whether this object matches the given type name.

#### LTweenState Type

- Lua-exposed standalone tween state for manual interpolation without automatic property updates.

##### Fields

- `paused` (`any`): Lua-visible field.

##### Methods

- `LTweenState:isComplete`: Returns whether this tween state has finished its full duration.
- `LTweenState:lerp`: Linearly interpolates between two values using the current eased progress.
- `LTweenState:reset`: Resets the tween state to the beginning so it can be replayed.
- `LTweenState:t`: Returns the raw (un-eased) progress value from 0.0 to 1.0.
- `LTweenState:tick`: Advances the tween state by the given delta time and returns the eased interpolation value (0..1).
- `LTweenState:type`: Returns the type name of this object.
- `LTweenState:typeOf`: Checks whether this object matches the given type name.
