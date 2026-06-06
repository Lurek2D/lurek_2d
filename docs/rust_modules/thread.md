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

This module delivers a safe and robust concurrency framework for executing asynchronous Lua jobs outside the main frame loop. Because separate virtual machines do not share state, the runtime guarantees thread safety by spinning up isolated workers on dedicated operating system threads. Background tasks run within a restricted environment, which prevents hazardous cross-thread memory sharing while keeping gameplay operations fluid.

To facilitate communication, the module utilizes typed channels that safely copy scalars, nested tables, and binary blobs between active threads. Callers can choose bounded or unbounded queues to manage backpressure, or employ one-shot promises to monitor deferred computations. Furthermore, a thread-pool system coordinates multiple workers through shared pipelines, enabling heavy-duty background tasks.

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
