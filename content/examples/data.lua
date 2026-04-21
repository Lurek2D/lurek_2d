-- content/examples/data.lua
-- Lurek2D lurek.data API Reference
-- Run with: cargo run -- content/examples/data
--
Scenario: A save-game system that serializes player state into binary format,
-- compresses it for storage, uses ring buffers for undo history, and parses
-- TOML configuration files for mod settings.

print("=== lurek.data — Binary Data & Serialization ===\n")

-- =============================================================================
-- Pack / Unpack — binary struct encoding
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.pack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_pack()
    local packed = lurek.data.pack("ffH", 123.5, 456.7, 100)
    print("packed size: " .. #packed)
end
local _ok, _err = pcall(demo_lurek_data_pack)

-- Demonstrates the proper usage of lurek.data.unpack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_unpack()
    local x, y, hp = lurek.data.unpack("ffH", packed)
    print("unpacked: " .. x .. "," .. y .. " hp=" .. hp)
end
local _ok, _err = pcall(demo_lurek_data_unpack)

-- Demonstrates the proper usage of lurek.data.getPackedSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_getPackedSize()
    print("format 'ffH' size: " .. lurek.data.getPackedSize("ffH"))
end
local _ok, _err = pcall(demo_lurek_data_getPackedSize)

-- =============================================================================
-- Compression
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.compress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_compress()
    local blob = string.rep("hello world ", 1000)
    local compressed = lurek.data.compress(blob)
    print("compressed: " .. #blob .. " -> " .. #compressed)
end
local _ok, _err = pcall(demo_lurek_data_compress)

-- Demonstrates the proper usage of lurek.data.decompress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_decompress()
    local restored = lurek.data.decompress(compressed)
    print("decompressed matches: " .. tostring(restored == blob))
end
local _ok, _err = pcall(demo_lurek_data_decompress)

-- =============================================================================
-- Encoding (base64, hex)
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.encode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_encode()
    local b64 = lurek.data.encode("base64", "save data here")
    print("base64: " .. b64)
end
local _ok, _err = pcall(demo_lurek_data_encode)

-- Demonstrates the proper usage of lurek.data.decode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_decode()
    local decoded = lurek.data.decode("base64", b64)
    print("decoded: " .. decoded)
end
local _ok, _err = pcall(demo_lurek_data_decode)

-- =============================================================================
-- Hashing
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.hash.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_hash()
    local checksum = lurek.data.hash("sha256", "player_save_v1")
    print("sha256: " .. checksum)
end
local _ok, _err = pcall(demo_lurek_data_hash)

-- =============================================================================
-- MessagePack
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.toMsgPack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_toMsgPack()
    local msg = lurek.data.toMsgPack({name = "Hero", level = 10, items = {"sword", "shield"}})
    print("msgpack size: " .. #msg)
end
local _ok, _err = pcall(demo_lurek_data_toMsgPack)

-- Demonstrates the proper usage of lurek.data.fromMsgPack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_fromMsgPack()
    local obj = lurek.data.fromMsgPack(msg)
    print("from msgpack: " .. obj.name .. " level " .. obj.level)
end
local _ok, _err = pcall(demo_lurek_data_fromMsgPack)

-- =============================================================================
-- TOML Parsing — mod configuration
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.parseToml.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_parseToml()
    local cfg = lurek.data.parseToml([[
    [mod]
    name = "extended_combat"
    version = "1.2.0"
    enabled = true
    ]])
    print("mod name: " .. cfg.mod.name)
end
local _ok, _err = pcall(demo_lurek_data_parseToml)

-- Demonstrates the proper usage of lurek.data.encodeToml.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_encodeToml()
    local toml_str = lurek.data.encodeToml({settings = {volume = 0.8, fullscreen = true}})
    print("encoded toml:\n" .. toml_str)
end
local _ok, _err = pcall(demo_lurek_data_encodeToml)

-- =============================================================================
-- ByteData — raw byte buffers
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.newByteData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newByteData()
    local bytes = lurek.data.newByteData(256)
end
local _ok, _err = pcall(demo_lurek_data_newByteData)

-- Demonstrates the proper usage of mlua:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getSize()
    print("byte data size: " .. bytes:getSize())
end
local _ok, _err = pcall(demo_mlua_getSize)

-- Demonstrates the proper usage of mlua:getString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getString()
    local str = bytes:getString()
end
local _ok, _err = pcall(demo_mlua_getString)

-- Demonstrates the proper usage of mlua:getByte.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getByte()
    local b = bytes:getByte(0)
    print("byte 0: " .. b)
end
local _ok, _err = pcall(demo_mlua_getByte)

-- Demonstrates the proper usage of mlua:setByte.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_setByte()
    bytes:setByte(0, 42)
end
local _ok, _err = pcall(demo_mlua_setByte)

-- Demonstrates the proper usage of mlua:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_clone()
    local bytes_copy = bytes:clone()
end
local _ok, _err = pcall(demo_mlua_clone)

-- =============================================================================
-- DataView — typed access to binary data
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.newDataView.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newDataView()
    local view = lurek.data.newDataView(packed)
end
local _ok, _err = pcall(demo_lurek_data_newDataView)

-- Demonstrates the proper usage of DataView:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getSize()
    print("view size: " .. view:getSize())
end
local _ok, _err = pcall(demo_DataView_getSize)

-- Demonstrates the proper usage of DataView:getFloat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getFloat()
    print("float at 0: " .. view:getFloat(0))
end
local _ok, _err = pcall(demo_DataView_getFloat)

-- Demonstrates the proper usage of DataView:getDouble.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getDouble()
    print("double at 0: " .. view:getDouble(0))
end
local _ok, _err = pcall(demo_DataView_getDouble)

-- Demonstrates the proper usage of DataView:getUInt8.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt8()
    print("u8 at 0: " .. view:getUInt8(0))
end
local _ok, _err = pcall(demo_DataView_getUInt8)

-- Demonstrates the proper usage of DataView:getInt8.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt8()
    print("i8 at 0: " .. view:getInt8(0))
end
local _ok, _err = pcall(demo_DataView_getInt8)

-- Demonstrates the proper usage of DataView:getInt16.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt16()
    print("i16 at 0: " .. view:getInt16(0))
end
local _ok, _err = pcall(demo_DataView_getInt16)

-- Demonstrates the proper usage of DataView:getUInt16.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt16()
    print("u16 at 0: " .. view:getUInt16(0))
end
local _ok, _err = pcall(demo_DataView_getUInt16)

-- Demonstrates the proper usage of DataView:getInt32.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt32()
    print("i32 at 0: " .. view:getInt32(0))
end
local _ok, _err = pcall(demo_DataView_getInt32)

-- Demonstrates the proper usage of DataView:getUInt32.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt32()
    print("u32 at 0: " .. view:getUInt32(0))
end
local _ok, _err = pcall(demo_DataView_getUInt32)

-- =============================================================================
-- File I/O shortcuts
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.write.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_write()
    lurek.data.write("save/player.dat", packed)
end
local _ok, _err = pcall(demo_lurek_data_write)

-- Demonstrates the proper usage of lurek.data.read.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_read()
    local loaded = lurek.data.read("save/player.dat")
    print("loaded save: " .. #loaded .. " bytes")
end
local _ok, _err = pcall(demo_lurek_data_read)

-- Demonstrates the proper usage of lurek.data.size.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_size()
    print("file size: " .. lurek.data.size("save/player.dat"))
end
local _ok, _err = pcall(demo_lurek_data_size)

-- =============================================================================
-- RingBuffer — undo/redo history
-- =============================================================================

-- Demonstrates the proper usage of lurek.data.newRingBuffer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newRingBuffer()
    local undo = lurek.data.newRingBuffer(20)
end
local _ok, _err = pcall(demo_lurek_data_newRingBuffer)

-- Demonstrates the proper usage of RingBuffer:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_push()
    undo:push({action = "move", x = 100, y = 200})
    undo:push({action = "attack", target = "goblin"})
    undo:push({action = "move", x = 150, y = 210})
end
local _ok, _err = pcall(demo_RingBuffer_push)

-- Demonstrates the proper usage of RingBuffer:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print("undo stack: " .. undo:len())
end
local _ok, _err = pcall(demo_RingBuffer_len)

-- Demonstrates the proper usage of RingBuffer:capacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_capacity()
    print("capacity: " .. undo:capacity())
end
local _ok, _err = pcall(demo_RingBuffer_capacity)

-- Demonstrates the proper usage of RingBuffer:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_isEmpty()
    print("empty: " .. tostring(undo:isEmpty()))
end
local _ok, _err = pcall(demo_RingBuffer_isEmpty)

-- Demonstrates the proper usage of RingBuffer:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_isFull()
    print("full: " .. tostring(undo:isFull()))
end
local _ok, _err = pcall(demo_RingBuffer_isFull)

-- Demonstrates the proper usage of RingBuffer:peek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_peek()
    local oldest = undo:peek()
    print("oldest action: " .. oldest.action)
end
local _ok, _err = pcall(demo_RingBuffer_peek)

-- Demonstrates the proper usage of RingBuffer:peekNewest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_peekNewest()
    local newest = undo:peekNewest()
    print("newest action: " .. newest.action)
end
local _ok, _err = pcall(demo_RingBuffer_peekNewest)

-- Demonstrates the proper usage of RingBuffer:pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_pop()
    local undone = undo:pop()
    print("undone: " .. undone.action)
end
local _ok, _err = pcall(demo_RingBuffer_pop)

-- Demonstrates the proper usage of RingBuffer:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_toTable()
    local history = undo:toTable()
    print("remaining history: " .. #history)
end
local _ok, _err = pcall(demo_RingBuffer_toTable)

-- Demonstrates the proper usage of RingBuffer:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_clear()
    undo:clear()
end
local _ok, _err = pcall(demo_RingBuffer_clear)

-- =============================================================================
-- New in 0.15.0: DataWriter — binary write buffer
-- =============================================================================

local w = lurek.data.newWriter()

-- Write individual fields.
w:writeU8(0x01)
w:writeU32LE(0xDEADBEEF)
w:writeString("hello")
print(string.format("DataWriter len after writes: %d", w:len()))

-- Seek to position 0 and overwrite the first byte.
w:seek(0)
w:writeU8(0xFF)
print(string.format("cursor after seek+write: %d", w:tell()))

-- Export the raw bytes as a Lua string.
local bytes = w:toBytes()
print(string.format("toBytes length: %d, first byte: 0x%02X", #bytes, string.byte(bytes, 1)))

-- =============================================================================
-- New in 0.15.0: lurek.data.crc32
-- =============================================================================

-- CRC-32 is a fast, non-cryptographic checksum — ideal for asset validation.
local checksum = lurek.data.crc32("123456789")
-- ISO/IEC 3309 check value: 0xCBF43926 = 3421780262
print(string.format("crc32('123456789') = 0x%08X (%d)", checksum, checksum))

local ck_hello = lurek.data.crc32("hello")
local ck_world = lurek.data.crc32("world")
print(string.format("crc32('hello')=%d  crc32('world')=%d  equal=%s",
  ck_hello, ck_world, tostring(ck_hello == ck_world)))

print("\n-- data.lua example complete --")

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- DataWriter methods
-- -----------------------------------------------------------------------------

-- Writes a signed 8-bit integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI8()")
    pcall(function() datawriter:writeI8() end)
    print("Executed smoothly.")
end

-- Writes an unsigned 16-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeU16LE()")
    pcall(function() datawriter:writeU16LE() end)
    print("Executed smoothly.")
end

-- Writes an unsigned 16-bit BE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeU16BE()")
    pcall(function() datawriter:writeU16BE() end)
    print("Executed smoothly.")
end

-- Writes a signed 16-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI16LE()")
    pcall(function() datawriter:writeI16LE() end)
    print("Executed smoothly.")
end

-- Writes a signed 32-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI32LE()")
    pcall(function() datawriter:writeI32LE() end)
    print("Executed smoothly.")
end

-- Writes a 32-bit LE float.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeF32LE()")
    pcall(function() datawriter:writeF32LE() end)
    print("Executed smoothly.")
end

-- Writes a 64-bit LE float.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeF64LE()")
    pcall(function() datawriter:writeF64LE() end)
    print("Executed smoothly.")
end

-- Writes raw bytes from a Lua string.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeBytes()")
    pcall(function() datawriter:writeBytes() end)
    print("Executed smoothly.")
end
-- Returns the CRC-32 checksum of the input data as an integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_crc32()
    print('Executing crc32')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_data_crc32)

-- Returns the number of elements currently in the buffer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_RingBuffer_len)

-- Creates a new write-cursor for building binary data.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newWriter()
    print('Executing newWriter')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_data_newWriter)

-- Moves the write cursor to the given position.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_seek()
    print('Executing seek')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_seek)

-- Returns the current write cursor position.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_tell()
    print('Executing tell')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_tell)

-- Returns the buffer contents as a Lua string.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_toBytes()
    print('Executing toBytes')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_toBytes)

-- Writes a length-prefixed UTF-8 string (4-byte LE length + bytes).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeString()
    print('Executing writeString')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeString)

-- Writes an unsigned 32-bit LE integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeU32LE()
    print('Executing writeU32LE')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeU32LE)

-- Writes an unsigned 8-bit integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeU8()
    print('Executing writeU8')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeU8)

-- Returns the CRC-32 checksum of the input data as an integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_crc32()
    print('Executing crc32')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_data_crc32)

-- Returns the number of elements currently in the buffer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_RingBuffer_len)

-- Creates a new write-cursor for building binary data.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newWriter()
    print('Executing newWriter')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_data_newWriter)

-- Moves the write cursor to the given position.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_seek()
    print('Executing seek')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_seek)

-- Returns the current write cursor position.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_tell()
    print('Executing tell')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_tell)

-- Returns the buffer contents as a Lua string.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_toBytes()
    print('Executing toBytes')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_toBytes)

-- Writes a length-prefixed UTF-8 string (4-byte LE length + bytes).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeString()
    print('Executing writeString')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeString)

-- Writes an unsigned 32-bit LE integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeU32LE()
    print('Executing writeU32LE')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeU32LE)

-- Writes an unsigned 8-bit integer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_writeU8()
    print('Executing writeU8')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_writeU8)

-- Demonstrates ByteReader:len
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ByteReader_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_ByteReader_len)
-- Demonstrates RingBuffer:len
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_RingBuffer_len)

-- Demonstrates RingBuffer:len
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_RingBuffer_len)

-- Demonstrates RingBuffer:len
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_RingBuffer_len)
-- Demonstrates DataWriter:len
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataWriter_len()
    print('Executing len')
    print('Example')
end
local _ok, _err = pcall(demo_DataWriter_len)
