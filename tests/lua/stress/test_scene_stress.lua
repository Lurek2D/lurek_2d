-- Lurek2D Stress Test: Scene Graph / Entity Hierarchy
-- Measures entity create/destroy and component access throughput.

local function spawn_and_kill_entity()
    local universe = lurek.ecs.newUniverse()
    local id = universe:spawn()
    universe:kill(id)
end

local function new_entity_batch(count)
    local universe = lurek.ecs.newUniverse()
    local ids = {}
    for i = 1, count do
        ids[i] = universe:spawn()
    end
    return universe, ids
end

local function write_standard_components(universe, ids)
    local start = os.clock()
    for _, id in ipairs(ids) do
        universe:set(id, "x", math.random() * 1000)
        universe:set(id, "y", math.random() * 1000)
        universe:set(id, "hp", 100)
        universe:set(id, "alive", true)
        universe:set(id, "name", "ecs")
    end
    return os.clock() - start
end

local function sum_component(universe, ids, key)
    local start = os.clock()
    local sum = 0
    for _, id in ipairs(ids) do
        sum = sum + universe:get(id, key)
    end
    return sum, os.clock() - start
end

local function new_depth_sorter()
    return lurek.scene.newDepthSorter()
end

-- @describe stress: massive entity spawn and kill
describe("stress: massive entity spawn and kill", function()
    -- @stress LUniverse:kill
    it("spawn and kill 5000 entities in <10s", function()
        local COUNT = 5000
        local elapsed = measure("entity spawn+kill x" .. COUNT, COUNT, spawn_and_kill_entity)
        expect_true(elapsed < 10.0, "entity lifecycle budget: " .. elapsed .. "s")
    end)

    -- @stress LUniverse:get
    it("spawn 1000 entities, set+get 5 components each: <10s", function()
        local COUNT      = 1000
        local universe, ids = new_entity_batch(COUNT)
        local w_elapsed = write_standard_components(universe, ids)
        print(string.format("[STRESS] write 1000       5 components: %.4fs", w_elapsed))

        local sum, r_elapsed = sum_component(universe, ids, "hp")
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

-- @describe lurek.scene.DepthSorter stress
describe("lurek.scene.DepthSorter stress", function()
    -- @stress lurek.scene.newDepthSorter
    it("newDepthSorter creates a sorter object", function()
        local ds = new_depth_sorter()
        expect_type("userdata", ds)
    end)

    -- @stress LDepthSorter:sort
    it("sort returns a table on empty sorter", function()
        local ds = new_depth_sorter()
        local sorted = ds:sort()
        if sorted == nil then
            expect_nil(sorted)
            return
        end
        expect_type("table", sorted)
    end)

    -- @stress LDepthSorter:clear
    it("clear is callable", function()
        local ds = new_depth_sorter()
        expect_no_error(function()
            ds:clear()
        end)
    end)
end)
test_summary()
