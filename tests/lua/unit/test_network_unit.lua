-- Test file: tests/lua/unit/test_network_unit.lua
-- Tests for lurek.network module functions
-- Covers: pack, unpack, setReady, isAllReady, getRoom, getPlayerList

-- @describe lurek.network
describe("lurek.network", function()
    -- @covers lurek.network.pack
    it("packs a table into binary message", function()
        local t = { a = 1, b = "hello", c = true }
        local packed = lurek.network.pack(t)
        assert(type(packed) == "string", "pack should return a string")
        assert(#packed > 0, "packed message should not be empty")
    end)

    -- @covers lurek.network.unpack
    it("unpacks binary message back to table", function()
        local original = { x = 42, y = "test", z = false }
        local packed = lurek.network.pack(original)
        local unpacked = lurek.network.unpack(packed)
        assert(type(unpacked) == "table", "unpack should return a table")
        assert(unpacked.x == 42, "unpacked table should preserve number values")
        assert(unpacked.y == "test", "unpacked table should preserve string values")
        assert(unpacked.z == false, "unpacked table should preserve boolean values")
    end)

    -- @covers lurek.network.pack
    it("packs a number", function()
        local packed = lurek.network.pack(123)
        assert(type(packed) == "string", "pack should handle numbers")
    end)

    -- @covers lurek.network.pack
    it("packs a string", function()
        local packed = lurek.network.pack("hello world")
        assert(type(packed) == "string", "pack should handle strings")
    end)

    -- @covers lurek.network.pack
    it("packs a boolean", function()
        local packed = lurek.network.pack(true)
        assert(type(packed) == "string", "pack should handle booleans")
    end)

    -- @covers lurek.network.setReady
    it("marks a player as ready in a room", function()
        lurek.network.setReady("test_room", 1, true)
        local ready = lurek.network.isAllReady("test_room")
        -- Single player is not "all ready" (requires 2+)
        assert(not ready, "single player should not satisfy isAllReady")
    end)

    -- @covers lurek.network.setReady
    it("marks a player as not ready", function()
        lurek.network.setReady("test_room_2", 1, false)
        local ready = lurek.network.isAllReady("test_room_2")
        assert(not ready, "unready player should make isAllReady false")
    end)

    -- @covers lurek.network.isAllReady
    it("returns true when all players in room are ready", function()
        lurek.network.setReady("ready_room", 1, true)
        lurek.network.setReady("ready_room", 2, true)
        local ready = lurek.network.isAllReady("ready_room")
        assert(ready == true, "all ready players should return true")
    end)

    -- @covers lurek.network.isAllReady
    it("returns false when one player is not ready", function()
        lurek.network.setReady("mixed_room", 1, true)
        lurek.network.setReady("mixed_room", 2, false)
        local ready = lurek.network.isAllReady("mixed_room")
        assert(not ready, "one unready player should return false")
    end)

    -- @covers lurek.network.isAllReady
    it("returns false for non-existent room", function()
        local ready = lurek.network.isAllReady("nonexistent_room")
        assert(not ready, "non-existent room should return false")
    end)

    -- @covers lurek.network.getRoom
    it("returns room metadata", function()
        lurek.network.setReady("metadata_room", 1, true)
        local room = lurek.network.getRoom("metadata_room")
        assert(room ~= nil, "getRoom should return room table")
        assert(type(room) == "table", "getRoom should return table type")
        assert(room.name == "metadata_room", "room name should be preserved")
        assert(room.host_peer == 1, "host_peer should be first peer")
        assert(room.player_count == 1, "player_count should match number of players")
        assert(room.max_players >= 1, "max_players should be positive")
    end)

    -- @covers lurek.network.getRoom
    it("returns nil for non-existent room", function()
        local room = lurek.network.getRoom("does_not_exist")
        assert(room == nil, "getRoom should return nil for non-existent room")
    end)

    -- @covers lurek.network.getRoom
    it("returns correct player count", function()
        lurek.network.setReady("count_room", 1, true)
        lurek.network.setReady("count_room", 2, false)
        lurek.network.setReady("count_room", 3, true)
        local room = lurek.network.getRoom("count_room")
        assert(room.player_count == 3, "player_count should reflect number of players")
    end)

    -- @covers lurek.network.getPlayerList
    it("returns list of player peer IDs", function()
        lurek.network.setReady("player_list_room", 1, true)
        lurek.network.setReady("player_list_room", 2, true)
        lurek.network.setReady("player_list_room", 3, false)
        local players = lurek.network.getPlayerList("player_list_room")
        assert(type(players) == "table", "getPlayerList should return table")
        assert(#players == 3, "player list should contain 3 players")
        assert(players[1] == 1, "first player should be peer 1")
        assert(players[2] == 2, "second player should be peer 2")
        assert(players[3] == 3, "third player should be peer 3")
    end)

    -- @covers lurek.network.getPlayerList
    it("returns empty list for non-existent room", function()
        local players = lurek.network.getPlayerList("empty_room")
        assert(type(players) == "table", "getPlayerList should return table")
        assert(#players == 0, "player list should be empty for non-existent room")
    end)

    -- @covers lurek.network.getPlayerList
    it("returns sorted peer IDs", function()
        lurek.network.setReady("sorted_room", 5, true)
        lurek.network.setReady("sorted_room", 2, true)
        lurek.network.setReady("sorted_room", 8, true)
        local players = lurek.network.getPlayerList("sorted_room")
        assert(players[1] == 2, "player list should be sorted (peer 2 first)")
        assert(players[2] == 5, "player list should be sorted (peer 5 second)")
        assert(players[3] == 8, "player list should be sorted (peer 8 last)")
    end)

    -- @covers lurek.network.setReady
    -- @covers lurek.network.isAllReady
    it("tracks ready state transitions", function()
        local room = "transition_room"
        lurek.network.setReady(room, 1, false)
        lurek.network.setReady(room, 2, false)
        assert(not lurek.network.isAllReady(room), "both unready initially")

        lurek.network.setReady(room, 1, true)
        assert(not lurek.network.isAllReady(room), "one ready is not all ready")

        lurek.network.setReady(room, 2, true)
        assert(lurek.network.isAllReady(room), "both ready now")

        lurek.network.setReady(room, 1, false)
        assert(not lurek.network.isAllReady(room), "one unready breaks all ready")
    end)

    -- @covers lurek.network.setReady
    it("supports multiple rooms independently", function()
        lurek.network.setReady("room_a", 1, true)
        lurek.network.setReady("room_b", 1, false)

        local ready_a = lurek.network.isAllReady("room_a")
        local ready_b = lurek.network.isAllReady("room_b")
        -- Both are single-player, so both false
        assert(not ready_a and not ready_b, "single players in different rooms should be independent")

        lurek.network.setReady("room_a", 2, true)
        lurek.network.setReady("room_b", 2, false)
        local ready_a_2p = lurek.network.isAllReady("room_a")
        local ready_b_2p = lurek.network.isAllReady("room_b")
        assert(ready_a_2p == true, "room_a with 2 ready players should be true")
        assert(ready_b_2p == false, "room_b with 1 ready and 1 unready should be false")
    end)

    -- @covers lurek.network.getRoom
    it("track host peer correctly", function()
        local room = "host_room"
        lurek.network.setReady(room, 5, true)
        lurek.network.setReady(room, 2, true)
        local room_info = lurek.network.getRoom(room)
        assert(room_info.host_peer == 5, "first peer to join should be host")

        -- Add another peer, host should remain
        lurek.network.setReady(room, 8, true)
        room_info = lurek.network.getRoom(room)
        assert(room_info.host_peer == 5, "host should not change when new peer joins")
    end)

    -- @covers lurek.network.newRpc
    it("creates an RPC manager from a host", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        assert(rpc ~= nil, "newRpc should return an RPC manager")
        assert(rpc:type() == "LNetworkRpc", "RPC should have correct type")
    end)

    -- @covers lurek.network.newRpc
    it("creates RPC with custom channel", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host, 2)
        assert(rpc ~= nil, "newRpc with channel should work")
    end)

    -- @covers lurek.network.newRpc
    it("creates RPC with timeout", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host, 0, 10.0)
        assert(rpc ~= nil, "newRpc with timeout should work")
    end)

    -- @covers lurek.network.newRpc
    it("RPC typeOf works correctly", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        assert(rpc:typeOf("LNetworkRpc") == true, "typeOf LNetworkRpc should be true")
        assert(rpc:typeOf("LObject") == true, "typeOf LObject should be true")
        assert(rpc:typeOf("LNetworkHost") == false, "typeOf LNetworkHost should be false")
    end)

    -- @covers lurek.network.newRpc:getNextId
    it("tracks next request ID", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        local id1 = rpc:getNextId()
        assert(type(id1) == "number", "getNextId should return a number")
        assert(id1 > 0, "request ID should be positive")
    end)

    -- @covers lurek.network.newRpc:getPendingCount
    it("returns pending call count", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        local count = rpc:getPendingCount()
        assert(type(count) == "number", "getPendingCount should return a number")
        assert(count >= 0, "pending count should be non-negative")
    end)

    -- @covers lurek.network.newRpc:setLogging
    it("enables and disables logging", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        rpc:setLogging(true)
        rpc:setLogging(false)
        -- If this doesn't error, it works
        assert(true, "setLogging should not error")
    end)

    -- @covers lurek.network.newRpc:setTimeout
    it("sets timeout for pending calls", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        rpc:setTimeout(5.0)
        rpc:setTimeout(0)
        assert(true, "setTimeout should not error")
    end)

    -- @covers lurek.network.newRpc:resetIdCounter
    it("resets request ID counter", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        rpc:resetIdCounter()
        local id = rpc:getNextId()
        assert(id == 1, "after reset, next ID should be 1")
    end)

    -- @covers lurek.network.newRpc:register
    it("registers RPC handlers", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        local handler_called = false
        rpc:register("test_fn", function(peer_id)
            handler_called = true
            return "ok"
        end)
        assert(true, "register should not error")
    end)

    -- @covers lurek.network.newRpc:poll
    it("polls for RPC events", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        local responses = rpc:poll()
        assert(type(responses) == "table", "poll should return a table")
    end)

    -- @covers lurek.network.newRpc:onError
    it("sets error callback", function()
        local host = lurek.network.newHost({ addr = "127.0.0.1:0" })
        local rpc = lurek.network.newRpc(host)
        local error_msg = nil
        rpc:onError(function(msg)
            error_msg = msg
        end)
        assert(true, "onError should not error")
    end)
end)
test_summary()
