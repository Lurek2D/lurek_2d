<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/procgen.md or source docstrings instead. -->

# procgen

## TL;DR

- Orchestrates deterministic generation of terrain heightmaps, biomes, dungeons, and overworlds.
- Implements Perlin/Simplex/Worley noise, cellular automata sandboxes, and Poisson disks.
- Supports L-system branching trees, Wave Function Collapse tiling, and Markov name generation.

## General Info

- Module group: `Foundations`
- Source path: `src/procgen`
- Binding: `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`
- Lua API surface: `33` functions, `15` types, `37` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

## Summary

- The `procgen` module is the engine's procedural-content creation toolkit for users who want maps, regions, structures, names, distributions, and generated support data to be produced inside the engine from reusable algorithms.
- Its strength is range. Noise, BSP, cellular methods, Voronoi-style construction, flood fill, L-systems, room placement, graph assembly, wave-function-collapse style constraints, biome logic, and naming helpers all coexist because procedural work rarely stays inside one algorithm family.
- That breadth matters because procedural generation in games usually spans several scales at once, from local texture or room shape up to region connectivity and readable generated labels.
- The module is useful not only for final world output but also for support structures that other systems consume, such as region maps, connectivity data, biome assignments, or candidate placements.
- Constructive algorithms are especially valuable because they let projects generate spaces and structures with visible design logic rather than only sampling randomness.
- Constraint-driven approaches such as wave-function-collapse style generation matter for projects that need local rules and authored tile compatibility without fully hand-building every map.
- Graph and region-generation helpers broaden the module into larger-scale world assembly. Generated content is often about how areas relate to one another, not only about local texture or room shape.
- Naming helpers show that the scope is not restricted to geometry. Procedural content also includes readable labels, faction or place names, and other text-like generated outputs that help a world feel authored and coherent.
- Rendering and visualization support are therefore part of the practical story, since generated results often need to be previewed, compared, or debugged.
- Support for both small local algorithms and larger assembly logic makes the toolkit useful across scales, from decorative patterns up to multi-region world structures with interacting constraints.
- The module is especially helpful in hybrid projects where authored and generated content mix.
- That breadth also helps teams iterate on generated layouts before treating them as final world content.
- It also lets the same procedural vocabulary serve prototypes, editor previews, and final content workflows.
- Downstream modules render, navigate, or simulate the output, but `procgen` owns the samplers, constructive rules, and algorithmic helpers that create it.
- Read `procgen` as the engine's creation toolkit for algorithmic content.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/procgen`
- Owning tier: `Foundations`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/procgen_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### biome.rs

- This file owns biome classification rules that turn height, moisture, and temperature samples into named world regions.
- `BiomeType` defines the terrain vocabulary, while `BiomeRules` stores the thresholds that drive every decision.
- `BiomeClassifier` stays stateless so single-point queries and full-map classification share one predictable rule set.
- Color helpers also belong here because biome identity and preview rendering use the same canonical mapping table.
- Map-wide classification remains local since missing-sample defaults and per-cell rule dispatch are biome semantics.
- Open it when climate thresholds change; height, noise, and region graphs live in sibling procgen modules.

### bsp.rs

- This file owns the BSP dungeon generator that recursively splits a rectangle into rooms and corridor connections.
- `BspOpts` defines size, depth, padding, and seed, while `BspDungeon` stores the generated rooms and corridors.
- `BspRoom`, `BspPrefabStamp`, and `PlacedBspPrefab` live here because room geometry and prefab placement are local.
- Recursive partitioning and leaf-room carving stay here since split policy is the core authored BSP behavior.
- Prefab stamping also belongs here because room-fit checks and centered placement depend on BSP room ownership.
- Open it when partitioned-dungeon rules change; scatter rooms and world graphs live in sibling modules.

### cellular.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around CellularOpts, default, validate, with helpers kept close to their invariants.
- Defines how cellular data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on cellular behavior while Lua registration stays elsewhere.

### cellular_world.rs

- Owns the cellular world owner for the procgen subsystem and keeps its rules local to this file.
- Keeps procgen data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how cellular world data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on cellular world behavior while Lua registration stays elsewhere.
- Documents the boundary where procgen code accepts inputs, reports errors, or updates state.
- Use this file when changing cellular world defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the procgen state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping cellular world calculations explicit at their owner boundary.

### color.rs

- This file owns the scalar-to-RGBA conversion helper used to turn normalized procedural values into grayscale pixels.
- The conversion stays here because clamping and flat buffer layout are color-export concerns, not noise semantics.
- Open it when scalar preview encoding changes; terrain generation and sampled grids live in sibling modules.

### error.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around ProcgenError, fmt, with helpers kept close to their invariants.
- Defines how error data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on error behavior while Lua registration stays elsewhere.
- Documents the boundary where procgen code accepts inputs, reports errors, or updates state.

### flood_fill.rs

- This file owns the flat-grid flood-fill helper used to find connected regions above or below a byte threshold.
- Seed validation, 4-neighbor expansion, and threshold matching stay here because they define reachable-mask output.
- It returns a byte mask rather than world objects, keeping the file focused on grid-region extraction only.
- Open it when connectivity rules change; caves, rooms, and cellular worlds live in sibling procgen modules.

### heightmap.rs

- Owns the heightmap owner for the procgen subsystem and keeps its rules local to this file.
- Keeps procgen data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how heightmap data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on heightmap behavior while Lua registration stays elsewhere.
- Documents the boundary where procgen code accepts inputs, reports errors, or updates state.
- Use this file when changing heightmap defaults, lifecycle handling, validation, or data ownership.

### lcg.rs

- Owns the lcg owner for the procgen subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around LCG_ALGORITHM_VERSION, Lcg, new, with helpers kept close to their invariants.
- Defines how lcg data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.

### limits.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps procgen data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how limits data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on limits behavior while Lua registration stays elsewhere.

### lsystem.rs

- This file owns the L-system rewriter that expands symbolic grammars into deterministic strings and line segments.
- `LSystem` stores the axiom, production rules, and iteration count so generated forms remain easy to inspect.
- String generation stays here because rewrite application order and unmapped-character preservation are local rules.
- Turtle interpretation also belongs here since segment emission depends on bracket stacks and heading updates.

### mod.rs

- This module is the procgen index, exposing noise, terrain, dungeon, graph, naming, and sampling generators.
- It exports low-level primitives such as LCG, noise, flood fill, and scalar coloring for other generators to reuse.
- It also exports higher-level builders such as BSP dungeons, room dungeons, WFC grids, and world-region graphs.
- `mod.rs` owns visibility and reexport boundaries, not generated state, so feature responsibility stays in siblings.
- Open this file to map which source owns caves, biomes, naming, Voronoi regions, or sandbox material simulation.
- `noise.rs`, `heightmap.rs`, and `biome.rs` cover scalar-field generation plus terrain and climate interpretation.
- `bsp.rs`, `rooms.rs`, `wfc.rs`, and `world_graph.rs` cover discrete layout, tiling, and connectivity generation.
- `cellular.rs`, `cellular_world.rs`, `poisson.rs`, and `voronoi.rs` cover evolving grids and spatial sampling.

### namegen.rs

- This file owns the Markov-style name generator that learns character transitions from example word corpora.
- `NameGen` stores chain order, learned successor tables, and the internal seeded RNG used during sampling.
- Batch generation and bounded retries stay here because name length constraints are part of generator semantics.
- Open it when invented-name rules change; grammar rewriting and terrain synthesis live in sibling modules.

### noise.rs

- This file owns the core procedural-noise engine used to sample continuous scalar fields across many generators.
- `DistType`, `NoiseKind`, and `FractalType` define the selectable metrics and algorithms used by higher layers.
- `MapGenOptions` stores map-scale, octave, lacunarity, persistence, and offset parameters for grid generation.
- The free functions cover Perlin, Simplex, FBM, periodic tiling, and map helpers for quick stateless sampling.
- `NoiseGenerator` owns the seeded permutation table plus methods for Perlin, Simplex, Worley, and fractal variants.
- Worley distance evaluation also belongs here because feature-point hashing and metric choice are core noise rules.
- Domain warping remains local since warped coordinates are derived directly from the generator's own sample methods.
- Sequential and rayon-backed parallel map generation stay here because both consume the same map option contract.
- This file is the scalar-field foundation for terrain, caves, textures, and regions, not a gameplay policy owner.
- Open it when low-level sampling semantics change; biome thresholds and dungeon layout live in sibling modules.
- Its main value is consolidating seeded field generation so procgen callers share one reproducible math surface.

### poisson.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around poisson_disk, try_poisson_disk, with helpers kept close to their invariants.
- Defines how poisson data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on poisson behavior while Lua registration stays elsewhere.

### render.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around NoiseGrid, from_perlin, try_from_perlin, with helpers kept close to their invariants.
- Defines how render data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.

### report.rs

- This file owns lightweight diagnostic summaries shared by procgen generators that expose safe reports.
- It centralizes seed, cell-count, iteration, and attempt metadata so feature-specific reports stay consistent.
- Open it when a generator needs to surface deterministic run context or bounded-work diagnostics.

### rooms.rs

- This file owns the random-room dungeon generator that places non-overlapping rectangles and links them by corridors.
- `RoomsOpts` stores map size, room limits, size ranges, and seed, while `RoomsDungeon` owns rooms, links, and grid.
- `Room`, `RoomPrefabStamp`, and `PlacedRoomPrefab` live here because room geometry and prefab stamping are local.
- Room-overlap checks and L-shaped corridor carving stay here because they define the scatter-dungeon layout rules.
- Grid stamping also belongs here since prefab masks overwrite owned room interiors inside the produced tile map.
- Open it when room-based dungeon semantics change; BSP splitting and WFC tiling live in sibling modules.

### voronoi.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around VoronoiOpts, default, validate, with helpers kept close to their invariants.
- Defines how voronoi data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on voronoi behavior while Lua registration stays elsewhere.

### wfc.rs

- Owns the wfc owner for the procgen subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around WfcTile, WfcRules, WfcOpts, with helpers kept close to their invariants.
- Defines how wfc data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on wfc behavior while Lua registration stays elsewhere.
- Documents the boundary where procgen code accepts inputs, reports errors, or updates state.

### wfc_llm.rs

- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps procgen data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how wfc llm data is validated, transformed, or stored before neighboring systems use it.
- Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on wfc llm behavior while Lua registration stays elsewhere.

### world_graph.rs

- This file owns the world-region graph used to store places, travel links, and route-finding helpers on top of them.
- `WorldRegion` and `WorldEdge` define the stored topology, while `WorldGraph` owns regions, edges, and ids.
- A* pathfinding and bounded Dijkstra stay here because route cost semantics are derived from graph-owned edges.
- Kruskal MST support also belongs here since essential connectivity analysis depends on the same shared topology.
- Random graph generation remains local because spatial placement and nearest-neighbor linking build this graph type.
- Open it when overworld connectivity changes; Voronoi fields and dungeon interiors live in sibling modules.



## Lua API Ref

### Functions

- `lurek.procgen.biomeColor(name) -> number`: Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.
- `lurek.procgen.bspDungeon(opts?) -> table`: Generate a dungeon layout using Binary Space Partitioning. Produces non-overlapping rooms connected by corridors.
- `lurek.procgen.bspDungeonWithPrefabs(opts?, prefabs) -> table`: Generate a BSP dungeon and stamp named prefab rooms into suitable leaves. Returns dungeon layout plus prefab placement info.
- `lurek.procgen.cellularAutomata(width, height, opts?) -> integer[]`: Generate a cave or organic map using cellular automata rules.
- `lurek.procgen.fbm(x, y, seed?, octaves?, lac?, gain?) -> number`: Samples stateless fractal Brownian motion noise.
- `lurek.procgen.floodFill(data, width, height, startX, startY, threshold?, above?) -> integer[]`: Flood-fill a grid from a starting cell, marking all connected cells that pass a threshold test.
- `lurek.procgen.generateName(samples, minLen?, maxLen?, seed?) -> string`: Generate a single random name based on a Markov chain trained from sample names. Great for NPC names, place names, or item names.
- `lurek.procgen.generateNames(samples, count, minLen?, maxLen?, seed?) -> string[]`: Generate multiple random names in one call using Markov chains trained from sample data.
- `lurek.procgen.heightmap(opts?) -> table`: Generate a fractal heightmap using multi-octave noise with optional hydraulic erosion.
- `lurek.procgen.heightmapFromCellular(width, height, cells, floorValue?) -> table`: Convert a cellular automata grid into a heightmap by distance-transforming the floor cells.
- `lurek.procgen.lsystem(opts) -> string`: Expand an L-system grammar and return the resulting string. Useful for generating branching structures like trees, rivers, or cave networks.
- `lurek.procgen.lsystemSegments(opts, angle?, step?) -> table`: Expand an L-system and interpret the result as turtle-graphics commands, returning line segments.
- `lurek.procgen.newBiomeClassifier(opts?) -> LBiomeClassifier`: Create a BiomeClassifier object with custom threshold rules for mapping height/moisture/temperature to biome types.
- `lurek.procgen.newCellular(width, height) -> LCellular`: Performs the 'procgen' operation.
- `lurek.procgen.newNoiseGenerator(seed?) -> LNoiseGenerator`: Creates a procedural noise generator with an optional seed.
- `lurek.procgen.noiseMap(width, height, opts?) -> number[]`: Generate a 2D noise map with configurable scale, octaves, and offsets. Runs on a single thread.
- `lurek.procgen.noiseMapParallel(width, height, opts?) -> number[]`: Generate a 2D noise map using multiple threads for faster computation on large maps. Uses seed 0.
- `lurek.procgen.noiseMapParallelSeeded(width, height, opts?) -> number[]`: Generate a 2D noise map using multiple threads with a specific seed for reproducible results.
- `lurek.procgen.perlin2d(x, y, seed?) -> number`: Samples stateless 2D Perlin noise.
- `lurek.procgen.perlin3d(x, y, z, seed?) -> number`: Samples stateless 3D Perlin noise.
- `lurek.procgen.perlin4d(x, y, z, w, seed?) -> number`: Samples stateless 4D Perlin noise.
- `lurek.procgen.perlinNoise(x, y, periodX, periodY) -> number`: Sample periodic 2D Perlin noise at a given coordinate.
- `lurek.procgen.poissonDisk(width, height, minDist, maxAttempts?, seed?) -> table`: Generate evenly-spaced random points using Poisson disk sampling. Useful for placing trees, NPCs, or loot without clustering.
- `lurek.procgen.roomsDungeon(opts?) -> table`: Generate a dungeon by placing random non-overlapping rooms and connecting them with corridors. Also returns a full tile grid.
- `lurek.procgen.roomsDungeonWithPrefabs(opts?, prefabs, stampValue?) -> table`: Generate a rooms-based dungeon and place named prefabs into qualifying rooms. Prefabs can have custom shape masks.
- `lurek.procgen.setConstraintsFromLLM(prompt) -> table`: Sends a natural-language prompt to the global LLM and returns WFC adjacency constraints as a Lua table.
- `lurek.procgen.simplex2d(x, y) -> number`: Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].
- `lurek.procgen.simplex3d(x, y, z) -> number`: Sample 3D simplex noise at a point. The third axis can be used for animation or layering.
- `lurek.procgen.simplexNoise(x, y, z?) -> number`: Sample a 2D or 3D simplex noise value at a given point.
- `lurek.procgen.voronoi(width, height, points, opts?) -> integer[]`: Compute a Voronoi diagram from a set of seed points. Returns region ownership, distance-to-nearest, and distance-to-second-nearest for each cell.
- `lurek.procgen.wfcFromPrompt(prompt, config) -> table`: Asks the global LLM for WFC tile definitions and adjacency rules, then runs WFC generation.
- `lurek.procgen.wfcGenerate(opts) -> table`: Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.
- `lurek.procgen.worldGraph(width, height, regionCount, seed?) -> table`: Generate a connected world graph with named regions and weighted edges. Useful for overworld maps, trade routes, or quest connectivity.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LBiomeClassifier Type

- Lua-visible wrapper around the biome classification engine, used to assign biome types based on height, moisture, and temperature.

##### Fields

- No documented fields.

##### Methods

- `LBiomeClassifier:classify(height, moisture, temperature) -> string`: Classify a single point into a biome type based on its environmental parameters.
- `LBiomeClassifier:classifyMap(width, height, heights, moisture, temperature?) -> string[]`: Classify an entire grid of points into biome types in bulk.
- `LBiomeClassifier:type() -> string`: Returns the type name of this object.
- `LBiomeClassifier:typeOf(name) -> boolean`: Check whether this object matches a given type name.

#### LCellular Type

- A cellular automaton simulation grid (sand, water, fire, gas, rock) for per-cell falling-sand style simulation.

##### Fields

- No documented fields.

##### Methods

- `LCellular:countCells(cellType) -> integer`: Counts how many cells of a given material type exist in the grid.
- `LCellular:fillCircle(cx, cy, r, cellType) -> nil`: Fills a circular region of cells with a material type.
- `LCellular:fillRect(cx0, cy0, cw, ch, cellType) -> nil`: Fills a rectangular region of cells with a material type.
- `LCellular:findCells(cellType) -> table`: Returns positions of all cells matching a material type.
- `LCellular:getCell(cx, cy) -> integer`: Returns the material type of a cell at the given grid position.
- `LCellular:loadFromBytes(data) -> boolean`: Restores cellular grid state from binary data previously produced by toBytes.
- `LCellular:setCell(cx, cy, cellType) -> nil`: Sets a single cell in the cellular grid to a specific material type.
- `LCellular:step() -> nil`: Advances the cellular simulation by one tick (particles fall, flow, burn, etc.).
- `LCellular:stepN(n) -> nil`: Advances the cellular simulation by N ticks in a single call.
- `LCellular:toBytes() -> string`: Serializes the cellular grid to a compact binary format for saving.
- `LCellular:toImageData() -> string`: Renders the entire cellular grid to raw RGBA pixel data using the default material palette.
- `LCellular:toImageDataRegion(cx0, cy0, cw, ch) -> string`: Renders a rectangular sub-region of the cellular grid to raw RGBA pixel data.
- `LCellular:type() -> string`: Returns the type name of this object ("LCellular").
- `LCellular:typeOf(name) -> boolean`: Checks if this object is of a given type name.

#### LCellularFindCellsResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X coordinate.
- `y` (`number`): Y coordinate.

##### Methods

- No documented methods.

#### LNoiseGenerator Type

- Lua-side wrapper for a procedural noise generator.

##### Fields

- No documented fields.

##### Methods

- `LNoiseGenerator:fbm(x, y, octaves?, lac?, pers?, kind?) -> number`: Samples fractal Brownian motion noise.
- `LNoiseGenerator:generateMap(w, h, opts?) -> number[]`: Generates a noise map and returns it as a flat array table.
- `LNoiseGenerator:generateMapCompute(w, h, opts?) -> number[]`: Generates a noise map through the compute backend and returns it as a flat array table.
- `LNoiseGenerator:getSeed() -> integer`: Returns this noise generator seed.
- `LNoiseGenerator:perlin1d(x) -> number`: Samples 1D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin2d(x, y) -> number`: Samples 2D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin3d(x, y, z) -> number`: Samples 3D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin4d(x, y, z, w) -> number`: Samples 4D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:ridged(x, y, octaves?, lac?, pers?, kind?) -> number`: Samples ridged fractal noise. This method is available to Lua scripts.
- `LNoiseGenerator:setSeed(seed) -> nil`: Sets this noise generator seed. This method is available to Lua scripts.
- `LNoiseGenerator:simplex1d(x) -> number`: Samples 1D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex2d(x, y) -> number`: Samples 2D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex3d(x, y, z) -> number`: Samples 3D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:turbulence(x, y, octaves?, lac?, pers?, kind?) -> number`: Samples turbulence fractal noise.
- `LNoiseGenerator:type() -> string`: Returns the Lua-visible type name for this noise generator handle.
- `LNoiseGenerator:typeOf(name) -> boolean`: Returns whether this noise generator handle matches a supported type name.
- `LNoiseGenerator:warpDomain(x, y, strength) -> number`: Samples domain-warped noise coordinates.
- `LNoiseGenerator:worley2d(x, y, dist_name?, f2?) -> number`: Samples 2D Worley noise. This method is available to Lua scripts.
- `LNoiseGenerator:worley3d(x, y, z, dist_name?, f2?) -> number`: Samples 3D Worley noise. This method is available to Lua scripts.

#### LProcgenBspDungeonResult Type

- Generated result shape from @field tags.

##### Fields

- `corridors` (`table`): Array of corridor tables with x1, y1, x2, y2 fields.
- `rooms` (`table`): Array of room tables with x, y, w, h fields.

##### Methods

- No documented methods.

#### LProcgenBspDungeonWithPrefabsResult Type

- Generated result shape from @field tags.

##### Fields

- `height` (`number`): Height.
- `name` (`string`): Name.
- `width` (`number`): Width.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LProcgenHeightmapFromCellularResult Type

- Generated result shape from @field tags.

##### Fields

- `cells` (`number[]`): Distance-transformed heightmap values.
- `height` (`integer`): Height.
- `width` (`integer`): Width.

##### Methods

- No documented methods.

#### LProcgenHeightmapResult Type

- Generated result shape from @field tags.

##### Fields

- `cells` (`number[]`): Heightmap values.
- `height` (`integer`): Height.
- `width` (`integer`): Width.

##### Methods

- No documented methods.

#### LProcgenLsystemSegmentsResult Type

- Generated result shape from @field tags.

##### Fields

- `x1` (`number`): X1.
- `x2` (`number`): X2.
- `y1` (`number`): Y1.
- `y2` (`number`): Y2.

##### Methods

- No documented methods.

#### LProcgenPoissonDiskResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LProcgenRoomsDungeonResult Type

- Generated result shape from @field tags.

##### Fields

- `corridors` (`table`): Array of corridor tables with x1, y1, x2, y2 fields.
- `grid` (`integer[]`): Flat grid array of tile values.
- `height` (`integer`): Grid height in tiles.
- `rooms` (`table`): Array of room tables with x, y, w, h fields.
- `width` (`integer`): Grid width in tiles.

##### Methods

- No documented methods.

#### LProcgenRoomsDungeonWithPrefabsResult Type

- Generated result shape from @field tags.

##### Fields

- `height` (`number`): Height.
- `name` (`string`): Name.
- `width` (`number`): Width.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LProcgenWfcFromPromptResult Type

- Generated result shape from @field tags.

##### Fields

- `cells` (`table`): Array of {x, y, tile} tables for resolved cells.
- `failed_cells` (`table`): Array of {x, y} tables for unresolved cells.
- `height` (`integer`): Grid height.
- `width` (`integer`): Grid width.

##### Methods

- No documented methods.

#### LProcgenWfcGenerateResult Type

- Generated result shape from @field tags.

##### Fields

- `cells` (`integer[]`): Tile ID per cell.
- `height` (`integer`): Height.
- `width` (`integer`): Width.

##### Methods

- No documented methods.

#### LProcgenWorldGraphResult Type

- Generated result shape from @field tags.

##### Fields

- `edges` (`table`): Array of edge tables, each with from (integer), to (integer), cost (number), bidirectional (boolean).
- `regions` (`table`): Array of region tables, each with id (integer), name (string), x (number), y (number), tags (string[]).

##### Methods

- No documented methods.

## Examples

- `content/examples/procgen.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_procgen_unit.lua` (present)
- Rust: `tests/rust/unit/procgen_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_procgen_evidence.lua` |
| Golden test | `tests/lua/golden/test_procgen_golden.lua` |
| Current artifact | `tests/artifacts/current/procgen/procgen_bsp_dungeon.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_cellular_cave_map.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_cellular_cave_map_stats.txt` |
| Current artifact | `tests/artifacts/current/procgen/procgen_cellular_dense_map.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_cellular_flood.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_cellular_material_sandbox.gif` |
| Current artifact | `tests/artifacts/current/procgen/procgen_climate_biome_world.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_extended_api_trace.txt` |
| Current artifact | `tests/artifacts/current/procgen/procgen_height_worldgraph.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_lsystem_river_settlement.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_noise_heightmap_colored.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_noise_map.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_noise_map_parallel.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_perlin_grid.json` |
| Current artifact | `tests/artifacts/current/procgen/procgen_perlin_strip.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_poisson_voronoi.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_prefab_dungeon_stamps.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_rooms_dungeon.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_seeded_noise_grid.json` |
| Current artifact | `tests/artifacts/current/procgen/procgen_simplex2d_strip.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_simplex3d_strip.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_simplex_grid.json` |
| Current artifact | `tests/artifacts/current/procgen/procgen_wfc_constraint_world.png` |
| Current artifact | `tests/artifacts/current/procgen/procgen_wfc_lsystem_names.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_bsp_dungeon.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_cellular_cave_map.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_cellular_cave_map_stats.txt` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_cellular_dense_map.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_cellular_flood.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_cellular_material_sandbox.gif` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_climate_biome_world.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_height_worldgraph.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_lsystem_river_settlement.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_noise_heightmap_colored.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_noise_map.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_noise_map_parallel.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_perlin_grid.json` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_perlin_strip.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_poisson_voronoi.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_prefab_dungeon_stamps.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_rooms_dungeon.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_seeded_noise_grid.json` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_simplex2d_strip.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_simplex3d_strip.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_simplex_grid.json` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_wfc_constraint_world.png` |
| Baseline artifact | `tests/artifacts/baselines/procgen/procgen_wfc_lsystem_names.png` |

## Architecture Links

- Intentionally empty.

## Notes

- Safe procgen paths now reject zero-sized grids, overflowing `width * height` allocations, invalid finite/range parameters, and oversized WFC retry budgets through `ProcgenLimits`/`ProcgenError`.
- `Heightmap::try_generate`, `try_from_noise_map`, `try_from_cellular`, and `try_get` define the non-panicking heightmap contract; legacy constructors still route callers through the same validation layer.
- `Heightmap` now exposes explicit `ErosionMode` semantics: `InPlace` is scan-order dependent and fast, while `Buffered` uses a frozen source snapshot per pass for order-independent updates; erosion helpers return `HeightmapErosionReport` with pass and change counts.
- `MapGenOptions` now owns bounded parallel-generation controls (`parallel_enabled`, `parallel_chunk_size`), so safe noise generation can fall back to sequential execution or constrain Rayon chunk granularity without changing output determinism.
- `CellularWorld::try_new`, version-aware `from_bytes_with_limits`, and `try_to_image_data*` reject oversized worlds or exports before allocation; serialization now stores width, height, RNG state, tick parity, cell bytes, and fire-lifetime bytes so save/restore can resume exactly.
- `CellularWorld::step` reuses internal scratch buffers instead of cloning full grids every tick and records `CellularWorldStepStats` for moved cells, fire spread count, and active update bounds.
- `try_wfc_generate` now reports contradictions distinctly from empty or invalid tile sets, while legacy `wfc_generate` preserves the all-`None` fallback and attaches a `WfcReport` with shared `ProcgenReport` summary metadata.
- `Lcg` now exposes algorithm versioning, raw-state snapshot/restore, `next_u64`, `next_f64`, and bounded integer helpers so deterministic procgen callers can reproduce results without modulo-biased indexing.
- Strict `wfc_llm` parsing is now bounded by `ProcgenLimits` (`max_parser_input_bytes`, `max_wfc_tiles`, `max_wfc_adjacency_refs`) and returns structured `ProcgenError` values for malformed schema, oversized payloads, and count overruns instead of silently partially parsing by default.
- Auxiliary grid helpers also participate in the safe contract: `NoiseGrid::try_from_perlin`, `try_poisson_disk`, `try_voronoi_diagram`, `try_rooms_dungeon`, `BiomeClassifier::try_classify_map`, and `try_flood_fill` validate dimensions or finite parameters before allocating.
