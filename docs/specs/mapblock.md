# mapblock

## TL;DR

- Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/mapblock/`
- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`
- Lua API surface: `10` functions, `9` types, `53` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

- This module gives users procedural map assembly from reusable authored blocks.
- Blocks package tile data, sockets, and metadata so placement remains data-driven.
- Neighbor constraints enforce legal block adjacency and prevent invalid seams.
- Scripted generation steps support fill, targeted placement, random placement, and repeats.
- Placement grids track occupancy and legality during generation.
- Multi-level support enables stacked floors and vertical map structures.
- Orientation support covers top-down and isometric output expectations.
- Weighted groups support biome or theme-biased block selection.
- Deterministic seeded generation supports reproducible builds.
- Tileset references map block slots into concrete output tile identifiers.
- Output conversion produces renderer-ready layered tilemap structures.
- This module is useful for dungeons, city chunks, and modular world assembly.
- It keeps generation logic separate from final render map representation.
- For users, it reduces hand-authored map workload while preserving authored control.
- It also improves iteration speed for procedural level design workflows.
- Overall, users get a complete block-based map generation pipeline in one module.
- The practical value is reliable procedural layout with explicit constraint control.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

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

### Functions

- `lurek.mapblock.newBlock(width, height, layers, config) -> MapBlock`: Create a new map block exposed by the lurek engine.
- `lurek.mapblock.newConfig() -> MapBlockConfig`: Create a new map block configuration with default slots.
- `lurek.mapblock.newEmptyConfig() -> MapBlockConfig`: Create an empty config with no predefined slots.
- `lurek.mapblock.newEmptyGrid() -> PlacementGrid`: Create an empty placement grid (for arbitrary shapes).
- `lurek.mapblock.newGenerator(config) -> MapBlockGenerator`: Create a new procedural map block generator instance.
- `lurek.mapblock.newGrid(width, height) -> PlacementGrid`: Create a rectangular placement grid.
- `lurek.mapblock.newGroup(name) -> MapGroup`: Create a new map group exposed by the lurek engine.
- `lurek.mapblock.newRules() -> NeighborRules`: Create new neighbor rules exposed by the lurek engine.
- `lurek.mapblock.newScript(name?) -> MapScript`: Create a new map script exposed by the lurek engine.
- `lurek.mapblock.newTilesetRef(id, name, tile_count, columns, tile_width, tile_height) -> TilesetRef`: Create a tileset reference exposed by the lurek engine.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LMapBlock Type

- Lua-facing map block exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapBlock:getHeight() -> integer`: Get height in tiles for this object.
- `LMapBlock:getLayerCount() -> integer`: Get the number of tile layers in this map block.
- `LMapBlock:getName() -> string`: Get the map block's display or lookup name string value.
- `LMapBlock:getTile(layer, x, y, slot) -> integer`: Get the tile GID at a specified row and column position.
- `LMapBlock:getWidth() -> integer`: Get the block width measured in tile grid units.
- `LMapBlock:setEdge(edge, segment, edge_type) -> nil`: Set edge type for a side and segment.
- `LMapBlock:setEdgeOnly(edge_only) -> nil`: Set whether block must be on map edge.
- `LMapBlock:setInteriorOnly(interior_only) -> nil`: Set whether block must be in interior.
- `LMapBlock:setLevelSpan(levels) -> nil`: Set multi-level span for this object.
- `LMapBlock:setName(name) -> nil`: Set the map block's display or lookup name string value.
- `LMapBlock:setTile(layer, x, y, slot, tileset_id, gid) -> nil`: Set a tile slot value â€” Lua userdata object exposed by the engine.
- `LMapBlock:setWeight(weight) -> nil`: Set block weight for random selection.

#### LMapBlockConfig Type

- Lua-facing map block configuration.

##### Fields

- No documented fields.

##### Methods

- `LMapBlockConfig:addSlot(name, required?, default_gid?) -> nil`: Add a slot definition â€” Lua userdata object exposed by the engine.
- `LMapBlockConfig:getSlotCount() -> integer`: Get the number of slots for this object.
- `LMapBlockConfig:removeSlot(name) -> boolean`: Remove a slot by name for this object.
- `LMapBlockConfig:setDefaultSegmentSize(size) -> nil`: Set default segment size for this object.
- `LMapBlockConfig:setMaxLayers(max) -> nil`: Set maximum layers per block for this object.

#### LMapBlockGenerator Type

- Lua-facing generator exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapBlockGenerator:addGroup(group) -> nil`: Add a named block group definition to this map generator.
- `LMapBlockGenerator:generate(script) -> MapBlockResult`: Generate map using a script for this object.
- `LMapBlockGenerator:getLastPlacedCount() -> integer`: Get last placement count for this object.
- `LMapBlockGenerator:setMaxLevels(levels) -> nil`: Set the number of vertical levels or storeys to generate.
- `LMapBlockGenerator:setOrientation(orientation) -> nil`: Set rendering orientation for this object.
- `LMapBlockGenerator:setRectShape(width, height) -> nil`: Set rectangular map shape â€” Lua userdata object exposed by the engine.
- `LMapBlockGenerator:setRules(rules) -> nil`: Set neighbor matching rules for this object.
- `LMapBlockGenerator:setSeed(seed) -> nil`: Set RNG seed for deterministic generation.
- `LMapBlockGenerator:setShape(positions) -> nil`: Set the generator map shape using a list of tile positions.
- `LMapBlockGenerator:setTileSize(w, h) -> nil`: Set tile pixel dimensions for this object.

#### LMapBlockResult Type

- Lua-facing generation result exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapBlockResult:getBlocksPlaced() -> integer`: Get number of blocks placed for this object.
- `LMapBlockResult:getGid(level, layer, x, y, slot) -> integer`: Get tile GID at position for this object.
- `LMapBlockResult:getHeight() -> integer`: Get total height in tiles â€” Lua userdata object exposed by the engine.
- `LMapBlockResult:getLayerCount() -> integer`: Get number of layers for this object.
- `LMapBlockResult:getLevelCount() -> integer`: Get number of levels for this object.
- `LMapBlockResult:getWidth() -> integer`: Get total width in tiles for this object.
- `LMapBlockResult:isEmpty() -> boolean`: Check if result is empty for this object.

#### LMapGroup Type

- Lua-facing map group exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapGroup:addBlock(block) -> nil`: Add a block to this group for this object.
- `LMapGroup:addScript(script) -> nil`: Add a script to this group for this object.
- `LMapGroup:getBlockCount() -> integer`: Get the number of blocks for this object.
- `LMapGroup:getName() -> string`: Get the display name of this map group object.

#### LMapScript Type

- Lua-facing map script exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapScript:addStep(step_type, opts?) -> nil`: Add a generation step â€” Lua userdata object exposed by the engine.
- `LMapScript:clear() -> nil`: Clear all queued script steps from this map script.
- `LMapScript:getName() -> string`: Get the script name for this object.
- `LMapScript:getStepCount() -> integer`: Get the number of steps for this object.

#### LNeighborRules Type

- Lua-facing neighbor rules exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LNeighborRules:addCompatible(type_a, type_b) -> nil`: Add bidirectional compatibility between two edge types.
- `LNeighborRules:addCompatibleOneWay(type_a, type_b) -> nil`: Add one-way compatibility for this object.
- `LNeighborRules:clear() -> nil`: Clear all neighbor placement rules from this rule set.
- `LNeighborRules:isCompatible(type_a, type_b) -> boolean`: Check if two edge types are compatible.

#### LPlacementGrid Type

- Lua-facing placement grid exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LPlacementGrid:addPosition(x, y) -> nil`: Add a position to the grid â€” Lua userdata object exposed by the engine.
- `LPlacementGrid:clear() -> nil`: Clear all positions and placed blocks.
- `LPlacementGrid:getAvailableCount() -> integer`: Get available position count for this object.
- `LPlacementGrid:isAvailable(x, y) -> boolean`: Check whether a placement grid position is currently available.

#### LTilesetRef Type

- Lua-facing tileset reference exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LTilesetRef:getId() -> integer`: Get the numeric tileset ID for this tileset reference.
- `LTilesetRef:getName() -> string`: Get tileset name â€” Lua userdata object exposed by the engine.
- `LTilesetRef:setImagePath(path) -> nil`: Set the image file path for this tileset reference.
