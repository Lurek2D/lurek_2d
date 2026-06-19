# save

## TL;DR

- Manages game saves with compression, auto-save timers, and schema migrations.

## General Info

- Module group: `Feature Systems`
- Source path: `src/save/`
- Binding: `src/lua_api/save_api.rs`
- Namespace: `lurek.save`
- Lua API surface: `1` functions, `3` types, `27` methods
- Rust test path(s): tests/rust/unit/save_tests.rs
- Lua test path(s): tests/lua/unit/test_save_unit.lua, tests/lua/stress/test_save_stress.lua, tests/lua/security/test_save_security.lua, tests/lua/integration/test_save_ecs_integration.lua, tests/lua/integration/test_save_tilemap_integration.lua, tests/lua/integration/test_save_ecs_scene_integration.lua

## Summary

- The `save` module is the persistence-lifecycle surface for users who want game state to be stored, versioned, and restored as a managed workflow instead of a raw file dump.
- Save managers, metadata, migration support, schema versions, and summary information work together so save files can evolve over time without every project rolling its own compatibility rules.
- That matters because persistence is usually more than writing bytes: projects also need naming, summaries, migration paths, and validation.
- It also needs a clear lifecycle for selecting, migrating, and restoring stored game state.
- Read `save` as the owner of save and load policy. Serialization modules decide how data is encoded, but `save` decides how game-state persistence is packaged, versioned, and coordinated for users.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### mod.rs

- `src/save/mod.rs` is the save module index, exposing the persistence surface that gameplay and Lua bindings consume.
- It reexports `SaveManager`, slot metadata, serialization helpers, compression helpers, and the save value tree.
- No runtime state lives here; this file keeps the public save boundary stable while logic stays in `save_manager.rs`.
- Read this index when a caller needs save APIs, because it shows which persistence symbols are intentionally public.
- The module groups table serialization, compressed slot payload handling, and manager-driven save orchestration together.
- Changes here alter the persistence boundary, since reexports decide what the engine and Lua layer may import.

### save_manager.rs

- `src/save/save_manager.rs` owns slot persistence: registration, dirty tracking, schema versioning, and restore flow.
- `SaveManager` decides which Lua tables join a slot, when writes should happen, and which migrations must run.
- The file also defines `SaveValue` and `SlotMeta`, so payload structure and save-select metadata share one owner.
- Compression, decompression, table serialization, and parsing live here to keep format logic near persistence policy.
- Auto-save timing and slot path construction are handled locally, keeping higher runtime layers free of save bookkeeping.
- The internal parser reads the restricted Lua table format emitted here, keeping load behavior aligned with save output.
- Neighboring systems matter here mainly at the runtime and binary utility boundary, not in modules that register state.
- Open this file when save format, migration routing, compression policy, or slot lifecycle behavior needs to change.



## Lua API Ref

### Functions

- `lurek.save.newSaveManager() -> LSaveManager`: Create a new SaveManager instance for managing persistent game saves.

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

- `LSaveManager:addMigration(fromVersion, func) -> nil`: Register a migration function that transforms save data from one schema version to the next.
- `LSaveManager:collect() -> table`: Invoke all registered collectors and return the assembled save-data table without writing to disk.
- `LSaveManager:delete(slot) -> nil`: Permanently delete a save slot file from disk. This action cannot be undone.
- `LSaveManager:disableAutoSave() -> nil`: Disable the periodic auto-save timer. Manual saves via save() still work.
- `LSaveManager:enableAutoSave(interval, slot) -> nil`: Enable periodic auto-saving: when the dirty flag is set, the system writes to the target slot every interval seconds.
- `LSaveManager:exists(slot) -> boolean`: Check whether a save slot file exists on disk without reading its contents.
- `LSaveManager:getSchemaVersion() -> integer`: Return the current schema version number set for this save manager.
- `LSaveManager:getSlotInfo(slot) -> table`: Read metadata for a single save slot without loading its full game state.
- `LSaveManager:getSlots() -> table`: List all save slots found on disk with their metadata (version, timestamp, summary).
- `LSaveManager:getSummary() -> string`: Get the current summary string that will be embedded in the next save.
- `LSaveManager:isCompressed() -> boolean`: Check whether save compression is currently enabled.
- `LSaveManager:isDirty() -> boolean`: Check whether unsaved changes exist since the last save or load.
- `LSaveManager:load(slot) -> boolean`: Load game state from a named slot file. Decompresses if needed, applies migrations, calls restorers, then fires onAfterLoad.
- `LSaveManager:markDirty() -> nil`: Mark the save state as dirty, indicating unsaved changes exist.
- `LSaveManager:onAfterLoad(func?) -> nil`: Set a hook function called immediately after a save file is successfully loaded and all restorers have run.
- `LSaveManager:onBeforeSave(func?) -> nil`: Set a hook function called immediately before each save operation begins.
- `LSaveManager:register(name, collectFn, restoreFn) -> nil`: Register a named data section with a collector and restorer function pair.
- `LSaveManager:reset() -> nil`: Completely reset the save manager: unregister all sections, clear migrations, hooks, compression, and dirty state.
- `LSaveManager:restore(data) -> nil`: Apply a previously collected save-data table back into game state by invoking all registered restorers.
- `LSaveManager:save(slot) -> nil`: Persist all registered data sections to the named slot file on disk.
- `LSaveManager:setCompress(enabled) -> nil`: Enable or disable LZ4 compression for save files. Compressed saves are smaller on disk.
- `LSaveManager:setSchemaVersion(version) -> nil`: Set the current schema version number for saves produced by this game build.
- `LSaveManager:setSummary(summary) -> nil`: Set a human-readable summary string stored alongside save metadata (e.g. "Level 5 â€“ Forest").
- `LSaveManager:type() -> string`: Return the type name string for this userdata object.
- `LSaveManager:typeOf(name) -> boolean`: Check whether this object matches a given type name. Supports "LSaveManager" and "Object".
- `LSaveManager:unregister(name) -> nil`: Remove a previously registered data section by name, cleaning up its collector and restorer callbacks.
- `LSaveManager:update(dt) -> string`: Advance the auto-save timer by dt seconds. Call this once per frame from your game loop.

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

## References

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
