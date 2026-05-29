# mapblock

## TL;DR

- The `mapblock` module provides a scripted, constraint-based procedural map assembly system that composes reusable tile-block prefabs into fully rendered TileMaps.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/mapblock/`
- Lua API path(s): `src/lua_api/mapblock_api.rs`
- Primary Lua namespace: `lurek.mapblock`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `mapblock` module implements a Carcassonne-inspired map assembly pipeline where discrete `MapBlock` prefabs — each a grid of `MapTile` slots with typed edges — are placed on a `PlacementGrid` according to `EdgeConstraint` rules that ensure neighboring blocks share compatible socket types (e.g., `"road"`, `"river"`). Block placement is driven by a `MapScript`: an ordered sequence of typed `ScriptStep` operations including `Fill` (flood-fill a region with a block group), `PlaceGroup` (weighted random selection from a named `BlockGroup`), `PlaceBlock` (explicit placement), `ApplyLayer` (copy a layer from another block), and `Repeat` (nested sub-sequence with its own RNG advance). The `MapBlockGenerator` executes these steps in order with backtrack support, capped by a configurable `retry_limit`.

Blocks are organized into named `BlockGroup` sets using alias-method weighted sampling, enabling biome-zone filling where a single script step populates an entire region with contextually appropriate tiles. Each block references a `TilesetRef` that maps its tile slot IDs to world tile IDs via a `base_id` offset, allowing multiple blocks to share the same tileset texture. Tile slots are typed (`floor`, `roof`, `object`, `wall`, or custom), which maps directly to `TileMap` layer indices in the output.

Multi-storey environments are handled by a `LayerStack` (wrapped as `MultilevelMap`) that maintains independent `MapBlockGrid` instances per Z-level. Both top-down and isometric projection orientations are supported via `MapOrientation`, applied by the tilemap renderer. The final assembly step calls `grid_to_tilemap`, converting the block grid into a standard `TileMap` owned by the caller and decoupled from the generator. The `lurek.mapblock.*` Lua API exposes block definition, group registration, script construction, and generation entry points.

## Files

### block.rs

- Map block definition: tile slots, edge connection points, and per-block metadata.
- `MapBlock` holds a grid of `MapTile` slots and a set of edge constraint descriptors.
- `BlockMeta` carries the name, weight, group membership, and tileset reference.
- Blocks are loaded from TOML files under `content/maps/blocks/`.
- Exposed to Lua via `lurek.mapblock.define(spec)` for runtime registration.

### config.rs

- Map block generator configuration: grid dimensions, seed, and global assembly rules.
- `MapBlockConfig` is deserialized from the `[mapblock]` section of a game TOML.
- Controls output grid width/height, RNG seed, and whether to allow backtracking.
- `retry_limit` caps backtrack iterations; exceeded limit falls back to a blank tile.
- Seed 0 uses the current wall-clock time for non-deterministic generation.

### constraints.rs

- Carcassonne-style edge constraints for matching adjacent map blocks.
- `EdgeConstraint` describes what socket types are legal on each of the 4 cardinal edges.
- `opposite_edge` returns the mirror direction (North↔South, East↔West).
- Constraint checking is O(1) per neighbor pair; the full grid check is O(w×h).
- Socket type strings are arbitrary game-defined labels (e.g. `"road"`, `"river"`).

### generator.rs

- Scripted procedural map assembler: executes a sequence of placement steps.
- `MapBlockGenerator` owns the grid, block registry, and RNG state.
- Runs the `MapScript` step list: Fill, PlaceGroup, PlaceBlock, ApplyLayer.
- After assembly, converts the grid to a `TileMap` via `mapblock::output`.
- Exposed to Lua via `lurek.mapblock.generate(config, script)` returning a tilemap.

### group.rs

- Named block groups for weighted random selection and themed zone filling.
- `BlockGroup` holds a name and a `Vec<(block_id, weight)>` for weighted sampling.
- Groups are registered by name; scripts reference them by string, not index.
- `BlockGroup::pick(rng)` returns a block ID using alias-method weighted sampling.
- Useful for biome zones: register a `"forest"` group and fill a region by name.

### layer.rs

- Z-layer management for multi-storey and multi-level map construction.
- `LayerStack` holds a `Vec<MapBlockGrid>`, one per Z level starting from 0.
- Layers are independent grids; block placement in one layer does not affect another.
- Layer 0 is the ground floor; negative indices are not supported.
- The `MapBlockConfig::layer_count` field pre-allocates the stack at generator init.

### maptile.rs

- Map tile and slot definitions: floor, roof, object, wall, and custom-typed slots.
- `MapTile` is a struct of optional slot IDs: `floor`, `roof`, `object`, `wall`.
- Each slot references a tile ID in the associated tileset; `None` = empty.
- `TileSlotKind` distinguishes slot roles for rendering order and collision.
- `MapTile` is the leaf unit stored in every cell of a `MapBlockGrid`.

### mod.rs

- Map-block procedural assembly system.
- Builds tile maps from composable blocks using scripted placement.
- Supports configurable tile slots (floor, roof, object, walls, custom).
- Carcassonne-style neighbor edge matching for placement constraints.
- Multi-level (Z-layers) for multi-storey maps.
- TopDown and Isometric orientations (no hex).
- Arbitrary map shapes (not limited to rectangles).
- Output converts to standard `TileMap` for rendering.

### multilevel.rs

- Multi-level map data structure with per-level block grid accessors.
- `MultilevelMap` wraps `LayerStack` and exposes named-level access (floor, roof, etc.).
- Level names are user-defined strings registered at generator init time.
- Provides `get(level, x, y)` and `set(level, x, y, tile)` with bounds checking.
- Serialized as a flat array of (level, x, y, tile) tuples in the save file.

### orientation.rs

- Map orientation modes: TopDown and Isometric projection support.
- `Orientation` enum controls how (grid_x, grid_y) maps to screen (pixel_x, pixel_y).
- `TopDown` uses a direct pixel-per-tile scale with no shear.
- `Isometric` applies the standard 2:1 diamond transform for 2.5D appearance.
- The active orientation is set in `MapBlockConfig` and applied by the tilemap renderer.

### output.rs

- Output converter: transforms an assembled map block grid into a `TileMap`.
- `grid_to_tilemap(grid, tileset_id)` produces a `TileMap` ready for the renderer.
- Slot roles (floor/wall/object) are translated to `TileMap` layer indices.
- Block-local tile IDs are offset by the tileset base ID to produce world tile IDs.
- The returned `TileMap` is owned by the caller; no reference to the block grid is kept.

### placement.rs

- Block placement grid, valid-position search, and placed-block tracking.
- `PlacementGrid` tracks which cells are occupied and caches constraint state.
- `find_valid_positions(grid, block)` returns all (x, y) cells where the block fits.
- Placement validation is O(edges × constraints) per candidate cell.
- `PlacedBlock` records the block ID, position, and applied rotation for undo support.

### script.rs

- Script steps that drive the procedural map block generation sequence.
- `MapScript` is a `Vec<ScriptStep>` executed in order by the generator.
- `StepType` variants: `Fill`, `PlaceGroup`, `PlaceBlock`, `ApplyLayer`, `Repeat`.
- Steps can be loaded from TOML or constructed programmatically from Lua.
- `Repeat { count, steps }` nests a sub-list with its own RNG advancement.

### tileset_ref.rs

- Tileset reference: links a map block's tile slots to ID ranges in a tileset asset.
- `TilesetRef` stores the tileset asset key and a `base_id` offset applied to all tiles.
- Multiple blocks may reference the same tileset with different `base_id` offsets.
- Resolved at generator build time; missing tilesets produce a load-time error.
- The resolved tileset texture is loaded once and shared across all referencing blocks.

## Lua API Ref

- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`

### Functions

- `lurek.mapblock.newBlock`: Create a new map block exposed by the lurek engine.
- `lurek.mapblock.newConfig`: Create a new map block configuration with default slots.
- `lurek.mapblock.newEmptyConfig`: Create an empty config with no predefined slots.
- `lurek.mapblock.newEmptyGrid`: Create an empty placement grid (for arbitrary shapes).
- `lurek.mapblock.newGenerator`: Create a new procedural map block generator instance.
- `lurek.mapblock.newGrid`: Create a rectangular placement grid.
- `lurek.mapblock.newGroup`: Create a new map group exposed by the lurek engine.
- `lurek.mapblock.newRules`: Create new neighbor rules exposed by the lurek engine.
- `lurek.mapblock.newScript`: Create a new map script exposed by the lurek engine.
- `lurek.mapblock.newTilesetRef`: Create a tileset reference exposed by the lurek engine.

### Enums

- No documented module-level enums/constants.

### Types


#### LMapBlock Type


##### Fields

- No documented fields.

##### Methods

- `LMapBlock:getHeight`: Get height in tiles for this object.
- `LMapBlock:getLayerCount`: Get the number of tile layers in this map block.
- `LMapBlock:getName`: Get the map block's display or lookup name string value.
- `LMapBlock:getTile`: Get the tile GID at a specified row and column position.
- `LMapBlock:getWidth`: Get the block width measured in tile grid units.
- `LMapBlock:setEdge`: Set edge type for a side and segment.
- `LMapBlock:setEdgeOnly`: Set whether block must be on map edge.
- `LMapBlock:setInteriorOnly`: Set whether block must be in interior.
- `LMapBlock:setLevelSpan`: Set multi-level span for this object.
- `LMapBlock:setName`: Set the map block's display or lookup name string value.
- `LMapBlock:setTile`: Set a tile slot value — Lua userdata object exposed by the engine.
- `LMapBlock:setWeight`: Set block weight for random selection.


#### LMapBlockConfig Type


##### Fields

- No documented fields.

##### Methods

- `LMapBlockConfig:addSlot`: Add a slot definition — Lua userdata object exposed by the engine.
- `LMapBlockConfig:getSlotCount`: Get the number of slots for this object.
- `LMapBlockConfig:removeSlot`: Remove a slot by name for this object.
- `LMapBlockConfig:setDefaultSegmentSize`: Set default segment size for this object.
- `LMapBlockConfig:setMaxLayers`: Set maximum layers per block for this object.


#### LMapBlockGenerator Type


##### Fields

- No documented fields.

##### Methods

- `LMapBlockGenerator:addGroup`: Add a named block group definition to this map generator.
- `LMapBlockGenerator:generate`: Generate map using a script for this object.
- `LMapBlockGenerator:getLastPlacedCount`: Get last placement count for this object.
- `LMapBlockGenerator:setMaxLevels`: Set the number of vertical levels or storeys to generate.
- `LMapBlockGenerator:setOrientation`: Set rendering orientation for this object.
- `LMapBlockGenerator:setRectShape`: Set rectangular map shape — Lua userdata object exposed by the engine.
- `LMapBlockGenerator:setRules`: Set neighbor matching rules for this object.
- `LMapBlockGenerator:setSeed`: Set RNG seed for deterministic generation.
- `LMapBlockGenerator:setShape`: Set the generator map shape using a list of tile positions.
- `LMapBlockGenerator:setTileSize`: Set tile pixel dimensions for this object.


#### LMapBlockResult Type


##### Fields

- No documented fields.

##### Methods

- `LMapBlockResult:getBlocksPlaced`: Get number of blocks placed for this object.
- `LMapBlockResult:getGid`: Get tile GID at position for this object.
- `LMapBlockResult:getHeight`: Get total height in tiles — Lua userdata object exposed by the engine.
- `LMapBlockResult:getLayerCount`: Get number of layers for this object.
- `LMapBlockResult:getLevelCount`: Get number of levels for this object.
- `LMapBlockResult:getWidth`: Get total width in tiles for this object.
- `LMapBlockResult:isEmpty`: Check if result is empty for this object.


#### LMapGroup Type


##### Fields

- No documented fields.

##### Methods

- `LMapGroup:addBlock`: Add a block to this group for this object.
- `LMapGroup:addScript`: Add a script to this group for this object.
- `LMapGroup:getBlockCount`: Get the number of blocks for this object.
- `LMapGroup:getName`: Get the display name of this map group object.


#### LMapScript Type


##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep`: Add a generation step — Lua userdata object exposed by the engine.
- `LMapScript:clear`: Clear all queued script steps from this map script.
- `LMapScript:getName`: Get the script name for this object.
- `LMapScript:getStepCount`: Get the number of steps for this object.


#### LNeighborRules Type


##### Fields

- No documented fields.

##### Methods

- `LNeighborRules:addCompatible`: Add bidirectional compatibility between two edge types.
- `LNeighborRules:addCompatibleOneWay`: Add one-way compatibility for this object.
- `LNeighborRules:clear`: Clear all neighbor placement rules from this rule set.
- `LNeighborRules:isCompatible`: Check if two edge types are compatible.


#### LPlacementGrid Type


##### Fields

- No documented fields.

##### Methods

- `LPlacementGrid:addPosition`: Add a position to the grid — Lua userdata object exposed by the engine.
- `LPlacementGrid:clear`: Clear all positions and placed blocks.
- `LPlacementGrid:getAvailableCount`: Get available position count for this object.
- `LPlacementGrid:isAvailable`: Check whether a placement grid position is currently available.


#### LTilesetRef Type


##### Fields

- No documented fields.

##### Methods

- `LTilesetRef:getId`: Get the numeric tileset ID for this tileset reference.
- `LTilesetRef:getName`: Get tileset name — Lua userdata object exposed by the engine.
- `LTilesetRef:setImagePath`: Set the image file path for this tileset reference.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
