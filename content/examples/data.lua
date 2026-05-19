-- content/examples/data.lua
-- Auto-generated from content/examples2/data_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/data.lua

--- Data Module Part 1: Pack/Unpack, Compression, Encoding, Hashing, TOML, MsgPack, RingBuffer, DataView, Writer


--@api-stub: lurek.data.pack
-- Packs Lua values into a binary string using a format string.
do
    local packed = lurek.data.pack("BHI", 255, 1000, 123456)
    print("packed len = " .. #packed)
end

--@api-stub: lurek.data.unpack
-- Unpacks values from a binary string.
do
    local packed = lurek.data.pack("BHI", 255, 1000, 123456)
    local b, h, i = lurek.data.unpack("BHI", packed)
    print("unpacked: " .. b .. ", " .. h .. ", " .. i)
end

--@api-stub: lurek.data.getPackedSize
-- Computes the byte size for a format string.
do
    local sz = lurek.data.getPackedSize("BHI", 0, 0, 0)
    print("packed size = " .. sz)
end

--@api-stub: lurek.data.compress
-- Compresses a binary string with a named format.
do
    local raw = string.rep("hello", 100)
    local compressed = lurek.data.compress("deflate", raw)
    print("compressed len = " .. #compressed)
end

--@api-stub: lurek.data.decompress
-- Decompresses a binary string.
do
    local raw = string.rep("world", 100)
    local compressed = lurek.data.compress("deflate", raw)
    local restored = lurek.data.decompress("deflate", compressed)
    print("restored len = " .. #restored)
end

--@api-stub: lurek.data.compressChunks
-- Compresses a table of strings as a chunked stream.
do
    local chunks = {"chunk1", "chunk2", "chunk3"}
    local compressed = lurek.data.compressChunks("deflate", chunks)
    print("chunks compressed len = " .. #compressed)
end

--@api-stub: lurek.data.decompressChunks
-- Decompresses a chunked byte stream.
do
    local chunks = {"aaaa", "bbbb", "cccc"}
    local compressed = lurek.data.compressChunks("deflate", chunks)
    local restored = lurek.data.decompressChunks("deflate", compressed)
    print("decompressed chunks len = " .. #restored)
end

--@api-stub: lurek.data.encode
-- Encodes raw data using a named text encoding format.
do
    local encoded = lurek.data.encode("base64", "Hello, World!")
    print("base64 = " .. encoded)
end

--@api-stub: lurek.data.decode
-- Decodes an encoded string back to raw bytes.
do
    local encoded = lurek.data.encode("base64", "Hello")
    local decoded = lurek.data.decode("base64", encoded)
    print("decoded = " .. decoded)
end

--@api-stub: lurek.data.hash
-- Hashes data with a named algorithm.
do
    local digest = lurek.data.hash("sha256", "secret data")
    print("sha256 = " .. digest)
end

--@api-stub: lurek.data.crc32
-- Computes CRC32 checksum for binary data.
do
    local crc = lurek.data.crc32("test data")
    print("crc32 = " .. crc)
end

--@api-stub: lurek.data.newByteData
-- Creates ByteData from a size or string.
do
    local bd = lurek.data.newByteData(16)
    print("bytedata size = " .. bd:getSize())
end

--@api-stub: lurek.data.newDataView
-- Creates a DataView over a binary string slice.
do
    local raw = lurek.data.pack("<II", 42, 99)
    local view = lurek.data.newDataView(raw)
    print("view size = " .. view:getSize())
end

--@api-stub: lurek.data.write
-- Writes binary values into a byte string using a format string.
do
    local bytes = lurek.data.write("u32", 42)
    print("write len = " .. #bytes)
end

--@api-stub: lurek.data.read
-- Reads binary values from a byte string using a format string.
do
    local bytes = lurek.data.write("u32", 42)
    local val = lurek.data.read("u32", bytes)
    print("read val = " .. val)
end

--@api-stub: lurek.data.size
-- Measures fixed byte size for a format string.
do
    local sz = lurek.data.size("u32")
    print("format size = " .. sz)
end

--@api-stub: lurek.data.parseToml
-- Parses TOML text into Lua tables.
do
    local toml_text = "[player]\nname = \"Hero\"\nlevel = 5"
    local t = lurek.data.parseToml(toml_text)
    print("player name = " .. t.player.name)
end

--@api-stub: lurek.data.encodeToml
-- Encodes a Lua table into TOML text.
do
    local t = {title = "My Game", version = "1.0"}
    local text = lurek.data.encodeToml(t)
    print("toml len = " .. #text)
end

--@api-stub: lurek.data.newRingBuffer
-- Creates a fixed-capacity ring buffer.
do
    local rb = lurek.data.newRingBuffer(8)
    print("ring capacity = " .. rb:capacity())
end

--@api-stub: lurek.data.toMsgPack
-- Encodes a Lua value into binary MsgPack.
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.data.toMsgPack(payload)
    print("msgpack len = " .. #bytes)
end

--@api-stub: lurek.data.fromMsgPack
-- Decodes binary MsgPack back into Lua values.
do
    local payload = {score = 100, name = "test"}
    local bytes = lurek.data.toMsgPack(payload)
    local decoded = lurek.data.fromMsgPack(bytes) --[[@as table]]
    print("decoded score = " .. decoded.score)
end

--@api-stub: lurek.data.newWriter
-- Creates an empty binary data writer.
do
    local w = lurek.data.newWriter()
    print("writer created = " .. tostring(w ~= nil))
end

--@api-stub: LRingBuffer:push
-- Pushes a value; returns true when an older value was evicted.
do
    local rb = lurek.data.newRingBuffer(3)
    rb:push("a")
    rb:push("b")
    local evicted = rb:push("d")
    print("evicted = " .. tostring(evicted))
end

--@api-stub: LRingBuffer:pop
-- Removes and returns the oldest stored value.
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local oldest = rb:pop()
    print("popped = " .. oldest)
end

--@api-stub: LRingBuffer:peek
-- Returns the oldest value without removing it.
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push("first")
    rb:push("second")
    print("peek = " .. rb:peek())
end

--@api-stub: LRingBuffer:peekNewest
-- Returns the newest value without removing it.
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push("old")
    rb:push("new")
    print("newest = " .. rb:peekNewest())
end

--@api-stub: LRingBuffer:len
-- Returns the number of stored values.
do
    local rb = lurek.data.newRingBuffer(10)
    rb:push(1)
    rb:push(2)
    print("len = " .. rb:len())
end

--@api-stub: LRingBuffer:capacity
-- Returns the maximum capacity.
do
    local rb = lurek.data.newRingBuffer(5)
    print("capacity = " .. rb:capacity())
end

--@api-stub: LRingBuffer:isEmpty
-- Returns true when the buffer is empty.
do
    local rb = lurek.data.newRingBuffer(4)
    print("empty = " .. tostring(rb:isEmpty()))
end

--@api-stub: LRingBuffer:isFull
-- Returns true when the buffer is at capacity.
do
    local rb = lurek.data.newRingBuffer(2)
    rb:push("a")
    rb:push("b")
    print("full = " .. tostring(rb:isFull()))
end

--@api-stub: LRingBuffer:clear
-- Removes all stored values.
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(1)
    rb:push(2)
    rb:clear()
    print("after clear len = " .. rb:len())
end

--@api-stub: LRingBuffer:toTable
-- Returns stored values in oldest-to-newest order.
do
    local rb = lurek.data.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local t = rb:toTable()
    print("table len = " .. #t)
end

--@api-stub: LRingBuffer:type
-- Returns the type name ("LRingBuffer").
do
    local rb = lurek.data.newRingBuffer(4)
    print("type = " .. rb:type())
end

--@api-stub: LRingBuffer:typeOf
-- Returns whether this handle matches a type name.
do
    local rb = lurek.data.newRingBuffer(4)
    print("is LRingBuffer = " .. tostring(rb:typeOf("LRingBuffer")))
end

--@api-stub: LDataView:getUInt8
-- Reads an unsigned 8-bit integer at a byte offset.
do
    local raw = lurek.data.pack("BBBB", 10, 20, 30, 40)
    local view = lurek.data.newDataView(raw)
    print("u8[0] = " .. view:getUInt8(0))
end

--@api-stub: LDataView:getInt8
-- Reads a signed 8-bit integer at a byte offset.
do
    local raw = lurek.data.pack("b", -42)
    local view = lurek.data.newDataView(raw)
    print("i8[0] = " .. view:getInt8(0))
end

--@api-stub: LDataView:getInt16
-- Reads a signed 16-bit integer at a byte offset.
do
    local raw = lurek.data.pack("h", -1000)
    local view = lurek.data.newDataView(raw)
    print("i16[0] = " .. view:getInt16(0))
end

--@api-stub: LDataView:getUInt16
-- Reads an unsigned 16-bit integer at a byte offset.
do
    local raw = lurek.data.pack("H", 65000)
    local view = lurek.data.newDataView(raw)
    print("u16[0] = " .. view:getUInt16(0))
end

--@api-stub: LDataView:getInt32
-- Reads a signed 32-bit integer at a byte offset.
do
    local raw = lurek.data.pack("<i", -100000)
    local view = lurek.data.newDataView(raw)
    print("i32[0] = " .. view:getInt32(0))
end

--@api-stub: LDataView:getUInt32
-- Reads an unsigned 32-bit integer at a byte offset.
do
    local raw = lurek.data.pack("<I", 3000000)
    local view = lurek.data.newDataView(raw)
    print("u32[0] = " .. view:getUInt32(0))
end

--@api-stub: LDataView:getFloat
-- Reads a 32-bit float at a byte offset.
do
    local raw = lurek.data.pack("f", 3.14)
    local view = lurek.data.newDataView(raw)
    print("f32[0] = " .. view:getFloat(0))
end

--@api-stub: LDataView:getDouble
-- Reads a 64-bit float at a byte offset.
do
    local raw = lurek.data.pack("d", 2.718281828)
    local view = lurek.data.newDataView(raw)
    print("f64[0] = " .. view:getDouble(0))
end

--@api-stub: LDataView:getSize
-- Returns the data view size in bytes.
do
    local raw = lurek.data.pack("<III", 1, 2, 3)
    local view = lurek.data.newDataView(raw)
    print("view size = " .. view:getSize())
end

--@api-stub: LDataView:type
-- Returns the type name ("LDataView").
do
    local view = lurek.data.newDataView("abc")
    print("type = " .. view:type())
end

--@api-stub: LDataView:typeOf
-- Returns whether this handle matches a type name.
do
    local view = lurek.data.newDataView("abc")
    print("is LDataView = " .. tostring(view:typeOf("LDataView")))
end

--@api-stub: LDataWriter:writeU8
-- Appends an unsigned 8-bit integer.
do
    local w = lurek.data.newWriter()
    w:writeU8(255)
    print("after writeU8 len = " .. w:len())
end

--@api-stub: LDataWriter:writeI8
-- Appends a signed 8-bit integer.
do
    local w = lurek.data.newWriter()
    w:writeI8(-128)
    print("after writeI8 len = " .. w:len())
end

--@api-stub: LDataWriter:writeU16LE
-- Appends an unsigned 16-bit integer in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeU16LE(1000)
    print("after writeU16LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeU16BE
-- Appends an unsigned 16-bit integer in big-endian.
do
    local w = lurek.data.newWriter()
    w:writeU16BE(1000)
    print("after writeU16BE len = " .. w:len())
end

--@api-stub: LDataWriter:writeI16LE
-- Appends a signed 16-bit integer in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeI16LE(-500)
    print("after writeI16LE len = " .. w:len())
end

--- Data Module Part 2: DataWriter (continued), ByteData


--@api-stub: LDataWriter:writeU32LE
-- Appends an unsigned 32-bit integer in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeU32LE(123456)
    print("after writeU32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeI32LE
-- Appends a signed 32-bit integer in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeI32LE(-99999)
    print("after writeI32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeF32LE
-- Appends a 32-bit float in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeF32LE(3.14)
    print("after writeF32LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeF64LE
-- Appends a 64-bit float in little-endian.
do
    local w = lurek.data.newWriter()
    w:writeF64LE(2.718281828)
    print("after writeF64LE len = " .. w:len())
end

--@api-stub: LDataWriter:writeString
-- Appends a UTF-8 string to the buffer.
do
    local w = lurek.data.newWriter()
    w:writeString("Hello!")
    print("after writeString len = " .. w:len())
end

--@api-stub: LDataWriter:writeBytes
-- Appends raw bytes from a Lua string.
do
    local w = lurek.data.newWriter()
    w:writeBytes("\x00\x01\x02\x03")
    print("after writeBytes len = " .. w:len())
end

--@api-stub: LDataWriter:seek
-- Moves the writer cursor to a specific position.
do
    local w = lurek.data.newWriter()
    w:writeU32LE(0)
    w:writeU32LE(0)
    w:seek(0)
    w:writeU32LE(42)
    print("seek then overwrite, len = " .. w:len())
end

--@api-stub: LDataWriter:tell
-- Returns the current writer cursor position.
do
    local w = lurek.data.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    print("cursor at = " .. w:tell())
end

--@api-stub: LDataWriter:len
-- Returns the buffer length in bytes.
do
    local w = lurek.data.newWriter()
    w:writeU16LE(100)
    w:writeU16LE(200)
    print("writer len = " .. w:len())
end

--@api-stub: LDataWriter:toBytes
-- Returns the buffer as a binary string.
do
    local w = lurek.data.newWriter()
    w:writeU8(65)
    w:writeU8(66)
    local bytes = w:toBytes()
    print("bytes len = " .. #bytes)
end

--@api-stub: LDataWriter:type
-- Returns the type name ("LDataWriter").
do
    local w = lurek.data.newWriter()
    print("type = " .. w:type())
end

--@api-stub: LDataWriter:typeOf
-- Returns whether this handle matches a type name.
do
    local w = lurek.data.newWriter()
    print("is LDataWriter = " .. tostring(w:typeOf("LDataWriter")))
end

--@api-stub: LByteData:getSize
-- Returns the buffer length in bytes.
do
    local bd = lurek.data.newByteData(32)
    print("size = " .. bd:getSize())
end

--@api-stub: LByteData:getString
-- Returns the buffer as a Lua string.
do
    local bd = lurek.data.newByteData("Hello")
    print("str = " .. bd:getString())
end

--@api-stub: LByteData:getByte
-- Reads one byte at a zero-based offset.
do
    local bd = lurek.data.newByteData("ABC")
    print("byte[0] = " .. bd:getByte(0))
end

--@api-stub: LByteData:setByte
-- Writes one byte at a zero-based offset.
do
    local bd = lurek.data.newByteData(4)
    bd:setByte(0, 255)
    print("byte[0] = " .. bd:getByte(0))
end

--@api-stub: LByteData:clone
-- Returns a deep copy of the byte buffer.
do
    local bd = lurek.data.newByteData("test")
    local copy = bd:clone()
    copy:setByte(0, 88)
    print("original[0] = " .. bd:getByte(0) .. " copy[0] = " .. copy:getByte(0))
end

--@api-stub: LByteData:setBit
-- Sets or clears one bit inside a byte.
do
    local bd = lurek.data.newByteData(1)
    bd:setBit(0, 0, true)
    bd:setBit(0, 7, true)
    print("byte = " .. bd:getByte(0))
end

--@api-stub: LByteData:getBit
-- Reads one bit inside a byte.
do
    local bd = lurek.data.newByteData(1)
    bd:setByte(0, 0x80)
    print("bit7 = " .. tostring(bd:getBit(0, 7)))
end

--@api-stub: LByteData:readBits
-- Reads up to 32 bits starting at a byte and bit offset.
do
    local bd = lurek.data.newByteData(2)
    bd:setByte(0, 0xFF)
    bd:setByte(1, 0x0F)
    local val = bd:readBits(0, 0, 12)
    print("12 bits = " .. val)
end

--@api-stub: LByteData:type
-- Returns the type name ("LByteData").
do
    local bd = lurek.data.newByteData(1)
    print("type = " .. bd:type())
end

--@api-stub: LByteData:typeOf
-- Returns whether this handle matches a type name.
do
    local bd = lurek.data.newByteData(1)
    print("is LByteData = " .. tostring(bd:typeOf("LByteData")))
end

print("content/examples/data.lua")
