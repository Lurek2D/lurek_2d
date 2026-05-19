-- content/examples/save.lua
-- Auto-generated from content/examples2/save_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/save.lua

--- Save Module: persistent game state management


--@api-stub: lurek.save.newSaveManager
-- Creating a save manager instance.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    print("type = " .. mgr:type())
    print("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager")))
end

--@api-stub: LSaveManager:register
-- Registering data sections and round-tripping state. Focus: register.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local playerHP = 100
    mgr:register("player", function()
        return { hp = playerHP }
    end, function(data)
        playerHP = data.hp
    end)
    local snapshot = mgr:collect()
    print("collected player hp = " .. snapshot.player.hp)
end

--@api-stub: LSaveManager:collect
-- Registering data sections and round-tripping state. Focus: collect.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local playerHP = 100
    mgr:register("player", function()
        return { hp = playerHP }
    end, function(data)
        playerHP = data.hp
    end)
    local snapshot = mgr:collect()
    print("collected player hp = " .. snapshot.player.hp)
end

--@api-stub: LSaveManager:restore
-- Registering data sections and round-tripping state. Focus: restore.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local playerHP = 100
    mgr:register("player", function()
        return { hp = playerHP }
    end, function(data)
        playerHP = data.hp
    end)
    local snapshot = mgr:collect()
    playerHP = 50
    mgr:restore(snapshot)
    print("restored hp = " .. playerHP)
end

--@api-stub: LSaveManager:save
-- Saving and loading from named slots. Focus: save.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function()
        return { value = score }
    end, function(data)
        score = data.value
    end)
    mgr:save("test_slot")
    print("saved to test_slot")
end

--@api-stub: LSaveManager:load
-- Saving and loading from named slots. Focus: load.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function()
        return { value = score }
    end, function(data)
        score = data.value
    end)
    mgr:save("test_slot")
    score = 0
    local ok = mgr:load("test_slot")
    print("load ok = " .. tostring(ok))
    print("restored score = " .. score)
    mgr:delete("test_slot")
end

--@api-stub: LSaveManager:exists
-- Saving and loading from named slots. Focus: exists.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function()
        return { value = score }
    end, function(data)
        score = data.value
    end)
    mgr:save("test_slot")
    print("exists = " .. tostring(mgr:exists("test_slot")))
    mgr:delete("test_slot")
end

--@api-stub: LSaveManager:delete
-- Saving and loading from named slots. Focus: delete.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function()
        return { value = score }
    end, function(data)
        score = data.value
    end)
    mgr:save("test_slot")
    mgr:delete("test_slot")
    print("after delete exists = " .. tostring(mgr:exists("test_slot")))
end

--@api-stub: LSaveManager:getSlots
-- Listing available save slots. Focus: getSlots.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function()
        return { level = 5 }
    end, function(data) end)
    mgr:setSummary("Level 5 - Forest")
    mgr:save("slot1")
    mgr:setSummary("Level 8 - Castle")
    mgr:save("slot2")
    local slots = mgr:getSlots()
    print("slot count = " .. #slots)
    for _, s in ipairs(slots) do
        print("  " .. s.slot .. " v" .. s.version .. " summary: " .. s.summary)
    end
    local info = mgr:getSlotInfo("slot1")
    if info then
        print("slot1 info: " .. info.slot .. " ts=" .. info.timestamp)
    end
    mgr:delete("slot1")
    mgr:delete("slot2")
end

--@api-stub: LSaveManager:getSlotInfo
-- Listing available save slots. Focus: getSlotInfo.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function()
        return { level = 5 }
    end, function(data) end)
    mgr:setSummary("Level 5 - Forest")
    mgr:save("slot1")
    mgr:setSummary("Level 8 - Castle")
    mgr:save("slot2")
    local slots = mgr:getSlots()
    print("slot count = " .. #slots)
    for _, s in ipairs(slots) do
        print("  " .. s.slot .. " v" .. s.version .. " summary: " .. s.summary)
    end
    local info = mgr:getSlotInfo("slot1")
    if info then
        print("slot1 info: " .. info.slot .. " ts=" .. info.timestamp)
    end
    mgr:delete("slot1")
    mgr:delete("slot2")
end

--@api-stub: LSaveManager:enableAutoSave
-- Auto-save system. Focus: enableAutoSave.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local counter = 0
    mgr:register("counter", function()
        return { value = counter }
    end, function(data)
        counter = data.value
    end)
    mgr:enableAutoSave(5.0, "autosave")
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
    counter = 42
    local triggered = mgr:update(6.0)
    print("auto-save triggered = " .. tostring(triggered))
    mgr:disableAutoSave()
    mgr:markDirty()
    triggered = mgr:update(10.0)
    print("after disable triggered = " .. tostring(triggered))
    if mgr:exists("autosave") then
        mgr:delete("autosave")
    end
end

--@api-stub: LSaveManager:disableAutoSave
-- Auto-save system. Focus: disableAutoSave.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local counter = 0
    mgr:register("counter", function()
        return { value = counter }
    end, function(data)
        counter = data.value
    end)
    mgr:enableAutoSave(5.0, "autosave")
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
    counter = 42
    local triggered = mgr:update(6.0)
    print("auto-save triggered = " .. tostring(triggered))
    mgr:disableAutoSave()
    mgr:markDirty()
    triggered = mgr:update(10.0)
    print("after disable triggered = " .. tostring(triggered))
    if mgr:exists("autosave") then
        mgr:delete("autosave")
    end
end

--@api-stub: LSaveManager:update
-- Auto-save system. Focus: update.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local counter = 0
    mgr:register("counter", function()
        return { value = counter }
    end, function(data)
        counter = data.value
    end)
    mgr:enableAutoSave(5.0, "autosave")
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
    counter = 42
    local triggered = mgr:update(6.0)
    print("auto-save triggered = " .. tostring(triggered))
    mgr:disableAutoSave()
    mgr:markDirty()
    triggered = mgr:update(10.0)
    print("after disable triggered = " .. tostring(triggered))
    if mgr:exists("autosave") then
        mgr:delete("autosave")
    end
end

--@api-stub: LSaveManager:markDirty
-- Auto-save system. Focus: markDirty.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local counter = 0
    mgr:register("counter", function()
        return { value = counter }
    end, function(data)
        counter = data.value
    end)
    mgr:enableAutoSave(5.0, "autosave")
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
    counter = 42
    local triggered = mgr:update(6.0)
    print("auto-save triggered = " .. tostring(triggered))
    mgr:disableAutoSave()
    mgr:markDirty()
    triggered = mgr:update(10.0)
    print("after disable triggered = " .. tostring(triggered))
    if mgr:exists("autosave") then
        mgr:delete("autosave")
    end
end

--@api-stub: LSaveManager:isDirty
-- Auto-save system. Focus: isDirty.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local counter = 0
    mgr:register("counter", function()
        return { value = counter }
    end, function(data)
        counter = data.value
    end)
    mgr:enableAutoSave(5.0, "autosave")
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
    counter = 42
    local triggered = mgr:update(6.0)
    print("auto-save triggered = " .. tostring(triggered))
    mgr:disableAutoSave()
    mgr:markDirty()
    triggered = mgr:update(10.0)
    print("after disable triggered = " .. tostring(triggered))
    if mgr:exists("autosave") then
        mgr:delete("autosave")
    end
end

--@api-stub: LSaveManager:setSchemaVersion
-- Schema versioning and migrations. Focus: setSchemaVersion.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    print("schema version = " .. mgr:getSchemaVersion())
    mgr:addMigration(1, function(data)
        if data.player then
            data.player.maxHp = data.player.maxHp or 100
        end
        return data
    end)
    mgr:addMigration(2, function(data)
        if data.player and not data.player.mana then
            data.player.mana = 50
        end
        return data
    end)
    print("migrations registered for v1→v2 and v2→v3")
end

--@api-stub: LSaveManager:getSchemaVersion
-- Schema versioning and migrations. Focus: getSchemaVersion.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    print("schema version = " .. mgr:getSchemaVersion())
    mgr:addMigration(1, function(data)
        if data.player then
            data.player.maxHp = data.player.maxHp or 100
        end
        return data
    end)
    mgr:addMigration(2, function(data)
        if data.player and not data.player.mana then
            data.player.mana = 50
        end
        return data
    end)
    print("migrations registered for v1→v2 and v2→v3")
end

--@api-stub: LSaveManager:addMigration
-- Schema versioning and migrations. Focus: addMigration.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    print("schema version = " .. mgr:getSchemaVersion())
    mgr:addMigration(1, function(data)
        if data.player then
            data.player.maxHp = data.player.maxHp or 100
        end
        return data
    end)
    mgr:addMigration(2, function(data)
        if data.player and not data.player.mana then
            data.player.mana = 50
        end
        return data
    end)
    print("migrations registered for v1→v2 and v2→v3")
end

--@api-stub: LSaveManager:setSummary
-- Save slot summaries. Focus: setSummary.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
    mgr:setSummary("Chapter 4 — Mountain Pass")
    print("updated summary = " .. mgr:getSummary())
end

--@api-stub: LSaveManager:getSummary
-- Save slot summaries. Focus: getSummary.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
    mgr:setSummary("Chapter 4 — Mountain Pass")
    print("updated summary = " .. mgr:getSummary())
end

--@api-stub: LSaveManager:setCompress
-- Save compression settings. Focus: setCompress.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    print("compressed = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(false)
    print("after disable = " .. tostring(mgr:isCompressed()))
end

--@api-stub: LSaveManager:isCompressed
-- Save compression settings. Focus: isCompressed.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    print("compressed = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(false)
    print("after disable = " .. tostring(mgr:isCompressed()))
end

--@api-stub: LSaveManager:onBeforeSave
-- Save/load lifecycle hooks. Focus: onBeforeSave.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local hookLog = {}
    mgr:register("state", function()
        return { x = 10, y = 20 }
    end, function(data)
        print("restored x=" .. data.x .. " y=" .. data.y)
    end)
    mgr:onBeforeSave(function(slot)
        table.insert(hookLog, "before:" .. slot)
    end)
    mgr:onAfterLoad(function(slot)
        table.insert(hookLog, "after:" .. slot)
    end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    print("hooks fired = " .. #hookLog)
    for _, h in ipairs(hookLog) do
        print("  " .. h)
    end
    mgr:onBeforeSave(nil)
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:onAfterLoad
-- Save/load lifecycle hooks. Focus: onAfterLoad.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local hookLog = {}
    mgr:register("state", function()
        return { x = 10, y = 20 }
    end, function(data)
        print("restored x=" .. data.x .. " y=" .. data.y)
    end)
    mgr:onBeforeSave(function(slot)
        table.insert(hookLog, "before:" .. slot)
    end)
    mgr:onAfterLoad(function(slot)
        table.insert(hookLog, "after:" .. slot)
    end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    print("hooks fired = " .. #hookLog)
    for _, h in ipairs(hookLog) do
        print("  " .. h)
    end
    mgr:onBeforeSave(nil)
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:unregister
-- Cleaning up save manager state. Focus: unregister.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(d) end)
    mgr:register("section_b", function() return {} end, function(d) end)
    mgr:unregister("section_a")
    print("unregistered section_a")
    mgr:reset()
    print("full reset complete")
end

--@api-stub: LSaveManager:reset
-- Cleaning up save manager state. Focus: reset.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(d) end)
    mgr:register("section_b", function() return {} end, function(d) end)
    mgr:unregister("section_a")
    print("unregistered section_a")
    mgr:reset()
    print("full reset complete")
end

--@api-stub: LSaveManager:type
-- Type introspection on LSaveManager. Focus: type.
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

--@api-stub: LSaveManager:typeOf
-- Type introspection on LSaveManager. Focus: typeOf.
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

print("content/examples/save.lua")
