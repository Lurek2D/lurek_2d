-- content/examples/serial.lua
-- Demonstrates every lurek.serial.* function with realistic game-developer usage.
-- Run: cargo run -- content/examples/serial.lua

--@api-stub: lurek.serial.fromJson
-- Parses a JSON string into a Lua table
do
  -- Loading a player profile received from a server or read from a file
  local json_str = '{"username":"knight42","level":12,"inventory":["sword","shield","potion"]}'
  local profile = lurek.serial.fromJson(json_str)

  -- Access nested fields directly as Lua tables
  lurek.log.info("Player: " .. profile.username .. " (level " .. profile.level .. ")", "serial")
  lurek.log.info("First item: " .. profile.inventory[1], "serial")
end

--@api-stub: lurek.serial.toJson
-- Serializes a Lua value into a JSON string
do
  -- Prepare a save-game snapshot for writing to disk or sending over network
  local save_data = {
    player = { x = 128.5, y = 64.0, hp = 85 },
    quest_progress = { main = 3, side = { "gather_herbs", "rescue_cat" } },
    timestamp = os.time(),
  }

  -- pretty=true makes the output human-readable (useful for debug saves)
  local compact = lurek.serial.toJson(save_data)
  local pretty = lurek.serial.toJson(save_data, true)
  lurek.log.info("Compact length: " .. #compact .. " Pretty length: " .. #pretty, "serial")
end

--@api-stub: lurek.serial.fromToml
-- Parses a TOML string into a Lua table
do
  -- TOML is the preferred format for game configuration in Lurek2D
  local toml_str = [[
title = "Dragon Quest"
version = "1.2.0"

[window]
width = 1280
height = 720
vsync = true

[gameplay]
difficulty = "normal"
max_enemies = 50
]]
  local cfg = lurek.serial.fromToml(toml_str)

  -- Nested TOML sections become nested Lua tables
  lurek.log.info(cfg.title .. " v" .. cfg.version, "serial")
  lurek.log.info("Window: " .. cfg.window.width .. "x" .. cfg.window.height, "serial")
  lurek.log.info("Difficulty: " .. cfg.gameplay.difficulty, "serial")
end

--@api-stub: lurek.serial.toToml
-- Serializes a Lua table into a TOML-formatted string
do
  -- Generate a default configuration file that players can edit
  local defaults = {
    audio = { master = 0.8, music = 0.6, sfx = 1.0 },
    controls = { move_up = "w", move_down = "s" },
    fullscreen = false,
  }
  local toml_output = lurek.serial.toToml(defaults)

  -- The result can be written to a .toml file via lurek.filesystem
  lurek.log.info("Generated config:\n" .. toml_output, "serial")
end

--@api-stub: lurek.serial.fromIni
-- Parses an INI-format string into a Lua table
do
  -- INI is common in legacy game configs and mod settings
  local ini_str = [[
[player]
name=Warrior
class=fighter
starting_gold=100

[display]
resolution=1920x1080
fullscreen=true
]]
  local cfg = lurek.serial.fromIni(ini_str)

  -- Sections become top-level keys, key-value pairs become string fields
  lurek.log.info("Character: " .. cfg.player.name .. " (" .. cfg.player.class .. ")", "serial")
  lurek.log.info("Resolution: " .. cfg.display.resolution, "serial")
end

--@api-stub: lurek.serial.fromCsv
-- Parses a CSV string into an array of row tables
do
  -- Loading a leaderboard or item database exported from a spreadsheet
  local csv_data = "id,name,damage,rarity\n1,Iron Sword,10,common\n2,Fire Staff,25,rare\n3,Shadow Blade,40,epic\n"
  local items = lurek.serial.fromCsv(csv_data)

  -- Each row is a table keyed by column headers (hasHeaders defaults to true)
  for i, item in ipairs(items) do
    lurek.log.info(item.name .. " dmg=" .. item.damage .. " [" .. item.rarity .. "]", "serial")
  end

  -- Use a custom delimiter for semicolon-separated data
  local tsv = "name;score\nAda;1500\nMax;1200\n"
  local scores = lurek.serial.fromCsv(tsv, ";")
  lurek.log.info("Top scorer: " .. scores[1].name .. " = " .. scores[1].score, "serial")
end

--@api-stub: lurek.serial.toCsv
-- Serializes an array of row tables into a CSV-formatted string
do
  -- Export a high-score table for display or file save
  local scores = {
    { rank = "1", player = "Ada", score = "15000", time = "12:34" },
    { rank = "2", player = "Max", score = "12000", time = "14:01" },
    { rank = "3", player = "Lin", score = "9500", time = "15:22" },
  }

  -- Default delimiter is comma, headers are written automatically
  local csv = lurek.serial.toCsv(scores)
  lurek.log.info("Leaderboard CSV:\n" .. csv, "serial")

  -- Use semicolon delimiter for locales where comma is decimal separator
  local csv_semi = lurek.serial.toCsv(scores, ";")
  lurek.log.info("Semicolon variant:\n" .. csv_semi, "serial")
end

--@api-stub: lurek.serial.encodeMsgPack
-- Encodes a Lua table into compact binary MessagePack
do
  -- MessagePack is ideal for save files and network packets (smaller + faster than JSON)
  local game_state = {
    tick = 48000,
    entities = {
      { id = 1, x = 100, y = 200, hp = 50 },
      { id = 2, x = 300, y = 150, hp = 80 },
    },
    seed = 987654,
  }

  local bytes = lurek.serial.encodeMsgPack(game_state)
  local json_equivalent = lurek.serial.toJson(game_state)

  -- Compare sizes: msgpack is typically 30-50% smaller than JSON
  lurek.log.info("MsgPack: " .. #bytes .. " bytes, JSON: " .. #json_equivalent .. " bytes", "serial")
end

--@api-stub: lurek.serial.decodeMsgPack
-- Decodes a binary MessagePack string back into a Lua table
do
  -- Round-trip: encode game state, then decode it back (e.g. loading a save)
  local original = { player_x = 256, player_y = 128, level = 5, items = { "key", "gem" } }
  local bytes = lurek.serial.encodeMsgPack(original)

  -- Decode returns a full Lua table identical to the original
  local restored = lurek.serial.decodeMsgPack(bytes)
  lurek.log.info("Restored: level=" .. restored.level .. " at (" .. restored.player_x .. "," .. restored.player_y .. ")", "serial")
  lurek.log.info("Items: " .. restored.items[1] .. ", " .. restored.items[2], "serial")
end

--@api-stub: lurek.serial.decodeXml
-- Parses an XML string into a nested Lua table structure
do
  -- Load a Tiled-style tilemap layer exported as XML
  local xml_str = [[<map width="10" height="10" tilewidth="32">
  <tileset firstgid="1" name="terrain" source="terrain.tsx"/>
  <layer name="ground" width="10" height="10">
    <data encoding="csv">1,1,2,2,3,3,1,1,2,2</data>
  </layer>
</map>]]

  local doc = lurek.serial.decodeXml(xml_str)

  -- Root element: tag name, attributes, and children are all accessible
  lurek.log.info("Map tag: " .. doc.tag .. " width=" .. doc.attrs.width, "serial")

  -- Navigate children by index
  if doc.children and #doc.children > 0 then
    local first_child = doc.children[1]
    lurek.log.info("First child: <" .. first_child.tag .. "> name=" .. tostring(first_child.attrs.name), "serial")
  end
end

--@api-stub: lurek.serial.validate
-- Validates a Lua value against a schema table
do
  -- Define a schema for player save data with type and range constraints
  local save_schema = {
    type = "table",
    fields = {
      hp = { type = "number", min = 0, max = 999 },
      name = { type = "string" },
      level = { type = "number", min = 1 },
    },
  }

  -- Valid data passes validation
  local ok, err = lurek.serial.validate({ hp = 100, name = "Hero", level = 5 }, save_schema)
  lurek.log.info("Valid save: ok=" .. tostring(ok), "serial")

  -- Invalid data returns false + descriptive error message
  local ok2, err2 = lurek.serial.validate({ hp = -5, name = "Hero", level = 0 }, save_schema)
  lurek.log.info("Invalid save: ok=" .. tostring(ok2) .. " err=" .. tostring(err2), "serial")

  -- Use validate before loading untrusted user data to prevent corrupted state
end

--@api-stub: lurek.serial.detectFormat
-- Auto-detects the serialization format of a string
do
  -- Useful when accepting drag-and-drop files or user-provided configs of unknown format
  local samples = {
    '{"type": "enemy", "hp": 50}',
    'title = "My Game"\nversion = "1.0"',
    '<?xml version="1.0"?><root/>',
    "[section]\nkey=value",
    "name,score\nAda,100",
  }

  for _, sample in ipairs(samples) do
    local detected = lurek.serial.detectFormat(sample)
    -- Returns "json", "toml", "xml", "ini", "csv", or nil
    lurek.log.info("Detected: " .. tostring(detected) .. " for: " .. sample:sub(1, 20) .. "...", "serial")
  end
end

--@api-stub: lurek.serial.decode
-- Universal decoder that auto-detects or uses a format hint
do
  -- Single entry point for loading any supported format
  -- Auto-detect mode (no format argument): inspects content to determine type
  local json_data = lurek.serial.decode('{"weapon":"bow","ammo":15}')
  lurek.log.info("Auto-detected JSON: weapon=" .. json_data.weapon, "serial")

  -- Explicit format hint: skips detection, faster and unambiguous
  local toml_data = lurek.serial.decode('hp = 100\nmp = 50\n', "toml")
  lurek.log.info("TOML with hint: hp=" .. toml_data.hp .. " mp=" .. toml_data.mp, "serial")

  -- CSV with options: custom delimiter and header control
  local csv_data = lurek.serial.decode("name;score\nAda;99\n", "csv", { delimiter = ";", has_headers = true })
  lurek.log.info("CSV: " .. csv_data[1].name .. "=" .. csv_data[1].score, "serial")
end

--@api-stub: lurek.serial.encode
-- Universal encoder that serializes to a specified format
do
  -- Single entry point for all serialization needs
  local inventory = { { slot = "1", item = "sword", qty = "1" }, { slot = "2", item = "potion", qty = "5" } }

  -- JSON with pretty printing for debug/config files
  local json_out = lurek.serial.encode({ gold = 500, xp = 1200 }, "json", { pretty = true })
  lurek.log.info("Pretty JSON:\n" .. json_out, "serial")

  -- TOML for configuration export
  local toml_out = lurek.serial.encode({ audio = { volume = 0.8 } }, "toml")
  lurek.log.info("TOML:\n" .. toml_out, "serial")

  -- CSV with custom delimiter
  local csv_out = lurek.serial.encode(inventory, "csv", { delimiter = ";" })
  lurek.log.info("CSV semicolon:\n" .. csv_out, "serial")

  -- MsgPack for compact binary (save files, network)
  local bin = lurek.serial.encode({ tick = 999, alive = true }, "msgpack")
  lurek.log.info("MsgPack bytes: " .. #bin, "serial")
end

--@api-stub: lurek.serial.applyDefaults
-- Merges schema defaults into a data table without overwriting existing values
do
  -- Define a schema with defaults for every field
  local settings_schema = {
    type = "table",
    fields = {
      music_volume = { type = "number", default = 0.7 },
      sfx_volume = { type = "number", default = 1.0 },
      language = { type = "string", default = "en" },
      fullscreen = { type = "boolean", default = false },
    },
  }

  -- User only set one field; applyDefaults fills the rest
  local user_settings = { music_volume = 0.3 }
  local complete = lurek.serial.applyDefaults(user_settings, settings_schema)

  -- music_volume stays 0.3 (user override), others get defaults
  lurek.log.info("Music: " .. complete.music_volume, "serial")   -- 0.3 (kept)
  lurek.log.info("SFX: " .. complete.sfx_volume, "serial")       -- 1.0 (default)
  lurek.log.info("Lang: " .. complete.language, "serial")         -- "en" (default)
  lurek.log.info("Fullscreen: " .. tostring(complete.fullscreen), "serial") -- false (default)
end

print("content/examples/serial.lua")
