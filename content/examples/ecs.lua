-- content/examples/ecs.lua
-- Auto-generated from content/examples2/ecs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ecs.lua

--- ECS Module Part 1: Universe creation, entities, components, systems, queries


--@api-stub: lurek.ecs.newUniverse
do
    local uni = lurek.ecs.newUniverse()
    print("universe created, entities = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:spawn
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("spawned entity id = " .. id)
end

--@api-stub: LUniverse:kill
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:kill(id)
    print("killed, alive = " .. tostring(uni:isAlive(id)))
end

--@api-stub: LUniverse:isAlive
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    print("alive = " .. tostring(uni:isAlive(id)))
end

--@api-stub: LUniverse:set
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    print("position set")
end

--@api-stub: LUniverse:get
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    print("hp = " .. tostring(hp))
end

--@api-stub: LUniverse:has
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    print("has speed = " .. tostring(uni:has(id, "speed")))
end

--@api-stub: LUniverse:remove
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    print("after remove has = " .. tostring(uni:has(id, "temp")))
end

--@api-stub: LUniverse:getComponents
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0}); uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    print("components = " .. #names)
end

--@api-stub: LUniverse:query
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0}); uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn(); uni:set(b, "pos", {x = 5, y = 5}); print("with pos+vel = " .. #uni:query("pos", "vel"))
end

--@api-stub: LUniverse:each
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0; uni:each("name", function() count = count + 1 end)
    print("each count = " .. count)
end

--@api-stub: LUniverse:getEntities
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    print("entities = " .. #all)
end

--@api-stub: LUniverse:getEntityCount
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    print("count = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:addSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = { update = function(self, universe, dt) end }
    uni:addSystem(sys, {name = "movement", priority = 1})
    print("systems = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:removeSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    print("after remove systems = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:update
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    print("update called = " .. tostring(called))
end

--@api-stub: LUniverse:render
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    print("render called = " .. tostring(drawn))
end

--@api-stub: LUniverse:emit
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    print("emit received = " .. tostring(got))
end

--@api-stub: LUniverse:getSystemCount
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end})
    uni:addSystem({draw = function() end})
    print("system count = " .. uni:getSystemCount())
end

--@api-stub: LUniverse:updatePhase
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    print("phase ran = " .. tostring(ran))
end

--@api-stub: LUniverse:getDirtyEntities
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    print("dirty = " .. #dirty)
end

--@api-stub: LUniverse:queryMulti
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "a", {value = 1}); uni:set(id, "b", {value = 2})
    local count = 0; uni:queryMulti({"a", "b"}, function() count = count + 1 end)
    print("queryMulti = " .. count)
end

--@api-stub: LUniverse:snapshot
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    print("snapshot type = " .. type(snap))
end

--- ECS Module Part 2: Blueprints, hierarchy, relations, serialization, observers, advanced queries


--@api-stub: LUniverse:defineBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {pos = {x = 0, y = 0}, hp = {value = 50}, tag = {value = "hostile"}})
    print("blueprint defined")
end

--@api-stub: LUniverse:getBlueprintComponents
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    print("blueprint comps type = " .. type(comps))
end

--@api-stub: LUniverse:spawnBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    print("spawned from blueprint id = " .. id)
end

--@api-stub: LUniverse:setParent
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    print("parent set")
end

--@api-stub: LUniverse:getParent
do
    local uni = lurek.ecs.newUniverse()
    local parent, child = uni:spawn(), uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    print("parent = " .. p)
end

--@api-stub: LUniverse:getChildren
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local c1, c2 = uni:spawn(), uni:spawn(); uni:setParent(c1, parent); uni:setParent(c2, parent)
    local children = uni:getChildren(parent)
    print("children = " .. #children)
end

--@api-stub: LUniverse:killRecursive
do
    local uni = lurek.ecs.newUniverse()
    local root, child = uni:spawn(), uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    print("child alive = " .. tostring(uni:isAlive(child)))
end

--@api-stub: LUniverse:queryNot
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0}); uni:set(a, "static", {flag = true})
    uni:set(b, "pos", {x = 1, y = 1}); print("moving entities = " .. #uni:queryNot({"pos"}, {"static"}))
end

--@api-stub: LUniverse:serialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    print("entities in snapshot = " .. #snap.entities)
end

--@api-stub: LUniverse:deserialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    uni:deserialize(uni:serialize())
    print("deserialized, count = " .. uni:getEntityCount())
end

--@api-stub: LUniverse:onComponentAdded
do
    local uni = lurek.ecs.newUniverse(); local added = false
    uni:onComponentAdded("hp", function() added = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100}); uni:flushObservers()
    print("added callback fired = " .. tostring(added))
end

--@api-stub: LUniverse:onComponentRemoved
do
    local uni = lurek.ecs.newUniverse(); local removed = false
    uni:onComponentRemoved("hp", function() removed = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 50}); uni:remove(id, "hp"); uni:flushObservers()
    print("removed callback fired = " .. tostring(removed))
end

--@api-stub: LUniverse:flushObservers
do
    local uni = lurek.ecs.newUniverse()
    uni:flushObservers()
    print("observers flushed")
end

--@api-stub: LUniverse:spawnBulk
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    print("bulk spawned = " .. #ids)
end

--@api-stub: LUniverse:addRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    print("relation added")
end

--@api-stub: LUniverse:getRelated
do
    local uni = lurek.ecs.newUniverse()
    local a, b, c = uni:spawn(), uni:spawn(), uni:spawn()
    uni:addRelation(a, "friend", b); uni:addRelation(a, "friend", c)
    local friends = uni:getRelated(a, "friend")
    print("friends = " .. #friends)
end

--@api-stub: LUniverse:removeRelation
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    print("relation removed")
end

--@api-stub: LUniverse:clearRelations
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn(); uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    print("after clear = " .. #targets)
end

--@api-stub: LUniverse:hasRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    print("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end

--@api-stub: LUniverse:type
do
    local uni = lurek.ecs.newUniverse()
    print("type = " .. uni:type())
end

--@api-stub: LUniverse:typeOf
do
    local uni = lurek.ecs.newUniverse()
    print("is LUniverse = " .. tostring(uni:typeOf("LUniverse")))
end

--- ECS Module: tag system, blueprints, layers, snapshots


--@api-stub: LUniverse:defineTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    print(u:hasTag(e, "enemy"))
end

--@api-stub: LUniverse:addTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api-stub: LUniverse:removeTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:addTag(e, "enemy"); u:removeTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api-stub: LUniverse:hasTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:addTag(e, "enemy")
    print(u:hasTag(e, "enemy"))
end

--@api-stub: LUniverse:getTags
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:addTag(e, "enemy")
    print(#u:getTags(e))
end

--@api-stub: LUniverse:bitmapTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api-stub: LUniverse:bitmapUntag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy"); u:bitmapUntag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api-stub: LUniverse:getBitmapTagBit
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    print("bit = " .. tostring(u:getBitmapTagBit("enemy")))
end

--@api-stub: LUniverse:hasBitmapTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(u:hasBitmapTag(e, "enemy"))
end

--@api-stub: LUniverse:queryBitmapAll
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAll({"enemy"}))
end

--@api-stub: LUniverse:queryBitmapAny
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapAny({"enemy"}))
end

--@api-stub: LUniverse:queryBitmapTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy"); local e = u:spawn()
    u:bitmapTag(e, "enemy")
    print(#u:queryBitmapTag("enemy"))
end

--@api-stub: LUniverse:extendBlueprint
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end

--@api-stub: LUniverse:hasBlueprint
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(u:hasBlueprint("enemy"))
end

--@api-stub: LUniverse:listBlueprints
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    print(#u:listBlueprints())
end

--@api-stub: LUniverse:removeBlueprint
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 }); u:extendBlueprint("enemy", "base", { damage = 10 })
    u:removeBlueprint("enemy")
    print(u:hasBlueprint("enemy"))
end

--@api-stub: LUniverse:getEntitiesByLayer
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print(#u:getEntitiesByLayer(2))
end

--@api-stub: LUniverse:getEntitiesByTag
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit"); local e = u:spawn()
    u:addTag(e, "unit")
    print(#u:getEntitiesByTag("unit"))
end

--@api-stub: LUniverse:getEntitiesSorted
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("sorted count = " .. #u:getEntitiesSorted())
end

--@api-stub: LUniverse:getLayer
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end

--@api-stub: LUniverse:setLayer
do
    ---@type LUniverse
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    print("layer = " .. tostring(u:getLayer(e)))
end

--@api-stub: LUniverse:applySnapshot
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local snap = u:snapshot(); u:clear(); u:applySnapshot(snap)
    print("entities after apply = " .. u:getEntityCount())
end

--@api-stub: LUniverse:takeSnapshotDiff
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    print("dirty entities = " .. tostring(#diff.dirty_entities))
end

--@api-stub: LUniverse:clear
do
    local u = lurek.ecs.newUniverse()
    u:spawn()
    u:clear()
    print("entities after clear = " .. u:getEntityCount())
end

--@api-stub: LUniverse:release
do
    local u = lurek.ecs.newUniverse()
    u:release()
    print("released")
end

print("content/examples/ecs.lua")
