# `savegame` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 2 — Engine Extensions |
| **Status**     | Implemented — Full                                   |
| **Lua API** | `luna.savegame` |
| **Source** | `src/savegame/` |
| **Rust Tests** | `tests/unit/savegame_tests.rs`                    |
| **Tests** | `tests/savegame_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_savegame.lua` |

## Summary

The savegame module handles the lifecycle management of game save data: naming
and registering save slots, tracking whether the current in-memory state is
dirty (modified since the last write to disk), firing auto-save at configurable
intervals (for example every 60 seconds of real time), and serialising Lua
tables to a `return { ... }` Lua-literal format that `loadfile()` can
deserialise without any custom parser.  The module deliberately does not
perform file I/O — serialised strings are passed to `luna.filesystem.write()`
by the caller so the I/O boundary is explicit and the module is fully
unit-testable without touching the filesystem.

Schema versioning allows save files to carry a version number so that older
saves can be migrated to newer formats.  Games register migration steps with
`add_migration(from_version)` and call `applicable_migrations(loaded_version)`
at load time to determine which migration steps to apply.  Dirty tracking
prevents excessive disk writes: the auto-save timer only fires when `is_dirty()`
is true, so repeated calls to `update(dt)` on an unchanged state produce no
I/O at all.

## Architecture

```
SaveManager (save state tracker)
  │
  ├── Schema versioning
  │     ├── schema_version: u32
  │     └── migration_versions: Vec<u32> (upgrade history)
  │
  ├── Slot registration
  │     ├── registered: Vec<String> (named save slots)
  │     └── register / unregister
  │
  ├── Auto-save
  │     ├── enable_auto_save(interval, slot_name)
  │     ├── disable_auto_save()
  │     └── update(dt) → Option<String> (fires when interval elapses)
  │
  ├── Dirty tracking
  │     ├── mark_dirty() / is_dirty() / clear_dirty()
  │     └── Auto-save only fires if dirty
  │
  └── Serialization
        ├── serialize_table(lua_table) → String
        ├── serialize_value(value) → String
        └── Output: `return { key = value, ... }` format
```

## Source Files

| File | Purpose |
|------|---------|
| `save_data.rs` | Save/load slot system with collectors, schema versioning, dirty tracking, |

## Submodules

### `savegame::save_data`

Save/load slot system with collectors, schema versioning, dirty tracking, and auto-save.

- **`SlotMeta`** (struct): Metadata extracted from a save slot. Consult the module-level documentation for the broader usage context and...
- **`SaveManager`** (struct): Pure-data save manager providing registration of named collectors, schema versioning, dirty-state tracking, and...
- **`serialize_table`** (fn): Serialize a simple Lua-compatible value hierarchy into a `return { ... }` string.
- **`serialize_value`** (fn): Serialize a single value. Consult the module-level documentation for the broader usage context and preconditions.
- **`SaveValue`** (enum): A simple value type matching the Lua subset we can serialize.

## Key Types

### Structs

#### `savegame::save_data::SaveManager`

Pure-data save manager providing registration of named collectors, schema versioning, dirty-state tracking, and...

#### `savegame::save_data::SlotMeta`

Metadata extracted from a save slot. Consult the module-level documentation for the broader usage context and...

### Enums

#### `savegame::save_data::SaveValue`

A simple value type matching the Lua subset we can serialize.

## Public Functions

- **`serialize_table()`** `save_data::` — Serialize a simple Lua-compatible value hierarchy into a `return { ... }` string.
- **`serialize_value()`** `save_data::` — Serialize a single value. Consult the module-level documentation for the broader usage context and preconditions.

## Lua API

Exposed under `luna.savegame.*` by `src/lua_api/savegame_api/`.

## Item Summary

| Kind | Count |
|------|-------|
| `enum` | 1 |
| `fn` | 2 |
| `mod` | 1 |
| `struct` | 2 |
| **Total** | **6** |

## Lua Examples

```lua
function luna.load()
    save = luna.savegame.load("slot1")
    if save then
        player_score = save.score
        player_level = save.level
    else
        player_score = 0
        player_level = 1
    end
end

function save_game()
    luna.savegame.save("slot1", {
        score = player_score,
        level = player_level
    })
end
```

## References

| Module       | Relationship  | Notes                                              |
|--------------|---------------|----------------------------------------------------|
| `engine`     | Imports from  | Uses `SharedState`                                 |
| `filesystem` | Imports from  | All save/load operations go through `filesystem` sandbox |
| `data`       | Related       | `data` handles binary serialisation; `savegame` provides schema-versioned JSON saves |
| `lua_api`    | Imported by   | `src/lua_api/savegame_api.rs` registers `luna.savegame.*` |

## Notes

- Save data is serialised to JSON (human-readable) via `serde_json`; schema version is embedded.
- `savegame:migrate()` applies registered migration functions when loading an older save schema.
- Save files are stored in `luna.filesystem.getSaveDirectory()` — always sandbox-safe.
- Do not save resource keys (TextureKey, etc.) — they are runtime-only; save logical IDs instead.
