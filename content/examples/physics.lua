-- content/examples/physics.lua
-- Auto-generated from content/examples2/physics_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/physics.lua

local function physics_log(message)
    lurek.log.info("[physics.example] " .. tostring(message))
end

--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.physics.newWorld
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(320, 520, "static")
    local crate = world:newCircleBody(320, 120, 14, "dynamic")
    local gx, gy = world:getGravity()
    world:step(1 / 60)
    physics_log("training room gravity=" .. gx .. "," .. gy)
    physics_log("floor=" .. floor:getType() .. " crate_y=" .. select(2, crate:getPosition()))
end

--@api: LWorld:getGravity
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    example_print_log("gravity", gx, gy)
    world:setGravity(10, 800)
    example_print_log("updated", world:getGravity())
end

--@api: LWorld:setGravity
do
    local world = lurek.physics.newWorld(0, 200)
    world:setGravity(25, 600)
    local gx, gy = world:getGravity()
    example_print_log("gravity", gx, gy)
    example_print_log("body_count", world:getBodyCount())
end

--@api: LWorld:step
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 12, "dynamic")
    world:step(1 / 60)
    example_print_log("position", body:getPosition())
    example_print_log("velocity", body:getVelocity())
end

--@api: LWorld:stepFixed
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 120, 10, "dynamic")
    local remainder = world:stepFixed(0.025, 1 / 60, 4)
    local x, y = ball:getPosition()
    local vx, vy = ball:getVelocity()
    physics_log("fixed-step remainder=" .. remainder .. " pos=" .. x .. "," .. y)
    physics_log("post-step velocity=" .. vx .. "," .. vy .. " iterations=" .. world:getSolverIterations())
end

--@api: LWorld:setMeter
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local playerWidthPixels = 128
    local playerWidthMeters = world:toPhysics(playerWidthPixels)
    local jumpArcPixels = world:toPixels(1.5)
    physics_log("platformer meter=" .. world:getMeter() .. " player_width_m=" .. playerWidthMeters)
    physics_log("jump arc preview px=" .. jumpArcPixels)
end

--@api: LWorld:getMeter
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local bridgeSpanMeters = 2.0
    local bridgeSpanPixels = world:toPixels(bridgeSpanMeters)
    local rampHeightPixels = world:toPixels(0.75)
    physics_log("builder meter=" .. world:getMeter() .. " bridge_px=" .. bridgeSpanPixels)
    physics_log("ramp height px=" .. rampHeightPixels)
end

--@api: LWorld:toPhysics
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local doorWidthPx = 96
    local doorWidthMeters = world:toPhysics(doorWidthPx)
    local heroRadiusMeters = world:toPhysics(24)
    physics_log("door width meters=" .. doorWidthMeters)
    physics_log("hero radius meters=" .. heroRadiusMeters)
    physics_log("reference pixels=" .. world:toPixels(1.5))
end

--@api: LWorld:toPixels
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local ropeLengthMeters = 2.5
    local ropeLengthPixels = world:toPixels(ropeLengthMeters)
    local ledgeDepthPixels = world:toPixels(0.5)
    physics_log("rope length px=" .. ropeLengthPixels)
    physics_log("ledge depth px=" .. ledgeDepthPixels)
    physics_log("reverse sample meters=" .. world:toPhysics(160))
end

--@api: LWorld:setSolverIterations
do
    local world = lurek.physics.newWorld(0, 400)
    local crate = world:newCircleBody(160, 80, 10, "dynamic")
    world:setSolverIterations(8)
    crate:setVelocity(0, 20)
    world:step(1 / 60)
    physics_log("solver iterations=" .. world:getSolverIterations())
    physics_log("crate velocity y=" .. select(2, crate:getVelocity()))
end

--@api: LWorld:getSolverIterations
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(10)
    local floor = world:newBody(200, 420, "static")
    local ball = world:newCircleBody(200, 120, 8, "dynamic")
    world:step(1 / 60)
    physics_log("solver iterations=" .. world:getSolverIterations())
    physics_log("scene bodies=" .. world:getBodyCount() .. " floor=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end

--@api: LWorld:newBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    world:step(1 / 60)
    example_print_log("id", body:getId())
    example_print_log("type", body:getType())
    example_print_log("position", body:getPosition())
end

--@api: LWorld:newCircleBody
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    local target = world:newBody(200, 260, "static")
    ball:setVelocity(15, -20)
    world:step(1 / 60)
    physics_log("projectile pos=" .. select(1, ball:getPosition()) .. "," .. select(2, ball:getPosition()))
    physics_log("projectile size=" .. ball:getWidth() .. "x" .. ball:getHeight() .. " target=" .. target:getType())
end

--@api: LWorld:kinematic
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(400, 580, "static")
    local platform = world:newBody(300, 400, "kinematic")
    local trigger = world:newBody(500, 300, "sensor")
    example_print_log("types", floor:getType(), platform:getType(), trigger:getType())
end

--@api: LBody:setPosition
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    example_print_log("position", body:getPosition())
    example_print_log("velocity", body:getVelocity())
end

--@api: LBody:setVelocity
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(50, -100)
    example_print_log("velocity", body:getVelocity())
    world:step(1 / 60)
    example_print_log("position", body:getPosition())
end

--@api: LBody:getVelocity
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(25, -50)
    example_print_log("velocity", body:getVelocity())
    example_print_log("type", body:getType())
end

--@api: LBody:setAngle
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    example_print_log("angle", body:getAngle())
    example_print_log("angular_velocity", body:getAngularVelocity())
end

--@api: LBody:getAngle
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 6)
    example_print_log("angle", body:getAngle())
    example_print_log("position", body:getPosition())
end

--@api: LBody:setAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(2.0)
    example_print_log("angular_velocity", body:getAngularVelocity())
    world:step(1 / 60)
    example_print_log("angle", body:getAngle())
end

--@api: LBody:getAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(1.25)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end

--@api: LBody:getMass
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    example_print_log("mass", body:getMass())
    example_print_log("friction", body:getFriction())
    example_print_log("restitution", body:getRestitution())
end

--@api: LBody:setMass
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(7.5)
    example_print_log("mass", body:getMass())
    example_print_log("type", body:getType())
end

--@api: LBody:setFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.8)
    example_print_log("friction", body:getFriction())
    example_print_log("mass", body:getMass())
end

--@api: LBody:getFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.25)
    example_print_log("friction", body:getFriction())
    example_print_log("restitution", body:getRestitution())
end

--@api: LBody:setRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    example_print_log("restitution", body:getRestitution())
    example_print_log("mass", body:getMass())
end

--@api: LBody:getRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.15)
    example_print_log("restitution", body:getRestitution())
    example_print_log("friction", body:getFriction())
end

--@api: LBody:setLinearDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    example_print_log("linear_damping", body:getLinearDamping())
    example_print_log("angular_damping", body:getAngularDamping())
end

--@api: LBody:getLinearDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.75)
    example_print_log("linear_damping", body:getLinearDamping())
    example_print_log("velocity", body:getVelocity())
end

--@api: LBody:setAngularDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.3)
    example_print_log("angular_damping", body:getAngularDamping())
    example_print_log("angle", body:getAngle())
end

--@api: LBody:getAngularDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.9)
    example_print_log("angular_damping", body:getAngularDamping())
    example_print_log("linear_damping", body:getLinearDamping())
end

--@api: LBody:setGravityScale
do
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    floaty:setGravityScale(0.2)
    example_print_log("normal", normal:getGravityScale())
    example_print_log("floaty", floaty:getGravityScale())
end

--@api: LBody:getGravityScale
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setGravityScale(-1.0)
    example_print_log("gravity_scale", body:getGravityScale())
    example_print_log("type", body:getType())
end

--@api: LBody:applyForce
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("position", body:getPosition())
end

--@api: LBody:applyForceAtPoint
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForceAtPoint(0, -50, 210, 200)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("angular_velocity", body:getAngularVelocity())
end

--@api: LBody:applyImpulse
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyImpulse(0, -200)
    world:step(1 / 60)
    example_print_log("velocity", body:getVelocity())
    example_print_log("position", body:getPosition())
end

--@api: LBody:applyAngularImpulse
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyAngularImpulse(5.0)
    world:step(1 / 60)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end

--@api: LBody:applyTorque
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyTorque(10.0)
    world:step(1 / 60)
    example_print_log("angular_velocity", body:getAngularVelocity())
    example_print_log("angle", body:getAngle())
end

--@api: LBody:setBullet
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    example_print_log("is_bullet", bullet:isBullet())
    example_print_log("type", bullet:getType())
end

--@api: LBody:isBullet
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    example_print_log("is_bullet", bullet:isBullet())
    example_print_log("position", bullet:getPosition())
end

--@api: LBody:setFixedRotation
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    example_print_log("fixed_rotation", player:isFixedRotation())
    example_print_log("angle", player:getAngle())
end

--@api: LBody:isFixedRotation
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    example_print_log("fixed_rotation", player:isFixedRotation())
    example_print_log("type", player:getType())
end

--@api: LBody:setType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    example_print_log("type", body:getType())
    example_print_log("layer", body:getLayer())
end

--@api: LBody:getType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "sensor")
    body:setLayer(8)
    world:setBodyData(body:getId(), { role = "checkpoint" })
    local data = world:getBodyData(body:getId())
    physics_log("checkpoint type=" .. body:getType() .. " id=" .. body:getId())
    physics_log("layer=" .. body:getLayer() .. " role=" .. data.role)
end

--@api: LBody:setLayer
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(2)
    example_print_log("layer", body:getLayer())
    example_print_log("mask", body:getMask())
end

--@api: LBody:getLayer
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(4)
    example_print_log("layer", body:getLayer())
    example_print_log("type", body:getType())
end

--@api: LBody:setMask
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(3)
    example_print_log("mask", body:getMask())
    example_print_log("layer", body:getLayer())
end

--@api: LBody:getMask
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(7)
    example_print_log("mask", body:getMask())
    example_print_log("id", body:getId())
end

--@api: LBody:sleep
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    example_print_log("sleeping", body:isSleeping())
    example_print_log("allowed", body:isSleepingAllowed())
end

--@api: LBody:wakeUp
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    body:wakeUp()
    example_print_log("sleeping", body:isSleeping())
    example_print_log("allowed", body:isSleepingAllowed())
end

--@api: LBody:isSleeping
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    example_print_log("sleeping", body:isSleeping())
    example_print_log("id", body:getId())
end

--@api: LBody:setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(false)
    example_print_log("allowed", body:isSleepingAllowed())
    example_print_log("sleeping", body:isSleeping())
end

--@api: LBody:isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    example_print_log("allowed", body:isSleepingAllowed())
    example_print_log("type", body:getType())
end

--@api: LBody:destroy
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    example_print_log("before", world:getBodyCount())
    temp:destroy()
    example_print_log("after", world:getBodyCount())
end

--@api: LBody:isValid
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    example_print_log("valid", temp:isValid())
    temp:destroy()
    example_print_log("valid_after_destroy", temp:isValid())
end

--@api: LWorld:getBodyCount
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(100, 100, "dynamic")
    local floor = world:newBody(200, 200, "static")
    local pickup = world:newBody(240, 140, "sensor")
    world:step(1 / 60)
    physics_log("arena bodies=" .. world:getBodyCount())
    physics_log("player=" .. player:getType() .. " floor=" .. floor:getType() .. " pickup=" .. pickup:getType())
end

--@api: LWorld:getStats
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local stats = world:getStats()
    example_print_log("bodies", stats.bodies, "slots", stats.bodySlots, "colliders", stats.colliders)
    example_print_log("joints", stats.joints, "joint_slots", stats.jointSlots)
    example_print_log("zones", stats.zones, "sleeping", stats.sleepingBodies)
    body:destroy()
    stats = world:getStats()
    example_print_log("after_destroy", stats.bodies, "slots", stats.bodySlots)
end

--@api: LBody:type
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(12, -6)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    physics_log("userdata type=" .. body:type() .. " object=" .. tostring(body:typeOf("LObject")))
    physics_log("motion sample=" .. vx .. "," .. vy)
end

--@api: LBody:typeOf
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setGravityScale(0.5)
    local isBody = body:typeOf("LBody")
    local isObject = body:typeOf("LObject")
    local isWorld = body:typeOf("LWorld")
    physics_log("body handle checks body=" .. tostring(isBody) .. " object=" .. tostring(isObject))
    physics_log("world check=" .. tostring(isWorld) .. " type=" .. body:type())
end

--@api: LWorld:type
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(160, 300, "static")
    local ball = world:newCircleBody(160, 120, 10, "dynamic")
    world:step(1 / 60)
    physics_log("world userdata=" .. world:type() .. " world_check=" .. tostring(world:typeOf("LWorld")))
    physics_log("scene bodies=" .. world:getBodyCount() .. " first=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end

--@api: LWorld:typeOf
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(160, 300, "static")
    world:newCircleBody(160, 120, 10, "dynamic")
    local isWorld = world:typeOf("LWorld")
    local isObject = world:typeOf("LObject")
    physics_log("world check=" .. tostring(isWorld) .. " object check=" .. tostring(isObject))
    physics_log("runtime kind=" .. world:type() .. " bodies=" .. world:getBodyCount())
end

--- Physics Module Part 2: shapes, attachShape, fixtures, collision filtering

--@api: lurek.physics.newCircleShape
do
    local circle = lurek.physics.newCircleShape(16)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    example_print_log("type", circle:getType())
    example_print_log("radius", circle:getRadius())
    example_print_log("bounds", minX, minY, maxX, maxY)
end

--@api: lurek.physics.newRectangleShape
do
    local rect = lurek.physics.newRectangleShape(64, 32)
    local minX, minY, maxX, maxY = rect:getBoundingBox()
    rect:setFriction(0.8)
    rect:setDensity(2.0)
    physics_log("crate collider type=" .. rect:getType())
    physics_log("crate bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newPolygonShape
do
    local triangle = lurek.physics.newPolygonShape(0, -20, -15, 15, 15, 15)
    local minX, minY, maxX, maxY = triangle:getBoundingBox()
    triangle:setDensity(1.2)
    triangle:setRestitution(0.1)
    physics_log("roof wedge type=" .. triangle:getType())
    physics_log("roof bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newEdgeShape
do
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    local minX, minY, maxX, maxY = edge:getBoundingBox()
    edge:setFriction(0.6)
    edge:setSensor(false)
    physics_log("ledge edge type=" .. edge:getType())
    physics_log("ledge bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newChainShape
do
    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100)
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100)
    local minX, minY, maxX, maxY = chain:getBoundingBox()
    local loopMinX, loopMinY, loopMaxX, loopMaxY = loop:getBoundingBox()
    physics_log("spline type=" .. chain:getType() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    physics_log("pit loop type=" .. loop:getType() .. " bounds=" .. loopMinX .. "," .. loopMinY .. " -> " .. loopMaxX .. "," .. loopMaxY)
end

--@api: LPhysicsShape:setDensity
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    shape:setFriction(0.4)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("heavy boulder density prepared for " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setFriction
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    shape:setDensity(1.0)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("sticky tire friction tuned on " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setRestitution
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    shape:setDensity(0.8)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("pickup bounce tuned on " .. shape:getType())
    physics_log("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setSensor
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(true)
    shape:setDensity(0.2)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("trigger volume type=" .. shape:getType())
    physics_log("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.attachShape
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
    example_print_log("position", body:getPosition())
end

--@api: LWorld:setFixtureFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end

--@api: LWorld:setFixtureRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(body:getId(), fixture, 0.9)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end

--@api: LWorld:setFixtureSensor
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(body:getId(), fixture, true)
    example_print_log("fixture", fixture)
    example_print_log("fixture_count", world:fixtureCount(body:getId()))
end

--@api: LWorld:newPolygonBody
do
    local world = lurek.physics.newWorld(0, 400)
    local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic")
    tri:setAngularVelocity(1.5)
    world:step(1 / 60)
    local x, y = tri:getPosition()
    physics_log("falling wedge pos=" .. x .. "," .. y)
    physics_log("body type=" .. tri:getType() .. " angle=" .. tri:getAngle())
end

--@api: LWorld:newEdgeBody
do
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    local player = world:newCircleBody(100, 420, 10, "dynamic")
    player:setVelocity(40, 0)
    world:step(1 / 60)
    physics_log("ledge body type=" .. wall:getType() .. " pos_y=" .. select(2, wall:getPosition()))
    physics_log("runner pos=" .. select(1, player:getPosition()) .. "," .. select(2, player:getPosition()))
end

--@api: LWorld:newChainBody
do
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static")
    local bike = world:newCircleBody(120, 420, 8, "dynamic")
    bike:setVelocity(30, 0)
    world:step(1 / 60)
    physics_log("track body type=" .. ground:getType() .. " start_y=" .. select(2, ground:getPosition()))
    physics_log("bike pos=" .. select(1, bike:getPosition()) .. "," .. select(2, bike:getPosition()))
end

--@api: LWorld:newBodies
do
    local world = lurek.physics.newWorld(0, 400)
    local ids = world:newBodies({
        { 15, 50, 12, 12, "dynamic" },
        { 30, 50, 12, 12, "dynamic" },
        { 45, 50, 12, 12, "static" },
    })
    example_print_log("created", #ids)
    example_print_log("body_count", world:getBodyCount())
end

--@api: LWorld:getBodyIds
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    example_print_log("count", #ids)
    example_print_log("first", ids[1])
end

--@api: LWorld:hasBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    example_print_log("has_body", world:hasBody(body:getId()))
    body:destroy()
    example_print_log("has_body_after_destroy", world:hasBody(body:getId()))
end

--@api: LWorld:getBodyType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    world:newBody(100, 220, "static")
    world:setBodyData(body:getId(), { role = "crate" })
    local data = world:getBodyData(body:getId())
    physics_log("body type lookup=" .. world:getBodyType(body:getId()) .. " id=" .. body:getId())
    physics_log("role=" .. data.role .. " world bodies=" .. world:getBodyCount())
end

--@api: LPhysicsShape:type
do
    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    physics_log("shape userdata=" .. shape:type())
    physics_log("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:typeOf
do
    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local isShape = shape:typeOf("LPhysicsShape")
    local isObject = shape:typeOf("LObject")
    local isBody = shape:typeOf("LBody")
    physics_log("shape checks shape=" .. tostring(isShape) .. " object=" .. tostring(isObject))
    physics_log("body check=" .. tostring(isBody) .. " userdata=" .. shape:type())
end

--@api: LPhysicsShape:destroy
do
    local shape = lurek.physics.newCircleShape(10)
    local before = shape:type()
    local radius = shape:getRadius()
    shape:destroy()
    local after = shape:getType()
    physics_log("temporary shape type before=" .. before .. " after=" .. after)
    physics_log("radius sample=" .. radius)
end

--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)

--@api: LWorld:addRevoluteJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local pivot = world:newBody(200, 150, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addDistanceJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(bodyA:getId(), bodyB:getId(), 0, 0, 0, 0, 100)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addPrismaticJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(rail:getId(), slider:getId(), 300, 300, 1, 0)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addWeldJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addRopeJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addWheelJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(car:getId(), wheel:getId(), 200, 230, 0, 1)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addMouseJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    world:setMouseJointTarget(jointId, 400, 150)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addMotorJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addFrictionJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    local jointId = world:addFrictionJoint(ground:getId(), puck:getId(), 200, 400, 100, 50)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addGearJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:addPulleyJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    example_print_log("joint_id", jointId)
    example_print_log("joint_type", world:getJointType(jointId))
end

--@api: LWorld:getJointIds
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    example_print_log("count", #ids)
    example_print_log("first", ids[1])
end

--@api: LWorld:jointCount
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("joint_count", world:jointCount())
end

--@api: LWorld:getJointBodies
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("bodies", world:getJointBodies(jid))
end

--@api: LWorld:getJointType
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("joint_type", world:getJointType(jid))
end

--@api: LWorld:setJointLimits
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    example_print_log("limits", world:getJointLimits(jid))
end

--@api: LWorld:getJointLimits
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    example_print_log("limits", world:getJointLimits(jid))
end

--@api: LWorld:setJointLimitsEnabled
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    example_print_log("limits", world:getJointLimits(jid))
end

--@api: LWorld:setJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    example_print_log("motor_speed", world:getJointMotorSpeed(jid))
end

--@api: LWorld:getJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    example_print_log("motor_speed", world:getJointMotorSpeed(jid))
end

--@api: LWorld:setJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    example_print_log("break_force", world:getJointBreakForce(jid))
end

--@api: LWorld:getJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    example_print_log("break_force", world:getJointBreakForce(jid))
end

--@api: LWorld:destroyJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("before", world:jointCount())
    world:destroyJoint(jid)
    example_print_log("after", world:jointCount())
end

--@api: LWorld:hasJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    example_print_log("has_joint", world:hasJoint(jid))
    world:destroyJoint(jid)
    example_print_log("has_joint_after_destroy", world:hasJoint(jid))
end

--- Physics Module Part 4: raycasting, AABB queries, contacts, collision events

--@api: LWorld:raycast
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 20, "static")
    body:setLayer(0x2)
    local hit = world:raycast(0, 200, 600, 200, { layer = 0x1, mask = 0x2 })
    if hit then
        example_print_log("body", hit.bodyId)
        example_print_log("point", hit.x, hit.y)
        example_print_log("normal", hit.normalX, hit.normalY)
    else
        example_print_log("body", nil)
    end
end

--@api: LWorld:raycastClosest
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 300, 15, "static")
    body:setLayer(0x2)
    local hit = world:raycastClosest(200, 100, 0, 1, 500, { layer = 0x1, mask = 0x2 })
    if hit then
        example_print_log("body", hit.bodyId)
        example_print_log("point", hit.x, hit.y)
        example_print_log("toi", hit.toi)
    else
        example_print_log("body", nil)
    end
end

--@api: LWorld:raycastAll
do
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        local body = world:newCircleBody(100 + i * 80, 200, 10, "static")
        body:setLayer(0x2)
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600, { layer = 0x1, mask = 0x2 })
    example_print_log("count", #hits)
    if hits[1] then
        example_print_log("first", hits[1].bodyId, hits[1].x, hits[1].y)
    end
end

--@api: LWorld:queryAABB
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newCircleBody(100, 100, 10, "dynamic")
    local b = world:newCircleBody(150, 120, 10, "dynamic")
    local c = world:newCircleBody(500, 500, 10, "dynamic")
    a:setLayer(0x2)
    b:setLayer(0x2)
    c:setLayer(0x4)
    local found = world:queryAABB(50, 50, 200, 200, { layer = 0x1, mask = 0x2 })
    example_print_log("count", #found)
    example_print_log("first", found[1])
end

--@api: LWorld:getBodyAtPoint
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 30, "static")
    body:setLayer(0x2)
    local hitId = world:getBodyAtPoint(210, 205, { layer = 0x1, mask = 0x2 })
    local missId = world:getBodyAtPoint(0, 0, { layer = 0x1, mask = 0x2 })
    example_print_log("hit", hitId)
    example_print_log("miss", missId)
end

--@api: LWorld:getContacts
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    example_print_log("count", #contacts)
    example_print_log("ball", ball:getId())
    if contacts[1] then
        example_print_log("touching", contacts[1].isTouching)
    end
end

--@api: LWorld:getBeginContactEvents
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    for _ = 1, 180 do
        world:step(1 / 60)
        local events = world:getBeginContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    example_print_log("count", count)
end

--@api: LWorld:getEndContactEvents
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    for _ = 1, 300 do
        world:step(1 / 60)
        local events = world:getEndContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    example_print_log("count", count)
end

--@api: LWorld:getCollisionEvents
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getCollisionEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    example_print_log("count", count)
end

--@api: LWorld:setBeginContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        example_print_log("callback", bodyA, bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    example_print_log("count", contactCount)
end

--@api: LWorld:setEndContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
        example_print_log("callback", bodyA, bodyB)
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    example_print_log("count", endCount)
end

--@api: LWorld:getBodyContacts
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    example_print_log("count", #contacts)
    if contacts[1] then
        example_print_log("first", contacts[1].bodyA, contacts[1].bodyB)
    end
end

--@api: lurek.physics.testAABB
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    local miss = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    local playerInsideHazard = lurek.physics.testAABB(30, 30, 16, 16, 20, 20, 40, 40)
    local pickupFarAway = lurek.physics.testAABB(30, 30, 16, 16, 120, 120, 8, 8)
    physics_log("hazard overlap=" .. tostring(overlap) .. " player overlap=" .. tostring(playerInsideHazard))
    physics_log("miss=" .. tostring(miss) .. " pickup far=" .. tostring(pickupFarAway))
end

--@api: lurek.physics.testCircleAABB
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    local explosionHitsDoor = lurek.physics.testCircleAABB(160, 96, 24, 150, 80, 40, 60)
    local explosionMissesTower = lurek.physics.testCircleAABB(160, 96, 24, 260, 80, 40, 60)
    physics_log("door splash hit=" .. tostring(hit) .. " explosion door=" .. tostring(explosionHitsDoor))
    physics_log("miss=" .. tostring(miss) .. " tower miss=" .. tostring(explosionMissesTower))
end

--@api: lurek.physics.testCircles
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    local bombHitsShield = lurek.physics.testCircles(200, 200, 18, 214, 200, 12)
    local bombMissesPlayer = lurek.physics.testCircles(200, 200, 18, 260, 200, 12)
    physics_log("touching=" .. tostring(touching) .. " shield hit=" .. tostring(bombHitsShield))
    physics_log("apart=" .. tostring(apart) .. " player miss=" .. tostring(bombMissesPlayer))
end

--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced

--@api: LWorld:addZone
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    zone:setPriority(10)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end

--@api: LZone:setGravityDirectional
do
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end

--@api: LZone:setGravityPoint
do
    local world = lurek.physics.newWorld(0, 400)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(450, 220, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end

--@api: LZone:setGravityRepulsor
do
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local ball = world:newCircleBody(240, 240, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end

--@api: LZone:setGravityZero
do
    local world = lurek.physics.newWorld(0, 400)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    example_print_log("position", ball:getPosition())
    example_print_log("velocity", ball:getVelocity())
end

--@api: LZone:setLinearDampingOverride
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    example_print_log("velocity", diver:getVelocity())
    example_print_log("position", diver:getPosition())
end

--@api: LZone:setAngularDampingOverride
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setAngularDampingOverride(2.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setAngularVelocity(5)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    example_print_log("angular_velocity", diver:getAngularVelocity())
    example_print_log("angle", diver:getAngle())
end

--@api: LZone:setCircle
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end

--@api: LWorld:getZoneEvents
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    world:newCircleBody(250, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getZoneEvents()
        count = count + #events
    end
    example_print_log("count", count)
end

--@api: LZone:destroy
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(0, 0, 100, 100)
    example_print_log("zone_id", zone:getId())
    zone:destroy()
    example_print_log("events", #world:getZoneEvents())
end

--@api: lurek.physics.newTerrain
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 128, 40, false)
    terrain:flush()
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end

--@api: LTerrain:setCell
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    example_print_log("cell", terrain:getCell(5, 5))
    example_print_log("dirty", terrain:isDirty())
end

--@api: LTerrain:getCell
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    example_print_log("cell", terrain:getCell(5, 5))
    example_print_log("type", terrain:type())
end

--@api: LTerrain:fillRect
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillRect(80, 80, 40, 40, false)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("cell", terrain:getCell(10, 10))
end

--@api: LTerrain:collapseColumns
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    example_print_log("collapsed", terrain:collapseColumns())
    example_print_log("dirty", terrain:isDirty())
end

--@api: LTerrain:solidPositions
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    example_print_log("count", #solids)
    if solids[1] then
        example_print_log("first", solids[1].x, solids[1].y)
    end
end

--@api: LTerrain:spawnDebris
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:flush()
    local debris = terrain:spawnDebris({ { x = 64, y = 64 }, { x = 72, y = 64 } }, 1.0, 0.2)
    example_print_log("count", #debris)
    example_print_log("body_count", world:getBodyCount())
end

--@api: LTerrain:toBytes
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local bytes = terrain:toBytes()
    example_print_log("bytes", #bytes)
    example_print_log("dirty", terrain:isDirty())
end

--@api: LTerrain:loadFromBytes
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local bytes = terrain:toBytes()
    local clone = lurek.physics.newTerrain(32, 32, 4, world)
    example_print_log("loaded", clone:loadFromBytes(bytes))
    example_print_log("cell", clone:getCell(0, 0))
end

--@api: LTerrain:toImageData
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local pixels = terrain:toImageData(255, 255, 255, 0, 0, 0)
    example_print_log("bytes", #pixels)
    example_print_log("type", terrain:type())
end

--@api: LWorld:setBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    local data = world:getBodyData(player:getId())
    example_print_log("tag", data.tag)
    example_print_log("hp", data.hp)
end

--@api: LWorld:getBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local data = world:getBodyData(enemy:getId())
    example_print_log("tag", data.tag)
    example_print_log("hp", data.hp)
end

--@api: LWorld:clearBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player" })
    world:clearBodyData(player:getId())
    example_print_log("data", world:getBodyData(player:getId()))
end

--@api: LWorld:setBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    local player = world:newCircleBody(200, 320, 10, "dynamic")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    world:step(1 / 60)
    physics_log("one-way normal=" .. nx .. "," .. ny)
    physics_log("player above platform y=" .. select(2, player:getPosition()))
end

--@api: LWorld:getBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    local coin = world:newBody(220, 360, "sensor")
    world:step(1 / 60)
    physics_log("queried one-way normal=" .. nx .. "," .. ny)
    physics_log("platform=" .. platform:getType() .. " helper=" .. coin:getType())
end

--@api: LWorld:clearBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    world:clearBodyOneWay(platform:getId())
    example_print_log("normal", world:getBodyOneWay(platform:getId()))
end

--@api: LWorld:setBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    example_print_log("ccd", world:getBodyCCD(bullet:getId()))
    example_print_log("id", bullet:getId())
end

--@api: LWorld:getBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    example_print_log("ccd", world:getBodyCCD(bullet:getId()))
    example_print_log("velocity", bullet:getVelocity())
end

--@api: LWorld:sleepBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end

--@api: LWorld:wakeUpBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    world:wakeUpBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end

--@api: LWorld:isBodySleeping
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    example_print_log("sleeping", world:isBodySleeping(body:getId()))
end

--@api: LWorld:drawDebug
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    local img = lurek.image.newImageData(800, 600)
    local ok, err = pcall(function() world:drawDebug(img, 0, 255, 0, 200) end)
    if ok then example_print_log("image", img:type()) else example_print_log("drawDebug skipped: " .. tostring(err)) end
end

--@api: lurek.physics.debugDraw
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    lurek.physics.drawDebugGpu(world, { lineWidth = 2 })
    example_print_log("body_count", world:getBodyCount())
end

--@api: lurek.physics.destroyWorld
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    example_print_log("before", world:getBodyCount())
    lurek.physics.destroyWorld(world)
    example_print_log("after", world:getBodyCount())
end

--@api: LWorld:clear
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    example_print_log("before", world:getBodyCount())
    world:clear()
    example_print_log("after", world:getBodyCount())
end

--@api: lurek.physics.step
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local floor = world:newBody(100, 240, "static")
    body:setVelocity(20, -30)
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    physics_log("module step pos=" .. x .. "," .. y)
    physics_log("velocity=" .. vx .. "," .. vy .. " floor=" .. floor:getType())
end

--@api: lurek.physics.getCollisions
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    example_print_log("count", #collisions)
    if collisions[1] then
        example_print_log("first", collisions[1].body_a, collisions[1].body_b)
    end
end

--@api: lurek.physics.isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    example_print_log("allowed", lurek.physics.isSleepingAllowed(world, body))
    lurek.physics.setSleepingAllowed(world, body, false)
    example_print_log("allowed_after", lurek.physics.isSleepingAllowed(world, body))
end

--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns

--@api: LBody:getHeight
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(32, 48)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    physics_log("character height=" .. body:getHeight() .. " width=" .. body:getWidth())
    physics_log("spawn pos=" .. select(1, body:getPosition()) .. "," .. select(2, body:getPosition()))
end

--@api: LBody:getId
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    world:setBodyData(body:getId(), { kind = "spawn_marker" })
    local data = world:getBodyData(body:getId())
    world:step(1 / 60)
    physics_log("body id=" .. body:getId() .. " kind=" .. data.kind)
    physics_log("spawn x=" .. body:getX() .. " y=" .. body:getY())
end

--@api: LBody:getPosition
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(14, -8)
    world:step(1 / 60)
    local x, y = body:getPosition()
    physics_log("patrol body id=" .. body:getId())
    physics_log("current position=" .. x .. "," .. y)
end

--@api: LBody:getWidth
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(48, 20)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    physics_log("bridge plank width=" .. body:getWidth())
    physics_log("bridge plank height=" .. body:getHeight())
end

--@api: LBody:getX
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(12, 0)
    world:step(1 / 60)
    local x = body:getX()
    local y = body:getY()
    physics_log("spawn marker x=" .. x)
    physics_log("paired y=" .. y)
end

--@api: LBody:getY
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(0, -10)
    world:step(1 / 60)
    local y = body:getY()
    local x = body:getX()
    physics_log("spawn marker y=" .. y)
    physics_log("paired x=" .. x)
end

--@api: LPhysicsShape:getBoundingBox
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setSensor(true)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    physics_log("shape type=" .. circle:getType())
end

--@api: LPhysicsShape:getRadius
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setDensity(1.5)
    local radius = circle:getRadius()
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("blast radius=" .. radius)
    physics_log("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:getType
do
    local circle = lurek.physics.newCircleShape(10.0)
    circle:setRestitution(0.2)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    physics_log("collider kind=" .. circle:getType())
    physics_log("preview bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LTerrain:fillAll
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end

--@api: LTerrain:fillCircle
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 256, 50, false)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end

--@api: LTerrain:flush
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:flush()
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end

--@api: LTerrain:isDirty
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    example_print_log("dirty", terrain:isDirty())
    example_print_log("type", terrain:type())
end

--@api: LTerrain:type
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillRect(32, 400, 96, 32, true)
    terrain:flush()
    physics_log("terrain userdata=" .. terrain:type())
    physics_log("terrain inheritance=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api: LTerrain:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(false)
    terrain:setCell(1, 1, true)
    local isTerrain = terrain:typeOf("LTerrain")
    local isObject = terrain:typeOf("LObject")
    physics_log("terrain check=" .. tostring(isTerrain) .. " object=" .. tostring(isObject))
    physics_log("terrain userdata=" .. terrain:type())
end

--@api: LWorld:addFixture
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    example_print_log("fixture", fid)
    example_print_log("count", world:fixtureCount(body:getId()))
end

--@api: LWorld:clearBeginContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    world:setBeginContact(function()
        count = count + 1
    end)
    world:clearBeginContact()
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    example_print_log("count", count)
end

--@api: LWorld:clearEndContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    world:setEndContact(function()
        count = count + 1
    end)
    world:clearEndContact()
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    example_print_log("count", count)
end

--@api: LWorld:destroyBody
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    example_print_log("before", world:getBodyCount())
    world:destroyBody(body:getId())
    example_print_log("after", world:getBodyCount())
end

--@api: LWorld:fixtureCount
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    world:addFixture(body:getId(), "rectangle", 1.0, 0.6, 0.1, false, 12.0, 4.0)
    world:step(1 / 60)
    physics_log("fixture count=" .. world:fixtureCount(body:getId()))
    physics_log("body type=" .. body:getType())
end

--@api: LWorld:setBodyType
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:setBodyType(body:getId(), "static")
    body:setPosition(32, 64)
    world:step(1 / 60)
    physics_log("builder converted type=" .. world:getBodyType(body:getId()))
    physics_log("placement=" .. body:getX() .. "," .. body:getY())
end

--@api: LWorld:setMouseJointTarget
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    example_print_log("joint", jid)
    example_print_log("type", world:getJointType(jid))
end

--@api: LZone:getId
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setGravityZero()
    local scout = world:newCircleBody(60, 60, 8, "dynamic")
    world:step(1 / 60)
    physics_log("zone id=" .. zone:getId() .. " type=" .. zone:type())
    physics_log("scout y=" .. select(2, scout:getPosition()))
end

--@api: LZone:setEnabled
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end

--@api: LZone:setLayerMask
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setLayerMask(0xFF)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end

--@api: LZone:setPriority
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(1)
    example_print_log("zone_id", zone:getId())
    example_print_log("type", zone:type())
end

--@api: LZone:type
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(2)
    zone:setGravityDirectional(0, -50)
    local probe = world:newCircleBody(40, 40, 8, "dynamic")
    physics_log("zone userdata=" .. zone:type())
    physics_log("zone check=" .. tostring(zone:typeOf("LZone")) .. " probe=" .. probe:getType())
end

--@api: LZone:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    local isZone = zone:typeOf("LZone")
    local isObject = zone:typeOf("LObject")
    local isWorld = zone:typeOf("LWorld")
    physics_log("zone checks zone=" .. tostring(isZone) .. " object=" .. tostring(isObject))
    physics_log("world check=" .. tostring(isWorld) .. " userdata=" .. zone:type())
end

--@api: lurek.physics.drawDebugGpu
do
    local world = lurek.physics.newWorld(0, 9.8)
    world:newBody(120, 200, "static")
    world:newCircleBody(120, 120, 10, "dynamic")
    lurek.physics.drawDebugGpu(world, {})
    world:step(1 / 60)
    physics_log("gpu debug scene bodies=" .. world:getBodyCount())
    physics_log("world type=" .. world:type())
end

--@api: lurek.physics.getBody
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    body:setVelocity(10, 5)
    world:step(1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    physics_log("free-function body pos=" .. x .. "," .. y)
    physics_log("free-function velocity=" .. vx .. "," .. vy)
end

--@api: lurek.physics.newBody
do
    local world = lurek.physics.newWorld(0, 0)
    local body = lurek.physics.newBody(world, 50, 50, "static")
    local checkpoint = lurek.physics.newBody(world, 80, 50, "sensor")
    world:step(1 / 60)
    physics_log("spawned wall id=" .. body:getId() .. " type=" .. body:getType())
    physics_log("checkpoint type=" .. checkpoint:getType() .. " bodies=" .. world:getBodyCount())
end

--@api: LChainShape:getType
do
    local chain = lurek.physics.newChainShape(false, 0, 0, 10, 0, 10, 10, 0, 10)
    chain:setFriction(0.5)
    local minX, minY, maxX, maxY = chain:getBoundingBox()
    physics_log("chain kind=" .. chain:getType())
    physics_log("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.setBodyVelocity
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    physics_log("dash velocity=" .. vx .. "," .. vy)
    physics_log("dash position=" .. body:getX() .. "," .. body:getY())
end

--@api: lurek.physics.setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    world:step(1 / 60)
    local allowed = body:isSleepingAllowed()
    local valid = body:isValid()
    physics_log("always-awake enemy allowed=" .. tostring(allowed))
    physics_log("body still valid=" .. tostring(valid))
end

--@api: lurek.physics.testPoint
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    local buttonHover = lurek.physics.testPoint(42, 18, 32, 8, 24, 24)
    local missHover = lurek.physics.testPoint(80, 18, 32, 8, 24, 24)
    physics_log("inside tile=" .. tostring(inside) .. " ui hover=" .. tostring(buttonHover))
    physics_log("outside tile=" .. tostring(outside) .. " hover miss=" .. tostring(missHover))
end

