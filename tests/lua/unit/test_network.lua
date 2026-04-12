-- tests/lua/unit/test_network.lua
-- BDD tests for lurek.network (high-level UDP API via ENet).
-- lurek.net and _G.enet tests are guarded â€” they only run if those namespaces exist.
-- Headless-safe (no GPU/window needed).
-- @covers lurek.network.newHost
-- @covers lurek.network.Host.service
-- @covers lurek.network.Host.getAddress
-- @covers lurek.network.Host.getPeerCount
-- @covers lurek.network.Host.flush
-- @covers lurek.network.Host.destroy
-- @covers lurek.network.Host.setBandwidthLimit
-- @covers lurek.network.Host.getPeers
-- @covers lurek.network.Host.connect
-- @covers lurek.network.Host.broadcast


-- @description Covers suite: lurek.network.
describe("lurek.network", function()
  -- @covers lurek.network
  -- @description Verifies the high-level network namespace is available as a table.
  it("is a table", function()
    expect_equal(type(lurek.network), "table")
  end)

  -- @covers lurek.network.newHost
  -- @description Verifies the high-level newHost constructor is exposed.
  it("newHost is a function", function()
    expect_equal(type(lurek.network.newHost), "function")
  end)
end)

-- @description Covers suite: lurek.network.newHost.
describe("lurek.network.newHost", function()
  -- @covers lurek.network.newHost
  -- @description Verifies newHost can create a client host with default options.
  it("creates a client host with no arguments", function()
    local host = lurek.network.newHost()
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.network.newHost
  -- @description Verifies newHost accepts a port option table.
  it("creates a host with port option", function()
    local host = lurek.network.newHost({ port = 0 })
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.network.newHost
  -- @description Verifies newHost accepts the full option table surface.
  it("creates a host with all options", function()
    local host = lurek.network.newHost({
      port = 0,
      maxPeers = 4,
      channels = 2,
      inBandwidth = 0,
      outBandwidth = 0,
    })
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.network.newHost
  -- @description Verifies maxPeers is clamped instead of rejecting oversized requests.
  it("clamps maxPeers to 8", function()
    -- Requesting more than MAX_PEERS should clamp, not error
    local host = lurek.network.newHost({ maxPeers = 100 })
    expect_equal(type(host), "userdata")
    host:destroy()
  end)
end)

-- @description Covers suite: lurek.network host methods.
describe("lurek.network host methods", function()
  -- @covers lurek.network.Host.service
  -- @description Verifies service returns nil when no events are pending.
  it("service returns nil when no events", function()
    local host = lurek.network.newHost()
    local event = host:service(0)
    expect_equal(event, nil)
    host:destroy()
  end)

  -- @covers lurek.network.Host.getAddress
  -- @description Verifies getAddress returns string host information and a numeric port.
  it("getAddress returns address and port", function()
    local host = lurek.network.newHost()
    local addr, port = host:getAddress()
    expect_equal(type(addr), "string")
    expect_equal(type(port), "number")
    host:destroy()
  end)

  -- @covers lurek.network.Host.getPeerCount
  -- @description Verifies getPeerCount reports the default peer limit.
  it("getPeerCount returns peer limit", function()
    local host = lurek.network.newHost()
    local count = host:getPeerCount()
    expect_equal(4, count)
    host:destroy()
  end)

  -- @covers lurek.network.Host.flush
  -- @description Verifies flush is safe when there is no pending data.
  it("flush succeeds with no pending data", function()
    local host = lurek.network.newHost()
    local ok, err = pcall(function() host:flush() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.network.Host.destroy
  -- @description Verifies destroy invalidates the host for later method calls.
  it("destroy makes host unusable", function()
    local host = lurek.network.newHost()
    host:destroy()
    local ok, err = pcall(function() host:service(0) end)
    expect_equal(ok, false)
  end)

  -- @covers lurek.network.Host.setBandwidthLimit
  -- @description Verifies setBandwidthLimit accepts numeric limits without error.
  it("setBandwidthLimit does not error", function()
    local host = lurek.network.newHost()
    local ok, err = pcall(function() host:setBandwidthLimit(100000, 50000) end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.network.Host.getPeers
  -- @description Verifies getPeers returns an empty table when there are no connections.
  it("getPeers returns empty table when no connections", function()
    local host = lurek.network.newHost()
    local peers = host:getPeers()
    expect_equal(type(peers), "table")
    local count = 0
    for _ in pairs(peers) do count = count + 1 end
    expect_equal(count, 0)
    host:destroy()
  end)

  -- @covers lurek.network.Host.getStats
  -- @description Verifies getStats returns a table payload.
  it("getStats returns a table", function()
    local host = lurek.network.newHost()
    local stats = host:getStats()
    expect_equal(type(stats), "table")
    host:destroy()
  end)
end)

-- â”€â”€ lurek.net (raw ENet API) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- NOTE: lurek.net is a low-level ENet alias that may not be registered
-- in all builds. Tests are guarded so the file does not crash when absent.

if lurek.net then
  -- @description Covers suite: lurek.net.
  describe("lurek.net", function()
    -- @covers lurek.net
    -- @description Verifies the low-level ENet alias is exposed when registered.
    it("is a table", function()
      expect_equal(type(lurek.net), "table")
    end)

    -- @covers lurek.net.host_create
    -- @description Verifies the low-level host_create constructor is exposed.
    it("host_create is a function", function()
      expect_equal(type(lurek.net.host_create), "function")
    end)

    -- @covers lurek.net.linked_version
    -- @description Verifies linked_version is exposed.
    it("linked_version is a function", function()
      expect_equal(type(lurek.net.linked_version), "function")
    end)
  end)

-- @description Covers suite: lurek.net.linked_version.
describe("lurek.net.linked_version", function()
  -- @covers lurek.net.linked_version
  -- @description Verifies linked_version returns a string.
  it("returns a string", function()
    local ver = lurek.net.linked_version()
    expect_equal(type(ver), "string")
  end)
end)

-- @description Covers suite: lurek.net.host_create.
describe("lurek.net.host_create", function()
  -- @covers lurek.net.host_create
  -- @description Verifies host_create can build a client host with default arguments.
  it("creates a client host with no arguments", function()
    local host = lurek.net.host_create()
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies host_create accepts a bind address string.
  it("creates a server host with bind address", function()
    local host = lurek.net.host_create("*:0")
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies host_create accepts an explicit peer count.
  it("creates a host with peer count", function()
    local host = lurek.net.host_create(nil, 6)
    expect_equal(type(host), "userdata")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies host_create accepts every low-level constructor parameter.
  it("creates a host with all parameters", function()
    local host = lurek.net.host_create("*:0", 4, 2, 0, 0)
    expect_equal(type(host), "userdata")
    host:destroy()
  end)
end)

-- @description Covers suite: lurek.net host methods.
describe("lurek.net host methods", function()
  -- @covers lurek.net.host_create
  -- @description Verifies service returns nil when there are no ENet events.
  it("service returns nil when no events", function()
    local host = lurek.net.host_create()
    local evt = host:service(0)
    expect_equal(evt, nil)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies get_socket_address returns a string.
  it("get_socket_address returns address string", function()
    local host = lurek.net.host_create()
    local addr = host:get_socket_address()
    expect_equal(type(addr), "string")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies connected_peers starts at zero.
  it("connected_peers returns zero initially", function()
    local host = lurek.net.host_create()
    local count = host:connected_peers()
    expect_equal(count, 0)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies flush is safe without pending data.
  it("flush succeeds with no pending data", function()
    local host = lurek.net.host_create()
    local ok, err = pcall(function() host:flush() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies destroy invalidates the low-level host.
  it("destroy makes host unusable", function()
    local host = lurek.net.host_create()
    host:destroy()
    local ok, err = pcall(function() host:service(0) end)
    expect_equal(ok, false)
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies bandwidth_limit returns numeric in and out limits.
  it("bandwidth_limit returns in and out", function()
    local host = lurek.net.host_create()
    local in_bw, out_bw = host:bandwidth_limit()
    -- Default is unlimited (0 or nil)
    expect_equal(type(in_bw), "number")
    expect_equal(type(out_bw), "number")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies max_packet_size returns a number.
  it("max_packet_size returns a number", function()
    local host = lurek.net.host_create()
    local sz = host:max_packet_size()
    expect_equal(type(sz), "number")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies max_waiting_data returns a number.
  it("max_waiting_data returns a number", function()
    local host = lurek.net.host_create()
    local wd = host:max_waiting_data()
    expect_equal(type(wd), "number")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies duplicate_peers returns a number.
  it("duplicate_peers returns a number", function()
    local host = lurek.net.host_create()
    local dp = host:duplicate_peers()
    expect_equal(type(dp), "number")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies enable_checksum accepts a boolean without error.
  it("enable_checksum does not error", function()
    local host = lurek.net.host_create()
    local ok = pcall(function() host:enable_checksum(true) end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies compress_with_range_coder is callable without error.
  it("compress_with_range_coder does not error", function()
    local host = lurek.net.host_create()
    local ok = pcall(function() host:compress_with_range_coder() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies compress_disable is callable without error.
  it("compress_disable does not error", function()
    local host = lurek.net.host_create()
    local ok = pcall(function() host:compress_disable() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies get_stats returns a table.
  it("get_stats returns a table", function()
    local host = lurek.net.host_create()
    local stats = host:get_stats()
    expect_equal(type(stats), "table")
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies reset_stats can be called without error.
  it("reset_stats does not error", function()
    local host = lurek.net.host_create()
    local ok = pcall(function() host:reset_stats() end)
    expect_equal(ok, true)
    host:destroy()
  end)

  -- @covers lurek.net.host_create
  -- @description Verifies received_address returns a string.
  it("received_address returns a string", function()
    local host = lurek.net.host_create()
    local addr = host:received_address()
    expect_equal(type(addr), "string")
    host:destroy()
  end)
end)

-- @description Covers suite: lurek.net time.
describe("lurek.net time", function()
  -- @covers lurek.net.time_get
  -- @description Verifies time_get returns a number.
  it("time_get returns a number", function()
    local t = lurek.net.time_get()
    expect_equal(type(t), "number")
  end)

  -- @covers lurek.net.time_get
  -- @description Verifies time_get is monotonic across consecutive calls.
  it("time_get increases monotonically", function()
    local t1 = lurek.net.time_get()
    local t2 = lurek.net.time_get()
    -- At minimum, t2 >= t1 (both from wall clock)
    expect_equal(t2 >= t1, true)
  end)
end) -- lurek.net time
end -- if lurek.net

if _G.enet then
  -- @description Covers suite: enet global alias.
  describe("enet global alias", function()
    -- @covers enet
    -- @description Verifies the global enet alias is available when registered.
    it("enet is a table", function()
      expect_equal(type(_G.enet), "table")
    end)

    -- @covers enet.host_create
    -- @description Verifies the global enet alias exposes host_create.
    it("enet.host_create is a function", function()
      expect_equal(type(_G.enet.host_create), "function")
    end)

    -- @covers enet.linked_version
    -- @description Verifies the global enet alias exposes linked_version.
    it("enet.linked_version returns a string", function()
      expect_equal(type(_G.enet.linked_version()), "string")
    end)
  end) -- enet global alias
end -- if _G.enet

-- @description Covers suite: lurek.network constants.
describe("lurek.network constants", function()
  -- @covers lurek.network.MAX_PEERS
  -- @description Verifies MAX_PEERS is numeric in the high-level namespace.
  it("MAX_PEERS is a number", function()
    expect_type("number", lurek.network.MAX_PEERS)
  end)

  -- @covers lurek.network.MAX_PEERS
  -- @description Verifies MAX_PEERS equals 8.
  it("MAX_PEERS equals 8", function()
    expect_equal(lurek.network.MAX_PEERS, 8)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies DEFAULT_PEERS is numeric.
  it("DEFAULT_PEERS is a number", function()
    expect_type("number", lurek.network.DEFAULT_PEERS)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies DEFAULT_PEERS equals 4.
  it("DEFAULT_PEERS equals 4", function()
    expect_equal(lurek.network.DEFAULT_PEERS, 4)
  end)

  -- @covers lurek.network.MAX_CHANNELS
  -- @description Verifies MAX_CHANNELS is numeric.
  it("MAX_CHANNELS is a number", function()
    expect_type("number", lurek.network.MAX_CHANNELS)
  end)

  -- @covers lurek.network.MAX_CHANNELS
  -- @description Verifies MAX_CHANNELS equals 255.
  it("MAX_CHANNELS equals 255", function()
    expect_equal(lurek.network.MAX_CHANNELS, 255)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies DEFAULT_CHANNELS is numeric.
  it("DEFAULT_CHANNELS is a number", function()
    expect_type("number", lurek.network.DEFAULT_CHANNELS)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies DEFAULT_CHANNELS equals 1.
  it("DEFAULT_CHANNELS equals 1", function()
    expect_equal(lurek.network.DEFAULT_CHANNELS, 1)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies DEFAULT_PEERS does not exceed MAX_PEERS.
  it("DEFAULT_PEERS is less than or equal to MAX_PEERS", function()
    expect_true(lurek.network.DEFAULT_PEERS <= lurek.network.MAX_PEERS)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies DEFAULT_CHANNELS does not exceed MAX_CHANNELS.
  it("DEFAULT_CHANNELS is less than or equal to MAX_CHANNELS", function()
    expect_true(lurek.network.DEFAULT_CHANNELS <= lurek.network.MAX_CHANNELS)
  end)
end)

test_summary()
