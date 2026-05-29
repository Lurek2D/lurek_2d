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

## Files

### build_scene.rs

- Build a complete `RaycasterScene` each frame from camera parameters, a DDA grid, and texture lookups.
- Project floor and ceiling tiles as perspective-correct quads with per-tile lighting and UV mapping.
- Generate lowered-floor pit geometry including depth-offset surfaces and side-wall extrusions.
- Emit wall-face quads for every visible solid-cell boundary with roof-side thickness geometry.
- Project billboard sprites to screen space with distance-based sizing and lighting.
- Integrate ambient light, point-light contributions, distance shading, and roofed-ambient darkening.
- Provide camera-space depth projection helpers (`camera_depth`, `project_ground_point`, `project_horizontal_plane`).
- Snap projected coordinates to half-pixel boundaries to reduce sub-pixel jitter on floor/ceiling edges.
- Supply UV-generation utilities for axis-aligned quads and world-space column strips.

### column_batch.rs

- Per-column wall-slice projection data produced by the DDA stepper.
- Full-frame column batch holding screen dimensions and flat floor/ceiling colors.
- Bulk update from packed ray data and per-column depth queries.

### dda.rs

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

### depth_buffer.rs

- Per-column depth storage for raycaster wall hits.
- Used during sprite rendering to cull pixels that fall behind walls.
- Cleared each frame, written during wall-casting, read during sprite-casting.

### doors.rs

- Animated sliding doors placed on raycaster grid tiles.
- Per-door state machine: Closed → Opening → Open → Closing → Closed.
- DoorManager registry drives batch updates and spatial lookups.

### draw.rs

- Software rasterization of a raycaster scene into an `ImageData` pixel buffer.
- Flat-shaded fills for ceilings, floors, walls, and sprites.
- Back-to-front draw order for correct painter's-algorithm layering.

### grid_motion.rs

- Discrete movement actions (forward, backward, strafe) for grid-locked locomotion.
- Direction-to-delta conversion for 4-directional facing (E/S/W/N).
- Collision-checked tile movement with configurable blocking predicate.

### heightmap.rs

- Per-tile floor and ceiling height storage for raycaster maps.
- Supports individual tile and rectangular region height assignment.
- Out-of-bounds coordinates are silently ignored or return safe defaults.

### level_render.rs

- Raycaster level renderer: wall, floor, ceiling, and sprite column rendering.
- `render_level_columns` is the hot path; called once per screen column per frame.
- `compute_hole_visibility` pre-calculates which cells are visible through openings.
- Texture-mapped floors/ceilings use an affine perspective-corrected UV formula.
- All output goes to an RGBA framebuffer; no wgpu calls are made from this module.
- Performance target: 60 FPS at 320×200 on integrated GPUs; scales to 1080p.

### lighting.rs

- Point-light model with position, radius, intensity, and RGB color.
- Bresenham line-of-sight check to block light through walls.
- Per-tile lighting accumulator combining ambient and point-light contributions.

### mod.rs

- Grid-based 2D raycaster using DDA ray-stepping and column projection.
- Builds per-frame scenes with wall quads, floor/ceiling, sprites, and doors.
- Supports heightmaps, distance lighting, depth occlusion, and FOV visibility.
- Provides debug visualization helpers.

### multilevel.rs

- Multi-level raycaster: stacked horizontal slices for floors, ceilings, and bridges.
- Extends the flat raycaster with per-column level stacks for multi-storey maps.
- Each level slice defines a floor height, ceiling height, and tile layer pair.
- Level transitions (stairs, portals) are handled as special tile types.
- Blends into the base `level_render` pipeline; no separate render pass needed.

### projection.rs

- Wall-column projection from ray distance to screen-pixel height and vertical bounds.
- Distance-based shading for depth fog attenuation.
- Returns `(wall_height, draw_start, draw_end)` clamped to valid screen-pixel bounds.

### ray_hit.rs

- DDA ray-cast result record holding wall distance, hit coordinates, and texture sampling data.
- Carries both fish-eye-corrected and raw distances for flexible column rendering.
- Provides side, alpha, and cell value for shading and transparency decisions.

### render.rs

- Convert a built raycaster scene into GPU-ready render commands.
- Emit textured quads for ceilings, floors, walls, and sprites in correct painter order.
- Fall back to solid-color rectangles when a surface has no texture assigned.

### scene.rs

- Scene geometry types emitted by the raycaster build pass and consumed by the renderer.
- Quad primitives for walls, floors, ceilings, billboard sprites, and static meshes.
- `RaycasterScene` collects all quads for one frame with depth and perspective-correct UV data.

### segment.rs

- 2D line segment representation for raycaster wall geometry.
- Ray-vs-segment intersection test returning nearest hit point and index.
- Used by the raycaster module to resolve wall hits from arbitrary origins.

### sprite_manager.rs

- Billboard sprite registry for the raycaster subsystem.
- Manages creation, removal, positioning, and visibility of world-space sprites.
- Provides distance-sorted iteration for back-to-front rendering.

### sprite_projection.rs

- Screen-space sprite projection data for raycaster billboard rendering.
- Stores position, scale, distance, and visibility after camera-plane projection.
- Consumed by the depth-buffer occlusion pass to sort and clip sprites.

### tile_picker.rs

- Tile picker: converts a screen (x, y) click into a raycasted map tile coordinate.
- `pick_tile(screen_x, screen_y, camera, map)` returns `Option<(tile_x, tile_y)>`.
- Reverses the column rendering math to find the intersection depth for a pixel.
- Accounts for the player's position and angle at the moment of the pick query.
- Used by `lurek.raycaster.pick(x, y)` to report tile coordinates to Lua scripts.

### visibility.rs

- Radial visibility polygon computation from a point source.
- Casts rays at segment-endpoint angles with epsilon jitter for gap-free coverage.
- Returns interleaved coordinate arrays suitable for triangle-fan rendering.

### visualization.rs

- Software-rendered raycaster visualization helpers for debugging and demo output.
- Top-down grid map rendering with player position and radial ray overlay.
- First-person column-based wall rendering with distance-based shading.
- Depth-map greyscale visualization where brightness encodes proximity.
- Line-of-sight connectivity check rendered as a coloured line between two points.
- Camera sweep atlas generating a multi-frame rotation sequence into a single image.
- Procedural textured first-person view with brick, stone, wood, metal, and mosaic patterns.
- All outputs produce an `ImageData` bitmap suitable for GPU upload or file export.
- Procedural texture lookup mapping cell type and UV to RGB without external assets.

## Lua API Ref

- Binding: `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`

### Functions

- `lurek.raycaster.applyLitShade`: Applies an RGB light color to a scalar shade value.
- `lurek.raycaster.distanceShade`: Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
- `lurek.raycaster.new`: Creates a new raycaster map with the given grid dimensions.
- `lurek.raycaster.newDoorManager`: Creates a new door manager for tracking and animating sliding doors.
- `lurek.raycaster.newHeightMap`: Creates a new height map for variable floor/ceiling heights across the grid.
- `lurek.raycaster.newMap`: Creates a new raycaster map (alias for `new`).
- `lurek.raycaster.newPointLight`: Creates a new point light with position, color, radius, and intensity.
- `lurek.raycaster.newSpriteManager`: Creates a new sprite manager for tracking and projecting billboard sprites.
- `lurek.raycaster.projectColumn`: Computes the projected wall-column height for a given distance, FOV, and screen height.

### Enums

- No documented module-level enums/constants.

### Types


#### LDoorManager Type


##### Fields

- No documented fields.

##### Methods

- `LDoorManager:addDoor`: Registers a new sliding door at the given grid cell.
- `LDoorManager:closeDoor`: Begins closing the door at the given index. The door animates over time via `update()`.
- `LDoorManager:count`: Returns the total number of registered doors.
- `LDoorManager:getDoor`: Returns a table describing the door at the given index, or nil if index is out of range.
- `LDoorManager:openDoor`: Begins opening the door at the given index. The door animates over time via `update()`.
- `LDoorManager:type`: Returns the type name of this object.
- `LDoorManager:typeOf`: Checks whether this object matches the given type name.
- `LDoorManager:update`: Advances all door animations by the given delta time. Call once per frame.


#### LHeightMap Type


##### Fields

- No documented fields.

##### Methods

- `LHeightMap:ceilingAt`: Returns the ceiling height offset at a given grid cell.
- `LHeightMap:floorAt`: Returns the floor height offset at a given grid cell.
- `LHeightMap:setCeiling`: Sets the ceiling height offset at a specific grid cell.
- `LHeightMap:setFloor`: Sets the floor height offset at a specific grid cell.
- `LHeightMap:type`: Returns the type name of this object.
- `LHeightMap:typeOf`: Checks whether this object matches the given type name.


#### LPointLight Type


##### Fields

- No documented fields.

##### Methods

- `LPointLight:color`: Returns the RGB color components of this light.
- `LPointLight:intensity`: Returns the brightness multiplier of this light.
- `LPointLight:radius`: Returns the light's falloff radius in world units.
- `LPointLight:set`: Overwrites all properties of this point light in a single call.
- `LPointLight:type`: Returns the type name of this object ("LPointLight").
- `LPointLight:typeOf`: Checks whether this object matches the given type name.
- `LPointLight:x`: Returns the X world position of this light.
- `LPointLight:y`: Returns the Y world position of this light.


#### LRaycaster Type


##### Fields

- No documented fields.

##### Methods

- `LRaycaster:buildMinimapWindow`: Generates a grid of minimap tile samples around a center point with lighting info.
- `LRaycaster:buildScene`: Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.
- `LRaycaster:buildSceneWithModels`: Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.
- `LRaycaster:castFloorRow`: Computes floor/ceiling texture UV coordinates for a single scanline row.
- `LRaycaster:castRay`: Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.
- `LRaycaster:castRayMulti`: Casts a single ray that passes through transparent walls, returning multiple hits.
- `LRaycaster:castRays`: Casts multiple rays across a field of view and returns an array of hit tables.
- `LRaycaster:castRaysFlat`: Casts multiple rays and returns only the corrected distances as a flat array.
- `LRaycaster:computeTileLight`: Computes the combined lighting color at a tile from ambient and point lights, accounting for walls.
- `LRaycaster:drawCameraSweep`: Renders multiple frames of a rotating camera sweep as a single combined image.
- `LRaycaster:drawDepthMap`: Renders a grayscale depth map showing distance-to-wall for each column.
- `LRaycaster:drawLineOfSight`: Renders a debug image showing the line-of-sight ray between two world points.
- `LRaycaster:drawTopDown`: Renders a top-down debug view of the map with the player's position and direction.
- `LRaycaster:drawView`: Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).
- `LRaycaster:extractMinimap`: Extracts a pixel minimap image centered on the player from this raycaster map.
- `LRaycaster:getCeilingTextureCell`: Returns the raw texture id assigned to this ceiling cell, or nil if none.
- `LRaycaster:getCell`: Returns the wall type value at a grid cell.
- `LRaycaster:getFloorTextureCell`: Returns the raw texture id assigned to this floor cell, or nil if none.
- `LRaycaster:getLoweredFloorCell`: Returns the lowered floor configuration at a cell, or nil if the cell is normal.
- `LRaycaster:getWallAlpha`: Returns the current transparency value for a wall tile type.
- `LRaycaster:gridMove`: Performs a discrete grid-step movement in one of 4 cardinal directions with collision.
- `LRaycaster:height`: Returns the map height in grid cells.
- `LRaycaster:isBlocked`: Returns true if the grid cell is a solid wall (non-zero value).
- `LRaycaster:isWalkBlocked`: Returns true if the cell blocks walking (solid wall OR blocked lowered-floor cell).
- `LRaycaster:lineOfSight`: Tests whether there is a clear line of sight between two world points (no walls in between).
- `LRaycaster:projectSprite`: Projects a world-space sprite to screen coordinates for billboard rendering.
- `LRaycaster:revealCellsFromRays`: Casts rays across the FOV and returns a list of grid cells that are visible (for fog-of-war).
- `LRaycaster:setCeilingTextureCell`: Assigns a per-cell ceiling texture override. Pass nil to remove the override.
- `LRaycaster:setCell`: Sets the wall type value at a grid cell. Non-zero values are solid walls.
- `LRaycaster:setCells`: Replaces the entire map grid with a flat array of cell values (row-major order).
- `LRaycaster:setFloorTextureCell`: Assigns a per-cell floor texture override. Pass nil to remove the override.
- `LRaycaster:setLoweredFloorCell`: Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LRaycaster:setWallAlpha`: Sets the transparency for a specific wall tile type, enabling see-through walls.
- `LRaycaster:tryMove`: Attempts to move from (px,py) by (dx,dy) with wall-slide collision. Returns the final position.
- `LRaycaster:type`: Returns the type name of this object ("LRaycaster").
- `LRaycaster:typeOf`: Checks whether this object matches the given type name.
- `LRaycaster:width`: Returns the map width in grid cells.


#### LSpriteManager Type


##### Fields

- No documented fields.

##### Methods

- `LSpriteManager:add`: Adds a new sprite to the manager at a world position with a texture name and optional scale.
- `LSpriteManager:clear`: Removes all sprites from the manager.
- `LSpriteManager:remove`: Removes a sprite by its id. This method is available to Lua scripts.
- `LSpriteManager:setPosition`: Updates the world position of an existing sprite.
- `LSpriteManager:setVisible`: Shows or hides a sprite without removing it.
- `LSpriteManager:sortAndProject`: Sorts all visible sprites by distance from the camera and returns projection data.
- `LSpriteManager:type`: Returns the type name of this object ("LSpriteManager").
- `LSpriteManager:typeOf`: Checks whether this object matches the given type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
