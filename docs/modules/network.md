# Network

- The `network` module is a powerful Core Runtime tier component providing a comprehensive multiplayer networking stack for Lurek2D.

It is engineered to handle a diverse array of network topologies and transport protocols, including high-performance ENet UDP transport, raw non-blocking TCP sockets, asynchronous HTTP requests, and persistent bidirectional WebSocket connections. The module is built around a dedicated background `NetworkRuntime` thread (powered by Tokio) that handles all blocking I/O, ensuring that socket latency and network operations never stall the primary game loop. The game thread communicates with this runtime via highly efficient MPSC request/response channels.

At the heart of real-time multiplayer functionality is the `NetworkHost` structure, which wraps an ENet instance and manages robust connections across Server, Client, or Peer-to-Peer roles. It supports sophisticated traffic shaping, including per-peer bandwidth limits and reliable/unreliable channel separation, and provides a continuous stream of `NetworkEvent`s (connect, disconnect, receive) for Lua to consume. To address the complexities of modern internet connectivity, the module features a sophisticated `relay` system that utilizes NAT-punching probes and encoded `RelayTicket`s to establish peer connections even across restrictive networks. It also provides built-in LAN lobby discovery via UDP broadcasting.

Beyond raw transport, the module implements high-level game synchronization features. The `net_sync` submodule provides tools for entity snapshot replication, utilizing linear dead-reckoning prediction and server-authoritative reconciliation to ensure smooth gameplay across varied latencies. Network messaging is powered by a custom `NetValue` wire-format, mirroring Lua's dynamic type system and utilizing compact MessagePack serialization. Auxiliary services, like the synchronous HTTP client (supporting all major verbs with headers and timeouts) and the WebSocket manager, provide vital hooks for integrating with REST APIs, authentication servers, and web-based services. This extensive networking suite is fully exposed to scripts via the `lurek.network.*` API, making it a cornerstone for connected Lurek2D games.

## Functions

### `lurek.network.createLobby`

Broadcasts lobby information and returns it as a table.

```lua
-- signature
lurek.network.createLobby(name, port, player_count, max_players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Lobby name. |
| `port` | `number` | Lobby port. |
| `player_count?` | `number` | Optional current player count, defaulting to 1. |
| `max_players?` | `number` | Optional maximum players, defaulting to 8. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkCreateLobbyResult` | Lobby info table. |

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
-- signature
lurek.network.createRoom(name, host, max_players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Room name. |
| `host` | `string` | Host string. |
| `max_players?` | `number` | Optional maximum players, defaulting to 8. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkCreateRoomResult` | Room info table. |

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
-- signature
lurek.network.discoverLobbies(timeout_ms)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeout_ms?` | `number` | Optional timeout in milliseconds, defaulting to 500. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkDiscoverLobbiesResult` | Array table of lobby info tables. |

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

### `lurek.network.joinRoom`

Joins a room by id when available. This function is exposed to Lua scripts.

```lua
-- signature
lurek.network.joinRoom(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Room id. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkJoinRoomResult` | Room info table, or nil when missing. |

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
-- signature
lurek.network.leaveRoom(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Room id. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkLeaveRoomResult` | Room info table, or nil when missing. |

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
-- signature
lurek.network.listRooms()
```

**Returns**

| Type | Description |
|------|-------------|
| `NetworkListRoomsResult` | Array table of room info tables. |

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
-- signature
lurek.network.makePunchProbe(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `string` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Probe payload. |

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
-- signature
lurek.network.newClient(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options with required `addr`, optional `channels`, and `data`. |

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHost` | New client host handle. |

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
-- signature
lurek.network.newHost(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options with `addr`, optional `maxPeers`/`peers`, `channels`, `inBandwidth`, and `outBandwidth`. |

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHost` | New network host handle. |

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

### `lurek.network.newRelayTicket`

Creates an encoded relay ticket. This function is exposed to Lua scripts.

```lua
-- signature
lurek.network.newRelayTicket(room_id, peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `room_id` | `string` | Room id. |
| `peer_id` | `string` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Encoded relay ticket. |

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

### `lurek.network.newRuntime`

Creates a background network runtime.

```lua
-- signature
lurek.network.newRuntime()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkRuntime` | New network runtime handle. |

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
-- signature
lurek.network.newServer(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options with required `port`, optional `maxPeers`/`peers`, and `channels`. |

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHost` | New server host handle. |

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
-- signature
lurek.network.pack(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | Lua value to pack (table, number, string, or boolean). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary packed message. |

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

### `lurek.network.parsePunchProbe`

Parses a relay punch probe payload.

```lua
-- signature
lurek.network.parsePunchProbe(payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `payload` | `string` | Probe payload. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Parsed peer id, or nil when invalid. |

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
-- signature
lurek.network.parseRelayTicket(token)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `token` | `string` | Encoded relay ticket. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkParseRelayTicketResult` | Ticket table, or nil when invalid. |

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
-- signature
lurek.network.predictLinear(snapshot, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | `table` | Snapshot table with `id`, `tick`, `x`, `y`, `vx`, and `vy`. |
| `dt` | `number` | Prediction delta time. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkPredictLinearResult` | Predicted snapshot table. |

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
-- signature
lurek.network.reconcileSnapshot(pred, auth, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pred` | `table` | Predicted snapshot table. |
| `auth` | `table` | Authoritative snapshot table. |
| `alpha` | `number` | Blend factor. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkReconcileSnapshotResult` | Reconciled snapshot table. |

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

### `lurek.network.sseCollect`

Blocking helper: collects up to `n` events from a fresh SSE connection or until `timeout_secs` elapses.

```lua
-- signature
lurek.network.sseCollect(url, n, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | SSE endpoint URL. |
| `n` | `number` | Maximum number of events to collect. |
| `timeout_secs?` | `number` | Optional timeout in seconds; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of event tables `{ id?, event?, data }`. |

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

Opens an SSE stream to `url` and returns an `LSseStream` handle.

```lua
-- signature
lurek.network.sseConnect(url, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | SSE endpoint URL. |
| `callback` | `function` | Called with each event table `{ id?, event?, data }`. |

**Returns**

| Type | Description |
|------|-------------|
| `LSseStream` | Stream handle for polling or closing. |

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
-- signature
lurek.network.syncEntity(host_ud, entity_id, data_tbl, channel, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `host_ud` | `LNetworkHost` | Network host handle. |
| `entity_id` | `number` | Entity id. |
| `data_tbl` | `table` | Entity field table. |
| `channel?` | `number` | Optional channel id, defaulting to 0. |
| `reliable?` | `boolean` | Optional reliable flag, defaulting to false. |

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
-- signature
lurek.network.unpack(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Binary packed message. |

**Returns**

| Type | Description |
|------|-------------|
| `NetworkUnpackResult` | Unpacked Lua value. |

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

## LNetworkHost

### `LNetworkHost:broadcast`

Broadcasts bytes to all connected peers on a channel.

```lua
-- signature
LNetworkHost:broadcast(channel_id, data, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel_id` | `number` | Channel id. |
| `data` | `string` | Binary payload string. |
| `reliable?` | `boolean` | Optional reliable flag, defaulting to true. |

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

### `LNetworkHost:connect`

Connects to a remote address. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:connect(addr_str, channels, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `addr_str` | `string` | Remote socket address. |
| `channels?` | `number` | Optional channel count, defaulting to 1. |
| `data?` | `number` | Optional connection data, defaulting to 0. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Peer id. |

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

### `LNetworkHost:destroy`

Destroys the network host and releases resources.

```lua
-- signature
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

### `LNetworkHost:disconnect`

Requests a graceful peer disconnect.

```lua
-- signature
LNetworkHost:disconnect(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |
| `data?` | `number` | Optional disconnect data. |

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

### `LNetworkHost:disconnectLater`

Schedules a peer disconnect after pending packets.

```lua
-- signature
LNetworkHost:disconnectLater(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |
| `data?` | `number` | Optional disconnect data. |

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

### `LNetworkHost:disconnectNow`

Disconnects a peer immediately. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:disconnectNow(peer_id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |
| `data?` | `number` | Optional disconnect data. |

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

### `LNetworkHost:flush`

Flushes queued outgoing network packets.

```lua
-- signature
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

### `LNetworkHost:getAddress`

Returns local host socket address.

```lua
-- signature
LNetworkHost:getAddress()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Local socket address. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("addr=" .. host:getAddress())
    host:destroy()
end
```

---

### `LNetworkHost:getBandwidthLimit`

Returns incoming and outgoing bandwidth limits.

```lua
-- signature
LNetworkHost:getBandwidthLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHostGetBandwidthLimitResult` | Table with `incoming` and `outgoing` fields. |

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

### `LNetworkHost:getChannelLimit`

Returns configured channel limit.

```lua
-- signature
LNetworkHost:getChannelLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Channel limit. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end
```

---

### `LNetworkHost:getConnectedPeerCount`

Returns the number of currently connected peers.

```lua
-- signature
LNetworkHost:getConnectedPeerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Connected peer count. |

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

### `LNetworkHost:getConnectedPeerIds`

Returns an array of ids for all connected peers.

```lua
-- signature
LNetworkHost:getConnectedPeerIds()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of peer ids. |

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

### `LNetworkHost:getPeerAddress`

Returns peer socket address when available.

```lua
-- signature
LNetworkHost:getPeerAddress(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Peer address, or nil when unavailable. |

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

### `LNetworkHost:getPeerLimit`

Returns configured peer limit. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:getPeerLimit()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Peer limit. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("peer_limit=" .. host:getPeerLimit())
    host:destroy()
end
```

---

### `LNetworkHost:getPeerState`

Returns peer connection state. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:getPeerState(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Peer state string. |

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

### `LNetworkHost:getPeerStats`

Returns statistics for a peer. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:getPeerStats(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHostGetPeerStatsResult` | Peer statistics table. |

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

### `LNetworkHost:getRole`

Returns host role string. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:getRole()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Role string. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("role=" .. host:getRole())
    host:destroy()
end
```

---

### `LNetworkHost:getRoundTripTime`

Returns peer round trip time in milliseconds.

```lua
-- signature
LNetworkHost:getRoundTripTime(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Round trip time in milliseconds. |

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

### `LNetworkHost:isClient`

Returns whether this host has client role.

```lua
-- signature
LNetworkHost:isClient()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when role is client. |

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

### `LNetworkHost:isDestroyed`

Returns whether the network host is destroyed.

```lua
-- signature
LNetworkHost:isDestroyed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when destroyed. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    host:destroy()
end
```

---

### `LNetworkHost:isServer`

Returns whether this host has server role.

```lua
-- signature
LNetworkHost:isServer()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when role is server. |

**Example**

```lua
do
    local server = lurek.network.newServer({port = 7799, maxPeers = 4, channels = 2})
    print("is_server=" .. tostring(server:isServer()))
    server:destroy()
end
```

---

### `LNetworkHost:ping`

Sends a ping to a peer. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:ping(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

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

### `LNetworkHost:resetPeer`

Resets a peer connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:resetPeer(peer_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |

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

### `LNetworkHost:send`

Sends bytes to a peer on a channel. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:send(peer_id, channel_id, data, reliable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `peer_id` | `number` | Peer id. |
| `channel_id` | `number` | Channel id. |
| `data` | `string` | Binary payload string. |
| `reliable?` | `boolean` | Optional reliable flag, defaulting to true. |

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

### `LNetworkHost:service`

Polls the host for one network event.

```lua
-- signature
LNetworkHost:service()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkHostServiceResult` | Event table, or nil when no event is available. |

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

### `LNetworkHost:setBandwidthLimit`

Sets incoming and outgoing bandwidth limits.

```lua
-- signature
LNetworkHost:setBandwidthLimit(incoming, outgoing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `incoming?` | `number` | Optional incoming bandwidth limit. |
| `outgoing?` | `number` | Optional outgoing bandwidth limit. |

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

### `LNetworkHost:setChannelLimit`

Sets channel limit. This method is available to Lua scripts.

```lua
-- signature
LNetworkHost:setChannelLimit(limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `limit` | `number` | Channel limit. |

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

### `LNetworkHost:type`

Returns the Lua-visible type name for this network host handle.

```lua
-- signature
LNetworkHost:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNetworkHost`. |

**Example**

```lua
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("type=" .. host:type())
    host:destroy()
end
```

---

### `LNetworkHost:typeOf`

Returns whether this network host handle matches a supported type name.

```lua
-- signature
LNetworkHost:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LNetworkHost` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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

### `LNetworkRuntime:httpGet`

Starts an HTTP GET request. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:httpGet(url, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | Request URL. |
| `headers?` | `table` | Optional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Request id. |

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

### `LNetworkRuntime:httpJson`

Starts an HTTP POST request with a JSON-encoded body and Content-Type application/json.

```lua
-- signature
LNetworkRuntime:httpJson(url, body, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | Request URL. |
| `body` | `string` | JSON string to send as the request body. |
| `headers?` | `table` | Optional additional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Request id. |

---

### `LNetworkRuntime:httpPost`

Starts an HTTP POST request. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:httpPost(url, body, headers)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | Request URL. |
| `body` | `string` | Request body. |
| `headers?` | `table` | Optional headers table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Request id. |

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

### `LNetworkRuntime:httpRequest`

Starts an HTTP request from an options table and returns its request id.

```lua
-- signature
LNetworkRuntime:httpRequest(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options table with `url`, optional `method`, `headers`, `body`, and `timeout`. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Request id. |

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

### `LNetworkRuntime:httpStream`

Starts an HTTP GET request intended for Server-Sent Events or streaming responses.

```lua
-- signature
LNetworkRuntime:httpStream(url, headers, timeout_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | Request URL. |
| `headers?` | `table` | Optional headers table. |
| `timeout_secs?` | `number` | Optional timeout override in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Request id. |

---

### `LNetworkRuntime:poll`

Polls runtime responses for HTTP, TCP, and WebSocket operations.

```lua
-- signature
LNetworkRuntime:poll()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNetworkRuntimePollResult` | Array table of response/event tables. |

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

### `LNetworkRuntime:shutdown`

Shuts down the network runtime and cancels pending requests.

```lua
-- signature
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

### `LNetworkRuntime:tcpClose`

Closes a TCP connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:tcpClose(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Connection id. |

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

### `LNetworkRuntime:tcpConnect`

Opens a TCP connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:tcpConnect(addr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `addr` | `string` | Remote address. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Connection id. |

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

### `LNetworkRuntime:tcpSend`

Sends bytes over a TCP connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:tcpSend(id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Connection id. |
| `data` | `string` | Binary payload string. |

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

### `LNetworkRuntime:type`

Returns the Lua-visible type name for this network runtime handle.

```lua
-- signature
LNetworkRuntime:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNetworkRuntime`. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    rt:shutdown()
end
```

---

### `LNetworkRuntime:typeOf`

Returns whether this network runtime handle matches a supported type name.

```lua
-- signature
LNetworkRuntime:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LNetworkRuntime` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local rt = lurek.network.newRuntime()
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end
```

---

### `LNetworkRuntime:wsClose`

Closes a WebSocket connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:wsClose(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Connection id. |

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

### `LNetworkRuntime:wsConnect`

Opens a WebSocket connection. This method is available to Lua scripts.

```lua
-- signature
LNetworkRuntime:wsConnect(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `string` | WebSocket URL. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Connection id. |

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

### `LNetworkRuntime:wsSend`

Sends text over a WebSocket connection.

```lua
-- signature
LNetworkRuntime:wsSend(id, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Connection id. |
| `data` | `string` | Text payload. |

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

### `LSseStream:close`

Signals the background reader thread to stop and closes the stream.

```lua
-- signature
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

### `LSseStream:isOpen`

Returns true if the background reader thread is still connected and reading.

```lua
-- signature
LSseStream:isOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True while the stream is open. |

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

### `LSseStream:next`

Polls for the next available event from the SSE stream (non-blocking).

```lua
-- signature
LSseStream:next()
```

**Returns**

| Type | Description |
|------|-------------|
| `table?` | Event table `{ id?, event?, data }`, or nil when no event is ready. |

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

### `LSseStream:type`

Returns the Lua-visible type name for this SSE stream handle.

```lua
-- signature
LSseStream:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LSseStream`. |

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

### `LSseStream:typeOf`

Returns whether this SSE stream handle matches a supported type name.

```lua
-- signature
LSseStream:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LSseStream` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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
