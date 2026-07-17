# Event

## Purpose

Runs a dual-priority event queue, wildcard signal registry, and neutral ChangeSet envelope.

## Summary

- The `event` module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies.
- Queues, priorities, listeners, signals, and deferred dispatch work together so gameplay, input, and tooling events can move through one predictable channel.
- Wildcard-style subscriptions and explicit listener lifecycle management make the bus practical for both large subsystems and small script integrations.
- History and Rust-Lua payload transfer matter because the module is not only about dispatch, but also about making that dispatch inspectable and usable across the engine boundary.
- `newChangeSet()` provides a bounded, versioned collection of object/component mutations. It owns ordering, validation, deterministic hashing, and snapshot/restore only; it does not apply changes to ECS, physics, save, or network state.
- Lua code explicitly forwards a ChangeSet table to whichever existing module should consume it, keeping cross-system composition outside Rust.
- Read it as the shared traffic system for runtime messages.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.event.clear`

Clears all pending events from the shared event queue.

```lua
lurek.event.clear()
```

**Example**

```lua
do

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("discard_me", 1)
    lurek.event.push("discard_me_too", 2)
    lurek.event.clear()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("clear remaining=" .. tostring(#events) .. " queue_cleared=" .. tostring(#events == 0))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(4)
    lurek.event.push("histA", 1)
    lurek.event.push("histB", 2)
    local before = #lurek.event.getHistory()
    lurek.event.clearHistory()
    local after = #lurek.event.getHistory()
    lurek.log.info("clearHistory before=" .. tostring(before) .. " after=" .. tostring(after))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("score", 100)
    lurek.event.push("score", 200)
    local history = lurek.event.getHistory()
    lurek.log.info("enableHistory capacity=2 entries=" .. tostring(#history) .. " latest=" .. tostring(history[#history] and history[#history].args[1]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "exit_requested")
    local callable = type(lurek.event.exit) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("exit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("scene_ready", "hangar")
    lurek.event.pushDeferred("music_cue", "boss_intro")
    local moved = lurek.event.flushDeferred()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local last = events[#events] and events[#events].name or "none"
    lurek.log.info("flushDeferred moved=" .. tostring(moved) .. " count=" .. tostring(#events) .. " last=" .. last)
end
```

---

### `lurek.event.fromChangeSetTable`

Creates a ChangeSet from a table produced by `[LChangeSet](#lchangeset):toTable()`.

```lua
lurek.event.fromChangeSetTable(value, maxChanges)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | ChangeSet table with schema, revision, changes, and optional hash. |
| `maxChanges?` | number | Maximum accepted records; defaults to the table length or 10000. |

**Returns**

| Type | Description |
|------|-------------|
| [LChangeSet](#lchangeset) | Restored ChangeSet handle. |

**Example**

```lua
do
    local source = lurek.event.newChangeSet({ schema = "save.v1", revision = 2 })
    source:append(11, "health", "set", { value = 90 })
    local restored = lurek.event.fromChangeSetTable(source:toTable())
    local row = restored:toTable().changes[1]
    lurek.log.info("restored object=" .. row.objectId .. " component=" .. row.component .. " value=" .. row.payload.value)
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(4)
    lurek.event.push("score", 999, "gold")
    local history = lurek.event.getHistory()
    local first = history[1]
    local arg_count = first and #first.args or 0
    lurek.log.info("getHistory entries=" .. tostring(#history) .. " name=" .. tostring(first and first.name) .. " arg_count=" .. tostring(arg_count))
end
```

---

### `lurek.event.newChangeSet`

Creates an empty bounded ChangeSet for neutral state replication, save, or Lua-side module integration.

```lua
lurek.event.newChangeSet(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | table | Optional `schema`, `revision`, and `maxChanges` fields. Defaults are `"game"`, `0`, and `10000`. |

**Returns**

| Type | Description |
|------|-------------|
| [LChangeSet](#lchangeset) | Isolated ChangeSet handle. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "actor.v1", revision = 7, maxChanges = 16 })
    local schema = changes:schema()
    local revision = changes:revision()
    local empty = changes:isEmpty()
    lurek.log.info("changeset schema=" .. schema .. " revision=" .. revision .. " empty=" .. tostring(empty))
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
    lurek.log.info("newSignal type=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("ev1", 10)
    lurek.event.push("ev2", 20)
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1]
    local second = events[2]
    lurek.log.info("poll first=" .. tostring(first and first.name) .. ":" .. tostring(first and first.args[1]) .. " second=" .. tostring(second and second.name) .. ":" .. tostring(second and second.args[1]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("hud_refresh", "health_bar")
    lurek.event.pump()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1] and events[1].name or "none"
    lurek.log.info("pump remaining=" .. tostring(#events) .. " first=" .. first .. " callable=" .. tostring(type(lurek.event.pump) == "function"))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("player_hit", 25, "critical")
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1]
    local count = #events
    lurek.log.info("push count=" .. tostring(count) .. " name=" .. tostring(first and first.name) .. " damage=" .. tostring(first and first.args[1]) .. " tag=" .. tostring(first and first.args[2]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("scene_ready", "main_menu")
    local before = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        before[#before + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local moved = lurek.event.flushDeferred()
    local after = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        after[#after + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("pushDeferred before=" .. tostring(#before) .. " moved=" .. tostring(moved) .. " after=" .. tostring(#after) .. " name=" .. tostring(after[1] and after[1].name))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.pushDeferred("normal_deferred", "slow")
    lurek.event.pushDeferredPriority("high_deferred", "high", "fast")
    local moved = lurek.event.flushDeferred()
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    lurek.log.info("pushDeferredPriority moved=" .. tostring(moved) .. " first=" .. tostring(events[1] and events[1].name) .. " second=" .. tostring(events[2] and events[2].name))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.push("normal_evt", 1)
    lurek.event.pushPriority("high_evt", "high", 2)
    local events = {}
    for event_name, a1, a2, a3 in lurek.event.poll() do
        events[#events + 1] = { name = event_name, args = { a1, a2, a3 } }
    end
    local first = events[1] and events[1].name or "none"
    local second = events[2] and events[2].name or "none"
    lurek.log.info("pushPriority first=" .. first .. " second=" .. second .. " count=" .. tostring(#events))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "quit_requested")
    local callable = type(lurek.event.quit) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("quit callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    lurek.event.enableHistory(2)
    lurek.event.push("menu_action", "restart_requested")
    local callable = type(lurek.event.restart) == "function"
    local history = lurek.event.getHistory()
    lurek.log.info("restart callable=" .. tostring(callable) .. " note=not_called entries=" .. tostring(#history) .. " action=" .. tostring(history[1] and history[1].args[1]))
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

    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
    local timed_out, empty_name, empty_args = lurek.event.wait(0.01)
    lurek.event.push("wake_up", "now")
    local ok, name, args = lurek.event.wait(0)
    lurek.log.info("wait timeout=" .. tostring(timed_out) .. " empty=" .. tostring(empty_name) .. "/" .. tostring(#empty_args) .. " ok=" .. tostring(ok) .. " name=" .. tostring(name) .. " arg=" .. tostring(args[1]))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LChangeSet](#lchangeset)
- [LSignal](#lsignal)

## LChangeSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LChangeSet:append`

Appends one neutral object/component mutation and returns the new record count.

```lua
LChangeSet:append(objectId, component, operation, payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `objectId` | number | Stable object identifier greater than zero. |
| `component` | string | Caller-defined state namespace. |
| `operation` | string | Caller-defined operation name. |
| `payload` | any | Recursively serializable operation data. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of records after the append. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "world.v1" })
    local count = changes:append(42, "position", "set", { x = 12, y = 8, level = 1 })
    local table_value = changes:toTable()
    lurek.log.info("appended=" .. count .. " records=" .. #table_value.changes .. " operation=" .. table_value.changes[1].operation)
end
```

---

#### `LChangeSet:clear`

Removes all records and returns the number removed.

```lua
LChangeSet:clear()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of records removed. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet()
    changes:append(1, "flag", "set", true)
    changes:append(2, "flag", "set", false)
    local removed = changes:clear()
    lurek.log.info("cleared=" .. removed .. " remaining=" .. changes:len() .. " empty=" .. tostring(changes:isEmpty()))
end
```

---

#### `LChangeSet:hash`

Returns the deterministic FNV-1a hash of schema, revision, and ordered records.

```lua
LChangeSet:hash()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Decimal unsigned 64-bit ChangeSet hash (string preserves LuaJIT precision). |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "hash.v1", revision = 3 })
    changes:append(7, "score", "set", 99)
    local hash = changes:hash()
    local snapshot_hash = changes:snapshot().hash
    lurek.log.info("hash=" .. tostring(hash) .. " snapshot_matches=" .. tostring(hash == snapshot_hash))
end
```

---

#### `LChangeSet:isEmpty`

Returns true when the ChangeSet contains no records.

```lua
LChangeSet:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the ChangeSet is empty. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet()
    local before = changes:isEmpty()
    changes:append(3, "alive", "set", true)
    local after = changes:isEmpty()
    lurek.log.info("empty before=" .. tostring(before) .. " after append=" .. tostring(after))
end
```

---

#### `LChangeSet:len`

Returns the number of records currently stored.

```lua
LChangeSet:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Record count. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet()
    local before = changes:len()
    changes:append(8, "ammo", "set", 12)
    local after = changes:len()
    lurek.log.info("length before=" .. before .. " after=" .. after)
end
```

---

#### `LChangeSet:restore`

Restores records from a table produced by `snapshot` or `toTable`.

```lua
LChangeSet:restore(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Snapshot with schema, revision, changes, and optional hash. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "restore.v1" })
    local source = lurek.event.newChangeSet({ schema = "restore.v1" })
    source:append(5, "state", "set", { ready = true })
    changes:restore(source:snapshot())
    lurek.log.info("restored len=" .. changes:len() .. " state=" .. tostring(changes:toTable().changes[1].payload.ready))
end
```

---

#### `LChangeSet:revision`

Returns the caller-defined monotonic revision.

```lua
LChangeSet:revision()
```

**Returns**

| Type | Description |
|------|-------------|
| number | ChangeSet revision. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "revision.v1", revision = 18 })
    local revision = changes:revision()
    local snapshot_revision = changes:snapshot().revision
    lurek.log.info("revision=" .. revision .. " snapshot=" .. snapshot_revision)
end
```

---

#### `LChangeSet:schema`

Returns the schema identifier used to interpret records.

```lua
LChangeSet:schema()
```

**Returns**

| Type | Description |
|------|-------------|
| string | ChangeSet schema name. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "content.v2" })
    local schema = changes:schema()
    local table_schema = changes:toTable().schema
    lurek.log.info("schema=" .. schema .. " table_schema=" .. table_schema)
end
```

---

#### `LChangeSet:snapshot`

Returns a deterministic Lua snapshot including the derived hash.

```lua
LChangeSet:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Snapshot suitable for save or network transport. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "network.v1", revision = 4 })
    changes:append(10, "owner", "set", "player_one")
    local snapshot = changes:snapshot()
    lurek.log.info("snapshot schema=" .. snapshot.schema .. " revision=" .. snapshot.revision .. " rows=" .. #snapshot.changes)
end
```

---

#### `LChangeSet:toTable`

Converts the ChangeSet to a transport-neutral Lua table.

```lua
LChangeSet:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Schema, revision, hash, and ordered change records. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet({ schema = "table.v1" })
    changes:append(4, "tag", "set", "quest")
    local value = changes:toTable()
    lurek.log.info("table schema=" .. value.schema .. " object=" .. value.changes[1].objectId .. " payload=" .. value.changes[1].payload)
end
```

---

#### `LChangeSet:type`

Returns the Lua-visible type name.

```lua
LChangeSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `[LChangeSet](#lchangeset)`. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet()
    local type_name = changes:type()
    lurek.log.info("changeset type=" .. type_name .. " handle=" .. tostring(changes ~= nil))
end
```

---

#### `LChangeSet:typeOf`

Checks whether this handle matches `[LChangeSet](#lchangeset)` or `LObject`.

```lua
LChangeSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the name matches. |

**Example**

```lua
do
    local changes = lurek.event.newChangeSet()
    local is_changeset = changes:typeOf("LChangeSet")
    local is_object = changes:typeOf("LObject")
    lurek.log.info("changeset=" .. tostring(is_changeset) .. " object=" .. tostring(is_object))
end
```

---

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
    lurek.log.info("clear removed=" .. tostring(removed) .. " clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover))
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
    lurek.log.info("clearAll before=" .. tostring(before) .. " removed=" .. tostring(removed) .. " after=" .. tostring(after))
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
    lurek.log.info("connect handle=" .. tostring(handle) .. " seen=" .. seen .. " count=" .. tostring(count))
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
    lurek.log.info("emit a=" .. tostring(received_a) .. " b=" .. tostring(received_b) .. " total=" .. tostring(sig:getTotalCount()))
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
    lurek.log.info("getCount clicks=" .. tostring(clicks) .. " hover=" .. tostring(hover) .. " missing=" .. tostring(missing))
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
    lurek.log.info("getTotalCount total=" .. tostring(total) .. " a=" .. tostring(clicks) .. " b=" .. tostring(sig:getCount("b")))
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
    lurek.log.info("once handle=" .. tostring(handle) .. " count=" .. tostring(count) .. " remaining=" .. tostring(remaining))
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
    lurek.log.info("register handle=" .. tostring(handle) .. " total=" .. tostring(total) .. " count=" .. tostring(count))
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
    lurek.log.info("registerWithFilter handle=" .. tostring(handle) .. " hits=" .. tostring(hits) .. " total=" .. tostring(sig:getTotalCount()))
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
    lurek.log.info("remove removed=" .. tostring(removed) .. " count_a=" .. tostring(count_a) .. " count_b=" .. tostring(count_b) .. " remaining=" .. tostring(sig:getCount("tick")))
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
    lurek.log.info("type name=" .. type_name .. " total=" .. tostring(total) .. " is_signal=" .. tostring(is_signal))
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
    lurek.log.info("typeOf signal=" .. tostring(is_signal) .. " object=" .. tostring(is_object) .. " entity=" .. tostring(is_entity))
end
```

---
