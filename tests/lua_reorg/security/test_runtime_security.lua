-- test_runtime.lua
-- Canonical file. Merged from multiple sources.

-- Lurek2D Validation Test: Corrupted and Malformed TOML
-- Tests that the TOML parser handles invalid input gracefully

-- @describe validation: corrupted TOML
describe("validation: corrupted TOML", function()
    -- @security lurek.binary.parseToml
    it("validates malformed, oversized, and valid TOML payloads safely", function()
        -- Empty TOML should parse as empty table, not crash
        expect_no_error(function()
            lurek.binary.parseToml("")
        end)
        expect_error(function()
            lurek.binary.parseToml("key = ")
        end, "incomplete key-value should error")
        expect_error(function()
            lurek.binary.parseToml('name = "unclosed')
        end, "unclosed string should error")
        expect_error(function()
            lurek.binary.parseToml("[section\nkey = 1")
        end, "unclosed table header should error")
        expect_error(function()
            lurek.binary.parseToml("key = 1\nkey = 2")
        end, "duplicate keys should error")
        expect_error(function()
            lurek.binary.parseToml("num = 12.34.56")
        end, "invalid number should error")
        expect_error(function()
            lurek.binary.parseToml("\x00\x01\x02\xFF\xFE")
        end, "binary garbage should error")
        expect_error(function()
            lurek.binary.parseToml("[a]\n[a.b]\n[a.b.c]\nkey = [[[invalid]]]")
        end, "deeply nested invalid syntax should error")
        local long_key = string.rep("k", 10000)
        expect_no_error(function()
            lurek.binary.parseToml(long_key .. ' = "value"')
        end, "long key name should not crash")
        local long_val = string.rep("v", 50000)
        expect_no_error(function()
            lurek.binary.parseToml('key = "' .. long_val .. '"')
        end, "long value should not crash")

        expect_no_error(function()
            local result = lurek.binary.parseToml('x = 1')
            expect_not_nil(result, "minimal TOML parsed")
        end)
        expect_no_error(function()
            local toml_str = [[
                [section]
                integer = 42
                float = 3.14
                string = "hello"
                bool = true
                array = [1, 2, 3]
            ]]
            local result = lurek.binary.parseToml(toml_str)
            expect_not_nil(result, "mixed type TOML parsed")
        end)
        expect_error(function()
            lurek.binary.parseToml('["../../escape" = "x"')
        end)
    end)
end)

-- @describe validation: TOML edge cases
describe("validation: TOML edge cases", function()
    -- @security lurek.binary.encodeToml
    it("encodeToml rejects unsupported input values", function()
        -- encodeToml should only accept table values
        local bad_input = "not a table" ---@type any
        expect_error(function()
            lurek.binary.encodeToml(bad_input)
        end, "string input should error")
        expect_error(function()
            lurek.binary.encodeToml({ cb = function() end })
        end)
    end)
end)
test_summary()
