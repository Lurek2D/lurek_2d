# tween

## General Info

- Module group: `Feature Systems`
- Source path: `src/tween/`
- Lua API path(s): `src/lua_api/tween_api.rs`
- Primary Lua namespace: `lurek.tween`
- Rust test path(s): tests/rust/unit/tween_tests.rs
- Lua test path(s): tests/lua/unit/test_tween.lua, tests/lua/stress/test_tween_stress.lua, tests/lua/integration/test_tween_ecs.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tween_animation.lua

## Summary

## Summary

The `tween` module provides property animation through interpolated value transitions. It is a Feature Systems tier module designed for smoothly animating numeric fields on Lua tables — position, colour, alpha, scale, angle, volume, and any other user-defined float — without requiring game scripts to manage per-frame lerp arithmetic manually.

**TweenState.** `TweenState` is the pure-Rust timing and easing core. It stores duration, an easing function resolved from `math::EasingType` by name string through `resolve_easing()`, accumulated elapsed time, and a pause flag. `tick(dt)` advances the clock and returns `true` when the tween completes. `value_at(t)` evaluates the easing function at normalised time `t = elapsed / duration` and returns a [0, 1] progress scalar. `lerp(start, end)` wraps `value_at` to produce a directly usable interpolated float. `TweenState` holds no Lua references, making it safe to construct, advance, and query outside a Lua context — useful for Rust-side testing and use in `SpringSystem`.

**LuaTween.** `LuaTween` is the Lua-facing single-group tween handle. It wraps a `TweenState` alongside the target Lua table (held as a `LuaRegistryKey`), a list of (field, start_value, end_value) triples, an optional `on_step` callback, and an optional `on_complete` callback. `tick_with(dt, lua)` advances the state and writes all interpolated field values to the target table. When `tick_with` returns complete, `fire_on_complete(lua)` invokes the callback and releases the registry key. Multiple fields can be animated in a single `LuaTween` call, which is useful for animating `x` and `y` simultaneously with a single easing curve.

**Sequence.** `LuaTweenSequence` chains steps queue-style: each step starts only when the previous completes. `SequenceStep` discriminates between `Tween` (an embedded `LuaTween`), `Delay` (a pure time wait), and `Callback` (an inline Lua function invoked with no arguments). `LuaTweenSequence::tick_with(dt, lua)` advances the current step, pops it when done, and starts the next. A shared `on_complete` fires after the last step. Sequences model cutscene beats, multi-stage tutorials, or chained UI transitions.

**Parallel.** `LuaTweenParallel` runs multiple `ParallelEntry` tween records simultaneously. `tick_with(dt, lua)` advances all entries together. When the last entry completes, the parallel fires a shared `on_complete`. Parallel groups are useful for animating several independent objects simultaneously that must all finish before a next action triggers.

**Spring.** `spring.rs` provides physics-based spring interpolation as an alternative to fixed-duration easing curves. `SpringAxis` models a single damped harmonic oscillator: it stores current position, velocity, target, stiffness (`k`), damping ratio (`d`), and a rest precision threshold. `SpringAxis::update(dt)` integrates the differential equation `a = k*(target - pos) - d*vel` using a semi-implicit Euler step, zeroing velocity and snapping to target when the axis settles within the precision threshold. `SpringSystem` manages a named map of `SpringAxis` values with shared stiffness, damping, and precision parameters, so multiple axes (e.g. `x`, `y`, `scale`) can be driven together with uniform feel. Springs produce organic overshoot and oscillation, making them popular for UI snap-back and camera follow-lag effects.

**TweenEngine.** `TweenEngine` is the frame-level driver stored in `SharedState`. `update(dt, lua)` iterates all registered `LuaTween`, `LuaTweenSequence`, `LuaTweenParallel`, and `SpringSystem` instances in registration order, advances them, applies interpolated values to their target Lua tables, and removes completed objects. `cancel_all()` removes every active object immediately. `active_count()` returns the total number of currently tracked objects for diagnostic purposes.

**Easing catalogue.** All standard Robert Penner easing families are available by name string: `linear`, `quadIn`, `quadOut`, `quadInOut`, `cubicIn`/`Out`/`InOut`, `quartIn`/`Out`/`InOut`, `quintIn`/`Out`/`InOut`, `sineIn`/`Out`/`InOut`, `expoIn`/`Out`/`InOut`, `circIn`/`Out`/`InOut`, `backIn`/`Out`/`InOut` (overshoot), `elasticIn`/`Out`/`InOut` (oscillating), `bounceIn`/`Out`/`InOut` (simulated bounce). Custom easing functions can be passed as Lua function references instead of string names.

**Lua surface.** Single tween: `lurek.tween.to(target_tbl, props_tbl, opts)` → tween_handle; `opts` includes `duration`, `easing` (string or fn), `delay`, `onStep`, `onComplete`. Control: `tween:pause()`, `tween:resume()`, `tween:cancel()`, `tween:isComplete()` → bool. Sequence: `lurek.tween.sequence()` → seq; `seq:addTween(props)`, `seq:addDelay(s)`, `seq:addCallback(fn)`, `seq:setOnComplete(fn)`, `seq:start()`, `seq:cancel()`. Parallel: `lurek.tween.parallel(tweens_arr, on_complete)` → par_handle; `par:cancel()`. Spring: `lurek.tween.spring(target_tbl, field, opts)` → spring; `opts` includes `stiffness`, `damping`, `precision`; `spring:setTarget(v)`, `spring:getValue()` → float. Engine: `lurek.tween.cancelAll()`, `lurek.tween.count()` → int.

**Scope boundary.** Feature Systems tier. Depends on `math` (easing functions), `runtime`. Lua bridge in `src/lua_api/tween_api.rs`.

## Files

- `engine.rs`: Defines `TweenEngine`, the active-object pool that ticks live tween handles and releases them when done.
- `handle.rs`: Defines the Lua-backed domain handle types for single tweens, sequences, parallel groups, and their step or entry records.
- `mod.rs`: Declares the tween submodules and re-exports the core timing state, handle types, and engine.
- `spring.rs`: Physics-based spring interpolation for the `lurek.tween` system.
- `state.rs`: Defines `TweenState` plus built-in easing lookup and easing-name enumeration.

## Types

- `TweenEngine` (`struct`, `engine.rs`): The active tween pool that updates all registered tweens, sequences, and parallel groups each frame.
- `LuaTween` (`struct`, `handle.rs`): The single-property-group tween handle that animates named numeric fields on a Lua table.
- `SequenceStep` (`enum`, `handle.rs`): The enum-like workflow step container used inside sequences.
- `LuaTweenSequence` (`struct`, `handle.rs`): The ordered step runner that executes tween, delay, and callback steps one after another.
- `ParallelEntry` (`struct`, `handle.rs`): The per-arm tween record stored inside a parallel group.
- `LuaTweenParallel` (`struct`, `handle.rs`): The grouped runner that executes multiple tween entries at the same time.
- `SpringAxis` (`struct`, `spring.rs`): Single-axis spring simulation driven by a damped differential equation.
- `SpringSystem` (`struct`, `spring.rs`): Named collection of [`SpringAxis`] values that all share the same parameters.
- `TweenState` (`struct`, `state.rs`): The pure timing and easing core that tracks elapsed time, completion, and interpolation progress without Lua dependencies.

## Functions

- `TweenEngine::new` (`engine.rs`): Creates an empty `TweenEngine` with no active objects.
- `TweenEngine::update` (`engine.rs`): Advances all active tweens, sequences, and parallels by `dt` seconds.
- `TweenEngine::cancel_all` (`engine.rs`): Cancels and removes all active tweens, sequences, and parallels.
- `TweenEngine::active_count` (`engine.rs`): Returns the total number of currently tracked objects (tweens + seqs + pars + springs).
- `LuaTween::new` (`handle.rs`): Creates a `LuaTween` that animates named fields of a Lua table.
- `LuaTween::tick_with` (`handle.rs`): Advances the tween by `dt` seconds, writing interpolated values to the target table.
- `LuaTween::fire_on_complete` (`handle.rs`): Fires the `on_complete` callback if one is set, then frees the registry key.
- `LuaTweenSequence::new` (`handle.rs`): Creates an empty, inactive `LuaTweenSequence`.
- `LuaTweenSequence::tick_with` (`handle.rs`): Advances the sequence by `dt` seconds.
- `LuaTweenParallel::new` (`handle.rs`): Creates an empty, inactive `LuaTweenParallel`.
- `LuaTweenParallel::tick_with` (`handle.rs`): Advances all child entries by `dt` seconds.
- `SpringAxis::new` (`spring.rs`): Creates a `SpringAxis` with the given initial position and target.
- `SpringAxis::update` (`spring.rs`): Advances the spring simulation by `dt` seconds.
- `SpringAxis::is_settled` (`spring.rs`): Returns `true` when the axis has settled within `precision` of the target.
- `SpringAxis::reset` (`spring.rs`): Teleports to a new position and target, clearing velocity and the settled flag.
- `SpringAxis::set_target` (`spring.rs`): Updates the target without resetting velocity or position.
- `SpringSystem::new` (`spring.rs`): Creates an empty `SpringSystem` with the given parameters.
- `SpringSystem::add_axis` (`spring.rs`): Adds a named axis with the given starting position and target.
- `SpringSystem::update` (`spring.rs`): Advances all axes by `dt` seconds.
- `SpringSystem::is_settled` (`spring.rs`): Returns `true` when every axis has settled.
- `SpringSystem::set_target` (`spring.rs`): Sets the target for a named axis without resetting velocity.
- `SpringSystem::get_position` (`spring.rs`): Returns the current position of a named axis, or `None` if not found.
- `TweenState::new` (`state.rs`): Creates a new tween state with the given duration and easing name.
- `TweenState::tick` (`state.rs`): Advances the elapsed time by `dt` seconds.
- `TweenState::reset` (`state.rs`): Resets elapsed time to 0 so the tween plays from the beginning.
- `TweenState::t_raw` (`state.rs`): Returns the raw (un-eased) 0..=1 progress factor.
- `TweenState::t_eased` (`state.rs`): Returns the eased 0..=1 progress factor using the chosen easing function.
- `TweenState::lerp` (`state.rs`): Linearly interpolates from `start` to `end` using the eased progress factor.
- `TweenState::is_complete` (`state.rs`): Returns `true` if elapsed has reached or exceeded the duration.
- `resolve_easing` (`state.rs`): Resolves a named easing function to a function pointer.
- `builtin_easing_names` (`state.rs`): Returns all built-in easing names as a static slice.

## Lua API Reference

- Binding path(s): `src/lua_api/tween_api.rs`
- Namespace: `lurek.tween`

### Module Functions
- `lurek.tween.update`: Advances all active tweens, sequences, and parallels by `dt` seconds.
- `lurek.tween.tween`: Creates a new property tween and registers it for automatic updating.
- `lurek.tween.sequence`: Creates an empty TweenSequence. Add steps with :tween(), :delay(), :callback(),
- `lurek.tween.parallel`: Creates an empty TweenParallel. Add entries with :tween() or :add(tween),
- `lurek.tween.delay`: Creates a no-op tween that waits `seconds`, then optionally calls `callback`.
- `lurek.tween.cancelAll`: Cancels all active tweens, sequences, parallels, and springs immediately.
- `lurek.tween.getActiveCount`: Returns the number of currently active tween objects (tweens + seqs + pars).
- `lurek.tween.registerEasing`: Registers a custom easing function under `name`. `fn(t)` receives 0..1, returns 0..1.
- `lurek.tween.getEasingNames`: Returns a list of all available easing names (built-in + custom).
- `lurek.tween.newState`: Creates a standalone tween timing state without registering it with the engine.
- `lurek.tween.to`: Sugar for `tween()` with `target` first â€” natural read order.
- `lurek.tween.spring`: Creates a physics-based spring animation that drives named fields on `target_table`

### `Spring` Methods
- `Spring:update`: Advances the spring by `dt` seconds and writes positions to the target table.
- `Spring:isSettled`: Returns `true` when all spring axes have converged within `precision`.
- `Spring:isActive`: Returns `true` if the spring has not been cancelled or settled.
- `Spring:setTarget`: Updates target values for all fields present in `fields_table`.
- `Spring:setStiffness`: Updates the stiffness constant on all axes.
- `Spring:setDamping`: Updates the damping coefficient on all axes.
- `Spring:cancel`: Stops the spring. The engine will drop it on the next `update(dt)` call.
- `Spring:getPosition`: Returns the current interpolated position for the named field, or `nil`.

### `Tween` Methods
- `Tween:pause`: Pauses this tween; time stops advancing but the tween is not cancelled.
- `Tween:resume`: Resumes a paused tween, continuing from the position where it was paused.
- `Tween:isActive`: Returns true if the tween is still running (not completed or cancelled).
- `Tween:getProgress`: Returns raw 0..1 playback progress (not eased, not accounting for yoyo).
- `Tween:setRepeat`: Sets the number of extra play cycles after the first (0 = play once, -1 = infinite).
- `Tween:setYoyo`: Enables or disables yoyo (ping-pong) on each repeat cycle.

### `TweenParallel` Methods
- `TweenParallel:cancel`: Cancels the parallel group immediately.
- `TweenParallel:isActive`: Returns true if the parallel is running and not yet complete.

### `TweenSequence` Methods
- `TweenSequence:cancel`: Cancels the sequence and stops all pending steps.
- `TweenSequence:isActive`: Returns true if the sequence has been started and has not yet completed.

### `TweenState` Methods
- `TweenState:tick`: Advances the tween state by `dt` seconds.
- `TweenState:isComplete`: Returns whether the tween state has completed.
- `TweenState:t`: Returns the raw 0..1 playback progress.
- `TweenState:lerp`: Interpolates from `start` to `finish` using the eased tween progress.
- `TweenState:reset`: Resets the tween state to elapsed time zero.

## References

- `math`: Imports or references `math` from `src/math/`.

## Notes

- Keep this module reference synchronized with `src/tween/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
