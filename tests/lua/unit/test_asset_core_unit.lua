-- test_asset_core_unit.lua
-- Unit tests for lurek.asset: one test per public API method.

describe("lurek.asset module", function()

    -- ─── Module presence ───────────────────────────────────────────────────

    it("lurek.asset is a table", function()
        expect_type("table", lurek.asset)
    end)

    it("lurek.asset.load is a function", function()
        expect_type("function", lurek.asset.load)
    end)

    it("lurek.asset.unload is a function", function()
        expect_type("function", lurek.asset.unload)
    end)

    it("lurek.asset.get is a function", function()
        expect_type("function", lurek.asset.get)
    end)

    it("lurek.asset.preload is a function", function()
        expect_type("function", lurek.asset.preload)
    end)

    it("lurek.asset.refcount is a function", function()
        expect_type("function", lurek.asset.refcount)
    end)

    it("lurek.asset.isLoaded is a function", function()
        expect_type("function", lurek.asset.isLoaded)
    end)

    it("lurek.asset.stats is a function", function()
        expect_type("function", lurek.asset.stats)
    end)

    it("lurek.asset.clear is a function", function()
        expect_type("function", lurek.asset.clear)
    end)

    -- ─── load / handle basics ──────────────────────────────────────────────

    it("load a text file returns LAssetHandle", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_not_nil(handle, "handle should not be nil")
        expect_equal("LAssetHandle", handle:type())
    end)

    it("handle:typeOf('LAssetHandle') returns true", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(true, handle:typeOf("LAssetHandle"))
    end)

    it("handle:typeOf('LObject') returns true", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(true, handle:typeOf("LObject"))
    end)

    it("handle:typeOf('unknown') returns false", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(false, handle:typeOf("unknown"))
    end)

    -- ─── isLoaded / refcount ───────────────────────────────────────────────

    it("isLoaded returns true after load", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
    end)

    it("refcount returns 1 after initial load", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(1, lurek.asset.refcount(handle))
    end)

    -- ─── unload ────────────────────────────────────────────────────────────

    it("unload reduces refcount to 0 and asset is no longer loaded", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
        lurek.asset.unload(handle)
        expect_equal(false, lurek.asset.isLoaded(handle))
        expect_equal(0, lurek.asset.refcount(handle))
    end)

    -- ─── get (text) ────────────────────────────────────────────────────────

    it("get returns string content for text asset", function()
        local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        local content = lurek.asset.get(handle)
        expect_not_nil(content, "get should return content")
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(handle)
    end)

    -- ─── stats ─────────────────────────────────────────────────────────────

    it("stats returns table with loaded and total_refs fields", function()
        lurek.asset.clear()
        local s = lurek.asset.stats()
        expect_not_nil(s)
        expect_type("table", s)
        expect_not_nil(s.loaded)
        expect_not_nil(s.total_refs)
        expect_not_nil(s.types)
    end)

    it("stats reflects loaded asset count", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        local s = lurek.asset.stats()
        expect_equal(1, s.loaded)
        expect_equal(1, s.total_refs)
        lurek.asset.unload(h1)
    end)

    it("stats.types reflects the type breakdown", function()
        lurek.asset.clear()
        local h = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        local s = lurek.asset.stats()
        expect_equal(1, s.types.text)
        lurek.asset.unload(h)
    end)

    -- ─── clear ─────────────────────────────────────────────────────────────

    it("clear empties the cache", function()
        local h1 = lurek.asset.load("assets/fonts/bitmap_fonts.json", "text")
        lurek.asset.clear()
        expect_equal(0, lurek.asset.stats().loaded)
        expect_equal(false, lurek.asset.isLoaded(h1))
    end)

    -- ─── load error cases ──────────────────────────────────────────────────

    it("load missing file returns error for non-text type", function()
        local ok, err = pcall(lurek.asset.load, "nonexistent_asset.png", "image")
        expect_equal(false, ok)
        expect_not_nil(err)
    end)

    it("load missing text file returns error", function()
        local ok, err = pcall(lurek.asset.load, "nonexistent_file.txt", "text")
        expect_equal(false, ok)
        expect_not_nil(err)
    end)

    -- ─── preload ───────────────────────────────────────────────────────────

    it("preload fires callback with progress and nil/nil at end", function()
        lurek.asset.clear()
        local calls = {}
        lurek.asset.preload(
            {
                {"assets/fonts/bitmap_fonts.json", "text"},
            },
            function(loaded, total)
                table.insert(calls, {loaded, total})
            end
        )
        -- Should have two calls: {1, 1} then {nil, nil}
        expect_equal(2, #calls)
        expect_equal(1, calls[1][1])
        expect_equal(1, calls[1][2])
        expect_equal(nil, calls[2][1])
        expect_equal(nil, calls[2][2])
    end)

    it("preload registers asset in cache", function()
        lurek.asset.clear()
        lurek.asset.preload(
            {{"assets/fonts/bitmap_fonts.json", "text"}},
            function() end
        )
        expect_equal(1, lurek.asset.stats().loaded)
        lurek.asset.clear()
    end)

end)

test_summary()
