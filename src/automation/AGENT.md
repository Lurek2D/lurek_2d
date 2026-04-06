# `automation` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status** | Implemented — Full |
| **Lua API** | `luna.automation` |
| **Source** | `src/automation/` |
| **Rust Tests** | `tests/unit/automation_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_automation.lua` |
| **Architecture** | — |

## Summary

The `automation` module provides automated input simulation through timed step scripts.
It is a Tier 1 Engine Subsystem that depends only on `crate::math`, `crate::engine`, and
`crate::event`.

A `Script` contains an ordered list of `Step` records, each with a timestamp and an `Action`
variant — one of eight kinds: `KeyPress`, `KeyRelease`, `TextInput`, `MouseMove`, `MousePress`,
`MouseRelease`, `WheelMove`, and `Wait`. The `Simulator` plays back a loaded script by comparing
the elapsed game time against each step's timestamp and injecting the corresponding synthetic
event into the engine's `EventQueue`.

Primary use-cases are headless integration tests, QA regression replay, speedrun verification,
and recorded developer input sessions. Scripts can be serialised to/from Lua tables for storage.

**Scope boundary**: The `automation` module only injects events into the queue; it does not
consume them. Actual input handling remains in `src/input/`. Steps beyond `MAX_STEPS` are
silently dropped to cap memory footprint.
## Architecture

```
automation (module root)
  ├── script.rs — Script container for the automation simulation module. This module provides the [`Script`] struct — a named, time-sorted, capacity-capped collection of [`Step`] objects. Scripts are stored in the [`Simulator`](super::Simulator) by name and selected for playback via [`Simulator::start`](super::Simulator::start). The step cap of [`MAX_STEPS`] guards against unbounded memory allocation from large or adversarially constructed input scripts (CSF-010 allocation guard).
  ├── simulator.rs — Playback engine for the automation simulation module. This module provides the [`Simulator`] struct and the private [`PlaybackState`] enum that drives it. The [`Simulator`] holds a named collection of [`Script`] objects and plays back the active script by injecting synthetic input events into the engine's [`EventQueue`] on each [`Simulator::update`] call. ## Playback lifecycle 1. Load one or more scripts with [`Simulator::load`]. 2. Call [`Simulator::start`] to select a script and begin playback. 3. Call [`Simulator::update`] once per frame, passing the delta time. 4. The simulator advances its internal elapsed counter and dispatches all steps whose `time <= elapsed`. Each step fires at most once. 5. When all steps are dispatched the state transitions to `Complete`. Playback can be paused and resumed at any point. Stopping resets the elapsed counter and step index back to zero.
  ├── step.rs — Step definitions for the automation simulation module. This module provides the [`Action`] enum and [`Step`] struct that form the building blocks of a simulation script. A `Step` pairs a wall-clock offset (seconds from script start) with an action type and optional action-specific parameters such as key name, mouse coordinates, button index, and text. Steps are created programmatically and collected into a [`Script`](super::Script) to be played back by the [`Simulator`](super::Simulator).
```

## Source Files

| File | Purpose |
|------|---------|
| `script.rs` | Script container for the automation simulation module. This module provides the [`Script`] struct — a named, time-sorted, capacity-capped collection of [`Step`] objects. Scripts are stored in the [`Simulator`](super::Simulator) by name and selected for playback via [`Simulator::start`](super::Simulator::start). The step cap of [`MAX_STEPS`] guards against unbounded memory allocation from large or adversarially constructed input scripts (CSF-010 allocation guard). |
| `simulator.rs` | Playback engine for the automation simulation module. This module provides the [`Simulator`] struct and the private [`PlaybackState`] enum that drives it. The [`Simulator`] holds a named collection of [`Script`] objects and plays back the active script by injecting synthetic input events into the engine's [`EventQueue`] on each [`Simulator::update`] call. ## Playback lifecycle 1. Load one or more scripts with [`Simulator::load`]. 2. Call [`Simulator::start`] to select a script and begin playback. 3. Call [`Simulator::update`] once per frame, passing the delta time. 4. The simulator advances its internal elapsed counter and dispatches all steps whose `time <= elapsed`. Each step fires at most once. 5. When all steps are dispatched the state transitions to `Complete`. Playback can be paused and resumed at any point. Stopping resets the elapsed counter and step index back to zero. |
| `step.rs` | Step definitions for the automation simulation module. This module provides the [`Action`] enum and [`Step`] struct that form the building blocks of a simulation script. A `Step` pairs a wall-clock offset (seconds from script start) with an action type and optional action-specific parameters such as key name, mouse coordinates, button index, and text. Steps are created programmatically and collected into a [`Script`](super::Script) to be played back by the [`Simulator`](super::Simulator). |

## Submodules

### `automation::script`

Script container for the automation simulation module. This module provides the [`Script`] struct — a named, time-sorted, capacity-capped collection of [`Step`] objects. Scripts are stored in the [`Simulator`](super::Simulator) by name and selected for playback via [`Simulator::start`](super::Simulator::start). The step cap of [`MAX_STEPS`] guards against unbounded memory allocation from large or adversarially constructed input scripts (CSF-010 allocation guard).

- **`Script`** (struct): TODO: one-line description.

### `automation::simulator`

Playback engine for the automation simulation module. This module provides the [`Simulator`] struct and the private [`PlaybackState`] enum that drives it. The [`Simulator`] holds a named collection of [`Script`] objects and plays back the active script by injecting synthetic input events into the engine's [`EventQueue`] on each [`Simulator::update`] call. ## Playback lifecycle 1. Load one or more scripts with [`Simulator::load`]. 2. Call [`Simulator::start`] to select a script and begin playback. 3. Call [`Simulator::update`] once per frame, passing the delta time. 4. The simulator advances its internal elapsed counter and dispatches all steps whose `time <= elapsed`. Each step fires at most once. 5. When all steps are dispatched the state transitions to `Complete`. Playback can be paused and resumed at any point. Stopping resets the elapsed counter and step index back to zero.

- **`Simulator`** (struct): TODO: one-line description.

### `automation::step`

Step definitions for the automation simulation module. This module provides the [`Action`] enum and [`Step`] struct that form the building blocks of a simulation script. A `Step` pairs a wall-clock offset (seconds from script start) with an action type and optional action-specific parameters such as key name, mouse coordinates, button index, and text. Steps are created programmatically and collected into a [`Script`](super::Script) to be played back by the [`Simulator`](super::Simulator).

- **`Step`** (struct): TODO: one-line description.
- **`Action`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `automation::script::Script`

TODO: description from `///` doc comment.

#### `automation::simulator::Simulator`

TODO: description from `///` doc comment.

#### `automation::step::Step`

TODO: description from `///` doc comment.

### Enums

#### `automation::step::Action`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.automation.*` by `src\lua_api\automation_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `simulator`.

## Lua Examples

```lua
-- Example: Basic automation usage
function luna.load()
    -- TODO: replace with real automation setup
    local obj = luna.automation.simulator()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 3 |
| `enum`   | 1 |
| `fn`     | 0 |
| **Total** | **4** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
