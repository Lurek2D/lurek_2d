-- content/examples/particle.lua
-- Auto-generated from content/examples2/particle_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/particle.lua


--- Particle Module Part 1: system creation, presets, basic config


--@api: lurek.particle.newSystem
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        seed = 42,
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })

    example_print_log("type = " .. ps:type())
    example_print_log("buffer = " .. ps:getBufferSize())
end

--@api: lurek.particle.newPreset
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)
    fire:setEmissionRate(48)
    local x, y = fire:getPosition()
    local rate = fire:getEmissionRate()
    particle_log("campfire preset at " .. x .. "," .. y .. " emits " .. rate)
end

--@api: lurek.particle.fromTOML
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "save/particle_example.toml"
    lurek.filesystem.write(path, "seed = 42\nmax_particles = 96\nemission_rate = 18.0\nlifetime_min = 0.2\nlifetime_max = 0.8\n")

    local ps = lurek.particle.fromTOML(path)
    example_print_log("type = " .. ps:type())
    example_print_log("buffer = " .. ps:getBufferSize())
end

--@api: LParticleSystem:setBufferSize
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(60)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    particle_log("boss explosion pool resized to " .. buffer)
end

--@api: LParticleSystem:getBufferSize
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(90)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    local rate = ps:getEmissionRate()
    particle_log("buffer " .. buffer .. " supports rate " .. rate)
end

--@api: LParticleSystem:setPosition
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(20)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local rate = ps:getEmissionRate()
    particle_log("torch ember emitter moved to " .. x .. "," .. y .. " at rate " .. rate)
end

--@api: LParticleSystem:getPosition
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setOffset(12, -4)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local ox, oy = ps:getOffset()
    particle_log("projectile trail anchor " .. x .. "," .. y .. " offset " .. ox .. "," .. oy)
end

--@api: LParticleSystem:moveTo
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    example_print_log("moved = " .. x .. "," .. y)
end

--@api: LParticleSystem:setEmissionRate
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(256)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local buffer = ps:getBufferSize()
    particle_log("rain emitter rate " .. rate .. " within pool " .. buffer)
end

--@api: LParticleSystem:getEmissionRate
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.2, 0.8)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local min_life = select(1, ps:getParticleLifetime())
    particle_log("muzzle flash emits " .. rate .. " with min lifetime " .. min_life)
end

--@api: LParticleSystem:setParticleLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(32)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local rate = ps:getEmissionRate()
    particle_log("smoke lifetime " .. min_life .. ".." .. max_life .. " at rate " .. rate)
end

--@api: LParticleSystem:getParticleLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(20, 80)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local max_speed = select(2, ps:getSpeed())
    particle_log("spark lifetime " .. min_life .. ".." .. max_life .. " with speed ceiling " .. max_speed)
end

--@api: LParticleSystem:setEmitterLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(18)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local rate = ps:getEmissionRate()
    particle_log("one-shot vent runs for " .. emitter_life .. "s at rate " .. rate)
end

--@api: LParticleSystem:getEmitterLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 180)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local x = select(1, ps:getPosition())
    particle_log("storm cloud at x=" .. x .. " lives " .. emitter_life .. "s")
end

--@api: LParticleSystem:setSpeed
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local dir = ps:getDirection()
    particle_log("debris speed " .. min_speed .. ".." .. max_speed .. " toward " .. dir)
end

--@api: LParticleSystem:getSpeed
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 12)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local spread = ps:getSpread()
    particle_log("fountain speed " .. min_speed .. ".." .. max_speed .. " with spread " .. spread)
end

--@api: LParticleSystem:setDirection
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 10)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local spread = ps:getSpread()
    particle_log("steam vent faces " .. dir .. " with spread " .. spread)
end

--@api: LParticleSystem:getDirection
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(40, 60)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local min_speed = select(1, ps:getSpeed())
    particle_log("leaf burst direction " .. dir .. " from speed floor " .. min_speed)
end

--@api: LParticleSystem:setSpread
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local dir = ps:getDirection()
    particle_log("shotgun spark cone " .. spread .. " around " .. dir)
end

--@api: LParticleSystem:getSpread
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(24)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local rate = ps:getEmissionRate()
    particle_log("ember spread " .. spread .. " with rate " .. rate)
end

--@api: LParticleSystem:setGravity
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(60, 90)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_speed = select(2, ps:getSpeed())
    particle_log("snowfall gravity " .. gx .. "," .. gy .. " against speed " .. max_speed)
end

--@api: LParticleSystem:getGravity
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 1.5)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_life = select(2, ps:getParticleLifetime())
    particle_log("dust gravity " .. gx .. "," .. gy .. " over lifetime " .. max_life)
end

--@api: LParticleSystem:setSizes
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    example_print_log("size count = " .. #sizes)
    example_print_log("first size = " .. sizes[1])
end

--@api: LParticleSystem:getSizes
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    example_print_log("size count = " .. #sizes)
    example_print_log("last size = " .. sizes[#sizes])
end

--@api: LParticleSystem:setSizeVariation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local sizes = ps:getSizes()
    particle_log("spark size variation " .. variation .. " across " .. #sizes .. " keyframes")
end

--@api: LParticleSystem:getSizeVariation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local first_size = ps:getSizes()[1]
    particle_log("size variation " .. variation .. " with first size " .. first_size)
end

--@api: LParticleSystem:setColors
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    example_print_log("color keyframes = " .. #colors)
    example_print_log("first alpha = " .. colors[1][4])
end

--@api: LParticleSystem:getColors
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    example_print_log("color keyframes = " .. #colors)
    example_print_log("last alpha = " .. colors[#colors][4])
end

--- Particle Module Part 2: lifecycle, emission, rendering, cloning

--@api: LParticleSystem:start
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    example_print_log("active = " .. tostring(ps:isActive()))
    example_print_log("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:stop
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    ps:stop()
    example_print_log("active = " .. tostring(ps:isActive()))
    example_print_log("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:isActive
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:update(0.05)
    local active = ps:isActive()
    local count = ps:count()
    particle_log("bonfire active = " .. tostring(active) .. " with " .. count .. " live particles")
end

--@api: LParticleSystem:isStopped
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    example_print_log("stopped = " .. tostring(ps:isStopped()))
end

--@api: LParticleSystem:pause
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    example_print_log("paused = " .. tostring(ps:isPaused()))
end

--@api: LParticleSystem:resume
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    example_print_log("paused = " .. tostring(ps:isPaused()))
    example_print_log("active = " .. tostring(ps:isActive()))
end

--@api: LParticleSystem:isPaused
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    example_print_log("paused = " .. tostring(ps:isPaused()))
end

--@api: LParticleSystem:emit
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)

    example_print_log("after emit = " .. ps:count())
end

--@api: LParticleSystem:warmUp
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)
    local count = ps:count()
    local active = ps:isActive()
    particle_log("rain warmed to " .. count .. " drops active=" .. tostring(active))
end

--@api: LParticleSystem:update
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("count after update = " .. ps:count())
end

--@api: LParticleSystem:render
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("count before render = " .. ps:count())
end

--@api: LParticleSystem:reset
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    example_print_log("before reset = " .. ps:count())
    ps:reset()
    example_print_log("after reset = " .. ps:count())
end

--@api: LParticleSystem:clone
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
        emissionRate = 75,
    })
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)

    local copy = ps:clone()
    example_print_log("clone buffer = " .. copy:getBufferSize())
    example_print_log("clone rate = " .. copy:getEmissionRate())
end

--@api: LParticleSystem:isEmpty
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:setEmissionRate(0)
    ps:emit(0)
    local empty = ps:isEmpty()
    local count = ps:count()
    particle_log("fresh system empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LParticleSystem:isFull
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    example_print_log("full = " .. tostring(ps:isFull()))
end

--@api: LParticleSystem:count
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    example_print_log("count = " .. ps:count())
end

--@api: LParticleSystem:getCount
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    example_print_log("getCount = " .. ps:getCount())
end

--@api: LParticleSystem:release
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(12)
    ps:emit(5)
    local ok = ps:release()
    local type_name = ps:type()
    particle_log("release returned " .. tostring(ok) .. " for " .. type_name)
end

--@api: LParticleSystem:type
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(16)
    local type_name = ps:type()
    local is_particle = ps:typeOf("LParticleSystem")
    local is_drawable = ps:typeOf("LDrawable")
    particle_log(type_name .. " particle=" .. tostring(is_particle) .. " drawable=" .. tostring(is_drawable))
end

--@api: LParticleSystem:typeOf
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(8)
    local particle = ps:typeOf("LParticleSystem")
    local drawable = ps:typeOf("LDrawable")
    local object = ps:typeOf("LObject")
    particle_log("typeOf particle=" .. tostring(particle) .. " drawable=" .. tostring(drawable) .. " object=" .. tostring(object))
end

--@api: LParticleSystem:setLinearAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(30, 60)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local speed = select(2, ps:getSpeed())
    particle_log("wind accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " speed " .. speed)
end

--@api: LParticleSystem:getLinearAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local dir = ps:getDirection()
    particle_log("read accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " dir " .. dir)
end

--@api: LParticleSystem:setLinearDamping
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(120, 180)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local speed = select(2, ps:getSpeed())
    particle_log("air drag " .. min_damping .. ".." .. max_damping .. " with max speed " .. speed)
end

--@api: LParticleSystem:getLinearDamping
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.6, 1.2)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local max_life = select(2, ps:getParticleLifetime())
    particle_log("damping " .. min_damping .. ".." .. max_damping .. " over " .. max_life .. "s")
end

--@api: LParticleSystem:setRadialAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 240)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local x = select(1, ps:getPosition())
    particle_log("shockwave radial accel " .. min_radial .. ".." .. max_radial .. " from x=" .. x)
end

--@api: LParticleSystem:getRadialAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi * 2)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local spread = ps:getSpread()
    particle_log("radial accel " .. min_radial .. ".." .. max_radial .. " with spread " .. spread)
end

--@api: LParticleSystem:setTangentialAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local dir = ps:getDirection()
    particle_log("swirl tangential accel " .. min_tangent .. ".." .. max_tangent .. " around " .. dir)
end

--@api: LParticleSystem:getTangentialAcceleration
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(128, 96)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local y = select(2, ps:getPosition())
    particle_log("tangential accel " .. min_tangent .. ".." .. max_tangent .. " near y=" .. y)
end

--- Particle Module Part 3: advanced — attractors, sub-emitters, trails, physics, custom shapes

--@api: LParticleSystem:addAttractor
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("attractors = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:getAttractorCount
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("attractors = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:clearAttractors
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("before clear = " .. ps:getAttractorCount())
    ps:clearAttractors()
    example_print_log("after clear = " .. ps:getAttractorCount())
end

--@api: LParticleSystem:addSubEmitter
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("sub-systems = " .. ps:subSystemCount())
end

--@api: LParticleSystem:addSubSystem
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("sub-system index = " .. idx)
    example_print_log("sub-system count = " .. ps:subSystemCount())
end

--@api: LParticleSystem:subSystemCount
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("sub-system count = " .. ps:subSystemCount())
end

--@api: LParticleSystem:setEmissionArea
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    example_print_log("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    example_print_log("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
end

--@api: LParticleSystem:getEmissionArea
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 3)
    ps:setEmissionArea("uniform", 100, 50)
    local dist, width, height = ps:getEmissionArea()
    local dir = ps:getDirection()
    particle_log("spawn area " .. dist .. " " .. width .. "x" .. height .. " dir " .. dir)
end

--@api: LParticleSystem:setRotation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local shape = ps:getShape()
    particle_log("shrapnel rotation " .. min_rotation .. ".." .. max_rotation .. " shape " .. shape)
end

--@api: LParticleSystem:getRotation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpin(-1, 1)
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local min_spin = select(1, ps:getSpin())
    particle_log("rotation " .. min_rotation .. ".." .. max_rotation .. " with min spin " .. min_spin)
end

--@api: LParticleSystem:setSpin
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi)
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local max_rotation = select(2, ps:getRotation())
    particle_log("spin " .. min_spin .. ".." .. max_spin .. " across rotation " .. max_rotation)
end

--@api: LParticleSystem:getSpin
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("ring")
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local shape = ps:getShape()
    particle_log("spin " .. min_spin .. ".." .. max_spin .. " for shape " .. shape)
end

--@api: LParticleSystem:setSpinVariation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpin(-2, 2)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_spin = select(2, ps:getSpin())
    particle_log("spin variation " .. variation .. " with max spin " .. max_spin)
end

--@api: LParticleSystem:getSpinVariation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, 0.5)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_rotation = select(2, ps:getRotation())
    particle_log("spin variation " .. variation .. " with max rotation " .. max_rotation)
end

--@api: LParticleSystem:setRelativeRotation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local shape = ps:getShape()
    particle_log("relative rotation " .. tostring(relative) .. " for " .. shape)
end

--@api: LParticleSystem:hasRelativeRotation
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 4)
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local dir = ps:getDirection()
    particle_log("relative rotation " .. tostring(relative) .. " at dir " .. dir)
end

--@api: LParticleSystem:setInsertMode
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    example_print_log("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    example_print_log("mode = " .. ps:getInsertMode())
end

--@api: LParticleSystem:getInsertMode
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(32)
    ps:setInsertMode("bottom")
    local mode = ps:getInsertMode()
    local buffer = ps:getBufferSize()
    particle_log("insert mode " .. mode .. " within pool " .. buffer)
end

--@api: LParticleSystem:setOffset
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(200, 120)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local x, y = ps:getPosition()
    particle_log("spawn offset " .. ox .. "," .. oy .. " from " .. x .. "," .. y)
end

--@api: LParticleSystem:getOffset
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local dir = ps:getDirection()
    particle_log("offset " .. ox .. "," .. oy .. " for direction " .. dir)
end

--@api: LParticleSystem:setShape
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(6, 2)
    ps:setShape("circle")
    local shape = ps:getShape()
    local size_count = #ps:getSizes()
    particle_log("shape " .. shape .. " with " .. size_count .. " size keys")
end

--@api: LParticleSystem:getShape
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.25)
    ps:setShape("circle")
    local shape = ps:getShape()
    local variation = ps:getSpinVariation()
    particle_log("shape readback " .. shape .. " with spin variation " .. variation)
end

--@api: LParticleSystem:setFlipbook
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("square")
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local shape = ps:getShape()
    particle_log("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps on " .. shape)
end

--@api: LParticleSystem:getFlipbook
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(30)
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local rate = ps:getEmissionRate()
    particle_log("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps at rate " .. rate)
end

--@api: LParticleSystem:setBounds
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    example_print_log("bounds set")
    ps:clearBounds()
    example_print_log("bounds cleared")
end

--@api: LParticleSystem:clearBounds
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    example_print_log("bounds set")
    ps:clearBounds()
    example_print_log("bounds cleared")
end

--@api: LParticleSystem:setCustomEmissionShape
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("custom shape emitted = " .. ps:count())
end

--@api: LParticleSystem:setOnDeathBatch
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("deaths = " .. death_count)
end

--@api: LParticleSystem:drawToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    example_print_log("drawToImage type = " .. image:type())
end

--@api: LParticleSystem:toImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    example_print_log("toImage type = " .. image:type())
end

--@api: LParticleSystem:drawExplosionToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    example_print_log("explosion type = " .. image:type())
    example_print_log("explosion width = " .. image:getWidth())
end

--@api: LParticleSystem:drawRainToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    example_print_log("rain type = " .. image:type())
    example_print_log("rain height = " .. image:getHeight())
end

--@api: LParticleSystem:drawSparkTrailToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    example_print_log("spark type = " .. image:type())
    example_print_log("spark width = " .. image:getWidth())
end

--@api: LParticleSystem:drawOverImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local image = lurek.image.newImageData(128, 128)
    image:fill(16, 16, 16, 255)

    local over = ps:drawOverImage(image)
    example_print_log("overlay type = " .. over:type())
    example_print_log("overlay width = " .. over:getWidth())
end

--@api: LParticleSystem:paintOnto
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(32, 32)
    ps:emit(12)
    ps:update(0.1)
    local image = lurek.image.newImageData(64, 64)

    ps:paintOnto(image)
    example_print_log("paint target type = " .. image:type())
    example_print_log("paint target height = " .. image:getHeight())
end

--@api: lurek.particle.drawLifecycleToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local snapshots = {
        { 0, 0 },
        { 5, 12 },
        { 10, 4 },
    }
    local image = lurek.particle.drawLifecycleToImage(snapshots, 16, 128, 64)
    example_print_log("lifecycle type = " .. image:type())
    example_print_log("lifecycle width = " .. image:getWidth())
end

--@api: lurek.particle.newTrail
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 8)
    trail:pushPoint(0, 0)
    trail:pushPoint(24, 12)
    local type_name = trail:type()
    local lifetime = trail:getLifetime()
    particle_log(type_name .. " lifetime " .. lifetime .. " with " .. trail:getPointCount() .. " points")
end

--@api: LTrail:pushPoint
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    example_print_log("points = " .. trail:getPointCount())
end

--@api: LTrail:getPointCount
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    example_print_log("points = " .. trail:getPointCount())
end

--@api: LTrail:clear
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    example_print_log("before clear = " .. trail:getPointCount())
    trail:clear()
    example_print_log("after clear = " .. trail:getPointCount())
end

--@api: LTrail:update
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    example_print_log("after update = " .. trail:getPointCount())
end

--@api: LTrail:setWidth
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local points = trail:getPointCount()
    particle_log("trail width " .. start_width .. " -> " .. end_width .. " across " .. points .. " point(s)")
end

--@api: LTrail:getWidth
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local lifetime = trail:getLifetime()
    particle_log("trail width " .. start_width .. " -> " .. end_width .. " lifetime " .. lifetime)
end

--@api: LTrail:setLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local points = trail:getPointCount()
    particle_log("trail lifetime set to " .. lifetime .. " with " .. points .. " point(s)")
end

--@api: LTrail:getLifetime
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(4, 2)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local type_name = trail:type()
    particle_log(type_name .. " lifetime readback " .. lifetime)
end

--@api: LTrail:setHeadColor
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    example_print_log("points = " .. trail:getPointCount())
end

--@api: LTrail:setTailColor
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    example_print_log("points = " .. trail:getPointCount())
end

--@api: LTrail:setMinDistance
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    example_print_log("points = " .. trail:getPointCount())
end

--@api: LTrail:drawToImage
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    example_print_log("trail image type = " .. image:type())
end

--@api: LTrail:typeOf
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    local is_trail = trail:typeOf("LTrail")
    local is_object = trail:typeOf("LObject")
    local points = trail:getPointCount()
    particle_log("trail typeOf trail=" .. tostring(is_trail) .. " object=" .. tostring(is_object) .. " points=" .. points)
end

--- Particle Module Part 3: physics collision, trail type

--@api: LParticleSystem:clearCollidesWithPhysics
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LParticleSystem:hasCollidesWithPhysics
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LParticleSystem:setCollidesWithPhysics
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end

--@api: LTrail:type
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.5, 8.0)
    trail:pushPoint(0, 0)
    trail:setWidth(8.0, 2.0)
    local type_name = trail:type()
    local points = trail:getPointCount()
    particle_log("trail handle " .. type_name .. " stores " .. points .. " point(s)")
end

--@api: LParticleSystem:getStats
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({ emissionRate = 40, maxParticles = 32, lifetimeMin = 2.0, lifetimeMax = 2.0 })
    ps:addAttractor(32, 32, 80, 64)
    ps:setBounds(64, -64, 48, -48, 0.5)
    ps:emit(6)
    ps:update(0.1)
    local stats = ps:getStats()

    example_print_log("live_particles = " .. tostring(stats.live_particles))
    example_print_log("state = " .. tostring(stats.state))
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

