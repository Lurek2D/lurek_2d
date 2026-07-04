# raycaster manual spec overlay

## TL;DR

- Simulates pseudo-3D first-person views from 2D maps using DDA marching.
- Supports transparent walls, variable heights, and multilevel storeys.
- Manages render-only wall features, multilevel space, and billboard sprites.
- Renders textured space from supplied scene input with depth buffers and pickers.

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

## Architecture Links

- Intentionally empty.
