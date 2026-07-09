# `item` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/item/init.lua` |
| Lua tests | `tests/lua/library/test_item_library.lua` |
| Status | full |
| Optional bindings | `lurek.patterns.newWeightedRandom`, `lurek.patterns.groupBy`, `topN`, `sortedIndices` |

## Purpose

Typed item definitions, mutable item instances, stacks, slots, weighted pools,
stack history, stack manager helpers, and flat-array analysis helpers.

## Current shape

- `defineType`, `getType`, `getTypeNames`, and `clearTypes` own the type registry.
- `newItem`, `newStack`, `newItemPool`, `newStackBuilder`, `newStackHistory`,
  `newStackManager`, and `newSlot` cover the runtime data model.
- Helper functions such as `groupByCategory`, `findNOfStat`,
  `sortedIndicesByStat`, and `findSequences` operate on flat item arrays.

## Engine integration

- `ItemPool` uses `lurek.patterns.newWeightedRandom` when available.
- Some helper functions delegate to `lurek.patterns` when delegation preserves
  the library's current indexing and return shapes.

## Notes

- Item models, stacks, and history remain domain-owned Lua logic.
- Preserve public helper names and current compatibility behavior.
