-- content/examples/save.lua
-- love2d-style usage snippets for the lurek.save API (22 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/save.lua

-- ── lurek.save.* functions ──

--@api-stub: lurek.save.newSaveManager
-- Creates a new SaveManager for slot-based save/load operations.
-- Build once at startup; reuse across frames.
local savemanager = lurek.save.newSaveManager()
print("created", savemanager)
return savemanager

-- ── SaveManager methods ──

--@api-stub: SaveManager:unregister
-- Removes a named module and its callbacks.
-- Pair with the matching constructor to free resources.
local saveManager = lurek.save.newSaveManager()
saveManager:unregister("main")
-- saveManager is now released
print("ok")

--@api-stub: SaveManager:setSchemaVersion
-- Sets the current schema version for new saves.
-- Apply at startup or in response to user input.
local saveManager = lurek.save.newSaveManager()
saveManager:setSchemaVersion(version)
print("SaveManager:setSchemaVersion applied")

--@api-stub: SaveManager:getSchemaVersion
-- Returns the current schema version.
-- Cheap to call; safe inside callbacks.
local saveManager = lurek.save.newSaveManager()  -- or your existing handle
local value = saveManager:getSchemaVersion()
print("SaveManager:getSchemaVersion ->", value)

--@api-stub: SaveManager:collect
-- Collects data from all registered collectors into a table with metadata.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:collect()
print("SaveManager:collect done")

--@api-stub: SaveManager:restore
-- Restores data from a table, applying migrations and calling restorers.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:restore({ x = 0, y = 0 })
print("SaveManager:restore done")

--@api-stub: SaveManager:markDirty
-- Marks data as modified since the last save or load.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:markDirty()
print("SaveManager:markDirty done")

--@api-stub: SaveManager:isDirty
-- Returns whether data has been modified since the last save or load.
-- Use as a guard inside lurek.update or event handlers.
local saveManager = lurek.save.newSaveManager()
if saveManager:isDirty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: SaveManager:disableAutoSave
-- Disables automatic periodic saving; manual `write()` calls still work.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:disableAutoSave()
print("SaveManager:disableAutoSave done")

--@api-stub: SaveManager:update
-- Advances the auto-save timer, returning the slot name if a save should trigger.
-- Apply at startup or in response to user input.
local saveManager = lurek.save.newSaveManager()
saveManager:update(dt)
print("SaveManager:update applied")

--@api-stub: SaveManager:setSummary
-- Sets the summary string included in save metadata.
-- Apply at startup or in response to user input.
local saveManager = lurek.save.newSaveManager()
saveManager:setSummary(summary)
print("SaveManager:setSummary applied")

--@api-stub: SaveManager:getSummary
-- Returns the current summary string.
-- Cheap to call; safe inside callbacks.
local saveManager = lurek.save.newSaveManager()  -- or your existing handle
local value = saveManager:getSummary()
print("SaveManager:getSummary ->", value)

--@api-stub: SaveManager:reset
-- Resets all state, removing callbacks and clearing the manager.
-- Pair with the matching constructor to free resources.
local saveManager = lurek.save.newSaveManager()
saveManager:reset()
-- saveManager is now released
print("ok")

--@api-stub: SaveManager:setCompress
-- Enables or disables LZ4 compression for saved data.
-- Apply at startup or in response to user input.
local saveManager = lurek.save.newSaveManager()
saveManager:setCompress(enabled)
print("SaveManager:setCompress applied")

--@api-stub: SaveManager:isCompressed
-- Returns whether compression is currently enabled.
-- Use as a guard inside lurek.update or event handlers.
local saveManager = lurek.save.newSaveManager()
if saveManager:isCompressed() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: SaveManager:onBeforeSave
-- Registers a callback that fires before every save operation.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:onBeforeSave(function() print("onBeforeSave fired") end)
print("SaveManager:onBeforeSave done")

--@api-stub: SaveManager:onAfterLoad
-- Registers a callback that fires after every successful load operation.
-- See the module spec for detailed semantics.
local saveManager = lurek.save.newSaveManager()
saveManager:onAfterLoad(function() print("onAfterLoad fired") end)
print("SaveManager:onAfterLoad done")

--@api-stub: SaveManager:save
-- Collects data and writes it to a slot file.
-- May block — call from a worker thread for large payloads.
local saveManager = lurek.save.newSaveManager()
saveManager:save(slot)
print("SaveManager:save done")

--@api-stub: SaveManager:load
-- Loads data from a slot file, applies migrations, and restores.
-- May block — call from a worker thread for large payloads.
local saveManager = lurek.save.newSaveManager()
saveManager:load(slot)
print("SaveManager:load done")

--@api-stub: SaveManager:delete
-- Deletes a save file for the given slot.
-- Pair with the matching constructor to free resources.
local saveManager = lurek.save.newSaveManager()
saveManager:delete(slot)
-- saveManager is now released
print("ok")

--@api-stub: SaveManager:getSlots
-- Returns a list of all save slots with metadata.
-- Cheap to call; safe inside callbacks.
local saveManager = lurek.save.newSaveManager()  -- or your existing handle
local value = saveManager:getSlots()
print("SaveManager:getSlots ->", value)

--@api-stub: SaveManager:getSlotInfo
-- Returns metadata for a single slot, or nil if not found.
-- Cheap to call; safe inside callbacks.
local saveManager = lurek.save.newSaveManager()  -- or your existing handle
local value = saveManager:getSlotInfo(slot)
print("SaveManager:getSlotInfo ->", value)

