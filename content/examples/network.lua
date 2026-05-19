-- content/examples/network.lua
-- Auto-generated from content/examples2/network_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/network.lua

--- Network Module Part 1: LNetworkHost — server, client, peer management


--@api-stub: lurek.network.newServer
-- Creates a server host.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    print("role = " .. server:getRole())
    server:destroy()
end

--@api-stub: lurek.network.newClient
-- Creates a client host and connects to a server.
do
    ---@type LNetworkHost
    local client = lurek.network.newClient({addr = "127.0.0.1:7777", channels = 2})
    print("role = " .. client:getRole())
    client:destroy()
end

--@api-stub: lurek.network.newHost
-- Creates a generic network host.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    print("address = " .. host:getAddress())
    host:destroy()
end

--@api-stub: LNetworkHost:connect
-- Connects to a remote peer (client-side).
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1})
    local peer_id = host:connect("127.0.0.1:7777", 2)
    print("connecting, peer_id = " .. peer_id)
    host:destroy()
end

--@api-stub: LNetworkHost:service
-- Polls for network events.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7778, maxPeers = 4})
    local ev = server:service()
    if ev then
        print("event type = " .. ev.type)
        if ev.peer_id then print("peer = " .. ev.peer_id) end
        if ev.payload then print("payload len = " .. #ev.payload) end
    else
        print("no events")
    end
    server:destroy()
end

--@api-stub: LNetworkHost:send
-- Sends data to peers. Focus: send.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7779, maxPeers = 8, channels = 2})
    print("send ready, channels = " .. server:getChannelLimit())
    server:destroy()
end

--@api-stub: LNetworkHost:broadcast
-- Sends data to peers. Focus: broadcast.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7779, maxPeers = 8, channels = 2})
    print("broadcast ready, channels = " .. server:getChannelLimit())
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerCount
-- Queries connected peers. Focus: getConnectedPeerCount.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7780, maxPeers = 4})
    print("connected = " .. server:getConnectedPeerCount())
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerIds
-- Queries connected peers. Focus: getConnectedPeerIds.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7780, maxPeers = 4})
    local ids = server:getConnectedPeerIds()
    print("peer ids = " .. #ids)
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerState
-- Peer info queries. Focus: getPeerState.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    -- With a connected peer_id=1:
    -- print(server:getPeerState(1))
    -- print(server:getPeerAddress(1))
    -- print(server:getRoundTripTime(1))
    print("peer queries ready")
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerAddress
-- Peer info queries. Focus: getPeerAddress.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    -- With a connected peer_id=1:
    -- print(server:getPeerState(1))
    -- print(server:getPeerAddress(1))
    -- print(server:getRoundTripTime(1))
    print("peer queries ready")
    server:destroy()
end

--@api-stub: LNetworkHost:getRoundTripTime
-- Peer info queries. Focus: getRoundTripTime.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    -- With a connected peer_id=1:
    -- print(server:getPeerState(1))
    -- print(server:getPeerAddress(1))
    -- print(server:getRoundTripTime(1))
    print("peer queries ready")
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerStats
-- Detailed peer statistics.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7782, maxPeers = 4})
    -- With a connected peer_id=1:
    -- local stats = server:getPeerStats(1)
    -- print("rtt=" .. stats.round_trip_time)
    -- print("sent=" .. stats.packets_sent)
    -- print("lost=" .. stats.packets_lost)
    -- print("loss=" .. stats.packet_loss)
    print("stats query ready")
    server:destroy()
end

--@api-stub: LNetworkHost:setBandwidthLimit
-- Bandwidth configuration. Focus: setBandwidthLimit.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    print("bandwidth limit set")
    server:destroy()
end

--@api-stub: LNetworkHost:getBandwidthLimit
-- Bandwidth configuration. Focus: getBandwidthLimit.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    local bw = server:getBandwidthLimit()
    print("bw in=" .. bw.incoming .. " out=" .. bw.outgoing)
    server:destroy()
end

--@api-stub: LNetworkHost:setChannelLimit
-- Changes channel limit.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7784", maxPeers = 2, channels = 1})
    host:setChannelLimit(4)
    print("channels = " .. host:getChannelLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:disconnect
-- Disconnection methods. Focus: disconnect.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    -- With peer_id=1:
    -- host:disconnect(1, 0)
    -- host:disconnectLater(1, 0)
    -- host:disconnectNow(1, 0)
    print("disconnect methods ready")
    host:destroy()
end

--@api-stub: LNetworkHost:disconnectLater
-- Disconnection methods. Focus: disconnectLater.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    -- With peer_id=1:
    -- host:disconnect(1, 0)
    -- host:disconnectLater(1, 0)
    -- host:disconnectNow(1, 0)
    print("disconnect methods ready")
    host:destroy()
end

--@api-stub: LNetworkHost:disconnectNow
-- Disconnection methods. Focus: disconnectNow.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    -- With peer_id=1:
    -- host:disconnect(1, 0)
    -- host:disconnectLater(1, 0)
    -- host:disconnectNow(1, 0)
    print("disconnect methods ready")
    host:destroy()
end

--@api-stub: LNetworkHost:flush
-- Utility methods. Focus: flush.
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    host:flush()
    -- host:ping(1)
    -- host:resetPeer(1)
    print("utility methods ready")
    host:destroy()
end

--@api-stub: LNetworkHost:ping
-- Utility methods. Focus: ping.
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    host:flush()
    -- host:ping(1)
    -- host:resetPeer(1)
    print("utility methods ready")
    host:destroy()
end

--@api-stub: LNetworkHost:resetPeer
-- Utility methods. Focus: resetPeer.
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    host:flush()
    -- host:ping(1)
    -- host:resetPeer(1)
    print("utility methods ready")
    host:destroy()
end

--- Network Module Part 2: LNetworkRuntime, rooms, lobbies, pack/unpack, prediction


--@api-stub: lurek.network.newRuntime
-- Creates an async HTTP/TCP/WS runtime.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    print("runtime created")
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpGet
-- Non-blocking HTTP GET.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpGet("https://example.com/api/status")
    print("GET request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpPost
-- Non-blocking HTTP POST.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpPost(
        "https://example.com/api/data",
        '{"key":"value"}',
        {["Content-Type"] = "application/json"}
    )
    print("POST request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpRequest
-- Flexible HTTP request with options table.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpRequest({
        url = "https://example.com/api/resource",
        method = "PUT",
        headers = {["Authorization"] = "Bearer token123"},
        body = "updated data",
        timeout = 5000,
    })
    print("custom request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:poll
-- Polls for completed async events.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    rt:httpGet("https://example.com/ping")
    local events = rt:poll()
    for _, ev in ipairs(events) do
        print("event type = " .. ev.type)
        if ev.status then print("  status = " .. ev.status) end
        if ev.body then print("  body len = " .. #ev.body) end
    end
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpConnect
-- Raw TCP connections. Focus: tcpConnect.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp id = " .. id)
    rt:tcpSend(id, "PING\n")
    rt:tcpClose(id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpSend
-- Raw TCP connections. Focus: tcpSend.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp id = " .. id)
    rt:tcpSend(id, "PING\n")
    rt:tcpClose(id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpClose
-- Raw TCP connections. Focus: tcpClose.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp id = " .. id)
    rt:tcpSend(id, "PING\n")
    rt:tcpClose(id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsConnect
-- WebSocket connections. Focus: wsConnect.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws id = " .. id)
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    rt:wsClose(id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsSend
-- WebSocket connections. Focus: wsSend.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws id = " .. id)
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    rt:wsClose(id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsClose
-- WebSocket connections. Focus: wsClose.
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws id = " .. id)
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    rt:wsClose(id)
    rt:shutdown()
end

--@api-stub: lurek.network.createRoom
-- Room management.
do
    local room = lurek.network.createRoom("Arena", "player1", 8)
    print("room id=" .. room.id .. " name=" .. room.name)
    print("host=" .. room.host .. " max=" .. room.max_players)

    local joined = lurek.network.joinRoom(room.id)
    if joined then print("joined room") end

    local rooms = lurek.network.listRooms()
    print("rooms available = " .. #rooms)

    lurek.network.leaveRoom(room.id)
    print("left room")
end

--@api-stub: lurek.network.createLobby
-- Lobby discovery on LAN.
do
    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    print("lobby=" .. lobby.name .. " port=" .. lobby.port)
    print("max=" .. lobby.max_players)

    local found = lurek.network.discoverLobbies(2000)
    print("discovered = " .. #found)
    for _, l in ipairs(found) do
        print("  " .. l.name .. " at " .. l.host .. ":" .. l.port)
    end
end

--@api-stub: lurek.network.pack
-- Binary serialization roundtrip.
do
    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    print("packed bytes = " .. #packed)
    local unpacked = lurek.network.unpack(packed)
    print("unpacked hp = " .. (unpacked --[[@as table]]).hp)
end

--@api-stub: lurek.network.syncEntity
-- Synchronizes entity state across the network.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7790, maxPeers = 4})
    local entity_data = {x = 100, y = 200, hp = 50}
    lurek.network.syncEntity(server, 1, entity_data, 0, true)
    print("entity synced")
    server:destroy()
end

--@api-stub: lurek.network.predictLinear
-- Client-side prediction and server reconciliation.
do
    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    print("predicted x = " .. (predicted --[[@as table]]).x)

    local auth = {id = 1, tick = 11, x = 10.1, y = 20, vx = 5, vy = 0}
    local reconciled = lurek.network.reconcileSnapshot(predicted, auth, 0.3)
    print("reconciled x = " .. (reconciled --[[@as table]]).x)
end

--@api-stub: lurek.network.newRelayTicket
-- Relay ticket tokens.
do
    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    print("ticket = " .. token)
    local parsed = lurek.network.parseRelayTicket(token)
    if parsed then
        print("parsed room = " .. (parsed --[[@as table]]).room_id)
    end
end

--@api-stub: lurek.network.makePunchProbe
-- NAT punch-through probes.
do
    local probe = lurek.network.makePunchProbe("peer_99")
    print("probe = " .. probe)
    local peer_id = lurek.network.parsePunchProbe(probe)
    if peer_id then
        print("parsed peer = " .. peer_id)
    end
end

--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot


--@api-stub: LNetworkHost:destroy
-- Host lifecycle, role, and type introspection. Focus: destroy.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:getAddress
-- Host lifecycle, role, and type introspection. Focus: getAddress.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:getChannelLimit
-- Host lifecycle, role, and type introspection. Focus: getChannelLimit.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:getPeerLimit
-- Host lifecycle, role, and type introspection. Focus: getPeerLimit.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:getRole
-- Host lifecycle, role, and type introspection. Focus: getRole.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:isClient
-- Host lifecycle, role, and type introspection. Focus: isClient.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:isDestroyed
-- Host lifecycle, role, and type introspection. Focus: isDestroyed.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:isServer
-- Host lifecycle, role, and type introspection. Focus: isServer.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:type
-- Host lifecycle, role, and type introspection. Focus: type.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkHost:typeOf
-- Host lifecycle, role, and type introspection. Focus: typeOf.
do
    local host = lurek.network.newHost({ port = 0, max_peers = 4, channels = 2 })
    print("addr=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    print("peer_limit=" .. host:getPeerLimit())
    print("role=" .. host:getRole())
    print("is_server=" .. tostring(host:isServer()))
    print("is_client=" .. tostring(host:isClient()))
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    print("type=" .. host:type())
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkRuntime:shutdown
-- Runtime lifecycle and type introspection. Focus: shutdown.
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:type
-- Runtime lifecycle and type introspection. Focus: type.
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:typeOf
-- Runtime lifecycle and type introspection. Focus: typeOf.
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: lurek.network.discoverLobbies
-- Lobby and room management. Focus: discoverLobbies.
do
    local lobbies = lurek.network.discoverLobbies(1000)
    print("lobbies=" .. #lobbies)
    local rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    lurek.network.joinRoom("room_id_1")
    lurek.network.leaveRoom("room_id_1")
    print("room lifecycle ok")
end

--@api-stub: lurek.network.joinRoom
-- Lobby and room management. Focus: joinRoom.
do
    local lobbies = lurek.network.discoverLobbies(1000)
    print("lobbies=" .. #lobbies)
    local rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    lurek.network.joinRoom("room_id_1")
    lurek.network.leaveRoom("room_id_1")
    print("room lifecycle ok")
end

--@api-stub: lurek.network.leaveRoom
-- Lobby and room management. Focus: leaveRoom.
do
    local lobbies = lurek.network.discoverLobbies(1000)
    print("lobbies=" .. #lobbies)
    local rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    lurek.network.joinRoom("room_id_1")
    lurek.network.leaveRoom("room_id_1")
    print("room lifecycle ok")
end

--@api-stub: lurek.network.listRooms
-- Lobby and room management. Focus: listRooms.
do
    local lobbies = lurek.network.discoverLobbies(1000)
    print("lobbies=" .. #lobbies)
    local rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    lurek.network.joinRoom("room_id_1")
    lurek.network.leaveRoom("room_id_1")
    print("room lifecycle ok")
end

--@api-stub: lurek.network.parsePunchProbe
-- Relay and punch probe parsing. Focus: parsePunchProbe.
do
    local ok, probe = pcall(lurek.network.parsePunchProbe, "test_payload")
    print("probe=" .. tostring(ok))
    local ok2, ticket = pcall(lurek.network.parseRelayTicket, "test_token")
    print("ticket=" .. tostring(ok2))
end

--@api-stub: lurek.network.parseRelayTicket
-- Relay and punch probe parsing. Focus: parseRelayTicket.
do
    local ok, probe = pcall(lurek.network.parsePunchProbe, "test_payload")
    print("probe=" .. tostring(ok))
    local ok2, ticket = pcall(lurek.network.parseRelayTicket, "test_token")
    print("ticket=" .. tostring(ok2))
end

--@api-stub: lurek.network.reconcileSnapshot
-- Snapshot interpolation for netcode.
do
    local pred = { x = 10, y = 10 }
    local auth = { x = 12, y = 11 }
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    print("reconcile=" .. tostring(result ~= nil))
end

--@api-stub: lurek.network.unpack
-- Unpack a binary network payload.
do
    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    print("unpacked_id=" .. tostring(msg))
end

print("content/examples/network.lua")
