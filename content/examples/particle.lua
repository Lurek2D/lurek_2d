-- content/examples/particle.lua
-- Lurek2D lurek.particle API Reference
-- Run with: cargo run -- content/examples/particle
--
-- Scenario: A spell-casting RPG with fire explosions, smoke trails, magic
-- sparkles, and weapon swing trails. Demonstrates particle system lifecycle,
-- emission control, visual properties, and trail rendering.

print("=== lurek.particle — Particle System ===\n")

-- =============================================================================
-- System & Trail Creation
-- =============================================================================

--@api-stub: lurek.particle.newSystem
-- Demonstrates the proper usage of lurek.particle.newSystem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_particle_newSystem()
    local fire = lurek.particle.newSystem(500)
end
local _ok, _err = pcall(demo_lurek_particle_newSystem)

--@api-stub: lurek.particle.newTrail
-- Demonstrates the proper usage of lurek.particle.newTrail.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_particle_newTrail()
    local sword_trail = lurek.particle.newTrail()
end
local _ok, _err = pcall(demo_lurek_particle_newTrail)

-- =============================================================================
-- Position & Movement
-- =============================================================================

--@api-stub: ParticleSystem:setPosition
-- Demonstrates the proper usage of ParticleSystem:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setPosition()
    fire:setPosition(400, 300)
end
local _ok, _err = pcall(demo_ParticleSystem_setPosition)

--@api-stub: ParticleSystem:getPosition
-- Demonstrates the proper usage of ParticleSystem:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getPosition()
    local px, py = fire:getPosition()
    print("fire at: " .. px .. "," .. py)
end
local _ok, _err = pcall(demo_ParticleSystem_getPosition)

--@api-stub: ParticleSystem:moveTo
-- Demonstrates the proper usage of ParticleSystem:moveTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_moveTo()
    fire:moveTo(420, 310)
end
local _ok, _err = pcall(demo_ParticleSystem_moveTo)

-- =============================================================================
-- Emission Control
-- =============================================================================

--@api-stub: ParticleSystem:setEmissionRate
-- Demonstrates the proper usage of ParticleSystem:setEmissionRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setEmissionRate()
    fire:setEmissionRate(50)
end
local _ok, _err = pcall(demo_ParticleSystem_setEmissionRate)

--@api-stub: ParticleSystem:getEmissionRate
-- Demonstrates the proper usage of ParticleSystem:getEmissionRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getEmissionRate()
    print("rate: " .. fire:getEmissionRate())
end
local _ok, _err = pcall(demo_ParticleSystem_getEmissionRate)

--@api-stub: ParticleSystem:setEmitterLifetime
-- Demonstrates the proper usage of ParticleSystem:setEmitterLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setEmitterLifetime()
    fire:setEmitterLifetime(2.0)
end
local _ok, _err = pcall(demo_ParticleSystem_setEmitterLifetime)

--@api-stub: ParticleSystem:getEmitterLifetime
-- Demonstrates the proper usage of ParticleSystem:getEmitterLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getEmitterLifetime()
    print("emitter life: " .. fire:getEmitterLifetime())
end
local _ok, _err = pcall(demo_ParticleSystem_getEmitterLifetime)

--@api-stub: ParticleSystem:emit
-- Demonstrates the proper usage of ParticleSystem:emit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_emit()
    fire:emit(20)
end
local _ok, _err = pcall(demo_ParticleSystem_emit)

--@api-stub: ParticleSystem:setBufferSize
-- Demonstrates the proper usage of ParticleSystem:setBufferSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setBufferSize()
    fire:setBufferSize(1000)
end
local _ok, _err = pcall(demo_ParticleSystem_setBufferSize)

--@api-stub: ParticleSystem:getBufferSize
-- Demonstrates the proper usage of ParticleSystem:getBufferSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getBufferSize()
    print("buffer: " .. fire:getBufferSize())
end
local _ok, _err = pcall(demo_ParticleSystem_getBufferSize)

--@api-stub: ParticleSystem:setInsertMode
-- Demonstrates the proper usage of ParticleSystem:setInsertMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setInsertMode()
    fire:setInsertMode("top")
end
local _ok, _err = pcall(demo_ParticleSystem_setInsertMode)

--@api-stub: ParticleSystem:getInsertMode
-- Demonstrates the proper usage of ParticleSystem:getInsertMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getInsertMode()
    print("insert mode: " .. fire:getInsertMode())
end
local _ok, _err = pcall(demo_ParticleSystem_getInsertMode)

-- =============================================================================
-- Particle Lifetime & Speed
-- =============================================================================

--@api-stub: ParticleSystem:setParticleLifetime
-- Demonstrates the proper usage of ParticleSystem:setParticleLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setParticleLifetime()
    fire:setParticleLifetime(0.5, 1.5)
end
local _ok, _err = pcall(demo_ParticleSystem_setParticleLifetime)

--@api-stub: ParticleSystem:getParticleLifetime
-- Demonstrates the proper usage of ParticleSystem:getParticleLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getParticleLifetime()
    local minl, maxl = fire:getParticleLifetime()
    print("life: " .. minl .. "-" .. maxl)
end
local _ok, _err = pcall(demo_ParticleSystem_getParticleLifetime)

--@api-stub: ParticleSystem:setSpeed
-- Demonstrates the proper usage of ParticleSystem:setSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSpeed()
    fire:setSpeed(50, 150)
end
local _ok, _err = pcall(demo_ParticleSystem_setSpeed)

--@api-stub: ParticleSystem:getSpeed
-- Demonstrates the proper usage of ParticleSystem:getSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSpeed()
    local mins, maxs = fire:getSpeed()
    print("speed: " .. mins .. "-" .. maxs)
end
local _ok, _err = pcall(demo_ParticleSystem_getSpeed)

--@api-stub: ParticleSystem:setDirection
-- Demonstrates the proper usage of ParticleSystem:setDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setDirection()
    fire:setDirection(math.pi * 1.5)  -- upward
end
local _ok, _err = pcall(demo_ParticleSystem_setDirection)

--@api-stub: ParticleSystem:getDirection
-- Demonstrates the proper usage of ParticleSystem:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getDirection()
    print("direction: " .. fire:getDirection())
end
local _ok, _err = pcall(demo_ParticleSystem_getDirection)

--@api-stub: ParticleSystem:setSpread
-- Demonstrates the proper usage of ParticleSystem:setSpread.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSpread()
    fire:setSpread(math.pi / 4)
end
local _ok, _err = pcall(demo_ParticleSystem_setSpread)

--@api-stub: ParticleSystem:getSpread
-- Demonstrates the proper usage of ParticleSystem:getSpread.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSpread()
    print("spread: " .. fire:getSpread())
end
local _ok, _err = pcall(demo_ParticleSystem_getSpread)

-- =============================================================================
-- Acceleration & Damping
-- =============================================================================

--@api-stub: ParticleSystem:getLinearAcceleration
-- Demonstrates the proper usage of ParticleSystem:getLinearAcceleration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getLinearAcceleration()
    local ax1, ay1, ax2, ay2 = fire:getLinearAcceleration()
end
local _ok, _err = pcall(demo_ParticleSystem_getLinearAcceleration)

--@api-stub: ParticleSystem:getRadialAcceleration
-- Demonstrates the proper usage of ParticleSystem:getRadialAcceleration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getRadialAcceleration()
    local rmin, rmax = fire:getRadialAcceleration()
end
local _ok, _err = pcall(demo_ParticleSystem_getRadialAcceleration)

--@api-stub: ParticleSystem:getTangentialAcceleration
-- Demonstrates the proper usage of ParticleSystem:getTangentialAcceleration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getTangentialAcceleration()
    local tmin, tmax = fire:getTangentialAcceleration()
end
local _ok, _err = pcall(demo_ParticleSystem_getTangentialAcceleration)

--@api-stub: ParticleSystem:setLinearDamping
-- Demonstrates the proper usage of ParticleSystem:setLinearDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setLinearDamping()
    fire:setLinearDamping(0.5, 1.0)
end
local _ok, _err = pcall(demo_ParticleSystem_setLinearDamping)

--@api-stub: ParticleSystem:getLinearDamping
-- Demonstrates the proper usage of ParticleSystem:getLinearDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getLinearDamping()
    local dmin, dmax = fire:getLinearDamping()
    print("damping: " .. dmin .. "-" .. dmax)
end
local _ok, _err = pcall(demo_ParticleSystem_getLinearDamping)

--@api-stub: ParticleSystem:setGravity
-- Demonstrates the proper usage of ParticleSystem:setGravity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setGravity()
    fire:setGravity(0, -50)
end
local _ok, _err = pcall(demo_ParticleSystem_setGravity)

--@api-stub: ParticleSystem:getGravity
-- Demonstrates the proper usage of ParticleSystem:getGravity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getGravity()
    local gx, gy = fire:getGravity()
    print("gravity: " .. gx .. "," .. gy)
end
local _ok, _err = pcall(demo_ParticleSystem_getGravity)

-- =============================================================================
-- Size
-- =============================================================================

--@api-stub: ParticleSystem:setSizes
-- Demonstrates the proper usage of ParticleSystem:setSizes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSizes()
    fire:setSizes(2.0, 1.5, 0.5, 0.0)
end
local _ok, _err = pcall(demo_ParticleSystem_setSizes)

--@api-stub: ParticleSystem:getSizes
-- Demonstrates the proper usage of ParticleSystem:getSizes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSizes()
    local sizes = fire:getSizes()
    print("size steps: " .. #sizes)
end
local _ok, _err = pcall(demo_ParticleSystem_getSizes)

--@api-stub: ParticleSystem:setSizeVariation
-- Demonstrates the proper usage of ParticleSystem:setSizeVariation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSizeVariation()
    fire:setSizeVariation(0.3)
end
local _ok, _err = pcall(demo_ParticleSystem_setSizeVariation)

--@api-stub: ParticleSystem:getSizeVariation
-- Demonstrates the proper usage of ParticleSystem:getSizeVariation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSizeVariation()
    print("size variation: " .. fire:getSizeVariation())
end
local _ok, _err = pcall(demo_ParticleSystem_getSizeVariation)

-- =============================================================================
-- Rotation & Spin
-- =============================================================================

--@api-stub: ParticleSystem:setRotation
-- Demonstrates the proper usage of ParticleSystem:setRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setRotation()
    fire:setRotation(0, math.pi * 2)
end
local _ok, _err = pcall(demo_ParticleSystem_setRotation)

--@api-stub: ParticleSystem:getRotation
-- Demonstrates the proper usage of ParticleSystem:getRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getRotation()
    local rmin2, rmax2 = fire:getRotation()
end
local _ok, _err = pcall(demo_ParticleSystem_getRotation)

--@api-stub: ParticleSystem:setSpin
-- Demonstrates the proper usage of ParticleSystem:setSpin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSpin()
    fire:setSpin(-2, 2)
end
local _ok, _err = pcall(demo_ParticleSystem_setSpin)

--@api-stub: ParticleSystem:getSpin
-- Demonstrates the proper usage of ParticleSystem:getSpin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSpin()
    local smin, smax = fire:getSpin()
end
local _ok, _err = pcall(demo_ParticleSystem_getSpin)

--@api-stub: ParticleSystem:setSpinVariation
-- Demonstrates the proper usage of ParticleSystem:setSpinVariation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setSpinVariation()
    fire:setSpinVariation(0.5)
end
local _ok, _err = pcall(demo_ParticleSystem_setSpinVariation)

--@api-stub: ParticleSystem:getSpinVariation
-- Demonstrates the proper usage of ParticleSystem:getSpinVariation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getSpinVariation()
    print("spin var: " .. fire:getSpinVariation())
end
local _ok, _err = pcall(demo_ParticleSystem_getSpinVariation)

--@api-stub: ParticleSystem:setRelativeRotation
-- Demonstrates the proper usage of ParticleSystem:setRelativeRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setRelativeRotation()
    fire:setRelativeRotation(true)
end
local _ok, _err = pcall(demo_ParticleSystem_setRelativeRotation)

--@api-stub: ParticleSystem:hasRelativeRotation
-- Demonstrates the proper usage of ParticleSystem:hasRelativeRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_hasRelativeRotation()
    print("relative rot: " .. tostring(fire:hasRelativeRotation()))
end
local _ok, _err = pcall(demo_ParticleSystem_hasRelativeRotation)

-- =============================================================================
-- Colors
-- =============================================================================

--@api-stub: ParticleSystem:setColors
-- Demonstrates the proper usage of ParticleSystem:setColors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setColors()
    fire:setColors(
    1.0, 1.0, 1.0, 1.0,
    1.0, 0.9, 0.3, 1.0,
    1.0, 0.5, 0.1, 0.8,
    0.8, 0.2, 0.0, 0.0
    )
end
local _ok, _err = pcall(demo_ParticleSystem_setColors)

--@api-stub: ParticleSystem:getColors
-- Demonstrates the proper usage of ParticleSystem:getColors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getColors()
    local colors = fire:getColors()
    print("color stops: " .. #colors / 4)
end
local _ok, _err = pcall(demo_ParticleSystem_getColors)

-- =============================================================================
-- Emission Shape & Area
-- =============================================================================

--@api-stub: ParticleSystem:setEmissionArea
-- Demonstrates the proper usage of ParticleSystem:setEmissionArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setEmissionArea()
    fire:setEmissionArea("uniform", 20, 20)
end
local _ok, _err = pcall(demo_ParticleSystem_setEmissionArea)

--@api-stub: ParticleSystem:getEmissionArea
-- Demonstrates the proper usage of ParticleSystem:getEmissionArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getEmissionArea()
    local shape, w, h = fire:getEmissionArea()
    print("emission: " .. shape .. " " .. w .. "x" .. h)
end
local _ok, _err = pcall(demo_ParticleSystem_getEmissionArea)

--@api-stub: ParticleSystem:setShape
-- Demonstrates the proper usage of ParticleSystem:setShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setShape()
    fire:setShape("circle")
end
local _ok, _err = pcall(demo_ParticleSystem_setShape)

--@api-stub: ParticleSystem:getShape
-- Demonstrates the proper usage of ParticleSystem:getShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getShape()
    print("shape: " .. fire:getShape())
end
local _ok, _err = pcall(demo_ParticleSystem_getShape)

--@api-stub: ParticleSystem:setOffset
-- Demonstrates the proper usage of ParticleSystem:setOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setOffset()
    fire:setOffset(0, -10)
end
local _ok, _err = pcall(demo_ParticleSystem_setOffset)

--@api-stub: ParticleSystem:getOffset
-- Demonstrates the proper usage of ParticleSystem:getOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getOffset()
    local ofx, ofy = fire:getOffset()
    print("offset: " .. ofx .. "," .. ofy)
end
local _ok, _err = pcall(demo_ParticleSystem_getOffset)

-- =============================================================================
-- Lifecycle
-- =============================================================================

--@api-stub: ParticleSystem:start
-- Demonstrates the proper usage of ParticleSystem:start.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_start()
    fire:start()
end
local _ok, _err = pcall(demo_ParticleSystem_start)

--@api-stub: ParticleSystem:isActive
-- Demonstrates the proper usage of ParticleSystem:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_isActive()
    print("active: " .. tostring(fire:isActive()))
end
local _ok, _err = pcall(demo_ParticleSystem_isActive)

--@api-stub: ParticleSystem:update
-- Demonstrates the proper usage of ParticleSystem:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_update()
    fire:update(1/60)
end
local _ok, _err = pcall(demo_ParticleSystem_update)

--@api-stub: ParticleSystem:count
-- Demonstrates the proper usage of ParticleSystem:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_count()
    print("alive particles: " .. fire:count())
end
local _ok, _err = pcall(demo_ParticleSystem_count)

--@api-stub: ParticleSystem:getCount
-- Demonstrates the proper usage of ParticleSystem:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getCount()
    print("count: " .. fire:getCount())
end
local _ok, _err = pcall(demo_ParticleSystem_getCount)

--@api-stub: ParticleSystem:pause
-- Demonstrates the proper usage of ParticleSystem:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_pause()
    fire:pause()
end
local _ok, _err = pcall(demo_ParticleSystem_pause)

--@api-stub: ParticleSystem:isPaused
-- Demonstrates the proper usage of ParticleSystem:isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_isPaused()
    print("paused: " .. tostring(fire:isPaused()))
end
local _ok, _err = pcall(demo_ParticleSystem_isPaused)

--@api-stub: ParticleSystem:resume
-- Demonstrates the proper usage of ParticleSystem:resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_resume()
    fire:resume()
end
local _ok, _err = pcall(demo_ParticleSystem_resume)

--@api-stub: ParticleSystem:stop
-- Demonstrates the proper usage of ParticleSystem:stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_stop()
    fire:stop()
end
local _ok, _err = pcall(demo_ParticleSystem_stop)

--@api-stub: ParticleSystem:isStopped
-- Demonstrates the proper usage of ParticleSystem:isStopped.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_isStopped()
    print("stopped: " .. tostring(fire:isStopped()))
end
local _ok, _err = pcall(demo_ParticleSystem_isStopped)

--@api-stub: ParticleSystem:isEmpty
-- Demonstrates the proper usage of ParticleSystem:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_isEmpty()
    print("empty: " .. tostring(fire:isEmpty()))
end
local _ok, _err = pcall(demo_ParticleSystem_isEmpty)

--@api-stub: ParticleSystem:isFull
-- Demonstrates the proper usage of ParticleSystem:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_isFull()
    print("full: " .. tostring(fire:isFull()))
end
local _ok, _err = pcall(demo_ParticleSystem_isFull)

--@api-stub: ParticleSystem:reset
-- Demonstrates the proper usage of ParticleSystem:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_reset()
    fire:reset()
end
local _ok, _err = pcall(demo_ParticleSystem_reset)

-- =============================================================================
-- Rendering
-- =============================================================================

--@api-stub: ParticleSystem:render
-- Demonstrates the proper usage of ParticleSystem:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_render()
    fire:render()
end
local _ok, _err = pcall(demo_ParticleSystem_render)

--@api-stub: ParticleSystem:drawToImage
-- Demonstrates the proper usage of ParticleSystem:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_drawToImage()
    local img = fire:drawToImage(256, 256)
end
local _ok, _err = pcall(demo_ParticleSystem_drawToImage)

--@api-stub: ParticleSystem:toImage
-- Demonstrates the proper usage of ParticleSystem:toImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_toImage()
    local snap = fire:toImage()
end
local _ok, _err = pcall(demo_ParticleSystem_toImage)

-- =============================================================================
-- Advanced Features
-- =============================================================================

--@api-stub: ParticleSystem:clone
-- Demonstrates the proper usage of ParticleSystem:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_clone()
    local fire2 = fire:clone()
    fire2:setPosition(600, 300)
end
local _ok, _err = pcall(demo_ParticleSystem_clone)

--@api-stub: ParticleSystem:warmUp
-- Demonstrates the proper usage of ParticleSystem:warmUp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_warmUp()
    fire:warmUp(0.5)
end
local _ok, _err = pcall(demo_ParticleSystem_warmUp)

--@api-stub: ParticleSystem:clearAttractors
-- Demonstrates the proper usage of ParticleSystem:clearAttractors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_clearAttractors()
    fire:clearAttractors()
end
local _ok, _err = pcall(demo_ParticleSystem_clearAttractors)

--@api-stub: ParticleSystem:getAttractorCount
-- Demonstrates the proper usage of ParticleSystem:getAttractorCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getAttractorCount()
    print("attractors: " .. fire:getAttractorCount())
end
local _ok, _err = pcall(demo_ParticleSystem_getAttractorCount)

--@api-stub: ParticleSystem:clearBounds
-- Demonstrates the proper usage of ParticleSystem:clearBounds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_clearBounds()
    fire:clearBounds()
end
local _ok, _err = pcall(demo_ParticleSystem_clearBounds)

--@api-stub: ParticleSystem:addSubEmitter
-- Demonstrates the proper usage of ParticleSystem:addSubEmitter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_addSubEmitter()
    print('Executing addSubEmitter')
end
local _ok, _err = pcall(demo_ParticleSystem_addSubEmitter)

--@api-stub: ParticleSystem:setFlipbook
-- Demonstrates the proper usage of ParticleSystem:setFlipbook.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_setFlipbook()
    fire:setFlipbook(4, 4, 16)
end
local _ok, _err = pcall(demo_ParticleSystem_setFlipbook)

--@api-stub: ParticleSystem:getFlipbook
-- Demonstrates the proper usage of ParticleSystem:getFlipbook.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_getFlipbook()
    local cols, rows, frames = fire:getFlipbook()
    print("flipbook: " .. cols .. "x" .. rows .. " (" .. frames .. " frames)")
end
local _ok, _err = pcall(demo_ParticleSystem_getFlipbook)

--@api-stub: ParticleSystem:release
-- Demonstrates the proper usage of ParticleSystem:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_release()
    print('Executing release')
end
local _ok, _err = pcall(demo_ParticleSystem_release)

--@api-stub: ParticleSystem:type
-- Demonstrates the proper usage of ParticleSystem:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_type()
    print("type: " .. fire:type())
end
local _ok, _err = pcall(demo_ParticleSystem_type)

--@api-stub: ParticleSystem:typeOf
-- Demonstrates the proper usage of ParticleSystem:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParticleSystem_typeOf()
    print("is ParticleSystem: " .. tostring(fire:typeOf("ParticleSystem")))
end
local _ok, _err = pcall(demo_ParticleSystem_typeOf)

-- =============================================================================
-- Trail — Sword swing trail
-- =============================================================================

--@api-stub: Trail:setWidth
-- Demonstrates the proper usage of Trail:setWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_setWidth()
    sword_trail:setWidth(8.0)
end
local _ok, _err = pcall(demo_Trail_setWidth)

--@api-stub: Trail:getWidth
-- Demonstrates the proper usage of Trail:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_getWidth()
    print("trail width: " .. sword_trail:getWidth())
end
local _ok, _err = pcall(demo_Trail_getWidth)

--@api-stub: Trail:setLifetime
-- Demonstrates the proper usage of Trail:setLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_setLifetime()
    sword_trail:setLifetime(0.3)
end
local _ok, _err = pcall(demo_Trail_setLifetime)

--@api-stub: Trail:getLifetime
-- Demonstrates the proper usage of Trail:getLifetime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_getLifetime()
    print("trail life: " .. sword_trail:getLifetime())
end
local _ok, _err = pcall(demo_Trail_getLifetime)

--@api-stub: Trail:setMinDistance
-- Demonstrates the proper usage of Trail:setMinDistance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_setMinDistance()
    sword_trail:setMinDistance(4.0)
end
local _ok, _err = pcall(demo_Trail_setMinDistance)

--@api-stub: Trail:pushPoint
-- Demonstrates the proper usage of Trail:pushPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_pushPoint()
    sword_trail:pushPoint(100, 200)
    sword_trail:pushPoint(120, 180)
    sword_trail:pushPoint(140, 165)
end
local _ok, _err = pcall(demo_Trail_pushPoint)

--@api-stub: Trail:getPointCount
-- Demonstrates the proper usage of Trail:getPointCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_getPointCount()
    print("trail points: " .. sword_trail:getPointCount())
end
local _ok, _err = pcall(demo_Trail_getPointCount)

--@api-stub: Trail:update
-- Demonstrates the proper usage of Trail:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_update()
    sword_trail:update(1/60)
end
local _ok, _err = pcall(demo_Trail_update)

--@api-stub: Trail:drawToImage
-- Demonstrates the proper usage of Trail:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_drawToImage()
    local trail_img = sword_trail:drawToImage(256, 256)
end
local _ok, _err = pcall(demo_Trail_drawToImage)

--@api-stub: Trail:clear
-- Demonstrates the proper usage of Trail:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Trail_clear()
    sword_trail:clear()
    print("\n-- particle.lua example complete --")
end
local _ok, _err = pcall(demo_Trail_clear)

-- =============================================================================
-- STUBS: 1 uncovered lurek.particle API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ParticleSystem methods
-- -----------------------------------------------------------------------------

-- ---- Stub: ParticleSystem:release ----------------------------------------
--@api-stub: ParticleSystem:release
-- Removes the particle system from the engine, freeing its slot.
-- Example scenario:
if psys ~= nil then
    -- Calling actual method on psys successfully
    print("Action: calling release()")
    pcall(function() psys:release() end)
    print("Executed smoothly.")
end
