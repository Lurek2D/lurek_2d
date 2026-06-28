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
- Tile gameplay semantics such as movement blockers, vision blockers, action blockers, point tile-light, global sunlight, and window/door/half-wall profile behavior belong in `lurek.tilefield`.
- `raycaster` no longer exposes gameplay movement, line-of-sight, tile-light, or minimap-light helpers. Tile-based gameplay flows should build or export from `lurek.tilefield`, then pass render input to `raycaster`.
- `lurek.raycaster.buildMultiLevelSceneFromField(params, field, opts)` is the field-consuming bridge for generated multilevel render input. It can read `tilefield` blocker channels as a fallback, but the preferred structured path is to map named field slots such as `wallSlot`, `doorSlot`, `windowSlot`, `floorSlot`, `ceilingSlot`, `objectSlot`, `spriteSlot`, `floorHoleSlot`, and `ceilingHoleSlot` into raycaster walls, wall features, surface textures, billboard sprites, holes, and render-only point-light samples. Presentation slots such as `backgroundSlot`, `skyboxSlot`, and `overlaySlot` let typed map refs select first-person sky/background and full-frame effects like fog or snow without moving gameplay semantics into raycaster. When `opts.catalog` or `opts.tileCatalog` is an `LTileCatalog`, typed tilefield refs reuse `tileset` visuals, texture ids, and object properties instead of requiring duplicate raycaster-only material maps.
- `lurek.raycaster.setShader(shaderOrNil)` accepts only draw-target shaders created through `lurek.render.newShader`. The module stores a render-owned shader handle for the most recently built scene presentation path; it does not compile WGSL or own GPU pipeline state. Software exports such as `drawLastScene` remain CPU captures and do not execute the shader.

## Architecture Links

- Intentionally empty.
