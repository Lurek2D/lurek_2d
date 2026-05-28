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

## Source Documentation

### `block.rs`
- Map block definition: tile slots, edge connection points, and per-block metadata.
- `MapBlock` holds a grid of `MapTile` slots and a set of edge constraint descriptors.
- `BlockMeta` carries the name, weight, group membership, and tileset reference.
- Blocks are loaded from TOML files under `content/maps/blocks/`.
- Exposed to Lua via `lurek.mapblock.define(spec)` for runtime registration.

### `config.rs`
- Map block generator configuration: grid dimensions, seed, and global assembly rules.
- `MapBlockConfig` is deserialized from the `[mapblock]` section of a game TOML.
- Controls output grid width/height, RNG seed, and whether to allow backtracking.
- `retry_limit` caps backtrack iterations; exceeded limit falls back to a blank tile.
- Seed 0 uses the current wall-clock time for non-deterministic generation.

### `constraints.rs`
- Carcassonne-style edge constraints for matching adjacent map blocks.
- `EdgeConstraint` describes what socket types are legal on each of the 4 cardinal edges.
- `opposite_edge` returns the mirror direction (North↔South, East↔West).
- Constraint checking is O(1) per neighbor pair; the full grid check is O(w×h).
- Socket type strings are arbitrary game-defined labels (e.g. `"road"`, `"river"`).

### `generator.rs`
- Scripted procedural map assembler: executes a sequence of placement steps.
- `MapBlockGenerator` owns the grid, block registry, and RNG state.
- Runs the `MapScript` step list: Fill, PlaceGroup, PlaceBlock, ApplyLayer.
- After assembly, converts the grid to a `TileMap` via `mapblock::output`.
- Exposed to Lua via `lurek.mapblock.generate(config, script)` returning a tilemap.

### `group.rs`
- Named block groups for weighted random selection and themed zone filling.
- `BlockGroup` holds a name and a `Vec<(block_id, weight)>` for weighted sampling.
- Groups are registered by name; scripts reference them by string, not index.
- `BlockGroup::pick(rng)` returns a block ID using alias-method weighted sampling.
- Useful for biome zones: register a `"forest"` group and fill a region by name.

### `layer.rs`
- Z-layer management for multi-storey and multi-level map construction.
- `LayerStack` holds a `Vec<MapBlockGrid>`, one per Z level starting from 0.
- Layers are independent grids; block placement in one layer does not affect another.
- Layer 0 is the ground floor; negative indices are not supported.
- The `MapBlockConfig::layer_count` field pre-allocates the stack at generator init.

### `maptile.rs`
- Map tile and slot definitions: floor, roof, object, wall, and custom-typed slots.
- `MapTile` is a struct of optional slot IDs: `floor`, `roof`, `object`, `wall`.
- Each slot references a tile ID in the associated tileset; `None` = empty.
- `TileSlotKind` distinguishes slot roles for rendering order and collision.
- `MapTile` is the leaf unit stored in every cell of a `MapBlockGrid`.

### `mod.rs`
- Map-block procedural assembly system.
- Builds tile maps from composable blocks using scripted placement.
- Supports configurable tile slots (floor, roof, object, walls, custom).
- Carcassonne-style neighbor edge matching for placement constraints.
- Multi-level (Z-layers) for multi-storey maps.
- TopDown and Isometric orientations (no hex).
- Arbitrary map shapes (not limited to rectangles).
- Output converts to standard `TileMap` for rendering.

### `multilevel.rs`
- Multi-level map data structure with per-level block grid accessors.
- `MultilevelMap` wraps `LayerStack` and exposes named-level access (floor, roof, etc.).
- Level names are user-defined strings registered at generator init time.
- Provides `get(level, x, y)` and `set(level, x, y, tile)` with bounds checking.
- Serialized as a flat array of (level, x, y, tile) tuples in the save file.

### `orientation.rs`
- Map orientation modes: TopDown and Isometric projection support.
- `Orientation` enum controls how (grid_x, grid_y) maps to screen (pixel_x, pixel_y).
- `TopDown` uses a direct pixel-per-tile scale with no shear.
- `Isometric` applies the standard 2:1 diamond transform for 2.5D appearance.
- The active orientation is set in `MapBlockConfig` and applied by the tilemap renderer.

### `output.rs`
- Output converter: transforms an assembled map block grid into a `TileMap`.
- `grid_to_tilemap(grid, tileset_id)` produces a `TileMap` ready for the renderer.
- Slot roles (floor/wall/object) are translated to `TileMap` layer indices.
- Block-local tile IDs are offset by the tileset base ID to produce world tile IDs.
- The returned `TileMap` is owned by the caller; no reference to the block grid is kept.

### `placement.rs`
- Block placement grid, valid-position search, and placed-block tracking.
- `PlacementGrid` tracks which cells are occupied and caches constraint state.
- `find_valid_positions(grid, block)` returns all (x, y) cells where the block fits.
- Placement validation is O(edges × constraints) per candidate cell.
- `PlacedBlock` records the block ID, position, and applied rotation for undo support.

### `script.rs`
- Script steps that drive the procedural map block generation sequence.
- `MapScript` is a `Vec<ScriptStep>` executed in order by the generator.
- `StepType` variants: `Fill`, `PlaceGroup`, `PlaceBlock`, `ApplyLayer`, `Repeat`.
- Steps can be loaded from TOML or constructed programmatically from Lua.
- `Repeat { count, steps }` nests a sub-list with its own RNG advancement.

### `tileset_ref.rs`
- Tileset reference: links a map block's tile slots to ID ranges in a tileset asset.
- `TilesetRef` stores the tileset asset key and a `base_id` offset applied to all tiles.
- Multiple blocks may reference the same tileset with different `base_id` offsets.
- Resolved at generator build time; missing tilesets produce a load-time error.
- The resolved tileset texture is loaded once and shared across all referencing blocks.

## Types

- `Edge` (`enum`, `block.rs`): Cardinal direction for block edges.
- `MapBlock` (`struct`, `block.rs`): A composable map block containing layers of tiles with edge constraints.
- `MapBlockConfig` (`struct`, `config.rs`): Configuration defining which tile slots exist in a map block system.
- `SlotDef` (`struct`, `config.rs`): A single slot definition within a tile.
- `EdgeConstraint` (`struct`, `constraints.rs`): A single edge constraint on a block.
- `NeighborRules` (`struct`, `constraints.rs`): Rules for neighbor matching between blocks.
- `MapBlockGenerator` (`struct`, `generator.rs`): Main generator that assembles maps from blocks using scripts.
- `MapGroup` (`struct`, `group.rs`): A named collection of blocks and scripts used together for generation.
- `BlockLayer` (`struct`, `layer.rs`): A single layer within a map block — a 2D grid of map tiles.
- `MapTile` (`struct`, `maptile.rs`): A single tile in a map block layer.
- `TileSlot` (`struct`, `maptile.rs`): A single slot value within a map tile.
- `MultiLevelMap` (`struct`, `multilevel.rs`): A complete multi-level map assembled from placed blocks on multiple storeys.
- `LevelData` (`struct`, `multilevel.rs`): Data for a single level/storey.
- `MapOrientation` (`enum`, `orientation.rs`): Projection / rendering orientation for the generated map.
- `MapBlockResult` (`struct`, `output.rs`): Result of map block generation — contains all placed tiles ready for rendering.
- `PlacedBlock` (`struct`, `placement.rs`): A block that has been placed on the map.
- `PlacementGrid` (`struct`, `placement.rs`): The placement grid — defines available positions and tracks placed blocks.
- `StepType` (`enum`, `script.rs`): Type of procedural map generation step executed by the build script.
- `ScriptStep` (`struct`, `script.rs`): A single step in a map generation script.
- `MapScript` (`struct`, `script.rs`): An ordered sequence of steps that drives one generation pass.
- `TilesetRef` (`struct`, `tileset_ref.rs`): Reference to a tileset used by map blocks.

## Functions

- `MapBlock::new` (`block.rs`): Create a new map block with given dimensions and layer count.
- `MapBlock::from_legacy` (`block.rs`): Create a block from legacy mapgen format (single layer, raw GID data).
- `MapBlock::get_width` (`block.rs`): Get the block width in tile units.
- `MapBlock::get_height` (`block.rs`): Get the block height in tile units.
- `MapBlock::get_layer_count` (`block.rs`): Get the total number of tile layers.
- `MapBlock::get_layer` (`block.rs`): Get an immutable tile layer by index.
- `MapBlock::get_layer_mut` (`block.rs`): Get a mutable tile layer by index.
- `MapBlock::add_layer` (`block.rs`): Add a new empty layer.
- `MapBlock::set_tile` (`block.rs`): Set a tile slot value at (layer, x, y, slot).
- `MapBlock::get_tile` (`block.rs`): Get a tile GID at (layer, x, y, slot).
- `MapBlock::get_tile_legacy` (`block.rs`): Legacy get_tile for single-slot blocks (slot 0, layer 0).
- `MapBlock::set_edge` (`block.rs`): Set edge type for a given side and segment index.
- `MapBlock::get_edge` (`block.rs`): Get edge type for a given side and segment index.
- `MapBlock::get_edge_constraints` (`block.rs`): Get all edge constraints for this block.
- `MapBlock::set_name` (`block.rs`): Set the display name of this block.
- `MapBlock::get_name` (`block.rs`): Get the display name of this block.
- `MapBlock::segments_horizontal` (`block.rs`): Get number of segments along an edge (width / segment_size or height / segment_size).
- `MapBlock::segments_vertical` (`block.rs`): Get number of segments along vertical edge.
- `MapBlockConfig::new` (`config.rs`): Create a new config with default slots: floor, roof, object, left_wall, right_wall.
- `MapBlockConfig::empty` (`config.rs`): Create an empty config with no predefined slots.
- `MapBlockConfig::add_slot` (`config.rs`): Add a custom slot definition.
- `MapBlockConfig::remove_slot` (`config.rs`): Remove a slot by name.
- `MapBlockConfig::slot_index` (`config.rs`): Get the position index of a named slot.
- `MapBlockConfig::slot_count` (`config.rs`): Get the number of defined slots.
- `MapBlockConfig::set_max_layers` (`config.rs`): Set maximum layers per block.
- `MapBlockConfig::set_default_segment_size` (`config.rs`): Set the default edge segment size.
- `NeighborRules::new` (`constraints.rs`): Create empty neighbor rules.
- `NeighborRules::add_compatible` (`constraints.rs`): Add a bidirectional compatibility rule: type_a matches type_b and vice versa.
- `NeighborRules::add_compatible_one_way` (`constraints.rs`): Add a one-directional compatibility rule: type_a matches type_b (but not reverse).
- `NeighborRules::is_compatible` (`constraints.rs`): Check if two edge types are compatible.
- `NeighborRules::set_edge_required` (`constraints.rs`): Mark a block index as requiring edge placement.
- `NeighborRules::set_interior_only` (`constraints.rs`): Mark a block index as interior-only (cannot be on edge).
- `NeighborRules::is_edge_required` (`constraints.rs`): Check if a block index requires edge placement.
- `NeighborRules::is_interior_only` (`constraints.rs`): Check if a block index is interior-only.
- `NeighborRules::get_compatible` (`constraints.rs`): Get all compatible types for a given edge type.
- `NeighborRules::clear` (`constraints.rs`): Clear all compatibility and constraint rules.
- `opposite_edge` (`constraints.rs`): Return the opposite edge direction.
- `MapBlockGenerator::new` (`generator.rs`): Create a new generator with default configuration.
- `MapBlockGenerator::set_rect_shape` (`generator.rs`): Set the map shape as a rectangular grid.
- `MapBlockGenerator::set_shape` (`generator.rs`): Set the map shape from arbitrary positions.
- `MapBlockGenerator::set_grid` (`generator.rs`): Set the placement grid directly.
- `MapBlockGenerator::set_orientation` (`generator.rs`): Set the map rendering orientation.
- `MapBlockGenerator::set_max_levels` (`generator.rs`): Set the number of levels (storeys).
- `MapBlockGenerator::set_rules` (`generator.rs`): Set the neighbor placement rules.
- `MapBlockGenerator::set_seed` (`generator.rs`): Set the random number generator seed.
- `MapBlockGenerator::set_tile_size` (`generator.rs`): Set tile pixel dimensions for output conversion.
- `MapBlockGenerator::add_group` (`generator.rs`): Add a named group of map blocks.
- `MapBlockGenerator::get_group` (`generator.rs`): Get a named block group by name.
- `MapBlockGenerator::generate` (`generator.rs`): Generate the map using a script.
- `MapBlockGenerator::last_placed_count` (`generator.rs`): Get the last placement count.
- `MapBlockGenerator::config` (`generator.rs`): Get the current configuration.
- `MapBlockGenerator::orientation` (`generator.rs`): Get the current orientation.
- `MapGroup::new` (`group.rs`): Create an empty group with the given name.
- `MapGroup::add_block` (`group.rs`): Append a map block to this group.
- `MapGroup::get_block` (`group.rs`): Get an immutable block by index.
- `MapGroup::get_block_mut` (`group.rs`): Get a mutable map block by index.
- `MapGroup::block_count` (`group.rs`): Get the total number of blocks in this group.
- `MapGroup::remove_block` (`group.rs`): Remove a map block at the given index.
- `MapGroup::add_script` (`group.rs`): Add a map script to this group.
- `MapGroup::get_script` (`group.rs`): Get an immutable script by index.
- `MapGroup::script_count` (`group.rs`): Get the number of scripts in this group.
- `MapGroup::name` (`group.rs`): Get this group's display name.
- `MapGroup::set_name` (`group.rs`): Set this group's display name.
- `MapGroup::blocks` (`group.rs`): Get all map blocks in this group as a slice.
- `MapGroup::scripts` (`group.rs`): Get all scripts in this group as a slice.
- `MapGroup::find_block` (`group.rs`): Find a block index by block name.
- `BlockLayer::new` (`layer.rs`): Create a new layer with given dimensions and slot count per tile.
- `BlockLayer::width` (`layer.rs`): Get the tile width of this layer.
- `BlockLayer::height` (`layer.rs`): Get the tile height of this layer.
- `BlockLayer::get_tile` (`layer.rs`): Get a tile reference at (x, y).
- `BlockLayer::get_tile_mut` (`layer.rs`): Get a mutable tile reference at (x, y).
- `BlockLayer::set_tile_slot` (`layer.rs`): Set a specific slot on a tile at (x, y).
- `BlockLayer::get_tile_gid` (`layer.rs`): Get the GID of a specific slot at (x, y).
- `BlockLayer::fill` (`layer.rs`): Fill entire layer with a single GID in a specific slot.
- `BlockLayer::clear` (`layer.rs`): Clear all tiles in this layer.
- `BlockLayer::slot_count` (`layer.rs`): Return the number of slots per tile.
- `TileSlot::new` (`maptile.rs`): Create a new tile slot with given tileset and GID.
- `TileSlot::is_empty` (`maptile.rs`): Check if this slot is empty (no tile assigned).
- `MapTile::new` (`maptile.rs`): Create a new tile with `slot_count` empty slots.
- `MapTile::set_slot` (`maptile.rs`): Set a tile slot value by slot index.
- `MapTile::get_slot` (`maptile.rs`): Get a tile slot value by slot index.
- `MapTile::clear_slot` (`maptile.rs`): Clear a slot, resetting it to empty.
- `MapTile::is_empty` (`maptile.rs`): Check if all tile slots are empty.
- `MultiLevelMap::new` (`multilevel.rs`): Create a new multi-level map with specified max levels.
- `MultiLevelMap::level_count` (`multilevel.rs`): Get the total number of map levels.
- `MultiLevelMap::get_level` (`multilevel.rs`): Get an immutable level by index.
- `MultiLevelMap::get_level_mut` (`multilevel.rs`): Get a mutable map level by index.
- `MultiLevelMap::add_block_to_level` (`multilevel.rs`): Add a placed block to a specific level.
- `MultiLevelMap::total_block_count` (`multilevel.rs`): Get total number of placed blocks across all levels.
- `MultiLevelMap::blocks_on_level` (`multilevel.rs`): Get all placed blocks on a specific level.
- `MultiLevelMap::set_level_height` (`multilevel.rs`): Set height for a specific level.
- `MultiLevelMap::clear` (`multilevel.rs`): Clear all placed blocks on all levels.
- `LevelData::is_empty` (`multilevel.rs`): Check if this level has any placed blocks.
- `LevelData::block_count` (`multilevel.rs`): Get the number of placed blocks on this level.
- `MapOrientation::from_name` (`orientation.rs`): Parse orientation from string.
- `MapOrientation::as_str` (`orientation.rs`): Convert to string representation.
- `MapBlockResult::new` (`output.rs`): Build the result from placement data.
- `MapBlockResult::get_tile` (`output.rs`): Get a tile slot value at (level, layer, x, y, slot).
- `MapBlockResult::get_gid` (`output.rs`): Get just the GID (ignoring tileset) at (level, layer, x, y, slot).
- `MapBlockResult::is_empty` (`output.rs`): Check if the result is empty (no blocks placed).
- `PlacementGrid::new` (`placement.rs`): Create a new empty placement grid.
- `PlacementGrid::new_rect` (`placement.rs`): Create a rectangular grid with positions from (0,0) to (width-1, height-1).
- `PlacementGrid::add_position` (`placement.rs`): Add a single available position.
- `PlacementGrid::remove_position` (`placement.rs`): Remove an available position.
- `PlacementGrid::add_positions` (`placement.rs`): Add positions from a list of (x, y) pairs.
- `PlacementGrid::is_available` (`placement.rs`): Check if a position is available (exists and not occupied).
- `PlacementGrid::is_edge_position` (`placement.rs`): Check if a position is on the edge of the available area.
- `PlacementGrid::place_block` (`placement.rs`): Place a block at a position.
- `PlacementGrid::get_block_at` (`placement.rs`): Get the block placed at a given position.
- `PlacementGrid::placed_blocks` (`placement.rs`): Get a slice of all placed blocks.
- `PlacementGrid::placed_count` (`placement.rs`): Get the number of placed blocks.
- `PlacementGrid::available_count` (`placement.rs`): Get the number of available (unfilled) positions.
- `PlacementGrid::available_positions` (`placement.rs`): Get all available (unfilled) positions.
- `PlacementGrid::bounds` (`placement.rs`): Get the bounding box of all available positions: (min_x, min_y, max_x, max_y).
- `PlacementGrid::clear_placed` (`placement.rs`): Clear all placed blocks (keep available positions).
- `PlacementGrid::clear` (`placement.rs`): Reset the entire placement grid.
- `find_valid_positions` (`placement.rs`): Find valid positions for a block given the current grid state and rules.
- `MapScript::new` (`script.rs`): Create an empty script with the given name.
- `MapScript::add_step` (`script.rs`): Append a new step to this script.
- `MapScript::add_step_simple` (`script.rs`): Add a step from type and group name with defaults.
- `MapScript::get_step` (`script.rs`): Get an immutable script step by index.
- `MapScript::get_step_mut` (`script.rs`): Get a mutable script step by index.
- `MapScript::step_count` (`script.rs`): Get the total number of steps in this script.
- `MapScript::remove_step` (`script.rs`): Remove a script step at the given index.
- `MapScript::clear` (`script.rs`): Clear all steps from this script.
- `MapScript::name` (`script.rs`): Get this script's display name.
- `MapScript::set_name` (`script.rs`): Set this script's display name.
- `MapScript::steps` (`script.rs`): Get all steps in this script as a slice.
- `TilesetRef::new` (`tileset_ref.rs`): Create a new tileset reference.
- `TilesetRef::set_image_path` (`tileset_ref.rs`): Set the image path for this tileset.
- `TilesetRef::id` (`tileset_ref.rs`): Get the numeric tileset identifier.
- `TilesetRef::name` (`tileset_ref.rs`): Get the display name of this tileset.

## Lua API Reference

- Binding path(s): `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`

### Module Functions
- `lurek.mapblock.newConfig`: Create a new map block configuration with default slots.
- `lurek.mapblock.newEmptyConfig`: Create an empty config with no predefined slots.
- `lurek.mapblock.newBlock`: Create a new map block exposed by the lurek engine.
- `lurek.mapblock.newGroup`: Create a new map group exposed by the lurek engine.
- `lurek.mapblock.newScript`: Create a new map script exposed by the lurek engine.
- `lurek.mapblock.newRules`: Create new neighbor rules exposed by the lurek engine.
- `lurek.mapblock.newGrid`: Create a rectangular placement grid.
- `lurek.mapblock.newEmptyGrid`: Create an empty placement grid (for arbitrary shapes).
- `lurek.mapblock.newGenerator`: Create a new procedural map block generator instance.
- `lurek.mapblock.newTilesetRef`: Create a tileset reference exposed by the lurek engine.

### `LMapBlock` Methods
- `LMapBlock:setTile`: Set a tile slot value — Lua userdata object exposed by the engine.
- `LMapBlock:getTile`: Get the tile GID at a specified row and column position.
- `LMapBlock:setEdge`: Set edge type for a side and segment.
- `LMapBlock:setName`: Set the map block's display or lookup name string value.
- `LMapBlock:getName`: Get the map block's display or lookup name string value.
- `LMapBlock:setWeight`: Set block weight for random selection.
- `LMapBlock:setEdgeOnly`: Set whether block must be on map edge.
- `LMapBlock:setInteriorOnly`: Set whether block must be in interior.
- `LMapBlock:setLevelSpan`: Set multi-level span for this object.
- `LMapBlock:getWidth`: Get the block width measured in tile grid units.
- `LMapBlock:getHeight`: Get height in tiles for this object.
- `LMapBlock:getLayerCount`: Get the number of tile layers in this map block.

### `LMapBlockConfig` Methods
- `LMapBlockConfig:addSlot`: Add a slot definition — Lua userdata object exposed by the engine.
- `LMapBlockConfig:removeSlot`: Remove a slot by name for this object.
- `LMapBlockConfig:getSlotCount`: Get the number of slots for this object.
- `LMapBlockConfig:setMaxLayers`: Set maximum layers per block for this object.
- `LMapBlockConfig:setDefaultSegmentSize`: Set default segment size for this object.

### `LMapBlockGenerator` Methods
- `LMapBlockGenerator:setRectShape`: Set rectangular map shape — Lua userdata object exposed by the engine.
- `LMapBlockGenerator:setShape`: Set the generator map shape using a list of tile positions.
- `LMapBlockGenerator:setOrientation`: Set rendering orientation for this object.
- `LMapBlockGenerator:setMaxLevels`: Set the number of vertical levels or storeys to generate.
- `LMapBlockGenerator:setRules`: Set neighbor matching rules for this object.
- `LMapBlockGenerator:setSeed`: Set RNG seed for deterministic generation.
- `LMapBlockGenerator:setTileSize`: Set tile pixel dimensions for this object.
- `LMapBlockGenerator:addGroup`: Add a named block group definition to this map generator.
- `LMapBlockGenerator:generate`: Generate map using a script for this object.
- `LMapBlockGenerator:getLastPlacedCount`: Get last placement count for this object.

### `LMapBlockResult` Methods
- `LMapBlockResult:getWidth`: Get total width in tiles for this object.
- `LMapBlockResult:getHeight`: Get total height in tiles — Lua userdata object exposed by the engine.
- `LMapBlockResult:getLevelCount`: Get number of levels for this object.
- `LMapBlockResult:getLayerCount`: Get number of layers for this object.
- `LMapBlockResult:getGid`: Get tile GID at position for this object.
- `LMapBlockResult:getBlocksPlaced`: Get number of blocks placed for this object.
- `LMapBlockResult:isEmpty`: Check if result is empty for this object.

### `LMapGroup` Methods
- `LMapGroup:addBlock`: Add a block to this group for this object.
- `LMapGroup:getBlockCount`: Get the number of blocks for this object.
- `LMapGroup:getName`: Get the display name of this map group object.
- `LMapGroup:addScript`: Add a script to this group for this object.

### `LMapScript` Methods
- `LMapScript:addStep`: Add a generation step — Lua userdata object exposed by the engine.
- `LMapScript:getStepCount`: Get the number of steps for this object.
- `LMapScript:clear`: Clear all queued script steps from this map script.
- `LMapScript:getName`: Get the script name for this object.

### `LNeighborRules` Methods
- `LNeighborRules:addCompatible`: Add bidirectional compatibility between two edge types.
- `LNeighborRules:addCompatibleOneWay`: Add one-way compatibility for this object.
- `LNeighborRules:isCompatible`: Check if two edge types are compatible.
- `LNeighborRules:clear`: Clear all neighbor placement rules from this rule set.

### `LPlacementGrid` Methods
- `LPlacementGrid:addPosition`: Add a position to the grid — Lua userdata object exposed by the engine.
- `LPlacementGrid:isAvailable`: Check whether a placement grid position is currently available.
- `LPlacementGrid:getAvailableCount`: Get available position count for this object.
- `LPlacementGrid:clear`: Clear all positions and placed blocks.

### `LTilesetRef` Methods
- `LTilesetRef:getId`: Get the numeric tileset ID for this tileset reference.
- `LTilesetRef:getName`: Get tileset name — Lua userdata object exposed by the engine.
- `LTilesetRef:setImagePath`: Set the image file path for this tileset reference.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/mapblock/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
