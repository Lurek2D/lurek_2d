-- Golden test: serial compare-only evidence validation.

-- @description Compares Lua-generated base64 and hex evidence outputs against the migrated Rust serial baselines now stored under Lua golden samples.
describe("golden: serial Encode/decode deterministic output", function()
    -- @golden
    -- @description Compares the migrated Rust base64 and hex evidence files against their committed Lua golden samples.
    it("matches migrated Rust encode samples", function()
        expect_golden_text_match("save/golden_text/migrated_rust/encode/base64_encode.txt", "tests/samples/migrated_rust/encode/base64_encode.txt")
        expect_golden_text_match("save/golden_text/migrated_rust/encode/hex_encode.txt", "tests/samples/migrated_rust/encode/hex_encode.txt")
    end)
end)

test_summary()
