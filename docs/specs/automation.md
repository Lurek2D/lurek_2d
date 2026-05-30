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

The `automation` module provides deterministic scripted input playback and assertion-driven simulation used by tests, CI scenarios, and reproducible tool flows. It models automation as time-sorted step sequences and executes them through a simulator that can drive virtual input, macro expansion, conditional actions, and verification checks.

`script.rs` owns script structure and parsing concerns, including normalization and repeat expansion. `step.rs` defines the typed action vocabulary (`Action`, `Step`) used to represent replayable behavior. `simulator.rs` executes those steps against runtime state with strict ordering, enabling controlled replay instead of device-dependent live interaction.

A key architectural property is determinism: scenarios are encoded as data and replayed under engine control rather than by flaky external tooling. That makes this module suitable for regression checks where timing and ordering must remain stable across runs.

Because it is a feature-system integration tool, it should remain focused on sequencing, condition evaluation, and assertions. Device drivers, rendering internals, and gameplay domain logic are inputs to automation scenarios, not responsibilities of this module.

Implementation detail and boundary guarantees for automation: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: mod.rs: Automation subsystem for deterministic input replay and visual regression testing.; script.rs: Automation script container: named, time-sorted step sequences for deterministic replay.; simulator.rs: Automation simulator: drives script playback by advancing time and dispatching events.; step.rs: Action enum and Step struct: typed event descriptors for automation playback.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

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

- Binding: `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`

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

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `event`: Imports or references `event` from `src/event/`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
