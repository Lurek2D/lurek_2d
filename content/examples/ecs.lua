-- content/examples/ecs.lua
-- Auto-generated from content/examples2/ecs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ecs.lua

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

--- ECS Module Part 2: Blueprints, hierarchy, relations, serialization, observers, advanced queries

--@api-stub: LUniverse:defineBlueprint
-- Defines a named entity blueprint from a component table.
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {
        pos = {x = 0, y = 0},
        hp = {value = 50},
        tag = {value = "hostile"},
    })
    print("blueprint defined")
end

--@api-stub: LUniverse:getBlueprintComponents
-- Returns the component table stored for a named blueprint.
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    print("blueprint comps type = " .. type(comps))
end

--@api-stub: LUniverse:spawnBlueprint
-- Spawns an entity from a named blueprint with optional overrides.
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    print("spawned from blueprint id = " .. id)
end

--@api-stub: LUniverse:setParent
-- Sets or clears the parent entity for a child entity.
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    print("parent set")
end

--@api-stub: LUniverse:getParent
-- Returns the parent entity id for a child entity.
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    print("parent = " .. p)
end

--@api-stub: LUniverse:getChildren
-- Returns child entity ids for a parent entity.
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local c1 = uni:spawn()
    local c2 = uni:spawn()
    uni:setParent(c1, parent)
    uni:setParent(c2, parent)
    local children = uni:getChildren(parent)
    print("children = " .. #children)
end

--@api-stub: LUniverse:killRecursive
-- Deletes an entity and all descendant entities in its hierarchy.
do
    local uni = lurek.ecs.newUniverse()
    local root = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    print("root alive = " .. tostring(uni:isAlive(root)))
    print("child alive = " .. tostring(uni:isAlive(child)))
end

--@api-stub: LUniverse:queryNot
-- Returns entities that match one set and exclude another.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "static", {flag = true})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 1, y = 1})
    local moving = uni:queryNot({"pos"}, {"static"})
    print("moving entities = " .. #moving)
end

--@api-stub: LUniverse:serialize
-- Serializes this universe into a Lua table snapshot.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    print("entities in snapshot = " .. #snap.entities)
end

--@api-stub: LUniverse:deserialize
-- Replaces this universe state from a serialized Lua snapshot.
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    local snap = uni:serialize()
    uni:deserialize(snap)
    print("deserialized, count = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:onComponentAdded
-- Registers a callback for queued component-add events.
do
    local uni = lurek.ecs.newUniverse()
    local added = false
    uni:onComponentAdded("hp", function(eid, name)
        added = true
    end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    print("added callback fired = " .. tostring(added))
end

--@api-stub: LUniverse:onComponentRemoved
-- Registers a callback for queued component-remove events.
do
    local uni = lurek.ecs.newUniverse()
    local removed = false
    uni:onComponentRemoved("hp", function(eid, name)
        removed = true
    end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 50})
    uni:remove(id, "hp")
    uni:flushObservers()
    print("removed callback fired = " .. tostring(removed))
end

--@api-stub: LUniverse:flushObservers
-- Delivers queued component events to registered observer callbacks.
do
    local uni = lurek.ecs.newUniverse()
    uni:flushObservers()
    print("observers flushed")
end

--@api-stub: LUniverse:spawnBulk
-- Spawns multiple entities from a blueprint.
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    print("bulk spawned = " .. #ids)
end

--@api-stub: LUniverse:addRelation
-- Adds a named directed relation between two entities.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    print("relation added")
end

--@api-stub: LUniverse:getRelated
-- Returns targets linked from an entity by a named relation.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    local c = uni:spawn()
    uni:addRelation(a, "friend", b)
    uni:addRelation(a, "friend", c)
    local friends = uni:getRelated(a, "friend")
    print("friends = " .. #friends)
end

--@api-stub: LUniverse:removeRelation
-- Removes a named directed relation between two entities.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    print("relation removed")
end

--@api-stub: LUniverse:clearRelations
-- Removes every target for one named relation from an entity.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    print("after clear = " .. #targets)
end

--@api-stub: LUniverse:hasRelation
-- Returns whether a named directed relation exists between two entities.
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    print("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end

--@api-stub: LUniverse:type
-- Returns the type name ("LUniverse").
do
    local uni = lurek.ecs.newUniverse()
    print("type = " .. uni:type())
end

--@api-stub: LUniverse:typeOf
-- Returns whether this handle matches a type name.
do
    local uni = lurek.ecs.newUniverse()
    print("is LUniverse = " .. tostring(uni:typeOf("LUniverse")))
end

--- ECS Module: tag system, blueprints, layers, snapshots

--@api-stub: LUniverse:defineTag
--@api-stub: LUniverse:addTag
--@api-stub: LUniverse:removeTag
--@api-stub: LUniverse:hasTag
--@api-stub: LUniverse:getTags
-- Tag definition and entity tagging.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e1 = u:spawn()
    local e2 = u:spawn()
    u:addTag(e1, "enemy")
    print(u:hasTag(e1, "enemy"))
    print(u:hasTag(e2, "enemy"))
    local tags = u:getTags(e1)
    for _, t in ipairs(tags) do print(t) end
    u:removeTag(e1, "enemy")
    print(u:hasTag(e1, "enemy"))
end

--@api-stub: LUniverse:bitmapTag
--@api-stub: LUniverse:bitmapUntag
--@api-stub: LUniverse:getBitmapTagBit
--@api-stub: LUniverse:hasBitmapTag
--@api-stub: LUniverse:queryBitmapAll
--@api-stub: LUniverse:queryBitmapAny
--@api-stub: LUniverse:queryBitmapTag
-- Bitmap tag queries for bulk entity filtering.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e1 = u:spawn()
    u:bitmapTag(e1, "enemy")
    local bit = u:getBitmapTagBit("enemy")
    print("bit = " .. tostring(bit))
    print(u:hasBitmapTag(e1, "enemy"))
    local all = u:queryBitmapAll({ "enemy" })
    local any = u:queryBitmapAny({ "enemy" })
    local tagged = u:queryBitmapTag("enemy")
    for _, id in ipairs(tagged) do print(id) end
    u:bitmapUntag(e1, "enemy")
end

--@api-stub: LUniverse:extendBlueprint
--@api-stub: LUniverse:hasBlueprint
--@api-stub: LUniverse:listBlueprints
--@api-stub: LUniverse:removeBlueprint
-- Blueprint extension and introspection.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
    print(u:hasBlueprint("missing"))
    local names = u:listBlueprints()
    for _, n in ipairs(names) do print(n) end
    u:removeBlueprint("enemy")
    print(u:hasBlueprint("enemy"))
end

--@api-stub: LUniverse:getEntitiesByLayer
--@api-stub: LUniverse:getEntitiesByTag
--@api-stub: LUniverse:getEntitiesSorted
--@api-stub: LUniverse:getLayer
--@api-stub: LUniverse:setLayer
-- Layer-based entity queries.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:setLayer(e, 2)
    local layer = u:getLayer(e)
    print("layer = " .. tostring(layer))
    local byLayer = u:getEntitiesByLayer(2)
    for _, id in ipairs(byLayer) do print(id) end
    u:addTag(e, "unit")
    local byTag = u:getEntitiesByTag("unit")
    for _, id in ipairs(byTag) do print(id) end
    local sorted = u:getEntitiesSorted()
    print("sorted count = " .. #sorted)
end

--@api-stub: LUniverse:applySnapshot
--@api-stub: LUniverse:takeSnapshotDiff
--@api-stub: LUniverse:clear
--@api-stub: LUniverse:release
-- Snapshot diffing and universe lifecycle.
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    print("diff keys = " .. tostring(diff))
    u:applySnapshot(diff)
    u:clear()
    print("cleared")
    u:release()
    print("released")
end

print("content/examples/ecs.lua")
