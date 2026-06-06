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

This module provides a unified state persistence and save slot manager designed to handle game progress. Diverse gameplay systems register data sections using collector and restorer callback pairs. When saving, the manager invokes collectors to assemble a single structured state payload; during loads, it distributes this data back to their respective systems to ensure smooth, reliable state restorations.

To optimize disk usage, the system integrates compression, auto-saves, and migrations. It applies LZ4 compression to minimize files, tracks modifications with a dirty flag, and schedules auto-save timers. Additionally, it enforces schema versioning and runs registered transformation callbacks to migrate old save files to current formats.

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
