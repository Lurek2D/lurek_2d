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

--@api-stub: lurek.physics.newChainShape (open)
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
end

--@api-stub: lurek.physics.newChainShape (closed)
-- Create a closed chain shape (forms a loop).
do
    ---@type LPhysicsShape
    local loop = lurek.physics.newChainShape(true,
        0, 0,
        100, 0,
        100, 100,
        0, 100
    )
    print("closed chain type = " .. loop:getType())
end

--@api-stub: lurek.physics.attachShape
-- Attach a standalone shape to a body.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(200, 200, "dynamic")
    ---@type LPhysicsShape
    local circle = lurek.physics.newCircleShape(20)
    lurek.physics.attachShape(body, circle)
    world:step(1 / 60)
    local x, y = body:getPosition()
    print("body with shape: " .. x .. ", " .. y)
end

--@api-stub: LPhysicsShape:setDensity
--@api-stub: LPhysicsShape:setFriction
--@api-stub: LPhysicsShape:setRestitution
--@api-stub: LPhysicsShape:setSensor
-- Shape material properties.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    shape:setFriction(0.9)
    shape:setRestitution(0.3)
    shape:setSensor(false)
    print("configured shape")
end

--@api-stub: LWorld:addFixture (circle)
-- Add a circle fixture to a body using the world API.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    local fixtureId = world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 16)
    print("fixture id = " .. fixtureId)
    print("fixture count = " .. world:fixtureCount(bodyId))
end

--@api-stub: LWorld:addFixture (rectangle)
-- Add a rectangle fixture to a body.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(200, 100, "dynamic")
    local bodyId = body:getId()
    local fid = world:addFixture(bodyId, "rectangle", 1.0, 0.5, 0.2, false, 40, 20)
    print("rect fixture = " .. fid)
    print("fixtures = " .. world:fixtureCount(bodyId))
end

--@api-stub: LWorld:addFixture (polygon)
-- Add a polygon fixture.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(300, 100, "dynamic")
    local bodyId = body:getId()
    local fid = world:addFixture(bodyId, "polygon", 1.0, 0.5, 0.1, false,
        0, -15, -12, 10, 12, 10)
    print("polygon fixture = " .. fid)
end

--@api-stub: LWorld:setFixtureFriction
--@api-stub: LWorld:setFixtureRestitution
--@api-stub: LWorld:setFixtureSensor
-- Modify fixture properties after creation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(bodyId, 0, 0.8)
    world:setFixtureRestitution(bodyId, 0, 0.9)
    world:setFixtureSensor(bodyId, 0, true)
    print("fixture modified")
end

--@api-stub: LWorld:addFixture sensor
-- Creating a sensor fixture for overlap detection.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local trigger = world:newBody(300, 300, "static")
    local triggerId = trigger:getId()
    world:addFixture(triggerId, "circle", 0, 0, 0, true, 50)
    print("sensor fixture created")
    print("fixtures = " .. world:fixtureCount(triggerId))
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

--@api-stub: LWorld:newBodies (batch creation)
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
end

--@api-stub: LWorld:getBodyIds
--@api-stub: LWorld:getBodyType
-- Iterating all bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    world:newBody(300, 300, "kinematic")
    local ids = world:getBodyIds()
    for _, id in ipairs(ids) do
        print("body " .. id .. " type = " .. world:getBodyType(id))
    end
end

--@api-stub: LPhysicsShape:type
--@api-stub: LPhysicsShape:typeOf
--@api-stub: LPhysicsShape:destroy
-- Shape lifecycle.
do
    ---@type LPhysicsShape
    local shape = lurek.physics.newCircleShape(10)
    print("shape type = " .. shape:type())
    print("is LPhysicsShape = " .. tostring(shape:typeOf("LPhysicsShape")))
    shape:destroy()
    print("shape destroyed")
end

--@api-stub: multiple fixtures on one body
-- Compound body with multiple fixtures.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(200, 200, "dynamic")
    local bodyId = body:getId()
    world:addFixture(bodyId, "circle", 1.0, 0.3, 0.2, false, 10)
    world:addFixture(bodyId, "rectangle", 1.0, 0.5, 0.1, false, 30, 8)
    world:addFixture(bodyId, "circle", 0, 0, 0, true, 40)
    print("compound body fixtures = " .. world:fixtureCount(bodyId))
end

print("physics_01.lua")
