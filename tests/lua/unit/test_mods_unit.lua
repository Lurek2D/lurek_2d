-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_mods_core_unit.lua
do
-- Lurek2D mods API unit tests
-- One owner test per public mods symbol.

local function make_mod(info)
    local base = {
        id = "core_mod",
        name = "Core Mod",
        version = "1.2.3",
        author = "TestAuthor",
        description = "A test mod",
        dependencies = { "dep_a", "dep_b" },
        priority = 7,
    }
    if info ~= nil then
        for k, v in pairs(info) do
            base[k] = v
        end
    end
    return lurek.mods.newMod(base)
end

local function make_manager()
    return lurek.mods.newModManager()
end

local function expect_list_contains(values, expected)
    local found = false
    for _, value in ipairs(values) do
        if value == expected then
            found = true
        end
    end
    expect_true(found, "expected list to contain " .. tostring(expected))
end

local function remove_if_exists(path, is_dir)
    if lurek.filesystem.exists(path) then
        if is_dir then
            lurek.filesystem.removeDir(path)
        else
            lurek.filesystem.remove(path)
        end
    end
end

-- @describe lurek.mods
describe("lurek.mods", function()
    -- @covers lurek.mods.newMod
    it("creates a mod handle from metadata and rejects missing ids", function()
        local mod = make_mod({ id = "my_mod" })
        expect_type("userdata", mod)
        expect_equal("my_mod", mod:getId())
        expect_error(function()
            lurek.mods.newMod({})
        end)
    end)

    -- @covers lurek.mods.newModManager
    it("creates an empty mod manager", function()
        local manager = make_manager()
        expect_type("userdata", manager)
        expect_equal(0, manager:getModCount())
        expect_equal(0, #manager:getLoadOrder())
    end)

    -- @covers lurek.mods.checkApiVersion
    it("returns compatibility status and message for API requirements", function()
        local compatible = make_mod({ id = "compat_mod" })
        local ok1, err1 = lurek.mods.checkApiVersion(compatible, "1.0.0")
        expect_true(ok1)
        expect_nil(err1)

        local incompatible = make_mod({ id = "incompat_mod", api_version = "2.0.0" })
        local ok2, err2 = lurek.mods.checkApiVersion(incompatible, "1.0.0")
        expect_false(ok2)
        expect_type("string", err2)
    end)

    -- @covers lurek.mods.newRegistry
    it("creates a content registry with basic CRUD methods", function()
        local registry = lurek.mods.newRegistry()
        expect_type("userdata", registry)
        expect_type("function", registry.registerType)
        expect_type("function", registry.register)
        expect_type("function", registry.get)
        expect_type("function", registry.getAll)
        expect_type("function", registry.getTypes)
    end)

    -- @covers LContentRegistry:registerType
    it("registers new content types", function()
        local registry = lurek.mods.newRegistry()
        registry:registerType("item")
        expect_list_contains(registry:getTypes(), "item")
    end)

    -- @covers LContentRegistry:register
    it("stores content entries under a registered type", function()
        local registry = lurek.mods.newRegistry()
        registry:registerType("weapon")
        registry:register("weapon", "sword", { name = "Sword", damage = 10 })
        local sword = registry:get("weapon", "sword")
        expect_not_nil(sword)
        expect_equal("Sword", sword.name)
        expect_false(pcall(function()
            registry:register("unknown_type", "id", {})
        end))
    end)

    -- @covers LContentRegistry:get
    it("returns nil for missing registry entries", function()
        local registry = lurek.mods.newRegistry()
        registry:registerType("spell")
        expect_nil(registry:get("spell", "unknown_spell"))
    end)

    -- @covers LContentRegistry:getAll
    it("returns all entries for a registered type", function()
        local registry = lurek.mods.newRegistry()
        registry:registerType("item")
        registry:register("item", "potion", { name = "Potion" })
        registry:register("item", "scroll", { name = "Scroll" })
        local all = registry:getAll("item")
        expect_not_nil(all.potion)
        expect_not_nil(all.scroll)
    end)

    -- @covers LContentRegistry:getTypes
    it("returns all registered type names", function()
        local registry = lurek.mods.newRegistry()
        registry:registerType("armor")
        registry:registerType("gem")
        local types = registry:getTypes()
        expect_type("table", types)
        expect_equal(2, #types)
    end)

    -- @covers LContentRegistry:type
    it("reports the registry type name", function()
        expect_type("string", lurek.mods.newRegistry():type())
    end)

    -- @covers LContentRegistry:typeOf
    it("checks registry type compatibility", function()
        expect_type("boolean", lurek.mods.newRegistry():typeOf("LObject"))
    end)

    -- @covers LMod:getId
    it("returns the mod id", function()
        expect_equal("accessor_mod", make_mod({ id = "accessor_mod" }):getId())
    end)

    -- @covers LMod:getName
    it("returns a provided name or a string fallback", function()
        expect_equal("My Mod", make_mod({ id = "x", name = "My Mod" }):getName())
        expect_type("string", make_mod({ id = "y", name = nil }):getName())
    end)

    -- @covers LMod:getVersion
    it("returns the version string", function()
        expect_equal("1.2.3", make_mod():getVersion())
    end)

    -- @covers LMod:getAuthor
    it("returns the author string", function()
        expect_equal("TestAuthor", make_mod():getAuthor())
    end)

    -- @covers LMod:getDescription
    it("returns the description string", function()
        expect_equal("A test mod", make_mod():getDescription())
    end)

    -- @covers LMod:getDependencies
    it("returns the declared dependency array", function()
        local deps = make_mod():getDependencies()
        expect_type("table", deps)
        expect_equal(2, #deps)
        expect_equal("dep_a", deps[1])
        expect_equal("dep_b", deps[2])
    end)

    -- @covers LMod:getPriority
    it("returns the priority integer", function()
        expect_equal(7, make_mod():getPriority())
    end)

    -- @covers LMod:isEnabled
    it("is true by default for new mods", function()
        expect_true(make_mod():isEnabled())
    end)

    -- @covers LMod:setEnabled
    it("toggles mod enabled state", function()
        local mod = make_mod()
        mod:setEnabled(false)
        expect_false(mod:isEnabled())
        mod:setEnabled(true)
        expect_true(mod:isEnabled())
    end)

    -- @covers LMod:isLoaded
    it("is false for a fresh mod handle", function()
        expect_false(make_mod():isLoaded())
    end)

    -- @covers LMod:setHook
    it("registers callable hook functions", function()
        local mod = make_mod({ id = "hooks_mod" })
        local called = false
        mod:setHook("on_load", function()
            called = true
        end)
        local fn = mod:getHook("on_load")
        expect_type("function", fn)
        fn()
        expect_true(called)
        expect_error(function()
            mod:setHook("bad hook name", function() end)
        end)
    end)

    -- @covers LMod:hasHook
    it("reports whether a named hook exists", function()
        local mod = make_mod({ id = "has_hook_mod" })
        expect_false(mod:hasHook("on_load"))
        mod:setHook("on_load", function() end)
        expect_true(mod:hasHook("on_load"))
    end)

    -- @covers LMod:getHookNames
    it("returns the names of registered hooks", function()
        local mod = make_mod({ id = "hook_names_mod" })
        mod:setHook("on_load", function() end)
        mod:setHook("on_unload", function() end)
        local names = mod:getHookNames()
        expect_type("table", names)
        expect_true(#names >= 2)
    end)

    -- @covers LMod:getHook
    it("returns nil for missing hooks", function()
        expect_nil(make_mod({ id = "get_hook_mod" }):getHook("missing_hook"))
    end)

    -- @covers LMod:setSandbox
    -- @covers LMod:getSandbox
    it("stores and returns sandbox configuration tables", function()
        local root = "save/_mods_sandbox_unit/"
        remove_if_exists(root, true)
        lurek.filesystem.createDirectory(root)

        local mod = make_mod({ id = "sandbox_mod" })
        mod:setSandbox({
            api_mode = "allow_list",
            apis = { "filesystem" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { root },
            blocked_ops = { "filesystem.remove" },
            allow_network = false,
            allow_file_write = false,
            max_memory = 4096,
        })

        local sandbox = mod:getSandbox()
        expect_type("table", sandbox)
        expect_equal("allow_list", sandbox.api_mode)
        expect_equal("allow_list", sandbox.hook_mode)
        expect_equal("allow_list", sandbox.read_mode)
        expect_equal("filesystem", sandbox.apis[1])
        expect_equal("on_load", sandbox.hooks[1])
        expect_equal(false, sandbox.allow_network)
        expect_equal(false, sandbox.allow_file_write)
        expect_equal(4096, sandbox.max_memory)

        remove_if_exists(root, true)
    end)

    -- @covers LMod:runHook
    it("executes hooks under sandbox policy and returns their values", function()
        local mod = make_mod({
            id = "run_hook_mod",
            sandbox = {
                hook_mode = "allow_list",
                hooks = { "on_load" },
            },
        })
        mod:setHook("on_load", function(a, b)
            return a + b, "ok"
        end)

        local sum, status = mod:runHook("on_load", 2, 3)
        expect_equal(5, sum)
        expect_equal("ok", status)
        expect_error(function()
            mod:runHook("missing_hook")
        end)
    end)

    -- @covers LMod:setConfig
    it("stores and overwrites arbitrary config values", function()
        local mod = make_mod({ id = "cfg_mod" })
        mod:setConfig({ volume = 0.5, fullscreen = true })
        local cfg = mod:getConfig()
        expect_type("table", cfg)
        expect_equal(0.5, cfg.volume)
        mod:setConfig(42)
        expect_equal(42, mod:getConfig())
    end)

    -- @covers LMod:getConfig
    it("returns nil when config is unset", function()
        expect_nil(make_mod({ id = "cfg_nil_mod" }):getConfig())
    end)

    -- @covers LMod:setApiVersion
    it("round-trips api version values", function()
        local mod = make_mod({ id = "api_ver_mod" })
        mod:setApiVersion("3.2.1")
        expect_equal("3.2.1", mod:getApiVersion())
    end)

    -- @covers LMod:getApiVersion
    it("returns nil when the api version is unset", function()
        expect_nil(make_mod({ id = "unset_api_mod" }):getApiVersion())
    end)

    -- @covers LMod:setCapabilities
    it("round-trips capabilities arrays", function()
        local mod = make_mod({ id = "caps_mod" })
        mod:setCapabilities({ "save", "network" })
        local caps = mod:getCapabilities()
        expect_type("table", caps)
        expect_equal("save", caps[1])
        expect_equal("network", caps[2])
    end)

    -- @covers LMod:getCapabilities
    it("returns an empty or present capability list", function()
        expect_type("table", make_mod({ id = "caps_default_mod", capabilities = {} }):getCapabilities())
    end)

    -- @covers LMod:setConfigSchema
    it("round-trips config schema tables", function()
        local mod = make_mod({ id = "schema_mod" })
        local schema = { { key = "volume", type = "number", default = 0.8 } }
        mod:setConfigSchema(schema)
        local result = mod:getConfigSchema()
        expect_type("table", result)
        expect_equal("volume", result[1].key)
    end)

    -- @covers LMod:getConfigSchema
    it("returns an empty table when the config schema is unset", function()
        local schema = make_mod({ id = "schema_nil_mod" }):getConfigSchema()
        expect_type("table", schema)
        expect_equal(0, #schema)
    end)

    -- @covers LMod:releaseRefs
    it("releases internal references without error", function()
        local mod = make_mod({ id = "release_mod" })
        expect_no_error(function()
            mod:releaseRefs()
        end)
    end)

    -- @covers LMod:type
    it("reports the mod type name", function()
        expect_type("string", make_mod({ id = "strict_mod" }):type())
    end)

    -- @covers LMod:typeOf
    it("checks mod type compatibility", function()
        expect_type("boolean", make_mod({ id = "strict_mod2" }):typeOf("LObject"))
    end)

    -- @covers LModManager:registerMod
    it("registers mods with the manager", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "manager_register" }))
        expect_true(manager:hasMod("manager_register"))
        expect_equal(1, manager:getModCount())
    end)

    -- @covers LModManager:getAllMods
    it("returns registered mod info tables", function()
        local manager = make_manager()
        manager:registerMod(make_mod({
            id = "asset_sig_mod",
            assets = { "textures/hero.png" },
            signature = "deadbeef",
        }))
        local all = manager:getAllMods()
        expect_type("table", all)
        expect_equal("textures/hero.png", all[1].assets[1])
        expect_equal("deadbeef", all[1].signature)
    end)

    -- @covers LModManager:getLoadOrder
    it("sorts mods by dependencies and priority", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "base_mod", priority = 50 }))
        manager:registerMod(make_mod({
            id = "child_mod",
            priority = -10,
            dependencies = { "base_mod" },
        }))
        local order = manager:getLoadOrder()
        expect_type("table", order)
        expect_equal("base_mod", order[1].id)
        expect_equal("child_mod", order[2].id)
    end)

    -- @covers LModManager:getModCount
    it("returns the number of registered mods", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "query_a", priority = 1 }))
        manager:registerMod(make_mod({ id = "query_b", priority = 2 }))
        expect_equal(2, manager:getModCount())
    end)

    -- @covers LModManager:getModPath
    it("returns nil or a string for registered mods", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "path_mod" }))
        local path = manager:getModPath("path_mod")
        expect_true(path == nil or type(path) == "string")
    end)

    -- @covers LModManager:getModsByCapability
    it("filters mods by declared capability", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "save_mod", capabilities = { "save", "ui" } }))
        manager:registerMod(make_mod({ id = "audio_mod", capabilities = { "audio" } }))
        local matches = manager:getModsByCapability("save")
        expect_equal(1, #matches)
        expect_equal("save_mod", matches[1].id)
    end)

    -- @covers LModManager:getReloadQueue
    it("returns queued ids after markForReload", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "rq_mod" }))
        manager:markForReload("rq_mod")
        manager:markForReload("rq_mod")
        local queue = manager:getReloadQueue()
        expect_type("table", queue)
        expect_list_contains(queue, "rq_mod")
    end)

    -- @covers LModManager:hasCircularDependencies
    it("detects circular dependency graphs", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "a", dependencies = { "b" } }))
        manager:registerMod(make_mod({ id = "b", dependencies = { "a" } }))
        expect_true(manager:hasCircularDependencies())
    end)

    -- @covers LModManager:hasMod
    it("reports whether a mod id is registered", function()
        local manager = make_manager()
        expect_false(manager:hasMod("nonexistent_mod"))
        manager:registerMod(make_mod({ id = "known_mod" }))
        expect_true(manager:hasMod("known_mod"))
    end)

    -- @covers LModManager:markForReload
    it("marks registered mods for reload", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "reload_me" }))
        expect_true(manager:markForReload("reload_me"))
    end)

    -- @covers LModManager:processReloadQueue
    it("reloads manifest-backed mods and clears the reload queue", function()
        local root = "save/_mods_reload_case/"
        local mod_dir = root .. "reload_mod/"

        remove_if_exists(root, true)
        lurek.filesystem.createDirectory(mod_dir)
        lurek.filesystem.write(
            mod_dir .. "mod.toml",
            "id = \"reload_mod\"\nversion = \"1.0.0\"\n"
        )

        local manager = make_manager()
        manager:scanFolder(root)
        expect_true(manager:markForReload("reload_mod"))

        lurek.filesystem.write(
            mod_dir .. "mod.toml",
            "id = \"reload_mod\"\nversion = \"2.0.0\"\n"
        )

        local processed = manager:processReloadQueue()
        expect_type("table", processed)
        expect_equal(1, #processed)
        expect_equal("reload_mod", processed[1])
        expect_equal(0, #manager:getReloadQueue())

        local reloaded = manager:getAllMods()
        expect_equal("2.0.0", reloaded[1].version)
        expect_true(reloaded[1].loaded)

        remove_if_exists(root, true)
    end)

    -- @covers LModManager:scanFolder
    it("returns a table when scanning a folder", function()
        local manager = make_manager()
        local found = manager:scanFolder("content/examples")
        expect_type("table", found)
    end)

    -- @covers LModManager:setLoadOrder
    it("accepts an explicit load order", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "ord_a", priority = 0 }))
        manager:registerMod(make_mod({ id = "ord_b", priority = 10 }))
        manager:setLoadOrder({ "ord_b", "ord_a" })
        local order = manager:getLoadOrder()
        expect_equal("ord_b", order[1].id)
        expect_equal("ord_a", order[2].id)
    end)

    -- @covers LModManager:clearLoadOrder
    it("clears explicit load order state", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "clr_a" }))
        manager:setLoadOrder({ "clr_a" })
        expect_no_error(function()
            manager:clearLoadOrder()
        end)
    end)

    -- @covers LModManager:clearReloadQueue
    it("clears queued reload ids", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "rq_clear" }))
        manager:markForReload("rq_clear")
        manager:clearReloadQueue()
        expect_equal(0, #manager:getReloadQueue())
    end)

    -- @covers LModManager:type
    it("reports the manager type name", function()
        expect_type("string", make_manager():type())
    end)

    -- @covers LModManager:typeOf
    it("checks manager type compatibility", function()
        expect_type("boolean", make_manager():typeOf("LObject"))
    end)

    -- @covers LModManager:unregisterMod
    it("removes mods and associated reload queue entries", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "manager_unregister" }))
        manager:markForReload("manager_unregister")
        expect_true(manager:unregisterMod("manager_unregister"))
        expect_false(manager:hasMod("manager_unregister"))
        expect_equal(0, #manager:getReloadQueue())
    end)

    -- @covers LModManager:validateDependencies
    it("reports missing dependency errors", function()
        local manager = make_manager()
        manager:registerMod(make_mod({ id = "missing_consumer", dependencies = { "missing_dep" } }))
        local errors = manager:validateDependencies()
        expect_type("table", errors)
        expect_true(#errors >= 1)
    end)
end)
end
-- END test_mods_core_unit.lua

test_summary()
