<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/physics.md or source docstrings instead. -->

# physics

## TL;DR

- Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors.
- Supports shapes, continuous detection, and motorized mechanical joints.
- Can infer approximate collision shapes from image alpha masks for asset-driven colliders.
- Manages override zones, raycast queries, and destructible static terrain.
- Provides a 16-group world collision matrix layered over per-body layer/mask filters.
- Provides post-step contact events and colorized visual debug overlays.
- Supports authored flow fields for wind, water, conveyor, and magic-current style motion that can be sampled or applied during stepping.

## General Info

- Module group: `Platform Services`
- Source path: `src/physics`
- Binding: `src/lua_api/physics_api.rs`
- Namespace: `lurek.physics`
- Lua API surface: `23` functions, `21` types, `222` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

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

## Ownership

- Canonical source: `src/physics`
- Owning tier: `Platform Services`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/physics_api.rs`
- Referenced engine modules: `image`, `math`, `render`, `runtime`

## Imports

- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `render`: Imports or references `src/render/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### body.rs

- Owns the body owner for the physics subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around BodyType, BodyShape, Body, with helpers kept close to their invariants.
- Defines how body data is validated, transformed, or stored before neighboring systems use it.
- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on body behavior while Lua registration stays elsewhere.
- Documents the boundary where physics code accepts inputs, reports errors, or updates state.
- Use this file when changing body defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the physics state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping body calculations explicit at their owner boundary.

### collision.rs

- This file owns `CollisionInfo`, the stable collision payload used when contact results leave solver internals.
- It stores penetration depth and collision normal so gameplay systems can react without raw engine state.
- Open this file when exported contact payload fields change; overlap helpers and body simulation live elsewhere.

### collision_helpers.rs

- This file owns lightweight overlap helpers for AABBs, circles, and point tests without a full physics world.
- It provides stateless boolean queries used by gameplay code that only needs immediate geometric answers.
- Open this file when simple collision predicates change; buffered collision events and bodies live elsewhere.

### error.rs

- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around PhysicsError, fmt, with helpers kept close to their invariants.
- Defines how error data is validated, transformed, or stored before neighboring systems use it.
- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on error behavior while Lua registration stays elsewhere.
- Documents the boundary where physics code accepts inputs, reports errors, or updates state.

### flow.rs

- Owns authored flow-field definitions, validation, and deterministic sampling for the physics subsystem.
- It keeps geometry math, medium/application metadata, and overlap contribution data outside the main world step owner.
- The file samples vector fields only; body iteration, Rapier mutation, and Lua registration live in neighboring physics files.
- Use this file when stream geometry or combination semantics change; world storage and debug drawing stay elsewhere.

### limits.rs

- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around PhysicsLimits, default, validate_finite, with helpers kept close to their invariants.
- Defines how limits data is validated, transformed, or stored before neighboring systems use it.
- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on limits behavior while Lua registration stays elsewhere.

### mod.rs

- This module re-exports the physics subsystem surface for bodies, shapes, zones, world stepping, and helpers.
- It keeps navigation explicit by mapping which sibling files own body descriptors, geometry, debug output, or zones.
- Public exports here route callers toward `World` for simulation and `Body` or `Shape` for authored physics state.
- `collision.rs` and `collision_helpers.rs` own contact payloads and lightweight overlap checks outside full stepping.
- `body.rs`, `shape.rs`, and `zone.rs` define the core authored inputs that later feed the runtime world owner.
- `flow.rs` owns path and volume flow-field definitions sampled by `world.rs` during stepping.
- Change this file when the public physics symbol map moves; change siblings when simulation data rules change.

### render.rs

- This file owns the physics debug-render bridge that turns simulation state into engine commands and preview images.
- It walks world bodies, colors them by body type, draws shape outlines, and adds velocity arrows for movers.
- The image path rasterizes the same data into `ImageData`, making physics inspection available without the renderer.
- This is the right owner for visualization semantics, not stepping logic, contact generation, or body storage rules.
- Open it when debug draw output changes; runtime world integration and authored shapes live in sibling files.

### shape.rs

- Owns the shape owner for the physics subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around Shape, polygon_area2, is_convex_polygon, with helpers kept close to their invariants.
- Defines how shape data is validated, transformed, or stored before neighboring systems use it.
- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on shape behavior while Lua registration stays elsewhere.
- Documents the boundary where physics code accepts inputs, reports errors, or updates state.
- Use this file when changing shape defaults, lifecycle handling, validation, or data ownership.

### terrain.rs

- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps physics data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how terrain data is validated, transformed, or stored before neighboring systems use it.
- Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on terrain behavior while Lua registration stays elsewhere.
- Documents the boundary where physics code accepts inputs, reports errors, or updates state.
- Use this file when changing terrain defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the physics state that can explain them while keeping call sites explicit.

### types.rs

- This file owns `BodyId`, the stable typed identifier used to reference bodies across the physics subsystem.
- It wraps raw slot indices with conversions, display formatting, and Lua bridging so body handles stay explicit.
- Open this file when body-handle representation changes; world storage and body descriptors live in sibling owners.
- This is the right owner for changing Rust or Lua identity semantics without touching simulation behavior directly.

### world.rs

- This file owns `World`, the Rapier-backed runtime that stores live bodies, colliders, joints, and zones.
- It mirrors authored `Body` data into Rapier sets, keeps stable ids, and tracks tombstones for removed slots.
- Stepping syncs scripted state into Rapier, runs the solver pipeline, then writes motion back into body mirrors.
- Collision handling buffers begin and end contact pairs plus overlap events so gameplay reads post-step results.
- Contact and stats helpers summarize active manifolds, sleeping bodies, collider counts, and joint counts.
- Spatial query helpers provide filtered raycasts, instant beam traces, AABB scans, and point tests.
- Fixture APIs let one body carry multiple colliders, while rebuild paths refresh filters and materials after edits.
- Joint APIs create revolute, rope, prismatic, weld, wheel, friction, motor, and mouse constraints with stable ids.
- Joint utilities also expose motor speeds, limits, break thresholds, connected bodies, and explicit destruction paths.
- Zone integration applies priority-ordered gravity and damping overrides, then emits enter and leave events per body.
- One-way platform handling and sleep controls adapt raw solver behavior to platformer-style gameplay expectations.
- Meter conversion helpers keep pixel-authored content aligned with simulation units without spreading scale math.
- Debug extraction exposes shape snapshots and image drawing support so tools can inspect runtime geometry easily.
- Open this file when runtime ownership or physics behavior changes; pure shape and zone definitions live nearby.
- Keep Lua conversion, renderer submission, asset parsing, and editor UI policy outside this simulation owner.

### zone.rs

- Owns physics zone definitions, priorities, gravity modes, falloffs, boundaries, and membership tracking events.
- Keeps zone validation near the data that needs it so invalid radii, damping, and polygon bounds fail early.
- Provides pure zone containment helpers plus tracker bookkeeping used by `World` during simulation steps.
- Stores no Rapier sets itself; the world applies zone effects after ordering and filtering these definitions.
- Separates authored gravity areas from body, fixture, joint, and collision ownership in nearby physics files.
- Emits enter and leave events through `ZoneTracker` so gameplay reads stable membership changes after stepping.
- Keeps crate-local helpers focused on physics data while Lua binding translation remains in `lua_api`.
- Update this file when zone shapes, priority rules, gravity overrides, or membership event semantics change.
- Keep renderer debug extraction and solver integration outside this file so the zone concept stays reusable.



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
- `lurek.physics.shapeFromImage(image, opts?) -> LPhysicsShape`: Builds an approximate collision shape from an image alpha mask.
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
- `LBody:getCollisionGroup() -> integer?`: Returns the single 0..15 collision group for this body, or nil for multi-group masks.
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
- `LBody:setAirScale(scale) -> nil`: Sets the extra multiplier used only for `air` flow fields.
- `LBody:setAngle(angle) -> nil`: Sets the body's rotation angle directly.
- `LBody:setAngularDamping(damping) -> nil`: Sets the angular damping factor (higher = rotation decays faster).
- `LBody:setAngularVelocity(omega) -> nil`: Sets the body's angular velocity directly.
- `LBody:setBullet(bullet) -> nil`: Enables or disables continuous collision detection to prevent fast-moving tunneling.
- `LBody:setCollisionGroup(group) -> nil`: Assigns the body to one collision group and opens its local mask to the 16 group bits.
- `LBody:setFixedRotation(fixed) -> nil`: Locks or unlocks the body's rotation. Useful for player characters.
- `LBody:setFlowCrossSection(crossSection) -> nil`: Sets the drag cross-section factor used by drag-style flow application.
- `LBody:setFlowScale(scale) -> nil`: Sets the global multiplier applied to all flow-field influences on this body.
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
- `LBody:setWaterScale(scale) -> nil`: Sets the extra multiplier used only for `water` flow fields.
- `LBody:sleep() -> nil`: Forces the body into sleep state, pausing its simulation until disturbed.
- `LBody:type() -> string`: Returns the type name of this object ("LBody").
- `LBody:typeOf(name) -> boolean`: Checks if this object is of a given type name.
- `LBody:wakeUp() -> nil`: Wakes the body from sleep, making it active in the simulation again.

#### LFlowStream Type

- A mutable handle to one authored flow field stored inside a physics world.

##### Fields

- No documented fields.

##### Methods

- `LFlowStream:destroy() -> nil`: Disables this flow field.
- `LFlowStream:getId() -> integer`: Returns this flow field id.
- `LFlowStream:getLayerMask() -> integer`: Returns this flow field layer mask.
- `LFlowStream:getStrength() -> number`: Returns this flow field strength.
- `LFlowStream:isEnabled() -> boolean`: Returns whether this flow field is enabled.
- `LFlowStream:setApplication(mode) -> nil`: Sets the body-application mode used during stepping.
- `LFlowStream:setCombine(mode) -> nil`: Sets how this field combines with overlapping fields.
- `LFlowStream:setEnabled(enabled) -> nil`: Enables or disables this flow field.
- `LFlowStream:setLayerMask(mask) -> nil`: Sets the body-layer mask that this field affects.
- `LFlowStream:setPoints(points) -> nil`: Replaces the polyline points of a path-shaped flow field.
- `LFlowStream:setStrength(strength) -> nil`: Sets this flow field strength.
- `LFlowStream:setWidth(width) -> nil`: Sets the width of a path-shaped flow field.
- `LFlowStream:type() -> string`: Returns the type name of this object.
- `LFlowStream:typeOf(name) -> boolean`: Returns whether this object matches the requested type name.

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
- `LPhysicsShape:getVertexCount() -> integer`: Returns the number of local-space vertices for polygon, rectangle, edge, or chain shapes; circles return 0.
- `LPhysicsShape:getVertices() -> table?`: Returns local-space vertices as an array of `{x, y}` tables, or nil for circles.
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
- `LWorld:addFlowField(opts) -> LFlowStream`: Creates one authored flow field and returns a handle for later mutation.
- `LWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque) -> integer`: Creates a friction joint that applies resistance to relative motion between two bodies.
- `LWorld:addGearJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a gear joint that synchronizes rotation between two bodies at an anchor.
- `LWorld:addGravityVector(gx, gy, layerMask?) -> integer`: Adds an extra directional gravity vector that is summed with world gravity when no non-additive zone override is active.
- `LWorld:addMotorJoint(bodyA, bodyB, factor) -> integer`: Creates a motor joint that drives body B toward a target offset from body A using a correction factor.
- `LWorld:addMouseJoint(bodyId, targetX, targetY, maxForce) -> integer`: Creates a mouse joint that pulls a body toward a world target point with spring-like force.
- `LWorld:addPrismaticJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY) -> integer`: Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.
- `LWorld:addPulleyJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.
- `LWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.
- `LWorld:addRopeJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, maxLength) -> integer`: Creates a rope joint limiting the maximum distance between two anchor points on two bodies.
- `LWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY) -> integer`: Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).
- `LWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY) -> integer`: Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.
- `LWorld:addZone(x, y, w, h) -> LZone`: Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).
- `LWorld:beamAll(x, y, dx, dy, range, filter?) -> table`: Returns all instant beam hits in deterministic distance order.
- `LWorld:beamClosest(x, y, dx, dy, range, filter?) -> table`: Returns only the closest instant beam hit, or nil if nothing blocks the beam.
- `LWorld:castBeam(x, y, dx, dy, range, opts?) -> table`: Casts an instant beam and returns hit plus segment data for gameplay or rendering.
- `LWorld:clear() -> nil`: Removes bodies, joints, terrain colliders, and zones while preserving world-level settings.
- `LWorld:clearBeginContact() -> nil`: Removes the begin-contact callback so it is no longer called.
- `LWorld:clearBodyData(id) -> nil`: Removes and releases the Lua data attached to a body.
- `LWorld:clearBodyOneWay(id) -> nil`: Removes the one-way platform behavior from a body, making it block from all directions.
- `LWorld:clearEndContact() -> nil`: Removes the end-contact callback so it is no longer called.
- `LWorld:clearFlowFields() -> nil`: Disables every authored flow field in the world.
- `LWorld:clearGravityVectors() -> nil`: Removes all additive gravity vectors from the world.
- `LWorld:destroyBody(id) -> nil`: Removes a body from the world by its ID, along with all attached fixtures and joints.
- `LWorld:destroyJoint(jointId) -> nil`: Removes a joint from the world, disconnecting the two bodies it linked.
- `LWorld:drawDebug(target, r?, g?, b?, a?) -> nil`: Renders a debug visualization of all physics bodies onto a software ImageData target.
- `LWorld:drawFlowDebug(target, opts?) -> nil`: Draws flow-field centerlines and sampled arrows into an ImageData target.
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
- `LWorld:getCollisionGroupMask(group) -> integer`: Returns one row of the 16-group collision matrix.
- `LWorld:getCollisionPair(groupA, groupB) -> boolean`: Returns whether collisions are enabled between two world-level collision groups.
- `LWorld:getContacts() -> table`: Returns all currently active contact manifolds with normals and touching state.
- `LWorld:getEndContactEvents() -> table`: Returns contact-end events from the last step (pairs of bodies that stopped touching).
- `LWorld:getFlowField(id) -> table?`: Returns one flow field table by id, or nil when missing.
- `LWorld:getGravity() -> number`: Returns the current world gravity vector.
- `LWorld:getGravityVector(id) -> table?`: Returns an additive gravity vector by ID, or nil when no active vector exists.
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
- `LWorld:removeFlowField(id) -> boolean`: Disables one flow field by id.
- `LWorld:removeGravityVector(id) -> boolean`: Removes one additive gravity vector so it no longer affects future steps.
- `LWorld:resetCollisionGroups() -> nil`: Restores all 16 collision groups so every group can collide with every other group.
- `LWorld:resetWorld() -> nil`: Fully resets the world to its post-construction state.
- `LWorld:sampleFlow(x, y, opts?) -> table`: Samples combined flow at a world position.
- `LWorld:setBeginContact(callback) -> nil`: Registers a callback function invoked whenever two bodies begin touching.
- `LWorld:setBodyCCD(id, enabled) -> nil`: Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.
- `LWorld:setBodyData(id, value) -> nil`: Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).
- `LWorld:setBodyOneWay(id, nx, ny) -> nil`: Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.
- `LWorld:setBodyType(id, bodyType) -> nil`: Changes the type of an existing body (e.g. from "dynamic" to "static").
- `LWorld:setCollisionGroupMask(group, mask) -> nil`: Replaces one row of the 16-group collision matrix.
- `LWorld:setCollisionPair(groupA, groupB, enabled) -> nil`: Enables or disables collisions between two world-level collision groups.
- `LWorld:setEndContact(callback) -> nil`: Registers a callback function invoked whenever two bodies stop touching.
- `LWorld:setFixtureFriction(bodyId, fixtureIndex, friction) -> nil`: Updates the friction coefficient of a specific fixture on a body.
- `LWorld:setFixtureRestitution(bodyId, fixtureIndex, restitution) -> nil`: Updates the restitution (bounciness) of a specific fixture on a body.
- `LWorld:setFixtureSensor(bodyId, fixtureIndex, sensor) -> nil`: Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).
- `LWorld:setGravity(gx, gy) -> nil`: Sets the world gravity vector. Affects all dynamic bodies.
- `LWorld:setGravityVector(id, gx, gy, layerMask?) -> nil`: Replaces the direction, strength, and optional layer mask of an existing additive gravity vector.
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

#### LWorldBeamAllResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyId` (`integer`): BodyId.
- `distance` (`number`): Beam travel distance to the hit.
- `normalX` (`number`): Surface normal X.
- `normalY` (`number`): Surface normal Y.
- `segmentIndex` (`integer`): 1-based segment index inside the trace.
- `x` (`number`): Hit point X.
- `y` (`number`): Hit point Y.

##### Methods

- No documented methods.

#### LWorldBeamClosestResult Type

- Generated result shape from @field tags.

##### Fields

- `bodyId` (`integer`): BodyId.
- `distance` (`number`): Beam travel distance to the hit.
- `normalX` (`number`): Surface normal X.
- `normalY` (`number`): Surface normal Y.
- `segmentIndex` (`integer`): 1-based segment index inside the trace.
- `x` (`number`): Hit point X.
- `y` (`number`): Hit point Y.

##### Methods

- No documented methods.

#### LWorldCastBeamResult Type

- Generated result shape from @field tags.

##### Fields

- `hits` (`table[]`): Array of hit tables {bodyId, x, y, normalX, normalY, distance, segmentIndex}.
- `reachedMaxRange` (`boolean`): True when the beam extended to the requested range.
- `segments` (`table[]`): Array of segment tables {x1, y1, x2, y2, blockedBy}.

##### Methods

- No documented methods.

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
- `flowAffectedBodies` (`integer`): Number of bodies influenced by non-zero flow during the last simulation step.
- `flowFields` (`integer`): Number of active authored flow fields.
- `flowSamples` (`integer`): Number of flow-field samples evaluated during the last simulation step.
- `gravityVectors` (`integer`): Number of active additive gravity vectors.
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
- `LZone:getGravityFalloff() -> string`: Returns the current point/repulsor gravity falloff mode.
- `LZone:getId() -> integer`: Returns the unique ID of this zone. This method is available to Lua scripts.
- `LZone:isGravityAdditive() -> boolean`: Returns whether this zone adds gravity to other fields.
- `LZone:setAngularDampingOverride(value?) -> nil`: Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setCircle(cx, cy, radius) -> nil`: Changes this zone's shape to a circle (overrides the initial rectangle).
- `LZone:setEnabled(enabled) -> nil`: Enables or disables this zone. Disabled zones have no effect on bodies.
- `LZone:setGravityAdditive(additive) -> nil`: Controls whether this zone adds gravity to other fields instead of overriding world gravity by priority.
- `LZone:setGravityDirectional(gx, gy) -> nil`: Sets the zone to apply a constant directional gravity to bodies inside.
- `LZone:setGravityFalloff(mode) -> nil`: Sets point/repulsor gravity falloff. Accepted modes: inverseSquare, inverse, linear, constant.
- `LZone:setGravityLimits(minAccel?, maxAccel?) -> nil`: Sets optional minimum and maximum acceleration clamps for point/repulsor gravity.
- `LZone:setGravityPoint(cx, cy, strength) -> nil`: Sets the zone to attract bodies toward a center point with a given strength.
- `LZone:setGravityRadius(innerRadius, outerRadius?) -> nil`: Sets the inner radius and optional outer radius used by point/repulsor falloff.
- `LZone:setGravityRepulsor(cx, cy, strength) -> nil`: Sets the zone to push bodies away from a center point with a given strength.
- `LZone:setGravityZero() -> nil`: Sets the zone to cancel all gravity for bodies inside (zero-G area).
- `LZone:setLayerMask(mask) -> nil`: Sets a bitmask controlling which body layers this zone affects.
- `LZone:setLinearDampingOverride(value?) -> nil`: Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.
- `LZone:setLinearDrag(value?) -> nil`: Sets or clears area drag proportional to velocity for bodies inside this zone.
- `LZone:setPriority(priority) -> nil`: Sets the priority of this zone. Higher-priority zones take precedence when overlapping.
- `LZone:setQuadraticDrag(value?) -> nil`: Sets or clears area drag proportional to speed times velocity for bodies inside this zone.
- `LZone:type() -> string`: Returns the type name of this object ("LZone").
- `LZone:typeOf(name) -> boolean`: Checks if this object is of a given type name.

## Examples

- `content/examples/physics.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- Beam query contract:
  `LWorld:castBeam`, `LWorld:beamClosest`, and `LWorld:beamAll` are instant spatial queries, not projectile-body simulation. They share the same layer, mask, group, sensor, and `excludeBody` filtering semantics as the raycast family so gameplay can switch between projectiles and hitscan without inventing parallel collision policy. The current release ships the thin-beam path (`thickness = 0`) and leaves thick beam shape-casting as the explicit follow-up; calling `thickness > 0` fails fast so scripts do not assume wide-beam support yet.
- Flow-field contract:
  Authored flow fields live on the world, respect layer masks, can overlap additively, and may be sampled directly from Lua for AI, VFX, UI previews, or debugging. The physics world remains the source of truth for how those currents affect bodies during stepping.
- Body-influence contract:
  Bodies expose per-body flow coefficients so gameplay can scale all flow, air-only flow, water-only flow, and drag cross-section without forking world behavior. Those coefficients are body metadata, not separate force emitters.
- Debug contract:
  Physics debug rendering includes authored flow guides through `drawFlowDebug` so tools and examples can inspect centerlines, coverage bounds, and sampled arrows using the same world-owned data that stepping uses.
