# Automation

## Purpose

Replays precise input steps, chords, device actions, and visual test assertions.

## Summary

- The `automation` module is the scripted replay layer for users who want deterministic QA, repeatable demos, or regression-oriented gameplay checks.
- It turns authored steps into real runtime input flow, covering the parsing of automation scripts, ordered playback, and step-level control over how the scenario advances.
- Steps can model keyboard, mouse, wheel, text, touch, and gamepad input, including positions, click counts, axis values, pressure, and duration-generated release events.
- Chord steps such as `ctrl+a` or `shift+mouse1` are authored as one automation event but replay as the same primitive callbacks and input-state transitions that real user input would produce.
- Simulation and assertion features work together here: the same module can replay actions, wait on conditions, and verify visual or behavioral outcomes under the same timing rules.
- Determinism is the key promise: authored steps should replay under controlled timing.
- Read it as the coordination layer above raw input and clocks. Neighboring modules provide the low-level events and timing primitives, while `automation` turns them into a reusable test workflow.

This module primarily collaborates with `event`, `input`, `runtime`, `timer`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

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
    lurek.log.info(tostring("ready = " .. tostring(val)))
    lurek.log.info(tostring("missing_condition = " .. tostring(missing)))
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
    lurek.log.info(tostring("current script = " .. tostring(name)))
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
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
    lurek.log.info(tostring("current step = " .. tostring(step)))
    lurek.log.info(tostring("step count = " .. tostring(lurek.automation.getStepCount())))
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
    lurek.log.info(tostring("elapsed = " .. tostring(t) .. "s"))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
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
    lurek.log.info(tostring("last error = " .. tostring(err)))
    lurek.log.info(tostring("failed = " .. tostring(failed)))
    lurek.log.info(tostring("has error text = " .. tostring(err ~= nil and err ~= "")))
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
    lurek.log.info(tostring("playback speed = " .. tostring(speed)))
    lurek.log.info(tostring("speed query completed"))
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
    lurek.log.info(tostring("loaded scripts = " .. #scripts))
    lurek.log.info(tostring("first script = " .. tostring(scripts[1])))
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
    lurek.log.info(tostring("step count = " .. tostring(count)))
    lurek.log.info(tostring("current step = " .. tostring(lurek.automation.getCurrentStep())))
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
    lurek.log.info(tostring("step limit for run_test = " .. tostring(limit)))
    lurek.log.info(tostring("step limit for limit_query = " .. tostring(loaded_limit)))
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
    lurek.log.info(tostring("has macro = " .. tostring(has)))
    lurek.log.info(tostring("macro count = " .. tostring(#lurek.automation.listMacros())))
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
    lurek.log.info(tostring("has nonexistent = " .. tostring(has)))
    lurek.log.info(tostring("has status_check = " .. tostring(loaded)))
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
    lurek.log.info(tostring("isComplete = " .. tostring(done)))
    lurek.log.info(tostring("current step = " .. tostring(lurek.automation.getCurrentStep())))
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
    lurek.log.info(tostring("last error = " .. tostring(err)))
    lurek.log.info(tostring("isFailed = " .. tostring(failed)))
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
    lurek.log.info(tostring("highlight mode = " .. tostring(hl)))
    lurek.automation.setHighlightMode(false)
    lurek.log.info(tostring("highlight mode after reset = " .. tostring(lurek.automation.isHighlightMode())))
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
    lurek.log.info(tostring("isPaused = " .. tostring(paused)))
    lurek.automation.resume()
    lurek.log.info(tostring("isPaused after resume = " .. tostring(lurek.automation.isPaused())))
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
    lurek.log.info(tostring("isRunning = " .. tostring(running)))
    lurek.automation.stop()
    lurek.log.info(tostring("isRunning after stop = " .. tostring(lurek.automation.isRunning())))
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
    lurek.log.info(tostring("macros = " .. #macros))
    lurek.log.info(tostring("first macro = " .. tostring(macros[1])))
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
    lurek.log.info(tostring("loaded = " .. tostring(lurek.automation.hasScript("login_flow"))))
    lurek.log.info(tostring("script count = " .. tostring(#scripts)))
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
    lurek.log.info(tostring("loaded from TOML = " .. tostring(lurek.automation.hasScript("toml_script"))))
    lurek.log.info(tostring("script count = " .. tostring(#scripts)))
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
    lurek.log.info(tostring("paused = " .. tostring(lurek.automation.isPaused())))
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
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
    lurek.log.info(tostring("macro playing = " .. tostring(lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
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
    lurek.log.info(tostring("paused after resume = " .. tostring(lurek.automation.isPaused())))
    lurek.log.info(tostring("running after resume = " .. tostring(lurek.automation.isRunning())))
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
    lurek.log.info(tostring("macro saved = " .. tostring(lurek.automation.hasMacro("fast_login"))))
    lurek.log.info(tostring("macro count = " .. tostring(#lurek.automation.listMacros())))
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
    lurek.log.info(tostring("condition set"))
    lurek.log.info(tostring("logged_in = " .. tostring(lurek.automation.getCondition("logged_in"))))
    lurek.log.info(tostring("ready = " .. tostring(lurek.automation.getCondition("ready"))))
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
    lurek.log.info(tostring("highlight before = " .. tostring(before)))
    lurek.log.info(tostring("highlight = " .. tostring(lurek.automation.isHighlightMode())))
    lurek.automation.setHighlightMode(false)
    lurek.log.info(tostring("highlight after reset = " .. tostring(lurek.automation.isHighlightMode())))
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
    lurek.log.info(tostring("configured speed = 2.0"))
    lurek.log.info(tostring("speed before = " .. tostring(before)))
    lurek.log.info(tostring("speed = " .. tostring(lurek.automation.getPlaybackSpeed())))
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
    lurek.log.info(tostring("step limit updated = " .. tostring(ok)))
    lurek.log.info(tostring("step limit = " .. tostring(lurek.automation.getStepLimit("limit_set"))))
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
    lurek.log.info(tostring("running = " .. tostring(lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(current)))
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
    lurek.log.info(tostring("stopped = " .. tostring(not lurek.automation.isRunning())))
    lurek.log.info(tostring("current script = " .. tostring(lurek.automation.getCurrentScript())))
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
    lurek.log.info(tostring("loaded before unload = " .. tostring(loaded)))
    lurek.log.info(tostring("unloaded = " .. tostring(not lurek.automation.hasScript("temp_script"))))
    lurek.log.info(tostring("loaded after unload = " .. tostring(still_loaded)))
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
    lurek.log.info(tostring("updated by 16ms"))
    lurek.log.info(tostring("elapsed = " .. tostring(lurek.automation.getElapsedTime())))

    lurek.automation.load("input_replay", {
        steps = {
            { action = "combo", time = 0.10, combo = { "ctrl", "a" }, duration = 0.05 },
            { action = "mousepress", time = 0.20, x = 120, y = 80, button = 1, clicks = 2, duration = 0.03 },
            { action = "gamepadpress", time = 0.30, gamepad = 0, gamepadButton = 0, buttonName = "south", duration = 0.10 },
            { action = "touchpress", time = 0.40, id = 1, x = 64, y = 64, pressure = 1.0, duration = 0.10 },
        },
    })
    lurek.automation.start("input_replay")
    lurek.automation.update(0.50)
    lurek.log.info(tostring("input replay step = " .. tostring(lurek.automation.getCurrentStep())))
    lurek.log.info(tostring("gamepad down = " .. tostring(lurek.input.gamepad.isDown(0, 0))))
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
    lurek.log.info(tostring("waitUntil registered with 5s timeout"))
    lurek.log.info(tostring("ready = " .. tostring(lurek.automation.getCondition("ready"))))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.automation.waitUntil` param `predicate` (`function`): Function called each update; true resolves the wait.

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
