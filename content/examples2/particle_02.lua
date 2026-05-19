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

print("particle_02.lua")
