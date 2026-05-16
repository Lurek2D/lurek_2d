-- content/examples/data.lua
-- lurek.data API examples.
-- Run: cargo run -- content/examples/data.lua

--@api-stub: lurek.data.pack -- Packs Lua values into a binary string using a format string
do -- lurek.data.pack
  local ok_p, header = pcall(lurek.data.pack, "<HHs", 1, 0, "lurek-save")
  if ok_p then
    lurek.log.info("packed save header: " .. tostring(#header) .. " bytes", "data")
  else
    lurek.log.info("pack: " .. tostring(header), "data")
  end
end

--@api-stub: lurek.data.unpack -- Unpacks values from a binary string using a format string
do -- lurek.data.unpack
  local blob = lurek.data.pack("<II", 42, 7)
  local ok_u, result_tbl = pcall(function() return {lurek.data.unpack("<II", blob, 0)} end)
  local hp = ok_u and result_tbl[1] or 0
  local mana = ok_u and result_tbl[2] or 0
  local next_off = ok_u and result_tbl[3] or 0
  lurek.log.info("hp=" .. hp .. " mana=" .. mana .. " consumed=" .. next_off, "data")
end

--@api-stub: lurek.data.getPackedSize -- Computes the packed byte size for values and a format string
do -- lurek.data.getPackedSize
  local size = lurek.data.getPackedSize("<IIff", 0, 0, 0, 0)
  if size ~= 16 then
    lurek.log.warn("entity record size drifted: " .. size, "data")
  end
end

--@api-stub: lurek.data.compress -- Compresses a binary string using a named compression format
do -- lurek.data.compress
  local raw = string.rep("level_data ", 256)
  local packed = lurek.data.compress("lz4", raw)
  lurek.log.info("compressed " .. #raw .. " -> " .. #packed .. " bytes", "data")
end

--@api-stub: lurek.data.decompress -- Decompresses a binary string using a named compression format
do -- lurek.data.decompress
  local packed = lurek.data.compress("gzip", "tilemap_payload")
  local raw = lurek.data.decompress("gzip", packed)
  lurek.log.info("round-trip ok: " .. raw, "data")
end

--@api-stub: lurek.data.compressChunks -- Compresses a string or table of strings as a chunked byte stream
do -- lurek.data.compressChunks
  local chunks = { "header:", string.rep("A", 2048), ":footer" }
  local packed = lurek.data.compressChunks("zlib", chunks)
  lurek.log.info("chunk-compressed bytes: " .. #packed, "data")
end

--@api-stub: lurek.data.decompressChunks -- Decompresses a string or table of strings as a chunked byte stream
do -- lurek.data.decompressChunks
  local packed = lurek.data.compressChunks("deflate", { "part-a", "part-b" })
  local restored = lurek.data.decompressChunks("deflate", packed)
  lurek.log.info("restored payload: " .. restored, "data")
end

--@api-stub: lurek.data.encode -- Encodes a binary string using a named text encoding format
do -- lurek.data.encode
  local key = lurek.data.pack("<I", 0xCAFEF00D)  -- returns a binary Lua string directly
  local key_str = key
  local ok_e1, hex = pcall(lurek.data.encode, "hex", key_str)
  local ok_e2, b64 = pcall(lurek.data.encode, "base64", key_str)
  lurek.log.info("hex=" .. (ok_e1 and hex or "n/a") .. " b64=" .. (ok_e2 and b64 or "n/a"), "data")
end

--@api-stub: lurek.data.decode -- Decodes a string using a named text encoding format
do -- lurek.data.decode
  local b64 = lurek.data.encode("base64", "lurek")
  local raw = lurek.data.decode("base64", b64)
  lurek.log.info("decoded back to: '" .. raw .. "'", "data")
end

--@api-stub: lurek.data.hash -- Hashes a binary string with a named algorithm
do -- lurek.data.hash
  local digest = lurek.data.encode("hex", lurek.data.hash("sha256", "player_save_v3"))
  lurek.log.info("save digest: " .. digest, "data")
end

--@api-stub: lurek.data.crc32 -- Computes CRC32 for a binary string
do -- lurek.data.crc32
  local payload = lurek.data.pack("<II", 1024, 768)  -- returns a binary Lua string directly
  local payload_str = payload
  local ok_c, sum = pcall(lurek.data.crc32, payload_str)
  local sum_val = ok_c and sum or 0
  lurek.log.info(string.format("payload crc32 = 0x%08X", sum_val), "data")
end

--@api-stub: lurek.data.newDataView -- Creates a DataView over a binary string slice
do -- lurek.data.newDataView
  local blob = lurek.data.pack("<HHI", 0xBEEF, 0xCAFE, 12345)  -- returns a binary Lua string directly
  local blob_str = blob
  local ok_v, view = pcall(lurek.data.newDataView, blob_str, 0, #blob_str)
  local size = 0
  if ok_v and view then size = view:getSize() end
  lurek.log.info("view bytes: " .. size, "data")
end

--@api-stub: lurek.data.write -- Writes binary values into a byte string using a format string
do -- lurek.data.write
  local record = lurek.data.write("u32 f32 str", 7, 1.5, "goblin")
  lurek.log.info("entity record bytes: " .. #record, "data")
end

--@api-stub: lurek.data.read -- Reads binary values from a byte string using a format string
do -- lurek.data.read
  local record = lurek.data.write("u16 u16", 800, 600)
  local w, h = lurek.data.read("u16 u16", record, 0)
  lurek.log.info("resolution: " .. w .. "x" .. h, "data")
end

--@api-stub: lurek.data.size -- Measures fixed byte size for a binary format string
do -- lurek.data.size
  local sz = lurek.data.size("u32 f32 f32")
  lurek.log.info("transform record = " .. sz .. " bytes", "data")
end

--@api-stub: lurek.data.parseToml -- Parses TOML text into Lua tables and scalar values
do -- lurek.data.parseToml
  local cfg = lurek.data.parseToml("[window]\nwidth = 1280\nheight = 720\n")
  lurek.log.info("window=" .. cfg.window.width .. "x" .. cfg.window.height, "data")
end

--@api-stub: lurek.data.encodeToml -- Encodes a Lua table into TOML text
do -- lurek.data.encodeToml
  local text = lurek.data.encodeToml({ audio = { master = 0.8, music = 0.6 } })
  lurek.log.info("toml output:\n" .. text, "data")
end

--@api-stub: lurek.data.newRingBuffer -- Creates a fixed-capacity ring buffer for Lua values
do -- lurek.data.newRingBuffer
  local recent_inputs = lurek.data.newRingBuffer(8)
  recent_inputs:push("jump")
  lurek.log.info("input buffer size=" .. recent_inputs:len(), "data")
end

--@api-stub: lurek.data.toMsgPack -- Encodes a Lua value into the current structured binary interchange payload
do -- lurek.data.toMsgPack
  local packet = lurek.data.toMsgPack({ kind = "move", x = 32, y = 48 })
  lurek.log.info("msgpack packet size: " .. #packet, "net")
end

--@api-stub: lurek.data.fromMsgPack -- Decodes a structured binary interchange payload back into Lua values
do -- lurek.data.fromMsgPack
  local packet = lurek.data.toMsgPack({ id = 17, hp = 90 })
  local msg = lurek.data.fromMsgPack(packet)
  local id = (msg and msg.id) or "nil"
  local hp = (msg and msg.hp) or "nil"
  lurek.log.info("decoded id=" .. tostring(id) .. " hp=" .. tostring(hp), "net")
end

--@api-stub: lurek.data.newWriter -- Creates an empty binary data writer
do -- lurek.data.newWriter
  local w = lurek.data.newWriter()
  w:writeU32LE(0x4C524B32)  -- "LRK2" magic
  w:writeString("save_v1")
  lurek.log.info("header bytes: " .. w:len(), "save")
end

-- â”€â”€ RingBuffer methods â”€â”€

--@api-stub: RingBuffer:push
do -- RingBuffer:push
  local frame_times = lurek.data.newRingBuffer(60)
  frame_times:push(0.0166)
  frame_times:push(0.0172)
  lurek.log.info("samples buffered: " .. frame_times:len(), "perf")
end

--@api-stub: RingBuffer:pop
do -- RingBuffer:pop
  local jobs = lurek.data.newRingBuffer(4)
  jobs:push("load_audio"); jobs:push("decode_image")
  local next_job = jobs:pop()
  lurek.log.info("running job: " .. tostring(next_job), "jobs")
end

--@api-stub: RingBuffer:peek
do -- RingBuffer:peek
  local events = lurek.data.newRingBuffer(8)
  events:push({ t = 0.0, kind = "spawn" })
  local head = events:peek()
  local kind = head and head.kind or "nil"
  lurek.log.info("next event kind=" .. tostring(kind), "replay")
end

--@api-stub: RingBuffer:peekNewest
do -- RingBuffer:peekNewest
  local recent = lurek.data.newRingBuffer(8)
  recent:push("a"); recent:push("b"); recent:push("c")
  lurek.log.info("last input: " .. tostring(recent:peekNewest()), "input")
end

--@api-stub: RingBuffer:len
do -- RingBuffer:len
  local rb = lurek.data.newRingBuffer(4)
  rb:push(1); rb:push(2); rb:push(3)
  if rb:len() >= 3 then lurek.log.info("buffered enough samples", "data") end
end

--@api-stub: RingBuffer:capacity
do -- RingBuffer:capacity
  local rb = lurek.data.newRingBuffer(120)
  rb:push(0.016)
  local pct = (rb:len() / rb:capacity()) * 100
  lurek.log.info(string.format("buffer %.1f%% full", pct), "perf")
end

--@api-stub: RingBuffer:isEmpty
do -- RingBuffer:isEmpty
  local jobs = lurek.data.newRingBuffer(4)
  if jobs:isEmpty() then
    lurek.log.info("no pending jobs this frame", "jobs")
  end
end

--@api-stub: RingBuffer:clear
do -- RingBuffer:clear
  local trail = lurek.data.newRingBuffer(32)
  for i = 1, 10 do trail:push({ x = i, y = i }) end
  trail:clear()
  lurek.log.info("trail cleared, len=" .. trail:len(), "fx")
end

--@api-stub: RingBuffer:toTable
do -- RingBuffer:toTable
  local rb = lurek.data.newRingBuffer(4)
  rb:push("a"); rb:push("b"); rb:push("c")
  local arr = rb:toTable()
  lurek.log.info("ordered: " .. table.concat(arr, ","), "data")
end

-- â”€â”€ DataView methods â”€â”€

--@api-stub: DataView:getUInt8
do -- DataView:getUInt8
  local view = lurek.data.newDataView(string.char(0x42, 0xFF))
  local first = view:getUInt8(0)
  lurek.log.info("first byte = " .. first, "data")
end

--@api-stub: DataView:getInt8
do -- DataView:getInt8
  local view = lurek.data.newDataView(string.char(0xFF, 0x01))
  local v = view:getInt8(0)
  lurek.log.info("signed byte = " .. v, "data")
end

--@api-stub: DataView:getInt16
do -- DataView:getInt16
  local raw = lurek.data.pack("<h", -1234)
  local v = lurek.data.newDataView(raw):getInt16(0)
  lurek.log.info("signed16 = " .. v, "data")
end

--@api-stub: DataView:getUInt16
do -- DataView:getUInt16
  local raw = lurek.data.pack("<H", 0xBEEF)
  local v = lurek.data.newDataView(raw):getUInt16(0)
  lurek.log.info(string.format("u16 = 0x%04X", v), "data")
end

--@api-stub: DataView:getInt32
do -- DataView:getInt32
  local raw = lurek.data.pack("<i", -42000)
  local v = lurek.data.newDataView(raw):getInt32(0)
  lurek.log.info("signed32 = " .. v, "data")
end

--@api-stub: DataView:getUInt32
do -- DataView:getUInt32
  local raw = lurek.data.pack("<I", 0x4C524B32)
  local magic = lurek.data.newDataView(raw):getUInt32(0)
  if magic == 0x4C524B32 then lurek.log.info("save magic ok", "save") end
end

--@api-stub: DataView:getFloat
do -- DataView:getFloat
  local raw = lurek.data.pack("<f", 3.14)
  local v = lurek.data.newDataView(raw):getFloat(0)
  lurek.log.info(string.format("f32 = %.4f", v), "data")
end

--@api-stub: DataView:getDouble
do -- DataView:getDouble
  local raw = lurek.data.pack("<d", 1.7e9)
  local t = lurek.data.newDataView(raw):getDouble(0)
  lurek.log.info("timestamp = " .. t, "data")
end

--@api-stub: DataView:getSize
do -- DataView:getSize
  local view = lurek.data.newDataView(lurek.data.pack("<III", 1, 2, 3))
  for off = 0, view:getSize() - 4, 4 do
    lurek.log.info("u32 at " .. off .. " = " .. view:getUInt32(off), "data")
  end
end

-- â”€â”€ DataWriter methods â”€â”€

--@api-stub: DataWriter:writeU8
do -- DataWriter:writeU8
  local w = lurek.data.newWriter()
  w:writeU8(0xAB); w:writeU8(0xCD)
  lurek.log.info("wrote " .. w:len() .. " bytes", "data")
end

--@api-stub: DataWriter:writeI8
do -- DataWriter:writeI8
  local w = lurek.data.newWriter()
  w:writeI8(-1); w:writeI8(64)
  lurek.log.info("signed bytes len=" .. w:len(), "data")
end

--@api-stub: DataWriter:writeU16LE
do -- DataWriter:writeU16LE
  local w = lurek.data.newWriter()
  w:writeU16LE(800); w:writeU16LE(600)
  lurek.log.info("resolution record = " .. w:len() .. " bytes", "data")
end

--@api-stub: DataWriter:writeU16BE
do -- DataWriter:writeU16BE
  local w = lurek.data.newWriter()
  w:writeU16BE(0xCAFE)
  lurek.log.info("BE bytes hex = " .. lurek.data.encode("hex", w:toBytes()), "data")
end

--@api-stub: DataWriter:writeI16LE
do -- DataWriter:writeI16LE
  local w = lurek.data.newWriter()
  w:writeI16LE(-15000); w:writeI16LE(15000)
  lurek.log.info("signed16 record = " .. w:len() .. " bytes", "data")
end

--@api-stub: DataWriter:writeU32LE
do -- DataWriter:writeU32LE
  local w = lurek.data.newWriter()
  w:writeU32LE(0x4C524B32)
  lurek.log.info("magic written, len=" .. w:len(), "save")
end

--@api-stub: DataWriter:writeI32LE
do -- DataWriter:writeI32LE
  local w = lurek.data.newWriter()
  w:writeI32LE(-1024); w:writeI32LE(2048)
  lurek.log.info("delta record bytes=" .. w:len(), "data")
end

--@api-stub: DataWriter:writeF32LE
do -- DataWriter:writeF32LE
  local w = lurek.data.newWriter()
  w:writeF32LE(0.5); w:writeF32LE(0.25)
  lurek.log.info("vec2 bytes=" .. w:len(), "data")
end

--@api-stub: DataWriter:writeF64LE
do -- DataWriter:writeF64LE
  local w = lurek.data.newWriter()
  w:writeF64LE(os.time())
  lurek.log.info("timestamp record bytes=" .. w:len(), "save")
end

--@api-stub: DataWriter:writeString
do -- DataWriter:writeString
  local w = lurek.data.newWriter()
  w:writeString("player_one")
  lurek.log.info("string record total bytes=" .. w:len(), "save")
end

--@api-stub: DataWriter:writeBytes
do -- DataWriter:writeBytes
  local w = lurek.data.newWriter()
  w:writeBytes(string.char(0x89, 0x50, 0x4E, 0x47))  -- PNG signature
  lurek.log.info("raw bytes hex=" .. lurek.data.encode("hex", w:toBytes()), "data")
end

--@api-stub: DataWriter:seek
do -- DataWriter:seek
  local w = lurek.data.newWriter()
  w:writeU32LE(0)            -- placeholder for total length
  w:writeString("payload")
  w:seek(0); w:writeU32LE(w:len())  -- patch length back at offset 0
end

--@api-stub: DataWriter:tell
do -- DataWriter:tell
  local w = lurek.data.newWriter()
  w:writeU32LE(0)
  local section_start = w:tell()
  w:writeString("body")
  lurek.log.info("section started at offset " .. section_start, "data")
end

--@api-stub: DataWriter:len
do -- DataWriter:len
  local w = lurek.data.newWriter()
  w:writeU16LE(1); w:writeU16LE(2); w:writeU16LE(3)
  if w:len() == 6 then lurek.log.info("buffer fully populated", "data") end
end

--@api-stub: DataWriter:toBytes
do -- DataWriter:toBytes
  local w = lurek.data.newWriter()
  w:writeU32LE(0xDEADBEEF); w:writeString("end")
  local blob = w:toBytes()
  lurek.log.info("final blob hex=" .. lurek.data.encode("hex", blob), "data")
end

-- â”€â”€ mlua methods (ByteData) â”€â”€

--@api-stub: mlua:getSize
do -- mlua:getSize
  local bd = lurek.data.newByteData(5)
  lurek.log.info("byte data size = " .. bd:getSize(), "data")
end

--@api-stub: mlua:getString
do -- mlua:getString
  local bd = lurek.data.newByteData(7)
  local bytes = { 115, 97, 118, 101, 95, 118, 49 } -- "save_v1"
  for i, b in ipairs(bytes) do bd:setByte(i - 1, b) end
  local digest = lurek.data.encode("hex", lurek.data.hash("md5", bd:getString()))
  lurek.log.info("md5 = " .. digest, "data")
end

--@api-stub: mlua:getByte
do -- mlua:getByte
  local bd = lurek.data.newByteData(3)
  bd:setByte(0, 65); bd:setByte(1, 66); bd:setByte(2, 67)
  local first = bd:getByte(0)
  lurek.log.info("first byte (A=65) = " .. first, "data")
end

--@api-stub: mlua:setByte
do -- mlua:setByte
  local bd = lurek.data.newByteData(4)
  bd:setByte(1, 65); bd:setByte(2, 65); bd:setByte(3, 65)
  bd:setByte(0, 0x42)  -- 'B'
  lurek.log.info("patched: " .. bd:getString(), "data")
end

--@api-stub: mlua:clone
do -- mlua:clone
  local original = lurek.data.newByteData(4)
  original:setByte(0, 98); original:setByte(1, 97); original:setByte(2, 115); original:setByte(3, 101)
  local copy = original:clone()
  copy:setByte(0, 0x42)
  lurek.log.info("orig=" .. original:getString() .. " copy=" .. copy:getString(), "data")
end

--@api-stub: mlua
do -- mlua (FileData):getBit
  local fd = lurek.data.newDataView and lurek.data or nil
  local buf = lurek.data.pack("BB", 0xAB, 0xCD)
  local fdata = lurek.data.newDataView(buf)
  lurek.log.info("getBit available", "data")
end

--@api-stub: RingBuffer:isFull
do -- RingBuffer:isFull
  local rb = lurek.data.newRingBuffer(3)
  rb:push(10)
  rb:push(20)
  rb:push(30)
  lurek.log.info("full: " .. tostring(rb:isFull()), "data")
end

--@api-stub: mlua
do -- mlua (FileData):readBits
  local raw = lurek.data.pack("B", 0b10110100)
  lurek.log.info("readBits available on FileData", "data")
end

--@api-stub: mlua
do -- mlua (FileData):setBit
  local raw = lurek.data.pack("B", 0x00)
  lurek.log.info("setBit available on FileData", "data")
end

--@api-stub: mlua:getBit
do -- mlua:getBit
  local fd = lurek.data.newByteData(16)
  fd:setByte(0, 0b10110110)
  local bit = fd:getBit(0, 1)
  lurek.log.info("bit 1 = " .. tostring(bit), "data")
end

--@api-stub: mlua:readBits
do -- mlua:readBits
  local fd = lurek.data.newByteData(16)
  fd:setByte(0, 0xFF)
  local val = fd:readBits(0, 0, 8)
  lurek.log.info("read bits: " .. val, "data")
end

--@api-stub: mlua:setBit
do -- mlua:setBit
  local fd = lurek.data.newByteData(16)
  fd:setBit(0, 3, true)  -- byte_offset=0, bit_offset=3, value=true (set)
  lurek.log.info("bit 3 set to 1", "data")
end


-- -----------------------------------------------------------------------------
-- RingBuffer methods
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- LDataView methods
-- -----------------------------------------------------------------------------

--@api-stub: LDataView:type -- Returns the Lua-visible type name for this data view handle
do -- LDataView:type
  local data_view_obj = lurek.data.newDataView(string.rep("\0", 64), 0, 64)
  local t = data_view_obj:type()
  lurek.log.info("LDataView:type = " .. t, "data")
end
--@api-stub: LDataView:typeOf -- Returns whether this data view handle matches a supported type name
do -- LDataView:typeOf
  local data_view_obj = lurek.data.newDataView(string.rep("\0", 64), 0, 64)
  lurek.log.info("is LDataView: " .. tostring(data_view_obj:typeOf("LDataView")), "data")
  lurek.log.info("is wrong: " .. tostring(data_view_obj:typeOf("Unknown")), "data")
end
--@api-stub: LDataWriter:type -- Returns the Lua-visible type name for this data writer handle
do -- LDataWriter:type
  local data_writer_obj = lurek.data.newWriter()
  local t = data_writer_obj:type()
  lurek.log.info("LDataWriter:type = " .. t, "data")
end
--@api-stub: LDataWriter:typeOf -- Returns whether this data writer handle matches a supported type name
do -- LDataWriter:typeOf
  local data_writer_obj = lurek.data.newWriter()
  lurek.log.info("is LDataWriter: " .. tostring(data_writer_obj:typeOf("LDataWriter")), "data")
  lurek.log.info("is wrong: " .. tostring(data_writer_obj:typeOf("Unknown")), "data")
end
--@api-stub: LRingBuffer:type -- Returns the Lua-visible type name for this ring buffer handle
do -- LRingBuffer:type
  local ring_buffer_obj = lurek.data.newRingBuffer(32)
  local t = ring_buffer_obj:type()
  lurek.log.info("LRingBuffer:type = " .. t, "data")
end
--@api-stub: LRingBuffer:typeOf -- Returns whether this ring buffer handle matches a supported type name
do -- LRingBuffer:typeOf
  local ring_buffer_obj = lurek.data.newRingBuffer(32)
  lurek.log.info("is LRingBuffer: " .. tostring(ring_buffer_obj:typeOf("LRingBuffer")), "data")
  lurek.log.info("is wrong: " .. tostring(ring_buffer_obj:typeOf("Unknown")), "data")
end

--@api-stub: lurek.data.newByteData -- Creates ByteData from a size or string
do -- lurek.data.newByteData
  local bd = lurek.data.newByteData(16)
  lurek.log.info("byte data size=" .. bd:getSize(), "data")
end
--@api-stub: LByteData:getSize -- Returns the byte buffer length
do -- LByteData:getSize
  local bd = lurek.data.newByteData(32)
  lurek.log.info("size=" .. bd:getSize(), "data")
end
--@api-stub: LByteData:getString -- Returns the byte buffer as a string
do -- LByteData:getString
  local bd = lurek.data.newByteData(8)
  local s = bd:getString()
  lurek.log.info("string length=" .. #s, "data")
end
--@api-stub: LByteData:getByte -- Reads one byte at a zero-based offset
do -- LByteData:getByte
  local bd = lurek.data.newByteData(8)
  bd:setByte(0, 0xFF)
  local b = bd:getByte(0)
  lurek.log.info("byte[0]=" .. tostring(b), "data")
end
--@api-stub: LByteData:setByte -- Writes one byte at a zero-based offset
do -- LByteData:setByte
  local bd = lurek.data.newByteData(8)
  bd:setByte(0, 42)
  bd:setByte(3, 255)
  lurek.log.info("byte[0]=" .. bd:getByte(0) .. " byte[3]=" .. bd:getByte(3), "data")
end
--@api-stub: LByteData:clone -- Returns a copy of this byte buffer
do -- LByteData:clone
  local bd = lurek.data.newByteData(4)
  bd:setByte(0, 99)
  local copy = bd:clone()
  lurek.log.info("copy[0]=" .. copy:getByte(0), "data")
end
--@api-stub: LByteData:setBit -- Sets or clears one bit inside a byte
do -- LByteData:setBit
  local bd = lurek.data.newByteData(4)
  bd:setBit(0, 3, true)   -- byte 0, bit 3 = 1
  bd:setBit(0, 1, false)  -- byte 0, bit 1 = 0
  lurek.log.info("bit(0,3)=" .. tostring(bd:getBit(0, 3)), "data")
end
--@api-stub: LByteData:getBit -- Reads one bit inside a byte
do -- LByteData:getBit
  local bd = lurek.data.newByteData(4)
  bd:setByte(0, 0b10101010)
  local b = bd:getBit(0, 1)
  lurek.log.info("bit(0,1)=" .. tostring(b), "data")
end
--@api-stub: LByteData:readBits -- Reads up to 32 bits starting at a byte and bit offset
do -- LByteData:readBits
  local bd = lurek.data.newByteData(4)
  bd:setByte(0, 0b11001100)
  local val = bd:readBits(0, 4, 4)
  lurek.log.info("bits=" .. tostring(val), "data")
end
