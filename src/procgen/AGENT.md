# `procgen` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Core Engine Subsystems |
| **Status**     | Implemented — Full                                   |
| **Lua API** | `luna.math` (sub-functions) |
| **Source** | `src/procgen/` |
| **Rust Tests** | `tests/unit/procgen_tests.rs`                    |
| **Lua Tests**  | `tests/lua/unit/test_procgen.lua`                     |
| **Tests** | `tests/lua/unit/test_math.lua` |

## Summary

The `procgen` module provides five stateless procedural-generation algorithms
used during world-creation phases.  Every function is CPU-only, deterministic
(seeded), and returns plain data — no GPU or audio dependency.  Results are
flat arrays or point lists that games can post-process into tilemaps, spawn
tables, or noise textures before the first frame.

* **Cellular automata** — iterative birth/survive rules on a binary grid to
  produce cave-like or room-like structures.
* **Flood fill** — BFS region discovery on a grid, useful for isolating rooms
  or tagging connected areas after a cellular pass.
* **Periodic Perlin noise** — tileable gradient noise; useful for seamlessly
  looping scrolling backgrounds or terrain heightmaps.
* **Poisson-disk sampling** — Bridson's algorithm for sampling a set of points
  with a guaranteed minimum inter-point distance; useful for object placement
  that avoids clumping.
* **Voronoi diagram** — Lloyd-style assignment of every grid cell to its
  nearest input point, with optional domain-warping for organic irregularity.

The internal `Lcg` struct (`pub(crate)`) provides a fast linear-congruential
generator shared across the above algorithms.  It is not exposed to Lua.

All five algorithms are bound to Lua under `luna.math.*` by `lua_api/math_api.rs`.

## Architecture

```
procgen (module root, re-exports public API)
  │
  ├── cellular.rs       — birth/survive cellular automata
  ├── flood_fill.rs     — BFS connected-region fill
  ├── noise_ext.rs      — tileable Perlin noise
  ├── poisson.rs        — Poisson-disk point sampling
  ├── voronoi.rs        — Voronoi region assignment + domain warp
  └── lcg.rs            — internal LCG seed helper (pub(crate))
```

## Source Files

| File | Purpose |
|------|---------|
| `mod.rs` | Module root; re-exports all public API items |
| `cellular.rs` | Cellular-automata grid generation with configurable birth/survive rules |
| `flood_fill.rs` | BFS flood-fill returning a reachability mask |
| `noise_ext.rs` | Seamlessly tileable Perlin noise via periodic gradients |
| `poisson.rs` | Bridson Poisson-disk sampling for well-distributed point sets |
| `voronoi.rs` | Voronoi region + distance fields with optional domain warping |
| `lcg.rs` | Internal linear-congruential generator (not public) |

## Submodules

### `procgen::cellular`

Cellular-automata cave generation.

- **`CellularOpts`** (struct): Configuration for `cellular_automata`.
- **`cellular_automata`** (fn): Run `opts.iterations` rounds of birth/survive on a seeded random grid.

### `procgen::flood_fill`

BFS reachability fill.

- **`flood_fill`** (fn): Return a `Vec<bool>` mask of all cells reachable from `(sx, sy)` via the given threshold rule.

### `procgen::noise_ext`

Tileable Perlin noise.

- **`perlin_noise_periodic`** (fn): Evaluate seamlessly tileable 2D Perlin noise at `(x, y)` with period `(px, py)`.

### `procgen::poisson`

Poisson-disk point sampling.

- **`poisson_disk`** (fn): Generate a set of points in `[0, width] × [0, height]` with at least `min_dist` separation.

### `procgen::voronoi`

Voronoi region and distance field generation.

- **`VoronoiOpts`** (struct): Configuration for domain warping applied before distance calculation.
- **`voronoi_diagram`** (fn): Assign every cell to its nearest input point and return region, distance, and second-distance arrays.

## Key Types

### Structs

#### `procgen::CellularOpts`

Configuration for `cellular_automata`.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `fill` | `f32` | `0.45` | Initial fill probability (0–1) |
| `iterations` | `u32` | `5` | Number of birth/survive rounds |
| `birth` | `u32` | `6` | Neighbour count that births a live cell |
| `survive` | `u32` | `4` | Neighbour count that keeps a live cell alive |
| `seed` | `u64` | `12345` | RNG seed |

#### `procgen::VoronoiOpts`

Configuration for domain warping applied to Voronoi distance calculation.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `warp_scale` | `f32` | `0.1` | Noise frequency used for domain warp |
| `warp_strength` | `f32` | `0.0` | Warp displacement magnitude (0 = no warp) |
| `seed` | `u64` | `0` | RNG seed for warp noise |

## Public Functions

| Function | Signature | Returns |
|----------|-----------|---------|
| `cellular_automata` | `(width: u32, height: u32, opts: &CellularOpts) -> Vec<u8>` | Flat row-major binary grid (0=floor, 1=wall) |
| `flood_fill` | `(data: &[u8], w: u32, h: u32, sx: u32, sy: u32, threshold: u8, above: bool) -> Vec<bool>` | Reachability mask, same length as `data` |
| `perlin_noise_periodic` | `(x: f64, y: f64, px: f64, py: f64) -> f64` | Noise value in `[-1, 1]` |
| `poisson_disk` | `(w: f32, h: f32, min_dist: f32, max_attempts: u32, seed: u64) -> Vec<(f32, f32)>` | List of `(x, y)` sample points |
| `voronoi_diagram` | `(w: u32, h: u32, points: &[(f32,f32)], opts: &VoronoiOpts) -> (Vec<u32>, Vec<f32>, Vec<f32>)` | (regions, distances, second-distances) |

## Lua API

All functions are registered under `luna.math.*` by `src/lua_api/math_api.rs`.

| Lua function | Parameters | Returns |
|---|---|---|
| `luna.math.cellularAutomata(w, h, opts?)` | `w, h: integer`, `opts: {fill, iterations, birth, survive, seed}?` | flat `{integer}` (1=wall) |
| `luna.math.floodFill(data, w, h, sx, sy, threshold, mode?)` | `data: {integer}`, coords 1-based, `threshold: integer`, `mode: "above"?` | flat `{1/0}` reachability mask |
| `luna.math.perlinNoisePeriodic(x, y, px, py)` | all `number` | `number` in `[-1, 1]` |
| `luna.math.poissonDisk(w, h, minDist, maxAttempts?, seed?)` | `w, h, minDist: number`, optional integer/seed | `{{x, y}, ...}` |
| `luna.math.voronoiDiagram(w, h, points, opts?)` | `w, h: integer`, `points: {x,y,...}`, `opts: {warpScale, warpStrength, seed}?` | `regions, distances, secondDistances` (three flat arrays) |

## Item Summary

| Category | Count |
|----------|-------|
| Structs | 2 |
| Free functions | 5 |
| Lua bindings | 5 |
| Source files | 7 |

## Lua Examples

```lua
function luna.load()
    gen = luna.procgen.new(12345)  -- seed

    -- Generate dungeon
    dungeon = gen:dungeon({
        width = 80, height = 50,
        rooms = 12, min_room = 4, max_room = 10
    })

    -- Generate terrain noise map
    terrain = gen:noiseMap(200, 100, {scale=0.05, octaves=4})
end
```

## References

| Module      | Relationship  | Notes                                              |
|-------------|---------------|----------------------------------------------------|
| `engine`    | Imports from  | Uses `SharedState`                                 |
| `math`      | Imports from  | Noise functions, `RandomGenerator`, `Vec2`         |
| `tilemap`   | Related       | Procedurally generated maps are often stored in `tilemap` structures |
| `pathfinding`| Related      | Generated dungeons feed into `pathfinding` grids   |
| `lua_api`   | Imported by   | `src/lua_api/procgen_api.rs` registers `luna.procgen.*` |

## Notes

- All generation functions are deterministic for a given seed — same seed produces same output.
- Dungeon generation places rooms, then connects them with corridors using MST + random extra connections.
- Noise map generation uses `math::noise_generator` under the hood; the `procgen` API just wraps it with domain defaults.
- Cave generation uses cellular automata (born/survive rules are configurable).
