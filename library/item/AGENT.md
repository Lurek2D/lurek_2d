# `item` — Agent Reference (Lureksome)

| Property | Value |
|----------|-------|
| **Tier** | Tier 3 — Lureksome (pure Lua, no Rust dependencies) |
| **Source** | `library/item/init.lua` |
| **Lua Tests** | `tests/lua/library/test_library_item.lua` |
| **Depends on** | `lurek.*` public API only |
| **Test count** | 107 tests, 0 failures |

## Summary

Generic item system with a type registry, per-instance mutable state, weighted
pools, and stack management. `TypeRegistry` stores blueprints with base stats,
tags, metadata, and an optional display name. `Item` instances are cloned from a
type definition and own their own stats, tags, **counters** (named integers),
metadata, owner reference, **display name**, and **slot/position name**. Items
are fully serialisable with `lurek.save`.

`Stack` is an ordered, capacity-bounded collection of `Item` instances; it
supports LIFO push/pop, FIFO pop-bottom/push-bottom, arbitrary removal by
index, `peekBottom()`, `peekTopNTypes(n)`, bulk popMany, and filtering queries.
Extended search methods: `searchByType`, `searchByTag`, `searchByCategory`,
`findByType`, `findByTag`; count helpers: `countByType`, `countByCategory`,
`countByTag`; sort: `sortByStat`, `sortByStatDesc`, `sortByCategory`,
`sortByName`, `shuffle`; and `isEmpty`, `popMany`, `moveWithin`.

`StackBuilder` provides a builder pattern with `add`, `addWith` (applies stat
overrides and extra tags to pre-built items), `setShuffleOnBuild`, `requireType`,
`banType`, `validateEntries`, `validateStack`, `build`, and `buildNamed`.

`ItemPool` holds type names with integer weights via `addType`/`remove`/
`setWeight` and exposes `draw`, `drawTypes(n)`, `drawUniqueTypes(n)`,
`totalWeight()`, and `isEmpty()`.

`StackHistory` is an append-only bounded log with `recordPush`, `recordPop`,
`recordClear`, `recordCustom`, `entries`, `getLastN`, `last`, `isEmpty`,
`entriesFor(source)`, and `clear`.

`StackManager` groups multiple named stacks: `addStack`, `getStack`,
`removeStack`, `hasStack`, `createStack`, `createStackCapped`, `keys`,
`totalItems`, `moveItem`, `moveItemByType`, and `moveTop`.

`Slot` is a standalone bounded single-position holder: `push`, `pop`,
`removeAt`, `peek`, `peekAt`, `clear`, `items`, `hasItemWithTag`,
`hasItemOfType`, `isEmpty`, `isFull`, `getCapacity`, `setCapacity`.

Analysis helpers operate on flat item arrays: `groupByStat`, `groupByCategory`,
`groupByTagPrefix`, `findNOfStat`, `findAtLeastNOfStat`, `findSequences`,
`findTagGroups`, `sortedIndicesByStat(items, stat, ascending?)`,
`sortedIndicesByCategory`.

## Architecture

```
TypeRegistry
  └── defs: { type_id → { name, category, base_stats, base_tags, metadata } }

Item (instance)
  ├── type_id, name, category
  ├── stats, tags, counters (named integer counters)
  ├── metadata, owner, slot
  └── clone() → deep copy (stats, tags, meta, counters, slot, name; NOT owner)

Stack (ordered collection)
  ├── capacity, items[]
  ├── push/pop (LIFO)   pushBottom/popBottom (FIFO)   peekBottom
  ├── removeAt / insertAt / moveWithin / popMany(n)
  ├── searchByType / searchByTag / searchByCategory
  ├── countByType / countByCategory / countByTag
  ├── findByType / findByTag / findFirst(pred)
  ├── sortByStat / sortByStatDesc / sortByCategory / sortByName / shuffle
  └── isEmpty / peekTopNTypes(n) / getItems / peekAt

StackBuilder
  ├── add / addWith (with stat overrides + extra tags)
  ├── setShuffleOnBuild / requireType / banType / removeBannedType
  ├── validateEntries / validateStack
  └── build(name) / buildNamed(name)

ItemPool (weighted draw)
  ├── addType / remove / setWeight
  ├── size / isEmpty / totalWeight
  └── draw / drawTypes(n) / drawUniqueTypes(n)

Slot (bounded single-position holder)
  ├── push / pop / removeAt / peek / peekAt / clear / items
  ├── size / isEmpty / isFull / getCapacity / setCapacity
  └── hasItemWithTag / hasItemOfType

StackHistory (append-only event log)
  ├── recordPush / recordPop / recordClear / recordCustom
  ├── entries / getLastN / last / entriesFor(source)
  └── count / isEmpty / clear

StackManager (named stack group)
  ├── addStack / getStack / removeStack / hasStack
  ├── createStack / createStackCapped / keys / totalItems
  └── moveItem / moveItemByType / moveTop

HistoryAction constants: Push, Pop, Clear, Custom, Moved, Shuffled, Sorted, Built

Analysis helpers (operate on flat item arrays)
  ├── groupByStat / groupByCategory / groupByTagPrefix
  ├── findNOfStat / findAtLeastNOfStat / findSequences / findTagGroups
  └── sortedIndicesByStat(items, stat, ascending?) / sortedIndicesByCategory
```

## Source Files

| File | Purpose |
|------|---------|
| `library/item/init.lua` | Full implementation — TypeRegistry, Item, Stack, StackBuilder, ItemPool, Slot, StackHistory, StackManager, analysis helpers |

## Key Types

| Type | Constructor | Purpose |
|------|-------------|---------|
| TypeRegistry | (module-level singleton) | Global blueprint store |
| Item | `M.newItem(type_name)` | Mutable instance: stats, tags, counters, meta, owner, name, slot |
| Stack | `M.newStack(name, capacity?)` | Ordered item collection with full LIFO/FIFO/positional/search/sort API |
| StackBuilder | `M.newStackBuilder()` | Validated Stack construction with addWith, shuffleOnBuild, requireType/banType |
| ItemPool | `M.newItemPool()` | Weighted random-draw pool with totalWeight and isEmpty |
| Slot | `M.newSlot(name, capacity?)` | Bounded single-position holder with tag/type queries |
| StackHistory | `M.newStackHistory(max_entries?)` | Append-only change log with last, isEmpty, entriesFor |
| StackManager | `M.newStackManager()` | Named stack group with createStack, hasStack, moveItem, totalItems |
| M.HistoryAction | constants | Push, Pop, Clear, Custom, Moved, Shuffled, Sorted, Built |
| M.groupByStat | free function | Group flat item array by integer stat value |
| M.groupByCategory | free function | Group flat item array by category string |
| M.groupByTagPrefix | free function | Group flat item array by tag prefix |
| M.findNOfStat | free function | Top-N items by stat value (descending) |
| M.findAtLeastNOfStat | free function | Items where stat >= threshold |
| M.findSequences | free function | Consecutive runs of same stat value |
| M.findTagGroups | free function | Groups of items sharing common tags |
| M.sortedIndicesByStat | free function | Index array sorted by stat, supports ascending/descending |
| M.sortedIndicesByCategory | free function | Index array sorted by category |

| Property | Value |
|----------|-------|
| **Tier** | Tier 3 — Lureksome (pure Lua, no Rust dependencies) |
| **Source** | `library/item/init.lua` |
| **Lua Tests** | `tests/lua/library/test_library_item.lua` |
| **Depends on** | `lurek.*` public API only |

## Summary

Generic item system with a type registry, per-instance mutable state, weighted
pools, and stack management. `TypeRegistry` stores `ItemTypeDef` blueprints;
each definition carries a base stat table, a tag set, default metadata, and an
optional `max_stack` limit. `Item` instances are cloned from a type definition
and own their own stats, tags, counters, metadata, and an optional owner
identifier. Items never reference the engine runtime making them safe to
serialise completely with `lurek.save`.

`Stack` is an ordered, capacity-bounded collection of `Item` instances; it
supports both LIFO push/pop semantics and FIFO shift/unshift, arbitrary removal
by index, bulk moves, and filtering queries. Extended search methods include
`searchByType`, `searchByTag`, `searchByCategory`, `findByType`, `findByTag`;
count helpers include `countByType`, `countByCategory`, `countByTag`;
sort methods include `sortByStat`, `sortByStatDesc`, `sortByCategory`, `sortByName`,
and `shuffle()`; and `isEmpty()`, `popMany(n)`, `peekTopNTypes(n)` round out
the extended interface. `StackBuilder` provides a builder pattern for stack
construction with type inclusion (`addWith`), type allowlist/banlist constraints
(`requireType`, `banType`), entry validation (`validateEntries`), full validation
(`validateStack`), and `buildNamed(name)` to produce a named stack. `ItemPool` holds
named items with integer weights and produces random draws via `drawOne()` and
`drawMany()`, respecting an optional boolean `unique_draw` flag that prevents
duplicate draws in one session.

`StackHistory` is an append-only change log that records push, pop, and move
events. `StackManager` groups multiple named stacks and provides bulk
operations across them. Analysis helpers (`groupByStat`, `groupByCategory`,
`totalStat`, `maxStat`, `filterByTag`, `excludeTag`) operate on flat item
arrays without copying and are suitable for batch AI or UI queries.

## Architecture

```
TypeRegistry
  └── defs: { type_id → ItemTypeDef }
        ├── base_stats, base_tags, metadata
        └── max_stack

Item (instance)
  ├── type_id, stats, tags, counters
  ├── metadata, owner
  └── clone() → deep copy

Stack (ordered collection)
  ├── capacity, items[]
  ├── push/pop (LIFO)   shift/unshift (FIFO)
  ├── remove(index)  move(from_stack, index)  popMany(n)
  ├── searchByType / searchByTag / searchByCategory
  ├── countByType / countByCategory / countByTag
  ├── sortByStat / sortByStatDesc / sortByCategory / sortByName / shuffle()
  └── filter(predicate) / find(predicate) / isEmpty() / peekTopNTypes(n)

StackBuilder (builder pattern)
  ├── addWith / requireType / banType
  ├── validateEntries / validateStack
  └── buildNamed(name) → Stack

M.HistoryAction  ──  Pushed | Popped | Moved | Shuffled | Sorted | Built (action kind constants)

ItemPool (weighted draw)
  ├── entries: { name → Item, weight }
  ├── unique_draw flag
  └── drawOne() / drawMany(n)

StackHistory  ─── append-only event log
StackManager  ─── named stack group with bulk operations

Analysis helpers (operate on flat item arrays)
  ├── groupByStat / groupByCategory / filterByTag / excludeTag
  ├── findAtLeastNOfStat / findTagGroups
  └── totalStat / maxStat / sortedIndicesByStat / sortedIndicesByCategory
```

## Source Files

| File | Purpose |
|------|---------|
| `library/item/init.lua` | Full implementation — TypeRegistry, ItemTypeDef, Item, Stack, ItemPool, StackHistory, StackManager, analysis helpers |

## Key Types

| Type | Constructor | Purpose |
|------|-------------|--------|
| `TypeRegistry` | (module-level singleton) | Global blueprint store |
| `ItemTypeDef` | `M.newItem(type_name)` (via registry) | Blueprint: base stats, tags, stack limit |
| `Item` | (cloned from TypeDef) | Mutable instance with stats, tags, counters, metadata, and owner |
| `Stack` | `M.newStack(name, capacity)` | Ordered item collection with LIFO/FIFO and extended search/sort API |
| `StackBuilder` | `M.newStackBuilder()` | Builder pattern for typed/validated Stack construction |
| `ItemPool` | `M.newItemPool()` | Weighted random-draw pool |
| `StackHistory` | `M.newStackHistory(max_entries)` | Append-only change log with typed action records |
| `StackManager` | `M.newStackManager()` | Named stack group with bulk operations |
| `M.HistoryAction` | action kind constants | Named history action kind values (Pushed, Popped, Moved, Shuffled, Sorted, Built) |
| `M.groupByCategory` | free function | Group a flat item array by item category; returns a table of category-keyed item lists |
| `M.findAtLeastNOfStat` | free function | Find items where a named stat meets or exceeds a threshold with a minimum match count |
| `M.findTagGroups` | free function | Return groups of items sharing common tags across a flat item list |
| `M.sortedIndicesByStat` | free function | Return index array sorted over a flat item list by a named stat (ascending) |
| `M.sortedIndicesByCategory` | free function | Return index array sorted over a flat item list by category string |
