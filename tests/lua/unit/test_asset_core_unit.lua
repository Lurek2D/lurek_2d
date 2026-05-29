-- test_asset_core_unit.lua
-- Unit tests for lurek.asset: one test per public API method.
--
-- Text-like types (text, toml, json, obj, shader, lua) are loaded with real
-- project files; binary types (image, font, audio, music) use an existing
-- file for path-existence checks only — get() is not called for binary types
-- because audio/GPU infrastructure is not available in the unit-test VM.

-- ─── Shared fixture paths ─────────────────────────────────────────────────
local PATH_JSON   = "assets/fonts/bitmap_fonts.json"
local PATH_TOML   = "Cargo.toml"
local PATH_LUA    = "main.lua"
local PATH_SHADER = "assets/shaders/province_map.wgsl"
local PATH_OBJ    = "main.lua"      -- any text file; obj type stores raw text
local PATH_BIN    = "assets/textures/province_map.png"  -- exists; used for binary types

describe("lurek.asset module", function()

    -- ─── Module presence: core ─────────────────────────────────────────────

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

    -- ─── Module presence: info functions ──────────────────────────────────

    it("lurek.asset.getPath is a function", function()
        expect_type("function", lurek.asset.getPath)
    end)

    it("lurek.asset.getType is a function", function()
        expect_type("function", lurek.asset.getType)
    end)

    it("lurek.asset.getInfo is a function", function()
        expect_type("function", lurek.asset.getInfo)
    end)

    -- ─── Module presence: name/group/tag functions ────────────────────────

    it("lurek.asset.setName is a function", function()
        expect_type("function", lurek.asset.setName)
    end)

    it("lurek.asset.getName is a function", function()
        expect_type("function", lurek.asset.getName)
    end)

    it("lurek.asset.setGroup is a function", function()
        expect_type("function", lurek.asset.setGroup)
    end)

    it("lurek.asset.getGroup is a function", function()
        expect_type("function", lurek.asset.getGroup)
    end)

    it("lurek.asset.addTag is a function", function()
        expect_type("function", lurek.asset.addTag)
    end)

    it("lurek.asset.removeTag is a function", function()
        expect_type("function", lurek.asset.removeTag)
    end)

    it("lurek.asset.getTags is a function", function()
        expect_type("function", lurek.asset.getTags)
    end)

    it("lurek.asset.hasTag is a function", function()
        expect_type("function", lurek.asset.hasTag)
    end)

    -- ─── Module presence: search functions ────────────────────────────────

    it("lurek.asset.findByName is a function", function()
        expect_type("function", lurek.asset.findByName)
    end)

    it("lurek.asset.findByGroup is a function", function()
        expect_type("function", lurek.asset.findByGroup)
    end)

    it("lurek.asset.findByTag is a function", function()
        expect_type("function", lurek.asset.findByTag)
    end)

    it("lurek.asset.findByType is a function", function()
        expect_type("function", lurek.asset.findByType)
    end)

    -- ─── load / handle basics ──────────────────────────────────────────────

    -- @covers lurek.asset.load
    -- @covers LAssetHandle:type
    it("load a text file returns LAssetHandle", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_not_nil(handle, "handle should not be nil")
        expect_equal("LAssetHandle", handle:type())
    end)

    -- @covers LAssetHandle:typeOf
    it("handle:typeOf('LAssetHandle') returns true", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, handle:typeOf("LAssetHandle"))
    end)

    it("handle:typeOf('LObject') returns true", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, handle:typeOf("LObject"))
    end)

    it("handle:typeOf('unknown') returns false", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(false, handle:typeOf("unknown"))
    end)

    -- ─── New text-like types ───────────────────────────────────────────────

    it("load type=toml reads file content", function()
        local h = lurek.asset.load(PATH_TOML, "toml")
        expect_not_nil(h)
        expect_equal("LAssetHandle", h:type())
        local content = lurek.asset.get(h)
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(h)
    end)

    it("load type=json reads file content", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        expect_not_nil(h)
        local content = lurek.asset.get(h)
        expect_type("string", content)
        expect_equal(true, string.find(content, "{") ~= nil or string.find(content, "[") ~= nil)
        lurek.asset.unload(h)
    end)

    it("load type=lua reads file content", function()
        local h = lurek.asset.load(PATH_LUA, "lua")
        expect_not_nil(h)
        local content = lurek.asset.get(h)
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(h)
    end)

    it("load type=shader reads file content", function()
        local h = lurek.asset.load(PATH_SHADER, "shader")
        expect_not_nil(h)
        local content = lurek.asset.get(h)
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(h)
    end)

    it("load type=obj reads file content", function()
        local h = lurek.asset.load(PATH_OBJ, "obj")
        expect_not_nil(h)
        local content = lurek.asset.get(h)
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(h)
    end)

    it("load type=music stores path ref only (binary)", function()
        local h = lurek.asset.load(PATH_BIN, "music")
        expect_not_nil(h)
        expect_equal(true, lurek.asset.isLoaded(h))
        expect_equal("music", lurek.asset.getType(h))
        lurek.asset.unload(h)
    end)

    -- ─── load with opts (name / group / tags) ─────────────────────────────

    it("load with opts.name sets display name", function()
        local h = lurek.asset.load(PATH_JSON, "json", {name = "my_config"})
        expect_equal("my_config", lurek.asset.getName(h))
        lurek.asset.unload(h)
    end)

    it("load with opts.group sets group", function()
        local h = lurek.asset.load(PATH_JSON, "json", {group = "ui"})
        expect_equal("ui", lurek.asset.getGroup(h))
        lurek.asset.unload(h)
    end)

    it("load with opts.tags sets multiple tags", function()
        local h = lurek.asset.load(PATH_JSON, "json", {tags = {"config", "ui"}})
        expect_equal(true, lurek.asset.hasTag(h, "config"))
        expect_equal(true, lurek.asset.hasTag(h, "ui"))
        lurek.asset.unload(h)
    end)

    it("load with all opts fields together", function()
        local h = lurek.asset.load(PATH_TOML, "toml", {
            name = "build_config",
            group = "project",
            tags  = {"config", "toml"},
        })
        expect_equal("build_config", lurek.asset.getName(h))
        expect_equal("project",      lurek.asset.getGroup(h))
        expect_equal(true,           lurek.asset.hasTag(h, "config"))
        lurek.asset.unload(h)
    end)

    -- ─── isLoaded / refcount ───────────────────────────────────────────────

    it("isLoaded returns true after load", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
    end)

    it("refcount returns 1 after initial load", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(1, lurek.asset.refcount(handle))
    end)

    -- ─── unload ────────────────────────────────────────────────────────────

    -- @covers lurek.asset.unload
    -- @covers lurek.asset.refcount
    -- @covers lurek.asset.isLoaded
    it("unload reduces refcount to 0 and asset is no longer loaded", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
        lurek.asset.unload(handle)
        expect_equal(false, lurek.asset.isLoaded(handle))
        expect_equal(0, lurek.asset.refcount(handle))
    end)

    -- ─── get (text) ────────────────────────────────────────────────────────

    -- @covers lurek.asset.get
    it("get returns string content for text asset", function()
        local handle = lurek.asset.load(PATH_JSON, "text")
        local content = lurek.asset.get(handle)
        expect_not_nil(content, "get should return content")
        expect_type("string", content)
        expect_equal(true, #content > 0)
        lurek.asset.unload(handle)
    end)

    -- ─── getPath / getType ────────────────────────────────────────────────

    -- @covers lurek.asset.getPath
    it("getPath returns the path passed to load", function()
        local h = lurek.asset.load(PATH_TOML, "toml")
        expect_equal(PATH_TOML, lurek.asset.getPath(h))
        lurek.asset.unload(h)
    end)

    -- @covers lurek.asset.getType
    it("getType returns the type string used at load", function()
        local h = lurek.asset.load(PATH_TOML, "toml")
        expect_equal("toml", lurek.asset.getType(h))
        lurek.asset.unload(h)
    end)

    it("getType distinguishes music from audio", function()
        local hm = lurek.asset.load(PATH_BIN, "music")
        local ha = lurek.asset.load(PATH_BIN, "audio")
        expect_equal("music", lurek.asset.getType(hm))
        expect_equal("audio", lurek.asset.getType(ha))
        lurek.asset.unload(hm)
        lurek.asset.unload(ha)
    end)

    -- ─── getInfo ──────────────────────────────────────────────────────────

    -- @covers lurek.asset.getInfo
    it("getInfo returns table with all fields", function()
        local h = lurek.asset.load(PATH_JSON, "json", {
            name  = "test_asset",
            group = "test_group",
            tags  = {"t1"},
        })
        local info = lurek.asset.getInfo(h)
        expect_not_nil(info)
        expect_type("table", info)
        expect_equal(PATH_JSON,    info.path)
        expect_equal("json",       info.type)
        expect_equal("test_asset", info.name)
        expect_equal("test_group", info.group)
        expect_equal(1,            info.refcount)
        expect_type("table",       info.tags)
        expect_equal(true, #info.tags >= 1)
        lurek.asset.unload(h)
    end)

    it("getInfo.name defaults to path file-stem when no name set", function()
        local h = lurek.asset.load(PATH_TOML, "toml")
        local info = lurek.asset.getInfo(h)
        expect_not_nil(info)
        -- file-stem of "Cargo.toml" is "Cargo"
        expect_equal("Cargo", info.name)
        lurek.asset.unload(h)
    end)

    it("getInfo.group is empty string when no group set", function()
        local h = lurek.asset.load(PATH_JSON, "text")
        local info = lurek.asset.getInfo(h)
        expect_equal("", info.group)
        lurek.asset.unload(h)
    end)

    -- ─── setName / getName ────────────────────────────────────────────────

    it("getName defaults to path file-stem when no name set", function()
        local h = lurek.asset.load(PATH_TOML, "toml")
        expect_equal("Cargo", lurek.asset.getName(h))
        lurek.asset.unload(h)
    end)

    -- @covers lurek.asset.setName
    -- @covers lurek.asset.getName
    it("setName then getName roundtrip", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.setName(h, "my_json")
        expect_equal("my_json", lurek.asset.getName(h))
        lurek.asset.unload(h)
    end)

    -- ─── setGroup / getGroup ──────────────────────────────────────────────

    it("getGroup returns empty string when no group set", function()
        local h = lurek.asset.load(PATH_JSON, "text")
        expect_equal("", lurek.asset.getGroup(h))
        lurek.asset.unload(h)
    end)

    -- @covers lurek.asset.setGroup
    -- @covers lurek.asset.getGroup
    it("setGroup then getGroup roundtrip", function()
        local h = lurek.asset.load(PATH_JSON, "text")
        lurek.asset.setGroup(h, "level_1")
        expect_equal("level_1", lurek.asset.getGroup(h))
        lurek.asset.unload(h)
    end)

    -- ─── addTag / removeTag / getTags / hasTag ────────────────────────────

    it("addTag then hasTag returns true", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.addTag(h, "config")
        expect_equal(true, lurek.asset.hasTag(h, "config"))
        lurek.asset.unload(h)
    end)

    it("hasTag returns false for tag not added", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        expect_equal(false, lurek.asset.hasTag(h, "nonexistent"))
        lurek.asset.unload(h)
    end)

    -- @covers lurek.asset.addTag
    -- @covers lurek.asset.removeTag
    -- @covers lurek.asset.getTags
    -- @covers lurek.asset.hasTag
    it("removeTag returns true when tag was present", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.addTag(h, "tmp")
        expect_equal(true, lurek.asset.removeTag(h, "tmp"))
        expect_equal(false, lurek.asset.hasTag(h, "tmp"))
        lurek.asset.unload(h)
    end)

    it("removeTag returns false when tag was not present", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        expect_equal(false, lurek.asset.removeTag(h, "not_there"))
        lurek.asset.unload(h)
    end)

    it("getTags returns array of all added tags", function()
        local h = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.addTag(h, "a")
        lurek.asset.addTag(h, "b")
        local tags = lurek.asset.getTags(h)
        expect_type("table", tags)
        expect_equal(true, #tags >= 2)
        lurek.asset.unload(h)
    end)

    it("getTags is empty for untagged asset", function()
        local h = lurek.asset.load(PATH_JSON, "text")
        local tags = lurek.asset.getTags(h)
        expect_type("table", tags)
        expect_equal(0, #tags)
        lurek.asset.unload(h)
    end)

    -- ─── findByType ───────────────────────────────────────────────────────

    -- @covers lurek.asset.findByType
    it("findByType returns handles of matching type only", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load(PATH_JSON, "json")
        local h2 = lurek.asset.load(PATH_TOML, "toml")
        local h3 = lurek.asset.load(PATH_LUA,  "lua")
        local json_handles = lurek.asset.findByType("json")
        expect_type("table", json_handles)
        expect_equal(1, #json_handles)
        lurek.asset.clear()
    end)

    it("findByType returns empty table when no match", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "json")
        local results = lurek.asset.findByType("shader")
        expect_type("table", results)
        expect_equal(0, #results)
        lurek.asset.clear()
    end)

    -- ─── findByGroup ──────────────────────────────────────────────────────

    -- @covers lurek.asset.findByGroup
    it("findByGroup returns handles in named group", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load(PATH_JSON, "json", {group = "ui"})
        local h2 = lurek.asset.load(PATH_TOML, "toml", {group = "ui"})
        local h3 = lurek.asset.load(PATH_LUA,  "lua",  {group = "scripts"})
        local ui = lurek.asset.findByGroup("ui")
        expect_type("table", ui)
        expect_equal(2, #ui)
        lurek.asset.clear()
    end)

    it("findByGroup returns empty table for unknown group", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "json", {group = "ui"})
        local results = lurek.asset.findByGroup("audio")
        expect_equal(0, #results)
        lurek.asset.clear()
    end)

    -- ─── findByTag ────────────────────────────────────────────────────────

    -- @covers lurek.asset.findByTag
    it("findByTag returns handles with matching tag", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load(PATH_JSON, "json")
        local h2 = lurek.asset.load(PATH_TOML, "toml")
        lurek.asset.addTag(h1, "config")
        lurek.asset.addTag(h2, "config")
        local results = lurek.asset.findByTag("config")
        expect_type("table", results)
        expect_equal(2, #results)
        lurek.asset.clear()
    end)

    it("findByTag returns empty table when no handle has tag", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "json")
        local results = lurek.asset.findByTag("sfx")
        expect_equal(0, #results)
        lurek.asset.clear()
    end)

    -- ─── findByName ───────────────────────────────────────────────────────

    -- @covers lurek.asset.findByName
    it("findByName uses path file-stem for unnamed assets", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_TOML, "toml")
        -- file-stem is "Cargo"; search for "Cargo" (case-insensitive)
        local results = lurek.asset.findByName("Cargo")
        expect_type("table", results)
        expect_equal(true, #results >= 1)
        lurek.asset.clear()
    end)

    it("findByName is case-insensitive", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_TOML, "toml")
        lurek.asset.setName(h, "CargoConfig")
        local results_lo = lurek.asset.findByName("cargoconfig")
        local results_up = lurek.asset.findByName("CARGOCONFIG")
        expect_equal(#results_lo, #results_up)
        expect_equal(true, #results_lo >= 1)
        lurek.asset.clear()
    end)

    it("findByName returns empty table when no match", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "json", {name = "sprites"})
        local results = lurek.asset.findByName("xyzzy_no_match")
        expect_equal(0, #results)
        lurek.asset.clear()
    end)

    -- ─── stats ─────────────────────────────────────────────────────────────

    -- @covers lurek.asset.stats
    it("stats returns table with loaded and total_refs fields", function()
        lurek.asset.clear()
        local s = lurek.asset.stats()
        expect_not_nil(s)
        expect_type("table", s)
        expect_not_nil(s.loaded)
        expect_not_nil(s.total_refs)
        expect_not_nil(s.types)
        expect_not_nil(s.groups)
    end)

    it("stats reflects loaded asset count", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load(PATH_JSON, "text")
        local s = lurek.asset.stats()
        expect_equal(1, s.loaded)
        expect_equal(1, s.total_refs)
        lurek.asset.unload(h1)
    end)

    it("stats.types reflects the type breakdown", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "text")
        local s = lurek.asset.stats()
        expect_equal(1, s.types.text)
        lurek.asset.unload(h)
    end)

    it("stats.groups is empty array when no groups set", function()
        lurek.asset.clear()
        local h = lurek.asset.load(PATH_JSON, "text")
        local s = lurek.asset.stats()
        expect_type("table", s.groups)
        expect_equal(0, #s.groups)
        lurek.asset.unload(h)
    end)

    it("stats.groups lists unique group names", function()
        lurek.asset.clear()
        local h1 = lurek.asset.load(PATH_JSON,   "json",  {group = "ui"})
        local h2 = lurek.asset.load(PATH_TOML,   "toml",  {group = "config"})
        local h3 = lurek.asset.load(PATH_LUA,    "lua",   {group = "ui"})
        local s = lurek.asset.stats()
        expect_type("table", s.groups)
        expect_equal(2, #s.groups)  -- "config" and "ui"
        lurek.asset.clear()
    end)

    -- ─── clear ─────────────────────────────────────────────────────────────

    -- @covers lurek.asset.clear
    it("clear empties the cache", function()
        local h1 = lurek.asset.load(PATH_JSON, "text")
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

    it("load missing toml file returns error", function()
        local ok, err = pcall(lurek.asset.load, "nonexistent.toml", "toml")
        expect_equal(false, ok)
        expect_not_nil(err)
    end)

    -- ─── preload ───────────────────────────────────────────────────────────

    -- @covers lurek.asset.preload
    it("preload fires callback with progress and nil/nil at end", function()
        lurek.asset.clear()
        local calls = {}
        lurek.asset.preload(
            {
                {PATH_JSON, "text"},
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
            {{PATH_JSON, "text"}},
            function() end
        )
        expect_equal(1, lurek.asset.stats().loaded)
        lurek.asset.clear()
    end)

    it("preload supports new types including toml", function()
        lurek.asset.clear()
        lurek.asset.preload(
            {
                {PATH_JSON,   "json"},
                {PATH_TOML,   "toml"},
                {PATH_LUA,    "lua"},
            },
            function() end
        )
        expect_equal(3, lurek.asset.stats().loaded)
        lurek.asset.clear()
    end)

end)

test_summary()
