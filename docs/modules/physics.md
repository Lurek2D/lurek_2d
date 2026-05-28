# Physics

- The `physics` module is a core Platform Services tier component that provides a robust, high-performance 2D rigid-body simulation for Lurek2D, backed by the industry-standard Rapier2D (v0.32) engine.

At its center is the `World` struct, which completely encapsulates the Rapier simulation state, including body sets, collider sets, joint sets, and the broad/narrow-phase collision pipelines. The simulation is advanced via deterministic fixed-timestep sub-stepping (`step_fixed`), ensuring consistent and predictable physical interactions regardless of frame rate fluctuations.

The module supports a full spectrum of physics bodies: `dynamic` (fully simulated), `static` (immovable terrain/walls), `kinematic` (script-driven movement that affects dynamic bodies), and `sensor` (detects overlap without physical collision response). These bodies can be composed of various primitives, including circles, rectangles, convex polygons, edge segments, and chain polylines. Developers have granular control over material properties such as density, friction, and restitution (bounciness). Advanced simulation features like continuous collision detection (CCD, or "bullet mode") are available to prevent fast-moving objects from tunneling through walls, and rotation locking ensures character controllers behave predictably.

A comprehensive suite of joints enables complex mechanical linkages between bodies, including revolute (hinge), prismatic (slider), distance (rope), weld, wheel, motor, and mouse joints. The module also features a sophisticated `TerrainMap` system for chunked, destructible environments, automatically synchronizing solid bit-grid cells into static physics colliders for high-performance interaction. Further extending environmental interactions, the `PhysicsZone` system allows developers to define spatial areas (rectangles or circles) that override standard physics rules—applying directional gravity, point attractors, repulsors, or custom damping to bodies that enter them.

Additionally, the `cellular` submodule provides a cellular automaton grid for simulating falling sand, flowing water, and other particle-like materials. For spatial queries, the module offers extensive raycasting, shape-casting, and point intersection tests, alongside pure-geometry collision helpers for lightweight, physics-free checks. The entire system—from body lifecycle management to collision event callbacks and debug rendering—is comprehensively exposed to the Lua environment via the `lurek.physics.*` API, forming the backbone of physical interactions in Lurek2D games.

## Functions

### `lurek.physics.attachShape`

Attaches a previously created shape to a body, using the shape's stored material properties.

```lua
-- signature
lurek.physics.attachShape(body, shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | `LBody` | The target body. |
| `shape` | `LPhysicsShape` | The shape to attach. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    print("fixture_count", world:fixtureCount(body:getId()))
    print("position", body:getPosition())
end
```

---

### `lurek.physics.debugDraw`

Enables or disables automatic physics debug overlay rendering for the next frame.

```lua
-- signature
lurek.physics.debugDraw(enable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enable` | `boolean` | True to show debug shapes. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    lurek.physics.drawDebugGpu(world, { lineWidth = 2 })
    print("body_count", world:getBodyCount())
end
```

---

### `lurek.physics.destroyWorld`

No-op placeholder for API parity. Worlds are freed when no longer referenced.

```lua
-- signature
lurek.physics.destroyWorld(world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    print("before", world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("after", world:getBodyCount())
end
```

---

### `lurek.physics.drawDebugGpu`

Queues a GPU-rendered physics debug visualization using the world's current body state.

```lua
-- signature
lurek.physics.drawDebugGpu(world, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world to visualize. |
| `config?` | `table` | Optional config: {bodyColor, staticColor, sleepColor, sensorColor, lineWidth}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    lurek.physics.drawDebugGpu(world, {})
    print("body_count", world:getBodyCount())
end
```

---

### `lurek.physics.getBody`

Returns position and velocity of a body (free-function variant for quick queries).

```lua
-- signature
lurek.physics.getBody(world, body)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world. |
| `body` | `LBody` | The body to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X position. |
| `number` | b Y position. |
| `number` | c Velocity X. |
| `number` | d Velocity Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    body:setVelocity(10, 5)
    print("body", lurek.physics.getBody(world, body))
end
```

---

### `lurek.physics.getCollisions`

Returns all collision events from the last world step as {body_a, body_b} pairs.

```lua
-- signature
lurek.physics.getCollisions(world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world to query. |

**Returns**

| Type | Description |
|------|-------------|
| `PhysicsGetCollisionsResult` | Array of collision event tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    print("count", #collisions)
    if collisions[1] then
        print("first", collisions[1].body_a, collisions[1].body_b)
    end
end
```

---

### `lurek.physics.isSleepingAllowed`

Checks if sleeping is allowed on a body (free-function variant).

```lua
-- signature
lurek.physics.isSleepingAllowed(world, body)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world. |
| `body` | `LBody` | The body. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if sleeping is allowed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    print("allowed", lurek.physics.isSleepingAllowed(world, body))
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed_after", lurek.physics.isSleepingAllowed(world, body))
end
```

---

### `lurek.physics.newBody`

Creates a new body in a world (free-function variant).

```lua
-- signature
lurek.physics.newBody(world, x, y, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The target world. |
| `x` | `number` | Initial X position. |
| `y` | `number` | Initial Y position. |
| `bodyType` | `string` | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = lurek.physics.newBody(world, 50, 50, "static")
    print("id", body:getId())
    print("type", body:getType())
end
```

---

### `lurek.physics.newChainShape`

Creates a chain (polyline) collision shape. Useful for terrain outlines.

```lua
-- signature
lurek.physics.newChainShape(closed, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `closed` | `boolean` | If true, connects last vertex to first. |
| — | — | @param ... number Alternating x,y coordinates (minimum 2 pairs = 4 numbers). |

**Returns**

| Type | Description |
|------|-------------|
| `LPhysicsShape` | The shape object. |

**Example**

```lua
do
    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100)
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100)
    print("open_type", chain:getType())
    print("closed_type", loop:getType())
end
```

---

### `lurek.physics.newCircleShape`

Creates a circle collision shape with the given radius.

```lua
-- signature
lurek.physics.newCircleShape(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Radius. |

**Returns**

| Type | Description |
|------|-------------|
| `LPhysicsShape` | The shape object. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(16)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    print("type", circle:getType())
    print("radius", circle:getRadius())
    print("bounds", minX, minY, maxX, maxY)
end
```

---

### `lurek.physics.newEdgeShape`

Creates an edge (line segment) collision shape between two local points.

```lua
-- signature
lurek.physics.newEdgeShape(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | Start X. |
| `y1` | `number` | Start Y. |
| `x2` | `number` | End X. |
| `y2` | `number` | End Y. |

**Returns**

| Type | Description |
|------|-------------|
| `LPhysicsShape` | The shape object. |

**Example**

```lua
do
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    local minX, minY, maxX, maxY = edge:getBoundingBox()
    print("type", edge:getType())
    print("bounds", minX, minY, maxX, maxY)
end
```

---

### `lurek.physics.newPolygonShape`

Creates a convex polygon collision shape from vertex coordinate pairs.

```lua
-- signature
lurek.physics.newPolygonShape(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Alternating x,y coordinates (minimum 3 pairs = 6 numbers). |

**Returns**

| Type | Description |
|------|-------------|
| `LPhysicsShape` | The shape object. |

**Example**

```lua
do
    local triangle = lurek.physics.newPolygonShape(0, -20, -15, 15, 15, 15)
    local minX, minY, maxX, maxY = triangle:getBoundingBox()
    print("type", triangle:getType())
    print("bounds", minX, minY, maxX, maxY)
end
```

---

### `lurek.physics.newRectangleShape`

Creates a rectangle collision shape with the given dimensions.

```lua
-- signature
lurek.physics.newRectangleShape(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Width. |
| `h` | `number` | Height. |

**Returns**

| Type | Description |
|------|-------------|
| `LPhysicsShape` | The shape object. |

**Example**

```lua
do
    local rect = lurek.physics.newRectangleShape(64, 32)
    local minX, minY, maxX, maxY = rect:getBoundingBox()
    print("type", rect:getType())
    print("bounds", minX, minY, maxX, maxY)
end
```

---

### `lurek.physics.newTerrain`

Creates a destructible terrain grid linked to a physics world for automatic collider generation.

```lua
-- signature
lurek.physics.newTerrain(width, height, cellSize, world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |
| `cellSize` | `number` | World-space size of each cell. |
| `world` | `LWorld` | The physics world that will own the generated colliders. |

**Returns**

| Type | Description |
|------|-------------|
| `LTerrain` | The terrain object. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 128, 40, false)
    terrain:flush()
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end
```

---

### `lurek.physics.newWorld`

Creates a new physics world with the given gravity vector.

```lua
-- signature
lurek.physics.newWorld(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | `number` | Gravity X component. |
| `gy` | `number` | Gravity Y component (positive = down). |

**Returns**

| Type | Description |
|------|-------------|
| `LWorld` | The new physics world. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    print("type", world:type())
end
```

---

### `lurek.physics.setBodyVelocity`

Sets a body's velocity (free-function variant).

```lua
-- signature
lurek.physics.setBodyVelocity(world, body, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world. |
| `body` | `LBody` | The body. |
| `vx` | `number` | Velocity X. |
| `vy` | `number` | Velocity Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    print("velocity", body:getVelocity())
end
```

---

### `lurek.physics.setSleepingAllowed`

Sets whether a body is allowed to sleep (free-function variant).

```lua
-- signature
lurek.physics.setSleepingAllowed(world, body, allowed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world. |
| `body` | `LBody` | The body. |
| `allowed` | `boolean` | True to allow sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed", body:isSleepingAllowed())
end
```

---

### `lurek.physics.step`

Steps a physics world forward by dt seconds (free-function variant).

```lua
-- signature
lurek.physics.step(world, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | `LWorld` | The world to step. |
| `dt` | `number` | Time step in seconds. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.step(world, 1 / 60)
    print("body", lurek.physics.getBody(world, body))
end
```

---

### `lurek.physics.testAABB`

Tests whether two axis-aligned bounding boxes overlap. Lightweight collision check without physics world.

```lua
-- signature
lurek.physics.testAABB(ax, ay, aw, ah, bx, by, bw, bh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | `number` | First rect X. |
| `ay` | `number` | First rect Y. |
| `aw` | `number` | First rect width. |
| `ah` | `number` | First rect height. |
| `bx` | `number` | Second rect X. |
| `by` | `number` | Second rect Y. |
| `bw` | `number` | Second rect width. |
| `bh` | `number` | Second rect height. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the rectangles overlap. |

**Example**

```lua
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    local miss = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    print("overlap", overlap)
    print("miss", miss)
end
```

---

### `lurek.physics.testCircleAABB`

Tests whether a circle overlaps an AABB. Lightweight check without physics world.

```lua
-- signature
lurek.physics.testCircleAABB(cx, cy, cr, ax, ay, aw, ah)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Circle center X. |
| `cy` | `number` | Circle center Y. |
| `cr` | `number` | Circle radius. |
| `ax` | `number` | Rect X. |
| `ay` | `number` | Rect Y. |
| `aw` | `number` | Rect width. |
| `ah` | `number` | Rect height. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if circle and AABB overlap. |

**Example**

```lua
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    print("hit", hit)
    print("miss", miss)
end
```

---

### `lurek.physics.testCircles`

Tests whether two circles overlap. Lightweight collision check without physics world.

```lua
-- signature
lurek.physics.testCircles(ax, ay, ar, bx, by, br)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | `number` | First circle center X. |
| `ay` | `number` | First circle center Y. |
| `ar` | `number` | First circle radius. |
| `bx` | `number` | Second circle center X. |
| `by` | `number` | Second circle center Y. |
| `br` | `number` | Second circle radius. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the circles overlap. |

**Example**

```lua
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    print("touching", touching)
    print("apart", apart)
end
```

---

### `lurek.physics.testPoint`

Tests whether a point lies inside an AABB. Lightweight check without physics world.

```lua
-- signature
lurek.physics.testPoint(px, py, ax, ay, aw, ah)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | `number` | Point X. |
| `py` | `number` | Point Y. |
| `ax` | `number` | Rect X. |
| `ay` | `number` | Rect Y. |
| `aw` | `number` | Rect width. |
| `ah` | `number` | Rect height. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the point is inside. |

**Example**

```lua
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    print("inside", inside)
    print("outside", outside)
end
```

---

## LBody

### `LBody:applyAngularImpulse`

Applies an instantaneous angular impulse (spin) to the body.

```lua
-- signature
LBody:applyAngularImpulse(impulse)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `impulse` | `number` | Angular impulse value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyAngularImpulse(5.0)
    world:step(1 / 60)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end
```

---

### `LBody:applyForce`

Applies a continuous force to the body's center of mass (accumulates over the step).

```lua
-- signature
LBody:applyForce(fx, fy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | `number` | Force X component. |
| `fy` | `number` | Force Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("position", body:getPosition())
end
```

---

### `LBody:applyForceAtPoint`

Applies a force at a specific world point, generating both linear and angular acceleration.

```lua
-- signature
LBody:applyForceAtPoint(fx, fy, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | `number` | Force X component. |
| `fy` | `number` | Force Y component. |
| `px` | `number` | Application point X in world coordinates. |
| `py` | `number` | Application point Y in world coordinates. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForceAtPoint(0, -50, 210, 200)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("angular_velocity", body:getAngularVelocity())
end
```

---

### `LBody:applyImpulse`

Applies an instantaneous linear impulse to the body's center of mass.

```lua
-- signature
LBody:applyImpulse(ix, iy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ix` | `number` | Impulse X component. |
| `iy` | `number` | Impulse Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyImpulse(0, -200)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("position", body:getPosition())
end
```

---

### `LBody:applyTorque`

Applies a rotational torque to the body.

```lua
-- signature
LBody:applyTorque(torque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `torque` | `number` | Torque value (positive = counter-clockwise). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyTorque(10.0)
    world:step(1 / 60)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end
```

---

### `LBody:destroy`

Destroys this body, removing it from the world along with all fixtures and joints.

```lua
-- signature
LBody:destroy()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    print("before", world:getBodyCount())
    temp:destroy()
    print("after", world:getBodyCount())
end
```

---

### `LBody:getAngle`

Returns the body's rotation angle in radians.

```lua
-- signature
LBody:getAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Angle in radians. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 6)
    print("angle", body:getAngle())
    print("position", body:getPosition())
end
```

---

### `LBody:getAngularDamping`

Returns the angular damping factor (rotational decay rate).

```lua
-- signature
LBody:getAngularDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Angular damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.9)
    print("angular_damping", body:getAngularDamping())
    print("linear_damping", body:getLinearDamping())
end
```

---

### `LBody:getAngularVelocity`

Returns the body's angular (rotational) velocity.

```lua
-- signature
LBody:getAngularVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Angular velocity in radians per second. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(1.25)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end
```

---

### `LBody:getFriction`

Returns the body's friction coefficient.

```lua
-- signature
LBody:getFriction()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Friction value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.25)
    print("friction", body:getFriction())
    print("restitution", body:getRestitution())
end
```

---

### `LBody:getGravityScale`

Returns the gravity scale multiplier for this body (1.0 = normal gravity).

```lua
-- signature
LBody:getGravityScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Gravity scale. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setGravityScale(-1.0)
    print("gravity_scale", body:getGravityScale())
    print("type", body:getType())
end
```

---

### `LBody:getHeight`

Returns the body's bounding height (from its primary shape).

```lua
-- signature
LBody:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in world units. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("position", body:getPosition())
    print("size", body:getWidth(), body:getHeight())
end
```

---

### `LBody:getId`

Returns the unique numeric ID of this body within the world.

```lua
-- signature
LBody:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("id", body:getId())
    print("position", body:getPosition())
end
```

---

### `LBody:getLayer`

Returns the body's collision layer bitmask.

```lua
-- signature
LBody:getLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(4)
    print("layer", body:getLayer())
    print("type", body:getType())
end
```

---

### `LBody:getLinearDamping`

Returns the linear damping factor (velocity decay rate, like air resistance).

```lua
-- signature
LBody:getLinearDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.75)
    print("linear_damping", body:getLinearDamping())
    print("velocity", body:getVelocity())
end
```

---

### `LBody:getMask`

Returns the body's collision mask (which layers this body can collide with).

```lua
-- signature
LBody:getMask()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Mask bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(7)
    print("mask", body:getMask())
    print("id", body:getId())
end
```

---

### `LBody:getMass`

Returns the body's total mass (computed from density and fixture areas).

```lua
-- signature
LBody:getMass()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Mass in kilograms. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass", body:getMass())
    print("friction", body:getFriction())
    print("restitution", body:getRestitution())
end
```

---

### `LBody:getPosition`

Returns the current world-space position of this body.

```lua
-- signature
LBody:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X coordinate. |
| `number` | b Y coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("position", body:getPosition())
    print("id", body:getId())
end
```

---

### `LBody:getRestitution`

Returns the body's restitution (bounciness) value.

```lua
-- signature
LBody:getRestitution()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Restitution (0 = no bounce, 1 = perfectly elastic). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.15)
    print("restitution", body:getRestitution())
    print("friction", body:getFriction())
end
```

---

### `LBody:getType`

Returns the body's type as a string.

```lua
-- signature
LBody:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "sensor")
    print("type", body:getType())
    print("id", body:getId())
end
```

---

### `LBody:getVelocity`

Returns the body's current linear velocity.

```lua
-- signature
LBody:getVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Velocity X component. |
| `number` | b Velocity Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(25, -50)
    print("velocity", body:getVelocity())
    print("type", body:getType())
end
```

---

### `LBody:getWidth`

Returns the body's bounding width (from its primary shape).

```lua
-- signature
LBody:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in world units. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("width", body:getWidth())
    print("height", body:getHeight())
end
```

---

### `LBody:getX`

Returns only the X component of the body's position.

```lua
-- signature
LBody:getX()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | X coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("x", body:getX())
    print("y", body:getY())
end
```

---

### `LBody:getY`

Returns only the Y component of the body's position.

```lua
-- signature
LBody:getY()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Y coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("y", body:getY())
    print("x", body:getX())
end
```

---

### `LBody:isBullet`

Returns whether continuous collision detection (bullet mode) is enabled for this body.

```lua
-- signature
LBody:isBullet()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if CCD is active. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is_bullet", bullet:isBullet())
    print("position", bullet:getPosition())
end
```

---

### `LBody:isFixedRotation`

Returns whether the body's rotation is locked.

```lua
-- signature
LBody:isFixedRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if rotation is fixed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed_rotation", player:isFixedRotation())
    print("type", player:getType())
end
```

---

### `LBody:isSleeping`

Returns whether this body is currently in the sleeping (inactive) state.

```lua
-- signature
LBody:isSleeping()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    print("sleeping", body:isSleeping())
    print("id", body:getId())
end
```

---

### `LBody:isSleepingAllowed`

Returns whether the body is allowed to enter sleep state when at rest.

```lua
-- signature
LBody:isSleepingAllowed()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if sleeping is allowed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("allowed", body:isSleepingAllowed())
    print("type", body:getType())
end
```

---

### `LBody:setAngle`

Sets the body's rotation angle directly.

```lua
-- signature
LBody:setAngle(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | `number` | New angle in radians. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle", body:getAngle())
    print("angular_velocity", body:getAngularVelocity())
end
```

---

### `LBody:setAngularDamping`

Sets the angular damping factor (higher = rotation decays faster).

```lua
-- signature
LBody:setAngularDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | `number` | Angular damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.3)
    print("angular_damping", body:getAngularDamping())
    print("angle", body:getAngle())
end
```

---

### `LBody:setAngularVelocity`

Sets the body's angular velocity directly.

```lua
-- signature
LBody:setAngularVelocity(omega)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `omega` | `number` | Angular velocity in radians per second. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(2.0)
    print("angular_velocity", body:getAngularVelocity())
    world:step(1 / 60)
    print("angle", body:getAngle())
end
```

---

### `LBody:setBullet`

Enables or disables continuous collision detection to prevent fast-moving tunneling.

```lua
-- signature
LBody:setBullet(bullet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bullet` | `boolean` | True to enable CCD. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is_bullet", bullet:isBullet())
    print("type", bullet:getType())
end
```

---

### `LBody:setFixedRotation`

Locks or unlocks the body's rotation. Useful for player characters.

```lua
-- signature
LBody:setFixedRotation(fixed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fixed` | `boolean` | True to prevent rotation. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed_rotation", player:isFixedRotation())
    print("angle", player:getAngle())
end
```

---

### `LBody:setFriction`

Sets the body's friction coefficient.

```lua
-- signature
LBody:setFriction(friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `friction` | `number` | New friction value (0 = ice, 1 = rubber). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.8)
    print("friction", body:getFriction())
    print("mass", body:getMass())
end
```

---

### `LBody:setGravityScale`

Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).

```lua
-- signature
LBody:setGravityScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | `number` | Gravity scale factor. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    floaty:setGravityScale(0.2)
    print("normal", normal:getGravityScale())
    print("floaty", floaty:getGravityScale())
end
```

---

### `LBody:setLayer`

Sets the body's collision layer bitmask (which layers this body belongs to).

```lua
-- signature
LBody:setLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `number` | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(2)
    print("layer", body:getLayer())
    print("mask", body:getMask())
end
```

---

### `LBody:setLinearDamping`

Sets the linear damping factor (higher = more velocity decay per step).

```lua
-- signature
LBody:setLinearDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | `number` | Damping value (0 = no damping). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    print("linear_damping", body:getLinearDamping())
    print("angular_damping", body:getAngularDamping())
end
```

---

### `LBody:setMask`

Sets the body's collision mask (which layers this body can collide with).

```lua
-- signature
LBody:setMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | `number` | Collision mask bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(3)
    print("mask", body:getMask())
    print("layer", body:getLayer())
end
```

---

### `LBody:setMass`

Overrides the body's mass directly.

```lua
-- signature
LBody:setMass(mass)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mass` | `number` | New mass value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(7.5)
    print("mass", body:getMass())
    print("type", body:getType())
end
```

---

### `LBody:setPosition`

Teleports the body to a new world-space position (does not apply physics forces).

```lua
-- signature
LBody:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | New X position. |
| `y` | `number` | New Y position. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    print("position", body:getPosition())
    print("velocity", body:getVelocity())
end
```

---

### `LBody:setRestitution`

Sets the body's restitution (bounciness) value.

```lua
-- signature
LBody:setRestitution(restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `restitution` | `number` | New restitution (0Ă˘â‚¬â€ś1). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    print("restitution", body:getRestitution())
    print("mass", body:getMass())
end
```

---

### `LBody:setSleepingAllowed`

Controls whether the body can enter sleep state. Disable for bodies that must stay active.

```lua
-- signature
LBody:setSleepingAllowed(allowed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `allowed` | `boolean` | True to allow sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(false)
    print("allowed", body:isSleepingAllowed())
    print("sleeping", body:isSleeping())
end
```

---

### `LBody:setType`

Changes the body's type at runtime.

```lua
-- signature
LBody:setType(bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyType` | `string` | New type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type", body:getType())
    print("layer", body:getLayer())
end
```

---

### `LBody:setVelocity`

Directly sets the body's linear velocity.

```lua
-- signature
LBody:setVelocity(vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | `number` | Velocity X component. |
| `vy` | `number` | Velocity Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(50, -100)
    print("velocity", body:getVelocity())
    world:step(1 / 60)
    print("position", body:getPosition())
end
```

---

### `LBody:sleep`

Forces the body into sleep state, pausing its simulation until disturbed.

```lua
-- signature
LBody:sleep()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    print("sleeping", body:isSleeping())
    print("allowed", body:isSleepingAllowed())
end
```

---

### `LBody:type`

Returns the type name of this object ("LBody").

```lua
-- signature
LBody:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LBody". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type", body:type())
    print("type_of", body:typeOf("LBody"), body:typeOf("LObject"))
end
```

---

### `LBody:typeOf`

Checks if this object is of a given type name.

```lua
-- signature
LBody:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type_of", body:typeOf("LBody"), body:typeOf("LObject"))
    print("type", body:type())
end
```

---

### `LBody:wakeUp`

Wakes the body from sleep, making it active in the simulation again.

```lua
-- signature
LBody:wakeUp()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    body:wakeUp()
    print("sleeping", body:isSleeping())
    print("allowed", body:isSleepingAllowed())
end
```

---

## LCellular

### `LCellular:countCells`

Counts how many cells of a given material type exist in the grid.

```lua
-- signature
LCellular:countCells(cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cellType` | `number` | Material type constant to count. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cell count. |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("count", ca:countCells(lurek.physics.CELL_SAND))
    print("type", ca:type())
end
```

---

### `LCellular:fillCircle`

Fills a circular region of cells with a material type.

```lua
-- signature
LCellular:fillCircle(cx, cy, r, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Center cell column. |
| `cy` | `number` | Center cell row. |
| `r` | `number` | Radius in cells. |
| `cellType` | `number` | Material type constant. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillCircle(64, 64, 15, lurek.physics.CELL_FIRE)
    print("fire", grid:countCells(lurek.physics.CELL_FIRE))
    print("type", grid:type())
end
```

---

### `LCellular:fillRect`

Fills a rectangular region of cells with a material type.

```lua
-- signature
LCellular:fillRect(cx0, cy0, cw, ch, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx0` | `number` | Top-left cell column. |
| `cy0` | `number` | Top-left cell row. |
| `cw` | `number` | Width in cells. |
| `ch` | `number` | Height in cells. |
| `cellType` | `number` | Material type constant. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillRect(10, 10, 20, 5, lurek.physics.CELL_WATER)
    print("water", grid:countCells(lurek.physics.CELL_WATER))
    print("type", grid:type())
end
```

---

### `LCellular:findCells`

Returns positions of all cells matching a material type.

```lua
-- signature
LCellular:findCells(cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cellType` | `number` | Material type constant to find. |

**Returns**

| Type | Description |
|------|-------------|
| `LCellularFindCellsResult` | Array of {x, y} tables with cell coordinates. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, lurek.physics.CELL_SAND)
    local positions = grid:findCells(lurek.physics.CELL_SAND)
    print("count", #positions)
    if positions[1] then
        print("first", positions[1].x, positions[1].y)
    end
end
```

---

### `LCellular:getCell`

Returns the material type of a cell at the given grid position.

```lua
-- signature
LCellular:getCell(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Cell column. |
| `cy` | `number` | Cell row. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Material type constant. |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("cell", ca:getCell(5, 5))
    print("count", ca:countCells(lurek.physics.CELL_SAND))
end
```

---

### `LCellular:loadFromBytes`

Restores cellular grid state from binary data previously produced by toBytes.

```lua
-- signature
LCellular:loadFromBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Binary cellular data. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if loading succeeded, false if data was invalid. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local bytes = grid:toBytes()
    local clone = lurek.physics.newCellular(32, 32)
    print("loaded", clone:loadFromBytes(bytes))
    print("cell", clone:getCell(16, 16))
end
```

---

### `LCellular:setCell`

Sets a single cell in the cellular grid to a specific material type.

```lua
-- signature
LCellular:setCell(cx, cy, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Cell column (0-based). |
| `cy` | `number` | Cell row (0-based). |
| `cellType` | `number` | Material type constant (CELL_AIR, CELL_SAND, etc.). |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("cell", ca:getCell(5, 5))
    print("type", ca:type())
end
```

---

### `LCellular:step`

Advances the cellular simulation by one tick (particles fall, flow, burn, etc.).

```lua
-- signature
LCellular:step()
```

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    ca:step()
    print("count", ca:countCells(lurek.physics.CELL_SAND))
    print("type", ca:type())
end
```

---

### `LCellular:stepN`

Advances the cellular simulation by N ticks in a single call.

```lua
-- signature
LCellular:stepN(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of simulation ticks to run. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, lurek.physics.CELL_SAND)
    grid:stepN(10)
    print("sand", grid:countCells(lurek.physics.CELL_SAND))
    print("type", grid:type())
end
```

---

### `LCellular:toBytes`

Serializes the cellular grid to a compact binary format for saving.

```lua
-- signature
LCellular:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary cellular data. |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local bytes = grid:toBytes()
    print("bytes", #bytes)
    print("type", grid:type())
end
```

---

### `LCellular:toImageData`

Renders the entire cellular grid to raw RGBA pixel data using the default material palette.

```lua
-- signature
LCellular:toImageData()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Raw RGBA pixel bytes (width * height * 4). |

**Example**

```lua
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local pixels = grid:toImageData()
    print("bytes", #pixels)
    print("count", grid:countCells(lurek.physics.CELL_SAND))
end
```

---

### `LCellular:toImageDataRegion`

Renders a rectangular sub-region of the cellular grid to raw RGBA pixel data.

```lua
-- signature
LCellular:toImageDataRegion(cx0, cy0, cw, ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx0` | `number` | Top-left cell column. |
| `cy0` | `number` | Top-left cell row. |
| `cw` | `number` | Width in cells. |
| `ch` | `number` | Height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Raw RGBA pixel bytes (cw * ch * 4). |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("bytes", #img)
    print("type", ca:type())
end
```

---

### `LCellular:type`

Returns the type name of this object ("LCellular").

```lua
-- signature
LCellular:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LCellular". |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    print("type", ca:type())
    print("type_of", ca:typeOf("LCellular"))
end
```

---

### `LCellular:typeOf`

Checks if this object is of a given type name.

```lua
-- signature
LCellular:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local ca = lurek.physics.newCellular(32, 32)
    print("type_of", ca:typeOf("LCellular"), ca:typeOf("LObject"))
    print("type", ca:type())
end
```

---

## LPhysicsShape

### `LPhysicsShape:destroy`

No-op placeholder for API consistency. Shapes are freed when no longer referenced.

```lua
-- signature
LPhysicsShape:destroy()
```

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    shape:destroy()
    print("type", shape:getType())
end
```

---

### `LPhysicsShape:getBoundingBox`

Returns the axis-aligned bounding box of the shape in local coordinates.

```lua
-- signature
LPhysicsShape:getBoundingBox()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum X. |
| `number` | b Minimum Y. |
| `number` | c Maximum X. |
| `number` | d Maximum Y. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("bounds", circle:getBoundingBox())
    print("type", circle:getType())
end
```

---

### `LPhysicsShape:getRadius`

Returns the radius of a circle shape. Errors if called on a non-circle shape.

```lua
-- signature
LPhysicsShape:getRadius()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Circle radius. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("radius", circle:getRadius())
    print("type", circle:getType())
end
```

---

### `LPhysicsShape:getType`

Returns the shape kind as a string: "circle", "rectangle", "polygon", "edge", or "chain".

```lua
-- signature
LPhysicsShape:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Shape type name. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("type", circle:getType())
    print("bounds", circle:getBoundingBox())
end
```

---

### `LPhysicsShape:setDensity`

Sets the density used when this shape is attached to a body (affects mass calculation).

```lua
-- signature
LPhysicsShape:setDensity(density)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `density` | `number` | Mass density. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end
```

---

### `LPhysicsShape:setFriction`

Sets the friction coefficient for this shape.

```lua
-- signature
LPhysicsShape:setFriction(friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `friction` | `number` | Friction (0 = ice, 1 = rubber). |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end
```

---

### `LPhysicsShape:setRestitution`

Sets the restitution (bounciness) for this shape.

```lua
-- signature
LPhysicsShape:setRestitution(restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `restitution` | `number` | Restitution (0\u20131). |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end
```

---

### `LPhysicsShape:setSensor`

Marks this shape as a sensor (overlap detection only, no physical response).

```lua
-- signature
LPhysicsShape:setSensor(sensor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sensor` | `boolean` | True for sensor mode. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(true)
    print("type", shape:getType())
    print("bounds", shape:getBoundingBox())
end
```

---

### `LPhysicsShape:type`

Returns the type name of this object ("LPhysicsShape").

```lua
-- signature
LPhysicsShape:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LPhysicsShape". |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    print("type", shape:type())
end
```

---

### `LPhysicsShape:typeOf`

Checks if this object is of a given type name.

```lua
-- signature
LPhysicsShape:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    print("type_of", shape:typeOf("LPhysicsShape"))
    print("type", shape:type())
end
```

---

## LTerrain

### `LTerrain:collapseColumns`

Optimizes terrain by merging vertically adjacent solid cells into larger colliders.

```lua
-- signature
LTerrain:collapseColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of columns collapsed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    print("collapsed", terrain:collapseColumns())
    print("dirty", terrain:isDirty())
end
```

---

### `LTerrain:fillAll`

Sets all terrain cells to either solid or empty.

```lua
-- signature
LTerrain:fillAll(solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `solid` | `boolean` | True to fill everything solid, false to clear. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end
```

---

### `LTerrain:fillCircle`

Fills or clears a circular region of terrain cells.

```lua
-- signature
LTerrain:fillCircle(wx, wy, radius, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | `number` | Circle center X in world coordinates. |
| `wy` | `number` | Circle center Y in world coordinates. |
| `radius` | `number` | Circle radius in world units. |
| `solid` | `boolean` | True to fill solid, false to carve empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 256, 50, false)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end
```

---

### `LTerrain:fillRect`

Fills or clears a rectangular region of terrain cells.

```lua
-- signature
LTerrain:fillRect(wx, wy, w, h, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | `number` | Rectangle left X in world coordinates. |
| `wy` | `number` | Rectangle top Y in world coordinates. |
| `w` | `number` | Rectangle width. |
| `h` | `number` | Rectangle height. |
| `solid` | `boolean` | True to fill solid, false to carve empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillRect(80, 80, 40, 40, false)
    print("dirty", terrain:isDirty())
    print("cell", terrain:getCell(10, 10))
end
```

---

### `LTerrain:flush`

Regenerates physics colliders from the current terrain grid state. Call after modifying cells.

```lua
-- signature
LTerrain:flush()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:flush()
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end
```

---

### `LTerrain:getCell`

Returns whether a cell is solid. This method is available to Lua scripts.

```lua
-- signature
LTerrain:getCell(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Cell column. |
| `cy` | `number` | Cell row. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the cell is solid. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    print("cell", terrain:getCell(5, 5))
    print("type", terrain:type())
end
```

---

### `LTerrain:isDirty`

Returns true if terrain cells have been modified since the last flush.

```lua
-- signature
LTerrain:isDirty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a flush is needed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end
```

---

### `LTerrain:loadFromBytes`

Restores terrain grid state from binary data previously produced by toBytes.

```lua
-- signature
LTerrain:loadFromBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Binary terrain data. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if loading succeeded. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local bytes = terrain:toBytes()
    local clone = lurek.physics.newTerrain(32, 32, 4, world)
    print("loaded", clone:loadFromBytes(bytes))
    print("cell", clone:getCell(0, 0))
end
```

---

### `LTerrain:setCell`

Sets a single terrain cell to solid or empty.

```lua
-- signature
LTerrain:setCell(cx, cy, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Cell column (0-based). |
| `cy` | `number` | Cell row (0-based). |
| `solid` | `boolean` | True for solid, false for empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    print("cell", terrain:getCell(5, 5))
    print("dirty", terrain:isDirty())
end
```

---

### `LTerrain:solidPositions`

Returns all solid cell positions as a table of {x, y} entries.

```lua
-- signature
LTerrain:solidPositions()
```

**Returns**

| Type | Description |
|------|-------------|
| `LTerrainSolidPositionsResult` | Array of tables with x and y fields (cell coordinates). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    print("count", #solids)
    if solids[1] then
        print("first", solids[1].x, solids[1].y)
    end
end
```

---

### `LTerrain:spawnDebris`

Spawns small dynamic debris bodies at the given positions (for destruction effects).

```lua
-- signature
LTerrain:spawnDebris(positions, mass, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `positions` | `table` | Array of {x, y} tables in world coordinates. |
| `mass` | `number` | Mass of each debris body. |
| `restitution` | `number` | Bounciness of debris bodies. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of body IDs for the spawned debris. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:flush()
    local debris = terrain:spawnDebris({ { x = 64, y = 64 }, { x = 72, y = 64 } }, 1.0, 0.2)
    print("count", #debris)
    print("body_count", world:getBodyCount())
end
```

---

### `LTerrain:toBytes`

Serializes the terrain grid to a compact binary format for saving.

```lua
-- signature
LTerrain:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary terrain data. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local bytes = terrain:toBytes()
    print("bytes", #bytes)
    print("dirty", terrain:isDirty())
end
```

---

### `LTerrain:toImageData`

Renders the terrain grid to raw RGBA pixel data with solid and empty colors.

```lua
-- signature
LTerrain:toImageData(sr, sg, sb, er, eg, eb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sr` | `number` | Solid color red (0-255). |
| `sg` | `number` | Solid color green. |
| `sb` | `number` | Solid color blue. |
| `er` | `number` | Empty color red. |
| `eg` | `number` | Empty color green. |
| `eb` | `number` | Empty color blue. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Raw RGBA pixel bytes. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local pixels = terrain:toImageData(255, 255, 255, 0, 0, 0)
    print("bytes", #pixels)
    print("type", terrain:type())
end
```

---

### `LTerrain:type`

Returns the type name of this object ("LTerrain").

```lua
-- signature
LTerrain:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LTerrain". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    print("type", terrain:type())
    print("type_of", terrain:typeOf("LTerrain"))
end
```

---

### `LTerrain:typeOf`

Checks if this object is of a given type name.

```lua
-- signature
LTerrain:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    print("type_of", terrain:typeOf("LTerrain"), terrain:typeOf("LObject"))
    print("type", terrain:type())
end
```

---

## LWorld

### `LWorld:addDistanceJoint`

Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.

```lua
-- signature
LWorld:addDistanceJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, length)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorAX` | `number` | Local anchor X on body A. |
| `anchorAY` | `number` | Local anchor Y on body A. |
| `anchorBX` | `number` | Local anchor X on body B. |
| `anchorBY` | `number` | Local anchor Y on body B. |
| `length` | `number` | Target distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(bodyA:getId(), bodyB:getId(), 0, 0, 0, 0, 100)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addFixture`

Attaches a new collider shape to an existing body with material properties.

```lua
-- signature
LWorld:addFixture(bodyId, shapeType, density, friction, restitution, sensor, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The target body ID. |
| `shapeType` | `string` | Shape kind: "circle", "rectangle", "polygon", "edge", or "chain". |
| `density` | `number` | Mass density (affects dynamic body mass calculation). |
| `friction` | `number` | Surface friction coefficient (0 = ice, 1 = rubber). |
| `restitution` | `number` | Bounciness (0 = no bounce, 1 = perfectly elastic). |
| `sensor` | `boolean` | If true, detects overlaps without generating collision response. |
| — | — | @param ... number Shape-specific size arguments (radius, width/height, or vertex list). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The fixture index on the body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture", fid)
    print("count", world:fixtureCount(body:getId()))
end
```

---

### `LWorld:addFrictionJoint`

Creates a friction joint that applies resistance to relative motion between two bodies.

```lua
-- signature
LWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Anchor X in world coordinates. |
| `anchorY` | `number` | Anchor Y in world coordinates. |
| `maxForce` | `number` | Maximum friction force. |
| `maxTorque` | `number` | Maximum friction torque. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    local jointId = world:addFrictionJoint(ground:getId(), puck:getId(), 200, 400, 100, 50)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addGearJoint`

Creates a gear joint that synchronizes rotation between two bodies at an anchor.

```lua
-- signature
LWorld:addGearJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Gear anchor X. |
| `anchorY` | `number` | Gear anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addMotorJoint`

Creates a motor joint that drives body B toward a target offset from body A using a correction factor.

```lua
-- signature
LWorld:addMotorJoint(bodyA, bodyB, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `factor` | `number` | Correction factor (0Ă˘â‚¬â€ś1), higher = faster convergence. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addMouseJoint`

Creates a mouse joint that pulls a body toward a world target point with spring-like force.

```lua
-- signature
LWorld:addMouseJoint(bodyId, targetX, targetY, maxForce)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body to pull. |
| `targetX` | `number` | Initial target X in world coordinates. |
| `targetY` | `number` | Initial target Y in world coordinates. |
| `maxForce` | `number` | Maximum force applied to reach the target. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    world:setMouseJointTarget(jointId, 400, 150)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addPrismaticJoint`

Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.

```lua
-- signature
LWorld:addPrismaticJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Anchor X in world coordinates. |
| `anchorY` | `number` | Anchor Y in world coordinates. |
| `axisX` | `number` | Slide axis X direction. |
| `axisY` | `number` | Slide axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(rail:getId(), slider:getId(), 300, 300, 1, 0)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addPulleyJoint`

Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.

```lua
-- signature
LWorld:addPulleyJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Shared anchor X. |
| `anchorY` | `number` | Shared anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addRevoluteJoint`

Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.

```lua
-- signature
LWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Anchor X in world coordinates. |
| `anchorY` | `number` | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local pivot = world:newBody(200, 150, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addRopeJoint`

Creates a rope joint limiting the maximum distance between two anchor points on two bodies.

```lua
-- signature
LWorld:addRopeJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, maxLength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorAX` | `number` | Local anchor X on body A. |
| `anchorAY` | `number` | Local anchor Y on body A. |
| `anchorBX` | `number` | Local anchor X on body B. |
| `anchorBY` | `number` | Local anchor Y on body B. |
| `maxLength` | `number` | Maximum allowed distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addWeldJoint`

Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).

```lua
-- signature
LWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID. |
| `bodyB` | `number` | Second body ID. |
| `anchorX` | `number` | Anchor X in world coordinates. |
| `anchorY` | `number` | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addWheelJoint`

Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.

```lua
-- signature
LWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | `number` | First body ID (chassis). |
| `bodyB` | `number` | Second body ID (wheel). |
| `anchorX` | `number` | Anchor X in world coordinates. |
| `anchorY` | `number` | Anchor Y in world coordinates. |
| `axisX` | `number` | Suspension axis X direction. |
| `axisY` | `number` | Suspension axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(car:getId(), wheel:getId(), 200, 230, 0, 1)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end
```

---

### `LWorld:addZone`

Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).

```lua
-- signature
LWorld:addZone(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Zone left X. |
| `y` | `number` | Zone top Y. |
| `w` | `number` | Zone width. |
| `h` | `number` | Zone height. |

**Returns**

| Type | Description |
|------|-------------|
| `LZone` | The zone handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    zone:setPriority(10)
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LWorld:clear`

Removes all bodies and joints from the world, resetting it to an empty state.

```lua
-- signature
LWorld:clear()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    print("before", world:getBodyCount())
    world:clear()
    print("after", world:getBodyCount())
end
```

---

### `LWorld:clearBeginContact`

Removes the begin-contact callback so it is no longer called.

```lua
-- signature
LWorld:clearBeginContact()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    world:setBeginContact(function()
        count = count + 1
    end)
    world:clearBeginContact()
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("count", count)
end
```

---

### `LWorld:clearBodyData`

Removes and releases the Lua data attached to a body.

```lua
-- signature
LWorld:clearBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player" })
    world:clearBodyData(player:getId())
    print("data", world:getBodyData(player:getId()))
end
```

---

### `LWorld:clearBodyOneWay`

Removes the one-way platform behavior from a body, making it block from all directions.

```lua
-- signature
LWorld:clearBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    world:clearBodyOneWay(platform:getId())
    print("normal", world:getBodyOneWay(platform:getId()))
end
```

---

### `LWorld:clearEndContact`

Removes the end-contact callback so it is no longer called.

```lua
-- signature
LWorld:clearEndContact()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    world:setEndContact(function()
        count = count + 1
    end)
    world:clearEndContact()
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("count", count)
end
```

---

### `LWorld:destroyBody`

Removes a body from the world by its ID, along with all attached fixtures and joints.

```lua
-- signature
LWorld:destroyBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    print("before", world:getBodyCount())
    world:destroyBody(body:getId())
    print("after", world:getBodyCount())
end
```

---

### `LWorld:destroyJoint`

Removes a joint from the world, disconnecting the two bodies it linked.

```lua
-- signature
LWorld:destroyJoint(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("before", world:jointCount())
    world:destroyJoint(jid)
    print("after", world:jointCount())
end
```

---

### `LWorld:drawDebug`

Renders a debug visualization of all physics bodies onto a software ImageData target.

```lua
-- signature
LWorld:drawDebug(target, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw debug shapes onto. |
| `r?` | `number` | Red channel (0-255, default 0). |
| `g?` | `number` | Green channel (0-255, default 255). |
| `b?` | `number` | Blue channel (0-255, default 0). |
| `a?` | `number` | Alpha channel (0-255, default 255). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    local img = lurek.image.newImageData(800, 600)
    local ok, err = pcall(function() world:drawDebug(img, 0, 255, 0, 200) end)
    if ok then print("image", img:type()) else print("drawDebug skipped: " .. tostring(err)) end
end
```

---

### `LWorld:fixtureCount`

Returns how many fixtures (colliders) are attached to a body.

```lua
-- signature
LWorld:fixtureCount(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of attached fixtures. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("count", world:fixtureCount(body:getId()))
end
```

---

### `LWorld:getBeginContactEvents`

Returns contact-begin events from the last step (pairs of bodies that started touching).

```lua
-- signature
LWorld:getBeginContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetBeginContactEventsResult` | Array of {bodyA, bodyB} tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    for _ = 1, 180 do
        world:step(1 / 60)
        local events = world:getBeginContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    print("count", count)
end
```

---

### `LWorld:getBodyAtPoint`

Returns the body ID at a specific world point, or nil if no body is there.

```lua
-- signature
LWorld:getBodyAtPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Query point X. |
| `y` | `number` | Query point Y. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Body ID at the point, or nil. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 30, "static")
    local hitId = world:getBodyAtPoint(210, 205)
    local missId = world:getBodyAtPoint(0, 0)
    print("hit", hitId)
    print("miss", missId)
end
```

---

### `LWorld:getBodyCCD`

Returns whether continuous collision detection is enabled on a body.

```lua
-- signature
LWorld:getBodyCCD(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if CCD is enabled. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("ccd", world:getBodyCCD(bullet:getId()))
    print("velocity", bullet:getVelocity())
end
```

---

### `LWorld:getBodyContacts`

Returns all contacts involving a specific body.

```lua
-- signature
LWorld:getBodyContacts(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body to query contacts for. |

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetBodyContactsResult` | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    print("count", #contacts)
    if contacts[1] then
        print("first", contacts[1].bodyA, contacts[1].bodyB)
    end
end
```

---

### `LWorld:getBodyCount`

Returns the total number of active bodies in the world.

```lua
-- signature
LWorld:getBodyCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Body count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    print("body_count", world:getBodyCount())
end
```

---

### `LWorld:getBodyData`

Retrieves the Lua data previously attached to a body, or nil if none was set.

```lua
-- signature
LWorld:getBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | The stored value, or nil if none was set. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local data = world:getBodyData(enemy:getId())
    print("tag", data.tag)
    print("hp", data.hp)
end
```

---

### `LWorld:getBodyIds`

Returns a sequential table of all body IDs currently in the world.

```lua
-- signature
LWorld:getBodyIds()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Body ID numbers. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    print("count", #ids)
    print("first", ids[1])
end
```

---

### `LWorld:getBodyOneWay`

Returns the one-way platform normal for a body, or nil,nil if not set.

```lua
-- signature
LWorld:getBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Normal X, or nil if not a one-way body. |
| `number` | b Normal Y, or nil if not a one-way body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    print("normal", world:getBodyOneWay(platform:getId()))
end
```

---

### `LWorld:getBodyType`

Returns the type name of a body as a string.

```lua
-- signature
LWorld:getBodyType(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    print("type", world:getBodyType(body:getId()))
    print("id", body:getId())
end
```

---

### `LWorld:getCollisionEvents`

Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.

```lua
-- signature
LWorld:getCollisionEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetCollisionEventsResult` | Array of collision event tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getCollisionEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    print("count", count)
end
```

---

### `LWorld:getContacts`

Returns all currently active contact manifolds with normals and touching state.

```lua
-- signature
LWorld:getContacts()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetContactsResult` | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    print("count", #contacts)
    print("ball", ball:getId())
end
```

---

### `LWorld:getEndContactEvents`

Returns contact-end events from the last step (pairs of bodies that stopped touching).

```lua
-- signature
LWorld:getEndContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetEndContactEventsResult` | Array of {bodyA, bodyB} tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    for _ = 1, 300 do
        world:step(1 / 60)
        local events = world:getEndContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    print("count", count)
end
```

---

### `LWorld:getGravity`

Returns the current world gravity vector.

```lua
-- signature
LWorld:getGravity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Gravity X component in world units per second squared. |
| `number` | b Gravity Y component in world units per second squared. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    world:setGravity(10, 800)
    print("updated", world:getGravity())
end
```

---

### `LWorld:getJointBodies`

Returns the two body IDs connected by a joint.

```lua
-- signature
LWorld:getJointBodies(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Body A ID. |
| `number` | b Body B ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("bodies", world:getJointBodies(jid))
end
```

---

### `LWorld:getJointBreakForce`

Returns the break force threshold for a joint.

```lua
-- signature
LWorld:getJointBreakForce(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Break force value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    print("break_force", world:getJointBreakForce(jid))
end
```

---

### `LWorld:getJointIds`

Returns a sequential table of all joint IDs currently in the world.

```lua
-- signature
LWorld:getJointIds()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Joint ID numbers. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    print("count", #ids)
    print("first", ids[1])
end
```

---

### `LWorld:getJointLimits`

Returns the lower and upper limit values for a joint.

```lua
-- signature
LWorld:getJointLimits(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Lower limit. |
| `number` | b Upper limit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("limits", world:getJointLimits(jid))
end
```

---

### `LWorld:getJointMotorSpeed`

Returns the current motor speed setting of a joint.

```lua
-- signature
LWorld:getJointMotorSpeed(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Motor speed value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor_speed", world:getJointMotorSpeed(jid))
end
```

---

### `LWorld:getJointType`

Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").

```lua
-- signature
LWorld:getJointType(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The joint type name. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint_type", world:getJointType(jid))
end
```

---

### `LWorld:getMeter`

Returns the current pixels-per-meter scale.

```lua
-- signature
LWorld:getMeter()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Pixels per meter. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter", world:getMeter())
    print("pixels", world:toPixels(2.0))
end
```

---

### `LWorld:getSolverIterations`

Returns the current number of velocity solver iterations.

```lua
-- signature
LWorld:getSolverIterations()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Iteration count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(10)
    print("solver_iterations", world:getSolverIterations())
end
```

---

### `LWorld:getZoneEvents`

Returns all zone enter/leave events from the last step.

```lua
-- signature
LWorld:getZoneEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `LWorldGetZoneEventsResult` | Array of {zone_id, body_id, kind} tables where kind is "enter" or "leave". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    world:newCircleBody(250, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getZoneEvents()
        count = count + #events
    end
    print("count", count)
end
```

---

### `LWorld:isBodySleeping`

Returns whether a body is currently in the sleeping (inactive) state.

```lua
-- signature
LWorld:isBodySleeping(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the body is sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end
```

---

### `LWorld:jointCount`

Returns the total number of joints in the world.

```lua
-- signature
LWorld:jointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Joint count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint_count", world:jointCount())
end
```

---

### `LWorld:newBodies`

Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.

```lua
-- signature
LWorld:newBodies(specs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `specs` | `table` | Array of tables: {{x, y, w, h, "dynamic"}, ...} or {{x, y, "dynamic"}, ...} (defaults to 16x16). |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Body ID numbers in creation order. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ids = world:newBodies({
        { 15, 50, 12, 12, "dynamic" },
        { 30, 50, 12, 12, "dynamic" },
        { 45, 50, 12, 12, "static" },
    })
    print("created", #ids)
    print("body_count", world:getBodyCount())
end
```

---

### `LWorld:newBody`

Creates a new physics body at the given position with the specified type and dimensions.

```lua
-- signature
LWorld:newBody(x, y, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Initial X position in world coordinates. |
| `y` | `number` | Initial Y position in world coordinates. |
| `bodyType` | `string` | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    world:step(1 / 60)
    print("id", body:getId())
    print("type", body:getType())
    print("position", body:getPosition())
end
```

---

### `LWorld:newChainBody`

Creates a new body with a chain (polyline) collider. Useful for terrain edges.

```lua
-- signature
LWorld:newChainBody(x, y, vertices, closed, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Body X position in world coordinates. |
| `y` | `number` | Body Y position in world coordinates. |
| `vertices` | `table` | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `closed` | `boolean` | If true, connects the last vertex back to the first. |
| `bodyType` | `string` | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static")
    print("position", ground:getPosition())
    print("type", ground:getType())
end
```

---

### `LWorld:newCircleBody`

Creates a new body with a circle collider already attached.

```lua
-- signature
LWorld:newCircleBody(x, y, radius, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Initial X position in world coordinates. |
| `y` | `number` | Initial Y position in world coordinates. |
| `radius` | `number` | Circle radius in world units. |
| `bodyType` | `string` | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    print("position", ball:getPosition())
    print("size", ball:getWidth(), ball:getHeight())
end
```

---

### `LWorld:newEdgeBody`

Creates a new body with an edge (line segment) collider between two local points.

```lua
-- signature
LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Body X position in world coordinates. |
| `y` | `number` | Body Y position in world coordinates. |
| `x1` | `number` | Edge start X relative to body. |
| `y1` | `number` | Edge start Y relative to body. |
| `x2` | `number` | Edge end X relative to body. |
| `y2` | `number` | Edge end Y relative to body. |
| `bodyType` | `string` | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    print("position", wall:getPosition())
    print("type", wall:getType())
end
```

---

### `LWorld:newPolygonBody`

Creates a new body with a convex polygon collider defined by vertex pairs.

```lua
-- signature
LWorld:newPolygonBody(x, y, vertices, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Initial X position in world coordinates. |
| `y` | `number` | Initial Y position in world coordinates. |
| `vertices` | `table` | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `bodyType` | `string` | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| `LBody` | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic")
    print("position", tri:getPosition())
    print("type", tri:getType())
end
```

---

### `LWorld:queryAABB`

Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.

```lua
-- signature
LWorld:queryAABB(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Query rectangle left X. |
| `y` | `number` | Query rectangle top Y. |
| `w` | `number` | Query rectangle width. |
| `h` | `number` | Query rectangle height. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Body ID numbers found in the region. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(150, 120, 10, "dynamic")
    world:newCircleBody(500, 500, 10, "dynamic")
    local found = world:queryAABB(50, 50, 200, 200)
    print("count", #found)
    print("first", found[1])
end
```

---

### `LWorld:raycast`

Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.

```lua
-- signature
LWorld:raycast(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | `number` | Ray origin X. |
| `y1` | `number` | Ray origin Y. |
| `x2` | `number` | Ray end X. |
| `y2` | `number` | Ray end Y. |

**Returns**

| Type | Description |
|------|-------------|
| `LWorldRaycastResult` | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "static")
    local hit = world:raycast(0, 200, 600, 200)
    if hit then
        print("body", hit.bodyId)
        print("point", hit.x, hit.y)
        print("normal", hit.normalX, hit.normalY)
    else
        print("body", nil)
    end
end
```

---

### `LWorld:raycastAll`

Casts a directional ray and returns all bodies hit within max distance as a table of results.

```lua
-- signature
LWorld:raycastAll(x, y, dx, dy, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Ray origin X. |
| `y` | `number` | Ray origin Y. |
| `dx` | `number` | Ray direction X. |
| `dy` | `number` | Ray direction Y. |
| `maxDist` | `number` | Maximum ray travel distance. |

**Returns**

| Type | Description |
|------|-------------|
| `LWorldRaycastAllResult` | Array of hit tables {bodyId, x, y, normalX, normalY, toi}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        world:newCircleBody(100 + i * 80, 200, 10, "static")
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600)
    print("count", #hits)
    if hits[1] then
        print("first", hits[1].bodyId, hits[1].x, hits[1].y)
    end
end
```

---

### `LWorld:raycastClosest`

Casts a directional ray from a point and returns the closest hit within max distance.

```lua
-- signature
LWorld:raycastClosest(x, y, dx, dy, maxDist)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Ray origin X. |
| `y` | `number` | Ray origin Y. |
| `dx` | `number` | Ray direction X (does not need to be normalized). |
| `dy` | `number` | Ray direction Y. |
| `maxDist` | `number` | Maximum ray travel distance. |

**Returns**

| Type | Description |
|------|-------------|
| `LWorldRaycastClosestResult` | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 300, 15, "static")
    local hit = world:raycastClosest(200, 100, 0, 1, 500)
    if hit then
        print("body", hit.bodyId)
        print("point", hit.x, hit.y)
        print("toi", hit.toi)
    else
        print("body", nil)
    end
end
```

---

### `LWorld:setBeginContact`

Registers a callback function invoked whenever two bodies begin touching.

```lua
-- signature
LWorld:setBeginContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | Called with (bodyIdA, bodyIdB) on each new contact. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        print("callback", bodyA, bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("count", contactCount)
end
```

---

### `LWorld:setBodyCCD`

Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.

```lua
-- signature
LWorld:setBodyCCD(id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |
| `enabled` | `boolean` | True to enable CCD. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("ccd", world:getBodyCCD(bullet:getId()))
    print("id", bullet:getId())
end
```

---

### `LWorld:setBodyData`

Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).

```lua
-- signature
LWorld:setBodyData(id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |
| `value` | `any` | Lua value to associate with this body (table, number, string, etc.). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    local data = world:getBodyData(player:getId())
    print("tag", data.tag)
    print("hp", data.hp)
end
```

---

### `LWorld:setBodyOneWay`

Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.

```lua
-- signature
LWorld:setBodyOneWay(id, nx, ny)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |
| `nx` | `number` | One-way normal X (points toward the blocking side). |
| `ny` | `number` | One-way normal Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    print("normal", world:getBodyOneWay(platform:getId()))
end
```

---

### `LWorld:setBodyType`

Changes the type of an existing body (e.g. from "dynamic" to "static").

```lua
-- signature
LWorld:setBodyType(id, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |
| `bodyType` | `string` | New type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:setBodyType(body:getId(), "static")
    print("type", world:getBodyType(body:getId()))
end
```

---

### `LWorld:setEndContact`

Registers a callback function invoked whenever two bodies stop touching.

```lua
-- signature
LWorld:setEndContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | Called with (bodyIdA, bodyIdB) on each ended contact. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
        print("callback", bodyA, bodyB)
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("count", endCount)
end
```

---

### `LWorld:setFixtureFriction`

Updates the friction coefficient of a specific fixture on a body.

```lua
-- signature
LWorld:setFixtureFriction(bodyId, fixtureIndex, friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body ID. |
| `fixtureIndex` | `number` | Zero-based fixture index on the body. |
| `friction` | `number` | New friction value (0Ă˘â‚¬â€ś1 typical range). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end
```

---

### `LWorld:setFixtureRestitution`

Updates the restitution (bounciness) of a specific fixture on a body.

```lua
-- signature
LWorld:setFixtureRestitution(bodyId, fixtureIndex, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body ID. |
| `fixtureIndex` | `number` | Zero-based fixture index on the body. |
| `restitution` | `number` | New restitution value (0 = no bounce, 1 = full bounce). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(body:getId(), fixture, 0.9)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end
```

---

### `LWorld:setFixtureSensor`

Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).

```lua
-- signature
LWorld:setFixtureSensor(bodyId, fixtureIndex, sensor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | `number` | The body ID. |
| `fixtureIndex` | `number` | Zero-based fixture index on the body. |
| `sensor` | `boolean` | True to make it a sensor, false for solid collision. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(body:getId(), fixture, true)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end
```

---

### `LWorld:setGravity`

Sets the world gravity vector. Affects all dynamic bodies.

```lua
-- signature
LWorld:setGravity(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | `number` | Horizontal gravity component. |
| `gy` | `number` | Vertical gravity component (positive = down in screen space). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 200)
    world:setGravity(25, 600)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    print("body_count", world:getBodyCount())
end
```

---

### `LWorld:setJointBreakForce`

Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.

```lua
-- signature
LWorld:setJointBreakForce(jointId, force)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |
| `force` | `number` | Break threshold force (use math.huge for unbreakable). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    print("break_force", world:getJointBreakForce(jid))
end
```

---

### `LWorld:setJointLimits`

Sets the lower and upper bounds for a joint's limited range of motion.

```lua
-- signature
LWorld:setJointLimits(jointId, lower, upper)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |
| `lower` | `number` | Lower limit (radians or meters depending on joint type). |
| `upper` | `number` | Upper limit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("limits", world:getJointLimits(jid))
end
```

---

### `LWorld:setJointLimitsEnabled`

Enables or disables angular/linear limits on a joint.

```lua
-- signature
LWorld:setJointLimitsEnabled(jointId, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |
| `enabled` | `boolean` | True to enforce limits, false to allow free movement. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    print("limits", world:getJointLimits(jid))
end
```

---

### `LWorld:setJointMotorSpeed`

Sets the motor speed on a motorized joint (revolute or prismatic).

```lua
-- signature
LWorld:setJointMotorSpeed(jointId, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The joint ID. |
| `speed` | `number` | Desired motor speed (radians/sec for revolute, meters/sec for prismatic). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor_speed", world:getJointMotorSpeed(jid))
end
```

---

### `LWorld:setMeter`

Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.

```lua
-- signature
LWorld:setMeter(ppm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ppm` | `number` | Pixels per meter (e.g. 64 means 64 px = 1 meter in physics). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter", world:getMeter())
    print("physics", world:toPhysics(128))
end
```

---

### `LWorld:setMouseJointTarget`

Moves the target position of a mouse joint, causing the attached body to follow.

```lua
-- signature
LWorld:setMouseJointTarget(jointId, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | `number` | The mouse joint ID. |
| `x` | `number` | New target X in world coordinates. |
| `y` | `number` | New target Y in world coordinates. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    print("joint", jid)
    print("type", world:getJointType(jid))
end
```

---

### `LWorld:setSolverIterations`

Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.

```lua
-- signature
LWorld:setSolverIterations(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of iterations (default is typically 4Ă˘â‚¬â€ś8). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver_iterations", world:getSolverIterations())
end
```

---

### `LWorld:sleepBody`

Forces a body into the sleeping state, pausing its simulation until disturbed.

```lua
-- signature
LWorld:sleepBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end
```

---

### `LWorld:step`

Advances the physics simulation by a time delta and fires any registered contact callbacks.

```lua
-- signature
LWorld:step(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Time step in seconds (e.g. 1/60 for 60 FPS). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 12, "dynamic")
    world:step(1 / 60)
    print("position", body:getPosition())
    print("velocity", body:getVelocity())
end
```

---

### `LWorld:stepFixed`

Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.

```lua
-- signature
LWorld:stepFixed(accumulator, stepDt, maxSteps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `accumulator` | `number` | Accumulated time since last frame (seconds). |
| `stepDt` | `number` | Fixed step size (e.g. 1/60). |
| `maxSteps` | `number` | Maximum sub-steps per call to prevent spiral of death. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Remaining unstepped time to carry into next frame. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local remainder = world:stepFixed(0.025, 1 / 60, 4)
    print("remainder", remainder)
    print("iterations", world:getSolverIterations())
end
```

---

### `LWorld:toPhysics`

Converts a pixel measurement to physics-world meters using the current meter scale.

```lua
-- signature
LWorld:toPhysics(px)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | `number` | Value in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Equivalent value in physics meters. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meters", world:toPhysics(96))
    print("pixels", world:toPixels(1.5))
end
```

---

### `LWorld:toPixels`

Converts a physics-world meter measurement to pixels using the current meter scale.

```lua
-- signature
LWorld:toPixels(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | `number` | Value in physics meters. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Equivalent value in pixels. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("pixels", world:toPixels(2.5))
    print("meters", world:toPhysics(160))
end
```

---

### `LWorld:type`

Returns the type name of this object ("LWorld").

```lua
-- signature
LWorld:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LWorld". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    print("type", world:type())
    print("type_of", world:typeOf("LWorld"))
end
```

---

### `LWorld:typeOf`

Checks if this object is of a given type name. Supports inheritance (always matches "Object").

```lua
-- signature
LWorld:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    print("type_of", world:typeOf("LWorld"), world:typeOf("LObject"))
    print("type", world:type())
end
```

---

### `LWorld:wakeUpBody`

Forces a sleeping body to wake up and participate in simulation again.

```lua
-- signature
LWorld:wakeUpBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    world:wakeUpBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end
```

---

## LZone

### `LZone:destroy`

Removes this zone from the world. Bodies will no longer be affected by it.

```lua
-- signature
LZone:destroy()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(0, 0, 100, 100)
    print("zone_id", zone:getId())
    zone:destroy()
    print("events", #world:getZoneEvents())
end
```

---

### `LZone:getId`

Returns the unique ID of this zone. This method is available to Lua scripts.

```lua
-- signature
LZone:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zone ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LZone:setAngularDampingOverride`

Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.

```lua
-- signature
LZone:setAngularDampingOverride(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | `number` | Damping override, or nil to clear. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setAngularDampingOverride(2.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setAngularVelocity(5)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("angular_velocity", diver:getAngularVelocity())
    print("angle", diver:getAngle())
end
```

---

### `LZone:setCircle`

Changes this zone's shape to a circle (overrides the initial rectangle).

```lua
-- signature
LZone:setCircle(cx, cy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Center X. |
| `cy` | `number` | Center Y. |
| `radius` | `number` | Circle radius. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LZone:setEnabled`

Enables or disables this zone. Disabled zones have no effect on bodies.

```lua
-- signature
LZone:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to enable, false to disable. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LZone:setGravityDirectional`

Sets the zone to apply a constant directional gravity to bodies inside.

```lua
-- signature
LZone:setGravityDirectional(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | `number` | Gravity X component. |
| `gy` | `number` | Gravity Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end
```

---

### `LZone:setGravityPoint`

Sets the zone to attract bodies toward a center point with a given strength.

```lua
-- signature
LZone:setGravityPoint(cx, cy, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Attractor center X. |
| `cy` | `number` | Attractor center Y. |
| `strength` | `number` | Pull force magnitude. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(450, 220, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end
```

---

### `LZone:setGravityRepulsor`

Sets the zone to push bodies away from a center point with a given strength.

```lua
-- signature
LZone:setGravityRepulsor(cx, cy, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | `number` | Repulsor center X. |
| `cy` | `number` | Repulsor center Y. |
| `strength` | `number` | Push force magnitude. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local ball = world:newCircleBody(240, 240, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end
```

---

### `LZone:setGravityZero`

Sets the zone to cancel all gravity for bodies inside (zero-G area).

```lua
-- signature
LZone:setGravityZero()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end
```

---

### `LZone:setLayerMask`

Sets a bitmask controlling which body layers this zone affects.

```lua
-- signature
LZone:setLayerMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | `number` | Layer bitmask (bitwise AND with body layer must be nonzero). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setLayerMask(0xFF)
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LZone:setLinearDampingOverride`

Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.

```lua
-- signature
LZone:setLinearDampingOverride(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | `number` | Damping override, or nil to clear. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("velocity", diver:getVelocity())
    print("position", diver:getPosition())
end
```

---

### `LZone:setPriority`

Sets the priority of this zone. Higher-priority zones take precedence when overlapping.

```lua
-- signature
LZone:setPriority(priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `priority` | `number` | Integer priority value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(1)
    print("zone_id", zone:getId())
    print("type", zone:type())
end
```

---

### `LZone:type`

Returns the type name of this object ("LZone").

```lua
-- signature
LZone:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "LZone". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("type", zone:type())
    print("type_of", zone:typeOf("LZone"))
end
```

---

### `LZone:typeOf`

Checks if this object is of a given type name.

```lua
-- signature
LZone:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("type_of", zone:typeOf("LZone"), zone:typeOf("LObject"))
    print("type", zone:type())
end
```

---
