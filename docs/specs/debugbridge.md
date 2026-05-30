# debugbridge

## TL;DR

- The `debugbridge` module provides a powerful TCP-based communication layer that enables external toolsâ€”such as the VS Code extension, remote inspectors, and diagnostic dashboardsâ€”to connect directly to a running Lurek2D instance.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/debugbridge/`
- Binding: `src/lua_api/debugbridge_api.rs`
- Namespace: `lurek.debugbridge`
- Lua API surface: `16` functions, `2` types, `0` methods
- Rust test path(s): tests/rust/unit/debugbridge_tests.rs
- Lua test path(s): tests/lua/unit/test_debugbridge.lua

## Summary

The `debugbridge` module provides runtime-to-tool communication primitives for debugging workflows, centered on shared bridge state and server-side JSON-RPC style message handling. Its purpose is integration: shuttle requests/responses and debug prints between engine runtime and external tooling while preserving thread-safe queue semantics.

`bridge.rs` owns shared data structures (`BridgeShared`, pending request/response buffers, print entries), and `server.rs` owns client message handling plus server-thread lifecycle. The module then re-exports these integration types/functions for runtime layers that start and drive the bridge.

This module should stay transport-focused. It is not a replacement for gameplay introspection logic; it is the conduit that carries those operations between processes.

Operationally, quality depends on predictable queue behavior, clear message contracts, and failure-safe networking boundaries so debug tooling cannot silently corrupt runtime state.

Implementation detail and boundary guarantees for debugbridge: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: bridge.rs: Define shared state and queue structures for the debug bridge protocol.; mod.rs: Expose the debug bridge subsystem for runtime-to-IDE communication.; server.rs: Run a non-blocking TCP server loop accepting debug bridge client connections.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bridge.rs

- Implements shared state and queue structures for runtime-to-client debug bridge communication.
- Stores pending requests and responses exchanged between network server and runtime logic.
- Tracks rolling performance metrics and bounded print history for debugger-side inspection.
- Maintains session configuration and capability metadata used across active bridge connections.
- Provides broadcast event queues for fan-out delivery to all connected debug clients.
- Serves as the core synchronization layer under the debug bridge protocol subsystem.

### mod.rs

- Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange.
- Groups shared bridge state and TCP server functionality under one integration surface.
- Serves as the composition entry for engine-side debugbridge capabilities.

### server.rs

- Implements the non-blocking TCP server loop for debugbridge client connectivity and dispatch.
- Accepts client sessions and parses JSON-RPC messages into runtime and built-in command handlers.
- Delivers queued responses and broadcast events across connected debugger endpoints.
- Handles handshake, protocol version checks, and nonce-based authentication workflows.
- Supports eval, ping, performance, print-history, and screenshot-oriented protocol requests.
- Serves as the network transport execution layer for the debugbridge subsystem.
- Preserves deterministic request lifecycle behavior across concurrent debugger client sessions.

## Lua API Ref

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

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LDebugbridgeGetPrintHistoryResult Type

- Generated result shape from @field tags.

##### Fields

- `line` (`integer`): Line number.
- `message` (`string`): Log message.
- `source` (`string`): Source file or module.
- `timestamp` (`number`): Unix timestamp.

##### Methods

- No documented methods.

#### LDebugbridgeGetProtocolInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `capabilities` (`table`): Capabilities table.
- `nonce` (`string`): Nonce.
- `version` (`string`): Protocol version.

##### Methods

- No documented methods.
