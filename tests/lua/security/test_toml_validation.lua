-- Lurek2D Validation Test: Corrupted and Malformed TOML
-- Tests that the TOML parser handles invalid input gracefully
-- @security lurek.data.encodeToml
-- @security lurek.data.parseToml


-- @description Covers suite: validation: corrupted TOML.
describe("validation: corrupted TOML", function()
    -- @covers lurek.data.parseToml
    -- @description Parses an empty TOML document to verify the parser treats empty input as benign instead of erroring or crashing.
    it("rejects empty string", function()
        -- Empty TOML should parse as empty table, not crash
        expect_no_error(function()
            local result = lurek.data.parseToml("")
        end)
    end)

    -- @covers lurek.data.parseToml
    -- @description Feeds an unfinished key-value pair to verify malformed assignments fail with a parser error.
    it("rejects incomplete key-value", function()
        expect_error(function()
            lurek.data.parseToml("key = ")
        end, "incomplete key-value should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Uses an unterminated string literal to exercise string scanning and error reporting on malformed documents.
    it("rejects unclosed string", function()
        expect_error(function()
            lurek.data.parseToml('name = "unclosed')
        end, "unclosed string should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Provides a broken table header to confirm section parsing rejects incomplete bracket syntax.
    it("rejects unclosed table header", function()
        expect_error(function()
            lurek.data.parseToml("[section\nkey = 1")
        end, "unclosed table header should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Declares the same key twice to ensure duplicate definitions are detected rather than silently overwritten.
    it("rejects duplicate keys", function()
        expect_error(function()
            lurek.data.parseToml("key = 1\nkey = 2")
        end, "duplicate keys should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Uses an invalid floating-point literal to exercise numeric parsing rejection paths.
    it("rejects invalid number format", function()
        expect_error(function()
            lurek.data.parseToml("num = 12.34.56")
        end, "invalid number should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Sends binary garbage bytes through the TOML parser to verify hostile non-text payloads are rejected safely.
    it("rejects binary garbage", function()
        expect_error(function()
            lurek.data.parseToml("\x00\x01\x02\xFF\xFE")
        end, "binary garbage should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Combines deep nesting with malformed arrays to probe parser stability on structurally complex invalid input.
    it("rejects deeply nested invalid TOML", function()
        expect_error(function()
            lurek.data.parseToml("[a]\n[a.b]\n[a.b.c]\nkey = [[[invalid]]]")
        end, "deeply nested invalid syntax should error")
    end)

    -- @covers lurek.data.parseToml
    -- @description Parses an extremely long key name to ensure oversized identifiers do not crash the parser even if they are unusual.
    it("handles very long key names", function()
        local long_key = string.rep("k", 10000)
        expect_no_error(function()
            lurek.data.parseToml(long_key .. ' = "value"')
        end, "long key name should not crash")
    end)

    -- @covers lurek.data.parseToml
    -- @description Parses a document with a very long string value to test large-text handling inside the TOML decoder.
    it("handles very long values", function()
        local long_val = string.rep("v", 50000)
        expect_no_error(function()
            lurek.data.parseToml('key = "' .. long_val .. '"')
        end, "long value should not crash")
    end)
end)

-- @description Covers suite: validation: TOML edge cases.
describe("validation: TOML edge cases", function()
    -- @covers lurek.data.parseToml
    -- @description Parses the smallest valid TOML assignment to confirm the success path remains available after the malformed-input cases.
    it("parses valid minimal TOML", function()
        expect_no_error(function()
            local result = lurek.data.parseToml('x = 1')
            expect_not_nil(result, "minimal TOML parsed")
        end)
    end)

    -- @covers lurek.data.parseToml
    -- @description Parses a table containing mixed scalar and array types to verify ordinary structured documents still decode successfully.
    it("parses TOML with mixed types", function()
        expect_no_error(function()
            local toml_str = [[
                [section]
                integer = 42
                float = 3.14
                string = "hello"
                bool = true
                array = [1, 2, 3]
            ]]
            local result = lurek.data.parseToml(toml_str)
            expect_not_nil(result, "mixed type TOML parsed")
        end)
    end)

    -- @covers lurek.data.encodeToml
    -- @description Sends a string into TOML encoding to verify the serializer only accepts table-shaped data and rejects invalid roots.
    it("encodeToml rejects non-table input", function()
        -- encodeToml should only accept table values
        expect_error(function()
            lurek.data.encodeToml("not a table")
        end, "string input should error")
    end)
end)
