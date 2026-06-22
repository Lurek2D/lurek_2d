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
    -- Does: Runs "writes binary_encode_reference_values.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.binary.encode and related owner calls.
    -- Artifact: tests/artifacts/current/binary/binary_encode_reference_values.txt
    -- Why: This is meaningful only if the output is driven by lurek.binary.encode and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "writes binary_hash_reference_values.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.binary.hash and related owner calls.
    -- Artifact: tests/artifacts/current/binary/binary_hash_reference_values.txt
    -- Why: This is meaningful only if the output is driven by lurek.binary.hash and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "writes binary_pack_roundtrip_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.binary.pack and related owner calls.
    -- Artifact: tests/artifacts/current/binary/binary_pack_roundtrip_snapshot.txt
    -- Why: This is meaningful only if the output is driven by lurek.binary.pack and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "writes binary_compression_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.binary.compress and related owner calls.
    -- Artifact: tests/artifacts/current/binary/binary_compression_snapshot.txt
    -- Why: This is meaningful only if the output is driven by lurek.binary.compress and related owner calls rather than by helper-only drawing.

    it("writes binary_compression_snapshot.txt", function()
        local raw = string.rep("hello", 40)
        local compressed = lurek.binary.compress("deflate", raw)
        local restored = lurek.binary.decompress("deflate", compressed)
        local chunk_blob = lurek.binary.compressChunks("zlib", { "alpha", "beta", "gamma" })
        local chunk_restore = lurek.binary.decompressChunks("zlib", chunk_blob)
        local lines = {
            "raw_len=" .. tostring(#raw),
            "compressed_len=" .. tostring(#compressed),
            "restored_matches=" .. tostring(restored == raw),
            "chunks_restored=" .. tostring(chunk_restore),
        }
        write_text(OUT .. "binary_compression_snapshot.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Runs "writes binary_buffer_surface_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.binary.newByteData and related owner calls.
    -- Artifact: tests/artifacts/current/binary/binary_buffer_surface_snapshot.txt
    -- Why: This is meaningful only if the output is driven by lurek.binary.newByteData and related owner calls rather than by helper-only drawing.

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
    -- Does: Runs "writes binary_low_level_buffers_trace.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LRingBuffer:push, LRingBuffer:pop, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/binary/binary_low_level_buffers_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LRingBuffer:push, LRingBuffer:pop, and related owner calls; export helpers are just the container.

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
