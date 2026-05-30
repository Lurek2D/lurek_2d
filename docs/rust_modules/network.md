# network

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Binding: `src/lua_api/network_api.rs`
- Namespace: `lurek.network`
- Lua API surface: `21` functions, `17` types, `49` methods
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua, tests/lua/unit/test_network_pack_unpack.lua, tests/lua/unit/test_network_roles.lua, tests/lua/unit/test_network_runtimer.lua, tests/lua/security/test_network_security.lua

## Summary

It is engineered to handle a diverse array of network topologies and transport protocols, including high-performance ENet UDP transport, raw non-blocking TCP sockets, asynchronous HTTP requests, and persistent bidirectional WebSocket connections. The module is built around a dedicated background `NetworkRuntime` thread (powered by Tokio) that handles all blocking I/O, ensuring that socket latency and network operations never stall the primary game loop. The game thread communicates with this runtime via highly efficient MPSC request/response channels.

At the heart of real-time multiplayer functionality is the `NetworkHost` structure, which wraps an ENet instance and manages robust connections across Server, Client, or Peer-to-Peer roles. It supports sophisticated traffic shaping, including per-peer bandwidth limits and reliable/unreliable channel separation, and provides a continuous stream of `NetworkEvent`s (connect, disconnect, receive) for Lua to consume. To address the complexities of modern internet connectivity, the module features a sophisticated `relay` system that utilizes NAT-punching probes and encoded `RelayTicket`s to establish peer connections even across restrictive networks. It also provides built-in LAN lobby discovery via UDP broadcasting.

Beyond raw transport, the module implements high-level game synchronization features. The `net_sync` submodule provides tools for entity snapshot replication, utilizing linear dead-reckoning prediction and server-authoritative reconciliation to ensure smooth gameplay across varied latencies. Network messaging is powered by a custom `NetValue` wire-format, mirroring Lua's dynamic type system and utilizing compact MessagePack serialization. Auxiliary services, like the synchronous HTTP client (supporting all major verbs with headers and timeouts) and the WebSocket manager, provide vital hooks for integrating with REST APIs, authentication servers, and web-based services. This extensive networking suite is fully exposed to scripts via the `lurek.network.*` API, making it a cornerstone for connected Lurek2D games.

## Files

### [constants.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/constants.rs)

- Numeric limits for peer connections, channels, and buffer sizes.
- Provides default fallback values when game config omits network settings.
- Holds timeout durations for HTTP and transport-level operations.

### [error.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/error.rs)

- Unified error type for all network subsystem failures.
- Covers socket I/O, ENet, HTTP, WebSocket, TCP, and threading faults.
- Integrates with thiserror for automatic Display and From implementations.

### [host.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/host.rs)

- ENet host wrapper owning a non-blocking UDP socket and peer slots for one endpoint.
- Classifies the host role as server, client, or combined host for session routing.
- Runs the event poll loop that yields connect, disconnect, and receive events.
- Manages connection lifecycle, packet delivery, and reset flows.
- Exposes peer diagnostics such as round-trip time, state, address, and statistics.
- Lets callers tune bandwidth and channel limits at runtime.
- Provides convenience constructors for common server and client bind patterns.
- Acts as the low-level connection anchor for the multiplayer stack.

### [http.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/http.rs)

- Synchronous HTTP client built on ureq for common request verbs.
- Supports per-request timeout configuration through the agent builder.
- Returns a unified response object with status, body, headers, and error text.
- Keeps the API small so game code can fetch remote data without async setup.
- Fits simple request/response workflows inside scripts and engine tools.

### [lobby.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/lobby.rs)

- LAN lobby discovery via timed UDP broadcast on a fixed port.
- Encodes and parses lobby advertisements in a compact key-value wire format.
- Maintains an in-process room registry for create, join, leave, and list flows.
- Sends one broadcast datagram across all interfaces when scanning starts.
- Deduplicates discovered lobbies by host and port during the scan window.

### [message.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/message.rs)

- Wire-format value type mirroring Lua's dynamic type system for peer messaging.
- Uses MessagePack serialization and deserialization for packed transport.
- Provides zero-allocation size estimation before a message is sent.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/mod.rs)

- Multiplayer networking across TCP, WebSocket, relay, and HTTP helpers.
- Hosts the host/client model, lobby flow, peer management, and game-state sync.
- Runs the background async runtime for non-blocking socket I/O.

### [net_sync.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/net_sync.rs)

- Entity snapshot capture and wire serialization for networked state.
- Supports linear dead-reckoning prediction between ticks.
- Handles server-authoritative reconciliation with a configurable blend factor.
- Gives the multiplayer stack a compact sync model for replicated actors.

### [net_thread.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/net_thread.rs)

- Background network thread that owns all blocking I/O for HTTP, TCP, and WebSocket work.
- Uses MPSC request and response channels to keep the game thread isolated from latency.
- Drives transport activity through typed request and response enums.
- Models connection state with explicit TCP and WebSocket event types.
- Spawns, polls, and shuts down the runtime while preserving request ordering.
- Routes completed results back with correlation ids for outstanding work.
- Keeps the blocking transport surface off the main loop.

### [relay.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/relay.rs)

- Relay ticket encoding and decoding for room and peer identification.
- Builds UDP hole-punch probe payloads with a magic prefix.
- Provides lightweight helpers for relay-based NAT traversal signalling.

### [sse.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/sse.rs)

- Server-Sent Events stream reader for HTTP event endpoints.
- Uses a background thread to parse frames and forward them through a channel.
- Offers non-blocking polling plus a blocking collect helper for batched reads.
- Keeps live event streams separate from the main game thread.
- Fits long-lived event feeds that should not stall gameplay.
- Exposes a simple streaming shape for push-based remote updates.

### [tcp.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/tcp.rs)

- Non-blocking TCP connection pool for the background network thread.
- Uses round-robin polling across all active streams with event-based notification.
- Supports connect, send, close, and bulk-poll operations with automatic cleanup.
- Keeps stream management simple for the threaded network runtime.
- Serves as the pooled TCP transport layer for multiplayer I/O.

### [websocket.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/network/websocket.rs)

- Pool of active WebSocket connections keyed by caller-assigned id.
- Spawns background threads for TLS and TCP handshakes so connect never blocks the game loop.
- Polls live sockets for text, binary, and close frames without blocking.
- Sends text or binary frames and performs graceful close with drain semantics.
- Posts connection lifecycle events through an MPSC channel.
- Keeps WebSocket transport behaviour isolated from game-thread timing.
