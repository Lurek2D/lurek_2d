-- Lurek2D Stress Test: Binary throughput operations
-- Canonical stress coverage for large payload and repeated binary work.

local function make_repeated_payload(chunk, count)
    return string.rep(chunk, count)
end

local function unpack_sum_via_roundtrip(count)
    local sum = 0
    for i = 1, count do
        local value = lurek.binary.unpack("<I", lurek.binary.pack("<I", i))
        sum = sum + value
    end
    return sum
end

local function expect_gzip_roundtrip(payload, repeats)
    local compressed = lurek.binary.compress("gzip", payload, 6)
    for _ = 1, repeats do
        expect_equal(payload, lurek.binary.decompress("gzip", compressed))
    end
end

local function decode_roundtrip_lengths()
    local base64_input = make_repeated_payload("Base64 benchmark. ", 2778)
    local base64_encoded = lurek.binary.encode("base64", base64_input)
    local base64_decoded = lurek.binary.decode("base64", base64_encoded)

    local hex_input = make_repeated_payload("HexData!", 1250)
    local hex_encoded = lurek.binary.encode("hex", hex_input)
    local hex_decoded = lurek.binary.decode("hex", hex_encoded)

    return #base64_input, #base64_decoded, #hex_input, #hex_decoded
end

-- @describe binary stress: pack and unpack throughput
describe("binary stress: pack and unpack throughput", function()
    -- @stress lurek.binary.pack
    it("packs 10000 little-endian integers", function()
        local total_bytes = 0
        for i = 1, 10000 do
            local bytes = lurek.binary.pack("<I", i)
            total_bytes = total_bytes + #bytes
        end
        expect_equal(40000, total_bytes, "all packed integers contribute four bytes")
    end)

    -- @stress lurek.binary.unpack
    it("unpacks 5000 packed integers without drift", function()
        local sum = unpack_sum_via_roundtrip(5000)
        expect_equal((5000 * 5001) / 2, sum, "unpacked integers preserve values")
    end)
end)

-- @describe binary stress: compression throughput
describe("binary stress: compression throughput", function()
    -- @stress lurek.binary.compress
    it("compresses large payloads across formats and levels", function()
        local big_string = make_repeated_payload("Lurek2D engine test data with repetition. ", 1000)
        expect_true(#big_string > 30000, "data is large enough: " .. #big_string)

        local formats = {"deflate", "gzip", "zlib", "lz4"}
        for _, fmt in ipairs(formats) do
            local compressed = lurek.binary.compress(fmt, big_string, 6)
            expect_not_nil(compressed, fmt .. " produced output")
            expect_true(#compressed > 0, fmt .. " has content")
        end

        for level = 1, 9 do
            local compressed = lurek.binary.compress("deflate", big_string, level)
            expect_not_nil(compressed, "level " .. level .. " produced output")
        end
    end)

    -- @stress lurek.binary.decompress
    it("decompresses repeated gzip payloads back to the original bytes", function()
        local payload = make_repeated_payload("gzip roundtrip payload ", 1500)
        expect_gzip_roundtrip(payload, 50)
    end)

    -- @stress lurek.binary.compressChunks
    it("compresses 1000 fixed-size chunks into one blob", function()
        local chunks = {}
        for i = 1, 1000 do
            chunks[i] = string.format("chunk_%04d_payload", i)
        end
        local compressed = lurek.binary.compressChunks("zlib", chunks)
        expect_type("string", compressed)
        expect_true(#compressed > 0, "compressed chunk stream has content")
    end)
    local function __audit_stress_1()
        local chunks = {}
        for i = 1, 250 do
            chunks[i] = string.format("seg_%04d", i)
        end
        local compressed = lurek.binary.compressChunks("zlib", chunks)
        local restored = lurek.binary.decompressChunks("zlib", compressed)
        expect_equal(table.concat(chunks), restored, "chunk stream roundtrip preserves order")
    end


    -- @stress lurek.binary.decompressChunks
    it("restores chunk payload order after chunk compression", function()
        __audit_stress_1()
    end)
end)

-- @describe binary stress: hashing and checksums
describe("binary stress: hashing and checksums", function()
    -- @stress lurek.binary.hash
    it("hashes 10KB data with multiple algorithms deterministically", function()
        local data = make_repeated_payload("Hash benchmark data. ", 500)
        local baselines = {}
        local algos = {"md5", "sha1", "sha256", "sha512"}

        for _, algo in ipairs(algos) do
            baselines[algo] = lurek.binary.hash(algo, data)
            expect_true(#baselines[algo] > 0, algo .. " produces digest")
        end

        for i = 1, 25 do
            expect_equal(baselines.sha256, lurek.binary.hash("sha256", data), "sha256 call " .. i .. " matches")
        end
        expect_true(lurek.binary.hash("sha256", "data1") ~= lurek.binary.hash("sha256", "data2"))
    end)

    -- @stress lurek.binary.crc32
    it("computes crc32 across 500 payload variants", function()
        local first = lurek.binary.crc32("crc-seed-1")
        local unique_changes = 0

        for i = 1, 500 do
            local digest = lurek.binary.crc32("crc-seed-" .. i)
            expect_type("number", digest)
            if digest ~= first then
                unique_changes = unique_changes + 1
            end
        end

        expect_true(unique_changes > 400, "crc32 changes with input variations")
    end)
end)

-- @describe binary stress: text encoding throughput
describe("binary stress: text encoding throughput", function()
    -- @stress lurek.binary.encode
    it("encodes large payloads to base64 and hex", function()
        local base64_input = make_repeated_payload("Base64 benchmark. ", 2778)
        local base64_encoded = lurek.binary.encode("base64", base64_input)
        expect_not_nil(base64_encoded, "base64 encode produced output")
        expect_true(#base64_encoded > #base64_input, "base64 encoding is larger than input")

        local hex_input = make_repeated_payload("HexData!", 1250)
        local hex_encoded = lurek.binary.encode("hex", hex_input)
        expect_equal(#hex_input * 2, #hex_encoded, "hex doubles size")
    end)

    -- @stress lurek.binary.decode
    it("decodes base64 and hex payloads back to their original size", function()
        local base64_input_len, base64_decoded_len, hex_input_len, hex_decoded_len = decode_roundtrip_lengths()
        expect_equal(base64_input_len, base64_decoded_len, "base64 roundtrip preserves length")
        expect_equal(hex_input_len, hex_decoded_len, "hex roundtrip preserves length")
    end)
end)
test_summary()
