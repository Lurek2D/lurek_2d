-- Golden test: data compare-only evidence validation.

-- @description Compares the Lua-generated TOML round-trip evidence file against the migrated Rust sample now stored under Lua golden samples.
describe("golden: data TOML round-trip", function()
    -- @golden
    -- @description Compares toml_roundtrip.toml from the evidence layer against the committed migrated Rust sample.
    it("matches migrated Rust TOML sample", function()
        local evidence = "save/golden_text/migrated_rust/data/toml_roundtrip.toml"
        local golden = "tests/lua/golden/samples/migrated_rust/data/toml_roundtrip.toml"
        expect_golden_text_match(evidence, golden)
    end)
end)
test_summary()
