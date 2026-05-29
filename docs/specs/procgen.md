# procgen

## TL;DR

- The `procgen` module is a versatile Feature Systems tier library dedicated to procedural content generation in Lurek2D.

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

## Files

### biome.rs

- Biome classification system mapping height, moisture, and temperature to terrain types.
- Defines `BiomeType` enum covering ocean, coast, desert, forest, tundra, and more.
- Configurable `BiomeRules` thresholds for tuning world generation.
- Stateless `BiomeClassifier` for single-cell or bulk grid classification.
- RGBA color mapping for biome visualisation output.

### bsp.rs

- Binary Space Partition dungeon generator: recursive splitting, leaf room placement, corridor linking.
- Configuration via `BspOpts`: grid size, recursion depth, minimum partition size, padding, seed.
- Prefab stamping: round-robin placement of named template shapes centred in qualifying rooms.
- Deterministic output driven by a seeded `Lcg` RNG for reproducible layouts.
- Pure algorithm module with no rendering or tilemap dependency.

### cellular.rs

- Cellular automata cave generator producing flat grid maps from configurable birth/survive rules.
- Supports reproducible output via seeded LCG randomisation.
- Treats out-of-bounds neighbours as solid, forming natural cave walls at map edges.

### cellular_world.rs

- Fixed-size cellular automaton grid simulating falling sand, flowing water, rising gas, and spreading fire.
- Material interaction rules: sand displaces water, fire consumes gas, gravity pulls solids down.
- Alternating sweep direction each tick to reduce lateral bias in material flow.
- RGBA image export with pluggable palette for rendering grid state to textures.
- Compact byte serialization and deserialization for save/load of grid snapshots.
- Geometric fill helpers (rect, circle) for painting materials into the grid.

### color.rs

- Convert scalar procgen output into pixel-ready RGBA byte buffers.
- Grayscale mapping with automatic 0–1 clamping.
- Suitable for heightmaps, noise previews, and debug visualisation.

### flood_fill.rs

- Four-connected flood fill on a flat `u8` grid with threshold-based matching.
- Return a binary mask of reachable cells from a seed coordinate.
- Support both above-threshold and below-threshold fill modes.

### heightmap.rs

- Procedural heightmap generation from FBM Perlin noise with configurable octaves, lacunarity, and persistence.
- Simple hydraulic erosion pass that redistributes height differences across 4-connected neighbours.
- Construction from raw noise maps or cellular automata grids with automatic normalisation to 0.0–1.0.
- Clamped coordinate access and flat RGBA byte export for GPU texture upload.
- Deterministic output controlled by a seed value passed through to the noise generator.

### lcg.rs

- 64-bit linear congruential generator (LCG) for deterministic pseudo-random number output.
- Provides seeded construction, raw `u64` stepping, and uniform `f32` sampling.
- Used as the shared RNG primitive across all `procgen` subsystems.

### lsystem.rs

- Deterministic string-rewriting L-system with configurable axiom, production rules, and iteration depth.
- Turtle-graphics interpreter converts generated strings into line segments for rendering.
- Supports branching via stack-based `[`/`]` commands for tree and fractal geometry.

### mod.rs

- Procedural generation toolkit: noise, dungeons, heightmaps, cellular worlds, and world graphs.
- Algorithms: Perlin/Simplex/Worley noise, BSP & room-scatter dungeons, cellular automata caves.
- Utilities: Poisson disk sampling, L-systems, Markov name generation, Voronoi, WFC.
- Simulation: Falling-sand cellular automaton world (sand, water, fire, gas, rock).
- All generators are deterministic given a seed via the internal LCG.

### namegen.rs

- Markov-chain name generator trained on arbitrary word corpora.
- Configurable n-gram order controls fidelity-vs-variety tradeoff.
- Deterministic output via internal LCG seeding for reproducible generation.
- Batch generation with length constraints and bounded retry logic.

### noise.rs

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

### poisson.rs

- Poisson-disk sampling: generate evenly-spaced random 2D point distributions.
- Uses Bridson's algorithm with grid acceleration for O(n) rejection.
- Deterministic via seeded LCG; produces `(x, y)` pair vectors.

### render.rs

- Tileable Perlin noise grid generation and cell access.
- Conversion to flat grayscale RGBA byte buffers for higher-tier projection.
- Does not create `RenderCommand`, `ImageData`, tilemap objects, or Lua userdata.

### rooms.rs

- Random room placement with overlap rejection and configurable size ranges.
- L-shaped corridor carving between consecutive room centres.
- Flat row-major tile grid output (wall / floor / corridor byte values).
- Prefab stamp system that centre-pastes named mask patterns into placed rooms.
- Round-robin prefab assignment across all placed rooms.

### voronoi.rs

- Voronoi diagram generation on a 2D grid with F1/F2 distance fields.
- Optional domain warp via hash noise for organic region boundaries.
- Returns region indices and per-pixel distance buffers in row-major order.

### wfc.rs

- Wave Function Collapse (WFC) grid generator with weighted tile selection.
- Adjacency-rule constraint propagation with automatic backtracking retries.
- Deterministic seeded output via the internal LCG; each retry increments the seed.
- Returns a flat row-major grid of tile IDs or `None` cells on contradiction.

### wfc_llm.rs

- LLM-assisted WFC constraint generation.
- Sends structured prompts to the global LLM endpoint and parses
- the JSON response into WFC tile sets and adjacency rules.

### world_graph.rs

- Region and edge data types representing nodes and weighted connections in a world graph.
- A* pathfinding with Euclidean heuristic for shortest-path queries between regions.
- Bounded Dijkstra reachability returning all regions within a cumulative travel cost.
- Minimum spanning tree computation via Kruskal's algorithm.
- Random world graph generation placing regions in a bounding box and connecting k-nearest neighbours.

## Lua API Ref

- Binding: `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`

### Functions

- `lurek.procgen.biomeColor`: Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.
- `lurek.procgen.bspDungeon`: Generate a dungeon layout using Binary Space Partitioning. Produces non-overlapping rooms connected by corridors.
- `lurek.procgen.bspDungeonWithPrefabs`: Generate a BSP dungeon and stamp named prefab rooms into suitable leaves. Returns dungeon layout plus prefab placement info.
- `lurek.procgen.cellularAutomata`: Generate a cave or organic map using cellular automata rules.
- `lurek.procgen.fbm`: Samples stateless fractal Brownian motion noise.
- `lurek.procgen.floodFill`: Flood-fill a grid from a starting cell, marking all connected cells that pass a threshold test.
- `lurek.procgen.generateName`: Generate a single random name based on a Markov chain trained from sample names. Great for NPC names, place names, or item names.
- `lurek.procgen.generateNames`: Generate multiple random names in one call using Markov chains trained from sample data.
- `lurek.procgen.heightmap`: Generate a fractal heightmap using multi-octave noise with optional hydraulic erosion.
- `lurek.procgen.heightmapFromCellular`: Convert a cellular automata grid into a heightmap by distance-transforming the floor cells.
- `lurek.procgen.lsystem`: Expand an L-system grammar and return the resulting string. Useful for generating branching structures like trees, rivers, or cave networks.
- `lurek.procgen.lsystemSegments`: Expand an L-system and interpret the result as turtle-graphics commands, returning line segments.
- `lurek.procgen.newBiomeClassifier`: Create a BiomeClassifier object with custom threshold rules for mapping height/moisture/temperature to biome types.
- `lurek.procgen.newCellular`: Performs the 'procgen' operation.
- `lurek.procgen.newNoiseGenerator`: Creates a procedural noise generator with an optional seed.
- `lurek.procgen.noiseMap`: Generate a 2D noise map with configurable scale, octaves, and offsets. Runs on a single thread.
- `lurek.procgen.noiseMapParallel`: Generate a 2D noise map using multiple threads for faster computation on large maps. Uses seed 0.
- `lurek.procgen.noiseMapParallelSeeded`: Generate a 2D noise map using multiple threads with a specific seed for reproducible results.
- `lurek.procgen.perlin2d`: Samples stateless 2D Perlin noise.
- `lurek.procgen.perlin3d`: Samples stateless 3D Perlin noise.
- `lurek.procgen.perlin4d`: Samples stateless 4D Perlin noise.
- `lurek.procgen.perlinNoise`: Sample periodic 2D Perlin noise at a given coordinate.
- `lurek.procgen.poissonDisk`: Generate evenly-spaced random points using Poisson disk sampling. Useful for placing trees, NPCs, or loot without clustering.
- `lurek.procgen.roomsDungeon`: Generate a dungeon by placing random non-overlapping rooms and connecting them with corridors. Also returns a full tile grid.
- `lurek.procgen.roomsDungeonWithPrefabs`: Generate a rooms-based dungeon and place named prefabs into qualifying rooms. Prefabs can have custom shape masks.
- `lurek.procgen.setConstraintsFromLLM`: Sends a natural-language prompt to the global LLM and returns WFC adjacency constraints as a Lua table.
- `lurek.procgen.simplex2d`: Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].
- `lurek.procgen.simplex3d`: Sample 3D simplex noise at a point. The third axis can be used for animation or layering.
- `lurek.procgen.simplexNoise`: Sample a 2D or 3D simplex noise value at a given point.
- `lurek.procgen.voronoi`: Compute a Voronoi diagram from a set of seed points. Returns region ownership, distance-to-nearest, and distance-to-second-nearest for each cell.
- `lurek.procgen.wfcFromPrompt`: Asks the global LLM for WFC tile definitions and adjacency rules, then runs WFC generation.
- `lurek.procgen.wfcGenerate`: Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.
- `lurek.procgen.worldGraph`: Generate a connected world graph with named regions and weighted edges. Useful for overworld maps, trade routes, or quest connectivity.

### Enums

- No documented module-level enums/constants.

### Types


#### LBiomeClassifier Type


##### Fields

- No documented fields.

##### Methods

- `LBiomeClassifier:classify`: Classify a single point into a biome type based on its environmental parameters.
- `LBiomeClassifier:classifyMap`: Classify an entire grid of points into biome types in bulk.
- `LBiomeClassifier:type`: Returns the type name of this object.
- `LBiomeClassifier:typeOf`: Check whether this object matches a given type name.


#### LCellular Type


##### Fields

- No documented fields.

##### Methods

- `LCellular:countCells`: Counts how many cells of a given material type exist in the grid.
- `LCellular:fillCircle`: Fills a circular region of cells with a material type.
- `LCellular:fillRect`: Fills a rectangular region of cells with a material type.
- `LCellular:findCells`: Returns positions of all cells matching a material type.
- `LCellular:getCell`: Returns the material type of a cell at the given grid position.
- `LCellular:loadFromBytes`: Restores cellular grid state from binary data previously produced by toBytes.
- `LCellular:setCell`: Sets a single cell in the cellular grid to a specific material type.
- `LCellular:step`: Advances the cellular simulation by one tick (particles fall, flow, burn, etc.).
- `LCellular:stepN`: Advances the cellular simulation by N ticks in a single call.
- `LCellular:toBytes`: Serializes the cellular grid to a compact binary format for saving.
- `LCellular:toImageData`: Renders the entire cellular grid to raw RGBA pixel data using the default material palette.
- `LCellular:toImageDataRegion`: Renders a rectangular sub-region of the cellular grid to raw RGBA pixel data.
- `LCellular:type`: Returns the type name of this object ("LCellular").
- `LCellular:typeOf`: Checks if this object is of a given type name.


#### LNoiseGenerator Type


##### Fields

- No documented fields.

##### Methods

- `LNoiseGenerator:fbm`: Samples fractal Brownian motion noise.
- `LNoiseGenerator:generateMap`: Generates a noise map and returns it as a flat array table.
- `LNoiseGenerator:generateMapCompute`: Generates a noise map through the compute backend and returns it as a flat array table.
- `LNoiseGenerator:getSeed`: Returns this noise generator seed.
- `LNoiseGenerator:perlin1d`: Samples 1D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin2d`: Samples 2D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin3d`: Samples 3D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin4d`: Samples 4D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:ridged`: Samples ridged fractal noise. This method is available to Lua scripts.
- `LNoiseGenerator:setSeed`: Sets this noise generator seed. This method is available to Lua scripts.
- `LNoiseGenerator:simplex1d`: Samples 1D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex2d`: Samples 2D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex3d`: Samples 3D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:turbulence`: Samples turbulence fractal noise.
- `LNoiseGenerator:type`: Returns the Lua-visible type name for this noise generator handle.
- `LNoiseGenerator:typeOf`: Returns whether this noise generator handle matches a supported type name.
- `LNoiseGenerator:warpDomain`: Samples domain-warped noise coordinates.
- `LNoiseGenerator:worley2d`: Samples 2D Worley noise. This method is available to Lua scripts.
- `LNoiseGenerator:worley3d`: Samples 3D Worley noise. This method is available to Lua scripts.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
