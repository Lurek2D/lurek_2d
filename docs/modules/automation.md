# Automation

## Summary

The `automation` module provides deterministic scripted input playback and assertion-driven simulation used by tests, CI scenarios, and reproducible tool flows. It models automation as time-sorted step sequences and executes them through a simulator that can drive virtual input, macro expansion, conditional actions, and verification checks.

`script.rs` owns script structure and parsing concerns, including normalization and repeat expansion. `step.rs` defines the typed action vocabulary (`Action`, `Step`) used to represent replayable behavior. `simulator.rs` executes those steps against runtime state with strict ordering, enabling controlled replay instead of device-dependent live interaction.

A key architectural property is determinism: scenarios are encoded as data and replayed under engine control rather than by flaky external tooling. That makes this module suitable for regression checks where timing and ordering must remain stable across runs.

Because it is a feature-system integration tool, it should remain focused on sequencing, condition evaluation, and assertions. Device drivers, rendering internals, and gameplay domain logic are inputs to automation scenarios, not responsibilities of this module.

Implementation detail and boundary guarantees for automation: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: mod.rs: Automation subsystem for deterministic input replay and visual regression testing.; script.rs: Automation script container: named, time-sorted step sequences for deterministic replay.; simulator.rs: Automation simulator: drives script playback by advancing time and dispatching events.; step.rs: Action enum and Step struct: typed event descriptors for automation playback.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

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

## Functions

### `lurek.automation.getCondition`

Returns a named automation condition value.

```lua
lurek.automation.getCondition(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Condition name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Current condition value. |

**Example**

```lua
do
    lurek.automation.setCondition("ready", true)
    local val = lurek.automation.getCondition("ready")
    print("ready = " .. tostring(val))
end
```

---

### `lurek.automation.getCurrentScript`

Returns the current script name when a script is active.

```lua
lurek.automation.getCurrentScript()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current script name, or nil when no script is active. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("current_test", { steps = steps })
    lurek.automation.start("current_test")
    local name = lurek.automation.getCurrentScript()
    print("current script = " .. tostring(name))
    print("running = " .. tostring(lurek.automation.isRunning()))
end
```

---

### `lurek.automation.getCurrentStep`

Returns the current step index of the active script.

```lua
lurek.automation.getCurrentStep()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current step index. |

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("step_test", { steps = steps })
    lurek.automation.start("step_test")
    local step = lurek.automation.getCurrentStep()
    print("current step = " .. tostring(step))
    print("step count = " .. tostring(lurek.automation.getStepCount()))
end
```

---

### `lurek.automation.getElapsedTime`

Returns elapsed playback time for the current script.

```lua
lurek.automation.getElapsedTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Elapsed time in seconds. |

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
    }
    lurek.automation.load("elapsed_test", { steps = steps })
    lurek.automation.start("elapsed_test")
    lurek.automation.update(0.05)
    local t = lurek.automation.getElapsedTime()
    print("elapsed = " .. tostring(t) .. "s")
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end
```

---

### `lurek.automation.getLastError`

Returns the last automation error message when one exists.

```lua
lurek.automation.getLastError()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Last error string, or nil when no error is stored. |

**Example**

```lua
do
    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    print("last error = " .. tostring(err))
    print("failed = " .. tostring(lurek.automation.isFailed()))
end
```

---

### `lurek.automation.getPlaybackSpeed`

Returns automation playback speed multiplier.

```lua
lurek.automation.getPlaybackSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current playback speed multiplier. |

**Example**

```lua
do
    local speed = lurek.automation.getPlaybackSpeed()
    print("playback speed = " .. tostring(speed))
    print("speed query completed")
end
```

---

### `lurek.automation.getScripts`

Returns the names of loaded automation scripts.

```lua
lurek.automation.getScripts()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Script names. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("list_one", { steps = steps })
    lurek.automation.load("list_two", { steps = steps })
    local scripts = lurek.automation.getScripts()
    print("loaded scripts = " .. #scripts)
    print("first script = " .. tostring(scripts[1]))
end
```

---

### `lurek.automation.getStepCount`

Returns the number of steps in the active script.

```lua
lurek.automation.getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active script step count. |

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.2 },
        { action = "wait", time = 0.4 },
    }
    lurek.automation.load("count_test", { steps = steps })
    lurek.automation.start("count_test")
    local count = lurek.automation.getStepCount()
    print("step count = " .. tostring(count))
    print("current step = " .. tostring(lurek.automation.getCurrentStep()))
end
```

---

### `lurek.automation.getStepLimit`

Returns the configured step limit for a loaded script.

```lua
lurek.automation.getStepLimit(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Step limit, or nil when no limit is set. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_query", { steps = steps })
    local limit = lurek.automation.getStepLimit("run_test")
    local loaded_limit = lurek.automation.getStepLimit("limit_query")
    print("step limit for run_test = " .. tostring(limit))
    print("step limit for limit_query = " .. tostring(loaded_limit))
end
```

---

### `lurek.automation.hasMacro`

Returns whether a macro is saved. This function is exposed to Lua scripts.

```lua
lurek.automation.hasMacro(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Macro name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the macro exists. |

**Example**

```lua
do
    local has = lurek.automation.hasMacro("fast_login")
    print("has macro = " .. tostring(has))
end
```

---

### `lurek.automation.hasScript`

Returns whether a script is loaded.

```lua
lurek.automation.hasScript(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the script is loaded. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("status_check", { steps = steps })
    local has = lurek.automation.hasScript("nonexistent")
    local loaded = lurek.automation.hasScript("status_check")
    print("has nonexistent = " .. tostring(has))
    print("has status_check = " .. tostring(loaded))
end
```

---

### `lurek.automation.isComplete`

Returns whether the current automation script completed.

```lua
lurek.automation.isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the current script has completed. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("complete_test", { steps = steps })
    lurek.automation.start("complete_test")
    lurek.automation.update(0.1)
    local done = lurek.automation.isComplete()
    print("isComplete = " .. tostring(done))
    print("current step = " .. tostring(lurek.automation.getCurrentStep()))
end
```

---

### `lurek.automation.isFailed`

Returns whether the current automation script failed.

```lua
lurek.automation.isFailed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the current script has failed. |

**Example**

```lua
do
    local failed = lurek.automation.isFailed()
    print("isFailed = " .. tostring(failed))
end
```

---

### `lurek.automation.isHighlightMode`

Returns whether automation highlight mode is enabled.

```lua
lurek.automation.isHighlightMode()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when highlight mode is enabled. |

**Example**

```lua
do
    lurek.automation.setHighlightMode(true)
    local hl = lurek.automation.isHighlightMode()
    print("highlight mode = " .. tostring(hl))
    lurek.automation.setHighlightMode(false)
    print("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode()))
end
```

---

### `lurek.automation.isPaused`

Returns whether automation playback is paused.

```lua
lurek.automation.isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when playback is paused. |

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("paused_test", { steps = steps })
    lurek.automation.start("paused_test")
    lurek.automation.pause()
    local paused = lurek.automation.isPaused()
    print("isPaused = " .. tostring(paused))
    lurek.automation.resume()
    print("isPaused after resume = " .. tostring(lurek.automation.isPaused()))
end
```

---

### `lurek.automation.isRunning`

Returns whether automation playback is running.

```lua
lurek.automation.isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a script is running. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("running_test", { steps = steps })
    lurek.automation.start("running_test")
    local running = lurek.automation.isRunning()
    print("isRunning = " .. tostring(running))
    lurek.automation.stop()
    print("isRunning after stop = " .. tostring(lurek.automation.isRunning()))
end
```

---

### `lurek.automation.listMacros`

Returns the names of saved macros. This function is exposed to Lua scripts.

```lua
lurek.automation.listMacros()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Macro names. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_list_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_list_source")
    local macros = lurek.automation.listMacros()
    print("macros = " .. #macros)
    print("first macro = " .. tostring(macros[1]))
end
```

---

### `lurek.automation.load`

Loads an automation script from a Lua table of steps and optional metadata.

```lua
lurek.automation.load(name, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name used by `start`, macros, and lookup calls. |
| `data` | table | Script data table with a `steps` array and optional `meta.description` string. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("login_flow", { steps = steps })
    print("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
end
```

---

### `lurek.automation.loadFromToml`

Loads an automation script from TOML text.

```lua
lurek.automation.loadFromToml(name, toml_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name used by `start`, macros, and lookup calls. |
| `toml_str` | string | TOML automation script contents. |

**Example**

```lua
do
    local toml = "[[steps]]\naction = \"wait\"\ntime = 0.0\n"
    lurek.automation.loadFromToml("toml_script", toml)
    print("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
end
```

---

### `lurek.automation.pause`

Pauses automation playback. This function is exposed to Lua scripts.

```lua
lurek.automation.pause()
```

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("pause_test", { steps = steps })
    lurek.automation.start("pause_test")
    lurek.automation.pause()
    print("paused = " .. tostring(lurek.automation.isPaused()))
    print("running = " .. tostring(lurek.automation.isRunning()))
end
```

---

### `lurek.automation.playMacro`

Starts playback of a saved macro. This function is exposed to Lua scripts.

```lua
lurek.automation.playMacro(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Macro name to play. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_play_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_play_source")
    lurek.automation.playMacro("fast_login")
    print("macro playing = " .. tostring(lurek.automation.isRunning()))
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end
```

---

### `lurek.automation.resume`

Resumes automation playback. This function is exposed to Lua scripts.

```lua
lurek.automation.resume()
```

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.5 },
    }
    lurek.automation.load("resume_test", { steps = steps })
    lurek.automation.start("resume_test")
    lurek.automation.pause()
    lurek.automation.resume()
    print("paused after resume = " .. tostring(lurek.automation.isPaused()))
    print("running after resume = " .. tostring(lurek.automation.isRunning()))
end
```

---

### `lurek.automation.saveMacro`

Saves a loaded script as a named macro.

```lua
lurek.automation.saveMacro(macro_name, script_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `macro_name` | string | Macro name to save. |
| `script_name` | string | Loaded script name to copy into the macro store. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_source")
    print("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login")))
    print("macro count = " .. tostring(#lurek.automation.listMacros()))
end
```

---

### `lurek.automation.setCondition`

Sets a named boolean condition used by automation steps.

```lua
lurek.automation.setCondition(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Condition name. |
| `value` | boolean | Condition value. |

**Example**

```lua
do
    lurek.automation.setCondition("logged_in", true)
    print("condition set")
    print("logged_in = " .. tostring(lurek.automation.getCondition("logged_in")))
end
```

---

### `lurek.automation.setHighlightMode`

Enables or disables automation highlight mode.

```lua
lurek.automation.setHighlightMode(enable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enable` | boolean | True to enable highlight mode. |

**Example**

```lua
do
    lurek.automation.setHighlightMode(true)
    print("highlight = " .. tostring(lurek.automation.isHighlightMode()))
    lurek.automation.setHighlightMode(false)
    print("highlight after reset = " .. tostring(lurek.automation.isHighlightMode()))
end
```

---

### `lurek.automation.setPlaybackSpeed`

Sets automation playback speed multiplier.

```lua
lurek.automation.setPlaybackSpeed(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Playback speed multiplier. |

**Example**

```lua
do
    lurek.automation.setPlaybackSpeed(2.0)
    print("configured speed = 2.0")
    print("speed = " .. tostring(lurek.automation.getPlaybackSpeed()))
end
```

---

### `lurek.automation.setStepLimit`

Sets the maximum step count for a loaded script.

```lua
lurek.automation.setStepLimit(name, n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name to update. |
| `n` | number | Maximum step count. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the script exists and the limit was set. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("limit_set", { steps = steps })
    local ok = lurek.automation.setStepLimit("limit_set", 1000)
    print("step limit updated = " .. tostring(ok))
    print("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set")))
end
```

---

### `lurek.automation.start`

Starts playback of a loaded automation script.

```lua
lurek.automation.start(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Loaded script name to start. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("run_test", { steps = steps })
    lurek.automation.start("run_test")
    print("running = " .. tostring(lurek.automation.isRunning()))
end
```

---

### `lurek.automation.stop`

Stops the current automation script.

```lua
lurek.automation.stop()
```

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("stop_test", { steps = steps })
    lurek.automation.start("stop_test")
    lurek.automation.stop()
    print("stopped = " .. tostring(not lurek.automation.isRunning()))
    print("current script = " .. tostring(lurek.automation.getCurrentScript()))
end
```

---

### `lurek.automation.unload`

Unloads a named automation script.

```lua
lurek.automation.unload(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Script name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the script existed and was removed. |

**Example**

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("temp_script", { steps = steps })
    lurek.automation.unload("temp_script")
    print("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script")))
end
```

---

### `lurek.automation.update`

Advances automation playback and dispatches generated input events.

```lua
lurek.automation.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local steps = {
        { action = "wait", time = 0.0 },
        { action = "wait", time = 0.1 },
    }
    lurek.automation.load("update_test", { steps = steps })
    lurek.automation.start("update_test")
    lurek.automation.update(0.016)
    print("updated by 16ms")
    print("elapsed = " .. tostring(lurek.automation.getElapsedTime()))
end
```

---

### `lurek.automation.waitUntil`

Suspends automation updates until a predicate returns true or a timeout elapses.

```lua
lurek.automation.waitUntil(predicate, timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `predicate` | function | Function called each update; true resolves the wait. |
| `timeout` | number | Maximum wait duration in seconds. |

**Example**

```lua
do
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    print("waitUntil registered with 5s timeout")
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

*No Lua userdata types detected for this module.*

## Callbacks

- `lurek.automation.waitUntil` param `predicate` (`function`): Function called each update; true resolves the wait.

## Enums

*No module-specific enums documented.*
