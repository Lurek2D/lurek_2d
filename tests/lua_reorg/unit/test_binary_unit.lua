-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_binary_core_unit.lua
do
-- Canonical unit coverage for lurek.binary.

local function new_byte_data(value)
    return lurek.binary.newByteData(value or 4)
end

local function new_data_view(bytes, offset, size)
    return lurek.binary.newDataView(bytes or "\x01\x02\x03\x04", offset, size)
end

local function new_ring_buffer(capacity)
    return lurek.binary.newRingBuffer(capacity or 4)
end

local function new_writer()
    return lurek.binary.newWriter()
end

-- @describe module functions
describe("binary module functions", function()
    -- @covers lurek.binary.pack
    it("pack writes a little-endian float", function()
        local bytes = lurek.binary.pack("<f", 3.14)
        expect_type("string", bytes)
        expect_equal(4, #bytes)
    end)

    -- @covers lurek.binary.unpack
    it("unpack reads packed values", function()
        local value = lurek.binary.unpack("<H", lurek.binary.pack("<H", 513))
        expect_equal(513, value)
    end)

    -- @covers lurek.binary.getPackedSize
    it("getPackedSize counts fixed-width tokens", function()
        expect_equal(5, lurek.binary.getPackedSize("Bf"))
    end)

    -- @covers lurek.binary.compress
    it("compress produces a byte string", function()
        local compressed = lurek.binary.compress("deflate", string.rep("AAAA", 32))
        expect_type("string", compressed)
    end)

    -- @covers lurek.binary.decompress
    it("decompress restores original payload", function()
        local payload = "Hello, Lurek2D!"
        local compressed = lurek.binary.compress("gzip", payload)
        expect_equal(payload, lurek.binary.decompress("gzip", compressed))
    end)

    -- @covers lurek.binary.compressChunks
    it("compressChunks accepts an array of strings", function()
        local compressed = lurek.binary.compressChunks("zlib", { "ab", "cd", "ef" })
        expect_type("string", compressed)
        expect_greater(#compressed, 0)
    end)

    -- @covers lurek.binary.decompressChunks
    it("decompressChunks restores chunk boundaries", function()
        local chunks = { "one", "two" }
        local compressed = lurek.binary.compressChunks("zlib", chunks)
        local restored = lurek.binary.decompressChunks("zlib", compressed)
        expect_equal("onetwo", restored)
    end)

    -- @covers lurek.binary.encode
    it("encode converts bytes to base64", function()
        expect_equal("SGVsbG8=", lurek.binary.encode("base64", "Hello"))
    end)

    -- @covers lurek.binary.decode
    it("decode converts base64 back to bytes", function()
        expect_equal("Hello", lurek.binary.decode("base64", "SGVsbG8="))
    end)

    -- @covers lurek.binary.hash
    it("hash produces a known md5 digest", function()
        expect_equal("5d41402abc4b2a76b9719d911017c592", lurek.binary.hash("md5", "hello"))
    end)

    -- @covers lurek.binary.crc32
    it("crc32 matches the standard test vector", function()
        expect_equal(3421780262, lurek.binary.crc32("123456789"))
    end)

    -- @covers lurek.binary.newByteData
    it("newByteData creates zeroed bytes from a size", function()
        local bytes = new_byte_data(3)
        expect_equal(3, bytes:getSize())
        expect_equal(0, bytes:getByte(0))
    end)

    -- @covers lurek.binary.newDataView
    it("newDataView exposes a byte slice", function()
        local view = new_data_view("abc", 1, 2)
        expect_equal(2, view:getSize())
    end)

    -- @covers lurek.binary.write
    it("write serializes values with the pack-format DSL", function()
        local bytes = lurek.binary.write("u32 f32", 42, 3.5)
        expect_type("string", bytes)
    end)

    -- @covers lurek.binary.read
    it("read deserializes values with the pack-format DSL", function()
        local bytes = lurek.binary.write("bool cstr", true, "ok")
        local flag, text = lurek.binary.read("bool cstr", bytes)
        expect_true(flag)
        expect_equal("ok", text)
    end)

    -- @covers lurek.binary.size
    it("size returns fixed-format byte width", function()
        expect_equal(14, lurek.binary.size("f32 f64 bool pad"))
    end)

    -- @covers lurek.binary.parseToml
    it("parseToml decodes nested tables", function()
        local parsed = lurek.binary.parseToml('[window]\nwidth = 800\nheight = 600')
        expect_equal(800, parsed.window.width)
        expect_equal(600, parsed.window.height)
    end)

    -- @covers lurek.binary.encodeToml
    it("encodeToml emits scalar assignments", function()
        local encoded = lurek.binary.encodeToml({ name = "test", count = 5 })
        expect_contains(encoded, 'name = "test"')
        expect_contains(encoded, "count = 5")
    end)

    -- @covers lurek.binary.newRingBuffer
    it("newRingBuffer creates userdata", function()
        expect_type("userdata", new_ring_buffer(4))
    end)

    -- @covers lurek.binary.toMsgPack
    it("toMsgPack serializes Lua tables", function()
        local blob = lurek.binary.toMsgPack({ x = 1, y = 2 })
        expect_type("string", blob)
    end)

    -- @covers lurek.binary.fromMsgPack
    it("fromMsgPack decodes a scalar payload", function()
        expect_equal(42, lurek.binary.fromMsgPack(lurek.binary.toMsgPack(42)))
    end)

    -- @covers lurek.binary.newWriter
    it("newWriter creates userdata", function()
        expect_type("userdata", new_writer())
    end)
end)

-- @describe ring buffer methods
describe("ring buffer methods", function()
    -- @covers LRingBuffer:push
    it("push reports overwrite when capacity is exceeded", function()
        local rb = new_ring_buffer(2)
        rb:push(1)
        rb:push(2)
        expect_true(rb:push(3))
    end)

    -- @covers LRingBuffer:pop
    it("pop returns the oldest value", function()
        local rb = new_ring_buffer(4)
        rb:push("a")
        rb:push("b")
        expect_equal("a", rb:pop())
    end)

    -- @covers LRingBuffer:peek
    it("peek returns the oldest value without removing it", function()
        local rb = new_ring_buffer(4)
        rb:push(10)
        expect_equal(10, rb:peek())
    end)

    -- @covers LRingBuffer:peekNewest
    it("peekNewest returns the newest value", function()
        local rb = new_ring_buffer(4)
        rb:push(10)
        rb:push(20)
        expect_equal(20, rb:peekNewest())
    end)

    -- @covers LRingBuffer:len
    it("len tracks the number of buffered values", function()
        local rb = new_ring_buffer(4)
        rb:push(1)
        rb:push(2)
        expect_equal(2, rb:len())
    end)

    -- @covers LRingBuffer:capacity
    it("capacity returns the configured maximum size", function()
        expect_equal(6, new_ring_buffer(6):capacity())
    end)

    -- @covers LRingBuffer:isEmpty
    it("isEmpty is true for a fresh buffer", function()
        expect_true(new_ring_buffer(4):isEmpty())
    end)

    -- @covers LRingBuffer:isFull
    it("isFull becomes true once capacity is reached", function()
        local rb = new_ring_buffer(2)
        rb:push(1)
        rb:push(2)
        expect_true(rb:isFull())
    end)

    -- @covers LRingBuffer:clear
    it("clear removes all values", function()
        local rb = new_ring_buffer(4)
        rb:push(1)
        rb:push(2)
        rb:clear()
        expect_equal(0, rb:len())
    end)

    -- @covers LRingBuffer:toTable
    it("toTable returns values in FIFO order", function()
        local rb = new_ring_buffer(4)
        rb:push("x")
        rb:push("y")
        expect_deep_equal({ "x", "y" }, rb:toTable())
    end)

    -- @covers LRingBuffer:type
    it("type returns LRingBuffer", function()
        expect_equal("LRingBuffer", new_ring_buffer(4):type())
    end)

    -- @covers LRingBuffer:typeOf
    it("typeOf recognizes the ring buffer type", function()
        expect_true(new_ring_buffer(4):typeOf("LRingBuffer"))
    end)
end)

-- @describe data view methods
describe("data view methods", function()
    -- @covers LDataView:getUInt8
    it("getUInt8 reads an unsigned byte", function()
        expect_equal(255, new_data_view("\xFF"):getUInt8(0))
    end)

    -- @covers LDataView:getInt8
    it("getInt8 reads a signed byte", function()
        expect_equal(-5, new_data_view(lurek.binary.pack("b", -5)):getInt8(0))
    end)

    -- @covers LDataView:getInt16
    it("getInt16 reads a signed 16-bit integer", function()
        expect_equal(-300, new_data_view(lurek.binary.pack("<h", -300)):getInt16(0))
    end)

    -- @covers LDataView:getUInt16
    it("getUInt16 reads an unsigned 16-bit integer", function()
        expect_equal(1000, new_data_view(lurek.binary.pack("<H", 1000)):getUInt16(0))
    end)

    -- @covers LDataView:getInt32
    it("getInt32 reads a signed 32-bit integer", function()
        expect_equal(-123456, new_data_view(lurek.binary.pack("<i", -123456)):getInt32(0))
    end)

    -- @covers LDataView:getUInt32
    it("getUInt32 reads an unsigned 32-bit integer", function()
        expect_equal(123456, new_data_view(lurek.binary.pack("<I", 123456)):getUInt32(0))
    end)

    -- @covers LDataView:getFloat
    it("getFloat reads a 32-bit float", function()
        expect_near(1.5, new_data_view(lurek.binary.pack("<f", 1.5)):getFloat(0), 0.0001)
    end)

    -- @covers LDataView:getDouble
    it("getDouble reads a 64-bit float", function()
        expect_near(2.5, new_data_view(lurek.binary.pack("<d", 2.5)):getDouble(0), 1e-9)
    end)

    -- @covers LDataView:getSize
    it("getSize returns the view length", function()
        expect_equal(3, new_data_view("abc"):getSize())
    end)

    -- @covers LDataView:type
    it("type returns LDataView", function()
        expect_equal("LDataView", new_data_view("abc"):type())
    end)

    -- @covers LDataView:typeOf
    it("typeOf recognizes the data view type", function()
        expect_true(new_data_view("abc"):typeOf("LDataView"))
    end)
end)

-- @describe byte data methods
describe("byte data methods", function()
    -- @covers LByteData:getSize
    it("getSize returns the byte count", function()
        expect_equal(5, new_byte_data("hello"):getSize())
    end)

    -- @covers LByteData:getString
    it("getString returns the backing bytes", function()
        expect_equal("hello", new_byte_data("hello"):getString())
    end)

    -- @covers LByteData:getByte
    it("getByte returns the value at an index", function()
        expect_equal(65, new_byte_data("AB"):getByte(0))
    end)

    -- @covers LByteData:setByte
    it("setByte updates a byte in place", function()
        local bytes = new_byte_data(2)
        bytes:setByte(1, 66)
        expect_equal(66, bytes:getByte(1))
    end)

    -- @covers LByteData:clone
    it("clone returns an independent copy", function()
        local original = new_byte_data("test")
        local copy = original:clone()
        expect_equal("test", copy:getString())
    end)

    -- @covers LByteData:setBit
    it("setBit updates a bit flag", function()
        local bytes = new_byte_data(1)
        bytes:setBit(0, 3, true)
        expect_true(bytes:getBit(0, 3))
    end)

    -- @covers LByteData:getBit
    it("getBit reads a single bit flag", function()
        local bytes = new_byte_data(1)
        bytes:setByte(0, 0x08)
        expect_true(bytes:getBit(0, 3))
    end)

    -- @covers LByteData:readBits
    it("readBits reads a range across bytes", function()
        local bytes = new_byte_data(2)
        bytes:setByte(0, 0xFF)
        bytes:setByte(1, 0x01)
        expect_equal(31, bytes:readBits(0, 4, 8))
    end)

    -- @covers LByteData:type
    it("type returns LByteData", function()
        expect_equal("LByteData", new_byte_data(1):type())
    end)

    -- @covers LByteData:typeOf
    it("typeOf recognizes the byte-data type", function()
        expect_true(new_byte_data(1):typeOf("LByteData"))
    end)
end)

-- @describe data writer methods
describe("data writer methods", function()
    -- @covers LDataWriter:writeU8
    it("writeU8 appends one byte", function()
        local writer = new_writer()
        writer:writeU8(0x41)
        expect_equal("A", writer:toBytes())
    end)

    -- @covers LDataWriter:writeI8
    it("writeI8 appends a signed byte", function()
        local writer = new_writer()
        writer:writeI8(-5)
        expect_equal(-5, new_data_view(writer:toBytes()):getInt8(0))
    end)

    -- @covers LDataWriter:writeU16LE
    it("writeU16LE appends little-endian bytes", function()
        local writer = new_writer()
        writer:writeU16LE(0x1234)
        expect_equal(0x34, string.byte(writer:toBytes(), 1))
    end)

    -- @covers LDataWriter:writeU16BE
    it("writeU16BE appends big-endian bytes", function()
        local writer = new_writer()
        writer:writeU16BE(0x1234)
        expect_equal(0x12, string.byte(writer:toBytes(), 1))
    end)

    -- @covers LDataWriter:writeI16LE
    it("writeI16LE appends a signed 16-bit integer", function()
        local writer = new_writer()
        writer:writeI16LE(-300)
        expect_equal(-300, new_data_view(writer:toBytes()):getInt16(0))
    end)

    -- @covers LDataWriter:writeU32LE
    it("writeU32LE appends four bytes", function()
        local writer = new_writer()
        writer:writeU32LE(99)
        expect_equal(4, writer:len())
    end)

    -- @covers LDataWriter:writeI32LE
    it("writeI32LE appends a signed 32-bit integer", function()
        local writer = new_writer()
        writer:writeI32LE(-123456)
        expect_equal(-123456, new_data_view(writer:toBytes()):getInt32(0))
    end)

    -- @covers LDataWriter:writeF32LE
    it("writeF32LE appends a 32-bit float", function()
        local writer = new_writer()
        writer:writeF32LE(1.5)
        expect_near(1.5, new_data_view(writer:toBytes()):getFloat(0), 0.0001)
    end)

    -- @covers LDataWriter:writeF64LE
    it("writeF64LE appends a 64-bit float", function()
        local writer = new_writer()
        writer:writeF64LE(2.5)
        expect_near(2.5, new_data_view(writer:toBytes()):getDouble(0), 1e-9)
    end)

    -- @covers LDataWriter:writeString
    it("writeString prefixes the byte length", function()
        local writer = new_writer()
        writer:writeString("hi")
        expect_equal(6, writer:len())
    end)

    -- @covers LDataWriter:writeBytes
    it("writeBytes appends raw byte strings", function()
        local writer = new_writer()
        writer:writeBytes("ab")
        expect_equal("ab", writer:toBytes())
    end)

    -- @covers LDataWriter:seek
    it("seek moves the cursor for later writes", function()
        local writer = new_writer()
        writer:writeU8(0)
        writer:writeU8(0)
        writer:seek(1)
        writer:writeU8(9)
        expect_equal(9, string.byte(writer:toBytes(), 2))
    end)

    -- @covers LDataWriter:tell
    it("tell reports the current cursor position", function()
        local writer = new_writer()
        writer:writeU8(1)
        writer:writeU8(2)
        expect_equal(2, writer:tell())
    end)

    -- @covers LDataWriter:len
    it("len reports the current buffer size", function()
        local writer = new_writer()
        writer:writeBytes("abc")
        expect_equal(3, writer:len())
    end)

    -- @covers LDataWriter:toBytes
    it("toBytes returns the accumulated buffer", function()
        local writer = new_writer()
        writer:writeBytes("xyz")
        expect_equal("xyz", writer:toBytes())
    end)

    -- @covers LDataWriter:type
    it("type returns LDataWriter", function()
        expect_equal("LDataWriter", new_writer():type())
    end)

    -- @covers LDataWriter:typeOf
    it("typeOf recognizes the writer type", function()
        expect_true(new_writer():typeOf("LDataWriter"))
    end)
end)
end
-- END test_binary_core_unit.lua

test_summary()
