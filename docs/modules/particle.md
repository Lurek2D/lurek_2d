# Particle

- The `particle` module is a powerful Feature Systems tier component that provides comprehensive, emitter-based 2D particle systems for Lurek2D.

Designed for high-performance visual effects, it utilizes bounded, fixed-capacity memory pools and CPU-based Euler integration. At the core of the module is the `ParticleSystem`, an emitter that spawns `Particle` instances according to highly configurable emission shapes, such as point, circle, ring, rectangle, cone, line, and custom callbacks. Once spawned, each particle evolves independently based on a robust physics model that includes linear velocity, gravity, radial/tangential acceleration, linear damping, drag, orbit mechanics, and turbulence, before eventually expiring after a predefined lifetime.

The visual representation of particles is extremely flexible. The system supports both procedural geometric shapes (like squares, circles, sparks, and shrapnel) and fully textured sprites. Throughout their lifetime, particles dynamically interpolate key properties—such as color, size, rotation, and opacity—using customizable multi-stop keyframe curves. To create complex, layered effects, `ParticleSystem`s support sub-emitters, allowing particles to spawn entirely new child particle bursts upon specific events, such as birth, death, or collision. The module also features a robust physics collision integration, allowing particles to bounce realistically off defined bounding boxes or dynamic Rapier2D world geometry with configurable restitution.

Beyond standalone particles, the module implements a sophisticated `Trail` system. This generates connected ribbon segments behind moving particles or standalone points, featuring width tapering, age-based point retirement, and head-to-tail color interpolation. Additional advanced features include point attractors (gravity wells) that dynamically pull or repel live particles, and texture animation that can cycle through sprite atlas frames over a particle's lifetime. For ease of use, the module provides a suite of ready-made `presets` for common effects like fire, smoke, rain, snow, and sparks. The entire module is heavily optimized for deterministic simulation (given the same initial seed) and provides extensive debug visualization tools. It is fully exposed to the Lua scripting environment via the `lurek.particle.*` API, making it an essential tool for bringing dynamic, visually rich effects to Lurek2D games.

## Functions

### `lurek.particle.drawLifecycleToImage`

Draws a lifecycle chart image from `(step, count)` snapshot tables.

```lua
-- signature
lurek.particle.drawLifecycleToImage(snapshots, max_particles, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshots` | `table` | Array of snapshot tables or `{step, count}` arrays. |
| `max_particles` | `number` | Maximum particle count for chart scaling. |
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the lifecycle chart. |

**Example**

```lua
do
    local snapshots = {
        { step = 0, count = 0 },
        { step = 5, count = 12 },
        { step = 10, count = 4 },
    }
    local image = lurek.particle.drawLifecycleToImage(snapshots, 16, 128, 64)
    print("lifecycle type = " .. image:type())
    print("lifecycle width = " .. image:getWidth())
end
```

---

### `lurek.particle.fromTOML`

Creates a particle system from a TOML config file.

```lua
-- signature
lurek.particle.fromTOML(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | TOML file path. |

**Returns**

| Type | Description |
|------|-------------|
| `LParticleSystem` | New particle system handle. |

**Example**

```lua
do
    local path = "logs/particle_example.toml"
    lurek.filesystem.write(path, "max_particles = 96\nemission_rate = 18.0\nlifetime_min = 0.2\nlifetime_max = 0.8\n")

    local ps = lurek.particle.fromTOML(path)
    print("type = " .. ps:type())
    print("buffer = " .. ps:getBufferSize())
end
```

---

### `lurek.particle.newPreset`

Creates a particle system from a named preset.

```lua
-- signature
lurek.particle.newPreset(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Preset name: `fire`, `smoke`, `rain`, `snow`, or `sparks`. |

**Returns**

| Type | Description |
|------|-------------|
| `LParticleSystem` | New particle system handle. |

**Example**

```lua
do
    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)

    print("type = " .. fire:type())
    print("fire rate = " .. fire:getEmissionRate())
end
```

---

### `lurek.particle.newSystem`

Creates a particle system from an optional config table.

```lua
-- signature
lurek.particle.newSystem(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Particle config table. |

**Returns**

| Type | Description |
|------|-------------|
| `LParticleSystem` | New particle system handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })

    print("type = " .. ps:type())
    print("buffer = " .. ps:getBufferSize())
end
```

---

### `lurek.particle.newTrail`

Creates a trail effect. This function is exposed to Lua scripts.

```lua
-- signature
lurek.particle.newTrail(lifetime, start_width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lifetime` | `number` | Trail point lifetime. |
| `start_width` | `number` | Trail start width. |

**Returns**

| Type | Description |
|------|-------------|
| `LTrail` | New trail handle. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(2.0, 8)

    print("type = " .. trail:type())
    print("lifetime = " .. trail:getLifetime())
end
```

---

## LParticleSystem

### `LParticleSystem:addAttractor`

Adds an attractor to the particle system.

```lua
-- signature
LParticleSystem:addAttractor(x, y, strength, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Attractor x position. |
| `y` | `number` | Attractor y position. |
| `strength` | `number` | Attraction strength. |
| `radius` | `number` | Attraction radius. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("attractors = " .. ps:getAttractorCount())
end
```

---

### `LParticleSystem:addSubEmitter`

Configures a death sub-emitter from a config table.

```lua
-- signature
LParticleSystem:addSubEmitter(config_tbl, burst_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config_tbl` | `table` | Particle config table. |
| `burst_count?` | `number` | Burst count per death. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    ps:addSubEmitter({
        emissionRate = 20,
        speedMin = 10,
        speedMax = 30,
        lifetimeMin = 0.2,
        lifetimeMax = 0.5,
    }, 5)

    print("sub-systems = " .. ps:subSystemCount())
end
```

---

### `LParticleSystem:addSubSystem`

Adds a particle sub-system from a config table.

```lua
-- signature
LParticleSystem:addSubSystem(config_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config_tbl` | `table` | Particle config table. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based sub-system index. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    local idx = ps:addSubSystem({
        emissionRate = 10,
        speedMin = 5,
        speedMax = 15,
        lifetimeMin = 0.3,
        lifetimeMax = 0.6,
    })

    print("sub-system index = " .. idx)
    print("sub-system count = " .. ps:subSystemCount())
end
```

---

### `LParticleSystem:clearAttractors`

Clears all attractors on this object.

```lua
-- signature
LParticleSystem:clearAttractors()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("before clear = " .. ps:getAttractorCount())
    ps:clearAttractors()
    print("after clear = " .. ps:getAttractorCount())
end
```

---

### `LParticleSystem:clearBounds`

Clears collision bounds on this object.

```lua
-- signature
LParticleSystem:clearBounds()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
end
```

---

### `LParticleSystem:clearCollidesWithPhysics`

Disables particle collision against a physics world.

```lua
-- signature
LParticleSystem:clearCollidesWithPhysics()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

### `LParticleSystem:clone`

Clones this particle system configuration into a new system handle.

```lua
-- signature
LParticleSystem:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| `LParticleSystem` | New particle system handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 256,
        emissionRate = 75,
    })
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)

    local copy = ps:clone()
    print("clone buffer = " .. copy:getBufferSize())
    print("clone rate = " .. copy:getEmissionRate())
end
```

---

### `LParticleSystem:count`

Returns the current particle count.

```lua
-- signature
LParticleSystem:count()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Particle count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("count = " .. ps:count())
end
```

---

### `LParticleSystem:drawExplosionToImage`

Draws particles as an explosion preview image.

```lua
-- signature
LParticleSystem:drawExplosionToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the explosion preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    print("explosion type = " .. image:type())
    print("explosion width = " .. image:getWidth())
end
```

---

### `LParticleSystem:drawOverImage`

Draws particles over an existing image and returns a composited copy.

```lua
-- signature
LParticleSystem:drawOverImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImageData` | Background image data handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the composited result. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local image = lurek.image.newImageData(128, 128)
    image:fill(16, 16, 16, 255)

    local over = ps:drawOverImage(image)
    print("overlay type = " .. over:type())
    print("overlay width = " .. over:getWidth())
end
```

---

### `LParticleSystem:drawRainToImage`

Draws particles as a rain preview image.

```lua
-- signature
LParticleSystem:drawRainToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the rain preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    print("rain type = " .. image:type())
    print("rain height = " .. image:getHeight())
end
```

---

### `LParticleSystem:drawSparkTrailToImage`

Draws particles as a spark-trail preview image.

```lua
-- signature
LParticleSystem:drawSparkTrailToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the spark preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    print("spark type = " .. image:type())
    print("spark width = " .. image:getWidth())
end
```

---

### `LParticleSystem:drawToImage`

Draws particles to image data. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the rendered particles. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    print("drawToImage type = " .. image:type())
end
```

---

### `LParticleSystem:emit`

Emits particles immediately. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:emit(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | Number of particles to emit. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)

    print("after emit = " .. ps:count())
end
```

---

### `LParticleSystem:getAttractorCount`

Returns attractor count. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getAttractorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Attractor count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("attractors = " .. ps:getAttractorCount())
end
```

---

### `LParticleSystem:getBufferSize`

Returns maximum particle buffer size.

```lua
-- signature
LParticleSystem:getBufferSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum particle count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
end
```

---

### `LParticleSystem:getColors`

Returns particle color keyframes.

```lua
-- signature
LParticleSystem:getColors()
```

**Returns**

| Type | Description |
|------|-------------|
| `LParticleSystemGetColorsResult` | Array table of RGBA color tables. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("last alpha = " .. colors[#colors][4])
end
```

---

### `LParticleSystem:getCount`

Returns particle count and errors if the handle was released.

```lua
-- signature
LParticleSystem:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Particle count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("getCount = " .. ps:getCount())
end
```

---

### `LParticleSystem:getDirection`

Returns emission direction. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Direction angle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
end
```

---

### `LParticleSystem:getEmissionArea`

Returns emission area distribution and size.

```lua
-- signature
LParticleSystem:getEmissionArea()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Distribution name. |
| `number` | b Area width. |
| `number` | c Area height. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)
end
```

---

### `LParticleSystem:getEmissionRate`

Returns emission rate. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getEmissionRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Particles per second. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
end
```

---

### `LParticleSystem:getEmitterLifetime`

Returns emitter lifetime. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getEmitterLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Emitter lifetime. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
end
```

---

### `LParticleSystem:getFlipbook`

Returns flipbook grid and frame rate when configured.

```lua
-- signature
LParticleSystem:getFlipbook()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Column count, or nil when unconfigured. |
| `number` | b Row count, or nil when unconfigured. |
| `number` | c Frame rate, or nil when unconfigured. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
end
```

---

### `LParticleSystem:getGravity`

Returns particle gravity. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getGravity()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Gravity x. |
| `number` | b Gravity y. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
end
```

---

### `LParticleSystem:getInsertMode`

Returns particle insert mode. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getInsertMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Insert mode name. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("bottom")

    print("mode = " .. ps:getInsertMode())
end
```

---

### `LParticleSystem:getLinearAcceleration`

Returns linear acceleration range.

```lua
-- signature
LParticleSystem:getLinearAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum x acceleration. |
| `number` | b Minimum y acceleration. |
| `number` | c Maximum x acceleration. |
| `number` | d Maximum y acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
end
```

---

### `LParticleSystem:getLinearDamping`

Returns linear damping range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getLinearDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum damping. |
| `number` | b Maximum damping. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
end
```

---

### `LParticleSystem:getOffset`

Returns particle spawn offset. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Offset x. |
| `number` | b Offset y. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
end
```

---

### `LParticleSystem:getParticleLifetime`

Returns particle lifetime range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getParticleLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum lifetime. |
| `number` | b Maximum lifetime. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
end
```

---

### `LParticleSystem:getPosition`

Returns emitter position. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Emitter x coordinate. |
| `number` | b Emitter y coordinate. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
end
```

---

### `LParticleSystem:getRadialAcceleration`

Returns radial acceleration range.

```lua
-- signature
LParticleSystem:getRadialAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum acceleration. |
| `number` | b Maximum acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
end
```

---

### `LParticleSystem:getRotation`

Returns particle rotation range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum rotation. |
| `number` | b Maximum rotation. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
end
```

---

### `LParticleSystem:getShape`

Returns particle shape. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getShape()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Shape name. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
end
```

---

### `LParticleSystem:getSizeVariation`

Returns size variation. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSizeVariation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Size variation. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
end
```

---

### `LParticleSystem:getSizes`

Returns particle size keyframes. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of size values. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("last size = " .. sizes[#sizes])
end
```

---

### `LParticleSystem:getSpeed`

Returns particle speed range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum speed. |
| `number` | b Maximum speed. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
end
```

---

### `LParticleSystem:getSpin`

Returns particle spin range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSpin()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum spin. |
| `number` | b Maximum spin. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
end
```

---

### `LParticleSystem:getSpinVariation`

Returns spin variation. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSpinVariation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Spin variation. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
end
```

---

### `LParticleSystem:getSpread`

Returns emission spread. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:getSpread()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Spread angle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
end
```

---

### `LParticleSystem:getTangentialAcceleration`

Returns tangential acceleration range.

```lua
-- signature
LParticleSystem:getTangentialAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Minimum acceleration. |
| `number` | b Maximum acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
end
```

---

### `LParticleSystem:hasCollidesWithPhysics`

Returns whether particle physics collision is enabled.

```lua
-- signature
LParticleSystem:hasCollidesWithPhysics()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when collision is enabled. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

### `LParticleSystem:hasRelativeRotation`

Returns whether relative rotation is enabled.

```lua
-- signature
LParticleSystem:hasRelativeRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when relative rotation is enabled. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
end
```

---

### `LParticleSystem:isActive`

Returns whether the particle system is active.

```lua
-- signature
LParticleSystem:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when active. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()

    print("active = " .. tostring(ps:isActive()))
end
```

---

### `LParticleSystem:isEmpty`

Returns whether the particle system has no particles or is missing.

```lua
-- signature
LParticleSystem:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when empty. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })

    print("empty = " .. tostring(ps:isEmpty()))
end
```

---

### `LParticleSystem:isFull`

Returns whether the particle system has reached capacity.

```lua
-- signature
LParticleSystem:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when full. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    print("full = " .. tostring(ps:isFull()))
end
```

---

### `LParticleSystem:isPaused`

Returns whether the particle system is paused.

```lua
-- signature
LParticleSystem:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when paused. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
end
```

---

### `LParticleSystem:isStopped`

Returns whether the particle system is stopped or missing.

```lua
-- signature
LParticleSystem:isStopped()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when stopped. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    print("stopped = " .. tostring(ps:isStopped()))
end
```

---

### `LParticleSystem:moveTo`

Moves the particle emitter. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:moveTo(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Emitter x coordinate. |
| `y` | `number` | Emitter y coordinate. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    print("moved = " .. x .. "," .. y)
end
```

---

### `LParticleSystem:paintOnto`

Paints live particles directly onto an existing image in place.

```lua
-- signature
LParticleSystem:paintOnto(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | `LImageData` | Target image data handle. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(32, 32)
    ps:emit(12)
    ps:update(0.1)
    local image = lurek.image.newImageData(64, 64)

    ps:paintOnto(image)
    print("paint target type = " .. image:type())
    print("paint target height = " .. image:getHeight())
end
```

---

### `LParticleSystem:pause`

Pauses particle emission and updates.

```lua
-- signature
LParticleSystem:pause()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
end
```

---

### `LParticleSystem:release`

Releases the particle system from shared storage.

```lua
-- signature
LParticleSystem:release()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True after release. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:emit(5)

    local ok = ps:release()
    print("released = " .. tostring(ok))
end
```

---

### `LParticleSystem:render`

Enqueues particle render commands with an optional offset.

```lua
-- signature
LParticleSystem:render(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox?` | `number` | X offset. |
| `oy?` | `number` | Y offset. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        emissionRate = 200,
        maxParticles = 1024,
    })
    ps:setPosition(320, 240)
    ps:setSpeed(100, 300)
    ps:setDirection(-math.pi / 2)
    ps:setSpread(math.pi / 8)
    ps:setGravity(0, 400)
    ps:start()

    for _ = 1, 10 do
        ps:update(0.016)
    end

    ps:render()
    ps:render(10, 5)
    print("count before render = " .. ps:count())
end
```

---

### `LParticleSystem:reset`

Resets particles and emitter state.

```lua
-- signature
LParticleSystem:reset()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    print("before reset = " .. ps:count())
    ps:reset()
    print("after reset = " .. ps:count())
end
```

---

### `LParticleSystem:resume`

Resumes a paused particle system if it was previously paused.

```lua
-- signature
LParticleSystem:resume()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    print("paused = " .. tostring(ps:isPaused()))
    print("active = " .. tostring(ps:isActive()))
end
```

---

### `LParticleSystem:setBounds`

Sets collision bounds for particles.

```lua
-- signature
LParticleSystem:setBounds(xmin, xmax, ymin, ymax, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `xmin` | `number` | Minimum x bound. |
| `xmax` | `number` | Maximum x bound. |
| `ymin` | `number` | Minimum y bound. |
| `ymax` | `number` | Maximum y bound. |
| `restitution` | `number` | Bounce restitution factor. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
end
```

---

### `LParticleSystem:setBufferSize`

Sets maximum particle buffer size.

```lua
-- signature
LParticleSystem:setBufferSize(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Maximum particle count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
end
```

---

### `LParticleSystem:setCollidesWithPhysics`

Enables particle collision against a physics world.

```lua
-- signature
LParticleSystem:setCollidesWithPhysics(world_ud, probe_radius, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world_ud` | `LWorld` | Physics world handle. |
| `probe_radius?` | `number` | Collision probe radius. |
| `restitution?` | `number` | Bounce restitution. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

### `LParticleSystem:setColors`

Sets particle color keyframes from one or more RGBA tables.

```lua
-- signature
LParticleSystem:setColors(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... table One or more `{r, g, b, a}` color tables. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("first alpha = " .. colors[1][4])
end
```

---

### `LParticleSystem:setCustomEmissionShape`

Sets a Lua callback for custom emission positions.

```lua
-- signature
LParticleSystem:setCustomEmissionShape(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb` | `function` | Callback returning an x/y position. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    local step = 0

    ps:setCustomEmissionShape(function()
        step = step + 1
        local angle = step * (math.pi / 4)
        local radius = 50
        return 400 + math.cos(angle) * radius, 300 + math.sin(angle) * radius
    end)

    ps:emit(10)
    ps:update(0.016)
    print("custom shape emitted = " .. ps:count())
end
```

---

### `LParticleSystem:setDirection`

Sets emission direction. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | `number` | Direction angle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
end
```

---

### `LParticleSystem:setEmissionArea`

Sets emission area distribution and size.

```lua
-- signature
LParticleSystem:setEmissionArea(dist, w, h, angle, dir_rel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dist` | `string` | Distribution name. |
| `w` | `number` | Area width. |
| `h` | `number` | Area height. |
| `angle?` | `number` | Area angle. |
| `dir_rel?` | `boolean` | Direction-relative flag. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    print("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
end
```

---

### `LParticleSystem:setEmissionRate`

Sets emission rate. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setEmissionRate(rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rate` | `number` | Particles per second. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
end
```

---

### `LParticleSystem:setEmitterLifetime`

Sets emitter lifetime. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setEmitterLifetime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Emitter lifetime. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
end
```

---

### `LParticleSystem:setFlipbook`

Sets flipbook grid and frame rate. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setFlipbook(cols, rows, fps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols` | `number` | Grid column count. |
| `rows` | `number` | Grid row count. |
| `fps` | `number` | Playback frame rate. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
end
```

---

### `LParticleSystem:setGravity`

Sets particle gravity. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setGravity(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | `number` | Gravity x. |
| `gy` | `number` | Gravity y. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
end
```

---

### `LParticleSystem:setInsertMode`

Sets particle insert mode. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setInsertMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Insert mode: `top`, `bottom`, or `random`. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    print("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    print("mode = " .. ps:getInsertMode())
end
```

---

### `LParticleSystem:setLinearAcceleration`

Sets linear acceleration range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setLinearAcceleration(xmin, ymin, xmax, ymax)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `xmin` | `number` | Minimum x acceleration. |
| `ymin` | `number` | Minimum y acceleration. |
| `xmax` | `number` | Maximum x acceleration. |
| `ymax` | `number` | Maximum y acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
end
```

---

### `LParticleSystem:setLinearDamping`

Sets linear damping range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setLinearDamping(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum damping. |
| `max` | `number` | Maximum damping. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
end
```

---

### `LParticleSystem:setOffset`

Sets particle spawn offset. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setOffset(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | `number` | Spawn offset x. |
| `oy` | `number` | Spawn offset y. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
end
```

---

### `LParticleSystem:setOnDeathBatch`

Sets a Lua callback invoked with batched particle death records.

```lua
-- signature
LParticleSystem:setOnDeathBatch(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb` | `function` | Death batch callback. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 64,
        emissionRate = 0,
        lifetimeMin = 0.1,
        lifetimeMax = 0.2,
    })
    local death_count = 0

    ps:setOnDeathBatch(function(batch)
        death_count = death_count + #batch
    end)

    ps:emit(8)
    ps:update(0.5)
    print("deaths = " .. death_count)
end
```

---

### `LParticleSystem:setParticleLifetime`

Sets particle lifetime range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setParticleLifetime(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum lifetime. |
| `max` | `number` | Maximum lifetime. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
end
```

---

### `LParticleSystem:setPosition`

Sets emitter position. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Emitter x coordinate. |
| `y` | `number` | Emitter y coordinate. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
end
```

---

### `LParticleSystem:setRadialAcceleration`

Sets radial acceleration range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setRadialAcceleration(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum radial acceleration. |
| `max` | `number` | Maximum radial acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
end
```

---

### `LParticleSystem:setRelativeRotation`

Sets whether particle rotation is relative to movement.

```lua
-- signature
LParticleSystem:setRelativeRotation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `boolean` | Relative rotation flag. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
end
```

---

### `LParticleSystem:setRotation`

Sets particle rotation range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setRotation(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum rotation. |
| `max` | `number` | Maximum rotation. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
end
```

---

### `LParticleSystem:setShape`

Sets particle shape. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setShape(shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | `string` | Shape name. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
end
```

---

### `LParticleSystem:setSizeVariation`

Sets size variation. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setSizeVariation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Size variation. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
end
```

---

### `LParticleSystem:setSizes`

Sets the particle size keyframes used during a particle's lifetime. Pass two or more values to interpolate between them.

```lua
-- signature
LParticleSystem:setSizes(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Two or more size values that the particle lerps through over its lifetime (e.g. `4, 1` shrinks from 4 to 1). |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("first size = " .. sizes[1])
end
```

---

### `LParticleSystem:setSpeed`

Sets particle speed range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setSpeed(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum speed. |
| `max` | `number` | Maximum speed. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
end
```

---

### `LParticleSystem:setSpin`

Sets particle spin range. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setSpin(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum spin. |
| `max` | `number` | Maximum spin. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
end
```

---

### `LParticleSystem:setSpinVariation`

Sets spin variation. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setSpinVariation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Spin variation factor. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
end
```

---

### `LParticleSystem:setSpread`

Sets emission spread. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:setSpread(spread)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spread` | `number` | Spread angle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
end
```

---

### `LParticleSystem:setTangentialAcceleration`

Sets tangential acceleration range for emitted particles.

```lua
-- signature
LParticleSystem:setTangentialAcceleration(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | `number` | Minimum tangential acceleration. |
| `max` | `number` | Maximum tangential acceleration. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
end
```

---

### `LParticleSystem:start`

Starts particle emission on this object.

```lua
-- signature
LParticleSystem:start()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    print("active = " .. tostring(ps:isActive()))
    print("stopped = " .. tostring(ps:isStopped()))
end
```

---

### `LParticleSystem:stop`

Stops particle emission on this object.

```lua
-- signature
LParticleSystem:stop()
```

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    ps:stop()
    print("active = " .. tostring(ps:isActive()))
    print("stopped = " .. tostring(ps:isStopped()))
end
```

---

### `LParticleSystem:subSystemCount`

Returns particle sub-system count.

```lua
-- signature
LParticleSystem:subSystemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sub-system count. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    ps:addSubSystem({
        emissionRate = 10,
        speedMin = 5,
        speedMax = 15,
        lifetimeMin = 0.3,
        lifetimeMax = 0.6,
    })

    print("sub-system count = " .. ps:subSystemCount())
end
```

---

### `LParticleSystem:toImage`

Draws particles to image data. This method is available to Lua scripts.

```lua
-- signature
LParticleSystem:toImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Image width. |
| `h` | `number` | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the rendered particles. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    print("toImage type = " .. image:type())
end
```

---

### `LParticleSystem:type`

Returns the Lua-visible type name for this particle system handle.

```lua
-- signature
LParticleSystem:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LParticleSystem`. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()

    print("type = " .. ps:type())
    print("is particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("is drawable = " .. tostring(ps:typeOf("LDrawable")))
end
```

---

### `LParticleSystem:typeOf`

Returns whether this particle system handle matches a supported type name.

```lua
-- signature
LParticleSystem:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LParticleSystem`, `ParticleSystem`, `Drawable`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()

    print("particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("drawable = " .. tostring(ps:typeOf("LDrawable")))
    print("object = " .. tostring(ps:typeOf("LObject")))
end
```

---

### `LParticleSystem:update`

Updates the particle system, applies optional physics collision, and invokes pending callbacks.

```lua
-- signature
LParticleSystem:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        emissionRate = 200,
        maxParticles = 1024,
    })
    ps:setPosition(320, 240)
    ps:setSpeed(100, 300)
    ps:setDirection(-math.pi / 2)
    ps:setSpread(math.pi / 8)
    ps:setGravity(0, 400)
    ps:start()

    for _ = 1, 10 do
        ps:update(0.016)
    end

    print("count after update = " .. ps:count())
end
```

---

### `LParticleSystem:warmUp`

Advances the system by a warm-up duration.

```lua
-- signature
LParticleSystem:warmUp(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Warm-up duration in seconds. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)

    print("warmed count = " .. ps:count())
end
```

---

## LTrail

### `LTrail:clear`

Clears all trail points on this object.

```lua
-- signature
LTrail:clear()
```

**Example**

```lua
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    print("before clear = " .. trail:getPointCount())
    trail:clear()
    print("after clear = " .. trail:getPointCount())
end
```

---

### `LTrail:drawToImage`

Draws the trail to image data. This method is available to Lua scripts.

```lua
-- signature
LTrail:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Width of output image. |
| `h` | `number` | Height of output image. |

**Returns**

| Type | Description |
|------|-------------|
| `LImageData` | Image data containing the rendered trail. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    print("trail image type = " .. image:type())
end
```

---

### `LTrail:getLifetime`

Returns trail point lifetime. This method is available to Lua scripts.

```lua
-- signature
LTrail:getLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Lifetime in seconds. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
end
```

---

### `LTrail:getPointCount`

Returns trail point count. This method is available to Lua scripts.

```lua
-- signature
LTrail:getPointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Point count. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
end
```

---

### `LTrail:getWidth`

Returns trail width settings from this object.

```lua
-- signature
LTrail:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Start width. |
| `number` | b End width. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
end
```

---

### `LTrail:pushPoint`

Adds a point to the trail. This method is available to Lua scripts.

```lua
-- signature
LTrail:pushPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Point x coordinate. |
| `y` | `number` | Point y coordinate. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
end
```

---

### `LTrail:setHeadColor`

Sets the color of the leading edge of the trail.

```lua
-- signature
LTrail:setHeadColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a` | `number` | Alpha channel. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
end
```

---

### `LTrail:setLifetime`

Sets trail point lifetime. This method is available to Lua scripts.

```lua
-- signature
LTrail:setLifetime(lifetime)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lifetime` | `number` | Point lifetime in seconds. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
end
```

---

### `LTrail:setMinDistance`

Sets minimum distance between trail points.

```lua
-- signature
LTrail:setMinDistance(distance)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `distance` | `number` | Minimum distance between points. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    print("points = " .. trail:getPointCount())
end
```

---

### `LTrail:setTailColor`

Sets the color of the trailing edge of the trail.

```lua
-- signature
LTrail:setTailColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a` | `number` | Alpha channel. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
end
```

---

### `LTrail:setWidth`

Sets trail start and optional end width.

```lua
-- signature
LTrail:setWidth(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | `number` | Start width. |
| `end_?` | `number` | End width. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
end
```

---

### `LTrail:type`

Returns the Lua-visible type name for this trail handle.

```lua
-- signature
LTrail:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LTrail`. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.5, 8.0)

    print("type = " .. trail:type())
end
```

---

### `LTrail:typeOf`

Returns whether this trail handle matches a supported type name.

```lua
-- signature
LTrail:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LTrail` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)

    print("is trail = " .. tostring(trail:typeOf("LTrail")))
    print("is object = " .. tostring(trail:typeOf("LObject")))
end
```

---

### `LTrail:update`

Updates trail point lifetimes. This method is available to Lua scripts.

```lua
-- signature
LTrail:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    print("after update = " .. trail:getPointCount())
end
```

---
