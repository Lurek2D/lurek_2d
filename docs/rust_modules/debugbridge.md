# debugbridge

## General Info

- Module group: `Edge/Integration`
- Source path: `src/debugbridge/`
- Binding: `src/lua_api/debugbridge_api.rs`
- Namespace: `lurek.debugbridge`
- Lua API surface: `16` functions, `2` types, `0` methods
- Rust test path(s): tests/rust/unit/debugbridge_tests.rs
- Lua test path(s): tests/lua/unit/test_debugbridge.lua

## Summary

The `debugbridge` module is the runtime communication path between the engine and external debug clients. It allows tools to connect to a live process, exchange messages, and receive diagnostics without embedding tool code in gameplay systems.

Its core behavior is queue-based and thread-safe. Requests, responses, and bridge events are stored in shared buffers so runtime logic and network handling can cooperate in a controlled way.

The module also supports practical debugging workflows such as print capture, performance polling, and screenshot requests. This gives one integration point for common tool operations during development.

The boundary stays transport-focused. Gameplay inspection policies belong to other modules, while `debugbridge` is responsible for safe message flow, connection handling, and protocol consistency.

In practice, `lurek.debugbridge` improves reliability of live debugging by keeping cross-process communication explicit, predictable, and easier to observe.

## Files

### [bridge.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/debugbridge/bridge.rs)

- Implements shared state and queue structures for runtime-to-client debug bridge communication.
- Stores pending requests and responses exchanged between network server and runtime logic.
- Tracks rolling performance metrics and bounded print history for debugger-side inspection.
- Maintains session configuration and capability metadata used across active bridge connections.
- Provides broadcast event queues for fan-out delivery to all connected debug clients.
- Serves as the core synchronization layer under the debug bridge protocol subsystem.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/debugbridge/mod.rs)

- Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange.
- Groups shared bridge state and TCP server functionality under one integration surface.
- Serves as the composition entry for engine-side debugbridge capabilities.

### [server.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/debugbridge/server.rs)

- Implements the non-blocking TCP server loop for debugbridge client connectivity and dispatch.
- Accepts client sessions and parses JSON-RPC messages into runtime and built-in command handlers.
- Delivers queued responses and broadcast events across connected debugger endpoints.
- Handles handshake, protocol version checks, and nonce-based authentication workflows.
- Supports eval, ping, performance, print-history, and screenshot-oriented protocol requests.
- Serves as the network transport execution layer for the debugbridge subsystem.
- Preserves deterministic request lifecycle behavior across concurrent debugger client sessions.
