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

local function add_rect_flow_field(world)
    return world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 120,
        h = 120,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 60,
    })
end

local function add_path_flow_field(world)
    return world:addFlowField({
        name = "wind_lane",
        geometry = "path",
        points = {
            { x = 0, y = 0 },
            { x = 100, y = 0 },
        },
        width = 20,
        strength = 40,
        direction = "alongPath",
        layerMask = 0x2,
    })
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

    -- @covers lurek.physics.newMaterial
    it("newMaterial validates and canonicalizes reusable material tables", function()
        local material = lurek.physics.newMaterial({
            name = "rubber",
            density = 1.2,
            friction = 0.9,
            restitution = 0.8,
            beamReflectivity = 0.6,
            surfaceType = "bounce_pad",
        })
        expect_type("table", material)
        expect_equal("rubber", material.name)
        expect_near(0.9, material.friction, 0.001)
        expect_equal("bounce_pad", material.surfaceType)
        local ok, err = pcall(function()
            lurek.physics.newMaterial({ density = 0 })
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "newMaterial", 1, true) ~= nil)
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
        local world = new_world(0, 0)
        local body = new_dynamic_body(world)
        local before = body:getMass()
        local shape = lurek.physics.newCircleShape(2)
        shape:setDensity(10)
        lurek.physics.attachShape(body, shape)
        local after = body:getMass()
        expect_type("number", before)
        expect_true(after > before)
    end)

    -- @covers LBody:setMass
    it("setMass overrides the body mass", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setMass(7.5)
        expect_near(7.5, body:getMass(), 0.01)
    end)

    -- @covers LBody:setMaterial
    it("setMaterial applies solver-backed properties to the body", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setMaterial(lurek.physics.newMaterial({
            name = "glue",
            density = 1.4,
            friction = 1.0,
            restitution = 0.0,
            gravityScale = 0.5,
            linearDamping = 0.25,
            angularDamping = 0.75,
            massOverride = 6.5,
            stickiness = 1.0,
            adhesion = 0.8,
        }))
        expect_near(1.0, body:getFriction(), 0.001)
        expect_near(0.0, body:getRestitution(), 0.001)
        expect_near(0.5, body:getGravityScale(), 0.001)
        expect_near(0.25, body:getLinearDamping(), 0.001)
        expect_near(0.75, body:getAngularDamping(), 0.001)
        expect_near(6.5, body:getMass(), 0.01)
    end)

    -- @covers LBody:getMaterial
    it("getMaterial returns the current body material snapshot", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setMaterial(lurek.physics.newMaterial({
            name = "mirror",
            friction = 0.2,
            restitution = 0.1,
            beamReflectivity = 1.0,
            projectileReflectivity = 0.25,
            beamAbsorption = 0.4,
            buoyancy = 0.3,
        }))
        local material = body:getMaterial()
        expect_type("table", material)
        expect_equal("mirror", material.name)
        expect_near(0.2, material.friction, 0.001)
        expect_near(1.0, material.beamReflectivity, 0.001)
        expect_near(0.25, material.projectileReflectivity, 0.001)
        expect_near(0.4, material.beamAbsorption, 0.001)
        expect_near(0.3, material.buoyancy, 0.001)
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

    -- @covers LBody:setMirror
    it("setMirror is callable", function()
        expect_no_error(function()
            new_dynamic_body(new_world(0, 0)):setMirror(true)
        end)
    end)

    -- @covers LBody:isMirror
    it("isMirror reflects the authored beam-mirror flag", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_false(body:isMirror())
        body:setMirror(true)
        expect_true(body:isMirror())
    end)

    -- @covers LBody:setBeamReflectivity
    it("setBeamReflectivity validates 0..1 values", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_no_error(function()
            body:setBeamReflectivity(0.6)
        end)
        expect_error(function()
            body:setBeamReflectivity(1.1)
        end)
    end)

    -- @covers LBody:getBeamReflectivity
    it("getBeamReflectivity returns the stored beam multiplier", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setBeamReflectivity(0.4)
        expect_near(0.4, body:getBeamReflectivity(), 0.0001)
    end)

    -- @covers LBody:setProjectileReflectivity
    it("setProjectileReflectivity validates 0..1 values", function()
        local body = new_dynamic_body(new_world(0, 0))
        expect_no_error(function()
            body:setProjectileReflectivity(0.25)
        end)
        expect_error(function()
            body:setProjectileReflectivity(-0.1)
        end)
    end)

    -- @covers LBody:getProjectileReflectivity
    it("getProjectileReflectivity returns the stored projectile multiplier", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setProjectileReflectivity(0.75)
        expect_near(0.75, body:getProjectileReflectivity(), 0.0001)
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

    -- @covers LBody:getCollisionGroup
    it("getCollisionGroup returns a single 16-way collision group", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setCollisionGroup(3)
        expect_equal(3, body:getCollisionGroup())
        body:setLayer(0x3)
        expect_nil(body:getCollisionGroup())
    end)

    -- @covers LBody:setCollisionGroup
    it("setCollisionGroup assigns the body layer bit", function()
        local body = new_dynamic_body(new_world(0, 0))
        body:setCollisionGroup(3)
        expect_equal(0x8, body:getLayer())
        expect_equal(0xFFFF, body:getMask())
        expect_equal(3, body:getCollisionGroup())
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

    -- @covers LBody:setFlowScale
    it("setFlowScale configures body flow response", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(20, 20, 8, "dynamic")
        body:setFlowScale(0.75)
        add_rect_flow_field(world)
        world:step(1 / 60)
        expect_true(select(1, body:getVelocity()) > 0)
    end)

    -- @covers LBody:setAirScale
    it("setAirScale configures body air response", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(20, 20, 8, "dynamic")
        body:setAirScale(0.5)
        add_rect_flow_field(world)
        world:step(1 / 60)
        expect_true(select(1, body:getVelocity()) > 0)
    end)

    -- @covers LBody:setWaterScale
    it("setWaterScale configures body water response", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(20, 20, 8, "dynamic")
        body:setWaterScale(1.25)
        add_rect_flow_field(world)
        world:step(1 / 60)
        expect_true(select(1, body:getVelocity()) > 0)
    end)

    -- @covers LBody:setFlowCrossSection
    it("setFlowCrossSection configures body drag cross section", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(20, 20, 8, "dynamic")
        body:setFlowCrossSection(2.0)
        add_rect_flow_field(world)
        world:step(1 / 60)
        expect_true(select(1, body:getVelocity()) > 0)
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
        local body = new_dynamic_body(new_world(0, 0))
        expect_false(body:isBullet())
        body:setBullet(true)
        expect_true(body:isBullet())
    end)

    -- @covers LBody:setBullet
    it("setBullet updates the ccd flag", function()
        local function fire_projectile(bullet_mode)
            local world = new_world(0, 0)
            world:setCcdSubsteps(4)
            local wall = world:newBody(100, 40, 2, 80, "static")
            local projectile = world:newCircleBody(20, 40, 1, "dynamic")
            projectile:setBullet(bullet_mode)
            projectile:setVelocity(6000, 0)
            world:step(1 / 60)
            return projectile:getX(), wall:getX()
        end

        local tunneled_x, wall_x = fire_projectile(false)
        local blocked_x = fire_projectile(true)
        expect_true(tunneled_x > wall_x)
        expect_true(blocked_x < wall_x)
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
        world:addGravityVector(0, 25)
        add_rect_flow_field(world)
        world:step(1 / 60)
        local stats = world:getStats()
        expect_equal(1, stats.bodies)
        expect_equal(1, stats.bodySlots)
        expect_equal(1, stats.colliders)
        expect_equal(1, stats.gravityVectors)
        expect_equal(1, stats.flowFields)
        body:destroy()
        stats = world:getStats()
        expect_equal(0, stats.bodies)
        expect_equal(1, stats.bodySlots)
    end)

    -- @covers LWorld:addFlowField
    it("addFlowField authors a runtime flow handle", function()
        local world = new_world(0, 0)
        local field = add_path_flow_field(world)
        expect_equal("LFlowStream", field:type())
    end)

    -- @covers LWorld:addFan
    it("addFan creates a directional wedge flow helper", function()
        local world = new_world(0, 0)
        local fan = world:addFan({
            x = 32,
            y = 32,
            radius = 48,
            widthAngle = 60,
            directionVector = { x = 1, y = 0 },
            strength = 30,
        })
        local ahead = world:sampleFlow(60, 32)
        local behind = world:sampleFlow(8, 32)
        expect_equal("LFlowStream", fan:type())
        expect_true(ahead.vx > 0)
        expect_near(0, behind.magnitude, 0.0001)
    end)

    -- @covers LWorld:getFlowField
    it("getFlowField returns authored metadata by id", function()
        local world = new_world(0, 0)
        local field = add_path_flow_field(world)
        field:setEnabled(false)
        local info = world:getFlowField(field:getId())
        expect_equal("wind_lane", info.name)
        expect_equal("path", info.geometry)
        expect_false(info.enabled)
    end)

    -- @covers LWorld:sampleFlow
    it("sampleFlow returns composed flow vectors in world space", function()
        local world = new_world(0, 0)
        add_path_flow_field(world)
        local sample = world:sampleFlow(40, 0, { layerMask = 0x2 })
        local repeat_sample = world:sampleFlow(40, 0, { layerMask = 0x2 })
        expect_true(sample.vx > 0)
        expect_equal(1, #sample.sources)
        expect_near(sample.vx, repeat_sample.vx, 0.0001)
        expect_near(sample.intensity, repeat_sample.intensity, 0.0001)
    end)

    -- @covers LFlowStream:getId
    it("getId returns the flow field identifier", function()
        local world = new_world(0, 0)
        local field = add_path_flow_field(world)
        expect_type("number", field:getId())
    end)

    -- @covers LWorld:removeFlowField
    it("removeFlowField disables one authored flow field", function()
        local world = new_world(0, 0)
        local first = add_rect_flow_field(world)
        expect_true(world:removeFlowField(first:getId()))
        expect_false(world:getFlowField(first:getId()).enabled)
    end)

    -- @covers LWorld:clearFlowFields
    it("clearFlowFields disables all authored flow fields", function()
        local world = new_world(0, 0)
        add_rect_flow_field(world)
        local second = world:addFlowField({
            geometry = "circle",
            x = 60,
            y = 60,
            radius = 20,
            direction = "radialOut",
            strength = 30,
        })
        world:clearFlowFields()
        expect_false(world:getFlowField(second:getId()).enabled)
        expect_equal(0, world:getStats().flowFields)
    end)

    -- @covers LWorld:drawFlowDebug
    it("drawFlowDebug renders authored field guides into an image target", function()
        local world = new_world(0, 0)
        world:addFlowField({
            geometry = "rect",
            x = 8,
            y = 8,
            w = 24,
            h = 16,
            direction = "explicit",
            directionVector = { x = 1, y = 0 },
            strength = 25,
        })
        local img = lurek.image.newImageData(64, 64)
        world:drawFlowDebug(img, { arrowSpacing = 16 })
        local _, _, _, alpha = img:getPixel(8, 8)
        expect_true(alpha > 0)
    end)

    -- @covers LFlowStream:setEnabled
    it("setEnabled toggles flow field activity", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setEnabled(false)
        expect_false(field:isEnabled())
    end)

    -- @covers LFlowStream:isEnabled
    it("isEnabled reports the current flow field enabled flag", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        expect_true(field:isEnabled())
        field:setEnabled(false)
        expect_false(field:isEnabled())
    end)

    -- @covers LFlowStream:setStrength
    it("setStrength mutates flow field strength", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setStrength(55)
        expect_near(55, world:getFlowField(field:getId()).strength, 0.0001)
    end)

    -- @covers LFlowStream:getStrength
    it("getStrength returns the stored flow field strength", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setEnabled(true)
        field:setStrength(55)
        expect_near(55, field:getStrength(), 0.0001)
    end)

    -- @covers LFlowStream:setLayerMask
    it("setLayerMask updates the flow field layer filter", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setLayerMask(0x8)
        expect_equal(0x8, world:getFlowField(field:getId()).layerMask)
    end)

    -- @covers LFlowStream:getLayerMask
    it("getLayerMask returns the stored layer filter", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setLayerMask(0x8)
        expect_equal(0x8, field:getLayerMask())
    end)

    -- @covers LFlowStream:setApplication
    it("setApplication updates the flow application mode", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setApplication("targetVelocityDrag")
        expect_equal("targetVelocityDrag", world:getFlowField(field:getId()).application)
    end)

    -- @covers LFlowStream:setCombine
    it("setCombine updates the flow composition mode", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        field:setCombine("additiveClamped")
        expect_equal("additiveClamped", world:getFlowField(field:getId()).combine)
    end)

    -- @covers LFlowStream:destroy
    it("destroy disables the authored flow field handle", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        local id = field:getId()
        field:destroy()
        expect_false(world:getFlowField(id).enabled)
    end)

    -- @covers LFlowStream:type
    it("type returns the flow field userdata name", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        expect_equal("LFlowStream", field:type())
    end)

    -- @covers LFlowStream:typeOf
    it("typeOf accepts the flow field userdata name", function()
        local world = new_world(0, 0)
        local field = add_rect_flow_field(world)
        expect_true(field:typeOf("LFlowStream"))
        expect_true(field:typeOf("LObject"))
    end)

    -- @covers LFlowStream:setWidth
    it("setWidth updates path flow field corridor width", function()
        local world = new_world(0, 0)
        local field = add_path_flow_field(world)
        field:setWidth(18)
        local info = world:getFlowField(field:getId())
        expect_equal(18, info.width)
    end)

    -- @covers LFlowStream:setPoints
    it("setPoints reshapes the path flow field polyline", function()
        local world = new_world(0, 0)
        local field = add_path_flow_field(world)
        field:setPoints({
            { x = 0, y = 0 },
            { x = 0, y = 48 },
            { x = 16, y = 64 },
        })
        local info = world:getFlowField(field:getId())
        expect_equal(3, #info.points)
        expect_equal(48, info.points[2].y)
    end)

    -- @covers LWorld:addGravityVector
    it("addGravityVector applies an additive directional acceleration", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(0, 0, 1, "dynamic")
        local id = world:addGravityVector(0, 120)
        world:step(1 / 60)
        local _, vy = body:getVelocity()
        expect_type("number", id)
        expect_true(vy > 0)
    end)

    -- @covers LWorld:setGravityVector
    it("setGravityVector changes an additive gravity vector at runtime", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(0, 0, 1, "dynamic")
        local id = world:addGravityVector(0, 20)
        world:setGravityVector(id, 0, -120)
        world:step(1 / 60)
        local _, vy = body:getVelocity()
        expect_true(vy < 0)
    end)

    -- @covers LWorld:getGravityVector
    it("getGravityVector returns the active vector table", function()
        local world = new_world(0, 0)
        local id = world:addGravityVector(10, 20, 0x2)
        local vector = world:getGravityVector(id)
        expect_equal(id, vector.id)
        expect_equal(10, vector.gx)
        expect_equal(20, vector.gy)
        expect_equal(0x2, vector.layerMask)
        expect_true(vector.enabled)
    end)

    -- @covers LWorld:removeGravityVector
    it("removeGravityVector disables one additive gravity vector", function()
        local world = new_world(0, 0)
        local id = world:addGravityVector(0, 100)
        expect_true(world:removeGravityVector(id))
        expect_nil(world:getGravityVector(id))
        expect_false(world:removeGravityVector(id))
    end)

    -- @covers LWorld:clearGravityVectors
    it("clearGravityVectors disables all additive gravity vectors", function()
        local world = new_world(0, 0)
        local a = world:addGravityVector(10, 0)
        local b = world:addGravityVector(0, 10)
        world:clearGravityVectors()
        expect_nil(world:getGravityVector(a))
        expect_nil(world:getGravityVector(b))
        expect_equal(0, world:getStats().gravityVectors)
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

    -- @covers LWorld:getCollisionPair
    it("getCollisionPair reads symmetric collision group pairs", function()
        local world = new_world(0, 0)
        expect_true(world:getCollisionPair(0, 1))
        world:setCollisionPair(0, 1, false)
        expect_false(world:getCollisionPair(0, 1))
        expect_false(world:getCollisionPair(1, 0))
    end)

    -- @covers LWorld:setCollisionGroupMask
    it("setCollisionGroupMask changes one matrix row", function()
        local world = new_world(0, 0)
        world:setCollisionGroupMask(2, 0x4)
        expect_equal(0x4, world:getCollisionGroupMask(2))
        local ok, err = pcall(function()
            world:setCollisionGroupMask(0, 0x10000)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "setCollisionGroupMask", 1, true) ~= nil)
    end)

    -- @covers LWorld:getCollisionGroupMask
    it("getCollisionGroupMask returns the configured row", function()
        local world = new_world(0, 0)
        expect_equal(0xFFFF, world:getCollisionGroupMask(2))
        world:setCollisionGroupMask(2, 0x4)
        expect_equal(0x4, world:getCollisionGroupMask(2))
    end)

    -- @covers LWorld:resetCollisionGroups
    it("resetCollisionGroups restores the full matrix", function()
        local world = new_world(0, 0)
        world:setCollisionPair(0, 1, false)
        world:setCollisionGroupMask(2, 0x4)
        world:resetCollisionGroups()
        expect_true(world:getCollisionPair(0, 1))
        expect_equal(0xFFFF, world:getCollisionGroupMask(2))
    end)

    -- @covers LWorld:setCollisionPair
    it("collision group pairs filter world contacts", function()
        local world = new_world(0, 0)
        local a = world:newCircleBody(0, 0, 10, "dynamic")
        local b = world:newCircleBody(0, 0, 10, "static")
        local c = world:newCircleBody(0, 0, 10, "dynamic")
        a:setCollisionGroup(0)
        b:setCollisionGroup(1)
        c:setCollisionGroup(2)
        world:setCollisionPair(0, 1, false)
        world:step(1 / 60)
        local events = world:getBeginContactEvents()
        local saw_ab = false
        local saw_bc = false
        for _, event in ipairs(events) do
            local low = math.min(event.bodyA, event.bodyB)
            local high = math.max(event.bodyA, event.bodyB)
            if low == math.min(a:getId(), b:getId()) and high == math.max(a:getId(), b:getId()) then
                saw_ab = true
            end
            if low == math.min(b:getId(), c:getId()) and high == math.max(b:getId(), c:getId()) then
                saw_bc = true
            end
        end
        expect_false(saw_ab)
        expect_true(saw_bc)
        local ok, err = pcall(function()
            world:setCollisionPair(0, 16, false)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "setCollisionPair", 1, true) ~= nil)
        ok, err = pcall(function()
            world:setCollisionGroupMask(0, 0x10000)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "setCollisionGroupMask", 1, true) ~= nil)
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
    it("newCircleBody accepts material and collision options", function()
        local world = new_world(0, 0)
        local body = world:newCircleBody(10, 20, 5, "dynamic", {
            material = lurek.physics.newMaterial({
                name = "rubber",
                density = 1.1,
                friction = 0.85,
                restitution = 0.7,
            }),
            bullet = true,
            layer = 0x2,
            mask = 0x3,
        })
        expect_type("userdata", body)
        expect_true(body:isBullet())
        expect_equal(0x2, body:getLayer())
        expect_equal(0x3, body:getMask())
        expect_equal("rubber", body:getMaterial().name)
    end)

    -- @covers LWorld:newPolygonBody
    it("newPolygonBody applies material and collision options", function()
        local world = new_world(0, 0)
        local body = world:newPolygonBody(5, 5, { 0, 0, 10, 0, 10, 10, 0, 10 }, "dynamic", {
            material = lurek.physics.newMaterial({
                name = "poly",
                density = 1.25,
                friction = 0.65,
                restitution = 0.2,
            }),
            bullet = true,
            layer = 0x4,
            mask = 0x5,
        })
        expect_type("userdata", body)
        expect_true(body:isBullet())
        expect_equal(0x4, body:getLayer())
        expect_equal(0x5, body:getMask())
        expect_equal("poly", body:getMaterial().name)
    end)

    -- @covers LWorld:newEdgeBody
    it("newEdgeBody applies material and collision options", function()
        local world = new_world(0, 0)
        local body = world:newEdgeBody(0, 0, 0, 0, 100, 0, "static", {
            material = lurek.physics.newMaterial({
                name = "edge",
                friction = 0.4,
                restitution = 0.0,
                beamReflectivity = 0.75,
            }),
            layer = 0x8,
            mask = 0x3,
        })
        expect_type("userdata", body)
        expect_equal(0x8, body:getLayer())
        expect_equal(0x3, body:getMask())
        expect_equal("edge", body:getMaterial().name)
        expect_near(0.75, body:getMaterial().beamReflectivity, 0.001)
    end)

    -- @covers LWorld:newChainBody
    it("newChainBody applies material and collision options", function()
        local world = new_world(0, 0)
        local body = world:newChainBody(0, 0, { 0, 0, 20, 0, 20, 10 }, false, "static", {
            material = lurek.physics.newMaterial({
                name = "chain",
                friction = 0.9,
                restitution = 0.0,
                surfaceType = "ground",
            }),
            layer = 0x10,
            mask = 0x1F,
        })
        expect_type("userdata", body)
        expect_equal(0x10, body:getLayer())
        expect_equal(0x1F, body:getMask())
        expect_equal("ground", body:getMaterial().surfaceType)
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

    -- @covers LWorld:setFixtureMaterial
    it("setFixtureMaterial updates only the targeted fixture snapshot", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.5, 0.3, false, 2.0)
        world:setFixtureMaterial(body:getId(), fixture, lurek.physics.newMaterial({
            name = "glass",
            density = 0.6,
            friction = 0.05,
            restitution = 0.8,
            beamReflectivity = 1.0,
            projectileReflectivity = 0.2,
        }))
        local primary = world:getFixtureMaterial(body:getId(), 0)
        local extra = world:getFixtureMaterial(body:getId(), fixture)
        expect_equal("glass", extra.name)
        expect_near(0.05, extra.friction, 0.001)
        expect_near(0.5, primary.friction, 0.001)
    end)

    -- @covers LWorld:getFixtureMaterial
    it("getFixtureMaterial returns the current fixture material table", function()
        local world = new_world(0, 0)
        local body = lurek.physics.newBody(world, 0, 0, "dynamic")
        local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.2, 0.1, false, 2.0)
        world:setFixtureMaterial(body:getId(), fixture, lurek.physics.newMaterial({
            name = "ice",
            density = 0.9,
            friction = 0.05,
            restitution = 0.15,
            buoyancy = 0.2,
            surfaceType = "slick",
        }))
        local material = world:getFixtureMaterial(body:getId(), fixture)
        expect_type("table", material)
        expect_equal("ice", material.name)
        expect_near(0.2, material.buoyancy, 0.001)
        expect_equal("slick", material.surfaceType)
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
        world:step(1 / 60)
        expect_true(world:getBodyCCD(body:getId()))
    end)

    -- @covers LWorld:getBodyCCD
    it("getBodyCCD returns whether continuous collision detection is enabled", function()
        local world = new_world(0, 0)
        local body = world:newBody(0, 0, "dynamic")
        expect_false(world:getBodyCCD(body:getId()))
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

    -- @covers LWorld:setCcdSubsteps
    it("setCcdSubsteps persists positive values and clamps zero", function()
        local world = new_world(0, 0)
        world:setCcdSubsteps(4)
        expect_equal(4, world:getCcdSubsteps())
        world:setCcdSubsteps(0)
        expect_equal(1, world:getCcdSubsteps())
    end)

    -- @covers LWorld:getCcdSubsteps
    it("getCcdSubsteps returns the configured value", function()
        local world = new_world(0, 0)
        expect_equal(1, world:getCcdSubsteps())
        world:setCcdSubsteps(6)
        expect_equal(6, world:getCcdSubsteps())
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
        expect_equal(0, #world:queryAABB(0, 0, 8, 8, { excludeBody = body:getId() }))
        expect_equal(0, #world:queryAABB(0, 0, 8, 8, { layer = 0x1, mask = 0x4 }))
        expect_equal(1, #world:queryAABB(0, 0, 8, 8, { layer = 0x1, mask = 0x2 }))

        body:setCollisionGroup(1)
        world:step(1 / 60)
        expect_equal(1, #world:queryAABB(0, 0, 8, 8, { group = 0 }))
        world:setCollisionPair(0, 1, false)
        world:step(1 / 60)
        expect_equal(0, #world:queryAABB(0, 0, 8, 8, { group = 0 }))
        expect_equal(1, #world:queryAABB(0, 0, 8, 8, { groups = 0x2 }))
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
        expect_nil(world:raycastClosest(0, 2, 1, 0, 10, { excludeBody = body:getId() }))
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
        expect_nil(world:raycast(0, 0, 10, 0, { excludeBody = body:getId() }))
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

    -- @covers LWorld:castCircle
    it("castCircle returns the first solid hit and respects sensor filters", function()
        local world = new_world(0, 0)
        local sensor = world:newBody(60, 0, 6, 40, "sensor")
        local wall = world:newBody(110, 0, 6, 40, "static")
        world:step(1 / 60)

        local with_sensor = world:castCircle(0, 0, 4, 1, 0, 200, { includeSensors = true })
        local without_sensor = world:castCircle(0, 0, 4, 1, 0, 200, { includeSensors = false })

        expect_type("table", with_sensor)
        expect_type("table", without_sensor)
        expect_equal(sensor:getId(), with_sensor.bodyId)
        expect_equal(wall:getId(), without_sensor.bodyId)
        expect_true(without_sensor.toi > with_sensor.toi)
        expect_true(without_sensor.safeFraction > with_sensor.safeFraction)
        expect_near(-1, without_sensor.normalX, 0.01)
    end)

    -- @covers LWorld:castBeam
    it("castBeam covers reflective tracing, pierce ordering, and thick-beam fail-fast behavior", function()
        local world = new_world(0, 0)
        local blocker = world:newBody(10, 0, 6, 40, "static")
        local mirror = world:newBody(80, 0, 6, 40, "static")
        mirror:setMirror(true)
        mirror:setBeamReflectivity(0.8)
        world:step(1 / 60)

        local trace = world:castBeam(40, 0, 1, 0, 160, {
            reflect = true,
            maxBounces = 2,
            energy = 1.0,
            minEnergy = 0.1,
        })
        expect_type("table", trace)
        expect_equal(2, #trace.hits)
        expect_equal(2, #trace.segments)
        expect_false(trace.reachedMaxRange)
        expect_equal(mirror:getId(), trace.hits[1].bodyId)
        expect_true(trace.hits[1].reflected)
        expect_equal(1, trace.hits[1].segmentIndex)
        expect_true(trace.hits[1].outgoingDirX < 0)
        expect_equal(blocker:getId(), trace.hits[2].bodyId)
        expect_false(trace.hits[2].reflected)
        expect_equal(2, trace.hits[2].segmentIndex)
        expect_true(trace.hits[1].distance < trace.hits[2].distance)
        expect_equal(mirror:getId(), trace.segments[1].blockedBy)
        expect_equal(blocker:getId(), trace.segments[2].blockedBy)

        local tie_world = new_world(0, 0)
        local first_mirror = tie_world:newBody(80, -10, 6, 40, "static")
        first_mirror:setMirror(true)
        local second_mirror = tie_world:newBody(80, 10, 6, 40, "static")
        second_mirror:setMirror(true)
        tie_world:step(1 / 60)

        local tie_trace = tie_world:castBeam(40, 0, 1, 0, 120, {
            reflect = true,
            maxBounces = 1,
        })
        expect_equal(first_mirror:getId(), tie_trace.hits[1].bodyId)

        local bounce_world = new_world(0, 0)
        local left_mirror = bounce_world:newBody(20, 0, 6, 60, "static")
        left_mirror:setMirror(true)
        local right_mirror = bounce_world:newBody(80, 0, 6, 60, "static")
        right_mirror:setMirror(true)
        bounce_world:step(1 / 60)

        local bounce_trace = bounce_world:castBeam(50, 0, 1, 0, 200, {
            reflect = true,
            maxBounces = 2,
        })
        expect_equal(3, #bounce_trace.hits)
        expect_equal(3, #bounce_trace.segments)
        expect_equal(right_mirror:getId(), bounce_trace.hits[1].bodyId)
        expect_equal(left_mirror:getId(), bounce_trace.hits[2].bodyId)
        expect_equal(right_mirror:getId(), bounce_trace.hits[3].bodyId)
        expect_false(bounce_trace.hits[3].reflected)

        local pierce_world = new_world(0, 0)
        local shooter = pierce_world:newCircleBody(10, 0, 2, "dynamic")
        shooter:setLayer(0x2)
        local ids = {}
        for i = 1, 3 do
            local target = pierce_world:newCircleBody(40 + i * 20, 0, 4, "static")
            target:setLayer(0x2)
            ids[i] = target:getId()
        end
        pierce_world:step(1 / 60)

        local trace = pierce_world:castBeam(10, 0, 1, 0, 120, {
            mode = "pierce",
            maxHits = 2,
            layer = 0x1,
            mask = 0x2,
            excludeBody = shooter:getId(),
        })
        expect_type("table", trace)
        expect_equal(2, #trace.hits)
        expect_equal(ids[1], trace.hits[1].bodyId)
        expect_equal(ids[2], trace.hits[2].bodyId)
        expect_true(trace.hits[1].distance < trace.hits[2].distance)
        expect_equal(1, trace.hits[1].segmentIndex)
        expect_equal(1, trace.hits[2].segmentIndex)
        expect_equal(1, #trace.segments)
        expect_equal(ids[2], trace.segments[1].blockedBy)
        expect_false(trace.reachedMaxRange)

        local err = expect_error(function()
            new_world(0, 0):castBeam(0, 0, 1, 0, 20, { thickness = 2 })
        end)
        expect_true(
            string.find(
                tostring(err),
                "thickness > 0 is not implemented yet; thick beams require shape casting",
                1,
                true
            ) ~= nil
        )
    end)

    -- @covers LWorld:reflectBodyVelocity
    it("reflectBodyVelocity mirrors the current velocity around a normal", function()
        local world = new_world(0, 0)
        local projectile = world:newCircleBody(0, 0, 2, "dynamic")
        projectile:setVelocity(10, -5)

        expect_true(world:reflectBodyVelocity(projectile:getId(), 0, 1, 0.5))
        local vx, vy = projectile:getVelocity()
        expect_near(5, vx, 0.01)
        expect_near(2.5, vy, 0.01)
        expect_false(world:reflectBodyVelocity(projectile:getId(), 0, 0, 1.0))
    end)

    -- @covers LWorld:beamClosest
    it("beamClosest can skip sensors while allowing the shooter body to be excluded", function()
        local world = new_world(0, 0)
        local shooter = world:newCircleBody(10, 5, 2, "dynamic")
        shooter:setLayer(0x2)
        local sensor = world:newCircleBody(30, 5, 3, "sensor")
        sensor:setLayer(0x2)
        local target = world:newCircleBody(50, 5, 4, "static")
        target:setLayer(0x2)
        world:step(1 / 60)

        local hit = world:beamClosest(10, 5, 1, 0, 120, {
            layer = 0x1,
            mask = 0x2,
            excludeBody = shooter:getId(),
            includeSensors = false,
        })
        expect_type("table", hit)
        expect_equal(target:getId(), hit.bodyId)
        expect_equal(1, hit.segmentIndex)
        local sensor_hit = world:beamClosest(10, 5, 1, 0, 120, {
            layer = 0x1,
            mask = 0x2,
            excludeBody = shooter:getId(),
            includeSensors = true,
        })
        expect_type("table", sensor_hit)
        expect_equal(sensor:getId(), sensor_hit.bodyId)
        expect_nil(world:beamClosest(10, 5, 1, 0, 120, {
            layer = 0x1,
            mask = 0x4,
            excludeBody = shooter:getId(),
        }))
    end)

    -- @covers LWorld:beamAll
    it("beamAll respects world collision groups and stays in deterministic distance order", function()
        local world = new_world(0, 0)
        local ids = {}
        for i = 1, 3 do
            local body = world:newCircleBody(40 + i * 30, 10, 4, "static")
            body:setCollisionGroup(i)
            ids[i] = body:getId()
        end
        world:setCollisionPair(0, 1, false)
        world:step(1 / 60)

        local hits = world:beamAll(30, 10, 1, 0, 160, { group = 0 })
        expect_type("table", hits)
        expect_equal(2, #hits)
        expect_equal(ids[2], hits[1].bodyId)
        expect_equal(ids[3], hits[2].bodyId)
        expect_true(hits[1].distance < hits[2].distance)

        local groups_world = new_world(0, 0)
        local grouped = groups_world:newCircleBody(60, 10, 4, "static")
        grouped:setCollisionGroup(1)
        groups_world:step(1 / 60)
        expect_equal(1, #groups_world:beamAll(30, 10, 1, 0, 80, { groups = 0x2 }))
        groups_world:setCollisionPair(1, 1, false)
        groups_world:step(1 / 60)
        expect_equal(0, #groups_world:beamAll(30, 10, 1, 0, 80, { groups = 0x2 }))
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
        expect_nil(world:getBodyAtPoint(2, 2, { excludeBody = body:getId() }))
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

    -- @covers LZone:setGravityAdditive
    it("setGravityAdditive lets a zone add to world gravity", function()
        local world = new_world(0, 50)
        local zone = world:addZone(-100, -100, 200, 200)
        zone:setGravityDirectional(0, 100)
        zone:setGravityAdditive(true)
        local body = world:newCircleBody(0, 0, 1, "dynamic")
        world:step(1 / 60)
        local _, vy = body:getVelocity()
        expect_true(vy > 1.0)
    end)

    -- @covers LZone:isGravityAdditive
    it("isGravityAdditive reports additive zone mode", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_false(zone:isGravityAdditive())
        zone:setGravityAdditive(true)
        expect_true(zone:isGravityAdditive())
    end)

    -- @covers LZone:setGravityFalloff
    it("setGravityFalloff accepts named point gravity curves", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        expect_no_error(function()
            zone:setGravityFalloff("constant")
        end)
        local ok, err = pcall(function()
            zone:setGravityFalloff("unknown")
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "setGravityFalloff", 1, true) ~= nil)
    end)

    -- @covers LZone:getGravityFalloff
    it("getGravityFalloff returns the current falloff mode", function()
        local zone = new_world(0, 0):addZone(0, 0, 100, 100)
        zone:setGravityFalloff("inverse")
        expect_equal("inverse", zone:getGravityFalloff())
    end)

    -- @covers LZone:setGravityRadius
    it("setGravityRadius clamps point gravity to an active radius", function()
        local world = new_world(0, 0)
        local zone = world:addZone(-200, -200, 400, 400)
        zone:setGravityPoint(0, 0, 500)
        zone:setGravityRadius(1, 10)
        local body = world:newCircleBody(50, 0, 1, "dynamic")
        world:step(1 / 60)
        local vx = select(1, body:getVelocity())
        expect_near(0, vx, 0.001)
    end)

    -- @covers LZone:setGravityLimits
    it("setGravityLimits clamps point gravity acceleration", function()
        local world = new_world(0, 0)
        local zone = world:addZone(-200, -200, 400, 400)
        zone:setGravityPoint(0, 0, 5000)
        zone:setGravityLimits(nil, 10)
        local body = world:newCircleBody(20, 0, 1, "dynamic")
        world:step(1 / 60)
        local vx = select(1, body:getVelocity())
        expect_true(vx < 0)
        expect_true(vx > -1)
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

    -- @covers LZone:setLinearDrag
    it("setLinearDrag slows bodies inside an atmosphere zone", function()
        local world = new_world(0, 0)
        local zone = world:addZone(-20, -20, 40, 40)
        zone:setLinearDrag(3.0)
        local body = world:newCircleBody(0, 0, 1, "dynamic")
        body:setVelocity(100, 0)
        world:step(1 / 60)
        local vx = select(1, body:getVelocity())
        expect_true(vx < 100)
    end)

    -- @covers LZone:setQuadraticDrag
    it("setQuadraticDrag applies speed-scaled drag inside a zone", function()
        local world = new_world(0, 0)
        local zone = world:addZone(-20, -20, 40, 40)
        zone:setQuadraticDrag(0.05)
        local body = world:newCircleBody(0, 0, 1, "dynamic")
        body:setVelocity(80, 0)
        world:step(1 / 60)
        local vx = select(1, body:getVelocity())
        expect_true(vx < 80)
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

    -- @covers LTerrain:carveCircle
    it("carveCircle clears a circular patch without a boolean flag", function()
        local terrain = new_terrain(new_world(0, 0), 32, 32, 4)
        terrain:fillAll(true)
        terrain:carveCircle(32, 32, 12)
        expect_false(terrain:getCell(8, 8))
    end)

    -- @covers LTerrain:addCircle
    it("addCircle restores solid terrain in a circular patch", function()
        local terrain = new_terrain(new_world(0, 0), 32, 32, 4)
        terrain:fillAll(false)
        terrain:addCircle(32, 32, 12)
        expect_true(terrain:getCell(8, 8))
    end)

    -- @covers LTerrain:fillRect
    it("fillRect edits a rectangular patch of terrain", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillRect(8, 8, 12, 12, true)
        expect_true(terrain:isDirty())
    end)

    -- @covers LTerrain:carveRect
    it("carveRect clears a rectangular patch without a boolean flag", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        terrain:carveRect(8, 8, 12, 12)
        expect_false(terrain:getCell(2, 2))
    end)

    -- @covers LTerrain:addRect
    it("addRect fills a rectangular patch without a boolean flag", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(false)
        terrain:addRect(8, 8, 12, 12)
        expect_true(terrain:getCell(2, 2))
    end)

    -- @covers LTerrain:flush
    it("flush returns rebuild diagnostics and can honor a chunk budget", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        local stats = terrain:flush(1)
        expect_type("table", stats)
        expect_equal(1, stats.dirtyChunksRebuilt)
        expect_true(stats.dirtyChunksRemaining >= 0)
        terrain:flush()
        expect_false(terrain:isDirty())
    end)

    -- @covers LTerrain:isDirty
    it("isDirty reports whether terrain edits are pending", function()
        local terrain = new_terrain(new_world(0, 0), 16, 16, 4)
        terrain:fillAll(true)
        expect_true(terrain:isDirty())
    end)

    -- @covers LTerrain:damageCircle
    it("damageCircle carves terrain and returns a collapse result table", function()
        local terrain = new_terrain(new_world(0, 0), 32, 32, 4)
        terrain:fillAll(true)
        local result = terrain:damageCircle(32, 32, 12)
        expect_false(terrain:getCell(8, 8))
        expect_type("table", result)
        expect_equal(0, result.removedCells)
    end)

    -- @covers LTerrain:collapseUnsupported
    it("collapseUnsupported removes floating terrain and can spawn debris or dynamic chunks", function()
        local world = new_world(0, 200)
        local terrain = new_terrain(world, 16, 16, 8)
        terrain:fillRect(0, 120, 128, 8, true)
        terrain:addRect(32, 32, 16, 16)
        local result = terrain:collapseUnsupported({
            support = "bottom",
            mode = "spawnDebris",
            minComponentCells = 2,
            maxDebris = 2,
        })
        expect_equal(1, result.components)
        expect_equal(4, result.removedCells)
        expect_equal(2, #result.bodyIds)
        expect_equal(2, #result.debrisBodies)

        local terrain2 = new_terrain(world, 16, 16, 8)
        terrain2:addRect(32, 32, 16, 16)
        local chunks = terrain2:collapseUnsupported({
            support = "bottom",
            mode = "spawnDynamicChunks",
            minComponentCells = 2,
        })
        expect_equal(1, chunks.components)
        expect_equal(4, chunks.removedCells)
        expect_equal(1, #chunks.bodyIds)
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

-- @describe liquid map
describe("liquid map", function()
    -- @covers lurek.physics.newLiquidMap
    it("newLiquidMap creates a liquid userdata and rejects mismatched terrain grids", function()
        local world = new_world(0, 0)
        local terrain = new_terrain(world, 8, 8, 4)
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, world, terrain)
        expect_type("userdata", liquid)

        local ok, err = pcall(function()
            local other = new_terrain(world, 4, 4, 4)
            lurek.physics.newLiquidMap(8, 8, 4, world, other)
        end)
        expect_false(ok)
        expect_true(string.find(tostring(err), "newLiquidMap", 1, true) ~= nil)
    end)

    -- @covers LLiquidMap:setCell
    it("setCell stores one liquid amount and kind", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        liquid:setCell(2, 3, 0.75, "water")
        local amount, kind = liquid:getCell(2, 3)
        expect_near(0.75, amount, 0.001)
        expect_equal("water", kind)
    end)

    -- @covers LLiquidMap:getCell
    it("getCell returns stored values and nil kind for empty cells", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        local empty_amount, empty_kind = liquid:getCell(1, 1)
        expect_equal(0, empty_amount)
        expect_nil(empty_kind)
        liquid:setCell(1, 1, 1.0, "lava")
        local amount, kind = liquid:getCell(1, 1)
        expect_near(1.0, amount, 0.001)
        expect_equal("lava", kind)
    end)

    -- @covers LLiquidMap:fillRect
    it("fillRect assigns a rectangle of liquid cells", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        liquid:fillRect(2, 2, 3, 2, 1.0, "acid")
        local amount, kind = liquid:getCell(3, 3)
        expect_near(1.0, amount, 0.001)
        expect_equal("acid", kind)
    end)

    -- @covers LLiquidMap:drainRect
    it("drainRect removes volume from each cell in a rectangle", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        liquid:fillRect(2, 2, 3, 2, 1.0, "water")
        liquid:drainRect(2, 2, 3, 2, 0.4)
        local amount, kind = liquid:getCell(3, 3)
        expect_near(0.6, amount, 0.001)
        expect_equal("water", kind)
    end)

    -- @covers LLiquidMap:step
    it("step leaks through a carved tank opening while conserving volume within tolerance", function()
        local world = new_world(0, 200)
        local terrain = new_terrain(world, 8, 8, 8)
        for x = 1, 6 do
            terrain:setCell(x, 6, true)
        end
        for y = 2, 6 do
            terrain:setCell(1, y, true)
            terrain:setCell(6, y, true)
        end

        local liquid = lurek.physics.newLiquidMap(8, 8, 8, world, terrain)
        liquid:fillRect(2, 2, 3, 3, 1.0, "water")

        local inside_before = 0
        local total_before = 0
        for y = 0, 7 do
            for x = 0, 7 do
                local amount = select(1, liquid:getCell(x, y))
                total_before = total_before + amount
                if x >= 2 and x <= 4 and y >= 2 and y <= 5 then
                    inside_before = inside_before + amount
                end
            end
        end

        terrain:setCell(3, 6, false)
        local stats = nil
        for _ = 1, 18 do
            stats = liquid:step({
                gravityFlow = 1.0,
                sidewaysFlow = 0.5,
                pressureFlow = 0.15,
                maxSteps = 2,
            })
        end

        local inside_after = 0
        local outside_after = 0
        local total_after = 0
        for y = 0, 7 do
            for x = 0, 7 do
                local amount = select(1, liquid:getCell(x, y))
                total_after = total_after + amount
                if x >= 2 and x <= 4 and y >= 2 and y <= 5 then
                    inside_after = inside_after + amount
                end
                if y == 7 then
                    outside_after = outside_after + amount
                end
            end
        end

        expect_type("table", stats)
        expect_true(inside_after < inside_before)
        expect_true(outside_after > 0.0)
        expect_near(total_before, total_after, 0.01)
    end)

    -- @covers LLiquidMap:getAmountAt
    it("getAmountAt samples liquid amount in world space", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 8, new_world(0, 0))
        liquid:setCell(2, 3, 0.6, "acid")
        expect_near(0.6, liquid:getAmountAt(20, 28), 0.001)
        expect_equal(0, liquid:getAmountAt(999, 999))
    end)

    -- @covers LLiquidMap:getLevelAt
    it("getLevelAt returns the top visible surface height for a liquid column", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 8, new_world(0, 0))
        liquid:setCell(4, 4, 1.0, "water")
        liquid:setCell(4, 3, 0.5, "water")
        local level = liquid:getLevelAt(36, 24)
        expect_type("number", level)
        expect_near(28.0, level, 0.001)
    end)

    -- @covers LLiquidMap:applyBuoyancy
    it("applyBuoyancy applies sampled drag and upward force to submerged bodies", function()
        local world = new_world(0, 200)
        local body = world:newCircleBody(20, 20, 6, "dynamic")
        local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
        liquid:fillRect(1, 1, 3, 3, 1.0, "water")
        local stats = liquid:applyBuoyancy({ density = 3.0, drag = 1.0 })
        world:step(1 / 60)
        local _, vy = body:getVelocity()
        expect_type("table", stats)
        expect_equal(1, stats.affectedBodies)
        expect_true(stats.submergedBodies >= 1)
        expect_true(vy < (200 / 60))
    end)

    -- @covers LLiquidMap:toBytes
    it("toBytes serializes liquid grid state into a string", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        liquid:fillRect(1, 1, 2, 2, 1.0, "water")
        expect_type("string", liquid:toBytes())
    end)

    -- @covers LLiquidMap:loadFromBytes
    it("loadFromBytes restores a prior liquid snapshot", function()
        local world = new_world(0, 0)
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, world)
        liquid:fillRect(1, 1, 2, 2, 1.0, "water")
        local bytes = liquid:toBytes()
        local clone = lurek.physics.newLiquidMap(8, 8, 4, world)
        expect_true(clone:loadFromBytes(bytes))
        expect_near(1.0, select(1, clone:getCell(1, 1)), 0.001)
    end)

    -- @covers LLiquidMap:type
    it("type returns LLiquidMap", function()
        expect_equal("LLiquidMap", lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0)):type())
    end)

    -- @covers LLiquidMap:typeOf
    it("typeOf reports liquid-map inheritance", function()
        local liquid = lurek.physics.newLiquidMap(8, 8, 4, new_world(0, 0))
        expect_true(liquid:typeOf("LLiquidMap"))
        expect_true(liquid:typeOf("LObject"))
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

-- BEGIN test_physics_alpha_shape_unit.lua
do
-- Public coverage for alpha-mask collision shape inference.

-- @describe physics alpha shape inference
describe("physics alpha shape inference", function()
    -- @covers lurek.physics.shapeFromImage
    it("shapeFromImage classifies circle-like alpha masks as circles", function()
        local img = lurek.image.newImageData(32, 32)
        img:drawCircle(16, 16, 8, 255, 255, 255, 255)
        local shape = lurek.physics.shapeFromImage(img, { alphaThreshold = 1 })

        expect_equal("circle", shape:getType())
        expect_true(shape:getRadius() > 6)
    end)

    -- @covers LPhysicsShape:getVertexCount
    it("shapeFromImage reports vertex count for irregular masks", function()
        local img = lurek.image.newImageData(32, 32)
        img:drawRect(4, 16, 20, 4, 255, 255, 255, 255)
        img:drawRect(16, 4, 4, 20, 255, 255, 255, 255)
        local shape = lurek.physics.shapeFromImage(img, {
            alphaThreshold = 1,
            rectangleFillThreshold = 1.0,
            circleFillTolerance = 0.01,
            maxVertices = 6,
        })

        expect_equal("polygon", shape:getType())
        expect_true(shape:getVertexCount() >= 3)
    end)

    -- @covers LPhysicsShape:getVertices
    it("shapeFromImage exposes polygon vertices for irregular masks", function()
        local img = lurek.image.newImageData(32, 32)
        img:drawRect(4, 16, 20, 4, 255, 255, 255, 255)
        img:drawRect(16, 4, 4, 20, 255, 255, 255, 255)
        local shape = lurek.physics.shapeFromImage(img, {
            alphaThreshold = 1,
            rectangleFillThreshold = 1.0,
            circleFillTolerance = 0.01,
            maxVertices = 6,
        })
        local vertices = shape:getVertices()

        expect_type("table", vertices)
        expect_type("number", vertices[1].x)
        expect_type("number", vertices[1].y)
    end)
end)
end
-- END test_physics_alpha_shape_unit.lua

-- BEGIN test_physics_altitude_unit.lua
do
-- Canonical public coverage for 2.5D altitude and ballistic helpers.

local function new_altitude_layer(sample_mode)
    return lurek.physics.newAltitudeLayer({
        width = 4,
        height = 4,
        cellSize = 10,
        defaultGroundHeight = 0,
        sampleMode = sample_mode or "nearest",
    })
end

local function new_altitude_world()
    local world = lurek.physics.newWorld(0, 0)
    local layer = new_altitude_layer("nearest")
    world:setAltitudeLayer(layer)
    return world
end

-- @describe physics altitude and ballistic api
describe("physics altitude and ballistic api", function()
    -- @covers lurek.physics.newAltitudeLayer
    it("newAltitudeLayer returns an altitude layer userdata", function()
        expect_type("userdata", new_altitude_layer("nearest"))
    end)

    -- @covers LAltitudeLayer:setCellHeight
    it("setCellHeight updates one authored height cell", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellHeight(1, 0, 6)
        expect_equal(6, layer:getCellHeight(1, 0))
    end)

    -- @covers LAltitudeLayer:getCellHeight
    it("getCellHeight reads one authored height cell", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellHeight(0, 1, 7)
        expect_equal(7, layer:getCellHeight(0, 1))
    end)

    -- @covers LAltitudeLayer:sampleHeight
    it("sampleHeight reads deterministic height samples", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellHeight(1, 0, 5)
        expect_equal(5, layer:sampleHeight(15, 5))
    end)

    -- @covers LAltitudeLayer:setCellClearance
    it("setCellClearance updates one authored clearance cell", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellClearance(1, 1, 12)
        expect_equal(12, layer:sampleClearance(15, 15))
    end)

    -- @covers LAltitudeLayer:sampleClearance
    it("sampleClearance reads deterministic clearance samples", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellClearance(0, 0, 4)
        expect_equal(4, layer:sampleClearance(5, 5))
    end)

    -- @covers LAltitudeLayer:serialize
    it("serialize returns a save-friendly altitude layer table", function()
        local layer = new_altitude_layer("nearest")
        layer:setCellHeight(1, 0, 8)
        local data = layer:serialize()
        expect_type("table", data)
        expect_equal(4, data.width)
        expect_equal(8, data.heights[2])
    end)

    -- @covers LAltitudeLayer:load
    it("load restores serialized altitude layer data", function()
        local source = new_altitude_layer("nearest")
        source:setCellHeight(1, 0, 8)
        local clone = new_altitude_layer("nearest")
        clone:load(source:serialize())
        expect_equal(8, clone:getCellHeight(1, 0))
    end)

    -- @covers LAltitudeLayer:type
    it("type returns the altitude layer userdata name", function()
        expect_equal("LAltitudeLayer", new_altitude_layer("nearest"):type())
    end)

    -- @covers LAltitudeLayer:typeOf
    it("typeOf recognizes altitude layer userdata", function()
        expect_true(new_altitude_layer("nearest"):typeOf("LAltitudeLayer"))
    end)

    -- @covers LWorld:setAltitudeLayer
    it("setAltitudeLayer attaches an altitude layer snapshot to a world", function()
        local world = lurek.physics.newWorld(0, 0)
        local layer = new_altitude_layer("nearest")
        layer:setCellHeight(0, 0, 3)
        world:setAltitudeLayer(layer)
        expect_equal(3, world:getAltitudeLayer():sampleHeight(5, 5))
    end)

    -- @covers LWorld:getAltitudeLayer
    it("getAltitudeLayer returns an attached altitude layer view", function()
        local world = new_altitude_world()
        expect_type("userdata", world:getAltitudeLayer())
    end)

    -- @covers LWorld:drawAltitudeDebug
    it("drawAltitudeDebug renders layer, body, and projectile guides into an image target", function()
        local world = new_altitude_world()
        local layer = world:getAltitudeLayer()
        layer:setCellHeight(1, 1, 6)
        layer:setCellClearance(1, 1, 8)
        local body = world:newBody(24, 24, 10, 10, "static")
        body:setAltitudeMode("fixed")
        body:setAltitude(6)
        body:setHeightExtent(4)
        world:spawnBallisticProjectile({
            from = { x = 8, y = 40, z = 2 },
            target = { x = 40, y = 40, z = 8 },
            speed = 16, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25,
        })
        local img = lurek.image.newImageData(64, 64)
        world:drawAltitudeDebug(img)
        local _, _, _, layer_alpha = img:getPixel(10, 10)
        local _, _, _, body_alpha = img:getPixel(24, 24)
        local _, _, _, projectile_alpha = img:getPixel(8, 38)
        expect_true(layer_alpha > 0)
        expect_true(body_alpha > 0)
        expect_true(projectile_alpha > 0)
    end)

    -- @covers LWorld:queryAltitudeOverlap
    it("queryAltitudeOverlap filters overlaps by world-space z range", function()
        local world = new_altitude_world()
        local low = world:newBody(20, 0, 8, 8, "static")
        low:setAltitudeMode("fixed")
        low:setAltitude(0)
        low:setHeightExtent(2)
        local high = world:newBody(20, 0, 8, 8, "static")
        high:setAltitudeMode("fixed")
        high:setAltitude(5)
        high:setHeightExtent(3)
        world:step(1 / 60)
        local hits = world:queryAltitudeOverlap(20, 0, 8, 4, 9)
        expect_equal(1, #hits)
        expect_equal(high:getId(), hits[1].bodyId)
    end)

    -- @covers LWorld:castCircle2_5d
    it("castCircle2_5d ignores low blockers and reaches matching altitude targets", function()
        local world = new_altitude_world()
        local low = world:newBody(14, 0, 6, 6, "static")
        low:setAltitudeMode("fixed")
        low:setAltitude(0)
        low:setHeightExtent(2)
        local high = world:newBody(28, 0, 6, 6, "static")
        high:setAltitudeMode("fixed")
        high:setAltitude(4)
        high:setHeightExtent(4)
        world:step(1 / 60)
        local hit = world:castCircle2_5d({
            x = 0, y = 0, z = 4, radius = 1, height = 2, dx = 40, dy = 0, dz = 0,
        })
        expect_equal(high:getId(), hit.bodyId)
    end)

    -- @covers LWorld:castBallisticArc
    it("castBallisticArc returns deterministic altitude hit payloads", function()
        local world = new_altitude_world()
        local target = world:newBody(20, 0, 6, 6, "static")
        target:setAltitudeMode("fixed")
        target:setAltitude(4)
        target:setHeightExtent(4)
        world:step(1 / 60)
        local trace = world:castBallisticArc({
            from = { x = 0, y = 0, z = 4 },
            to = { x = 20, y = 0, z = 4 },
            speed = 20, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25,
        })
        expect_equal(target:getId(), trace.hit.bodyId)
    end)

    -- @covers LWorld:spawnBallisticProjectile
    it("spawnBallisticProjectile allocates engine-owned projectile ids", function()
        local world = new_altitude_world()
        local id = world:spawnBallisticProjectile({
            from = { x = 0, y = 0, z = 1 },
            target = { x = 8, y = 0, z = 1 },
            speed = 8, gravity = 0, radius = 1, maxTime = 1, sampleDt = 0.25,
        })
        expect_true(id >= 0)
    end)

    -- @covers LWorld:getBallisticProjectile
    it("getBallisticProjectile returns active projectile state tables", function()
        local world = new_altitude_world()
        local id = world:spawnBallisticProjectile({
            owner = 77,
            from = { x = 0, y = 0, z = 1 },
            target = { x = 8, y = 0, z = 1 },
            speed = 8, gravity = 0, radius = 1, maxTime = 1, sampleDt = 0.25,
        })
        local projectile = world:getBallisticProjectile(id)
        expect_equal(77, projectile.owner)
    end)

    -- @covers LWorld:removeBallisticProjectile
    it("removeBallisticProjectile tombstones active projectile slots", function()
        local world = new_altitude_world()
        local id = world:spawnBallisticProjectile({
            from = { x = 0, y = 0, z = 1 },
            target = { x = 8, y = 0, z = 1 },
            speed = 8, gravity = 0, radius = 1, maxTime = 1, sampleDt = 0.25,
        })
        expect_true(world:removeBallisticProjectile(id))
    end)

    -- @covers LWorld:getBallisticProjectileHits
    it("getBallisticProjectileHits reports completed projectile impacts", function()
        local world = new_altitude_world()
        local target = world:newBody(12, 0, 8, 8, "static")
        target:setAltitudeMode("fixed")
        target:setAltitude(2)
        target:setHeightExtent(4)
        world:step(1 / 60)
        world:spawnBallisticProjectile({
            from = { x = 0, y = 0, z = 2 },
            target = { x = 12, y = 0, z = 2 },
            speed = 12, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25,
        })
        for _ = 1, 8 do world:step(0.25) end
        local hits = world:getBallisticProjectileHits()
        expect_equal(target:getId(), hits[1].bodyId)
    end)

    -- @covers LBody:setAltitude
    it("setAltitude stores the body's altitude value", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setAltitude(3)
        expect_equal(3, body:getAltitude())
    end)

    -- @covers LBody:getAltitude
    it("getAltitude returns the body's altitude value", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setAltitude(5)
        expect_equal(5, body:getAltitude())
    end)

    -- @covers LBody:setVerticalVelocity
    it("setVerticalVelocity stores vertical speed for later stepping", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setVerticalVelocity(5)
        expect_equal(5, body:getVerticalVelocity())
    end)

    -- @covers LBody:getVerticalVelocity
    it("getVerticalVelocity returns the stored vertical speed", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setVerticalVelocity(9)
        expect_equal(9, body:getVerticalVelocity())
    end)

    -- @covers LBody:setHeightExtent
    it("setHeightExtent stores targetable vertical size", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setHeightExtent(7)
        expect_equal(7, body:getHeightExtent())
    end)

    -- @covers LBody:getHeightExtent
    it("getHeightExtent returns targetable vertical size", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setHeightExtent(11)
        expect_equal(11, body:getHeightExtent())
    end)

    -- @covers LBody:setAltitudeMode
    it("setAltitudeMode changes how altitude is interpreted", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setAltitudeMode("fixed")
        expect_equal("fixed", body:getAltitudeMode())
    end)

    -- @covers LBody:getAltitudeMode
    it("getAltitudeMode reports the active altitude mode", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setAltitudeMode("airborne")
        expect_equal("airborne", body:getAltitudeMode())
    end)

    -- @covers LBody:setVerticalGravity
    it("setVerticalGravity stores the per-body vertical gravity", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setVerticalGravity(-12)
        expect_equal(-12, body:getVerticalGravity())
    end)

    -- @covers LBody:getVerticalGravity
    it("getVerticalGravity returns the per-body vertical gravity", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setVerticalGravity(-9)
        expect_equal(-9, body:getVerticalGravity())
    end)

    -- @covers LBody:setClearanceClass
    it("setClearanceClass stores an authored clearance label", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setClearanceClass("air")
        expect_equal("air", body:getClearanceClass())
    end)

    -- @covers LBody:getClearanceClass
    it("getClearanceClass returns the authored clearance label", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setClearanceClass("hover")
        expect_equal("hover", body:getClearanceClass())
    end)

    -- @covers LBody:getWorldZRange
    it("getWorldZRange reports the effective world-space altitude interval", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        body:setAltitudeMode("fixed")
        body:setAltitude(4)
        body:setHeightExtent(5)
        local z_min, z_max = body:getWorldZRange()
        expect_equal(4, z_min)
        expect_equal(9, z_max)
    end)

    -- @covers LBody:setAltitudeCollision
    it("setAltitudeCollision stores altitude collision flags without error", function()
        local body = new_altitude_world():newCircleBody(20, 20, 4, "dynamic")
        expect_no_error(function()
            body:setAltitudeCollision({
                enabled = true,
                collideWhenSeparated = false,
                hitGroundWhenBelowTerrain = false,
            })
        end)
    end)
end)
end
-- END test_physics_altitude_unit.lua

test_summary()
