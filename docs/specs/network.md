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

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports runtime config from `src/runtime/`.

## Files

### constants.rs

- Numeric limits for peer connections, channels, and buffer sizes. `network/constants` delivers the constants implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### error.rs

- Unified error type for all network subsystem failures. `network/error` delivers the error implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Covers socket I/O, ENet, HTTP, WebSocket, TCP, and threading faults. The file owns or coordinates data contracts including `NetworkError`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Integrates with thiserror for automatic Display and From implementations. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### host.rs

- ENet host wrapper owning a non-blocking UDP socket and peer slots for one endpoint. `network/host` delivers the host implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Classifies the host role as server, client, or combined host for session routing. The file owns or coordinates data contracts including `HostRole`, `EnetLease`, `NetworkHost`, `NetworkEvent`, `PeerStats`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Runs the event poll loop that yields connect, disconnect, and receive events. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `service`, `connect`, `send`, `send_bytes`, `broadcast`, and 31 more stays attached to the local data model and invariants.
- Manages connection lifecycle, packet delivery, and reset flows. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes peer diagnostics such as round-trip time, state, address, and statistics. External integration uses `super`, `rusty_enet`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Lets callers tune bandwidth and channel limits at runtime. The file boundary separates network implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### http.rs

- Synchronous HTTP client built on ureq for common request verbs. `network/http` delivers the http implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports per-request timeout configuration through the agent builder. The file owns or coordinates data contracts including `HttpResponse`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Returns a unified response object with status, body, headers, and error text. Public callable behavior is centered on `execute_request`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Keeps the API small so game code can fetch remote data without async setup. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### lobby.rs

- LAN lobby discovery via timed UDP broadcast on a fixed port. `network/lobby` delivers the lobby implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes and parses lobby advertisements in a compact key-value wire format. The file owns or coordinates data contracts including `LobbyInfo`, `RoomInfo`, `PlayerState`, `RoomState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Maintains an in-process room registry for create, join, leave, and list flows. Public callable behavior is centered on `broadcast_lobby`, `discover_lobbies`, `create_room`, `list_rooms`, `join_room`, and 5 more, while method-level behavior such as `to_wire`, `from_wire` stays attached to the local data model and invariants.
- Sends one broadcast datagram across all interfaces when scanning starts. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Deduplicates discovered lobbies by host and port during the scan window. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### message.rs

- Wire-format value type mirroring Lua's dynamic type system for peer messaging. `network/message` delivers the message implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Uses MessagePack serialization and deserialization for packed transport. The file owns or coordinates data contracts including `NetValue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides zero-allocation size estimation before a message is sent. Public callable behavior is centered on `pack`, `unpack`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### mod.rs

- Multiplayer networking across TCP, WebSocket, relay, and HTTP helpers. `network/mod` is the network module index, declaring `constants`, `error`, `host`, `http`, `lobby`, and 9 more so agents can identify which files own each feature slice before opening implementation code.
- Hosts the host/client model, lobby flow, peer management, and game-state sync. `src/network/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `sse::{SseEvent, SseStream}` centralized for the network subsystem.
- Runs the background async runtime for non-blocking socket I/O. The file documents how network submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `network/mod` is the network module index, declaring `constants`, `error`, `host`, `http`, `lobby`, and 9 more so agents can identify which files own each feature slice before opening implementation code.
- `src/network/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `sse::{SseEvent, SseStream}` centralized for the network subsystem.
- The file documents how network submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### net_sync.rs

- Entity snapshot capture and wire serialization for networked state. `network/net_sync` delivers the net sync implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports linear dead-reckoning prediction between ticks. The file owns or coordinates data contracts including `EntitySnapshot`, `SyncSnapshot`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Handles server-authoritative reconciliation with a configurable blend factor. Public callable behavior is centered on `predict_linear`, `reconcile`, `reconcile_with_policy`, while method-level behavior such as `to_netvalue`, `from_netvalue` stays attached to the local data model and invariants.
- Gives the multiplayer stack a compact sync model for replicated actors. Runtime integration reaches sibling engine areas through crate modules `network`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- `network/net_sync` delivers the net sync implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### net_thread.rs

- Background network thread that owns all blocking I/O for HTTP, TCP, and WebSocket work. `network/net_thread` delivers the net thread implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Uses MPSC request and response channels to keep the game thread isolated from latency. The file owns or coordinates data contracts including `NetworkRequest`, `NetworkResponse`, `TcpEvent`, `WsEvent`, `NetworkRuntime`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Drives transport activity through typed request and response enums. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `next_request_id`, `send`, `poll`, `shutdown`, `is_running`, and 14 more stays attached to the local data model and invariants.
- Models connection state with explicit TCP and WebSocket event types. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Spawns, polls, and shuts down the runtime while preserving request ordering. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Routes completed results back with correlation ids for outstanding work. The file boundary separates network implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Keeps the blocking transport surface off the main loop. State changes, validation paths, and helper routines in `src/network/net_thread.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- `network/net_thread` delivers the net thread implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### netstat.rs

- Engine module for network statistics. `network/netstat` delivers the netstat implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides runtime metrics such as bytes sent/received and latency. The file owns or coordinates data contracts including `NetStat`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- This is a generic, genre‑agnostic API. Public callable behavior is centered on `register`, while method-level behavior such as `new`, `update`, `snapshot` stays attached to the local data model and invariants.

### netstate.rs

- Network state synchronization manager for replicated state across peers. `network/netstate` delivers the netstate implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides `LNetworkState` userdata wrapping the pure-Lua netstate protocol. The file owns or coordinates data contracts including `LNetworkState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports authority-based writes, per-key versioning, turn-based coordination,. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.
- and callback-driven change notifications. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### relay.rs

- Relay ticket encoding and decoding for room and peer identification. `network/relay` delivers the relay implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds UDP hole-punch probe payloads with a magic prefix. The file owns or coordinates data contracts including `RelayTicket`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides lightweight helpers for relay-based NAT traversal signalling. Public callable behavior is centered on `encode_ticket`, `decode_ticket`, `make_punch_probe`, `parse_punch_probe`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### rpc.rs

- Remote Procedure Call (RPC) manager for networked function invocation. `network/rpc` delivers the rpc implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides request/response patterns, fire-and-forget notifications, and broadcasts. The file owns or coordinates data contracts including `LNetworkRpc`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- over network connections. Manages pending calls with timeout, automatic request ID. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.
- generation, and response callback dispatch. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### sse.rs

- Server-Sent Events stream reader for HTTP event endpoints. `network/sse` delivers the sse implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Uses a background thread to parse frames and forward them through a channel. The file owns or coordinates data contracts including `SseEvent`, `SseStream`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Offers non-blocking polling plus a blocking collect helper for batched reads. Public callable behavior is centered on no named public items, while method-level behavior such as `connect`, `next`, `close`, `is_open`, `collect` stays attached to the local data model and invariants.
- Keeps live event streams separate from the main game thread. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Fits long-lived event feeds that should not stall gameplay. External integration uses `log`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### tcp.rs

- Non-blocking TCP connection pool for the background network thread. `network/tcp` delivers the tcp implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Uses round-robin polling across all active streams with event-based notification. The file owns or coordinates data contracts including `TcpConnectionManager`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports connect, send, close, and bulk-poll operations with automatic cleanup. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `connect`, `send`, `close`, `poll_all`, `close_all`, and 1 more stays attached to the local data model and invariants.
- Keeps stream management simple for the threaded network runtime. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### websocket.rs

- Pool of active WebSocket connections keyed by caller-assigned id. `network/websocket` delivers the websocket implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Spawns background threads for TLS and TCP handshakes so connect never blocks the game loop. The file owns or coordinates data contracts including `WebSocketManager`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Polls live sockets for text, binary, and close frames without blocking. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `is_empty`, `connect`, `send`, `close`, `poll_all`, and 1 more stays attached to the local data model and invariants.
- Sends text or binary frames and performs graceful close with drain semantics. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Posts connection lifecycle events through an MPSC channel. External integration uses `super`, `log`, `std`, `tungstenite`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.



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
- `LNetworkHost:getLeasePeer(token) -> integer`: Retrieves the peer ID associated with a valid, non-expired lease token.
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
- `LNetworkRuntime:authCancel() -> nil`: Cancels the currently active authentication request.
- `LNetworkRuntime:getAuthStatus() -> string`: Returns the current active authentication status.
- `LNetworkRuntime:getAuthToken() -> string`: Returns the current active access token.
- `LNetworkRuntime:getMetrics() -> table`: Returns current network runtime metrics.
- `LNetworkRuntime:httpGet(url, headers?) -> integer`: Starts an HTTP GET request. This method is available to Lua scripts.
- `LNetworkRuntime:httpJson(url, body, headers?) -> integer`: Starts an HTTP POST request with a JSON-encoded body and Content-Type application/json.
- `LNetworkRuntime:httpPost(url, body, headers?) -> integer`: Starts an HTTP POST request. This method is available to Lua scripts.
- `LNetworkRuntime:httpRequest(opts) -> integer`: Starts an HTTP request from an options table and returns its request id.
- `LNetworkRuntime:httpStream(url, headers?, timeout_secs?) -> integer`: Starts an HTTP GET request intended for Server-Sent Events or streaming responses.
- `LNetworkRuntime:matchmakeCancel(id) -> nil`: Cancels a previously started matchmaking request.
- `LNetworkRuntime:matchmakeStart(url, payload) -> integer`: Starts a matchmaking request against the backend.
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

## References

- `runtime`: Imports runtime config from `src/runtime/`.

## Notes

- No additional module-specific notes.
