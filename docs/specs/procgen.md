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

- Lua-visible wrapper around the biome classification engine, used to assign biome types based on height, moisture, and temperature.

##### Fields

- No documented fields.

##### Methods

- `LBiomeClassifier:classify`: Classify a single point into a biome type based on its environmental parameters.
- `LBiomeClassifier:classifyMap`: Classify an entire grid of points into biome types in bulk.
- `LBiomeClassifier:type`: Returns the type name of this object.
- `LBiomeClassifier:typeOf`: Check whether this object matches a given type name.

#### LCellular Type

- A cellular automaton simulation grid (sand, water, fire, gas, rock) for per-cell falling-sand style simulation.

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
