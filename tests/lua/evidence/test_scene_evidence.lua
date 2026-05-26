-- Evidence tests: scene module
-- Evidence validates lurek.scene depth sorting behavior.


local OUT = "tests/output/scene/"

-- @describe Evidence: lurek.scene DepthSorter
describe("Evidence: lurek.scene DepthSorter", function()
    before_each(function()
        ensure_evidence_dir("scene")
    end)

    -- @evidence file
    it("TXT: depth order ascending", function()
        local ds = lurek.scene.newDepthSorter()
        local call_order = {}

        ds:add(function() call_order[#call_order + 1] = 30 end, 30.0)
        ds:add(function() call_order[#call_order + 1] = 10 end, 10.0)
        ds:add(function() call_order[#call_order + 1] = 50 end, 50.0)
        ds:add(function() call_order[#call_order + 1] = -5 end, -5.0)
        ds:add(function() call_order[#call_order + 1] = 20 end, 20.0)

        ds:flush()

        local prev = -math.huge
        for _, v in ipairs(call_order) do
            expect_true(v >= prev)
            prev = v
        end

        local lines = {}
        for _, v in ipairs(call_order) do
            lines[#lines + 1] = tostring(v)
        end

        local path = OUT .. "depth_sort_order.txt"
        lurek.filesystem.write(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("TXT: stable equal-depth order", function()
        local ds = lurek.scene.newDepthSorter()
        ds:setStable(true)

        local call_order = {}
        ds:add(function() call_order[#call_order + 1] = "A" end, 5.0)
        ds:add(function() call_order[#call_order + 1] = "B" end, 5.0)
        ds:add(function() call_order[#call_order + 1] = "C" end, 5.0)
        ds:flush()

        expect_equal("A", call_order[1])
        expect_equal("B", call_order[2])
        expect_equal("C", call_order[3])

        local path = OUT .. "stable_sort_order.txt"
        lurek.filesystem.write(path, table.concat(call_order, "\n") .. "\n")
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("TXT: object entry order", function()
        local ds = lurek.scene.newDepthSorter()
        local call_order = {}

        local obj1 = { depth = 2.0, drawSorted = function() call_order[#call_order + 1] = 2 end }
        local obj2 = { depth = 1.0, drawSorted = function() call_order[#call_order + 1] = 1 end }

        ds:addObject(obj1)
        ds:addObject(obj2)
        ds:flush()

        expect_equal(1, call_order[1])
        expect_equal(2, call_order[2])

        local path = OUT .. "object_sort_order.txt"
        lurek.filesystem.write(path, table.concat({ tostring(call_order[1]), tostring(call_order[2]) }, "\n") .. "\n")
        expect_evidence_created(path)
    end)
end)

test_summary()
