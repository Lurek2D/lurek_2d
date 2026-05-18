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

print("data_01.lua")
