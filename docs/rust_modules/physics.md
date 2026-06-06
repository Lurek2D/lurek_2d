# physics

## General Info

- Module group: `Platform Services`
- Source path: `src/physics/`
- Binding: `src/lua_api/physics_api.rs`
- Namespace: `lurek.physics`
- Lua API surface: `22` functions, `16` types, `168` methods
- Rust test path(s): src/physics/world_tests.rs, inline #[cfg(test)] in body.rs, shape.rs, zone.rs, cellular.rs, terrain.rs, render.rs, collision_helpers.rs
- Lua test path(s): none found in the workspace

## Summary

This module delivers a high-performance 2D rigid-body physics simulation subsystem that drives motion, collision, and mechanical interactions. It manages rigid bodies under distinct behavioral roles, including dynamic movers, fixed solid obstacles, script-driven kinematics, and trigger sensors. To ensure deterministic results regardless of rendering frame rate, the engine utilizes fixed-timestep updates, automatically reconciling screen pixels with physics meters.

Colliders define the physical boundaries and surface characteristics of bodies, utilizing a range of shapes from circles and rectangles to convex polygons and chained polyline boundaries. Each shape stores dedicated physical properties, such as mass density, friction, and restitution bounciness. For fast-moving bodies, continuous collision detection can be enabled, preventing objects from tunneling through thin solid obstacles in the environment.

The simulation world supports mechanical assemblies through joints that bind body pairs together. Developers can establish distance rods, friction dampers, revolute hinges, slider axes, pulleys, ropes, and weld points, giving each joint unique motor settings and break-force thresholds. These constraints enable interactive features like swinging ropes, mechanical gears, suspension wheels, and motorized platforms that react dynamically to player forces.

Trigger zones expand the world into interactive fields that override physics rules within designated areas. Zones apply gravity modifiers such as constant directional currents, point attractors, point repulsors, or zero-gravity environments. They can also override linear and angular damping to simulate underwater currents, deep mud, or low-friction ice fields. Priority levels and layer masks resolve overlapping zones to ensure logical behaviors.

For tactical queries, the subsystem exposes spatial intersection utilities. It handles raycasts to detect sightlines and collision points, including comprehensive searches that return all intersected colliders along a path. Additionally, developers can perform fast axis-aligned bounding box and circular search queries to locate nearby bodies, alongside allocation-free collision check helpers for high-frequency testing outside the active physics world.

The module also integrates a destructible terrain system that bridges static cell grids with dynamic physical colliders. The terrain is tracked in chunks to optimize updates, allowing solid blocks to be filled or cleared in real time. It merges vertically adjacent cells to keep the collider footprint small, spawns debris on collapse, and serializes cell layouts into binary streams, supporting real-time ground destruction and terraforming mechanics.

To assist with debugging, the system translates live body coordinates, joint links, contact manifolds, and collision events into post-step reports. Developers can hook into begin-contact and end-contact event loops, or retrieve comprehensive contact pairs at frame boundaries. Furthermore, debug rendering utilities draw color-coded shapes, contact normals, and velocity vectors, making invisible simulation states easy to analyze.

## Files

### [body.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/body.rs)

- Physics body description layer that gathers the state a simulation object needs before or while it lives inside the world.
- The file defines the playable vocabulary of rigid body roles such as dynamic movers, fixed solids, script-driven kinematics, and overlap-only sensors.
- It also binds those roles to supported geometry forms, material defaults, collision filtering, and transform helpers so a body can be reasoned about as one coherent unit.
- Constructors emphasize ready-to-use authoring by filling in sensible density, friction, restitution, and motion settings rather than forcing every caller to spell out raw fields.
- Geometry utilities keep body space and world space connected, which matters for bounds queries, spawn setup, editor tooling, and shape-aware logic outside the solver.
- Functionally this file delivers the authored physical identity of an object before the broader world machinery turns it into live simulated behavior.

### [collision.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/collision.rs)

- Collision event buffering for the moments when physical contact needs to become stable gameplay information instead of transient solver state.
- The file packages body pairs, normals, penetration data, and sensor transitions into an ordered queue that can be drained after stepping without disturbing the simulation loop.
- Functionally this delivers the bridge from raw contact detection to script-consumable collision events with clean step-boundary timing.

### [collision_helpers.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/collision_helpers.rs)

- Lightweight geometry overlap helpers for code that needs quick collision answers without standing up a full physics world.
- The file keeps AABB, circle, and point tests allocation-free and side-effect free so they fit hot loops, culling, and cheap gameplay probes.
- Functionally this delivers the smallest collision vocabulary for fast spatial checks in plain screen-space coordinates.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/mod.rs)

- Platform-level 2D physics module that unifies authored bodies, geometric shapes, simulation stepping, spatial queries, terrain sync, and trigger-style environmental effects.
- It exposes the major surfaces of the subsystem as one coherent toolbox, from lightweight helper tests through full world simulation and debug-oriented support structures.
- Functionally this file is the high-level entry point for physical interaction, movement constraints, collision reporting, and physics-backed world state in Lurek2D.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/render.rs)

- Physics debug rendering layer for turning invisible simulation state into visible lines, outlines, and motion cues that developers can inspect frame by frame.
- The file translates bodies and shapes into render-friendly snapshots without changing the simulation, letting diagnostics live beside gameplay rather than inside it.
- Type-based coloring keeps static, dynamic, kinematic, and sensor objects readable at a glance when scenes grow dense.
- Velocity arrows and shape outlines expose both form and movement so developers can see why contacts, tunnels, or odd impulses are happening.
- Functionally this delivers the visual instrumentation needed to understand, tune, and trust the physics subsystem during development.

### [shape.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/shape.rs)

- Physics shape definition layer that gives the subsystem a compact language for circles, rectangles, polygons, edges, and chained outlines.
- The file keeps geometry authoring, validation, and collider conversion close together so malformed inputs can be rejected before they become unstable runtime fixtures.
- Parsing and regular-polygon construction make the surface practical for scripts, tools, and data-driven content that describe shape intent rather than raw engine objects.
- Standalone shapes carry material and sensor settings alongside geometry, which lets authored collision pieces travel with the properties that affect how they behave in the world.
- Local bounding logic keeps each shape queryable without needing a live body, which is useful for previews, authoring tools, and lightweight reasoning.
- Functionally this file delivers the reusable geometry vocabulary that both bodies and higher-level physics workflows build upon.

### [terrain.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/terrain.rs)

- Destructible terrain map layer that turns editable solid cells into physics-ready world geometry without making callers manage collider lifecycles manually.
- The file tracks terrain in chunks so local edits stay local, allowing flush operations to rebuild only the regions that actually changed.
- Fill tools support live terrain authoring and destruction patterns such as circles, rectangles, blanket writes, and other broad modifications during play.
- Row merging keeps the generated static-body footprint compact, which matters when large tile fields must remain interactive without exploding collider counts.
- Serialization and image output make the terrain usable for save systems, tooling, previews, and data exchange outside the immediate simulation step.
- Debris spawning and collapse helpers push the system beyond passive walls into active destructible-environment behavior.
- Functionally this file delivers the editable ground model that connects tile logic, destruction effects, and efficient static collision rebuilds.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/types.rs)

- Small core type surface for the physics subsystem where stable identifiers need stronger meaning than a bare integer can provide.
- The file wraps body identity in a dedicated type so physics handles remain cheap to pass around while still reading as deliberate domain values.
- Functionally this delivers the low-friction type safety that keeps body references explicit across Rust and Lua-facing boundaries.

### [world.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/world.rs)

- Central physics simulation world that owns the living state of rigid bodies, colliders, joints, queries, events, and solver progression for the engine.
- The file wraps Rapier into an engine-shaped runtime surface where spawning, stepping, sleeping, destruction, and body mutation all speak one consistent game-facing vocabulary.
- Fixed-timestep accumulation is part of that surface, which keeps motion and contact results deterministic enough for frame-rate-independent gameplay code.
- Collision collection lives beside stepping so begin, end, and overlap information emerges as stable post-step data rather than scattered callbacks fired from deep inside the solver.
- Spatial queries such as raycasts, point tests, and area checks share the same authoritative world state, which lets gameplay systems ask where things are without duplicating geometry.
- Joint support turns the world from a loose body container into a mechanical playground where links, motors, ropes, sliders, and welded constraints become first-class scene behaviors.
- Break thresholds and one-way platform handling add gameplay-oriented control over how contacts and constraints should behave under stress or directional motion.
- Trigger zones extend the world beyond classic rigid-body simulation by letting areas override gravity, damping, and enter-exit signaling as bodies move through space.
- Pixels-per-meter conversion keeps authored screen-scale intent aligned with simulation-scale correctness, reducing the friction between gameplay numbers and solver numbers.
- Debug shape extraction and line drawing make the same world inspectable, so developers can see the geometry and contact surfaces that drive runtime outcomes.
- Terrain-linked behavior integrates static environment rebuilding into the same physical authority instead of leaving destructible ground as an external special case.
- Body lifecycle controls cover creation, disabling, wake-sleep flow, velocity mutation, material changes, and other everyday manipulations expected from a playable simulation backend.
- Query, contact, and mutation responsibilities stay concentrated here so higher layers can treat the world as the one source of truth for physical state.
- The result is a large but coherent orchestration surface where simulation, environment effects, and debug visibility reinforce each other instead of fragmenting across helper subsystems.
- Functionally this file delivers the full physical stage on which movement, impact, constraints, triggers, terrain interaction, and spatial reasoning all take place.

### [zone.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/physics/zone.rs)

- Physics zone system for spatial rule overrides that should apply because a body is somewhere, not because it touched a solid object.
- The file defines bounded areas that can replace normal gravity with directional pull, attraction, repulsion, or weightless behavior.
- Priority and mask filtering let multiple zones coexist without turning area-based effects into ambiguous global state.
- Damping overrides make zones useful for liquids, mud, low-friction fields, or other environmental modifiers that change motion feel.
- Enter and leave tracking turns zones into event sources as well as force fields, which is important for scripting and gameplay transitions.
- Functionally this file delivers area-driven physics behavior for environmental control, special spaces, and location-sensitive simulation rules.
