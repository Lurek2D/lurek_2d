-- Integration: typed Channel passing JSON-serialized data between thread contexts
-- @describe integration: thread channel with serialized data

-- @describe integration: thread channel with serialized data
describe("integration: thread channel with serialized data", function()

    -- @integration LChannel:getCount
    -- @integration LChannel:pop
    -- @integration LChannel:push
    -- @integration lurek.serial.fromJson
    -- @integration lurek.serial.toJson
    -- @integration lurek.thread.newChannel
    -- @integration lurek.serial.fromJson
    -- @integration lurek.serial.toJson
    -- @integration lurek.thread.newChannel
    it("pushes JSON-encoded table and receives raw string", function()
        local ch      = lurek.thread.newChannel()
        local payload = {x = 10, y = 20, label = "pos"}

        local encoded = lurek.serial.toJson(payload)
        ch:push(encoded)
        expect_equal(1, ch:getCount(), "channel count increases after push")

        local raw = ch:pop()
        expect_equal(0, ch:getCount(), "channel count drops after pop")
        expect_type("string", raw, "received encoded string from channel")

        local decoded = lurek.serial.fromJson(raw)
        expect_equal(10,    decoded.x,     "x round-tripped through channel")
        expect_equal(20,    decoded.y,     "y round-tripped through channel")
        expect_equal("pos", decoded.label, "label round-tripped through channel")
    end)

    -- @integration LChannel:getCount
    -- @integration LChannel:pop
    -- @integration LChannel:push
    -- @integration lurek.serial.fromJson
    -- @integration lurek.serial.toJson
    -- @integration lurek.thread.newChannel
    it("large payload round-trips via channel", function()
        local ch = lurek.thread.newChannel()
        local big = {}
        for i = 1, 1000 do big[i] = i * 2 end

        local encoded = lurek.serial.toJson(big)
        ch:push(encoded)
        expect_equal(1, ch:getCount(), "large payload still occupies one queued channel entry")

        local raw     = ch:pop()
        expect_equal(0, ch:getCount(), "channel is empty after popping the large payload")
        local decoded = lurek.serial.fromJson(raw)
        expect_equal(1000, #decoded,     "1000-element array round-tripped")
        expect_equal(2000, decoded[1000], "last element correct")
    end)
end)
test_summary()
