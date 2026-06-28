# Save

## Purpose

Manages game saves with compression, auto-save timers, and schema migrations.

## Summary

- The `save` module is the persistence-lifecycle surface for users who want game state to be stored, versioned, and restored as a managed workflow instead of a raw file dump.
- Save managers, metadata, migration support, schema versions, and summary information work together so save files can evolve over time without every project rolling its own compatibility rules.
- That matters because persistence is usually more than writing bytes: projects also need naming, summaries, migration paths, and validation.
- It also needs a clear lifecycle for selecting, migrating, and restoring stored game state.
- Read `save` as the owner of save and load policy. Serialization modules decide how data is encoded, but `save` decides how game-state persistence is packaged, versioned, and coordinated for users.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.save.newManager`

Create a new SaveManager instance for managing persistent game saves.

```lua
lurek.save.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSaveManager](#lsavemanager) | A fresh save manager with no registered sections. |

**Example**

```lua
do

    ---@type LSaveManager
    local mgr = lurek.save.newManager()
    mgr:setSummary("Canonical Manager")
    local summary = mgr:getSummary()
    lurek.log.info(tostring("type = " .. mgr:type()))
    lurek.log.info(tostring("format = " .. mgr:getFormat()))
    lurek.log.info(tostring("summary = " .. summary))
end
```

---

### `lurek.save.newSaveManager`

Create a new SaveManager instance for managing persistent game saves.

```lua
lurek.save.newSaveManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSaveManager](#lsavemanager) | A fresh save manager with no registered sections. |

**Example**

```lua
do

    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("New Game")
    mgr:setSchemaVersion(1)
    lurek.log.info(tostring("type = " .. mgr:type()))
    lurek.log.info(tostring("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager"))))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LSaveManager](#lsavemanager)

## LSaveManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSaveManager:addMigration`

Register a migration function that transforms save data from one schema version to the next.

```lua
LSaveManager:addMigration(fromVersion, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fromVersion` | number | The schema version this migration upgrades FROM (it produces fromVersion+1). |
| `func` | function | Receives the full save data table and must return the transformed table. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    local collected = { __schema_version = 1, player = {} }
    mgr:register("player", function() return { level = 7 } end, function(_) end)
    mgr:restore(collected)
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end
```

---

#### `LSaveManager:collect`

Invoke all registered collectors and return the assembled save-data table without writing to disk.

```lua
LSaveManager:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The full save-data table including __schema_version, __timestamp, and __summary metadata. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    local data = mgr:collect()
    data.player.hp = data.player.hp + 25
    mgr:restore(data)
    lurek.log.info(tostring("collected player hp = " .. data.player.hp))
    lurek.log.info(tostring("restored player hp = " .. hp))
end
```

---

#### `LSaveManager:delete`

Permanently delete a save slot file from disk. This action cannot be undone.

```lua
LSaveManager:delete(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name to delete (e.g. "slot1"). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_delete_slot"
    mgr:save(slot)
    mgr:delete(slot)
    lurek.log.info(tostring("after delete exists = " .. tostring(mgr:exists(slot))))
end
```

---

#### `LSaveManager:disableAutoSave`

Disable the periodic auto-save timer. Manual saves via save() still work.

```lua
LSaveManager:disableAutoSave()
```

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    mgr:enableAutoSave(5.0, "autosave")
    mgr:disableAutoSave()
    mgr:markDirty()
    lurek.log.info(tostring("after disable triggered = " .. tostring(mgr:update(6.0))))
end
```

---

#### `LSaveManager:enableAutoSave`

Enable periodic auto-saving: when the dirty flag is set, the system writes to the target slot every interval seconds.

```lua
LSaveManager:enableAutoSave(interval, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | number | Time in seconds between auto-save checks (e.g. 30.0 for every 30 seconds). |
| `slot` | string | The validated slot name to auto-save into (e.g. "autosave"). |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_autosave_slot"
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    lurek.log.info(tostring("auto-save triggered = " .. tostring(mgr:update(6.0))))
    lurek.log.info(tostring("autosave exists = " .. tostring(mgr:exists("autosave"))))
    pcall(function() mgr:delete("autosave") end)
end
```

---

#### `LSaveManager:exists`

Check whether a save slot file exists on disk without reading its contents.

```lua
LSaveManager:exists(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the slot file is present. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_exists_slot"
    mgr:save(slot)
    lurek.log.info(tostring("exists = " .. tostring(mgr:exists(slot))))
    mgr:delete(slot)
end
```

---

#### `LSaveManager:getFormat`

Return the payload serialization format used for saves and loads.

```lua
LSaveManager:getFormat()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current format name. |

**Example**

```lua
do

    local mgr = lurek.save.newManager()
    local format = mgr:getFormat()
    mgr:setSummary("Default format")
    lurek.log.info(tostring("default save format = " .. format))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end
```

---

#### `LSaveManager:getSchemaVersion`

Return the current schema version number set for this save manager.

```lua
LSaveManager:getSchemaVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The active schema version. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end
```

---

#### `LSaveManager:getSlotInfo`

Read metadata for a single save slot without loading its full game state.

```lua
LSaveManager:getSlotInfo(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| LSaveManagerGetSlotInfoResult | Info table with fields: slot, version, timestamp, summary, or nil if not found. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slot_info"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local info = mgr:getSlotInfo(slot)
    lurek.log.info(tostring("slot info = " .. tostring(info and info.slot)))
    lurek.log.info(tostring("summary = " .. tostring(info and info.summary)))
    mgr:delete(slot)
end
```

---

#### `LSaveManager:getSlots`

List all save slots found on disk with their metadata (version, timestamp, summary).

```lua
LSaveManager:getSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| LSaveManagerGetSlotsResult | Array of info tables, each with fields: slot, version, timestamp, summary. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slots_slot"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local slots = mgr:getSlots()
    lurek.log.info(tostring("slot count = " .. #slots))
    lurek.log.info(tostring("first slot = " .. tostring(slots[1] and slots[1].slot)))
    mgr:delete(slot)
end
```

---

#### `LSaveManager:getSummary`

Get the current summary string that will be embedded in the next save.

```lua
LSaveManager:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The summary text, or an empty string if none was set. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("progress", function() return { chapter = 3 } end, function(_) end)
    local data = mgr:collect()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end
```

---

#### `LSaveManager:isCompressed`

Check whether save compression is currently enabled.

```lua
LSaveManager:isCompressed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if future saves will be LZ4-compressed. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    mgr:setSummary("Compressed Save")
    lurek.log.info(tostring("after enable = " .. tostring(mgr:isCompressed())))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
    mgr:setCompress(false)
end
```

---

#### `LSaveManager:isDirty`

Check whether unsaved changes exist since the last save or load.

```lua
LSaveManager:isDirty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if game state has been modified and not yet persisted. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    lurek.log.info(tostring("dirty = " .. tostring(mgr:isDirty())))
    mgr:markDirty()
    lurek.log.info(tostring("after markDirty = " .. tostring(mgr:isDirty())))
end
```

---

#### `LSaveManager:load`

Load game state from a named slot file. Decompresses if needed, applies migrations, calls restorers, then fires onAfterLoad.

```lua
LSaveManager:load(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name to load (e.g. "slot1"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the load succeeded; false on error. |
| string | Error message if the load failed; nil on success. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    local score = 9999
    mgr:register("score", function() return { value = score } end, function(data) score = data.value end)
    local slot = "example_load_slot"
    mgr:save(slot)
    score = 0
    local ok, err = mgr:load(slot)
    lurek.log.info(tostring("load ok = " .. tostring(ok)))
    lurek.log.info(tostring("load err = " .. tostring(err)))
    lurek.log.info(tostring("score = " .. score))
    mgr:delete(slot)
end
```

---

#### `LSaveManager:markDirty`

Mark the save state as dirty, indicating unsaved changes exist.

```lua
LSaveManager:markDirty()
```

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    lurek.log.info(tostring("dirty = " .. tostring(mgr:isDirty())))
    mgr:markDirty()
    lurek.log.info(tostring("after markDirty = " .. tostring(mgr:isDirty())))
end
```

---

#### `LSaveManager:onAfterLoad`

Set a hook function called immediately after a save file is successfully loaded and all restorers have run.

```lua
LSaveManager:onAfterLoad(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func?` | function | Callback receiving the slot name as its argument, or nil to clear. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) lurek.log.info(tostring("after:" .. slot)) end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end
```

---

#### `LSaveManager:onBeforeSave`

Set a hook function called immediately before each save operation begins.

```lua
LSaveManager:onBeforeSave(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func?` | function | Callback receiving the slot name as its argument, or nil to clear. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onBeforeSave(function(slot) lurek.log.info(tostring("before:" .. slot)) end)
    mgr:save("hook_test")
    mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end
```

---

#### `LSaveManager:register`

Register a named data section with a collector and restorer function pair.

```lua
LSaveManager:register(name, collectFn, restoreFn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique section name identifying this chunk of save data (e.g. "player", "inventory"). |
| `collectFn` | function | Called with no arguments during save; must return the data to persist for this section. |
| `restoreFn` | function | Called with the saved value during load; responsible for applying it back to game state. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 75
    mgr:restore({ player = { hp = 120 } })
    lurek.log.info(tostring("collected player hp = " .. mgr:collect().player.hp))
    lurek.log.info(tostring("restored hp = " .. hp))
end
```

---

#### `LSaveManager:reset`

Completely reset the save manager: unregister all sections, clear migrations, hooks, compression, and dirty state.

```lua
LSaveManager:reset()
```

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:setSummary("temporary summary")
    mgr:setCompress(true)
    mgr:reset()
    lurek.log.info(tostring("summary after reset = " .. tostring(mgr:getSummary())))
    lurek.log.info(tostring("compressed after reset = " .. tostring(mgr:isCompressed())))
end
```

---

#### `LSaveManager:restore`

Apply a previously collected save-data table back into game state by invoking all registered restorers.

```lua
LSaveManager:restore(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | A save-data table (as produced by collect or loaded from disk). |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 50
    mgr:restore({ player = { hp = 100 } })
    lurek.log.info(tostring("restored hp = " .. hp))
end
```

---

#### `LSaveManager:save`

Persist all registered data sections to the named slot file on disk.

```lua
LSaveManager:save(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name (e.g. "slot1", "quicksave"). The file is stored as save/slots/slot_<name>.sav. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_save_slot"
    mgr:save(slot)
    lurek.log.info(tostring("saved to " .. slot))
    lurek.log.info(tostring("exists after save = " .. tostring(mgr:exists(slot))))
    mgr:delete(slot)
end
```

---

#### `LSaveManager:setCompress`

Enable or disable LZ4 compression for save files. Compressed saves are smaller on disk.

```lua
LSaveManager:setCompress(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to compress future saves, false to write plain text. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    lurek.log.info(tostring("before compress = " .. tostring(mgr:isCompressed())))
    mgr:setCompress(true)
    lurek.log.info(tostring("after enable = " .. tostring(mgr:isCompressed())))
    mgr:setCompress(false)
    lurek.log.info(tostring("after disable = " .. tostring(mgr:isCompressed())))
end
```

---

#### `LSaveManager:setFormat`

Set the payload serialization format for future saves and loads.

```lua
LSaveManager:setFormat(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Payload format name. |

**Example**

```lua
do

    local mgr = lurek.save.newManager()
    mgr:setFormat("json")
    local format = mgr:getFormat()
    mgr:setSummary("JSON save")
    lurek.log.info(tostring("save format = " .. format))
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
end
```

---

#### `LSaveManager:setSchemaVersion`

Set the current schema version number for saves produced by this game build.

```lua
LSaveManager:setSchemaVersion(version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `version` | number | Integer schema version (must increase with each breaking data format change). |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:setSchemaVersion(3)
    mgr:addMigration(1, function(data)
        data.player = data.player or {}
        data.player.maxHp = data.player.maxHp or 100
        return data
    end)
    mgr:addMigration(2, function(data)
        data.player = data.player or {}
        data.player.mana = data.player.mana or 50
        return data
    end)
    lurek.log.info(tostring("schema version = " .. mgr:getSchemaVersion()))
end
```

---

#### `LSaveManager:setSummary`

Set a human-readable summary string stored alongside save metadata (e.g. "Level 5 - Forest").

```lua
LSaveManager:setSummary(summary)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | string | Short description of the current game progress. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    lurek.log.info(tostring("summary before = " .. mgr:getSummary()))
    mgr:setSummary("Chapter 3 — The Dark Forest")
    lurek.log.info(tostring("summary = " .. mgr:getSummary()))
    mgr:setSchemaVersion(3)
    lurek.log.info(tostring("version = " .. mgr:getSchemaVersion()))
end
```

---

#### `LSaveManager:type`

Return the type name string for this userdata object.

```lua
LSaveManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LSaveManager](#lsavemanager)". |

**Example**

```lua
do

    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    sm:setSummary("Type Check")
    sm:register("state", function() return { ok = true } end, function(_) end)
    lurek.log.info(tostring("type = " .. sm:type()))
    lurek.log.info(tostring("sections = " .. tostring(sm:collect().state.ok)))
end
```

---

#### `LSaveManager:typeOf`

Check whether this object matches a given type name. Supports "[LSaveManager](#lsavemanager)" and "Object".

```lua
LSaveManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches the given type name. |

**Example**

```lua
do

    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    local is_save = sm:typeOf("LSaveManager")
    local is_object = sm:typeOf("LObject")
    local slots = sm:getSlots()
    lurek.log.info(tostring("is save manager = " .. tostring(is_save)))
    lurek.log.info(tostring("save slots now = " .. tostring(#slots)))
    lurek.log.info(tostring("is object = " .. tostring(is_object)))
    lurek.log.info(tostring("type = " .. sm:type()))
end
```

---

#### `LSaveManager:unregister`

Remove a previously registered data section by name, cleaning up its collector and restorer callbacks.

```lua
LSaveManager:unregister(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The section name to unregister. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:unregister("section_a")
    local data = mgr:collect()
    lurek.log.info(tostring("has section_a = " .. tostring(data.section_a ~= nil)))
    lurek.log.info(tostring("has section_b = " .. tostring(data.section_b ~= nil)))
end
```

---

#### `LSaveManager:update`

Advance the auto-save timer by dt seconds. Call this once per frame from your game loop.

```lua
LSaveManager:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since the last frame. |

**Returns**

| Type | Description |
|------|-------------|
| string | Auto-save slot name when save work is due, or nil when no flush is needed yet. |

**Example**

```lua
do

    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_update_slot"
    mgr:enableAutoSave(5.0, slot)
    mgr:markDirty()
    lurek.log.info(tostring("auto-save triggered = " .. tostring(mgr:update(6.0))))
    lurek.log.info(tostring("slot exists = " .. tostring(mgr:exists(slot))))
    if mgr:exists(slot) then
        mgr:delete(slot)
    end
end
```

---
