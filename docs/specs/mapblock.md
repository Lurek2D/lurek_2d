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

- Fundamental mapblock unit combining tile payloads, edge sockets, and metadata.
- Carries the data needed to match blocks during procedural placement.
- Stores selection weighting, naming, and tileset references for later output.
- Encodes the local shape and slot content that downstream stages consume.
- Keeps neighbor semantics alongside the block so validation stays data-driven.
- Acts as the atomic building piece for the entire mapblock pipeline.

### config.rs

- Runtime configuration for mapblock generation shape, slots, and randomness.
- Holds grid dimensions, layer limits, and placement behavior flags.
- Stores seed and retry controls for deterministic or exploratory runs.
- Defines the slot schema that orders per-tile payload interpretation.
- Serves as the canonical loaded settings object for assembly routines.

### constraints.rs

- Edge compatibility rules that decide whether neighboring blocks can connect.
- Describes socket-style match data per edge for fine-grained placement checks.
- Provides opposite-edge helpers for two-sided adjacency validation.
- Keeps connection semantics data-driven instead of hard-coded.
- Powers fast local legality checks during generator execution.

### generator.rs

- Operational core for scripted mapblock assembly over a block grid.
- Owns block registries, multi-level placement state, and RNG progression.
- Executes fill, targeted placement, random placement, and repeat steps.
- Applies neighbor constraints to keep layouts structurally coherent.
- Threads orientation and config context through the build process.
- Converts intermediate placements into renderer-ready output structures.
- Supports deterministic runs through seeded randomness and explicit step ordering.
- Serves as the main execution engine behind mapblock authoring tools.

### group.rs

- Named block group for themed procedural generation passes.
- Carries weighted selection metadata for controlled randomness.
- Lets scripts reference semantic groups instead of numeric ids.
- Supports biome-style or region-style content curation.

### layer.rs

- Per-level tile storage for multi-storey mapblock outputs.
- Manages independent 2D block layers indexed by non-negative vertical levels.
- Provides bounds-aware tile access and mutation for placement operations.
- Keeps slot counts and layer dimensions aligned with global config.
- Supplies the layered container used by multilevel map assembly.

### maptile.rs

- Atomic tile payload composed from configurable slot values and metadata.
- Encodes tile-slot identifiers that point at tileset entries for rendering and logic.
- Distinguishes slot roles so ordered drawing stays consistent.
- Serves as the smallest content unit stored inside mapblock grids.

### mod.rs

- High-level mapblock module that wires blocks, scripts, constraints, and output conversion together.
- Exposes the procedural assembly surface used to build tilemaps from authored content.
- Keeps layered generation, orientation handling, and placement validation under one namespace.

### multilevel.rs

- Multilevel container for placed blocks across vertical storeys.
- Tracks level metadata and block placements with bounds-safe access patterns.
- Supports mutation and query by level and grid coordinate during generation.
- Preserves structure needed for serialization and output transformation.
- Bridges layered placement logic with final map export.

### orientation.rs

- Orientation modes for interpreting generated mapblock layouts.
- Provides top-down and isometric variants for different presentation styles.
- Supplies parsing and helpers used by config-driven renderer integration.

### output.rs

- Final mapblock conversion layer that turns placements into tile data outputs.
- Translates layered slot payloads into ordered tile layers and resolved tileset ids.
- Applies orientation and level handling so exports match runtime presentation.
- Produces owned result structures detached from mutable generator state.
- Serves as the last step in the mapblock build pipeline.

### placement.rs

- Placement-grid state and legality checks for mapblock assembly operations.
- Tracks occupied cells and placed-block metadata used by scripted steps.
- Evaluates candidates against edge constraints and neighborhood compatibility rules.
- Enumerates valid placements for deterministic or random selection passes.
- Records coordinates and orientation details for downstream processing.
- Acts as the spatial validation core inside the generator loop.

### script.rs

- Scripted step language that drives procedural mapblock generation flow.
- Encodes fill, targeted placement, random placement, and repeat operations.
- Stores ordered step sequences consumed directly by the execution engine.
- Supports data-driven authoring and runtime construction of generation programs.
- Provides the control plane for deterministic and expressive map assembly.

### tileset_ref.rs

- Tileset reference metadata used to resolve slot values into concrete tile resources.
- Stores tileset identity, sizing, and index-offset data shared across blocks.
- Supports reuse of one tileset with different offset conventions per content group.
- Serves as lookup glue between authored blocks and runtime tilemap output.

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

- Lua-facing map block exposed by the lurek engine.

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

- Lua-facing map block configuration.

##### Fields

- No documented fields.

##### Methods

- `LMapBlockConfig:addSlot`: Add a slot definition — Lua userdata object exposed by the engine.
- `LMapBlockConfig:getSlotCount`: Get the number of slots for this object.
- `LMapBlockConfig:removeSlot`: Remove a slot by name for this object.
- `LMapBlockConfig:setDefaultSegmentSize`: Set default segment size for this object.
- `LMapBlockConfig:setMaxLayers`: Set maximum layers per block for this object.

#### LMapBlockGenerator Type

- Lua-facing generator exposed by the lurek engine.

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

- Lua-facing generation result exposed by the lurek engine.

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

- Lua-facing map group exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapGroup:addBlock`: Add a block to this group for this object.
- `LMapGroup:addScript`: Add a script to this group for this object.
- `LMapGroup:getBlockCount`: Get the number of blocks for this object.
- `LMapGroup:getName`: Get the display name of this map group object.

#### LMapScript Type

- Lua-facing map script exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep`: Add a generation step — Lua userdata object exposed by the engine.
- `LMapScript:clear`: Clear all queued script steps from this map script.
- `LMapScript:getName`: Get the script name for this object.
- `LMapScript:getStepCount`: Get the number of steps for this object.

#### LNeighborRules Type

- Lua-facing neighbor rules exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LNeighborRules:addCompatible`: Add bidirectional compatibility between two edge types.
- `LNeighborRules:addCompatibleOneWay`: Add one-way compatibility for this object.
- `LNeighborRules:clear`: Clear all neighbor placement rules from this rule set.
- `LNeighborRules:isCompatible`: Check if two edge types are compatible.

#### LPlacementGrid Type

- Lua-facing placement grid exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LPlacementGrid:addPosition`: Add a position to the grid — Lua userdata object exposed by the engine.
- `LPlacementGrid:clear`: Clear all positions and placed blocks.
- `LPlacementGrid:getAvailableCount`: Get available position count for this object.
- `LPlacementGrid:isAvailable`: Check whether a placement grid position is currently available.

#### LTilesetRef Type

- Lua-facing tileset reference exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LTilesetRef:getId`: Get the numeric tileset ID for this tileset reference.
- `LTilesetRef:getName`: Get tileset name — Lua userdata object exposed by the engine.
- `LTilesetRef:setImagePath`: Set the image file path for this tileset reference.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
