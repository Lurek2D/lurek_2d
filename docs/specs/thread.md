# thread

## TL;DR

- Parallel Lua workers via isolated threads, safe channels, and promises.

## General Info

- Module group: `Core Runtime`
- Source path: `src/thread/`
- Binding: `src/lua_api/thread_api.rs`
- Namespace: `lurek.thread`
- Lua API surface: `7` functions, `4` types, `34` methods
- Rust test path(s): tests/rust/unit/thread_tests.rs, plus inline unit coverage in src/thread/channel.rs, src/thread/promise.rs, src/thread/pool.rs, src/thread/worker.rs
- Lua test path(s): tests/lua/unit/test_thread.lua, tests/lua/stress/test_thread_stress.lua, tests/lua/integration/test_thread_data.lua

## Summary

- The `thread` module is the isolated-concurrency surface for projects that want background Lua work without violating the engine's VM and runtime-safety rules.
- Channels, worker threads, pools, and promises let asynchronous work move messages and results between isolated execution contexts instead of sharing unsafe state directly.
- That matters because concurrency here is not just thread creation; it is about controlling what can cross between workers and how results return safely.
- The module is useful for expensive background tasks, staged jobs, and workflows where script-facing logic should continue while separate workers finish their part of the work.
- Promise-style completion is central because finished work still has to rejoin the foreground safely.
- It keeps worker isolation visible to scripts while still making background jobs practical and safe.
- Read it as the engine's sanctioned script-concurrency model.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### channel.rs

- `src/thread/channel.rs` owns the thread-safe message channel used to move portable values between isolated Lua VMs.
- It defines `ChannelValue`, `OverflowPolicy`, `Channel`, and `LuaChannel`, keeping transport rules under one owner.
- Bounded and unbounded queue creation, blocking push and demand, non-blocking operations, and queue inspection live here.
- Rust-Lua conversion helpers also live here, including recursive table transport and byte-string handling for messages.
- Read this file when backpressure, wake-up behavior, transferable value rules, or channel naming semantics must change.
- Higher layers should treat it as the cross-thread transport boundary, while worker lifecycle logic stays in `worker.rs`.

### mod.rs

- `src/thread/mod.rs` is the module index that exposes channels, workers, pools, and promises for Lua concurrency.
- It groups message transport and worker orchestration so background Lua execution uses one thread surface.
- No live thread state lives here; this file only declares child modules and documents the concurrency split by concern.
- Read this index when wiring background execution, because it shows where message passing ends and worker control begins.
- Changes here reshape the thread boundary, since module visibility defines which concurrency tools other systems use.
- This module keeps channels, worker lifecycles, pooling, and one-shot results separated for easier ownership tracing.

### pool.rs

- `src/thread/pool.rs` owns the fixed-size worker pool that shares input and output channels across multiple Lua threads.
- `ThreadPool` wires named pool channels, spawns workers from one code body, and exposes submit, collect, and join flows.
- This file keeps pooled orchestration separate from raw worker implementation, which makes multi-worker policy explicit.
- Open it when pool sizing, shared channel wiring, or join timeout behavior for batch Lua work needs to change.

### promise.rs

- `src/thread/promise.rs` owns the one-shot async result wrapper built around a worker thread and result channel.
- It defines `PromiseState` and `Promise`, keeping pending, success, and error tracking under one lightweight owner.
- `new`, `is_done`, `result`, and `get_error` live here so callers can poll background Lua work without blocking frames.
- Read this file when promise completion rules, result handoff semantics, or worker error propagation must change.

### worker.rs

- `src/thread/worker.rs` owns the isolated Lua worker lifecycle that runs one script on its own OS thread.
- It defines `ThreadState` and `LuaThread`, keeping startup, completion, error tracking, and join logic under one owner.
- Worker capability registration also lives here, including channel lookup, fs.read access, `arg`, and package path setup.
- This file is the policy boundary for what background Lua code may access and how worker completion is observed.
- Read it when worker sandbox rules, spawn lifecycle, timeout waiting, or exposed thread capabilities need to change.



## Lua API Ref

### Functions

- `lurek.thread.async(codeOrFunc, ...) -> LPromise`: Runs a Lua code string or dumped function asynchronously on a new worker thread, returning a promise for the result.
- `lurek.thread.getChannel(name) -> LChannel`: Returns a named shared channel, creating it on first access. Repeated calls with the same name return the same channel.
- `lurek.thread.getWorkerCapabilities() -> string[]`: Returns a list of capability names available inside worker VMs (e.g. which `lurek.*` modules are accessible).
- `lurek.thread.newBoundedChannel(capacity) -> LChannel`: Creates a new bounded channel with a fixed capacity, blocking pushes when full.
- `lurek.thread.newChannel() -> LChannel`: Creates a new unbounded channel for sending typed values between threads.
- `lurek.thread.newPool(size, code) -> LThreadPool`: Creates a fixed-size thread pool where each worker runs the same Lua code and consumes items from a shared input channel.
- `lurek.thread.newThread(code) -> LThread`: Creates a new worker thread that will execute the given Lua code string when started.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LChannel Type

- Creates a new unbounded channel for sending typed values between threads.

##### Fields

- No documented fields.

##### Methods

- `LChannel:clear() -> nil`: Removes all pending values from the channel.
- `LChannel:demand(timeout?) -> table`: Blocks until a value is available on the channel or the optional timeout expires.
- `LChannel:getCapacity() -> integer`: Returns the maximum capacity of a bounded channel, or `nil` for unbounded channels.
- `LChannel:getCount() -> integer`: Returns the number of values currently queued in the channel.
- `LChannel:isBounded() -> boolean`: Checks whether this channel has a fixed capacity limit.
- `LChannel:peek() -> table`: Returns the next value from the channel without removing it.
- `LChannel:pop() -> table`: Removes and returns the next value from the channel without blocking.
- `LChannel:popBytes() -> string`: Pops the next value from the channel only if it is a byte blob, discarding non-bytes values.
- `LChannel:popTable() -> table`: Pops the next value from the channel only if it is a table, discarding non-table values.
- `LChannel:push(value) -> integer`: Pushes a value onto the channel. Blocks on bounded channels if the channel is full.
- `LChannel:pushBytes(data) -> integer`: Pushes raw binary data onto the channel as a byte blob.
- `LChannel:pushTable(value) -> integer`: Pushes a table value onto the channel, raising an error if the value is not a table.
- `LChannel:supply(value) -> boolean`: Pushes a value and blocks until a consumer pops it (synchronous handoff).
- `LChannel:tryPush(value) -> boolean`: Attempts to push a value onto a bounded channel without blocking.
- `LChannel:type() -> string`: Returns the type name of this object.
- `LChannel:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LPromise Type

- Lua-visible handle representing an asynchronous computation that will produce a single result value.

##### Fields

- No documented fields.

##### Methods

- `LPromise:chain(code, ...) -> LPromise`: Creates a new promise that runs the given code with the parent promise's result as its first argument.
- `LPromise:getError() -> string`: Returns the error message from the promise, if it terminated with an error.
- `LPromise:isDone() -> boolean`: Checks whether the asynchronous computation has completed.
- `LPromise:result() -> table`: Returns the result value of the completed promise.
- `LPromise:type() -> string`: Returns the type name of this object.
- `LPromise:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LThreadHandle Type

- Lua-visible handle wrapping a single background worker VM that executes a Lua code string on a dedicated OS thread.

##### Fields

- No documented fields.

##### Methods

- `LThreadHandle:getError() -> string`: Returns the error message from the worker thread, if it terminated with an error.
- `LThreadHandle:isRunning() -> boolean`: Checks whether the worker thread is still executing.
- `LThreadHandle:start(...) -> nil`: Launches the worker thread, executing the Lua code string supplied at creation time.
- `LThreadHandle:wait() -> nil`: Blocks the calling thread until the worker thread finishes execution.

#### LThreadPool Type

- Lua-visible handle for a fixed-size pool of worker threads that process items from a shared input channel.

##### Fields

- No documented fields.

##### Methods

- `LThreadPool:collect() -> table`: Pops and returns the next result from the pool's output channel.
- `LThreadPool:getInputChannel() -> LChannel`: Returns the pool's shared input channel that feeds work items to worker threads.
- `LThreadPool:getOutputChannel() -> LChannel`: Returns the pool's shared output channel where worker threads place their results.
- `LThreadPool:join(timeout?) -> boolean`: Blocks until all workers finish or the optional timeout elapses.
- `LThreadPool:size() -> integer`: Returns the number of worker threads in the pool.
- `LThreadPool:submit(value) -> nil`: Pushes a value into the pool's input channel for processing by a worker thread.
- `LThreadPool:type() -> string`: Returns the type name of this object.
- `LThreadPool:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
