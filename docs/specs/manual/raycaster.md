# raycaster manual spec overlay

## TL;DR

- Simulates pseudo-3D first-person views from 2D maps using DDA marching.
- Supports transparent walls, variable heights, and multilevel storeys.
- Manages sliding doors, discrete grid motion, and billboard sprites.
- Renders textured space with point lights, depth buffers, and pickers.

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

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
