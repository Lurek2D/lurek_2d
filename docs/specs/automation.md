# automation

## TL;DR

- The `automation` module provides deterministic scripted input playback for tests, QA replay, and reproducible runtime scenarios.

## General Info

- Module group: `Feature Systems`
- Source path: `src/automation/`
- Binding: `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`
- Lua API surface: `32` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/automation_tests.rs
- Lua test path(s): tests/lua/unit/test_automation_core_unit.lua, tests/lua/integration/test_automation_event.lua

## Summary

The `automation` module gives one reliable way to simulate runtime interaction without manual input. It turns test intent into scripted steps and replays those steps in a controlled timeline. This helps teams verify behavior repeatedly with the same sequence and expected outcomes.

Its core value is deterministic playback. Scripts are stored as ordered actions, then executed by a simulator that advances time and dispatches events in strict order. Because runs are data-driven, results are less dependent on machine timing, device noise, or manual tester variance.

The module supports practical workflow features for test authoring and reuse. Scripts can be loaded, started, paused, resumed, stopped, and limited by step count. Named macros and conditional gates allow larger scenarios to be built from smaller reusable pieces.

Verification is part of the runtime flow, not an afterthought. The simulator can apply assertions, track failures, and expose status such as running, paused, complete, failed, and last error. This makes it useful for CI and regression checks where pass/fail signals must be explicit.

Functionally, the module stays focused on sequencing and control logic. It does not replace device, rendering, or gameplay systems. Instead, it drives those systems through scripted input and observation, providing a stable automation layer for quality and debugging work.

## Imports

- `event`: Imports or references `event` from `src/event/`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Files

### mod.rs

- Defines the automation module boundary for deterministic input replay and scripted verification flows.
- Groups script parsing, playback simulation, and typed step contracts under one coherent runtime surface.
- Serves as the composition entry for test-like interaction automation inside engine execution.

### script.rs

- Implements automation script storage as named, time-ordered step sequences for deterministic replay.
- Parses TOML definitions into typed runtime steps with metadata and validated field extraction.
- Expands repeat directives into concrete scheduled steps at computed temporal offsets.
- Enforces bounded script size to protect playback and memory behavior under large inputs.
- Maintains stable chronological ordering so simulator playback semantics stay predictable.

### simulator.rs

- Implements deterministic automation playback that advances script time and dispatches input events.
- Maintains registries of named scripts and macros for reusable scenario composition.
- Evaluates boolean condition expressions to gate control-flow steps and assertion behavior.
- Supports pause, resume, and speed scaling so runs can be inspected or accelerated as needed.
- Inlines macro calls into active playback flow while preserving temporal consistency.
- Executes visual assertions through baseline comparison with configurable tolerance thresholds.
- Stops or reports on failed assertions to provide reliable test-signal semantics during playback.
- Decouples event emission via sink abstractions to support runtime and test harness integration.
- Tracks simulator state transitions and progression indices for deterministic repeatability.
- Serves as the execution core for scripted automation scenarios and regression validation.

### step.rs

- Defines typed automation step contracts that describe input actions and control-flow intent.
- Covers keyboard, mouse, wheel, text, wait, macro, and assertion-oriented event categories.
- Stores optional action payload fields in one flexible step record consumed by script playback.
- Maps textual action tags to enum variants for deterministic parse and dispatch behavior.
- Supplies repeat and interval semantics used during script expansion and schedule construction.

## Lua API Ref

### Functions

- `lurek.automation.getCondition`: Returns a named automation condition value.
- `lurek.automation.getCurrentScript`: Returns the current script name when a script is active.
- `lurek.automation.getCurrentStep`: Returns the current step index of the active script.
- `lurek.automation.getElapsedTime`: Returns elapsed playback time for the current script.
- `lurek.automation.getLastError`: Returns the last automation error message when one exists.
- `lurek.automation.getPlaybackSpeed`: Returns automation playback speed multiplier.
- `lurek.automation.getScripts`: Returns the names of loaded automation scripts.
- `lurek.automation.getStepCount`: Returns the number of steps in the active script.
- `lurek.automation.getStepLimit`: Returns the configured step limit for a loaded script.
- `lurek.automation.hasMacro`: Returns whether a macro is saved. This function is exposed to Lua scripts.
- `lurek.automation.hasScript`: Returns whether a script is loaded.
- `lurek.automation.isComplete`: Returns whether the current automation script completed.
- `lurek.automation.isFailed`: Returns whether the current automation script failed.
- `lurek.automation.isHighlightMode`: Returns whether automation highlight mode is enabled.
- `lurek.automation.isPaused`: Returns whether automation playback is paused.
- `lurek.automation.isRunning`: Returns whether automation playback is running.
- `lurek.automation.listMacros`: Returns the names of saved macros. This function is exposed to Lua scripts.
- `lurek.automation.load`: Loads an automation script from a Lua table of steps and optional metadata.
- `lurek.automation.loadFromToml`: Loads an automation script from TOML text.
- `lurek.automation.pause`: Pauses automation playback. This function is exposed to Lua scripts.
- `lurek.automation.playMacro`: Starts playback of a saved macro. This function is exposed to Lua scripts.
- `lurek.automation.resume`: Resumes automation playback. This function is exposed to Lua scripts.
- `lurek.automation.saveMacro`: Saves a loaded script as a named macro.
- `lurek.automation.setCondition`: Sets a named boolean condition used by automation steps.
- `lurek.automation.setHighlightMode`: Enables or disables automation highlight mode.
- `lurek.automation.setPlaybackSpeed`: Sets automation playback speed multiplier.
- `lurek.automation.setStepLimit`: Sets the maximum step count for a loaded script.
- `lurek.automation.start`: Starts playback of a loaded automation script.
- `lurek.automation.stop`: Stops the current automation script.
- `lurek.automation.unload`: Unloads a named automation script.
- `lurek.automation.update`: Advances automation playback and dispatches generated input events.
- `lurek.automation.waitUntil`: Suspends automation updates until a predicate returns true or a timeout elapses.

### Callbacks

- `lurek.automation.waitUntil` param `predicate` (`function`): Function called each update; true resolves the wait.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.
