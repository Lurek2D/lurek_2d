# thread

## General Info

- Module group: `Core Runtime`
- Source path: `src/thread/`
- Lua API path(s): `src/lua_api/thread_api.rs`
- Primary Lua namespace: `lurek.thread`
- Rust test path(s): tests/rust/unit/thread_tests.rs, plus inline unit coverage in src/thread/channel.rs, src/thread/promise.rs, src/thread/pool.rs, src/thread/worker.rs
- Lua test path(s): tests/lua/unit/test_thread.lua, tests/lua/stress/test_thread_stress.lua, tests/lua/integration/test_thread_data.lua

## Summary

## Summary

The `thread` module provides Lurek2D's background threading infrastructure, enabling CPU-intensive work to execute off the main Lua VM thread without blocking the game loop. Because LuaJIT VMs cannot share state across OS threads (binding constraint B-04), each background thread runs a fully isolated VM with its own script load, its own globals, and its own GC heap. All cross-thread data transfer is serialised through typed channel values.

**Channel.** `Channel` is the primary cross-thread communication primitive: an MPMC queue backed by `Mutex<VecDeque<ChannelValue>>` with a `Condvar` for blocking waits. `ChannelValue` is the transfer-safe enum: `Nil`, `Bool`, `Number(f64)`, `String`, serialised `Table` (JSON round-trip), and raw `Bytes`. Lua UserData and closures cannot cross thread boundaries. Operations: `push(v)` (non-blocking, returns a monotonic push ID), `pop()` (non-blocking, `None` if empty), `demand(timeout_ms)` (blocks until a value arrives or the timeout elapses), `supply(v)` (push only if the queue is currently empty), `peek()` (read front without consuming), `clear()` (drain the queue), `get_count()` → current length. Channels can be created unnamed or named; `Channel::named(name)` binds the channel pair to a global string registry so any worker can retrieve it by name, enabling pub-sub patterns across multiple workers.

**Worker.** `LuaThread` wraps an OS thread running an isolated LuaJIT VM. It loads a specified Lua script file, then runs a task loop: pull a `ChannelValue` from the input channel, invoke the script's registered task function, push the result to the output channel. `ThreadState` enum tracks the lifecycle: `Idle`, `Running`, `Paused`, `Error(String)`, `Terminated`. Workers can be paused with `pause()` and resumed with `resume()`. Termination is graceful: the thread drains remaining input, runs cleanup hooks, then exits. Uncaught errors are captured in an error slot; the main thread retrieves them with `worker:getError()`. Worker scripts should not call `lurek.render` or `lurek.input`; safe modules in worker VMs are `lurek.math`, `lurek.data`, `lurek.serial`, `lurek.log`.

**Pool.** `ThreadPool` manages a fixed-size group of workers all executing the same task script. A shared input channel distributes work items; a shared output channel collects results. `submit(v)` pushes a task item; `collect()` drains completed results. Pool size is set at construction and cannot change at runtime. Useful for parallel data transforms, procedural generation passes, or background save serialisation.

**Promise.** `Promise` provides a single-result future for one-shot background computation. `PromiseState` enum: `Pending`, `Resolved(ChannelValue)`, `Rejected(String)`. A promise wraps a single background Lua VM invocation. The main thread calls `promise:poll()` to check state without blocking, or `promise:await(timeout_ms)` to block until resolution. On rejection the error string propagates to the Lua callback or surfaces via `getError()`.

**Semaphore.** `ThreadSemaphore` provides a counting semaphore for rate-limiting concurrent workers. `newSemaphore(n)` creates an instance with `n` permits. `acquire()` blocks until a permit is available; `release()` returns one permit. Useful for capping concurrent database queries, file reads, or network requests to a maximum parallelism.

**Barrier.** `ThreadBarrier` synchronises a group of threads at a rendezvous point before any may proceed. `newBarrier(count)` initialises for `count` participants. Each thread calls `barrier:wait()`, which blocks until all `count` threads have reached the barrier. Intended for multi-worker phases where all workers must finish a preparation step before any start the next phase.

**Lua surface.** `lurek.thread.new(script_path, opts)` → LuaThread; `thread:start()`, `thread:pause()`, `thread:resume()`, `thread:terminate()`, `thread:getState()` → string, `thread:getError()` → string or nil. Channel: `lurek.thread.newChannel()` → channel, `lurek.thread.getChannel(name)` → channel; `channel:push(v)`, `channel:pop()` → value or nil, `channel:demand(ms)` → value or nil, `channel:supply(v)`, `channel:peek()` → value or nil, `channel:clear()`, `channel:count()` → int. Pool: `lurek.thread.newPool(n, script_path)` → pool; `pool:submit(v)`, `pool:collect()` → table of results, `pool:shutdown()`. Promise: `lurek.thread.newPromise(fn_name, arg)` → promise; `promise:poll()` → state, `promise:await(ms)` → value or nil. Semaphore: `lurek.thread.newSemaphore(n)` → semaphore; `semaphore:acquire()`, `semaphore:release()`. Barrier: `lurek.thread.newBarrier(count)` → barrier; `barrier:wait()`.

**Scope boundary.** Core Runtime tier. Depends on `runtime`. Lua bridge in `src/lua_api/thread_api.rs`.

## Files

- `channel.rs`: `ChannelValue` enum, `Channel` MPMC queue, `LuaChannel` UserData, conversion functions
- `mod.rs`: Module root — re-exports `channel` and `worker` submodules
- `pool.rs`: Thread pool of reusable worker Lua VMs.
- `promise.rs`: Single-result future for one-shot background computation.
- `worker.rs`: `ThreadState` enum, `LuaThread` struct, worker VM registration

## Types

- `ChannelValue` (`enum`, `channel.rs`): Serializable values that can be sent between threads.
- `Channel` (`struct`, `channel.rs`): Thread-safe MPMC channel for Lua inter-thread communication.
- `LuaChannel` (`struct`, `channel.rs`): Lua UserData wrapper for a thread-safe channel.
- `ThreadPool` (`struct`, `pool.rs`): A pool of N persistent worker threads that accept tasks from a shared input channel and send results to a shared output channel.
- `PromiseState` (`enum`, `promise.rs`): Execution state of a [`Promise`].
- `Promise` (`struct`, `promise.rs`): A one-shot async computation that produces a single `ChannelValue` result.
- `ThreadState` (`enum`, `worker.rs`): Execution state of a background Lua thread.
- `LuaThread` (`struct`, `worker.rs`): A background Lua thread running its own VM.

## Functions

- `Channel::new` (`channel.rs`): Create an unnamed channel.
- `Channel::named` (`channel.rs`): Creates a named bidirectional channel pair, binding the channel name in the global registry.
- `Channel::push` (`channel.rs`): Push a value to the back of the channel.
- `Channel::pop` (`channel.rs`): Pop a value from the front of the channel (non-blocking).
- `Channel::peek` (`channel.rs`): Peek at the front value without removing it.
- `Channel::demand` (`channel.rs`): Wait for a value, blocking the calling thread.
- `Channel::get_count` (`channel.rs`): Get the number of values currently in the channel.
- `Channel::clear` (`channel.rs`): Remove all values from the channel.
- `Channel::supply` (`channel.rs`): Push a value only if the channel is currently empty.
- `Channel::name` (`channel.rs`): Get the channel name, if it is a named channel.
- `lua_to_channel_value` (`channel.rs`): Convert a Lua value into a `ChannelValue` for cross-thread transfer.
- `channel_value_to_lua` (`channel.rs`): Convert a `ChannelValue` back into a Lua value.
- `ThreadPool::new` (`pool.rs`): Create a pool of `size` workers, all executing `code`.
- `ThreadPool::submit` (`pool.rs`): Submit a value to the pool input channel.
- `ThreadPool::collect` (`pool.rs`): Collect a result from the pool output channel (non-blocking).
- `ThreadPool::join` (`pool.rs`): Block until all workers have finished execution.
- `ThreadPool::size` (`pool.rs`): Returns the number of workers in this pool.
- `Promise::new` (`promise.rs`): Create and immediately start a promise executing `code`.
- `Promise::is_done` (`promise.rs`): Check if the promise has a result ready, without blocking.
- `Promise::result` (`promise.rs`): Retrieve the result value if ready.
- `Promise::get_error` (`promise.rs`): Returns the error string if the worker thread failed, otherwise `None`.
- `LuaThread::new` (`worker.rs`): Create a new thread that will execute the given Lua code.
- `LuaThread::start` (`worker.rs`): Start the thread, spawning a new OS thread with its own Lua VM.
- `LuaThread::wait` (`worker.rs`): Block until the thread finishes execution.
- `LuaThread::is_running` (`worker.rs`): Check whether the thread is currently running.
- `LuaThread::get_error` (`worker.rs`): Get the error message if the thread terminated with an error.

## Lua API Reference

- Binding path(s): `src/lua_api/thread_api.rs`
- Namespace: `lurek.thread`

### Module Functions
- `lurek.thread.newThread`: Creates a new background thread from a Lua code string.
- `lurek.thread.newChannel`: Creates an unnamed thread-safe channel for inter-thread communication.
- `lurek.thread.getChannel`: Gets or creates a named global channel shared across threads.
- `lurek.thread.newPool`: Creates a thread pool of N workers all running the same Lua code.
- `lurek.thread.async`: Starts a one-shot background computation and returns a Promise.

### `Channel` Methods
- `Channel:type`: Returns the type of the object.
- `Channel:typeOf`: Checks if the object is of the specified type.
- `Channel:push`: Pushes a value to the channel.
- `Channel:pop`: Retrieves and removes a value from the channel.
- `Channel:peek`: Retrieves the value from the channel without removing it.
- `Channel:demand`: Blocks until a value is available or the timeout expires, then removes and returns it.
- `Channel:getCount`: Returns the number of items in the channel.
- `Channel:clear`: Clears all items from the channel.
- `Channel:supply`: Blocks until the channel has space, then adds the value.
- `Channel:pushTable`: Serializes a Lua table and pushes it to the channel.
- `Channel:popTable`: Pops a value from the channel expecting a table.
- `Channel:pushBytes`: Pushes raw binary data (a Lua string treated as a byte array) to the channel.
- `Channel:popBytes`: Pops a bytes value from the channel and returns it as a Lua string.

### `Promise` Methods
- `Promise:type`: Returns the type name of this object.
- `Promise:typeOf`: Returns whether this object is of the given type.
- `Promise:isDone`: Returns true if the promise has a result or has errored (non-blocking).
- `Promise:result`: Pops and returns the promise result, or nil if not yet ready.
- `Promise:getError`: Returns the worker error string if the promise failed, otherwise nil.

### `ThreadHandle` Methods
- `ThreadHandle:type`: Returns the type name of this object.
- `ThreadHandle:typeOf`: Returns whether this object is of the given type.
- `ThreadHandle:start`: Launches the background thread, passing optional arguments via varargs.
- `ThreadHandle:wait`: Blocks the calling thread until the background thread finishes.
- `ThreadHandle:isRunning`: Returns whether the thread is currently executing.
- `ThreadHandle:getError`: Returns the error message if the thread failed, or nil.

### `ThreadPool` Methods
- `ThreadPool:type`: Returns the type name of this object.
- `ThreadPool:typeOf`: Returns whether this object is of the given type.
- `ThreadPool:submit`: Submits a value to the pool's input channel for processing by a worker.
- `ThreadPool:collect`: Retrieves the next result from the pool's output channel (non-blocking).
- `ThreadPool:size`: Returns the number of workers in this pool.
- `ThreadPool:join`: Blocks until all workers in the pool have finished execution.
- `ThreadPool:getInputChannel`: Returns the shared input Channel (main â†’ workers).
- `ThreadPool:getOutputChannel`: Returns the shared output Channel (workers â†’ main).

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/thread/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
