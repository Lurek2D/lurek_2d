# raycaster

## General Info

- Module group: `Feature Systems`
- Source path: `src/raycaster/`
- Binding: `src/lua_api/raycaster_api.rs`
- Namespace: `lurek.raycaster`
- Lua API surface: `9` functions, `14` types, `67` methods
- Rust test path(s): tests/rust/unit/raycaster_tests.rs
- Lua test path(s): tests/lua/unit/test_raycaster_core_unit.lua, tests/lua/evidence/test_raycaster_evidence.lua

## Summary

This module provides a classic grid-based first-person raycasting subsystem, turning 2D maps into immersive pseudo-3D environments. At its computational core, a Digital Differential Analysis marcher shoots rays across the map grid to detect wall collisions, calculating corrected perpendicular distances to prevent perspective distortion. This allows developers to present textured first-person viewpoints while preserving the low-overhead structure of a 2D engine runtime.

To support complex layouts, the subsystem extends beyond simple flat maps. The DDA marcher handles layered transparent walls, allowing players to peer through windows. Heightmaps define variable floor and ceiling offsets to model pits, raised steps, and tall chambers. Multilevel slices stack individual storeys horizontally, enabling multi-storey dungeons with vertical shafts, overhead walkways, and smooth transitions between vertical levels.

Moving boundaries and gameplay actors are integrated directly into the spatial model. Sliding doors are represented as stateful grid occupants that animate open or closed over time. This keeps movement and collision in sync without hardcoding transitions. For locomotion, the module provides a grid-motion controller that snaps travel cleanly from tile to tile, which fits classic dungeon exploration games and ensures predictable grid boundaries.

Dynamic props, pickups, and enemies are managed as billboard sprites that face the camera. The sprite manager registers world-space objects, projects them using the camera pose, and sorts them by distance. This depth-aware ordering prevents sprites from bleeding through solid walls, and ensures they blend with the environment, matching the perspective of adjacent wall columns and corridor depths.

The scene builder compiles these spatial hits into a textured 3D environment. It maps wall hits to screen quads and expands floor and ceiling rows into perspective-correct textured strips. A lighting engine applies ambient fill, distance falloff, and colored point lights that respect wall blockages. Half-pixel snapping is also applied to reduce texture shimmering along long wall seams, producing a stable visual space.

Rasterization is handled by both CPU and GPU paths. A per-column depth buffer tracks wall distances, enabling subsequent passes to reject hidden fragments. For GPU rendering, the system generates textured quad draw lists that are easily consumed by the main renderer. Alternatively, a CPU-side software draw pass rasterizes scenes directly into raw image buffers, facilitating offline image generation and tool-facing previews.

Finally, the module provides interactive tile pickers and diagnostic tools. The picker casts rays from cursor clicks to select wall and floor cells, reporting which side was targeted. Line-of-sight and visibility fan utilities calculate field-of-view masks for fog-of-war systems. Software visualizers paint top-down overhead maps, camera sweeps, and depth previews, offering high visibility over the entire raycasting pipeline during development.

## Files

### [build_scene.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/build_scene.rs)

- This file assembles the full per-frame raycaster scene from camera state, grid hits, texture routing, and lighting inputs.
- It turns wall contacts into screen-space quads whose geometry already matches the perspective rules expected by the render stage.
- Floor and ceiling strips are expanded into textured spans with stable UVs so long corridors and open rooms keep coherent surface motion.
- Lowered cells become pits with visible bottoms, side faces, and transitions that preserve depth cues instead of flattening into one plane.
- Roofed regions are darkened differently from open regions so covered space reads denser even before dynamic lights are applied.
- Point lights, ambient light, and distance falloff are blended here so every emitted surface leaves this file with its final light tint.
- Billboard sprites are projected into the same camera space as walls, which keeps monsters, props, and pickups aligned with corridor depth.
- Static meshes can be injected beside billboarded elements without asking later stages to reconstruct world-space context.
- Ground projection helpers convert world corners into screen corners for both top and bottom planes with near-plane rejection baked in.
- UV helpers keep repeated strips and axis-aligned quads visually stable when the camera rotates or grazes a tile boundary.
- Half-pixel snapping is applied where needed to reduce shimmer along long floor edges and thin seam lines.
- The file also decides how visible boundaries around solid cells become roof lips, pit walls, and other secondary surfaces.
- Output is a dense scene description rather than immediate pixels, so later stages can sort, batch, or rasterize without redoing math.
- Most of the expensive spatial reasoning for textured raycast presentation lives here, not in the draw backends.
- In practice this is the bridge between raw DDA hit data and a believable first-person space built from quads and light.

### [column_batch.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/column_batch.rs)

- This file stores the compact per-column output that the raycaster produces before any richer scene assembly begins.
- It keeps wall slice projection, depth, and screen span data in a shape that is cheap to fill for an entire frame at once.
- Frame-level metadata for colors and dimensions rides next to the columns so downstream code can treat one batch as a complete column pass.
- Packed ray input is unpacked here into stable per-column records that preserve shading and visibility decisions from the DDA stage.
- The result is a narrow transport format between hit collection and later wall, floor, or sprite composition work.

### [dda.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/dda.rs)

- This file owns the grid-backed DDA marcher that turns a 2D tile map into ray hits, corrected distances, and wall sampling coordinates.
- It handles both single-hit and layered traversal so partially transparent cells can be marched through without losing the final solid contact.
- Wide fan casts for a whole screen are derived from the same stepping rules, which keeps column rendering consistent with ad hoc queries.
- Line-of-sight checks reuse the same grid logic, so lighting, AI, and visibility questions follow the same blocking semantics as rendering.
- The map storage stays simple and row-major, with safe fallback behavior for out-of-range reads and silent rejection of invalid writes.
- Sprite projection helpers live beside ray stepping so billboard placement uses the same camera conventions as wall casting.
- Floor and ceiling sampling utilities expose screen-to-world relationships without forcing higher layers to re-derive projection math.
- This file is the computational core of the raycaster, where map occupancy becomes reliable spatial hits and camera-facing depth data.

### [depth_buffer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/depth_buffer.rs)

- This file keeps the narrow depth memory that tells the raycaster which wall distance currently owns each screen column.
- It exists so later sprite and overlay work can reject fragments that should remain hidden behind already projected geometry.
- The structure is intentionally simple because it is cleared, written, and read every frame on the hottest render path.

### [doors.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/doors.rs)

- This file models raycaster doors as animated grid occupants whose openness changes continuously while their tile identity stays stable.
- Each door carries movement direction, travel progress, and a small phase machine so gameplay code can request transitions without manual timing.
- The manager keeps doors in one indexed registry, making updates and spatial queries deterministic for the rest of the raycaster.
- Because door openness is tracked separately from base map cells, rendering and collision code can read evolving passage state without duplicating logic.
- The overall effect is a lightweight moving-boundary system that fits the same tile world used by walls, sprites, and picking.

### [draw.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/draw.rs)

- This file turns a prepared raycaster scene into software pixels when GPU command generation is not the chosen output path.
- It fills ceilings, floors, walls, and sprite shapes directly into image memory using the scene ordering established earlier in the pipeline.
- Draw order stays deliberately simple so layered surfaces read correctly even without a richer hardware depth workflow.
- The result is useful for offline images, debug previews, and tool-facing render outputs that need first-person content in CPU memory.

### [grid_motion.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/grid_motion.rs)

- This file provides grid-locked locomotion rules for games that want raycaster movement to snap cleanly from tile to tile.
- Facing direction is reduced to stable cardinal deltas so movement input stays predictable for dungeon crawlers and similar designs.
- Collision checks are delegated through a caller-provided blocking rule, which lets map logic stay external while motion rules stay reusable.
- The emphasis is on deterministic tile traversal rather than smooth analog movement, matching classic first-person grid exploration.

### [heightmap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/heightmap.rs)

- This file stores per-tile floor and ceiling offsets so a raycast map can express steps, pits, and varied room volumes.
- Height data can be assigned cell by cell or across rectangular regions, which makes authored layouts and procedural stamping equally convenient.
- Reads always yield a stable answer and invalid writes are ignored, keeping spatial queries predictable when tools or scripts probe edges.
- It is the lightweight elevation layer that feeds richer scene building without forcing the base map storage to change shape.

### [level_render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/level_render.rs)

- This file handles the column-wise drawing logic for stacked raycaster levels where openings can reveal space above or below the current slice.
- It decides which neighboring cells remain visible through holes so multi-level layouts feel connected instead of collapsing into isolated layers.
- Framebuffer output is written directly in software, with floor and ceiling sampling tuned for readable textured planes in narrow screen columns.
- The file therefore acts as the specialized draw path for vertical level relationships that are more complex than the flat scene builder alone.

### [lighting.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/lighting.rs)

- This file applies simple but readable local lighting to raycast space using colored point emitters and ambient fill.
- Visibility between a light and a sample point is checked against blocking tiles so illumination respects corridor walls and corners.
- Contributions from multiple emitters are accumulated into one tint that later scene builders can stamp onto walls, floors, and sprites.
- The model favors clear spatial mood and cheap evaluation over physically exact light transport.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/mod.rs)

- This module delivers the raycast feature stack that turns a 2D tile field into a readable first-person space with walls, floors, ceilings, sprites, and moving doors.
- It combines DDA stepping, projection, scene building, visibility, lighting, and helper render paths so game code can ask for either gameplay queries or full presentation output.
- Support code for elevation, multilevel layouts, picking, depth, and debug visualization lives beside the core marcher so the subsystem keeps one camera model end to end.
- At the highest level, this is the part of the engine that gives Lua and Rust callers a classic grid-based 3D view without leaving the 2D runtime architecture.

### [multilevel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/multilevel.rs)

- This file extends the flat raycaster into stacked slices so one map position can participate in a multi-storey layout.
- Each slice carries its own vertical span and tile layer, allowing bridges, overhead rooms, shafts, and similar structures to share horizontal space.
- The representation stays close to the base raycaster model, which keeps level transitions understandable for rendering and gameplay code.
- Special transitions can move the viewer between slices without inventing a separate world format or renderer.
- The design is meant to add vertical richness while preserving the core assumptions of the column-based pipeline.

### [projection.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/projection.rs)

- This file contains the compact projection math that turns a ray distance into a visible wall span on screen.
- It also derives distance falloff values so farther geometry can darken smoothly as space recedes from the camera.
- The formulas here keep screen bounds clamped and predictable for the rest of the raycaster pipeline.

### [ray_hit.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/ray_hit.rs)

- This file defines the hit record that carries everything a marched ray learned when it touched visible map geometry.
- It preserves both geometric contact details and render-facing details such as sampled side, distance flavor, opacity, and tile identity.
- The struct is the shared currency between stepping, scene building, shading, and any caller that needs precise impact information.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/render.rs)

- This file converts the prepared raycaster scene into renderer commands that the broader engine command stream already understands.
- It emits textured or flat-colored quads in the ordering expected for ceilings, floors, walls, and billboard content.
- Because the scene already carries geometry, UVs, light, and depth intent, this step mostly translates instead of recomputing presentation logic.
- The file is therefore the handoff point where raycast-specific scene data becomes generic render work for the engine backend.

### [scene.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/scene.rs)

- This file defines the transient geometry language that the raycaster uses between spatial reasoning and final drawing.
- Walls, floors, ceilings, sprites, and injected meshes all share a quad-oriented representation so later stages can sort and emit them uniformly.
- Each record carries the texture routing, light tint, depth meaning, and UV state needed to survive the trip from world logic to renderer.
- The scene container groups one frame of these surfaces into a single package sized to the active viewport.
- In practice it is the raycaster's staging area for everything the camera can currently see.

### [segment.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/segment.rs)

- This file provides a minimal 2D segment representation for ray-style queries that are easier to express against explicit line geometry.
- It computes nearest segment intersections from an origin and direction so callers can reason about wall-like boundaries outside the grid marcher.
- The focus is geometric clarity for helper queries, not a full alternate rendering pipeline.

### [sprite_manager.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/sprite_manager.rs)

- This file manages world-space billboard content that should appear inside the raycast view without becoming part of the wall grid.
- It keeps sprite placement, identity, and visibility data in one registry so gameplay systems can add props, pickups, or actors cheaply.
- When the camera needs them, sprites are exposed in depth-aware order that fits alpha-friendly first-person rendering.
- The registry therefore acts as the dynamic object layer that rides on top of static map geometry.

### [sprite_projection.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/sprite_projection.rs)

- This file stores the screen-facing projection result for a billboard after world position has been interpreted through the raycaster camera.
- It captures where the sprite should land, how large it should read, and whether it remains meaningfully visible to the viewer.
- That compact record lets later passes sort, cull, and clip billboard content against wall depth without repeating camera math.

### [tile_picker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/tile_picker.rs)

- This file maps a screen interaction back into raycaster grid space so UI clicks can target the world the player is looking at.
- It replays the essential camera and stepping assumptions of the view transform instead of relying on a separate picking representation.
- Screen size, camera pose, and tile scale are all part of the picker state, which keeps repeated queries stable across a frame.
- The result reports both tile identity and hit character so callers can tell which cell was reached and from which side it was approached.
- This makes the file the practical bridge between first-person view coordinates and gameplay selection on the underlying map.

### [visibility.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/visibility.rs)

- This file computes a radial visibility fan from a source point against segment obstacles in the plane.
- Rays are aimed around segment endpoints with slight angular offsets so the resulting contour closes gaps that naive sampling would miss.
- The output is shaped for immediate drawing or further masking work wherever a 2D field of view needs explicit polygon points.

### [visualization.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/raycaster/visualization.rs)

- This file provides software visualizers that expose how the raycaster sees, marches, shades, and composes space without requiring the main renderer.
- It can paint overhead maps, first-person wall bands, line-of-sight traces, depth previews, and sweep atlases directly into image buffers.
- Procedural material coloring is embedded here so diagnostic or demo output can still look spatially rich without loading authored textures.
- The helpers are useful when tuning collision, sampling, map layout, or visibility because they make invisible intermediate state immediately legible.
- Outputs stay in plain image memory, which makes them easy to save, inspect in tools, or present inside UI overlays.
- Several views deliberately trade physical correctness for fast explanation, prioritizing readable spatial evidence over final-game polish.
- This file therefore acts as the observability layer for the raycaster subsystem, not just a collection of screenshots.
- It is where engine authors can inspect the behavior of rays, walls, and depth as pictures instead of logs.
