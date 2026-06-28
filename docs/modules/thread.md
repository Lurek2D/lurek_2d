# Thread

## Purpose

Parallel Lua workers via isolated threads, safe channels, and promises.

## Summary

- The `thread` module is the isolated-concurrency surface for projects that want background Lua work without violating the engine's VM and runtime-safety rules.
- Channels, worker threads, pools, and promises let asynchronous work move messages and results between isolated execution contexts instead of sharing unsafe state directly.
- That matters because concurrency here is not just thread creation; it is about controlling what can cross between workers and how results return safely.
- The module is useful for expensive background tasks, staged jobs, and workflows where script-facing logic should continue while separate workers finish their part of the work.
- Promise-style completion is central because finished work still has to rejoin the foreground safely.
- It keeps worker isolation visible to scripts while still making background jobs practical and safe.
- Read it as the engine's sanctioned script-concurrency model.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.thread.async`

Runs a Lua code string or dumped function asynchronously on a new worker thread, returning a promise for the result.

```lua
lurek.thread.async(codeOrFunc, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `codeOrFunc` | string|function | Lua source code or a dumpable Lua function to execute. |
| — | — | @param ... any Additional arguments forwarded to the worker. |

**Returns**

| Type | Description |
|------|-------------|
| [LPromise](#lpromise) | A promise that resolves to the worker's return value. |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local done = promise:isDone()
    local result = promise:result()
    lurek.log.info("[thread] async promise type=" .. type_name .. " done=" .. tostring(done) .. " result=" .. tostring(result))
end
```

---

### `lurek.thread.getChannel`

Returns a named shared channel, creating it on first access. Repeated calls with the same name return the same channel.

```lua
lurek.thread.getChannel(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name identifying the shared channel. |

**Returns**

| Type | Description |
|------|-------------|
| [LChannel](#lchannel) | The named channel instance. |

**Example**

```lua
do
    local events = lurek.thread.getChannel("events")
    events:clear()
    events:push("player_died")
    local same = lurek.thread.getChannel("events")
    local message = same:pop()
    lurek.log.info("[thread] shared channel message=" .. tostring(message) .. " same_instance=" .. tostring(events == same))
end
```

---

### `lurek.thread.getWorkerCapabilities`

Returns a list of capability names available inside worker VMs (e.g. which `lurek.*` modules are accessible).

```lua
lurek.thread.getWorkerCapabilities()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Integer-indexed list of capability name strings. |

**Example**

```lua
do
    local caps = lurek.thread.getWorkerCapabilities()
    local first = caps[1] or "none"
    local count = #caps
    local has_thread = count > 0
    lurek.log.info("[thread] worker capabilities count=" .. count .. " first=" .. first .. " available=" .. tostring(has_thread))
end
```

---

### `lurek.thread.newBoundedChannel`

Creates a new bounded channel with a fixed capacity, blocking pushes when full.

```lua
lurek.thread.newBoundedChannel(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | number | Maximum number of items the channel can hold. |

**Returns**

| Type | Description |
|------|-------------|
| [LChannel](#lchannel) | A new bounded channel. |

**Example**

```lua
do
    local channel = lurek.thread.newBoundedChannel(10)
    channel:push("frame_1")
    local bounded = channel:isBounded()
    local capacity = channel:getCapacity()
    lurek.log.info("[thread] bounded channel bounded=" .. tostring(bounded) .. " capacity=" .. capacity .. " count=" .. channel:getCount())
end
```

---

### `lurek.thread.newChannel`

Creates a new unbounded channel for sending typed values between threads.

```lua
lurek.thread.newChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LChannel](#lchannel) | A new unbounded channel. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("spawn_enemy")
    local type_name = channel:type()
    local count = channel:getCount()
    lurek.log.info("[thread] new channel type=" .. type_name .. " count=" .. count .. " bounded=" .. tostring(channel:isBounded()))
end
```

---

### `lurek.thread.newPool`

Creates a fixed-size thread pool where each worker runs the same Lua code and consumes items from a shared input channel.

```lua
lurek.thread.newPool(size, code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Number of worker threads to spawn. |
| `code` | string | Lua source code each worker thread will execute. |

**Returns**

| Type | Description |
|------|-------------|
| [LThreadPool](#lthreadpool) | A pool handle for submitting work and collecting results. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local type_name = pool:type()
    local size = pool:size()
    local matches = pool:typeOf("LThreadPool")
    lurek.log.info("[thread] new pool type=" .. type_name .. " workers=" .. size .. " matches=" .. tostring(matches))
end
```

---

### `lurek.thread.newThread`

Creates a new worker thread that will execute the given Lua code string when started.

```lua
lurek.thread.newThread(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | Lua source code to run in the worker VM. |

**Returns**

| Type | Description |
|------|-------------|
| LThread | A thread handle that can be started, waited on, and inspected. |

**Example**

```lua
do
    local results = lurek.thread.getChannel("thread_results")
    results:clear()
    local thread = lurek.thread.newThread([[
        local ch = lurek.thread.getChannel("thread_results")
        ch:push(21 * 2)
    ]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] newThread result=" .. tostring(results:pop()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.thread.async` param `codeOrFunc` (`string|function`): Lua source code or a dumpable Lua function to execute.

## Enums

*No module-specific enums documented.*

## Types

- [LChannel](#lchannel)
- [LPromise](#lpromise)
- [LThreadHandle](#lthreadhandle)
- [LThreadPool](#lthreadpool)

## LChannel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LChannel:clear`

Removes all pending values from the channel.

```lua
LChannel:clear()
```

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("x")
    channel:push("y")
    local before = channel:getCount()
    channel:clear()
    lurek.log.info("[thread] clear removed queue from " .. before .. " to " .. channel:getCount())
end
```

---

#### `LChannel:demand`

Blocks until a value is available on the channel or the optional timeout expires.

```lua
LChannel:demand(timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout?` | number | Maximum seconds to wait. If omitted, waits indefinitely. |

**Returns**

| Type | Description |
|------|-------------|
| table | The received message table. |
| nil | If the timeout expired. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("ready")
    local immediate = channel:demand(1.0)
    local timeout = channel:demand(0.01)
    lurek.log.info("[thread] demand immediate=" .. tostring(immediate) .. " timeout=" .. tostring(timeout))
end
```

---

#### `LChannel:getCapacity`

Returns the maximum capacity of a bounded channel, or `nil` for unbounded channels.

```lua
LChannel:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The capacity limit, or `nil` if unbounded. |

**Example**

```lua
do
    local channel = lurek.thread.newBoundedChannel(3)
    channel:push("job")
    local capacity = channel:getCapacity()
    local bounded = channel:isBounded()
    lurek.log.info("[thread] bounded channel capacity=" .. tostring(capacity) .. " count=" .. channel:getCount() .. " bounded=" .. tostring(bounded))
end
```

---

#### `LChannel:getCount`

Returns the number of values currently queued in the channel.

```lua
LChannel:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The current item count. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("x")
    channel:push("y")
    local count = channel:getCount()
    local preview = channel:peek()
    lurek.log.info("[thread] getCount reports " .. count .. " next=" .. tostring(preview))
end
```

---

#### `LChannel:isBounded`

Checks whether this channel has a fixed capacity limit.

```lua
LChannel:isBounded()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the channel is bounded. |

**Example**

```lua
do
    local channel = lurek.thread.newBoundedChannel(1)
    channel:push("job")
    local bounded = channel:isBounded()
    local count = channel:getCount()
    lurek.log.info("[thread] channel bounded=" .. tostring(bounded) .. " capacity=" .. tostring(channel:getCapacity()) .. " count=" .. count)
end
```

---

#### `LChannel:peek`

Returns the next value from the channel without removing it.

```lua
LChannel:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The front message table. |
| nil | If the channel is empty. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("first")
    channel:push("second")
    local preview = channel:peek()
    local count = channel:getCount()
    lurek.log.info("[thread] peek saw=" .. tostring(preview) .. " while count stayed=" .. count)
end
```

---

#### `LChannel:pop`

Removes and returns the next value from the channel without blocking.

```lua
LChannel:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The next message table. |
| nil | If the channel is empty. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("hello")
    channel:push("world")
    local first = channel:pop()
    local remaining = channel:getCount()
    lurek.log.info("[thread] pop first=" .. tostring(first) .. " remaining=" .. remaining)
end
```

---

#### `LChannel:popBytes`

Pops the next value from the channel only if it is a byte blob, discarding non-bytes values.

```lua
LChannel:popBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The binary data as a Lua string, or `nil` if the channel is empty or the front value is not bytes. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:pushBytes(string.rep("\x00\xFF", 100))
    local payload = channel:popBytes()
    local size = #payload
    lurek.log.info("[thread] popBytes length=" .. size .. " remaining=" .. channel:getCount())
end
```

---

#### `LChannel:popTable`

Pops the next value from the channel only if it is a table, discarding non-table values.

```lua
LChannel:popTable()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The table value, or `nil` if the channel is empty or the front value is not a table. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:pushTable({ name = "player", hp = 100 })
    local result = channel:popTable()
    local hp = result.hp
    lurek.log.info("[thread] popTable name=" .. result.name .. " hp=" .. hp)
end
```

---

#### `LChannel:push`

Pushes a value onto the channel. Blocks on bounded channels if the channel is full.

```lua
LChannel:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| number | The message sequence ID assigned to this push. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    local id = channel:push("quest_started")
    local queued = channel:getCount()
    local preview = channel:peek()
    lurek.log.info("[thread] push queued id=" .. id .. " count=" .. queued .. " preview=" .. tostring(preview))
end
```

---

#### `LChannel:pushBytes`

Pushes raw binary data onto the channel as a byte blob.

```lua
LChannel:pushBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | The binary data to send (Lua strings can hold arbitrary bytes). |

**Returns**

| Type | Description |
|------|-------------|
| number | The message sequence ID assigned to this push. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    local payload = string.rep("\x00\xFF", 100)
    local id = channel:pushBytes(payload)
    local count = channel:getCount()
    lurek.log.info("[thread] pushBytes id=" .. id .. " bytes=" .. #payload .. " count=" .. count)
end
```

---

#### `LChannel:pushTable`

Pushes a table value onto the channel, raising an error if the value is not a table.

```lua
LChannel:pushTable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | The table to send through the channel. |

**Returns**

| Type | Description |
|------|-------------|
| number | The message sequence ID assigned to this push. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = channel:pushTable(payload)
    local preview = channel:peek()
    lurek.log.info("[thread] pushTable id=" .. id .. " preview_name=" .. tostring(preview.name))
end
```

---

#### `LChannel:supply`

Pushes a value and blocks until a consumer pops it (synchronous handoff).

```lua
LChannel:supply(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | true when the value has been consumed. |

**Example**

```lua
do
    local channel = lurek.thread.newBoundedChannel(2)
    channel:tryPush("a")
    channel:tryPush("b")
    local ok = channel:supply("c")
    local count = channel:getCount()
    lurek.log.info("[thread] supply when full=" .. tostring(ok) .. " queued=" .. count)
end
```

---

#### `LChannel:tryPush`

Attempts to push a value onto a bounded channel without blocking.

```lua
LChannel:tryPush(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | true if the value was enqueued, false if the channel is full. |

**Example**

```lua
do
    local channel = lurek.thread.newBoundedChannel(2)
    local first = channel:tryPush("a")
    local second = channel:tryPush("b")
    local third = channel:tryPush("c")
    lurek.log.info("[thread] tryPush results=" .. tostring(first) .. "," .. tostring(second) .. "," .. tostring(third))
end
```

---

#### `LChannel:type`

Returns the type name of this object.

```lua
LChannel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns `"[LChannel](#lchannel)"`. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("job")
    local type_name = channel:type()
    local bounded = channel:isBounded()
    lurek.log.info("[thread] channel type=" .. type_name .. " count=" .. channel:getCount() .. " bounded=" .. tostring(bounded))
end
```

---

#### `LChannel:typeOf`

Checks whether this object matches the given type name.

```lua
LChannel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against (`"[LChannel](#lchannel)"`, `"Channel"`, or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local channel = lurek.thread.newChannel()
    channel:push("job")
    local matches = channel:typeOf("LChannel")
    local type_name = channel:type()
    lurek.log.info("[thread] channel typeOf LChannel=" .. tostring(matches) .. " type=" .. type_name)
end
```

---

## LPromise

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPromise:chain`

Creates a new promise that runs the given code with the parent promise's result as its first argument.

```lua
LPromise:chain(code, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | Lua source code to execute in the chained worker thread. |
| — | — | @param ... any Additional arguments forwarded after the parent result. |

**Returns**

| Type | Description |
|------|-------------|
| [LPromise](#lpromise) | A new promise representing the chained computation. |

**Example**

```lua
do
    local first = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(10)")
    while not first:isDone() do
    end
    local second = first:chain("lurek.thread.getChannel('__promise_result'):push((arg[1] or 0) * 3)")
    while not second:isDone() do
    end
    local result = second:result()
    local done = second:isDone()
    lurek.log.info("[thread] promise chain result=" .. tostring(result) .. " done=" .. tostring(done))
end
```

---

#### `LPromise:getError`

Returns the error message from the promise, if it terminated with an error.

```lua
LPromise:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The error string, or `nil` if the promise succeeded or is still running. |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local done = promise:isDone()
    local result = promise:result()
    local error_message = promise:getError()
    lurek.log.info("[thread] promise done_before=" .. tostring(done) .. " result=" .. tostring(result) .. " error=" .. tostring(error_message))
end
```

---

#### `LPromise:isDone`

Checks whether the asynchronous computation has completed.

```lua
LPromise:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the promise has finished (either successfully or with an error). |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local before = promise:isDone()
    local result = promise:result()
    local after = promise:isDone()
    lurek.log.info("[thread] promise isDone before=" .. tostring(before) .. " after=" .. tostring(after) .. " result=" .. tostring(result))
end
```

---

#### `LPromise:result`

Returns the result value of the completed promise.

```lua
LPromise:result()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The computed result table. |
| nil | If the promise is not yet done. |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local result = promise:result()
    local done = promise:isDone()
    lurek.log.info("[thread] promise type=" .. type_name .. " result=" .. tostring(result) .. " done=" .. tostring(done))
end
```

---

#### `LPromise:type`

Returns the type name of this object.

```lua
LPromise:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns `"[LPromise](#lpromise)"`. |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local type_name = promise:type()
    local result = promise:result()
    local done = promise:isDone()
    lurek.log.info("[thread] promise type=" .. type_name .. " result=" .. tostring(result) .. " done=" .. tostring(done))
end
```

---

#### `LPromise:typeOf`

Checks whether this object matches the given type name.

```lua
LPromise:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against (`"Promise"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local promise = lurek.thread.async("lurek.thread.getChannel('__promise_result'):push(42)")
    local is_promise = promise:typeOf("LPromise")
    local result = promise:result()
    local type_name = promise:type()
    lurek.log.info("[thread] promise typeOf=" .. tostring(is_promise) .. " result=" .. tostring(result) .. " type=" .. type_name)
end
```

---

## LThreadHandle

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LThreadHandle:getError`

Returns the error message from the worker thread, if it terminated with an error.

```lua
LThreadHandle:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The error string, or `nil` if the thread completed successfully or is still running. |

**Example**

```lua
do
    local thread = lurek.thread.newThread("return 1")
    thread:start()
    thread:wait()
    local error_message = thread:getError()
    lurek.log.info("[thread] thread handle error=" .. tostring(error_message))
end
```

---

#### `LThreadHandle:isRunning`

Checks whether the worker thread is still executing.

```lua
LThreadHandle:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the thread has been started and has not yet finished. |

**Example**

```lua
do
    local thread = lurek.thread.newThread("return 1")
    local before = thread:isRunning()
    thread:start()
    thread:wait()
    local after = thread:isRunning()
    lurek.log.info("[thread] thread handle running before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LThreadHandle:start`

Launches the worker thread, executing the Lua code string supplied at creation time.

```lua
LThreadHandle:start(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Zero or more arguments forwarded to the worker as the `arg` table. |

**Example**

```lua
do
    local results = lurek.thread.getChannel("thread_handle_start")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_handle_start"):push("ok")]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread handle start pushed=" .. tostring(results:pop()))
end
```

---

#### `LThreadHandle:wait`

Blocks the calling thread until the worker thread finishes execution.

```lua
LThreadHandle:wait()
```

**Example**

```lua
do
    local results = lurek.thread.getChannel("thread_handle_wait")
    results:clear()
    local thread = lurek.thread.newThread([[lurek.thread.getChannel("thread_handle_wait"):push(99)]])
    thread:start()
    thread:wait()
    lurek.log.info("[thread] thread handle wait result=" .. tostring(results:pop()))
end
```

---

## LThreadPool

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LThreadPool:collect`

Pops and returns the next result from the pool's output channel.

```lua
LThreadPool:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The next result table. |
| nil | If the output channel is empty. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(10)
    pool:join(1.0)
    local result = pool:collect()
    lurek.log.info("[thread] collect returned=" .. tostring(result))
end
```

---

#### `LThreadPool:getInputChannel`

Returns the pool's shared input channel that feeds work items to worker threads.

```lua
LThreadPool:getInputChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LChannel](#lchannel) | The input channel. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local input = pool:getInputChannel()
    pool:submit(7)
    local count = input:getCount()
    lurek.log.info("[thread] input channel type=" .. input:type() .. " count=" .. count)
end
```

---

#### `LThreadPool:getOutputChannel`

Returns the pool's shared output channel where worker threads place their results.

```lua
LThreadPool:getOutputChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LChannel](#lchannel) | The output channel. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local output = pool:getOutputChannel()
    pool:submit(5)
    pool:join(1.0)
    local preview = output:peek()
    lurek.log.info("[thread] output channel type=" .. output:type() .. " preview=" .. tostring(preview))
end
```

---

#### `LThreadPool:join`

Blocks until all workers finish or the optional timeout elapses.

```lua
LThreadPool:join(timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout?` | number | Maximum seconds to wait. If omitted, waits indefinitely. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if all workers finished, `false` if the timeout expired. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(8)
    local joined = pool:join(2.0)
    local collected = pool:collect()
    lurek.log.info("[thread] join result=" .. tostring(joined) .. " collected=" .. tostring(collected))
end
```

---

#### `LThreadPool:size`

Returns the number of worker threads in the pool.

```lua
LThreadPool:size()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The pool's worker count. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(3)
    local size = pool:size()
    local input_count = pool:getInputChannel():getCount()
    lurek.log.info("[thread] thread pool size=" .. size .. " queued=" .. input_count)
end
```

---

#### `LThreadPool:submit`

Pushes a value into the pool's input channel for processing by a worker thread.

```lua
LThreadPool:submit(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The message value to send. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(10)
    local queued = pool:getInputChannel():getCount()
    local workers = pool:size()
    lurek.log.info("[thread] submit queued=" .. queued .. " workers=" .. workers)
end
```

---

#### `LThreadPool:type`

Returns the type name of this object.

```lua
LThreadPool:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns `"[LThreadPool](#lthreadpool)"`. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    pool:submit(3)
    local type_name = pool:type()
    local matches = pool:typeOf("LThreadPool")
    lurek.log.info("[thread] thread pool type=" .. type_name .. " size=" .. pool:size() .. " matches=" .. tostring(matches))
end
```

---

#### `LThreadPool:typeOf`

Checks whether this object matches the given type name.

```lua
LThreadPool:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against (`"ThreadPool"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.1)
        if value then
            output:push(value * 2)
        end
    ]])
    local matches = pool:typeOf("LThreadPool")
    pool:submit(4)
    local size = pool:size()
    lurek.log.info("[thread] thread pool typeOf LThreadPool=" .. tostring(matches) .. " size=" .. size)
end
```

---
