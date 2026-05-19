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

print("particle_01.lua")
