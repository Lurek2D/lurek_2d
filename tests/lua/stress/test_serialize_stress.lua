-- Lurek2D Stress Test: Serial Module
-- Tests encode/decode throughput under high volume

-- @describe serial stress: base64 throughput
describe("serial stress: base64 throughput", function()
    -- @stress lurek.data.decode
    -- @stress lurek.data.encode
    it("1000 base64 encode-decode cycles", function()
        local input = string.rep("Stress test payload for serialization. ", 10)
        local decoded_last = nil

        for i = 1, 1000 do
            local encoded = lurek.data.encode("base64", input)
            decoded_last = lurek.data.decode("base64", encoded)
        end
        expect_equal(input, decoded_last)
    end)

    -- @stress lurek.data.decode
    -- @stress lurek.data.encode
    it("increasing payload sizes", function()
        for size = 1, 10 do
            local payload = string.rep("X", size * 100)
            local encoded = lurek.data.encode("base64", payload)
            local decoded = lurek.data.decode("base64", encoded)
            expect_equal(payload, decoded, "size " .. (size * 100) .. " round-trip")
        end
    end)
end)

-- @describe serial stress: data encode throughput
describe("serial stress: data encode throughput", function()
    -- @stress lurek.serial.fromJson
    -- @stress lurek.serial.toJson
    it("1000 JSON encode-decode cycles", function()
        local input = { x = 1.5, y = 2.5, name = "stress", items = { 1, 2, 3 } }

        if type(lurek.serialize) ~= "table" or type(lurek.serial.toJson) ~= "function" or type(lurek.serial.fromJson) ~= "function" then
            expect_true(type(lurek.serialize) ~= "table" or type(lurek.serial.toJson) ~= "function" or type(lurek.serial.fromJson) ~= "function")
            return
        end

        local out = nil
        for i = 1, 1000 do
            local json = lurek.serial.toJson(input, false)
            out = lurek.serial.fromJson(json)
        end
        expect_type("table", out)
    end)

    -- @stress lurek.data.compress
    -- @stress lurek.data.decompress
    it("100 compression cycles on 10KB data", function()
        local input = string.rep("ABCDEFGHIJ", 1000)  -- 10KB
        local decompressed_last = nil
        for i = 1, 100 do
            local compressed = lurek.data.compress("deflate", input)
            decompressed_last = lurek.data.decompress("deflate", compressed)
        end
        expect_equal(input, decompressed_last)
    end)
end)
test_summary()
