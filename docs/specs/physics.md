# physics

## TL;DR

- The `physics` module is a core Platform Services tier component that provides a robust, high-performance 2D rigid-body simulation for Lurek2D, backed by the industry-standard Rapier2D (v0.32) engine.

## General Info

- Module group: `Platform Services`
- Source path: `src/physics/`
- Binding: `src/lua_api/physics_api.rs`
- Namespace: `lurek.physics`
- Lua API surface: `22` functions, `16` types, `168` methods
- Rust test path(s): src/physics/world_tests.rs, inline #[cfg(test)] in body.rs, shape.rs, zone.rs, cellular.rs, terrain.rs, render.rs, collision_helpers.rs
- Lua test path(s): none found in the workspace

## Summary

At its center is the `World` struct, which completely encapsulates the Rapier simulation state, including body sets, collider sets, joint sets, and the broad/narrow-phase collision pipelines. The simulation is advanced via deterministic fixed-timestep sub-stepping (`step_fixed`), ensuring consistent and predictable physical interactions regardless of frame rate fluctuations.

The module supports a full spectrum of physics bodies: `dynamic` (fully simulated), `static` (immovable terrain/walls), `kinematic` (script-driven movement that affects dynamic bodies), and `sensor` (detects overlap without physical collision response). These bodies can be composed of various primitives, including circles, rectangles, convex polygons, edge segments, and chain polylines. Developers have granular control over material properties such as density, friction, and restitution (bounciness). Advanced simulation features like continuous collision detection (CCD, or "bullet mode") are available to prevent fast-moving objects from tunneling through walls, and rotation locking ensures character controllers behave predictably.

A comprehensive suite of joints enables complex mechanical linkages between bodies, including revolute (hinge), prismatic (slider), distance (rope), weld, wheel, motor, and mouse joints. The module also features a sophisticated `TerrainMap` system for chunked, destructible environments, automatically synchronizing solid bit-grid cells into static physics colliders for high-performance interaction. Further extending environmental interactions, the `PhysicsZone` system allows developers to define spatial areas (rectangles or circles) that override standard physics rules—applying directional gravity, point attractors, repulsors, or custom damping to bodies that enter them.

Additionally, the `cellular` submodule provides a cellular automaton grid for simulating falling sand, flowing water, and other particle-like materials. For spatial queries, the module offers extensive raycasting, shape-casting, and point intersection tests, alongside pure-geometry collision helpers for lightweight, physics-free checks. The entire system—from body lifecycle management to collision event callbacks and debug rendering—is comprehensively exposed to the Lua environment via the `lurek.physics.*` API, forming the backbone of physical interactions in Lurek2D games.

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

## Lua API Ref

### Functions

- `lurek.physics.attachShape`: Attaches a previously created shape to a body, using the shape's stored material properties.
- `lurek.physics.debugDraw`: Enables or disables automatic physics debug overlay rendering for the next frame.
- `lurek.physics.destroyWorld`: No-op placeholder for API parity. Worlds are freed when no longer referenced.
- `lurek.physics.drawDebugGpu`: Queues a GPU-rendered physics debug visualization using the world's current body state.
- `lurek.physics.getBody`: Returns position and velocity of a body (free-function variant for quick queries).
- `lurek.physics.getCollisions`: Returns all collision events from the last world step as {body_a, body_b} pairs.
- `lurek.physics.isSleepingAllowed`: Checks if sleeping is allowed on a body (free-function variant).
- `lurek.physics.newBody`: Creates a new body in a world (free-function variant).
- `lurek.physics.newChainShape`: Creates a chain (polyline) collision shape. Useful for terrain outlines.
- `lurek.physics.newCircleShape`: Creates a circle collision shape with the given radius.
- `lurek.physics.newEdgeShape`: Creates an edge (line segment) collision shape between two local points.
- `lurek.physics.newPolygonShape`: Creates a convex polygon collision shape from vertex coordinate pairs.
- `lurek.physics.newRectangleShape`: Creates a rectangle collision shape with the given dimensions.
- `lurek.physics.newTerrain`: Creates a destructible terrain grid linked to a physics world for automatic collider generation.
- `lurek.physics.newWorld`: Creates a new physics world with the given gravity vector.
- `lurek.physics.setBodyVelocity`: Sets a body's velocity (free-function variant).
- `lurek.physics.setSleepingAllowed`: Sets whether a body is allowed to sleep (free-function variant).
- `lurek.physics.step`: Steps a physics world forward by dt seconds (free-function variant).
- `lurek.physics.testAABB`: Tests whether two axis-aligned bounding boxes overlap. Lightweight collision check without physics world.
- `lurek.physics.testCircleAABB`: Tests whether a circle overlaps an AABB. Lightweight check without physics world.
- `lurek.physics.testCircles`: Tests whether two circles overlap. Lightweight collision check without physics world.
- `lurek.physics.testPoint`: Tests whether a point lies inside an AABB. Lightweight check without physics world.

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

- `LBody:applyAngularImpulse`: Applies an instantaneous angular impulse (spin) to the body.
- `LBody:applyForce`: Applies a continuous force to the body's center of mass (accumulates over the step).
- `LBody:applyForceAtPoint`: Applies a force at a specific world point, generating both linear and angular acceleration.
- `LBody:applyImpulse`: Applies an instantaneous linear impulse to the body's center of mass.
- `LBody:applyTorque`: Applies a rotational torque to the body.
- `LBody:destroy`: Destroys this body, removing it from the world along with all fixtures and joints.
- `LBody:getAngle`: Returns the body's rotation angle in radians.
- `LBody:getAngularDamping`: Returns the angular damping factor (rotational decay rate).
- `LBody:getAngularVelocity`: Returns the body's angular (rotational) velocity.
- `LBody:getFriction`: Returns the body's friction coefficient.
- `LBody:getGravityScale`: Returns the gravity scale multiplier for this body (1.0 = normal gravity).
- `LBody:getHeight`: Returns the body's bounding height (from its primary shape).
- `LBody:getId`: Returns the unique numeric ID of this body within the world.
- `LBody:getLayer`: Returns the body's collision layer bitmask.
- `LBody:getLinearDamping`: Returns the linear damping factor (velocity decay rate, like air resistance).
- `LBody:getMask`: Returns the body's collision mask (which layers this body can collide with).
- `LBody:getMass`: Returns the body's total mass (computed from density and fixture areas).
- `LBody:getPosition`: Returns the current world-space position of this body.
- `LBody:getRestitution`: Returns the body's restitution (bounciness) value.
- `LBody:getType`: Returns the body's type as a string.
- `LBody:getVelocity`: Returns the body's current linear velocity.
- `LBody:getWidth`: Returns the body's bounding width (from its primary shape).
- `LBody:getX`: Returns only the X component of the body's position.
- `LBody:getY`: Returns only the Y component of the body's position.
- `LBody:isBullet`: Returns whether continuous collision detection (bullet mode) is enabled for this body.
- `LBody:isFixedRotation`: Returns whether the body's rotation is locked.
- `LBody:isSleeping`: Returns whether this body is currently in the sleeping (inactive) state.
- `LBody:isSleepingAllowed`: Returns whether the body is allowed to enter sleep state when at rest.
- `LBody:setAngle`: Sets the body's rotation angle directly.
- `LBody:setAngularDamping`: Sets the angular damping factor (higher = rotation decays faster).
- `LBody:setAngularVelocity`: Sets the body's angular velocity directly.
- `LBody:setBullet`: Enables or disables continuous collision detection to prevent fast-moving tunneling.
- `LBody:setFixedRotation`: Locks or unlocks the body's rotation. Useful for player characters.
- `LBody:setFriction`: Sets the body's friction coefficient.
- `LBody:setGravityScale`: Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).
- `LBody:setLayer`: Sets the body's collision layer bitmask (which layers this body belongs to).
- `LBody:setLinearDamping`: Sets the linear damping factor (higher = more velocity decay per step).
- `LBody:setMask`: Sets the body's collision mask (which layers this body can collide with).
- `LBody:setMass`: Overrides the body's mass directly.
- `LBody:setPosition`: Teleports the body to a new world-space position (does not apply physics forces).
- `LBody:setRestitution`: Sets the body's restitution (bounciness) value.
- `LBody:setSleepingAllowed`: Controls whether the body can enter sleep state. Disable for bodies that must stay active.
- `LBody:setType`: Changes the body's type at runtime.
- `LBody:setVelocity`: Directly sets the body's linear velocity.
- `LBody:sleep`: Forces the body into sleep state, pausing its simulation until disturbed.
- `LBody:type`: Returns the type name of this object ("LBody").
- `LBody:typeOf`: Checks if this object is of a given type name.
- `LBody:wakeUp`: Wakes the body from sleep, making it active in the simulation again.

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

- `LPhysicsShape:destroy`: No-op placeholder for API consistency. Shapes are freed when no longer referenced.
- `LPhysicsShape:getBoundingBox`: Returns the axis-aligned bounding box of the shape in local coordinates.
- `LPhysicsShape:getRadius`: Returns the radius of a circle shape. Errors if called on a non-circle shape.
- `LPhysicsShape:getType`: Returns the shape kind as a string: "circle", "rectangle", "polygon", "edge", or "chain".
- `LPhysicsShape:setDensity`: Sets the density used when this shape is attached to a body (affects mass calculation).
- `LPhysicsShape:setFriction`: Sets the friction coefficient for this shape.
- `LPhysicsShape:setRestitution`: Sets the restitution (bounciness) for this shape.
- `LPhysicsShape:setSensor`: Marks this shape as a sensor (overlap detection only, no physical response).
- `LPhysicsShape:type`: Returns the type name of this object ("LPhysicsShape").
- `LPhysicsShape:typeOf`: Checks if this object is of a given type name.

#### LTerrain Type

- A destructible terrain map backed by a grid of solid/empty cells. Generates physics colliders on flush.

##### Fields

- No documented fields.

##### Methods

- `LTerrain:collapseColumns`: Optimizes terrain by merging vertically adjacent solid cells into larger colliders.
- `LTerrain:fillAll`: Sets all terrain cells to either solid or empty.
- `LTerrain:fillCircle`: Fills or clears a circular region of terrain cells.
- `LTerrain:fillRect`: Fills or clears a rectangular region of terrain cells.
- `LTerrain:flush`: Regenerates physics colliders from the current terrain grid state. Call after modifying cells.
- `LTerrain:getCell`: Returns whether a cell is solid. This method is available to Lua scripts.
- `LTerrain:isDirty`: Returns true if terrain cells have been modified since the last flush.
- `LTerrain:loadFromBytes`: Restores terrain grid state from binary data previously produced by toBytes.
- `LTerrain:setCell`: Sets a single terrain cell to solid or empty.
- `LTerrain:solidPositions`: Returns all solid cell positions as a table of {x, y} entries.
- `LTerrain:spawnDebris`: Spawns small dynamic debris bodies at the given positions (for destruction effects).
- `LTerrain:toBytes`: Serializes the terrain grid to a compact binary format for saving.
- `LTerrain:toImageData`: Renders the terrain grid to raw RGBA pixel data with solid and empty colors.
- `LTerrain:type`: Returns the type name of this object ("LTerrain").
- `LTerrain:typeOf`: Checks if this object is of a given type name.

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

- `LWorld:addDistanceJoint`: Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.
- `LWorld:addFixture`: Attaches a new collider shape to an existing body with material properties.
- `LWorld:addFrictionJoint`: Creates a friction joint that applies resistance to relative motion between two bodies.
- `LWorld:addGearJoint`: Creates a gear joint that synchronizes rotation between two bodies at an anchor.
- `LWorld:addMotorJoint`: Creates a motor joint that drives body B toward a target offset from body A using a correction factor.
- `LWorld:addMouseJoint`: Creates a mouse joint that pulls a body toward a world target point with spring-like force.
- `LWorld:addPrismaticJoint`: Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.
- `LWorld:addPulleyJoint`: Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.
- `LWorld:addRevoluteJoint`: Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.
- `LWorld:addRopeJoint`: Creates a rope joint limiting the maximum distance between two anchor points on two bodies.
- `LWorld:addWeldJoint`: Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).
- `LWorld:addWheelJoint`: Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.
- `LWorld:addZone`: Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).
- `LWorld:clear`: Removes all bodies and joints from the world, resetting it to an empty state.
- `LWorld:clearBeginContact`: Removes the begin-contact callback so it is no longer called.
- `LWorld:clearBodyData`: Removes and releases the Lua data attached to a body.
- `LWorld:clearBodyOneWay`: Removes the one-way platform behavior from a body, making it block from all directions.
- `LWorld:clearEndContact`: Removes the end-contact callback so it is no longer called.
- `LWorld:destroyBody`: Removes a body from the world by its ID, along with all attached fixtures and joints.
- `LWorld:destroyJoint`: Removes a joint from the world, disconnecting the two bodies it linked.
- `LWorld:drawDebug`: Renders a debug visualization of all physics bodies onto a software ImageData target.
- `LWorld:fixtureCount`: Returns how many fixtures (colliders) are attached to a body.
- `LWorld:getBeginContactEvents`: Returns contact-begin events from the last step (pairs of bodies that started touching).
- `LWorld:getBodyAtPoint`: Returns the body ID at a specific world point, or nil if no body is there.
- `LWorld:getBodyCCD`: Returns whether continuous collision detection is enabled on a body.
- `LWorld:getBodyContacts`: Returns all contacts involving a specific body.
- `LWorld:getBodyCount`: Returns the total number of active bodies in the world.
- `LWorld:getBodyData`: Retrieves the Lua data previously attached to a body, or nil if none was set.
- `LWorld:getBodyIds`: Returns a sequential table of all body IDs currently in the world.
- `LWorld:getBodyOneWay`: Returns the one-way platform normal for a body, or nil,nil if not set.
- `LWorld:getBodyType`: Returns the type name of a body as a string.
- `LWorld:getCollisionEvents`: Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.
- `LWorld:getContacts`: Returns all currently active contact manifolds with normals and touching state.
- `LWorld:getEndContactEvents`: Returns contact-end events from the last step (pairs of bodies that stopped touching).
- `LWorld:getGravity`: Returns the current world gravity vector.
- `LWorld:getJointBodies`: Returns the two body IDs connected by a joint.
- `LWorld:getJointBreakForce`: Returns the break force threshold for a joint.
- `LWorld:getJointIds`: Returns a sequential table of all joint IDs currently in the world.
- `LWorld:getJointLimits`: Returns the lower and upper limit values for a joint.
- `LWorld:getJointMotorSpeed`: Returns the current motor speed setting of a joint.
- `LWorld:getJointType`: Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").
- `LWorld:getMeter`: Returns the current pixels-per-meter scale.
- `LWorld:getSolverIterations`: Returns the current number of velocity solver iterations.
- `LWorld:getZoneEvents`: Returns all zone enter/leave events from the last step.
- `LWorld:isBodySleeping`: Returns whether a body is currently in the sleeping (inactive) state.
- `LWorld:jointCount`: Returns the total number of joints in the world.
- `LWorld:newBodies`: Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.
- `LWorld:newBody`: Creates a new physics body at the given position with the specified type and dimensions.
- `LWorld:newChainBody`: Creates a new body with a chain (polyline) collider. Useful for terrain edges.
- `LWorld:newCircleBody`: Creates a new body with a circle collider already attached.
- `LWorld:newEdgeBody`: Creates a new body with an edge (line segment) collider between two local points.
- `LWorld:newPolygonBody`: Creates a new body with a convex polygon collider defined by vertex pairs.
- `LWorld:queryAABB`: Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.
- `LWorld:raycast`: Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.
- `LWorld:raycastAll`: Casts a directional ray and returns all bodies hit within max distance as a table of results.
- `LWorld:raycastClosest`: Casts a directional ray from a point and returns the closest hit within max distance.
- `LWorld:setBeginContact`: Registers a callback function invoked whenever two bodies begin touching.
- `LWorld:setBodyCCD`: Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.
- `LWorld:setBodyData`: Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).
- `LWorld:setBodyOneWay`: Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.
- `LWorld:setBodyType`: Changes the type of an existing body (e.g. from "dynamic" to "static").
- `LWorld:setEndContact`: Registers a callback function invoked whenever two bodies stop touching.
- `LWorld:setFixtureFriction`: Updates the friction coefficient of a specific fixture on a body.
- `LWorld:setFixtureRestitution`: Updates the restitution (bounciness) of a specific fixture on a body.
- `LWorld:setFixtureSensor`: Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).
- `LWorld:setGravity`: Sets the world gravity vector. Affects all dynamic bodies.
- `LWorld:setJointBreakForce`: Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.
- `LWorld:setJointLimits`: Sets the lower and upper bounds for a joint's limited range of motion.
- `LWorld:setJointLimitsEnabled`: Enables or disables angular/linear limits on a joint.
- `LWorld:setJointMotorSpeed`: Sets the motor speed on a motorized joint (revolute or prismatic).
- `LWorld:setMeter`: Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.
- `LWorld:setMouseJointTarget`: Moves the target position of a mouse joint, causing the attached body to follow.
- `LWorld:setSolverIterations`: Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.
- `LWorld:sleepBody`: Forces a body into the sleeping state, pausing its simulation until disturbed.
- `LWorld:step`: Advances the physics simulation by a time delta and fires any registered contact callbacks.
- `LWorld:stepFixed`: Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.
- `LWorld:toPhysics`: Converts a pixel measurement to physics-world meters using the current meter scale.
- `LWorld:toPixels`: Converts a physics-world meter measurement to pixels using the current meter scale.
- `LWorld:type`: Returns the type name of this object ("LWorld").
- `LWorld:typeOf`: Checks if this object is of a given type name. Supports inheritance (always matches "Object").
- `LWorld:wakeUpBody`: Forces a sleeping body to wake up and participate in simulation again.

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
- `isTouching` (`boolean`): IsTouching.
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
- `isTouching` (`boolean`): IsTouching.
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

- `LZone:destroy`: Removes this zone from the world. Bodies will no longer be affected by it.
- `LZone:getId`: Returns the unique ID of this zone. This method is available to Lua scripts.
- `LZone:setAngularDampingOverride`: Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setCircle`: Changes this zone's shape to a circle (overrides the initial rectangle).
- `LZone:setEnabled`: Enables or disables this zone. Disabled zones have no effect on bodies.
- `LZone:setGravityDirectional`: Sets the zone to apply a constant directional gravity to bodies inside.
- `LZone:setGravityPoint`: Sets the zone to attract bodies toward a center point with a given strength.
- `LZone:setGravityRepulsor`: Sets the zone to push bodies away from a center point with a given strength.
- `LZone:setGravityZero`: Sets the zone to cancel all gravity for bodies inside (zero-G area).
- `LZone:setLayerMask`: Sets a bitmask controlling which body layers this zone affects.
- `LZone:setLinearDampingOverride`: Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setPriority`: Sets the priority of this zone. Higher-priority zones take precedence when overlapping.
- `LZone:type`: Returns the type name of this object ("LZone").
- `LZone:typeOf`: Checks if this object is of a given type name.
