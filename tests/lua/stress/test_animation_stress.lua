-- Lurek2D Stress Test: Animation Timelines
-- Tests mass creation and updating of animation timelines

-- @description Covers suite: animation stress: mass timeline creation.
describe("animation stress: mass timeline creation", function()
    -- @covers lurek.animation.newTimeline
    -- @covers Timeline:addFrame
    -- @stress Allocates 1000 timelines and appends two keyframes to each.
    -- @description Stresses timeline construction and keyframe insertion by creating a large batch of small animations in a tight allocation loop.
    it("creates 1000 timelines", function()
        local timelines = {}
        for i = 1, 1000 do
            local tl = lurek.animation.newTimeline()
            tl:addFrame(0.0, { idx = i })
            tl:addFrame(1.0, { idx = i + 1 })
            timelines[i] = tl
        end
        expect_equal(1000, #timelines, "1000 timelines created")
    end)

    -- @covers lurek.animation.newTimeline
    -- @covers Timeline:update
    -- @stress Builds 1000 timelines and advances all of them for 60 simulated frames.
    -- @description Stresses per-frame animation stepping by combining bulk timeline allocation with a 60-frame nested update loop over the full timeline set.
    it("updates 1000 timelines per frame", function()
        local timelines = {}
        for i = 1, 1000 do
            local tl = lurek.animation.newTimeline()
            tl:addFrame(0.0, { v = 0 })
            tl:addFrame(1.0, { v = 100 })
            timelines[i] = tl
        end

        -- Simulate 60 frames of updates
        local dt = 1.0 / 60.0
        for frame = 1, 60 do
            for _, tl in ipairs(timelines) do
                tl:update(dt)
            end
        end

        -- All should have advanced
        local elapsed = timelines[1]:getElapsed()
        expect_true(elapsed > 0.9, "timelines advanced: " .. elapsed)
    end)
end)

-- @description Covers suite: animation stress: many keyframes.
describe("animation stress: many keyframes", function()
    -- @covers lurek.animation.newTimeline
    -- @covers Timeline:addFrame
    -- @covers Timeline:seek
    -- @stress Appends 100 keyframes to one timeline, then performs repeated seek-based frame lookups across the timeline.
    -- @description Stresses dense keyframe storage and lookup by packing 100 closely spaced frames into one timeline and seeking across start, midpoint, and end positions.
    it("timeline with 100 keyframes", function()
        local tl = lurek.animation.newTimeline()
        for i = 0, 99 do
            tl:addFrame(i * 0.01, { frame = i })
        end

        -- Seek to various points
        tl:seek(0.0)
        expect_true(tl:getCurrentFrame() ~= nil, "frame at start")

        tl:seek(0.5)
        expect_true(tl:getCurrentFrame() ~= nil, "frame at midpoint")

        tl:seek(0.99)
        expect_true(tl:getCurrentFrame() ~= nil, "frame near end")
    end)
end)

test_summary()
