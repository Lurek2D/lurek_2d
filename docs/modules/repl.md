# Repl

## Purpose

Evaluates Lua inputs with tab completion.

## When To Use

- Session state, commands, completion, and value rendering work together so ad hoc evaluation feels like a usable runtime console instead of a raw eval hook.
- Read it as the runtime console boundary. repl owns how state is queried, evaluated, formatted, and returned.

## Minimal Example

Example block: `lurek.repl.new`

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local repl = lurek.repl.new(8)
    local initial_len = repl:len()
    local is_session = repl:typeOf("LReplSession")
    lurek.log.info("repl type = " .. repl:type())
    lurek.log.info("initial len = " .. initial_len)
    assert(is_session and initial_len == 0, "new REPL session starts empty")
end
```

## Common Patterns

- Start with `lurek.repl.new` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `repl` module is the interactive evaluation surface for users who want to inspect or execute Lua code live inside a running engine context.
- Session state, commands, completion, and value rendering work together so ad hoc evaluation feels like a usable runtime console instead of a raw `eval` hook.
- Read it as the runtime console boundary. `repl` owns how state is queried, evaluated, formatted, and returned.

This module is mostly self-contained inside the `Core Runtime` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.repl.new`

Creates a release-safe REPL session with bounded command history.

```lua
lurek.repl.new(max_history)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_history?` | number | Maximum number of history entries; defaults to 200. |

**Returns**

| Type | Description |
|------|-------------|
| [LReplSession](#lreplsession) | REPL session handle for eval, history, and completion. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local repl = lurek.repl.new(8)
    local initial_len = repl:len()
    local is_session = repl:typeOf("LReplSession")
    lurek.log.info("repl type = " .. repl:type())
    lurek.log.info("initial len = " .. initial_len)
    assert(is_session and initial_len == 0, "new REPL session starts empty")
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LReplSession](#lreplsession)

## LReplSession

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LReplSession:clear`

Clears all entries from this REPL session history.

```lua
LReplSession:clear()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:clear()
    example_print_log("after clear = " .. repl:len() .. " history=" .. #repl:history())
end
```

---

#### `LReplSession:complete`

Returns completion candidates that begin with the supplied prefix.

```lua
LReplSession:complete(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | string | Prefix text to complete. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Matching completion strings. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local repl = lurek.repl.new()
    local completions = repl:complete("lurek.re")
    local first = tostring(completions[1] or "")
    local count = #completions
    lurek.log.info("completions for lurek.re = " .. count)
    lurek.log.info("first match = " .. first)
end
```

---

#### `LReplSession:eval`

Evaluates Lua code and records the input in this REPL history.

```lua
LReplSession:eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | Lua expression, statement, or REPL command to evaluate. |

**Returns**

| Type | Description |
|------|-------------|
| string | Display text for the result, command, or error. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("local total = 2 + 2")
    local result = repl:eval("return total * 3")
    example_print_log("eval result = " .. result)
    example_print_log("history len = " .. repl:len())
end
```

---

#### `LReplSession:history`

Returns the recorded REPL input history in oldest-first order.

```lua
LReplSession:history()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | History entry strings. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.repl.new()
    repl:eval("return 'first'")
    repl:eval("return 'second'")
    local hist = repl:history()
    example_print_log("history entries = " .. #hist)
    example_print_log("last entry = " .. hist[#hist])
end
```

---

#### `LReplSession:len`

Returns the number of entries stored in this REPL history.

```lua
LReplSession:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | History entry count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.repl.new()
    repl:eval("return 'a'")
    repl:eval("return 'b'")
    example_print_log("len = " .. repl:len())
    repl:clear()
    example_print_log("after clear = " .. repl:len())
end
```

---

#### `LReplSession:type`

Returns the Lua-visible type name for this REPL session handle.

```lua
LReplSession:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LReplSession](#lreplsession)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local sess = lurek.repl.new()
    local type_name = sess:type()
    local matches = sess:typeOf(type_name)
    lurek.log.info("repl session type = " .. type_name)
    lurek.log.info("type check = " .. tostring(matches))
    assert(matches, "session reports its own type")
end
```

---

#### `LReplSession:typeOf`

Returns whether this REPL session handle matches a supported type name.

```lua
LReplSession:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LReplSession](#lreplsession)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LReplSession
    local sess = lurek.repl.new()
    local is_session = sess:typeOf("LReplSession")
    local is_object = sess:typeOf("LObject")
    lurek.log.info("is session = " .. tostring(is_session))
    lurek.log.info("history entries = " .. tostring(sess:len()))
    assert(is_session and is_object, "REPL session exposes expected type hierarchy")
end
```

---
