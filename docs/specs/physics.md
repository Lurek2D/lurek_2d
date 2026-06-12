# physics

## TL;DR

- Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors.
- Supports shapes, continuous detection, and motorized mechanical joints.
- Manages override zones, raycast queries, and destructible static terrain.
- Provides post-step contact events and colorized visual debug overlays.

## General Info

- Module group: `Platform Services`
- Source path: `src/physics/`
- Binding: `src/lua_api/physics_api.rs`
- Namespace: `lurek.physics`
- Lua API surface: `22` functions, `17` types, `172` methods
- Rust test path(s): src/physics/world_tests.rs, inline #[cfg(test)] in body.rs, shape.rs, zone.rs, cellular.rs, terrain.rs, render.rs, collision_helpers.rs
- Lua test path(s): tests/lua_reorg/unit/test_physics_unit.lua

## Summary

- The physics module provides 2D rigid-body simulation, collision, and query services for gameplay systems.
- It supports dynamic, static, kinematic, and sensor body roles.
- The world steps on a fixed timestep to keep simulation deterministic across frame rates.
- Bodies carry type, transform, collision filtering, and motion configuration.
- Shape support includes circles, rectangles, polygons, edges, and chain boundaries.
- Shape material settings include density, friction, and restitution.
- Continuous collision detection is available for fast-moving bodies.
- Broad and narrow phase collision processing is owned by the world runtime.
- Contact events are captured and exposed as stable post-step records.
- Lua callbacks can subscribe to begin-contact and end-contact transitions.
- Spatial queries include raycast, point test, and area overlap helpers.
- Lightweight geometry helpers are available outside the full world object.
- Joint support enables hinges, sliders, ropes, welds, and motorized constraints.
- Joint limits and break thresholds support mechanical gameplay behaviors.
- Sleeping policies reduce CPU load for resting bodies.
- Wake/sleep controls are script-accessible when deterministic activation is required.
- Layer/mask filtering controls collision participation between groups.
- Zone systems apply local gravity and damping overrides by area.
- Zone priorities and masks resolve overlapping environmental effects.
- Terrain integration supports destructible cell maps linked to collider rebuilds.
- Chunk-local terrain updates avoid global rebuild cost.
- Merged terrain spans reduce static collider count.
- Terrain supports serialization and diagnostic image export.
- Debug rendering exposes bodies, vectors, and contact-oriented visuals.
- Diagnostic colors help separate body categories in dense scenes.
- Pixels-to-meters mapping keeps gameplay and solver scales coherent.
- The module owns physical simulation and queries, not game-domain policy.
- It collaborates with render/runtime/math/image through bounded interfaces.
- Error handling and validation protect against invalid shape/world inputs.
- APIs support both high-level helpers and detailed body control.
- The module is suitable for platformers, top-down motion, and destructible worlds.
- Contracts are tuned for deterministic tests and reproducible runtime behavior.
- Physics remains a Platform Services backend used by many feature modules.
- Overall, physics is the authoritative source of movement and collision truth.
- It provides performance-aware simulation with practical debugging support.
- It is designed for production stability under mixed gameplay workloads.
- The module keeps integration explicit to reduce hidden side effects.
- Invariants prioritize stable step ordering and predictable contact semantics.
- Query results are aligned with the same world state used by solver progression.
- This consistency is critical for AI, gameplay, and tool integrations.
- Physics is a core technical pillar for interactive 2D experiences.

This module primarily collaborates with `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Files

### body.rs

- Physics body description layer that gathers the state a simulation object needs before or while it lives inside the world.
- The file defines the playable vocabulary of rigid body roles such as dynamic movers, fixed solids, script-driven kinematics, and overlap-only sensors.
- It also binds those roles to supported geometry forms, material defaults, collision filtering, and transform helpers so a body can be reasoned about as one coherent unit.
- Constructors emphasize ready-to-use authoring by filling in sensible density, friction, restitution, and motion settings rather than forcing every caller to spell out raw fields.
- Geometry utilities keep body space and world space connected, which matters for bounds queries, spawn setup, editor tooling, and shape-aware logic outside the solver.
- Functionally this file delivers the authored physical identity of an object before the broader world machinery turns it into live simulated behavior.

### collision.rs

- Collision event buffering for the moments when physical contact needs to become stable gameplay information instead of transient solver state.
- The file packages body pairs, normals, penetration data, and sensor transitions into an ordered queue that can be drained after stepping without disturbing the simulation loop.
- Functionally this delivers the bridge from raw contact detection to script-consumable collision events with clean step-boundary timing.

### collision_helpers.rs

- Lightweight geometry overlap helpers for code that needs quick collision answers without standing up a full physics world.
- The file keeps AABB, circle, and point tests allocation-free and side-effect free so they fit hot loops, culling, and cheap gameplay probes.
- Functionally this delivers the smallest collision vocabulary for fast spatial checks in plain screen-space coordinates.

### mod.rs

- Platform-level 2D physics module that unifies authored bodies, geometric shapes, simulation stepping, spatial queries, terrain sync, and trigger-style environmental effects.
- It exposes the major surfaces of the subsystem as one coherent toolbox, from lightweight helper tests through full world simulation and debug-oriented support structures.
- Functionally this file is the high-level entry point for physical interaction, movement constraints, collision reporting, and physics-backed world state in Lurek2D.

### render.rs

- Physics debug rendering layer for turning invisible simulation state into visible lines, outlines, and motion cues that developers can inspect frame by frame.
- The file translates bodies and shapes into render-friendly snapshots without changing the simulation, letting diagnostics live beside gameplay rather than inside it.
- Type-based coloring keeps static, dynamic, kinematic, and sensor objects readable at a glance when scenes grow dense.
- Velocity arrows and shape outlines expose both form and movement so developers can see why contacts, tunnels, or odd impulses are happening.
- Functionally this delivers the visual instrumentation needed to understand, tune, and trust the physics subsystem during development.

### shape.rs

- Physics shape definition layer that gives the subsystem a compact language for circles, rectangles, polygons, edges, and chained outlines.
- The file keeps geometry authoring, validation, and collider conversion close together so malformed inputs can be rejected before they become unstable runtime fixtures.
- Parsing and regular-polygon construction make the surface practical for scripts, tools, and data-driven content that describe shape intent rather than raw engine objects.
- Standalone shapes carry material and sensor settings alongside geometry, which lets authored collision pieces travel with the properties that affect how they behave in the world.
- Local bounding logic keeps each shape queryable without needing a live body, which is useful for previews, authoring tools, and lightweight reasoning.
- Functionally this file delivers the reusable geometry vocabulary that both bodies and higher-level physics workflows build upon.

### terrain.rs

- Destructible terrain map layer that turns editable solid cells into physics-ready world geometry without making callers manage collider lifecycles manually.
- The file tracks terrain in chunks so local edits stay local, allowing flush operations to rebuild only the regions that actually changed.
- Fill tools support live terrain authoring and destruction patterns such as circles, rectangles, blanket writes, and other broad modifications during play.
- Row merging keeps the generated static-body footprint compact, which matters when large tile fields must remain interactive without exploding collider counts.
- Serialization and image output make the terrain usable for save systems, tooling, previews, and data exchange outside the immediate simulation step.
- Debris spawning and collapse helpers push the system beyond passive walls into active destructible-environment behavior.
- Functionally this file delivers the editable ground model that connects tile logic, destruction effects, and efficient static collision rebuilds.

### types.rs

- Small core type surface for the physics subsystem where stable identifiers need stronger meaning than a bare integer can provide.
- The file wraps body identity in a dedicated type so physics handles remain cheap to pass around while still reading as deliberate domain values.
- Functionally this delivers the low-friction type safety that keeps body references explicit across Rust and Lua-facing boundaries.

### world.rs

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

### zone.rs

- Physics zone system for spatial rule overrides that should apply because a body is somewhere, not because it touched a solid object.
- The file defines bounded areas that can replace normal gravity with directional pull, attraction, repulsion, or weightless behavior.
- Priority and mask filtering let multiple zones coexist without turning area-based effects into ambiguous global state.
- Damping overrides make zones useful for liquids, mud, low-friction fields, or other environmental modifiers that change motion feel.
- Enter and leave tracking turns zones into event sources as well as force fields, which is important for scripting and gameplay transitions.
- Functionally this file delivers area-driven physics behavior for environmental control, special spaces, and location-sensitive simulation rules.

## Types

- `BodyType` (`enum`, `body.rs`): Simulation role of a physics body. Details: variants: Static, Dynamic, Kinematic, Sensor
- `BodyShape` (`enum`, `body.rs`): Primitive collision shape baked into the body descriptor. Details: variants: Rect, Circle
- `Body` (`struct`, `body.rs`): Data-only description of a physics body passed to `World` for simulation. Details: fields: position: Vec2, velocity: Vec2, mass: f32, body_type: BodyType, shape: BodyShape, restitution: f32, layer: u32, mask: u32, width: f32, height: f32, friction: f32, angle: f32, angular_velocity: f32, shape_ext: Option<Shape> | methods: bounding_box (Return the axis-aligned bounding box of this body in world space.); collides_with_layer (Return true when this body's layer and mask are compatible with `other`.); get_bounding_box (Return the bounding box as `(x, y, width, height)` tuple.); get_local_point (Convert a world-space position to a local-space offset accounting for body rotation.); get_type (Return the body type as a static string slice.); get_world_point (Convert a local-space offset to world-space position accounting for body rotation.); new (Create a rectangular body at `(x,y)` with explicit `(w,h)` dimensions.); new_chain (Create a chain (open or closed polyline) body anchored at `(x,y)`.); new_circle (Create a circular body at `(x,y)` with the given `radius`.); new_edge (Create an edge (line segment) body from `v1` to `v2` anchored at `(x,y)`.); new_polygon (Create a polygon body at `(x,y)` from a vertex list; AABB derived from vertex bounds.)
- `CollisionInfo` (`struct`, `collision.rs`): Result of a collision detection query. Details: fields: penetration: f32, normal: Vec2
- `Shape` (`enum`, `shape.rs`): Physics primitive shape used in `Body` and `StandaloneShape`. Details: variants: Rect, Circle, Polygon, Edge, Chain | methods: from_parts (Parse a shape from a string type tag and flat argument list; `closed` applies to chains.); regular_polygon (Create a regular convex polygon with `sides` (clamped 3–8) inscribed in `radius`.); to_rapier_collider (Convert this shape to a rapier `ColliderBuilder`; return `None` for degenerate inputs.)
- `StandaloneShape` (`struct`, `shape.rs`): A `Shape` combined with material properties for standalone collision testing. Details: fields: shape: Shape, density: f32, friction: f32, restitution: f32, sensor: bool | methods: get_bounding_box (Return the local-space AABB as `(min_x, min_y, max_x, max_y)`.); get_radius (Return the circle radius when the inner shape is a `Circle`; otherwise `None`.); get_type (Return a static string label for the shape type.); new (Create a standalone shape with default material values.)
- `ChunkId` (`struct`, `terrain.rs`): Key identifying a chunk by its chunk-grid coordinates. Details: fields: cx: u32, cy: u32
- `TerrainMap` (`struct`, `terrain.rs`): Tile-based terrain map that synchronises static physics bodies with a `World`. Details: fields: width: u32, height: u32, cell_size: f32, offset_x: f32, offset_y: f32 | methods: collapse_columns (Remove isolated single-cell pillars with no support; return the count removed.); fill_all (Set every cell to `solid` and mark all chunks dirty.); fill_circle (Set all cells within `radius` world units of `(wx,wy)` to `solid`.); fill_rect (Set all cells overlapping the world-space rectangle to `solid`.); flush (Rebuild bodies in all dirty chunks and sync them into `world`.); from_bytes (Deserialise from a byte buffer produced by `to_bytes`; marks all chunks dirty; return `None` on error.); get_cell (Return whether cell `(cx,cy)` is solid; false when out of bounds.); is_dirty (Return true when any chunks are pending a `flush`.); load_from_bytes (Load bytes into this map if dimensions match; return false on mismatch or parse error.); new (Create an empty terrain map of `width`×`height` cells with `cell_size` world units each.); set_cell (Set the solid state of cell `(cx,cy)`; marks the owning chunk dirty when the value changes.); solid_cell_positions (Return the world-space centres of all solid cells.); spawn_debris_at (Spawn a dynamic debris body in `world` for each position in `positions`; return body ids.); to_bytes (Serialise to a compact byte buffer: `width u32 LE` + `height u32 LE` + `cell_size f32 LE` + bitpacked cells.); to_image_data (Encode the terrain as RGBA pixel data using `solid_rgba` and `empty_rgba`.)
- `BodyId` (`struct`, `types.rs`): Unique identifier for a physics body. Details: methods: new (Creates a new BodyId from a raw usize.); raw (Returns the raw usize underlying value.)
- `BodyContact` (`struct`, `world.rs`): A pair of body ids that have started or are overlapping. Details: fields: body_a: BodyId, body_b: BodyId
- `RaycastHit` (`struct`, `world.rs`): The closest raycast intersection result. Details: fields: body_id: BodyId, point: (f32, normal: (f32, toi: f32
- `ContactInfo` (`struct`, `world.rs`): Contact information between two bodies. Details: fields: body_a: BodyId, body_b: BodyId, normal_x: f32, normal_y: f32, is_touching: bool
- `PhysicsShapeSnapshot` (`struct`, `world.rs`): Snapshot of a physics shape used for debug rendering. Details: fields: x: f32, y: f32, half_w: f32, half_h: f32, angle: f32, is_static: bool, is_sleeping: bool, is_sensor: bool, is_circle: bool, hull_verts: Vec<[f32; 2]>
- `PhysicsQueryFilter` (`struct`, `world.rs`): Optional filters applied to physics spatial queries. Details: fields: layer: Option<u32>, mask: Option<u32>, include_sensors: bool
- `PhysicsWorldStats` (`struct`, `world.rs`): Lightweight world diagnostics for Lua/editor tooling. Details: fields: bodies: usize, body_slots: usize, colliders: usize, joints: usize, joint_slots: usize, zones: usize, sleeping_bodies: usize
- `World` (`struct`, `world.rs`): Full rapier2d-backed simulation world. Details: methods: add_bodies (Batch-create bodies from a list of `(x, y, w, h, BodyType)` tuples; return their ids.); add_body (Insert a body into the world and return its id.); add_distance_joint (Add a distance (rope) joint between two bodies; return joint id.); add_fixture (Add an extra collider shape to an existing body; returns the fixture index.); add_friction_joint (Add a friction joint limiting linear and angular impulses; return joint id.); add_gear_joint (Add a gear joint (falls back to weld; logs a warning); return joint id.); add_motor_joint (Add a spring-motor joint for position correction; return joint id.); add_mouse_joint (Create a kinematic anchor and a spring joint targeting `(target_x, target_y)`; return joint id.); add_prismatic_joint (Add a prismatic (slide-axis) joint between two bodies; return joint id.); add_pulley_joint (Add a pulley joint (falls back to weld; logs a warning); return joint id.); add_revolute_joint (Add a revolute joint between two bodies at the given local anchor; return joint id.); add_rope_joint (Add a rope joint with a maximum length; return joint id.); add_weld_joint (Add a weld (fixed) joint between two bodies; return joint id.); add_wheel_joint (Add a wheel-style prismatic joint; return joint id.); add_zone (Register a trigger zone and return its id.); apply_angular_impulse (Apply an angular impulse to body `id`.); apply_force (Apply a continuous force `(fx, fy)` to body `id` this step.); apply_force_at_point (Apply force `(fx, fy)` at world point `(px, py)` on body `id`.); apply_impulse (Apply a linear impulse `(ix, iy)` to body `id`.); apply_torque (Apply a torque to body `id` this step.); apply_zone_forces (Apply per-zone gravity/damping overrides to all bodies; updates zone enter/exit events.); body_count (Return the total number of bodies in the world.); clear (Remove all bodies, joints, and zones; reset rapier sets.); clear_body_one_way (Remove the one-way constraint from body `id`.); destroy_body (Disable body `id`; it will no longer participate in simulation.); destroy_joint (Remove joint `joint_id` from the simulation.); draw_debug_to_image (Draw all body outlines onto an RGBA `ImageData` using the given colour.); draw_to_image (Rasterise all bodies onto a `width`×`height` `ImageData` centered at the origin.); extract_shape_snapshots (Return a snapshot of all body shapes suitable for debug rendering.); fixture_count (Return the number of colliders attached to `body_id`.); generate_render_commands (Build a list of `RenderCommand`s drawing outlines and velocity arrows for all bodies.); get_angular_damping (Return angular damping of body `id`; returns 0 if out of range.); get_angular_velocity (Return angular velocity of body `id` in radians/second; returns 0 if out of range.); get_begin_contact_events (Return body-pair ids that began touching during the last `step`.); get_body (Return a shared reference to body `id`, or `None` if out of range.); get_body_angle (Return rotation angle of body `id` in radians; returns 0 if out of range.); get_body_at_point (Return the first body id whose AABB contains point `(x, y)`, or `None`.); get_body_at_point_filtered (Return the first filtered body id whose AABB contains point `(x, y)`, or `None`.); get_body_contacts (Return contacts involving body `body_id` filtered from `get_contacts`.); get_body_ids (Return all valid body ids as a `Vec`.); get_body_mass (Return the mass of body `id`; returns 0 if out of range.); get_body_mut (Return a mutable reference to body `id`, or `None` if out of range.); get_body_one_way (Return the one-way normal for body `id`, or `None` if not set.); get_body_type_str (Return the body-type string of `id`; returns "dynamic" if out of range.); get_collision_events (Return overlap events collected during the last `step`.); get_contacts (Return all active contact pairs with normals and touch state.); get_end_contact_events (Return body-pair ids that stopped touching during the last `step`.); get_gravity (Return world gravity as `(gx, gy)`.); get_gravity_scale (Return gravity scale of body `id`; returns 1.0 if out of range.); get_joint_bodies (Return the two body ids connected by `joint_id`, or `None` if not found.); get_joint_break_force (Return the break-force threshold for joint `jid`, or `None` if not set.); get_joint_ids (Return all valid joint ids as a `Vec`.); get_joint_limits (Return `(lower, upper)` angular limits on joint `joint_id`; returns `(0,0)` if not set.); get_joint_motor_speed (Return angular motor target speed on joint `joint_id`; returns 0 if not set.); get_joint_type (Return the type string of joint `joint_id`; returns "unknown" if out of range.); get_linear_damping (Return linear damping of body `id`; returns 0 if out of range.); get_meter (Return the current pixels-per-meter ratio.); get_solver_iterations (Return the current number of solver iterations.); get_stats (Return current world diagnostics for tooling and scripts.); get_zone_events (Return zone enter/exit events from the last `step`.); has_body (Return true when a body id names a live body slot.); has_joint (Return true when a joint id names a live joint slot.); is_body_sleeping (Return true if body `id` is currently asleep.); is_bullet (Return true if CCD is enabled on body `id`.); is_fixed_rotation (Return true if rotation is locked on body `id`.); is_sleeping_allowed (Return true if body `id` is permitted to sleep.); joint_count (Return the number of registered joints.); new (Create a world with gravity `(gx, gy)` in pixels/s².); query_aabb (Return all body ids whose AABB overlaps the query rectangle.); query_aabb_filtered (Return all filtered body ids whose AABB overlaps the query rectangle.); raycast (Cast a ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.); raycast_all (Cast a ray from `(x1,y1)` in direction `(dx,dy)` and return all hits up to `max_dist`.); raycast_all_filtered (Cast a filtered ray and return at most one closest hit per body.); raycast_closest (Cast a ray from `(x1,y1)` in direction `(dx,dy)` up to `max_dist`; return closest hit.); raycast_closest_filtered (Cast a filtered directional ray and return the closest hit.); raycast_filtered (Cast a filtered ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.); remove_zone (Remove the zone with the given id.); set_angular_damping (Set angular damping coefficient on body `id`.); set_angular_velocity (Set angular velocity of body `id` in radians/second.); set_body_angle (Set the rotation angle of body `id` in radians.); set_body_mass (Override mass of body `id`.); set_body_one_way (Enable one-way platform behaviour: only accept collisions with a normal aligned to `(nx,ny)`.); set_body_position (Teleport body `id` to world position `(x, y)`.); set_body_type (Change the body type of `id` and rebuild its collider.); set_bullet (Enable or disable CCD (continuous collision detection) on body `id`.); set_fixed_rotation (Lock or unlock rotation for body `id`.); set_fixture_friction (Set friction on a specific fixture of `body_id`.); set_fixture_restitution (Set restitution (bounciness) on a specific fixture of `body_id`.); set_fixture_sensor (Enable or disable the sensor flag on a specific fixture of `body_id`.); set_gravity (Set world gravity to `(gx, gy)`.); set_gravity_scale (Set gravity scale multiplier on body `id`.); set_joint_break_force (Register a break force threshold for joint `jid`.); set_joint_limits (Set `[lower, upper]` angular limits on joint `joint_id`.); set_joint_limits_enabled (Enable or disable angular limits on joint `joint_id`.); set_joint_motor_speed (Set angular motor target speed on joint `joint_id`.); set_linear_damping (Set linear damping coefficient on body `id`.); set_meter (Set the pixels-per-meter conversion ratio.); set_mouse_joint_target (Reposition the kinematic anchor of mouse joint `joint_id` to `(x, y)`.); set_sleeping_allowed (Allow or permanently prevent sleeping for body `id`.); set_solver_iterations (Set the number of solver iterations (minimum 1).); sleep_body (Force body `id` to sleep immediately.); step (Step the simulation by `dt` seconds; synchronises body state with rapier.); step_fixed (Run up to `max_steps` fixed substeps using `step_dt`; return steps taken and leftover dt.); to_physics (Convert a pixel distance to physics-space metres.); to_pixels (Convert a physics-space metre distance to pixels.); wake_up_body (Wake up body `id` from sleep.); zone_mut (Return a mutable reference to zone `id`, or `None` if not found.)
- `ZoneId` (`type`, `zone.rs`): Alias for a zone's numeric identifier.
- `ZonePriority` (`type`, `zone.rs`): Alias for zone processing priority (higher wins).
- `ZoneGravityMode` (`enum`, `zone.rs`): Gravity behaviour applied to bodies inside the zone. Details: variants: Directional, Point, Repulsor, Zero
- `ZoneBoundary` (`enum`, `zone.rs`): Spatial boundary shape for a zone. Details: variants: Rect, Circle | methods: contains (Return true if point `(px, py)` is inside this boundary.)
- `ZoneEventKind` (`enum`, `zone.rs`): Zone enter/exit event discriminant. Details: variants: Enter, Leave
- `ZoneEvent` (`struct`, `zone.rs`): A zone crossing event emitted by `ZoneTracker::update`. Details: fields: zone_id: ZoneId, body_id: usize, kind: ZoneEventKind
- `PhysicsZone` (`struct`, `zone.rs`): A trigger zone that applies gravity and damping overrides to bodies inside it. Details: fields: id: ZoneId, boundary: ZoneBoundary, gravity_mode: ZoneGravityMode, priority: ZonePriority, linear_damping_override: Option<f32>, angular_damping_override: Option<f32>, layer_mask: u32, enabled: bool | methods: contains (Return true if the zone is enabled and the point `(px, py)` is inside its boundary.); new_rect (Create a rectangular zone with zero gravity and default layer mask.); set_circle (Replace the boundary with a circle centred at `(cx, cy)` with given `radius`.); set_gravity_directional (Set constant directional gravity `(gx, gy)` for this zone.); set_gravity_point (Set point-attractor gravity centred at `(cx, cy)` with given `strength`.); set_gravity_repulsor (Set repulsor gravity pushing away from `(cx, cy)` with given `strength`.); set_gravity_zero (Set zero gravity for this zone.)
- `ZoneTracker` (`struct`, `zone.rs`): Tracks which bodies are inside which zones to generate enter/exit events. Details: methods: clear (Clear all per-body zone state.); new (Create an empty tracker.); remove_body (Remove all zone tracking state for `body_id`.); update (Diff `new_zones` against stored state for `body_id`; emit enter/leave events and update.)

## Functions

- `Body::new` (`body.rs`): Create a rectangular body at `(x,y)` with explicit `(w,h)` dimensions.
- `Body::new_circle` (`body.rs`): Create a circular body at `(x,y)` with the given `radius`.
- `Body::new_polygon` (`body.rs`): Create a polygon body at `(x,y)` from a vertex list; AABB derived from vertex bounds.
- `Body::new_edge` (`body.rs`): Create an edge (line segment) body from `v1` to `v2` anchored at `(x,y)`.
- `Body::new_chain` (`body.rs`): Create a chain (open or closed polyline) body anchored at `(x,y)`.
- `Body::bounding_box` (`body.rs`): Return the axis-aligned bounding box of this body in world space.
- `Body::collides_with_layer` (`body.rs`): Return true when this body's layer and mask are compatible with `other`.
- `Body::get_bounding_box` (`body.rs`): Return the bounding box as `(x, y, width, height)` tuple.
- `Body::get_type` (`body.rs`): Return the body type as a static string slice.
- `Body::get_world_point` (`body.rs`): Convert a local-space offset to world-space position accounting for body rotation.
- `Body::get_local_point` (`body.rs`): Convert a world-space position to a local-space offset accounting for body rotation.
- `test_aabb` (`collision_helpers.rs`): Return true when two AABBs overlap (axes: x-right, y-down).
- `test_circles` (`collision_helpers.rs`): Return true when two circles overlap given center positions and radii.
- `test_point_aabb` (`collision_helpers.rs`): Return true when point `(px,py)` lies inside the AABB.
- `test_circle_aabb` (`collision_helpers.rs`): Return true when circle `(cx,cy,cr)` overlaps the AABB.
- `World::generate_render_commands` (`render.rs`): Build a list of `RenderCommand`s drawing outlines and velocity arrows for all bodies.
- `World::draw_to_image` (`render.rs`): Rasterise all bodies onto a `width`×`height` `ImageData` centered at the origin.
- `Shape::to_rapier_collider` (`shape.rs`): Convert this shape to a rapier `ColliderBuilder`; return `None` for degenerate inputs.
- `Shape::from_parts` (`shape.rs`): Parse a shape from a string type tag and flat argument list; `closed` applies to chains.
- `Shape::regular_polygon` (`shape.rs`): Create a regular convex polygon with `sides` (clamped 3–8) inscribed in `radius`.
- `StandaloneShape::new` (`shape.rs`): Create a standalone shape with default material values.
- `StandaloneShape::get_type` (`shape.rs`): Return a static string label for the shape type.
- `StandaloneShape::get_radius` (`shape.rs`): Return the circle radius when the inner shape is a `Circle`; otherwise `None`.
- `StandaloneShape::get_bounding_box` (`shape.rs`): Return the local-space AABB as `(min_x, min_y, max_x, max_y)`.
- `TerrainMap::new` (`terrain.rs`): Create an empty terrain map of `width`×`height` cells with `cell_size` world units each.
- `TerrainMap::set_cell` (`terrain.rs`): Set the solid state of cell `(cx,cy)`; marks the owning chunk dirty when the value changes.
- `TerrainMap::get_cell` (`terrain.rs`): Return whether cell `(cx,cy)` is solid; false when out of bounds.
- `TerrainMap::fill_circle` (`terrain.rs`): Set all cells within `radius` world units of `(wx,wy)` to `solid`.
- `TerrainMap::fill_rect` (`terrain.rs`): Set all cells overlapping the world-space rectangle to `solid`.
- `TerrainMap::fill_all` (`terrain.rs`): Set every cell to `solid` and mark all chunks dirty.
- `TerrainMap::is_dirty` (`terrain.rs`): Return true when any chunks are pending a `flush`.
- `TerrainMap::flush` (`terrain.rs`): Rebuild bodies in all dirty chunks and sync them into `world`.
- `TerrainMap::collapse_columns` (`terrain.rs`): Remove isolated single-cell pillars with no support; return the count removed.
- `TerrainMap::solid_cell_positions` (`terrain.rs`): Return the world-space centres of all solid cells.
- `TerrainMap::spawn_debris_at` (`terrain.rs`): Spawn a dynamic debris body in `world` for each position in `positions`; return body ids.
- `TerrainMap::to_image_data` (`terrain.rs`): Encode the terrain as RGBA pixel data using `solid_rgba` and `empty_rgba`.
- `TerrainMap::to_bytes` (`terrain.rs`): Serialise to a compact byte buffer: `width u32 LE` + `height u32 LE` + `cell_size f32 LE` + bitpacked cells.
- `TerrainMap::from_bytes` (`terrain.rs`): Deserialise from a byte buffer produced by `to_bytes`; marks all chunks dirty; return `None` on error.
- `TerrainMap::load_from_bytes` (`terrain.rs`): Load bytes into this map if dimensions match; return false on mismatch or parse error.
- `BodyId::new` (`types.rs`): Creates a new BodyId from a raw usize.
- `BodyId::raw` (`types.rs`): Returns the raw usize underlying value.
- `World::draw_debug_to_image` (`world.rs`): Draw all body outlines onto an RGBA `ImageData` using the given colour.
- `World::extract_shape_snapshots` (`world.rs`): Return a snapshot of all body shapes suitable for debug rendering.
- `World::new` (`world.rs`): Create a world with gravity `(gx, gy)` in pixels/s².
- `World::has_body` (`world.rs`): Return true when a body id names a live body slot.
- `World::has_joint` (`world.rs`): Return true when a joint id names a live joint slot.
- `World::add_body` (`world.rs`): Insert a body into the world and return its id.
- `World::add_fixture` (`world.rs`): Add an extra collider shape to an existing body; returns the fixture index.
- `World::fixture_count` (`world.rs`): Return the number of colliders attached to `body_id`.
- `World::set_fixture_friction` (`world.rs`): Set friction on a specific fixture of `body_id`.
- `World::set_fixture_restitution` (`world.rs`): Set restitution (bounciness) on a specific fixture of `body_id`.
- `World::set_fixture_sensor` (`world.rs`): Enable or disable the sensor flag on a specific fixture of `body_id`.
- `World::get_body` (`world.rs`): Return a shared reference to body `id`, or `None` if out of range.
- `World::get_body_mut` (`world.rs`): Return a mutable reference to body `id`, or `None` if out of range.
- `World::body_count` (`world.rs`): Return the total number of bodies in the world.
- `World::add_revolute_joint` (`world.rs`): Add a revolute joint between two bodies at the given local anchor; return joint id.
- `World::raycast` (`world.rs`): Cast a ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.
- `World::raycast_filtered` (`world.rs`): Cast a filtered ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.
- `World::step` (`world.rs`): Step the simulation by `dt` seconds; synchronises body state with rapier.
- `World::apply_impulse` (`world.rs`): Apply a linear impulse `(ix, iy)` to body `id`.
- `World::get_collision_events` (`world.rs`): Return overlap events collected during the last `step`.
- `World::get_begin_contact_events` (`world.rs`): Return body-pair ids that began touching during the last `step`.
- `World::get_end_contact_events` (`world.rs`): Return body-pair ids that stopped touching during the last `step`.
- `World::add_zone` (`world.rs`): Register a trigger zone and return its id.
- `World::remove_zone` (`world.rs`): Remove the zone with the given id.
- `World::zone_mut` (`world.rs`): Return a mutable reference to zone `id`, or `None` if not found.
- `World::get_zone_events` (`world.rs`): Return zone enter/exit events from the last `step`.
- `World::apply_zone_forces` (`world.rs`): Apply per-zone gravity/damping overrides to all bodies; updates zone enter/exit events.
- `World::step_fixed` (`world.rs`): Run up to `max_steps` fixed substeps using `step_dt`; return steps taken and leftover dt.
- `World::set_body_position` (`world.rs`): Teleport body `id` to world position `(x, y)`.
- `World::apply_force` (`world.rs`): Apply a continuous force `(fx, fy)` to body `id` this step.
- `World::apply_torque` (`world.rs`): Apply a torque to body `id` this step.
- `World::set_angular_velocity` (`world.rs`): Set angular velocity of body `id` in radians/second.
- `World::get_angular_velocity` (`world.rs`): Return angular velocity of body `id` in radians/second; returns 0 if out of range.
- `World::get_body_angle` (`world.rs`): Return rotation angle of body `id` in radians; returns 0 if out of range.
- `World::set_body_angle` (`world.rs`): Set the rotation angle of body `id` in radians.
- `World::get_body_mass` (`world.rs`): Return the mass of body `id`; returns 0 if out of range.
- `World::set_body_mass` (`world.rs`): Override mass of body `id`.
- `World::set_gravity_scale` (`world.rs`): Set gravity scale multiplier on body `id`.
- `World::set_fixed_rotation` (`world.rs`): Lock or unlock rotation for body `id`.
- `World::set_linear_damping` (`world.rs`): Set linear damping coefficient on body `id`.
- `World::set_angular_damping` (`world.rs`): Set angular damping coefficient on body `id`.
- `World::get_gravity_scale` (`world.rs`): Return gravity scale of body `id`; returns 1.0 if out of range.
- `World::is_fixed_rotation` (`world.rs`): Return true if rotation is locked on body `id`.
- `World::get_linear_damping` (`world.rs`): Return linear damping of body `id`; returns 0 if out of range.
- `World::get_angular_damping` (`world.rs`): Return angular damping of body `id`; returns 0 if out of range.
- `World::set_bullet` (`world.rs`): Enable or disable CCD (continuous collision detection) on body `id`.
- `World::is_bullet` (`world.rs`): Return true if CCD is enabled on body `id`.
- `World::apply_force_at_point` (`world.rs`): Apply force `(fx, fy)` at world point `(px, py)` on body `id`.
- `World::apply_angular_impulse` (`world.rs`): Apply an angular impulse to body `id`.
- `World::get_body_ids` (`world.rs`): Return all valid body ids as a `Vec`.
- `World::get_joint_ids` (`world.rs`): Return all valid joint ids as a `Vec`.
- `World::get_body_type_str` (`world.rs`): Return the body-type string of `id`; returns "dynamic" if out of range.
- `World::set_body_type` (`world.rs`): Change the body type of `id` and rebuild its collider.
- `World::get_gravity` (`world.rs`): Return world gravity as `(gx, gy)`.
- `World::set_gravity` (`world.rs`): Set world gravity to `(gx, gy)`.
- `World::clear` (`world.rs`): Remove all bodies, joints, and zones; reset rapier sets.
- `World::set_sleeping_allowed` (`world.rs`): Allow or permanently prevent sleeping for body `id`.
- `World::is_sleeping_allowed` (`world.rs`): Return true if body `id` is permitted to sleep.
- `World::destroy_body` (`world.rs`): Disable body `id`; it will no longer participate in simulation.
- `World::joint_count` (`world.rs`): Return the number of registered joints.
- `World::add_distance_joint` (`world.rs`): Add a distance (rope) joint between two bodies; return joint id.
- `World::add_prismatic_joint` (`world.rs`): Add a prismatic (slide-axis) joint between two bodies; return joint id.
- `World::add_weld_joint` (`world.rs`): Add a weld (fixed) joint between two bodies; return joint id.
- `World::add_rope_joint` (`world.rs`): Add a rope joint with a maximum length; return joint id.
- `World::get_joint_bodies` (`world.rs`): Return the two body ids connected by `joint_id`, or `None` if not found.
- `World::destroy_joint` (`world.rs`): Remove joint `joint_id` from the simulation.
- `World::raycast_closest` (`world.rs`): Cast a ray from `(x1,y1)` in direction `(dx,dy)` up to `max_dist`; return closest hit.
- `World::raycast_closest_filtered` (`world.rs`): Cast a filtered directional ray and return the closest hit.
- `World::raycast_all` (`world.rs`): Cast a ray from `(x1,y1)` in direction `(dx,dy)` and return all hits up to `max_dist`.
- `World::raycast_all_filtered` (`world.rs`): Cast a filtered ray and return at most one closest hit per body.
- `World::query_aabb` (`world.rs`): Return all body ids whose AABB overlaps the query rectangle.
- `World::query_aabb_filtered` (`world.rs`): Return all filtered body ids whose AABB overlaps the query rectangle.
- `World::get_body_at_point` (`world.rs`): Return the first body id whose AABB contains point `(x, y)`, or `None`.
- `World::get_body_at_point_filtered` (`world.rs`): Return the first filtered body id whose AABB contains point `(x, y)`, or `None`.
- `World::add_wheel_joint` (`world.rs`): Add a wheel-style prismatic joint; return joint id.
- `World::add_friction_joint` (`world.rs`): Add a friction joint limiting linear and angular impulses; return joint id.
- `World::add_motor_joint` (`world.rs`): Add a spring-motor joint for position correction; return joint id.
- `World::add_mouse_joint` (`world.rs`): Create a kinematic anchor and a spring joint targeting `(target_x, target_y)`; return joint id.
- `World::set_mouse_joint_target` (`world.rs`): Reposition the kinematic anchor of mouse joint `joint_id` to `(x, y)`.
- `World::add_pulley_joint` (`world.rs`): Add a pulley joint (falls back to weld; logs a warning); return joint id.
- `World::add_gear_joint` (`world.rs`): Add a gear joint (falls back to weld; logs a warning); return joint id.
- `World::set_joint_motor_speed` (`world.rs`): Set angular motor target speed on joint `joint_id`.
- `World::get_joint_motor_speed` (`world.rs`): Return angular motor target speed on joint `joint_id`; returns 0 if not set.
- `World::set_joint_limits_enabled` (`world.rs`): Enable or disable angular limits on joint `joint_id`.
- `World::set_joint_limits` (`world.rs`): Set `[lower, upper]` angular limits on joint `joint_id`.
- `World::get_joint_limits` (`world.rs`): Return `(lower, upper)` angular limits on joint `joint_id`; returns `(0,0)` if not set.
- `World::get_joint_type` (`world.rs`): Return the type string of joint `joint_id`; returns "unknown" if out of range.
- `World::set_meter` (`world.rs`): Set the pixels-per-meter conversion ratio.
- `World::get_meter` (`world.rs`): Return the current pixels-per-meter ratio.
- `World::to_physics` (`world.rs`): Convert a pixel distance to physics-space metres.
- `World::to_pixels` (`world.rs`): Convert a physics-space metre distance to pixels.
- `World::get_contacts` (`world.rs`): Return all active contact pairs with normals and touch state.
- `World::get_body_contacts` (`world.rs`): Return contacts involving body `body_id` filtered from `get_contacts`.
- `World::set_body_one_way` (`world.rs`): Enable one-way platform behaviour: only accept collisions with a normal aligned to `(nx,ny)`.
- `World::clear_body_one_way` (`world.rs`): Remove the one-way constraint from body `id`.
- `World::get_body_one_way` (`world.rs`): Return the one-way normal for body `id`, or `None` if not set.
- `World::set_joint_break_force` (`world.rs`): Register a break force threshold for joint `jid`.
- `World::get_joint_break_force` (`world.rs`): Return the break-force threshold for joint `jid`, or `None` if not set.
- `World::is_body_sleeping` (`world.rs`): Return true if body `id` is currently asleep.
- `World::wake_up_body` (`world.rs`): Wake up body `id` from sleep.
- `World::sleep_body` (`world.rs`): Force body `id` to sleep immediately.
- `World::set_solver_iterations` (`world.rs`): Set the number of solver iterations (minimum 1).
- `World::get_solver_iterations` (`world.rs`): Return the current number of solver iterations.
- `World::get_stats` (`world.rs`): Return current world diagnostics for tooling and scripts.
- `World::add_bodies` (`world.rs`): Batch-create bodies from a list of `(x, y, w, h, BodyType)` tuples; return their ids.
- `ZoneBoundary::contains` (`zone.rs`): Return true if point `(px, py)` is inside this boundary.
- `PhysicsZone::new_rect` (`zone.rs`): Create a rectangular zone with zero gravity and default layer mask.
- `PhysicsZone::set_circle` (`zone.rs`): Replace the boundary with a circle centred at `(cx, cy)` with given `radius`.
- `PhysicsZone::set_gravity_directional` (`zone.rs`): Set constant directional gravity `(gx, gy)` for this zone.
- `PhysicsZone::set_gravity_point` (`zone.rs`): Set point-attractor gravity centred at `(cx, cy)` with given `strength`.
- `PhysicsZone::set_gravity_repulsor` (`zone.rs`): Set repulsor gravity pushing away from `(cx, cy)` with given `strength`.
- `PhysicsZone::set_gravity_zero` (`zone.rs`): Set zero gravity for this zone.
- `PhysicsZone::contains` (`zone.rs`): Return true if the zone is enabled and the point `(px, py)` is inside its boundary.
- `ZoneTracker::new` (`zone.rs`): Create an empty tracker.
- `ZoneTracker::update` (`zone.rs`): Diff `new_zones` against stored state for `body_id`; emit enter/leave events and update.
- `ZoneTracker::remove_body` (`zone.rs`): Remove all zone tracking state for `body_id`.
- `ZoneTracker::clear` (`zone.rs`): Clear all per-body zone state.

## Lua API Reference

### Functions

- `lurek.physics.attachShape(body, shape) -> nil`: Attaches a previously created shape to a body, using the shape's stored material properties.
- `lurek.physics.debugDraw(enable) -> nil`: Enables or disables automatic physics debug overlay rendering for the next frame.
- `lurek.physics.destroyWorld(world) -> nil`: No-op placeholder for API parity. Worlds are freed when no longer referenced.
- `lurek.physics.drawDebugGpu(world, config?) -> nil`: Queues a GPU-rendered physics debug visualization using the world's current body state.
- `lurek.physics.getBody(world, body) -> number`: Returns position and velocity of a body (free-function variant for quick queries).
- `lurek.physics.getCollisions(world) -> table`: Returns all collision events from the last world step as {body_a, body_b} pairs.
- `lurek.physics.isSleepingAllowed(world, body) -> boolean`: Checks if sleeping is allowed on a body (free-function variant).
- `lurek.physics.newBody(world, x, y, bodyType) -> LBody`: Creates a new body in a world (free-function variant).
- `lurek.physics.newChainShape(closed, ...) -> LPhysicsShape`: Creates a chain (polyline) collision shape. Useful for terrain outlines.
- `lurek.physics.newCircleShape(r) -> LPhysicsShape`: Creates a circle collision shape with the given radius.
- `lurek.physics.newEdgeShape(x1, y1, x2, y2) -> LPhysicsShape`: Creates an edge (line segment) collision shape between two local points.
- `lurek.physics.newPolygonShape(...) -> LPhysicsShape`: Creates a convex polygon collision shape from vertex coordinate pairs.
- `lurek.physics.newRectangleShape(w, h) -> LPhysicsShape`: Creates a rectangle collision shape with the given dimensions.
- `lurek.physics.newTerrain(width, height, cellSize, world) -> LTerrain`: Creates a destructible terrain grid linked to a physics world for automatic collider generation.
- `lurek.physics.newWorld(gx, gy) -> LWorld`: Creates a new physics world with the given gravity vector.
- `lurek.physics.setBodyVelocity(world, body, vx, vy) -> nil`: Sets a body's velocity (free-function variant).
- `lurek.physics.setSleepingAllowed(world, body, allowed) -> nil`: Sets whether a body is allowed to sleep (free-function variant).
- `lurek.physics.step(world, dt) -> nil`: Steps a physics world forward by dt seconds (free-function variant).
- `lurek.physics.testAABB(ax, ay, aw, ah, bx, by, bw, bh) -> boolean`: Tests whether two axis-aligned bounding boxes overlap. Lightweight collision check without physics world.
- `lurek.physics.testCircleAABB(cx, cy, cr, ax, ay, aw, ah) -> boolean`: Tests whether a circle overlaps an AABB. Lightweight check without physics world.
- `lurek.physics.testCircles(ax, ay, ar, bx, by, br) -> boolean`: Tests whether two circles overlap. Lightweight collision check without physics world.
- `lurek.physics.testPoint(px, py, ax, ay, aw, ah) -> boolean`: Tests whether a point lies inside an AABB. Lightweight check without physics world.

### Callbacks

- `LWorld:setBeginContact` param `callback` (`function`): Called with (bodyIdA, bodyIdB) on each new contact.
- `LWorld:setEndContact` param `callback` (`function`): Called with (bodyIdA, bodyIdB) on each ended contact.

### Enums

- No documented module-level enums/constants.

### Types

#### LBody Type

- A handle to a single physics body in the world, providing per-body manipulation methods.

##### Fields

- No documented fields.

##### Methods

- `LBody:applyAngularImpulse(impulse) -> nil`: Applies an instantaneous angular impulse (spin) to the body.
- `LBody:applyForce(fx, fy) -> nil`: Applies a continuous force to the body's center of mass (accumulates over the step).
- `LBody:applyForceAtPoint(fx, fy, px, py) -> nil`: Applies a force at a specific world point, generating both linear and angular acceleration.
- `LBody:applyImpulse(ix, iy) -> nil`: Applies an instantaneous linear impulse to the body's center of mass.
- `LBody:applyTorque(torque) -> nil`: Applies a rotational torque to the body.
- `LBody:destroy() -> nil`: Destroys this body, removing it from the world along with all fixtures and joints.
- `LBody:getAngle() -> number`: Returns the body's rotation angle in radians.
- `LBody:getAngularDamping() -> number`: Returns the angular damping factor (rotational decay rate).
- `LBody:getAngularVelocity() -> number`: Returns the body's angular (rotational) velocity.
- `LBody:getFriction() -> number`: Returns the body's friction coefficient.
- `LBody:getGravityScale() -> number`: Returns the gravity scale multiplier for this body (1.0 = normal gravity).
- `LBody:getHeight() -> number`: Returns the body's bounding height (from its primary shape).
- `LBody:getId() -> integer`: Returns the unique numeric ID of this body within the world.
- `LBody:getLayer() -> integer`: Returns the body's collision layer bitmask.
- `LBody:getLinearDamping() -> number`: Returns the linear damping factor (velocity decay rate, like air resistance).
- `LBody:getMask() -> integer`: Returns the body's collision mask (which layers this body can collide with).
- `LBody:getMass() -> number`: Returns the body's total mass (computed from density and fixture areas).
- `LBody:getPosition() -> number`: Returns the current world-space position of this body.
- `LBody:getRestitution() -> number`: Returns the body's restitution (bounciness) value.
- `LBody:getType() -> string`: Returns the body's type as a string.
- `LBody:getVelocity() -> number`: Returns the body's current linear velocity.
- `LBody:getWidth() -> number`: Returns the body's bounding width (from its primary shape).
- `LBody:getX() -> number`: Returns only the X component of the body's position.
- `LBody:getY() -> number`: Returns only the Y component of the body's position.
- `LBody:isBullet() -> boolean`: Returns whether continuous collision detection (bullet mode) is enabled for this body.
- `LBody:isFixedRotation() -> boolean`: Returns whether the body's rotation is locked.
- `LBody:isSleeping() -> boolean`: Returns whether this body is currently in the sleeping (inactive) state.
- `LBody:isSleepingAllowed() -> boolean`: Returns whether the body is allowed to enter sleep state when at rest.
- `LBody:isValid() -> boolean`: Returns whether this body handle still points to an active body.
- `LBody:setAngle(angle) -> nil`: Sets the body's rotation angle directly.
- `LBody:setAngularDamping(damping) -> nil`: Sets the angular damping factor (higher = rotation decays faster).
- `LBody:setAngularVelocity(omega) -> nil`: Sets the body's angular velocity directly.
- `LBody:setBullet(bullet) -> nil`: Enables or disables continuous collision detection to prevent fast-moving tunneling.
- `LBody:setFixedRotation(fixed) -> nil`: Locks or unlocks the body's rotation. Useful for player characters.
- `LBody:setFriction(friction) -> nil`: Sets the body's friction coefficient.
- `LBody:setGravityScale(scale) -> nil`: Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).
- `LBody:setLayer(layer) -> nil`: Sets the body's collision layer bitmask (which layers this body belongs to).
- `LBody:setLinearDamping(damping) -> nil`: Sets the linear damping factor (higher = more velocity decay per step).
- `LBody:setMask(mask) -> nil`: Sets the body's collision mask (which layers this body can collide with).
- `LBody:setMass(mass) -> nil`: Overrides the body's mass directly.
- `LBody:setPosition(x, y) -> nil`: Teleports the body to a new world-space position (does not apply physics forces).
- `LBody:setRestitution(restitution) -> nil`: Sets the body's restitution (bounciness) value.
- `LBody:setSleepingAllowed(allowed) -> nil`: Controls whether the body can enter sleep state. Disable for bodies that must stay active.
- `LBody:setType(bodyType) -> nil`: Changes the body's type at runtime.
- `LBody:setVelocity(vx, vy) -> nil`: Directly sets the body's linear velocity.
- `LBody:sleep() -> nil`: Forces the body into sleep state, pausing its simulation until disturbed.
- `LBody:type() -> string`: Returns the type name of this object ("LBody").
- `LBody:typeOf(name) -> boolean`: Checks if this object is of a given type name.
- `LBody:wakeUp() -> nil`: Wakes the body from sleep, making it active in the simulation again.

#### LPhysicsGetCollisionsResult Type

- Generated result shape from @field tags.

##### Fields

- `body_a` (`integer`): Body A id.
- `body_b` (`integer`): Body B id.

##### Methods

- No documented methods.

#### LPhysicsShape Type

- A standalone collision shape with material properties, to be attached to bodies via `attachShape`.

##### Fields

- No documented fields.

##### Methods

- `LPhysicsShape:destroy() -> nil`: No-op placeholder for API consistency. Shapes are freed when no longer referenced.
- `LPhysicsShape:getBoundingBox() -> number`: Returns the axis-aligned bounding box of the shape in local coordinates.
- `LPhysicsShape:getRadius() -> number`: Returns the radius of a circle shape. Errors if called on a non-circle shape.
- `LPhysicsShape:getType() -> string`: Returns the shape kind as a string: "circle", "rectangle", "polygon", "edge", or "chain".
- `LPhysicsShape:setDensity(density) -> nil`: Sets the density used when this shape is attached to a body (affects mass calculation).
- `LPhysicsShape:setFriction(friction) -> nil`: Sets the friction coefficient for this shape.
- `LPhysicsShape:setRestitution(restitution) -> nil`: Sets the restitution (bounciness) for this shape.
- `LPhysicsShape:setSensor(sensor) -> nil`: Marks this shape as a sensor (overlap detection only, no physical response).
- `LPhysicsShape:type() -> string`: Returns the type name of this object ("LPhysicsShape").
- `LPhysicsShape:typeOf(name) -> boolean`: Checks if this object is of a given type name.

#### LTerrain Type

- A destructible terrain map backed by a grid of solid/empty cells. Generates physics colliders on flush.

##### Fields

- No documented fields.

##### Methods

- `LTerrain:collapseColumns() -> integer`: Optimizes terrain by merging vertically adjacent solid cells into larger colliders.
- `LTerrain:fillAll(solid) -> nil`: Sets all terrain cells to either solid or empty.
- `LTerrain:fillCircle(wx, wy, radius, solid) -> nil`: Fills or clears a circular region of terrain cells.
- `LTerrain:fillRect(wx, wy, w, h, solid) -> nil`: Fills or clears a rectangular region of terrain cells.
- `LTerrain:flush() -> nil`: Regenerates physics colliders from the current terrain grid state. Call after modifying cells.
- `LTerrain:getCell(cx, cy) -> boolean`: Returns whether a cell is solid. This method is available to Lua scripts.
- `LTerrain:isDirty() -> boolean`: Returns true if terrain cells have been modified since the last flush.
- `LTerrain:loadFromBytes(data) -> boolean`: Restores terrain grid state from binary data previously produced by toBytes.
- `LTerrain:setCell(cx, cy, solid) -> nil`: Sets a single terrain cell to solid or empty.
- `LTerrain:solidPositions() -> table`: Returns all solid cell positions as a table of {x, y} entries.
- `LTerrain:spawnDebris(positions, mass, restitution) -> integer[]`: Spawns small dynamic debris bodies at the given positions (for destruction effects).
- `LTerrain:toBytes() -> string`: Serializes the terrain grid to a compact binary format for saving.
- `LTerrain:toImageData(sr, sg, sb, er, eg, eb) -> string`: Renders the terrain grid to raw RGBA pixel data with solid and empty colors.
- `LTerrain:type() -> string`: Returns the type name of this object ("LTerrain").
- `LTerrain:typeOf(name) -> boolean`: Checks if this object is of a given type name.

#### LTerrainSolidPositionsResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`integer`): Cell x coordinate.
- `y` (`integer`): Cell y coordinate.

##### Methods

- No documented methods.

#### LWorld Type

- A physics world that manages rigid bodies, joints, collision detection, and simulation stepping.

##### Fields

- No documented fields.

##### Methods

- `LWorld:addDistanceJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, length) -> integer`: Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.
- `LWorld:addFixture(bodyId, shapeType, density, friction, restitution, sensor, ...) -> integer`: Attaches a new collider shape to an existing body with material properties.
- `LWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque) -> integer`: Creates a friction joint that applies resistance to relative motion between two bodies.
- `LWorld:addGearJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a gear joint that synchronizes rotation between two bodies at an anchor.
- `LWorld:addMotorJoint(bodyA, bodyB, factor) -> integer`: Creates a motor joint that drives body B toward a target offset from body A using a correction factor.
- `LWorld:addMouseJoint(bodyId, targetX, targetY, maxForce) -> integer`: Creates a mouse joint that pulls a body toward a world target point with spring-like force.
- `LWorld:addPrismaticJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY) -> integer`: Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.
- `LWorld:addPulleyJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.
- `LWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.
- `LWorld:addRopeJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, maxLength) -> integer`: Creates a rope joint limiting the maximum distance between two anchor points on two bodies.
- `LWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).
- `LWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY) -> integer`: Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.
- `LWorld:addZone(x, y, w, h) -> LZone`: Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).
- `LWorld:clear() -> nil`: Removes all bodies and joints from the world, resetting it to an empty state.
- `LWorld:clearBeginContact() -> nil`: Removes the begin-contact callback so it is no longer called.
- `LWorld:clearBodyData(id) -> nil`: Removes and releases the Lua data attached to a body.
- `LWorld:clearBodyOneWay(id) -> nil`: Removes the one-way platform behavior from a body, making it block from all directions.
- `LWorld:clearEndContact() -> nil`: Removes the end-contact callback so it is no longer called.
- `LWorld:destroyBody(id) -> nil`: Removes a body from the world by its ID, along with all attached fixtures and joints.
- `LWorld:destroyJoint(jointId) -> nil`: Removes a joint from the world, disconnecting the two bodies it linked.
- `LWorld:drawDebug(target, r?, g?, b?, a?) -> nil`: Renders a debug visualization of all physics bodies onto a software ImageData target.
- `LWorld:fixtureCount(bodyId) -> integer`: Returns how many fixtures (colliders) are attached to a body.
- `LWorld:getBeginContactEvents() -> table`: Returns contact-begin events from the last step (pairs of bodies that started touching).
- `LWorld:getBodyAtPoint(x, y, filter?) -> integer`: Returns the body ID at a specific world point, or nil if no body is there.
- `LWorld:getBodyCCD(id) -> boolean`: Returns whether continuous collision detection is enabled on a body.
- `LWorld:getBodyContacts(bodyId) -> table`: Returns all contacts involving a specific body.
- `LWorld:getBodyCount() -> integer`: Returns the total number of active bodies in the world.
- `LWorld:getBodyData(id) -> table`: Retrieves the Lua data previously attached to a body, or nil if none was set.
- `LWorld:getBodyIds() -> integer[]`: Returns a sequential table of all body IDs currently in the world.
- `LWorld:getBodyOneWay(id) -> number`: Returns the one-way platform normal for a body, or nil,nil if not set.
- `LWorld:getBodyType(id) -> string`: Returns the type name of a body as a string.
- `LWorld:getCollisionEvents() -> table`: Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.
- `LWorld:getContacts() -> table`: Returns all currently active contact manifolds with normals and touching state.
- `LWorld:getEndContactEvents() -> table`: Returns contact-end events from the last step (pairs of bodies that stopped touching).
- `LWorld:getGravity() -> number`: Returns the current world gravity vector.
- `LWorld:getJointBodies(jointId) -> integer`: Returns the two body IDs connected by a joint.
- `LWorld:getJointBreakForce(jointId) -> number`: Returns the break force threshold for a joint.
- `LWorld:getJointIds() -> integer[]`: Returns a sequential table of all joint IDs currently in the world.
- `LWorld:getJointLimits(jointId) -> number`: Returns the lower and upper limit values for a joint.
- `LWorld:getJointMotorSpeed(jointId) -> number`: Returns the current motor speed setting of a joint.
- `LWorld:getJointType(jointId) -> string`: Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").
- `LWorld:getMeter() -> number`: Returns the current pixels-per-meter scale.
- `LWorld:getSolverIterations() -> integer`: Returns the current number of velocity solver iterations.
- `LWorld:getStats() -> table`: Returns active counts and slot diagnostics for the world.
- `LWorld:getZoneEvents() -> table`: Returns all zone enter/leave events from the last step.
- `LWorld:hasBody(id) -> boolean`: Returns true when a body ID still refers to a live body slot.
- `LWorld:hasJoint(id) -> boolean`: Returns true when a joint ID still refers to a live joint slot.
- `LWorld:isBodySleeping(id) -> boolean`: Returns whether a body is currently in the sleeping (inactive) state.
- `LWorld:jointCount() -> integer`: Returns the total number of joints in the world.
- `LWorld:newBodies(specs) -> integer[]`: Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.
- `LWorld:newBody(x, y, bodyType) -> LBody`: Creates a new physics body at the given position with the specified type and dimensions.
- `LWorld:newChainBody(x, y, vertices, closed, bodyType) -> LBody`: Creates a new body with a chain (polyline) collider. Useful for terrain edges.
- `LWorld:newCircleBody(x, y, radius, bodyType) -> LBody`: Creates a new body with a circle collider already attached.
- `LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bodyType) -> LBody`: Creates a new body with an edge (line segment) collider between two local points.
- `LWorld:newPolygonBody(x, y, vertices, bodyType) -> LBody`: Creates a new body with a convex polygon collider defined by vertex pairs.
- `LWorld:queryAABB(x, y, w, h, filter?) -> integer[]`: Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.
- `LWorld:raycast(x1, y1, x2, y2, filter?) -> table`: Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.
- `LWorld:raycastAll(x, y, dx, dy, maxDist, filter?) -> table`: Casts a directional ray and returns all bodies hit within max distance as a table of results.
- `LWorld:raycastClosest(x, y, dx, dy, maxDist, filter?) -> table`: Casts a directional ray from a point and returns the closest hit within max distance.
- `LWorld:setBeginContact(callback) -> nil`: Registers a callback function invoked whenever two bodies begin touching.
- `LWorld:setBodyCCD(id, enabled) -> nil`: Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.
- `LWorld:setBodyData(id, value) -> nil`: Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).
- `LWorld:setBodyOneWay(id, nx, ny) -> nil`: Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.
- `LWorld:setBodyType(id, bodyType) -> nil`: Changes the type of an existing body (e.g. from "dynamic" to "static").
- `LWorld:setEndContact(callback) -> nil`: Registers a callback function invoked whenever two bodies stop touching.
- `LWorld:setFixtureFriction(bodyId, fixtureIndex, friction) -> nil`: Updates the friction coefficient of a specific fixture on a body.
- `LWorld:setFixtureRestitution(bodyId, fixtureIndex, restitution) -> nil`: Updates the restitution (bounciness) of a specific fixture on a body.
- `LWorld:setFixtureSensor(bodyId, fixtureIndex, sensor) -> nil`: Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).
- `LWorld:setGravity(gx, gy) -> nil`: Sets the world gravity vector. Affects all dynamic bodies.
- `LWorld:setJointBreakForce(jointId, force) -> nil`: Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.
- `LWorld:setJointLimits(jointId, lower, upper) -> nil`: Sets the lower and upper bounds for a joint's limited range of motion.
- `LWorld:setJointLimitsEnabled(jointId, enabled) -> nil`: Enables or disables angular/linear limits on a joint.
- `LWorld:setJointMotorSpeed(jointId, speed) -> nil`: Sets the motor speed on a motorized joint (revolute or prismatic).
- `LWorld:setMeter(ppm) -> nil`: Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.
- `LWorld:setMouseJointTarget(jointId, x, y) -> nil`: Moves the target position of a mouse joint, causing the attached body to follow.
- `LWorld:setSolverIterations(n) -> nil`: Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.
- `LWorld:sleepBody(id) -> nil`: Forces a body into the sleeping state, pausing its simulation until disturbed.
- `LWorld:step(dt) -> nil`: Advances the physics simulation by a time delta and fires any registered contact callbacks.
- `LWorld:stepFixed(accumulator, stepDt, maxSteps) -> number`: Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.
- `LWorld:toPhysics(px) -> number`: Converts a pixel measurement to physics-world meters using the current meter scale.
- `LWorld:toPixels(m) -> number`: Converts a physics-world meter measurement to pixels using the current meter scale.
- `LWorld:type() -> string`: Returns the type name of this object ("LWorld").
- `LWorld:typeOf(name) -> boolean`: Checks if this object is of a given type name. Supports inheritance (always matches "Object").
- `LWorld:wakeUpBody(id) -> nil`: Forces a sleeping body to wake up and participate in simulation again.

#### LWorldGetBeginContactEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyA` (`integer`): BodyA.
- `bodyB` (`integer`): BodyB.

##### Methods

- No documented methods.

#### LWorldGetBodyContactsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyA` (`integer`): BodyA.
- `bodyB` (`integer`): BodyB.
- `isTouching` (`boolean`): True while the body pair is currently touching.
- `normalX` (`number`): NormalX.
- `normalY` (`number`): NormalY.

##### Methods

- No documented methods.

#### LWorldGetCollisionEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyA` (`integer`): Body A id.
- `bodyB` (`integer`): Body B id.

##### Methods

- No documented methods.

#### LWorldGetContactsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyA` (`integer`): BodyA.
- `bodyB` (`integer`): BodyB.
- `isTouching` (`boolean`): True while the bodies are currently touching.
- `normalX` (`number`): NormalX.
- `normalY` (`number`): NormalY.

##### Methods

- No documented methods.

#### LWorldGetEndContactEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyA` (`integer`): BodyA.
- `bodyB` (`integer`): BodyB.

##### Methods

- No documented methods.

#### LWorldGetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `bodies` (`integer`): Number of active body slots.
- `bodySlots` (`integer`): Total allocated body slots, including inactive tombstones.
- `colliders` (`integer`): Number of active Rapier colliders.
- `jointSlots` (`integer`): Total allocated joint slots, including inactive tombstones.
- `joints` (`integer`): Number of active joint slots.
- `sleepingBodies` (`integer`): Number of active bodies currently sleeping.
- `zones` (`integer`): Number of active physics zones.

##### Methods

- No documented methods.

#### LWorldGetZoneEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `body_id` (`integer`): Body_id.
- `kind` (`string`): Kind.
- `zone_id` (`integer`): Zone_id.

##### Methods

- No documented methods.

#### LWorldRaycastAllResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyId` (`integer`): BodyId.
- `normalX` (`number`): NormalX.
- `normalY` (`number`): NormalY.
- `toi` (`number`): Toi.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LWorldRaycastClosestResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyId` (`integer`): BodyId.
- `normalX` (`number`): NormalX.
- `normalY` (`number`): NormalY.
- `toi` (`number`): Toi.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LWorldRaycastResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyId` (`integer`): BodyId.
- `normalX` (`number`): NormalX.
- `normalY` (`number`): NormalY.
- `toi` (`number`): Toi.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LZone Type

- A physics zone that applies area-based effects (gravity overrides, damping) to bodies within its bounds.

##### Fields

- No documented fields.

##### Methods

- `LZone:destroy() -> nil`: Removes this zone from the world. Bodies will no longer be affected by it.
- `LZone:getId() -> integer`: Returns the unique ID of this zone. This method is available to Lua scripts.
- `LZone:setAngularDampingOverride(value?) -> nil`: Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setCircle(cx, cy, radius) -> nil`: Changes this zone's shape to a circle (overrides the initial rectangle).
- `LZone:setEnabled(enabled) -> nil`: Enables or disables this zone. Disabled zones have no effect on bodies.
- `LZone:setGravityDirectional(gx, gy) -> nil`: Sets the zone to apply a constant directional gravity to bodies inside.
- `LZone:setGravityPoint(cx, cy, strength) -> nil`: Sets the zone to attract bodies toward a center point with a given strength.
- `LZone:setGravityRepulsor(cx, cy, strength) -> nil`: Sets the zone to push bodies away from a center point with a given strength.
- `LZone:setGravityZero() -> nil`: Sets the zone to cancel all gravity for bodies inside (zero-G area).
- `LZone:setLayerMask(mask) -> nil`: Sets a bitmask controlling which body layers this zone affects.
- `LZone:setLinearDampingOverride(value?) -> nil`: Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setPriority(priority) -> nil`: Sets the priority of this zone. Higher-priority zones take precedence when overlapping.
- `LZone:type() -> string`: Returns the type name of this object ("LZone").
- `LZone:typeOf(name) -> boolean`: Checks if this object is of a given type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
