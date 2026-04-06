-- examples/serial.lua
-- luna.serial — Serialization and deserialization: JSON, TOML, CSV.
-- All luna.serial API methods demonstrated with code and comments.

-- ── JSON ──────────────────────────────────────────────────────────────────────

-- fromJson(s) → table | value   — deserialize a JSON string to Lua value
local json_str = '{"name":"hero","hp":100,"items":["sword","shield"]}'
local data = luna.serial.fromJson(json_str)
print(data.name)         -- "hero"
print(data.hp)           -- 100
print(data.items[1])     -- "sword"

-- toJson(value, pretty?) → string   — serialize a Lua table (or any serializable value) to JSON
-- pretty = true adds indentation
local result = luna.serial.toJson({ id = 42, score = 9999 })
print(result)            -- {"id":42,"score":9999}

local pretty = luna.serial.toJson({ id = 42, score = 9999 }, true)
print(pretty)
-- {
--   "id": 42,
--   "score": 9999
-- }

-- Round-trip JSON
local original = { level = 3, pos = { x = 100, y = 200 } }
local encoded  = luna.serial.toJson(original)
local decoded  = luna.serial.fromJson(encoded)
assert(decoded.level == 3)
assert(decoded.pos.x == 100)

-- ── TOML ──────────────────────────────────────────────────────────────────────

-- fromToml(s) → table   — parse TOML text to Lua table
local toml_str = [[
title = "Luna Demo"
version = 1

[window]
width  = 1280
height = 720
]]
local cfg = luna.serial.fromToml(toml_str)
print(cfg.title)           -- "Luna Demo"
print(cfg.window.width)    -- 1280

-- toToml(value) → string   — serialize a Lua table to TOML
local toml_out = luna.serial.toToml({
    title = "My Game",
    version = 2,
    window = { width = 800, height = 600 }
})
print(toml_out)

-- ── CSV ───────────────────────────────────────────────────────────────────────

-- fromCsv(s, delimiter?, has_headers?) → table of tables
-- Each inner table is one row; if has_headers=true, inner tables are keyed by column name.
-- delimiter defaults to ","  |  has_headers defaults to true

local csv_str = "name,hp,level\nhero,100,5\nvillain,200,10"
local rows_keyed = luna.serial.fromCsv(csv_str)        -- has_headers = true by default
print(rows_keyed[1].name)    -- "hero"
print(rows_keyed[2].hp)      -- "200" (values are strings)

-- Without headers — each row becomes an array
local rows_array = luna.serial.fromCsv("a,b\nc,d", ",", false)
print(rows_array[1][1])  -- "a"
print(rows_array[2][2])  -- "d"

-- Custom delimiter (tab-separated)
local tsv = "sword\t10\ndagger\t5"
local items_tsv = luna.serial.fromCsv(tsv, "\t", false)
print(items_tsv[1][1])   -- "sword"

-- toCsv(value, delimiter?, has_headers?) → string
-- Converts an array of arrays (or array of keyed tables) back to CSV text.
-- has_headers=true (default) — use keys from first row as header row.

local data_table = {
    { name = "axe",   damage = 15 },
    { name = "staff", damage = 8  },
}
local csv_out = luna.serial.toCsv(data_table)
print(csv_out)
-- damage,name
-- 15,axe
-- 8,staff

-- Use has_headers=false with array-of-arrays
local arr_out = luna.serial.toCsv({ {"r1c1","r1c2"}, {"r2c1","r2c2"} }, ",", false)
print(arr_out)
-- r1c1,r1c2
-- r2c1,r2c2

-- ── Common Patterns ───────────────────────────────────────────────────────────

-- Save/load settings with JSON
--[[
local function save_settings(path, settings)
    luna.filesystem.write(path, luna.serial.toJson(settings, true))
end

local function load_settings(path)
    if luna.filesystem.exists(path) then
        return luna.serial.fromJson(luna.filesystem.read(path))
    end
    return { volume = 1.0, fullscreen = false }
end
]]

-- Parse game data from TOML config
--[[
local config_text = luna.filesystem.read("data/config.toml")
local game_config = luna.serial.fromToml(config_text)
local target_fps  = game_config.performance.target_fps or 60
]]

-- Export leaderboard as CSV
--[[
local scores = {
    { name = "Alice", score = 1200, time = 98 },
    { name = "Bob",   score =  900, time = 115 },
}
luna.filesystem.write("save/scores.csv", luna.serial.toCsv(scores))
]]
