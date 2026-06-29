# physics manual spec overlay

## TL;DR

- Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors.
- Supports shapes, continuous detection, and motorized mechanical joints.
- Can infer approximate collision shapes from image alpha masks for asset-driven colliders.
- Manages override zones, raycast queries, and destructible static terrain.
- Provides a 16-group world collision matrix layered over per-body layer/mask filters.
- Provides post-step contact events and colorized visual debug overlays.
- Supports authored flow fields for wind, water, conveyor, and magic-current style motion that can be sampled or applied during stepping.

## Summary

- The `physics` module is the engine's 2D simulation authority for users who want motion, contact, shapes, joints, and collision queries to live inside one consistent world model.
- Bodies, colliders, forces, terrain, joints, sensors, and collision layers all belong to the same simulation step, which keeps movement and contact rules coherent across the engine.
- The module supports dynamic, static, kinematic, and sensor-style roles so projects can mix actors, level geometry, triggers, platforms, and detection-only regions inside one physical space without switching subsystems.
- Practical physics also depends on querying the world, not only advancing it. Raycasts, overlap checks, sweep-style tests, and contact inspection let gameplay ask what was hit, what overlaps, and why motion changed.
- Flow fields extend that world model with continuous directional media. They let scripts describe rectangles, circular fans, and polyline tubes that contribute acceleration or drag-like target velocity behavior without inventing a second movement subsystem outside the physics step.
- Shape support, terrain integration, and joints give the system expressive range for characters, bullets, walls, pickups, hazards, linked mechanisms, and authored environment collision.
- Alpha-mask shape inference gives tools and scripts a pragmatic bridge from sprite or image assets to plausible collision geometry: circle-like masks become circles, filled masks become rectangles, and irregular masks become bounded convex polygons.
- Contact data is one of the main user-facing outputs because systems often need normals, hit points, and begin or end state changes to react meaningfully.
- That query surface is a major part of the module's identity. Many gameplay features care less about rigid-body theory than about dependable answers to questions such as where movement will stop, whether a region is occupied, what a sensor can currently detect, or which body pair produced a specific contact event.
- The module therefore acts as both simulator and spatial authority. It advances bodies through time, but it also explains the world back to scripts in terms of overlaps, hits, filters, material response, joints, and collision-layer policy.
- Terrain support matters because a large share of game physics is really about how actors relate to authored space. Ground, ramps, tile-derived obstacles, one-way behavior, ledges, and sensor volumes all need to participate in the same contact model or movement quickly becomes inconsistent.
- Joints and constraints extend the feature beyond isolated bodies into coupled systems such as hinges, chains, levers, suspended loads, doors, and puzzle machinery. Without that layer, several gameplay designs would need bespoke approximations instead of sharing engine-owned physical semantics.
- Filtering rules are equally important because not every shape should collide, trigger, block, or report in the same way. Keeping collision layers and response policy near world state lets projects express interaction rules explicitly rather than hiding them in scattered caller-side checks.
- The 16-group world collision matrix gives projects a single policy surface for common roles such as player, enemy, projectile, pickup, and terrain while preserving lower-level per-body layer/mask overrides for specialized cases.
- Debug visualization is not just a convenience but a necessary part of the contract because collision tuning mistakes are difficult to reason about from code alone. Seeing shapes, sensors, normals, joints, and query paths turns the simulation into something inspectable instead of opaque.
- This makes `physics` especially important for grounded locomotion, projectile travel, hazard interaction, puzzle systems, traversal mechanics, and any design where contact semantics are part of gameplay rather than an incidental backend.
- The shared step loop gives other systems one trusted spatial authority for grounded movement, projectiles, puzzle machinery, and hazards instead of several drifting approximations.
- That authority is what lets gameplay, tools, and effects ask the same world-state questions without maintaining parallel collision logic.
- Other systems consume the results, but `physics` owns the source of truth for what counts as solid, colliding, constrained, or detectable in 2D space.

This module primarily collaborates with `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Beam query contract:
  `LWorld:castBeam`, `LWorld:beamClosest`, and `LWorld:beamAll` are instant spatial queries, not projectile-body simulation. They share the same layer, mask, group, sensor, and `excludeBody` filtering semantics as the raycast family so gameplay can switch between projectiles and hitscan without inventing parallel collision policy. The current release ships the thin-beam path (`thickness = 0`) and leaves thick beam shape-casting as the explicit follow-up; calling `thickness > 0` fails fast so scripts do not assume wide-beam support yet.
- Flow-field contract:
  Authored flow fields live on the world, respect layer masks, can overlap additively, and may be sampled directly from Lua for AI, VFX, UI previews, or debugging. The physics world remains the source of truth for how those currents affect bodies during stepping.
- Body-influence contract:
  Bodies expose per-body flow coefficients so gameplay can scale all flow, air-only flow, water-only flow, and drag cross-section without forking world behavior. Those coefficients are body metadata, not separate force emitters.
- Debug contract:
  Physics debug rendering includes authored flow guides through `drawFlowDebug` so tools and examples can inspect centerlines, coverage bounds, and sampled arrows using the same world-owned data that stepping uses.

## Architecture Links

- Intentionally empty.
