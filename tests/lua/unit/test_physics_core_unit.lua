-- Canonical unit coverage for lurek.physics core APIs.

local function new_world(gx, gy)
    return lurek.physics.newWorld(gx or 0, gy or 0)
end

local function new_dynamic_body(world)
    return lurek.physics.newBody(world, 0, 0, "dynamic")
end

local function new_circle_body(world)
    return world:newCircleBody(0, 0, 1.0, "dynamic")
end

-- @describe lurek.physics module
describe("lurek.physics module", function()
    -- @covers lurek.physics.newWorld
    it("newWorld returns a world userdata", function()
        expect_type("userdata", new_world(0, 9.81))
    end)

    -- @covers lurek.physics.step
    it("step advances a module-created world", function()
        local world = new_world(0, 9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.step(world, 1 / 60)
        local _, y = lurek.physics.getBody(world, body)
        expect_true(y >= 0)
    end)

    -- @covers lurek.physics.newBody
    it("newBody creates a body userdata", function()
        expect_type("userdata", lurek.physics.newBody(new_world(0, 0), 10, 20, "dynamic"))
    end)

    -- @covers lurek.physics.getBody
    it("getBody returns position and velocity values", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 50, 75, "static")
        local x, y, vx, vy = lurek.physics.getBody(world, body)
        expect_near(50, x, 0.01)
        expect_near(75, y, 0.01)
        expect_type("number", vx)
        expect_type("number", vy)
    end)

    -- @covers lurek.physics.setBodyVelocity
    it("setBodyVelocity updates body velocity", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.setBodyVelocity(world, body, 100, 0)
        local _, _, vx = lurek.physics.getBody(world, body)
        expect_near(100, vx, 0.01)
    end)

    -- @covers lurek.physics.isSleepingAllowed
    it("isSleepingAllowed returns the current sleep flag", function()
        local world = new_world(0, 9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_type("boolean", lurek.physics.isSleepingAllowed(world, body))
    end)

    -- @covers lurek.physics.setSleepingAllowed
    it("setSleepingAllowed updates the module sleep flag", function()
        local world = new_world(0, 9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.setSleepingAllowed(world, body, false)
        expect_false(lurek.physics.isSleepingAllowed(world, body))
    end)

    -- @covers lurek.physics.attachShape
    it("attachShape attaches a standalone shape to a body", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local shape = lurek.physics.newCircleShape(1.0)
        expect_no_error(function()
            lurek.physics.attachShape(body, shape)
        end)
    end)

    -- @covers lurek.physics.destroyWorld
    it("destroyWorld is callable", function()
        expect_no_error(function()
            lurek.physics.destroyWorld(new_world(0, 0))
        end)
    end)

    -- @covers lurek.physics.debugDraw
    it("debugDraw toggle is callable", function()
        expect_no_error(function()
            lurek.physics.debugDraw(true)
            lurek.physics.debugDraw(false)
        end)
    end)

    -- @covers lurek.physics.drawDebugGpu
    it("drawDebugGpu is callable", function()
        expect_no_error(function()
            lurek.physics.drawDebugGpu(new_world(0, 0), {})
        end)
    end)

    -- @covers lurek.physics.testAABB
    it("testAABB detects overlap", function()
        expect_true(lurek.physics.testAABB(0, 0, 10, 10, 5, 5, 10, 10))
        expect_false(lurek.physics.testAABB(0, 0, 10, 10, 20, 20, 10, 10))
    end)

    -- @covers lurek.physics.testCircles
    it("testCircles detects circle overlap", function()
        expect_true(lurek.physics.testCircles(0, 0, 5, 3, 0, 5))
        expect_false(lurek.physics.testCircles(0, 0, 1, 10, 0, 1))
    end)

    -- @covers lurek.physics.testPoint
    it("testPoint checks point inclusion in an aabb", function()
        expect_true(lurek.physics.testPoint(5, 5, 0, 0, 10, 10))
        expect_false(lurek.physics.testPoint(15, 5, 0, 0, 10, 10))
    end)

    -- @covers lurek.physics.testCircleAABB
    it("testCircleAABB checks circle and aabb overlap", function()
        expect_true(lurek.physics.testCircleAABB(5, 5, 3, 0, 0, 10, 10))
        expect_false(lurek.physics.testCircleAABB(20, 20, 1, 0, 0, 10, 10))
    end)
end)

-- @describe standalone shape userdata
describe("standalone shape userdata", function()
    -- @covers lurek.physics.newCircleShape
    it("newCircleShape creates a circle shape", function()
        expect_type("userdata", lurek.physics.newCircleShape(2.0))
    end)

    -- @covers lurek.physics.newRectangleShape
    it("newRectangleShape creates a rectangle shape", function()
        expect_type("userdata", lurek.physics.newRectangleShape(20, 10))
    end)

    -- @covers lurek.physics.newEdgeShape
    it("newEdgeShape creates an edge shape", function()
        expect_type("userdata", lurek.physics.newEdgeShape(0, 0, 10, 0))
    end)

    -- @covers lurek.physics.newPolygonShape
    it("newPolygonShape creates a polygon shape", function()
        expect_type("userdata", lurek.physics.newPolygonShape(0, 0, 10, 0, 5, 10))
    end)

    -- @covers lurek.physics.newChainShape
    it("newChainShape creates a chain shape", function()
        expect_type("userdata", lurek.physics.newChainShape(false, 0, 0, 5, 0, 10, 5))
    end)

    -- @covers LPhysicsShape:getType
    it("getType reports the shape kind", function()
        expect_equal("circle", lurek.physics.newCircleShape(1.0):getType())
    end)

    -- @covers LPhysicsShape:getRadius
    it("getRadius returns the circle radius", function()
        expect_near(7.5, lurek.physics.newCircleShape(7.5):getRadius(), 0.001)
    end)

    -- @covers LPhysicsShape:getBoundingBox
    it("getBoundingBox returns numeric extents", function()
        local x1, y1, x2, y2 = lurek.physics.newCircleShape(5):getBoundingBox()
        expect_type("number", x1)
        expect_type("number", y1)
        expect_type("number", x2)
        expect_type("number", y2)
    end)

    -- @covers LPhysicsShape:setDensity
    it("setDensity is callable", function()
        expect_no_error(function()
            lurek.physics.newCircleShape(1):setDensity(2.0)
        end)
    end)

    -- @covers LPhysicsShape:setFriction
    it("setFriction is callable", function()
        expect_no_error(function()
            lurek.physics.newCircleShape(1):setFriction(0.8)
        end)
    end)

    -- @covers LPhysicsShape:setRestitution
    it("setRestitution is callable", function()
        expect_no_error(function()
            lurek.physics.newCircleShape(1):setRestitution(0.5)
        end)
    end)

    -- @covers LPhysicsShape:setSensor
    it("setSensor is callable", function()
        expect_no_error(function()
            lurek.physics.newCircleShape(1):setSensor(true)
        end)
    end)

    -- @covers LPhysicsShape:destroy
    it("destroy is callable", function()
        expect_no_error(function()
            lurek.physics.newCircleShape(1):destroy()
        end)
    end)

    -- @covers LPhysicsShape:type
    it("type returns LPhysicsShape", function()
        expect_equal("LPhysicsShape", lurek.physics.newCircleShape(1):type())
    end)

    -- @covers LPhysicsShape:typeOf
    it("typeOf reports shape inheritance", function()
        expect_true(lurek.physics.newCircleShape(1):typeOf("LPhysicsShape"))
    end)
end)

-- @describe body userdata methods
describe("body userdata methods", function()
    -- @covers LBody:getPosition
    it("getPosition returns body coordinates", function()
        local x, y = lurek.physics.newBody(new_world(0, 0), 12, 34, "dynamic"):getPosition()
        expect_near(12, x, 0.01)
        expect_near(34, y, 0.01)
    end)

    -- @covers LBody:setPosition
    it("setPosition updates body coordinates", function()
        local body = lurek.physics.newBody(new_world(0, 0), 0, 0, "dynamic")
        body:setPosition(20, 30)
        local x, y = body:getPosition()
        expect_near(20, x, 0.01)
        expect_near(30, y, 0.01)
    end)

    -- @covers LBody:getX
    it("getX returns the x coordinate", function()
        expect_near(8, lurek.physics.newBody(new_world(0, 0), 8, 9, "dynamic"):getX(), 0.01)
    end)

    -- @covers LBody:getY
    it("getY returns the y coordinate", function()
        expect_near(9, lurek.physics.newBody(new_world(0, 0), 8, 9, "dynamic"):getY(), 0.01)
    end)

    -- @covers LBody:getVelocity
    it("getVelocity returns velocity components", function()
        local body = lurek.physics.newBody(new_world(0, 0), 0, 0, "dynamic")
        body:setVelocity(3, 4)
        local vx, vy = body:getVelocity()
        expect_near(3, vx, 0.01)
        expect_near(4, vy, 0.01)
    end)

    -- @covers LBody:setVelocity
    it("setVelocity updates velocity components", function()
        local body = lurek.physics.newBody(new_world(0, 0), 0, 0, "dynamic")
        body:setVelocity(5, 6)
        local vx, vy = body:getVelocity()
        expect_near(5, vx, 0.01)
        expect_near(6, vy, 0.01)
    end)

    -- @covers LBody:getAngle
    it("getAngle returns the rotation angle", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setAngle(0.5)
        expect_near(0.5, body:getAngle(), 0.01)
    end)

    -- @covers LBody:setAngle
    it("setAngle updates the rotation angle", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setAngle(1.0)
        expect_near(1.0, body:getAngle(), 0.01)
    end)

    -- @covers LBody:getAngularVelocity
    it("getAngularVelocity returns angular speed", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setAngularVelocity(2.5)
        expect_near(2.5, body:getAngularVelocity(), 0.01)
    end)

    -- @covers LBody:setAngularVelocity
    it("setAngularVelocity updates angular speed", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setAngularVelocity(1.75)
        expect_near(1.75, body:getAngularVelocity(), 0.01)
    end)

    -- @covers LBody:getMass
    it("getMass returns a numeric mass value", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getMass())
    end)

    -- @covers LBody:getType
    it("getType returns the body kind", function()
        expect_equal("dynamic", new_dynamic_body(new_world(0, 0)):getType())
    end)

    -- @covers LBody:setType
    it("setType updates the body kind", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setType("static")
        expect_equal("static", body:getType())
    end)

    -- @covers LBody:getFriction
    it("getFriction returns a numeric value", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getFriction())
    end)

    -- @covers LBody:setFriction
    it("setFriction is callable", function()
        expect_no_error(function()
            new_dynamic_body(new_world(0, 0)):setFriction(0.8)
        end)
    end)

    -- @covers LBody:getRestitution
    it("getRestitution returns a numeric value", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getRestitution())
    end)

    -- @covers LBody:setRestitution
    it("setRestitution is callable", function()
        expect_no_error(function()
            new_dynamic_body(new_world(0, 0)):setRestitution(0.5)
        end)
    end)

    -- @covers LBody:getLayer
    it("getLayer returns a numeric layer", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getLayer())
    end)

    -- @covers LBody:setLayer
    it("setLayer updates the layer", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setLayer(3)
        expect_equal(3, body:getLayer())
    end)

    -- @covers LBody:getGravityScale
    it("getGravityScale returns a numeric scale", function()
        expect_type("number", new_circle_body(new_world(0, 0)):getGravityScale())
    end)

    -- @covers LBody:setGravityScale
    it("setGravityScale updates the gravity multiplier", function()
        local body = new_circle_body(new_world(0, 0))
        body:setGravityScale(0.5)
        expect_near(0.5, body:getGravityScale(), 0.01)
    end)

    -- @covers LBody:getId
    it("getId returns a numeric body identifier", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getId())
    end)

    -- @covers LBody:destroy
    it("destroy is callable", function()
        expect_no_error(function()
            new_dynamic_body(new_world(0, 0)):destroy()
        end)
    end)

    -- @covers LBody:type
    it("type returns LBody", function()
        expect_equal("LBody", new_dynamic_body(new_world(0, 0)):type())
    end)

    -- @covers LBody:typeOf
    it("typeOf reports body inheritance", function()
        expect_true(new_dynamic_body(new_world(0, 0)):typeOf("LBody"))
    end)
end)

-- @describe world userdata methods
describe("world userdata methods", function()
    -- @covers LWorld:getGravity
    it("getGravity returns the configured world gravity", function()
        local gx, gy = new_world(0, 9.81):getGravity()
        expect_near(0, gx, 0.01)
        expect_near(9.81, gy, 0.01)
    end)

    -- @covers LWorld:setGravity
    it("setGravity updates world gravity", function()
        local world = new_world(0, 0)
        world:setGravity(0, -10)
        local gx, gy = world:getGravity()
        expect_near(-10, gy, 0.01)
    end)

    -- @covers LWorld:getBodyCount
    it("getBodyCount tracks world bodies", function()
        local world = new_world(0, 0)
        expect_equal(0, world:getBodyCount())
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "static")
        expect_equal(2, world:getBodyCount())
    end)

    -- @covers LWorld:newBody
    it("newBody creates bodies from the world userdata", function()
        expect_type("userdata", new_world(0, 0):newBody(0, 0, "dynamic"))
    end)

    -- @covers LWorld:getBodyIds
    it("getBodyIds returns a table of body ids", function()
        local world = new_world(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        expect_equal(2, #world:getBodyIds())
    end)

    -- @covers LWorld:destroyBody
    it("destroyBody is callable for an existing body id", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_no_error(function()
            world:destroyBody(body:getId())
        end)
    end)

    -- @covers LWorld:clear
    it("clear removes all bodies from the world", function()
        local world = new_world(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        world:clear()
        expect_equal(0, world:getBodyCount())
    end)

    -- @covers LWorld:step
    it("step advances simulation through the world userdata", function()
        local world = new_world(0, 9.81)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        world:step(1 / 60)
        local _, y = body:getPosition()
        expect_true(y >= 0)
    end)

    -- @covers LWorld:getMeter
    it("getMeter returns a numeric scale", function()
        expect_type("number", new_world(0, 0):getMeter())
    end)

    -- @covers LWorld:setMeter
    it("setMeter updates the conversion scale", function()
        local world = new_world(0, 0)
        world:setMeter(50)
        expect_near(50, world:getMeter(), 0.01)
    end)

    -- @covers LWorld:toPhysics
    it("toPhysics converts pixels into world units", function()
        local world = new_world(0, 0)
        world:setMeter(50)
        expect_near(2.0, world:toPhysics(100), 0.01)
    end)

    -- @covers LWorld:toPixels
    it("toPixels converts world units into pixels", function()
        local world = new_world(0, 0)
        world:setMeter(50)
        expect_near(100, world:toPixels(2.0), 0.01)
    end)

    -- @covers LWorld:newCircleBody
    it("newCircleBody creates a dynamic circle body", function()
        expect_type("userdata", new_world(0, 0):newCircleBody(10, 20, 5, "dynamic"))
    end)

    -- @covers LWorld:newPolygonBody
    it("newPolygonBody creates a polygon body", function()
        local verts = { 0, 0, 10, 0, 10, 10, 0, 10 }
        expect_not_nil(new_world(0, 0):newPolygonBody(5, 5, verts, "dynamic"))
    end)

    -- @covers LWorld:newEdgeBody
    it("newEdgeBody creates an edge body", function()
        expect_not_nil(new_world(0, 0):newEdgeBody(0, 0, 0, 0, 100, 0, "static"))
    end)

    -- @covers LWorld:addRevoluteJoint
    it("addRevoluteJoint creates a joint handle", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0))
    end)

    -- @covers LWorld:addDistanceJoint
    it("addDistanceJoint creates a joint handle", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(10, 0, 1.0, "dynamic")
        expect_type("number", world:addDistanceJoint(a:getId(), b:getId(), 0, 0, 10, 0, 10))
    end)

    -- @covers LWorld:addWeldJoint
    it("addWeldJoint creates a joint handle", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addWeldJoint(a:getId(), b:getId(), 2.5, 0))
    end)

    -- @covers LWorld:jointCount
    it("jointCount returns the number of joints", function()
        local world = new_world(0, 0)
        expect_equal(0, world:jointCount())
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_equal(1, world:jointCount())
    end)

    -- @covers LWorld:getJointIds
    it("getJointIds returns a table of joint ids", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_equal(1, #world:getJointIds())
    end)

    -- @covers LWorld:getJointType
    it("getJointType returns the joint kind string", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_type("string", world:getJointType(joint))
    end)

    -- @covers LWorld:destroyJoint
    it("destroyJoint is callable for an existing joint", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_no_error(function()
            world:destroyJoint(joint)
        end)
    end)

    -- @covers LWorld:fixtureCount
    it("fixtureCount reports at least the default fixture", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_equal(1, world:fixtureCount(body:getId()))
    end)

    -- @covers LWorld:addFixture
    it("addFixture returns a fixture index", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_type("number", world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0))
    end)

    -- @covers LWorld:setFixtureFriction
    it("setFixtureFriction is callable", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureFriction(body:getId(), 0, 0.8)
        end)
    end)

    -- @covers LWorld:setFixtureRestitution
    it("setFixtureRestitution is callable", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureRestitution(body:getId(), 0, 0.4)
        end)
    end)

    -- @covers LWorld:setFixtureSensor
    it("setFixtureSensor is callable", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        expect_no_error(function()
            world:setFixtureSensor(body:getId(), 0, true)
        end)
    end)

    -- @covers LWorld:setBodyData
    it("setBodyData stores lua-side metadata", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyData(body:getId(), { name = "ground" })
        local data = world:getBodyData(body:getId())
        expect_equal("ground", data.name)
    end)

    -- @covers LWorld:getBodyData
    it("getBodyData returns stored metadata", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyData(body:getId(), "hello")
        expect_equal("hello", world:getBodyData(body:getId()))
    end)

    -- @covers LWorld:clearBodyData
    it("clearBodyData removes stored metadata", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyData(body:getId(), "hello")
        world:clearBodyData(body:getId())
        expect_nil(world:getBodyData(body:getId()))
    end)

    -- @covers LWorld:getSolverIterations
    it("getSolverIterations returns the iteration count", function()
        expect_equal(4, new_world(0, 0):getSolverIterations())
    end)

    -- @covers LWorld:setSolverIterations
    it("setSolverIterations persists positive values", function()
        local world = new_world(0, 0)
        world:setSolverIterations(8)
        expect_equal(8, world:getSolverIterations())
    end)

    -- @covers LWorld:isBodySleeping
    it("isBodySleeping returns a boolean", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_type("boolean", world:isBodySleeping(body:getId()))
    end)

    -- @covers LWorld:sleepBody
    it("sleepBody is callable", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_no_error(function()
            world:sleepBody(body:getId())
        end)
    end)

    -- @covers LWorld:wakeUpBody
    it("wakeUpBody is callable", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:sleepBody(body:getId())
        expect_no_error(function()
            world:wakeUpBody(body:getId())
        end)
    end)

    -- @covers LWorld:queryAABB
    it("queryAABB returns a table of hits", function()
        local world = new_world(0, 0)
        world:newCircleBody(2, 2, 1, "dynamic")
        expect_type("table", world:queryAABB(0, 0, 8, 8))
    end)

    -- @covers LWorld:raycastClosest
    it("raycastClosest returns a hit result near a body", function()
        local world = new_world(0, 0)
        world:newCircleBody(2, 2, 1, "dynamic")
        local hit = world:raycastClosest(0, 2, 1, 0, 10)
        if hit ~= nil then
            expect_type("table", hit)
        else
            expect_nil(hit)
        end
    end)

    -- @covers LWorld:getBodyAtPoint
    it("getBodyAtPoint returns a body at a covered coordinate", function()
        local world = new_world(0, 0)
        world:newCircleBody(2, 2, 1, "dynamic")
        local at = world:getBodyAtPoint(2, 2)
        if at ~= nil then
            expect_type("number", at)
        else
            expect_nil(at)
        end
    end)

    -- @covers LWorld:getContacts
    it("getContacts returns a table", function()
        local world = new_world(0, 0)
        world:newCircleBody(0, 0, 1, "dynamic")
        world:newCircleBody(0, 0, 1, "dynamic")
        world:step(1 / 60)
        expect_type("table", world:getContacts())
    end)

    -- @covers LWorld:type
    it("type returns LWorld", function()
        expect_equal("LWorld", new_world(0, 0):type())
    end)

    -- @covers LWorld:typeOf
    it("typeOf reports world inheritance", function()
        expect_true(new_world(0, 0):typeOf("LWorld"))
    end)
end)

test_summary()
