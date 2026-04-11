# thread

## General Info

- Module group: `Core Runtime`
- Source path: `src/thread/`
- Lua API path(s): `src/lua_api/thread_api.rs`
- Primary Lua namespace: `lurek.thread`
- Rust test path(s): tests/rust/unit/thread_tests.rs
- Lua test path(s): tests/lua/unit/test_thread.lua, tests/lua/stress/test_thread_stress.lua, tests/lua/integration/test_thread_data.lua

## Summary

The thread module provides Lurek2D's explicit concurrency boundary. It lets scripts spawn background Lua workers and exchange simple values through thread-safe channels without sharing a Lua VM or the engine's central runtime state.

This module exists to enforce the repository's concurrency rule: Rust threads may run in parallel, but Lua state must stay isolated per VM. The module therefore centers on two primitives only: `Channel`, which moves primitive values across threads, and `LuaThread`, which owns an isolated worker VM with a tightly restricted API surface.

It intentionally does not own async runtimes, shared-memory game objects, or cross-thread access to rendering, input, physics, or audio state. If a design needs full engine APIs inside a worker, it is pushing against a deliberate boundary. The Lua wrapper in `src/lua_api/thread_api.rs` is also part of the safety story because it decides what worker threads can see and how named channels are shared.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Core Runtime responsibility boundary defined in the architecture docs.

## Files

- `channel.rs`: `ChannelValue` enum, `Channel` MPMC queue, `LuaChannel` UserData, conversion functions
- `mod.rs`: Module root — re-exports `channel` and `worker` submodules
- `worker.rs`: `ThreadState` enum, `LuaThread` struct, worker VM registration

## Types

- `ChannelValue` (`enum`, `channel.rs`): Serializable values that can be sent between threads.
- `Channel` (`struct`, `channel.rs`): Thread-safe MPMC channel for Lua inter-thread communication.
- `LuaChannel` (`struct`, `channel.rs`): Lua UserData wrapper for a thread-safe channel.
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

### `Channel` Methods
- `Channel:type`: Lua-facing function documented in the binding source.
- `Channel:typeOf`: Lua-facing function documented in the binding source.
- `Channel:push`: Lua-facing function documented in the binding source.
- `Channel:pop`: Lua-facing function documented in the binding source.
- `Channel:peek`: Lua-facing function documented in the binding source.
- `Channel:demand`: Lua-facing function documented in the binding source.
- `Channel:getCount`: Lua-facing function documented in the binding source.
- `Channel:clear`: Lua-facing function documented in the binding source.
- `Channel:supply`: Lua-facing function documented in the binding source.

### `ThreadHandle` Methods
- `ThreadHandle:type`: Returns the type name of this object.
- `ThreadHandle:typeOf`: Returns whether this object is of the given type.
- `ThreadHandle:start`: Launches the background thread, passing optional arguments via varargs.
- `ThreadHandle:wait`: Blocks the calling thread until the background thread finishes.
- `ThreadHandle:isRunning`: Returns whether the thread is currently executing.
- `ThreadHandle:getError`: Returns the error message if the thread failed, or nil.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/thread/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
