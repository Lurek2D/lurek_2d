--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced

--@api-stub: LWorld:addZone / LZone basic setup
-- Zones: axis-aligned areas that apply effects to bodies inside.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    print("zone id = " .. zone:getId())
    zone:setEnabled(true)
    zone:setPriority(10)
    zone:setLayerMask(1)
end

--@api-stub: LZone:setGravityDirectional / setGravityPoint
-- Zone gravity overrides.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local x, y = ball:getPosition()
    print("ball in wind zone: " .. x .. ", " .. y)
end

--@api-stub: LZone:setGravityRepulsor / setGravityZero
-- Repulsor and zero-gravity zones.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local vx, vy = ball:getVelocity()
    print("ball in zero-g: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setLinearDampingOverride / setAngularDampingOverride
-- Zone damping overrides (water, mud).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    water:setAngularDampingOverride(2.0)
    water:setGravityDirectional(0, 100)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local vx, vy = diver:getVelocity()
    print("diver in water: vel=" .. vx .. "," .. vy)
end

--@api-stub: LZone:setCircle
-- Circular zone (instead of default rectangle).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    print("circular zone created")
end

--@api-stub: LWorld:getZoneEvents
-- Zone enter/exit events.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    local ball = world:newCircleBody(250, 100, 8, "dynamic")
    for frame = 1, 120 do
        world:step(1 / 60)
        local events = world:getZoneEvents()
        for _, ev in ipairs(events) do
            print("frame " .. frame .. ": zone=" .. ev.zone_id ..
                " body=" .. ev.body_id .. " kind=" .. ev.kind)
        end
    end
end

--@api-stub: LZone:destroy
-- Destroying zones.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local z1 = world:addZone(0, 0, 100, 100)
    local z2 = world:addZone(200, 200, 100, 100)
    print("zone 1 id = " .. z1:getId())
    z1:destroy()
    print("zone 1 destroyed")
end

--@api-stub: lurek.physics.newCellular / LCellular basic
-- Cellular automaton: grid-based simulation (sand, water, fire).
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(64, 64)
    grid:setCell(32, 0, 1)
    grid:setCell(33, 0, 1)
    grid:setCell(34, 0, 1)
    print("cell at 32,0 = " .. grid:getCell(32, 0))
    grid:step()
    print("after step: cell at 32,1 = " .. grid:getCell(32, 1))
end

--@api-stub: LCellular:fillRect / fillCircle
-- Cellular bulk fill.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(128, 128)
    grid:fillRect(10, 10, 20, 5, 2)
    grid:fillCircle(64, 64, 15, 3)
    local count = grid:countCells(2)
    print("type-2 cells = " .. count)
    local count3 = grid:countCells(3)
    print("type-3 cells = " .. count3)
end

--@api-stub: LCellular:stepN / findCells
-- Multiple steps and finding specific cells.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillRect(14, 0, 4, 2, 1)
    grid:stepN(10)
    local positions = grid:findCells(1)
    print("type-1 cells after 10 steps = " .. #positions)
end

--@api-stub: LCellular:toImageData / toBytes / loadFromBytes
-- Cellular serialization and visualization.
do
    ---@type LCellular
    local grid = lurek.physics.newCellular(32, 32)
    grid:fillCircle(16, 16, 8, 1)
    local bytes = grid:toBytes()
    print("grid bytes length = " .. #bytes)
    ---@type LCellular
    local grid2 = lurek.physics.newCellular(32, 32)
    grid2:loadFromBytes(bytes)
    print("loaded cell at 16,16 = " .. grid2:getCell(16, 16))
end

--@api-stub: lurek.physics.newTerrain / LTerrain basic
-- Destructible terrain: grid-backed physical terrain with collision bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 32, 10, false)
    terrain:flush()
    print("terrain created with hole")
    print("dirty = " .. tostring(terrain:isDirty()))
end

--@api-stub: LTerrain:setCell / getCell / fillRect
-- Terrain cell manipulation.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(20, 20, 10, 10, false)
    terrain:setCell(5, 5, true)
    print("cell at 5,5 = " .. tostring(terrain:getCell(5, 5)))
    terrain:flush()
end

--@api-stub: LTerrain:collapseColumns / solidPositions / spawnDebris
-- Terrain advanced operations.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(10, 0, 12, 15, false)
    terrain:flush()
    terrain:collapseColumns()
    terrain:flush()
    local solids = terrain:solidPositions()
    print("solid positions = " .. #solids)
end

--@api-stub: LTerrain:toBytes / loadFromBytes / toImageData
-- Terrain serialization.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    ---@type LTerrain
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(16, 16, 6, false)
    terrain:flush()
    local data = terrain:toBytes()
    print("terrain bytes = " .. #data)
    ---@type LTerrain
    local terrain2 = lurek.physics.newTerrain(32, 32, 4, world)
    terrain2:loadFromBytes(data)
    terrain2:flush()
    print("loaded cell 0,0 = " .. tostring(terrain2:getCell(0, 0)))
    print("loaded cell 16,16 = " .. tostring(terrain2:getCell(16, 16)))
end

--@api-stub: LWorld:setBodyData / getBodyData / clearBodyData
-- Attach arbitrary data to physics bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local pd = world:getBodyData(player:getId())
    print("player data tag = " .. tostring(pd))
    local ed = world:getBodyData(enemy:getId())
    print("enemy data tag = " .. tostring(ed))
    world:clearBodyData(player:getId())
    print("after clear = " .. tostring(world:getBodyData(player:getId())))
end

--@api-stub: LWorld:setBodyOneWay / getBodyOneWay / clearBodyOneWay
-- One-way platforms: bodies that can only be entered from one direction.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:addFixture(platform:getId(), "rectangle", 0, 0.5, 0, false, 100, 10)
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    if nx then
        print("one-way normal = " .. nx .. ", " .. ny)
    end
    world:clearBodyOneWay(platform:getId())
    nx, ny = world:getBodyOneWay(platform:getId())
    print("after clear: " .. tostring(nx))
end

--@api-stub: LWorld:setBodyCCD / getBodyCCD
-- Continuous collision detection per body (for fast-moving objects).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    print("CCD enabled = " .. tostring(world:getBodyCCD(bullet:getId())))
    bullet:setVelocity(2000, 0)
end

--@api-stub: LWorld:sleepBody / wakeUpBody / isBodySleeping
-- Sleep management via world API.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local id = body:getId()
    lurek.physics.setSleepingAllowed(world, body, true)
    world:sleepBody(id)
    print("sleeping = " .. tostring(world:isBodySleeping(id)))
    world:wakeUpBody(id)
    print("after wake = " .. tostring(world:isBodySleeping(id)))
end

--@api-stub: LWorld:drawDebug
-- Debug drawing (renders wireframes to an image data target).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    world:newBody(200, 500, "static")
    ---@type LImageData
    local img = lurek.image.newImageData(800, 600)
    world:drawDebug(img, 0, 255, 0, 200)
    print("debug drawn to image data")
end

--@api-stub: lurek.physics.debugDraw / drawDebugGpu
-- Global debug draw toggle and GPU debug.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    print("debug draw enabled")
    lurek.physics.drawDebugGpu(world)
    print("GPU debug drawn")
    lurek.physics.debugDraw(false)
end

--@api-stub: lurek.physics.destroyWorld / LWorld:clear
-- World cleanup.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(200, 200, 10, "dynamic")
    print("before clear: " .. world:getBodyCount())
    world:clear()
    print("after clear: " .. world:getBodyCount())
    lurek.physics.destroyWorld(world)
    print("world destroyed")
end

--@api-stub: lurek.physics.step / getBody / setBodyVelocity (free functions)
-- Using free-function API (alternative to method calls).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    print("free fn: pos=" .. x .. "," .. y .. " vel=" .. vx .. "," .. vy)
    lurek.physics.setBodyVelocity(world, body, 50, -100)
    lurek.physics.step(world, 1 / 60)
    x, y, vx, vy = lurek.physics.getBody(world, body)
    print("after set vel: pos=" .. x .. "," .. y)
end

--@api-stub: lurek.physics.getCollisions (free function)
-- Polling collisions via the free-function API.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    print("collisions = " .. #collisions)
    for _, c in ipairs(collisions) do
        print("  A=" .. c.body_a .. " B=" .. c.body_b)
    end
end

--@api-stub: lurek.physics.isSleepingAllowed / setSleepingAllowed (free function)
-- Free-function sleep control.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
    lurek.physics.setSleepingAllowed(world, body, false)
    print("allowed = " .. tostring(lurek.physics.isSleepingAllowed(world, body)))
end

print("physics_04.lua")
