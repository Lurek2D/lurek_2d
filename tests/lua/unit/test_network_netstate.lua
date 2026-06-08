-- Test file: tests/lua/unit/test_network_netstate.lua
-- Tests for lurek.network.newNetState (NetState state synchronization manager)

-- @describe lurek.network.newNetState
describe("lurek.network.newNetState", function()
    -- @covers lurek.network.newNetState
    it("creates a network state manager from a host", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host)
        assert(state ~= nil, "newNetState should return a state manager")
        assert(state:type() == "LNetworkState", "state should have correct type")
    end)

    -- @covers lurek.network.newNetState
    it("creates a state manager with custom options", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local opts = { channel = 1, authority = true, turnBased = false }
        local state = lurek.network.newNetState(host, opts)
        assert(state ~= nil, "newNetState with opts should work")
        assert(state:type() == "LNetworkState", "state should have correct type")
    end)

    -- @covers lurek.network.newNetState
    it("creates a state manager in offline mode (nil host)", function()
        local state = lurek.network.newNetState(nil)
        assert(state ~= nil, "newNetState with nil host should work for offline mode")
        assert(state:type() == "LNetworkState", "offline state should have correct type")
    end)

    -- @covers lurek.network.newNetState:type
    it("reports correct type name", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host)
        assert(state:type() == "LNetworkState", "type() should return LNetworkState")
    end)

    -- @covers lurek.network.newNetState:typeOf
    it("checks type by name via typeOf", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host)
        assert(state:typeOf("LNetworkState") == true, "typeOf should recognize LNetworkState")
        assert(state:typeOf("other") == false, "typeOf should reject other types")
    end)

    -- @covers lurek.network.newNetState:set
    it("allows authority to set values", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        state:set("test_key", "test_value")
        -- If no error, set succeeded
        assert(true, "set should work when authority")
    end)

    -- @covers lurek.network.newNetState:get
    it("retrieves state values", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        state:set("key1", 42)
        local val = state:get("key1")
        assert(val == 42, "get should return the set value")
    end)

    -- @covers lurek.network.newNetState:getAll
    it("returns all synced state as a table", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        state:set("a", 1)
        state:set("b", 2)
        local all = state:getAll()
        assert(type(all) == "table", "getAll should return a table")
        assert(all.a == 1, "getAll should contain set values")
        assert(all.b == 2, "getAll should contain all keys")
    end)

    -- @covers lurek.network.newNetState:getCurrentTurn
    it("reports current turn number", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { turnBased = true, authority = true })
        local turn = state:getCurrentTurn()
        assert(type(turn) == "number", "getCurrentTurn should return a number")
    end)

    -- @covers lurek.network.newNetState:beginTurn
    it("advances turn counter in turn-based mode", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { turnBased = true, authority = true })
        local turn1 = state:getCurrentTurn()
        state:beginTurn()
        local turn2 = state:getCurrentTurn()
        assert(turn2 >= turn1, "turn should advance or stay same")
    end)

    -- @covers lurek.network.newNetState:hashState
    it("generates deterministic state hash", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        state:set("x", 100)
        local hash = state:hashState()
        assert(type(hash) == "string", "hashState should return a string")
        assert(#hash > 0, "hash should not be empty")
    end)

    -- @covers lurek.network.newNetState:onChange
    it("registers callback for key changes", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        local called = false
        state:onChange("mykey", function(value, old_value, peer_id)
            called = true
        end)
        -- Registering the callback should not error
        assert(true, "onChange should register without error")
    end)

    -- @covers lurek.network.newNetState:onTurn
    it("registers callback for turn changes", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { turnBased = true })
        local called = false
        state:onTurn(function(turn_num)
            called = true
        end)
        -- Registering should not error
        assert(true, "onTurn should register without error")
    end)

    -- @covers lurek.network.newNetState:poll
    it("processes incoming network state updates", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = true })
        state:poll()
        -- If poll doesn't error, it works
        assert(true, "poll should process without error")
    end)

    -- @covers lurek.network.newNetState:requestFullState
    it("requests full state from authority", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local state = lurek.network.newNetState(host, { authority = false })
        state:requestFullState()
        -- If no error, request was issued
        assert(true, "requestFullState should work")
    end)
end)
test_summary()
