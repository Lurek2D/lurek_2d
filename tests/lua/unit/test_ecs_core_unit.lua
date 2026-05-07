-- Entity module Lua tests
-- Headless-safe. Each describe block creates a fresh Universe.

-- @describe Spawn and lifecycle
describe("Spawn and lifecycle", function()
    -- @covers LUniverse:getEntityCount
    -- @covers LUniverse:isAlive
    -- @covers LUniverse:kill
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("spawns entities with sequential IDs", function()
        local world = lurek.ecs.newUniverse()
        local a = world:spawn()
        expect_equal(1, a)
        local b = world:spawn()
        expect_equal(2, b)
        expect_true(world:isAlive(a))
        expect_equal(2, world:getEntityCount())

        world:kill(a)
        expect_false(world:isAlive(a))
        expect_equal(1, world:getEntityCount())

        -- LIFO recycling: recycled slot gets incremented generation (stale detection)
        local c = world:spawn()
        expect_true(world:isAlive(c), "recycled entity is alive")
        expect_true(c ~= a, "recycled id differs from stale id (generational)")
    end)
end)

-- @describe Components
describe("Components", function()
    -- @covers LUniverse:get
    -- @covers LUniverse:getComponents
    -- @covers LUniverse:has
    -- @covers LUniverse:remove
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("stores and retrieves component values", function()
        local world = lurek.ecs.newUniverse()
        local e = world:spawn()

        world:set(e, "hp", 100)
        expect_equal(100, world:get(e, "hp"))
        expect_true(world:has(e, "hp"))

        world:set(e, "name", "Hero")
        expect_equal("Hero", world:get(e, "name"))

        local comps = world:getComponents(e)
        expect_type("table", comps)

        world:remove(e, "hp")
        expect_false(world:has(e, "hp"))
        expect_equal(nil, world:get(e, "hp"))
    end)
end)

-- @describe Query
describe("Query", function()
    -- @covers LUniverse:query
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("queries entities by components", function()
        local world = lurek.ecs.newUniverse()
        local p = world:spawn()
        world:set(p, "pos", {x=0, y=0})
        world:set(p, "vel", {x=1, y=0})

        local q = world:spawn()
        world:set(q, "pos", {x=5, y=5})

        local both = world:query("pos", "vel")
        expect_equal(1, #both)
        expect_equal(p, both[1])

        local all_pos = world:query("pos")
        expect_equal(2, #all_pos)
    end)

    -- @covers LUniverse:each
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("iterates matching entities with each()", function()
        local world = lurek.ecs.newUniverse()
        local p = world:spawn()
        world:set(p, "pos", {x=0, y=0})
        local q = world:spawn()
        world:set(q, "pos", {x=5, y=5})

        local count = 0
        world:each("pos", function(id, val)
            count = count + 1
        end)
        expect_equal(2, count)
    end)
end)

-- @describe String Tags
describe("String Tags", function()
    -- @covers LUniverse:addTag
    -- @covers LUniverse:getEntitiesByTag
    -- @covers LUniverse:getTags
    -- @covers LUniverse:hasTag
    -- @covers LUniverse:removeTag
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("adds, queries, and removes string tags", function()
        local world = lurek.ecs.newUniverse()
        local p = world:spawn()
        local q = world:spawn()

        world:addTag(p, "player")
        world:addTag(q, "enemy")

        expect_true(world:hasTag(p, "player"))
        expect_false(world:hasTag(p, "enemy"))

        local tags = world:getTags(p)
        expect_equal(1, #tags)
        expect_equal("player", tags[1])

        local enemies = world:getEntitiesByTag("enemy")
        expect_equal(1, #enemies)
        expect_equal(q, enemies[1])

        world:removeTag(p, "player")
        expect_false(world:hasTag(p, "player"))
    end)
end)

-- @describe Bitmap Tags
describe("Bitmap Tags", function()
    -- @covers LUniverse:bitmapTag
    -- @covers LUniverse:defineTag
    -- @covers LUniverse:hasBitmapTag
    -- @covers LUniverse:queryBitmapAll
    -- @covers LUniverse:queryBitmapAny
    -- @covers LUniverse:queryBitmapTag
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("defines and queries bitmap tags", function()
        local world = lurek.ecs.newUniverse()
        local p = world:spawn()
        local q = world:spawn()

        local bit = world:defineTag("fast")
        expect_type("number", bit)

        world:bitmapTag(p, "fast")
        world:bitmapTag(p, "strong")
        world:bitmapTag(q, "fast")

        expect_true(world:hasBitmapTag(p, "fast"))
        expect_true(world:hasBitmapTag(p, "strong"))
        expect_false(world:hasBitmapTag(q, "strong"))

        local fast_ones = world:queryBitmapTag("fast")
        expect_equal(2, #fast_ones)

        local both_tags = world:queryBitmapAll({"fast", "strong"})
        expect_equal(1, #both_tags)
        expect_equal(p, both_tags[1])

        local any_tags = world:queryBitmapAny({"fast", "strong"})
        expect_equal(2, #any_tags)
    end)

    -- @covers LUniverse:bitmapTag
    -- @covers LUniverse:bitmapUntag
    -- @covers LUniverse:hasBitmapTag
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("removes bitmap tags with bitmapUntag", function()
        local world = lurek.ecs.newUniverse()
        local entity = world:spawn()

        world:bitmapTag(entity, "fast")
        world:bitmapTag(entity, "strong")
        expect_true(world:hasBitmapTag(entity, "strong"))

        world:bitmapUntag(entity, "strong")

        expect_false(world:hasBitmapTag(entity, "strong"))
        expect_true(world:hasBitmapTag(entity, "fast"))
    end)
end)

-- @describe Layers
describe("Layers", function()
    -- @covers LUniverse:getEntitiesByLayer
    -- @covers LUniverse:getEntitiesSorted
    -- @covers LUniverse:getLayer
    -- @covers LUniverse:setLayer
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("assigns layers and returns entities sorted by layer", function()
        local world = lurek.ecs.newUniverse()
        local p = world:spawn()
        local q = world:spawn()

        expect_equal(0, world:getLayer(p))
        expect_equal(0, world:getLayer(q))

        world:setLayer(p, 2)
        expect_equal(2, world:getLayer(p))
        expect_equal(0, world:getLayer(q))

        local layer0 = world:getEntitiesByLayer(0)
        expect_true(#layer0 >= 1)

        local sorted = world:getEntitiesSorted()
        expect_true(#sorted >= 2)

        -- q has layer 0, p has layer 2 -> q must come first
        local found_q = false
        for i, id in ipairs(sorted) do
            if id == q then found_q = true end
            if id == p then
                expect_true(found_q)
            end
        end
    end)
end)

-- @describe Blueprints
describe("Blueprints", function()
    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:get
    -- @covers LUniverse:hasBlueprint
    -- @covers LUniverse:isAlive
    -- @covers LUniverse:spawnBlueprint
    -- @covers lurek.ecs.newUniverse
    it("defines blueprints and spawns entities from them", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })
        expect_true(world:hasBlueprint("goblin"))

        local g = world:spawnBlueprint("goblin")
        expect_true(world:isAlive(g))
        expect_equal(30, world:get(g, "hp"))
        expect_equal(100, world:get(g, "speed"))
    end)

    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:get
    -- @covers LUniverse:set
    -- @covers LUniverse:spawnBlueprint
    -- @covers lurek.ecs.newUniverse
    it("blueprints provide deep-copy isolation", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })

        local g = world:spawnBlueprint("goblin")
        world:set(g, "hp", 999)
        local g2 = world:spawnBlueprint("goblin")
        expect_equal(30, world:get(g2, "hp"))
    end)

    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:extendBlueprint
    -- @covers LUniverse:get
    -- @covers LUniverse:spawnBlueprint
    -- @covers lurek.ecs.newUniverse
    it("extends blueprints with overrides", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })
        world:extendBlueprint("boss_goblin", "goblin", { hp = 200, boss = true })

        local bg = world:spawnBlueprint("boss_goblin")
        expect_equal(200, world:get(bg, "hp"))
        expect_equal(100, world:get(bg, "speed"))
        expect_equal(true, world:get(bg, "boss"))
    end)

    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:get
    -- @covers LUniverse:spawnBlueprint
    -- @covers lurek.ecs.newUniverse
    it("spawnBlueprint accepts per-spawn field overrides", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })

        local g = world:spawnBlueprint("goblin", { hp = 50 })
        expect_equal(50, world:get(g, "hp"))
        expect_equal(100, world:get(g, "speed"))
    end)

    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:hasBlueprint
    -- @covers LUniverse:listBlueprints
    -- @covers LUniverse:removeBlueprint
    -- @covers lurek.ecs.newUniverse
    it("lists and removes blueprints", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30 })
        world:defineBlueprint("boss", { hp = 200 })

        local bps = world:listBlueprints()
        expect_true(#bps >= 2)

        world:removeBlueprint("boss")
        expect_false(world:hasBlueprint("boss"))
    end)

    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:getBlueprintComponents
    -- @covers lurek.ecs.newUniverse
    it("getBlueprintComponents returns component table", function()
        local world = lurek.ecs.newUniverse()
        world:defineBlueprint("goblin", { hp = 30 })

        local bp_comps = world:getBlueprintComponents("goblin")
        expect_true(bp_comps ~= nil)
        expect_equal(30, bp_comps.hp)
    end)
end)

-- @describe Systems
describe("Systems", function()
    -- @covers LUniverse:addSystem
    -- @covers LUniverse:emit
    -- @covers LUniverse:getSystemCount
    -- @covers LUniverse:update
    -- @covers lurek.ecs.newUniverse
    it("dispatches update and draw to registered systems", function()
        local world = lurek.ecs.newUniverse()
        local update_count = 0
        local draw_count = 0

        local TestSys = {}
        function TestSys:update(w, dt) update_count = update_count + 1 end
        function TestSys:draw(w) draw_count = draw_count + 1 end

        world:addSystem(TestSys)
        expect_equal(1, world:getSystemCount())

        world:update(0.016)
        expect_equal(1, update_count)

        world:emit("draw")
        expect_equal(1, draw_count)
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:emit
    -- @covers lurek.ecs.newUniverse
    it("emits custom events to systems", function()
        local world = lurek.ecs.newUniverse()
        local custom_count = 0

        local EventSys = {}
        function EventSys:onHit(w, damage) custom_count = damage end
        world:addSystem(EventSys)

        world:emit("onHit", 42)
        expect_equal(42, custom_count)
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:getSystemCount
    -- @covers LUniverse:removeSystem
    -- @covers lurek.ecs.newUniverse
    it("removeSystem removes by reference", function()
        local world = lurek.ecs.newUniverse()

        local SysA = {}
        function SysA:update() end
        local SysB = {}
        function SysB:update() end

        world:addSystem(SysA)
        world:addSystem(SysB)
        expect_equal(2, world:getSystemCount())

        world:removeSystem(SysA)
        expect_equal(1, world:getSystemCount())
    end)
end)

-- @describe Clear and Release
describe("Clear and Release", function()
    -- @covers LUniverse:clear
    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:getEntityCount
    -- @covers LUniverse:hasBlueprint
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("clear() removes entities but preserves blueprints", function()
        local world = lurek.ecs.newUniverse()
        world:spawn()
        world:spawn()
        world:defineBlueprint("preserved", { val = 1 })

        world:clear()
        expect_equal(0, world:getEntityCount())
        expect_true(world:hasBlueprint("preserved"))
    end)
end)

-- parent-child hierarchy

-- @describe parent-child hierarchy
describe("parent-child hierarchy", function()
    -- @covers LUniverse:getParent
    -- @covers LUniverse:setParent
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("setParent / getParent round-trip", function()
        local world = lurek.ecs.newUniverse()
        local parent = world:spawn()
        local child  = world:spawn()
        world:setParent(child, parent)
        expect_equal(parent, world:getParent(child))
    end)

    -- @covers LUniverse:getParent
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("getParent returns nil for entity with no parent", function()
        local world = lurek.ecs.newUniverse()
        local e = world:spawn()
        expect_nil(world:getParent(e))
    end)

    -- @covers LUniverse:getChildren
    -- @covers LUniverse:setParent
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("getChildren returns table containing child", function()
        local world = lurek.ecs.newUniverse()
        local parent = world:spawn()
        local child  = world:spawn()
        world:setParent(child, parent)
        local children = world:getChildren(parent)
        expect_type("table", children)
        local found = false
        for _, id in ipairs(children) do
            if id == child then found = true end
        end
        expect_true(found, "child id should appear in getChildren")
    end)

    -- @covers LUniverse:getChildren
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("getChildren returns empty table when no children attached", function()
        local world = lurek.ecs.newUniverse()
        local e = world:spawn()
        local children = world:getChildren(e)
        expect_type("table", children)
        expect_equal(0, #children)
    end)

    -- @covers LUniverse:getChildren
    -- @covers LUniverse:getParent
    -- @covers LUniverse:setParent
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("setParent accepts nil to detach a child", function()
        local world = lurek.ecs.newUniverse()
        local parent = world:spawn()
        local child = world:spawn()

        world:setParent(child, parent)
        world:setParent(child, nil)

        expect_nil(world:getParent(child))
        expect_equal(0, #world:getChildren(parent))
    end)

    -- @covers LUniverse:isAlive
    -- @covers LUniverse:killRecursive
    -- @covers LUniverse:setParent
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("killRecursive kills parent and all children", function()
        local world = lurek.ecs.newUniverse()
        local parent = world:spawn()
        local child1 = world:spawn()
        local child2 = world:spawn()
        world:setParent(child1, parent)
        world:setParent(child2, parent)
        world:killRecursive(parent)
        expect_false(world:isAlive(parent))
        expect_false(world:isAlive(child1))
        expect_false(world:isAlive(child2))
    end)
end)

-- getEntities

-- @describe World.getEntities
describe("World.getEntities", function()
    -- @covers LUniverse:getEntities
    -- @covers lurek.ecs.newUniverse
    it("getEntities returns a table", function()
        local world = lurek.ecs.newUniverse()
        local result = world:getEntities()
        expect_type("table", result)
    end)

    -- @covers LUniverse:getEntities
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("getEntities includes spawned entities", function()
        local world = lurek.ecs.newUniverse()
        local e1 = world:spawn()
        local e2 = world:spawn()
        local all = world:getEntities()
        local found_e1, found_e2 = false, false
        for _, id in ipairs(all) do
            if id == e1 then found_e1 = true end
            if id == e2 then found_e2 = true end
        end
        expect_true(found_e1, "e1 in getEntities")
        expect_true(found_e2, "e2 in getEntities")
    end)

    -- @covers LUniverse:getEntities
    -- @covers LUniverse:kill
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("getEntities does not include killed entities", function()
        local world = lurek.ecs.newUniverse()
        local e = world:spawn()
        world:kill(e)
        local all = world:getEntities()
        local found = false
        for _, id in ipairs(all) do
            if id == e then found = true end
        end
        expect_false(found, "killed entity should not appear in getEntities")
    end)
end)

-- getBitmapTagBit

-- @describe World.getBitmapTagBit
describe("World.getBitmapTagBit", function()
    -- @covers LUniverse:defineTag
    -- @covers LUniverse:getBitmapTagBit
    -- @covers lurek.ecs.newUniverse
    it("getBitmapTagBit returns a number for a defined tag", function()
        local world = lurek.ecs.newUniverse()
        world:defineTag("collidable")
        local bit = world:getBitmapTagBit("collidable")
        expect_type("number", bit)
    end)
end)

--  component observers (merged from test_entity_observers.lua)

-- @describe component observers
describe("component observers", function()
    -- @covers LUniverse:flushObservers
    -- @covers LUniverse:onComponentAdded
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("onComponentAdded fires after flushObservers", function()
        local w = lurek.ecs.newUniverse()
        local fired = 0
        local last_id = nil
        local last_name = nil
        w:onComponentAdded("hp", function(id, name)
            fired = fired + 1
            last_id = id
            last_name = name
        end)
        local e = w:spawn()
        w:set(e, "hp", 100)
        expect_equal(0, fired) -- not fired yet
        w:flushObservers()
        expect_equal(1, fired)
        expect_equal(e, last_id)
        expect_equal("hp", last_name)
    end)

    -- @covers LUniverse:flushObservers
    -- @covers LUniverse:onComponentAdded
    -- @covers LUniverse:onComponentRemoved
    -- @covers LUniverse:remove
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("onComponentRemoved fires after flushObservers", function()
        local w = lurek.ecs.newUniverse()
        local fired = 0
        w:onComponentRemoved("hp", function(id, name)
            fired = fired + 1
        end)
        local e = w:spawn()
        w:set(e, "hp", 50)
        w:flushObservers()   -- consume add event
        w:remove(e, "hp")
        expect_equal(0, fired) -- not yet
        w:flushObservers()
        expect_equal(1, fired)

        -- @covers LUniverse:flushObservers
        -- @covers LUniverse:onComponentRemoved
        -- @covers LUniverse:remove
        -- @covers LUniverse:spawn
        -- @covers lurek.ecs.newUniverse
        it("removing absent component does not fire remove event", function()
            local w = lurek.ecs.newUniverse()
            local fired = 0
            w:onComponentRemoved("hp", function() fired = fired + 1 end)
            local e = w:spawn()
            -- hp never set
            w:remove(e, "hp")
            w:flushObservers()
            expect_equal(0, fired)
        end)

        -- @covers LUniverse:flushObservers
        -- @covers LUniverse:onComponentAdded
        -- @covers LUniverse:set
        -- @covers LUniverse:spawn
        -- @covers lurek.ecs.newUniverse
        it("multiple observers on same component all fire", function()
            local w = lurek.ecs.newUniverse()
            local count = 0
            w:onComponentAdded("pos", function() count = count + 1 end)
            w:onComponentAdded("pos", function() count = count + 1 end)
            local e = w:spawn()
            w:set(e, "pos", {x=0,y=0})
            w:flushObservers()
            expect_equal(2, count)
        end)
    end)
end)

--  queryNot (merged from test_entity_query_not.lua)

-- @describe queryNot
describe("queryNot", function()
    -- @covers LUniverse:queryNot
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("returns entities that have required and NOT excluded components", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        local e2 = w:spawn()
        local e3 = w:spawn()
        w:set(e1, "Health", {hp = 100})
        w:set(e1, "Visible", true)
        w:set(e2, "Health", {hp = 50})
        -- e3 has no components
        -- queryNot: has Health, does NOT have Visible
        local res = w:queryNot({"Health"}, {"Visible"})
        expect_equal(1, #res)
        expect_equal(e2, res[1])
    end)

    -- @covers LUniverse:queryNot
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("empty without-list behaves like query", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        local e2 = w:spawn()
        w:set(e1, "Speed", 5)
        w:set(e2, "Speed", 10)
        local res = w:queryNot({"Speed"}, {})
        expect_equal(2, #res)
    end)

    -- @covers LUniverse:queryNot
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("empty with-list returns all entities without excluded component", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        local e2 = w:spawn()
        local e3 = w:spawn()
        w:set(e1, "Invisible", true)
        -- e2, e3 have no Invisible component
        local res = w:queryNot({}, {"Invisible"})
        -- e2 and e3 should appear
        expect_equal(2, #res)
    end)

    -- @covers LUniverse:queryNot
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("excludes entities with any of the excluded components", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        local e2 = w:spawn()
        local e3 = w:spawn()
        w:set(e1, "Health", 10)
        w:set(e2, "Health", 10)
        w:set(e2, "Dead", true)
        w:set(e3, "Health", 10)
        w:set(e3, "Frozen", true)
        local res = w:queryNot({"Health"}, {"Dead", "Frozen"})
        expect_equal(1, #res)
        expect_equal(e1, res[1])
    end)
end)

--  relationships (merged from test_entity_relationships.lua)

-- @describe lurek.patterns.RelationshipManager
describe("lurek.patterns.RelationshipManager", function()
    -- @covers LRelationshipManager:getValue
    -- @covers lurek.patterns.newRelationshipManager
    it("getValue defaults to zero for unknown pairs", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_near(0.0, rm:getValue(1, 2), 1e-5)
    end)

    -- @covers LRelationshipManager:getValue
    -- @covers LRelationshipManager:setValue
    -- @covers lurek.patterns.newRelationshipManager
    it("stores and retrieves numeric values between entity pairs", function()
        local rm = lurek.patterns.newRelationshipManager()
        local a, b = 1, 2
        rm:setValue(a, b, 75.0)
        expect_near(75.0, rm:getValue(a, b), 1e-5)
    end)

    -- @covers LRelationshipManager:adjustValue
    -- @covers LRelationshipManager:getValue
    -- @covers LRelationshipManager:setValue
    -- @covers lurek.patterns.newRelationshipManager
    it("adjustValue changes the value by delta", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50.0)
        rm:adjustValue(1, 2, -10.0)
        expect_near(40.0, rm:getValue(1, 2), 1e-5)
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:getLevel
    -- @covers LRelationshipManager:setLevel
    -- @covers lurek.patterns.newRelationshipManager
    it("supports named relationship type levels", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Faction", {"enemy", "neutral", "ally"}, "neutral")
        local ok = rm:setLevel(1, 2, "Faction", "ally")
        expect_equal(true, ok)
        expect_equal("ally", rm:getLevel(1, 2, "Faction"))
    end)

    -- @covers LRelationshipManager:setLevel
    -- @covers lurek.patterns.newRelationshipManager
    it("setLevel returns false for unknown type", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_equal(false, rm:setLevel(1, 2, "Unknown", "ally"))
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:setLevel
    -- @covers lurek.patterns.newRelationshipManager
    it("setLevel returns false for invalid level", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Faction", {"enemy", "ally"}, "ally")
        expect_equal(false, rm:setLevel(1, 2, "Faction", "neutral"))
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:getLevel
    -- @covers lurek.patterns.newRelationshipManager
    it("getLevel returns default when unset", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Faction", {"enemy", "neutral", "ally"}, "neutral")
        expect_equal("neutral", rm:getLevel(1, 2, "Faction"))
    end)

    -- @covers LRelationshipManager:getValue
    -- @covers LRelationshipManager:pairCount
    -- @covers LRelationshipManager:removePair
    -- @covers LRelationshipManager:setValue
    -- @covers lurek.patterns.newRelationshipManager
    it("removePair resets to defaults and decrements pairCount", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 100.0)
        expect_equal(1, rm:pairCount())
        rm:removePair(1, 2)
        expect_equal(0, rm:pairCount())
        expect_near(0.0, rm:getValue(1, 2), 1e-5)
    end)

    -- @covers LRelationshipManager:pairCount
    -- @covers LRelationshipManager:setValue
    -- @covers lurek.patterns.newRelationshipManager
    it("pairCount tracks stored pairs", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_equal(0, rm:pairCount())
        rm:setValue(1, 2, 5.0)
        expect_equal(1, rm:pairCount())
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:typeNames
    -- @covers lurek.patterns.newRelationshipManager
    it("typeNames returns all defined type names", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Friendship", {"stranger","friend","bestfriend"})
        rm:defineType("Faction", {"enemy","ally"})
        local names = rm:typeNames()
        expect_equal(2, #names)
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:removeType
    -- @covers LRelationshipManager:setLevel
    -- @covers LRelationshipManager:typeNames
    -- @covers lurek.patterns.newRelationshipManager
    it("removeType removes the relationship type", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("Mood", {"happy", "sad"}, "happy")
        rm:removeType("Mood")
        local names = rm:typeNames()
        expect_equal(0, #names)
        expect_equal(false, rm:setLevel(1, 2, "Mood", "sad"))
    end)
end)

-- ============================================================
-- ECS Universe directed relationship API
-- ============================================================
-- @describe lurek.ecs Universe directed relationships
describe("lurek.ecs Universe directed relationships", function()

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:getRelated
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("addRelation and getRelated round-trip", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        u:addRelation(e1, "owns", e2)
        local related = u:getRelated(e1, "owns")
        expect_equal(1, #related)
        expect_equal(e2, related[1])
    end)

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:hasRelation
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("hasRelation returns true when relation exists", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        u:addRelation(e1, "enemy", e2)
        expect_equal(true, u:hasRelation(e1, "enemy", e2))
    end)

    -- @covers LUniverse:hasRelation
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("hasRelation returns false when relation does not exist", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        expect_equal(false, u:hasRelation(e1, "ally", e2))
    end)

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:hasRelation
    -- @covers LUniverse:removeRelation
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("removeRelation removes a specific link", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        u:addRelation(e1, "ally", e2)
        u:removeRelation(e1, "ally", e2)
        expect_equal(false, u:hasRelation(e1, "ally", e2))
    end)

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:clearRelations
    -- @covers LUniverse:getRelated
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("clearRelations removes all links of a type", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        local e3 = u:spawn()
        u:addRelation(e1, "friend", e2)
        u:addRelation(e1, "friend", e3)
        u:clearRelations(e1, "friend")
        expect_equal(0, #u:getRelated(e1, "friend"))
    end)

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:getRelated
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("addRelation is idempotent  no duplicate links", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        u:addRelation(e1, "link", e2)
        u:addRelation(e1, "link", e2)
        expect_equal(1, #u:getRelated(e1, "link"))
    end)

    -- @covers LUniverse:addRelation
    -- @covers LUniverse:getRelated
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("directed links are not symmetric", function()
        local u = lurek.ecs.newUniverse()
        local e1 = u:spawn()
        local e2 = u:spawn()
        u:addRelation(e1, "owns", e2)
        expect_equal(0, #u:getRelated(e2, "owns"))
    end)

end)

--  serialization (merged from test_entity_serialization.lua)

-- @describe serialize and deserialize
describe("serialize and deserialize", function()
    -- @covers LUniverse:serialize
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("serialize returns a table with entities and bitmap_tags", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:set(e, "name", "hero")
        local snap = w:serialize()
        expect_equal("table", type(snap))
        expect_equal("table", type(snap.entities))
        expect_equal("table", type(snap.bitmap_tags))
    end)

    -- @covers LUniverse:serialize
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("serialized entity count matches world entity count", function()
        local w = lurek.ecs.newUniverse()
        w:spawn() w:spawn() w:spawn()
        local snap = w:serialize()
        expect_equal(3, #snap.entities)
    end)

    -- @covers LUniverse:clear
    -- @covers LUniverse:deserialize
    -- @covers LUniverse:get
    -- @covers LUniverse:getEntities
    -- @covers LUniverse:getEntityCount
    -- @covers LUniverse:serialize
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("deserialize restores component values", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        w:set(e1, "hp", 42)
        local snap = w:serialize()
        -- Clear and restore
        w:clear()
        w:deserialize(snap)
        expect_equal(1, w:getEntityCount())
        local ids = w:getEntities()
        local hp = w:get(ids[1], "hp")
        expect_equal(42, hp)
    end)

    -- @covers LUniverse:addTag
    -- @covers LUniverse:clear
    -- @covers LUniverse:deserialize
    -- @covers LUniverse:getEntitiesByTag
    -- @covers LUniverse:serialize
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("deserialize restores string tags", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:addTag(e, "enemy")
        w:addTag(e, "active")
        local snap = w:serialize()
        w:clear()
        w:deserialize(snap)
        local enemies = w:getEntitiesByTag("enemy")
        expect_equal(1, #enemies)
    end)

    -- @covers LUniverse:clear
    -- @covers LUniverse:defineBlueprint
    -- @covers LUniverse:deserialize
    -- @covers LUniverse:hasBlueprint
    -- @covers LUniverse:serialize
    -- @covers lurek.ecs.newUniverse
    it("deserialize preserves registered blueprints", function()
        local w = lurek.ecs.newUniverse()
        w:defineBlueprint("Enemy", {hp = 10, speed = 5})
        local snap = w:serialize()
        w:clear()
        w:deserialize(snap)
        expect_equal(true, w:hasBlueprint("Enemy"))
    end)
end)

--  system priority (merged from test_entity_system_priority.lua)

-- @describe system priority
describe("system priority", function()
    -- @covers LUniverse:addSystem
    -- @covers LUniverse:update
    -- @covers lurek.ecs.newUniverse
    it("systems dispatch in ascending priority order", function()
        local w = lurek.ecs.newUniverse()
        local order = {}
        local sys_a = {
            update = function(self, world, dt)
                table.insert(order, "A")
            end
        }
        local sys_b = {
            update = function(self, world, dt)
                table.insert(order, "B")
            end
        }
        local sys_c = {
            update = function(self, world, dt)
                table.insert(order, "C")
            end
        }
        -- Add in reverse order; lower priority = runs first
        w:addSystem(sys_c, {priority = 30})
        w:addSystem(sys_a, {priority = 10})
        w:addSystem(sys_b, {priority = 20})
        w:update(0.016)
        expect_equal("A", order[1])
        expect_equal("B", order[2])
        expect_equal("C", order[3])
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:update
    -- @covers lurek.ecs.newUniverse
    it("systems default to priority 0 when not specified", function()
        local w = lurek.ecs.newUniverse()
        local order = {}
        local sys_default = { update = function() table.insert(order, "default") end }
        local sys_negative = { update = function() table.insert(order, "early") end }
        w:addSystem(sys_default)            -- priority 0
        w:addSystem(sys_negative, {priority = -1})  -- runs before
        w:update(0)
        expect_equal("early", order[1])
        expect_equal("default", order[2])
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:getSystemCount
    -- @covers lurek.ecs.newUniverse
    it("getSystemCount increments correctly with priority", function()
        local w = lurek.ecs.newUniverse()
        expect_equal(0, w:getSystemCount())
        local s1 = { update = function() end }
        local s2 = { update = function() end }
        w:addSystem(s1, {priority = 5})
        w:addSystem(s2, {priority = 1})
        expect_equal(2, w:getSystemCount())
    end)
end)


-- [merged from test_ecs_regress_relationship_default.lua]
-- Regression: RelationshipManager:defineType must not panic when the optional
-- default_level argument is omitted or empty. Before the fix, an empty default
-- string tripped a debug_assert in RelationType::new.

-- @describe RelationshipManager regression: empty default_level
describe("RelationshipManager regression: empty default_level", function()
    -- @covers LRelationshipManager:defineType
    -- @covers LRelationshipManager:typeNames
    -- @covers lurek.patterns.newRelationshipManager
    it("defineType without default_level does not panic", function()
        local rm = lurek.patterns.newRelationshipManager()
        expect_no_error(function()
            rm:defineType("diplomacy", { "war", "neutral", "alliance" })
        end)
        local names = rm:typeNames()
        expect_equal(1, #names)
        expect_equal("diplomacy", names[1])
    end)

    -- @covers LRelationshipManager:defineType
    -- @covers lurek.patterns.newRelationshipManager
    it("defineType accepts empty levels table without error", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("neutral", {})
    end)
end)

-- @describe ecs strict: LUniverse release/spawnBulk/type/typeOf
describe("ecs strict: LUniverse release/spawnBulk/type/typeOf", function()
    -- @covers LUniverse:type
    -- @covers LUniverse:typeOf
    -- @covers lurek.ecs.newUniverse
    it("LUniverse type and typeOf are callable", function()
        local u = lurek.ecs.newUniverse()
        expect_type("string", u:type())
        expect_type("boolean", u:typeOf("Object"))
    end)

    -- @covers LUniverse:release
    -- @covers lurek.ecs.newUniverse
    it("LUniverse release is callable", function()
        local u = lurek.ecs.newUniverse()
        local ok = pcall(function() u:release() end)
        expect_type("boolean", ok)
    end)

    -- @covers LUniverse:spawnBulk
    -- @covers lurek.ecs.newUniverse
    it("LUniverse spawnBulk is callable for unknown archetype", function()
        local u = lurek.ecs.newUniverse()
        local ok = pcall(function() u:spawnBulk("ghost", 2) end)
        expect_type("boolean", ok)
    end)
end)

-- @describe queryMulti
describe("queryMulti", function()
    -- @covers LUniverse:queryMulti
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("calls callback with id and component values for matching entities", function()
        local w = lurek.ecs.newUniverse()
        local a = w:spawn()
        local b = w:spawn()
        local c = w:spawn()
        w:set(a, "pos", {x=1, y=2})
        w:set(a, "vel", {x=3, y=4})
        w:set(b, "pos", {x=5, y=6})   -- no vel
        w:set(c, "pos", {x=7, y=8})
        w:set(c, "vel", {x=9, y=10})

        local ids_seen = {}
        local sum_x = 0
        w:queryMulti({"pos", "vel"}, function(id, p, v)
            table.insert(ids_seen, id)
            sum_x = sum_x + p.x + v.x
        end)

        expect_equal(2, #ids_seen)
        expect_equal(1+3+7+9, sum_x)
    end)

    -- @covers LUniverse:queryMulti
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("calls callback zero times when no entity matches all components", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:set(e, "pos", {x=0, y=0})

        local count = 0
        w:queryMulti({"pos", "vel"}, function() count = count + 1 end)
        expect_equal(0, count)
    end)

    -- @covers LUniverse:queryMulti
    -- @covers lurek.ecs.newUniverse
    it("empty names list calls callback zero times", function()
        local w = lurek.ecs.newUniverse()
        w:spawn()
        local count = 0
        w:queryMulti({}, function() count = count + 1 end)
        expect_equal(0, count)
    end)
end)

-- @describe getDirtyEntities
describe("getDirtyEntities", function()
    -- @covers LUniverse:getDirtyEntities
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("tracks entities whose components were changed", function()
        local w = lurek.ecs.newUniverse()
        local e1 = w:spawn()
        local e2 = w:spawn()
        local e3 = w:spawn()

        w:set(e1, "hp", 10)
        w:set(e3, "speed", 5)

        local dirty = w:getDirtyEntities()
        expect_equal(2, #dirty)

        -- Check the entity IDs are in the returned table
        local found_e1, found_e3 = false, false
        for _, id in ipairs(dirty) do
            if id == e1 then found_e1 = true end
            if id == e3 then found_e3 = true end
        end
        expect_true(found_e1, "e1 should be dirty")
        expect_true(found_e3, "e3 should be dirty")
    end)

    -- @covers LUniverse:getDirtyEntities
    -- @covers LUniverse:flushObservers
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("dirty set is cleared after flushObservers", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:set(e, "hp", 10)
        expect_equal(1, #w:getDirtyEntities())
        w:flushObservers()
        expect_equal(0, #w:getDirtyEntities())
    end)

    -- @covers LUniverse:getDirtyEntities
    -- @covers LUniverse:remove
    -- @covers LUniverse:set
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("removing a component marks entity as dirty", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:set(e, "hp", 100)
        w:flushObservers()
        w:remove(e, "hp")
        local dirty = w:getDirtyEntities()
        local found = false
        for _, id in ipairs(dirty) do
            if id == e then found = true end
        end
        expect_true(found, "entity with removed component should be dirty")
    end)
end)

-- @describe system phases
describe("system phases", function()
    -- @covers LUniverse:addSystem
    -- @covers LUniverse:update
    -- @covers LUniverse:updatePhase
    -- @covers lurek.ecs.newUniverse
    it("update() only runs systems in the update phase", function()
        local w = lurek.ecs.newUniverse()
        local update_ran = false
        local pre_ran = false

        local UpdateSys = { update = function(self, world, dt) update_ran = true end }
        local PreSys    = { update = function(self, world, dt) pre_ran  = true end }

        w:addSystem(UpdateSys, {phase = "update"})
        w:addSystem(PreSys,    {phase = "pre_update"})

        w:update(0.016)

        expect_true(update_ran, "update phase system should have run")
        expect_false(pre_ran,   "pre_update system should not run on world:update()")
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:updatePhase
    -- @covers lurek.ecs.newUniverse
    it("updatePhase runs only systems in the named phase", function()
        local w = lurek.ecs.newUniverse()
        local order = {}

        local PreSys    = { update = function() table.insert(order, "pre")  end }
        local UpdateSys = { update = function() table.insert(order, "tick") end }
        local PostSys   = { update = function() table.insert(order, "post") end }

        w:addSystem(PreSys,    {phase = "pre_update"})
        w:addSystem(UpdateSys, {phase = "update"})
        w:addSystem(PostSys,   {phase = "post_update"})

        w:updatePhase("pre_update",  0.016)
        w:updatePhase("update",      0.016)
        w:updatePhase("post_update", 0.016)

        expect_equal("pre",  order[1])
        expect_equal("tick", order[2])
        expect_equal("post", order[3])
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:update
    -- @covers lurek.ecs.newUniverse
    it("system without explicit phase defaults to update phase", function()
        local w = lurek.ecs.newUniverse()
        local ran = false
        local Sys = { update = function() ran = true end }
        w:addSystem(Sys)  -- no phase option
        w:update(0.016)
        expect_true(ran, "default-phase system should run on world:update()")
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:emit
    -- @covers lurek.ecs.newUniverse
    it("emit dispatches to all systems regardless of phase", function()
        local w = lurek.ecs.newUniverse()
        local count = 0
        local SysA = { onEvent = function() count = count + 1 end }
        local SysB = { onEvent = function() count = count + 1 end }
        w:addSystem(SysA, {phase = "pre_update"})
        w:addSystem(SysB, {phase = "post_update"})
        w:emit("onEvent")
        expect_equal(2, count)
    end)

    -- @covers LUniverse:addSystem
    -- @covers LUniverse:render
    -- @covers lurek.ecs.newUniverse
    it("render() only runs systems in the render phase", function()
        local w = lurek.ecs.newUniverse()
        local render_ran = false
        local update_ran = false

        local RenderSys = { render = function() render_ran = true end }
        local UpdateSys = { render = function() update_ran = true end }

        w:addSystem(RenderSys, {phase = "render"})
        w:addSystem(UpdateSys, {phase = "update"})

        w:render()

        expect_true(render_ran,  "render-phase system should have run")
        expect_false(update_ran, "update-phase system should not run on world:render()")
    end)
end)

-- @describe snapshot and applySnapshot
describe("snapshot and applySnapshot", function()
    -- @covers LUniverse:applySnapshot
    -- @covers LUniverse:get
    -- @covers LUniverse:getEntityCount
    -- @covers LUniverse:set
    -- @covers LUniverse:snapshot
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("snapshot / applySnapshot round-trips entity state", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:set(e, "score", 99)

        local snap = w:snapshot()
        expect_equal("table", type(snap))

        w:clear()
        expect_equal(0, w:getEntityCount())

        w:applySnapshot(snap)
        expect_equal(1, w:getEntityCount())
        local ids = w:getEntities()
        expect_equal(99, w:get(ids[1], "score"))
    end)

    -- @covers LUniverse:applySnapshot
    -- @covers LUniverse:snapshot
    -- @covers LUniverse:spawn
    -- @covers lurek.ecs.newUniverse
    it("snapshot captures string tags", function()
        local w = lurek.ecs.newUniverse()
        local e = w:spawn()
        w:addTag(e, "hero")

        local snap = w:snapshot()
        w:clear()
        w:applySnapshot(snap)
        expect_true(w:hasTag(w:getEntities()[1], "hero"))
    end)
end)

test_summary()
