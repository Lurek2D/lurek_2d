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

This module represents the network communication and multiplayer transport subsystem, enabling real-time game coordination across host sessions. It wraps ENet bindings to handle low-level UDP sockets, connection lifecycles, and multi-channel packet delivery. By abstracting host behaviors into server, client, or combined host configurations, the engine manages connection slotting, disconnect sequences, and round-trip statistics seamlessly.

To isolate network latency from main-loop timings, the module operates on a background network thread. MPSC queues isolate message transfers, ensuring the game loop remains responsive during socket blockages. This thread drives non-blocking TCP connections and WebSocket pools, managing secure handshakes and frame exchanges. Additionally, ureq-backed HTTP agents handle synchronous queries and Server-Sent Event push streams in parallel.

Multiplayer states are synchronized using authoritative entity snapshots and client reconciliation. The system captures object positions, stepping simulations forward using linear dead-reckoning prediction between ticks. It resolves differences using configurable blending factors, keeping replicated entities aligned across clients. MessagePack serialization provides packed, zero-allocation sizing estimates before transport.

Lobby discovery and NAT traversal facilitate session-matching workflows. Discovered games are advertised on local networks using UDP broadcasts, and the room registry handles creation, listing, and membership. Dynamic UDP hole punching and ticket generation support NAT traversal, allowing clients to establish direct connections through relay boundaries without manual port configurations or server-side setups.

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
