-- content/examples/network.lua
-- Auto-generated from content/examples2/network_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/network.lua

--- Network Module Part 1: LNetworkHost — server, client, peer management


--@api-stub: lurek.network.newServer
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    print("role = " .. server:getRole())
    server:destroy()
end

--@api-stub: lurek.network.newClient
do
    ---@type LNetworkHost
    local client = lurek.network.newClient({addr = "127.0.0.1:7777", channels = 2})
    print("role = " .. client:getRole())
    client:destroy()
end

--@api-stub: lurek.network.newHost
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    print("address = " .. host:getAddress())
    host:destroy()
end

--@api-stub: LNetworkHost:connect
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1})
    local peer_id = host:connect("127.0.0.1:7777", 2)
    print("connecting, peer_id = " .. peer_id)
    host:destroy()
end

--@api-stub: LNetworkHost:service
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7778, maxPeers = 4})
    local ev = server:service()
    print("service = " .. tostring(ev ~= nil))
    server:destroy()
end

--@api-stub: LNetworkHost:send
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7779, maxPeers = 8, channels = 2})
    print("send ready, channels = " .. server:getChannelLimit())
    server:destroy()
end

--@api-stub: LNetworkHost:broadcast
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7779, maxPeers = 8, channels = 2})
    print("broadcast ready, channels = " .. server:getChannelLimit())
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerCount
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7780, maxPeers = 4})
    print("connected = " .. server:getConnectedPeerCount())
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerIds
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7780, maxPeers = 4})
    local ids = server:getConnectedPeerIds()
    print("peer ids = " .. #ids)
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerState
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    print("peer state = " .. tostring(pcall(server.getPeerState, server, 1)))
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerAddress
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    print("peer addr = " .. tostring(pcall(server.getPeerAddress, server, 1)))
    server:destroy()
end

--@api-stub: LNetworkHost:getRoundTripTime
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7781, maxPeers = 4})
    print("peer rtt = " .. tostring(pcall(server.getRoundTripTime, server, 1)))
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerStats
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7782, maxPeers = 4})
    print("peer stats = " .. tostring(pcall(server.getPeerStats, server, 1)))
    server:destroy()
end

--@api-stub: LNetworkHost:setBandwidthLimit
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    print("bandwidth limit set")
    server:destroy()
end

--@api-stub: LNetworkHost:getBandwidthLimit
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    local bw = server:getBandwidthLimit()
    print("bw in=" .. bw.incoming .. " out=" .. bw.outgoing)
    server:destroy()
end

--@api-stub: LNetworkHost:setChannelLimit
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7784", maxPeers = 2, channels = 1})
    host:setChannelLimit(4)
    print("channels = " .. host:getChannelLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:disconnect
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    print("disconnect = " .. tostring(pcall(host.disconnect, host, 1, 0)))
    host:destroy()
end

--@api-stub: LNetworkHost:disconnectLater
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    print("disconnectLater = " .. tostring(pcall(host.disconnectLater, host, 1, 0)))
    host:destroy()
end

--@api-stub: LNetworkHost:disconnectNow
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:7785", maxPeers = 4})
    print("disconnectNow = " .. tostring(pcall(host.disconnectNow, host, 1, 0)))
    host:destroy()
end

--@api-stub: LNetworkHost:flush
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    host:flush()
    print("flushed")
    host:destroy()
end

--@api-stub: LNetworkHost:ping
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    print("ping = " .. tostring(pcall(host.ping, host, 1)))
    host:destroy()
end

--@api-stub: LNetworkHost:resetPeer
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    print("reset = " .. tostring(pcall(host.resetPeer, host, 1)))
    host:destroy()
end

--- Network Module Part 2: LNetworkRuntime, rooms, lobbies, pack/unpack, prediction


--@api-stub: lurek.network.newRuntime
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    print("runtime created")
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpGet
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpGet("https://example.com/api/status")
    print("GET request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpPost
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpPost("https://example.com/api/data", '{"key":"value"}', {["Content-Type"] = "application/json"})
    print("POST request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpRequest
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpRequest({url = "https://example.com/api/resource", method = "PUT", body = "updated data", timeout = 5000})
    print("custom request id = " .. req_id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:poll
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local events = rt:poll()
    print("events = " .. #events)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpConnect
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp id = " .. id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpSend
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp send = " .. tostring(pcall(rt.tcpSend, rt, id, "PING\n")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpClose
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9000")
    print("tcp close = " .. tostring(pcall(rt.tcpClose, rt, id)))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsConnect
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws id = " .. id)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsSend
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws send = " .. tostring(pcall(rt.wsSend, rt, id, '{"action":"join","room":"lobby"}')))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsClose
do
    ---@type LNetworkRuntime
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:9001/game")
    print("ws close = " .. tostring(pcall(rt.wsClose, rt, id)))
    rt:shutdown()
end

--@api-stub: lurek.network.createRoom
do
    local room = lurek.network.createRoom("Arena", "player1", 8)
    print("room id=" .. room.id .. " name=" .. room.name)
    lurek.network.leaveRoom(room.id)
    print("left room")
end

--@api-stub: lurek.network.createLobby
do
    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    print("lobby=" .. lobby.name .. " port=" .. lobby.port)
    local found = lurek.network.discoverLobbies(2000)
    print("discovered = " .. #found)
end

--@api-stub: lurek.network.pack
do
    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    print("packed bytes = " .. #packed)
    local unpacked = lurek.network.unpack(packed)
    print("unpacked hp = " .. (unpacked --[[@as table]]).hp)
end

--@api-stub: lurek.network.syncEntity
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7790, maxPeers = 4})
    lurek.network.syncEntity(server, 1, {x = 100, y = 200, hp = 50}, 0, true)
    print("entity synced")
    server:destroy()
end

--@api-stub: lurek.network.predictLinear
do
    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    print("predicted x = " .. (predicted --[[@as table]]).x)
end

--@api-stub: lurek.network.newRelayTicket
do
    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    print("ticket = " .. token)
end

--@api-stub: lurek.network.makePunchProbe
do
    local probe = lurek.network.makePunchProbe("peer_99")
    print("probe = " .. probe)
end

--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot


--@api-stub: LNetworkHost:destroy
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("destroyable = " .. tostring(not host:isDestroyed()))
    host:destroy()
end

--@api-stub: LNetworkHost:getAddress
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("addr=" .. host:getAddress())
    host:destroy()
end

--@api-stub: LNetworkHost:getChannelLimit
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:getPeerLimit
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("peer_limit=" .. host:getPeerLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:getRole
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("role=" .. host:getRole())
    host:destroy()
end

--@api-stub: LNetworkHost:isClient
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_client=" .. tostring(host:isClient()))
    host:destroy()
end

--@api-stub: LNetworkHost:isDestroyed
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    host:destroy()
end

--@api-stub: LNetworkHost:isServer
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_server=" .. tostring(host:isServer()))
    host:destroy()
end

--@api-stub: LNetworkHost:type
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("type=" .. host:type())
    host:destroy()
end

--@api-stub: LNetworkHost:typeOf
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("typeOf=" .. tostring(host:typeOf("LNetworkHost")))
    host:destroy()
end

--@api-stub: LNetworkRuntime:shutdown
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:type
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:typeOf
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: lurek.network.discoverLobbies
do
    local lobbies = lurek.network.discoverLobbies(1000)
    print("lobbies=" .. #lobbies)
end

--@api-stub: lurek.network.joinRoom
do
    print("joined=" .. tostring(pcall(lurek.network.joinRoom, "room_id_1")))
end

--@api-stub: lurek.network.leaveRoom
do
    print("left=" .. tostring(pcall(lurek.network.leaveRoom, "room_id_1")))
end

--@api-stub: lurek.network.listRooms
do
    local rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
end

--@api-stub: lurek.network.parsePunchProbe
do
    local ok, probe = pcall(lurek.network.parsePunchProbe, "test_payload")
    print("probe=" .. tostring(ok))
    local ok2, ticket = pcall(lurek.network.parseRelayTicket, "test_token")
    print("ticket=" .. tostring(ok2))
end

--@api-stub: lurek.network.parseRelayTicket
do
    local ok, probe = pcall(lurek.network.parsePunchProbe, "test_payload")
    print("probe=" .. tostring(ok))
    local ok2, ticket = pcall(lurek.network.parseRelayTicket, "test_token")
    print("ticket=" .. tostring(ok2))
end

--@api-stub: lurek.network.reconcileSnapshot
do
    local pred = { x = 10, y = 10 }
    local auth = { x = 12, y = 11 }
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    print("reconcile=" .. tostring(result ~= nil))
end

--@api-stub: lurek.network.unpack
do
    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    print("unpacked_id=" .. tostring(msg))
end

print("content/examples/network.lua")
