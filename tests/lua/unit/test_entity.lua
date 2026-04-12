-- Entity module Lua tests
-- Headless-safe. Each describe block creates a fresh Universe.
-- @covers lurek.entity.newUniverse


-- @covers lurek.entity.World.setParent
-- @covers lurek.entity.World.getParent
-- @covers lurek.entity.World.getChildren
-- @covers lurek.entity.World.killRecursive
-- @covers lurek.entity.World.getEntities
-- @covers lurek.entity.World.getBitmapTagBit

-- @description Verifies sequential spawning, alive state tracking, entity counts after kill, and generational ID recycling on respawn.
describe("Spawn and lifecycle", function()
    -- @description Confirms the first two spawns return IDs 1 and 2, killing one entity reduces the live count, and a recycled slot respawns as a distinct live generational ID.
    it("spawns entities with sequential IDs", function()
        local world = lurek.entity.newUniverse()
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

-- @description Verifies setting, reading, listing, and removing named component values on a live entity.
describe("Components", function()
    -- @description Confirms component writes can be read back, has() reflects presence, getComponents() returns a table, and removed components become absent and nil.
    it("stores and retrieves component values", function()
        local world = lurek.entity.newUniverse()
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

-- @description Verifies component-based queries return the expected entity sets and callback iteration count.
describe("Query", function()
    -- @description Confirms query("pos","vel") returns only the entity with both components and query("pos") returns both entities carrying position.
    it("queries entities by components", function()
        local world = lurek.entity.newUniverse()
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

    -- @description Confirms each("pos", ...) invokes the callback once per entity with a pos component, producing a count of two.
    it("iterates matching entities with each()", function()
        local world = lurek.entity.newUniverse()
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

-- @description Verifies string tag assignment, lookup, listing, reverse lookup, and removal across multiple entities.
describe("String Tags", function()
    -- @description Confirms tags can be added and queried per entity, getTags returns the assigned tag, getEntitiesByTag finds the tagged entity, and removal clears membership.
    it("adds, queries, and removes string tags", function()
        local world = lurek.entity.newUniverse()
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

-- @description Verifies bitmap tag definition, assignment, per-entity checks, and any/all bitmap tag queries.
describe("Bitmap Tags", function()
    -- @description Confirms defineTag returns a numeric bit, bitmapTag assigns tags per entity, hasBitmapTag reflects presence, and fast/strong queries return the expected entity sets.
    it("defines and queries bitmap tags", function()
        local world = lurek.entity.newUniverse()
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
end)

-- @description Verifies explicit layer assignment, per-layer lookup, and overall sorted ordering by layer value.
describe("Layers", function()
    -- @description Confirms entities retain assigned layer numbers, layer 0 lookup is non-empty, and sorted entities place the layer 0 entity before the layer 2 entity.
    it("assigns layers and returns entities sorted by layer", function()
        local world = lurek.entity.newUniverse()
        local p = world:spawn()
        local q = world:spawn()

        world:setLayer(p, 2)
        world:setLayer(q, 0)
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

-- @description Verifies blueprint registration, spawning, override behavior, inheritance, listing, removal, and component table retrieval.
describe("Blueprints", function()
    -- @description Confirms a defined blueprint is reported as present and spawns a live entity with the stored hp and speed component values.
    it("defines blueprints and spawns entities from them", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })
        expect_true(world:hasBlueprint("goblin"))

        local g = world:spawnBlueprint("goblin")
        expect_true(world:isAlive(g))
        expect_equal(30, world:get(g, "hp"))
        expect_equal(100, world:get(g, "speed"))
    end)

    -- @description Confirms mutating one spawned blueprint instance does not affect later spawns, which still receive the original hp value.
    it("blueprints provide deep-copy isolation", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })

        local g = world:spawnBlueprint("goblin")
        world:set(g, "hp", 999)
        local g2 = world:spawnBlueprint("goblin")
        expect_equal(30, world:get(g2, "hp"))
    end)

    -- @description Confirms an extended blueprint inherits base fields, overrides hp, and adds the boss flag on spawned entities.
    it("extends blueprints with overrides", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })
        world:extendBlueprint("boss_goblin", "goblin", { hp = 200, boss = true })

        local bg = world:spawnBlueprint("boss_goblin")
        expect_equal(200, world:get(bg, "hp"))
        expect_equal(100, world:get(bg, "speed"))
        expect_equal(true, world:get(bg, "boss"))
    end)

    -- @description Confirms per-spawn overrides replace blueprint hp while leaving unspecified fields such as speed unchanged.
    it("spawnBlueprint accepts per-spawn field overrides", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30, speed = 100 })

        local g = world:spawnBlueprint("goblin", { hp = 50 })
        expect_equal(50, world:get(g, "hp"))
        expect_equal(100, world:get(g, "speed"))
    end)

    -- @description Confirms listBlueprints returns at least the two defined names and removeBlueprint makes the removed blueprint report absent.
    it("lists and removes blueprints", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30 })
        world:defineBlueprint("boss", { hp = 200 })

        local bps = world:listBlueprints()
        expect_true(#bps >= 2)

        world:removeBlueprint("boss")
        expect_false(world:hasBlueprint("boss"))
    end)

    -- @description Confirms getBlueprintComponents returns a non-nil table containing the blueprint's stored hp field.
    it("getBlueprintComponents returns component table", function()
        local world = lurek.entity.newUniverse()
        world:defineBlueprint("goblin", { hp = 30 })

        local bp_comps = world:getBlueprintComponents("goblin")
        expect_true(bp_comps ~= nil)
        expect_equal(30, bp_comps.hp)
    end)
end)

-- @description Verifies systems can be registered, counted, updated, drawn, sent custom events, and removed by reference.
describe("Systems", function()
    -- @description Confirms addSystem increments the system count, update() calls the system update once, and emit("draw") calls the draw handler once.
    it("dispatches update and draw to registered systems", function()
        local world = lurek.entity.newUniverse()
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

    -- @description Confirms emit("onHit", 42) dispatches the custom event method and passes the damage payload through unchanged.
    it("emits custom events to systems", function()
        local world = lurek.entity.newUniverse()
        local custom_count = 0

        local EventSys = {}
        function EventSys:onHit(w, damage) custom_count = damage end
        world:addSystem(EventSys)

        world:emit("onHit", 42)
        expect_equal(42, custom_count)
    end)

    -- @description Confirms removeSystem deletes the referenced system instance and reduces the registered system count from two to one.
    it("removeSystem removes by reference", function()
        local world = lurek.entity.newUniverse()

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

-- @description Verifies clearing the world removes live entities without deleting registered blueprints.
describe("Clear and Release", function()
    -- @description Confirms clear() resets the live entity count to zero while preserving a previously defined blueprint.
    it("clear() removes entities but preserves blueprints", function()
        local world = lurek.entity.newUniverse()
        world:spawn()
        world:spawn()
        world:defineBlueprint("preserved", { val = 1 })

        world:clear()
        expect_equal(0, world:getEntityCount())
        expect_true(world:hasBlueprint("preserved"))
    end)
end)

-- â”€â”€ parent-child hierarchy â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies parent assignment, missing-parent behavior, child enumeration, empty child lists, and recursive death propagation.
describe("parent-child hierarchy", function()
    -- @description Confirms setParent stores the relationship and getParent returns the same parent entity ID.
    it("setParent / getParent round-trip", function()
        local world = lurek.entity.newUniverse()
        local parent = world:spawn()
        local child  = world:spawn()
        world:setParent(child, parent)
        expect_equal(parent, world:getParent(child))
    end)

    -- @description Confirms getParent returns nil when no parent relationship has been assigned.
    it("getParent returns nil for entity with no parent", function()
        local world = lurek.entity.newUniverse()
        local e = world:spawn()
        expect_nil(world:getParent(e))
    end)

    -- @description Confirms getChildren returns a table and that the attached child ID appears in the returned list.
    it("getChildren returns table containing child", function()
        local world = lurek.entity.newUniverse()
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

    -- @description Confirms getChildren returns an empty table for an entity that has no attached children.
    it("getChildren returns empty table when no children attached", function()
        local world = lurek.entity.newUniverse()
        local e = world:spawn()
        local children = world:getChildren(e)
        expect_type("table", children)
        expect_equal(0, #children)
    end)

    -- @description Confirms killRecursive marks the parent and both linked children as no longer alive.
    it("killRecursive kills parent and all children", function()
        local world = lurek.entity.newUniverse()
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

-- â”€â”€ getEntities â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies getEntities returns a table of live entities, includes spawned IDs, and excludes killed ones.
describe("World.getEntities", function()
    -- @description Confirms getEntities always returns a table value even before entities are inspected.
    it("getEntities returns a table", function()
        local world = lurek.entity.newUniverse()
        local result = world:getEntities()
        expect_type("table", result)
    end)

    -- @description Confirms both spawned entity IDs appear in the getEntities result set.
    it("getEntities includes spawned entities", function()
        local world = lurek.entity.newUniverse()
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

    -- @description Confirms an entity removed with kill() no longer appears in the getEntities result set.
    it("getEntities does not include killed entities", function()
        local world = lurek.entity.newUniverse()
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

-- â”€â”€ getBitmapTagBit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies a previously defined bitmap tag can be resolved back to its numeric bit value.
describe("World.getBitmapTagBit", function()
    -- @description Confirms getBitmapTagBit returns a number after the collidable tag has been defined with an explicit bit.
    it("getBitmapTagBit returns a number for a defined tag", function()
        local world = lurek.entity.newUniverse()
        world:defineTag("collidable", 1)
        local bit = world:getBitmapTagBit("collidable")
        expect_type("number", bit)
    end)
end)

test_summary()
