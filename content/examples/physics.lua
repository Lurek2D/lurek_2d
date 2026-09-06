-- content/examples/physics.lua
-- Auto-generated from content/examples2/physics_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/physics.lua


--@api: lurek.physics.createBodiesFromTilefield
do

    local tileset = lurek.tileset.fromProvider({ firstGid = 1, tileCount = 1, columns = 1, tileWidth = 16, tileHeight = 16, objects = { wall = { physics = { shape = "rect", bodyType = "static" } } }, tileObjects = { [1] = "wall" } })
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "tiles", 1)
    local world = lurek.physics.newWorld(0, 0)
    local bodies = lurek.physics.createBodiesFromTilefield(field, "tiles", tileset, world, { refIsGid = true })
    lurek.log.info("consumer-owned tilefield bodies=" .. #bodies .. " world=" .. world:getBodyCount())
end


--- Physics Module Part 1: world creation, gravity, stepping, body creation, body properties


--@api: lurek.physics.newWorld
do

    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(320, 520, "static")
    local crate = world:newCircleBody(320, 120, 14, "dynamic")
    local gx, gy = world:getGravity()
    world:step(1 / 60)
    lurek.log.info("training room gravity=" .. gx .. "," .. gy)
    lurek.log.info("floor=" .. floor:getType() .. " crate_y=" .. select(2, crate:getPosition()))
end

--@api: LWorld:getGravity
do

    local world = lurek.physics.newWorld(0, 400)
    local gx, gy = world:getGravity()
    lurek.log.info("gravity=" .. tostring(gx) .. " " .. tostring(gy))
    world:setGravity(10, 800)
    lurek.log.info("updated=" .. tostring(world:getGravity()))
end

--@api: LWorld:setGravity
do

    local world = lurek.physics.newWorld(0, 200)
    world:setGravity(25, 600)
    local gx, gy = world:getGravity()
    lurek.log.info("gravity=" .. tostring(gx) .. " " .. tostring(gy))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end

--@api: LWorld:step
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 12, "dynamic")
    world:step(1 / 60)
    lurek.log.info("position=" .. tostring(body:getPosition()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
end

--@api: LWorld:addGravityVector
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(120, 120, 10, "dynamic")
    local vector_id = world:addGravityVector(0, 180)
    world:step(1 / 60)
    lurek.log.info("gravity vector id=" .. vector_id .. " velocity_y=" .. select(2, body:getVelocity()))
end

--@api: LWorld:setGravityVector
do

    local world = lurek.physics.newWorld(0, 0)
    local ship = world:newCircleBody(160, 160, 8, "dynamic")
    local vector_id = world:addGravityVector(80, 0)
    world:setGravityVector(vector_id, -80, 0)
    world:step(1 / 60)
    lurek.log.info("switched gravity vector=" .. vector_id .. " vx=" .. select(1, ship:getVelocity()))
end

--@api: LWorld:getGravityVector
do

    local world = lurek.physics.newWorld(0, 0)
    local vector_id = world:addGravityVector(12, -18, 0x4)
    local vector = world:getGravityVector(vector_id)
    lurek.log.info("gravity_vector=" .. tostring(vector.id) .. " " .. tostring(vector.gx) .. " " .. tostring(vector.gy))
    lurek.log.info("layer_mask=" .. tostring(vector.layerMask))
end

--@api: LWorld:removeGravityVector
do

    local world = lurek.physics.newWorld(0, 0)
    local vector_id = world:addGravityVector(0, 120)
    local removed = world:removeGravityVector(vector_id)
    local vector = world:getGravityVector(vector_id)
    lurek.log.info("removed=" .. tostring(removed) .. " active=" .. tostring(vector ~= nil))
end

--@api: LWorld:clearGravityVectors
do

    local world = lurek.physics.newWorld(0, 0)
    world:addGravityVector(40, 0)
    world:addGravityVector(0, -40)
    world:clearGravityVectors()
    lurek.log.info("active gravity vectors=" .. world:getStats().gravityVectors)
end

--@api: LWorld:stepFixed
do

    local world = lurek.physics.newWorld(0, 400)
    local ball = world:newCircleBody(200, 120, 10, "dynamic")
    local remainder = world:stepFixed(0.025, 1 / 60, 4)
    local x, y = ball:getPosition()
    local vx, vy = ball:getVelocity()
    lurek.log.info("fixed-step remainder=" .. remainder .. " pos=" .. x .. "," .. y)
    lurek.log.info("post-step velocity=" .. vx .. "," .. vy .. " iterations=" .. world:getSolverIterations())
end

--@api: LWorld:setMeter
do

    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local playerWidthPixels = 128
    local playerWidthMeters = world:toPhysics(playerWidthPixels)
    local jumpArcPixels = world:toPixels(1.5)
    lurek.log.info("platformer meter=" .. world:getMeter() .. " player_width_m=" .. playerWidthMeters)
    lurek.log.info("jump arc preview px=" .. jumpArcPixels)
end

--@api: LWorld:getMeter
do

    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local bridgeSpanMeters = 2.0
    local bridgeSpanPixels = world:toPixels(bridgeSpanMeters)
    local rampHeightPixels = world:toPixels(0.75)
    lurek.log.info("builder meter=" .. world:getMeter() .. " bridge_px=" .. bridgeSpanPixels)
    lurek.log.info("ramp height px=" .. rampHeightPixels)
end

--@api: LWorld:toPhysics
do

    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local doorWidthPx = 96
    local doorWidthMeters = world:toPhysics(doorWidthPx)
    local heroRadiusMeters = world:toPhysics(24)
    lurek.log.info("door width meters=" .. doorWidthMeters)
    lurek.log.info("hero radius meters=" .. heroRadiusMeters)
    lurek.log.info("reference pixels=" .. world:toPixels(1.5))
end

--@api: LWorld:toPixels
do

    local world = lurek.physics.newWorld(0, 9.81)
    world:setMeter(64)
    local ropeLengthMeters = 2.5
    local ropeLengthPixels = world:toPixels(ropeLengthMeters)
    local ledgeDepthPixels = world:toPixels(0.5)
    lurek.log.info("rope length px=" .. ropeLengthPixels)
    lurek.log.info("ledge depth px=" .. ledgeDepthPixels)
    lurek.log.info("reverse sample meters=" .. world:toPhysics(160))
end

--@api: LWorld:setSolverIterations
do

    local world = lurek.physics.newWorld(0, 400)
    local crate = world:newCircleBody(160, 80, 10, "dynamic")
    world:setSolverIterations(8)
    crate:setVelocity(0, 20)
    world:step(1 / 60)
    lurek.log.info("solver iterations=" .. world:getSolverIterations())
    lurek.log.info("crate velocity y=" .. select(2, crate:getVelocity()))
end

--@api: LWorld:getSolverIterations
do

    local world = lurek.physics.newWorld(0, 400)
    world:setSolverIterations(10)
    local floor = world:newBody(200, 420, "static")
    local ball = world:newCircleBody(200, 120, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("solver iterations=" .. world:getSolverIterations())
    lurek.log.info("scene bodies=" .. world:getBodyCount() .. " floor=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end

--@api: LWorld:setCcdSubsteps
do

    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(40, 80, 3, "dynamic")
    world:setCcdSubsteps(4)
    bullet:setBullet(true)
    bullet:setVelocity(1200, 0)
    lurek.log.info("ccd_substeps=" .. tostring(world:getCcdSubsteps()))
    lurek.log.info("bullet_mode=" .. tostring(bullet:isBullet()))
end

--@api: LWorld:getCcdSubsteps
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(180, 90, 6, 80, "static")
    local projectile = world:newCircleBody(40, 90, 2, "dynamic")
    world:setCcdSubsteps(6)
    projectile:setBullet(true)
    local remainder = world:stepFixed(1 / 30, 1 / 120, 8)
    lurek.log.info("ccd_substeps=" .. tostring(world:getCcdSubsteps()) .. " remainder=" .. tostring(remainder))
    lurek.log.info("wall=" .. wall:getType() .. " projectile_x=" .. tostring(select(1, projectile:getPosition())))
end

--@api: LWorld:resetWorld
do

    local world = lurek.physics.newWorld(0, 100)
    world:setGravity(5, 6)
    world:setMeter(96)
    world:setSolverIterations(12)
    world:newBody(0, 0, "dynamic")
    world:resetWorld()
    local gx, gy = world:getGravity()
    lurek.log.info("reset bodies=" .. world:getBodyCount() .. " joints=" .. world:jointCount())
    lurek.log.info("reset gravity=" .. gx .. "," .. gy)
    lurek.log.info("reset meter=" .. world:getMeter() .. " iterations=" .. world:getSolverIterations())
end

--@api: LWorld:setCollisionPair
do

    local world = lurek.physics.newWorld(0, 0)
    local player = world:newCircleBody(0, 0, 8, "dynamic")
    local pickup = world:newCircleBody(0, 0, 8, "static")
    player:setCollisionGroup(0)
    pickup:setCollisionGroup(1)
    world:setCollisionPair(0, 1, false)
    lurek.log.info("pair=" .. tostring(world:getCollisionPair(0, 1)))
    lurek.log.info("player=" .. player:getCollisionGroup() .. " pickup=" .. pickup:getCollisionGroup())
end

--@api: LWorld:getCollisionPair
do

    local world = lurek.physics.newWorld(0, 0)
    local default_pair = world:getCollisionPair(0, 1)
    world:setCollisionPair(0, 1, false)
    local disabled_pair = world:getCollisionPair(0, 1)
    world:setCollisionPair(0, 1, true)
    lurek.log.info("default=" .. tostring(default_pair))
    lurek.log.info("disabled=" .. tostring(disabled_pair))
    lurek.log.info("restored pair=" .. tostring(world:getCollisionPair(0, 1)))
end

--@api: LWorld:setCollisionGroupMask
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 6, "static")
    body:setCollisionGroup(2)
    world:setCollisionGroupMask(0, 0x4)
    world:step(1 / 60)
    local hits = world:queryAABB(0, 0, 20, 20, { group = 0 })
    lurek.log.info("mask=" .. tostring(world:getCollisionGroupMask(0)))
    lurek.log.info("query hits=" .. #hits .. " body_group=" .. body:getCollisionGroup())
end

--@api: LWorld:getCollisionGroupMask
do

    local world = lurek.physics.newWorld(0, 0)
    world:setCollisionGroupMask(3, 0x9)
    local mask = world:getCollisionGroupMask(3)
    world:setCollisionPair(3, 0, false)
    local pair = world:getCollisionPair(3, 0)
    lurek.log.info("mask=" .. tostring(mask))
    lurek.log.info("pair after override=" .. tostring(pair))
end

--@api: LWorld:resetCollisionGroups
do

    local world = lurek.physics.newWorld(0, 0)
    world:setCollisionPair(0, 1, false)
    local disabled = world:getCollisionPair(0, 1)
    world:resetCollisionGroups()
    local restored = world:getCollisionPair(0, 1)
    lurek.log.info("disabled=" .. tostring(disabled))
    lurek.log.info("restored=" .. tostring(restored) .. " mask=" .. world:getCollisionGroupMask(0))
end

--@api: LWorld:newBody
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 50, "dynamic")
    world:step(1 / 60)
    lurek.log.info("id=" .. tostring(body:getId()))
    lurek.log.info("type=" .. tostring(body:getType()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: lurek.physics.newMaterial
do

    local rubber = lurek.physics.newMaterial({
        name = "rubber",
        density = 1.2,
        friction = 0.9,
        restitution = 0.8,
        surfaceType = "bounce_pad",
    })
    lurek.log.info("name=" .. tostring(rubber.name))
    lurek.log.info("friction=" .. tostring(rubber.friction))
    lurek.log.info("surface=" .. tostring(rubber.surfaceType))
end

--@api: LWorld:newCircleBody
do

local world = lurek.physics.newWorld(0, 400)
local rubber = lurek.physics.newMaterial({
name = "rubber",
density = 1.1,
friction = 0.85,
restitution = 0.7,
})
local ball = world:newCircleBody(200, 100, 16, "dynamic", {
material = rubber,
bullet = true,
layer = 0x2,
mask = 0x3,
})
local target = world:newBody(200, 260, "static")
ball:setVelocity(15, -20)
world:step(1 / 60)
end

--@api: LWorld:kinematic
do

    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(400, 580, "static")
    local platform = world:newBody(300, 400, "kinematic")
    local trigger = world:newBody(500, 300, "sensor")
    lurek.log.info("types=" .. tostring(floor:getType()) .. " " .. tostring(platform:getType()) .. " " .. tostring(trigger:getType()))
end

--@api: LBody:setPosition
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setPosition(200, 100)
    lurek.log.info("position=" .. tostring(body:getPosition()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
end

--@api: LBody:setVelocity
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(50, -100)
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    world:step(1 / 60)
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: LBody:getVelocity
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(25, -50)
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("type=" .. tostring(body:getType()))
end

--@api: LBody:setAngle
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 4)
    lurek.log.info("angle=" .. tostring(body:getAngle()))
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
end

--@api: LBody:getAngle
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngle(math.pi / 6)
    lurek.log.info("angle=" .. tostring(body:getAngle()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: LBody:setAngularVelocity
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(2.0)
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    world:step(1 / 60)
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end

--@api: LBody:getAngularVelocity
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularVelocity(1.25)
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end

--@api: LBody:getMass
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(5.0)
    lurek.log.info("mass=" .. tostring(body:getMass()))
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
end

--@api: LBody:setMass
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setMass(7.5)
    lurek.log.info("mass=" .. tostring(body:getMass()))
    lurek.log.info("type=" .. tostring(body:getType()))
end

--@api: LBody:setMaterial
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    local glue = lurek.physics.newMaterial({
        name = "glue",
        density = 1.4,
        friction = 1.0,
        restitution = 0.0,
        stickiness = 1.0,
        adhesion = 0.8,
        gravityScale = 0.5,
    })
    body:setMaterial(glue)
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("gravity=" .. tostring(body:getGravityScale()))
end

--@api: LBody:getMaterial
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(40, 40, "dynamic")
    body:setMaterial(lurek.physics.newMaterial({
        name = "mirror",
        friction = 0.2,
        restitution = 0.1,
        beamReflectivity = 1.0,
        projectileReflectivity = 0.25,
        beamAbsorption = 0.0,
    }))
    local material = body:getMaterial()
    lurek.log.info("name=" .. tostring(material.name))
    lurek.log.info("beam=" .. tostring(material.beamReflectivity))
    lurek.log.info("projectile=" .. tostring(material.projectileReflectivity))
end

--@api: LBody:setFriction
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.8)
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("mass=" .. tostring(body:getMass()))
end

--@api: LBody:getFriction
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setFriction(0.25)
    lurek.log.info("friction=" .. tostring(body:getFriction()))
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
end

--@api: LBody:setRestitution
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.6)
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
    lurek.log.info("mass=" .. tostring(body:getMass()))
end

--@api: LBody:getRestitution
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 20, "dynamic")
    body:setRestitution(0.15)
    lurek.log.info("restitution=" .. tostring(body:getRestitution()))
    lurek.log.info("friction=" .. tostring(body:getFriction()))
end

--@api: LBody:setMirror
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(80, 80, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(1.0)
    local trace = world:castBeam(20, 80, 1, 0, 160, { reflect = true, maxBounces = 1 })
    lurek.log.info("mirror_enabled=" .. tostring(mirror:isMirror()))
    lurek.log.info("mirror_segments=" .. tostring(#trace.segments))
end

--@api: LBody:isMirror
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(90, 90, 12, 48, "static")
    mirror:setMirror(true)
    local reflective = mirror:isMirror()
    local body_id = mirror:getId()
    lurek.log.info("body=" .. tostring(body_id))
    lurek.log.info("is_mirror=" .. tostring(reflective))
end

--@api: LBody:setBeamReflectivity
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(100, 100, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(0.65)
    local reflectivity = mirror:getBeamReflectivity()
    lurek.log.info("beam_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("mirror=" .. tostring(mirror:isMirror()))
end

--@api: LBody:getBeamReflectivity
do

    local world = lurek.physics.newWorld(0, 0)
    local mirror = world:newBody(120, 90, 12, 48, "static")
    mirror:setMirror(true)
    mirror:setBeamReflectivity(0.4)
    local reflectivity = mirror:getBeamReflectivity()
    local trace = world:castBeam(40, 90, 1, 0, 140, { reflect = true, maxBounces = 1, minEnergy = 0.1 })
    lurek.log.info("beam_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("trace_hits=" .. tostring(#trace.hits))
end

--@api: LBody:setProjectileReflectivity
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(80, 100, 12, 48, "static")
    wall:setProjectileReflectivity(0.8)
    local projectile = world:newCircleBody(40, 100, 6, "dynamic")
    projectile:setVelocity(50, 0)
    local reflected = world:reflectBodyVelocity(projectile:getId(), -1, 0, wall:getProjectileReflectivity())
    lurek.log.info("projectile_reflectivity=" .. tostring(wall:getProjectileReflectivity()))
    lurek.log.info("reflected=" .. tostring(reflected))
end

--@api: LBody:getProjectileReflectivity
do

    local world = lurek.physics.newWorld(0, 0)
    local wall = world:newBody(90, 110, 12, 48, "static")
    wall:setProjectileReflectivity(0.55)
    local reflectivity = wall:getProjectileReflectivity()
    local mirror = wall:isMirror()
    lurek.log.info("projectile_reflectivity=" .. tostring(reflectivity))
    lurek.log.info("mirror=" .. tostring(mirror))
end

--@api: LBody:setLinearDamping
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.5)
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
end

--@api: LBody:getLinearDamping
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setLinearDamping(0.75)
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
end

--@api: LBody:setAngularDamping
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.3)
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end

--@api: LBody:getAngularDamping
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, "dynamic")
    body:setAngularDamping(0.9)
    lurek.log.info("angular_damping=" .. tostring(body:getAngularDamping()))
    lurek.log.info("linear_damping=" .. tostring(body:getLinearDamping()))
end

--@api: LBody:setGravityScale
do

    local world = lurek.physics.newWorld(0, 400)
    local normal = world:newBody(100, 100, "dynamic")
    local floaty = world:newBody(200, 100, "dynamic")
    floaty:setGravityScale(0.2)
    lurek.log.info("normal=" .. tostring(normal:getGravityScale()))
    lurek.log.info("floaty=" .. tostring(floaty:getGravityScale()))
end

--@api: LBody:getGravityScale
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setGravityScale(-1.0)
    lurek.log.info("gravity_scale=" .. tostring(body:getGravityScale()))
    lurek.log.info("type=" .. tostring(body:getType()))
end

--@api: LBody:applyForce
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForce(100, 0)
    world:step(1 / 60)
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: LBody:applyForceAtPoint
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyForceAtPoint(0, -50, 210, 200)
    world:step(1 / 60)
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
end

--@api: LBody:applyImpulse
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyImpulse(0, -200)
    world:step(1 / 60)
    lurek.log.info("velocity=" .. tostring(body:getVelocity()))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: LBody:applyAngularImpulse
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyAngularImpulse(5.0)
    world:step(1 / 60)
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end

--@api: LBody:applyTorque
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(200, 200, 10, "dynamic")
    body:applyTorque(10.0)
    world:step(1 / 60)
    lurek.log.info("angular_velocity=" .. tostring(body:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(body:getAngle()))
end

--@api: LBody:setBullet
do

    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    lurek.log.info("is_bullet=" .. tostring(bullet:isBullet()))
    lurek.log.info("type=" .. tostring(bullet:getType()))
end

--@api: LBody:isBullet
do

    local world = lurek.physics.newWorld(0, 400)
    local bullet = world:newCircleBody(100, 100, 4, "dynamic")
    bullet:setBullet(true)
    lurek.log.info("is_bullet=" .. tostring(bullet:isBullet()))
    lurek.log.info("position=" .. tostring(bullet:getPosition()))
end

--@api: LBody:setFixedRotation
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    lurek.log.info("fixed_rotation=" .. tostring(player:isFixedRotation()))
    lurek.log.info("angle=" .. tostring(player:getAngle()))
end

--@api: LBody:isFixedRotation
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(200, 200, "dynamic")
    player:setFixedRotation(true)
    lurek.log.info("fixed_rotation=" .. tostring(player:isFixedRotation()))
    lurek.log.info("type=" .. tostring(player:getType()))
end

--@api: LBody:setType
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setType("kinematic")
    lurek.log.info("type=" .. tostring(body:getType()))
    lurek.log.info("layer=" .. tostring(body:getLayer()))
end

--@api: LBody:getType
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "sensor")
    body:setLayer(8)
    world:setBodyData(body:getId(), { role = "checkpoint" })
    local data = world:getBodyData(body:getId())
    lurek.log.info("checkpoint type=" .. body:getType() .. " id=" .. body:getId())
    lurek.log.info("layer=" .. body:getLayer() .. " role=" .. data.role)
end

--@api: LBody:setLayer
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(2)
    lurek.log.info("layer=" .. tostring(body:getLayer()))
    lurek.log.info("mask=" .. tostring(body:getMask()))
end

--@api: LBody:getLayer
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setLayer(4)
    lurek.log.info("layer=" .. tostring(body:getLayer()))
    lurek.log.info("type=" .. tostring(body:getType()))
end

--@api: LBody:setMask
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(3)
    lurek.log.info("mask=" .. tostring(body:getMask()))
    lurek.log.info("layer=" .. tostring(body:getLayer()))
end

--@api: LBody:getMask
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setMask(7)
    lurek.log.info("mask=" .. tostring(body:getMask()))
    lurek.log.info("id=" .. tostring(body:getId()))
end

--@api: LBody:setCollisionGroup
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(100, 100, "dynamic")
    local wall = world:newBody(120, 100, "static")
    player:setCollisionGroup(0)
    wall:setCollisionGroup(1)
    lurek.log.info("player_group=" .. tostring(player:getCollisionGroup()))
    lurek.log.info("wall group=" .. wall:getCollisionGroup() .. " player layer=" .. player:getLayer())
end

--@api: LBody:getCollisionGroup
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setCollisionGroup(4)
    local group = body:getCollisionGroup()
    body:setLayer(0x3)
    lurek.log.info("single=" .. tostring(group))
    lurek.log.info("multi group returns=" .. tostring(body:getCollisionGroup()))
end

--@api: LBody:sleep
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
end

--@api: LBody:wakeUp
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    body:wakeUp()
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
end

--@api: LBody:isSleeping
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    body:sleep()
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
    lurek.log.info("id=" .. tostring(body:getId()))
end

--@api: LBody:setSleepingAllowed
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(false)
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
    lurek.log.info("sleeping=" .. tostring(body:isSleeping()))
end

--@api: LBody:isSleepingAllowed
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    body:setSleepingAllowed(true)
    lurek.log.info("allowed=" .. tostring(body:isSleepingAllowed()))
    lurek.log.info("type=" .. tostring(body:getType()))
end

--@api: LBody:destroy
do

    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    temp:destroy()
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
end

--@api: LBody:isValid
do

    local world = lurek.physics.newWorld(0, 400)
    local temp = world:newBody(400, 400, "dynamic")
    lurek.log.info("valid=" .. tostring(temp:isValid()))
    temp:destroy()
    lurek.log.info("valid_after_destroy=" .. tostring(temp:isValid()))
end

--@api: LWorld:getBodyCount
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newBody(100, 100, "dynamic")
    local floor = world:newBody(200, 200, "static")
    local pickup = world:newBody(240, 140, "sensor")
    world:step(1 / 60)
    lurek.log.info("arena bodies=" .. world:getBodyCount())
    lurek.log.info("player=" .. player:getType() .. " floor=" .. floor:getType() .. " pickup=" .. pickup:getType())
end

--@api: LWorld:getStats
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local stats = world:getStats()
    lurek.log.info("bodies=" .. tostring(stats.bodies) .. " " .. tostring("slots") .. " " .. tostring(stats.bodySlots) .. " " .. tostring("colliders") .. " " .. tostring(stats.colliders))
    lurek.log.info("joints=" .. tostring(stats.joints) .. " " .. tostring("joint_slots") .. " " .. tostring(stats.jointSlots))
    lurek.log.info("zones=" .. tostring(stats.zones) .. " " .. tostring("sleeping") .. " " .. tostring(stats.sleepingBodies))
    body:destroy()
    stats = world:getStats()
    lurek.log.info("after_destroy=" .. tostring(stats.bodies) .. " " .. tostring("slots") .. " " .. tostring(stats.bodySlots))
end

--@api: LBody:type
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setVelocity(12, -6)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    lurek.log.info("userdata type=" .. body:type() .. " object=" .. tostring(body:typeOf("LObject")))
    lurek.log.info("motion sample=" .. vx .. "," .. vy)
end

--@api: LBody:typeOf
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(0, 0, "dynamic")
    body:setGravityScale(0.5)
    local isBody = body:typeOf("LBody")
    local isObject = body:typeOf("LObject")
    local isWorld = body:typeOf("LWorld")
    lurek.log.info("body handle checks body=" .. tostring(isBody) .. " object=" .. tostring(isObject))
    lurek.log.info("world check=" .. tostring(isWorld) .. " type=" .. body:type())
end

--@api: LWorld:type
do

    local world = lurek.physics.newWorld(0, 400)
    local floor = world:newBody(160, 300, "static")
    local ball = world:newCircleBody(160, 120, 10, "dynamic")
    world:step(1 / 60)
    lurek.log.info("world userdata=" .. world:type() .. " world_check=" .. tostring(world:typeOf("LWorld")))
    lurek.log.info("scene bodies=" .. world:getBodyCount() .. " first=" .. floor:getType() .. " ball_y=" .. select(2, ball:getPosition()))
end

--@api: LWorld:typeOf
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(160, 300, "static")
    world:newCircleBody(160, 120, 10, "dynamic")
    local isWorld = world:typeOf("LWorld")
    local isObject = world:typeOf("LObject")
    lurek.log.info("world check=" .. tostring(isWorld) .. " object check=" .. tostring(isObject))
    lurek.log.info("runtime kind=" .. world:type() .. " bodies=" .. world:getBodyCount())
end

--- Physics Module Part 2: shapes, attachShape, fixtures, collision filtering

--@api: lurek.physics.newCircleShape
do

    local circle = lurek.physics.newCircleShape(16)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    lurek.log.info("type=" .. tostring(circle:getType()))
    lurek.log.info("radius=" .. tostring(circle:getRadius()))
    lurek.log.info("bounds=" .. tostring(minX) .. " " .. tostring(minY) .. " " .. tostring(maxX) .. " " .. tostring(maxY))
end

--@api: lurek.physics.newRectangleShape
do

    local rect = lurek.physics.newRectangleShape(64, 32)
    local minX, minY, maxX, maxY = rect:getBoundingBox()
    rect:setFriction(0.8)
    rect:setDensity(2.0)
    lurek.log.info("crate collider type=" .. rect:getType())
    lurek.log.info("crate bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newPolygonShape
do

    local triangle = lurek.physics.newPolygonShape(0, -20, -15, 15, 15, 15)
    local minX, minY, maxX, maxY = triangle:getBoundingBox()
    triangle:setDensity(1.2)
    triangle:setRestitution(0.1)
    lurek.log.info("roof wedge type=" .. triangle:getType())
    lurek.log.info("roof bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newEdgeShape
do

    local edge = lurek.physics.newEdgeShape(0, 0, 100, 0)
    local minX, minY, maxX, maxY = edge:getBoundingBox()
    edge:setFriction(0.6)
    edge:setSensor(false)
    lurek.log.info("ledge edge type=" .. edge:getType())
    lurek.log.info("ledge bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.newChainShape
do

    local chain = lurek.physics.newChainShape(false, 0, 100, 50, 80, 100, 90, 150, 70, 200, 100)
    local loop = lurek.physics.newChainShape(true, 0, 0, 100, 0, 100, 100, 0, 100)
    local minX, minY, maxX, maxY = chain:getBoundingBox()
    local loopMinX, loopMinY, loopMaxX, loopMaxY = loop:getBoundingBox()
    lurek.log.info("spline type=" .. chain:getType() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    lurek.log.info("pit loop type=" .. loop:getType() .. " bounds=" .. loopMinX .. "," .. loopMinY .. " -> " .. loopMaxX .. "," .. loopMaxY)
end

--@api: LPhysicsShape:setDensity
do

    local shape = lurek.physics.newCircleShape(12)
    shape:setDensity(2.5)
    shape:setFriction(0.4)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    lurek.log.info("heavy boulder density prepared for " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setFriction
do

    local shape = lurek.physics.newCircleShape(12)
    shape:setFriction(0.9)
    shape:setDensity(1.0)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    lurek.log.info("sticky tire friction tuned on " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setRestitution
do

    local shape = lurek.physics.newCircleShape(12)
    shape:setRestitution(0.3)
    shape:setDensity(0.8)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    lurek.log.info("pickup bounce tuned on " .. shape:getType())
    lurek.log.info("radius=" .. shape:getRadius() .. " bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:setSensor
do

    local shape = lurek.physics.newCircleShape(12)
    shape:setSensor(true)
    shape:setDensity(0.2)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    lurek.log.info("trigger volume type=" .. shape:getType())
    lurek.log.info("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.attachShape
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(120, 120, "dynamic")
    local shape = lurek.physics.newCircleShape(10)
    shape:setDensity(1.5)
    lurek.physics.attachShape(body, shape)
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
    lurek.log.info("position=" .. tostring(body:getPosition()))
end

--@api: LWorld:setFixtureFriction
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureFriction(body:getId(), fixture, 0.8)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
end

--@api: LWorld:setFixtureRestitution
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureRestitution(body:getId(), fixture, 0.9)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
end

--@api: LWorld:setFixtureMaterial
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(100, 100, 20, 20, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 0.6, 0.2, 0.1, false, 8)
    local mirror = lurek.physics.newMaterial({
        name = "mirror",
        density = 0.6,
        friction = 0.1,
        restitution = 0.05,
        beamReflectivity = 1.0,
        projectileReflectivity = 0.2,
        surfaceType = "glass",
    })
    world:setFixtureMaterial(body:getId(), fixture, mirror)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("material=" .. tostring(world:getFixtureMaterial(body:getId(), fixture).name))
end

--@api: LWorld:getFixtureMaterial
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(120, 120, 20, 20, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.2, false, 6)
    world:setFixtureMaterial(body:getId(), fixture, lurek.physics.newMaterial({
        name = "ice",
        density = 0.9,
        friction = 0.05,
        restitution = 0.15,
        stickiness = 0.0,
        adhesion = 0.0,
        buoyancy = 0.2,
    }))
    local material = world:getFixtureMaterial(body:getId(), fixture)
    lurek.log.info("name=" .. tostring(material.name))
    lurek.log.info("friction=" .. tostring(material.friction))
    lurek.log.info("buoyancy=" .. tostring(material.buoyancy))
end

--@api: LWorld:setFixtureSensor
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    local fixture = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 10)
    world:setFixtureSensor(body:getId(), fixture, true)
    lurek.log.info("fixture=" .. tostring(fixture))
    lurek.log.info("fixture_count=" .. tostring(world:fixtureCount(body:getId())))
end

--@api: LWorld:newPolygonBody
do

local world = lurek.physics.newWorld(0, 400)
local tri = world:newPolygonBody(100, 200, { 0, -20, -15, 15, 15, 15 }, "dynamic", {
material = lurek.physics.newMaterial({
name = "wedge",
density = 1.3,
friction = 0.7,
restitution = 0.2,
}),
bullet = true,
layer = 0x4,
mask = 0x7,
})
tri:setAngularVelocity(1.5)
world:step(1 / 60)
local x, y = tri:getPosition()
lurek.log.info("falling wedge pos=" .. x .. "," .. y)
end

--@api: LWorld:newEdgeBody
do

local world = lurek.physics.newWorld(0, 400)
local wall = world:newEdgeBody(0, 500, 0, 0, 800, 0, "static", {
material = lurek.physics.newMaterial({
name = "rail",
friction = 0.4,
restitution = 0.0,
beamReflectivity = 0.8,
}),
layer = 0x8,
mask = 0x2,
})
local player = world:newCircleBody(100, 420, 10, "dynamic")
player:setVelocity(40, 0)
world:step(1 / 60)
lurek.log.info("ledge body type=" .. wall:getType() .. " pos_y=" .. select(2, wall:getPosition()))
lurek.log.info("runner pos=" .. select(1, player:getPosition()) .. "," .. select(2, player:getPosition()))
end

--@api: LWorld:newChainBody
do

local world = lurek.physics.newWorld(0, 400)
local ground = world:newChainBody(0, 500, { 0, 100, 100, 80, 200, 90, 300, 60, 400, 100 }, false, "static", {
material = lurek.physics.newMaterial({
name = "track",
friction = 0.9,
restitution = 0.0,
surfaceType = "ground",
}),
layer = 0x10,
mask = 0x1F,
})
local bike = world:newCircleBody(120, 420, 8, "dynamic")
bike:setVelocity(30, 0)
world:step(1 / 60)
lurek.log.info("track body type=" .. ground:getType() .. " start_y=" .. select(2, ground:getPosition()))
lurek.log.info("bike pos=" .. select(1, bike:getPosition()) .. "," .. select(2, bike:getPosition()))
end

--@api: LWorld:newBodies
do

    local world = lurek.physics.newWorld(0, 400)
    local ids = world:newBodies({
        { 15, 50, 12, 12, "dynamic" },
        { 30, 50, 12, 12, "dynamic" },
        { 45, 50, 12, 12, "static" },
    })
    lurek.log.info("created=" .. tostring(#ids))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end

--@api: LWorld:getBodyStates
do
    local world = lurek.physics.newWorld(0, 0)
    local ids = world:newBodies({ { 10, 20, "dynamic" }, { 30, 40, "dynamic" } })
    local states = world:getBodyStates(ids)
    lurek.log.info("first body=" .. states[1].id .. " at " .. states[1].x .. "," .. states[1].y)
    lurek.log.info("state records=" .. tostring(#states))
end

--@api: LWorld:setBodyStates
do
    local world = lurek.physics.newWorld(0, 0)
    local ids = world:newBodies({ { 0, 0, "dynamic" } })
    world:setBodyStates({ { id = ids[1], x = 12, y = 24, vx = 3, vy = 0 } })
    local state = world:getBodyStates(ids)[1]
    lurek.log.info("updated x=" .. state.x)
    lurek.log.info("updated velocity=" .. state.vx .. "," .. state.vy)
end

--@api: LWorld:applyForces
do
    local world = lurek.physics.newWorld(0, 0)
    local ids = world:newBodies({ { 0, 0, "dynamic" } })
    world:applyForces({ { id = ids[1], fx = 100, fy = 0 } })
    local state = world:getBodyStates(ids)[1]
    lurek.log.info("forces queued for body=" .. ids[1])
    lurek.log.info("body remains at x=" .. state.x .. " before a step")
end

--@api: LWorld:getBodyIds
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(100, 100, "dynamic")
    world:newBody(200, 200, "static")
    local ids = world:getBodyIds()
    lurek.log.info("count=" .. tostring(#ids))
    lurek.log.info("first=" .. tostring(ids[1]))
end

--@api: LWorld:hasBody
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    lurek.log.info("has_body=" .. tostring(world:hasBody(body:getId())))
    body:destroy()
    lurek.log.info("has_body_after_destroy=" .. tostring(world:hasBody(body:getId())))
end

--@api: LWorld:getBodyType
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newBody(100, 100, "dynamic")
    world:newBody(100, 220, "static")
    world:setBodyData(body:getId(), { role = "crate" })
    local data = world:getBodyData(body:getId())
    lurek.log.info("body type lookup=" .. world:getBodyType(body:getId()) .. " id=" .. body:getId())
    lurek.log.info("role=" .. data.role .. " world bodies=" .. world:getBodyCount())
end

--@api: LPhysicsShape:type
do

    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local minX, minY, maxX, maxY = shape:getBoundingBox()
    lurek.log.info("shape userdata=" .. shape:type())
    lurek.log.info("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:typeOf
do

    local shape = lurek.physics.newCircleShape(10)
    shape:setSensor(true)
    local isShape = shape:typeOf("LPhysicsShape")
    local isObject = shape:typeOf("LObject")
    local isBody = shape:typeOf("LBody")
    lurek.log.info("shape checks shape=" .. tostring(isShape) .. " object=" .. tostring(isObject))
    lurek.log.info("body check=" .. tostring(isBody) .. " userdata=" .. shape:type())
end

--@api: LPhysicsShape:destroy
do

    local shape = lurek.physics.newCircleShape(10)
    local before = shape:type()
    local radius = shape:getRadius()
    shape:destroy()
    local after = shape:getType()
    lurek.log.info("temporary shape type before=" .. before .. " after=" .. after)
    lurek.log.info("radius sample=" .. radius)
end

--- Physics Module Part 3: joints (revolute, distance, prismatic, weld, rope, wheel, mouse, motor, friction, gear, pulley)

--@api: LWorld:addRevoluteJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local pivot = world:newBody(200, 150, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jointId = world:addRevoluteJoint(pivot:getId(), arm:getId(), 200, 150)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addDistanceJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local bodyA = world:newCircleBody(100, 100, 10, "dynamic")
    local bodyB = world:newCircleBody(200, 100, 10, "dynamic")
    local jointId = world:addDistanceJoint(bodyA:getId(), bodyB:getId(), 0, 0, 0, 0, 100)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addPrismaticJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local rail = world:newBody(300, 300, "static")
    local slider = world:newBody(300, 300, "dynamic")
    local jointId = world:addPrismaticJoint(rail:getId(), slider:getId(), 300, 300, 1, 0)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addWeldJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local chassis = world:newBody(200, 200, "dynamic")
    local turret = world:newBody(200, 180, "dynamic")
    local jointId = world:addWeldJoint(chassis:getId(), turret:getId(), 200, 190)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addRopeJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(300, 50, "static")
    local weight = world:newCircleBody(300, 150, 8, "dynamic")
    local jointId = world:addRopeJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 120)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addWheelJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local car = world:newBody(200, 200, "dynamic")
    local wheel = world:newCircleBody(200, 230, 12, "dynamic")
    local jointId = world:addWheelJoint(car:getId(), wheel:getId(), 200, 230, 0, 1)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addMouseJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local box = world:newCircleBody(200, 200, 15, "dynamic")
    local jointId = world:addMouseJoint(box:getId(), 300, 100, 500)
    world:setMouseJointTarget(jointId, 400, 150)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addMotorJoint
do

    local world = lurek.physics.newWorld(0, 0)
    local platform = world:newBody(200, 200, "static")
    local mover = world:newBody(200, 200, "dynamic")
    local jointId = world:addMotorJoint(platform:getId(), mover:getId(), 0.5)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addFrictionJoint
do

    local world = lurek.physics.newWorld(0, 0)
    local ground = world:newBody(200, 400, "static")
    local puck = world:newCircleBody(200, 400, 10, "dynamic")
    local jointId = world:addFrictionJoint(ground:getId(), puck:getId(), 200, 400, 100, 50)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addGearJoint
do

    local world = lurek.physics.newWorld(0, 0)
    local gearA = world:newCircleBody(100, 200, 20, "dynamic")
    local gearB = world:newCircleBody(200, 200, 20, "dynamic")
    local jointId = world:addGearJoint(gearA:getId(), gearB:getId(), 150, 200)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:addPulleyJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local boxA = world:newCircleBody(100, 200, 10, "dynamic")
    local boxB = world:newCircleBody(300, 200, 10, "dynamic")
    local jointId = world:addPulleyJoint(boxA:getId(), boxB:getId(), 200, 50)
    lurek.log.info("joint_id=" .. tostring(jointId))
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jointId)))
end

--@api: LWorld:getJointIds
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    local ids = world:getJointIds()
    lurek.log.info("count=" .. tostring(#ids))
    lurek.log.info("first=" .. tostring(ids[1]))
end

--@api: LWorld:jointCount
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    lurek.log.info("joint_count=" .. tostring(world:jointCount()))
end

--@api: LWorld:getJointBodies
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    lurek.log.info("bodies=" .. tostring(world:getJointBodies(jid)))
end

--@api: LWorld:getJointType
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newCircleBody(100, 200, 10, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    lurek.log.info("joint_type=" .. tostring(world:getJointType(jid)))
end

--@api: LWorld:setJointLimits
do

    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
end

--@api: LWorld:getJointLimits
do

    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimits(jid, -math.pi / 4, math.pi / 4)
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
end

--@api: LWorld:setJointLimitsEnabled
do

    local world = lurek.physics.newWorld(0, 400)
    local anchor = world:newBody(200, 100, "static")
    local arm = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(anchor:getId(), arm:getId(), 200, 100)
    world:setJointLimitsEnabled(jid, true)
    lurek.log.info("limits=" .. tostring(world:getJointLimits(jid)))
end

--@api: LWorld:setJointMotorSpeed
do

    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    lurek.log.info("motor_speed=" .. tostring(world:getJointMotorSpeed(jid)))
end

--@api: LWorld:getJointMotorSpeed
do

    local world = lurek.physics.newWorld(0, 0)
    local hub = world:newBody(200, 200, "static")
    local blade = world:newBody(200, 200, "dynamic")
    local jid = world:addRevoluteJoint(hub:getId(), blade:getId(), 200, 200)
    world:setJointMotorSpeed(jid, 5.0)
    lurek.log.info("motor_speed=" .. tostring(world:getJointMotorSpeed(jid)))
end

--@api: LWorld:setJointBreakForce
do

    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    lurek.log.info("break_force=" .. tostring(world:getJointBreakForce(jid)))
end

--@api: LWorld:getJointBreakForce
do

    local world = lurek.physics.newWorld(0, 400)
    local ceiling = world:newBody(200, 50, "static")
    local weight = world:newCircleBody(200, 100, 10, "dynamic")
    local jid = world:addDistanceJoint(ceiling:getId(), weight:getId(), 0, 0, 0, 0, 50)
    world:setJointBreakForce(jid, 500)
    lurek.log.info("break_force=" .. tostring(world:getJointBreakForce(jid)))
end

--@api: LWorld:destroyJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    lurek.log.info("before=" .. tostring(world:jointCount()))
    world:destroyJoint(jid)
    lurek.log.info("after=" .. tostring(world:jointCount()))
end

--@api: LWorld:hasJoint
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newBody(100, 100, "static")
    local b = world:newBody(100, 200, "dynamic")
    local jid = world:addRevoluteJoint(a:getId(), b:getId(), 100, 100)
    lurek.log.info("has_joint=" .. tostring(world:hasJoint(jid)))
    world:destroyJoint(jid)
    lurek.log.info("has_joint_after_destroy=" .. tostring(world:hasJoint(jid)))
end

--- Physics Module Part 4: raycasting, instant beams, AABB queries, contacts, collision events

--@api: LWorld:raycast
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 20, "static")
    body:setLayer(0x2)
    local hit = world:raycast(0, 200, 600, 200, { layer = 0x1, mask = 0x2 })
    if hit then
        lurek.log.info("body=" .. tostring(hit.bodyId))
        lurek.log.info("point=" .. tostring(hit.x) .. " " .. tostring(hit.y))
        lurek.log.info("normal=" .. tostring(hit.normalX) .. " " .. tostring(hit.normalY))
    else
        lurek.log.info("body=" .. tostring(nil))
    end
end

--@api: LWorld:raycastClosest
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 300, 15, "static")
    body:setLayer(0x2)
    local hit = world:raycastClosest(200, 100, 0, 1, 500, { layer = 0x1, mask = 0x2 })
    if hit then
        lurek.log.info("body=" .. tostring(hit.bodyId))
        lurek.log.info("point=" .. tostring(hit.x) .. " " .. tostring(hit.y))
        lurek.log.info("toi=" .. tostring(hit.toi))
    else
        lurek.log.info("body=" .. tostring(nil))
    end
end

--@api: LWorld:raycastAll
do

    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 5 do
        local body = world:newCircleBody(100 + i * 80, 200, 10, "static")
        body:setLayer(0x2)
    end
    local hits = world:raycastAll(50, 200, 1, 0, 600, { layer = 0x1, mask = 0x2 })
    lurek.log.info("count=" .. tostring(#hits))
    if hits[1] then
        lurek.log.info("first=" .. tostring(hits[1].bodyId) .. " " .. tostring(hits[1].x) .. " " .. tostring(hits[1].y))
    end
end

--@api: LWorld:castCircle
do

    local world = lurek.physics.newWorld(0, 0)
    local sensor = world:newBody(120, 100, 8, 80, "sensor")
    local wall = world:newBody(160, 100, 8, 80, "static")
    local with_sensor = world:castCircle(40, 100, 6, 1, 0, 200, { includeSensors = true })
    local solid_hit = world:castCircle(40, 100, 6, 1, 0, 200, { includeSensors = false })
    lurek.log.info("sensor_first=" .. tostring(with_sensor and with_sensor.bodyId) .. " solid_owner=" .. tostring(sensor:getId()))
    lurek.log.info("solid_first=" .. tostring(solid_hit and solid_hit.bodyId) .. " wall_owner=" .. tostring(wall:getId()))
    lurek.log.info("solid_normal=" .. tostring(solid_hit and solid_hit.normalX) .. "," .. tostring(solid_hit and solid_hit.normalY))
end

--@api: LWorld:castBeam
do

local world = lurek.physics.newWorld(0, 0)
local mirror = world:newBody(120, 120, 8, 80, "static")
mirror:setMirror(true)
mirror:setBeamReflectivity(0.75)
local blocker = world:newBody(120, 40, 80, 8, "static")
local trace = world:castBeam(40, 120, 1, 0, 260, {
reflect = true,
maxBounces = 2,
energy = 1.0,
minEnergy = 0.2,
})
lurek.log.info("beam_hits=" .. tostring(#trace.hits))
lurek.log.info("beam_segments=" .. tostring(#trace.segments))
lurek.log.info("beam_reached_max=" .. tostring(trace.reachedMaxRange))
end

--@api: LWorld:reflectBodyVelocity
do

    local world = lurek.physics.newWorld(0, 0)
    local projectile = world:newCircleBody(40, 90, 4, "dynamic")
    projectile:setVelocity(120, -40)
    local ok = world:reflectBodyVelocity(projectile:getId(), 0, 1, 0.5)
    local vx, vy = projectile:getVelocity()
    lurek.log.info("reflected=" .. tostring(ok))
    lurek.log.info("velocity=" .. tostring(vx) .. "," .. tostring(vy))
    lurek.log.info("projectile=" .. tostring(projectile:getId()))
end

--@api: LWorld:beamClosest
do

local world = lurek.physics.newWorld(0, 0)
local shooter = world:newCircleBody(50, 260, 8, "dynamic")
shooter:setLayer(0x2)
local target = world:newCircleBody(190, 260, 14, "static")
target:setLayer(0x2)
local hit = world:beamClosest(50, 260, 1, 0, 240, {
excludeBody = shooter:getId(),
layer = 0x1,
mask = 0x2,
})
end

--@api: LWorld:beamAll
do

    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 3 do
        local body = world:newCircleBody(90 + i * 45, 320, 10, "static")
        body:setLayer(0x2)
    end
    local hits = world:beamAll(60, 320, 1, 0, 240, { layer = 0x1, mask = 0x2 })
    lurek.log.info("beam_all_count=" .. tostring(#hits))
    if hits[1] then
        lurek.log.info("beam_all_first=" .. tostring(hits[1].bodyId) .. " " .. tostring(hits[1].distance))
    end
    if hits[2] then
        lurek.log.info("beam_all_second=" .. tostring(hits[2].bodyId) .. " " .. tostring(hits[2].distance))
    end
end

--@api: LWorld:queryAABB
do

    local world = lurek.physics.newWorld(0, 400)
    local a = world:newCircleBody(100, 100, 10, "dynamic")
    local b = world:newCircleBody(150, 120, 10, "dynamic")
    local c = world:newCircleBody(500, 500, 10, "dynamic")
    a:setLayer(0x2)
    b:setLayer(0x2)
    c:setLayer(0x4)
    local found = world:queryAABB(50, 50, 200, 200, { layer = 0x1, mask = 0x2 })
    lurek.log.info("count=" .. tostring(#found))
    lurek.log.info("first=" .. tostring(found[1]))
end

--@api: LWorld:getBodyAtPoint
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(200, 200, 30, "static")
    body:setLayer(0x2)
    local hitId = world:getBodyAtPoint(210, 205, { layer = 0x1, mask = 0x2 })
    local missId = world:getBodyAtPoint(0, 0, { layer = 0x1, mask = 0x2 })
    lurek.log.info("hit=" .. tostring(hitId))
    lurek.log.info("miss=" .. tostring(missId))
end

--@api: LWorld:getContacts
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    local contacts = world:getContacts()
    lurek.log.info("count=" .. tostring(#contacts))
    lurek.log.info("ball=" .. tostring(ball:getId()))
    if contacts[1] then
        lurek.log.info("touching=" .. tostring(contacts[1].isTouching))
    end
end

--@api: LWorld:getBeginContactEvents
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    for _ = 1, 180 do
        world:step(1 / 60)
        local events = world:getBeginContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LWorld:getEndContactEvents
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    for _ = 1, 300 do
        world:step(1 / 60)
        local events = world:getEndContactEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LWorld:getCollisionEvents
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    world:newCircleBody(210, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getCollisionEvents()
        if #events > 0 then
            count = #events
            break
        end
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LWorld:setBeginContact
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local contactCount = 0
    world:setBeginContact(function(bodyA, bodyB)
        contactCount = contactCount + 1
        lurek.log.info("callback=" .. tostring(bodyA) .. " " .. tostring(bodyB))
    end)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(contactCount))
end

--@api: LWorld:setEndContact
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local endCount = 0
    world:setEndContact(function(bodyA, bodyB)
        endCount = endCount + 1
        lurek.log.info("callback=" .. tostring(bodyA) .. " " .. tostring(bodyB))
    end)
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(endCount))
end

--@api: LWorld:getBodyContacts
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 480, 10, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    local contacts = world:getBodyContacts(ball:getId())
    lurek.log.info("count=" .. tostring(#contacts))
    if contacts[1] then
        lurek.log.info("first=" .. tostring(contacts[1].bodyA) .. " " .. tostring(contacts[1].bodyB))
    end
end

--@api: lurek.physics.testAABB
do

    local overlap = lurek.physics.testAABB(0, 0, 50, 50, 25, 25, 50, 50)
    local miss = lurek.physics.testAABB(0, 0, 10, 10, 100, 100, 10, 10)
    local playerInsideHazard = lurek.physics.testAABB(30, 30, 16, 16, 20, 20, 40, 40)
    local pickupFarAway = lurek.physics.testAABB(30, 30, 16, 16, 120, 120, 8, 8)
    lurek.log.info("hazard overlap=" .. tostring(overlap) .. " player overlap=" .. tostring(playerInsideHazard))
    lurek.log.info("miss=" .. tostring(miss) .. " pickup far=" .. tostring(pickupFarAway))
end

--@api: lurek.physics.testCircleAABB
do

    local hit = lurek.physics.testCircleAABB(50, 50, 20, 30, 30, 40, 40)
    local miss = lurek.physics.testCircleAABB(0, 0, 5, 100, 100, 10, 10)
    local explosionHitsDoor = lurek.physics.testCircleAABB(160, 96, 24, 150, 80, 40, 60)
    local explosionMissesTower = lurek.physics.testCircleAABB(160, 96, 24, 260, 80, 40, 60)
    lurek.log.info("door splash hit=" .. tostring(hit) .. " explosion door=" .. tostring(explosionHitsDoor))
    lurek.log.info("miss=" .. tostring(miss) .. " tower miss=" .. tostring(explosionMissesTower))
end

--@api: lurek.physics.testCircles
do

    local touching = lurek.physics.testCircles(0, 0, 20, 30, 0, 20)
    local apart = lurek.physics.testCircles(0, 0, 5, 100, 0, 5)
    local bombHitsShield = lurek.physics.testCircles(200, 200, 18, 214, 200, 12)
    local bombMissesPlayer = lurek.physics.testCircles(200, 200, 18, 260, 200, 12)
    lurek.log.info("touching=" .. tostring(touching) .. " shield hit=" .. tostring(bombHitsShield))
    lurek.log.info("apart=" .. tostring(apart) .. " player miss=" .. tostring(bombMissesPlayer))
end

--- Physics Module Part 5: zones, cellular automaton, terrain, body data, sleeping, debug draw, CCD, advanced

--@api: LWorld:addZone
do

    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(100, 100, 200, 200)
    zone:setPriority(10)
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end

--@api: LZone:setGravityDirectional
do

    local world = lurek.physics.newWorld(0, 400)
    local windZone = world:addZone(0, 0, 300, 600)
    windZone:setGravityDirectional(200, 0)
    local ball = world:newCircleBody(50, 300, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end

--@api: LZone:setGravityPoint
do

    local world = lurek.physics.newWorld(0, 400)
    local vortex = world:addZone(400, 200, 150, 150)
    vortex:setGravityPoint(475, 275, 500)
    local ball = world:newCircleBody(450, 220, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end

--@api: LZone:setGravityRepulsor
do

    local world = lurek.physics.newWorld(0, 400)
    local repulsor = world:addZone(200, 200, 100, 100)
    repulsor:setGravityRepulsor(250, 250, 300)
    local ball = world:newCircleBody(240, 240, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end

--@api: LZone:setGravityZero
do

    local world = lurek.physics.newWorld(0, 400)
    local zeroG = world:addZone(400, 100, 200, 200)
    zeroG:setGravityZero()
    local ball = world:newCircleBody(450, 200, 8, "dynamic")
    for _ = 1, 60 do
        world:step(1 / 60)
    end
    lurek.log.info("position=" .. tostring(ball:getPosition()))
    lurek.log.info("velocity=" .. tostring(ball:getVelocity()))
end

--@api: LZone:setLinearDampingOverride
do

    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setLinearDampingOverride(3.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setVelocity(0, 100)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    lurek.log.info("velocity=" .. tostring(diver:getVelocity()))
    lurek.log.info("position=" .. tostring(diver:getPosition()))
end

--@api: LZone:setGravityAdditive
do

    local world = lurek.physics.newWorld(0, 60)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setGravityDirectional(0, -20)
    zone:setGravityAdditive(true)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("additive=" .. tostring(zone:isGravityAdditive()) .. " vy=" .. select(2, probe:getVelocity()))
end

--@api: LZone:isGravityAdditive
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 200, 200)
    local before = zone:isGravityAdditive()
    zone:setGravityAdditive(true)
    local after = zone:isGravityAdditive()
    lurek.log.info("additive before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LZone:setGravityFalloff
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 240, 240)
    zone:setGravityPoint(120, 120, 90)
    zone:setGravityFalloff("constant")
    local probe = world:newCircleBody(180, 120, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("falloff=" .. zone:getGravityFalloff() .. " vx=" .. select(1, probe:getVelocity()))
end

--@api: LZone:getGravityFalloff
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 240, 240)
    zone:setGravityFalloff("inverse")
    local mode = zone:getGravityFalloff()
    lurek.log.info("falloff=" .. tostring(mode))
end

--@api: LZone:setGravityRadius
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 300, 300)
    zone:setGravityPoint(150, 150, 200)
    zone:setGravityRadius(8, 90)
    local probe = world:newCircleBody(210, 150, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("radius-limited vx=" .. select(1, probe:getVelocity()))
end

--@api: LZone:setGravityLimits
do

    local world = lurek.physics.newWorld(0, 0)
    local zone = world:addZone(0, 0, 300, 300)
    zone:setGravityPoint(150, 150, 2000)
    zone:setGravityLimits(nil, 80)
    local probe = world:newCircleBody(230, 150, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("limited gravity vx=" .. select(1, probe:getVelocity()))
end

--@api: LZone:setLinearDrag
do

    local world = lurek.physics.newWorld(0, 0)
    local atmosphere = world:addZone(0, 0, 240, 240)
    atmosphere:setLinearDrag(2.5)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    probe:setVelocity(100, 0)
    world:step(1 / 60)
    lurek.log.info("linear drag vx=" .. select(1, probe:getVelocity()))
end

--@api: LZone:setQuadraticDrag
do

    local world = lurek.physics.newWorld(0, 0)
    local nebula = world:addZone(0, 0, 240, 240)
    nebula:setQuadraticDrag(0.04)
    local probe = world:newCircleBody(80, 80, 8, "dynamic")
    probe:setVelocity(120, 0)
    world:step(1 / 60)
    lurek.log.info("quadratic drag vx=" .. select(1, probe:getVelocity()))
end

--@api: LZone:setAngularDampingOverride
do

    local world = lurek.physics.newWorld(0, 400)
    local water = world:addZone(100, 300, 400, 200)
    water:setAngularDampingOverride(2.0)
    local diver = world:newCircleBody(300, 310, 8, "dynamic")
    diver:setAngularVelocity(5)
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    lurek.log.info("angular_velocity=" .. tostring(diver:getAngularVelocity()))
    lurek.log.info("angle=" .. tostring(diver:getAngle()))
end

--@api: LZone:setCircle
do

    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(200, 200, 100, 100)
    zone:setCircle(250, 250, 80)
    zone:setGravityZero()
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end

--@api: LWorld:getZoneEvents
do

    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(150, 300, 200, 100)
    zone:setEnabled(true)
    world:newCircleBody(250, 100, 8, "dynamic")
    local count = 0
    for _ = 1, 120 do
        world:step(1 / 60)
        local events = world:getZoneEvents()
        count = count + #events
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LZone:destroy
do

    local world = lurek.physics.newWorld(0, 400)
    local zone = world:addZone(0, 0, 100, 100)
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    zone:destroy()
    lurek.log.info("events=" .. tostring(#world:getZoneEvents()))
end

--@api: lurek.physics.newTerrain
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(128, 64, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 128, 40, false)
    terrain:flush()
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LTerrain:setCell
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:getCell
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:setCell(5, 5, true)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LTerrain:fillRect
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(64, 64, 8, world)
    terrain:fillRect(80, 80, 40, 40, false)
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("cell=" .. tostring(terrain:getCell(10, 10)))
end

--@api: LTerrain:carveCircle
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:carveCircle(64, 64, 18)
    lurek.log.info("center=" .. tostring(terrain:getCell(8, 8)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:addCircle
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(false)
    terrain:addCircle(64, 64, 18)
    lurek.log.info("center=" .. tostring(terrain:getCell(8, 8)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:carveRect
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:carveRect(40, 40, 24, 24)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:addRect
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(false)
    terrain:addRect(40, 40, 24, 24)
    lurek.log.info("cell=" .. tostring(terrain:getCell(5, 5)))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:collapseColumns
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    terrain:flush()
    lurek.log.info("collapsed=" .. tostring(terrain:collapseColumns()))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:damageCircle
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    local result = terrain:damageCircle(64, 64, 18, {
        collapse = true,
        support = "bottom",
        mode = "remove",
        minComponentCells = 2,
    })
    lurek.log.info("removed=" .. tostring(result.removedCells))
    lurek.log.info("components=" .. tostring(result.components))
end

--@api: LTerrain:collapseUnsupported
do

local world = lurek.physics.newWorld(0, 400)
local terrain = lurek.physics.newTerrain(32, 32, 8, world)
terrain:fillRect(0, 248, 256, 8, true)
terrain:addRect(72, 72, 24, 24)
local debris_result = terrain:collapseUnsupported({
support = "bottom",
mode = "spawnDebris",
minComponentCells = 2,
maxDebris = 2,
})
local terrain2 = lurek.physics.newTerrain(32, 32, 8, world)
terrain2:addRect(72, 72, 24, 24)
end

--@api: LTerrain:solidPositions
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:fillRect(80, 0, 96, 120, false)
    local solids = terrain:solidPositions()
    lurek.log.info("count=" .. tostring(#solids))
    if solids[1] then
        lurek.log.info("first=" .. tostring(solids[1].x) .. " " .. tostring(solids[1].y))
    end
end

--@api: LTerrain:spawnDebris
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 8, world)
    terrain:fillAll(true)
    terrain:flush()
    local debris = terrain:spawnDebris({ { x = 64, y = 64 }, { x = 72, y = 64 } }, 1.0, 0.2)
    lurek.log.info("count=" .. tostring(#debris))
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end

--@api: LTerrain:toBytes
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local bytes = terrain:toBytes()
    lurek.log.info("bytes=" .. tostring(#bytes))
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
end

--@api: LTerrain:getDirtyChunks
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local dirty = terrain:getDirtyChunks()
    terrain:flush(1)
    local remaining = terrain:getDirtyChunks()
    lurek.log.info("terrain dirty before=" .. tostring(#dirty))
    lurek.log.info("terrain dirty after budget=" .. tostring(#remaining))
end

--@api: LTerrain:loadFromBytes
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    local bytes = terrain:toBytes()
    local clone = lurek.physics.newTerrain(32, 32, 4, world)
    lurek.log.info("loaded=" .. tostring(clone:loadFromBytes(bytes)))
    lurek.log.info("cell=" .. tostring(clone:getCell(0, 0)))
end

--@api: LTerrain:toImageData
do

    local world = lurek.physics.newWorld(0, 400)
    local terrain = lurek.physics.newTerrain(32, 32, 4, world)
    terrain:fillAll(true)
    terrain:fillCircle(64, 64, 24, false)
    local pixels = terrain:toImageData(255, 255, 255, 0, 0, 0)
    lurek.log.info("bytes=" .. tostring(#pixels))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LWorld:setBodyData
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player", hp = 100 })
    local data = world:getBodyData(player:getId())
    lurek.log.info("tag=" .. tostring(data.tag))
    lurek.log.info("hp=" .. tostring(data.hp))
end

--@api: LWorld:getBodyData
do

    local world = lurek.physics.newWorld(0, 400)
    local enemy = world:newCircleBody(300, 100, 10, "dynamic")
    world:setBodyData(enemy:getId(), { tag = "enemy", hp = 50 })
    local data = world:getBodyData(enemy:getId())
    lurek.log.info("tag=" .. tostring(data.tag))
    lurek.log.info("hp=" .. tostring(data.hp))
end

--@api: LWorld:clearBodyData
do

    local world = lurek.physics.newWorld(0, 400)
    local player = world:newCircleBody(100, 100, 10, "dynamic")
    world:setBodyData(player:getId(), { tag = "player" })
    world:clearBodyData(player:getId())
    lurek.log.info("data=" .. tostring(world:getBodyData(player:getId())))
end

--@api: LWorld:setBodyOneWay
do

    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    local player = world:newCircleBody(200, 320, 10, "dynamic")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    world:step(1 / 60)
    lurek.log.info("one-way normal=" .. nx .. "," .. ny)
    lurek.log.info("player above platform y=" .. select(2, player:getPosition()))
end

--@api: LWorld:getBodyOneWay
do

    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    local nx, ny = world:getBodyOneWay(platform:getId())
    local coin = world:newBody(220, 360, "sensor")
    world:step(1 / 60)
    lurek.log.info("queried one-way normal=" .. nx .. "," .. ny)
    lurek.log.info("platform=" .. platform:getType() .. " helper=" .. coin:getType())
end

--@api: LWorld:clearBodyOneWay
do

    local world = lurek.physics.newWorld(0, 400)
    local platform = world:newBody(200, 400, "static")
    world:setBodyOneWay(platform:getId(), 0, -1)
    world:clearBodyOneWay(platform:getId())
    lurek.log.info("normal=" .. tostring(world:getBodyOneWay(platform:getId())))
end

--@api: LWorld:setBodyCCD
do

    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    lurek.log.info("ccd=" .. tostring(world:getBodyCCD(bullet:getId())))
    lurek.log.info("id=" .. tostring(bullet:getId()))
end

--@api: LWorld:getBodyCCD
do

    local world = lurek.physics.newWorld(0, 0)
    local bullet = world:newCircleBody(100, 100, 3, "dynamic")
    world:setBodyCCD(bullet:getId(), true)
    lurek.log.info("ccd=" .. tostring(world:getBodyCCD(bullet:getId())))
    lurek.log.info("velocity=" .. tostring(bullet:getVelocity()))
end

--@api: LWorld:sleepBody
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
end

--@api: LWorld:wakeUpBody
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    world:wakeUpBody(body:getId())
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
end

--@api: LWorld:isBodySleeping
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    body:setSleepingAllowed(true)
    world:sleepBody(body:getId())
    lurek.log.info("sleeping=" .. tostring(world:isBodySleeping(body:getId())))
end

--@api: LWorld:drawDebug
do

    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(200, 200, 20, "dynamic")
    local img = lurek.image.newImageData(800, 600)
    local ok, err = pcall(function() world:drawDebug(img, 0, 255, 0, 200) end)
    if ok then lurek.log.info("image", img:type()) else lurek.log.info("drawDebug skipped: " .. tostring(err)) end
end

--@api: lurek.physics.debugDraw
do

    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 15, "dynamic")
    lurek.physics.debugDraw(true)
    lurek.physics.drawDebugGpu(world, { lineWidth = 2 })
    lurek.log.info("body_count=" .. tostring(world:getBodyCount()))
end

--@api: lurek.physics.destroyWorld
do

    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    lurek.physics.destroyWorld(world)
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
end

--@api: LWorld:clear
do

    local world = lurek.physics.newWorld(0, 400)
    world:newCircleBody(100, 100, 10, "dynamic")
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    world:clear()
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
end

--@api: lurek.physics.step
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    local floor = world:newBody(100, 240, "static")
    body:setVelocity(20, -30)
    lurek.physics.step(world, 1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    lurek.log.info("module step pos=" .. x .. "," .. y)
    lurek.log.info("velocity=" .. vx .. "," .. vy .. " floor=" .. floor:getType())
end

--@api: lurek.physics.getCollisions
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    for _ = 1, 120 do
        lurek.physics.step(world, 1 / 60)
    end
    local collisions = lurek.physics.getCollisions(world)
    lurek.log.info("count=" .. tostring(#collisions))
    if collisions[1] then
        lurek.log.info("first=" .. tostring(collisions[1].body_a) .. " " .. tostring(collisions[1].body_b))
    end
end

--@api: lurek.physics.isSleepingAllowed
do

    local world = lurek.physics.newWorld(0, 400)
    local body = world:newCircleBody(100, 100, 10, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, true)
    lurek.log.info("allowed=" .. tostring(lurek.physics.isSleepingAllowed(world, body)))
    lurek.physics.setSleepingAllowed(world, body, false)
    lurek.log.info("allowed_after=" .. tostring(lurek.physics.isSleepingAllowed(world, body)))
end

--- Physics Module Part 5: LBody dims, LCellular, LPhysicsShape, LTerrain, LWorld advanced, LZone, module fns

--@api: LBody:getHeight
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(32, 48)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    lurek.log.info("character height=" .. body:getHeight() .. " width=" .. body:getWidth())
    lurek.log.info("spawn pos=" .. select(1, body:getPosition()) .. "," .. select(2, body:getPosition()))
end

--@api: LBody:getId
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    world:setBodyData(body:getId(), { kind = "spawn_marker" })
    local data = world:getBodyData(body:getId())
    world:step(1 / 60)
    lurek.log.info("body id=" .. body:getId() .. " kind=" .. data.kind)
    lurek.log.info("spawn x=" .. body:getX() .. " y=" .. body:getY())
end

--@api: LBody:getPosition
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(14, -8)
    world:step(1 / 60)
    local x, y = body:getPosition()
    lurek.log.info("patrol body id=" .. body:getId())
    lurek.log.info("current position=" .. x .. "," .. y)
end

--@api: LBody:getWidth
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    local collider = lurek.physics.newRectangleShape(48, 20)
    lurek.physics.attachShape(body, collider)
    world:step(1 / 60)
    lurek.log.info("bridge plank width=" .. body:getWidth())
    lurek.log.info("bridge plank height=" .. body:getHeight())
end

--@api: LBody:getX
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(12, 0)
    world:step(1 / 60)
    local x = body:getX()
    local y = body:getY()
    lurek.log.info("spawn marker x=" .. x)
    lurek.log.info("paired y=" .. y)
end

--@api: LBody:getY
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 100, 100, "dynamic")
    body:setVelocity(0, -10)
    world:step(1 / 60)
    local y = body:getY()
    local x = body:getX()
    lurek.log.info("spawn marker y=" .. y)
    lurek.log.info("paired x=" .. x)
end

--@api: LPhysicsShape:getBoundingBox
do

    local circle = lurek.physics.newCircleShape(10.0)
    circle:setSensor(true)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    lurek.log.info("sensor bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
    lurek.log.info("shape type=" .. circle:getType())
end

--@api: LPhysicsShape:getRadius
do

    local circle = lurek.physics.newCircleShape(10.0)
    circle:setDensity(1.5)
    local radius = circle:getRadius()
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    lurek.log.info("blast radius=" .. radius)
    lurek.log.info("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LPhysicsShape:getType
do

    local circle = lurek.physics.newCircleShape(10.0)
    circle:setRestitution(0.2)
    local minX, minY, maxX, maxY = circle:getBoundingBox()
    lurek.log.info("collider kind=" .. circle:getType())
    lurek.log.info("preview bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: LTerrain:fillAll
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LTerrain:fillCircle
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    terrain:fillCircle(256, 256, 50, false)
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LTerrain:flush
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(64, 16, 16, world)
    terrain:fillAll(true)
    local first = terrain:flush(2)
    local second = terrain:flush()
    lurek.log.info("rebuilt=" .. tostring(first.dirtyChunksRebuilt))
    lurek.log.info("remaining=" .. tostring(first.dirtyChunksRemaining))
    lurek.log.info("final_remaining=" .. tostring(second.dirtyChunksRemaining))
end

--@api: LTerrain:isDirty
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(true)
    lurek.log.info("dirty=" .. tostring(terrain:isDirty()))
    lurek.log.info("type=" .. tostring(terrain:type()))
end

--@api: LTerrain:type
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillRect(32, 400, 96, 32, true)
    terrain:flush()
    lurek.log.info("terrain userdata=" .. terrain:type())
    lurek.log.info("terrain inheritance=" .. tostring(terrain:typeOf("LTerrain")))
end

--@api: LTerrain:typeOf
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillAll(false)
    terrain:setCell(1, 1, true)
    local isTerrain = terrain:typeOf("LTerrain")
    local isObject = terrain:typeOf("LObject")
    lurek.log.info("terrain check=" .. tostring(isTerrain) .. " object=" .. tostring(isObject))
    lurek.log.info("terrain userdata=" .. terrain:type())
end

--@api: LTerrain:setColliderStrategy
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:fillRect(0, 256, 512, 32, true)
    terrain:setColliderStrategy("contourEdges")
    local report = terrain:flush()
    lurek.log.info("terrain strategy=" .. terrain:getColliderStrategy())
    lurek.log.info("rebuilt chunks=" .. tostring(report.dirtyChunksRebuilt))
end

--@api: LTerrain:getColliderStrategy
do

    local world = lurek.physics.newWorld(0, 9.8)
    local terrain = lurek.physics.newTerrain(32, 32, 16, world)
    terrain:setColliderStrategy("rowRuns")
    terrain:fillAll(true)
    local strategy = terrain:getColliderStrategy()
    local report = terrain:flush()
    lurek.log.info("terrain strategy=" .. strategy .. " rebuilt=" .. tostring(report.dirtyChunksRebuilt))
end

--@api: lurek.physics.newLiquidMap
do

    local world = lurek.physics.newWorld(0, 200)
    local terrain = lurek.physics.newTerrain(16, 16, 8, world)
    local liquid = lurek.physics.newLiquidMap(16, 16, 8, world, terrain)
    liquid:setCell(4, 4, 1.0, "water")
    local amount = liquid:getAmountAt(36, 36)
    lurek.log.info("liquid amount=" .. tostring(amount))
    lurek.log.info("liquid type=" .. tostring(liquid:type()))
end

--@api: LLiquidMap:setCell
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(2, 3, 0.75, "water")
    local amount, kind = liquid:getCell(2, 3)
    lurek.log.info("setCell amount=" .. tostring(amount))
    lurek.log.info("setCell kind=" .. tostring(kind))
end

--@api: LLiquidMap:getCell
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(1, 1, 0.5, "lava")
    local amount, kind = liquid:getCell(1, 1)
    lurek.log.info("getCell amount=" .. tostring(amount))
    lurek.log.info("getCell kind=" .. tostring(kind))
end

--@api: LLiquidMap:fillRect
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(10, 10, 8, world)
    liquid:fillRect(2, 2, 3, 2, 1.0, "water")
    local amount, kind = liquid:getCell(3, 3)
    lurek.log.info("fillRect amount=" .. tostring(amount))
    lurek.log.info("fillRect kind=" .. tostring(kind))
end

--@api: LLiquidMap:drainRect
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(10, 10, 8, world)
    liquid:fillRect(2, 2, 3, 2, 1.0, "water")
    liquid:drainRect(2, 2, 3, 2, 0.4)
    local amount = select(1, liquid:getCell(3, 3))
    lurek.log.info("drainRect amount=" .. tostring(amount))
    lurek.log.info("drainRect type=" .. tostring(liquid:type()))
end

--@api: LLiquidMap:step
do

local world = lurek.physics.newWorld(0, 200)
local terrain = lurek.physics.newTerrain(8, 8, 8, world)
for x = 1, 6 do
terrain:setCell(x, 6, true)
end
for y = 2, 6 do
terrain:setCell(1, y, true)
terrain:setCell(6, y, true)
end
local liquid = lurek.physics.newLiquidMap(8, 8, 8, world, terrain)
liquid:fillRect(2, 2, 3, 3, 1.0, "water")
terrain:setCell(3, 6, false)
local stats = nil
for _ = 1, 18 do
stats = liquid:step({ gravityFlow = 1.0, sidewaysFlow = 0.5, pressureFlow = 0.15, maxSteps = 2 })
end
end

--@api: LLiquidMap:getAmountAt
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(2, 3, 0.6, "acid")
    local amount = liquid:getAmountAt(20, 28)
    local outside = liquid:getAmountAt(1000, 1000)
    lurek.log.info("amountAt inside=" .. tostring(amount))
    lurek.log.info("amountAt outside=" .. tostring(outside))
end

--@api: LLiquidMap:getLevelAt
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(4, 4, 1.0, "water")
    liquid:setCell(4, 3, 0.5, "water")
    local level = liquid:getLevelAt(36, 24)
    lurek.log.info("levelAt y=" .. tostring(level))
    lurek.log.info("levelAt type=" .. tostring(liquid:type()))
end

--@api: LLiquidMap:applyBuoyancy
do

    local world = lurek.physics.newWorld(0, 200)
    local body = world:newCircleBody(20, 20, 6, "dynamic")
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local stats = liquid:applyBuoyancy({ density = 3.0, drag = 1.0 })
    world:step(1 / 60)
    lurek.log.info("buoyancy submerged=" .. tostring(stats.submergedBodies))
    lurek.log.info("buoyancy vy=" .. tostring(select(2, body:getVelocity())))
end

--@api: LLiquidMap:toBytes
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local bytes = liquid:toBytes()
    lurek.log.info("liquid bytes=" .. tostring(#bytes))
    lurek.log.info("liquid type=" .. tostring(liquid:type()))
end

--@api: LLiquidMap:getDirtyChunks
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(2, 3, 0.75, "water")
    local dirty = liquid:getDirtyChunks()
    local first = dirty[1] or { cx = -1, cy = -1 }
    lurek.log.info("liquid dirty chunks=" .. tostring(#dirty))
    lurek.log.info("liquid first dirty=" .. tostring(first.cx) .. "," .. tostring(first.cy))
end

--@api: LLiquidMap:loadFromBytes
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 3, 3, 1.0, "water")
    local bytes = liquid:toBytes()
    local clone = lurek.physics.newLiquidMap(8, 8, 8, world)
    lurek.log.info("liquid loaded=" .. tostring(clone:loadFromBytes(bytes)))
    lurek.log.info("liquid cell=" .. tostring(select(1, clone:getCell(1, 1))))
end

--@api: LLiquidMap:type
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:fillRect(1, 1, 2, 2, 1.0, "water")
    local kind = select(2, liquid:getCell(1, 1))
    lurek.log.info("liquid userdata=" .. tostring(liquid:type()))
    lurek.log.info("liquid kind=" .. tostring(kind))
end

--@api: LLiquidMap:typeOf
do

    local world = lurek.physics.newWorld(0, 0)
    local liquid = lurek.physics.newLiquidMap(8, 8, 8, world)
    liquid:setCell(1, 1, 1.0, "water")
    local isLiquid = liquid:typeOf("LLiquidMap")
    local isObject = liquid:typeOf("LObject")
    lurek.log.info("liquid inheritance=" .. tostring(isLiquid))
    lurek.log.info("liquid object=" .. tostring(isObject))
end

--@api: LWorld:addFixture
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local fid = world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    lurek.log.info("fixture=" .. tostring(fid))
    lurek.log.info("count=" .. tostring(world:fixtureCount(body:getId())))
end

--@api: LWorld:clearBeginContact
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    world:newCircleBody(200, 100, 10, "dynamic")
    local count = 0
    world:setBeginContact(function()
        count = count + 1
    end)
    world:clearBeginContact()
    for _ = 1, 120 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LWorld:clearEndContact
do

    local world = lurek.physics.newWorld(0, 400)
    world:newBody(200, 500, "static")
    local ball = world:newCircleBody(200, 100, 10, "dynamic")
    ball:setRestitution(0.9)
    local count = 0
    world:setEndContact(function()
        count = count + 1
    end)
    world:clearEndContact()
    for _ = 1, 300 do
        world:step(1 / 60)
    end
    lurek.log.info("count=" .. tostring(count))
end

--@api: LWorld:destroyBody
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    lurek.log.info("before=" .. tostring(world:getBodyCount()))
    world:destroyBody(body:getId())
    lurek.log.info("after=" .. tostring(world:getBodyCount()))
end

--@api: LWorld:fixtureCount
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:addFixture(body:getId(), "circle", 1.0, 0.3, 0.5, false, 5.0)
    world:addFixture(body:getId(), "rectangle", 1.0, 0.6, 0.1, false, 12.0, 4.0)
    world:step(1 / 60)
    lurek.log.info("fixture count=" .. world:fixtureCount(body:getId()))
    lurek.log.info("body type=" .. body:getType())
end

--@api: LWorld:setBodyType
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    world:setBodyType(body:getId(), "static")
    body:setPosition(32, 64)
    world:step(1 / 60)
    lurek.log.info("builder converted type=" .. world:getBodyType(body:getId()))
    lurek.log.info("placement=" .. body:getX() .. "," .. body:getY())
end

--@api: LWorld:setMouseJointTarget
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = world:newBody(0, 0, "dynamic")
    local jid = world:addMouseJoint(body:getId(), 0, 0, 1000)
    world:setMouseJointTarget(jid, 50, 50)
    lurek.log.info("joint=" .. tostring(jid))
    lurek.log.info("type=" .. tostring(world:getJointType(jid)))
end

--@api: LZone:getId
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setGravityZero()
    local scout = world:newCircleBody(60, 60, 8, "dynamic")
    world:step(1 / 60)
    lurek.log.info("zone id=" .. zone:getId() .. " type=" .. zone:type())
    lurek.log.info("scout y=" .. select(2, scout:getPosition()))
end

--@api: LZone:setEnabled
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end

--@api: LZone:setLayerMask
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setLayerMask(0xFF)
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end

--@api: LZone:setPriority
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(1)
    lurek.log.info("zone_id=" .. tostring(zone:getId()))
    lurek.log.info("type=" .. tostring(zone:type()))
end

--@api: LZone:type
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setPriority(2)
    zone:setGravityDirectional(0, -50)
    local probe = world:newCircleBody(40, 40, 8, "dynamic")
    lurek.log.info("zone userdata=" .. zone:type())
    lurek.log.info("zone check=" .. tostring(zone:typeOf("LZone")) .. " probe=" .. probe:getType())
end

--@api: LZone:typeOf
do

    local world = lurek.physics.newWorld(0, 9.8)
    local zone = world:addZone(0, 0, 200, 200)
    zone:setEnabled(true)
    local isZone = zone:typeOf("LZone")
    local isObject = zone:typeOf("LObject")
    local isWorld = zone:typeOf("LWorld")
    lurek.log.info("zone checks zone=" .. tostring(isZone) .. " object=" .. tostring(isObject))
    lurek.log.info("world check=" .. tostring(isWorld) .. " userdata=" .. zone:type())
end

--@api: lurek.physics.drawDebugGpu
do

    local world = lurek.physics.newWorld(0, 9.8)
    world:newBody(120, 200, "static")
    world:newCircleBody(120, 120, 10, "dynamic")
    lurek.physics.drawDebugGpu(world, {})
    world:step(1 / 60)
    lurek.log.info("gpu debug scene bodies=" .. world:getBodyCount())
    lurek.log.info("world type=" .. world:type())
end

--@api: lurek.physics.getBody
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    body:setVelocity(10, 5)
    world:step(1 / 60)
    local x, y, vx, vy = lurek.physics.getBody(world, body)
    lurek.log.info("free-function body pos=" .. x .. "," .. y)
    lurek.log.info("free-function velocity=" .. vx .. "," .. vy)
end

--@api: lurek.physics.newBody
do

    local world = lurek.physics.newWorld(0, 0)
    local body = lurek.physics.newBody(world, 50, 50, "static")
    local checkpoint = lurek.physics.newBody(world, 80, 50, "sensor")
    world:step(1 / 60)
    lurek.log.info("spawned wall id=" .. body:getId() .. " type=" .. body:getType())
    lurek.log.info("checkpoint type=" .. checkpoint:getType() .. " bodies=" .. world:getBodyCount())
end

--@api: LChainShape:getType
do

    local chain = lurek.physics.newChainShape(false, 0, 0, 10, 0, 10, 10, 0, 10)
    chain:setFriction(0.5)
    local minX, minY, maxX, maxY = chain:getBoundingBox()
    lurek.log.info("chain kind=" .. chain:getType())
    lurek.log.info("bounds=" .. minX .. "," .. minY .. " -> " .. maxX .. "," .. maxY)
end

--@api: lurek.physics.setBodyVelocity
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setBodyVelocity(world, body, 10, 5)
    world:step(1 / 60)
    local vx, vy = body:getVelocity()
    lurek.log.info("dash velocity=" .. vx .. "," .. vy)
    lurek.log.info("dash position=" .. body:getX() .. "," .. body:getY())
end

--@api: lurek.physics.setSleepingAllowed
do

    local world = lurek.physics.newWorld(0, 9.8)
    local body = lurek.physics.newBody(world, 0, 0, "dynamic")
    lurek.physics.setSleepingAllowed(world, body, false)
    world:step(1 / 60)
    local allowed = body:isSleepingAllowed()
    local valid = body:isValid()
    lurek.log.info("always-awake enemy allowed=" .. tostring(allowed))
    lurek.log.info("body still valid=" .. tostring(valid))
end

--@api: lurek.physics.testPoint
do

    local inside = lurek.physics.testPoint(5, 5, 0, 0, 10, 10)
    local outside = lurek.physics.testPoint(20, 20, 0, 0, 10, 10)
    local buttonHover = lurek.physics.testPoint(42, 18, 32, 8, 24, 24)
    local missHover = lurek.physics.testPoint(80, 18, 32, 8, 24, 24)
    lurek.log.info("inside tile=" .. tostring(inside) .. " ui hover=" .. tostring(buttonHover))
    lurek.log.info("outside tile=" .. tostring(outside) .. " hover miss=" .. tostring(missHover))
end
--@api: lurek.physics.shapeFromImage
do
    local img = lurek.image.newImageData(32, 32)
    img:drawCircle(16, 16, 9, 255, 255, 255, 255)
    local shape = lurek.physics.shapeFromImage(img, { alphaThreshold = 1, maxVertices = 8 })
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(20, 20, "dynamic")
    lurek.physics.attachShape(body, shape)
    lurek.log.info("[physics] alpha shape type=" .. shape:getType() .. " body=" .. tostring(body:getId()))
end

--@api: LPhysicsShape:getVertexCount
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 16, 20, 4, 255, 255, 255, 255)
    img:drawRect(16, 4, 4, 20, 255, 255, 255, 255)
    local shape = lurek.physics.shapeFromImage(img, { alphaThreshold = 1, rectangleFillThreshold = 1.0 })
    local count = shape:getVertexCount()
    local x1, y1, x2, y2 = shape:getBoundingBox()
    lurek.log.info("[physics] alpha vertices=" .. tostring(count) .. " bounds=" .. tostring(x1) .. "," .. tostring(y1) .. "," .. tostring(x2) .. "," .. tostring(y2))
end

--@api: LPhysicsShape:getVertices
do
    local shape = lurek.physics.newRectangleShape(18, 10)
    local vertices = shape:getVertices()
    local first = vertices and vertices[1] or { x = 0, y = 0 }
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(0, 0, "static")
    lurek.physics.attachShape(body, shape)
    lurek.log.info("[physics] first vertex=" .. tostring(first.x) .. "," .. tostring(first.y) .. " count=" .. tostring(#vertices))
end

--@api: LWorld:sampleFlow
do
    local world = lurek.physics.newWorld(0, 0)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 120,
        h = 60,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 30,
    })
    local sample = world:sampleFlow(20, 20)
    lurek.log.info("[physics] flow sample=" .. string.format("%.2f,%.2f", sample.vx, sample.vy))
end

--@api: LWorld:addFlowField
do
local world = lurek.physics.newWorld(0, 220)
local field = world:addFlowField({
name = "canyon_wind",
geometry = "path",
points = {
{ x = 80, y = 180 },
{ x = 200, y = 160 },
{ x = 340, y = 190 },
},
width = 70,
strength = 180,
direction = "alongPath",
application = "acceleration",
})
local projectile = world:newCircleBody(120, 120, 4, "dynamic")
projectile:setBullet(true)
end

--@api: LWorld:addFan
do
    local world = lurek.physics.newWorld(0, 0)
    local fan = world:addFan({
        x = 80,
        y = 80,
        radius = 72,
        widthAngle = 70,
        directionVector = { x = 1, y = -0.2 },
        strength = 120,
    })
    local sample = world:sampleFlow(120, 72)
    lurek.log.info("[physics] fan id=" .. tostring(fan:getId()) .. " sample=" .. string.format("%.2f,%.2f", sample.vx, sample.vy))
end

--@api: LWorld:removeFlowField
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 32,
        h = 32,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    world:removeFlowField(field:getId())
    local info = world:getFlowField(field:getId())
    lurek.log.info("[physics] removed=" .. tostring(info ~= nil and not info.enabled))
end

--@api: LWorld:getFlowField
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        name = "fan",
        geometry = "circle",
        x = 64,
        y = 64,
        radius = 32,
        direction = "radialOut",
        strength = 35,
    })
    field:setEnabled(false)
    local info = world:getFlowField(field:getId())
    lurek.log.info("[physics] flow geometry=" .. tostring(info.geometry) .. " enabled=" .. tostring(info.enabled))
    lurek.log.info("[physics] flow strength=" .. tostring(info.strength))
end

--@api: LWorld:clearFlowFields
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 20,
        h = 20,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 15,
    })
    world:clearFlowFields()
    lurek.log.info("[physics] flow count after clear=" .. tostring(world:getStats().flowFields))
    lurek.log.info("[physics] first disabled=" .. tostring(not world:getFlowField(field:getId()).enabled))
end

--@api: LWorld:drawFlowDebug
do
    local world = lurek.physics.newWorld(0, 0)
    world:addFlowField({
        geometry = "rect",
        x = 10,
        y = 10,
        w = 30,
        h = 20,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 25,
    })
    local img = lurek.image.newImageData(64, 64)
    world:drawFlowDebug(img, { arrowSpacing = 16 })
    local _, _, _, a = img:getPixel(10, 10)
    lurek.log.info("[physics] flow debug alpha=" .. tostring(a))
end

--@api: LWorld:drawAltitudeDebug
do
    local world = lurek.physics.newWorld(0, 0)
    local layer = lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(1, 1, 6)
    layer:setCellClearance(1, 1, 8)
    world:setAltitudeLayer(layer)
    local body = world:newBody(24, 24, 10, 10, "static")
    body:setAltitudeMode("fixed")
    body:setAltitude(6)
    body:setHeightExtent(4)
    world:spawnBallisticProjectile({ from = { x = 8, y = 40, z = 2 }, target = { x = 40, y = 40, z = 8 }, speed = 16, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25 })
    local img = lurek.image.newImageData(64, 64)
    world:drawAltitudeDebug(img)
    local _, _, _, a = img:getPixel(24, 24)
    lurek.log.info("[physics] altitude debug alpha=" .. tostring(a))
end

--@api: LFlowStream:getId
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    lurek.log.info("[physics] flow id=" .. tostring(field:getId()))
end

--@api: LFlowStream:setEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    field:setEnabled(false)
    lurek.log.info("[physics] enabled after set=" .. tostring(field:isEnabled()))
end

--@api: LFlowStream:isEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 0, y = 1 },
        strength = 18,
    })
    lurek.log.info("[physics] flow enabled=" .. tostring(field:isEnabled()))
end

--@api: LFlowStream:setStrength
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 10,
    })
    field:setStrength(55)
    lurek.log.info("[physics] flow strength now=" .. tostring(field:getStrength()))
end

--@api: LFlowStream:getStrength
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 22,
    })
    lurek.log.info("[physics] getStrength=" .. tostring(field:getStrength()))
end

--@api: LFlowStream:setWidth
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "path",
        points = {
            { x = 0, y = 0 },
            { x = 48, y = 0 },
        },
        width = 10,
        strength = 20,
    })
    field:setWidth(18)
    lurek.log.info("[physics] path width=" .. tostring(world:getFlowField(field:getId()).width))
end

--@api: LFlowStream:setPoints
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "path",
        points = {
            { x = 0, y = 0 },
            { x = 20, y = 0 },
        },
        width = 8,
        strength = 20,
    })
    field:setPoints({
        { x = 0, y = 0 },
        { x = 0, y = 40 },
        { x = 16, y = 56 },
    })
    lurek.log.info("[physics] path points=" .. tostring(#world:getFlowField(field:getId()).points))
end

--@api: LFlowStream:setLayerMask
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setLayerMask(0x8)
    lurek.log.info("[physics] layer mask=" .. tostring(field:getLayerMask()))
end

--@api: LFlowStream:getLayerMask
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
        layerMask = 0x4,
    })
    lurek.log.info("[physics] getLayerMask=" .. tostring(field:getLayerMask()))
end

--@api: LFlowStream:setApplication
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setApplication("targetVelocityDrag")
    lurek.log.info("[physics] application=" .. tostring(world:getFlowField(field:getId()).application))
end

--@api: LFlowStream:setCombine
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:setCombine("additiveClamped")
    lurek.log.info("[physics] combine=" .. tostring(world:getFlowField(field:getId()).combine))
end

--@api: LFlowStream:destroy
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    field:destroy()
    lurek.log.info("[physics] destroyed flow=" .. tostring(not world:getFlowField(field:getId()).enabled))
end

--@api: LFlowStream:type
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    lurek.log.info("[physics] flow type=" .. tostring(field:type()))
end

--@api: LFlowStream:typeOf
do
    local world = lurek.physics.newWorld(0, 0)
    local field = world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 24,
        h = 24,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 20,
    })
    lurek.log.info("[physics] flow typeOf=" .. tostring(field:typeOf("LFlowStream")))
end

--@api: LBody:setFlowScale
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setFlowScale(0.5)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 80,
        h = 80,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 50,
    })
    world:step(1 / 60)
    lurek.log.info("[physics] flowScale vx=" .. tostring(select(1, body:getVelocity())))
end

--@api: LBody:setAirScale
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(20, 20, 8, "dynamic")
    body:setAirScale(0.25)
    world:addFlowField({
        geometry = "rect",
        x = 0,
        y = 0,
        w = 80,
        h = 80,
        direction = "explicit",
        directionVector = { x = 1, y = 0 },
        strength = 50,
        medium = "air",
    })
    world:step(1 / 60)
    lurek.log.info("[physics] airScale vx=" .. tostring(select(1, body:getVelocity())))
end

--@api: LBody:setWaterScale
do
local world = lurek.physics.newWorld(0, 0)
local body = world:newCircleBody(20, 20, 8, "dynamic")
body:setWaterScale(1.5)
world:addFlowField({
geometry = "path",
points = {
{ x = 0, y = 20 },
{ x = 120, y = 20 },
{ x = 180, y = 48 },
},
width = 48,
direction = "alongPath",
strength = 50,
medium = "water",
})
world:step(1 / 60)
end

--@api: LBody:setFlowCrossSection
do
local world = lurek.physics.newWorld(0, 0)
local body = world:newCircleBody(20, 20, 8, "dynamic")
body:setFlowCrossSection(2.0)
world:addFlowField({
geometry = "rect",
x = 0,
y = 0,
w = 80,
h = 80,
direction = "explicit",
directionVector = { x = 1, y = 0 },
medium = "water",
application = "targetVelocityDrag",
strength = 50,
drag = 2.0,
})
end

--@api: lurek.physics.newAltitudeLayer
do
    local layer = lurek.physics.newAltitudeLayer({
        width = 4,
        height = 4,
        cellSize = 10,
        defaultGroundHeight = 0,
        sampleMode = "nearest",
    })
    layer:setCellHeight(0, 0, 2)
    layer:setCellClearance(0, 0, 6)
    local data = layer:serialize()
    lurek.log.info("[physics] altitude layer " .. tostring(data.width) .. "x" .. tostring(data.height))
end

--@api: LAltitudeLayer:setCellHeight
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(1, 0, 5)
    local height = layer:getCellHeight(1, 0)
    local sample = layer:sampleHeight(15, 5)
    lurek.log.info("[physics] setCellHeight cell=" .. tostring(height) .. " sample=" .. tostring(sample))
end

--@api: LAltitudeLayer:getCellHeight
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(0, 1, 7)
    local height = layer:getCellHeight(0, 1)
    local data = layer:serialize()
    lurek.log.info("[physics] getCellHeight=" .. tostring(height) .. " rows=" .. tostring(data.height))
end

--@api: LAltitudeLayer:sampleHeight
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(1, 1, 9)
    local sample = layer:sampleHeight(15, 15)
    local data = layer:serialize()
    lurek.log.info("[physics] sampleHeight=" .. tostring(sample) .. " mode=" .. tostring(data.sampleMode))
end

--@api: LAltitudeLayer:setCellClearance
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellClearance(1, 1, 12)
    local clearance = layer:sampleClearance(15, 15)
    local data = layer:serialize()
    lurek.log.info("[physics] setCellClearance sample=" .. tostring(clearance) .. " cells=" .. tostring(#data.clearances))
end

--@api: LAltitudeLayer:sampleClearance
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellClearance(0, 0, 4)
    local sample = layer:sampleClearance(5, 5)
    local data = layer:serialize()
    lurek.log.info("[physics] sampleClearance=" .. tostring(sample) .. " width=" .. tostring(data.width))
end

--@api: LAltitudeLayer:serialize
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 1, sampleMode = "nearest" })
    layer:setCellHeight(0, 0, 3)
    local data = layer:serialize()
    local copy = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    copy:load(data)
    lurek.log.info("[physics] serialize copy=" .. tostring(copy:getCellHeight(0, 0)))
end

--@api: LAltitudeLayer:load
do
    local source = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    source:setCellHeight(1, 0, 8)
    local target = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    target:load(source:serialize())
    lurek.log.info("[physics] load height=" .. tostring(target:getCellHeight(1, 0)))
end

--@api: LAltitudeLayer:type
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(0, 0, 1)
    local type_name = layer:type()
    local data = layer:serialize()
    lurek.log.info("[physics] altitude type=" .. tostring(type_name) .. " default=" .. tostring(data.defaultGroundHeight))
end

--@api: LAltitudeLayer:typeOf
do
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellClearance(0, 0, 2)
    local matches = layer:typeOf("LAltitudeLayer")
    local data = layer:serialize()
    lurek.log.info("[physics] altitude typeOf=" .. tostring(matches) .. " clearances=" .. tostring(#data.clearances))
end

--@api: LWorld:setAltitudeLayer
do
    local world = lurek.physics.newWorld(0, 0)
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    layer:setCellHeight(0, 0, 4)
    world:setAltitudeLayer(layer)
    lurek.log.info("[physics] setAltitudeLayer sample=" .. tostring(world:getAltitudeLayer():sampleHeight(5, 5)))
end

--@api: LWorld:getAltitudeLayer
do
    local world = lurek.physics.newWorld(0, 0)
    local layer = lurek.physics.newAltitudeLayer({ width = 2, height = 2, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" })
    world:setAltitudeLayer(layer)
    local attached = world:getAltitudeLayer()
    attached:setCellHeight(0, 0, 7)
    lurek.log.info("[physics] getAltitudeLayer sample=" .. tostring(attached:sampleHeight(5, 5)))
end

--@api: LWorld:queryAltitudeOverlap
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local body = world:newBody(20, 0, 8, 8, "static")
    body:setAltitudeMode("fixed")
    body:setAltitude(5)
    body:setHeightExtent(4)
    world:step(1 / 60)
    local hits = world:queryAltitudeOverlap(20, 0, 8, 4, 10)
    lurek.log.info("[physics] queryAltitudeOverlap hits=" .. tostring(#hits))
end

--@api: LWorld:castCircle2_5d
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local body = world:newBody(24, 0, 8, 8, "static")
    body:setAltitudeMode("fixed")
    body:setAltitude(4)
    body:setHeightExtent(4)
    world:step(1 / 60)
    local hit = world:castCircle2_5d({ x = 0, y = 0, z = 4, radius = 1, height = 2, dx = 30, dy = 0, dz = 0 })
    lurek.log.info("[physics] castCircle2_5d hit=" .. tostring(hit and hit.hitKind))
end

--@api: LWorld:castBallisticArc
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local body = world:newBody(20, 0, 8, 8, "static")
    body:setAltitudeMode("fixed")
    body:setAltitude(4)
    body:setHeightExtent(4)
    world:step(1 / 60)
    local trace = world:castBallisticArc({ from = { x = 0, y = 0, z = 4 }, to = { x = 20, y = 0, z = 4 }, speed = 20, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25 })
    lurek.log.info("[physics] castBallisticArc samples=" .. tostring(#trace.samples))
end

--@api: LWorld:spawnBallisticProjectile
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local id = world:spawnBallisticProjectile({ from = { x = 0, y = 0, z = 2 }, target = { x = 16, y = 0, z = 2 }, speed = 16, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25 })
    local projectile = world:getBallisticProjectile(id)
    world:step(0.25)
    lurek.log.info("[physics] spawnBallisticProjectile id=" .. tostring(projectile and projectile.id))
end

--@api: LWorld:getBallisticProjectile
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local id = world:spawnBallisticProjectile({ from = { x = 0, y = 0, z = 1 }, target = { x = 8, y = 0, z = 1 }, speed = 8, gravity = 0, radius = 1, maxTime = 1, sampleDt = 0.25 })
    local projectile = world:getBallisticProjectile(id)
    world:step(0.25)
    lurek.log.info("[physics] getBallisticProjectile vz=" .. tostring(projectile and projectile.vz))
end

--@api: LWorld:removeBallisticProjectile
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local id = world:spawnBallisticProjectile({ from = { x = 0, y = 0, z = 1 }, target = { x = 8, y = 0, z = 1 }, speed = 8, gravity = 0, radius = 1, maxTime = 1, sampleDt = 0.25 })
    local removed = world:removeBallisticProjectile(id)
    local projectile = world:getBallisticProjectile(id)
    lurek.log.info("[physics] removeBallisticProjectile removed=" .. tostring(removed) .. " alive=" .. tostring(projectile ~= nil))
end

--@api: LWorld:getBallisticProjectileHits
do
    local world = lurek.physics.newWorld(0, 0)
    world:setAltitudeLayer(lurek.physics.newAltitudeLayer({ width = 4, height = 4, cellSize = 10, defaultGroundHeight = 0, sampleMode = "nearest" }))
    local body = world:newBody(12, 0, 8, 8, "static")
    body:setAltitudeMode("fixed")
    body:setAltitude(2)
    body:setHeightExtent(4)
    world:step(1 / 60)
    world:spawnBallisticProjectile({ from = { x = 0, y = 0, z = 2 }, target = { x = 12, y = 0, z = 2 }, speed = 12, gravity = 0, radius = 1, maxTime = 2, sampleDt = 0.25 })
    for _ = 1, 8 do world:step(0.25) end
    lurek.log.info("[physics] projectile hits=" .. tostring(#world:getBallisticProjectileHits()))
end

--@api: LBody:setAltitude
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitude(3)
    body:setHeightExtent(6)
    local z_min, z_max = body:getWorldZRange()
    lurek.log.info("[physics] setAltitude range=" .. tostring(z_min) .. "," .. tostring(z_max))
end

--@api: LBody:getAltitude
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitude(5)
    body:setHeightExtent(6)
    lurek.log.info("[physics] getAltitude=" .. tostring(body:getAltitude()))
end

--@api: LBody:setVerticalVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("ballistic")
    body:setVerticalVelocity(12)
    world:step(0.1)
    lurek.log.info("[physics] setVerticalVelocity=" .. tostring(body:getVerticalVelocity()))
end

--@api: LBody:getVerticalVelocity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setVerticalVelocity(9)
    body:setAltitudeMode("fixed")
    lurek.log.info("[physics] getVerticalVelocity=" .. tostring(body:getVerticalVelocity()))
end

--@api: LBody:setHeightExtent
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitude(2)
    body:setHeightExtent(9)
    local z_min, z_max = body:getWorldZRange()
    lurek.log.info("[physics] setHeightExtent max=" .. tostring(z_max) .. " min=" .. tostring(z_min))
end

--@api: LBody:getHeightExtent
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setHeightExtent(11)
    body:setAltitude(1)
    lurek.log.info("[physics] getHeightExtent=" .. tostring(body:getHeightExtent()))
end

--@api: LBody:setAltitudeMode
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("fixed")
    body:setAltitude(6)
    lurek.log.info("[physics] setAltitudeMode=" .. tostring(body:getAltitudeMode()))
end

--@api: LBody:getAltitudeMode
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("airborne")
    body:setAltitude(2)
    lurek.log.info("[physics] getAltitudeMode=" .. tostring(body:getAltitudeMode()))
end

--@api: LBody:setVerticalGravity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("ballistic")
    body:setVerticalGravity(-20)
    body:setVerticalVelocity(10)
    world:step(0.25)
    lurek.log.info("[physics] setVerticalGravity vz=" .. tostring(body:getVerticalVelocity()))
end

--@api: LBody:getVerticalGravity
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setVerticalGravity(-14)
    body:setAltitudeMode("fixed")
    lurek.log.info("[physics] getVerticalGravity=" .. tostring(body:getVerticalGravity()))
end

--@api: LBody:setClearanceClass
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setClearanceClass("air")
    body:setAltitudeMode("fixed")
    lurek.log.info("[physics] setClearanceClass=" .. tostring(body:getClearanceClass()))
end

--@api: LBody:getClearanceClass
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setClearanceClass("hover")
    body:setAltitude(1)
    lurek.log.info("[physics] getClearanceClass=" .. tostring(body:getClearanceClass()))
end

--@api: LBody:getWorldZRange
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("fixed")
    body:setAltitude(4)
    body:setHeightExtent(5)
    local z_min, z_max = body:getWorldZRange()
    lurek.log.info("[physics] getWorldZRange=" .. tostring(z_min) .. "," .. tostring(z_max))
end

--@api: LBody:setAltitudeCollision
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(10, 10, 4, "dynamic")
    body:setAltitudeMode("airborne")
    body:setAltitudeCollision({ enabled = true, collideWhenSeparated = false, hitGroundWhenBelowTerrain = true })
    body:setVerticalVelocity(-6)
    world:step(0.1)
    lurek.log.info("[physics] setAltitudeCollision altitude=" .. tostring(body:getAltitude()))
end

--@api: lurek.physics.reflectVelocity
do
    local vx, vy = lurek.physics.reflectVelocity(120, 0, -1, 0, 0.75)
    local speed = math.sqrt(vx * vx + vy * vy)
    local default_vx, default_vy = lurek.physics.reflectVelocity(0, 80, 0, -1)
    local bounced_down = default_vy < 0
    lurek.log.info("[physics] reflectVelocity=" .. tostring(vx) .. "," .. tostring(vy))
    lurek.log.info("[physics] reflected speed=" .. tostring(speed) .. " down=" .. tostring(bounced_down))
end

--@api: LWorld:configureCollisionGroups
do
    local world = lurek.physics.newWorld(0, 0)
    local groups = world:configureCollisionGroups({
        projectile = { group = 0, collidesWith = { "enemy" } },
        enemy = { group = 1, collidesWith = { "projectile", "terrain" } },
        terrain = { group = 2, collidesWith = { "enemy" } },
    })
    lurek.log.info("[physics] projectile mask=" .. tostring(groups.projectile.mask))
end

--@api: LWorld:newProjectileBody
do
    local world = lurek.physics.newWorld(0, 100)
    local projectile = world:newProjectileBody({
        x = 12, y = 18, radius = 2, vx = 240, vy = 0,
        group = 0, restitution = 0.2,
    })
    local vx, vy = projectile:getVelocity()
    lurek.log.info("[physics] projectile velocity=" .. tostring(vx) .. "," .. tostring(vy))
end

--@api: LWorld:castProjectile
do
    local world = lurek.physics.newWorld(0, 0)
    world:newCircleBody(64, 0, 8, "static")
    world:step(1 / 60)
    local result = world:castProjectile({ x = 0, y = 0, radius = 2, dx = 1, dy = 0, maxDist = 128 })
    lurek.log.info("[physics] castProjectile hit=" .. tostring(result.hit) .. " travel=" .. tostring(result.travel))
end

--@api: LWorld:setWrapBounds
do
    local world = lurek.physics.newWorld(0, 0)
    world:setWrapBounds(0, 0, 100, 100)
    local body = world:newBody(120, 50, "dynamic")
    world:wrapBody(body)
    lurek.log.info("[physics] wrapped x=" .. tostring(body:getX()))
end

--@api: LWorld:wrapBody
do
    local world = lurek.physics.newWorld(0, 0)
    world:setWrapBounds(0, 0, 100, 100)
    local body = world:newBody(120, 50, "dynamic")
    world:wrapBody(body)
    lurek.log.info("[physics] wrapBody x=" .. tostring(body:getX()))
end

--@api: LWorld:getWrapBounds
do
    local world = lurek.physics.newWorld(0, 0)
    world:setWrapBounds(0, 0, 100, 100)
    local bounds = world:getWrapBounds()
    lurek.log.info("wrap min=" .. bounds.min_x .. "," .. bounds.min_y)
    lurek.log.info("wrap max=" .. bounds.max_x .. "," .. bounds.max_y)
    world:setWrapBounds(nil)
end

--@api: LWorld:setTopDownDamping
do
    local world = lurek.physics.newWorld(0, 0)
    world:setTopDownDamping(0.2, 0.3)
    local body = world:newBody(16, 16, "dynamic")
    world:step(1 / 60)
    lurek.log.info("[physics] damping body id=" .. tostring(body:getId()))
end

--@api: LBody:applyThrust
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(16, 16, "dynamic")
    body:applyThrust(10)
    world:step(1 / 60)
    lurek.log.info("[physics] thrust body x=" .. tostring(body:getX()))
end

--@api: LBody:applyTurn
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(16, 16, "dynamic")
    body:applyTurn(1)
    world:step(1 / 60)
    lurek.log.info("[physics] turn body id=" .. tostring(body:getId()))
end
--@api: LWorld:newKinematicController
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    local kind = controller:type()
    lurek.log.info("controller=" .. kind)
end

--@api: LKinematicController2D:move
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    local result = controller:move(1, 0)
    lurek.log.info("moved=" .. tostring(result.appliedX))
end

--@api: LKinematicController2D:testMove
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    local result = controller:testMove(1, 0)
    lurek.log.info("tested=" .. tostring(result.appliedX))
end

--@api: LKinematicController2D:setRadius
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:setRadius(0.75)
    lurek.log.info("controller radius updated")
end

--@api: LKinematicController2D:setSkin
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:setSkin(0.02)
    lurek.log.info("controller skin updated")
end

--@api: LKinematicController2D:setMaxSlides
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:setMaxSlides(6)
    lurek.log.info("controller slides updated")
end

--@api: LKinematicController2D:setFilter
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:setFilter({ includeSensors = false, layer = 1, mask = 1 })
    lurek.log.info("controller filter updated")
end

--@api: LKinematicController2D:setVerticalSpan
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:setVerticalSpan(0, 2)
    lurek.log.info("controller vertical span enabled")
end

--@api: LKinematicController2D:clearVerticalSpan
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5, zMin = 0, zMax = 2 })
    controller:clearVerticalSpan()
    lurek.log.info("controller vertical span cleared")
end

--@api: LKinematicController2D:recover
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    world:newBody(0, 0, 2, 2, "static")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    lurek.log.info("recovery collided=" .. tostring(controller:recover().collided))
end

--@api: LKinematicController2D:getLastResult
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:testMove(1, 0)
    lurek.log.info("last request=" .. tostring(controller:getLastResult().requestedX))
end

--@api: LKinematicController2D:release
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    controller:release()
    lurek.log.info("controller released")
end

--@api: LKinematicController2D:type
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    local kind = controller:type()
    lurek.log.info("controller type=" .. kind)
end

--@api: LKinematicController2D:typeOf
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(0, 0, 0.5, "kinematic")
    local controller = world:newKinematicController(body, { radius = 0.5 })
    local object = controller:typeOf("LObject")
    lurek.log.info("controller object=" .. tostring(object))
end

--@api: LWorld:querySector
do
    local world = lurek.physics.newWorld(0, 0)
    world:newCircleBody(2, 0, 0.5, "static")
    world:newCircleBody(4, 1, 0.5, "static")
    world:step(1 / 60)
    lurek.log.info("sector hits=" .. tostring(#world:querySector(0, 0, 10, 0, math.pi / 2)))
end

--@api: LWorld:setBodyEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(2, 2, 1, "static")
    world:setBodyEnabled(body:getId(), false)
    local enabled = world:isBodyEnabled(body:getId())
    lurek.log.info("body enabled=" .. tostring(enabled))
end

--@api: LWorld:isBodyEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(2, 2, 1, "static")
    local initial = world:isBodyEnabled(body:getId())
    world:setBodyEnabled(body:getId(), false)
    lurek.log.info("body initial=" .. tostring(initial) .. " after=" .. tostring(world:isBodyEnabled(body:getId())))
end

--@api: LWorld:setFixtureEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(2, 2, 1, "static")
    world:setFixtureEnabled(body:getId(), 0, false)
    local enabled = world:isFixtureEnabled(body:getId(), 0)
    lurek.log.info("fixture enabled=" .. tostring(enabled))
end

--@api: LWorld:isFixtureEnabled
do
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newCircleBody(2, 2, 1, "static")
    local initial = world:isFixtureEnabled(body:getId(), 0)
    world:setFixtureEnabled(body:getId(), 0, false)
    lurek.log.info("fixture initial=" .. tostring(initial) .. " after=" .. tostring(world:isFixtureEnabled(body:getId(), 0)))
end
