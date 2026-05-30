# thread

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

## Files

### [channel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/thread/channel.rs)

- This file provides the thread-safe message bus that moves typed payloads between isolated Lua VMs.
- It defines a stable transport value model that preserves scalar values, nested tables, and binary blobs.
- It supports bounded and unbounded queues so gameplay code can choose backpressure or open throughput.
- It offers blocking and non-blocking push and pull flows for deterministic runtime synchronization.
- It bridges Rust and Lua value domains with explicit conversion rules that avoid hidden sharing.
- It keeps channel identity and message sequencing visible so concurrent data flow stays debuggable.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/thread/mod.rs)

- This module delivers the high-level concurrency layer for isolated Lua workers in the runtime.
- It combines channels, worker execution, pools, and one-shot promises into one coherent flow model.
- It keeps cross-thread scripting safe by enforcing message passing instead of shared VM state.

### [pool.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/thread/pool.rs)

- This file provides a fixed worker pool that executes Lua jobs in parallel with stable throughput.
- It binds shared input and output channels so tasks and results travel on a predictable pipeline.
- It exposes a practical lifecycle of submit, collect, and join for frame-safe orchestration.
- It keeps named channel wiring consistent across engine and script boundaries during pooled execution.

### [promise.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/thread/promise.rs)

- This file provides a one-shot async result container for Lua work running off the main thread.
- It models pending, success, and error states so callers can poll progress without blocking frames.
- It delivers the resolved value through a dedicated channel for safe cross-thread handoff semantics.
- It makes deferred gameplay logic simple by letting results be consumed cleanly in later updates.

### [worker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/thread/worker.rs)

- This file provides the worker lifecycle that boots an isolated Lua VM on its own OS thread.
- It tracks execution transitions from pending to running to completed or failed outcomes.
- It injects a restricted capability surface so background scripts run inside controlled boundaries.
- It connects workers to shared named channels so inter-VM communication remains explicit and typed.
- It offers blocking and timeout joins to synchronize background completion with frame progression.
