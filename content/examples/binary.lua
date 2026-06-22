-- content/examples/binary.lua
-- Auto-generated from content/examples2/data_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/binary.lua

--- Binary Module Part 1: Pack/Unpack, Compression, Encoding, Hashing, RingBuffer, DataView, Writer

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.binary.pack
do
    local actorId = 255
    local health = 1000
    local gold = 123456
    local packed = lurek.binary.pack("BHI", actorId, health, gold)
    local savedActorId, savedHealth, savedGold = lurek.binary.unpack("BHI", packed)
    lurek.log.info("save header bytes=" .. tostring(#packed))
    lurek.log.info("save header actor=" .. tostring(savedActorId) .. " hp=" .. tostring(savedHealth) .. " gold=" .. tostring(savedGold))
end

--@api: lurek.binary.unpack
do
    local packed = lurek.binary.pack("BHI", 255, 1000, 123456)
    local b, h, i = lurek.binary.unpack("BHI", packed)
    local checksum = b + h + i
    local headerSize = lurek.binary.getPackedSize("BHI", 255, 1000, 123456)
    lurek.log.info("enemy packet values=" .. tostring(b) .. "," .. tostring(h) .. "," .. tostring(i))
    lurek.log.info("enemy packet checksum=" .. tostring(checksum) .. " size=" .. tostring(headerSize))
end

--@api: lurek.binary.getPackedSize
do
    local sz = lurek.binary.getPackedSize("BHI", 0, 0, 0)
    local packed = lurek.binary.pack("BHI", 0, 0, 0)
    local itemPacket = lurek.binary.pack("BHI", 7, 25, 9000)
    local itemPacketSize = lurek.binary.getPackedSize("BHI", 7, 25, 9000)
    lurek.log.info("fixed packet size=" .. tostring(sz))
    lurek.log.info("item packet size matches=" .. tostring(itemPacketSize == #itemPacket))
end

--@api: lurek.binary.compress
do
    local raw = string.rep("hello", 100)
    local compressed = lurek.binary.compress("deflate", raw)
    local restored = lurek.binary.decompress("deflate", compressed)
    local savedBytes = #raw - #compressed
    lurek.log.info("dialogue raw bytes=" .. tostring(#raw))
    lurek.log.info("dialogue compressed bytes=" .. tostring(#compressed) .. " saved=" .. tostring(savedBytes) .. " restored=" .. tostring(restored == raw))
end

--@api: lurek.binary.decompress
do
    local raw = string.rep("world", 100)
    local compressed = lurek.binary.compress("deflate", raw)
    local restored = lurek.binary.decompress("deflate", compressed)
    example_print_log("restored len = " .. #restored)
    example_print_log("restored matches = " .. tostring(restored == raw))
end

--@api: lurek.binary.compressChunks
do
    local chunks = {"chunk1", "chunk2", "chunk3"}
    local compressed = lurek.binary.compressChunks("deflate", chunks)
    local restored = lurek.binary.decompressChunks("deflate", compressed)
    local merged = table.concat(chunks)
    local restoredLen = #restored
    lurek.log.info("replay chunk count=" .. tostring(#chunks))
    lurek.log.info("replay compressed bytes=" .. tostring(#compressed) .. " restored ok=" .. tostring(restored == merged) .. " restored len=" .. tostring(restoredLen))
end

--@api: lurek.binary.decompressChunks
do
    local chunks = {"aaaa", "bbbb", "cccc"}
    local compressed = lurek.binary.compressChunks("deflate", chunks)
    local restored = lurek.binary.decompressChunks("deflate", compressed)
    example_print_log("decompressed chunks len = " .. #restored)
    example_print_log("restored preview = " .. restored:sub(1, 8))
end

--@api: lurek.binary.encode
do
    local encoded = lurek.binary.encode("base64", "Hello, World!")
    local decoded = lurek.binary.decode("base64", encoded)
    local header = encoded:sub(1, 8)
    lurek.log.info("encoded quest note header=" .. tostring(header))
    lurek.log.info("quest note restored=" .. tostring(decoded))
end

--@api: lurek.binary.decode
do
    local encoded = lurek.binary.encode("base64", "Hello")
    local decoded = lurek.binary.decode("base64", encoded)
    local reencoded = lurek.binary.encode("base64", decoded)
    local samePayload = reencoded == encoded
    lurek.log.info("decoded chat snippet=" .. tostring(decoded))
    lurek.log.info("decoded round trip stable=" .. tostring(samePayload))
end

--@api: lurek.binary.hash
do
    local digest = lurek.binary.hash("sha256", "secret data")
    local otherDigest = lurek.binary.hash("sha256", "secret data v2")
    local sameDigest = digest == otherDigest
    lurek.log.info("save manifest sha256 len=" .. tostring(#digest))
    lurek.log.info("different payload same digest=" .. tostring(sameDigest))
end

--@api: lurek.binary.crc32
do
    local crc = lurek.binary.crc32("test data")
    local changedCrc = lurek.binary.crc32("test data!")
    local crcType = type(crc)
    lurek.log.info("packet crc32=" .. tostring(crc))
    lurek.log.info("packet crc type=" .. tostring(crcType) .. " changed payload differs=" .. tostring(changedCrc ~= crc))
end

--@api: lurek.binary.newByteData
do
    local bd = lurek.binary.newByteData(16)
    bd:setByte(0, 65)
    bd:setByte(1, 66)
    local size = bd:getSize()
    local firstByte = bd:getByte(0)
    lurek.log.info("byte buffer size=" .. tostring(size))
    lurek.log.info("byte buffer first bytes=" .. tostring(firstByte) .. "," .. tostring(bd:getByte(1)))
end

--@api: lurek.binary.newDataView
do
    local raw = lurek.binary.pack("<II", 42, 99)
    local view = lurek.binary.newDataView(raw)
    local firstValue = view:getUInt32(0)
    local secondValue = view:getUInt32(4)
    local size = view:getSize()
    lurek.log.info("spawn view size=" .. tostring(size))
    lurek.log.info("spawn view values=" .. tostring(firstValue) .. "," .. tostring(secondValue))
end

--@api: lurek.binary.write
do
    local bytes = lurek.binary.write("u32", 42)
    local rewardBytes = lurek.binary.write("u32 u32", 42, 500)
    local questId, reward = lurek.binary.read("u32 u32", rewardBytes)
    lurek.log.info("reward packet bytes=" .. tostring(#rewardBytes))
    lurek.log.info("reward packet quest=" .. tostring(questId) .. " reward=" .. tostring(reward))
end

--@api: lurek.binary.read
do
    local bytes = lurek.binary.write("bool cstr", true, "ok")
    local flag, text = lurek.binary.read("bool cstr", bytes)
    local rawSize = #bytes
    lurek.log.info("network flag=" .. tostring(flag))
    lurek.log.info("network text=" .. tostring(text) .. " bytes=" .. tostring(rawSize))
end

--@api: lurek.binary.size
do
    local sz = lurek.binary.size("u32")
    local bytes = lurek.binary.write("u32", 7)
    local transformSize = lurek.binary.size("f32 f32 f32")
    local transformBytes = lurek.binary.write("f32 f32 f32", 1.0, 2.0, 3.0)
    lurek.log.info("single u32 size=" .. tostring(sz))
    lurek.log.info("transform bytes match=" .. tostring(transformSize == #transformBytes))
end

--@api: lurek.binary.newRingBuffer
do
    local rb = lurek.binary.newRingBuffer(8)
    rb:push("spawn")
    rb:push("loot")
    local capacity = rb:capacity()
    local length = rb:len()
    lurek.log.info("event ring capacity=" .. tostring(capacity))
    lurek.log.info("event ring len=" .. tostring(length) .. " empty=" .. tostring(rb:isEmpty()))
end

--@api: lurek.binary.newWriter
do
    local w = lurek.binary.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    local writerLen = w:len()
    local typeName = w:type()
    lurek.log.info("writer created=" .. tostring(w ~= nil))
    lurek.log.info("writer type=" .. tostring(typeName) .. " len=" .. tostring(writerLen))
end

--@api: LRingBuffer:push
do
    local rb = lurek.binary.newRingBuffer(3)
    rb:push("a")
    rb:push("b")
    local evicted = rb:push("d")
    example_print_log("evicted = " .. tostring(evicted))
    example_print_log("newest = " .. tostring(rb:peekNewest()))
end

--@api: LRingBuffer:pop
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local oldest = rb:pop()
    example_print_log("popped = " .. oldest)
end

--@api: LRingBuffer:peek
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("first")
    rb:push("second")
    local oldest = rb:peek()
    local newest = rb:peekNewest()
    local count = rb:len()
    lurek.log.info("oldest queued event=" .. tostring(oldest))
    lurek.log.info("newest queued event=" .. tostring(newest) .. " count=" .. tostring(count))
end

--@api: LRingBuffer:peekNewest
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("old")
    rb:push("new")
    local oldest = rb:peek()
    local newest = rb:peekNewest()
    local count = rb:len()
    lurek.log.info("oldest replay marker=" .. tostring(oldest))
    lurek.log.info("newest replay marker=" .. tostring(newest) .. " count=" .. tostring(count))
end

--@api: LRingBuffer:len
do
    local rb = lurek.binary.newRingBuffer(10)
    rb:push(1)
    rb:push(2)
    example_print_log("len = " .. rb:len())
    example_print_log("capacity = " .. rb:capacity())
end

--@api: LRingBuffer:capacity
do
    local rb = lurek.binary.newRingBuffer(5)
    rb:push("north")
    rb:push("east")
    local capacity = rb:capacity()
    local count = rb:len()
    lurek.log.info("input history capacity=" .. tostring(capacity))
    lurek.log.info("input history count=" .. tostring(count))
end

--@api: LRingBuffer:isEmpty
do
    local rb = lurek.binary.newRingBuffer(4)
    local beforePush = rb:isEmpty()
    rb:push("value")
    local afterPush = rb:isEmpty()
    local newest = rb:peekNewest()
    lurek.log.info("buffer empty before push=" .. tostring(beforePush))
    lurek.log.info("buffer empty after push=" .. tostring(afterPush) .. " newest=" .. tostring(newest))
end

--@api: LRingBuffer:isFull
do
    local rb = lurek.binary.newRingBuffer(2)
    rb:push("a")
    rb:push("b")
    example_print_log("full = " .. tostring(rb:isFull()))
    example_print_log("len = " .. tostring(rb:len()))
end

--@api: LRingBuffer:clear
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(1)
    rb:push(2)
    rb:clear()
    example_print_log("after clear len = " .. rb:len())
end

--@api: LRingBuffer:toTable
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push(10)
    rb:push(20)
    local t = rb:toTable()
    example_print_log("table len = " .. #t)
    example_print_log("first item = " .. tostring(t[1]))
end

--@api: LRingBuffer:type
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("fx")
    local typeName = rb:type()
    local count = rb:len()
    lurek.log.info("ring buffer type=" .. tostring(typeName))
    lurek.log.info("ring buffer count=" .. tostring(count))
end

--@api: LRingBuffer:typeOf
do
    local rb = lurek.binary.newRingBuffer(4)
    rb:push("fx")
    local isRingBuffer = rb:typeOf("LRingBuffer")
    local isWriter = rb:typeOf("LDataWriter")
    lurek.log.info("is ring buffer=" .. tostring(isRingBuffer))
    lurek.log.info("is writer=" .. tostring(isWriter))
end

--@api: LDataView:getUInt8
do
    local raw = lurek.binary.pack("BBBB", 10, 20, 30, 40)
    local view = lurek.binary.newDataView(raw)
    local red = view:getUInt8(0)
    local green = view:getUInt8(1)
    local blue = view:getUInt8(2)
    lurek.log.info("palette rgb=" .. tostring(red) .. "," .. tostring(green) .. "," .. tostring(blue))
    lurek.log.info("palette raw bytes=" .. tostring(view:getSize()))
end

--@api: LDataView:getInt8
do
    local raw = lurek.binary.pack("b", -42)
    local view = lurek.binary.newDataView(raw)
    local velocity = view:getInt8(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("signed velocity byte=" .. tostring(velocity))
    lurek.log.info("velocity view size=" .. tostring(size) .. " type=" .. tostring(typeName))
end

--@api: LDataView:getInt16
do
    local raw = lurek.binary.pack("h", -1000)
    local view = lurek.binary.newDataView(raw)
    local yVelocity = view:getInt16(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("signed y velocity=" .. tostring(yVelocity))
    lurek.log.info("i16 view size=" .. tostring(size) .. " is view=" .. tostring(isView))
end

--@api: LDataView:getUInt16
do
    local raw = lurek.binary.pack("H", 65000)
    local view = lurek.binary.newDataView(raw)
    local tileId = view:getUInt16(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("tileset entry id=" .. tostring(tileId))
    lurek.log.info("u16 view size=" .. tostring(size) .. " type=" .. tostring(typeName))
end

--@api: LDataView:getInt32
do
    local raw = lurek.binary.pack("<i", -100000)
    local view = lurek.binary.newDataView(raw)
    local worldOffset = view:getInt32(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("signed world offset=" .. tostring(worldOffset))
    lurek.log.info("i32 view size=" .. tostring(size) .. " is view=" .. tostring(isView))
end

--@api: LDataView:getUInt32
do
    local raw = lurek.binary.pack("<I", 3000000)
    local view = lurek.binary.newDataView(raw)
    local saveVersion = view:getUInt32(0)
    local size = view:getSize()
    local typeName = view:type()
    lurek.log.info("save version id=" .. tostring(saveVersion))
    lurek.log.info("u32 view size=" .. tostring(size) .. " type=" .. tostring(typeName))
end

--@api: LDataView:getFloat
do
    local raw = lurek.binary.pack("f", 3.14)
    local view = lurek.binary.newDataView(raw)
    local radius = view:getFloat(0)
    local size = view:getSize()
    local bytes = lurek.binary.pack("f", radius * 2.0)
    lurek.log.info("float radius=" .. tostring(radius))
    lurek.log.info("float view size=" .. tostring(size) .. " doubled bytes=" .. tostring(#bytes))
end

--@api: LDataView:getDouble
do
    local raw = lurek.binary.pack("d", 2.718281828)
    local view = lurek.binary.newDataView(raw)
    local precisionValue = view:getDouble(0)
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("double precision value=" .. tostring(precisionValue))
    lurek.log.info("double view size=" .. tostring(size) .. " is view=" .. tostring(isView))
end

--@api: LDataView:getSize
do
    local raw = lurek.binary.pack("<III", 1, 2, 3)
    local view = lurek.binary.newDataView(raw)
    local size = view:getSize()
    local firstValue = view:getUInt32(0)
    local lastValue = view:getUInt32(8)
    lurek.log.info("navigation node blob size=" .. tostring(size))
    lurek.log.info("navigation node values=" .. tostring(firstValue) .. "," .. tostring(lastValue))
end

--@api: LDataView:type
do
    local view = lurek.binary.newDataView("abc")
    local typeName = view:type()
    local size = view:getSize()
    local isView = view:typeOf("LDataView")
    lurek.log.info("data view type=" .. tostring(typeName))
    lurek.log.info("data view size=" .. tostring(size) .. " is view=" .. tostring(isView))
end

--@api: LDataView:typeOf
do
    local view = lurek.binary.newDataView("abc")
    local isView = view:typeOf("LDataView")
    local isWriter = view:typeOf("LDataWriter")
    local size = view:getSize()
    lurek.log.info("is data view=" .. tostring(isView))
    lurek.log.info("is data writer=" .. tostring(isWriter) .. " size=" .. tostring(size))
end

--@api: LDataWriter:writeU8
do
    local w = lurek.binary.newWriter()
    w:writeU8(255)
    w:writeU8(64)
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("u8 writer len=" .. tostring(len))
    lurek.log.info("u8 writer bytes=" .. tostring(string.byte(bytes, 1)) .. "," .. tostring(string.byte(bytes, 2)))
end

--@api: LDataWriter:writeI8
do
    local w = lurek.binary.newWriter()
    w:writeI8(-128)
    w:writeI8(12)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i8 writer len=" .. tostring(w:len()))
    lurek.log.info("i8 writer values=" .. tostring(view:getInt8(0)) .. "," .. tostring(view:getInt8(1)))
end

--@api: LDataWriter:writeU16LE
do
    local w = lurek.binary.newWriter()
    w:writeU16LE(1000)
    w:writeU16LE(2000)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("u16le writer len=" .. tostring(w:len()))
    lurek.log.info("u16le values=" .. tostring(view:getUInt16(0)) .. "," .. tostring(view:getUInt16(2)))
end

--@api: LDataWriter:writeU16BE
do
    local w = lurek.binary.newWriter()
    w:writeU16BE(1000)
    w:writeU16BE(2000)
    local bytes = w:toBytes()
    local firstPair = string.byte(bytes, 1) .. "," .. string.byte(bytes, 2)
    lurek.log.info("u16be writer len=" .. tostring(w:len()))
    lurek.log.info("u16be first pair=" .. tostring(firstPair) .. " second first byte=" .. tostring(string.byte(bytes, 3)))
end

--@api: LDataWriter:writeI16LE
do
    local w = lurek.binary.newWriter()
    w:writeI16LE(-500)
    w:writeI16LE(125)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i16le writer len=" .. tostring(w:len()))
    lurek.log.info("i16le values=" .. tostring(view:getInt16(0)) .. "," .. tostring(view:getInt16(2)))
end

--- Binary Module Part 2: DataWriter (continued), ByteData

--@api: LDataWriter:writeU32LE
do
    local w = lurek.binary.newWriter()
    w:writeU32LE(123456)
    w:writeU32LE(654321)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("u32le writer len=" .. tostring(w:len()))
    lurek.log.info("u32le values=" .. tostring(view:getUInt32(0)) .. "," .. tostring(view:getUInt32(4)))
end

--@api: LDataWriter:writeI32LE
do
    local w = lurek.binary.newWriter()
    w:writeI32LE(-99999)
    w:writeI32LE(12345)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("i32le writer len=" .. tostring(w:len()))
    lurek.log.info("i32le values=" .. tostring(view:getInt32(0)) .. "," .. tostring(view:getInt32(4)))
end

--@api: LDataWriter:writeF32LE
do
    local w = lurek.binary.newWriter()
    w:writeF32LE(3.14)
    w:writeF32LE(6.28)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("f32le writer len=" .. tostring(w:len()))
    lurek.log.info("f32le values=" .. tostring(view:getFloat(0)) .. "," .. tostring(view:getFloat(4)))
end

--@api: LDataWriter:writeF64LE
do
    local w = lurek.binary.newWriter()
    w:writeF64LE(2.718281828)
    w:writeF64LE(1.414213562)
    local bytes = w:toBytes()
    local view = lurek.binary.newDataView(bytes)
    lurek.log.info("f64le writer len=" .. tostring(w:len()))
    lurek.log.info("f64le first value=" .. tostring(view:getDouble(0)) .. " second value=" .. tostring(view:getDouble(8)))
end

--@api: LDataWriter:writeString
do
    local w = lurek.binary.newWriter()
    w:writeString("Hello!")
    w:writeString("Quest")
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("string writer len=" .. tostring(len))
    lurek.log.info("string writer preview=" .. tostring(bytes:sub(1, 6)))
end

--@api: LDataWriter:writeBytes
do
    local w = lurek.binary.newWriter()
    w:writeBytes("\x00\x01\x02\x03")
    w:writeBytes("\x04\x05")
    local bytes = w:toBytes()
    local len = w:len()
    lurek.log.info("raw byte writer len=" .. tostring(len))
    lurek.log.info("raw byte tail=" .. tostring(string.byte(bytes, 5)) .. "," .. tostring(string.byte(bytes, 6)))
end

--@api: LDataWriter:seek
do
    local w = lurek.binary.newWriter()
    w:writeU32LE(0)
    w:seek(0)
    w:writeU32LE(42)
    example_print_log("seek then overwrite, len = " .. w:len())
    example_print_log("cursor = " .. w:tell())
end

--@api: LDataWriter:tell
do
    local w = lurek.binary.newWriter()
    w:writeU8(1)
    w:writeU8(2)
    local cursor = w:tell()
    local len = w:len()
    local bytes = w:toBytes()
    lurek.log.info("writer cursor=" .. tostring(cursor))
    lurek.log.info("writer len=" .. tostring(len) .. " last byte=" .. tostring(string.byte(bytes, 2)))
end

--@api: LDataWriter:len
do
    local w = lurek.binary.newWriter()
    w:writeU16LE(100)
    w:writeU16LE(200)
    local len = w:len()
    local cursor = w:tell()
    local bytes = w:toBytes()
    lurek.log.info("writer len after two u16 values=" .. tostring(len))
    lurek.log.info("writer cursor=" .. tostring(cursor) .. " first byte=" .. tostring(string.byte(bytes, 1)))
end

--@api: LDataWriter:toBytes
do
    local w = lurek.binary.newWriter()
    w:writeU8(65)
    w:writeU8(66)
    local bytes = w:toBytes()
    example_print_log("bytes len = " .. #bytes)
    example_print_log("bytes text = " .. bytes)
end

--@api: LDataWriter:type
do
    local w = lurek.binary.newWriter()
    w:writeU8(7)
    local typeName = w:type()
    local len = w:len()
    lurek.log.info("writer type=" .. tostring(typeName))
    lurek.log.info("writer len=" .. tostring(len))
end

--@api: LDataWriter:typeOf
do
    local w = lurek.binary.newWriter()
    w:writeU8(7)
    local isWriter = w:typeOf("LDataWriter")
    local isView = w:typeOf("LDataView")
    lurek.log.info("is data writer=" .. tostring(isWriter))
    lurek.log.info("is data view=" .. tostring(isView))
end

--@api: LByteData:getSize
do
    local bd = lurek.binary.newByteData(32)
    bd:setByte(0, 10)
    bd:setByte(31, 99)
    local size = bd:getSize()
    local firstByte = bd:getByte(0)
    lurek.log.info("byte data size=" .. tostring(size))
    lurek.log.info("byte data edge bytes=" .. tostring(firstByte) .. "," .. tostring(bd:getByte(31)))
end

--@api: LByteData:getString
do
    local bd = lurek.binary.newByteData(string.char(0x48, 0x65, 0x00, 0xFF))
    local rawString = bd:getString()
    local size = bd:getSize()
    local lastByte = bd:getByte(3)
    lurek.log.info("byte data string len=" .. tostring(#rawString))
    lurek.log.info("byte data size=" .. tostring(size) .. " last byte=" .. tostring(lastByte))
end

--@api: LByteData:getByte
do
    local bd = lurek.binary.newByteData("ABC")
    local firstByte = bd:getByte(0)
    local secondByte = bd:getByte(1)
    local size = bd:getSize()
    lurek.log.info("byte data ascii=" .. tostring(firstByte) .. "," .. tostring(secondByte))
    lurek.log.info("byte data size=" .. tostring(size))
end

--@api: LByteData:setByte
do
    local bd = lurek.binary.newByteData(4)
    bd:setByte(0, 255)
    bd:setByte(1, 128)
    local firstByte = bd:getByte(0)
    local secondByte = bd:getByte(1)
    lurek.log.info("written bytes=" .. tostring(firstByte) .. "," .. tostring(secondByte))
    lurek.log.info("byte data size=" .. tostring(bd:getSize()))
end

--@api: LByteData:clone
do
    local bd = lurek.binary.newByteData("test")
    local copy = bd:clone()
    copy:setByte(0, 88)
    local originalByte = bd:getByte(0)
    local copiedByte = copy:getByte(0)
    local sameSize = bd:getSize() == copy:getSize()
    lurek.log.info("clone keeps original byte=" .. tostring(originalByte))
    lurek.log.info("clone changed byte=" .. tostring(copiedByte) .. " size match=" .. tostring(sameSize))
end

--@api: LByteData:setBit
do
    local bd = lurek.binary.newByteData(1)
    bd:setBit(0, 0, true)
    bd:setBit(0, 7, true)
    example_print_log("byte = " .. bd:getByte(0))
    example_print_log("bit 7 = " .. tostring(bd:getBit(0, 7)))
end

--@api: LByteData:getBit
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 0x80)
    local highBit = bd:getBit(0, 7)
    local lowBit = bd:getBit(0, 0)
    local storedByte = bd:getByte(0)
    lurek.log.info("stored byte=" .. tostring(storedByte))
    lurek.log.info("high bit=" .. tostring(highBit) .. " low bit=" .. tostring(lowBit))
end

--@api: LByteData:readBits
do
    local bd = lurek.binary.newByteData(2)
    bd:setByte(0, 0xFF)
    bd:setByte(1, 0x0F)
    local val = bd:readBits(0, 0, 12)
    example_print_log("12 bits = " .. val)
end

--@api: LByteData:type
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 7)
    local typeName = bd:type()
    local size = bd:getSize()
    lurek.log.info("byte data type=" .. tostring(typeName))
    lurek.log.info("byte data size=" .. tostring(size))
end

--@api: LByteData:typeOf
do
    local bd = lurek.binary.newByteData(1)
    bd:setByte(0, 7)
    local isByteData = bd:typeOf("LByteData")
    local isView = bd:typeOf("LDataView")
    lurek.log.info("is byte data=" .. tostring(isByteData))
    lurek.log.info("is data view=" .. tostring(isView))
end

-- --- lurek.binary aliases (defined in binary_api.rs) ------------------------
