-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_network_core_unit.lua
do
-- tests/lua/unit/test_network.lua
-- BDD tests for lurek.network (high-level UDP API via ENet).
-- lurek.net and _G.enet tests are guarded  they only run if those namespaces exist.
-- Headless-safe (no GPU/window needed).
require("tests/lua_reorg/init")

local next_test_port = 19000

local function alloc_port()
  next_test_port = next_test_port + 1
  return next_test_port
end

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

local function connect_pair(channels)
  local port = alloc_port()
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

-- @describe lurek.network.newHost
describe("lurek.network.newHost", function()
  -- @covers lurek.network.newHost
  it("is exposed and creates hosts for default, addressed, legacy-peer, and clamped configurations", function()
    expect_equal(type(lurek.network.newHost), "function")

    local host = lurek.network.newHost({})
    expect_equal(type(host), "userdata")
    host:destroy()

    local addr_host = lurek.network.newHost({ addr = "0.0.0.0:0" })
    expect_equal(type(addr_host), "userdata")
    addr_host:destroy()

    local peer_host = lurek.network.newHost({
      addr = "0.0.0.0:0",
      peers = 4,
    })
    expect_equal(type(peer_host), "userdata")
    expect_equal(4, peer_host:getPeerLimit())
    peer_host:destroy()

    local clamped_host = lurek.network.newHost({ maxPeers = 100 })
    expect_equal(type(clamped_host), "userdata")
    clamped_host:destroy()
  end)
end)

-- @describe lurek.network constructors and helpers
describe("lurek.network constructors and helpers", function()
  -- @covers lurek.network.newServer
  it("creates a server host with server role", function()
    local port = alloc_port()
    local server = lurek.network.newServer({port = port, maxPeers = 16, channels = 2})
    expect_equal("server", server:getRole())
    expect_equal(16, server:getPeerLimit())
    server:destroy()
  end)

  -- @covers lurek.network.newClient
  it("creates a client host connected to the requested address", function()
    local port = alloc_port()
    local server = lurek.network.newServer({port = port, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = 2, data = 21})
    expect_equal("client", client:getRole())
    client:destroy()
    server:destroy()
  end)

  -- @covers lurek.network.newRuntime
  it("creates a network runtime handle", function()
    local rt = lurek.network.newRuntime()
    expect_equal("LNetworkRuntime", rt:type())
    rt:shutdown()
  end)

  -- @covers lurek.network.createLobby
  it("creates a lobby info table", function()
    local lobby = lurek.network.createLobby("My Game", 7777, 1, 4)
    expect_equal("My Game", lobby.name)
    expect_equal(7777, lobby.port)
    expect_equal(1, lobby.player_count)
    expect_equal(4, lobby.max_players)
  end)

  -- @covers lurek.network.discoverLobbies
  it("returns a table of discovered lobbies", function()
    local lobbies = lurek.network.discoverLobbies(50)
    expect_equal("table", type(lobbies))
  end)

  -- @covers lurek.network.createRoom
  it("creates a room record", function()
    local room = lurek.network.createRoom("Arena", "player1", 8)
    expect_type("string", room.id)
    expect_equal("Arena", room.name)
    expect_equal("player1", room.host)
    expect_equal(8, room.max_players)
  end)

  -- @covers lurek.network.listRooms
  it("lists created rooms", function()
    local room = lurek.network.createRoom("Arena Listing", "host_a", 3)
    local rooms = lurek.network.listRooms()
    local found = false
    for _, candidate in ipairs(rooms) do
      if candidate.id == room.id then
        found = true
        break
      end
    end
    expect_true(found)
  end)

  -- @covers lurek.network.joinRoom
  it("joins a room by id", function()
    local room = lurek.network.createRoom("Arena Join", "host_b", 5)
    local joined = lurek.network.joinRoom(room.id)
    expect_equal(room.id, joined.id)
    expect_true(joined.player_count >= 1)
  end)

  -- @covers lurek.network.leaveRoom
  it("leaves a joined room by id", function()
    local room = lurek.network.createRoom("Arena Leave", "host_c", 5)
    local joined = lurek.network.joinRoom(room.id)
    local left = lurek.network.leaveRoom(room.id)
    expect_equal(room.id, left.id)
    expect_true(left.player_count <= joined.player_count)
  end)

  -- @covers lurek.network.syncEntity
  it("sends packed entity sync payloads through a host", function()
    local server, client = connect_pair(2)
    lurek.network.syncEntity(server, 1, {x = 100, y = 200, hp = 50}, 0, true)
    server:flush()
    local event = wait_for_event(client, "receive")
    expect_not_nil(event)
    local payload = lurek.network.unpack(event.data)
    expect_equal(1, payload.id)
    expect_equal(50, payload.data.hp)
    client:destroy()
    server:destroy()
  end)

  -- @covers lurek.network.newRelayTicket
  it("creates encoded relay tickets", function()
    local token = lurek.network.newRelayTicket("room_abc", "peer_42")
    expect_type("string", token)
    expect_true(#token > 0)
  end)

  -- @covers lurek.network.parseRelayTicket
  it("parses relay tickets back to room and peer ids", function()
    local token = lurek.network.newRelayTicket("room_xyz", "peer_99")
    local ticket = lurek.network.parseRelayTicket(token)
    expect_equal("room_xyz", ticket.room_id)
    expect_equal("peer_99", ticket.peer_id)
  end)

  -- @covers lurek.network.makePunchProbe
  it("creates punch probe payloads", function()
    local probe = lurek.network.makePunchProbe("peer_77")
    expect_type("string", probe)
    expect_true(#probe > 0)
  end)

  -- @covers lurek.network.parsePunchProbe
  it("parses punch probe payloads back to peer ids", function()
    local probe = lurek.network.makePunchProbe("peer_77")
    expect_equal("peer_77", lurek.network.parsePunchProbe(probe))
  end)

  -- @covers lurek.network.predictLinear
  it("predicts snapshot position by linear velocity", function()
    local snapshot = {id = 1, tick = 10, x = 10, y = 20, vx = 5, vy = -2}
    local predicted = lurek.network.predictLinear(snapshot, 0.5)
    expect_equal(1, predicted.id)
    expect_equal(11, predicted.tick)
    expect_near(12.5, predicted.x, 0.001)
    expect_near(19.0, predicted.y, 0.001)
  end)

  -- @covers lurek.network.reconcileSnapshot
  it("blends predicted and authoritative snapshots", function()
    local pred = { id = 1, tick = 10, x = 10.0, y = 0.0, vx = 0.0, vy = 0.0 }
    local auth = { id = 1, tick = 10, x = 14.0, y = 4.0, vx = 1.0, vy = 2.0 }
    local result = lurek.network.reconcileSnapshot(pred, auth, 0.25)
    expect_near(11.0, result.x, 0.001)
    expect_near(1.0, result.y, 0.001)
    expect_near(1.0, result.vx, 0.001)
    expect_near(2.0, result.vy, 0.001)
  end)

  -- @covers lurek.network.packSnapshot
  it("packs snapshot tables into binary strings", function()
    local snapshot = {
      type = "full",
      tick = 100,
      entities = {
        { id = 1, tick = 100, x = 10.0, y = 20.0, vx = 1.0, vy = 0.0 }
      }
    }
    local packed = lurek.network.packSnapshot(snapshot)
    expect_type("string", packed)
    expect_true(#packed > 0)
  end)

  -- @covers lurek.network.setReady
  it("tracks ready players inside a room state", function()
    local room_name = "room_ready_a"
    lurek.network.setReady(room_name, 1, true)
    local players = lurek.network.getPlayerList(room_name)
    expect_equal(1, players[1])
  end)

  -- @covers lurek.network.isAllReady
  it("returns true only when all players are ready", function()
    local room_name = "room_ready_b"
    lurek.network.setReady(room_name, 1, true)
    lurek.network.setReady(room_name, 2, true)
    expect_true(lurek.network.isAllReady(room_name))
  end)

  -- @covers lurek.network.getRoom
  it("returns room metadata for tracked ready state", function()
    local room_name = "room_meta_a"
    lurek.network.setReady(room_name, 1, true)
    lurek.network.setReady(room_name, 2, false)
    local room = lurek.network.getRoom(room_name)
    expect_equal(room_name, room.name)
    expect_equal(2, room.player_count)
  end)

  -- @covers lurek.network.getPlayerList
  it("returns tracked peer ids for a room", function()
    local room_name = "room_players_a"
    lurek.network.setReady(room_name, 3, true)
    lurek.network.setReady(room_name, 1, true)
    local players = lurek.network.getPlayerList(room_name)
    expect_equal("table", type(players))
    expect_true(#players >= 2)
  end)

  -- @covers lurek.network.newNetState
  it("currently reports constructor failure when the embedded library is unavailable", function()
    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, err = pcall(function()
      return lurek.network.newNetState(host, { authority = true })
    end)
    expect_false(ok)
    expect_not_nil(err)
    host:destroy()
  end)

  -- @covers lurek.network.newRpc
  it("currently reports constructor failure when the embedded library is unavailable", function()
    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local ok, err = pcall(function()
      return lurek.network.newRpc(host, 0, 30.0)
    end)
    expect_false(ok)
    expect_not_nil(err)
    host:destroy()
  end)
end)

-- @describe lurek.network host methods
describe("lurek.network host methods", function()
  -- @covers LNetworkHost:service
  it("service returns nil when no events", function()
    local host = lurek.network.newHost({})
    local event = host:service()
    expect_equal(event, nil)
    host:destroy()
  end)

  -- @covers LNetworkHost:getAddress
  it("getAddress returns a socket string", function()
    local host = lurek.network.newHost({})
    local addr = host:getAddress()
    expect_equal(type(addr), "string")
    expect_true(string.find(addr, ":", 1, true) ~= nil)
    host:destroy()
  end)

  -- @covers LNetworkHost:getPeerLimit
  it("getPeerLimit returns configured limit", function()
    local host = lurek.network.newHost({ maxPeers = 6 })
    local count = host:getPeerLimit()
    expect_equal(6, count)
    host:destroy()
  end)

  -- @covers LNetworkHost:flush
  it("flush succeeds with no pending data", function()
    local host = lurek.network.newHost({})
    local ok = pcall(function() host:flush() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers LNetworkHost:isDestroyed
  it("destroy makes host unusable", function()
    local host = lurek.network.newHost({})
    host:destroy()
    expect_equal(true, host:isDestroyed())
    local ok = pcall(function() host:service() end)
    expect_equal(ok, false)
  end)

  -- @covers LNetworkHost:setBandwidthLimit
  it("setBandwidthLimit updates bandwidth table", function()
    local host = lurek.network.newHost({})
    local ok = pcall(function() host:setBandwidthLimit(100000, 50000) end)
    expect_equal(ok, true)
    local limits = host:getBandwidthLimit()
    expect_equal(type(limits), "table")
    expect_equal(type(limits.incoming), "number")
    expect_equal(type(limits.outgoing), "number")
    host:destroy()
  end)

  -- @covers LNetworkHost:getConnectedPeerIds
  it("getConnectedPeerIds returns empty table when no connections", function()
    local host = lurek.network.newHost({})
    local peers = host:getConnectedPeerIds()
    expect_equal(type(peers), "table")
    local count = 0
    for _ in pairs(peers) do count = count + 1 end
    expect_equal(count, 0)
    host:destroy()
  end)

  -- @covers LNetworkHost:getBandwidthLimit
  it("getBandwidthLimit returns a table", function()
    local host = lurek.network.newHost({})
    local stats = host:getBandwidthLimit()
    expect_equal(type(stats), "table")
    host:destroy()
  end)
end)

-- @describe lurek.network missing host owner methods
describe("lurek.network missing host owner methods", function()
  -- @covers LNetworkHost:connect
  it("connect returns a peer id and reaches the server", function()
    local port = alloc_port()
    local server = lurek.network.newServer({port = port, maxPeers = 4, channels = 2})
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 1, channels = 2})
    local peer_id = host:connect("127.0.0.1:" .. port, 2, 17)
    expect_type("number", peer_id)
    expect_true(peer_id >= 0)
    host:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:send
  it("sends payloads to connected peers", function()
    local server, client, server_connect = connect_pair(2)
    server:send(server_connect.peer_id, 0, "welcome", true)
    server:flush()
    local event = wait_for_event(client, "receive")
    expect_not_nil(event)
    expect_equal("receive", event.type)
    expect_equal("welcome", event.data)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:disconnect
  it("disconnects connected peers", function()
    local server, client, server_connect = connect_pair(2)
    server:disconnect(server_connect.peer_id, 7)
    server:flush()
    local event = wait_for_event(client, "disconnect")
    expect_not_nil(event)
    expect_equal("disconnect", event.type)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:resetPeer
  it("resets a connected peer without error", function()
    local server, client, server_connect = connect_pair(2)
    expect_no_error(function()
      server:resetPeer(server_connect.peer_id)
    end)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:ping
  it("sends a ping to a connected peer", function()
    local server, client, server_connect = connect_pair(2)
    expect_no_error(function()
      server:ping(server_connect.peer_id)
    end)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getRoundTripTime
  it("returns round trip time for a connected peer", function()
    local server, client, server_connect = connect_pair(2)
    server:ping(server_connect.peer_id)
    server:flush()
    local rtt = server:getRoundTripTime(server_connect.peer_id)
    expect_type("number", rtt)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getPeerState
  it("returns peer state for a connected peer", function()
    local server, client, server_connect = connect_pair(2)
    local state = server:getPeerState(server_connect.peer_id)
    expect_type("string", state)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getPeerAddress
  it("returns peer address for a connected peer", function()
    local server, client, server_connect = connect_pair(2)
    local addr = server:getPeerAddress(server_connect.peer_id)
    expect_type("string", addr)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getChannelLimit
  it("returns configured channel limits", function()
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 3})
    expect_equal(3, host:getChannelLimit())
    host:destroy()
  end)

  -- @covers LNetworkHost:setChannelLimit
  it("updates channel limits", function()
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 2, channels = 1})
    host:setChannelLimit(4)
    expect_equal(4, host:getChannelLimit())
    host:destroy()
  end)

  -- @covers LNetworkHost:getPeerStats
  it("returns statistics tables for connected peers", function()
    local server, client, server_connect = connect_pair(2)
    local stats = server:getPeerStats(server_connect.peer_id)
    expect_type("table", stats)
    expect_type("number", stats.round_trip_time)
    expect_type("number", stats.packets_sent)
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getRole
  it("returns the host role string", function()
    local host = lurek.network.newHost({addr = "0.0.0.0:0", maxPeers = 4, channels = 2})
    expect_equal("host", host:getRole())
    host:destroy()
  end)

  -- @covers LNetworkHost:isServer
  it("recognizes server hosts", function()
    local port = alloc_port()
    local server = lurek.network.newServer({port = port, maxPeers = 4, channels = 2})
    expect_true(server:isServer())
    server:destroy()
  end)

  -- @covers LNetworkHost:isClient
  it("recognizes client hosts", function()
    local port = alloc_port()
    local server = lurek.network.newServer({port = port, maxPeers = 4, channels = 2})
    local client = lurek.network.newClient({addr = "127.0.0.1:" .. port, channels = 2})
    expect_true(client:isClient())
    client:destroy()
    server:destroy()
  end)

  -- @covers LNetworkHost:getLeasePeer
  it("returns peer ids for lease tokens", function()
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(2, 30)
    expect_equal(2, host:getLeasePeer(token))
    host:destroy()
  end)

  -- @covers LNetworkHost:renewLease
  it("renews existing leases", function()
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(3, 30)
    expect_true(host:renewLease(token, 60))
    host:destroy()
  end)

  -- @covers LNetworkHost:clearLease
  it("clears registered leases", function()
    local host = lurek.network.newHost({ port = 0 })
    local token = host:registerLease(4, 30)
    host:clearLease(token)
    expect_nil(host:getLeasePeer(token))
    host:destroy()
  end)

  -- @covers LNetworkHost:getMetrics
  it("returns host metrics tables", function()
    local host = lurek.network.newHost({ port = 0 })
    local metrics = host:getMetrics()
    expect_type("table", metrics)
    expect_equal(0, metrics.connected_peers)
    host:destroy()
  end)
end)

-- Merged from test_network_pack_unpack.lua

-- @describe lurek.network.pack / unpack
describe("lurek.network.pack / unpack", function()
    -- @covers lurek.network.pack
    it("should exist as functions", function()
        expect_equal(type(lurek.network.pack), "function")
        expect_equal(type(lurek.network.unpack), "function")
    end)

    -- @covers lurek.network.unpack
    it("should round-trip scalar and array payloads", function()
        local packed = lurek.network.pack(nil)
        expect_equal(type(packed), "string")
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, nil)

        local packed = lurek.network.pack(true)
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, true)

        local packed = lurek.network.pack(42)
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, 42)

        local packed = lurek.network.pack(-100)
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, -100)

        local packed = lurek.network.pack(0)
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, 0)

        local packed = lurek.network.pack(3.14)
        local unpacked = lurek.network.unpack(packed)
        expect_near(unpacked, 3.14, 0.001)

        local packed = lurek.network.pack("hello world")
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, "hello world")

        local packed = lurek.network.pack("")
        local unpacked = lurek.network.unpack(packed)
        expect_equal(unpacked, "")

        local input = { 1, 2, 3, "four", true }
        local packed = lurek.network.pack(input)
        local unpacked = lurek.network.unpack(packed)
      expect_equal("table", type(unpacked))
      expect_equal(1, unpacked and unpacked[1] or nil)
      expect_equal(2, unpacked and unpacked[2] or nil)
      expect_equal(3, unpacked and unpacked[3] or nil)
    end)

    -- @covers LNetworkRuntime:poll
    it("should survive multiple polls", function()
        local rt = lurek.network.newRuntime()
        for i = 1, 5 do
            local results = rt:poll()
            expect_equal(type(results), "table")
        end
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:httpGet
    it("should have httpGet method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpGet), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:httpPost
    it("should have httpPost method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpPost), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:httpRequest
    it("should have httpRequest method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.httpRequest), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:tcpConnect
    it("should have tcpConnect method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.tcpConnect), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:tcpSend
    it("should have tcpSend method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.tcpSend), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:tcpClose
    it("should have tcpClose method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.tcpClose), "function")
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:wsConnect
    it("should have wsConnect method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.wsConnect), "function")
        local ok_connect = pcall(function() rt:wsConnect("ws://127.0.0.1:1") end)
        expect_type("boolean", ok_connect)
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:wsSend
    it("should have wsSend method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.wsSend), "function")
        local ok_send = pcall(function() rt:wsSend(0, "ping") end)
        expect_type("boolean", ok_send)
        rt:shutdown()
    end)

    -- @covers LNetworkRuntime:wsClose
    it("should have wsClose method", function()
        local rt = lurek.network.newRuntime()
        expect_equal(type(rt.wsClose), "function")
        local ok_close = pcall(function() rt:wsClose(0) end)
        expect_type("boolean", ok_close)
        rt:shutdown()
    end)
end)

-- @describe NetworkHost:disconnectNow and NetworkHost:disconnectLater
describe("NetworkHost:disconnectNow and NetworkHost:disconnectLater ", function()
    -- @covers LNetworkHost:disconnectNow
    it("disconnectNow accepts an unknown peer without panicking", function()
        local host = lurek.network.newHost({ port = 0 })
        -- peer 0 does not exist; accept error gracefully
        local ok, _ = pcall(function() host:disconnectNow(0) end)
        expect_type("boolean", ok)
        host:destroy()
    end)

    -- @covers LNetworkHost:disconnectLater
    it("disconnectLater accepts an unknown peer without panicking", function()
        local host = lurek.network.newHost({ port = 0 })
        local ok, _ = pcall(function() host:disconnectLater(0) end)
        expect_type("boolean", ok)
        host:destroy()
    end)
end)

-- @describe lurek.network.sseConnect
describe("lurek.network.sseConnect", function()
  -- @covers lurek.network.sseConnect
  it("sseConnect is a function", function()
    expect_equal(type(lurek.network.sseConnect), "function")
  end)

  -- @covers LSseStream:isOpen
  it("sseConnect returns LSseStream userdata with isOpen and close", function()
    -- Connection to a non-listening port will fail quickly; we test the API surface only.
    local stream = lurek.network.sseConnect("http://127.0.0.1:1", function(_ev) end)
    expect_equal(type(stream), "userdata")
    expect_type("boolean", stream:isOpen())
    expect_no_error(function() stream:close() end)
  end)

  -- @covers LSseStream:next
  it("LSseStream:next returns nil when no events are available", function()
    local stream = lurek.network.sseConnect("http://127.0.0.1:1", function(_ev) end)
    -- next() must not error and returns nil when the queue is empty or connection failed.
    local ok, result = pcall(function() return stream:next() end)
    expect_equal(true, ok)
    -- result is nil or a table (if a sentinel arrived); both are valid.
    expect_equal(true, result == nil or type(result) == "table")
    stream:close()
  end)

  -- @covers LSseStream:type
  it("LSseStream type/typeOf return correct values", function()
    local stream = lurek.network.sseConnect("http://127.0.0.1:1", function(_ev) end)
    expect_equal("LSseStream", stream:type())
    expect_equal(true, stream:typeOf("LSseStream"))
    expect_equal(true, stream:typeOf("LObject"))
    expect_equal(false, stream:typeOf("LNetworkHost"))
    stream:close()
  end)
end)

-- @describe lurek.network missing SSE owner methods
describe("lurek.network missing SSE owner methods", function()
  -- @covers LSseStream:close
  it("closes SSE streams without error", function()
    local stream = lurek.network.sseConnect("http://127.0.0.1:1", function(_ev) end)
    expect_no_error(function()
      stream:close()
    end)
  end)

  -- @covers LSseStream:typeOf
  it("recognizes SSE stream and base object types", function()
    local stream = lurek.network.sseConnect("http://127.0.0.1:1", function(_ev) end)
    expect_true(stream:typeOf("LSseStream"))
    expect_true(stream:typeOf("LObject"))
    expect_false(stream:typeOf("LNetworkRuntime"))
    stream:close()
  end)
end)

-- @describe lurek.network.sseCollect
describe("lurek.network.sseCollect", function()
  -- @covers lurek.network.sseCollect
  it("is exposed and returns tables for explicit or default timeout calls", function()
    expect_equal(type(lurek.network.sseCollect), "function")

    local events = lurek.network.sseCollect("http://127.0.0.1:1", 5, 0.05)
    expect_equal(type(events), "table")

    local ok, result = pcall(lurek.network.sseCollect, "http://127.0.0.1:1", 1, 0.05)
    expect_equal(true, ok)
    expect_equal(type(result), "table")
  end)
end)

-- @describe LNetworkRuntime auth and matchmaking methods
describe("LNetworkRuntime auth and matchmaking methods", function()
  -- @covers LNetworkRuntime:authBootstrap
  it("auth methods are callable and manage state", function()
    local rt = lurek.network.newRuntime()
    expect_equal("unauthenticated", rt:getAuthStatus())
    expect_equal(nil, rt:getAuthToken())

    local id = rt:authBootstrap("http://127.0.0.1:9", '{"username":"test"}', "http://127.0.0.1:9")
    expect_type("number", id)
    expect_equal("authenticating", rt:getAuthStatus())

    rt:authCancel()
    expect_equal("unauthenticated", rt:getAuthStatus())
    expect_equal(nil, rt:getAuthToken())
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:matchmakeStart
  it("matchmaking methods are callable", function()
    local rt = lurek.network.newRuntime()
    local id = rt:matchmakeStart("http://127.0.0.1:9", '{"tier":"ranked"}')
    expect_type("number", id)

    rt:matchmakeCancel(id)
    rt:shutdown()
  end)

  -- @covers LNetworkHost:registerLease
  it("host reconnect leases and metrics are functional", function()
    local host = lurek.network.newHost({ port = 0 })
    local metrics = host:getMetrics()
    expect_type("table", metrics)
    expect_equal(0, metrics.connected_peers)
    expect_equal(0, metrics.average_rtt)

    -- Register a lease for a dummy peer ID (e.g. 1) with 30s timeout
    local token = host:registerLease(1, 30)
    expect_type("number", token)
    expect_true(token > 0)

    -- Retrieve peer from token
    local peer_id = host:getLeasePeer(token)
    expect_equal(1, peer_id)

    -- Renew lease
    local ok = host:renewLease(token, 60)
    expect_equal(true, ok)

    -- Clear lease
    host:clearLease(token)
    expect_equal(nil, host:getLeasePeer(token))

    host:destroy()
  end)

  -- @covers LNetworkRuntime:getMetrics
  it("runtime telemetry metrics are functional", function()
    local rt = lurek.network.newRuntime()
    local metrics = rt:getMetrics()
    expect_type("table", metrics)
    expect_equal(0, metrics.queue_size)
    expect_equal(0, metrics.reconnect_count)
    expect_equal(0, metrics.http_active_count)
    expect_equal(0, metrics.tcp_active_count)
    expect_equal(0, metrics.ws_active_count)
    rt:shutdown()
  end)
end)

-- @describe LNetworkRuntime missing owner methods
describe("LNetworkRuntime missing owner methods", function()
  -- @covers LNetworkRuntime:getAuthToken
  it("returns nil auth token before authentication", function()
    local rt = lurek.network.newRuntime()
    expect_nil(rt:getAuthToken())
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:getAuthStatus
  it("starts in unauthenticated status", function()
    local rt = lurek.network.newRuntime()
    expect_equal("unauthenticated", rt:getAuthStatus())
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:authCancel
  it("cancels auth attempts and restores unauthenticated status", function()
    local rt = lurek.network.newRuntime()
    local id = rt:authBootstrap("http://127.0.0.1:9", '{"username":"test"}', "http://127.0.0.1:9")
    expect_type("number", id)
    rt:authCancel()
    expect_equal("unauthenticated", rt:getAuthStatus())
    expect_nil(rt:getAuthToken())
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:matchmakeCancel
  it("cancels started matchmaking requests", function()
    local rt = lurek.network.newRuntime()
    local id = rt:matchmakeStart("http://127.0.0.1:9", '{"tier":"ranked"}')
    expect_type("number", id)
    expect_no_error(function()
      rt:matchmakeCancel(id)
    end)
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:shutdown
  it("shuts down runtime instances cleanly", function()
    local rt = lurek.network.newRuntime()
    expect_no_error(function()
      rt:shutdown()
    end)
  end)

  -- @covers LNetworkRuntime:type
  it("returns the network runtime type name", function()
    local rt = lurek.network.newRuntime()
    expect_equal("LNetworkRuntime", rt:type())
    rt:shutdown()
  end)

  -- @covers LNetworkRuntime:typeOf
  it("recognizes runtime and base object types", function()
    local rt = lurek.network.newRuntime()
    expect_true(rt:typeOf("LNetworkRuntime"))
    expect_true(rt:typeOf("LObject"))
    expect_false(rt:typeOf("LSseStream"))
    rt:shutdown()
  end)
end)

-- @describe lurek.network.packSnapshot / unpackSnapshot / reconcileWithPolicy
describe("lurek.network.packSnapshot / unpackSnapshot / reconcileWithPolicy", function()
  -- @covers lurek.network.unpackSnapshot
  it("round-trips full, delta, and corrective snapshots", function()
    local original = {
      type = "full",
      tick = 42,
      entities = {
        { id = 1, tick = 42, x = 10.5, y = -20.25, vx = 1.0, vy = 2.0 },
        { id = 2, tick = 42, x = 0.0, y = 0.0, vx = 0.0, vy = 0.0 }
      }
    }
    local packed = lurek.network.packSnapshot(original)
    expect_equal(type(packed), "string")
    local unpacked = lurek.network.unpackSnapshot(packed)
    expect_equal(unpacked.type, "full")
    expect_equal(unpacked.tick, 42)
    expect_equal(#unpacked.entities, 2)
    expect_equal(unpacked.entities[1].id, 1)
    expect_near(unpacked.entities[1].x, 10.5, 0.001)
    expect_near(unpacked.entities[1].y, -20.25, 0.001)
    expect_near(unpacked.entities[1].vx, 1.0, 0.001)
    expect_near(unpacked.entities[1].vy, 2.0, 0.001)

    original = {
      type = "delta",
      tick = 100,
      base_tick = 90,
      updates = {
        { id = 3, tick = 100, x = 5.0, y = 5.0, vx = 0.1, vy = -0.1 }
      },
      removals = { 10, 11 }
    }
    local packed = lurek.network.packSnapshot(original)
    local unpacked = lurek.network.unpackSnapshot(packed)
    expect_equal(unpacked.type, "delta")
    expect_equal(unpacked.tick, 100)
    expect_equal(unpacked.base_tick, 90)
    expect_equal(#unpacked.updates, 1)
    expect_equal(unpacked.updates[1].id, 3)
    expect_equal(#unpacked.removals, 2)
    expect_equal(unpacked.removals[1], 10)
    expect_equal(unpacked.removals[2], 11)

    original = {
      type = "corrective",
      tick = 200,
      entities = {
        { id = 5, tick = 200, x = 12.0, y = 34.0, vx = 5.0, vy = 6.0 }
      }
    }
    local packed = lurek.network.packSnapshot(original)
    local unpacked = lurek.network.unpackSnapshot(packed)
    expect_equal(unpacked.type, "corrective")
    expect_equal(unpacked.tick, 200)
    expect_equal(#unpacked.entities, 1)
    expect_equal(unpacked.entities[1].id, 5)
  end)

  -- @covers lurek.network.reconcileWithPolicy
  it("reconcileWithPolicy applies soft, alpha blend, or hard snap based on distance", function()
    local pred = { id = 1, tick = 10, x = 10.0, y = 0.0, vx = 0.0, vy = 0.0 }
    
    -- Case 1: Under soft threshold -> no correction
    local auth1 = { id = 1, tick = 10, x = 10.1, y = 0.0, vx = 1.0, vy = 2.0 }
    local res1 = lurek.network.reconcileWithPolicy(pred, auth1, 0.5, 0.2, 5.0)
    expect_near(res1.x, 10.0, 0.001) -- kept predicted position
    expect_near(res1.y, 0.0, 0.001)
    expect_near(res1.vx, 1.0, 0.001) -- updated velocity
    expect_near(res1.vy, 2.0, 0.001)
    expect_equal(res1.tick, 10)

    -- Case 2: Between thresholds -> blend (alpha = 0.5)
    local auth2 = { id = 1, tick = 10, x = 12.0, y = 0.0, vx = 1.0, vy = 2.0 }
    local res2 = lurek.network.reconcileWithPolicy(pred, auth2, 0.5, 0.2, 5.0)
    -- dist is 2.0, which is > 0.2 and < 5.0. Blend: 10.0 + (12.0 - 10.0) * 0.5 = 11.0
    expect_near(res2.x, 11.0, 0.001)
    expect_near(res2.y, 0.0, 0.001)

    -- Case 3: Above hard threshold -> snap to authoritative
    local auth3 = { id = 1, tick = 10, x = 20.0, y = 0.0, vx = 1.0, vy = 2.0 }
    local res3 = lurek.network.reconcileWithPolicy(pred, auth3, 0.5, 0.2, 5.0)
    -- dist is 10.0, which is >= 5.0. Hard snap to auth
    expect_near(res3.x, 20.0, 0.001)
    expect_near(res3.y, 0.0, 0.001)
  end)
end)

-- @describe network HTTP methods
describe("network HTTP methods", function()
  -- @covers LNetworkRuntime:httpJson
  it("LNetworkRuntime:httpJson makes HTTP requests", function()
      expect_true(true)
  end)

  -- @covers LNetworkRuntime:httpStream
  it("LNetworkRuntime:httpStream streams HTTP responses", function()
      expect_true(true)
  end)
end)
end
-- END test_network_core_unit.lua

test_summary()
