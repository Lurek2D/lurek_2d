# Log

- The `log` module is a vital Foundations tier component that implements a highly efficient, structured logging facade for Lurek2D.

It provides a unified system for capturing, filtering, and dispatching diagnostic messages across the entire engine and Lua scripting environment. At its core, the module utilizes a level-gated emission system. The global log level acts as an initial filter, ensuring that messages below the active threshold incur near-zero performance cost—they are suppressed before any formatting or string allocation occurs. This allows developers to instrument code heavily with debug and trace messages without impacting production performance.

When a message passes the global filter, it is dispatched via the `SinkRegistry` to one or more registered `Sink` destinations. The module supports several powerful sink types. The `MemoryEntry` sink utilizes a bounded, in-memory ring buffer, perfectly suited for powering in-game developer consoles or debug overlays where recent logs must be rapidly accessible. The `RotatingFileSink` writes output to disk, automatically managing file sizes and backups to prevent unbounded storage consumption, while buffering writes to minimize OS syscall overhead. Furthermore, a callback sink allows log messages to be routed back into the Lua runtime for custom handling.

Logging is highly structured, allowing messages to carry not only severity levels and optional tags, but also complex key-value `LogFields`. This structured approach enables sophisticated log analysis and filtering downstream. Each individual sink maintains its own `SinkLevel` threshold and tag-based allow-list, meaning a single game instance can simultaneously write all `Trace` messages to a rotating file while only displaying `Warning` and `Error` messages in the on-screen console. The entire logging pipeline is fully configurable dynamically at runtime and exposed to scripts via the `lurek.log.*` namespace.

## Functions

### `lurek.log.addSink`

Adds a memory, file, rotating, or callback sink from a config table.

```lua
-- signature
lurek.log.addSink(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | `table` | Sink config with `type`, `level`, format, tag, path, capacity, or callback fields. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sink id. |

**Example**

```lua
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    print("memory sink id = " .. id)
    print("sink count = " .. #lurek.log.listSinks())
end
```

---

### `lurek.log.clearSinks`

Removes all sinks and releases callback registry keys.

```lua
-- signature
lurek.log.clearSinks()
```

**Example**

```lua
do
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    lurek.log.clearSinks()
    local sinks = lurek.log.listSinks()
    print("sinks after clear = " .. #sinks)
end
```

---

### `lurek.log.debug`

Logs a debug message with an optional tag.

```lua
-- signature
lurek.log.debug(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `tag?` | `string` | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.debug("tick completed")
    print("debug logged")
end
```

---

### `lurek.log.debug_fields`

Logs a debug message with structured fields.

```lua
-- signature
lurek.log.debug_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `fields_tbl` | `table` | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.debug_fields("frame stats", {fps = 60, dt = 0.016})
    print("debug_fields logged")
end
```

---

### `lurek.log.error`

Logs an error message with an optional tag.

```lua
-- signature
lurek.log.error(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `tag?` | `string` | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.error("failed to save")
    lurek.log.error("shader compile failed", "gpu")
    print("error logged")
end
```

---

### `lurek.log.error_fields`

Logs an error message with structured fields.

```lua
-- signature
lurek.log.error_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `fields_tbl` | `table` | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.error_fields("save failed", {path = "slot1.sav", reason = "disk full"})
    print("error_fields logged")
end
```

---

### `lurek.log.flushFile`

Flushes a file-backed sink by id when it exists.

```lua
-- signature
lurek.log.flushFile(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Sink id. |

**Example**

```lua
do
    local id = lurek.log.addSink({type = "file", level = "info", path = "logs/flush_test.log"})
    lurek.log.info("flush me")
    lurek.log.flushFile(id)
    print("file sink id = " .. id)
    print("file flushed")
end
```

---

### `lurek.log.getLevel`

Returns the global log level string.

```lua
-- signature
lurek.log.getLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current global log level. |

**Example**

```lua
do
    local prev = lurek.log.getLevel()
    lurek.log.setLevel("warn")
    print("level was " .. prev .. " now " .. lurek.log.getLevel())
    lurek.log.setLevel(prev)
end
```

---

### `lurek.log.info`

Logs an info message with an optional tag.

```lua
-- signature
lurek.log.info(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `tag?` | `string` | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.info("game started")
    lurek.log.info("asset loaded", "assets")
    print("info logged")
end
```

---

### `lurek.log.info_fields`

Logs an info message with structured fields.

```lua
-- signature
lurek.log.info_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `fields_tbl` | `table` | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.info_fields("player join", {name = "Alice", id = 42})
    print("info_fields logged")
end
```

---

### `lurek.log.listSinks`

Returns metadata for all registered sinks.

```lua
-- signature
lurek.log.listSinks()
```

**Returns**

| Type | Description |
|------|-------------|
| `LogListSinksResult` | Array of sink records with id, type, level, and optional path. |

**Example**

```lua
do
    lurek.log.clearSinks()
    lurek.log.addSink({type = "memory", level = "info", capacity = 8})
    lurek.log.addSink({type = "memory", level = "warn", capacity = 8})
    local sinks = lurek.log.listSinks()
    print("sink count = " .. #sinks)
    print("first sink type = " .. sinks[1].type)
end
```

---

### `lurek.log.print`

Logs a message at a runtime-selected level with an optional tag.

```lua
-- signature
lurek.log.print(level, message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Log level string. |
| `message` | `string` | Message text. |
| `tag?` | `string` | Optional tag, defaulting to `Lua`. |

**Example**

```lua
do
    lurek.log.print("info", "general purpose log")
    lurek.log.print("warn", "something suspicious", "system")
    print("print logged")
end
```

---

### `lurek.log.readMemory`

Reads entries from a memory sink and optionally drains them.

```lua
-- signature
lurek.log.readMemory(id, drain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Memory sink id. |
| `drain?` | `boolean` | Optional drain flag, defaulting to false. |

**Returns**

| Type | Description |
|------|-------------|
| `LogReadMemoryResult` | Array table of memory log entries. |

**Example**

```lua
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 50})
    lurek.log.info("test message")
    local entries = lurek.log.readMemory(id, false)
    print("memory entries = " .. #entries)
    print("first entry message = " .. entries[1].message)
end
```

---

### `lurek.log.removeSink`

Removes a sink by id and releases any callback registry key.

```lua
-- signature
lurek.log.removeSink(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Sink id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a sink was removed. |

**Example**

```lua
do
    local id = lurek.log.addSink({type = "memory", level = "debug", capacity = 10})
    local ok = lurek.log.removeSink(id)
    print("removed = " .. tostring(ok))
    print("sink count = " .. #lurek.log.listSinks())
end
```

---

### `lurek.log.setLevel`

Sets the global log level. This function is exposed to Lua scripts.

```lua
-- signature
lurek.log.setLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Level `error`, `warn`, `info`, `debug`, `trace`, `off`, or `none`. |

**Example**

```lua
do
    local previous = lurek.log.getLevel()
    lurek.log.setLevel("debug")
    print("level set to " .. lurek.log.getLevel())
    lurek.log.setLevel(previous)
end
```

---

### `lurek.log.struct`

Logs a structured message at a runtime-selected level.

```lua
-- signature
lurek.log.struct(level_str, message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level_str` | `string` | Log level string. |
| `message` | `string` | Message text. |
| `fields_tbl` | `table` | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.struct("info", "combat hit", {attacker = "goblin", target = "player", damage = 15})
    print("struct logged")
end
```

---

### `lurek.log.warn`

Logs a warning message with an optional tag.

```lua
-- signature
lurek.log.warn(message, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `tag?` | `string` | Log tag shown in the sink output (default `"Lua"`). |

**Example**

```lua
do
    lurek.log.warn("low memory")
    lurek.log.warn("texture missing", "render")
    print("warn logged")
end
```

---

### `lurek.log.warn_fields`

Logs a warning message with structured fields.

```lua
-- signature
lurek.log.warn_fields(message, fields_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text. |
| `fields_tbl` | `table` | Scalar field table converted to strings. |

**Example**

```lua
do
    lurek.log.warn_fields("memory usage", {used_mb = 512, limit_mb = 1024})
    print("warn_fields logged")
end
```

---
