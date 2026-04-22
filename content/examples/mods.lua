-- content/examples/mods.lua
-- love2d-style usage snippets for the lurek.mods API (40 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/mods.lua

-- ── lurek.mods.* functions ──

--@api-stub: lurek.mods.newMod
-- Creates a new Mod from an info table with at least an `id` field.
-- Build once at startup; reuse across frames.
local mod = lurek.mods.newMod(info)
print("created", mod)
return mod

--@api-stub: lurek.mods.newModManager
-- Creates a new empty ModManager.
-- Build once at startup; reuse across frames.
local modmanager = lurek.mods.newModManager()
print("created", modmanager)
return modmanager

--@api-stub: lurek.mods.checkApiVersion
-- Checks whether a mod's required `api_version` is compatible with the given `host_version`.
-- See the module spec for detailed semantics.
local result = lurek.mods.checkApiVersion(mod_ud, host_version)
print("checkApiVersion:", result)
return result

-- ── Mod methods ──

--@api-stub: Mod:getId
-- Returns the unique mod identifier.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getId()
print("Mod:getId ->", value)

--@api-stub: Mod:getName
-- Returns the localized or human-readable display name of the mod.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getName()
print("Mod:getName ->", value)

--@api-stub: Mod:getVersion
-- Returns the version string.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getVersion()
print("Mod:getVersion ->", value)

--@api-stub: Mod:getAuthor
-- Returns the author name string from this mod's metadata manifest.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getAuthor()
print("Mod:getAuthor ->", value)

--@api-stub: Mod:getDescription
-- Returns the mod description.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getDescription()
print("Mod:getDescription ->", value)

--@api-stub: Mod:getDependencies
-- Returns the list of required mod IDs.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getDependencies()
print("Mod:getDependencies ->", value)

--@api-stub: Mod:getPriority
-- Returns the load-order priority.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getPriority()
print("Mod:getPriority ->", value)

--@api-stub: Mod:isEnabled
-- Returns whether the mod is enabled.
-- Use as a guard inside lurek.update or event handlers.
local mod = lurek.mods.newMod()
if mod:isEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Mod:setEnabled
-- Enables or disables this mod; disabled mods are skipped during loading.
-- Apply at startup or in response to user input.
local mod = lurek.mods.newMod()
mod:setEnabled(enabled)
print("Mod:setEnabled applied")

--@api-stub: Mod:isLoaded
-- Returns whether the mod has been loaded.
-- Use as a guard inside lurek.update or event handlers.
local mod = lurek.mods.newMod()
if mod:isLoaded() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Mod:getApiVersion
-- Returns the required engine API version string, or nil if not set.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getApiVersion()
print("Mod:getApiVersion ->", value)

--@api-stub: Mod:setApiVersion
-- Sets the required engine API version string.
-- Apply at startup or in response to user input.
local mod = lurek.mods.newMod()
mod:setApiVersion(api_version)
print("Mod:setApiVersion applied")

--@api-stub: Mod:getCapabilities
-- Returns an array of declared capability flags.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getCapabilities()
print("Mod:getCapabilities ->", value)

--@api-stub: Mod:setCapabilities
-- Replaces the capability list with the given array of strings.
-- Apply at startup or in response to user input.
local mod = lurek.mods.newMod()
mod:setCapabilities(caps)
print("Mod:setCapabilities applied")

--@api-stub: Mod:getConfigSchema
-- Returns the config schema as an array of `{key, type, default}` tables.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getConfigSchema()
print("Mod:getConfigSchema ->", value)

--@api-stub: Mod:setConfigSchema
-- Replaces the config schema with the given array of `{key, type, default}` tables.
-- Apply at startup or in response to user input.
local mod = lurek.mods.newMod()
mod:setConfigSchema(schema)
print("Mod:setConfigSchema applied")

--@api-stub: Mod:getHook
-- Returns the hook function for the given name, or nil.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getHook("main")
print("Mod:getHook ->", value)

--@api-stub: Mod:hasHook
-- Returns whether a hook with the given name exists.
-- Use as a guard inside lurek.update or event handlers.
local mod = lurek.mods.newMod()
if mod:hasHook("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Mod:getHookNames
-- Returns an array of registered hook names.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getHookNames()
print("Mod:getHookNames ->", value)

--@api-stub: Mod:setConfig
-- Stores an arbitrary config value for this mod.
-- Apply at startup or in response to user input.
local mod = lurek.mods.newMod()
mod:setConfig(value)
print("Mod:setConfig applied")

--@api-stub: Mod:getConfig
-- Returns the stored config value, or nil.
-- Cheap to call; safe inside callbacks.
local mod = lurek.mods.newMod()  -- or your existing handle
local value = mod:getConfig()
print("Mod:getConfig ->", value)

--@api-stub: Mod:releaseRefs
-- Releases all hook and config registry references.
-- See the module spec for detailed semantics.
local mod = lurek.mods.newMod()
mod:releaseRefs()
print("Mod:releaseRefs done")

-- ── ModManager methods ──

--@api-stub: ModManager:registerMod
-- Registers a mod from its Mod userdata.
-- Side-effecting; safe to call any time after init.
local modManager = lurek.mods.newModManager()
modManager:registerMod(ud)
print("ModManager:registerMod done")

--@api-stub: ModManager:unregisterMod
-- Removes a mod by ID and returns whether it was found.
-- Pair with the matching constructor to free resources.
local modManager = lurek.mods.newModManager()
modManager:unregisterMod(1)
-- modManager is now released
print("ok")

--@api-stub: ModManager:hasMod
-- Returns whether a mod with the given ID is registered.
-- Use as a guard inside lurek.update or event handlers.
local modManager = lurek.mods.newModManager()
if modManager:hasMod(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ModManager:getModCount
-- Returns the number of registered mods.
-- Cheap to call; safe inside callbacks.
local modManager = lurek.mods.newModManager()  -- or your existing handle
local value = modManager:getModCount()
print("ModManager:getModCount ->", value)

--@api-stub: ModManager:getAllMods
-- Returns an array of info tables for all registered mods.
-- Cheap to call; safe inside callbacks.
local modManager = lurek.mods.newModManager()  -- or your existing handle
local value = modManager:getAllMods()
print("ModManager:getAllMods ->", value)

--@api-stub: ModManager:getLoadOrder
-- Returns an array of info tables in effective load order.
-- Cheap to call; safe inside callbacks.
local modManager = lurek.mods.newModManager()  -- or your existing handle
local value = modManager:getLoadOrder()
print("ModManager:getLoadOrder ->", value)

--@api-stub: ModManager:validateDependencies
-- Returns an array of mod IDs with missing dependencies.
-- See the module spec for detailed semantics.
local modManager = lurek.mods.newModManager()
modManager:validateDependencies()
print("ModManager:validateDependencies done")

--@api-stub: ModManager:hasCircularDependencies
-- Returns whether any circular dependency cycles exist.
-- Use as a guard inside lurek.update or event handlers.
local modManager = lurek.mods.newModManager()
if modManager:hasCircularDependencies() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ModManager:setLoadOrder
-- Sets an explicit load order from an array of mod ID strings.
-- Apply at startup or in response to user input.
local modManager = lurek.mods.newModManager()
modManager:setLoadOrder({ x = 0, y = 0 })
print("ModManager:setLoadOrder applied")

--@api-stub: ModManager:clearLoadOrder
-- Clears the custom load order, reverting to priority-based sorting.
-- Pair with the matching constructor to free resources.
local modManager = lurek.mods.newModManager()
modManager:clearLoadOrder()
-- modManager is now released
print("ok")

--@api-stub: ModManager:scanFolder
-- Scans a directory for mods with mod.toml and registers them.
-- See the module spec for detailed semantics.
local modManager = lurek.mods.newModManager()
modManager:scanFolder("data/file.txt")
print("ModManager:scanFolder done")

--@api-stub: ModManager:getModPath
-- Returns the filesystem path of a registered mod, or nil.
-- Cheap to call; safe inside callbacks.
local modManager = lurek.mods.newModManager()  -- or your existing handle
local value = modManager:getModPath(1)
print("ModManager:getModPath ->", value)

--@api-stub: ModManager:markForReload
-- Marks a registered mod for hot-reload.
-- See the module spec for detailed semantics.
local modManager = lurek.mods.newModManager()
modManager:markForReload(1)
print("ModManager:markForReload done")

--@api-stub: ModManager:getReloadQueue
-- Returns the array of mod IDs pending hot-reload.
-- Cheap to call; safe inside callbacks.
local modManager = lurek.mods.newModManager()  -- or your existing handle
local value = modManager:getReloadQueue()
print("ModManager:getReloadQueue ->", value)

--@api-stub: ModManager:clearReloadQueue
-- Clears the reload queue without reloading.
-- Pair with the matching constructor to free resources.
local modManager = lurek.mods.newModManager()
modManager:clearReloadQueue()
-- modManager is now released
print("ok")

