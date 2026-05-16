-- content/examples/mods.lua
-- lurek.mods API examples.
-- Run: cargo run -- content/examples/mods.lua

--@api-stub: lurek.mods.newMod -- Creates a mod metadata handle from a Lua table
do -- lurek.mods.newMod
  local hud_mod = lurek.mods.newMod({
    id = "core.hud",
    name = "Core HUD",
    version = "1.2.0",
    author = "studio",
    priority = 10,
    dependencies = {"core.input"},
  })
  lurek.log.info("built mod " .. hud_mod:getId() .. " v" .. hud_mod:getVersion(), "mods")
end

--@api-stub: lurek.mods.newModManager -- Creates an empty mod manager
do -- lurek.mods.newModManager
  local manager = lurek.mods.newModManager()
  lurek.log.info("manager initialised, " .. manager:getModCount() .. " mods", "mods")
end

--@api-stub: lurek.mods.checkApiVersion -- Checks whether a mod API version is compatible with a host version
do -- lurek.mods.checkApiVersion
  local probe = lurek.mods.newMod({id = "fan.skins", api_version = "1.4.0"})
  local ok, msg = lurek.mods.checkApiVersion(probe, "1.6.2")
  if not ok then
    lurek.log.warn("incompatible mod: " .. (msg or "unknown"), "mods")
  end
end

-- â”€â”€ Mod methods â”€â”€

--@api-stub: Mod:getId
do -- Mod:getId
  local m = lurek.mods.newMod({id = "core.audio"})
  local registry = {}
  registry[m:getId()] = {volume = 0.8}
end

--@api-stub: Mod:getName
do -- Mod:getName
  local m = lurek.mods.newMod({id = "ui.theme.dark", name = "Dark Theme"})
  local label = m:getName()
  if label == "" then label = m:getId() end
  lurek.log.info("listing: " .. label, "ui")
end

--@api-stub: Mod:getVersion
do -- Mod:getVersion
  local m = lurek.mods.newMod({id = "core.physics", version = "2.1.0"})
  if m:getVersion() ~= "2.1.0" then
    lurek.log.warn("save was written by " .. m:getVersion(), "save")
  end
end

--@api-stub: Mod:getAuthor
do -- Mod:getAuthor
  local m = lurek.mods.newMod({id = "fan.maps", author = "alice"})
  local credit = m:getAuthor()
  lurek.log.info("map pack by " .. credit, "credits")
end

--@api-stub: Mod:getDescription
do -- Mod:getDescription
  local m = lurek.mods.newMod({id = "ui.minimap", description = "Adds a corner minimap with fog-of-war."})
  local detail = m:getDescription()
  lurek.log.info("about: " .. detail, "ui")
end

--@api-stub: Mod:getDependencies
do -- Mod:getDependencies
  local m = lurek.mods.newMod({id = "fan.weapons", dependencies = {"core.combat", "core.audio"}})
  for _, dep in ipairs(m:getDependencies()) do
    lurek.log.debug("requires " .. dep, "mods")
  end
end

--@api-stub: Mod:getPriority
do -- Mod:getPriority
  local a = lurek.mods.newMod({id = "core.base", priority = 100})
  local b = lurek.mods.newMod({id = "fan.tweak", priority = 5})
  if a:getPriority() > b:getPriority() then
    lurek.log.info(a:getId() .. " loads before " .. b:getId(), "mods")
  end
end

--@api-stub: Mod:isEnabled
do -- Mod:isEnabled
  local m = lurek.mods.newMod({id = "fan.cheats"})
  if m:isEnabled() then
    lurek.log.debug(m:getId() .. " is active", "mods")
  end
end

--@api-stub: Mod:setEnabled
do -- Mod:setEnabled
  local m = lurek.mods.newMod({id = "fan.skins"})
  local user_choice = false
  m:setEnabled(user_choice)
  lurek.log.info(m:getId() .. " enabled=" .. tostring(m:isEnabled()), "mods")
end

--@api-stub: Mod:isLoaded
do -- Mod:isLoaded
  local m = lurek.mods.newMod({id = "core.input"})
  if not m:isLoaded() then
    lurek.log.debug("pending: " .. m:getId(), "mods")
  end
end

--@api-stub: Mod:getApiVersion
do -- Mod:getApiVersion
  local m = lurek.mods.newMod({id = "fan.maps", api_version = "1.5.0"})
  local req = m:getApiVersion()
  if req then
    lurek.log.info(m:getId() .. " requires engine >= " .. req, "mods")
  end
end

--@api-stub: Mod:setApiVersion
do -- Mod:setApiVersion
  local m = lurek.mods.newMod({id = "test.fixture"})
  m:setApiVersion("1.6.0")
  lurek.log.debug("fixture api_version=" .. m:getApiVersion(), "test")
end

--@api-stub: Mod:getCapabilities
do -- Mod:getCapabilities
  local m = lurek.mods.newMod({id = "fan.online", capabilities = {"network", "filesystem"}})
  for _, cap in ipairs(m:getCapabilities()) do
    lurek.log.debug(m:getId() .. " uses " .. cap, "mods")
  end
end

--@api-stub: Mod:setCapabilities
do -- Mod:setCapabilities
  local m = lurek.mods.newMod({id = "fan.tools"})
  local caps = m:getCapabilities()
  caps[#caps + 1] = "filesystem"
  m:setCapabilities(caps)
end

--@api-stub: Mod:getConfigSchema
do -- Mod:getConfigSchema
  local m = lurek.mods.newMod({id = "ui.theme", config_schema = {
    {key = "accent", type = "string", default = "#ff8800"},
  }})
  for _, entry in ipairs(m:getConfigSchema()) do
    lurek.log.debug("setting " .. entry.key .. " (" .. entry.type .. ")", "ui")
  end
end

--@api-stub: Mod:setConfigSchema
do -- Mod:setConfigSchema
  local m = lurek.mods.newMod({id = "fan.audio"})
  m:setConfigSchema({
    {key = "music_vol", type = "number", default = "0.8"},
    {key = "sfx_vol",   type = "number", default = "1.0"},
  })
end

--@api-stub: Mod:getHook
do -- Mod:getHook
  local m = lurek.mods.newMod({id = "fan.combat"})
  m:setHook("on_damage", function(amount) return amount * 2 end)
  local fn = m:getHook("on_damage")
  if fn then lurek.log.debug("doubled: " .. fn(10), "combat") end
end

--@api-stub: Mod:hasHook
do -- Mod:hasHook
  local m = lurek.mods.newMod({id = "fan.input"})
  m:setHook("on_jump", function() end)
  if m:hasHook("on_jump") then
    lurek.log.debug(m:getId() .. " handles jump", "input")
  end
end

--@api-stub: Mod:getHookNames
do -- Mod:getHookNames
  local m = lurek.mods.newMod({id = "fan.events"})
  m:setHook("on_load", function() end)
  m:setHook("on_quit", function() end)
  for _, name in ipairs(m:getHookNames()) do
    lurek.log.debug(m:getId() .. " hook: " .. name, "mods")
  end
end

--@api-stub: Mod:setConfig
do -- Mod:setConfig
  local m = lurek.mods.newMod({id = "fan.audio"})
  m:setConfig({music_vol = 0.6, sfx_vol = 1.0, mute = false})
end

--@api-stub: Mod:getConfig
do -- Mod:getConfig
  local m = lurek.mods.newMod({id = "fan.audio"})
  m:setConfig({music_vol = 0.5})
  local cfg = m:getConfig() or {music_vol = 1.0}
  lurek.log.debug("music vol=" .. cfg.music_vol, "audio")
end

--@api-stub: Mod:releaseRefs
do -- Mod:releaseRefs
  local m = lurek.mods.newMod({id = "scratch.tmp"})
  m:setHook("on_tick", function() end)
  m:setConfig({foo = 1})
  m:releaseRefs()
end

-- â”€â”€ ModManager methods â”€â”€

--@api-stub: ModManager:registerMod
do -- ModManager:registerMod
  local mgr = lurek.mods.newModManager()
  local m = lurek.mods.newMod({id = "core.hud", priority = 50})
  mgr:registerMod(m)
  lurek.log.info("registered " .. mgr:getModCount() .. " mods", "mods")
end

--@api-stub: ModManager:unregisterMod
do -- ModManager:unregisterMod
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "fan.skins"}))
  local removed = mgr:unregisterMod("fan.skins")
  lurek.log.info("removed=" .. tostring(removed), "mods")
end

--@api-stub: ModManager:hasMod
do -- ModManager:hasMod
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "core.combat"}))
  if mgr:hasMod("core.combat") then
    lurek.log.debug("combat available", "ui")
  end
end

--@api-stub: ModManager:getModCount
do -- ModManager:getModCount
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "a"}))
  mgr:registerMod(lurek.mods.newMod({id = "b"}))
  lurek.log.info("loaded " .. mgr:getModCount() .. " mods", "boot")
end

--@api-stub: ModManager:getAllMods
do -- ModManager:getAllMods
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "core.hud", name = "HUD"}))
  for _, info in ipairs(mgr:getAllMods()) do
    lurek.log.debug(info.id .. " priority=" .. info.priority, "mods")
  end
end

--@api-stub: ModManager:getLoadOrder
do -- ModManager:getLoadOrder
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "core.base", priority = 100}))
  mgr:registerMod(lurek.mods.newMod({id = "fan.ui",   priority = 10, dependencies = {"core.base"}}))
  for i, info in ipairs(mgr:getLoadOrder()) do
    lurek.log.info(i .. ": " .. info.id, "mods")
  end
end

--@api-stub: ModManager:getModsByCapability
do -- ModManager:getModsByCapability
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "fan.audio", capabilities = {"audio"}}))
  mgr:registerMod(lurek.mods.newMod({id = "fan.ui", capabilities = {"ui"}}))
  for _, info in ipairs(mgr:getModsByCapability("audio")) do
    lurek.log.info("audio-capable: " .. info.id, "mods")
  end
end

--@api-stub: ModManager:validateDependencies
do -- ModManager:validateDependencies
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "fan.weapons", dependencies = {"core.combat"}}))
  for _, broken_id in ipairs(mgr:validateDependencies()) do
    lurek.log.error("missing deps for " .. broken_id, "mods")
  end
end

--@api-stub: ModManager:hasCircularDependencies
do -- ModManager:hasCircularDependencies
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "a", dependencies = {"b"}}))
  mgr:registerMod(lurek.mods.newMod({id = "b", dependencies = {"a"}}))
  if mgr:hasCircularDependencies() then
    lurek.log.error("dependency cycle detected", "mods")
  end
end

--@api-stub: ModManager:setLoadOrder
do -- ModManager:setLoadOrder
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "core.base"}))
  mgr:registerMod(lurek.mods.newMod({id = "fan.ui"}))
  mgr:setLoadOrder({"core.base", "fan.ui"})
end

--@api-stub: ModManager:clearLoadOrder
do -- ModManager:clearLoadOrder
  local mgr = lurek.mods.newModManager()
  mgr:setLoadOrder({"a", "b", "c"})
  mgr:clearLoadOrder()
  lurek.log.info("load order reset to priority", "mods")
end

--@api-stub: ModManager:scanFolder
do -- ModManager:scanFolder
  local mgr = lurek.mods.newModManager()
  local discovered = mgr:scanFolder("content/plugins")
  lurek.log.info("auto-registered " .. #discovered .. " mods", "mods")
end

--@api-stub: ModManager:getModPath
do -- ModManager:getModPath
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "fan.skins"}))
  local path = mgr:getModPath("fan.skins")
  if path then lurek.log.debug("on-disk at " .. path, "mods") end
end

--@api-stub: ModManager:markForReload
do -- ModManager:markForReload
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "core.hud"}))
  local queued = mgr:markForReload("core.hud")
  lurek.log.debug("queued for reload=" .. tostring(queued), "mods")
end

--@api-stub: ModManager:getReloadQueue
do -- ModManager:getReloadQueue
  local mgr = lurek.mods.newModManager()
  mgr:registerMod(lurek.mods.newMod({id = "ui.theme"}))
  mgr:markForReload("ui.theme")
  for _, id in ipairs(mgr:getReloadQueue()) do
    lurek.log.info("reload pending: " .. id, "mods")
  end
end

--@api-stub: ModManager:clearReloadQueue
do -- ModManager:clearReloadQueue
  local mgr = lurek.mods.newModManager()
  mgr:markForReload("core.hud")
  mgr:clearReloadQueue()
  lurek.log.debug("queue size=" .. #mgr:getReloadQueue(), "mods")
end
--@api-stub: ModManager:processReloadQueue
do -- ModManager:processReloadQueue
  local mgr = lurek.mods.newModManager()
  ---@diagnostic disable-next-line: undefined-field
  local reloaded = mgr:processReloadQueue()
  lurek.log.debug("reloaded count=" .. #reloaded, "mods")
end
-- â”€â”€ Content Registry â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

--@api-stub: lurek.mods.newRegistry -- Creates an empty content registry
do -- lurek.mods.newRegistry
  local reg = lurek.mods.newRegistry()
  lurek.log.debug("registry created", "mods")
end

--@api-stub: ContentRegistry:registerType
do -- ContentRegistry:registerType
  local reg = lurek.mods.newRegistry()
  reg:registerType("weapon")
  lurek.log.debug("registered type 'weapon'", "mods")
end

--@api-stub: ContentRegistry:register
do -- ContentRegistry:register
  local reg = lurek.mods.newRegistry()
  reg:registerType("weapon")
  reg:register("weapon", "iron_sword", { name = "Iron Sword", damage = 12 })
  lurek.log.debug("registered iron_sword", "mods")
end

--@api-stub: ContentRegistry:get
do -- ContentRegistry:get
  local reg = lurek.mods.newRegistry()
  reg:registerType("spell")
  reg:register("spell", "fireball", { cost = 10 })
  local s = reg:get("spell", "fireball")
  lurek.log.debug("spell cost=" .. (s and s.cost or "nil"), "mods") ---@diagnostic disable-line:undefined-field
end

--@api-stub: ContentRegistry:getAll
do -- ContentRegistry:getAll
  local reg = lurek.mods.newRegistry()
  reg:registerType("item")
  reg:register("item", "potion", { name = "Potion" })
  local all = reg:getAll("item")
  lurek.log.debug("item count=" .. (all.potion and 1 or 0), "mods") ---@diagnostic disable-line:undefined-field
end

--@api-stub: ContentRegistry:getTypes
do -- ContentRegistry:getTypes
  local reg = lurek.mods.newRegistry()
  reg:registerType("creature")
  reg:registerType("item")
  local types = reg:getTypes()
  lurek.log.debug("type count=" .. #types, "mods")
end

--@api-stub: Mod:setHook
do -- Mod:setHook
  local mod = lurek.mods.newMod({id="example_mod", name="Example", version="1.0"})
  mod:setHook("on_save", function(ctx)
    lurek.log.info("mod saving extra data", "mods")
  end)
  lurek.log.info("hook registered: " .. tostring(mod:hasHook("on_save")), "mods")
end

-- =============================================================================
-- COVERAGE: 4 uncovered lurek.mods API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- ModManager methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 6 uncovered lurek.mods API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LContentRegistry methods
-- -----------------------------------------------------------------------------

--@api-stub: LContentRegistry:type -- Returns the Lua-visible type name for this content registry handle
do -- LContentRegistry:type
  local content_registry_obj = lurek.mods.newRegistry()
  local t = content_registry_obj:type()
  lurek.log.info("LContentRegistry:type = " .. t, "mods")
end
--@api-stub: LContentRegistry:typeOf -- Returns whether this content registry handle matches a supported type name
do -- LContentRegistry:typeOf
  local content_registry_obj = lurek.mods.newRegistry()
  lurek.log.info("is LContentRegistry: " .. tostring(content_registry_obj:typeOf("LContentRegistry")), "mods")
  lurek.log.info("is wrong: " .. tostring(content_registry_obj:typeOf("Unknown")), "mods")
end
--@api-stub: LMod:type -- Returns the Lua-visible type name for this mod handle
do -- LMod:type
  local ok ---@type boolean
  local mod_obj ---@type LMod?
  ok, mod_obj = pcall(lurek.mods.newMod, "testmod")
  if not ok then mod_obj = nil end
  local t = mod_obj and mod_obj:type() or "LMod"
  lurek.log.info("LMod:type = " .. t, "mods")
end
--@api-stub: LMod:typeOf -- Returns whether this mod handle matches a supported type name
do -- LMod:typeOf
  local ok2 ---@type boolean
  local mod_obj2 ---@type LMod?
  ok2, mod_obj2 = pcall(lurek.mods.newMod, "testmod")
  if not ok2 then mod_obj2 = nil end
  lurek.log.info("is LMod: " .. tostring(mod_obj2 and mod_obj2:typeOf("LMod") or false), "mods")
  lurek.log.info("is wrong: " .. tostring(mod_obj2 and mod_obj2:typeOf("Unknown") or false), "mods")
end
--@api-stub: LModManager:type -- Returns the Lua-visible type name for this mod manager handle
do -- LModManager:type
  local mod_manager_obj = lurek.mods.newModManager()
  local t = mod_manager_obj:type()
  lurek.log.info("LModManager:type = " .. t, "mods")
end
--@api-stub: LModManager:typeOf -- Returns whether this mod manager handle matches a supported type name
do -- LModManager:typeOf
  local mod_manager_obj = lurek.mods.newModManager()
  lurek.log.info("is LModManager: " .. tostring(mod_manager_obj:typeOf("LModManager")), "mods")
  lurek.log.info("is wrong: " .. tostring(mod_manager_obj:typeOf("Unknown")), "mods")
end


