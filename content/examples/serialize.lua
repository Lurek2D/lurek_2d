-- content/examples/serialize.lua
-- Auto-generated from content/examples2/serial_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/serial.lua

--- Serial Module: JSON, TOML, CSV, INI, MsgPack, XML, format detection, schema validation

--@api: lurek.serialize.fromJson
do
    local jsonStr = '{"name":"warrior","level":12,"alive":true,"items":["sword","shield"]}'
    local data = lurek.serialize.fromJson(jsonStr)
    local equipment = data.items[1] .. " + " .. data.items[2]
    local summary = data.name .. " lvl " .. data.level
    lurek.log.info("loaded party member: " .. summary)
    lurek.log.info("alive = " .. tostring(data.alive) .. ", gear = " .. equipment)
end

--@api: lurek.serialize.toJson
do
    local save_state = { player = { name = "Alice", level = 2 }, checkpoint = "town_gate" }
    local json = lurek.serialize.toJson(save_state, true)
    local restored = lurek.serialize.fromJson(json)
    local has_player = json:find('"player"') ~= nil
    lurek.log.info("save checkpoint = " .. restored.checkpoint)
    lurek.log.info("pretty json has player key = " .. tostring(has_player))
end

--@api: lurek.serialize.fromToml
do
    local tomlStr = '[game]\ntitle = "Dungeon Quest"\n[window]\nwidth = 1920\nheight = 1080'
    local config = lurek.serialize.fromToml(tomlStr)
    local resolution = config.window.width .. "x" .. config.window.height
    local area = config.window.width * config.window.height
    local title = config.game.title
    lurek.log.info("loaded TOML config for " .. title)
    lurek.log.info("window = " .. resolution .. " (" .. area .. " px)")
end

--@api: lurek.serialize.fromCsv
do
    local csvWithHeaders = "name,age,city\nAlice,30,Warsaw\nBob,25,Krakow\nCarol,35,Gdansk"
    local rows = lurek.serialize.fromCsv(csvWithHeaders, ",", true)
    lurek.log.info("rows with headers = " .. #rows)
    lurek.log.info("first row name = " .. rows[1].name)
    lurek.log.info("second row city = " .. rows[2].city)
end

--@api: lurek.serialize.fromIni
do
    local iniStr = '[player]\nname = Hero\nclass = warrior\n[controls]\njump = space'
    local ini = lurek.serialize.fromIni(iniStr)
    local player = ini.player.name .. " the " .. ini.player.class
    local jump_key = ini.controls.jump
    local config_source = "legacy input preset"
    lurek.log.info("loaded " .. config_source .. " for " .. player)
    lurek.log.info("jump key = " .. jump_key)
end

--@api: lurek.serialize.encodeMsgPack
do
    local snapshot = { version = 2, entities = { { id = 1, hp = 100, x = 16, y = 24 } } }
    local packed = lurek.serialize.encodeMsgPack(snapshot)
    local unpacked = lurek.serialize.decodeMsgPack(packed)
    local first = unpacked.entities[1]
    local position = first.x .. "," .. first.y
    lurek.log.info("msgpack snapshot version = " .. unpacked.version)
    lurek.log.info("entity #" .. first.id .. " hp=" .. first.hp .. " pos=" .. position)
end

--@api: lurek.serialize.decodeXml
do
    local doc = lurek.serialize.decodeXml('<tilemap width="32"><layer name="ground">solid</layer></tilemap>')
    local root_tag = doc.tag or doc.name or "unknown"
    local first_layer = doc.children and doc.children[1] or {}
    local layer_name = first_layer.attrs and first_layer.attrs.name or "missing"
    lurek.log.info("xml root = " .. root_tag .. " width=" .. tostring(doc.attrs.width))
    lurek.log.info("first layer = " .. layer_name .. " text=" .. tostring(first_layer.text))
end

--@api: lurek.serialize.encode
do
    local quest_state = { quest = "intro", count = 42, completed = false }
    local jsonOut = lurek.serialize.encode(quest_state, "json", { pretty = true })
    local restored = lurek.serialize.decode(jsonOut, "json")
    local detected = lurek.serialize.detectFormat(jsonOut)
    lurek.log.info("encoded quest payload as " .. tostring(detected))
    lurek.log.info("quest=" .. restored.quest .. " count=" .. restored.count)
end

--@api: lurek.serialize.detectFormat
do
    local json_format = lurek.serialize.detectFormat('{"key":"value"}')
    local ini_format = lurek.serialize.detectFormat("[video]\nvsync=true\n")
    local unknown_format = lurek.serialize.detectFormat("spawn goblin at x=4")
    local knows_unknown = unknown_format == nil
    lurek.log.info("detected formats: json=" .. tostring(json_format) .. ", ini=" .. tostring(ini_format))
    lurek.log.info("plain designer note unresolved = " .. tostring(knows_unknown))
end

--@api: lurek.serialize.validate
do
    local schema = {
        type = "table",
        fields = { name = { type = "string", required = true }, level = { type = "number", min = 1, max = 100 } },
    }
    local ok_valid = lurek.serialize.validate({ name = "Knight", level = 50 }, schema)
    local ok_invalid, err_invalid = lurek.serialize.validate({ name = "Knight", level = 150 }, schema)
    lurek.log.info("valid hero payload = " .. tostring(ok_valid))
    lurek.log.info("invalid payload rejected = " .. tostring(not ok_invalid) .. " err=" .. tostring(err_invalid))
end

--@api: lurek.serialize.applyDefaults
do
    local schema = { fields = { width = { default = 800 }, height = { default = 600 }, title = { default = "Untitled" } } }
    local filled = lurek.serialize.applyDefaults({ width = 1280 }, schema)
    lurek.log.info("width = " .. filled.width)
    lurek.log.info("height = " .. filled.height)
    lurek.log.info("title = " .. filled.title)
end

--@api: lurek.serialize.encodeChangeSet
do
    local changes = { schema = "network.v1", revision = 4, changes = {
        { objectId = 9, component = "position", operation = "set", payload = { x = 12, y = 5 } },
    } }
    local encoded = lurek.serialize.encodeChangeSet(changes, "json", { pretty = true })
    local decoded = lurek.serialize.decodeChangeSet(encoded, "json")
    lurek.log.info("changeset bytes=" .. #encoded .. " schema=" .. decoded.schema .. " rows=" .. #decoded.changes)
end

--@api: lurek.serialize.decodeChangeSet
do
    local encoded = lurek.serialize.encode({ schema = "save.v1", revision = 1, changes = {
        { objectId = 2, component = "alive", operation = "set", payload = true },
    } }, "json")
    local changes = lurek.serialize.decodeChangeSet(encoded, "json")
    local row = changes.changes[1]
    lurek.log.info("decoded schema=" .. changes.schema .. " object=" .. row.objectId .. " payload=" .. tostring(row.payload))
end

--@api: lurek.serialize.decode
do
    local jsonPayload = '{"auto": true, "score": 99}'
    local result = lurek.serialize.decode(jsonPayload)
    local bytes = lurek.serialize.encodeMsgPack({ hp = 10, mana = 4 })
    local stats = lurek.serialize.decode(bytes, "msgpack")
    lurek.log.info("auto-detected json score = " .. result.score)
    lurek.log.info("decoded msgpack stats hp=" .. stats.hp .. " mana=" .. stats.mana)
end

--- Serial Module: decode, decodeMsgPack, toCsv, toJson, toToml

--@api: lurek.serialize.decodeMsgPack
do
    local bytes = lurek.serialize.encodeMsgPack({ x = 1, y = 2, room = "spawn" })
    local decoded = lurek.serialize.decodeMsgPack(bytes)
    local room = decoded.room
    local sum = decoded.x + decoded.y
    lurek.log.info("spawn room = " .. room)
    lurek.log.info("decoded coordinates = " .. decoded.x .. "," .. decoded.y .. " sum=" .. sum)
end

--@api: lurek.serialize.toCsv
do
    local rows = { { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }
    local csv = lurek.serialize.toCsv(rows, ",", true)
    local restored = lurek.serialize.fromCsv(csv, ",", true)
    local has_header = csv:find("name", 1, true) ~= nil
    lurek.log.info("csv leaderboard rows = " .. #restored)
    lurek.log.info("header present = " .. tostring(has_header) .. ", top player = " .. restored[1].name)
end

--@api: lurek.serialize.toToml
do
    local settings = { version = "1.0", debug = false, game = { title = "Arena" } }
    local toml = lurek.serialize.toToml(settings)
    local restored = lurek.serialize.fromToml(toml)
    local has_version = toml:find("version", 1, true) ~= nil
    lurek.log.info("toml bytes = " .. #toml .. ", has version = " .. tostring(has_version))
    lurek.log.info("restored title = " .. restored.game.title)
end
--@api: lurek.serialize.canonicalEncode
do
    local first = { z = 2, a = 1, nested = { y = true, b = "ore" } }
    local second = { nested = { b = "ore", y = true }, a = 1, z = 2 }
    local encoded_first = lurek.serialize.canonicalEncode(first)
    local encoded_second = lurek.serialize.canonicalEncode(second)
    local stable = encoded_first == encoded_second
    lurek.log.info("canonical=" .. encoded_first)
    lurek.log.info("stable=" .. tostring(stable))
end

--@api: lurek.serialize.canonicalHash
do
    local checkpoint = { tick = 12, inventory = { ore = 4, coal = 2 } }
    local first = lurek.serialize.canonicalHash(checkpoint)
    local reordered = { inventory = { coal = 2, ore = 4 }, tick = 12 }
    local second = lurek.serialize.canonicalHash(reordered)
    local stable = first == second
    lurek.log.info("checkpoint hash=" .. first)
    lurek.log.info("stable=" .. tostring(stable))
end
