# Network

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

## Functions

### `lurek.network.createLobby`

Broadcasts lobby information and returns it as a table.

```lua
lurek.network.createLobby(name, port, player_count, max_players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Lobby name. |
| `port` | number | Lobby port. |
| `player_count?` | number | Optional current player count, defaulting to 1. |
| `max_players?` | number | Optional maximum players, defaulting to 8. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkCreateLobbyResult | Lobby info table. |

**Example**

```lua
do
    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    local found = lurek.network.discoverLobbies(200)
    print("lobby=" .. lobby.name .. ":" .. lobby.port)
    print("discovered=" .. #found)
end
```

---

### `lurek.network.createRoom`

Creates a local room record. This function is exposed to Lua scripts.

```lua
lurek.network.createRoom(name, host, max_players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Room name. |
| `host` | string | Host string. |
| `max_players?` | number | Optional maximum players, defaulting to 8. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkCreateRoomResult | Room info table. |

**Example**

```lua
do
    local room = lurek.network.createRoom("Arena", "player1", 8)
    local joined = lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    print("room_id=" .. room.id)
    print("players=" .. joined.player_count .. "->" .. left.player_count)
end
```

---

### `lurek.network.discoverLobbies`

Discovers broadcast lobbies. This function is exposed to Lua scripts.

```lua
lurek.network.discoverLobbies(timeout_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout_ms?` | number | Optional timeout in milliseconds, defaulting to 500. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkDiscoverLobbiesResult | Array table of lobby info tables. |

**Example**

```lua
do
    lurek.network.createLobby("Discovery", 7788, 1, 4)
    local lobbies = lurek.network.discoverLobbies(200)
    print("lobbies=" .. #lobbies)
    print("first_name=" .. tostring(lobbies[1] and lobbies[1].name or "nil"))
end
```

---

### `lurek.network.getPlayerList`

Returns list of peer IDs currently in a room.

```lua
lurek.network.getPlayerList(room_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_name` | string | Room name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of peer ID integers. |

**Example**

```lua
do
    lurek.network.setReady("match_room", 1, true)
    lurek.network.setReady("match_room", 3, true)
    lurek.network.setReady("match_room", 2, false)
    local players = lurek.network.getPlayerList("match_room")
    print("player_list_count=" .. #players)
    for i, pid in ipairs(players) do
        print("player_" .. i .. "=" .. pid)
    end
end
```

---

### `lurek.network.getRoom`

Returns room metadata including host peer and player count.

```lua
lurek.network.getRoom(room_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_name` | string | Room name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Room metadata table with fields: `name`, `host_peer`, `max_players`, `player_count`. |

**Example**

```lua
do
    lurek.network.setReady("session_room", 1, true)
    lurek.network.setReady("session_room", 2, false)
    local room = lurek.network.getRoom("session_room")
    print("room_name=" .. room.name)
    print("room_host=" .. room.host_peer)
    print("room_players=" .. room.player_count)
end
```

---

### `lurek.network.isAllReady`

Checks if all players in a room are ready. Requires at least 2 players.

```lua
lurek.network.isAllReady(room_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_name` | string | Room name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if all players are ready and count >= 2. |

**Example**

```lua
do
    lurek.network.setReady("lobby_room", 1, true)
    lurek.network.setReady("lobby_room", 2, true)
    local all_ready = lurek.network.isAllReady("lobby_room")
    print("all_ready=" .. tostring(all_ready))
end
```

---

### `lurek.network.joinRoom`

Joins a room by id when available. This function is exposed to Lua scripts.

```lua
lurek.network.joinRoom(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Room id. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkJoinRoomResult | Room info table, or nil when missing. |

**Example**

```lua
do
    local room = lurek.network.createRoom("Joinable", "host-B", 4)
    local joined = lurek.network.joinRoom(room.id)
    print("room_id=" .. room.id)
    print("player_count=" .. joined.player_count)
end
```

---

### `lurek.network.leaveRoom`

Leaves a room by id when available. This function is exposed to Lua scripts.

```lua
lurek.network.leaveRoom(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Room id. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkLeaveRoomResult | Room info table, or nil when missing. |

**Example**

```lua
do
    local room = lurek.network.createRoom("Leavable", "host-C", 4)
    lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    print("room_id=" .. room.id)
    print("player_count=" .. left.player_count)
end
```

---

### `lurek.network.listRooms`

Lists known local room records. This function is exposed to Lua scripts.

```lua
lurek.network.listRooms()
```

**Returns**

| Type | Description |
|------|-------------|
| LNetworkListRoomsResult | Array table of room info tables. |

**Example**

```lua
do
    local rooms = lurek.network.listRooms()
    local room = lurek.network.createRoom("Listed", "host-D", 3)
    rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    print("last_room=" .. room.name)
end
```

---

### `lurek.network.makePunchProbe`

Creates a relay punch probe payload for a peer id.

```lua
lurek.network.makePunchProbe(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | string | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Probe payload. |

**Example**

```lua
do
    local probe = lurek.network.makePunchProbe("peer_99")
    local peer_id = lurek.network.parsePunchProbe(probe)
    print("probe_bytes=" .. #probe)
    print("peer_id=" .. tostring(peer_id))
end
```

---

### `lurek.network.newClient`

Creates a client host and connects to an address.

```lua
lurek.network.newClient(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options with required `addr`, optional `channels`, and `data`. |

**Returns**

| Type | Description |
|------|-------------|
| [LNetworkHost](#lnetworkhost) | New client host handle. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7778, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7778", channels = 2, data = 21})
    print("role=" .. client:getRole())
    print("type=" .. client:type())
    client:destroy()
    server:destroy()
end
```

---

### `lurek.network.newHost`

Creates a network host from an options table.

```lua
lurek.network.newHost(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options with `addr`, optional `maxPeers`/`peers`, `channels`, `inBandwidth`, and `outBandwidth`. |

**Returns**

| Type | Description |
|------|-------------|
| [LNetworkHost](#lnetworkhost) | New network host handle. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    print("address=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end
```

---

### `lurek.network.newNetState`

Creates a network state synchronization manager.

```lua
lurek.network.newNetState(host, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `host?` | [LNetworkHost](#lnetworkhost) | Network host for state transport, or nil for offline mode. |
| `opts?` | table | Configuration table with `channel`, `authority`, `turnBased`, `maxDirtyKeys`. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkState | New state manager handle. |

**Example**

```lua
do
    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, state = pcall(function()
        return lurek.network.newNetState(host, { authority = true })
    end)
    print("newNetState ok=" .. tostring(ok))
    if ok then
        state:set("player_x", 100)
        state:set("player_y", 50)

        local x = state:get("player_x")
        print("player_x=" .. x)

        state:onChange("player_x", function(value, old_value, peer_id)
            print("player_x changed from " .. tostring(old_value) .. " to " .. tostring(value))
        end)

        local all_state = state:getAll()
        print("state_keys=" .. #all_state)

        state:poll()
    end

    host:destroy()
end
```

---

### `lurek.network.newRelayTicket`

Creates an encoded relay ticket. This function is exposed to Lua scripts.

```lua
lurek.network.newRelayTicket(room_id, peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_id` | string | Room id. |
| `peer_id` | string | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded relay ticket. |

**Example**

```lua
do
    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    local ticket = lurek.network.parseRelayTicket(token)
    print("ticket=" .. token)
    print("peer_id=" .. ticket.peer_id)
end
```

---

### `lurek.network.newRpc`

Creates a network RPC manager attached to a host.

```lua
lurek.network.newRpc(host, channel, timeout_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `host` | [LNetworkHost](#lnetworkhost) | Network host for RPC transport. |
| `channel?` | number | Optional ENet channel for RPC traffic, defaults to 0. |
| `timeout_ms?` | number | Optional timeout in milliseconds for pending calls, defaults to 30s. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkRpc | New RPC manager handle. |

**Example**

```lua
do
    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, rpc = pcall(function()
        return lurek.network.newRpc(host, 0, 30.0)
    end)
    print("newRpc ok=" .. tostring(ok))
    if ok then
        rpc:register("ping", function(peer_id)
            return "pong"
        end)
        local responses = rpc:poll()
        print("rpc_responses=" .. #responses)
    end
end
```

---

### `lurek.network.newRuntime`

Creates a background network runtime.

```lua
lurek.network.newRuntime()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNetworkRuntime](#lnetworkruntime) | New network runtime handle. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("type=" .. rt:type())
    print("typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end
```

---

### `lurek.network.newServer`

Creates a server host from an options table.

```lua
lurek.network.newServer(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options with required `port`, optional `maxPeers`/`peers`, and `channels`. |

**Returns**

| Type | Description |
|------|-------------|
| [LNetworkHost](#lnetworkhost) | New server host handle. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    print("role=" .. server:getRole())
    print("peer_limit=" .. server:getPeerLimit())
    server:destroy()
end
```

---

### `lurek.network.pack`

Packs a supported Lua value into a binary network message string.

```lua
lurek.network.pack(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Lua value to pack (table, number, string, or boolean). |

**Returns**

| Type | Description |
|------|-------------|
| string | Binary packed message. |

**Example**

```lua
do
    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    local unpacked = lurek.network.unpack(packed)
    print("packed_bytes=" .. #packed)
    print("unpacked_name=" .. unpacked.name)
end
```

---

### `lurek.network.packSnapshot`

Packs a sync snapshot table into a binary network message string.

```lua
lurek.network.packSnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Sync snapshot table. |

**Returns**

| Type | Description |
|------|-------------|
| string | Binary packed snapshot. |

**Example**

```lua
do
    local snapshot = {
        type = "full",
        tick = 100,
        entities = {
            { id = 1, tick = 100, x = 10.0, y = 20.0, vx = 1.0, vy = 0.0 }
        }
    }
    local packed = lurek.network.packSnapshot(snapshot)
    print("packed_snapshot_bytes=" .. #packed)
end
```

---

### `lurek.network.parsePunchProbe`

Parses a relay punch probe payload.

```lua
lurek.network.parsePunchProbe(payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `payload` | string | Probe payload. |

**Returns**

| Type | Description |
|------|-------------|
| string | Parsed peer id, or nil when invalid. |

**Example**

```lua
do
    local probe = lurek.network.makePunchProbe("peer_parse")
    local peer_id = lurek.network.parsePunchProbe(probe)
    print("peer_id=" .. tostring(peer_id))
end
```

---

### `lurek.network.parseRelayTicket`

Parses an encoded relay ticket. This function is exposed to Lua scripts.

```lua
lurek.network.parseRelayTicket(token)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `token` | string | Encoded relay ticket. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkParseRelayTicketResult | Ticket table, or nil when invalid. |

**Example**

```lua
do
    local token = lurek.network.newRelayTicket("room_parse", "peer_parse")
    local ticket = lurek.network.parseRelayTicket(token)
    print("room_id=" .. ticket.room_id)
    print("peer_id=" .. ticket.peer_id)
end
```

---

### `lurek.network.predictLinear`

Predicts an entity snapshot forward by linear velocity.

```lua
lurek.network.predictLinear(snapshot, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Snapshot table with `id`, `tick`, `x`, `y`, `vx`, and `vy`. |
| `dt` | number | Prediction delta time. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkPredictLinearResult | Predicted snapshot table. |

**Example**

```lua
do
    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    print("tick=" .. predicted.tick)
    print("x=" .. predicted.x)
end
```

---

### `lurek.network.reconcileSnapshot`

Reconciles a predicted snapshot toward an authoritative snapshot.

```lua
lurek.network.reconcileSnapshot(pred, auth, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pred` | table | Predicted snapshot table. |
| `auth` | table | Authoritative snapshot table. |
| `alpha` | number | Blend factor. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkReconcileSnapshotResult | Reconciled snapshot table. |

**Example**

```lua
do
    local pred = {id = 3, tick = 20, x = 10, y = 10, vx = 1, vy = 0}
    local auth = {id = 3, tick = 21, x = 12, y = 11, vx = 1, vy = 0}
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    print("tick=" .. result.tick)
    print("x=" .. result.x)
end
```

---

### `lurek.network.reconcileWithPolicy`

Reconciles a predicted snapshot toward an authoritative snapshot using a distance-based policy.

```lua
lurek.network.reconcileWithPolicy(pred, auth, alpha, soft_threshold, hard_threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pred` | table | Predicted snapshot table. |
| `auth` | table | Authoritative snapshot table. |
| `alpha` | number | Blend factor. |
| `soft_threshold` | number | Distance threshold below which no correction is made. |
| `hard_threshold` | number | Distance threshold above which a hard snap occurs. |

**Returns**

| Type | Description |
|------|-------------|
| table | Reconciled snapshot table. |

**Example**

```lua
do
    local pred = { id = 1, tick = 10, x = 10.0, y = 0.0, vx = 0.0, vy = 0.0 }
    local auth = { id = 1, tick = 10, x = 12.0, y = 0.0, vx = 1.0, vy = 2.0 }
    local result = lurek.network.reconcileWithPolicy(pred, auth, 0.5, 0.2, 5.0)
    print("reconciled_x=" .. result.x)
end
```

---

### `lurek.network.setReady`

Marks a player as ready or not ready in a room.

```lua
lurek.network.setReady(room_name, peer_id, ready)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_name` | string | Room name. |
| `peer_id` | number | Peer identifier. |
| `ready` | boolean | True to mark as ready, false to unmark. |

**Example**

```lua
do
    lurek.network.setReady("game_room", 1, true)
    lurek.network.setReady("game_room", 2, false)
    print("set_player_1_ready=true")
    print("set_player_2_ready=false")
end
```

---

### `lurek.network.sseCollect`

Blocking helper: collects up to `n` events from a fresh SSE connection or until `timeout_secs` elapses.

```lua
lurek.network.sseCollect(url, n, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | SSE endpoint URL. |
| `n` | number | Maximum number of events to collect. |
| `timeout_secs?` | number | Optional timeout in seconds; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of event tables `{ id?, event?, data }`. |

**Example**

```lua
do
    local events = lurek.network.sseCollect("http://127.0.0.1:9999/events", 10, 2.0)
    for _, ev in ipairs(events) do
        print("collected: " .. ev.data)
    end
end
```

---

### `lurek.network.sseConnect`

Opens an SSE stream to `url` and returns an `[LSseStream](#lssestream)` handle.

```lua
lurek.network.sseConnect(url, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | SSE endpoint URL. |
| `callback` | function | Called with each event table `{ id?, event?, data }`. |

**Returns**

| Type | Description |
|------|-------------|
| [LSseStream](#lssestream) | Stream handle for polling or closing. |

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(ev)
        print("event=" .. tostring(ev.event) .. " data=" .. ev.data)
    end)
    -- Poll for events each frame; close when done.
    local ev = stream:next()
    if ev then
        print("got event: " .. ev.data)
    end
    stream:close()
end
```

---

### `lurek.network.syncEntity`

Broadcasts a packed entity sync payload through a network host.

```lua
lurek.network.syncEntity(host_ud, entity_id, data_tbl, channel, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `host_ud` | [LNetworkHost](#lnetworkhost) | Network host handle. |
| `entity_id` | number | Entity id. |
| `data_tbl` | table | Entity field table. |
| `channel?` | number | Optional channel id, defaulting to 0. |
| `reliable?` | boolean | Optional reliable flag, defaulting to false. |

**Example**

```lua
do
    local server, client = connect_pair(7797, 2)
    lurek.network.syncEntity(server, 1, {x = 100, y = 200, hp = 50}, 0, true)
    server:flush()
    local event = wait_for_event(client, "receive")
    local payload = lurek.network.unpack(event.data)
    print("entity_id=" .. payload.id)
    print("hp=" .. payload.data.hp)
    client:destroy()
    server:destroy()
end
```

---

### `lurek.network.unpack`

Unpacks a binary network message string into a Lua value.

```lua
lurek.network.unpack(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Binary packed message. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkUnpackResult | Unpacked Lua value. |

**Example**

```lua
do
    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    print("id=" .. msg.id)
    print("data=" .. msg.data)
end
```

---

### `lurek.network.unpackSnapshot`

Unpacks a binary network message string into a sync snapshot table.

```lua
lurek.network.unpackSnapshot(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Binary packed snapshot. |

**Returns**

| Type | Description |
|------|-------------|
| table | Unpacked sync snapshot table. |

**Example**

```lua
do
    local snapshot = {
        type = "delta",
        tick = 101,
        base_tick = 100,
        updates = {
            { id = 1, tick = 101, x = 11.0, y = 20.0, vx = 1.0, vy = 0.0 }
        },
        removals = { 2 }
    }
    local packed = lurek.network.packSnapshot(snapshot)
    local unpacked = lurek.network.unpackSnapshot(packed)
    print("unpacked_type=" .. unpacked.type)
    print("unpacked_tick=" .. unpacked.tick)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.network.sseConnect` param `callback` (`function`): Called with each event table `{ id?, event?, data }`.

## Enums

*No module-specific enums documented.*

## Types

- [LNetworkHost](#lnetworkhost)
- [LNetworkRuntime](#lnetworkruntime)
- [LSseStream](#lssestream)

## LNetworkHost

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNetworkHost:broadcast`

Broadcasts bytes to all connected peers on a channel.

```lua
LNetworkHost:broadcast(channel_id, data, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel_id` | number | Channel id. |
| `data` | string | Binary payload string. |
| `reliable?` | boolean | Optional reliable flag, defaulting to true. |

**Example**

```lua
do
    local server, client = connect_pair(7782, 2)
    server:broadcast(1, "state:update", true)
    server:flush()
    local event = wait_for_event(client, "receive")
    print("channel=" .. tostring(event and event.channel_id or "nil"))
    print("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:clearLease`

Removes a lease token immediately.

```lua
LNetworkHost:clearLease(token)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `token` | number | Reconnection token. |

**Example**

```lua
do
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(4, 30)
    host:clearLease(token)
    print("cleared lease: " .. tostring(host:getLeasePeer(token) == nil))
    host:destroy()
end
```

---

#### `LNetworkHost:connect`

Connects to a remote address. This method is available to Lua scripts.

```lua
LNetworkHost:connect(addr_str, channels, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `addr_str` | string | Remote socket address. |
| `channels?` | number | Optional channel count, defaulting to 1. |
| `data?` | number | Optional connection data, defaulting to 0. |

**Returns**

| Type | Description |
|------|-------------|
| number | Peer id. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7779, maxPeers = 4, channels = 2})
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1, channels = 2})
    local peer_id = host:connect("127.0.0.1:7779", 2, 17)
    local event = wait_for_event(server, "connect")
    print("peer_id=" .. peer_id)
    print("server_event=" .. tostring(event and event.type or "nil"))
    host:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:destroy`

Destroys the network host and releases resources.

```lua
LNetworkHost:destroy()
```

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("before=" .. tostring(host:isDestroyed()))
    host:destroy()
    print("after=" .. tostring(host:isDestroyed()))
end
```

---

#### `LNetworkHost:disconnect`

Requests a graceful peer disconnect.

```lua
LNetworkHost:disconnect(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |
| `data?` | number | Optional disconnect data. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7791, 2)
    server:disconnect(server_connect.peer_id, 7)
    server:flush()
    local event = wait_for_event(client, "disconnect")
    print("event_type=" .. tostring(event and event.type or "nil"))
    print("data=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:disconnectLater`

Schedules a peer disconnect after pending packets.

```lua
LNetworkHost:disconnectLater(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |
| `data?` | number | Optional disconnect data. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7792, 2)
    server:send(server_connect.peer_id, 0, "queued-goodbye", true)
    server:disconnectLater(server_connect.peer_id, 8)
    server:flush()
    local receive = wait_for_event(client, "receive")
    local disconnect = wait_for_event(client, "disconnect")
    print("payload=" .. tostring(receive and receive.data or "nil"))
    print("disconnect_data=" .. tostring(disconnect and disconnect.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:disconnectNow`

Disconnects a peer immediately. This method is available to Lua scripts.

```lua
LNetworkHost:disconnectNow(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |
| `data?` | number | Optional disconnect data. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7793, 2)
    server:disconnectNow(server_connect.peer_id, 9)
    server:flush()
    local event = wait_for_event(client, "disconnect")
    print("event_type=" .. tostring(event and event.type or "nil"))
    print("data=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:flush`

Flushes queued outgoing network packets.

```lua
LNetworkHost:flush()
```

**Example**

```lua
do
    local server, client, _, client_connect = connect_pair(7794, 2)
    client:send(client_connect.peer_id, 0, "flush-check", true)
    client:flush()
    local event = wait_for_event(server, "receive")
    print("event_type=" .. tostring(event and event.type or "nil"))
    print("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getAddress`

Returns local host socket address.

```lua
LNetworkHost:getAddress()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Local socket address. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("addr=" .. host:getAddress())
    host:destroy()
end
```

---

#### `LNetworkHost:getBandwidthLimit`

Returns incoming and outgoing bandwidth limits.

```lua
LNetworkHost:getBandwidthLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| LNetworkHostGetBandwidthLimitResult | Table with `incoming` and `outgoing` fields. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7789, maxPeers = 4})
    server:setBandwidthLimit(64000, 32000)
    local bw = server:getBandwidthLimit()
    print("bw_in=" .. tostring(bw.incoming))
    print("bw_out=" .. tostring(bw.outgoing))
    server:destroy()
end
```

---

#### `LNetworkHost:getChannelLimit`

Returns configured channel limit.

```lua
LNetworkHost:getChannelLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Channel limit. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end
```

---

#### `LNetworkHost:getConnectedPeerCount`

Returns the number of currently connected peers.

```lua
LNetworkHost:getConnectedPeerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Connected peer count. |

**Example**

```lua
do
    local server, client = connect_pair(7783, 2)
    print("connected=" .. server:getConnectedPeerCount())
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getConnectedPeerIds`

Returns an array of ids for all connected peers.

```lua
LNetworkHost:getConnectedPeerIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of peer ids. |

**Example**

```lua
do
    local server, client = connect_pair(7784, 2)
    local ids = server:getConnectedPeerIds()
    print("peer_count=" .. #ids)
    print("first_peer=" .. tostring(ids[1]))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getLeasePeer`

Retrieves the peer ID associated with a valid, non-expired lease token.

```lua
LNetworkHost:getLeasePeer(token)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `token` | number | Reconnection token. |

**Returns**

| Type | Description |
|------|-------------|
| number? | Original Peer ID or nil if invalid/expired. |

**Example**

```lua
do
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(2, 30)
    local peer_id = host:getLeasePeer(token)
    print("lease peer: " .. tostring(peer_id))
    host:destroy()
end
```

---

#### `LNetworkHost:getMetrics`

Returns global network host metrics.

```lua
LNetworkHost:getMetrics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Metrics table with connected_peers, average_rtt, average_packet_loss, total_packets_sent, total_packets_lost. |

**Example**

```lua
do
    local host = lurek.network.newHost({ port = 0 })
    local metrics = host:getMetrics()
    print("host peers: " .. tostring(metrics.connected_peers))
    host:destroy()
end
```

---

#### `LNetworkHost:getPeerAddress`

Returns peer socket address when available.

```lua
LNetworkHost:getPeerAddress(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Peer address, or nil when unavailable. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7786, 2)
    print("peer_addr=" .. tostring(server:getPeerAddress(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getPeerLimit`

Returns configured peer limit. This method is available to Lua scripts.

```lua
LNetworkHost:getPeerLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Peer limit. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("peer_limit=" .. host:getPeerLimit())
    host:destroy()
end
```

---

#### `LNetworkHost:getPeerState`

Returns peer connection state. This method is available to Lua scripts.

```lua
LNetworkHost:getPeerState(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Peer state string. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7785, 2)
    print("peer_state=" .. server:getPeerState(server_connect.peer_id))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getPeerStats`

Returns statistics for a peer. This method is available to Lua scripts.

```lua
LNetworkHost:getPeerStats(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| LNetworkHostGetPeerStatsResult | Peer statistics table. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7788, 2)
    local stats = server:getPeerStats(server_connect.peer_id)
    print("packets_sent=" .. stats.packets_sent)
    print("rtt_ms=" .. stats.round_trip_time)
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:getRole`

Returns host role string. This method is available to Lua scripts.

```lua
LNetworkHost:getRole()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Role string. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("role=" .. host:getRole())
    host:destroy()
end
```

---

#### `LNetworkHost:getRoundTripTime`

Returns peer round trip time in milliseconds.

```lua
LNetworkHost:getRoundTripTime(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Round trip time in milliseconds. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7787, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    print("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:isClient`

Returns whether this host has client role.

```lua
LNetworkHost:isClient()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when role is client. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7798, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7798", channels = 2})
    print("is_client=" .. tostring(client:isClient()))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:isDestroyed`

Returns whether the network host is destroyed.

```lua
LNetworkHost:isDestroyed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when destroyed. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    host:destroy()
end
```

---

#### `LNetworkHost:isServer`

Returns whether this host has server role.

```lua
LNetworkHost:isServer()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when role is server. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7799, maxPeers = 4, channels = 2})
    print("is_server=" .. tostring(server:isServer()))
    server:destroy()
end
```

---

#### `LNetworkHost:ping`

Sends a ping to a peer. This method is available to Lua scripts.

```lua
LNetworkHost:ping(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7795, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    print("peer_state=" .. server:getPeerState(server_connect.peer_id))
    print("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:registerLease`

Registers a reconnection lease for the given peer ID.

```lua
LNetworkHost:registerLease(peer_id, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer ID. |
| `timeout_secs` | number | Lease duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| number | Reconnection token. |

**Example**

```lua
do
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(1, 30)
    print("registered lease token: " .. tostring(token))
    host:destroy()
end
```

---

#### `LNetworkHost:renewLease`

Renews an active lease token with a new duration.

```lua
LNetworkHost:renewLease(token, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `token` | number | Reconnection token. |
| `timeout_secs` | number | New lease duration in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if successfully renewed, false otherwise. |

**Example**

```lua
do
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(3, 30)
    local success = host:renewLease(token, 60)
    print("lease renew: " .. tostring(success))
    host:destroy()
end
```

---

#### `LNetworkHost:resetPeer`

Resets a peer connection. This method is available to Lua scripts.

```lua
LNetworkHost:resetPeer(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7796, 2)
    server:resetPeer(server_connect.peer_id)
    server:service()
    client:service()
    print("reset_peer=" .. server_connect.peer_id)
    print("connected=" .. server:getConnectedPeerCount())
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:send`

Sends bytes to a peer on a channel. This method is available to Lua scripts.

```lua
LNetworkHost:send(peer_id, channel_id, data, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | number | Peer id. |
| `channel_id` | number | Channel id. |
| `data` | string | Binary payload string. |
| `reliable?` | boolean | Optional reliable flag, defaulting to true. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7781, 2)
    server:send(server_connect.peer_id, 0, "welcome", true)
    server:flush()
    local event = wait_for_event(client, "receive")
    print("event_type=" .. tostring(event and event.type or "nil"))
    print("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:service`

Polls the host for one network event.

```lua
LNetworkHost:service()
```

**Returns**

| Type | Description |
|------|-------------|
| LNetworkHostServiceResult | Event table, or nil when no event is available. |

**Example**

```lua
do
    local server, client, server_connect = connect_pair(7780, 2)
    print("event_type=" .. tostring(server_connect and server_connect.type or "nil"))
    print("peer_id=" .. tostring(server_connect and server_connect.peer_id or "nil"))
    client:destroy()
    server:destroy()
end
```

---

#### `LNetworkHost:setBandwidthLimit`

Sets incoming and outgoing bandwidth limits.

```lua
LNetworkHost:setBandwidthLimit(incoming, outgoing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `incoming?` | number | Optional incoming bandwidth limit. |
| `outgoing?` | number | Optional outgoing bandwidth limit. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    local limits = server:getBandwidthLimit()
    print("incoming=" .. tostring(limits.incoming))
    print("outgoing=" .. tostring(limits.outgoing))
    server:destroy()
end
```

---

#### `LNetworkHost:setChannelLimit`

Sets channel limit. This method is available to Lua scripts.

```lua
LNetworkHost:setChannelLimit(limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `limit` | number | Channel limit. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:7790", maxPeers = 2, channels = 1})
    host:setChannelLimit(4)
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end
```

---

#### `LNetworkHost:type`

Returns the Lua-visible type name for this network host handle.

```lua
LNetworkHost:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNetworkHost](#lnetworkhost)`. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("type=" .. host:type())
    host:destroy()
end
```

---

#### `LNetworkHost:typeOf`

Returns whether this network host handle matches a supported type name.

```lua
LNetworkHost:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNetworkHost](#lnetworkhost)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end
```

---

## LNetworkRuntime

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNetworkRuntime:authBootstrap`

Start authenticating with a backend.

```lua
LNetworkRuntime:authBootstrap(auth_url, payload, refresh_url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `auth_url` | string | Authentication URL. |
| `payload` | string | JSON payload. |
| `refresh_url` | string | Refresh URL. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local ok, id = pcall(function()
        return rt:authBootstrap("http://localhost:8080/auth", '{"user":"test"}', "http://localhost:8080/refresh")
    end)
    print("auth ok: " .. tostring(ok))
    print("auth id: " .. tostring(id))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:authCancel`

Cancels active authentication.

```lua
LNetworkRuntime:authCancel()
```

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    rt:authCancel()
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:getAuthStatus`

Returns the current active authentication status.

```lua
LNetworkRuntime:getAuthStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current status ("unauthenticated", "authenticating", "authenticated", "failed"). |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local status = rt:getAuthStatus()
    print("status: " .. tostring(status))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:getAuthToken`

Returns the current active access token.

```lua
LNetworkRuntime:getAuthToken()
```

**Returns**

| Type | Description |
|------|-------------|
| string? | Access token or nil if unauthenticated. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local token = rt:getAuthToken()
    print("token: " .. tostring(token))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:getMetrics`

Returns network runtime metrics.

```lua
LNetworkRuntime:getMetrics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Metrics table with queue_size, reconnect_count, http_active_count, tcp_active_count, ws_active_count. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local metrics = rt:getMetrics()
    print("queue size: " .. tostring(metrics.queue_size))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:httpGet`

Starts an HTTP GET request. This method is available to Lua scripts.

```lua
LNetworkRuntime:httpGet(url, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Request URL. |
| `headers?` | table | Optional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpGet("http://127.0.0.1:1/status", {Accept = "text/plain"})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:httpJson`

Starts an HTTP POST request with a JSON-encoded body and Content-Type application/json.

```lua
LNetworkRuntime:httpJson(url, body, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Request URL. |
| `body` | string | JSON string to send as the request body. |
| `headers?` | table | Optional additional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local ok, response = pcall(function()
        return rt:httpJson("http://localhost:8080/api", '{"key":"value"}')
    end)
    print("httpJson ok: " .. tostring(ok))
    print("httpJson response: " .. tostring(response))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:httpPost`

Starts an HTTP POST request. This method is available to Lua scripts.

```lua
LNetworkRuntime:httpPost(url, body, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Request URL. |
| `body` | string | Request body. |
| `headers?` | table | Optional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpPost("http://127.0.0.1:1/data", '{"key":"value"}', {["Content-Type"] = "application/json"})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:httpRequest`

Starts an HTTP request from an options table and returns its request id.

```lua
LNetworkRuntime:httpRequest(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options table with `url`, optional `method`, `headers`, `body`, and `timeout`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpRequest({url = "http://127.0.0.1:1/resource", method = "PUT", body = "updated data", timeout = 5})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:httpStream`

Starts an HTTP GET request intended for Server-Sent Events or streaming responses.

```lua
LNetworkRuntime:httpStream(url, headers, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Request URL. |
| `headers?` | table | Optional headers table. |
| `timeout_secs?` | number | Optional timeout override in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local ok, response = pcall(function()
        return rt:httpStream("http://localhost:8080/stream")
    end)
    print("httpStream ok: " .. tostring(ok))
    print("httpStream response: " .. tostring(response))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:matchmakeCancel`

Cancel matchmaking request.

```lua
LNetworkRuntime:matchmakeCancel(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    rt:matchmakeCancel(1)
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:matchmakeStart`

Start matchmaking request.

```lua
LNetworkRuntime:matchmakeStart(url, payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Matchmaker URL. |
| `payload` | string | JSON payload. |

**Returns**

| Type | Description |
|------|-------------|
| number | Request id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local ok, id = pcall(function()
        return rt:matchmakeStart("http://localhost:8080/match", '{"game_mode":"ranked"}')
    end)
    print("matchmake ok: " .. tostring(ok))
    print("matchmake id: " .. tostring(id))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:poll`

Polls runtime responses for HTTP, TCP, and WebSocket operations.

```lua
LNetworkRuntime:poll()
```

**Returns**

| Type | Description |
|------|-------------|
| LNetworkRuntimePollResult | Array table of response/event tables. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    rt:httpGet("http://127.0.0.1:1/poll")
    local events = rt:poll()
    print("events=" .. #events)
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:shutdown`

Shuts down the network runtime and cancels pending requests.

```lua
LNetworkRuntime:shutdown()
```

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    rt:shutdown()
    print("shutdown=true")
end
```

---

#### `LNetworkRuntime:tcpClose`

Closes a TCP connection. This method is available to Lua scripts.

```lua
LNetworkRuntime:tcpClose(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Connection id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpClose(id)
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:tcpConnect`

Opens a TCP connection. This method is available to Lua scripts.

```lua
LNetworkRuntime:tcpConnect(addr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `addr` | string | Remote address. |

**Returns**

| Type | Description |
|------|-------------|
| number | Connection id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:tcpSend`

Sends bytes over a TCP connection. This method is available to Lua scripts.

```lua
LNetworkRuntime:tcpSend(id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Connection id. |
| `data` | string | Binary payload string. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpSend(id, "PING\n")
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:type`

Returns the Lua-visible type name for this network runtime handle.

```lua
LNetworkRuntime:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNetworkRuntime](#lnetworkruntime)`. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:typeOf`

Returns whether this network runtime handle matches a supported type name.

```lua
LNetworkRuntime:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNetworkRuntime](#lnetworkruntime)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:wsClose`

Closes a WebSocket connection. This method is available to Lua scripts.

```lua
LNetworkRuntime:wsClose(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Connection id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsClose(id)
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:wsConnect`

Opens a WebSocket connection. This method is available to Lua scripts.

```lua
LNetworkRuntime:wsConnect(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | WebSocket URL. |

**Returns**

| Type | Description |
|------|-------------|
| number | Connection id. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

#### `LNetworkRuntime:wsSend`

Sends text over a WebSocket connection.

```lua
LNetworkRuntime:wsSend(id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Connection id. |
| `data` | string | Text payload. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end
```

---

## LSseStream

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSseStream:close`

Signals the background reader thread to stop and closes the stream.

```lua
LSseStream:close()
```

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(_ev) end)
    stream:close()
end
```

---

#### `LSseStream:isOpen`

Returns true if the background reader thread is still connected and reading.

```lua
LSseStream:isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True while the stream is open. |

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(_ev) end)
    print("open=" .. tostring(stream:isOpen()))
    stream:close()
end
```

---

#### `LSseStream:next`

Polls for the next available event from the SSE stream (non-blocking).

```lua
LSseStream:next()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Event table `{ id?, event?, data }` when available; returns nil when no event is ready. |

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(_ev) end)
    local ev = stream:next()
    if ev then
        print("data=" .. ev.data)
    end
    stream:close()
end
```

---

#### `LSseStream:type`

Returns the Lua-visible type name for this SSE stream handle.

```lua
LSseStream:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSseStream](#lssestream)`. |

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(_ev) end)
    print(stream:type())
    stream:close()
end
```

---

#### `LSseStream:typeOf`

Returns whether this SSE stream handle matches a supported type name.

```lua
LSseStream:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LSseStream](#lssestream)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:9999/events", function(_ev) end)
    print(stream:typeOf("LSseStream"))
    stream:close()
end
```

---
