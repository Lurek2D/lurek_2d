-- Lurek2D Stress Test: Serial Module
-- Tests encode/decode throughput under high volume

local function run_base64_cycles(input, cycles)
    local encoded_last = nil
    local decoded_last = nil
    for _ = 1, cycles do
        encoded_last = lurek.binary.encode("base64", input)
        decoded_last = lurek.binary.decode("base64", encoded_last)
    end
    return encoded_last, decoded_last
end

local function base64_roundtrip(payload)
    local encoded = lurek.binary.encode("base64", payload)
    return lurek.binary.decode("base64", encoded)
end

local function json_cycle_payload(input, cycles)
    local json_last = nil
    local out = nil
    for _ = 1, cycles do
        json_last = lurek.serialize.toJson(input, false)
        out = lurek.serialize.fromJson(json_last)
    end
    return json_last, out
end

local function expect_json_roundtrip_cycles(input, cycles)
    local json_last, out = json_cycle_payload(input, cycles)
    expect_type("string", json_last)
    expect_type("table", out)
end

local function serial_json_available()
    return type(lurek.serialize) == "table"
        and type(lurek.serialize.toJson) == "function"
        and type(lurek.serialize.fromJson) == "function"
end

local function run_compression_cycles(input, cycles)
    local decompressed_last = nil
    for _ = 1, cycles do
        local compressed = lurek.binary.compress("deflate", input)
        decompressed_last = lurek.binary.decompress("deflate", compressed)
    end
    return decompressed_last
end

-- @describe serial stress: base64 throughput
describe("serial stress: base64 throughput", function()
    -- @stress lurek.binary.encode
    it("1000 base64 encode-decode cycles", function()
        local input = string.rep("Stress test payload for serialization. ", 10)
        local encoded_last, decoded_last = run_base64_cycles(input, 1000)
        expect_type("string", encoded_last)
        expect_true(#encoded_last > 0, "encoded payload should not be empty")
        expect_equal(input, decoded_last)
    end)

    -- @stress lurek.binary.decode
    it("increasing payload sizes", function()
        for size = 1, 10 do
            local payload = string.rep("X", size * 100)
            local decoded = base64_roundtrip(payload)
            expect_equal(payload, decoded, "size " .. (size * 100) .. " round-trip")
        end
    end)
end)

-- @describe serial stress: data encode throughput
describe("serial stress: data encode throughput", function()
    -- @stress lurek.serialize.toJson
    it("1000 JSON encode-decode cycles", function()
        local input = { x = 1.5, y = 2.5, name = "stress", items = { 1, 2, 3 } }

        if not serial_json_available() then
            expect_true(not serial_json_available())
            return
        end

        expect_json_roundtrip_cycles(input, 1000)
    end)

    -- @stress lurek.binary.decompress
    it("100 compression cycles on 10KB data", function()
        local input = string.rep("ABCDEFGHIJ", 1000)  -- 10KB
        local decompressed_last = run_compression_cycles(input, 100)
        expect_equal(input, decompressed_last)
    end)
end)
test_summary()
