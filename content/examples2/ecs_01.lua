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

print("ecs_01.lua")
