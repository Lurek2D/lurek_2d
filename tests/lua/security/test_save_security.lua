-- test_save.lua
-- Canonical file. Merged from multiple sources.

-- Lurek2D Validation Test: SaveManager Edge Cases
-- Tests save/load with corrupted data, missing fields, and edge cases

local function new_manager()
    return lurek.save.newSaveManager()
end

-- @describe validation: savegame edge cases
describe("validation: savegame edge cases", function()
    -- @security lurek.save.newSaveManager
    it("creates save manager without crash", function()
        expect_no_error(function()
            local mgr = new_manager()
            expect_not_nil(mgr, "save manager created")
        end)
    end)

    -- @security LSaveManager:register
    it("register accepts valid collectors and rejects invalid ones", function()
        local mgr = new_manager()
        mgr:register("player", function() return {hp = 100} end, function(data) end)
        mgr:register("inventory", function() return {} end, function(data) end)
        expect_no_error(function()
            mgr:register("stats", function() return {mp = 50} end, function(data) end)
        end, "register accepts valid collector")

        ---@type any
        local bad_collector = "bad_collector"
        expect_error(function()
            mgr:register("broken", bad_collector, function(_) end)
        end, "register rejects non-function collector")
    end)

    -- @security LSaveManager:unregister
    it("unregister handles existing and missing collectors without crashing", function()
        local mgr = new_manager()
        mgr:register("player", function() return {hp = 100} end, function(data) end)
        expect_no_error(function()
            mgr:unregister("player")
        end, "unregister existing collector should not crash")

        expect_no_error(function()
            mgr:unregister("nonexistent")
        end, "unregister nonexistent should not crash")
    end)

    -- @security LSaveManager:setSchemaVersion
    it("setSchemaVersion updates the stored schema version", function()
        local mgr = new_manager()
        mgr:setSchemaVersion(5)
        expect_equal(5, mgr:getSchemaVersion(), "version set correctly")
    end)

    -- @security LSaveManager:getSchemaVersion
    it("getSchemaVersion returns the last configured schema version", function()
        local mgr = new_manager()
        mgr:setSchemaVersion(7)
        expect_equal(7, mgr:getSchemaVersion(), "getSchemaVersion returns updated value")
    end)

    -- @security LSaveManager:markDirty
    it("markDirty flips the manager into dirty state", function()
        local mgr = new_manager()
        mgr:markDirty()
        expect_true(mgr:isDirty(), "dirty after markDirty")
    end)

    -- @security LSaveManager:isDirty
    it("isDirty reflects clean and dirty states", function()
        local mgr = new_manager()
        expect_false(mgr:isDirty(), "initially not dirty")
        mgr:markDirty()
        expect_true(mgr:isDirty(), "dirty after mark")
    end)

    -- @security LSaveManager:enableAutoSave
    it("enableAutoSave configures an auto-save timer and rejects invalid parameters", function()
        local mgr = new_manager()
        mgr:enableAutoSave(30.0, "auto")
        local triggered = mgr:update(1.0)
        expect_false(triggered, "not ready after 1 second")
        expect_error(function()
            mgr:enableAutoSave(0, "auto")
        end)
        expect_error(function()
            mgr:enableAutoSave(-1, "auto")
        end)
        expect_error(function()
            mgr:enableAutoSave(0 / 0, "auto")
        end)
        expect_error(function()
            mgr:enableAutoSave(1, "../evil")
        end)
    end)

    -- @security LSaveManager:save
    it("save rejects invalid slot names before writing files", function()
        local mgr = new_manager()
        mgr:register("player", function() return { hp = 100 } end, function(_) end)
        expect_error(function()
            mgr:save("../evil")
        end)
        expect_false(mgr:exists("../evil"), "invalid slot should not be treated as persisted")
    end)

    -- @security LSaveManager:update
    it("update returns false before the auto-save interval elapses", function()
        local mgr = new_manager()
        mgr:enableAutoSave(30.0, "auto")
        local triggered = mgr:update(1.0)
        expect_false(triggered, "not ready after 1 second")
    end)

    -- @security LSaveManager:load
    it("load falls back to the backup slot when the primary payload is corrupt", function()
        local slot = "security_backup_" .. tostring(os.time()) .. "_" .. tostring(math.floor(os.clock() * 1000000))
        local mgr = new_manager()
        local hp = 10

        mgr:register("player", function()
            return { hp = hp }
        end, function(data)
            hp = data.hp
        end)

        mgr:save(slot)
        hp = 20
        mgr:save(slot)

        lurek.filesystem.write("save/slot_" .. slot .. ".sav", "return { broken = }")

        hp = 0
        local ok, err = mgr:load(slot)
        expect_true(ok, err or "backup recovery should succeed")
        expect_equal(10, hp, "backup payload restored the earlier save")

        mgr:delete(slot)
    end)

    -- @security LSaveManager:disableAutoSave
    it("disableAutoSave stops pending auto-save checks", function()
        local mgr = new_manager()
        mgr:enableAutoSave(30.0, "auto")
        mgr:disableAutoSave()
        local triggered = mgr:update(60.0)
        expect_false(triggered, "disabled autosave should not trigger")
    end)

    -- @security LSaveManager:setSummary
    it("setSummary stores a human-readable summary", function()
        local mgr = new_manager()
        mgr:setSummary("Test save game")
        expect_equal("Test save game", mgr:getSummary(), "summary preserved")
    end)

    -- @security LSaveManager:getSummary
    it("getSummary returns the configured summary text", function()
        local mgr = new_manager()
        mgr:setSummary("Checkpoint Alpha")
        expect_equal("Checkpoint Alpha", mgr:getSummary(), "summary text preserved")
    end)

    -- @security LSaveManager:reset
    it("reset clears dirty state and summary", function()
        local mgr = new_manager()
        mgr:register("test", function() return {} end, function(data) end)
        mgr:markDirty()
        mgr:setSummary("to be cleared")
        mgr:reset()
        expect_false(mgr:isDirty(), "not dirty after reset")
        expect_equal("", mgr:getSummary(), "summary cleared by reset")
    end)
end)

-- @describe validation: savegame migration
describe("validation: savegame migration", function()
    -- @security LSaveManager:addMigration
    it("addMigration accepts valid callbacks and rejects invalid ones", function()
        local mgr = new_manager()
        mgr:setSchemaVersion(3)
        mgr:addMigration(1, function(data) return data end)
        mgr:addMigration(2, function(data) return data end)
        expect_equal(3, mgr:getSchemaVersion(), "migrations keep configured schema version")
        ---@type any
        local bad_migration = "not_a_function"
        expect_error(function()
            mgr:addMigration(3, bad_migration)
        end)
    end)
end)
test_summary()
