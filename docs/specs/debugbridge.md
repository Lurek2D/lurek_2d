# debugbridge

## TL;DR

- The `debugbridge` module provides a powerful TCP-based communication layer that enables external toolsâ€”such as the VS Code extension, remote inspectors, and diagnostic dashboardsâ€”to connect directly to a running Lurek2D instance.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/debugbridge/`
- Lua API path(s): `src/lua_api/debugbridge_api.rs`
- Primary Lua namespace: `lurek.debugbridge`
- Rust test path(s): tests/rust/unit/debugbridge_tests.rs
- Lua test path(s): tests/lua/unit/test_debugbridge.lua

## Summary

The `debugbridge` module provides runtime-to-tool communication primitives for debugging workflows, centered on shared bridge state and server-side JSON-RPC style message handling. Its purpose is integration: shuttle requests/responses and debug prints between engine runtime and external tooling while preserving thread-safe queue semantics.

`bridge.rs` owns shared data structures (`BridgeShared`, pending request/response buffers, print entries), and `server.rs` owns client message handling plus server-thread lifecycle. The module then re-exports these integration types/functions for runtime layers that start and drive the bridge.

This module should stay transport-focused. It is not a replacement for gameplay introspection logic; it is the conduit that carries those operations between processes.

Operationally, quality depends on predictable queue behavior, clear message contracts, and failure-safe networking boundaries so debug tooling cannot silently corrupt runtime state.

Implementation detail and boundary guarantees for debugbridge: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: bridge.rs: Define shared state and queue structures for the debug bridge protocol.; mod.rs: Expose the debug bridge subsystem for runtime-to-IDE communication.; server.rs: Run a non-blocking TCP server loop accepting debug bridge client connections.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### bridge.rs

- Define shared state and queue structures for the debug bridge protocol.
- Hold pending request and response buffers for runtime-client communication.
- Track rolling frame-time performance metrics with bounded sample windows.
- Maintain bounded print history captured from runtime Lua output.
- Manage session configuration: port, protocol version, capabilities, and nonce.
- Provide broadcast queue for event delivery to all connected clients.

### mod.rs

- Expose the debug bridge subsystem for runtime-to-IDE communication.
- Provide shared state queues, TCP server loop, and JSON-RPC dispatch.
- Re-export integration types used by the engine runtime layer.

### server.rs

- Run a non-blocking TCP server loop accepting debug bridge client connections.
- Parse JSON-RPC messages and dispatch to built-in handlers or runtime queue.
- Deliver pending responses and broadcast events to connected clients.
- Handle protocol handshake, nonce authentication, and version negotiation.
- Support ping, hello, eval, performance, print history, and screenshot requests.

## Lua API Ref

- Binding: `src/lua_api/debugbridge_api.rs`
- Namespace: `lurek.debugbridge`

### Functions

- `lurek.debugbridge.broadcast`: Queues a JSON string payload broadcast for debug bridge clients.
- `lurek.debugbridge.capturePrint`: Captures a print message and broadcasts it to debug bridge clients.
- `lurek.debugbridge.clearPrintHistory`: Clears all entries from the captured print history buffer.
- `lurek.debugbridge.consumeHotReloadRequest`: Returns and clears the pending hot reload request flag.
- `lurek.debugbridge.getClientCount`: Returns the number of connected debug bridge clients.
- `lurek.debugbridge.getPerformance`: Returns debug bridge performance metrics.
- `lurek.debugbridge.getPort`: Returns the configured TCP port for the debug bridge.
- `lurek.debugbridge.getPrintHistory`: Returns captured print history entries.
- `lurek.debugbridge.getProtocolInfo`: Returns debug bridge protocol version, capabilities, and handshake nonce.
- `lurek.debugbridge.isRunning`: Returns whether the debug bridge server is currently running.
- `lurek.debugbridge.isScreenshotRequested`: Returns whether a screenshot request is pending.
- `lurek.debugbridge.poll`: Polls pending debugger requests, evaluates supported methods, and queues responses.
- `lurek.debugbridge.requestScreenshot`: Requests a screenshot from the runtime.
- `lurek.debugbridge.setMaxPrintHistory`: Sets the maximum retained print history entry count.
- `lurek.debugbridge.start`: Starts the localhost debug bridge server on a port.
- `lurek.debugbridge.stop`: Stops the debug bridge server and joins its server thread.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
