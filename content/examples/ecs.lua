-- content/examples/ecs.lua
-- Auto-generated from content/examples2/ecs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ecs.lua

--- ECS Module Part 1: Universe creation, entities, components, systems, queries

--@api: lurek.ecs.newUniverse
do
    local uni = lurek.ecs.newUniverse()
    print("universe created, entities = " .. uni:getEntityCount())
end

--@api: LUniverse:spawn
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("spawned entity id = " .. id)
end

--@api: LUniverse:kill
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:kill(id)
    print("killed, alive = " .. tostring(uni:isAlive(id)))
end

--@api: LUniverse:isAlive
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("alive = " .. tostring(uni:isAlive(id)))
end

--@api: LUniverse:set
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    print("position set")
end

--@api: LUniverse:get
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    print("hp.value = " .. tostring(hp.value))
end

--@api: LUniverse:has
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    print("has speed = " .. tostring(uni:has(id, "speed")))
end

--@api: LUniverse:remove
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    print("after remove has = " .. tostring(uni:has(id, "temp")))
end

--@api: LUniverse:getComponents
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0})
    uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    print("components = " .. #names)
end

--@api: LUniverse:query
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 5, y = 5})
    print("with pos+vel = " .. #uni:query("pos", "vel"))
end

--@api: LUniverse:each
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0
    uni:each("name", function(entity_id, name_value)
        count = count + 1
        print("visited entity = " .. tostring(entity_id))
        print("name.value = " .. tostring(name_value.value))
    end)
    print("each count = " .. count)
end

--@api: LUniverse:getEntities
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    print("entities = " .. #all)
end

--@api: LUniverse:getEntityCount
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    print("count = " .. uni:getEntityCount())
end

--@api: LUniverse:addSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = { update = function(self, universe, dt) end }
    uni:addSystem(sys, {name = "movement", priority = 1})
    print("systems = " .. uni:getSystemCount())
end

--@api: LUniverse:removeSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    print("after remove systems = " .. uni:getSystemCount())
end

--@api: LUniverse:update
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    print("update called = " .. tostring(called))
end

--@api: LUniverse:render
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    print("render called = " .. tostring(drawn))
end

--@api: LUniverse:emit
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    print("emit received = " .. tostring(got))
end

--@api: LUniverse:getSystemCount
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end})
    uni:addSystem({draw = function() end})
    print("system count = " .. uni:getSystemCount())
end

--@api: LUniverse:updatePhase
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    print("phase ran = " .. tostring(ran))
end

--@api: LUniverse:getDirtyEntities
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    print("dirty = " .. #dirty)
end

--@api: LUniverse:queryMulti
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "a", {value = 1})
    uni:set(id, "b", {value = 2})
    local count = 0
    uni:queryMulti({"a", "b"}, function(entity_id, a_value, b_value)
        count = count + 1
        print("queryMulti entity = " .. tostring(entity_id))
        print("values = " .. tostring(a_value.value) .. "," .. tostring(b_value.value))
    end)
    print("queryMulti = " .. count)
end

--@api: LUniverse:snapshot
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    print("snapshot type = " .. type(snap))
    print("snapshot entities = " .. #snap.entities)
end

--- ECS Module Part 2: Blueprints, hierarchy, relations, serialization, observers, advanced queries

--@api: LUniverse:defineBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {pos = {x = 0, y = 0}, hp = {value = 50}, tag = {value = "hostile"}})
    print("blueprint defined")
end

--@api: LUniverse:getBlueprintComponents
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    print("blueprint comps type = " .. type(comps))
    print("damage = " .. tostring(comps.damage.value))
end

--@api: LUniverse:spawnBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    print("spawned from blueprint id = " .. id)
end

--@api: LUniverse:setParent
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    print("parent set")
end

--@api: LUniverse:getParent
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    print("parent = " .. p)
end

--@api: LUniverse:getChildren
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

--@api: LUniverse:killRecursive
do
    local uni = lurek.ecs.newUniverse()
    local root = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    print("child alive = " .. tostring(uni:isAlive(child)))
end

--@api: LUniverse:queryNot
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "static", {flag = true})
    uni:set(b, "pos", {x = 1, y = 1})
    print("moving entities = " .. #uni:queryNot({"pos"}, {"static"}))
end

--@api: LUniverse:serialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    print("entities in snapshot = " .. #snap.entities)
end

--@api: LUniverse:deserialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    uni:deserialize(uni:serialize())
    print("deserialized, count = " .. uni:getEntityCount())
end

--@api: LUniverse:onComponentAdded
do
    local uni = lurek.ecs.newUniverse()
    local added = false
    uni:onComponentAdded("hp", function() added = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    print("added callback fired = " .. tostring(added))
end

--@api: LUniverse:onComponentRemoved
do
    local uni = lurek.ecs.newUniverse()
    local removed = false
    uni:onComponentRemoved("hp", function() removed = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 50})
    uni:remove(id, "hp")
    uni:flushObservers()
    print("removed callback fired = " .. tostring(removed))
end

--@api: LUniverse:flushObservers
do
    local uni = lurek.ecs.newUniverse()
    uni:flushObservers()
    print("observers flushed")
end

--@api: LUniverse:spawnBulk
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    print("bulk spawned = " .. #ids)
end

--@api: LUniverse:addRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    print("relation added")
end

--@api: LUniverse:getRelated
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

--@api: LUniverse:removeRelation
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    print("relation removed")
end

--@api: LUniverse:clearRelations
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    print("after clear = " .. #targets)
end

--@api: LUniverse:hasRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    print("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end

--@api: LUniverse:type
do
    local uni = lurek.ecs.newUniverse()
    print("type = " .. uni:type())
end

--@api: LUniverse:typeOf
do
    local uni = lurek.ecs.newUniverse()
    print("is LUniverse = " .. tostring(uni:typeOf("LUniverse")))
end

--- ECS Module: tag system, blueprints, layers, snapshots

--@api: LUniverse:defineTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api: LUniverse:addTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api: LUniverse:removeTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    u:removeTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api: LUniverse:hasTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api: LUniverse:getTags
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    print(#u:getTags(e))
end

--@api: LUniverse:bitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:bitmapUntag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    u:bitmapUntag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:getBitmapTagBit
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    print("bit = " .. tostring(u:getBitmapTagBit("enemy")))
end

--@api: LUniverse:hasBitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:queryBitmapAll
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAll({"enemy"}))
end

--@api: LUniverse:queryBitmapAny
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAny({"enemy"}))
end

--@api: LUniverse:queryBitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapTag("enemy"))
end

--@api: LUniverse:extendBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end

--@api: LUniverse:hasBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end

--@api: LUniverse:listBlueprints
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(#u:listBlueprints())
end

--@api: LUniverse:removeBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:removeBlueprint("enemy")
    print(u:hasBlueprint("enemy"))
end

--@api: LUniverse:getEntitiesByLayer
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print(#u:getEntitiesByLayer(2))
end

--@api: LUniverse:getEntitiesByTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:addTag(e, "unit")
    print(#u:getEntitiesByTag("unit"))
end

--@api: LUniverse:getEntitiesSorted
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("sorted count = " .. #u:getEntitiesSorted())
end

--@api: LUniverse:getLayer
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end

--@api: LUniverse:setLayer
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end

--@api: LUniverse:applySnapshot
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local snap = u:snapshot()
    u:clear()
    u:applySnapshot(snap)
    print("entities after apply = " .. u:getEntityCount())
end

--@api: LUniverse:takeSnapshotDiff
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    print("dirty entities = " .. tostring(#diff.dirty_entities))
end

--@api: LUniverse:clear
do
    local u = lurek.ecs.newUniverse()
    u:spawn()
    u:clear()
    print("entities after clear = " .. u:getEntityCount())
end

--@api: LUniverse:release
do
    local u = lurek.ecs.newUniverse()
    u:release()
    print("released")
end
