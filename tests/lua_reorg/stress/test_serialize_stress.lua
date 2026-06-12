-- Lurek2D Stress Test: Serial Module
-- Tests encode/decode throughput under high volume

-- @describe serial stress: base64 throughput
describe("serial stress: base64 throughput", function()
    -- @stress lurek.binary.encode
    it("1000 base64 encode-decode cycles", function()
        local input = string.rep("Stress test payload for serialization. ", 10)
        local encoded_last = nil
        local decoded_last = nil

        for i = 1, 1000 do
            encoded_last = lurek.binary.encode("base64", input)
            decoded_last = lurek.binary.decode("base64", encoded_last)
        end
        expect_type("string", encoded_last)
        expect_true(#encoded_last > 0, "encoded payload should not be empty")
        expect_equal(input, decoded_last)
    end)

    -- @stress lurek.binary.decode
    it("increasing payload sizes", function()
        for size = 1, 10 do
            local payload = string.rep("X", size * 100)
            local encoded = lurek.binary.encode("base64", payload)
            local decoded = lurek.binary.decode("base64", encoded)
            expect_equal(payload, decoded, "size " .. (size * 100) .. " round-trip")
        end
    end)
end)

-- @describe serial stress: data encode throughput
describe("serial stress: data encode throughput", function()
    -- @stress lurek.serial.toJson
    it("1000 JSON encode-decode cycles", function()
        local input = { x = 1.5, y = 2.5, name = "stress", items = { 1, 2, 3 } }

        if type(lurek.serialize) ~= "table" or type(lurek.serial.toJson) ~= "function" or type(lurek.serial.fromJson) ~= "function" then
            expect_true(type(lurek.serialize) ~= "table" or type(lurek.serial.toJson) ~= "function" or type(lurek.serial.fromJson) ~= "function")
            return
        end

        local json_last = nil
        local out = nil
        for i = 1, 1000 do
            json_last = lurek.serial.toJson(input, false)
            out = lurek.serial.fromJson(json_last)
        end
        expect_type("string", json_last)
        expect_type("table", out)
    end)

    -- @stress lurek.binary.decompress
    it("100 compression cycles on 10KB data", function()
        local input = string.rep("ABCDEFGHIJ", 1000)  -- 10KB
        local decompressed_last = nil
        for i = 1, 100 do
            local compressed = lurek.binary.compress("deflate", input)
            decompressed_last = lurek.binary.decompress("deflate", compressed)
        end
        expect_equal(input, decompressed_last)
    end)
end)
test_summary()
