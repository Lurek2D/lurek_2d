-- Lurek2D UI font integration tests.

-- @describe lurek.ui font selection
describe("lurek.ui font selection", function()
    -- @covers lurek.ui.setFont
    -- @covers lurek.ui.getFont
    -- @covers lurek.ui.clearFont
    it("global UI font can be set and cleared", function()
        local font = lurek.render.newFont("font_12")
        lurek.ui.setFont(font)
        local current = lurek.ui.getFont()
        expect_type("userdata", current)
        lurek.ui.clearFont()
        expect_equal(nil, lurek.ui.getFont())
    end)

    -- @covers LUiWidget.setFont
    -- @covers LUiWidget.clearFont
    -- @covers lurek.ui.getWidgetFont
    it("widget font override can be set and cleared", function()
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
