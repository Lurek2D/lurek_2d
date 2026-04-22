-- content/examples/data.lua
-- love2d-style usage snippets for the lurek.data API (57 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/data.lua

-- ── lurek.data.* functions ──

--@api-stub: lurek.data.pack
-- Packs values into a binary byte string using the format string.
-- See the module spec for detailed semantics.
local result = lurek.data.pack("hello", vals)
print("pack:", result)
return result

--@api-stub: lurek.data.unpack
-- Unpacks values from a binary byte string, returning values followed by next offset.
-- See the module spec for detailed semantics.
local result = lurek.data.unpack("hello", raw, offset)
print("unpack:", result)
return result

--@api-stub: lurek.data.getPackedSize
-- Returns the number of bytes the given format and values would occupy.
-- Cheap to call; safe inside callbacks.
local value = lurek.data.getPackedSize("hello", vals)
print("getPackedSize:", value)
return value

--@api-stub: lurek.data.compress
-- Compresses data using the given algorithm (deflate, gzip, lz4).
-- See the module spec for detailed semantics.
local result = lurek.data.compress("hello", { x = 0, y = 0 }, level)
print("compress:", result)
return result

--@api-stub: lurek.data.decompress
-- Decompresses data using the given algorithm (deflate, gzip, lz4).
-- See the module spec for detailed semantics.
local result = lurek.data.decompress("hello", compressed)
print("decompress:", result)
return result

--@api-stub: lurek.data.encode
-- Encodes binary data using the given format (base64, hex).
-- May block — call from a worker thread for large payloads.
local result = lurek.data.encode("hello", { x = 0, y = 0 })
-- may block; consider lurek.thread for large payloads
print("encode:", result)
print("ok")

--@api-stub: lurek.data.decode
-- Decodes encoded text back to binary (base64, hex).
-- May block — call from a worker thread for large payloads.
local result = lurek.data.decode("hello", encoded)
-- may block; consider lurek.thread for large payloads
print("decode:", result)
print("ok")

--@api-stub: lurek.data.hash
-- Returns the cryptographic hash of the input (md5, sha1, sha256, sha512).
-- See the module spec for detailed semantics.
local result = lurek.data.hash("hello", { x = 0, y = 0 })
print("hash:", result)
return result

--@api-stub: lurek.data.crc32
-- Returns the CRC-32 checksum of the input data as an integer.
-- See the module spec for detailed semantics.
local result = lurek.data.crc32({ x = 0, y = 0 })
print("crc32:", result)
return result

--@api-stub: lurek.data.newDataView
-- Creates a read-only windowed view into a byte string.
-- Build once at startup; reuse across frames.
local dataview = lurek.data.newDataView(raw, offset, 10)
print("created", dataview)
return dataview

--@api-stub: lurek.data.write
-- Writes values using the Lurek2D Binary Pack Format.
-- See the module spec for detailed semantics.
local result = lurek.data.write("hello", vals)
print("write:", result)
return result

--@api-stub: lurek.data.read
-- Reads values using the Lurek2D Binary Pack Format.
-- Cheap to call; safe inside callbacks.
local value = lurek.data.read("hello", raw, offset)
print("read:", value)
return value

--@api-stub: lurek.data.size
-- Returns the byte size of a Lurek2D Binary Pack Format string.
-- See the module spec for detailed semantics.
local result = lurek.data.size("hello")
print("size:", result)
return result

--@api-stub: lurek.data.parseToml
-- Parses a TOML string into a Lua table.
-- See the module spec for detailed semantics.
local result = lurek.data.parseToml("hello")
print("parseToml:", result)
return result

--@api-stub: lurek.data.encodeToml
-- Encodes a Lua table into a TOML string.
-- May block — call from a worker thread for large payloads.
local result = lurek.data.encodeToml(tbl)
-- may block; consider lurek.thread for large payloads
print("encodeToml:", result)
print("ok")

--@api-stub: lurek.data.newRingBuffer
-- Creates a fixed-capacity ring buffer that can store any Lua value.
-- Build once at startup; reuse across frames.
local ringbuffer = lurek.data.newRingBuffer(capacity)
print("created", ringbuffer)
return ringbuffer

--@api-stub: lurek.data.toMsgPack
-- Serializes a Lua value (table, string, number, boolean, or nil) to MessagePack binary.
-- See the module spec for detailed semantics.
local result = lurek.data.toMsgPack(value)
print("toMsgPack:", result)
return result

--@api-stub: lurek.data.fromMsgPack
-- Deserializes a MessagePack binary string back into a Lua value.
-- Build once at startup; reuse across frames.
local frommsgpack = lurek.data.fromMsgPack(bytes)
print("created", frommsgpack)
return frommsgpack

--@api-stub: lurek.data.newWriter
-- Creates a new write-cursor for building binary data.
-- Build once at startup; reuse across frames.
local writer = lurek.data.newWriter()
print("created", writer)
return writer

-- ── RingBuffer methods ──

--@api-stub: RingBuffer:push
-- Pushes a value onto the ring buffer.
-- Side-effecting; safe to call any time after init.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:push(value)
print("RingBuffer:push done")

--@api-stub: RingBuffer:pop
-- Removes and returns the oldest element, or nil if the buffer is empty.
-- Pair with the matching constructor to free resources.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:pop()
-- ringBuffer is now released
print("ok")

--@api-stub: RingBuffer:peek
-- Returns the oldest element without removing it, or nil if empty.
-- Cheap to call; safe inside callbacks.
local ringBuffer = lurek.data.newRingBuffer()  -- or your existing handle
local value = ringBuffer:peek()
print("RingBuffer:peek ->", value)

--@api-stub: RingBuffer:peekNewest
-- Returns the newest element without removing it, or nil if empty.
-- Cheap to call; safe inside callbacks.
local ringBuffer = lurek.data.newRingBuffer()  -- or your existing handle
local value = ringBuffer:peekNewest()
print("RingBuffer:peekNewest ->", value)

--@api-stub: RingBuffer:len
-- Returns the number of elements currently in the buffer.
-- See the module spec for detailed semantics.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:len()
print("RingBuffer:len done")

--@api-stub: RingBuffer:capacity
-- Returns the maximum number of elements the buffer can hold.
-- See the module spec for detailed semantics.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:capacity()
print("RingBuffer:capacity done")

--@api-stub: RingBuffer:isEmpty
-- Returns true if the buffer contains no elements.
-- Use as a guard inside lurek.update or event handlers.
local ringBuffer = lurek.data.newRingBuffer()
if ringBuffer:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: RingBuffer:clear
-- Removes all elements from the buffer, releasing their registry entries.
-- Pair with the matching constructor to free resources.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:clear()
-- ringBuffer is now released
print("ok")

--@api-stub: RingBuffer:toTable
-- Returns all elements as an array table ordered oldest-first.
-- See the module spec for detailed semantics.
local ringBuffer = lurek.data.newRingBuffer()
ringBuffer:toTable()
print("RingBuffer:toTable done")

-- ── DataView methods ──

--@api-stub: DataView:getUInt8
-- Reads an unsigned 8-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getUInt8(offset)
print("DataView:getUInt8 ->", value)

--@api-stub: DataView:getInt8
-- Reads a signed 8-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getInt8(offset)
print("DataView:getInt8 ->", value)

--@api-stub: DataView:getInt16
-- Reads a signed 16-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getInt16(offset)
print("DataView:getInt16 ->", value)

--@api-stub: DataView:getUInt16
-- Reads an unsigned 16-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getUInt16(offset)
print("DataView:getUInt16 ->", value)

--@api-stub: DataView:getInt32
-- Reads a signed 32-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getInt32(offset)
print("DataView:getInt32 ->", value)

--@api-stub: DataView:getUInt32
-- Reads an unsigned 32-bit integer at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getUInt32(offset)
print("DataView:getUInt32 ->", value)

--@api-stub: DataView:getFloat
-- Reads a 32-bit float at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getFloat(offset)
print("DataView:getFloat ->", value)

--@api-stub: DataView:getDouble
-- Reads a 64-bit float at the given offset.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getDouble(offset)
print("DataView:getDouble ->", value)

--@api-stub: DataView:getSize
-- Returns the size of this view in bytes.
-- Cheap to call; safe inside callbacks.
local dataView = lurek.data.newDataView()  -- or your existing handle
local value = dataView:getSize()
print("DataView:getSize ->", value)

-- ── DataWriter methods ──

--@api-stub: DataWriter:writeU8
-- Writes an unsigned 8-bit integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeU8(v)
print("DataWriter:writeU8 done")

--@api-stub: DataWriter:writeI8
-- Writes a signed 8-bit integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeI8(v)
print("DataWriter:writeI8 done")

--@api-stub: DataWriter:writeU16LE
-- Writes an unsigned 16-bit LE integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeU16LE(v)
print("DataWriter:writeU16LE done")

--@api-stub: DataWriter:writeU16BE
-- Writes an unsigned 16-bit BE integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeU16BE(v)
print("DataWriter:writeU16BE done")

--@api-stub: DataWriter:writeI16LE
-- Writes a signed 16-bit LE integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeI16LE(v)
print("DataWriter:writeI16LE done")

--@api-stub: DataWriter:writeU32LE
-- Writes an unsigned 32-bit LE integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeU32LE(v)
print("DataWriter:writeU32LE done")

--@api-stub: DataWriter:writeI32LE
-- Writes a signed 32-bit LE integer.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeI32LE(v)
print("DataWriter:writeI32LE done")

--@api-stub: DataWriter:writeF32LE
-- Writes a 32-bit LE float.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeF32LE(v)
print("DataWriter:writeF32LE done")

--@api-stub: DataWriter:writeF64LE
-- Writes a 64-bit LE float.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeF64LE(v)
print("DataWriter:writeF64LE done")

--@api-stub: DataWriter:writeString
-- Writes a length-prefixed UTF-8 string (4-byte LE length + bytes).
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeString(s)
print("DataWriter:writeString done")

--@api-stub: DataWriter:writeBytes
-- Writes raw bytes from a Lua string.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:writeBytes()
print("DataWriter:writeBytes done")

--@api-stub: DataWriter:seek
-- Moves the write cursor to the given position.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:seek(pos)
print("DataWriter:seek done")

--@api-stub: DataWriter:tell
-- Returns the current write cursor position.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:tell()
print("DataWriter:tell done")

--@api-stub: DataWriter:len
-- Returns the total buffer length.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:len()
print("DataWriter:len done")

--@api-stub: DataWriter:toBytes
-- Returns the buffer contents as a Lua string.
-- See the module spec for detailed semantics.
local dataWriter = lurek.data.newDataWriter()
dataWriter:toBytes()
print("DataWriter:toBytes done")

-- ── mlua methods ──

--@api-stub: mlua:getSize
-- Get the size.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.data.newmlua()  -- or your existing handle
local value = mlua:getSize()
print("mlua:getSize ->", value)

--@api-stub: mlua:getString
-- Get the string representation.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.data.newmlua()  -- or your existing handle
local value = mlua:getString()
print("mlua:getString ->", value)

--@api-stub: mlua:getByte
-- Get a byte at the specified offset.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.data.newmlua()  -- or your existing handle
local value = mlua:getByte(offset)
print("mlua:getByte ->", value)

--@api-stub: mlua:setByte
-- Set a byte at the specified offset.
-- Apply at startup or in response to user input.
local mlua = lurek.data.newmlua()
mlua:setByte(offset, value)
print("mlua:setByte applied")

--@api-stub: mlua:clone
-- Clone the ByteData.
-- See the module spec for detailed semantics.
local mlua = lurek.data.newmlua()
mlua:clone()
print("mlua:clone done")

