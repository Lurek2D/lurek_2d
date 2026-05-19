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
--@api-stub: LSaveManager:collect
--@api-stub: LSaveManager:restore
-- Registering data sections and round-tripping state.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    local playerHP = 100
    local playerGold = 500
    local inventory = { "sword", "shield", "potion" }
    mgr:register("player", function()
        return { hp = playerHP, gold = playerGold }
    end, function(data)
        playerHP = data.hp
        playerGold = data.gold
    end)
    mgr:register("inventory", function()
        return inventory
    end, function(data)
        inventory = data
    end)
    local snapshot = mgr:collect()
    print("collected player hp = " .. snapshot.player.hp)
    print("collected gold = " .. snapshot.player.gold)
    print("collected items = " .. #snapshot.inventory)
    playerHP = 50
    playerGold = 200
    inventory = {}
    mgr:restore(snapshot)
    print("restored hp = " .. playerHP)
    print("restored gold = " .. playerGold)
    print("restored items = " .. #inventory)
end

--@api-stub: LSaveManager:save
--@api-stub: LSaveManager:load
--@api-stub: LSaveManager:exists
--@api-stub: LSaveManager:delete
-- Saving and loading from named slots.
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
    print("exists = " .. tostring(mgr:exists("test_slot")))
    score = 0
    local ok, err = mgr:load("test_slot")
    print("load ok = " .. tostring(ok))
    print("restored score = " .. score)
    local missing_ok, missing_err = mgr:load("nonexistent")
    print("missing load ok = " .. tostring(missing_ok))
    if missing_err then
        print("error = " .. missing_err)
    end
    mgr:delete("test_slot")
    print("after delete exists = " .. tostring(mgr:exists("test_slot")))
end

--@api-stub: LSaveManager:getSlots
--@api-stub: LSaveManager:getSlotInfo
-- Listing available save slots.
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
--@api-stub: LSaveManager:disableAutoSave
--@api-stub: LSaveManager:update
--@api-stub: LSaveManager:markDirty
--@api-stub: LSaveManager:isDirty
-- Auto-save system.
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
    mgr:delete("autosave")
end

--@api-stub: LSaveManager:setSchemaVersion
--@api-stub: LSaveManager:getSchemaVersion
--@api-stub: LSaveManager:addMigration
-- Schema versioning and migrations.
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
--@api-stub: LSaveManager:getSummary
-- Save slot summaries.
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
    mgr:setSummary("Chapter 4 — Mountain Pass")
    print("updated summary = " .. mgr:getSummary())
end

--@api-stub: LSaveManager:setCompress
--@api-stub: LSaveManager:isCompressed
-- Save compression settings.
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
--@api-stub: LSaveManager:onAfterLoad
-- Save/load lifecycle hooks.
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
--@api-stub: LSaveManager:reset
-- Cleaning up save manager state.
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
--@api-stub: LSaveManager:typeOf
-- Type introspection on LSaveManager.
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

print("content/examples/save.lua")
