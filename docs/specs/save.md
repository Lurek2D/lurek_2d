<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/save.md or source docstrings instead. -->

# save

## TL;DR

- Manages game saves with compression, auto-save timers, and schema migrations.

## General Info

- Module group: `Feature Systems`
- Source path: `src/save`
- Binding: `src/lua_api/save_api.rs`
- Namespace: `lurek.save`
- Lua API surface: `2` functions, `3` types, `29` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `save` module is the persistence-lifecycle surface for users who want game state to be stored, versioned, and restored as a managed workflow instead of a raw file dump.
- Save managers, metadata, migration support, schema versions, and summary information work together so save files can evolve over time without every project rolling its own compatibility rules.
- That matters because persistence is usually more than writing bytes: projects also need naming, summaries, migration paths, and validation.
- It also needs a clear lifecycle for selecting, migrating, and restoring stored game state.
- Read `save` as the owner of save and load policy. Serialization modules decide how data is encoded, but `save` decides how game-state persistence is packaged, versioned, and coordinated for users.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/save`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/save_api.rs`
- Referenced engine modules: `binary`, `runtime`, `serialize`

## Imports

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
- `serialize`: Imports or references `src/serialize/`. Cross-group dependency from `Feature Systems` into `Foundations`.

## Source Files

### mod.rs

- `src/save/mod.rs` is the save module index, exposing the persistence surface that gameplay and Lua bindings consume.
- It reexports `SaveManager`, slot metadata, and compression helpers while serialization stays in `serialize`.
- No runtime state lives here; this file keeps the public save boundary stable while logic stays in `save_manager.rs`.
- Read this index when a caller needs save APIs, because it shows which persistence symbols are intentionally public.
- The module groups table serialization, compressed slot payload handling, and manager-driven save orchestration together.
- Changes here alter the persistence boundary, since reexports decide what the engine and Lua layer may import.

### save_manager.rs

- Owns save-slot lifecycle policy: slot names, metadata, autosave timing, migrations, backups, and restore flow.
- Delegates payload encoding to `serialize` and byte compression or checksum helpers to `binary` boundaries.
- Stores manager configuration such as format, compression, root path, current slot metadata, and migration hooks.
- Validates slot paths, migration ordering, content limits, compression envelopes, and checksum corruption cases.
- Exposes crate-local helpers used by Lua bindings without owning Lua table parsing or generic file codecs.
- Keeps save-game state semantics separate from static mod definitions, assets, and renderer-owned runtime data.
- Provides deterministic metadata and content conversion so tests can verify save behavior across formats.
- Handles legacy compressed markers and the current save envelope while keeping payload data opaque to save.
- Update this file when save lifecycle rules, version handling, compression policy, or slot safety changes.
- Leave format-specific parsing in serialization modules and keep filesystem-facing policy visible at this owner.



## Lua API Ref

### Functions

- `lurek.save.newManager() -> LSaveManager`: Create a new SaveManager instance for managing persistent game saves.
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
- `LSaveManager:getFormat() -> string`: Return the payload serialization format used for saves and loads.
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
- `LSaveManager:setFormat(format) -> nil`: Set the payload serialization format for future saves and loads.
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

## Examples

- `content/examples/save.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- Slot names are restricted to non-empty ASCII `[A-Za-z0-9_-]` identifiers with a bounded maximum length; path traversal and separator-like input must be rejected before any save/delete/load path is constructed.
- Save collection rejects cyclic Lua tables, non-finite numbers, oversized strings/keys, and oversized table graphs before serialization begins.
- Parser and compression reads are bounded by explicit depth, entry-count, key/string, and compressed/decompressed byte limits; malformed or oversized payloads must fail with a concrete reason.
- Compressed saves use a versioned `LUREK_SAVE v1` header with LZ4 + Base64 metadata, declared uncompressed size, and SHA-256 integrity verification; legacy `--[[COMPRESSED]]` payloads remain readable.
- Slot writes use temp-file plus rename semantics and keep a `.bak` recovery copy when replacing an existing slot; loads may recover from the backup when the primary payload is corrupt.
- Migration routing is strict: missing version steps or downgrade attempts must be reported instead of silently skipping versions.
