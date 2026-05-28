# Automation

- The `automation` module provides a powerful headless input simulation framework designed for automated testing, QA replay, and recorded gameplay sessions.

Positioned within the Feature Systems tier, it enables Lurek2D to execute deterministic, time-sorted sequences of synthetic input events without requiring a visible operating system window or actual hardware interactions. This makes it an invaluable tool for continuous integration pipelines, visual regression testing, and creating in-game replay features.

At the core of the module is the `Script` container, which holds an ordered sequence of `Step` entries. Each `Step` describes a timed action—such as key presses, mouse movements, clicks, scrolling, text input, or wait delays. Scripts can be authored externally in TOML format or constructed dynamically via Lua tables, supporting advanced orchestration capabilities including repeat expansions and configurable step limits to prevent runaway execution. 

Playback is managed by the `Simulator`, an engine that advances virtual time and dispatches events exactly as if they originated from real hardware. The `Simulator` supports complex control flow during playback, including pause and resume functionality, playback speed scaling, and macro invocations where reusable scripts are inlined at the current playback position. Additionally, it features a robust condition evaluation system allowing scripts to branch or assert state based on logical expressions (e.g., `!`, `&&`, `||`, and parentheses) against named boolean flags. 

For visual debugging and regression testing, the module offers unique assertion steps: `Assert` halts playback if a logical condition fails, while `VisualAssert` compares baseline images against actual rendered frames with pixel-diff tolerances. When running with a visible window, developers can enable a `highlight_mode` that overlays action indicators, making it easy to track synthetic inputs visually. The entire framework is fully integrated with the engine's event queue and exposed to Lua via the `lurek.automation.*` namespace, allowing script developers to orchestrate deterministic testing and record-and-playback systems directly from game logic.

## Functions

### `lurek.automation.getCondition`

Returns a named automation condition value.

```lua
-- signature
lurek.automation.getCondition(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Condition name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Current condition value. |

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
-- signature
lurek.automation.getCurrentScript()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current script name, or nil when no script is active. |

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
-- signature
lurek.automation.getCurrentStep()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current step index. |

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
-- signature
lurek.automation.getElapsedTime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Elapsed time in seconds. |

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
-- signature
lurek.automation.getLastError()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Last error string, or nil when no error is stored. |

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
-- signature
lurek.automation.getPlaybackSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current playback speed multiplier. |

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
-- signature
lurek.automation.getScripts()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Script names. |

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
-- signature
lurek.automation.getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Active script step count. |

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
-- signature
lurek.automation.getStepLimit(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Step limit, or nil when no limit is set. |

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
-- signature
lurek.automation.hasMacro(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Macro name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the macro exists. |

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
-- signature
lurek.automation.hasScript(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the script is loaded. |

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
-- signature
lurek.automation.isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the current script has completed. |

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
-- signature
lurek.automation.isFailed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the current script has failed. |

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
-- signature
lurek.automation.isHighlightMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when highlight mode is enabled. |

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
-- signature
lurek.automation.isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when playback is paused. |

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
-- signature
lurek.automation.isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a script is running. |

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
-- signature
lurek.automation.listMacros()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Macro names. |

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
-- signature
lurek.automation.load(name, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name used by `start`, macros, and lookup calls. |
| `data` | `table` | Script data table with a `steps` array and optional `meta.description` string. |

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
-- signature
lurek.automation.loadFromToml(name, toml_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name used by `start`, macros, and lookup calls. |
| `toml_str` | `string` | TOML automation script contents. |

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
-- signature
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
-- signature
lurek.automation.playMacro(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Macro name to play. |

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
-- signature
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
-- signature
lurek.automation.saveMacro(macro_name, script_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `macro_name` | `string` | Macro name to save. |
| `script_name` | `string` | Loaded script name to copy into the macro store. |

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
-- signature
lurek.automation.setCondition(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Condition name. |
| `value` | `boolean` | Condition value. |

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
-- signature
lurek.automation.setHighlightMode(enable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enable` | `boolean` | True to enable highlight mode. |

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
-- signature
lurek.automation.setPlaybackSpeed(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | `number` | Playback speed multiplier. |

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
-- signature
lurek.automation.setStepLimit(name, n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name to update. |
| `n` | `number` | Maximum step count. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the script exists and the limit was set. |

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
-- signature
lurek.automation.start(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Loaded script name to start. |

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
-- signature
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
-- signature
lurek.automation.unload(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Script name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the script existed and was removed. |

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
-- signature
lurek.automation.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Elapsed time in seconds. |

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
-- signature
lurek.automation.waitUntil(predicate, timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `predicate` | `function` | Function called each update; true resolves the wait. |
| `timeout` | `number` | Maximum wait duration in seconds. |

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
