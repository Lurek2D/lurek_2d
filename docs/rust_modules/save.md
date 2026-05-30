# save

## General Info

- Module group: `Feature Systems`
- Source path: `src/save/`
- Binding: `src/lua_api/save_api.rs`
- Namespace: `lurek.save`
- Lua API surface: `1` functions, `3` types, `27` methods
- Rust test path(s): tests/rust/unit/savegame_tests.rs
- Lua test path(s): tests/lua/unit/test_save.lua, tests/lua/stress/test_save_stress.lua, tests/lua/security/test_save_validation.lua, tests/lua/integration/test_save_ecs.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_save_ecs_scene.lua

## Summary

It enables developers to reliably save and load game state with built-in support for compression, file rotation, and schema versioning. The architecture is built around the `SaveManager`, which coordinates persistence using a named-section approach. Developers register game modules (like inventory, player stats, or level state) by assigning a string name and providing paired `collect` and `restore` Lua callback functions. During a save operation, the manager queries these collectors to gather the current game state as a Lua table; during load, the state is passed back via the restorers.

To optimize performance and minimize disk wear, the system employs dirty tracking. Writes are entirely skipped unless the state is explicitly marked as dirty (changed). An auto-save scheduler can be configured to automatically persist the dirty state to a designated slot at regular intervals. When writing to disk, the `save` module uses a custom serialization format that converts Lua tables into a Rust `SaveValue` tree, emitting valid Lua-literal text. To ensure small file sizes, this text is subsequently compressed using LZ4 and Base64 encoded before being written. The manager also handles slot file rotation, automatically maintaining a configurable number of backup copies for data safety.

Crucially, the module provides robust tools for long-term game maintenance via schema versioning and data migrations. Each save file is stamped with a schema version number. If the game is updated and the schema advances, registered migration functions are automatically invoked in sequence to upgrade older save data to the current schema before it is handed back to the `restore` callbacks. Additionally, the system generates lightweight `SlotMeta` metadata for each save slot—including timestamps, play time, and human-readable summary strings (e.g., 'Level 5 – Forest')—enabling UI save-select screens to display save info instantly without needing to deserialize the entire game state. The comprehensive `lurek.save.*` API gives Lua scripts full control over this powerful persistence engine.

## Files

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/save/mod.rs)

- This module provides the save-system surface for collecting game state, storing it by slot, and restoring it later.
- It combines persistence, compression, backup rotation, and migration support under one gameplay-facing feature stack.
- At the highest level this is the engine subsystem that turns live Lua state into durable save slots.

### [save_manager.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/save/save_manager.rs)

- This file implements the practical save manager that coordinates collection, serialization, persistence, and restoration of game state.
- Registered sections let different gameplay systems contribute their own data while still producing one coherent slot payload.
- Dirty tracking and auto-save timing live here so disk writes happen when needed instead of on every frame or every small state change.
- Schema versioning and migration routing are also handled here, which lets older saves evolve forward as projects change over time.
- Serialization and compression are part of the same flow so slot files remain structured, compact, and easy to validate on load.
- The file is therefore the operational core of persistence for games built on the engine.
