# Event

## Summary

This module serves as the runtime messaging hub, decoupling subsystems through asynchronous signaling. It implements a dual-priority queue ensuring critical tasks process ahead of standard events. The system handles data marshalling between Rust and Lua, supporting both immediate pushes and deferred buffering to coordinate events across frames.

Additionally, the system manages a signal registry supporting exact and wildcard subscriber patterns. Listeners connect to named signals with lifecycle controls. To aid diagnostics, the module retains a configurable history of pushed events, allowing developers to inspect past messages to trace game flows and simplify debugging.

## Functions

### `lurek.event.clear`

Clears all pending events from the shared event queue.

```lua
lurek.event.clear()
```

**Example**

```lua
do
    lurek.event.push("discard_me", 1)
    lurek.event.clear()
    print("queue cleared")
end
```

---

### `lurek.event.clearHistory`

Clears retained pushed event history.

```lua
lurek.event.clearHistory()
```

**Example**

```lua
do
    lurek.event.clearHistory()
    print("history cleared")
end
```

---

### `lurek.event.enableHistory`

Enables event push history with a maximum retained capacity.

```lua
lurek.event.enableHistory(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | number | Maximum number of pushed events to keep; zero disables retention. |

**Example**

```lua
do
    lurek.event.enableHistory(100)
    print("history enabled, capacity = 100")
end
```

---

### `lurek.event.exit`

Requests engine shutdown with an optional process exit code.

```lua
lurek.event.exit(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code?` | number | Optional exit code, defaulting to 0. |

**Example**

```lua
do
    print("exit function available = " .. tostring(type(lurek.event.exit) == "function"))
    print("exit(code) requests shutdown, so this example does not call it")
end
```

---

### `lurek.event.flushDeferred`

Moves all deferred events into the shared event queue and clears the deferred buffer.

```lua
lurek.event.flushDeferred()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of events flushed. |

**Example**

```lua
do
    lurek.event.pushDeferred("a", 1)
    lurek.event.pushDeferred("b", 2)
    local count = lurek.event.flushDeferred()
    print("flushed " .. count .. " deferred events")
end
```

---

### `lurek.event.getHistory`

Returns retained pushed event history entries.

```lua
lurek.event.getHistory()
```

**Returns**

| Type | Description |
|------|-------------|
| LEventGetHistoryResult | Array of entries with `name` and `args` fields. |

**Example**

```lua
do
    lurek.event.enableHistory(50)
    lurek.event.push("score", 999)
    local history = lurek.event.getHistory()
    print("history entries = " .. #history)
    if history[1] then
        print("latest name = " .. tostring(history[#history].name))
    end
end
```

---

### `lurek.event.newSignal`

Creates an isolated signal dispatcher for Lua callbacks.

```lua
lurek.event.newSignal()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSignal](#lsignal) | New signal handle. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    print("signal type = " .. sig:type())
end
```

---

### `lurek.event.poll`

Creates a polling function that returns the next queued event each time it is called.

```lua
lurek.event.poll()
```

**Returns**

| Type | Description |
|------|-------------|
| function | Poll function returning event values, or no values when the queue is empty. |

**Example**

```lua
do
    lurek.event.push("test_event", 42)
    local next_event = lurek.event.poll()
    for name, a1 in next_event do
        print("polled: " .. name .. " arg=" .. tostring(a1))
    end
end
```

---

### `lurek.event.pump`

Pumps the shared event queue without removing events for Lua.

```lua
lurek.event.pump()
```

**Example**

```lua
do
    lurek.event.pump()
    print("pumped")
end
```

---

### `lurek.event.push`

Pushes a normal-priority event into the shared event queue and optional history.

```lua
lurek.event.push(name, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Event name. |
| — | — | @param ... any Additional event arguments. |

**Example**

```lua
do
    lurek.event.push("player_hit", 25)
    print("pushed 'player_hit' event")
    print("push function type = " .. type(lurek.event.push))
end
```

---

### `lurek.event.pushDeferred`

Adds a normal-priority event to the deferred buffer instead of the live queue.

```lua
lurek.event.pushDeferred(name, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Event name to enqueue later. |
| — | — | @param ... any Additional event arguments stored with the event. |

**Example**

```lua
do
    lurek.event.pushDeferred("scene_ready", "main_menu")
    print("deferred 'scene_ready'")
    print("deferred helper type = " .. type(lurek.event.pushDeferred))
end
```

---

### `lurek.event.pushDeferredPriority`

Adds an event with explicit priority to the deferred buffer.

```lua
lurek.event.pushDeferredPriority(name, priority, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Event name to enqueue later. |
| `priority` | string | Priority string `high` or `normal`. |
| — | — | @param ... any Additional event arguments stored with the event. |

**Example**

```lua
do
    lurek.event.pushDeferredPriority("system_alert", "high", "low battery")
    print("deferred high-priority 'system_alert'")
    print("deferred priority helper type = " .. type(lurek.event.pushDeferredPriority))
end
```

---

### `lurek.event.pushPriority`

Pushes an event with explicit priority into the shared event queue and optional history.

```lua
lurek.event.pushPriority(name, priority, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Event name. |
| `priority` | string | Priority string `high` or `normal`. |
| — | — | @param ... any Additional event arguments. |

**Example**

```lua
do
    lurek.event.pushPriority("critical_error", "high", "out of memory")
    print("pushed high-priority event")
    print("priority helper ready = " .. tostring(type(lurek.event.pushPriority) == "function"))
end
```

---

### `lurek.event.quit`

Deprecated alias for `lurek.event.exit(0)`; requests engine shutdown with exit code zero.

```lua
lurek.event.quit()
```

**Example**

```lua
do
    print("quit function available = " .. tostring(type(lurek.event.quit) == "function"))
    print("quit() requests shutdown, so this example does not call it")
end
```

---

### `lurek.event.restart`

Requests a full engine restart cycle from the runtime.

```lua
lurek.event.restart()
```

**Example**

```lua
do
    print("restart function available = " .. tostring(type(lurek.event.restart) == "function"))
    print("restart() requests a runtime restart, so this example does not call it")
end
```

---

### `lurek.event.wait`

Waits for the next queued event and returns success, name, and argument table.

```lua
lurek.event.wait(timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout?` | number | Optional timeout in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an event was received before timeout. |
| string | Event name; or an empty string on timeout. |
| table | Array of event arguments; element types depend on the emitted event. |

**Example**

```lua
do
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0.1)
    print(ok and ("received: " .. name) or "timed out")
    if ok then
        print("arg count = " .. #args)
        print("first arg = " .. tostring(args[1]))
    end
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

- [LSignal](#lsignal)

## LSignal

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSignal:clear`

Removes all callbacks registered for one exact signal event name.

```lua
LSignal:clear(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name to clear. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of callbacks removed. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    sig:connect("update", function() end)
    sig:connect("update", function() end)
    local count = sig:clear("update")
    print("cleared " .. count .. " callbacks")
end
```

---

#### `LSignal:clearAll`

Removes every callback from this signal object.

```lua
LSignal:clearAll()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of callbacks removed. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    local count = sig:clearAll()
    print("cleared all: " .. count)
end
```

---

#### `LSignal:connect`

Registers a callback for an exact name or wildcard signal pattern.

```lua
LSignal:connect(name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Exact signal event name or wildcard pattern. |
| `func` | function | Lua function invoked with emitted signal arguments. |

**Returns**

| Type | Description |
|------|-------------|
| number | Subscription handle used for removal. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    local handle = sig:connect("damage", function(amount)
        print("took " .. tostring(amount) .. " damage")
    end)
    print("connected, handle = " .. handle)
end
```

---

#### `LSignal:emit`

Emits a signal event and invokes matching callbacks with the remaining arguments.

```lua
LSignal:emit(name, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name to emit. |
| — | — | @param ... any Additional arguments passed to matching callbacks. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Fires callbacks synchronously; no value is returned. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    sig:connect("greet", function(name)
        print("hello " .. tostring(name))
    end)
    sig:emit("greet", "world")
end
```

---

#### `LSignal:getCount`

Returns the callback count for one exact signal event name.

```lua
LSignal:getCount(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of callbacks registered for the event. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    sig:connect("tick", function() end)
    sig:connect("tick", function() end)
    print("tick count = " .. sig:getCount("tick"))
end
```

---

#### `LSignal:getTotalCount`

Returns the total callback count across all signal event names.

```lua
LSignal:getTotalCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total callback count. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    sig:connect("a", function() end)
    sig:connect("b", function() end)
    sig:connect("b", function() end)
    print("total = " .. sig:getTotalCount())
end
```

---

#### `LSignal:once`

Registers a callback that is removed after its next matching emission.

```lua
LSignal:once(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name. |
| `callback` | function | Lua function invoked once with emitted signal arguments. |

**Returns**

| Type | Description |
|------|-------------|
| number | Subscription handle used for removal before it fires. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    local handle = sig:once("init", function()
        print("initialized (fires once)")
    end)
    print("once handle = " .. handle)
end
```

---

#### `LSignal:register`

Registers a callback for an exact signal event name.

```lua
LSignal:register(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name. |
| `callback` | function | Lua function invoked with emitted signal arguments. |

**Returns**

| Type | Description |
|------|-------------|
| number | Subscription handle used for removal. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    local handle = sig:register("heal", function(amount)
        print("healed " .. tostring(amount))
    end)
    print("registered, handle = " .. handle)
end
```

---

#### `LSignal:registerWithFilter`

Registers a callback that runs only when a filter callback returns true.

```lua
LSignal:registerWithFilter(name, callback, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Signal event name. |
| `callback` | function | Lua function invoked after the filter accepts the signal. |
| `filter` | function | Lua predicate called with emitted arguments. |

**Returns**

| Type | Description |
|------|-------------|
| number | Subscription handle used for removal. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    local handle = sig:registerWithFilter("hit", function(dmg)
        print("critical hit: " .. tostring(dmg))
    end, function(dmg)
        return dmg > 50
    end)
    print("registered with filter, handle = " .. handle)
end
```

---

#### `LSignal:remove`

Removes a signal callback by subscription handle.

```lua
LSignal:remove(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | number | Subscription handle returned by registration. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a callback was removed. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    local h = sig:connect("tick", function() end)
    local removed = sig:remove(h)
    print("removed = " .. tostring(removed))
end
```

---

#### `LSignal:type`

Returns the Lua-visible type name for this signal handle.

```lua
LSignal:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSignal](#lsignal)`. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    print("type = " .. sig:type())
end
```

---

#### `LSignal:typeOf`

Returns whether this signal handle matches a supported type name.

```lua
LSignal:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LSignal](#lsignal)`, `Signal`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sig = lurek.event.newSignal()
    print("is Signal = " .. tostring(sig:typeOf("LSignal")))
end
```

---
