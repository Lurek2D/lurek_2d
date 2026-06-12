# procgen

## TL;DR

- Orchestrates deterministic generation of terrain heightmaps, biomes, dungeons, and overworlds.
- Implements Perlin/Simplex/Worley noise, cellular automata sandboxes, and Poisson disks.
- Supports L-system branching trees, Wave Function Collapse tiling, and Markov name generation.

## General Info

- Module group: `Foundations`
- Source path: `src/procgen/`
- Binding: `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`
- Lua API surface: `33` functions, `15` types, `37` methods
- Rust test path(s): src/procgen/noise_tests.rs (sibling), plus inline #[cfg(test)] in all other .rs files
- Lua test path(s): tests/lua_reorg/unit/test_procgen_unit.lua

## Summary

- The procgen module provides deterministic synthesis of maps, structures, names, and procedural data fields.
- Seeded randomness is centralized so outputs are reproducible across runs and test pipelines.
- Noise primitives include Perlin, Simplex, and Worley generation.
- Fractal combinations support richer terrain and texture-like scalar fields.
- Domain warping and tileable variants support seamless looping and stylized maps.
- Parallel generation paths support large grid workloads.
- Heightmap generation converts sampled fields into usable elevation surfaces.
- Optional erosion passes add terrain smoothing and channel-like shaping.
- Biome classification maps elevation, moisture, and temperature into discrete categories.
- Biome outputs include visual-friendly color mapping.
- BSP dungeon generation creates partitioned room-and-corridor structures.
- Room-scatter generation provides alternative stochastic dungeon layouts.
- Prefab stamping blends authored motifs into procedural results.
- Cellular automata generation supports cave-like map structures.
- Cellular worlds support emergent sand/liquid/gas/fire style simulations.
- Flood-fill helpers support region extraction and connectivity tooling.
- Poisson disk sampling supports evenly spaced placement patterns.
- Voronoi support partitions space into nearest-seed regions.
- L-systems support grammar-based branching structures and turtle output.
- Wave Function Collapse supports adjacency-constrained tile synthesis.
- WFC includes weighted tile selection and contradiction retry behavior.
- World graph generation supports region topology and route analysis.
- Graph tools include shortest-path and spanning-tree utilities.
- Markov name generation supports synthetic naming from sample corpora.
- The module exposes both low-level primitives and high-level generators.
- It is designed for both rapid prototyping and production content pipelines.
- The module owns generation logic, not gameplay interpretation.
- It does not own renderer policy, but supports preview-oriented outputs.
- Determinism and parameterization are core quality goals.
- APIs are script-friendly and suitable for automated regression checks.
- The module remains in Foundations for broad reuse across genres.
- Overall, procgen is the data-synthesis backbone for procedural world workflows.
- It lets teams scale content variety without proportional authoring cost.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### biome.rs

- Biome classification layer for turning raw environmental values such as elevation, moisture, and temperature into readable world-region identities.
- The file defines the terrain vocabulary itself and the threshold rules that decide when a sampled point should become ocean, coast, forest, desert, tundra, or another high-level biome.
- Classifier logic stays stateless so single points and full maps can be categorized with the same predictable rule set.
- Color mapping lives beside the rules, which makes the biome model useful both for gameplay semantics and for direct visualization in tools or previews.
- Threshold tuning is part of the authored surface, allowing different world flavors to emerge without changing the classification algorithm.
- Functionally this file delivers the semantic translation from continuous climate-like data into discrete terrain meaning.

### bsp.rs

- BSP dungeon generator for layouts that should feel structured, room-based, and reproducible rather than hand-authored tile by tile.
- The file recursively splits a rectangular space into partitions, chooses usable leaves for rooms, and then links those rooms with corridors that preserve navigable flow.
- Configuration controls the personality of the result through size, depth, padding, and seed rather than scattering generation policy across unrelated helpers.
- Prefab stamping extends the base dungeon with authored patterns that can be placed into qualifying rooms without sacrificing determinism.
- The implementation stays algorithmic and headless, which makes it suitable for offline generation, tests, and data-driven tooling.
- Functionally this file delivers a reproducible room-and-corridor dungeon backbone shaped by binary spatial subdivision.

### cellular.rs

- Cave-style map generator that uses cellular automata to turn noisy initial occupancy into organic cavern shapes.
- The file exposes birth and survival style rules together with seeded randomization so cave density and texture can be tuned while staying reproducible.
- Edge treatment is baked into the model to keep map borders naturally enclosed rather than porous or artificially clean.
- Functionally this file delivers fast organic cave generation from simple rule-based iteration on a flat grid.

### cellular_world.rs

- Cellular material simulation world for sand-box style phenomena where local rules create visible motion such as falling grains, flowing liquid, rising gas, and spreading fire.
- The file keeps material state on a fixed grid and advances that state through explicit interaction rules instead of a continuous physics solver.
- Alternating sweep direction helps the simulation avoid obvious left-right bias, which keeps repeated ticks from producing one-sided artifacts.
- Fill helpers make the grid directly paintable by gameplay code and tools, allowing immediate authoring of test setups, explosions, or scripted reactions.
- Byte serialization and image export let the same simulation serve runtime effects, save systems, and visual previews.
- Palette-aware rendering support keeps the cell model easy to project into textures without teaching the simulation about higher rendering layers.
- Functionally this file delivers a compact material sandbox for emergent grid-based motion and reactions.

### color.rs

- Scalar-to-color conversion helpers for procedural outputs that need to become immediate pixel data.
- The file focuses on clamped grayscale mapping so noise fields, heightmaps, and other sampled values can be previewed without bringing in a full rendering layer.
- Functionally this file delivers the simplest visual projection path from numeric procgen data to RGBA buffers.

### flood_fill.rs

- Grid flood-fill helper for discovering connected regions from a seed without needing heavier map analysis infrastructure.
- The file works over flat byte grids and uses threshold comparison to decide whether propagation should include or exclude a cell.
- Above-threshold and below-threshold modes make the same routine usable for holes, landmasses, islands, basins, and similar binary region problems.
- Functionally this file delivers reachability masks for contiguous area extraction on simple procedural maps.

### heightmap.rs

- Heightmap model for turning procedural fields into normalized terrain elevation that other systems can sample, erode, render, or classify.
- The file builds maps from layered noise or other grid sources and keeps results in a form that is easy to query by cell or export by row-major order.
- A simple erosion pass gives the generated terrain a way to soften sharp differences and hint at water-shaped structure without introducing a heavyweight terrain solver.
- Deterministic seeding keeps terrain reproduction reliable for saves, testing, and content pipelines.
- Functionally this file delivers the elevation surface from which broader terrain generation can derive shape, biome, and visual output.

### lcg.rs

- Shared deterministic random number primitive for procedural systems that need repeatable variation from a tiny, dependable core.
- The file exposes seeded stepping and simple sampling utilities so higher-level generators can stay reproducible without each carrying its own RNG implementation.
- Functionally this file delivers the compact source of randomness that keeps the rest of the procgen stack aligned around seeds.

### lsystem.rs

- L-system generator for recursive symbolic growth where simple rewrite rules can unfold into plants, roads, fractals, or other branching structures.
- The file keeps axiom, productions, and iteration depth explicit so generated strings remain deterministic and inspectable rather than hidden inside opaque helpers.
- Turtle interpretation turns those symbols into drawable line segments, giving the grammar an immediate geometric payoff.
- Stack-based branching support enables structures that fork and return, which is essential for tree-like and fractal forms.
- Functionally this file delivers a compact grammar-to-geometry pipeline for recursive content generation.

### mod.rs

- Procedural generation module that gathers deterministic algorithms for terrain, dungeons, graphs, names, tilings, simulations, and sampling into one reusable content toolbox.
- It combines low-level random and noise primitives with higher-order generators so callers can move from seeded numbers to full spatial structure without leaving the module.
- The subsystem covers both static generation and evolving grid simulation, which makes it useful for worlds that must be authored once or kept alive over time.
- Functionally this file is the high-level entry point for reproducible content synthesis across maps, layouts, regions, patterns, and emergent cellular effects.

### namegen.rs

- Markov-style name generator for producing plausible invented words from example corpora without hand-authoring every outcome.
- The file learns local character transitions from source words and then samples new sequences with configurable order to balance familiarity against novelty.
- Deterministic seeding keeps generated names stable when needed for saves, tests, or curated content batches.
- Length constraints and bounded retries make batch generation practical rather than endlessly exploratory.
- Functionally this file delivers repeatable synthetic naming for characters, places, items, factions, and other worldbuilding surfaces.

### noise.rs

- Core noise engine for procedural generation where continuous variation, repeatable randomness, and composable sampling functions are the raw material behind richer content.
- The file gathers the module's foundational field generators in one place so scripts and higher-level Rust systems can sample coherent structure instead of inventing ad hoc randomness.
- Perlin support spans multiple dimensions and both stateless helpers and seeded generator state, which makes it useful for quick probes as well as sustained content workflows.
- Simplex support broadens that sampling surface with smoother alternatives better suited to some animated or layered fields.
- Worley distance fields add cell-like spatial texture, enabling region partitioning, cracked patterns, and other feature-point-driven looks.
- Fractal combinators turn base noise into richer terrain-scale structure by layering octaves into smoother hills, harsher ridges, or turbulent distortions.
- Domain warping further bends otherwise regular fields so generated output feels less axis-bound and more organically varied.
- Height-map generation helpers keep the module tied to practical terrain production rather than remaining a pile of isolated math routines.
- Parallel generation support matters here because large maps are a first-class workload, not an afterthought.
- Tileable periodic variants let the same toolbox serve looping textures and wraparound worlds where seam-free repetition matters.
- Internal hashing, gradients, and permutation logic live close to the public samplers so correctness and determinism share one source of truth.
- Seed handling is treated as authored input, which keeps results reproducible across tests, saves, and content pipelines.
- The file therefore acts as both a mathematical substrate and a production utility layer for the rest of procedural generation.
- It is intentionally broad because many higher-order systems in the module eventually reduce to sampled scalar fields shaped here.
- Functionally this file delivers the reusable field-generation backbone behind terrain, texture, biome, and layout variation across the engine.

### poisson.rs

- Even-spacing point sampler for procedural placement problems where randomness should look natural without collapsing into visible clustering.
- The file implements Bridson-style Poisson disk generation with acceleration structures and seeded control so distribution quality and reproducibility both stay strong.
- Functionally this file delivers scattered-but-separated 2D points for trees, loot, enemies, landmarks, and other placement-heavy content.

### render.rs

- Lightweight projection layer for sampled noise grids that need storage, cell access, and quick grayscale export without depending on higher rendering systems.
- The file keeps tileable Perlin-backed values in a compact grid form and exposes them in a way that is useful for previews, tooling, and texture-oriented workflows.
- Functionally this file delivers a small bridge from procedural scalar fields to inspectable pixel-ready grid data.

### rooms.rs

- Room-scatter dungeon generator for layouts that start from independent room candidates and then stitch them into a traversable interior.
- The file focuses on non-overlapping room placement, giving each accepted space a clear rectangular identity before corridor carving connects the overall layout.
- L-shaped corridor logic keeps navigation simple and readable while still creating believable links between dispersed rooms.
- Flat tile-grid output makes the generator easy to consume by map systems, tests, and script-side post-processing.
- Prefab stamping layers authored motifs on top of procedural geometry so hand-designed shapes can appear inside otherwise generated rooms.
- Functionally this file delivers a scatter-style dungeon layout path that balances randomness, navigability, and controlled room embellishment.

### voronoi.rs

- Voronoi field generator for dividing space into nearest-seed regions and measuring how each cell relates to its closest feature points.
- The file returns both ownership and distance information, which makes it useful for region maps, borders, crackle patterns, and cell-based world partitioning.
- Optional warp support roughens otherwise clean geometric boundaries so the resulting regions can feel less synthetic.
- Functionally this file delivers region tessellation data for map segmentation and distance-based procedural effects.

### wfc.rs

- Constraint-based tile generator for patterns that should emerge from local adjacency rules rather than from direct handcrafted placement.
- The file treats each cell as a shrinking set of possible tiles and propagates neighbor constraints until a consistent arrangement collapses into concrete choices.
- Weighted selection gives the same ruleset room for stylistic bias so some tiles appear more often without breaking compatibility logic.
- Retry behavior acknowledges that contradictions are part of this style of generation and turns them into controlled regeneration rather than silent corruption.
- Functionally this file delivers deterministic rule-driven tiling for maps, motifs, and pattern synthesis where local consistency matters most.

### wfc_llm.rs

- LLM-assisted helper layer for turning natural-language intent into concrete WFC tiles, weights, and adjacency rules.
- The file handles prompt shaping and response parsing so language-model output can become structured generator input rather than loose text.
- Keeping that translation here isolates the experimental boundary between authored prompts and deterministic procedural systems.
- Functionally this file delivers an assisted authoring path for bootstrapping WFC constraints from descriptive input.

### world_graph.rs

- World-graph generation and traversal layer for overworld-style structures where places are discrete nodes connected by weighted travel links.
- The file defines the region and edge model itself, then builds pathfinding and reachability logic directly on top of that shared representation.
- A* and bounded Dijkstra cover shortest routes and local travel envelopes, which makes the graph useful for quests, logistics, and map progression.
- Minimum spanning tree support gives generation and analysis code a way to reason about essential connectivity independent of redundant routes.
- Random graph construction turns the same structure into a content generator, placing regions spatially and wiring them into plausible networks.
- Functionally this file delivers the connected overworld skeleton for route planning, regional structure, and graph-shaped world content.



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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
