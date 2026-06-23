-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_serialize_core_unit.lua
do
-- lurek.serialize API unit tests.
-- Canonical one-owner behavioral coverage for headless-safe serialization helpers.

-- @describe lurek.serialize JSON helpers
describe("lurek.serialize JSON helpers", function()
    -- @covers lurek.serialize.fromJson
    it("fromJson parses objects and arrays and uses only the canonical serialize namespace", function()
        expect_type("table", lurek.serialize)
        expect_equal(nil, lurek.serial)
        expect_type("function", lurek.serialize.fromJson)

        local obj = lurek.serialize.fromJson('{"name":"luna","version":1}')
        expect_type("table", obj)
        expect_equal("luna", obj.name)
        expect_equal(1, obj.version)

        local arr = lurek.serialize.fromJson("[1,2,3]")
        expect_type("table", arr)
        expect_equal(1, arr[1])
        expect_equal(3, arr[3])

        expect_error(function()
            lurek.serialize.fromJson("not json {{{")
        end)
    end)

    -- @covers lurek.serialize.toJson
    it("toJson serializes nested tables and supports pretty output", function()
        expect_type("function", lurek.serialize.toJson)

        local nested = {
            meta = { version = 2, engine = "lurek" },
            data = { { x = 1, y = 2 }, { x = 3, y = 4 } },
        }

        local compact = lurek.serialize.toJson(nested, false)
        local pretty = lurek.serialize.toJson(nested, true)
        expect_type("string", compact)
        expect_type("string", pretty)
        expect_true(#compact > 0)
        expect_true(#pretty >= #compact)

        local decoded = lurek.serialize.fromJson(compact)
        expect_equal(2, decoded.meta.version)
        expect_equal("lurek", decoded.meta.engine)
        expect_equal(4, decoded.data[2].y)

        local cyclic = {}
        cyclic.self = cyclic
        expect_error(function()
            lurek.serialize.toJson(cyclic, false)
        end)

        expect_error(function()
            lurek.serialize.toJson({ bad = math.huge }, false)
        end)
    end)
end)

-- @describe lurek.serialize TOML helpers
describe("lurek.serialize TOML helpers", function()
    -- @covers lurek.serialize.fromToml
    it("fromToml parses tables and rejects malformed input", function()
        expect_type("function", lurek.serialize.fromToml)

        local t = lurek.serialize.fromToml('[window]\ntitle = "Lurek2D"\nwidth = 800\n')
        expect_type("table", t)
        expect_type("table", t.window)
        expect_equal("Lurek2D", t.window.title)
        expect_equal(800, t.window.width)

        expect_error(function()
            lurek.serialize.fromToml("[[broken = = ]]")
        end)
    end)

    -- @covers lurek.serialize.toToml
    it("toToml serializes tables and round-trips scalar values", function()
        expect_type("function", lurek.serialize.toToml)

        local s = lurek.serialize.toToml({ game = { fps = 60 }, score = 100 })
        expect_type("string", s)
        expect_true(#s > 0)

        local back = lurek.serialize.fromToml(s)
        expect_equal(60, back.game.fps)
        expect_equal(100, back.score)
    end)
end)

-- @describe lurek.serialize INI helper
describe("lurek.serialize INI helper", function()
    -- @covers lurek.serialize.fromIni
    it("fromIni parses sectioned ini text", function()
        local cfg = lurek.serialize.fromIni("[player]\nname=hero\n")
        expect_equal("hero", cfg.player.name)
    end)
end)

-- @describe lurek.serialize CSV helpers
describe("lurek.serialize CSV helpers", function()
    -- @covers lurek.serialize.fromCsv
    it("fromCsv supports headers, no headers, and custom delimiters", function()
        expect_type("function", lurek.serialize.fromCsv)

        local rows = lurek.serialize.fromCsv("name,score\nalice,10\nbob,20\n", nil, true)
        expect_true(#rows >= 2)
        expect_equal("alice", rows[1].name)
        expect_equal("10", rows[1].score)

        local raw_rows = lurek.serialize.fromCsv("alice,10\nbob,20\n", nil, false)
        expect_true(#raw_rows >= 2)
        expect_not_nil(raw_rows[1][1])

        local tsv = lurek.serialize.fromCsv("name\tscore\nalice\t10\nbob\t20\n", "\t", true)
        expect_equal("alice", tsv[1].name)
    end)

    -- @covers lurek.serialize.toCsv
    it("toCsv serializes row tables and round-trips them", function()
        expect_type("function", lurek.serialize.toCsv)

        local data = {
            { name = "test", value = "42" },
            { name = "next", value = "7" },
        }
        local csv = lurek.serialize.toCsv(data)
        expect_type("string", csv)
        expect_true(#csv > 0)

        local back = lurek.serialize.fromCsv(csv)
        expect_equal("test", back[1].name)
        expect_equal("42", back[1].value)
    end)
end)

-- @describe lurek.serialize MsgPack helpers
describe("lurek.serialize MsgPack helpers", function()
    -- @covers lurek.serialize.encodeMsgPack
    it("encodeMsgPack serializes tables and rejects unsupported input", function()
        local bytes = lurek.serialize.encodeMsgPack({ name = "hero", level = 5 })
        expect_equal("string", type(bytes))
        expect_true(#bytes > 0)

        expect_error(function()
            lurek.serialize.encodeMsgPack(nil)
        end)
        expect_error(function()
            lurek.serialize.encodeMsgPack("not a table")
        end)
        expect_error(function()
            lurek.serialize.encodeMsgPack(42)
        end)
    end)

    -- @covers lurek.serialize.decodeMsgPack
    it("decodeMsgPack round-trips structured data and rejects invalid bytes", function()
        local tbl = {
            name = "hero",
            level = 5,
            pos = { x = 10, y = 20 },
            items = { "sword", "shield", "potion" },
        }
        local decoded = lurek.serialize.decodeMsgPack(lurek.serialize.encodeMsgPack(tbl))
        expect_equal("hero", decoded.name)
        expect_equal(5, decoded.level)
        expect_equal(10, decoded.pos.x)
        expect_equal("shield", decoded.items[2])

        expect_error(function()
            lurek.serialize.decodeMsgPack("\xc1\xc1\xc1")
        end)
    end)
end)

-- @describe lurek.serialize schema helper
describe("lurek.serialize schema helper", function()
    -- @covers lurek.serialize.validate
    it("validate enforces type, required, range, length, fields, and items", function()
        local ok, err = lurek.serialize.validate("hello", { type = "string" })
        expect_equal(true, ok)
        expect_equal(nil, err)

        ok, err = lurek.serialize.validate(42, { type = "string" })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serialize.validate(nil, { type = "string" })
        expect_equal(true, ok)

        ok, err = lurek.serialize.validate(nil, { type = "string", required = true })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serialize.validate(50, { type = "number", min = 1, max = 100 })
        expect_equal(true, ok)
        ok, err = lurek.serialize.validate(101, { type = "number", min = 1, max = 100 })
        expect_equal(false, ok)
        expect_type("string", err)

        ok = lurek.serialize.validate("abc", { type = "string", minlen = 1, maxlen = 10 })
        expect_equal(true, ok)
        ok, err = lurek.serialize.validate("toolong", { type = "string", maxlen = 3 })
        expect_equal(false, ok)
        expect_type("string", err)

        local table_schema = {
            type = "table",
            fields = {
                name = { type = "string", required = true },
                level = { type = "number", min = 1, max = 100 },
            }
        }
        expect_equal(true, lurek.serialize.validate({ name = "hero", level = 5 }, table_schema))
        ok, err = lurek.serialize.validate({ level = 5 }, table_schema)
        expect_equal(false, ok)
        expect_type("string", err)

        local list_schema = { type = "table", items = { type = "string" } }
        expect_equal(true, lurek.serialize.validate({ "a", "b", "c" }, list_schema))
        ok, err = lurek.serialize.validate({ "a", 2, "c" }, list_schema)
        expect_equal(false, ok)
        expect_type("string", err)
    end)
end)

-- @describe lurek.serialize XML helper
describe("lurek.serialize XML helper", function()
    -- @covers lurek.serialize.decodeXml
    it("decodeXml captures tags, text, attrs, children, and malformed input", function()
        local root = lurek.serialize.decodeXml('<player id="1" name="hero">ready</player>')
        expect_equal("player", root.tag)
        expect_equal("ready", root.text)
        expect_equal("1", root.attrs.id)
        expect_equal("hero", root.attrs.name)

        local nested = lurek.serialize.decodeXml("<items><item>sword</item><item>shield</item></items>")
        expect_equal("items", nested.tag)
        expect_equal(2, #nested.children)
        expect_equal("item", nested.children[1].tag)
        expect_equal("shield", nested.children[2].text)

        local leaf = lurek.serialize.decodeXml("<leaf>text</leaf>")
        expect_equal(nil, leaf.children)

        expect_error(function()
            lurek.serialize.decodeXml("<unclosed")
        end)
        expect_error(function()
            lurek.serialize.decodeXml("<a></b>")
        end)
    end)
end)

-- @describe lurek.serialize unified codec helpers
describe("lurek.serialize unified codec helpers", function()
    -- @covers lurek.serialize.detectFormat
    it("detectFormat identifies known formats and ignores unknown text", function()
        expect_equal("json", lurek.serialize.detectFormat('{"name":"hero"}'))
        expect_equal(nil, lurek.serialize.detectFormat("hello world"))
    end)

    -- @covers lurek.serialize.decode
    it("decode supports auto-detected and explicit formats", function()
        local toml = lurek.serialize.decode('title = "demo"')
        expect_equal("demo", toml.title)

        local ini = lurek.serialize.decode("[player]\nname=hero\n", "ini")
        expect_equal("hero", ini.player.name)

        local bytes = lurek.serialize.encodeMsgPack({ hp = 10 })
        local msgpack = lurek.serialize.decode(bytes, "msgpack")
        expect_equal(10, msgpack.hp)

        local patched = lurek.serialize.decode('{"name":"hero"}', "json", {
            schema = {
                type = "table",
                fields = {
                    name = { type = "string", required = true },
                    hp = { type = "number", default = 10 },
                },
            },
        })
        expect_equal("hero", patched.name)
        expect_equal(10, patched.hp)

        expect_error(function()
            lurek.serialize.decode("title = \"demo\"", nil, {
                allowed_formats = { "json", "toml" },
                max_detect_attempts = 1,
            })
        end)

        expect_error(function()
            lurek.serialize.decode("name,score\nada,10\nlin,20\n", "csv", {
                max_rows = 1,
            })
        end)

        expect_error(function()
            lurek.serialize.decode("name,score\nada,toolong\n", "csv", {
                max_field_chars = 3,
            })
        end)
    end)

    -- @covers lurek.serialize.encode
    it("encode supports json pretty output and csv options", function()
        local json = lurek.serialize.encode({ a = 1 }, "json", { pretty = true })
        expect_equal("string", type(json))
        expect_true(#json > 0)

        local rows = {
            { name = "ada", score = "10" },
            { name = "lin", score = "20" },
        }
        local csv = lurek.serialize.encode(rows, "csv", { delimiter = ";", has_headers = true })
        expect_true(string.find(csv, ";", 1, true) ~= nil)

        local big = {}
        for i = 1, 20 do
            big[i] = i
        end
        expect_error(function()
            lurek.serialize.encode(big, "json", { max_sequence_len = 10 })
        end)

        expect_error(function()
            lurek.serialize.encode({
                { name = "ada", payload = { nested = true } },
            }, "csv")
        end)

        local csv_nested = lurek.serialize.encode({
            { name = "ada", payload = { nested = true } },
        }, "csv", {
            complex_cells = "json",
        })
        local decoded_rows = lurek.serialize.fromCsv(csv_nested)
        local payload = lurek.serialize.fromJson(decoded_rows[1].payload)
        expect_equal(true, payload.nested)
    end)

    -- @covers lurek.serialize.applyDefaults
    it("applyDefaults fills missing fields from schema defaults", function()
        local schema = {
            type = "table",
            fields = {
                hp = { type = "number", default = 100 },
                name = { type = "string", default = "hero" },
            },
        }
        local patched = lurek.serialize.applyDefaults({}, schema)
        expect_equal(100, patched.hp)
        expect_equal("hero", patched.name)
    end)
end)
end
-- END test_serialize_core_unit.lua

test_summary()
