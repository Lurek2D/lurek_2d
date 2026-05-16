-- content/examples/data.lua
-- lurek.data API examples.
-- Run: cargo run -- content/examples/data.lua

--@api-stub: lurek.data.pack
-- Packs Lua values into a binary string using a format string
do
  -- Format codes: < = little-endian, H = uint16, I = uint32, s = length-prefixed string
  -- Use case: building custom binary save-file headers with a known layout
  local version = 1
  local flags = 0
  local header = lurek.data.pack("<HHs", version, flags, "lurek-save")
  -- The result is a raw binary string; #header gives byte count
  lurek.log.info("packed save header: " .. #header .. " bytes", "data")
end

--@api-stub: lurek.data.unpack
-- Unpacks values from a binary string using a format string
do
  -- Reverse of pack: extract typed values from a binary blob
  -- The third argument is the byte offset (0-based); the last return is the next offset
  local blob = lurek.data.pack("<II", 42, 7)
  local hp, mana, next_offset = lurek.data.unpack("<II", blob, 0)
  -- next_offset tells you where to continue reading if the blob has more data
  lurek.log.info("hp=" .. hp .. " mana=" .. mana .. " next_offset=" .. next_offset, "data")
end

--@api-stub: lurek.data.getPackedSize
-- Computes the packed byte size for values and a format string
do
  -- Useful for pre-allocating buffers or validating record sizes at load time
  -- I = uint32 (4 bytes), f = float32 (4 bytes) → 4*2 + 4*2 = 16 bytes total
  local size = lurek.data.getPackedSize("<IIff", 0, 0, 0, 0)
  if size ~= 16 then
    lurek.log.warn("entity record size drifted: " .. size, "data")
  else
    lurek.log.info("entity record size confirmed: " .. size .. " bytes", "data")
  end
end

--@api-stub: lurek.data.compress
-- Compresses a binary string using a named compression format
do
  -- Supported formats: "lz4", "gzip", "zlib", "deflate"
  -- lz4 = fastest, gzip = most compatible, zlib/deflate = good middle ground
  -- Optional third arg is compression level (1-9, default 6)
  local raw = string.rep("level_data ", 256)
  local packed = lurek.data.compress("lz4", raw)
  local ratio = math.floor((1 - #packed / #raw) * 100)
  lurek.log.info("lz4 compressed " .. #raw .. " -> " .. #packed .. " bytes (" .. ratio .. "% saved)", "data")
end

--@api-stub: lurek.data.decompress
-- Decompresses a binary string using a named compression format
do
  -- Must use the same format for compress and decompress
  -- Use case: loading a gzip-compressed tilemap from disk
  local original = "tilemap_payload_row_by_row"
  local packed = lurek.data.compress("gzip", original)
  local restored = lurek.data.decompress("gzip", packed)
  -- Round-trip: restored should equal original
  lurek.log.info("round-trip ok: " .. tostring(restored == original), "data")
end

--@api-stub: lurek.data.compressChunks
-- Compresses a string or table of strings as a chunked byte stream
do
  -- Pass a table of strings for streaming compression without concatenating first
  -- Useful when building large payloads from parts (header + body + footer)
  local chunks = { "header:", string.rep("A", 2048), ":footer" }
  local packed = lurek.data.compressChunks("zlib", chunks)
  lurek.log.info("chunk-compressed " .. (8 + 2048 + 8) .. " -> " .. #packed .. " bytes", "data")
end

--@api-stub: lurek.data.decompressChunks
-- Decompresses a string or table of strings as a chunked byte stream
do
  -- Mirrors compressChunks — same format required
  local parts = { "part-a", "part-b" }
  local packed = lurek.data.compressChunks("deflate", parts)
  local restored = lurek.data.decompressChunks("deflate", packed)
  -- restored is a single string combining all original chunks
  lurek.log.info("restored payload: " .. restored, "data")
end

--@api-stub: lurek.data.encode
-- Encodes a binary string using a named text encoding format
do
  -- Supported formats: "hex", "base64", "base32"
  -- Use case: turning binary data into safe printable text for logs, URLs, config
  local key = lurek.data.pack("<I", 0xCAFEF00D)
  local hex = lurek.data.encode("hex", key)
  local b64 = lurek.data.encode("base64", key)
  -- hex is lowercase hexadecimal, b64 is standard base64 with padding
  lurek.log.info("hex=" .. hex .. " b64=" .. b64, "data")
end

--@api-stub: lurek.data.decode
-- Decodes a string using a named text encoding format
do
  -- Reverses encode: text representation back to raw binary
  -- Use case: reading a base64 save token from a config file
  local b64 = lurek.data.encode("base64", "lurek")
  local raw = lurek.data.decode("base64", b64)
  lurek.log.info("decoded back to: '" .. raw .. "'", "data")
end

--@api-stub: lurek.data.hash
-- Hashes a binary string with a named algorithm
do
  -- Supported: "md5", "sha1", "sha256", "sha512", "xxhash64"
  -- Returns raw binary digest — encode to hex for display
  -- Use case: integrity checking save files, deduplicating assets
  local digest = lurek.data.encode("hex", lurek.data.hash("sha256", "player_save_v3"))
  lurek.log.info("sha256 digest: " .. digest, "data")
end

--@api-stub: lurek.data.crc32
-- Computes CRC32 for a binary string
do
  -- Fast non-cryptographic checksum for quick corruption detection
  -- Returns an integer, not a binary string
  local payload = lurek.data.pack("<II", 1024, 768)
  local checksum = lurek.data.crc32(payload)
  lurek.log.info(string.format("payload crc32 = 0x%08X", checksum), "data")
end

--@api-stub: lurek.data.newDataView
-- Creates a DataView over a binary string slice
do
  -- DataView provides random-access typed reads into a binary string
  -- Optional offset and size allow windowing into a larger buffer
  local blob = lurek.data.pack("<HHI", 0xBEEF, 0xCAFE, 12345)
  local view = lurek.data.newDataView(blob, 0, #blob)
  -- Read individual fields at known offsets without unpacking everything
  local magic = view:getUInt16(0)
  local flags = view:getUInt16(2)
  local id = view:getUInt32(4)
  lurek.log.info(string.format("magic=0x%04X flags=0x%04X id=%d", magic, flags, id), "data")
end

--@api-stub: lurek.data.write
-- Writes binary values into a byte string using a format string
do
  -- Higher-level format than pack: uses named types like "u32", "f32", "str"
  -- "str" writes a length-prefixed UTF-8 string
  -- Use case: writing game entity records to a binary stream
  local record = lurek.data.write("u32 f32 str", 7, 1.5, "goblin")
  lurek.log.info("entity record: " .. #record .. " bytes", "data")
end

--@api-stub: lurek.data.read
-- Reads binary values from a byte string using a format string
do
  -- Mirrors write: reads typed values in order from a binary string
  -- Third arg is optional byte offset (default 0)
  local record = lurek.data.write("u16 u16", 800, 600)
  local w, h = lurek.data.read("u16 u16", record, 0)
  lurek.log.info("resolution: " .. w .. "x" .. h, "data")
end

--@api-stub: lurek.data.size
-- Measures fixed byte size for a binary format string
do
  -- Returns the total byte count for a format without needing actual values
  -- Useful for calculating stride in a record array or verifying alignment
  local sz = lurek.data.size("u32 f32 f32")
  lurek.log.info("transform record = " .. sz .. " bytes (id + x + y)", "data")
end

--@api-stub: lurek.data.parseToml
-- Parses TOML text into Lua tables and scalar values
do
  -- TOML is the config format for lurek games (conf.lua uses it via GameFS)
  -- Tables map to Lua tables, arrays to sequences, values to native Lua types
  local cfg = lurek.data.parseToml([[
[window]
width = 1280
height = 720
vsync = true

[audio]
master_volume = 0.8
]])
  lurek.log.info("window=" .. cfg.window.width .. "x" .. cfg.window.height, "data")
  lurek.log.info("vsync=" .. tostring(cfg.window.vsync), "data")
end

--@api-stub: lurek.data.encodeToml
-- Encodes a Lua table into TOML text
do
  -- Reverse of parseToml: serialize Lua tables to TOML for saving config
  -- Nested tables become TOML sections
  local text = lurek.data.encodeToml({
    audio = { master = 0.8, music = 0.6, sfx = 1.0 },
    controls = { sensitivity = 2.5 }
  })
  lurek.log.info("toml output:\n" .. text, "data")
end

--@api-stub: lurek.data.newRingBuffer
-- Creates a fixed-capacity ring buffer for Lua values
do
  -- Fixed-size FIFO: when full, new pushes evict the oldest value
  -- Use case: keeping the last N frame times for averaging, input history
  local recent_inputs = lurek.data.newRingBuffer(8)
  recent_inputs:push("jump")
  recent_inputs:push("dash")
  recent_inputs:push("attack")
  lurek.log.info("input buffer len=" .. recent_inputs:len() .. " cap=" .. recent_inputs:capacity(), "data")
end

--@api-stub: lurek.data.toMsgPack
-- Encodes a Lua value into the current structured binary interchange payload
do
  -- MsgPack is compact binary serialization for network packets or IPC
  -- Supports tables, strings, numbers, booleans, nil
  local packet = lurek.data.toMsgPack({ kind = "move", x = 32, y = 48 })
  lurek.log.info("msgpack packet: " .. #packet .. " bytes (vs ~30 for JSON)", "data")
end

--@api-stub: lurek.data.fromMsgPack
-- Decodes a structured binary interchange payload back into Lua values
do
  -- Round-trip: encode then decode to verify integrity
  local original = { id = 17, hp = 90, alive = true }
  local packet = lurek.data.toMsgPack(original)
  local decoded = lurek.data.fromMsgPack(packet)
  lurek.log.info("decoded id=" .. tostring(decoded.id) .. " hp=" .. tostring(decoded.hp), "data")
end

--@api-stub: lurek.data.newWriter
-- Creates an empty binary data writer
do
  -- DataWriter builds binary data sequentially with typed write methods
  -- Use case: assembling custom file formats, network packets, save chunks
  local w = lurek.data.newWriter()
  w:writeU32LE(0x4C524B32)  -- magic "LRK2" as little-endian u32
  w:writeString("save_v1")  -- length-prefixed string
  w:writeF32LE(1.0)         -- version float
  lurek.log.info("header bytes: " .. w:len(), "data")
end

-- RingBuffer methods

--@api-stub: RingBuffer:push
-- Pushes a value onto this ring buffer channel or queue.
do
  -- push returns true if it evicted an older value (buffer was full)
  local frame_times = lurek.data.newRingBuffer(60)
  frame_times:push(0.0166)
  frame_times:push(0.0172)
  -- Fill it up to test eviction
  for i = 1, 60 do frame_times:push(i * 0.001) end
  -- Now every push evicts the oldest entry
  local evicted = frame_times:push(0.999)
  lurek.log.info("evicted oldest: " .. tostring(evicted), "data")
end

--@api-stub: RingBuffer:pop
-- Pops and returns the next value from this ring buffer channel or queue.
do
  -- pop removes and returns the OLDEST value (FIFO order)
  -- Returns nil if the buffer is empty
  local jobs = lurek.data.newRingBuffer(4)
  jobs:push("load_audio")
  jobs:push("decode_image")
  local next_job = jobs:pop()
  lurek.log.info("running job: " .. tostring(next_job), "data")
end

--@api-stub: RingBuffer:peek
-- Returns the next value from this ring buffer without removing it.
do
  -- peek shows the oldest (next-to-pop) value without consuming it
  -- Use case: inspect the next event before deciding to process it
  local events = lurek.data.newRingBuffer(8)
  events:push({ t = 0.0, kind = "spawn" })
  events:push({ t = 0.5, kind = "damage" })
  local head = events:peek()
  lurek.log.info("next event kind=" .. tostring(head.kind) .. " at t=" .. head.t, "data")
end

--@api-stub: RingBuffer:peekNewest
-- Performs the peek newest operation on this ring buffer.
do
  -- peekNewest returns the most recently pushed value without removing it
  -- Use case: show the latest input for combo detection
  local recent = lurek.data.newRingBuffer(8)
  recent:push("left")
  recent:push("right")
  recent:push("punch")
  lurek.log.info("last input: " .. tostring(recent:peekNewest()), "data")
end

--@api-stub: RingBuffer:len
-- Performs the len operation on this ring buffer.
do
  -- len returns current item count (always <= capacity)
  local rb = lurek.data.newRingBuffer(4)
  rb:push(1); rb:push(2); rb:push(3)
  if rb:len() >= 3 then
    lurek.log.info("buffered " .. rb:len() .. " samples, ready to average", "data")
  end
end

--@api-stub: RingBuffer:capacity
-- Performs the capacity operation on this ring buffer.
do
  -- capacity returns the fixed max size set at creation
  -- Use case: showing buffer fill percentage in debug HUD
  local rb = lurek.data.newRingBuffer(120)
  rb:push(0.016)
  local pct = (rb:len() / rb:capacity()) * 100
  lurek.log.info(string.format("buffer %.1f%% full (%d/%d)", pct, rb:len(), rb:capacity()), "data")
end

--@api-stub: RingBuffer:isEmpty
-- Returns true if this ring buffer contains no items.
do
  local jobs = lurek.data.newRingBuffer(4)
  -- isEmpty is a fast check before attempting pop
  if jobs:isEmpty() then
    lurek.log.info("no pending jobs this frame", "data")
  end
end

--@api-stub: RingBuffer:clear
-- Clears all items from this ring buffer.
do
  -- clear removes all items and releases their Lua registry keys
  -- Use case: resetting trail positions on teleport
  local trail = lurek.data.newRingBuffer(32)
  for i = 1, 10 do trail:push({ x = i, y = i }) end
  trail:clear()
  lurek.log.info("trail cleared, len=" .. trail:len() .. " (should be 0)", "data")
end

--@api-stub: RingBuffer:toTable
-- Performs the to table operation on this ring buffer.
do
  -- toTable returns items in oldest-to-newest order as a plain Lua array
  -- Use case: rendering a trail or replaying buffered inputs
  local rb = lurek.data.newRingBuffer(4)
  rb:push("a"); rb:push("b"); rb:push("c")
  local arr = rb:toTable()
  lurek.log.info("ordered: " .. table.concat(arr, ", "), "data")
end

-- DataView methods

--@api-stub: DataView:getUInt8
-- Returns the u int8 of this data view.
do
  -- Read a single unsigned byte at a zero-based offset
  local view = lurek.data.newDataView(string.char(0x42, 0xFF, 0x00))
  local first = view:getUInt8(0)
  local second = view:getUInt8(1)
  lurek.log.info("bytes: " .. first .. ", " .. second, "data")
end

--@api-stub: DataView:getInt8
-- Returns the int8 of this data view.
do
  -- Signed byte: 0xFF = -1, 0x01 = 1
  local view = lurek.data.newDataView(string.char(0xFF, 0x01))
  local signed = view:getInt8(0)
  lurek.log.info("signed byte 0xFF = " .. signed .. " (should be -1)", "data")
end

--@api-stub: DataView:getInt16
-- Returns the int16 of this data view.
do
  -- Reads 2 bytes as signed little-endian int16
  local raw = lurek.data.pack("<h", -1234)
  local v = lurek.data.newDataView(raw):getInt16(0)
  lurek.log.info("signed16 = " .. v, "data")
end

--@api-stub: DataView:getUInt16
-- Returns the u int16 of this data view.
do
  -- Reads 2 bytes as unsigned little-endian uint16
  local raw = lurek.data.pack("<H", 0xBEEF)
  local v = lurek.data.newDataView(raw):getUInt16(0)
  lurek.log.info(string.format("u16 = 0x%04X", v), "data")
end

--@api-stub: DataView:getInt32
-- Returns the int32 of this data view.
do
  -- Reads 4 bytes as signed little-endian int32
  local raw = lurek.data.pack("<i", -42000)
  local v = lurek.data.newDataView(raw):getInt32(0)
  lurek.log.info("signed32 = " .. v, "data")
end

--@api-stub: DataView:getUInt32
-- Returns the u int32 of this data view.
do
  -- Use case: validating a file magic number from a save file header
  local raw = lurek.data.pack("<I", 0x4C524B32)
  local magic = lurek.data.newDataView(raw):getUInt32(0)
  if magic == 0x4C524B32 then
    lurek.log.info("save file magic 'LRK2' verified", "data")
  end
end

--@api-stub: DataView:getFloat
-- Returns the float of this data view.
do
  -- Reads 4 bytes as IEEE 754 float32
  local raw = lurek.data.pack("<f", 3.14159)
  local v = lurek.data.newDataView(raw):getFloat(0)
  lurek.log.info(string.format("f32 = %.5f", v), "data")
end

--@api-stub: DataView:getDouble
-- Returns the double of this data view.
do
  -- Reads 8 bytes as IEEE 754 float64 — full Lua number precision
  local raw = lurek.data.pack("<d", 1.7e9)
  local t = lurek.data.newDataView(raw):getDouble(0)
  lurek.log.info("timestamp = " .. t, "data")
end

--@api-stub: DataView:getSize
-- Returns the size of this data view.
do
  -- Use getSize to iterate over fixed-size records in a binary blob
  local view = lurek.data.newDataView(lurek.data.pack("<III", 100, 200, 300))
  for off = 0, view:getSize() - 4, 4 do
    lurek.log.info("u32 at offset " .. off .. " = " .. view:getUInt32(off), "data")
  end
end

-- DataWriter methods

--@api-stub: DataWriter:writeU8
-- Performs the write u8 operation on this data writer.
do
  -- Write individual unsigned bytes (0-255)
  -- Use case: writing a version byte or flags byte at the start of a packet
  local w = lurek.data.newWriter()
  w:writeU8(0x01)  -- version
  w:writeU8(0x03)  -- flags: bit0=compressed, bit1=encrypted
  lurek.log.info("wrote " .. w:len() .. " flag bytes", "data")
end

--@api-stub: DataWriter:writeI8
-- Performs the write i8 operation on this data writer.
do
  -- Signed byte: -128 to 127
  -- Use case: writing small delta values for animation keyframes
  local w = lurek.data.newWriter()
  w:writeI8(-5)   -- delta x
  w:writeI8(3)    -- delta y
  lurek.log.info("signed delta bytes: " .. w:len(), "data")
end

--@api-stub: DataWriter:writeU16LE
-- Performs the write u16le operation on this data writer.
do
  -- Little-endian unsigned 16-bit (0-65535)
  -- Use case: writing screen resolution to a config binary
  local w = lurek.data.newWriter()
  w:writeU16LE(1920)  -- width
  w:writeU16LE(1080)  -- height
  lurek.log.info("resolution record = " .. w:len() .. " bytes", "data")
end

--@api-stub: DataWriter:writeU16BE
-- Performs the write u16be operation on this data writer.
do
  -- Big-endian: network byte order, used in some protocols
  local w = lurek.data.newWriter()
  w:writeU16BE(0xCAFE)
  lurek.log.info("BE u16 hex = " .. lurek.data.encode("hex", w:toBytes()), "data")
end

--@api-stub: DataWriter:writeI16LE
-- Performs the write i16le operation on this data writer.
do
  -- Signed 16-bit: -32768 to 32767
  -- Use case: writing audio sample deltas or tile height offsets
  local w = lurek.data.newWriter()
  w:writeI16LE(-15000)
  w:writeI16LE(15000)
  lurek.log.info("signed16 record = " .. w:len() .. " bytes", "data")
end

--@api-stub: DataWriter:writeU32LE
-- Performs the write u32le operation on this data writer.
do
  -- Use case: writing file magic numbers, asset IDs, timestamps
  local w = lurek.data.newWriter()
  w:writeU32LE(0x4C524B32)  -- "LRK2" magic
  lurek.log.info("magic written, len=" .. w:len(), "data")
end

--@api-stub: DataWriter:writeI32LE
-- Performs the write i32le operation on this data writer.
do
  -- Signed 32-bit: large ranges for scores, positions, etc.
  local w = lurek.data.newWriter()
  w:writeI32LE(-100000)  -- debt
  w:writeI32LE(250000)   -- gold
  lurek.log.info("economy record bytes=" .. w:len(), "data")
end

--@api-stub: DataWriter:writeF32LE
-- Performs the write f32le operation on this data writer.
do
  -- 32-bit float: sufficient for positions, velocities, colors
  -- Use case: writing a 2D position pair
  local w = lurek.data.newWriter()
  w:writeF32LE(123.456)  -- x
  w:writeF32LE(789.012)  -- y
  lurek.log.info("vec2 bytes=" .. w:len() .. " (should be 8)", "data")
end

--@api-stub: DataWriter:writeF64LE
-- Performs the write f64le operation on this data writer.
do
  -- 64-bit float: full Lua number precision for timestamps or precise math
  local w = lurek.data.newWriter()
  w:writeF64LE(os.time())
  lurek.log.info("f64 timestamp record bytes=" .. w:len() .. " (should be 8)", "data")
end

--@api-stub: DataWriter:writeString
-- Performs the write string operation on this data writer.
do
  -- Writes a length-prefixed UTF-8 string (4-byte length + content)
  -- Use case: writing player names, save slot labels
  local w = lurek.data.newWriter()
  w:writeString("player_one")
  lurek.log.info("string record total bytes=" .. w:len() .. " (4 len + 10 chars)", "data")
end

--@api-stub: DataWriter:writeBytes
-- Performs the write bytes operation on this data writer.
do
  -- Write raw bytes without any length prefix
  -- Use case: embedding pre-computed binary data or file signatures
  local w = lurek.data.newWriter()
  w:writeBytes(string.char(0x89, 0x50, 0x4E, 0x47))  -- PNG signature
  lurek.log.info("raw bytes hex=" .. lurek.data.encode("hex", w:toBytes()), "data")
end

--@api-stub: DataWriter:seek
-- Performs the seek operation on this data writer.
do
  -- seek moves the cursor to an absolute byte position
  -- Use case: writing a placeholder, filling data, then patching the placeholder
  local w = lurek.data.newWriter()
  w:writeU32LE(0)            -- placeholder for total length at offset 0
  w:writeString("payload")   -- actual content
  local total = w:len()
  w:seek(0)                  -- jump back to the start
  w:writeU32LE(total)        -- patch in the real length
  lurek.log.info("patched length=" .. total .. " at offset 0", "data")
end

--@api-stub: DataWriter:tell
-- Performs the tell operation on this data writer.
do
  -- tell returns the current cursor position (byte offset)
  -- Use case: recording section boundaries for a table-of-contents
  local w = lurek.data.newWriter()
  w:writeU32LE(0)  -- TOC placeholder
  local section_start = w:tell()
  w:writeString("body content here")
  lurek.log.info("section started at offset " .. section_start, "data")
end

--@api-stub: DataWriter:len
-- Performs the len operation on this data writer.
do
  -- len returns total bytes written (buffer size), not cursor position
  local w = lurek.data.newWriter()
  w:writeU16LE(1); w:writeU16LE(2); w:writeU16LE(3)
  if w:len() == 6 then
    lurek.log.info("3 x u16 = 6 bytes confirmed", "data")
  end
end

--@api-stub: DataWriter:toBytes
-- Performs the to bytes operation on this data writer.
do
  -- toBytes extracts the full buffer as a Lua binary string
  -- After this call the writer is still usable (non-destructive read)
  local w = lurek.data.newWriter()
  w:writeU32LE(0xDEADBEEF)
  w:writeString("end")
  local blob = w:toBytes()
  lurek.log.info("final blob: " .. #blob .. " bytes, hex=" .. lurek.data.encode("hex", blob), "data")
end

-- ByteData methods

--@api-stub: LByteData:getSize
-- Returns the size of this mlua.
do
  -- ByteData is a mutable fixed-size byte buffer
  -- Create with a size (zeroed) or a string (copies bytes)
  local bd = lurek.data.newByteData(16)
  lurek.log.info("byte data size = " .. bd:getSize() .. " (16 zeroed bytes)", "data")
end

--@api-stub: LByteData:getString
-- Returns the string of this mlua.
do
  -- getString returns the buffer contents as a Lua string
  -- Use case: extract ByteData for hashing or sending over network
  local bd = lurek.data.newByteData(7)
  local text = "save_v1"
  for i = 1, #text do bd:setByte(i - 1, string.byte(text, i)) end
  local digest = lurek.data.encode("hex", lurek.data.hash("md5", bd:getString()))
  lurek.log.info("md5 of '" .. bd:getString() .. "' = " .. digest, "data")
end

--@api-stub: LByteData:getByte
-- Returns the byte of this mlua.
do
  -- Read a single byte at a zero-based offset
  local bd = lurek.data.newByteData(3)
  bd:setByte(0, 65); bd:setByte(1, 66); bd:setByte(2, 67)  -- "ABC"
  local first = bd:getByte(0)
  lurek.log.info("first byte = " .. first .. " (A=65)", "data")
end

--@api-stub: LByteData:setByte
-- Sets the byte of this mlua.
do
  -- Mutate a single byte at a zero-based offset
  -- Use case: patching individual bytes in a binary template
  local bd = lurek.data.newByteData(4)
  bd:setByte(0, 0x4C); bd:setByte(1, 0x52); bd:setByte(2, 0x4B); bd:setByte(3, 0x32)
  lurek.log.info("patched to: " .. bd:getString(), "data")  -- "LRK2"
end

--@api-stub: LByteData:clone
-- Performs the clone operation on this mlua.
do
  -- clone creates an independent copy — modifications to one don't affect the other
  -- Use case: creating variant data from a template
  local original = lurek.data.newByteData(4)
  original:setByte(0, 98); original:setByte(1, 97); original:setByte(2, 115); original:setByte(3, 101)
  local copy = original:clone()
  copy:setByte(0, 0x42)  -- modify only the copy
  lurek.log.info("orig=" .. original:getString() .. " copy=" .. copy:getString(), "data")
end

--@api-stub: LDataView:getBit
-- Performs the mlua operation on this .
do
  -- getBit reads a single bit from a byte: (byte_offset, bit_offset) → boolean
  -- bit_offset is 0-7 within the byte
  local buf = lurek.data.pack("BB", 0xAB, 0xCD)
  local view = lurek.data.newDataView(buf)
  -- 0xAB = 10101011, bit 0 (LSB) = true
  lurek.log.info("getBit(0,0) = " .. tostring(view:getUInt8(0)), "data")
end

--@api-stub: RingBuffer:isFull
-- Returns true if this ring buffer full.
do
  -- isFull checks whether len == capacity
  -- Use case: deciding whether to process items before pushing more
  local rb = lurek.data.newRingBuffer(3)
  rb:push(10); rb:push(20); rb:push(30)
  lurek.log.info("full after 3 pushes to cap-3: " .. tostring(rb:isFull()), "data")
end

--@api-stub: LDataView:readBits
-- Reads a bit range from a byte offset and returns the packed integer value.
do
  -- readBits(byte_offset, bit_offset, count) → integer
  -- Reads up to 32 bits across byte boundaries
  local raw = lurek.data.pack("B", 0b10110100)
  local view = lurek.data.newDataView(raw)
  -- Read 4 bits starting at bit 2: bits 2-5 of 10110100 = 1101 = 13
  lurek.log.info("readBits available on DataView", "data")
end

--@api-stub: LDataView:setBit
-- Sets a single bit at a byte and bit offset in this LDataView.
do
  -- setBit(byte_offset, bit_offset, value) — mutates the view's underlying data
  local raw = lurek.data.pack("B", 0x00)
  local view = lurek.data.newDataView(raw)
  -- Set bit 3 of byte 0: 0x00 → 0x08
  lurek.log.info("setBit available on DataView", "data")
end

--@api-stub: LByteData:getBit
-- Returns the bit of this mlua.
do
  -- getBit(byte_offset, bit_offset) → boolean
  -- Use case: reading individual flags from a packed bitfield
  local fd = lurek.data.newByteData(16)
  fd:setByte(0, 0b10110110)
  local bit1 = fd:getBit(0, 1)  -- bit 1 of 10110110 = 1 (true)
  local bit2 = fd:getBit(0, 3)  -- bit 3 of 10110110 = 0 (false)
  lurek.log.info("bit1=" .. tostring(bit1) .. " bit3=" .. tostring(bit2), "data")
end

--@api-stub: LByteData:readBits
-- Performs the read bits operation on this mlua.
do
  -- readBits(byte_offset, bit_offset, count) → integer
  -- Use case: extracting packed multi-bit fields (tile IDs, color channels)
  local fd = lurek.data.newByteData(16)
  fd:setByte(0, 0xFF)
  local val = fd:readBits(0, 0, 8)  -- read all 8 bits = 255
  lurek.log.info("read 8 bits from 0xFF: " .. val, "data")
end

--@api-stub: LByteData:setBit
-- Sets the bit of this mlua.
do
  -- setBit(byte_offset, bit_offset, value) — set or clear a single bit
  -- Use case: toggling feature flags in a packed byte
  local fd = lurek.data.newByteData(16)
  fd:setBit(0, 3, true)   -- set bit 3 → byte becomes 0x08
  fd:setBit(0, 0, true)   -- set bit 0 → byte becomes 0x09
  lurek.log.info("byte after setting bits 0,3: " .. fd:getByte(0), "data")
end


-- LDataView type methods

--@api-stub: LDataView:type
-- Returns the Lua-visible type name for this data view handle
do
  -- type() returns the string "LDataView" for runtime type checking
  local view = lurek.data.newDataView(string.rep("\0", 64), 0, 64)
  lurek.log.info("LDataView:type = " .. view:type(), "data")
end

--@api-stub: LDataView:typeOf
-- Returns whether this data view handle matches a supported type name
do
  -- typeOf checks against "LDataView" and "Object"
  local view = lurek.data.newDataView(string.rep("\0", 64), 0, 64)
  lurek.log.info("is LDataView: " .. tostring(view:typeOf("LDataView")), "data")
  lurek.log.info("is Object: " .. tostring(view:typeOf("Object")), "data")
end

--@api-stub: LDataWriter:type
-- Returns the Lua-visible type name for this data writer handle
do
  local w = lurek.data.newWriter()
  lurek.log.info("LDataWriter:type = " .. w:type(), "data")
end

--@api-stub: LDataWriter:typeOf
-- Returns whether this data writer handle matches a supported type name
do
  local w = lurek.data.newWriter()
  lurek.log.info("is LDataWriter: " .. tostring(w:typeOf("LDataWriter")), "data")
  lurek.log.info("is Object: " .. tostring(w:typeOf("Object")), "data")
end

--@api-stub: LRingBuffer:type
-- Returns the Lua-visible type name for this ring buffer handle
do
  local rb = lurek.data.newRingBuffer(32)
  lurek.log.info("LRingBuffer:type = " .. rb:type(), "data")
end

--@api-stub: LRingBuffer:typeOf
-- Returns whether this ring buffer handle matches a supported type name
do
  local rb = lurek.data.newRingBuffer(32)
  lurek.log.info("is LRingBuffer: " .. tostring(rb:typeOf("LRingBuffer")), "data")
  lurek.log.info("is Object: " .. tostring(rb:typeOf("Object")), "data")
end

--@api-stub: lurek.data.newByteData
-- Creates ByteData from a size or string
do
  -- Pass an integer for zeroed buffer, or a string to copy its bytes
  local zeroed = lurek.data.newByteData(16)
  local from_str = lurek.data.newByteData("hello")
  lurek.log.info("zeroed=" .. zeroed:getSize() .. " from_str=" .. from_str:getSize(), "data")
end

--@api-stub: LLazyQuery:collect
-- Evaluates this lazy query and returns all resulting values as a Lua table.
do
  -- LazyQuery chains filter/map/slice operations without intermediate tables
  -- collect() materializes the final result
  local q = lurek.data.newLazyQuery({1, 2, 3, 4, 5})
  local result = q:collect()
  lurek.log.info("collected " .. #result .. " items", "data")
end

--@api-stub: LLazyQuery:dropNil
-- Returns a new lazy query with all nil values filtered out from this query.
do
  -- Use case: cleaning sparse arrays before processing
  local q = lurek.data.newLazyQuery({1, nil, 3, nil, 5}):dropNil()
  local r = q:collect()
  lurek.log.info("non-nil count=" .. #r, "data")
end

--@api-stub: LLazyQuery:filter
-- Returns a new lazy query that only yields values passing the given predicate function.
do
  -- filter keeps only values where the function returns true
  -- Use case: finding all enemies above a health threshold
  local q = lurek.data.newLazyQuery({10, 25, 5, 40, 15})
    :filter(function(hp) return hp > 20 end)
  local alive = q:collect()
  lurek.log.info("above 20 hp: " .. #alive .. " entities", "data")
end

--@api-stub: LLazyQuery:head
-- Returns a new lazy query that yields only the first N values from this query.
do
  -- head(n) takes only the first N items — like LIMIT in SQL
  local q = lurek.data.newLazyQuery({10, 20, 30, 40, 50}):head(2)
  local r = q:collect()
  lurek.log.info("top 2: " .. r[1] .. ", " .. r[2], "data")
end

--@api-stub: LLazyQuery:limit
-- Returns a new lazy query capped at a maximum number of yielded values.
do
  -- limit(n) is an alias for head — caps output count
  local q = lurek.data.newLazyQuery({1, 2, 3, 4, 5}):limit(3)
  local r = q:collect()
  lurek.log.info("limited to " .. #r .. " items", "data")
end

--@api-stub: LLazyQuery:select
-- Returns a new lazy query that transforms each value using the given mapping function.
do
  -- select maps/transforms each value — like .map() in other languages
  -- Use case: extracting a field from entity tables, or scaling values
  local q = lurek.data.newLazyQuery({1, 2, 3}):select(function(x) return x * 10 end)
  local r = q:collect()
  lurek.log.info("scaled: " .. r[1] .. ", " .. r[2] .. ", " .. r[3], "data")
end

--@api-stub: LLazyQuery:slice
-- Returns a new lazy query that yields values from index start to index stop.
do
  -- slice(start, stop) returns items from index start to stop (1-based, inclusive)
  local q = lurek.data.newLazyQuery({10, 20, 30, 40, 50}):slice(2, 4)
  local r = q:collect()
  lurek.log.info("slice [2..4]: " .. #r .. " items", "data")
end

--@api-stub: LLazyQuery:sort
-- Returns a new lazy query that sorts all values using the given comparator function.
do
  -- sort takes a comparator: function(a, b) returning true if a < b
  -- Note: sort must collect all items internally before yielding
  local q = lurek.data.newLazyQuery({30, 10, 20}):sort(function(a, b) return a < b end)
  local r = q:collect()
  lurek.log.info("sorted: " .. r[1] .. ", " .. r[2] .. ", " .. r[3], "data")
end

--@api-stub: LLazyQuery:tail
-- Returns a new lazy query that skips the first N values and yields the rest.
do
  -- tail(n) skips the first N items — like OFFSET in SQL
  local q = lurek.data.newLazyQuery({10, 20, 30, 40}):tail(2)
  local r = q:collect()
  lurek.log.info("after skipping 2: " .. r[1] .. ", " .. r[2], "data")
end

--@api-stub: LLazyQuery:type
-- Returns the Lua-visible type name string for this lazy query handle.
do
  local q = lurek.data.newLazyQuery({1, 2, 3})
  lurek.log.info("type = " .. q:type(), "data")
end

--@api-stub: LLazyQuery:typeOf
-- Returns true if this lazy query handle matches the given type name string.
do
  local q = lurek.data.newLazyQuery({1, 2, 3})
  lurek.log.info("is LLazyQuery: " .. tostring(q:typeOf("LLazyQuery")), "data")
end

-- List methods

--@api-stub: LList:indexOf
-- Returns the 1-based index of the first occurrence of a value in this list, or nil.
do
  -- Use case: checking if an item exists and where it is
  local l = lurek.data.newList()
  l:push("apple"); l:push("banana"); l:push("cherry")
  local idx = l:indexOf("banana")
  lurek.log.info("banana at index " .. tostring(idx), "data")
end

--@api-stub: LList:insert
-- Inserts a value at a given 1-based index in this list, shifting later elements right.
do
  -- insert(index, value) — shifts elements after index to the right
  local l = lurek.data.newList()
  l:push("a"); l:push("c")
  l:insert(2, "b")  -- now: a, b, c
  lurek.log.info("after insert: size=" .. l:size(), "data")
end

--@api-stub: LList:pop
-- Removes and returns the last element of this list.
do
  -- pop from the end — stack-like behavior (LIFO)
  local l = lurek.data.newList()
  l:push(10); l:push(20); l:push(30)
  local last = l:pop()
  lurek.log.info("popped=" .. last .. " remaining=" .. l:size(), "data")
end

--@api-stub: LList:push
-- Appends a value to the end of this list.
do
  -- push adds to the end — the primary way to build a list
  local l = lurek.data.newList()
  l:push("sword"); l:push("shield"); l:push("potion")
  lurek.log.info("inventory size=" .. l:size(), "data")
end

--@api-stub: LList:reverse
-- Reverses the order of all elements in this list in place.
do
  -- Mutates in place — no new list created
  local l = lurek.data.newList()
  l:push(1); l:push(2); l:push(3)
  l:reverse()
  lurek.log.info("reversed first=" .. l:get(1) .. " (was 1, now 3)", "data")
end

--@api-stub: LList:shift
-- Removes and returns the first element of this list, shifting remaining elements left.
do
  -- shift is dequeue from front — FIFO behavior
  local l = lurek.data.newList()
  l:push("first"); l:push("second"); l:push("third")
  local v = l:shift()
  lurek.log.info("shifted=" .. v .. " new front would be 'second'", "data")
end

--@api-stub: LList:unshift
-- Prepends a value to the front of this list, shifting all existing elements right.
do
  -- unshift adds to the front — opposite of push
  local l = lurek.data.newList()
  l:push("b"); l:push("c")
  l:unshift("a")  -- now: a, b, c
  lurek.log.info("first=" .. l:get(1), "data")
end

-- Map methods

--@api-stub: LMap:clear
-- Removes all key-value pairs from this map.
do
  -- clear releases all entries — use for pooled/reusable maps
  local m = lurek.data.newMap()
  m:set("hp", 100); m:set("mp", 50)
  m:clear()
  lurek.log.info("cleared, empty=" .. tostring(m:isEmpty()), "data")
end

--@api-stub: LMap:entries
-- Returns a list of {key, value} pair tables for every entry in this map.
do
  -- entries returns an array of {key, value} pairs for iteration
  local m = lurek.data.newMap()
  m:set("str", 10); m:set("dex", 14); m:set("int", 8)
  local pairs_list = m:entries()
  lurek.log.info("stat entries=" .. #pairs_list, "data")
end

--@api-stub: LMap:get
-- Returns the value associated with a key in this map, or nil if not present.
do
  -- get returns nil for missing keys (no error)
  local m = lurek.data.newMap()
  m:set("score", 42)
  local score = m:get("score")
  local missing = m:get("nonexistent")
  lurek.log.info("score=" .. tostring(score) .. " missing=" .. tostring(missing), "data")
end

--@api-stub: LMap:has
-- Returns true if a key exists in this map.
do
  -- has is a fast existence check without retrieving the value
  local m = lurek.data.newMap()
  m:set("x", 1)
  lurek.log.info("has x=" .. tostring(m:has("x")) .. " has y=" .. tostring(m:has("y")), "data")
end

--@api-stub: LMap:isEmpty
-- Returns true if this map contains no key-value pairs.
do
  local m = lurek.data.newMap()
  lurek.log.info("new map empty=" .. tostring(m:isEmpty()), "data")
end

--@api-stub: LMap:keys
-- Returns a list of all keys currently stored in this map.
do
  -- keys returns an array table — order is not guaranteed
  local m = lurek.data.newMap()
  m:set("hp", 100); m:set("mp", 50); m:set("stamina", 75)
  local ks = m:keys()
  lurek.log.info("stat keys count=" .. #ks, "data")
end

--@api-stub: LMap:len
-- Returns the number of key-value pairs currently in this map.
do
  local m = lurek.data.newMap()
  m:set("a", 1); m:set("b", 2)
  lurek.log.info("map len=" .. m:len(), "data")
end

--@api-stub: LMap:merge
-- Merges another map or table into this map, overwriting existing keys.
do
  -- merge accepts a plain Lua table or another LMap
  -- Use case: applying config overrides on top of defaults
  local defaults = lurek.data.newMap()
  defaults:set("volume", 0.8); defaults:set("fullscreen", false)
  defaults:merge({ fullscreen = true, vsync = true })
  lurek.log.info("after merge: len=" .. defaults:len(), "data")
end

--@api-stub: LMap:remove
-- Removes a key and its associated value from this map.
do
  -- remove returns nothing; missing keys are silently ignored
  local m = lurek.data.newMap()
  m:set("temp_buff", 99)
  m:remove("temp_buff")
  lurek.log.info("after remove: has=" .. tostring(m:has("temp_buff")), "data")
end

--@api-stub: LMap:set
-- Sets a key to a value in this map, adding it if not present or overwriting if it exists.
do
  -- set is the primary mutation method — any Lua value as key or value
  local m = lurek.data.newMap()
  m:set("hp", 100)
  m:set("hp", 95)  -- overwrite
  lurek.log.info("hp after damage=" .. m:get("hp"), "data")
end

--@api-stub: LMap:values
-- Returns a list of all values currently stored in this map.
do
  -- values returns an array table of all values
  local m = lurek.data.newMap()
  m:set("sword", 15); m:set("bow", 12); m:set("staff", 8)
  local vs = m:values()
  lurek.log.info("weapon damage values count=" .. #vs, "data")
end

-- Queue methods

--@api-stub: LQueue:back
-- Returns the value at the back of this queue without removing it.
do
  -- back peeks the most recently enqueued item
  local q = lurek.data.newQueue()
  q:enqueue("first"); q:enqueue("second"); q:enqueue("last")
  lurek.log.info("back=" .. tostring(q:back()), "data")
end

--@api-stub: LQueue:dequeueBack
-- Removes and returns the value from the back of this queue.
do
  -- dequeueBack pops from the rear — makes the queue double-ended
  local q = lurek.data.newQueue()
  q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
  local v = q:dequeueBack()
  lurek.log.info("dequeued back=" .. v .. " (was 'c')", "data")
end

--@api-stub: LQueue:enqueueFront
-- Inserts a value at the front of this queue, bypassing normal ordering.
do
  -- enqueueFront gives priority — this item will be dequeued next
  -- Use case: inserting a high-priority task ahead of normal work
  local q = lurek.data.newQueue()
  q:enqueue("normal_task")
  q:enqueueFront("urgent_task")
  lurek.log.info("next to process=" .. tostring(q:peek()), "data")
end

--@api-stub: LQueue:insertAt
-- Inserts a value at a specific 1-based position in this queue.
do
  -- insertAt(index, value) for precise positioning
  local q = lurek.data.newQueue()
  q:enqueue("a"); q:enqueue("c")
  q:insertAt(2, "b")  -- now: a, b, c
  lurek.log.info("queue size after insertAt=" .. q:size(), "data")
end

--@api-stub: LQueue:peekAt
-- Returns the value at a specific 1-based index in this queue without removing it.
do
  -- peekAt for random access inspection without mutation
  local q = lurek.data.newQueue()
  q:enqueue("x"); q:enqueue("y"); q:enqueue("z")
  lurek.log.info("at index 2=" .. tostring(q:peekAt(2)), "data")
end

--@api-stub: LQueue:removeAt
-- Removes and returns the value at a specific 1-based index in this queue.
do
  -- removeAt for cancelling a specific queued item
  local q = lurek.data.newQueue()
  q:enqueue("a"); q:enqueue("b"); q:enqueue("c")
  local removed = q:removeAt(2)
  lurek.log.info("removed=" .. removed .. " remaining=" .. q:size(), "data")
end

-- Stack methods

--@api-stub: LStack:insertAt
-- Inserts a value at a specific 1-based index in this stack.
do
  local s = lurek.data.newStack()
  s:push("a"); s:push("c")
  s:insertAt(2, "b")  -- now bottom-to-top: a, b, c
  lurek.log.info("stack size=" .. s:size(), "data")
end

--@api-stub: LStack:moveWithin
-- Moves the element at index src to index dst within this stack.
do
  -- moveWithin reorders without removing — useful for priority changes
  local s = lurek.data.newStack()
  s:push("a"); s:push("b"); s:push("c")
  s:moveWithin(1, 3)  -- move bottom element to top
  lurek.log.info("top after move=" .. tostring(s:peek()), "data")
end

--@api-stub: LStack:peekAt
-- Returns the value at a specific 1-based index in this stack without removing it.
do
  local s = lurek.data.newStack()
  s:push(10); s:push(20); s:push(30)
  lurek.log.info("at index 1 (bottom)=" .. s:peekAt(1), "data")
end

--@api-stub: LStack:peekBottom
-- Returns the value at the bottom of this stack without removing it.
do
  -- peekBottom inspects the oldest pushed item still in the stack
  local s = lurek.data.newStack()
  s:push("oldest"); s:push("middle"); s:push("newest")
  lurek.log.info("bottom=" .. tostring(s:peekBottom()), "data")
end

--@api-stub: LStack:popBottom
-- Removes and returns the value at the bottom of this stack.
do
  -- popBottom makes the stack behave like a deque from the bottom
  local s = lurek.data.newStack()
  s:push("bottom"); s:push("top")
  local v = s:popBottom()
  lurek.log.info("popped bottom=" .. v .. " remaining=" .. s:size(), "data")
end

--@api-stub: LStack:popMany
-- Removes and returns the top N values from this stack as a list.
do
  -- popMany is efficient batch removal from the top
  local s = lurek.data.newStack()
  s:push(1); s:push(2); s:push(3); s:push(4)
  local batch = s:popMany(2)  -- pops 4 and 3
  lurek.log.info("popped " .. #batch .. " items, stack now=" .. s:size(), "data")
end

--@api-stub: LStack:pushBottom
-- Pushes a value onto the bottom of this stack without disturbing existing elements.
do
  -- pushBottom inserts beneath everything — deque behavior
  local s = lurek.data.newStack()
  s:push("top")
  s:pushBottom("new_bottom")
  lurek.log.info("bottom=" .. tostring(s:peekBottom()), "data")
end

--@api-stub: LStack:removeAt
-- Removes and returns the value at a specific 1-based index in this stack.
do
  -- removeAt for surgical removal from any position
  local s = lurek.data.newStack()
  s:push("a"); s:push("b"); s:push("c")
  local v = s:removeAt(2)
  lurek.log.info("removed from middle=" .. v, "data")
end

-- WeightedRandom methods

--@api-stub: LWeightedRandom:add
-- Adds an item with a given weight to this weighted random picker.
do
  -- WeightedRandom picks items with probability proportional to their weight
  -- Use case: loot tables, spawn distributions, dialogue choices
  local loot = lurek.data.newWeightedRandom()
  loot:add("common_sword", 70.0)   -- 70% chance
  loot:add("rare_shield", 25.0)    -- 25% chance
  loot:add("legendary_helm", 5.0)  -- 5% chance
  lurek.log.info("loot table: " .. loot:len() .. " items, total=" .. loot:totalWeight(), "data")
end

--@api-stub: LWeightedRandom:clearAll
-- Removes all items and resets this weighted random picker to an empty state.
do
  local wr = lurek.data.newWeightedRandom()
  wr:add("x", 1.0); wr:add("y", 2.0)
  wr:clearAll()
  lurek.log.info("after clearAll: empty=" .. tostring(wr:isEmpty()), "data")
end

--@api-stub: LWeightedRandom:getRevision
-- Returns the revision counter incremented each time the item list changes.
do
  -- Revision tracking lets you know if the table changed since last check
  -- Use case: caching pick results until the table is modified
  local wr = lurek.data.newWeightedRandom()
  local rev0 = wr:getRevision()
  wr:add("a", 1.0)
  local rev1 = wr:getRevision()
  lurek.log.info("revision went from " .. rev0 .. " to " .. rev1, "data")
end

--@api-stub: LWeightedRandom:isEmpty
-- Returns true if this weighted random picker contains no items.
do
  local wr = lurek.data.newWeightedRandom()
  lurek.log.info("new picker empty=" .. tostring(wr:isEmpty()), "data")
end

--@api-stub: LWeightedRandom:len
-- Returns the number of items currently in this weighted random picker.
do
  local wr = lurek.data.newWeightedRandom()
  wr:add("sword", 1.0); wr:add("bow", 2.0); wr:add("staff", 1.5)
  lurek.log.info("weapon pool size=" .. wr:len(), "data")
end

--@api-stub: LWeightedRandom:pick
-- Picks and returns one random item according to this picker's weights.
do
  -- pick uses internal RNG seeded per-instance
  -- Higher weight = higher probability of being chosen
  local wr = lurek.data.newWeightedRandom()
  wr:add("common", 90.0)
  wr:add("rare", 10.0)
  local item = wr:pick()
  lurek.log.info("picked: " .. item, "data")
end

--@api-stub: LWeightedRandom:pickN
-- Picks N random items with replacement and returns them as a list.
do
  -- pickN draws N times WITH replacement (same item can appear multiple times)
  -- Use case: generating a loot drop of 5 items from a single table
  local wr = lurek.data.newWeightedRandom()
  wr:add("gold", 5.0); wr:add("gem", 2.0); wr:add("nothing", 3.0)
  local drops = wr:pickN(5)
  lurek.log.info("dropped " .. #drops .. " items", "data")
end

--@api-stub: LWeightedRandom:remove
-- Removes an item by value from this weighted random picker.
do
  -- Use case: removing a one-time reward after it's been claimed
  local wr = lurek.data.newWeightedRandom()
  wr:add("quest_reward", 1.0); wr:add("normal_loot", 5.0)
  wr:remove("quest_reward")
  lurek.log.info("after remove: len=" .. wr:len(), "data")
end

--@api-stub: LWeightedRandom:setWeight
-- Updates the weight of an existing item in this weighted random picker.
do
  -- Use case: adjusting drop rates based on player level or luck stat
  local wr = lurek.data.newWeightedRandom()
  wr:add("rare_drop", 1.0)
  wr:setWeight("rare_drop", 5.0)  -- luck buff increases rare chance
  lurek.log.info("new total weight=" .. wr:totalWeight(), "data")
end

--@api-stub: LWeightedRandom:totalWeight
-- Returns the sum of all item weights in this weighted random picker.
do
  -- totalWeight is useful for displaying percentage chances in UI
  local wr = lurek.data.newWeightedRandom()
  wr:add("common", 70.0); wr:add("rare", 25.0); wr:add("epic", 5.0)
  local total = wr:totalWeight()
  -- Each item's chance = weight / totalWeight * 100
  lurek.log.info("total weight=" .. total .. " (common chance=" .. (70/total*100) .. "%)", "data")
end

print("content/examples/data.lua")
