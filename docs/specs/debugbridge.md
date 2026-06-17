# debugbridge

## TL;DR

- Connects the game runtime to external editor panels.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/debugbridge/`
- Binding: `src/lua_api/debugbridge_api.rs`
- Namespace: `lurek.debugbridge`
- Lua API surface: `16` functions, `2` types, `0` methods
- Rust test path(s): tests/rust/unit/debugbridge_tests.rs
- Lua test path(s): tests/lua/unit/test_debugbridge.lua

## Summary

- Connects a running game session to external tooling so developers can inspect and control runtime state live.
- Enables remote debugging workflows without stopping gameplay or attaching heavyweight local instrumentation.
- Exposes protocol and capability metadata so client tools can negotiate supported bridge behavior safely.
- Streams print history and broadcast events to connected clients for faster issue triage.
- Supports screenshot and hot-reload request flows that accelerate iteration during content and script tuning.
- Provides basic session hardening through handshake and nonce-based access checks.
- Gives teams one remote diagnostics channel for live observability and command dispatch.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bridge.rs

- Implements shared state and queue structures for runtime-to-client debug bridge communication. `debugbridge/bridge` delivers the bridge implementation for the debugbridge subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores pending requests and responses exchanged between network server and runtime logic. The file owns or coordinates data contracts including `PendingRequest`, `PendingResponse`, `PrintEntry`, `BridgeShared`, `SharedBridge`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Tracks rolling performance metrics and bounded print history for debugger-side inspection. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `elapsed`, `get_performance`, `push_print`, `record_frame`, `set_max_print_history`, and 3 more stays attached to the local data model and invariants.
- Maintains session configuration and capability metadata used across active bridge connections. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Provides broadcast event queues for fan-out delivery to all connected debug clients. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange. `debugbridge/mod` is the debugbridge module index, declaring `bridge`, `server` so agents can identify which files own each feature slice before opening implementation code.
- Groups shared bridge state and TCP server functionality under one integration surface. `src/debugbridge/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bridge::{BridgeShared, PendingRequest, PendingResponse, PrintEntry, SharedBridge}`, `server::{handle_client_message, server_thread}` centralized for the debugbridge subsystem.

### server.rs

- Implements the non-blocking TCP server loop for debugbridge client connectivity and dispatch. `debugbridge/server` delivers the server implementation for the debugbridge subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Accepts client sessions and parses JSON-RPC messages into runtime and built-in command handlers. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers queued responses and broadcast events across connected debugger endpoints. Public callable behavior is centered on `server_thread`, `handle_client_message`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Handles handshake, protocol version checks, and nonce-based authentication workflows. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports eval, ping, performance, print-history, and screenshot-oriented protocol requests. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.



## Lua API Ref

### Functions

- `lurek.debugbridge.broadcast(event, json_data) -> nil`: Queues a JSON string payload broadcast for debug bridge clients.
- `lurek.debugbridge.capturePrint(msg, source?, line?) -> nil`: Captures a print message and broadcasts it to debug bridge clients.
- `lurek.debugbridge.clearPrintHistory() -> nil`: Clears all entries from the captured print history buffer.
- `lurek.debugbridge.consumeHotReloadRequest() -> boolean`: Returns and clears the pending hot reload request flag.
- `lurek.debugbridge.getClientCount() -> integer`: Returns the number of connected debug bridge clients.
- `lurek.debugbridge.getPerformance() -> table`: Returns debug bridge performance metrics.
- `lurek.debugbridge.getPort() -> integer`: Returns the configured TCP port for the debug bridge.
- `lurek.debugbridge.getPrintHistory(count?) -> table`: Returns captured print history entries.
- `lurek.debugbridge.getProtocolInfo() -> table`: Returns debug bridge protocol version, capabilities, and handshake nonce.
- `lurek.debugbridge.isRunning() -> boolean`: Returns whether the debug bridge server is currently running.
- `lurek.debugbridge.isScreenshotRequested() -> boolean`: Returns whether a screenshot request is pending.
- `lurek.debugbridge.poll() -> nil`: Polls pending debugger requests, evaluates supported methods, and queues responses.
- `lurek.debugbridge.requestScreenshot(scale?) -> nil`: Requests a screenshot from the runtime.
- `lurek.debugbridge.setMaxPrintHistory(max) -> nil`: Sets the maximum retained print history entry count.
- `lurek.debugbridge.start(port?) -> boolean`: Starts the localhost debug bridge server on a port.
- `lurek.debugbridge.stop() -> nil`: Stops the debug bridge server and joins its server thread.

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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
