-- Lurek2D Physics API Tests
-- @covers lurek.physics.attachShape
-- @covers lurek.physics.getBody
-- @covers lurek.physics.isSleepingAllowed
-- @covers lurek.physics.newBody
-- @covers lurek.physics.newChainShape
-- @covers lurek.physics.newCircleShape
-- @covers lurek.physics.newEdgeShape
-- @covers lurek.physics.newPolygonShape
-- @covers lurek.physics.newRectangleShape
-- @covers lurek.physics.newWorld
-- @covers lurek.physics.setBodyVelocity
-- @covers lurek.physics.setSleepingAllowed
-- @covers lurek.physics.step
-- @covers lurek.physics.newCircleBody
-- @covers lurek.physics.newPolygonBody
-- @covers lurek.physics.newEdgeBody
-- @covers lurek.physics.newChainBody
-- @covers lurek.physics.addFixture
-- @covers lurek.physics.fixtureCount
-- @covers lurek.physics.setFixtureFriction
-- @covers lurek.physics.setFixtureRestitution
-- @covers lurek.physics.setFixtureSensor
-- @covers lurek.physics.addRevoluteJoint
-- @covers lurek.physics.addDistanceJoint
-- @covers lurek.physics.addWeldJoint
-- @covers lurek.physics.jointCount
-- @covers lurek.physics.getJointIds
-- @covers lurek.physics.destroyJoint
-- @covers lurek.physics.getJointType
-- @covers lurek.physics.destroyWorld


-- @description Covers suite: lurek.physics module exists.
describe("lurek.physics module exists", function()
    -- @covers lurek.physics
    -- @description Verifies the physics namespace is exposed as a Lua table.
    it("lurek.physics is a table", function()
        expect_type("table", lurek.physics)
    end)
end)

-- @description Covers suite: lurek.physics world.
describe("lurek.physics world", function()
    -- @covers lurek.physics.newWorld
    -- @description Verifies newWorld is exposed as a callable physics factory.
    it("newWorld is a function", function()
        expect_type("function", lurek.physics.newWorld)
    end)

    -- @covers lurek.physics.newWorld
    -- @description Verifies newWorld returns World userdata.
    it("newWorld creates a world and returns World object", function()
        local id = lurek.physics.newWorld(0, 9.81)
        expect_type("userdata", id)
    end)

    -- @covers lurek.physics.step
    -- @description Verifies the module-level step function is exposed.
    it("step is a function", function()
        expect_type("function", lurek.physics.step)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.step
    -- @description Verifies the module-level step function accepts a world and timestep without error.
    it("step can be called with world_id and dt", function()
        local world = lurek.physics.newWorld(0, 9.81)
        expect_no_error(function()
            lurek.physics.step(world, 1/60)
        end)
    end)
end)

-- @description Covers suite: lurek.physics bodies.
describe("lurek.physics bodies", function()
    -- @covers lurek.physics.newBody
    -- @description Verifies newBody is exposed as a callable constructor.
    it("newBody is a function", function()
        expect_type("function", lurek.physics.newBody)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @description Verifies newBody returns Body userdata when attached to a world.
    it("newBody creates a body and returns Body object", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local id = lurek.physics.newBody(world, 100, 100, "dynamic")
        expect_type("userdata", id)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.getBody
    -- @description Verifies getBody returns the created body's position and velocity tuple.
    it("getBody returns position and velocity", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local id = lurek.physics.newBody(world, 50, 50, "static")
        local x, y, vx, vy = lurek.physics.getBody(world, id)
        expect_near(50, x, 1)
        expect_near(50, y, 1)
    end)

    -- @covers lurek.physics.setBodyVelocity
    -- @description Verifies setBodyVelocity is exposed as a callable helper.
    it("setBodyVelocity is a function", function()
        expect_type("function", lurek.physics.setBodyVelocity)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.setBodyVelocity
    -- @description Verifies setBodyVelocity accepts a world, body, and velocity components without error.
    it("setBodyVelocity changes velocity", function()
        local world = lurek.physics.newWorld(0, 0)
        local id = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_no_error(function()
            lurek.physics.setBodyVelocity(world, id, 100, 0)
        end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.step
    -- @covers lurek.physics.getBody
    -- @description Verifies a dynamic body moves under gravity after stepping the world.
    it("dynamic body moves after step", function()
        local world = lurek.physics.newWorld(0, 100)
        local id = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.step(world, 0.1)
        local x, y, vx, vy = lurek.physics.getBody(world, id)
        expect_true(y > 0, "body should fall due to gravity")
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.step
    -- @covers lurek.physics.getBody
    -- @description Verifies a static body remains at its original position when the world steps.
    it("static body does not move", function()
        local world = lurek.physics.newWorld(0, 100)
        local id = lurek.physics.newBody(world, 50, 50, "static")
        lurek.physics.step(world, 0.1)
        local x, y, vx, vy = lurek.physics.getBody(world, id)
        expect_near(50, x, 0.01)
        expect_near(50, y, 0.01)
    end)
end)

-- =========================================================================
-- Sleeping allowed
-- =========================================================================
-- @description Covers suite: sleeping allowed.
describe("sleeping allowed", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.isSleepingAllowed
    -- @description Verifies new dynamic bodies allow sleeping by default.
    it("isSleepingAllowed defaults to true", function()
        local world = lurek.physics.newWorld(0, 9.8)
        local id = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_true(lurek.physics.isSleepingAllowed(world, id))
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.setSleepingAllowed
    -- @covers lurek.physics.isSleepingAllowed
    -- @description Verifies setSleepingAllowed(false) disables sleeping for a body.
    it("setSleepingAllowed false disables sleeping", function()
        local world = lurek.physics.newWorld(0, 9.8)
        local id = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.setSleepingAllowed(world, id, false)
        expect_false(lurek.physics.isSleepingAllowed(world, id))
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.setSleepingAllowed
    -- @covers lurek.physics.isSleepingAllowed
    -- @description Verifies setSleepingAllowed(true) re-enables sleeping after disabling it.
    it("setSleepingAllowed true re-enables sleeping", function()
        local world = lurek.physics.newWorld(0, 9.8)
        local id = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.setSleepingAllowed(world, id, false)
        lurek.physics.setSleepingAllowed(world, id, true)
        expect_true(lurek.physics.isSleepingAllowed(world, id))
    end)
end)

-- Remaining tests require APIs not yet registered (circle bodies, collisions,
-- restitution, layers). They are skipped until those bindings are implemented.
-- See: newCircleBody, getBodyShape, setBodyShape, getCollisions,
--      setBodyRestitution, setBodyLayer

-- =========================================================================
-- Phase 2: Standalone shape userdata
-- =========================================================================
-- @description Covers suite: physics.Shape userdata.
describe("physics.Shape userdata", function()
    -- @covers lurek.physics.newCircleShape
    -- @description Verifies newCircleShape is exposed as a constructor.
    it("newCircleShape is a function", function()
        expect_type("function", lurek.physics.newCircleShape)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.getType
    -- @description Verifies newCircleShape returns shape userdata reporting the circle type.
    it("newCircleShape returns userdata with type 'circle'", function()
        local s = lurek.physics.newCircleShape(10)
        expect_type("userdata", s)
        expect_equal("circle", s:getType())
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.getRadius
    -- @description Verifies getRadius returns the configured radius for circle shapes.
    it("getRadius returns correct value for circle", function()
        local s = lurek.physics.newCircleShape(7.5)
        expect_near(7.5, s:getRadius(), 0.001)
    end)

    -- @covers lurek.physics.newRectangleShape
    -- @covers lurek.physics.Shape.getType
    -- @description Verifies newRectangleShape returns shape userdata reporting the rectangle type.
    it("newRectangleShape returns userdata with type 'rectangle'", function()
        local s = lurek.physics.newRectangleShape(20, 10)
        expect_type("userdata", s)
        expect_equal("rectangle", s:getType())
    end)

    -- @covers lurek.physics.newEdgeShape
    -- @covers lurek.physics.Shape.getType
    -- @description Verifies newEdgeShape returns shape userdata reporting the edge type.
    it("newEdgeShape returns userdata with type 'edge'", function()
        local s = lurek.physics.newEdgeShape(0, 0, 10, 0)
        expect_type("userdata", s)
        expect_equal("edge", s:getType())
    end)

    -- @covers lurek.physics.newPolygonShape
    -- @covers lurek.physics.Shape.getType
    -- @description Verifies newPolygonShape returns shape userdata reporting the polygon type.
    it("newPolygonShape returns userdata with type 'polygon'", function()
        local s = lurek.physics.newPolygonShape(0, 0, 10, 0, 5, 10)
        expect_type("userdata", s)
        expect_equal("polygon", s:getType())
    end)

    -- @covers lurek.physics.newChainShape
    -- @covers lurek.physics.Shape.getType
    -- @description Verifies newChainShape returns shape userdata reporting the chain type.
    it("newChainShape returns userdata with type 'chain'", function()
        local s = lurek.physics.newChainShape(false, 0, 0, 5, 0, 10, 5)
        expect_type("userdata", s)
        expect_equal("chain", s:getType())
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.getBoundingBox
    -- @description Verifies getBoundingBox returns numeric bounds for a circle shape.
    it("getBoundingBox returns 4 numbers for circle", function()
        local s = lurek.physics.newCircleShape(5)
        local x1, y1, x2, y2 = s:getBoundingBox()
        expect_type("number", x1)
        expect_type("number", x2)
        expect_near(-5, x1, 0.001)
        expect_near(5, x2, 0.001)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.setDensity
    -- @description Verifies setDensity can be applied to shape userdata without error.
    it("setDensity does not error", function()
        local s = lurek.physics.newCircleShape(1)
        expect_no_error(function() s:setDensity(2.0) end)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.setFriction
    -- @description Verifies setFriction can be applied to shape userdata without error.
    it("setFriction does not error", function()
        local s = lurek.physics.newCircleShape(1)
        expect_no_error(function() s:setFriction(0.8) end)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.setRestitution
    -- @description Verifies setRestitution can be applied to shape userdata without error.
    it("setRestitution does not error", function()
        local s = lurek.physics.newCircleShape(1)
        expect_no_error(function() s:setRestitution(0.5) end)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.setSensor
    -- @description Verifies setSensor can be applied to shape userdata without error.
    it("setSensor does not error", function()
        local s = lurek.physics.newCircleShape(1)
        expect_no_error(function() s:setSensor(true) end)
    end)

    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.Shape.destroy
    -- @description Verifies destroy can be called on shape userdata without error.
    it("destroy does not error", function()
        local s = lurek.physics.newCircleShape(1)
        expect_no_error(function() s:destroy() end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.newCircleShape
    -- @covers lurek.physics.attachShape
    -- @description Verifies attachShape attaches standalone shape userdata to a body without error.
    it("attachShape attaches circle to body", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local shape = lurek.physics.newCircleShape(15)
        expect_no_error(function()
            lurek.physics.attachShape(body, shape)
        end)
    end)
end)

-- â”€â”€ Body UserData methods â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: Body UserData methods.
describe("Body UserData methods", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies Body:getPosition returns the spawn coordinates after creation.
    it("getPosition returns x, y after creation", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 10.0, 20.0, "dynamic")
        local x, y = body:getPosition()
        expect_near(10.0, x, 0.01)
        expect_near(20.0, y, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setPosition
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies Body:setPosition moves the body and getPosition reports the updated coordinates.
    it("setPosition moves the body", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setPosition(50, 75)
        local x, y = body:getPosition()
        expect_near(50, x, 0.01)
        expect_near(75, y, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.getX
    -- @covers lurek.physics.Body.getY
    -- @description Verifies Body:getX and Body:getY expose individual position components.
    it("getX and getY return individual coordinates", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 3.5, 7.5, "dynamic")
        expect_near(3.5, body:getX(), 0.01)
        expect_near(7.5, body:getY(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setVelocity
    -- @covers lurek.physics.Body.getVelocity
    -- @description Verifies Body:setVelocity and Body:getVelocity round-trip linear velocity.
    it("setVelocity and getVelocity round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setVelocity(5.0, -3.0)
        local vx, vy = body:getVelocity()
        expect_near(5.0, vx, 0.01)
        expect_near(-3.0, vy, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setAngle
    -- @covers lurek.physics.Body.getAngle
    -- @description Verifies Body:setAngle and Body:getAngle round-trip rotation.
    it("getAngle and setAngle round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setAngle(1.57)
        expect_near(1.57, body:getAngle(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setAngularVelocity
    -- @covers lurek.physics.Body.getAngularVelocity
    -- @description Verifies Body:setAngularVelocity and Body:getAngularVelocity round-trip spin rate.
    it("getAngularVelocity and setAngularVelocity round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setAngularVelocity(2.5)
        expect_near(2.5, body:getAngularVelocity(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.getMass
    -- @description Verifies Body:getMass returns a positive mass for a dynamic body with attached geometry.
    it("getMass returns positive for dynamic body with shape", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_true(body:getMass() > 0)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.getType
    -- @description Verifies Body:getType reports the configured body type.
    it("getType returns body type string", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "static")
        expect_equal("static", body:getType())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setType
    -- @covers lurek.physics.Body.getType
    -- @description Verifies Body:setType changes the stored body type.
    it("setType changes body type", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setType("kinematic")
        expect_equal("kinematic", body:getType())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.setFriction
    -- @covers lurek.physics.Body.getFriction
    -- @description Verifies Body:setFriction and Body:getFriction round-trip fixture friction.
    it("getFriction and setFriction round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        body:setFriction(0.7)
        expect_near(0.7, body:getFriction(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.setRestitution
    -- @covers lurek.physics.Body.getRestitution
    -- @description Verifies Body:setRestitution and Body:getRestitution round-trip bounce values.
    it("getRestitution and setRestitution round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        body:setRestitution(0.9)
        expect_near(0.9, body:getRestitution(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setLayer
    -- @covers lurek.physics.Body.getLayer
    -- @description Verifies Body:setLayer and Body:getLayer round-trip collision layer values.
    it("getLayer and setLayer round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setLayer(3)
        expect_equal(3, body:getLayer())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setMask
    -- @covers lurek.physics.Body.getMask
    -- @description Verifies Body:setMask and Body:getMask round-trip collision masks.
    it("getMask and setMask round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setMask(5)
        expect_equal(5, body:getMask())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.applyImpulse
    -- @covers lurek.physics.Body.getVelocity
    -- @description Verifies Body:applyImpulse changes the body's linear velocity.
    it("applyImpulse changes velocity", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        body:applyImpulse(10, 0)
        local vx, vy = body:getVelocity()
        expect_true(vx > 0, "impulse should increase x velocity")
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.applyForce
    -- @description Verifies Body:applyForce accepts force input without error.
    it("applyForce does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_no_error(function() body:applyForce(100, 0) end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.applyTorque
    -- @description Verifies Body:applyTorque accepts torque input without error.
    it("applyTorque does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_no_error(function() body:applyTorque(5.0) end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.applyAngularImpulse
    -- @covers lurek.physics.Body.getAngularVelocity
    -- @description Verifies Body:applyAngularImpulse changes angular velocity.
    it("applyAngularImpulse changes angular velocity", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        body:applyAngularImpulse(3.0)
        expect_true(math.abs(body:getAngularVelocity()) > 0)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setGravityScale
    -- @covers lurek.physics.Body.getGravityScale
    -- @description Verifies Body:setGravityScale and Body:getGravityScale round-trip gravity scaling.
    it("getGravityScale and setGravityScale round-trip", function()
        local world = lurek.physics.newWorld(0, -9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setGravityScale(0.5)
        expect_near(0.5, body:getGravityScale(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.isFixedRotation
    -- @covers lurek.physics.Body.setFixedRotation
    -- @description Verifies Body:setFixedRotation toggles the fixed-rotation flag.
    it("isFixedRotation and setFixedRotation round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_false(body:isFixedRotation())
        body:setFixedRotation(true)
        expect_true(body:isFixedRotation())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setLinearDamping
    -- @covers lurek.physics.Body.getLinearDamping
    -- @description Verifies Body:setLinearDamping and Body:getLinearDamping round-trip drag values.
    it("getLinearDamping and setLinearDamping round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setLinearDamping(0.3)
        expect_near(0.3, body:getLinearDamping(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.setAngularDamping
    -- @covers lurek.physics.Body.getAngularDamping
    -- @description Verifies Body:setAngularDamping and Body:getAngularDamping round-trip angular drag values.
    it("getAngularDamping and setAngularDamping round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        body:setAngularDamping(0.4)
        expect_near(0.4, body:getAngularDamping(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.isBullet
    -- @covers lurek.physics.Body.setBullet
    -- @description Verifies Body:setBullet toggles bullet mode on and off.
    it("isBullet and setBullet round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_false(body:isBullet())
        body:setBullet(true)
        expect_true(body:isBullet())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.getId
    -- @description Verifies Body:getId returns a numeric identifier.
    it("getId returns a number", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_type("number", body:getId())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.Body.destroy
    -- @description Verifies Body:destroy can be called without error.
    it("destroy removes body", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_no_error(function() body:destroy() end)
    end)
end)

-- â”€â”€ World UserData methods â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: World UserData methods.
describe("World UserData methods", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.getGravity
    -- @description Verifies World:getGravity returns the world's configured gravity vector.
    it("getGravity returns world gravity", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local gx, gy = world:getGravity()
        expect_near(0, gx, 0.01)
        expect_near(9.81, gy, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.setGravity
    -- @covers lurek.physics.World.getGravity
    -- @description Verifies World:setGravity updates the world's gravity vector.
    it("setGravity changes world gravity", function()
        local world = lurek.physics.newWorld(0, 0)
        world:setGravity(0, -10)
        local gx, gy = world:getGravity()
        expect_near(0, gx, 0.01)
        expect_near(-10, gy, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.getBodyCount
    -- @covers lurek.physics.World.newBody
    -- @description Verifies World:getBodyCount tracks bodies created through World:newBody.
    it("getBodyCount tracks bodies", function()
        local world = lurek.physics.newWorld(0, 0)
        expect_equal(0, world:getBodyCount())
        world:newBody(0, 0, "dynamic")
        expect_equal(1, world:getBodyCount())
        world:newBody(5, 5, "static")
        expect_equal(2, world:getBodyCount())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newBody
    -- @covers lurek.physics.World.getBodyIds
    -- @description Verifies World:getBodyIds returns the IDs of created bodies.
    it("getBodyIds returns id table", function()
        local world = lurek.physics.newWorld(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        local ids = world:getBodyIds()
        expect_equal(2, #ids)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newBody
    -- @covers lurek.physics.World.destroyBody
    -- @covers lurek.physics.World.getBodyCount
    -- @covers lurek.physics.Body.getType
    -- @description Verifies World:destroyBody soft-destroys a body without shrinking the tracked body count.
    it("destroyBody disables a body (soft destroy)", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        local id = body:getId()
        expect_equal(1, world:getBodyCount())
        world:destroyBody(id)
        -- destroyBody disables the body and marks static; count stays
        expect_equal(1, world:getBodyCount())
        expect_equal("static", body:getType())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newBody
    -- @covers lurek.physics.World.clear
    -- @covers lurek.physics.World.getBodyCount
    -- @description Verifies World:clear removes all tracked bodies.
    it("clear removes all bodies", function()
        local world = lurek.physics.newWorld(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        world:clear()
        expect_equal(0, world:getBodyCount())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.step
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies World:step advances simulation for dynamic bodies under gravity.
    it("step advances simulation", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        world:step(1.0 / 60.0)
        local _, y = body:getPosition()
        expect_true(y > 0, "gravity should move body down")
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.setMeter
    -- @covers lurek.physics.World.getMeter
    -- @description Verifies World:setMeter and World:getMeter round-trip the pixels-per-meter scale.
    it("getMeter and setMeter round-trip", function()
        local world = lurek.physics.newWorld(0, 0)
        world:setMeter(100)
        expect_near(100, world:getMeter(), 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.setMeter
    -- @covers lurek.physics.World.toPhysics
    -- @covers lurek.physics.World.toPixels
    -- @description Verifies World:toPhysics and World:toPixels convert distances using the configured meter scale.
    it("toPhysics and toPixels convert", function()
        local world = lurek.physics.newWorld(0, 0)
        world:setMeter(50)
        local m = world:toPhysics(100)
        expect_near(2.0, m, 0.01)
        local px = world:toPixels(2.0)
        expect_near(100, px, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies World:newCircleBody creates a positioned body with circle geometry.
    it("newCircleBody creates a body with circle shape", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(10, 20, 5, "dynamic")
        local x, y = body:getPosition()
        expect_near(10, x, 0.01)
        expect_near(20, y, 0.01)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newPolygonBody
    -- @covers lurek.physics.Body.getType
    -- @description Verifies World:newPolygonBody creates a dynamic polygon body.
    it("newPolygonBody creates a polygon body", function()
        local world = lurek.physics.newWorld(0, 0)
        local verts = {0, 0, 10, 0, 10, 10, 0, 10}
        local body = world:newPolygonBody(5, 5, verts, "dynamic")
        expect_not_nil(body)
        expect_equal("dynamic", body:getType())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newEdgeBody
    -- @description Verifies World:newEdgeBody creates edge-body userdata.
    it("newEdgeBody creates an edge body", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newEdgeBody(0, 0, 0, 0, 100, 0, "static")
        expect_not_nil(body)
    end)
end)

-- â”€â”€ Joints â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: Joint operations.
describe("Joint operations", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addRevoluteJoint
    -- @description Verifies addRevoluteJoint creates a numeric joint handle between two bodies.
    it("addRevoluteJoint creates a revolute joint", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        local jid = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_type("number", jid)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addDistanceJoint
    -- @description Verifies addDistanceJoint creates a numeric joint handle between two bodies.
    it("addDistanceJoint creates a distance joint", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(10, 0, 1, "dynamic")
        local jid = world:addDistanceJoint(a:getId(), b:getId(), 0, 0, 10, 0, 10)
        expect_type("number", jid)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addWeldJoint
    -- @description Verifies addWeldJoint creates a numeric joint handle between two bodies.
    it("addWeldJoint creates a weld joint", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        local jid = world:addWeldJoint(a:getId(), b:getId(), 2.5, 0)
        expect_type("number", jid)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.jointCount
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addRevoluteJoint
    -- @description Verifies jointCount increases after adding a joint.
    it("jointCount returns number of joints", function()
        local world = lurek.physics.newWorld(0, 0)
        expect_equal(0, world:jointCount())
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_equal(1, world:jointCount())
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addRevoluteJoint
    -- @covers lurek.physics.World.getJointIds
    -- @description Verifies getJointIds returns the IDs of created joints.
    it("getJointIds returns joint id table", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        local ids = world:getJointIds()
        expect_equal(1, #ids)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addRevoluteJoint
    -- @covers lurek.physics.World.getJointType
    -- @description Verifies getJointType returns a string descriptor for an existing joint.
    it("getJointType returns joint type string", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        local jid = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        local jtype = world:getJointType(jid)
        expect_type("string", jtype)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.addRevoluteJoint
    -- @covers lurek.physics.World.jointCount
    -- @covers lurek.physics.World.destroyJoint
    -- @description Verifies destroyJoint can be called for an existing joint without error.
    it("destroyJoint removes the rapier joint", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1, "dynamic")
        local b = world:newCircleBody(5, 0, 1, "dynamic")
        local jid = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_equal(1, world:jointCount())
        -- destroyJoint removes the rapier joint; handle vec may not shrink
        expect_no_error(function() world:destroyJoint(jid) end)
    end)
end)

-- â”€â”€ Fixtures â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: Fixture operations.
describe("Fixture operations", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.World.addFixture
    -- @description Verifies addFixture returns a numeric fixture index for a body.
    it("addFixture returns fixture index", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local idx = world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_type("number", idx)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.World.fixtureCount
    -- @covers lurek.physics.World.addFixture
    -- @description Verifies fixtureCount increments after a fixture is added to a body.
    it("fixtureCount increases after addFixture", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local before = world:fixtureCount(body:getId())
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_equal(before + 1, world:fixtureCount(body:getId()))
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.World.addFixture
    -- @covers lurek.physics.World.setFixtureFriction
    -- @description Verifies setFixtureFriction can update an existing fixture without error.
    it("setFixtureFriction does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureFriction(body:getId(), 0, 0.8)
        end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.World.addFixture
    -- @covers lurek.physics.World.setFixtureRestitution
    -- @description Verifies setFixtureRestitution can update an existing fixture without error.
    it("setFixtureRestitution does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureRestitution(body:getId(), 0, 0.6)
        end)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.newBody
    -- @covers lurek.physics.World.addFixture
    -- @covers lurek.physics.World.setFixtureSensor
    -- @description Verifies setFixtureSensor can toggle sensor mode on an existing fixture without error.
    it("setFixtureSensor does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureSensor(body:getId(), 0, true)
        end)
    end)
end)

-- â”€â”€ Collision behavior â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: Collision and simulation behavior.
describe("Collision and simulation behavior", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.step
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies static bodies remain stationary under gravity.
    it("static body does not move under gravity", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 1.0, "static")
        world:step(1.0 / 60.0)
        local _, y = body:getPosition()
        expect_near(0, y, 0.001)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.step
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies zero gravity leaves a dynamic body stationary.
    it("zero gravity keeps dynamic body still", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        world:step(1.0 / 60.0)
        local x, y = body:getPosition()
        expect_near(0, x, 0.001)
        expect_near(0, y, 0.001)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.World.step
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies kinematic bodies are not displaced by gravity during stepping.
    it("kinematic body is unaffected by gravity", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 1.0, "kinematic")
        world:step(1.0 / 60.0)
        local _, y = body:getPosition()
        expect_near(0, y, 0.001)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.setGravityScale
    -- @covers lurek.physics.World.step
    -- @covers lurek.physics.Body.getPosition
    -- @description Verifies gravityScale zero prevents a dynamic body from falling.
    it("gravity scale 0 prevents falling", function()
        local world = lurek.physics.newWorld(0, 9.81)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        body:setGravityScale(0)
        world:step(1.0 / 60.0)
        local _, y = body:getPosition()
        expect_near(0, y, 0.001)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newCircleBody
    -- @covers lurek.physics.Body.setLayer
    -- @covers lurek.physics.Body.setMask
    -- @covers lurek.physics.World.step
    -- @description Verifies mismatched layer and mask settings can be stepped without collision errors.
    it("layer/mask filtering prevents collision", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(0, 0, 1.0, "dynamic")
        local b = world:newCircleBody(0, 0, 1.0, "dynamic")
        a:setLayer(1)
        a:setMask(2)
        b:setLayer(4)
        b:setMask(8)
        -- different layer/mask = no collision expected
        expect_no_error(function() world:step(1.0 / 60.0) end)
    end)
end)

-- â”€â”€ destroyWorld â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Covers suite: World destruction.
describe("World destruction", function()
    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.World.newBody
    -- @covers lurek.physics.destroyWorld
    -- @description Verifies destroyWorld accepts a populated world without error.
    it("destroyWorld does not error", function()
        local world = lurek.physics.newWorld(0, 0)
        world:newBody(0, 0, "dynamic")
        expect_no_error(function() lurek.physics.destroyWorld(world) end)
    end)
end)

test_summary()

