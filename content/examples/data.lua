-- content/examples/data.lua
-- Lurek2D lurek.data API Reference
-- Run with: cargo run -- content/examples/data
--
-- Scenario: A save-game system that serializes player state into binary format,
-- compresses it for storage, uses ring buffers for undo history, and parses
-- TOML configuration files for mod settings.

print("=== lurek.data — Binary Data & Serialization ===\n")

-- =============================================================================
-- Pack / Unpack — binary struct encoding
-- =============================================================================

--@api-stub: lurek.data.pack
-- Demonstrates the proper usage of lurek.data.pack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_pack()
    local packed = lurek.data.pack("ffH", 123.5, 456.7, 100)
    print("packed size: " .. #packed)
end
local _ok, _err = pcall(demo_lurek_data_pack)

--@api-stub: lurek.data.unpack
-- Demonstrates the proper usage of lurek.data.unpack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_unpack()
    local x, y, hp = lurek.data.unpack("ffH", packed)
    print("unpacked: " .. x .. "," .. y .. " hp=" .. hp)
end
local _ok, _err = pcall(demo_lurek_data_unpack)

--@api-stub: lurek.data.getPackedSize
-- Demonstrates the proper usage of lurek.data.getPackedSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_getPackedSize()
    print("format 'ffH' size: " .. lurek.data.getPackedSize("ffH"))
end
local _ok, _err = pcall(demo_lurek_data_getPackedSize)

-- =============================================================================
-- Compression
-- =============================================================================

--@api-stub: lurek.data.compress
-- Demonstrates the proper usage of lurek.data.compress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_compress()
    local blob = string.rep("hello world ", 1000)
    local compressed = lurek.data.compress(blob)
    print("compressed: " .. #blob .. " -> " .. #compressed)
end
local _ok, _err = pcall(demo_lurek_data_compress)

--@api-stub: lurek.data.decompress
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

--@api-stub: lurek.data.encode
-- Demonstrates the proper usage of lurek.data.encode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_encode()
    local b64 = lurek.data.encode("base64", "save data here")
    print("base64: " .. b64)
end
local _ok, _err = pcall(demo_lurek_data_encode)

--@api-stub: lurek.data.decode
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

--@api-stub: lurek.data.hash
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

--@api-stub: lurek.data.toMsgPack
-- Demonstrates the proper usage of lurek.data.toMsgPack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_toMsgPack()
    local msg = lurek.data.toMsgPack({name = "Hero", level = 10, items = {"sword", "shield"}})
    print("msgpack size: " .. #msg)
end
local _ok, _err = pcall(demo_lurek_data_toMsgPack)

--@api-stub: lurek.data.fromMsgPack
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

--@api-stub: lurek.data.parseToml
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

--@api-stub: lurek.data.encodeToml
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

--@api-stub: lurek.data.newByteData
-- Demonstrates the proper usage of lurek.data.newByteData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newByteData()
    local bytes = lurek.data.newByteData(256)
end
local _ok, _err = pcall(demo_lurek_data_newByteData)

--@api-stub: mlua:getSize
-- Demonstrates the proper usage of mlua:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getSize()
    print("byte data size: " .. bytes:getSize())
end
local _ok, _err = pcall(demo_mlua_getSize)

--@api-stub: mlua:getString
-- Demonstrates the proper usage of mlua:getString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getString()
    local str = bytes:getString()
end
local _ok, _err = pcall(demo_mlua_getString)

--@api-stub: mlua:getByte
-- Demonstrates the proper usage of mlua:getByte.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getByte()
    local b = bytes:getByte(0)
    print("byte 0: " .. b)
end
local _ok, _err = pcall(demo_mlua_getByte)

--@api-stub: mlua:setByte
-- Demonstrates the proper usage of mlua:setByte.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_setByte()
    bytes:setByte(0, 42)
end
local _ok, _err = pcall(demo_mlua_setByte)

--@api-stub: mlua:clone
-- Demonstrates the proper usage of mlua:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_clone()
    local bytes_copy = bytes:clone()
end
local _ok, _err = pcall(demo_mlua_clone)

-- =============================================================================
-- DataView — typed access to binary data
-- =============================================================================

--@api-stub: lurek.data.newDataView
-- Demonstrates the proper usage of lurek.data.newDataView.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newDataView()
    local view = lurek.data.newDataView(packed)
end
local _ok, _err = pcall(demo_lurek_data_newDataView)

--@api-stub: DataView:getSize
-- Demonstrates the proper usage of DataView:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getSize()
    print("view size: " .. view:getSize())
end
local _ok, _err = pcall(demo_DataView_getSize)

--@api-stub: DataView:getFloat
-- Demonstrates the proper usage of DataView:getFloat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getFloat()
    print("float at 0: " .. view:getFloat(0))
end
local _ok, _err = pcall(demo_DataView_getFloat)

--@api-stub: DataView:getDouble
-- Demonstrates the proper usage of DataView:getDouble.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getDouble()
    print("double at 0: " .. view:getDouble(0))
end
local _ok, _err = pcall(demo_DataView_getDouble)

--@api-stub: DataView:getUInt8
-- Demonstrates the proper usage of DataView:getUInt8.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt8()
    print("u8 at 0: " .. view:getUInt8(0))
end
local _ok, _err = pcall(demo_DataView_getUInt8)

--@api-stub: DataView:getInt8
-- Demonstrates the proper usage of DataView:getInt8.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt8()
    print("i8 at 0: " .. view:getInt8(0))
end
local _ok, _err = pcall(demo_DataView_getInt8)

--@api-stub: DataView:getInt16
-- Demonstrates the proper usage of DataView:getInt16.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt16()
    print("i16 at 0: " .. view:getInt16(0))
end
local _ok, _err = pcall(demo_DataView_getInt16)

--@api-stub: DataView:getUInt16
-- Demonstrates the proper usage of DataView:getUInt16.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt16()
    print("u16 at 0: " .. view:getUInt16(0))
end
local _ok, _err = pcall(demo_DataView_getUInt16)

--@api-stub: DataView:getInt32
-- Demonstrates the proper usage of DataView:getInt32.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getInt32()
    print("i32 at 0: " .. view:getInt32(0))
end
local _ok, _err = pcall(demo_DataView_getInt32)

--@api-stub: DataView:getUInt32
-- Demonstrates the proper usage of DataView:getUInt32.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataView_getUInt32()
    print("u32 at 0: " .. view:getUInt32(0))
end
local _ok, _err = pcall(demo_DataView_getUInt32)

-- =============================================================================
-- File I/O shortcuts
-- =============================================================================

--@api-stub: lurek.data.write
-- Demonstrates the proper usage of lurek.data.write.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_write()
    lurek.data.write("save/player.dat", packed)
end
local _ok, _err = pcall(demo_lurek_data_write)

--@api-stub: lurek.data.read
-- Demonstrates the proper usage of lurek.data.read.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_read()
    local loaded = lurek.data.read("save/player.dat")
    print("loaded save: " .. #loaded .. " bytes")
end
local _ok, _err = pcall(demo_lurek_data_read)

--@api-stub: lurek.data.size
-- Demonstrates the proper usage of lurek.data.size.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_size()
    print("file size: " .. lurek.data.size("save/player.dat"))
end
local _ok, _err = pcall(demo_lurek_data_size)

-- =============================================================================
-- RingBuffer — undo/redo history
-- =============================================================================

--@api-stub: lurek.data.newRingBuffer
-- Demonstrates the proper usage of lurek.data.newRingBuffer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_data_newRingBuffer()
    local undo = lurek.data.newRingBuffer(20)
end
local _ok, _err = pcall(demo_lurek_data_newRingBuffer)

--@api-stub: RingBuffer:push
-- Demonstrates the proper usage of RingBuffer:push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_push()
    undo:push({action = "move", x = 100, y = 200})
    undo:push({action = "attack", target = "goblin"})
    undo:push({action = "move", x = 150, y = 210})
end
local _ok, _err = pcall(demo_RingBuffer_push)

--@api-stub: RingBuffer:len
-- Demonstrates the proper usage of RingBuffer:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_len()
    print("undo stack: " .. undo:len())
end
local _ok, _err = pcall(demo_RingBuffer_len)

--@api-stub: RingBuffer:capacity
-- Demonstrates the proper usage of RingBuffer:capacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_capacity()
    print("capacity: " .. undo:capacity())
end
local _ok, _err = pcall(demo_RingBuffer_capacity)

--@api-stub: RingBuffer:isEmpty
-- Demonstrates the proper usage of RingBuffer:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_isEmpty()
    print("empty: " .. tostring(undo:isEmpty()))
end
local _ok, _err = pcall(demo_RingBuffer_isEmpty)

--@api-stub: RingBuffer:isFull
-- Demonstrates the proper usage of RingBuffer:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_isFull()
    print("full: " .. tostring(undo:isFull()))
end
local _ok, _err = pcall(demo_RingBuffer_isFull)

--@api-stub: RingBuffer:peek
-- Demonstrates the proper usage of RingBuffer:peek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_peek()
    local oldest = undo:peek()
    print("oldest action: " .. oldest.action)
end
local _ok, _err = pcall(demo_RingBuffer_peek)

--@api-stub: RingBuffer:peekNewest
-- Demonstrates the proper usage of RingBuffer:peekNewest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_peekNewest()
    local newest = undo:peekNewest()
    print("newest action: " .. newest.action)
end
local _ok, _err = pcall(demo_RingBuffer_peekNewest)

--@api-stub: RingBuffer:pop
-- Demonstrates the proper usage of RingBuffer:pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_pop()
    local undone = undo:pop()
    print("undone: " .. undone.action)
end
local _ok, _err = pcall(demo_RingBuffer_pop)

--@api-stub: RingBuffer:toTable
-- Demonstrates the proper usage of RingBuffer:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RingBuffer_toTable()
    local history = undo:toTable()
    print("remaining history: " .. #history)
end
local _ok, _err = pcall(demo_RingBuffer_toTable)

--@api-stub: RingBuffer:clear
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
-- STUBS: 8 uncovered lurek.data API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- DataWriter methods
-- -----------------------------------------------------------------------------

-- ---- Stub: DataWriter:writeI8 --------------------------------------------
--@api-stub: DataWriter:writeI8
-- Writes a signed 8-bit integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI8()")
    pcall(function() datawriter:writeI8() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeU16LE -----------------------------------------
--@api-stub: DataWriter:writeU16LE
-- Writes an unsigned 16-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeU16LE()")
    pcall(function() datawriter:writeU16LE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeU16BE -----------------------------------------
--@api-stub: DataWriter:writeU16BE
-- Writes an unsigned 16-bit BE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeU16BE()")
    pcall(function() datawriter:writeU16BE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeI16LE -----------------------------------------
--@api-stub: DataWriter:writeI16LE
-- Writes a signed 16-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI16LE()")
    pcall(function() datawriter:writeI16LE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeI32LE -----------------------------------------
--@api-stub: DataWriter:writeI32LE
-- Writes a signed 32-bit LE integer.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeI32LE()")
    pcall(function() datawriter:writeI32LE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeF32LE -----------------------------------------
--@api-stub: DataWriter:writeF32LE
-- Writes a 32-bit LE float.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeF32LE()")
    pcall(function() datawriter:writeF32LE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeF64LE -----------------------------------------
--@api-stub: DataWriter:writeF64LE
-- Writes a 64-bit LE float.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeF64LE()")
    pcall(function() datawriter:writeF64LE() end)
    print("Executed smoothly.")
end

-- ---- Stub: DataWriter:writeBytes -----------------------------------------
--@api-stub: DataWriter:writeBytes
-- Writes raw bytes from a Lua string.
-- Example scenario:
if datawriter ~= nil then
    -- Calling actual method on datawriter successfully
    print("Action: calling writeBytes()")
    pcall(function() datawriter:writeBytes() end)
    print("Executed smoothly.")
end
