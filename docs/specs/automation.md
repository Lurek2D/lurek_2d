# automation

## TL;DR

- Replays input steps and runs visual test assertions.

## General Info

- Module group: `Feature Systems`
- Source path: `src/automation/`
- Binding: `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`
- Lua API surface: `32` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/automation_tests.rs
- Lua test path(s): tests/lua/unit/test_automation_core_unit.lua, tests/lua/integration/test_automation_event.lua

## Summary

- The automation module replays scripted input and validates gameplay flows deterministically.
- It converts Lua/TOML steps into time-ordered actions so scenarios run the same on every machine.
- Supported inputs include keyboard, mouse, wheel, text, and macro playback.
- Pause, resume, speed scaling, and wait predicates make failures easier to reproduce and inspect.
- Visual assertions with tolerance thresholds catch rendering regressions in CI-style runs.
- Progress, failure state, and last-error queries provide actionable harness diagnostics.
- Script replay reduces manual smoke testing across gameplay, UI, and input-heavy systems.
- The module exists as the user-facing foundation for regression automation.

This module primarily collaborates with `event`, `input`, `runtime`, `timer`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `event`: Imports or references `event` from `src/event/`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Files

### mod.rs

- Defines the automation module boundary for deterministic input replay and scripted verification flows. `automation/mod` is the automation module index, declaring `script`, `simulator`, `step` so agents can identify which files own each feature slice before opening implementation code.
- Groups script parsing, playback simulation, and typed step contracts under one coherent runtime surface. `src/automation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `script::Script`, `simulator::Simulator`, `step::{Action, Step}` centralized for the automation subsystem.

### script.rs

- Implements automation script storage as named, time-ordered step sequences for deterministic replay. `automation/script` delivers the script implementation for the automation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Parses TOML definitions into typed runtime steps with metadata and validated field extraction. The file owns or coordinates data contracts including `Script`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Expands repeat directives into concrete scheduled steps at computed temporal offsets. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_description`, `step_count`, `set_step_limit`, `get_step_limit`, `from_toml` stays attached to the local data model and invariants.
- Enforces bounded script size to protect playback and memory behavior under large inputs. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### simulator.rs

- Implements deterministic automation playback that advances script time and dispatches input events. `automation/simulator` delivers the simulator implementation for the automation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maintains registries of named scripts and macros for reusable scenario composition. The file owns or coordinates data contracts including `StepEventSink`, `Simulator`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Evaluates boolean condition expressions to gate control-flow steps and assertion behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `load`, `unload`, `has_script`, `get_scripts`, `start`, and 27 more stays attached to the local data model and invariants.
- Supports pause, resume, and speed scaling so runs can be inspected or accelerated as needed. Runtime integration reaches sibling engine areas through crate modules `event`, `input`, `log_msg`, `runtime`, `timer`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Inlines macro calls into active playback flow while preserving temporal consistency. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Executes visual assertions through baseline comparison with configurable tolerance thresholds. The file boundary separates automation implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### step.rs

- Defines typed automation step contracts that describe input actions and control-flow intent. `automation/step` delivers the step implementation for the automation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Covers keyboard, mouse, wheel, text, wait, macro, and assertion-oriented event categories. The file owns or coordinates data contracts including `Action`, `Step`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores optional action payload fields in one flexible step record consumed by script playback. Public callable behavior is centered on no named public items, while method-level behavior such as `parse_action`, `as_str`, `new`, `effective_scancode` stays attached to the local data model and invariants.
- Maps textual action tags to enum variants for deterministic parse and dispatch behavior. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



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

## References

- `event`: Imports or references `event` from `src/event/`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Notes

- No additional module-specific notes.
