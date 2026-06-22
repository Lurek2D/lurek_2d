<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/raycaster.md or source docstrings instead. -->

# raycaster

## TL;DR

- Simulates pseudo-3D first-person views from 2D maps using DDA marching.
- Supports transparent walls, variable heights, and multilevel storeys.
- Manages sliding doors, discrete grid motion, and billboard sprites.
- Renders textured space with point lights, depth buffers, and pickers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/raycaster`
- Binding: `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`
- Lua API surface: `16` functions, `21` types, `132` methods
- User-facing: `true`
- Plugin tier: `tier_1_plugin`

## Summary

- The `raycaster` module is the engine's pseudo-3D first-person view system for users who want corridor shooters, dungeon crawlers, exploration views, or tactical previews built from structured 2D world data instead of from a full freeform 3D engine stack.
- Its technical base is DDA-style ray traversal over map-aligned space, but the important user-facing point is that the module turns that low-level technique into a complete first-person workflow with scene building, interaction helpers, lighting hooks, and deterministic output options.
- The module is valuable because it solves the interpretation layer between a tile or cell world and a playable camera view. Users provide structured world data, and `raycaster` decides how that data becomes walls, depth, occlusion, visible openings, and navigable perspective.
- This matters most in projects that want first-person presence without the complexity of general 3D mesh authoring, continuous physics, and fully free camera semantics. The system stays constrained enough to be authorable and testable while still producing a convincing viewpoint.
- Variable heights, multilevel interpretation, partial blockers, and transparent or layered hits make the subsystem more than a toy single-plane corridor renderer. It can represent richer spaces where openings, stacked features, and elevation differences matter to play and readability.
- Door state and related wall-feature handling are especially important because first-person tile spaces often depend on interactable architecture. A door is not only a texture change; it affects visibility, ray obstruction, navigation feel, and scene comprehension, and this module keeps those consequences together.
- Floors and ceilings are part of the same contract rather than optional garnish, since convincing pseudo-3D scenes need more than wall columns to read as spaces.
- Billboard sprites keep moving actors, pickups, props, projectiles, and markers inside the same depth model as the wall renderer, which avoids a separate mismatched pseudo-3D object layer.
- Depth-aware ordering and visibility rules are therefore core capabilities. When wall features, sprites, and translucent elements overlap, the module owns what is actually visible and in what order.
- Lighting hooks, visibility helpers, and picking support make the subsystem useful for gameplay and tooling as well as for final rendering.
- Those helpers matter beyond display. Projects may use raycasted visibility for perception checks, preview cameras, editor probes, or line-of-sight style gameplay questions tied to the same projected world.
- Scene assembly is one of the biggest practical wins for users: walls, floors, ceilings, sprites, and optional inserted content are composed through one coherent first-person pipeline instead of several subsystems guessing at perspective differently.
- Movement-oriented helpers keep the module grounded in its natural use cases. Many raycasted projects combine discrete or grid-influenced movement with first-person presentation, so helpers for that style of navigation reduce project-specific glue at the camera seam.
- Deterministic preview and software-capture paths matter because raycasted scenes often need screenshots, regression checks, editor thumbnails, or evidence artifacts outside live play.
- Because the module owns both projection and interaction-friendly queries, aiming, object picking, and visibility-sensitive gameplay can stay aligned with the same depth model instead of relying on separate approximations.
- That same alignment keeps first-person tools and gameplay on one depth model.
- The result is a feature that serves both play and inspection. The same projection model can support a shipped first-person game, a level preview tool, or a visibility-debug workflow without changing how world interpretation works.
- This combination of constrained world model and rich view helpers is what gives the subsystem its identity: it provides first-person readability without giving up the structural advantages of a map-driven engine.
- From a boundary perspective, world modules define the environment and `render` draws the final commands, but `raycaster` owns how structured 2D space becomes a first-person readable visual field with depth, occlusion, and object placement semantics.
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

### build_scene.rs

- This file owns `RaycasterScene::build` and `build_multilevel`, which turn camera state into prepared scene geometry.
- It defines scene-build inputs such as `SceneBuildParams`, `LoweredFloorCell`, `WorldSprite`, and `LevelSprite`.
- Wall hits are converted here into perspective-correct quads with texture routing, cell values, depths, and light tint.
- Floor and ceiling tiles expand into screen-space spans with stable UVs, texture overrides, and roof-aware lighting.
- Lowered-floor cells generate pits, bottoms, and side faces so vertical relief survives scene translation cleanly.
- Lighting sampling blends ambient, point, and global light here, with a cache that keeps repeated queries affordable.
- Roofed cells, ceiling holes, and multilevel visibility rules influence which surfaces are emitted and how they render.
- Billboard sprites use the same camera model as walls, including directional texture selection from viewer angle.
- Multilevel builds group sprites and lights per slice, compile level runtimes on demand, and merge visible slices.
- Texture lookup callbacks keep resource routing outside the builder while geometry and lighting policy stay centralized.
- This file is the staging boundary between grid-owned ray data and the renderer-facing `RaycasterScene` surface.
- It is the right owner for changing surface emission, pit geometry, or light application without renderer rewrites.
- Open this file when scene assembly semantics change; casting, picking, and draw translation live in siblings.

### column_batch.rs

- This file owns `ColumnData` and `ColumnBatch`, the compact per-column output buffer before scene assembly.
- It stores wall slice spans, texture coordinate, shade, cell value, depth, screen size, and flat fill colors.
- Helpers initialize frame-sized buffers, write one column, or unpack packed DDA float arrays into stable records.
- Downstream render paths can reuse one batch as a complete wall pass without rederiving projection or shading.
- Open this file when per-column buffer shape changes; DDA casting and scene translation live in sibling owners.

### dda.rs

- This file owns `Raycaster2D`, the grid-backed DDA engine that stores wall cells and answers ray or LOS queries.
- It stores map dimensions, row-major cells, wall alpha overrides, wall features, and synchronized door feature state.
- Core casting methods produce single hits, layered transparent hits, fan casts, and packed ray buffers from one model.
- Visibility helpers reuse the same blocking rules for line of sight, so lighting and AI stay aligned with rendering.
- Door synchronization translates `DoorManager` openness into wall features without replacing underlying tile identity.
- Sprite and floor helpers project billboards and sample floor rows with the same camera conventions as wall casting.
- Safe setters ignore invalid writes, and out-of-range reads fall back predictably for tools and runtime probes.
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

- This file owns the software rasterization path that turns a prepared `RaycasterScene` into CPU-side `ImageData`.
- It fills ceilings, floors, walls, sprites, and transient meshes in a fixed order using quad and triangle helpers.
- The scene already carries geometry, UVs, lighting, and depth intent, so this file translates instead of recomputing.
- It is the right owner for previews, captures, and tool outputs that need first-person imagery without renderer commands.
- Open this file when CPU draw ordering or fill behavior changes; scene assembly and GPU translation live in siblings.

### grid_motion.rs

- This file owns grid-locked movement helpers for raycaster games that step actors one tile at a time.
- It defines `GridMoveAction`, parses move tokens, and converts facing direction into cardinal world deltas.
- `try_move` applies bounds and caller-provided blocking tests so locomotion rules stay reusable across maps.
- Open this file when snapped movement semantics change; ray casting and wall visibility logic live in siblings.

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

- This file owns `PointLight` plus local and global lighting helpers for colored illumination in raycaster space.
- It stores point-light position, optional level ownership, radius, intensity, and color for cheap sample evaluation.
- Helper functions test line of sight through walls, accumulate ambient and point light, and apply directional sun tint.
- Scene builders reuse these lighting samples to shade walls, floors, sprites, and multilevel slices without light graphs.
- Open this file when raycaster light semantics change; hit casting and wall feature payloads live in sibling owners.

### mod.rs

- This module re-exports the raycaster subsystem surface for casting, scene building, lighting, doors, and rendering.
- It keeps navigation explicit by mapping which sibling files own DDA marching, column batches, height data, and adapters.
- Public exports here route callers toward `Raycaster2D` for casting and scene types for prepared first-person output.
- `projection.rs`, `depth_buffer.rs`, and `sprite_projection.rs` own screen-space math and occlusion data.
- `doors.rs`, `wall_feature.rs`, and `heightmap.rs` hold cell state that changes how blocking tiles render.
- `build_scene.rs`, `draw.rs`, and `render.rs` translate ray hits into either CPU pixels or engine render commands.
- Visibility, segment, and grid-motion helpers stay here so gameplay queries can reuse the camera model.
- Change this file when the public raycaster symbol map moves; change siblings when behavior or data rules change.

### multilevel.rs

- This file owns `RaycasterLevel` and `MultiLevelGrid`, the stacked-slice model for multi-storey raycaster worlds.
- It stores per-level walls, wall features, texture overrides, lowered floors, holes, vertical bounds, and caches.
- Level helpers read or mutate wall, floor, ceiling, and hole data while rejecting out-of-bounds writes safely.
- The runtime builder compiles a transient `Raycaster2D` view from level-owned cells for rendering and picking.
- `MultiLevelGrid` tracks the active slice, caches compiled runtimes, and resolves visible lower or upper levels.
- Ascend and descend checks use floor or ceiling holes so movement and visibility share one vertical rule set.
- Open this file when stacked-level data or cross-level visibility changes; scene assembly lives in siblings.

### projection.rs

- This file owns the projection helpers that convert ray-hit distance into wall column height and draw bounds.
- It also computes distance-based shading factors so raycaster rendering can fade geometry over viewing range.
- Open this file when wall projection math changes; hit records and sprite payloads live in sibling files.

### ray_hit.rs

- This file owns `RayHit`, the per-ray result record produced when DDA traversal reaches visible geometry.
- It stores corrected distance, raw distance, tile value, face side, texture coordinate, alpha, and hit point.
- Open this file when ray-hit payload shape changes; projection math and scene construction live in siblings.

### render.rs

- This file owns the render-command bridge that turns a prepared `RaycasterScene` into generic engine draw commands.
- It emits textured quads or flat rectangles for ceilings, floors, walls, sprites, and transient meshes in scene order.
- Because the scene already contains geometry, UVs, lighting, and depth intent, this file mostly translates existing data.
- It is the handoff point where raycaster-specific presentation becomes backend-agnostic `RenderCommand` work.
- Open this file when command translation or draw ordering changes; CPU rasterization and scene assembly live in siblings.

### scene.rs

- This file owns `RaycasterScene` and its quad, sprite, mesh, pick, and build-stat record types for one frame.
- It stores walls, floors, ceilings, billboard sprites, transient models, viewport size, and build counters.
- Quad records carry corners, UVs, texture routing, light tint, depth, and perspective data for later draw paths.
- Picking helpers resolve screen pixels against projected sprites and model triangles, with optional sprite alpha tests.
- `EntityPickResult` and related enums define the stable payload returned when higher layers query scene selections.
- This file is the staging boundary between raycaster world reasoning and renderer or CPU draw translation.
- Open this file when prepared-scene data or picking semantics change; build and render flow live in siblings.

### scene_adapter.rs

- This file owns transform adapters that turn static entries or live physics bodies into scene-facing raycaster inputs.
- It stores `SceneTransform` sources plus resolved sprite, light, and optional model bindings sampled each frame.
- Body-backed transforms apply local offsets and angle offsets so pseudo-3D attachments stay aligned with physics owners.
- `SceneAdapter` aggregates bindings, clears tracked groups, and resolves live entries into world sprite or light data.
- The adapter keeps gameplay code focused on 2D ownership while the raycaster consumes one normalized input surface.
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
- This file is the boundary between first-person UI input and gameplay selection on underlying grid or multilevel data.
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
- Query helpers answer movement, visibility, and light blocking from the same payload used by rendering code.
- Open this file when per-cell wall behavior changes; door state progression and scene assembly live in siblings.



## Lua API Ref

### Functions

- `lurek.raycaster.applyLitShade(baseShade, r, g, b) -> number`: Applies an RGB light color to a scalar shade value.
- `lurek.raycaster.buildMultiLevelScene(params, levels, lights?, sprites?, wallTextures?, models?) -> integer`: Builds a multilevel raycaster scene from a stack of plain Lua level tables.
- `lurek.raycaster.buildMultiLevelSceneFromAdapter(params, levels, adapter, wallTextures?) -> integer`: Builds a multilevel raycaster scene from a stack of plain Lua level tables using a runtime scene adapter.
- `lurek.raycaster.distanceShade(distance, maxDistance) -> number`: Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
- `lurek.raycaster.getLastBuildStats() -> table`: Returns stats for the last stored raycaster scene build.
- `lurek.raycaster.new(w, h) -> LRaycaster`: Creates a new raycaster map with the given grid dimensions.
- `lurek.raycaster.newDoorManager() -> LDoorManager`: Creates a new door manager for tracking and animating sliding doors.
- `lurek.raycaster.newHeightMap(w, h) -> LHeightMap`: Creates a new height map for variable floor/ceiling heights across the grid.
- `lurek.raycaster.newMap(w, h) -> LRaycaster`: Creates a new raycaster map (alias for `new`).
- `lurek.raycaster.newMultiLevelGrid(levels?) -> LMultiLevelGrid`: Creates a persistent multi-level raycaster world from plain Lua level tables or as an empty container.
- `lurek.raycaster.newPointLight(x, y, r, g, b, radius, intensity, level?) -> LPointLight`: Creates a new point light with position, color, radius, and intensity.
- `lurek.raycaster.newSceneAdapter() -> LSceneAdapter`: Creates a runtime adapter for sprites, lights, and models that can follow physics bodies.
- `lurek.raycaster.newSpriteManager() -> LSpriteManager`: Creates a new sprite manager for tracking and projecting billboard sprites.
- `lurek.raycaster.pickScreenMultiLevel(sx, sy, params, levels, wallTextures?, sprites?, models?) -> table`: Resolves a screen-space click against a stack of plain Lua level tables and returns the owning level.
- `lurek.raycaster.pickScreenMultiLevelFromAdapter(sx, sy, params, levels, wallTextures?, adapter) -> table`: Resolves a screen-space click against a stack of plain Lua level tables using a runtime scene adapter.
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
- `LMultiLevelGrid:getCeilingHeight() -> number`: Returns the ceiling height of the active level in world units.
- `LMultiLevelGrid:getCeilingTexture() -> integer`: Returns the default ceiling texture id used by the active level, or nil when none is set.
- `LMultiLevelGrid:getCeilingTextureCell(x, y) -> integer`: Returns the per-cell ceiling texture id assigned on the active level, or nil if none is set.
- `LMultiLevelGrid:getCell(x, y) -> integer`: Returns the wall type value at a grid cell on the active level.
- `LMultiLevelGrid:getFloorOffset() -> number`: Returns the floor height offset of the active level in world units.
- `LMultiLevelGrid:getFloorTexture() -> integer`: Returns the default floor texture id used by the active level, or nil when none is set.
- `LMultiLevelGrid:getFloorTextureCell(x, y) -> integer`: Returns the per-cell floor texture id assigned on the active level, or nil if none is set.
- `LMultiLevelGrid:getLoweredFloorCell(x, y) -> table`: Returns the lowered-floor configuration at an active-level cell, or nil if the cell is normal.
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
- `LMultiLevelGrid:setDoorCell(x, y, direction, openAmount, alpha?) -> nil`: Attaches a sliding door feature to a blocking cell on the active level.
- `LMultiLevelGrid:setFloorHole(x, y, hole) -> nil`: Sets whether an active-level cell is open to the level below.
- `LMultiLevelGrid:setFloorOffset(offset) -> nil`: Sets the floor height offset of the active level in world units.
- `LMultiLevelGrid:setFloorTexture(texture?) -> nil`: Sets the default floor texture used by the active level. Pass nil to clear it.
- `LMultiLevelGrid:setFloorTextureCell(x, y, texture?) -> nil`: Assigns a per-cell floor texture override on the active level. Pass nil to remove the override.
- `LMultiLevelGrid:setHalfWallCell(x, y, height) -> nil`: Attaches a half-height wall feature to a blocking cell on the active level.
- `LMultiLevelGrid:setLoweredFloorCell(x, y, opts?) -> nil`: Marks an active-level cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
- `LMultiLevelGrid:setWindowCell(x, y, sillHeight, lintelHeight, alpha?) -> nil`: Attaches a window feature to a blocking cell on the active level, leaving a visible opening between sill and lintel.
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

#### LRaycasterGetLastBuildStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `lightingCacheHits` (`integer`): Number of reused lighting samples served from the per-build cache.
- `lightingCacheMisses` (`integer`): Number of unique lighting samples computed during the last build.
- `lightingSamples` (`integer`): Total lighting samples requested during the last build.

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

#### LRaycasterRevealCellsFromRaysResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

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
- `LSpriteManager:remove(id) -> nil`: Removes a sprite by its id. This method is available to Lua scripts.
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

## Tests

- Lua unit: `tests/lua/unit/test_raycaster_unit.lua` (present)
- Rust: `tests/rust/unit/raycaster_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_raycaster_evidence.lua` |
| Golden test | `tests/lua/golden/test_raycaster_golden.lua` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_camera_sweep_atlas.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_corridor_view_with_fov.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_depth_columns_vs_view.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_feature_walls_view_pick.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_floor_ceiling_pick_uv.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_los_wall_window_door.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_minimap_reveal_lighting.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_multilevel_hole_pick.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_topdown_reveal_fov.png` |
| Current artifact | `tests/artifacts/current/raycaster/raycaster_transparent_layered_hits.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_camera_sweep_atlas.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_corridor_view_with_fov.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_depth_columns_vs_view.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_feature_walls_view_pick.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_floor_ceiling_pick_uv.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_los_wall_window_door.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_minimap_reveal_lighting.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_multilevel_hole_pick.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_topdown_reveal_fov.png` |
| Baseline artifact | `tests/artifacts/baselines/raycaster/raycaster_transparent_layered_hits.png` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
