-- @covers lurek.codec.fromCsv
-- @covers lurek.codec.fromJson
-- @covers lurek.codec.fromToml
-- @covers lurek.codec.toCsv
-- @covers lurek.codec.toJson
-- @covers lurek.codec.toToml

-- lurek.codec API unit tests
-- Headless-safe (no window / GPU / audio required).

-- @description Covers suite: lurek.codec module exists.
describe("lurek.codec module exists", function()
    -- @covers lurek.codec
    -- @description Verifies the codec namespace is available before format helpers are exercised.
    it("lurek.codec is a table", function()
        expect_type("table", lurek.codec)
    end)
end)

-- @description Covers suite: JSON round-trip.
describe("JSON round-trip", function()
    -- @covers lurek.codec.fromJson
    -- @description Verifies the JSON decoder is exposed as a callable function.
    it("fromJson is a function", function()
        expect_type("function", lurek.codec.fromJson)
    end)

    -- @covers lurek.codec.toJson
    -- @description Verifies the JSON encoder is exposed as a callable function.
    it("toJson is a function", function()
        expect_type("function", lurek.codec.toJson)
    end)

    -- @covers lurek.codec.fromJson
    -- @description Verifies fromJson decodes flat object members into named Lua table fields.
    it("fromJson parses a simple object", function()
        local t = lurek.codec.fromJson('{"name":"luna","version":1}')
        expect_type("table", t)
        expect_equal("luna", t.name)
        expect_equal(1, t.version)
    end)

    -- @covers lurek.codec.fromJson
    -- @description Verifies fromJson decodes JSON arrays into numeric Lua sequence entries.
    it("fromJson parses an array", function()
        local t = lurek.codec.fromJson('[1,2,3]')
        expect_type("table", t)
        expect_equal(1, t[1])
        expect_equal(3, t[3])
    end)

    -- @covers lurek.codec.toJson
    -- @description Verifies toJson serializes a Lua table into a non-empty JSON string.
    it("toJson serializes a table to a string", function()
        local s = lurek.codec.toJson({ x = 10, y = 20 })
        expect_type("string", s)
        expect_true(#s > 0, "json string is non-empty")
    end)

    -- @covers lurek.codec.toJson
    -- @covers lurek.codec.fromJson
    -- @description Verifies a JSON round-trip preserves string-valued object fields.
    it("JSON round-trip preserves string values", function()
        local orig = { greeting = "hello" }
        local json = lurek.codec.toJson(orig)
        local back = lurek.codec.fromJson(json)
        expect_equal("hello", back.greeting)
    end)

    -- @covers lurek.codec.toJson
    -- @covers lurek.codec.fromJson
    -- @description Verifies a JSON round-trip preserves numeric object fields.
    it("JSON round-trip preserves numbers", function()
        local orig = { val = 42 }
        local json = lurek.codec.toJson(orig)
        local back = lurek.codec.fromJson(json)
        expect_equal(42, back.val)
    end)

    -- @covers lurek.codec.toJson
    -- @description Verifies pretty-print mode produces output no shorter than the compact encoding.
    it("toJson with pretty=true produces longer output", function()
        local t = { a = 1, b = 2 }
        local compact = lurek.codec.toJson(t, false)
        local pretty  = lurek.codec.toJson(t, true)
        expect_true(#pretty >= #compact, "pretty >= compact length")
    end)

    -- @covers lurek.codec.fromJson
    -- @description Verifies malformed JSON input raises a Lua-side error instead of returning junk data.
    it("fromJson returns error on invalid JSON", function()
        expect_error(function()
            lurek.codec.fromJson("not json {{{")
        end)
    end)
end)

-- @description Covers suite: TOML round-trip.
describe("TOML round-trip", function()
    -- @covers lurek.codec.fromToml
    -- @description Verifies the TOML decoder is exposed as a callable function.
    it("fromToml is a function", function()
        expect_type("function", lurek.codec.fromToml)
    end)

    -- @covers lurek.codec.toToml
    -- @description Verifies the TOML encoder is exposed as a callable function.
    it("toToml is a function", function()
        expect_type("function", lurek.codec.toToml)
    end)

    -- @covers lurek.codec.fromToml
    -- @description Verifies fromToml parses nested table syntax into nested Lua tables.
    it("fromToml parses a simple table", function()
        local t = lurek.codec.fromToml('[window]\ntitle = "Lurek2D"\nwidth = 800\n')
        expect_type("table", t)
        expect_type("table", t.window)
        expect_equal("Lurek2D", t.window.title)
        expect_equal(800, t.window.width)
    end)

    -- @covers lurek.codec.toToml
    -- @description Verifies toToml serializes Lua tables into non-empty TOML text.
    it("toToml serializes a table", function()
        local s = lurek.codec.toToml({ game = { fps = 60 } })
        expect_type("string", s)
        expect_true(#s > 0, "toml string is non-empty")
    end)

    -- @covers lurek.codec.toToml
    -- @covers lurek.codec.fromToml
    -- @description Verifies a TOML round-trip preserves scalar values.
    it("TOML round-trip preserves scalar values", function()
        local orig = { score = 100 }
        local toml = lurek.codec.toToml(orig)
        local back = lurek.codec.fromToml(toml)
        expect_equal(100, back.score)
    end)

    -- @covers lurek.codec.fromToml
    -- @description Verifies malformed TOML input raises an error.
    it("fromToml returns error on invalid TOML", function()
        expect_error(function()
            lurek.codec.fromToml("[[broken = = ]]")
        end)
    end)
end)

-- @description Covers suite: CSV round-trip.
describe("CSV round-trip", function()
    -- @covers lurek.codec.fromCsv
    -- @description Verifies the CSV decoder is exposed as a callable function.
    it("fromCsv is a function", function()
        expect_type("function", lurek.codec.fromCsv)
    end)

    -- @covers lurek.codec.toCsv
    -- @description Verifies the CSV encoder is exposed as a callable function.
    it("toCsv is a function", function()
        expect_type("function", lurek.codec.toCsv)
    end)

    -- @covers lurek.codec.fromCsv
    -- @description Verifies fromCsv parses delimited rows into a Lua table result.
    it("fromCsv parses rows", function()
        local csv = "name,score\nalice,10\nbob,20\n"
        local rows = lurek.codec.fromCsv(csv)
        expect_type("table", rows)
        expect_true(#rows >= 1, "has at least one row")
    end)

    -- @covers lurek.codec.toCsv
    -- @description Verifies toCsv serializes row tables into non-empty CSV text.
    it("toCsv produces a non-empty string", function()
        local data = { { name = "a", score = "1" }, { name = "b", score = "2" } }
        local s = lurek.codec.toCsv(data)
        expect_type("string", s)
        expect_true(#s > 0, "csv string is non-empty")
    end)
end)

-- â”€â”€ CSV options â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: CSV advanced options.
describe("CSV advanced options", function()
    -- @covers lurek.codec.fromCsv
    -- @description Verifies header-aware CSV parsing maps column names onto each returned row table.
    it("fromCsv with headers creates object-keyed rows", function()
        local csv = "name,score\nalice,10\nbob,20\n"
        local rows = lurek.codec.fromCsv(csv, nil, true)
        expect_true(#rows >= 2)
        expect_equal("alice", rows[1].name)
        expect_equal("10", rows[1].score)
    end)

    -- @covers lurek.codec.fromCsv
    -- @description Verifies headerless CSV parsing preserves positional fields as numeric indexes.
    it("fromCsv without headers creates numeric keys", function()
        local csv = "alice,10\nbob,20\n"
        local rows = lurek.codec.fromCsv(csv, nil, false)
        expect_true(#rows >= 2)
        expect_not_nil(rows[1][1])
    end)

    -- @covers lurek.codec.fromCsv
    -- @description Verifies fromCsv honors a caller-supplied delimiter instead of assuming commas.
    it("fromCsv with custom delimiter", function()
        local csv = "name\tscore\nalice\t10\nbob\t20\n"
        local rows = lurek.codec.fromCsv(csv, "\t", true)
        expect_true(#rows >= 2)
        expect_equal("alice", rows[1].name)
    end)

    -- @covers lurek.codec.toCsv
    -- @covers lurek.codec.fromCsv
    -- @description Verifies CSV serialization and parsing preserve field values across a round-trip.
    it("CSV round-trip preserves data", function()
        local data = { { name = "test", value = "42" } }
        local csv = lurek.codec.toCsv(data)
        local back = lurek.codec.fromCsv(csv)
        expect_equal("test", back[1].name)
        expect_equal("42", back[1].value)
    end)
end)

-- â”€â”€ error handling â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: codec error handling.
describe("codec error handling", function()
    -- @covers lurek.codec.fromJson
    -- @description Verifies malformed JSON with invalid tokens raises an error.
    it("fromJson error on malformed input", function()
        expect_error(function()
            lurek.codec.fromJson("{bad: json}")
        end)
    end)

    -- @covers lurek.codec.fromToml
    -- @description Verifies malformed TOML with an incomplete array raises an error.
    it("fromToml error on malformed input", function()
        expect_error(function()
            lurek.codec.fromToml("invalid = [")
        end)
    end)

    -- @covers lurek.codec.fromJson
    -- @description Verifies empty JSON input is rejected instead of decoding to a default value.
    it("fromJson on empty string errors", function()
        expect_error(function()
            lurek.codec.fromJson("")
        end)
    end)
end)

-- YAML removed: design-assumption B-05 (TOML is the human-authored config format; serde_yml dependency dropped)

test_summary()
