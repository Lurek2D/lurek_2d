-- content/examples/physics.lua
-- Auto-generated from content/examples2/physics_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/physics.lua

--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties


--@api-stub: lurek.physics.newWorld
-- Create a physics world with gravity. Focus: newWorld.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:getGravity
-- Create a physics world with gravity. Focus: getGravity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:setGravity
-- Create a physics world with gravity. Focus: setGravity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:step
-- Stepping the simulation. Focus: step.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:step(1 / 60)
    world:step(1 / 60)
    print("stepped twice at 60fps")
    local leftover = world:stepFixed(0.025, 1 / 60, 4)
    print("fixed step leftover = " .. leftover)
end

--@api-stub: LWorld:stepFixed
-- Stepping the simulation. Focus: stepFixed.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:step(1 / 60)
    world:step(1 / 60)
    print("stepped twice at 60fps")
    local leftover = world:stepFixed(0.025, 1 / 60, 4)
    print("fixed step leftover = " .. leftover)
end

--@api-stub: LWorld:setMeter
-- Unit conversion between pixels and physics meters. Focus: setMeter.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px")
    local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:getMeter
-- Unit conversion between pixels and physics meters. Focus: getMeter.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px")
    local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:toPhysics
-- Unit conversion between pixels and physics meters. Focus: toPhysics.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px")
    local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:toPixels
-- Unit conversion between pixels and physics meters. Focus: toPixels.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px")
    local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:setSolverIterations
-- Solver iteration control. Focus: setSolverIterations.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver iterations = " .. world:getSolverIterations())
end

--@api-stub: LWorld:getSolverIterations
-- Solver iteration control. Focus: getSolverIterations.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver iterations = " .. world:getSolverIterations())
end

--@api-stub: LWorld:newBody
-- Creating dynamic bodies and reading position/velocity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
    print("type = " .. body:getType())
    print("id = " .. body:getId())
    world:step(1 / 60)
    x, y = body:getPosition()
    print("after step: y = " .. y)
end

--@api-stub: LWorld:newCircleBody
-- Shortcut to create a body with a circle collider.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    print("ball pos = " .. ball:getX() .. ", " .. ball:getY())
    print("ball w = " .. ball:getWidth() .. " h = " .. ball:getHeight())

    -- Practical: find all bodies in explosion radius.
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    for i = 1, 10 do
        world:newCircleBody(50 + i * 40, 200, 6, "dynamic")
    end
    local explosionX, explosionY = 250, 200
    local radius = 80
    local affected = world:queryAABB(
        explosionX - radius, explosionY - radius,
        radius * 2, radius * 2
    )
    print("bodies in explosion area = " .. #affected)
    for _, id in ipairs(affected) do
        local bx = world:getBodyType(id)
        if bx == "dynamic" then
            print("  applying force to body " .. id)
        end
    end
end

--@api-stub: LWorld:kinematic
-- Different body types.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(400, 580, "static")
    local platform = world:newBody(300, 400, "kinematic")
    local trigger = world:newBody(500, 300, "sensor")
    print("floor type = " .. floor:getType())
    print("platform type = " .. platform:getType())
    print("trigger type = " .. trigger:getType())
end

--@api-stub: LBody:setPosition
-- Teleporting and setting velocity. Focus: setPosition.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    body:setVelocity(50, -100)
    local vx, vy = body:getVelocity()
    print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:setVelocity
-- Teleporting and setting velocity. Focus: setVelocity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    body:setVelocity(50, -100)
    local vx, vy = body:getVelocity()
    print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:getVelocity
-- Teleporting and setting velocity. Focus: getVelocity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    body:setVelocity(50, -100)
    local vx, vy = body:getVelocity()
    print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:setAngle
-- Rotation. Focus: setAngle.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getAngle
-- Rotation. Focus: getAngle.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:setAngularVelocity
-- Rotation. Focus: setAngularVelocity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getAngularVelocity
-- Rotation. Focus: getAngularVelocity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getMass
-- Mass and material properties. Focus: getMass.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setMass
-- Mass and material properties. Focus: setMass.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setFriction
-- Mass and material properties. Focus: setFriction.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:getFriction
-- Mass and material properties. Focus: getFriction.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setRestitution
-- Mass and material properties. Focus: setRestitution.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:getRestitution
-- Mass and material properties. Focus: getRestitution.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass = " .. body:getMass())
    body:setFriction(0.8)
    print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setLinearDamping
-- Damping (velocity decay). Focus: setLinearDamping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:getLinearDamping
-- Damping (velocity decay). Focus: getLinearDamping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:setAngularDamping
-- Damping (velocity decay). Focus: setAngularDamping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:getAngularDamping
-- Damping (velocity decay). Focus: getAngularDamping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:setGravityScale
-- Per-body gravity scale. Focus: setGravityScale.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    local inverted = world:newBody(300, 100, "dynamic")
    floaty:setGravityScale(0.2)
    inverted:setGravityScale(-1.0)
    print("normal gravity = " .. normal:getGravityScale())
    print("floaty gravity = " .. floaty:getGravityScale())
    print("inverted gravity = " .. inverted:getGravityScale())
end

--@api-stub: LBody:getGravityScale
-- Per-body gravity scale. Focus: getGravityScale.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    local inverted = world:newBody(300, 100, "dynamic")
    floaty:setGravityScale(0.2)
    inverted:setGravityScale(-1.0)
    print("normal gravity = " .. normal:getGravityScale())
    print("floaty gravity = " .. floaty:getGravityScale())
    print("inverted gravity = " .. inverted:getGravityScale())
end

--@api-stub: LBody:applyForce
-- Forces and impulses. Focus: applyForce.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200)
    body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0)
    body:applyTorque(10.0)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyForceAtPoint
-- Forces and impulses. Focus: applyForceAtPoint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200)
    body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0)
    body:applyTorque(10.0)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyImpulse
-- Forces and impulses. Focus: applyImpulse.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200)
    body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0)
    body:applyTorque(10.0)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyAngularImpulse
-- Forces and impulses. Focus: applyAngularImpulse.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200)
    body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0)
    body:applyTorque(10.0)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyTorque
-- Forces and impulses. Focus: applyTorque.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200)
    body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0)
    body:applyTorque(10.0)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:setBullet
-- CCD and rotation lock. Focus: setBullet.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:isBullet
-- CCD and rotation lock. Focus: isBullet.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:setFixedRotation
-- CCD and rotation lock. Focus: setFixedRotation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:isFixedRotation
-- CCD and rotation lock. Focus: isFixedRotation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:setType
-- Body type changes and collision filtering. Focus: setType.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getType
-- Body type changes and collision filtering. Focus: getType.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:setLayer
-- Body type changes and collision filtering. Focus: setLayer.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getLayer
-- Body type changes and collision filtering. Focus: getLayer.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:setMask
-- Body type changes and collision filtering. Focus: setMask.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getMask
-- Body type changes and collision filtering. Focus: getMask.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type = " .. body:getType())
    body:setLayer(2)
    body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:sleep
-- Sleep state management. Focus: sleep.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep()
    print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:wakeUp
-- Sleep state management. Focus: wakeUp.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep()
    print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:isSleeping
-- Sleep state management. Focus: isSleeping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep()
    print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:setSleepingAllowed
-- Sleep state management. Focus: setSleepingAllowed.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep()
    print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:isSleepingAllowed
-- Sleep state management. Focus: isSleepingAllowed.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep()
    print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:destroy
-- Destroying bodies. Focus: destroy.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "dynamic")
    world:newBody(300, 300, "static")
    print("bodies = " .. world:getBodyCount())
    local temp = world:newBody(400, 400, "dynamic")
    print("bodies = " .. world:getBodyCount())
    temp:destroy()
    print("after destroy = " .. world:getBodyCount())
end

--@api-stub: LWorld:getBodyCount
-- Destroying bodies. Focus: getBodyCount.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "dynamic")
    world:newBody(300, 300, "static")
    print("bodies = " .. world:getBodyCount())
    local temp = world:newBody(400, 400, "dynamic")
    print("bodies = " .. world:getBodyCount())
    temp:destroy()
    print("after destroy = " .. world:getBodyCount())
end

--@api-stub: LBody:type
-- Type checking. Focus: type.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type = " .. body:type())
    print("is LBody = " .. tostring(body:typeOf("LBody")))
    print("is Object = " .. tostring(body:typeOf("Object")))
end

--@api-stub: LBody:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type = " .. body:type())
    print("is LBody = " .. tostring(body:typeOf("LBody")))
    print("is Object = " .. tostring(body:typeOf("Object")))
end

--@api-stub: LWorld:type
-- World type checking. Focus: type.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    print("type = " .. world:type())
    print("is LWorld = " .. tostring(world:typeOf("LWorld")))
end

--@api-stub: LWorld:typeOf
-- World type checking. Focus: typeOf.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    print("type = " .. world:type())
    print("is LWorld = " .. tostring(world:typeOf("LWorld")))
end

--- Physics Module Part 2: shapes, attachShape, fixtures, collision filtering


--@api-stub: lurek.physics.newCircleShape
-- Create a standalone circle shape.
do
    ---@type LPhysicsShape
    local circle = lurek.physics.newCircleShape(16)
    print("type = " .. circle:getType())
    local x, y, w, h = circle:getBoundingBox()
    print("bounding box = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("radius = " .. circle:getRadius())
end

--@api-stub: lurek.physics.newRectangleShape
-- Create a standalone rectangle shape.
do
    ---@type LPhysicsShape
    local rect = lurek.physics.newRectangleShape(64, 32)
    print("type = " .. rect:getType())
    local x, y, w, h = rect:getBoundingBox()
    print("bounding box = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newPolygonShape
-- Create a polygon shape from vertex list.
do
    ---@type LPhysicsShape
    local triangle = lurek.physics.newPolygonShape(
        0, -20,
        -15, 15,
        15, 15
    )
    print("polygon type = " .. triangle:getType())
    local x, y, w, h = triangle:getBoundingBox()
    print("poly bounds = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newEdgeShape
-- Create an edge (line segment) shape.
do
    ---@type LPhysicsShape
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    print("edge type = " .. edge:getType())
    local x, y, w, h = edge:getBoundingBox()
    print("edge bounds = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newChainShape
-- Create an open chain shape (sequence of connected edges).
do
    ---@type LPhysicsShape
    local chain = lurek.physics.newChainShape(false,
        0, 100,
        50, 80,
        100, 90,
        150, 70,
        200, 100
    )
    print("open chain type = " .. chain:getType())

    -- Create a closed chain shape (forms a loop).
    ---@type LPhysicsShape
    local loop = lurek.physics.newChainShape(true,
        0, 0,
        100, 0,
        100, 100,
        0, 100
    )
    print("closed chain type = " .. loop:getType())
end

--@api-stub: LPhysicsShape:setDensity
-- Set the density of a standalone shape.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    print("density set")
end

--@api-stub: LPhysicsShape:setFriction
-- Set the friction of a standalone shape.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    print("friction set")
end

--@api-stub: LPhysicsShape:setRestitution
-- Set the restitution of a standalone shape.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    print("restitution set")
end

--@api-stub: LPhysicsShape:setSensor
-- Toggle sensor mode on a standalone shape.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(false)
    print("sensor flag set")
end

--@api-stub: LWorld:setFixtureFriction
-- Update fixture friction after creation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(bodyId, 0, 0.8)
    print("fixture friction updated")
end

--@api-stub: LWorld:setFixtureRestitution
-- Update fixture restitution after creation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(bodyId, 0, 0.9)
    print("fixture restitution updated")
end

--@api-stub: LWorld:setFixtureSensor
-- Update the sensor flag after fixture creation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(bodyId, 0, true)
    print("fixture sensor updated")
end

--@api-stub: LWorld:newPolygonBody
-- Create a body with polygon shape in one call.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local verts = { 0, -20, -15, 15, 15, 15 }
    local tri = world:newPolygonBody(100, 200, verts, "dynamic")
    print("polygon body at " .. tri:getX() .. ", " .. tri:getY())
end

--@api-stub: LWorld:newEdgeBody
-- Create a body with an edge shape.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    print("edge body at " .. wall:getX() .. ", " .. wall:getY())
end

--@api-stub: LWorld:newChainBody
-- Create a body with a chain shape (terrain outline).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local terrain = { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }
    local ground = world:newChainBody(0, 500, terrain, false, "static")
    print("chain body at " .. ground:getX() .. ", " .. ground:getY())
end

--@api-stub: LWorld:newBodies
-- Create many bodies at once for performance.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local specs = {}
    for i = 1, 50 do
        specs[i] = {
            x = i * 15,
            y = 50,
            body_type = "dynamic",
            shape = "circle",
            radius = 5
        }
    end
    local ids = world:newBodies(specs)
    print("batch created " .. #ids .. " bodies")
    print("total count = " .. world:getBodyCount())

    -- World body management. Focus: newBodies.
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:getBodyIds
-- Read the ids of all bodies in the world.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    print("body ids = " .. #ids)
end

--@api-stub: LWorld:getBodyType
-- Read the body type by id.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    print("body type = " .. world:getBodyType(body:getId()))
end

--@api-stub: LPhysicsShape:type
-- Read the physics-shape type name.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    print("shape type = " .. shape:type())
end

--@api-stub: LPhysicsShape:typeOf
-- Check the physics-shape type identity.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    print("is LPhysicsShape = " .. tostring(shape:typeOf("LPhysicsShape")))
end

--@api-stub: LPhysicsShape:destroy
-- Destroy a standalone physics shape.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    shape:destroy()
    print("shape destroyed")
end

--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)


--@api-stub: LWorld:addRevoluteJoint
-- Revolute joint: allows two bodies to rotate around a shared anchor point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local arm = world:newBody(200, 200, "dynamic")
    local pivot = world:newBody(200, 150, "static")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    print("revolute joint id = " .. jointId)
    world:step(1 / 60)
    print("arm angle = " .. arm:getAngle())
end

--@api-stub: LWorld:addDistanceJoint
-- Distance joint: keeps two bodies at a fixed distance.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(
        bodyA:getId(), bodyB:getId(),
        100, 100,
        200, 100,
        100
    )
    print("distance joint id = " .. jointId)
    world:step(1 / 60)
    local ax, ay = bodyA:getPosition()
    local bx, by = bodyB:getPosition()
    print("A=" .. ax .. "," .. ay .. " B=" .. bx .. "," .. by)
end

--@api-stub: LWorld:addPrismaticJoint
-- Prismatic joint: constrains movement along an axis (slider).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(
        rail:getId(), slider:getId(),
        300, 300,
        1, 0
    )
    print("prismatic joint id = " .. jointId)
    slider:applyForce(200, 0)
    world:step(1 / 60)
    print("slider x = " .. slider:getX())
end

--@api-stub: LWorld:addWeldJoint
-- Weld joint: glues two bodies together rigidly.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    print("weld joint id = " .. jointId)
    chassis:applyForce(100, 0)
    world:step(1 / 60)
    print("chassis x = " .. chassis:getX())
    print("turret x = " .. turret:getX())
end

--@api-stub: LWorld:addRopeJoint
-- Rope joint: limits maximum distance between two anchors.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(
        ceiling:getId(), weight:getId(),
        0, 0,
        0, 0,
        120
    )
    print("rope joint id = " .. jointId)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("weight y = " .. weight:getY())
end

--@api-stub: LWorld:addWheelJoint
-- Wheel joint: simulates a wheel on an axle (suspension).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(
        car:getId(), wheel:getId(),
        200, 230,
        0, 1
    )
    print("wheel joint id = " .. jointId)
    world:step(1 / 60)
    print("wheel pos = " .. wheel:getX() .. ", " .. wheel:getY())
end

--@api-stub: LWorld:addMouseJoint
-- Mouse joint: drags a body toward a target point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    print("mouse joint id = " .. jointId)
    for _ = 1, 30 do
        world:step(1 / 60)
    end
    print("box pos = " .. box:getX() .. ", " .. box:getY())
    world:setMouseJointTarget(jointId, 400, 150)
    for _ = 1, 30 do
        world:step(1 / 60)
    end
    print("box after retarget = " .. box:getX() .. ", " .. box:getY())
end

--@api-stub: LWorld:addMotorJoint
-- Motor joint: applies a relative force/torque between two bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    print("motor joint id = " .. jointId)
    world:step(1 / 60)
    print("mover pos = " .. mover:getX() .. ", " .. mover:getY())
end

--@api-stub: LWorld:addFrictionJoint
-- Friction joint: applies drag forces between two bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    puck:setVelocity(200, 0)
    local jointId = world:addFrictionJoint(
        ground:getId(), puck:getId(),
        200, 400,
        100, 50
    )
    print("friction joint id = " .. jointId)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local vx, vy = puck:getVelocity()
    print("puck vel after friction = " .. vx .. ", " .. vy)
end

--@api-stub: LWorld:addGearJoint
-- Gear joint: couples two revolute or prismatic joints.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    print("gear joint id = " .. jointId)
end

--@api-stub: LWorld:addPulleyJoint
-- Pulley joint: simulates a pulley system.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    print("pulley joint id = " .. jointId)
    boxA:setMass(5.0)
    boxB:setMass(1.0)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("heavy A y = " .. boxA:getY())
    print("light B y = " .. boxB:getY())
end

--@api-stub: LWorld:getJointIds
-- Read all joint ids from the world.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    print("joint ids = " .. #ids)
end

--@api-stub: LWorld:jointCount
-- Read the number of joints in the world.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint count = " .. world:jointCount())
end

--@api-stub: LWorld:getJointBodies
-- Read the body ids attached to a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local bodyA, bodyB = world:getJointBodies(jid)
    print("joint bodies = " .. bodyA .. "," .. bodyB)
end

--@api-stub: LWorld:getJointType
-- Read the type name for a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint type = " .. world:getJointType(jid))
end

--@api-stub: LWorld:setJointLimits
-- Apply angular limits to a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("joint limits set")
end

--@api-stub: LWorld:getJointLimits
-- Read the angular limits of a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    local lo, hi = world:getJointLimits(jid)
    print("limits = " .. lo .. " to " .. hi)
end

--@api-stub: LWorld:setJointLimitsEnabled
-- Enable or disable joint limits.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    print("joint limits enabled")
end

--@api-stub: LWorld:setJointMotorSpeed
-- Set the motor speed of a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor speed set")
end

--@api-stub: LWorld:getJointMotorSpeed
-- Read the motor speed of a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor speed = " .. world:getJointMotorSpeed(jid))
end

--@api-stub: LWorld:setJointBreakForce
-- Set the break force of a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(
        ceiling:getId(), weight:getId(),
        0, 0, 0, 0, 50
    )
    world:setJointBreakForce(jid, 500)
    print("break force set")
end

--@api-stub: LWorld:getJointBreakForce
-- Read the break force of a joint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(
        ceiling:getId(), weight:getId(),
        0, 0, 0, 0, 50
    )
    world:setJointBreakForce(jid, 500)
    print("break force = " .. world:getJointBreakForce(jid))
end

--@api-stub: LWorld:destroyJoint
-- Destroying a joint explicitly.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joints = " .. world:jointCount())
    world:destroyJoint(jid)
    print("after destroy = " .. world:jointCount())
end

--- Physics Module Part 4: raycasting, AABB queries, contacts, collision events


--@api-stub: LWorld:raycast
-- Basic raycast: returns first hit along a line segment.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "static")
    world:newCircleBody(400, 200, 20, "static")
    local hit = world:raycast(0, 200, 600, 200)
    if hit then
        print("hit body " .. hit.bodyId)
        print("hit point = " .. hit.x .. ", " .. hit.y)
        print("normal = " .. hit.normalX .. ", " .. hit.normalY)
        print("toi = " .. hit.toi)
    else
        print("no hit")
    end
end

--@api-stub: LWorld:raycastClosest
-- Raycast with direction and max distance (closest hit).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 300, 15, "static")
    world:newCircleBody(200, 500, 15, "static")
    local hit = world:raycastClosest(200, 100, 0, 1, 500)
    if hit then
        print("closest hit body = " .. hit.bodyId)
        print("at " .. hit.x .. ", " .. hit.y)
        print("distance factor = " .. hit.toi)
    else
        print("no hit within range")
    end
end

--@api-stub: LWorld:raycastAll
-- Raycast that returns all hits along the ray.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        world:newCircleBody(100 + i * 80, 200, 10, "static")
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600)
    print("total hits = " .. #hits)
    for i, hit in ipairs(hits) do
        print("  hit " .. i .. ": body=" .. hit.bodyId .. " at " .. hit.x .. "," .. hit.y)
    end
end

--@api-stub: LWorld:queryAABB
-- Query all bodies within an axis-aligned bounding box.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(150, 120, 10, "dynamic")
    world:newCircleBody(500, 500, 10, "dynamic")
    local found = world:queryAABB(50, 50, 200, 200)
    print("bodies in AABB = " .. #found)
    for _, id in ipairs(found) do
        print("  body id = " .. id)
    end
end

--@api-stub: LWorld:getBodyAtPoint
-- Find a body at a specific point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 30, "static")
    world:newCircleBody(400, 400, 30, "static")
    local id = world:getBodyAtPoint(210, 205)
    if id then
        print("body at point = " .. id)
    else
        print("no body at point")
    end
    local miss = world:getBodyAtPoint(0, 0)
    print("miss = " .. tostring(miss))
end

--@api-stub: LWorld:getContacts
-- Query all active contacts in the world.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 400, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    print("active contacts = " .. #contacts)
    for _, c in ipairs(contacts) do
        print("  bodyA=" .. c.bodyA .. " bodyB=" .. c.bodyB)
    end
end

--@api-stub: LWorld:getBeginContactEvents
-- Poll begin-contact events frame by frame.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    for frame = 1, 180 do
        world:step(1 / 60)
        local events = world:getBeginContactEvents()
        if #events > 0 then
            count = #events
            print("frame " .. frame .. ": begin events = " .. count)
            break
        end
    end
    print("begin total = " .. count)
end

--@api-stub: LWorld:getEndContactEvents
-- Poll end-contact events frame by frame.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    for frame = 1, 300 do
        world:step(1 / 60)
        local events = world:getEndContactEvents()
        if #events > 0 then
            count = #events
            print("frame " .. frame .. ": end events = " .. count)
            break
        end
    end
    print("end total = " .. count)
end

--@api-stub: LWorld:getCollisionEvents
-- Collision events (combined begin contacts).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(190, 100, 8, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    for frame = 1, 120 do
        world:step(1 / 60)
        local events = world:getCollisionEvents()
        if #events > 0 then
            print("frame " .. frame .. ": " .. #events .. " collision(s)")
            for _, ev in ipairs(events) do
                print("  A=" .. ev.bodyA .. " B=" .. ev.bodyB)
            end
            break
        end
    end
end

--@api-stub: LWorld:setBeginContact
-- Contact callbacks (alternative to polling).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        print("callback: contact #" .. contactCount .. " A=" .. bodyA .. " B=" .. bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("total begin contacts = " .. contactCount)
    world:clearBeginContact()
end

--@api-stub: LWorld:setEndContact
-- End contact callback.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("end contacts (bounces) = " .. endCount)
    world:clearEndContact()
end

--@api-stub: LWorld:getBodyContacts
-- Get contacts for a specific body.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    print("ball contacts = " .. #contacts)
    for _, c in ipairs(contacts) do
        print("  other=" .. c.bodyB .. " normal=" .. c.normalX .. "," .. c.normalY ..
            " touching=" .. tostring(c.isTouching))
    end
end

--@api-stub: lurek.physics.testAABB
-- AABB vs AABB overlap test (no world needed).
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    print("overlap = " .. tostring(overlap))
    local noOverlap = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    print("no overlap = " .. tostring(noOverlap))
end

--@api-stub: lurek.physics.testCircleAABB
-- Circle vs AABB overlap test.
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    print("circle-aabb hit = " .. tostring(hit))
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    print("circle-aabb miss = " .. tostring(miss))
end

--@api-stub: lurek.physics.testCircles
-- Circle vs circle overlap test.
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    print("circles touching = " .. tostring(touching))
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    print("circles apart = " .. tostring(apart))
end

--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced


--@api-stub: LWorld:addZone
-- Zones: axis-aligned areas that apply effects to bodies inside.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    print("zone id = " .. zone:getId())
    zone:setEnabled(true)
    zone:setPriority(10)
    zone:setLayerMask(1)
end

--@api-stub: LZone:setGravityDirectional
-- Zone gravity overrides. Focus: setGravityDirectional.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local x, y = ball:getPosition()
    print("ball in wind zone: " .. x .. ", " .. y)
end

--@api-stub: LZone:setGravityPoint
-- Zone gravity overrides. Focus: setGravityPoint.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local x, y = ball:getPosition()
    print("ball in wind zone: " .. x .. ", " .. y)
end

--@api-stub: LZone:setGravityRepulsor
-- Repulsor and zero-gravity zones. Focus: setGravityRepulsor.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local vx, vy = ball:getVelocity()
    print("ball in zero-g: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setGravityZero
-- Repulsor and zero-gravity zones. Focus: setGravityZero.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local vx, vy = ball:getVelocity()
    print("ball in zero-g: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setLinearDampingOverride
-- Zone damping overrides (water, mud). Focus: setLinearDampingOverride.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    water:setAngularDampingOverride(2.0)
    water:setGravityDirectional(0, 100)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local vx, vy = diver:getVelocity()
    print("diver in water: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setAngularDampingOverride
-- Zone damping overrides (water, mud). Focus: setAngularDampingOverride.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    water:setAngularDampingOverride(2.0)
    water:setGravityDirectional(0, 100)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local vx, vy = diver:getVelocity()
    print("diver in water: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setCircle
-- Circular zone (instead of default rectangle).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    print("circular zone created")
end

--@api-stub: LWorld:getZoneEvents
-- Zone enter/exit events.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    local ball = world:newCircleBody(250, 100, 8, "dynamic")
    for frame = 1, 120 do
        world:step(1 / 60)
        local events = world:getZoneEvents()
        for _, ev in ipairs(events) do
            print("frame " .. frame .. ": zone=" .. ev.zone_id ..
                " body=" .. ev.body_id .. " kind=" .. ev.kind)
        end
    end
end

--@api-stub: LZone:destroy
-- Destroying zones.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local z1 = world:addZone(0, 0, 100, 100)
    local z2 = world:addZone(200, 200, 100, 100)
    print("zone 1 id = " .. z1:getId())
    z1:destroy()
    print("zone 1 destroyed")
end

--@api-stub: lurek.physics.newCellular
-- Cellular automaton: grid-based simulation (sand, water, fire).
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(64, 64)
    grid:setCell(32, 0, 1)
    grid:setCell(33, 0, 1)
    grid:setCell(34, 0, 1)
    print("cell at 32,0 = " .. grid:getCell(32, 0))
    grid:step()
    print("after step: cell at 32,1 = " .. grid:getCell(32, 1))
end

--@api-stub: LCellular:fillRect
-- Cellular bulk fill. Focus: fillRect.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillRect(10, 10, 20, 5, 2)
    grid:fillCircle(64, 64, 15, 3)
    local count = grid:countCells(2)
    print("type-2 cells = " .. count)
    local count3 = grid:countCells(3)
    print("type-3 cells = " .. count3)
end

--@api-stub: LCellular:fillCircle
-- Cellular bulk fill. Focus: fillCircle.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillRect(10, 10, 20, 5, 2)
    grid:fillCircle(64, 64, 15, 3)
    local count = grid:countCells(2)
    print("type-2 cells = " .. count)
    local count3 = grid:countCells(3)
    print("type-3 cells = " .. count3)
end

--@api-stub: LCellular:stepN
-- Multiple steps and finding specific cells. Focus: stepN.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, 1)
    grid:stepN(10)
    local positions = grid:findCells(1)
    print("type-1 cells after 10 steps = " .. #positions)
end

--@api-stub: LCellular:findCells
-- Multiple steps and finding specific cells. Focus: findCells.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, 1)
    grid:stepN(10)
    local positions = grid:findCells(1)
    print("type-1 cells after 10 steps = " .. #positions)
end

--@api-stub: LCellular:toImageData
-- Cellular serialization and visualization. Focus: toImageData.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes()
    print("grid bytes length = " .. #bytes)
    ---@type LCellular
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: LCellular:toBytes
-- Cellular serialization and visualization. Focus: toBytes.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes()
    print("grid bytes length = " .. #bytes)
    ---@type LCellular
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: LCellular:loadFromBytes
-- Cellular serialization and visualization. Focus: loadFromBytes.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes()
    print("grid bytes length = " .. #bytes)
    ---@type LCellular
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: lurek.physics.newTerrain
-- Destructible terrain: grid-backed physical terrain with collision bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 32, 10, false)
    terrain:flush()
    print("terrain created with hole")
    print("dirty = " .. tostring(terrain:isDirty()))
end

--@api-stub: LTerrain:setCell
-- Terrain cell manipulation. Focus: setCell.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:getCell
-- Terrain cell manipulation. Focus: getCell.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:fillRect
-- Terrain cell manipulation. Focus: fillRect.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:collapseColumns
-- Terrain advanced operations. Focus: collapseColumns.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush()
    terrain:collapseColumns()
    terrain:flush()
    local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:solidPositions
-- Terrain advanced operations. Focus: solidPositions.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush()
    terrain:collapseColumns()
    terrain:flush()
    local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:spawnDebris
-- Terrain advanced operations. Focus: spawnDebris.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush()
    terrain:collapseColumns()
    terrain:flush()
    local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:toBytes
-- Terrain serialization. Focus: toBytes.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false)
    terrain:flush()
    local data = terrain:toBytes()
    print("terrain bytes = " .. #data)
    ---@type LTerrain
    local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data)
    terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0)))
    print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LTerrain:loadFromBytes
-- Terrain serialization. Focus: loadFromBytes.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false)
    terrain:flush()
    local data = terrain:toBytes()
    print("terrain bytes = " .. #data)
    ---@type LTerrain
    local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data)
    terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0)))
    print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LTerrain:toImageData
-- Terrain serialization. Focus: toImageData.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false)
    terrain:flush()
    local data = terrain:toBytes()
    print("terrain bytes = " .. #data)
    ---@type LTerrain
    local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data)
    terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0)))
    print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LWorld:setBodyData
-- Attach arbitrary data to physics bodies. Focus: setBodyData.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId())
    print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId())
    print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId())
    print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:getBodyData
-- Attach arbitrary data to physics bodies. Focus: getBodyData.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId())
    print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId())
    print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId())
    print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:clearBodyData
-- Attach arbitrary data to physics bodies. Focus: clearBodyData.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId())
    print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId())
    print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId())
    print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:setBodyOneWay
-- One-way platforms: bodies that can only be entered from one direction. Focus: setBodyOneWay.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10)
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    if nx then
        print("one-way normal = " .. nx .. ", " .. ny)
    end
    world:clearBodyOneWay(platform:getId())
    nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:getBodyOneWay
-- One-way platforms: bodies that can only be entered from one direction. Focus: getBodyOneWay.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10)
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    if nx then
        print("one-way normal = " .. nx .. ", " .. ny)
    end
    world:clearBodyOneWay(platform:getId())
    nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:clearBodyOneWay
-- One-way platforms: bodies that can only be entered from one direction. Focus: clearBodyOneWay.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10)
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    if nx then
        print("one-way normal = " .. nx .. ", " .. ny)
    end
    world:clearBodyOneWay(platform:getId())
    nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:setBodyCCD
-- Continuous collision detection per body (for fast-moving objects). Focus: setBodyCCD.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("CCD enabled = " .. tostring(world:getBodyCCD(bullet:getId())))
    bullet:setVelocity(2000, 0)
end

--@api-stub: LWorld:getBodyCCD
-- Continuous collision detection per body (for fast-moving objects). Focus: getBodyCCD.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("CCD enabled = " .. tostring(world:getBodyCCD(bullet:getId())))
    bullet:setVelocity(2000, 0)
end

--@api-stub: LWorld:sleepBody
-- Sleep management via world API. Focus: sleepBody.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId()
    lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id)
    print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:wakeUpBody
-- Sleep management via world API. Focus: wakeUpBody.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId()
    lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id)
    print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:isBodySleeping
-- Sleep management via world API. Focus: isBodySleeping.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId()
    lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id)
    print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:drawDebug
-- Debug drawing (renders wireframes to an image data target).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    world:newBody(200, 500, "static")
    ---@type LImageData
    local img = lurek.image.newImageData(800, 600)
    world:drawDebug(img, 0, 255, 0, 200)
    print("debug drawn to image data")
end

--@api-stub: lurek.physics.debugDraw
-- Global debug draw toggle and GPU debug.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    print("debug draw enabled")
    lurek.physics.drawDebugGpu(world)
    print("GPU debug drawn")
    lurek.physics.debugDraw(false)
end

--@api-stub: lurek.physics.destroyWorld
-- World cleanup. Focus: destroyWorld.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(200, 200, 10, "dynamic")
    print("before clear: " .. world:getBodyCount())
    world:clear()
    print("after clear: " .. world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("world destroyed")
end

--@api-stub: LWorld:clear
-- World cleanup. Focus: clear.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(200, 200, 10, "dynamic")
    print("before clear: " .. world:getBodyCount())
    world:clear()
    print("after clear: " .. world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("world destroyed")
end

--@api-stub: lurek.physics.step
-- Using free-function API (alternative to method calls).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    print("free fn: pos=" .. x .. "," .. y .. " vel=" .. vx .. "," .. vy)
    lurek.physics.setBodyVelocity(world, body, 50, -100)
    lurek.physics.step(world, 1 / 60)
    x, y, vx, vy = lurek.physics.getBody(world, body)
    print("after set vel: pos=" .. x .. "," .. y)

    -- Polling collisions via the free-function API. Focus: step.
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    print("collisions = " .. #collisions)
    for _, c in ipairs(collisions) do
        print("  A=" .. c.body_a .. " B=" .. c.body_b)
    end
end

--@api-stub: lurek.physics.getCollisions
-- Polling collisions via the free-function API. Focus: getCollisions.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    print("collisions = " .. #collisions)
    for _, c in ipairs(collisions) do
        print("  A=" .. c.body_a .. " B=" .. c.body_b)
    end
end

--@api-stub: lurek.physics.isSleepingAllowed
-- Free-function sleep control.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
end

--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns


--@api-stub: LBody:getHeight
-- Body position and size queries. Focus: getHeight.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getId
-- Body position and size queries. Focus: getId.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getPosition
-- Body position and size queries. Focus: getPosition.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getWidth
-- Body position and size queries. Focus: getWidth.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getX
-- Body position and size queries. Focus: getX.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getY
-- Body position and size queries. Focus: getY.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition()
    print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX())
    print("y=" .. body:getY())
    print("id=" .. body:getId())
    print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LCellular:countCells
-- Cellular automaton simulation grid. Focus: countCells.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:getCell
-- Cellular automaton simulation grid. Focus: getCell.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:setCell
-- Cellular automaton simulation grid. Focus: setCell.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:step
-- Cellular automaton simulation grid. Focus: step.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:toImageDataRegion
-- Cellular automaton simulation grid. Focus: toImageDataRegion.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:type
-- Cellular automaton simulation grid. Focus: type.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:typeOf
-- Cellular automaton simulation grid. Focus: typeOf.
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5))
    ca:step()
    print("count=" .. ca:countCells(1))
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil))
    print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LPhysicsShape:getBoundingBox
-- Physics shape queries. Focus: getBoundingBox.
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LPhysicsShape:getRadius
-- Physics shape queries. Focus: getRadius.
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LPhysicsShape:getType
-- Physics shape queries. Focus: getType.
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LTerrain:fillAll
-- Destructible terrain grid operations. Focus: fillAll.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:fillCircle
-- Destructible terrain grid operations. Focus: fillCircle.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:flush
-- Destructible terrain grid operations. Focus: flush.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:isDirty
-- Destructible terrain grid operations. Focus: isDirty.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:type
-- Destructible terrain grid operations. Focus: type.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:typeOf
-- Destructible terrain grid operations. Focus: typeOf.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false)
    terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LWorld:addFixture
-- World body management. Focus: addFixture.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:clearBeginContact
-- World body management. Focus: clearBeginContact.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:clearEndContact
-- World body management. Focus: clearEndContact.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:destroyBody
-- World body management. Focus: destroyBody.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:fixtureCount
-- World body management. Focus: fixtureCount.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:setBodyType
-- World body management. Focus: setBodyType.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LWorld:setMouseJointTarget
-- World body management. Focus: setMouseJointTarget.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId()))
    world:setBodyType(body:getId(), "static")
    world:clearBeginContact()
    world:clearEndContact()
    local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies)
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    world:destroyBody(body:getId())
end

--@api-stub: LZone:getId
-- Zone lifecycle and config. Focus: getId.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setEnabled
-- Zone lifecycle and config. Focus: setEnabled.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setLayerMask
-- Zone lifecycle and config. Focus: setLayerMask.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setPriority
-- Zone lifecycle and config. Focus: setPriority.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:type
-- Zone lifecycle and config. Focus: type.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:typeOf
-- Zone lifecycle and config. Focus: typeOf.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId())
    zone:setEnabled(true)
    zone:setLayerMask(0xFF)
    zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: lurek.physics.drawDebugGpu
-- Draw physics debug overlay using GPU renderer.
do
    local world = lurek.physics.newWorld(0, 9.8)
    lurek.physics.drawDebugGpu(world, {})
    print("debug_gpu_draw ok")
end

--@api-stub: lurek.physics.getBody
-- Get body handle from world by id.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local b = lurek.physics.newBody(world, 0, 0, "dynamic")
    local b2 = lurek.physics.getBody(world, b)
    print("got_body=" .. tostring(b2 ~= nil))
end

--@api-stub: lurek.physics.newBody
-- Free-function body creation.
do
    local world = lurek.physics.newWorld(0, 0)
    local b = lurek.physics.newBody(world, 50, 50, "static")
    print("body_id=" .. b:getId())
end

--@api-stub: LChainShape:getType
-- Create a chain shape.
do
    local chain = lurek.physics.newChainShape(false, 0, 0, 10, 0, 10, 10, 0, 10)
    print("chain_type=" .. chain:getType())
end

--@api-stub: lurek.physics.setBodyVelocity
-- Set body velocity (free function).
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    print("velocity set")
end

--@api-stub: lurek.physics.setSleepingAllowed
-- Set body sleeping allowed (free function).
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    print("sleeping_allowed set")
end

--@api-stub: lurek.physics.testPoint
-- Point-in-AABB test.
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    print("inside=" .. tostring(inside))
    print("outside=" .. tostring(outside))
end

print("content/examples/physics.lua")
