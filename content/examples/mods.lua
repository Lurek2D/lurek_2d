-- content/examples/mods.lua
-- Auto-generated from content/examples2/mods_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/mods.lua

--- Mods Module Part 1: LMod creation, metadata, hooks, config, registry

--@api-stub: lurek.mods.newMod
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "Example mod",
        priority = 10,
    })
    print("id = " .. mod:getId())
    print("priority = " .. mod:getPriority())
end

--@api-stub: LMod:setEnabled
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    print("before = " .. tostring(mod:isEnabled()))
    mod:setEnabled(false)
    print("after = " .. tostring(mod:isEnabled()))
end

--@api-stub: LMod:isEnabled
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    mod:setEnabled(false)
    print("enabled = " .. tostring(mod:isEnabled()))
end

--@api-stub: LMod:isLoaded
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    print("loaded = " .. tostring(mod:isLoaded()))
end

--@api-stub: LMod:setHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        print("hook fired")
    end)
    print("has onLoad = " .. tostring(mod:hasHook("onLoad")))
    print("hook value = " .. tostring(mod:getHook("onLoad") ~= nil))
end

--@api-stub: LMod:getHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        print("hook fired")
    end)
    local hook = mod:getHook("onLoad")
    print("hook exists = " .. tostring(hook ~= nil))
end

--@api-stub: LMod:hasHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    print("before = " .. tostring(mod:hasHook("onLoad")))
    mod:setHook("onLoad", function()
    end)
    print("after = " .. tostring(mod:hasHook("onLoad")))
end

--@api-stub: LMod:getHookNames
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
    end)
    mod:setHook("onUnload", function()
    end)
    local names = mod:getHookNames()
    print("hook count = " .. #names)
    print("has onLoad = " .. tostring(mod:hasHook("onLoad")))
end

--@api-stub: LMod:setConfig
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "hard", volume = 0.8 })
    local config = mod:getConfig()
    print("difficulty = " .. config.difficulty)
    print("volume = " .. tostring(config.volume))
end

--@api-stub: LMod:getConfig
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "story", subtitles = true })
    local config = mod:getConfig()
    print("config exists = " .. tostring(config ~= nil))
    print("subtitles = " .. tostring(config.subtitles))
end

--@api-stub: LMod:setConfigSchema
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    print("schema count = " .. #schema)
    print("first key = " .. schema[1].key)
end

--@api-stub: LMod:getConfigSchema
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    print("schema entries = " .. #schema)
    print("second default = " .. schema[2].default)
end

--@api-stub: LMod:setApiVersion
do
    local mod = lurek.mods.newMod({ id = "ver", name = "Ver" })
    mod:setApiVersion("2.0.0")
    print("api version = " .. mod:getApiVersion())
end

--@api-stub: LMod:getApiVersion
do
    local mod = lurek.mods.newMod({ id = "ver", name = "Ver" })
    mod:setApiVersion("1.2.0")
    print("api version = " .. mod:getApiVersion())
end

--@api-stub: LMod:setCapabilities
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    print("capability count = " .. #capabilities)
    print("first = " .. capabilities[1])
end

--@api-stub: LMod:getCapabilities
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    print("capabilities = " .. table.concat(capabilities, ", "))
end

--@api-stub: LMod:getDependencies
do
    local mod = lurek.mods.newMod({
        id = "deps",
        name = "Deps",
        dependencies = { "core", "ui" },
    })
    local dependencies = mod:getDependencies()
    print("dependency count = " .. #dependencies)
    print("first dependency = " .. dependencies[1])
end

--@api-stub: LMod:releaseRefs
do
    local mod = lurek.mods.newMod({ id = "release", name = "Release" })
    mod:setHook("test", function()
    end)
    mod:setConfig({ x = 1 })
    mod:releaseRefs()
    print("hook exists = " .. tostring(mod:getHook("test") ~= nil))
    print("config exists = " .. tostring(mod:getConfig() ~= nil))
end

--@api-stub: lurek.mods.newRegistry
do
    local reg = lurek.mods.newRegistry()
    print("registry created = " .. tostring(reg ~= nil))
    print("type = " .. reg:type())
end

--@api-stub: LContentRegistry:register
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    print("stored = " .. tostring(sword ~= nil))
    print("damage = " .. tostring(sword.damage))
end

--@api-stub: LContentRegistry:get
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    print("got = " .. tostring(sword ~= nil))
    print("name = " .. sword.name)
end

--@api-stub: LContentRegistry:getAll
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", { name = "Shield", armor = 5 })
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local items = reg:getAll("item")
    print("shield name = " .. items.shield.name)
    print("sword damage = " .. tostring(items.sword.damage))
end

--@api-stub: lurek.mods.checkApiVersion
do
    local mod = lurek.mods.newMod({ id = "compat", name = "Compat" })
    mod:setApiVersion("2.0.0")
    local ok, err = lurek.mods.checkApiVersion(mod, "1.5.0")
    print("compatible = " .. tostring(ok))
    print("error = " .. tostring(err))
end

--- Mods Module Part 2: LModManager — registration, load order, scanning, reload

--@api-stub: lurek.mods.newModManager
do
    local mgr = lurek.mods.newModManager()
    print("mod count = " .. mgr:getModCount())
    print("type = " .. mgr:type())
end

--@api-stub: LModManager:registerMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mod:setEnabled(true)
    mgr:registerMod(mod)
    print("count = " .. mgr:getModCount())
end

--@api-stub: LModManager:hasMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    print("before = " .. tostring(mgr:hasMod("core")))
    mgr:registerMod(mod)
    print("after = " .. tostring(mgr:hasMod("core")))
end

--@api-stub: LModManager:getModCount
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    print("before = " .. mgr:getModCount())
    mgr:registerMod(mod)
    print("after = " .. mgr:getModCount())
end

--@api-stub: LModManager:unregisterMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "temp", name = "Temp" })
    mgr:registerMod(mod)
    local removed = mgr:unregisterMod("temp")
    print("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end

--@api-stub: LModManager:getAllMods
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "list", name = "List", version = "2.0.0" })
    mgr:registerMod(mod)
    local mods = mgr:getAllMods()
    print("mods = " .. #mods)
    print("first id = " .. mods[1].id)
end

--@api-stub: LModManager:getLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    local patch = lurek.mods.newMod({
        id = "patch",
        name = "Patch",
        priority = 10,
        dependencies = { "core" },
    })
    mgr:registerMod(core)
    mgr:registerMod(patch)
    local order = mgr:getLoadOrder()
    print("first = " .. order[1].id)
    print("second = " .. order[2].id)
end

--@api-stub: LModManager:setLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    local order = mgr:getLoadOrder()
    print("first = " .. order[1].id)
    print("second = " .. order[2].id)
end

--@api-stub: LModManager:clearLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    print("custom first = " .. mgr:getLoadOrder()[1].id)
    mgr:clearLoadOrder()
    print("default first = " .. mgr:getLoadOrder()[1].id)
end

--@api-stub: LModManager:hasCircularDependencies
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", dependencies = { "b" } })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", dependencies = { "a" } })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    print("circular = " .. tostring(mgr:hasCircularDependencies()))
end

--@api-stub: LModManager:validateDependencies
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({
        id = "addon",
        name = "Addon",
        dependencies = { "core" },
    })
    mgr:registerMod(mod)
    local missing = mgr:validateDependencies()
    print("missing count = " .. #missing)
    print("first missing = " .. tostring(missing[1]))
end

--@api-stub: LModManager:markForReload
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    local marked = mgr:markForReload("hot")
    print("marked = " .. tostring(marked))
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:getReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:processReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    print("queued after = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:clearReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mgr:clearReloadQueue()
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:getModPath
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "memory_only", name = "Memory Only" })
    mgr:registerMod(mod)
    local path = mgr:getModPath("memory_only")
    print("has mod = " .. tostring(mgr:hasMod("memory_only")))
    print("path = " .. tostring(path))
end

--@api-stub: LModManager:getModsByCapability
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "render_mod", name = "Renderer Mod" })
    mod:setCapabilities({ "renderer" })
    mgr:registerMod(mod)
    local renderers = mgr:getModsByCapability("renderer")
    print("renderer mods = " .. #renderers)
    print("first id = " .. renderers[1].id)
end

--@api-stub: LModManager:scanFolder
do
    local mgr = lurek.mods.newModManager()
    local found = mgr:scanFolder("content/examples")
    print("scanned mods = " .. #found)
    print("registered = " .. mgr:getModCount())
end

--- Mods Module: LContentRegistry, LMod, LModManager

--@api-stub: LContentRegistry:getTypes
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    print("type count = " .. #types)
end

--@api-stub: LContentRegistry:registerType
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    print("types = " .. #types)
end

--@api-stub: LContentRegistry:type
do
    local reg = lurek.mods.newRegistry()
    print("type = " .. reg:type())
end

--@api-stub: LContentRegistry:typeOf
do
    local reg = lurek.mods.newRegistry()
    print("is registry = " .. tostring(reg:typeOf("LContentRegistry")))
end

--@api-stub: LMod:getAuthor
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", author = "Dev" })
    print("author = " .. mod:getAuthor())
end

--@api-stub: LMod:getDescription
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        description = "Adds extra encounters",
    })
    print("description = " .. mod:getDescription())
end

--@api-stub: LMod:getId
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("id = " .. mod:getId())
end

--@api-stub: LMod:getName
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("name = " .. mod:getName())
end

--@api-stub: LMod:getPriority
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", priority = 25 })
    print("priority = " .. mod:getPriority())
end

--@api-stub: LMod:getVersion
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.4.2" })
    print("version = " .. mod:getVersion())
end

--@api-stub: LMod:type
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("type = " .. mod:type())
end

--@api-stub: LMod:typeOf
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("is LMod = " .. tostring(mod:typeOf("LMod")))
end

--@api-stub: LModManager:type
do
    local mgr = lurek.mods.newModManager()
    print("type = " .. mgr:type())
end

--@api-stub: LModManager:typeOf
do
    local mgr = lurek.mods.newModManager()
    print("is manager = " .. tostring(mgr:typeOf("LModManager")))
end
