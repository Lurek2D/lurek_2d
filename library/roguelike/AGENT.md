# `roguelike` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua with optional engine-backed FOV and goal maps) |
| Source | `library/roguelike/init.lua` |
| Lua tests | `tests/lua/library/test_roguelike_library.lua` |
| Status | full |
| Optional bindings | `lurek.tilemap`, `lurek.awareness.newFov`, `lurek.pathfind.newGoalMap`, `lurek.math.bresenham` |

## Purpose

Tile-grid roguelike helpers: field-of-view, energy scheduling, and multi-source
goal-map path guidance.

## Current shape

- `newFov(opts)` creates an FOV object with `setBlocker`, `attachTilemap`,
  `compute`, `isVisible`, `isExplored`, `resetExplored`, `eachVisible`,
  `visibleCells`, and `export`.
- `newScheduler()` creates an energy-turn scheduler with `add`, `remove`,
  `setSpeed`, `next`, `peek`, `tick`, `reset`, `save`, and `restore`.
- `newGoalMap(width, height)` creates a goal map with blocker setup, sources,
  `bake`, `distanceAt`, `gradientAt`, and `flee`.

## Engine integration

- FOV delegates to `lurek.awareness.newFov` when the engine API is available
  and behavior matches the library contract.
- Goal maps delegate to `lurek.pathfind.newGoalMap` when available.
- `Scheduler` stays pure Lua and does not use real-time engine schedulers.

## Notes

- Keep zero-based coordinates and current visible/explored semantics stable.
- If a backend cannot preserve behavior, the pure Lua fallback is the correct
  owner.
