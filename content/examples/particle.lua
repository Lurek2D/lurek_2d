-- content/examples/particle.lua
-- love2d-style usage snippets for the lurek.particle API (84 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/particle.lua

-- ── lurek.particle.* functions ──

--@api-stub: lurek.particle.newSystem
-- Creates a new particle system and stores it in the engine pool.
-- Build once at startup; reuse across frames.
local system = lurek.particle.newSystem({ x = 0, y = 0 })
print("created", system)
return system

--@api-stub: lurek.particle.newTrail
-- Creates a new trail ribbon effect.
-- Build once at startup; reuse across frames.
local trail = lurek.particle.newTrail(lifetime, start_width)
print("created", trail)
return trail

-- ── ParticleSystem methods ──

--@api-stub: ParticleSystem:update
-- Advances the particle simulation by dt seconds.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:update(dt)
print("ParticleSystem:update applied")

--@api-stub: ParticleSystem:emit
-- Emits a burst of the given number of particles.
-- Side-effecting; safe to call any time after init.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:emit(10)
print("ParticleSystem:emit done")

--@api-stub: ParticleSystem:start
-- Starts or restarts particle emission.
-- Trigger from input, timers, or game events.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:start()
-- trigger from input, timer, or event
print("ok")

--@api-stub: ParticleSystem:stop
-- Stops particle emission immediately.
-- Trigger from input, timers, or game events.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:stop()
-- trigger from input, timer, or event
print("ok")

--@api-stub: ParticleSystem:pause
-- Pauses particle emission; existing particles continue to simulate.
-- Trigger from input, timers, or game events.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: ParticleSystem:resume
-- Resumes a paused emitter.
-- Trigger from input, timers, or game events.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:resume()
-- trigger from input, timer, or event
print("ok")

--@api-stub: ParticleSystem:reset
-- Removes all particles and resets the emitter.
-- Pair with the matching constructor to free resources.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:reset()
-- particleSystem is now released
print("ok")

--@api-stub: ParticleSystem:moveTo
-- Moves the emitter to the given world position.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:moveTo(100, 100)
print("ParticleSystem:moveTo done")

--@api-stub: ParticleSystem:count
-- Returns the number of living particles.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:count()
print("ParticleSystem:count ->", value)

--@api-stub: ParticleSystem:isActive
-- Returns true if the emitter is currently emitting or has live particles.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:isPaused
-- Returns true if the emitter is paused.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:isPaused() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:isStopped
-- Returns true if the emitter is stopped.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:isStopped() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:isEmpty
-- Returns true if there are no live particles.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:isFull
-- Returns true if the system has reached max_particles.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:isFull() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:release
-- Removes the particle system from the engine, freeing its slot.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:release()
print("ParticleSystem:release done")

--@api-stub: ParticleSystem:getCount
-- Returns the number of living particles (alias for count).
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getCount()
print("ParticleSystem:getCount ->", value)

--@api-stub: ParticleSystem:type
-- Returns the type name "ParticleSystem".
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:type()
print("ParticleSystem:type done")

--@api-stub: ParticleSystem:typeOf
-- Returns true if this matches the given type name.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:typeOf("main")
print("ParticleSystem:typeOf done")

--@api-stub: ParticleSystem:setPosition
-- Sets the emitter world position.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setPosition(100, 100)
print("ParticleSystem:setPosition applied")

--@api-stub: ParticleSystem:getPosition
-- Returns the emitter world position.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getPosition()
print("ParticleSystem:getPosition ->", value)

--@api-stub: ParticleSystem:setEmissionRate
-- Sets particles emitted per second.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setEmissionRate(rate)
print("ParticleSystem:setEmissionRate applied")

--@api-stub: ParticleSystem:getEmissionRate
-- Returns particles emitted per second.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getEmissionRate()
print("ParticleSystem:getEmissionRate ->", value)

--@api-stub: ParticleSystem:setParticleLifetime
-- Sets min and max particle lifetime in seconds.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setParticleLifetime(0, 100)
print("ParticleSystem:setParticleLifetime applied")

--@api-stub: ParticleSystem:getParticleLifetime
-- Returns min and max particle lifetime.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getParticleLifetime()
print("ParticleSystem:getParticleLifetime ->", value)

--@api-stub: ParticleSystem:setEmitterLifetime
-- Sets how long the emitter runs before auto-stopping.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setEmitterLifetime(t)
print("ParticleSystem:setEmitterLifetime applied")

--@api-stub: ParticleSystem:getEmitterLifetime
-- Returns the emitter lifetime.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getEmitterLifetime()
print("ParticleSystem:getEmitterLifetime ->", value)

--@api-stub: ParticleSystem:setSpeed
-- Sets min/max initial speed.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSpeed(0, 100)
print("ParticleSystem:setSpeed applied")

--@api-stub: ParticleSystem:getSpeed
-- Returns min/max initial speed.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSpeed()
print("ParticleSystem:getSpeed ->", value)

--@api-stub: ParticleSystem:setDirection
-- Sets emission direction in radians.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setDirection("data/file.txt")
print("ParticleSystem:setDirection applied")

--@api-stub: ParticleSystem:getDirection
-- Returns emission direction in radians.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getDirection()
print("ParticleSystem:getDirection ->", value)

--@api-stub: ParticleSystem:setSpread
-- Sets emission spread (half-angle cone) in radians.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSpread(spread)
print("ParticleSystem:setSpread applied")

--@api-stub: ParticleSystem:getSpread
-- Returns the half-angle spread in radians for the emission cone.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSpread()
print("ParticleSystem:getSpread ->", value)

--@api-stub: ParticleSystem:getLinearAcceleration
-- Returns linear acceleration range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getLinearAcceleration()
print("ParticleSystem:getLinearAcceleration ->", value)

--@api-stub: ParticleSystem:getRadialAcceleration
-- Returns radial acceleration range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getRadialAcceleration()
print("ParticleSystem:getRadialAcceleration ->", value)

--@api-stub: ParticleSystem:getTangentialAcceleration
-- Returns tangential acceleration range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getTangentialAcceleration()
print("ParticleSystem:getTangentialAcceleration ->", value)

--@api-stub: ParticleSystem:setLinearDamping
-- Sets linear damping range.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setLinearDamping(0, 100)
print("ParticleSystem:setLinearDamping applied")

--@api-stub: ParticleSystem:getLinearDamping
-- Returns linear damping range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getLinearDamping()
print("ParticleSystem:getLinearDamping ->", value)

--@api-stub: ParticleSystem:setSizes
-- Sets size keyframes (varargs: each number is one keyframe).
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSizes(sizes)
print("ParticleSystem:setSizes applied")

--@api-stub: ParticleSystem:getSizes
-- Returns size keyframes as a Lua table.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSizes()
print("ParticleSystem:getSizes ->", value)

--@api-stub: ParticleSystem:setSizeVariation
-- Sets size variation (0â€“1).
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSizeVariation(v)
print("ParticleSystem:setSizeVariation applied")

--@api-stub: ParticleSystem:getSizeVariation
-- Returns the maximum random size variation applied to newly emitted particles.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSizeVariation()
print("ParticleSystem:getSizeVariation ->", value)

--@api-stub: ParticleSystem:setRotation
-- Sets initial rotation range in radians.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setRotation(0, 100)
print("ParticleSystem:setRotation applied")

--@api-stub: ParticleSystem:getRotation
-- Returns initial rotation range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getRotation()
print("ParticleSystem:getRotation ->", value)

--@api-stub: ParticleSystem:setSpin
-- Sets angular velocity range.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSpin(0, 100)
print("ParticleSystem:setSpin applied")

--@api-stub: ParticleSystem:getSpin
-- Returns angular velocity range.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSpin()
print("ParticleSystem:getSpin ->", value)

--@api-stub: ParticleSystem:setSpinVariation
-- Sets spin variation (0â€“1).
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setSpinVariation(v)
print("ParticleSystem:setSpinVariation applied")

--@api-stub: ParticleSystem:getSpinVariation
-- Returns the maximum random angular velocity variation for new particles.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getSpinVariation()
print("ParticleSystem:getSpinVariation ->", value)

--@api-stub: ParticleSystem:setRelativeRotation
-- Sets whether particle rotation follows velocity direction.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setRelativeRotation(v)
print("ParticleSystem:setRelativeRotation applied")

--@api-stub: ParticleSystem:hasRelativeRotation
-- Returns whether relative rotation is enabled.
-- Use as a guard inside lurek.update or event handlers.
local particleSystem = lurek.particle.newParticleSystem()
if particleSystem:hasRelativeRotation() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ParticleSystem:setColors
-- Sets color keyframes.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setColors({1, 0.5, 0, 1})
print("ParticleSystem:setColors applied")

--@api-stub: ParticleSystem:getColors
-- Returns color keyframes as a table of {r,g,b,a} tables.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getColors()
print("ParticleSystem:getColors ->", value)

--@api-stub: ParticleSystem:setOffset
-- Sets the render origin offset.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setOffset(ox, oy)
print("ParticleSystem:setOffset applied")

--@api-stub: ParticleSystem:getOffset
-- Returns the render origin offset.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getOffset()
print("ParticleSystem:getOffset ->", value)

--@api-stub: ParticleSystem:setInsertMode
-- Sets the insert mode: "top", "bottom", or "random".
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setInsertMode(mode)
print("ParticleSystem:setInsertMode applied")

--@api-stub: ParticleSystem:getInsertMode
-- Returns the insert mode as a string.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getInsertMode()
print("ParticleSystem:getInsertMode ->", value)

--@api-stub: ParticleSystem:setBufferSize
-- Sets the maximum number of particles (resizes the pool).
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setBufferSize(10)
print("ParticleSystem:setBufferSize applied")

--@api-stub: ParticleSystem:getBufferSize
-- Returns the maximum particle count.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getBufferSize()
print("ParticleSystem:getBufferSize ->", value)

--@api-stub: ParticleSystem:setEmissionArea
-- Sets emission area distribution and size.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setEmissionArea(dist, 64, 64, 0, "data/file.txt")
print("ParticleSystem:setEmissionArea applied")

--@api-stub: ParticleSystem:getEmissionArea
-- Returns emission area: dist-string, w, h.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getEmissionArea()
print("ParticleSystem:getEmissionArea ->", value)

--@api-stub: ParticleSystem:setShape
-- Sets the particle draw shape.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setShape(shape)
print("ParticleSystem:setShape applied")

--@api-stub: ParticleSystem:getShape
-- Returns the particle draw shape as a string.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getShape()
print("ParticleSystem:getShape ->", value)

--@api-stub: ParticleSystem:getGravity
-- Returns the gravity acceleration applied to particles as two numbers `gx, gy`.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getGravity()
print("ParticleSystem:getGravity ->", value)

--@api-stub: ParticleSystem:setGravity
-- Sets the gravity acceleration applied to all active particles each frame.
-- Apply at startup or in response to user input.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:setGravity(gx, gy)
print("ParticleSystem:setGravity applied")

--@api-stub: ParticleSystem:render
-- Renders all live particles to the GPU command queue.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:render(ox, oy)
print("ParticleSystem:render done")

--@api-stub: ParticleSystem:clone
-- Creates a copy of this particle system (config only, no live particles).
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:clone()
print("ParticleSystem:clone done")

--@api-stub: ParticleSystem:drawToImage
-- Renders all live particles to a CPU ImageData.
-- Place inside `function lurek.render() ... end`.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:drawToImage(64, 64)
print("ParticleSystem:drawToImage done")

--@api-stub: ParticleSystem:toImage
-- Alias for `drawToImage`.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:toImage(64, 64)
print("ParticleSystem:toImage done")

--@api-stub: ParticleSystem:warmUp
-- Pre-simulates the particle system for `seconds` so it appears fully.
-- See the module spec for detailed semantics.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:warmUp(1.0)
print("ParticleSystem:warmUp done")

--@api-stub: ParticleSystem:clearAttractors
-- Removes all attractors from this particle system.
-- Pair with the matching constructor to free resources.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:clearAttractors()
-- particleSystem is now released
print("ok")

--@api-stub: ParticleSystem:getAttractorCount
-- Returns the number of attractors currently registered on this system.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getAttractorCount()
print("ParticleSystem:getAttractorCount ->", value)

--@api-stub: ParticleSystem:clearBounds
-- Removes the bounding rectangle so particles can move freely.
-- Pair with the matching constructor to free resources.
local particleSystem = lurek.particle.newParticleSystem()
particleSystem:clearBounds()
-- particleSystem is now released
print("ok")

--@api-stub: ParticleSystem:getFlipbook
-- Returns the current flipbook configuration as `(cols, rows, fps)`, or `nil` if not set.
-- Cheap to call; safe inside callbacks.
local particleSystem = lurek.particle.newParticleSystem()  -- or your existing handle
local value = particleSystem:getFlipbook()
print("ParticleSystem:getFlipbook ->", value)

-- ── Trail methods ──

--@api-stub: Trail:pushPoint
-- Appends a new point to the trail head.
-- Side-effecting; safe to call any time after init.
local trail = lurek.particle.newTrail()
trail:pushPoint(100, 100)
print("Trail:pushPoint done")

--@api-stub: Trail:update
-- Ages trail points and removes expired ones.
-- Apply at startup or in response to user input.
local trail = lurek.particle.newTrail()
trail:update(dt)
print("Trail:update applied")

--@api-stub: Trail:setWidth
-- Sets the start and end width of the trail ribbon.
-- Apply at startup or in response to user input.
local trail = lurek.particle.newTrail()
trail:setWidth(start, end)
print("Trail:setWidth applied")

--@api-stub: Trail:getWidth
-- Returns the start and end width.
-- Cheap to call; safe inside callbacks.
local trail = lurek.particle.newTrail()  -- or your existing handle
local value = trail:getWidth()
print("Trail:getWidth ->", value)

--@api-stub: Trail:setLifetime
-- Sets how long each trail point persists in seconds.
-- Apply at startup or in response to user input.
local trail = lurek.particle.newTrail()
trail:setLifetime(lifetime)
print("Trail:setLifetime applied")

--@api-stub: Trail:getLifetime
-- Returns the trail point lifetime in seconds.
-- Cheap to call; safe inside callbacks.
local trail = lurek.particle.newTrail()  -- or your existing handle
local value = trail:getLifetime()
print("Trail:getLifetime ->", value)

--@api-stub: Trail:setMinDistance
-- Sets the minimum distance between trail points.
-- Apply at startup or in response to user input.
local trail = lurek.particle.newTrail()
trail:setMinDistance(distance)
print("Trail:setMinDistance applied")

--@api-stub: Trail:getPointCount
-- Returns the number of active trail points.
-- Cheap to call; safe inside callbacks.
local trail = lurek.particle.newTrail()  -- or your existing handle
local value = trail:getPointCount()
print("Trail:getPointCount ->", value)

--@api-stub: Trail:clear
-- Removes all trail points.
-- Pair with the matching constructor to free resources.
local trail = lurek.particle.newTrail()
trail:clear()
-- trail is now released
print("ok")

--@api-stub: Trail:drawToImage
-- Renders the trail ribbon to a CPU ImageData.
-- Place inside `function lurek.render() ... end`.
local trail = lurek.particle.newTrail()
trail:drawToImage(64, 64)
print("Trail:drawToImage done")

