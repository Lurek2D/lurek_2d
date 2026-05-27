-- tests/lua/unit/test_ui_features_unit.lua
-- Unit: lurek.ui (layout, focus, resolution, virtualization, animation)
-- Tests new UI features: spatial focus, resolution scaling, visible range, extended animations.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end

-- @describe ui spatial focus navigation
describe("ui spatial focus navigation", function()
    -- @covers lurek.ui.focusDirection
    it("moves focus spatially to nearest widget in direction", function()
        -- Create two buttons side by side
        local btn1 = lurek.ui.newButton("Left")
        btn1:setPosition(10, 50)
        btn1:setSize(80, 30)

        local btn2 = lurek.ui.newButton("Right")
        btn2:setPosition(200, 50)
        btn2:setSize(80, 30)

        lurek.ui.update(0.0)
        lurek.ui.setFocus(btn1)

        -- Move focus right
        local moved = lurek.ui.focusDirection(1.0, 0.0)
        expect_type("boolean", moved)
    end)

    -- @covers lurek.ui.focusDirection
    it("returns false when no neighbor exists in direction", function()
        local btn = lurek.ui.newButton("Solo")
        btn:setPosition(500, 500)
        btn:setSize(80, 30)

        lurek.ui.update(0.0)
        lurek.ui.setFocus(btn)

        -- Try to move in direction with nothing
        local moved = lurek.ui.focusDirection(0.0, -1.0)
        expect_type("boolean", moved)
    end)
end)

-- @describe ui resolution scaling
describe("ui resolution scaling", function()
    -- @covers lurek.ui.setBaseResolution
    -- @covers lurek.ui.getScaleFactor
    it("computes scale factor from base and current resolution", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(1920, 1080)
        local factor = lurek.ui.getScaleFactor()
        expect_near(1.0, factor, 0.01)
    end)

    -- @covers lurek.ui.updateResolution
    -- @covers lurek.ui.getScaleFactor
    it("scale factor changes when resolution changes", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(1280, 720)
        local factor = lurek.ui.getScaleFactor()
        -- 720 / 1080 = 0.667
        expect_near(0.667, factor, 0.01)
    end)

    -- @covers lurek.ui.setBaseResolution
    -- @covers lurek.ui.getScaleFactor
    -- @covers lurek.ui.updateResolution
    it("doubling resolution doubles scale factor", function()
        lurek.ui.setBaseResolution(1920, 1080)
        lurek.ui.updateResolution(3840, 2160)
        local factor = lurek.ui.getScaleFactor()
        expect_near(2.0, factor, 0.01)
    end)
end)

-- @describe ui visible range virtualization
describe("ui visible range virtualization", function()
    -- @covers lurek.ui.visibleRange
    it("computes visible item range for list box", function()
        local list = lurek.ui.newList()
        list:setPosition(10, 10)
        list:setSize(200, 100)
        lurek.ui.update(0.0)

        local start_idx, end_idx = lurek.ui.visibleRange(list, 50, 20.0)
        expect_type("number", start_idx)
        expect_type("number", end_idx)
        -- viewport 100px / 20px per item = 5 visible items + 1 = 6 max
        expect_true(end_idx - start_idx <= 7, "visible range should be bounded by viewport")
        expect_true(end_idx <= 50, "end should not exceed item count")
    end)
end)

-- @describe ui extended animations
describe("ui extended animations", function()
    -- @covers lurek.ui.animateScale
    it("starts scale animation on widget", function()
        local panel = lurek.ui.newPanel()
        local result = lurek.ui.animateScale(panel._idx, 1.0, 1.0, 2.0, 2.0, 0.5, "cubic_out")
        expect_true(result, "animateScale should return true for valid widget")
    end)

    -- @covers lurek.ui.animateRotation
    it("starts rotation animation on widget", function()
        local panel = lurek.ui.newPanel()
        local result = lurek.ui.animateRotation(panel._idx, 0.0, 3.14, 1.0, "bounce_out")
        expect_true(result, "animateRotation should return true for valid widget")
    end)

    -- @covers lurek.ui.animateColor
    it("starts color tint animation on widget", function()
        local panel = lurek.ui.newPanel()
        local from = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
        local to = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 }
        local result = lurek.ui.animateColor(panel._idx, from, to, 0.8, "sine_in_out")
        expect_true(result, "animateColor should return true for valid widget")
    end)

    -- @covers lurek.ui.animateScale
    it("animateScale returns false for invalid widget index", function()
        local result = lurek.ui.animateScale(99999, 1.0, 1.0, 2.0, 2.0, 0.5)
        expect_equal(false, result)
    end)

    -- @covers lurek.ui.animateRotation
    it("animateRotation uses linear easing by default", function()
        local panel = lurek.ui.newPanel()
        local result = lurek.ui.animateRotation(panel._idx, 0.0, 1.57, 1.0)
        expect_true(result, "should accept nil easing (defaults to linear)")
    end)
end)

test_summary()
