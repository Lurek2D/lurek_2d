# Physics

## Summary

- The `physics` module is the engine's 2D simulation authority for users who want motion, contact, shapes, joints, and collision queries to live inside one consistent world model.
- Bodies, colliders, forces, terrain, joints, sensors, and collision layers all belong to the same simulation step, which keeps movement and contact rules coherent across the engine.
- The module supports dynamic, static, kinematic, and sensor-style roles so projects can mix actors, level geometry, triggers, platforms, and detection-only regions inside one physical space without switching subsystems.
- Practical physics also depends on querying the world, not only advancing it. Raycasts, overlap checks, sweep-style tests, and contact inspection let gameplay ask what was hit, what overlaps, and why motion changed.
- Shape support, terrain integration, and joints give the system expressive range for characters, bullets, walls, pickups, hazards, linked mechanisms, and authored environment collision.
- Contact data is one of the main user-facing outputs because systems often need normals, hit points, and begin or end state changes to react meaningfully.
- That query surface is a major part of the module's identity. Many gameplay features care less about rigid-body theory than about dependable answers to questions such as where movement will stop, whether a region is occupied, what a sensor can currently detect, or which body pair produced a specific contact event.
- The module therefore acts as both simulator and spatial authority. It advances bodies through time, but it also explains the world back to scripts in terms of overlaps, hits, filters, material response, joints, and collision-layer policy.
- Terrain support matters because a large share of game physics is really about how actors relate to authored space. Ground, ramps, tile-derived obstacles, one-way behavior, ledges, and sensor volumes all need to participate in the same contact model or movement quickly becomes inconsistent.
- Joints and constraints extend the feature beyond isolated bodies into coupled systems such as hinges, chains, levers, suspended loads, doors, and puzzle machinery. Without that layer, several gameplay designs would need bespoke approximations instead of sharing engine-owned physical semantics.
- Filtering rules are equally important because not every shape should collide, trigger, block, or report in the same way. Keeping collision layers and response policy near world state lets projects express interaction rules explicitly rather than hiding them in scattered caller-side checks.
- Debug visualization is not just a convenience but a necessary part of the contract because collision tuning mistakes are difficult to reason about from code alone. Seeing shapes, sensors, normals, joints, and query paths turns the simulation into something inspectable instead of opaque.
- This makes `physics` especially important for grounded locomotion, projectile travel, hazard interaction, puzzle systems, traversal mechanics, and any design where contact semantics are part of gameplay rather than an incidental backend.
- The shared step loop gives other systems one trusted spatial authority for grounded movement, projectiles, puzzle machinery, and hazards instead of several drifting approximations.
- That authority is what lets gameplay, tools, and effects ask the same world-state questions without maintaining parallel collision logic.
- Other systems consume the results, but `physics` owns the source of truth for what counts as solid, colliding, constrained, or detectable in 2D space.

## Functions

### `lurek.physics.attachShape`

Attaches a previously created shape to a body, using the shape's stored material properties.

```lua
lurek.physics.attachShape(body, shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | [LBody](#lbody) | The target body. |
| `shape` | [LPhysicsShape](#lphysicsshape) | The shape to attach. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
    example_print_log("position", body:getPosition())
end
```

---

### `lurek.physics.debugDraw`

Enables or disables automatic physics debug overlay rendering for the next frame.

```lua
lurek.physics.debugDraw(enable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enable` | boolean | True to show debug shapes. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    lurek.physics.drawDebugGpu(world, { lineWidth = 2 })
    example_print_log("body_count", world:getBodyCount())
end
```

---

### `lurek.physics.destroyWorld`

No-op placeholder for API parity. Worlds are freed when no longer referenced.

```lua
lurek.physics.destroyWorld(world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    example_print_log("before", world:getBodyCount())
    lurek.physics.destroyWorld(world)
    example_print_log("after", world:getBodyCount())
end
```

---

### `lurek.physics.drawDebugGpu`

Queues a GPU-rendered physics debug visualization using the world's current body state.

```lua
lurek.physics.drawDebugGpu(world, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world to visualize. |
| `config?` | table | Optional config: {bodyColor, staticColor, sleepColor, sensorColor, lineWidth}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    world:newBody(120, 200, "static")
    world:newCircleBody(120, 120, 10, "dynamic")
    lurek.physics.drawDebugGpu(world, {})
    world:step(1 / 60)
    physics_log("gpu debug scene bodies=" .. world:getBodyCount())
    physics_log("world type=" .. world:type())
end
```

---

### `lurek.physics.getBody`

Returns position and velocity of a body (free-function variant for quick queries).

```lua
lurek.physics.getBody(world, body)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world. |
| `body` | [LBody](#lbody) | The body to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | X position. |
| number | Y position. |
| number | Velocity X. |
| number | Velocity Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    body:setVelocity(10, 5)
    world:step(1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    physics_log("free-function body pos=" .. x .. "," .. y)
    physics_log("free-function velocity=" .. vx .. "," .. vy)
end
```

---

### `lurek.physics.getCollisions`

Returns all collision events from the last world step as {body_a, body_b} pairs.

```lua
lurek.physics.getCollisions(world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world to query. |

**Returns**

| Type | Description |
|------|-------------|
| LPhysicsGetCollisionsResult | Array of collision event tables. |

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
    example_print_log("count", #collisions)
    if collisions[1] then
        example_print_log("first", collisions[1].body_a, collisions[1].body_b)
    end
end
```

---

### `lurek.physics.isSleepingAllowed`

Checks if sleeping is allowed on a body (free-function variant).

```lua
lurek.physics.isSleepingAllowed(world, body)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world. |
| `body` | [LBody](#lbody) | The body. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sleeping is allowed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    example_print_log("allowed", lurek.physics.isSleepingAllowed(world, body))
    lurek.physics.setSleepingAllowed(world, body, false)
    example_print_log("allowed_after", lurek.physics.isSleepingAllowed(world, body))
end
```

---

### `lurek.physics.newBody`

Creates a new body in a world (free-function variant).

```lua
lurek.physics.newBody(world, x, y, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The target world. |
| `x` | number | Initial X position. |
| `y` | number | Initial Y position. |
| `bodyType` | string | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = lurek.physics.newBody(world, 50, 50, "static")
    local checkpoint = lurek.physics.newBody(world, 80, 50, "sensor")
    world:step(1 / 60)
    physics_log("spawned wall id=" .. body:getId() .. " type=" .. body:getType())
    physics_log("checkpoint type=" .. checkpoint:getType() .. " bodies=" .. world:getBodyCount())
end
```

---

### `lurek.physics.newChainShape`

Creates a chain (polyline) collision shape. Useful for terrain outlines.

```lua
lurek.physics.newChainShape(closed, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `closed` | boolean | If true, connects last vertex to first. |
| — | — | @param ... number Alternating x,y coordinates (minimum 2 pairs = 4 numbers). |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | The shape object. |

**Example**

```lua
do
    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100)
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100)
    local minX, minY, maxX, maxY = chain:getBoundingBox()
    local loopMinX, loopMinY, loopMaxX, loopMaxY = loop:getBoundingBox()
    physics_log("spline type=" .. chain:getType() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    physics_log("pit loop type=" .. loop:getType() .. " bounds=" .. loopMinX .. "," .. loopMinY .. " -> " .. loopMaxX .. "," .. loopMaxY)
end
```

---

### `lurek.physics.newCircleShape`

Creates a circle collision shape with the given radius.

```lua
lurek.physics.newCircleShape(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | The shape object. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(16)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    example_print_log("type", circle:getType())
    example_print_log("radius", circle:getRadius())
    example_print_log("bounds", minX, minY, maxX, maxY)
end
```

---

### `lurek.physics.newEdgeShape`

Creates an edge (line segment) collision shape between two local points.

```lua
lurek.physics.newEdgeShape(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start X. |
| `y1` | number | Start Y. |
| `x2` | number | End X. |
| `y2` | number | End Y. |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | The shape object. |

**Example**

```lua
do
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    local minX, minY, maxX, maxY = edge:getBoundingBox()
    edge:setFriction(0.6)
    edge:setSensor(false)
    physics_log("ledge edge type=" .. edge:getType())
    physics_log("ledge bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

### `lurek.physics.newPolygonShape`

Creates a convex polygon collision shape from vertex coordinate pairs.

```lua
lurek.physics.newPolygonShape(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Alternating x,y coordinates (minimum 3 pairs = 6 numbers). |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | The shape object. |

**Example**

```lua
do
    local triangle = lurek.physics.newPolygonShape(0, -20, -15, 15, 15, 15)
    local minX, minY, maxX, maxY = triangle:getBoundingBox()
    triangle:setDensity(1.2)
    triangle:setRestitution(0.1)
    physics_log("roof wedge type=" .. triangle:getType())
    physics_log("roof bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

### `lurek.physics.newRectangleShape`

Creates a rectangle collision shape with the given dimensions.

```lua
lurek.physics.newRectangleShape(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width. |
| `h` | number | Height. |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | The shape object. |

**Example**

```lua
do
    local rect = lurek.physics.newRectangleShape(64, 32)
    local minX, minY, maxX, maxY = rect:getBoundingBox()
    rect:setFriction(0.8)
    rect:setDensity(2.0)
    physics_log("crate collider type=" .. rect:getType())
    physics_log("crate bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

### `lurek.physics.newTerrain`

Creates a destructible terrain grid linked to a physics world for automatic collider generation.

```lua
lurek.physics.newTerrain(width, height, cellSize, world)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |
| `cellSize` | number | World-space size of each cell. |
| `world` | [LWorld](#lworld) | The physics world that will own the generated colliders. |

**Returns**

| Type | Description |
|------|-------------|
| [LTerrain](#lterrain) | The terrain object. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 128, 40, false)
    terrain:flush()
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end
```

---

### `lurek.physics.newWorld`

Creates a new physics world with the given gravity vector.

```lua
lurek.physics.newWorld(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Gravity X component. |
| `gy` | number | Gravity Y component (positive = down). |

**Returns**

| Type | Description |
|------|-------------|
| [LWorld](#lworld) | The new physics world. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(320, 520, "static")
    local crate = world:newCircleBody(320, 120, 14, "dynamic")
    local gx, gy = world:getGravity()
    world:step(1 / 60)
    physics_log("training room gravity=" .. gx .. "," .. gy)
    physics_log("floor=" .. floor:getType() .. " crate_y=" .. select(2, crate:getPosition()))
end
```

---

### `lurek.physics.setBodyVelocity`

Sets a body's velocity (free-function variant).

```lua
lurek.physics.setBodyVelocity(world, body, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world. |
| `body` | [LBody](#lbody) | The body. |
| `vx` | number | Velocity X. |
| `vy` | number | Velocity Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    physics_log("dash velocity=" .. vx .. "," .. vy)
    physics_log("dash position=" .. body:getX() .. "," .. body:getY())
end
```

---

### `lurek.physics.setSleepingAllowed`

Sets whether a body is allowed to sleep (free-function variant).

```lua
lurek.physics.setSleepingAllowed(world, body, allowed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world. |
| `body` | [LBody](#lbody) | The body. |
| `allowed` | boolean | True to allow sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    world:step(1 / 60)
    local allowed = body:isSleepingAllowed()
    local valid = body:isValid()
    physics_log("always-awake enemy allowed=" .. tostring(allowed))
    physics_log("body still valid=" .. tostring(valid))
end
```

---

### `lurek.physics.step`

Steps a physics world forward by dt seconds (free-function variant).

```lua
lurek.physics.step(world, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The world to step. |
| `dt` | number | Time step in seconds. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local floor = world:newBody(100, 240, "static")
    body:setVelocity(20, -30)
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    physics_log("module step pos=" .. x .. "," .. y)
    physics_log("velocity=" .. vx .. "," .. vy .. " floor=" .. floor:getType())
end
```

---

### `lurek.physics.testAABB`

Tests whether two axis-aligned bounding boxes overlap. Lightweight collision check without physics world.

```lua
lurek.physics.testAABB(ax, ay, aw, ah, bx, by, bw, bh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | First rect X. |
| `ay` | number | First rect Y. |
| `aw` | number | First rect width. |
| `ah` | number | First rect height. |
| `bx` | number | Second rect X. |
| `by` | number | Second rect Y. |
| `bw` | number | Second rect width. |
| `bh` | number | Second rect height. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the rectangles overlap. |

**Example**

```lua
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    local miss = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    local playerInsideHazard = lurek.physics.testAABB(30, 30, 16, 16, 20, 20, 40, 40)
    local pickupFarAway = lurek.physics.testAABB(30, 30, 16, 16, 120, 120, 8, 8)
    physics_log("hazard overlap=" .. tostring(overlap) .. " player overlap=" .. tostring(playerInsideHazard))
    physics_log("miss=" .. tostring(miss) .. " pickup far=" .. tostring(pickupFarAway))
end
```

---

### `lurek.physics.testCircleAABB`

Tests whether a circle overlaps an AABB. Lightweight check without physics world.

```lua
lurek.physics.testCircleAABB(cx, cy, cr, ax, ay, aw, ah)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center X. |
| `cy` | number | Circle center Y. |
| `cr` | number | Circle radius. |
| `ax` | number | Rect X. |
| `ay` | number | Rect Y. |
| `aw` | number | Rect width. |
| `ah` | number | Rect height. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if circle and AABB overlap. |

**Example**

```lua
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    local explosionHitsDoor = lurek.physics.testCircleAABB(160, 96, 24, 150, 80, 40, 60)
    local explosionMissesTower = lurek.physics.testCircleAABB(160, 96, 24, 260, 80, 40, 60)
    physics_log("door splash hit=" .. tostring(hit) .. " explosion door=" .. tostring(explosionHitsDoor))
    physics_log("miss=" .. tostring(miss) .. " tower miss=" .. tostring(explosionMissesTower))
end
```

---

### `lurek.physics.testCircles`

Tests whether two circles overlap. Lightweight collision check without physics world.

```lua
lurek.physics.testCircles(ax, ay, ar, bx, by, br)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | First circle center X. |
| `ay` | number | First circle center Y. |
| `ar` | number | First circle radius. |
| `bx` | number | Second circle center X. |
| `by` | number | Second circle center Y. |
| `br` | number | Second circle radius. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the circles overlap. |

**Example**

```lua
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    local bombHitsShield = lurek.physics.testCircles(200, 200, 18, 214, 200, 12)
    local bombMissesPlayer = lurek.physics.testCircles(200, 200, 18, 260, 200, 12)
    physics_log("touching=" .. tostring(touching) .. " shield hit=" .. tostring(bombHitsShield))
    physics_log("apart=" .. tostring(apart) .. " player miss=" .. tostring(bombMissesPlayer))
end
```

---

### `lurek.physics.testPoint`

Tests whether a point lies inside an AABB. Lightweight check without physics world.

```lua
lurek.physics.testPoint(px, py, ax, ay, aw, ah)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Point X. |
| `py` | number | Point Y. |
| `ax` | number | Rect X. |
| `ay` | number | Rect Y. |
| `aw` | number | Rect width. |
| `ah` | number | Rect height. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the point is inside. |

**Example**

```lua
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    local buttonHover = lurek.physics.testPoint(42, 18, 32, 8, 24, 24)
    local missHover = lurek.physics.testPoint(80, 18, 32, 8, 24, 24)
    physics_log("inside tile=" .. tostring(inside) .. " ui hover=" .. tostring(buttonHover))
    physics_log("outside tile=" .. tostring(outside) .. " hover miss=" .. tostring(missHover))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LBody](#lbody)
- [LPhysicsShape](#lphysicsshape)
- [LTerrain](#lterrain)
- [LWorld](#lworld)
- [LZone](#lzone)

## LBody

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBody:applyAngularImpulse`

Applies an instantaneous angular impulse (spin) to the body.

```lua
LBody:applyAngularImpulse(impulse)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `impulse` | number | Angular impulse value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyAngularImpulse(5.0)
    world:step(1 / 60)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end
```

---

#### `LBody:applyForce`

Applies a continuous force to the body's center of mass (accumulates over the step).

```lua
LBody:applyForce(fx, fy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | Force X component. |
| `fy` | number | Force Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("position", body:getPosition())
end
```

---

#### `LBody:applyForceAtPoint`

Applies a force at a specific world point, generating both linear and angular acceleration.

```lua
LBody:applyForceAtPoint(fx, fy, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | Force X component. |
| `fy` | number | Force Y component. |
| `px` | number | Application point X in world coordinates. |
| `py` | number | Application point Y in world coordinates. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForceAtPoint(0, -50, 210, 200)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("angular_velocity", body:getAngularVelocity())
end
```

---

#### `LBody:applyImpulse`

Applies an instantaneous linear impulse to the body's center of mass.

```lua
LBody:applyImpulse(ix, iy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ix` | number | Impulse X component. |
| `iy` | number | Impulse Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyImpulse(0, -200)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("position", body:getPosition())
end
```

---

#### `LBody:applyTorque`

Applies a rotational torque to the body.

```lua
LBody:applyTorque(torque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `torque` | number | Torque value (positive = counter-clockwise). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyTorque(10.0)
    world:step(1 / 60)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end
```

---

#### `LBody:destroy`

Destroys this body, removing it from the world along with all fixtures and joints.

```lua
LBody:destroy()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    example_print_log("before", world:getBodyCount())
    temp:destroy()
    example_print_log("after", world:getBodyCount())
end
```

---

#### `LBody:getAngle`

Returns the body's rotation angle in radians.

```lua
LBody:getAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 6)
    example_print_log("angle", body:getAngle())
    example_print_log("position", body:getPosition())
end
```

---

#### `LBody:getAngularDamping`

Returns the angular damping factor (rotational decay rate).

```lua
LBody:getAngularDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angular damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.9)
    example_print_log("angular_damping", body:getAngularDamping())
    example_print_log("linear_damping", body:getLinearDamping())
end
```

---

#### `LBody:getAngularVelocity`

Returns the body's angular (rotational) velocity.

```lua
LBody:getAngularVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angular velocity in radians per second. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(1.25)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end
```

---

#### `LBody:getFriction`

Returns the body's friction coefficient.

```lua
LBody:getFriction()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Friction value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.25)
    example_print_log("friction", body:getFriction())
    example_print_log("restitution", body:getRestitution())
end
```

---

#### `LBody:getGravityScale`

Returns the gravity scale multiplier for this body (1.0 = normal gravity).

```lua
LBody:getGravityScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Gravity scale. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setGravityScale(-1.0)
    example_print_log("gravity_scale", body:getGravityScale())
    example_print_log("type", body:getType())
end
```

---

#### `LBody:getHeight`

Returns the body's bounding height (from its primary shape).

```lua
LBody:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in world units. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(32, 48)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    physics_log("character height=" .. body:getHeight() .. " width=" .. body:getWidth())
    physics_log("spawn pos=" .. select(1, body:getPosition()) .. "," .. select(2, body:getPosition()))
end
```

---

#### `LBody:getId`

Returns the unique numeric ID of this body within the world.

```lua
LBody:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    world:setBodyData(body:getId(), { kind = "spawn_marker" })
    local data = world:getBodyData(body:getId())
    world:step(1 / 60)
    physics_log("body id=" .. body:getId() .. " kind=" .. data.kind)
    physics_log("spawn x=" .. body:getX() .. " y=" .. body:getY())
end
```

---

#### `LBody:getLayer`

Returns the body's collision layer bitmask.

```lua
LBody:getLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(4)
    example_print_log("layer", body:getLayer())
    example_print_log("type", body:getType())
end
```

---

#### `LBody:getLinearDamping`

Returns the linear damping factor (velocity decay rate, like air resistance).

```lua
LBody:getLinearDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.75)
    example_print_log("linear_damping", body:getLinearDamping())
    example_print_log("velocity", body:getVelocity())
end
```

---

#### `LBody:getMask`

Returns the body's collision mask (which layers this body can collide with).

```lua
LBody:getMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mask bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(7)
    example_print_log("mask", body:getMask())
    example_print_log("id", body:getId())
end
```

---

#### `LBody:getMass`

Returns the body's total mass (computed from density and fixture areas).

```lua
LBody:getMass()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mass in kilograms. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    example_print_log("mass", body:getMass())
    example_print_log("friction", body:getFriction())
    example_print_log("restitution", body:getRestitution())
end
```

---

#### `LBody:getPosition`

Returns the current world-space position of this body.

```lua
LBody:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(14, -8)
    world:step(1 / 60)
    local x, y = body:getPosition()
    physics_log("patrol body id=" .. body:getId())
    physics_log("current position=" .. x .. "," .. y)
end
```

---

#### `LBody:getRestitution`

Returns the body's restitution (bounciness) value.

```lua
LBody:getRestitution()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Restitution (0 = no bounce, 1 = perfectly elastic). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.15)
    example_print_log("restitution", body:getRestitution())
    example_print_log("friction", body:getFriction())
end
```

---

#### `LBody:getType`

Returns the body's type as a string.

```lua
LBody:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "sensor")
    body:setLayer(8)
    world:setBodyData(body:getId(), { role = "checkpoint" })
    local data = world:getBodyData(body:getId())
    physics_log("checkpoint type=" .. body:getType() .. " id=" .. body:getId())
    physics_log("layer=" .. body:getLayer() .. " role=" .. data.role)
end
```

---

#### `LBody:getVelocity`

Returns the body's current linear velocity.

```lua
LBody:getVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Velocity X component. |
| number | Velocity Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(25, -50)
    example_print_log("velocity", body:getVelocity())
    example_print_log("type", body:getType())
end
```

---

#### `LBody:getWidth`

Returns the body's bounding width (from its primary shape).

```lua
LBody:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in world units. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(48, 20)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    physics_log("bridge plank width=" .. body:getWidth())
    physics_log("bridge plank height=" .. body:getHeight())
end
```

---

#### `LBody:getX`

Returns only the X component of the body's position.

```lua
LBody:getX()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(12, 0)
    world:step(1 / 60)
    local x = body:getX()
    local y = body:getY()
    physics_log("spawn marker x=" .. x)
    physics_log("paired y=" .. y)
end
```

---

#### `LBody:getY`

Returns only the Y component of the body's position.

```lua
LBody:getY()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Y coordinate. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(0, -10)
    world:step(1 / 60)
    local y = body:getY()
    local x = body:getX()
    physics_log("spawn marker y=" .. y)
    physics_log("paired x=" .. x)
end
```

---

#### `LBody:isBullet`

Returns whether continuous collision detection (bullet mode) is enabled for this body.

```lua
LBody:isBullet()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if CCD is active. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    example_print_log("is_bullet", bullet:isBullet())
    example_print_log("position", bullet:getPosition())
end
```

---

#### `LBody:isFixedRotation`

Returns whether the body's rotation is locked.

```lua
LBody:isFixedRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if rotation is fixed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    example_print_log("fixed_rotation", player:isFixedRotation())
    example_print_log("type", player:getType())
end
```

---

#### `LBody:isSleeping`

Returns whether this body is currently in the sleeping (inactive) state.

```lua
LBody:isSleeping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    example_print_log("sleeping", body:isSleeping())
    example_print_log("id", body:getId())
end
```

---

#### `LBody:isSleepingAllowed`

Returns whether the body is allowed to enter sleep state when at rest.

```lua
LBody:isSleepingAllowed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sleeping is allowed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    example_print_log("allowed", body:isSleepingAllowed())
    example_print_log("type", body:getType())
end
```

---

#### `LBody:isValid`

Returns whether this body handle still points to an active body.

```lua
LBody:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body has not been destroyed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    example_print_log("valid", temp:isValid())
    temp:destroy()
    example_print_log("valid_after_destroy", temp:isValid())
end
```

---

#### `LBody:setAngle`

Sets the body's rotation angle directly.

```lua
LBody:setAngle(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | New angle in radians. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    example_print_log("angle", body:getAngle())
    example_print_log("angular_velocity", body:getAngularVelocity())
end
```

---

#### `LBody:setAngularDamping`

Sets the angular damping factor (higher = rotation decays faster).

```lua
LBody:setAngularDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Angular damping value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.3)
    example_print_log("angular_damping", body:getAngularDamping())
    example_print_log("angle", body:getAngle())
end
```

---

#### `LBody:setAngularVelocity`

Sets the body's angular velocity directly.

```lua
LBody:setAngularVelocity(omega)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `omega` | number | Angular velocity in radians per second. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(2.0)
    example_print_log("angular_velocity", body:getAngularVelocity())
    world:step(1 / 60)
    example_print_log("angle", body:getAngle())
end
```

---

#### `LBody:setBullet`

Enables or disables continuous collision detection to prevent fast-moving tunneling.

```lua
LBody:setBullet(bullet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bullet` | boolean | True to enable CCD. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    example_print_log("is_bullet", bullet:isBullet())
    example_print_log("type", bullet:getType())
end
```

---

#### `LBody:setFixedRotation`

Locks or unlocks the body's rotation. Useful for player characters.

```lua
LBody:setFixedRotation(fixed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fixed` | boolean | True to prevent rotation. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    example_print_log("fixed_rotation", player:isFixedRotation())
    example_print_log("angle", player:getAngle())
end
```

---

#### `LBody:setFriction`

Sets the body's friction coefficient.

```lua
LBody:setFriction(friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `friction` | number | New friction value (0 = ice, 1 = rubber). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.8)
    example_print_log("friction", body:getFriction())
    example_print_log("mass", body:getMass())
end
```

---

#### `LBody:setGravityScale`

Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).

```lua
LBody:setGravityScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Gravity scale factor. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    floaty:setGravityScale(0.2)
    example_print_log("normal", normal:getGravityScale())
    example_print_log("floaty", floaty:getGravityScale())
end
```

---

#### `LBody:setLayer`

Sets the body's collision layer bitmask (which layers this body belongs to).

```lua
LBody:setLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(2)
    example_print_log("layer", body:getLayer())
    example_print_log("mask", body:getMask())
end
```

---

#### `LBody:setLinearDamping`

Sets the linear damping factor (higher = more velocity decay per step).

```lua
LBody:setLinearDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Damping value (0 = no damping). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    example_print_log("linear_damping", body:getLinearDamping())
    example_print_log("angular_damping", body:getAngularDamping())
end
```

---

#### `LBody:setMask`

Sets the body's collision mask (which layers this body can collide with).

```lua
LBody:setMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Collision mask bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(3)
    example_print_log("mask", body:getMask())
    example_print_log("layer", body:getLayer())
end
```

---

#### `LBody:setMass`

Overrides the body's mass directly.

```lua
LBody:setMass(mass)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mass` | number | New mass value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(7.5)
    example_print_log("mass", body:getMass())
    example_print_log("type", body:getType())
end
```

---

#### `LBody:setPosition`

Teleports the body to a new world-space position (does not apply physics forces).

```lua
LBody:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | New X position. |
| `y` | number | New Y position. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    example_print_log("position", body:getPosition())
    example_print_log("velocity", body:getVelocity())
end
```

---

#### `LBody:setRestitution`

Sets the body's restitution (bounciness) value.

```lua
LBody:setRestitution(restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `restitution` | number | New restitution (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    example_print_log("restitution", body:getRestitution())
    example_print_log("mass", body:getMass())
end
```

---

#### `LBody:setSleepingAllowed`

Controls whether the body can enter sleep state. Disable for bodies that must stay active.

```lua
LBody:setSleepingAllowed(allowed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `allowed` | boolean | True to allow sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(false)
    example_print_log("allowed", body:isSleepingAllowed())
    example_print_log("sleeping", body:isSleeping())
end
```

---

#### `LBody:setType`

Changes the body's type at runtime.

```lua
LBody:setType(bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyType` | string | New type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    example_print_log("type", body:getType())
    example_print_log("layer", body:getLayer())
end
```

---

#### `LBody:setVelocity`

Directly sets the body's linear velocity.

```lua
LBody:setVelocity(vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | number | Velocity X component. |
| `vy` | number | Velocity Y component. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(50, -100)
    example_print_log("velocity", body:getVelocity())
    world:step(1 / 60)
    example_print_log("position", body:getPosition())
end
```

---

#### `LBody:sleep`

Forces the body into sleep state, pausing its simulation until disturbed.

```lua
LBody:sleep()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    example_print_log("sleeping", body:isSleeping())
    example_print_log("allowed", body:isSleepingAllowed())
end
```

---

#### `LBody:type`

Returns the type name of this object ("[LBody](#lbody)").

```lua
LBody:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LBody](#lbody)". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(12, -6)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    physics_log("userdata type=" .. body:type() .. " object=" .. tostring(body:typeOf("LObject")))
    physics_log("motion sample=" .. vx .. "," .. vy)
end
```

---

#### `LBody:typeOf`

Checks if this object is of a given type name.

```lua
LBody:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setGravityScale(0.5)
    local isBody = body:typeOf("LBody")
    local isObject = body:typeOf("LObject")
    local isWorld = body:typeOf("LWorld")
    physics_log("body handle checks body=" .. tostring(isBody) .. " object=" .. tostring(isObject))
    physics_log("world check=" .. tostring(isWorld) .. " type=" .. body:type())
end
```

---

#### `LBody:wakeUp`

Wakes the body from sleep, making it active in the simulation again.

```lua
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
    example_print_log("sleeping", body:isSleeping())
    example_print_log("allowed", body:isSleepingAllowed())
end
```

---

## LPhysicsShape

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPhysicsShape:destroy`

No-op placeholder for API consistency. Shapes are freed when no longer referenced.

```lua
LPhysicsShape:destroy()
```

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    local before = shape:type()
    local radius = shape:getRadius()
    shape:destroy()
    local after = shape:getType()
    physics_log("temporary shape type before=" .. before .. " after=" .. after)
    physics_log("radius sample=" .. radius)
end
```

---

#### `LPhysicsShape:getBoundingBox`

Returns the axis-aligned bounding box of the shape in local coordinates.

```lua
LPhysicsShape:getBoundingBox()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum X. |
| number | Minimum Y. |
| number | Maximum X. |
| number | Maximum Y. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setSensor(true)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    physics_log("shape type=" .. circle:getType())
end
```

---

#### `LPhysicsShape:getRadius`

Returns the radius of a circle shape. Errors if called on a non-circle shape.

```lua
LPhysicsShape:getRadius()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Circle radius. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setDensity(1.5)
    local radius = circle:getRadius()
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("blast radius=" .. radius)
    physics_log("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:getType`

Returns the shape kind as a string: "circle", "rectangle", "polygon", "edge", or "chain".

```lua
LPhysicsShape:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shape type name. |

**Example**

```lua
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setRestitution(0.2)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("collider kind=" .. circle:getType())
    physics_log("preview bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:setDensity`

Sets the density used when this shape is attached to a body (affects mass calculation).

```lua
LPhysicsShape:setDensity(density)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `density` | number | Mass density. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    shape:setFriction(0.4)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("heavy boulder density prepared for " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:setFriction`

Sets the friction coefficient for this shape.

```lua
LPhysicsShape:setFriction(friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `friction` | number | Friction (0 = ice, 1 = rubber). |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    shape:setDensity(1.0)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("sticky tire friction tuned on " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:setRestitution`

Sets the restitution (bounciness) for this shape.

```lua
LPhysicsShape:setRestitution(restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `restitution` | number | Restitution (0\u20131). |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    shape:setDensity(0.8)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("pickup bounce tuned on " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:setSensor`

Marks this shape as a sensor (overlap detection only, no physical response).

```lua
LPhysicsShape:setSensor(sensor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sensor` | boolean | True for sensor mode. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(true)
    shape:setDensity(0.2)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("trigger volume type=" .. shape:getType())
    physics_log("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:type`

Returns the type name of this object ("[LPhysicsShape](#lphysicsshape)").

```lua
LPhysicsShape:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LPhysicsShape](#lphysicsshape)". |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("shape userdata=" .. shape:type())
    physics_log("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:typeOf`

Checks if this object is of a given type name.

```lua
LPhysicsShape:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local isShape = shape:typeOf("LPhysicsShape")
    local isObject = shape:typeOf("LObject")
    local isBody = shape:typeOf("LBody")
    physics_log("shape checks shape=" .. tostring(isShape) .. " object=" .. tostring(isObject))
    physics_log("body check=" .. tostring(isBody) .. " userdata=" .. shape:type())
end
```

---

## LTerrain

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTerrain:collapseColumns`

Optimizes terrain by merging vertically adjacent solid cells into larger colliders.

```lua
LTerrain:collapseColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of columns collapsed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    example_print_log("collapsed", terrain:collapseColumns())
    example_print_log("dirty", terrain:isDirty())
end
```

---

#### `LTerrain:fillAll`

Sets all terrain cells to either solid or empty.

```lua
LTerrain:fillAll(solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `solid` | boolean | True to fill everything solid, false to clear. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:fillCircle`

Fills or clears a circular region of terrain cells.

```lua
LTerrain:fillCircle(wx, wy, radius, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Circle center X in world coordinates. |
| `wy` | number | Circle center Y in world coordinates. |
| `radius` | number | Circle radius in world units. |
| `solid` | boolean | True to fill solid, false to carve empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 256, 50, false)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:fillRect`

Fills or clears a rectangular region of terrain cells.

```lua
LTerrain:fillRect(wx, wy, w, h, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Rectangle left X in world coordinates. |
| `wy` | number | Rectangle top Y in world coordinates. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `solid` | boolean | True to fill solid, false to carve empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillRect(80, 80, 40, 40, false)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("cell", terrain:getCell(10, 10))
end
```

---

#### `LTerrain:flush`

Regenerates physics colliders from the current terrain grid state. Call after modifying cells.

```lua
LTerrain:flush()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:flush()
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:getCell`

Returns whether a cell is solid. This method is available to Lua scripts.

```lua
LTerrain:getCell(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column. |
| `cy` | number | Cell row. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the cell is solid. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    example_print_log("cell", terrain:getCell(5, 5))
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:isDirty`

Returns true if terrain cells have been modified since the last flush.

```lua
LTerrain:isDirty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a flush is needed. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:loadFromBytes`

Restores terrain grid state from binary data previously produced by toBytes.

```lua
LTerrain:loadFromBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Binary terrain data. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if loading succeeded. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local bytes = terrain:toBytes()
    local clone = lurek.physics.newTerrain(32, 32, 4, world)
    example_print_log("loaded", clone:loadFromBytes(bytes))
    example_print_log("cell", clone:getCell(0, 0))
end
```

---

#### `LTerrain:setCell`

Sets a single terrain cell to solid or empty.

```lua
LTerrain:setCell(cx, cy, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column (0-based). |
| `cy` | number | Cell row (0-based). |
| `solid` | boolean | True for solid, false for empty. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    example_print_log("cell", terrain:getCell(5, 5))
    example_print_log("dirty", terrain:isDirty())
end
```

---

#### `LTerrain:solidPositions`

Returns all solid cell positions as a table of {x, y} entries.

```lua
LTerrain:solidPositions()
```

**Returns**

| Type | Description |
|------|-------------|
| LTerrainSolidPositionsResult | Array of tables with x and y fields (cell coordinates). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    example_print_log("count", #solids)
    if solids[1] then
        example_print_log("first", solids[1].x, solids[1].y)
    end
end
```

---

#### `LTerrain:spawnDebris`

Spawns small dynamic debris bodies at the given positions (for destruction effects).

```lua
LTerrain:spawnDebris(positions, mass, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `positions` | table | Array of {x, y} tables in world coordinates. |
| `mass` | number | Mass of each debris body. |
| `restitution` | number | Bounciness of debris bodies. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of body IDs for the spawned debris. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:flush()
    local debris = terrain:spawnDebris({ { x = 64, y = 64 }, { x = 72, y = 64 } }, 1.0, 0.2)
    example_print_log("count", #debris)
    example_print_log("body_count", world:getBodyCount())
end
```

---

#### `LTerrain:toBytes`

Serializes the terrain grid to a compact binary format for saving.

```lua
LTerrain:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary terrain data. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local bytes = terrain:toBytes()
    example_print_log("bytes", #bytes)
    example_print_log("dirty", terrain:isDirty())
end
```

---

#### `LTerrain:toImageData`

Renders the terrain grid to raw RGBA pixel data with solid and empty colors.

```lua
LTerrain:toImageData(sr, sg, sb, er, eg, eb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sr` | number | Solid color red (0-255). |
| `sg` | number | Solid color green. |
| `sb` | number | Solid color blue. |
| `er` | number | Empty color red. |
| `eg` | number | Empty color green. |
| `eb` | number | Empty color blue. |

**Returns**

| Type | Description |
|------|-------------|
| string | Raw RGBA pixel bytes. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local pixels = terrain:toImageData(255, 255, 255, 0, 0, 0)
    example_print_log("bytes", #pixels)
    example_print_log("type", terrain:type())
end
```

---

#### `LTerrain:type`

Returns the type name of this object ("[LTerrain](#lterrain)").

```lua
LTerrain:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LTerrain](#lterrain)". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillRect(32, 400, 96, 32, true)
    terrain:flush()
    physics_log("terrain userdata=" .. terrain:type())
    physics_log("terrain inheritance=" .. tostring(terrain:typeOf("LTerrain")))
end
```

---

#### `LTerrain:typeOf`

Checks if this object is of a given type name.

```lua
LTerrain:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(false)
    terrain:setCell(1, 1, true)
    local isTerrain = terrain:typeOf("LTerrain")
    local isObject = terrain:typeOf("LObject")
    physics_log("terrain check=" .. tostring(isTerrain) .. " object=" .. tostring(isObject))
    physics_log("terrain userdata=" .. terrain:type())
end
```

---

## LWorld

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LWorld:addDistanceJoint`

Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.

```lua
LWorld:addDistanceJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, length)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorAX` | number | Local anchor X on body A. |
| `anchorAY` | number | Local anchor Y on body A. |
| `anchorBX` | number | Local anchor X on body B. |
| `anchorBY` | number | Local anchor Y on body B. |
| `length` | number | Target distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(bodyA:getId(), bodyB:getId(), 0, 0, 0, 0, 100)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addFixture`

Attaches a new collider shape to an existing body with material properties.

```lua
LWorld:addFixture(bodyId, shapeType, density, friction, restitution, sensor, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The target body ID. |
| `shapeType` | string | Shape kind: "circle", "rectangle", "polygon", "edge", or "chain". |
| `density` | number | Mass density (affects dynamic body mass calculation). |
| `friction` | number | Surface friction coefficient (0 = ice, 1 = rubber). |
| `restitution` | number | Bounciness (0 = no bounce, 1 = perfectly elastic). |
| `sensor` | boolean | If true, detects overlaps without generating collision response. |
| — | — | @param ... number Shape-specific size arguments (radius, width/height, or vertex list). |

**Returns**

| Type | Description |
|------|-------------|
| number | The fixture index on the body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    example_print_log("fixture", fid)
    example_print_log("count", world:fixtureCount(body:getId()))
end
```

---

#### `LWorld:addFrictionJoint`

Creates a friction joint that applies resistance to relative motion between two bodies.

```lua
LWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `maxForce` | number | Maximum friction force. |
| `maxTorque` | number | Maximum friction torque. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    local jointId = world:addFrictionJoint(ground:getId(), puck:getId(), 200, 400, 100, 50)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addGearJoint`

Creates a gear joint that synchronizes rotation between two bodies at an anchor.

```lua
LWorld:addGearJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Gear anchor X. |
| `anchorY` | number | Gear anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addMotorJoint`

Creates a motor joint that drives body B toward a target offset from body A using a correction factor.

```lua
LWorld:addMotorJoint(bodyA, bodyB, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `factor` | number | Correction factor (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1), higher = faster convergence. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addMouseJoint`

Creates a mouse joint that pulls a body toward a world target point with spring-like force.

```lua
LWorld:addMouseJoint(bodyId, targetX, targetY, maxForce)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to pull. |
| `targetX` | number | Initial target X in world coordinates. |
| `targetY` | number | Initial target Y in world coordinates. |
| `maxForce` | number | Maximum force applied to reach the target. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    world:setMouseJointTarget(jointId, 400, 150)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addPrismaticJoint`

Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.

```lua
LWorld:addPrismaticJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `axisX` | number | Slide axis X direction. |
| `axisY` | number | Slide axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(rail:getId(), slider:getId(), 300, 300, 1, 0)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addPulleyJoint`

Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.

```lua
LWorld:addPulleyJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Shared anchor X. |
| `anchorY` | number | Shared anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addRevoluteJoint`

Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.

```lua
LWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local pivot = world:newBody(200, 150, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addRopeJoint`

Creates a rope joint limiting the maximum distance between two anchor points on two bodies.

```lua
LWorld:addRopeJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, maxLength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorAX` | number | Local anchor X on body A. |
| `anchorAY` | number | Local anchor Y on body A. |
| `anchorBX` | number | Local anchor X on body B. |
| `anchorBY` | number | Local anchor Y on body B. |
| `maxLength` | number | Maximum allowed distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addWeldJoint`

Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).

```lua
LWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addWheelJoint`

Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.

```lua
LWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID (chassis). |
| `bodyB` | number | Second body ID (wheel). |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `axisX` | number | Suspension axis X direction. |
| `axisY` | number | Suspension axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(car:getId(), wheel:getId(), 200, 230, 0, 1)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end
```

---

#### `LWorld:addZone`

Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).

```lua
LWorld:addZone(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Zone left X. |
| `y` | number | Zone top Y. |
| `w` | number | Zone width. |
| `h` | number | Zone height. |

**Returns**

| Type | Description |
|------|-------------|
| [LZone](#lzone) | The zone handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    zone:setPriority(10)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end
```

---

#### `LWorld:clear`

Removes bodies, joints, terrain colliders, and zones while preserving world-level settings.

```lua
LWorld:clear()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    example_print_log("before", world:getBodyCount())
    world:clear()
    example_print_log("after", world:getBodyCount())
end
```

---

#### `LWorld:clearBeginContact`

Removes the begin-contact callback so it is no longer called.

```lua
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
    example_print_log("count", count)
end
```

---

#### `LWorld:clearBodyData`

Removes and releases the Lua data attached to a body.

```lua
LWorld:clearBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player" })
    world:clearBodyData(player:getId())
    example_print_log("data", world:getBodyData(player:getId()))
end
```

---

#### `LWorld:clearBodyOneWay`

Removes the one-way platform behavior from a body, making it block from all directions.

```lua
LWorld:clearBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    world:clearBodyOneWay(platform:getId())
    example_print_log("normal", world:getBodyOneWay(platform:getId()))
end
```

---

#### `LWorld:clearEndContact`

Removes the end-contact callback so it is no longer called.

```lua
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
    example_print_log("count", count)
end
```

---

#### `LWorld:destroyBody`

Removes a body from the world by its ID, along with all attached fixtures and joints.

```lua
LWorld:destroyBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    example_print_log("before", world:getBodyCount())
    world:destroyBody(body:getId())
    example_print_log("after", world:getBodyCount())
end
```

---

#### `LWorld:destroyJoint`

Removes a joint from the world, disconnecting the two bodies it linked.

```lua
LWorld:destroyJoint(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID to destroy. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("before", world:jointCount())
    world:destroyJoint(jid)
    example_print_log("after", world:jointCount())
end
```

---

#### `LWorld:drawDebug`

Renders a debug visualization of all physics bodies onto a software ImageData target.

```lua
LWorld:drawDebug(target, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw debug shapes onto. |
| `r?` | number | Red channel (0-255, default 0). |
| `g?` | number | Green channel (0-255, default 255). |
| `b?` | number | Blue channel (0-255, default 0). |
| `a?` | number | Alpha channel (0-255, default 255). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    local img = lurek.image.newImageData(800, 600)
    local ok, err = pcall(function() world:drawDebug(img, 0, 255, 0, 200) end)
    if ok then example_print_log("image", img:type()) else example_print_log("drawDebug skipped: " .. tostring(err)) end
end
```

---

#### `LWorld:fixtureCount`

Returns how many fixtures (colliders) are attached to a body.

```lua
LWorld:fixtureCount(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of attached fixtures. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    world:addFixture(body:getId(), "rectangle", 1.0, 0.6, 0.1, false, 12.0, 4.0)
    world:step(1 / 60)
    physics_log("fixture count=" .. world:fixtureCount(body:getId()))
    physics_log("body type=" .. body:getType())
end
```

---

#### `LWorld:getBeginContactEvents`

Returns contact-begin events from the last step (pairs of bodies that started touching).

```lua
LWorld:getBeginContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetBeginContactEventsResult | Array of {bodyA, bodyB} tables. |

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
    example_print_log("count", count)
end
```

---

#### `LWorld:getBodyAtPoint`

Returns the body ID at a specific world point, or nil if no body is there.

```lua
LWorld:getBodyAtPoint(x, y, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Query point X. |
| `y` | number | Query point Y. |
| `filter?` | table | Optional query filter: {layer?, mask?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Body ID at the point, or nil. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 30, "static")
    body:setLayer(0x2)
    local hitId = world:getBodyAtPoint(210, 205, { layer = 0x1, mask = 0x2 })
    local missId = world:getBodyAtPoint(0, 0, { layer = 0x1, mask = 0x2 })
    example_print_log("hit", hitId)
    example_print_log("miss", missId)
end
```

---

#### `LWorld:getBodyCCD`

Returns whether continuous collision detection is enabled on a body.

```lua
LWorld:getBodyCCD(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if CCD is enabled. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    example_print_log("ccd", world:getBodyCCD(bullet:getId()))
    example_print_log("velocity", bullet:getVelocity())
end
```

---

#### `LWorld:getBodyContacts`

Returns all contacts involving a specific body.

```lua
LWorld:getBodyContacts(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to query contacts for. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetBodyContactsResult | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

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
    example_print_log("count", #contacts)
    if contacts[1] then
        example_print_log("first", contacts[1].bodyA, contacts[1].bodyB)
    end
end
```

---

#### `LWorld:getBodyCount`

Returns the total number of active bodies in the world.

```lua
LWorld:getBodyCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Body count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(100, 100, "dynamic")
    local floor = world:newBody(200, 200, "static")
    local pickup = world:newBody(240, 140, "sensor")
    world:step(1 / 60)
    physics_log("arena bodies=" .. world:getBodyCount())
    physics_log("player=" .. player:getType() .. " floor=" .. floor:getType() .. " pickup=" .. pickup:getType())
end
```

---

#### `LWorld:getBodyData`

Retrieves the Lua data previously attached to a body, or nil if none was set.

```lua
LWorld:getBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | The stored value, or nil if none was set. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local data = world:getBodyData(enemy:getId())
    example_print_log("tag", data.tag)
    example_print_log("hp", data.hp)
end
```

---

#### `LWorld:getBodyIds`

Returns a sequential table of all body IDs currently in the world.

```lua
LWorld:getBodyIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    example_print_log("count", #ids)
    example_print_log("first", ids[1])
end
```

---

#### `LWorld:getBodyOneWay`

Returns the one-way platform normal for a body, or nil,nil if not set.

```lua
LWorld:getBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Normal X; or nil if not a one-way body. |
| number | Normal Y; or nil if not a one-way body. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    local coin = world:newBody(220, 360, "sensor")
    world:step(1 / 60)
    physics_log("queried one-way normal=" .. nx .. "," .. ny)
    physics_log("platform=" .. platform:getType() .. " helper=" .. coin:getType())
end
```

---

#### `LWorld:getBodyType`

Returns the type name of a body as a string.

```lua
LWorld:getBodyType(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | Body type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    world:newBody(100, 220, "static")
    world:setBodyData(body:getId(), { role = "crate" })
    local data = world:getBodyData(body:getId())
    physics_log("body type lookup=" .. world:getBodyType(body:getId()) .. " id=" .. body:getId())
    physics_log("role=" .. data.role .. " world bodies=" .. world:getBodyCount())
end
```

---

#### `LWorld:getCollisionEvents`

Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.

```lua
LWorld:getCollisionEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetCollisionEventsResult | Array of collision event tables. |

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
    example_print_log("count", count)
end
```

---

#### `LWorld:getContacts`

Returns all currently active contact manifolds with normals and touching state.

```lua
LWorld:getContacts()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetContactsResult | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

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
    example_print_log("count", #contacts)
    example_print_log("ball", ball:getId())
    if contacts[1] then
        example_print_log("touching", contacts[1].isTouching)
    end
end
```

---

#### `LWorld:getEndContactEvents`

Returns contact-end events from the last step (pairs of bodies that stopped touching).

```lua
LWorld:getEndContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetEndContactEventsResult | Array of {bodyA, bodyB} tables. |

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
    example_print_log("count", count)
end
```

---

#### `LWorld:getGravity`

Returns the current world gravity vector.

```lua
LWorld:getGravity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Gravity X component in world units per second squared. |
| number | Gravity Y component in world units per second squared. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    example_print_log("gravity", gx, gy)
    world:setGravity(10, 800)
    example_print_log("updated", world:getGravity())
end
```

---

#### `LWorld:getJointBodies`

Returns the two body IDs connected by a joint.

```lua
LWorld:getJointBodies(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Body A ID. |
| number | Body B ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("bodies", world:getJointBodies(jid))
end
```

---

#### `LWorld:getJointBreakForce`

Returns the break force threshold for a joint.

```lua
LWorld:getJointBreakForce(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Break force value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    example_print_log("break_force", world:getJointBreakForce(jid))
end
```

---

#### `LWorld:getJointIds`

Returns a sequential table of all joint IDs currently in the world.

```lua
LWorld:getJointIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Joint ID numbers. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    example_print_log("count", #ids)
    example_print_log("first", ids[1])
end
```

---

#### `LWorld:getJointLimits`

Returns the lower and upper limit values for a joint.

```lua
LWorld:getJointLimits(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Lower limit. |
| number | Upper limit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    example_print_log("limits", world:getJointLimits(jid))
end
```

---

#### `LWorld:getJointMotorSpeed`

Returns the current motor speed setting of a joint.

```lua
LWorld:getJointMotorSpeed(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Motor speed value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    example_print_log("motor_speed", world:getJointMotorSpeed(jid))
end
```

---

#### `LWorld:getJointType`

Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").

```lua
LWorld:getJointType(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | The joint type name. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("joint_type", world:getJointType(jid))
end
```

---

#### `LWorld:getMeter`

Returns the current pixels-per-meter scale.

```lua
LWorld:getMeter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pixels per meter. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local bridgeSpanMeters = 2.0
    local bridgeSpanPixels = world:toPixels(bridgeSpanMeters)
    local rampHeightPixels = world:toPixels(0.75)
    physics_log("builder meter=" .. world:getMeter() .. " bridge_px=" .. bridgeSpanPixels)
    physics_log("ramp height px=" .. rampHeightPixels)
end
```

---

#### `LWorld:getSolverIterations`

Returns the current number of velocity solver iterations.

```lua
LWorld:getSolverIterations()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Iteration count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(10)
    local floor = world:newBody(200, 420, "static")
    local ball = world:newCircleBody(200, 120, 8, "dynamic")
    world:step(1 / 60)
    physics_log("solver iterations=" .. world:getSolverIterations())
    physics_log("scene bodies=" .. world:getBodyCount() .. " floor=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end
```

---

#### `LWorld:getStats`

Returns active counts and slot diagnostics for the world.

```lua
LWorld:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetStatsResult | Stats table with bodies, bodySlots, colliders, joints, jointSlots, zones, sleepingBodies. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local stats = world:getStats()
    example_print_log("bodies", stats.bodies, "slots", stats.bodySlots, "colliders", stats.colliders)
    example_print_log("joints", stats.joints, "joint_slots", stats.jointSlots)
    example_print_log("zones", stats.zones, "sleeping", stats.sleepingBodies)
    body:destroy()
    stats = world:getStats()
    example_print_log("after_destroy", stats.bodies, "slots", stats.bodySlots)
end
```

---

#### `LWorld:getZoneEvents`

Returns all zone enter/leave events from the last step.

```lua
LWorld:getZoneEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetZoneEventsResult | Array of {zone_id, body_id, kind} tables where kind is "enter" or "leave". |

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
    example_print_log("count", count)
end
```

---

#### `LWorld:hasBody`

Returns true when a body ID still refers to a live body slot.

```lua
LWorld:hasBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Body ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body is active. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    example_print_log("has_body", world:hasBody(body:getId()))
    body:destroy()
    example_print_log("has_body_after_destroy", world:hasBody(body:getId()))
end
```

---

#### `LWorld:hasJoint`

Returns true when a joint ID still refers to a live joint slot.

```lua
LWorld:hasJoint(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Joint ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the joint is active. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("has_joint", world:hasJoint(jid))
    world:destroyJoint(jid)
    example_print_log("has_joint_after_destroy", world:hasJoint(jid))
end
```

---

#### `LWorld:isBodySleeping`

Returns whether a body is currently in the sleeping (inactive) state.

```lua
LWorld:isBodySleeping(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body is sleeping. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end
```

---

#### `LWorld:jointCount`

Returns the total number of joints in the world.

```lua
LWorld:jointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Joint count. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("joint_count", world:jointCount())
end
```

---

#### `LWorld:newBodies`

Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.

```lua
LWorld:newBodies(specs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `specs` | table | Array of tables: {{x, y, w, h, "dynamic"}, ...} or {{x, y, "dynamic"}, ...} (defaults to 16x16). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers in creation order. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ids = world:newBodies({
        { 15, 50, 12, 12, "dynamic" },
        { 30, 50, 12, 12, "dynamic" },
        { 45, 50, 12, 12, "static" },
    })
    example_print_log("created", #ids)
    example_print_log("body_count", world:getBodyCount())
end
```

---

#### `LWorld:newBody`

Creates a new physics body at the given position with the specified type and dimensions.

```lua
LWorld:newBody(x, y, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    world:step(1 / 60)
    example_print_log("id", body:getId())
    example_print_log("type", body:getType())
    example_print_log("position", body:getPosition())
end
```

---

#### `LWorld:newChainBody`

Creates a new body with a chain (polyline) collider. Useful for terrain edges.

```lua
LWorld:newChainBody(x, y, vertices, closed, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Body X position in world coordinates. |
| `y` | number | Body Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `closed` | boolean | If true, connects the last vertex back to the first. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static")
    local bike = world:newCircleBody(120, 420, 8, "dynamic")
    bike:setVelocity(30, 0)
    world:step(1 / 60)
    physics_log("track body type=" .. ground:getType() .. " start_y=" .. select(2, ground:getPosition()))
    physics_log("bike pos=" .. select(1, bike:getPosition()) .. "," .. select(2, bike:getPosition()))
end
```

---

#### `LWorld:newCircleBody`

Creates a new body with a circle collider already attached.

```lua
LWorld:newCircleBody(x, y, radius, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `radius` | number | Circle radius in world units. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    local target = world:newBody(200, 260, "static")
    ball:setVelocity(15, -20)
    world:step(1 / 60)
    physics_log("projectile pos=" .. select(1, ball:getPosition()) .. "," .. select(2, ball:getPosition()))
    physics_log("projectile size=" .. ball:getWidth() .. "x" .. ball:getHeight() .. " target=" .. target:getType())
end
```

---

#### `LWorld:newEdgeBody`

Creates a new body with an edge (line segment) collider between two local points.

```lua
LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Body X position in world coordinates. |
| `y` | number | Body Y position in world coordinates. |
| `x1` | number | Edge start X relative to body. |
| `y1` | number | Edge start Y relative to body. |
| `x2` | number | Edge end X relative to body. |
| `y2` | number | Edge end Y relative to body. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    local player = world:newCircleBody(100, 420, 10, "dynamic")
    player:setVelocity(40, 0)
    world:step(1 / 60)
    physics_log("ledge body type=" .. wall:getType() .. " pos_y=" .. select(2, wall:getPosition()))
    physics_log("runner pos=" .. select(1, player:getPosition()) .. "," .. select(2, player:getPosition()))
end
```

---

#### `LWorld:newPolygonBody`

Creates a new body with a convex polygon collider defined by vertex pairs.

```lua
LWorld:newPolygonBody(x, y, vertices, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic")
    tri:setAngularVelocity(1.5)
    world:step(1 / 60)
    local x, y = tri:getPosition()
    physics_log("falling wedge pos=" .. x .. "," .. y)
    physics_log("body type=" .. tri:getType() .. " angle=" .. tri:getAngle())
end
```

---

#### `LWorld:queryAABB`

Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.

```lua
LWorld:queryAABB(x, y, w, h, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Query rectangle left X. |
| `y` | number | Query rectangle top Y. |
| `w` | number | Query rectangle width. |
| `h` | number | Query rectangle height. |
| `filter?` | table | Optional query filter: {layer?, mask?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers found in the region. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newCircleBody(100, 100, 10, "dynamic")
    local b = world:newCircleBody(150, 120, 10, "dynamic")
    local c = world:newCircleBody(500, 500, 10, "dynamic")
    a:setLayer(0x2)
    b:setLayer(0x2)
    c:setLayer(0x4)
    local found = world:queryAABB(50, 50, 200, 200, { layer = 0x1, mask = 0x2 })
    example_print_log("count", #found)
    example_print_log("first", found[1])
end
```

---

#### `LWorld:raycast`

Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.

```lua
LWorld:raycast(x1, y1, x2, y2, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Ray origin X. |
| `y1` | number | Ray origin Y. |
| `x2` | number | Ray end X. |
| `y2` | number | Ray end Y. |
| `filter?` | table | Optional query filter: {layer?, mask?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastResult | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 20, "static")
    body:setLayer(0x2)
    local hit = world:raycast(0, 200, 600, 200, { layer = 0x1, mask = 0x2 })
    if hit then
        example_print_log("body", hit.bodyId)
        example_print_log("point", hit.x, hit.y)
        example_print_log("normal", hit.normalX, hit.normalY)
    else
        example_print_log("body", nil)
    end
end
```

---

#### `LWorld:raycastAll`

Casts a directional ray and returns all bodies hit within max distance as a table of results.

```lua
LWorld:raycastAll(x, y, dx, dy, maxDist, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Ray origin X. |
| `y` | number | Ray origin Y. |
| `dx` | number | Ray direction X. |
| `dy` | number | Ray direction Y. |
| `maxDist` | number | Maximum ray travel distance. |
| `filter?` | table | Optional query filter: {layer?, mask?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastAllResult | Array of hit tables {bodyId, x, y, normalX, normalY, toi}. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        local body = world:newCircleBody(100 + i * 80, 200, 10, "static")
        body:setLayer(0x2)
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600, { layer = 0x1, mask = 0x2 })
    example_print_log("count", #hits)
    if hits[1] then
        example_print_log("first", hits[1].bodyId, hits[1].x, hits[1].y)
    end
end
```

---

#### `LWorld:raycastClosest`

Casts a directional ray from a point and returns the closest hit within max distance.

```lua
LWorld:raycastClosest(x, y, dx, dy, maxDist, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Ray origin X. |
| `y` | number | Ray origin Y. |
| `dx` | number | Ray direction X (does not need to be normalized). |
| `dy` | number | Ray direction Y. |
| `maxDist` | number | Maximum ray travel distance. |
| `filter?` | table | Optional query filter: {layer?, mask?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastClosestResult | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 300, 15, "static")
    body:setLayer(0x2)
    local hit = world:raycastClosest(200, 100, 0, 1, 500, { layer = 0x1, mask = 0x2 })
    if hit then
        example_print_log("body", hit.bodyId)
        example_print_log("point", hit.x, hit.y)
        example_print_log("toi", hit.toi)
    else
        example_print_log("body", nil)
    end
end
```

---

#### `LWorld:resetWorld`

Fully resets the world to its post-construction state.

```lua
LWorld:resetWorld()
```

---

#### `LWorld:setBeginContact`

Registers a callback function invoked whenever two bodies begin touching.

```lua
LWorld:setBeginContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Called with (bodyIdA, bodyIdB) on each new contact. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        example_print_log("callback", bodyA, bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    example_print_log("count", contactCount)
end
```

---

#### `LWorld:setBodyCCD`

Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.

```lua
LWorld:setBodyCCD(id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `enabled` | boolean | True to enable CCD. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    example_print_log("ccd", world:getBodyCCD(bullet:getId()))
    example_print_log("id", bullet:getId())
end
```

---

#### `LWorld:setBodyData`

Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).

```lua
LWorld:setBodyData(id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `value` | any | Lua value to associate with this body (table, number, string, etc.). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    local data = world:getBodyData(player:getId())
    example_print_log("tag", data.tag)
    example_print_log("hp", data.hp)
end
```

---

#### `LWorld:setBodyOneWay`

Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.

```lua
LWorld:setBodyOneWay(id, nx, ny)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `nx` | number | One-way normal X (points toward the blocking side). |
| `ny` | number | One-way normal Y. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    local player = world:newCircleBody(200, 320, 10, "dynamic")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    world:step(1 / 60)
    physics_log("one-way normal=" .. nx .. "," .. ny)
    physics_log("player above platform y=" .. select(2, player:getPosition()))
end
```

---

#### `LWorld:setBodyType`

Changes the type of an existing body (e.g. from "dynamic" to "static").

```lua
LWorld:setBodyType(id, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `bodyType` | string | New type: "static", "dynamic", "kinematic", or "sensor". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:setBodyType(body:getId(), "static")
    body:setPosition(32, 64)
    world:step(1 / 60)
    physics_log("builder converted type=" .. world:getBodyType(body:getId()))
    physics_log("placement=" .. body:getX() .. "," .. body:getY())
end
```

---

#### `LWorld:setEndContact`

Registers a callback function invoked whenever two bodies stop touching.

```lua
LWorld:setEndContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Called with (bodyIdA, bodyIdB) on each ended contact. |

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
        example_print_log("callback", bodyA, bodyB)
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    example_print_log("count", endCount)
end
```

---

#### `LWorld:setFixtureFriction`

Updates the friction coefficient of a specific fixture on a body.

```lua
LWorld:setFixtureFriction(bodyId, fixtureIndex, friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `friction` | number | New friction value (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1 typical range). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end
```

---

#### `LWorld:setFixtureRestitution`

Updates the restitution (bounciness) of a specific fixture on a body.

```lua
LWorld:setFixtureRestitution(bodyId, fixtureIndex, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `restitution` | number | New restitution value (0 = no bounce, 1 = full bounce). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(body:getId(), fixture, 0.9)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end
```

---

#### `LWorld:setFixtureSensor`

Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).

```lua
LWorld:setFixtureSensor(bodyId, fixtureIndex, sensor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `sensor` | boolean | True to make it a sensor, false for solid collision. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(body:getId(), fixture, true)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end
```

---

#### `LWorld:setGravity`

Sets the world gravity vector. Affects all dynamic bodies.

```lua
LWorld:setGravity(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Horizontal gravity component. |
| `gy` | number | Vertical gravity component (positive = down in screen space). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 200)
    world:setGravity(25, 600)
    local gx, gy = world:getGravity()
    example_print_log("gravity", gx, gy)
    example_print_log("body_count", world:getBodyCount())
end
```

---

#### `LWorld:setJointBreakForce`

Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.

```lua
LWorld:setJointBreakForce(jointId, force)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `force` | number | Break threshold force (use math.huge for unbreakable). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    example_print_log("break_force", world:getJointBreakForce(jid))
end
```

---

#### `LWorld:setJointLimits`

Sets the lower and upper bounds for a joint's limited range of motion.

```lua
LWorld:setJointLimits(jointId, lower, upper)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `lower` | number | Lower limit (radians or meters depending on joint type). |
| `upper` | number | Upper limit. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    example_print_log("limits", world:getJointLimits(jid))
end
```

---

#### `LWorld:setJointLimitsEnabled`

Enables or disables angular/linear limits on a joint.

```lua
LWorld:setJointLimitsEnabled(jointId, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `enabled` | boolean | True to enforce limits, false to allow free movement. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    example_print_log("limits", world:getJointLimits(jid))
end
```

---

#### `LWorld:setJointMotorSpeed`

Sets the motor speed on a motorized joint (revolute or prismatic).

```lua
LWorld:setJointMotorSpeed(jointId, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `speed` | number | Desired motor speed (radians/sec for revolute, meters/sec for prismatic). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    example_print_log("motor_speed", world:getJointMotorSpeed(jid))
end
```

---

#### `LWorld:setMeter`

Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.

```lua
LWorld:setMeter(ppm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ppm` | number | Pixels per meter (e.g. 64 means 64 px = 1 meter in physics). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local playerWidthPixels = 128
    local playerWidthMeters = world:toPhysics(playerWidthPixels)
    local jumpArcPixels = world:toPixels(1.5)
    physics_log("platformer meter=" .. world:getMeter() .. " player_width_m=" .. playerWidthMeters)
    physics_log("jump arc preview px=" .. jumpArcPixels)
end
```

---

#### `LWorld:setMouseJointTarget`

Moves the target position of a mouse joint, causing the attached body to follow.

```lua
LWorld:setMouseJointTarget(jointId, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The mouse joint ID. |
| `x` | number | New target X in world coordinates. |
| `y` | number | New target Y in world coordinates. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    example_print_log("joint", jid)
    example_print_log("type", world:getJointType(jid))
end
```

---

#### `LWorld:setSolverIterations`

Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.

```lua
LWorld:setSolverIterations(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of iterations (default is typically 4Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›8). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local crate = world:newCircleBody(160, 80, 10, "dynamic")
    world:setSolverIterations(8)
    crate:setVelocity(0, 20)
    world:step(1 / 60)
    physics_log("solver iterations=" .. world:getSolverIterations())
    physics_log("crate velocity y=" .. select(2, crate:getVelocity()))
end
```

---

#### `LWorld:sleepBody`

Forces a body into the sleeping state, pausing its simulation until disturbed.

```lua
LWorld:sleepBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end
```

---

#### `LWorld:step`

Advances the physics simulation by a time delta and fires any registered contact callbacks.

```lua
LWorld:step(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time step in seconds (e.g. 1/60 for 60 FPS). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 12, "dynamic")
    world:step(1 / 60)
    example_print_log("position", body:getPosition())
    example_print_log("velocity", body:getVelocity())
end
```

---

#### `LWorld:stepFixed`

Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.

```lua
LWorld:stepFixed(accumulator, stepDt, maxSteps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `accumulator` | number | Accumulated time since last frame (seconds). |
| `stepDt` | number | Fixed step size (e.g. 1/60). |
| `maxSteps` | number | Maximum sub-steps per call to prevent spiral of death. |

**Returns**

| Type | Description |
|------|-------------|
| number | Remaining unstepped time to carry into next frame. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 120, 10, "dynamic")
    local remainder = world:stepFixed(0.025, 1 / 60, 4)
    local x, y = ball:getPosition()
    local vx, vy = ball:getVelocity()
    physics_log("fixed-step remainder=" .. remainder .. " pos=" .. x .. "," .. y)
    physics_log("post-step velocity=" .. vx .. "," .. vy .. " iterations=" .. world:getSolverIterations())
end
```

---

#### `LWorld:toPhysics`

Converts a pixel measurement to physics-world meters using the current meter scale.

```lua
LWorld:toPhysics(px)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Value in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Equivalent value in physics meters. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local doorWidthPx = 96
    local doorWidthMeters = world:toPhysics(doorWidthPx)
    local heroRadiusMeters = world:toPhysics(24)
    physics_log("door width meters=" .. doorWidthMeters)
    physics_log("hero radius meters=" .. heroRadiusMeters)
    physics_log("reference pixels=" .. world:toPixels(1.5))
end
```

---

#### `LWorld:toPixels`

Converts a physics-world meter measurement to pixels using the current meter scale.

```lua
LWorld:toPixels(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | number | Value in physics meters. |

**Returns**

| Type | Description |
|------|-------------|
| number | Equivalent value in pixels. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local ropeLengthMeters = 2.5
    local ropeLengthPixels = world:toPixels(ropeLengthMeters)
    local ledgeDepthPixels = world:toPixels(0.5)
    physics_log("rope length px=" .. ropeLengthPixels)
    physics_log("ledge depth px=" .. ledgeDepthPixels)
    physics_log("reverse sample meters=" .. world:toPhysics(160))
end
```

---

#### `LWorld:type`

Returns the type name of this object ("[LWorld](#lworld)").

```lua
LWorld:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LWorld](#lworld)". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(160, 300, "static")
    local ball = world:newCircleBody(160, 120, 10, "dynamic")
    world:step(1 / 60)
    physics_log("world userdata=" .. world:type() .. " world_check=" .. tostring(world:typeOf("LWorld")))
    physics_log("scene bodies=" .. world:getBodyCount() .. " first=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end
```

---

#### `LWorld:typeOf`

Checks if this object is of a given type name. Supports inheritance (always matches "Object").

```lua
LWorld:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(160, 300, "static")
    world:newCircleBody(160, 120, 10, "dynamic")
    local isWorld = world:typeOf("LWorld")
    local isObject = world:typeOf("LObject")
    physics_log("world check=" .. tostring(isWorld) .. " object check=" .. tostring(isObject))
    physics_log("runtime kind=" .. world:type() .. " bodies=" .. world:getBodyCount())
end
```

---

#### `LWorld:wakeUpBody`

Forces a sleeping body to wake up and participate in simulation again.

```lua
LWorld:wakeUpBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    world:wakeUpBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end
```

---

## LZone

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LZone:destroy`

Removes this zone from the world. Bodies will no longer be affected by it.

```lua
LZone:destroy()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(0, 0, 100, 100)
    example_print_log("zone_id", zone:getId())
    zone:destroy()
    example_print_log("events", #world:getZoneEvents())
end
```

---

#### `LZone:getId`

Returns the unique ID of this zone. This method is available to Lua scripts.

```lua
LZone:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zone ID. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setGravityZero()
    local scout = world:newCircleBody(60, 60, 8, "dynamic")
    world:step(1 / 60)
    physics_log("zone id=" .. zone:getId() .. " type=" .. zone:type())
    physics_log("scout y=" .. select(2, scout:getPosition()))
end
```

---

#### `LZone:setAngularDampingOverride`

Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.

```lua
LZone:setAngularDampingOverride(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | number | Damping override, or nil to clear. |

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
    example_print_log("angular_velocity", diver:getAngularVelocity())
    example_print_log("angle", diver:getAngle())
end
```

---

#### `LZone:setCircle`

Changes this zone's shape to a circle (overrides the initial rectangle).

```lua
LZone:setCircle(cx, cy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center X. |
| `cy` | number | Center Y. |
| `radius` | number | Circle radius. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end
```

---

#### `LZone:setEnabled`

Enables or disables this zone. Disabled zones have no effect on bodies.

```lua
LZone:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable, false to disable. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end
```

---

#### `LZone:setGravityDirectional`

Sets the zone to apply a constant directional gravity to bodies inside.

```lua
LZone:setGravityDirectional(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Gravity X component. |
| `gy` | number | Gravity Y component. |

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
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end
```

---

#### `LZone:setGravityPoint`

Sets the zone to attract bodies toward a center point with a given strength.

```lua
LZone:setGravityPoint(cx, cy, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Attractor center X. |
| `cy` | number | Attractor center Y. |
| `strength` | number | Pull force magnitude. |

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
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end
```

---

#### `LZone:setGravityRepulsor`

Sets the zone to push bodies away from a center point with a given strength.

```lua
LZone:setGravityRepulsor(cx, cy, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Repulsor center X. |
| `cy` | number | Repulsor center Y. |
| `strength` | number | Push force magnitude. |

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
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end
```

---

#### `LZone:setGravityZero`

Sets the zone to cancel all gravity for bodies inside (zero-G area).

```lua
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
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end
```

---

#### `LZone:setLayerMask`

Sets a bitmask controlling which body layers this zone affects.

```lua
LZone:setLayerMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Layer bitmask (bitwise AND with body layer must be nonzero). |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setLayerMask(0xFF)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end
```

---

#### `LZone:setLinearDampingOverride`

Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.

```lua
LZone:setLinearDampingOverride(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | number | Damping override, or nil to clear. |

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
    example_print_log("velocity", diver:getVelocity())
    example_print_log("position", diver:getPosition())
end
```

---

#### `LZone:setPriority`

Sets the priority of this zone. Higher-priority zones take precedence when overlapping.

```lua
LZone:setPriority(priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `priority` | number | Integer priority value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(1)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end
```

---

#### `LZone:type`

Returns the type name of this object ("[LZone](#lzone)").

```lua
LZone:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LZone](#lzone)". |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(2)
    zone:setGravityDirectional(0, -50)
    local probe = world:newCircleBody(40, 40, 8, "dynamic")
    physics_log("zone userdata=" .. zone:type())
    physics_log("zone check=" .. tostring(zone:typeOf("LZone")) .. " probe=" .. probe:getType())
end
```

---

#### `LZone:typeOf`

Checks if this object is of a given type name.

```lua
LZone:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    local isZone = zone:typeOf("LZone")
    local isObject = zone:typeOf("LObject")
    local isWorld = zone:typeOf("LWorld")
    physics_log("zone checks zone=" .. tostring(isZone) .. " object=" .. tostring(isObject))
    physics_log("world check=" .. tostring(isWorld) .. " userdata=" .. zone:type())
end
```

---
