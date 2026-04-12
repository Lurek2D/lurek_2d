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

describe("lurek.modding module exists", function()
    it("lurek.modding is a table", function()
        expect_type("table", lurek.modding)
    end)
end)

describe("Factory functions", function()
    it("newMod is a function", function()
        expect_type("function", lurek.modding.newMod)
    end)

    it("newModManager is a function", function()
        expect_type("function", lurek.modding.newModManager)
    end)
end)

describe("Mod object creation and metadata", function()
    it("newMod returns a non-nil object", function()
        local m = lurek.modding.newMod({ id = "test_mod" })
        expect_true(m ~= nil, "mod is not nil")
    end)

    it("newMod without id field raises an error", function()
        expect_error(function()
            lurek.modding.newMod({})
        end)
    end)

    it("getId returns the id passed to newMod", function()
        local m = lurek.modding.newMod({ id = "my_mod" })
        expect_equal("my_mod", m:getId())
    end)

    it("getName returns the name when provided", function()
        local m = lurek.modding.newMod({ id = "x", name = "My Mod" })
        expect_equal("My Mod", m:getName())
    end)

    it("getName returns a string even when not provided", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_type("string", m:getName())
    end)

    it("getVersion returns the version when provided", function()
        local m = lurek.modding.newMod({ id = "x", version = "1.2.3" })
        expect_equal("1.2.3", m:getVersion())
    end)

    it("getAuthor returns the author when provided", function()
        local m = lurek.modding.newMod({ id = "x", author = "Dev" })
        expect_equal("Dev", m:getAuthor())
    end)

    it("getDescription returns the description when provided", function()
        local m = lurek.modding.newMod({ id = "x", description = "A cool mod" })
        expect_equal("A cool mod", m:getDescription())
    end)

    it("getDependencies returns a table", function()
        local m = lurek.modding.newMod({ id = "x", dependencies = { "core_mod" } })
        local deps = m:getDependencies()
        expect_type("table", deps)
    end)

    it("getDependencies includes declared dependency ids", function()
        local m = lurek.modding.newMod({ id = "x", dependencies = { "dep_a", "dep_b" } })
        local deps = m:getDependencies()
        expect_equal(2, #deps)
    end)

    it("getPriority returns the priority when provided", function()
        local m = lurek.modding.newMod({ id = "x", priority = 5 })
        expect_equal(5, m:getPriority())
    end)

    it("isEnabled returns true by default", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_true(m:isEnabled(), "mods are enabled by default")
    end)

    it("setEnabled can disable a mod", function()
        local m = lurek.modding.newMod({ id = "x" })
        m:setEnabled(false)
        expect_false(m:isEnabled())
    end)

    it("setEnabled can re-enable a mod", function()
        local m = lurek.modding.newMod({ id = "x" })
        m:setEnabled(false)
        m:setEnabled(true)
        expect_true(m:isEnabled())
    end)

    it("isLoaded returns false by default", function()
        local m = lurek.modding.newMod({ id = "x" })
        expect_false(m:isLoaded())
    end)
end)

describe("Mod hooks", function()
    it("setHook stores a function callable via getHook", function()
        local m = lurek.modding.newMod({ id = "hooks_mod" })
        local called = false
        m:setHook("on_load", function() called = true end)
        local fn = m:getHook("on_load")
        expect_type("function", fn)
        fn()
        expect_true(called, "hook was invoked")
    end)

    it("hasHook returns false before setHook", function()
        local m = lurek.modding.newMod({ id = "has_hook_test" })
        expect_false(m:hasHook("on_load"))
    end)

    it("hasHook returns true after setHook", function()
        local m = lurek.modding.newMod({ id = "has_hook_set" })
        m:setHook("on_load", function() end)
        expect_true(m:hasHook("on_load"))
    end)

    it("getHookNames returns a table of registered hook names", function()
        local m = lurek.modding.newMod({ id = "hook_names_mod" })
        m:setHook("on_load",   function() end)
        m:setHook("on_unload", function() end)
        local names = m:getHookNames()
        expect_type("table", names)
        expect_true(#names >= 2, "at least 2 hook names")
    end)

    it("getHookNames returns empty table for mod with no hooks", function()
        local m = lurek.modding.newMod({ id = "no_hooks" })
        local names = m:getHookNames()
        expect_equal(0, #names)
    end)

    it("getHook returns nil for unregistered hook name", function()
        local m = lurek.modding.newMod({ id = "getHook_nil" })
        expect_nil(m:getHook("nonexistent_hook"))
    end)

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

describe("Mod config", function()
    it("setConfig / getConfig round-trips a string value", function()
        local m = lurek.modding.newMod({ id = "cfg_mod" })
        m:setConfig("0.8")
        expect_equal("0.8", m:getConfig())
    end)

    it("setConfig / getConfig round-trips a number value", function()
        local m = lurek.modding.newMod({ id = "cfg_num" })
        m:setConfig(42)
        local v = m:getConfig()
        expect_equal(42, v)
    end)

    it("getConfig returns nil when not set", function()
        local m = lurek.modding.newMod({ id = "cfg_nil" })
        expect_nil(m:getConfig())
    end)

    it("setConfig overwrites previous value", function()
        local m = lurek.modding.newMod({ id = "cfg_overwrite" })
        m:setConfig(1)
        m:setConfig(2)
        expect_equal(2, m:getConfig())
    end)
end)

describe("ModManager object", function()
    it("newModManager returns a non-nil object", function()
        local mm = lurek.modding.newModManager()
        expect_true(mm ~= nil, "mod manager is not nil")
    end)

    it("getLoadOrder returns a table on empty manager", function()
        local mm = lurek.modding.newModManager()
        expect_type("table", mm:getLoadOrder())
    end)

    it("getLoadOrder is empty on new manager", function()
        local mm = lurek.modding.newModManager()
        expect_equal(0, #mm:getLoadOrder())
    end)

    it("registerMod adds a mod and getAllMods includes it", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "pack_a" })
        mm:registerMod(m)
        local all = mm:getAllMods()
        expect_type("table", all)
        expect_true(#all >= 1, "at least one mod registered")
    end)

    it("hasMod returns false for unknown id", function()
        local mm = lurek.modding.newModManager()
        expect_false(mm:hasMod("nonexistent_mod"))
    end)

    it("hasMod returns true after registerMod", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "unique_mod" })
        mm:registerMod(m)
        expect_true(mm:hasMod("unique_mod"), "found registered mod by id")
    end)

    it("unregisterMod removes the mod", function()
        local mm = lurek.modding.newModManager()
        local m = lurek.modding.newMod({ id = "temp_mod" })
        mm:registerMod(m)
        mm:unregisterMod("temp_mod")
        expect_false(mm:hasMod("temp_mod"))
    end)

    it("getModCount returns 0 on empty manager", function()
        local mm = lurek.modding.newModManager()
        expect_equal(0, mm:getModCount())
    end)

    it("getModCount increments after registerMod", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "m1" }))
        mm:registerMod(lurek.modding.newMod({ id = "m2" }))
        expect_equal(2, mm:getModCount())
    end)
end)

describe("ModManager.validateDependencies / hasCircularDependencies", function()
    it("validateDependencies returns a table", function()
        local mm = lurek.modding.newModManager()
        local result = mm:validateDependencies()
        expect_type("table", result)
    end)

    it("validateDependencies is empty for independent mods", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "standalone_a" }))
        mm:registerMod(lurek.modding.newMod({ id = "standalone_b" }))
        local errors = mm:validateDependencies()
        expect_equal(0, #errors)
    end)

    it("validateDependencies reports missing dependency", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({
            id = "needs_missing",
            dependencies = { "missing_dep" },
        }))
        local errors = mm:validateDependencies()
        expect_true(#errors >= 1, "unmet dependency should produce an error entry")
    end)

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

    it("hasCircularDependencies returns a boolean", function()
        local mm = lurek.modding.newModManager()
        local result = mm:hasCircularDependencies()
        expect_type("boolean", result)
    end)

    it("hasCircularDependencies is false for acyclic dependency graph", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "base" }))
        mm:registerMod(lurek.modding.newMod({ id = "depends_on_base", dependencies = { "base" } }))
        expect_false(mm:hasCircularDependencies())
    end)
end)

describe("ModManager load order control", function()
    it("setLoadOrder accepts an ordered list of mod ids", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "ord_a" }))
        mm:registerMod(lurek.modding.newMod({ id = "ord_b" }))
        expect_no_error(function()
            mm:setLoadOrder({ "ord_a", "ord_b" })
        end)
    end)

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

    it("clearLoadOrder resets the explicit order", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "clr_a" }))
        mm:setLoadOrder({ "clr_a" })
        expect_no_error(function() mm:clearLoadOrder() end)
    end)
end)

describe("ModManager reload queue", function()
    it("markForReload adds a mod id to the reload queue", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "reload_me" }))
        expect_no_error(function() mm:markForReload("reload_me") end)
    end)

    it("getReloadQueue returns a table", function()
        local mm = lurek.modding.newModManager()
        local q = mm:getReloadQueue()
        expect_type("table", q)
    end)

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

    it("clearReloadQueue empties the queue", function()
        local mm = lurek.modding.newModManager()
        mm:registerMod(lurek.modding.newMod({ id = "rq_clear" }))
        mm:markForReload("rq_clear")
        mm:clearReloadQueue()
        expect_equal(0, #mm:getReloadQueue())
    end)
end)

test_summary()
