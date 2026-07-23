# physics manual spec overlay

## TL;DR

- Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors.
- Supports shapes, continuous detection, and motorized mechanical joints.
- Supports bullet-mode CCD bodies and swept circle queries for fast projectile work.
- Supports mirror-style beam reflection and explicit projectile-velocity ricochet helpers.
- Can infer approximate collision shapes from image alpha masks for asset-driven colliders.
- Manages override zones, raycast queries, and destructible static terrain.
- Provides a separate grid-based `LiquidMap` for leaking tanks, simple settling, serialization, and sampled buoyancy or drag.
- Provides a 16-group world collision matrix layered over per-body layer/mask filters.
- Provides post-step contact events and colorized visual debug overlays.
- Supports authored flow fields for wind, water, conveyor, and magic-current style motion that can be sampled or applied during stepping.

## Summary

- The `physics` module is the engine's 2D simulation authority for users who want motion, contact, shapes, joints, and collision queries to live inside one consistent world model.
- Bodies, colliders, forces, terrain, joints, sensors, and collision layers all belong to the same simulation step, which keeps movement and contact rules coherent across the engine.
- The module supports dynamic, static, kinematic, and sensor-style roles so projects can mix actors, level geometry, triggers, platforms, and detection-only regions inside one physical space without switching subsystems.
- Practical physics also depends on querying the world, not only advancing it. Raycasts, overlap checks, sweep-style tests, and contact inspection let gameplay ask what was hit, what overlaps, and why motion changed.
- Reflective query paths now extend that spatial role. Scripts can mark bodies as mirrors, trace deterministic multi-segment beams through those surfaces, and reflect projectile velocities from supplied contact normals without confusing gameplay reflection with rigid-body restitution.
- Flow fields extend that world model with continuous directional media. They let scripts describe rectangles, circular fans, and polyline tubes that contribute acceleration or drag-like target velocity behavior without inventing a second movement subsystem outside the physics step.
- Liquids now cover the next step beyond those purely authored media. `LLiquidMap` adds a separate cell grid for finite-volume leaks, settling levels, terrain-linked openings, and sampled body buoyancy without turning every liquid cell into a rigid-body collider.
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

- Safety and lifetime contract:
  `PhysicsLimits` bounds active bodies, lifetime body slots, fixtures, joints, zones, gravity-vector and flow-field slots, query hits, beam reflections, lifetime ballistic-projectile slots, debug snapshots, ballistic trace samples, fixed steps, contact events, solver work, CCD work, terrain/liquid allocation, component scans, and terrain component output. Numeric body and projectile IDs are stable non-negative integers and are not reused after destruction; worlds fail creation once their lifetime slot ceiling is reached, until `clear()` or `resetWorld()` releases backing state. `clear()` preserves configured limits and world settings, while `resetWorld()` restores defaults.

- Stepping and event contract:
  Lua-facing `LWorld:step(dt)` and `lurek.physics.step(world, dt)` require a finite delta within the configured step range and reject oversized input rather than silently discarding time. `stepFixed(accumulator, stepDt, maxSteps)` requires a finite non-negative accumulator, a bounded valid fixed delta, and bounded work; it returns the unconsumed remainder. Begin/end contacts are canonicalized by body ID, deduplicated, ordered, and limited by `PhysicsLimits.max_contact_events` for the complete fixed-step call. `step` plus `stepFixed` dispatch the same callbacks after the world borrow is released.

- Query and rebuild ordering:
  All-hit raycasts sort by time of impact and then body ID, AABB queries sort body IDs, point-query ties choose the lowest body ID, and fixture duplicates collapse to one body result. Partial terrain flushes process dirty chunks in row-major order. These rules make query and rebuild results stable across runs.

- Batched query contract:
  Rust systems that need several same-filter all-hit rays can use `World::raycast_all_batch(...)`. The batch creates one query-pipeline view, applies the shared filter to every request, and returns one deterministic, individually capped result vector per request. Lua continues to expose the simpler single-query APIs; batching remains a core integration seam until a Lua table contract can preserve the same bounded diagnostics.

  Render, navigation, and tooling consumers can use `World::physics_snapshot()` to receive an immutable, body-id-sorted bounded shape snapshot, then `World::diff_physics_snapshots(previous, current)` to obtain deterministic added, removed, and changed records without borrowing mutable physics state. Snapshot generation IDs are content-derived and therefore change only when the captured bounded shape data changes.

- `lurek.physics.createBodiesFromTilefield(field, slot, tileset, world, opts?)` is the canonical consumer-owned adapter for turning tilefield refs plus tileset `physics` metadata into bodies. `lurek.tilefield.createPhysicsFromTileset(...)` remains a compatibility alias during the migration window.

- Material model:
  `lurek.physics.newMaterial({...})` is the reusable, validated material constructor. Body-default material assignment lives on `LBody:setMaterial(...)` / `LBody:getMaterial()`, while collider-specific overrides live on `LWorld:setFixtureMaterial(bodyId, fixtureIndex, ...)` / `LWorld:getFixtureMaterial(...)`. Existing direct setters such as `setFriction`, `setRestitution`, `setMass`, `setGravityScale`, `setLinearDamping`, `setAngularDamping`, `setBeamReflectivity`, and `setProjectileReflectivity` remain valid and keep the stored body-material snapshot in sync.

  Mixed-surface contacts use explicit per-material combine rules. `frictionCombineRule` and `restitutionCombineRule` accept `average`, `min`, `multiply`, or `max` and are applied directly to the Rapier collider when a material is assigned to a body or fixture. Omitting either field preserves the deterministic `average` default.

  | Property | Scope | Current API | Backing |
  | --- | --- | --- | --- |
  | `density` | body primary collider, fixture | `newMaterial`, `setMaterial`, `setFixtureMaterial`, `addFixture` | solver-backed |
  | `friction` | body primary collider, fixture | `getFriction`, `setFriction`, `setFixtureFriction`, material APIs | solver-backed |
  | `restitution` | body primary collider, fixture | `getRestitution`, `setRestitution`, `setFixtureRestitution`, material APIs | solver-backed |
  | `frictionCombineRule`, `restitutionCombineRule` | body primary collider, fixture | `newMaterial`, `setMaterial`, `setFixtureMaterial` | solver-backed |
  | `massOverride` | body | `getMass`, `setMass`, material APIs | solver-backed |
  | `gravityScale` | body | `getGravityScale`, `setGravityScale`, material APIs | solver-backed |
  | `linearDamping`, `angularDamping` | body | damping getters/setters, material APIs | solver-backed |
  | `beamReflectivity`, `projectileReflectivity` | body, fixture metadata | dedicated reflectivity getters/setters, material APIs | gameplay-backed |
  | `beamAbsorption` | body, fixture metadata | material APIs | gameplay-backed |
  | `stickiness`, `adhesion` | body, fixture metadata | material APIs | gameplay-backed |
  | `buoyancy` | body, fixture metadata | material APIs | gameplay-backed |
  | `name`, `surfaceType` | body, fixture metadata | material APIs | metadata |

- Terrain contract:
  `LTerrain:fillCircle(...)` and `LTerrain:fillRect(...)` remain the low-level solid-or-empty edit primitives, while `carveCircle`, `addCircle`, `carveRect`, `addRect`, and `damageCircle` expose gameplay-intent names so crater code does not have to remember boolean fill semantics. `collapseColumns()` is still the legacy single-cell overhang cleanup heuristic, not a full stability pass. `collapseUnsupported(...)` is the explicit connected-component pass for Worms-style unsupported terrain handling: it scans solid islands, treats bottom-border or any-border connectivity as support depending on the chosen rule, removes unsupported components, spawns sampled debris, or emits one dynamic rectangle body per unsupported component bounds when `mode = "spawnDynamicChunks"`. `flush(maxDirtyChunks?)`, `collapseUnsupported(...)` spawn modes, and `spawnDebris(...)` preflight all generated bodies against active and lifetime-slot limits; failures leave terrain/world state unchanged and report a named physics error. Successful `flush` calls report how many dirty chunks were rebuilt, how many remain queued, how many terrain bodies were destroyed or created, and how long the rebuild took. `rowRuns` remains the fast deterministic default; `contourEdges` emits only exposed cell boundaries, eliminating internal rectangle seams at the cost of more bounded collider bodies.
- Beam query contract:
  `LWorld:castBeam`, `LWorld:beamClosest`, and `LWorld:beamAll` are instant spatial queries, not projectile-body simulation. They share the same layer, mask, group, sensor, and `excludeBody` filtering semantics as the raycast family so gameplay can switch between projectiles and hitscan without inventing parallel collision policy. `castBeam(..., { reflect = true })` extends the thin closest-hit path into deterministic mirror tracing: mirror bodies use surface normals plus per-body beam reflectivity to produce chained segments until the range, bounce budget, or energy budget runs out. A positive `thickness` uses the canonical circle shape sweep for a closest, non-reflective capsule-style beam; multi-hit/pierce and reflective thick beams remain explicitly rejected until they have equivalent swept-shape semantics.
- Fast-projectile contract:
  `LBody:setBullet(true)` and `LWorld:setBodyCCD(id, true)` enable Rapier CCD for physical projectiles that should bounce, collide, and emit normal contact events. `LWorld:setCcdSubsteps(n)` tunes how aggressively the world resolves CCD events for those bullet bodies, while `LWorld:stepFixed(accumulator, stepDt, maxSteps)` handles frame pacing and backlog reduction. Use `LWorld:reflectBodyVelocity(bodyId, normalX, normalY, coefficient)` when gameplay has already decided a projectile should ricochet from a supplied world-space contact normal and needs the shared reflection math to update both Rapier and the Lua-visible body mirror. Use bullet CCD for dynamic bodies that must stay physical; use `LWorld:castCircle(...)` when a script needs an immediate swept hit before moving a kinematic or manually-authored projectile. Use raycasts and beam helpers for thin hitscan logic, not for thick moving projectile volumes.

- Projectile and query decision table:

  | Need | Canonical physics tool | State advanced | Result contract | Do not use it for |
  | --- | --- | --- | --- |
  | A physical moving body that must bounce and emit contacts | Bullet body CCD: `setBullet` / `setBodyCCD` | Normal world `step` or `stepFixed` | Solver contacts and body state | Instant hitscan or arbitrary thick casts |
  | An immediate swept-radius answer before authored movement | `castCircle` | None | One earliest shape-sweep hit | Persistent projectile simulation |
  | A thin instant hitscan, optionally with mirrors | `castBeam`, `beamClosest`, or `beamAll` | None | Sorted hit/segment trace, bounded by query and bounce limits | A thick beam |
  | A closest capsule-style beam | `castBeam(..., { thickness = radius })` | None | One canonical circle-sweep hit | Multi-hit/pierce or reflective thick tracing |
  | A sampled 2.5D arc against altitude-aware targets | `castBallisticArc` | None | Bounded sampled trace and first 2.5D hit | Gameplay-owned projectile lifetime or damage policy |
  | A simulated altitude-aware projectile with a stable engine slot | `spawnBallisticProjectile` | World stepping | Bounded lifetime slot plus queued impact records | Rigid-body contacts, weapon damage, or render policy |

  Gameplay owns weapon rules, damage, VFX, and despawn policy around these primitives; physics owns only collision, query, and bounded sidecar state.
- Reflective-surface contract:
  Mirror-style beam reflection is explicit gameplay metadata, not a synonym for rigid-body restitution. `LBody:setMirror(...)`, `LBody:setBeamReflectivity(...)`, and `LBody:setProjectileReflectivity(...)` let scripts describe mirror and ricochet intent independently from `setRestitution(...)`, so laser puzzles and gameplay reflection can stay deterministic even when physical bounce settings differ.
- Flow-field contract:
  Authored flow fields live on the world, respect layer masks, can overlap additively, and may be sampled directly from Lua for AI, VFX, UI previews, or debugging. The physics world remains the source of truth for how those currents affect bodies during stepping.
- Simple-field contract:
  Rectangles, full circles, directional fans, radial in/out currents, and tangential clockwise/counter-clockwise swirl all share the same flow-field owner. `addFan(...)` is the convenience helper for designer-authored blower wedges, while circular fields plus radial or tangential directions cover attraction, repulsion, and vortex-like motion without introducing a second subsystem.
- Body-influence contract:
  Bodies expose per-body flow coefficients so gameplay can scale all flow, air-only flow, water-only flow, and drag cross-section without forking world behavior. Those coefficients are body metadata, not separate force emitters.
- Liquid contract:
  `LLiquidMap` is the first volume-aware liquid surface. It stores per-cell amount and kind in a separate grid, serializes those cells directly, links to `LTerrain` when projects want leaks through carved openings, and advances with deterministic downward, lateral, and light pressure equalization passes. The current implementation is intentionally pragmatic: it conserves volume within floating-point tolerance when evaporation is zero, samples liquid at body points to apply buoyancy or drag, and leaves full SPH, particle-only fluids, and collider-backed liquid bodies out of scope. Zones and flow fields remain the cheaper non-volume-conserving option for "body is inside water" style gameplay volumes.
- Debug contract:
  Physics debug rendering includes authored flow guides through `drawFlowDebug` so tools and examples can inspect centerlines, coverage bounds, and sampled arrows using the same world-owned data that stepping uses.

## Architecture Links

- Intentionally empty.
