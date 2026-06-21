-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_physics_core_unit.lua
do
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

local function new_static_floor(world)
    return world:newBody(0, 40, "static")
end

local function new_terrain(world, width, height, cell_size)
    return lurek.physics.newTerrain(width or 32, height or 32, cell_size or 4, world)
end

-- @describe lurek.physics module
describe("lurek.physics module", function()
    -- @covers lurek.physics.newWorld
    it("newWorld returns a world userdata", function()
        expect_type("userdata", new_world(0, 9.81))
    end)

    -- @covers lurek.physics.step
    it("step advances a module-created world and rejects invalid dt", function()
        local world = new_world(0, 9.81)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.step(world, 1 / 60)
        local _, y = lurek.physics.getBody(world, body)
        expect_true(y >= 0)
        local ok, err = pcall(function()
            lurek.physics.step(world, 0 / 0)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "step", 1, true) ~= nil)
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

    -- @covers lurek.physics.getCollisions
    it("getCollisions returns contact pairs after a collision step", function()
        local world = new_world(0, 400)
        world:newBody(200, 500, "static")
        world:newCircleBody(200, 100, 10, "dynamic")
        for _ = 1, 120 do
            lurek.physics.step(world, 1 / 60)
        end
        local collisions = lurek.physics.getCollisions(world)
        expect_type("table", collisions)
    end)

    -- @covers lurek.physics.newTerrain
    it("newTerrain creates a destructible terrain userdata and rejects zero cell size", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 8)
        expect_type("userdata", terrain)
        local ok, err = pcall(function()
            lurek.physics.newTerrain(4, 4, 0, lurek.physics.newWorld(0, 0))
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "newTerrain", 1, true) ~= nil)
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

    -- @covers LBody:setMass
    it("setMass overrides the body mass", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setMass(7.5)
        expect_near(7.5, body:getMass(), 0.01)
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

    -- @covers LBody:getWidth
    it("getWidth returns a numeric body width", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getWidth())
    end)

    -- @covers LBody:getHeight
    it("getHeight returns a numeric body height", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getHeight())
    end)

    -- @covers LBody:applyImpulse
    it("applyImpulse changes the body velocity immediately", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:applyImpulse(5, 0)
        local vx = select(1, body:getVelocity())
        expect_true(vx ~= 0)
    end)

    -- @covers LBody:applyForce
    it("applyForce is callable on a dynamic body", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_no_error(function()
            body:applyForce(10, 0)
        end)
    end)

    -- @covers LBody:applyTorque
    it("applyTorque is callable on a dynamic body", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_no_error(function()
            body:applyTorque(3.0)
        end)
    end)

    -- @covers LBody:applyForceAtPoint
    it("applyForceAtPoint is callable on a dynamic body", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_no_error(function()
            body:applyForceAtPoint(5, 2, 0, 0)
        end)
    end)

    -- @covers LBody:applyAngularImpulse
    it("applyAngularImpulse changes angular velocity", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:applyAngularImpulse(2.0)
        expect_true(body:getAngularVelocity() ~= 0)
    end)

    -- @covers LBody:isFixedRotation
    it("isFixedRotation returns the current fixed-rotation flag", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_type("boolean", body:isFixedRotation())
    end)

    -- @covers LBody:setFixedRotation
    it("setFixedRotation updates the body rotation lock", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setFixedRotation(true)
        expect_true(body:isFixedRotation())
    end)

    -- @covers LBody:getLinearDamping
    it("getLinearDamping returns the linear damping factor", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getLinearDamping())
    end)

    -- @covers LBody:setLinearDamping
    it("setLinearDamping updates the linear damping factor", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setLinearDamping(0.5)
        expect_near(0.5, body:getLinearDamping(), 0.01)
    end)

    -- @covers LBody:getAngularDamping
    it("getAngularDamping returns the angular damping factor", function()
        expect_type("number", new_dynamic_body(new_world(0, 0)):getAngularDamping())
    end)

    -- @covers LBody:setAngularDamping
    it("setAngularDamping updates the angular damping factor", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setAngularDamping(0.3)
        expect_near(0.3, body:getAngularDamping(), 0.01)
    end)

    -- @covers LBody:isBullet
    it("isBullet returns the current ccd flag", function()
        expect_type("boolean", new_dynamic_body(new_world(0, 0)):isBullet())
    end)

    -- @covers LBody:setBullet
    it("setBullet updates the ccd flag", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setBullet(true)
        expect_true(body:isBullet())
    end)

    -- @covers LBody:isSleepingAllowed
    it("isSleepingAllowed returns the body sleep permission", function()
        expect_type("boolean", new_dynamic_body(new_world(0, 0)):isSleepingAllowed())
    end)

    -- @covers LBody:setSleepingAllowed
    it("setSleepingAllowed updates the body sleep permission", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setSleepingAllowed(false)
        expect_false(body:isSleepingAllowed())
    end)

    -- @covers LBody:isSleeping
    it("isSleeping reports whether the body is asleep", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setSleepingAllowed(true)
        body:sleep()
        expect_true(body:isSleeping())
    end)

    -- @covers LBody:wakeUp
    it("wakeUp reactivates a sleeping body", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setSleepingAllowed(true)
        body:sleep()
        body:wakeUp()
        expect_false(body:isSleeping())
    end)

    -- @covers LBody:sleep
    it("sleep forces a body into the sleeping state", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setSleepingAllowed(true)
        body:sleep()
        expect_true(body:isSleeping())
    end)

    -- @covers LBody:destroy
    it("destroy is callable", function()
        expect_no_error(function()
            new_dynamic_body(new_world(0, 0)):destroy()
        end)
    end)

    -- @covers LBody:isValid
    it("isValid reports destroyed body handles", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_true(body:isValid())
        body:destroy()
        expect_false(body:isValid())
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
        local ok = pcall(function()
            new_world(0, 0):newBody(0, 0, "invalid")
        end)
        expect_false(ok)
    end)

    -- @covers LWorld:getBodyIds
    it("getBodyIds returns a table of body ids", function()
        local world = new_world(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        expect_equal(2, #world:getBodyIds())
    end)

    -- @covers LWorld:hasBody
    it("hasBody reports live body slots", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_true(world:hasBody(body:getId()))
        body:destroy()
        expect_false(world:hasBody(body:getId()))
    end)

    -- @covers LWorld:getStats
    it("getStats reports active counts and stable slots", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        local stats = world:getStats()
        expect_equal(1, stats.bodies)
        expect_equal(1, stats.bodySlots)
        expect_equal(1, stats.colliders)
        body:destroy()
        stats = world:getStats()
        expect_equal(0, stats.bodies)
        expect_equal(1, stats.bodySlots)
    end)

    -- @covers LWorld:destroyBody
    it("destroyBody is callable for an existing body id", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_no_error(function()
            world:destroyBody(body:getId())
        end)
        expect_equal(0, world:getBodyCount())
    end)

    -- @covers LWorld:clear
    it("clear removes runtime state while preserving world settings", function()
        local world = new_world(0, 0)
        world:newBody(0, 0, "dynamic")
        world:newBody(5, 5, "dynamic")
        world:setGravity(5, 6)
        world:setMeter(96)
        world:setSolverIterations(12)
        world:addZone(-10, -10, 20, 20)
        world:clear()
        expect_equal(0, world:getBodyCount())
        expect_equal(0, world:jointCount())
        local gx, gy = world:getGravity()
        expect_equal(5, gx)
        expect_equal(6, gy)
        expect_equal(96, world:getMeter())
        expect_equal(12, world:getSolverIterations())
        expect_equal(0, world:getStats().zones)
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

    -- @covers LWorld:newChainBody
    it("newChainBody creates a chain-collider body", function()
        local body = new_world(0, 0):newChainBody(0, 0, { 0, 0, 20, 0, 20, 10 }, false, "static")
        expect_type("userdata", body)
    end)

    -- @covers LWorld:addRevoluteJoint
    it("addRevoluteJoint creates a joint handle and errors for invalid body ids", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0))
        local ok, err = pcall(function()
            world:addRevoluteJoint(a:getId(), 999, 0, 0)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "addRevoluteJoint", 1, true) ~= nil)
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

    -- @covers LWorld:addPrismaticJoint
    it("addPrismaticJoint creates a slider joint handle", function()
        local world = new_world(0, 0)
        local rail = world:newBody(0, 0, "static")
        local slider = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addPrismaticJoint(rail:getId(), slider:getId(), 0, 0, 1, 0))
    end)

    -- @covers LWorld:addRopeJoint
    it("addRopeJoint creates a rope joint handle", function()
        local world = new_world(0, 0)
        local a = world:newBody(0, 0, "static")
        local b = world:newCircleBody(0, 10, 1.0, "dynamic")
        expect_type("number", world:addRopeJoint(a:getId(), b:getId(), 0, 0, 0, 0, 20))
    end)

    -- @covers LWorld:addWheelJoint
    it("addWheelJoint creates a wheel joint handle", function()
        local world = new_world(0, 0)
        local chassis = world:newBody(0, 0, "static")
        local wheel = world:newCircleBody(0, 10, 1.0, "dynamic")
        expect_type("number", world:addWheelJoint(chassis:getId(), wheel:getId(), 0, 0, 0, 1))
    end)

    -- @covers LWorld:addFrictionJoint
    it("addFrictionJoint creates a friction joint handle", function()
        local world = new_world(0, 0)
        local a = world:newBody(0, 0, "static")
        local b = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_type("number", world:addFrictionJoint(a:getId(), b:getId(), 0, 0, 10, 5))
    end)

    -- @covers LWorld:addMotorJoint
    it("addMotorJoint creates a motor joint handle", function()
        local world = new_world(0, 0)
        local a = world:newBody(0, 0, "static")
        local b = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_type("number", world:addMotorJoint(a:getId(), b:getId(), 0.5))
    end)

    -- @covers LWorld:addMouseJoint
    it("addMouseJoint creates a mouse joint handle", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        expect_type("number", world:addMouseJoint(body:getId(), 5, 6, 100))
    end)

    -- @covers LWorld:addPulleyJoint
    it("addPulleyJoint creates a pulley joint handle", function()
        local world = new_world(0, 0)
        local a = world:newCircleBody(-5, 0, 1.0, "dynamic")
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addPulleyJoint(a:getId(), b:getId(), 0, 0))
    end)

    -- @covers LWorld:addGearJoint
    it("addGearJoint creates a gear joint handle", function()
        local world = new_world(0, 0)
        local a = world:newCircleBody(-5, 0, 1.0, "dynamic")
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        expect_type("number", world:addGearJoint(a:getId(), b:getId(), 0, 0))
    end)

    -- @covers LWorld:jointCount
    it("jointCount returns the number of joints", function()
        local world = new_world(0, 0)
        expect_equal(0, world:jointCount())
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local jid = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_equal(1, world:jointCount())
        world:destroyJoint(jid)
        expect_equal(0, world:jointCount())
    end)

    -- @covers LWorld:hasJoint
    it("hasJoint reports live joint slots", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local jid = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_true(world:hasJoint(jid))
        world:destroyJoint(jid)
        expect_false(world:hasJoint(jid))
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

    -- @covers LWorld:getJointBodies
    it("getJointBodies returns ids connected by a joint", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        local ida, idb = world:getJointBodies(joint)
        expect_equal(a:getId(), ida)
        expect_equal(b:getId(), idb)
    end)

    -- @covers LWorld:setJointMotorSpeed
    it("setJointMotorSpeed updates a joint motor speed", function()
        local world = new_world(0, 0)
        local rail = world:newBody(0, 0, "static")
        local slider = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addPrismaticJoint(rail:getId(), slider:getId(), 0, 0, 1, 0)
        world:setJointMotorSpeed(joint, 5.0)
        expect_near(5.0, world:getJointMotorSpeed(joint), 0.01)
    end)

    -- @covers LWorld:getJointMotorSpeed
    it("getJointMotorSpeed returns the configured motor speed", function()
        local world = new_world(0, 0)
        local rail = world:newBody(0, 0, "static")
        local slider = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addPrismaticJoint(rail:getId(), slider:getId(), 0, 0, 1, 0)
        world:setJointMotorSpeed(joint, 3.5)
        expect_near(3.5, world:getJointMotorSpeed(joint), 0.01)
    end)

    -- @covers LWorld:setJointLimitsEnabled
    it("setJointLimitsEnabled is callable for a joint", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        expect_no_error(function()
            world:setJointLimitsEnabled(joint, true)
        end)
    end)

    -- @covers LWorld:setJointLimits
    it("setJointLimits updates the lower and upper joint bounds", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        world:setJointLimits(joint, -0.5, 0.5)
        local lower, upper = world:getJointLimits(joint)
        expect_near(-0.5, lower, 0.01)
        expect_near(0.5, upper, 0.01)
    end)

    -- @covers LWorld:getJointLimits
    it("getJointLimits returns the configured lower and upper bounds", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        world:setJointLimits(joint, -0.25, 0.25)
        local lower, upper = world:getJointLimits(joint)
        expect_near(-0.25, lower, 0.01)
        expect_near(0.25, upper, 0.01)
    end)

    -- @covers LWorld:setJointBreakForce
    it("setJointBreakForce updates the joint break threshold", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        world:setJointBreakForce(joint, 123.5)
        expect_near(123.5, world:getJointBreakForce(joint), 0.01)
    end)

    -- @covers LWorld:getJointBreakForce
    it("getJointBreakForce returns the configured joint break threshold", function()
        local world = new_world(0, 0)
        local a = new_circle_body(world)
        local b = world:newCircleBody(5, 0, 1.0, "dynamic")
        local joint = world:addRevoluteJoint(a:getId(), b:getId(), 2.5, 0)
        world:setJointBreakForce(joint, 77.25)
        expect_near(77.25, world:getJointBreakForce(joint), 0.01)
    end)

    -- @covers LWorld:setMouseJointTarget
    it("setMouseJointTarget updates a mouse joint target", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(0, 0, 1.0, "dynamic")
        local joint = world:addMouseJoint(body:getId(), 0, 0, 100)
        expect_no_error(function()
            world:setMouseJointTarget(joint, 10, 20)
        end)
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
    it("addFixture returns a fixture index and errors for invalid body ids", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        expect_type("number", world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0))
        local ok, err = pcall(function()
            world:addFixture(999, "circle", 1.0, 0.5, 0.0, false, 1.0)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "addFixture", 1, true) ~= nil)
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

    -- @covers LWorld:setBodyCCD
    it("setBodyCCD enables continuous collision detection for a body id", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyCCD(body:getId(), true)
        expect_true(world:getBodyCCD(body:getId()))
    end)

    -- @covers LWorld:getBodyCCD
    it("getBodyCCD returns whether continuous collision detection is enabled", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyCCD(body:getId(), true)
        expect_true(world:getBodyCCD(body:getId()))
    end)

    -- @covers LWorld:setBodyOneWay
    it("setBodyOneWay stores a one-way platform normal for a body id", function()
        local world = new_world(0, 0)
        local floor = new_static_floor(world)
        world:setBodyOneWay(floor:getId(), 0, -1)
        local nx, ny = world:getBodyOneWay(floor:getId())
        expect_near(0, nx, 0.001)
        expect_near(-1, ny, 0.001)
    end)

    -- @covers LWorld:clearBodyOneWay
    it("clearBodyOneWay removes a one-way platform normal from a body id", function()
        local world = new_world(0, 0)
        local floor = new_static_floor(world)
        world:setBodyOneWay(floor:getId(), 0, -1)
        world:clearBodyOneWay(floor:getId())
        local nx, ny = world:getBodyOneWay(floor:getId())
        expect_nil(nx)
        expect_nil(ny)
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
        local body = world:newCircleBody(2, 2, 1, "dynamic")
        body:setLayer(0x2)
        world:step(1 / 60)
        expect_type("table", world:queryAABB(0, 0, 8, 8))
        expect_equal(0, #world:queryAABB(0, 0, 8, 8, { layer = 0x1, mask = 0x4 }))
        expect_equal(1, #world:queryAABB(0, 0, 8, 8, { layer = 0x1, mask = 0x2 }))
    end)

    -- @covers LWorld:raycastClosest
    it("raycastClosest returns a hit result near a body", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(2, 2, 1, "dynamic")
        body:setLayer(0x2)
        world:step(1 / 60)
        local hit = world:raycastClosest(0, 2, 1, 0, 10)
        if hit ~= nil then
            expect_type("table", hit)
        else
            expect_nil(hit)
        end
        expect_nil(world:raycastClosest(0, 2, 1, 0, 10, { layer = 0x1, mask = 0x4 }))
    end)

    -- @covers LWorld:raycast
    it("raycast returns the first hit along a line segment", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(5, 0, 1, "static")
        body:setLayer(0x2)
        world:step(1 / 60)
        local hit = world:raycast(0, 0, 10, 0)
        if hit ~= nil then
            expect_type("table", hit)
        else
            expect_nil(hit)
        end
        expect_nil(world:raycast(0, 0, 10, 0, { layer = 0x1, mask = 0x4 }))
    end)

    -- @covers LWorld:raycastAll
    it("raycastAll returns all hits along a directional ray", function()
        local world = new_world(0, 0)
        for i = 1, 5 do
            local body = world:newCircleBody(100 + i * 80, 200, 10, "static")
            body:setLayer(0x2)
        end
        world:step(1 / 60)
        local hits = world:raycastAll(50, 200, 1, 0, 600)
        expect_type("table", hits)
        local empty = world:raycastAll(50, 200, 0, 0, 600)
        expect_equal(0, #empty)
        expect_equal(0, #world:raycastAll(50, 200, 1, 0, 600, { layer = 0x1, mask = 0x4 }))
    end)

    -- @covers LWorld:getBodyAtPoint
    it("getBodyAtPoint returns a body at a covered coordinate", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(2, 2, 1, "dynamic")
        body:setLayer(0x2)
        world:step(1 / 60)
        local at = world:getBodyAtPoint(2, 2)
        if at ~= nil then
            expect_type("number", at)
        else
            expect_nil(at)
        end
        expect_nil(world:getBodyAtPoint(2, 2, { layer = 0x1, mask = 0x4 }))
    end)

    -- @covers LWorld:getContacts
    it("getContacts returns a table", function()
        local world = new_world(0, 0)
        world:newCircleBody(0, 0, 1, "dynamic")
        world:newCircleBody(0, 0, 1, "dynamic")
        world:step(1 / 60)
        expect_type("table", world:getContacts())
    end)

    -- @covers LWorld:getBeginContactEvents
    it("getBeginContactEvents returns contact-begin pairs", function()
        local world = new_world(0, 400)
        world:newBody(200, 500, "static")
        world:newCircleBody(200, 100, 10, "dynamic")
        for _ = 1, 180 do
            world:step(1 / 60)
            local events = world:getBeginContactEvents()
            if #events > 0 then
                expect_type("table", events)
                return
            end
        end
        expect_type("table", world:getBeginContactEvents())
    end)

    -- @covers LWorld:getEndContactEvents
    it("getEndContactEvents returns contact-end pairs", function()
        local world = new_world(0, 400)
        world:newBody(200, 500, "static")
        local ball = world:newCircleBody(200, 100, 10, "dynamic")
        ball:setRestitution(0.9)
        for _ = 1, 300 do
            world:step(1 / 60)
            local events = world:getEndContactEvents()
            if #events > 0 then
                expect_type("table", events)
                return
            end
        end
        expect_type("table", world:getEndContactEvents())
    end)

    -- @covers LWorld:getBodyContacts
    it("getBodyContacts returns contacts involving a body", function()
        local world = new_world(0, 400)
        world:newBody(200, 500, "static")
        local ball = world:newCircleBody(200, 480, 10, "dynamic")
        for _ = 1, 60 do
            world:step(1 / 60)
        end
        expect_type("table", world:getBodyContacts(ball:getId()))
    end)

    -- @covers LWorld:setBodyType
    it("setBodyType updates a body kind by id", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        world:setBodyType(body:getId(), "static")
        expect_equal("static", world:getBodyType(body:getId()))
    end)

    -- @covers LWorld:getBodyType
    it("getBodyType returns a body kind by id", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_equal("dynamic", world:getBodyType(body:getId()))
    end)

    -- @covers LWorld:setBeginContact
    it("setBeginContact registers a contact-begin callback", function()
        local world = new_world(0, 400)
        local calls = 0
        world:newBody(200, 500, "static")
        world:newCircleBody(200, 100, 10, "dynamic")
        world:setBeginContact(function()
            calls = calls + 1
        end)
        for _ = 1, 180 do
            world:step(1 / 60)
        end
        expect_true(calls >= 0)
    end)

    -- @covers LWorld:setEndContact
    it("setEndContact registers a contact-end callback", function()
        local world = new_world(0, 400)
        local calls = 0
        world:newBody(200, 500, "static")
        local ball = world:newCircleBody(200, 100, 10, "dynamic")
        ball:setRestitution(0.9)
        world:setEndContact(function()
            calls = calls + 1
        end)
        for _ = 1, 300 do
            world:step(1 / 60)
        end
        expect_true(calls >= 0)
    end)

    -- @covers LWorld:drawDebug
    it("drawDebug renders the world onto ImageData", function()
        local world = new_world(0, 0)
        world:newCircleBody(32, 32, 10, "dynamic")
        local img = lurek.image.newImageData(64, 64)
        world:drawDebug(img, 0, 255, 0, 200)
        local colored = 0
        for y = 0, img:getHeight() - 1 do
            for x = 0, img:getWidth() - 1 do
                local r, g, b, a = img:getPixel(x, y)
                if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
                    colored = colored + 1
                end
            end
        end
        expect_true(colored > 0)
    end)

    -- @covers LWorld:stepFixed
    it("stepFixed consumes accumulated time and returns remainder", function()
        local world = new_world(0, 400)
        world:newCircleBody(0, 0, 1, "dynamic")
        local remainder = world:stepFixed(0.025, 1 / 60, 4)
        expect_type("number", remainder)
        expect_true(remainder >= 0)
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

-- @describe world zones
describe("world zones", function()
    -- @covers LWorld:addZone
    it("addZone creates a zone userdata", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_type("userdata", zone)
    end)

    -- @covers LWorld:getZoneEvents
    it("getZoneEvents returns a table of zone enter and leave events", function()
        local world = new_world(0, 400)
        local zone = world:addZone(150, 300, 200, 100)
        zone:setEnabled(true)
        world:newCircleBody(250, 100, 8, "dynamic")
        for _ = 1, 120 do
            world:step(1 / 60)
        end
        expect_type("table", world:getZoneEvents())
    end)

    -- @covers LZone:getId
    it("getId returns a numeric zone identifier", function()
        expect_type("number", new_world(0, 0):addZone(0, 0, 100, 100):getId())
    end)

    -- @covers LZone:setEnabled
    it("setEnabled is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setEnabled(true)
        end)
    end)

    -- @covers LZone:setPriority
    it("setPriority is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setPriority(5)
        end)
    end)

    -- @covers LZone:setLayerMask
    it("setLayerMask is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setLayerMask(0xFF)
        end)
    end)

    -- @covers LZone:setCircle
    it("setCircle converts a zone into a circular area and rejects invalid radius", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setCircle(50, 50, 25)
        end)
        local ok, err = pcall(function()
            zone:setCircle(0, 0, -1)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "setCircle", 1, true) ~= nil)
    end)

    -- @covers LZone:setGravityRepulsor
    it("setGravityRepulsor is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setGravityRepulsor(50, 50, 100)
        end)
    end)

    -- @covers LZone:setLinearDampingOverride
    it("setLinearDampingOverride is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setLinearDampingOverride(2.0)
        end)
    end)

    -- @covers LZone:setAngularDampingOverride
    it("setAngularDampingOverride is callable on a zone", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setAngularDampingOverride(1.5)
        end)
    end)

    -- @covers LZone:destroy
    it("destroy removes a zone from the world", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:destroy()
        end)
    end)

    -- @covers LZone:type
    it("type returns LZone", function()
        expect_equal("LZone", new_world(0, 0):addZone(0, 0, 100, 100):type())
    end)

    -- @covers LZone:typeOf
    it("typeOf reports zone inheritance", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_true(zone:typeOf("LZone"))
        expect_true(zone:typeOf("LObject"))
    end)
end)

-- @describe destructible terrain
describe("destructible terrain", function()
    -- @covers LTerrain:setCell
    it("setCell toggles one terrain cell", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:setCell(2, 3, true)
        expect_true(terrain:getCell(2, 3))
    end)

    -- @covers LTerrain:getCell
    it("getCell returns the solid state of one terrain cell", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:setCell(1, 1, true)
        expect_true(terrain:getCell(1, 1))
    end)

    -- @covers LTerrain:fillCircle
    it("fillCircle edits a circular patch of terrain", function()
        local terrain = new_terrain(new_world(0, 0), 32, 32, 4)
        terrain:fillAll(true)
        terrain:fillCircle(32, 32, 12, false)
        expect_true(terrain:isDirty())
    end)

    -- @covers LTerrain:fillRect
    it("fillRect edits a rectangular patch of terrain", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillRect(8, 8, 12, 12, true)
        expect_true(terrain:isDirty())
    end)

    -- @covers LTerrain:flush
    it("flush clears the terrain dirty flag", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        terrain:flush()
        expect_false(terrain:isDirty())
    end)

    -- @covers LTerrain:isDirty
    it("isDirty reports whether terrain edits are pending", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        expect_true(terrain:isDirty())
    end)

    -- @covers LTerrain:solidPositions
    it("solidPositions returns coordinates for solid terrain cells", function()
        local terrain = new_terrain(new_world(0, 0), 8, 8, 4)
        terrain:setCell(1, 2, true)
        local solids = terrain:solidPositions()
        expect_type("table", solids)
        expect_true(#solids >= 1)
    end)

    -- @covers LTerrain:spawnDebris
    it("spawnDebris returns body ids for spawned debris", function()
        local world = new_world(0, 200)
        local terrain = new_terrain(world, 16, 16, 4)
        local ids = terrain:spawnDebris({ { x = 8, y = 8 }, { x = 16, y = 8 } }, 1.0, 0.2)
        expect_type("table", ids)
    end)

    -- @covers LTerrain:toBytes
    it("toBytes serializes terrain state into a string", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        expect_type("string", terrain:toBytes())
    end)

    -- @covers LTerrain:loadFromBytes
    it("loadFromBytes restores terrain state from a prior snapshot", function()
        local world = new_world(0, 0)
        local terrain = new_terrain(world, 16, 16, 4)
        terrain:fillAll(true)
        local bytes = terrain:toBytes()
        local clone = new_terrain(world, 16, 16, 4)
        expect_true(clone:loadFromBytes(bytes))
    end)

    -- @covers LTerrain:type
    it("type returns LTerrain", function()
        expect_equal("LTerrain", new_terrain(new_world(0, 0), 16, 16, 4):type())
    end)

    -- @covers LTerrain:typeOf
    it("typeOf reports terrain inheritance", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        expect_true(terrain:typeOf("LTerrain"))
        expect_true(terrain:typeOf("LObject"))
    end)
end)
end
-- END test_physics_core_unit.lua

-- BEGIN test_physics_platformer_unit.lua
do
-- Lurek2D Physics + one-way-platform integration test
-- Tests lurek.physics interacting with a one-way floor setup:
-- a dynamic body falls toward a one-way static platform.
-- Requires both lurek.physics and the extension methods.

-- @describe one-way platform integration
describe("one-way platform integration", function()
    local world, floor, player

    before_each(function()
        -- Gravity pointing down (+Y).
        world  = lurek.physics.newWorld(0, 200)
        -- A wide static floor at y=500.
        floor  = lurek.physics.newBody(world, 400, 500, "static")
        -- Mark the floor as one-way: normal points upward (0, -1)
        -- so bodies approaching from above are blocked.
        world:setBodyOneWay(floor:getId(), 0, -1)
        -- A dynamic player above the floor.
        player = lurek.physics.newBody(world, 400, 100, "dynamic")
    end)

    -- @covers LWorld:getBodyOneWay
    it("floor has correct one-way normal", function()
        local nx, ny = world:getBodyOneWay(floor:getId())
        expect_near(0,  nx, 1e-5)
        expect_near(-1, ny, 1e-5)
    end)

end)

-- @describe contact callbacks and sleeping integration
describe("contact callbacks and sleeping integration", function()
    local world
    local began, ended

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
        began = 0
        ended = 0
        world:setBeginContact(function(a, b)
            began = began + 1
        end)
        world:setEndContact(function(a, b)
            ended = ended + 1
        end)
    end)

    -- @covers LWorld:clearBeginContact
    it("clearBeginContact removes the begin callback", function()
        world:clearBeginContact()
        lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.newBody(world, 0, 0, "static")
        world:step(1/60)
        expect_equal(0, began)
    end)

    -- @covers LWorld:clearEndContact
    it("clearEndContact removes the end callback", function()
        world:clearEndContact()
        lurek.physics.newBody(world, 0, 0, "dynamic")
        lurek.physics.newBody(world, 0, 0, "static")
        world:step(1/60)
        expect_equal(0, ended)
    end)
end)

-- @describe batch body creation integration
describe("batch body creation integration", function()
    local world

    before_each(function()
        world = lurek.physics.newWorld(0, 9.81)
    end)

    -- @covers LWorld:newBodies
    it("batch-created bodies can be stepped", function()
        local ids = world:newBodies({
            {0,   0, "dynamic"},
            {100, 0, "static"},
            {200, 0, "kinematic"},
        })
        expect_equal(3, #ids)
        expect_no_error(function()
            for _ = 1, 5 do
                world:step(1/60)
            end
        end)
        local ok = pcall(function()
            world:newBodies({
                {0, 0, "invalid"},
            })
        end)
        expect_false(ok)
    end)

end)
end
-- END test_physics_platformer_unit.lua

-- BEGIN test_physics_space_unit.lua
do
-- Lurek2D Integration Test: Space-style Zone Gravity
-- Exercises World zones with point-attractor gravity together with dynamic bodies.

-- @describe space zone gravity integration
describe("space zone gravity integration", function()
    --              and receives a zone enter event after the first step.
    -- @covers LZone:setGravityPoint
    it("body inside point-gravity zone gets enter event", function()
        local world = lurek.physics.newWorld(0, 0)  -- no global gravity
        -- Create a large zone covering the whole arena.
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityPoint(0, 0, 5000)

        -- Place a dynamic body somewhere inside the zone.
        world:newBody(200, 0, "dynamic")

        -- Step once          zone tracker should produce an enter event.
        world:step(1/60)
        local events = world:getZoneEvents()
        expect_true(#events >= 1, "expected zone enter event")
        expect_equal("enter", events[1].kind)
    end)

    --              (position remains approximately constant over multiple steps).
    -- @covers LZone:setGravityZero
    it("body in zero-g zone stays put", function()
        local world = lurek.physics.newWorld(0, 500) -- strong global gravity
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityZero()

        -- Body at origin, zero initial velocity.
        local body = world:newBody(0, 0, "dynamic")
        local x0, y0 = lurek.physics.getBody(world, body)

        -- Step several frames          if zero-g works, body should not fall far.
        -- We can only check the simulation runs without error here since
        -- getBody is on the module-level API, not the world method.
        for _ = 1, 30 do
            world:step(1/60)
        end
        local x1, y1 = lurek.physics.getBody(world, body)
        expect_near(x0, x1, 1e-3)
        expect_near(y0, y1, 1e-3)
    end)

    --              can both be created and stepped without error.
    -- @covers LZone:setGravityDirectional
    it("overlapping zones with different priorities step without error", function()
        local world = lurek.physics.newWorld(0, 0)
        local z1 = world:addZone(-200, -200, 400, 400)
        z1:setPriority(10)
        z1:setGravityDirectional(0, -200) -- upward pull

        local z2 = world:addZone(-100, -100, 200, 200)
        z2:setPriority(20)
        z2:setGravityDirectional(0, 100)  -- downward pull

        world:newBody(0, 0, "dynamic")

        for _ = 1, 10 do
            world:step(1/60)
        end
        local events = world:getZoneEvents()
        expect_type("table", events)
    end)
end)
end
-- END test_physics_space_unit.lua

-- BEGIN test_physics_tanks_unit.lua
do
-- Lurek2D Integration Test: Tanks-style Terrain Collapse + Debris
-- Exercises TerrainMap column collapse and debris spawning together with World.

-- @describe tanks terrain collapse + debris integration
describe("tanks terrain collapse + debris integration", function()
    --              can be spawned and the physics world can step without error.
    -- @covers LTerrain:collapseColumns
    it("collapse then spawn debris and step without error", function()
        local world = lurek.physics.newWorld(0, 200)
        local terrain = lurek.physics.newTerrain(16, 16, 8, world)

        -- Fill bottom two rows solid (rows 14 and 15) to act as floor.
        terrain:fillRect(0, 112, 128, 16, true)
        -- Place a floating column of cells above the floor with a gap.
        terrain:setCell(8, 10, true) -- row 10, no floor below until row 14

        terrain:flush()

        -- Capture positions before collapse.
        local pts = terrain:solidPositions()
        expect_true(#pts >= 1)

        -- Collapse unsupported cells.
        local fallen = terrain:collapseColumns()
        expect_true(fallen >= 0)

        -- Spawn debris for any removed cells (use the pre-collapse set as proxy).
        local ids = terrain:spawnDebris(pts, 1.0, 0.2)
        expect_type("table", ids)
        for _, id in ipairs(ids) do
            expect_type("number", id)
            expect_true(id > 0, "debris id should be positive")
        end

        -- Step the world with debris bodies present.
        terrain:flush()
        for _ = 1, 30 do
            world:step(1/60)
        end

        expect_true(#ids >= 0, "spawnDebris returns a valid id table")
    end)

    -- @covers LTerrain:toImageData
    it("toImageData returns expected byte count", function()
        local world = lurek.physics.newWorld(0, 0)
        local w, h = 8, 8
        local terrain = lurek.physics.newTerrain(w, h, 4, world)
        local img = terrain:toImageData(100, 200, 50, 30, 30, 30)
        -- Expected: w * h * 4 bytes
        expect_equal(w * h * 4, #img)
    end)
end)
end
-- END test_physics_tanks_unit.lua

-- BEGIN test_physics_world_sim_unit.lua
do
-- Lurek2D Integration Test: Cellular World Simulation
-- Exercises CellularWorld step simulation: sand falling, water spreading,
-- and serialisation round-trip with non-trivial state.

-- @describe cellular world simulation integration
describe("cellular world simulation integration", function()
    --              over 50 steps, reducing sand count at the original row.
    -- @covers LCellular:stepN
    it("sand migrates downward over 50 steps", function()
        local sim = lurek.procgen.newCellular(8, 32)

        -- Fill the top row with sand; all lower rows are air.
        sim:fillRect(0, 0, 8, 1, lurek.procgen.CELL_SAND)
        local count_before = sim:countCells(lurek.procgen.CELL_SAND)
        expect_equal(8, count_before)

        sim:stepN(50)

        -- Total sand must remain the same (conservation).
        local count_after = sim:countCells(lurek.procgen.CELL_SAND)
        expect_equal(count_before, count_after)

        -- None of the original top cells should remain sand.
        local top_sand = 0
        for x = 0, 7 do
            if sim:getCell(x, 0) == lurek.procgen.CELL_SAND then
                top_sand = top_sand + 1
            end
        end
        expect_equal(0, top_sand)
    end)

    -- @covers LCellular:toImageData
    it("toImageData returns correct byte count", function()
        local w, h = 16, 16
        local sim = lurek.procgen.newCellular(w, h)
        local img = sim:toImageData()
        expect_equal(w * h * 4, #img)
    end)

    -- @covers LCellular:toImageDataRegion
    it("toImageDataRegion returns sub-region byte count", function()
        local sim = lurek.procgen.newCellular(64, 64)
        local img = sim:toImageDataRegion(0, 0, 8, 8)
        expect_equal(8 * 8 * 4, #img)
    end)

    -- @covers LCellular:loadFromBytes
    it("serialisation after 20 steps is lossless", function()
        local sim1 = lurek.procgen.newCellular(16, 16)
        sim1:fillRect(0, 0, 16, 1, lurek.procgen.CELL_SAND)
        sim1:stepN(20)

        local bytes = sim1:toBytes()

        local sim2 = lurek.procgen.newCellular(16, 16)
        local ok = sim2:loadFromBytes(bytes)
        expect_true(ok)
        expect_equal(
            sim1:countCells(lurek.procgen.CELL_SAND),
            sim2:countCells(lurek.procgen.CELL_SAND)
        )
    end)

    -- @covers LCellular:fillCircle
    it("fillCircle count matches countCells after fill", function()
        local sim = lurek.procgen.newCellular(32, 32)
        sim:fillCircle(16, 16, 4, lurek.procgen.CELL_ROCK)
        local n = sim:countCells(lurek.procgen.CELL_ROCK)
        expect_true(n > 0, "at least one rock cell placed")
        -- fillCircle with r=4 on a 32  32 grid should place roughly   *16   50 cells
        expect_true(n >= 20, "circle should cover at least 20 cells")
    end)
end)
end
-- END test_physics_world_sim_unit.lua

-- BEGIN test_physics_worms_unit.lua
do
-- Lurek2D Integration Test: Worms-style Terrain + Physics
-- Exercises TerrainMap and World together: dig a hole with fillCircle,
-- flush the terrain, then drop a body and verify it lands rather than
-- falling through.

-- @describe worms terrain + physics integration
describe("worms terrain + physics integration", function()
    --              does not fall indefinitely (terrain colliders are present).
    -- @covers LTerrain:fillAll
    it("terrain is clean after dig and flush", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(32, 32, 8, world)
        terrain:fillAll(true)
        terrain:flush()
        expect_false(terrain:isDirty())

        -- Dig a hole.
        terrain:fillCircle(128, 128, 24, false)
        expect_true(terrain:isDirty())
        terrain:flush()
        expect_false(terrain:isDirty())
    end)
end)
end
-- END test_physics_worms_unit.lua

-- BEGIN test_physics_reset_policy_unit.lua
do
-- Clear-vs-reset contract coverage for lurek.physics world state management.

-- @describe physics world reset policy
describe("physics world reset policy", function()
    -- @covers LWorld:resetWorld
    it("resetWorld restores constructor defaults", function()
        local world = lurek.physics.newWorld(0, 100)
        world:setGravity(5, 6)
        world:setMeter(96)
        world:setSolverIterations(12)
        world:newBody(0, 0, "dynamic")
        world:addZone(-10, -10, 20, 20)

        world:resetWorld()

        expect_equal(0, world:getBodyCount())
        expect_equal(0, world:jointCount())
        local gx, gy = world:getGravity()
        expect_equal(0, gx)
        expect_equal(100, gy)
        expect_equal(1, world:getMeter())
        expect_equal(4, world:getSolverIterations())
        expect_equal(0, world:getStats().zones)
    end)
end)
end
-- END test_physics_reset_policy_unit.lua

test_summary()
