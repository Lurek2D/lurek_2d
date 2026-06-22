# Log

## Purpose

Runs structured logs with level-filtered sinks.

## When To Use

- It keeps message formatting, structured fields, severity, and sink routing together, which lets debugging output scale from quick traces to retained logs.
- That common path makes filtering and correlation across subsystems easier.
- Read it as the standard language for script diagnostics when several systems need to be debugged through the same output flow.

## Minimal Example

From the `lurek.log.debug` example block:

```lua
do
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.debug("tick completed", "Gameplay")
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("captured debug entry: " .. entry.level .. " " .. entry.tag)
end
```

## Common Patterns

- Start with `lurek.log.addSink` when exploring this module.
- Start with `lurek.log.clearSinks` when exploring this module.
- Start with `lurek.log.debug` when exploring this module.
- Start with `lurek.log.debug_fields` when exploring this module.
- Start with `lurek.log.error` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/log.lua`

## Summary

- The `log` module is the common script-facing path for runtime diagnostics, so users can emit messages through one consistent logging surface instead of mixing ad hoc print styles.
- It keeps message formatting, structured fields, severity, and sink routing together, which lets debugging output scale from quick traces to retained logs.
- That common path makes filtering and correlation across subsystems easier.
- Read it as the standard language for script diagnostics when several systems need to be debugged through the same output flow.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.log.addSink`

Adds a memory, file, rotating, or callback sink from a config table.

```lua
lurek.log.addSink(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Sink config with `type`, `level`, format, tag, path, capacity, or callback fields. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sink id. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local before = #lurek.log.listSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local after = #lurek.log.listSinks()
    lurek.log.info("memory sink id = " .. id)
    lurek.log.info("sink count " .. before .. " -> " .. after)
end
```

---

### `lurek.log.clearSinks`

Removes all sinks and releases callback registry keys.

```lua
lurek.log.clearSinks()
```

**Example**

```lua
do
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    local before = #lurek.log.listSinks()
    lurek.log.clearSinks()
    local sinks = lurek.log.listSinks()
    lurek.log.info("sinks before clear = " .. before)
    lurek.log.info("sinks after clear = " .. #sinks)
end
```

---

### `lurek.log.debug`

Logs a debug message with an optional tag.

```lua
lurek.log.debug(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `tag?` | string | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.debug("tick completed", "Gameplay")
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("captured debug entry: " .. entry.level .. " " .. entry.tag)
end
```

---

### `lurek.log.debug_fields`

Logs a debug message with structured fields.

```lua
lurek.log.debug_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `fields_tbl` | table | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.clearSinks()
    lurek.log.setLevel("debug")
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.debug_fields("frame stats", {fps = "60", dt = "0.016"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("debug fields fps=" .. tostring(entry.fields.fps) .. " dt=" .. tostring(entry.fields.dt))
end
```

---

### `lurek.log.error`

Logs an error message with an optional tag.

```lua
lurek.log.error(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `tag?` | string | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "error", capacity = 8})
    lurek.log.error("failed to save")
    lurek.log.error("shader compile failed", "gpu")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("error sink captured message = " .. entry.message)
end
```

---

### `lurek.log.error_fields`

Logs an error message with structured fields.

```lua
lurek.log.error_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `fields_tbl` | table | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "error", capacity = 8})
    lurek.log.error_fields("save failed", {path = "slot1.sav", reason = "disk full"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("save error path=" .. tostring(entry.fields.path) .. " reason=" .. tostring(entry.fields.reason))
end
```

---

### `lurek.log.flushFile`

Flushes a file-backed sink by id when it exists.

```lua
lurek.log.flushFile(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sink id. |

**Example**

```lua
do
    lurek.log.clearSinks()
    lurek.filesystem.mkdir("save")
    local path = "save/_log_flush_example.log"
    local id = lurek.log.addSink({type = "file", level = "info", path = path})
    lurek.log.info("flush me")
    lurek.log.flushFile(id)
    lurek.log.removeSink(id)
    lurek.log.info("file sink id = " .. id)
    lurek.log.info("flush requested for " .. path)
end
```

---

### `lurek.log.getLevel`

Returns the global log level string.

```lua
lurek.log.getLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current global log level. |

**Example**

```lua
do
    local prev = lurek.log.getLevel()
    lurek.log.setLevel("warn")
    local current = lurek.log.getLevel()
    lurek.log.setLevel(prev)
    local restored = lurek.log.getLevel()
    lurek.log.info("level switched " .. prev .. " -> " .. current)
    lurek.log.info("level restored = " .. restored)
end
```

---

### `lurek.log.info`

Logs an info message with an optional tag.

```lua
lurek.log.info(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `tag?` | string | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.info("game started")
    lurek.log.info("asset loaded", "assets")
    local entries = lurek.log.readMemory(id, true)
    lurek.log.removeSink(id)
    lurek.log.info("info entries captured = " .. #entries)
end
```

---

### `lurek.log.info_fields`

Logs an info message with structured fields.

```lua
lurek.log.info_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `fields_tbl` | table | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.info_fields("player join", {name = "Alice", id = "42"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("joined player " .. tostring(entry.fields.name) .. " id=" .. tostring(entry.fields.id))
end
```

---

### `lurek.log.listSinks`

Returns metadata for all registered sinks.

```lua
lurek.log.listSinks()
```

**Returns**

| Type | Description |
|------|-------------|
| LLogListSinksResult | Array of sink records with id, type, level, and optional path. |

**Example**

```lua
do
    lurek.log.clearSinks()
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    local sinks = lurek.log.listSinks()
    lurek.log.info("sink count = " .. #sinks)
    lurek.log.info("first sink type = " .. sinks[1].type)
end
```

---

### `lurek.log.print`

Logs a message at a runtime-selected level with an optional tag.

```lua
lurek.log.print(level, message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Log level string. |
| `message` | string | Message text. |
| `tag?` | string | Optional tag, defaulting to `Lua`. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.print("info", "general purpose log")
    lurek.log.print("warn", "something suspicious", "system")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("runtime-selected level = " .. entry.level .. " tag=" .. tostring(entry.tag))
end
```

---

### `lurek.log.readMemory`

Reads entries from a memory sink and optionally drains them.

```lua
lurek.log.readMemory(id, drain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Memory sink id. |
| `drain?` | boolean | Optional drain flag, defaulting to false. |

**Returns**

| Type | Description |
|------|-------------|
| LLogReadMemoryResult | Array table of memory log entries. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.info("test message")
    local entries = lurek.log.readMemory(id, false)
    local entry = entries[1]
    lurek.log.removeSink(id)
    lurek.log.info("memory entries = " .. #entries)
    lurek.log.info("first entry message = " .. entry.message)
end
```

---

### `lurek.log.removeSink`

Removes a sink by id and releases any callback registry key.

```lua
lurek.log.removeSink(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Sink id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a sink was removed. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local before = #lurek.log.listSinks()
    local ok = lurek.log.removeSink(id)
    local after = #lurek.log.listSinks()
    lurek.log.info("removed = " .. tostring(ok))
    lurek.log.info("sink count " .. before .. " -> " .. after)
end
```

---

### `lurek.log.setLevel`

Sets the global log level. This function is exposed to Lua scripts.

```lua
lurek.log.setLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Level `error`, `warn`, `info`, `debug`, `trace`, `off`, or `none`. |

**Example**

```lua
do
    local previous = lurek.log.getLevel()
    lurek.log.setLevel("debug")
    local current = lurek.log.getLevel()
    lurek.log.setLevel(previous)
    lurek.log.info("level set to " .. current)
    lurek.log.info("restored level = " .. lurek.log.getLevel())
end
```

---

### `lurek.log.struct`

Logs a structured message at a runtime-selected level.

```lua
lurek.log.struct(level_str, message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level_str` | string | Log level string. |
| `message` | string | Message text. |
| `fields_tbl` | table | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 8})
    lurek.log.struct("info", "combat hit", {attacker = "enemy", target = "player", damage = "15"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("struct fields attacker=" .. tostring(entry.fields.attacker) .. " damage=" .. tostring(entry.fields.damage))
end
```

---

### `lurek.log.warn`

Logs a warning message with an optional tag.

```lua
lurek.log.warn(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `tag?` | string | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    lurek.log.warn("low memory")
    lurek.log.warn("texture missing", "render")
    local entry = lurek.log.readMemory(id, true)[2]
    lurek.log.removeSink(id)
    lurek.log.info("warn tag captured = " .. tostring(entry.tag))
end
```

---

### `lurek.log.warn_fields`

Logs a warning message with structured fields.

```lua
lurek.log.warn_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text. |
| `fields_tbl` | table | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.clearSinks()
    local id = lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    lurek.log.warn_fields("memory usage", {used_mb = "512", limit_mb = "1024"})
    local entry = lurek.log.readMemory(id, true)[1]
    lurek.log.removeSink(id)
    lurek.log.info("warn fields usage=" .. tostring(entry.fields.used_mb) .. "/" .. tostring(entry.fields.limit_mb) .. " MB")
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
