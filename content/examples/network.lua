-- content/examples/network.lua
-- Auto-generated from content/examples2/network_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/network.lua


--- Network Module Part 1: LNetworkHost — server, client, peer management


--@api: lurek.network.newServer
do

    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    local limits = server:getBandwidthLimit()
    local metrics = server:getMetrics()
    lurek.log.info("dedicated server role=" .. server:getRole() .. " addr=" .. server:getAddress())
    lurek.log.info("peer_limit=" .. server:getPeerLimit() .. " channels=" .. server:getChannelLimit())
    lurek.log.info("bw=" .. tostring(limits.incoming) .. "/" .. tostring(limits.outgoing) .. " connected=" .. metrics.connected_peers)
    server:destroy()
end

--@api: lurek.network.newClient
do

    local server = lurek.network.newServer({port = 7778, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7778", channels = 2, data = 21})
    lurek.log.info("role=" .. client:getRole())
    lurek.log.info("type=" .. client:type())
    client:destroy()
    server:destroy()
end

--@api: lurek.network.newHost
do

    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    local metrics = host:getMetrics()
    local limits = host:getBandwidthLimit()
    lurek.log.info("listen host addr=" .. host:getAddress() .. " role=" .. host:getRole())
    lurek.log.info("channels=" .. host:getChannelLimit() .. " peers=" .. host:getPeerLimit())
    lurek.log.info("bw=" .. tostring(limits.incoming) .. "/" .. tostring(limits.outgoing) .. " connected=" .. metrics.connected_peers)
    host:destroy()
end

--@api: LNetworkHost:connect
do


    local server = lurek.network.newServer({port = 7779, maxPeers = 4, channels = 2})
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1, channels = 2})
    local peer_id = host:connect("127.0.0.1:7779", 2, 17)
    local event = nil
    for _ = 1, 8 do
        local polled = server:service()
        if polled and polled.type == "connect" then
            event = polled
            break
        end
    end
    lurek.log.info("peer_id=" .. peer_id)
    lurek.log.info("server_event=" .. tostring(event and event.type or "nil"))
    host:destroy()
    server:destroy()
end

--@api: LNetworkHost:service
do


    local server = lurek.network.newServer({port = 7780, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7780, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    lurek.log.info("event_type=" .. tostring(server_connect and server_connect.type or "nil"))
    lurek.log.info("peer_id=" .. tostring(server_connect and server_connect.peer_id or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:send
do



    local server = lurek.network.newServer({port = 7781, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7781, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:send(server_connect.peer_id, 0, "welcome", true)
    server:flush()
    local event = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "receive" then
            event = polled
            break
        end
    end
    lurek.log.info("event_type=" .. tostring(event and event.type or "nil"))
    lurek.log.info("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:broadcast
do



    local server = lurek.network.newServer({port = 7782, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7782, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:broadcast(1, "state:update", true)
    server:flush()
    local event = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "receive" then
            event = polled
            break
        end
    end
    lurek.log.info("channel=" .. tostring(event and event.channel_id or "nil"))
    lurek.log.info("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getConnectedPeerCount
do


    local server = lurek.network.newServer({port = 7783, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7783, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    lurek.log.info("connected=" .. server:getConnectedPeerCount())
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getConnectedPeerIds
do


    local server = lurek.network.newServer({port = 7784, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7784, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    local ids = server:getConnectedPeerIds()
    lurek.log.info("peer_count=" .. #ids)
    lurek.log.info("first_peer=" .. tostring(ids[1]))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getPeerState
do


    local server = lurek.network.newServer({port = 7785, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7785, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    lurek.log.info("peer_state=" .. server:getPeerState(server_connect.peer_id))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getPeerAddress
do


    local server = lurek.network.newServer({port = 7786, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7786, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    lurek.log.info("peer_addr=" .. tostring(server:getPeerAddress(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getRoundTripTime
do


    local server = lurek.network.newServer({port = 7787, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7787, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:ping(server_connect.peer_id)
    server:flush()
    lurek.log.info("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:getPeerStats
do


    local server = lurek.network.newServer({port = 7788, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7788, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    local stats = server:getPeerStats(server_connect.peer_id)
    lurek.log.info("packets_sent=" .. stats.packets_sent)
    lurek.log.info("rtt_ms=" .. stats.round_trip_time)
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:setBandwidthLimit
do

    local server = lurek.network.newServer({port = 7783, maxPeers = 4})
    server:setBandwidthLimit(100000, 50000)
    local limits = server:getBandwidthLimit()
    lurek.log.info("incoming=" .. tostring(limits.incoming))
    lurek.log.info("outgoing=" .. tostring(limits.outgoing))
    server:destroy()
end

--@api: LNetworkHost:getBandwidthLimit
do

    local server = lurek.network.newServer({port = 7789, maxPeers = 4})
    server:setBandwidthLimit(64000, 32000)
    local bw = server:getBandwidthLimit()
    lurek.log.info("bw_in=" .. tostring(bw.incoming))
    lurek.log.info("bw_out=" .. tostring(bw.outgoing))
    server:destroy()
end

--@api: LNetworkHost:setChannelLimit
do

    local host = lurek.network.newHost({addr = "0.0.0.0:7790", maxPeers = 2, channels = 1})
    local before = host:getChannelLimit()
    host:setChannelLimit(4)
    local after = host:getChannelLimit()
    local peers = host:getPeerLimit()
    lurek.log.info("match channels before=" .. before .. " after=" .. after)
    lurek.log.info("peer slots remain=" .. peers)
    host:destroy()
end

--@api: LNetworkHost:disconnect
do



    local server = lurek.network.newServer({port = 7791, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7791, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:disconnect(server_connect.peer_id, 7)
    server:flush()
    local event = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "disconnect" then
            event = polled
            break
        end
    end
    lurek.log.info("event_type=" .. tostring(event and event.type or "nil"))
    lurek.log.info("data=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:disconnectLater
do



    local server = lurek.network.newServer({port = 7792, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7792, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:send(server_connect.peer_id, 0, "queued-goodbye", true)
    server:disconnectLater(server_connect.peer_id, 8)
    server:flush()
    local receive = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "receive" then
            receive = polled
            break
        end
    end
    local disconnect = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "disconnect" then
            disconnect = polled
            break
        end
    end
    lurek.log.info("payload=" .. tostring(receive and receive.data or "nil"))
    lurek.log.info("disconnect_data=" .. tostring(disconnect and disconnect.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:disconnectNow
do



    local server = lurek.network.newServer({port = 7793, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7793, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:disconnectNow(server_connect.peer_id, 9)
    server:flush()
    local event = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "disconnect" then
            event = polled
            break
        end
    end
    lurek.log.info("event_type=" .. tostring(event and event.type or "nil"))
    lurek.log.info("data=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:flush
do



    local server = lurek.network.newServer({port = 7794, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7794, channels = 2, data = 99})
    local _ = nil
    local client_connect = nil
    for _ = 1, 8 do
        server:flush()
        client:flush()
        if not _ then
            local event = server:service()
            if event and event.type == "connect" then
                _ = event
            end
        end
        if not client_connect then
            local event = client:service()
            if event and event.type == "connect" then
                client_connect = event
            end
        end
        if not _ then
            local ids = server:getConnectedPeerIds()
            if ids[1] ~= nil then
                _ = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if _ and client_connect then
            break
        end
    end
    if client_connect then
        client:send(client_connect.peer_id, 0, "flush-check", true)
        client:flush()
    end
    local event = nil
    for _ = 1, 8 do
        local polled = server:service()
        if polled and polled.type == "receive" then
            event = polled
            break
        end
    end
    lurek.log.info("client connected=" .. tostring(client_connect ~= nil))
    lurek.log.info("event_type=" .. tostring(event and event.type or "nil"))
    lurek.log.info("payload=" .. tostring(event and event.data or "nil"))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:ping
do


    local server = lurek.network.newServer({port = 7795, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7795, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:ping(server_connect.peer_id)
    server:flush()
    lurek.log.info("peer_state=" .. server:getPeerState(server_connect.peer_id))
    lurek.log.info("rtt_ms=" .. math.floor(server:getRoundTripTime(server_connect.peer_id)))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:resetPeer
do


    local server = lurek.network.newServer({port = 7796, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7796, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    server:resetPeer(server_connect.peer_id)
    server:service()
    client:service()
    lurek.log.info("reset_peer=" .. server_connect.peer_id)
    lurek.log.info("connected=" .. server:getConnectedPeerCount())
    client:destroy()
    server:destroy()
end

--- Network Module Part 2: rooms, lobbies, pack/unpack, prediction























--@api: lurek.network.createRoom
do

    local room = lurek.network.createRoom("Arena", "player1", 8)
    local joined = lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    lurek.log.info("room_id=" .. room.id)
    lurek.log.info("players=" .. joined.player_count .. "->" .. left.player_count)
end

--@api: lurek.network.createLobby
do

    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    local found = lurek.network.discoverLobbies(10)
    local room = lurek.network.createRoom("My Game staging", "host-A", 4)
    local rooms = lurek.network.listRooms()
    lurek.log.info("lobby=" .. lobby.name .. ":" .. lobby.port .. " players=" .. lobby.player_count .. "/" .. lobby.max_players)
    lurek.log.info("discoveries=" .. #found .. " local_rooms=" .. #rooms .. " staging=" .. room.id)
end

--@api: lurek.network.pack
do

    local data = {hp = 100, pos = {x = 10.5, y = 20.3}, name = "Hero"}
    local packed = lurek.network.pack(data)
    local unpacked = lurek.network.unpack(packed)
    lurek.log.info("packed_bytes=" .. #packed)
    lurek.log.info("unpacked_name=" .. unpacked.name)
end

--@api: lurek.network.syncEntity
do



    local server = lurek.network.newServer({port = 7797, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. 7797, channels = 2, data = 99})
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
                server_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if not client_connect then
            local ids = client:getConnectedPeerIds()
            if ids[1] ~= nil then
                client_connect = { type = "connect", peer_id = ids[1] }
            end
        end
        if server_connect and client_connect then
            break
        end
    end
    lurek.network.syncEntity(server, 1, {x = 100, y = 200, hp = 50}, 0, true)
    server:flush()
    local event = nil
    for _ = 1, 8 do
        local polled = client:service()
        if polled and polled.type == "receive" then
            event = polled
            break
        end
    end
    local payload = lurek.network.unpack(event.data)
    lurek.log.info("entity_id=" .. payload.id)
    lurek.log.info("hp=" .. payload.data.hp)
    client:destroy()
    server:destroy()
end

--@api: lurek.network.predictLinear
do

    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = 0}
    local predicted = lurek.network.predictLinear(snapshot, 0.016)
    local auth = {id = 1, tick = 11, x = 10.3, y = 20, vx = 5, vy = 0}
    local corrected = lurek.network.reconcileSnapshot(predicted, auth, 0.5)
    lurek.log.info("predicted tick=" .. predicted.tick .. " pos=" .. predicted.x .. "," .. predicted.y)
    lurek.log.info("corrected pos=" .. corrected.x .. "," .. corrected.y)
end

--@api: lurek.network.newRelayTicket
do

    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    local ticket = lurek.network.parseRelayTicket(token)
    local packed = lurek.network.pack({ room = ticket.room_id, peer = ticket.peer_id })
    local unpacked = lurek.network.unpack(packed)
    lurek.log.info("relay room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
    lurek.log.info("packed mirror room=" .. unpacked.room .. " token_bytes=" .. #token)
end

--@api: lurek.network.makePunchProbe
do

    local probe = lurek.network.makePunchProbe("peer_99")
    local peer_id = lurek.network.parsePunchProbe(probe)
    local relay = lurek.network.newRelayTicket("room_probe", peer_id)
    local ticket = lurek.network.parseRelayTicket(relay)
    lurek.log.info("probe bytes=" .. #probe .. " peer=" .. tostring(peer_id))
    lurek.log.info("relay pairing room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
end

--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot

--@api: LNetworkHost:destroy
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local before = host:isDestroyed()
    local role = host:getRole()
    host:destroy()
    local after = host:isDestroyed()
    lurek.log.info("host role=" .. role .. " before_destroy=" .. tostring(before))
    lurek.log.info("after_destroy=" .. tostring(after))
end

--@api: LNetworkHost:getAddress
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local addr = host:getAddress()
    local role = host:getRole()
    local peers = host:getPeerLimit()
    lurek.log.info("local host addr=" .. addr)
    lurek.log.info("role=" .. role .. " peer_limit=" .. peers)
    host:destroy()
end

--@api: LNetworkHost:getChannelLimit
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local channels = host:getChannelLimit()
    local peers = host:getPeerLimit()
    local role = host:getRole()
    lurek.log.info("channel budget=" .. channels)
    lurek.log.info("peer_limit=" .. peers .. " role=" .. role)
    host:destroy()
end

--@api: LNetworkHost:getPeerLimit
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local peers = host:getPeerLimit()
    local channels = host:getChannelLimit()
    local addr = host:getAddress()
    lurek.log.info("peer cap=" .. peers)
    lurek.log.info("channels=" .. channels .. " addr=" .. addr)
    host:destroy()
end

--@api: LNetworkHost:getRole
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local role = host:getRole()
    local typeName = host:type()
    local addr = host:getAddress()
    lurek.log.info("host role=" .. role)
    lurek.log.info("type=" .. typeName .. " addr=" .. addr)
    host:destroy()
end

--@api: LNetworkHost:isClient
do

    local server = lurek.network.newServer({port = 7798, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:7798", channels = 2})
    lurek.log.info("is_client=" .. tostring(client:isClient()))
    client:destroy()
    server:destroy()
end

--@api: LNetworkHost:isDestroyed
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local before = host:isDestroyed()
    local role = host:getRole()
    host:destroy()
    local after = host:isDestroyed()
    lurek.log.info("role=" .. role .. " before_destroyed=" .. tostring(before))
    lurek.log.info("after_destroyed=" .. tostring(after))
end

--@api: LNetworkHost:isServer
do

    local server = lurek.network.newServer({port = 7799, maxPeers = 4, channels = 2})
    local role = server:getRole()
    local isServer = server:isServer()
    local channels = server:getChannelLimit()
    lurek.log.info("role=" .. role .. " is_server=" .. tostring(isServer))
    lurek.log.info("channel_limit=" .. channels)
    server:destroy()
end

--@api: LNetworkHost:type
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local typeName = host:type()
    local role = host:getRole()
    local destroyed = host:isDestroyed()
    lurek.log.info("host userdata=" .. typeName)
    lurek.log.info("role=" .. role .. " destroyed=" .. tostring(destroyed))
    host:destroy()
end

--@api: LNetworkHost:typeOf
do

    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    local isHost = host:typeOf("LNetworkHost")
    local isObject = host:typeOf("LObject")
    lurek.log.info("typeOf host=" .. tostring(isHost) .. " object=" .. tostring(isObject))
    lurek.log.info("runtime check=" .. tostring(isRuntime) .. " type=" .. host:type())
    host:destroy()
end







--@api: lurek.network.discoverLobbies
do

    lurek.network.createLobby("Discovery", 7788, 1, 4)
    local lobbies = lurek.network.discoverLobbies(10)
    local room = lurek.network.createRoom("Discovery staging", "host-discovery", 4)
    local rooms = lurek.network.listRooms()
    lurek.log.info("lan lobbies=" .. #lobbies)
    lurek.log.info("first=" .. tostring(lobbies[1] and lobbies[1].name or "nil") .. " local_rooms=" .. #rooms .. " staging=" .. room.id)
end

--@api: lurek.network.joinRoom
do

    local room = lurek.network.createRoom("Joinable", "host-B", 4)
    local joined = lurek.network.joinRoom(room.id)
    local players = lurek.network.getPlayerList(room.id)
    local meta = lurek.network.getRoom(room.id)
    lurek.log.info("joined room=" .. tostring(room.id) .. " name=" .. tostring(joined.name))
    lurek.log.info("player_count=" .. tostring(joined.player_count) .. " tracked_players=" .. #players .. " meta_host=" .. tostring(meta.host))
end

--@api: lurek.network.leaveRoom
do

    local room = lurek.network.createRoom("Leavable", "host-C", 4)
    lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    lurek.log.info("room_id=" .. room.id)
    lurek.log.info("player_count=" .. left.player_count)
end

--@api: lurek.network.listRooms
do

    local rooms = lurek.network.listRooms()
    local room = lurek.network.createRoom("Listed", "host-D", 3)
    rooms = lurek.network.listRooms()
    lurek.log.info("rooms=" .. #rooms)
    lurek.log.info("last_room=" .. room.name)
end

--@api: lurek.network.parsePunchProbe
do

    local probe = lurek.network.makePunchProbe("peer_parse")
    local peer_id = lurek.network.parsePunchProbe(probe)
    local relay = lurek.network.newRelayTicket("room_parse_probe", peer_id)
    local ticket = lurek.network.parseRelayTicket(relay)
    lurek.log.info("parsed probe peer=" .. tostring(peer_id))
    lurek.log.info("relay room=" .. ticket.room_id .. " peer=" .. ticket.peer_id)
end

--@api: lurek.network.parseRelayTicket
do

    local token = lurek.network.newRelayTicket("room_parse", "peer_parse")
    local ticket = lurek.network.parseRelayTicket(token)
    local packed = lurek.network.pack({ room = ticket.room_id, peer = ticket.peer_id })
    local unpacked = lurek.network.unpack(packed)
    lurek.log.info("ticket room=" .. ticket.room_id)
    lurek.log.info("ticket peer=" .. tostring(ticket.peer_id) .. " unpacked_peer=" .. tostring(unpacked.peer))
end

--@api: lurek.network.reconcileSnapshot
do

    local pred = {id = 3, tick = 20, x = 10, y = 10, vx = 1, vy = 0}
    local auth = {id = 3, tick = 21, x = 12, y = 11, vx = 1, vy = 0}
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.5)
    lurek.log.info("tick=" .. result.tick)
    lurek.log.info("x=" .. result.x)
end

--@api: lurek.network.unpack
do

    local raw = lurek.network.pack({ id = 1, data = "hello" })
    local msg = lurek.network.unpack(raw)
    local packedSnapshot = lurek.network.pack({ id = msg.id, tag = "chat", body = msg.data })
    local echo = lurek.network.unpack(packedSnapshot)
    lurek.log.info("message id=" .. msg.id .. " body=" .. msg.data)
    lurek.log.info("echo tag=" .. echo.tag .. " raw_bytes=" .. #raw)
end































--@api: LNetworkHost:registerLease
do

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(1, 30)
    local peer = host:getLeasePeer(token)
    local renewed = host:renewLease(token, 45)
    lurek.log.info("lease token=" .. tostring(token) .. " peer=" .. tostring(peer))
    lurek.log.info("renewed=" .. tostring(renewed))
    host:destroy()
end

--@api: LNetworkHost:getLeasePeer
do

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(2, 30)
    local peer_id = host:getLeasePeer(token)
    lurek.log.info("lease peer: " .. tostring(peer_id))
    host:destroy()
end

--@api: LNetworkHost:renewLease
do

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(3, 30)
    local success = host:renewLease(token, 60)
    lurek.log.info("lease renew: " .. tostring(success))
    host:destroy()
end

--@api: LNetworkHost:clearLease
do

    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(4, 30)
    host:clearLease(token)
    lurek.log.info("cleared lease: " .. tostring(host:getLeasePeer(token) == nil))
    host:destroy()
end

--@api: LNetworkHost:getMetrics
do

    local host = lurek.network.newHost({ port = 0 })
    local metrics = host:getMetrics()
    local role = host:getRole()
    local addr = host:getAddress()
    lurek.log.info("host metrics peers=" .. tostring(metrics.connected_peers))
    lurek.log.info("role=" .. role .. " addr=" .. addr)
    host:destroy()
end



--@api: lurek.network.packSnapshot
do

    local snapshot = {
        type = "full",
        tick = 100,
        entities = {
            { id = 1, tick = 100, x = 10.0, y = 20.0, vx = 1.0, vy = 0.0 }
        }
    }
    local packed = lurek.network.packSnapshot(snapshot)
    lurek.log.info("packed_snapshot_bytes=" .. #packed)
end

--@api: lurek.network.unpackSnapshot
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
    lurek.log.info("unpacked_type=" .. unpacked.type)
    lurek.log.info("unpacked_tick=" .. unpacked.tick)
end

--@api: lurek.network.reconcileWithPolicy
do

    local pred = { id = 1, tick = 10, x = 10.0, y = 0.0, vx = 0.0, vy = 0.0 }
    local auth = { id = 1, tick = 10, x = 12.0, y = 0.0, vx = 1.0, vy = 2.0 }
    local result = lurek.network.reconcileWithPolicy(pred, auth, 0.5, 0.2, 5.0)
    local hardSnap = lurek.network.reconcileWithPolicy(pred, { id = 1, tick = 10, x = 20.0, y = 0.0, vx = 1.0, vy = 2.0 }, 0.5, 0.2, 5.0)
    lurek.log.info("soft reconcile x=" .. result.x .. " y=" .. result.y)
    lurek.log.info("hard reconcile x=" .. hardSnap.x .. " vx=" .. hardSnap.vx)
end

--@api: lurek.network.setReady
do

    lurek.network.setReady("game_room", 1, true)
    lurek.network.setReady("game_room", 2, false)
    local players = lurek.network.getPlayerList("game_room")
    local room = lurek.network.getRoom("game_room")
    lurek.log.info("room=" .. tostring(room.name) .. " players=" .. tostring(room.player_count))
    lurek.log.info("tracked player ids=" .. table.concat(players, ","))
end

--@api: lurek.network.isAllReady
do

    lurek.network.setReady("lobby_room", 1, true)
    lurek.network.setReady("lobby_room", 2, true)
    local all_ready = lurek.network.isAllReady("lobby_room")
    local room = lurek.network.getRoom("lobby_room")
    local players = lurek.network.getPlayerList("lobby_room")
    lurek.log.info("all_ready=" .. tostring(all_ready))
    lurek.log.info("room players=" .. tostring(room.player_count) .. " ids=" .. table.concat(players, ","))
end

--@api: lurek.network.getRoom
do

    lurek.network.setReady("session_room", 1, true)
    lurek.network.setReady("session_room", 2, false)
    local room = lurek.network.getRoom("session_room")
    lurek.log.info("room_name=" .. room.name)
    lurek.log.info("room_host=" .. room.host_peer)
    lurek.log.info("room_players=" .. room.player_count)
end

--@api: lurek.network.getPlayerList
do

    lurek.network.setReady("match_room", 1, true)
    lurek.network.setReady("match_room", 3, true)
    lurek.network.setReady("match_room", 2, false)
    local players = lurek.network.getPlayerList("match_room")
    lurek.log.info("player_list_count=" .. #players)
    for i, pid in ipairs(players) do
        lurek.log.info("player_" .. i .. "=" .. pid)
    end
end

--@api: lurek.network.newRpc
do

    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, rpc = pcall(function()
        return lurek.network.newRpc(host, 0, 30.0)
    end)
    lurek.log.info("newRpc ok=" .. tostring(ok))
    if ok then
        rpc:register("ping", function(peer_id)
            return "pong"
        end)
        local responses = rpc:poll()
        lurek.log.info("rpc_responses=" .. #responses)
    end
end

--@api: lurek.network.newNetState
do

    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, state = pcall(function()
        return lurek.network.newNetState(host, { authority = true })
    end)
    lurek.log.info("newNetState ok=" .. tostring(ok))
    if ok then
        state:set("player_x", 100)
        state:set("player_y", 50)

        local x = state:get("player_x")
        lurek.log.info("player_x=" .. x)

        state:onChange("player_x", function(value, old_value, peer_id)
            lurek.log.info("player_x changed from " .. tostring(old_value) .. " to " .. tostring(value))
        end)

        local all_state = state:getAll()
        lurek.log.info("state_keys=" .. #all_state)

        state:poll()
    end

    host:destroy()
end


