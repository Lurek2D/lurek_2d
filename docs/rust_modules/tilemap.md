# tilemap

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilemap/`
- Binding: `src/lua_api/tilemap_api.rs`
- Namespace: `lurek.tilemap`
- Lua API surface: `28` functions, `22` types, `162` methods
- Rust test path(s): tests/rust/unit/tilemap_tests.rs
- Lua test path(s): tests/lua/unit/test_tilemap_core_unit.lua, tests/lua/stress/test_tilemap_stress.lua, tests/lua/integration/test_tilemap_physics.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_tilemap_camera.lua, tests/lua/integration/test_save_tilemap.lua, tests/lua/integration/test_procgen_tilemap.lua, tests/lua/golden/test_tilemap_golden.lua, tests/lua/evidence/test_evidence_tilemap.lua

## Summary

This module serves as the primary system for building, simulating, and visualizing rich, grid-based game worlds. It unifies orthogonal, isometric, and hexagonal structures under a single set of spatial operations, enabling developers to map virtual grid coordinates directly into screen-space projections. The system manages conversions, diamond layout ordering, diagonal sorting, and hexadecimal neighborhood navigations for gameplay logic.

For massive sandbox and role-playing worlds, the module employs sparse chunk-based storage to handle vast environments without overwhelming memory allocations. This representation connects to a chunk-oriented rendering engine that groups layers and tiles into blocks for camera-aware view culling. Viewport-scoped culling keeps frame rates high, while dirty-chunk tracking guarantees that modified tiles update immediately.

To accommodate mainstream workflows, the tilemap engine supports direct imports from industry-standard editor formats. It parses XML-based Tiled files and LDtk JSON documents on the fly, decoding base64-compressed layers and preserving custom properties. The importer strips auxiliary packaging flags to isolate native cell identities, reconstructing layers, object entities, and visual settings into engine-native structures.

In addition to hand-crafted environments, the subsystem provides a procedural generation pipeline built on repeatable seed values. By combining reusable block templates with procedural scripts, developers can orchestrate operations like flood fills, path carving, and noise scattering. Seed-driven randomness guarantees identical world outputs across runs, making procedural layouts stable and testable.

Terrain continuity is managed dynamically via an autotiling system that checks tile neighborhoods to select matching sprites automatically. Supporting both four-neighbor and eight-neighbor diagonal rules, this system maps structural bitmasks directly to tileset transitions. Developers can paint paths, organic borders, and water flows, letting the runtime patch corner seams and transition quads smoothly.

Beyond visual representation, the tilemap forms the bedrock of spatial collision detection and pathfinding. Individual tiles convey solidity properties that feed swept bounding-box tests, giving platformers and top-down entities collision responses. The system also exports raw layers into navigation grids, making it simple for pathfinding algorithms to query obstacle placements and plan routes.

Finally, the module provides specialized spatial tools for tactical strategy games, including hex ring traversals, spiral patterns, and line-of-sight traversals. Hexagonal maps now travel through the same render-command path as other orientations, so hex coordinate helpers and tilemap drawing stay aligned. It also manages arbitrary polygon regions layered on top of the grid to define zone semantics, ownership areas, and visual outlines. These regions support selection testing and compute bounds to coordinate dynamic camera positioning and trigger regions.

Interactive elements are rounded out by event-driven callbacks triggered as entities step across tile boundaries. These hooks notify gameplay scripts during entries and exits, facilitating pressure plates, hazards, and portals. Supported by coordinate interpolations for smooth movement ticks, this complete framework bridges static world data with reactive, dynamic gameplay simulation.

Internal layout note: the module surface is now split more explicitly by concern. Procedural-generation model types live in `mapgen_model.rs`, collision helpers in `tilemap_collision.rs`, and reverse-index maintenance in `tilemap_index.rs`, while the public `tilemap` API remains unchanged.

Animation update note: animated tile advancement is now tied to visible GIDs and viewport invalidation state, so on-screen animated cells refresh through the dirty/visible path without disturbing the active viewport configuration.

## Files

### [autotile_sheet.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/autotile_sheet.rs)

- This file provides the autotile sheet model that turns neighborhood context into final tile picks.
- It keeps multiple atlas layouts coherent so different terrain styles share one usage contract.
- It centralizes bitmask interpretation and rule matching in a single graphics selection layer.
- It resolves corner relationships carefully so terrain seams stay clean across transitions.
- It supports quarter-tile composition when rendering needs sub-tile assembly for smooth blends.
- It connects sheet logic to tileset data so runtime autotiling remains deterministic.
- It forms a stable foundation for roads, biomes, and organic borders in grid-based worlds.

### [chunk.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/chunk.rs)

- This file provides sparse chunk storage for very large tile worlds that load data on demand.
- It decouples tile access from raw memory layout so map scale can grow without full allocation.
- It keeps world-to-chunk and local cell transforms precise for predictable addressing.
- It exposes range operations and visible-chunk selection to drive rendering and streaming paths.
- It stabilizes spatial boundaries so culling and update logic stay consistent under scale.

### [coords.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/coords.rs)

- This file provides coordinate transforms for isometric and hex grids used across map systems.
- It keeps one geometric language between screen space, tile space, and movement direction logic.
- It offers orientation, rotation, and side classification helpers for grid navigation flows.
- It supports hex metrics and neighborhoods so pathing and range tools share a stable base.
- It delivers line, ring, and spiral traversals for tactical gameplay and map UI overlays.

### [isomap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/isomap.rs)

- This file provides a multi-level isometric map model with separate parts per tile cell.
- It maps tile coordinates to diamond-projected screen space for coherent scene placement.
- It iterates draw order by diagonal progression so elevation layering reads correctly.
- It lets each elevation level be shown or hidden to support staged world presentation.
- It keeps part ordering configurable so floor, wall, and object composition remains flexible.
- It supports both bulk writes and precise per-slot updates for runtime editing workflows.
- It anchors isometric world structure in a form that is predictable for rendering and tools.

### [large_map_renderer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/large_map_renderer.rs)

- This file provides chunk-oriented rendering support for tilemaps that exceed single-pass scale.
- It partitions the full grid into fixed blocks with dirty tracking for incremental refresh.
- It uses camera and viewport state to cull work at chunk granularity before draw emission.
- It supports per-tile mutation with automatic invalidation so updates stay localized.
- It applies optional zoom-aware detail reduction to keep large-world rendering responsive.
- It preserves tileset atlas geometry inputs needed by backend UV mapping logic.

### [ldtk.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/ldtk.rs)

- This file provides LDtk JSON import into the engine-native tilemap representation.
- It parses levels and tile layers while rebuilding tileset geometry needed by runtime maps.
- It converts pixel-based LDtk placements into stable grid-cell coordinates for simulation.
- It keeps external level content aligned with the engine's layered tile data model.
- It enables deterministic content ingestion from LDtk authoring workflows.

### [mapgen.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/mapgen.rs)

- This file provides scripted procedural generation for tile worlds built from reusable block pieces.
- It models block edges and matching rules so assembled regions connect with coherent boundaries.
- It groups reusable content and scripts into named generation palettes for targeted world styles.
- It defines step-driven operations for fill, placement, scatter, flood spread, and path carving.
- It orchestrates generation with seeded randomness so outputs are repeatable and testable.
- It supports both single-map and multi-region production with independent deterministic seeds.
- It applies zone and orientation metadata so generated content matches downstream render expectations.
- It controls how layers receive writes, enabling unified or split composition strategies.
- It gives runtime and tools one procedural contract that scales from prototypes to full maps.
- It keeps generation intent explicit so scripts remain readable and maintainable over time.
- It enables data-driven map variety without requiring hand-authored full layouts for every scene.
- It anchors procedural authoring in predictable structures that can be debugged and replayed.

### [mapgen_model.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/mapgen_model.rs)

- This file holds shared procedural-generation model types extracted from `mapgen.rs` so generation data structures can evolve without keeping every concern in one source file.
- It keeps orientation, zone, edge, and script-shape metadata reusable across generator logic and callers.
- The split is structural only; the public map-generation contract stays under `lurek.tilemap`.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/mod.rs)

- This module delivers the high-level tile world stack for storage, generation, import, and rendering.
- It unifies layered map data for orthogonal and isometric play spaces under one runtime contract.
- It connects authored formats, procedural tools, autotiling, and region geometry into one pipeline.
- It provides the structural backbone for large interactive 2D worlds in Lurek2D.

### [polygon_map.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/polygon_map.rs)

- This file provides named polygon regions for zone semantics layered over tile-based worlds.
- It supports convex and concave shapes with fill styling and optional in-region text labels.
- It answers point-in-region queries for selection, triggers, and gameplay ownership checks.
- It maintains shared outline and highlight styling to keep region feedback visually consistent.
- It includes region lifecycle operations so zones can be created, updated, and removed at runtime.
- It computes bounds and centroids to support layout decisions, framing, and camera behaviors.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/render.rs)

- This file provides tilemap render-command emission with camera-aware culling across map layers.
- It maps tile IDs to debug colors so rendering can proceed even without atlas texture sampling.
- It applies per-layer visibility and tint state when composing command output for the renderer.
- It respects orthogonal, isometric, and hexagonal map orientation so debug rendering matches the map's coordinate system.
- It keeps draw generation predictable so map visualization remains stable during updates.
- It provides a stable debug visualization path when textured rendering is unavailable.

### [tile_walker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tile_walker.rs)

- This file provides a discrete grid walker model with stable cardinal facing semantics.
- It supports forward, backward, and strafe movement as first-class motion primitives.
- It tracks previous state snapshots so interpolation can smooth visual motion between ticks.
- It classifies neighboring cells relative to facing for directional interaction logic.
- It separates passability queries from concrete collision backends for flexible integration.
- It keeps movement intent readable for gameplay, AI steering, and tactical controls.

### [tilemap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tilemap.rs)

- This file provides the core layered tilemap data model used by simulation and rendering paths.
- It stores per-cell tile IDs, per-layer state, tint metadata, and parallax movement factors.
- It resolves global IDs through attached tilesets so tile ownership stays deterministic.
- It computes autotile neighborhood masks and substitution outputs for terrain continuity.
- It performs swept collision checks against solid tiles for top-down and platform movement.
- It advances tile animation timelines from tileset frame data during runtime updates.
- It converts world and tile coordinates in both directions using map geometry settings.
- It emits culled draw commands for viewport-scoped visualization and debug rendering.
- It tracks visible animated GIDs and dirty viewport state so animated tiles update only where the current view requires it.
- It exports walkability structures so pathfinding systems can consume map topology directly.
- It maintains reverse lookup caches from tile IDs to positions for fast spatial queries.
- It supports image-based debug outputs for inspection, tooling, and regression validation.
- It anchors gameplay-critical map behavior in one consistent and testable runtime surface.

### [tilemap_collision.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tilemap_collision.rs)

- This file contains tilemap collision helpers extracted from `tilemap.rs` so sweep and overlap math can stay isolated from storage concerns.
- It keeps the tile-grid collision query path explicit without changing the public `TileMap` collision surface.

### [tilemap_index.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tilemap_index.rs)

- This file contains reverse-index cache helpers extracted from `tilemap.rs`.
- It centralizes GID-to-position cache maintenance so lookup performance stays predictable while the core map type remains easier to navigate.

### [tileset.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tileset.rs)

- This file provides tileset geometry and metadata that define how tile IDs map to atlas pixels.
- It computes source rectangles from local IDs so render code can sample the correct sprite area.
- It stores solidity metadata per tile to support collision and gameplay filtering decisions.
- It tracks frame-based tile animations so animated map cells advance with deterministic timing.
- It holds autotile rule tables that translate neighborhood masks into terrain transition IDs.

### [tmx.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/tilemap/tmx.rs)

- This file provides TMX import that converts Tiled XML maps into engine-native map structures.
- It supports major TMX orientation modes so authored content can target varied 2D projections.
- It decodes tile data from csv, xml, and compressed base64 payloads into stable gid streams.
- It ingests tileset geometry and metadata needed for atlas lookup and collision interpretation.
- It parses object layers to retain placement, sizing, and semantic type annotations.
- It strips flip flags from raw gids so stored tile identity stays clean and comparable.
- It infers solid tiles from embedded markers and custom properties used by authoring tools.
- It reports parse failures with contextual messages to speed debugging of malformed assets.
- It reads TMX color encodings so visual defaults are preserved during map import.
- It delivers a predictable bridge between external level authoring and runtime world assembly.
