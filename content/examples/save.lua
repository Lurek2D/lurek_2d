-- content/examples/save.lua
-- Auto-generated from content/examples2/save_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/save.lua

--- Save Module: persistent game state management

--@api: lurek.save.newManager
do

    ---@type LSaveManager
    local mgr = lurek.save.newManager()
    mgr:setSummary("Canonical Manager")
    local summary = mgr:getSummary()
    lurek.log.info(tostring("type = " .. mgr:type()))
    lurek.log.info(tostring("format = " .. mgr:getFormat()))
    lurek.log.info(tostring("summary = " .. summary))
end

--@api: LSaveManager:registerSchema
do
    local manager = lurek.save.newSaveManager()
    manager:registerSchema("ecs_loadout", 2, function(data) data.migrated = true return data end)
    local version = manager:getSchemaVersion()
    local format = manager:getFormat()
    lurek.log.info("registered schema version=" .. tostring(version) .. " format=" .. tostring(format))
end

--@api: LSaveManager:setFormat
do

    local mgr = lurek.save.newManager()
    mgr:setFormat("json")
    local format = mgr:getFormat()
    mgr:setSummary("JSON save")
    lurek.log.info(tostring("save format = " .. format))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end

--@api: LSaveManager:getFormat
do

    local mgr = lurek.save.newManager()
    local format = mgr:getFormat()
    mgr:setSummary("Default format")
    lurek.log.info(tostring("default save format = " .. format))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end


--@api: lurek.save.newSaveManager
do

    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("New Game")
    mgr:setSchemaVersion(1)
    lurek.log.info(tostring("type = " .. mgr:type()))
    lurek.log.info(tostring("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager"))))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end

--@api: LSaveManager:register
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 75
    mgr:restore({ player = { hp = 120 } })
    lurek.log.info(tostring("collected player hp = " .. mgr:collect().player.hp))
    lurek.log.info(tostring("restored hp = " .. hp))
end

--@api: LSaveManager:collect
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    local data = mgr:collect()
    data.player.hp = data.player.hp + 25
    mgr:restore(data)
    lurek.log.info(tostring("collected player hp = " .. data.player.hp))
    lurek.log.info(tostring("restored player hp = " .. hp))
end

--@api: LSaveManager:restore
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 50
    mgr:restore({ player = { hp = 100 } })
    lurek.log.info(tostring("restored hp = " .. hp))
end

--@api: LSaveManager:save
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_save_slot"
    mgr:save(slot)
    lurek.log.info(tostring("saved to " .. slot))
    lurek.log.info(tostring("exists after save = " .. tostring(mgr:exists(slot))))
    mgr:delete(slot)
end

--@api: LSaveManager:load
do

    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function() return { value = score } end, function(data) score = data.value end)
    local slot = "example_load_slot"
    mgr:save(slot)
    score = 0
    local ok, err = mgr:load(slot)
    lurek.log.info(tostring("load ok = " .. tostring(ok)))
    lurek.log.info(tostring("load err = " .. tostring(err)))
    lurek.log.info(tostring("score = " .. score))
    mgr:delete(slot)
end

--@api: LSaveManager:exists
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_exists_slot"
    mgr:save(slot)
    lurek.log.info(tostring("exists = " .. tostring(mgr:exists(slot))))
    mgr:delete(slot)
end

--@api: LSaveManager:delete
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_delete_slot"
    mgr:save(slot)
    mgr:delete(slot)
    lurek.log.info(tostring("after delete exists = " .. tostring(mgr:exists(slot))))
end

--@api: LSaveManager:getSlots
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slots_slot"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local slots = mgr:getSlots()
    lurek.log.info(tostring("slot count = " .. #slots))
    lurek.log.info(tostring("first slot = " .. tostring(slots[1] and slots[1].slot)))
    mgr:delete(slot)
end

--@api: LSaveManager:getSlotInfo
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slot_info"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local info = mgr:getSlotInfo(slot)
    lurek.log.info(tostring("slot info = " .. tostring(info and info.slot)))
    lurek.log.info(tostring("summary = " .. tostring(info and info.summary)))
    mgr:delete(slot)
end

--@api: LSaveManager:enableAutoSave
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_autosave_slot"
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    lurek.log.info(tostring("auto-save triggered = " .. tostring(mgr:update(6.0))))
    lurek.log.info(tostring("autosave exists = " .. tostring(mgr:exists("autosave"))))
    pcall(function() mgr:delete("autosave") end)
end

--@api: LSaveManager:disableAutoSave
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:disableAutoSave()
    mgr:markDirty()
    lurek.log.info(tostring("after disable triggered = " .. tostring(mgr:update(6.0))))
end

--@api: LSaveManager:update
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_update_slot"
    mgr:enableAutoSave(5.0, slot)
    mgr:markDirty()
    lurek.log.info(tostring("auto-save triggered = " .. tostring(mgr:update(6.0))))
    lurek.log.info(tostring("slot exists = " .. tostring(mgr:exists(slot))))
    if mgr:exists(slot) then
        mgr:delete(slot)
    end
end

--@api: LSaveManager:markDirty
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    lurek.log.info(tostring("dirty = " .. tostring(mgr:isDirty())))
    mgr:markDirty()
    lurek.log.info(tostring("after markDirty = " .. tostring(mgr:isDirty())))
end

--@api: LSaveManager:isDirty
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    lurek.log.info(tostring("dirty = " .. tostring(mgr:isDirty())))
    mgr:markDirty()
    lurek.log.info(tostring("after markDirty = " .. tostring(mgr:isDirty())))
end

--@api: LSaveManager:setSchemaVersion
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
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end

--@api: LSaveManager:getSchemaVersion
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
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end

--@api: LSaveManager:addMigration
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
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end

--@api: LSaveManager:setSummary
do

    local mgr = lurek.save.newSaveManager()
    lurek.log.info(tostring("summary before = " .. mgr:getSummary()))
    mgr:setSummary("Chapter 3 — The Dark Forest")
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
    mgr:setSchemaVersion(3)
    lurek.log.info(tostring("version = " .. mgr:getSchemaVersion()))
end

--@api: LSaveManager:getSummary
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("progress", function() return { chapter = 3 } end, function(_) end)
    local data = mgr:collect()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end

--@api: LSaveManager:setCompress
do

    local mgr = lurek.save.newSaveManager()
    lurek.log.info(tostring("before compress = " .. tostring(mgr:isCompressed())))
    mgr:setCompress(true)
    lurek.log.info(tostring("after enable = " .. tostring(mgr:isCompressed())))
    mgr:setCompress(false)
    lurek.log.info(tostring("after disable = " .. tostring(mgr:isCompressed())))
end

--@api: LSaveManager:isCompressed
do

    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    mgr:setSummary("Compressed Save")
    lurek.log.info(tostring("after enable = " .. tostring(mgr:isCompressed())))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
    mgr:setCompress(false)
end

--@api: LSaveManager:onBeforeSave
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onBeforeSave(function(slot) lurek.log.info(tostring("before:" .. slot)) end)
    mgr:save("hook_test")
    mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end

--@api: LSaveManager:onAfterLoad
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) lurek.log.info(tostring("after:" .. slot)) end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end

--@api: LSaveManager:unregister
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:unregister("section_a")
    local data = mgr:collect()
    lurek.log.info(tostring("has section_a = " .. tostring(data.section_a ~= nil)))
    lurek.log.info(tostring("has section_b = " .. tostring(data.section_b ~= nil)))
end

--@api: LSaveManager:reset
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:setSummary("temporary summary")
    mgr:setCompress(true)
    mgr:reset()
    lurek.log.info(tostring("summary after reset = " .. tostring(mgr:getSummary())))
    lurek.log.info(tostring("compressed after reset = " .. tostring(mgr:isCompressed())))
end

--@api: LSaveManager:type
do

    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    sm:setSummary("Type Check")
    sm:register("state", function() return { ok = true } end, function(_) end)
    lurek.log.info(tostring("type = " .. sm:type()))
    lurek.log.info(tostring("sections = " .. tostring(sm:collect().state.ok)))
end

--@api: LSaveManager:typeOf
do

    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    local is_save = sm:typeOf("LSaveManager")
    local is_object = sm:typeOf("LObject")
    local slots = sm:getSlots()
    lurek.log.info(tostring("is save manager = " .. tostring(is_save)))
    lurek.log.info(tostring("save slots now = " .. tostring(#slots)))
    lurek.log.info(tostring("is object = " .. tostring(is_object)))
    lurek.log.info(tostring("type = " .. sm:type()))
end
