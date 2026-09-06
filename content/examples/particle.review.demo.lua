-- content/examples/particle.lua
-- Auto-generated from content/examples2/particle_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/particle.lua


--- Particle Module Part 1: system creation, presets, basic config


--@api: lurek.particle.newSystem
do

    local ps = lurek.particle.newSystem({
        seed = 42,
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })
    local from_toml_shape = lurek.particle.newSystem({
        seed = 7,
        max_particles = 32,
        emission_rate = 12,
        lifetime_min = 0.15,
        lifetime_max = 0.45,
        speed_min = 20,
        speed_max = 60,
        gravity_y = 48,
    })

    lurek.log.info("type = " .. ps:type())
    lurek.log.info("buffer = " .. ps:getBufferSize())
    lurek.log.info("snake_case rate = " .. from_toml_shape:getEmissionRate())
end

--@api: lurek.particle.newPreset
do

    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)
    fire:setEmissionRate(48)
    local x, y = fire:getPosition()
    local rate = fire:getEmissionRate()
    local explosion = lurek.particle.newPreset("explosion")
    local muzzle = lurek.particle.newPreset("muzzle")
    local trail = lurek.particle.newPreset("smoke_trail")
    lurek.log.info("campfire preset at " .. x .. "," .. y .. " emits " .. rate)
    lurek.log.info("shooter presets = " .. explosion:type() .. "," .. muzzle:type() .. "," .. trail:type())
end

--@api: lurek.particle.fromTOML
do

    local path = "save/particle_example.toml"
    lurek.filesystem.write(path, "seed = 42\nmax_particles = 96\nemission_rate = 18.0\nlifetime_min = 0.2\nlifetime_max = 0.8\n")

    local ps = lurek.particle.fromTOML(path)
    lurek.log.info("type = " .. ps:type())
    lurek.log.info("buffer = " .. ps:getBufferSize())
end

--@api: LParticleSystem:setBufferSize
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(60)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    lurek.log.info("boss explosion pool resized to " .. buffer)
end

--@api: LParticleSystem:getBufferSize
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(90)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    local rate = ps:getEmissionRate()
    lurek.log.info("buffer " .. buffer .. " supports rate " .. rate)
end

--@api: LParticleSystem:setPosition
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(20)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local rate = ps:getEmissionRate()
    lurek.log.info("torch ember emitter moved to " .. x .. "," .. y .. " at rate " .. rate)
end

--@api: LParticleSystem:getPosition
do

    local ps = lurek.particle.newSystem()
    ps:setOffset(12, -4)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local ox, oy = ps:getOffset()
    lurek.log.info("projectile trail anchor " .. x .. "," .. y .. " offset " .. ox .. "," .. oy)
end

--@api: LParticleSystem:moveTo
do

    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    lurek.log.info("moved = " .. x .. "," .. y)
end

--@api: LParticleSystem:setEmissionRate
do

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(256)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local buffer = ps:getBufferSize()
    lurek.log.info("rain emitter rate " .. rate .. " within pool " .. buffer)
end

--@api: LParticleSystem:getEmissionRate
do

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.2, 0.8)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local min_life = select(1, ps:getParticleLifetime())
    lurek.log.info("muzzle flash emits " .. rate .. " with min lifetime " .. min_life)
end

--@api: LParticleSystem:setParticleLifetime
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(32)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local rate = ps:getEmissionRate()
    lurek.log.info("smoke lifetime " .. min_life .. ".." .. max_life .. " at rate " .. rate)
end

--@api: LParticleSystem:getParticleLifetime
do

    local ps = lurek.particle.newSystem()
    ps:setSpeed(20, 80)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local max_speed = select(2, ps:getSpeed())
    lurek.log.info("spark lifetime " .. min_life .. ".." .. max_life .. " with speed ceiling " .. max_speed)
end

--@api: LParticleSystem:setEmitterLifetime
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(18)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local rate = ps:getEmissionRate()
    lurek.log.info("one-shot vent runs for " .. emitter_life .. "s at rate " .. rate)
end

--@api: LParticleSystem:getEmitterLifetime
do

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 180)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local x = select(1, ps:getPosition())
    lurek.log.info("storm cloud at x=" .. x .. " lives " .. emitter_life .. "s")
end

--@api: LParticleSystem:setSpeed
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local dir = ps:getDirection()
    lurek.log.info("debris speed " .. min_speed .. ".." .. max_speed .. " toward " .. dir)
end

--@api: LParticleSystem:getSpeed
do

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 12)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local spread = ps:getSpread()
    lurek.log.info("fountain speed " .. min_speed .. ".." .. max_speed .. " with spread " .. spread)
end

--@api: LParticleSystem:setDirection
do

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 10)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local spread = ps:getSpread()
    lurek.log.info("steam vent faces " .. dir .. " with spread " .. spread)
end

--@api: LParticleSystem:getDirection
do

    local ps = lurek.particle.newSystem()
    ps:setSpeed(40, 60)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local min_speed = select(1, ps:getSpeed())
    lurek.log.info("leaf burst direction " .. dir .. " from speed floor " .. min_speed)
end

--@api: LParticleSystem:setSpread
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local dir = ps:getDirection()
    lurek.log.info("shotgun spark cone " .. spread .. " around " .. dir)
end

--@api: LParticleSystem:getSpread
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(24)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local rate = ps:getEmissionRate()
    lurek.log.info("ember spread " .. spread .. " with rate " .. rate)
end

--@api: LParticleSystem:setGravity
do

    local ps = lurek.particle.newSystem()
    ps:setSpeed(60, 90)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_speed = select(2, ps:getSpeed())
    lurek.log.info("snowfall gravity " .. gx .. "," .. gy .. " against speed " .. max_speed)
end

--@api: LParticleSystem:getGravity
do

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 1.5)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_life = select(2, ps:getParticleLifetime())
    lurek.log.info("dust gravity " .. gx .. "," .. gy .. " over lifetime " .. max_life)
end

--@api: LParticleSystem:setSizes
do

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    lurek.log.info("size count = " .. #sizes)
    lurek.log.info("first size = " .. sizes[1])
end

--@api: LParticleSystem:getSizes
do

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    lurek.log.info("size count = " .. #sizes)
    lurek.log.info("last size = " .. sizes[#sizes])
end

--@api: LParticleSystem:setSizeVariation
do

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local sizes = ps:getSizes()
    lurek.log.info("spark size variation " .. variation .. " across " .. #sizes .. " keyframes")
end

--@api: LParticleSystem:getSizeVariation
do

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local first_size = ps:getSizes()[1]
    lurek.log.info("size variation " .. variation .. " with first size " .. first_size)
end

--@api: LParticleSystem:setColors
do

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    lurek.log.info("color keyframes = " .. #colors)
    lurek.log.info("first alpha = " .. colors[1][4])
end

--@api: LParticleSystem:getColors
do

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    lurek.log.info("color keyframes = " .. #colors)
    lurek.log.info("last alpha = " .. colors[#colors][4])
end

--- Particle Module Part 2: lifecycle, emission, rendering, cloning

--@api: LParticleSystem:start
do

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    lurek.log.info("active = " .. tostring(ps:isActive()))
    lurek.log.info("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:stop
do

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    ps:stop()
    lurek.log.info("active = " .. tostring(ps:isActive()))
    lurek.log.info("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:isActive
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:update(0.05)
    local active = ps:isActive()
    local count = ps:count()
    lurek.log.info("bonfire active = " .. tostring(active) .. " with " .. count .. " live particles")
end

--@api: LParticleSystem:isStopped
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    lurek.log.info("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:pause
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    lurek.log.info("paused = " .. tostring(ps:isPaused()))
end

--@api: LParticleSystem:resume
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    lurek.log.info("paused = " .. tostring(ps:isPaused()))
    lurek.log.info("active = " .. tostring(ps:isActive()))
end

--@api: LParticleSystem:isPaused
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    lurek.log.info("paused = " .. tostring(ps:isPaused()))
end

--@api: LParticleSystem:emit
do

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)

    lurek.log.info("after emit = " .. ps:count())
end

--@api: LParticleSystem:warmUp
do

    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)
    local count = ps:count()
    local active = ps:isActive()
    lurek.log.info("rain warmed to " .. count .. " drops active=" .. tostring(active))
end

--@api: LParticleSystem:update
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

    lurek.log.info("count after update = " .. ps:count())
end

--@api: LParticleSystem:render
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
    lurek.log.info("count before render = " .. ps:count())
end

--@api: LParticleSystem:reset
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    lurek.log.info("before reset = " .. ps:count())
    ps:reset()
    lurek.log.info("after reset = " .. ps:count())
end

--@api: LParticleSystem:clone
do

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
        emissionRate = 75,
    })
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)

    local copy = ps:clone()
    lurek.log.info("clone buffer = " .. copy:getBufferSize())
    lurek.log.info("clone rate = " .. copy:getEmissionRate())
end

--@api: LParticleSystem:isEmpty
do

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:setEmissionRate(0)
    ps:emit(0)
    local empty = ps:isEmpty()
    local count = ps:count()
    lurek.log.info("fresh system empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LParticleSystem:isFull
do

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    lurek.log.info("full = " .. tostring(ps:isFull()))
end

--@api: LParticleSystem:count
do

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    lurek.log.info("count = " .. ps:count())
end

--@api: LParticleSystem:getCount
do

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    lurek.log.info("getCount = " .. ps:getCount())
end

--@api: LParticleSystem:release
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(12)
    ps:emit(5)
    local ok = ps:release()
    local type_name = ps:type()
    lurek.log.info("release returned " .. tostring(ok) .. " for " .. type_name)
end

--@api: LParticleSystem:type
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(16)
    local type_name = ps:type()
    local is_particle = ps:typeOf("LParticleSystem")
    local is_drawable = ps:typeOf("LDrawable")
    lurek.log.info(type_name .. " particle=" .. tostring(is_particle) .. " drawable=" .. tostring(is_drawable))
end

--@api: LParticleSystem:typeOf
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(8)
    local particle = ps:typeOf("LParticleSystem")
    local drawable = ps:typeOf("LDrawable")
    local object = ps:typeOf("LObject")
    lurek.log.info("typeOf particle=" .. tostring(particle) .. " drawable=" .. tostring(drawable) .. " object=" .. tostring(object))
end

--@api: LParticleSystem:setLinearAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setSpeed(30, 60)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local speed = select(2, ps:getSpeed())
    lurek.log.info("wind accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " speed " .. speed)
end

--@api: LParticleSystem:getLinearAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local dir = ps:getDirection()
    lurek.log.info("read accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " dir " .. dir)
end

--@api: LParticleSystem:setLinearDamping
do

    local ps = lurek.particle.newSystem()
    ps:setSpeed(120, 180)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local speed = select(2, ps:getSpeed())
    lurek.log.info("air drag " .. min_damping .. ".." .. max_damping .. " with max speed " .. speed)
end

--@api: LParticleSystem:getLinearDamping
do

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.6, 1.2)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local max_life = select(2, ps:getParticleLifetime())
    lurek.log.info("damping " .. min_damping .. ".." .. max_damping .. " over " .. max_life .. "s")
end

--@api: LParticleSystem:setRadialAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 240)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local x = select(1, ps:getPosition())
    lurek.log.info("shockwave radial accel " .. min_radial .. ".." .. max_radial .. " from x=" .. x)
end

--@api: LParticleSystem:getRadialAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi * 2)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local spread = ps:getSpread()
    lurek.log.info("radial accel " .. min_radial .. ".." .. max_radial .. " with spread " .. spread)
end

--@api: LParticleSystem:setTangentialAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local dir = ps:getDirection()
    lurek.log.info("swirl tangential accel " .. min_tangent .. ".." .. max_tangent .. " around " .. dir)
end

--@api: LParticleSystem:getTangentialAcceleration
do

    local ps = lurek.particle.newSystem()
    ps:setPosition(128, 96)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local y = select(2, ps:getPosition())
    lurek.log.info("tangential accel " .. min_tangent .. ".." .. max_tangent .. " near y=" .. y)
end

--- Particle Module Part 3: advanced — attractors, sub-emitters, trails, physics, custom shapes

--@api: LParticleSystem:addAttractor
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

    lurek.log.info("attractors = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:getAttractorCount
do

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    lurek.log.info("attractors = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:clearAttractors
do

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    lurek.log.info("before clear = " .. ps:getAttractorCount())
    ps:clearAttractors()
    lurek.log.info("after clear = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:addSubEmitter
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

    lurek.log.info("sub-systems = " .. ps:subSystemCount())
end

--@api: LParticleSystem:addSubSystem
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

    lurek.log.info("sub-system index = " .. idx)
    lurek.log.info("sub-system count = " .. ps:subSystemCount())
end

--@api: LParticleSystem:subSystemCount
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

    lurek.log.info("sub-system count = " .. ps:subSystemCount())
end

--@api: LParticleSystem:setEmissionArea
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    lurek.log.info("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    lurek.log.info("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
end

--@api: LParticleSystem:getEmissionArea
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 3)
    ps:setEmissionArea("uniform", 100, 50)
    local dist, width, height = ps:getEmissionArea()
    local dir = ps:getDirection()
    lurek.log.info("spawn area " .. dist .. " " .. width .. "x" .. height .. " dir " .. dir)
end

--@api: LParticleSystem:setRotation
do

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local shape = ps:getShape()
    lurek.log.info("shrapnel rotation " .. min_rotation .. ".." .. max_rotation .. " shape " .. shape)
end

--@api: LParticleSystem:getRotation
do

    local ps = lurek.particle.newSystem()
    ps:setSpin(-1, 1)
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local min_spin = select(1, ps:getSpin())
    lurek.log.info("rotation " .. min_rotation .. ".." .. max_rotation .. " with min spin " .. min_spin)
end

--@api: LParticleSystem:setSpin
do

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi)
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local max_rotation = select(2, ps:getRotation())
    lurek.log.info("spin " .. min_spin .. ".." .. max_spin .. " across rotation " .. max_rotation)
end

--@api: LParticleSystem:getSpin
do

    local ps = lurek.particle.newSystem()
    ps:setShape("ring")
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local shape = ps:getShape()
    lurek.log.info("spin " .. min_spin .. ".." .. max_spin .. " for shape " .. shape)
end

--@api: LParticleSystem:setSpinVariation
do

    local ps = lurek.particle.newSystem()
    ps:setSpin(-2, 2)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_spin = select(2, ps:getSpin())
    lurek.log.info("spin variation " .. variation .. " with max spin " .. max_spin)
end

--@api: LParticleSystem:getSpinVariation
do

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, 0.5)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_rotation = select(2, ps:getRotation())
    lurek.log.info("spin variation " .. variation .. " with max rotation " .. max_rotation)
end

--@api: LParticleSystem:setRelativeRotation
do

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local shape = ps:getShape()
    lurek.log.info("relative rotation " .. tostring(relative) .. " for " .. shape)
end

--@api: LParticleSystem:hasRelativeRotation
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 4)
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local dir = ps:getDirection()
    lurek.log.info("relative rotation " .. tostring(relative) .. " at dir " .. dir)
end

--@api: LParticleSystem:setInsertMode
do

    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    lurek.log.info("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    lurek.log.info("mode = " .. ps:getInsertMode())
end

--@api: LParticleSystem:getInsertMode
do

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(32)
    ps:setInsertMode("bottom")
    local mode = ps:getInsertMode()
    local buffer = ps:getBufferSize()
    lurek.log.info("insert mode " .. mode .. " within pool " .. buffer)
end

--@api: LParticleSystem:setOffset
do

    local ps = lurek.particle.newSystem()
    ps:setPosition(200, 120)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local x, y = ps:getPosition()
    lurek.log.info("spawn offset " .. ox .. "," .. oy .. " from " .. x .. "," .. y)
end

--@api: LParticleSystem:getOffset
do

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local dir = ps:getDirection()
    lurek.log.info("offset " .. ox .. "," .. oy .. " for direction " .. dir)
end

--@api: LParticleSystem:setShape
do

    local ps = lurek.particle.newSystem()
    ps:setSizes(6, 2)
    ps:setShape("circle")
    local shape = ps:getShape()
    local size_count = #ps:getSizes()
    lurek.log.info("shape " .. shape .. " with " .. size_count .. " size keys")
end

--@api: LParticleSystem:getShape
do

    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.25)
    ps:setShape("circle")
    local shape = ps:getShape()
    local variation = ps:getSpinVariation()
    lurek.log.info("shape readback " .. shape .. " with spin variation " .. variation)
end

--@api: LParticleSystem:setFlipbook
do

    local ps = lurek.particle.newSystem()
    ps:setShape("square")
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local shape = ps:getShape()
    lurek.log.info("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps on " .. shape)
end

--@api: LParticleSystem:getFlipbook
do

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(30)
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local rate = ps:getEmissionRate()
    lurek.log.info("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps at rate " .. rate)
end

--@api: LParticleSystem:setBounds
do

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    lurek.log.info("bounds set")
    ps:clearBounds()
    lurek.log.info("bounds cleared")
end

--@api: LParticleSystem:clearBounds
do

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    lurek.log.info("bounds set")
    ps:clearBounds()
    lurek.log.info("bounds cleared")
end

--@api: LParticleSystem:setCustomEmissionShape
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
    lurek.log.info("custom shape emitted = " .. ps:count())
end

--@api: LParticleSystem:setOnDeathBatch
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
    lurek.log.info("deaths = " .. death_count)
end

--@api: LParticleSystem:drawToImage
do

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    lurek.log.info("drawToImage type = " .. image:type())
end

--@api: LParticleSystem:toImage
do

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    lurek.log.info("toImage type = " .. image:type())
end

--@api: LParticleSystem:drawExplosionToImage
do

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    lurek.log.info("explosion type = " .. image:type())
    lurek.log.info("explosion width = " .. image:getWidth())
end

--@api: LParticleSystem:drawRainToImage
do

    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    lurek.log.info("rain type = " .. image:type())
    lurek.log.info("rain height = " .. image:getHeight())
end

--@api: LParticleSystem:drawSparkTrailToImage
do

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    lurek.log.info("spark type = " .. image:type())
    lurek.log.info("spark width = " .. image:getWidth())
end

--@api: LParticleSystem:drawOverImage
do

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local image = lurek.image.newImageData(128, 128)
    image:fill(16, 16, 16, 255)

    local over = ps:drawOverImage(image)
    lurek.log.info("overlay type = " .. over:type())
    lurek.log.info("overlay width = " .. over:getWidth())
end

--@api: LParticleSystem:paintOnto
do

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(32, 32)
    ps:emit(12)
    ps:update(0.1)
    local image = lurek.image.newImageData(64, 64)

    ps:paintOnto(image)
    lurek.log.info("paint target type = " .. image:type())
    lurek.log.info("paint target height = " .. image:getHeight())
end

--@api: lurek.particle.drawLifecycleToImage
do

    local snapshots = {
        { 0, 0 },
        { 5, 12 },
        { 10, 4 },
    }
    local image = lurek.particle.drawLifecycleToImage(snapshots, 16, 128, 64)
    lurek.log.info("lifecycle type = " .. image:type())
    lurek.log.info("lifecycle width = " .. image:getWidth())
end

--@api: lurek.particle.newTrail
do

    local trail = lurek.particle.newTrail(2.0, 8)
    trail:pushPoint(0, 0)
    trail:pushPoint(24, 12)
    local type_name = trail:type()
    local lifetime = trail:getLifetime()
    lurek.log.info(type_name .. " lifetime " .. lifetime .. " with " .. trail:getPointCount() .. " points")
end

--@api: LTrail:pushPoint
do

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    lurek.log.info("points = " .. trail:getPointCount())
end

--@api: LTrail:getPointCount
do

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    lurek.log.info("points = " .. trail:getPointCount())
end

--@api: LTrail:clear
do

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    lurek.log.info("before clear = " .. trail:getPointCount())
    trail:clear()
    lurek.log.info("after clear = " .. trail:getPointCount())
end

--@api: LTrail:update
do

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    lurek.log.info("after update = " .. trail:getPointCount())
end

--@api: LTrail:setWidth
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local points = trail:getPointCount()
    lurek.log.info("trail width " .. start_width .. " -> " .. end_width .. " across " .. points .. " point(s)")
end

--@api: LTrail:getWidth
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local lifetime = trail:getLifetime()
    lurek.log.info("trail width " .. start_width .. " -> " .. end_width .. " lifetime " .. lifetime)
end

--@api: LTrail:setLifetime
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local points = trail:getPointCount()
    lurek.log.info("trail lifetime set to " .. lifetime .. " with " .. points .. " point(s)")
end

--@api: LTrail:getLifetime
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(4, 2)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local type_name = trail:type()
    lurek.log.info(type_name .. " lifetime readback " .. lifetime)
end

--@api: LTrail:setHeadColor
do

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    lurek.log.info("points = " .. trail:getPointCount())
end

--@api: LTrail:setTailColor
do

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    lurek.log.info("points = " .. trail:getPointCount())
end

--@api: LTrail:setMinDistance
do

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    lurek.log.info("points = " .. trail:getPointCount())
end

--@api: LTrail:drawToImage
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    lurek.log.info("trail image type = " .. image:type())
end

--@api: LTrail:typeOf
do

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    local is_trail = trail:typeOf("LTrail")
    local is_object = trail:typeOf("LObject")
    local points = trail:getPointCount()
    lurek.log.info("trail typeOf trail=" .. tostring(is_trail) .. " object=" .. tostring(is_object) .. " points=" .. points)
end

--- Particle Module Part 3: physics collision, trail type

--@api: LParticleSystem:clearCollidesWithPhysics
do

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    lurek.log.info("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    lurek.log.info("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LParticleSystem:hasCollidesWithPhysics
do

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    lurek.log.info("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LParticleSystem:setCollidesWithPhysics
do

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    lurek.log.info("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LTrail:type
do

    local trail = lurek.particle.newTrail(1.5, 8.0)
    trail:pushPoint(0, 0)
    trail:setWidth(8.0, 2.0)
    local type_name = trail:type()
    local points = trail:getPointCount()
    lurek.log.info("trail handle " .. type_name .. " stores " .. points .. " point(s)")
end

--@api: LParticleSystem:getStats
do

    local ps = lurek.particle.newSystem({ emissionRate = 40, maxParticles = 32, lifetimeMin = 2.0, lifetimeMax = 2.0 })
    ps:addAttractor(32, 32, 80, 64)
    ps:setBounds(64, -64, 48, -48, 0.5)
    ps:emit(6)
    ps:update(0.1)
    local stats = ps:getStats()

    lurek.log.info("live_particles = " .. tostring(stats.live_particles))
    lurek.log.info("state = " .. tostring(stats.state))
end

--@api: LParticleSystem:setShader
do
    local ps = lurek.particle.newSystem({ maxParticles = 32 })
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "particle" })
    ps:setShader(shader)
    lurek.log.info("[particle.example] shader bound=" .. tostring(ps:getShader() ~= nil))
end

--@api: LParticleSystem:getShader
do
    local ps = lurek.particle.newSystem({ maxParticles = 32 })
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "particle" })
    ps:setShader(shader)
    local active = ps:getShader()
    local target = active and active:getTarget() or "nil"
    ps:setShader(nil)
    lurek.log.info("[particle.example] shader target=" .. target)
end

--@api: LParticleSystem:setShaderUniform
do
    local ps = lurek.particle.newSystem({ maxParticles = 32 })
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "particle" })
    ps:setShader(shader)
    ps:setShaderUniform("glow_amount", 0.8)
    lurek.log.info("[particle.example] uniform=" .. tostring(shader:hasUniform("glow_amount")))
end

--@api: LParticleSystem:emitAt
do
    local ps = lurek.particle.newPreset("muzzle")
    ps:emitAt(48, 32, 6, 0)
    local x, y = ps:getPosition()
    local direction = ps:getDirection()
    ps:emitAt(x + 8, y, 2, direction)
    lurek.log.info("[particle.example] emitAt count=" .. tostring(ps:getCount()))
    lurek.log.info("[particle.example] emitAt pos=" .. tostring(x) .. "," .. tostring(y))
end
