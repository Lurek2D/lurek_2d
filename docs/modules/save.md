# Save

- The `save` module is an essential Feature Systems tier component that provides a robust, slot-based persistent save management system for Lurek2D.

It enables developers to reliably save and load game state with built-in support for compression, file rotation, and schema versioning. The architecture is built around the `SaveManager`, which coordinates persistence using a named-section approach. Developers register game modules (like inventory, player stats, or level state) by assigning a string name and providing paired `collect` and `restore` Lua callback functions. During a save operation, the manager queries these collectors to gather the current game state as a Lua table; during load, the state is passed back via the restorers.

To optimize performance and minimize disk wear, the system employs dirty tracking. Writes are entirely skipped unless the state is explicitly marked as dirty (changed). An auto-save scheduler can be configured to automatically persist the dirty state to a designated slot at regular intervals. When writing to disk, the `save` module uses a custom serialization format that converts Lua tables into a Rust `SaveValue` tree, emitting valid Lua-literal text. To ensure small file sizes, this text is subsequently compressed using LZ4 and Base64 encoded before being written. The manager also handles slot file rotation, automatically maintaining a configurable number of backup copies for data safety.

Crucially, the module provides robust tools for long-term game maintenance via schema versioning and data migrations. Each save file is stamped with a schema version number. If the game is updated and the schema advances, registered migration functions are automatically invoked in sequence to upgrade older save data to the current schema before it is handed back to the `restore` callbacks. Additionally, the system generates lightweight `SlotMeta` metadata for each save slot—including timestamps, play time, and human-readable summary strings (e.g., 'Level 5 – Forest')—enabling UI save-select screens to display save info instantly without needing to deserialize the entire game state. The comprehensive `lurek.save.*` API gives Lua scripts full control over this powerful persistence engine.

## Functions

### `lurek.save.newSaveManager`

Create a new SaveManager instance for managing persistent game saves.

```lua
-- signature
lurek.save.newSaveManager()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSaveManager` | A fresh save manager with no registered sections. |

**Example**

```lua
do
    ---@type LSaveManager
    local mgr = lurek.save.newSaveManager()
    print("type = " .. mgr:type())
    print("is LSaveManager = " .. tostring(mgr:typeOf("LSaveManager")))
end
```

---

## LSaveManager

### `LSaveManager:addMigration`

Register a migration function that transforms save data from one schema version to the next.

```lua
-- signature
LSaveManager:addMigration(fromVersion, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fromVersion` | `number` | The schema version this migration upgrades FROM (it produces fromVersion+1). |
| `func` | `function` | Receives the full save data table and must return the transformed table. |

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
    print("schema version = " .. mgr:getSchemaVersion())
end
```

---

### `LSaveManager:collect`

Invoke all registered collectors and return the assembled save-data table without writing to disk.

```lua
-- signature
LSaveManager:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | The full save-data table including __schema_version, __timestamp, and __summary metadata. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    print("collected player hp = " .. mgr:collect().player.hp)
end
```

---

### `LSaveManager:delete`

Permanently delete a save slot file from disk. This action cannot be undone.

```lua
-- signature
LSaveManager:delete(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | `string` | Slot name to delete (e.g. "slot1"). |

**Returns**

| Type | Description |
|------|-------------|
| `nil` | No return value. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_delete_slot"
    mgr:save(slot)
    mgr:delete(slot)
    print("after delete exists = " .. tostring(mgr:exists(slot)))
end
```

---

### `LSaveManager:disableAutoSave`

Disable the periodic auto-save timer. Manual saves via save() still work.

```lua
-- signature
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
    print("after disable triggered = " .. tostring(mgr:update(6.0)))
end
```

---

### `LSaveManager:enableAutoSave`

Enable periodic auto-saving: when the dirty flag is set, the system writes to the target slot every interval seconds.

```lua
-- signature
LSaveManager:enableAutoSave(interval, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | `number` | Time in seconds between auto-save checks (e.g. 30.0 for every 30 seconds). |
| `slot` | `string` | The slot name to auto-save into (e.g. "autosave"). |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_autosave_slot"
    mgr:enableAutoSave(5.0, "autosave")
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0)))
    print("autosave exists = " .. tostring(mgr:exists("autosave")))
    pcall(function() mgr:delete("autosave") end)
end
```

---

### `LSaveManager:exists`

Check whether a save slot file exists on disk without reading its contents.

```lua
-- signature
LSaveManager:exists(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | `string` | Slot name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the slot file is present. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_exists_slot"
    mgr:save(slot)
    print("exists = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end
```

---

### `LSaveManager:getSchemaVersion`

Return the current schema version number set for this save manager.

```lua
-- signature
LSaveManager:getSchemaVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The active schema version. |

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
    print("schema version = " .. mgr:getSchemaVersion())
end
```

---

### `LSaveManager:getSlotInfo`

Read metadata for a single save slot without loading its full game state.

```lua
-- signature
LSaveManager:getSlotInfo(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | `string` | Slot name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `LSaveManagerGetSlotInfoResult` | Info table with fields: slot, version, timestamp, summary, or nil if not found. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slot_info"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local info = mgr:getSlotInfo(slot)
    print("slot info = " .. tostring(info and info.slot))
    print("summary = " .. tostring(info and info.summary))
    mgr:delete(slot)
end
```

---

### `LSaveManager:getSlots`

List all save slots found on disk with their metadata (version, timestamp, summary).

```lua
-- signature
LSaveManager:getSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSaveManagerGetSlotsResult` | Array of info tables, each with fields: slot, version, timestamp, summary. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("data", function() return { level = 5 } end, function(_) end)
    local slot = "example_slots_slot"
    mgr:setSummary("Level 5 - Forest")
    mgr:save(slot)
    local slots = mgr:getSlots()
    print("slot count = " .. #slots)
    print("first slot = " .. tostring(slots[1] and slots[1].slot))
    mgr:delete(slot)
end
```

---

### `LSaveManager:getSummary`

Get the current summary string that will be embedded in the next save.

```lua
-- signature
LSaveManager:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The summary text, or an empty string if none was set. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
end
```

---

### `LSaveManager:isCompressed`

Check whether save compression is currently enabled.

```lua
-- signature
LSaveManager:isCompressed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if future saves will be LZ4-compressed. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
end
```

---

### `LSaveManager:isDirty`

Check whether unsaved changes exist since the last save or load.

```lua
-- signature
LSaveManager:isDirty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if game state has been modified and not yet persisted. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
end
```

---

### `LSaveManager:load`

Load game state from a named slot file. Decompresses if needed, applies migrations, calls restorers, then fires onAfterLoad.

```lua
-- signature
LSaveManager:load(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | `string` | Slot name to load (e.g. "slot1"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True if the load succeeded, false on error. |
| `string` | b Error message if the load failed, nil on success. |

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
    print("load ok = " .. tostring(ok))
    print("load err = " .. tostring(err))
    print("score = " .. score)
    mgr:delete(slot)
end
```

---

### `LSaveManager:markDirty`

Mark the save state as dirty, indicating unsaved changes exist.

```lua
-- signature
LSaveManager:markDirty()
```

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    print("dirty = " .. tostring(mgr:isDirty()))
    mgr:markDirty()
    print("after markDirty = " .. tostring(mgr:isDirty()))
end
```

---

### `LSaveManager:onAfterLoad`

Set a hook function called immediately after a save file is successfully loaded and all restorers have run.

```lua
-- signature
LSaveManager:onAfterLoad(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func?` | `function` | Callback receiving the slot name as its argument, or nil to clear. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onAfterLoad(function(slot) print("after:" .. slot) end)
    mgr:save("hook_test")
    mgr:load("hook_test")
    mgr:onAfterLoad(nil)
    mgr:delete("hook_test")
end
```

---

### `LSaveManager:onBeforeSave`

Set a hook function called immediately before each save operation begins.

```lua
-- signature
LSaveManager:onBeforeSave(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func?` | `function` | Callback receiving the slot name as its argument, or nil to clear. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("state", function() return { x = 10, y = 20 } end, function(_) end)
    mgr:onBeforeSave(function(slot) print("before:" .. slot) end)
    mgr:save("hook_test")
    mgr:onBeforeSave(nil)
    mgr:delete("hook_test")
end
```

---

### `LSaveManager:register`

Register a named data section with a collector and restorer function pair.

```lua
-- signature
LSaveManager:register(name, collectFn, restoreFn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique section name identifying this chunk of save data (e.g. "player", "inventory"). |
| `collectFn` | `function` | Called with no arguments during save; must return the data to persist for this section. |
| `restoreFn` | `function` | Called with the saved value during load; responsible for applying it back to game state. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    print("collected player hp = " .. mgr:collect().player.hp)
end
```

---

### `LSaveManager:reset`

Completely reset the save manager: unregister all sections, clear migrations, hooks, compression, and dirty state.

```lua
-- signature
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
    print("summary after reset = " .. tostring(mgr:getSummary()))
    print("compressed after reset = " .. tostring(mgr:isCompressed()))
end
```

---

### `LSaveManager:restore`

Apply a previously collected save-data table back into game state by invoking all registered restorers.

```lua
-- signature
LSaveManager:restore(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | A save-data table (as produced by collect or loaded from disk). |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    local hp = 100
    mgr:register("player", function() return { hp = hp } end, function(data) hp = data.hp end)
    hp = 50
    mgr:restore({ player = { hp = 100 } })
    print("restored hp = " .. hp)
end
```

---

### `LSaveManager:save`

Persist all registered data sections to the named slot file on disk.

```lua
-- signature
LSaveManager:save(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | `string` | Slot name (e.g. "slot1", "quicksave"). The file is stored as save/slot_<name>.sav. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("score", function() return { value = 9999 } end, function(_) end)
    local slot = "example_save_slot"
    mgr:save(slot)
    print("saved to " .. slot)
    print("exists after save = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end
```

---

### `LSaveManager:setCompress`

Enable or disable LZ4 compression for save files. Compressed saves are smaller on disk.

```lua
-- signature
LSaveManager:setCompress(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to compress future saves, false to write plain text. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:setCompress(true)
    print("after enable = " .. tostring(mgr:isCompressed()))
end
```

---

### `LSaveManager:setSchemaVersion`

Set the current schema version number for saves produced by this game build.

```lua
-- signature
LSaveManager:setSchemaVersion(version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `version` | `number` | Integer schema version (must increase with each breaking data format change). |

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
    print("schema version = " .. mgr:getSchemaVersion())
end
```

---

### `LSaveManager:setSummary`

Set a human-readable summary string stored alongside save metadata (e.g. "Level 5 – Forest").

```lua
-- signature
LSaveManager:setSummary(summary)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | `string` | Short description of the current game progress. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:setSummary("Chapter 3 — The Dark Forest")
    print("summary = " .. mgr:getSummary())
end
```

---

### `LSaveManager:type`

Return the type name string for this userdata object.

```lua
-- signature
LSaveManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LSaveManager". |

**Example**

```lua
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print("type = " .. sm:type())
end
```

---

### `LSaveManager:typeOf`

Check whether this object matches a given type name. Supports "LSaveManager" and "Object".

```lua
-- signature
LSaveManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches the given type name. |

**Example**

```lua
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print("is save manager = " .. tostring(sm:typeOf("LSaveManager")))
    print("is object = " .. tostring(sm:typeOf("LObject")))
end
```

---

### `LSaveManager:unregister`

Remove a previously registered data section by name, cleaning up its collector and restorer callbacks.

```lua
-- signature
LSaveManager:unregister(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The section name to unregister. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("section_a", function() return {} end, function(_) end)
    mgr:register("section_b", function() return {} end, function(_) end)
    mgr:unregister("section_a")
    local data = mgr:collect()
    print("has section_a = " .. tostring(data.section_a ~= nil))
    print("has section_b = " .. tostring(data.section_b ~= nil))
end
```

---

### `LSaveManager:update`

Advance the auto-save timer by dt seconds. Call this once per frame from your game loop.

```lua
-- signature
LSaveManager:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds since the last frame. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if an auto-save was triggered during this update. |

**Example**

```lua
do
    local mgr = lurek.save.newSaveManager()
    mgr:register("counter", function() return { value = 1 } end, function(_) end)
    local slot = "example_update_slot"
    mgr:enableAutoSave(5.0, slot)
    mgr:markDirty()
    print("auto-save triggered = " .. tostring(mgr:update(6.0)))
    print("slot exists = " .. tostring(mgr:exists(slot)))
    mgr:delete(slot)
end
```

---
