-- content/examples/thread.lua
-- love2d-style usage snippets for the lurek.thread API (37 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/thread.lua

-- ── lurek.thread.* functions ──

--@api-stub: lurek.thread.newThread
-- Creates a new background thread from a Lua code string.
-- Build once at startup; reuse across frames.
local thread = lurek.thread.newThread(code)
print("created", thread)
return thread

--@api-stub: lurek.thread.newChannel
-- Creates an unnamed thread-safe channel for inter-thread communication.
-- Build once at startup; reuse across frames.
local channel = lurek.thread.newChannel()
print("created", channel)
return channel

--@api-stub: lurek.thread.getChannel
-- Gets or creates a named global channel shared across threads.
-- Cheap to call; safe inside callbacks.
local value = lurek.thread.getChannel("main")
print("getChannel:", value)
return value

--@api-stub: lurek.thread.newPool
-- Creates a thread pool of N workers all running the same Lua code.
-- Build once at startup; reuse across frames.
local pool = lurek.thread.newPool(10, code)
print("created", pool)
return pool

--@api-stub: lurek.thread.async
-- Starts a one-shot background computation and returns a Promise.
-- See the module spec for detailed semantics.
local result = lurek.thread.async(code, { x = 0, y = 0 })
print("async:", result)
return result

-- ── ThreadHandle methods ──

--@api-stub: ThreadHandle:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local threadHandle = lurek.thread.newThreadHandle()
threadHandle:type()
print("ThreadHandle:type done")

--@api-stub: ThreadHandle:typeOf
-- Returns whether this object is of the given type.
-- See the module spec for detailed semantics.
local threadHandle = lurek.thread.newThreadHandle()
threadHandle:typeOf("main")
print("ThreadHandle:typeOf done")

--@api-stub: ThreadHandle:start
-- Launches the background thread, passing optional arguments via varargs.
-- Trigger from input, timers, or game events.
local threadHandle = lurek.thread.newThreadHandle()
threadHandle:start({ x = 0, y = 0 })
-- trigger from input, timer, or event
print("ok")

--@api-stub: ThreadHandle:wait
-- Blocks the calling thread until the background thread finishes.
-- See the module spec for detailed semantics.
local threadHandle = lurek.thread.newThreadHandle()
threadHandle:wait()
print("ThreadHandle:wait done")

--@api-stub: ThreadHandle:isRunning
-- Returns whether the thread is currently executing.
-- Use as a guard inside lurek.update or event handlers.
local threadHandle = lurek.thread.newThreadHandle()
if threadHandle:isRunning() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ThreadHandle:getError
-- Returns the error message if the thread failed, or nil.
-- Cheap to call; safe inside callbacks.
local threadHandle = lurek.thread.newThreadHandle()  -- or your existing handle
local value = threadHandle:getError()
print("ThreadHandle:getError ->", value)

-- ── ThreadPool methods ──

--@api-stub: ThreadPool:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:type()
print("ThreadPool:type done")

--@api-stub: ThreadPool:typeOf
-- Returns whether this object is of the given type.
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:typeOf("main")
print("ThreadPool:typeOf done")

--@api-stub: ThreadPool:submit
-- Submits a value to the pool's input channel for processing by a worker.
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:submit(value)
print("ThreadPool:submit done")

--@api-stub: ThreadPool:collect
-- Retrieves the next result from the pool's output channel (non-blocking).
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:collect()
print("ThreadPool:collect done")

--@api-stub: ThreadPool:size
-- Returns the number of workers in this pool.
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:size()
print("ThreadPool:size done")

--@api-stub: ThreadPool:join
-- Blocks until all workers in the pool have finished execution.
-- See the module spec for detailed semantics.
local threadPool = lurek.thread.newThreadPool()
threadPool:join()
print("ThreadPool:join done")

--@api-stub: ThreadPool:getInputChannel
-- Returns the shared input Channel (main â†’ workers).
-- Cheap to call; safe inside callbacks.
local threadPool = lurek.thread.newThreadPool()  -- or your existing handle
local value = threadPool:getInputChannel()
print("ThreadPool:getInputChannel ->", value)

--@api-stub: ThreadPool:getOutputChannel
-- Returns the shared output Channel (workers â†’ main).
-- Cheap to call; safe inside callbacks.
local threadPool = lurek.thread.newThreadPool()  -- or your existing handle
local value = threadPool:getOutputChannel()
print("ThreadPool:getOutputChannel ->", value)

-- ── Promise methods ──

--@api-stub: Promise:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local promise = lurek.thread.newPromise()
promise:type()
print("Promise:type done")

--@api-stub: Promise:typeOf
-- Returns whether this object is of the given type.
-- See the module spec for detailed semantics.
local promise = lurek.thread.newPromise()
promise:typeOf("main")
print("Promise:typeOf done")

--@api-stub: Promise:isDone
-- Returns true if the promise has a result or has errored (non-blocking).
-- Use as a guard inside lurek.update or event handlers.
local promise = lurek.thread.newPromise()
if promise:isDone() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Promise:result
-- Pops and returns the promise result, or nil if not yet ready.
-- See the module spec for detailed semantics.
local promise = lurek.thread.newPromise()
promise:result()
print("Promise:result done")

--@api-stub: Promise:getError
-- Returns the worker error string if the promise failed, otherwise nil.
-- Cheap to call; safe inside callbacks.
local promise = lurek.thread.newPromise()  -- or your existing handle
local value = promise:getError()
print("Promise:getError ->", value)

-- ── Channel methods ──

--@api-stub: Channel:type
-- Returns the type of the object.
-- See the module spec for detailed semantics.
local channel = lurek.thread.newChannel()
channel:type()
print("Channel:type done")

--@api-stub: Channel:typeOf
-- Checks if the object is of the specified type.
-- See the module spec for detailed semantics.
local channel = lurek.thread.newChannel()
channel:typeOf("main")
print("Channel:typeOf done")

--@api-stub: Channel:push
-- Pushes a value to the channel.
-- Side-effecting; safe to call any time after init.
local channel = lurek.thread.newChannel()
channel:push(value)
print("Channel:push done")

--@api-stub: Channel:pop
-- Retrieves and removes a value from the channel.
-- Pair with the matching constructor to free resources.
local channel = lurek.thread.newChannel()
channel:pop()
-- channel is now released
print("ok")

--@api-stub: Channel:peek
-- Retrieves the value from the channel without removing it.
-- Cheap to call; safe inside callbacks.
local channel = lurek.thread.newChannel()  -- or your existing handle
local value = channel:peek()
print("Channel:peek ->", value)

--@api-stub: Channel:demand
-- Blocks until a value is available or the timeout expires, then removes and returns it.
-- See the module spec for detailed semantics.
local channel = lurek.thread.newChannel()
channel:demand(timeout)
print("Channel:demand done")

--@api-stub: Channel:getCount
-- Returns the number of items in the channel.
-- Cheap to call; safe inside callbacks.
local channel = lurek.thread.newChannel()  -- or your existing handle
local value = channel:getCount()
print("Channel:getCount ->", value)

--@api-stub: Channel:clear
-- Clears all items from the channel.
-- Pair with the matching constructor to free resources.
local channel = lurek.thread.newChannel()
channel:clear()
-- channel is now released
print("ok")

--@api-stub: Channel:supply
-- Blocks until the channel has space, then adds the value.
-- See the module spec for detailed semantics.
local channel = lurek.thread.newChannel()
channel:supply(value)
print("Channel:supply done")

--@api-stub: Channel:pushTable
-- Serializes a Lua table and pushes it to the channel.
-- Side-effecting; safe to call any time after init.
local channel = lurek.thread.newChannel()
channel:pushTable(value)
print("Channel:pushTable done")

--@api-stub: Channel:popTable
-- Pops a value from the channel expecting a table.
-- Pair with the matching constructor to free resources.
local channel = lurek.thread.newChannel()
channel:popTable()
-- channel is now released
print("ok")

--@api-stub: Channel:pushBytes
-- Pushes raw binary data (a Lua string treated as a byte array) to the channel.
-- Side-effecting; safe to call any time after init.
local channel = lurek.thread.newChannel()
channel:pushBytes({ x = 0, y = 0 })
print("Channel:pushBytes done")

--@api-stub: Channel:popBytes
-- Pops a bytes value from the channel and returns it as a Lua string.
-- Pair with the matching constructor to free resources.
local channel = lurek.thread.newChannel()
channel:popBytes()
-- channel is now released
print("ok")

