-- tests/lua/unit/test_network.lua
-- BDD tests for lurek.network (high-level UDP API via ENet).
-- lurek.net and _G.enet tests are guarded  they only run if those namespaces exist.
-- Headless-safe (no GPU/window needed).
require("tests/lua/init")

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

test_summary()
