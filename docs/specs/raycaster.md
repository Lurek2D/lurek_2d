# raycaster

## TL;DR

- Simulates pseudo-3D first-person views from 2D maps using DDA marching.
- Supports transparent walls, variable heights, and multilevel storeys.
- Manages sliding doors, discrete grid motion, and billboard sprites.
- Renders textured space with point lights, depth buffers, and pickers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/raycaster/`
- Binding: `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`
- Lua API surface: `12` functions, `16` types, `99` methods
- Rust test path(s): tests/rust/unit/raycaster_tests.rs
- Lua test path(s): tests/lua/unit/test_raycaster_core_unit.lua, tests/lua/evidence/test_raycaster_evidence.lua

## Summary

- The raycaster module projects 2D grid maps into pseudo-3D first-person scenes.
- Core traversal uses DDA ray marching for reliable tile intersection.
- Perpendicular distance correction reduces fish-eye distortion artifacts.
- Layered hit traversal supports transparent or partially passable surfaces.
- Heightmaps support variable floor and ceiling profiles.
- Multilevel support enables stacked slices and vertical transition logic.
- Sliding doors are tracked as stateful animated grid occupants.
- Grid-motion helpers support classic tile-snapped dungeon movement.
- Billboard sprites represent dynamic entities in camera-facing projection.
- Depth-aware ordering prevents billboard leakage through wall columns.
- Scene building composes walls, floors, ceilings, sprites, and optional mesh inserts.
- Lighting combines ambient and point-light effects with occlusion checks.
- Last-build diagnostics expose lighting sample counts and cache reuse for scene-build profiling.
- Depth buffers track wall ownership per screen column.
- GPU path emits render commands for shared backend composition.
- CPU software path supports snapshots, tests, and tool previews.
- Tile picking maps screen coordinates back to hit tile and side semantics.
- Visibility helpers support line-of-sight and fan-style query tooling.
- Visualization utilities generate diagnostic images for rays and depth behavior.
- Column batch structures provide compact transport of cast results.
- Scene structs define a stable handoff between cast and draw phases.
- Camera semantics are kept consistent across cast, pick, and render paths.
- The module is 2D-first and does not implement full 3D physics.
- It owns projection and scene composition for first-person map experiences.
- Dependencies remain aligned with Lurek2D architecture boundaries.
- Invariants emphasize deterministic cast output for fixed camera/map input.
- Ordering invariants preserve coherent depth between walls and billboards.
- APIs support both gameplay runtime and authoring/debug workflows.
- The module is suitable for retro FPS and dungeon crawler experiences.
- It provides strong observability through explicit diagnostics.
- Performance is controlled by bounded per-column processing and culling assumptions.
- Integration with render is direct through shared quad-oriented command language.
- Overall, raycaster is a dedicated Feature Systems view pipeline.
- It delivers practical first-person rendering without a full 3D stack.
- This keeps implementation affordable while preserving gameplay readability.
- The module is robust enough for production maps and iterative prototypes.
- It supports deterministic behavior needed by evidence-style tests.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### build_scene.rs

- This file assembles the full per-frame raycaster scene from camera state, grid hits, texture routing, and lighting inputs.
- It turns wall contacts into screen-space quads whose geometry already matches the perspective rules expected by the render stage.
- Floor and ceiling strips are expanded into textured spans with stable UVs so long corridors and open rooms keep coherent surface motion.
- Lowered cells become pits with visible bottoms, side faces, and transitions that preserve depth cues instead of flattening into one plane.
- Roofed regions are darkened differently from open regions so covered space reads denser even before dynamic lights are applied.
- Point lights, ambient light, and distance falloff are blended here so every emitted surface leaves this file with its final light tint.
- Repeated lighting samples within one scene build are memoized so dense textured worlds avoid recomputing the same tile-light state.
- Billboard sprites are projected into the same camera space as walls, which keeps monsters, props, and pickups aligned with corridor depth.
- Static meshes can be injected beside billboarded elements without asking later stages to reconstruct world-space context.
- Ground projection helpers convert world corners into screen corners for both top and bottom planes with near-plane rejection baked in.
- UV helpers keep repeated strips and axis-aligned quads visually stable when the camera rotates or grazes a tile boundary.
- Half-pixel snapping is applied where needed to reduce shimmer along long floor edges and thin seam lines.
- The file also decides how visible boundaries around solid cells become roof lips, pit walls, and other secondary surfaces.
- Output is a dense scene description rather than immediate pixels, so later stages can sort, batch, or rasterize without redoing math.
- Most of the expensive spatial reasoning for textured raycast presentation lives here, not in the draw backends.
- In practice this is the bridge between raw DDA hit data and a believable first-person space built from quads and light.

### column_batch.rs

- This file stores the compact per-column output that the raycaster produces before any richer scene assembly begins.
- It keeps wall slice projection, depth, and screen span data in a shape that is cheap to fill for an entire frame at once.
- Frame-level metadata for colors and dimensions rides next to the columns so downstream code can treat one batch as a complete column pass.
- Packed ray input is unpacked here into stable per-column records that preserve shading and visibility decisions from the DDA stage.
- The result is a narrow transport format between hit collection and later wall, floor, or sprite composition work.

### dda.rs

- This file owns the grid-backed DDA marcher that turns a 2D tile map into ray hits, corrected distances, and wall sampling coordinates.
- It handles both single-hit and layered traversal so partially transparent cells can be marched through without losing the final solid contact.
- Wide fan casts for a whole screen are derived from the same stepping rules, which keeps column rendering consistent with ad hoc queries.
- Line-of-sight checks reuse the same grid logic, so lighting, AI, and visibility questions follow the same blocking semantics as rendering.
- The map storage stays simple and row-major, with safe fallback behavior for out-of-range reads and silent rejection of invalid writes.
- Sprite projection helpers live beside ray stepping so billboard placement uses the same camera conventions as wall casting.
- Floor and ceiling sampling utilities expose screen-to-world relationships without forcing higher layers to re-derive projection math.
- This file is the computational core of the raycaster, where map occupancy becomes reliable spatial hits and camera-facing depth data.

### depth_buffer.rs

- This file keeps the narrow depth memory that tells the raycaster which wall distance currently owns each screen column.
- It exists so later sprite and overlay work can reject fragments that should remain hidden behind already projected geometry.
- The structure is intentionally simple because it is cleared, written, and read every frame on the hottest render path.

### doors.rs

- This file models raycaster doors as animated grid occupants whose openness changes continuously while their tile identity stays stable.
- Each door carries movement direction, travel progress, and a small phase machine so gameplay code can request transitions without manual timing.
- The manager keeps doors in one indexed registry, making updates and spatial queries deterministic for the rest of the raycaster.
- Because door openness is tracked separately from base map cells, rendering and collision code can read evolving passage state without duplicating logic.
- The overall effect is a lightweight moving-boundary system that fits the same tile world used by walls, sprites, and picking.

### draw.rs

- This file turns a prepared raycaster scene into software pixels when GPU command generation is not the chosen output path.
- It fills ceilings, floors, walls, and sprite shapes directly into image memory using the scene ordering established earlier in the pipeline.
- Draw order stays deliberately simple so layered surfaces read correctly even without a richer hardware depth workflow.
- The result is useful for offline images, debug previews, and tool-facing render outputs that need first-person content in CPU memory.

### grid_motion.rs

- This file provides grid-locked locomotion rules for games that want raycaster movement to snap cleanly from tile to tile.
- Facing direction is reduced to stable cardinal deltas so movement input stays predictable for dungeon crawlers and similar designs.
- Collision checks are delegated through a caller-provided blocking rule, which lets map logic stay external while motion rules stay reusable.
- The emphasis is on deterministic tile traversal rather than smooth analog movement, matching classic first-person grid exploration.

### heightmap.rs

- This file stores per-tile floor and ceiling offsets so a raycast map can express steps, pits, and varied room volumes.
- Height data can be assigned cell by cell or across rectangular regions, which makes authored layouts and procedural stamping equally convenient.
- Reads always yield a stable answer and invalid writes are ignored, keeping spatial queries predictable when tools or scripts probe edges.
- It is the lightweight elevation layer that feeds richer scene building without forcing the base map storage to change shape.

### level_render.rs

- This file handles the column-wise drawing logic for stacked raycaster levels where openings can reveal space above or below the current slice.
- It decides which neighboring cells remain visible through holes so multi-level layouts feel connected instead of collapsing into isolated layers.
- Framebuffer output is written directly in software, with floor and ceiling sampling tuned for readable textured planes in narrow screen columns.
- The file therefore acts as the specialized draw path for vertical level relationships that are more complex than the flat scene builder alone.

### lighting.rs

- This file applies local lighting plus optional directional sun to raycast space using colored point emitters, ambient fill, and simple grid shadows.
- Visibility between a light and a sample point is checked against blocking tiles so illumination respects corridor walls and corners.
- Contributions from multiple emitters are accumulated into one tint that later scene builders can stamp onto walls, floors, sprites, and injected meshes.
- The model favors clear spatial mood and cheap evaluation over physically exact light transport.

### mod.rs

- This module delivers the raycast feature stack that turns a 2D tile field into a readable first-person space with walls, floors, ceilings, sprites, and moving doors.
- It combines DDA stepping, projection, scene building, visibility, lighting, and helper render paths so game code can ask for either gameplay queries or full presentation output.
- Support code for elevation, multilevel layouts, picking, depth, and debug visualization lives beside the core marcher so the subsystem keeps one camera model end to end.
- At the highest level, this is the part of the engine that gives Lua and Rust callers a classic grid-based 3D view without leaving the 2D runtime architecture.

### multilevel.rs

- This file extends the flat raycaster into stacked slices so one map position can participate in a multi-storey layout.
- Each slice carries its own vertical span and tile layer, allowing bridges, overhead rooms, shafts, and similar structures to share horizontal space.
- The representation stays close to the base raycaster model, which keeps level transitions understandable for rendering and gameplay code.
- Special transitions can move the viewer between slices without inventing a separate world format or renderer.
- The design is meant to add vertical richness while preserving the core assumptions of the column-based pipeline.

### projection.rs

- Projection mathematics converting ray-cast distance values into screen-space wall column heights and vertical draw bounds for 3D raycaster rendering.
- Implements distance-based perspective projection computing wall_height from camera FOV and ray distance, then clamps draw coordinates to screen bounds.
- Computes distance falloff multipliers enabling progressive darkening of farther geometry creating atmospheric depth and preventing visual pops.

### ray_hit.rs

- This file defines the hit record that carries everything a marched ray learned when it touched visible map geometry.
- It preserves both geometric contact details and render-facing details such as sampled side, distance flavor, opacity, and tile identity.
- The struct is the shared currency between stepping, scene building, shading, and any caller that needs precise impact information.

### render.rs

- This file converts the prepared raycaster scene into renderer commands that the broader engine command stream already understands.
- It emits textured or flat-colored quads in the ordering expected for ceilings, floors, walls, and billboard content.
- Because the scene already carries geometry, UVs, light, and depth intent, this step mostly translates instead of recomputing presentation logic.
- The file is therefore the handoff point where raycast-specific scene data becomes generic render work for the engine backend.

### scene.rs

- This file defines the transient geometry language that the raycaster uses between spatial reasoning and final drawing.
- Walls, floors, ceilings, sprites, and injected meshes all share a quad-oriented representation so later stages can sort and emit them uniformly.
- Each record carries the texture routing, light tint, depth meaning, and UV state needed to survive the trip from world logic to renderer.
- The scene container groups one frame of these surfaces into a single package sized to the active viewport.
- In practice it is the raycaster's staging area for everything the camera can currently see.

### segment.rs

- This file provides a minimal 2D segment representation for ray-style queries that are easier to express against explicit line geometry.
- It computes nearest segment intersections from an origin and direction so callers can reason about wall-like boundaries outside the grid marcher.
- The focus is geometric clarity for helper queries, not a full alternate rendering pipeline.

### sprite_manager.rs

- This file manages world-space billboard content that should appear inside the raycast view without becoming part of the wall grid.
- It keeps sprite placement, identity, and visibility data in one registry so gameplay systems can add props, pickups, or actors cheaply.
- When the camera needs them, sprites are exposed in depth-aware order that fits alpha-friendly first-person rendering.
- The registry therefore acts as the dynamic object layer that rides on top of static map geometry.

### sprite_projection.rs

- This file stores the screen-facing projection result for a billboard after world position has been interpreted through the raycaster camera.
- It captures where the sprite should land, how large it should read, and whether it remains meaningfully visible to the viewer.
- That compact record lets later passes sort, cull, and clip billboard content against wall depth without repeating camera math.

### tile_picker.rs

- This file maps a screen interaction back into raycaster grid space so UI clicks can target the world the player is looking at.
- It replays the essential camera and stepping assumptions of the view transform instead of relying on a separate picking representation.
- Screen size, camera pose, and tile scale are all part of the picker state, which keeps repeated queries stable across a frame.
- The result reports both tile identity and hit character so callers can tell which cell was reached and from which side it was approached.
- This makes the file the practical bridge between first-person view coordinates and gameplay selection on the underlying map.

### visibility.rs

- This file computes a radial visibility fan from a source point against segment obstacles in the plane.
- Rays are aimed around segment endpoints with slight angular offsets so the resulting contour closes gaps that naive sampling would miss.
- The output is shaped for immediate drawing or further masking work wherever a 2D field of view needs explicit polygon points.

### visualization.rs

- This file provides software visualizers that expose how the raycaster sees, marches, shades, and composes space without requiring the main renderer.
- It can paint overhead maps, first-person wall bands, line-of-sight traces, depth previews, and sweep atlases directly into image buffers.
- Procedural material coloring is embedded here so diagnostic or demo output can still look spatially rich without loading authored textures.
- The helpers are useful when tuning collision, sampling, map layout, or visibility because they make invisible intermediate state immediately legible.
- Outputs stay in plain image memory, which makes them easy to save, inspect in tools, or present inside UI overlays.
- Several views deliberately trade physical correctness for fast explanation, prioritizing readable spatial evidence over final-game polish.
- This file therefore acts as the observability layer for the raycaster subsystem, not just a collection of screenshots.
- It is where engine authors can inspect the behavior of rays, walls, and depth as pictures instead of logs.

### wall_feature.rs

- This file defines per-cell wall feature descriptors that refine how a blocking tile should render and behave.
- Features let one tile become a half-height barrier, a window with a visible opening, or a sliding door without changing the base 2D map format.
- The data stays compact and cell-local so scene building, collision, and editor-facing APIs can all consult the same description.



## Lua API Ref

### Functions

- `lurek.raycaster.applyLitShade(baseShade, r, g, b) -> number`: Applies an RGB light color to a scalar shade value.
- `lurek.raycaster.buildMultiLevelScene(params, levels, lights?, sprites?, wallTextures?, models?) -> integer`: Builds a multilevel raycaster scene from a stack of plain Lua level tables.
- `lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, wallTextures?) -> integer`: Builds a multilevel raycaster scene from plain Lua level tables using a runtime scene adapter that may follow physics bodies.
- `lurek.raycaster.distanceShade(distance, maxDistance) -> number`: Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
- `lurek.raycaster.new(w, h) -> LRaycaster`: Creates a new raycaster map with the given grid dimensions.
- `lurek.raycaster.newDoorManager() -> LDoorManager`: Creates a new door manager for tracking and animating sliding doors.
- `lurek.raycaster.newHeightMap(w, h) -> LHeightMap`: Creates a new height map for variable floor/ceiling heights across the grid.
- `lurek.raycaster.newMap(w, h) -> LRaycaster`: Creates a new raycaster map (alias for `new`).
- `lurek.raycaster.newMultiLevelGrid(levels?) -> LMultiLevelGrid`: Creates a persistent multi-level raycaster world from plain Lua level tables or as an empty container.
- `lurek.raycaster.newPointLight(x, y, r, g, b, radius, intensity, level?) -> LPointLight`: Creates a new point light with position, color, radius, and intensity.
- `lurek.raycaster.newSceneAdapter() -> LSceneAdapter`: Creates a runtime scene adapter for sprites, lights, and models that may follow physics bodies.
- `lurek.raycaster.newSpriteManager() -> LSpriteManager`: Creates a new sprite manager for tracking and projecting billboard sprites.
- `lurek.raycaster.pickScreenMultiLevel(sx, sy, params, levels, wallTextures?, sprites?, models?) -> table`: Resolves a screen-space click against a stack of plain Lua level tables and returns the owning level.
- `lurek.raycaster.pickScreenMultiLevelFromAdapter(sx, sy, params, levels, wallTextures?, adapter) -> table`: Resolves a screen-space click against plain Lua level tables using a runtime scene adapter.
- `lurek.raycaster.projectColumn(distance, fov, screenHeight) -> number`: Computes the projected wall-column height for a given distance, FOV, and screen height.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LDoorManager Type

- Lua-visible door manager that controls sliding doors within a raycaster map.

##### Fields

- No documented fields.

##### Methods

- `LDoorManager:addDoor(x, y, direction, speed) -> integer`: Registers a new sliding door at the given grid cell.
- `LDoorManager:closeDoor(index) -> nil`: Begins closing the door at the given index. The door animates over time via `update()`.
- `LDoorManager:count() -> integer`: Returns the total number of registered doors.
- `LDoorManager:getDoor(index) -> table`: Returns a table describing the door at the given index, or nil if index is out of range.
- `LDoorManager:openDoor(index) -> nil`: Begins opening the door at the given index. The door animates over time via `update()`.
- `LDoorManager:type() -> string`: Returns the type name of this object.
- `LDoorManager:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LDoorManager:update(dt) -> nil`: Advances all door animations by the given delta time. Call once per frame.

#### LDoorManagerGetDoorResult Type

- Generated result shape from @field tags.

##### Fields

- `openAmount` (`number`): Open amount 0.0 to 1.0.
- `state` (`string`): Door state.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LHeightMap Type

- Lua-visible height map that stores per-cell floor and ceiling offsets for variable-height raycaster levels.

##### Fields

- No documented fields.

##### Methods

- `LHeightMap:ceilingAt(x, y) -> number`: Returns the ceiling height offset at a given grid cell.
- `LHeightMap:floorAt(x, y) -> number`: Returns the floor height offset at a given grid cell.
- `LHeightMap:setCeiling(x, y, h) -> nil`: Sets the ceiling height offset at a specific grid cell.
- `LHeightMap:setFloor(x, y, h) -> nil`: Sets the floor height offset at a specific grid cell.
- `LHeightMap:type() -> string`: Returns the type name of this object.
- `LHeightMap:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMultiLevelGrid Type

- Lua-visible persistent multi-level raycaster world used for repeated build/pick calls.

##### Fields

- No documented fields.

##### Methods

- `LMultiLevelGrid:activeLevel() -> integer`: Returns the currently active level index used for stacked camera height.
- `LMultiLevelGrid:addLevel(level) -> integer`: Appends one level described with the same table format accepted by buildMultiLevelScene.
- `LMultiLevelGrid:buildScene(params, lights?, sprites?, wallTextures?) -> integer`: Builds a textured multilevel raycaster scene from this persistent world and stores it for rendering.
- `LMultiLevelGrid:buildSceneFromAdapter(params, adapter, wallTextures?) -> integer`: Builds a textured multilevel raycaster scene from a runtime scene adapter that may follow physics bodies.
- `LMultiLevelGrid:clearWallFeatureCell(x, y) -> nil`: Removes any per-cell wall feature override from the active level.
- `LMultiLevelGrid:getCell(x, y) -> integer`: Returns the wall type value at a grid cell on the active level.
- `LMultiLevelGrid:getWallFeatureCell(x, y) -> table`: Returns the wall feature attached to an active-level cell, or nil when none is set.
- `LMultiLevelGrid:isCeilingHole(x, y) -> boolean`: Returns true when an active-level cell is open to the level above.
- `LMultiLevelGrid:isFloorHole(x, y) -> boolean`: Returns true when an active-level cell is open to the level below.
- `LMultiLevelGrid:levelCount() -> integer`: Returns the total number of stored levels.
- `LMultiLevelGrid:pickScreen(sx, sy, params, wallTextures?, sprites?, models?) -> table`: Resolves a screen-space click against this persistent multi-level world and returns the owning level.
- `LMultiLevelGrid:pickScreenFromAdapter(sx, sy, params, wallTextures?, adapter) -> table`: Resolves a screen-space click against this multilevel world using a runtime scene adapter.
- `LMultiLevelGrid:setActiveLevel(level) -> nil`: Sets the currently active level index used for stacked camera height.
- `LMultiLevelGrid:setCeilingHole(x, y, hole) -> nil`: Sets whether an active-level cell is open to the level above.
- `LMultiLevelGrid:setCell(x, y, val) -> nil`: Sets the wall type value at a grid cell on the active level. Non-zero values are solid walls.
- `LMultiLevelGrid:setDoorCell(x, y, direction, openAmount, alpha?) -> nil`: Attaches a sliding door feature to a blocking cell on the active level.
- `LMultiLevelGrid:setFloorHole(x, y, hole) -> nil`: Sets whether an active-level cell is open to the level below.
- `LMultiLevelGrid:setHalfWallCell(x, y, height) -> nil`: Attaches a half-height wall feature to a blocking cell on the active level.
- `LMultiLevelGrid:setWindowCell(x, y, sillHeight, lintelHeight, alpha?) -> nil`: Attaches a window feature to a blocking cell on the active level, leaving a visible opening between sill and lintel.
- `LMultiLevelGrid:type() -> string`: Returns the type name of this object ("LMultiLevelGrid").
- `LMultiLevelGrid:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LPointLight Type

- Lua-visible point light that illuminates nearby raycaster tiles and sprites with colored light and falloff.

##### Fields

- No documented fields.

##### Methods

- `LPointLight:color() -> number`: Returns the RGB color components of this light.
- `LPointLight:intensity() -> number`: Returns the brightness multiplier of this light.
- `LPointLight:level() -> integer`: Returns the optional multilevel slice index that owns this light.
- `LPointLight:radius() -> number`: Returns the light's falloff radius in world units.
- `LPointLight:set(x, y, r, g, b, radius, intensity, level?) -> nil`: Overwrites all properties of this point light in a single call.
- `LPointLight:setLevel(level?) -> nil`: Updates the optional multilevel slice index that owns this light.
- `LPointLight:type() -> string`: Returns the type name of this object ("LPointLight").
- `LPointLight:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LPointLight:x() -> number`: Returns the X world position of this light.
- `LPointLight:y() -> number`: Returns the Y world position of this light.

#### LSceneAdapter Type

- Lua-visible adapter that snapshots sprites, lights, and models from static data and physics bodies.

##### Fields

- No documented fields.

##### Methods

- `LSceneAdapter:addDirectionalSprite(x, y, front, right, back, left?, opts?) -> nil`: Adds a static directional billboard sprite entry.
- `LSceneAdapter:addLight(x, y, radius, opts?) -> nil`: Adds a static point light entry.
- `LSceneAdapter:addModel(model, x, y, opts?) -> nil`: Adds a static OBJ model instance entry.
- `LSceneAdapter:addSprite(x, y, texture, opts?) -> nil`: Adds a static billboard sprite entry.
- `LSceneAdapter:bindBodyDirectionalSprite(body, front, right, back, left?, opts?) -> nil`: Binds a directional billboard sprite to a live physics body.
- `LSceneAdapter:bindBodyLight(body, radius, opts?) -> nil`: Binds a point light to a live physics body.
- `LSceneAdapter:bindBodyModel(body, model, opts?) -> nil`: Binds an OBJ model instance to a live physics body.
- `LSceneAdapter:bindBodySprite(body, texture, opts?) -> nil`: Binds a billboard sprite to a live physics body.
- `LSceneAdapter:clear() -> nil`: Removes every tracked entry from the adapter.
- `LSceneAdapter:clearLights() -> nil`: Removes every tracked light entry from the adapter.
- `LSceneAdapter:clearModels() -> nil`: Removes every tracked model entry from the adapter.
- `LSceneAdapter:clearSprites() -> nil`: Removes every tracked sprite entry from the adapter.
- `LSceneAdapter:sceneInputs() -> table`: Resolves the current runtime snapshot into `{ lights, sprites, models }` tables.
- `LSceneAdapter:type() -> string`: Returns the type name of this object ("LSceneAdapter").
- `LSceneAdapter:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LRaycaster Type

- Lua-visible raycaster map that holds cell data, per-cell textures, and provides raycasting,.

##### Fields

- No documented fields.

##### Methods

- `LRaycaster:applyDoorManager(doors, alpha?) -> nil`: Synchronizes animated doors from an `LDoorManager` into this map's per-cell wall features.
- `LRaycaster:buildMinimapWindow(centerX, centerY, radius, ambient, lights?) -> table`: Generates a grid of minimap tile samples around a center point with lighting info.
- `LRaycaster:buildScene(params, lights?, sprites?, wallTextures?) -> integer`: Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.
- `LRaycaster:buildSceneFromAdapter(params, adapter, wallTextures?) -> integer`: Builds a textured raycaster scene from a runtime scene adapter that may follow physics bodies.
- `LRaycaster:buildSceneWithModels(params, lights?, sprites?, wallTextures?, models?) -> integer`: Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.
- `LRaycaster:castFloorRow(camX, camY, dirX, dirY, planeX, planeY, row) -> table`: Computes floor/ceiling texture UV coordinates for a single scanline row.
- `LRaycaster:castRay(ox, oy, angle, maxDist) -> table`: Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.
- `LRaycaster:castRayMulti(ox, oy, angle, maxDist, maxHits?) -> table`: Casts a single ray that passes through transparent walls, returning multiple hits.
- `LRaycaster:castRays(ox, oy, angle, fov, count, maxDist) -> table`: Casts multiple rays across a field of view and returns an array of hit tables.
- `LRaycaster:castRaysFlat(ox, oy, angle, fov, count, maxDist) -> number[]`: Casts multiple rays and returns only the corrected distances as a flat array.
- `LRaycaster:clearWallFeatureCell(x, y) -> nil`: Removes any per-cell wall feature override from a blocking cell.
- `LRaycaster:computeTileLight(x, y, ambient, lights?) -> number`: Computes the combined lighting color at a tile from ambient and point lights, accounting for walls.
- `LRaycaster:drawCameraSweep(x, y, fov, maxDist, numFrames, fw, fh) -> LImageData`: Renders multiple frames of a rotating camera sweep as a single combined image.
- `LRaycaster:drawDepthMap(px, py, angle, fov, numRays, w, h, maxDist) -> LImageData`: Renders a grayscale depth map showing distance-to-wall for each column.
- `LRaycaster:drawLineOfSight(ax, ay, bx, by, scale) -> LImageData`: Renders a debug image showing the line-of-sight ray between two world points.
- `LRaycaster:drawTopDown(px, py, angle, scale) -> LImageData`: Renders a top-down debug view of the map with the player's position and direction.
- `LRaycaster:drawView(px, py, angle, fov, w, h, maxDist) -> LImageData`: Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).
- `LRaycaster:extractMinimap(playerX, playerY, playerAngle, viewRadius, cellSize) -> LImageData`: Extracts a pixel minimap image centered on the player from this raycaster map.
- `LRaycaster:getCeilingTextureCell(x, y) -> integer`: Returns the raw texture id assigned to this ceiling cell, or nil if none.
- `LRaycaster:getCell(x, y) -> integer`: Returns the wall type value at a grid cell.
- `LRaycaster:getFloorTextureCell(x, y) -> integer`: Returns the raw texture id assigned to this floor cell, or nil if none.
- `LRaycaster:getLoweredFloorCell(x, y) -> table`: Returns the lowered floor configuration at a cell, or nil if the cell is normal.
- `LRaycaster:getWallAlpha(tileType) -> number`: Returns the current transparency value for a wall tile type.
- `LRaycaster:getWallFeatureCell(x, y) -> table`: Returns the wall feature attached to a cell, or nil when none is set.
- `LRaycaster:gridMove(px, py, dir, action, step) -> number`: Performs a discrete grid-step movement in one of 4 cardinal directions with collision.
- `LRaycaster:height() -> integer`: Returns the map height in grid cells.
- `LRaycaster:isBlocked(x, y) -> boolean`: Returns true if the grid cell is a solid wall (non-zero value).
- `LRaycaster:isWalkBlocked(x, y) -> boolean`: Returns true if the cell blocks walking (solid wall OR blocked lowered-floor cell).
- `LRaycaster:lineOfSight(x1, y1, x2, y2) -> boolean`: Tests whether there is a clear line of sight between two world points (no walls in between).
- `LRaycaster:pickScreen(sx, sy, params, sprites?, models?) -> table`: Resolves a screen-space click back into the raycaster world using the same camera semantics as scene building.
- `LRaycaster:pickScreenFromAdapter(sx, sy, params, adapter) -> table`: Resolves a screen-space click using sprite/model inputs sourced from a runtime scene adapter.
- `LRaycaster:projectSprite(sx, sy, px, py, pa, fov, screenW) -> table`: Projects a world-space sprite to screen coordinates for billboard rendering.
- `LRaycaster:revealCellsFromRays(ox, oy, angle, fov, count, maxDist, step?) -> table`: Casts rays across the FOV and returns a list of grid cells that are visible (for fog-of-war).
- `LRaycaster:setCeilingTextureCell(x, y, texture?) -> nil`: Assigns a per-cell ceiling texture override. Pass nil to remove the override.
- `LRaycaster:setCell(x, y, val) -> nil`: Sets the wall type value at a grid cell. Non-zero values are solid walls.
- `LRaycaster:setCells(cells) -> nil`: Replaces the entire map grid with a flat array of cell values (row-major order).
- `LRaycaster:setDoorCell(x, y, direction, openAmount, alpha?) -> nil`: Attaches a sliding door feature to a blocking cell.
- `LRaycaster:setFloorTextureCell(x, y, texture?) -> nil`: Assigns a per-cell floor texture override. Pass nil to remove the override.
- `LRaycaster:setHalfWallCell(x, y, height) -> nil`: Attaches a half-height wall feature to a blocking cell.
- `LRaycaster:setLoweredFloorCell(x, y, opts?) -> nil`: Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LRaycaster:setWallAlpha(tileType, alpha) -> nil`: Sets the transparency for a specific wall tile type, enabling see-through walls.
- `LRaycaster:setWindowCell(x, y, sillHeight, lintelHeight, alpha?) -> nil`: Attaches a window feature to a blocking cell, leaving a visible opening between sill and lintel.
- `LRaycaster:tryMove(px, py, dx, dy) -> number`: Attempts to move from (px,py) by (dx,dy) with wall-slide collision. Returns the final position.
- `LRaycaster:type() -> string`: Returns the type name of this object ("LRaycaster").
- `LRaycaster:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LRaycaster:width() -> integer`: Returns the map width in grid cells.

#### LRaycasterBuildMinimapWindowResult Type

- Generated result shape from @field tags.

##### Fields

- `b` (`number`): B.
- `blocked` (`boolean`): Blocked.
- `g` (`number`): G.
- `luma` (`number`): Luma.
- `r` (`number`): R.
- `visible` (`boolean`): Visible.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LRaycasterCastFloorRowResult Type

- Generated result shape from @field tags.

##### Fields

- `u` (`number`): U.
- `v` (`number`): V.

##### Methods

- No documented methods.

#### LRaycasterCastRayMultiResult Type

- Generated result shape from @field tags.

##### Fields

- `alpha` (`number`): Sub-cell hit position.
- `cell_value` (`integer`): Cell value hit.
- `distance` (`number`): Corrected perpendicular distance.
- `hit` (`boolean`): True if ray hit a wall.
- `hit_x` (`number`): World hit x.
- `hit_y` (`number`): World hit y.
- `raw_distance` (`number`): Uncorrected ray distance.
- `side` (`integer`): Wall side (0=x, 1=y).
- `tex_u` (`number`): Texture u coordinate.

##### Methods

- No documented methods.

#### LRaycasterCastRayResult Type

- Generated result shape from @field tags.

##### Fields

- `alpha` (`number`): Alpha.
- `cell_value` (`integer`): Cell value at hit.
- `distance` (`number`): Distance.
- `hit` (`boolean`): Hit.
- `hit_x` (`number`): Hit X position.
- `hit_y` (`number`): Hit Y position.
- `raw_distance` (`number`): Raw distance before correction.
- `side` (`integer`): Side index.
- `tex_u` (`number`): Texture U coordinate.

##### Methods

- No documented methods.

#### LRaycasterCastRaysResult Type

- Generated result shape from @field tags.

##### Fields

- `alpha` (`number`): Sub-cell hit position.
- `cell_value` (`integer`): Cell value hit.
- `distance` (`number`): Corrected perpendicular distance.
- `hit` (`boolean`): True if ray hit a wall.
- `hit_x` (`number`): World hit x.
- `hit_y` (`number`): World hit y.
- `raw_distance` (`number`): Uncorrected ray distance.
- `side` (`integer`): Wall side (0=x, 1=y).
- `tex_u` (`number`): Texture u coordinate.

##### Methods

- No documented methods.

#### LRaycasterGetLoweredFloorCellResult Type

- Generated result shape from @field tags.

##### Fields

- `b` (`number`): Blue component.
- `blocked` (`boolean`): Blocked.
- `depth` (`number`): Floor depth.
- `g` (`number`): Green component.
- `r` (`number`): Red component.
- `texture` (`integer`): Texture id.

##### Methods

- No documented methods.

#### LRaycasterPickScreenResult Type

- Generated result shape from @field tags.

##### Fields

- `cell_value` (`integer`): Cell value at the picked tile.
- `distance` (`number`): Camera-space distance to the picked point.
- `hit_x` (`number`): World hit X.
- `hit_y` (`number`): World hit Y.
- `id` (`integer`): Optional caller-supplied entity id for sprite/model hits.
- `level` (`number`): Level index. For a single `LRaycaster` map this is always 0.
- `ray_angle` (`number`): Ray angle used to resolve this pick.
- `side` (`integer`): Wall side for wall hits only (0=x, 1=y).
- `surface` (`string`): "wall", "floor", "ceiling", "sprite", or "model".
- `texture` (`integer`): Raw floor/ceiling texture id when available.
- `u` (`number`): Surface U coordinate in 0.0..1.0.
- `v` (`number`): Surface V coordinate in 0.0..1.0.
- `x` (`number`): Grid X coordinate.
- `y` (`number`): Grid Y coordinate.

##### Methods

- No documented methods.

#### LRaycasterProjectSpriteResult Type

- Generated result shape from @field tags.

##### Fields

- `distance` (`number`): Distance.
- `scale` (`number`): Scale.
- `screen_x` (`number`): Screen x.
- `visible` (`boolean`): Visible.

##### Methods

- No documented methods.

#### LRaycasterRevealCellsFromRaysResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteManager Type

- Lua-visible sprite manager that tracks world-space billboard sprites for sorting and projection.

##### Fields

- No documented fields.

##### Methods

- `LSpriteManager:add(x, y, texture, scale?, level?) -> integer`: Adds a new sprite to the manager at a world position with a texture label, raw id, or image handle.
- `LSpriteManager:addDirectional(x, y, front, right, back, left?, angle?, scale?, level?) -> integer`: Adds a new sprite with front/right/back/left textures and a world-facing angle.
- `LSpriteManager:clear() -> nil`: Removes all sprites from the manager.
- `LSpriteManager:remove(id) -> nil`: Removes a sprite by its id. This method is available to Lua scripts.
- `LSpriteManager:setDirectionalTextures(id, front, right, back, left?, angle?) -> nil`: Replaces the directional bitmap set for an existing sprite and optionally updates its facing angle.
- `LSpriteManager:setFacing(id, angle) -> nil`: Updates the facing angle of an existing directional sprite.
- `LSpriteManager:setLevel(id, level) -> nil`: Updates the multilevel slice index for an existing sprite.
- `LSpriteManager:setPosition(id, x, y) -> nil`: Updates the world position of an existing sprite.
- `LSpriteManager:setVisible(id, visible) -> nil`: Shows or hides a sprite without removing it.
- `LSpriteManager:sortAndProject(camX, camY, camAngle) -> integer[]`: Sorts all visible sprites by distance from the camera and returns projection data.
- `LSpriteManager:type() -> string`: Returns the type name of this object ("LSpriteManager").
- `LSpriteManager:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
