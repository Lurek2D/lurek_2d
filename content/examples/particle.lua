-- content/examples/particle.lua
-- Auto-generated from content/examples2/particle_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/particle.lua

--- Particle Module Part 1: system creation, presets, basic config

--@api-stub: lurek.particle.newSystem
-- Creates a particle system with optional config.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    print("type = " .. ps:type())
    print("count = " .. ps:count())
    print("active = " .. tostring(ps:isActive()))
end

-- Creates a configured particle system.
--@api-stub: lurek.particle.newSystem
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({
        bufferSize = 256,
        emissionRate = 50,
        particleLifetime = {0.5, 2.0},
        speed = {100, 200},
        direction = 0,
        spread = math.pi / 4,
    })
    print("buffer = " .. ps:getBufferSize())
    print("rate = " .. ps:getEmissionRate())
    local lmin, lmax = ps:getParticleLifetime()
    print("lifetime = " .. lmin .. ".." .. lmax)
end

--@api-stub: lurek.particle.newPreset
-- Creates a system from a named preset.
do
    ---@type LParticleSystem
    local fire = lurek.particle.newPreset("fire")
    ---@type LParticleSystem
    local smoke = lurek.particle.newPreset("smoke")
    ---@type LParticleSystem
    local rain = lurek.particle.newPreset("rain")
    ---@type LParticleSystem
    local snow = lurek.particle.newPreset("snow")
    ---@type LParticleSystem
    local sparks = lurek.particle.newPreset("sparks")
    print("fire rate = " .. fire:getEmissionRate())
    print("smoke rate = " .. smoke:getEmissionRate())
    print("rain rate = " .. rain:getEmissionRate())
    print("snow rate = " .. snow:getEmissionRate())
    print("sparks rate = " .. sparks:getEmissionRate())
end

--@api-stub: lurek.particle.fromTOML
-- Creates a system from a TOML config file.
do
    ---@type LParticleSystem
    local ps = lurek.particle.fromTOML("particles/explosion.toml")
    print("from TOML, buffer = " .. ps:getBufferSize())
end

--@api-stub: LParticleSystem:setBufferSize
--@api-stub: LParticleSystem:getBufferSize
-- Maximum particle count.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)
    print("buffer = " .. ps:getBufferSize())
end

--@api-stub: LParticleSystem:setPosition
--@api-stub: LParticleSystem:getPosition
--@api-stub: LParticleSystem:moveTo
-- Emitter position.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
    ps:moveTo(300, 400)
    local mx, my = ps:getPosition()
    print("moved = " .. mx .. "," .. my)
end

--@api-stub: LParticleSystem:setEmissionRate
--@api-stub: LParticleSystem:getEmissionRate
-- Emission rate in particles per second.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    print("rate = " .. ps:getEmissionRate())
end

--@api-stub: LParticleSystem:setParticleLifetime
--@api-stub: LParticleSystem:getParticleLifetime
-- Particle lifetime range.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)
    local lmin, lmax = ps:getParticleLifetime()
    print("lifetime = " .. lmin .. ".." .. lmax)
end

--@api-stub: LParticleSystem:setEmitterLifetime
--@api-stub: LParticleSystem:getEmitterLifetime
-- Emitter lifetime (0 = infinite).
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)
    print("emitter lifetime = " .. ps:getEmitterLifetime())
end

--@api-stub: LParticleSystem:setSpeed
--@api-stub: LParticleSystem:getSpeed
-- Particle speed range.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)
    local smin, smax = ps:getSpeed()
    print("speed = " .. smin .. ".." .. smax)
end

--@api-stub: LParticleSystem:setDirection
--@api-stub: LParticleSystem:getDirection
--@api-stub: LParticleSystem:setSpread
--@api-stub: LParticleSystem:getSpread
-- Emission direction and spread.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)
    ps:setSpread(math.pi / 6)
    print("dir = " .. ps:getDirection())
    print("spread = " .. ps:getSpread())
end

--@api-stub: LParticleSystem:setGravity
--@api-stub: LParticleSystem:getGravity
-- Particle gravity.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
end

--@api-stub: LParticleSystem:setSizes
--@api-stub: LParticleSystem:getSizes
--@api-stub: LParticleSystem:setSizeVariation
--@api-stub: LParticleSystem:getSizeVariation
-- Particle size keyframes.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    local sizes = ps:getSizes()
    print("sizes = " .. #sizes)
    ps:setSizeVariation(0.3)
    print("size var = " .. ps:getSizeVariation())
end

--@api-stub: LParticleSystem:setColors
--@api-stub: LParticleSystem:getColors
-- Color keyframes.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setColors(
        {r = 1, g = 0.5, b = 0, a = 1},
        {r = 1, g = 0, b = 0, a = 0}
    )
    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
end

--- Particle Module Part 2: lifecycle, emission, rendering, cloning

--@api-stub: LParticleSystem:start
--@api-stub: LParticleSystem:stop
--@api-stub: LParticleSystem:isActive
--@api-stub: LParticleSystem:isStopped
-- Emission lifecycle.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({emissionRate = 100, particleLifetime = {1, 2}})
    ps:start()
    print("active = " .. tostring(ps:isActive()))
    print("stopped = " .. tostring(ps:isStopped()))
    ps:stop()
    print("after stop: active = " .. tostring(ps:isActive()))
end

--@api-stub: LParticleSystem:pause
--@api-stub: LParticleSystem:resume
--@api-stub: LParticleSystem:isPaused
-- Pausing and resuming.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    print("paused = " .. tostring(ps:isPaused()))
    ps:resume()
    print("paused after resume = " .. tostring(ps:isPaused()))
end

--@api-stub: LParticleSystem:emit
-- Burst emission.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 512})
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)
    print("after emit: count = " .. ps:count())
end

--@api-stub: LParticleSystem:warmUp
-- Pre-fills the system for immediate visual density.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)
    print("warmed up: count = " .. ps:count())
end

--@api-stub: LParticleSystem:update
--@api-stub: LParticleSystem:render
-- Frame-by-frame update and render.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({emissionRate = 200, bufferSize = 1024})
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
    print("count after 10 frames = " .. ps:count())
end

--@api-stub: LParticleSystem:reset
-- Resets all particles.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)
    print("before reset: " .. ps:count())
    ps:reset()
    print("after reset: " .. ps:count())
end

--@api-stub: LParticleSystem:clone
-- Clones the system configuration.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 256, emissionRate = 75})
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)
    local copy = ps:clone()
    print("clone buffer = " .. copy:getBufferSize())
    print("clone rate = " .. copy:getEmissionRate())
end

--@api-stub: LParticleSystem:isEmpty
--@api-stub: LParticleSystem:isFull
--@api-stub: LParticleSystem:count
--@api-stub: LParticleSystem:getCount
-- Capacity queries.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 10})
    print("empty = " .. tostring(ps:isEmpty()))
    ps:emit(10)
    print("full = " .. tostring(ps:isFull()))
    print("count = " .. ps:count())
    print("getCount = " .. ps:getCount())
end

--@api-stub: LParticleSystem:release
-- Releases the system from shared storage.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:emit(5)
    local ok = ps:release()
    print("released = " .. tostring(ok))
end

--@api-stub: LParticleSystem:type
--@api-stub: LParticleSystem:typeOf
-- Type checking.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    print("type = " .. ps:type())
    print("is PS = " .. tostring(ps:typeOf("LParticleSystem")))
    print("is Drawable = " .. tostring(ps:typeOf("Drawable")))
    print("is Object = " .. tostring(ps:typeOf("Object")))
end

--@api-stub: LParticleSystem:setLinearAcceleration
--@api-stub: LParticleSystem:getLinearAcceleration
-- Linear acceleration.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
end

--@api-stub: LParticleSystem:setLinearDamping
--@api-stub: LParticleSystem:getLinearDamping
-- Linear damping.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)
    local dmin, dmax = ps:getLinearDamping()
    print("damping = " .. dmin .. ".." .. dmax)
end

--@api-stub: LParticleSystem:setRadialAcceleration
--@api-stub: LParticleSystem:getRadialAcceleration
-- Radial acceleration.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)
    local rmin, rmax = ps:getRadialAcceleration()
    print("radial = " .. rmin .. ".." .. rmax)
end

--@api-stub: LParticleSystem:setTangentialAcceleration
--@api-stub: LParticleSystem:getTangentialAcceleration
-- Tangential acceleration.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)
    local tmin, tmax = ps:getTangentialAcceleration()
    print("tangential = " .. tmin .. ".." .. tmax)
end

--- Particle Module Part 3: advanced — attractors, sub-emitters, trails, physics, custom shapes

--@api-stub: LParticleSystem:addAttractor
--@api-stub: LParticleSystem:getAttractorCount
--@api-stub: LParticleSystem:clearAttractors
-- Particle attractors pull particles toward a point.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 512, emissionRate = 100})
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)
    print("attractors = " .. ps:getAttractorCount())
    ps:clearAttractors()
    print("after clear = " .. ps:getAttractorCount())
end

--@api-stub: LParticleSystem:addSubEmitter
--@api-stub: LParticleSystem:addSubSystem
--@api-stub: LParticleSystem:subSystemCount
-- Sub-emitters spawn particles on death. Sub-systems are layered emitters.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 256})
    ps:addSubEmitter({emissionRate = 20, speed = {10, 30}, particleLifetime = {0.2, 0.5}}, 5)
    local idx = ps:addSubSystem({emissionRate = 10, speed = {5, 15}})
    print("sub-systems = " .. ps:subSystemCount() .. " last idx = " .. idx)
end

--@api-stub: LParticleSystem:setEmissionArea
--@api-stub: LParticleSystem:getEmissionArea
-- Area-based emission shapes.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)
    local dist, w, h = ps:getEmissionArea()
    print("area = " .. dist .. " " .. w .. "x" .. h)
    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    print("area set with angle and dir_rel")
end

--@api-stub: LParticleSystem:setRotation
--@api-stub: LParticleSystem:getRotation
--@api-stub: LParticleSystem:setSpin
--@api-stub: LParticleSystem:getSpin
-- Rotation and spin.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)
    local rmin, rmax = ps:getRotation()
    print("rotation = " .. rmin .. ".." .. rmax)
    ps:setSpin(-3, 3)
    local smin, smax = ps:getSpin()
    print("spin = " .. smin .. ".." .. smax)
end

--@api-stub: LParticleSystem:setSpinVariation
--@api-stub: LParticleSystem:getSpinVariation
--@api-stub: LParticleSystem:setRelativeRotation
--@api-stub: LParticleSystem:hasRelativeRotation
-- Spin variation and relative rotation.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)
    print("spin var = " .. ps:getSpinVariation())
    ps:setRelativeRotation(true)
    print("relative rot = " .. tostring(ps:hasRelativeRotation()))
end

--@api-stub: LParticleSystem:setInsertMode
--@api-stub: LParticleSystem:getInsertMode
-- Insert mode determines particle draw ordering.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")
    print("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    print("mode = " .. ps:getInsertMode())
end

--@api-stub: LParticleSystem:setOffset
--@api-stub: LParticleSystem:getOffset
-- Particle spawn offset.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParticleSystem:setShape
--@api-stub: LParticleSystem:getShape
-- Particle shape.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")
    print("shape = " .. ps:getShape())
end

--@api-stub: LParticleSystem:setFlipbook
--@api-stub: LParticleSystem:getFlipbook
-- Flipbook animation on particles.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
end

--@api-stub: LParticleSystem:setBounds
--@api-stub: LParticleSystem:clearBounds
-- Collision bounds for particles.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)
    print("bounds set with restitution 0.5")
    ps:clearBounds()
    print("bounds cleared")
end

--@api-stub: LParticleSystem:setCustomEmissionShape
-- Custom emission position callback.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem()
    ps:setCustomEmissionShape(function()
        local angle = math.random() * math.pi * 2
        local r = 50
        return math.cos(angle) * r + 400, math.sin(angle) * r + 300
    end)
    ps:emit(10)
    print("custom shape emitted")
end

--@api-stub: LParticleSystem:setOnDeathBatch
-- Callback on particle death for spawning effects.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newSystem({bufferSize = 64, emissionRate = 30})
    ps:setParticleLifetime(0.1, 0.2)
    local death_count = 0
    ps:setOnDeathBatch(function(batch)
        death_count = death_count + #batch
    end)
    ps:start()
    ps:update(0.5)
    print("deaths = " .. death_count)
end

--@api-stub: LParticleSystem:drawToImage
--@api-stub: LParticleSystem:toImage
-- Renders particles to image data.
do
    ---@type LParticleSystem
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local img1 = ps:drawToImage(128, 128)
    local img2 = ps:toImage(128, 128)
    print("drawToImage type = " .. img1:type())
    print("toImage type = " .. img2:type())
end

--@api-stub: lurek.particle.newTrail
-- Creates a trail effect.
do
    ---@type LTrail
    local trail = lurek.particle.newTrail(2.0, 8)
    print("type = " .. trail:type())
    print("lifetime = " .. trail:getLifetime())
end

--@api-stub: LTrail:pushPoint
--@api-stub: LTrail:getPointCount
--@api-stub: LTrail:clear
--@api-stub: LTrail:update
-- Trail point management.
do
    ---@type LTrail
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)
    print("points = " .. trail:getPointCount())
    trail:update(0.5)
    print("after update = " .. trail:getPointCount())
    trail:clear()
    print("after clear = " .. trail:getPointCount())
end

--@api-stub: LTrail:setWidth
--@api-stub: LTrail:getWidth
--@api-stub: LTrail:setLifetime
--@api-stub: LTrail:getLifetime
-- Trail dimensions and lifetime.
do
    ---@type LTrail
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)
    local sw, ew = trail:getWidth()
    print("width = " .. sw .. " → " .. ew)
    trail:setLifetime(5.0)
    print("lifetime = " .. trail:getLifetime())
end

--@api-stub: LTrail:setHeadColor
--@api-stub: LTrail:setTailColor
--@api-stub: LTrail:setMinDistance
-- Trail color gradient and spacing.
do
    ---@type LTrail
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:setTailColor(1, 0, 0, 0)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)
    print("trail configured, points = " .. trail:getPointCount())
end

--@api-stub: LTrail:drawToImage
--@api-stub: LTrail:typeOf
-- Trail rendering and type check.
do
    ---@type LTrail
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)
    local img = trail:drawToImage(64, 64)
    print("trail image type = " .. img:type())
    print("is LTrail = " .. tostring(trail:typeOf("LTrail")))
    print("is Object = " .. tostring(trail:typeOf("Object")))
end

--- Particle Module Part 3: physics collision, trail type

--@api-stub: LParticleSystem:clearCollidesWithPhysics
--@api-stub: LParticleSystem:hasCollidesWithPhysics
--@api-stub: LParticleSystem:setCollidesWithPhysics
-- Particle physics collision integration.
do
    local ps = lurek.particle.newSystem({ max = 200 })
    local world = lurek.physics.newWorld(0, 0)
    ps:setCollidesWithPhysics(world, 4.0, 0.3)
    print("has_collides=" .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    print("cleared=" .. tostring(ps:hasCollidesWithPhysics()))
end

--@api-stub: LTrail:type
-- Type introspection on LTrail.
do
    local trail = lurek.particle.newTrail(1.5, 8.0)
    print(trail:type())
end

print("content/examples/particle.lua")
