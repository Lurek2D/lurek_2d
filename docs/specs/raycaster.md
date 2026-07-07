<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/raycaster.md or source docstrings instead. -->

# raycaster

## TL;DR

- Simulates pseudo-3D first-person views from 2D maps using DDA marching.
- Supports transparent walls, variable heights, and multilevel storeys.
- Manages render-only wall features, multilevel space, and billboard sprites.
- Renders textured space from supplied scene input with depth buffers and pickers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/raycaster`
- Binding: `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`
- Lua API surface: `19` functions, `18` types, `126` methods
- User-facing: `true`
- Plugin tier: `tier_1_plugin`

## Summary

- The `raycaster` module is the engine's pseudo-3D first-person view system for users who want corridor shooters, dungeon crawlers, exploration views, or tactical previews built from structured 2D world data instead of from a full freeform 3D engine stack.
- Its technical base is DDA-style ray traversal over map-aligned space, but the important user-facing point is that the module turns that low-level technique into a complete first-person workflow with scene building, interaction helpers, lighting hooks, and deterministic output options.
- The module is valuable because it solves the interpretation layer between structured render input and a playable camera view. Users provide wall, floor, ceiling, sprite, model, and optional light tables, and `raycaster` decides how that data becomes depth, occlusion, visible openings, and first-person perspective.
- This matters most in projects that want first-person presence without the complexity of general 3D mesh authoring, continuous physics, and fully free camera semantics. The system stays constrained enough to be authorable and testable while still producing a convincing viewpoint.
- Variable heights, multilevel interpretation, partial blockers, and transparent or layered hits make the subsystem more than a toy single-plane corridor renderer. It can represent richer spaces where openings, stacked features, and elevation differences matter to play and readability.
- Door state and related wall-feature handling are render features. They affect ray obstruction, visible openings, picking, and scene comprehension, while gameplay movement, vision, action, and tile-lighting semantics live in `tilefield`, `awareness`, and `tilelight`.
- Floors and ceilings are part of the same contract rather than optional garnish, since convincing pseudo-3D scenes need more than wall columns to read as spaces.
- Billboard sprites keep moving actors, pickups, props, projectiles, and markers inside the same depth model as the wall renderer, which avoids a separate mismatched pseudo-3D object layer.
- Depth-aware ordering and visibility rules are therefore core capabilities. When wall features, sprites, and translucent elements overlap, the module owns what is actually visible and in what order.
- Render-light hooks and picking support make the subsystem useful for final rendering and tooling.
- Gameplay visibility, action lines, movement blockers, point tile-light, and global top-light are outside this module.
- Scene assembly is one of the biggest practical wins for users: walls, floors, ceilings, sprites, and optional inserted content are composed through one coherent first-person pipeline instead of several subsystems guessing at perspective differently.
- Projects that need movement or reachability should use `pathfind` with `tilefield` adapters and feed the resulting camera/world state back into raycaster as render input.
- Deterministic preview and software-capture paths matter because raycasted scenes often need screenshots, regression checks, editor thumbnails, or evidence artifacts outside live play.
- Because the module owns projection and picking, first-person tools can inspect what the renderer hit without becoming gameplay authorities.
- The result is a feature that serves both play and inspection. The same projection model can support a shipped first-person game, a level preview tool, or a visibility-debug workflow without changing how world interpretation works.
- This combination of constrained world model and rich view helpers is what gives the subsystem its identity: it provides first-person readability without giving up the structural advantages of a map-driven engine.
- From a boundary perspective, world/gameplay modules define semantics and `render` draws final commands, while `raycaster` owns how structured render input becomes a first-person readable visual field with depth, occlusion, and object placement.
- Read `raycaster` as the engine authority for grid-based first-person projection and scene composition.

This module primarily collaborates with `color`, `image`, `math`, `physics`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/raycaster`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_1_plugin`
- Lua binding owner: `src/lua_api/raycaster_api.rs`
- Referenced engine modules: `color`, `image`, `math`, `physics`, `render`, `runtime`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### build_scene/floors.rs

- Owns the raycaster build scene floors implementation for the raycaster subsystem and keeps rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster build scene floors data is validated, transformed, or stored before systems consume it.
- Separates raycaster build scene floors behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster build scene floors defaults, lifecycle handling, validation, or data rules.
- Keeps failure paths and edge cases near raycaster build scene floors state that explains them instead of outward.
- Preserves deterministic behavior by keeping raycaster build scene floors calculations at their owning boundary.

### build_scene/pipeline.rs

- Owns the raycaster build scene pipeline implementation for the raycaster subsystem and keeps rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster build scene pipeline data is validated, transformed, or stored before systems consume it.
- Separates raycaster build scene pipeline behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster build scene pipeline defaults, lifecycle handling, validation, or data rules.
- Keeps failure paths and edge cases near raycaster build scene pipeline state that explains them instead of outward.

### build_scene/sprites.rs

- Owns the raycaster build scene sprites implementation for the raycaster subsystem and keeps rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster build scene sprites data is validated, transformed, or stored before systems consume it.
- Separates raycaster build scene sprites behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster build scene sprites defaults, lifecycle handling, validation, or data rules.

### build_scene/walls.rs

- Owns the raycaster build scene walls implementation for the raycaster subsystem and keeps rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster build scene walls data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster build scene walls behavior from Lua bindings, tests, and sibling owners so integration readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster build scene walls defaults, lifecycle handling, validation, or data rules.
- Keeps failure paths and edge cases near raycaster build scene walls state that explains them instead of outward.
- Preserves deterministic behavior by keeping raycaster build scene walls calculations at their owning subsystem boundary.
- Provides layer that lets callers reuse raycaster build scene walls rules without duplicating engine decisions.

### build_scene.rs

- Owns the raycaster build scene implementation for the raycaster subsystem and keeps related runtime rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster build scene data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster build scene behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster build scene defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near raycaster build scene state that explains them instead of spreading outward.
- Preserves deterministic behavior by keeping raycaster build scene calculations at their owning subsystem boundary.

### column_batch.rs

- This file owns `ColumnData` and `ColumnBatch`, the compact per-column output buffer before scene assembly.
- It stores wall slice spans, texture coordinate, shade, cell value, depth, screen size, and flat fill colors.
- Helpers initialize frame-sized buffers, write one column, or unpack packed DDA float arrays into stable records.
- Downstream render paths can reuse one batch as a complete wall pass without rederiving projection or shading.
- Open this file when per-column buffer shape changes; DDA casting and scene translation live in sibling owners.

### contract.rs

- Owns the raycaster contract implementation for the raycaster subsystem and keeps related runtime rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster contract data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster contract behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster contract defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near raycaster contract state that explains them instead of spreading rules outward.

### dda.rs

- This file owns `Raycaster2D`, the grid-backed DDA engine that stores wall cells and answers render ray queries.
- It stores map dimensions, row-major cells, wall alpha overrides, wall features, and synchronized door feature state.
- Core casting methods produce single hits, layered transparent hits, fan casts, and packed ray buffers from one model.
- Render visibility helpers reuse the same blocking rules so lighting and screen picking stay aligned with rendering.
- Door synchronization translates `DoorManager` openness into wall features without replacing underlying tile identity.
- Sprite and floor helpers project billboards and sample floor rows with the same camera conventions as wall casting.
- Safe setters ignore invalid writes, and out-of-range reads fall back predictably for tools and runtime probes.
- Pick attributes also live with the grid here so wall, floor, and ceiling metadata follow the owning cell surface.
- Screen picking and scene builders read this owner when they need tile semantics beyond the raw numeric cell value.
- Open this file when marching semantics or map-owned ray data change; debug views and scene building live in siblings.

### depth_buffer.rs

- This file owns `DepthBuffer`, the per-column wall-depth memory used to hide sprites behind geometry.
- It stores one depth per screen column and exposes clear, set, get, and visibility checks for each frame.
- Open this file when occlusion buffering changes; wall casting and sprite projection stay in sibling owners.

### doors.rs

- This file owns `DoorDirection`, `DoorState`, `Door`, and `DoorManager` for animated doors in map cells.
- It stores grid position, open amount, speed, slide axis, and phase state so doors evolve without retagging tiles.
- Manager helpers add doors, switch them between opening and closing, advance animation, and query doors by tile.
- Rendering and collision code can read one shared door registry, keeping passage state consistent across subsystems.
- Open this file when door lifecycle semantics change; wall descriptors and scene construction stay in siblings.

### draw.rs

- Owns the raycaster draw implementation for the raycaster subsystem and keeps related runtime rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster draw data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster draw behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster draw defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the raycaster draw state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping raycaster draw calculations explicit at their owning subsystem boundary.
- Provides the local adaptation layer that lets callers reuse raycaster draw rules without duplicating engine decisions.

### heightmap.rs

- This file owns `HeightMap`, the per-tile floor and ceiling override store for stepped raycaster spaces.
- It stores map dimensions plus floor and ceiling arrays, then serves stable reads with ignored bad writes.
- Helpers set individual cells or rectangles so authored tools and procedural passes share one height model.
- Open this file when per-tile height semantics change; scene building and level rendering stay in siblings.

### level_render.rs

- This file owns hole-visibility helpers and rendering config for stacked raycaster levels with openings.
- It defines `TileHighlight` and `LevelRenderConfig`, then computes which holed cells stay visible from camera.
- The visibility pass filters floor openings by distance so adjacent levels can render through holes efficiently.
- These types support software column rendering paths where above and below slices need per-cell decisions.
- Open this file when multi-level reveal rules change; generic ray hits and projection math belong to siblings.

### lighting.rs

- Owns render-only light samples used while raycaster turns structured scene input into shaded geometry.
- Stores screen-facing point light positions, optional level ownership, radius, intensity, and color inputs.
- Tests render occlusion through wall geometry for shading, not gameplay sight, action, or tile-light queries.
- Applies ambient, point, and directional tint values to walls, floors, sprites, and multilevel render slices.
- Change this file for first-person shading; tilefield owns gameplay light propagation and exported volumes.

### mod.rs

- This module re-exports the raycaster subsystem surface for casting, scene building, lighting, doors, and rendering.
- It keeps navigation explicit by mapping which sibling files own DDA marching, column batches, height data, and adapters.
- Public exports here route callers toward `Raycaster2D` for casting and scene types for prepared first-person output.
- `projection.rs`, `depth_buffer.rs`, and `sprite_projection.rs` own screen-space math and occlusion data.
- `doors.rs`, `wall_feature.rs`, and `heightmap.rs` hold cell state that changes how blocking tiles render.
- `build_scene.rs`, `draw.rs`, and `render.rs` translate ray hits into either CPU pixels or engine render commands.
- Visibility-polygon, segment, and picking helpers stay render-facing and do not own tile gameplay semantics.
- Reexports also expose pick-world context so cursor integrations can inspect the last prepared raycaster scene.
- Open sibling owners instead of this index when changing multilevel data, scene records, or screen-pick payloads.
- Change this file when the public raycaster symbol map moves; change siblings when behavior or data rules change.

### multilevel.rs

- This file owns `RaycasterLevel` and `MultiLevelGrid`, the stacked-slice model for multi-storey raycaster worlds.
- It stores per-level walls, wall features, texture overrides, lowered floors, holes, vertical bounds, and caches.
- Level helpers read or mutate wall, floor, ceiling, and hole data while rejecting out-of-bounds writes safely.
- The runtime builder compiles a transient `Raycaster2D` view from level-owned cells for rendering and picking.
- `MultiLevelGrid` tracks the active slice, caches compiled runtimes, and resolves visible lower or upper levels.
- Floor and ceiling holes decide which adjacent slices are visible to render and picking queries.
- Pick attrs stay level-owned here so cursor rules can vary by wall, floor, and ceiling across stacked slices.
- Open this file when stacked-level data or cross-level visibility changes; scene assembly lives in siblings.

### projection.rs

- Owns the raycaster projection implementation for the raycaster subsystem and keeps related runtime rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster projection data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster projection behavior from Lua bindings, tests, and sibling owners so integration stays readable.

### ray_hit.rs

- This file owns `RayHit`, the per-ray result record produced when DDA traversal reaches visible geometry.
- It stores corrected distance, raw distance, tile value, face side, texture coordinate, alpha, and hit point.
- Open this file when ray-hit payload shape changes; projection math and scene construction live in siblings.

### render.rs

- Owns the raycaster render implementation for the raycaster subsystem and keeps related runtime rules local here.
- Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
- Defines how raycaster render data is validated, transformed, or stored before neighboring systems consume it.
- Separates raycaster render behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing raycaster render defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near raycaster render state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping raycaster render calculations explicit at their owning subsystem boundary.

### scene.rs

- This file owns `RaycasterScene` and its quad, sprite, mesh, pick, and build-stat record types for one frame.
- It stores walls, floors, ceilings, billboard sprites, transient models, viewport size, and build counters.
- Quad records carry corners, UVs, texture routing, light tint, depth, and perspective data for later draw paths.
- Picking helpers resolve screen pixels against projected sprites and model triangles, with optional sprite alpha tests.
- `EntityPickResult` and related enums define the stable payload returned when higher layers query scene selections.
- This file is the staging boundary between raycaster world reasoning and renderer or CPU draw translation.
- Cursor integrations read attrs, ids, and hit kinds from these scene records without needing access to source grids.
- Open this file when prepared-scene data or picking semantics change; build and render flow live in siblings.

### scene_adapter.rs

- This file owns transform adapters that turn static entries or live physics bodies into scene-facing raycaster inputs.
- It stores `SceneTransform` sources plus resolved sprite, light, and optional model bindings sampled each frame.
- Body-backed transforms apply local offsets and angle offsets so pseudo-3D attachments stay aligned with physics owners.
- `SceneAdapter` aggregates bindings, clears tracked groups, and resolves live entries into world sprite or light data.
- The adapter keeps external entity ownership outside the raycaster while it consumes one normalized input surface.
- This file is the boundary between physics or runtime state and the scene builder's input contracts.
- Open this file when source-to-scene adaptation changes; prepared geometry and lighting evaluation live in siblings.

### segment.rs

- This file owns `Segment` and `cast_ray_2d`, the explicit line-geometry helper for non-grid ray queries.
- It stores endpoint pairs and finds the nearest segment hit along a ray within a caller-supplied limit.
- Open this file when segment-cast semantics change; visibility polygons and DDA traversal live in siblings.

### sprite_manager.rs

- This file owns `DirectionalSpriteTextures`, `WorldSprite`, and `SpriteManager`, the billboard sprite registry.
- It stores sprite identity, world position, texture choice, directional variants, scale, and visibility in one owner.
- Directional texture selection compares viewer angle to facing so billboards can swap front, side, or back art.
- Manager helpers add, remove, move, retarget, hide, clear, and distance-sort visible sprites for camera use.
- The registry keeps dynamic object presentation separate from wall cells while matching the raycaster depth pipeline.
- Open this file when billboard registry or facing-selection semantics change; scene projection stays elsewhere.

### sprite_projection.rs

- This file owns `SpriteProjection`, the screen-space result record produced for one raycaster billboard sprite.
- It stores screen x, uniform scale, camera distance, and visibility so later draw code can sort and clip safely.
- Open this file when billboard projection payload changes; projection math and sprite drawing live in siblings.

### tile_picker.rs

- This file owns screen-to-world picking for the raycaster, mapping a pixel back onto wall, floor, or ceiling space.
- It defines `PickSurface`, `PickWallSection`, `ScreenPickParams`, `TilePicker`, and `PickResult` payloads.
- `TilePicker` keeps camera pose, screen size, grid size, and tile scale for repeated first-person selection queries.
- Helper math derives ray angle, corrected distance, horizon, projection depth, and plane intersections from the camera.
- Wall picking reuses DDA stepping so hit ordering matches the same traversal semantics used for rendering and visibility.
- Feature-aware logic distinguishes half-height walls, window bands, and door panels, returning the hit solid section.
- Floor and ceiling picking projects the pixel onto horizontal planes and rejects cells hidden by closer walls or holes.
- `Raycaster2D::pick_screen` resolves single-level maps, while `MultiLevelGrid::pick_screen` chooses the owning slice.
- This file is the boundary between first-person UI input and render-space selection on grid or multilevel data.
- Open this file when selection payloads or pick precedence change; scene building and ray hits live in siblings.

### visibility.rs

- This file owns `field_of_view`, the radial visibility-polygon builder that casts around segment endpoints.
- It samples slight angular offsets, reuses segment casting, and returns points ready for drawing or masking.
- Open this file when 2D visibility contour generation changes; segment hits and grid raycasting live in siblings.

### visualization.rs

- This file owns software diagnostic views that render raycaster internals directly into `ImageData` buffers.
- It attaches debug rendering methods to `Raycaster2D` for top-down maps, wall bands, depth views, and sight traces.
- Helpers reuse live ray casts and line-of-sight logic so visual evidence matches the subsystem's marching behavior.
- Camera sweep and textured preview outputs let tools inspect sampling and material interpretation without the renderer.
- Procedural colouring stays local here so explanations remain readable even when authored textures are unavailable.
- The outputs live in plain image memory, making them easy to save, diff, or embed inside editor and UI overlays.
- Open this file when debug-view semantics change; core casting and scene assembly live in sibling owners.

### wall_feature.rs

- This file owns `WallFeatureKind` and `WallFeature`, the cell-local descriptors for wall behavior refinement.
- It models half-height walls, window openings, and sliding doors without changing the base tile map schema.
- Constructors clamp feature parameters into safe ranges so tools and scene builders share stable semantics.
- Query helpers answer render ray and render light blocking from the same payload used by rendering code.
- Open this file when per-cell wall behavior changes; door state progression and scene assembly live in siblings.



## Lua API Ref

### Functions

- `lurek.raycaster.applyLitShade(baseShade, r, g, b) -> number`: Applies an RGB light color to a scalar shade value.
- `lurek.raycaster.buildMultiLevelScene(params, levels, lights?, sprites?, wallTextures?, models?) -> integer`: Builds a multilevel raycaster scene from a stack of plain Lua level tables.
- `lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, wallTextures?) -> integer`: Builds a multilevel raycaster scene from a stack of plain Lua level tables using a runtime scene adapter.
- `lurek.raycaster.buildMultiLevelSceneFromField(params, field, opts?, lights?, sprites?, wallTextures?) -> integer`: Builds a multilevel raycaster scene from tilefield blockers, slots, holes, surfaces, and tile light emitters.
- `lurek.raycaster.distanceShade(distance, maxDistance) -> number`: Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
- `lurek.raycaster.drawLastScene(width, height) -> LImageData`: Rasterizes the most recently built raycaster scene to raw image data.
- `lurek.raycaster.getLastBuildStats() -> table`: Returns stats for the last stored raycaster scene build.
- `lurek.raycaster.getShader() -> LShader`: Returns the draw-target shader applied to the stored raycaster scene, or nil when default rendering is used.
- `lurek.raycaster.new(w, h) -> LRaycaster`: Creates a new raycaster map with the given grid dimensions.
- `lurek.raycaster.newDoorManager() -> LDoorManager`: Creates a new door manager for tracking and animating sliding doors.
- `lurek.raycaster.newHeightMap(w, h) -> LHeightMap`: Creates a new height map for variable floor/ceiling heights across the grid.
- `lurek.raycaster.newMap(w, h) -> LRaycaster`: Creates a new raycaster map (alias for `new`).
- `lurek.raycaster.newMultiLevelGrid(levels?) -> LMultiLevelGrid`: Creates a persistent multi-level raycaster world from plain Lua level tables or as an empty container.
- `lurek.raycaster.newSceneAdapter() -> LSceneAdapter`: Creates a runtime adapter for sprites, lights, and models that can follow physics bodies.
- `lurek.raycaster.newSpriteManager() -> LSpriteManager`: Creates a new sprite manager for tracking and projecting billboard sprites.
- `lurek.raycaster.pickScreenMultiLevel(sx, sy, params, levels, wallTextures?, sprites?, models?) -> table`: Resolves a screen-space click against a stack of plain Lua level tables and returns the owning level.
- `lurek.raycaster.pickScreenMultiLevelFromAdapter(sx, sy, params, levels, wallTextures?, adapter) -> table`: Resolves a screen-space click against a stack of plain Lua level tables using a runtime scene adapter.
- `lurek.raycaster.projectColumn(distance, fov, screenHeight) -> number`: Computes the projected wall-column height for a given distance, FOV, and screen height.
- `lurek.raycaster.setShader(shader?) -> nil`: Binds a draw-target shader to the most recently built raycaster scene when it is presented by the renderer. Pass nil to clear.

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
- `LMultiLevelGrid:clearPickAttr(x, y, surface, key?) -> nil`: Clears one arbitrary pick attribute or the whole surface channel from one active-level cell.
- `LMultiLevelGrid:clearWallFeatureCell(x, y) -> nil`: Removes any per-cell wall feature override from the active level.
- `LMultiLevelGrid:getCeilingHeight() -> number`: Returns the ceiling height of the active level in world units.
- `LMultiLevelGrid:getCeilingTexture() -> integer`: Returns the default ceiling texture id used by the active level, or nil when none is set.
- `LMultiLevelGrid:getCeilingTextureCell(x, y) -> integer`: Returns the per-cell ceiling texture id assigned on the active level, or nil if none is set.
- `LMultiLevelGrid:getCell(x, y) -> integer`: Returns the wall type value at a grid cell on the active level.
- `LMultiLevelGrid:getFloorOffset() -> number`: Returns the floor height offset of the active level in world units.
- `LMultiLevelGrid:getFloorTexture() -> integer`: Returns the default floor texture id used by the active level, or nil when none is set.
- `LMultiLevelGrid:getFloorTextureCell(x, y) -> integer`: Returns the per-cell floor texture id assigned on the active level, or nil if none is set.
- `LMultiLevelGrid:getLoweredFloorCell(x, y) -> table`: Returns the lowered-floor configuration at an active-level cell, or nil if the cell is normal.
- `LMultiLevelGrid:getPickAttr(x, y, surface, key) -> nil`: Reads one arbitrary pick attribute from one active-level surface cell.
- `LMultiLevelGrid:getWallFeatureCell(x, y) -> table`: Returns the wall feature attached to an active-level cell, or nil when none is set.
- `LMultiLevelGrid:isCeilingHole(x, y) -> boolean`: Returns true when an active-level cell is open to the level above.
- `LMultiLevelGrid:isFloorHole(x, y) -> boolean`: Returns true when an active-level cell is open to the level below.
- `LMultiLevelGrid:levelCount() -> integer`: Returns the total number of stored levels.
- `LMultiLevelGrid:pickScreen(sx, sy, params, wallTextures?, sprites?, models?) -> table`: Resolves a screen-space click against this persistent multi-level world and returns the owning level.
- `LMultiLevelGrid:pickScreenFromAdapter(sx, sy, params, wallTextures?, adapter) -> table`: Resolves a screen-space click against this multilevel world using a runtime scene adapter.
- `LMultiLevelGrid:setActiveLevel(level) -> nil`: Sets the currently active level index used for stacked camera height.
- `LMultiLevelGrid:setCeilingHeight(height) -> nil`: Sets the ceiling height of the active level in world units.
- `LMultiLevelGrid:setCeilingHole(x, y, hole) -> nil`: Sets whether an active-level cell is open to the level above.
- `LMultiLevelGrid:setCeilingTexture(texture?) -> nil`: Sets the default ceiling texture used by the active level. Pass nil to clear it.
- `LMultiLevelGrid:setCeilingTextureCell(x, y, texture?) -> nil`: Assigns a per-cell ceiling texture override on the active level. Pass nil to remove the override.
- `LMultiLevelGrid:setCell(x, y, val) -> nil`: Sets the wall type value at a grid cell on the active level. Non-zero values are solid walls.
- `LMultiLevelGrid:setFloorHole(x, y, hole) -> nil`: Sets whether an active-level cell is open to the level below.
- `LMultiLevelGrid:setFloorOffset(offset) -> nil`: Sets the floor height offset of the active level in world units.
- `LMultiLevelGrid:setFloorTexture(texture?) -> nil`: Sets the default floor texture used by the active level. Pass nil to clear it.
- `LMultiLevelGrid:setFloorTextureCell(x, y, texture?) -> nil`: Assigns a per-cell floor texture override on the active level. Pass nil to remove the override.
- `LMultiLevelGrid:setLoweredFloorCell(x, y, opts?) -> nil`: Marks an active-level cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LMultiLevelGrid:setPickAttr(x, y, surface, key, value) -> nil`: Sets one arbitrary pick attribute on one active-level surface cell.
- `LMultiLevelGrid:setWallFeatureCell(x, y, feature) -> nil`: Attaches a render-only wall feature descriptor to a blocking cell on the active level.
- `LMultiLevelGrid:type() -> string`: Returns the type name of this object ("LMultiLevelGrid").
- `LMultiLevelGrid:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMultiLevelGridGetWallFeatureCellResult Type

- Generated result shape from @field tags.

##### Fields

- `alpha` (`number`): Feature alpha/transparency override.
- `direction` (`string`): "horizontal" or "vertical" when `kind == "door"`.
- `height` (`number`): Half-wall height in cell units when `kind == "half"`.
- `kind` (`string`): "half", "window", or "door".
- `lintel_height` (`number`): Window lintel height when `kind == "window"`.
- `open_amount` (`number`): Door openness in 0.0..1.0 when `kind == "door"`.
- `sill_height` (`number`): Window sill height when `kind == "window"`.

##### Methods

- No documented methods.

#### LMultiLevelGridPickScreenResult Type

- Generated result shape from @field tags.

##### Fields

- `feature` (`table`): Optional wall feature table mirroring `getWallFeatureCell()` plus `section` for the solid band or door panel that was hit.
- `wall_height` (`number`): Local wall height in cell units for wall hits against partial-height features.

##### Methods

- No documented methods.

#### LRaycaster Type

- Lua-visible raycaster map that holds cell data, per-cell textures, and provides raycasting,.

##### Fields

- No documented fields.

##### Methods

- `LRaycaster:addParticleEmitter(emitter) -> nil`: Adds a projected raycaster particle emitter that spawns during scene builds.
- `LRaycaster:applyDoorManager(doors, alpha?) -> nil`: Synchronizes animated doors from an `LDoorManager` into this map's per-cell wall features.
- `LRaycaster:buildScene(params, lights?, sprites?, wallTextures?) -> integer`: Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.
- `LRaycaster:buildSceneFromAdapter(params, adapter, wallTextures?) -> integer`: Builds a textured raycaster scene from a runtime scene adapter that may follow physics bodies.
- `LRaycaster:buildSceneWithModels(params, lights?, sprites?, wallTextures?, models?) -> integer`: Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.
- `LRaycaster:castFloorRow(camX, camY, dirX, dirY, planeX, planeY, row, screenWidth?, screenHeight?) -> table`: Computes floor/ceiling texture UV coordinates for a single scanline row.
- `LRaycaster:castRay(ox, oy, angle, maxDist) -> table`: Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.
- `LRaycaster:castRayMulti(ox, oy, angle, maxDist, maxHits?) -> table`: Casts a single ray that passes through transparent walls, returning multiple hits.
- `LRaycaster:castRays(ox, oy, angle, fov, count, maxDist) -> table`: Casts multiple rays across a field of view and returns an array of hit tables.
- `LRaycaster:castRaysFlat(ox, oy, angle, fov, count, maxDist) -> number[]`: Casts multiple rays and returns only the corrected distances as a flat array.
- `LRaycaster:clearParticleEmitters() -> nil`: Removes all projected particle emitters from this map.
- `LRaycaster:clearPickAttr(x, y, surface, key?) -> nil`: Clears one arbitrary pick attribute or the whole channel from a raycaster surface cell.
- `LRaycaster:clearWallFeatureCell(x, y) -> nil`: Removes any per-cell wall feature override from a blocking cell.
- `LRaycaster:drawCameraSweep(x, y, fov, maxDist, numFrames, fw, fh) -> LImageData`: Renders multiple frames of a rotating camera sweep as a single combined image.
- `LRaycaster:drawDepthMap(px, py, angle, fov, numRays, w, h, maxDist) -> LImageData`: Renders a grayscale depth map showing distance-to-wall for each column.
- `LRaycaster:drawTopDown(px, py, angle, scale) -> LImageData`: Renders a top-down debug view of the map with the player's position and direction.
- `LRaycaster:drawView(px, py, angle, fov, w, h, maxDist) -> LImageData`: Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).
- `LRaycaster:getCeilingMaterialCell(x, y) -> table`: Returns the ceiling material override for one cell, or nil when none is set.
- `LRaycaster:getCeilingTextureCell(x, y) -> integer`: Returns the raw texture id assigned to this ceiling cell, or nil if none.
- `LRaycaster:getCell(x, y) -> integer`: Returns the wall type value at a grid cell.
- `LRaycaster:getFloorMaterialCell(x, y) -> table`: Returns the floor material override for one cell, or nil when none is set.
- `LRaycaster:getFloorTextureCell(x, y) -> integer`: Returns the raw texture id assigned to this floor cell, or nil if none.
- `LRaycaster:getLoweredFloorCell(x, y) -> table`: Returns the lowered floor configuration at a cell, or nil if the cell is normal.
- `LRaycaster:getPickAttr(x, y, surface, key) -> nil`: Reads one arbitrary pick attribute from a raycaster surface cell.
- `LRaycaster:getWallAlpha(tileType) -> number`: Returns the current transparency value for a wall tile type.
- `LRaycaster:getWallFeatureCell(x, y) -> table`: Returns the wall feature attached to a cell, or nil when none is set.
- `LRaycaster:getWallMaterial(cellValue) -> table`: Returns the material override for a wall tile type, or nil when none is set.
- `LRaycaster:height() -> integer`: Returns the map height in grid cells.
- `LRaycaster:isBlocked(x, y) -> boolean`: Returns true if the grid cell is a solid wall (non-zero value).
- `LRaycaster:pickScreen(sx, sy, params, sprites?, models?) -> table`: Resolves a screen-space click back into the raycaster world using the same camera semantics as scene building.
- `LRaycaster:pickScreenFromAdapter(sx, sy, params, adapter) -> table`: Resolves a screen-space click using sprite/model inputs sourced from a runtime scene adapter.
- `LRaycaster:projectSprite(sx, sy, px, py, pa, fov, screenW) -> table`: Projects a world-space sprite to screen coordinates for billboard rendering.
- `LRaycaster:setCeilingMaterialCell(x, y, material?) -> nil`: Assigns a render material override to one ceiling cell. Pass nil to clear.
- `LRaycaster:setCeilingTextureCell(x, y, texture?) -> nil`: Assigns a per-cell ceiling texture override. Pass nil to remove the override.
- `LRaycaster:setCell(x, y, val) -> nil`: Sets the wall type value at a grid cell. Non-zero values are solid walls.
- `LRaycaster:setCells(cells) -> nil`: Replaces the entire map grid with a flat array of cell values (row-major order).
- `LRaycaster:setFloorMaterialCell(x, y, material?) -> nil`: Assigns a render material override to one floor cell. Pass nil to clear.
- `LRaycaster:setFloorTextureCell(x, y, texture?) -> nil`: Assigns a per-cell floor texture override. Pass nil to remove the override.
- `LRaycaster:setLoweredFloorCell(x, y, opts?) -> nil`: Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LRaycaster:setPickAttr(x, y, surface, key, value) -> nil`: Sets one arbitrary pick attribute on a raycaster surface cell.
- `LRaycaster:setWallAlpha(tileType, alpha) -> nil`: Sets the transparency for a specific wall tile type, enabling see-through walls.
- `LRaycaster:setWallFeatureCell(x, y, feature) -> nil`: Attaches a render-only wall feature descriptor to a blocking cell.
- `LRaycaster:setWallMaterial(cellValue, material?) -> nil`: Assigns a render material override to a wall tile type. Pass nil to clear.
- `LRaycaster:type() -> string`: Returns the type name of this object ("LRaycaster").
- `LRaycaster:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LRaycaster:width() -> integer`: Returns the map width in grid cells.

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

#### LRaycasterGetLastBuildStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `ceilingQuads` (`integer`): Number of ceiling quads emitted during the last build.
- `depthColumns` (`integer`): Number of cached wall-depth columns available to overlays and picking.
- `floorQuads` (`integer`): Number of floor quads emitted during the last build.
- `lightingCacheHits` (`integer`): Number of reused lighting samples served from the per-build cache.
- `lightingCacheMisses` (`integer`): Number of unique lighting samples computed during the last build.
- `lightingSamples` (`integer`): Total lighting samples requested during the last build.
- `models` (`integer`): Number of projected model meshes emitted during the last build.
- `particles` (`integer`): Number of projected particle quads emitted during the last build.
- `sprites` (`integer`): Number of billboard sprites emitted during the last build.
- `visibleLevels` (`integer`): Number of multilevel slices traversed during the last build.
- `wallQuads` (`integer`): Number of wall quads emitted during the last build.

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

#### LRaycasterGetWallFeatureCellResult Type

- Generated result shape from @field tags.

##### Fields

- `alpha` (`number`): Feature alpha/transparency override.
- `direction` (`string`): "horizontal" or "vertical" when `kind == "door"`.
- `height` (`number`): Half-wall height in cell units when `kind == "half"`.
- `kind` (`string`): "half", "window", or "door".
- `lintel_height` (`number`): Window lintel height when `kind == "window"`.
- `open_amount` (`number`): Door openness in 0.0..1.0 when `kind == "door"`.
- `sill_height` (`number`): Window sill height when `kind == "window"`.

##### Methods

- No documented methods.

#### LRaycasterPickScreenResult Type

- Generated result shape from @field tags.

##### Fields

- `cell_value` (`integer`): Cell value at the picked tile.
- `distance` (`number`): Camera-space distance to the picked point.
- `feature` (`table`): Optional wall feature table mirroring `getWallFeatureCell()` plus `section` for the solid band or door panel that was hit.
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
- `wall_height` (`number`): Local wall height in cell units for wall hits against partial-height features.
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

#### LSceneAdapter Type

- Lua-visible adapter that snapshots sprites, lights, and models from static data and physics bodies.

##### Fields

- No documented fields.

##### Methods

- `LSceneAdapter:addDirectionalSprite(x, y, front, right, back, left?, opts?) -> nil`: Adds a static directional billboard sprite entry.
- `LSceneAdapter:addLight(x, y, radius, opts?) -> nil`: Adds a static point light entry to the adapter.
- `LSceneAdapter:addModel(model, x, y, opts?) -> nil`: Adds a static OBJ model instance entry.
- `LSceneAdapter:addSprite(x, y, texture, opts?) -> nil`: Adds a static billboard sprite entry.
- `LSceneAdapter:bindBodyDirectionalSprite(body, front, right, back, left?, opts?) -> nil`: Binds a directional billboard sprite to a live physics body.
- `LSceneAdapter:bindBodyLight(body, radius, opts?) -> nil`: Binds a point light to a live physics body.
- `LSceneAdapter:bindBodyModel(body, model, opts?) -> nil`: Binds an OBJ model instance to a live physics body.
- `LSceneAdapter:bindBodySprite(body, texture, opts?) -> nil`: Binds a billboard sprite to a live physics body.
- `LSceneAdapter:clear() -> nil`: Removes every tracked entry from the adapter.
- `LSceneAdapter:clearLights() -> nil`: Removes every tracked light entry from the adapter.
- `LSceneAdapter:clearModels() -> nil`: Clears all loaded model entries from the adapter.
- `LSceneAdapter:clearSprites() -> nil`: Removes every tracked sprite entry from the adapter.
- `LSceneAdapter:sceneInputs() -> table`: Resolves the current runtime snapshot into `{ lights, sprites, models }` tables.
- `LSceneAdapter:type() -> string`: Returns the type name of this object.
- `LSceneAdapter:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSpriteManager Type

- Lua-visible sprite manager that tracks world-space billboard sprites for sorting and projection.

##### Fields

- No documented fields.

##### Methods

- `LSpriteManager:add(x, y, texture, scale?, level?) -> integer`: Adds a new sprite to the manager at a world position with a texture label, raw id, or image handle.
- `LSpriteManager:addDirectional(x, y, front, right, back, left?, angle?, scale?, level?) -> integer`: Adds a new sprite with front/right/back/left textures and a world-facing angle.
- `LSpriteManager:clear() -> nil`: Removes all sprites from the manager.
- `LSpriteManager:clearAttr(id, key?) -> nil`: Clears one arbitrary string attribute or all attrs from the sprite.
- `LSpriteManager:getAttr(id, key) -> string?`: Reads one arbitrary string attribute from the sprite.
- `LSpriteManager:remove(id) -> nil`: Removes a sprite by its id. This method is available to Lua scripts.
- `LSpriteManager:setAttr(id, key, value) -> nil`: Sets one arbitrary string attribute on the sprite.
- `LSpriteManager:setDirectionalTextures(id, front, right, back, left?, angle?) -> nil`: Replaces the directional bitmap set for an existing sprite and optionally updates its facing angle.
- `LSpriteManager:setFacing(id, angle) -> nil`: Updates the facing angle of an existing directional sprite.
- `LSpriteManager:setLevel(id, level) -> nil`: Updates the multilevel slice index for an existing sprite.
- `LSpriteManager:setPosition(id, x, y) -> nil`: Updates the world position of an existing sprite.
- `LSpriteManager:setVisible(id, visible) -> nil`: Shows or hides a sprite without removing it.
- `LSpriteManager:sortAndProject(camX, camY, camAngle) -> integer[]`: Sorts all visible sprites by distance from the camera and returns projection data.
- `LSpriteManager:type() -> string`: Returns the type name of this object ("LSpriteManager").
- `LSpriteManager:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## Examples

- `content/examples/raycaster.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `raycaster` owns pseudo-3D projection, DDA-style rendering, wall/floor/ceiling composition, sprites, depth, picking, and render-facing scene assembly.
- Strict constructors and validators now guard map dimensions, flat cell-buffer sizes, FOV, screen size, max distance, and scene texture ids. Invalid public Lua input should fail at the boundary instead of silently keeping stale state.
- Checked Rust-only grid probes use `OutOfBoundsPolicy::{Open, Blocked, Stop}`. Legacy unchecked map reads still treat out-of-bounds as open space, but safety-sensitive owners should prefer the checked policy-aware helpers.
- `TilePicker::pick_tile` is expected to match the full `Raycaster2D` screen-volume picker. Screen Y must distinguish wall vs floor vs ceiling hits rather than returning a stub first-step cell.
- Wall features separate primary render-ray blocking from render visibility/light blocking. Windows stay open to visibility and lighting while doors block until mostly open; half walls still block primary wall hits but render shorter geometry.
- First-person scene geometry render commands are depth-sorted far-to-near before submission so nearer floor, wall, roof, lowered-floor side, sprite, particle, and model quads cover farther scene items.
- Built-scene entity picking is depth-aware. Billboard and model picks should be rejected when the wall depth column at the clicked screen X is nearer than the candidate entity.
- `LRaycaster:castFloorRow` keeps a legacy 7-argument form that samples by map dimensions, and also supports explicit `screenWidth`/`screenHeight` arguments for viewport-width per-pixel sampling.
- Scene params accept `ceiling_a`; use `ceiling_a = 0` when an untextured ceiling should be transparent open sky while textured ceiling cells should still render as roofs.
- `lurek.raycaster.getLastBuildStats()` should be treated as the public diagnostics surface for lighting cache counts, geometry counts, visible-level traversal, and cached wall-depth columns.
- Tile gameplay semantics such as movement blockers, vision blockers, action blockers, point tile-light, global sunlight, and window/door/half-wall profile behavior belong in `lurek.tilefield`.
- `raycaster` no longer exposes gameplay movement, line-of-sight, tile-light, or minimap-light helpers. Tile-based gameplay flows should build or export from `lurek.tilefield`, then pass render input to `raycaster`.
- `lurek.raycaster.buildMultiLevelSceneFromField(params, field, opts)` is the field-consuming bridge for generated multilevel render input. It can read `tilefield` blocker channels as a fallback, but the preferred structured path is to map named field slots such as `wallSlot`, `doorSlot`, `windowSlot`, `floorSlot`, `ceilingSlot`, `objectSlot`, `spriteSlot`, `floorHoleSlot`, and `ceilingHoleSlot` into raycaster walls, wall features, surface textures, billboard sprites, holes, and render-only point-light samples. Presentation slots such as `backgroundSlot`, `skyboxSlot`, and `overlaySlot` let typed map refs select first-person sky/background and full-frame effects like fog or snow without moving gameplay semantics into raycaster. When `opts.catalog` or `opts.tileCatalog` is an `LTileCatalog`, typed tilefield refs reuse `tileset` visuals, texture ids, and object properties instead of requiring duplicate raycaster-only material maps.
- `lurek.raycaster.setShader(shaderOrNil)` accepts only draw-target shaders created through `lurek.render.newShader`. The module stores a render-owned shader handle for the most recently built scene presentation path; it does not compile WGSL or own GPU pipeline state. Software exports such as `drawLastScene` remain CPU captures and do not execute the shader.
- Surface material overrides are map-owned data. `LRaycaster:setWallMaterial(cellValue, material)`, `setFloorMaterialCell(x, y, material)`, and `setCeilingMaterialCell(x, y, material)` let scripts bind per-surface textures, draw-target shaders, tint, blend mode, UV scroll/scale/offset, and atlas animation (`frame_count`, `frame_rate`, `frame_layout`) without moving shader compilation out of `render`.
- Scene params for `buildScene`, `buildMultiLevelScene`, and `LMultiLevelGrid:buildScene` now include `time_seconds`, `background`, and `overlays`. Shader backgrounds and shader overlays accept `overlay`, `postfx`, or `draw` targets, and raycaster forwards auto uniforms such as `ray_player_pos`, `ray_screen_size`, `ray_camera_angle`, `ray_fov`, `ray_horizon`, `ray_camera_height`, and `ray_max_distance`.
- Depth-aware fog is a first-class overlay mode. Use `{ type = "depth_fog", ... }` or `{ type = "fog", mode = "depth", ... }` when the effect should read per-column scene depth instead of only layering a flat fullscreen tint.
- `LRaycaster:addParticleEmitter(emitter)` spawns deterministic projected 2.5D particles during scene builds. Emitters can bind textures, `particle` shaders, blend modes, seeded jitter, and volumetric placement hints (`z`, `radius`, `height`) while still remaining raycaster scene data instead of direct render command ownership.
- `lurek.raycaster.drawLastScene(width, height)` is an evidence-oriented CPU fallback. It preserves base textures, tint, UV scrolling, frame-atlas animation, depth fog, and projected particle placement, but it does not execute WGSL for raycaster materials, shader backgrounds, or shader overlays.
- Raycaster picking now carries semantic metadata for cursor/runtime consumers. `pickScreen*` and multilevel pick helpers return stable `kind` strings plus optional `attrs` on wall, floor, ceiling, sprite, and model hits.
- `LRaycaster:setPickAttr/getPickAttr/clearPickAttr` and the matching `LMultiLevelGrid` methods store per-surface metadata on `wall`, `floor`, `ceiling`, or shared `any` channels so first-person surfaces can declare cursor states or effects without hardcoded Lua branching.
- `LSpriteManager:setAttr/getAttr/clearAttr` and scene sprite/model `attrs` tables let entity picks surface the same semantic cursor metadata as world geometry. This keeps `raycaster` aligned with the attrs-first hover model already used by `globe`.
