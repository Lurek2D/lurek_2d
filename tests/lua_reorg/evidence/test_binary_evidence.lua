-- Canonical evidence file for lurek.binary data outputs.

local OUT = evidence_output_dir("binary")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.binary data outputs
describe("Evidence: lurek.binary data outputs", function()
    before_each(function()
        ensure_evidence_dir("binary")
    end)

    -- @evidence lurek.binary.parseToml
    -- @evidence lurek.binary.encodeToml
    it("writes binary_toml_roundtrip_snapshot.toml", function()
        local input = [[
[game]
title = "Test Game"
version = "1.0.0"

[window]
width = 800
height = 600
fullscreen = false

[physics]
gravity_x = 0.0
gravity_y = 9.8
max_bodies = 1000
]]
        local parsed = lurek.binary.parseToml(input)
        local encoded = lurek.binary.encodeToml(parsed)
        write_text(OUT .. "binary_toml_roundtrip_snapshot.toml", encoded)
    end)

    -- @evidence lurek.binary.encode
    -- @evidence lurek.binary.decode
    it("writes binary_encode_reference_values.txt", function()
        local payload = "Lurek2D rocks!"
        local base64 = lurek.binary.encode("base64", payload)
        local hex = lurek.binary.encode("hex", payload)
        local decoded = lurek.binary.decode("base64", base64)
        local text = table.concat({
            "payload=" .. payload,
            "base64=" .. base64,
            "hex=" .. hex,
            "base64_roundtrip=" .. tostring(decoded == payload),
        }, "\n") .. "\n"
        write_text(OUT .. "binary_encode_reference_values.txt", text)
    end)

    -- @evidence lurek.binary.hash
    -- @evidence lurek.binary.crc32
    it("writes binary_hash_reference_values.txt", function()
        local text = table.concat({
            "md5_hello=" .. lurek.binary.hash("md5", "Hello, Lurek2D!"),
            "sha1_engine=" .. lurek.binary.hash("sha1", "Lurek2D engine test vector"),
            "sha256_hello=" .. lurek.binary.hash("sha256", "Hello, Lurek2D!"),
            "sha512_engine=" .. lurek.binary.hash("sha512", "Lurek2D engine test vector"),
            "crc32_vector=" .. tostring(lurek.binary.crc32("123456789")),
        }, "\n") .. "\n"
        write_text(OUT .. "binary_hash_reference_values.txt", text)
    end)

    -- @evidence lurek.binary.pack
    -- @evidence lurek.binary.unpack
    -- @evidence lurek.binary.getPackedSize
    -- @evidence lurek.binary.write
    -- @evidence lurek.binary.read
    -- @evidence lurek.binary.size
    it("writes binary_pack_roundtrip_snapshot.txt", function()
        local packed = lurek.binary.pack("BHI", 255, 1000, 123456)
        local b, h, i = lurek.binary.unpack("BHI", packed)
        local stream = lurek.binary.write("bool cstr", true, "ok")
        local flag, text = lurek.binary.read("bool cstr", stream)
        local fixed_stream = lurek.binary.write("u32", 7)
        local lines = {
            "packed_len=" .. tostring(#packed),
            "packed_size=" .. tostring(lurek.binary.getPackedSize("BHI", 0, 0, 0)),
            "unpacked=" .. table.concat({ tostring(b), tostring(h), tostring(i) }, ","),
            "fixed_stream_size=" .. tostring(lurek.binary.size("u32")),
            "fixed_stream_len=" .. tostring(#fixed_stream),
            "stream_flag=" .. tostring(flag),
            "stream_text=" .. tostring(text),
        }
        write_text(OUT .. "binary_pack_roundtrip_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence lurek.binary.compress
    -- @evidence lurek.binary.decompress
    -- @evidence lurek.binary.compressChunks
    -- @evidence lurek.binary.decompressChunks
    -- @evidence lurek.binary.toMsgPack
    -- @evidence lurek.binary.fromMsgPack
    it("writes binary_compression_msgpack_snapshot.txt", function()
        local raw = string.rep("hello", 40)
        local compressed = lurek.binary.compress("deflate", raw)
        local restored = lurek.binary.decompress("deflate", compressed)
        local chunk_blob = lurek.binary.compressChunks("zlib", { "alpha", "beta", "gamma" })
        local chunk_restore = lurek.binary.decompressChunks("zlib", chunk_blob)
        local msgpack = lurek.binary.toMsgPack({ score = 100, name = "test" })
        local decoded = lurek.binary.fromMsgPack(msgpack)
        local lines = {
            "raw_len=" .. tostring(#raw),
            "compressed_len=" .. tostring(#compressed),
            "restored_matches=" .. tostring(restored == raw),
            "chunks_restored=" .. tostring(chunk_restore),
            "msgpack_len=" .. tostring(#msgpack),
            "msgpack_name=" .. tostring(decoded.name),
            "msgpack_score=" .. tostring(decoded.score),
        }
        write_text(OUT .. "binary_compression_msgpack_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence lurek.binary.newByteData
    -- @evidence lurek.binary.newDataView
    -- @evidence lurek.binary.newRingBuffer
    -- @evidence lurek.binary.newWriter
    it("writes binary_buffer_surface_snapshot.txt", function()
        local bytes = lurek.binary.newByteData(16)
        local raw = lurek.binary.pack("<II", 42, 99)
        local view = lurek.binary.newDataView(raw)
        local ring = lurek.binary.newRingBuffer(3)
        ring:push("a")
        ring:push("b")
        local evicted = ring:push("d")
        local writer = lurek.binary.newWriter()
        local lines = {
            "bytedata_size=" .. tostring(bytes:getSize()),
            "bytedata_first=" .. tostring(bytes:getByte(0)),
            "dataview_size=" .. tostring(view:getSize()),
            "dataview_first_u32=" .. tostring(view:getUInt32(0)),
            "ring_len=" .. tostring(ring:len()),
            "ring_newest=" .. tostring(ring:peekNewest()),
            "ring_evicted=" .. tostring(evicted),
            "writer_type=" .. tostring(writer:type()),
        }
        write_text(OUT .. "binary_buffer_surface_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence LRingBuffer:push
    -- @evidence LRingBuffer:pop
    -- @evidence LRingBuffer:peek
    -- @evidence LRingBuffer:peekNewest
    -- @evidence LRingBuffer:isEmpty
    -- @evidence LRingBuffer:isFull
    -- @evidence LRingBuffer:toTable
    -- @evidence LDataView:getUInt8
    -- @evidence LDataView:getUInt16
    -- @evidence LDataView:getInt32
    -- @evidence LDataView:getFloat
    -- @evidence LByteData:setByte
    -- @evidence LByteData:getString
    -- @evidence LByteData:clone
    -- @evidence LByteData:setBit
    -- @evidence LByteData:getBit
    -- @evidence LByteData:readBits
    it("writes binary_low_level_buffers_trace.txt", function()
        local ring = lurek.binary.newRingBuffer(2)
        expect_true(ring:isEmpty())
        ring:push("left")
        ring:push("right")
        local evicted = ring:push("newest")
        local oldest = ring:peek()
        local newest = ring:peekNewest()
        local popped = ring:pop()
        local items = ring:toTable()

        local view = lurek.binary.newDataView(lurek.binary.pack("<BHIIf", 7, 300, 12345, 67890, 3.5))
        local bytes = lurek.binary.newByteData(2)
        bytes:setByte(0, 170)
        bytes:setByte(1, 85)
        bytes:setBit(0, 0, true)
        local clone = bytes:clone()
        local writer = lurek.binary.newWriter()

        local lines = {
            "ring_is_full=" .. tostring(ring:isFull()),
            "ring_evicted=" .. tostring(evicted),
            "ring_oldest=" .. tostring(oldest),
            "ring_newest=" .. tostring(newest),
            "ring_popped=" .. tostring(popped),
            "ring_remaining=" .. table.concat(items, ","),
            "u8=" .. tostring(view:getUInt8(0)),
            "u16=" .. tostring(view:getUInt16(1)),
            "i32=" .. tostring(view:getInt32(3)),
            "float=" .. tostring(view:getFloat(11)),
            "bytes_string_len=" .. tostring(#bytes:getString()),
            "bit_0=" .. tostring(bytes:getBit(0, 0)),
            "read_bits=" .. tostring(bytes:readBits(0, 0, 4)),
            "clone_first_byte=" .. tostring(clone:getByte(0)),
            "writer_type=" .. tostring(writer:type()),
        }
        write_text(OUT .. "binary_low_level_buffers_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
