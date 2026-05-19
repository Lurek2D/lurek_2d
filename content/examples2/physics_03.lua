--- Physics Module Part 4: raycasting, AABB queries, contacts, collision events

--@api-stub: LWorld:raycast
-- Basic raycast: returns first hit along a line segment.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "static")
    world:newCircleBody(400, 200, 20, "static")
    local hit = world:raycast(0, 200, 600, 200)
    if hit then
        print("hit body " .. hit.bodyId)
        print("hit point = " .. hit.x .. ", " .. hit.y)
        print("normal = " .. hit.normalX .. ", " .. hit.normalY)
        print("toi = " .. hit.toi)
    else
        print("no hit")
    end
end

--@api-stub: LWorld:raycastClosest
-- Raycast with direction and max distance (closest hit).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 300, 15, "static")
    world:newCircleBody(200, 500, 15, "static")
    local hit = world:raycastClosest(200, 100, 0, 1, 500)
    if hit then
        print("closest hit body = " .. hit.bodyId)
        print("at " .. hit.x .. ", " .. hit.y)
        print("distance factor = " .. hit.toi)
    else
        print("no hit within range")
    end
end

--@api-stub: LWorld:raycastAll
-- Raycast that returns all hits along the ray.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        world:newCircleBody(100 + i * 80, 200, 10, "static")
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600)
    print("total hits = " .. #hits)
    for i, hit in ipairs(hits) do
        print("  hit " .. i .. ": body=" .. hit.bodyId .. " at " .. hit.x .. "," .. hit.y)
    end
end

--@api-stub: LWorld:queryAABB
-- Query all bodies within an axis-aligned bounding box.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    world:newCircleBody(150, 120, 10, "dynamic")
    world:newCircleBody(500, 500, 10, "dynamic")
    local found = world:queryAABB(50, 50, 200, 200)
    print("bodies in AABB = " .. #found)
    for _, id in ipairs(found) do
        print("  body id = " .. id)
    end
end

--@api-stub: LWorld:getBodyAtPoint
-- Find a body at a specific point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 30, "static")
    world:newCircleBody(400, 400, 30, "static")
    local id = world:getBodyAtPoint(210, 205)
    if id then
        print("body at point = " .. id)
    else
        print("no body at point")
    end
    local miss = world:getBodyAtPoint(0, 0)
    print("miss = " .. tostring(miss))
end

--@api-stub: LWorld:getContacts
-- Query all active contacts in the world.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 400, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    print("active contacts = " .. #contacts)
    for _, c in ipairs(contacts) do
        print("  bodyA=" .. c.bodyA .. " bodyB=" .. c.bodyB)
    end
end

--@api-stub: LWorld:getBeginContactEvents
--@api-stub: LWorld:getEndContactEvents
-- Polling contact begin/end events each frame.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 600, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    local began = false
    for frame = 1, 180 do
        world:step(1 / 60)
        local beginEvents = world:getBeginContactEvents()
        if #beginEvents > 0 and not began then
            began = true
            print("frame " .. frame .. ": contact began")
            for _, ev in ipairs(beginEvents) do
                print("  A=" .. ev.bodyA .. " B=" .. ev.bodyB)
            end
        end
        local endEvents = world:getEndContactEvents()
        if #endEvents > 0 then
            print("frame " .. frame .. ": contact ended")
        end
    end
end

--@api-stub: LWorld:getCollisionEvents
-- Collision events (combined begin contacts).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(190, 100, 8, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    for frame = 1, 120 do
        world:step(1 / 60)
        local events = world:getCollisionEvents()
        if #events > 0 then
            print("frame " .. frame .. ": " .. #events .. " collision(s)")
            for _, ev in ipairs(events) do
                print("  A=" .. ev.bodyA .. " B=" .. ev.bodyB)
            end
            break
        end
    end
end

--@api-stub: LWorld:setBeginContact
-- Contact callbacks (alternative to polling).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        print("callback: contact #" .. contactCount .. " A=" .. bodyA .. " B=" .. bodyB)
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("total begin contacts = " .. contactCount)
    world:clearBeginContact()
end

--@api-stub: LWorld:setEndContact
-- End contact callback.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ground = world:newBody(200, 500, "static")
    world:addFixture(ground:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    print("end contacts (bounces) = " .. endCount)
    world:clearEndContact()
end

--@api-stub: LWorld:getBodyContacts
-- Get contacts for a specific body.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(200, 500, "static")
    world:addFixture(floor:getId(), "rectangle", 0, 0.5, 0, false, 400, 20)
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    print("ball contacts = " .. #contacts)
    for _, c in ipairs(contacts) do
        print("  other=" .. c.bodyB .. " normal=" .. c.normalX .. "," .. c.normalY ..
            " touching=" .. tostring(c.isTouching))
    end
end

--@api-stub: lurek.physics.testAABB
-- AABB vs AABB overlap test (no world needed).
do
    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    print("overlap = " .. tostring(overlap))
    local noOverlap = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    print("no overlap = " .. tostring(noOverlap))
end

--@api-stub: lurek.physics.testCircleAABB
-- Circle vs AABB overlap test.
do
    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    print("circle-aabb hit = " .. tostring(hit))
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    print("circle-aabb miss = " .. tostring(miss))
end

--@api-stub: lurek.physics.testCircles
-- Circle vs circle overlap test.
do
    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    print("circles touching = " .. tostring(touching))
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    print("circles apart = " .. tostring(apart))
end

-- Practical: line-of-sight check between player and enemy.
--@api-stub: LWorld:newBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(300, 200, "static")
    world:addFixture(wall:getId(), "rectangle", 0, 0, 0, false, 20, 100)
    local player = world:newCircleBody(100, 200, 8, "dynamic")
    local enemy = world:newCircleBody(500, 200, 8, "dynamic")
    local playerId = player:getId()
    local enemyId = enemy:getId()
    local hit = world:raycast(100, 200, 500, 200)
    if hit and hit.bodyId ~= enemyId then
        print("line of sight blocked by body " .. hit.bodyId)
    elseif hit and hit.bodyId == enemyId then
        print("enemy visible")
    else
        print("no obstacle")
    end
end

-- Practical: find all bodies in explosion radius.
--@api-stub: LWorld:newCircleBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    for i = 1, 10 do
        world:newCircleBody(50 + i * 40, 200, 6, "dynamic")
    end
    local explosionX, explosionY = 250, 200
    local radius = 80
    local affected = world:queryAABB(
        explosionX - radius, explosionY - radius,
        radius * 2, radius * 2
    )
    print("bodies in explosion area = " .. #affected)
    for _, id in ipairs(affected) do
        local bx = world:getBodyType(id)
        if bx == "dynamic" then
            print("  applying force to body " .. id)
        end
    end
end

print("physics_03.lua")
