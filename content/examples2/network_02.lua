--- Network Module Part 2: host queries, runtime lifecycle, room, relay, and snapshot

--@api-stub: LNetworkHost:destroy
--@api-stub: LNetworkHost:getAddress
--@api-stub: LNetworkHost:getChannelLimit
--@api-stub: LNetworkHost:getPeerLimit
--@api-stub: LNetworkHost:getRole
--@api-stub: LNetworkHost:isClient
--@api-stub: LNetworkHost:isDestroyed
--@api-stub: LNetworkHost:isServer
--@api-stub: LNetworkHost:type
--@api-stub: LNetworkHost:typeOf
-- Host lifecycle, role, and type introspection.
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
--@api-stub: LNetworkRuntime:type
--@api-stub: LNetworkRuntime:typeOf
-- Runtime lifecycle and type introspection.
do
    local rt = lurek.network.newRuntime()
    print("rt_type=" .. rt:type())
    print("rt_typeOf=" .. tostring(rt:typeOf("LNetworkRuntime")))
    rt:shutdown()
end

--@api-stub: lurek.network.discoverLobbies
--@api-stub: lurek.network.joinRoom
--@api-stub: lurek.network.leaveRoom
--@api-stub: lurek.network.listRooms
-- Lobby and room management.
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
--@api-stub: lurek.network.parseRelayTicket
-- Relay and punch probe parsing.
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

print("network_02.lua")
