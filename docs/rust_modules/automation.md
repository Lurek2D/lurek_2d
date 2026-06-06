# automation

## General Info

- Module group: `Feature Systems`
- Source path: `src/automation/`
- Binding: `src/lua_api/automation_api.rs`
- Namespace: `lurek.automation`
- Lua API surface: `32` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/automation_tests.rs
- Lua test path(s): tests/lua/unit/test_automation_core_unit.lua, tests/lua/integration/test_automation_event.lua

## Summary

The automation module delivers a deterministic input replay and scripted verification pipeline for Lurek2D. Its core purpose is to programmatically simulate human player interactions—including keyboard, mouse, and text inputs—to test gameplay behaviors. It parses ordered step sequences from TOML or Lua tables, expanding repeat directives and time intervals into concrete playback schedules.

Simulation playback supports real-time pausing, resuming, speed scaling, and macro reuse. Scripts can wait for predicates, run conditional steps gated by boolean flags, and execute visual assertions with configurable error tolerances, enabling robust regression verification.

## Files

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/automation/mod.rs)

- Defines the automation module boundary for deterministic input replay and scripted verification flows.
- Groups script parsing, playback simulation, and typed step contracts under one coherent runtime surface.
- Serves as the composition entry for test-like interaction automation inside engine execution.

### [script.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/automation/script.rs)

- Implements automation script storage as named, time-ordered step sequences for deterministic replay.
- Parses TOML definitions into typed runtime steps with metadata and validated field extraction.
- Expands repeat directives into concrete scheduled steps at computed temporal offsets.
- Enforces bounded script size to protect playback and memory behavior under large inputs.
- Maintains stable chronological ordering so simulator playback semantics stay predictable.

### [simulator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/automation/simulator.rs)

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

### [step.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/automation/step.rs)

- Defines typed automation step contracts that describe input actions and control-flow intent.
- Covers keyboard, mouse, wheel, text, wait, macro, and assertion-oriented event categories.
- Stores optional action payload fields in one flexible step record consumed by script playback.
- Maps textual action tags to enum variants for deterministic parse and dispatch behavior.
- Supplies repeat and interval semantics used during script expansion and schedule construction.
