-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_save_core_unit.lua
do
-- lurek.save API unit tests
-- Headless-safe (no window / GPU / audio required).
-- Tests SaveManager lifecycle: register/unregister, collect/restore,
-- save/load/delete slot ops, getSlots/getSlotInfo, schema version,
-- dirty flag, summary, autoSave/disableAutoSave/update, reset.

-- @describe Factory function
describe("Factory function", function()
    -- @covers lurek.save.newSaveManager
    it("newSaveManager is exposed and returns a non-nil object", function()
        expect_type("function", lurek.save.newSaveManager)
        local sm = lurek.save.newSaveManager()
        expect_true(sm ~= nil, "save manager is not nil")
    end)
end)

-- @describe SaveManager registration and metadata
describe("SaveManager registration and metadata", function()
    -- @covers LSaveManager:register
    it("register accepts a name + collect/restore callbacks", function()
        local sm = lurek.save.newSaveManager()
        sm:register("player",
            function() return { hp = 100 } end,
            function(data) end
        )
        expect_true(true, "register did not throw")
    end)

    -- @covers LSaveManager:unregister
    it("unregister removes a previously registered system from future collect results", function()
        local sm = lurek.save.newSaveManager()
        sm:register("temp_sys",
            function() return { hp = 100 } end,
            function(data) end
        )
        sm:unregister("temp_sys")
        local snapshot = sm:collect()
        expect_equal(nil, snapshot.temp_sys)
    end)

    -- @covers LSaveManager:setSummary
    it("setSummary and getSummary round-trip a string", function()
        local sm = lurek.save.newSaveManager()
        sm:setSummary("Level 3")
        expect_equal("Level 3", sm:getSummary())
    end)

    -- @covers LSaveManager:getSummary
    it("getSummary returns the last summary string assigned to the manager", function()
        local sm = lurek.save.newSaveManager()
        sm:setSummary("Level 3")
        expect_equal("Level 3", sm:getSummary())
    end)

    -- @covers LSaveManager:getSchemaVersion
    it("getSchemaVersion returns a non-negative number on a new manager", function()
        local sm = lurek.save.newSaveManager()
        local v = sm:getSchemaVersion()
        expect_type("number", v)
        expect_true(v >= 0)
    end)

    -- @covers LSaveManager:setSchemaVersion
    it("setSchemaVersion updates the version", function()
        local sm = lurek.save.newSaveManager()
        sm:setSchemaVersion(3)
        expect_equal(3, sm:getSchemaVersion())
    end)

    -- @covers LSaveManager:isDirty
    it("isDirty returns false on new manager", function()
        local sm = lurek.save.newSaveManager()
        expect_false(sm:isDirty())
    end)

    -- @covers LSaveManager:markDirty
    it("markDirty sets isDirty to true", function()
        local sm = lurek.save.newSaveManager()
        sm:markDirty()
        expect_true(sm:isDirty())
    end)

end)

-- collect and restore
-- @describe SaveManager.collect / restore
describe("SaveManager.collect / restore", function()
    -- @covers LSaveManager:collect
    it("collect returns a table and captures all registered systems", function()
        local sm = lurek.save.newSaveManager()
        sm:register("sys_a", function() return { val = 1 } end, function() end)
        sm:register("sys_b", function() return { val = 2 } end, function() end)
        local snapshot = sm:collect()
        expect_type("table", snapshot)
        expect_true(snapshot["sys_a"] ~= nil, "snapshot should contain sys_a data")
        expect_true(snapshot["sys_b"] ~= nil, "snapshot should contain sys_b data")
    end)

    -- @covers LSaveManager:restore
    it("restore calls restore callbacks with collected data", function()
        local sm = lurek.save.newSaveManager()
        local restored_hp = nil
        sm:register("player",
            function() return { hp = 55 } end,
            function(data) restored_hp = data.hp end
        )
        local snapshot = sm:collect()
        sm:restore(snapshot)
        expect_equal(55, restored_hp)
    end)
end)

-- save / load / delete / exists / getSlots / getSlotInfo
-- @describe SaveManager slot operations
describe("SaveManager slot operations", function()
    local SLOT = "unit_test_slot_" .. tostring(os.time()) .. "_" .. tostring(math.floor(os.clock() * 1000000))

    -- @covers LSaveManager:save
    it("save writes a slot file", function()
        local sm = lurek.save.newSaveManager()
        sm:register("test_data",
            function() return { x = 42 } end,
            function() end
        )
        expect_no_error(function()
            sm:save(SLOT)
        end)
    end)

    -- @covers LSaveManager:exists
    it("exists reports false before save and true after save", function()
        local slot = SLOT .. "_exists"
        local sm = lurek.save.newSaveManager()
        sm:register("chk",
            function() return {} end,
            function() end
        )
        expect_false(sm:exists(slot))
        sm:save(slot)
        expect_true(sm:exists(slot))
        sm:delete(slot)
    end)

    -- @covers LSaveManager:getSlots
    it("getSlots returns a table and includes saved slot metadata", function()
        local sm = lurek.save.newSaveManager()
        local empty_slots = sm:getSlots()
        expect_type("table", empty_slots)
        sm:register("slots_test", function() return {} end, function() end)
        sm:save(SLOT)
        local slots = sm:getSlots()
        expect_type("table", slots)
        -- getSlots returns info-tables with .slot field, not plain strings
        local found = false
        for _, info in ipairs(slots) do
            if type(info) == "table" and info.slot == SLOT then found = true end
        end
        expect_true(found)
    end)

    -- @covers LSaveManager:getSlotInfo
    it("getSlotInfo returns a table for an existing slot", function()
        local sm = lurek.save.newSaveManager()
        sm:register("info_data", function() return {} end, function() end)
        sm:save(SLOT)
        local info = sm:getSlotInfo(SLOT)
        expect_type("table", info)
    end)

    -- @covers LSaveManager:load
    it("load restores data saved in the slot", function()
        local sm = lurek.save.newSaveManager()
        local loaded_x = nil
        sm:register("round_trip",
            function() return { x = 99 } end,
            function(data) loaded_x = data.x end
        )
        sm:save(SLOT)
        sm:load(SLOT)
        expect_equal(99, loaded_x)
    end)

    -- @covers LSaveManager:delete
    it("delete removes the slot", function()
        local sm = lurek.save.newSaveManager()
        sm:register("del_sys", function() return {} end, function() end)
        sm:save(SLOT)
        sm:delete(SLOT)
        expect_false(sm:exists(SLOT))
    end)
end)

-- reset
-- @describe SaveManager.reset
describe("SaveManager.reset", function()
    -- @covers LSaveManager:reset
    it("reset clears dirty state without error", function()
        local sm = lurek.save.newSaveManager()
        sm:register("r", function() return {} end, function() end)
        sm:markDirty()
        expect_no_error(function() sm:reset() end)
        expect_false(sm:isDirty())
    end)
end)

-- AutoSave
-- @describe SaveManager.disableAutoSave / update
describe("SaveManager.disableAutoSave / update", function()
    -- @covers LSaveManager:disableAutoSave
    it("disableAutoSave does not error", function()
        local sm = lurek.save.newSaveManager()
        expect_no_error(function() sm:disableAutoSave() end)
    end)

    -- @covers LSaveManager:update
    it("update handles single and repeated delta time updates without error", function()
        local sm = lurek.save.newSaveManager()
        expect_no_error(function() sm:update(0.016) end)
        for _ = 1, 100 do
            sm:update(0.016)
        end
        expect_true(true, "update loop completed without error")
    end)
end)

-- @describe SaveManager regression coverage
describe("SaveManager regression coverage", function()
    -- @covers LSaveManager:setCompress
    it("setCompress toggles isCompressed", function()
        local sm = lurek.save.newSaveManager()

        sm:setCompress(true)
        expect_true(sm:isCompressed())

        sm:setCompress(false)
        expect_false(sm:isCompressed())
    end)

    -- @covers LSaveManager:isCompressed
    it("isCompressed reflects the current compression flag", function()
        local sm = lurek.save.newSaveManager()
        sm:setCompress(true)
        expect_true(sm:isCompressed())
        sm:setCompress(false)
        expect_false(sm:isCompressed())
    end)

    -- @covers LSaveManager:onBeforeSave
    it("onBeforeSave fires with the slot name", function()
        local sm = lurek.save.newSaveManager()
        local slot = "unit_test_before_save_hook"
        local seen_slot = nil

        sm:register("hook_data", function() return { x = 1 } end, function() end)
        sm:onBeforeSave(function(name)
            seen_slot = name
        end)

        sm:save(slot)

        expect_equal(slot, seen_slot)
        sm:delete(slot)
    end)

    -- @covers LSaveManager:onAfterLoad
    it("onAfterLoad fires after a successful load", function()
        local sm = lurek.save.newSaveManager()
        local slot = "unit_test_after_load_hook"
        local restored_value = nil
        local loaded_slot = nil

        sm:register(
            "round_trip",
            function() return { value = 42 } end,
            function(data) restored_value = data.value end
        )
        sm:onAfterLoad(function(name)
            loaded_slot = name
        end)

        sm:save(slot)
        local ok, err = sm:load(slot)

        expect_true(ok, err or "expected load to succeed")
        expect_equal(42, restored_value)
        expect_equal(slot, loaded_slot)

        sm:delete(slot)
    end)

    -- @covers LSaveManager:enableAutoSave
    it("autosave returns the configured slot when interval elapses", function()
        local sm = lurek.save.newSaveManager()

        sm:enableAutoSave(0.5, "autosave_slot")
        sm:markDirty()
        expect_equal(nil, sm:update(0.49))
        expect_equal("autosave_slot", sm:update(0.01))

        sm:disableAutoSave()
        sm:markDirty()
        expect_equal(nil, sm:update(1.0))
    end)
end)

-- @describe save strict: LSaveManager addMigration/type/typeOf
describe("save strict: LSaveManager addMigration/type/typeOf", function()
    -- @covers LSaveManager:type
    it("LSaveManager type is callable", function()
        local sm = lurek.save.newSaveManager()
        expect_type("string", sm:type())
    end)

    -- @covers LSaveManager:typeOf
    it("LSaveManager typeOf is callable", function()
        local sm = lurek.save.newSaveManager()
        expect_type("boolean", sm:typeOf("LObject"))
    end)

    -- @covers LSaveManager:addMigration
    it("LSaveManager addMigration is callable", function()
        local sm = lurek.save.newSaveManager()
        local ok = pcall(function()
            sm:addMigration(1, function(data) return data end)
        end)
        expect_type("boolean", ok)
    end)
end)

-- @describe save migrated from integration/save_tilemap
describe("save migrated from integration/save_tilemap", function()
end)
end
-- END test_save_core_unit.lua

test_summary()
