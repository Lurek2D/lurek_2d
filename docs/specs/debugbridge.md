# debugbridge

## TL;DR

- The `debugbridge` module provides a powerful TCP-based communication layer that enables external tools—such as the VS Code extension, remote inspectors, and diagnostic dashboards—to connect directly to a running Lurek2D instance.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/debugbridge/`
- Lua API path(s): `src/lua_api/debugbridge_api.rs`
- Primary Lua namespace: `lurek.debugbridge`
- Rust test path(s): tests/rust/unit/debugbridge_tests.rs
- Lua test path(s): tests/lua/unit/test_debugbridge.lua

## Summary

 Situated within the Edge/Integration tier, the bridge operates primarily over a lightweight JSON-RPC protocol. It accepts requests for real-time engine interactions, including breakpoint management, variable inspection, expression evaluation, screenshot capture, and print history retrieval. By design, the module is disabled by default in release builds for security and performance reasons, activating only when explicitly started from Lua via `lurek.debugbridge.start()`.

At the architectural core of the module is `BridgeShared`, a synchronized state container wrapped in an `Arc<Mutex<>>`. This structure safely brokers data between the main game thread and the dedicated background TCP I/O thread. It holds pending request and response queues, frame-time performance metrics with bounded sampling windows, and a broadcast queue for event delivery to all connected clients. One of its key features is print capture: it intercepts `lurek.log` and standard Lua `print` output, storing it in a bounded ring buffer so that external editors can natively display runtime textual output without needing to scrape the system's stdout.

The server loop manages non-blocking TCP connections, executing protocol handshakes, nonce authentication, and version negotiations to ensure secure tooling connections. It handles background-safe JSON-RPC messages immediately, while queuing game-state-dependent operations as `PendingRequest` records for the main thread to poll via `lurek.debugbridge.poll()`. The Lua API fully exposes these capabilities, allowing script developers to programmatically trigger broadcasts, request screenshots, track connected client counts, and consume hot-reload requests dynamically.

## Source Documentation

### `bridge.rs`
- Define shared state and queue structures for the debug bridge protocol.
- Hold pending request and response buffers for runtime-client communication.
- Track rolling frame-time performance metrics with bounded sample windows.
- Maintain bounded print history captured from runtime Lua output.
- Manage session configuration: port, protocol version, capabilities, and nonce.
- Provide broadcast queue for event delivery to all connected clients.

### `mod.rs`
- Expose the debug bridge subsystem for runtime-to-IDE communication.
- Provide shared state queues, TCP server loop, and JSON-RPC dispatch.
- Re-export integration types used by the engine runtime layer.

### `server.rs`
- Run a non-blocking TCP server loop accepting debug bridge client connections.
- Parse JSON-RPC messages and dispatch to built-in handlers or runtime queue.
- Deliver pending responses and broadcast events to connected clients.
- Handle protocol handshake, nonce authentication, and version negotiation.
- Support ping, hello, eval, performance, print history, and screenshot requests.

## Types

- `PendingRequest` (`struct`, `bridge.rs`): Queued main-thread request record containing the request id, method name, params, and source client index. It is the handoff format for operations that must run on the game thread.
- `PendingResponse` (`struct`, `bridge.rs`): Queued reply destined for a specific client. It is the final step between completed work and wire-level transmission.
- `PrintEntry` (`struct`, `bridge.rs`): Timestamped print-capture record used for tooling visibility into Lua-side print output. It exists so editor tooling can observe runtime textual output without scraping stdout.
- `BridgeShared` (`struct`, `bridge.rs`): Central shared bridge state wrapped behind Arc<Mutex<...>>. It holds pending requests, pending responses, broadcasts, print history, screenshot flags, and frame metrics, so it is the main object to inspect when the bridge appears to stall or misroute data.
- `SharedBridge` (`type`, `bridge.rs`): Type alias for the shared bridge handle used across the module and Lua bridge. It is important because the whole design assumes one synchronized shared object moving between threads.

## Functions

- `BridgeShared::new` (`bridge.rs`): Create initialized shared bridge state and return it.
- `BridgeShared::elapsed` (`bridge.rs`): Return elapsed time in seconds from bridge epoch.
- `BridgeShared::get_performance` (`bridge.rs`): Return current performance metrics as a JSON object.
- `BridgeShared::push_print` (`bridge.rs`): Append a print row to history and enforce retention bounds.
- `BridgeShared::record_frame` (`bridge.rs`): Record one frame delta and update rolling performance aggregates.
- `BridgeShared::set_max_print_history` (`bridge.rs`): Set max print history and trim oldest rows beyond the new limit.
- `BridgeShared::drain_responses` (`bridge.rs`): Drain all pending responses and return them as a vector.
- `BridgeShared::queue_broadcast_json` (`bridge.rs`): Queue one broadcast event payload and return unit.
- `BridgeShared::capture_print_with_broadcast` (`bridge.rs`): Capture print entry and queue matching broadcast payload.
- `server_thread` (`server.rs`): Accept loop: runs on a background thread and handles all TCP I/O.
- `handle_client_message` (`server.rs`): Parses a newline-terminated JSON message from a client and either responds immediately (background-safe methods) or queues a [`PendingRequest`] for the main thread.

## Lua API Reference

- Binding path(s): `src/lua_api/debugbridge_api.rs`
- Namespace: `lurek.debugbridge`

### Module Functions
- `lurek.debugbridge.start`: Starts the localhost debug bridge server on a port.
- `lurek.debugbridge.stop`: Stops the debug bridge server and joins its server thread.
- `lurek.debugbridge.isRunning`: Returns whether the debug bridge server is currently running.
- `lurek.debugbridge.getPort`: Returns the configured TCP port for the debug bridge.
- `lurek.debugbridge.getClientCount`: Returns the number of connected debug bridge clients.
- `lurek.debugbridge.poll`: Polls pending debugger requests, evaluates supported methods, and queues responses.
- `lurek.debugbridge.capturePrint`: Captures a print message and broadcasts it to debug bridge clients.
- `lurek.debugbridge.getPrintHistory`: Returns captured print history entries.
- `lurek.debugbridge.clearPrintHistory`: Clears all entries from the captured print history buffer.
- `lurek.debugbridge.setMaxPrintHistory`: Sets the maximum retained print history entry count.
- `lurek.debugbridge.getPerformance`: Returns debug bridge performance metrics.
- `lurek.debugbridge.requestScreenshot`: Requests a screenshot from the runtime.
- `lurek.debugbridge.isScreenshotRequested`: Returns whether a screenshot request is pending.
- `lurek.debugbridge.broadcast`: Queues a JSON string payload broadcast for debug bridge clients.
- `lurek.debugbridge.getProtocolInfo`: Returns debug bridge protocol version, capabilities, and handshake nonce.
- `lurek.debugbridge.consumeHotReloadRequest`: Returns and clears the pending hot reload request flag.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/debugbridge/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
