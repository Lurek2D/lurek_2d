--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)

--@api-stub: LWorld:addRevoluteJoint
-- Revolute joint: allows two bodies to rotate around a shared anchor point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local arm = world:newBody(200, 200, "dynamic")
    local pivot = world:newBody(200, 150, "static")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    print("revolute joint id = " .. jointId)
    world:step(1 / 60)
    print("arm angle = " .. arm:getAngle())
end

--@api-stub: LWorld:addDistanceJoint
-- Distance joint: keeps two bodies at a fixed distance.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(
        bodyA:getId(), bodyB:getId(),
        100, 100,
        200, 100,
        100
    )
    print("distance joint id = " .. jointId)
    world:step(1 / 60)
    local ax, ay = bodyA:getPosition()
    local bx, by = bodyB:getPosition()
    print("A=" .. ax .. "," .. ay .. " B=" .. bx .. "," .. by)
end

--@api-stub: LWorld:addPrismaticJoint
-- Prismatic joint: constrains movement along an axis (slider).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(
        rail:getId(), slider:getId(),
        300, 300,
        1, 0
    )
    print("prismatic joint id = " .. jointId)
    slider:applyForce(200, 0)
    world:step(1 / 60)
    print("slider x = " .. slider:getX())
end

--@api-stub: LWorld:addWeldJoint
-- Weld joint: glues two bodies together rigidly.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    print("weld joint id = " .. jointId)
    chassis:applyForce(100, 0)
    world:step(1 / 60)
    print("chassis x = " .. chassis:getX())
    print("turret x = " .. turret:getX())
end

--@api-stub: LWorld:addRopeJoint
-- Rope joint: limits maximum distance between two anchors.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(
        ceiling:getId(), weight:getId(),
        0, 0,
        0, 0,
        120
    )
    print("rope joint id = " .. jointId)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("weight y = " .. weight:getY())
end

--@api-stub: LWorld:addWheelJoint
-- Wheel joint: simulates a wheel on an axle (suspension).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(
        car:getId(), wheel:getId(),
        200, 230,
        0, 1
    )
    print("wheel joint id = " .. jointId)
    world:step(1 / 60)
    print("wheel pos = " .. wheel:getX() .. ", " .. wheel:getY())
end

--@api-stub: LWorld:addMouseJoint
-- Mouse joint: drags a body toward a target point.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    print("mouse joint id = " .. jointId)
    for _ = 1, 30 do
        world:step(1 / 60)
    end
    print("box pos = " .. box:getX() .. ", " .. box:getY())
    world:setMouseJointTarget(jointId, 400, 150)
    for _ = 1, 30 do
        world:step(1 / 60)
    end
    print("box after retarget = " .. box:getX() .. ", " .. box:getY())
end

--@api-stub: LWorld:addMotorJoint
-- Motor joint: applies a relative force/torque between two bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    print("motor joint id = " .. jointId)
    world:step(1 / 60)
    print("mover pos = " .. mover:getX() .. ", " .. mover:getY())
end

--@api-stub: LWorld:addFrictionJoint
-- Friction joint: applies drag forces between two bodies.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    puck:setVelocity(200, 0)
    local jointId = world:addFrictionJoint(
        ground:getId(), puck:getId(),
        200, 400,
        100, 50
    )
    print("friction joint id = " .. jointId)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local vx, vy = puck:getVelocity()
    print("puck vel after friction = " .. vx .. ", " .. vy)
end

--@api-stub: LWorld:addGearJoint
-- Gear joint: couples two revolute or prismatic joints.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    print("gear joint id = " .. jointId)
end

--@api-stub: LWorld:addPulleyJoint
-- Pulley joint: simulates a pulley system.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    print("pulley joint id = " .. jointId)
    boxA:setMass(5.0)
    boxB:setMass(1.0)
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("heavy A y = " .. boxA:getY())
    print("light B y = " .. boxB:getY())
end

--@api-stub: LWorld:getJointIds
--@api-stub: LWorld:jointCount
--@api-stub: LWorld:getJointBodies
--@api-stub: LWorld:getJointType
-- Querying joints.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local c = world:newCircleBody(200, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    world:addDistanceJoint(b:getId(), c:getId(), 100, 200, 200, 200, 100)
    print("joint count = " .. world:jointCount())
    local ids = world:getJointIds()
    for _, jid in ipairs(ids) do
        local bodyA, bodyB = world:getJointBodies(jid)
        print("joint " .. jid .. " type=" .. world:getJointType(jid) ..
            " bodies=" .. bodyA .. "," .. bodyB)
    end
end

--@api-stub: LWorld:setJointLimits
--@api-stub: LWorld:getJointLimits
--@api-stub: LWorld:setJointLimitsEnabled
-- Joint limits (e.g., revolute angle limits).
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    local lo, hi = world:getJointLimits(jid)
    print("limits = " .. lo .. " to " .. hi)
end

--@api-stub: LWorld:setJointMotorSpeed
--@api-stub: LWorld:getJointMotorSpeed
-- Joint motor.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    print("motor speed = " .. world:getJointMotorSpeed(jid))
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    print("blade angle = " .. blade:getAngle())
end

--@api-stub: LWorld:setJointBreakForce
--@api-stub: LWorld:getJointBreakForce
-- Breakable joints.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(
        ceiling:getId(), weight:getId(),
        0, 0, 0, 0, 50
    )
    world:setJointBreakForce(jid, 500)
    print("break force = " .. world:getJointBreakForce(jid))
    weight:setMass(100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    print("joints remaining = " .. world:jointCount())
end

--@api-stub: LWorld:destroyJoint
-- Destroying a joint explicitly.
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    print("joints = " .. world:jointCount())
    world:destroyJoint(jid)
    print("after destroy = " .. world:jointCount())
end

-- Practical: a chain of bodies connected by revolute joints.
--@api-stub: LWorld:newBody
do
    ---@type LWorld
    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(300, 50, "static")
    local prevBody = anchor
    local prevId = anchor:getId()
    local linkCount = 8
    for i = 1, linkCount do
        local link = world:newCircleBody(300, 50 + i * 20, 5, "dynamic")
        world:addRevoluteJoint(prevId, link:getId(), 300, 50 + (i - 1) * 20)
        prevBody = link
        prevId = link:getId()
    end
    print("chain with " .. linkCount .. " links")
    print("total joints = " .. world:jointCount())
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local x, y = prevBody:getPosition()
    print("tail pos = " .. x .. ", " .. y)
end

print("physics_02.lua")
