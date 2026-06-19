# mapblock

## TL;DR

- Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/mapblock/`
- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`
- Lua API surface: `10` functions, `10` types, `67` methods
- Rust test path(s): tests/rust/unit/mapblock_tests.rs
- Lua test path(s): tests/lua/unit/test_mapblock_unit.lua, tests/lua/evidence/test_mapblock_evidence.lua, content/games/puzzle/mapblock_labyrinth/test.lua

## Summary

- The `mapblock` module is the engine's modular map-assembly surface for users who want larger spaces built from reusable authored blocks instead of from one monolithic generator.
- Blocks, sockets, constraints, groups, scripts, orientation rules, and multilevel placement live together here so handcrafted pieces can recombine without losing local design intent.
- The module is especially useful for dungeons, modular interiors, overworld chunks, and other generators where the meaningful unit is a room or chunk rather than an individual tile.
- Constraint and socket logic are central because modular generation only works when legal adjacency, facing, and connector rules remain explicit and enforceable.
- Placement state and output shaping matter because the system must not only choose valid pieces, but also produce results that downstream tilemap, navigation, and render workflows can use safely.
- Construction and generation now reject oversized block requests, invalid weights, and level-span overflow before they can degrade into silent no-ops or unchecked allocation paths.
- Rust callers can inspect per-run generator diagnostics for missing groups, unsupported steps, invalid weights, placement stalls, and rejected paint operations.
- Script hooks and grouping support make the system adaptable to thematic or progression-aware generation, which is important when modular pieces need more nuance than simple random choice.
- Orientation and multilevel handling matter because reusable blocks often connect vertically or directionally, and the legality of the final layout depends on those relationships being tracked explicitly.
- This makes the module useful whenever designed pieces need to stay meaningful after recombination. A corridor, room, bridge, or stair block can keep its authored purpose while still participating in procedural assembly.
- It preserves authored intent while still enabling recombination.
- Neighboring modules consume the output, but `mapblock` owns the modular grammar that decides how authored fragments connect into a legal larger space.
- Read `mapblock` as the subsystem that turns reusable map pieces into generated layouts with explicit connection rules.

This module primarily collaborates with `procgen`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Imports

- `procgen`: Imports or references `src/procgen/`. Cross-group dependency from ``Edge/Integration`` into `Foundations`.

## Files

### block.rs

- This file owns the atomic mapblock model, combining tile layers, edge sockets, footprint cells, and author metadata.
- `MapBlock` stores dimensions, layers, slot count, side rules, custom sockets, weight flags, and vertical span data.
- `Edge` also lives here because block-local side identity is part of geometry and compatibility ownership.
- Legacy construction remains here so old raw layer data can be upgraded into the modern layered block structure.
- Tile setters and getters stay here because `MapBlock` is the first owner above `BlockLayer` for authored content.
- Footprint normalization and transformed socket maps belong here because rotation and mirroring start at block scope.
- Segment counts, transformed sizes, and legacy socket derivation stay local because they describe one block's geometry.
- Open it when block semantics change; candidate search, scripts, and result export build directly on this owner.

### config.rs

- This file owns global mapblock configuration, especially slot schema, max layer count, and default segment sizing.
- `MapBlockConfig` stores ordered `SlotDef` entries so every tile and block interprets slot positions consistently.
- Default floor, roof, object, and wall slots live here because authored slot vocabulary is a subsystem contract.
- Layer and segment setters stay here because these knobs shape block construction before any placement begins.
- Open it when slot schema changes; tile payloads, generation steps, and export assembly live in sibling files.

### constraints.rs

- This file owns neighbor compatibility rules, edge requirements, and interior-only placement constraints for blocks.
- `EdgeConstraint` describes one socket on one edge segment, while `NeighborRules` stores compatibility and flags.
- Bidirectional and one-way compatibility registration lives here because adjacency policy is data, not generator code.
- `opposite_edge` also stays here so socket comparison logic can share one canonical edge-direction helper.
- Open it when placement legality changes; block geometry, candidate search, and scripted execution live in siblings.

### generator.rs

- This file owns the operational mapblock engine that runs scripts, tracks RNG, and mutates placement state over time.
- `MapBlockGenerator` stores config, grid, rules, orientation, groups, levels, paint ops, and output tile sizing knobs.
- It reuses the shared `procgen::Lcg` so deterministic picks follow one engine-wide RNG contract.
- `generate` orchestrates the whole build, resetting state, running each script step, and then materializing output.
- Random, fixed, edge, auto, rectangle-paint, and shape-solver step handlers all live here as runtime control flow.
- Weighted block choice and candidate ordering stay here because authored content selection is step execution logic.
- Backtracking shape solving stays local because it recursively consumes placement candidates against the live grid state.
- `MapBlockReport` and `place_candidate` bridge execution outcomes into diagnostics, `PlacementGrid`, and `MultiLevelMap`.
- Open it when generation behavior changes; blocks, scripts, legality checks, and result export live in sibling owners.

### group.rs

- This file owns named collections of blocks and scripts used as one authored theme or generation content pack.
- `MapGroup` stores its display name plus ordered `MapBlock` and `MapScript` arrays for later weighted selection.
- Lookup and mutation helpers stay here because grouping content is an authoring concern, not a placement algorithm.
- Open it when content organization changes; block geometry, step execution, and output conversion live in siblings.

### layer.rs

- This file owns one 2D block layer, storing width, height, slot count, and row-major `MapTile` cells.
- `BlockLayer` exposes bounds-checked tile reads, mutable access, slot writes, fill, clear, and slot-count inspection.
- Layer-wide mutation lives here because tile-grid indexing and reset behavior belong below `MapBlock` orchestration.
- Open it when per-layer tile storage changes; block footprints, placement logic, and export passes live in siblings.

### maptile.rs

- This file owns the atomic tile payload used inside block layers, including per-slot tileset and gid assignments.
- `MapTile` stores an ordered slot vector, while `TileSlot` carries one `(tileset_id, gid)` pair or an empty state.
- Slot mutation helpers live here because writing, clearing, and emptiness checks belong to the smallest tile owner.
- Open it when slot semantics change; layer grids, block footprints, and export assembly live in sibling files.

### mod.rs

- This module is the mapblock index, exposing authored blocks, constraints, scripts, placement, and output conversion.
- It reexports `MapBlockGenerator`, block types, script data, placement state, and result carriers as one surface.
- `block.rs` owns atomic block geometry, while `placement.rs` and `generator.rs` own legality checks and execution flow.
- `config.rs`, `maptile.rs`, `layer.rs`, and `tileset_ref.rs` define the slot, tile, and tileset contracts here.
- `output.rs` and `multilevel.rs` handle built-map materialization, while `group.rs` and `script.rs` organize content.
- Open this file to navigate ownership quickly; actual generation logic, transforms, and storage live in sibling files.

### multilevel.rs

- This file owns placed-block storage across vertical storeys, organizing generation output into indexed levels.
- `MultiLevelMap` stores precreated `LevelData` entries, while each level holds placed blocks and height metadata.
- Add, clear, and per-level access helpers live here because storey management is separate from 2D grid legality.
- The file is the vertical container boundary later consumed by output building, not by tile or socket mutation.
- Open it when multi-level ownership changes; placement search, scripts, and final tile export live in siblings.

### orientation.rs

- This file owns mapblock orientation labels, mapping authored strings to top-down or isometric output modes.
- `MapOrientation` is the only contract here, carrying the projection choice later consumed by config and result builders.
- Open it when projection naming changes; block geometry, placement legality, and rendering output live in siblings.

### output.rs

- This file owns the final mapblock export layer that converts placed blocks and paint ops into tiled output buffers.
- `MapBlockResult` stores tile data by level, layer, tile index, and slot, plus placement summaries for inspection.
- `MapBlockResultBuild` and `PaintRectOp` live here because they define the immutable inputs for result materialization.
- Block-to-tile copying stays here since rotation, mirroring, offsets, levels, and slot writes are export semantics.
- Direct paint application also belongs here because post-placement fills mutate only the finalized result surface.
- `transform_tile` stays local because export-time coordinate remapping is specific to rotated and mirrored block copying.
- Open it when output layout changes; generation flow, placement legality, and authored block content live in siblings.

### placement.rs

- This file owns grid-shape state and candidate legality checks for placing transformed blocks onto available cells.
- `PlacementGrid` stores available cells, occupied cells, placed-block records, and a reverse map from cell to placement.
- `PlacedBlock`, `PlacementCandidate`, and `PlacementSearch` live here because they describe the search and commit states.
- Rectangular and arbitrary-shape grid setup belongs here because map shape is separate from authored block geometry.
- `find_valid_placements` also stays here, combining transformed footprints, edge-only rules, and occupied-cell checks.
- Neighbor compatibility evaluation is local because socket matching depends on grid state plus `NeighborRules` policy.
- Open it when placement legality changes; block definitions, scripted execution, and output building live in siblings.

### script.rs

- This file owns the authored step language that drives mapblock generation passes and post-placement paint actions.
- `StepType` names the generation verbs, `ScriptStep` stores their parameters, and `MapScript` keeps ordered steps.
- Default step values live here because random rotation, mirroring, chance, level, and slot settings shape execution.
- Script mutation helpers also stay here so authoring and runtime construction share one stable step-data owner.
- Open it when generation verbs change; block legality, candidate search, and result assembly live in siblings.

### tileset_ref.rs

- This file owns tileset reference metadata used by mapblocks to resolve slot values into concrete art resources.
- `TilesetRef` stores ids, display name, atlas dimensions, tile sizes, and an optional image path for authored content.
- Simple setters and accessors stay here because tileset identity is metadata, not generator or placement behavior.
- Open it when asset reference fields change; tile payloads, blocks, and output assembly live in sibling files.



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
- `LMapBlockGenerator:generateWithReport(script) -> MapBlockResult`: Generate map using a script and return runtime diagnostics for this object.
- `LMapBlockGenerator:getLastPlacedCount() -> integer`: Get last placement count for this object.
- `LMapBlockGenerator:getLastReport() -> MapBlockReport`: Get the diagnostic report captured during the previous generation run.
- `LMapBlockGenerator:setGrid(grid) -> nil`: Set the placement grid from a prepared PlacementGrid object.
- `LMapBlockGenerator:setMaxLevels(levels) -> nil`: Set the number of vertical levels or storeys to generate.
- `LMapBlockGenerator:setOrientation(orientation) -> nil`: Set rendering orientation for this object.
- `LMapBlockGenerator:setRectShape(width, height) -> nil`: Set rectangular map shape â€” Lua userdata object exposed by the engine.
- `LMapBlockGenerator:setRules(rules) -> nil`: Set neighbor matching rules for this object.
- `LMapBlockGenerator:setSeed(seed) -> nil`: Set RNG seed for deterministic generation.
- `LMapBlockGenerator:setShape(positions) -> nil`: Set the generator map shape using a list of tile positions.
- `LMapBlockGenerator:setSolverBudget(opts) -> nil`: Set bounded recursion budgets for `solve_shape`.
- `LMapBlockGenerator:setTileSize(w, h) -> nil`: Set tile pixel dimensions for this object.

#### LMapBlockReport Type

- Lua-facing generation diagnostics exposed by the lurek engine.

##### Fields

- No documented fields.

##### Methods

- `LMapBlockReport:toTable() -> table`: Serialize generation diagnostics into a plain Lua table.

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

- `procgen`: Imports or references `src/procgen/`. Cross-group dependency from ``Edge/Integration`` into `Foundations`.

## Notes

- No additional module-specific notes.
