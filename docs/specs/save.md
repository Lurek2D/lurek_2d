# save

## General Info

- Module group: `Feature Systems`
- Source path: `src/save/`
- Lua API path(s): `src/lua_api/save_api.rs`
- Primary Lua namespace: `lurek.save`
- Rust test path(s): tests/rust/unit/savegame_tests.rs
- Lua test path(s): tests/lua/unit/test_save.lua, tests/lua/stress/test_save_stress.lua, tests/lua/security/test_save_validation.lua, tests/lua/integration/test_save_ecs.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_save_ecs_scene.lua

## Summary

## Summary

The `save` module is Lurek2D's game save/load orchestration system — a Feature Systems tier module whose responsibility is lifecycle management: coordinating when and what to save, handling schema versioning, running migrations, and driving auto-save. Byte-level serialisation belongs to `serial`; file I/O belongs to `filesystem`. The `save` module calls both.

**SaveManager lifecycle.** `SaveManager` is the central coordinator. It maintains a registry of named collector modules, a current schema version integer, a dirty flag, optional auto-save configuration, and an ordered list of migration version checkpoints. Game code calls `register(name, gather_fn, restore_fn)` to install a named collector whose `gather()` callback returns a Lua table of game state and whose `restore(data)` callback reloads it. Multiple collectors can be registered for the same save slot (player state, world state, inventory, settings), each saving independently under their name key.

**Save flow.** `collect()` calls every registered `gather()` in registration order and assembles results into a slot data table with `SlotMeta` metadata: slot name, Unix timestamp, schema version integer, and a free-text summary string (e.g. "Chapter 2 – Forest of Shadows, 3h 42m"). This table is then passed to `serial` for TOML or Lua serialisation and to `filesystem` for write. `SaveValue` (nil, bool, number, string, table) is the Lua-serialisable value enum for Rust-side serialisation. `serialize_table` and `serialize_value` produce valid Lua return-statement strings from `SaveValue` trees, written to disk as `.lua` data files directly loadable with the Lua interpreter. `SaveValue::from_lua` converts `mlua::Value` to `SaveValue` for Rust-side processing before serialisation.

**Load and migration.** `restore(data)` reads the saved schema version from `SlotMeta`, determines which ordered migration checkpoints fall between the saved version and the current version, runs them in sequence (each migration receives the raw data table and returns a transformed copy), then calls every registered `restore()` callback. This migration chain transparently upgrades save files from older schema versions at load time without requiring external tooling. `register_migration(from_version, to_version, fn)` registers a migration step. Migrations are applied in version-ascending order.

**Dirty flag.** `mark_dirty()` signals that unsaved state exists. `is_dirty()` lets game code conditionally show a save indicator in the UI. The flag is cleared after a successful `write()`. Combined with auto-save, this prevents unnecessary writes when nothing has changed since the last save.

**Auto-save.** `enable_auto_save(interval_secs, slot_name)` activates timer-based background saves. `update(dt)` advances the timer each frame and returns `Some(slot_name)` when a save should fire — the caller (typically `app::GameLoop`) performs the actual write. `disable_auto_save()` stops background saves without affecting manual `write()` calls. Multiple save slots (e.g. three numbered slots plus an autosave slot) coexist under different names.

**Compression.** `compress_save_content(data, codec)` and `decompress_save_content(bytes, codec)` wrap the raw serialised string with a configurable compression codec (default: zstd), reducing disk usage for large save files with many registered collectors. The codec is stored in the file header so the correct decompressor is always used regardless of future codec changes.

**Slot introspection.** `list_slots(path)` scans a directory for save files and returns a list of `SlotMeta` tables without loading the full save data — used for save/load menus. `delete_slot(name)` removes a save file from disk. `slot_exists(name)` tests for existence without I/O.

**Note on dead code.** `save_data.rs` is present in the source tree but not declared in `mod.rs` and is dead code — it contains an older parallel copy of the same types. The canonical implementation lives entirely in `save_manager.rs`.

**Lua surface.** `lurek.save.register(name, gather_fn, restore_fn)`, `lurek.save.write(slot)`, `lurek.save.load(slot)`, `lurek.save.delete(slot)`, `lurek.save.exists(slot)` → bool, `lurek.save.list(dir)` → array of slot meta tables, `lurek.save.isDirty()`, `lurek.save.markDirty()`, `lurek.save.enableAutoSave(interval, slot)`, `lurek.save.disableAutoSave()`, `lurek.save.registerMigration(from, to, fn)`.

**Scope boundary.** Feature Systems tier. Depends on `filesystem` (file read/write), `serial` (serialisation), `runtime` (SharedState). Lua bridge in `src/lua_api/save_api.rs`.

**Scope boundary**: Feature Systems tier. Depends on `filesystem`, `runtime`,
`serial`. Lua bridge in `src/lua_api/save_api.rs` as `lurek.save.*`.

## Files

- `mod.rs`: Declares the save submodules and re-exports the public save manager, value, metadata, serialization-facing types, and compression helpers.
- `save_data.rs`: Holds an alternate save-data type definition set that currently lives in the module tree but is not the primary surface re-exported from `mod.rs`.
- `save_manager.rs`: Implements `SaveManager`, slot metadata, schema versioning, dirty tracking, collector registration, restore hooks, auto-save timing, and save-file compression helpers (`compress_save_content`, `decompress_save_content`).

## Types

- `SlotMeta` (`struct`, `save_data.rs`): Metadata describing a save slot, such as name, timestamp, version, and summary fields.
- `SaveManager` (`struct`, `save_data.rs`): The central save coordination object. It owns collectors, restore callbacks, schema versioning, dirty state, auto-save timers, and slot metadata handling.
- `SaveValue` (`enum`, `save_data.rs`): The Lua-serializable value enum used to represent saved data trees without depending on arbitrary engine internals.
- `SlotMeta` (`struct`, `save_manager.rs`): Metadata describing a save slot, such as name, timestamp, version, and summary fields.
- `SaveManager` (`struct`, `save_manager.rs`): The central save coordination object. It owns collectors, restore callbacks, schema versioning, dirty state, auto-save timers, and slot metadata handling.
- `SaveValue` (`enum`, `save_manager.rs`): The Lua-serializable value enum used to represent saved data trees without depending on arbitrary engine internals.

## Functions

- `SaveManager::new` (`save_data.rs`): Create a new empty SaveManager.
- `SaveManager::register` (`save_data.rs`): Register a named collector module.
- `SaveManager::unregister` (`save_data.rs`): Removes a previously registered data collector from the save/restore cycle.
- `SaveManager::registered_names` (`save_data.rs`): Get registered module names.
- `SaveManager::set_schema_version` (`save_data.rs`): Set the current schema version.
- `SaveManager::schema_version` (`save_data.rs`): Returns the schema version number used to detect save-file format upgrades.
- `SaveManager::add_migration` (`save_data.rs`): Record a migration version key.
- `SaveManager::applicable_migrations` (`save_data.rs`): Get migration versions >=`from` and < current, in ascending order.
- `SaveManager::mark_dirty` (`save_data.rs`): Mark data as dirty (modified since last save/load).
- `SaveManager::is_dirty` (`save_data.rs`): Whether data is dirty.
- `SaveManager::clear_dirty` (`save_data.rs`): Clear the dirty flag (called after save/load).
- `SaveManager::enable_auto_save` (`save_data.rs`): Enable auto-save with interval and target slot.
- `SaveManager::disable_auto_save` (`save_data.rs`): Disables the automatic save timer, preventing any further background saves.
- `SaveManager::update` (`save_data.rs`): Advance the auto-save timer.
- `SaveManager::reset` (`save_data.rs`): Reset all state.
- `serialize_table` (`save_data.rs`): Serialize a simple Lua-compatible value hierarchy into a `return { ...
- `serialize_value` (`save_data.rs`): Serialize a single value.
- `SaveManager::new` (`save_manager.rs`): Create a new empty SaveManager.
- `SaveManager::register` (`save_manager.rs`): Register a named collector module.
- `SaveManager::unregister` (`save_manager.rs`): Unregister a collector by name.
- `SaveManager::registered_names` (`save_manager.rs`): Get registered module names.
- `SaveManager::set_schema_version` (`save_manager.rs`): Set the current schema version.
- `SaveManager::schema_version` (`save_manager.rs`): Get the current schema version.
- `SaveManager::add_migration` (`save_manager.rs`): Record a migration version key.
- `SaveManager::applicable_migrations` (`save_manager.rs`): Get migration versions >=`from` and < current, in ascending order.
- `SaveManager::mark_dirty` (`save_manager.rs`): Mark data as dirty (modified since last save/load).
- `SaveManager::is_dirty` (`save_manager.rs`): Whether data is dirty.
- `SaveManager::clear_dirty` (`save_manager.rs`): Clear the dirty flag (called after save/load).
- `SaveManager::enable_auto_save` (`save_manager.rs`): Enable auto-save with interval and target slot.
- `SaveManager::disable_auto_save` (`save_manager.rs`): Disable auto-save.
- `SaveManager::update` (`save_manager.rs`): Advance the auto-save timer.
- `SaveManager::reset` (`save_manager.rs`): Reset all state.
- `SaveManager::slot_path` (`save_manager.rs`): Build the save file path for a given slot name.
- `SaveManager::set_summary` (`save_manager.rs`): Set the summary string for save metadata.
- `SaveManager::summary` (`save_manager.rs`): Get the summary string.
- `SaveManager::parse_save_string` (`save_manager.rs`): Validates and returns save-file content, rejecting empty input.
- `serialize_table` (`save_manager.rs`): Serialize a simple Lua-compatible value hierarchy into a `return { ...
- `serialize_value` (`save_manager.rs`): Serialize a single value.
- `SaveValue::from_lua` (`save_manager.rs`): Converts a [`LuaValue`] into a [`SaveValue`] for Rust-side serialization.
- `compress_save_content` (`save_manager.rs`): Compress a serialised save string with LZ4, then base64-encode it.
- `decompress_save_content` (`save_manager.rs`): Detect and decode a compressed save file, or pass through an uncompressed one.

## Lua API Reference

- Binding path(s): `src/lua_api/save_api.rs`
- Namespace: `lurek.save`

### Module Functions
- `lurek.save.newSaveManager`: Creates a new SaveManager for slot-based save/load operations.

### `SaveManager` Methods
- `SaveManager:unregister`: Removes a named module and its callbacks
- `SaveManager:setSchemaVersion`: Sets the current schema version for new saves
- `SaveManager:getSchemaVersion`: Returns the current schema version
- `SaveManager:collect`: Collects data from all registered collectors into a table with metadata
- `SaveManager:restore`: Restores data from a table, applying migrations and calling restorers
- `SaveManager:markDirty`: Marks data as modified since the last save or load
- `SaveManager:isDirty`: Returns whether data has been modified since the last save or load
- `SaveManager:disableAutoSave`: Disables automatic periodic saving; manual `write()` calls still work.
- `SaveManager:update`: Advances the auto-save timer, returning the slot name if a save should trigger
- `SaveManager:setSummary`: Sets the summary string included in save metadata
- `SaveManager:getSummary`: Returns the current summary string
- `SaveManager:reset`: Resets all state, removing callbacks and clearing the manager
- `SaveManager:setCompress`: Enables or disables LZ4 compression for saved data
- `SaveManager:isCompressed`: Returns whether compression is currently enabled.
- `SaveManager:onBeforeSave`: Registers a callback that fires before every save operation.
- `SaveManager:onAfterLoad`: Registers a callback that fires after every successful load operation.
- `SaveManager:save`: Collects data and writes it to a slot file.
- `SaveManager:load`: Loads data from a slot file, applies migrations, and restores.
- `SaveManager:delete`: Deletes a save file for the given slot.
- `SaveManager:getSlots`: Returns a list of all save slots with metadata.
- `SaveManager:getSlotInfo`: Returns metadata for a single slot, or nil if not found.

## References

- `data`: Imports or references `src/data/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/save/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
