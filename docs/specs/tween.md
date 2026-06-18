# tween

## TL;DR

- Timed interpolation engine supporting easing curves, spring dynamics, and sequence composition with coroutine awaiting.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tween/`
- Binding: `src/lua_api/tween_api.rs`
- Namespace: `lurek.tween`
- Lua API surface: `15` functions, `6` types, `82` methods
- Rust test path(s): tests/rust/unit/tween_tests.rs
- Lua test path(s): tests/lua/unit/test_tween.lua, tests/lua/stress/test_tween_stress.lua, tests/lua/integration/test_tween_ecs.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tween_animation.lua

## Summary

- The `tween` module is the engine's interpolation and motion-sequencing surface for users who want values to change over time without hand-writing frame-by-frame update loops.
- Tweens, handles, chains, grouped sequences, interpolators, and springs all live together here so one-off transitions and larger scripted motion can share one model.
- This matters because many features need shaped progression, not just endpoint changes: UI reveals, camera motion, gameplay feedback, and scripted effects all depend on timing semantics.
- Easing and spring behavior give the module expressive range, while handle-based control makes active transitions inspectable, cancelable, and synchronizable.
- The sequencing surface is important because many real transitions happen in stages instead of one linear interpolation.
- Parallel and chained motion therefore belong in the same subsystem as simple tweens, which keeps authored timing workflows coherent instead of scattering them across unrelated feature code.
- This makes the module suitable not only for decorative polish, but also for stateful workflows where motion is part of how a feature behaves instead of merely how it looks.
- The feature is useful whenever another system decides what should move but still needs reusable rules for how that movement advances over time.
- That separation is what lets several domains share one timing model without sharing any domain-specific update semantics.
- It also gives tools and gameplay code the same language for staged motion and timed value changes.
- The same model also helps previews and iteration stay controllable while motion is active.
- It is therefore as much a sequencing tool as a visual-polish helper.
- The module improves consistency across UI, cameras, overlays, and feedback systems by giving them one temporal vocabulary.
- Read `tween` as the engine's reusable workflow for interpolation, sequencing, and spring-like motion.

## Imports

- `math`: Imports or references `math` from `src/math/`.

## Files

### chain.rs

- This file owns `ChainStep`, `ChainEvent`, and `TweenChain`, the staged playback model for chained tween timing.
- It stores ordered steps, the active cursor, loop flags, pause state, and iteration counts for deterministic progress.
- Each step carries duration, easing, endpoints, optional labels, and local elapsed time used to compute live values.
- The `tick` loop can finish multiple short steps in one frame, emit completion events, and carry leftover delta forward.
- Sequence-level helpers start, stop, pause, reset, jump, and report progress without involving Lua registry handles.
- Open this file when scripted animation choreography or labeled step transitions change, not field-writing logic.

### engine.rs

- This file owns `TweenEngine`, the runtime registry that ticks standalone tweens, sequences, parallels, and springs.
- It stores Lua registry keys for active animation units plus named custom easing callbacks registered at runtime.
- The `update` path advances each live handle, drops completed registry entries, and preserves parent-owned tween rules.
- The `cancel_all` path shuts down outstanding animations, fires cancel callbacks where present, and clears engine state.
- Open this file when animation lifecycle cleanup, active counts, or per-frame coordination across handle types changes.

### handle.rs

- This file owns the Lua-facing tween handle types that scripts manipulate for single, sequential, and parallel motion.
- It defines `LuaTween`, `LuaTweenSequence`, `LuaTweenParallel`, and their step records around one lifecycle contract.
- Single tweens store target table bindings, captured starts, end values, repeat rules, yoyo state, waiters, and hooks.
- Sequence steps cover field tweens, timed delays, and instant callbacks so one handle can express ordered choreography.
- Parallel entries keep per-lane timing and field mappings so multiple table updates can complete under one parent.
- Tick methods write interpolated values back into Lua tables, resume waiting coroutines, and fire completion callbacks.
- This file is the boundary between raw tween progression state and the Lua userdata objects registered by the engine.
- Open it when script-visible tween semantics change; use sibling files for easing math, chain flow, or engine cleanup.

### interpolator.rs

- This file owns `Tween`, a generic multi-channel interpolator that samples registered start and target values over time.
- It stores the easing function, preserved easing name, playback clock, duration, and the channel list in one owner.
- Methods here add channels, advance or seek the clock, and read one channel or all channels through eased sampling.
- The local easing resolver accepts both core names and `easeIn*` aliases so script spelling stays backward compatible.
- Open this file when non-Lua interpolation behavior changes without touching engine registries or Lua handle lifecycles.

### mod.rs

- This module re-exports the tween runtime surface so callers can reach engines, handles, springs, and chains.
- It keeps `src/tween` navigation shallow by naming which sibling files own ticking, interpolation, easing, and flow.
- Public exports here route scripts and internal runtime code toward `TweenEngine` for active animation scheduling.
- It also exposes `LuaTween`, `LuaTweenSequence`, and `LuaTweenParallel` as the Lua-facing control shapes.
- State-oriented helpers such as `TweenState`, `Tween`, `SpringSystem`, and `TweenChain` stay discoverable here.
- Change this file when the tween subsystem boundary or public symbol map changes, not when animation logic changes.

### spring.rs

- This file owns `SpringAxis` and `SpringSystem`, which provide damped spring motion for one field or named axis sets.
- It stores per-axis position, velocity, target, stiffness, damping, precision, and settled state for each simulation.
- Update methods integrate motion each tick, snap settled axes to their targets, and expose queries or target changes.
- The system wrapper groups multiple axes under shared defaults so higher layers can drive coordinated spring motion.
- Open this file when physical-feel parameters or settle behavior change, not when keyframe easing rules change.

### state.rs

- This file owns `TweenState`, the shared timing record that tracks duration, elapsed time, pause state, and easing.
- It resolves easing names through the math catalog, including aliases exposed to scripts and tooling lookups.
- Methods here convert raw clock progress into eased progress, linear interpolation, reset behavior, and completion tests.
- The exported `builtin_easing_names` list gives validators, docs, and completion code one canonical set of names.
- Open this file when tween timing semantics or accepted easing identifiers change across multiple animation owners.



## Lua API Ref

### Functions

- `lurek.tween.cancelAll() -> nil`: Immediately cancels all active tweens, sequences, parallels, and springs managed by the tween engine.
- `lurek.tween.delay(seconds, cb?) -> LTweenSequence`: Creates a one-shot delay. After the specified seconds elapse, the optional callback is invoked.
- `lurek.tween.getActiveCount() -> number`: Returns the total number of currently active tweens, sequences, and parallels.
- `lurek.tween.getEasingNames() -> string[]`: Returns an array of all available easing function names, including both built-in and custom-registered easings.
- `lurek.tween.newChain(looping?) -> LTweenChain`: Creates a sequential tween chain for cinematic value-interpolation sequences.
- `lurek.tween.newState(duration, easing?) -> LTweenState`: Creates a standalone tween state for manual interpolation. Useful when you need eased progress without automatic property updates.
- `lurek.tween.parallel() -> LTweenParallel`: Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.
- `lurek.tween.registerEasing(name, f) -> nil`: Registers a custom easing function by name. The function receives a progress value (0..1) and must return an eased value.
- `lurek.tween.sequence() -> LTweenSequence`: Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.
- `lurek.tween.spring(target, fields, opts?) -> LSpring`: Creates a spring-physics animation that smoothly drives table fields toward target values with bounce and settle behavior.
- `lurek.tween.to(target, fields, duration, easing?) -> LTween`: Creates and starts a property tween with a different parameter order: target first, then fields, duration, easing.
- `lurek.tween.tween(duration, target, fields, easing?) -> LTween`: Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.
- `lurek.tween.tweenChain(steps) -> LTweenSequence`: Creates a sequence from a table of step descriptors. Each step is a table with `duration`, `target`, `fields`, optional `easing`, optional `callback`, or a `delay` key for pauses.
- `lurek.tween.tweenColor(duration, target, color, easing?) -> LTween`: Creates and starts a color tween that smoothly interpolates r, g, b, and/or a fields on the target table.
- `lurek.tween.update(dt) -> nil`: Advances all active tweens, sequences, parallels, and springs by the given delta time. Call once per frame.

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

- `LSpring:cancel() -> nil`: Cancels this spring animation and cleans up the on-settle callback if one was registered.
- `LSpring:getPosition(field) -> LuaValue`: Returns the current position of the given spring axis, or `nil` if the axis does not exist.
- `LSpring:isActive() -> boolean`: Returns whether this spring is still actively animating.
- `LSpring:isSettled() -> boolean`: Returns whether all spring axes have reached their targets within the precision threshold.
- `LSpring:setDamping(value) -> nil`: Sets the spring damping for all axes. Higher values reduce oscillation and overshoot.
- `LSpring:setStiffness(value) -> nil`: Sets the spring stiffness for all axes. Higher values make the spring snap faster.
- `LSpring:setTarget(fields) -> nil`: Changes the spring target values for one or more axes. Re-activates the spring if it was settled.
- `LSpring:type() -> string`: Returns the type name of this object.
- `LSpring:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LSpring:update(dt) -> boolean`: Manually advances this spring by the given delta time and writes updated positions to the target table. Returns `true` if still animating, `false` if settled.

#### LTween Type

- Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration.

##### Fields

- No documented fields.

##### Methods

- `LTween:await() -> nil`: Yields the current coroutine until this tween completes or is cancelled. Must be called from inside a coroutine.
- `LTween:cancel() -> nil`: Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it.
- `LTween:getDuration() -> number`: Returns the total duration of this tween in seconds.
- `LTween:getElapsed() -> number`: Returns the number of seconds that have elapsed since the tween started.
- `LTween:getFields() -> string[]`: Returns an array of field names being tweened on the target table.
- `LTween:getProgress() -> number`: Returns the eased progress of this tween as a value from 0.0 to 1.0.
- `LTween:getRemaining() -> number`: Returns the number of seconds remaining until this tween completes.
- `LTween:isActive() -> boolean`: Returns whether this tween is still running (not cancelled or completed).
- `LTween:onCancel(f) -> LTween`: Sets a callback to fire when the tween is cancelled. Returns the tween for chaining.
- `LTween:onComplete(f) -> LTween`: Sets a callback to fire when the tween completes. Returns the tween for chaining.
- `LTween:onUpdate(f) -> LTween`: Sets a callback to fire every frame while the tween is active. Returns the tween for chaining.
- `LTween:pause() -> nil`: Pauses this tween so it stops advancing until resumed.
- `LTween:relative(enabled) -> LTween`: Chainable version of `setRelative`. Returns the tween for fluent API usage.
- `LTween:resume() -> nil`: Resumes a paused tween so it continues advancing.
- `LTween:setRelative(enabled) -> nil`: Sets whether the tween end values are relative to the start values instead of absolute.
- `LTween:setRepeat(n) -> nil`: Sets how many times the tween should repeat after the first play. Use -1 for infinite repeat.
- `LTween:setYoyo(enabled) -> nil`: Enables or disables yoyo mode, which reverses the tween direction on each repeat cycle.
- `LTween:type() -> string`: Returns the type name of this object.
- `LTween:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTweenChain Type

- Lua-side wrapper for a sequential tween chain.

##### Fields

- No documented fields.

##### Methods

- `LTweenChain:call(fn) -> LTweenChain`: Adds a fluent callback step that executes once at this point in the chain.
- `LTweenChain:clear() -> nil`: Clears all fluent and legacy steps.
- `LTweenChain:cursor() -> integer`: Returns one-based current legacy step index.
- `LTweenChain:getIteration() -> integer`: Returns current iteration number.
- `LTweenChain:getProgress() -> number`: Returns normalized fluent chain progress in range `[0, 1]`.
- `LTweenChain:isActive() -> boolean`: Returns whether fluent playback is active.
- `LTweenChain:isComplete() -> boolean`: Returns whether fluent playback reached final completion.
- `LTweenChain:isFinished() -> boolean`: Returns whether legacy playback reached completion for the active pass.
- `LTweenChain:isLooping() -> boolean`: Returns whether chain is in infinite loop mode.
- `LTweenChain:jumpTo(step) -> nil`: Jumps legacy chain cursor to given one-based step.
- `LTweenChain:len() -> integer`: Returns legacy step count currently stored in this tween chain.
- `LTweenChain:loop(n) -> LTweenChain`: Sets fluent loop count where `0` means infinite looping behavior.
- `LTweenChain:onComplete(fn) -> LTweenChain`: Sets callback fired after the final fluent pass fully completes.
- `LTweenChain:onLoop(fn) -> LTweenChain`: Sets callback fired when entering the next fluent loop iteration.
- `LTweenChain:pause() -> LTweenChain`: Pauses fluent playback while preserving timeline progress and cursor state.
- `LTweenChain:push(opts) -> integer`: Appends a legacy scalar step to the compatibility chain.
- `LTweenChain:reset() -> nil`: Resets both fluent and legacy playback cursors.
- `LTweenChain:resume() -> LTweenChain`: Resumes fluent playback from the previously paused timeline position.
- `LTweenChain:setLooping(looping) -> nil`: Enables/disables infinite loop compatibility mode.
- `LTweenChain:start() -> LTweenChain`: Starts fluent chain playback and registers this chain in the update queue.
- `LTweenChain:stop() -> LTweenChain`: Stops fluent playback and leaves the chain ready for a later restart.
- `LTweenChain:tick(dt) -> table`: Advances the legacy scalar chain and returns completion events.
- `LTweenChain:to(target, fields, dur, easing?) -> LTweenChain`: Adds a fluent tween step to this chain.
- `LTweenChain:type() -> string`: Returns the Lua-visible type name.
- `LTweenChain:typeOf(name) -> boolean`: Returns whether this handle matches the given type name.
- `LTweenChain:value() -> number`: Returns current legacy scalar value.
- `LTweenChain:wait(seconds, callback?) -> LTweenChain`: Adds a fluent delay step to the chain timeline and keeps fluent chaining enabled.

#### LTweenParallel Type

- Creates a new empty parallel tween group. Add tweens with `:tween()` or `:add()`, then call `:start()` to run them simultaneously.

##### Fields

- No documented fields.

##### Methods

- `LTweenParallel:add(tw_ud) -> nil`: Adds an existing tween handle to this parallel group. The tween becomes owned by the group.
- `LTweenParallel:cancel() -> nil`: Cancels all tweens in this parallel group immediately.
- `LTweenParallel:isActive() -> boolean`: Returns whether this parallel group is still running.
- `LTweenParallel:onComplete(f) -> LTweenParallel`: Sets a callback to fire when all tweens in this parallel group have finished. Returns the group for chaining.
- `LTweenParallel:start() -> LTweenParallel`: Starts all tweens in this parallel group simultaneously.
- `LTweenParallel:tween(duration, target, fields, easing?) -> LTweenParallel`: Creates and adds a new tween step directly to this parallel group.
- `LTweenParallel:type() -> string`: Returns the type name of this object.
- `LTweenParallel:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTweenSequence Type

- Creates a new empty tween sequence. Chain `.tween()`, `.delay()`, and `.callback()` steps, then call `:start()`.

##### Fields

- No documented fields.

##### Methods

- `LTweenSequence:await() -> nil`: Yields the current coroutine until this sequence completes or is cancelled. Must be called from inside a coroutine.
- `LTweenSequence:callback(f) -> LTweenSequence`: Appends a callback step to this sequence that fires when reached during playback.
- `LTweenSequence:cancel() -> nil`: Cancels this sequence immediately and resumes any coroutines waiting on it.
- `LTweenSequence:delay(seconds, cb?) -> LTweenSequence`: Appends a delay step to this sequence. Optionally fires a callback when the delay elapses.
- `LTweenSequence:getProgress() -> number`: Returns the overall progress ratio of this sequence from 0.0 to 1.0.
- `LTweenSequence:isActive() -> boolean`: Returns whether this sequence is still running.
- `LTweenSequence:onComplete(f) -> LTweenSequence`: Sets a callback to fire when the sequence finishes all steps. Returns the sequence for chaining.
- `LTweenSequence:start() -> LTweenSequence`: Starts playback of this sequence from the first step.
- `LTweenSequence:tween(duration, target, fields, easing?) -> LTweenSequence`: Appends a tween step to this sequence that animates numeric fields on the target table.
- `LTweenSequence:type() -> string`: Returns the type name of this object.
- `LTweenSequence:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LTweenState Type

- Lua-exposed standalone tween state for manual interpolation without automatic property updates.

##### Fields

- `paused` (`any`): Lua-visible field.

##### Methods

- `LTweenState:isComplete() -> boolean`: Returns whether this tween state has finished its full duration.
- `LTweenState:lerp(start, finish) -> number`: Linearly interpolates between two values using the current eased progress.
- `LTweenState:reset() -> nil`: Resets the tween state to the beginning so it can be replayed.
- `LTweenState:t() -> number`: Returns the raw (un-eased) progress value from 0.0 to 1.0.
- `LTweenState:tick(dt) -> number`: Advances the tween state by the given delta time and returns the eased interpolation value (0..1).
- `LTweenState:type() -> string`: Returns the type name of this object.
- `LTweenState:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## References

- `math`: Imports or references `math` from `src/math/`.

## Notes

- No additional module-specific notes.
