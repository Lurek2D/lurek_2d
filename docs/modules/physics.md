# Physics

## Purpose

Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors. - Supports shapes, continuous detection, and motorized mechanical joints. - Supports bullet-mode CCD bodies and swept circle queries for fast projectile work. - Supports mirror-style beam reflection and explicit projectile-velocity ricochet helpers. - Can infer approximate collision shapes from image alpha masks for asset-driven colliders. - Manages override zones, raycast queries, and destructible static terrain. - Provides a separate grid-based LiquidMap for leaking tanks, simple settling, serialization, and sampled buoyancy or drag. - Provides a 16-group world collision matrix layered over per-body layer/mask filters. - Provides post-step contact events and colorized visual debug overlays. - Supports authored flow fields for wind, water, conveyor, and magic-current style motion that can be sampled or applied during stepping.

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

## API Reference

- This page is the generated API reference for this module.

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
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
    lurek.log.info("position=" .. tostring(body:getPosition()))
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
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    lurek.physics.destroyWorld(world)
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("gpu debug scene bodies=" .. world:getBodyCount())
    lurek.log.info("world type=" .. world:type())
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
    lurek.log.info("free-function body pos=" .. x .. "," .. y)
    lurek.log.info("free-function velocity=" .. vx .. "," .. vy)
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
    lurek.log.info("count=" .. tostring(#collisions))
    if collisions[1] then
        lurek.log.info("first=" .. tostring(collisions[1].body_a) .. " " .. tostring(collisions[1].body_b))
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
    lurek.log.info("allowed=" .. tostring(lurek.physics.isSleepingAllowed(world, body)))
    lurek.physics.setSleepingAllowed(world, body, false)
    lurek.log.info("allowed_after=" .. tostring(lurek.physics.isSleepingAllowed(world, body)))
end
```

---

### `lurek.physics.newBody`

Creates a new body in a world (free-function variant).

```lua
lurek.physics.newBody(world, x, y, bodyType, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world` | [LWorld](#lworld) | The target world. |
| `x` | number | Initial X position. |
| `y` | number | Initial Y position. |
| `bodyType` | string | Body type: "static", "dynamic", "kinematic", or "sensor". |
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

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
    lurek.log.info("spawned wall id=" .. body:getId() .. " type=" .. body:getType())
    lurek.log.info("checkpoint type=" .. checkpoint:getType() .. " bodies=" .. world:getBodyCount())
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
    lurek.log.info("spline type=" .. chain:getType() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    lurek.log.info("pit loop type=" .. loop:getType() .. " bounds=" .. loopMinX .. "," .. loopMinY .. " -> " .. loopMaxX .. "," .. loopMaxY)
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
    lurek.log.info("type=" .. tostring(circle:getType()))
    lurek.log.info("radius=" .. tostring(circle:getRadius()))
    lurek.log.info("bounds=" .. tostring(minX) .. " " .. tostring(minY) .. " " .. tostring(maxX) .. " " .. tostring(maxY))
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
    lurek.log.info("ledge edge type=" .. edge:getType())
    lurek.log.info("ledge bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

### `lurek.physics.newLiquidMap`

Creates a grid-based liquid map linked to a physics world and optionally to a terrain blocker grid.

```lua
lurek.physics.newLiquidMap(width, height, cellSize, world, terrain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |
| `cellSize` | number | World-space size of each cell. |
| `world` | [LWorld](#lworld) | Physics world used for `applyBuoyancy`. |
| `terrain?` | [LTerrain](#lterrain) | Optional terrain grid; when provided, it must match the liquid grid dimensions, cell size, and origin. |

**Returns**

| Type | Description |
|------|-------------|
| [LLiquidMap](#lliquidmap) | The liquid map object. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 200)
    local terrain = lurek.physics.newTerrain(16, 16, 8, world)
    local liquid = lurek.physics.newLiquidMap(16, 16, 8, world, terrain)
    liquid:setCell(4, 4, 1.0, "water")
    local amount = liquid:getAmountAt(36, 36)
    lurek.log.info("liquid amount=" .. tostring(amount))
    lurek.log.info("liquid type=" .. tostring(liquid:type()))
end
```

---

### `lurek.physics.newMaterial`

Validates and canonicalizes a reusable physics material table.

```lua
lurek.physics.newMaterial(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Material options: { name?, density?, friction?, restitution?, linearDamping?, angularDamping?, gravityScale?, massOverride?, stickiness?, adhesion?, beamReflectivity?, projectileReflectivity?, beamAbsorption?, buoyancy?, surfaceType? }. |

**Returns**

| Type | Description |
|------|-------------|
| table | Canonical material table that can be reused with body and fixture assignment APIs. |

**Example**

```lua
do

    local rubber = lurek.physics.newMaterial({
        name = "rubber",
        density = 1.2,
        friction = 0.9,
        restitution = 0.8,
        surfaceType = "bounce_pad",
    })
    lurek.log.info("name=" .. tostring(rubber.name))
    lurek.log.info("friction=" .. tostring(rubber.friction))
    lurek.log.info("surface=" .. tostring(rubber.surfaceType))
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
    lurek.log.info("roof wedge type=" .. triangle:getType())
    lurek.log.info("roof bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("crate collider type=" .. rect:getType())
    lurek.log.info("crate bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("training room gravity=" .. gx .. "," .. gy)
    lurek.log.info("floor=" .. floor:getType() .. " crate_y=" .. select(2, crate:getPosition()))
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
    lurek.log.info("dash velocity=" .. vx .. "," .. vy)
    lurek.log.info("dash position=" .. body:getX() .. "," .. body:getY())
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
    lurek.log.info("always-awake enemy allowed=" .. tostring(allowed))
    lurek.log.info("body still valid=" .. tostring(valid))
end
```

---

### `lurek.physics.shapeFromImage`

Builds an approximate collision shape from an image alpha mask.

```lua
lurek.physics.shapeFromImage(image, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImageData](render.md#limagedata) | Source image; pixels with alpha above threshold are treated as solid. |
| `opts?` | table | Optional keys: alphaThreshold, maxVertices, circleAspectTolerance, circleFillTolerance, rectangleFillThreshold. |

**Returns**

| Type | Description |
|------|-------------|
| [LPhysicsShape](#lphysicsshape) | Circle, rectangle, or convex polygon approximating the opaque pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawCircle(16, 16, 9, 255, 255, 255, 255)
    local shape = lurek.physics.shapeFromImage(img, { alphaThreshold = 1, maxVertices = 8 })
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(20, 20, "dynamic")
    lurek.physics.attachShape(body, shape)
    lurek.log.info("[physics] alpha shape type=" .. shape:getType() .. " body=" .. tostring(body:getId()))
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
    lurek.log.info("module step pos=" .. x .. "," .. y)
    lurek.log.info("velocity=" .. vx .. "," .. vy .. " floor=" .. floor:getType())
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
    lurek.log.info("hazard overlap=" .. tostring(overlap) .. " player overlap=" .. tostring(playerInsideHazard))
    lurek.log.info("miss=" .. tostring(miss) .. " pickup far=" .. tostring(pickupFarAway))
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
    lurek.log.info("door splash hit=" .. tostring(hit) .. " explosion door=" .. tostring(explosionHitsDoor))
    lurek.log.info("miss=" .. tostring(miss) .. " tower miss=" .. tostring(explosionMissesTower))
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
    lurek.log.info("touching=" .. tostring(touching) .. " shield hit=" .. tostring(bombHitsShield))
    lurek.log.info("apart=" .. tostring(apart) .. " player miss=" .. tostring(bombMissesPlayer))
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
    lurek.log.info("inside tile=" .. tostring(inside) .. " ui hover=" .. tostring(buttonHover))
    lurek.log.info("outside tile=" .. tostring(outside) .. " hover miss=" .. tostring(missHover))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LBody](#lbody)
- [LFlowStream](#lflowstream)
- [LLiquidMap](#lliquidmap)
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
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
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
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
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
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
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
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
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
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
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
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    temp:destroy()
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("angle=" .. tostring(body:getAngle()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
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
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
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
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end
```

---

#### `LBody:getBeamReflectivity`

Returns the energy multiplier used when a reflective beam bounces from this body.

```lua
LBody:getBeamReflectivity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Beam reflection multiplier in the range 0..1. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(120, 90, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(0.4)
    local reflectivity = mirror:getBeamReflectivity()
    local trace = world:castBeam(40, 90, 1, 0, 140, { reflect = true, maxBounces = 1, minEnergy = 0.1 })
    lurek.log.info("beam_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("trace_hits=" .. tostring(#trace.hits))
end
```

---

#### `LBody:getCollisionGroup`

Returns the single 0..15 collision group for this body, or nil for multi-group masks.

```lua
LBody:getCollisionGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Collision group index, or nil. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setCollisionGroup(4)
    local group = body:getCollisionGroup()
    body:setLayer(0x3)
    lurek.log.info("single=" .. tostring(group))
    lurek.log.info("multi group returns=" .. tostring(body:getCollisionGroup()))
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
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
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
    lurek.log.info("gravity_scale=" .. tostring(body:getGravityScale()))
    lurek.log.info("type=" .. tostring(body:getType()))
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
    lurek.log.info("character height=" .. body:getHeight() .. " width=" .. body:getWidth())
    lurek.log.info("spawn pos=" .. select(1, body:getPosition()) .. "," .. select(2, body:getPosition()))
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
    lurek.log.info("body id=" .. body:getId() .. " kind=" .. data.kind)
    lurek.log.info("spawn x=" .. body:getX() .. " y=" .. body:getY())
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
    lurek.log.info("layer=" .. tostring(body:getLayer()))
    lurek.log.info("type=" .. tostring(body:getType()))
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
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
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
    lurek.log.info("mask=" .. tostring(body:getMask()))
    lurek.log.info("id=" .. tostring(body:getId()))
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
    lurek.log.info("mass=" .. tostring(body:getMass()))
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
end
```

---

#### `LBody:getMaterial`

Returns this body's current material table.

```lua
LBody:getMaterial()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Material table with solver-backed and gameplay metadata fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(40, 40, "dynamic")
    body:setMaterial(lurek.physics.newMaterial({
        name = "mirror",
        friction = 0.2,
        restitution = 0.1,
        beamReflectivity = 1.0,
        projectileReflectivity = 0.25,
        beamAbsorption = 0.0,
    }))
    local material = body:getMaterial()
    lurek.log.info("name=" .. tostring(material.name))
    lurek.log.info("beam=" .. tostring(material.beamReflectivity))
    lurek.log.info("projectile=" .. tostring(material.projectileReflectivity))
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
    lurek.log.info("patrol body id=" .. body:getId())
    lurek.log.info("current position=" .. x .. "," .. y)
end
```

---

#### `LBody:getProjectileReflectivity`

Returns the gameplay projectile reflectivity hint stored on this body.

```lua
LBody:getProjectileReflectivity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Projectile reflection multiplier in the range 0..1. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(90, 110, 12, 48, "static")
    wall:setProjectileReflectivity(0.55)
    local reflectivity = wall:getProjectileReflectivity()
    local mirror = wall:isMirror()
    lurek.log.info("projectile_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("mirror=" .. tostring(mirror))
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
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
    lurek.log.info("friction=" .. tostring(body:getFriction()))
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
    lurek.log.info("checkpoint type=" .. body:getType() .. " id=" .. body:getId())
    lurek.log.info("layer=" .. body:getLayer() .. " role=" .. data.role)
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
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("type=" .. tostring(body:getType()))
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
    lurek.log.info("bridge plank width=" .. body:getWidth())
    lurek.log.info("bridge plank height=" .. body:getHeight())
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
    lurek.log.info("spawn marker x=" .. x)
    lurek.log.info("paired y=" .. y)
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
    lurek.log.info("spawn marker y=" .. y)
    lurek.log.info("paired x=" .. x)
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
    lurek.log.info("is_bullet=" .. tostring(bullet:isBullet()))
    lurek.log.info("position=" .. tostring(bullet:getPosition()))
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
    lurek.log.info("fixed_rotation=" .. tostring(player:isFixedRotation()))
    lurek.log.info("type=" .. tostring(player:getType()))
end
```

---

#### `LBody:isMirror`

Returns whether this body acts as a reflective mirror for beam traces.

```lua
LBody:isMirror()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when beam reflection is enabled for this body. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(90, 90, 12, 48, "static")
    mirror:setMirror(true)
    local reflective = mirror:isMirror()
    local body_id = mirror:getId()
    lurek.log.info("body=" .. tostring(body_id))
    lurek.log.info("is_mirror=" .. tostring(reflective))
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
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("id=" .. tostring(body:getId()))
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
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
    lurek.log.info("type=" .. tostring(body:getType()))
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
    lurek.log.info("valid=" .. tostring(temp:isValid()))
    temp:destroy()
    lurek.log.info("valid_after_destroy=" .. tostring(temp:isValid()))
end
```

---

#### `LBody:setAirScale`

Sets the extra multiplier used only for `air` flow fields.

```lua
LBody:setAirScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Non-negative air multiplier. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setAirScale(0.25)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 80,
        h = 80,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 50,
        medium = "air",
    })
    world:step(1 / 60)
    lurek.log.info("[physics] airScale vx=" .. tostring(select(1, body:getVelocity())))
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
    lurek.log.info("angle=" .. tostring(body:getAngle()))
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
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
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
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
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    world:step(1 / 60)
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end
```

---

#### `LBody:setBeamReflectivity`

Sets the energy multiplier used when a reflective beam bounces from this body.

```lua
LBody:setBeamReflectivity(reflectivity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `reflectivity` | number | Beam reflection multiplier in the range 0..1. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(100, 100, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(0.65)
    local reflectivity = mirror:getBeamReflectivity()
    lurek.log.info("beam_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("mirror=" .. tostring(mirror:isMirror()))
end
```

---

#### `LBody:setBullet`

Enables or disables continuous collision detection to prevent fast-moving tunneling. Use it for small, fast bodies such as bullets and shrapnel, not every body in the scene.

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
    lurek.log.info("is_bullet=" .. tostring(bullet:isBullet()))
    lurek.log.info("type=" .. tostring(bullet:getType()))
end
```

---

#### `LBody:setCollisionGroup`

Assigns the body to one collision group and opens its local mask to the 16 group bits.

```lua
LBody:setCollisionGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Collision group index, 0..15. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(100, 100, "dynamic")
    local wall = world:newBody(120, 100, "static")
    player:setCollisionGroup(0)
    wall:setCollisionGroup(1)
    lurek.log.info("player_group=" .. tostring(player:getCollisionGroup()))
    lurek.log.info("wall group=" .. wall:getCollisionGroup() .. " player layer=" .. player:getLayer())
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
    lurek.log.info("fixed_rotation=" .. tostring(player:isFixedRotation()))
    lurek.log.info("angle=" .. tostring(player:getAngle()))
end
```

---

#### `LBody:setFlowCrossSection`

Sets the drag cross-section factor used by drag-style flow application.

```lua
LBody:setFlowCrossSection(crossSection)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `crossSection` | number | Positive cross-section multiplier. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setFlowCrossSection(2.0)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 80,
        h = 80,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        medium = "water",
        application = "targetVelocityDrag",
        strength = 50,
        drag = 2.0,
    })
    world:step(1 / 60)
    lurek.log.info("[physics] flowCrossSection vx=" .. tostring(select(1, body:getVelocity())))
end
```

---

#### `LBody:setFlowScale`

Sets the global multiplier applied to all flow-field influences on this body.

```lua
LBody:setFlowScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Non-negative flow multiplier. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setFlowScale(0.5)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 80,
        h = 80,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 50,
    })
    world:step(1 / 60)
    lurek.log.info("[physics] flowScale vx=" .. tostring(select(1, body:getVelocity())))
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
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("mass=" .. tostring(body:getMass()))
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
    lurek.log.info("normal=" .. tostring(normal:getGravityScale()))
    lurek.log.info("floaty=" .. tostring(floaty:getGravityScale()))
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
    lurek.log.info("layer=" .. tostring(body:getLayer()))
    lurek.log.info("mask=" .. tostring(body:getMask()))
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
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
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
    lurek.log.info("mask=" .. tostring(body:getMask()))
    lurek.log.info("layer=" .. tostring(body:getLayer()))
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
    lurek.log.info("mass=" .. tostring(body:getMass()))
    lurek.log.info("type=" .. tostring(body:getType()))
end
```

---

#### `LBody:setMaterial`

Applies a validated material table to this body's primary collider and body-level solver properties.

```lua
LBody:setMaterial(material)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `material` | table | Material table created by `lurek.physics.newMaterial(...)` or an equivalent options table. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    local glue = lurek.physics.newMaterial({
        name = "glue",
        density = 1.4,
        friction = 1.0,
        restitution = 0.0,
        stickiness = 1.0,
        adhesion = 0.8,
        gravityScale = 0.5,
    })
    body:setMaterial(glue)
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("gravity=" .. tostring(body:getGravityScale()))
end
```

---

#### `LBody:setMirror`

Enables or disables mirror-style beam reflection on this body.

```lua
LBody:setMirror(mirror)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mirror` | boolean | True to let reflective beam traces bounce from this body. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(80, 80, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(1.0)
    local trace = world:castBeam(20, 80, 1, 0, 160, { reflect = true, maxBounces = 1 })
    lurek.log.info("mirror_enabled=" .. tostring(mirror:isMirror()))
    lurek.log.info("mirror_segments=" .. tostring(#trace.segments))
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
    lurek.log.info("position=" .. tostring(body:getPosition()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
end
```

---

#### `LBody:setProjectileReflectivity`

Sets the gameplay projectile reflectivity hint stored on this body.

```lua
LBody:setProjectileReflectivity(reflectivity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `reflectivity` | number | Projectile reflection multiplier in the range 0..1. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(80, 100, 12, 48, "static")
    wall:setProjectileReflectivity(0.8)
    local projectile = world:newCircleBody(40, 100, 6, "dynamic")
    projectile:setVelocity(50, 0)
    local reflected = world:reflectBodyVelocity(projectile:getId(), -1, 0, wall:getProjectileReflectivity())
    lurek.log.info("projectile_reflectivity=" .. tostring(wall:getProjectileReflectivity()))
    lurek.log.info("reflected=" .. tostring(reflected))
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
| `restitution` | number | New restitution (0..1). |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
    lurek.log.info("mass=" .. tostring(body:getMass()))
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
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
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
    lurek.log.info("type=" .. tostring(body:getType()))
    lurek.log.info("layer=" .. tostring(body:getLayer()))
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
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    world:step(1 / 60)
    lurek.log.info("position=" .. tostring(body:getPosition()))
end
```

---

#### `LBody:setWaterScale`

Sets the extra multiplier used only for `water` flow fields.

```lua
LBody:setWaterScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Non-negative water multiplier. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setWaterScale(1.5)
    world:addFlowField({
        geometry = "path",
        points = {
            { x = 0, y = 20 },
            { x = 120, y = 20 },
            { x = 180, y = 48 },
        },
        width = 48,
        direction = "alongPath",
        strength = 50,
        medium = "water",
    })
    world:step(1 / 60)
    lurek.log.info("[physics] waterScale vx=" .. tostring(select(1, body:getVelocity())))
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
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
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
    lurek.log.info("userdata type=" .. body:type() .. " object=" .. tostring(body:typeOf("LObject")))
    lurek.log.info("motion sample=" .. vx .. "," .. vy)
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
    lurek.log.info("body handle checks body=" .. tostring(isBody) .. " object=" .. tostring(isObject))
    lurek.log.info("world check=" .. tostring(isWorld) .. " type=" .. body:type())
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
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
end
```

---

## LFlowStream

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFlowStream:destroy`

Disables and removes this flow field from the world.

```lua
LFlowStream:destroy()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:destroy()
    lurek.log.info("[physics] destroyed flow=" .. tostring(not world:getFlowField(field:getId()).enabled))
end
```

---

#### `LFlowStream:getId`

Returns the stable numeric ID for this flow field.

```lua
LFlowStream:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Stable flow field id. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    lurek.log.info("[physics] flow id=" .. tostring(field:getId()))
end
```

---

#### `LFlowStream:getLayerMask`

Returns this flow field layer mask.

```lua
LFlowStream:getLayerMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
        layerMask = 0x4,
    })
    lurek.log.info("[physics] getLayerMask=" .. tostring(field:getLayerMask()))
end
```

---

#### `LFlowStream:getStrength`

Returns the current movement strength for this flow field.

```lua
LFlowStream:getStrength()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Strength value. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 22,
    })
    lurek.log.info("[physics] getStrength=" .. tostring(field:getStrength()))
end
```

---

#### `LFlowStream:isEnabled`

Returns whether this flow field is enabled.

```lua
LFlowStream:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    lurek.log.info("[physics] flow enabled=" .. tostring(field:isEnabled()))
end
```

---

#### `LFlowStream:setApplication`

Sets the body-application mode used during stepping.

```lua
LFlowStream:setApplication(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | `acceleration` or `targetVelocityDrag`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setApplication("targetVelocityDrag")
    lurek.log.info("[physics] application=" .. tostring(world:getFlowField(field:getId()).application))
end
```

---

#### `LFlowStream:setCombine`

Sets how this field combines with overlapping fields.

```lua
LFlowStream:setCombine(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | `additive` or `additiveClamped`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setCombine("additiveClamped")
    lurek.log.info("[physics] combine=" .. tostring(world:getFlowField(field:getId()).combine))
end
```

---

#### `LFlowStream:setEnabled`

Enables or disables this flow field.

```lua
LFlowStream:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable, false to disable. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    field:setEnabled(false)
    lurek.log.info("[physics] enabled after set=" .. tostring(field:isEnabled()))
end
```

---

#### `LFlowStream:setLayerMask`

Sets the body-layer mask that this field affects.

```lua
LFlowStream:setLayerMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Layer bitmask. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setLayerMask(0x8)
    lurek.log.info("[physics] layer mask=" .. tostring(field:getLayerMask()))
end
```

---

#### `LFlowStream:setPoints`

Replaces the polyline points of a path-shaped flow field.

```lua
LFlowStream:setPoints(points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points` | table | Array of `{ x, y }` point tables. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "path",
        points = {
            { x = 0, y = 0 },
            { x = 20, y = 0 },
        },
        width = 8,
        strength = 20,
    })
    field:setPoints({
        { x = 0, y = 0 },
        { x = 0, y = 40 },
        { x = 16, y = 56 },
    })
    lurek.log.info("[physics] path points=" .. tostring(#world:getFlowField(field:getId()).points))
end
```

---

#### `LFlowStream:setStrength`

Sets the current movement strength for this flow field.

```lua
LFlowStream:setStrength(strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `strength` | number | Strength in world units per second. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 10,
    })
    field:setStrength(55)
    lurek.log.info("[physics] flow strength now=" .. tostring(field:getStrength()))
end
```

---

#### `LFlowStream:setWidth`

Sets the width of a path-shaped flow field.

```lua
LFlowStream:setWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Tube width in world units. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "path",
        points = {
            { x = 0, y = 0 },
            { x = 48, y = 0 },
        },
        width = 10,
        strength = 20,
    })
    field:setWidth(18)
    lurek.log.info("[physics] path width=" .. tostring(world:getFlowField(field:getId()).width))
end
```

---

#### `LFlowStream:type`

Returns the type name of this object.

```lua
LFlowStream:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `[LFlowStream](#lflowstream)`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    lurek.log.info("[physics] flow type=" .. tostring(field:type()))
end
```

---

#### `LFlowStream:typeOf`

Returns whether this object matches the requested type name.

```lua
LFlowStream:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LFlowStream](#lflowstream)` and `LObject`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    lurek.log.info("[physics] flow typeOf=" .. tostring(field:typeOf("LFlowStream")))
end
```

---

## LLiquidMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLiquidMap:applyBuoyancy`

Applies sampled buoyancy and linear drag to matching dynamic bodies in the linked world.

```lua
LLiquidMap:applyBuoyancy(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional controls: { layerMask?, density?, drag? }. |

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostics with `affectedBodies` and `submergedBodies`. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 200)
    local body = world:newCircleBody(20, 20, 6, "dynamic")
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local stats = liquid:applyBuoyancy({ density = 3.0, drag = 1.0 })
    world:step(1 / 60)
    lurek.log.info("buoyancy submerged=" .. tostring(stats.submergedBodies))
    lurek.log.info("buoyancy vy=" .. tostring(select(2, body:getVelocity())))
end
```

---

#### `LLiquidMap:drainRect`

Removes up to the requested amount from every cell in a rectangular region.

```lua
LLiquidMap:drainRect(x, y, width, height, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle left cell coordinate. |
| `y` | number | Rectangle top cell coordinate. |
| `width` | number | Rectangle width in cells. |
| `height` | number | Rectangle height in cells. |
| `amount` | number | Amount removed from each cell, clamped into `0.0..1.0`. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(10, 10, 8, world)
    liquid:fillRect(2, 2, 3, 2, 1.0, "water")
    liquid:drainRect(2, 2, 3, 2, 0.4)
    local amount = select(1, liquid:getCell(3, 3))
    lurek.log.info("drainRect amount=" .. tostring(amount))
    lurek.log.info("drainRect type=" .. tostring(liquid:type()))
end
```

---

#### `LLiquidMap:fillRect`

Sets every liquid cell in a rectangular region to the same amount and kind.

```lua
LLiquidMap:fillRect(x, y, width, height, amount, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle left cell coordinate. |
| `y` | number | Rectangle top cell coordinate. |
| `width` | number | Rectangle width in cells. |
| `height` | number | Rectangle height in cells. |
| `amount` | number | Fill amount in `0.0..1.0`. |
| `kind` | any | Liquid kind as `water`, `lava`, `acid`, or a custom unsigned integer id. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(10, 10, 8, world)
    liquid:fillRect(2, 2, 3, 2, 1.0, "water")
    local amount, kind = liquid:getCell(3, 3)
    lurek.log.info("fillRect amount=" .. tostring(amount))
    lurek.log.info("fillRect kind=" .. tostring(kind))
end
```

---

#### `LLiquidMap:getAmountAt`

Samples liquid fill amount at one world-space point.

```lua
LLiquidMap:getAmountAt(worldX, worldY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `worldX` | number | World-space X coordinate. |
| `worldY` | number | World-space Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Fill amount in `0.0..1.0`, or zero outside the map or inside solid linked terrain. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(2, 3, 0.6, "acid")
    local amount = liquid:getAmountAt(20, 28)
    local outside = liquid:getAmountAt(1000, 1000)
    lurek.log.info("amountAt inside=" .. tostring(amount))
    lurek.log.info("amountAt outside=" .. tostring(outside))
end
```

---

#### `LLiquidMap:getCell`

Returns the amount and kind stored in one liquid cell.

```lua
LLiquidMap:getCell(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column (0-based). |
| `cy` | number | Cell row (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Fill amount in `0.0..1.0`. |
| LuaValue | Liquid kind as a built-in string or custom integer id; or nil when the cell is empty. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(1, 1, 0.5, "lava")
    local amount, kind = liquid:getCell(1, 1)
    lurek.log.info("getCell amount=" .. tostring(amount))
    lurek.log.info("getCell kind=" .. tostring(kind))
end
```

---

#### `LLiquidMap:getLevelAt`

Returns the top liquid surface level for the sampled column.

```lua
LLiquidMap:getLevelAt(worldX, worldY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `worldX` | number | World-space X coordinate. |
| `worldY` | number | World-space Y coordinate used to select the sampled column. |

**Returns**

| Type | Description |
|------|-------------|
| number | World-space surface Y, or nil when the sampled column is empty. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(4, 4, 1.0, "water")
    liquid:setCell(4, 3, 0.5, "water")
    local level = liquid:getLevelAt(36, 24)
    lurek.log.info("levelAt y=" .. tostring(level))
    lurek.log.info("levelAt type=" .. tostring(liquid:type()))
end
```

---

#### `LLiquidMap:loadFromBytes`

Restores liquid grid state from binary data previously produced by `toBytes`.

```lua
LLiquidMap:loadFromBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Binary liquid data. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the data matched this map's dimensions and cell size. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local bytes = liquid:toBytes()
    local clone = lurek.physics.newLiquidMap(8, 8, 8, world)
    lurek.log.info("liquid loaded=" .. tostring(clone:loadFromBytes(bytes)))
    lurek.log.info("liquid cell=" .. tostring(select(1, clone:getCell(1, 1))))
end
```

---

#### `LLiquidMap:setCell`

Sets one liquid cell amount and kind.

```lua
LLiquidMap:setCell(cx, cy, amount, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column (0-based). |
| `cy` | number | Cell row (0-based). |
| `amount` | number | Fill amount in `0.0..1.0`. |
| `kind` | any | Liquid kind as `water`, `lava`, `acid`, or a custom unsigned integer id. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(2, 3, 0.75, "water")
    local amount, kind = liquid:getCell(2, 3)
    lurek.log.info("setCell amount=" .. tostring(amount))
    lurek.log.info("setCell kind=" .. tostring(kind))
end
```

---

#### `LLiquidMap:step`

Advances the liquid simulation with deterministic per-cell flow.

```lua
LLiquidMap:step(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional controls: { gravityFlow?, sidewaysFlow?, pressureFlow?, evaporation?, maxSteps? }. |

**Returns**

| Type | Description |
|------|-------------|
| table | Step diagnostics with `movedAmount`, `activeCells`, and `dirtyChunks`. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 200)
    local terrain = lurek.physics.newTerrain(8, 8, 8, world)
    for x = 1, 6 do
        terrain:setCell(x, 6, true)
    end
    for y = 2, 6 do
        terrain:setCell(1, y, true)
        terrain:setCell(6, y, true)
    end
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world, terrain)
    liquid:fillRect(2, 2, 3, 3, 1.0, "water")
    terrain:setCell(3, 6, false)
    local stats = nil
    for _ = 1, 18 do
        stats = liquid:step({ gravityFlow = 1.0, sidewaysFlow = 0.5, pressureFlow = 0.15, maxSteps = 2 })
    end
    lurek.log.info("step moved=" .. tostring(stats.movedAmount))
    lurek.log.info("step outside=" .. tostring(liquid:getAmountAt(28, 60)))
end
```

---

#### `LLiquidMap:toBytes`

Serializes the liquid grid to binary data for save or transfer workflows.

```lua
LLiquidMap:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary liquid data. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local bytes = liquid:toBytes()
    lurek.log.info("liquid bytes=" .. tostring(#bytes))
    lurek.log.info("liquid type=" .. tostring(liquid:type()))
end
```

---

#### `LLiquidMap:type`

Returns the type name of this object ("[LLiquidMap](#lliquidmap)").

```lua
LLiquidMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LLiquidMap](#lliquidmap)". |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 2, 2, 1.0, "water")
    local kind = select(2, liquid:getCell(1, 1))
    lurek.log.info("liquid userdata=" .. tostring(liquid:type()))
    lurek.log.info("liquid kind=" .. tostring(kind))
end
```

---

#### `LLiquidMap:typeOf`

Checks whether this object matches a given type name.

```lua
LLiquidMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LLiquidMap](#lliquidmap)` and `LObject`. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(1, 1, 1.0, "water")
    local isLiquid = liquid:typeOf("LLiquidMap")
    local isObject = liquid:typeOf("LObject")
    lurek.log.info("liquid inheritance=" .. tostring(isLiquid))
    lurek.log.info("liquid object=" .. tostring(isObject))
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
    lurek.log.info("temporary shape type before=" .. before .. " after=" .. after)
    lurek.log.info("radius sample=" .. radius)
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
    lurek.log.info("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    lurek.log.info("shape type=" .. circle:getType())
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
    lurek.log.info("blast radius=" .. radius)
    lurek.log.info("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("collider kind=" .. circle:getType())
    lurek.log.info("preview bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end
```

---

#### `LPhysicsShape:getVertexCount`

Returns the number of local-space vertices for polygon, rectangle, edge, or chain shapes; circles return 0.

```lua
LPhysicsShape:getVertexCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Vertex count. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 16, 20, 4, 255, 255, 255, 255)
    img:drawRect(16, 4, 4, 20, 255, 255, 255, 255)
    local shape = lurek.physics.shapeFromImage(img, { alphaThreshold = 1, rectangleFillThreshold = 1.0 })
    local count = shape:getVertexCount()
    local x1, y1, x2, y2 = shape:getBoundingBox()
    lurek.log.info("[physics] alpha vertices=" .. tostring(count) .. " bounds=" .. tostring(x1) .. "," .. tostring(y1) .. "," .. tostring(x2) .. "," .. tostring(y2))
end
```

---

#### `LPhysicsShape:getVertices`

Returns local-space vertices as an array of `{x, y}` tables, or nil for circles.

```lua
LPhysicsShape:getVertices()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Vertex table, or nil for circles. |

**Example**

```lua
do
    local shape = lurek.physics.newRectangleShape(18, 10)
    local vertices = shape:getVertices()
    local first = vertices and vertices[1] or { x = 0, y = 0 }
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(0, 0, "static")
    lurek.physics.attachShape(body, shape)
    lurek.log.info("[physics] first vertex=" .. tostring(first.x) .. "," .. tostring(first.y) .. " count=" .. tostring(#vertices))
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
    lurek.log.info("heavy boulder density prepared for " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("sticky tire friction tuned on " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("pickup bounce tuned on " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("trigger volume type=" .. shape:getType())
    lurek.log.info("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("shape userdata=" .. shape:type())
    lurek.log.info("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
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
    lurek.log.info("shape checks shape=" .. tostring(isShape) .. " object=" .. tostring(isObject))
    lurek.log.info("body check=" .. tostring(isBody) .. " userdata=" .. shape:type())
end
```

---

## LTerrain

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTerrain:addCircle`

Adds solid terrain inside a circular region.

```lua
LTerrain:addCircle(wx, wy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Circle center X in world coordinates. |
| `wy` | number | Circle center Y in world coordinates. |
| `radius` | number | Circle radius in world units. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(false)
    terrain:addCircle(64, 64, 18)
    lurek.log.info("center=" .. tostring(terrain:getCell(8, 8)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:addRect`

Adds solid terrain across a rectangular region.

```lua
LTerrain:addRect(wx, wy, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Rectangle left X in world coordinates. |
| `wy` | number | Rectangle top Y in world coordinates. |
| `w` | number | Rectangle width in world units. |
| `h` | number | Rectangle height in world units. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(false)
    terrain:addRect(40, 40, 24, 24)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:carveCircle`

Carves a circular hole by clearing terrain cells inside the given radius.

```lua
LTerrain:carveCircle(wx, wy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Circle center X in world coordinates. |
| `wy` | number | Circle center Y in world coordinates. |
| `radius` | number | Circle radius in world units. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:carveCircle(64, 64, 18)
    lurek.log.info("center=" .. tostring(terrain:getCell(8, 8)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:carveRect`

Carves a rectangular hole by clearing all overlapping terrain cells.

```lua
LTerrain:carveRect(wx, wy, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Rectangle left X in world coordinates. |
| `wy` | number | Rectangle top Y in world coordinates. |
| `w` | number | Rectangle width in world units. |
| `h` | number | Rectangle height in world units. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:carveRect(40, 40, 24, 24)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:collapseColumns`

Removes isolated single-cell overhangs that have no support below or beside them.

```lua
LTerrain:collapseColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of unsupported single cells removed. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    lurek.log.info("collapsed=" .. tostring(terrain:collapseColumns()))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:collapseUnsupported`

Collapses unsupported connected terrain components using the requested support rule and collapse mode.

```lua
LTerrain:collapseUnsupported(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Collapse options: { support?, mode?, minComponentCells?, maxDebris?, debrisMass?, debrisRestitution? }. `support` accepts `bottom` or `border`. `mode` accepts `remove`, `spawnDebris`, `spawnDynamicChunks`, or `keepStatic`. Call `flush()` afterward to rebuild static colliders. |

**Returns**

| Type | Description |
|------|-------------|
| LTerrainCollapseUnsupportedResult | Collapse result table with removedCells, components, bodyIds, and debrisBodies fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillRect(0, 248, 256, 8, true)
    terrain:addRect(72, 72, 24, 24)
    local debris_result = terrain:collapseUnsupported({
        support = "bottom",
        mode = "spawnDebris",
        minComponentCells = 2,
        maxDebris = 2,
    })
    local terrain2 = lurek.physics.newTerrain(32, 32, 8, world)
    terrain2:addRect(72, 72, 24, 24)
    local chunk_result = terrain2:collapseUnsupported({
        support = "bottom",
        mode = "spawnDynamicChunks",
        minComponentCells = 2,
    })
    terrain:flush()
    lurek.log.info("debris_components=" .. tostring(debris_result.components))
    lurek.log.info("debris_bodies=" .. tostring(#debris_result.debrisBodies))
    lurek.log.info("chunk_bodies=" .. tostring(#chunk_result.bodyIds))
end
```

---

#### `LTerrain:damageCircle`

Carves a circular hole and can immediately collapse unsupported terrain with policy options.

```lua
LTerrain:damageCircle(wx, wy, radius, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | Circle center X in world coordinates. |
| `wy` | number | Circle center Y in world coordinates. |
| `radius` | number | Circle radius in world units. |
| `opts?` | table | Optional damage settings: { collapse?, support?, mode?, minComponentCells?, maxDebris?, debrisMass?, debrisRestitution? }. `support` accepts `bottom` or `border`. `mode` accepts `remove`, `spawnDebris`, `spawnDynamicChunks`, or `keepStatic`. `collapse` defaults to false. |

**Returns**

| Type | Description |
|------|-------------|
| LTerrainDamageCircleResult | Collapse result table with removedCells, components, bodyIds, and debrisBodies fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    local result = terrain:damageCircle(64, 64, 18, {
        collapse = true,
        support = "bottom",
        mode = "remove",
        minComponentCells = 2,
    })
    lurek.log.info("removed=" .. tostring(result.removedCells))
    lurek.log.info("components=" .. tostring(result.components))
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
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("cell=" .. tostring(terrain:getCell(10, 10)))
end
```

---

#### `LTerrain:flush`

Regenerates physics colliders from the current terrain grid state and returns rebuild diagnostics.

```lua
LTerrain:flush(maxDirtyChunks)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `maxDirtyChunks?` | number | Optional maximum number of dirty chunks to rebuild in this call. When omitted, all pending dirty chunks are rebuilt. |

**Returns**

| Type | Description |
|------|-------------|
| LTerrainFlushResult | Rebuild diagnostics with dirtyChunksRebuilt, dirtyChunksRemaining, bodiesDestroyed, bodiesCreated, and elapsedMicros fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(64, 16, 16, world)
    terrain:fillAll(true)
    local first = terrain:flush(2)
    local second = terrain:flush()
    lurek.log.info("rebuilt=" .. tostring(first.dirtyChunksRebuilt))
    lurek.log.info("remaining=" .. tostring(first.dirtyChunksRemaining))
    lurek.log.info("final_remaining=" .. tostring(second.dirtyChunksRemaining))
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
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("loaded=" .. tostring(clone:loadFromBytes(bytes)))
    lurek.log.info("cell=" .. tostring(clone:getCell(0, 0)))
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
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end
```

---

#### `LTerrain:solidPositions`

Returns all solid cell centers as a table of `{x, y}` entries in world coordinates.

```lua
LTerrain:solidPositions()
```

**Returns**

| Type | Description |
|------|-------------|
| LTerrainSolidPositionsResult | Array of tables with x and y fields (world-space centers). |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    lurek.log.info("count=" .. tostring(#solids))
    if solids[1] then
        lurek.log.info("first=" .. tostring(solids[1].x) .. " " .. tostring(solids[1].y))
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
    lurek.log.info("count=" .. tostring(#debris))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("bytes=" .. tostring(#bytes))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
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
    lurek.log.info("bytes=" .. tostring(#pixels))
    lurek.log.info("type=" .. tostring(terrain:type()))
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
    lurek.log.info("terrain userdata=" .. terrain:type())
    lurek.log.info("terrain inheritance=" .. tostring(terrain:typeOf("LTerrain")))
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
    lurek.log.info("terrain check=" .. tostring(isTerrain) .. " object=" .. tostring(isObject))
    lurek.log.info("terrain userdata=" .. terrain:type())
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end
```

---

#### `LWorld:addFan`

Creates a directional fan helper around the flow-field system.

```lua
LWorld:addFan(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Fan options such as `x`, `y`, `radius`, `directionVector`, and `widthAngle`. |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowStream](#lflowstream) | New flow field handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local fan = world:addFan({
        x = 80,
        y = 80,
        radius = 72,
        widthAngle = 70,
        directionVector = { x = 1, y = -0.2 },
        strength = 120,
    })
    local sample = world:sampleFlow(120, 72)
    lurek.log.info("[physics] fan id=" .. tostring(fan:getId()) .. " sample=" .. string.format("%.2f,%.2f", sample.vx, sample.vy))
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
    lurek.log.info("fixture=" .. tostring(fid))
    lurek.log.info("count=" .. tostring(world:fixtureCount(body:getId())))
end
```

---

#### `LWorld:addFlowField`

Creates one authored flow field and returns a handle for later mutation.

```lua
LWorld:addFlowField(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Flow field authoring table. |

**Returns**

| Type | Description |
|------|-------------|
| [LFlowStream](#lflowstream) | New flow field handle. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 220)
    local field = world:addFlowField({
        name = "canyon_wind",
        geometry = "path",
        points = {
            { x = 80, y = 180 },
            { x = 200, y = 160 },
            { x = 340, y = 190 },
        },
        width = 70,
        strength = 180,
        direction = "alongPath",
        application = "acceleration",
    })
    local projectile = world:newCircleBody(120, 120, 4, "dynamic")
    projectile:setBullet(true)
    projectile:applyImpulse(420, -160)
    for _ = 1, 30 do
        world:step(1 / 60)
    end
    local x, y = projectile:getPosition()
    lurek.log.info("[physics] flow field id=" .. tostring(field:getId()) .. " projectile=" .. tostring(math.floor(x)) .. "," .. tostring(math.floor(y)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end
```

---

#### `LWorld:addGravityVector`

Adds an extra directional gravity vector that is summed with world gravity when no non-additive zone override is active.

```lua
LWorld:addGravityVector(gx, gy, layerMask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Horizontal acceleration in world units per second squared. |
| `gy` | number | Vertical acceleration in world units per second squared. |
| `layerMask?` | number | Optional body layer mask, defaults to all layers. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable gravity vector ID. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(120, 120, 10, "dynamic")
    local vector_id = world:addGravityVector(0, 180)
    world:step(1 / 60)
    lurek.log.info("gravity vector id=" .. vector_id .. " velocity_y=" .. select(2, body:getVelocity()))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end
```

---

#### `LWorld:beamAll`

Returns all instant beam hits in deterministic distance order.

```lua
LWorld:beamAll(x, y, dx, dy, range, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Beam origin X. |
| `y` | number | Beam origin Y. |
| `dx` | number | Beam direction X (does not need to be normalized). |
| `dy` | number | Beam direction Y. |
| `range` | number | Maximum beam travel distance. Must be finite and > 0. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. `includeSensors` defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldBeamAllResult | Array of hit tables {bodyId, x, y, normalX, normalY, distance, segmentIndex}. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 3 do
        local body = world:newCircleBody(90 + i * 45, 320, 10, "static")
        body:setLayer(0x2)
    end
    local hits = world:beamAll(60, 320, 1, 0, 240, { layer = 0x1, mask = 0x2 })
    lurek.log.info("beam_all_count=" .. tostring(#hits))
    if hits[1] then
        lurek.log.info("beam_all_first=" .. tostring(hits[1].bodyId) .. " " .. tostring(hits[1].distance))
    end
    if hits[2] then
        lurek.log.info("beam_all_second=" .. tostring(hits[2].bodyId) .. " " .. tostring(hits[2].distance))
    end
end
```

---

#### `LWorld:beamClosest`

Returns only the closest instant beam hit, or nil if nothing blocks the beam.

```lua
LWorld:beamClosest(x, y, dx, dy, range, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Beam origin X. |
| `y` | number | Beam origin Y. |
| `dx` | number | Beam direction X (does not need to be normalized). |
| `dy` | number | Beam direction Y. |
| `range` | number | Maximum beam travel distance. Must be finite and > 0. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. `includeSensors` defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldBeamClosestResult | Hit info {bodyId, x, y, normalX, normalY, distance, segmentIndex} or nil if no hit. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local shooter = world:newCircleBody(50, 260, 8, "dynamic")
    shooter:setLayer(0x2)
    local target = world:newCircleBody(190, 260, 14, "static")
    target:setLayer(0x2)
    local hit = world:beamClosest(50, 260, 1, 0, 240, {
        excludeBody = shooter:getId(),
        layer = 0x1,
        mask = 0x2,
    })
    if hit then
        lurek.log.info("beam_closest_body=" .. tostring(hit.bodyId))
        lurek.log.info("beam_closest_point=" .. tostring(hit.x) .. " " .. tostring(hit.y))
        lurek.log.info("beam_closest_distance=" .. tostring(hit.distance))
    else
        lurek.log.info("beam_closest_body=" .. tostring(nil))
    end
end
```

---

#### `LWorld:castBeam`

Casts an instant beam and returns hit plus segment data for gameplay or rendering.

```lua
LWorld:castBeam(x, y, dx, dy, range, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Beam origin X. |
| `y` | number | Beam origin Y. |
| `dx` | number | Beam direction X (does not need to be normalized). |
| `dy` | number | Beam direction Y. |
| `range` | number | Maximum beam travel distance. Must be finite and > 0. |
| `opts?` | table | Optional beam options: {mode?, maxHits?, thickness?, reflect?, maxBounces?, energy?, minEnergy?, layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. `mode` accepts `closest`, `all`, or `pierce` and defaults to `closest`. Reflection currently requires `mode = "closest"`. `reflect` defaults to false. `maxBounces` defaults to 8, `energy` defaults to 1.0, and `minEnergy` defaults to 0.0. `includeSensors` defaults to true. `thickness` must be `0` until thick beam support lands. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldCastBeamResult | Trace table {hits, segments, reachedMaxRange}. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(120, 120, 8, 80, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(0.75)
    local blocker = world:newBody(120, 40, 80, 8, "static")
    local trace = world:castBeam(40, 120, 1, 0, 260, {
        reflect = true,
        maxBounces = 2,
        energy = 1.0,
        minEnergy = 0.2,
    })
    lurek.log.info("beam_hits=" .. tostring(#trace.hits))
    lurek.log.info("beam_segments=" .. tostring(#trace.segments))
    lurek.log.info("beam_reached_max=" .. tostring(trace.reachedMaxRange))
    if trace.hits[1] then
        lurek.log.info("beam_first=" .. tostring(trace.hits[1].bodyId) .. " reflected=" .. tostring(trace.hits[1].reflected))
    end
    if trace.hits[2] then
        lurek.log.info("beam_second=" .. tostring(trace.hits[2].bodyId) .. " " .. tostring(trace.hits[2].distance))
    end
    lurek.log.info("blocker=" .. tostring(blocker:getId()))
end
```

---

#### `LWorld:castCircle`

Sweeps a circle along a direction and returns the first collider hit.

```lua
LWorld:castCircle(x, y, radius, dx, dy, maxDist, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Circle center X at the start of the sweep. |
| `y` | number | Circle center Y at the start of the sweep. |
| `radius` | number | Circle radius in world units. |
| `dx` | number | Sweep direction X (does not need to be normalized). |
| `dy` | number | Sweep direction Y (does not need to be normalized). |
| `maxDist` | number | Maximum sweep travel distance. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

**Returns**

| Type | Description |
|------|-------------|
| table | Hit info {bodyId, x, y, normalX, normalY, toi, safeFraction} or nil if no hit. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local sensor = world:newBody(120, 100, 8, 80, "sensor")
    local wall = world:newBody(160, 100, 8, 80, "static")
    local with_sensor = world:castCircle(40, 100, 6, 1, 0, 200, { includeSensors = true })
    local solid_hit = world:castCircle(40, 100, 6, 1, 0, 200, { includeSensors = false })
    lurek.log.info("sensor_first=" .. tostring(with_sensor and with_sensor.bodyId) .. " solid_owner=" .. tostring(sensor:getId()))
    lurek.log.info("solid_first=" .. tostring(solid_hit and solid_hit.bodyId) .. " wall_owner=" .. tostring(wall:getId()))
    lurek.log.info("solid_normal=" .. tostring(solid_hit and solid_hit.normalX) .. "," .. tostring(solid_hit and solid_hit.normalY))
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
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    world:clear()
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("count=" .. tostring(count))
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
    lurek.log.info("data=" .. tostring(world:getBodyData(player:getId())))
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
    lurek.log.info("normal=" .. tostring(world:getBodyOneWay(platform:getId())))
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
    lurek.log.info("count=" .. tostring(count))
end
```

---

#### `LWorld:clearFlowFields`

Disables every authored flow field in the world.

```lua
LWorld:clearFlowFields()
```

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 20,
        h = 20,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 15,
    })
    world:clearFlowFields()
    lurek.log.info("[physics] flow count after clear=" .. tostring(world:getStats().flowFields))
    lurek.log.info("[physics] first disabled=" .. tostring(not world:getFlowField(field:getId()).enabled))
end
```

---

#### `LWorld:clearGravityVectors`

Removes all additive gravity vectors from the world.

```lua
LWorld:clearGravityVectors()
```

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    world:addGravityVector(40, 0)
    world:addGravityVector(0, -40)
    world:clearGravityVectors()
    lurek.log.info("active gravity vectors=" .. world:getStats().gravityVectors)
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
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    world:destroyBody(body:getId())
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
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
    lurek.log.info("before=" .. tostring(world:jointCount()))
    world:destroyJoint(jid)
    lurek.log.info("after=" .. tostring(world:jointCount()))
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
    if ok then lurek.log.info("image", img:type()) else lurek.log.info("drawDebug skipped: " .. tostring(err)) end
end
```

---

#### `LWorld:drawFlowDebug`

Draws flow-field centerlines and sampled arrows into an ImageData target.

```lua
LWorld:drawFlowDebug(target, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | Mutable target image. |
| `opts?` | table | Optional table with `arrowSpacing`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    world:addFlowField({
        geometry = "rect",
        x = 10,
        y = 10,
        w = 30,
        h = 20,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 25,
    })
    local img = lurek.image.newImageData(64, 64)
    world:drawFlowDebug(img, { arrowSpacing = 16 })
    local _, _, _, a = img:getPixel(10, 10)
    lurek.log.info("[physics] flow debug alpha=" .. tostring(a))
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
    lurek.log.info("fixture count=" .. world:fixtureCount(body:getId()))
    lurek.log.info("body type=" .. body:getType())
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
    lurek.log.info("count=" .. tostring(count))
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
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

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
    lurek.log.info("hit=" .. tostring(hitId))
    lurek.log.info("miss=" .. tostring(missId))
end
```

---

#### `LWorld:getBodyCCD`

Returns whether continuous collision detection is enabled on a body. This is the world-level alias for `[LBody](#lbody):isBullet`.

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
    lurek.log.info("ccd=" .. tostring(world:getBodyCCD(bullet:getId())))
    lurek.log.info("velocity=" .. tostring(bullet:getVelocity()))
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
    lurek.log.info("count=" .. tostring(#contacts))
    if contacts[1] then
        lurek.log.info("first=" .. tostring(contacts[1].bodyA) .. " " .. tostring(contacts[1].bodyB))
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
    lurek.log.info("arena bodies=" .. world:getBodyCount())
    lurek.log.info("player=" .. player:getType() .. " floor=" .. floor:getType() .. " pickup=" .. pickup:getType())
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
    lurek.log.info("tag=" .. tostring(data.tag))
    lurek.log.info("hp=" .. tostring(data.hp))
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
    lurek.log.info("count=" .. tostring(#ids))
    lurek.log.info("first=" .. tostring(ids[1]))
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
    lurek.log.info("queried one-way normal=" .. nx .. "," .. ny)
    lurek.log.info("platform=" .. platform:getType() .. " helper=" .. coin:getType())
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
    lurek.log.info("body type lookup=" .. world:getBodyType(body:getId()) .. " id=" .. body:getId())
    lurek.log.info("role=" .. data.role .. " world bodies=" .. world:getBodyCount())
end
```

---

#### `LWorld:getCcdSubsteps`

Returns the maximum number of CCD substeps used for bullet bodies in this world.

```lua
LWorld:getCcdSubsteps()
```

**Returns**

| Type | Description |
|------|-------------|
| number | CCD substep count. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(180, 90, 6, 80, "static")
    local projectile = world:newCircleBody(40, 90, 2, "dynamic")
    world:setCcdSubsteps(6)
    projectile:setBullet(true)
    local remainder = world:stepFixed(1 / 30, 1 / 120, 8)
    lurek.log.info("ccd_substeps=" .. tostring(world:getCcdSubsteps()) .. " remainder=" .. tostring(remainder))
    lurek.log.info("wall=" .. wall:getType() .. " projectile_x=" .. tostring(select(1, projectile:getPosition())))
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
    lurek.log.info("count=" .. tostring(count))
end
```

---

#### `LWorld:getCollisionGroupMask`

Returns one row of the 16-group collision matrix.

```lua
LWorld:getCollisionGroupMask(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Source collision group index, 0..15. |

**Returns**

| Type | Description |
|------|-------------|
| number | Target group bitmask. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    world:setCollisionGroupMask(3, 0x9)
    local mask = world:getCollisionGroupMask(3)
    world:setCollisionPair(3, 0, false)
    local pair = world:getCollisionPair(3, 0)
    lurek.log.info("mask=" .. tostring(mask))
    lurek.log.info("pair after override=" .. tostring(pair))
end
```

---

#### `LWorld:getCollisionPair`

Returns whether collisions are enabled between two world-level collision groups.

```lua
LWorld:getCollisionPair(groupA, groupB)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `groupA` | number | First collision group index, 0..15. |
| `groupB` | number | Second collision group index, 0..15. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the pair is enabled in both matrix directions. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local default_pair = world:getCollisionPair(0, 1)
    world:setCollisionPair(0, 1, false)
    local disabled_pair = world:getCollisionPair(0, 1)
    world:setCollisionPair(0, 1, true)
    lurek.log.info("default=" .. tostring(default_pair))
    lurek.log.info("disabled=" .. tostring(disabled_pair))
    lurek.log.info("restored pair=" .. tostring(world:getCollisionPair(0, 1)))
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
    lurek.log.info("count=" .. tostring(#contacts))
    lurek.log.info("ball=" .. tostring(ball:getId()))
    if contacts[1] then
        lurek.log.info("touching=" .. tostring(contacts[1].isTouching))
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
    lurek.log.info("count=" .. tostring(count))
end
```

---

#### `LWorld:getFixtureMaterial`

Returns the current material table for one fixture.

```lua
LWorld:getFixtureMaterial(bodyId, fixtureIndex)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |

**Returns**

| Type | Description |
|------|-------------|
| table | Material table with solver-backed and gameplay metadata fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(120, 120, 20, 20, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.2, false, 6)
    world:setFixtureMaterial(body:getId(), fixture, lurek.physics.newMaterial({
        name = "ice",
        density = 0.9,
        friction = 0.05,
        restitution = 0.15,
        stickiness = 0.0,
        adhesion = 0.0,
        buoyancy = 0.2,
    }))
    local material = world:getFixtureMaterial(body:getId(), fixture)
    lurek.log.info("name=" .. tostring(material.name))
    lurek.log.info("friction=" .. tostring(material.friction))
    lurek.log.info("buoyancy=" .. tostring(material.buoyancy))
end
```

---

#### `LWorld:getFlowField`

Returns one authored flow field table by id, or nil when missing.

```lua
LWorld:getFlowField(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Flow field id. |

**Returns**

| Type | Description |
|------|-------------|
| table | Flow field descriptor table with geometry, enabled, strength, application, combine, and layer-mask fields. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        name = "fan",
        geometry = "circle",
        x = 64,
        y = 64,
        radius = 32,
        direction = "radialOut",
        strength = 35,
    })
    field:setEnabled(false)
    local info = world:getFlowField(field:getId())
    lurek.log.info("[physics] flow geometry=" .. tostring(info.geometry) .. " enabled=" .. tostring(info.enabled))
    lurek.log.info("[physics] flow strength=" .. tostring(info.strength))
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
    lurek.log.info("gravity=" .. tostring(gx) .. " " .. tostring(gy))
    world:setGravity(10, 800)
    lurek.log.info("updated=" .. tostring(world:getGravity()))
end
```

---

#### `LWorld:getGravityVector`

Returns an additive gravity vector by ID, or nil when no active vector exists.

```lua
LWorld:getGravityVector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with id, gx, gy, layerMask, and enabled fields. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local vector_id = world:addGravityVector(12, -18, 0x4)
    local vector = world:getGravityVector(vector_id)
    lurek.log.info("gravity_vector=" .. tostring(vector.id) .. " " .. tostring(vector.gx) .. " " .. tostring(vector.gy))
    lurek.log.info("layer_mask=" .. tostring(vector.layerMask))
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
    lurek.log.info("bodies=" .. tostring(world:getJointBodies(jid)))
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
    lurek.log.info("break_force=" .. tostring(world:getJointBreakForce(jid)))
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
    lurek.log.info("count=" .. tostring(#ids))
    lurek.log.info("first=" .. tostring(ids[1]))
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
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
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
    lurek.log.info("motor_speed=" .. tostring(world:getJointMotorSpeed(jid)))
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
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jid)))
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
    lurek.log.info("builder meter=" .. world:getMeter() .. " bridge_px=" .. bridgeSpanPixels)
    lurek.log.info("ramp height px=" .. rampHeightPixels)
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
    lurek.log.info("solver iterations=" .. world:getSolverIterations())
    lurek.log.info("scene bodies=" .. world:getBodyCount() .. " floor=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
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
| LWorldGetStatsResult | Stats table with bodies, bodySlots, colliders, joints, jointSlots, zones, gravityVectors, sleepingBodies. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local stats = world:getStats()
    lurek.log.info("bodies=" .. tostring(stats.bodies) .. " " .. tostring("slots") .. " " .. tostring(stats.bodySlots) .. " " .. tostring("colliders") .. " " .. tostring(stats.colliders))
    lurek.log.info("joints=" .. tostring(stats.joints) .. " " .. tostring("joint_slots") .. " " .. tostring(stats.jointSlots))
    lurek.log.info("zones=" .. tostring(stats.zones) .. " " .. tostring("sleeping") .. " " .. tostring(stats.sleepingBodies))
    body:destroy()
    stats = world:getStats()
    lurek.log.info("after_destroy=" .. tostring(stats.bodies) .. " " .. tostring("slots") .. " " .. tostring(stats.bodySlots))
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
    lurek.log.info("count=" .. tostring(count))
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
    lurek.log.info("has_body=" .. tostring(world:hasBody(body:getId())))
    body:destroy()
    lurek.log.info("has_body_after_destroy=" .. tostring(world:hasBody(body:getId())))
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
    lurek.log.info("has_joint=" .. tostring(world:hasJoint(jid)))
    world:destroyJoint(jid)
    lurek.log.info("has_joint_after_destroy=" .. tostring(world:hasJoint(jid)))
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
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
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
    lurek.log.info("joint_count=" .. tostring(world:jointCount()))
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
    lurek.log.info("created=" .. tostring(#ids))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end
```

---

#### `LWorld:newBody`

Creates a new physics body at the given position with the specified type and dimensions.

```lua
LWorld:newBody(x, y, bodyType, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

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
    lurek.log.info("id=" .. tostring(body:getId()))
    lurek.log.info("type=" .. tostring(body:getType()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end
```

---

#### `LWorld:newChainBody`

Creates a new body with a chain (polyline) collider. Useful for terrain edges.

```lua
LWorld:newChainBody(x, y, vertices, closed, bodyType, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Body X position in world coordinates. |
| `y` | number | Body Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `closed` | boolean | If true, connects the last vertex back to the first. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static", {
        material = lurek.physics.newMaterial({
            name = "track",
            friction = 0.9,
            restitution = 0.0,
            surfaceType = "ground",
        }),
        layer = 0x10,
        mask = 0x1F,
    })
    local bike = world:newCircleBody(120, 420, 8, "dynamic")
    bike:setVelocity(30, 0)
    world:step(1 / 60)
    lurek.log.info("track body type=" .. ground:getType() .. " start_y=" .. select(2, ground:getPosition()))
    lurek.log.info("bike pos=" .. select(1, bike:getPosition()) .. "," .. select(2, bike:getPosition()))
    lurek.log.info("material=" .. tostring(ground:getMaterial().surfaceType) .. " mask=" .. tostring(ground:getMask()))
end
```

---

#### `LWorld:newCircleBody`

Creates a new body with a circle collider already attached.

```lua
LWorld:newCircleBody(x, y, radius, bodyType, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `radius` | number | Circle radius in world units. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local rubber = lurek.physics.newMaterial({
        name = "rubber",
        density = 1.1,
        friction = 0.85,
        restitution = 0.7,
    })
    local ball = world:newCircleBody(200, 100, 16, "dynamic", {
        material = rubber,
        bullet = true,
        layer = 0x2,
        mask = 0x3,
    })
    local target = world:newBody(200, 260, "static")
    ball:setVelocity(15, -20)
    world:step(1 / 60)
    lurek.log.info("projectile pos=" .. select(1, ball:getPosition()) .. "," .. select(2, ball:getPosition()))
    lurek.log.info("projectile size=" .. ball:getWidth() .. "x" .. ball:getHeight() .. " target=" .. target:getType())
    lurek.log.info("projectile bullet=" .. tostring(ball:isBullet()) .. " layer=" .. tostring(ball:getLayer()))
end
```

---

#### `LWorld:newEdgeBody`

Creates a new body with an edge (line segment) collider between two local points.

```lua
LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bodyType, opts)
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
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static", {
        material = lurek.physics.newMaterial({
            name = "rail",
            friction = 0.4,
            restitution = 0.0,
            beamReflectivity = 0.8,
        }),
        layer = 0x8,
        mask = 0x2,
    })
    local player = world:newCircleBody(100, 420, 10, "dynamic")
    player:setVelocity(40, 0)
    world:step(1 / 60)
    lurek.log.info("ledge body type=" .. wall:getType() .. " pos_y=" .. select(2, wall:getPosition()))
    lurek.log.info("runner pos=" .. select(1, player:getPosition()) .. "," .. select(2, player:getPosition()))
    lurek.log.info("material=" .. tostring(wall:getMaterial().name) .. " layer=" .. tostring(wall:getLayer()))
end
```

---

#### `LWorld:newPolygonBody`

Creates a new body with a convex polygon collider defined by vertex pairs.

```lua
LWorld:newPolygonBody(x, y, vertices, bodyType, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |
| `opts?` | table | Optional body options: { material?, bullet?, layer?, mask? }. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic", {
        material = lurek.physics.newMaterial({
            name = "wedge",
            density = 1.3,
            friction = 0.7,
            restitution = 0.2,
        }),
        bullet = true,
        layer = 0x4,
        mask = 0x7,
    })
    tri:setAngularVelocity(1.5)
    world:step(1 / 60)
    local x, y = tri:getPosition()
    lurek.log.info("falling wedge pos=" .. x .. "," .. y)
    lurek.log.info("body type=" .. tri:getType() .. " angle=" .. tri:getAngle())
    lurek.log.info("material=" .. tostring(tri:getMaterial().name) .. " bullet=" .. tostring(tri:isBullet()))
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
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

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
    lurek.log.info("count=" .. tostring(#found))
    lurek.log.info("first=" .. tostring(found[1]))
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
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

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
        lurek.log.info("body=" .. tostring(hit.bodyId))
        lurek.log.info("point=" .. tostring(hit.x) .. " " .. tostring(hit.y))
        lurek.log.info("normal=" .. tostring(hit.normalX) .. " " .. tostring(hit.normalY))
    else
        lurek.log.info("body=" .. tostring(nil))
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
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

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
    lurek.log.info("count=" .. tostring(#hits))
    if hits[1] then
        lurek.log.info("first=" .. tostring(hits[1].bodyId) .. " " .. tostring(hits[1].x) .. " " .. tostring(hits[1].y))
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
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?, excludeBody?}. |

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
        lurek.log.info("body=" .. tostring(hit.bodyId))
        lurek.log.info("point=" .. tostring(hit.x) .. " " .. tostring(hit.y))
        lurek.log.info("toi=" .. tostring(hit.toi))
    else
        lurek.log.info("body=" .. tostring(nil))
    end
end
```

---

#### `LWorld:reflectBodyVelocity`

Reflects a body's current velocity around a supplied world-space surface normal.

```lua
LWorld:reflectBodyVelocity(bodyId, normalX, normalY, coefficient)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | Body ID to update. |
| `normalX` | number | Surface normal X component in world space. |
| `normalY` | number | Surface normal Y component in world space. |
| `coefficient` | number | Speed multiplier applied after the reflection in the range 0..1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the body velocity was updated, false for inactive bodies, zero-speed bodies, or degenerate normals. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local projectile = world:newCircleBody(40, 90, 4, "dynamic")
    projectile:setVelocity(120, -40)
    local ok = world:reflectBodyVelocity(projectile:getId(), 0, 1, 0.5)
    local vx, vy = projectile:getVelocity()
    lurek.log.info("reflected=" .. tostring(ok))
    lurek.log.info("velocity=" .. tostring(vx) .. "," .. tostring(vy))
    lurek.log.info("projectile=" .. tostring(projectile:getId()))
end
```

---

#### `LWorld:removeFlowField`

Disables and removes one authored flow field by id.

```lua
LWorld:removeFlowField(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Flow field id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the field existed and was active. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 32,
        h = 32,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    world:removeFlowField(field:getId())
    local info = world:getFlowField(field:getId())
    lurek.log.info("[physics] removed=" .. tostring(info ~= nil and not info.enabled))
end
```

---

#### `LWorld:removeGravityVector`

Removes one additive gravity vector so it no longer affects future steps.

```lua
LWorld:removeGravityVector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if an active vector was removed. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local vector_id = world:addGravityVector(0, 120)
    local removed = world:removeGravityVector(vector_id)
    local vector = world:getGravityVector(vector_id)
    lurek.log.info("removed=" .. tostring(removed) .. " active=" .. tostring(vector ~= nil))
end
```

---

#### `LWorld:resetCollisionGroups`

Restores all 16 collision groups so every group can collide with every other group.

```lua
LWorld:resetCollisionGroups()
```

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    world:setCollisionPair(0, 1, false)
    local disabled = world:getCollisionPair(0, 1)
    world:resetCollisionGroups()
    local restored = world:getCollisionPair(0, 1)
    lurek.log.info("disabled=" .. tostring(disabled))
    lurek.log.info("restored=" .. tostring(restored) .. " mask=" .. world:getCollisionGroupMask(0))
end
```

---

#### `LWorld:resetWorld`

Fully resets the world to its post-construction state.

```lua
LWorld:resetWorld()
```

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 100)
    world:setGravity(5, 6)
    world:setMeter(96)
    world:setSolverIterations(12)
    world:newBody(0, 0, "dynamic")
    world:resetWorld()
    local gx, gy = world:getGravity()
    lurek.log.info("reset bodies=" .. world:getBodyCount() .. " joints=" .. world:jointCount())
    lurek.log.info("reset gravity=" .. gx .. "," .. gy)
    lurek.log.info("reset meter=" .. world:getMeter() .. " iterations=" .. world:getSolverIterations())
end
```

---

#### `LWorld:sampleFlow`

Samples combined flow at a world position.

```lua
LWorld:sampleFlow(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World-space x position. |
| `y` | number | World-space y position. |
| `opts?` | table | Optional table with `layerMask`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Flow sample table with `vx`, `vy`, `magnitude`, `intensity`, and `sources`. |

**Example**

```lua
do
    local world = lurek.physics.newWorld(0, 0)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 120,
        h = 60,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 30,
    })
    local sample = world:sampleFlow(20, 20)
    lurek.log.info("[physics] flow sample=" .. string.format("%.2f,%.2f", sample.vx, sample.vy))
end
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
        lurek.log.info("callback=" .. tostring(bodyA) .. " " .. tostring(bodyB))
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(contactCount))
end
```

---

#### `LWorld:setBodyCCD`

Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling. This is the world-level alias for `[LBody](#lbody):setBullet`.

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
    lurek.log.info("ccd=" .. tostring(world:getBodyCCD(bullet:getId())))
    lurek.log.info("id=" .. tostring(bullet:getId()))
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
    lurek.log.info("tag=" .. tostring(data.tag))
    lurek.log.info("hp=" .. tostring(data.hp))
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
    lurek.log.info("one-way normal=" .. nx .. "," .. ny)
    lurek.log.info("player above platform y=" .. select(2, player:getPosition()))
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
    lurek.log.info("builder converted type=" .. world:getBodyType(body:getId()))
    lurek.log.info("placement=" .. body:getX() .. "," .. body:getY())
end
```

---

#### `LWorld:setCcdSubsteps`

Sets the maximum number of CCD substeps. Increase this when fast bullet bodies still need more reliable thin-wall resolution.

```lua
LWorld:setCcdSubsteps(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum CCD substeps. Values below 1 clamp to 1. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(40, 80, 3, "dynamic")
    world:setCcdSubsteps(4)
    bullet:setBullet(true)
    bullet:setVelocity(1200, 0)
    lurek.log.info("ccd_substeps=" .. tostring(world:getCcdSubsteps()))
    lurek.log.info("bullet_mode=" .. tostring(bullet:isBullet()))
end
```

---

#### `LWorld:setCollisionGroupMask`

Replaces one row of the 16-group collision matrix.

```lua
LWorld:setCollisionGroupMask(group, mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Source collision group index, 0..15. |
| `mask` | number | Target group bitmask in 0..0xFFFF. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 6, "static")
    body:setCollisionGroup(2)
    world:setCollisionGroupMask(0, 0x4)
    world:step(1 / 60)
    local hits = world:queryAABB(0, 0, 20, 20, { group = 0 })
    lurek.log.info("mask=" .. tostring(world:getCollisionGroupMask(0)))
    lurek.log.info("query hits=" .. #hits .. " body_group=" .. body:getCollisionGroup())
end
```

---

#### `LWorld:setCollisionPair`

Enables or disables collisions between two world-level collision groups.

```lua
LWorld:setCollisionPair(groupA, groupB, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `groupA` | number | First collision group index, 0..15. |
| `groupB` | number | Second collision group index, 0..15. |
| `enabled` | boolean | True to allow collisions, false to block them. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local player = world:newCircleBody(0, 0, 8, "dynamic")
    local pickup = world:newCircleBody(0, 0, 8, "static")
    player:setCollisionGroup(0)
    pickup:setCollisionGroup(1)
    world:setCollisionPair(0, 1, false)
    lurek.log.info("pair=" .. tostring(world:getCollisionPair(0, 1)))
    lurek.log.info("player=" .. player:getCollisionGroup() .. " pickup=" .. pickup:getCollisionGroup())
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
        lurek.log.info("callback=" .. tostring(bodyA) .. " " .. tostring(bodyB))
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(endCount))
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
| `friction` | number | New friction value (0..1 typical range). |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
end
```

---

#### `LWorld:setFixtureMaterial`

Assigns a reusable material table to one fixture.

```lua
LWorld:setFixtureMaterial(bodyId, fixtureIndex, material)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `material` | table | Material table created by `lurek.physics.newMaterial(...)` or an equivalent options table. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, 20, 20, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 0.6, 0.2, 0.1, false, 8)
    local mirror = lurek.physics.newMaterial({
        name = "mirror",
        density = 0.6,
        friction = 0.1,
        restitution = 0.05,
        beamReflectivity = 1.0,
        projectileReflectivity = 0.2,
        surfaceType = "glass",
    })
    world:setFixtureMaterial(body:getId(), fixture, mirror)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("material=" .. tostring(world:getFixtureMaterial(body:getId(), fixture).name))
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
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
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
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
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
    lurek.log.info("gravity=" .. tostring(gx) .. " " .. tostring(gy))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end
```

---

#### `LWorld:setGravityVector`

Replaces the direction, strength, and optional layer mask of an existing additive gravity vector.

```lua
LWorld:setGravityVector(id, gx, gy, layerMask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |
| `gx` | number | Horizontal acceleration in world units per second squared. |
| `gy` | number | Vertical acceleration in world units per second squared. |
| `layerMask?` | number | Optional body layer mask, defaults to all layers. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local ship = world:newCircleBody(160, 160, 8, "dynamic")
    local vector_id = world:addGravityVector(80, 0)
    world:setGravityVector(vector_id, -80, 0)
    world:step(1 / 60)
    lurek.log.info("switched gravity vector=" .. vector_id .. " vx=" .. select(1, ship:getVelocity()))
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
    lurek.log.info("break_force=" .. tostring(world:getJointBreakForce(jid)))
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
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
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
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
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
    lurek.log.info("motor_speed=" .. tostring(world:getJointMotorSpeed(jid)))
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
    lurek.log.info("platformer meter=" .. world:getMeter() .. " player_width_m=" .. playerWidthMeters)
    lurek.log.info("jump arc preview px=" .. jumpArcPixels)
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
    lurek.log.info("joint=" .. tostring(jid))
    lurek.log.info("type=" .. tostring(world:getJointType(jid)))
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
    lurek.log.info("solver iterations=" .. world:getSolverIterations())
    lurek.log.info("crate velocity y=" .. select(2, crate:getVelocity()))
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
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
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
    lurek.log.info("position=" .. tostring(body:getPosition()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
end
```

---

#### `LWorld:stepFixed`

Performs fixed-timestep physics stepping, consuming accumulated time. Use this for frame pacing; bullet CCD still matters for thin barriers.

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
    lurek.log.info("fixed-step remainder=" .. remainder .. " pos=" .. x .. "," .. y)
    lurek.log.info("post-step velocity=" .. vx .. "," .. vy .. " iterations=" .. world:getSolverIterations())
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
    lurek.log.info("door width meters=" .. doorWidthMeters)
    lurek.log.info("hero radius meters=" .. heroRadiusMeters)
    lurek.log.info("reference pixels=" .. world:toPixels(1.5))
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
    lurek.log.info("rope length px=" .. ropeLengthPixels)
    lurek.log.info("ledge depth px=" .. ledgeDepthPixels)
    lurek.log.info("reverse sample meters=" .. world:toPhysics(160))
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
    lurek.log.info("world userdata=" .. world:type() .. " world_check=" .. tostring(world:typeOf("LWorld")))
    lurek.log.info("scene bodies=" .. world:getBodyCount() .. " first=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
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
    lurek.log.info("world check=" .. tostring(isWorld) .. " object check=" .. tostring(isObject))
    lurek.log.info("runtime kind=" .. world:type() .. " bodies=" .. world:getBodyCount())
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
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    zone:destroy()
    lurek.log.info("events=" .. tostring(#world:getZoneEvents()))
end
```

---

#### `LZone:getGravityFalloff`

Returns the current point/repulsor gravity falloff mode.

```lua
LZone:getGravityFalloff()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Falloff mode name. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 240, 240)
    zone:setGravityFalloff("inverse")
    local mode = zone:getGravityFalloff()
    lurek.log.info("falloff=" .. tostring(mode))
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
    lurek.log.info("zone id=" .. zone:getId() .. " type=" .. zone:type())
    lurek.log.info("scout y=" .. select(2, scout:getPosition()))
end
```

---

#### `LZone:isGravityAdditive`

Returns whether this zone adds gravity to other fields.

```lua
LZone:isGravityAdditive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when additive gravity mode is enabled. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 200, 200)
    local before = zone:isGravityAdditive()
    zone:setGravityAdditive(true)
    local after = zone:isGravityAdditive()
    lurek.log.info("additive before=" .. tostring(before) .. " after=" .. tostring(after))
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
    lurek.log.info("angular_velocity=" .. tostring(diver:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(diver:getAngle()))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end
```

---

#### `LZone:setGravityAdditive`

Controls whether this zone adds gravity to other fields instead of overriding world gravity by priority.

```lua
LZone:setGravityAdditive(additive)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `additive` | boolean | True to add this zone's gravity; false for priority override behavior. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 60)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setGravityDirectional(0, -20)
    zone:setGravityAdditive(true)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("additive=" .. tostring(zone:isGravityAdditive()) .. " vy=" .. select(2, probe:getVelocity()))
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
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end
```

---

#### `LZone:setGravityFalloff`

Sets point/repulsor gravity falloff. Accepted modes: inverseSquare, inverse, linear, constant.

```lua
LZone:setGravityFalloff(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Falloff mode name. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 240, 240)
    zone:setGravityPoint(120, 120, 90)
    zone:setGravityFalloff("constant")
    local probe = world:newCircleBody(180, 120, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("falloff=" .. zone:getGravityFalloff() .. " vx=" .. select(1, probe:getVelocity()))
end
```

---

#### `LZone:setGravityLimits`

Sets optional minimum and maximum acceleration clamps for point/repulsor gravity.

```lua
LZone:setGravityLimits(minAccel, maxAccel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `minAccel?` | number | Optional minimum acceleration magnitude. |
| `maxAccel?` | number | Optional maximum acceleration magnitude. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 300, 300)
    zone:setGravityPoint(150, 150, 2000)
    zone:setGravityLimits(nil, 80)
    local probe = world:newCircleBody(230, 150, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("limited gravity vx=" .. select(1, probe:getVelocity()))
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
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end
```

---

#### `LZone:setGravityRadius`

Sets the inner radius and optional outer radius used by point/repulsor falloff.

```lua
LZone:setGravityRadius(innerRadius, outerRadius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `innerRadius` | number | Minimum distance used for falloff, must be > 0. |
| `outerRadius?` | number | Optional maximum active distance, must be greater than innerRadius. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 300, 300)
    zone:setGravityPoint(150, 150, 200)
    zone:setGravityRadius(8, 90)
    local probe = world:newCircleBody(210, 150, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("radius-limited vx=" .. select(1, probe:getVelocity()))
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
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
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
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
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
    lurek.log.info("velocity=" .. tostring(diver:getVelocity()))
    lurek.log.info("position=" .. tostring(diver:getPosition()))
end
```

---

#### `LZone:setLinearDrag`

Sets or clears area drag proportional to velocity for bodies inside this zone.

```lua
LZone:setLinearDrag(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | number | Drag coefficient, or nil to clear. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local atmosphere = world:addZone(0, 0, 240, 240)
    atmosphere:setLinearDrag(2.5)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    probe:setVelocity(100, 0)
    world:step(1 / 60)
    lurek.log.info("linear drag vx=" .. select(1, probe:getVelocity()))
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
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end
```

---

#### `LZone:setQuadraticDrag`

Sets or clears area drag proportional to speed times velocity for bodies inside this zone.

```lua
LZone:setQuadraticDrag(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value?` | number | Drag coefficient, or nil to clear. |

**Example**

```lua
do

    local world = lurek.physics.newWorld(0, 0)
    local nebula = world:addZone(0, 0, 240, 240)
    nebula:setQuadraticDrag(0.04)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    probe:setVelocity(120, 0)
    world:step(1 / 60)
    lurek.log.info("quadratic drag vx=" .. select(1, probe:getVelocity()))
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
    lurek.log.info("zone userdata=" .. zone:type())
    lurek.log.info("zone check=" .. tostring(zone:typeOf("LZone")) .. " probe=" .. probe:getType())
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
    lurek.log.info("zone checks zone=" .. tostring(isZone) .. " object=" .. tostring(isObject))
    lurek.log.info("world check=" .. tostring(isWorld) .. " userdata=" .. zone:type())
end
```

---
