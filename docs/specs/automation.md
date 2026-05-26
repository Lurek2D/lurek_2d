# automation

## TL;DR

- The `automation` module provides a powerful headless input simulation framework designed for automated testing, QA replay, and recorded gameplay sessions.

## General Info

- Module group: `Feature Systems`
- Source path: `src/automation/`
- Lua API path(s): `src/lua_api/automation_api.rs`
- Primary Lua namespace: `lurek.automation`
- Rust test path(s): tests/rust/unit/automation_tests.rs
- Lua test path(s): tests/lua/unit/test_automation_core_unit.lua, tests/lua/integration/test_automation_event.lua

## Summary

 Positioned within the Feature Systems tier, it enables Lurek2D to execute deterministic, time-sorted sequences of synthetic input events without requiring a visible operating system window or actual hardware interactions. This makes it an invaluable tool for continuous integration pipelines, visual regression testing, and creating in-game replay features.

At the core of the module is the `Script` container, which holds an ordered sequence of `Step` entries. Each `Step` describes a timed action—such as key presses, mouse movements, clicks, scrolling, text input, or wait delays. Scripts can be authored externally in TOML format or constructed dynamically via Lua tables, supporting advanced orchestration capabilities including repeat expansions and configurable step limits to prevent runaway execution. 

Playback is managed by the `Simulator`, an engine that advances virtual time and dispatches events exactly as if they originated from real hardware. The `Simulator` supports complex control flow during playback, including pause and resume functionality, playback speed scaling, and macro invocations where reusable scripts are inlined at the current playback position. Additionally, it features a robust condition evaluation system allowing scripts to branch or assert state based on logical expressions (e.g., `!`, `&&`, `||`, and parentheses) against named boolean flags. 

For visual debugging and regression testing, the module offers unique assertion steps: `Assert` halts playback if a logical condition fails, while `VisualAssert` compares baseline images against actual rendered frames with pixel-diff tolerances. When running with a visible window, developers can enable a `highlight_mode` that overlays action indicators, making it easy to track synthetic inputs visually. The entire framework is fully integrated with the engine's event queue and exposed to Lua via the `lurek.automation.*` namespace, allowing script developers to orchestrate deterministic testing and record-and-playback systems directly from game logic.

## Source Documentation

### `mod.rs`
- Automation subsystem for deterministic input replay and visual regression testing.
- Script stores time-sorted steps parsed from TOML with repeat expansion.
- Simulator drives playback, dispatches events, evaluates conditions, and runs asserts.
- Step and Action types describe timed input events and control flow actions.

### `script.rs`
- Automation script container: named, time-sorted step sequences for deterministic replay.
- Expands repeat markers into cloned steps at computed time offsets.
- Parses TOML input with meta description and typed step fields.
- Enforces a configurable step limit (default MAX_STEPS = 100,000).
- Sorts steps by time after expansion for correct playback ordering.

### `simulator.rs`
- Automation simulator: drives script playback by advancing time and dispatching events.
- Manages a registry of named scripts and macros with load/unload lifecycle.
- Evaluates condition expressions (&&, ||, !, parentheses) against named boolean flags.
- Supports pause, resume, speed control, and visual highlight mode for debug tools.
- CallMacro steps inline macro scripts at the current playback position.
- VisualAssert steps compare baseline and actual images with pixel-diff tolerance.
- Assert steps halt playback when condition expressions evaluate to false.
- StepEventSink trait decouples event dispatch from EventQueue for testing.

### `step.rs`
- Action enum and Step struct: typed event descriptors for automation playback.
- Action variants cover keyboard, mouse, wheel, text, wait, repeat, macro, and asserts.
- Step carries all optional fields (key, position, delta, button, text, conditions).
- Parse support maps lowercase action strings to Action variants.
- Repeat and interval fields drive expansion in Script construction.

## Types

- `Script` (`struct`, `script.rs`): Named automation script with optional human-readable metadata and an ordered Vec of Step values. It is the durable unit loaded into the simulator and reused across playback runs.
- `StepEventSink` (`trait`, `simulator.rs`): Sink for events produced by the simulator during step dispatch.
- `Simulator` (`struct`, `simulator.rs`): Playback engine that owns the script registry, current script selection, elapsed time, next-step index, and running or paused state. This is the type to inspect when behavior changes around script lifecycle, event dispatch timing, or completion rules.
- `Action` (`enum`, `step.rs`): Enum of supported automation actions such as keypress, mousemove, mousepress, and wait. It is the boundary between script data and concrete EventQueue dispatch behavior.
- `Step` (`struct`, `step.rs`): One timed automation record with optional fields for key names, scancodes, mouse coordinates, wheel deltas, button data, and text input. It is intentionally flexible so a single structure can represent all supported synthetic input events.

## Functions

- `Script::new` (`script.rs`): Create a `Script` from a name and raw steps: expands repeats, sorts by time, caps to `MAX_STEPS`.
- `Script::with_description` (`script.rs`): Create a `Script` identical to `new` but also sets the human-readable `description` field.
- `Script::step_count` (`script.rs`): Return the total number of steps in this script.
- `Script::set_step_limit` (`script.rs`): Clamp and apply a new step limit, truncating the step list if it exceeds `limit`; range 1..=MAX_STEPS.
- `Script::get_step_limit` (`script.rs`): Return the current step limit for this script.
- `Script::from_toml` (`script.rs`): Parse a TOML string and construct a `Script`; return an error string on invalid TOML or unknown action.
- `Simulator::new` (`simulator.rs`): Create a new idle `Simulator` with no scripts, macros, or conditions loaded.
- `Simulator::load` (`simulator.rs`): Register a `Script` by name; replaces any existing script with the same name.
- `Simulator::unload` (`simulator.rs`): Remove the named script; stop playback if it is currently active.
- `Simulator::has_script` (`simulator.rs`): Return `true` if a script with `name` is registered.
- `Simulator::get_scripts` (`simulator.rs`): Return the names of all currently loaded scripts.
- `Simulator::start` (`simulator.rs`): Begin playback of the named script from the start; error if the script is not loaded.
- `Simulator::stop` (`simulator.rs`): Halt playback and reset all playback state to idle.
- `Simulator::pause` (`simulator.rs`): Suspend playback; time stops advancing until `resume()` is called.
- `Simulator::resume` (`simulator.rs`): Resume a paused script; no-op if not in `Paused` state.
- `Simulator::is_running` (`simulator.rs`): Return `true` when the script is actively advancing time.
- `Simulator::is_paused` (`simulator.rs`): Return `true` when the script is suspended.
- `Simulator::is_complete` (`simulator.rs`): Return `true` when all steps have been dispatched without error.
- `Simulator::is_failed` (`simulator.rs`): Return `true` when playback halted due to an assertion or macro error.
- `Simulator::last_error` (`simulator.rs`): Return the error message from the most recent failure, or `None` if no failure.
- `Simulator::current_step` (`simulator.rs`): Return the index of the next step that will be evaluated on the next `update()`.
- `Simulator::step_count` (`simulator.rs`): Return the total step count of the active script, or 0 when none is active.
- `Simulator::current_script` (`simulator.rs`): Return the name of the currently active script, or `None` when idle.
- `Simulator::elapsed_time` (`simulator.rs`): Return elapsed playback time in seconds (scaled by `playback_speed`).
- `Simulator::set_condition` (`simulator.rs`): Set a named boolean condition used by `when` and `assert` step expressions.
- `Simulator::get_condition` (`simulator.rs`): Return the current value of a named condition, or `None` if not set.
- `Simulator::get_script` (`simulator.rs`): Return a clone of the registered script with `name`, or `None` if not loaded.
- `Simulator::get_script_step_limit` (`simulator.rs`): Return the step limit of the named script, or `None` if the script is not loaded.
- `Simulator::set_script_step_limit` (`simulator.rs`): Apply a new step limit to the named script; return `true` if the script exists.
- `Simulator::save_macro` (`simulator.rs`): Register a named macro `Script` that can be inlined by `CallMacro` steps.
- `Simulator::play_macro` (`simulator.rs`): Load the named macro as a regular script and start it immediately.
- `Simulator::has_macro` (`simulator.rs`): Return `true` if a macro named `name` is registered.
- `Simulator::list_macros` (`simulator.rs`): Return the names of all registered macros.
- `Simulator::set_playback_speed` (`simulator.rs`): Set the playback speed multiplier; clamped to >= 0.0.
- `Simulator::get_playback_speed` (`simulator.rs`): Return the current playback speed multiplier.
- `Simulator::set_highlight_mode` (`simulator.rs`): Enable or disable visual step-highlight mode used by debug tooling.
- `Simulator::is_highlight_mode` (`simulator.rs`): Return `true` when visual step-highlight mode is active.
- `Simulator::update` (`simulator.rs`): Advance the simulator by `dt` seconds and dispatch due steps into `event_queue`.
- `Simulator::update_with_sink` (`simulator.rs`): Advance the simulator by `dt` seconds and dispatch due steps into the provided sink.
- `Action::parse_action` (`step.rs`): Parse a lowercase action string (e.g.
- `Action::as_str` (`step.rs`): Return the canonical lowercase string key for this variant; default to "wait" if not found.
- `Step::new` (`step.rs`): Create a `Step` at `time` seconds with the given `action`; all optional fields default to `None`.
- `Step::effective_scancode` (`step.rs`): Return `scancode` if set, otherwise fall back to `key`; `None` when both are absent.

## Lua API Reference

- Binding path(s): `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`

### Module Functions
- `lurek.automation.load`: Loads an automation script from a Lua table of steps and optional metadata.
- `lurek.automation.unload`: Unloads a named automation script.
- `lurek.automation.hasScript`: Returns whether a script is loaded.
- `lurek.automation.getScripts`: Returns the names of loaded automation scripts.
- `lurek.automation.start`: Starts playback of a loaded automation script.
- `lurek.automation.stop`: Stops the current automation script.
- `lurek.automation.pause`: Pauses automation playback. This function is exposed to Lua scripts.
- `lurek.automation.resume`: Resumes automation playback. This function is exposed to Lua scripts.
- `lurek.automation.update`: Advances automation playback and dispatches generated input events.
- `lurek.automation.isRunning`: Returns whether automation playback is running.
- `lurek.automation.isPaused`: Returns whether automation playback is paused.
- `lurek.automation.isComplete`: Returns whether the current automation script completed.
- `lurek.automation.isFailed`: Returns whether the current automation script failed.
- `lurek.automation.getLastError`: Returns the last automation error message when one exists.
- `lurek.automation.setCondition`: Sets a named boolean condition used by automation steps.
- `lurek.automation.getCondition`: Returns a named automation condition value.
- `lurek.automation.getCurrentStep`: Returns the current step index of the active script.
- `lurek.automation.getStepCount`: Returns the number of steps in the active script.
- `lurek.automation.getCurrentScript`: Returns the current script name when a script is active.
- `lurek.automation.getElapsedTime`: Returns elapsed playback time for the current script.
- `lurek.automation.loadFromToml`: Loads an automation script from TOML text.
- `lurek.automation.getStepLimit`: Returns the configured step limit for a loaded script.
- `lurek.automation.setStepLimit`: Sets the maximum step count for a loaded script.
- `lurek.automation.saveMacro`: Saves a loaded script as a named macro.
- `lurek.automation.playMacro`: Starts playback of a saved macro. This function is exposed to Lua scripts.
- `lurek.automation.hasMacro`: Returns whether a macro is saved. This function is exposed to Lua scripts.
- `lurek.automation.listMacros`: Returns the names of saved macros. This function is exposed to Lua scripts.
- `lurek.automation.setPlaybackSpeed`: Sets automation playback speed multiplier.
- `lurek.automation.getPlaybackSpeed`: Returns automation playback speed multiplier.
- `lurek.automation.setHighlightMode`: Enables or disables automation highlight mode.
- `lurek.automation.isHighlightMode`: Returns whether automation highlight mode is enabled.
- `lurek.automation.waitUntil`: Suspends automation updates until a predicate returns true or a timeout elapses.

## References

- `event`: Imports or references `event` from `src/event/`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Notes

- Keep this module reference synchronized with `src/automation/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.

### New in 0.14.1

- `Simulator.highlight_mode: bool` (default `false`) — hint flag for game-side replay overlays.
- `Simulator::set_highlight_mode(enable: bool)` / `is_highlight_mode() -> bool`.
- Lua: `lurek.automation.setHighlightMode(enable)` / `isHighlightMode()`.

### New in 1.0.9-fix.48

- Added script orchestration actions: `repeat`, `callmacro`, `assert`, `visualassert`.
- Added step-level fields: `repeat`, `repeatInterval`, `macro`, `when`, `assert`, `baseline`, `actual`, `maxDiff`.
- Added deterministic microsecond time accumulation in `Simulator::update` to reduce floating-drift behavior in long scripts.
- Added sink abstraction (`StepEventSink`) and `Simulator::update_with_sink` for isolated event-emission tests.
- Added runtime condition table and Lua APIs: `setCondition`, `getCondition`, `isFailed`, `getLastError`.

### New in 1.0.9-fix.78

- Added expression-capable condition checks for `when` and `assert` fields (`!`, `&&`, `||`, parentheses).
- Added shared timer integration via `timer::accumulate_scaled_micros` for replay time progression.
- Deduplicated automation event-name literals to `input` module constants.
