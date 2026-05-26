-- content/examples/network.lua
-- Auto-generated from content/examples2/network_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/network.lua

--- Network Module Part 1: LNetworkHost — server, client, peer management

local function wait_for_event(host, expected_type, max_attempts)
    max_attempts = max_attempts or 60
    for _ = 1, max_attempts do
        local event = host:service()
        if event and (expected_type == nil or event.type == expected_type) then
            return event
        end
        host:flush()
    end
    return nil
end

local function connect_pair(port, channels)
    local server = lurek.network.newServer({port = port, maxPeers = 4, channels = channels or 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = channels or 2, data = 99})
    local server_connect = nil
    local client_connect = nil

    for _ = 1, 60 do
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

--@api-stub: lurek.network.newServer
do
    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    print("role=" .. server:getRole())
    print("peer_limit=" .. server:getPeerLimit())
    server:destroy()
end

--@api-stub: lurek.network.newClient
do
    local server = lurek.network.newServer({port = 7778, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7778", channels = 2, data = 21})
    print("role=" .. client:getRole())
    print("type=" .. client:type())
    client:destroy()
    server:destroy()
end

--@api-stub: lurek.network.newHost
do
    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    print("address=" .. host:getAddress())
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:connect
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

--@api-stub: LNetworkHost:service
do
    local server, client, server_connect = connect_pair(7780, 2)
    print("event_type=" .. tostring(server_connect and server_connect.type or "nil"))
    print("peer_id=" .. tostring(server_connect and server_connect.peer_id or "nil"))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:send
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

--@api-stub: LNetworkHost:broadcast
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

--@api-stub: LNetworkHost:getConnectedPeerCount
do
    local server, client = connect_pair(7783, 2)
    print("connected=" .. server:getConnectedPeerCount())
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerIds
do
    local server, client = connect_pair(7784, 2)
    local ids = server:getConnectedPeerIds()
    print("peer_count=" .. #ids)
    print("first_peer=" .. tostring(ids[1]))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerState
do
    local server, client, server_connect = connect_pair(7785, 2)
    print("peer_state=" .. server:getPeerState(server_connect.peer_id))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerAddress
do
    local server, client, server_connect = connect_pair(7786, 2)
    print("peer_addr=" .. tostring(server:getPeerAddress(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:getRoundTripTime
do
    local server, client, server_connect = connect_pair(7787, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    print("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerStats
do
    local server, client, server_connect = connect_pair(7788, 2)
    local stats = server:getPeerStats(server_connect.peer_id)
    print("packets_sent=" .. stats.packets_sent)
    print("rtt_ms=" .. stats.round_trip_time)
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:setBandwidthLimit
do
    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    local limits = server:getBandwidthLimit()
    print("incoming=" .. tostring(limits.incoming))
    print("outgoing=" .. tostring(limits.outgoing))
    server:destroy()
end

--@api-stub: LNetworkHost:getBandwidthLimit
do
    local server = lurek.network.newServer({port = 7789, maxPeers = 4})
    server:setBandwidthLimit(64000, 32000)
    local bw = server:getBandwidthLimit()
    print("bw_in=" .. tostring(bw.incoming))
    print("bw_out=" .. tostring(bw.outgoing))
    server:destroy()
end

--@api-stub: LNetworkHost:setChannelLimit
do
    local host = lurek.network.newHost({addr = "0.0.0.0:7790", maxPeers = 2, channels = 1})
    host:setChannelLimit(4)
    print("channels=" .. host:getChannelLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:disconnect
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

--@api-stub: LNetworkHost:disconnectLater
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

--@api-stub: LNetworkHost:disconnectNow
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

--@api-stub: LNetworkHost:flush
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

--@api-stub: LNetworkHost:ping
do
    local server, client, server_connect = connect_pair(7795, 2)
    server:ping(server_connect.peer_id)
    server:flush()
    print("peer_state=" .. server:getPeerState(server_connect.peer_id))
    print("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:resetPeer
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

--- Network Module Part 2: LNetworkRuntime, rooms, lobbies, pack/unpack, prediction

--@api-stub: lurek.network.newRuntime
do
    local rt = lurek.network.newRuntime()
    print("type=" .. rt:type())
    print("typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpGet
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpGet("http://127.0.0.1:1/status", {Accept = "text/plain"})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpPost
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpPost("http://127.0.0.1:1/data", '{"key":"value"}', {["Content-Type"] = "application/json"})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:httpRequest
do
    local rt = lurek.network.newRuntime()
    local req_id = rt:httpRequest({url = "http://127.0.0.1:1/resource", method = "PUT", body = "updated data", timeout = 5})
    print("request_id=" .. req_id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:poll
do
    local rt = lurek.network.newRuntime()
    rt:httpGet("http://127.0.0.1:1/poll")
    local events = rt:poll()
    print("events=" .. #events)
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpConnect
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpSend
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpSend(id, "PING\n")
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:tcpClose
do
    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpClose(id)
    print("tcp_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsConnect
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsSend
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:wsClose
do
    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsClose(id)
    print("ws_id=" .. id)
    print("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api-stub: lurek.network.createRoom
do
    local room = lurek.network.createRoom("Arena", "player1", 8)
    local joined = lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    print("room_id=" .. room.id)
    print("players=" .. joined.player_count .. "->" .. left.player_count)
end

--@api-stub: lurek.network.createLobby
do
    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    local found = lurek.network.discoverLobbies(200)
    print("lobby=" .. lobby.name .. ":" .. lobby.port)
    print("discovered=" .. #found)
end

--@api-stub: lurek.network.pack
do
    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    local unpacked = lurek.network.unpack(packed)
    print("packed_bytes=" .. #packed)
    print("unpacked_name=" .. unpacked.name)
end

--@api-stub: lurek.network.syncEntity
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

--@api-stub: lurek.network.predictLinear
do
    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    print("tick=" .. predicted.tick)
    print("x=" .. predicted.x)
end

--@api-stub: lurek.network.newRelayTicket
do
    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    local ticket = lurek.network.parseRelayTicket(token)
    print("ticket=" .. token)
    print("peer_id=" .. ticket.peer_id)
end

--@api-stub: lurek.network.makePunchProbe
do
    local probe = lurek.network.makePunchProbe("peer_99")
    local peer_id = lurek.network.parsePunchProbe(probe)
    print("probe_bytes=" .. #probe)
    print("peer_id=" .. tostring(peer_id))
end

--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot

--@api-stub: LNetworkHost:destroy
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("before=" .. tostring(host:isDestroyed()))
    host:destroy()
    print("after=" .. tostring(host:isDestroyed()))
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
    local server = lurek.network.newServer({port = 7798, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7798", channels = 2})
    print("is_client=" .. tostring(client:isClient()))
    client:destroy()
    server:destroy()
end

--@api-stub: LNetworkHost:isDestroyed
do
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    print("is_destroyed=" .. tostring(host:isDestroyed()))
    host:destroy()
end

--@api-stub: LNetworkHost:isServer
do
    local server = lurek.network.newServer({port = 7799, maxPeers = 4, channels = 2})
    print("is_server=" .. tostring(server:isServer()))
    server:destroy()
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
    rt:shutdown()
    print("shutdown=true")
end

--@api-stub: LNetworkRuntime:type
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    rt:shutdown()
end

--@api-stub: LNetworkRuntime:typeOf
do
    local rt = lurek.network.newRuntime()
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: lurek.network.discoverLobbies
do
    lurek.network.createLobby("Discovery", 7788, 1, 4)
    local lobbies = lurek.network.discoverLobbies(200)
    print("lobbies=" .. #lobbies)
    print("first_name=" .. tostring(lobbies[1] and lobbies[1].name or "nil"))
end

--@api-stub: lurek.network.joinRoom
do
    local room = lurek.network.createRoom("Joinable", "host-B", 4)
    local joined = lurek.network.joinRoom(room.id)
    print("room_id=" .. room.id)
    print("player_count=" .. joined.player_count)
end

--@api-stub: lurek.network.leaveRoom
do
    local room = lurek.network.createRoom("Leavable", "host-C", 4)
    lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    print("room_id=" .. room.id)
    print("player_count=" .. left.player_count)
end

--@api-stub: lurek.network.listRooms
do
    local rooms = lurek.network.listRooms()
    local room = lurek.network.createRoom("Listed", "host-D", 3)
    rooms = lurek.network.listRooms()
    print("rooms=" .. #rooms)
    print("last_room=" .. room.name)
end

--@api-stub: lurek.network.parsePunchProbe
do
    local probe = lurek.network.makePunchProbe("peer_parse")
    local peer_id = lurek.network.parsePunchProbe(probe)
    print("peer_id=" .. tostring(peer_id))
end

--@api-stub: lurek.network.parseRelayTicket
do
    local token = lurek.network.newRelayTicket("room_parse", "peer_parse")
    local ticket = lurek.network.parseRelayTicket(token)
    print("room_id=" .. ticket.room_id)
    print("peer_id=" .. ticket.peer_id)
end

--@api-stub: lurek.network.reconcileSnapshot
do
    local pred = {id = 3, tick = 20, x = 10, y = 10, vx = 1, vy = 0}
    local auth = {id = 3, tick = 21, x = 12, y = 11, vx = 1, vy = 0}
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    print("tick=" .. result.tick)
    print("x=" .. result.x)
end

--@api-stub: lurek.network.unpack
do
    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    print("id=" .. msg.id)
    print("data=" .. msg.data)
end
