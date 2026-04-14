-- Lurek2D Lua stress test for lurek.scene DepthSorter with large item count
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.scene DepthSorter stress (1000 items).
describe("lurek.scene.DepthSorter stress", function()
    -- @covers lurek.scene.newDepthSorter
    -- @covers lurek.scene.DepthSorter.add
    -- @covers lurek.scene.DepthSorter.sort
    -- @covers lurek.scene.DepthSorter.getCount
    -- @description Verifies that 1000 items can be added and sorted without error.
    it("adds 1000 items and sorts without error", function()
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
    it("sorted items are in ascending depth order", function()
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
    it("clear empties the sorter after bulk add", function()
        local ds = lurek.scene.newDepthSorter()
        for i = 1, 500 do
            ds:add(i, i)
        end
        ds:clear()
        expect_equal(0, ds:getCount())
    end)
end)
test_summary()
