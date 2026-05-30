# thread

## TL;DR

- The `thread` module is an advanced Core Runtime tier component that introduces background threading and parallel execution to Lurek2D.

## General Info

- Module group: `Core Runtime`
- Source path: `src/thread/`
- Binding: `src/lua_api/thread_api.rs`
- Namespace: `lurek.thread`
- Lua API surface: `7` functions, `4` types, `34` methods
- Rust test path(s): tests/rust/unit/thread_tests.rs, plus inline unit coverage in src/thread/channel.rs, src/thread/promise.rs, src/thread/pool.rs, src/thread/worker.rs
- Lua test path(s): tests/lua/unit/test_thread.lua, tests/lua/stress/test_thread_stress.lua, tests/lua/integration/test_thread_data.lua

## Summary

Adhering to the engine's strict architectural constraints (specifically B-04), it ensures that Lua VMs do not share state. Instead, it provisions isolated, per-thread Lua VMs that communicate exclusively via typed Multi-Producer, Multi-Consumer (MPMC) channels. The `Channel` struct is the backbone of this system, offering thread-safe message passing with both bounded (fixed capacity) and unbounded variants. It supports various overflow policies (block, drop-oldest, drop-newest, error) and handles transparent, recursive serialization between Lua values and Rust's `ChannelValue` enum (supporting nil, booleans, numbers, strings, nested tables, and raw bytes).

To facilitate concurrent workloads, the module provides a `ThreadPool`. This fixed-size pool manages a set of persistent worker threads, each running its own restricted Lua VM. These workers process tasks from a shared input channel and push results to an output channel. The worker VMs are deliberately sandboxed: they are denied access to window, rendering, and input APIs, and are injected only with safe, restricted capabilities like `lurek.thread.getChannel` and path-traversed-guarded `fs.read`. This design ensures that background tasks—such as pathfinding, procedural generation, or heavy data processing—cannot compromise the main thread's stability or access unauthorized host files.

For simpler, one-off asynchronous tasks, the module offers the `Promise` pattern. A `Promise` spawns a single worker thread to execute a piece of Lua code and safely collects the solitary result via an internal channel, allowing the main thread to poll for completion using `isDone` and `result` methods. Recently enhanced with composable promise chaining, bounded channel backpressure, and deadline-based blocking (`demand`), the `thread` module provides a comprehensive suite of concurrency primitives. Fully exposed via the `lurek.thread.*` API, it empowers developers to build responsive, multi-threaded Lua games without the pitfalls of shared mutable state.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### channel.rs

- This file provides the thread-safe message bus that moves typed payloads between isolated Lua VMs.
- It defines a stable transport value model that preserves scalar values, nested tables, and binary blobs.
- It supports bounded and unbounded queues so gameplay code can choose backpressure or open throughput.
- It offers blocking and non-blocking push and pull flows for deterministic runtime synchronization.
- It bridges Rust and Lua value domains with explicit conversion rules that avoid hidden sharing.
- It keeps channel identity and message sequencing visible so concurrent data flow stays debuggable.

### mod.rs

- This module delivers the high-level concurrency layer for isolated Lua workers in the runtime.
- It combines channels, worker execution, pools, and one-shot promises into one coherent flow model.
- It keeps cross-thread scripting safe by enforcing message passing instead of shared VM state.

### pool.rs

- This file provides a fixed worker pool that executes Lua jobs in parallel with stable throughput.
- It binds shared input and output channels so tasks and results travel on a predictable pipeline.
- It exposes a practical lifecycle of submit, collect, and join for frame-safe orchestration.
- It keeps named channel wiring consistent across engine and script boundaries during pooled execution.

### promise.rs

- This file provides a one-shot async result container for Lua work running off the main thread.
- It models pending, success, and error states so callers can poll progress without blocking frames.
- It delivers the resolved value through a dedicated channel for safe cross-thread handoff semantics.
- It makes deferred gameplay logic simple by letting results be consumed cleanly in later updates.

### worker.rs

- This file provides the worker lifecycle that boots an isolated Lua VM on its own OS thread.
- It tracks execution transitions from pending to running to completed or failed outcomes.
- It injects a restricted capability surface so background scripts run inside controlled boundaries.
- It connects workers to shared named channels so inter-VM communication remains explicit and typed.
- It offers blocking and timeout joins to synchronize background completion with frame progression.

## Lua API Ref

### Functions

- `lurek.thread.async`: Runs a Lua code string or dumped function asynchronously on a new worker thread, returning a promise for the result.
- `lurek.thread.getChannel`: Returns a named shared channel, creating it on first access. Repeated calls with the same name return the same channel.
- `lurek.thread.getWorkerCapabilities`: Returns a list of capability names available inside worker VMs (e.g. which `lurek.*` modules are accessible).
- `lurek.thread.newBoundedChannel`: Creates a new bounded channel with a fixed capacity, blocking pushes when full.
- `lurek.thread.newChannel`: Creates a new unbounded channel for sending typed values between threads.
- `lurek.thread.newPool`: Creates a fixed-size thread pool where each worker runs the same Lua code and consumes items from a shared input channel.
- `lurek.thread.newThread`: Creates a new worker thread that will execute the given Lua code string when started.

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

- Lua-visible handle representing an asynchronous computation that will produce a single result value.

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

- Lua-visible handle wrapping a single background worker VM that executes a Lua code string on a dedicated OS thread.

##### Fields

- No documented fields.

##### Methods

- `LThreadHandle:getError`: Returns the error message from the worker thread, if it terminated with an error.
- `LThreadHandle:isRunning`: Checks whether the worker thread is still executing.
- `LThreadHandle:start`: Launches the worker thread, executing the Lua code string supplied at creation time.
- `LThreadHandle:wait`: Blocks the calling thread until the worker thread finishes execution.

#### LThreadPool Type

- Lua-visible handle for a fixed-size pool of worker threads that process items from a shared input channel.

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
