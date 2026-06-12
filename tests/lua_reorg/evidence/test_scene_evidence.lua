-- Canonical evidence file for lurek.scene data and visual outputs.



local OUT = evidence_output_dir("scene")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.scene DepthSorter
describe("Evidence: lurek.scene DepthSorter", function()
    before_each(function()
        ensure_evidence_dir("scene")
    end)

    -- @evidence lurek.scene.newDepthSorter
    -- @evidence LDepthSorter:add
    -- @evidence LDepthSorter:flush
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

        local path = OUT .. "scene_depth_sort_ascending.txt"
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)

    -- @evidence LDepthSorter:setStable
    -- @evidence LDepthSorter:flush
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

        local path = OUT .. "scene_depth_sort_stable_equal_depth.txt"
        write_text(path, table.concat(call_order, "\n") .. "\n")
    end)

    -- @evidence LDepthSorter:addObject
    -- @evidence LDepthSorter:flush
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

        local path = OUT .. "scene_depth_sort_object_entries.txt"
        write_text(path, table.concat({ tostring(call_order[1]), tostring(call_order[2]) }, "\n") .. "\n")
    end)
end)

describe("Evidence: lurek.scene runtime flow", function()
    before_each(function()
        ensure_evidence_dir("scene")
        lurek.scene.clear()
        lurek.scene.clearQueuedTransitions()
    end)

    -- @evidence LDepthSorter:add
    -- @evidence LDepthSorter:flush
    -- @evidence lurek.image.savePNG
    it("PNG: depth sorter order bands", function()
        local ds = lurek.scene.newDepthSorter()
        local order = {}

        ds:add(function() order[#order + 1] = 4 end, 40.0)
        ds:add(function() order[#order + 1] = 1 end, 10.0)
        ds:add(function() order[#order + 1] = 3 end, 30.0)
        ds:add(function() order[#order + 1] = 2 end, 20.0)
        ds:flush()

        local img = lurek.image.newImageData(220, 120)
        img:fill(14, 16, 20, 255)
        local colors = {
            { 90, 180, 255 },
            { 120, 220, 140 },
            { 255, 190, 80 },
            { 255, 120, 120 },
        }
        for i, depth_rank in ipairs(order) do
            local c = colors[depth_rank]
            local y = 10 + (i - 1) * 26
            for py = y, y + 18 do
                for px = 16, 204 do
                    img:setPixel(px, py, c[1], c[2], c[3], 255)
                end
            end
            img:drawRect(16, y, 188, 18, 12, 12, 14, 255)
        end

        local path = OUT .. "scene_depth_sort_bands.png"
        save_png(img, path)
    end)

    -- @evidence lurek.scene.queueTransition
    -- @evidence lurek.scene.getQueuedTransitionCount
    -- @evidence lurek.scene.clearQueuedTransitions
    -- @evidence lurek.scene.getTransitionProgress
    it("TXT: scene transition queue trace", function()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.5, "linear")
        local queued_before = lurek.scene.getQueuedTransitionCount()
        lurek.scene.update(0.25)
        local progress_mid = lurek.scene.getTransitionProgress()
        lurek.scene.clearQueuedTransitions()
        local queued_after = lurek.scene.getQueuedTransitionCount()

        local lines = {
            "queued_before=" .. tostring(queued_before),
            "progress_mid=" .. tostring(progress_mid),
            "queued_after=" .. tostring(queued_after),
        }
        local path = OUT .. "scene_transition_queue_trace.txt"
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
