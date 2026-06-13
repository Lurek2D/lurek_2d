-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_net_core_unit.lua
do
-- tests/lua/unit/test_net_core_unit.lua
-- Raw ENet alias unit tests for lurek.net.

-- @describe lurek.network compatibility baseline
describe("lurek.network compatibility baseline", function()
  -- @covers LNetworkHost:type
  it("creates a public network host even when lurek.net is absent", function()
    local host = lurek.network.newHost({})
    expect_equal("LNetworkHost", host:type())
    host:destroy()
  end)
end)

-- NOTE: lurek.net may not be registered in all builds.
if lurek.net then
  -- @describe lurek.net host methods
  describe("lurek.net host methods", function()
    -- @covers LNetworkHost:typeOf
    it("raw alias hosts report the expected userdata type", function()
      local host = lurek.net.host_create()
      expect_true(host:typeOf("LNetworkHost"))
      host:destroy()
    end)

    -- @covers LNetworkHost:getConnectedPeerCount
    it("raw alias hosts start with zero connected peers", function()
      local host = lurek.net.host_create()
      expect_equal(0, host:getConnectedPeerCount())
      host:destroy()
    end)

    -- @covers LNetworkHost:broadcast
    it("broadcast is callable", function()
      local host = lurek.net.host_create()
      host:broadcast(0, "hello")
      host:destroy()
    end)

    -- @covers LNetworkHost:destroy
    it("destroy is callable", function()
      local host = lurek.net.host_create()
      host:destroy()
    end)
  end)
end
end
-- END test_net_core_unit.lua

test_summary()
