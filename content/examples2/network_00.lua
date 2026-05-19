--- Network Module Part 1: LNetworkHost — server, client, peer management

--@api-stub: lurek.network.newServer
-- Creates a server host.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7777, maxPeers = 16, channels = 2})
    print("role = " .. server:getRole())
    print("isServer = " .. tostring(server:isServer()))
    print("peer limit = " .. server:getPeerLimit())
    print("channel limit = " .. server:getChannelLimit())
    print("address = " .. server:getAddress())
    server:destroy()
end

--@api-stub: lurek.network.newClient
-- Creates a client host and connects to a server.
do
    ---@type LNetworkHost
    local client = lurek.network.newClient({addr = "127.0.0.1:7777", channels = 2})
    print("role = " .. client:getRole())
    print("isClient = " .. tostring(client:isClient()))
    print("destroyed = " .. tostring(client:isDestroyed()))
    client:destroy()
end

--@api-stub: lurek.network.newHost
-- Creates a generic network host.
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:8888", maxPeers = 32, channels = 4})
    print("address = " .. host:getAddress())
    print("peers = " .. host:getPeerLimit())
    host:destroy()
end

--@api-stub: LNetworkHost:connect
-- Connects to a remote peer (client-side).
do
    ---@type LNetworkHost
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1})
    local peer_id = host:connect("127.0.0.1:7777", 2, 0)
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
--@api-stub: LNetworkHost:broadcast
-- Sends data to peers.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7779, maxPeers = 8, channels = 2})
    -- Would send to connected peer:
    -- server:send(1, 0, "hello", true)
    -- server:broadcast(0, "world", false)
    print("send/broadcast ready, channels = " .. server:getChannelLimit())
    server:destroy()
end

--@api-stub: LNetworkHost:getConnectedPeerCount
--@api-stub: LNetworkHost:getConnectedPeerIds
-- Queries connected peers.
do
    ---@type LNetworkHost
    local server = lurek.network.newServer({port = 7780, maxPeers = 4})
    print("connected = " .. server:getConnectedPeerCount())
    local ids = server:getConnectedPeerIds()
    print("peer ids = " .. #ids)
    server:destroy()
end

--@api-stub: LNetworkHost:getPeerState
--@api-stub: LNetworkHost:getPeerAddress
--@api-stub: LNetworkHost:getRoundTripTime
-- Peer info queries.
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
--@api-stub: LNetworkHost:getBandwidthLimit
-- Bandwidth configuration.
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
--@api-stub: LNetworkHost:disconnectLater
--@api-stub: LNetworkHost:disconnectNow
-- Disconnection methods.
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
--@api-stub: LNetworkHost:ping
--@api-stub: LNetworkHost:resetPeer
-- Utility methods.
do
    ---@type LNetworkHost
    local host = lurek.network.newServer({port = 7786, maxPeers = 4})
    host:flush()
    -- host:ping(1)
    -- host:resetPeer(1)
    print("utility methods ready")
    host:destroy()
end

print("network_00.lua")
