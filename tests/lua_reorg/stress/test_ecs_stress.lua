-- Lurek2D Stress Test: Entity Mass Spawn
-- Tests entity creation, tag assignment, and component operations at scale

local function new_universe()
    return lurek.ecs.newUniverse()
end

-- @describe entity stress: mass spawn
describe("entity stress: mass spawn", function()
    -- @stress LUniverse:spawn
    it("spawns 10000 entities", function()
        local universe = new_universe()

        for i = 1, 10000 do
            universe:spawn()
        end

        expect_equal(10000, universe:getEntityCount(), "10000 entities alive")
    end)

    -- @stress LUniverse:kill
    it("spawns and kills 5000 entities", function()
        local universe = new_universe()
        local ids = {}

        for i = 1, 5000 do
            ids[i] = universe:spawn()
        end
        expect_equal(5000, universe:getEntityCount(), "5000 spawned")

        for i = 1, 2500 do
            universe:kill(ids[i])
        end
        expect_equal(2500, universe:getEntityCount(), "2500 remaining")
    end)

    -- @stress LUniverse:set
    it("adds components to 5000 entities", function()
        local universe = new_universe()
        local sample_id = nil

        for i = 1, 5000 do
            local id = universe:spawn()
            if i == 2500 then
                sample_id = id
            end
            universe:set(id, "position", {x = i, y = i * 2})
            universe:set(id, "health", 100)
            universe:set(id, "name", "entity_" .. i)
        end

        expect_equal(5000, universe:getEntityCount(), "5000 with components")
        expect_equal(100, universe:get(sample_id, "health"), "sample entity stores component data")
    end)

    -- @stress LUniverse:isAlive
    it("ID recycling works after mass kill", function()
        local universe = new_universe()
        local old_ids = {}

        for i = 1, 1000 do
            old_ids[i] = universe:spawn()
        end
        for i = 1, 1000 do
            universe:kill(old_ids[i])
        end
        expect_equal(0, universe:getEntityCount(), "all killed")
        expect_false(universe:isAlive(old_ids[1]), "killed entity is no longer alive")

        local new_ids = {}
        for i = 1, 1000 do
            new_ids[i] = universe:spawn()
        end
        expect_equal(1000, universe:getEntityCount(), "1000 respawned")
        expect_true(universe:isAlive(new_ids[1]), "respawned entity is alive")
    end)

    -- @stress LUniverse:hasTag
    it("tag operations at scale", function()
        local universe = new_universe()

        for i = 1, 2000 do
            local id = universe:spawn()
            if i % 2 == 0 then
                universe:addTag(id, "even")
            else
                universe:addTag(id, "odd")
            end
            if i % 3 == 0 then
                universe:addTag(id, "multiple_of_3")
            end
        end

        expect_equal(2000, universe:getEntityCount(), "2000 tagged entities")
        expect_true(universe:hasTag(2, "even"), "even entity keeps even tag")
        expect_true(universe:hasTag(3, "multiple_of_3"), "multiple-of-3 entity keeps tag")
        expect_false(universe:hasTag(3, "even"), "odd entity does not get even tag")
    end)
end)



-- ================================================================
-- Merged from: test_ecs_bulk_spawn.lua
-- ================================================================

-- Lurek2D Lua stress test for lurek.ecs spawnBulk
-- Headless: no GPU, no audio, no window.

-- @describe lurek.ecs.spawnBulk
describe("lurek.ecs.spawnBulk", function()
    -- @stress LUniverse:spawnBulk
    it("spawnBulk creates correct entity count from blueprint", function()
        local w = new_universe()
        w:defineBlueprint("Enemy", {hp = 10, speed = 5, alive = true})
        local ids = w:spawnBulk("Enemy", 100)
        expect_equal(100, #ids)
        expect_equal(100, w:getEntityCount())
    end)

    -- @stress LUniverse:get
    it("each bulk-spawned entity has blueprint components", function()
        local w = new_universe()
        w:defineBlueprint("Bullet", {dmg = 5, vel = 20})
        local ids = w:spawnBulk("Bullet", 10)
        for _, id in ipairs(ids) do
            expect_equal(5, w:get(id, "dmg"))
        end
    end)

    -- @stress LUniverse:defineBlueprint
    it("spawning 500 entities completes without error", function()
        local w = new_universe()
        w:defineBlueprint("Particle", {life = 1.0, x = 0, y = 0})
        local ids = w:spawnBulk("Particle", 500)
        expect_equal(500, #ids)
    end)

    -- @stress LUniverse:getEntityCount
    it("spawnBulk with count 0 returns empty table", function()
        local w = new_universe()
        w:defineBlueprint("X", {a = 1})
        local ids = w:spawnBulk("X", 0)
        expect_equal(0, #ids)
        expect_equal(0, w:getEntityCount())
    end)

    -- @stress LUniverse:addTag
    it("spawnBulk then mass kill keeps entity count consistent", function()
        local w = new_universe()
        w:defineBlueprint("Heavy", {hp = 200, armor = 10})
        local ids = w:spawnBulk("Heavy", 2000)
        for i = 1, #ids do
            w:addTag(ids[i], "heavy")
        end

        for i = 1, 1000 do
            w:kill(ids[i])
        end

        expect_equal(1000, w:getEntityCount())
        expect_true(w:hasTag(ids[1500], "heavy"), "surviving entity keeps stress-added tag")
    end)
end)
test_summary()
