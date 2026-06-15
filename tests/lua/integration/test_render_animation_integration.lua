-- Integration: animation frame progression controlling sprite draw coordinates
-- @describe animation + render integration

-- @describe animation + render integration
describe("animation + render integration", function()
    -- @integration lurek.animation.new
    -- @integration LAnimation:addFramesFromGrid
    -- @integration LAnimation:addClip
    -- @integration LAnimation:isPlaying
    -- @integration LAnimation:play
    -- @integration LAnimation:update
    -- @integration LAnimation:getCurrentFrame
    -- @integration lurek.render.setColor
    -- @integration lurek.render.rectangle
    -- @integration lurek.animation.new
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    it("animation frame index controls render source texture offset", function()
        local anim = lurek.animation.new()
        expect_type("userdata", anim, "animation constructor returns userdata")
        anim:addFramesFromGrid(64, 16, 16, 16, 0, 4)  -- 4 frames, 16px wide each
        anim:addClip("walk", {0, 1, 2, 3}, 8.0, false)
        anim:play("walk")
        expect_true(anim:isPlaying(), "clip enters playing state before render")

        anim:update(0.125)  -- 8 fps, so 0.125s = one frame
        local frame_idx = anim:getCurrentFrame()
        local src_x = frame_idx * 16
        expect_equal(1, frame_idx, "frame 1 after one update at 8fps")
        expect_equal(16, src_x, "frame index maps to the expected sprite source offset")
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.rectangle("fill", src_x, 0, 16, 16)
    end)

    -- @integration lurek.animation.new
    -- @integration LAnimation:addFramesFromGrid
    -- @integration LAnimation:addClip
    -- @integration LAnimation:isPlaying
    -- @integration LAnimation:play
    -- @integration LAnimation:update
    -- @integration LAnimation:getCurrentFrame
    -- @integration lurek.render.rectangle
    it("sequential animation updates produce consecutive sprite offsets", function()
        local anim = lurek.animation.new()
        expect_type("userdata", anim, "animation constructor returns userdata")
        anim:addFramesFromGrid(32, 16, 16, 16, 0, 2)
        anim:addClip("seq", {0, 1}, 5.0, false)
        anim:play("seq")
        expect_true(anim:isPlaying(), "sequence clip starts playing")

        local offsets = {}
        for i = 1, 4 do
            anim:update(0.25)  -- 5fps
            local frame_idx = anim:getCurrentFrame()
            local src_x = frame_idx * 16
            table.insert(offsets, src_x)
            lurek.render.rectangle("fill", src_x, 0, 16, 16)
        end
        expect_equal(4, #offsets, "exactly 4 frame updates recorded")
        expect_equal(16, offsets[1], "first update uses second frame source offset")
        expect_equal(16, offsets[2], "non-looping clip holds the last frame on second update")
        expect_equal(16, offsets[3], "non-looping clip keeps the last frame on third update")
        expect_equal(16, offsets[4], "non-looping clip keeps the last frame on fourth update")
    end)
end)
test_summary()
