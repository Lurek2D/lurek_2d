# tilemap manual spec overlay

## TL;DR

- Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.
- Features autotiling, procedural generation, swept rect collisions, and pathfind navgrids.
- Provides hex rings, polygon trigger zones, and event callbacks for entity transitions.
- Safe constructors, bounded importers, and checked collision queries reject oversized or invalid inputs before allocation-heavy work.
- Treats `rectOverlapsSolid`/`sweepRect` as tile-grid collision queries; physics bodies still require their own `lurek.physics` colliders and sync flow.

## Summary

- The `tilemap` module is the engine's full grid-world framework for users who want tile-based spaces to be authored, generated, rendered, queried, and traversed through one reusable system rather than through several disconnected helpers.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, collision helpers, rendering rules, overlays, metadata, and traversal semantics, and this module keeps those concerns together.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Collision and sweep-style queries are a major practical feature. A tile world should be directly searchable for blocked cells, traversable neighbors, hits, ranges, or occupancy questions without escalating every problem into full rigid-body simulation.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers extend the feature from geometry into gameplay space by letting designers describe areas, triggers, provinces, and semantic regions layered over the same map.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: pathfinding needs traversability, render needs projection, and gameplay logic needs regions, triggers, or occupancy.
- It also gives projects a stable place to express tile metadata, adjacency, and region semantics without scattering that meaning across several helper layers.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful not only for drawing terrain, but also for organizing the world model that several other modules stand on.
- The feature therefore serves as both storage and interpretation: it does not merely hold tile IDs, it defines what tile-space means well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `physics`, `raycaster`, and `render` all consume tile-space in specialized ways, but `tilemap` owns what the grid world fundamentally is.
- Read `tilemap` as the engine's main authority for tile space and tile-world structure.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `tilemap` owns map storage, layers, chunks, tile ids, orientation/projection metadata, imports/exports, draw helpers, and tile-coordinate utilities.
- Tile gameplay semantics such as movement blockers, vision/action blockers, and tile-light blockers belong in `tilefield` when a project needs one shared source of truth.
- `lurek.tilefield.fromTileMap(tilemap, opts)` copies tilemap state into a field snapshot. Later tilemap edits are not automatically synchronized unless the adapter is called again.
- Existing `tilemap:toNavGrid()` and `pathfind.newNavGridFromTileMap()` stay as compatibility/convenience flows for direct navigation grids.
- `lurek.tilemap.newTileMap(...)` and `lurek.tilemap.newChunkMap(...)` accept an optional limits table with ceilings such as `maxLayers`, `maxTiles`, `maxImagePixels`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, and `maxCollisionTileChecks`.
- `lurek.tilemap.loadTMX(xml, opts)` supports strict/bounded import policy through `strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`, and the same byte/size limits used by safe constructors.
- `LTileMap:worldToTile(...)` preserves legacy clamping semantics, while `LTileMap:tryWorldToTile(...)` returns `nil` for negative or non-finite world coordinates and should be preferred for picking/collision front-ends.
- `LTileMap:rectOverlapsSolid(...)` and `LTileMap:sweepRect(...)` validate finite coordinates, positive rectangle size, and tile-check budgets before scanning the map.
- Reverse tile-position indexing is lazy after large writes such as `fill(...)`; callers that need dense reverse lookups should use `tileTypeIndex(...)` or `findTilesByGid(...)` and can inspect `getDiagnostics().lazyIndexRebuilds`.
- Diagnostics counters are part of the public debugging contract: invalid layer access, invalid coordinates, invalid collision queries, unknown gids, and lazy reverse-index rebuilds are observable through `LTileMap:getDiagnostics()`.

## Architecture Links

- Intentionally empty.
