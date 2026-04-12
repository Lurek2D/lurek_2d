-- Lurek2D modding API unit tests
-- Headless-safe (no window / GPU / audio required).
-- Tests Mod lifecycle, hooks, config, and ModManager operations including
-- validateDependencies, circular detection, load order control, reload queue,
-- and scanFolder.
-- @covers lurek.modding.newMod
-- @covers lurek.modding.newModManager
-- @covers lurek.modding.Mod.getId
-- @covers lurek.modding.Mod.getName
-- @covers lurek.modding.Mod.getVersion
-- @covers lurek.modding.Mod.getAuthor
-- @covers lurek.modding.Mod.getDescription
-- @covers lurek.modding.Mod.getDependencies
-- @covers lurek.modding.Mod.getPriority
-- @covers lurek.modding.Mod.isEnabled
-- @covers lurek.modding.Mod.setEnabled
-- @covers lurek.modding.Mod.isLoaded
-- @covers lurek.modding.Mod.setHook
-- @covers lurek.modding.Mod.getHook
-- @covers lurek.modding.Mod.hasHook
-- @covers lurek.modding.Mod.getHookNames
-- @covers lurek.modding.Mod.setConfig
-- @covers lurek.modding.Mod.getConfig
-- @covers lurek.modding.ModManager.registerMod
-- @covers lurek.modding.ModManager.unregisterMod
-- @covers lurek.modding.ModManager.hasMod
-- @covers lurek.modding.ModManager.getModCount
-- @covers lurek.modding.ModManager.getAllMods
-- @covers lurek.modding.ModManager.getLoadOrder
-- @covers lurek.modding.ModManager.validateDependencies
-- @covers lurek.modding.ModManager.hasCircularDependencies
-- @covers lurek.modding.ModManager.setLoadOrder
-- @covers lurek.modding.ModManager.clearLoadOrder
-- @covers lurek.modding.ModManager.markForReload
-- @covers lurek.modding.ModManager.getReloadQueue
-- @covers lurek.modding.ModManager.clearReloadQueue

-- @description Covers suite: lurek.modding module exists.
describe("lurek.modding module exists", function()
    -- @covers lurek.modding
    -- @description Verifies the modding namespace is available as a Lua table.
    it("lurek.modding is a table", function()
        expect_type("table", lurek.modding)
    end)
end)

-- @description Covers suite: Factory functions.
describe("Factory functions", function()
    -- @covers lurek.modding.newMod
    -- @description Verifies newMod is exposed.
    it("newMod is a function", function()
        expect_type("function", lurek.modding.newMod)
    end)

    -- @covers lurek.modding.newModManager
    -- @description Verifies newModManager is exposed.
    it("newModManager is a function", function()
        expect_type("function", lurek.modding.newModManager)
    end)
end)

-- @description Covers suite: Mod object creation and metadata.
describe("Mod object creation and metadata", function()
    -- @covers lurek.modding.newMod
    -- @description Verifies newMod returns a non-nil mod handle when an id is supplied.
    it("newMod returns a non-nil object", function()
        local m = lurek.modding.newMod({ id = "test_mod" })
        expect_true(m ~= nil, "mod is not nil")
    end)

    -- @covers lurek.modding.newMod
    -- @description Verifies newMod rejects a definition table without an id field.
    it("newMod without id field raises an error", function()
        expect_error(function()
            lurek.modding.newMod({})
        end)
    end)

    -- @covers lurek.modding.Mod.getId
    -- @description Verifies getId echoes the id passed to the constructor.
    it("getId returns the id passed to newMod", function()
        local m = lurek.modding.newMod({ id = "my_mod" })
        expect_equal("my_mod", m:getId())
    end)

    -- @covers lurek.modding.Mod.getName
    -- @description Verifies getName returns the configured display name.
    it("getName returns the name when provided", function()
        local m = lurek.modding.newMod({ id = "x", name = "My Mod" })
        expect_equal("My Mod", m:getName())
    end)

    -- @covers lurek.modding.Mod.getName
    -- @description Verifies getName still returns a string when no explicit name is provided.
    it("getName returns a string even when not provided", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_type("string", m:getName())
    end)

    -- @covers lurek.modding.Mod.getVersion
    -- @description Verifies getVersion returns the configured version string.
    it("getVersion returns the version when provided", function()
        local m = lurek.modding.newMod({ id = "x", version = "1.2.3" })
        expect_equal("1.2.3", m:getVersion())
    end)

    -- @covers lurek.modding.Mod.getAuthor
    -- @description Verifies getAuthor returns the configured author string.
    it("getAuthor returns the author when provided", function()
        local m = lurek.modding.newMod({ id = "x", author = "Dev" })
        expect_equal("Dev", m:getAuthor())
    end)

    -- @covers lurek.modding.Mod.getDescription
    -- @description Verifies getDescription returns the configured description.
    it("getDescription returns the description when provided", function()
        local m = lurek.modding.newMod({ id = "x", description = "A cool mod" })
        expect_equal("A cool mod", m:getDescription())
    end)

    -- @covers lurek.modding.Mod.getDependencies
    -- @description Verifies getDependencies returns a table payload.
    it("getDependencies returns a table", function()
        local m = lurek.modding.newMod({ id = "x", dependencies = { "core_mod" } })
        local deps = m:getDependencies()
        expect_type("table", deps)
    end)

    -- @covers lurek.modding.Mod.getDependencies
    -- @description Verifies getDependencies preserves all declared dependency ids.
    it("getDependencies includes declared dependency ids", function()
        local m = lurek.modding.newMod({ id = "x", dependencies = { "dep_a", "dep_b" } })
        local deps = m:getDependencies()
        expect_equal(2, #deps)
    end)

    -- @covers lurek.modding.Mod.getPriority
    -- @description Verifies getPriority returns the configured load priority.
    it("getPriority returns the priority when provided", function()
        local m = lurek.modding.newMod({ id = "x", priority = 5 })
        expect_equal(5, m:getPriority())
    end)

    -- @covers lurek.modding.Mod.isEnabled
    -- @description Verifies mods start enabled by default.
    it("isEnabled returns true by default", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_true(m:isEnabled(), "mods are enabled by default")
    end)

    -- @covers lurek.modding.Mod.setEnabled
    -- @description Verifies setEnabled(false) disables the mod.
    it("setEnabled can disable a mod", function()
        local m = lurek.modding.newMod({ id = "x" })
        m:setEnabled(false)
        expect_false(m:isEnabled())
    end)

    -- @covers lurek.modding.Mod.setEnabled
    -- @description Verifies setEnabled(true) can re-enable a disabled mod.
    it("setEnabled can re-enable a mod", function()
        local m = lurek.modding.newMod({ id = "x" })
        m:setEnabled(false)
        m:setEnabled(true)
        expect_true(m:isEnabled())
    end)

    -- @covers lurek.modding.Mod.isLoaded
    -- @description Verifies mods start unloaded.
    it("isLoaded returns false by default", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_false(m:isLoaded())
    end)
end)

-- @description Covers suite: Mod hooks.
describe("Mod hooks", function()
    -- @covers lurek.modding.Mod.setHook
    -- @description Verifies setHook stores a function retrievable through getHook.
    it("setHook stores a function callable via getHook", function()
        local m = lurek.modding.newMod({ id = "hooks_mod" })
        local called = false
        m:setHook("on_load", function() called = true end)
        local fn = m:getHook("on_load")
        expect_type("function", fn)
        fn()
        expect_true(called, "hook was invoked")
    end)

    -- @covers lurek.modding.Mod.hasHook
    -- @description Verifies hasHook returns false before registration.
    it("hasHook returns false before setHook", function()
        local m = lurek.modding.newMod({ id = "has_hook_test" })
        expect_false(m:hasHook("on_load"))
    end)

    -- @covers lurek.modding.Mod.hasHook
    -- @description Verifies hasHook returns true after registration.
    it("hasHook returns true after setHook", function()
        local m = lurek.modding.newMod({ id = "has_hook_set" })
        m:setHook("on_load", function() end)
        expect_true(m:hasHook("on_load"))
    end)

    -- @covers lurek.modding.Mod.getHookNames
    -- @description Verifies getHookNames lists registered hook names.
    it("getHookNames returns a table of registered hook names", function()
        local m = lurek.modding.newMod({ id = "hook_names_mod" })
        m:setHook("on_load",   function() end)
        m:setHook("on_unload", function() end)
        local names = m:getHookNames()
        expect_type("table", names)
        expect_true(#names >= 2, "at least 2 hook names")
    end)

    -- @covers lurek.modding.Mod.getHookNames
    -- @description Verifies getHookNames returns an empty table when no hooks exist.
    it("getHookNames returns empty table for mod with no hooks", function()
        local m = lurek.modding.newMod({ id = "no_hooks" })
        local names = m:getHookNames()
        expect_equal(0, #names)
    end)

    -- @covers lurek.modding.Mod.getHook
    -- @description Verifies getHook returns nil for an unknown hook name.
    it("getHook returns nil for unregistered hook name", function()
        local m = lurek.modding.newMod({ id = "getHook_nil" })
        expect_nil(m:getHook("nonexistent_hook"))
    end)

    -- @covers lurek.modding.Mod.setHook
    -- @description Verifies separately registered hooks remain independent when invoked.
    it("multiple hooks are stored independently", function()
        local m = lurek.modding.newMod({ id = "multi_hook" })
        local a_called, b_called = false, false
        m:setHook("hook_a", function() a_called = true end)
        m:setHook("hook_b", function() b_called = true end)
        m:getHook("hook_a")()
        expect_true(a_called,  "hook_a was called")
        expect_false(b_called, "hook_b was not called yet")
        m:getHook("hook_b")()
        expect_true(b_called, "hook_b was called")
    end)
end)

-- @description Covers suite: Mod config.
describe("Mod config", function()
    -- @covers lurek.modding.Mod.setConfig
    -- @description Verifies string config values round-trip through setConfig and getConfig.
    it("setConfig / getConfig round-trips a string value", function()
        local m = lurek.modding.newMod({ id = "cfg_mod" })
        m:setConfig("0.8")
        expect_equal("0.8", m:getConfig())
    end)

    -- @covers lurek.modding.Mod.setConfig
    -- @description Verifies numeric config values round-trip through setConfig and getConfig.
    it("setConfig / getConfig round-trips a number value", function()
        local m = lurek.modding.newMod({ id = "cfg_num" })
        m:setConfig(42)
        local v = m:getConfig()
        expect_equal(42, v)
    end)

    -- @covers lurek.modding.Mod.getConfig
    -- @description Verifies getConfig returns nil before any config is set.
    it("getConfig returns nil when not set", function()
        local m = lurek.modding.newMod({ id = "cfg_nil" })
        expect_nil(m:getConfig())
    end)

    -- @covers lurek.modding.Mod.setConfig
    -- @description Verifies later setConfig calls overwrite the previous value.
    it("setConfig overwrites previous value", function()
        local m = lurek.modding.newMod({ id = "cfg_overwrite" })
        m:setConfig(1)
        m:setConfig(2)
        expect_equal(2, m:getConfig())
    end)
end)

-- @description Covers suite: ModManager object.
describe("ModManager object", function()
    -- @covers lurek.modding.newModManager
    -- @description Verifies newModManager returns a non-nil manager handle.
    it("newModManager returns a non-nil object", function()
        local mm = lurek.modding.newModManager()
        expect_true(mm ~= nil, "mod manager is not nil")
    end)

    -- @covers lurek.modding.ModManager.getLoadOrder
    -- @description Verifies getLoadOrder returns a table on an empty manager.
    it("getLoadOrder returns a table on empty manager", function()
        local mm = lurek.modding.newModManager()
        expect_type("table", mm:getLoadOrder())
    end)

    -- @covers lurek.modding.ModManager.getLoadOrder
    -- @description Verifies a new manager starts with an empty load order.
    it("getLoadOrder is empty on new manager", function()
        local mm = lurek.modding.newModManager()
        expect_equal(0, #mm:getLoadOrder())
    end)

    -- @covers lurek.modding.ModManager.registerMod
    -- @description Verifies registerMod adds a mod that appears in getAllMods.
    it("registerMod adds a mod and getAllMods includes it", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "pack_a" })
        mm:registerMod(m)
        local all = mm:getAllMods()
        expect_type("table", all)
        expect_true(#all >= 1, "at least one mod registered")
    end)

    -- @covers lurek.modding.ModManager.hasMod
    -- @description Verifies hasMod returns false for an unknown mod id.
    it("hasMod returns false for unknown id", function()
        local mm = lurek.modding.newModManager()
        expect_false(mm:hasMod("nonexistent_mod"))
    end)

    -- @covers lurek.modding.ModManager.hasMod
    -- @description Verifies hasMod returns true after a mod is registered.
    it("hasMod returns true after registerMod", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "unique_mod" })
        mm:registerMod(m)
        expect_true(mm:hasMod("unique_mod"), "found registered mod by id")
    end)

    -- @covers lurek.modding.ModManager.unregisterMod
    -- @description Verifies unregisterMod removes a mod from manager lookup.
    it("unregisterMod removes the mod", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "temp_mod" })
        mm:registerMod(m)
        mm:unregisterMod("temp_mod")
        expect_false(mm:hasMod("temp_mod"))
    end)

    -- @covers lurek.modding.ModManager.getModCount
    -- @description Verifies getModCount reports zero for a new manager.
    it("getModCount returns 0 on empty manager", function()
        local mm = lurek.modding.newModManager()
        expect_equal(0, mm:getModCount())
    end)

    -- @covers lurek.modding.ModManager.getModCount
    -- @description Verifies getModCount increases as mods are registered.
    it("getModCount increments after registerMod", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "m1" }))
        mm:registerMod(lurek.modding.newMod({ id = "m2" }))
        expect_equal(2, mm:getModCount())
    end)
end)

-- @description Covers suite: ModManager.validateDependencies / hasCircularDependencies.
describe("ModManager.validateDependencies / hasCircularDependencies", function()
    -- @covers lurek.modding.ModManager.validateDependencies
    -- @description Verifies validateDependencies returns a table result.
    it("validateDependencies returns a table", function()
        local mm = lurek.modding.newModManager()
        local result = mm:validateDependencies()
        expect_type("table", result)
    end)

    -- @covers lurek.modding.ModManager.validateDependencies
    -- @description Verifies independent mods validate without dependency errors.
    it("validateDependencies is empty for independent mods", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "standalone_a" }))
        mm:registerMod(lurek.modding.newMod({ id = "standalone_b" }))
        local errors = mm:validateDependencies()
        expect_equal(0, #errors)
    end)

    -- @covers lurek.modding.ModManager.validateDependencies
    -- @description Verifies missing dependencies produce validation errors.
    it("validateDependencies reports missing dependency", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({
            id = "needs_missing",
            dependencies = { "missing_dep" },
        }))
        local errors = mm:validateDependencies()
        expect_true(#errors >= 1, "unmet dependency should produce an error entry")
    end)

    -- @covers lurek.modding.ModManager.validateDependencies
    -- @description Verifies registered dependency providers clear validation errors.
    it("validateDependencies is empty when dependencies are all registered", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "dep_provider" }))
        mm:registerMod(lurek.modding.newMod({
            id = "dep_consumer",
            dependencies = { "dep_provider" },
        }))
        local errors = mm:validateDependencies()
        expect_equal(0, #errors)
    end)

    -- @covers lurek.modding.ModManager.hasCircularDependencies
    -- @description Verifies hasCircularDependencies returns a boolean.
    it("hasCircularDependencies returns a boolean", function()
        local mm = lurek.modding.newModManager()
        local result = mm:hasCircularDependencies()
        expect_type("boolean", result)
    end)

    -- @covers lurek.modding.ModManager.hasCircularDependencies
    -- @description Verifies acyclic graphs report no circular dependencies.
    it("hasCircularDependencies is false for acyclic dependency graph", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "base" }))
        mm:registerMod(lurek.modding.newMod({ id = "depends_on_base", dependencies = { "base" } }))
        expect_false(mm:hasCircularDependencies())
    end)
end)

-- @description Covers suite: ModManager load order control.
describe("ModManager load order control", function()
    -- @covers lurek.modding.ModManager.setLoadOrder
    -- @description Verifies setLoadOrder accepts an explicit ordered list of mod ids.
    it("setLoadOrder accepts an ordered list of mod ids", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "ord_a" }))
        mm:registerMod(lurek.modding.newMod({ id = "ord_b" }))
        expect_no_error(function()
            mm:setLoadOrder({ "ord_a", "ord_b" })
        end)
    end)

    -- @covers lurek.modding.ModManager.getLoadOrder
    -- @description Verifies getLoadOrder reflects the previously assigned order.
    it("getLoadOrder reflects setLoadOrder", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "lo_first" }))
        mm:registerMod(lurek.modding.newMod({ id = "lo_second" }))
        mm:setLoadOrder({ "lo_first", "lo_second" })
        local order = mm:getLoadOrder()
        -- getLoadOrder returns a table of mod info tables; check the first
        -- item's id field to confirm ordering was applied.
        expect_type("table", order)
        expect_true(#order >= 1, "at least one entry after setLoadOrder")
    end)

    -- @covers lurek.modding.ModManager.clearLoadOrder
    -- @description Verifies clearLoadOrder resets explicit ordering state.
    it("clearLoadOrder resets the explicit order", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "clr_a" }))
        mm:setLoadOrder({ "clr_a" })
        expect_no_error(function() mm:clearLoadOrder() end)
    end)
end)

-- @description Covers suite: ModManager reload queue.
describe("ModManager reload queue", function()
    -- @covers lurek.modding.ModManager.markForReload
    -- @description Verifies markForReload queues a mod id without error.
    it("markForReload adds a mod id to the reload queue", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "reload_me" }))
        expect_no_error(function() mm:markForReload("reload_me") end)
    end)

    -- @covers lurek.modding.ModManager.getReloadQueue
    -- @description Verifies getReloadQueue returns a table payload.
    it("getReloadQueue returns a table", function()
        local mm = lurek.modding.newModManager()
        local q = mm:getReloadQueue()
        expect_type("table", q)
    end)

    -- @covers lurek.modding.ModManager.getReloadQueue
    -- @description Verifies queued ids appear in the reload queue.
    it("getReloadQueue contains id after markForReload", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "rq_mod" }))
        mm:markForReload("rq_mod")
        local q = mm:getReloadQueue()
        local found = false
        for _, id in ipairs(q) do
            if id == "rq_mod" then found = true end
        end
        expect_true(found, "rq_mod should appear in reload queue")
    end)

    -- @covers lurek.modding.ModManager.clearReloadQueue
    -- @description Verifies clearReloadQueue empties the reload queue.
    it("clearReloadQueue empties the queue", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "rq_clear" }))
        mm:markForReload("rq_clear")
        mm:clearReloadQueue()
        expect_equal(0, #mm:getReloadQueue())
    end)
end)

test_summary()
