# Network

## Purpose

Manages ENet UDP hosts for small client/server or peer-hosted games.

## When To Use

- ENet is the gameplay transport. It provides reliable and unreliable UDP channels, host/server/client roles, peer events, flushing, pinging, disconnects, stats, and metrics.
- LAN lobby and room helpers cover local coordination before gameplay packets flow: lobby advertisement/discovery, room creation, join/leave, readiness, room lookup, and player lists.
- MessagePack payload helpers keep gameplay messages compact and structured. Snapshot, prediction, reconciliation, net state, and RPC helpers are part of the same game-state exchange contract.

## Minimal Example

Example block: `lurek.network.newServer`

```lua
do
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    local limits = server:getBandwidthLimit()
    local metrics = server:getMetrics()
    network_log("dedicated server role=" .. server:getRole() .. " addr=" .. server:getAddress())
    network_log("peer_limit=" .. server:getPeerLimit() .. " channels=" .. server:getChannelLimit())
    network_log("bw=" .. tostring(limits.incoming) .. "/" .. tostring(limits.outgoing) .. " connected=" .. metrics.connected_peers)
    server:destroy()
end
```

## Common Patterns

- Start with `lurek.network.createLobby` when exploring this module.
- Start with `lurek.network.createRoom` when exploring this module.
- Start with `lurek.network.discoverLobbies` when exploring this module.
- Start with `lurek.network.getPlayerList` when exploring this module.
- Start with `lurek.network.getRoom` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `network` module is the engine's small-game multiplayer surface for users who need direct IP or LAN-hosted sessions for roughly 8-16 players.
- ENet is the gameplay transport. It provides reliable and unreliable UDP channels, host/server/client roles, peer events, flushing, pinging, disconnects, stats, and metrics.
- LAN lobby and room helpers cover local coordination before gameplay packets flow: lobby advertisement/discovery, room creation, join/leave, readiness, room lookup, and player lists.
- MessagePack payload helpers keep gameplay messages compact and structured. Snapshot, prediction, reconciliation, net state, and RPC helpers are part of the same game-state exchange contract.
- Relay and punch helpers are lightweight string/payload helpers only. They do not create a built-in web relay client or internet matchmaking service inside `lurek.exe`.
- Web-service transports, streaming feeds, auth bootstrap, and SaaS-style matchmaking are intentionally outside the runtime network API. If a project needs internet services later, they should live in a separate service/tool while gameplay remains ENet-based.
- Read `network` as the engine feature for small multiplayer sessions, LAN discovery, and structured gameplay state exchange.

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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    local found = lurek.network.discoverLobbies(10)
    local room = lurek.network.createRoom("My Game staging", "host-A", 4)
    local rooms = lurek.network.listRooms()
    network_log("lobby=" .. lobby.name .. ":" .. lobby.port .. " players=" .. lobby.player_count .. "/" .. lobby.max_players)
    network_log("discoveries=" .. #found .. " local_rooms=" .. #rooms .. " staging=" .. room.id)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local room = lurek.network.createRoom("Arena", "player1", 8)
    local joined = lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    example_print_log("room_id=" .. room.id)
    example_print_log("players=" .. joined.player_count .. "->" .. left.player_count)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.network.createLobby("Discovery", 7788, 1, 4)
    local lobbies = lurek.network.discoverLobbies(10)
    local room = lurek.network.createRoom("Discovery staging", "host-discovery", 4)
    local rooms = lurek.network.listRooms()
    network_log("lan lobbies=" .. #lobbies)
    network_log("first=" .. tostring(lobbies[1] and lobbies[1].name or "nil") .. " local_rooms=" .. #rooms .. " staging=" .. room.id)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.network.setReady("match_room", 1, true)
    lurek.network.setReady("match_room", 3, true)
    lurek.network.setReady("match_room", 2, false)
    local players = lurek.network.getPlayerList("match_room")
    example_print_log("player_list_count=" .. #players)
    for i, pid in ipairs(players) do
        example_print_log("player_" .. i .. "=" .. pid)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.network.setReady("session_room", 1, true)
    lurek.network.setReady("session_room", 2, false)
    local room = lurek.network.getRoom("session_room")
    example_print_log("room_name=" .. room.name)
    example_print_log("room_host=" .. room.host_peer)
    example_print_log("room_players=" .. room.player_count)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.network.setReady("lobby_room", 1, true)
    lurek.network.setReady("lobby_room", 2, true)
    local all_ready = lurek.network.isAllReady("lobby_room")
    local room = lurek.network.getRoom("lobby_room")
    local players = lurek.network.getPlayerList("lobby_room")
    network_log("all_ready=" .. tostring(all_ready))
    network_log("room players=" .. tostring(room.player_count) .. " ids=" .. table.concat(players, ","))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local room = lurek.network.createRoom("Joinable", "host-B", 4)
    local joined = lurek.network.joinRoom(room.id)
    local players = lurek.network.getPlayerList(room.id)
    local meta = lurek.network.getRoom(room.id)
    network_log("joined room=" .. tostring(room.id) .. " name=" .. tostring(joined.name))
    network_log("player_count=" .. tostring(joined.player_count) .. " tracked_players=" .. #players .. " meta_host=" .. tostring(meta.host))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local room = lurek.network.createRoom("Leavable", "host-C", 4)
    lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    example_print_log("room_id=" .. room.id)
    example_print_log("player_count=" .. left.player_count)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rooms = lurek.network.listRooms()
    local room = lurek.network.createRoom("Listed", "host-D", 3)
    rooms = lurek.network.listRooms()
    example_print_log("rooms=" .. #rooms)
    example_print_log("last_room=" .. room.name)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local probe = lurek.network.makePunchProbe("peer_99")
    local peer_id = lurek.network.parsePunchProbe(probe)
    local relay = lurek.network.newRelayTicket("room_probe", peer_id)
    local ticket = lurek.network.parseRelayTicket(relay)
    network_log("probe bytes=" .. #probe .. " peer=" .. tostring(peer_id))
    network_log("relay pairing room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7778, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7778", channels = 2, data = 21})
    example_print_log("role=" .. client:getRole())
    example_print_log("type=" .. client:type())
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    local metrics = host:getMetrics()
    local limits = host:getBandwidthLimit()
    network_log("listen host addr=" .. host:getAddress() .. " role=" .. host:getRole())
    network_log("channels=" .. host:getChannelLimit() .. " peers=" .. host:getPeerLimit())
    network_log("bw=" .. tostring(limits.incoming) .. "/" .. tostring(limits.outgoing) .. " connected=" .. metrics.connected_peers)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, state = pcall(function()
        return lurek.network.newNetState(host, { authority = true })
    end)
    example_print_log("newNetState ok=" .. tostring(ok))
    if ok then
        state:set("player_x", 100)
        state:set("player_y", 50)

        local x = state:get("player_x")
        example_print_log("player_x=" .. x)

        state:onChange("player_x", function(value, old_value, peer_id)
            example_print_log("player_x changed from " .. tostring(old_value) .. " to " .. tostring(value))
        end)

        local all_state = state:getAll()
        example_print_log("state_keys=" .. #all_state)

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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    local ticket = lurek.network.parseRelayTicket(token)
    local packed = lurek.network.pack({ room = ticket.room_id, peer = ticket.peer_id })
    local unpacked = lurek.network.unpack(packed)
    network_log("relay room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
    network_log("packed mirror room=" .. unpacked.room .. " token_bytes=" .. #token)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, rpc = pcall(function()
        return lurek.network.newRpc(host, 0, 30.0)
    end)
    example_print_log("newRpc ok=" .. tostring(ok))
    if ok then
        rpc:register("ping", function(peer_id)
            return "pong"
        end)
        local responses = rpc:poll()
        example_print_log("rpc_responses=" .. #responses)
    end
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    local limits = server:getBandwidthLimit()
    local metrics = server:getMetrics()
    network_log("dedicated server role=" .. server:getRole() .. " addr=" .. server:getAddress())
    network_log("peer_limit=" .. server:getPeerLimit() .. " channels=" .. server:getChannelLimit())
    network_log("bw=" .. tostring(limits.incoming) .. "/" .. tostring(limits.outgoing) .. " connected=" .. metrics.connected_peers)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    local unpacked = lurek.network.unpack(packed)
    example_print_log("packed_bytes=" .. #packed)
    example_print_log("unpacked_name=" .. unpacked.name)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local snapshot = {
        type = "full",
        tick = 100,
        entities = {
            { id = 1, tick = 100, x = 10.0, y = 20.0, vx = 1.0, vy = 0.0 }
        }
    }
    local packed = lurek.network.packSnapshot(snapshot)
    example_print_log("packed_snapshot_bytes=" .. #packed)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local probe = lurek.network.makePunchProbe("peer_parse")
    local peer_id = lurek.network.parsePunchProbe(probe)
    local relay = lurek.network.newRelayTicket("room_parse_probe", peer_id)
    local ticket = lurek.network.parseRelayTicket(relay)
    network_log("parsed probe peer=" .. tostring(peer_id))
    network_log("relay room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local token = lurek.network.newRelayTicket("room_parse", "peer_parse")
    local ticket = lurek.network.parseRelayTicket(token)
    local packed = lurek.network.pack({ room = ticket.room_id, peer = ticket.peer_id })
    local unpacked = lurek.network.unpack(packed)
    network_log("ticket room=" .. ticket.room_id)
    network_log("ticket peer=" .. tostring(ticket.peer_id) .. " unpacked_peer=" .. tostring(unpacked.peer))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    local auth = {id = 1, tick = 11, x = 10.3, y = 20, vx = 5, vy = 0}
    local corrected = lurek.network.reconcileSnapshot(predicted, auth, 0.5)
    network_log("predicted tick=" .. predicted.tick .. " pos=" .. predicted.x .. "," .. predicted.y)
    network_log("corrected pos=" .. corrected.x .. "," .. corrected.y)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pred = {id = 3, tick = 20, x = 10, y = 10, vx = 1, vy = 0}
    local auth = {id = 3, tick = 21, x = 12, y = 11, vx = 1, vy = 0}
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    example_print_log("tick=" .. result.tick)
    example_print_log("x=" .. result.x)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pred = { id = 1, tick = 10, x = 10.0, y = 0.0, vx = 0.0, vy = 0.0 }
    local auth = { id = 1, tick = 10, x = 12.0, y = 0.0, vx = 1.0, vy = 2.0 }
    local result = lurek.network.reconcileWithPolicy(pred, auth, 0.5, 0.2, 5.0)
    local hardSnap = lurek.network.reconcileWithPolicy(pred, { id = 1, tick = 10, x = 20.0, y = 0.0, vx = 1.0, vy = 2.0 }, 0.5, 0.2, 5.0)
    network_log("soft reconcile x=" .. result.x .. " y=" .. result.y)
    network_log("hard reconcile x=" .. hardSnap.x .. " vx=" .. hardSnap.vx)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.network.setReady("game_room", 1, true)
    lurek.network.setReady("game_room", 2, false)
    local players = lurek.network.getPlayerList("game_room")
    local room = lurek.network.getRoom("game_room")
    network_log("room=" .. tostring(room.name) .. " players=" .. tostring(room.player_count))
    network_log("tracked player ids=" .. table.concat(players, ","))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client = connect_pair(7797, 2)
    lurek.network.syncEntity(server, 1, {x = 100, y = 200, hp = 50}, 0, true)
    server:flush()
    local event = wait_for_event(client, "receive")
    local payload = lurek.network.unpack(event.data)
    example_print_log("entity_id=" .. payload.id)
    example_print_log("hp=" .. payload.data.hp)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    local packedSnapshot = lurek.network.pack({ id = msg.id, tag = "chat", body = msg.data })
    local echo = lurek.network.unpack(packedSnapshot)
    network_log("message id=" .. msg.id .. " body=" .. msg.data)
    network_log("echo tag=" .. echo.tag .. " raw_bytes=" .. #raw)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("unpacked_type=" .. unpacked.type)
    example_print_log("unpacked_tick=" .. unpacked.tick)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LNetworkHost](#lnetworkhost)

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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client = connect_pair(7782, 2)
    server:broadcast(1, "state:update", true)
    server:flush()
    local event = wait_for_event(client, "receive")
    example_print_log("channel=" .. tostring(event and event.channel_id or "nil"))
    example_print_log("payload=" .. tostring(event and event.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(4, 30)
    host:clearLease(token)
    example_print_log("cleared lease: " .. tostring(host:getLeasePeer(token) == nil))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server = lurek.network.newServer({port = 7779, maxPeers = 4, channels = 2})
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1, channels = 2})
    local peer_id = host:connect("127.0.0.1:7779", 2, 17)
    local event = wait_for_event(server, "connect")
    example_print_log("peer_id=" .. peer_id)
    example_print_log("server_event=" .. tostring(event and event.type or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local before = host:isDestroyed()
    local role = host:getRole()
    host:destroy()
    local after = host:isDestroyed()
    network_log("host role=" .. role .. " before_destroy=" .. tostring(before))
    network_log("after_destroy=" .. tostring(after))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client, server_connect = connect_pair(7791, 2)
    server:disconnect(server_connect.peer_id, 7)
    server:flush()
    local event = wait_for_event(client, "disconnect")
    example_print_log("event_type=" .. tostring(event and event.type or "nil"))
    example_print_log("data=" .. tostring(event and event.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client, server_connect = connect_pair(7792, 2)
    server:send(server_connect.peer_id, 0, "queued-goodbye", true)
    server:disconnectLater(server_connect.peer_id, 8)
    server:flush()
    local receive = wait_for_event(client, "receive")
    local disconnect = wait_for_event(client, "disconnect")
    example_print_log("payload=" .. tostring(receive and receive.data or "nil"))
    example_print_log("disconnect_data=" .. tostring(disconnect and disconnect.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client, server_connect = connect_pair(7793, 2)
    server:disconnectNow(server_connect.peer_id, 9)
    server:flush()
    local event = wait_for_event(client, "disconnect")
    example_print_log("event_type=" .. tostring(event and event.type or "nil"))
    example_print_log("data=" .. tostring(event and event.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client, _, client_connect = connect_pair(7794, 2)
    client:send(client_connect.peer_id, 0, "flush-check", true)
    client:flush()
    local event = wait_for_event(server, "receive")
    example_print_log("event_type=" .. tostring(event and event.type or "nil"))
    example_print_log("payload=" .. tostring(event and event.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local addr = host:getAddress()
    local role = host:getRole()
    local peers = host:getPeerLimit()
    network_log("local host addr=" .. addr)
    network_log("role=" .. role .. " peer_limit=" .. peers)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7789, maxPeers = 4})
    server:setBandwidthLimit(64000, 32000)
    local bw = server:getBandwidthLimit()
    example_print_log("bw_in=" .. tostring(bw.incoming))
    example_print_log("bw_out=" .. tostring(bw.outgoing))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local channels = host:getChannelLimit()
    local peers = host:getPeerLimit()
    local role = host:getRole()
    network_log("channel budget=" .. channels)
    network_log("peer_limit=" .. peers .. " role=" .. role)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client = connect_pair(7783, 2)
    example_print_log("connected=" .. server:getConnectedPeerCount())
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client = connect_pair(7784, 2)
    local ids = server:getConnectedPeerIds()
    example_print_log("peer_count=" .. #ids)
    example_print_log("first_peer=" .. tostring(ids[1]))
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
| number | Original Peer ID, or nil if invalid or expired. |

**Example**

```lua
do
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(2, 30)
    local peer_id = host:getLeasePeer(token)
    example_print_log("lease peer: " .. tostring(peer_id))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ port = 0 })
    local metrics = host:getMetrics()
    local role = host:getRole()
    local addr = host:getAddress()
    network_log("host metrics peers=" .. tostring(metrics.connected_peers))
    network_log("role=" .. role .. " addr=" .. addr)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7786, 2)
    example_print_log("peer_addr=" .. tostring(server:getPeerAddress(server_connect.peer_id)))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local peers = host:getPeerLimit()
    local channels = host:getChannelLimit()
    local addr = host:getAddress()
    network_log("peer cap=" .. peers)
    network_log("channels=" .. channels .. " addr=" .. addr)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7785, 2)
    example_print_log("peer_state=" .. server:getPeerState(server_connect.peer_id))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7788, 2)
    local stats = server:getPeerStats(server_connect.peer_id)
    example_print_log("packets_sent=" .. stats.packets_sent)
    example_print_log("rtt_ms=" .. stats.round_trip_time)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local role = host:getRole()
    local typeName = host:type()
    local addr = host:getAddress()
    network_log("host role=" .. role)
    network_log("type=" .. typeName .. " addr=" .. addr)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7787, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    example_print_log("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7798, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7798", channels = 2})
    example_print_log("is_client=" .. tostring(client:isClient()))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local before = host:isDestroyed()
    local role = host:getRole()
    host:destroy()
    local after = host:isDestroyed()
    network_log("role=" .. role .. " before_destroyed=" .. tostring(before))
    network_log("after_destroyed=" .. tostring(after))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7799, maxPeers = 4, channels = 2})
    local role = server:getRole()
    local isServer = server:isServer()
    local channels = server:getChannelLimit()
    network_log("role=" .. role .. " is_server=" .. tostring(isServer))
    network_log("channel_limit=" .. channels)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7795, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    example_print_log("peer_state=" .. server:getPeerState(server_connect.peer_id))
    example_print_log("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(1, 30)
    local peer = host:getLeasePeer(token)
    local renewed = host:renewLease(token, 45)
    network_log("lease token=" .. tostring(token) .. " peer=" .. tostring(peer))
    network_log("renewed=" .. tostring(renewed))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(3, 30)
    local success = host:renewLease(token, 60)
    example_print_log("lease renew: " .. tostring(success))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7796, 2)
    server:resetPeer(server_connect.peer_id)
    server:service()
    client:service()
    example_print_log("reset_peer=" .. server_connect.peer_id)
    example_print_log("connected=" .. server:getConnectedPeerCount())
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local function wait_for_event(host, expected_type, max_attempts)
        max_attempts = max_attempts or 8
        for _ = 1, max_attempts do
            local event = host:service()
            if event and (expected_type == nil or event.type == expected_type) then
                return event
            end
            host:flush()
        end
        return nil
    end

    local server, client, server_connect = connect_pair(7781, 2)
    server:send(server_connect.peer_id, 0, "welcome", true)
    server:flush()
    local event = wait_for_event(client, "receive")
    example_print_log("event_type=" .. tostring(event and event.type or "nil"))
    example_print_log("payload=" .. tostring(event and event.data or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function connect_pair(port, channels)
        local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
        local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
        local server_connect = nil
        local client_connect = nil

        for _ = 1, 8 do
            server:flush()
            client:flush()

            if not server_connect then
                local event = server:service()
                if event and event.type == "connect" then
                    server_connect = event
                end
            end

            if not client_connect then
                local event = client:service()
                if event and event.type == "connect" then
                    client_connect = event
                end
            end

            if not server_connect then
                local ids = server:getConnectedPeerIds()
                if ids[1] ~= nil then
                    server_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if not client_connect then
                local ids = client:getConnectedPeerIds()
                if ids[1] ~= nil then
                    client_connect = {type = "connect", peer_id = ids[1]}
                end
            end

            if server_connect and client_connect then
                break
            end
        end

        return server, client, server_connect, client_connect
    end

    local server, client, server_connect = connect_pair(7780, 2)
    example_print_log("event_type=" .. tostring(server_connect and server_connect.type or "nil"))
    example_print_log("peer_id=" .. tostring(server_connect and server_connect.peer_id or "nil"))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    local limits = server:getBandwidthLimit()
    example_print_log("incoming=" .. tostring(limits.incoming))
    example_print_log("outgoing=" .. tostring(limits.outgoing))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:7790", maxPeers = 2, channels = 1})
    local before = host:getChannelLimit()
    host:setChannelLimit(4)
    local after = host:getChannelLimit()
    local peers = host:getPeerLimit()
    network_log("match channels before=" .. before .. " after=" .. after)
    network_log("peer slots remain=" .. peers)
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local typeName = host:type()
    local role = host:getRole()
    local destroyed = host:isDestroyed()
    network_log("host userdata=" .. typeName)
    network_log("role=" .. role .. " destroyed=" .. tostring(destroyed))
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
    local function network_log(message)
        lurek.log.info("[network.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local isHost = host:typeOf("LNetworkHost")
    local isObject = host:typeOf("LObject")
    network_log("typeOf host=" .. tostring(isHost) .. " object=" .. tostring(isObject))
    network_log("runtime check=" .. tostring(isRuntime) .. " type=" .. host:type())
    host:destroy()
end
```

---
