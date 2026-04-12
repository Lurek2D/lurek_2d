-- tests/lua/unit/test_network_constants.lua
-- BDD tests for lurek.network constants. Headless-safe (no ENet required).

-- @description Covers suite: lurek.network constants.
describe("lurek.network constants", function()
  -- @covers lurek.network
  -- @covers lurek.network.MAX_PEERS
  -- @covers lurek.network.DEFAULT_PEERS
  -- @covers lurek.network.MAX_CHANNELS
  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies the network namespace is registered as a Lua table before constant lookups run.
  it("lurek.network is a table", function()
    expect_equal(type(lurek.network), "table")
  end)

  -- @covers lurek.network.MAX_PEERS
  -- @description Verifies MAX_PEERS is exported as a numeric constant.
  it("MAX_PEERS is a number", function()
    expect_type("number", lurek.network.MAX_PEERS)
  end)

  -- @covers lurek.network.MAX_PEERS
  -- @description Verifies MAX_PEERS matches the documented hard limit of 8 peers.
  it("MAX_PEERS equals 8", function()
    expect_equal(lurek.network.MAX_PEERS, 8)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies DEFAULT_PEERS is exported as a numeric constant.
  it("DEFAULT_PEERS is a number", function()
    expect_type("number", lurek.network.DEFAULT_PEERS)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies DEFAULT_PEERS keeps the expected default peer count of 4.
  it("DEFAULT_PEERS equals 4", function()
    expect_equal(lurek.network.DEFAULT_PEERS, 4)
  end)

  -- @covers lurek.network.MAX_CHANNELS
  -- @description Verifies MAX_CHANNELS is exported as a numeric constant.
  it("MAX_CHANNELS is a number", function()
    expect_type("number", lurek.network.MAX_CHANNELS)
  end)

  -- @covers lurek.network.MAX_CHANNELS
  -- @description Verifies MAX_CHANNELS matches the documented ENet ceiling of 255.
  it("MAX_CHANNELS equals 255", function()
    expect_equal(lurek.network.MAX_CHANNELS, 255)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies DEFAULT_CHANNELS is exported as a numeric constant.
  it("DEFAULT_CHANNELS is a number", function()
    expect_type("number", lurek.network.DEFAULT_CHANNELS)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies DEFAULT_CHANNELS keeps the default single-channel configuration.
  it("DEFAULT_CHANNELS equals 1", function()
    expect_equal(lurek.network.DEFAULT_CHANNELS, 1)
  end)

  -- @covers lurek.network.DEFAULT_PEERS
  -- @description Verifies the default peer count never exceeds the advertised peer cap.
  it("DEFAULT_PEERS does not exceed MAX_PEERS", function()
    expect_true(lurek.network.DEFAULT_PEERS <= lurek.network.MAX_PEERS)
  end)

  -- @covers lurek.network.DEFAULT_CHANNELS
  -- @description Verifies the default channel count stays within the exported channel limit.
  it("DEFAULT_CHANNELS does not exceed MAX_CHANNELS", function()
    expect_true(lurek.network.DEFAULT_CHANNELS <= lurek.network.MAX_CHANNELS)
  end)
end)
test_summary()
