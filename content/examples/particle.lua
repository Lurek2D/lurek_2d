-- content/examples/particle.lua
-- lurek.particle API examples.
-- Run: cargo run -- content/examples/particle.lua

--@api-stub: lurek.particle.newSystem -- Creates a particle system from an optional config table
do -- lurek.particle.newSystem
  local fire = lurek.particle.newSystem({
    maxParticles = 256, emissionRate = 60,
    lifetimeMin = 0.4, lifetimeMax = 0.9,
    speedMin = 40, speedMax = 80, direction = -math.pi/2, spread = 0.3,
  })
  fire:setPosition(320, 240)
  fire:start()
end

--@api-stub: lurek.particle.newPreset -- Creates a particle system from a named preset
do -- lurek.particle.newPreset
  local smoke = lurek.particle.newPreset("smoke")
  smoke:setPosition(300, 260)
  smoke:start()
end

--@api-stub: ParticleSystem:setCollidesWithPhysics
do -- ParticleSystem:setCollidesWithPhysics
  local world = lurek.physics.newWorld(0, 9.81)
  local rain = lurek.particle.newPreset("rain")
  rain:setCollidesWithPhysics(world, 1.0, 0.4)
  if rain:hasCollidesWithPhysics() then
    rain:clearCollidesWithPhysics()
  end
end

--@api-stub: ParticleSystem:hasCollidesWithPhysics
do -- ParticleSystem:hasCollidesWithPhysics
  local world = lurek.physics.newWorld(0, 9.81)
  local ps = lurek.particle.newSystem({ maxParticles = 64 })
  ps:setCollidesWithPhysics(world)
  local enabled = ps:hasCollidesWithPhysics()
  lurek.log.debug("physics collision enabled=" .. tostring(enabled), "particle")
end

--@api-stub: ParticleSystem:clearCollidesWithPhysics
do -- ParticleSystem:clearCollidesWithPhysics
  local world = lurek.physics.newWorld(0, 9.81)
  local ps = lurek.particle.newSystem({ maxParticles = 64 })
  ps:setCollidesWithPhysics(world)
  ps:clearCollidesWithPhysics()
end

--@api-stub: lurek.particle.newTrail -- Creates a trail effect
do -- lurek.particle.newTrail
  local sword_trail = lurek.particle.newTrail(0.35, 12.0)
  sword_trail:setHeadColor(1.0, 0.95, 0.6, 1.0)
  sword_trail:setTailColor(1.0, 0.4, 0.0, 0.0)
  sword_trail:pushPoint(100, 200)
end

-- â”€â”€ ParticleSystem methods â”€â”€

--@api-stub: ParticleSystem:update
do -- ParticleSystem:update
  local sys = lurek.particle.newSystem({ maxParticles = 128, emissionRate = 30 })
  sys:start()
  function lurek.process(dt)
    sys:update(dt)
  end
end

--@api-stub: ParticleSystem:emit
do -- ParticleSystem:emit
  local hit = lurek.particle.newSystem({ maxParticles = 64, lifetimeMin = 0.2, lifetimeMax = 0.4 })
  hit:setPosition(160, 120)
  hit:emit(24)
end

--@api-stub: ParticleSystem:start
do -- ParticleSystem:start
  local rain = lurek.particle.newSystem({ maxParticles = 512, emissionRate = 200 })
  rain:setPosition(400, 0)
  rain:setEmissionArea("uniform", 800, 1)
  rain:start()
end

--@api-stub: ParticleSystem:stop
do -- ParticleSystem:stop
  local jet = lurek.particle.newSystem({ emissionRate = 100 })
  jet:start()
  function lurek.process(dt)
    if lurek.input.keyboard.isDown("space") then jet:stop() end
  end
end

--@api-stub: ParticleSystem:pause
do -- ParticleSystem:pause
  local steam = lurek.particle.newSystem({ emissionRate = 40 })
  steam:start()
  if lurek.input.keyboard.isDown("escape") then steam:pause() end
end

--@api-stub: ParticleSystem:resume
do -- ParticleSystem:resume
  local fog = lurek.particle.newSystem({ emissionRate = 20 })
  fog:start()
  fog:pause()
  fog:resume()
end

--@api-stub: ParticleSystem:reset
do -- ParticleSystem:reset
  local sparks = lurek.particle.newSystem({ maxParticles = 128, emissionRate = 80 })
  sparks:start()
  sparks:emit(60)
  sparks:reset()
end

--@api-stub: ParticleSystem:moveTo
do -- ParticleSystem:moveTo
  local exhaust = lurek.particle.newSystem({ emissionRate = 50, lifetimeMin = 0.3, lifetimeMax = 0.6 })
  exhaust:start()
  local ship = { x = 200, y = 300 }
  function lurek.process(dt)
    exhaust:moveTo(ship.x, ship.y + 16)
    exhaust:update(dt)
  end
end

--@api-stub: ParticleSystem:count
do -- ParticleSystem:count
  local smoke = lurek.particle.newSystem({ maxParticles = 200 })
  smoke:start()
  if smoke:count() < 50 then smoke:emit(10) end
end

--@api-stub: ParticleSystem:isActive
do -- ParticleSystem:isActive
  local explosion = lurek.particle.newSystem({ emitterLifetime = 0.1 })
  explosion:emit(80)
  if explosion:isActive() then
    lurek.log.debug("explosion still has live particles", "fx")
  end
end

--@api-stub: ParticleSystem:isPaused
do -- ParticleSystem:isPaused
  local fountain = lurek.particle.newSystem({ emissionRate = 30 })
  fountain:start()
  fountain:pause()
  if fountain:isPaused() then lurek.log.info("fountain frozen", "fx") end
end

--@api-stub: ParticleSystem:isStopped
do -- ParticleSystem:isStopped
  local burst = lurek.particle.newSystem({})
  if burst:isStopped() then burst:start() end
end

--@api-stub: ParticleSystem:isEmpty
do -- ParticleSystem:isEmpty
  local trail_fx = lurek.particle.newSystem({ emissionRate = 0 })
  trail_fx:emit(5)
  if trail_fx:isEmpty() then trail_fx:release() end
end

--@api-stub: ParticleSystem:isFull
do -- ParticleSystem:isFull
  local heavy = lurek.particle.newSystem({ maxParticles = 32, emissionRate = 200 })
  heavy:start()
  function lurek.process(dt)
    heavy:update(dt)
    if heavy:isFull() then heavy:setEmissionRate(50) end
  end
end

--@api-stub: ParticleSystem:release
do -- ParticleSystem:release
  local oneshot = lurek.particle.newSystem({ maxParticles = 16 })
  oneshot:emit(10)
  oneshot:release()
end

--@api-stub: ParticleSystem:getCount
do -- ParticleSystem:getCount
  local plume = lurek.particle.newSystem({ emissionRate = 25 })
  plume:start()
  local n = plume:getCount()
  lurek.log.debug("plume live=" .. n, "fx")
end

--@api-stub: ParticleSystem:type
do -- ParticleSystem:type
  local sys = lurek.particle.newSystem({})
  if sys:type() == "LParticleSystem" then
    sys:start()
  end
end

--@api-stub: ParticleSystem:typeOf
do -- ParticleSystem:typeOf
  local sys = lurek.particle.newSystem({})
  if sys:typeOf("Drawable") then
    lurek.log.info("particle system is drawable", "fx")
  end
end

--@api-stub: ParticleSystem:setPosition
do -- ParticleSystem:setPosition
  local muzzle = lurek.particle.newSystem({ emissionRate = 0 })
  muzzle:setPosition(220, 180)
  muzzle:emit(12)
end

--@api-stub: ParticleSystem:getPosition
do -- ParticleSystem:getPosition
  local sys = lurek.particle.newSystem({})
  sys:setPosition(50, 75)
  local x, y = sys:getPosition()
  lurek.log.debug("emitter at " .. x .. "," .. y, "fx")
end

--@api-stub: ParticleSystem:setEmissionRate
do -- ParticleSystem:setEmissionRate
  local rain = lurek.particle.newSystem({ maxParticles = 400 })
  rain:start()
  local intensity = 0.7
  rain:setEmissionRate(150 * intensity)
end

--@api-stub: ParticleSystem:getEmissionRate
do -- ParticleSystem:getEmissionRate
  local sys = lurek.particle.newSystem({ emissionRate = 80 })
  if sys:getEmissionRate() > 100 then
    sys:setEmissionRate(100)
  end
end

--@api-stub: ParticleSystem:setParticleLifetime
do -- ParticleSystem:setParticleLifetime
  local smoke = lurek.particle.newSystem({})
  smoke:setParticleLifetime(1.5, 3.0)
  smoke:setEmissionRate(20)
  smoke:start()
end

--@api-stub: ParticleSystem:getParticleLifetime
do -- ParticleSystem:getParticleLifetime
  local sys = lurek.particle.newSystem({ lifetimeMin = 0.5, lifetimeMax = 1.2 })
  local lo, hi = sys:getParticleLifetime()
  lurek.log.debug("lifetime " .. lo .. " to " .. hi, "fx")
end

--@api-stub: ParticleSystem:setEmitterLifetime
do -- ParticleSystem:setEmitterLifetime
  local explosion = lurek.particle.newSystem({ emissionRate = 200 })
  explosion:setEmitterLifetime(0.15)
  explosion:start()
end

--@api-stub: ParticleSystem:getEmitterLifetime
do -- ParticleSystem:getEmitterLifetime
  local sys = lurek.particle.newSystem({ emitterLifetime = 2.0 })
  if sys:getEmitterLifetime() < 0 then
    lurek.log.info("emitter runs forever", "fx")
  end
end

--@api-stub: ParticleSystem:setSpeed
do -- ParticleSystem:setSpeed
  local geyser = lurek.particle.newSystem({})
  geyser:setSpeed(180, 260)
  geyser:setDirection(-math.pi/2)
  geyser:setSpread(0.15)
  geyser:start()
end

--@api-stub: ParticleSystem:getSpeed
do -- ParticleSystem:getSpeed
  local sys = lurek.particle.newSystem({ speedMin = 40, speedMax = 90 })
  local lo, hi = sys:getSpeed()
  local trail_len = (hi - lo) * 0.1
  lurek.log.debug("derived trail len " .. trail_len, "fx")
end

--@api-stub: ParticleSystem:setDirection
do -- ParticleSystem:setDirection
  local jet = lurek.particle.newSystem({ emissionRate = 60 })
  jet:setDirection(math.pi)  -- shoot left
  jet:setSpeed(120, 160)
  jet:start()
end

--@api-stub: ParticleSystem:getDirection
do -- ParticleSystem:getDirection
  local sys = lurek.particle.newSystem({ direction = math.pi/4 })
  local dir = sys:getDirection()
  lurek.log.debug("emit dir rad=" .. dir, "fx")
end

--@api-stub: ParticleSystem:setSpread
do -- ParticleSystem:setSpread
  local snow = lurek.particle.newSystem({ emissionRate = 80 })
  snow:setDirection(math.pi/2)
  snow:setSpread(0.25)
  snow:start()
end

--@api-stub: ParticleSystem:getSpread
do -- ParticleSystem:getSpread
  local sys = lurek.particle.newSystem({ spread = 0.4 })
  local cone = sys:getSpread() * 2
  lurek.log.debug("full cone rad=" .. cone, "fx")
end

--@api-stub: ParticleSystem:getLinearAcceleration
do -- ParticleSystem:getLinearAcceleration
  local sys = lurek.particle.newSystem({})
  local xmn, ymn, xmx, ymx = sys:getLinearAcceleration()
  lurek.log.debug("accel x=[" .. xmn .. "," .. xmx .. "]", "fx")
end

--@api-stub: ParticleSystem:getRadialAcceleration
do -- ParticleSystem:getRadialAcceleration
  local sys = lurek.particle.newSystem({ radialAccelMin = -50, radialAccelMax = -20 })
  local lo, hi = sys:getRadialAcceleration()
  if hi < 0 then lurek.log.info("particles implode", "fx") end
end

--@api-stub: ParticleSystem:getTangentialAcceleration
do -- ParticleSystem:getTangentialAcceleration
  local sys = lurek.particle.newSystem({ tangentialAccelMin = 30, tangentialAccelMax = 60 })
  local lo, hi = sys:getTangentialAcceleration()
  lurek.log.debug("swirl " .. lo .. ".." .. hi, "fx")
end

--@api-stub: ParticleSystem:setLinearDamping
do -- ParticleSystem:setLinearDamping
  local dust = lurek.particle.newSystem({ emissionRate = 40 })
  dust:setLinearDamping(1.5, 2.5)
  dust:setSpeed(60, 100)
  dust:start()
end

--@api-stub: ParticleSystem:getLinearDamping
do -- ParticleSystem:getLinearDamping
  local sys = lurek.particle.newSystem({ linearDampingMin = 1.0, linearDampingMax = 2.0 })
  local lo, hi = sys:getLinearDamping()
  lurek.log.debug("damping " .. lo .. ".." .. hi, "fx")
end

--@api-stub: ParticleSystem:setSizes
do -- ParticleSystem:setSizes
  local puff = lurek.particle.newSystem({ emissionRate = 30 })
  puff:setSizes(2, 8, 16, 4)
  puff:setShape("circle")
  puff:start()
end

--@api-stub: ParticleSystem:getSizes
do -- ParticleSystem:getSizes
  local sys = lurek.particle.newSystem({})
  sys:setSizes(4, 12, 6)
  local sizes = sys:getSizes()
  lurek.log.debug("size keyframes=" .. #sizes, "fx")
end

--@api-stub: ParticleSystem:setSizeVariation
do -- ParticleSystem:setSizeVariation
  local sparks = lurek.particle.newSystem({ emissionRate = 50 })
  sparks:setSizes(3, 1)
  sparks:setSizeVariation(0.4)
  sparks:start()
end

--@api-stub: ParticleSystem:getSizeVariation
do -- ParticleSystem:getSizeVariation
  local sys = lurek.particle.newSystem({ sizeVariation = 0.6 })
  local v = sys:getSizeVariation()
  lurek.log.debug("size variation=" .. v, "fx")
end

--@api-stub: ParticleSystem:setRotation
do -- ParticleSystem:setRotation
  local leaves = lurek.particle.newSystem({ emissionRate = 20 })
  leaves:setRotation(0, math.pi * 2)
  leaves:setSpin(-1.0, 1.0)
  leaves:start()
end

--@api-stub: ParticleSystem:getRotation
do -- ParticleSystem:getRotation
  local sys = lurek.particle.newSystem({ rotationMin = 0, rotationMax = math.pi })
  local lo, hi = sys:getRotation()
  lurek.log.debug("rot " .. lo .. ".." .. hi, "fx")
end

--@api-stub: ParticleSystem:setSpin
do -- ParticleSystem:setSpin
  local coins = lurek.particle.newSystem({ emissionRate = 10 })
  coins:setSpin(2.0, 4.0)
  coins:setSpeed(80, 120)
  coins:start()
end

--@api-stub: ParticleSystem:getSpin
do -- ParticleSystem:getSpin
  local sys = lurek.particle.newSystem({ spinMin = 0.5, spinMax = 1.5 })
  local lo, hi = sys:getSpin()
  lurek.log.debug("spin " .. lo .. ".." .. hi, "fx")
end

--@api-stub: ParticleSystem:setSpinVariation
do -- ParticleSystem:setSpinVariation
  local debris = lurek.particle.newSystem({ emissionRate = 60 })
  debris:setSpin(1.0, 2.0)
  debris:setSpinVariation(0.5)
  debris:start()
end

--@api-stub: ParticleSystem:getSpinVariation
do -- ParticleSystem:getSpinVariation
  local sys = lurek.particle.newSystem({ spinVariation = 0.3 })
  if sys:getSpinVariation() > 0 then
    lurek.log.info("spin will jitter per particle", "fx")
  end
end

--@api-stub: ParticleSystem:setRelativeRotation
do -- ParticleSystem:setRelativeRotation
  local arrows = lurek.particle.newSystem({ emissionRate = 30 })
  arrows:setShape("ray")
  arrows:setRelativeRotation(true)
  arrows:setSpeed(140, 200)
  arrows:start()
end

--@api-stub: ParticleSystem:hasRelativeRotation
do -- ParticleSystem:hasRelativeRotation
  local sys = lurek.particle.newSystem({})
  sys:setRelativeRotation(true)
  if sys:hasRelativeRotation() then
    lurek.log.info("particles align to motion", "fx")
  end
end

--@api-stub: ParticleSystem:setColors
do -- ParticleSystem:setColors
  local fire = lurek.particle.newSystem({ emissionRate = 80 })
  fire:setColors({1, 1, 0.6, 1}, {1, 0.4, 0, 0.8}, {0.2, 0.0, 0.0, 0.0})
  fire:setShape("circle")
  fire:start()
end

--@api-stub: ParticleSystem:getColors
do -- ParticleSystem:getColors
  local sys = lurek.particle.newSystem({})
  sys:setColors({1, 0, 0, 1}, {0, 0, 1, 1})
  local colors = sys:getColors()
  lurek.log.debug("color stops=" .. #colors, "fx")
end

--@api-stub: ParticleSystem:setOffset
do -- ParticleSystem:setOffset
  local glow = lurek.particle.newSystem({ emissionRate = 25 })
  glow:setOffset(0, -8)
  glow:setSizes(8, 4)
  glow:start()
end

--@api-stub: ParticleSystem:getOffset
do -- ParticleSystem:getOffset
  local sys = lurek.particle.newSystem({ offsetX = 4, offsetY = -2 })
  local ox, oy = sys:getOffset()
  lurek.log.debug("offset " .. ox .. "," .. oy, "fx")
end

--@api-stub: ParticleSystem:setInsertMode
do -- ParticleSystem:setInsertMode
  local smoke = lurek.particle.newSystem({ emissionRate = 30 })
  smoke:setInsertMode("bottom")
  smoke:setColors({1, 1, 1, 0.4}, {0.5, 0.5, 0.5, 0})
  smoke:start()
end

--@api-stub: ParticleSystem:getInsertMode
do -- ParticleSystem:getInsertMode
  local sys = lurek.particle.newSystem({})
  sys:setInsertMode("random")
  local mode = sys:getInsertMode()
  lurek.log.debug("insert mode=" .. mode, "fx")
end

--@api-stub: ParticleSystem:setBufferSize
do -- ParticleSystem:setBufferSize
  local rain = lurek.particle.newSystem({ maxParticles = 64 })
  rain:setBufferSize(1024)
  rain:setEmissionRate(500)
  rain:start()
end

--@api-stub: ParticleSystem:getBufferSize
do -- ParticleSystem:getBufferSize
  local sys = lurek.particle.newSystem({ maxParticles = 256 })
  local cap = sys:getBufferSize()
  lurek.log.debug("pool capacity=" .. cap, "fx")
end

--@api-stub: ParticleSystem:setEmissionArea
do -- ParticleSystem:setEmissionArea
  local fog = lurek.particle.newSystem({ emissionRate = 40 })
  fog:setEmissionArea("ellipse", 200, 80)
  fog:setColors({0.8, 0.8, 1.0, 0.3}, {0.8, 0.8, 1.0, 0})
  fog:start()
end

--@api-stub: ParticleSystem:getEmissionArea
do -- ParticleSystem:getEmissionArea
  local sys = lurek.particle.newSystem({})
  sys:setEmissionArea("uniform", 120, 40)
  local kind, w, h = sys:getEmissionArea()
  lurek.log.debug("area=" .. kind .. " " .. w .. "x" .. h, "fx")
end

--@api-stub: ParticleSystem:setShape
do -- ParticleSystem:setShape
  local stars = lurek.particle.newSystem({ emissionRate = 20 })
  stars:setShape("diamond")
  stars:setSizes(6, 2)
  stars:start()
end

--@api-stub: ParticleSystem:getShape
do -- ParticleSystem:getShape
  local sys = lurek.particle.newSystem({})
  sys:setShape("ring")
  if sys:getShape() == "ring" then
    lurek.log.info("ring shape selected", "fx")
  end
end

--@api-stub: ParticleSystem:getGravity
do -- ParticleSystem:getGravity
  local rain = lurek.particle.newSystem({ gravityX = 0, gravityY = 400 })
  local gx, gy = rain:getGravity()
  lurek.log.debug("g=" .. gx .. "," .. gy, "fx")
end

--@api-stub: ParticleSystem:setGravity
do -- ParticleSystem:setGravity
  local debris = lurek.particle.newSystem({ emissionRate = 40 })
  debris:setGravity(0, 600)
  debris:setSpeed(120, 200)
  debris:setSpread(math.pi)
  debris:start()
end

--@api-stub: ParticleSystem:render
do -- ParticleSystem:render
  local fx = lurek.particle.newSystem({ maxParticles = 128, emissionRate = 40 })
  fx:setPosition(200, 200)
  fx:start()
  function lurek.process(dt) fx:update(dt) end
  function lurek.draw() fx:render() end
end

--@api-stub: ParticleSystem:clone
do -- ParticleSystem:clone
  local proto = lurek.particle.newSystem({ emissionRate = 50, lifetimeMin = 0.5, lifetimeMax = 1.0 })
  local copy = proto:clone()
  copy:setPosition(400, 300)
  copy:start()
end

--@api-stub: ParticleSystem:drawToImage
do -- ParticleSystem:drawToImage
  local sys = lurek.particle.newSystem({ maxParticles = 32 })
  sys:setPosition(64, 64)
  sys:emit(20)
  local img = sys:drawToImage(128, 128)
  lurek.log.debug("baked thumbnail " .. img:getWidth() .. "x" .. img:getHeight(), "fx")
end

--@api-stub: ParticleSystem:toImage
do -- ParticleSystem:toImage
  local sys = lurek.particle.newSystem({ maxParticles = 16 })
  sys:emit(8)
  local img = sys:toImage(64, 64)
  lurek.log.debug("preview ready " .. img:getWidth() .. "px", "fx")
end

--@api-stub: ParticleSystem:warmUp
do -- ParticleSystem:warmUp
  local fountain = lurek.particle.newSystem({ emissionRate = 60, lifetimeMin = 1.0, lifetimeMax = 2.0 })
  fountain:setSpeed(80, 120)
  fountain:start()
  fountain:warmUp(2.0)
end

--@api-stub: ParticleSystem:clearAttractors
do -- ParticleSystem:clearAttractors
  local sys = lurek.particle.newSystem({ emissionRate = 30 })
  sys:addAttractor(200, 200, 400, 80)
  sys:clearAttractors()
  sys:start()
end

--@api-stub: ParticleSystem:getAttractorCount
do -- ParticleSystem:getAttractorCount
  local sys = lurek.particle.newSystem({})
  sys:addAttractor(100, 100, 250, 60)
  if sys:getAttractorCount() > 0 then
    lurek.log.info("attractors active", "fx")
  end
end

--@api-stub: ParticleSystem:clearBounds
do -- ParticleSystem:clearBounds
  local sys = lurek.particle.newSystem({ emissionRate = 20 })
  sys:setBounds(0, 800, 0, 600, 0.6)
  sys:clearBounds()
  sys:start()
end

--@api-stub: ParticleSystem:getFlipbook
do -- ParticleSystem:getFlipbook
  local sys = lurek.particle.newSystem({})
  sys:setFlipbook(4, 2, 12)
  local cols, rows, fps = sys:getFlipbook()
  if cols then lurek.log.debug("flipbook " .. cols .. "x" .. rows .. " @" .. fps, "fx") end
end

-- â”€â”€ Trail methods â”€â”€

--@api-stub: Trail:pushPoint
do -- Trail:pushPoint
  local trail = lurek.particle.newTrail(0.4, 8.0)
  function lurek.process(dt)
    local mx, my = lurek.input.getMousePosition()
    trail:pushPoint(mx, my)
    trail:update(dt)
  end
end

--@api-stub: Trail:update
do -- Trail:update
  local trail = lurek.particle.newTrail(0.5, 10.0)
  trail:pushPoint(100, 100)
  function lurek.process(dt)
    trail:update(dt)
  end
end

--@api-stub: Trail:setWidth
do -- Trail:setWidth
  local trail = lurek.particle.newTrail(0.3, 4.0)
  trail:setWidth(16.0, 2.0)
  trail:pushPoint(50, 50)
end

--@api-stub: Trail:getWidth
do -- Trail:getWidth
  local trail = lurek.particle.newTrail(0.3, 12.0)
  trail:setWidth(12.0, 1.0)
  local sw, ew = trail:getWidth()
  lurek.log.debug("trail w=" .. sw .. "->" .. ew, "fx")
end

--@api-stub: Trail:setLifetime
do -- Trail:setLifetime
  local trail = lurek.particle.newTrail(0.2, 6.0)
  trail:setLifetime(0.8)
  trail:pushPoint(120, 80)
end

--@api-stub: Trail:getLifetime
do -- Trail:getLifetime
  local trail = lurek.particle.newTrail(0.5, 8.0)
  local life = trail:getLifetime()
  if life > 1.0 then trail:setLifetime(1.0) end
end

--@api-stub: Trail:setMinDistance
do -- Trail:setMinDistance
  local trail = lurek.particle.newTrail(0.4, 8.0)
  trail:setMinDistance(4.0)
  trail:pushPoint(200, 100)
  trail:pushPoint(201, 100)  -- ignored: too close
end

--@api-stub: Trail:getPointCount
do -- Trail:getPointCount
  local trail = lurek.particle.newTrail(0.3, 6.0)
  trail:pushPoint(0, 0)
  trail:pushPoint(20, 0)
  if trail:getPointCount() < 2 then return end
  lurek.log.debug("trail points=" .. trail:getPointCount(), "fx")
end

--@api-stub: Trail:clear
do -- Trail:clear
  local trail = lurek.particle.newTrail(0.4, 8.0)
  trail:pushPoint(50, 50)
  trail:pushPoint(60, 60)
  trail:clear()
end

--@api-stub: Trail:drawToImage
do -- Trail:drawToImage
  local trail = lurek.particle.newTrail(0.5, 12.0)
  trail:pushPoint(20, 20)
  trail:pushPoint(80, 60)
  local img = trail:drawToImage(128, 128)
  lurek.log.debug("baked trail img " .. img:getWidth() .. "px", "fx")
end

-- â”€â”€ Phase 03: Lua Extensibility Hooks â”€â”€

--@api-stub: ParticleSystem:addSubSystem
do -- ParticleSystem:addSubSystem
  local fire = lurek.particle.newSystem({
    maxParticles = 200, emissionRate = 60,
    lifetimeMin = 0.3, lifetimeMax = 0.7,
    speedMin = 40, speedMax = 90,
    direction = -math.pi / 2, spread = 0.4,
  })
  local smoke_idx = fire:addSubSystem({
    maxParticles = 80, emissionRate = 20,
    lifetimeMin = 1.0, lifetimeMax = 2.0,
    speedMin = 10, speedMax = 30,
    direction = -math.pi / 2, spread = 0.6,
  })
  lurek.log.debug("smoke sub-system index: " .. smoke_idx, "fx")
  lurek.log.debug("sub-system count: " .. fire:subSystemCount(), "fx")
  fire:setPosition(400, 300)
  fire:start()
end

--@api-stub: ParticleSystem:subSystemCount
do -- ParticleSystem:subSystemCount
  local ps = lurek.particle.newSystem({ maxParticles = 64 })
  ps:addSubSystem({ maxParticles = 16 })
  ps:addSubSystem({ maxParticles = 16 })
  lurek.log.debug("sub count: " .. ps:subSystemCount(), "fx")  -- 2
end

--@api-stub: ParticleSystem:setCustomEmissionShape
do -- ParticleSystem:setCustomEmissionShape
  local ps = lurek.particle.newSystem({
    maxParticles = 128, emissionRate = 30,
    lifetimeMin = 0.8, lifetimeMax = 1.5,
    speedMin = 0, speedMax = 0,
  })
  local angle = 0
  ps:setCustomEmissionShape(function()
    angle = angle + 0.3
    local r = 60 + math.sin(angle * 2) * 20
    return math.cos(angle) * r, math.sin(angle) * r
  end)
  ps:setPosition(400, 300)
  ps:start()
end

--@api-stub: ParticleSystem:setOnDeathBatch
do -- ParticleSystem:setOnDeathBatch
  local ps = lurek.particle.newSystem({
    maxParticles = 64, emissionRate = 10,
    lifetimeMin = 0.5, lifetimeMax = 1.0,
    speedMin = 50, speedMax = 100,
  })
  ps:setOnDeathBatch(function(batch)
    for _, entry in ipairs(batch) do
      -- spawn a sparkle at each death position
      lurek.log.debug(
        string.format("death at (%.1f, %.1f) v=(%.1f, %.1f)", entry.x, entry.y, entry.vx, entry.vy),
        "fx"
      )
    end
  end)
  ps:setPosition(320, 240)
  ps:start()
end

--@api-stub: lurek.particle.fromTOML -- Creates a particle system from a TOML config file
do -- lurek.particle.fromTOML
  if lurek.particle.fromTOML then
    local toml_str = 'max_particles = 100\nemission_rate = 30.0\nlifetime_min = 0.5\nlifetime_max = 2.0\nspeed_min = 30.0\nspeed_max = 80.0\ndirection = 0.0\nspread = 1.57\ngravity_y = 0.0\n'
    lurek.filesystem.write("save/particle_test.toml", toml_str)
    local ps = lurek.particle.fromTOML("save/particle_test.toml")
    lurek.log.debug("fromTOML: " .. tostring(ps), "particle")
  end
end

--@api-stub: ParticleSystem:addAttractor
do -- ParticleSystem:addAttractor
  local ps = lurek.particle.newSystem({max_particles=1000})
  ps:addAttractor(400, 300, 80, -50)
  ps:start()
  lurek.log.info("attractor added", "particle")
end

--@api-stub: ParticleSystem:addSubEmitter
do -- ParticleSystem:addSubEmitter
  local parent = lurek.particle.newSystem({max_particles=200})
  local sparks  = lurek.particle.newSystem({max_particles=50})
  parent:addSubEmitter({trigger="on_death", max_particles=50})
  parent:start()
  lurek.log.info("sub emitter count: " .. parent:subSystemCount(), "particle")
end

--@api-stub: ParticleSystem:setBounds
do -- ParticleSystem:setBounds
  local ps = lurek.particle.newSystem({max_particles=500})
  ps:setBounds(0, 0, 800, 600, 0.0)
  ps:start()
  lurek.log.info("bounds set", "particle")
end

--@api-stub: ParticleSystem:setFlipbook
do -- ParticleSystem:setFlipbook
  local ps = lurek.particle.newSystem({max_particles=300})
  ps:setFlipbook(4, 4, 16)
  ps:start()
  lurek.log.info("flipbook set", "particle")
end

--@api-stub: Trail:setHeadColor
do -- Trail:setHeadColor
  local trail = lurek.particle.newTrail(2.0, 8.0)
  trail:setHeadColor(1.0, 0.8, 0.0, 1.0)
  trail:setTailColor(1.0, 0.2, 0.0, 0.0)
  lurek.log.info("trail head colour set", "particle")
end

--@api-stub: ParticleSystem:setLinearAcceleration
do -- ParticleSystem:setLinearAcceleration
  local ps = lurek.particle.newSystem({max_particles=500})
  ps:setLinearAcceleration(0, 200, 0, 250)
  ps:start()
  lurek.log.info("linear accel set", "particle")
end

--@api-stub: ParticleSystem:setRadialAcceleration
do -- ParticleSystem:setRadialAcceleration
  local ps = lurek.particle.newSystem({max_particles=400})
  ps:setRadialAcceleration(50, 100)
  ps:start()
  lurek.log.info("radial accel set", "particle")
end

--@api-stub: Trail:setTailColor
do -- Trail:setTailColor
  local trail = lurek.particle.newTrail(2.0, 8.0)
  trail:setHeadColor(0.5, 0.8, 1.0, 1.0)
  trail:setTailColor(0.3, 0.5, 1.0, 0.0)
  lurek.log.info("trail tail colour set", "particle")
end

--@api-stub: ParticleSystem:setTangentialAcceleration
do -- ParticleSystem:setTangentialAcceleration
  local ps = lurek.particle.newSystem({max_particles=400})
  ps:setTangentialAcceleration(30, 80)
  ps:start()
  lurek.log.info("tangential accel set", "particle")
end

-- =============================================================================
-- COVERAGE: 97 uncovered lurek.particle API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LTrail methods
-- -----------------------------------------------------------------------------

--@api-stub: LTrail:type -- Returns the Lua-visible type name for this trail handle
do  -- LTrail:type
  local trail = lurek.particle.newTrail(0.4, 8.0)
  local t = trail:type()
  lurek.log.info("LTrail:type = " .. t, "particle")
end
--@api-stub: LTrail:typeOf -- Returns whether this trail handle matches a supported type name
do  -- LTrail:typeOf
  local trail = lurek.particle.newTrail(0.4, 8.0)
  lurek.log.info("is LTrail: " .. tostring(trail:typeOf("LTrail")), "particle")
  lurek.log.info("is unknown: " .. tostring(trail:typeOf("Unknown")), "particle")
end
