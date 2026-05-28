-- content/examples/physics.lua
-- Auto-generated from content/examples2/physics_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/physics.lua

--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties

--@api-stub: lurek.physics.newWorld
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    print("type", world:type())
end

--@api-stub: LWorld:getGravity
do
    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    world:setGravity(10, 800)
    print("updated", world:getGravity())
end

--@api-stub: LWorld:setGravity
do
    local world = lurek.physics.newWorld(0, 200)
    world:setGravity(25, 600)
    local gx, gy = world:getGravity()
    print("gravity", gx, gy)
    print("body_count", world:getBodyCount())
end

--@api-stub: LWorld:step
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 12, "dynamic")
    world:step(1 / 60)
    print("position", body:getPosition())
    print("velocity", body:getVelocity())
end

--@api-stub: LWorld:stepFixed
do
    local world = lurek.physics.newWorld(0, 400)
    local remainder = world:stepFixed(0.025, 1 / 60, 4)
    print("remainder", remainder)
    print("iterations", world:getSolverIterations())
end

--@api-stub: LWorld:setMeter
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter", world:getMeter())
    print("physics", world:toPhysics(128))
end

--@api-stub: LWorld:getMeter
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meter", world:getMeter())
    print("pixels", world:toPixels(2.0))
end

--@api-stub: LWorld:toPhysics
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("meters", world:toPhysics(96))
    print("pixels", world:toPixels(1.5))
end

--@api-stub: LWorld:toPixels
do
    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    print("pixels", world:toPixels(2.5))
    print("meters", world:toPhysics(160))
end

--@api-stub: LWorld:setSolverIterations
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(8)
    print("solver_iterations", world:getSolverIterations())
end

--@api-stub: LWorld:getSolverIterations
do
    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(10)
    print("solver_iterations", world:getSolverIterations())
end

--@api-stub: LWorld:newBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    world:step(1 / 60)
    print("id", body:getId())
    print("type", body:getType())
    print("position", body:getPosition())
end

--@api-stub: LWorld:newCircleBody
do
    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 100, 16, "dynamic")
    print("position", ball:getPosition())
    print("size", ball:getWidth(), ball:getHeight())
end

--@api-stub: LWorld:kinematic
do
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(400, 580, "static")
    local platform = world:newBody(300, 400, "kinematic")
    local trigger = world:newBody(500, 300, "sensor")
    print("types", floor:getType(), platform:getType(), trigger:getType())
end

--@api-stub: LBody:setPosition
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    print("position", body:getPosition())
    print("velocity", body:getVelocity())
end

--@api-stub: LBody:setVelocity
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(50, -100)
    print("velocity", body:getVelocity())
    world:step(1 / 60)
    print("position", body:getPosition())
end

--@api-stub: LBody:getVelocity
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(25, -50)
    print("velocity", body:getVelocity())
    print("type", body:getType())
end

--@api-stub: LBody:setAngle
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    print("angle", body:getAngle())
    print("angular_velocity", body:getAngularVelocity())
end

--@api-stub: LBody:getAngle
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 6)
    print("angle", body:getAngle())
    print("position", body:getPosition())
end

--@api-stub: LBody:setAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(2.0)
    print("angular_velocity", body:getAngularVelocity())
    world:step(1 / 60)
    print("angle", body:getAngle())
end

--@api-stub: LBody:getAngularVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(1.25)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end

--@api-stub: LBody:getMass
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    print("mass", body:getMass())
    print("friction", body:getFriction())
    print("restitution", body:getRestitution())
end

--@api-stub: LBody:setMass
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(7.5)
    print("mass", body:getMass())
    print("type", body:getType())
end

--@api-stub: LBody:setFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.8)
    print("friction", body:getFriction())
    print("mass", body:getMass())
end

--@api-stub: LBody:getFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.25)
    print("friction", body:getFriction())
    print("restitution", body:getRestitution())
end

--@api-stub: LBody:setRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    print("restitution", body:getRestitution())
    print("mass", body:getMass())
end

--@api-stub: LBody:getRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.15)
    print("restitution", body:getRestitution())
    print("friction", body:getFriction())
end

--@api-stub: LBody:setLinearDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    print("linear_damping", body:getLinearDamping())
    print("angular_damping", body:getAngularDamping())
end

--@api-stub: LBody:getLinearDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.75)
    print("linear_damping", body:getLinearDamping())
    print("velocity", body:getVelocity())
end

--@api-stub: LBody:setAngularDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.3)
    print("angular_damping", body:getAngularDamping())
    print("angle", body:getAngle())
end

--@api-stub: LBody:getAngularDamping
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.9)
    print("angular_damping", body:getAngularDamping())
    print("linear_damping", body:getLinearDamping())
end

--@api-stub: LBody:setGravityScale
do
    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    floaty:setGravityScale(0.2)
    print("normal", normal:getGravityScale())
    print("floaty", floaty:getGravityScale())
end

--@api-stub: LBody:getGravityScale
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setGravityScale(-1.0)
    print("gravity_scale", body:getGravityScale())
    print("type", body:getType())
end

--@api-stub: LBody:applyForce
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("position", body:getPosition())
end

--@api-stub: LBody:applyForceAtPoint
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForceAtPoint(0, -50, 210, 200)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("angular_velocity", body:getAngularVelocity())
end

--@api-stub: LBody:applyImpulse
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyImpulse(0, -200)
    world:step(1 / 60)
    print("velocity", body:getVelocity())
    print("position", body:getPosition())
end

--@api-stub: LBody:applyAngularImpulse
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyAngularImpulse(5.0)
    world:step(1 / 60)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end

--@api-stub: LBody:applyTorque
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyTorque(10.0)
    world:step(1 / 60)
    print("angular_velocity", body:getAngularVelocity())
    print("angle", body:getAngle())
end

--@api-stub: LBody:setBullet
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is_bullet", bullet:isBullet())
    print("type", bullet:getType())
end

--@api-stub: LBody:isBullet
do
    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    print("is_bullet", bullet:isBullet())
    print("position", bullet:getPosition())
end

--@api-stub: LBody:setFixedRotation
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed_rotation", player:isFixedRotation())
    print("angle", player:getAngle())
end

--@api-stub: LBody:isFixedRotation
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    print("fixed_rotation", player:isFixedRotation())
    print("type", player:getType())
end

--@api-stub: LBody:setType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    print("type", body:getType())
    print("layer", body:getLayer())
end

--@api-stub: LBody:getType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "sensor")
    print("type", body:getType())
    print("id", body:getId())
end

--@api-stub: LBody:setLayer
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(2)
    print("layer", body:getLayer())
    print("mask", body:getMask())
end

--@api-stub: LBody:getLayer
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(4)
    print("layer", body:getLayer())
    print("type", body:getType())
end

--@api-stub: LBody:setMask
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(3)
    print("mask", body:getMask())
    print("layer", body:getLayer())
end

--@api-stub: LBody:getMask
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(7)
    print("mask", body:getMask())
    print("id", body:getId())
end

--@api-stub: LBody:sleep
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    print("sleeping", body:isSleeping())
    print("allowed", body:isSleepingAllowed())
end

--@api-stub: LBody:wakeUp
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    body:wakeUp()
    print("sleeping", body:isSleeping())
    print("allowed", body:isSleepingAllowed())
end

--@api-stub: LBody:isSleeping
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    print("sleeping", body:isSleeping())
    print("id", body:getId())
end

--@api-stub: LBody:setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(false)
    print("allowed", body:isSleepingAllowed())
    print("sleeping", body:isSleeping())
end

--@api-stub: LBody:isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    print("allowed", body:isSleepingAllowed())
    print("type", body:getType())
end

--@api-stub: LBody:destroy
do
    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    print("before", world:getBodyCount())
    temp:destroy()
    print("after", world:getBodyCount())
end

--@api-stub: LWorld:getBodyCount
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    print("body_count", world:getBodyCount())
end

--@api-stub: LBody:type
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type", body:type())
    print("type_of", body:typeOf("LBody"), body:typeOf("LObject"))
end

--@api-stub: LBody:typeOf
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    print("type_of", body:typeOf("LBody"), body:typeOf("LObject"))
    print("type", body:type())
end

--@api-stub: LWorld:type
do
    local world = lurek.physics.newWorld(0, 400)
    print("type", world:type())
    print("type_of", world:typeOf("LWorld"))
end

--@api-stub: LWorld:typeOf
do
    local world = lurek.physics.newWorld(0, 400)
    print("type_of", world:typeOf("LWorld"), world:typeOf("LObject"))
    print("type", world:type())
end

--- Physics Module Part 2: shapes, attachShape, fixtures, collision filtering

--@api-stub: lurek.physics.newCircleShape
do
    local circle = lurek.physics.newCircleShape(16)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    print("type", circle:getType())
    print("radius", circle:getRadius())
    print("bounds", minX, minY, maxX, maxY)
end

--@api-stub: lurek.physics.newRectangleShape
do
    local rect = lurek.physics.newRectangleShape(64, 32)
    local minX, minY, maxX, maxY = rect:getBoundingBox()
    print("type", rect:getType())
    print("bounds", minX, minY, maxX, maxY)
end

--@api-stub: lurek.physics.newPolygonShape
do
    local triangle = lurek.physics.newPolygonShape(0, -20, -15, 15, 15, 15)
    local minX, minY, maxX, maxY = triangle:getBoundingBox()
    print("type", triangle:getType())
    print("bounds", minX, minY, maxX, maxY)
end

--@api-stub: lurek.physics.newEdgeShape
do
    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    local minX, minY, maxX, maxY = edge:getBoundingBox()
    print("type", edge:getType())
    print("bounds", minX, minY, maxX, maxY)
end

--@api-stub: lurek.physics.newChainShape
do
    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100)
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100)
    print("open_type", chain:getType())
    print("closed_type", loop:getType())
end

--@api-stub: LPhysicsShape:setDensity
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end

--@api-stub: LPhysicsShape:setFriction
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end

--@api-stub: LPhysicsShape:setRestitution
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    print("type", shape:getType())
    print("radius", shape:getRadius())
end

--@api-stub: LPhysicsShape:setSensor
do
    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(true)
    print("type", shape:getType())
    print("bounds", shape:getBoundingBox())
end

--@api-stub: lurek.physics.attachShape
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    print("fixture_count", world:fixtureCount(body:getId()))
    print("position", body:getPosition())
end

--@api-stub: LWorld:setFixtureFriction
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end

--@api-stub: LWorld:setFixtureRestitution
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(body:getId(), fixture, 0.9)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end

--@api-stub: LWorld:setFixtureSensor
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(body:getId(), fixture, true)
    print("fixture", fixture)
    print("fixture_count", world:fixtureCount(body:getId()))
end

--@api-stub: LWorld:newPolygonBody
do
    local world = lurek.physics.newWorld(0, 400)
    local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic")
    print("position", tri:getPosition())
    print("type", tri:getType())
end

--@api-stub: LWorld:newEdgeBody
do
    local world = lurek.physics.newWorld(0, 400)
    local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static")
    print("position", wall:getPosition())
    print("type", wall:getType())
end

--@api-stub: LWorld:newChainBody
do
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static")
    print("position", ground:getPosition())
    print("type", ground:getType())
end

--@api-stub: LWorld:newBodies
do
    local world = lurek.physics.newWorld(0, 400)
    local ids = world:newBodies({
        { 15, 50, 12, 12, "dynamic" },
        { 30, 50, 12, 12, "dynamic" },
        { 45, 50, 12, 12, "static" },
    })
    print("created", #ids)
    print("body_count", world:getBodyCount())
end

--@api-stub: LWorld:getBodyIds
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    print("count", #ids)
    print("first", ids[1])
end

--@api-stub: LWorld:getBodyType
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    print("type", world:getBodyType(body:getId()))
    print("id", body:getId())
end

--@api-stub: LPhysicsShape:type
do
    local shape = lurek.physics.newCircleShape(10)
    print("type", shape:type())
end

--@api-stub: LPhysicsShape:typeOf
do
    local shape = lurek.physics.newCircleShape(10)
    print("type_of", shape:typeOf("LPhysicsShape"))
    print("type", shape:type())
end

--@api-stub: LPhysicsShape:destroy
do
    local shape = lurek.physics.newCircleShape(10)
    shape:destroy()
    print("type", shape:getType())
end

--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)

--@api-stub: LWorld:addRevoluteJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local pivot = world:newBody(200, 150, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addDistanceJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(bodyA:getId(), bodyB:getId(), 0, 0, 0, 0, 100)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addPrismaticJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(rail:getId(), slider:getId(), 300, 300, 1, 0)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addWeldJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addRopeJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addWheelJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(car:getId(), wheel:getId(), 200, 230, 0, 1)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addMouseJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    world:setMouseJointTarget(jointId, 400, 150)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addMotorJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addFrictionJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    local jointId = world:addFrictionJoint(ground:getId(), puck:getId(), 200, 400, 100, 50)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addGearJoint
do
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:addPulleyJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    print("joint_id", jointId)
    print("joint_type", world:getJointType(jointId))
end

--@api-stub: LWorld:getJointIds
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    print("count", #ids)
    print("first", ids[1])
end

--@api-stub: LWorld:jointCount
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint_count", world:jointCount())
end

--@api-stub: LWorld:getJointBodies
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("bodies", world:getJointBodies(jid))
end

--@api-stub: LWorld:getJointType
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joint_type", world:getJointType(jid))
end

--@api-stub: LWorld:setJointLimits
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("limits", world:getJointLimits(jid))
end

--@api-stub: LWorld:getJointLimits
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    print("limits", world:getJointLimits(jid))
end

--@api-stub: LWorld:setJointLimitsEnabled
do
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    print("limits", world:getJointLimits(jid))
end

--@api-stub: LWorld:setJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor_speed", world:getJointMotorSpeed(jid))
end

--@api-stub: LWorld:getJointMotorSpeed
do
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor_speed", world:getJointMotorSpeed(jid))
end

--@api-stub: LWorld:setJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    print("break_force", world:getJointBreakForce(jid))
end

--@api-stub: LWorld:getJointBreakForce
do
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    print("break_force", world:getJointBreakForce(jid))
end

--@api-stub: LWorld:destroyJoint
do
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("before", world:jointCount())
    world:destroyJoint(jid)
    print("after", world:jointCount())
end

--- Physics Module Part 4: raycasting, AABB queries, contacts, collision events

--@api-stub: LWorld:raycast
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "static")
    local hit = world:raycast(0, 200, 600, 200)
    if hit then
        print("body", hit.bodyId)
        print("point", hit.x, hit.y)
        print("normal", hit.normalX, hit.normalY)
    else
        print("body", nil)
    end
end

--@api-stub: LWorld:raycastClosest
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 300, 15, "static")
    local hit = world:raycastClosest(200, 100, 0, 1, 500)
    if hit then
        print("body", hit.bodyId)
        print("point", hit.x, hit.y)
        print("toi", hit.toi)
    else
        print("body", nil)
    end
end

--@api-stub: LWorld:raycastAll
do
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        world:newCircleBody(100 + i * 80, 200, 10, "static")
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600)
    print("count", #hits)
    if hits[1] then
        print("first", hits[1].bodyId, hits[1].x, hits[1].y)
    end
end

--@api-stub: LWorld:queryAABB
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(150, 120, 10, "dynamic")
    world:newCircleBody(500, 500, 10, "dynamic")
    local found = world:queryAABB(50, 50, 200, 200)
    print("count", #found)
    print("first", found[1])
end

--@api-stub: LWorld:getBodyAtPoint
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 30, "static")
    local hitId = world:getBodyAtPoint(210, 205)
    local missId = world:getBodyAtPoint(0, 0)
    print("hit", hitId)
    print("miss", missId)
end

--@api-stub: LWorld:getContacts
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    print("count", #contacts)
    print("ball", ball:getId())
end

--@api-stub: LWorld:getBeginContactEvents
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
    print("count", count)
end

--@api-stub: LWorld:getEndContactEvents
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
    print("count", count)
end

--@api-stub: LWorld:getCollisionEvents
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
    print("count", count)
end

--@api-stub: LWorld:setBeginContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        print("callback", bodyA, bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("count", contactCount)
end

--@api-stub: LWorld:setEndContact
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
        print("callback", bodyA, bodyB)
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("count", endCount)
end

--@api-stub: LWorld:getBodyContacts
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    print("count", #contacts)
    if contacts[1] then
        print("first", contacts[1].bodyA, contacts[1].bodyB)
    end
end

--@api-stub: lurek.physics.testAABB
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    local miss = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    print("overlap", overlap)
    print("miss", miss)
end

--@api-stub: lurek.physics.testCircleAABB
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    print("hit", hit)
    print("miss", miss)
end

--@api-stub: lurek.physics.testCircles
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    print("touching", touching)
    print("apart", apart)
end

--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced

--@api-stub: LWorld:addZone
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    zone:setPriority(10)
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LZone:setGravityDirectional
do
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end

--@api-stub: LZone:setGravityPoint
do
    local world = lurek.physics.newWorld(0, 400)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(450, 220, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end

--@api-stub: LZone:setGravityRepulsor
do
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local ball = world:newCircleBody(240, 240, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end

--@api-stub: LZone:setGravityZero
do
    local world = lurek.physics.newWorld(0, 400)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("position", ball:getPosition())
    print("velocity", ball:getVelocity())
end

--@api-stub: LZone:setLinearDampingOverride
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("velocity", diver:getVelocity())
    print("position", diver:getPosition())
end

--@api-stub: LZone:setAngularDampingOverride
do
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setAngularDampingOverride(2.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setAngularVelocity(5)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("angular_velocity", diver:getAngularVelocity())
    print("angle", diver:getAngle())
end

--@api-stub: LZone:setCircle
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LWorld:getZoneEvents
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
    print("count", count)
end

--@api-stub: LZone:destroy
do
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(0, 0, 100, 100)
    print("zone_id", zone:getId())
    zone:destroy()
    print("events", #world:getZoneEvents())
end

--@api-stub: lurek.physics.newCellular
do
    local grid = lurek.physics.newCellular(64, 64)
    grid:setCell(32, 0, lurek.physics.CELL_SAND)
    grid:step()
    print("cell", grid:getCell(32, 1))
    print("type", grid:type())
end

--@api-stub: LCellular:fillRect
do
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillRect(10, 10, 20, 5, lurek.physics.CELL_WATER)
    print("water", grid:countCells(lurek.physics.CELL_WATER))
    print("type", grid:type())
end

--@api-stub: LCellular:fillCircle
do
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillCircle(64, 64, 15, lurek.physics.CELL_FIRE)
    print("fire", grid:countCells(lurek.physics.CELL_FIRE))
    print("type", grid:type())
end

--@api-stub: LCellular:stepN
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, lurek.physics.CELL_SAND)
    grid:stepN(10)
    print("sand", grid:countCells(lurek.physics.CELL_SAND))
    print("type", grid:type())
end

--@api-stub: LCellular:findCells
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, lurek.physics.CELL_SAND)
    local positions = grid:findCells(lurek.physics.CELL_SAND)
    print("count", #positions)
    if positions[1] then
        print("first", positions[1].x, positions[1].y)
    end
end

--@api-stub: LCellular:toImageData
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local pixels = grid:toImageData()
    print("bytes", #pixels)
    print("count", grid:countCells(lurek.physics.CELL_SAND))
end

--@api-stub: LCellular:toBytes
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local bytes = grid:toBytes()
    print("bytes", #bytes)
    print("type", grid:type())
end

--@api-stub: LCellular:loadFromBytes
do
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, lurek.physics.CELL_SAND)
    local bytes = grid:toBytes()
    local clone = lurek.physics.newCellular(32, 32)
    print("loaded", clone:loadFromBytes(bytes))
    print("cell", clone:getCell(16, 16))
end

--@api-stub: lurek.physics.newTerrain
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 128, 40, false)
    terrain:flush()
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end

--@api-stub: LTerrain:setCell
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    print("cell", terrain:getCell(5, 5))
    print("dirty", terrain:isDirty())
end

--@api-stub: LTerrain:getCell
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    print("cell", terrain:getCell(5, 5))
    print("type", terrain:type())
end

--@api-stub: LTerrain:fillRect
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillRect(80, 80, 40, 40, false)
    print("dirty", terrain:isDirty())
    print("cell", terrain:getCell(10, 10))
end

--@api-stub: LTerrain:collapseColumns
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    print("collapsed", terrain:collapseColumns())
    print("dirty", terrain:isDirty())
end

--@api-stub: LTerrain:solidPositions
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    print("count", #solids)
    if solids[1] then
        print("first", solids[1].x, solids[1].y)
    end
end

--@api-stub: LTerrain:spawnDebris
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:flush()
    local debris = terrain:spawnDebris({ { x = 64, y = 64 }, { x = 72, y = 64 } }, 1.0, 0.2)
    print("count", #debris)
    print("body_count", world:getBodyCount())
end

--@api-stub: LTerrain:toBytes
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local bytes = terrain:toBytes()
    print("bytes", #bytes)
    print("dirty", terrain:isDirty())
end

--@api-stub: LTerrain:loadFromBytes
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local bytes = terrain:toBytes()
    local clone = lurek.physics.newTerrain(32, 32, 4, world)
    print("loaded", clone:loadFromBytes(bytes))
    print("cell", clone:getCell(0, 0))
end

--@api-stub: LTerrain:toImageData
do
    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local pixels = terrain:toImageData(255, 255, 255, 0, 0, 0)
    print("bytes", #pixels)
    print("type", terrain:type())
end

--@api-stub: LWorld:setBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    local data = world:getBodyData(player:getId())
    print("tag", data.tag)
    print("hp", data.hp)
end

--@api-stub: LWorld:getBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local data = world:getBodyData(enemy:getId())
    print("tag", data.tag)
    print("hp", data.hp)
end

--@api-stub: LWorld:clearBodyData
do
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player" })
    world:clearBodyData(player:getId())
    print("data", world:getBodyData(player:getId()))
end

--@api-stub: LWorld:setBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    print("normal", world:getBodyOneWay(platform:getId()))
end

--@api-stub: LWorld:getBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    print("normal", world:getBodyOneWay(platform:getId()))
end

--@api-stub: LWorld:clearBodyOneWay
do
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    world:clearBodyOneWay(platform:getId())
    print("normal", world:getBodyOneWay(platform:getId()))
end

--@api-stub: LWorld:setBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("ccd", world:getBodyCCD(bullet:getId()))
    print("id", bullet:getId())
end

--@api-stub: LWorld:getBodyCCD
do
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("ccd", world:getBodyCCD(bullet:getId()))
    print("velocity", bullet:getVelocity())
end

--@api-stub: LWorld:sleepBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end

--@api-stub: LWorld:wakeUpBody
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    world:wakeUpBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end

--@api-stub: LWorld:isBodySleeping
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    print("sleeping", world:isBodySleeping(body:getId()))
end

--@api-stub: LWorld:drawDebug
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    local img = lurek.image.newImageData(800, 600)
    local ok, err = pcall(function() world:drawDebug(img, 0, 255, 0, 200) end)
    if ok then print("image", img:type()) else print("drawDebug skipped: " .. tostring(err)) end
end

--@api-stub: lurek.physics.debugDraw
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    lurek.physics.drawDebugGpu(world, { lineWidth = 2 })
    print("body_count", world:getBodyCount())
end

--@api-stub: lurek.physics.destroyWorld
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    print("before", world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("after", world:getBodyCount())
end

--@api-stub: LWorld:clear
do
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    print("before", world:getBodyCount())
    world:clear()
    print("after", world:getBodyCount())
end

--@api-stub: lurek.physics.step
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.step(world, 1 / 60)
    print("body", lurek.physics.getBody(world, body))
end

--@api-stub: lurek.physics.getCollisions
do
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    print("count", #collisions)
    if collisions[1] then
        print("first", collisions[1].body_a, collisions[1].body_b)
    end
end

--@api-stub: lurek.physics.isSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    print("allowed", lurek.physics.isSleepingAllowed(world, body))
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed_after", lurek.physics.isSleepingAllowed(world, body))
end

--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns

--@api-stub: LBody:getHeight
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("position", body:getPosition())
    print("size", body:getWidth(), body:getHeight())
end

--@api-stub: LBody:getId
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("id", body:getId())
    print("position", body:getPosition())
end

--@api-stub: LBody:getPosition
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("position", body:getPosition())
    print("id", body:getId())
end

--@api-stub: LBody:getWidth
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("width", body:getWidth())
    print("height", body:getHeight())
end

--@api-stub: LBody:getX
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("x", body:getX())
    print("y", body:getY())
end

--@api-stub: LBody:getY
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    print("y", body:getY())
    print("x", body:getX())
end

--@api-stub: LCellular:countCells
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("count", ca:countCells(lurek.physics.CELL_SAND))
    print("type", ca:type())
end

--@api-stub: LCellular:getCell
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("cell", ca:getCell(5, 5))
    print("count", ca:countCells(lurek.physics.CELL_SAND))
end

--@api-stub: LCellular:setCell
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    print("cell", ca:getCell(5, 5))
    print("type", ca:type())
end

--@api-stub: LCellular:step
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    ca:step()
    print("count", ca:countCells(lurek.physics.CELL_SAND))
    print("type", ca:type())
end

--@api-stub: LCellular:toImageDataRegion
do
    local ca = lurek.physics.newCellular(32, 32)
    ca:setCell(5, 5, lurek.physics.CELL_SAND)
    local img = ca:toImageDataRegion(0, 0, 32, 32)
    print("bytes", #img)
    print("type", ca:type())
end

--@api-stub: LCellular:type
do
    local ca = lurek.physics.newCellular(32, 32)
    print("type", ca:type())
    print("type_of", ca:typeOf("LCellular"))
end

--@api-stub: LCellular:typeOf
do
    local ca = lurek.physics.newCellular(32, 32)
    print("type_of", ca:typeOf("LCellular"), ca:typeOf("LObject"))
    print("type", ca:type())
end

--@api-stub: LPhysicsShape:getBoundingBox
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("bounds", circle:getBoundingBox())
    print("type", circle:getType())
end

--@api-stub: LPhysicsShape:getRadius
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("radius", circle:getRadius())
    print("type", circle:getType())
end

--@api-stub: LPhysicsShape:getType
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("type", circle:getType())
    print("bounds", circle:getBoundingBox())
end

--@api-stub: LTerrain:fillAll
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end

--@api-stub: LTerrain:fillCircle
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 256, 50, false)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end

--@api-stub: LTerrain:flush
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:flush()
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end

--@api-stub: LTerrain:isDirty
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    print("dirty", terrain:isDirty())
    print("type", terrain:type())
end

--@api-stub: LTerrain:type
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    print("type", terrain:type())
    print("type_of", terrain:typeOf("LTerrain"))
end

--@api-stub: LTerrain:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    print("type_of", terrain:typeOf("LTerrain"), terrain:typeOf("LObject"))
    print("type", terrain:type())
end

--@api-stub: LWorld:addFixture
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("fixture", fid)
    print("count", world:fixtureCount(body:getId()))
end

--@api-stub: LWorld:clearBeginContact
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
    print("count", count)
end

--@api-stub: LWorld:clearEndContact
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
    print("count", count)
end

--@api-stub: LWorld:destroyBody
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    print("before", world:getBodyCount())
    world:destroyBody(body:getId())
    print("after", world:getBodyCount())
end

--@api-stub: LWorld:fixtureCount
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    print("count", world:fixtureCount(body:getId()))
end

--@api-stub: LWorld:setBodyType
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:setBodyType(body:getId(), "static")
    print("type", world:getBodyType(body:getId()))
end

--@api-stub: LWorld:setMouseJointTarget
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    print("joint", jid)
    print("type", world:getJointType(jid))
end

--@api-stub: LZone:getId
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LZone:setEnabled
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LZone:setLayerMask
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setLayerMask(0xFF)
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LZone:setPriority
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(1)
    print("zone_id", zone:getId())
    print("type", zone:type())
end

--@api-stub: LZone:type
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("type", zone:type())
    print("type_of", zone:typeOf("LZone"))
end

--@api-stub: LZone:typeOf
do
    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    print("type_of", zone:typeOf("LZone"), zone:typeOf("LObject"))
    print("type", zone:type())
end

--@api-stub: lurek.physics.drawDebugGpu
do
    local world = lurek.physics.newWorld(0, 9.8)
    lurek.physics.drawDebugGpu(world, {})
    print("body_count", world:getBodyCount())
end

--@api-stub: lurek.physics.getBody
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    body:setVelocity(10, 5)
    print("body", lurek.physics.getBody(world, body))
end

--@api-stub: lurek.physics.newBody
do
    local world = lurek.physics.newWorld(0, 0)
    local body = lurek.physics.newBody(world, 50, 50, "static")
    print("id", body:getId())
    print("type", body:getType())
end

--@api-stub: LChainShape:getType
do
    local chain = lurek.physics.newChainShape(false, 0, 0, 10, 0, 10, 10, 0, 10)
    print("type", chain:getType())
end

--@api-stub: lurek.physics.setBodyVelocity
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    print("velocity", body:getVelocity())
end

--@api-stub: lurek.physics.setSleepingAllowed
do
    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed", body:isSleepingAllowed())
end

--@api-stub: lurek.physics.testPoint
do
    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    print("inside", inside)
    print("outside", outside)
end

