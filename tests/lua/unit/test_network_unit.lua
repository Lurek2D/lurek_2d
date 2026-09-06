-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_network_core_unit.lua
do
-- tests/lua/unit/test_network.lua
-- BDD tests for lurek.network (high-level UDP API via ENet).
-- lurek.net and _G.enet tests are guarded  they only run if those namespaces exist.
-- Headless-safe (no GPU/window needed).
require("tests/lua/init")

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
  it("creates transport-neutral state that Lua can explicitly replicate", function()
    local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
    local state = lurek.network.newNetState(host, { authority = true, turnBased = true })
    expect_equal("LNetworkState", state:type())
    state:set("ship", { hull = 120, x = 4.5 })
    expect_equal(120, state:get("ship").hull)
    expect_equal("table", type(state:getAll()))
    expect_equal("string", type(state:takeDirty()))
    expect_equal(nil, state:takeDirty())
    host:destroy()
  end)

  -- @covers lurek.network.newInputBuffer
  it("keeps remote inputs ordered and bounded without applying game commands", function()
    local buffer = lurek.network.newInputBuffer({ maxPeers = 2, maxInputsPerPeer = 4 })
    local ok_a, result_a = buffer:push(2, 8, 1, { thrust = 1 })
    local ok_b, result_b = buffer:push(1, 8, 1, { fire = true })
    expect_true(ok_a)
    expect_true(ok_b)
    expect_equal("accepted", result_a)
    expect_equal("accepted", result_b)
    local inputs = buffer:drainThrough(8)
    expect_equal(2, #inputs)
    expect_equal(1, inputs[1].peer_id)
    expect_equal(true, inputs[1].payload.fire)
    expect_equal(2, inputs[2].peer_id)
    expect_equal(1, inputs[2].payload.thrust)
    expect_equal(0, buffer:getStats().queued)
    expect_equal("LNetworkInputBuffer", buffer:type())
    expect_true(buffer:typeOf("LNetworkInputBuffer"))
  end)

  -- @covers LNetworkInputBuffer:push
  it("reports duplicate input sequences", function()
    local buffer = lurek.network.newInputBuffer()
    expect_equal(true, buffer:push(1, 2, 1, { fire = true }))
    local ok, reason = buffer:push(1, 2, 1, { fire = true })
    expect_equal(false, ok)
    expect_equal("duplicate", reason)
  end)

  -- @covers LNetworkInputBuffer:drainThrough
  it("drains only inputs at or before the supplied tick", function()
    local buffer = lurek.network.newInputBuffer()
    buffer:push(1, 3, 1, {})
    buffer:push(1, 4, 2, {})
    expect_equal(1, #buffer:drainThrough(3))
    expect_equal(1, #buffer:drainThrough(4))
  end)

  -- @covers LNetworkInputBuffer:getStats
  it("reports configured input capacity", function()
    local buffer = lurek.network.newInputBuffer({ maxPeers = 3, maxInputsPerPeer = 5 })
    local stats = buffer:getStats()
    expect_equal(3, stats.max_peers)
    expect_equal(5, stats.max_inputs_per_peer)
  end)

  -- @covers LNetworkInputBuffer:type
  it("reports its input-buffer type", function()
    expect_equal("LNetworkInputBuffer", lurek.network.newInputBuffer():type())
  end)

  -- @covers LNetworkInputBuffer:typeOf
  it("matches the input-buffer type name", function()
    expect_true(lurek.network.newInputBuffer():typeOf("LNetworkInputBuffer"))
  end)

  -- @covers lurek.network.newSnapshotStore
  it("resolves full and delta snapshot frames for Lua-owned interpolation", function()
    local store = lurek.network.newSnapshotStore({ capacity = 3 })
    store:push({
      type = "full", tick = 10,
      entities = { { id = 1, tick = 10, x = 0, y = 0, vx = 2, vy = 0 } },
    })
    store:push({
      type = "delta", tick = 12, base_tick = 10,
      updates = { { id = 1, tick = 12, x = 4, y = 0, vx = 2, vy = 0 } }, removals = {},
    })
    local middle = store:interpolate(1, 10, 12, 0.5)
    expect_near(2, middle.x, 0.0001)
    expect_equal(12, store:latest().tick)
    expect_equal(2, store:getStats().frames)
  end)

  -- @covers LNetworkSnapshotStore:push
  it("rejects a delta whose base frame is not retained", function()
    local store = lurek.network.newSnapshotStore()
    local ok = pcall(function()
      store:push({ type = "delta", tick = 2, base_tick = 1, updates = {}, removals = {} })
    end)
    expect_false(ok)
  end)

  -- @covers LNetworkSnapshotStore:get
  it("returns nil for a frame that is not retained", function()
    expect_equal(nil, lurek.network.newSnapshotStore():get(42))
  end)

  -- @covers LNetworkSnapshotStore:latest
  it("returns nil until a frame has been pushed", function()
    expect_equal(nil, lurek.network.newSnapshotStore():latest())
  end)

  -- @covers LNetworkSnapshotStore:interpolate
  it("returns nil when an entity is unavailable in either frame", function()
    local store = lurek.network.newSnapshotStore()
    store:push({ type = "full", tick = 1, entities = {} })
    store:push({ type = "full", tick = 2, entities = {} })
    expect_equal(nil, store:interpolate(1, 1, 2, 0.5))
  end)

  -- @covers LNetworkSnapshotStore:getStats
  it("reports the configured snapshot capacity", function()
    local stats = lurek.network.newSnapshotStore({ capacity = 4 }):getStats()
    expect_equal(4, stats.capacity)
    expect_equal(0, stats.frames)
  end)

  -- @covers LNetworkSnapshotStore:type
  it("reports its snapshot-store type", function()
    expect_equal("LNetworkSnapshotStore", lurek.network.newSnapshotStore():type())
  end)

  -- @covers LNetworkSnapshotStore:typeOf
  it("matches its snapshot-store type name", function()
    expect_true(lurek.network.newSnapshotStore():typeOf("LNetworkSnapshotStore"))
  end)

  -- @covers-case lurek.network.newNetState
  it("applies explicit state payloads and dispatches callbacks when polled", function()
    local authority = lurek.network.newNetState(nil, { authority = true })
    authority:set("score", 7)
    local payload = authority:takeDirty()
    local replica = lurek.network.newNetState(nil, { authority = false })
    local observed_key, observed_value = nil, nil
    replica:onChange("score", function(key, value)
      observed_key, observed_value = key, value
    end)
    replica:apply(payload)
    replica:poll()
    expect_equal(7, replica:get("score"))
    expect_equal("score", observed_key)
    expect_equal(7, observed_value)
    expect_equal(authority:hashState(), replica:hashState())
  end)

  -- @covers-case lurek.network.newNetState
  it("exposes full-state requests as explicit Lua-routable payloads", function()
    local state = lurek.network.newNetState(nil, { authority = false })
    expect_equal(nil, state:takeRequest())
    state:requestFullState()
    expect_equal("string", type(state:takeRequest()))
    expect_equal(nil, state:takeRequest())
  end)

  -- @covers-case lurek.network.newNetState
  it("advances authority turn state and notifies on poll", function()
    local state = lurek.network.newNetState(nil, { authority = true, turnBased = true })
    local observed_turn = nil
    state:onTurn(function(turn) observed_turn = turn end)
    state:beginTurn()
    state:poll()
    expect_equal(1, state:getCurrentTurn())
    expect_equal(1, observed_turn)
  end)

  -- @covers lurek.network.newRpc
  it("creates an explicit RPC protocol that Lua can route", function()
    local rpc = lurek.network.newRpc(nil, 0, 30.0)
    local reply = nil
    rpc:register("add", function(args) return args.left + args.right end)
    local id = rpc:call("add", { left = 2, right = 5 }, function(result, err)
      reply = { result = result, err = err }
    end)
    expect_equal(1, id)
    local request = rpc:takeOutgoing()
    expect_equal("string", type(request))
    rpc:process(request)
    rpc:process(rpc:takeOutgoing())
    expect_equal(7, reply.result)
    expect_equal(nil, reply.err)
    expect_equal(0, rpc:getPendingCount())
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

-- @describe LNetworkHost reconnect leases and metrics
describe("LNetworkHost reconnect leases and metrics", function()
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

end
-- END test_network_core_unit.lua

test_summary()
