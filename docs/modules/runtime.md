# Runtime

- The `runtime` module forms the very foundation of the Lurek2D dependency graph.

As a Core Runtime tier component, it defines the essential shared state, engine configuration, unified error handling, and structured logging mechanisms upon which every other engine subsystem relies. At the heart of the module is `SharedState`, a central, mutable state container accessed via `RefCell` borrows. It orchestrates cross-module communication during a frame, tracking window state, input aggregation, timing profiles, asynchronous file I/O (GameFS), render pipeline configurations, and managing slot-map resource pools (textures, fonts, shaders, particle systems, etc.) while enforcing memory budgets via LRU eviction.

Configuration is driven by the `Config` struct, which parses the `conf.toml` file at startup. It dictates window settings, renderer preferences, performance caps (like Lua callback timeouts), and feature-toggles (`ModulesConfig`) that selectively load or auto-disable engine subsystems based on prerequisites. The runtime actively supports hot-reloading for many configuration values, allowing live tweaks to target FPS, physics ticks, log levels, and viewport settings without restarting the game. The module also robustly handles different startup modes (`gui`, `tui`, `headless`, `cli`), with the headless path specifically designed for script automation and CI testing without requiring window or audio contexts.

Error handling is unified under `EngineError`, an exhaustive enum that categorizes failures across all domains (IO, Lua, GPU, audio, network, physics) with stable, machine-readable codes (e.g., `E1001`) and actionable recovery hints. Complementing this is a comprehensive log message catalog driven by an embedded TOML file. It provides structured, consistent diagnostic output (using codes like `L001` or `G012`) via the `log_msg!` macro. To ensure safe and efficient resource management across the engine, the module defines strongly-typed `slotmap` keys (`TextureKey`, `FontKey`, etc.) that act as lightweight, generationally-checked handles suitable for storage within Lua userdata. Though most of the infrastructure is consumed through higher-level modules, the canonical runtime Lua surface is `lurek.runtime`.

### Lua API Bridge and Registration

The old `lua_api` spec duplicated this runtime namespace. Its relevant contract now lives here: `src/lua_api/` is the Edge/Integration bridge that creates sandboxed Lua VMs, installs the sealed `lurek` global, and registers every enabled `lurek.*` namespace against the runtime `SharedState`.

Module registration is trait-based. Each binding file implements a `register(lua, lurek, state)` entry point, and `src/lua_api/register.rs` walks the static `MODULES` slice using `always!` and `gated!` entries. Feature-gated modules that cannot appear in that static slice are registered after the standard pass. Binding files remain translation-only: they parse Lua values, borrow `SharedState`, call domain modules, and convert results back to Lua without owning business logic.

For the full Lua/Rust boundary design, see [docs/architecture/lua-rust-boundary.md](../architecture/lua-rust-boundary.md).

## Functions

### `lurek.runtime.errorSnapshot`

Creates a JSON-encoded error snapshot from a message string, useful for diagnostics and error reporting.

```lua
-- signature
lurek.runtime.errorSnapshot(msg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | `string` | The error message to capture. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON string containing the error snapshot with stack and context information. |

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
-- signature
lurek.runtime.getArch()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Architecture identifier (e.g. `"x86_64"`, `"aarch64"`). |

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
-- signature
lurek.runtime.getArgs()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Argument strings. |

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
-- signature
lurek.runtime.getBatchResults(results)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `results` | `table` | The results table returned by `runBatch`. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Count of passed tasks. |
| `number` | b Count of failed tasks. |
| `number` | c Count of skipped tasks. |

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
-- signature
lurek.runtime.getClipboardText()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The clipboard text, or `""` on failure. |

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
-- signature
lurek.runtime.getConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| `RuntimeGetConfigResult` | Table with fields: `runtime_mode` (string), `physics_tick_rate` (number), `fixed_update_tick_rate` (number?), `frame_budget_warn_ms` (number?), `lua_callback_timeout_ms` (number?), `vsync` (boolean), `log_level` (string), `default_font_size` (integer), `default_font_bold` (boolean), `config_reload_revision` (number). |

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
-- signature
lurek.runtime.getDebugOverlay()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the debug overlay is visible. |

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
-- signature
lurek.runtime.getEnv(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The environment variable name. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The variable value. Returns `nil` when the variable is not set. |

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
-- signature
lurek.runtime.getInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| `RuntimeGetInfoResult` | Table with fields: `engine` (string), `version` (string), `lua_version` (string), `renderer` (string), `os` (string), `processors` (number), `memory` (number). |

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
-- signature
lurek.runtime.getLastError()
```

**Returns**

| Type | Description |
|------|-------------|
| `RuntimeGetLastErrorResult` | Table result returned by this call. |

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
-- signature
lurek.runtime.getLogLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. |

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
-- signature
lurek.runtime.getMemorySize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total RAM in MB. |

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
-- signature
lurek.runtime.getMessage(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The message identifier to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The resolved message text. Returns `nil` when the identifier is not found. |

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
-- signature
lurek.runtime.getMessageCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of registered message identifiers. |

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
-- signature
lurek.runtime.getOS()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Operating system name: `"Windows"`, `"Linux"`, `"macOS"`, `"Android"`, `"iOS"`, or `"Unknown"`. |

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
-- signature
lurek.runtime.getPowerInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Power state: `"unknown"`, `"battery"`, `"nobattery"`, `"charging"`, or `"charged"`. |
| `number` | b Battery charge percentage from 0 to 100. This value may be `nil` when the platform does not provide battery data. |
| `number` | c Estimated battery life remaining in seconds. This value may be `nil` when the platform does not provide battery data. |

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
-- signature
lurek.runtime.getPreferredLocales()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Locale strings (e.g. `{"en_US", "pl_PL"}`). Falls back to `{"en_US"}` if detection fails. |

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
-- signature
lurek.runtime.getProcessorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Logical processor count (minimum 1). |

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
-- signature
lurek.runtime.getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Engine version in `"MAJOR.MINOR.PATCH"` format. |

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
-- signature
lurek.runtime.hasMessage(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The message identifier to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the message identifier is registered. |

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
-- signature
lurek.runtime.log(level, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. Defaults to `"info"` if unrecognized. |
| `message` | `string` | The message text to log. |

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
-- signature
lurek.runtime.openURL(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | The URL to open. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the URL was accepted and the open command launched successfully. |

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
-- signature
lurek.runtime.parseArgs(args)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `args?` | `table` | Optional table of argument strings. Uses `os.args` if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| `RuntimeParseArgsResult` | Table with fields: `flags` (table of boolean), `options` (table of string), `positional` (array of string). |

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
-- signature
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
-- signature
lurek.runtime.runBatch(tasks, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tasks` | `table` | Table mapping task names (string) to task functions (function). |
| `opts?` | `table` | Options table. Set `stopOnError = true` to skip remaining tasks after the first failure. |

**Returns**

| Type | Description |
|------|-------------|
| `RuntimeRunBatchResult` | Table mapping each task name to a result table. |

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
-- signature
lurek.runtime.setClipboardText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `string` | The text to place on the clipboard. |

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
-- signature
lurek.runtime.setDebugOverlay(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | `true` to show the debug overlay, `false` to hide it. |

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
-- signature
lurek.runtime.setLogLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Log level: `"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`. |

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
