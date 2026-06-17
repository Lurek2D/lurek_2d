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
- Lua test path(s): tests/lua/unit/test_physics_unit.lua

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

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### body.rs

- Physics body description layer that gathers the state a simulation object needs before or while it lives inside the world.
- The file defines the playable vocabulary of rigid body roles such as dynamic movers, fixed solids, script-driven kinematics, and overlap-only sensors.
- It also binds those roles to supported geometry forms, material defaults, collision filtering, and transform helpers so a body can be reasoned about as one coherent unit.
- Constructors emphasize ready-to-use authoring by filling in sensible density, friction, restitution, and motion settings rather than forcing every caller to spell out raw fields.
- Geometry utilities keep body space and world space connected, which matters for bounds queries, spawn setup, editor tooling, and shape-aware logic outside the solver.

### collision.rs

- Collision event buffering for the moments when physical contact needs to become stable gameplay information instead of transient solver state.

### collision_helpers.rs

- Lightweight geometry overlap helpers for code that needs quick collision answers without standing up a full physics world.

### mod.rs

- Platform-level 2D physics module that unifies authored bodies, geometric shapes, simulation stepping, spatial queries, terrain sync, and trigger-style environmental effects.
- It exposes the major surfaces of the subsystem as one coherent toolbox, from lightweight helper tests through full world simulation and debug-oriented support structures.
- Functionally this file is the high-level entry point for physical interaction, movement constraints, collision reporting, and physics-backed world state in Lurek2D.
- `physics/mod` is the physics module index, declaring `body`, `collision`, `collision_helpers`, `render`, `shape`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- `src/physics/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `types::BodyId`, `body::{Body, BodyShape, BodyType}`, `collision::CollisionInfo`, `collision_helpers::{test_aabb, test_circle_aabb, test_circles, test_point_aabb}`, and 5 more centralized for the physics subsystem.
- The file documents how physics submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### render.rs

- Physics debug rendering layer for turning invisible simulation state into visible lines, outlines, and motion cues that developers can inspect frame by frame.
- The file translates bodies and shapes into render-friendly snapshots without changing the simulation, letting diagnostics live beside gameplay rather than inside it.
- Type-based coloring keeps static, dynamic, kinematic, and sensor objects readable at a glance when scenes grow dense. Public callable behavior is centered on no named public items, while method-level behavior such as `generate_render_commands`, `draw_to_image` stays attached to the local data model and invariants.
- Velocity arrows and shape outlines expose both form and movement so developers can see why contacts, tunnels, or odd impulses are happening.

### shape.rs

- Physics shape definition layer that gives the subsystem a compact language for circles, rectangles, polygons, edges, and chained outlines.
- The file keeps geometry authoring, validation, and collider conversion close together so malformed inputs can be rejected before they become unstable runtime fixtures.
- Parsing and regular-polygon construction make the surface practical for scripts, tools, and data-driven content that describe shape intent rather than raw engine objects.
- Standalone shapes carry material and sensor settings alongside geometry, which lets authored collision pieces travel with the properties that affect how they behave in the world.
- Local bounding logic keeps each shape queryable without needing a live body, which is useful for previews, authoring tools, and lightweight reasoning.

### terrain.rs

- Destructible terrain map layer that turns editable solid cells into physics-ready world geometry without making callers manage collider lifecycles manually.
- The file tracks terrain in chunks so local edits stay local, allowing flush operations to rebuild only the regions that actually changed.
- Fill tools support live terrain authoring and destruction patterns such as circles, rectangles, blanket writes, and other broad modifications during play.
- Row merging keeps the generated static-body footprint compact, which matters when large tile fields must remain interactive without exploding collider counts.
- Serialization and image output make the terrain usable for save systems, tooling, previews, and data exchange outside the immediate simulation step.

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

### zone.rs

- Physics zone system for spatial rule overrides that should apply because a body is somewhere, not because it touched a solid object.
- The file defines bounded areas that can replace normal gravity with directional pull, attraction, repulsion, or weightless behavior.
- Priority and mask filtering let multiple zones coexist without turning area-based effects into ambiguous global state. Public callable behavior is centered on no named public items, while method-level behavior such as `contains`, `new_rect`, `set_circle`, `set_gravity_directional`, `set_gravity_point`, `set_gravity_repulsor`, and 5 more stays attached to the local data model and invariants.
- Damping overrides make zones useful for liquids, mud, low-friction fields, or other environmental modifiers that change motion feel.
- Enter and leave tracking turns zones into event sources as well as force fields, which is important for scripting and gameplay transitions.



## Lua API Ref

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
