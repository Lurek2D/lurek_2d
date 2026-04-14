# network

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Lua API path(s): `src/lua_api/network_api.rs`
- Primary Lua namespace: `lurek.network`
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua, tests/lua/unit/test_network_pack_unpack.lua, tests/lua/unit/test_network_roles.lua, tests/lua/unit/test_network_runtime.lua, tests/lua/security/test_network_security.lua

## Summary

The network module is Lurek2D's full networking toolkit organised in three layers:

**Layer 1 — Transport (Rust)**: ENet reliable UDP (`host.rs`), HTTP client (`http.rs`), non-blocking TCP (`tcp.rs`), WebSocket client (`websocket.rs`), and MessagePack serialization (`message.rs`). Each transport is a standalone Rust module with no Lua dependency.

**Layer 2 — Game Protocol (Rust + Lua binding)**: `NetworkRuntime` (`net_thread.rs`) runs all async I/O on a dedicated `std::thread` with `mpsc` bridge. The Lua API (`network_api.rs`) exposes `newServer`, `newClient`, `newRuntime`, `pack`, `unpack`, and typed event polling. `HostRole` (Server/Client/Host) assigns a semantic role to ENet hosts.

**Layer 3 — Lunasome Libraries (pure Lua)**: `content/library/rpc/` (remote procedure calls), `content/library/lobby/` (room management), `content/library/netstate/` (state sync + turn-based). These consume only the `lurek.network` public API.

The module depends on `rusty_enet` (ENet UDP), `ureq` (HTTP), `tungstenite` (WebSocket), and `rmp-serde` (MessagePack). All non-ENet I/O runs on the background thread — the Lua VM never blocks.

**Scope boundary**: This module depends on `runtime`. It stays within the Core Runtime responsibility boundary. Matchmaking, rollback, prediction, and NAT traversal belong in higher-level Lua code or future modules.

## Files

- `constants.rs`: Compile-time limits and defaults (MAX_PEERS=4096, DEFAULT_PEERS=16, DEFAULT_CHANNELS=2, HTTP_TIMEOUT_SECS=30, TCP_BUFFER_SIZE=65536, WS_BUFFER_SIZE=65536).
- `error.rs`: `NetworkError` enum with variants: ConnectionFailed, SendFailed, InvalidPeer, InvalidAddress, Http, WebSocket, Tcp, Serialization, Thread.
- `host.rs`: ENet host wrapper with `HostRole` enum; factory methods `create_server`, `create_client`.
- `http.rs`: HTTP client via `ureq`. `HttpResponse` struct, `execute_request` function.
- `message.rs`: MessagePack serialization. `NetValue` enum, `pack`/`unpack` functions.
- `mod.rs`: Module root — declares all 8 sub-modules.
- `net_thread.rs`: Background I/O thread. `NetworkRuntime`, `NetworkRequest`, `NetworkResponse`, `TcpEvent`, `WsEvent`.
- `tcp.rs`: Non-blocking TCP with `TcpConnectionManager`.
- `websocket.rs`: WebSocket client with `WebSocketManager`.

## Types

- `NetworkError` (`enum`, `error.rs`): Errors for ENet, HTTP, TCP, WebSocket, serialization, and threading.
- `NetworkHost` (`struct`, `host.rs`): Wraps `rusty_enet::Host<UdpSocket>` with role and limit enforcement.
- `HostRole` (`enum`, `host.rs`): Server, Client, or Host (peer-to-peer).
- `NetworkEvent` (`enum`, `host.rs`): Result of a single `NetworkHost::service` call.
- `PeerStats` (`struct`, `host.rs`): Per-peer statistics snapshot.
- `HttpResponse` (`struct`, `http.rs`): HTTP response with status, body, headers, error.
- `NetValue` (`enum`, `message.rs`): Nil, Bool, Integer, Float, String, Array, Map — serializable Lua values.
- `NetworkRuntime` (`struct`, `net_thread.rs`): Background I/O thread with mpsc channel bridge.
- `NetworkRequest` (`enum`, `net_thread.rs`): HttpRequest, TcpConnect, TcpSend, TcpClose, WsConnect, WsSend, WsClose, Shutdown.
- `NetworkResponse` (`enum`, `net_thread.rs`): HttpResponse, TcpEvent, WebSocketEvent.
- `TcpEvent` (`enum`, `net_thread.rs`): Connected, Data, Disconnected, Error.
- `WsEvent` (`enum`, `net_thread.rs`): Open, Text, Binary, Close, Error.
- `TcpConnectionManager` (`struct`, `tcp.rs`): Manages multiple non-blocking TCP connections.
- `WebSocketManager` (`struct`, `websocket.rs`): Manages multiple WebSocket connections.

## Functions

### host.rs
- `NetworkHost::new`: Create a new ENet host bound to `bind_addr`.
- `NetworkHost::create_server`: Create a host bound to port with HostRole::Server.
- `NetworkHost::create_client`: Create a host, connect, and set HostRole::Client.
- `NetworkHost::role`: Get the current HostRole.
- `NetworkHost::set_role`: Override the HostRole.
- `NetworkHost::service`: Poll for one network event.
- `NetworkHost::connect`: Initiate a connection to a remote host.
- `NetworkHost::send` / `send_bytes`: Send data to a specific peer.
- `NetworkHost::broadcast` / `broadcast_bytes`: Broadcast to all connected peers.
- `NetworkHost::flush`: Flush all queued packets.
- `NetworkHost::disconnect` / `disconnect_now` / `disconnect_later` / `reset_peer`: Peer disconnect variants.
- `NetworkHost::ping` / `round_trip_time` / `peer_state` / `peer_address`: Peer inspection.
- `NetworkHost::local_address` / `peer_limit` / `channel_limit` / `set_channel_limit`: Host config.
- `NetworkHost::bandwidth_limit` / `set_bandwidth_limit` / `connected_peer_count` / `connected_peer_ids` / `peer_stats`: Stats and limits.
- `NetworkHost::destroy` / `is_destroyed`: Lifecycle.

### message.rs
- `pack(value: &NetValue) → Result<Vec<u8>>`: Serialize to MessagePack bytes.
- `unpack(data: &[u8]) → Result<NetValue>`: Deserialize from MessagePack bytes.
- `estimate_size(value: &NetValue) → usize`: Estimate serialized size.

### net_thread.rs
- `NetworkRuntime::new() → Result<Self, String>`: Spawn background I/O thread.
- `NetworkRuntime::send(request)`: Queue a request to the background thread.
- `NetworkRuntime::poll() → Vec<NetworkResponse>`: Drain completed responses.
- `NetworkRuntime::shutdown()`: Signal thread to stop and join.
- Convenience: `http_request`, `tcp_connect`, `tcp_send`, `tcp_close`, `ws_connect`, `ws_send`, `ws_close`.

### http.rs
- `execute_request(method, url, headers, body, timeout_secs) → HttpResponse`: Blocking HTTP call (runs on network thread).

### tcp.rs
- `TcpConnectionManager::connect` / `send` / `close` / `poll_all` / `close_all`: TCP connection management.

### websocket.rs
- `WebSocketManager::connect` / `send` / `close` / `poll_all` / `close_all`: WebSocket connection management.

## Lua API Reference

- Binding path(s): `src/lua_api/network_api.rs`
- Namespace: `lurek.network`

### Module Functions & Constants
- `lurek.network.MAX_PEERS`: Maximum supported peer slots (4096).
- `lurek.network.DEFAULT_PEERS`: Default peer-slot count (16).
- `lurek.network.MAX_CHANNELS`: Maximum ENet channels (255).
- `lurek.network.DEFAULT_CHANNELS`: Default channel count (2).
- `lurek.network.newHost(opts)`: Creates a raw ENet host.
- `lurek.network.newServer(opts)`: Creates a server host (role = "server"). `opts.port` required.
- `lurek.network.newClient(opts)`: Creates a client host (role = "client"). `opts.addr` required.
- `lurek.network.newRuntime()`: Creates a background I/O runtime with HTTP, TCP, WebSocket.
- `lurek.network.pack(value)`: Serialize a Lua value to MessagePack binary string.
- `lurek.network.unpack(data)`: Deserialize a MessagePack binary string to a Lua value.

### `NetworkHost` Methods
- `:service()` → event table or nil
- `:connect(addr, channels?, data?) → peer_id`
- `:send(peer_id, channel, data, reliable?)`
- `:broadcast(channel, data, reliable?)`
- `:flush()`
- `:disconnect(peer_id, data?)`
- `:disconnectNow(peer_id, data?)`
- `:disconnectLater(peer_id, data?)`
- `:resetPeer(peer_id)`
- `:ping(peer_id)`
- `:getRoundTripTime(peer_id) → ms`
- `:getPeerState(peer_id) → string`
- `:getPeerAddress(peer_id) → string|nil`
- `:getAddress() → string`
- `:getPeerLimit() → number`
- `:getChannelLimit() → number`
- `:setChannelLimit(n)`
- `:getBandwidthLimit() → {incoming, outgoing}`
- `:setBandwidthLimit(in?, out?)`
- `:getConnectedPeerCount() → number`
- `:getConnectedPeerIds() → table`
- `:getPeerStats(peer_id) → table`
- `:getRole() → "server"|"client"|"host"`
- `:isServer() → bool`
- `:isClient() → bool`
- `:destroy()`
- `:isDestroyed() → bool`

### `NetworkRuntime` Methods
- `:httpGet(url, headers?) → request_id`
- `:httpPost(url, body, headers?) → request_id`
- `:httpRequest(opts) → request_id` — opts: method, url, headers, body, timeout
- `:tcpConnect(addr) → connection_id`
- `:tcpSend(id, data)`
- `:tcpClose(id)`
- `:wsConnect(url) → connection_id`
- `:wsSend(id, data)`
- `:wsClose(id)`
- `:poll() → table` — array of event tables
- `:shutdown()`

### Poll Event Shapes
```lua
-- HTTP
{ type="http", request_id=1, status=200, body="...", headers={}, error=nil }

-- TCP
{ type="tcp", id=1, event="connected"|"data"|"disconnected"|"error", data="..." }

-- WebSocket
{ type="websocket", id=1, event="open"|"text"|"binary"|"close"|"error", data="..." }
```

## Lunasome Libraries

Three pure-Lua libraries in `content/library/` build on `lurek.network`:

- **`rpc`** — Remote procedure calls with register/call/notify/broadcast and request/response pattern.
- **`lobby`** — Room management with create/join/leave, player tracking, ready-check coordination.
- **`netstate`** — Authority-based state synchronization with change callbacks, delta sync, and turn-based game support.

## References

- `runtime`: Imports runtime config from `src/runtime/`.
- `rusty_enet`: ENet reliable UDP transport (Cargo dep).
- `ureq`: HTTP client (Cargo dep).
- `tungstenite`: WebSocket client (Cargo dep).
- `rmp-serde`: MessagePack serialization (Cargo dep).

## Notes

- All non-ENet I/O runs on the background `NetworkRuntime` thread — the Lua VM never blocks.
- `HostRole` is metadata only — it does not change ENet behaviour, just helps game code distinguish server from client.
- MessagePack pack/unpack supports Nil, Bool, Integer, Float, String, Array (sequential table), Map (string-keyed table). Functions and userdata cannot be serialized.
- Keep this module reference synchronized with `src/network/` and any matching Lua bindings.
