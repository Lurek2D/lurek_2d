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

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.asset.load
do
    -- Minimal load: text type reads file content immediately.
    local h = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("loaded: " .. h:type())
    lurek.asset.unload(h)

    -- load type=toml
    local ht = lurek.asset.load(PATH_TOML, "toml")
    example_print_log("toml loaded: " .. tostring(lurek.asset.isLoaded(ht)))
    lurek.asset.unload(ht)

    -- load type=json
    local hj = lurek.asset.load(PATH_JSON, "json")
    example_print_log("json loaded: " .. tostring(lurek.asset.isLoaded(hj)))
    lurek.asset.unload(hj)

    -- load type=lua
    local hl = lurek.asset.load(PATH_LUA, "lua")
    example_print_log("lua loaded: " .. tostring(lurek.asset.isLoaded(hl)))
    lurek.asset.unload(hl)

    -- load type=shader
    local hs = lurek.asset.load(PATH_SHADER, "shader")
    example_print_log("shader loaded: " .. tostring(lurek.asset.isLoaded(hs)))
    lurek.asset.unload(hs)

    -- load type=obj (any text file works for raw OBJ geometry)
    local ho = lurek.asset.load(PATH_OBJ, "obj")
    example_print_log("obj loaded: " .. tostring(lurek.asset.isLoaded(ho)))
    lurek.asset.unload(ho)

    -- load type=music (binary path reference only; no file content cached)
    local hm = lurek.asset.load(PATH_BIN, "music")
    example_print_log("music loaded: " .. tostring(lurek.asset.isLoaded(hm)))
    lurek.asset.unload(hm)

    -- load type=audio (same as music but semantically a sound effect)
    local ha = lurek.asset.load(PATH_BIN, "audio")
    example_print_log("audio loaded: " .. tostring(lurek.asset.isLoaded(ha)))
    lurek.asset.unload(ha)

    -- load with opts: name, group, and tags supplied inline.
    local h = lurek.asset.load(PATH_TOML, "toml", {
        name  = "build_config",
        group = "project",
        tags  = {"config", "meta"},
    })
    example_print_log("name="  .. lurek.asset.getName(h))
    example_print_log("group=" .. lurek.asset.getGroup(h))
    example_print_log("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end

--@api: lurek.asset.unload
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local before = lurek.asset.isLoaded(h)
    lurek.asset.unload(h)
    local after = lurek.asset.isLoaded(h)
    example_print_log("loaded before unload=" .. tostring(before))
    example_print_log("unloaded, isLoaded=" .. tostring(after))
end

--@api: lurek.asset.get
do
    -- get() for text-like types returns cached file content as a string.
    local h = lurek.asset.load(PATH_TEXT, "text")
    local content = lurek.asset.get(h)
    example_print_log("content length=" .. tostring(type(content) == "string" and #content or 0))
    lurek.asset.unload(h)

    -- get() for toml returns the raw TOML source.
    local ht = lurek.asset.load(PATH_TOML, "toml")
    local toml_src = lurek.asset.get(ht)
    example_print_log("toml source length=" .. #toml_src)
    lurek.asset.unload(ht)
end

--@api: lurek.asset.preload
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
                example_print_log("preload done: " .. table.concat(results, ", "))
            end
        end
    )
    lurek.asset.clear()
end

--@api: lurek.asset.refcount
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local before = lurek.asset.refcount(h)
    local same = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("refcount before duplicate load=" .. before)
    example_print_log("refcount after duplicate load=" .. lurek.asset.refcount(same))
    lurek.asset.unload(h)
    lurek.asset.unload(same)
end

--@api: lurek.asset.isLoaded
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local loaded_before = lurek.asset.isLoaded(h)
    lurek.asset.unload(h)
    local loaded_after = lurek.asset.isLoaded(h)
    example_print_log("isLoaded before unload=" .. tostring(loaded_before))
    example_print_log("isLoaded after unload=" .. tostring(loaded_after))
end

--@api: lurek.asset.stats
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "data"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "data"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})
    local s = lurek.asset.stats()
    example_print_log("loaded="     .. s.loaded)
    example_print_log("total_refs=" .. s.total_refs)
    example_print_log("json count=" .. tostring(s.types.json))
    example_print_log("groups="     .. #s.groups)   -- 2 unique groups: "data" and "gfx"
    lurek.asset.clear()
end

--@api: lurek.asset.clear
do
    lurek.asset.load(PATH_TEXT, "text", { group = "temp" })
    lurek.asset.load(PATH_JSON, "json", { group = "temp" })
    local before = lurek.asset.stats()
    lurek.asset.clear()
    local after = lurek.asset.stats()
    example_print_log("clear removed loaded=" .. before.loaded .. " -> " .. after.loaded)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- GETPATH / GETTYPE / GETINFO
-- ─────────────────────────────────────────────────────────────────────────────

--@api: lurek.asset.getPath
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    local path = lurek.asset.getPath(h)
    local type_name = lurek.asset.getType(h)
    example_print_log("path=" .. path)
    example_print_log("type for path lookup=" .. type_name)
    lurek.asset.unload(h)
end

--@api: lurek.asset.getType
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    example_print_log("type=" .. lurek.asset.getType(h))   -- "toml"
    lurek.asset.unload(h)

    local hm = lurek.asset.load(PATH_BIN, "music")
    example_print_log("music type=" .. lurek.asset.getType(hm))  -- "music"
    lurek.asset.unload(hm)
end

--@api: lurek.asset.getInfo
do
    local h = lurek.asset.load(PATH_JSON, "json", {
        name  = "ui_config",
        group = "ui",
        tags  = {"config", "ui"},
    })
    local info = lurek.asset.getInfo(h)
    example_print_log("info.path="     .. info.path)
    example_print_log("info.type="     .. info.type)
    example_print_log("info.name="     .. info.name)
    example_print_log("info.group="    .. info.group)
    example_print_log("info.refcount=" .. info.refcount)
    example_print_log("info.tags[1]="  .. tostring(info.tags[1]))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NAME / GROUP
-- ─────────────────────────────────────────────────────────────────────────────

--@api: lurek.asset.setName
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("name before=" .. lurek.asset.getName(h))
    lurek.asset.setName(h, "font_atlas")
    local named = lurek.asset.findByName("font")
    example_print_log("setName → " .. lurek.asset.getName(h))
    example_print_log("findByName font count=" .. #named)
    lurek.asset.unload(h)
end

--@api: lurek.asset.getName
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    -- No explicit name: getName returns the path file-stem ("Cargo").
    example_print_log("getName (stem)=" .. lurek.asset.getName(h))
    lurek.asset.setName(h, "project_config")
    example_print_log("getName (set)=" .. lurek.asset.getName(h))
    lurek.asset.unload(h)
end

--@api: lurek.asset.setGroup
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("group before=" .. lurek.asset.getGroup(h))
    lurek.asset.setGroup(h, "level_1")
    local grouped = lurek.asset.findByGroup("level_1")
    example_print_log("findByGroup level_1 count=" .. #grouped)
    example_print_log("setGroup → " .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end

--@api: lurek.asset.getGroup
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("getGroup (unset)=" .. lurek.asset.getGroup(h))   -- ""
    lurek.asset.setGroup(h, "hud")
    example_print_log("getGroup (set)=" .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TAGS
-- ─────────────────────────────────────────────────────────────────────────────

--@api: lurek.asset.addTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "config")
    lurek.asset.addTag(h, "ui")
    example_print_log("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end

--@api: lurek.asset.removeTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "temp")
    local removed = lurek.asset.removeTag(h, "temp")
    example_print_log("removeTag returned=" .. tostring(removed))
    example_print_log("hasTag after remove=" .. tostring(lurek.asset.hasTag(h, "temp")))
    lurek.asset.unload(h)
end

--@api: lurek.asset.getTags
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "sfx")
    lurek.asset.addTag(h, "level_1")
    local tags = lurek.asset.getTags(h)
    example_print_log("tag count=" .. #tags)
    lurek.asset.unload(h)
end

--@api: lurek.asset.hasTag
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "enemy")
    example_print_log("hasTag enemy=" .. tostring(lurek.asset.hasTag(h, "enemy")))
    example_print_log("hasTag boss="  .. tostring(lurek.asset.hasTag(h, "boss")))
    lurek.asset.unload(h)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SEARCH
-- ─────────────────────────────────────────────────────────────────────────────

--@api: lurek.asset.findByName
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_TOML,   "toml", {name = "ProjectConfig"})
    local h2 = lurek.asset.load(PATH_JSON,   "json", {name = "FontAtlas"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader")  -- stem = "province_map"

    -- Substring search is case-insensitive.
    local matches = lurek.asset.findByName("config")
    example_print_log("findByName 'config' count=" .. #matches)  -- 1
    local shader_matches = lurek.asset.findByName("province")
    example_print_log("findByName 'province' count=" .. #shader_matches)  -- 1
    lurek.asset.clear()
end

--@api: lurek.asset.findByGroup
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "ui"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "ui"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})

    local ui = lurek.asset.findByGroup("ui")
    example_print_log("findByGroup 'ui' count=" .. #ui)   -- 2
    local gfx = lurek.asset.findByGroup("gfx")
    example_print_log("findByGroup 'gfx' count=" .. #gfx) -- 1
    lurek.asset.clear()
end

--@api: lurek.asset.findByTag
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_SHADER, "shader")
    lurek.asset.addTag(h1, "config")
    lurek.asset.addTag(h2, "config")
    lurek.asset.addTag(h3, "gfx")

    local config = lurek.asset.findByTag("config")
    example_print_log("findByTag 'config' count=" .. #config)  -- 2
    local gfx = lurek.asset.findByTag("gfx")
    example_print_log("findByTag 'gfx' count=" .. #gfx)        -- 1
    lurek.asset.clear()
end

--@api: lurek.asset.findByType
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_TOML,   "toml")
    local h4 = lurek.asset.load(PATH_SHADER, "shader")
    local h5 = lurek.asset.load(PATH_BIN,    "music")

    example_print_log("findByType 'toml' count="   .. #lurek.asset.findByType("toml"))    -- 2
    example_print_log("findByType 'json' count="   .. #lurek.asset.findByType("json"))    -- 1
    example_print_log("findByType 'shader' count=" .. #lurek.asset.findByType("shader"))  -- 1
    example_print_log("findByType 'music' count="  .. #lurek.asset.findByType("music"))   -- 1
    example_print_log("findByType 'audio' count="  .. #lurek.asset.findByType("audio"))   -- 0
    lurek.asset.clear()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LAssetHandle methods
-- ─────────────────────────────────────────────────────────────────────────────

--@api: LAssetHandle:type
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local type_name = h:type()
    local same_type = h:typeOf(type_name)
    example_print_log("type=" .. type_name)
    example_print_log("type matches handle=" .. tostring(same_type))
    lurek.asset.unload(h)
end

--@api: LAssetHandle:typeOf
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("typeOf LAssetHandle=" .. tostring(h:typeOf("LAssetHandle")))
    example_print_log("handle type name=" .. tostring(h:type()))
    example_print_log("typeOf other="        .. tostring(h:typeOf("other")))
    lurek.asset.unload(h)
end
