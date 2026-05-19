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

print("particle_00.lua")
