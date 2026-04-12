-- Golden test: migrated Rust text and binary baselines now compared from the Lua golden layer only.

-- @description Compares Lua-generated migrated_rust evidence artifacts against the committed Lua golden samples copied from the former Rust golden baselines.
describe("golden: migrated Rust baselines", function()
    -- @golden
    -- @description Compares the Lua-generated TOML round-trip evidence file against the migrated Rust sample baseline.
    it("matches migrated Rust TOML sample", function()
        expect_golden_text_match("save/golden_text/migrated_rust/data/toml_roundtrip.toml", "tests/lua/golden/samples/migrated_rust/data/toml_roundtrip.toml")
    end)

    -- @golden
    -- @description Compares the Lua-generated base64 and hex encoding outputs against the migrated Rust sample baselines.
    it("matches migrated Rust encode samples", function()
        expect_golden_text_match("save/golden_text/migrated_rust/encode/base64_encode.txt", "tests/lua/golden/samples/migrated_rust/encode/base64_encode.txt")
        expect_golden_text_match("save/golden_text/migrated_rust/encode/hex_encode.txt", "tests/lua/golden/samples/migrated_rust/encode/hex_encode.txt")
    end)

    -- @golden
    -- @description Compares the Lua-generated digest outputs against the migrated Rust hash sample baselines.
    it("matches migrated Rust hash samples", function()
        expect_golden_text_match("save/golden_text/migrated_rust/hash/md5_hello.txt", "tests/lua/golden/samples/migrated_rust/hash/md5_hello.txt")
        expect_golden_text_match("save/golden_text/migrated_rust/hash/sha1_engine.txt", "tests/lua/golden/samples/migrated_rust/hash/sha1_engine.txt")
        expect_golden_text_match("save/golden_text/migrated_rust/hash/sha256_hello.txt", "tests/lua/golden/samples/migrated_rust/hash/sha256_hello.txt")
        expect_golden_text_match("save/golden_text/migrated_rust/hash/sha512_engine.txt", "tests/lua/golden/samples/migrated_rust/hash/sha512_engine.txt")
    end)

end)

test_summary()
