--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns

--@api-stub: LBody:getHeight
--@api-stub: LBody:getId
--@api-stub: LBody:getPosition
--@api-stub: LBody:getWidth
--@api-stub: LBody:getX
--@api-stub: LBody:getY
-- Body position and size queries.
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
--@api-stub: LCellular:getCell
--@api-stub: LCellular:setCell
--@api-stub: LCellular:step
--@api-stub: LCellular:toImageDataRegion
--@api-stub: LCellular:type
--@api-stub: LCellular:typeOf
-- Cellular automaton simulation grid.
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
--@api-stub: LPhysicsShape:getRadius
--@api-stub: LPhysicsShape:getType
-- Physics shape queries.
do
    local circle = lurek.physics.newCircleShape(10.0)
    print("shape_type=" .. circle:getType())
    print("radius=" .. circle:getRadius())
    local x1, y1, x2, y2 = circle:getBoundingBox()
    print("bb=" .. x1 .. "," .. y1 .. "," .. x2 .. "," .. y2)
end

--@api-stub: LTerrain:fillAll
--@api-stub: LTerrain:fillCircle
--@api-stub: LTerrain:flush
--@api-stub: LTerrain:isDirty
--@api-stub: LTerrain:type
--@api-stub: LTerrain:typeOf
-- Destructible terrain grid operations.
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
--@api-stub: LWorld:clearBeginContact
--@api-stub: LWorld:clearEndContact
--@api-stub: LWorld:destroyBody
--@api-stub: LWorld:fixtureCount
--@api-stub: LWorld:newBodies
--@api-stub: LWorld:setBodyType
--@api-stub: LWorld:setMouseJointTarget
-- World body management.
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
--@api-stub: LZone:setEnabled
--@api-stub: LZone:setLayerMask
--@api-stub: LZone:setPriority
--@api-stub: LZone:type
--@api-stub: LZone:typeOf
-- Zone lifecycle and config.
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

--@api-stub: lurek.physics.getCollisions
-- Get all active collision pairs from a world.
do
    local world = lurek.physics.newWorld(0, 9.8)
    local cols = lurek.physics.getCollisions(world)
    print("collisions=" .. #cols)
end

--@api-stub: lurek.physics.newBody
-- Free-function body creation.
do
    local world = lurek.physics.newWorld(0, 0)
    local b = lurek.physics.newBody(world, 50, 50, "static")
    print("body_id=" .. b:getId())
end

--@api-stub: lurek.physics.newChainShape
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

print("physics_05.lua")
