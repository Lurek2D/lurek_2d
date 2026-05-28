-- content/examples/particle.lua
-- Auto-generated from content/examples2/particle_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/particle.lua

--- Particle Module Part 1: system creation, presets, basic config

--@api-stub: lurek.particle.newSystem
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

--@api-stub: lurek.particle.newPreset
do
    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)

    print("type = " .. fire:type())
    print("fire rate = " .. fire:getEmissionRate())
end

--@api-stub: lurek.particle.fromTOML
do
    local path = "logs/particle_example.toml"
    local file = assert(io.open(path, "w"))
    file:write("max_particles = 96\n")
    file:write("emission_rate = 18.0\n")
    file:write("lifetime_min = 0.2\n")
    file:write("lifetime_max = 0.8\n")
    file:close()

    local ps = lurek.particle.fromTOML(path)
    print("type = " .. ps:type())
    print("buffer = " .. ps:getBufferSize())
end

--@api-stub: LParticleSystem:setBufferSize
do
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
end

--@api-stub: LParticleSystem:getBufferSize
do
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
end

--@api-stub: LParticleSystem:setPosition
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LParticleSystem:getPosition
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LParticleSystem:moveTo
do
    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    print("moved = " .. x .. "," .. y)
end

--@api-stub: LParticleSystem:setEmissionRate
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
end

--@api-stub: LParticleSystem:getEmissionRate
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
end

--@api-stub: LParticleSystem:setParticleLifetime
do
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
end

--@api-stub: LParticleSystem:getParticleLifetime
do
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
end

--@api-stub: LParticleSystem:setEmitterLifetime
do
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
end

--@api-stub: LParticleSystem:getEmitterLifetime
do
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
end

--@api-stub: LParticleSystem:setSpeed
do
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
end

--@api-stub: LParticleSystem:getSpeed
do
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
end

--@api-stub: LParticleSystem:setDirection
do
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
end

--@api-stub: LParticleSystem:getDirection
do
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
end

--@api-stub: LParticleSystem:setSpread
do
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
end

--@api-stub: LParticleSystem:getSpread
do
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
end

--@api-stub: LParticleSystem:setGravity
do
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
end

--@api-stub: LParticleSystem:getGravity
do
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
end

--@api-stub: LParticleSystem:setSizes
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("first size = " .. sizes[1])
end

--@api-stub: LParticleSystem:getSizes
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("last size = " .. sizes[#sizes])
end

--@api-stub: LParticleSystem:setSizeVariation
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
end

--@api-stub: LParticleSystem:getSizeVariation
do
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
end

--@api-stub: LParticleSystem:setColors
do
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("first alpha = " .. colors[1][4])
end

--@api-stub: LParticleSystem:getColors
do
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("last alpha = " .. colors[#colors][4])
end

--- Particle Module Part 2: lifecycle, emission, rendering, cloning

--@api-stub: LParticleSystem:start
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

--@api-stub: LParticleSystem:stop
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

--@api-stub: LParticleSystem:isActive
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()

    print("active = " .. tostring(ps:isActive()))
end

--@api-stub: LParticleSystem:isStopped
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    print("stopped = " .. tostring(ps:isStopped()))
end

--@api-stub: LParticleSystem:pause
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
end

--@api-stub: LParticleSystem:resume
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    print("paused = " .. tostring(ps:isPaused()))
    print("active = " .. tostring(ps:isActive()))
end

--@api-stub: LParticleSystem:isPaused
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
end

--@api-stub: LParticleSystem:emit
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

--@api-stub: LParticleSystem:warmUp
do
    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)

    print("warmed count = " .. ps:count())
end

--@api-stub: LParticleSystem:update
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

--@api-stub: LParticleSystem:render
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

--@api-stub: LParticleSystem:reset
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    print("before reset = " .. ps:count())
    ps:reset()
    print("after reset = " .. ps:count())
end

--@api-stub: LParticleSystem:clone
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

--@api-stub: LParticleSystem:isEmpty
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })

    print("empty = " .. tostring(ps:isEmpty()))
end

--@api-stub: LParticleSystem:isFull
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    print("full = " .. tostring(ps:isFull()))
end

--@api-stub: LParticleSystem:count
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("count = " .. ps:count())
end

--@api-stub: LParticleSystem:getCount
do
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("getCount = " .. ps:getCount())
end

--@api-stub: LParticleSystem:release
do
    local ps = lurek.particle.newSystem()
    ps:emit(5)

    local ok = ps:release()
    print("released = " .. tostring(ok))
end

--@api-stub: LParticleSystem:type
do
    local ps = lurek.particle.newSystem()

    print("type = " .. ps:type())
    print("is particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("is drawable = " .. tostring(ps:typeOf("LDrawable")))
end

--@api-stub: LParticleSystem:typeOf
do
    local ps = lurek.particle.newSystem()

    print("particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("drawable = " .. tostring(ps:typeOf("LDrawable")))
    print("object = " .. tostring(ps:typeOf("LObject")))
end

--@api-stub: LParticleSystem:setLinearAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
end

--@api-stub: LParticleSystem:getLinearAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
end

--@api-stub: LParticleSystem:setLinearDamping
do
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
end

--@api-stub: LParticleSystem:getLinearDamping
do
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
end

--@api-stub: LParticleSystem:setRadialAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
end

--@api-stub: LParticleSystem:getRadialAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
end

--@api-stub: LParticleSystem:setTangentialAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
end

--@api-stub: LParticleSystem:getTangentialAcceleration
do
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
end

--- Particle Module Part 3: advanced — attractors, sub-emitters, trails, physics, custom shapes

--@api-stub: LParticleSystem:addAttractor
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

--@api-stub: LParticleSystem:getAttractorCount
do
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("attractors = " .. ps:getAttractorCount())
end

--@api-stub: LParticleSystem:clearAttractors
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

--@api-stub: LParticleSystem:addSubEmitter
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

--@api-stub: LParticleSystem:addSubSystem
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

--@api-stub: LParticleSystem:subSystemCount
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

--@api-stub: LParticleSystem:setEmissionArea
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    print("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
end

--@api-stub: LParticleSystem:getEmissionArea
do
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)
end

--@api-stub: LParticleSystem:setRotation
do
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
end

--@api-stub: LParticleSystem:getRotation
do
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
end

--@api-stub: LParticleSystem:setSpin
do
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
end

--@api-stub: LParticleSystem:getSpin
do
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
end

--@api-stub: LParticleSystem:setSpinVariation
do
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
end

--@api-stub: LParticleSystem:getSpinVariation
do
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
end

--@api-stub: LParticleSystem:setRelativeRotation
do
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
end

--@api-stub: LParticleSystem:hasRelativeRotation
do
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
end

--@api-stub: LParticleSystem:setInsertMode
do
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    print("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    print("mode = " .. ps:getInsertMode())
end

--@api-stub: LParticleSystem:getInsertMode
do
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("bottom")

    print("mode = " .. ps:getInsertMode())
end

--@api-stub: LParticleSystem:setOffset
do
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParticleSystem:getOffset
do
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParticleSystem:setShape
do
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
end

--@api-stub: LParticleSystem:getShape
do
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
end

--@api-stub: LParticleSystem:setFlipbook
do
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
end

--@api-stub: LParticleSystem:getFlipbook
do
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
end

--@api-stub: LParticleSystem:setBounds
do
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
end

--@api-stub: LParticleSystem:clearBounds
do
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
end

--@api-stub: LParticleSystem:setCustomEmissionShape
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

--@api-stub: LParticleSystem:setOnDeathBatch
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

--@api-stub: LParticleSystem:drawToImage
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    print("drawToImage type = " .. image:type())
end

--@api-stub: LParticleSystem:toImage
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    print("toImage type = " .. image:type())
end

--@api-stub: LParticleSystem:drawExplosionToImage
do
    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    print("explosion type = " .. image:type())
    print("explosion width = " .. image:getWidth())
end

--@api-stub: LParticleSystem:drawRainToImage
do
    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    print("rain type = " .. image:type())
    print("rain height = " .. image:getHeight())
end

--@api-stub: LParticleSystem:drawSparkTrailToImage
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    print("spark type = " .. image:type())
    print("spark width = " .. image:getWidth())
end

--@api-stub: LParticleSystem:drawOverImage
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

--@api-stub: LParticleSystem:paintOnto
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

--@api-stub: lurek.particle.drawLifecycleToImage
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

--@api-stub: lurek.particle.newTrail
do
    local trail = lurek.particle.newTrail(2.0, 8)

    print("type = " .. trail:type())
    print("lifetime = " .. trail:getLifetime())
end

--@api-stub: LTrail:pushPoint
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
end

--@api-stub: LTrail:getPointCount
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
end

--@api-stub: LTrail:clear
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    print("before clear = " .. trail:getPointCount())
    trail:clear()
    print("after clear = " .. trail:getPointCount())
end

--@api-stub: LTrail:update
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    print("after update = " .. trail:getPointCount())
end

--@api-stub: LTrail:setWidth
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
end

--@api-stub: LTrail:getWidth
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
end

--@api-stub: LTrail:setLifetime
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
end

--@api-stub: LTrail:getLifetime
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
end

--@api-stub: LTrail:setHeadColor
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
end

--@api-stub: LTrail:setTailColor
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
end

--@api-stub: LTrail:setMinDistance
do
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    print("points = " .. trail:getPointCount())
end

--@api-stub: LTrail:drawToImage
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    print("trail image type = " .. image:type())
end

--@api-stub: LTrail:typeOf
do
    local trail = lurek.particle.newTrail(1.0, 4)

    print("is trail = " .. tostring(trail:typeOf("LTrail")))
    print("is object = " .. tostring(trail:typeOf("LObject")))
end

--- Particle Module Part 3: physics collision, trail type

--@api-stub: LParticleSystem:clearCollidesWithPhysics
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

--@api-stub: LParticleSystem:hasCollidesWithPhysics
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api-stub: LParticleSystem:setCollidesWithPhysics
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api-stub: LTrail:type
do
    local trail = lurek.particle.newTrail(1.5, 8.0)

    print("type = " .. trail:type())
end
