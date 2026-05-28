-- content/snippets/data.lua
-- Handcrafted snippets for lurek.binary — binary serialisation, checksums, compression,
-- encoding, hashing, TOML, ring-buffers, binary reader/writer, DataView.
-- API surface covered: pack, unpack, getPackedSize, crc32, hash, encode, decode,
--   compress, decompress, compressChunks, write, read, size,
--   parseToml, encodeToml, newRingBuffer, newByteData, newDataView,
--   newWriter, toMsgPack, fromMsgPack.

local d = lurek.binary

-- ─────────────────────────────────────────────────────────────
-- BINARY SERIALISATION — pack / unpack
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.pack_unpack_roundtrip
-- @prefix lk-data-pack-roundtrip
-- @module data
-- @description Use for network packet construction and binary save-data blobs. pack serialises Lua values using a format string; unpack reverses it. crc32 detects corruption on receive before you call unpack.
-- @body
local SNIP_1_d = lurek.binary
-- pack: uint16, float, null-terminated string
local payload  = d.pack(">Hfz", 1042, 3.14, "hero")
local crc      = d.crc32(payload)
print("packed bytes=" .. #payload .. "  crc=" .. string.format("0x%08x", crc))

-- unpack (validate crc before this in real code):
local id, value, name = d.unpack(">Hfz", payload)
print(string.format("id=%d  value=%.2f  name=%s", id, value, name))
-- @end

-- @snippet binary.pack_struct_batch
-- @prefix lk-data-pack-struct-batch
-- @module data
-- @description Use to serialise a homogeneous array of fixed-size records (vectors, transform matrices, physics states) into one compact binary blob. getPackedSize verifies expected sizes without doing a full pack.
-- @body
local SNIP_1_d   = lurek.binary
local FMT = ">fff"   -- 3x big-endian float = 12 bytes
local vecs = { {1.0, 2.5, -3.0}, {0.5, 0.0, 1.5}, {-1.0, 4.2, 0.0} }
local blob = ""
for _, v in ipairs(vecs) do
    blob = blob .. d.pack(FMT, v[1], v[2], v[3])
end
local expected = d.getPackedSize(FMT, 0.0, 0.0, 0.0) * #vecs
print("blob=" .. #blob .. " bytes  expected=" .. expected)
-- @end

-- @snippet binary.write_read_writer
-- @prefix lk-data-write-read
-- @module data
-- @description Use newWriter when building a binary payload incrementally (message framing, file chunk headers). Typed methods writeU8/writeU16LE/writeF32LE are safer than raw pack for variable-length record construction.
-- @body
local SNIP_1_d = lurek.binary
local w = d.newWriter()
w:writeU8(0x7F)        -- version byte
w:writeU16LE(1024)     -- payload length hint
w:writeF32LE(3.14)     -- float field
w:writeString("hello") -- pascal-style string
local written_len = w:len()
print("writer bytes=" .. written_len)

-- read back the first two fields with the format-string API:
local blob_str = w:toBytes()
local ver, length = d.read("Bu16le", blob_str)
print("version=0x" .. string.format("%02x", ver) .. "  length=" .. length)
-- @end

-- @snippet binary.dataview_binary_inspection
-- @prefix lk-data-dataview-inspect
-- @module data
-- @description Use DataView to inspect a binary blob received from a file or network without copying it. Reads typed values at arbitrary byte offsets — useful for parsing file-format headers or network message envelopes.
-- @body
local SNIP_1_d = lurek.binary
-- simulate a 12-byte header: magic(4), version(2), data_len(4)
local header = d.pack(">IHI", 0x4C524B32, 1, 4096)
local view   = d.newDataView(header)
print("view size=" .. view:getSize() .. " bytes")
local magic   = view:getUInt32(0)
local version = view:getUInt16(4)
local dlen    = view:getUInt32(6)
print(string.format("magic=0x%08x  ver=%d  data_len=%d", magic, version, dlen))
-- @end

-- @snippet binary.bytedata_xor_cipher
-- @prefix lk-data-bytedata-cipher
-- @module data
-- @description Use LByteData for in-place byte manipulation: simple ciphers, checksum accumulation, or binary patching. newByteData(str) copies bytes in; getByte/setByte let you iterate and modify individual bytes.
-- @body
local SNIP_1_d   = lurek.binary
local KEY = 0x5A
local msg = "secret_level_data"
local bd  = d.newByteData(msg)
-- encrypt in place (XOR)
for i = 0, bd:getSize() - 1 do
    local b = bd:getByte(i)
    bd:setByte(i, bit.bxor(b, KEY))
end
print("encrypted length=" .. bd:getSize())
-- decrypt back
for i = 0, bd:getSize() - 1 do
    local b = bd:getByte(i)
    bd:setByte(i, bit.bxor(b, KEY))
end
print("decrypted=" .. bd:getString())
-- @end

-- ─────────────────────────────────────────────────────────────
-- HASHING AND CHECKSUMS
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.hash_asset_key
-- @prefix lk-data-hash-asset-key
-- @module data
-- @description Use hash() to derive a compact, reproducible lookup key from an asset path or chunk content. Use "sha256" for integrity checks; "xxh64" for fast non-security cache keys (~4x faster).
-- @body
local SNIP_1_d    = lurek.binary
local path = "content/games/mymod/map01.toml"
local secure_key = d.hash("sha256", path)
print("sha256=" .. secure_key)

local fast_key = d.hash("xxh64", path)
print("xxh64=" .. fast_key)
-- @end

-- @snippet binary.crc32_save_file_validate
-- @prefix lk-data-crc32-save
-- @module data
-- @description Use to protect save files and transmitted blobs from silent corruption. Append the CRC to the blob on write; recompute and compare on load before parsing the payload.
-- @body
local SNIP_1_d    = lurek.binary
local save = d.encodeToml({ player = { level = 5, gold = 300 } })
local crc  = d.crc32(save)
-- write: append CRC as 4 bytes
local safe_blob = save .. d.pack(">I", crc)
print("blob+crc=" .. #safe_blob .. " bytes")

-- on load: strip last 4 bytes and verify
local body        = safe_blob:sub(1, -5)
local stored_crc  = d.unpack(">I", safe_blob:sub(-4))
local valid       = d.crc32(body) == stored_crc
print("crc valid=" .. tostring(valid))
-- @end

-- @snippet binary.encode_decode_base64
-- @prefix lk-data-base64
-- @module data
-- @description Use to embed binary data in JSON strings, URLs, or text protocols. encode("base64") produces the RFC 4648 string; decode("base64") reverses it back to raw bytes.
-- @body
local SNIP_1_d   = lurek.binary
local raw = d.pack(">HH", 0xDEAD, 0xBEEF)
local b64 = d.encode("base64", raw)
print("base64=" .. b64)

local decoded = d.decode("base64", b64)
local a, b   = d.unpack(">HH", decoded)
print(string.format("decoded=0x%04x 0x%04x", a, b))
-- @end

-- ─────────────────────────────────────────────────────────────
-- COMPRESSION
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.compress_save_slot
-- @prefix lk-data-compress-save
-- @module data
-- @description Use zlib compression on save blobs to reduce file-system write size. Level 6 balances speed and ratio for structured config data; verify round-trip before writing with the assert check below.
-- @body
local SNIP_1_d   = lurek.binary
local payload    = d.encodeToml({ world = { map = "dungeon_01", seed = 42 } })
local compressed = d.compress("zlib", payload, 6)
print(string.format("original=%d  compressed=%d  ratio=%.2f",
    #payload, #compressed, #compressed / #payload))

-- decompress on load and verify:
local restored = d.decompress("zlib", compressed)
assert(restored == payload, "decompression mismatch")
print("decompressed ok")
-- @end

-- @snippet binary.compress_chunks_streaming
-- @prefix lk-data-compress-chunks
-- @module data
-- @description Use compressChunks for streaming serialisation of large maps or level sections split into tiles. Pass a table of binary strings to avoid allocating one giant concatenated blob before compression.
-- @body
local SNIP_1_d = lurek.binary
local sections = {
    d.pack(">Hff", 1, 100.0, 200.0),
    d.pack(">Hff", 2, 300.0,  50.0),
    d.pack(">Hff", 3, 450.0, 320.0),
}
local compressed = d.compressChunks("zlib", sections, 3)
print("chunks compressed=" .. #compressed .. " bytes")

local restored = d.decompress("zlib", compressed)
local section_id = d.unpack(">H", restored)
print("first section id=" .. section_id)
-- @end

-- ─────────────────────────────────────────────────────────────
-- TOML CONFIGURATION
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.toml_load_validate_defaults
-- @prefix lk-data-toml-load
-- @module data
-- @description Use at startup to load a TOML config, apply defaults for optional keys, and validate required fields. Fail fast with a clear error rather than silently propagating nil values into game logic.
-- @body
local SNIP_1_d = lurek.binary
local toml_str = [[
[audio]
volume = 0.8
[graphics]
resolution = "1920x1080"
]]
local cfg    = d.parseToml(toml_str)
local volume = (cfg.audio and cfg.audio.volume) or 0.75
local res    = (cfg.graphics and cfg.graphics.resolution) or "1280x720"
assert(type(volume) == "number" and volume >= 0 and volume <= 1, "invalid volume")
print("volume=" .. volume .. "  resolution=" .. res)
-- @end

-- @snippet binary.toml_config_patch_save
-- @prefix lk-data-toml-patch
-- @module data
-- @description Use to apply partial preference updates without rewriting the whole config. parseToml -> mutate the table -> encodeToml preserves all other keys and structure.
-- @body
local SNIP_1_d   = lurek.binary
local raw = [[
[player]
name = "Hero"
level = 1
[audio]
volume = 0.8
]]
local cfg = d.parseToml(raw)
cfg.player.level = cfg.player.level + 1
cfg.audio.volume = 0.6

local updated = d.encodeToml(cfg)
print(updated)
-- write to disk: lurek.filesystem.write("save/options.toml", updated)
-- @end

-- @snippet binary.toml_game_manifest_parse
-- @prefix lk-data-toml-manifest
-- @module data
-- @description Use to load and validate a game manifest (name, version, entry point) during boot. Centralise all schema checks here so the game loop never receives unvalidated manifest data.
-- @body
local SNIP_1_d = lurek.binary
local manifest_toml = [[
name    = "Dungeon Explorer"
version = "1.2.0"
entry   = "main.lua"
[requires]
engine = "0.6"
]]
local m = d.parseToml(manifest_toml)
assert(m.name,    "manifest: missing name")
assert(m.version, "manifest: missing version")
assert(m.entry,   "manifest: missing entry")
print("manifest ok: " .. m.name .. " v" .. m.version)
-- @end

-- ─────────────────────────────────────────────────────────────
-- RING BUFFER
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.ringbuffer_event_queue
-- @prefix lk-data-ringbuffer-queue
-- @module data
-- @description Use as a bounded event queue for combat log messages, input history, or debug entries. The buffer overwrites the oldest entry when full — no manual eviction code required.
-- @body
local SNIP_1_d   = lurek.binary
local buf = d.newRingBuffer(8)

buf:push({ type = "damage", amount = 15 })
buf:push({ type = "heal",   amount = 5  })
buf:push({ type = "damage", amount = 30 })
print("len=" .. buf:len() .. "  cap=" .. buf:capacity())

while not buf:isEmpty() do
    local ev = buf:pop()
    if ev then
        print("event=" .. ev.type .. " amount=" .. (ev.amount or 0))
    end
end
-- @end

-- @snippet binary.ringbuffer_rolling_avg
-- @prefix lk-data-ringbuffer-rolling-avg
-- @module data
-- @description Use a ring buffer to compute a rolling average of frame times, damage-per-second, or sensor readings. toTable() yields the current window as a plain Lua array for sum/count without a separate counter.
-- @body
local SNIP_1_d   = lurek.binary
local WIN = 30
local fps_buf = d.newRingBuffer(WIN)

-- simulate 40 frames of frame-time data (ms)
for i = 1, 40 do
    fps_buf:push(16.0 + (i % 5) * 0.3)
end

local samples = fps_buf:toTable()
local sum = 0
for _, v in ipairs(samples) do sum = sum + v end
local avg = sum / #samples
print(string.format("rolling avg frame_ms=%.2f  window=%d", avg, #samples))
-- @end

-- ─────────────────────────────────────────────────────────────
-- MSGPACK INTEROP
-- ─────────────────────────────────────────────────────────────

-- @snippet binary.msgpack_state_roundtrip
-- @prefix lk-data-msgpack-roundtrip
-- @module data
-- @description Use toMsgPack / fromMsgPack for compact structured serialisation of game state snapshots passed between Lua VMs via Channel, or written as save slot blobs. Smaller than TOML; more type-safe than raw pack.
-- @body
local SNIP_1_d = lurek.binary
local state = {
    player = { name = "Hero", hp = 80, level = 5 },
    round  = 3,
    flags  = { has_sword = true, chest_open = false },
}

local blob = d.toMsgPack(state)
print("msgpack bytes=" .. #blob)

local loaded = d.fromMsgPack(blob)
if type(loaded) == "table" then
    local player = loaded.player
    if player then
        print("loaded name=" .. tostring(player.name) .. " hp=" .. tostring(player.hp))
    end
end
-- @end
