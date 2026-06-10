-- test_asset_core_unit.lua
-- Unit tests for lurek.asset with one owner test per public API method.

local PATH_JSON = "assets/fonts/bitmap_fonts.json"
local PATH_TOML = "Cargo.toml"
local PATH_LUA = "content/examples/asset.lua"
local PATH_SHADER = "assets/shaders/province_map.wgsl"
local PATH_OBJ = "content/examples/asset.lua"
local PATH_BIN = "assets/textures/province_map.png"

local function reset_assets()
    lurek.asset.clear()
end

-- @describe lurek.asset.load
describe("lurek.asset.load", function()
    -- @covers lurek.asset.load
    it("loads text-like and binary asset types and errors for missing files", function()
        reset_assets()

        local text = lurek.asset.load(PATH_JSON, "json")
        expect_not_nil(text)
        expect_equal("LAssetHandle", text:type())

        local binary = lurek.asset.load(PATH_BIN, "music")
        expect_not_nil(binary)
        expect_equal("music", lurek.asset.getType(binary))

        local ok, err = pcall(lurek.asset.load, "nonexistent_asset.png", "image")
        expect_equal(false, ok)
        expect_not_nil(err)

        reset_assets()
    end)
end)

-- @describe lurek.asset.unload
describe("lurek.asset.unload", function()
    -- @covers lurek.asset.unload
    it("removes an asset from the cache", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
        lurek.asset.unload(handle)
        expect_equal(false, lurek.asset.isLoaded(handle))
        expect_equal(0, lurek.asset.refcount(handle))
    end)
end)

-- @describe lurek.asset.get
describe("lurek.asset.get", function()
    -- @covers lurek.asset.get
    it("returns loaded text content", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        local content = lurek.asset.get(handle)
        expect_type("string", content)
        expect_true(#content > 0)
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.preload
describe("lurek.asset.preload", function()
    -- @covers lurek.asset.preload
    it("loads multiple assets and reports callback progress", function()
        reset_assets()
        local calls = {}
        lurek.asset.preload(
            {
                { PATH_JSON, "json" },
                { PATH_TOML, "toml" },
                { PATH_LUA, "lua" },
            },
            function(loaded, total)
                table.insert(calls, { loaded, total })
            end
        )
        expect_equal(4, #calls)
        expect_equal(1, calls[1][1])
        expect_equal(3, calls[3][2])
        expect_equal(nil, calls[4][1])
        expect_equal(3, lurek.asset.stats().loaded)
        reset_assets()
    end)
end)

-- @describe lurek.asset.refcount
describe("lurek.asset.refcount", function()
    -- @covers lurek.asset.refcount
    it("starts at one after initial load", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(1, lurek.asset.refcount(handle))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.isLoaded
describe("lurek.asset.isLoaded", function()
    -- @covers lurek.asset.isLoaded
    it("reports whether a handle is currently loaded", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, lurek.asset.isLoaded(handle))
        lurek.asset.clear()
        expect_equal(false, lurek.asset.isLoaded(handle))
    end)
end)

-- @describe lurek.asset.stats
describe("lurek.asset.stats", function()
    -- @covers lurek.asset.stats
    it("returns aggregate counts, type breakdowns, and unique groups", function()
        reset_assets()
        lurek.asset.load(PATH_JSON, "json", { group = "ui" })
        lurek.asset.load(PATH_TOML, "toml", { group = "config" })
        lurek.asset.load(PATH_LUA, "lua", { group = "ui" })
        local s = lurek.asset.stats()
        expect_type("table", s)
        expect_equal(3, s.loaded)
        expect_equal(3, s.total_refs)
        expect_equal(1, s.types.json)
        expect_equal(1, s.types.toml)
        expect_equal(1, s.types.lua)
        expect_type("table", s.groups)
        expect_equal(2, #s.groups)
        reset_assets()
    end)
end)

-- @describe lurek.asset.clear
describe("lurek.asset.clear", function()
    -- @covers lurek.asset.clear
    it("empties the entire cache", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        lurek.asset.clear()
        expect_equal(0, lurek.asset.stats().loaded)
        expect_equal(false, lurek.asset.isLoaded(handle))
    end)
end)

-- @describe lurek.asset.getPath
describe("lurek.asset.getPath", function()
    -- @covers lurek.asset.getPath
    it("returns the path passed at load time", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_TOML, "toml")
        expect_equal(PATH_TOML, lurek.asset.getPath(handle))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.getType
describe("lurek.asset.getType", function()
    -- @covers lurek.asset.getType
    it("returns the type string used at load time", function()
        reset_assets()
        local hm = lurek.asset.load(PATH_BIN, "music")
        local ha = lurek.asset.load(PATH_BIN, "audio")
        expect_equal("music", lurek.asset.getType(hm))
        expect_equal("audio", lurek.asset.getType(ha))
        reset_assets()
    end)
end)

-- @describe lurek.asset.getInfo
describe("lurek.asset.getInfo", function()
    -- @covers lurek.asset.getInfo
    it("returns a metadata table for a loaded asset", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json", {
            name = "test_asset",
            group = "test_group",
            tags = { "t1" },
        })
        local info = lurek.asset.getInfo(handle)
        expect_type("table", info)
        expect_equal(PATH_JSON, info.path)
        expect_equal("json", info.type)
        expect_equal("test_asset", info.name)
        expect_equal("test_group", info.group)
        expect_equal(1, info.refcount)
        expect_type("table", info.tags)
        expect_true(#info.tags >= 1)
        reset_assets()
    end)
end)

-- @describe lurek.asset.setName
describe("lurek.asset.setName", function()
    -- @covers lurek.asset.setName
    it("updates the asset display name", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_TOML, "toml")
        lurek.asset.setName(handle, "CargoConfig")
        expect_equal("CargoConfig", lurek.asset.getName(handle))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.getName
describe("lurek.asset.getName", function()
    -- @covers lurek.asset.getName
    it("returns a default or explicit asset name", function()
        reset_assets()
        local defaulted = lurek.asset.load(PATH_TOML, "toml")
        expect_equal("Cargo", lurek.asset.getName(defaulted))
        local named = lurek.asset.load(PATH_JSON, "json", { name = "my_config" })
        expect_equal("my_config", lurek.asset.getName(named))
        reset_assets()
    end)
end)

-- @describe lurek.asset.setGroup
describe("lurek.asset.setGroup", function()
    -- @covers lurek.asset.setGroup
    it("updates the asset group", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.setGroup(handle, "ui")
        expect_equal("ui", lurek.asset.getGroup(handle))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.getGroup
describe("lurek.asset.getGroup", function()
    -- @covers lurek.asset.getGroup
    it("returns the assigned asset group", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json", { group = "project" })
        expect_equal("project", lurek.asset.getGroup(handle))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.addTag
describe("lurek.asset.addTag", function()
    -- @covers lurek.asset.addTag
    it("adds a tag to an asset", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json")
        lurek.asset.addTag(handle, "config")
        expect_equal(true, lurek.asset.hasTag(handle, "config"))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.removeTag
describe("lurek.asset.removeTag", function()
    -- @covers lurek.asset.removeTag
    it("removes a previously added tag", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json", { tags = { "config", "ui" } })
        lurek.asset.removeTag(handle, "config")
        expect_equal(false, lurek.asset.hasTag(handle, "config"))
        expect_equal(true, lurek.asset.hasTag(handle, "ui"))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.getTags
describe("lurek.asset.getTags", function()
    -- @covers lurek.asset.getTags
    it("returns the full tag list", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json", { tags = { "config", "ui" } })
        local tags = lurek.asset.getTags(handle)
        expect_type("table", tags)
        expect_equal(2, #tags)
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.hasTag
describe("lurek.asset.hasTag", function()
    -- @covers lurek.asset.hasTag
    it("checks whether a tag is present", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "json", { tags = { "config", "ui" } })
        expect_equal(true, lurek.asset.hasTag(handle, "config"))
        expect_equal(false, lurek.asset.hasTag(handle, "missing"))
        lurek.asset.unload(handle)
    end)
end)

-- @describe lurek.asset.findByName
describe("lurek.asset.findByName", function()
    -- @covers lurek.asset.findByName
    it("finds assets by case-insensitive display name", function()
        reset_assets()
        lurek.asset.load(PATH_TOML, "toml", { name = "CargoConfig" })
        local lo = lurek.asset.findByName("cargoconfig")
        local up = lurek.asset.findByName("CARGOCONFIG")
        local miss = lurek.asset.findByName("xyzzy_no_match")
        expect_equal(#lo, #up)
        expect_true(#lo >= 1)
        expect_equal(0, #miss)
        reset_assets()
    end)
end)

-- @describe lurek.asset.findByGroup
describe("lurek.asset.findByGroup", function()
    -- @covers lurek.asset.findByGroup
    it("finds assets by group name", function()
        reset_assets()
        lurek.asset.load(PATH_JSON, "json", { group = "ui" })
        lurek.asset.load(PATH_TOML, "toml", { group = "config" })
        local ui = lurek.asset.findByGroup("ui")
        local miss = lurek.asset.findByGroup("missing")
        expect_true(#ui >= 1)
        expect_equal(0, #miss)
        reset_assets()
    end)
end)

-- @describe lurek.asset.findByTag
describe("lurek.asset.findByTag", function()
    -- @covers lurek.asset.findByTag
    it("finds assets by tag", function()
        reset_assets()
        lurek.asset.load(PATH_JSON, "json", { tags = { "config" } })
        lurek.asset.load(PATH_TOML, "toml", { tags = { "build" } })
        local config = lurek.asset.findByTag("config")
        local miss = lurek.asset.findByTag("missing")
        expect_true(#config >= 1)
        expect_equal(0, #miss)
        reset_assets()
    end)
end)

-- @describe lurek.asset.findByType
describe("lurek.asset.findByType", function()
    -- @covers lurek.asset.findByType
    it("finds assets by type", function()
        reset_assets()
        lurek.asset.load(PATH_JSON, "json")
        lurek.asset.load(PATH_TOML, "toml")
        local json = lurek.asset.findByType("json")
        local missing = lurek.asset.findByType("shader")
        expect_true(#json >= 1)
        expect_equal(0, #missing)
        reset_assets()
    end)
end)

-- @describe LAssetHandle:typeOf
describe("LAssetHandle:typeOf", function()
    -- @covers LAssetHandle:typeOf
    it("matches handle and object types and rejects unknown ones", function()
        reset_assets()
        local handle = lurek.asset.load(PATH_JSON, "text")
        expect_equal(true, handle:typeOf("LAssetHandle"))
        expect_equal(true, handle:typeOf("LObject"))
        expect_equal(false, handle:typeOf("unknown"))
        lurek.asset.unload(handle)
    end)
end)

test_summary()
