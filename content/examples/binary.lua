-- content/examples/binary.lua
-- Auto-generated from content/examples2/data_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/binary.lua

--- Binary Module Part 1: Pack/Unpack, Compression, Encoding, Hashing, TOML, MsgPack, RingBuffer, DataView, Writer

--@api-stub: lurek.data.pack
do
    local packed = lurek.data.pack("BHI", 255, 1000, 123456)
    print("packed len = " .. #packed)
    print("first byte = " .. string.byte(packed, 1))
end

--@api-stub: lurek.data.unpack
do
    local packed = lurek.data.pack("BHI", 255, 1000, 123456)
    local b, h, i = lurek.data.unpack("BHI", packed)
    print("unpacked: " .. b .. ", " .. h .. ", " .. i)
end

--@api-stub: lurek.data.getPackedSize
do
    local sz = lurek.data.getPackedSize("BHI", 0, 0, 0)
    local packed = lurek.data.pack("BHI", 0, 0, 0)
    print("packed size = " .. sz)
    print("matches packed len = " .. tostring(sz == #packed))
end

--@api-stub: lurek.data.compress
do
    local raw = string.rep("hello", 100)
    local compressed = lurek.data.compress("deflate", raw)
    print("raw len = " .. #raw)
    print("compressed len = " .. #compressed)
end

--@api-stub: lurek.data.decompress
do
    local raw = string.rep("world", 100)
    local compressed = lurek.data.compress("deflate", raw)
    local restored = lurek.data.decompress("deflate", compressed)
    print("restored len = " .. #restored)
    print("restored matches = " .. tostring(restored == raw))
end

--@api-stub: lurek.data.compressChunks
do
    local chunks = {"chunk1", "chunk2", "chunk3"}
    local compressed = lurek.data.compressChunks("deflate", chunks)
    print("chunk count = " .. #chunks)
    print("chunks compressed len = " .. #compressed)
end

--@api-stub: lurek.data.decompressChunks
do
    local chunks = {"aaaa", "bbbb", "cccc"}
    local compressed = lurek.data.compressChunks("deflate", chunks)
    local restored = lurek.data.decompressChunks("deflate", compressed)
    print("decompressed chunks len = " .. #restored)
    print("restored preview = " .. restored:sub(1, 8))
end

--@api-stub: lurek.data.encode
do
    local encoded = lurek.data.encode("base64", "Hello, World!")
    print("base64 = " .. encoded)
end

--@api-stub: lurek.data.decode
do
    local encoded = lurek.data.encode("base64", "Hello")
    local decoded = lurek.data.decode("base64", encoded)
    print("decoded = " .. decoded)
end

--@api-stub: lurek.data.hash
do
    local digest = lurek.data.hash("sha256", "secret data")
    print("sha256 = " .. digest)
    print("digest length = " .. #digest)
end

--@api-stub: lurek.data.crc32
do
    local crc = lurek.data.crc32("test data")
    print("crc32 = " .. crc)
    print("crc32 type = " .. type(crc))
end

--@api-stub: lurek.data.newByteData
do
    local bd = lurek.data.newByteData(16)
    print("bytedata size = " .. bd:getSize())
    print("first byte = " .. bd:getByte(0))
end

--@api-stub: lurek.data.newDataView
do
    local raw = lurek.data.pack("<II", 42, 99)
    local view = lurek.data.newDataView(raw)
    print("view size = " .. view:getSize())
    print("first value = " .. view:getUInt32(0))
end

--@api-stub: lurek.data.write
do
    local bytes = lurek.data.write("u32", 42)
    print("write len = " .. #bytes)
    print("read back = " .. lurek.data.read("u32", bytes))
end

--@api-stub: lurek.data.read
do
    local bytes = lurek.data.write("u32", 42)
    local val = lurek.data.read("u32", bytes)
    print("read val = " .. val)
end

--@api-stub: lurek.data.size
do
    local sz = lurek.data.size("u32")
    local bytes = lurek.data.write("u32", 7)
    print("format size = " .. sz)
    print("matches write len = " .. tostring(sz == #bytes))
end

--@api-stub: lurek.data.parseToml
do
    local toml_text = "[player]\nname = \"Hero\"\nlevel = 5"
    local t = lurek.data.parseToml(toml_text)
    print("player name = " .. t.player.name)
    print("player level = " .. tostring(t.player.level))
end

--@api-stub: lurek.data.encodeToml
do
    local t = {title = "My Game", version = "1.0"}
    local text = lurek.data.encodeToml(t)
    print("toml len = " .. #text)
    print("toml preview = " .. text:sub(1, 20))
end

--@api-stub: lurek.data.newRingBuffer
do
    local rb = lurek.data.newRingBuffer(8)
    print("ring capacity = " .. rb:capacity())
    print("ring empty = " .. tostring(rb:isEmpty()))
end

--@api-stub: lurek.data.toMsgPack
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.data.toMsgPack(payload)
    print("msgpack len = " .. #bytes)
    print("first byte = " .. string.byte(bytes, 1))
end

--@api-stub: lurek.data.fromMsgPack
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.data.toMsgPack(payload)
    local decoded = lurek.data.fromMsgPack(bytes)
    print("decoded score = " .. decoded.score)
    print("decoded name = " .. decoded.name)
end

--@api-stub: lurek.data.newWriter
do
    local w = lurek.data.newWriter()
    print("writer created = " .. tostring(w ~= nil))
    print("writer type = " .. w:type())
end

--@api-stub: LRingBuffer:push
do
    local rb = lurek.data.newRingBuffer(3)
    rb:push("a")
    rb:push("b")
    local evicted = rb:push("d")
    print("evicted = " .. tostring(evicted))
    print("newest = " .. tostring(rb:peekNewest()))
end

--@api-stub: LRingBuffer:pop
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local oldest = rb:pop()
    print("popped = " .. oldest)
end

--@api-stub: LRingBuffer:peek
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push("first")
    rb:push("second")
    print("peek = " .. rb:peek())
end

--@api-stub: LRingBuffer:peekNewest
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push("old")
    rb:push("new")
    print("newest = " .. rb:peekNewest())
end

--@api-stub: LRingBuffer:len
do
    local rb = lurek.data.newRingBuffer(10)
    rb:push(1)
    rb:push(2)
    print("len = " .. rb:len())
    print("capacity = " .. rb:capacity())
end

--@api-stub: LRingBuffer:capacity
do
    local rb = lurek.data.newRingBuffer(5)
    print("capacity = " .. rb:capacity())
end

--@api-stub: LRingBuffer:isEmpty
do
    local rb = lurek.data.newRingBuffer(4)
    print("empty = " .. tostring(rb:isEmpty()))
    rb:push("value")
    print("empty after push = " .. tostring(rb:isEmpty()))
end

--@api-stub: LRingBuffer:isFull
do
    local rb = lurek.data.newRingBuffer(2)
    rb:push("a")
    rb:push("b")
    print("full = " .. tostring(rb:isFull()))
    print("len = " .. tostring(rb:len()))
end

--@api-stub: LRingBuffer:clear
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(1)
    rb:push(2)
    rb:clear()
    print("after clear len = " .. rb:len())
end

--@api-stub: LRingBuffer:toTable
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local t = rb:toTable()
    print("table len = " .. #t)
    print("first item = " .. tostring(t[1]))
end

--@api-stub: LRingBuffer:type
do
    local rb = lurek.data.newRingBuffer(4)
    print("type = " .. rb:type())
end

--@api-stub: LRingBuffer:typeOf
do
    local rb = lurek.data.newRingBuffer(4)
    print("is LRingBuffer = " .. tostring(rb:typeOf("LRingBuffer")))
end

--@api-stub: LDataView:getUInt8
do
    local raw = lurek.data.pack("BBBB", 10, 20, 30, 40)
    local view = lurek.data.newDataView(raw)
    print("u8[0] = " .. view:getUInt8(0))
    print("u8[1] = " .. view:getUInt8(1))
end

--@api-stub: LDataView:getInt8
do
    local raw = lurek.data.pack("b", -42)
    local view = lurek.data.newDataView(raw)
    print("i8[0] = " .. view:getInt8(0))
end

--@api-stub: LDataView:getInt16
do
    local raw = lurek.data.pack("h", -1000)
    local view = lurek.data.newDataView(raw)
    print("i16[0] = " .. view:getInt16(0))
end

--@api-stub: LDataView:getUInt16
do
    local raw = lurek.data.pack("H", 65000)
    local view = lurek.data.newDataView(raw)
    print("u16[0] = " .. view:getUInt16(0))
end

--@api-stub: LDataView:getInt32
do
    local raw = lurek.data.pack("<i", -100000)
    local view = lurek.data.newDataView(raw)
    print("i32[0] = " .. view:getInt32(0))
end

--@api-stub: LDataView:getUInt32
do
    local raw = lurek.data.pack("<I", 3000000)
    local view = lurek.data.newDataView(raw)
    print("u32[0] = " .. view:getUInt32(0))
end

--@api-stub: LDataView:getFloat
do
    local raw = lurek.data.pack("f", 3.14)
    local view = lurek.data.newDataView(raw)
    print("f32[0] = " .. view:getFloat(0))
    print("view size = " .. view:getSize())
end

--@api-stub: LDataView:getDouble
do
    local raw = lurek.data.pack("d", 2.718281828)
    local view = lurek.data.newDataView(raw)
    print("f64[0] = " .. view:getDouble(0))
end

--@api-stub: LDataView:getSize
do
    local raw = lurek.data.pack("<III", 1, 2, 3)
    local view = lurek.data.newDataView(raw)
    print("view size = " .. view:getSize())
    print("last value = " .. view:getUInt32(8))
end

--@api-stub: LDataView:type
do
    local view = lurek.data.newDataView("abc")
    print("type = " .. view:type())
end

--@api-stub: LDataView:typeOf
do
    local view = lurek.data.newDataView("abc")
    print("is LDataView = " .. tostring(view:typeOf("LDataView")))
end

--@api-stub: LDataWriter:writeU8
do
    local w = lurek.data.newWriter()
    w:writeU8(255)
    print("after writeU8 len = " .. w:len())
    print("first byte = " .. string.byte(w:toBytes(), 1))
end

--@api-stub: LDataWriter:writeI8
do
    local w = lurek.data.newWriter()
    w:writeI8(-128)
    print("after writeI8 len = " .. w:len())
end

--@api-stub: LDataWriter:writeU16LE
do
    local w = lurek.data.newWriter()
    w:writeU16LE(1000)
    print("after writeU16LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeU16BE
do
    local w = lurek.data.newWriter()
    w:writeU16BE(1000)
    print("after writeU16BE len = " .. w:len())
end

--@api-stub: LDataWriter:writeI16LE
do
    local w = lurek.data.newWriter()
    w:writeI16LE(-500)
    print("after writeI16LE len = " .. w:len())
end

--- Binary Module Part 2: DataWriter (continued), ByteData

--@api-stub: LDataWriter:writeU32LE
do
    local w = lurek.data.newWriter()
    w:writeU32LE(123456)
    print("after writeU32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeI32LE
do
    local w = lurek.data.newWriter()
    w:writeI32LE(-99999)
    print("after writeI32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeF32LE
do
    local w = lurek.data.newWriter()
    w:writeF32LE(3.14)
    print("after writeF32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeF64LE
do
    local w = lurek.data.newWriter()
    w:writeF64LE(2.718281828)
    print("after writeF64LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeString
do
    local w = lurek.data.newWriter()
    w:writeString("Hello!")
    print("after writeString len = " .. w:len())
end

--@api-stub: LDataWriter:writeBytes
do
    local w = lurek.data.newWriter()
    w:writeBytes("\x00\x01\x02\x03")
    print("after writeBytes len = " .. w:len())
end

--@api-stub: LDataWriter:seek
do
    local w = lurek.data.newWriter()
    w:writeU32LE(0)
    w:seek(0)
    w:writeU32LE(42)
    print("seek then overwrite, len = " .. w:len())
    print("cursor = " .. w:tell())
end

--@api-stub: LDataWriter:tell
do
    local w = lurek.data.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    print("cursor at = " .. w:tell())
end

--@api-stub: LDataWriter:len
do
    local w = lurek.data.newWriter()
    w:writeU16LE(100)
    w:writeU16LE(200)
    print("writer len = " .. w:len())
end

--@api-stub: LDataWriter:toBytes
do
    local w = lurek.data.newWriter()
    w:writeU8(65)
    w:writeU8(66)
    local bytes = w:toBytes()
    print("bytes len = " .. #bytes)
    print("bytes text = " .. bytes)
end

--@api-stub: LDataWriter:type
do
    local w = lurek.data.newWriter()
    print("type = " .. w:type())
end

--@api-stub: LDataWriter:typeOf
do
    local w = lurek.data.newWriter()
    print("is LDataWriter = " .. tostring(w:typeOf("LDataWriter")))
end

--@api-stub: LByteData:getSize
do
    local bd = lurek.data.newByteData(32)
    print("size = " .. bd:getSize())
end

--@api-stub: LByteData:getString
do
    local bd = lurek.data.newByteData("Hello")
    print("str = " .. bd:getString())
    print("size = " .. bd:getSize())
end

--@api-stub: LByteData:getByte
do
    local bd = lurek.data.newByteData("ABC")
    print("byte[0] = " .. bd:getByte(0))
end

--@api-stub: LByteData:setByte
do
    local bd = lurek.data.newByteData(4)
    bd:setByte(0, 255)
    print("byte[0] = " .. bd:getByte(0))
end

--@api-stub: LByteData:clone
do
    local bd = lurek.data.newByteData("test")
    local copy = bd:clone()
    copy:setByte(0, 88)
    print("original[0] = " .. bd:getByte(0) .. " copy[0] = " .. copy:getByte(0))
end

--@api-stub: LByteData:setBit
do
    local bd = lurek.data.newByteData(1)
    bd:setBit(0, 0, true)
    bd:setBit(0, 7, true)
    print("byte = " .. bd:getByte(0))
    print("bit 7 = " .. tostring(bd:getBit(0, 7)))
end

--@api-stub: LByteData:getBit
do
    local bd = lurek.data.newByteData(1)
    bd:setByte(0, 0x80)
    print("bit7 = " .. tostring(bd:getBit(0, 7)))
    print("bit0 = " .. tostring(bd:getBit(0, 0)))
end

--@api-stub: LByteData:readBits
do
    local bd = lurek.data.newByteData(2)
    bd:setByte(0, 0xFF)
    bd:setByte(1, 0x0F)
    local val = bd:readBits(0, 0, 12)
    print("12 bits = " .. val)
end

--@api-stub: LByteData:type
do
    local bd = lurek.data.newByteData(1)
    print("type = " .. bd:type())
end

--@api-stub: LByteData:typeOf
do
    local bd = lurek.data.newByteData(1)
    print("is LByteData = " .. tostring(bd:typeOf("LByteData")))
end

-- --- lurek.data aliases (defined in binary_api.rs) ------------------------
