# Automation

## Purpose

Replays input steps and runs visual test assertions.

## When To Use

- It turns authored steps into real runtime input flow, covering the parsing of automation scripts, ordered playback, and step-level control over how the scenario advances.
- Simulation and assertion features work together here: the same module can replay actions, wait on conditions, and verify visual or behavioral outcomes under the same timing rules.
- Determinism is the key promise: authored steps should replay under controlled timing.

## Minimal Example

From the `lurek.automation.load` example block:

```lua
do
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("login_flow", { steps = steps })
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
    example_print_log("script count = " .. tostring(#scripts))
    lurek.automation.unload("login_flow")
end
```

## Common Patterns

- Start with `lurek.automation.getCondition` when exploring this module.
- Start with `lurek.automation.getCurrentScript` when exploring this module.
- Start with `lurek.automation.getCurrentStep` when exploring this module.
- Start with `lurek.automation.getElapsedTime` when exploring this module.
- Start with `lurek.automation.getLastError` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/automation.lua`

## Summary

- The `automation` module is the scripted replay layer for users who want deterministic QA, repeatable demos, or regression-oriented gameplay checks.
- It turns authored steps into real runtime input flow, covering the parsing of automation scripts, ordered playback, and step-level control over how the scenario advances.
- Simulation and assertion features work together here: the same module can replay actions, wait on conditions, and verify visual or behavioral outcomes under the same timing rules.
- Determinism is the key promise: authored steps should replay under controlled timing.
- Read it as the coordination layer above raw input and clocks. Neighboring modules provide the low-level events and timing primitives, while `automation` turns them into a reusable test workflow.

This module primarily collaborates with `event`, `input`, `runtime`, `timer`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

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
    local missing = lurek.automation.getCondition("missing_condition")
    example_print_log("ready = " .. tostring(val))
    example_print_log("missing_condition = " .. tostring(missing))
    lurek.automation.setCondition("ready", false)
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
    example_print_log("current script = " .. tostring(name))
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
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
    example_print_log("current step = " .. tostring(step))
    example_print_log("step count = " .. tostring(lurek.automation.getStepCount()))
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
    example_print_log("elapsed = " .. tostring(t) .. "s")
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
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
    local failed = lurek.automation.isFailed()
    example_print_log("last error = " .. tostring(err))
    example_print_log("failed = " .. tostring(failed))
    example_print_log("has error text = " .. tostring(err ~= nil and err ~= ""))
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
    lurek.automation.setPlaybackSpeed(1.5)
    local speed = lurek.automation.getPlaybackSpeed()
    example_print_log("playback speed = " .. tostring(speed))
    example_print_log("speed query completed")
    lurek.automation.setPlaybackSpeed(1.0)
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
    example_print_log("loaded scripts = " .. #scripts)
    example_print_log("first script = " .. tostring(scripts[1]))
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
    example_print_log("step count = " .. tostring(count))
    example_print_log("current step = " .. tostring(lurek.automation.getCurrentStep()))
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
    example_print_log("step limit for run_test = " .. tostring(limit))
    example_print_log("step limit for limit_query = " .. tostring(loaded_limit))
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
    local steps = { { action = "wait", time = 0.0 } }
    lurek.automation.load("macro_has_source", { steps = steps })
    lurek.automation.saveMacro("fast_login", "macro_has_source")
    local has = lurek.automation.hasMacro("fast_login")
    example_print_log("has macro = " .. tostring(has))
    example_print_log("macro count = " .. tostring(#lurek.automation.listMacros()))
    lurek.automation.unload("macro_has_source")
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
    example_print_log("has nonexistent = " .. tostring(has))
    example_print_log("has status_check = " .. tostring(loaded))
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
    example_print_log("isComplete = " .. tostring(done))
    example_print_log("current step = " .. tostring(lurek.automation.getCurrentStep()))
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
    lurek.automation.stop()
    local err = lurek.automation.getLastError()
    local failed = lurek.automation.isFailed()
    example_print_log("last error = " .. tostring(err))
    example_print_log("isFailed = " .. tostring(failed))
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
    example_print_log("highlight mode = " .. tostring(hl))
    lurek.automation.setHighlightMode(false)
    example_print_log("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode()))
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
    example_print_log("isPaused = " .. tostring(paused))
    lurek.automation.resume()
    example_print_log("isPaused after resume = " .. tostring(lurek.automation.isPaused()))
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
    example_print_log("isRunning = " .. tostring(running))
    lurek.automation.stop()
    example_print_log("isRunning after stop = " .. tostring(lurek.automation.isRunning()))
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
    example_print_log("macros = " .. #macros)
    example_print_log("first macro = " .. tostring(macros[1]))
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
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded = " .. tostring(lurek.automation.hasScript("login_flow")))
    example_print_log("script count = " .. tostring(#scripts))
    lurek.automation.unload("login_flow")
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
    local scripts = lurek.automation.getScripts()
    example_print_log("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script")))
    example_print_log("script count = " .. tostring(#scripts))
    lurek.automation.unload("toml_script")
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
    example_print_log("paused = " .. tostring(lurek.automation.isPaused()))
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
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
    example_print_log("macro playing = " .. tostring(lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
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
    example_print_log("paused after resume = " .. tostring(lurek.automation.isPaused()))
    example_print_log("running after resume = " .. tostring(lurek.automation.isRunning()))
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
    example_print_log("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login")))
    example_print_log("macro count = " .. tostring(#lurek.automation.listMacros()))
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
    lurek.automation.setCondition("ready", false)
    example_print_log("condition set")
    example_print_log("logged_in = " .. tostring(lurek.automation.getCondition("logged_in")))
    example_print_log("ready = " .. tostring(lurek.automation.getCondition("ready")))
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
    local before = lurek.automation.isHighlightMode()
    lurek.automation.setHighlightMode(true)
    example_print_log("highlight before = " .. tostring(before))
    example_print_log("highlight = " .. tostring(lurek.automation.isHighlightMode()))
    lurek.automation.setHighlightMode(false)
    example_print_log("highlight after reset = " .. tostring(lurek.automation.isHighlightMode()))
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
    local before = lurek.automation.getPlaybackSpeed()
    lurek.automation.setPlaybackSpeed(2.0)
    example_print_log("configured speed = 2.0")
    example_print_log("speed before = " .. tostring(before))
    example_print_log("speed = " .. tostring(lurek.automation.getPlaybackSpeed()))
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
    example_print_log("step limit updated = " .. tostring(ok))
    example_print_log("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set")))
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
    local current = lurek.automation.getCurrentScript()
    example_print_log("running = " .. tostring(lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(current))
    lurek.automation.stop()
    lurek.automation.unload("run_test")
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
    example_print_log("stopped = " .. tostring(not lurek.automation.isRunning()))
    example_print_log("current script = " .. tostring(lurek.automation.getCurrentScript()))
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
    local loaded = lurek.automation.hasScript("temp_script")
    lurek.automation.unload("temp_script")
    local still_loaded = lurek.automation.hasScript("temp_script")
    example_print_log("loaded before unload = " .. tostring(loaded))
    example_print_log("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script")))
    example_print_log("loaded after unload = " .. tostring(still_loaded))
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
    example_print_log("updated by 16ms")
    example_print_log("elapsed = " .. tostring(lurek.automation.getElapsedTime()))
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
    lurek.automation.setCondition("ready", false)
    lurek.automation.waitUntil(function()
        return lurek.automation.getCondition("ready")
    end, 5.0)
    lurek.automation.setCondition("ready", true)
    example_print_log("waitUntil registered with 5s timeout")
    example_print_log("ready = " .. tostring(lurek.automation.getCondition("ready")))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.automation.waitUntil` param `predicate` (`function`): Function called each update; true resolves the wait.

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
