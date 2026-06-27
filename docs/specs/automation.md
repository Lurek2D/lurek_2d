<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/automation.md or source docstrings instead. -->

# automation

## TL;DR

- Replays precise input steps, chords, device actions, and visual test assertions.

## General Info

- Module group: `Feature Systems`
- Source path: `src/automation`
- Binding: `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`
- Lua API surface: `32` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `automation` module is the scripted replay layer for users who want deterministic QA, repeatable demos, or regression-oriented gameplay checks.
- It turns authored steps into real runtime input flow, covering the parsing of automation scripts, ordered playback, and step-level control over how the scenario advances.
- Steps can model keyboard, mouse, wheel, text, touch, and gamepad input, including positions, click counts, axis values, pressure, and duration-generated release events.
- Chord steps such as `ctrl+a` or `shift+mouse1` are authored as one automation event but replay as the same primitive callbacks and input-state transitions that real user input would produce.
- Simulation and assertion features work together here: the same module can replay actions, wait on conditions, and verify visual or behavioral outcomes under the same timing rules.
- Determinism is the key promise: authored steps should replay under controlled timing.
- Read it as the coordination layer above raw input and clocks. Neighboring modules provide the low-level events and timing primitives, while `automation` turns them into a reusable test workflow.

This module primarily collaborates with `event`, `input`, `runtime`, `timer`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/automation`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/automation_api.rs`
- Referenced engine modules: `event`, `input`, `runtime`, `timer`

## Imports

- `event`: Imports or references `src/event/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### mod.rs

- `src/automation/mod.rs` is the module index that exposes script parsing, playback simulation, and automation steps.
- It reexports `Script`, `Simulator`, `Action`, and `Step` so callers consume one stable automation surface.
- No active script or playback state lives here; this file only declares child modules and chooses public symbols.
- Read this index when wiring replay or verification flows, because it shows where script data ends and execution begins.
- Changes here reshape the automation boundary, since reexports decide what runtime code may import without deep paths.
- This module keeps step contracts, TOML loading, and playback logic separated for clearer ownership and testability.

### script.rs

- `src/automation/script.rs` owns automation script storage and TOML parsing into named, time-sorted step sequences.
- It defines `Script`, expands repeat directives, sorts steps by time, and enforces bounded script size in one owner.
- Metadata loading and field extraction from TOML also live here, keeping authoring rules close to stored script data.
- This file is the boundary for authored automation content before runtime playback policy is applied by the simulator.
- Read this file when script import rules, repeat expansion, or step-cap enforcement for automation content must change.

### simulator.rs

- `src/automation/simulator.rs` owns playback execution for automation scripts, macros, conditions, and visual assertions.
- It defines `StepEventSink` and `Simulator`, keeping script registries, playback state, and dispatch logic together.
- Time advancement, pause and resume, speed scaling, macro expansion, and step dispatch all live in this file.
- Condition parsing and boolean evaluation also live here, so `when` and `assert` expressions share one execution policy.
- Visual assert behavior is implemented here too, including image diffing and max-difference failure thresholds.
- This file is the runtime boundary for automation execution; script storage and step schemas stay in sibling files.
- Read it when playback ordering, macro inlining, assertion semantics, or emitted input-event behavior must change.
- It also centralizes drift-safe time accumulation during playback, which keeps long automation runs deterministic.
- Higher layers should treat this file as the owner of automation control flow rather than rebuilding policy elsewhere.

### step.rs

- `src/automation/step.rs` owns the typed action enum and step record that describe timed automation inputs and checks.
- It defines `Action` and `Step`, keeping parseable action names and optional per-step payload fields under one owner.
- Keyboard, mouse, wheel, text, touch, gamepad, combo, wait, macro, assert, and visual-assert categories are declared here.
- Read this file when action vocabulary, step fields, or scancode fallback behavior for automation content changes.
- This file is the schema boundary for automation scripts, while parsing and playback behavior stay in sibling modules.



## Lua API Ref

### Functions

- `lurek.automation.getCondition(name) -> boolean`: Returns a named automation condition value.
- `lurek.automation.getCurrentScript() -> string`: Returns the current script name when a script is active.
- `lurek.automation.getCurrentStep() -> integer`: Returns the current step index of the active script.
- `lurek.automation.getElapsedTime() -> number`: Returns elapsed playback time for the current script.
- `lurek.automation.getLastError() -> string`: Returns the last automation error message when one exists.
- `lurek.automation.getPlaybackSpeed() -> number`: Returns automation playback speed multiplier.
- `lurek.automation.getScripts() -> string[]`: Returns the names of loaded automation scripts.
- `lurek.automation.getStepCount() -> integer`: Returns the number of steps in the active script.
- `lurek.automation.getStepLimit(name) -> integer`: Returns the configured step limit for a loaded script.
- `lurek.automation.hasMacro(name) -> boolean`: Returns whether a macro is saved. This function is exposed to Lua scripts.
- `lurek.automation.hasScript(name) -> boolean`: Returns whether a script is loaded.
- `lurek.automation.isComplete() -> boolean`: Returns whether the current automation script completed.
- `lurek.automation.isFailed() -> boolean`: Returns whether the current automation script failed.
- `lurek.automation.isHighlightMode() -> boolean`: Returns whether automation highlight mode is enabled.
- `lurek.automation.isPaused() -> boolean`: Returns whether automation playback is paused.
- `lurek.automation.isRunning() -> boolean`: Returns whether automation playback is running.
- `lurek.automation.listMacros() -> string[]`: Returns the names of saved macros. This function is exposed to Lua scripts.
- `lurek.automation.load(name, data) -> nil`: Loads an automation script from a Lua table of steps and optional metadata.
- `lurek.automation.loadFromToml(name, toml_str) -> nil`: Loads an automation script from TOML text.
- `lurek.automation.pause() -> nil`: Pauses automation playback. This function is exposed to Lua scripts.
- `lurek.automation.playMacro(name) -> nil`: Starts playback of a saved macro. This function is exposed to Lua scripts.
- `lurek.automation.resume() -> nil`: Resumes automation playback. This function is exposed to Lua scripts.
- `lurek.automation.saveMacro(macro_name, script_name) -> nil`: Saves a loaded script as a named macro.
- `lurek.automation.setCondition(name, value) -> nil`: Sets a named boolean condition used by automation steps.
- `lurek.automation.setHighlightMode(enable) -> nil`: Enables or disables automation highlight mode.
- `lurek.automation.setPlaybackSpeed(factor) -> nil`: Sets automation playback speed multiplier.
- `lurek.automation.setStepLimit(name, n) -> boolean`: Sets the maximum step count for a loaded script.
- `lurek.automation.start(name) -> nil`: Starts playback of a loaded automation script.
- `lurek.automation.stop() -> nil`: Stops the current automation script.
- `lurek.automation.unload(name) -> boolean`: Unloads a named automation script.
- `lurek.automation.update(dt) -> nil`: Advances automation playback and dispatches generated input events.
- `lurek.automation.waitUntil(predicate, timeout) -> nil`: Suspends automation updates until a predicate returns true or a timeout elapses.

### Callbacks

- `lurek.automation.waitUntil` param `predicate` (`function`): Function called each update; true resolves the wait.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## Examples

- `content/examples/automation.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_automation_unit.lua` (present)
- Rust: `tests/rust/unit/automation_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_automation_evidence.lua` |
| Golden test | `tests/lua/golden/test_automation_golden.lua` |
| Current artifact | `tests/artifacts/current/automation/automation_condition_gate_trace.txt` |
| Current artifact | `tests/artifacts/current/automation/automation_macro_control_trace.txt` |
| Current artifact | `tests/artifacts/current/automation/automation_timeline_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/automation/automation_condition_gate_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/automation/automation_macro_control_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/automation/automation_timeline_trace.txt` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
