# Event

## Summary

The `event` module provides priority-aware runtime event queuing and signal subscription primitives. Its core role is decoupled communication: producers push typed payloads, consumers poll or subscribe by name/wildcard, and delivery semantics preserve ordering guarantees within priority lanes.

`event_queue` owns queue storage, event structures, priority behavior, and Lua payload conversion helpers. `signal` owns subscriber registration and matching semantics. The module then re-exports these types so runtime and scripting layers can integrate without binding to submodule internals.

Design emphasis is predictable dispatch behavior and safe payload bridging to Lua. Conversion helpers ensure event arguments can cross the Rust-Lua boundary without ad-hoc per-system glue.

As a core runtime messaging surface, this module should remain deterministic, minimal, and explicit about queue/priority semantics. Domain-specific event meanings belong to caller modules, not to the queue itself.

Implementation detail and boundary guarantees for event: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: event_queue.rs: Dual-priority FIFO event queue (high and normal) with priority-based polling.; mod.rs: Priority queue with ordered dispatch and Lua payload conversion for runtime events.; signal.rs: Named signal subscription registry with exact-name and wildcard pattern matching.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### event_queue.rs

- Provides a dual-priority FIFO event queue that dispatches high-priority items before normal traffic.
- Defines portable event payload shapes that carry scalar and shallow table data across boundaries.
- Supports blocking wait semantics with timeout control for synchronized producer-consumer patterns.
- Converts queued payloads between Rust and Lua value domains using predictable marshalling rules.
- Preserves insertion order inside each priority lane to keep event flow behavior deterministic.
- Encapsulates push, poll, peek, and wait operations in one reusable runtime messaging primitive.
- Delivers the queue core used by event-driven systems that need ordered asynchronous signaling.

### mod.rs

- Provides the high-level event module boundary for queued dispatch and signal-based subscription routing.
- Connects payload conversion, priority handling, and listener registration into one communication layer.
- Delivers a stable event-facing surface for systems that need decoupled runtime messaging.

### signal.rs

- Provides named signal subscription storage with support for exact and wildcard pattern matching.
- Allocates stable handle ids so listeners can be removed or inspected through explicit lifecycle control.
- Resolves matching subscribers with deterministic behavior for both direct names and glob-style patterns.
- Exposes snapshot-friendly query helpers that aid runtime diagnostics and tooling inspection.
- Delivers the subscription registry used by event publishers to find active listeners efficiently.

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
| [LSignal](#lsignal-handle) | New signal handle. |

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

## Types

- [LSignal Handle](#lsignal-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LSignal Handle

### Fields

*No documented fields for this handle.*

### Methods

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
| string | The string `[LSignal](#lsignal-handle)`. |

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
| `name` | string | Type name to compare against `[LSignal](#lsignal-handle)`, `Signal`, and `Object`. |

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
