# save

## TL;DR

- The `save` module gives one safe, slot-based save flow for games: collect state from many systems, persist it, migrate old versions, and restore it reliably.

## General Info

- Module group: `Feature Systems`
- Source path: `src/save/`
- Binding: `src/lua_api/save_api.rs`
- Namespace: `lurek.save`
- Lua API surface: `1` functions, `3` types, `27` methods
- Rust test path(s): tests/rust/unit/savegame_tests.rs
- Lua test path(s): tests/lua/unit/test_save.lua, tests/lua/stress/test_save_stress.lua, tests/lua/security/test_save_validation.lua, tests/lua/integration/test_save_ecs.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_save_ecs_scene.lua

## Summary

The `save` module is the persistence contract for gameplay state. It lets teams collect data from many systems, store it in named slots, and restore it later through one stable flow.

Instead of forcing one monolithic save script, it supports section-based collection and restore callbacks. This keeps save ownership close to each gameplay feature while still producing one coherent save payload.

Write behavior is practical for runtime use: state can be marked dirty, unnecessary writes can be skipped, and auto-save can run on interval. This protects progress without constant disk churn.

Slot metadata is available without full data load, so save-selection UI can show summaries and timestamps quickly. Backup rotation and compression are integrated to improve resilience and reduce storage cost.

In practice, `lurek.save` gives one managed persistence layer: collect, persist, migrate and restore state predictably

## Imports

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### mod.rs

- This module provides the save-system surface for collecting game state, storing it by slot, and restoring it later.
- It combines persistence, compression, backup rotation, and migration support under one gameplay-facing feature stack.
- At the highest level this is the engine subsystem that turns live Lua state into durable save slots.

### save_manager.rs

- This file implements the practical save manager that coordinates collection, serialization, persistence, and restoration of game state.
- Registered sections let different gameplay systems contribute their own data while still producing one coherent slot payload.
- Dirty tracking and auto-save timing live here so disk writes happen when needed instead of on every frame or every small state change.
- Schema versioning and migration routing are also handled here, which lets older saves evolve forward as projects change over time.
- Serialization and compression are part of the same flow so slot files remain structured, compact, and easy to validate on load.
- The file is therefore the operational core of persistence for games built on the engine.

## Lua API Ref

### Functions

- `lurek.save.newSaveManager`: Create a new SaveManager instance for managing persistent game saves.

### Callbacks

- `LSaveManager:addMigration` param `func` (`function`): Receives the full save data table and must return the transformed table.
- `LSaveManager:onAfterLoad` param `func` (`function?`): Callback receiving the slot name as its argument, or nil to clear.
- `LSaveManager:onBeforeSave` param `func` (`function?`): Callback receiving the slot name as its argument, or nil to clear.
- `LSaveManager:register` param `collectFn` (`function`): Called with no arguments during save; must return the data to persist for this section.
- `LSaveManager:register` param `restoreFn` (`function`): Called with the saved value during load; responsible for applying it back to game state.

### Enums

- No documented module-level enums/constants.

### Types

#### LSaveManager Type

- Manages persistent game state: registering data collectors/restorers, serializing to named.

##### Fields

- No documented fields.

##### Methods

- `LSaveManager:addMigration`: Register a migration function that transforms save data from one schema version to the next.
- `LSaveManager:collect`: Invoke all registered collectors and return the assembled save-data table without writing to disk.
- `LSaveManager:delete`: Permanently delete a save slot file from disk. This action cannot be undone.
- `LSaveManager:disableAutoSave`: Disable the periodic auto-save timer. Manual saves via save() still work.
- `LSaveManager:enableAutoSave`: Enable periodic auto-saving: when the dirty flag is set, the system writes to the target slot every interval seconds.
- `LSaveManager:exists`: Check whether a save slot file exists on disk without reading its contents.
- `LSaveManager:getSchemaVersion`: Return the current schema version number set for this save manager.
- `LSaveManager:getSlotInfo`: Read metadata for a single save slot without loading its full game state.
- `LSaveManager:getSlots`: List all save slots found on disk with their metadata (version, timestamp, summary).
- `LSaveManager:getSummary`: Get the current summary string that will be embedded in the next save.
- `LSaveManager:isCompressed`: Check whether save compression is currently enabled.
- `LSaveManager:isDirty`: Check whether unsaved changes exist since the last save or load.
- `LSaveManager:load`: Load game state from a named slot file. Decompresses if needed, applies migrations, calls restorers, then fires onAfterLoad.
- `LSaveManager:markDirty`: Mark the save state as dirty, indicating unsaved changes exist.
- `LSaveManager:onAfterLoad`: Set a hook function called immediately after a save file is successfully loaded and all restorers have run.
- `LSaveManager:onBeforeSave`: Set a hook function called immediately before each save operation begins.
- `LSaveManager:register`: Register a named data section with a collector and restorer function pair.
- `LSaveManager:reset`: Completely reset the save manager: unregister all sections, clear migrations, hooks, compression, and dirty state.
- `LSaveManager:restore`: Apply a previously collected save-data table back into game state by invoking all registered restorers.
- `LSaveManager:save`: Persist all registered data sections to the named slot file on disk.
- `LSaveManager:setCompress`: Enable or disable LZ4 compression for save files. Compressed saves are smaller on disk.
- `LSaveManager:setSchemaVersion`: Set the current schema version number for saves produced by this game build.
- `LSaveManager:setSummary`: Set a human-readable summary string stored alongside save metadata (e.g. "Level 5 â€“ Forest").
- `LSaveManager:type`: Return the type name string for this userdata object.
- `LSaveManager:typeOf`: Check whether this object matches a given type name. Supports "LSaveManager" and "Object".
- `LSaveManager:unregister`: Remove a previously registered data section by name, cleaning up its collector and restorer callbacks.
- `LSaveManager:update`: Advance the auto-save timer by dt seconds. Call this once per frame from your game loop.

#### LSaveManagerGetSlotInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `slot` (`string`): Slot name.
- `summary` (`string`): Save summary.
- `timestamp` (`integer`): Save timestamp.
- `version` (`integer`): Schema version.

##### Methods

- No documented methods.

#### LSaveManagerGetSlotsResult Type

- Generated result shape from @field tags.

##### Fields

- `slot` (`string`): Slot name.
- `summary` (`string`): Save summary.
- `timestamp` (`integer`): Save timestamp.
- `version` (`integer`): Schema version.

##### Methods

- No documented methods.
