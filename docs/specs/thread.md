# thread

## TL;DR

- The `thread` module is an advanced Core Runtime tier component that introduces background threading and parallel execution to Lurek2D.

## General Info

- Module group: `Core Runtime`
- Source path: `src/thread/`
- Lua API path(s): `src/lua_api/thread_api.rs`
- Primary Lua namespace: `lurek.thread`
- Rust test path(s): tests/rust/unit/thread_tests.rs, plus inline unit coverage in src/thread/channel.rs, src/thread/promise.rs, src/thread/pool.rs, src/thread/worker.rs
- Lua test path(s): tests/lua/unit/test_thread.lua, tests/lua/stress/test_thread_stress.lua, tests/lua/integration/test_thread_data.lua

## Summary

Adhering to the engine's strict architectural constraints (specifically B-04), it ensures that Lua VMs do not share state. Instead, it provisions isolated, per-thread Lua VMs that communicate exclusively via typed Multi-Producer, Multi-Consumer (MPMC) channels. The `Channel` struct is the backbone of this system, offering thread-safe message passing with both bounded (fixed capacity) and unbounded variants. It supports various overflow policies (block, drop-oldest, drop-newest, error) and handles transparent, recursive serialization between Lua values and Rust's `ChannelValue` enum (supporting nil, booleans, numbers, strings, nested tables, and raw bytes).

To facilitate concurrent workloads, the module provides a `ThreadPool`. This fixed-size pool manages a set of persistent worker threads, each running its own restricted Lua VM. These workers process tasks from a shared input channel and push results to an output channel. The worker VMs are deliberately sandboxed: they are denied access to window, rendering, and input APIs, and are injected only with safe, restricted capabilities like `lurek.thread.getChannel` and path-traversed-guarded `fs.read`. This design ensures that background tasks—such as pathfinding, procedural generation, or heavy data processing—cannot compromise the main thread's stability or access unauthorized host files.

For simpler, one-off asynchronous tasks, the module offers the `Promise` pattern. A `Promise` spawns a single worker thread to execute a piece of Lua code and safely collects the solitary result via an internal channel, allowing the main thread to poll for completion using `isDone` and `result` methods. Recently enhanced with composable promise chaining, bounded channel backpressure, and deadline-based blocking (`demand`), the `thread` module provides a comprehensive suite of concurrency primitives. Fully exposed via the `lurek.thread.*` API, it empowers developers to build responsive, multi-threaded Lua games without the pitfalls of shared mutable state.

## Files

### channel.rs

- Thread-safe MPMC channel for passing typed values between Lua VMs.
- Bounded and unbounded variants with configurable overflow policy.
- Blocking `push`/`demand` and non-blocking `try_push`/`pop`/`peek` operations.
- Recursive Lua-to-ChannelValue and ChannelValue-to-Lua conversion (nil, bool, number, string, table, bytes).
- Named channels for diagnostics; monotonic push-count IDs for tracing.

### mod.rs

- Cross-thread messaging via typed MPMC channels for Lua VM isolation.
- Fixed-size thread pool for CPU-bound background tasks.
- Promise containers for single-value async results.
- Worker harness owning secondary Lua VMs for parallel script execution.

### pool.rs

- Fixed-size worker pool backed by LuaThread instances sharing input/output channels.
- Submit work items, collect results non-blocking, and join with optional timeout.
- Workers auto-register `__pool_input`/`__pool_output` named channels for Lua-side access.

### promise.rs

- One-shot async computation that spawns a LuaThread and collects a single result.
- Lifecycle tracking via PromiseState (Pending, Done, Error).
- Result delivery through an internal named channel polled by the caller.

### worker.rs

- Worker VM lifecycle: spawn an OS thread with an isolated Lua VM, track Pending/Running/Completed/Error states.
- Restricted API surface: inject only `lurek.thread.getChannel`, `lurek.fs.read`, and `arg` into worker VMs.
- Channel-based communication: workers receive a shared channel registry for typed cross-VM messaging.
- Blocking and timeout joins: wait indefinitely or poll with a deadline for worker completion.
- Path-traversal guard: `fs.read` in worker VMs rejects `..` segments to prevent sandbox escape.

## Lua API Ref

- Binding: `src/lua_api/thread_api.rs`
- Namespace: `lurek.thread`

### Functions

- `lurek.thread.async`: Runs a Lua code string or dumped function asynchronously on a new worker thread, returning a promise for the result.
- `lurek.thread.getChannel`: Returns a named shared channel, creating it on first access. Repeated calls with the same name return the same channel.
- `lurek.thread.getWorkerCapabilities`: Returns a list of capability names available inside worker VMs (e.g. which `lurek.*` modules are accessible).
- `lurek.thread.newBoundedChannel`: Creates a new bounded channel with a fixed capacity, blocking pushes when full.
- `lurek.thread.newChannel`: Creates a new unbounded channel for sending typed values between threads.
- `lurek.thread.newPool`: Creates a fixed-size thread pool where each worker runs the same Lua code and consumes items from a shared input channel.
- `lurek.thread.newThread`: Creates a new worker thread that will execute the given Lua code string when started.

### Enums

- No documented module-level enums/constants.

### Types


#### LChannel Type


##### Fields

- No documented fields.

##### Methods

- `LChannel:clear`: Removes all pending values from the channel.
- `LChannel:demand`: Blocks until a value is available on the channel or the optional timeout expires.
- `LChannel:getCapacity`: Returns the maximum capacity of a bounded channel, or `nil` for unbounded channels.
- `LChannel:getCount`: Returns the number of values currently queued in the channel.
- `LChannel:isBounded`: Checks whether this channel has a fixed capacity limit.
- `LChannel:peek`: Returns the next value from the channel without removing it.
- `LChannel:pop`: Removes and returns the next value from the channel without blocking.
- `LChannel:popBytes`: Pops the next value from the channel only if it is a byte blob, discarding non-bytes values.
- `LChannel:popTable`: Pops the next value from the channel only if it is a table, discarding non-table values.
- `LChannel:push`: Pushes a value onto the channel. Blocks on bounded channels if the channel is full.
- `LChannel:pushBytes`: Pushes raw binary data onto the channel as a byte blob.
- `LChannel:pushTable`: Pushes a table value onto the channel, raising an error if the value is not a table.
- `LChannel:supply`: Pushes a value and blocks until a consumer pops it (synchronous handoff).
- `LChannel:tryPush`: Attempts to push a value onto a bounded channel without blocking.
- `LChannel:type`: Returns the type name of this object.
- `LChannel:typeOf`: Checks whether this object matches the given type name.


#### LPromise Type


##### Fields

- No documented fields.

##### Methods

- `LPromise:chain`: Creates a new promise that runs the given code with the parent promise's result as its first argument.
- `LPromise:getError`: Returns the error message from the promise, if it terminated with an error.
- `LPromise:isDone`: Checks whether the asynchronous computation has completed.
- `LPromise:result`: Returns the result value of the completed promise.
- `LPromise:type`: Returns the type name of this object.
- `LPromise:typeOf`: Checks whether this object matches the given type name.


#### LThreadHandle Type


##### Fields

- No documented fields.

##### Methods

- `LThreadHandle:getError`: Returns the error message from the worker thread, if it terminated with an error.
- `LThreadHandle:isRunning`: Checks whether the worker thread is still executing.
- `LThreadHandle:start`: Launches the worker thread, executing the Lua code string supplied at creation time.
- `LThreadHandle:wait`: Blocks the calling thread until the worker thread finishes execution.


#### LThreadPool Type


##### Fields

- No documented fields.

##### Methods

- `LThreadPool:collect`: Pops and returns the next result from the pool's output channel.
- `LThreadPool:getInputChannel`: Returns the pool's shared input channel that feeds work items to worker threads.
- `LThreadPool:getOutputChannel`: Returns the pool's shared output channel where worker threads place their results.
- `LThreadPool:join`: Blocks until all workers finish or the optional timeout elapses.
- `LThreadPool:size`: Returns the number of worker threads in the pool.
- `LThreadPool:submit`: Pushes a value into the pool's input channel for processing by a worker thread.
- `LThreadPool:type`: Returns the type name of this object.
- `LThreadPool:typeOf`: Checks whether this object matches the given type name.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
