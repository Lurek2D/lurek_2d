-- content/examples/data.lua
-- lurek.data API examples.
-- Run: cargo run -- content/examples/data.lua

--@api-stub: lurek.data.pack
-- Pack typed Lua values into a binary string for saves, packets, or compact cache keys.
do
    -- Use an explicit byte order in the format so data stays portable across machines.
    local payload = lurek.data.pack("<Iff", 7, 12.5, -3.25)
    local id, x, y = lurek.data.unpack("<Iff", payload)
    local round_trip_ok = (id == 7 and x > 12.4 and y < -3.2)
    print("data.pack", #payload, round_trip_ok)
end

--@api-stub: lurek.data.unpack
-- Unpack a binary record and continue reading from the returned offset.
do
    local raw = lurek.data.pack("<HH", 320, 180) .. lurek.data.pack("<H", 42)
    local width, height, next_offset = lurek.data.unpack("<HH", raw)
    local tile_id = lurek.data.unpack("<H", raw, next_offset)
    print("data.unpack", width, height, tile_id)
end

--@api-stub: lurek.data.getPackedSize
-- Ask how many bytes a packed record will use before writing it to a fixed buffer.
do
    local byte_count = lurek.data.getPackedSize("<Iff", 1, 2.0, 3.0)
    local payload = lurek.data.pack("<Iff", 1, 2.0, 3.0)
    print("data.getPackedSize", byte_count, byte_count == #payload)
end

--@api-stub: lurek.data.compress
-- Compress a string payload before storing it in a save file or sending it over a local pipe.
do
    local source = string.rep("region:forest;weather:rain;", 8)
    local compressed = lurek.data.compress("zlib", source, 6)
    local restored = lurek.data.decompress("zlib", compressed)
    print("data.compress", #source, #compressed, restored == source)
end

--@api-stub: lurek.data.decompress
-- Decompress bytes with the same format that was used during compression.
do
    local source = "checkpoint=bridge;score=1250;inventory=key"
    local compressed = lurek.data.compress("gzip", source)
    local restored = lurek.data.decompress("gzip", compressed)
    print("data.decompress", restored)
end

--@api-stub: lurek.data.compressChunks
-- Compress multiple string chunks without manually joining the source data first.
do
    local chunks = { "chunk-a:", string.rep("grass,", 6), "chunk-b:", string.rep("stone,", 6) }
    local compressed = lurek.data.compressChunks("zlib", chunks, 5)
    local restored = lurek.data.decompress("zlib", compressed)
    print("data.compressChunks", #compressed, restored:find("stone") ~= nil)
end

--@api-stub: lurek.data.decompressChunks
-- Decode several compressed chunks and receive the restored strings as a table.
do
    local first = lurek.data.compress("zlib", "north-sector")
    local second = lurek.data.compress("zlib", "south-sector")
    local restored = lurek.data.decompressChunks("zlib", { first, second })
    print("data.decompressChunks", restored[1], restored[2])
end

--@api-stub: lurek.data.encode
-- Encode raw bytes into a text-safe representation for logs, TOML fields, or debug output.
do
    local raw = lurek.data.pack("<HH", 64, 128)
    local encoded = lurek.data.encode("base64", raw)
    local decoded = lurek.data.decode("base64", encoded)
    print("data.encode", encoded, decoded == raw)
end

--@api-stub: lurek.data.decode
-- Decode a text representation back into the original bytes before reading it.
do
    local encoded = lurek.data.encode("hex", "L2D")
    local decoded = lurek.data.decode("hex", encoded)
    print("data.decode", encoded, decoded)
end

--@api-stub: lurek.data.hash
-- Hash a stable payload to compare cached data or detect content changes.
do
    local snapshot = "player=7;x=12;y=9;map=harbor"
    local digest = lurek.data.hash("sha256", snapshot)
    print("data.hash", #digest, digest:sub(1, 12))
end

--@api-stub: lurek.data.crc32
-- Use CRC32 for a small integrity check on binary records.
do
    local raw = lurek.data.pack("<IHH", 19, 4, 8)
    local checksum = lurek.data.crc32(raw)
    print("data.crc32", checksum)
end

--@api-stub: lurek.data.newByteData
-- Wrap a Lua string in LByteData when a later step needs byte-level reads or edits.
do
    local bytes = lurek.data.newByteData("ABCD")
    local first = bytes:getByte(0)
    bytes:setByte(3, 90)
    print("data.newByteData", bytes:getSize(), first, bytes:getString())
end

--@api-stub: lurek.data.newDataView
-- Create a typed view over raw bytes without copying the whole payload.
do
    local raw = lurek.data.pack("<HHI", 16, 32, 255)
    local view = lurek.data.newDataView(raw)
    local width = view:getUInt16(0)
    local height = view:getUInt16(2)
    print("data.newDataView", width, height, view:getSize())
end

--@api-stub: lurek.data.write
-- Write a structured record with the higher-level format tokens used by lurek.data.read.
do
    local raw = lurek.data.write("u16 u16 bool", 320, 180, true)
    local width, height, enabled = lurek.data.read("u16 u16 bool", raw)
    print("data.write", #raw, width, height, enabled)
end

--@api-stub: lurek.data.read
-- Read structured values and use the returned offset to process the next record.
do
    local raw = lurek.data.write("u8 str", 3, "key") .. lurek.data.write("u8", 9)
    local kind, label, next_offset = lurek.data.read("u8 str", raw)
    local priority = lurek.data.read("u8", raw, next_offset)
    print("data.read", kind, label, priority)
end

--@api-stub: lurek.data.size
-- Calculate the static byte size of a fixed-format record before allocating space for it.
do
    local fixed_size = lurek.data.size("u16 u16 bool")
    local raw = lurek.data.write("u16 u16 bool", 800, 600, true)
    print("data.size", fixed_size, #raw)
end

--@api-stub: lurek.data.parseToml
-- Parse a TOML document into a Lua table for human-authored configuration.
do
    local config = lurek.data.parseToml('title = "Arena"\n[window]\nwidth = 960\nheight = 540\n')
    print("data.parseToml", config.title, config.window.width, config.window.height)
end

--@api-stub: lurek.data.encodeToml
-- Encode a Lua table into TOML when saving readable settings or tool output.
do
    local text = lurek.data.encodeToml({ title = "Arena", window = { width = 960, height = 540 } })
    print("data.encodeToml", text:find("title") ~= nil, text:find("window") ~= nil)
end

--@api-stub: lurek.data.newRingBuffer
-- Keep the last N values without growing memory forever.
do
    local buffer = lurek.data.newRingBuffer(3)
    buffer:push("idle")
    buffer:push("walk")
    buffer:push("jump")
    buffer:push("land")
    print("data.newRingBuffer", buffer:len(), buffer:peek(), buffer:peekNewest())
end

--@api-stub: lurek.data.toMsgPack
-- Serialize a Lua table into MessagePack bytes for compact structured storage.
do
    local bytes = lurek.data.toMsgPack({ name = "save-1", hp = 42, flags = { "key", "map" } })
    local restored = lurek.data.fromMsgPack(bytes)
    print("data.toMsgPack", #bytes, type(restored))
end

--@api-stub: lurek.data.fromMsgPack
-- Restore MessagePack bytes into Lua values.
do
    local bytes = lurek.data.toMsgPack({ zone = "dock", difficulty = 2 })
    local restored = lurek.data.fromMsgPack(bytes)
    print("data.fromMsgPack", type(restored), bytes ~= "")
end

--@api-stub: lurek.data.newWriter
-- Build binary data incrementally when a record is easier to write field by field.
do
    local writer = lurek.data.newWriter()
    writer:writeU8(1)
    writer:writeU16LE(320)
    writer:writeU16LE(180)
    local raw = writer:toBytes()
    print("data.newWriter", writer:len(), #raw, writer:tell())
end

--@api-stub: LRingBuffer:push
-- Add a value to the ring buffer; when full, the oldest value is discarded.
do
    local buffer = lurek.data.newRingBuffer(2)
    buffer:push("first")
    buffer:push("second")
    buffer:push("third")
    print("LRingBuffer:push", buffer:toTable()[1], buffer:toTable()[2])
end

--@api-stub: LRingBuffer:pop
-- Remove and return the oldest buffered value.
do
    local buffer = lurek.data.newRingBuffer(2)
    buffer:push("queued")
    buffer:push("ready")
    local first = buffer:pop()
    print("LRingBuffer:pop", first, buffer:len())
end

--@api-stub: LRingBuffer:peek
-- Inspect the oldest buffered value without removing it.
do
    local buffer = lurek.data.newRingBuffer(3)
    buffer:push("north")
    buffer:push("east")
    print("LRingBuffer:peek", buffer:peek(), buffer:len())
end

--@api-stub: LRingBuffer:peekNewest
-- Inspect the newest buffered value without removing it.
do
    local buffer = lurek.data.newRingBuffer(3)
    buffer:push("north")
    buffer:push("east")
    print("LRingBuffer:peekNewest", buffer:peekNewest(), buffer:len())
end

--@api-stub: LRingBuffer:len
-- Count how many values are currently stored.
do
    local buffer = lurek.data.newRingBuffer(4)
    buffer:push("a")
    buffer:push("b")
    print("LRingBuffer:len", buffer:len())
end

--@api-stub: LRingBuffer:capacity
-- Read the fixed capacity that was chosen when the buffer was created.
do
    local buffer = lurek.data.newRingBuffer(4)
    print("LRingBuffer:capacity", buffer:capacity())
end

--@api-stub: LRingBuffer:isEmpty
-- Check whether the ring has no stored values.
do
    local buffer = lurek.data.newRingBuffer(2)
    local before = buffer:isEmpty()
    buffer:push("event")
    print("LRingBuffer:isEmpty", before, buffer:isEmpty())
end

--@api-stub: LRingBuffer:isFull
-- Check whether the next push will overwrite the oldest value.
do
    local buffer = lurek.data.newRingBuffer(2)
    buffer:push("a")
    local before = buffer:isFull()
    buffer:push("b")
    print("LRingBuffer:isFull", before, buffer:isFull())
end

--@api-stub: LRingBuffer:clear
-- Remove every stored value while keeping the same capacity.
do
    local buffer = lurek.data.newRingBuffer(3)
    buffer:push("a")
    buffer:push("b")
    buffer:clear()
    print("LRingBuffer:clear", buffer:len(), buffer:isEmpty())
end

--@api-stub: LRingBuffer:toTable
-- Copy buffered values into a Lua table ordered from oldest to newest.
do
    local buffer = lurek.data.newRingBuffer(3)
    buffer:push("idle")
    buffer:push("walk")
    buffer:push("jump")
    local values = buffer:toTable()
    print("LRingBuffer:toTable", values[1], values[2], values[3])
end

--@api-stub: LRingBuffer:type
-- Return the userdata type name for runtime checks or diagnostics.
do
    local buffer = lurek.data.newRingBuffer(1)
    print("LRingBuffer:type", buffer:type())
end

--@api-stub: LRingBuffer:typeOf
-- Test the userdata type without relying on Lua metatable details.
do
    local buffer = lurek.data.newRingBuffer(1)
    print("LRingBuffer:typeOf", buffer:typeOf("LRingBuffer"), buffer:typeOf("LByteData"))
end

--@api-stub: LDataView:getUInt8
-- Read an unsigned 8-bit value from a byte offset.
do
    local view = lurek.data.newDataView(string.char(255, 1, 2, 3))
    print("LDataView:getUInt8", view:getUInt8(0))
end

--@api-stub: LDataView:getInt8
-- Read a signed 8-bit value from a byte offset.
do
    local view = lurek.data.newDataView(string.char(255, 1, 2, 3))
    print("LDataView:getInt8", view:getInt8(0))
end

--@api-stub: LDataView:getInt16
-- Read a signed 16-bit little-endian value from a byte offset.
do
    local raw = lurek.data.pack("<h", -120)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getInt16", view:getInt16(0))
end

--@api-stub: LDataView:getUInt16
-- Read an unsigned 16-bit little-endian value from a byte offset.
do
    local raw = lurek.data.pack("<H", 65000)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getUInt16", view:getUInt16(0))
end

--@api-stub: LDataView:getInt32
-- Read a signed 32-bit little-endian value from a byte offset.
do
    local raw = lurek.data.pack("<i", -4096)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getInt32", view:getInt32(0))
end

--@api-stub: LDataView:getUInt32
-- Read an unsigned 32-bit little-endian value from a byte offset.
do
    local raw = lurek.data.pack("<I", 4096)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getUInt32", view:getUInt32(0))
end

--@api-stub: LDataView:getFloat
-- Read a 32-bit float from a byte offset.
do
    local raw = lurek.data.pack("<f", 3.5)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getFloat", view:getFloat(0))
end

--@api-stub: LDataView:getDouble
-- Read a 64-bit float from a byte offset.
do
    local raw = lurek.data.pack("<d", 9.25)
    local view = lurek.data.newDataView(raw)
    print("LDataView:getDouble", view:getDouble(0))
end

--@api-stub: LDataView:getSize
-- Return the visible byte length of the view.
do
    local view = lurek.data.newDataView("abcdef", 2, 3)
    print("LDataView:getSize", view:getSize())
end

--@api-stub: LDataView:type
-- Return the userdata type name for diagnostics.
do
    local view = lurek.data.newDataView("abc")
    print("LDataView:type", view:type())
end

--@api-stub: LDataView:typeOf
-- Check whether the userdata is an LDataView.
do
    local view = lurek.data.newDataView("abc")
    print("LDataView:typeOf", view:typeOf("LDataView"), view:typeOf("LDataWriter"))
end

--@api-stub: LDataWriter:writeU8
-- Append an unsigned 8-bit integer to the writer.
do
    local writer = lurek.data.newWriter()
    writer:writeU8(255)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeU8", view:getUInt8(0))
end

--@api-stub: LDataWriter:writeI8
-- Append a signed 8-bit integer to the writer.
do
    local writer = lurek.data.newWriter()
    writer:writeI8(-5)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeI8", view:getInt8(0))
end

--@api-stub: LDataWriter:writeU16LE
-- Append an unsigned 16-bit integer in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeU16LE(513)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeU16LE", view:getUInt16(0))
end

--@api-stub: LDataWriter:writeU16BE
-- Append an unsigned 16-bit integer in big-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeU16BE(513)
    local raw = writer:toBytes()
    print("LDataWriter:writeU16BE", raw:byte(1), raw:byte(2))
end

--@api-stub: LDataWriter:writeI16LE
-- Append a signed 16-bit integer in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeI16LE(-1024)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeI16LE", view:getInt16(0))
end

--@api-stub: LDataWriter:writeU32LE
-- Append an unsigned 32-bit integer in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeU32LE(65536)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeU32LE", view:getUInt32(0))
end

--@api-stub: LDataWriter:writeI32LE
-- Append a signed 32-bit integer in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeI32LE(-65536)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeI32LE", view:getInt32(0))
end

--@api-stub: LDataWriter:writeF32LE
-- Append a 32-bit float in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeF32LE(1.5)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeF32LE", view:getFloat(0))
end

--@api-stub: LDataWriter:writeF64LE
-- Append a 64-bit float in little-endian order.
do
    local writer = lurek.data.newWriter()
    writer:writeF64LE(2.75)
    local view = lurek.data.newDataView(writer:toBytes())
    print("LDataWriter:writeF64LE", view:getDouble(0))
end

--@api-stub: LDataWriter:writeString
-- Append a length-prefixed string so it can be read back with the matching format token.
do
    local writer = lurek.data.newWriter()
    writer:writeString("door")
    local value = lurek.data.read("str", writer:toBytes())
    print("LDataWriter:writeString", value)
end

--@api-stub: LDataWriter:writeBytes
-- Append raw bytes when the receiver already knows their length.
do
    local writer = lurek.data.newWriter()
    writer:writeBytes("RGB")
    print("LDataWriter:writeBytes", writer:len(), writer:toBytes())
end

--@api-stub: LDataWriter:seek
-- Move the cursor to overwrite a value that was reserved earlier.
do
    local writer = lurek.data.newWriter()
    writer:writeU16LE(0)
    writer:writeBytes("payload")
    writer:seek(0)
    writer:writeU16LE(writer:len())
    print("LDataWriter:seek", writer:tell(), writer:len())
end

--@api-stub: LDataWriter:tell
-- Read the current write cursor position.
do
    local writer = lurek.data.newWriter()
    writer:writeU8(1)
    writer:writeU16LE(2)
    print("LDataWriter:tell", writer:tell())
end

--@api-stub: LDataWriter:len
-- Read the total number of bytes currently stored in the writer.
do
    local writer = lurek.data.newWriter()
    writer:writeBytes("abc")
    print("LDataWriter:len", writer:len())
end

--@api-stub: LDataWriter:toBytes
-- Copy the writer buffer into a Lua string.
do
    local writer = lurek.data.newWriter()
    writer:writeU8(65)
    writer:writeU8(66)
    local raw = writer:toBytes()
    print("LDataWriter:toBytes", raw, #raw)
end

--@api-stub: LDataWriter:type
-- Return the userdata type name for diagnostics.
do
    local writer = lurek.data.newWriter()
    print("LDataWriter:type", writer:type())
end

--@api-stub: LDataWriter:typeOf
-- Check whether the userdata is an LDataWriter.
do
    local writer = lurek.data.newWriter()
    print("LDataWriter:typeOf", writer:typeOf("LDataWriter"), writer:typeOf("LDataView"))
end

--@api-stub: LByteData:getSize
-- Return the number of bytes stored in LByteData.
do
    local bytes = lurek.data.newByteData("ABCD")
    print("LByteData:getSize", bytes:getSize())
end

--@api-stub: LByteData:getString
-- Copy the byte buffer into a Lua string.
do
    local bytes = lurek.data.newByteData("ABCD")
    print("LByteData:getString", bytes:getString())
end

--@api-stub: LByteData:getByte
-- Read one byte by zero-based offset.
do
    local bytes = lurek.data.newByteData("ABCD")
    print("LByteData:getByte", bytes:getByte(1))
end

--@api-stub: LByteData:setByte
-- Replace one byte by zero-based offset.
do
    local bytes = lurek.data.newByteData("ABCD")
    bytes:setByte(1, string.byte("Z"))
    print("LByteData:setByte", bytes:getString())
end

--@api-stub: LByteData:clone
-- Clone byte data before mutating it so the original remains unchanged.
do
    local original = lurek.data.newByteData("ABCD")
    local copy = original:clone()
    copy:setByte(0, string.byte("Z"))
    print("LByteData:clone", original:getString(), copy:getString())
end

--@api-stub: LByteData:setBit
-- Set or clear a single bit inside a byte.
do
    local bytes = lurek.data.newByteData(string.char(0))
    bytes:setBit(0, 2, true)
    print("LByteData:setBit", bytes:getByte(0))
end

--@api-stub: LByteData:getBit
-- Read a single bit from a byte.
do
    local bytes = lurek.data.newByteData(string.char(4))
    print("LByteData:getBit", bytes:getBit(0, 2), bytes:getBit(0, 1))
end

--@api-stub: LByteData:readBits
-- Read a compact bit field that starts at a byte and bit offset.
do
    local bytes = lurek.data.newByteData(string.char(0x2d))
    local low_nibble = bytes:readBits(0, 0, 4)
    print("LByteData:readBits", low_nibble)
end

--@api-stub: LByteData:type
-- Return the userdata type name for diagnostics.
do
    local bytes = lurek.data.newByteData("AB")
    print("LByteData:type", bytes:type())
end

--@api-stub: LByteData:typeOf
-- Check whether the userdata is an LByteData.
do
    local bytes = lurek.data.newByteData("AB")
    print("LByteData:typeOf", bytes:typeOf("LByteData"), bytes:typeOf("LDataView"))
end

print("content/examples/data.lua")
