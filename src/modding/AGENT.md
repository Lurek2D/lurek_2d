# `modding` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 2 — Reusable Engine Extensions |
| **Status**     | Implemented — Full                                   |
| **Lua API** | `luna.modding` |
| **Source** | `src/modding/` |
| **Rust Tests** | `tests/unit/modding_tests.rs`                    |
| **Tests** | `tests/modding_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_modding.lua` |

## Summary

The modding module provides the infrastructure for player-created mods — the
ability for end users to add, replace, or extend game content without modifying
the original game files.  It scans a designated `mods/` directory for
subdirectories, reads each subdirectory's `mod.toml` manifest (name, version,
description, author, load-order priority, dependency declarations), resolves
the dependency graph to produce a deterministic load order, and executes each
mod's Lua entry script and asset-override declarations within the existing
sandbox rules.

Mods declare asset overrides in their manifest — for example replacing
`sprites/hero.png` with the mod's own version.  These virtual-path overrides
are registered in `GameFS` before any game script runs, so the mod asset is
found first without special-casing in the reader code.  Two mods overriding
the same asset are resolved by load-order priority declared in their
manifests.  A mod can also extend the `luna.*` Lua surface by defining new
functions in its entry Lua file, provided they do not shadow core Luna2D
names.

## Architecture

```
ModManager (mod registry)
  │
  ├── ModInfo ── per-mod metadata
  │     ├── id, name, version, author, description
  │     ├── priority (for load order)
  │     ├── dependencies (list of required mod IDs)
  │     ├── enabled / loaded flags
  │     └── path (filesystem location)
  │
  ├── Load order resolution
  │     ├── Priority-based default ordering
  │     └── Custom load order override
  │
  ├── Folder scanning
  │     └── scan_folder(path) → discovers mods via TOML metadata
  │
  ├── Dependency validation
  │     ├── validate_dependencies() → checks all deps satisfied
  │     └── has_circular_dependencies() → DFS cycle detection
  │
  └── Hot-reload queue
        ├── mark_for_reload(mod_id)
        └── get/clear_reload_queue()
```

## Source Files

| File | Purpose |
|------|---------|
| `mod_manager.rs` | Mod management framework |

## Submodules

### `modding::mod_manager`

Mod management framework.

- **`ModInfo`** (struct): Metadata describing a mod. Consult the module-level documentation for the broader usage context and preconditions.
- **`ModManager`** (struct): Centralized registry for managing mods, resolving load order, validating dependencies, scanning mod folders, and...

## Key Types

### Structs

#### `modding::mod_manager::ModInfo`

Metadata describing a mod. Consult the module-level documentation for the broader usage context and preconditions.

#### `modding::mod_manager::ModManager`

Centralized registry for managing mods, resolving load order, validating dependencies, scanning mod folders, and...

## Lua API

Exposed under `luna.modding.*` by `src/lua_api/modding_api/`.

## Item Summary

| Kind | Count |
|------|-------|
| `mod` | 1 |
| `struct` | 2 |
| **Total** | **3** |

## Lua Examples

```lua
function luna.load()
    -- Discover and load mods from "mods/" directory
    local mods = luna.modding.discover("mods/")
    for _, mod in ipairs(mods) do
        print("Found mod:", mod.name, "v"..mod.version)
        if luna.modding.isCompatible(mod) then
            luna.modding.load(mod)
        end
    end
end
```

## References

| Module       | Relationship  | Notes                                              |
|--------------|---------------|----------------------------------------------------|
| `engine`     | Imports from  | Uses `SharedState`                                 |
| `filesystem` | Imports from  | `modding` discovers mods through the filesystem layer |
| `lua_api`    | Imported by   | `src/lua_api/modding_api.rs` registers `luna.modding.*` |

## Notes

- Mod discovery searches only inside the configured mods directory — never the game source tree.
- Dependency resolution is topological sort; circular mod dependencies are detected and rejected.
- Load order is deterministic: alphabetical within priority tier, dependencies always before dependents.
- Mods are Lua scripts loaded in a sandboxed VM that inherits the game's `luna.*` API surface.
