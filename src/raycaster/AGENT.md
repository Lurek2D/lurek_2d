# `raycaster` — Agent Reference

| Property       | Value                                                |
|----------------|------------------------------------------------------|
| **Tier**       | Tier 2 — Engine Extensions                           |
| **Status**     | Implemented — Full                                   |
| **Lua API**    | `lurek.raycaster`                                     |
| **Source**      | `src/raycaster/`                                     |
| **Rust Tests** | `tests/rust/unit/raycaster_tests.rs`                 |
| **Lua Tests**  | `tests/lua/unit/test_raycaster.lua`                  |
| **Architecture** | —                                                  |

## Purpose

The `raycaster` module implements a DDA-based 2D grid raycaster designed for Wolfenstein-style retro FPS and dungeon-crawler games. It operates on a flat integer cell grid (`Raycaster2D`) and produces results as either plain numeric column data **or** as a complete `RaycasterScene` of textured quads with per-polygon lighting — suitable for dungeon-crawler style rendering where each surface (wall, floor, ceiling, sprite) is a full textured quad, not a column strip.

The module provides two rendering paths:
1. **Column-strip** (`ColumnBatch` / `ColumnData`) — classic Wolfenstein-style per-column rendering via `lurek.gfx` draw calls.
2. **Textured-quad** (`RaycasterScene` / `WallQuad` / `FloorQuad` / `CeilingQuad` / `BillboardSprite`) — dungeon-crawler style rendering where each surface is a perspective-correct textured quad with per-polygon `light` RGBA tint. Built by `RaycasterScene::build()` and converted to `Vec<RenderCommand>` by `generate_render_commands()`.

## Source Files

| File                     | Purpose                                                        |
|--------------------------|----------------------------------------------------------------|
| `mod.rs`                 | Module root; re-exports all public types and functions          |
| `dda.rs`                 | `Raycaster2D` grid struct and DDA traversal algorithms         |
| `ray_hit.rs`             | `RayHit` result struct returned per cast column                |
| `segment.rs`             | `Segment` line type and `cast_ray_2d` geometry raycaster       |
| `visibility.rs`          | `field_of_view` — visibility polygon via endpoint raycasting   |
| `projection.rs`          | `project_column` column geometry and `distance_shade` falloff  |
| `sprite_projection.rs`   | `SpriteProjection` billboard transform for screen-space sprites|
| `column_batch.rs`        | `ColumnBatch` / `ColumnData` — per-column wall rendering state |
| `depth_buffer.rs`        | `DepthBuffer` — 1D per-column depth for sprite occlusion       |
| `doors.rs`               | `Door`, `DoorManager`, `DoorDirection`, `DoorState` — sliding door animation |
| `heightmap.rs`           | `HeightMap` — per-cell variable floor and ceiling heights      |
| `lighting.rs`            | `PointLight`, `compute_lighting`, `apply_lit_shade`            |
| `minimap_overlay.rs`     | `extract_minimap` (RGBA crop) and `draw_player_arrow`          |
| `scene.rs`               | `RaycasterScene`, `WallQuad`, `FloorQuad`, `CeilingQuad`, `BillboardSprite` — textured-quad scene types with per-polygon `light: [f32; 4]` RGBA tint and `corners: [Vec2; 4]` / `uvs: [Vec2; 4]` |
| `build_scene.rs`         | `RaycasterScene::build()`, `SceneBuildParams`, `WorldSprite` — builds a complete scene from a `Raycaster2D` grid with per-polygon lighting |
| `render.rs`              | `generate_render_commands()` on `RaycasterScene` — converts the scene into `Vec<RenderCommand>` (DrawTexturedQuad per textured quad; SetColor + Rectangle for untextured fallbacks) |
| `draw.rs`                | `draw_to_image()` on `RaycasterScene` — CPU software-rendering fallback; produces an `ImageData` for headless testing |

## Key Types

| Type | Description |
|------|-------------|
| `Raycaster2D` | DDA grid raycaster — cast_rays, set_cell, get_cell. |
| `RayHit` | Per-ray hit result: distance, hit position, tex_u, cell_value. |
| `ColumnBatch` | Column-strip rendering batch (legacy path). |
| `ColumnData` | Per-column wall rendering state (legacy path). |
| `RaycasterScene` | Complete textured-quad scene: walls, floors, ceilings, sprites. |
| `WallQuad` | Single wall segment as a perspective-correct textured quad with `corners`, `uvs`, and per-polygon `light` RGBA. |
| `FloorQuad` | Single floor tile as a textured quad with `corners`, `uvs`, and per-polygon `light` RGBA. |
| `CeilingQuad` | Single ceiling tile as a textured quad with `corners`, `uvs`, and per-polygon `light` RGBA. |
| `BillboardSprite` | World-space sprite projected as a camera-facing textured quad with `corners`, `uvs`, and per-polygon `light` RGBA. |
| `SceneBuildParams` | Camera, lighting, and rendering parameters for scene building. |
| `WorldSprite` | Input sprite definition (world position, texture, size). |
| `PointLight` | Point light source for per-polygon lighting calculation. |
| `DepthBuffer` | 1D per-column depth buffer for sprite occlusion. |
| `Door` / `DoorManager` | Sliding door animation and management. |
| `HeightMap` | Per-cell variable floor and ceiling heights. |
| `Segment` | Line segment with ray intersection testing. |

## Lua API Summary

| Function | Description |
|----------|-------------|
| `lurek.raycaster.new()` | See `docs/specs/raycaster.md`. |
| `lurek.raycaster.projectColumn()` | See `docs/specs/raycaster.md`. |
| `lurek.raycaster.distanceShade()` | See `docs/specs/raycaster.md`. |

## Full Specification

All architecture diagrams, detailed type documentation, Lua API reference, examples, and cross-module references live in the consolidated spec:

→ [`docs/specs/raycaster.md`](../../docs/specs/raycaster.md)

_Update both this file **and** `docs/specs/raycaster.md` whenever source files, public types, or Lua bindings change._
