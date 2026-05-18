--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties

--@api-stub: lurek.physics.newWorld / LWorld:getGravity / setGravity
-- Create a physics world with gravity.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity = " .. gx .. ", " .. gy)
    world:setGravity(0, 800)
    gx, gy = world:getGravity()
    print("new gravity = " .. gx .. ", " .. gy)
end

--@api-stub: LWorld:step / stepFixed
-- Stepping the simulation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:step(1 / 60)
    world:step(1 / 60)
    print("stepped twice at 60fps")
    local leftover = world:stepFixed(0.025, 1 / 60, 4)
    print("fixed step leftover = " .. leftover)
end

--@api-stub: LWorld:setMeter / getMeter / toPhysics / toPixels
-- Unit conversion between pixels and physics meters.
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

--@api-stub: LWorld:setSolverIterations / getSolverIterations
-- Solver iteration control.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver iterations = " .. world:getSolverIterations())
end

--@api-stub: LWorld:newBody / LBody basic properties
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
end

--@api-stub: LWorld:newBody static/kinematic/sensor types
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

--@api-stub: LBody:setPosition / setVelocity / getVelocity
-- Teleporting and setting velocity.
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

--@api-stub: LBody:setAngle / getAngle / setAngularVelocity / getAngularVelocity
-- Rotation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle = " .. body:getAngle())
    body:setAngularVelocity(2.0)
    print("angular vel = " .. body:getAngularVelocity())
end

--@api-stub: LBody:getMass / setMass / setFriction / getFriction / setRestitution / getRestitution
-- Mass and material properties.
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

--@api-stub: LBody:setLinearDamping / getLinearDamping / setAngularDamping / getAngularDamping
-- Damping (velocity decay).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    body:setAngularDamping(0.3)
    print("linear damp = " .. body:getLinearDamping())
    print("angular damp = " .. body:getAngularDamping())
end

--@api-stub: LBody:setGravityScale / getGravityScale
-- Per-body gravity scale.
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

--@api-stub: LBody:applyForce / applyForceAtPoint / applyImpulse / applyAngularImpulse / applyTorque
-- Forces and impulses.
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

--@api-stub: LBody:setBullet / isBullet / setFixedRotation / isFixedRotation
-- CCD and rotation lock.
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

--@api-stub: LBody:setType / getType / setLayer / getLayer / setMask / getMask
-- Body type changes and collision filtering.
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

--@api-stub: LBody:sleep / wakeUp / isSleeping / setSleepingAllowed / isSleepingAllowed
-- Sleep state management.
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

--@api-stub: LBody:destroy / LWorld:getBodyCount
-- Destroying bodies.
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

--@api-stub: LBody:type / typeOf
-- Type checking.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type = " .. body:type())
    print("is LBody = " .. tostring(body:typeOf("LBody")))
    print("is Object = " .. tostring(body:typeOf("Object")))
end

--@api-stub: LWorld:type / typeOf
-- World type checking.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    print("type = " .. world:type())
    print("is LWorld = " .. tostring(world:typeOf("LWorld")))
end

print("physics_00.lua")
