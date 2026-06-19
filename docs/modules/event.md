# Event

## Summary

- The `event` module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies.
- Queues, priorities, listeners, signals, and deferred dispatch work together so gameplay, input, and tooling events can move through one predictable channel.
- Wildcard-style subscriptions and explicit listener lifecycle management make the bus practical for both large subsystems and small script integrations.
- History and Rust-Lua payload transfer matter because the module is not only about dispatch, but also about making that dispatch inspectable and usable across the engine boundary.
- Read it as the shared traffic system for runtime messages.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.event.clear`

Clears all pending events from the shared event queue.

```lua
lurek.event.clear()
```

**Example**

```lua
do
    reset_event_state()
    lurek.event.push("discard_me", 1)
    lurek.event.push("discard_me_too", 2)
    lurek.event.clear()
    local events = collect_polled_events()
    event_log("clear remaining=" .. tostring(#events) .. " queue_cleared=" .. tostring(#events == 0))
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
    reset_event_state()
    lurek.event.enableHistory(4)
    lurek.event.push("histA", 1)
    lurek.event.push("histB", 2)
    local before = #lurek.event.getHistory()
    lurek.event.clearHistory()
    local after = #lurek.event.getHistory()
    event_log("clearHistory before=" .. tostring(before) .. " after=" .. tostring(after))
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
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("score", 100)
    lurek.event.push("score", 200)
    local history = lurek.event.getHistory()
    event_log("enableHistory capacity=2 entries=" .. tostring(#history) .. " latest=" .. tostring(history[#history] and history[#history].args[1]))
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
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "exit_requested")
    local callable = type(lurek.event.exit) == "function"
    local history = lurek.event.getHistory()
    event_log("exit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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
    reset_event_state()
    lurek.event.pushDeferred("scene_ready", "hangar")
    lurek.event.pushDeferred("music_cue", "boss_intro")
    local moved = lurek.event.flushDeferred()
    local events = collect_polled_events()
    local last = events[#events] and events[#events].name or "none"
    event_log("flushDeferred moved=" .. tostring(moved) .. " count=" .. tostring(#events) .. " last=" .. last)
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
    reset_event_state()
    lurek.event.enableHistory(4)
    lurek.event.push("score", 999, "gold")
    local history = lurek.event.getHistory()
    local first = history[1]
    local arg_count = first and #first.args or 0
    event_log("getHistory entries=" .. tostring(#history) .. " name=" .. tostring(first and first.name) .. " arg_count=" .. tostring(arg_count))
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
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    event_log("newSignal type=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
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
    reset_event_state()
    lurek.event.push("ev1", 10)
    lurek.event.push("ev2", 20)
    local events = collect_polled_events()
    local first = events[1]
    local second = events[2]
    event_log("poll first=" .. tostring(first and first.name) .. ":" .. tostring(first and first.args[1]) .. " second=" .. tostring(second and second.name) .. ":" .. tostring(second and second.args[1]))
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
    reset_event_state()
    lurek.event.push("hud_refresh", "health_bar")
    lurek.event.pump()
    local events = collect_polled_events()
    local first = events[1] and events[1].name or "none"
    event_log("pump remaining=" .. tostring(#events) .. " first=" .. first .. " callable=" .. tostring(type(lurek.event.pump) == "function"))
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
    reset_event_state()
    lurek.event.push("player_hit", 25, "critical")
    local events = collect_polled_events()
    local first = events[1]
    local count = #events
    event_log("push count=" .. tostring(count) .. " name=" .. tostring(first and first.name) .. " damage=" .. tostring(first and first.args[1]) .. " tag=" .. tostring(first and first.args[2]))
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
    reset_event_state()
    lurek.event.pushDeferred("scene_ready", "main_menu")
    local before = collect_polled_events()
    local moved = lurek.event.flushDeferred()
    local after = collect_polled_events()
    event_log("pushDeferred before=" .. tostring(#before) .. " moved=" .. tostring(moved) .. " after=" .. tostring(#after) .. " name=" .. tostring(after[1] and after[1].name))
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
    reset_event_state()
    lurek.event.pushDeferred("normal_deferred", "slow")
    lurek.event.pushDeferredPriority("high_deferred", "high", "fast")
    local moved = lurek.event.flushDeferred()
    local events = collect_polled_events()
    event_log("pushDeferredPriority moved=" .. tostring(moved) .. " first=" .. tostring(events[1] and events[1].name) .. " second=" .. tostring(events[2] and events[2].name))
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
    reset_event_state()
    lurek.event.push("normal_evt", 1)
    lurek.event.pushPriority("high_evt", "high", 2)
    local events = collect_polled_events()
    local first = events[1] and events[1].name or "none"
    local second = events[2] and events[2].name or "none"
    event_log("pushPriority first=" .. first .. " second=" .. second .. " count=" .. tostring(#events))
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
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "quit_requested")
    local callable = type(lurek.event.quit) == "function"
    local history = lurek.event.getHistory()
    event_log("quit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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
    reset_event_state()
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "restart_requested")
    local callable = type(lurek.event.restart) == "function"
    local history = lurek.event.getHistory()
    event_log("restart callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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
    reset_event_state()
    local timed_out, empty_name, empty_args = lurek.event.wait(0.01)
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0)
    event_log("wait timeout=" .. tostring(timed_out) .. " empty=" .. tostring(empty_name) .. "/" .. tostring(#empty_args) .. " ok=" .. tostring(ok) .. " name=" .. tostring(name) .. " arg=" .. tostring(args[1]))
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
    sig:connect("click", function() end)
    sig:connect("click", function() end)
    sig:connect("hover", function() end)
    local removed = sig:clear("click")
    local clicks = sig:getCount("click")
    local hover = sig:getCount("hover")
    event_log("clear removed=" .. tostring(removed) .. " clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover))
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
    sig:connect("b", function() end)
    local before = sig:getTotalCount()
    local removed = sig:clearAll()
    local after = sig:getTotalCount()
    event_log("clearAll before=" .. tostring(before) .. " removed=" .. tostring(removed) .. " after=" .. tostring(after))
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
    local seen = "none"
    local handle = sig:connect("player.*", function(kind) seen = kind end)
    sig:emit("player.jump", "jump")
    local count = sig:getCount("player.*")
    event_log("connect handle=" .. tostring(handle) .. " seen=" .. seen .. " count=" .. tostring(count))
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
    local received_a = nil
    local received_b = nil
    sig:connect("ping", function(a, b) received_a = a; received_b = b end)
    sig:emit("ping", 4, "ok")
    event_log("emit a=" .. tostring(received_a) .. " b=" .. tostring(received_b) .. " total=" .. tostring(sig:getTotalCount()))
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
    sig:register("click", function() end)
    sig:register("click", function() end)
    sig:register("hover", function() end)
    local clicks = sig:getCount("click")
    local hover = sig:getCount("hover")
    local missing = sig:getCount("missing")
    event_log("getCount clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover) .. " missing=" .. tostring(missing))
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
    sig:register("a", function() end)
    sig:register("b", function() end)
    sig:register("b", function() end)
    local total = sig:getTotalCount()
    local clicks = sig:getCount("a")
    event_log("getTotalCount total=" .. tostring(total) .. " a=" .. tostring(clicks) .. " b=" .. tostring(sig:getCount("b")))
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
    local count = 0
    local handle = sig:once("init", function() count = count + 1 end)
    sig:emit("init")
    sig:emit("init")
    local remaining = sig:getCount("init")
    event_log("once handle=" .. tostring(handle) .. " count=" .. tostring(count) .. " remaining=" .. tostring(remaining))
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
    local total = 0
    local handle = sig:register("heal", function(amount) total = total + amount end)
    sig:emit("heal", 15)
    local count = sig:getCount("heal")
    event_log("register handle=" .. tostring(handle) .. " total=" .. tostring(total) .. " count=" .. tostring(count))
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
    local hits = 0
    local handle = sig:registerWithFilter("hit", function(dmg) hits = hits + dmg end, function(dmg) return dmg > 50 end)
    sig:emit("hit", 10)
    sig:emit("hit", 75)
    event_log("registerWithFilter handle=" .. tostring(handle) .. " hits=" .. tostring(hits) .. " total=" .. tostring(sig:getTotalCount()))
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
    local count_a = 0
    local count_b = 0
    local handle_a = sig:connect("tick", function() count_a = count_a + 1 end)
    sig:connect("tick", function() count_b = count_b + 1 end)
    local removed = sig:remove(handle_a)
    sig:emit("tick")
    event_log("remove removed=" .. tostring(removed) .. " count_a=" .. tostring(count_a) .. " count_b=" .. tostring(count_b) .. " remaining=" .. tostring(sig:getCount("tick")))
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
    local type_name = sig:type()
    local total = sig:getTotalCount()
    local is_signal = sig:typeOf("LSignal")
    event_log("type name=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
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
    local is_signal = sig:typeOf("LSignal")
    local is_object = sig:typeOf("LObject")
    local is_entity = sig:typeOf("LEntity")
    event_log("typeOf signal=" .. tostring(is_signal) .. " object=" .. tostring(is_object) .. " entity=" .. tostring(is_entity))
end
```

---
