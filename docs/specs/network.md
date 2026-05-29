# network

## TL;DR

- The `network` module is a powerful Core Runtime tier component providing a comprehensive multiplayer networking stack for Lurek2D.

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Lua API path(s): `src/lua_api/network_api.rs`
- Primary Lua namespace: `lurek.network`
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua, tests/lua/unit/test_network_pack_unpack.lua, tests/lua/unit/test_network_roles.lua, tests/lua/unit/test_network_runtimer.lua, tests/lua/security/test_network_security.lua

## Summary

It is engineered to handle a diverse array of network topologies and transport protocols, including high-performance ENet UDP transport, raw non-blocking TCP sockets, asynchronous HTTP requests, and persistent bidirectional WebSocket connections. The module is built around a dedicated background `NetworkRuntime` thread (powered by Tokio) that handles all blocking I/O, ensuring that socket latency and network operations never stall the primary game loop. The game thread communicates with this runtime via highly efficient MPSC request/response channels.

At the heart of real-time multiplayer functionality is the `NetworkHost` structure, which wraps an ENet instance and manages robust connections across Server, Client, or Peer-to-Peer roles. It supports sophisticated traffic shaping, including per-peer bandwidth limits and reliable/unreliable channel separation, and provides a continuous stream of `NetworkEvent`s (connect, disconnect, receive) for Lua to consume. To address the complexities of modern internet connectivity, the module features a sophisticated `relay` system that utilizes NAT-punching probes and encoded `RelayTicket`s to establish peer connections even across restrictive networks. It also provides built-in LAN lobby discovery via UDP broadcasting.

Beyond raw transport, the module implements high-level game synchronization features. The `net_sync` submodule provides tools for entity snapshot replication, utilizing linear dead-reckoning prediction and server-authoritative reconciliation to ensure smooth gameplay across varied latencies. Network messaging is powered by a custom `NetValue` wire-format, mirroring Lua's dynamic type system and utilizing compact MessagePack serialization. Auxiliary services, like the synchronous HTTP client (supporting all major verbs with headers and timeouts) and the WebSocket manager, provide vital hooks for integrating with REST APIs, authentication servers, and web-based services. This extensive networking suite is fully exposed to scripts via the `lurek.network.*` API, making it a cornerstone for connected Lurek2D games.

## Files

### constants.rs

- Numeric limits for peer connections, channels, and buffer sizes.
- Default fallback values when game config omits network parameters.
- Timeout durations for HTTP and transport-level operations.

### error.rs

- Unified error enum for all network subsystem failures.
- Covers socket I/O, ENet, HTTP, WebSocket, TCP, and threading faults.
- Integrates with `thiserror` for automatic `Display` and `From` impls.

### host.rs

- ENet host wrapper owning a non-blocking UDP socket and all peer slots for one endpoint.
- Host role classification (Server, Client, combined Host) for session routing.
- Event-driven poll loop yielding Connect, Disconnect, and Receive events.
- Connection lifecycle: initiate, graceful disconnect, forced disconnect, and reset.
- Unicast and broadcast packet sending with reliable or unreliable delivery.
- Peer diagnostics: round-trip time, connection state, address, and full statistics snapshot.
- Bandwidth and channel limit configuration at runtime.
- Convenience constructors for common server and client bind patterns.

### http.rs

- Synchronous HTTP client built on `ureq` for GET, POST, PUT, PATCH, DELETE, HEAD, and OPTIONS.
- Configurable per-request timeout via agent builder.
- Unified `HttpResponse` captures status, body, headers, and optional error message.

### lobby.rs

- LAN lobby discovery via timed UDP broadcast listen on a fixed port.
- Lobby advertisement encoding and parsing in a `key=value;...` wire format.
- In-process room registry for create, join, leave, and list operations.
- Broadcast helper that sends a single SO_BROADCAST datagram on all interfaces.
- Deduplication of discovered lobbies by host+port during the scan window.

### message.rs

- Wire-format value type (`NetValue`) mirroring Lua's dynamic type system for cross-peer messaging.
- MessagePack serialization and deserialization via `pack`/`unpack`.
- Zero-allocation size estimation for budget checks before sending.

### mod.rs

- Multiplayer networking: TCP, WebSocket, and relay transports with binary message framing.
- Host/client model with lobby state machine, peer management, and game-state sync.
- Background async runtime (Tokio) for non-blocking socket I/O and HTTP helpers.

### net_sync.rs

- Entity snapshot capture and wire serialization for networked state.
- Linear dead-reckoning prediction between ticks.
- Server-authoritative reconciliation with configurable blend factor.

### net_thread.rs

- Background network thread that owns all blocking I/O (HTTP, TCP, WebSocket).
- MPSC request/response channels isolate the game thread from socket latency.
- `NetworkRequest` enum drives HTTP fetches, TCP streams, and WebSocket frames.
- `NetworkResponse` carries completed results and lifecycle events back to the game loop.
- `TcpEvent` / `WsEvent` model connection state machines (connect, data, close, error).
- `NetworkRuntime` struct spawns the thread, assigns IDs, and exposes typed helpers.
- 10 ms poll loop processes transports and drains the request channel.
- Graceful shutdown closes all connections and joins the thread on drop.
- Correlation IDs let the game thread match responses to outstanding requests.

### relay.rs

- Relay ticket encoding and decoding for room+peer identification over the wire.
- UDP hole-punch probe construction and parsing with a magic prefix.
- Lightweight helpers for relay-based NAT traversal signalling.

### sse.rs

- Server-Sent Events (SSE) stream reader.
- Uses a background thread to read events from an HTTP SSE endpoint.
- `SseStream::connect` spawns a reader thread that parses SSE frames and sends them over a channel.
- `SseStream::next` polls for the next event without blocking.
- `SseStream::collect` is a blocking helper for gathering a fixed number of events.
- See `docs/specs/network.md` for the full SSE API specification.

### tcp.rs

- Non-blocking TCP connection pool for the background network thread.
- Round-robin polling across all active streams with event-based notification.
- Connect, send, close, and bulk-poll operations with automatic error cleanup.

### websocket.rs

- Manage a pool of active WebSocket connections keyed by caller-assigned ID.
- Spawn background threads for TLS/TCP handshakes so connect never blocks the game loop.
- Non-blocking poll loop reads text, binary, and close frames from all live sockets.
- Send text or binary frames, and perform graceful close with drain semantics.
- Post all connection lifecycle events (open, message, error, close) through an MPSC channel.

## Lua API Ref

- Binding: `src/lua_api/network_api.rs`
- Namespace: `lurek.network`

### Functions

- `lurek.network.createLobby`: Broadcasts lobby information and returns it as a table.
- `lurek.network.createRoom`: Creates a local room record. This function is exposed to Lua scripts.
- `lurek.network.discoverLobbies`: Discovers broadcast lobbies. This function is exposed to Lua scripts.
- `lurek.network.joinRoom`: Joins a room by id when available. This function is exposed to Lua scripts.
- `lurek.network.leaveRoom`: Leaves a room by id when available. This function is exposed to Lua scripts.
- `lurek.network.listRooms`: Lists known local room records. This function is exposed to Lua scripts.
- `lurek.network.makePunchProbe`: Creates a relay punch probe payload for a peer id.
- `lurek.network.newClient`: Creates a client host and connects to an address.
- `lurek.network.newHost`: Creates a network host from an options table.
- `lurek.network.newRelayTicket`: Creates an encoded relay ticket. This function is exposed to Lua scripts.
- `lurek.network.newRuntime`: Creates a background network runtime.
- `lurek.network.newServer`: Creates a server host from an options table.
- `lurek.network.pack`: Packs a supported Lua value into a binary network message string.
- `lurek.network.parsePunchProbe`: Parses a relay punch probe payload.
- `lurek.network.parseRelayTicket`: Parses an encoded relay ticket. This function is exposed to Lua scripts.
- `lurek.network.predictLinear`: Predicts an entity snapshot forward by linear velocity.
- `lurek.network.reconcileSnapshot`: Reconciles a predicted snapshot toward an authoritative snapshot.
- `lurek.network.sseCollect`: Blocking helper: collects up to `n` events from a fresh SSE connection or until `timeout_secs` elapses.
- `lurek.network.sseConnect`: Opens an SSE stream to `url` and returns an `LSseStream` handle.
- `lurek.network.syncEntity`: Broadcasts a packed entity sync payload through a network host.
- `lurek.network.unpack`: Unpacks a binary network message string into a Lua value.

### Enums

- No documented module-level enums/constants.

### Types


#### LNetworkHost Type


##### Fields

- No documented fields.

##### Methods

- `LNetworkHost:broadcast`: Broadcasts bytes to all connected peers on a channel.
- `LNetworkHost:connect`: Connects to a remote address. This method is available to Lua scripts.
- `LNetworkHost:destroy`: Destroys the network host and releases resources.
- `LNetworkHost:disconnect`: Requests a graceful peer disconnect.
- `LNetworkHost:disconnectLater`: Schedules a peer disconnect after pending packets.
- `LNetworkHost:disconnectNow`: Disconnects a peer immediately. This method is available to Lua scripts.
- `LNetworkHost:flush`: Flushes queued outgoing network packets.
- `LNetworkHost:getAddress`: Returns local host socket address.
- `LNetworkHost:getBandwidthLimit`: Returns incoming and outgoing bandwidth limits.
- `LNetworkHost:getChannelLimit`: Returns configured channel limit.
- `LNetworkHost:getConnectedPeerCount`: Returns the number of currently connected peers.
- `LNetworkHost:getConnectedPeerIds`: Returns an array of ids for all connected peers.
- `LNetworkHost:getPeerAddress`: Returns peer socket address when available.
- `LNetworkHost:getPeerLimit`: Returns configured peer limit. This method is available to Lua scripts.
- `LNetworkHost:getPeerState`: Returns peer connection state. This method is available to Lua scripts.
- `LNetworkHost:getPeerStats`: Returns statistics for a peer. This method is available to Lua scripts.
- `LNetworkHost:getRole`: Returns host role string. This method is available to Lua scripts.
- `LNetworkHost:getRoundTripTime`: Returns peer round trip time in milliseconds.
- `LNetworkHost:isClient`: Returns whether this host has client role.
- `LNetworkHost:isDestroyed`: Returns whether the network host is destroyed.
- `LNetworkHost:isServer`: Returns whether this host has server role.
- `LNetworkHost:ping`: Sends a ping to a peer. This method is available to Lua scripts.
- `LNetworkHost:resetPeer`: Resets a peer connection. This method is available to Lua scripts.
- `LNetworkHost:send`: Sends bytes to a peer on a channel. This method is available to Lua scripts.
- `LNetworkHost:service`: Polls the host for one network event.
- `LNetworkHost:setBandwidthLimit`: Sets incoming and outgoing bandwidth limits.
- `LNetworkHost:setChannelLimit`: Sets channel limit. This method is available to Lua scripts.
- `LNetworkHost:type`: Returns the Lua-visible type name for this network host handle.
- `LNetworkHost:typeOf`: Returns whether this network host handle matches a supported type name.


#### LNetworkRuntime Type


##### Fields

- No documented fields.

##### Methods

- `LNetworkRuntime:httpGet`: Starts an HTTP GET request. This method is available to Lua scripts.
- `LNetworkRuntime:httpJson`: Starts an HTTP POST request with a JSON-encoded body and Content-Type application/json.
- `LNetworkRuntime:httpPost`: Starts an HTTP POST request. This method is available to Lua scripts.
- `LNetworkRuntime:httpRequest`: Starts an HTTP request from an options table and returns its request id.
- `LNetworkRuntime:httpStream`: Starts an HTTP GET request intended for Server-Sent Events or streaming responses.
- `LNetworkRuntime:poll`: Polls runtime responses for HTTP, TCP, and WebSocket operations.
- `LNetworkRuntime:shutdown`: Shuts down the network runtime and cancels pending requests.
- `LNetworkRuntime:tcpClose`: Closes a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:tcpConnect`: Opens a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:tcpSend`: Sends bytes over a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:type`: Returns the Lua-visible type name for this network runtime handle.
- `LNetworkRuntime:typeOf`: Returns whether this network runtime handle matches a supported type name.
- `LNetworkRuntime:wsClose`: Closes a WebSocket connection. This method is available to Lua scripts.
- `LNetworkRuntime:wsConnect`: Opens a WebSocket connection. This method is available to Lua scripts.
- `LNetworkRuntime:wsSend`: Sends text over a WebSocket connection.


#### LSseStream Type


##### Fields

- No documented fields.

##### Methods

- `LSseStream:close`: Signals the background reader thread to stop and closes the stream.
- `LSseStream:isOpen`: Returns true if the background reader thread is still connected and reading.
- `LSseStream:next`: Polls for the next available event from the SSE stream (non-blocking).
- `LSseStream:type`: Returns the Lua-visible type name for this SSE stream handle.
- `LSseStream:typeOf`: Returns whether this SSE stream handle matches a supported type name.

## References

- `runtime`: Imports runtime config from `src/runtime/`.
