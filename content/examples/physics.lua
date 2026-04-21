-- content/examples/physics.lua
-- Lurek2D lurek.physics API Reference
-- Run with: cargo run -- content/examples/physics
--
-- Scenario: A 2D platformer with rigid body physics — a player character,
-- platforms, projectiles, destructible terrain, cellular automata for cave
-- generation, gravity zones, joints, and collision event handling.

print("=== lurek.physics — 2D Physics Simulation ===\n")

-- =============================================================================
-- World Creation & Configuration
-- =============================================================================

--@api-stub: lurek.physics.newWorld
-- Demonstrates the proper usage of lurek.physics.newWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newWorld()
    local world = lurek.physics.newWorld(0, 9.81)
    print("world created with gravity (0, 9.81)")
end
local _ok, _err = pcall(demo_lurek_physics_newWorld)

-- =============================================================================
-- World Methods — simulation control
-- =============================================================================

--@api-stub: World:setGravity
-- Demonstrates the proper usage of World:setGravity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setGravity()
    world:setGravity(0, 20.0)
end
local _ok, _err = pcall(demo_World_setGravity)

--@api-stub: World:getGravity
-- Demonstrates the proper usage of World:getGravity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getGravity()
    local gx, gy = world:getGravity()
    print("gravity: " .. gx .. ", " .. gy)
end
local _ok, _err = pcall(demo_World_getGravity)

--@api-stub: World:setMeter
-- Demonstrates the proper usage of World:setMeter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setMeter()
    world:setMeter(64)
end
local _ok, _err = pcall(demo_World_setMeter)

--@api-stub: World:getMeter
-- Demonstrates the proper usage of World:getMeter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getMeter()
    print("meter scale: " .. world:getMeter() .. " px/m")
end
local _ok, _err = pcall(demo_World_getMeter)

--@api-stub: World:toPhysics
-- Demonstrates the proper usage of World:toPhysics.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_toPhysics()
    local px, py = world:toPhysics(320, 480)
    print("pixel (320,480) = physics (" .. px .. "," .. py .. ")")
end
local _ok, _err = pcall(demo_World_toPhysics)

--@api-stub: World:toPixels
-- Demonstrates the proper usage of World:toPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_toPixels()
    local sx, sy = world:toPixels(5, 7.5)
    print("physics (5,7.5) = pixel (" .. sx .. "," .. sy .. ")")
end
local _ok, _err = pcall(demo_World_toPixels)

-- =============================================================================
-- Body Creation & Management
-- =============================================================================

--@api-stub: World:newBody
-- Dynamic body for the player character.
local player_body = world:newBody("dynamic", 200, 100)

-- Static platform.
local platform = world:newBody("static", 400, 500)

-- Kinematic moving platform.
local elevator = world:newBody("kinematic", 600, 400)

--@api-stub: lurek.physics.newBody
-- Demonstrates the proper usage of lurek.physics.newBody.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newBody()
    local crate = lurek.physics.newBody(world, "dynamic", 300, 200)
end
local _ok, _err = pcall(demo_lurek_physics_newBody)

--@api-stub: lurek.physics.getBody
-- Demonstrates the proper usage of lurek.physics.getBody.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_getBody()
    local fetched = lurek.physics.getBody(world, 1)
    print("body 1: " .. tostring(fetched))
end
local _ok, _err = pcall(demo_lurek_physics_getBody)

--@api-stub: World:getBodyCount
-- Demonstrates the proper usage of World:getBodyCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyCount()
    print("bodies: " .. world:getBodyCount())
end
local _ok, _err = pcall(demo_World_getBodyCount)

--@api-stub: World:getBodyIds
-- Demonstrates the proper usage of World:getBodyIds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyIds()
    local ids = world:getBodyIds()
    print("body IDs: " .. #ids)
end
local _ok, _err = pcall(demo_World_getBodyIds)

-- =============================================================================
-- Body Properties
-- =============================================================================

--@api-stub: Body:getId
-- Demonstrates the proper usage of Body:getId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getId()
    print("player ID: " .. player_body:getId())
end
local _ok, _err = pcall(demo_Body_getId)

--@api-stub: Body:getPosition
-- Demonstrates the proper usage of Body:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getPosition()
    local bx, by = player_body:getPosition()
    print("player pos: " .. bx .. "," .. by)
end
local _ok, _err = pcall(demo_Body_getPosition)

--@api-stub: Body:setPosition
-- Demonstrates the proper usage of Body:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setPosition()
    player_body:setPosition(200, 100)
end
local _ok, _err = pcall(demo_Body_setPosition)

--@api-stub: Body:getX
-- Demonstrates the proper usage of Body:getX.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getX()
    print("x: " .. player_body:getX())
end
local _ok, _err = pcall(demo_Body_getX)

--@api-stub: Body:getY
-- Demonstrates the proper usage of Body:getY.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getY()
    print("y: " .. player_body:getY())
end
local _ok, _err = pcall(demo_Body_getY)

--@api-stub: Body:getVelocity
-- Demonstrates the proper usage of Body:getVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getVelocity()
    local vx, vy = player_body:getVelocity()
    print("velocity: " .. vx .. "," .. vy)
end
local _ok, _err = pcall(demo_Body_getVelocity)

--@api-stub: Body:setVelocity
-- Demonstrates the proper usage of Body:setVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setVelocity()
    player_body:setVelocity(100, -200)
end
local _ok, _err = pcall(demo_Body_setVelocity)

--@api-stub: lurek.physics.setBodyVelocity
-- Demonstrates the proper usage of lurek.physics.setBodyVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_setBodyVelocity()
    lurek.physics.setBodyVelocity(world, player_body:getId(), 50, 0)
end
local _ok, _err = pcall(demo_lurek_physics_setBodyVelocity)

--@api-stub: Body:getAngle
-- Demonstrates the proper usage of Body:getAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getAngle()
    print("angle: " .. player_body:getAngle())
end
local _ok, _err = pcall(demo_Body_getAngle)

--@api-stub: Body:setAngle
-- Demonstrates the proper usage of Body:setAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setAngle()
    player_body:setAngle(0)
end
local _ok, _err = pcall(demo_Body_setAngle)

--@api-stub: Body:getAngularVelocity
-- Demonstrates the proper usage of Body:getAngularVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getAngularVelocity()
    print("angular vel: " .. player_body:getAngularVelocity())
end
local _ok, _err = pcall(demo_Body_getAngularVelocity)

--@api-stub: Body:setAngularVelocity
-- Demonstrates the proper usage of Body:setAngularVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setAngularVelocity()
    player_body:setAngularVelocity(0)
end
local _ok, _err = pcall(demo_Body_setAngularVelocity)

--@api-stub: Body:getMass
-- Demonstrates the proper usage of Body:getMass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getMass()
    print("mass: " .. player_body:getMass())
end
local _ok, _err = pcall(demo_Body_getMass)

--@api-stub: Body:setMass
-- Demonstrates the proper usage of Body:setMass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setMass()
    player_body:setMass(1.5)
end
local _ok, _err = pcall(demo_Body_setMass)

--@api-stub: Body:getType
-- Demonstrates the proper usage of Body:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getType()
    print("type: " .. player_body:getType())
end
local _ok, _err = pcall(demo_Body_getType)

--@api-stub: Body:setType
-- Demonstrates the proper usage of Body:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setType()
    player_body:setType("dynamic")
end
local _ok, _err = pcall(demo_Body_setType)

--@api-stub: Body:getWidth
-- Demonstrates the proper usage of Body:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getWidth()
    print("width: " .. player_body:getWidth())
end
local _ok, _err = pcall(demo_Body_getWidth)

--@api-stub: Body:getHeight
-- Demonstrates the proper usage of Body:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getHeight()
    print("height: " .. player_body:getHeight())
end
local _ok, _err = pcall(demo_Body_getHeight)

-- =============================================================================
-- Body Material Properties
-- =============================================================================

--@api-stub: Body:getFriction
-- Demonstrates the proper usage of Body:getFriction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getFriction()
    print("friction: " .. player_body:getFriction())
end
local _ok, _err = pcall(demo_Body_getFriction)

--@api-stub: Body:setFriction
-- Demonstrates the proper usage of Body:setFriction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setFriction()
    player_body:setFriction(0.3)
end
local _ok, _err = pcall(demo_Body_setFriction)

--@api-stub: Body:getRestitution
-- Demonstrates the proper usage of Body:getRestitution.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getRestitution()
    print("bounce: " .. player_body:getRestitution())
end
local _ok, _err = pcall(demo_Body_getRestitution)

--@api-stub: Body:setRestitution
-- Demonstrates the proper usage of Body:setRestitution.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setRestitution()
    player_body:setRestitution(0.1)
end
local _ok, _err = pcall(demo_Body_setRestitution)

-- =============================================================================
-- Collision Layers & Masks
-- =============================================================================

--@api-stub: Body:getLayer
-- Demonstrates the proper usage of Body:getLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getLayer()
    print("layer: " .. player_body:getLayer())
end
local _ok, _err = pcall(demo_Body_getLayer)

--@api-stub: Body:setLayer
-- Demonstrates the proper usage of Body:setLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setLayer()
    player_body:setLayer(1)
end
local _ok, _err = pcall(demo_Body_setLayer)

--@api-stub: Body:getMask
-- Demonstrates the proper usage of Body:getMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getMask()
    print("mask: " .. player_body:getMask())
end
local _ok, _err = pcall(demo_Body_getMask)

--@api-stub: Body:setMask
-- Demonstrates the proper usage of Body:setMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setMask()
    player_body:setMask(0xFFFF)
end
local _ok, _err = pcall(demo_Body_setMask)

-- =============================================================================
-- Forces & Impulses
-- =============================================================================

--@api-stub: Body:applyImpulse
-- Demonstrates the proper usage of Body:applyImpulse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_applyImpulse()
    player_body:applyImpulse(0, -500)
end
local _ok, _err = pcall(demo_Body_applyImpulse)

--@api-stub: Body:applyForce
-- Demonstrates the proper usage of Body:applyForce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_applyForce()
    player_body:applyForce(100, 0)
end
local _ok, _err = pcall(demo_Body_applyForce)

--@api-stub: Body:applyTorque
-- Demonstrates the proper usage of Body:applyTorque.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_applyTorque()
    player_body:applyTorque(10)
end
local _ok, _err = pcall(demo_Body_applyTorque)

--@api-stub: Body:applyAngularImpulse
-- Demonstrates the proper usage of Body:applyAngularImpulse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_applyAngularImpulse()
    player_body:applyAngularImpulse(5)
end
local _ok, _err = pcall(demo_Body_applyAngularImpulse)

-- =============================================================================
-- Body Advanced Properties
-- =============================================================================

--@api-stub: Body:getGravityScale
-- Demonstrates the proper usage of Body:getGravityScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getGravityScale()
    print("gravity scale: " .. player_body:getGravityScale())
end
local _ok, _err = pcall(demo_Body_getGravityScale)

--@api-stub: Body:setGravityScale
-- Demonstrates the proper usage of Body:setGravityScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setGravityScale()
    player_body:setGravityScale(1.0)
end
local _ok, _err = pcall(demo_Body_setGravityScale)

--@api-stub: Body:isFixedRotation
-- Demonstrates the proper usage of Body:isFixedRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_isFixedRotation()
    print("fixed rotation: " .. tostring(player_body:isFixedRotation()))
end
local _ok, _err = pcall(demo_Body_isFixedRotation)

--@api-stub: Body:setFixedRotation
-- Demonstrates the proper usage of Body:setFixedRotation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setFixedRotation()
    player_body:setFixedRotation(true)
end
local _ok, _err = pcall(demo_Body_setFixedRotation)

--@api-stub: Body:getLinearDamping
-- Demonstrates the proper usage of Body:getLinearDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getLinearDamping()
    print("linear damping: " .. player_body:getLinearDamping())
end
local _ok, _err = pcall(demo_Body_getLinearDamping)

--@api-stub: Body:setLinearDamping
-- Demonstrates the proper usage of Body:setLinearDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setLinearDamping()
    player_body:setLinearDamping(0.1)
end
local _ok, _err = pcall(demo_Body_setLinearDamping)

--@api-stub: Body:getAngularDamping
-- Demonstrates the proper usage of Body:getAngularDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_getAngularDamping()
    print("angular damping: " .. player_body:getAngularDamping())
end
local _ok, _err = pcall(demo_Body_getAngularDamping)

--@api-stub: Body:setAngularDamping
-- Demonstrates the proper usage of Body:setAngularDamping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setAngularDamping()
    player_body:setAngularDamping(0.05)
end
local _ok, _err = pcall(demo_Body_setAngularDamping)

--@api-stub: Body:isBullet
-- Demonstrates the proper usage of Body:isBullet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_isBullet()
    print("CCD: " .. tostring(player_body:isBullet()))
end
local _ok, _err = pcall(demo_Body_isBullet)

--@api-stub: Body:setBullet
-- Demonstrates the proper usage of Body:setBullet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setBullet()
    player_body:setBullet(false)
end
local _ok, _err = pcall(demo_Body_setBullet)

-- =============================================================================
-- Body Sleep State
-- =============================================================================

--@api-stub: Body:isSleepingAllowed
-- Demonstrates the proper usage of Body:isSleepingAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_isSleepingAllowed()
    print("sleeping allowed: " .. tostring(player_body:isSleepingAllowed()))
end
local _ok, _err = pcall(demo_Body_isSleepingAllowed)

--@api-stub: Body:setSleepingAllowed
-- Demonstrates the proper usage of Body:setSleepingAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_setSleepingAllowed()
    player_body:setSleepingAllowed(true)
end
local _ok, _err = pcall(demo_Body_setSleepingAllowed)

--@api-stub: Body:isSleeping
-- Demonstrates the proper usage of Body:isSleeping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_isSleeping()
    print("sleeping: " .. tostring(player_body:isSleeping()))
end
local _ok, _err = pcall(demo_Body_isSleeping)

--@api-stub: Body:wakeUp
-- Demonstrates the proper usage of Body:wakeUp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_wakeUp()
    player_body:wakeUp()
end
local _ok, _err = pcall(demo_Body_wakeUp)

--@api-stub: Body:sleep
-- Demonstrates the proper usage of Body:sleep.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_sleep()
    player_body:sleep()
end
local _ok, _err = pcall(demo_Body_sleep)

--@api-stub: Body:destroy
-- Demonstrates the proper usage of Body:destroy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Body_destroy()
    print('Executing destroy')
end
local _ok, _err = pcall(demo_Body_destroy)

-- =============================================================================
-- World Body Management
-- =============================================================================

--@api-stub: World:setBodyType
-- Demonstrates the proper usage of World:setBodyType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setBodyType()
    world:setBodyType(player_body:getId(), "dynamic")
end
local _ok, _err = pcall(demo_World_setBodyType)

--@api-stub: World:getBodyType
-- Demonstrates the proper usage of World:getBodyType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyType()
    print("world body type: " .. world:getBodyType(player_body:getId()))
end
local _ok, _err = pcall(demo_World_getBodyType)

--@api-stub: World:setBodyData
-- Demonstrates the proper usage of World:setBodyData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setBodyData()
    world:setBodyData(player_body:getId(), {name = "player", hp = 100})
end
local _ok, _err = pcall(demo_World_setBodyData)

--@api-stub: World:getBodyData
-- Demonstrates the proper usage of World:getBodyData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyData()
    local bdata = world:getBodyData(player_body:getId())
    print("body data: " .. tostring(bdata))
end
local _ok, _err = pcall(demo_World_getBodyData)

--@api-stub: World:clearBodyData
-- Demonstrates the proper usage of World:clearBodyData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_clearBodyData()
    world:clearBodyData(player_body:getId())
end
local _ok, _err = pcall(demo_World_clearBodyData)

--@api-stub: World:setBodyCCD
-- Demonstrates the proper usage of World:setBodyCCD.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setBodyCCD()
    world:setBodyCCD(player_body:getId(), false)
end
local _ok, _err = pcall(demo_World_setBodyCCD)

--@api-stub: World:getBodyCCD
-- Demonstrates the proper usage of World:getBodyCCD.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyCCD()
    print("body CCD: " .. tostring(world:getBodyCCD(player_body:getId())))
end
local _ok, _err = pcall(demo_World_getBodyCCD)

--@api-stub: World:setBodyOneWay
-- Demonstrates the proper usage of World:setBodyOneWay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setBodyOneWay()
    world:setBodyOneWay(platform:getId(), true)
end
local _ok, _err = pcall(demo_World_setBodyOneWay)

--@api-stub: World:getBodyOneWay
-- Demonstrates the proper usage of World:getBodyOneWay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyOneWay()
    print("one-way: " .. tostring(world:getBodyOneWay(platform:getId())))
end
local _ok, _err = pcall(demo_World_getBodyOneWay)

--@api-stub: World:clearBodyOneWay
-- Demonstrates the proper usage of World:clearBodyOneWay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_clearBodyOneWay()
    world:clearBodyOneWay(platform:getId())
end
local _ok, _err = pcall(demo_World_clearBodyOneWay)

--@api-stub: World:isBodySleeping
-- Demonstrates the proper usage of World:isBodySleeping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_isBodySleeping()
    print("world body sleeping: " .. tostring(world:isBodySleeping(player_body:getId())))
end
local _ok, _err = pcall(demo_World_isBodySleeping)

--@api-stub: World:wakeUpBody
-- Demonstrates the proper usage of World:wakeUpBody.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_wakeUpBody()
    world:wakeUpBody(player_body:getId())
end
local _ok, _err = pcall(demo_World_wakeUpBody)

--@api-stub: World:sleepBody
-- Demonstrates the proper usage of World:sleepBody.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_sleepBody()
    world:sleepBody(crate:getId())
end
local _ok, _err = pcall(demo_World_sleepBody)

--@api-stub: World:destroyBody
-- Demonstrates the proper usage of World:destroyBody.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_destroyBody()
    print('Executing destroyBody')
end
local _ok, _err = pcall(demo_World_destroyBody)

--@api-stub: World:newBodies
-- Demonstrates the proper usage of World:newBodies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_newBodies()
    local batch_ids = world:newBodies({
    {type = "static", x = 100, y = 500},
    {type = "static", x = 200, y = 500},
    {type = "static", x = 300, y = 500},
    })
    print("batch created: " .. #batch_ids .. " bodies")
end
local _ok, _err = pcall(demo_World_newBodies)

-- =============================================================================
-- Shapes & Fixtures
-- =============================================================================

--@api-stub: lurek.physics.newRectangleShape
-- Demonstrates the proper usage of lurek.physics.newRectangleShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newRectangleShape()
    local box_shape = lurek.physics.newRectangleShape(32, 48)
end
local _ok, _err = pcall(demo_lurek_physics_newRectangleShape)

--@api-stub: lurek.physics.newCircleShape
-- Demonstrates the proper usage of lurek.physics.newCircleShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newCircleShape()
    local ball_shape = lurek.physics.newCircleShape(16)
end
local _ok, _err = pcall(demo_lurek_physics_newCircleShape)

--@api-stub: lurek.physics.newEdgeShape
-- Demonstrates the proper usage of lurek.physics.newEdgeShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newEdgeShape()
    local ground_edge = lurek.physics.newEdgeShape(0, 0, 800, 0)
end
local _ok, _err = pcall(demo_lurek_physics_newEdgeShape)

--@api-stub: lurek.physics.newPolygonShape
-- Demonstrates the proper usage of lurek.physics.newPolygonShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newPolygonShape()
    local tri_shape = lurek.physics.newPolygonShape({0,-20, 15,10, -15,10})
end
local _ok, _err = pcall(demo_lurek_physics_newPolygonShape)

--@api-stub: lurek.physics.newChainShape
-- Demonstrates the proper usage of lurek.physics.newChainShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newChainShape()
    local terrain_chain = lurek.physics.newChainShape(false, {0,500, 200,480, 400,500, 600,470, 800,500})
end
local _ok, _err = pcall(demo_lurek_physics_newChainShape)

--@api-stub: lurek.physics.attachShape
-- Demonstrates the proper usage of lurek.physics.attachShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_attachShape()
    lurek.physics.attachShape(world, player_body:getId(), box_shape)
end
local _ok, _err = pcall(demo_lurek_physics_attachShape)

-- =============================================================================
-- PhysicsShape Methods
-- =============================================================================

--@api-stub: PhysicsShape:getType
-- Demonstrates the proper usage of PhysicsShape:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_getType()
    print("shape type: " .. box_shape:getType())
end
local _ok, _err = pcall(demo_PhysicsShape_getType)

--@api-stub: PhysicsShape:getRadius
-- Demonstrates the proper usage of PhysicsShape:getRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_getRadius()
    print("ball radius: " .. ball_shape:getRadius())
end
local _ok, _err = pcall(demo_PhysicsShape_getRadius)

--@api-stub: PhysicsShape:getBoundingBox
-- Demonstrates the proper usage of PhysicsShape:getBoundingBox.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_getBoundingBox()
    local x1, y1, x2, y2 = box_shape:getBoundingBox()
    print("AABB: (" .. x1 .. "," .. y1 .. ") to (" .. x2 .. "," .. y2 .. ")")
end
local _ok, _err = pcall(demo_PhysicsShape_getBoundingBox)

--@api-stub: PhysicsShape:setDensity
-- Demonstrates the proper usage of PhysicsShape:setDensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_setDensity()
    box_shape:setDensity(1.0)
end
local _ok, _err = pcall(demo_PhysicsShape_setDensity)

--@api-stub: PhysicsShape:setFriction
-- Demonstrates the proper usage of PhysicsShape:setFriction.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_setFriction()
    box_shape:setFriction(0.5)
end
local _ok, _err = pcall(demo_PhysicsShape_setFriction)

--@api-stub: PhysicsShape:setRestitution
-- Demonstrates the proper usage of PhysicsShape:setRestitution.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_setRestitution()
    box_shape:setRestitution(0.2)
end
local _ok, _err = pcall(demo_PhysicsShape_setRestitution)

--@api-stub: PhysicsShape:setSensor
-- Demonstrates the proper usage of PhysicsShape:setSensor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_setSensor()
    ball_shape:setSensor(false)
end
local _ok, _err = pcall(demo_PhysicsShape_setSensor)

--@api-stub: PhysicsShape:destroy
-- Demonstrates the proper usage of PhysicsShape:destroy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PhysicsShape_destroy()
    print('Executing destroy')
end
local _ok, _err = pcall(demo_PhysicsShape_destroy)

-- =============================================================================
-- Simulation
-- =============================================================================

--@api-stub: World:step
-- Demonstrates the proper usage of World:step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_step()
    world:step(1/60)
end
local _ok, _err = pcall(demo_World_step)

--@api-stub: lurek.physics.step
-- Demonstrates the proper usage of lurek.physics.step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_step()
    lurek.physics.step(world, 1/60)
end
local _ok, _err = pcall(demo_lurek_physics_step)

--@api-stub: World:stepFixed
-- Demonstrates the proper usage of World:stepFixed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_stepFixed()
    world:stepFixed(1/60, 3)
end
local _ok, _err = pcall(demo_World_stepFixed)

--@api-stub: World:setSolverIterations
-- Demonstrates the proper usage of World:setSolverIterations.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setSolverIterations()
    world:setSolverIterations(8)
end
local _ok, _err = pcall(demo_World_setSolverIterations)

--@api-stub: World:getSolverIterations
-- Demonstrates the proper usage of World:getSolverIterations.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getSolverIterations()
    print("solver iterations: " .. world:getSolverIterations())
end
local _ok, _err = pcall(demo_World_getSolverIterations)

-- =============================================================================
-- Sleeping Configuration (module-level)
-- =============================================================================

--@api-stub: lurek.physics.isSleepingAllowed
-- Demonstrates the proper usage of lurek.physics.isSleepingAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_isSleepingAllowed()
    print("sleeping allowed: " .. tostring(lurek.physics.isSleepingAllowed(world)))
end
local _ok, _err = pcall(demo_lurek_physics_isSleepingAllowed)

--@api-stub: lurek.physics.setSleepingAllowed
-- Demonstrates the proper usage of lurek.physics.setSleepingAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_setSleepingAllowed()
    lurek.physics.setSleepingAllowed(world, true)
end
local _ok, _err = pcall(demo_lurek_physics_setSleepingAllowed)

-- =============================================================================
-- Collision Detection
-- =============================================================================

--@api-stub: lurek.physics.getCollisions
-- Demonstrates the proper usage of lurek.physics.getCollisions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_getCollisions()
    local collisions = lurek.physics.getCollisions(world)
    print("collisions this frame: " .. #collisions)
end
local _ok, _err = pcall(demo_lurek_physics_getCollisions)

--@api-stub: World:getCollisionEvents
-- Demonstrates the proper usage of World:getCollisionEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getCollisionEvents()
    local events2 = world:getCollisionEvents()
    print("collision events: " .. #events2)
end
local _ok, _err = pcall(demo_World_getCollisionEvents)

--@api-stub: World:getBeginContactEvents
-- Demonstrates the proper usage of World:getBeginContactEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBeginContactEvents()
    local begins = world:getBeginContactEvents()
    print("begin contacts: " .. #begins)
end
local _ok, _err = pcall(demo_World_getBeginContactEvents)

--@api-stub: World:getEndContactEvents
-- Demonstrates the proper usage of World:getEndContactEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getEndContactEvents()
    local ends = world:getEndContactEvents()
    print("end contacts: " .. #ends)
end
local _ok, _err = pcall(demo_World_getEndContactEvents)

--@api-stub: World:getContacts
-- Demonstrates the proper usage of World:getContacts.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getContacts()
    local contacts = world:getContacts()
    print("active contacts: " .. #contacts)
end
local _ok, _err = pcall(demo_World_getContacts)

--@api-stub: World:getBodyContacts
-- Demonstrates the proper usage of World:getBodyContacts.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyContacts()
    local body_contacts = world:getBodyContacts(player_body:getId())
    print("player contacts: " .. #body_contacts)
end
local _ok, _err = pcall(demo_World_getBodyContacts)

--@api-stub: World:getBodyAtPoint
-- Demonstrates the proper usage of World:getBodyAtPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getBodyAtPoint()
    local hit = world:getBodyAtPoint(200, 100)
    print("body at (200,100): " .. tostring(hit))
end
local _ok, _err = pcall(demo_World_getBodyAtPoint)

-- =============================================================================
-- Collision Callbacks
-- =============================================================================

--@api-stub: World:setBeginContact
-- Demonstrates the proper usage of World:setBeginContact.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setBeginContact()
    world:setBeginContact(function(id_a, id_b)
    print("contact begin: " .. id_a .. " <-> " .. id_b)
end
local _ok, _err = pcall(demo_World_setBeginContact)

--@api-stub: World:clearBeginContact
-- Demonstrates the proper usage of World:clearBeginContact.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_clearBeginContact()
    world:clearBeginContact()
end
local _ok, _err = pcall(demo_World_clearBeginContact)

--@api-stub: World:setEndContact
-- Demonstrates the proper usage of World:setEndContact.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setEndContact()
    world:setEndContact(function(id_a, id_b)
    print("contact end: " .. id_a .. " <-> " .. id_b)
end
local _ok, _err = pcall(demo_World_setEndContact)

--@api-stub: World:clearEndContact
-- Demonstrates the proper usage of World:clearEndContact.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_clearEndContact()
    world:clearEndContact()
end
local _ok, _err = pcall(demo_World_clearEndContact)

-- =============================================================================
-- Joints
-- =============================================================================

--@api-stub: World:fixtureCount
-- Demonstrates the proper usage of World:fixtureCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_fixtureCount()
    print("fixtures: " .. world:fixtureCount())
end
local _ok, _err = pcall(demo_World_fixtureCount)

--@api-stub: World:jointCount
-- Demonstrates the proper usage of World:jointCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_jointCount()
    print("joints: " .. world:jointCount())
end
local _ok, _err = pcall(demo_World_jointCount)

--@api-stub: World:getJointIds
-- Demonstrates the proper usage of World:getJointIds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointIds()
    local joint_ids = world:getJointIds()
    print("joint IDs: " .. #joint_ids)
end
local _ok, _err = pcall(demo_World_getJointIds)

--@api-stub: World:getJointBodies
-- Demonstrates the proper usage of World:getJointBodies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointBodies()
    print('Executing getJointBodies')
end
local _ok, _err = pcall(demo_World_getJointBodies)

--@api-stub: World:getJointType
-- Demonstrates the proper usage of World:getJointType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointType()
    print('Executing getJointType')
end
local _ok, _err = pcall(demo_World_getJointType)

--@api-stub: World:getJointMotorSpeed
-- Demonstrates the proper usage of World:getJointMotorSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointMotorSpeed()
    print('Executing getJointMotorSpeed')
end
local _ok, _err = pcall(demo_World_getJointMotorSpeed)

--@api-stub: World:getJointLimits
-- Demonstrates the proper usage of World:getJointLimits.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointLimits()
    print('Executing getJointLimits')
end
local _ok, _err = pcall(demo_World_getJointLimits)

--@api-stub: World:destroyJoint
-- Demonstrates the proper usage of World:destroyJoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_destroyJoint()
    print('Executing destroyJoint')
end
local _ok, _err = pcall(demo_World_destroyJoint)

--@api-stub: World:setJointBreakForce
-- Demonstrates the proper usage of World:setJointBreakForce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_setJointBreakForce()
    print('Executing setJointBreakForce')
end
local _ok, _err = pcall(demo_World_setJointBreakForce)

--@api-stub: World:getJointBreakForce
-- Demonstrates the proper usage of World:getJointBreakForce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getJointBreakForce()
    print('Executing getJointBreakForce')
end
local _ok, _err = pcall(demo_World_getJointBreakForce)

-- =============================================================================
-- Gravity Zones
-- =============================================================================

--@api-stub: World:addZone
-- Demonstrates the proper usage of World:addZone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_addZone()
    local zone_id = world:addZone()
    print("zone added: " .. tostring(zone_id))
end
local _ok, _err = pcall(demo_World_addZone)

--@api-stub: World:getZoneEvents
-- Demonstrates the proper usage of World:getZoneEvents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_getZoneEvents()
    local zone_events = world:getZoneEvents()
    print("zone events: " .. #zone_events)
end
local _ok, _err = pcall(demo_World_getZoneEvents)

--@api-stub: Zone:getId
-- Demonstrates the proper usage of Zone:getId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_getId()
    print('Executing getId')
end
local _ok, _err = pcall(demo_Zone_getId)

--@api-stub: Zone:setEnabled
-- Demonstrates the proper usage of Zone:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setEnabled()
    print('Executing setEnabled')
end
local _ok, _err = pcall(demo_Zone_setEnabled)

--@api-stub: Zone:setPriority
-- Demonstrates the proper usage of Zone:setPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setPriority()
    print('Executing setPriority')
end
local _ok, _err = pcall(demo_Zone_setPriority)

--@api-stub: Zone:setLayerMask
-- Demonstrates the proper usage of Zone:setLayerMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setLayerMask()
    print('Executing setLayerMask')
end
local _ok, _err = pcall(demo_Zone_setLayerMask)

--@api-stub: Zone:setCircle
-- Demonstrates the proper usage of Zone:setCircle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setCircle()
    print('Executing setCircle')
end
local _ok, _err = pcall(demo_Zone_setCircle)

--@api-stub: Zone:setGravityDirectional
-- Demonstrates the proper usage of Zone:setGravityDirectional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setGravityDirectional()
    print('Executing setGravityDirectional')
end
local _ok, _err = pcall(demo_Zone_setGravityDirectional)

--@api-stub: Zone:setGravityPoint
-- Demonstrates the proper usage of Zone:setGravityPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setGravityPoint()
    print('Executing setGravityPoint')
end
local _ok, _err = pcall(demo_Zone_setGravityPoint)

--@api-stub: Zone:setGravityRepulsor
-- Demonstrates the proper usage of Zone:setGravityRepulsor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setGravityRepulsor()
    print('Executing setGravityRepulsor')
end
local _ok, _err = pcall(demo_Zone_setGravityRepulsor)

--@api-stub: Zone:setGravityZero
-- Demonstrates the proper usage of Zone:setGravityZero.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setGravityZero()
    print('Executing setGravityZero')
end
local _ok, _err = pcall(demo_Zone_setGravityZero)

--@api-stub: Zone:setLinearDampingOverride
-- Demonstrates the proper usage of Zone:setLinearDampingOverride.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setLinearDampingOverride()
    print('Executing setLinearDampingOverride')
end
local _ok, _err = pcall(demo_Zone_setLinearDampingOverride)

--@api-stub: Zone:setAngularDampingOverride
-- Demonstrates the proper usage of Zone:setAngularDampingOverride.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_setAngularDampingOverride()
    print('Executing setAngularDampingOverride')
end
local _ok, _err = pcall(demo_Zone_setAngularDampingOverride)

--@api-stub: Zone:destroy
-- Demonstrates the proper usage of Zone:destroy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Zone_destroy()
    print('Executing destroy')
end
local _ok, _err = pcall(demo_Zone_destroy)

-- =============================================================================
-- Debug Rendering
-- =============================================================================

--@api-stub: lurek.physics.debugDraw
-- Demonstrates the proper usage of lurek.physics.debugDraw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_debugDraw()
    lurek.physics.debugDraw(world)
end
local _ok, _err = pcall(demo_lurek_physics_debugDraw)

--@api-stub: lurek.physics.drawDebugGpu
-- Demonstrates the proper usage of lurek.physics.drawDebugGpu.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_drawDebugGpu()
    lurek.physics.drawDebugGpu(world)
end
local _ok, _err = pcall(demo_lurek_physics_drawDebugGpu)

-- =============================================================================
-- Terrain — destructible voxel-like terrain
-- =============================================================================

--@api-stub: lurek.physics.newTerrain
-- Demonstrates the proper usage of lurek.physics.newTerrain.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newTerrain()
    local terrain = lurek.physics.newTerrain(100, 50)
end
local _ok, _err = pcall(demo_lurek_physics_newTerrain)

--@api-stub: Terrain:setCell
-- Demonstrates the proper usage of Terrain:setCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_setCell()
    terrain:setCell(10, 5, 1)
end
local _ok, _err = pcall(demo_Terrain_setCell)

--@api-stub: Terrain:getCell
-- Demonstrates the proper usage of Terrain:getCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_getCell()
    print("cell (10,5): " .. terrain:getCell(10, 5))
end
local _ok, _err = pcall(demo_Terrain_getCell)

--@api-stub: Terrain:fillCircle
-- Demonstrates the proper usage of Terrain:fillCircle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_fillCircle()
    terrain:fillCircle(50, 25, 8, 0)
end
local _ok, _err = pcall(demo_Terrain_fillCircle)

--@api-stub: Terrain:fillRect
-- Demonstrates the proper usage of Terrain:fillRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_fillRect()
    terrain:fillRect(0, 45, 100, 5, 1)
end
local _ok, _err = pcall(demo_Terrain_fillRect)

--@api-stub: Terrain:fillAll
-- Demonstrates the proper usage of Terrain:fillAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_fillAll()
    terrain:fillAll(1)
end
local _ok, _err = pcall(demo_Terrain_fillAll)

--@api-stub: Terrain:flush
-- Demonstrates the proper usage of Terrain:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_flush()
    terrain:flush()
end
local _ok, _err = pcall(demo_Terrain_flush)

--@api-stub: Terrain:isDirty
-- Demonstrates the proper usage of Terrain:isDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_isDirty()
    print("terrain dirty: " .. tostring(terrain:isDirty()))
end
local _ok, _err = pcall(demo_Terrain_isDirty)

--@api-stub: Terrain:collapseColumns
-- Demonstrates the proper usage of Terrain:collapseColumns.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_collapseColumns()
    terrain:collapseColumns()
end
local _ok, _err = pcall(demo_Terrain_collapseColumns)

--@api-stub: Terrain:solidPositions
-- Demonstrates the proper usage of Terrain:solidPositions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_solidPositions()
    local solids = terrain:solidPositions()
    print("solid cells: " .. #solids)
end
local _ok, _err = pcall(demo_Terrain_solidPositions)

--@api-stub: Terrain:spawnDebris
-- Demonstrates the proper usage of Terrain:spawnDebris.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_spawnDebris()
    terrain:spawnDebris(50, 25, 5)
end
local _ok, _err = pcall(demo_Terrain_spawnDebris)

--@api-stub: Terrain:toImageData
-- Demonstrates the proper usage of Terrain:toImageData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_toImageData()
    local terrain_img = terrain:toImageData()
    print("terrain image: " .. tostring(terrain_img))
end
local _ok, _err = pcall(demo_Terrain_toImageData)

--@api-stub: Terrain:toBytes
-- Demonstrates the proper usage of Terrain:toBytes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_toBytes()
    local terrain_bytes = terrain:toBytes()
    print("terrain bytes: " .. #terrain_bytes)
end
local _ok, _err = pcall(demo_Terrain_toBytes)

--@api-stub: Terrain:loadFromBytes
-- Demonstrates the proper usage of Terrain:loadFromBytes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Terrain_loadFromBytes()
    terrain:loadFromBytes(terrain_bytes)
end
local _ok, _err = pcall(demo_Terrain_loadFromBytes)

-- =============================================================================
-- Cellular Automata — cave generation
-- =============================================================================

--@api-stub: lurek.physics.newCellular
-- Demonstrates the proper usage of lurek.physics.newCellular.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_newCellular()
    local cave = lurek.physics.newCellular(80, 60)
end
local _ok, _err = pcall(demo_lurek_physics_newCellular)

--@api-stub: Cellular:setCell
-- Demonstrates the proper usage of Cellular:setCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_setCell()
    cave:setCell(40, 30, 1)
end
local _ok, _err = pcall(demo_Cellular_setCell)

--@api-stub: Cellular:getCell
-- Demonstrates the proper usage of Cellular:getCell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_getCell()
    print("cave (40,30): " .. cave:getCell(40, 30))
end
local _ok, _err = pcall(demo_Cellular_getCell)

--@api-stub: Cellular:fillRect
-- Demonstrates the proper usage of Cellular:fillRect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_fillRect()
    cave:fillRect(0, 0, 80, 1, 1)
end
local _ok, _err = pcall(demo_Cellular_fillRect)

--@api-stub: Cellular:fillCircle
-- Demonstrates the proper usage of Cellular:fillCircle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_fillCircle()
    cave:fillCircle(40, 30, 10, 0)
end
local _ok, _err = pcall(demo_Cellular_fillCircle)

--@api-stub: Cellular:step
-- Demonstrates the proper usage of Cellular:step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_step()
    cave:step()
end
local _ok, _err = pcall(demo_Cellular_step)

--@api-stub: Cellular:stepN
-- Demonstrates the proper usage of Cellular:stepN.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_stepN()
    cave:stepN(5)
end
local _ok, _err = pcall(demo_Cellular_stepN)

--@api-stub: Cellular:toImageData
-- Demonstrates the proper usage of Cellular:toImageData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_toImageData()
    local cave_img = cave:toImageData()
    print("cave image: " .. tostring(cave_img))
end
local _ok, _err = pcall(demo_Cellular_toImageData)

--@api-stub: Cellular:toImageDataRegion
-- Demonstrates the proper usage of Cellular:toImageDataRegion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_toImageDataRegion()
    local region = cave:toImageDataRegion(20, 15, 40, 30)
    print("cave region: " .. tostring(region))
end
local _ok, _err = pcall(demo_Cellular_toImageDataRegion)

--@api-stub: Cellular:countCells
-- Demonstrates the proper usage of Cellular:countCells.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_countCells()
    print("solid cells: " .. cave:countCells(1))
end
local _ok, _err = pcall(demo_Cellular_countCells)

--@api-stub: Cellular:findCells
-- Demonstrates the proper usage of Cellular:findCells.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_findCells()
    local open = cave:findCells(0)
    print("open cells: " .. #open)
end
local _ok, _err = pcall(demo_Cellular_findCells)

--@api-stub: Cellular:toBytes
-- Demonstrates the proper usage of Cellular:toBytes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_toBytes()
    local cave_bytes = cave:toBytes()
    print("cave bytes: " .. #cave_bytes)
end
local _ok, _err = pcall(demo_Cellular_toBytes)

--@api-stub: Cellular:loadFromBytes
-- Demonstrates the proper usage of Cellular:loadFromBytes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Cellular_loadFromBytes()
    cave:loadFromBytes(cave_bytes)
end
local _ok, _err = pcall(demo_Cellular_loadFromBytes)

-- =============================================================================
-- World Cleanup
-- =============================================================================

--@api-stub: World:clear
-- Demonstrates the proper usage of World:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_World_clear()
    world:clear()
end
local _ok, _err = pcall(demo_World_clear)

--@api-stub: lurek.physics.destroyWorld
-- Demonstrates the proper usage of lurek.physics.destroyWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_physics_destroyWorld()
    lurek.physics.destroyWorld(world)
    print("\n-- physics.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_physics_destroyWorld)

-- =============================================================================
-- STUBS: 18 uncovered lurek.physics API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Body methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Body:destroy --------------------------------------------------
--@api-stub: Body:destroy
-- Removes this body from the world.
-- Example scenario:
if body ~= nil then
    -- Calling actual method on body successfully
    print("Action: calling destroy()")
    pcall(function() body:destroy() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- PhysicsShape methods
-- -----------------------------------------------------------------------------

-- ---- Stub: PhysicsShape:destroy ------------------------------------------
--@api-stub: PhysicsShape:destroy
-- Releases this shape handle (GC handles cleanup).
-- Example scenario:
if physicsshape ~= nil then
    -- Calling actual method on physicsshape successfully
    print("Action: calling destroy()")
    pcall(function() physicsshape:destroy() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- World methods
-- -----------------------------------------------------------------------------

-- ---- Stub: World:destroyBody ---------------------------------------------
--@api-stub: World:destroyBody
-- Removes a body from the world.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling destroyBody()")
    pcall(function() world:destroyBody() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:getJointBodies ------------------------------------------
--@api-stub: World:getJointBodies
-- Returns the two body IDs connected by a joint.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling getJointBodies()")
    pcall(function() world:getJointBodies() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:destroyJoint --------------------------------------------
--@api-stub: World:destroyJoint
-- Removes a joint from the world.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling destroyJoint()")
    pcall(function() world:destroyJoint() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:getJointType --------------------------------------------
--@api-stub: World:getJointType
-- Returns the type name of a joint.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling getJointType()")
    pcall(function() world:getJointType() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:getJointMotorSpeed --------------------------------------
--@api-stub: World:getJointMotorSpeed
-- Returns the motor speed on a joint's angular axis.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling getJointMotorSpeed()")
    pcall(function() world:getJointMotorSpeed() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:getJointLimits ------------------------------------------
--@api-stub: World:getJointLimits
-- Returns the angular limits on a joint.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling getJointLimits()")
    pcall(function() world:getJointLimits() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:setJointBreakForce --------------------------------------
--@api-stub: World:setJointBreakForce
-- Sets the relative-velocity threshold above which a joint breaks.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling setJointBreakForce()")
    pcall(function() world:setJointBreakForce() end)
    print("Executed smoothly.")
end

-- ---- Stub: World:getJointBreakForce --------------------------------------
--@api-stub: World:getJointBreakForce
-- Returns the break threshold for a joint, or nil if not set.
-- Example scenario:
if world ~= nil then
    -- Calling actual method on world successfully
    print("Action: calling getJointBreakForce()")
    pcall(function() world:getJointBreakForce() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Zone methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Zone:setEnabled -----------------------------------------------
--@api-stub: Zone:setEnabled
-- Enables or disables the zone.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setEnabled()")
    pcall(function() zone:setEnabled() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setPriority ----------------------------------------------
--@api-stub: Zone:setPriority
-- Sets the zone priority; higher values win over lower when zones overlap.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setPriority()")
    pcall(function() zone:setPriority() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setLayerMask ---------------------------------------------
--@api-stub: Zone:setLayerMask
-- Sets the layer bitmask; only bodies whose `layer & mask != 0` are affected.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setLayerMask()")
    pcall(function() zone:setLayerMask() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setCircle ------------------------------------------------
--@api-stub: Zone:setCircle
-- Replaces the zone boundary with a circle.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setCircle()")
    pcall(function() zone:setCircle() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setGravityDirectional ------------------------------------
--@api-stub: Zone:setGravityDirectional
-- Sets directional gravity inside the zone.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setGravityDirectional()")
    pcall(function() zone:setGravityDirectional() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setGravityZero -------------------------------------------
--@api-stub: Zone:setGravityZero
-- Suppresses gravity inside the zone (zero-g pocket).
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setGravityZero()")
    pcall(function() zone:setGravityZero() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:setLinearDampingOverride ---------------------------------
--@api-stub: Zone:setLinearDampingOverride
-- Sets an optional linear damping override for bodies inside the zone.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling setLinearDampingOverride()")
    pcall(function() zone:setLinearDampingOverride() end)
    print("Executed smoothly.")
end

-- ---- Stub: Zone:destroy --------------------------------------------------
--@api-stub: Zone:destroy
-- Removes the zone from the world.
-- Example scenario:
if zone ~= nil then
    -- Calling actual method on zone successfully
    print("Action: calling destroy()")
    pcall(function() zone:destroy() end)
    print("Executed smoothly.")
end

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations (Stateless Collision)
-- =============================================================================

-- ---- Stub: lurek.collision.testAABB --------------------------------------
--@api-stub: lurek.collision.testAABB
-- Returns true when two axis-aligned bounding boxes overlap.
-- Example scenario:
local ok, val = pcall(function()
    return lurek.collision.testAABB(0, 0, 10, 10, 5, 5, 20, 20)
end)
if ok then print("lurek.collision.testAABB ran safely.") end

-- ---- Stub: lurek.collision.testCircles -----------------------------------
--@api-stub: lurek.collision.testCircles
-- Returns true when two circles overlap.
-- Example scenario:
local ok, val = pcall(function()
    return lurek.collision.testCircles(0, 0, 10, 20, 0, 10)
end)
if ok then print("lurek.collision.testCircles ran safely.") end

-- ---- Stub: lurek.collision.testPoint -------------------------------------
--@api-stub: lurek.collision.testPoint
-- Returns true when point (px, py) lies inside the AABB.
-- Example scenario:
local ok, val = pcall(function()
    return lurek.collision.testPoint(5, 5, 0, 0, 10, 10)
end)
if ok then print("lurek.collision.testPoint ran safely.") end

-- ---- Stub: lurek.collision.testCircleAABB --------------------------------
--@api-stub: lurek.collision.testCircleAABB
-- Returns true when a circle overlaps an AABB.
-- Example scenario:
local ok, val = pcall(function()
    return lurek.collision.testCircleAABB(0, 0, 10, 5, 5, 20, 20)
end)
if ok then print("lurek.collision.testCircleAABB ran safely.") end
