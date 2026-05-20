-- content/examples/save.lua
-- Auto-generated from content/examples2/save_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/save.lua

--- Save Module: persistent game state management


--@api-stub: lurek.save.newSaveManager
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    print("type = " .. mgr:type())
    print("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager")))
end

--@api-stub: LSaveManager:register
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    print("collected player hp = " .. mgr:collect().player.hp)
end

--@api-stub: LSaveManager:collect
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    print("collected player hp = " .. mgr:collect().player.hp)
end

--@api-stub: LSaveManager:restore
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 50; mgr:restore({ player = { hp = 100 } })
    print("restored hp = " .. hp)
end

--@api-stub: LSaveManager:save
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    mgr:save("test_slot")
    print("saved to test_slot")
end

--@api-stub: LSaveManager:load
do
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function() return { value = score } end, function(data) score = data.value end)
    mgr:save("test_slot"); score = 0
    print("load ok = " .. tostring(mgr:load("test_slot")) .. " score = " .. score); mgr:delete("test_slot")
end

--@api-stub: LSaveManager:exists
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    mgr:save("test_slot")
    print("exists = " .. tostring(mgr:exists("test_slot")))
    mgr:delete("test_slot")
end

--@api-stub: LSaveManager:delete
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    mgr:save("test_slot")
    mgr:delete("test_slot")
    print("after delete exists = " .. tostring(mgr:exists("test_slot")))
end

--@api-stub: LSaveManager:getSlots
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    mgr:setSummary("Level 5 - Forest"); mgr:save("slot1")
    print("slot count = " .. #mgr:getSlots())
    mgr:delete("slot1")
end

--@api-stub: LSaveManager:getSlotInfo
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    mgr:setSummary("Level 5 - Forest"); mgr:save("slot1")
    print("slot1 info = " .. tostring((mgr:getSlotInfo("slot1") or {}).slot)); mgr:delete("slot1")
end

--@api-stub: LSaveManager:enableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0))); mgr:delete("autosave")
end

--@api-stub: LSaveManager:disableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave"); mgr:disableAutoSave(); mgr:markDirty()
    print("after disable triggered = " .. tostring(mgr:update(6.0)))
end

--@api-stub: LSaveManager:update
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0))); mgr:delete("autosave")
end

--@api-stub: LSaveManager:markDirty
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
end

--@api-stub: LSaveManager:isDirty
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
end

--@api-stub: LSaveManager:setSchemaVersion
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data) data.player = data.player or {}; data.player.maxHp = data.player.maxHp or 100; return data end)
    mgr:addMigration(2, function(data) data.player = data.player or {}; data.player.mana = data.player.mana or 50; return data end)
    print("schema version = " .. mgr:getSchemaVersion())
end

--@api-stub: LSaveManager:getSchemaVersion
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data) data.player = data.player or {}; data.player.maxHp = data.player.maxHp or 100; return data end)
    mgr:addMigration(2, function(data) data.player = data.player or {}; data.player.mana = data.player.mana or 50; return data end)
    print("schema version = " .. mgr:getSchemaVersion())
end

--@api-stub: LSaveManager:addMigration
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data) data.player = data.player or {}; data.player.maxHp = data.player.maxHp or 100; return data end)
    mgr:addMigration(2, function(data) data.player = data.player or {}; data.player.mana = data.player.mana or 50; return data end)
    print("schema version = " .. mgr:getSchemaVersion())
end

--@api-stub: LSaveManager:setSummary
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
end

--@api-stub: LSaveManager:getSummary
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
end

--@api-stub: LSaveManager:setCompress
do
    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
end

--@api-stub: LSaveManager:isCompressed
do
    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
end

--@api-stub: LSaveManager:onBeforeSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onBeforeSave(function(slot) print("before:" .. slot) end)
    mgr:save("hook_test"); mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:onAfterLoad
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) print("after:" .. slot) end)
    mgr:save("hook_test"); mgr:load("hook_test"); mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:unregister
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:unregister("section_a")
    print("unregistered section_a")
end

--@api-stub: LSaveManager:reset
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:reset()
    print("full reset complete")
end

--@api-stub: LSaveManager:type
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

--@api-stub: LSaveManager:typeOf
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

print("content/examples/save.lua")
