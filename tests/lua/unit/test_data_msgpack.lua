-- tests/lua/unit/test_data_msgpack.lua
-- Tests for lurek.data.toMsgPack and lurek.data.fromMsgPack
-- MessagePack binary serialization roundtrip.

describe("data.msgpack", function()

    it("roundtrips a boolean", function()
        local bytes = lurek.data.toMsgPack(true)
        expect_equal(type(bytes), "string")
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val, true)
    end)

    it("roundtrips an integer", function()
        local bytes = lurek.data.toMsgPack(42)
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val, 42)
    end)

    it("roundtrips a float", function()
        local bytes = lurek.data.toMsgPack(3.14)
        local val = lurek.data.fromMsgPack(bytes)
        expect_near(val, 3.14, 1e-10)
    end)

    it("roundtrips a string", function()
        local bytes = lurek.data.toMsgPack("hello msgpack")
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val, "hello msgpack")
    end)

    it("roundtrips nil", function()
        local bytes = lurek.data.toMsgPack(nil)
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val, nil)
    end)

    it("roundtrips a flat table (object)", function()
        local tbl = { x = 1, y = 2, name = "test" }
        local bytes = lurek.data.toMsgPack(tbl)
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val.x, 1)
        expect_equal(val.y, 2)
        expect_equal(val.name, "test")
    end)

    it("roundtrips a sequence table (array)", function()
        local arr = { 10, 20, 30 }
        local bytes = lurek.data.toMsgPack(arr)
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val[1], 10)
        expect_equal(val[2], 20)
        expect_equal(val[3], 30)
    end)

    it("roundtrips a nested table", function()
        local data = { player = { name = "hero", hp = 100 }, level = 5 }
        local bytes = lurek.data.toMsgPack(data)
        local val = lurek.data.fromMsgPack(bytes)
        expect_equal(val.level, 5)
        expect_equal(val.player.name, "hero")
        expect_equal(val.player.hp, 100)
    end)

    it("produces a binary string shorter than JSON for integers", function()
        local data = { a = 1, b = 2, c = 3 }
        local bytes = lurek.data.toMsgPack(data)
        local json  = lurek.codec.toJson(data, false)
        -- MessagePack should be more compact than JSON for this payload
        expect_equal(#bytes <= #json, true)
    end)

    it("raises an error when fromMsgPack receives invalid bytes", function()
        expect_error(function()
            -- 0xFF 0xFF is not valid MessagePack
            lurek.data.fromMsgPack("\xFF\xFF")
        end)
    end)

end)

test_summary()
