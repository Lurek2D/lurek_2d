# `loot` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua with optional engine-backed sampling) |
| Source | `library/loot/init.lua` |
| Lua tests | `tests/lua/library/test_loot_library.lua` |
| Status | full |
| Optional bindings | `lurek.math.newLootTable`, `lootFromList`, `lootFromToml`, `newPityTracker`, `sampleWithPity`, `newRandomGenerator`, `lurek.serialize.fromToml`, `lurek.filesystem.read` |

## Purpose

Weighted loot tables, drop-set DSL, pity tracking, and modifier views for RPG
and roguelike reward generation.

## Current shape

- `newTable`, `fromList`, `fromToml`, and `merge` create loot tables.
- `LootTable:sample()` and `sampleN()` preserve the legacy `id, meta` return
  shape expected by existing Lua content.
- `newDrop()` builds conditional and guaranteed drop sets.
- `newPity(target_id, threshold)` tracks guaranteed-after-N-misses behavior.
- `newModifier()` builds gameplay-level weight modifiers over loot tables.

## Engine integration

- Loot tables delegate to `lurek.math` loot backends when safe.
- Pity tracking delegates to `lurek.math.newPityTracker` when safe.
- TOML loading may use `lurek.math.lootFromToml` or `lurek.serialize.fromToml`
  plus `lurek.filesystem.read`.
- Pure Lua fallback remains intentional for headless or non-engine hosts.

## Notes

- Keep constructor names and `id, meta` return values stable.
- Gameplay wrappers such as `DropSet` and `Modifier` stay library-owned.
