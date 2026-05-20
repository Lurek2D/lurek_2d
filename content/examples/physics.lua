-- content/examples/physics.lua
-- Auto-generated from content/examples2/physics_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/physics.lua

--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties


--@api-stub: lurek.physics.newWorld
do
    local world = lurek.physics.newWorld(0, 400); local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:getGravity
do
    local world = lurek.physics.newWorld(0, 400); local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:setGravity
do
    local world = lurek.physics.newWorld(0, 400); local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:step
do
    local world = lurek.physics.newWorld(0, 400); world:step(1 / 60)
    world:step(1 / 60)
    print("stepped twice at 60fps")
    local leftover = world:stepFixed(0.025, 1 / 60, 4)
    print("fixed step leftover = " .. leftover)
end

--@api-stub: LWorld:stepFixed
do
    local world = lurek.physics.newWorld(0, 400); world:step(1 / 60)
    world:step(1 / 60)
    print("stepped twice at 60fps")
    local leftover = world:stepFixed(0.025, 1 / 60, 4)
    print("fixed step leftover = " .. leftover)
end

--@api-stub: LWorld:setMeter
do
    local world = lurek.physics.newWorld(0, 9.81); world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px"); local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:getMeter
do
    local world = lurek.physics.newWorld(0, 9.81); world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px"); local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:toPhysics
do
    local world = lurek.physics.newWorld(0, 9.81); world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px"); local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:toPixels
do
    local world = lurek.physics.newWorld(0, 9.81); world:setMeter(64)
    print("meter = " .. world:getMeter() .. " px"); local meters = world:toPhysics(128)
    print("128px = " .. meters .. "m")
    local pixels = world:toPixels(2.0)
    print("2m = " .. pixels .. "px")
end

--@api-stub: LWorld:setSolverIterations
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver iterations = " .. world:getSolverIterations())
end

--@api-stub: LWorld:getSolverIterations
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver iterations = " .. world:getSolverIterations())
end

--@api-stub: LWorld:newBody
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 50, "dynamic")
    local x, y = body:getPosition(); print("pos = " .. x .. ", " .. y)
    print("type = " .. body:getType()); print("id = " .. body:getId())
    world:step(1 / 60); x, y = body:getPosition()
    print("after step: y = " .. y)
end

--@api-stub: LWorld:newCircleBody
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    print("ball pos = " .. ball:getX() .. ", " .. ball:getY())
    print("ball w = " .. ball:getWidth() .. " h = " .. ball:getHeight())
end

--@api-stub: LWorld:kinematic
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(400, 580, "static")
    local platform = world:newBody(300, 400, "kinematic"); local trigger = world:newBody(500, 300, "sensor")
    print("floor type = " .. floor:getType())
    print("platform type = " .. platform:getType())
    print("trigger type = " .. trigger:getType())
end

--@api-stub: LBody:setPosition
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100); body:setVelocity(50, -100)
    local vx, vy = body:getVelocity(); print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:setVelocity
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100); body:setVelocity(50, -100)
    local vx, vy = body:getVelocity(); print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:getVelocity
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100); body:setVelocity(50, -100)
    local vx, vy = body:getVelocity(); print("velocity = " .. vx .. ", " .. vy)
    local x, y = body:getPosition()
    print("pos = " .. x .. ", " .. y)
end

--@api-stub: LBody:setAngle
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getAngle
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:setAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getMass
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setMass
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setFriction
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:getFriction
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setRestitution
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:getRestitution
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0); print("mass = " .. body:getMass())
    body:setFriction(0.8); print("friction = " .. body:getFriction())
    body:setRestitution(0.6)
    print("restitution = " .. body:getRestitution())
end

--@api-stub: LBody:setLinearDamping
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:getLinearDamping
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:setAngularDamping
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:getAngularDamping
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:setGravityScale
do
    local world = lurek.physics.newWorld(0, 400); local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic"); local inverted = world:newBody(300, 100, "dynamic")
    floaty:setGravityScale(0.2); inverted:setGravityScale(-1.0)
    print("normal gravity = " .. normal:getGravityScale()); print("floaty gravity = " .. floaty:getGravityScale())
    print("inverted gravity = " .. inverted:getGravityScale())
end

--@api-stub: LBody:getGravityScale
do
    local world = lurek.physics.newWorld(0, 400); local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic"); local inverted = world:newBody(300, 100, "dynamic")
    floaty:setGravityScale(0.2); inverted:setGravityScale(-1.0)
    print("normal gravity = " .. normal:getGravityScale()); print("floaty gravity = " .. floaty:getGravityScale())
    print("inverted gravity = " .. inverted:getGravityScale())
end

--@api-stub: LBody:applyForce
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newCircleBody(200, 200, 10, "dynamic"); body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200); body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0); body:applyTorque(10.0)
    world:step(1 / 60); local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy); print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyForceAtPoint
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newCircleBody(200, 200, 10, "dynamic"); body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200); body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0); body:applyTorque(10.0)
    world:step(1 / 60); local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy); print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyImpulse
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newCircleBody(200, 200, 10, "dynamic"); body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200); body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0); body:applyTorque(10.0)
    world:step(1 / 60); local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy); print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyAngularImpulse
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newCircleBody(200, 200, 10, "dynamic"); body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200); body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0); body:applyTorque(10.0)
    world:step(1 / 60); local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy); print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:applyTorque
do
    local world = lurek.physics.newWorld(0, 0); local body = world:newCircleBody(200, 200, 10, "dynamic"); body:applyForce(100, 0)
    body:applyForceAtPoint(0, -50, 210, 200); body:applyImpulse(0, -200)
    body:applyAngularImpulse(5.0); body:applyTorque(10.0)
    world:step(1 / 60); local vx, vy = body:getVelocity()
    print("after forces: vx=" .. vx .. " vy=" .. vy); print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:setBullet
do
    local world = lurek.physics.newWorld(0, 400); local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true); print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:isBullet
do
    local world = lurek.physics.newWorld(0, 400); local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true); print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:setFixedRotation
do
    local world = lurek.physics.newWorld(0, 400); local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true); print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:isFixedRotation
do
    local world = lurek.physics.newWorld(0, 400); local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true); print("is bullet = " .. tostring(bullet:isBullet()))
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed rotation = " .. tostring(player:isFixedRotation()))
end

--@api-stub: LBody:setType
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getType
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:setLayer
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getLayer
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:setMask
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:getMask
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic"); print("type = " .. body:getType())
    body:setLayer(2); body:setMask(1)
    print("layer = " .. body:getLayer())
    print("mask = " .. body:getMask())
end

--@api-stub: LBody:sleep
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true); print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep(); print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:wakeUp
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true); print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep(); print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:isSleeping
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true); print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep(); print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true); print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep(); print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true); print("sleeping allowed = " .. tostring(body:isSleepingAllowed()))
    body:sleep(); print("sleeping = " .. tostring(body:isSleeping()))
    body:wakeUp()
    print("sleeping after wake = " .. tostring(body:isSleeping()))
end

--@api-stub: LBody:destroy
do
    local world = lurek.physics.newWorld(0, 400); world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "dynamic"); world:newBody(300, 300, "static")
    print("bodies = " .. world:getBodyCount()); local temp = world:newBody(400, 400, "dynamic")
    print("bodies = " .. world:getBodyCount()); temp:destroy()
    print("after destroy = " .. world:getBodyCount())
end

--@api-stub: LWorld:getBodyCount
do
    local world = lurek.physics.newWorld(0, 400); world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "dynamic"); world:newBody(300, 300, "static")
    print("bodies = " .. world:getBodyCount()); local temp = world:newBody(400, 400, "dynamic")
    print("bodies = " .. world:getBodyCount()); temp:destroy()
    print("after destroy = " .. world:getBodyCount())
end

--@api-stub: LBody:type
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type = " .. body:type())
    print("is LBody = " .. tostring(body:typeOf("LBody")))
    print("is Object = " .. tostring(body:typeOf("Object")))
end

--@api-stub: LBody:typeOf
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type = " .. body:type())
    print("is LBody = " .. tostring(body:typeOf("LBody")))
    print("is Object = " .. tostring(body:typeOf("Object")))
end

--@api-stub: LWorld:type
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    print("type = " .. world:type())
    print("is LWorld = " .. tostring(world:typeOf("LWorld")))
end

--@api-stub: LWorld:typeOf
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    print("type = " .. world:type())
    print("is LWorld = " .. tostring(world:typeOf("LWorld")))
end

--- Physics Module Part 2: shapes, attachShape, fixtures, collision filtering


--@api-stub: lurek.physics.newCircleShape
do
    local circle = lurek.physics.newCircleShape(16)
    print("type = " .. circle:getType())
    local x, y, w, h = circle:getBoundingBox()
    print("bounding box = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("radius = " .. circle:getRadius())
end

--@api-stub: lurek.physics.newRectangleShape
do
    ---@type LPhysicsShape
    local rect = lurek.physics.newRectangleShape(64, 32)
    print("type = " .. rect:getType())
    local x, y, w, h = rect:getBoundingBox()
    print("bounding box = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newPolygonShape
do
    local triangle = lurek.physics.newPolygonShape( 0, -20, -15, 15, 15, 15 )
    print("polygon type = " .. triangle:getType())
    local x, y, w, h = triangle:getBoundingBox()
    print("poly bounds = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newEdgeShape
do
    ---@type LPhysicsShape
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    print("edge type = " .. edge:getType())
    local x, y, w, h = edge:getBoundingBox()
    print("edge bounds = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: lurek.physics.newChainShape
do
    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100 )
    print("open chain type = " .. chain:getType())
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100 )
    print("closed chain type = " .. loop:getType())
end

--@api-stub: LPhysicsShape:setDensity
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    print("density set")
end

--@api-stub: LPhysicsShape:setFriction
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    print("friction set")
end

--@api-stub: LPhysicsShape:setRestitution
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    print("restitution set")
end

--@api-stub: LPhysicsShape:setSensor
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(false)
    print("sensor flag set")
end

--@api-stub: lurek.physics.attachShape
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    print("body with attached shape at " .. body:getX() .. ", " .. body:getY())
end

--@api-stub: LWorld:setFixtureFriction
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(bodyId, 0, 0.8)
    print("fixture friction updated")
end

--@api-stub: LWorld:setFixtureRestitution
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(bodyId, 0, 0.9)
    print("fixture restitution updated")
end

--@api-stub: LWorld:setFixtureSensor
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(bodyId, 0, true)
    print("fixture sensor updated")
end

--@api-stub: LWorld:newPolygonBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local verts = { 0, -20, -15, 15, 15, 15 }
    local tri = world:newPolygonBody(100, 200, verts, "dynamic")
    print("polygon body at " .. tri:getX() .. ", " .. tri:getY())
end

--@api-stub: LWorld:newEdgeBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    print("edge body at " .. wall:getX() .. ", " .. wall:getY())
end

--@api-stub: LWorld:newChainBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local terrain = { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }
    local ground = world:newChainBody(0, 500, terrain, false, "static")
    print("chain body at " .. ground:getX() .. ", " .. ground:getY())
end

--@api-stub: LWorld:newBodies
do
    local world = lurek.physics.newWorld(0, 400)
    local specs = { { 15, 50, "dynamic" }, { 30, 50, "dynamic" }, { 45, 50, "static" }, }
    local ids = world:newBodies(specs)
    print("batch created = " .. #ids)
end

--@api-stub: LWorld:getBodyIds
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    print("body ids = " .. #ids)
end

--@api-stub: LWorld:getBodyType
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    print("body type = " .. world:getBodyType(body:getId()))
end

--@api-stub: LPhysicsShape:type
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    print("shape type = " .. shape:type())
end

--@api-stub: LPhysicsShape:typeOf
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    print("is LPhysicsShape = " .. tostring(shape:typeOf("LPhysicsShape")))
end

--@api-stub: LPhysicsShape:destroy
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    shape:destroy()
    print("shape destroyed")
end

--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)


--@api-stub: LWorld:addRevoluteJoint
do
    local world = lurek.physics.newWorld(0, 400); local arm = world:newBody(200, 200, "dynamic")
    local pivot = world:newBody(200, 150, "static"); local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    print("revolute joint id = " .. jointId)
    world:step(1 / 60)
    print("arm angle = " .. arm:getAngle())
end

--@api-stub: LWorld:addDistanceJoint
do
    local world = lurek.physics.newWorld(0, 400); local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic"); local jointId = world:addDistanceJoint( bodyA:getId(), bodyB:getId(), 100, 100, 200, 100, 100 )
    print("distance joint id = " .. jointId); world:step(1 / 60)
    local ax, ay = bodyA:getPosition(); local bx, by = bodyB:getPosition()
    print("A=" .. ax .. "," .. ay .. " B=" .. bx .. "," .. by)
end

--@api-stub: LWorld:addPrismaticJoint
do
    local world = lurek.physics.newWorld(0, 400); local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic"); local jointId = world:addPrismaticJoint( rail:getId(), slider:getId(), 300, 300, 1, 0 )
    print("prismatic joint id = " .. jointId); slider:applyForce(200, 0)
    world:step(1 / 60)
    print("slider x = " .. slider:getX())
end

--@api-stub: LWorld:addWeldJoint
do
    local world = lurek.physics.newWorld(0, 400); local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic"); local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    print("weld joint id = " .. jointId); chassis:applyForce(100, 0)
    world:step(1 / 60); print("chassis x = " .. chassis:getX())
    print("turret x = " .. turret:getX())
end

--@api-stub: LWorld:addRopeJoint
do
    local world = lurek.physics.newWorld(0, 400); local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic"); local jointId = world:addRopeJoint( ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120 )
    print("rope joint id = " .. jointId)
    for _ = 1, 60 do world:step(1 / 60) end
    print("weight y = " .. weight:getY())
end

--@api-stub: LWorld:addWheelJoint
do
    local world = lurek.physics.newWorld(0, 400); local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic"); local jointId = world:addWheelJoint( car:getId(), wheel:getId(), 200, 230, 0, 1 )
    print("wheel joint id = " .. jointId)
    world:step(1 / 60)
    print("wheel pos = " .. wheel:getX() .. ", " .. wheel:getY())
end

--@api-stub: LWorld:addMouseJoint
do
    local world = lurek.physics.newWorld(0, 400); local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500); print("mouse joint id = " .. jointId)
    for _ = 1, 30 do world:step(1 / 60) end; print("box pos = " .. box:getX() .. ", " .. box:getY())
    world:setMouseJointTarget(jointId, 400, 150); for _ = 1, 30 do world:step(1 / 60) end
    print("box after retarget = " .. box:getX() .. ", " .. box:getY())
end

--@api-stub: LWorld:addMotorJoint
do
    print("motor joint available")
end

--@api-stub: LWorld:addFrictionJoint
do
    local world = lurek.physics.newWorld(0, 0); local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic"); puck:setVelocity(200, 0)
    local jointId = world:addFrictionJoint( ground:getId(), puck:getId(), 200, 400, 100, 50 ); print("friction joint id = " .. jointId)
    for _ = 1, 60 do world:step(1 / 60) end; local vx, vy = puck:getVelocity()
    print("puck vel after friction = " .. vx .. ", " .. vy)
end

--@api-stub: LWorld:addGearJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    print("gear joint id = " .. jointId)
end

--@api-stub: LWorld:addPulleyJoint
do
    local world = lurek.physics.newWorld(0, 400); local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic"); local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    print("pulley joint id = " .. jointId); boxA:setMass(5.0)
    boxB:setMass(1.0); for _ = 1, 60 do world:step(1 / 60) end
    print("heavy A y = " .. boxA:getY()); print("light B y = " .. boxB:getY())
end

--@api-stub: LWorld:getJointIds
do
    local world = lurek.physics.newWorld(0, 400); local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    print("joint ids = " .. #ids)
end

--@api-stub: LWorld:jointCount
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint count = " .. world:jointCount())
end

--@api-stub: LWorld:getJointBodies
do
    local world = lurek.physics.newWorld(0, 400); local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local bodyA, bodyB = world:getJointBodies(jid)
    print("joint bodies = " .. bodyA .. "," .. bodyB)
end

--@api-stub: LWorld:getJointType
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint type = " .. world:getJointType(jid))
end

--@api-stub: LWorld:setJointLimits
do
    local world = lurek.physics.newWorld(0, 400); local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("joint limits set")
end

--@api-stub: LWorld:getJointLimits
do
    local world = lurek.physics.newWorld(0, 400); local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic"); local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    local lo, hi = world:getJointLimits(jid)
    print("limits = " .. lo .. " to " .. hi)
end

--@api-stub: LWorld:setJointLimitsEnabled
do
    local world = lurek.physics.newWorld(0, 400); local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    print("joint limits enabled")
end

--@api-stub: LWorld:setJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0); local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor speed set")
end

--@api-stub: LWorld:getJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0); local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor speed = " .. world:getJointMotorSpeed(jid))
end

--@api-stub: LWorld:setJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400); local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint( ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50 )
    world:setJointBreakForce(jid, 500)
    print("break force set")
end

--@api-stub: LWorld:getJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400); local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint( ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50 )
    world:setJointBreakForce(jid, 500)
    print("break force = " .. world:getJointBreakForce(jid))
end

--@api-stub: LWorld:destroyJoint
do
    local world = lurek.physics.newWorld(0, 400); local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic"); local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joints = " .. world:jointCount())
    world:destroyJoint(jid)
    print("after destroy = " .. world:jointCount())
end

--- Physics Module Part 4: raycasting, AABB queries, contacts, collision events


--@api-stub: LWorld:raycast
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "static")
    world:newCircleBody(400, 200, 20, "static")
    local hit = world:raycast(0, 200, 600, 200)
    if hit then print("hit body " .. hit.bodyId) print("hit point = " .. hit.x .. ", " .. hit.y) print("normal = " .. hit.normalX .. ", " .. hit.normalY) print("toi = " .. hit.toi) else print("no hit") end
end

--@api-stub: LWorld:raycastClosest
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 300, 15, "static")
    world:newCircleBody(200, 500, 15, "static")
    local hit = world:raycastClosest(200, 100, 0, 1, 500)
    if hit then print("closest hit body = " .. hit.bodyId) print("at " .. hit.x .. ", " .. hit.y) print("distance factor = " .. hit.toi) else print("no hit within range") end
end

--@api-stub: LWorld:raycastAll
do
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do world:newCircleBody(100 + i * 80, 200, 10, "static") end
    local hits = world:raycastAll(50, 200, 1, 0, 600)
    print("total hits = " .. #hits)
    for i, hit in ipairs(hits) do print("  hit " .. i .. ": body=" .. hit.bodyId .. " at " .. hit.x .. "," .. hit.y) end
end

--@api-stub: LWorld:queryAABB
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(150, 120, 10, "dynamic"); world:newCircleBody(500, 500, 10, "dynamic")
    local found = world:queryAABB(50, 50, 200, 200)
    print("bodies in AABB = " .. #found)
    for _, id in ipairs(found) do print("  body id = " .. id) end
end

--@api-stub: LWorld:getBodyAtPoint
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(200, 200, 30, "static")
    world:newCircleBody(400, 400, 30, "static"); local id = world:getBodyAtPoint(210, 205)
    if id then print("body at point = " .. id) else print("no body at point") end
    local miss = world:getBodyAtPoint(0, 0)
    print("miss = " .. tostring(miss))
end

--@api-stub: LWorld:getContacts
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 400, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20); local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do world:step(1 / 60) end; local contacts = world:getContacts()
    print("active contacts = " .. #contacts)
    for _, c in ipairs(contacts) do print("  bodyA=" .. c.bodyA .. " bodyB=" .. c.bodyB) end
end

--@api-stub: LWorld:getBeginContactEvents
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20); world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    for frame = 1, 180 do world:step(1 / 60) local events = world:getBeginContactEvents() if #events > 0 then count = #events print("frame " .. frame .. ": begin events = " .. count) break end end
    print("begin total = " .. count)
end

--@api-stub: LWorld:getEndContactEvents
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20); local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9); local count = 0
    for frame = 1, 300 do world:step(1 / 60) local events = world:getEndContactEvents() if #events > 0 then count = #events print("frame " .. frame .. ": end events = " .. count) break end end
    print("end total = " .. count)
end

--@api-stub: LWorld:getCollisionEvents
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    for frame = 1, 120 do world:step(1 / 60) local events = world:getCollisionEvents() if #events > 0 then print("frame " .. frame .. ": " .. #events .. " collision(s)") for _, ev in ipairs(events) do print("  A=" .. ev.bodyA .. " B=" .. ev.bodyB) end break end end
end

--@api-stub: LWorld:setBeginContact
do
    local world = lurek.physics.newWorld(0, 400); local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB) contactCount = contactCount + 1 print("callback: contact #" .. contactCount .. " A=" .. bodyA .. " B=" .. bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("total begin contacts = " .. contactCount)
    world:clearBeginContact()
end

--@api-stub: LWorld:setEndContact
do
    local world = lurek.physics.newWorld(0, 400); local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20); local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB) endCount = endCount + 1
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("end contacts (bounces) = " .. endCount)
    world:clearEndContact()
end

--@api-stub: LWorld:getBodyContacts
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20); local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do world:step(1 / 60) end; local contacts = world:getBodyContacts(ball:getId())
    print("ball contacts = " .. #contacts)
    for _, c in ipairs(contacts) do print("  other=" .. c.bodyB .. " normal=" .. c.normalX .. "," .. c.normalY .. " touching=" .. tostring(c.isTouching)) end
end

--@api-stub: lurek.physics.testAABB
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    print("overlap = " .. tostring(overlap))
    local noOverlap = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    print("no overlap = " .. tostring(noOverlap))
end

--@api-stub: lurek.physics.testCircleAABB
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    print("circle-aabb hit = " .. tostring(hit))
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    print("circle-aabb miss = " .. tostring(miss))
end

--@api-stub: lurek.physics.testCircles
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    print("circles touching = " .. tostring(touching))
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    print("circles apart = " .. tostring(apart))
end

--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced


--@api-stub: LWorld:addZone
do
    local world = lurek.physics.newWorld(0, 400); local zone = world:addZone(100, 100, 200, 200)
    print("zone id = " .. zone:getId())
    zone:setEnabled(true)
    zone:setPriority(10)
    zone:setLayerMask(1)
end

--@api-stub: LZone:setGravityDirectional
do
    local world = lurek.physics.newWorld(0, 400); local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0); local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500); local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do world:step(1 / 60) end; local x, y = ball:getPosition()
    print("ball in wind zone: " .. x .. ", " .. y)
end

--@api-stub: LZone:setGravityPoint
do
    local world = lurek.physics.newWorld(0, 400); local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0); local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500); local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do world:step(1 / 60) end; local x, y = ball:getPosition()
    print("ball in wind zone: " .. x .. ", " .. y)
end

--@api-stub: LZone:setGravityRepulsor
do
    local world = lurek.physics.newWorld(0, 400); local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300); local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero(); local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do world:step(1 / 60) end; local vx, vy = ball:getVelocity()
    print("ball in zero-g: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setGravityZero
do
    local world = lurek.physics.newWorld(0, 400); local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300); local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero(); local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do world:step(1 / 60) end; local vx, vy = ball:getVelocity()
    print("ball in zero-g: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setLinearDampingOverride
do
    local world = lurek.physics.newWorld(0, 400); local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0); water:setAngularDampingOverride(2.0)
    water:setGravityDirectional(0, 100); local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100); for _ = 1, 120 do world:step(1 / 60) end
    local vx, vy = diver:getVelocity(); print("diver in water: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setAngularDampingOverride
do
    local world = lurek.physics.newWorld(0, 400); local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0); water:setAngularDampingOverride(2.0)
    water:setGravityDirectional(0, 100); local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100); for _ = 1, 120 do world:step(1 / 60) end
    local vx, vy = diver:getVelocity(); print("diver in water: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setCircle
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    print("circular zone created")
end

--@api-stub: LWorld:getZoneEvents
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    local ball = world:newCircleBody(250, 100, 8, "dynamic")
    for frame = 1, 120 do world:step(1 / 60) local events = world:getZoneEvents() for _, ev in ipairs(events) do print("frame " .. frame .. ": zone=" .. ev.zone_id .. " body=" .. ev.body_id .. " kind=" .. ev.kind) end end
end

--@api-stub: LZone:destroy
do
    local world = lurek.physics.newWorld(0, 400); local z1 = world:addZone(0, 0, 100, 100)
    local z2 = world:addZone(200, 200, 100, 100)
    print("zone 1 id = " .. z1:getId())
    z1:destroy()
    print("zone 1 destroyed")
end

--@api-stub: lurek.physics.newCellular
do
    local grid = lurek.physics.newCellular(64, 64); grid:setCell(32, 0, 1)
    grid:setCell(33, 0, 1); grid:setCell(34, 0, 1)
    print("cell at 32,0 = " .. grid:getCell(32, 0))
    grid:step()
    print("after step: cell at 32,1 = " .. grid:getCell(32, 1))
end

--@api-stub: LCellular:fillRect
do
    local grid = lurek.physics.newCellular(128, 128); grid:fillRect(10, 10, 20, 5, 2)
    grid:fillCircle(64, 64, 15, 3); local count = grid:countCells(2)
    print("type-2 cells = " .. count)
    local count3 = grid:countCells(3)
    print("type-3 cells = " .. count3)
end

--@api-stub: LCellular:fillCircle
do
    local grid = lurek.physics.newCellular(128, 128); grid:fillRect(10, 10, 20, 5, 2)
    grid:fillCircle(64, 64, 15, 3); local count = grid:countCells(2)
    print("type-2 cells = " .. count)
    local count3 = grid:countCells(3)
    print("type-3 cells = " .. count3)
end

--@api-stub: LCellular:stepN
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, 1)
    grid:stepN(10)
    local positions = grid:findCells(1)
    print("type-1 cells after 10 steps = " .. #positions)
end

--@api-stub: LCellular:findCells
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, 1)
    grid:stepN(10)
    local positions = grid:findCells(1)
    print("type-1 cells after 10 steps = " .. #positions)
end

--@api-stub: LCellular:toImageData
do
    local grid = lurek.physics.newCellular(32, 32); grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes(); print("grid bytes length = " .. #bytes)
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: LCellular:toBytes
do
    local grid = lurek.physics.newCellular(32, 32); grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes(); print("grid bytes length = " .. #bytes)
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: LCellular:loadFromBytes
do
    local grid = lurek.physics.newCellular(32, 32); grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes(); print("grid bytes length = " .. #bytes)
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: lurek.physics.newTerrain
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true); terrain:fillCircle(64, 32, 10, false)
    terrain:flush()
    print("terrain created with hole")
    print("dirty = " .. tostring(terrain:isDirty()))
end

--@api-stub: LTerrain:setCell
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true); terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:getCell
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true); terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:fillRect
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true); terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:collapseColumns
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true); terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush(); terrain:collapseColumns()
    terrain:flush(); local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:solidPositions
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true); terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush(); terrain:collapseColumns()
    terrain:flush(); local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:spawnDebris
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true); terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush(); terrain:collapseColumns()
    terrain:flush(); local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:toBytes
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 4, world); terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false); terrain:flush(); local data = terrain:toBytes()
    print("terrain bytes = " .. #data); local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data); terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0))); print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LTerrain:loadFromBytes
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 4, world); terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false); terrain:flush(); local data = terrain:toBytes()
    print("terrain bytes = " .. #data); local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data); terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0))); print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LTerrain:toImageData
do
    local world = lurek.physics.newWorld(0, 400); local terrain = lurek.physics.newTerrain(32, 32, 4, world); terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false); terrain:flush(); local data = terrain:toBytes()
    print("terrain bytes = " .. #data); local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data); terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0))); print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LWorld:setBodyData
do
    local world = lurek.physics.newWorld(0, 400); local player = world:newCircleBody(100, 100, 10, "dynamic"); local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 }); world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId()); print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId()); print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId()); print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:getBodyData
do
    local world = lurek.physics.newWorld(0, 400); local player = world:newCircleBody(100, 100, 10, "dynamic"); local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 }); world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId()); print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId()); print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId()); print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:clearBodyData
do
    local world = lurek.physics.newWorld(0, 400); local player = world:newCircleBody(100, 100, 10, "dynamic"); local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 }); world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId()); print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId()); print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId()); print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:setBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400); local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10); world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId()); if nx then print("one-way normal = " .. nx .. ", " .. ny) end
    world:clearBodyOneWay(platform:getId()); nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:getBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400); local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10); world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId()); if nx then print("one-way normal = " .. nx .. ", " .. ny) end
    world:clearBodyOneWay(platform:getId()); nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:clearBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400); local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10); world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId()); if nx then print("one-way normal = " .. nx .. ", " .. ny) end
    world:clearBodyOneWay(platform:getId()); nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:setBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("CCD enabled = " .. tostring(world:getBodyCCD(bullet:getId())))
    bullet:setVelocity(2000, 0)
end

--@api-stub: LWorld:getBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("CCD enabled = " .. tostring(world:getBodyCCD(bullet:getId())))
    bullet:setVelocity(2000, 0)
end

--@api-stub: LWorld:sleepBody
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId(); lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id); print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:wakeUpBody
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId(); lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id); print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:isBodySleeping
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId(); lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id); print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:drawDebug
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(200, 200, 20, "dynamic")
    world:newBody(200, 500, "static")
    local img = lurek.image.newImageData(800, 600)
    world:drawDebug(img, 0, 255, 0, 200)
    print("debug drawn to image data")
end

--@api-stub: lurek.physics.debugDraw
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true); print("debug draw enabled")
    lurek.physics.drawDebugGpu(world)
    print("GPU debug drawn")
    lurek.physics.debugDraw(false)
end

--@api-stub: lurek.physics.destroyWorld
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(200, 200, 10, "dynamic"); print("before clear: " .. world:getBodyCount())
    world:clear(); print("after clear: " .. world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("world destroyed")
end

--@api-stub: LWorld:clear
do
    local world = lurek.physics.newWorld(0, 400); world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(200, 200, 10, "dynamic"); print("before clear: " .. world:getBodyCount())
    world:clear(); print("after clear: " .. world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("world destroyed")
end

--@api-stub: lurek.physics.step
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    print("free fn: pos=" .. x .. "," .. y .. " vel=" .. vx .. "," .. vy)
end

--@api-stub: lurek.physics.getCollisions
do
    local world = lurek.physics.newWorld(0, 400); local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20); world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do lurek.physics.step(world, 1 / 60) end; local collisions = lurek.physics.getCollisions(world)
    print("collisions = " .. #collisions)
    for _, c in ipairs(collisions) do print("  A=" .. c.body_a .. " B=" .. c.body_b) end
end

--@api-stub: lurek.physics.isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400); local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
end

--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns


--@api-stub: LBody:getHeight
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getId
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getPosition
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getWidth
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getX
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LBody:getY
do
    local world = lurek.physics.newWorld(0, 9.8); local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local x, y = body:getPosition(); print("pos=" .. x .. "," .. y)
    print("x=" .. body:getX()); print("y=" .. body:getY())
    print("id=" .. body:getId()); print("w=" .. body:getWidth())
    print("h=" .. body:getHeight())
end

--@api-stub: LCellular:countCells
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:getCell
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:setCell
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:step
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:toImageDataRegion
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:type
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LCellular:typeOf
do
    local ca = lurek.physics.newCellular(32, 32); ca:setCell(5, 5, 1)
    print("cell(5,5)=" .. ca:getCell(5, 5)); ca:step()
    print("count=" .. ca:countCells(1)); local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("img=" .. tostring(img ~= nil)); print("type=" .. ca:type())
    print("typeOf=" .. tostring(ca:typeOf("LCellular")))
end

--@api-stub: LPhysicsShape:getBoundingBox
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LPhysicsShape:getRadius
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LPhysicsShape:getType
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LTerrain:fillAll
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:fillCircle
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:flush
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:isDirty
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:type
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LTerrain:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8); local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true); print("is_dirty=" .. tostring(terrain:isDirty()))
    terrain:fillCircle(256, 256, 50, false); terrain:flush()
    print("type=" .. terrain:type())
    print("typeOf=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api-stub: LWorld:addFixture
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:clearBeginContact
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:clearEndContact
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:destroyBody
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:fixtureCount
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:setBodyType
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LWorld:setMouseJointTarget
do
    local world = lurek.physics.newWorld(0, 9.8); local body = world:newBody(0, 0, "dynamic"); local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture_count=" .. world:fixtureCount(body:getId())); world:setBodyType(body:getId(), "static"); world:clearBeginContact()
    world:clearEndContact(); local bodies = world:newBodies({{ x=10, y=10, type="dynamic" }, { x=20, y=10, type="static" }})
    print("batch_bodies=" .. #bodies); local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50); world:destroyBody(body:getId())
end

--@api-stub: LZone:getId
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setEnabled
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setLayerMask
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:setPriority
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:type
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: LZone:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8); local zone = world:addZone(0, 0, 200, 200)
    print("zone_id=" .. zone:getId()); zone:setEnabled(true)
    zone:setLayerMask(0xFF); zone:setPriority(1)
    print("type=" .. zone:type())
    print("typeOf=" .. tostring(zone:typeOf("LZone")))
end

--@api-stub: lurek.physics.drawDebugGpu
do
    local world = lurek.physics.newWorld(0, 9.8)
    lurek.physics.drawDebugGpu(world, {})
    print("debug_gpu_draw ok")
end

--@api-stub: lurek.physics.getBody
do
    local world = lurek.physics.newWorld(0, 9.8)
    local b = lurek.physics.newBody(world, 0, 0, "dynamic")
    local b2 = lurek.physics.getBody(world, b)
    print("got_body=" .. tostring(b2 ~= nil))
end

--@api-stub: lurek.physics.newBody
do
    local world = lurek.physics.newWorld(0, 0)
    local b = lurek.physics.newBody(world, 50, 50, "static")
    print("body_id=" .. b:getId())
end

--@api-stub: LChainShape:getType
do
    local chain = lurek.physics.newChainShape(false, 0, 0, 10, 0, 10, 10, 0, 10)
    print("chain_type=" .. chain:getType())
end

--@api-stub: lurek.physics.setBodyVelocity
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    print("velocity set")
end

--@api-stub: lurek.physics.setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    print("sleeping_allowed set")
end

--@api-stub: lurek.physics.testPoint
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    print("inside=" .. tostring(inside))
    print("outside=" .. tostring(outside))
end

print("content/examples/physics.lua")
