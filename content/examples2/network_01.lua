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
--@api-stub: LNetworkRuntime:tcpSend
--@api-stub: LNetworkRuntime:tcpClose
-- Raw TCP connections.
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
--@api-stub: LNetworkRuntime:wsSend
--@api-stub: LNetworkRuntime:wsClose
-- WebSocket connections.
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
--@api-stub: lurek.joinRoom
--@api-stub: lurek.leaveRoom
--@api-stub: lurek.listRooms
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
--@api-stub: lurek.discoverLobbies
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
--@api-stub: lurek.unpack
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
--@api-stub: lurek.reconcileSnapshot
-- Client-side prediction and server reconciliation.
do
    local snapshot = {x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    print("predicted x = " .. (predicted --[[@as table]]).x)

    local auth = {x = 10.1, y = 20}
    local reconciled = lurek.network.reconcileSnapshot(predicted, auth, 0.3)
    print("reconciled x = " .. (reconciled --[[@as table]]).x)
end

--@api-stub: lurek.network.newRelayTicket
--@api-stub: lurek.parseRelayTicket
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
--@api-stub: lurek.parsePunchProbe
-- NAT punch-through probes.
do
    local probe = lurek.network.makePunchProbe("peer_99")
    print("probe = " .. probe)
    local peer_id = lurek.network.parsePunchProbe(probe)
    if peer_id then
        print("parsed peer = " .. peer_id)
    end
end

print("network_01.lua")
