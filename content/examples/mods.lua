-- content/examples/mods.lua
-- Auto-generated from content/examples2/mods_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/mods.lua

--- Mods Module Part 1: LMod creation, metadata, hooks, config, registry


--@api-stub: lurek.mods.newMod
do
    ---@type LMod
    local m = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.0.0", author = "Dev", description = "A test mod", priority = 10 })
    print("id=" .. m:getId() .. " name=" .. m:getName())
end

--@api-stub: LMod:setEnabled
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:isEnabled
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:isLoaded
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    print("loaded=" .. tostring(m:isLoaded()))
end

--@api-stub: LMod:setHook
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
end

--@api-stub: LMod:getHook
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    local fn = m:getHook("onLoad")
    print("hook exists = " .. tostring(fn ~= nil))
end

--@api-stub: LMod:hasHook
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
end

--@api-stub: LMod:getHookNames
do
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() end)
    m:setHook("onUnload", function() end)
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
end

--@api-stub: LMod:setConfig
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "cfg", name = "Cfg", version = "1.0", author = "A", description = "d"})
    m:setConfig({difficulty = "hard", volume = 0.8})
    print("config stored")
end

--@api-stub: LMod:getConfig
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "cfg", name = "Cfg", version = "1.0", author = "A", description = "d"})
    m:setConfig({difficulty = "hard", volume = 0.8})
    local cfg = m:getConfig()
    print("config exists = " .. tostring(cfg ~= nil))
end

--@api-stub: LMod:setConfigSchema
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "schema", name = "Schema", version = "1.0", author = "A", description = "d"})
    m:setConfigSchema({ {key = "volume", type = "number", default = "0.5"}, {key = "language", type = "string", default = "en"} })
    print("schema set")
end

--@api-stub: LMod:getConfigSchema
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "schema", name = "Schema", version = "1.0", author = "A", description = "d"})
    m:setConfigSchema({ {key = "volume", type = "number", default = "0.5"}, {key = "language", type = "string", default = "en"} })
    local schema = m:getConfigSchema()
    print("schema entries = " .. #schema)
end

--@api-stub: LMod:setApiVersion
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "ver", name = "Ver", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("2.0.0")
    print("api version = " .. m:getApiVersion())
end

--@api-stub: LMod:getApiVersion
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "ver", name = "Ver", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("2.0.0")
    print("api version = " .. m:getApiVersion())
end

--@api-stub: LMod:setCapabilities
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "caps", name = "Caps", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer", "audio", "physics"})
    print("capabilities set")
end

--@api-stub: LMod:getCapabilities
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "caps", name = "Caps", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer", "audio", "physics"})
    local caps = m:getCapabilities()
    print("capabilities = " .. table.concat(caps, ", "))
end

--@api-stub: LMod:getDependencies
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "deps", name = "Deps", version = "1.0", author = "A", description = "d"})
    local deps = m:getDependencies()
    print("dependencies = " .. #deps)
end

--@api-stub: LMod:releaseRefs
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "release", name = "R", version = "1.0", author = "A", description = "d"})
    m:setHook("test", function() end); m:setConfig({x = 1})
    m:releaseRefs()
    print("refs released")
end

--@api-stub: lurek.mods.newRegistry
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    print("registry created = " .. tostring(reg ~= nil))
end

--@api-stub: LContentRegistry:register
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    print("got = " .. tostring(reg:get("item", "sword") ~= nil))
end

--@api-stub: LContentRegistry:get
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    local sword = reg:get("item", "sword")
    print("got = " .. tostring(sword ~= nil))
end

--@api-stub: LContentRegistry:getAll
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", {name = "Shield", armor = 5})
    print("all items = " .. #reg:getAll("item"))
end

--@api-stub: lurek.mods.checkApiVersion
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "compat", name = "C", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("1.0.0")
    local ok, err = lurek.mods.checkApiVersion(m, "1.5.0")
    print("compatible = " .. tostring(ok) .. " error = " .. tostring(err))
end

--- Mods Module Part 2: LModManager — registration, load order, scanning, reload


--@api-stub: lurek.mods.newModManager
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    print("mod count = " .. mgr:getModCount())
end

--@api-stub: LModManager:registerMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    mod:setEnabled(true); mgr:registerMod(mod)
    print("count = " .. mgr:getModCount())
end

--@api-stub: LModManager:hasMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    mod:setEnabled(true); mgr:registerMod(mod)
    print("has core = " .. tostring(mgr:hasMod("core")))
end

--@api-stub: LModManager:getModCount
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "core", name = "Core", version = "1.0", author = "A", description = "Core mod", priority = 0})
    mod:setEnabled(true); mgr:registerMod(mod)
    print("count = " .. mgr:getModCount())
end

--@api-stub: LModManager:unregisterMod
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "temp", name = "Temp", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true); mgr:registerMod(m)
    local removed = mgr:unregisterMod("temp")
    print("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end

--@api-stub: LModManager:getAllMods
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "list", name = "List", version = "2.0", author = "X", description = "d"})
    m:setEnabled(true)
    mgr:registerMod(m)
    print("mods = " .. #mgr:getAllMods())
end

--@api-stub: LModManager:getLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0}); local mod_b = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    mod_a:setEnabled(true); mod_b:setEnabled(true); mgr:registerMod(mod_a); mgr:registerMod(mod_b)
    mgr:setLoadOrder({"b", "a"})
    print("first = " .. mgr:getLoadOrder()[1].id)
end

--@api-stub: LModManager:setLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0}); local mod_b = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    mod_a:setEnabled(true); mod_b:setEnabled(true); mgr:registerMod(mod_a); mgr:registerMod(mod_b)
    mgr:setLoadOrder({"b", "a"})
    print("load order set")
end

--@api-stub: LModManager:clearLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({id = "a", name = "A", version = "1.0", author = "X", description = "d", priority = 0}); local mod_b = lurek.mods.newMod({id = "b", name = "B", version = "1.0", author = "X", description = "d", priority = 10})
    mod_a:setEnabled(true); mod_b:setEnabled(true); mgr:registerMod(mod_a); mgr:registerMod(mod_b)
    mgr:setLoadOrder({"b", "a"}); mgr:clearLoadOrder()
    print("order cleared")
end

--@api-stub: LModManager:hasCircularDependencies
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "safe", name = "Safe", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true); mgr:registerMod(m)
    print("circular = " .. tostring(mgr:hasCircularDependencies()))
end

--@api-stub: LModManager:validateDependencies
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "safe", name = "Safe", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true); mgr:registerMod(m)
    local msgs = mgr:validateDependencies()
    print("validation messages = " .. #msgs)
end

--@api-stub: LModManager:markForReload
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    mod:setEnabled(true); mgr:registerMod(mod); mgr:markForReload("hot")
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:getReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    mod:setEnabled(true); mgr:registerMod(mod); mgr:markForReload("hot")
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:processReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    mod:setEnabled(true); mgr:registerMod(mod); mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
end

--@api-stub: LModManager:clearReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({id = "hot", name = "Hot", version = "1.0", author = "A", description = "d"})
    mod:setEnabled(true); mgr:registerMod(mod); mgr:markForReload("hot")
    mgr:clearReloadQueue()
    print("queued = " .. #mgr:getReloadQueue())
end

--@api-stub: LModManager:getModPath
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "pathed", name = "P", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true); mgr:registerMod(m)
    local path = mgr:getModPath("pathed")
    print("path = " .. tostring(path))
end

--@api-stub: LModManager:getModsByCapability
do
    local mgr = lurek.mods.newModManager()
    local m = lurek.mods.newMod({id = "render_mod", name = "R", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer"}); m:setEnabled(true); mgr:registerMod(m)
    local renderers = mgr:getModsByCapability("renderer")
    print("renderer mods = " .. #renderers)
end

--@api-stub: LModManager:scanFolder
do
    local mgr = lurek.mods.newModManager()
    local found = mgr:scanFolder("content/plugins")
    print("scanned mods = " .. #found)
end

--- Mods Module: LContentRegistry, LMod, LModManager


--@api-stub: LContentRegistry:getTypes
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    print("types = " .. #reg:getTypes())
end

--@api-stub: LContentRegistry:registerType
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    print("types = " .. #reg:getTypes())
end

--@api-stub: LContentRegistry:type
do
    local reg = lurek.mods.newRegistry()
    print(reg:type())
end

--@api-stub: LContentRegistry:typeOf
do
    local reg = lurek.mods.newRegistry()
    print(reg:typeOf("LContentRegistry"))
end

--@api-stub: LMod:getAuthor
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("author = " .. mod:getAuthor())
end

--@api-stub: LMod:getDescription
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("description = " .. mod:getDescription())
end

--@api-stub: LMod:getId
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("id = " .. mod:getId())
end

--@api-stub: LMod:getName
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("name = " .. mod:getName())
end

--@api-stub: LMod:getPriority
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("priority = " .. mod:getPriority())
end

--@api-stub: LMod:getVersion
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("version = " .. mod:getVersion())
end

--@api-stub: LMod:type
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("type = " .. mod:type())
end

--@api-stub: LMod:typeOf
do
    local mod = lurek.mods.newMod({id = "my_mod", name = "My Mod", version = "1.0", author = "Dev", description = "Test mod"})
    print("is LMod = " .. tostring(mod:typeOf("LMod")))
end

--@api-stub: LModManager:type
do
    local mgr = lurek.mods.newModManager()
    print(mgr:type())
end

--@api-stub: LModManager:typeOf
do
    local mgr = lurek.mods.newModManager()
    print(mgr:typeOf("LModManager"))
end

print("content/examples/mods.lua")
