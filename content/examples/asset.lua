-- Asset registry and ref-counted media cache example.
-- Covers lurek.asset.* and LAssetHandle methods.
-- @module lurek.asset

-- Shared fixture paths used throughout the file.

-- ─────────────────────────────────────────────────────────────────────────────
-- LOAD / UNLOAD  (text-like types read content; binary types store path ref)
-- ─────────────────────────────────────────────────────────────────────────────


--@api: lurek.asset.load
do
    local path = "content/examples/assets/data/sample_config.toml"
    local handle = lurek.asset.load(path, "toml", { name = "build_config", group = "project", tags = { "config" } })
    local loaded = lurek.asset.isLoaded(handle)
    local name = lurek.asset.getName(handle)
    local group = lurek.asset.getGroup(handle)
    lurek.log.info("loaded asset name=" .. name .. " group=" .. group .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.unload
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local before = lurek.asset.isLoaded(handle)
    lurek.asset.unload(handle)
    local after = lurek.asset.isLoaded(handle)
    local refs = lurek.asset.refcount(handle)
    lurek.log.info("unload changed loaded=" .. tostring(before) .. " to " .. tostring(after) .. " refs=" .. refs)
end
--@api: lurek.asset.get
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local content = lurek.asset.get(handle)
    local length = type(content) == "string" and #content or 0
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset content length=" .. length .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.preload
do
    local results = {}
    lurek.asset.preload({
        { "content/examples/assets/data/sample_hello.txt", "text" },
        { "content/examples/assets/data/sample_config.toml", "toml" },
    }, function(loaded, total)
        results[#results + 1] = loaded and (loaded .. "/" .. tostring(total)) or "done"
    end)
    lurek.log.info("preload progress=" .. table.concat(results, ","))
    lurek.asset.clear()
end
--@api: lurek.asset.refcount
do
    local path = "content/examples/assets/data/sample_hello.txt"
    local first = lurek.asset.load(path, "text")
    local before = lurek.asset.refcount(first)
    local second = lurek.asset.load(path, "text")
    local after = lurek.asset.refcount(second)
    lurek.log.info("asset refcount " .. before .. " -> " .. after)
    lurek.asset.unload(first)
    lurek.asset.unload(second)
end
--@api: lurek.asset.isLoaded
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local before = lurek.asset.isLoaded(handle)
    lurek.asset.unload(handle)
    local after = lurek.asset.isLoaded(handle)
    local refs = lurek.asset.refcount(handle)
    lurek.log.info("isLoaded before=" .. tostring(before) .. " after=" .. tostring(after) .. " refs=" .. refs)
end
--@api: lurek.asset.stats
do
    lurek.asset.clear()
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "data" })
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader", { group = "gfx" })
    local stats = lurek.asset.stats()
    lurek.log.info("asset stats loaded=" .. stats.loaded .. " groups=" .. #stats.groups .. " refs=" .. stats.total_refs)
    lurek.asset.clear()
end
--@api: lurek.asset.clear
do
    lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text", { group = "temp" })
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "temp" })
    local before = lurek.asset.stats()
    lurek.asset.clear()
    local after = lurek.asset.stats()
    lurek.log.info("clear removed loaded=" .. before.loaded .. " -> " .. after.loaded)
end
--@api: lurek.asset.getPath
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local path = lurek.asset.getPath(handle)
    local type_name = lurek.asset.getType(handle)
    lurek.log.info("asset path=" .. path .. " type=" .. type_name)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.getType
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local type_name = lurek.asset.getType(handle)
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset type=" .. type_name .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.getInfo
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { name = "ui_config", group = "ui", tags = { "config", "ui" } })
    local info = lurek.asset.getInfo(handle)
    local tag = info.tags[1] or "none"
    lurek.log.info("asset info name=" .. info.name .. " group=" .. info.group .. " tag=" .. tag)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.setName
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local before = lurek.asset.getName(handle)
    lurek.asset.setName(handle, "font_atlas")
    local named = lurek.asset.findByName("font")
    lurek.log.info("asset name " .. before .. " -> " .. lurek.asset.getName(handle) .. " matches=" .. #named)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.getName
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local stem_name = lurek.asset.getName(handle)
    lurek.asset.setName(handle, "project_config")
    local custom_name = lurek.asset.getName(handle)
    lurek.log.info("asset names stem=" .. stem_name .. " custom=" .. custom_name)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.setGroup
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local before = lurek.asset.getGroup(handle)
    lurek.asset.setGroup(handle, "level_1")
    local grouped = lurek.asset.findByGroup("level_1")
    lurek.log.info("asset group " .. before .. " -> " .. lurek.asset.getGroup(handle) .. " matches=" .. #grouped)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.getGroup
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local unset = lurek.asset.getGroup(handle)
    lurek.asset.setGroup(handle, "hud")
    local group = lurek.asset.getGroup(handle)
    lurek.log.info("asset groups unset=" .. unset .. " set=" .. group)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.addTag
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "config")
    lurek.asset.addTag(handle, "ui")
    local tags = lurek.asset.getTags(handle)
    lurek.log.info("asset tag count=" .. #tags .. " has_config=" .. tostring(lurek.asset.hasTag(handle, "config")))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.removeTag
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "temp")
    local removed = lurek.asset.removeTag(handle, "temp")
    local still_tagged = lurek.asset.hasTag(handle, "temp")
    lurek.log.info("asset removeTag removed=" .. tostring(removed) .. " still_tagged=" .. tostring(still_tagged))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.getTags
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "ui")
    lurek.asset.addTag(handle, "level_1")
    local tags = lurek.asset.getTags(handle)
    lurek.log.info("asset tags count=" .. #tags .. " first=" .. tostring(tags[1]))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.hasTag
do
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "enemy")
    local has_enemy = lurek.asset.hasTag(handle, "enemy")
    local has_boss = lurek.asset.hasTag(handle, "boss")
    lurek.log.info("asset hasTag enemy=" .. tostring(has_enemy) .. " boss=" .. tostring(has_boss))
    lurek.asset.unload(handle)
end
--@api: lurek.asset.findByName
do
    lurek.asset.clear()
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { name = "ProjectConfig" })
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { name = "FontAtlas" })
    local config = lurek.asset.findByName("config")
    local font = lurek.asset.findByName("font")
    lurek.log.info("findByName config=" .. #config .. " font=" .. #font)
    lurek.asset.clear()
end
--@api: lurek.asset.findByGroup
do
    lurek.asset.clear()
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { group = "ui" })
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "ui" })
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader", { group = "gfx" })
    local ui = lurek.asset.findByGroup("ui")
    local gfx = lurek.asset.findByGroup("gfx")
    lurek.log.info("findByGroup ui=" .. #ui .. " gfx=" .. #gfx)
    lurek.asset.clear()
end

--@api: lurek.asset.findByTag
do
    lurek.asset.clear()
    local config_json = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local config_toml = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local shader = lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader")
    lurek.asset.addTag(config_json, "config")
    lurek.asset.addTag(config_toml, "config")
    lurek.asset.addTag(shader, "gfx")
    local config = lurek.asset.findByTag("config")
    local gfx = lurek.asset.findByTag("gfx")
    lurek.log.info("findByTag config=" .. #config .. " gfx=" .. #gfx)
    lurek.asset.clear()
end

--@api: lurek.asset.findByType
do
    lurek.asset.clear()
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader")
    local toml = lurek.asset.findByType("toml")
    local json = lurek.asset.findByType("json")
    local shader = lurek.asset.findByType("shader")
    lurek.log.info("findByType toml=" .. #toml .. " json=" .. #json .. " shader=" .. #shader)
    lurek.asset.clear()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LAssetHandle methods
-- ─────────────────────────────────────────────────────────────────────────────

--@api: LAssetHandle:type
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local type_name = handle:type()
    local same_type = handle:typeOf(type_name)
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset handle type=" .. type_name .. " same=" .. tostring(same_type) .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
end

--@api: LAssetHandle:typeOf
do
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local is_handle = handle:typeOf("LAssetHandle")
    local is_other = handle:typeOf("other")
    local type_name = handle:type()
    lurek.log.info("asset typeOf handle=" .. tostring(is_handle) .. " other=" .. tostring(is_other) .. " type=" .. type_name)
    lurek.asset.unload(handle)
end
--@api: lurek.asset.watch
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local watched = lurek.asset.watch(handle)
    local info = lurek.asset.resolve(watched)
    lurek.log.info("[asset] watched=" .. tostring(info.watched))
    lurek.asset.unload(handle)
end

--@api: lurek.asset.reload
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local before = lurek.asset.getRevision(handle)
    local after = lurek.asset.reload(handle)
    lurek.log.info("[asset] reload revision " .. tostring(before) .. " -> " .. tostring(after))
    lurek.asset.unload(handle)
end

--@api: lurek.asset.getRevision
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local revision = lurek.asset.getRevision(handle)
    local info = lurek.asset.resolve(handle)
    lurek.log.info("[asset] revision=" .. tostring(revision) .. " type=" .. tostring(info.type))
    lurek.asset.unload(handle)
end

--@api: lurek.asset.onReload
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local seen = 0
    lurek.asset.onReload(handle, function(_, revision) seen = revision end)
    local revision = lurek.asset.reload(handle)
    lurek.log.info("[asset] callback revision=" .. tostring(seen or revision))
    lurek.asset.unload(handle)
end

--@api: lurek.asset.resolve
do
    local handle = lurek.asset.load("Cargo.toml", "toml", { name = "cargo-example" })
    local info = lurek.asset.resolve(handle)
    local label = info.name .. ":" .. info.type
    lurek.log.info("[asset] resolved " .. label)
    lurek.asset.unload(handle)
end

--@api: lurek.asset.loadManifest
do
    local handles = lurek.asset.loadManifest("tests/fixtures/asset_manifest.toml")
    local first = handles[1]
    local info = lurek.asset.resolve(first)
    lurek.log.info("[asset] manifest loaded " .. tostring(info.name))
    lurek.asset.clear()
end
