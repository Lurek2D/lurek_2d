# procgen

## General Info

- Module group: `Foundations.`
- Source path: `src/procgen/`
- Lua API path(s): `src/lua_api/procgen_api.rs`
- Primary Lua namespace: `lurek.procgen`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The procgen module owns reusable procedural-generation algorithms that return plain data structures instead of engine-owned objects. It exists so gameplay and content code can generate caves, reachability masks, tileable noise, point distributions, and Voronoi regions without reimplementing seeded randomness or spatial traversal logic.

Its public surface is intentionally stateless from the caller's perspective: configuration is passed through function arguments or small option structs, while internal helpers such as the private LCG stay inside the module. It does not own tilemap editing, scene placement, or general renderer behavior, although it does include a small `NoiseGrid` debug-visualization type for turning sampled noise into render commands or CPU images.

**Scope boundary**: This module currently depends on `image`, `render`, `runtime`. It stays within the Foundations responsibility boundary defined in the architecture docs.

## Files

- `cellular.rs`: Cellular automata map generation with configurable fill, birth, survive, and iteration settings.
- `flood_fill.rs`: Threshold-based BFS flood fill over flat byte grids.
- `lcg.rs`: Internal deterministic random generator shared by the generation algorithms.
- `mod.rs`: Module root and re-export surface for the public generation functions and option structs.
- `noise_ext.rs`: Periodic Perlin noise that tiles cleanly across configurable wrap periods.
- `poisson.rs`: Bridson-style Poisson-disk sampling for evenly spaced point placement.
- `render.rs`: `NoiseGrid` sampling and visualization helpers for command-queue or CPU-image inspection.
- `voronoi.rs`: Voronoi region, nearest-distance, and second-distance field generation with optional warp.

## Types

- `CellularOpts` (`struct`, `cellular.rs`): Configuration bundle for cellular automata generation.
- `Lcg` (`struct`, `lcg.rs`): Internal deterministic RNG used to keep the public algorithms reproducible.
- `NoiseGrid` (`struct`, `render.rs`): Sampled noise buffer that can be exported as render commands or a CPU image.
- `VoronoiOpts` (`struct`, `voronoi.rs`): Configuration bundle for Voronoi generation and optional domain warping.

## Functions

- `cellular_automata` (`cellular.rs`): Generates a cave/dungeon map using cellular automata.
- `flood_fill` (`flood_fill.rs`): BFS flood fill on a flat grid, returning a binary mask of all cells reachable from a seed position whose values satisfy `threshold`.
- `Lcg::new` (`lcg.rs`): Creates a new LCG seeded with the given value.
- `Lcg::next` (`lcg.rs`): Returns the next pseudo-random `u64`.
- `Lcg::next_f32` (`lcg.rs`): Returns the next pseudo-random `f32` in [0, 1).
- `perlin_noise_periodic` (`noise_ext.rs`): Periodic Perlin noise that tiles over period (px, py).
- `poisson_disk` (`poisson.rs`): Generates Poisson disk sample points using Bridson's algorithm.
- `NoiseGrid::from_perlin` (`render.rs`): Sample periodic Perlin noise onto a grid.
- `NoiseGrid::generate_render_commands` (`render.rs`): Generate render commands visualising the noise grid as a greyscale tile mosaic.
- `NoiseGrid::draw_to_image` (`render.rs`): Render the noise grid to a CPU image.
- `voronoi_diagram` (`voronoi.rs`): Generates a Voronoi diagram over a `width × height` grid for the given seed points.

## Lua API Reference

- Binding path(s): `src/lua_api/procgen_api.rs`
- Namespace: `lurek.procgen`

### Module Functions
- `lurek.procgen.cellularAutomata`: Generates a cave-like map using cellular automata.
- `lurek.procgen.floodFill`: BFS flood fill on a flat grid of bytes.
- `lurek.procgen.perlinNoise`: Evaluates periodic Perlin noise at a point.
- `lurek.procgen.poissonDisk`: Generates Poisson disk sample points using Bridson's algorithm.
- `lurek.procgen.voronoi`: Generates a Voronoi diagram for a set of seed points.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/procgen/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
