-- content/examples/mods.lua
-- Auto-generated from content/examples2/mods_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/mods.lua

--- Mods Module Part 1: LMod creation, metadata, hooks, config, registry


--@api-stub: lurek.mods.newMod
-- Creates a mod from a metadata table.
do
    ---@type LMod
    local m = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "A test mod",
        priority = 10,
    })
    print("id=" .. m:getId() .. " name=" .. m:getName())
    print("version=" .. m:getVersion() .. " author=" .. m:getAuthor())
    print("desc=" .. m:getDescription())
    print("priority=" .. m:getPriority())
end

--@api-stub: LMod:setEnabled
-- Enable state and loaded flag. Focus: setEnabled.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()) .. " loaded=" .. tostring(m:isLoaded()))
    m:setEnabled(false)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:isEnabled
-- Enable state and loaded flag. Focus: isEnabled.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()) .. " loaded=" .. tostring(m:isLoaded()))
    m:setEnabled(false)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:isLoaded
-- Enable state and loaded flag. Focus: isLoaded.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()) .. " loaded=" .. tostring(m:isLoaded()))
    m:setEnabled(false)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:setHook
-- Registering and querying hooks. Focus: setHook.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    m:setHook("onUnload", function() print("unloaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
    print("has onSave = " .. tostring(m:hasHook("onSave")))
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
    local fn = m:getHook("onLoad")
    if fn then fn() end
end

--@api-stub: LMod:getHook
-- Registering and querying hooks. Focus: getHook.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    m:setHook("onUnload", function() print("unloaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
    print("has onSave = " .. tostring(m:hasHook("onSave")))
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
    local fn = m:getHook("onLoad")
    if fn then fn() end
end

--@api-stub: LMod:hasHook
-- Registering and querying hooks. Focus: hasHook.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    m:setHook("onUnload", function() print("unloaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
    print("has onSave = " .. tostring(m:hasHook("onSave")))
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
    local fn = m:getHook("onLoad")
    if fn then fn() end
end

--@api-stub: LMod:getHookNames
-- Registering and querying hooks. Focus: getHookNames.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    m:setHook("onUnload", function() print("unloaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
    print("has onSave = " .. tostring(m:hasHook("onSave")))
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
    local fn = m:getHook("onLoad")
    if fn then fn() end
end

--@api-stub: LMod:setConfig
-- Storing and retrieving mod config. Focus: setConfig.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "cfg", name = "Cfg", version = "1.0", author = "A", description = "d"})
    m:setConfig({difficulty = "hard", volume = 0.8})
    local cfg = m:getConfig()
    if cfg then
        print("config stored")
    end
end

--@api-stub: LMod:getConfig
-- Storing and retrieving mod config. Focus: getConfig.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "cfg", name = "Cfg", version = "1.0", author = "A", description = "d"})
    m:setConfig({difficulty = "hard", volume = 0.8})
    local cfg = m:getConfig()
    if cfg then
        print("config stored")
    end
end

--@api-stub: LMod:setConfigSchema
-- Config schema for UI/validation. Focus: setConfigSchema.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "schema", name = "Schema", version = "1.0", author = "A", description = "d"})
    m:setConfigSchema({
        {key = "volume", type = "number", default = "0.5"},
        {key = "language", type = "string", default = "en"},
    })
    local schema = m:getConfigSchema()
    for _, entry in ipairs(schema) do
        print(entry.key .. " (" .. entry.type .. ") = " .. entry.default)
    end
end

--@api-stub: LMod:getConfigSchema
-- Config schema for UI/validation. Focus: getConfigSchema.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "schema", name = "Schema", version = "1.0", author = "A", description = "d"})
    m:setConfigSchema({
        {key = "volume", type = "number", default = "0.5"},
        {key = "language", type = "string", default = "en"},
    })
    local schema = m:getConfigSchema()
    for _, entry in ipairs(schema) do
        print(entry.key .. " (" .. entry.type .. ") = " .. entry.default)
    end
end

--@api-stub: LMod:setApiVersion
-- API version compatibility. Focus: setApiVersion.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "ver", name = "Ver", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("2.0.0")
    print("api version = " .. m:getApiVersion())
end

--@api-stub: LMod:getApiVersion
-- API version compatibility. Focus: getApiVersion.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "ver", name = "Ver", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("2.0.0")
    print("api version = " .. m:getApiVersion())
end

--@api-stub: LMod:setCapabilities
-- Declaring capabilities. Focus: setCapabilities.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "caps", name = "Caps", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer", "audio", "physics"})
    local caps = m:getCapabilities()
    print("capabilities = " .. table.concat(caps, ", "))
end

--@api-stub: LMod:getCapabilities
-- Declaring capabilities. Focus: getCapabilities.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "caps", name = "Caps", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer", "audio", "physics"})
    local caps = m:getCapabilities()
    print("capabilities = " .. table.concat(caps, ", "))
end

--@api-stub: LMod:getDependencies
-- Mod dependencies.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "deps", name = "Deps", version = "1.0", author = "A", description = "d"})
    local deps = m:getDependencies()
    print("dependencies = " .. #deps)
end

--@api-stub: LMod:releaseRefs
-- Release stored references.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "release", name = "R", version = "1.0", author = "A", description = "d"})
    m:setHook("test", function() end)
    m:setConfig({x = 1})
    m:releaseRefs()
    print("refs released")
end

--@api-stub: lurek.mods.newRegistry
-- Creates a content registry.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("weapon")
    reg:registerType("armor")
    local types = reg:getTypes()
    print("types = " .. table.concat(types, ", "))
end

--@api-stub: LContentRegistry:register
-- Storing and retrieving content. Focus: register.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    reg:register("item", "shield", {name = "Shield", armor = 5})
    local sword = reg:get("item", "sword")
    if sword then
        print("got: " .. (sword --[[@as table]]).name)
    end
    local all = reg:getAll("item")
    print("all items = " .. #all)
end

--@api-stub: LContentRegistry:get
-- Storing and retrieving content. Focus: get.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    reg:register("item", "shield", {name = "Shield", armor = 5})
    local sword = reg:get("item", "sword")
    if sword then
        print("got: " .. (sword --[[@as table]]).name)
    end
    local all = reg:getAll("item")
    print("all items = " .. #all)
end

--@api-stub: LContentRegistry:getAll
-- Storing and retrieving content. Focus: getAll.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    reg:register("item", "shield", {name = "Shield", armor = 5})
    local sword = reg:get("item", "sword")
    if sword then
        print("got: " .. (sword --[[@as table]]).name)
    end
    local all = reg:getAll("item")
    print("all items = " .. #all)
end

--@api-stub: lurek.mods.checkApiVersion
-- Checks mod/host API compatibility.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "compat", name = "C", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("1.0.0")
    local ok, err = lurek.mods.checkApiVersion(m, "1.5.0")
    print("compatible = " .. tostring(ok))
    if err then print("error = " .. err) end
end

--- Mods Module Part 2: LModManager — registration, load order, scanning, reload


--@api-stub: lurek.mods.newModManager
-- Creates an empty mod manager.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    print("mod count = " .. mgr:getModCount())
end

--@api-stub: LModManager:registerMod
-- Registers mods with the manager. Focus: registerMod.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "extra", name = "Extra", version = "1.0", author = "B", description = "Extra mod", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    print("count = " .. mgr:getModCount())
    print("has core = " .. tostring(mgr:hasMod("core")))
    print("has missing = " .. tostring(mgr:hasMod("missing")))
end

--@api-stub: LModManager:hasMod
-- Registers mods with the manager. Focus: hasMod.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "extra", name = "Extra", version = "1.0", author = "B", description = "Extra mod", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    print("count = " .. mgr:getModCount())
    print("has core = " .. tostring(mgr:hasMod("core")))
    print("has missing = " .. tostring(mgr:hasMod("missing")))
end

--@api-stub: LModManager:getModCount
-- Registers mods with the manager. Focus: getModCount.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "extra", name = "Extra", version = "1.0", author = "B", description = "Extra mod", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    print("count = " .. mgr:getModCount())
    print("has core = " .. tostring(mgr:hasMod("core")))
    print("has missing = " .. tostring(mgr:hasMod("missing")))
end

--@api-stub: LModManager:unregisterMod
-- Removes a mod by id.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "temp", name = "Temp", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    print("before = " .. mgr:getModCount())
    local removed = mgr:unregisterMod("temp")
    print("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end

--@api-stub: LModManager:getAllMods
-- Lists all registered mods.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "list", name = "List", version = "2.0", author = "X", description = "d", priority = 5})
    m:setEnabled(true)
    mgr:registerMod(m)
    local all = mgr:getAllMods()
    for _, info in ipairs(all) do
        print(info.id .. " v" .. info.version .. " pri=" .. info.priority)
    end
end

--@api-stub: LModManager:getLoadOrder
-- Managing mod load order. Focus: getLoadOrder.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    mgr:setLoadOrder({"b", "a"})
    local order = mgr:getLoadOrder()
    for i, info in ipairs(order) do
        print(i .. ": " .. info.id)
    end
    mgr:clearLoadOrder()
end

--@api-stub: LModManager:setLoadOrder
-- Managing mod load order. Focus: setLoadOrder.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    mgr:setLoadOrder({"b", "a"})
    local order = mgr:getLoadOrder()
    for i, info in ipairs(order) do
        print(i .. ": " .. info.id)
    end
    mgr:clearLoadOrder()
end

--@api-stub: LModManager:clearLoadOrder
-- Managing mod load order. Focus: clearLoadOrder.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m1 = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0})
    ---@type LMod
    local m2 = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    m1:setEnabled(true)
    m2:setEnabled(true)
    mgr:registerMod(m1)
    mgr:registerMod(m2)
    mgr:setLoadOrder({"b", "a"})
    local order = mgr:getLoadOrder()
    for i, info in ipairs(order) do
        print(i .. ": " .. info.id)
    end
    mgr:clearLoadOrder()
end

--@api-stub: LModManager:hasCircularDependencies
-- Dependency validation. Focus: hasCircularDependencies.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "safe", name = "Safe", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    print("circular = " .. tostring(mgr:hasCircularDependencies()))
    local msgs = mgr:validateDependencies()
    print("validation messages = " .. #msgs)
end

--@api-stub: LModManager:validateDependencies
-- Dependency validation. Focus: validateDependencies.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "safe", name = "Safe", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    print("circular = " .. tostring(mgr:hasCircularDependencies()))
    local msgs = mgr:validateDependencies()
    print("validation messages = " .. #msgs)
end

--@api-stub: LModManager:markForReload
-- Reload workflow. Focus: markForReload.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    mgr:markForReload("hot")
    local queue = mgr:getReloadQueue()
    print("queued = " .. #queue)
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    mgr:clearReloadQueue()
end

--@api-stub: LModManager:getReloadQueue
-- Reload workflow. Focus: getReloadQueue.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    mgr:markForReload("hot")
    local queue = mgr:getReloadQueue()
    print("queued = " .. #queue)
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    mgr:clearReloadQueue()
end

--@api-stub: LModManager:processReloadQueue
-- Reload workflow. Focus: processReloadQueue.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    mgr:markForReload("hot")
    local queue = mgr:getReloadQueue()
    print("queued = " .. #queue)
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    mgr:clearReloadQueue()
end

--@api-stub: LModManager:clearReloadQueue
-- Reload workflow. Focus: clearReloadQueue.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    mgr:markForReload("hot")
    local queue = mgr:getReloadQueue()
    print("queued = " .. #queue)
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    mgr:clearReloadQueue()
end

--@api-stub: LModManager:getModPath
-- Retrieves mod filesystem path.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "pathed", name = "P", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    local path = mgr:getModPath("pathed")
    print("path = " .. tostring(path))
end

--@api-stub: LModManager:getModsByCapability
-- Filters mods by capability.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    ---@type LMod
    local m = lurek.mods.newMod({id = "render_mod", name = "R", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer"})
    m:setEnabled(true)
    mgr:registerMod(m)
    local renderers = mgr:getModsByCapability("renderer")
    print("renderer mods = " .. #renderers)
end

--@api-stub: LModManager:scanFolder
-- Scans a folder for mods.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    local found = mgr:scanFolder("content/plugins")
    print("scanned mods = " .. #found)
    for _, info in ipairs(found) do
        print("  " .. info.id .. " - " .. info.name)
    end
end

--- Mods Module: LContentRegistry, LMod, LModManager


--@api-stub: LContentRegistry:getTypes
-- Content registry: register, get, list types. Focus: getTypes.
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    for _, t in ipairs(types) do print("type=" .. t) end
    reg:register("item", "sword", { damage = 10 })
    reg:register("item", "bow", { range = 5 })
    local sword = reg:get("item", "sword")
    print("sword = " .. tostring(sword))
    local all = reg:getAll("item")
    print("all items = " .. #all)
    print(reg:type())
    print(reg:typeOf("LContentRegistry"))
end

--@api-stub: LContentRegistry:registerType
-- Content registry: register, get, list types. Focus: registerType.
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    for _, t in ipairs(types) do print("type=" .. t) end
    reg:register("item", "sword", { damage = 10 })
    reg:register("item", "bow", { range = 5 })
    local sword = reg:get("item", "sword")
    print("sword = " .. tostring(sword))
    local all = reg:getAll("item")
    print("all items = " .. #all)
    print(reg:type())
    print(reg:typeOf("LContentRegistry"))
end

--@api-stub: LContentRegistry:type
-- Content registry: register, get, list types. Focus: type.
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    for _, t in ipairs(types) do print("type=" .. t) end
    reg:register("item", "sword", { damage = 10 })
    reg:register("item", "bow", { range = 5 })
    local sword = reg:get("item", "sword")
    print("sword = " .. tostring(sword))
    local all = reg:getAll("item")
    print("all items = " .. #all)
    print(reg:type())
    print(reg:typeOf("LContentRegistry"))
end

--@api-stub: LContentRegistry:typeOf
-- Content registry: register, get, list types. Focus: typeOf.
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    for _, t in ipairs(types) do print("type=" .. t) end
    reg:register("item", "sword", { damage = 10 })
    reg:register("item", "bow", { range = 5 })
    local sword = reg:get("item", "sword")
    print("sword = " .. tostring(sword))
    local all = reg:getAll("item")
    print("all items = " .. #all)
    print(reg:type())
    print(reg:typeOf("LContentRegistry"))
end

--@api-stub: LMod:getAuthor
-- Mod: metadata, hooks, config, enable/disable. Focus: getAuthor.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:getDescription
-- Mod: metadata, hooks, config, enable/disable. Focus: getDescription.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:getId
-- Mod: metadata, hooks, config, enable/disable. Focus: getId.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:getName
-- Mod: metadata, hooks, config, enable/disable. Focus: getName.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:getPriority
-- Mod: metadata, hooks, config, enable/disable. Focus: getPriority.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:getVersion
-- Mod: metadata, hooks, config, enable/disable. Focus: getVersion.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:type
-- Mod: metadata, hooks, config, enable/disable. Focus: type.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LMod:typeOf
-- Mod: metadata, hooks, config, enable/disable. Focus: typeOf.
do
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod" })
    m:setApiVersion("1.0")
    print(m:getApiVersion())
    m:setCapabilities({ "maps", "items" })
    local caps = m:getCapabilities()
    print("caps=" .. #caps)
    m:setConfig({ volume = 0.8 })
    local cfg = m:getConfig()
    print("config=" .. tostring(cfg))
    m:setConfigSchema({ volume = "number" })
    local schema = m:getConfigSchema()
    print("schema=" .. tostring(schema))
    local deps = m:getDependencies()
    print("deps=" .. #deps)
    print(m:getDescription())
    print(m:getId())
    print(m:getName())
    print(m:getPriority())
    print(m:getVersion())
    print(m:getAuthor())
    m:setHook("onLoad", function() print("loaded") end)
    local names = m:getHookNames()
    print("hooks=" .. #names)
    print(m:hasHook("onLoad"))
    local fn = m:getHook("onLoad")
    print("hook=" .. tostring(fn))
    print(m:isEnabled())
    print(m:isLoaded())
    m:setEnabled(true)
    m:releaseRefs()
    print(m:type())
    print(m:typeOf("LMod"))
end

--@api-stub: LModManager:type
-- Mod manager: registry, load order, reload, capability filtering. Focus: type.
do
    local mm = lurek.mods.newModManager()
    local m = lurek.mods.newMod({ id = "mgr_mod", name = "Mgr Mod", version = "1.0", author = "Dev", description = "For manager test" })
    print(mm:getModCount())
    print(mm:hasMod(m:getId()))
    local all = mm:getAllMods()
    print("mods=" .. #all)
    local order = mm:getLoadOrder()
    print("order=" .. #order)
    mm:setLoadOrder({ m:getId() })
    mm:clearLoadOrder()
    local caps = mm:getModsByCapability("maps")
    print("capable=" .. #caps)
    local path = mm:getModPath(m:getId())
    print("path=" .. tostring(path))
    mm:markForReload(m:getId())
    local queue = mm:getReloadQueue()
    print("queue=" .. #queue)
    mm:clearReloadQueue()
    mm:processReloadQueue()
    local hasCycles = mm:hasCircularDependencies()
    print("cycles=" .. tostring(hasCycles))
    local errors = mm:validateDependencies()
    print("errors=" .. #errors)
    mm:scanFolder("content/")
    mm:unregisterMod(m:getId())
    print(mm:type())
    print(mm:typeOf("LModManager"))
end

--@api-stub: LModManager:typeOf
-- Mod manager: registry, load order, reload, capability filtering. Focus: typeOf.
do
    local mm = lurek.mods.newModManager()
    local m = lurek.mods.newMod({ id = "mgr_mod", name = "Mgr Mod", version = "1.0", author = "Dev", description = "For manager test" })
    print(mm:getModCount())
    print(mm:hasMod(m:getId()))
    local all = mm:getAllMods()
    print("mods=" .. #all)
    local order = mm:getLoadOrder()
    print("order=" .. #order)
    mm:setLoadOrder({ m:getId() })
    mm:clearLoadOrder()
    local caps = mm:getModsByCapability("maps")
    print("capable=" .. #caps)
    local path = mm:getModPath(m:getId())
    print("path=" .. tostring(path))
    mm:markForReload(m:getId())
    local queue = mm:getReloadQueue()
    print("queue=" .. #queue)
    mm:clearReloadQueue()
    mm:processReloadQueue()
    local hasCycles = mm:hasCircularDependencies()
    print("cycles=" .. tostring(hasCycles))
    local errors = mm:validateDependencies()
    print("errors=" .. #errors)
    mm:scanFolder("content/")
    mm:unregisterMod(m:getId())
    print(mm:type())
    print(mm:typeOf("LModManager"))
end

print("content/examples/mods.lua")
