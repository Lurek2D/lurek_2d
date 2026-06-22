# procgen manual spec overlay

## TL;DR

- Orchestrates deterministic generation of terrain heightmaps, biomes, dungeons, and overworlds.
- Implements Perlin/Simplex/Worley noise, cellular automata sandboxes, and Poisson disks.
- Supports L-system branching trees, Wave Function Collapse tiling, and Markov name generation.

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

## Architecture Links

- Intentionally empty.
