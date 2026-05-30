# network

## TL;DR

- The `network` module provides multiplayer host networking and service communication in one stack: session transport, HTTP/WebSocket/SSE, relay tools, and sync helpers.

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Binding: `src/lua_api/network_api.rs`
- Namespace: `lurek.network`
- Lua API surface: `21` functions, `17` types, `49` methods
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua, tests/lua/unit/test_network_pack_unpack.lua, tests/lua/unit/test_network_roles.lua, tests/lua/unit/test_network_runtimer.lua, tests/lua/security/test_network_security.lua

## Summary

The `network` module is the communication backbone for connected gameplay and remote services. It combines multiplayer session transport and service-facing protocols in one runtime surface, so scripts do not need separate networking stacks for each use case.

Its practical design keeps blocking I/O off the frame-critical path. Background networking components handle transport work and return structured responses through channel-based flows, which helps maintain stable frame timing under real network latency.

For multiplayer sessions, the module provides host/client behavior, peer events, and message routing with consistent lifecycle signals. This gives gameplay code one predictable model for connection, disconnection, and payload handling.

Connectivity support extends beyond raw sockets. Discovery and relay helpers cover LAN lobby finding and NAT traversal signals, reducing friction when peers need to locate each other and establish playable connections.

State-sync helpers are included for replicated gameplay entities. Prediction and reconciliation utilities help keep local control responsive while still converging to authoritative state in networked play.

The same module also serves external integration needs through HTTP, WebSocket, and SSE workflows. This supports account services, telemetry streams, live control channels, and tool-side integrations without leaving the network namespace.

In practice, `lurek.network` provides one complete communication contract: host sessions, exchange messages, discover peers, sync state, and interact with remote services through a unified script-facing API.

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

### relay.rs

- Relay ticket encoding and decoding for room and peer identification.
- Builds UDP hole-punch probe payloads with a magic prefix.
- Provides lightweight helpers for relay-based NAT traversal signalling.

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

- `LSseStream:close`: Signals the background reader thread to stop and closes the stream.
- `LSseStream:isOpen`: Returns true if the background reader thread is still connected and reading.
- `LSseStream:next`: Polls for the next available event from the SSE stream (non-blocking).
- `LSseStream:type`: Returns the Lua-visible type name for this SSE stream handle.
- `LSseStream:typeOf`: Returns whether this SSE stream handle matches a supported type name.
