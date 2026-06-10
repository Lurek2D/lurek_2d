# Runtime

## Summary

- The runtime module is the shared execution core that coordinates engine state across systems.
- It owns the central mutable state container used during startup and per-frame updates.
- Shared state includes timing, input snapshots, window-related state, and feature handles.
- Resource pools for textures, fonts, canvases, shaders, and meshes are coordinated here.
- Resource budgets and usage stats are tracked to support observability and policy.
- Configuration models are typed and loaded from TOML with controlled defaults.
- Runtime modes separate windowed execution from headless execution paths.
- Reload revision tracking supports controlled runtime configuration refresh.
- Error contracts provide stable codes and snapshot-oriented diagnostics.
- Log message identifiers standardize machine-readable diagnostics across modules.
- Message catalogs support lazy lookup and fallback behavior.
- Frame profiling captures phase timing for update/render callback visibility.
- Typed resource keys provide stable cross-module handles.
- Host/environment queries expose platform and process context to script APIs.
- Runtime services include clipboard and locale integration points.
- Higher-level modules depend on runtime as source-of-truth.
- The module avoids owning game-domain policy.
- It owns lifecycle policy, state ownership, and core diagnostics.
- Deterministic state progression is a central invariant.
- Stable error/reporting contracts are another core invariant.
- Runtime is the root integration layer for engine execution behavior.
- It defines common contracts that keep module interactions coherent.
- The module is essential for startup, frame loop, and host-facing integration stability.
- Overall, runtime is the Core Runtime anchor for the dependency graph.
- It keeps shared execution behavior explicit, observable, and maintainable.
- Without it, resource and lifecycle ownership would fragment across subsystems.

This module primarily collaborates with `audio`, `camera`, `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, and adjacent engine modules. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.runtime.errorSnapshot`

Creates a JSON-encoded error snapshot from a message string, useful for diagnostics and error reporting.

```lua
lurek.runtime.errorSnapshot(msg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | string | The error message to capture. |

**Returns**

| Type | Description |
|------|-------------|
| string | JSON string containing the error snapshot with stack and context information. |

**Example**

```lua
do
    local snapshot = lurek.runtime.errorSnapshot("Something went wrong in level 3")
    print("snapshot type = " .. type(snapshot))
    print("snapshot length = " .. #snapshot)
    print("contains message field = " .. tostring(snapshot:find('"message"') ~= nil))
end
```

---

### `lurek.runtime.getArch`

Returns the CPU architecture of the host system.

```lua
lurek.runtime.getArch()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Architecture identifier (e.g. `"x86_64"`, `"aarch64"`). |

**Example**

```lua
do
    local arch = lurek.runtime.getArch()
    print("arch = " .. arch)
end
```

---

### `lurek.runtime.getArgs`

Returns the command-line arguments passed to the engine as a 1-indexed table of strings.

```lua
lurek.runtime.getArgs()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Argument strings. |

**Example**

```lua
do
    local args = lurek.runtime.getArgs()
    print("raw args count = " .. #args)
    print("first arg = " .. tostring(args[1]))
end
```

---

### `lurek.runtime.getBatchResults`

Summarizes batch results by counting passed, failed, and skipped tasks.

```lua
lurek.runtime.getBatchResults(results)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `results` | table | The results table returned by `runBatch`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Count of passed tasks. |
| number | Count of failed tasks. |
| number | Count of skipped tasks. |

**Example**

```lua
do
    local results = {
        ok = { status = "passed" },
        bad = { status = "failed" },
        later = { status = "skipped" },
    }
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("batch_results = " .. passed .. "/" .. failed .. "/" .. skipped)
end
```

---

### `lurek.runtime.getClipboardText`

Reads the current text content from the system clipboard. Returns an empty string if the clipboard is unavailable or contains no text.

```lua
lurek.runtime.getClipboardText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The clipboard text, or `""` on failure. |

**Example**

```lua
do
    lurek.runtime.setClipboardText("Hello from Lurek2D!")
    local text = lurek.runtime.getClipboardText()
    print("clipboard = " .. text)
    print("clipboard len = " .. #text)
end
```

---

### `lurek.runtime.getConfig`

Returns a table containing the current engine runtime configuration values.

```lua
lurek.runtime.getConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeGetConfigResult | Table with fields: `runtime_mode` (string), `physics_tick_rate` (number), `fixed_update_tick_rate` (number?), `frame_budget_warn_ms` (number?), `lua_callback_timeout_ms` (number?), `vsync` (boolean), `log_level` (string), `default_font_size` (integer), `default_font_bold` (boolean), `config_reload_revision` (number). |

**Example**

```lua
do
    local config = lurek.runtime.getConfig()
    print("runtime mode = " .. config.runtime_mode)
    print("physics tick rate = " .. config.physics_tick_rate)
    print("config revision = " .. config.config_reload_revision)
end
```

---

### `lurek.runtime.getDebugOverlay`

Returns whether the on-screen debug overlay is currently enabled.

```lua
lurek.runtime.getDebugOverlay()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the debug overlay is visible. |

**Example**

```lua
do
    local overlay = lurek.runtime.getDebugOverlay()
    print("overlay enabled = " .. tostring(overlay))
end
```

---

### `lurek.runtime.getEnv`

Reads an environment variable by name. Returns `nil` if the variable is not set.

```lua
lurek.runtime.getEnv(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The environment variable name. |

**Returns**

| Type | Description |
|------|-------------|
| string | The variable value. Returns `nil` when the variable is not set. |

**Example**

```lua
do
    local path = lurek.runtime.getEnv("PATH")
    print("PATH set = " .. tostring(path ~= nil))
    print("missing var = " .. tostring(lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR") == nil))
end
```

---

### `lurek.runtime.getInfo`

Returns a table with comprehensive engine and host information.

```lua
lurek.runtime.getInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeGetInfoResult | Table with fields: `engine` (string), `version` (string), `lua_version` (string), `renderer` (string), `os` (string), `processors` (number), `memory` (number). |

**Example**

```lua
do
    local info = lurek.runtime.getInfo()
    print("engine = " .. info.engine .. " version = " .. info.version)
    print("os = " .. info.os .. " lua = " .. info.lua_version)
    print("processors = " .. info.processors .. " memory = " .. info.memory)
end
```

---

### `lurek.runtime.getLastError`

Returns the last error for Lua scripts in this module.

```lua
lurek.runtime.getLastError()
```

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeGetLastErrorResult | Table result returned by this call. |

**Example**

```lua
do
    local err = lurek.runtime.getLastError()
    print("last error = " .. tostring(err and err.message))
    print("category = " .. tostring(err and err.category))
end
```

---

### `lurek.runtime.getLogLevel`

Returns the current engine log verbosity level as a string.

```lua
lurek.runtime.getLogLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. |

**Example**

```lua
do
    local lvl = lurek.runtime.getLogLevel()
    print("log_level = " .. lvl)
end
```

---

### `lurek.runtime.getMemorySize`

Returns the total physical memory of the host system in megabytes.

```lua
lurek.runtime.getMemorySize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total RAM in MB. |

**Example**

```lua
do
    local memory = lurek.runtime.getMemorySize()
    print("mem_mb = " .. memory)
    print("memory ok = " .. tostring(memory >= 0))
end
```

---

### `lurek.runtime.getMessage`

Resolves a message string by its identifier from the engine message catalog.

```lua
lurek.runtime.getMessage(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The message identifier to look up. |

**Returns**

| Type | Description |
|------|-------------|
| string | The resolved message text. Returns `nil` when the identifier is not found. |

**Example**

```lua
do
    local key = "engine.welcome"
    print("has engine.welcome = " .. tostring(lurek.runtime.hasMessage(key)))
    print("message = " .. tostring(lurek.runtime.getMessage(key)))
end
```

---

### `lurek.runtime.getMessageCount`

Returns the total number of messages registered in the engine message catalog.

```lua
lurek.runtime.getMessageCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of registered message identifiers. |

**Example**

```lua
do
    local n = lurek.runtime.getMessageCount()
    print("msg_count = " .. n)
end
```

---

### `lurek.runtime.getOS`

Returns the name of the host operating system as a string.

```lua
lurek.runtime.getOS()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Operating system name: `"Windows"`, `"Linux"`, `"macOS"`, `"Android"`, `"iOS"`, or `"Unknown"`. |

**Example**

```lua
do
    local os = lurek.runtime.getOS()
    print("os = " .. os)
end
```

---

### `lurek.runtime.getPowerInfo`

Returns the current power supply state, battery percentage, and estimated time remaining.

```lua
lurek.runtime.getPowerInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Power state: `"unknown"`; `"battery"`; `"nobattery"`; `"charging"`; or `"charged"`. |
| number | Battery charge percentage from 0 to 100. This value may be `nil` when the platform does not provide battery data. |
| number | Estimated battery life remaining in seconds. This value may be `nil` when the platform does not provide battery data. |

**Example**

```lua
do
    local state, percent, seconds = lurek.runtime.getPowerInfo()
    print("power state = " .. state)
    print("battery = " .. tostring(percent))
    print("seconds = " .. tostring(seconds))
end
```

---

### `lurek.runtime.getPreferredLocales`

Returns a list of the user's preferred locale identifiers from the operating system.

```lua
lurek.runtime.getPreferredLocales()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Locale strings (e.g. `{"en_US", "pl_PL"}`). Falls back to `{"en_US"}` if detection fails. |

**Example**

```lua
do
    local locales = lurek.runtime.getPreferredLocales()
    print("locale count = " .. #locales)
    print("first locale = " .. tostring(locales[1]))
end
```

---

### `lurek.runtime.getProcessorCount`

Returns the number of logical processors available on the host machine.

```lua
lurek.runtime.getProcessorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Logical processor count (minimum 1). |

**Example**

```lua
do
    local cpus = lurek.runtime.getProcessorCount()
    print("logical processors = " .. cpus)
    print("has cpu info = " .. tostring(cpus >= 1))
end
```

---

### `lurek.runtime.getVersion`

Returns the semantic version string of the Lurek2D engine.

```lua
lurek.runtime.getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Engine version in `"MAJOR.MINOR.PATCH"` format. |

**Example**

```lua
do
    local version = lurek.runtime.getVersion()
    print("engine version = " .. version)
    print("major tag = " .. tostring(version:match("^[^.]+")))
end
```

---

### `lurek.runtime.hasMessage`

Checks whether a message identifier exists in the engine message catalog.

```lua
lurek.runtime.hasMessage(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | The message identifier to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the message identifier is registered. |

**Example**

```lua
do
    local v = lurek.runtime.hasMessage("engine.welcome")
    print("has_msg = " .. tostring(v))
end
```

---

### `lurek.runtime.log`

Writes a message to the engine log at the specified severity level.

```lua
lurek.runtime.log(level, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. Defaults to `"info"` if unrecognized. |
| `message` | string | The message text to log. |

**Example**

```lua
do
    lurek.runtime.log("info", "Game starting up")
    lurek.runtime.log("debug", "Loading runtime example block")
    print("logged runtime messages")
end
```

---

### `lurek.runtime.openURL`

Opens a URL in the default system browser. Only `http://`, `https://`, and `mailto:` schemes are permitted.

```lua
lurek.runtime.openURL(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | The URL to open. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the URL was accepted and the open command launched successfully. |

**Example**

```lua
do
    local ok = lurek.runtime.openURL("https://lurek2d.dev")
    print("open https = " .. tostring(ok))
end
```

---

### `lurek.runtime.parseArgs`

Parses command-line arguments into structured flags, options, and positional values. Supports `--key=value`, `--key value`, `-flag`, and `--` end-of-options.

```lua
lurek.runtime.parseArgs(args)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `args?` | table | Optional table of argument strings. Uses `os.args` if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeParseArgsResult | Table with fields: `flags` (table of boolean), `options` (table of string), `positional` (array of string). |

**Example**

```lua
do
    local parsed = lurek.runtime.parseArgs({"--debug", "--level=5", "demo.lua", "--", "tail.txt"})
    print("debug flag = " .. tostring(parsed.flags.debug))
    print("level option = " .. tostring(parsed.options.level))
    print("positional count = " .. #parsed.positional)
end
```

---

### `lurek.runtime.reloadConfig`

Requests a reload of the engine configuration from `conf.lua`. The reload is deferred until the next frame.

```lua
lurek.runtime.reloadConfig()
```

**Example**

```lua
do
    local before = lurek.runtime.getConfig().config_reload_revision
    lurek.runtime.reloadConfig()
    local after = lurek.runtime.getConfig().config_reload_revision
    print("reload requested = true")
    print("revision now = " .. after .. " (before " .. before .. ")")
end
```

---

### `lurek.runtime.runBatch`

Executes a table of named task functions sequentially, collecting pass/fail results and elapsed time for each.

```lua
lurek.runtime.runBatch(tasks, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tasks` | table | Table mapping task names (string) to task functions (function). |
| `opts?` | table | Options table. Set `stopOnError = true` to skip remaining tasks after the first failure. |

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeRunBatchResult | Table mapping each task name to a result table. |

**Example**

```lua
do
    local results = lurek.runtime.runBatch({
        ping = function()
            return true
        end,
        fail = function()
            error("boom")
        end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("passed = " .. passed .. " failed = " .. failed .. " skipped = " .. skipped)
    print("fail status = " .. results.fail.status)
end
```

---

### `lurek.runtime.setClipboardText`

Copies a string to the system clipboard. Logs a warning if the clipboard is unavailable or the write fails.

```lua
lurek.runtime.setClipboardText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The text to place on the clipboard. |

**Example**

```lua
do
    lurek.runtime.setClipboardText("lurek_test")
    print("clipboard = " .. tostring(lurek.runtime.getClipboardText()))
end
```

---

### `lurek.runtime.setDebugOverlay`

Enables or disables the on-screen debug overlay that shows FPS, draw calls, and other diagnostics.

```lua
lurek.runtime.setDebugOverlay(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` to show the debug overlay, `false` to hide it. |

**Example**

```lua
do
    local before = lurek.runtime.getDebugOverlay()
    print("debug overlay before = " .. tostring(before))
    lurek.runtime.setDebugOverlay(true)
    print("after enable = " .. tostring(lurek.runtime.getDebugOverlay()))
    lurek.runtime.setDebugOverlay(false)
    print("after disable = " .. tostring(lurek.runtime.getDebugOverlay()))
end
```

---

### `lurek.runtime.setLogLevel`

Sets the engine-wide log verbosity level at runtime.

```lua
lurek.runtime.setLogLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. |

**Example**

```lua
do
    local before = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("info")
    print("before = " .. before)
    print("after = " .. lurek.runtime.getLogLevel())
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
