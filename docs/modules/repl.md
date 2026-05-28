# Repl

- The `repl` module is a crucial Core Runtime tier component that provides a release-safe, interactive Read-Eval-Print Loop (REPL) for Lurek2D.

Designed to execute Lua commands dynamically, it empowers developers and users to introspect state, run functions, and tweak variables at runtime. At its center is the `ReplSession`, a stateful evaluator that operates over an existing `mlua::Lua` VM without directly owning it. This design makes the REPL completely headless—processing string input and returning string output—so it can be seamlessly embedded into both in-game GUI developer terminals and external command-line debug bridges.

The REPL supports a rich set of interactive features. It manages a bounded command history (with a configurable capacity, defaulting to 200 entries), allowing users to easily navigate past inputs. The input evaluator intelligently handles expressions (attempting a `return <input>` first) before falling back to statement execution. A suite of built-in colon commands (`:help`, `:clear`, `:vars`, `:time`, `:reset`, `:load <file>`) provides essential session management and file execution capabilities directly from the prompt.

Furthermore, the module includes a sophisticated `completer` that offers tab completion against a static pool of Lua keywords, built-ins, standard libraries, and all `lurek.*` namespaces, while also dynamically resolving dot-separated paths against the live Lua global table. Value formatting is handled by a robust `value_to_string` recursive formatter, which converts all Lua value types (including opaque types like functions and userdata) into stable, human-readable display text with configurable depth limits and table truncation. Entirely free of wgpu or winit dependencies, the `lurek.repl.*` API ensures that interactive scripting is safe, stable, and available across all Lurek2D environments.

## Functions

### `lurek.repl.new`

Creates a release-safe REPL session with bounded command history.

```lua
-- signature
lurek.repl.new(max_history)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_history?` | `number` | Maximum number of history entries; defaults to 200. |

**Returns**

| Type | Description |
|------|-------------|
| `LReplSession` | REPL session handle for eval, history, and completion. |

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

## LReplSession

### `LReplSession:clear`

Clears all entries from this REPL session history.

```lua
-- signature
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

### `LReplSession:complete`

Returns completion candidates that begin with the supplied prefix.

```lua
-- signature
LReplSession:complete(prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | `string` | Prefix text to complete. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Matching completion strings. |

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

### `LReplSession:eval`

Evaluates Lua code and records the input in this REPL history.

```lua
-- signature
LReplSession:eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | Lua expression, statement, or REPL command to evaluate. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Display text for the result, command, or error. |

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

### `LReplSession:history`

Returns the recorded REPL input history in oldest-first order.

```lua
-- signature
LReplSession:history()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | History entry strings. |

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

### `LReplSession:len`

Returns the number of entries stored in this REPL history.

```lua
-- signature
LReplSession:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | History entry count. |

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

### `LReplSession:type`

Returns the Lua-visible type name for this REPL session handle.

```lua
-- signature
LReplSession:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LReplSession`. |

**Example**

```lua
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print("type = " .. sess:type())
end
```

---

### `LReplSession:typeOf`

Returns whether this REPL session handle matches a supported type name.

```lua
-- signature
LReplSession:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LReplSession` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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
