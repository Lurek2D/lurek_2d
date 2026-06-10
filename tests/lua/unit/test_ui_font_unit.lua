-- Lurek2D UI font integration tests.

-- @describe lurek.ui font selection
describe("lurek.ui font selection", function()
    -- @covers lurek.ui.setFont
    it("setFont stores the global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        expect_type("userdata", lurek.ui.getFont())
    end)

    -- @covers lurek.ui.getFont
    it("getFont returns the configured global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        local current = lurek.ui.getFont()
        expect_type("userdata", current)
    end)

    -- @covers lurek.ui.clearFont
    it("clearFont removes the global UI font", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        lurek.ui.clearFont()
        expect_equal(nil, lurek.ui.getFont())
    end)

    -- @covers lurek.ui.getWidgetFont
    it("getWidgetFont returns the widget override and then nil after clear", function()
        local widget = lurek.ui.newCustomWidget({ x = 1, y = 2, width = 32, height = 16 })
        local font = lurek.render.newFont("fontb_10")
        widget:setFont(font)
        local current = lurek.ui.getWidgetFont(widget)
        expect_type("userdata", current)
        widget:clearFont()
        expect_equal(nil, lurek.ui.getWidgetFont(widget))
    end)
end)
test_summary()
