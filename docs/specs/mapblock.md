<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/mapblock.md or source docstrings instead. -->

# mapblock

## TL;DR

- Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids.

## General Info

- Module group: `Feature Systems`
- Source path: `src/mapblock`
- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`
- Lua API surface: `10` functions, `10` types, `67` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

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

## Ownership

- Canonical source: `src/mapblock`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/mapblock_api.rs`
- Referenced engine modules: `procgen`

## Imports

- `procgen`: Imports or references `src/procgen/`. Cross-group dependency from `Feature Systems` into `Foundations`.

## Source Files

### block.rs

- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around Edge, MapBlockLimits, default, with helpers kept close to their invariants.
- Defines how block data is validated, transformed, or stored before neighboring systems use it.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on block behavior while Lua registration stays elsewhere.
- Documents the boundary where mapblock code accepts inputs, reports errors, or updates state.
- Use this file when changing block defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the mapblock state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping block calculations explicit at their owner boundary.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.

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

- Owns the generation pipeline for the mapblock subsystem and keeps its rules local to this file.
- Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.
- Defines how generator data is validated, transformed, or stored before neighboring systems use it.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on generator behavior while Lua registration stays elsewhere.
- Documents the boundary where mapblock code accepts inputs, reports errors, or updates state.
- Use this file when changing generator defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the mapblock state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping generator calculations explicit at their owner boundary.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.

### group.rs

- This file owns named collections of blocks and scripts used as one authored theme or generation content pack.
- `MapGroup` stores its display name plus ordered `MapBlock` and `MapScript` arrays for later weighted selection.
- Lookup and mutation helpers stay here because grouping content is an authoring concern, not a placement algorithm.
- Open it when content organization changes; block geometry, step execution, and output conversion live in siblings.

### layer.rs

- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around BlockLayer, new, try_new, with helpers kept close to their invariants.
- Defines how layer data is validated, transformed, or stored before neighboring systems use it.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on layer behavior while Lua registration stays elsewhere.

### maptile.rs

- This file owns the atomic tile payload used inside block layers, including per-slot tileset and gid assignments.
- `MapTile` stores an ordered slot vector, while `TileSlot` carries one `(tileset_id, gid)` pair or an empty state.
- Slot mutation helpers live here because writing, clearing, and emptiness checks belong to the smallest tile owner.
- Open it when slot semantics change; layer grids, block footprints, and export assembly live in sibling files.

### mod.rs

- Indexes the mapblock subsystem and keeps exported submodules discoverable from one crate entry.
- Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.
- Separates navigation and module wiring from implementation so feature files own behavior directly.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps crate callers pointed at stable mapblock entrypoints while internals stay organized.
- Documents where mapblock callers should change defaults, errors, or lifecycle behavior. for engine changes.
- Indexes the mapblock subsystem and keeps exported submodules discoverable from one crate entry.
- Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.

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

- Owns the placement owner for the mapblock subsystem and keeps its rules local to this file.
- Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.
- Defines how placement data is validated, transformed, or stored before neighboring systems use it.
- Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on placement behavior while Lua registration stays elsewhere.
- Documents the boundary where mapblock code accepts inputs, reports errors, or updates state.
- Use this file when changing placement defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the mapblock state that can explain them while keeping call sites explicit.

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

## Examples

- `content/examples/mapblock.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_mapblock_unit.lua` (present)
- Rust: `tests/rust/unit/mapblock_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_mapblock_evidence.lua` |
| Golden test | `tests/lua/golden/test_mapblock_golden.lua` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_detail_level0.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_detail_level1.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_edge_interior_constraints.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_generation_timeline.gif` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_macro_placement.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_multilevel_layers.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_result_contract_histogram.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_script_pipeline_storyboard.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_scripted_paint_diagnostics.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_socket_constraints.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_solver_footprints.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_strategic_tactical_split.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_transform_export.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_two_level_cutaway.png` |
| Current artifact | `tests/artifacts/current/mapblock/mapblock_two_stage_manifest.json` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_edge_interior_constraints.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_generation_timeline.gif` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_multilevel_layers.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_result_contract_histogram.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_script_pipeline_storyboard.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_scripted_paint_diagnostics.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_socket_constraints.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_solver_footprints.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_strategic_tactical_split.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_transform_export.png` |
| Baseline artifact | `tests/artifacts/baselines/mapblock/mapblock_two_level_cutaway.png` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
