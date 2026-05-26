# mapblock

## Overview

Procedural map block generation system. Provides configurable tile-based map blocks with multi-slot tiles, constraint-based placement, multi-level support, and scripted generation pipelines.

## Tier

Feature Systems

## Dependencies

- None (standalone)

## Public API (`lurek.mapblock`)

### Constructors
- `newConfig()` — Create default config with standard slots (floor, roof, object, left_wall, right_wall).
- `newEmptyConfig()` — Create empty config with no slots.
- `newBlock(name, width, height, layers, config)` — Create a map block.
- `newGroup(name)` — Create a block group.
- `newScript()` — Create a generation script.
- `newRules()` — Create neighbor constraint rules.
- `newGrid(width, height)` — Create a placement grid.
- `newEmptyGrid()` — Create an empty placement grid.
- `newGenerator(seed)` — Create a map generator with RNG seed.
- `newTilesetRef(id, name, tile_count, columns, tile_w, tile_h, image)` — Create tileset reference.

### Block Methods
- `block:setTile(layer, x, y, slot, tileset_id, gid)` — Set a tile.
- `block:getTile(layer, x, y, slot)` — Get a tile (tileset_id, gid).
- `block:setSide(edge, flag)` — Mark block edge compatibility.
- `block:setWeight(w)` — Set placement weight.
- `block:width()`, `block:height()`, `block:layers()` — Dimensions.

### Generator Methods
- `gen:addGroup(group)` — Register a block group.
- `gen:runScript(script, grid, rules)` — Execute generation script.
- `gen:getResult(grid)` — Get assembled tile data as 4D array.

## Invariants

- MapTile slots are configurable via MapBlockConfig.
- PlacementGrid uses HashSet for arbitrary map shapes.
- NeighborRules type 0 = wildcard (matches anything).
- Generator uses deterministic LCG RNG from seed.
- Orientation supports TopDown and Isometric only (no hex).
