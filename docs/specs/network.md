<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/network.md or source docstrings instead. -->

# network

## TL;DR

- Manages ENet UDP hosts for small client/server or peer-hosted games.
- Coordinates LAN lobby discovery, room state, MessagePack payloads, RPC helpers, prediction, and snapshot sync.
- Does not provide web-service, streaming, auth, or SaaS matchmaking runtime APIs.

## General Info

- Module group: `Core Runtime`
- Source path: `src/network`
- Binding: `src/lua_api/network_api.rs`
- Namespace: `lurek.network`
- Lua API surface: `27` functions, `14` types, `34` methods
- User-facing: `true`
- Plugin tier: `tier_1_plugin`

## Summary

- The `network` module is the engine's small-game multiplayer surface for users who need direct IP or LAN-hosted sessions for roughly 8-16 players.
- ENet is the gameplay transport. It provides reliable and unreliable UDP channels, host/server/client roles, peer events, flushing, pinging, disconnects, stats, and metrics.
- LAN lobby and room helpers cover local coordination before gameplay packets flow: lobby advertisement/discovery, room creation, join/leave, readiness, room lookup, and player lists.
- MessagePack payload helpers keep gameplay messages compact and structured. Snapshot, prediction, reconciliation, net state, and RPC helpers are part of the same game-state exchange contract.
- Relay and punch helpers are lightweight string/payload helpers only. They do not create a built-in web relay client or internet matchmaking service inside `lurek.exe`.
- Web-service transports, streaming feeds, auth bootstrap, and SaaS-style matchmaking are intentionally outside the runtime network API. If a project needs internet services later, they should live in a separate service/tool while gameplay remains ENet-based.
- Read `network` as the engine feature for small multiplayer sessions, LAN discovery, and structured gameplay state exchange.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/network`
- Owning tier: `Core Runtime`
- Plugin tier: `tier_1_plugin`
- Lua binding owner: `src/lua_api/network_api.rs`
- Referenced engine modules: `runtime`

## Imports

- `runtime`: Imports or references `src/runtime/`. Dependency stays inside `Core Runtime` and should remain acyclic.

## Source Files

### constants.rs

- Owns the network constants implementation for the network subsystem and keeps related runtime rules local here.
- Keeps transport state, peers, and protocol-facing helpers so helpers stay close to invariants this file updates.
- Defines how network constants data is validated, transformed, or stored before neighboring systems consume it.

### error.rs

- This file owns the unified `NetworkError` enum used to surface IO, protocol, and address failures.
- It maps transport-specific problems into one error boundary so higher layers do not depend on backend details.
- Open it when network failure categories change; host state, runtime flow, and message codecs live elsewhere.

### host.rs

- Owns the network host implementation for the network subsystem and keeps related runtime rules local here.
- Keeps transport state, peers, and protocol-facing helpers so helpers stay close to invariants this file updates.
- Defines how network host data is validated, transformed, or stored before neighboring systems consume it.
- Separates network host behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where network code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing network host defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the network host state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping network host calculations explicit at their owning subsystem boundary.

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

- This module re-exports network surface for `constants.rs`, `error.rs`, `host.rs`, and `lobby.rs` and runtime helpers.
- It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
- Public exports here route callers toward `constants.rs`, `error.rs`, and `host.rs` first, while deeper behavior owners.
- Open this file when the public network symbol map moves; edit siblings when runtime rules themselves change.
- This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
- Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.

### net_sync.rs

- This file owns compact entity-snapshot and sync-snapshot models used for networked state replication.
- `EntitySnapshot` stores tick, position, and velocity, while `SyncSnapshot` encodes full, delta, and corrective syncs.
- NetValue conversion lives here because snapshot wire shape belongs with the replicated state contracts themselves.
- Prediction and reconciliation helpers also stay here because smoothing policy is part of sync semantics, not transport.
- The distance-based reconcile policy is local because soft and hard correction thresholds shape state convergence.
- Open it when replicated actor semantics change; hosts, sockets, and Lua netstate bindings live in siblings.

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
- `lurek.network.newServer(opts) -> LNetworkHost`: Creates a server host from an options table.
- `lurek.network.pack(value) -> string`: Packs a supported Lua value into a binary network message string.
- `lurek.network.packSnapshot(snapshot) -> string`: Packs a sync snapshot table into a binary network message string.
- `lurek.network.parsePunchProbe(payload) -> string`: Parses a relay punch probe payload.
- `lurek.network.parseRelayTicket(token) -> table`: Parses an encoded relay ticket. This function is exposed to Lua scripts.
- `lurek.network.predictLinear(snapshot, dt) -> table`: Predicts an entity snapshot forward by linear velocity.
- `lurek.network.reconcileSnapshot(pred, auth, alpha) -> table`: Reconciles a predicted snapshot toward an authoritative snapshot.
- `lurek.network.reconcileWithPolicy(pred, auth, alpha, soft_threshold, hard_threshold) -> table`: Reconciles a predicted snapshot toward an authoritative snapshot using a distance-based policy.
- `lurek.network.setReady(room_name, peer_id, ready) -> nil`: Marks a player as ready or not ready in a room.
- `lurek.network.syncEntity(host_ud, entity_id, data_tbl, channel?, reliable?) -> nil`: Broadcasts a packed entity sync payload through a network host.
- `lurek.network.unpack(data) -> table`: Unpacks a binary network message string into a Lua value.
- `lurek.network.unpackSnapshot(data) -> table`: Unpacks a binary network message string into a sync snapshot table.

### Callbacks

- No documented callback parameters in this module.

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

## Examples

- `content/examples/network.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
