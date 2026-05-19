--- Mods Module: LContentRegistry, LMod, LModManager

--@api-stub: LContentRegistry:getTypes
--@api-stub: LContentRegistry:registerType
--@api-stub: LContentRegistry:type
--@api-stub: LContentRegistry:typeOf
-- Content registry: register, get, list types.
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
--@api-stub: LMod:getDescription
--@api-stub: LMod:getId
--@api-stub: LMod:getName
--@api-stub: LMod:getPriority
--@api-stub: LMod:getVersion
--@api-stub: LMod:type
--@api-stub: LMod:typeOf
-- Mod: metadata, hooks, config, enable/disable.
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
--@api-stub: LModManager:typeOf
-- Mod manager: registry, load order, reload, capability filtering.
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

print("mods_02.lua")
