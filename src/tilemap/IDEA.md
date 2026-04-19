# IDEA — `src/tilemap/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.
>
> See [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md) for filling instructions.

---

## 1. Header

- **Module**: `tilemap`
- **Owner module path**: `src/tilemap/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~7877 · **Public Lua surface**: `lurek.tilemap` — ~80 fns / 6 userdata (TileMap, TileSet, IsoMap, ChunkMap, TileWalker, PolygonMap)
- **Inbound non-`lua_api` callers**: `src/engine/app.rs`
- **Heavy dependencies**: none (pure Rust + engine math)

## 2. Mission Summary

The tilemap module provides 2D tile-based map systems: orthogonal tilemaps, isometric maps,
chunked infinite maps, procedural generation, TMX/LDtk import, autotiling, polygon regions,
and grid-based movement. It serves GameDev (Lua tilemap construction and rendering), Modder
(custom map generators), and EngDev (rendering pipeline integration). It is NOT a voxel engine
and does NOT handle 3D terrain.

## 3. Existing Strengths

- Full orthogonal tilemap with multi-layer support, per-tile metadata, animated tiles, and collision queries (sweep, overlap, raycast).
- Isometric rendering with multi-level painter's algorithm and tile stacking (`IsoMap`).
- Chunked map storage (`ChunkMap`) enabling infinite/large maps with sparse allocation.
- TMX (Tiled) and LDtk importers for industry-standard level editor interop.
- Comprehensive procedural generation (`MapGen`) with block/group/script composition, BSP rooms, cellular caves, and maze algorithms.
- Autotile system (`AutoTileSheet`) with 47-tile bitmask lookup and neighbor-aware placement.
- Pure-function coordinate conversions (`coords.rs`) for iso, hex grids with full hex math (ring, spiral, area, rotate, reflect, line).
- Grid movement controller (`TileWalker`) with smooth interpolation, facing, and collision.

## 4. Gap List

1. **[P1][GAP]** `Hex tilemap rendering` — hex coordinate math exists in `coords.rs` but there is no `HexMap` struct analogous to `IsoMap`.
   - Why: hex-grid games (strategy, RPG) must manually compute tile positions; no integrated hex renderer.
2. **[P1][GAP]** `Tile property queries by type` — no fast lookup of "all tiles of type X" across layers.
   - Why: gameplay logic (e.g. "find all water tiles") requires O(W×H) scan per query.
3. **[P2][GAP]** `Animated tile performance` — `TileMap::update_animations` iterates all tiles every frame.
   - Why: large maps with many animated tiles cause CPU spikes.
4. **[P2][GAP]** `TMX/LDtk error reporting` — parser errors are logged but not returned to Lua.
   - Why: GameDev cannot distinguish "file not found" from "corrupt format" in script.
5. **[P3][GAP]** `Tilemap undo/redo` — no built-in command history for tile edits.
   - Why: level-editor-in-game patterns need manual undo stacks.

## 5. Feature Ideas

1. **[P1][FEAT]** `HexMap renderer` — add `HexMap` struct wrapping hex grid data + pointy-top rendering using existing `coords.rs` math, with layer support and culling.
   - Rationale: hex games are a major genre; coordinate math is already implemented (GameDev persona).
   - Effort: M · Risk: low.
2. **[P1][FEAT]** `Tile type index` — maintain a per-layer `HashMap<u32, Vec<(u32,u32)>>` for O(1) type lookups, updated on `set_tile`.
   - Rationale: enables fast spatial queries for gameplay logic.
   - Effort: S · Risk: low.
3. **[P2][FEAT]** `Dirty-rect animated tile update` — only iterate tiles in the visible viewport + a margin for animated tile updates.
   - Rationale: reduces CPU cost for large maps with sparse animations.
   - Effort: S · Risk: low.
4. **[P2][FEAT]** `Structured import errors` — return `Result<TileMap, TileMapError>` from TMX/LDtk parsers with typed error variants.
   - Rationale: Lua scripts can match on error type and show user-friendly messages.
   - Effort: S · Risk: low.
5. **[P3][FEAT]** `Wang tile support` — extend `AutoTileSheet` with Wang tile (corner/edge) matching for smoother terrain transitions.
   - Rationale: higher-quality autotiling for natural terrains.
   - Effort: M · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P1][PERF]** `Viewport culling in TileMap::render` — skip tiles outside the camera viewport entirely during render command generation.
  - Hot path: `render.rs` tile iteration loop.
  - Verification: frame-time comparison on 256×256 map.
- **[P2][QUAL]** `Split mapgen.rs` — at ~1440 lines, `mapgen.rs` is large. Extract BSP, cellular, and maze generators into separate files.
  - File: `src/tilemap/mapgen.rs`.
  - Reason: readability, independent iteration.
- **[P2][QUAL]** `Split tilemap.rs` — at ~1370 lines, `tilemap.rs` mixes storage, queries, and animation. Extract collision queries into `tilemap_queries.rs`.
  - File: `src/tilemap/tilemap.rs`.
  - Reason: separation of concerns.
- **[P2][REL]** `Bounds-check TMX layer data` — TMX parser trusts layer dimensions match tile count; mismatch causes panic.
  - Files: `tmx.rs`.
  - Suggested fix: validate and return `TileMapError` instead of indexing.

## 7. Test Coverage Gaps

- **[FIXED]** `tilemap_tests.rs` and `mapgen_tests.rs` were NOT wired in `mod.rs` — 35 tests were orphaned. Fixed by adding `#[cfg(test)] mod tilemap_tests;` and `#[cfg(test)] mod mapgen_tests;` to `mod.rs`.
- **[P1][TEST-LUA]** Add Lua BDD tests for `lurek.tilemap.newMap`, `setTile`/`getTile`, layer management, collision queries.
- **[P1][TEST-LUA]** Add Lua tests for `lurek.tilemap.newIsoMap` with multi-level stacking.
- **[P2][TEST-RUST]** Add Rust tests for TMX parser with malformed XML input (error paths).
- **[P2][TEST-RUST]** Add Rust tests for LDtk parser with missing fields.
- **[P2][TEST-LUA]** Add Lua tests for `MapGen` procedural generation determinism (seed-based).
- **[P3][TEST-FUZZ]** Fuzz target: `tmx::load_tmx` with random XML input.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): render::RenderCommand — tilemap/render.rs and large_map_renderer.rs both build RenderCommands; shared tile-render trait candidate
TODO(dedup): math::Vec2 — coords.rs returns custom (f32,f32) tuples instead of Vec2 in several places
TODO(dedup): physics::collision_helpers — tilemap collision sweep reimplements AABB overlap checks
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): camera_follow_walker — TileWalker + camera centering pattern repeated in RPG demos — citation: content/library/rpg/init.lua
TODO(helper): tilemap_minimap — render downscaled tilemap to image for minimap HUD — citation: content/examples/tilemap.lua
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — tilemap is central to 2D games; used by majority of demos; no heavy external deps to extract
```

- **Extraction blockers**: `runtime::shared_state` pool entry for TileMap, inbound imports from `app.rs`.
- **Heavy dep impact if extracted**: none (pure Rust); no binary savings.
- **Lua surface stability**: evolving.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/tilemap.md](../../docs/specs/tilemap.md)
- Lua API reference: [docs/API/lua-api.md#tilemap](../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D only), `B-03` (60 FPS target)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md) · Session decisions: [DECISIONS.md](../../work/src-module-review-20260418/reports/DECISIONS.md)
