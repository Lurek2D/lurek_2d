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
    hp = 50
    mgr:restore({ player = { hp = 100 } })
    print("restored hp = " .. hp)
end

--@api-stub: LSaveManager:save
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_save_slot"
    mgr:save(slot)
    print("saved to " .. slot)
    print("exists after save = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end

--@api-stub: LSaveManager:load
do
    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function() return { value = score } end, function(data) score = data.value end)
    local slot = "example_load_slot"
    mgr:save(slot)
    score = 0
    local ok, err = mgr:load(slot)
    print("load ok = " .. tostring(ok))
    print("load err = " .. tostring(err))
    print("score = " .. score)
    mgr:delete(slot)
end

--@api-stub: LSaveManager:exists
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_exists_slot"
    mgr:save(slot)
    print("exists = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end

--@api-stub: LSaveManager:delete
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_delete_slot"
    mgr:save(slot)
    mgr:delete(slot)
    print("after delete exists = " .. tostring(mgr:exists(slot)))
end

--@api-stub: LSaveManager:getSlots
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slots_slot"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local slots = mgr:getSlots()
    print("slot count = " .. #slots)
    print("first slot = " .. tostring(slots[1] and slots[1].slot))
    mgr:delete(slot)
end

--@api-stub: LSaveManager:getSlotInfo
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slot_info"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local info = mgr:getSlotInfo(slot)
    print("slot info = " .. tostring(info and info.slot))
    print("summary = " .. tostring(info and info.summary))
    mgr:delete(slot)
end

--@api-stub: LSaveManager:enableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_autosave_slot"
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0)))
    print("autosave exists = " .. tostring(mgr:exists("autosave")))
    mgr:delete("autosave")
end

--@api-stub: LSaveManager:disableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:disableAutoSave()
    mgr:markDirty()
    print("after disable triggered = " .. tostring(mgr:update(6.0)))
end

--@api-stub: LSaveManager:update
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_update_slot"
    mgr:enableAutoSave(5.0, slot)
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0)))
    print("slot exists = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
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
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    print("schema version = " .. mgr:getSchemaVersion())
end

--@api-stub: LSaveManager:getSchemaVersion
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    print("schema version = " .. mgr:getSchemaVersion())
end

--@api-stub: LSaveManager:addMigration
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    local collected = { __schema_version = 1, player = {} }
    mgr:register("player", function() return { level = 7 } end, function(_) end)
    mgr:restore(collected)
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
    mgr:save("hook_test")
    mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:onAfterLoad
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) print("after:" .. slot) end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end

--@api-stub: LSaveManager:unregister
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:unregister("section_a")
    local data = mgr:collect()
    print("has section_a = " .. tostring(data.section_a ~= nil))
    print("has section_b = " .. tostring(data.section_b ~= nil))
end

--@api-stub: LSaveManager:reset
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:setSummary("temporary summary")
    mgr:setCompress(true)
    mgr:reset()
    print("summary after reset = " .. tostring(mgr:getSummary()))
    print("compressed after reset = " .. tostring(mgr:isCompressed()))
end

--@api-stub: LSaveManager:type
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print("type = " .. sm:type())
end

--@api-stub: LSaveManager:typeOf
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print("is save manager = " .. tostring(sm:typeOf("LSaveManager")))
    print("is object = " .. tostring(sm:typeOf("LObject")))
end
