-- Integration: animation frames controlling SVG layer visibility

-- @describe svg + animation integration
describe("svg + animation integration", function()
    -- @integration lurek.svg.load
    -- @integration LSvgImage:setElementVisible
    -- @integration LSvgImage:getElementVisible
    -- @integration LSvgImage:getElementAtPoint
    -- @integration lurek.animation.new
    -- @integration LAnimation:addFramesFromGrid
    -- @integration LAnimation:addClip
    -- @integration LAnimation:play
    -- @integration LAnimation:update
    -- @integration LAnimation:getCurrentFrame
    it("animation frame index toggles SVG frame groups", function()
        local svg = lurek.svg.load("tests/lua/fixtures/svg_frames.svg")
        local anim = lurek.animation.new()
        anim:addFramesFromGrid(32, 16, 16, 16, 0, 2)
        anim:addClip("flip", {0, 1}, 2.0, false)
        anim:play("flip")

        svg:setElementVisible("frame_0", true)
        svg:setElementVisible("frame_1", false)
        expect_equal(true, svg:getElementVisible("frame_0"))
        expect_equal(false, svg:getElementVisible("frame_1"))
        expect_equal("frame_0", svg:getElementAtPoint("frame_", 12, 12))

        anim:update(0.5)
        local frame = anim:getCurrentFrame()
        svg:setElementVisible("frame_0", frame == 0)
        svg:setElementVisible("frame_1", frame == 1)

        expect_equal(1, frame)
        expect_equal(false, svg:getElementVisible("frame_0"))
        expect_equal(true, svg:getElementVisible("frame_1"))
        expect_equal("frame_1", svg:getElementAtPoint("frame_", 44, 12))
    end)
end)
test_summary()
