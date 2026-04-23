-- Lurek2D Stress Test: Scene Graph / Entity Hierarchy
-- Measures entity create/destroy and component access throughput.

-- @description Covers suite: stress: massive entity spawn and kill.
describe("stress: massive entity spawn and kill", function()
    -- @covers lurek.ecs.newUniverse
    -- @covers Universe:spawn
    -- @covers Universe:kill
    -- @stress Creates and destroys 5000 one-off entities inside a measured loop.
    -- @description Stresses short-lived entity lifecycle churn by allocating a fresh universe entity every iteration and immediately deleting it.
    it("spawn and kill 5000 entities in <10s", function()
        local COUNT = 5000

        local elapsed = measure("entity spawn+kill x" .. COUNT, COUNT, function()
            local universe = lurek.ecs.newUniverse()
            local id = universe:spawn()
            universe:kill(id)
        end)

        expect_true(elapsed < 10.0, "entity lifecycle budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.ecs.newUniverse
    -- @covers Universe:spawn
    -- @covers Universe:set
    -- @covers Universe:get
    -- @stress Spawns 1000 entities, writes five components per entity, then reads back one component from every entity.
    -- @description Stresses component write and read throughput across a moderate entity pool by separating bulk writes from a full verification read pass.
    it("spawn 1000 entities, set+get 5 components each: <10s", function()
        local COUNT      = 1000
        local universe   = lurek.ecs.newUniverse()
        local ids        = {}

        for i = 1, COUNT do
            local id = universe:spawn()
            ids[i]   = id
        end

        local start = os.clock()
        for _, id in ipairs(ids) do
            universe:set(id, "x",     math.random() * 1000)
            universe:set(id, "y",     math.random() * 1000)
            universe:set(id, "hp",    100)
            universe:set(id, "alive", true)
            universe:set(id, "name",  "ecs")
        end
        local w_elapsed = os.clock() - start
        print(string.format("[STRESS] write 1000       5 components: %.4fs", w_elapsed))

        local start2 = os.clock()
        local sum = 0
        for _, id in ipairs(ids) do
            sum = sum + universe:get(id, "hp")
        end
        local r_elapsed = os.clock() - start2
        print(string.format("[STRESS] read 1000       hp: %.4fs (sum=%d)", r_elapsed, sum))

        expect_true(w_elapsed + r_elapsed < 10.0, "component r/w budget")
        expect_equal(100 * COUNT, sum, "all HPs are 100")
    end)
end)



-- ================================================================
-- Merged from: test_scene_depth_sort.lua
-- ================================================================

-- Lurek2D Lua stress test for lurek.scene DepthSorter with large item count
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.scene DepthSorter stress (1000 items).
describe("lurek.scene.DepthSorter stress", function()
    -- @covers lurek.scene.newDepthSorter
    -- @covers lurek.scene.DepthSorter.add
    -- @covers lurek.scene.DepthSorter.sort
    -- @covers lurek.scene.DepthSorter.getCount
    -- @description Verifies that 1000 items can be added and sorted without error.
    xit("adds 1000 items and sorts without error", function()
        local ds = lurek.scene.newDepthSorter()
        for i = 1, 1000 do
            local depth = math.random(1, 10000)
            ds:add(i, depth)
        end
        expect_equal(1000, ds:getCount())
        local sorted = ds:sort()
        expect_equal(1000, #sorted)
    end)

    -- @covers lurek.scene.DepthSorter.sort
    -- @description Verifies that sorted items are in ascending depth order.
    xit("sorted items are in ascending depth order", function()
        local ds = lurek.scene.newDepthSorter()
        ds:add("c", 30)
        ds:add("a", 10)
        ds:add("b", 20)
        local sorted = ds:sort()
        expect_equal(3, #sorted)
        -- First item must have depth <= second, etc.
        expect_equal(true, sorted[1].depth <= sorted[2].depth)
        expect_equal(true, sorted[2].depth <= sorted[3].depth)
    end)

    -- @covers lurek.scene.DepthSorter.clear
    -- @description Verifies that clear resets the sorter.
    xit("clear empties the sorter after bulk add", function()
        local ds = lurek.scene.newDepthSorter()
        for i = 1, 500 do
            ds:add(i, i)
        end
        ds:clear()
        expect_equal(0, ds:getCount())
    end)
end)

test_summary()
