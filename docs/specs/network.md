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

- The `network` module is the engine's communication and session surface for users who need game state, tool messages, service calls, telemetry, or multiplayer traffic to move between processes or machines.
- Its scope is intentionally broad because real communication needs are broad. Raw TCP, HTTP-style requests, websockets, SSE-like streams, lobbies, host state, relays, RPC, sync structures, and worker-thread coordination all appear in one engine-facing family.
- That breadth is a practical advantage because projects often need several kinds of communication at once. A multiplayer game may also need service APIs, diagnostics channels, content downloads, and background coordination without wanting four unrelated networking stacks.
- Message and transport types are central to the contract because networking is not just about opening a socket; it is also about how payloads are described, routed, retried, synchronized, and surfaced to the rest of the engine.
- Session and host helpers matter because communication often begins before any gameplay packet is exchanged. Discovery, lobby state, connection negotiation, and participant tracking are all part of real multiplayer or remote-tool workflows.
- RPC-style and sync-oriented surfaces broaden the feature into structured state exchange, while background thread support keeps network activity off the main loop.
- This asynchronous model matters for responsiveness, retries, timeouts, and long-lived connections where the network layer must remain active even while other systems continue to update.
- HTTP, websocket, and streaming surfaces keep the module useful outside classic multiplayer for tooling, editor integrations, remote control, telemetry, and service-backed workflows.
- Error typing and connection-state tracking are equally valuable because networking only becomes usable at scale when disconnects, retries, and degraded states are visible rather than hidden in transport internals.
- The module is therefore useful for online play, local-network coordination, service-backed tools, live dashboards, remote assistants, telemetry sinks, and any feature that depends on structured communication beyond the current process.
- That breadth is one reason the subsystem belongs in the engine rather than in ad hoc project code.
- Domain modules define what should be exchanged, while `network` owns how those exchanges are carried, coordinated, monitored, and kept off the blocking path.
- Read `network` as the engine feature that turns remote communication into a reusable runtime capability.


## Imports

- `runtime`: Imports runtime config from `src/runtime/`.

## Files

### constants.rs

- This file owns shared numeric limits for peers, channels, timeouts, and socket buffer sizes in networking.
- It centralizes defaults such as `DEFAULT_PEERS`, `DEFAULT_CHANNELS`, and transport buffer capacities.
- Open it when protocol ceilings change; host logic, runtime polling, and message framing live in siblings.

### error.rs

- This file owns the unified `NetworkError` enum used to surface IO, protocol, address, and thread failures.
- It maps transport-specific problems into one error boundary so higher layers do not depend on backend details.
- Open it when network failure categories change; host state, runtime flow, and message codecs live elsewhere.

### host.rs

- This file owns the ENet host wrapper that binds one UDP socket and manages peer slots for a network endpoint.
- `NetworkHost` stores the inner ENet host, local address, host role, and reconnection leases for peer resumption.
- `HostRole`, `NetworkEvent`, `EnetLease`, and `PeerStats` live here because they describe host-owned peer lifecycle.
- Service, connect, send, broadcast, ping, and disconnect flows stay here because ENet peer control is this boundary.
- Lease registration and cleanup also belong here since reconnect tokens are indexed by peer ownership state.
- Bandwidth, channel, address, and connection metrics remain local because they report or tune host-level behavior.
- Server and client convenience constructors stay here because role assignment and binding strategy are host concerns.
- Open it when ENet peer ownership changes; lobbies, wire values, and background TCP or WebSocket workers do not.

### http.rs

- This file owns synchronous HTTP execution used by matchmaking, auth flows, and simple remote fetches.
- `HttpResponse` stores status, body, headers, and error text so callers receive one uniform completion payload.
- `execute_request` and its agent helper stay here because timeout, headers, and body dispatch are HTTP concerns.
- The file keeps network-runtime callers free from ureq details while still returning raw response bytes.
- Open it when blocking request behavior changes; sockets, lobbies, and background orchestration live elsewhere.

### lobby.rs

- This file owns LAN lobby discovery plus in-process room registries used for local multiplayer coordination.
- `LobbyInfo` handles UDP advertisement parsing, while `RoomInfo` and `RoomState` track join counts and players.
- Broadcast and discovery stay here because UDP room announcements are separate from ENet host or relay ownership.
- The basic and extended registries also belong here because create, join, leave, ready, and host election are room data.
- Player ready-state helpers remain local so pre-match coordination uses one authoritative room-state owner.
- Open it when room lifecycle changes; relay tokens, sockets, and background workers live in sibling files.

### message.rs

- This file owns the dynamic wire value format used to move Lua-like data across network transports.
- `NetValue` models nil, scalars, arrays, and maps, while `pack` and `unpack` convert that shape with MessagePack.
- Payload size and nesting guards stay here because transport-neutral framing safety belongs with the wire model.
- Open it when cross-peer value semantics change; sockets, hosts, and sync policies live in sibling files.

### mod.rs

- This module is the network index, exposing transports, host ownership, sync helpers, and background workers.
- It reexports only `SseEvent` and `SseStream`, while the rest of the surface stays partitioned by transport owner.
- `host.rs` owns ENet peers, `net_thread.rs` owns blocking IO workers, and `message.rs` owns portable wire values.
- `http.rs`, `tcp.rs`, `websocket.rs`, and `sse.rs` implement request or socket backends used by the runtime.
- `lobby.rs`, `relay.rs`, `rpc.rs`, `net_sync.rs`, and `netstate.rs` cover higher-level multiplayer coordination.
- Open this file to navigate subsystem boundaries; actual transport logic and state live in sibling modules.

### net_sync.rs

- This file owns compact entity-snapshot and sync-snapshot models used for networked state replication.
- `EntitySnapshot` stores tick, position, and velocity, while `SyncSnapshot` encodes full, delta, and corrective syncs.
- NetValue conversion lives here because snapshot wire shape belongs with the replicated state contracts themselves.
- Prediction and reconciliation helpers also stay here because smoothing policy is part of sync semantics, not transport.
- The distance-based reconcile policy is local because soft and hard correction thresholds shape state convergence.
- Open it when replicated actor semantics change; hosts, sockets, and Lua netstate bindings live in siblings.

### net_thread.rs

- This file owns the background network runtime that keeps blocking HTTP, TCP, and WebSocket work off the game loop.
- `NetworkRequest` and `NetworkResponse` define the typed command and completion protocol between threads.
- `TcpEvent` and `WsEvent` live here because the runtime normalizes lifecycle callbacks emitted by backend managers.
- `NetworkRuntime` stores the request sender, response receiver, join handle, ids, auth token, and activity counters.
- Public queue helpers stay here because request-id allocation and active-request accounting are runtime concerns.
- Thread startup and shutdown also belong here because this file owns the `lurek-network` worker thread lifecycle.
- Its event loop polls backend managers, drains requests, and drives auth refresh plus matchmaking polling state.
- `handle_request` remains local because it routes HTTP, TCP, WebSocket, auth, and matchmake commands.
- Auth and matchmake session structs stay here because they track transient runtime state between helper-thread callbacks.
- Metrics and access-token getters also belong here since they summarize live runtime status for callers.
- Open it when cross-thread networking flow changes; backend socket mechanics live in their sibling transport owners.

### netstat.rs

- This file owns a small network-statistics userdata that reports sent bytes, received bytes, and latency.
- `NetStat` stores the counters, while `register` publishes Lua constructors and mutation helpers under `lurek`.
- The file is a thin state carrier for scripting, not a transport implementation or runtime worker boundary.
- Open it when scripting metrics change; host telemetry and socket polling live in other network owners.

### netstate.rs

- This file owns the Rust userdata wrapper around the Lua netstate library used for replicated keyed game state.
- `LNetworkState` stores a registry key and forwards set, get, poll, turn, and callback methods into Lua tables.
- Registry access stays here because the lifetime boundary between Rust userdata and Lua netstate is this owner.
- It is a binding shim, not the sync algorithm itself, nor the transport runtime that delivers packets.
- Open it when Lua-facing state-sync methods change; snapshot policies and socket work live in siblings.

### relay.rs

- This file owns relay-ticket and punch-probe helpers used for room identity and simple NAT traversal signalling.
- `RelayTicket` plus encode, decode, and probe helpers stay here because they define the relay wire token shape.
- Open it when relay token formats change; lobbies, hosts, and background transport workers live in siblings.

### rpc.rs

- This file owns the Rust userdata wrapper around the Lua RPC manager used for remote function invocation.
- `LNetworkRpc` stores a registry key and forwards register, call, notify, broadcast, and timeout methods.
- Registry-table retrieval stays here because the Rust-to-Lua lifetime boundary is this file's core contract.
- It is a binding layer for RPC scripting, not the socket transport, host ownership, or auth runtime.
- Open it when Lua-facing RPC controls change; transport workers and wire values live in sibling modules.

### sse.rs

- This file owns long-lived Server-Sent Events readers that stream HTTP event feeds on a helper thread.
- `SseEvent` stores parsed id, event name, and data, while `SseStream` manages the channel and close flags.
- Connect-time thread spawning and line parsing stay here because SSE framing is distinct from request-response HTTP.
- Non-blocking `next` and blocking `collect` helpers also belong here as stream-consumption policies for callers.
- Drop-time shutdown is local because the reader thread lifecycle is part of owning one live SSE connection.
- Open it when event-stream behavior changes; standard HTTP requests and socket transports live in siblings.

### tcp.rs

- This file owns the non-blocking TCP connection pool used by the background network runtime thread.
- `TcpConnectionManager` stores live streams, handles connect and send, and polls all sockets round-robin.
- Lifecycle events are emitted through `NetworkResponse` because the manager reports data, closes, and errors only.
- Cleanup and missing-connection errors stay here since stream ownership belongs below the main runtime loop.
- Open it when TCP polling changes; request routing, WebSockets, and ENet host logic live in sibling files.

### websocket.rs

- This file owns the WebSocket connection pool used by the background runtime for framed duplex messaging.
- `WebSocketManager` stores live sockets and pending handshakes, while `PendingConnect` tracks helper-thread results.
- Connect-time worker spawning stays here because TLS handshakes and tungstenite setup must not block the game loop.
- Frame send, close, and poll logic also live here because text, binary, and close-event handling is backend-specific.
- Pending-connect promotion belongs here since open or error events are derived from handshake completion state.
- Open it when WebSocket lifecycle changes; request routing, TCP sockets, and message values live elsewhere.



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
