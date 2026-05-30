# procgen

## General Info

- Module group: `Foundations`
- Source path: `src/procgen/`
- Binding: `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`
- Lua API surface: `33` functions, `15` types, `37` methods
- Rust test path(s): src/procgen/noise_tests.rs (sibling), plus inline #[cfg(test)] in all other .rs files
- Lua test path(s): none found in the workspace

## Summary

It offers a rich suite of deterministic, headless-testable algorithms for creating diverse game worlds, terrains, and structures. Central to the module is a robust `NoiseGenerator` built on an internal seeded Linear Congruential Generator (LCG). It supports 2D/3D/4D Perlin and Simplex noise, as well as 2D/3D Worley (cellular) noise with various distance metrics. These base noises can be combined using fractal combinators like Fractal Brownian Motion (FBM), ridged multifractal, and turbulence, and deformed via domain warping. For map generation, `procgen` provides sequential and parallel (`rayon`-powered) heightmap generation with options for hydraulic erosion, which can then be classified into dynamic biomes (e.g., ocean, desert, forest) via the `BiomeClassifier`.

The module also excels at dungeon and interior generation. The `BspDungeon` generator uses Binary Space Partitioning to recursively divide space and carve rooms connected by L-shaped corridors. Alternatively, the `rooms_dungeon` generator places random non-overlapping rooms. Both systems support a prefab stamping feature that cleanly pastes named template shapes into qualifying rooms in a round-robin fashion. For organic caves, the `cellular_automata` generator applies birth/survival rules to a grid to form natural-looking caverns.

For advanced world-building, `procgen` includes a `world_graph` subsystem for generating overworld node topologies, complete with A* pathfinding and Kruskal's minimum spanning tree algorithms. It also features a Wave Function Collapse (`wfc`) solver for constraint-based tile placement, Voronoi tessellation for regional partitioning, and Poisson-disk sampling for natural, evenly-spaced object distribution. L-systems provide string-rewriting and turtle-graphics interpretation for generating fractal trees or road networks. Finally, a Markov-chain `NameGen` creates plausible, random names trained on input word corpora. All these algorithms are thoroughly exposed to Lua via the `lurek.procgen.*` API, enabling script developers to construct infinitely varied, reproducible game content on the fly.

## Files

### [biome.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/biome.rs)

- Biome classification layer for turning raw environmental values such as elevation, moisture, and temperature into readable world-region identities.
- The file defines the terrain vocabulary itself and the threshold rules that decide when a sampled point should become ocean, coast, forest, desert, tundra, or another high-level biome.
- Classifier logic stays stateless so single points and full maps can be categorized with the same predictable rule set.
- Color mapping lives beside the rules, which makes the biome model useful both for gameplay semantics and for direct visualization in tools or previews.
- Threshold tuning is part of the authored surface, allowing different world flavors to emerge without changing the classification algorithm.
- Functionally this file delivers the semantic translation from continuous climate-like data into discrete terrain meaning.

### [bsp.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/bsp.rs)

- BSP dungeon generator for layouts that should feel structured, room-based, and reproducible rather than hand-authored tile by tile.
- The file recursively splits a rectangular space into partitions, chooses usable leaves for rooms, and then links those rooms with corridors that preserve navigable flow.
- Configuration controls the personality of the result through size, depth, padding, and seed rather than scattering generation policy across unrelated helpers.
- Prefab stamping extends the base dungeon with authored patterns that can be placed into qualifying rooms without sacrificing determinism.
- The implementation stays algorithmic and headless, which makes it suitable for offline generation, tests, and data-driven tooling.
- Functionally this file delivers a reproducible room-and-corridor dungeon backbone shaped by binary spatial subdivision.

### [cellular.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/cellular.rs)

- Cave-style map generator that uses cellular automata to turn noisy initial occupancy into organic cavern shapes.
- The file exposes birth and survival style rules together with seeded randomization so cave density and texture can be tuned while staying reproducible.
- Edge treatment is baked into the model to keep map borders naturally enclosed rather than porous or artificially clean.
- Functionally this file delivers fast organic cave generation from simple rule-based iteration on a flat grid.

### [cellular_world.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/cellular_world.rs)

- Cellular material simulation world for sand-box style phenomena where local rules create visible motion such as falling grains, flowing liquid, rising gas, and spreading fire.
- The file keeps material state on a fixed grid and advances that state through explicit interaction rules instead of a continuous physics solver.
- Alternating sweep direction helps the simulation avoid obvious left-right bias, which keeps repeated ticks from producing one-sided artifacts.
- Fill helpers make the grid directly paintable by gameplay code and tools, allowing immediate authoring of test setups, explosions, or scripted reactions.
- Byte serialization and image export let the same simulation serve runtime effects, save systems, and visual previews.
- Palette-aware rendering support keeps the cell model easy to project into textures without teaching the simulation about higher rendering layers.
- Functionally this file delivers a compact material sandbox for emergent grid-based motion and reactions.

### [color.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/color.rs)

- Scalar-to-color conversion helpers for procedural outputs that need to become immediate pixel data.
- The file focuses on clamped grayscale mapping so noise fields, heightmaps, and other sampled values can be previewed without bringing in a full rendering layer.
- Functionally this file delivers the simplest visual projection path from numeric procgen data to RGBA buffers.

### [flood_fill.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/flood_fill.rs)

- Grid flood-fill helper for discovering connected regions from a seed without needing heavier map analysis infrastructure.
- The file works over flat byte grids and uses threshold comparison to decide whether propagation should include or exclude a cell.
- Above-threshold and below-threshold modes make the same routine usable for holes, landmasses, islands, basins, and similar binary region problems.
- Functionally this file delivers reachability masks for contiguous area extraction on simple procedural maps.

### [heightmap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/heightmap.rs)

- Heightmap model for turning procedural fields into normalized terrain elevation that other systems can sample, erode, render, or classify.
- The file builds maps from layered noise or other grid sources and keeps results in a form that is easy to query by cell or export by row-major order.
- A simple erosion pass gives the generated terrain a way to soften sharp differences and hint at water-shaped structure without introducing a heavyweight terrain solver.
- Deterministic seeding keeps terrain reproduction reliable for saves, testing, and content pipelines.
- Functionally this file delivers the elevation surface from which broader terrain generation can derive shape, biome, and visual output.

### [lcg.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/lcg.rs)

- Shared deterministic random number primitive for procedural systems that need repeatable variation from a tiny, dependable core.
- The file exposes seeded stepping and simple sampling utilities so higher-level generators can stay reproducible without each carrying its own RNG implementation.
- Functionally this file delivers the compact source of randomness that keeps the rest of the procgen stack aligned around seeds.

### [lsystem.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/lsystem.rs)

- L-system generator for recursive symbolic growth where simple rewrite rules can unfold into plants, roads, fractals, or other branching structures.
- The file keeps axiom, productions, and iteration depth explicit so generated strings remain deterministic and inspectable rather than hidden inside opaque helpers.
- Turtle interpretation turns those symbols into drawable line segments, giving the grammar an immediate geometric payoff.
- Stack-based branching support enables structures that fork and return, which is essential for tree-like and fractal forms.
- Functionally this file delivers a compact grammar-to-geometry pipeline for recursive content generation.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/mod.rs)

- Procedural generation module that gathers deterministic algorithms for terrain, dungeons, graphs, names, tilings, simulations, and sampling into one reusable content toolbox.
- It combines low-level random and noise primitives with higher-order generators so callers can move from seeded numbers to full spatial structure without leaving the module.
- The subsystem covers both static generation and evolving grid simulation, which makes it useful for worlds that must be authored once or kept alive over time.
- Functionally this file is the high-level entry point for reproducible content synthesis across maps, layouts, regions, patterns, and emergent cellular effects.

### [namegen.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/namegen.rs)

- Markov-style name generator for producing plausible invented words from example corpora without hand-authoring every outcome.
- The file learns local character transitions from source words and then samples new sequences with configurable order to balance familiarity against novelty.
- Deterministic seeding keeps generated names stable when needed for saves, tests, or curated content batches.
- Length constraints and bounded retries make batch generation practical rather than endlessly exploratory.
- Functionally this file delivers repeatable synthetic naming for characters, places, items, factions, and other worldbuilding surfaces.

### [noise.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/noise.rs)

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

### [poisson.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/poisson.rs)

- Even-spacing point sampler for procedural placement problems where randomness should look natural without collapsing into visible clustering.
- The file implements Bridson-style Poisson disk generation with acceleration structures and seeded control so distribution quality and reproducibility both stay strong.
- Functionally this file delivers scattered-but-separated 2D points for trees, loot, enemies, landmarks, and other placement-heavy content.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/render.rs)

- Lightweight projection layer for sampled noise grids that need storage, cell access, and quick grayscale export without depending on higher rendering systems.
- The file keeps tileable Perlin-backed values in a compact grid form and exposes them in a way that is useful for previews, tooling, and texture-oriented workflows.
- Functionally this file delivers a small bridge from procedural scalar fields to inspectable pixel-ready grid data.

### [rooms.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/rooms.rs)

- Room-scatter dungeon generator for layouts that start from independent room candidates and then stitch them into a traversable interior.
- The file focuses on non-overlapping room placement, giving each accepted space a clear rectangular identity before corridor carving connects the overall layout.
- L-shaped corridor logic keeps navigation simple and readable while still creating believable links between dispersed rooms.
- Flat tile-grid output makes the generator easy to consume by map systems, tests, and script-side post-processing.
- Prefab stamping layers authored motifs on top of procedural geometry so hand-designed shapes can appear inside otherwise generated rooms.
- Functionally this file delivers a scatter-style dungeon layout path that balances randomness, navigability, and controlled room embellishment.

### [voronoi.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/voronoi.rs)

- Voronoi field generator for dividing space into nearest-seed regions and measuring how each cell relates to its closest feature points.
- The file returns both ownership and distance information, which makes it useful for region maps, borders, crackle patterns, and cell-based world partitioning.
- Optional warp support roughens otherwise clean geometric boundaries so the resulting regions can feel less synthetic.
- Functionally this file delivers region tessellation data for map segmentation and distance-based procedural effects.

### [wfc.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/wfc.rs)

- Constraint-based tile generator for patterns that should emerge from local adjacency rules rather than from direct handcrafted placement.
- The file treats each cell as a shrinking set of possible tiles and propagates neighbor constraints until a consistent arrangement collapses into concrete choices.
- Weighted selection gives the same ruleset room for stylistic bias so some tiles appear more often without breaking compatibility logic.
- Retry behavior acknowledges that contradictions are part of this style of generation and turns them into controlled regeneration rather than silent corruption.
- Functionally this file delivers deterministic rule-driven tiling for maps, motifs, and pattern synthesis where local consistency matters most.

### [wfc_llm.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/wfc_llm.rs)

- LLM-assisted helper layer for turning natural-language intent into concrete WFC tiles, weights, and adjacency rules.
- The file handles prompt shaping and response parsing so language-model output can become structured generator input rather than loose text.
- Keeping that translation here isolates the experimental boundary between authored prompts and deterministic procedural systems.
- Functionally this file delivers an assisted authoring path for bootstrapping WFC constraints from descriptive input.

### [world_graph.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/procgen/world_graph.rs)

- World-graph generation and traversal layer for overworld-style structures where places are discrete nodes connected by weighted travel links.
- The file defines the region and edge model itself, then builds pathfinding and reachability logic directly on top of that shared representation.
- A* and bounded Dijkstra cover shortest routes and local travel envelopes, which makes the graph useful for quests, logistics, and map progression.
- Minimum spanning tree support gives generation and analysis code a way to reason about essential connectivity independent of redundant routes.
- Random graph construction turns the same structure into a content generator, placing regions spatially and wiring them into plausible networks.
- Functionally this file delivers the connected overworld skeleton for route planning, regional structure, and graph-shaped world content.
