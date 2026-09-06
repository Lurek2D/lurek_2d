-- content/examples/mods.lua
-- Auto-generated from content/examples2/mods_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/mods.lua




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
    lurek.log.info("created mod id=" .. mod:getId())
    lurek.log.info("priority = " .. mod:getPriority())
end

--@api: LMod:setEnabled
do

    local mod = lurek.mods.newMod({ id = "toggle_campaign", name = "Toggle Campaign Rules" })
    local before = mod:isEnabled()
    mod:setEnabled(false)
    local after = mod:isEnabled()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    lurek.log.info("campaign toggle before=" .. tostring(before) .. " after=" .. tostring(after) .. " registered=" .. tostring(manager:hasMod(mod:getId())))
end

--@api: LMod:isEnabled
do

    local mod = lurek.mods.newMod({ id = "ruleset", name = "Ruleset Override" })
    local default_enabled = mod:isEnabled()
    mod:setEnabled(false)
    local disabled_state = mod:isEnabled()
    mod:setEnabled(true)
    local restored_state = mod:isEnabled()
    lurek.log.info("ruleset enabled default=" .. tostring(default_enabled) .. " disabled=" .. tostring(disabled_state) .. " restored=" .. tostring(restored_state))
end

--@api: LMod:isLoaded
do

    local mod = lurek.mods.newMod({ id = "fresh_manifest", name = "Fresh Manifest" })
    local before_register = mod:isLoaded()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    local listed = manager:getAllMods()
    local listed_loaded = listed[1] and listed[1].loaded or nil
    lurek.log.info("fresh mod loaded before_register=" .. tostring(before_register) .. " listed_loaded=" .. tostring(listed_loaded) .. " count=" .. tostring(#listed))
end

--@api: LMod:setHook
do

    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        lurek.log.info("hook fired")
    end)
    lurek.log.info("has onLoad = " .. tostring(mod:hasHook("onLoad")))
    lurek.log.info("hook value = " .. tostring(mod:getHook("onLoad") ~= nil))
end

--@api: LMod:getHook
do

    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        lurek.log.info("hook fired")
    end)
    local hook = mod:getHook("onLoad")
    lurek.log.info("hook exists = " .. tostring(hook ~= nil))
end

--@api: LMod:hasHook
do

    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    lurek.log.info("before = " .. tostring(mod:hasHook("onLoad")))
    mod:setHook("onLoad", function()
    end)
    lurek.log.info("after = " .. tostring(mod:hasHook("onLoad")))
end

--@api: LMod:getHookNames
do

    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
    end)
    mod:setHook("onUnload", function()
    end)
    local names = mod:getHookNames()
    lurek.log.info("hook count = " .. #names)
    lurek.log.info("has onLoad = " .. tostring(mod:hasHook("onLoad")))
end

--@api: LMod:setSandbox
do

if not lurek.filesystem.exists("save") then
lurek.filesystem.createDirectory("save")
end
if not lurek.filesystem.exists("save/example-mods") then
lurek.filesystem.createDirectory("save/example-mods")
end
local root = "save/_mods_sandbox_unit"
local root_abs = lurek.filesystem.getSaveDirectory() .. "/_mods_sandbox_unit"
if not lurek.filesystem.exists(root) then
lurek.filesystem.createDirectory(root)
end
local mod = lurek.mods.newMod({ id = "sandbox_guard", name = "Sandbox Guard" })
end

--@api: LMod:getSandbox
do

if not lurek.filesystem.exists("save") then
lurek.filesystem.createDirectory("save")
end
local root = "save/_mods_sandbox_readback"
local root_abs = lurek.filesystem.getSaveDirectory() .. "/_mods_sandbox_readback"
if not lurek.filesystem.exists(root) then
lurek.filesystem.createDirectory(root)
end
local mod = lurek.mods.newMod({ id = "sandbox_readback", name = "Sandbox Readback" })
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
    lurek.log.info("hook sum=" .. tostring(sum))
    lurek.log.info("hook status=" .. tostring(status))
end

--@api: LMod:setConfig
do

    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "hard", volume = 0.8 })
    local config = mod:getConfig()
    lurek.log.info("difficulty = " .. config.difficulty)
    lurek.log.info("volume = " .. tostring(config.volume))
end

--@api: LMod:getConfig
do

    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "story", subtitles = true })
    local config = mod:getConfig()
    lurek.log.info("config exists = " .. tostring(config ~= nil))
    lurek.log.info("subtitles = " .. tostring(config.subtitles))
end

--@api: LMod:setConfigSchema
do

    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    lurek.log.info("schema count = " .. #schema)
    lurek.log.info("first key = " .. schema[1].key)
end

--@api: LMod:getConfigSchema
do

    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    lurek.log.info("schema entries = " .. #schema)
    lurek.log.info("second default = " .. schema[2].default)
end

--@api: LMod:setApiVersion
do

    local mod = lurek.mods.newMod({ id = "ui_patch", name = "UI Patch" })
    local host_version = "1.5.0"
    mod:setApiVersion("2.0.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    lurek.log.info("api requirement host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end

--@api: LMod:getApiVersion
do

    local mod = lurek.mods.newMod({ id = "save_patch", name = "Save Patch" })
    local host_version = "1.3.0"
    mod:setApiVersion("1.2.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    lurek.log.info("saved campaign api host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end

--@api: LMod:setCapabilities
do

    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    lurek.log.info("capability count = " .. #capabilities)
    lurek.log.info("first = " .. capabilities[1])
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
    lurek.log.info("capabilities = " .. capability_list .. " renderer_matches=" .. tostring(#renderers) .. " first_renderer=" .. tostring(first_renderer))
end

--@api: LMod:getDependencies
do

    local mod = lurek.mods.newMod({
        id = "deps",
        name = "Deps",
        dependencies = { "core", "ui" },
    })
    local dependencies = mod:getDependencies()
    lurek.log.info("dependency count = " .. #dependencies)
    lurek.log.info("first dependency = " .. dependencies[1])
end

--@api: LMod:releaseRefs
do

    local mod = lurek.mods.newMod({ id = "release", name = "Release" })
    mod:setHook("test", function()
    end)
    mod:setConfig({ x = 1 })
    mod:releaseRefs()
    lurek.log.info("hook exists = " .. tostring(mod:getHook("test") ~= nil))
    lurek.log.info("config exists = " .. tostring(mod:getConfig() ~= nil))
end

--@api: lurek.mods.newRegistry
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "bandits", { difficulty = 3, biome = "forest" })
    local stored = reg:get("encounter", "bandits")
    local types = reg:getTypes()
    lurek.log.info("registry created=" .. tostring(reg ~= nil) .. " type=" .. reg:type() .. " stored_biome=" .. tostring(stored and stored.biome) .. " types=" .. tostring(#types))
end

--@api: LContentRegistry:register
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    lurek.log.info("stored = " .. tostring(sword ~= nil))
    lurek.log.info("damage = " .. tostring(sword.damage))
end

--@api: LContentRegistry:get
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    lurek.log.info("got = " .. tostring(sword ~= nil))
    lurek.log.info("name = " .. sword.name)
end

--@api: LContentRegistry:getAll
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", { name = "Shield", armor = 5 })
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local items = reg:getAll("item")
    lurek.log.info("shield name = " .. items.shield.name)
    lurek.log.info("sword damage = " .. tostring(items.sword.damage))
end

--@api: lurek.mods.checkApiVersion
do

    local mod = lurek.mods.newMod({ id = "compat", name = "Compat" })
    mod:setApiVersion("2.0.0")
    local ok, err = lurek.mods.checkApiVersion(mod, "1.5.0")
    lurek.log.info("compatible = " .. tostring(ok))
    lurek.log.info("error = " .. tostring(err))
end

--- Mods Module Part 2: LModManager — registration, load order, scanning, reload

--@api: lurek.mods.newModManager
do

    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core_pack", name = "Core Pack", priority = 0 })
    mgr:registerMod(core)
    local order = mgr:getLoadOrder()
    local first = order[1] and order[1].id or "none"
    lurek.log.info("manager type=" .. mgr:type() .. " count=" .. tostring(mgr:getModCount()) .. " first_in_order=" .. tostring(first))
end

--@api: LModManager:registerMod
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mod:setEnabled(true)
    mgr:registerMod(mod)
    lurek.log.info("count = " .. mgr:getModCount())
end

--@api: LModManager:hasMod
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    lurek.log.info("before = " .. tostring(mgr:hasMod("core")))
    mgr:registerMod(mod)
    lurek.log.info("after = " .. tostring(mgr:hasMod("core")))
end

--@api: LModManager:getModCount
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    lurek.log.info("before = " .. mgr:getModCount())
    mgr:registerMod(mod)
    lurek.log.info("after = " .. mgr:getModCount())
end

--@api: LModManager:unregisterMod
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "temp", name = "Temp" })
    mgr:registerMod(mod)
    local removed = mgr:unregisterMod("temp")
    lurek.log.info("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end

--@api: LModManager:getAllMods
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "list", name = "List", version = "2.0.0" })
    mgr:registerMod(mod)
    local mods = mgr:getAllMods()
    lurek.log.info("mods = " .. #mods)
    lurek.log.info("first id = " .. mods[1].id)
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
    lurek.log.info("first = " .. order[1].id)
    lurek.log.info("second = " .. order[2].id)
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
    lurek.log.info("first = " .. order[1].id)
    lurek.log.info("second = " .. order[2].id)
end

--@api: LModManager:clearLoadOrder
do

    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    lurek.log.info("custom first = " .. mgr:getLoadOrder()[1].id)
    mgr:clearLoadOrder()
    lurek.log.info("default first = " .. mgr:getLoadOrder()[1].id)
end

--@api: LModManager:hasCircularDependencies
do

    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", dependencies = { "b" } })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", dependencies = { "a" } })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    lurek.log.info("circular = " .. tostring(mgr:hasCircularDependencies()))
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
    lurek.log.info("missing count = " .. #missing)
    lurek.log.info("first missing = " .. tostring(missing[1]))
end

--@api: LModManager:markForReload
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    local marked = mgr:markForReload("hot")
    lurek.log.info("marked = " .. tostring(marked))
    lurek.log.info("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:getReloadQueue
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    lurek.log.info("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:processReloadQueue
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    lurek.log.info("processed = " .. #processed)
    lurek.log.info("queued after = " .. #mgr:getReloadQueue())
end

--@api: LModManager:clearReloadQueue
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mgr:clearReloadQueue()
    lurek.log.info("queued = " .. #mgr:getReloadQueue())
end

--@api: LModManager:getModPath
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "memory_only", name = "Memory Only" })
    mgr:registerMod(mod)
    local path = mgr:getModPath("memory_only")
    lurek.log.info("has mod = " .. tostring(mgr:hasMod("memory_only")))
    lurek.log.info("path = " .. tostring(path))
end

--@api: LModManager:getModsByCapability
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "render_mod", name = "Renderer Mod" })
    mod:setCapabilities({ "renderer" })
    mgr:registerMod(mod)
    local renderers = mgr:getModsByCapability("renderer")
    lurek.log.info("renderer mods = " .. #renderers)
    lurek.log.info("first id = " .. renderers[1].id)
end

--@api: LModManager:scanFolder
do

local mgr = lurek.mods.newModManager()
local root = "save/example-mods/scan_case"
local mod_dir = root .. "/demo_pack"
if lurek.filesystem.exists(root) then
lurek.filesystem.removeDir(root)
end
if not lurek.filesystem.exists("save") then
lurek.filesystem.createDirectory("save")
end
if not lurek.filesystem.exists("save/example-mods") then
lurek.filesystem.createDirectory("save/example-mods")
end
if not lurek.filesystem.exists(root) then
lurek.filesystem.createDirectory(root)
end
end

--- Mods Module: LContentRegistry, LMod, LModManager

--@api: LContentRegistry:getTypes
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    lurek.log.info("type count = " .. #types)
end

--@api: LContentRegistry:registerType
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    lurek.log.info("types = " .. #types)
end

--@api: LContentRegistry:defineType
do
    local reg = lurek.mods.newRegistry()
    reg:defineType("item", { fields = {
        name = { type = "string", required = true },
        stack = { type = "integer" },
    } })
    reg:register("item", "iron", { name = "Iron", stack = 20 })
    lurek.log.info("defined item schema=" .. tostring(reg:getSchema("item") ~= nil) .. " count=" .. #reg:getTypes())
end

--@api: LContentRegistry:unregisterType
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("temporary")
    local removed = reg:unregisterType("temporary")
    local missing = reg:unregisterType("temporary")
    lurek.log.info("unregister removed=" .. tostring(removed) .. " missing=" .. tostring(missing) .. " types=" .. #reg:getTypes())
end

--@api: LContentRegistry:getSchema
do
    local reg = lurek.mods.newRegistry()
    reg:defineType("npc", { fields = { hp = { type = "integer", required = true } } })
    local schema = reg:getSchema("npc")
    local missing = reg:getSchema("unknown")
    local hp = schema and schema.fields and schema.fields.hp
    local valid_shape = hp and hp.type == "integer" and hp.required == true
    lurek.log.info("schema fields=" .. tostring(schema.fields.hp.type) .. " required=" .. tostring(schema.fields.hp.required))
    lurek.log.info("schema valid=" .. tostring(valid_shape) .. " missing=" .. tostring(missing == nil))
end

--@api: LContentRegistry:validate
do
    local reg = lurek.mods.newRegistry()
    reg:defineType("quest", { fields = { title = { type = "string", required = true } } })
    local ok, err = reg:validate("quest", { title = "Find the key" })
    local bad, bad_err = reg:validate("quest", { title = 42 })
    lurek.log.info("valid=" .. tostring(ok) .. " invalid=" .. tostring(not bad) .. " error=" .. tostring(bad_err or err))
end

--@api: LContentRegistry:freeze
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("runtime")
    local changed = reg:freeze()
    local rejected = not pcall(function() reg:registerType("late") end)
    lurek.log.info("freeze changed=" .. tostring(changed) .. " frozen=" .. tostring(reg:isFrozen()) .. " rejected=" .. tostring(rejected))
end

--@api: LContentRegistry:isFrozen
do
    local reg = lurek.mods.newRegistry()
    local before = reg:isFrozen()
    reg:freeze()
    local after = reg:isFrozen()
    lurek.log.info("frozen before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LContentRegistry:snapshot
do
    local reg = lurek.mods.newRegistry()
    reg:defineType("loot", { fields = { value = { type = "integer", required = true } } })
    reg:register("loot", "coin", { value = 25 })
    local snapshot = reg:snapshot()
    lurek.log.info("snapshot types=" .. #snapshot.types .. " coin=" .. snapshot.entries.loot.coin.value)
end

--@api: LContentRegistry:restore
do
    local source = lurek.mods.newRegistry()
    source:registerType("prefab")
    source:register("prefab", "room", { width = 8, height = 6 })
    local target = lurek.mods.newRegistry()
    target:restore(source:snapshot())
    local room = target:get("prefab", "room")
    lurek.log.info("restored room=" .. room.width .. "x" .. room.height .. " types=" .. #target:getTypes())
end

--@api: LContentRegistry:type
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "wolves", { strength = 2 })
    local type_name = reg:type()
    local types = reg:getTypes()
    local wolves = reg:get("encounter", "wolves")
    lurek.log.info("content registry type=" .. tostring(type_name) .. " type_count=" .. tostring(#types) .. " sample_strength=" .. tostring(wolves and wolves.strength))
end

--@api: LContentRegistry:typeOf
do

    local reg = lurek.mods.newRegistry()
    reg:registerType("loot")
    local is_registry = reg:typeOf("LContentRegistry")
    local is_object = reg:typeOf("LObject")
    local is_manager = reg:typeOf("LModManager")
    local types = reg:getTypes()
    lurek.log.info("registry type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager) .. " type_count=" .. tostring(#types))
end

--@api: LMod:getAuthor
do

    local mod = lurek.mods.newMod({ id = "narrative_pack", name = "Narrative Pack", author = "Dev" })
    local author = mod:getAuthor()
    local name = mod:getName()
    local id = mod:getId()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    lurek.log.info("mod credit id=" .. tostring(id) .. " name=" .. tostring(name) .. " author=" .. tostring(author) .. " registered=" .. tostring(manager:hasMod(id)))
end

--@api: LMod:getDescription
do

    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        description = "Adds extra encounters",
    })
    lurek.log.info("description = " .. mod:getDescription())
end

--@api: LMod:getId
do

    local mod = lurek.mods.newMod({ id = "ui_overhaul", name = "UI Overhaul" })
    local id = mod:getId()
    local name = mod:getName()
    local priority = mod:getPriority()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    lurek.log.info("manifest identity id=" .. tostring(id) .. " name=" .. tostring(name) .. " priority=" .. tostring(priority) .. " count=" .. tostring(manager:getModCount()))
end

--@api: LMod:getName
do

    local mod = lurek.mods.newMod({ id = "economy_patch", name = "Economy Patch" })
    local name = mod:getName()
    local id = mod:getId()
    local version = mod:getVersion()
    local descriptor = name .. "@" .. tostring(version)
    lurek.log.info("display name id=" .. tostring(id) .. " name=" .. tostring(name) .. " descriptor=" .. descriptor)
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
    lurek.log.info("priority value=" .. tostring(priority) .. " load_order_size=" .. tostring(#order) .. " last_id=" .. tostring(last_id))
end

--@api: LMod:getVersion
do

    local mod = lurek.mods.newMod({ id = "patch_notes", name = "Patch Notes", version = "1.4.2" })
    local version = mod:getVersion()
    local id = mod:getId()
    local api = mod:getApiVersion()
    local combined = id .. ":" .. tostring(version)
    lurek.log.info("version query combined=" .. combined .. " api_requirement=" .. tostring(api) .. " loaded=" .. tostring(mod:isLoaded()))
end

--@api: LMod:type
do

    local mod = lurek.mods.newMod({ id = "strict_type", name = "Strict Type" })
    local type_name = mod:type()
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local id = mod:getId()
    lurek.log.info("mod type=" .. tostring(type_name) .. " is_mod=" .. tostring(is_mod) .. " is_object=" .. tostring(is_object) .. " id=" .. tostring(id))
end

--@api: LMod:typeOf
do

    local mod = lurek.mods.newMod({ id = "type_guard", name = "Type Guard" })
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local is_manager = mod:typeOf("LModManager")
    local type_name = mod:type()
    lurek.log.info("type guard type=" .. tostring(type_name) .. " mod=" .. tostring(is_mod) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager))
end

--@api: LModManager:type
do

    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "typed_manager_mod", name = "Typed Manager Mod" })
    mgr:registerMod(mod)
    local type_name = mgr:type()
    local is_manager = mgr:typeOf("LModManager")
    local count = mgr:getModCount()
    lurek.log.info("manager type=" .. tostring(type_name) .. " is_manager=" .. tostring(is_manager) .. " count=" .. tostring(count))
end

--@api: LModManager:typeOf
do

    local mgr = lurek.mods.newModManager()
    mgr:registerMod(lurek.mods.newMod({ id = "guarded_mod", name = "Guarded Mod" }))
    local is_manager = mgr:typeOf("LModManager")
    local is_object = mgr:typeOf("LObject")
    local is_mod = mgr:typeOf("LMod")
    local count = mgr:getModCount()
    lurek.log.info("manager type guard manager=" .. tostring(is_manager) .. " object=" .. tostring(is_object) .. " mod=" .. tostring(is_mod) .. " count=" .. tostring(count))
end
