--- Mods Module Part 2: LModManager — registration, load order, scanning, reload

--@api-stub: lurek.mods.newModManager
-- Creates an empty mod manager.
do
    ---@type LModManager
    local mgr = lurek.mods.newModManager()
    print("mod count = " .. mgr:getModCount())
end

--@api-stub: LModManager:registerMod / hasMod / getModCount
-- Registers mods with the manager.
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

--@api-stub: LModManager:getLoadOrder / setLoadOrder / clearLoadOrder
-- Managing mod load order.
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

--@api-stub: LModManager:hasCircularDependencies / validateDependencies
-- Dependency validation.
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

--@api-stub: LModManager:markForReload / getReloadQueue / processReloadQueue / clearReloadQueue
-- Reload workflow.
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

print("mods_01.lua")
