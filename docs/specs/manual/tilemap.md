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
- `lurek.tilemap.newTileMap(...)` and `lurek.tilemap.newChunkMap(...)` accept an optional limits table with ceilings such as `maxLayers`, `maxTiles`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, and `maxTileOperationCells`.
- `lurek.tilemap.loadTMX(xml, opts)` supports strict/bounded import policy through `strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`, and the same byte/size limits used by safe constructors.
- `LTileMap:worldToTile(...)` preserves legacy clamping semantics, while `LTileMap:tryWorldToTile(...)` returns `nil` for negative or non-finite world coordinates and should be preferred for picking front-ends.
- Reverse tile-position indexing is lazy after large writes such as `fill(...)`; callers that need dense reverse lookups should use `tileTypeIndex(...)` or `findTilesByGid(...)` and can inspect `getDiagnostics().lazyIndexRebuilds`.
- Diagnostics counters are part of the public debugging contract: invalid layer access, invalid coordinates, invalid coordinate queries, unknown gids, and lazy reverse-index rebuilds are observable through `LTileMap:getDiagnostics()`.

## Architecture Links

- Intentionally empty.
