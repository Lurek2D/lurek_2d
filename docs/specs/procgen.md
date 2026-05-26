# procgen

## TL;DR

- The `procgen` module is a versatile Foundations tier library dedicated to procedural content generation in Lurek2D.

## General Info

- Module group: `Foundations`
- Source path: `src/procgen/`
- Lua API path(s): `src/lua_api/procgen_api.rs`
- Primary Lua namespace: `lurek.procgen`
- Rust test path(s): src/procgen/noise_tests.rs (sibling), plus inline #[cfg(test)] in all other .rs files
- Lua test path(s): none found in the workspace

## Summary

 It offers a rich suite of deterministic, headless-testable algorithms for creating diverse game worlds, terrains, and structures. Central to the module is a robust `NoiseGenerator` built on an internal seeded Linear Congruential Generator (LCG). It supports 2D/3D/4D Perlin and Simplex noise, as well as 2D/3D Worley (cellular) noise with various distance metrics. These base noises can be combined using fractal combinators like Fractal Brownian Motion (FBM), ridged multifractal, and turbulence, and deformed via domain warping. For map generation, `procgen` provides sequential and parallel (`rayon`-powered) heightmap generation with options for hydraulic erosion, which can then be classified into dynamic biomes (e.g., ocean, desert, forest) via the `BiomeClassifier`.

The module also excels at dungeon and interior generation. The `BspDungeon` generator uses Binary Space Partitioning to recursively divide space and carve rooms connected by L-shaped corridors. Alternatively, the `rooms_dungeon` generator places random non-overlapping rooms. Both systems support a prefab stamping feature that cleanly pastes named template shapes into qualifying rooms in a round-robin fashion. For organic caves, the `cellular_automata` generator applies birth/survival rules to a grid to form natural-looking caverns.

For advanced world-building, `procgen` includes a `world_graph` subsystem for generating overworld node topologies, complete with A* pathfinding and Kruskal's minimum spanning tree algorithms. It also features a Wave Function Collapse (`wfc`) solver for constraint-based tile placement, Voronoi tessellation for regional partitioning, and Poisson-disk sampling for natural, evenly-spaced object distribution. L-systems provide string-rewriting and turtle-graphics interpretation for generating fractal trees or road networks. Finally, a Markov-chain `NameGen` creates plausible, random names trained on input word corpora. All these algorithms are thoroughly exposed to Lua via the `lurek.procgen.*` API, enabling script developers to construct infinitely varied, reproducible game content on the fly.

## Source Documentation

### `biome.rs`
- Biome classification system mapping height, moisture, and temperature to terrain types.
- Defines `BiomeType` enum covering ocean, coast, desert, forest, tundra, and more.
- Configurable `BiomeRules` thresholds for tuning world generation.
- Stateless `BiomeClassifier` for single-cell or bulk grid classification.
- RGBA color mapping for biome visualisation output.

### `bsp.rs`
- Binary Space Partition dungeon generator: recursive splitting, leaf room placement, corridor linking.
- Configuration via `BspOpts`: grid size, recursion depth, minimum partition size, padding, seed.
- Prefab stamping: round-robin placement of named template shapes centred in qualifying rooms.
- Deterministic output driven by a seeded `Lcg` RNG for reproducible layouts.
- Pure algorithm module with no rendering or tilemap dependency.

### `cellular.rs`
- Cellular automata cave generator producing flat grid maps from configurable birth/survive rules.
- Supports reproducible output via seeded LCG randomisation.
- Treats out-of-bounds neighbours as solid, forming natural cave walls at map edges.

### `color.rs`
- Convert scalar procgen output into pixel-ready RGBA byte buffers.
- Grayscale mapping with automatic 0–1 clamping.
- Suitable for heightmaps, noise previews, and debug visualisation.

### `flood_fill.rs`
- Four-connected flood fill on a flat `u8` grid with threshold-based matching.
- Return a binary mask of reachable cells from a seed coordinate.
- Support both above-threshold and below-threshold fill modes.

### `heightmap.rs`
- Procedural heightmap generation from FBM Perlin noise with configurable octaves, lacunarity, and persistence.
- Simple hydraulic erosion pass that redistributes height differences across 4-connected neighbours.
- Construction from raw noise maps or cellular automata grids with automatic normalisation to 0.0–1.0.
- Clamped coordinate access and flat RGBA byte export for GPU texture upload.
- Deterministic output controlled by a seed value passed through to the noise generator.

### `lcg.rs`
- 64-bit linear congruential generator (LCG) for deterministic pseudo-random number output.
- Provides seeded construction, raw `u64` stepping, and uniform `f32` sampling.
- Used as the shared RNG primitive across all `procgen` subsystems.

### `lsystem.rs`
- Deterministic string-rewriting L-system with configurable axiom, production rules, and iteration depth.
- Turtle-graphics interpreter converts generated strings into line segments for rendering.
- Supports branching via stack-based `[`/`]` commands for tree and fractal geometry.

### `mod.rs`
- Procedural generation toolkit: noise, dungeons, heightmaps, and world graphs.
- Algorithms: Perlin/Simplex/Worley noise, BSP & room-scatter dungeons, cellular automata caves.
- Utilities: Poisson disk sampling, L-systems, Markov name generation, Voronoi, WFC.
- All generators are deterministic given a seed via the internal LCG.

### `namegen.rs`
- Markov-chain name generator trained on arbitrary word corpora.
- Configurable n-gram order controls fidelity-vs-variety tradeoff.
- Deterministic output via internal LCG seeding for reproducible generation.
- Batch generation with length constraints and bounded retry logic.

### `noise.rs`
- Standalone 2D, 3D, and 4D Perlin noise evaluation with configurable seeds.
- 2D simplex noise with seeded and convenience zero-seed wrappers.
- FBM fractal layering over Perlin noise with normalised output.
- Seeded `NoiseGenerator` with permutation-table Perlin (1D/2D/3D) and Simplex (2D/3D/4D).
- Worley (cellular) noise in 2D and 3D with Euclidean, Manhattan, and Chebyshev metrics.
- Fractal combinators: FBM, ridged multifractal, and turbulence; all normalised.
- Domain warping via Perlin-driven coordinate offsets.
- Sequential and parallel (`rayon`) height-map generation from `MapGenOptions`.
- Tileable periodic 2D Perlin noise for seamless texture synthesis.
- Internal hash and gradient helpers for all supported dimensions.

### `poisson.rs`
- Poisson-disk sampling: generate evenly-spaced random 2D point distributions.
- Uses Bridson's algorithm with grid acceleration for O(n) rejection.
- Deterministic via seeded LCG; produces `(x, y)` pair vectors.

### `render.rs`
- Tileable Perlin noise grid generation and cell access.
- Conversion to grayscale RGBA byte buffers and `ImageData`.
- Batch render-command generation for grid visualization.

### `rooms.rs`
- Random room placement with overlap rejection and configurable size ranges.
- L-shaped corridor carving between consecutive room centres.
- Flat row-major tile grid output (wall / floor / corridor byte values).
- Prefab stamp system that centre-pastes named mask patterns into placed rooms.
- Round-robin prefab assignment across all placed rooms.

### `voronoi.rs`
- Voronoi diagram generation on a 2D grid with F1/F2 distance fields.
- Optional domain warp via hash noise for organic region boundaries.
- Returns region indices and per-pixel distance buffers in row-major order.

### `wfc.rs`
- Wave Function Collapse (WFC) grid generator with weighted tile selection.
- Adjacency-rule constraint propagation with automatic backtracking retries.
- Deterministic seeded output via the internal LCG; each retry increments the seed.
- Returns a flat row-major grid of tile IDs or `None` cells on contradiction.

### `world_graph.rs`
- Region and edge data types representing nodes and weighted connections in a world graph.
- A* pathfinding with Euclidean heuristic for shortest-path queries between regions.
- Bounded Dijkstra reachability returning all regions within a cumulative travel cost.
- Minimum spanning tree computation via Kruskal's algorithm.
- Random world graph generation placing regions in a bounding box and connecting k-nearest neighbours.

## Types

- `BiomeType` (`enum`, `biome.rs`): Biome variant covering terrain from ocean to ice cap.
- `BiomeRules` (`struct`, `biome.rs`): Scalar thresholds that drive biome classification; all values are normalised 0..=1.
- `BiomeClassifier` (`struct`, `biome.rs`): Stateless classifier that maps (height, moisture, temperature) to a `BiomeType`.
- `BspRoom` (`struct`, `bsp.rs`): A room placed within the dungeon.
- `BspDungeon` (`struct`, `bsp.rs`): A generated BSP dungeon.
- `BspPrefabStamp` (`struct`, `bsp.rs`): Template shape used to stamp a named prefab into a room during BSP generation.
- `PlacedBspPrefab` (`struct`, `bsp.rs`): A `BspPrefabStamp` placed at a concrete tile position within a room.
- `BspOpts` (`struct`, `bsp.rs`): Options controlling BSP dungeon generation.
- `CellularOpts` (`struct`, `cellular.rs`): Configuration bundle for cellular automata generation.
- `HeightmapOpts` (`struct`, `heightmap.rs`): Options for heightmap generation.
- `Heightmap` (`struct`, `heightmap.rs`): A 2D heightmap with float elevation values.
- `Lcg` (`struct`, `lcg.rs`): Internal deterministic RNG used to keep the public algorithms reproducible.
- `LSystem` (`struct`, `lsystem.rs`): An L-system with an axiom, rewriting rules, and an iteration count.
- `NameGen` (`struct`, `namegen.rs`): A Markov chain name generator.
- `DistType` (`enum`, `noise.rs`): Distance metric for Worley (cellular) noise.
- `NoiseKind` (`enum`, `noise.rs`): Noise algorithm kind used by fractal combinators.
- `FractalType` (`enum`, `noise.rs`): Fractal type for multi-octave noise.
- `MapGenOptions` (`struct`, `noise.rs`): Options for 2D noise map generation.
- `NoiseGenerator` (`struct`, `noise.rs`): Seeded procedural noise generator.
- `NoiseGrid` (`struct`, `render.rs`): Sampled noise buffer that can be exported as render commands or a CPU image.
- `Room` (`struct`, `rooms.rs`): A placed room in the dungeon.
- `RoomsOpts` (`struct`, `rooms.rs`): Options for rooms-and-corridors generation.
- `RoomsDungeon` (`struct`, `rooms.rs`): The result of rooms-and-corridors generation.
- `RoomPrefabStamp` (`struct`, `rooms.rs`): Template shape used to overwrite a room's interior with a named stamp pattern.
- `PlacedRoomPrefab` (`struct`, `rooms.rs`): A `RoomPrefabStamp` placed at a concrete tile position within a room.
- `VoronoiOpts` (`struct`, `voronoi.rs`): Configuration bundle for Voronoi generation and optional domain warping.
- `WfcTile` (`struct`, `wfc.rs`): A weighted tile for WFC generation.
- `WfcRules` (`struct`, `wfc.rs`): Adjacency rules: maps each tile ID to the set of tile IDs that may appear beside it.
- `WfcOpts` (`struct`, `wfc.rs`): Options for WFC generation.
- `WfcGrid` (`struct`, `wfc.rs`): The generated grid.
- `WorldRegion` (`struct`, `world_graph.rs`): A region (node) in the world graph.
- `WorldEdge` (`struct`, `world_graph.rs`): An edge connecting two regions.
- `WorldGraph` (`struct`, `world_graph.rs`): A world-level topology graph.

## Functions

- `BiomeType::as_str` (`biome.rs`): Return the canonical snake_case string token for this biome.
- `BiomeType::color_rgba` (`biome.rs`): Return the representative RGBA color `[r, g, b, 255]` for this biome variant.
- `BiomeClassifier::new` (`biome.rs`): Create a classifier using the provided rules.
- `BiomeClassifier::default_rules` (`biome.rs`): Create a classifier with `BiomeRules::default()`.
- `BiomeClassifier::classify` (`biome.rs`): Classify a single cell and return its `BiomeType`; all inputs must be normalised 0..=1.
- `BiomeClassifier::classify_map` (`biome.rs`): Classify every cell in a flat `width × height_map` grid; missing slice entries default to neutral values.
- `BiomeClassifier::rules` (`biome.rs`): Return a shared reference to the active `BiomeRules`.
- `biome_map_to_rgba` (`biome.rs`): Convert a slice of `BiomeType` values to a flat RGBA byte buffer at 4 bytes per cell.
- `bsp_dungeon` (`bsp.rs`): Generate a BSP dungeon from the given options.
- `bsp_dungeon_with_prefabs` (`bsp.rs`): Generate a BSP dungeon and centre-place `prefabs` (round-robin) in rooms that fit; returns `(dungeon, placements)`.
- `cellular_automata` (`cellular.rs`): Generates a cave/dungeon map using cellular automata.
- `scalar_map_to_rgba_bytes` (`color.rs`): Convert a normalised float slice to a flat grayscale RGBA buffer; clamps each value to 0.0–1.0.
- `flood_fill` (`flood_fill.rs`): BFS flood fill on a flat grid, returning a binary mask of all cells reachable from a seed position whose values satisfy `threshold`.
- `Heightmap::generate` (`heightmap.rs`): Generate a heightmap from `opts` using FBM Perlin noise, normalised and optionally eroded.
- `Heightmap::from_noise_map` (`heightmap.rs`): Build a heightmap from a pre-computed `f64` noise slice; normalises the result.
- `Heightmap::from_cellular` (`heightmap.rs`): Build a heightmap from a cellular automata `u8` grid: cells != `floor_value` map to 1.0, others to 0.0.
- `Heightmap::get` (`heightmap.rs`): Return the cell value at `(x, y)`, clamping out-of-bounds coordinates to the grid edge.
- `Heightmap::normalize` (`heightmap.rs`): Remap all cells to 0.0–1.0 by dividing by the current min/max range; no-op if range < 1e-7.
- `Heightmap::erode` (`heightmap.rs`): Apply `passes` rounds of simple hydraulic erosion: each cell deposits 10 % of its height difference into its lowest 4-connected neighbour.
- `Heightmap::to_rgba_bytes` (`heightmap.rs`): Convert the cell grid to a flat grayscale RGBA byte buffer at 4 bytes per cell.
- `Lcg::new` (`lcg.rs`): Create an LCG seeded with `seed` (internal state = seed + 1 to avoid zero-state).
- `Lcg::next` (`lcg.rs`): Advance the LCG by one step and return the next raw `u64` output.
- `Lcg::next_f32` (`lcg.rs`): Advance and return a uniform float in 0.0–1.0 using the upper 31 bits.
- `LSystem::new` (`lsystem.rs`): Create an L-system from a string axiom and `(char, &str)` rule pairs.
- `LSystem::new_from_pairs` (`lsystem.rs`): Create an L-system from a string axiom and `(char, String)` rule slice.
- `LSystem::generate` (`lsystem.rs`): Apply all production rules `iterations` times and return the resulting string.
- `LSystem::to_segments` (`lsystem.rs`): Interpret the generated string as turtle commands and return `(x1,y1,x2,y2)` line segments.
- `NameGen::new` (`namegen.rs`): Build a chain from `training` words at the given `order` and deterministic `seed`.
- `NameGen::generate` (`namegen.rs`): Sample up to 64 candidate names and return the first one with `min_len..=max_len` characters; returns an empty string when all attempts fail.
- `NameGen::generate_n` (`namegen.rs`): Generate `n` names each satisfying `min_len`/`max_len`; names that fail all attempts are empty strings.
- `perlin2d` (`noise.rs`): Generates 2D Perlin noise at the given coordinates.
- `simplex2d` (`noise.rs`): Generates 2D Simplex noise at the given coordinates.
- `simplex_noise_2d` (`noise.rs`): Returns 2D simplex noise using a fixed seed of 0.
- `simplex_noise_3d` (`noise.rs`): Returns 3D simplex noise using a fixed seed of 0.
- `fbm` (`noise.rs`): Generates fractal Brownian motion noise by layering multiple octaves of Perlin noise.
- `perlin3d` (`noise.rs`): Generates 3D Perlin noise at the given coordinates.
- `perlin4d` (`noise.rs`): Generates 4D Perlin noise at the given coordinates.
- `generate_noise_map_parallel` (`noise.rs`): Generate a noise map in parallel using rayon.
- `NoiseGenerator::new` (`noise.rs`): Create a generator seeded with `seed` and build the permutation table.
- `NoiseGenerator::set_seed` (`noise.rs`): Replace the current seed and rebuild the permutation table.
- `NoiseGenerator::seed` (`noise.rs`): Return the current seed value.
- `NoiseGenerator::perlin_1d` (`noise.rs`): Evaluate 1D Perlin noise at `x`; returns a value roughly in -1.0..1.0.
- `NoiseGenerator::perlin_2d` (`noise.rs`): Evaluate 2D Perlin noise at `(x, y)`; returns a value roughly in -1.0..1.0.
- `NoiseGenerator::perlin_3d` (`noise.rs`): Evaluate 3D Perlin noise at `(x, y, z)`; returns a value roughly in -1.0..1.0.
- `NoiseGenerator::simplex_2d` (`noise.rs`): Evaluate 2D simplex noise at `(x, y)`; scaled to approximately -1.0..1.0.
- `NoiseGenerator::simplex_3d` (`noise.rs`): Evaluate 3D simplex noise at `(x, y, z)`; scaled to approximately -1.0..1.0.
- `NoiseGenerator::simplex_4d` (`noise.rs`): Evaluate 4D simplex noise at `(x, y, z, w)`; scaled to approximately -1.0..1.0.
- `NoiseGenerator::worley_2d` (`noise.rs`): Evaluate 2D Worley noise; returns F1 distance when `f2=false`, F2−F1 when `f2=true`.
- `NoiseGenerator::worley_3d` (`noise.rs`): Evaluate 3D Worley noise; returns F1 distance when `f2=false`, F2−F1 when `f2=true`.
- `NoiseGenerator::fbm` (`noise.rs`): Evaluate FBM fractal at `(x, y)` using `kind` noise; sums `octaves` normalised octaves.
- `NoiseGenerator::ridged` (`noise.rs`): Evaluate ridged multifractal at `(x, y)` using `kind` noise; inverts octaves to produce ridges.
- `NoiseGenerator::turbulence` (`noise.rs`): Evaluate turbulence fractal at `(x, y)` using `kind` noise; sums absolute octave values.
- `NoiseGenerator::warp_domain` (`noise.rs`): Apply domain-warp to `(x, y)` using `perlin_2d` offsets scaled by `strength`; returns warped coordinates.
- `NoiseGenerator::generate_map` (`noise.rs`): Generate a flat `width × height` noise map sequentially using `opts`; returns values in approximately -1.0..1.0.
- `NoiseGenerator::generate_map_parallel` (`noise.rs`): Generate a flat `width × height` noise map using rayon parallel iteration; faster than `generate_map` for large grids.
- `perlin_noise_periodic` (`noise.rs`): Periodic Perlin noise that tiles over period (px, py).
- `poisson_disk` (`poisson.rs`): Generates Poisson disk sample points using Bridson's algorithm.
- `NoiseGrid::from_perlin` (`render.rs`): Build a tileable Perlin noise grid at the given `scale`; scale is clamped to >= 1e-6.
- `NoiseGrid::to_rgba_bytes` (`render.rs`): Convert the cell grid to a flat grayscale RGBA byte buffer at 4 bytes per cell.
- `NoiseGrid::generate_render_commands` (`render.rs`): Generate `SetColor` + `Rectangle` render commands for each cell at `cell_size` pixels; returns an empty vec for empty grids.
- `NoiseGrid::draw_to_image` (`render.rs`): Render the grid into a new `ImageData` as grayscale RGBA pixels.
- `rooms_dungeon` (`rooms.rs`): Generate a rooms-and-corridors dungeon.
- `rooms_dungeon_with_prefabs` (`rooms.rs`): Generate a rooms dungeon, centre-stamp `prefabs` (round-robin) in each room, and return `(dungeon, placements)`.
- `voronoi_diagram` (`voronoi.rs`): Generates a Voronoi diagram over a `width × height` grid for the given seed points.
- `wfc_generate` (`wfc.rs`): Generate a WFC tile grid.
- `WorldGraph::new` (`world_graph.rs`): Create an empty world graph.
- `WorldGraph::add_region` (`world_graph.rs`): Add a named region at `(x, y)` and return its assigned ID.
- `WorldGraph::add_edge` (`world_graph.rs`): Add an edge from `from` to `to` with the given `cost`; bidirectional edges traverse both ways.
- `WorldGraph::find_path` (`world_graph.rs`): Find the shortest path from `from` to `to` using A* with Euclidean heuristic; returns `None` when no path exists.
- `WorldGraph::reachable_from` (`world_graph.rs`): Return all region IDs reachable from `start` within cumulative edge cost `max_cost` using bounded Dijkstra.
- `WorldGraph::mst` (`world_graph.rs`): Compute a minimum spanning tree using Kruskal's algorithm; returns `(from, to, cost)` triples.
- `WorldGraph::to_regions_list` (`world_graph.rs`): Return references to all regions in insertion order.
- `generate_world_graph` (`world_graph.rs`): Scatter `region_count` regions randomly in a `width × height` world and connect each to its k-nearest neighbours (k = 3).

## Lua API Reference

- Binding path(s): `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`

### Module Functions
- `lurek.procgen.cellularAutomata`: Generate a cave or organic map using cellular automata rules.
- `lurek.procgen.floodFill`: Flood-fill a grid from a starting cell, marking all connected cells that pass a threshold test.
- `lurek.procgen.perlinNoise`: Sample periodic 2D Perlin noise at a given coordinate.
- `lurek.procgen.poissonDisk`: Generate evenly-spaced random points using Poisson disk sampling. Useful for placing trees, NPCs, or loot without clustering.
- `lurek.procgen.voronoi`: Compute a Voronoi diagram from a set of seed points. Returns region ownership, distance-to-nearest, and distance-to-second-nearest for each cell.
- `lurek.procgen.bspDungeon`: Generate a dungeon layout using Binary Space Partitioning. Produces non-overlapping rooms connected by corridors.
- `lurek.procgen.bspDungeonWithPrefabs`: Generate a BSP dungeon and stamp named prefab rooms into suitable leaves. Returns dungeon layout plus prefab placement info.
- `lurek.procgen.roomsDungeon`: Generate a dungeon by placing random non-overlapping rooms and connecting them with corridors. Also returns a full tile grid.
- `lurek.procgen.roomsDungeonWithPrefabs`: Generate a rooms-based dungeon and place named prefabs into qualifying rooms. Prefabs can have custom shape masks.
- `lurek.procgen.heightmap`: Generate a fractal heightmap using multi-octave noise with optional hydraulic erosion.
- `lurek.procgen.heightmapFromCellular`: Convert a cellular automata grid into a heightmap by distance-transforming the floor cells.
- `lurek.procgen.wfcGenerate`: Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.
- `lurek.procgen.lsystem`: Expand an L-system grammar and return the resulting string. Useful for generating branching structures like trees, rivers, or cave networks.
- `lurek.procgen.lsystemSegments`: Expand an L-system and interpret the result as turtle-graphics commands, returning line segments.
- `lurek.procgen.generateName`: Generate a single random name based on a Markov chain trained from sample names. Great for NPC names, place names, or item names.
- `lurek.procgen.generateNames`: Generate multiple random names in one call using Markov chains trained from sample data.
- `lurek.procgen.worldGraph`: Generate a connected world graph with named regions and weighted edges. Useful for overworld maps, trade routes, or quest connectivity.
- `lurek.procgen.noiseMap`: Generate a 2D noise map with configurable scale, octaves, and offsets. Runs on a single thread.
- `lurek.procgen.noiseMapParallel`: Generate a 2D noise map using multiple threads for faster computation on large maps. Uses seed 0.
- `lurek.procgen.noiseMapParallelSeeded`: Generate a 2D noise map using multiple threads with a specific seed for reproducible results.
- `lurek.procgen.simplex2d`: Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].
- `lurek.procgen.simplex3d`: Sample 3D simplex noise at a point. The third axis can be used for animation or layering.
- `lurek.procgen.newBiomeClassifier`: Create a BiomeClassifier object with custom threshold rules for mapping height/moisture/temperature to biome types.
- `lurek.procgen.biomeColor`: Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.

### `LBiomeClassifier` Methods
- `LBiomeClassifier:classify`: Classify a single point into a biome type based on its environmental parameters.
- `LBiomeClassifier:classifyMap`: Classify an entire grid of points into biome types in bulk.
- `LBiomeClassifier:type`: Returns the type name of this object.
- `LBiomeClassifier:typeOf`: Check whether this object matches a given type name.

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Foundations.`` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from ``Foundations.`` into `Platform Services`.

## Notes

- Keep this module reference synchronized with `src/procgen/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.

### 2026-05-12 Update

- Added biome classification layer (`src/procgen/biome.rs`):
	- `BiomeType`, `BiomeRules`, `BiomeClassifier`
	- `BiomeClassifier::classify`, `BiomeClassifier::classify_map`
	- `biome_map_to_rgba`
- Added Lua API in `lurek.procgen`:
	- `newBiomeClassifier(opts?)`
	- `biomeColor(name)`
	- Userdata methods: `BiomeClassifier:classify`, `BiomeClassifier:classifyMap`, `BiomeClassifier:type`, `BiomeClassifier:typeOf`.

- Added prefab stamping support for dungeon generators:
	- Rust: `rooms_dungeon_with_prefabs(opts, prefabs, stamp_value)`
	- Rust: `bsp_dungeon_with_prefabs(opts, prefabs)`
	- Lua: `lurek.procgen.roomsDungeonWithPrefabs(opts?, prefabs, stamp_value?)`
	- Lua: `lurek.procgen.bspDungeonWithPrefabs(opts?, prefabs)`
	- Prefab placement metadata is returned to Lua for deterministic post-processing.

- Added Heightmap helper constructors:
	- `Heightmap::from_noise_map(width, height, values)`
	- `Heightmap::from_cellular(width, height, cells, floor_value)`
	- Lua: `lurek.procgen.heightmapFromCellular(width, height, cells, floor_value?)`

- Added seeded parallel map generation:
	- Rust: `NoiseGenerator::generate_map_parallel(width, height, opts)`
	- Lua: `lurek.procgen.noiseMapParallelSeeded(width, height, opts?)`

- Deduplicated scalar-map grayscale conversion:
	- Shared helper: `scalar_map_to_rgba_bytes(values)`
	- Used by `Heightmap::to_rgba_bytes` and `NoiseGrid::to_rgba_bytes`.
