# Runtime

## Purpose

Manages engine shared state, asset registries, and configurations.

## When To Use

- Its role is to keep the rest of the engine coherent. Configuration, shared state, execution mode, error vocabulary, resource keys, logging support, and OS-aware helpers live here so the engine has one common operating language.
- This central vocabulary matters because large engines become fragile when every subsystem invents its own concepts for startup state, environment mode, resource identity, logging, or global context.
- Mode handling is especially important because the same engine may run in normal interactive play, headless automation, docs generation, tests, screenshots, or other specialized workflows that need different assumptions.

## Minimal Example

Example block: `lurek.runtime.getVersion`

```lua
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local version = lurek.runtime.getVersion()
    local major = version:match("^[^.]+") or "0"
    local parts = lurek.runtime.parseArgs({ "--version=" .. version })
    local tagged = parts.options.version or "unknown"
    runtime_log("getVersion version=" .. version .. " major=" .. major .. " tagged=" .. tagged)
end
```

## Common Patterns

- Start with `lurek.runtime.errorSnapshot` when exploring this module.
- Start with `lurek.runtime.getArch` when exploring this module.
- Start with `lurek.runtime.getArgs` when exploring this module.
- Start with `lurek.runtime.getBatchResults` when exploring this module.
- Start with `lurek.runtime.getClipboardText` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `runtime` module is the shared engine-state surface that many other modules depend on before they expose their own user-facing features.
- Its role is to keep the rest of the engine coherent. Configuration, shared state, execution mode, error vocabulary, resource keys, logging support, and OS-aware helpers live here so the engine has one common operating language.
- This central vocabulary matters because large engines become fragile when every subsystem invents its own concepts for startup state, environment mode, resource identity, logging, or global context.
- Mode handling is especially important because the same engine may run in normal interactive play, headless automation, docs generation, tests, screenshots, or other specialized workflows that need different assumptions.
- Shared state, resource-key helpers, and runtime-wide error types give other modules a stable way to coordinate without dissolving into ad hoc registries and inconsistent failure reporting.
- Logging and environment-aware helpers belong here for the same reason: runtime-wide diagnostics and platform context should be centralized rather than redefined in each subsystem.
- That shared operating layer is what makes higher-level systems easier to compose around one startup and execution contract.
- Headless support is especially important because non-interactive execution should feel first-class for CI, docs, evidence capture, and automation instead of like a reduced afterthought.
- It also gives tool and gameplay code one place to agree on environment mode, startup assumptions, and shared process-level state.
- It gives the engine one durable answer to runtime context.
- That keeps “how the engine is running” separate from “what a feature is doing,” which is exactly the boundary `runtime` should own.
- `runtime` should stabilize common policy and state, but it should not absorb the domain logic of the modules that depend on it.
- Read `runtime` as the shared operating layer of the engine.

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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local snapshot = lurek.runtime.errorSnapshot("Renderer warmup failed")
    local has_message = snapshot:find('"message"') ~= nil
    local has_code = snapshot:find('"code"') ~= nil
    local has_category = snapshot:find('"category"') ~= nil
    runtime_log("errorSnapshot len=" .. tostring(#snapshot) .. " message=" .. tostring(has_message) .. " code=" .. tostring(has_code) .. " category=" .. tostring(has_category))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local arch = lurek.runtime.getArch()
    local cpus = lurek.runtime.getProcessorCount()
    local memory = lurek.runtime.getMemorySize()
    local fingerprint = arch .. ":" .. tostring(cpus) .. ":" .. tostring(memory)
    runtime_log("getArch arch=" .. arch .. " fingerprint=" .. fingerprint)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local args = lurek.runtime.getArgs()
    local first = first_or(args, "none")
    local parsed = lurek.runtime.parseArgs(args)
    local positional = #parsed.positional
    runtime_log("getArgs count=" .. tostring(#args) .. " first=" .. first .. " positional=" .. tostring(positional))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local results = {
        ok = { status = "passed", time = 0.01 },
        bad = { status = "failed", time = 0.02, error = "nope" },
        later = { status = "skipped", time = 0.0 },
    }
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    runtime_log("getBatchResults passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    lurek.runtime.setClipboardText("mission:relay")
    local text = lurek.runtime.getClipboardText()
    local length = #text
    local restored = lurek.runtime.parseArgs({ "--clipboard=" .. text })
    runtime_log("getClipboardText text=" .. text .. " length=" .. tostring(length) .. " echoed=" .. tostring(restored.options.clipboard))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local config = lurek.runtime.getConfig()
    local mode = config.runtime_mode
    local physics = tostring(config.physics_tick_rate)
    local revision = tostring(config.config_reload_revision)
    runtime_log("getConfig mode=" .. mode .. " physics=" .. physics .. " log=" .. config.log_level .. " revision=" .. revision)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    lurek.runtime.setDebugOverlay(false)
    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local after = lurek.runtime.getDebugOverlay()
    runtime_log("getDebugOverlay before=" .. tostring(before) .. " after=" .. tostring(after) .. " mode=" .. lurek.runtime.getConfig().runtime_mode)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local path = lurek.runtime.getEnv("PATH")
    local user = lurek.runtime.getEnv("USERNAME") or lurek.runtime.getEnv("USER")
    local missing = lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR")
    local has_path = tostring(path ~= nil and #path > 0)
    runtime_log("getEnv has_path=" .. has_path .. " user=" .. tostring(user) .. " missing=" .. tostring(missing))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local info = lurek.runtime.getInfo()
    local summary = info.engine .. " " .. info.version
    local host = info.os .. "/" .. tostring(info.processors)
    local renderer = info.renderer .. " with " .. info.lua_version
    runtime_log("getInfo summary=" .. summary .. " host=" .. host .. " renderer=" .. renderer .. " memory=" .. tostring(info.memory))
end
```

---

### `lurek.runtime.getLastError`

Returns the most recent engine error as a table, or `nil` if no error has occurred.

```lua
lurek.runtime.getLastError()
```

**Returns**

| Type | Description |
|------|-------------|
| LRuntimeGetLastErrorResult | Table with fields: `message` (string), `code` (string), `category` (string), and optional `hint` (string). Returns `nil` when no error is recorded. |

**Example**

```lua
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local err = lurek.runtime.getLastError()
    local kind = type(err)
    local message = err and err.message or "none"
    local category = err and err.category or "none"
    runtime_log("getLastError type=" .. kind .. " message=" .. message .. " category=" .. category)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local initial = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("info")
    local info_level = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(initial)
    runtime_log("getLogLevel initial=" .. initial .. " info_level=" .. info_level .. " restored=" .. lurek.runtime.getLogLevel())
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local memory = lurek.runtime.getMemorySize()
    local info = lurek.runtime.getInfo()
    local enough = tostring(memory > 0)
    local mirrored = tostring(info.memory)
    runtime_log("getMemorySize memory=" .. tostring(memory) .. " enough=" .. enough .. " info_memory=" .. mirrored)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local missing = lurek.runtime.getMessage("ZZUNKNOWN")
    local known = lurek.runtime.hasMessage("L001")
    runtime_log("getMessage boot=" .. boot .. " loaded=" .. loaded .. " missing=" .. missing .. " known=" .. tostring(known))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local count = lurek.runtime.getMessageCount()
    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local enough = tostring(count >= 30)
    runtime_log("getMessageCount count=" .. tostring(count) .. " enough=" .. enough .. " sample=" .. boot .. " / " .. loaded)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local os = lurek.runtime.getOS()
    local arch = lurek.runtime.getArch()
    local host = os .. "-" .. arch
    local known = lurek.runtime.getInfo().os
    runtime_log("getOS host=" .. host .. " info_os=" .. known)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local state, percent, seconds = lurek.runtime.getPowerInfo()
    local battery = tostring(percent)
    local eta = tostring(seconds)
    local locale = first_or(lurek.runtime.getPreferredLocales(), "en_US")
    runtime_log("getPowerInfo state=" .. state .. " battery=" .. battery .. " eta=" .. eta .. " locale=" .. locale)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local locales = lurek.runtime.getPreferredLocales()
    local first = first_or(locales, "en_US")
    local parsed = lurek.runtime.parseArgs({ "--locale=" .. first })
    local locale = tostring(parsed.options.locale)
    runtime_log("getPreferredLocales count=" .. tostring(#locales) .. " first=" .. first .. " parsed=" .. locale)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local cpus = lurek.runtime.getProcessorCount()
    local workers = math.max(cpus - 1, 1)
    local batch = lurek.runtime.runBatch({ ai = function() return workers end })
    local passed = batch.ai.status
    runtime_log("getProcessorCount cpus=" .. tostring(cpus) .. " workers=" .. tostring(workers) .. " batch=" .. passed)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local version = lurek.runtime.getVersion()
    local major = version:match("^[^.]+") or "0"
    local parts = lurek.runtime.parseArgs({ "--version=" .. version })
    local tagged = parts.options.version or "unknown"
    runtime_log("getVersion version=" .. version .. " major=" .. major .. " tagged=" .. tagged)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local boot = lurek.runtime.hasMessage("L001")
    local render = lurek.runtime.hasMessage("L010")
    local unknown = lurek.runtime.hasMessage("ZZUNKNOWN")
    local count = lurek.runtime.getMessageCount()
    runtime_log("hasMessage boot=" .. tostring(boot) .. " render=" .. tostring(render) .. " unknown=" .. tostring(unknown) .. " count=" .. tostring(count))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.log("info", "Boot sequence ready")
    lurek.runtime.log("warn", "Shader cache cold")
    lurek.runtime.log("error", "Example error line for diagnostics")
    runtime_log("log before=" .. before .. " after=" .. lurek.runtime.getLogLevel())
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local mode = lurek.runtime.getConfig().runtime_mode
    local docs_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("https://lurek2d.dev/docs") or false
    local issue_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("mailto:support@lurek2d.dev") or false
    local https_allowed = tostring(docs_ok)
    local mailto_allowed = tostring(issue_ok)
    runtime_log("openURL docs=" .. https_allowed .. " mailto=" .. mailto_allowed .. " mode=" .. mode)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local parsed = lurek.runtime.parseArgs({ "--debug", "--level=5", "demo.lua", "--", "tail.txt" })
    local debug_flag = tostring(parsed.flags.debug == true)
    local level = tostring(parsed.options.level)
    local entry = tostring(parsed.positional[1])
    runtime_log("parseArgs debug=" .. debug_flag .. " level=" .. level .. " entry=" .. entry .. " tail=" .. tostring(parsed.positional[2]))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getConfig().config_reload_revision
    lurek.runtime.reloadConfig()
    local after = lurek.runtime.getConfig().config_reload_revision
    local changed = tostring(after ~= before)
    runtime_log("reloadConfig before=" .. tostring(before) .. " after=" .. tostring(after) .. " changed_now=" .. changed)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local results = lurek.runtime.runBatch({
        compile = function() return true end,
        package = function() return "zip" end,
        deploy = function() error("network timeout") end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    runtime_log("runBatch passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped) .. " deploy=" .. results.deploy.status)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local payload = "save-slot-02"
    lurek.runtime.setClipboardText(payload)
    local echoed = lurek.runtime.getClipboardText()
    local preview = string.sub(echoed, 1, 12)
    runtime_log("setClipboardText payload=" .. payload .. " echoed=" .. echoed .. " preview=" .. preview)
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local enabled = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(false)
    runtime_log("setDebugOverlay before=" .. tostring(before) .. " enabled=" .. tostring(enabled) .. " final=" .. tostring(lurek.runtime.getDebugOverlay()))
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
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("warn")
    local during = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(before)
    runtime_log("setLogLevel before=" .. before .. " during=" .. during .. " restored=" .. lurek.runtime.getLogLevel())
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
