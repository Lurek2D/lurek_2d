# IDEA.md — `tilemap` module

> Migrated from `ideas/features/tilemap.md` + `ideas/performance/07-tilemap-large-world.md`.
> Status checked against `src/tilemap/` and `src/lua_api/tilemap_api.rs`.
> Lua namespace: `lurek.tilemap`.

---

## Features

### ✅ DONE — Grid Tilemap with Named Layers
**Source**: features/tilemap.md — Summary

`lurek.tilemap.new(w, h, tileSize)` — 2D grid with multiple named layers.

---

### ✅ DONE — Auto-Tile (4-bit and 8-bit Blob Bitmask)
**Source**: features/tilemap.md — Summary

Both 4-bit and 8-bit (blob) auto-tiling with bitmask matching implemented.

---

### ✅ DONE — Frustum Culling (Draw Visible Tiles Only)
**Source**: features/tilemap.md — Summary

Only visible tiles tessellated per frame.

---

### ✅ DONE — Pathfinding Bridge (`toNavGrid`)
**Source**: features/tilemap.md — Feature Gaps #8 (IMPLEMENTED)

`tilemap:toNavGrid(layer, gids)` at `tilemap_api.rs:770` — converts tile layer to
`NavGrid` for pathfinding module. Feature gap listed as TODO in analysis was already done.

---

### ✅ DONE — Isometric Coordinate Helpers
**Source**: features/tilemap.md — Feature Gaps #3 (IMPLEMENTED)

`toScreenIso`, `fromScreenIso` at `tilemap_api.rs:1206+` — diamond isometric projection
for both tile→screen and screen→tile conversions.

---

### ✅ DONE — Hex Coordinate Helpers
**Source**: features/tilemap.md — Feature Gaps #4 (IMPLEMENTED)

`toScreenHex`, `fromScreenHex`, `hexNeighbors`, `hexDistance` at `tilemap_api.rs:1768+` —
pointy-top hexagonal coordinates fully implemented.

---

### ✅ DONE — Tile Properties (Custom Per-Tile Data)
**Source**: features/tilemap.md — Summary

Per-tile custom data (walkable, damage, etc.) supported.

---

### ✅ DONE — Collision Layer Generation
**Source**: features/tilemap.md — Summary

Generate physics colliders from tile data.

---

### ✅ DONE — Tiled TMX / LDtk Import
**Source**: features/tilemap.md — Feature Gaps #1 / Suggestions #1+2

Tiled TMX import: `lurek.tilemap.loadTMX(path)` — registered in `tilemap_api.rs`.
Returns a Lua table with map metadata, tile layer data, object layers, and tile properties.

LDtk import: `lurek.tilemap.fromLDtk(path)` — registered in `tilemap_api.rs`.
Returns a `TileMap` userdata built from the LDtk JSON world format.

---

### ✅ DONE — Infinite / Chunked Map Streaming
**Source**: features/tilemap.md — Feature Gaps #2

`lurek.tilemap.newChunkMap(chunkW, chunkH, tileSize)` — registered in `tilemap_api.rs`.
`LuaChunkMap` userdata: `setChunk`, `getChunk`, `getChunksInView`, and neighbouring helpers.
Chunks are loaded lazily; only visible chunks are processed each frame.

---

### ✅ DONE — Tile Entity Spawners / Trigger Callbacks
**Source**: features/tilemap.md — Feature Gaps #7 / Suggestions #7

`tilemap:onTileEnter(tileId, fn)` registered in `tilemap_api.rs`.
`tilemap:checkEntities(entities)` processes entity positions against registered callbacks.

---

### ✅ DONE — Per-Layer Parallax Scroll Factor
**Source**: features/tilemap.md — Feature Gaps #6

`tilemap:setLayerParallax(layer, factorX, factorY)` and `tilemap:getLayerParallax(layer)`
registered in `tilemap_api.rs`. Each layer has an independent parallax factor.

---

### ✅ CLOSED — Cellular Automata Duplication with `procgen`
**Source**: features/tilemap.md — Structural Issues

Audit of `src/tilemap/mapgen.rs` found no actual Rust-level duplicate of the `procgen`
cellular automata implementation. The cellular helper in `mapgen.rs` is a separate,
tilemap-specific variant applied directly to the tile grid. No code removal needed.

---

## Performance

### ✅ DONE — Chunk-Level Occlusion Culling for Large Worlds
**Source**: performance/07-tilemap-large-world.md

`lurek.tilemap.newLargeMapRenderer(tileW, tileH)` — registered in `tilemap_api.rs`.
`LuaLargeMapRenderer` userdata: `setMapData`, `setTile`, `getTile`, `setCamera`,
`setViewport`, `getVisibleChunks`, `getTotalChunks`, `setChunkSize`, `setLodEnabled`,
`setLodThresholds`, `setTilesetColumns`, `invalidateChunk`, `invalidateAll`.
Backed by `src/tilemap/large_map_renderer.rs`.
