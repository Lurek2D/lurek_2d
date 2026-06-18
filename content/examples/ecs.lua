-- content/examples/ecs.lua
-- Auto-generated from content/examples2/ecs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/ecs.lua

local function ecs_log(message)
    lurek.log.info("[ecs.example] " .. tostring(message))
end

--- ECS Module Part 1: Universe creation, entities, components, systems, queries

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.ecs.newUniverse
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    uni:set(hero, "name", "hero")
    local entities = uni:getEntities()
    local count = uni:getEntityCount()
    ecs_log("universe created count=" .. tostring(count) .. " first_id=" .. tostring(entities[1]) .. " hero_name=" .. tostring(uni:get(hero, "name")))
end

--@api: lurek.ecs.newRelationshipManager
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("stance", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "stance", "friendly")
    rm:setValue(1, 2, 25)
    local level = rm:getLevel(1, 2, "stance")
    local score = rm:getValue(1, 2)
    ecs_log("relationship manager level=" .. tostring(level) .. " score=" .. tostring(score) .. " pairs=" .. tostring(rm:pairCount()))
end

--@api: LRelationshipManager:type
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local type_name = rm:type()
    local is_rm = rm:typeOf("LRelationshipManager")
    local type_count = #rm:typeNames()
    ecs_log("relationship manager type=" .. tostring(type_name) .. " is_rm=" .. tostring(is_rm) .. " type_count=" .. tostring(type_count))
end

--@api: LRelationshipManager:typeOf
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("stance", {"hostile", "neutral", "friendly"}, "neutral")
    local is_relationship_manager = rm:typeOf("LRelationshipManager")
    local is_object = rm:typeOf("LObject")
    local is_universe = rm:typeOf("LUniverse")
    ecs_log("relationship manager type guard rm=" .. tostring(is_relationship_manager) .. " object=" .. tostring(is_object) .. " universe=" .. tostring(is_universe))
end

--@api: LRelationshipManager:defineType
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local types = rm:typeNames()
    local first = types[1]
    local second = types[2]
    ecs_log("defined relationship types count=" .. tostring(#types) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
end

--@api: LRelationshipManager:removeType
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    example_print_log("before = " .. #rm:typeNames())
    rm:removeType("friendship")
    example_print_log("after = " .. #rm:typeNames())
end

--@api: LRelationshipManager:typeNames
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:defineType("trust", {"low", "medium", "high"}, "medium")
    local types = rm:typeNames()
    example_print_log("types = " .. #types)
    example_print_log("first = " .. tostring(types[1]))
end

--@api: LRelationshipManager:setValue
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("1->3 = " .. rm:getValue(1, 3))
end

--@api: LRelationshipManager:getValue
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("1->3 = " .. rm:getValue(1, 3))
end

--@api: LRelationshipManager:adjustValue
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:adjustValue(1, 2, 10)
    example_print_log("1->2 = " .. rm:getValue(1, 2))
    example_print_log("pairs = " .. rm:pairCount())
end

--@api: LRelationshipManager:setLevel
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    example_print_log("pairs = " .. rm:pairCount())
end

--@api: LRelationshipManager:getLevel
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
    example_print_log("types = " .. #rm:typeNames())
end

--@api: LRelationshipManager:removePair
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    example_print_log("before = " .. rm:pairCount())
    rm:removePair(1, 3)
    example_print_log("after = " .. rm:pairCount())
end

--@api: LRelationshipManager:pairCount
do
    local rm = lurek.ecs.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    example_print_log("pairs = " .. rm:pairCount())
    example_print_log("level = " .. tostring(rm:getLevel(1, 2, "friendship")))
end

--@api: LUniverse:spawn
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    local enemy = uni:spawn()
    uni:set(hero, "name", "hero")
    uni:set(enemy, "name", "enemy")
    local ids = uni:getEntities()
    ecs_log("spawned entities hero=" .. tostring(hero) .. " enemy=" .. tostring(enemy) .. " live_count=" .. tostring(#ids))
end

--@api: LUniverse:kill
do
    local uni = lurek.ecs.newUniverse()
    local owner = uni:spawn()
    local minion = uni:spawn()
    uni:addRelation(owner, "owns", minion)
    uni:kill(minion)
    local alive = uni:isAlive(minion)
    local owned = #uni:getRelated(owner, "owns")
    ecs_log("kill removed minion alive=" .. tostring(alive) .. " owner_links=" .. tostring(owned) .. " entity_count=" .. tostring(uni:getEntityCount()))
end

--@api: LUniverse:isAlive
do
    local uni = lurek.ecs.newUniverse()
    local hero = uni:spawn()
    local prop = uni:spawn()
    local hero_alive = uni:isAlive(hero)
    uni:kill(prop)
    local prop_alive = uni:isAlive(prop)
    ecs_log("liveness hero=" .. tostring(hero_alive) .. " prop=" .. tostring(prop_alive) .. " entity_count=" .. tostring(uni:getEntityCount()))
end

--@api: LUniverse:set
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "position", {x = 10, y = 20})
    uni:set(id, "hp", {value = 100})
    local pos = uni:get(id, "position")
    local hp = uni:get(id, "hp")
    ecs_log("components set pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " hp=" .. tostring(hp.value))
end

--@api: LUniverse:get
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    local hp = uni:get(id, "hp")
    example_print_log("hp.value = " .. tostring(hp.value))
end

--@api: LUniverse:has
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "speed", {value = 5})
    uni:set(id, "hp", {value = 20})
    local has_speed = uni:has(id, "speed")
    local has_hp = uni:has(id, "hp")
    local has_mp = uni:has(id, "mp")
    ecs_log("component presence speed=" .. tostring(has_speed) .. " hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api: LUniverse:remove
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "temp", {flag = true})
    uni:remove(id, "temp")
    example_print_log("after remove has = " .. tostring(uni:has(id, "temp")))
end

--@api: LUniverse:getComponents
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 0, y = 0})
    uni:set(id, "vel", {x = 1, y = 0})
    local names = uni:getComponents(id)
    example_print_log("components = " .. #names)
end

--@api: LUniverse:query
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "vel", {x = 1, y = 0})
    local b = uni:spawn()
    uni:set(b, "pos", {x = 5, y = 5})
    example_print_log("with pos+vel = " .. #uni:query("pos", "vel"))
end

--@api: LUniverse:getQueryChangeTick
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    uni:newQueryView({"pos"})
    example_print_log("query tick = " .. tostring(uni:getQueryChangeTick()))
end

--@api: LUniverse:newQueryView
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("view created = " .. tostring(view ~= nil))
end

--@api: LQueryView:ids
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("cached ids = " .. #view:ids())
end

--@api: LQueryView:lastTick
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("view tick = " .. tostring(view:lastTick()))
end

--@api: LQueryView:type
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("query view type = " .. view:type())
end

--@api: LQueryView:typeOf
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "pos", {x = 3, y = 4})
    local view = uni:newQueryView({"pos"})
    example_print_log("is query view = " .. tostring(view:typeOf("LQueryView")))
end

--@api: LUniverse:each
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "name", {value = "hero"})
    local count = 0
    uni:each("name", function(entity_id, name_value)
        count = count + 1
        example_print_log("visited entity = " .. tostring(entity_id))
        example_print_log("name.value = " .. tostring(name_value.value))
    end)
    example_print_log("each count = " .. count)
end

--@api: LUniverse:getEntities
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    local all = uni:getEntities()
    example_print_log("entities = " .. #all)
end

--@api: LUniverse:getEntityCount
do
    local uni = lurek.ecs.newUniverse()
    uni:spawn()
    uni:spawn()
    uni:spawn()
    example_print_log("count = " .. uni:getEntityCount())
end

--@api: LUniverse:addSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = { update = function(self, universe, dt) universe:emit("on_tick", dt) end }
    uni:addSystem(sys, {name = "movement", priority = 1})
    uni:addSystem({ render = function() end }, {name = "draw", priority = 2})
    local count = uni:getSystemCount()
    uni:update(1 / 60)
    ecs_log("systems registered count=" .. tostring(count) .. " query_tick=" .. tostring(uni:getQueryChangeTick()))
end

--@api: LUniverse:removeSystem
do
    local uni = lurek.ecs.newUniverse()
    local sys = {update = function() end}
    uni:addSystem(sys)
    uni:removeSystem(sys)
    example_print_log("after remove systems = " .. uni:getSystemCount())
end

--@api: LUniverse:update
do
    local uni = lurek.ecs.newUniverse()
    local called = false
    uni:addSystem({update = function() called = true end})
    uni:update(1 / 60)
    example_print_log("update called = " .. tostring(called))
end

--@api: LUniverse:render
do
    local uni = lurek.ecs.newUniverse()
    local drawn = false
    uni:addSystem({draw = function() drawn = true end})
    uni:render()
    example_print_log("render called = " .. tostring(drawn))
end

--@api: LUniverse:emit
do
    local uni = lurek.ecs.newUniverse()
    local got = false
    uni:addSystem({on_damage = function() got = true end})
    uni:emit("on_damage")
    example_print_log("emit received = " .. tostring(got))
end

--@api: LUniverse:getSystemCount
do
    local uni = lurek.ecs.newUniverse()
    uni:addSystem({update = function() end}, {name = "movement", priority = 1})
    uni:addSystem({draw = function() end}, {name = "render", priority = 2})
    local count = uni:getSystemCount()
    local hero = uni:spawn()
    uni:set(hero, "name", "hero")
    ecs_log("system count=" .. tostring(count) .. " hero_alive=" .. tostring(uni:isAlive(hero)))
end

--@api: LUniverse:updatePhase
do
    local uni = lurek.ecs.newUniverse()
    local ran = false
    uni:addSystem({update = function() ran = true end}, {phase = "physics"})
    uni:updatePhase("physics", 1 / 60)
    example_print_log("phase ran = " .. tostring(ran))
end

--@api: LUniverse:getDirtyEntities
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "x", {value = 1})
    local dirty = uni:getDirtyEntities()
    example_print_log("dirty = " .. #dirty)
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
        example_print_log("queryMulti entity = " .. tostring(entity_id))
        example_print_log("values = " .. tostring(a_value.value) .. "," .. tostring(b_value.value))
    end)
    example_print_log("queryMulti = " .. count)
end

--@api: LUniverse:snapshot
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "val", {value = 42})
    local snap = uni:snapshot()
    example_print_log("snapshot type = " .. type(snap))
    example_print_log("snapshot entities = " .. #snap.entities)
end

--- ECS Module Part 2: Blueprints, hierarchy, relations, serialization, observers, advanced queries

--@api: LUniverse:defineBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("enemy", {pos = {x = 0, y = 0}, hp = {value = 50}, tag = {value = "hostile"}})
    local comps = uni:getBlueprintComponents("enemy")
    local spawned = uni:spawnBlueprint("enemy")
    local hp = uni:get(spawned, "hp")
    ecs_log("blueprint enemy defined hp=" .. tostring(comps.hp.value) .. " spawned=" .. tostring(spawned) .. " live_hp=" .. tostring(hp.value))
end

--@api: LUniverse:getBlueprintComponents
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("item", {name = {value = "sword"}, damage = {value = 10}})
    local comps = uni:getBlueprintComponents("item")
    example_print_log("blueprint comps type = " .. type(comps))
    example_print_log("damage = " .. tostring(comps.damage.value))
end

--@api: LUniverse:spawnBlueprint
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("npc", {pos = {x = 0, y = 0}})
    local id = uni:spawnBlueprint("npc", {pos = {x = 5, y = 5}})
    local pos = uni:get(id, "pos")
    local components = uni:getComponents(id)
    local alive = uni:isAlive(id)
    ecs_log("spawned blueprint id=" .. tostring(id) .. " pos=" .. tostring(pos.x) .. "," .. tostring(pos.y) .. " components=" .. tostring(#components) .. " alive=" .. tostring(alive))
end

--@api: LUniverse:setParent
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    example_print_log("parent set")
end

--@api: LUniverse:getParent
do
    local uni = lurek.ecs.newUniverse()
    local parent = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, parent)
    local p = uni:getParent(child)
    example_print_log("parent = " .. p)
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
    example_print_log("children = " .. #children)
end

--@api: LUniverse:killRecursive
do
    local uni = lurek.ecs.newUniverse()
    local root = uni:spawn()
    local child = uni:spawn()
    uni:setParent(child, root)
    uni:killRecursive(root)
    example_print_log("child alive = " .. tostring(uni:isAlive(child)))
end

--@api: LUniverse:queryNot
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:set(a, "pos", {x = 0, y = 0})
    uni:set(a, "static", {flag = true})
    uni:set(b, "pos", {x = 1, y = 1})
    example_print_log("moving entities = " .. #uni:queryNot({"pos"}, {"static"}))
end

--@api: LUniverse:serialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "data", {k = "v"})
    local snap = uni:serialize()
    example_print_log("entities in snapshot = " .. #snap.entities)
end

--@api: LUniverse:deserialize
do
    local uni = lurek.ecs.newUniverse()
    local id = uni:spawn()
    uni:set(id, "score", {value = 99})
    uni:deserialize(uni:serialize())
    example_print_log("deserialized, count = " .. uni:getEntityCount())
end

--@api: LUniverse:onComponentAdded
do
    local uni = lurek.ecs.newUniverse()
    local added = false
    uni:onComponentAdded("hp", function() added = true end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    example_print_log("added callback fired = " .. tostring(added))
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
    example_print_log("removed callback fired = " .. tostring(removed))
end

--@api: LUniverse:flushObservers
do
    local uni = lurek.ecs.newUniverse()
    local fired = 0
    uni:onComponentAdded("hp", function() fired = fired + 1 end)
    local id = uni:spawn()
    uni:set(id, "hp", {value = 100})
    uni:flushObservers()
    ecs_log("observers flushed fired=" .. tostring(fired) .. " entity=" .. tostring(id) .. " dirty=" .. tostring(#uni:getDirtyEntities()))
end

--@api: LUniverse:spawnBulk
do
    local uni = lurek.ecs.newUniverse()
    uni:defineBlueprint("bullet", {pos = {x = 0, y = 0}})
    local ids = uni:spawnBulk("bullet", 10)
    local first = ids[1]
    local first_pos = first and uni:get(first, "pos") or nil
    local count = uni:getEntityCount()
    ecs_log("bulk spawned count=" .. tostring(#ids) .. " first=" .. tostring(first) .. " first_pos_x=" .. tostring(first_pos and first_pos.x) .. " live_count=" .. tostring(count))
end

--@api: LUniverse:addRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "likes", b)
    example_print_log("relation added")
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
    example_print_log("friends = " .. #friends)
end

--@api: LUniverse:removeRelation
do
    local uni = lurek.ecs.newUniverse()
    local a, b = uni:spawn(), uni:spawn()
    uni:addRelation(a, "owns", b)
    uni:removeRelation(a, "owns", b)
    example_print_log("relation removed")
end

--@api: LUniverse:clearRelations
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "sees", b)
    uni:clearRelations(a, "sees")
    local targets = uni:getRelated(a, "sees")
    example_print_log("after clear = " .. #targets)
end

--@api: LUniverse:hasRelation
do
    local uni = lurek.ecs.newUniverse()
    local a = uni:spawn()
    local b = uni:spawn()
    uni:addRelation(a, "attacks", b)
    example_print_log("has relation = " .. tostring(uni:hasRelation(a, "attacks", b)))
end

--@api: LUniverse:type
do
    local uni = lurek.ecs.newUniverse()
    local type_name = uni:type()
    local entity = uni:spawn()
    local count = uni:getEntityCount()
    ecs_log("universe type=" .. tostring(type_name) .. " entity=" .. tostring(entity) .. " count=" .. tostring(count))
end

--@api: LUniverse:typeOf
do
    local uni = lurek.ecs.newUniverse()
    local is_universe = uni:typeOf("LUniverse")
    local is_object = uni:typeOf("LObject")
    local is_rm = uni:typeOf("LRelationshipManager")
    ecs_log("universe type guard universe=" .. tostring(is_universe) .. " object=" .. tostring(is_object) .. " rm=" .. tostring(is_rm))
end

--- ECS Module: tag system, blueprints, layers, snapshots

--@api: LUniverse:defineTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end

--@api: LUniverse:addTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end

--@api: LUniverse:removeTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    u:removeTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end

--@api: LUniverse:hasTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(u:hasTag(e, "enemy"))
end

--@api: LUniverse:getTags
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:addTag(e, "enemy")
    example_print_log(#u:getTags(e))
end

--@api: LUniverse:bitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:bitmapUntag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    u:bitmapUntag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:getBitmapTagBit
do
    local u = lurek.ecs.newUniverse()
    local bit = u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    local queried_bit = u:getBitmapTagBit("enemy")
    local has_tag = u:hasBitmapTag(e, "enemy")
    ecs_log("bitmap tag bit defined=" .. tostring(bit) .. " queried=" .. tostring(queried_bit) .. " has_tag=" .. tostring(has_tag))
end

--@api: LUniverse:hasBitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(u:hasBitmapTag(e, "enemy"))
end

--@api: LUniverse:queryBitmapAll
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapAll({"enemy"}))
end

--@api: LUniverse:queryBitmapAny
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapAny({"enemy"}))
end

--@api: LUniverse:queryBitmapTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("enemy")
    local e = u:spawn()
    u:bitmapTag(e, "enemy")
    example_print_log(#u:queryBitmapTag("enemy"))
end

--@api: LUniverse:extendBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    local id = u:spawnBlueprint("enemy")
    local hp = u:get(id, "hp")
    local damage = u:get(id, "damage")
    ecs_log("extended blueprint exists=" .. tostring(u:hasBlueprint("enemy")) .. " hp=" .. tostring(hp) .. " damage=" .. tostring(damage))
end

--@api: LUniverse:hasBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    local has_enemy = u:hasBlueprint("enemy")
    local has_boss = u:hasBlueprint("boss")
    local names = u:listBlueprints()
    ecs_log("has blueprint enemy=" .. tostring(has_enemy) .. " boss=" .. tostring(has_boss) .. " total=" .. tostring(#names))
end

--@api: LUniverse:listBlueprints
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:defineBlueprint("bullet", { speed = 50 })
    local names = u:listBlueprints()
    local first = names[1]
    local last = names[#names]
    ecs_log("blueprint names total=" .. tostring(#names) .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end

--@api: LUniverse:removeBlueprint
do
    local u = lurek.ecs.newUniverse()
    u:defineBlueprint("base", { hp = 100 })
    u:extendBlueprint("enemy", "base", { damage = 10 })
    u:removeBlueprint("enemy")
    example_print_log(u:hasBlueprint("enemy"))
end

--@api: LUniverse:getEntitiesByLayer
do
    local u = lurek.ecs.newUniverse()
    local low = u:spawn()
    local high = u:spawn()
    u:setLayer(low, 2)
    u:setLayer(high, 5)
    local ids = u:getEntitiesByLayer(2)
    local sorted = u:getEntitiesSorted()
    ecs_log("entities by layer count=" .. tostring(#ids) .. " first_layer_two=" .. tostring(ids[1]) .. " sorted_first=" .. tostring(sorted[1]))
end

--@api: LUniverse:getEntitiesByTag
do
    local u = lurek.ecs.newUniverse()
    u:defineTag("unit")
    local e = u:spawn()
    u:addTag(e, "unit")
    example_print_log(#u:getEntitiesByTag("unit"))
end

--@api: LUniverse:getEntitiesSorted
do
    local u = lurek.ecs.newUniverse()
    local high = u:spawn()
    local low = u:spawn()
    u:setLayer(high, 5)
    u:setLayer(low, 1)
    local sorted = u:getEntitiesSorted()
    local first = sorted[1]
    local second = sorted[2]
    ecs_log("sorted entities count=" .. tostring(#sorted) .. " first=" .. tostring(first) .. " second=" .. tostring(second))
end

--@api: LUniverse:getLayer
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    local layer = u:getLayer(e)
    local count = #u:getEntitiesByLayer(2)
    local sorted = u:getEntitiesSorted()
    ecs_log("entity layer=" .. tostring(layer) .. " same_layer_count=" .. tostring(count) .. " sorted_first=" .. tostring(sorted[1]))
end

--@api: LUniverse:setLayer
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:setLayer(e, 2)
    local before = u:getLayer(e)
    u:setLayer(e, 4)
    local after = u:getLayer(e)
    local layer_entities = u:getEntitiesByLayer(4)
    ecs_log("set layer before=" .. tostring(before) .. " after=" .. tostring(after) .. " layer_entities=" .. tostring(#layer_entities))
end

--@api: LUniverse:applySnapshot
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local snap = u:snapshot()
    u:clear()
    u:applySnapshot(snap)
    example_print_log("entities after apply = " .. u:getEntityCount())
end

--@api: LUniverse:takeSnapshotDiff
do
    local u = lurek.ecs.newUniverse()
    local e = u:spawn()
    u:set(e, "pos", { x = 1, y = 2 })
    local diff = u:takeSnapshotDiff()
    example_print_log("dirty entities = " .. tostring(#diff.dirty_entities))
end

--@api: LUniverse:clear
do
    local u = lurek.ecs.newUniverse()
    local entity = u:spawn()
    u:set(entity, "hp", 10)
    local before = u:getEntityCount()
    u:clear()
    local after = u:getEntityCount()
    local alive = u:isAlive(entity)
    ecs_log("clear world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
end

--@api: LUniverse:release
do
    local u = lurek.ecs.newUniverse()
    local entity = u:spawn()
    u:set(entity, "name", "temp")
    local before = u:getEntityCount()
    u:release()
    local after = u:getEntityCount()
    local alive = u:isAlive(entity)
    ecs_log("release world before=" .. tostring(before) .. " after=" .. tostring(after) .. " old_entity_alive=" .. tostring(alive))
end
