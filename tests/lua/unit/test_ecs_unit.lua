-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_ecs_unit.lua
do
-- tests/lua/unit/test_ecs_unit.lua
-- Canonical unit coverage for lurek.ecs and LUniverse.

local function new_world()
    return lurek.ecs.newUniverse()
end

local function contains_id(ids, target)
    for _, id in ipairs(ids) do
        if id == target then
            return true
        end
    end
    return false
end

local function define_enemy_blueprint(world)
    world:defineBlueprint("enemy", {
        hp = 30,
        speed = 5,
        pos = { x = 1, y = 2 },
    })
end

-- @describe lurek.ecs functions
describe("lurek.ecs functions", function()
    -- @covers lurek.ecs.newUniverse
    it("newUniverse creates a universe userdata", function()
        local world = new_world()
        expect_equal("LUniverse", world:type())
    end)

    -- @covers lurek.ecs.newRelationshipManager
    it("newRelationshipManager creates a relationship manager userdata", function()
        local rm = lurek.ecs.newRelationshipManager()
        expect_equal("LRelationshipManager", rm:type())
    end)

    -- @covers LRelationshipManager:type
    it("relationship manager type returns the userdata name", function()
        local rm = lurek.ecs.newRelationshipManager()
        expect_equal("LRelationshipManager", rm:type())
    end)

    -- @covers LRelationshipManager:typeOf
    it("relationship manager typeOf accepts its type name", function()
        local rm = lurek.ecs.newRelationshipManager()
        expect_true(rm:typeOf("LRelationshipManager"))
    end)
end)

-- @describe LUniverse lifecycle and metadata
describe("LUniverse lifecycle and metadata", function()
    -- @covers LUniverse:spawn
    it("spawn returns sequential entity ids", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        expect_equal(1, a)
        expect_equal(2, b)
    end)

    -- @covers LUniverse:isAlive
    it("isAlive reports whether an entity is still live", function()
        local world = new_world()
        local entity = world:spawn()
        expect_true(world:isAlive(entity))
        world:kill(entity)
        expect_false(world:isAlive(entity))
    end)

    -- @covers LUniverse:kill
    it("kill removes an entity from the live set", function()
        local world = new_world()
        local entity = world:spawn()
        local other = world:spawn()
        world:addRelation(other, "owns", entity)
        world:kill(entity)
        expect_false(contains_id(world:getEntities(), entity))
        expect_equal(0, #world:getRelated(other, "owns"))
    end)

    -- @covers LUniverse:getEntityCount
    it("getEntityCount tracks live entity totals", function()
        local world = new_world()
        local a = world:spawn()
        world:spawn()
        expect_equal(2, world:getEntityCount())
        world:kill(a)
        expect_equal(1, world:getEntityCount())
    end)

    -- @covers LUniverse:getEntities
    it("getEntities returns only live entity ids", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:kill(a)
        local ids = world:getEntities()
        expect_false(contains_id(ids, a))
        expect_true(contains_id(ids, b))
    end)

    -- @covers LUniverse:clear
    it("clear removes entities but keeps blueprints", function()
        local world = new_world()
        world:spawn()
        define_enemy_blueprint(world)
        world:clear()
        expect_equal(0, world:getEntityCount())
        expect_true(world:hasBlueprint("enemy"))
    end)

    -- @covers LUniverse:release
    it("release clears world contents", function()
        local world = new_world()
        world:spawn()
        world:release()
        expect_equal(0, world:getEntityCount())
    end)

    -- @covers LUniverse:type
    it("type returns the universe userdata name", function()
        local world = new_world()
        expect_equal("LUniverse", world:type())
    end)

    -- @covers LUniverse:typeOf
    it("typeOf accepts the universe type name", function()
        local world = new_world()
        expect_true(world:typeOf("LUniverse"))
    end)
end)

-- @describe LUniverse components
describe("LUniverse components", function()
    -- @covers LUniverse:set
    it("set stores component values on an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 100)
        expect_equal(100, world:get(entity, "hp"))
    end)

    -- @covers LUniverse:get
    it("get returns a stored component value", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "name", "hero")
        expect_equal("hero", world:get(entity, "name"))
    end)

    -- @covers LUniverse:has
    it("has reports component presence", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 10)
        expect_true(world:has(entity, "hp"))
        expect_false(world:has(entity, "mp"))
    end)

    -- @covers LUniverse:remove
    it("remove deletes a component from an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 10)
        world:remove(entity, "hp")
        expect_nil(world:get(entity, "hp"))
    end)

    -- @covers LUniverse:getComponents
    it("getComponents returns a table of current components", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "name", "hero")
        world:set(entity, "hp", 50)
        local components = world:getComponents(entity)
        expect_type("table", components)
        expect_equal(2, #components)
        expect_equal("hp", components[1])
        expect_equal("name", components[2])
    end)
end)

-- @describe LUniverse querying
describe("LUniverse querying", function()
    -- @covers LUniverse:query
    it("query returns entities that have all named components", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:set(a, "pos", { x = 0, y = 0 })
        world:set(a, "vel", { x = 1, y = 0 })
        world:set(b, "pos", { x = 5, y = 5 })
        local ids = world:query("pos", "vel")
        expect_equal(1, #ids)
        expect_equal(a, ids[1])
    end)

    -- @covers LUniverse:getQueryChangeTick
    it("getQueryChangeTick advances after selection-affecting mutations", function()
        local world = new_world()
        expect_equal(0, world:getQueryChangeTick())

        local entity = world:spawn()
        local after_spawn = world:getQueryChangeTick()
        expect_true(after_spawn > 0)

        world:set(entity, "pos", { x = 1, y = 2 })
        local after_set = world:getQueryChangeTick()
        expect_true(after_set > after_spawn)

        world:remove(entity, "pos")
        local after_remove = world:getQueryChangeTick()
        expect_true(after_remove > after_set)
    end)

    -- @covers LUniverse:newQueryView
    it("newQueryView creates a cached query view bound to the world", function()
        local world = new_world()
        local view = world:newQueryView({ "pos" })
        expect_equal("LQueryView", view:type())
    end)

    -- @covers LQueryView:type
    it("query views report their Lua-visible type name", function()
        local world = new_world()
        local view = world:newQueryView({ "pos" })
        expect_equal("LQueryView", view:type())
    end)

    -- @covers LQueryView:typeOf
    it("query views support typeOf checks", function()
        local world = new_world()
        local view = world:newQueryView({ "pos" })
        expect_true(view:typeOf("LQueryView"))
        expect_true(view:typeOf("LObject"))
        expect_equal(false, view:typeOf("LUniverse"))
    end)

    -- @covers LQueryView:ids
    it("query view ids refresh when the world query tick changes", function()
        local world = new_world()
        local first = world:spawn()
        world:set(first, "pos", { x = 0, y = 0 })
        local view = world:newQueryView({ "pos" })

        local ids = view:ids()
        expect_equal(1, #ids)
        expect_equal(first, ids[1])

        local second = world:spawn()
        world:set(second, "pos", { x = 2, y = 3 })
        ids = view:ids()
        expect_equal(2, #ids)
        expect_equal(first, ids[1])
        expect_equal(second, ids[2])
    end)

    -- @covers LQueryView:lastTick
    it("query view lastTick tracks the world tick used to build cached ids", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "pos", { x = 0, y = 0 })
        local view = world:newQueryView({ "pos" })

        local ids = view:ids()
        expect_equal(1, #ids)
        expect_equal(world:getQueryChangeTick(), view:lastTick())

        world:remove(entity, "pos")
        expect_equal(world:getQueryChangeTick(), view:lastTick())
    end)

    -- @covers LUniverse:each
    it("each invokes a callback for every matching entity", function()
        local world = new_world()
        local a = world:spawn()
        world:set(a, "pos", { x = 0, y = 0 })
        world:spawn()
        local count = 0
        world:each("pos", function(id, value)
            count = count + 1
            expect_equal(a, id)
            expect_type("table", value)
        end)
        expect_equal(1, count)
    end)

    -- @covers LUniverse:queryMulti
    it("queryMulti passes multiple component values to the callback", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "pos", { x = 1, y = 2 })
        world:set(entity, "vel", { x = 3, y = 4 })
        local seen = 0
        local sum = 0
        world:queryMulti({ "pos", "vel" }, function(id, pos, vel)
            seen = seen + 1
            expect_equal(entity, id)
            sum = pos.x + vel.x
        end)
        expect_equal(1, seen)
        expect_equal(4, sum)
    end)

    -- @covers LUniverse:queryNot
    it("queryNot excludes entities with forbidden components", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:set(a, "Health", 10)
        world:set(b, "Health", 10)
        world:set(b, "Dead", true)
        local ids = world:queryNot({ "Health" }, { "Dead" })
        expect_equal(1, #ids)
        expect_equal(a, ids[1])
    end)

    -- @covers LUniverse:getDirtyEntities
    it("getDirtyEntities reports recently mutated entities", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 5)
        local dirty = world:getDirtyEntities()
        expect_equal(1, #dirty)
        expect_equal(entity, dirty[1])
    end)
end)

-- @describe LUniverse observers
describe("LUniverse observers", function()
    -- @covers LUniverse:flushObservers
    it("flushObservers delivers queued observer events", function()
        local world = new_world()
        local fired = 0
        world:onComponentAdded("hp", function()
            fired = fired + 1
        end)
        local entity = world:spawn()
        world:set(entity, "hp", 10)
        expect_equal(0, fired)
        world:flushObservers()
        expect_equal(1, fired)
    end)

    -- @covers LUniverse:onComponentAdded
    it("onComponentAdded registers add observers", function()
        local world = new_world()
        local seen_id = nil
        local seen_name = nil
        world:onComponentAdded("hp", function(id, name)
            seen_id = id
            seen_name = name
        end)
        local entity = world:spawn()
        world:set(entity, "hp", 20)
        world:flushObservers()
        expect_equal(entity, seen_id)
        expect_equal("hp", seen_name)
    end)

    -- @covers LUniverse:onComponentRemoved
    it("onComponentRemoved registers remove observers", function()
        local world = new_world()
        local seen_id = nil
        local seen_name = nil
        world:onComponentRemoved("hp", function(id, name)
            seen_id = id
            seen_name = name
        end)
        local entity = world:spawn()
        world:set(entity, "hp", 20)
        world:flushObservers()
        world:remove(entity, "hp")
        world:flushObservers()
        expect_equal(entity, seen_id)
        expect_equal("hp", seen_name)
    end)
end)

-- @describe LUniverse string tags
describe("LUniverse string tags", function()
    -- @covers LUniverse:addTag
    it("addTag assigns a string tag to an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:addTag(entity, "player")
        expect_true(world:hasTag(entity, "player"))
    end)

    -- @covers LUniverse:removeTag
    it("removeTag deletes a string tag from an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:addTag(entity, "player")
        world:removeTag(entity, "player")
        expect_false(world:hasTag(entity, "player"))
    end)

    -- @covers LUniverse:hasTag
    it("hasTag reports tag membership", function()
        local world = new_world()
        local entity = world:spawn()
        world:addTag(entity, "enemy")
        expect_true(world:hasTag(entity, "enemy"))
        expect_false(world:hasTag(entity, "ally"))
    end)

    -- @covers LUniverse:getTags
    it("getTags returns every string tag attached to an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:addTag(entity, "enemy")
        world:addTag(entity, "active")
        local tags = world:getTags(entity)
        expect_equal(2, #tags)
    end)

    -- @covers LUniverse:getEntitiesByTag
    it("getEntitiesByTag returns entities with a specific tag", function()
        local world = new_world()
        local entity = world:spawn()
        world:addTag(entity, "enemy")
        local ids = world:getEntitiesByTag("enemy")
        expect_equal(1, #ids)
        expect_equal(entity, ids[1])
    end)
end)

-- @describe LUniverse bitmap tags
describe("LUniverse bitmap tags", function()
    -- @covers LUniverse:defineTag
    it("defineTag returns a numeric bitmap tag bit", function()
        local world = new_world()
        expect_type("number", world:defineTag("fast"))
    end)

    -- @covers LUniverse:bitmapTag
    it("bitmapTag assigns a bitmap tag to an entity", function()
        local world = new_world()
        local entity = world:spawn()
        world:bitmapTag(entity, "fast")
        expect_true(world:hasBitmapTag(entity, "fast"))
    end)

    -- @covers LUniverse:bitmapUntag
    it("bitmapUntag removes an assigned bitmap tag", function()
        local world = new_world()
        local entity = world:spawn()
        world:bitmapTag(entity, "fast")
        world:bitmapUntag(entity, "fast")
        expect_false(world:hasBitmapTag(entity, "fast"))
    end)

    -- @covers LUniverse:hasBitmapTag
    it("hasBitmapTag reports bitmap tag membership", function()
        local world = new_world()
        local entity = world:spawn()
        world:bitmapTag(entity, "strong")
        expect_true(world:hasBitmapTag(entity, "strong"))
        expect_false(world:hasBitmapTag(entity, "fast"))
    end)

    -- @covers LUniverse:queryBitmapTag
    it("queryBitmapTag returns entities with one bitmap tag", function()
        local world = new_world()
        local entity = world:spawn()
        world:bitmapTag(entity, "fast")
        local ids = world:queryBitmapTag("fast")
        expect_equal(1, #ids)
        expect_equal(entity, ids[1])
    end)

    -- @covers LUniverse:queryBitmapAll
    it("queryBitmapAll returns entities that have every requested tag", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:bitmapTag(a, "fast")
        world:bitmapTag(a, "strong")
        world:bitmapTag(b, "fast")
        local ids = world:queryBitmapAll({ "fast", "strong" })
        expect_equal(1, #ids)
        expect_equal(a, ids[1])
    end)

    -- @covers LUniverse:queryBitmapAny
    it("queryBitmapAny returns entities that have any requested tag", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:bitmapTag(a, "fast")
        world:bitmapTag(b, "strong")
        local ids = world:queryBitmapAny({ "fast", "strong" })
        expect_equal(2, #ids)
    end)

    -- @covers LUniverse:getBitmapTagBit
    it("getBitmapTagBit returns the bit assigned to a tag name", function()
        local world = new_world()
        local bit = world:defineTag("enemy")
        expect_equal(bit, world:getBitmapTagBit("enemy"))
    end)
end)

-- @describe LUniverse layers
describe("LUniverse layers", function()
    -- @covers LUniverse:setLayer
    it("setLayer stores an entity layer number", function()
        local world = new_world()
        local entity = world:spawn()
        world:setLayer(entity, 3)
        expect_equal(3, world:getLayer(entity))
    end)

    -- @covers LUniverse:getLayer
    it("getLayer returns zero for a fresh entity", function()
        local world = new_world()
        local entity = world:spawn()
        expect_equal(0, world:getLayer(entity))
    end)

    -- @covers LUniverse:getEntitiesByLayer
    it("getEntitiesByLayer returns entities assigned to a specific layer", function()
        local world = new_world()
        local entity = world:spawn()
        world:setLayer(entity, 2)
        local ids = world:getEntitiesByLayer(2)
        expect_equal(1, #ids)
        expect_equal(entity, ids[1])
    end)

    -- @covers LUniverse:getEntitiesSorted
    it("getEntitiesSorted orders entities by ascending layer", function()
        local world = new_world()
        local high = world:spawn()
        local low = world:spawn()
        world:setLayer(high, 5)
        world:setLayer(low, 1)
        local ids = world:getEntitiesSorted()
        expect_equal(low, ids[1])
        expect_equal(high, ids[#ids])
    end)
end)

-- @describe LUniverse blueprints
describe("LUniverse blueprints", function()
    -- @covers LUniverse:defineBlueprint
    it("defineBlueprint registers blueprint component data", function()
        local world = new_world()
        define_enemy_blueprint(world)
        expect_not_nil(world:getBlueprintComponents("enemy"))
    end)

    -- @covers LUniverse:hasBlueprint
    it("hasBlueprint reports whether a blueprint exists", function()
        local world = new_world()
        define_enemy_blueprint(world)
        expect_true(world:hasBlueprint("enemy"))
        expect_false(world:hasBlueprint("boss"))
    end)

    -- @covers LUniverse:spawnBlueprint
    it("spawnBlueprint creates an entity from blueprint data", function()
        local world = new_world()
        define_enemy_blueprint(world)
        local entity = world:spawnBlueprint("enemy")
        expect_equal(30, world:get(entity, "hp"))
        expect_equal(5, world:get(entity, "speed"))
    end)

    -- @covers LUniverse:extendBlueprint
    it("extendBlueprint inherits and overrides parent blueprint data", function()
        local world = new_world()
        define_enemy_blueprint(world)
        world:extendBlueprint("boss", "enemy", { hp = 200, boss = true })
        local entity = world:spawnBlueprint("boss")
        expect_equal(200, world:get(entity, "hp"))
        expect_equal(true, world:get(entity, "boss"))
    end)

    -- @covers LUniverse:removeBlueprint
    it("removeBlueprint deletes a registered blueprint", function()
        local world = new_world()
        define_enemy_blueprint(world)
        world:removeBlueprint("enemy")
        expect_false(world:hasBlueprint("enemy"))
    end)

    -- @covers LUniverse:listBlueprints
    it("listBlueprints returns registered blueprint names", function()
        local world = new_world()
        world:defineBlueprint("bullet", { speed = 50 })
        define_enemy_blueprint(world)
        local names = world:listBlueprints()
        expect_equal("bullet", names[1])
        expect_equal("enemy", names[2])
    end)

    -- @covers LUniverse:getBlueprintComponents
    it("getBlueprintComponents returns blueprint component tables", function()
        local world = new_world()
        define_enemy_blueprint(world)
        local components = world:getBlueprintComponents("enemy")
        expect_equal(30, components.hp)
        expect_equal(5, components.speed)
    end)

    -- @covers LUniverse:spawnBulk
    it("spawnBulk returns ids for entities spawned from one blueprint", function()
        local world = new_world()
        world:defineBlueprint("bullet", { pos = { x = 0, y = 0 } })
        local ids = world:spawnBulk("bullet", 3)
        expect_equal(3, #ids)
        expect_true(world:isAlive(ids[1]))
    end)
end)

-- @describe LUniverse systems
describe("LUniverse systems", function()
    -- @covers LUniverse:addSystem
    it("addSystem registers a system that update can execute", function()
        local world = new_world()
        local ran = false
        local sys = { update = function() ran = true end }
        world:addSystem(sys)
        world:update(0.016)
        expect_true(ran)
    end)

    -- @covers LUniverse:getSystemCount
    it("getSystemCount reports the number of registered systems", function()
        local world = new_world()
        world:addSystem({ update = function() end })
        world:addSystem({ update = function() end })
        expect_equal(2, world:getSystemCount())
    end)

    -- @covers LUniverse:update
    it("update runs update-phase systems", function()
        local world = new_world()
        local count = 0
        world:addSystem({ update = function() count = count + 1 end })
        world:update(0.016)
        expect_equal(1, count)
    end)

    -- @covers LUniverse:emit
    it("emit dispatches named events to systems", function()
        local world = new_world()
        local payload = 0
        world:addSystem({
            onHit = function(self, w, damage)
                payload = damage
            end,
        })
        world:emit("onHit", 42)
        expect_equal(42, payload)
    end)

    -- @covers LUniverse:removeSystem
    it("removeSystem unregisters a system by reference", function()
        local world = new_world()
        local a = { update = function() end }
        local b = { update = function() end }
        world:addSystem(a)
        world:addSystem(b)
        world:removeSystem(a)
        expect_equal(1, world:getSystemCount())
    end)

    -- @covers LUniverse:updatePhase
    it("updatePhase runs only systems assigned to a named phase", function()
        local world = new_world()
        local order = {}
        world:addSystem({ update = function() table.insert(order, "pre") end }, { phase = "pre_update" })
        world:addSystem({ update = function() table.insert(order, "tick") end }, { phase = "update" })
        world:addSystem({ update = function() table.insert(order, "post") end }, { phase = "post_update" })
        world:updatePhase("pre_update", 0.016)
        world:updatePhase("update", 0.016)
        world:updatePhase("post_update", 0.016)
        expect_equal("pre", order[1])
        expect_equal("tick", order[2])
        expect_equal("post", order[3])
    end)

    -- @covers LUniverse:render
    it("render dispatches render methods on systems", function()
        local world = new_world()
        local count = 0
        world:addSystem({
            render = function()
                count = count + 1
            end,
        })
        world:render()
        expect_equal(1, count)
    end)
end)

-- @describe LUniverse hierarchy
describe("LUniverse hierarchy", function()
    -- @covers LUniverse:setParent
    it("setParent attaches a child to a parent entity", function()
        local world = new_world()
        local parent = world:spawn()
        local child = world:spawn()
        world:setParent(child, parent)
        expect_equal(parent, world:getParent(child))
        expect_error(function()
            world:setParent(parent, parent)
        end)
        expect_error(function()
            world:setParent(parent, child)
        end)
    end)

    -- @covers LUniverse:getParent
    it("getParent returns nil when no parent is assigned", function()
        local world = new_world()
        local entity = world:spawn()
        expect_nil(world:getParent(entity))
    end)

    -- @covers LUniverse:getChildren
    it("getChildren returns child ids for a parent entity", function()
        local world = new_world()
        local parent = world:spawn()
        local child = world:spawn()
        world:setParent(child, parent)
        local children = world:getChildren(parent)
        expect_equal(1, #children)
        expect_equal(child, children[1])
    end)

    -- @covers LUniverse:killRecursive
    it("killRecursive removes a parent and all descendants", function()
        local world = new_world()
        local parent = world:spawn()
        local child = world:spawn()
        world:setParent(child, parent)
        world:killRecursive(parent)
        expect_false(world:isAlive(parent))
        expect_false(world:isAlive(child))
    end)
end)

-- @describe LUniverse relations
describe("LUniverse relations", function()
    -- @covers LUniverse:addRelation
    it("addRelation creates a directed relation between entities", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:addRelation(a, "owns", b)
        expect_equal(1, #world:getRelated(a, "owns"))
    end)

    -- @covers LUniverse:getRelated
    it("getRelated returns linked target ids for one relation name", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:addRelation(a, "friend", b)
        local related = world:getRelated(a, "friend")
        expect_equal(1, #related)
        expect_equal(b, related[1])
    end)

    -- @covers LUniverse:hasRelation
    it("hasRelation reports whether a named link exists", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:addRelation(a, "enemy", b)
        expect_true(world:hasRelation(a, "enemy", b))
        expect_false(world:hasRelation(b, "enemy", a))
    end)

    -- @covers LUniverse:removeRelation
    it("removeRelation deletes one directed relation", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        world:addRelation(a, "ally", b)
        world:removeRelation(a, "ally", b)
        expect_false(world:hasRelation(a, "ally", b))
    end)

    -- @covers LUniverse:clearRelations
    it("clearRelations removes every target for one relation name", function()
        local world = new_world()
        local a = world:spawn()
        local b = world:spawn()
        local c = world:spawn()
        world:addRelation(a, "sees", b)
        world:addRelation(a, "sees", c)
        world:clearRelations(a, "sees")
        expect_equal(0, #world:getRelated(a, "sees"))
    end)
end)

-- @describe LUniverse snapshots
describe("LUniverse snapshots", function()
    -- @covers LUniverse:serialize
    it("serialize returns a table with entity and bitmap tag state", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "name", "hero")
        local snapshot = world:serialize()
        expect_type("table", snapshot)
        expect_type("table", snapshot.entities)
        expect_type("table", snapshot.bitmap_tags)
    end)

    -- @covers LUniverse:deserialize
    it("deserialize restores serialized world state", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 42)
        world:addTag(entity, "enemy")
        local snapshot = world:serialize()
        world:clear()
        world:deserialize(snapshot)
        local ids = world:getEntities()
        expect_equal(1, #ids)
        expect_equal(42, world:get(ids[1], "hp"))
        expect_true(world:hasTag(ids[1], "enemy"))
    end)

    -- @covers LUniverse:snapshot
    it("snapshot returns a Lua table snapshot of the current world", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "score", 99)
        local snapshot = world:snapshot()
        expect_type("table", snapshot)
        expect_true(#snapshot.entities >= 1)
    end)

    -- @covers LUniverse:applySnapshot
    it("applySnapshot restores state from a snapshot table", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "pos", { x = 1, y = 2 })
        local snapshot = world:snapshot()
        world:clear()
        world:applySnapshot(snapshot)
        local ids = world:getEntities()
        expect_equal(1, #ids)
        expect_type("table", world:get(ids[1], "pos"))
    end)

    -- @covers LUniverse:takeSnapshotDiff
    it("takeSnapshotDiff returns dirty data and drains it on the next call", function()
        local world = new_world()
        local entity = world:spawn()
        world:set(entity, "hp", 10)
        world:remove(entity, "hp")
        local diff = world:takeSnapshotDiff()
        expect_true(#diff.added_components >= 1)
        expect_true(#diff.removed_components >= 1)
        expect_true(#diff.dirty_entities >= 1)
        local drained = world:takeSnapshotDiff()
        expect_equal(0, #drained.added_components)
        expect_equal(0, #drained.removed_components)
        expect_equal(0, #drained.dirty_entities)
    end)
end)

-- @describe LUniverse ChangeSet bridge
describe("LUniverse ChangeSet bridge", function()
    -- @covers LUniverse:applyChangeSet
    it("applyChangeSet validates and applies explicit component operations", function()
        local world = new_world()
        local entity = world:spawn()
        local victim = world:spawn()
        world:set(entity, "stale", true)
        local changes = lurek.event.newChangeSet({ schema = "ecs", revision = 3 })
        changes:append(entity, "hp", "set", 42)
        changes:append(entity, "stale", "remove", true)
        changes:append(victim, "body", "kill", true)
        expect_equal(3, world:applyChangeSet(changes:toTable()))
        expect_equal(42, world:get(entity, "hp"))
        expect_false(world:has(entity, "stale"))
        expect_false(world:isAlive(victim))
    end)
end)

-- @describe ECS class and object registry
describe("ECS class and object registry", function()
    -- @covers lurek.ecs.defineClass
    it("defineClass supports inheritance, defaults, methods, properties, and constructors", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("GameObject", {
            defaults = { alive = true, hp = 1 },
            methods = {
                label = function(self)
                    return self.name .. ":" .. tostring(self.hp)
                end,
            },
            properties = { speed = 4 },
            constructor = function(self, props)
                self.constructed = props and props.name or "unnamed"
            end,
            tags = { "base" },
        })
        lurek.ecs.defineClass("Projectile", {
            extends = "GameObject",
            defaults = { damage = 2 },
            properties = { speed = 8 },
            tags = { "projectile" },
        })
        local obj = lurek.ecs.newObject("Projectile", { name = "bolt", hp = 5 })
        expect_equal("bolt:5", obj:label())
        expect_equal(8, obj:getProperty("speed"))
        expect_equal("bolt", obj.constructed)
        expect_true(obj:isA("GameObject"))
    end)

    -- @covers lurek.ecs.hasClass
    it("hasClass reports registered classes", function()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("RegistryProbe", {})
        expect_true(lurek.ecs.hasClass("RegistryProbe"))
        expect_false(lurek.ecs.hasClass("MissingClass"))
    end)

    -- @covers lurek.ecs.getClass
    it("getClass returns class metadata", function()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("TaggedClass", { tags = { "enemy", "flying" } })
        local meta = lurek.ecs.getClass("TaggedClass")
        expect_equal("TaggedClass", meta.name)
        expect_equal("enemy", meta.tags[1])
        expect_nil(lurek.ecs.getClass("NoSuchClass"))
    end)

    -- @covers lurek.ecs.classNames
    it("classNames lists registered class names", function()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("ClassA", {})
        lurek.ecs.defineClass("ClassB", {})
        local names = lurek.ecs.classNames()
        expect_equal("ClassA", names[1])
        expect_equal("ClassB", names[2])
    end)

    -- @covers lurek.ecs.clearClasses
    it("clearClasses removes class metadata", function()
        lurek.ecs.defineClass("TemporaryClass", {})
        lurek.ecs.clearClasses()
        expect_false(lurek.ecs.hasClass("TemporaryClass"))
    end)

    -- @covers lurek.ecs.newObject
    it("newObject creates typed objects with property helpers", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("ObjectProbe", { properties = { hp = 10 } })
        local obj = lurek.ecs.newObject("ObjectProbe")
        obj:setProperty("hp", 12)
        expect_equal("ObjectProbe", obj:type())
        expect_true(obj:typeOf("ObjectProbe"))
        expect_equal(12, obj:getProperty("hp"))
    end)

    -- @covers lurek.ecs.type
    it("object type returns its class name", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("TypedObject", {})
        local obj = lurek.ecs.newObject("TypedObject")
        expect_equal("TypedObject", obj:type())
    end)

    -- @covers lurek.ecs.typeOf
    it("object typeOf accepts inherited class names", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("BaseObject", {})
        lurek.ecs.defineClass("DerivedObject", { extends = "BaseObject" })
        local obj = lurek.ecs.newObject("DerivedObject")
        expect_true(obj:typeOf("BaseObject"))
    end)

    -- @covers lurek.ecs.isA
    it("object isA accepts inherited class names", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("ActorObject", {})
        lurek.ecs.defineClass("EnemyObject", { extends = "ActorObject" })
        local obj = lurek.ecs.newObject("EnemyObject")
        expect_true(obj:isA("ActorObject"))
    end)

    -- @covers lurek.ecs.getProperty
    it("object getProperty returns current property state", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("PropertyReadObject", { properties = { hp = 10 } })
        local obj = lurek.ecs.newObject("PropertyReadObject")
        expect_equal(10, obj:getProperty("hp"))
    end)

    -- @covers lurek.ecs.setProperty
    it("object setProperty updates property state", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("PropertyWriteObject", { properties = { hp = 10 } })
        local obj = lurek.ecs.newObject("PropertyWriteObject")
        obj:setProperty("hp", 4)
        expect_equal(4, obj:getProperty("hp"))
    end)

    -- @covers lurek.ecs.getObject
    it("getObject retrieves registered objects by id", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("LookupObject", {})
        local obj = lurek.ecs.newObject("LookupObject")
        expect_equal(obj, lurek.ecs.getObject(obj.__id))
    end)

    -- @covers lurek.ecs.hasObject
    it("hasObject reports live object ids", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("LiveObject", {})
        local obj = lurek.ecs.newObject("LiveObject")
        expect_true(lurek.ecs.hasObject(obj.__id))
        expect_false(lurek.ecs.hasObject(obj.__id + 100))
    end)

    -- @covers lurek.ecs.objectIds
    it("objectIds lists live object ids", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("ListedObject", {})
        local obj = lurek.ecs.newObject("ListedObject")
        local ids = lurek.ecs.objectIds()
        expect_equal(obj.__id, ids[1])
    end)

    -- @covers lurek.ecs.destroyObject
    it("destroyObject removes one object", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("DestroyObject", {})
        local obj = lurek.ecs.newObject("DestroyObject")
        expect_true(lurek.ecs.destroyObject(obj.__id))
        expect_false(lurek.ecs.hasObject(obj.__id))
    end)

    -- @covers lurek.ecs.clearObjects
    it("clearObjects removes all objects", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("ClearObject", {})
        lurek.ecs.newObject("ClearObject")
        lurek.ecs.clearObjects()
        expect_equal(0, #lurek.ecs.objectIds())
    end)

    -- @covers LUniverse:spawnObject
    it("spawnObject creates an entity with object components", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("WorldObject", { defaults = { hp = 3 } })
        local world = new_world()
        local entity = world:spawnObject("WorldObject", { hp = 9 })
        expect_equal("WorldObject", world:get(entity, "objectClass"))
        expect_equal(9, world:get(entity, "object").hp)
    end)

    -- @covers LUniverse:attachObject
    it("attachObject links an existing object to an entity", function()
        lurek.ecs.clearObjects()
        lurek.ecs.clearClasses()
        lurek.ecs.defineClass("AttachedObject", {})
        local obj = lurek.ecs.newObject("AttachedObject")
        local world = new_world()
        local entity = world:spawn()
        world:attachObject(entity, obj)
        expect_equal(obj.__id, world:get(entity, "objectId"))
        expect_equal(obj, world:get(entity, "object"))
    end)
end)
end
-- END test_ecs_core_unit.lua

test_summary()
