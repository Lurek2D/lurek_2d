-- examples/particle.lua
-- lurek.particles — Emitter-based 2D particle systems and trail ribbons.

-- ── Creating a Particle System ────────────────────────────────────────────────

-- newSystem(config) → ParticleSystem
-- The config table controls every aspect of particle behaviour.
-- All fields are optional; unset fields use engine defaults.
local ps = lurek.particles.newSystem({
    -- Core emission settings
    maxParticles  = 500,        -- maximum live particles
    emissionRate  = 50,         -- particles per second (continuous)
    emitterLifetime = -1,       -- -1 = infinite; >0 = auto-stop after N seconds

    -- Particle lifetime range (seconds)
    lifetimeMin = 0.5,
    lifetimeMax = 1.5,

    -- Initial speed range
    speedMin = 40,
    speedMax = 120,

    -- Emission direction (radians) and angular spread (radians)
    direction = -math.pi / 2,  -- upward
    spread    = math.pi / 4,   -- ±45 degrees

    -- Per-particle acceleration
    gravityX = 0,
    gravityY = 200,

    -- Spin (rotation rate, radians/second)
    spinMin = -2,
    spinMax =  2,
    spinVariation = 0.5,  -- 0..1 random blend

    -- Initial rotation
    rotationMin = 0,
    rotationMax = math.pi * 2,

    -- Size keyframes (interpolated 0..1 over lifetime)
    -- 1 value = constant; multiple = keyframe gradient
    sizes = { 1.0, 0.5, 0.0 },  -- shrinks over lifetime

    -- Color keyframes — table of {r, g, b, a} tables
    colors = {
        { 1.0, 0.8, 0.2, 1.0 },  -- fiery yellow-orange
        { 1.0, 0.3, 0.0, 0.8 },  -- orange
        { 0.3, 0.3, 0.3, 0.0 },  -- dark grey smoke, fades out
    },

    -- Alpha keyframes (0..1), overrides colors[4] if provided
    -- alphaKeyframes = { 1, 1, 0.5, 0 },

    -- Emission area distribution
"uniform" | "normal" | "ellipse" | "borderRectangle" | "borderEllipse"
    areaDistribution = "uniform",
    areaWidth  = 0,
    areaHeight = 0,

    -- Emission shape
"point" | "circle" | "rectangle" | "ring" | "line" | "cone" | "star" | "spiral"
    emissionShape = "point",

    -- Particle draw shape: "square" | "circle" | "triangle" | "spark" | "diamond"
    shape = "circle",

    -- Relative emission mode: "detached" (default) | "attached"
    relativeMode = "detached",

    -- Physics
    linearDampingMin = 0.0,
    linearDampingMax = 0.1,
    radialAccelMin   = 0,
    radialAccelMax   = 0,
    tangentialAccelMin = 0,
    tangentialAccelMax = 0,
    linearAccelXMin = 0,
    linearAccelXMax = 0,
    linearAccelYMin = 0,
    linearAccelYMax = 0,

    -- Extra effects
    turbulence = 0,      -- random force magnitude each tick
    drag       = 0,      -- simple speed drag coefficient
    orbitSpeed = 0,      -- rotational drift speed
    offsetX    = 0,      -- emitter centre offset
    offsetY    = 0,

    -- Insert order: "top" | "bottom" | "random"
    insertMode = "top",

    -- Sprite sheet animation (if using a texture atlas)
    animatedFrames = 0,       -- 0 = single frame
    frameRate      = 12,

    -- Color-by-speed mapping
    colorBySpeed   = false,
    speedColorMin  = 0,
    speedColorMax  = 200,
})

-- ── Moving the Emitter ────────────────────────────────────────────────────────

-- moveTo(x, y) — reposition the emitter in world space
ps:moveTo(400, 300)

-- ── Emission Control ─────────────────────────────────────────────────────────

-- start() — begin continuous emission at emissionRate
ps:start()

-- emit(count) — fire a one-shot burst regardless of emissionRate
ps:emit(20)

-- pause() / resume()
ps:pause()
ps:resume()

-- stop() — halt new emission; live particles finish their lifetime
ps:stop()

-- reset() — kill all particles and reset the emitter
ps:reset()

-- ── State Queries ─────────────────────────────────────────────────────────────

-- count() → integer — number of live particles
local live = ps:count()

-- isActive() → boolean — emitting OR has live particles
local active = ps:isActive()

-- isPaused() → boolean
local paused = ps:isPaused()

-- isStopped() → boolean
local stopped = ps:isStopped()

-- isEmpty() → boolean — no live particles
local empty = ps:isEmpty()

-- isFull() → boolean — at max_particles
local full = ps:isFull()

-- ── Update / Draw ─────────────────────────────────────────────────────────────

-- update(dt) — call each frame to advance simulation
ps:update(lurek.time.getDelta())

-- To draw the particle system, pass it to lurek.gfx.draw():
lurek.gfx.draw(ps, 0, 0)

-- ── Release ───────────────────────────────────────────────────────────────────

-- release() — free the engine slot; ps is invalid afterwards
ps:release()

-- ── Trail Ribbons ─────────────────────────────────────────────────────────────

-- newTrail() → Trail
-- Trails produce a smooth ribbon following a moving point.
local trail = lurek.particles.newTrail()

-- setWidth(start_w, end_w?) — ribbon width at head and tail
trail:setWidth(8, 0)  -- tapers to a point

-- setLifetime(seconds) — how long each segment persists
trail:setLifetime(1.0)

-- setMinDistance(px) — minimum pixel distance before adding a new segment
trail:setMinDistance(4)

-- setHeadColor(r, g, b, a) / setTailColor(r, g, b, a)
trail:setHeadColor(1, 1, 0, 1)   -- bright yellow at head
trail:setTailColor(1, 0.2, 0, 0) -- fades to transparent orange at tail

-- getWidth() → start_w, end_w
local sw, ew = trail:getWidth()

-- getLifetime() → number
local lt = trail:getLifetime()

-- pushPoint(x, y) — add the current position each frame
trail:pushPoint(200, 300)

-- update(dt) — age and prune segments
trail:update(1/60)

-- getPointCount() → integer
local pts = trail:getPointCount()

-- clear() — remove all segments
trail:clear()

-- To draw: lurek.gfx.draw(trail, 0, 0)

-- ── Typical Particle Usage ────────────────────────────────────────────────────

--[[
function lurek.init()
    fire = lurek.particles.newSystem({
        maxParticles  = 300,
        emissionRate  = 80,
        lifetimeMin   = 0.4,
        lifetimeMax   = 1.0,
        speedMin      = 30,
        speedMax      = 90,
        direction     = -math.pi / 2,
        spread        = math.pi / 3,
        gravityY      = -60,  -- rises
        sizes         = { 1.0, 0.6, 0.0 },
        colors        = {{ 1, 0.9, 0.1, 1 }, { 1, 0.3, 0, 0.8 }, { 0.2, 0.2, 0.2, 0 }},
        shape         = "circle",
    })
    fire:moveTo(400, 500)
    fire:start()
end

function lurek.process(dt)
    fire:update(dt)
end

function lurek.render()
    lurek.gfx.draw(fire, 0, 0)
end
]]

-- ─── ParticleSystem ────────────────────────────────────────────────────────────

local clone = particlesystem:clone()  -- Creates a copy of this particle system (config only, no live particles)
local buffer_size = particlesystem:getBufferSize()  -- Returns the maximum particle count
local colors = particlesystem:getColors()  -- Returns color keyframes as a table of {r,g,b,a} tables
local count = particlesystem:getCount()  -- Returns the number of living particles (alias for count)
local direction = particlesystem:getDirection()  -- Returns emission direction in radians
local emission_area = particlesystem:getEmissionArea()  -- Returns emission area: dist-string, w, h
local emission_rate = particlesystem:getEmissionRate()  -- Returns particles emitted per second
local emitter_lifetime = particlesystem:getEmitterLifetime()  -- Returns the emitter lifetime
local gravity = particlesystem:getGravity()  -- Returns gravity (x, y)
local insert_mode = particlesystem:getInsertMode()  -- Returns the insert mode as a string
local linear_acceleration = particlesystem:getLinearAcceleration()  -- Returns linear acceleration range
local linear_damping = particlesystem:getLinearDamping()  -- Returns linear damping range
local offset = particlesystem:getOffset()  -- Returns the render origin offset
local particle_lifetime = particlesystem:getParticleLifetime()  -- Returns min and max particle lifetime
local position = particlesystem:getPosition()  -- Returns the emitter world position
local radial_acceleration = particlesystem:getRadialAcceleration()  -- Returns radial acceleration range
local rotation = particlesystem:getRotation()  -- Returns initial rotation range
local shape = particlesystem:getShape()  -- Returns the particle draw shape as a string
local size_variation = particlesystem:getSizeVariation()  -- Returns size variation
local sizes = particlesystem:getSizes()  -- Returns size keyframes as a Lua table
local speed = particlesystem:getSpeed()  -- Returns min/max initial speed
local spin = particlesystem:getSpin()  -- Returns angular velocity range
local spin_variation = particlesystem:getSpinVariation()  -- Returns spin variation
local spread = particlesystem:getSpread()  -- Returns emission spread
local tangential_acceleration = particlesystem:getTangentialAcceleration()  -- Returns tangential acceleration range
local has_relative_rotation = particlesystem:hasRelativeRotation()  -- Returns whether relative rotation is enabled
particlesystem:setBufferSize(1)  -- Sets the maximum number of particles (resizes the pool)
particlesystem:setColors({r=0.8, g=0.4, b=0.2, a=1.0})  -- Sets color keyframes. Each arg is a table {r, g, b, a}
particlesystem:setDirection(1.0)  -- Sets emission direction in radians
particlesystem:setEmissionArea("uniform", 20, 20)  -- width/height for uniform/normal distributionsize
particlesystem:setEmissionRate(1.0)  -- Sets particles emitted per second
particlesystem:setEmitterLifetime(1.0)  -- Sets how long the emitter runs before auto-stopping. Negative = infinite
particlesystem:setGravity(1.0, 1.0)  -- Sets gravity (x, y)
particlesystem:setInsertMode("top")  -- Insert new particles at the front ("top", "bottom", "random")dom"
particlesystem:setLinearAcceleration(1.0, 1.0, 1.0, 1.0)  -- Sets linear acceleration range
particlesystem:setLinearDamping(1.0, 1.0)  -- Sets linear damping range
particlesystem:setOffset(1.0, 1.0)  -- Sets the render origin offset
particlesystem:setParticleLifetime(1.0, 1.0)  -- Sets min and max particle lifetime in seconds
particlesystem:setPosition(1.0, 1.0)  -- Sets the emitter world position
particlesystem:setRadialAcceleration(1.0, 1.0)  -- Sets radial acceleration range
particlesystem:setRelativeRotation(false)  -- Sets whether particle rotation follows velocity direction
particlesystem:setRotation(1.0, 1.0)  -- Sets initial rotation range in radians
particlesystem:setShape("circle")  -- "circle", "square", "triangle", "spark", "diamond", "shrapnel", "ray", "puff", "ring", "capsule"
particlesystem:setSizeVariation(1.0)  -- Sets size variation (0–1)
particlesystem:setSizes(8, 16, 8)  -- Size keyframes: start=8, mid=16, end=8rame)
particlesystem:setSpeed(1.0, 1.0)  -- Sets min/max initial speed
particlesystem:setSpin(1.0, 1.0)  -- Sets angular velocity range
particlesystem:setSpinVariation(1.0)  -- Sets spin variation (0–1)
particlesystem:setSpread(1.0)  -- Sets emission spread (half-angle cone) in radians
particlesystem:setTangentialAcceleration(1.0, 1.0)  -- Sets tangential acceleration range
local particlesystem_type = particlesystem:type()  -- "ParticleSystem"
local particlesystem_is_type = particlesystem:typeOf("ParticleSystem")  -- Returns true if this matches the given type name

-- --- Sub-Emitters -------------------------------------------------------------
-- addSubEmitter(config_tbl, burst_count?) � burst secondary particles on death
--   config_tbl  : same keys as lurek.particles.new(opts)
--   burst_count : number? (default 1)
--
-- The spawned sub-particles use the config table for all properties.

local fire = lurek.particles.new({
    rate = 40, lifetime = { 0.4, 0.6 }, speed = { 80, 120 },
    colors = { {1,0.4,0,1}, {1,0.2,0,0} }
})

-- Each fire particle bursts 3 smoke particles when it dies:
fire:addSubEmitter({
    rate = 0, lifetime = { 0.8, 1.2 }, speed = { 20, 40 },
    colors = { {0.4,0.4,0.4,0.5}, {0.2,0.2,0.2,0} }
}, 3)

-- --- Flipbook Texture Animation -----------------------------------------------
-- setFlipbook(cols, rows, fps)  � auto-computes cols�rows UV quads from a texture
-- getFlipbook() ? cols, rows, fps  (or nil, nil, nil when not set)

local sparks = lurek.particles.new({ rate = 20, lifetime = { 0.3, 0.5 } })

-- A 4-column � 2-row sprite sheet animating at 12 FPS:
sparks:setFlipbook(4, 2, 12)

local cols, rows, fps = sparks:getFlipbook()
print(("flipbook: %d cols � %d rows @ %.0f FPS"):format(cols, rows, fps))
-- flipbook: 4 cols � 2 rows @ 12 FPS
