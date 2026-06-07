# Repl

## Summary

This module provides a headless, embeddable interactive Lua session that evaluates code against the running VM. It operates independently of rendering layers, maintaining a bounded history and executing colon-prefixed console commands.

To assist users, a completer scans live globals and keywords to suggest autocomplete candidates, resolving dot-paths. Raw values are formatted into readable text for interactive debugging feedback.

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
    ---@type LReplSession
    local repl = lurek.repl.new(8)
    print("type = " .. repl:type())
    print("initial len = " .. repl:len())
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
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:clear()
    print("after clear = " .. repl:len() .. " history=" .. #repl:history())
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
    ---@type LReplSession
    local repl = lurek.repl.new()
    local completions = repl:complete("lurek.re")
    print("completions for 'lurek.re' = " .. #completions)
    print("first match = " .. tostring(completions[1]))
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
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("local total = 2 + 2")
    local result = repl:eval("return total * 3")
    print("eval result = " .. result)
    print("history len = " .. repl:len())
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
    local repl = lurek.repl.new()
    repl:eval("return 'first'")
    repl:eval("return 'second'")
    local hist = repl:history()
    print("history entries = " .. #hist)
    print("last entry = " .. hist[#hist])
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
    local repl = lurek.repl.new()
    repl:eval("return 'a'")
    repl:eval("return 'b'")
    print("len = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
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
    ---@type LReplSession
    local sess = lurek.repl.new()
    print("type = " .. sess:type())
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
    ---@type LReplSession
    local sess = lurek.repl.new()
    print("is session = " .. tostring(sess:typeOf("LReplSession")))
    print("is object = " .. tostring(sess:typeOf("LObject")))
end
```

---
