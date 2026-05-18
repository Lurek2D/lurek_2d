--- ECS Module Part 1: Universe creation, entities, components, systems, queries

--@api-stub: lurek.ecs.newUniverse
-- Creates an empty ECS universe for entity, component, system, and relationship management.
do
    local uni = lurek.ecs.newUniverse()
    print("universe created, entities = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:spawn
-- Creates a new entity in this universe.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("spawned entity id = " .. id)
end

--@api-stub: LUniverse:kill
-- Deletes an entity and removes its components from this universe.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:kill(id)
    print("killed, alive = " .. tostring(uni:isAlive(id)))
end

--@api-stub: LUniverse:isAlive
-- Returns whether an entity id currently exists in this universe.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("alive = " .. tostring(uni:isAlive(id)))
end

--@api-stub: LUniverse:set
-- Stores or replaces a component value on an entity.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    print("position set")
end

--@api-stub: LUniverse:get
-- Returns a component value from an entity.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    print("hp = " .. tostring(hp))
end

--@api-stub: LUniverse:has
-- Returns whether an entity has a named component.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    print("has speed = " .. tostring(uni:has(id, "speed")))
end

--@api-stub: LUniverse:remove
-- Removes a named component from an entity.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    print("after remove has = " .. tostring(uni:has(id, "temp")))
end

--@api-stub: LUniverse:getComponents
-- Returns component names currently stored on an entity.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0})
    uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    print("components = " .. #names)
end

--@api-stub: LUniverse:query
-- Returns entities that have all component names passed as varargs.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 5, y = 5})
    local results = uni:query("pos", "vel")
    print("with pos+vel = " .. #results)
end

--@api-stub: LUniverse:each
-- Iterates entities with one component and calls a Lua callback for each match.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0
    uni:each("name", function(eid)
        count = count + 1
    end)
    print("each count = " .. count)
end

--@api-stub: LUniverse:getEntities
-- Returns all live entity ids in this universe.
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    print("entities = " .. #all)
end

--@api-stub: LUniverse:getEntityCount
-- Returns the number of live entities in this universe.
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    print("count = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:addSystem
-- Registers a Lua system table with optional phase, priority, name, and dependency metadata.
do
    local uni = lurek.ecs.newUniverse()
    local sys = {
        update = function(self, universe, dt) end
    }
    uni:addSystem(sys, {name = "movement", priority = 1})
    print("systems = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:removeSystem
-- Removes a previously registered Lua system table.
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    print("after remove systems = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:update
-- Runs registered update-phase systems with a frame delta.
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    print("update called = " .. tostring(called))
end

--@api-stub: LUniverse:render
-- Runs registered render-phase systems using their render or draw callbacks.
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    print("render called = " .. tostring(drawn))
end

--@api-stub: LUniverse:emit
-- Calls matching event-named functions on registered systems.
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    print("emit received = " .. tostring(got))
end

--@api-stub: LUniverse:getSystemCount
-- Returns the number of registered systems.
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end})
    uni:addSystem({draw = function() end})
    print("system count = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:updatePhase
-- Runs registered systems assigned to a named phase.
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    print("phase ran = " .. tostring(ran))
end

--@api-stub: LUniverse:getDirtyEntities
-- Returns entities marked dirty by recent ECS mutations.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    print("dirty = " .. #dirty)
end

--@api-stub: LUniverse:queryMulti
-- Iterates entities that have all component names from a table.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "a", {value = 1})
    uni:set(id, "b", {value = 2})
    local count = 0
    uni:queryMulti({"a", "b"}, function(eid)
        count = count + 1
    end)
    print("queryMulti = " .. count)
end

--@api-stub: LUniverse:snapshot
-- Serializes this universe into a Lua table snapshot.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    print("snapshot type = " .. type(snap))
end

print("ecs_00.lua")
