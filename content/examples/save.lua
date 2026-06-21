-- content/examples/save.lua
-- Auto-generated from content/examples2/save_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/save.lua

--- Save Module: persistent game state management

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.save.newSaveManager
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("New Game")
    mgr:setSchemaVersion(1)
    example_print_log("type = " .. mgr:type())
    example_print_log("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager")))
    example_print_log("summary = " .. mgr:getSummary())
end

--@api: LSaveManager:register
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 75
    mgr:restore({ player = { hp = 120 } })
    example_print_log("collected player hp = " .. mgr:collect().player.hp)
    example_print_log("restored hp = " .. hp)
end

--@api: LSaveManager:collect
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    local data = mgr:collect()
    data.player.hp = data.player.hp + 25
    mgr:restore(data)
    example_print_log("collected player hp = " .. data.player.hp)
    example_print_log("restored player hp = " .. hp)
end

--@api: LSaveManager:restore
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 50
    mgr:restore({ player = { hp = 100 } })
    example_print_log("restored hp = " .. hp)
end

--@api: LSaveManager:save
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_save_slot"
    mgr:save(slot)
    example_print_log("saved to " .. slot)
    example_print_log("exists after save = " .. tostring(mgr:exists(slot)))
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
    example_print_log("load ok = " .. tostring(ok))
    example_print_log("load err = " .. tostring(err))
    example_print_log("score = " .. score)
    mgr:delete(slot)
end

--@api: LSaveManager:exists
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_exists_slot"
    mgr:save(slot)
    example_print_log("exists = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end

--@api: LSaveManager:delete
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_delete_slot"
    mgr:save(slot)
    mgr:delete(slot)
    example_print_log("after delete exists = " .. tostring(mgr:exists(slot)))
end

--@api: LSaveManager:getSlots
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slots_slot"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local slots = mgr:getSlots()
    example_print_log("slot count = " .. #slots)
    example_print_log("first slot = " .. tostring(slots[1] and slots[1].slot))
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
    example_print_log("slot info = " .. tostring(info and info.slot))
    example_print_log("summary = " .. tostring(info and info.summary))
    mgr:delete(slot)
end

--@api: LSaveManager:enableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_autosave_slot"
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    example_print_log("auto-save triggered = " .. tostring(mgr:update(6.0)))
    example_print_log("autosave exists = " .. tostring(mgr:exists("autosave")))
    pcall(function() mgr:delete("autosave") end)
end

--@api: LSaveManager:disableAutoSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:disableAutoSave()
    mgr:markDirty()
    example_print_log("after disable triggered = " .. tostring(mgr:update(6.0)))
end

--@api: LSaveManager:update
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_update_slot"
    mgr:enableAutoSave(5.0, slot)
    mgr:markDirty()
    example_print_log("auto-save triggered = " .. tostring(mgr:update(6.0)))
    example_print_log("slot exists = " .. tostring(mgr:exists(slot)))
    if mgr:exists(slot) then
        mgr:delete(slot)
    end
end

--@api: LSaveManager:markDirty
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    example_print_log("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    example_print_log("after markDirty = " .. tostring(mgr:isDirty()))
end

--@api: LSaveManager:isDirty
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    example_print_log("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    example_print_log("after markDirty = " .. tostring(mgr:isDirty()))
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
    example_print_log("schema version = " .. mgr:getSchemaVersion())
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
    example_print_log("schema version = " .. mgr:getSchemaVersion())
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
    example_print_log("schema version = " .. mgr:getSchemaVersion())
end

--@api: LSaveManager:setSummary
do
    local mgr = lurek.save.newSaveManager()
    example_print_log("summary before = " .. mgr:getSummary())
    mgr:setSummary("Chapter 3 — The Dark Forest")
    example_print_log("summary = " .. mgr:getSummary())
    mgr:setSchemaVersion(3)
    example_print_log("version = " .. mgr:getSchemaVersion())
end

--@api: LSaveManager:getSummary
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("progress", function() return { chapter = 3 } end, function(_) end)
    local data = mgr:collect()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    example_print_log("summary = " .. mgr:getSummary())
end

--@api: LSaveManager:setCompress
do
    local mgr = lurek.save.newSaveManager()
    example_print_log("before compress = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(true)
    example_print_log("after enable = " .. tostring(mgr:isCompressed()))
    mgr:setCompress(false)
    example_print_log("after disable = " .. tostring(mgr:isCompressed()))
end

--@api: LSaveManager:isCompressed
do
    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    mgr:setSummary("Compressed Save")
    example_print_log("after enable = " .. tostring(mgr:isCompressed()))
    example_print_log("summary = " .. mgr:getSummary())
    mgr:setCompress(false)
end

--@api: LSaveManager:onBeforeSave
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onBeforeSave(function(slot) example_print_log("before:" .. slot) end)
    mgr:save("hook_test")
    mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end

--@api: LSaveManager:onAfterLoad
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) example_print_log("after:" .. slot) end)
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
    example_print_log("has section_a = " .. tostring(data.section_a ~= nil))
    example_print_log("has section_b = " .. tostring(data.section_b ~= nil))
end

--@api: LSaveManager:reset
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:setSummary("temporary summary")
    mgr:setCompress(true)
    mgr:reset()
    example_print_log("summary after reset = " .. tostring(mgr:getSummary()))
    example_print_log("compressed after reset = " .. tostring(mgr:isCompressed()))
end

--@api: LSaveManager:type
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    sm:setSummary("Type Check")
    sm:register("state", function() return { ok = true } end, function(_) end)
    example_print_log("type = " .. sm:type())
    example_print_log("sections = " .. tostring(sm:collect().state.ok))
end

--@api: LSaveManager:typeOf
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    local is_save = sm:typeOf("LSaveManager")
    local is_object = sm:typeOf("LObject")
    local slots = sm:getSlots()
    example_print_log("is save manager = " .. tostring(is_save))
    example_print_log("save slots now = " .. tostring(#slots))
    example_print_log("is object = " .. tostring(is_object))
    example_print_log("type = " .. sm:type())
end
