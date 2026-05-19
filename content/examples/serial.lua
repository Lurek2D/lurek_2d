-- content/examples/serial.lua
-- Auto-generated from content/examples2/serial_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/serial.lua

--- Serial Module: JSON, TOML, CSV, INI, MsgPack, XML, format detection, schema validation


--@api-stub: lurek.serial.fromJson
-- JSON parsing and encoding.
do
    local jsonStr = '{"name":"warrior","level":12,"alive":true,"items":["sword","shield"]}'
    local data = lurek.serial.fromJson(jsonStr)
    print("name = " .. data.name)
    print("level = " .. data.level)
    print("alive = " .. tostring(data.alive))
    print("items count = " .. #data.items)
    for i, item in ipairs(data.items) do
        print("  " .. i .. ": " .. item)
    end
    local encoded = lurek.serial.toJson(data)
    print("compact = " .. encoded)
    local pretty = lurek.serial.toJson(data, true)
    print("pretty:\n" .. pretty)

    -- Complex JSON round-trip. Focus: fromJson.
    local complex = {
        config = {
            window = { width = 1280, height = 720, fullscreen = false },
            audio = { volume = 0.8, mute = false },
        },
        players = {
            { id = 1, name = "Alice", scores = { 100, 200, 300 } },
            { id = 2, name = "Bob", scores = { 50, 150 } },
        },
    }
    local json = lurek.serial.toJson(complex, true)
    print("encoded length = " .. #json)
    local decoded = lurek.serial.fromJson(json)
    print("window width = " .. decoded.config.window.width)
    print("player 1 name = " .. decoded.players[1].name)
    print("player 2 scores = " .. #decoded.players[2].scores)
end

--@api-stub: lurek.serial.toJson
-- Complex JSON round-trip. Focus: toJson.
do
    local complex = {
        config = {
            window = { width = 1280, height = 720, fullscreen = false },
            audio = { volume = 0.8, mute = false },
        },
        players = {
            { id = 1, name = "Alice", scores = { 100, 200, 300 } },
            { id = 2, name = "Bob", scores = { 50, 150 } },
        },
    }
    local json = lurek.serial.toJson(complex, true)
    print("encoded length = " .. #json)
    local decoded = lurek.serial.fromJson(json)
    print("window width = " .. decoded.config.window.width)
    print("player 1 name = " .. decoded.players[1].name)
    print("player 2 scores = " .. #decoded.players[2].scores)
end

--@api-stub: lurek.serial.fromToml
-- TOML parsing and encoding.
do
    local tomlStr = [[
[game]
title = "Dungeon Quest"
version = "1.2.0"
debug = false

[window]
width = 1920
height = 1080
vsync = true

[audio]
master_volume = 0.9
music_volume = 0.7
sfx_volume = 1.0
]]
    local config = lurek.serial.fromToml(tomlStr)
    print("title = " .. config.game.title)
    print("version = " .. config.game.version)
    print("window = " .. config.window.width .. "x" .. config.window.height)
    print("vsync = " .. tostring(config.window.vsync))
    print("master vol = " .. config.audio.master_volume)
    local reEncoded = lurek.serial.toToml(config)
    print("re-encoded length = " .. #reEncoded)
    print("contains [game] = " .. tostring(reEncoded:find("%[game%]") ~= nil))
end

--@api-stub: lurek.serial.fromCsv
-- CSV parsing with and without headers.
do
    local csvWithHeaders = "name,age,city\nAlice,30,Warsaw\nBob,25,Krakow\nCarol,35,Gdansk"
    local rows = lurek.serial.fromCsv(csvWithHeaders, ",", true)
    print("rows with headers = " .. #rows)
    for _, row in ipairs(rows) do
        print("  " .. row.name .. " age=" .. row.age .. " city=" .. row.city)
    end
    local csvNoHeaders = "10,20,30\n40,50,60\n70,80,90"
    local plain = lurek.serial.fromCsv(csvNoHeaders, ",", false)
    print("plain rows = " .. #plain)
    for i, row in ipairs(plain) do
        print("  row " .. i .. ": " .. table.concat(row, ", "))
    end
    local output = lurek.serial.toCsv(rows, ",", true)
    print("re-encoded csv length = " .. #output)
    print("has header line = " .. tostring(output:find("name,age,city") ~= nil))

    -- Tab-separated and semicolon-separated.
    local tsv = "id\tproduct\tprice\n1\tSword\t150\n2\tShield\t80\n3\tPotion\t25"
    local items = lurek.serial.fromCsv(tsv, "\t", true)
    print("tsv items = " .. #items)
    print("item 1 = " .. items[1].product .. " @ " .. items[1].price)
    local semicolonData = "x;y;z\n1.0;2.5;3.7\n4.2;5.8;6.1"
    local coords = lurek.serial.fromCsv(semicolonData, ";", true)
    print("semicolon rows = " .. #coords)
    print("first point x=" .. coords[1].x .. " y=" .. coords[1].y)
end

--@api-stub: lurek.serial.fromIni
-- INI file parsing.
do
    local iniStr = [[
[player]
name = Hero
class = warrior
level = 15

[display]
resolution = 1080p
gamma = 1.2
fullscreen = true

[controls]
jump = space
attack = z
dash = x
]]
    local ini = lurek.serial.fromIni(iniStr)
    print("player name = " .. ini.player.name)
    print("player class = " .. ini.player.class)
    print("display res = " .. ini.display.resolution)
    print("gamma = " .. ini.display.gamma)
    print("jump key = " .. ini.controls.jump)
    print("attack key = " .. ini.controls.attack)
end

--@api-stub: lurek.serial.encodeMsgPack
-- Binary MsgPack serialization round-trip.
do
    local payload = {
        version = 2,
        entities = {
            { id = 1, x = 10.5, y = 20.3, hp = 100 },
            { id = 2, x = 30.0, y = 40.7, hp = 50 },
        },
        timestamp = 1234567890,
    }
    local packed = lurek.serial.encodeMsgPack(payload)
    print("packed type = " .. type(packed))
    print("packed length = " .. #packed)
    local unpacked = lurek.serial.decodeMsgPack(packed)
    print("version = " .. unpacked.version)
    print("entities = " .. #unpacked.entities)
    print("entity 1 x = " .. unpacked.entities[1].x)
    print("timestamp = " .. unpacked.entities[2].hp)
end

--@api-stub: lurek.serial.decodeXml
-- XML to table conversion.
do
    local xml = [[
<tilemap width="10" height="8">
  <layer name="ground" visible="true">
    <tile x="0" y="0" id="1"/>
    <tile x="1" y="0" id="2"/>
    <tile x="2" y="0" id="1"/>
  </layer>
  <layer name="objects" visible="true">
    <tile x="5" y="3" id="10"/>
  </layer>
</tilemap>
]]
    local doc = lurek.serial.decodeXml(xml)
    print("root tag = " .. (doc.tag or doc.name or "unknown"))
    print("decoded xml type = " .. type(doc))
end

--@api-stub: lurek.serial.encode
-- Generic encode/decode with format parameter.
do
    local data = { greeting = "hello", count = 42, active = true }
    local jsonOut = lurek.serial.encode(data, "json")
    print("json encode = " .. jsonOut)
    local tomlOut = lurek.serial.encode(data, "toml")
    print("toml encode length = " .. #tomlOut)
    local backFromJson = lurek.serial.decode(jsonOut, "json")
    print("greeting = " .. backFromJson.greeting)
    print("count = " .. backFromJson.count)
    local backFromToml = lurek.serial.decode(tomlOut, "toml")
    print("active = " .. tostring(backFromToml.active))
end

--@api-stub: lurek.serial.detectFormat
-- Automatic format detection.
do
    local jsonSample = '{"key": "value"}'
    local tomlSample = '[section]\nkey = "value"'
    local csvSample = "a,b,c\n1,2,3"
    print("json detected = " .. lurek.serial.detectFormat(jsonSample))
    print("toml detected = " .. lurek.serial.detectFormat(tomlSample))
    print("csv detected = " .. lurek.serial.detectFormat(csvSample))
end

--@api-stub: lurek.serial.validate
-- Schema-based validation.
do
    local schema = {
        type = "object",
        required = { "name", "level" },
        properties = {
            name = { type = "string" },
            level = { type = "number", minimum = 1, maximum = 100 },
            class = { type = "string" },
        },
    }
    local valid = { name = "Knight", level = 50, class = "warrior" }
    local ok, err = lurek.serial.validate(valid, schema)
    print("valid data ok = " .. tostring(ok))
    print("valid err = " .. tostring(err))
    local invalid = { name = "Mage", level = 200 }
    ok, err = lurek.serial.validate(invalid, schema)
    print("invalid ok = " .. tostring(ok))
    print("invalid err = " .. err)
    local missing = { level = 10 }
    ok, err = lurek.serial.validate(missing, schema)
    print("missing ok = " .. tostring(ok))
    print("missing err = " .. err)
end

--@api-stub: lurek.serial.applyDefaults
-- Filling in default values from schema.
do
    local schema = {
        fields = {
            width = { default = 800 },
            height = { default = 600 },
            title = { default = "Untitled" },
            vsync = { default = true },
        },
    }
    local partial = { width = 1280, title = "My Game" }
    local filled = lurek.serial.applyDefaults(partial, schema)
    print("width = " .. filled.width)
    print("height = " .. filled.height)
    print("title = " .. filled.title)
    print("vsync = " .. tostring(filled.vsync))
    local empty = {}
    local allDefaults = lurek.serial.applyDefaults(empty, schema)
    print("all defaults width = " .. allDefaults.width)
    print("all defaults height = " .. allDefaults.height)
end

--@api-stub: lurek.serial.decode
-- Decode without specifying format.
do
    local jsonPayload = '{"auto": true, "score": 99}'
    local result = lurek.serial.decode(jsonPayload)
    print("auto-detected json: auto = " .. tostring(result.auto))
    print("score = " .. result.score)
end

--- Serial Module: decode, decodeMsgPack, toCsv, toJson, toToml


--@api-stub: lurek.serial.decodeMsgPack
-- Decode binary or formatted payload into a Lua table.
do
    local ok, t = lurek.serial.decode('{"key": 1}', "json")
    print("decode ok=" .. tostring(ok))
    local bytes = lurek.serial.encodeMsgPack({ x = 1, y = 2 })
    local ok2, t2 = lurek.serial.decodeMsgPack(bytes)
    print("msgpack ok=" .. tostring(ok2))
end

--@api-stub: lurek.serial.toCsv
-- Serialize a table to CSV, JSON, or TOML string. Focus: toCsv.
do
    local data = { { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }
    local csv = lurek.serial.toCsv(data, ",", true)
    print("csv lines = " .. #csv)
    local json = lurek.serial.toJson({ a = 1, b = "hello" }, true)
    print("json = " .. json)
    local toml = lurek.serial.toToml({ version = "1.0", debug = false })
    print("toml = " .. toml)
end

--@api-stub: lurek.serial.toToml
-- Serialize a table to CSV, JSON, or TOML string. Focus: toToml.
do
    local data = { { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }
    local csv = lurek.serial.toCsv(data, ",", true)
    print("csv lines = " .. #csv)
    local json = lurek.serial.toJson({ a = 1, b = "hello" }, true)
    print("json = " .. json)
    local toml = lurek.serial.toToml({ version = "1.0", debug = false })
    print("toml = " .. toml)
end

print("content/examples/serial.lua")
