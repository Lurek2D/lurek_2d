-- Asset registry and ref-counted media cache example.
-- Covers lurek.asset.* and LAssetHandle methods.
-- @module lurek.asset

-- Shared fixture paths used throughout the file.
local PATH_TEXT   = "content/examples/assets/data/sample_hello.txt"
local PATH_JSON   = "assets/fonts/bitmap_fonts.json"
local PATH_TOML   = "content/examples/assets/data/sample_config.toml"
local PATH_LUA    = "content/examples/asset.lua"
local PATH_SHADER = "assets/shaders/province_map.wgsl"
local PATH_OBJ    = "content/examples/assets/models/sample_tank.obj"
local PATH_BIN    = "content/examples/assets/audio/sample_tone.wav"

-- ─────────────────────────────────────────────────────────────────────────────
-- LOAD / UNLOAD  (text-like types read content; binary types store path ref)
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: lurek.asset.load
do
    -- Minimal load: text type reads file content immediately.
    local h = lurek.asset.load(PATH_TEXT, "text")
    print("loaded: " .. h:type())
    lurek.asset.unload(h)

    -- load type=toml
    local ht = lurek.asset.load(PATH_TOML, "toml")
    print("toml loaded: " .. tostring(lurek.asset.isLoaded(ht)))
    lurek.asset.unload(ht)

    -- load type=json
    local hj = lurek.asset.load(PATH_JSON, "json")
    print("json loaded: " .. tostring(lurek.asset.isLoaded(hj)))
    lurek.asset.unload(hj)

    -- load type=lua
    local hl = lurek.asset.load(PATH_LUA, "lua")
    print("lua loaded: " .. tostring(lurek.asset.isLoaded(hl)))
    lurek.asset.unload(hl)

    -- load type=shader
    local hs = lurek.asset.load(PATH_SHADER, "shader")
    print("shader loaded: " .. tostring(lurek.asset.isLoaded(hs)))
    lurek.asset.unload(hs)

    -- load type=obj (any text file works for raw OBJ geometry)
    local ho = lurek.asset.load(PATH_OBJ, "obj")
    print("obj loaded: " .. tostring(lurek.asset.isLoaded(ho)))
    lurek.asset.unload(ho)

    -- load type=music (binary path reference only; no file content cached)
    local hm = lurek.asset.load(PATH_BIN, "music")
    print("music loaded: " .. tostring(lurek.asset.isLoaded(hm)))
    lurek.asset.unload(hm)

    -- load type=audio (same as music but semantically a sound effect)
    local ha = lurek.asset.load(PATH_BIN, "audio")
    print("audio loaded: " .. tostring(lurek.asset.isLoaded(ha)))
    lurek.asset.unload(ha)

    -- load with opts: name, group, and tags supplied inline.
    local h = lurek.asset.load(PATH_TOML, "toml", {
        name  = "build_config",
        group = "project",
        tags  = {"config", "meta"},
    })
    print("name="  .. lurek.asset.getName(h))
    print("group=" .. lurek.asset.getGroup(h))
    print("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.unload
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    lurek.asset.unload(h)
    print("unloaded, isLoaded=" .. tostring(lurek.asset.isLoaded(h)))
end

--@api-stub: lurek.asset.get
do
    -- get() for text-like types returns cached file content as a string.
    local h = lurek.asset.load(PATH_TEXT, "text")
    local content = lurek.asset.get(h)
    print("content length=" .. tostring(type(content) == "string" and #content or 0))
    lurek.asset.unload(h)

    -- get() for toml returns the raw TOML source.
    local ht = lurek.asset.load(PATH_TOML, "toml")
    local toml_src = lurek.asset.get(ht)
    print("toml source length=" .. #toml_src)
    lurek.asset.unload(ht)
end

--@api-stub: lurek.asset.preload
do
    local results = {}
    lurek.asset.preload(
        {
            {PATH_TEXT,   "text"},
            {PATH_JSON,   "json"},
            {PATH_TOML,   "toml"},
            {PATH_LUA,    "lua"},
        },
        function(loaded, total)
            if loaded ~= nil then
                table.insert(results, loaded .. "/" .. tostring(total))
            else
                print("preload done: " .. table.concat(results, ", "))
            end
        end
    )
    lurek.asset.clear()
end

--@api-stub: lurek.asset.refcount
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    print("refcount=" .. lurek.asset.refcount(h))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.isLoaded
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    print("isLoaded=" .. tostring(lurek.asset.isLoaded(h)))
    lurek.asset.unload(h)
    print("isLoaded after unload=" .. tostring(lurek.asset.isLoaded(h)))
end

--@api-stub: lurek.asset.stats
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "data"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "data"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})
    local s = lurek.asset.stats()
    print("loaded="     .. s.loaded)
    print("total_refs=" .. s.total_refs)
    print("json count=" .. tostring(s.types.json))
    print("groups="     .. #s.groups)   -- 2 unique groups: "data" and "gfx"
    lurek.asset.clear()
end

--@api-stub: lurek.asset.clear
do
    lurek.asset.load(PATH_TEXT, "text")
    lurek.asset.clear()
    print("after clear loaded=" .. lurek.asset.stats().loaded)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- GETPATH / GETTYPE / GETINFO
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: lurek.asset.getPath
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    print("path=" .. lurek.asset.getPath(h))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.getType
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    print("type=" .. lurek.asset.getType(h))   -- "toml"
    lurek.asset.unload(h)

    local hm = lurek.asset.load(PATH_BIN, "music")
    print("music type=" .. lurek.asset.getType(hm))  -- "music"
    lurek.asset.unload(hm)
end

--@api-stub: lurek.asset.getInfo
do
    local h = lurek.asset.load(PATH_JSON, "json", {
        name  = "ui_config",
        group = "ui",
        tags  = {"config", "ui"},
    })
    local info = lurek.asset.getInfo(h)
    print("info.path="     .. info.path)
    print("info.type="     .. info.type)
    print("info.name="     .. info.name)
    print("info.group="    .. info.group)
    print("info.refcount=" .. info.refcount)
    print("info.tags[1]="  .. tostring(info.tags[1]))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NAME / GROUP
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: lurek.asset.setName
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.setName(h, "font_atlas")
    print("setName → " .. lurek.asset.getName(h))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.getName
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    -- No explicit name: getName returns the path file-stem ("Cargo").
    print("getName (stem)=" .. lurek.asset.getName(h))
    lurek.asset.setName(h, "project_config")
    print("getName (set)=" .. lurek.asset.getName(h))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.setGroup
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.setGroup(h, "level_1")
    print("setGroup → " .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.getGroup
do
    local h = lurek.asset.load(PATH_JSON, "json")
    print("getGroup (unset)=" .. lurek.asset.getGroup(h))   -- ""
    lurek.asset.setGroup(h, "hud")
    print("getGroup (set)=" .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TAGS
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: lurek.asset.addTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "config")
    lurek.asset.addTag(h, "ui")
    print("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.removeTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "temp")
    local removed = lurek.asset.removeTag(h, "temp")
    print("removeTag returned=" .. tostring(removed))
    print("hasTag after remove=" .. tostring(lurek.asset.hasTag(h, "temp")))
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.getTags
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "sfx")
    lurek.asset.addTag(h, "level_1")
    local tags = lurek.asset.getTags(h)
    print("tag count=" .. #tags)
    lurek.asset.unload(h)
end

--@api-stub: lurek.asset.hasTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "enemy")
    print("hasTag enemy=" .. tostring(lurek.asset.hasTag(h, "enemy")))
    print("hasTag boss="  .. tostring(lurek.asset.hasTag(h, "boss")))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SEARCH
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: lurek.asset.findByName
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_TOML,   "toml", {name = "ProjectConfig"})
    local h2 = lurek.asset.load(PATH_JSON,   "json", {name = "FontAtlas"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader")  -- stem = "province_map"

    -- Substring search is case-insensitive.
    local matches = lurek.asset.findByName("config")
    print("findByName 'config' count=" .. #matches)  -- 1
    local shader_matches = lurek.asset.findByName("province")
    print("findByName 'province' count=" .. #shader_matches)  -- 1
    lurek.asset.clear()
end

--@api-stub: lurek.asset.findByGroup
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "ui"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "ui"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})

    local ui = lurek.asset.findByGroup("ui")
    print("findByGroup 'ui' count=" .. #ui)   -- 2
    local gfx = lurek.asset.findByGroup("gfx")
    print("findByGroup 'gfx' count=" .. #gfx) -- 1
    lurek.asset.clear()
end

--@api-stub: lurek.asset.findByTag
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_SHADER, "shader")
    lurek.asset.addTag(h1, "config")
    lurek.asset.addTag(h2, "config")
    lurek.asset.addTag(h3, "gfx")

    local config = lurek.asset.findByTag("config")
    print("findByTag 'config' count=" .. #config)  -- 2
    local gfx = lurek.asset.findByTag("gfx")
    print("findByTag 'gfx' count=" .. #gfx)        -- 1
    lurek.asset.clear()
end

--@api-stub: lurek.asset.findByType
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_TOML,   "toml")
    local h4 = lurek.asset.load(PATH_SHADER, "shader")
    local h5 = lurek.asset.load(PATH_BIN,    "music")

    print("findByType 'toml' count="   .. #lurek.asset.findByType("toml"))    -- 2
    print("findByType 'json' count="   .. #lurek.asset.findByType("json"))    -- 1
    print("findByType 'shader' count=" .. #lurek.asset.findByType("shader"))  -- 1
    print("findByType 'music' count="  .. #lurek.asset.findByType("music"))   -- 1
    print("findByType 'audio' count="  .. #lurek.asset.findByType("audio"))   -- 0
    lurek.asset.clear()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LAssetHandle methods
-- ─────────────────────────────────────────────────────────────────────────────

--@api-stub: LAssetHandle:type
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    print("type=" .. h:type())                    -- "LAssetHandle"
    lurek.asset.unload(h)
end

--@api-stub: LAssetHandle:typeOf
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    print("typeOf LAssetHandle=" .. tostring(h:typeOf("LAssetHandle")))
    print("typeOf LObject="      .. tostring(h:typeOf("LObject")))
    print("typeOf other="        .. tostring(h:typeOf("other")))
    lurek.asset.unload(h)
end
