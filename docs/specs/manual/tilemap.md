# tilemap manual spec overlay

## TL;DR

- Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.
- Owns runtime tilemap storage, layers, chunks, tile ids, coordinate conversion, autotiling, and render-command payload generation.
- Provides hex/grid coordinate helpers and polygon/region utilities without owning gameplay legality.
- Safe constructors, bounded importers, and bounded tile operations reject oversized input before allocation-heavy work.
- Tile blockers, movement costs, visibility, fog, action legality, and tile lighting belong to `tilefield`, `pathfind`, `awareness`, and `tilelight`.

## Summary

- The `tilemap` module is the engine's runtime tile-grid storage and presentation bridge for users who want tile-based spaces to be authored, generated, imported, indexed, and submitted to rendering through one reusable storage model.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, rendering rules, overlays, and metadata, while traversal semantics live in systems that consume shared data.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Movement blockers, line-of-sight blockers, tile-light blockers, ranges, action masks, and fog are not inferred by `tilemap`; projects materialize those semantics into `tilefield` and run `pathfind`, `awareness`, and `tilelight` independently.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers describe authored areas over the same map, but trigger/event policy stays in Lua or specialized gameplay systems.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: `render` needs projection payloads, `pathfind` needs traversability from `tilefield`, and gameplay logic may need regions or author refs.
- It also gives projects a stable place to express tile ids, tile metadata links, adjacency helpers, and region structure without mixing in per-system gameplay state.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful for drawing terrain and organizing visual tile space, while shared gameplay interpretation is stored in `tilefield`.
- The feature therefore serves as storage and presentation integration: it holds tile IDs and tile-space metadata well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `tilelight`, `awareness`, minimap helpers, physics scripts, raycaster, and `render` all consume tile-space in specialized ways, but `tilemap` owns the visual tile grid and coordinate model.
- Read `tilemap` as the engine's authority for visual tilemap storage and tile-world coordinate structure.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `tilemap` owns map storage, layers, chunks, tile ids, orientation/projection metadata, imports/exports, draw helpers, and tile-coordinate utilities.
- Tile gameplay semantics such as movement blockers, vision/action blockers, and tile-light blockers belong in `tilefield` when a project needs one shared source of truth.
- `LTileSet` owns atlas-local tile metadata: visual source rectangles, animation, autotile rules, optional profile names, optional physics-shape names, and arbitrary author properties. Sprite atlases own image regions; tileset metadata explains what a tile id means.
- Tileset profile names are lightweight links into `tilefield` profiles. They do not make `tilemap` depend on `tilefield`, and they do not duplicate full movement, vision, action, or light costs inside the atlas object.
- `lurek.tilefield.fromTileMap(tilemap, opts)` copies tilemap state into a field snapshot. It only applies movement blockers from explicit `solidGids`; it does not infer solidity from the tileset. Later tilemap edits are not automatically synchronized unless the adapter is called again.
- `lurek.tilemap.newTileSet(...)` remains a compatibility alias for the tileset owner; new code should prefer `lurek.tileset.newTileSet(...)` while existing tilemap scripts remain supported.
- `lurek.tilemap.newTileMap(...)` and `lurek.tilemap.newChunkMap(...)` accept an optional limits table with ceilings such as `maxLayers`, `maxTiles`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, and `maxTileOperationCells`.
- `lurek.tilemap.loadTMX(xml, opts)` supports strict/bounded import policy through `strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`, and the same byte/size limits used by safe constructors.
- `LTileMap:worldToTile(...)` preserves legacy clamping semantics, while `LTileMap:tryWorldToTile(...)` returns `nil` for negative or non-finite world coordinates and should be preferred for picking front-ends.
- Reverse tile-position indexing is lazy after large writes such as `fill(...)`; callers that need dense reverse lookups should use `tileTypeIndex(...)` or `findTilesByGid(...)` and can inspect `getDiagnostics().lazyIndexRebuilds`.
- Diagnostics counters are part of the public debugging contract: invalid layer access, invalid coordinates, invalid coordinate queries, unknown gids, and lazy reverse-index rebuilds are observable through `LTileMap:getDiagnostics()`.
- Tilemap shader bindings are visual-only render bindings. `LTileMap:setShader(shaderOrNil)` applies a `tilemap` target shader to generated tilemap render commands, while `LTileMap:setLayerShader(layer, shaderOrNil)` overrides one layer. Tilemap stores only `ShaderKey` handles and semantic layer choices; WGSL validation, GPU pipeline selection, and execution stay in `render`.
- The current `tilemap` shader contract exposes draw color at `@location(0)` and uv at `@location(1)`. Textured tile visuals receive atlas uv; debug-color tile primitives receive zero uv until tilemap-specific vertex payloads are added.

## Safety and Ownership Contract

- `TileMap` and `ChunkMap` are the authoritative stores for their respective data. `LargeMapRenderer` owns only an explicitly supplied dense snapshot and its chunk/culling cache; changing a `TileMap` does not silently update a renderer snapshot, and renderer edits do not mutate a `TileMap`.
- `LChunkMap` exposes a logical tile-content version, prepared batches, bulk reads, regional snapshots, and deterministic regional hashes. Prepared commits validate the whole edit list and advance the version once.
- `LLargeMapRenderer:setTiles` validates every zero-based dense-snapshot coordinate before the first write and advances its independent snapshot version once. It remains a render snapshot, not a bridge back to `TileMap` or `ChunkMap`.
- `TileMapLimits` defaults are `maxLayers=256`, `maxTiles=16,777,216`, `maxImportBytes=8 MiB`, `maxDecodedBytes=64 MiB`, `maxChunkCells=1,048,576`, `maxChunks=1,048,576`, and `maxTileOperationCells=1,048,576`. Option tables may lower or raise these ceilings only when the resulting configuration is non-zero and addressable.
- Fallible constructors and mutators reject invalid limits, zero dimensions, overflowing cell/chunk counts, excessive operations, and mismatched dense payload lengths before allocating. Legacy infallible wrappers retain compatibility by clamping constructor inputs or ignoring typed mutation errors; security-sensitive Lua constructors use the fallible path and return a runtime error.
- Public Lua indices for layers, tilesets, and autotile operations are one-based. Zero or underflowing indices are rejected rather than wrapping to the final Rust element.
- Projection inputs must be finite; extents, tile sizes, viewport dimensions, camera zoom, and LOD thresholds must be positive. LOD thresholds are sorted and deduplicated. Animation `dt` must be finite and non-negative.
- Dirty tracking is local: changing a tile marks only its changed chunk/layer, unchanged GIDs do not create duplicate reverse-index entries, and batch edits return deterministic touched-chunk coordinates. Eager reverse indexes update in place; lazy indexes are invalidated and rebuilt on the next query. Animation timers are pruned when the active animated set is rebuilt.

## Import and Serialization Policy

- `loadTMX` enforces raw and decoded byte budgets, bounded layer/tileset/object/property work, finite numeric attributes, and a strict-or-pad/truncate layer-size policy. External TSX files require `allowExternalTilesets=true`; safe-path mode rejects traversal/absolute paths outside `assetRoot`.
- `fromLDtk` bounds recursive JSON depth/node work, level/layer counts, grid dimensions, tile entries, and tileset metadata before dense map construction. Malformed, oversized, or out-of-range values return structured import errors.
- Chunk bytes use little-endian `LCM2`: magic, version `u16`, reserved flags `u16` (currently zero), chunk size `u32`, then exactly `chunkSize²` little-endian `u32` GIDs. Version, reserved flags, chunk size, truncation, excess bytes, and configured allocation limits are validated before replacement.
- `newLargeMapRenderer(tileW, tileH, opts)` and `newIsoMap(width, height, tileW, tileH, levelHeight, partCount, opts)` accept the same limits table where their allocations or level storage are bounded.

## Architecture Links

- Intentionally empty.
