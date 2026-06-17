# mapblock

## TL;DR

- Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/mapblock/`
- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`
- Lua API surface: `10` functions, `9` types, `63` methods
- Rust test path(s): tests/rust/unit/mapblock_tests.rs
- Lua test path(s): tests/lua/unit/test_mapblock_unit.lua, tests/lua/evidence/test_mapblock_evidence.lua, content/games/puzzle/mapblock_labyrinth/test.lua

## Summary

- This module gives users procedural map assembly from reusable authored blocks.
- Blocks package tile data, sockets, and metadata so placement remains data-driven.
- Neighbor constraints enforce legal block adjacency and prevent invalid seams.
- Scripted generation steps support fill, targeted placement, random placement, backtracking shape solving, and repeats.
- Placement grids track occupancy and legality during generation, including arbitrary non-rectangular shapes.
- Multi-level support enables stacked floors and vertical map structures.
- Orientation support covers top-down and isometric output expectations.
- Weighted groups support biome or theme-biased block selection.
- Footprint-aware blocks can express polyomino and province-style shapes with rotation and mirroring.
- Deterministic seeded generation supports reproducible builds.
- Placement exports expose block names, transforms, and covered cells for downstream tools and demos.
- Tileset references map block slots into concrete output tile identifiers.
- Output conversion produces renderer-ready layered tilemap structures.
- This module is useful for dungeons, city chunks, and modular world assembly.
- It keeps generation logic separate from final render map representation.
- For users, it reduces hand-authored map workload while preserving authored control.
- It also improves iteration speed for procedural level design workflows.
- Overall, users get a complete block-based map generation pipeline in one module.
- The practical value is reliable procedural layout with explicit constraint control.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### block.rs

- Fundamental mapblock unit combining tile payloads, edge sockets, and metadata. `mapblock/block` delivers the block implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Carries the data needed to match blocks during procedural placement. The file owns or coordinates data contracts including `Edge`, `MapBlock`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores selection weighting, naming, and tileset references for later output. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_legacy`, `get_width`, `get_height`, `get_layer_count`, `get_layer`, and 25 more stays attached to the local data model and invariants.
- Encodes the local shape and slot content that downstream stages consume. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Keeps neighbor semantics alongside the block so validation stays data-driven. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Acts as the atomic building piece for the entire mapblock pipeline. The file boundary separates mapblock implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### config.rs

- Runtime configuration for mapblock generation shape, slots, and randomness. `mapblock/config` delivers the configuration schema and defaults for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Holds grid dimensions, layer limits, and placement behavior flags. The file owns or coordinates data contracts including `MapBlockConfig`, `SlotDef`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores seed and retry controls for deterministic or exploratory runs. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `empty`, `add_slot`, `remove_slot`, `slot_index`, `slot_count`, and 2 more stays attached to the local data model and invariants.
- Defines the slot schema that orders per-tile payload interpretation. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### constraints.rs

- Edge compatibility rules that decide whether neighboring blocks can connect. `mapblock/constraints` delivers the constraints implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Describes socket-style match data per edge for fine-grained placement checks. The file owns or coordinates data contracts including `EdgeConstraint`, `NeighborRules`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides opposite-edge helpers for two-sided adjacency validation. Public callable behavior is centered on `opposite_edge`, while method-level behavior such as `new`, `add_compatible`, `add_compatible_one_way`, `is_compatible`, `set_edge_required`, `set_interior_only`, and 4 more stays attached to the local data model and invariants.
- Keeps connection semantics data-driven instead of hard-coded. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### generator.rs

- Operational core for scripted mapblock assembly over a block grid. `mapblock/generator` delivers the generator implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Owns block registries, multi-level placement state, and RNG progression. The file owns or coordinates data contracts including `MapBlockGenerator`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Executes fill, targeted placement, random placement, and repeat steps. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_rect_shape`, `set_shape`, `set_grid`, `set_orientation`, `set_max_levels`, and 9 more stays attached to the local data model and invariants.
- Applies neighbor constraints to keep layouts structurally coherent. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Threads orientation and config context through the build process. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Converts intermediate placements into renderer-ready output structures. The file boundary separates mapblock implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### group.rs

- Named block group for themed procedural generation passes. `mapblock/group` delivers the group implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Carries weighted selection metadata for controlled randomness. The file owns or coordinates data contracts including `MapGroup`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Lets scripts reference semantic groups instead of numeric ids. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_block`, `get_block`, `get_block_mut`, `block_count`, `remove_block`, and 8 more stays attached to the local data model and invariants.
- Supports biome-style or region-style content curation. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### layer.rs

- Per-level tile storage for multi-storey mapblock outputs. `mapblock/layer` delivers the layer implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Manages independent 2D block layers indexed by non-negative vertical levels. The file owns or coordinates data contracts including `BlockLayer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides bounds-aware tile access and mutation for placement operations. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `width`, `height`, `get_tile`, `get_tile_mut`, `set_tile_slot`, and 4 more stays attached to the local data model and invariants.
- Keeps slot counts and layer dimensions aligned with global config. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### maptile.rs

- Atomic tile payload composed from configurable slot values and metadata. `mapblock/maptile` delivers the maptile implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes tile-slot identifiers that point at tileset entries for rendering and logic. The file owns or coordinates data contracts including `MapTile`, `TileSlot`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Distinguishes slot roles so ordered drawing stays consistent. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `is_empty`, `set_slot`, `get_slot`, `clear_slot` stays attached to the local data model and invariants.

### mod.rs

- High-level mapblock module that wires blocks, scripts, constraints, and output conversion together. `mapblock/mod` is the mapblock module index, declaring `block`, `config`, `constraints`, `generator`, `group`, and 8 more so agents can identify which files own each feature slice before opening implementation code.
- Exposes the procedural assembly surface used to build tilemaps from authored content. `src/mapblock/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `block::{Edge, MapBlock}`, `config::MapBlockConfig`, `constraints::{EdgeConstraint, NeighborRules}`, `generator::MapBlockGenerator`, and 9 more centralized for the mapblock subsystem.
- Keeps layered generation, orientation handling, and placement validation under one namespace. The file documents how mapblock submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `mapblock/mod` is the mapblock module index, declaring `block`, `config`, `constraints`, `generator`, `group`, and 8 more so agents can identify which files own each feature slice before opening implementation code.
- `src/mapblock/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `block::{Edge, MapBlock}`, `config::MapBlockConfig`, `constraints::{EdgeConstraint, NeighborRules}`, `generator::MapBlockGenerator`, and 9 more centralized for the mapblock subsystem.
- The file documents how mapblock submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### multilevel.rs

- Multilevel container for placed blocks across vertical storeys. `mapblock/multilevel` delivers the multilevel implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks level metadata and block placements with bounds-safe access patterns. The file owns or coordinates data contracts including `MultiLevelMap`, `LevelData`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports mutation and query by level and grid coordinate during generation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `level_count`, `get_level`, `get_level_mut`, `add_block_to_level`, `total_block_count`, and 5 more stays attached to the local data model and invariants.
- Preserves structure needed for serialization and output transformation. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### orientation.rs

- Orientation modes for interpreting generated mapblock layouts. `mapblock/orientation` delivers the orientation implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides top-down and isometric variants for different presentation styles. The file owns or coordinates data contracts including `MapOrientation`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supplies parsing and helpers used by config-driven renderer integration. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str` stays attached to the local data model and invariants.

### output.rs

- Final mapblock conversion layer that turns placements into tile data outputs. `mapblock/output` delivers the output implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Translates layered slot payloads into ordered tile layers and resolved tileset ids. The file owns or coordinates data contracts including `PaintRectOp`, `PlacementRecord`, `MapBlockResultBuild`, `MapBlockResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies orientation and level handling so exports match runtime presentation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `get_tile`, `get_gid`, `is_empty`, `placements` stays attached to the local data model and invariants.
- Produces owned result structures detached from mutable generator state. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the last step in the mapblock build pipeline. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### placement.rs

- Placement-grid state and legality checks for mapblock assembly operations. `mapblock/placement` delivers the placement implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks occupied cells and placed-block metadata used by scripted steps. The file owns or coordinates data contracts including `PlacedBlock`, `PlacementCandidate`, `PlacementSearch`, `PlacementGrid`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Evaluates candidates against edge constraints and neighborhood compatibility rules. Public callable behavior is centered on `find_valid_placements`, while method-level behavior such as `new`, `new_rect`, `add_position`, `remove_position`, `add_positions`, `is_available`, and 11 more stays attached to the local data model and invariants.
- Enumerates valid placements for deterministic or random selection passes. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Records coordinates and orientation details for downstream processing. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### script.rs

- Scripted step language that drives procedural mapblock generation flow. `mapblock/script` delivers the script implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes fill, targeted placement, random placement, and repeat operations. The file owns or coordinates data contracts including `StepType`, `ScriptStep`, `MapScript`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores ordered step sequences consumed directly by the execution engine. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_step`, `add_step_simple`, `get_step`, `get_step_mut`, `step_count`, and 5 more stays attached to the local data model and invariants.
- Supports data-driven authoring and runtime construction of generation programs. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### tileset_ref.rs

- Tileset reference metadata used to resolve slot values into concrete tile resources. `mapblock/tileset_ref` delivers the tileset ref implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores tileset identity, sizing, and index-offset data shared across blocks. The file owns or coordinates data contracts including `TilesetRef`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports reuse of one tileset with different offset conventions per content group. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_image_path`, `id`, `name` stays attached to the local data model and invariants.



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

- `LMapBlock:getFootprintCellCount() -> integer`: Get the number of occupied footprint cells.
- `LMapBlock:getHeight() -> integer`: Get height in tiles for this object.
- `LMapBlock:getLayerCount() -> integer`: Get the number of tile layers in this map block.
- `LMapBlock:getName() -> string`: Get the map block's display or lookup name string value.
- `LMapBlock:getSocket(x, y, edge) -> integer`: Get a previously stored per-cell socket type.
- `LMapBlock:getTile(layer, x, y, slot) -> integer`: Get the tile GID at a specified row and column position.
- `LMapBlock:getWeight() -> number`: Get block weight for random selection.
- `LMapBlock:getWidth() -> integer`: Get the block width measured in tile grid units.
- `LMapBlock:isFootprintCell(x, y) -> boolean`: Check whether a local footprint cell exists.
- `LMapBlock:setEdge(edge, segment, edge_type) -> nil`: Set edge type for a side and segment.
- `LMapBlock:setEdgeOnly(edge_only) -> nil`: Set whether block must be on map edge.
- `LMapBlock:setFootprint(cells) -> nil`: Replace the placement footprint with a custom cell list.
- `LMapBlock:setInteriorOnly(interior_only) -> nil`: Set whether block must be in interior.
- `LMapBlock:setLevelSpan(levels) -> nil`: Set multi-level span for this object.
- `LMapBlock:setName(name) -> nil`: Set the map block's display or lookup name string value.
- `LMapBlock:setSocket(x, y, edge, edge_type) -> nil`: Set a per-cell socket type for one edge of the footprint.
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
- `LMapBlockGenerator:setGrid(grid) -> nil`: Set the placement grid from a prepared PlacementGrid object.
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
- `LMapBlockResult:getPlacements() -> table`: Get placement summaries from the last generation run.
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
- `LPlacementGrid:isEdgePosition(x, y) -> boolean`: Check whether a cell touches the placement-shape boundary.
- `LPlacementGrid:removePosition(x, y) -> nil`: Remove an available position from the grid.

#### LTilesetRef Type

- Lua-facing tileset reference exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LTilesetRef:getId() -> integer`: Get the numeric tileset ID for this tileset reference.
- `LTilesetRef:getName() -> string`: Get tileset name â€” Lua userdata object exposed by the engine.
- `LTilesetRef:setImagePath(path) -> nil`: Set the image file path for this tileset reference.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
