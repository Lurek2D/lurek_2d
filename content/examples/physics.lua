-- content/examples/physics.lua
-- love2d-style usage snippets for the lurek.physics API (147 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/physics.lua

-- ── lurek.physics.* functions ──

--@api-stub: lurek.physics.newWorld
-- Creates a new physics world with the given gravity vector.
-- Build once at startup; reuse across frames.
local world = lurek.physics.newWorld(0, 9.81)
function lurek.update(dt) world:update(dt) end
return world

--@api-stub: lurek.physics.step
-- Advances the physics world by dt seconds.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.physics.step(world_ud, dt)
print("step fired")
print("ok")

--@api-stub: lurek.physics.destroyWorld
-- Marks a physics world for destruction.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.physics.destroyWorld(world_ud)
print("destroyWorld done")
print("ok")

--@api-stub: lurek.physics.newBody
-- Creates a new rectangular body in the given world.
-- Build once at startup; reuse across frames.
local body = lurek.physics.newBody(world, 100, 100, "dynamic")
body:setMass(1.0)
return body

--@api-stub: lurek.physics.getBody
-- Returns the position and velocity of a body (x, y, vx, vy).
-- Cheap to call; safe inside callbacks.
local value = lurek.physics.getBody(world_ud, body_ud)
print("getBody:", value)
return value

--@api-stub: lurek.physics.setBodyVelocity
-- Sets the velocity of a body.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.physics.setBodyVelocity(world_ud, body_ud, 100, 100)
print("setBodyVelocity applied")
print("ok")

--@api-stub: lurek.physics.isSleepingAllowed
-- Returns whether the body is allowed to sleep.
-- Use as a guard inside lurek.update or event handlers.
if lurek.physics.isSleepingAllowed(world_ud, body_ud) then
  print("isSleepingAllowed -> true")
end

--@api-stub: lurek.physics.setSleepingAllowed
-- Sets whether the body is allowed to sleep.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.physics.setSleepingAllowed(world_ud, body_ud, allowed)
print("setSleepingAllowed applied")
print("ok")

--@api-stub: lurek.physics.newRectangleShape
-- Creates a rectangle shape userdata.
-- Build once at startup; reuse across frames.
local rectangleshape = lurek.physics.newRectangleShape(64, 64)
print("created", rectangleshape)
return rectangleshape

--@api-stub: lurek.physics.newCircleShape
-- Creates a circle shape userdata.
-- Build once at startup; reuse across frames.
local circleshape = lurek.physics.newCircleShape(1)
print("created", circleshape)
return circleshape

--@api-stub: lurek.physics.newEdgeShape
-- Creates an edge (line segment) shape userdata.
-- Build once at startup; reuse across frames.
local edgeshape = lurek.physics.newEdgeShape(x1, y1, x2, y2)
print("created", edgeshape)
return edgeshape

--@api-stub: lurek.physics.newPolygonShape
-- Creates a convex polygon shape userdata from flat variadic vertex pairs.
-- Build once at startup; reuse across frames.
local polygonshape = lurek.physics.newPolygonShape()
print("created", polygonshape)
return polygonshape

--@api-stub: lurek.physics.newChainShape
-- Creates a chain shape userdata from flat variadic vertex pairs.
-- Build once at startup; reuse across frames.
local chainshape = lurek.physics.newChainShape(closed, coords)
print("created", chainshape)
return chainshape

--@api-stub: lurek.physics.attachShape
-- Attaches a standalone shape to a body as an additional fixture.
-- Side-effecting; safe to call any time after init.
lurek.physics.attachShape(body_ud, shape_ud)
-- mutator; side effect applied
print("attachShape done")
print("ok")

--@api-stub: lurek.physics.getCollisions
-- Returns all collision events from the last simulation step.
-- Cheap to call; safe inside callbacks.
local value = lurek.physics.getCollisions(world_ud)
print("getCollisions:", value)
return value

--@api-stub: lurek.physics.debugDraw
-- Enables or disables the physics debug overlay (AABB boxes and velocity vectors).
-- See the module spec for detailed semantics.
local result = lurek.physics.debugDraw(enable)
print("debugDraw:", result)
return result

--@api-stub: lurek.physics.drawDebugGpu
-- Extracts collider geometry from a World and queues a GPU physics debug.
-- See the module spec for detailed semantics.
local result = lurek.physics.drawDebugGpu(world_ud, { x = 0, y = 0 })
print("drawDebugGpu:", result)
return result

--@api-stub: lurek.physics.newTerrain
-- Creates a destructible terrain grid.
-- Build once at startup; reuse across frames.
local terrain = lurek.physics.newTerrain(64, 64, cell_size, world_ud)
print("created", terrain)
return terrain

--@api-stub: lurek.physics.newCellular
-- Creates a falling-sand cellular automaton grid.
-- Build once at startup; reuse across frames.
local cellular = lurek.physics.newCellular(64, 64)
print("created", cellular)
return cellular

-- ── World methods ──

--@api-stub: World:step
-- Advances the physics simulation by dt seconds, firing onBeginContact /.
-- Trigger from input, timers, or game events.
local world = lurek.physics.newWorld()
world:step(dt)
-- trigger from input, timer, or event
print("ok")

--@api-stub: World:clear
-- Resets the world, removing all bodies and joints.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:clear()
-- world is now released
print("ok")

--@api-stub: World:getGravity
-- Returns the gravity vector (gx, gy).
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getGravity()
print("World:getGravity ->", value)

--@api-stub: World:setGravity
-- Sets the world gravity vector; default is `(0, 9.81)` (downward).
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setGravity(gx, gy)
print("World:setGravity applied")

--@api-stub: World:setMeter
-- Sets the pixels-per-meter scaling factor.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setMeter(ppm)
print("World:setMeter applied")

--@api-stub: World:getMeter
-- Returns the pixels-per-meter scaling factor.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getMeter()
print("World:getMeter ->", value)

--@api-stub: World:toPhysics
-- Converts a pixel value to physics units.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:toPhysics(px)
print("World:toPhysics done")

--@api-stub: World:toPixels
-- Converts a physics-unit value to pixels.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:toPixels(m)
print("World:toPixels done")

--@api-stub: World:getBodyCount
-- Returns the total number of bodies in the world.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyCount()
print("World:getBodyCount ->", value)

--@api-stub: World:getBodyIds
-- Returns all body IDs in the world.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyIds()
print("World:getBodyIds ->", value)

--@api-stub: World:destroyBody
-- Removes a body from the world.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:destroyBody(1)
-- world is now released
print("ok")

--@api-stub: World:newBody
-- Creates a new rectangular body and adds it to the world.
-- Build once at startup; reuse across frames.
local world = lurek.physics.newWorld()
world:newBody(100, 100, bt)
print("World:newBody done")

--@api-stub: World:fixtureCount
-- Returns the number of fixtures on a body.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:fixtureCount(1)
print("World:fixtureCount done")

--@api-stub: World:jointCount
-- Returns the total number of joints.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:jointCount()
print("World:jointCount done")

--@api-stub: World:getJointIds
-- Returns a table of integer IDs for every joint attached to this world.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointIds()
print("World:getJointIds ->", value)

--@api-stub: World:getJointBodies
-- Returns the two body IDs connected by a joint.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointBodies(1)
print("World:getJointBodies ->", value)

--@api-stub: World:destroyJoint
-- Removes a joint from the world.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:destroyJoint(1)
-- world is now released
print("ok")

--@api-stub: World:getJointType
-- Returns the type name of a joint.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointType(1)
print("World:getJointType ->", value)

--@api-stub: World:getJointMotorSpeed
-- Returns the motor speed on a joint's angular axis.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointMotorSpeed(1)
print("World:getJointMotorSpeed ->", value)

--@api-stub: World:getJointLimits
-- Returns the angular limits on a joint.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointLimits(1)
print("World:getJointLimits ->", value)

--@api-stub: World:getBodyAtPoint
-- Returns the body ID at a world-space point, or nil.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyAtPoint(100, 100)
print("World:getBodyAtPoint ->", value)

--@api-stub: World:getCollisionEvents
-- Returns collision events from the last step.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getCollisionEvents()
print("World:getCollisionEvents ->", value)

--@api-stub: World:getBeginContactEvents
-- Returns begin-contact events from the last step.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBeginContactEvents()
print("World:getBeginContactEvents ->", value)

--@api-stub: World:getEndContactEvents
-- Returns end-contact events from the last step.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getEndContactEvents()
print("World:getEndContactEvents ->", value)

--@api-stub: World:getContacts
-- Returns all contact pairs from the narrow phase.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getContacts()
print("World:getContacts ->", value)

--@api-stub: World:getBodyContacts
-- Returns contacts involving a specific body.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyContacts(1)
print("World:getBodyContacts ->", value)

--@api-stub: World:setBodyType
-- Changes the simulation type of the body: `"dynamic"`, `"static"`, or `"kinematic"`.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setBodyType(1, bt)
print("World:setBodyType applied")

--@api-stub: World:getBodyType
-- Returns the body type as a string.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyType(1)
print("World:getBodyType ->", value)

--@api-stub: World:setBeginContact
-- Registers a Lua function called with (bodyIdA, bodyIdB) when two.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setBeginContact(f)
print("World:setBeginContact applied")

--@api-stub: World:clearBeginContact
-- Removes the begin-contact callback.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:clearBeginContact()
-- world is now released
print("ok")

--@api-stub: World:setEndContact
-- Registers a Lua function called with (bodyIdA, bodyIdB) when two.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setEndContact(f)
print("World:setEndContact applied")

--@api-stub: World:clearEndContact
-- Removes the end-contact callback.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:clearEndContact()
-- world is now released
print("ok")

--@api-stub: World:getBodyData
-- Returns the Lua data previously attached to a body, or nil if none is set.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyData(1)
print("World:getBodyData ->", value)

--@api-stub: World:clearBodyData
-- Removes the Lua data attached to a body.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:clearBodyData(1)
-- world is now released
print("ok")

--@api-stub: World:setBodyCCD
-- Enables or disables Continuous Collision Detection for a body.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setBodyCCD(1, enabled)
print("World:setBodyCCD applied")

--@api-stub: World:getBodyCCD
-- Returns whether CCD is enabled for a body.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyCCD(1)
print("World:getBodyCCD ->", value)

--@api-stub: World:clearBodyOneWay
-- Removes the one-way platform flag from a body.
-- Pair with the matching constructor to free resources.
local world = lurek.physics.newWorld()
world:clearBodyOneWay(1)
-- world is now released
print("ok")

--@api-stub: World:getBodyOneWay
-- Returns the one-way normal for a body, or nil if not configured.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getBodyOneWay(1)
print("World:getBodyOneWay ->", value)

--@api-stub: World:setJointBreakForce
-- Sets the relative-velocity threshold above which a joint breaks.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setJointBreakForce(1, f)
print("World:setJointBreakForce applied")

--@api-stub: World:getJointBreakForce
-- Returns the break threshold for a joint, or nil if not set.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getJointBreakForce(1)
print("World:getJointBreakForce ->", value)

--@api-stub: World:isBodySleeping
-- Returns true if a body is currently sleeping (inactive).
-- Use as a guard inside lurek.update or event handlers.
local world = lurek.physics.newWorld()
if world:isBodySleeping(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: World:wakeUpBody
-- Forcibly wakes up a sleeping body.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:wakeUpBody(1)
print("World:wakeUpBody done")

--@api-stub: World:sleepBody
-- Puts a body to sleep immediately.
-- See the module spec for detailed semantics.
local world = lurek.physics.newWorld()
world:sleepBody(1)
print("World:sleepBody done")

--@api-stub: World:setSolverIterations
-- Sets the number of constraint solver iterations per step.
-- Apply at startup or in response to user input.
local world = lurek.physics.newWorld()
world:setSolverIterations(10)
print("World:setSolverIterations applied")

--@api-stub: World:getSolverIterations
-- Returns the current number of solver iterations per step.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getSolverIterations()
print("World:getSolverIterations ->", value)

--@api-stub: World:newBodies
-- Creates multiple bodies in one call.
-- Build once at startup; reuse across frames.
local world = lurek.physics.newWorld()
world:newBodies(specs)
print("World:newBodies done")

--@api-stub: World:addZone
-- Creates a rectangular gravity/damping zone and returns a LuaZone handle.
-- Side-effecting; safe to call any time after init.
local world = lurek.physics.newWorld()
world:addZone(100, 100, 64, 64)
print("World:addZone done")

--@api-stub: World:getZoneEvents
-- Returns zone enter/leave events produced by the most recent step.
-- Cheap to call; safe inside callbacks.
local world = lurek.physics.newWorld()  -- or your existing handle
local value = world:getZoneEvents()
print("World:getZoneEvents ->", value)

-- ── Zone methods ──

--@api-stub: Zone:getId
-- Returns the zone's integer ID.
-- Cheap to call; safe inside callbacks.
local zone = lurek.physics.newZone()  -- or your existing handle
local value = zone:getId()
print("Zone:getId ->", value)

--@api-stub: Zone:setEnabled
-- Enables or disables the zone.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setEnabled(enabled)
print("Zone:setEnabled applied")

--@api-stub: Zone:setPriority
-- Sets the zone priority; higher values win over lower when zones overlap.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setPriority(priority)
print("Zone:setPriority applied")

--@api-stub: Zone:setLayerMask
-- Sets the layer bitmask; only bodies whose `layer & mask != 0` are affected.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setLayerMask(mask)
print("Zone:setLayerMask applied")

--@api-stub: Zone:setCircle
-- Replaces the zone boundary with a circle.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setCircle(cx, cy, radius)
print("Zone:setCircle applied")

--@api-stub: Zone:setGravityDirectional
-- Sets directional gravity inside the zone.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setGravityDirectional(gx, gy)
print("Zone:setGravityDirectional applied")

--@api-stub: Zone:setGravityZero
-- Suppresses gravity inside the zone (zero-g pocket).
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setGravityZero()
print("Zone:setGravityZero applied")

--@api-stub: Zone:setLinearDampingOverride
-- Sets an optional linear damping override for bodies inside the zone.
-- Apply at startup or in response to user input.
local zone = lurek.physics.newZone()
zone:setLinearDampingOverride(value)
print("Zone:setLinearDampingOverride applied")

--@api-stub: Zone:destroy
-- Removes the zone from the world.
-- Pair with the matching constructor to free resources.
local zone = lurek.physics.newZone()
zone:destroy()
-- zone is now released
print("ok")

-- ── Terrain methods ──

--@api-stub: Terrain:setCell
-- Sets a single terrain cell to solid or empty.
-- Apply at startup or in response to user input.
local terrain = lurek.physics.newTerrain()
terrain:setCell(cx, cy, 1)
print("Terrain:setCell applied")

--@api-stub: Terrain:getCell
-- Returns whether a cell is solid.
-- Cheap to call; safe inside callbacks.
local terrain = lurek.physics.newTerrain()  -- or your existing handle
local value = terrain:getCell(cx, cy)
print("Terrain:getCell ->", value)

--@api-stub: Terrain:fillAll
-- Sets every cell in the grid to `solid`.
-- See the module spec for detailed semantics.
local terrain = lurek.physics.newTerrain()
terrain:fillAll(1)
print("Terrain:fillAll done")

--@api-stub: Terrain:flush
-- Rebuilds physics bodies for all dirty chunks.
-- See the module spec for detailed semantics.
local terrain = lurek.physics.newTerrain()
terrain:flush()
print("Terrain:flush done")

--@api-stub: Terrain:isDirty
-- Returns `true` when at least one chunk needs flushing.
-- Use as a guard inside lurek.update or event handlers.
local terrain = lurek.physics.newTerrain()
if terrain:isDirty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Terrain:collapseColumns
-- Removes unsupported cells, returning the number of cells that fell.
-- See the module spec for detailed semantics.
local terrain = lurek.physics.newTerrain()
terrain:collapseColumns()
print("Terrain:collapseColumns done")

--@api-stub: Terrain:solidPositions
-- Returns the world-space centres of all solid cells as an array of `{x, y}` tables.
-- See the module spec for detailed semantics.
local terrain = lurek.physics.newTerrain()
terrain:solidPositions()
print("Terrain:solidPositions done")

--@api-stub: Terrain:toBytes
-- Serialises the terrain grid to a byte string for save/load.
-- See the module spec for detailed semantics.
local terrain = lurek.physics.newTerrain()
terrain:toBytes()
print("Terrain:toBytes done")

--@api-stub: Terrain:loadFromBytes
-- Loads terrain cell data from bytes produced by `toBytes`.
-- May block — call from a worker thread for large payloads.
local terrain = lurek.physics.newTerrain()
terrain:loadFromBytes({ x = 0, y = 0 })
print("Terrain:loadFromBytes done")

-- ── Cellular methods ──

--@api-stub: Cellular:setCell
-- Sets the material of a cell.
-- Apply at startup or in response to user input.
local cellular = lurek.physics.newCellular()
cellular:setCell(cx, cy, t)
print("Cellular:setCell applied")

--@api-stub: Cellular:getCell
-- Returns the material at `(cx, cy)` as an integer constant.
-- Cheap to call; safe inside callbacks.
local cellular = lurek.physics.newCellular()  -- or your existing handle
local value = cellular:getCell(cx, cy)
print("Cellular:getCell ->", value)

--@api-stub: Cellular:step
-- Advances the simulation by one tick.
-- Trigger from input, timers, or game events.
local cellular = lurek.physics.newCellular()
cellular:step()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Cellular:stepN
-- Advances the simulation by `n` ticks.
-- Trigger from input, timers, or game events.
local cellular = lurek.physics.newCellular()
cellular:stepN(10)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Cellular:toImageData
-- Returns the full grid as an RGBA byte string using the default colour palette.
-- See the module spec for detailed semantics.
local cellular = lurek.physics.newCellular()
cellular:toImageData()
print("Cellular:toImageData done")

--@api-stub: Cellular:countCells
-- Counts cells of the given material type.
-- Cheap to call; safe inside callbacks.
local cellular = lurek.physics.newCellular()  -- or your existing handle
local value = cellular:countCells(t)
print("Cellular:countCells ->", value)

--@api-stub: Cellular:findCells
-- Returns positions of all cells of the given material as an array of `{x, y}` tables.
-- Cheap to call; safe inside callbacks.
local cellular = lurek.physics.newCellular()  -- or your existing handle
local value = cellular:findCells(t)
print("Cellular:findCells ->", value)

--@api-stub: Cellular:toBytes
-- Serialises the grid to a byte string.
-- See the module spec for detailed semantics.
local cellular = lurek.physics.newCellular()
cellular:toBytes()
print("Cellular:toBytes done")

--@api-stub: Cellular:loadFromBytes
-- Loads grid data from bytes produced by `toBytes`.
-- May block — call from a worker thread for large payloads.
local cellular = lurek.physics.newCellular()
cellular:loadFromBytes({ x = 0, y = 0 })
print("Cellular:loadFromBytes done")

-- ── Body methods ──

--@api-stub: Body:getId
-- Returns the body's integer ID.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getId()
print("Body:getId ->", value)

--@api-stub: Body:getPosition
-- Returns the body position (x, y).
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getPosition()
print("Body:getPosition ->", value)

--@api-stub: Body:setPosition
-- Teleports the body to the given world-space position, bypassing collision.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setPosition(100, 100)
print("Body:setPosition applied")

--@api-stub: Body:getX
-- Returns the body X position.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getX()
print("Body:getX ->", value)

--@api-stub: Body:getY
-- Returns the body Y position.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getY()
print("Body:getY ->", value)

--@api-stub: Body:getVelocity
-- Returns the body velocity (vx, vy).
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getVelocity()
print("Body:getVelocity ->", value)

--@api-stub: Body:setVelocity
-- Sets the body's linear velocity in world units per second.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setVelocity(100, 100)
print("Body:setVelocity applied")

--@api-stub: Body:getAngle
-- Returns the body angle in radians.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getAngle()
print("Body:getAngle ->", value)

--@api-stub: Body:setAngle
-- Sets the body angle in radians.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setAngle(0)
print("Body:setAngle applied")

--@api-stub: Body:getAngularVelocity
-- Returns the angular velocity in radians/s.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getAngularVelocity()
print("Body:getAngularVelocity ->", value)

--@api-stub: Body:setAngularVelocity
-- Sets the angular velocity.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setAngularVelocity(omega)
print("Body:setAngularVelocity applied")

--@api-stub: Body:getMass
-- Returns the body mass in kilograms used for force and impulse calculations.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getMass()
print("Body:getMass ->", value)

--@api-stub: Body:setMass
-- Sets the body mass; affects how forces and impulses change velocity.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setMass(mass)
print("Body:setMass applied")

--@api-stub: Body:getType
-- Returns the body type as a string.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getType()
print("Body:getType ->", value)

--@api-stub: Body:setType
-- Changes the body type: `"dynamic"`, `"static"`, or `"kinematic"`.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setType(bt)
print("Body:setType applied")

--@api-stub: Body:getWidth
-- Returns the width of this body's primary collider shape in world units.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getWidth()
print("Body:getWidth ->", value)

--@api-stub: Body:getHeight
-- Returns the height of this body's primary collider shape in world units.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getHeight()
print("Body:getHeight ->", value)

--@api-stub: Body:getFriction
-- Returns the body friction coefficient.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getFriction()
print("Body:getFriction ->", value)

--@api-stub: Body:setFriction
-- Sets the body friction coefficient.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setFriction(friction)
print("Body:setFriction applied")

--@api-stub: Body:getRestitution
-- Returns the body restitution (bounciness).
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getRestitution()
print("Body:getRestitution ->", value)

--@api-stub: Body:setRestitution
-- Sets the body restitution (bounciness).
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setRestitution(restitution)
print("Body:setRestitution applied")

--@api-stub: Body:getLayer
-- Returns the collision layer bitmask.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getLayer()
print("Body:getLayer ->", value)

--@api-stub: Body:setLayer
-- Sets the collision layer bitmask.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setLayer(layer)
print("Body:setLayer applied")

--@api-stub: Body:getMask
-- Returns the collision mask bitmask.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getMask()
print("Body:getMask ->", value)

--@api-stub: Body:setMask
-- Sets the collision mask bitmask.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setMask(mask)
print("Body:setMask applied")

--@api-stub: Body:applyImpulse
-- Applies a linear impulse to the body.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:applyImpulse(ix, iy)
print("Body:applyImpulse applied")

--@api-stub: Body:applyForce
-- Applies a continuous force to the body.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:applyForce(fx, fy)
print("Body:applyForce applied")

--@api-stub: Body:applyTorque
-- Applies a torque (rotational force).
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:applyTorque(torque)
print("Body:applyTorque applied")

--@api-stub: Body:applyAngularImpulse
-- Applies an angular impulse.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:applyAngularImpulse(impulse)
print("Body:applyAngularImpulse applied")

--@api-stub: Body:getGravityScale
-- Returns the per-body gravity multiplier.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getGravityScale()
print("Body:getGravityScale ->", value)

--@api-stub: Body:setGravityScale
-- Sets the per-body gravity multiplier.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setGravityScale(1.0)
print("Body:setGravityScale applied")

--@api-stub: Body:isFixedRotation
-- Returns whether rotation is locked.
-- Use as a guard inside lurek.update or event handlers.
local body = lurek.physics.newBody()
if body:isFixedRotation() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Body:setFixedRotation
-- Locks or unlocks rotation.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setFixedRotation(fixed)
print("Body:setFixedRotation applied")

--@api-stub: Body:getLinearDamping
-- Returns the linear damping coefficient.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getLinearDamping()
print("Body:getLinearDamping ->", value)

--@api-stub: Body:setLinearDamping
-- Sets the linear damping coefficient.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setLinearDamping(damping)
print("Body:setLinearDamping applied")

--@api-stub: Body:getAngularDamping
-- Returns the angular damping coefficient.
-- Cheap to call; safe inside callbacks.
local body = lurek.physics.newBody()  -- or your existing handle
local value = body:getAngularDamping()
print("Body:getAngularDamping ->", value)

--@api-stub: Body:setAngularDamping
-- Sets the angular damping coefficient.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setAngularDamping(damping)
print("Body:setAngularDamping applied")

--@api-stub: Body:isBullet
-- Returns whether CCD is enabled.
-- Use as a guard inside lurek.update or event handlers.
local body = lurek.physics.newBody()
if body:isBullet() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Body:setBullet
-- Enables or disables continuous collision detection (CCD) for fast-moving bodies.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setBullet(bullet)
print("Body:setBullet applied")

--@api-stub: Body:isSleepingAllowed
-- Returns whether the body can sleep.
-- Use as a guard inside lurek.update or event handlers.
local body = lurek.physics.newBody()
if body:isSleepingAllowed() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Body:setSleepingAllowed
-- Sets whether the body can sleep.
-- Apply at startup or in response to user input.
local body = lurek.physics.newBody()
body:setSleepingAllowed(allowed)
print("Body:setSleepingAllowed applied")

--@api-stub: Body:destroy
-- Removes this body from the world.
-- Pair with the matching constructor to free resources.
local body = lurek.physics.newBody()
body:destroy()
-- body is now released
print("ok")

--@api-stub: Body:isSleeping
-- Returns true if this body is currently sleeping (inactive).
-- Use as a guard inside lurek.update or event handlers.
local body = lurek.physics.newBody()
if body:isSleeping() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Body:wakeUp
-- Forcibly wakes up this body.
-- See the module spec for detailed semantics.
local body = lurek.physics.newBody()
body:wakeUp()
print("Body:wakeUp done")

--@api-stub: Body:sleep
-- Puts this body to sleep immediately.
-- See the module spec for detailed semantics.
local body = lurek.physics.newBody()
body:sleep()
print("Body:sleep done")

-- ── PhysicsShape methods ──

--@api-stub: PhysicsShape:getType
-- Returns the shape type string: "circle", "rectangle", "polygon", "edge", or "chain".
-- Cheap to call; safe inside callbacks.
local physicsShape = lurek.physics.newPhysicsShape()  -- or your existing handle
local value = physicsShape:getType()
print("PhysicsShape:getType ->", value)

--@api-stub: PhysicsShape:getRadius
-- Returns the radius.
-- Cheap to call; safe inside callbacks.
local physicsShape = lurek.physics.newPhysicsShape()  -- or your existing handle
local value = physicsShape:getRadius()
print("PhysicsShape:getRadius ->", value)

--@api-stub: PhysicsShape:getBoundingBox
-- Returns the axis-aligned bounding box (x1, y1, x2, y2).
-- Cheap to call; safe inside callbacks.
local physicsShape = lurek.physics.newPhysicsShape()  -- or your existing handle
local value = physicsShape:getBoundingBox()
print("PhysicsShape:getBoundingBox ->", value)

--@api-stub: PhysicsShape:setDensity
-- Sets the density for this shape (used when attaching to a body).
-- Apply at startup or in response to user input.
local physicsShape = lurek.physics.newPhysicsShape()
physicsShape:setDensity(density)
print("PhysicsShape:setDensity applied")

--@api-stub: PhysicsShape:setFriction
-- Sets the friction coefficient.
-- Apply at startup or in response to user input.
local physicsShape = lurek.physics.newPhysicsShape()
physicsShape:setFriction(friction)
print("PhysicsShape:setFriction applied")

--@api-stub: PhysicsShape:setRestitution
-- Sets the restitution (bounciness) coefficient.
-- Apply at startup or in response to user input.
local physicsShape = lurek.physics.newPhysicsShape()
physicsShape:setRestitution(restitution)
print("PhysicsShape:setRestitution applied")

--@api-stub: PhysicsShape:setSensor
-- Sets whether this shape is a sensor (non-colliding trigger).
-- Apply at startup or in response to user input.
local physicsShape = lurek.physics.newPhysicsShape()
physicsShape:setSensor(sensor)
print("PhysicsShape:setSensor applied")

--@api-stub: PhysicsShape:destroy
-- Releases this shape handle (GC handles cleanup).
-- Pair with the matching constructor to free resources.
local physicsShape = lurek.physics.newPhysicsShape()
physicsShape:destroy()
-- physicsShape is now released
print("ok")

