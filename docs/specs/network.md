# network

## TL;DR

- Manages ENet UDP hosts, TCP/WebSocket pools, and ureq-backed HTTP/SSE channels.
- Coordinates MessagePack messaging, linear predictions, and snapshot syncs.

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Binding: `src/lua_api/network_api.rs`
- Namespace: `lurek.network`
- Lua API surface: `30` functions, `17` types, `61` methods
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua, tests/lua/unit/test_network_pack_unpack.lua, tests/lua/unit/test_network_roles.lua, tests/lua/unit/test_network_runtimer.lua, tests/lua/security/test_network_security.lua

## Summary

- This module gives users multiplayer transport and networking utilities for real-time and service-backed game features.
- ENet host support covers server, client, and mixed-host runtime roles.
- Peer lifecycle handling includes connect, disconnect, channel messaging, and round-trip diagnostics.
- Background runtime threading keeps blocking network operations off the frame-critical loop.
- MPSC queues support safe handoff between game logic and transport workers.
- TCP and WebSocket pools support persistent connection workflows.
- HTTP helpers support request-response integrations for backend service calls.
- SSE support enables long-lived push-style event ingestion from remote endpoints.
- MessagePack support provides compact serialization for runtime payloads.
- Snapshot helpers support entity-state packing and unpacking workflows.
- Prediction helpers support dead-reckoning style client smoothing.
- Reconciliation helpers support blending predicted and authoritative states.
- Lobby discovery supports LAN game discovery flows.
- Room management helpers support create/list/join/leave coordination.
- Relay ticket and punch-probe helpers support NAT traversal signaling.
- Runtime APIs expose thread counts, status, and event polling surfaces.
- RPC layer support enables request-response and notify-style message patterns.
- Network state sync helpers support authority-aware replicated key/value updates.
- The module is useful for co-op gameplay, dedicated servers, and tool-to-runtime communication.
- For users, it centralizes diverse transports under one consistent Lua-facing namespace.
- It reduces custom socket plumbing and integration duplication.
- It supports both low-latency gameplay channels and web-service integrations.
- The practical result is faster multiplayer feature implementation.
- It also improves observability of network behavior and failure modes.
- Overall, users get a broad, production-oriented networking toolkit.
- This makes scaling from local tests to internet sessions more manageable.
- It aligns transport, serialization, synchronization, and lobby concerns in one module.
- That alignment reduces cross-layer mismatch bugs in multiplayer stacks.
- Users gain flexibility to mix UDP gameplay and HTTP/WebSocket service traffic.

## Imports

- `runtime`: Imports runtime config from `src/runtime/`.

## Files

### constants.rs

- Numeric limits for peer connections, channels, and buffer sizes.
- Provides default fallback values when game config omits network settings.
- Holds timeout durations for HTTP and transport-level operations.

### error.rs

- Unified error type for all network subsystem failures.
- Covers socket I/O, ENet, HTTP, WebSocket, TCP, and threading faults.
- Integrates with thiserror for automatic Display and From implementations.

### host.rs

- ENet host wrapper owning a non-blocking UDP socket and peer slots for one endpoint.
- Classifies the host role as server, client, or combined host for session routing.
- Runs the event poll loop that yields connect, disconnect, and receive events.
- Manages connection lifecycle, packet delivery, and reset flows.
- Exposes peer diagnostics such as round-trip time, state, address, and statistics.
- Lets callers tune bandwidth and channel limits at runtime.
- Provides convenience constructors for common server and client bind patterns.
- Acts as the low-level connection anchor for the multiplayer stack.

### http.rs

- Synchronous HTTP client built on ureq for common request verbs.
- Supports per-request timeout configuration through the agent builder.
- Returns a unified response object with status, body, headers, and error text.
- Keeps the API small so game code can fetch remote data without async setup.
- Fits simple request/response workflows inside scripts and engine tools.

### lobby.rs

- LAN lobby discovery via timed UDP broadcast on a fixed port.
- Encodes and parses lobby advertisements in a compact key-value wire format.
- Maintains an in-process room registry for create, join, leave, and list flows.
- Sends one broadcast datagram across all interfaces when scanning starts.
- Deduplicates discovered lobbies by host and port during the scan window.

### message.rs

- Wire-format value type mirroring Lua's dynamic type system for peer messaging.
- Uses MessagePack serialization and deserialization for packed transport.
- Provides zero-allocation size estimation before a message is sent.

### mod.rs

- Multiplayer networking across TCP, WebSocket, relay, and HTTP helpers.
- Hosts the host/client model, lobby flow, peer management, and game-state sync.
- Runs the background async runtime for non-blocking socket I/O.

### net_sync.rs

- Entity snapshot capture and wire serialization for networked state.
- Supports linear dead-reckoning prediction between ticks.
- Handles server-authoritative reconciliation with a configurable blend factor.
- Gives the multiplayer stack a compact sync model for replicated actors.

### net_thread.rs

- Background network thread that owns all blocking I/O for HTTP, TCP, and WebSocket work.
- Uses MPSC request and response channels to keep the game thread isolated from latency.
- Drives transport activity through typed request and response enums.
- Models connection state with explicit TCP and WebSocket event types.
- Spawns, polls, and shuts down the runtime while preserving request ordering.
- Routes completed results back with correlation ids for outstanding work.
- Keeps the blocking transport surface off the main loop.

### netstat.rs

- Engine module for network statistics.
- Provides runtime metrics such as bytes sent/received and latency.
- This is a generic, genre‑agnostic API.

### netstate.rs

- Network state synchronization manager for replicated state across peers.
- Provides `LNetworkState` userdata wrapping the pure-Lua netstate protocol.
- Supports authority-based writes, per-key versioning, turn-based coordination,
- and callback-driven change notifications.

### relay.rs

- Relay ticket encoding and decoding for room and peer identification.
- Builds UDP hole-punch probe payloads with a magic prefix.
- Provides lightweight helpers for relay-based NAT traversal signalling.

### rpc.rs

- Remote Procedure Call (RPC) manager for networked function invocation.
- Provides request/response patterns, fire-and-forget notifications, and broadcasts
- over network connections. Manages pending calls with timeout, automatic request ID
- generation, and response callback dispatch.

### sse.rs

- Server-Sent Events stream reader for HTTP event endpoints.
- Uses a background thread to parse frames and forward them through a channel.
- Offers non-blocking polling plus a blocking collect helper for batched reads.
- Keeps live event streams separate from the main game thread.
- Fits long-lived event feeds that should not stall gameplay.
- Exposes a simple streaming shape for push-based remote updates.

### tcp.rs

- Non-blocking TCP connection pool for the background network thread.
- Uses round-robin polling across all active streams with event-based notification.
- Supports connect, send, close, and bulk-poll operations with automatic cleanup.
- Keeps stream management simple for the threaded network runtime.
- Serves as the pooled TCP transport layer for multiplayer I/O.

### websocket.rs

- Pool of active WebSocket connections keyed by caller-assigned id.
- Spawns background threads for TLS and TCP handshakes so connect never blocks the game loop.
- Polls live sockets for text, binary, and close frames without blocking.
- Sends text or binary frames and performs graceful close with drain semantics.
- Posts connection lifecycle events through an MPSC channel.
- Keeps WebSocket transport behaviour isolated from game-thread timing.

## Lua API Ref

### Functions

- `lurek.network.createLobby(name, port, player_count?, max_players?) -> table`: Broadcasts lobby information and returns it as a table.
- `lurek.network.createRoom(name, host, max_players?) -> table`: Creates a local room record. This function is exposed to Lua scripts.
- `lurek.network.discoverLobbies(timeout_ms?) -> table`: Discovers broadcast lobbies. This function is exposed to Lua scripts.
- `lurek.network.getPlayerList(room_name) -> table`: Returns list of peer IDs currently in a room.
- `lurek.network.getRoom(room_name) -> table`: Returns room metadata including host peer and player count.
- `lurek.network.isAllReady(room_name) -> boolean`: Checks if all players in a room are ready. Requires at least 2 players.
- `lurek.network.joinRoom(id) -> table`: Joins a room by id when available. This function is exposed to Lua scripts.
- `lurek.network.leaveRoom(id) -> table`: Leaves a room by id when available. This function is exposed to Lua scripts.
- `lurek.network.listRooms() -> table`: Lists known local room records. This function is exposed to Lua scripts.
- `lurek.network.makePunchProbe(peer_id) -> string`: Creates a relay punch probe payload for a peer id.
- `lurek.network.newClient(opts) -> LNetworkHost`: Creates a client host and connects to an address.
- `lurek.network.newHost(opts) -> LNetworkHost`: Creates a network host from an options table.
- `lurek.network.newNetState(host?, opts?) -> LNetworkState`: Creates a network state synchronization manager.
- `lurek.network.newRelayTicket(room_id, peer_id) -> string`: Creates an encoded relay ticket. This function is exposed to Lua scripts.
- `lurek.network.newRpc(host, channel?, timeout_ms?) -> LNetworkRpc`: Creates a network RPC manager attached to a host.
- `lurek.network.newRuntime() -> LNetworkRuntime`: Creates a background network runtime.
- `lurek.network.newServer(opts) -> LNetworkHost`: Creates a server host from an options table.
- `lurek.network.pack(value) -> string`: Packs a supported Lua value into a binary network message string.
- `lurek.network.packSnapshot(snapshot) -> string`: Packs a sync snapshot table into a binary network message string.
- `lurek.network.parsePunchProbe(payload) -> string`: Parses a relay punch probe payload.
- `lurek.network.parseRelayTicket(token) -> table`: Parses an encoded relay ticket. This function is exposed to Lua scripts.
- `lurek.network.predictLinear(snapshot, dt) -> table`: Predicts an entity snapshot forward by linear velocity.
- `lurek.network.reconcileSnapshot(pred, auth, alpha) -> table`: Reconciles a predicted snapshot toward an authoritative snapshot.
- `lurek.network.reconcileWithPolicy(pred, auth, alpha, soft_threshold, hard_threshold) -> table`: Reconciles a predicted snapshot toward an authoritative snapshot using a distance-based policy.
- `lurek.network.setReady(room_name, peer_id, ready) -> nil`: Marks a player as ready or not ready in a room.
- `lurek.network.sseCollect(url, n, timeout_secs?) -> table`: Blocking helper: collects up to `n` events from a fresh SSE connection or until `timeout_secs` elapses.
- `lurek.network.sseConnect(url, callback) -> LSseStream`: Opens an SSE stream to `url` and returns an `LSseStream` handle.
- `lurek.network.syncEntity(host_ud, entity_id, data_tbl, channel?, reliable?) -> nil`: Broadcasts a packed entity sync payload through a network host.
- `lurek.network.unpack(data) -> table`: Unpacks a binary network message string into a Lua value.
- `lurek.network.unpackSnapshot(data) -> table`: Unpacks a binary network message string into a sync snapshot table.

### Callbacks

- `lurek.network.sseConnect` param `callback` (`function`): Called with each event table `{ id?, event?, data }`.

### Enums

- No documented module-level enums/constants.

### Types

#### LNetworkCreateLobbyResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `max_players` (`integer`): Maximum players allowed.
- `name` (`string`): Lobby name.
- `player_count` (`integer`): Current player count.
- `port` (`integer`): Port number.

##### Methods

- No documented methods.

#### LNetworkCreateRoomResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `id` (`string`): Room identifier.
- `max_players` (`integer`): Maximum allowed players.
- `name` (`string`): Room name.
- `player_count` (`integer`): Current player count.

##### Methods

- No documented methods.

#### LNetworkDiscoverLobbiesResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `max_players` (`integer`): Maximum allowed players.
- `name` (`string`): Lobby name.
- `player_count` (`integer`): Current player count.
- `port` (`integer`): Host port.

##### Methods

- No documented methods.

#### LNetworkHost Type

- Lua-side wrapper for a network host.

##### Fields

- No documented fields.

##### Methods

- `LNetworkHost:broadcast(channel_id, data, reliable?) -> nil`: Broadcasts bytes to all connected peers on a channel.
- `LNetworkHost:clearLease(token) -> nil`: Removes a lease token immediately.
- `LNetworkHost:connect(addr_str, channels?, data?) -> integer`: Connects to a remote address. This method is available to Lua scripts.
- `LNetworkHost:destroy() -> nil`: Destroys the network host and releases resources.
- `LNetworkHost:disconnect(peer_id, data?) -> nil`: Requests a graceful peer disconnect.
- `LNetworkHost:disconnectLater(peer_id, data?) -> nil`: Schedules a peer disconnect after pending packets.
- `LNetworkHost:disconnectNow(peer_id, data?) -> nil`: Disconnects a peer immediately. This method is available to Lua scripts.
- `LNetworkHost:flush() -> nil`: Flushes queued outgoing network packets.
- `LNetworkHost:getAddress() -> string`: Returns local host socket address.
- `LNetworkHost:getBandwidthLimit() -> table`: Returns incoming and outgoing bandwidth limits.
- `LNetworkHost:getChannelLimit() -> integer`: Returns configured channel limit.
- `LNetworkHost:getConnectedPeerCount() -> integer`: Returns the number of currently connected peers.
- `LNetworkHost:getConnectedPeerIds() -> integer[]`: Returns an array of ids for all connected peers.
- `LNetworkHost:getLeasePeer(token) -> integer?`: Retrieves the peer ID associated with a valid, non-expired lease token.
- `LNetworkHost:getMetrics() -> table`: Returns global network host metrics.
- `LNetworkHost:getPeerAddress(peer_id) -> string`: Returns peer socket address when available.
- `LNetworkHost:getPeerLimit() -> integer`: Returns configured peer limit. This method is available to Lua scripts.
- `LNetworkHost:getPeerState(peer_id) -> string`: Returns peer connection state. This method is available to Lua scripts.
- `LNetworkHost:getPeerStats(peer_id) -> table`: Returns statistics for a peer. This method is available to Lua scripts.
- `LNetworkHost:getRole() -> string`: Returns host role string. This method is available to Lua scripts.
- `LNetworkHost:getRoundTripTime(peer_id) -> number`: Returns peer round trip time in milliseconds.
- `LNetworkHost:isClient() -> boolean`: Returns whether this host has client role.
- `LNetworkHost:isDestroyed() -> boolean`: Returns whether the network host is destroyed.
- `LNetworkHost:isServer() -> boolean`: Returns whether this host has server role.
- `LNetworkHost:ping(peer_id) -> nil`: Sends a ping to a peer. This method is available to Lua scripts.
- `LNetworkHost:registerLease(peer_id, timeout_secs) -> integer`: Registers a reconnection lease for the given peer ID.
- `LNetworkHost:renewLease(token, timeout_secs) -> boolean`: Renews an active lease token with a new duration.
- `LNetworkHost:resetPeer(peer_id) -> nil`: Resets a peer connection. This method is available to Lua scripts.
- `LNetworkHost:send(peer_id, channel_id, data, reliable?) -> nil`: Sends bytes to a peer on a channel. This method is available to Lua scripts.
- `LNetworkHost:service() -> table`: Polls the host for one network event.
- `LNetworkHost:setBandwidthLimit(incoming?, outgoing?) -> nil`: Sets incoming and outgoing bandwidth limits.
- `LNetworkHost:setChannelLimit(limit) -> nil`: Sets channel limit. This method is available to Lua scripts.
- `LNetworkHost:type() -> string`: Returns the Lua-visible type name for this network host handle.
- `LNetworkHost:typeOf(name) -> boolean`: Returns whether this network host handle matches a supported type name.

#### LNetworkHostGetBandwidthLimitResult Type

- Generated result shape from @field tags.

##### Fields

- `incoming` (`integer`): Incoming bandwidth limit.
- `outgoing` (`integer`): Outgoing bandwidth limit.

##### Methods

- No documented methods.

#### LNetworkHostGetPeerStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `packet_loss` (`number`): Packet loss ratio.
- `packets_lost` (`integer`): Packets lost.
- `packets_sent` (`integer`): Packets sent.
- `round_trip_time` (`number`): Round-trip time in ms.
- `round_trip_time_variance` (`number`): RTT variance.

##### Methods

- No documented methods.

#### LNetworkHostServiceResult Type

- Generated result shape from @field tags.

##### Fields

- `channel_id` (`integer?`): Channel index for receive events.
- `data` (`any`): Connection data or receive payload.
- `peer_id` (`integer`): Peer id.
- `type` (`string`): Event type (connect, disconnect, receive).

##### Methods

- No documented methods.

#### LNetworkJoinRoomResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `id` (`string`): Room id.
- `max_players` (`integer`): Maximum allowed players.
- `name` (`string`): Room name.
- `player_count` (`integer`): Current player count.

##### Methods

- No documented methods.

#### LNetworkLeaveRoomResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `id` (`string`): Room id.
- `max_players` (`integer`): Maximum allowed players.
- `name` (`string`): Room name.
- `player_count` (`integer`): Current player count.

##### Methods

- No documented methods.

#### LNetworkListRoomsResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `max_players` (`integer`): Maximum allowed players.
- `name` (`string`): Room name.
- `player_count` (`integer`): Current player count.

##### Methods

- No documented methods.

#### LNetworkParseRelayTicketResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Id.
- `peer_id` (`string`): Peer identifier.
- `room_id` (`string`): Room identifier.
- `tick` (`integer`): Tick number.
- `vx` (`number`): Velocity X.
- `vy` (`number`): Velocity Y.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LNetworkPredictLinearResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Id.
- `tick` (`integer`): Tick number.
- `vx` (`number`): Velocity X.
- `vy` (`number`): Velocity Y.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LNetworkReconcileSnapshotResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Id.
- `tick` (`integer`): Tick number.
- `vx` (`number`): Velocity X.
- `vy` (`number`): Velocity Y.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LNetworkRuntime Type

- Lua-side wrapper for the background network runtime.

##### Fields

- No documented fields.

##### Methods

- `LNetworkRuntime:authBootstrap(auth_url, payload, refresh_url) -> integer`: Start authenticating with a backend.
- `LNetworkRuntime:authCancel() -> nil`: Cancels active authentication.
- `LNetworkRuntime:getAuthStatus() -> string`: Returns the current active authentication status.
- `LNetworkRuntime:getAuthToken() -> string?`: Returns the current active access token.
- `LNetworkRuntime:getMetrics() -> table`: Returns network runtime metrics.
- `LNetworkRuntime:httpGet(url, headers?) -> integer`: Starts an HTTP GET request. This method is available to Lua scripts.
- `LNetworkRuntime:httpJson(url, body, headers?) -> integer`: Starts an HTTP POST request with a JSON-encoded body and Content-Type application/json.
- `LNetworkRuntime:httpPost(url, body, headers?) -> integer`: Starts an HTTP POST request. This method is available to Lua scripts.
- `LNetworkRuntime:httpRequest(opts) -> integer`: Starts an HTTP request from an options table and returns its request id.
- `LNetworkRuntime:httpStream(url, headers?, timeout_secs?) -> integer`: Starts an HTTP GET request intended for Server-Sent Events or streaming responses.
- `LNetworkRuntime:matchmakeCancel(id) -> nil`: Cancel matchmaking request.
- `LNetworkRuntime:matchmakeStart(url, payload) -> integer`: Start matchmaking request.
- `LNetworkRuntime:poll() -> table`: Polls runtime responses for HTTP, TCP, and WebSocket operations.
- `LNetworkRuntime:shutdown() -> nil`: Shuts down the network runtime and cancels pending requests.
- `LNetworkRuntime:tcpClose(id) -> nil`: Closes a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:tcpConnect(addr) -> integer`: Opens a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:tcpSend(id, data) -> nil`: Sends bytes over a TCP connection. This method is available to Lua scripts.
- `LNetworkRuntime:type() -> string`: Returns the Lua-visible type name for this network runtime handle.
- `LNetworkRuntime:typeOf(name) -> boolean`: Returns whether this network runtime handle matches a supported type name.
- `LNetworkRuntime:wsClose(id) -> nil`: Closes a WebSocket connection. This method is available to Lua scripts.
- `LNetworkRuntime:wsConnect(url) -> integer`: Opens a WebSocket connection. This method is available to Lua scripts.
- `LNetworkRuntime:wsSend(id, data) -> nil`: Sends text over a WebSocket connection.

#### LNetworkRuntimePollResult Type

- Generated result shape from @field tags.

##### Fields

- `body` (`string?`): HTTP response body.
- `headers` (`table?`): HTTP response headers.
- `id` (`integer?`): TCP/WS connection id.
- `request_id` (`integer?`): HTTP request id.
- `status` (`integer?`): HTTP status code.
- `type` (`string`): Response type (http, tcp, ws).

##### Methods

- No documented methods.

#### LNetworkUnpackResult Type

- Generated result shape from @field tags.

##### Fields

- `host` (`string`): Host address.
- `max_players` (`integer`): Maximum players allowed.
- `name` (`string`): Lobby name.
- `player_count` (`integer`): Current player count.
- `port` (`integer`): Port number.

##### Methods

- No documented methods.

#### LSseStream Type

- Lua userdata wrapping an `SseStream` with an optional stored callback.

##### Fields

- No documented fields.

##### Methods

- `LSseStream:close() -> nil`: Signals the background reader thread to stop and closes the stream.
- `LSseStream:isOpen() -> boolean`: Returns true if the background reader thread is still connected and reading.
- `LSseStream:next() -> table`: Polls for the next available event from the SSE stream (non-blocking).
- `LSseStream:type() -> string`: Returns the Lua-visible type name for this SSE stream handle.
- `LSseStream:typeOf(name) -> boolean`: Returns whether this SSE stream handle matches a supported type name.
