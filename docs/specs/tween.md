# tween

## General Info

- Module group: `Feature Systems`
- Source path: `src/tween/`
- Lua API path(s): `src/lua_api/tween_api.rs`
- Primary Lua namespace: `lurek.tween`
- Rust test path(s): tests/rust/unit/tween_tests.rs
- Lua test path(s): tests/lua/unit/test_tween.lua, tests/lua/stress/test_tween_stress.lua, tests/lua/integration/test_tween_entity.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tween_animation.lua

## Summary

The `tween` module owns time-based property interpolation for Lua-facing game objects. Its job is to take named numeric fields on Lua tables, apply easing over time, support repeats and yoyo playback, and coordinate single tweens, sequential chains, and parallel groups through a shared update engine.

This module exists so scripted gameplay code can animate values declaratively without embedding interpolation logic into every feature module. `TweenState` provides the pure numeric timing and easing core. The handle types carry the Lua registry references and state machines for single tweens, sequences, and parallel groups. `TweenEngine` then advances all active handles each frame and cleans them up when they complete or are cancelled.

The module intentionally does not own the main game clock, frame scheduling, scene update order, or any particular animated domain object. It also does not define a generic Rust-side property graph; the target values live in Lua tables and are updated from there. Systems such as camera, animation, UI, and ECS may all be animated by tween, but they retain ownership of their own state and meaning.

**Scope boundary**: This module currently depends on `math`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `engine.rs`: Defines `TweenEngine`, the active-object pool that ticks live tween handles and releases them when done.
- `handle.rs`: Defines the Lua-backed domain handle types for single tweens, sequences, parallel groups, and their step or entry records.
- `mod.rs`: Declares the tween submodules and re-exports the core timing state, handle types, and engine.
- `state.rs`: Defines `TweenState` plus built-in easing lookup and easing-name enumeration.

## Types

- `TweenEngine` (`struct`, `engine.rs`): The active tween pool that updates all registered tweens, sequences, and parallel groups each frame.
- `LuaTween` (`struct`, `handle.rs`): The single-property-group tween handle that animates named numeric fields on a Lua table.
- `SequenceStep` (`enum`, `handle.rs`): The enum-like workflow step container used inside sequences.
- `LuaTweenSequence` (`struct`, `handle.rs`): The ordered step runner that executes tween, delay, and callback steps one after another.
- `ParallelEntry` (`struct`, `handle.rs`): The per-arm tween record stored inside a parallel group.
- `LuaTweenParallel` (`struct`, `handle.rs`): The grouped runner that executes multiple tween entries at the same time.
- `TweenState` (`struct`, `state.rs`): The pure timing and easing core that tracks elapsed time, completion, and interpolation progress without Lua dependencies.

## Functions

- `TweenEngine::new` (`engine.rs`): Creates an empty `TweenEngine` with no active objects.
- `TweenEngine::update` (`engine.rs`): Advances all active tweens, sequences, and parallels by `dt` seconds.
- `TweenEngine::cancel_all` (`engine.rs`): Cancels and removes all active tweens, sequences, and parallels.
- `TweenEngine::active_count` (`engine.rs`): Returns the total number of currently tracked objects (tweens + seqs + pars).
- `LuaTween::new` (`handle.rs`): Creates a `LuaTween` that animates named fields of a Lua table.
- `LuaTween::tick_with` (`handle.rs`): Advances the tween by `dt` seconds, writing interpolated values to the target table.
- `LuaTween::fire_on_complete` (`handle.rs`): Fires the `on_complete` callback if one is set, then frees the registry key.
- `LuaTweenSequence::new` (`handle.rs`): Creates an empty, inactive `LuaTweenSequence`.
- `LuaTweenSequence::tick_with` (`handle.rs`): Advances the sequence by `dt` seconds.
- `LuaTweenParallel::new` (`handle.rs`): Creates an empty, inactive `LuaTweenParallel`.
- `LuaTweenParallel::tick_with` (`handle.rs`): Advances all child entries by `dt` seconds.
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
- `lurek.tween.cancelAll`: Cancels all active tweens, sequences, and parallels immediately.
- `lurek.tween.getActiveCount`: Returns the number of currently active tween objects (tweens + seqs + pars).
- `lurek.tween.registerEasing`: Registers a custom easing function under `name`. `fn(t)` receives 0..1, returns 0..1.
- `lurek.tween.getEasingNames`: Returns a list of all available easing names (built-in + custom).

### `Tween` Methods
- `Tween:pause`: Pauses this tween; time stops advancing but the tween is not cancelled.
- `Tween:resume`: Resumes a paused tween.
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

## References

- `math`: Imports or references `math` from `src/math/`.

## Notes

- Keep this module reference synchronized with `src/tween/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
