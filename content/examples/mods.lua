-- content/examples/mods.lua
-- Auto-generated from content/examples2/mods_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/mods.lua

local function mods_log(message)
    lurek.log.info("[mods.example] " .. tostring(message))
end

local function ensure_dir(path)
    if not lurek.filesystem.exists(path) then
        lurek.filesystem.createDirectory(path)
    end
end

local function prepare_scan_folder(root)
    local mod_dir = root .. "/demo_pack"
    if lurek.filesystem.exists(root) then
        lurek.filesystem.removeDir(root)
    end
    ensure_dir("save")
    ensure_dir("save/example-mods")
    ensure_dir(root)
    ensure_dir(mod_dir)
    lurek.filesystem.write(
        mod_dir .. "/mod.toml",
        "id = \"demo_pack\"\nname = \"Demo Pack\"\nversion = \"1.0.0\"\nauthor = \"Codex\"\n"
    )
    return mod_dir
end

--- Mods Module Part 1: LMod creation, metadata, hooks, config, registry

--@api: lurek.mods.newMod
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "Example mod",
        priority = 10,
    })
    mods_log("created mod id=" .. mod:getId())
    mods_log("priority = " .. mod:getPriority())
end

--@api: LMod:setEnabled
do
    local mod = lurek.mods.newMod({ id = "toggle_campaign", name = "Toggle Campaign Rules" })
    local before = mod:isEnabled()
    mod:setEnabled(false)
    local after = mod:isEnabled()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("campaign toggle before=" .. tostring(before) .. " after=" .. tostring(after) .. " registered=" .. tostring(manager:hasMod(mod:getId())))
end

--@api: LMod:isEnabled
do
    local mod = lurek.mods.newMod({ id = "ruleset", name = "Ruleset Override" })
    local default_enabled = mod:isEnabled()
    mod:setEnabled(false)
    local disabled_state = mod:isEnabled()
    mod:setEnabled(true)
    local restored_state = mod:isEnabled()
    mods_log("ruleset enabled default=" .. tostring(default_enabled) .. " disabled=" .. tostring(disabled_state) .. " restored=" .. tostring(restored_state))
end

--@api: LMod:isLoaded
do
    local mod = lurek.mods.newMod({ id = "fresh_manifest", name = "Fresh Manifest" })
    local before_register = mod:isLoaded()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    local listed = manager:getAllMods()
    local listed_loaded = listed[1] and listed[1].loaded or nil
    mods_log("fresh mod loaded before_register=" .. tostring(before_register) .. " listed_loaded=" .. tostring(listed_loaded) .. " count=" .. tostring(#listed))
end

--@api: LMod:setHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        mods_log("hook fired")
    end)
    mods_log("has onLoad = " .. tostring(mod:hasHook("onLoad")))
    mods_log("hook value = " .. tostring(mod:getHook("onLoad") ~= nil))
end

--@api: LMod:getHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        mods_log("hook fired")
    end)
    local hook = mod:getHook("onLoad")
    mods_log("hook exists = " .. tostring(hook ~= nil))
end

--@api: LMod:hasHook
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mods_log("before = " .. tostring(mod:hasHook("onLoad")))
    mod:setHook("onLoad", function()
    end)
    mods_log("after = " .. tostring(mod:hasHook("onLoad")))
end

--@api: LMod:getHookNames
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
    end)
    mod:setHook("onUnload", function()
    end)
    local names = mod:getHookNames()
    mods_log("hook count = " .. #names)
    mods_log("has onLoad = " .. tostring(mod:hasHook("onLoad")))
end

--@api: LMod:setSandbox
do
    local root = "save/example-mods/sandbox/"
    ensure_dir(root)
    local mod = lurek.mods.newMod({ id = "sandbox_guard", name = "Sandbox Guard" })
    mod:setSandbox({
        api_mode = "allow_list",
        apis = { "filesystem" },
        hook_mode = "allow_list",
        hooks = { "on_load" },
        read_mode = "allow_list",
        read_roots = { root },
        allow_network = false,
        allow_file_write = false,
        max_memory = 4096,
    })
    local sandbox = mod:getSandbox()
    mods_log("sandbox api_mode=" .. tostring(sandbox and sandbox.api_mode))
    mods_log("sandbox max_memory=" .. tostring(sandbox and sandbox.max_memory))
end

--@api: LMod:getSandbox
do
    local root = "save/example-mods/sandbox-read/"
    ensure_dir(root)
    local mod = lurek.mods.newMod({ id = "sandbox_readback", name = "Sandbox Readback" })
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
    })
    local sandbox = mod:getSandbox()
    mods_log("sandbox hooks=" .. tostring(sandbox and sandbox.hooks and sandbox.hooks[1]))
    mods_log("sandbox allow_network=" .. tostring(sandbox and sandbox.allow_network))
    mods_log("sandbox blocked_op=" .. tostring(sandbox and sandbox.blocked_ops and sandbox.blocked_ops[1]))
end

--@api: LMod:runHook
do
    local mod = lurek.mods.newMod({ id = "runtime_hooks", name = "Runtime Hooks" })
    mod:setSandbox({
        hook_mode = "allow_list",
        hooks = { "on_load" },
    })
    mod:setHook("on_load", function(a, b)
        return a + b, "ok"
    end)
    local sum, status = mod:runHook("on_load", 2, 3)
    mods_log("hook sum=" .. tostring(sum))
    mods_log("hook status=" .. tostring(status))
end

--@api: LMod:setConfig
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "hard", volume = 0.8 })
    local config = mod:getConfig()
    mods_log("difficulty = " .. config.difficulty)
    mods_log("volume = " .. tostring(config.volume))
end

--@api: LMod:getConfig
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "story", subtitles = true })
    local config = mod:getConfig()
    mods_log("config exists = " .. tostring(config ~= nil))
    mods_log("subtitles = " .. tostring(config.subtitles))
end

--@api: LMod:setConfigSchema
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    mods_log("schema count = " .. #schema)
    mods_log("first key = " .. schema[1].key)
end

--@api: LMod:getConfigSchema
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    mods_log("schema entries = " .. #schema)
    mods_log("second default = " .. schema[2].default)
end

--@api: LMod:setApiVersion
do
    local mod = lurek.mods.newMod({ id = "ui_patch", name = "UI Patch" })
    local host_version = "1.5.0"
    mod:setApiVersion("2.0.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    mods_log("api requirement host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end

--@api: LMod:getApiVersion
do
    local mod = lurek.mods.newMod({ id = "save_patch", name = "Save Patch" })
    local host_version = "1.3.0"
    mod:setApiVersion("1.2.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    mods_log("saved campaign api host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end

--@api: LMod:setCapabilities
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    mods_log("capability count = " .. #capabilities)
    mods_log("first = " .. capabilities[1])
end

--@api: LMod:getCapabilities
do
    local mod = lurek.mods.newMod({ id = "renderer_pack", name = "Renderer Pack" })
    local manager = lurek.mods.newModManager()
    mod:setCapabilities({ "renderer", "audio", "physics" })
    manager:registerMod(mod)
    local capabilities = mod:getCapabilities()
    local renderers = manager:getModsByCapability("renderer")
    local capability_list = table.concat(capabilities, ", ")
    local first_renderer = renderers[1] and renderers[1].id or "none"
    mods_log("capabilities = " .. capability_list .. " renderer_matches=" .. tostring(#renderers) .. " first_renderer=" .. tostring(first_renderer))
end

--@api: LMod:getDependencies
do
    local mod = lurek.mods.newMod({
        id = "deps",
        name = "Deps",
        dependencies = { "core", "ui" },
    })
    local dependencies = mod:getDependencies()
    mods_log("dependency count = " .. #dependencies)
    mods_log("first dependency = " .. dependencies[1])
end

--@api: LMod:releaseRefs
do
    local mod = lurek.mods.newMod({ id = "release", name = "Release" })
    mod:setHook("test", function()
    end)
    mod:setConfig({ x = 1 })
    mod:releaseRefs()
    mods_log("hook exists = " .. tostring(mod:getHook("test") ~= nil))
    mods_log("config exists = " .. tostring(mod:getConfig() ~= nil))
end

--@api: lurek.mods.newRegistry
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "bandits", { difficulty = 3, biome = "forest" })
    local stored = reg:get("encounter", "bandits")
    local types = reg:getTypes()
    mods_log("registry created=" .. tostring(reg ~= nil) .. " type=" .. reg:type() .. " stored_biome=" .. tostring(stored and stored.biome) .. " types=" .. tostring(#types))
end

--@api: LContentRegistry:register
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    mods_log("stored = " .. tostring(sword ~= nil))
    mods_log("damage = " .. tostring(sword.damage))
end

--@api: LContentRegistry:get
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    mods_log("got = " .. tostring(sword ~= nil))
    mods_log("name = " .. sword.name)
end

--@api: LContentRegistry:getAll
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", { name = "Shield", armor = 5 })
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local items = reg:getAll("item")
    mods_log("shield name = " .. items.shield.name)
    mods_log("sword damage = " .. tostring(items.sword.damage))
end

--@api: lurek.mods.checkApiVersion
do
    local mod = lurek.mods.newMod({ id = "compat", name = "Compat" })
    mod:setApiVersion("2.0.0")
    local ok, err = lurek.mods.checkApiVersion(mod, "1.5.0")
    mods_log("compatible = " .. tostring(ok))
    mods_log("error = " .. tostring(err))
end

--- Mods Module Part 2: LModManager — registration, load order, scanning, reload

--@api: lurek.mods.newModManager
do
    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core_pack", name = "Core Pack", priority = 0 })
    mgr:registerMod(core)
    local order = mgr:getLoadOrder()
    local first = order[1] and order[1].id or "none"
    mods_log("manager type=" .. mgr:type() .. " count=" .. tostring(mgr:getModCount()) .. " first_in_order=" .. tostring(first))
end

--@api: LModManager:registerMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mod:setEnabled(true)
    mgr:registerMod(mod)
    mods_log("count = " .. mgr:getModCount())
end

--@api: LModManager:hasMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mods_log("before = " .. tostring(mgr:hasMod("core")))
    mgr:registerMod(mod)
    mods_log("after = " .. tostring(mgr:hasMod("core")))
end

--@api: LModManager:getModCount
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mods_log("before = " .. mgr:getModCount())
    mgr:registerMod(mod)
    mods_log("after = " .. mgr:getModCount())
end

--@api: LModManager:unregisterMod
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "temp", name = "Temp" })
    mgr:registerMod(mod)
    local removed = mgr:unregisterMod("temp")
    mods_log("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end

--@api: LModManager:getAllMods
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "list", name = "List", version = "2.0.0" })
    mgr:registerMod(mod)
    local mods = mgr:getAllMods()
    mods_log("mods = " .. #mods)
    mods_log("first id = " .. mods[1].id)
end

--@api: LModManager:getLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    local patch = lurek.mods.newMod({
        id = "patch",
        name = "Patch",
        priority = 10,
        dependencies = { "core" },
    })
    mgr:registerMod(core)
    mgr:registerMod(patch)
    local order = mgr:getLoadOrder()
    mods_log("first = " .. order[1].id)
    mods_log("second = " .. order[2].id)
end

--@api: LModManager:setLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    local order = mgr:getLoadOrder()
    mods_log("first = " .. order[1].id)
    mods_log("second = " .. order[2].id)
end

--@api: LModManager:clearLoadOrder
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    mods_log("custom first = " .. mgr:getLoadOrder()[1].id)
    mgr:clearLoadOrder()
    mods_log("default first = " .. mgr:getLoadOrder()[1].id)
end

--@api: LModManager:hasCircularDependencies
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", dependencies = { "b" } })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", dependencies = { "a" } })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mods_log("circular = " .. tostring(mgr:hasCircularDependencies()))
end

--@api: LModManager:validateDependencies
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({
        id = "addon",
        name = "Addon",
        dependencies = { "core" },
    })
    mgr:registerMod(mod)
    local missing = mgr:validateDependencies()
    mods_log("missing count = " .. #missing)
    mods_log("first missing = " .. tostring(missing[1]))
end

--@api: LModManager:markForReload
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    local marked = mgr:markForReload("hot")
    mods_log("marked = " .. tostring(marked))
    mods_log("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:getReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mods_log("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:processReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    mods_log("processed = " .. #processed)
    mods_log("queued after = " .. #mgr:getReloadQueue())
end

--@api: LModManager:clearReloadQueue
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mgr:clearReloadQueue()
    mods_log("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:getModPath
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "memory_only", name = "Memory Only" })
    mgr:registerMod(mod)
    local path = mgr:getModPath("memory_only")
    mods_log("has mod = " .. tostring(mgr:hasMod("memory_only")))
    mods_log("path = " .. tostring(path))
end

--@api: LModManager:getModsByCapability
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "render_mod", name = "Renderer Mod" })
    mod:setCapabilities({ "renderer" })
    mgr:registerMod(mod)
    local renderers = mgr:getModsByCapability("renderer")
    mods_log("renderer mods = " .. #renderers)
    mods_log("first id = " .. renderers[1].id)
end

--@api: LModManager:scanFolder
do
    local mgr = lurek.mods.newModManager()
    local root = "save/example-mods/scan_case"
    prepare_scan_folder(root)
    local found = mgr:scanFolder(root)
    local has_demo = mgr:hasMod("demo_pack")
    local all_mods = mgr:getAllMods()
    local first_id = all_mods[1] and all_mods[1].id or "none"
    mods_log("scanned mods = " .. #found .. " registered=" .. tostring(mgr:getModCount()) .. " has_demo=" .. tostring(has_demo) .. " first_id=" .. tostring(first_id))
end

--- Mods Module: LContentRegistry, LMod, LModManager

--@api: LContentRegistry:getTypes
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    mods_log("type count = " .. #types)
end

--@api: LContentRegistry:registerType
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    mods_log("types = " .. #types)
end

--@api: LContentRegistry:type
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "wolves", { strength = 2 })
    local type_name = reg:type()
    local types = reg:getTypes()
    local wolves = reg:get("encounter", "wolves")
    mods_log("content registry type=" .. tostring(type_name) .. " type_count=" .. tostring(#types) .. " sample_strength=" .. tostring(wolves and wolves.strength))
end

--@api: LContentRegistry:typeOf
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("loot")
    local is_registry = reg:typeOf("LContentRegistry")
    local is_object = reg:typeOf("LObject")
    local is_manager = reg:typeOf("LModManager")
    local types = reg:getTypes()
    mods_log("registry type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager) .. " type_count=" .. tostring(#types))
end

--@api: LMod:getAuthor
do
    local mod = lurek.mods.newMod({ id = "narrative_pack", name = "Narrative Pack", author = "Dev" })
    local author = mod:getAuthor()
    local name = mod:getName()
    local id = mod:getId()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("mod credit id=" .. tostring(id) .. " name=" .. tostring(name) .. " author=" .. tostring(author) .. " registered=" .. tostring(manager:hasMod(id)))
end

--@api: LMod:getDescription
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        description = "Adds extra encounters",
    })
    mods_log("description = " .. mod:getDescription())
end

--@api: LMod:getId
do
    local mod = lurek.mods.newMod({ id = "ui_overhaul", name = "UI Overhaul" })
    local id = mod:getId()
    local name = mod:getName()
    local priority = mod:getPriority()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("manifest identity id=" .. tostring(id) .. " name=" .. tostring(name) .. " priority=" .. tostring(priority) .. " count=" .. tostring(manager:getModCount()))
end

--@api: LMod:getName
do
    local mod = lurek.mods.newMod({ id = "economy_patch", name = "Economy Patch" })
    local name = mod:getName()
    local id = mod:getId()
    local version = mod:getVersion()
    local descriptor = name .. "@" .. tostring(version)
    mods_log("display name id=" .. tostring(id) .. " name=" .. tostring(name) .. " descriptor=" .. descriptor)
end

--@api: LMod:getPriority
do
    local mod = lurek.mods.newMod({ id = "late_patch", name = "Late Patch", priority = 25 })
    local priority = mod:getPriority()
    local manager = lurek.mods.newModManager()
    manager:registerMod(lurek.mods.newMod({ id = "base_patch", name = "Base Patch", priority = 0 }))
    manager:registerMod(mod)
    local order = manager:getLoadOrder()
    local last_id = order[#order] and order[#order].id or "none"
    mods_log("priority value=" .. tostring(priority) .. " load_order_size=" .. tostring(#order) .. " last_id=" .. tostring(last_id))
end

--@api: LMod:getVersion
do
    local mod = lurek.mods.newMod({ id = "patch_notes", name = "Patch Notes", version = "1.4.2" })
    local version = mod:getVersion()
    local id = mod:getId()
    local api = mod:getApiVersion()
    local combined = id .. ":" .. tostring(version)
    mods_log("version query combined=" .. combined .. " api_requirement=" .. tostring(api) .. " loaded=" .. tostring(mod:isLoaded()))
end

--@api: LMod:type
do
    local mod = lurek.mods.newMod({ id = "strict_type", name = "Strict Type" })
    local type_name = mod:type()
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local id = mod:getId()
    mods_log("mod type=" .. tostring(type_name) .. " is_mod=" .. tostring(is_mod) .. " is_object=" .. tostring(is_object) .. " id=" .. tostring(id))
end

--@api: LMod:typeOf
do
    local mod = lurek.mods.newMod({ id = "type_guard", name = "Type Guard" })
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local is_manager = mod:typeOf("LModManager")
    local type_name = mod:type()
    mods_log("type guard type=" .. tostring(type_name) .. " mod=" .. tostring(is_mod) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager))
end

--@api: LModManager:type
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "typed_manager_mod", name = "Typed Manager Mod" })
    mgr:registerMod(mod)
    local type_name = mgr:type()
    local is_manager = mgr:typeOf("LModManager")
    local count = mgr:getModCount()
    mods_log("manager type=" .. tostring(type_name) .. " is_manager=" .. tostring(is_manager) .. " count=" .. tostring(count))
end

--@api: LModManager:typeOf
do
    local mgr = lurek.mods.newModManager()
    mgr:registerMod(lurek.mods.newMod({ id = "guarded_mod", name = "Guarded Mod" }))
    local is_manager = mgr:typeOf("LModManager")
    local is_object = mgr:typeOf("LObject")
    local is_mod = mgr:typeOf("LMod")
    local count = mgr:getModCount()
    mods_log("manager type guard manager=" .. tostring(is_manager) .. " object=" .. tostring(is_object) .. " mod=" .. tostring(is_mod) .. " count=" .. tostring(count))
end
