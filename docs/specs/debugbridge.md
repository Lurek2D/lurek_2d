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

- The `debugbridge` module is the remote inspection channel between a running game and external development tools such as the VS Code extension or MCP-style clients.
- It owns the bridge state, network protocol, queued requests and responses, print-history streaming, and guarded remote operations such as screenshots or hot reload requests.
- Read it as the integration boundary for external observability: gameplay systems do not need to know editor protocols, because `debugbridge` translates between runtime state and tool clients.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### bridge.rs

- `src/debugbridge/bridge.rs` owns the shared debug bridge state used by the runtime thread and debugger clients.
- It defines queued request and response records, print history rows, and the `BridgeShared` container that holds them.
- Request, response, and broadcast queues live here so networking code and runtime handlers exchange data through it.
- This file also tracks frame timing samples, client counts, capabilities, handshake nonce data, and screenshot requests.
- Open it when telemetry retention, queue semantics, print history policy, or bridge session metadata must change.
- Higher layers should treat this file as the synchronization and state boundary, not the place for TCP parsing logic.

### mod.rs

- `src/debugbridge/mod.rs` is the module index that exposes the runtime debug bridge state and server entry points.
- It reexports shared queue types and network handlers so runtime code and tooling consume one stable debugger surface.
- No bridge state lives here; this file only declares child modules and defines which debug transport symbols are public.
- Read this index when wiring IDE integration, because it shows where shared state ends and socket handling begins.
- Changes here reshape the debugger boundary, since reexports decide what engine code may import without deep paths.
- This module keeps bridge storage and TCP protocol handling separate, which makes debugger ownership easier to trace.

### server.rs

- `src/debugbridge/server.rs` owns the non-blocking TCP loop that accepts debugger clients and reads line-delimited JSON.
- `server_thread` manages client sockets, flushes queued responses, and fans out broadcast events from bridge state.
- `handle_client_message` validates JSON requests, enforces nonce and protocol checks, and dispatches supported methods.
- Built-in commands such as ping, status, performance, print history, hot reload, and screenshots are handled here.
- Runtime-bound operations like eval, globals, locals, and call-stack inspection are queued for later engine execution.
- Read this file when debugger transport behavior, authorization rules, or per-method response payloads need to change.
- This is the network edge of debugbridge; shared queues stay in `bridge.rs`, while protocol flow and I/O live here.



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
