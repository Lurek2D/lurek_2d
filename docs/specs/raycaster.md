# raycaster

## TL;DR

- The `raycaster` module is a powerful Feature Systems tier component that provides a complete Wolfenstein-style 2D grid raycasting engine for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/raycaster/`
- Lua API path(s): `src/lua_api/raycaster_api.rs`
- Primary Lua namespace: `lurek.raycaster`
- Rust test path(s): tests/rust/unit/raycaster_tests.rs
- Lua test path(s): tests/lua/unit/test_raycaster_core_unit.lua, tests/lua/evidence/test_raycaster_evidence.lua

## Summary

It projects a grid-based 2D map into a textured, first-person 3D perspective using Digital Differential Analyzer (DDA) ray-stepping. At the core is the `Raycaster2D` struct, which maintains the tile grid. Each cell in the grid can be assigned per-face wall textures (North, South, East, West), floor/ceiling textures, alpha transparency overrides, and unique height modifiers via the `HeightMap` system (allowing for variable-height floors, ceilings, and lowered pits). The DDA stepper casts rays for each screen column, applies perpendicular distance corrections (to fix "fish-eye" distortion), and emits texture-sampled wall slices.

The rendering pipeline is robust and feature-rich. Floor and ceiling rendering utilizes perspective-correct per-pixel texture mapping with per-tile UV generation and lighting calculations. Transparent and semi-transparent walls are natively supported via multi-hit ray casting (`cast_ray_multi`), which penetrates transparent tiles until an opaque wall is hit. The module also features a fully animated sliding door system (`DoorManager`), and a `SpriteManager` that projects world-space billboard sprites (such as enemies or items) into the camera view. Sprites are correctly distance-sorted and depth-culled against a per-column `DepthBuffer` populated during the wall-casting phase. Furthermore, dynamic 3D OBJ models can be projected into the scene alongside flat sprites.

Lighting and visibility are deeply integrated into the raycaster. It supports a point-light model with Bresenham line-of-sight occlusion, distance-based shading (fog/darkness attenuation), and FOV-aware visibility polygon generation. A comprehensive suite of software-rendered visualization helpers is also included, allowing developers to draw top-down grid maps, minimap overlays, depth maps, line-of-sight rays, and even first-person sweeps directly into `ImageData` buffers for debugging or UI overlays. The scene builder synthesizes all these elements—walls, floors, ceilings, doors, sprites, and models—into a GPU-ready `RaycasterScene` composed of textured quads, which is then handed off to the main renderer. The entire engine is fully scriptable via the `lurek.raycaster.*` Lua API.

## Source Documentation

### `build_scene.rs`
- Build a complete `RaycasterScene` each frame from camera parameters, a DDA grid, and texture lookups.
- Project floor and ceiling tiles as perspective-correct quads with per-tile lighting and UV mapping.
- Generate lowered-floor pit geometry including depth-offset surfaces and side-wall extrusions.
- Emit wall-face quads for every visible solid-cell boundary with roof-side thickness geometry.
- Project billboard sprites to screen space with distance-based sizing and lighting.
- Integrate ambient light, point-light contributions, distance shading, and roofed-ambient darkening.
- Provide camera-space depth projection helpers (`camera_depth`, `project_ground_point`, `project_horizontal_plane`).
- Snap projected coordinates to half-pixel boundaries to reduce sub-pixel jitter on floor/ceiling edges.
- Supply UV-generation utilities for axis-aligned quads and world-space column strips.

### `column_batch.rs`
- Per-column wall-slice projection data produced by the DDA stepper.
- Full-frame column batch holding screen dimensions and flat floor/ceiling colors.
- Bulk update from packed ray data and per-column depth queries.

### `dda.rs`
- 2D grid map and Digital Differential Analyzer (DDA) ray-stepping engine.
- Single-ray casting with perpendicular distance correction and texture-U sampling.
- Multi-hit ray casting through transparent walls up to a configurable depth.
- Fan-cast (cast_rays) with fish-eye correction for full-screen column rendering.
- Flat-packed ray output for efficient Lua-side consumption without per-hit tables.
- Grid-based line-of-sight query using DDA traversal.
- World-to-screen sprite projection with FOV-aware perspective transform.
- Per-pixel floor/ceiling UV generation for textured floor casting.
- Per-tile-type wall alpha overrides enabling transparent and semi-transparent walls.
- Bounds-safe cell access with silent clamping for out-of-range coordinates.

### `depth_buffer.rs`
- Per-column depth storage for raycaster wall hits.
- Used during sprite rendering to cull pixels that fall behind walls.
- Cleared each frame, written during wall-casting, read during sprite-casting.

### `doors.rs`
- Animated sliding doors placed on raycaster grid tiles.
- Per-door state machine: Closed → Opening → Open → Closing → Closed.
- DoorManager registry drives batch updates and spatial lookups.

### `draw.rs`
- Software rasterization of a raycaster scene into an `ImageData` pixel buffer.
- Flat-shaded fills for ceilings, floors, walls, and sprites.
- Back-to-front draw order for correct painter's-algorithm layering.

### `grid_motion.rs`
- Discrete movement actions (forward, backward, strafe) for grid-locked locomotion.
- Direction-to-delta conversion for 4-directional facing (E/S/W/N).
- Collision-checked tile movement with configurable blocking predicate.

### `heightmap.rs`
- Per-tile floor and ceiling height storage for raycaster maps.
- Supports individual tile and rectangular region height assignment.
- Out-of-bounds coordinates are silently ignored or return safe defaults.

### `level_render.rs`
- Raycaster level renderer: wall, floor, ceiling, and sprite column rendering.
- `render_level_columns` is the hot path; called once per screen column per frame.
- `compute_hole_visibility` pre-calculates which cells are visible through openings.
- Texture-mapped floors/ceilings use an affine perspective-corrected UV formula.
- All output goes to an RGBA framebuffer; no wgpu calls are made from this module.
- Performance target: 60 FPS at 320×200 on integrated GPUs; scales to 1080p.

### `lighting.rs`
- Point-light model with position, radius, intensity, and RGB color.
- Bresenham line-of-sight check to block light through walls.
- Per-tile lighting accumulator combining ambient and point-light contributions.

### `mod.rs`
- Grid-based 2D raycaster using DDA ray-stepping and column projection.
- Builds per-frame scenes with wall quads, floor/ceiling, sprites, and doors.
- Supports heightmaps, distance lighting, depth occlusion, and FOV visibility.
- Provides debug visualization helpers.

### `multilevel.rs`
- Multi-level raycaster: stacked horizontal slices for floors, ceilings, and bridges.
- Extends the flat raycaster with per-column level stacks for multi-storey maps.
- Each level slice defines a floor height, ceiling height, and tile layer pair.
- Level transitions (stairs, portals) are handled as special tile types.
- Blends into the base `level_render` pipeline; no separate render pass needed.

### `projection.rs`
- Wall-column projection from ray distance to screen-pixel height and vertical bounds.
- Distance-based shading for depth fog attenuation.
- Returns `(wall_height, draw_start, draw_end)` clamped to valid screen-pixel bounds.

### `ray_hit.rs`
- DDA ray-cast result record holding wall distance, hit coordinates, and texture sampling data.
- Carries both fish-eye-corrected and raw distances for flexible column rendering.
- Provides side, alpha, and cell value for shading and transparency decisions.

### `render.rs`
- Convert a built raycaster scene into GPU-ready render commands.
- Emit textured quads for ceilings, floors, walls, and sprites in correct painter order.
- Fall back to solid-color rectangles when a surface has no texture assigned.

### `scene.rs`
- Scene geometry types emitted by the raycaster build pass and consumed by the renderer.
- Quad primitives for walls, floors, ceilings, billboard sprites, and static meshes.
- `RaycasterScene` collects all quads for one frame with depth and perspective-correct UV data.

### `segment.rs`
- 2D line segment representation for raycaster wall geometry.
- Ray-vs-segment intersection test returning nearest hit point and index.
- Used by the raycaster module to resolve wall hits from arbitrary origins.

### `sprite_manager.rs`
- Billboard sprite registry for the raycaster subsystem.
- Manages creation, removal, positioning, and visibility of world-space sprites.
- Provides distance-sorted iteration for back-to-front rendering.

### `sprite_projection.rs`
- Screen-space sprite projection data for raycaster billboard rendering.
- Stores position, scale, distance, and visibility after camera-plane projection.
- Consumed by the depth-buffer occlusion pass to sort and clip sprites.

### `tile_picker.rs`
- Tile picker: converts a screen (x, y) click into a raycasted map tile coordinate.
- `pick_tile(screen_x, screen_y, camera, map)` returns `Option<(tile_x, tile_y)>`.
- Reverses the column rendering math to find the intersection depth for a pixel.
- Accounts for the player's position and angle at the moment of the pick query.
- Used by `lurek.raycaster.pick(x, y)` to report tile coordinates to Lua scripts.

### `visibility.rs`
- Radial visibility polygon computation from a point source.
- Casts rays at segment-endpoint angles with epsilon jitter for gap-free coverage.
- Returns interleaved coordinate arrays suitable for triangle-fan rendering.

### `visualization.rs`
- Software-rendered raycaster visualization helpers for debugging and demo output.
- Top-down grid map rendering with player position and radial ray overlay.
- First-person column-based wall rendering with distance-based shading.
- Depth-map greyscale visualization where brightness encodes proximity.
- Line-of-sight connectivity check rendered as a coloured line between two points.
- Camera sweep atlas generating a multi-frame rotation sequence into a single image.
- Procedural textured first-person view with brick, stone, wood, metal, and mosaic patterns.
- All outputs produce an `ImageData` bitmap suitable for GPU upload or file export.
- Procedural texture lookup mapping cell type and UV to RGB without external assets.

## Types

- `LoweredFloorCell` (`struct`, `build_scene.rs`): Auto-doc: public item.
- `SceneBuildParams` (`struct`, `build_scene.rs`): Parameters for building a raycaster scene.
- `WorldSprite` (`struct`, `build_scene.rs`): A world-space sprite for scene building.
- `TextureLookup` (`type`, `build_scene.rs`): Texture lookup function type.
- `CellTextureLookup` (`type`, `build_scene.rs`): Per-cell texture lookup function type.
- `ColumnData` (`struct`, `column_batch.rs`): One projected column entry inside a `ColumnBatch`.
- `ColumnBatch` (`struct`, `column_batch.rs`): Column-oriented wall rendering payload for strip-based outputs.
- `Raycaster2D` (`struct`, `dda.rs`): The main DDA grid raycaster over integer world cells. It answers ray hits, multi-ray sweeps, and line-of-sight checks.
- `DepthBuffer` (`struct`, `depth_buffer.rs`): Per-column depth storage used to hide sprites or geometry that should fall behind walls.
- `DoorDirection` (`enum`, `doors.rs`): Describes how a door opens relative to the map grid.
- `DoorState` (`enum`, `doors.rs`): Encodes whether a door is closed, opening, open, or closing.
- `Door` (`struct`, `doors.rs`): One animated door in a raycast map.
- `DoorManager` (`struct`, `doors.rs`): Owns door records and their animation state over time.
- `GridMoveAction` (`enum`, `grid_motion.rs`): Camera-relative movement action for 4-directional movement.
- `HeightMap` (`struct`, `heightmap.rs`): Per-cell floor and ceiling height data for non-flat raycast worlds.
- `TileHighlight` (`struct`, `level_render.rs`): Wireframe highlight configuration for a tile.
- `LevelRenderConfig` (`struct`, `level_render.rs`): Configuration for rendering adjacent levels through holes.
- `PointLight` (`struct`, `lighting.rs`): A point light source used by the optional lighting helpers.
- `RaycasterLevel` (`struct`, `multilevel.rs`): A single level in a multi-level raycaster world.
- `MultiLevelGrid` (`struct`, `multilevel.rs`): Multi-level grid containing stacked raycaster levels.
- `RayHit` (`struct`, `ray_hit.rs`): A single cast result describing hit distance, impacted cell, hit side, texture coordinate, and hit position.
- `WallQuad` (`struct`, `scene.rs`): One textured wall polygon in a built raycaster scene.
- `FloorQuad` (`struct`, `scene.rs`): One projected floor polygon in a built raycaster scene.
- `CeilingQuad` (`struct`, `scene.rs`): One projected ceiling polygon in a built raycaster scene.
- `BillboardSprite` (`struct`, `scene.rs`): A sprite projected into the raycast view that still faces the camera.
- `ModelMesh` (`struct`, `scene.rs`): A projected 3D model instance stored as a screen-space mesh.
- `RaycasterScene` (`struct`, `scene.rs`): A render-ready scene assembled from raycast results, carrying quads for walls, floors, ceilings, and sprites.
- `Segment` (`struct`, `segment.rs`): A line segment for raycasting.
- `WorldSprite` (`struct`, `sprite_manager.rs`): A world-space sprite for scene building.
- `SpriteManager` (`struct`, `sprite_manager.rs`): Manages a collection of [`WorldSprite`] objects with depth-sorted projection.
- `SpriteProjection` (`struct`, `sprite_projection.rs`): Sprite projection result.
- `TilePicker` (`struct`, `tile_picker.rs`): Tile picker that maps screen coordinates to raycaster grid tiles.
- `PickResult` (`struct`, `tile_picker.rs`): Result of a tile pick operation.

## Functions

- `RaycasterScene::build` (`build_scene.rs`): Build a complete `RaycasterScene` from camera params, lights, sprites, and texture lookups.
- `ColumnBatch::new` (`column_batch.rs`): Create a new `ColumnBatch` with `column_count` default columns for the given screen size.
- `ColumnBatch::set_column` (`column_batch.rs`): Write projected wall-slice data to column `col`; silently ignores out-of-range indices.
- `ColumnBatch::get_column` (`column_batch.rs`): Return the `ColumnData` for column `col`, or `None` if `col` is out of range.
- `ColumnBatch::update_from_ray_data` (`column_batch.rs`): Populate columns from a packed float slice produced by the DDA stepper; each ray is 5 floats.
- `ColumnBatch::get_depth_at` (`column_batch.rs`): Return the depth value stored in column `col`, or `None` if out of range.
- `ColumnBatch::get_depth_buffer` (`column_batch.rs`): Collect depth values from all columns into a new `Vec<f32>`.
- `ColumnBatch::set_floor_color` (`column_batch.rs`): Set the flat floor color.
- `ColumnBatch::set_ceiling_color` (`column_batch.rs`): Set the flat ceiling color.
- `ColumnBatch::get_column_count` (`column_batch.rs`): Return the number of columns in this batch.
- `ColumnBatch::get_screen_width` (`column_batch.rs`): Return the render target width this batch was created for.
- `ColumnBatch::get_screen_height` (`column_batch.rs`): Return the render target height this batch was created for.
- `Raycaster2D::new` (`dda.rs`): Create a new empty grid of `width × height` open cells.
- `Raycaster2D::set_cell` (`dda.rs`): Set the value of cell `(x, y)`; silently ignores out-of-bounds coordinates.
- `Raycaster2D::get_cell` (`dda.rs`): Return the value of cell `(x, y)`, or 0 for out-of-bounds coordinates.
- `Raycaster2D::set_cells` (`dda.rs`): Replace the entire cell grid with `data`; no-op if length mismatches.
- `Raycaster2D::is_blocked` (`dda.rs`): Return true when cell `(x, y)` has a non-zero value (solid wall).
- `Raycaster2D::width` (`dda.rs`): Return the map width in tiles.
- `Raycaster2D::height` (`dda.rs`): Return the map height in tiles.
- `Raycaster2D::cells` (`dda.rs`): Return a read-only slice of the raw cell grid.
- `Raycaster2D::set_wall_alpha` (`dda.rs`): Set the alpha for walls of `tile_type`; clamped to 0.0..1.0.
- `Raycaster2D::get_wall_alpha` (`dda.rs`): Return the wall alpha for `tile_type`; defaults to 1.0 if not set.
- `Raycaster2D::cast_ray` (`dda.rs`): Cast a single DDA ray from `(ox, oy)` in direction `angle`; return the first solid hit or `None`.
- `Raycaster2D::cast_ray_multi` (`dda.rs`): Cast a ray and collect up to `max_hits` (≤ 8) consecutive hits, stopping at the first opaque wall.
- `Raycaster2D::cast_rays` (`dda.rs`): Cast `count` rays spread across `fov` from `(ox, oy)`; return one `RayHit` per ray with fish-eye correction.
- `Raycaster2D::cast_rays_flat` (`dda.rs`): Cast `count` rays and pack each hit as 5 floats `[dist, cell, side, tex_u, hit]`.
- `Raycaster2D::line_of_sight` (`dda.rs`): Return true if the straight-line path from `(x1,y1)` to `(x2,y2)` contains no solid cell.
- `Raycaster2D::project_sprite` (`dda.rs`): Project world sprite at `(sx, sy)` onto the screen given player position and orientation; return a `SpriteProjection`.
- `Raycaster2D::cast_floor_row` (`dda.rs`): Return per-pixel `(tex_u, tex_v)` world UV coordinates for every pixel in floor row `row`.
- `DepthBuffer::new` (`depth_buffer.rs`): Create a new depth buffer for `width` screen columns, all initialised to `f32::MAX`.
- `DepthBuffer::clear` (`depth_buffer.rs`): Reset all columns to `f32::MAX` (no wall) ready for the next frame.
- `DepthBuffer::set` (`depth_buffer.rs`): Store wall depth for `column`; silently ignores out-of-range indices.
- `DepthBuffer::get` (`depth_buffer.rs`): Return the stored depth for `column`, or `f32::MAX` if out of range.
- `DepthBuffer::is_visible` (`depth_buffer.rs`): Return true when `depth` is less than the stored depth for `column` (sprite pixel is visible).
- `DepthBuffer::width` (`depth_buffer.rs`): Return the width this buffer was created for.
- `DoorManager::new` (`doors.rs`): Create an empty `DoorManager`.
- `DoorManager::add_door` (`doors.rs`): Register a new closed door at `(x, y)` with the given `direction` and `speed`; return its index handle.
- `DoorManager::open_door` (`doors.rs`): Start opening door `index` if it is Closed or Closing; no-op otherwise.
- `DoorManager::close_door` (`doors.rs`): Start closing door `index` if it is Open or Opening; no-op otherwise.
- `DoorManager::update` (`doors.rs`): Advance all door animations by `dt` seconds.
- `DoorManager::get_door_at` (`doors.rs`): Return the first door at grid tile `(x, y)`, or `None` if none is registered there.
- `DoorManager::doors` (`doors.rs`): Return a slice of all registered doors.
- `RaycasterScene::draw_to_image` (`draw.rs`): Rasterize this scene into a new `ImageData` of `width × height`; draws ceilings, floors, walls, then sprites back-to-front.
- `GridMoveAction::parse` (`grid_motion.rs`): Parse a string token into a `GridMoveAction`; return `None` for unrecognised tokens.
- `dir4_delta` (`grid_motion.rs`): Returns movement delta for direction index `1..4` and action token (`forward/back/left/right`).
- `try_move` (`grid_motion.rs`): Applies a movement delta with bounds and collision checks.
- `HeightMap::new` (`heightmap.rs`): Create a new `HeightMap` with default floor heights 0.0 and ceiling heights 1.0.
- `HeightMap::set_floor` (`heightmap.rs`): Set the floor height for tile `(x, y)`; silently ignores out-of-bounds coordinates.
- `HeightMap::set_ceiling` (`heightmap.rs`): Set the ceiling height for tile `(x, y)`; silently ignores out-of-bounds coordinates.
- `HeightMap::floor_at` (`heightmap.rs`): Return the floor height at tile `(x, y)`, or 0.0 for out-of-bounds coordinates.
- `HeightMap::ceiling_at` (`heightmap.rs`): Return the ceiling height at tile `(x, y)`, or 1.0 for out-of-bounds coordinates.
- `HeightMap::set_floor_rect` (`heightmap.rs`): Set the floor height for all tiles in the rectangle `(x, y, w, h)` to `height`.
- `HeightMap::set_ceiling_rect` (`heightmap.rs`): Set the ceiling height for all tiles in the rectangle `(x, y, w, h)` to `height`.
- `TileHighlight::new` (`level_render.rs`): Create a tile highlight at the given grid coordinates with default yellow color.
- `TileHighlight::with_color` (`level_render.rs`): Set the wireframe border color as an RGBA array.
- `TileHighlight::with_thickness` (`level_render.rs`): Set the wireframe border line thickness in pixels.
- `compute_hole_visibility` (`level_render.rs`): Determines which cells are visible through holes from the current level.
- `compute_lighting` (`lighting.rs`): Computes ambient + point-light illumination at a world position.
- `apply_lit_shade` (`lighting.rs`): Applies lighting to a distance-shaded base brightness.
- `RaycasterLevel::new` (`multilevel.rs`): Create a new level grid of the given dimensions, all cells empty.
- `RaycasterLevel::get_wall` (`multilevel.rs`): Return the wall texture ID at `(x, y)`, returning 1 (solid) for out-of-bounds coordinates.
- `RaycasterLevel::set_wall` (`multilevel.rs`): Set the wall texture ID at `(x, y)`; out-of-bounds writes are silently ignored.
- `RaycasterLevel::is_floor_hole` (`multilevel.rs`): Return `true` if the cell at `(x, y)` is a floor hole (visibility through to the level below).
- `RaycasterLevel::set_floor_hole` (`multilevel.rs`): Set whether the cell at `(x, y)` is a floor hole.
- `RaycasterLevel::is_ceiling_hole` (`multilevel.rs`): Return `true` if the cell at `(x, y)` is a ceiling hole (visibility through to the level above).
- `RaycasterLevel::set_ceiling_hole` (`multilevel.rs`): Set whether the cell at `(x, y)` is a ceiling hole.
- `MultiLevelGrid::new` (`multilevel.rs`): Create a new empty multi-level grid with no levels.
- `MultiLevelGrid::add_level` (`multilevel.rs`): Append a new level to the grid stack.
- `MultiLevelGrid::level_count` (`multilevel.rs`): Return the total number of levels in this grid.
- `MultiLevelGrid::active_level` (`multilevel.rs`): Return the index of the currently active level.
- `MultiLevelGrid::set_active_level` (`multilevel.rs`): Set the active level index; silently ignored if out of range.
- `MultiLevelGrid::get_level` (`multilevel.rs`): Return a shared reference to the level at `idx`, or `None` if out of range.
- `MultiLevelGrid::get_level_mut` (`multilevel.rs`): Return a mutable reference to the level at `idx`, or `None` if out of range.
- `MultiLevelGrid::get_active` (`multilevel.rs`): Return a shared reference to the currently active level, or `None` if the grid is empty.
- `MultiLevelGrid::get_active_mut` (`multilevel.rs`): Return a mutable reference to the currently active level, or `None` if the grid is empty.
- `MultiLevelGrid::can_descend` (`multilevel.rs`): Check if a position connects to the level below via floor hole.
- `MultiLevelGrid::can_ascend` (`multilevel.rs`): Check if a position connects to the level above via ceiling hole.
- `project_column` (`projection.rs`): Projects a wall column distance to screen-space drawing parameters.
- `distance_shade` (`projection.rs`): Distance-based shading.
- `RaycasterScene::generate_render_commands` (`render.rs`): Build a `Vec<RenderCommand>` for the full scene: ceilings, floors, walls, then sprites back-to-front.
- `RaycasterScene::new` (`scene.rs`): Create an empty scene sized to `screen_width` × `screen_height` pixels.
- `RaycasterScene::quad_count` (`scene.rs`): Return the total number of quads, sprites, and models in this scene.
- `RaycasterScene::is_empty` (`scene.rs`): Return true when no geometry has been added to this scene.
- `cast_ray_2d` (`segment.rs`): Casts a ray from (ox, oy) in direction (dx, dy) against a list of segments.
- `SpriteManager::new` (`sprite_manager.rs`): Create an empty `SpriteManager` with ID counter starting at 1.
- `SpriteManager::add` (`sprite_manager.rs`): Register a sprite at `(x, y)` with the given `texture` path and `scale`; return its new ID.
- `SpriteManager::remove` (`sprite_manager.rs`): Remove the sprite with the given `id`; silently does nothing if not found.
- `SpriteManager::set_position` (`sprite_manager.rs`): Move the sprite with `id` to world position `(x, y)`; silently does nothing if not found.
- `SpriteManager::set_visible` (`sprite_manager.rs`): Set the visibility flag for sprite `id`; silently does nothing if not found.
- `SpriteManager::clear` (`sprite_manager.rs`): Remove all sprites from the registry.
- `SpriteManager::sort_by_distance` (`sprite_manager.rs`): Return visible sprites sorted farthest-to-nearest from `(cam_x, cam_y)`.
- `TilePicker::new` (`tile_picker.rs`): Create a `TilePicker` for a grid of the given dimensions and tile size in world units.
- `TilePicker::set_camera` (`tile_picker.rs`): Update camera position and angle.
- `TilePicker::set_screen_size` (`tile_picker.rs`): Set the screen width and height dimensions.
- `TilePicker::pick_tile` (`tile_picker.rs`): Pick a tile from screen coordinates using simplified raycasting.
- `TilePicker::world_to_tile` (`tile_picker.rs`): Get tile coordinates directly from world position.
- `field_of_view` (`visibility.rs`): Computes a visibility polygon by casting rays at segment endpoints.
- `Raycaster2D::draw_top_down_to_image` (`visualization.rs`): Render a top-down grid map with player dot and radial ray lines into an `ImageData`.
- `Raycaster2D::draw_view_to_image` (`visualization.rs`): Render a software first-person view with cell-colour shading into an `ImageData`.
- `Raycaster2D::draw_depth_map_to_image` (`visualization.rs`): Render a depth-map greyscale view where brighter = closer, into an `ImageData`.
- `Raycaster2D::draw_line_of_sight_to_image` (`visualization.rs`): Render a top-down grid with a line-of-sight check between two points into an `ImageData`.
- `Raycaster2D::draw_camera_sweep_to_image` (`visualization.rs`): Render a multi-frame camera rotation sweep as a tiled atlas into an `ImageData`.
- `Raycaster2D::draw_textured_view_to_image` (`visualization.rs`): Render a first-person view with procedural wall textures into an `ImageData`.

## Lua API Reference

- Binding path(s): `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`

### Module Functions
- `lurek.raycaster.new`: Creates a new raycaster map with the given grid dimensions.
- `lurek.raycaster.newMap`: Creates a new raycaster map (alias for `new`).
- `lurek.raycaster.projectColumn`: Computes the projected wall-column height for a given distance, FOV, and screen height.
- `lurek.raycaster.distanceShade`: Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
- `lurek.raycaster.applyLitShade`: Applies an RGB light color to a scalar shade value.
- `lurek.raycaster.newDoorManager`: Creates a new door manager for tracking and animating sliding doors.
- `lurek.raycaster.newHeightMap`: Creates a new height map for variable floor/ceiling heights across the grid.
- `lurek.raycaster.newPointLight`: Creates a new point light with position, color, radius, and intensity.
- `lurek.raycaster.newSpriteManager`: Creates a new sprite manager for tracking and projecting billboard sprites.

### `LDoorManager` Methods
- `LDoorManager:addDoor`: Registers a new sliding door at the given grid cell.
- `LDoorManager:openDoor`: Begins opening the door at the given index. The door animates over time via `update()`.
- `LDoorManager:closeDoor`: Begins closing the door at the given index. The door animates over time via `update()`.
- `LDoorManager:update`: Advances all door animations by the given delta time. Call once per frame.
- `LDoorManager:getDoor`: Returns a table describing the door at the given index, or nil if index is out of range.
- `LDoorManager:count`: Returns the total number of registered doors.
- `LDoorManager:type`: Returns the type name of this object.
- `LDoorManager:typeOf`: Checks whether this object matches the given type name.

### `LHeightMap` Methods
- `LHeightMap:setFloor`: Sets the floor height offset at a specific grid cell.
- `LHeightMap:setCeiling`: Sets the ceiling height offset at a specific grid cell.
- `LHeightMap:floorAt`: Returns the floor height offset at a given grid cell.
- `LHeightMap:ceilingAt`: Returns the ceiling height offset at a given grid cell.
- `LHeightMap:type`: Returns the type name of this object.
- `LHeightMap:typeOf`: Checks whether this object matches the given type name.

### `LPointLight` Methods
- `LPointLight:x`: Returns the X world position of this light.
- `LPointLight:y`: Returns the Y world position of this light.
- `LPointLight:radius`: Returns the light's falloff radius in world units.
- `LPointLight:intensity`: Returns the brightness multiplier of this light.
- `LPointLight:color`: Returns the RGB color components of this light.
- `LPointLight:set`: Overwrites all properties of this point light in a single call.
- `LPointLight:type`: Returns the type name of this object ("LPointLight").
- `LPointLight:typeOf`: Checks whether this object matches the given type name.

### `LRaycaster` Methods
- `LRaycaster:setCell`: Sets the wall type value at a grid cell. Non-zero values are solid walls.
- `LRaycaster:getCell`: Returns the wall type value at a grid cell.
- `LRaycaster:setCells`: Replaces the entire map grid with a flat array of cell values (row-major order).
- `LRaycaster:isBlocked`: Returns true if the grid cell is a solid wall (non-zero value).
- `LRaycaster:width`: Returns the map width in grid cells.
- `LRaycaster:height`: Returns the map height in grid cells.
- `LRaycaster:setFloorTextureCell`: Assigns a per-cell floor texture override. Pass nil to remove the override.
- `LRaycaster:getFloorTextureCell`: Returns the raw texture id assigned to this floor cell, or nil if none.
- `LRaycaster:setCeilingTextureCell`: Assigns a per-cell ceiling texture override. Pass nil to remove the override.
- `LRaycaster:getCeilingTextureCell`: Returns the raw texture id assigned to this ceiling cell, or nil if none.
- `LRaycaster:setLoweredFloorCell`: Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LRaycaster:getLoweredFloorCell`: Returns the lowered floor configuration at a cell, or nil if the cell is normal.
- `LRaycaster:isWalkBlocked`: Returns true if the cell blocks walking (solid wall OR blocked lowered-floor cell).
- `LRaycaster:tryMove`: Attempts to move from (px,py) by (dx,dy) with wall-slide collision. Returns the final position.
- `LRaycaster:gridMove`: Performs a discrete grid-step movement in one of 4 cardinal directions with collision.
- `LRaycaster:castRay`: Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.
- `LRaycaster:castRays`: Casts multiple rays across a field of view and returns an array of hit tables.
- `LRaycaster:castRaysFlat`: Casts multiple rays and returns only the corrected distances as a flat array.
- `LRaycaster:lineOfSight`: Tests whether there is a clear line of sight between two world points (no walls in between).
- `LRaycaster:revealCellsFromRays`: Casts rays across the FOV and returns a list of grid cells that are visible (for fog-of-war).
- `LRaycaster:computeTileLight`: Computes the combined lighting color at a tile from ambient and point lights, accounting for walls.
- `LRaycaster:buildMinimapWindow`: Generates a grid of minimap tile samples around a center point with lighting info.
- `LRaycaster:extractMinimap`: Extracts a pixel minimap image centered on the player from this raycaster map.
- `LRaycaster:setWallAlpha`: Sets the transparency for a specific wall tile type, enabling see-through walls.
- `LRaycaster:getWallAlpha`: Returns the current transparency value for a wall tile type.
- `LRaycaster:castRayMulti`: Casts a single ray that passes through transparent walls, returning multiple hits.
- `LRaycaster:castFloorRow`: Computes floor/ceiling texture UV coordinates for a single scanline row.
- `LRaycaster:projectSprite`: Projects a world-space sprite to screen coordinates for billboard rendering.
- `LRaycaster:drawTopDown`: Renders a top-down debug view of the map with the player's position and direction.
- `LRaycaster:drawView`: Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).
- `LRaycaster:drawDepthMap`: Renders a grayscale depth map showing distance-to-wall for each column.
- `LRaycaster:drawLineOfSight`: Renders a debug image showing the line-of-sight ray between two world points.
- `LRaycaster:drawCameraSweep`: Renders multiple frames of a rotating camera sweep as a single combined image.
- `LRaycaster:buildScene`: Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.
- `LRaycaster:buildSceneWithModels`: Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.
- `LRaycaster:type`: Returns the type name of this object ("LRaycaster").
- `LRaycaster:typeOf`: Checks whether this object matches the given type name.

### `LSpriteManager` Methods
- `LSpriteManager:add`: Adds a new sprite to the manager at a world position with a texture name and optional scale.
- `LSpriteManager:remove`: Removes a sprite by its id. This method is available to Lua scripts.
- `LSpriteManager:setPosition`: Updates the world position of an existing sprite.
- `LSpriteManager:setVisible`: Shows or hides a sprite without removing it.
- `LSpriteManager:clear`: Removes all sprites from the manager.
- `LSpriteManager:sortAndProject`: Sorts all visible sprites by distance from the camera and returns projection data.
- `LSpriteManager:type`: Returns the type name of this object ("LSpriteManager").
- `LSpriteManager:typeOf`: Checks whether this object matches the given type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/raycaster/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
