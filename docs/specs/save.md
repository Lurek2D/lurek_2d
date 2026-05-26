# save

## TL;DR

- The `save` module is an essential Feature Systems tier component that provides a robust, slot-based persistent save management system for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/save/`
- Lua API path(s): `src/lua_api/save_api.rs`
- Primary Lua namespace: `lurek.save`
- Rust test path(s): tests/rust/unit/savegame_tests.rs
- Lua test path(s): tests/lua/unit/test_save.lua, tests/lua/stress/test_save_stress.lua, tests/lua/security/test_save_validation.lua, tests/lua/integration/test_save_ecs.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_save_ecs_scene.lua

## Summary

 It enables developers to reliably save and load game state with built-in support for compression, file rotation, and schema versioning. The architecture is built around the `SaveManager`, which coordinates persistence using a named-section approach. Developers register game modules (like inventory, player stats, or level state) by assigning a string name and providing paired `collect` and `restore` Lua callback functions. During a save operation, the manager queries these collectors to gather the current game state as a Lua table; during load, the state is passed back via the restorers.

To optimize performance and minimize disk wear, the system employs dirty tracking. Writes are entirely skipped unless the state is explicitly marked as dirty (changed). An auto-save scheduler can be configured to automatically persist the dirty state to a designated slot at regular intervals. When writing to disk, the `save` module uses a custom serialization format that converts Lua tables into a Rust `SaveValue` tree, emitting valid Lua-literal text. To ensure small file sizes, this text is subsequently compressed using LZ4 and Base64 encoded before being written. The manager also handles slot file rotation, automatically maintaining a configurable number of backup copies for data safety.

Crucially, the module provides robust tools for long-term game maintenance via schema versioning and data migrations. Each save file is stamped with a schema version number. If the game is updated and the schema advances, registered migration functions are automatically invoked in sequence to upgrade older save data to the current schema before it is handed back to the `restore` callbacks. Additionally, the system generates lightweight `SlotMeta` metadata for each save slot—including timestamps, play time, and human-readable summary strings (e.g., 'Level 5 – Forest')—enabling UI save-select screens to display save info instantly without needing to deserialize the entire game state. The comprehensive `lurek.save.*` API gives Lua scripts full control over this powerful persistence engine.

## Source Documentation

### `mod.rs`
- Slot-based save/load with compression and rotation
- Serialize Lua tables to binary SaveValue format
- Backup management with configurable slot count

### `save_manager.rs`
- Dirty-tracking, auto-save scheduling, and schema-versioned migration for `lurek.save`.
- `SaveManager` owns registration of Lua tables, auto-save interval logic, and migration routing.
- `SaveValue` tree converts between Lua tables and a serializable Rust enum.
- Serialization emits Lua table literals; compression uses LZ4 + Base64 with a marker header.
- Slot file naming, parse validation, and summary forwarding to `SlotMeta`.

## Types

- `SlotMeta` (`struct`, `save_manager.rs`): Metadata describing a save slot, such as name, timestamp, version, and summary fields.
- `SaveManager` (`struct`, `save_manager.rs`): The central save coordination object. It owns collectors, restore callbacks, schema versioning, dirty state, auto-save timers, and slot metadata handling.
- `SaveValue` (`enum`, `save_manager.rs`): The Lua-serializable value enum used to represent saved data trees without depending on arbitrary engine internals.

## Functions

- `SaveManager::new` (`save_manager.rs`): Create a new default `SaveManager` and log its construction.
- `SaveManager::register` (`save_manager.rs`): Register a Lua table name for persistence; no-op if already registered.
- `SaveManager::unregister` (`save_manager.rs`): Remove a previously registered table name; silent no-op if not found.
- `SaveManager::registered_names` (`save_manager.rs`): Return the slice of currently registered table names.
- `SaveManager::set_schema_version` (`save_manager.rs`): Set the current schema version used for migration selection.
- `SaveManager::schema_version` (`save_manager.rs`): Return the current schema version.
- `SaveManager::add_migration` (`save_manager.rs`): Record a migration entry-point version; keeps the list sorted, ignores duplicates.
- `SaveManager::applicable_migrations` (`save_manager.rs`): Return all migration versions in `[from, schema_version)` that should be applied.
- `SaveManager::mark_dirty` (`save_manager.rs`): Set the dirty flag, signalling that unsaved changes exist.
- `SaveManager::is_dirty` (`save_manager.rs`): Return true when unsaved changes exist.
- `SaveManager::clear_dirty` (`save_manager.rs`): Clear the dirty flag after a successful save.
- `SaveManager::enable_auto_save` (`save_manager.rs`): Enable auto-save to `slot` every `interval` seconds when dirty; resets elapsed counter.
- `SaveManager::disable_auto_save` (`save_manager.rs`): Disable auto-save and reset the elapsed timer.
- `SaveManager::update` (`save_manager.rs`): Advance the auto-save timer by `dt` seconds; return the slot name to save when due, else `None`.
- `SaveManager::reset` (`save_manager.rs`): Reset all fields to defaults, clearing registrations and dirty state.
- `SaveManager::slot_path` (`save_manager.rs`): Return the canonical file path for `slot`, e.g.
- `SaveManager::set_summary` (`save_manager.rs`): Store the human-readable summary written into the next `SlotMeta`.
- `SaveManager::summary` (`save_manager.rs`): Return the current summary string.
- `SaveManager::parse_save_string` (`save_manager.rs`): Validate that `content` is non-empty and return it unchanged; return `Err` on empty input.
- `serialize_table` (`save_manager.rs`): Serialize a simple Lua-compatible value hierarchy into a `return { ...
- `serialize_value` (`save_manager.rs`): Serialize a single value.
- `SaveValue::from_lua` (`save_manager.rs`): Convert a `LuaValue` into `SaveValue`; return `LuaError` for unsupported types or non-string table keys.
- `compress_save_content` (`save_manager.rs`): Compress a serialised save string with LZ4, then base64-encode it.
- `decompress_save_content` (`save_manager.rs`): Detect and decode a compressed save file, or pass through an uncompressed one.

## Lua API Reference

- Binding path(s): `src/lua_api/save_api.rs`
- Namespace: `lurek.save`

### Module Functions
- `lurek.save.newSaveManager`: Create a new SaveManager instance for managing persistent game saves.

### `LSaveManager` Methods
- `LSaveManager:register`: Register a named data section with a collector and restorer function pair.
- `LSaveManager:unregister`: Remove a previously registered data section by name, cleaning up its collector and restorer callbacks.
- `LSaveManager:setSchemaVersion`: Set the current schema version number for saves produced by this game build.
- `LSaveManager:getSchemaVersion`: Return the current schema version number set for this save manager.
- `LSaveManager:addMigration`: Register a migration function that transforms save data from one schema version to the next.
- `LSaveManager:collect`: Invoke all registered collectors and return the assembled save-data table without writing to disk.
- `LSaveManager:restore`: Apply a previously collected save-data table back into game state by invoking all registered restorers.
- `LSaveManager:markDirty`: Mark the save state as dirty, indicating unsaved changes exist.
- `LSaveManager:isDirty`: Check whether unsaved changes exist since the last save or load.
- `LSaveManager:enableAutoSave`: Enable periodic auto-saving: when the dirty flag is set, the system writes to the target slot every interval seconds.
- `LSaveManager:disableAutoSave`: Disable the periodic auto-save timer. Manual saves via save() still work.
- `LSaveManager:update`: Advance the auto-save timer by dt seconds. Call this once per frame from your game loop.
- `LSaveManager:setSummary`: Set a human-readable summary string stored alongside save metadata (e.g. "Level 5 – Forest").
- `LSaveManager:getSummary`: Get the current summary string that will be embedded in the next save.
- `LSaveManager:reset`: Completely reset the save manager: unregister all sections, clear migrations, hooks, compression, and dirty state.
- `LSaveManager:setCompress`: Enable or disable LZ4 compression for save files. Compressed saves are smaller on disk.
- `LSaveManager:isCompressed`: Check whether save compression is currently enabled.
- `LSaveManager:onBeforeSave`: Set a hook function called immediately before each save operation begins.
- `LSaveManager:onAfterLoad`: Set a hook function called immediately after a save file is successfully loaded and all restorers have run.
- `LSaveManager:save`: Persist all registered data sections to the named slot file on disk.
- `LSaveManager:load`: Load game state from a named slot file. Decompresses if needed, applies migrations, calls restorers, then fires onAfterLoad.
- `LSaveManager:delete`: Permanently delete a save slot file from disk. This action cannot be undone.
- `LSaveManager:exists`: Check whether a save slot file exists on disk without reading its contents.
- `LSaveManager:getSlots`: List all save slots found on disk with their metadata (version, timestamp, summary).
- `LSaveManager:getSlotInfo`: Read metadata for a single save slot without loading its full game state.
- `LSaveManager:type`: Return the type name string for this userdata object.
- `LSaveManager:typeOf`: Check whether this object matches a given type name. Supports "LSaveManager" and "Object".

## References

- `data`: Imports or references `src/data/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/save/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
