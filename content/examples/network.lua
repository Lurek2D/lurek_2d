-- content/examples/network.lua
-- Auto-generated from content/examples2/network_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/network.lua


--- Network Module Part 1: LNetworkHost — server, client, peer management


--@api: lurek.network.newServer
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

--@api: lurek.network.newClient
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

--@api: lurek.network.newHost
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

--@api: LNetworkHost:connect
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

--@api: LNetworkHost:service
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

--@api: LNetworkHost:send
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

--@api: LNetworkHost:broadcast
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

--@api: LNetworkHost:getConnectedPeerCount
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

--@api: LNetworkHost:getConnectedPeerIds
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

--@api: LNetworkHost:getPeerState
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

--@api: LNetworkHost:getPeerAddress
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

--@api: LNetworkHost:getRoundTripTime
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

--@api: LNetworkHost:getPeerStats
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

--@api: LNetworkHost:setBandwidthLimit
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

--@api: LNetworkHost:getBandwidthLimit
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

--@api: LNetworkHost:setChannelLimit
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

--@api: LNetworkHost:disconnect
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

--@api: LNetworkHost:disconnectLater
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

--@api: LNetworkHost:disconnectNow
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

--@api: LNetworkHost:flush
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

--@api: LNetworkHost:ping
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

--@api: LNetworkHost:resetPeer
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

--- Network Module Part 2: LNetworkRuntime, rooms, lobbies, pack/unpack, prediction

--@api: lurek.network.newRuntime
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

    local rt = lurek.network.newRuntime()
    local metrics = rt:getMetrics()
    local status = rt:getAuthStatus()
    local token = rt:getAuthToken()
    network_log("runtime type=" .. rt:type() .. " typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    network_log("queue=" .. metrics.queue_size .. " auth=" .. status .. " token=" .. tostring(token))
    rt:shutdown()
end

--@api: LNetworkRuntime:httpGet
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

    local rt = lurek.network.newRuntime()
    local req_id = rt:httpGet("http://127.0.0.1:1/status", {Accept = "text/plain"})
    example_print_log("request_id=" .. req_id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:httpPost
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

    local rt = lurek.network.newRuntime()
    local req_id = rt:httpPost("http://127.0.0.1:1/data", '{"key":"value"}', {["Content-Type"] = "application/json"})
    example_print_log("request_id=" .. req_id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:httpRequest
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

    local rt = lurek.network.newRuntime()
    local req_id = rt:httpRequest({url = "http://127.0.0.1:1/resource", method = "PUT", body = "updated data", timeout = 0.01})
    example_print_log("request_id=" .. req_id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:poll
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

    local rt = lurek.network.newRuntime()
    rt:httpGet("http://127.0.0.1:1/poll")
    local events = rt:poll()
    example_print_log("events=" .. #events)
    rt:shutdown()
end

--@api: LNetworkRuntime:tcpConnect
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

    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    example_print_log("tcp_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:tcpSend
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

    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpSend(id, "PING\n")
    example_print_log("tcp_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:tcpClose
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

    local rt = lurek.network.newRuntime()
    local id = rt:tcpConnect("127.0.0.1:9")
    rt:tcpClose(id)
    example_print_log("tcp_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:wsConnect
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

    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    example_print_log("ws_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:wsSend
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

    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsSend(id, '{"action":"join","room":"lobby"}')
    example_print_log("ws_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: LNetworkRuntime:wsClose
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

    local rt = lurek.network.newRuntime()
    local id = rt:wsConnect("ws://127.0.0.1:1/game")
    rt:wsClose(id)
    example_print_log("ws_id=" .. id)
    example_print_log("pending_events=" .. #rt:poll())
    rt:shutdown()
end

--@api: lurek.network.createRoom
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

--@api: lurek.network.createLobby
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

--@api: lurek.network.pack
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

--@api: lurek.network.syncEntity
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

--@api: lurek.network.predictLinear
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

--@api: lurek.network.newRelayTicket
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

--@api: lurek.network.makePunchProbe
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

--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot

--@api: LNetworkHost:destroy
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

--@api: LNetworkHost:getAddress
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

--@api: LNetworkHost:getChannelLimit
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

--@api: LNetworkHost:getPeerLimit
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

--@api: LNetworkHost:getRole
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

--@api: LNetworkHost:isClient
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

--@api: LNetworkHost:isDestroyed
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

--@api: LNetworkHost:isServer
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

--@api: LNetworkHost:type
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

--@api: LNetworkHost:typeOf
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
    local isRuntime = host:typeOf("LNetworkRuntime")
    network_log("typeOf host=" .. tostring(isHost) .. " object=" .. tostring(isObject))
    network_log("runtime check=" .. tostring(isRuntime) .. " type=" .. host:type())
    host:destroy()
end

--@api: LNetworkRuntime:shutdown
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

    local rt = lurek.network.newRuntime()
    local typeName = rt:type()
    local status = rt:getAuthStatus()
    local metrics = rt:getMetrics()
    rt:shutdown()
    network_log("runtime type=" .. typeName .. " status=" .. status)
    network_log("shutdown queue=" .. metrics.queue_size)
end

--@api: LNetworkRuntime:type
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

    local rt = lurek.network.newRuntime()
    local typeName = rt:type()
    local status = rt:getAuthStatus()
    local metrics = rt:getMetrics()
    network_log("runtime userdata=" .. typeName)
    network_log("status=" .. status .. " queue=" .. metrics.queue_size)
    rt:shutdown()
end

--@api: LNetworkRuntime:typeOf
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

    local rt = lurek.network.newRuntime()
    local isRuntime = rt:typeOf("LNetworkRuntime")
    local isObject = rt:typeOf("LObject")
    local isStream = rt:typeOf("LSseStream")
    network_log("runtime check=" .. tostring(isRuntime) .. " object=" .. tostring(isObject))
    network_log("stream check=" .. tostring(isStream) .. " type=" .. rt:type())
    rt:shutdown()
end

--@api: lurek.network.discoverLobbies
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

--@api: lurek.network.joinRoom
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

--@api: lurek.network.leaveRoom
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

--@api: lurek.network.listRooms
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

--@api: lurek.network.parsePunchProbe
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

--@api: lurek.network.parseRelayTicket
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

--@api: lurek.network.reconcileSnapshot
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

--@api: lurek.network.unpack
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

--@api: lurek.network.sseConnect
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(ev)
        example_print_log("event=" .. tostring(ev.event) .. " data=" .. ev.data)
    end)
    -- Poll for events each frame; close when done.
    local ev = stream:next()
    if ev then
        example_print_log("got event: " .. ev.data)
    end
    stream:close()
end

--@api: lurek.network.sseCollect
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

    local events = lurek.network.sseCollect("http://127.0.0.1:1/events", 1, 0.01)
    local count = #events
    local firstEvent = events[1]
    for _, ev in ipairs(events) do
        network_log("collected event=" .. tostring(ev.event) .. " data=" .. tostring(ev.data))
    end
    network_log("sse batch size=" .. count)
    network_log("first event=" .. tostring(firstEvent and firstEvent.event or "nil"))
end

--@api: LSseStream:next
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(_ev) end)
    local ev = stream:next()
    if ev then
        example_print_log("data=" .. ev.data)
    end
    stream:close()
end

--@api: LSseStream:close
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(_ev) end)
    local wasOpen = stream:isOpen()
    local typeName = stream:type()
    stream:close()
    local isStream = stream:typeOf("LSseStream")
    network_log("sse close open_before=" .. tostring(wasOpen))
    network_log("type=" .. typeName .. " check=" .. tostring(isStream))
end

--@api: LSseStream:isOpen
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(_ev) end)
    local open = stream:isOpen()
    local typeName = stream:type()
    local event = stream:next()
    network_log("sse open=" .. tostring(open))
    network_log("type=" .. typeName .. " next=" .. tostring(event and event.event or "nil"))
    stream:close()
end

--@api: LSseStream:type
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(_ev) end)
    local typeName = stream:type()
    local isStream = stream:typeOf("LSseStream")
    local open = stream:isOpen()
    network_log("sse userdata=" .. typeName)
    network_log("is_stream=" .. tostring(isStream) .. " open=" .. tostring(open))
    stream:close()
end

--@api: LSseStream:typeOf
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

    ---@type LSseStream
    local stream = lurek.network.sseConnect("http://127.0.0.1:1/events", function(_ev) end)
    local isStream = stream:typeOf("LSseStream")
    local isObject = stream:typeOf("LObject")
    local isRuntime = stream:typeOf("LNetworkRuntime")
    network_log("sse typeOf stream=" .. tostring(isStream) .. " object=" .. tostring(isObject))
    network_log("runtime check=" .. tostring(isRuntime) .. " type=" .. stream:type())
    stream:close()
end

--@api: LNetworkRuntime:httpJson
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

    local rt = lurek.network.newRuntime()
    local ok, response = pcall(function()
        return rt:httpJson("http://127.0.0.1:1/api", '{"key":"value"}')
    end)
    example_print_log("httpJson ok: " .. tostring(ok))
    example_print_log("httpJson response: " .. tostring(response))
    rt:shutdown()
end

--@api: LNetworkRuntime:httpStream
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

    local rt = lurek.network.newRuntime()
    local ok, response = pcall(function()
        return rt:httpStream("http://127.0.0.1:1/stream")
    end)
    example_print_log("httpStream ok: " .. tostring(ok))
    example_print_log("httpStream response: " .. tostring(response))
    rt:shutdown()
end

--@api: LNetworkRuntime:authBootstrap
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

    local rt = lurek.network.newRuntime()
    local ok, id = pcall(function()
        return rt:authBootstrap("http://127.0.0.1:1/auth", '{"user":"test"}', "http://127.0.0.1:1/refresh")
    end)
    example_print_log("auth ok: " .. tostring(ok))
    example_print_log("auth id: " .. tostring(id))
    rt:shutdown()
end

--@api: LNetworkRuntime:getAuthToken
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

    local rt = lurek.network.newRuntime()
    local token = rt:getAuthToken()
    local status = rt:getAuthStatus()
    local metrics = rt:getMetrics()
    network_log("auth token=" .. tostring(token))
    network_log("status=" .. status .. " queue=" .. metrics.queue_size)
    rt:shutdown()
end

--@api: LNetworkRuntime:getAuthStatus
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

    local rt = lurek.network.newRuntime()
    local status = rt:getAuthStatus()
    local token = rt:getAuthToken()
    local metrics = rt:getMetrics()
    network_log("auth status=" .. tostring(status))
    network_log("token=" .. tostring(token) .. " queue=" .. metrics.queue_size)
    rt:shutdown()
end

--@api: LNetworkRuntime:authCancel
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

    local rt = lurek.network.newRuntime()
    local before = rt:getAuthStatus()
    rt:authCancel()
    local after = rt:getAuthStatus()
    local token = rt:getAuthToken()
    network_log("auth cancel before=" .. before .. " after=" .. after)
    network_log("token after cancel=" .. tostring(token))
    rt:shutdown()
end

--@api: LNetworkRuntime:matchmakeStart
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

    local rt = lurek.network.newRuntime()
    local ok, id = pcall(function()
        return rt:matchmakeStart("http://127.0.0.1:1/match", '{"game_mode":"ranked"}')
    end)
    example_print_log("matchmake ok: " .. tostring(ok))
    example_print_log("matchmake id: " .. tostring(id))
    rt:shutdown()
end

--@api: LNetworkRuntime:matchmakeCancel
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

    local rt = lurek.network.newRuntime()
    local before = rt:getMetrics()
    rt:matchmakeCancel(1)
    local after = rt:getMetrics()
    network_log("cancelled matchmaking request id=1")
    network_log("queue before=" .. before.queue_size .. " after=" .. after.queue_size)
    rt:shutdown()
end

--@api: LNetworkHost:registerLease
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

--@api: LNetworkHost:getLeasePeer
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

--@api: LNetworkHost:renewLease
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

--@api: LNetworkHost:clearLease
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

--@api: LNetworkHost:getMetrics
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

--@api: LNetworkRuntime:getMetrics
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

    local rt = lurek.network.newRuntime()
    local metrics = rt:getMetrics()
    local status = rt:getAuthStatus()
    local typeName = rt:type()
    network_log("runtime queue size=" .. tostring(metrics.queue_size))
    network_log("status=" .. status .. " type=" .. typeName)
    rt:shutdown()
end

--@api: lurek.network.packSnapshot
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

--@api: lurek.network.unpackSnapshot
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

--@api: lurek.network.reconcileWithPolicy
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

--@api: lurek.network.setReady
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

--@api: lurek.network.isAllReady
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

--@api: lurek.network.getRoom
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

--@api: lurek.network.getPlayerList
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

--@api: lurek.network.newRpc
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

--@api: lurek.network.newNetState
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


