# Thread

- The `thread` module is an advanced Core Runtime tier component that introduces background threading and parallel execution to Lurek2D.

Adhering to the engine's strict architectural constraints (specifically B-04), it ensures that Lua VMs do not share state. Instead, it provisions isolated, per-thread Lua VMs that communicate exclusively via typed Multi-Producer, Multi-Consumer (MPMC) channels. The `Channel` struct is the backbone of this system, offering thread-safe message passing with both bounded (fixed capacity) and unbounded variants. It supports various overflow policies (block, drop-oldest, drop-newest, error) and handles transparent, recursive serialization between Lua values and Rust's `ChannelValue` enum (supporting nil, booleans, numbers, strings, nested tables, and raw bytes).

To facilitate concurrent workloads, the module provides a `ThreadPool`. This fixed-size pool manages a set of persistent worker threads, each running its own restricted Lua VM. These workers process tasks from a shared input channel and push results to an output channel. The worker VMs are deliberately sandboxed: they are denied access to window, rendering, and input APIs, and are injected only with safe, restricted capabilities like `lurek.thread.getChannel` and path-traversed-guarded `fs.read`. This design ensures that background tasks—such as pathfinding, procedural generation, or heavy data processing—cannot compromise the main thread's stability or access unauthorized host files.

For simpler, one-off asynchronous tasks, the module offers the `Promise` pattern. A `Promise` spawns a single worker thread to execute a piece of Lua code and safely collects the solitary result via an internal channel, allowing the main thread to poll for completion using `isDone` and `result` methods. Recently enhanced with composable promise chaining, bounded channel backpressure, and deadline-based blocking (`demand`), the `thread` module provides a comprehensive suite of concurrency primitives. Fully exposed via the `lurek.thread.*` API, it empowers developers to build responsive, multi-threaded Lua games without the pitfalls of shared mutable state.

## Functions

### `lurek.thread.async`

Runs a Lua code string or dumped function asynchronously on a new worker thread, returning a promise for the result.

```lua
-- signature
lurek.thread.async(codeOrFunc, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `codeOrFunc` | `string|function` | Lua source code or a dumpable Lua function to execute. |
| — | — | @param ... any Additional arguments forwarded to the worker. |

**Returns**

| Type | Description |
|------|-------------|
| `LPromise` | A promise that resolves to the worker's return value. |

**Example**

```lua
do
    local promise = lurek.thread.async("return 42")
    print("type = " .. promise:type())
    print("done immediately = " .. tostring(promise:isDone()))
end
```

---

### `lurek.thread.getChannel`

Returns a named shared channel, creating it on first access. Repeated calls with the same name return the same channel.

```lua
-- signature
lurek.thread.getChannel(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name identifying the shared channel. |

**Returns**

| Type | Description |
|------|-------------|
| `LChannel` | The named channel instance. |

**Example**

```lua
do
    local ch = lurek.thread.getChannel("events")
    ch:push("player_died")
    local same = lurek.thread.getChannel("events")
    print("shared channel msg = " .. tostring(same:pop()))
    print("same instance = " .. tostring(ch == same))
end
```

---

### `lurek.thread.getWorkerCapabilities`

Returns a list of capability names available inside worker VMs (e.g. which `lurek.*` modules are accessible).

```lua
-- signature
lurek.thread.getWorkerCapabilities()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Integer-indexed list of capability name strings. |

**Example**

```lua
do
    local caps = lurek.thread.getWorkerCapabilities()
    print("capabilities = " .. #caps)
end
```

---

### `lurek.thread.newBoundedChannel`

Creates a new bounded channel with a fixed capacity, blocking pushes when full.

```lua
-- signature
lurek.thread.newBoundedChannel(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | `number` | Maximum number of items the channel can hold. |

**Returns**

| Type | Description |
|------|-------------|
| `LChannel` | A new bounded channel. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(10)
    print("bounded = " .. tostring(ch:isBounded()))
    print("capacity = " .. ch:getCapacity())
    print("count = " .. ch:getCount())
end
```

---

### `lurek.thread.newChannel`

Creates a new unbounded channel for sending typed values between threads.

```lua
-- signature
lurek.thread.newChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LChannel` | A new unbounded channel. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    print("type = " .. ch:type())
    print("count = " .. ch:getCount())
    print("bounded = " .. tostring(ch:isBounded()))
end
```

---

### `lurek.thread.newPool`

Creates a fixed-size thread pool where each worker runs the same Lua code and consumes items from a shared input channel.

```lua
-- signature
lurek.thread.newPool(size, code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | `number` | Number of worker threads to spawn. |
| `code` | `string` | Lua source code each worker thread will execute. |

**Returns**

| Type | Description |
|------|-------------|
| `LThreadPool` | A pool handle for submitting work and collecting results. |

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
    print("type = " .. pool:type())
    print("pool size = " .. pool:size())
end
```

---

### `lurek.thread.newThread`

Creates a new worker thread that will execute the given Lua code string when started.

```lua
-- signature
lurek.thread.newThread(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | Lua source code to run in the worker VM. |

**Returns**

| Type | Description |
|------|-------------|
| `LThread` | A thread handle that can be started, waited on, and inspected. |

**Example**

```lua
do
    local results = lurek.thread.getChannel("results")
    results:clear()
    local thread = lurek.thread.newThread([[
        local ch = lurek.thread.getChannel("results")
        ch:push(21 * 2)
    ]])
    thread:start()
    thread:wait()
    print("result = " .. tostring(results:pop()))
end
```

---

## LChannel

### `LChannel:clear`

Removes all pending values from the channel.

```lua
-- signature
LChannel:clear()
```

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("before clear = " .. ch:getCount())
    ch:clear()
    print("after clear = " .. ch:getCount())
end
```

---

### `LChannel:demand`

Blocks until a value is available on the channel or the optional timeout expires.

```lua
-- signature
LChannel:demand(timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout?` | `number` | Maximum seconds to wait. If omitted, waits indefinitely. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The received message table. |
| `nil` | b If the timeout expired. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:push("ready")
    print("demand got = " .. tostring(ch:demand(1.0)))
    print("demand timeout = " .. tostring(ch:demand(0.01)))
end
```

---

### `LChannel:getCapacity`

Returns the maximum capacity of a bounded channel, or `nil` for unbounded channels.

```lua
-- signature
LChannel:getCapacity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The capacity limit, or `nil` if unbounded. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    print("capacity=" .. tostring(ch:getCapacity()))
end
```

---

### `LChannel:getCount`

Returns the number of values currently queued in the channel.

```lua
-- signature
LChannel:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The current item count. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:push("x")
    print("count = " .. ch:getCount())
end
```

---

### `LChannel:isBounded`

Checks whether this channel has a fixed capacity limit.

```lua
-- signature
LChannel:isBounded()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the channel is bounded. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    print("bounded=" .. tostring(ch:isBounded()))
end
```

---

### `LChannel:peek`

Returns the next value from the channel without removing it.

```lua
-- signature
LChannel:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The front message table. |
| `nil` | b If the channel is empty. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:push("first")
    print("peek = " .. tostring(ch:peek()))
    print("count after peek = " .. ch:getCount())
end
```

---

### `LChannel:pop`

Removes and returns the next value from the channel without blocking.

```lua
-- signature
LChannel:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The next message table. |
| `nil` | b If the channel is empty. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    ch:push("hello")
    local val1 = ch:pop()
    print("pop 1 = " .. tostring(val1))
end
```

---

### `LChannel:popBytes`

Pops the next value from the channel only if it is a byte blob, discarding non-bytes values.

```lua
-- signature
LChannel:popBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The binary data as a Lua string, or `nil` if the channel is empty or the front value is not bytes. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:pushBytes(string.rep("\x00\xFF", 100))
    print("popBytes length = " .. #ch:popBytes())
end
```

---

### `LChannel:popTable`

Pops the next value from the channel only if it is a table, discarding non-table values.

```lua
-- signature
LChannel:popTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | The table value, or `nil` if the channel is empty or the front value is not a table. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    ch:pushTable({ name = "player" })
    local result = ch:popTable()
    print("popTable name = " .. result.name)
end
```

---

### `LChannel:push`

Pushes a value onto the channel. Blocks on bounded channels if the channel is full.

```lua
-- signature
LChannel:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The message sequence ID assigned to this push. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local id1 = ch:push("hello")
    print("pushed id: " .. id1)
    print("count = " .. ch:getCount())
end
```

---

### `LChannel:pushBytes`

Pushes raw binary data onto the channel as a byte blob.

```lua
-- signature
LChannel:pushBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | The binary data to send (Lua strings can hold arbitrary bytes). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The message sequence ID assigned to this push. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local data = string.rep("\x00\xFF", 100)
    local id = ch:pushBytes(data)
    print("pushBytes id = " .. id)
end
```

---

### `LChannel:pushTable`

Pushes a table value onto the channel, raising an error if the value is not a table.

```lua
-- signature
LChannel:pushTable(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `table` | The table to send through the channel. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The message sequence ID assigned to this push. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newChannel()
    local payload = { name = "player", hp = 100, items = { "sword", "shield" } }
    local id = ch:pushTable(payload)
    print("pushTable id = " .. id)
end
```

---

### `LChannel:supply`

Pushes a value and blocks until a consumer pops it (synchronous handoff).

```lua
-- signature
LChannel:supply(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | true when the value has been consumed. |

**Example**

```lua
do
    local ch = lurek.thread.newBoundedChannel(2)
    ch:tryPush("a")
    ch:tryPush("b")
    print("supply when full = " .. tostring(ch:supply("d")))
end
```

---

### `LChannel:tryPush`

Attempts to push a value onto a bounded channel without blocking.

```lua
-- signature
LChannel:tryPush(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The message value to send. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | true if the value was enqueued, false if the channel is full. |

**Example**

```lua
do
    ---@type LChannel
    local ch = lurek.thread.newBoundedChannel(2)
    local ok1 = ch:tryPush("a")
    print("tryPush 1 = " .. tostring(ok1))
end
```

---

### `LChannel:type`

Returns the type name of this object.

```lua
-- signature
LChannel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns `"LChannel"`. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    print("type=" .. ch:type())
end
```

---

### `LChannel:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LChannel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against (`"LChannel"`, `"Channel"`, or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local ch = lurek.thread.newChannel()
    print("typeOf=" .. tostring(ch:typeOf("LChannel")))
end
```

---

## LPromise

### `LPromise:chain`

Creates a new promise that runs the given code with the parent promise's result as its first argument.

```lua
-- signature
LPromise:chain(code, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | Lua source code to execute in the chained worker thread. |
| — | — | @param ... any Additional arguments forwarded after the parent result. |

**Returns**

| Type | Description |
|------|-------------|
| `LPromise` | A new promise representing the chained computation. |

**Example**

```lua
do
    local first = lurek.thread.async([[
        local result = lurek.thread.getChannel("__promise_result")
        result:push(10)
    ]])
    local guard = 0
    while not first:isDone() and guard < 10000 do
        guard = guard + 1
    end
    local second = first:chain([[
        local prev = ...
        local result = lurek.thread.getChannel("__promise_result")
        result:push(prev * 3)
    ]])
    guard = 0
    while not second:isDone() and guard < 10000 do
        guard = guard + 1
    end
    print("chain result = " .. tostring(second:result()))
end
```

---

### `LPromise:getError`

Returns the error message from the promise, if it terminated with an error.

```lua
-- signature
LPromise:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The error string, or `nil` if the promise succeeded or is still running. |

**Example**

```lua
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("error = " .. tostring(promise:getError()))
end
```

---

### `LPromise:isDone`

Checks whether the asynchronous computation has completed.

```lua
-- signature
LPromise:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the promise has finished (either successfully or with an error). |

**Example**

```lua
do
    local promise = lurek.thread.async("return 42")
    promise:result()
    print("done = " .. tostring(promise:isDone()))
end
```

---

### `LPromise:result`

Returns the result value of the completed promise.

```lua
-- signature
LPromise:result()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The computed result table. |
| `nil` | b If the promise is not yet done. |

**Example**

```lua
do
    local promise = lurek.thread.async("return 42")
    print("result = " .. tostring(promise:result()))
end
```

---

### `LPromise:type`

Returns the type name of this object.

```lua
-- signature
LPromise:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns `"LPromise"`. |

**Example**

```lua
do
    local p = lurek.thread.async("return 42")
    local t = p:type()
    print("LPromise type:", t)
end
```

---

### `LPromise:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LPromise:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against (`"Promise"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local p = lurek.thread.async("return 42")
    local ok = p:typeOf("LPromise")
    print("LPromise typeOf:", ok)
end
```

---

## LThreadHandle

### `LThreadHandle:getError`

Returns the error message from the worker thread, if it terminated with an error.

```lua
-- signature
LThreadHandle:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The error string, or `nil` if the thread completed successfully or is still running. |

**Example**

```lua
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    t:wait()
    print("LThreadHandle:getError = " .. tostring(t:getError()))
end
```

---

### `LThreadHandle:isRunning`

Checks whether the worker thread is still executing.

```lua
-- signature
LThreadHandle:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the thread has been started and has not yet finished. |

**Example**

```lua
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("LThreadHandle:isRunning = " .. tostring(t:isRunning()))
end
```

---

### `LThreadHandle:start`

Launches the worker thread, executing the Lua code string supplied at creation time.

```lua
-- signature
LThreadHandle:start(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Zero or more arguments forwarded to the worker as the `arg` table. |

**Example**

```lua
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    print("LThreadHandle:start ok")
end
```

---

### `LThreadHandle:wait`

Blocks the calling thread until the worker thread finishes execution.

```lua
-- signature
LThreadHandle:wait()
```

**Example**

```lua
do
    local t = lurek.thread.newThread("return 1")
    t:start()
    t:wait()
    print("LThreadHandle:wait ok")
end
```

---

## LThreadPool

### `LThreadPool:collect`

Pops and returns the next result from the pool's output channel.

```lua
-- signature
LThreadPool:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The next result table. |
| `nil` | b If the output channel is empty. |

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
    print("collected = " .. tostring(pool:collect()))
end
```

---

### `LThreadPool:getInputChannel`

Returns the pool's shared input channel that feeds work items to worker threads.

```lua
-- signature
LThreadPool:getInputChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LChannel` | The input channel. |

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
    local inCh = pool:getInputChannel()
    print("input channel type = " .. inCh:type())
    print("input bounded = " .. tostring(inCh:isBounded()))
end
```

---

### `LThreadPool:getOutputChannel`

Returns the pool's shared output channel where worker threads place their results.

```lua
-- signature
LThreadPool:getOutputChannel()
```

**Returns**

| Type | Description |
|------|-------------|
| `LChannel` | The output channel. |

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
    local outCh = pool:getOutputChannel()
    print("output channel type = " .. outCh:type())
    print("output count = " .. outCh:getCount())
end
```

---

### `LThreadPool:join`

Blocks until all workers finish or the optional timeout elapses.

```lua
-- signature
LThreadPool:join(timeout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout?` | `number` | Maximum seconds to wait. If omitted, waits indefinitely. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if all workers finished, `false` if the timeout expired. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(2, "return nil")
    print("join result = " .. tostring(pool:join(2.0)))
end
```

---

### `LThreadPool:size`

Returns the number of worker threads in the pool.

```lua
-- signature
LThreadPool:size()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The pool's worker count. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local sz = pool:size()
    print("pool size = " .. sz)
end
```

---

### `LThreadPool:submit`

Pushes a value into the pool's input channel for processing by a worker thread.

```lua
-- signature
LThreadPool:submit(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | The message value to send. |

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
    print("submitted one task")
    print("input count = " .. pool:getInputChannel():getCount())
end
```

---

### `LThreadPool:type`

Returns the type name of this object.

```lua
-- signature
LThreadPool:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns `"LThreadPool"`. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local t = pool:type()
    print("type = " .. t)
end
```

---

### `LThreadPool:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LThreadPool:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against (`"ThreadPool"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | `true` if the name matches one of the accepted type names. |

**Example**

```lua
do
    local pool = lurek.thread.newPool(3, [[
        local input = lurek.thread.getChannel("__pool_input")
        local output = lurek.thread.getChannel("__pool_output")
        local value = input:demand(0.05)
        if value then
            output:push(value)
        end
    ]])
    local ok = pool:typeOf("LThreadPool")
    print("typeOf = " .. tostring(ok))
end
```

---
