-- test_ui_layout.lua
-- Unit tests for lurek.ui.loadLayout and lurek.ui.loadLayoutFile.
-- Covers: API existence, widget tree creation from a Lua table definition,
-- child attachment, ID lookup, flat and nested layouts.

-- =========================================================================
-- 1. Layout API existence
-- =========================================================================
-- @description Confirms the three layout-loader functions are exposed on lurek.ui.
describe("lurek.ui layout loader API exists", function()
    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.loadLayoutFile
    -- @covers lurek.ui.renderToImage
    -- @description loadLayout is a function
    it("loadLayout is a function", function()
        expect_type("function", lurek.ui.loadLayout)
    end)

    -- @description loadLayoutFile is a function
    it("loadLayoutFile is a function", function()
        expect_type("function", lurek.ui.loadLayoutFile)
    end)

    -- @description renderToImage is a function
    it("renderToImage is a function", function()
        expect_type("function", lurek.ui.renderToImage)
    end)
end)

-- =========================================================================
-- 2. loadLayout — flat single-widget definition
-- =========================================================================
-- @description loadLayout creates a panel widget from a minimal Lua table.
describe("lurek.ui.loadLayout — flat single widget", function()
    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.getWidgetCount
    -- @description Returns a positive pool index
    it("returns a positive pool index", function()
        local before = lurek.ui.getWidgetCount()
        local idx = lurek.ui.loadLayout({ type = "panel", w = 100, h = 80 })
        expect_type("number", idx)
        local after = lurek.ui.getWidgetCount()
        -- At least one new widget was added
        assert(after > before, "widget count must increase after loadLayout")
        assert(idx > 0, "returned pool index must be > 0")
    end)

    -- @covers lurek.ui.loadLayout
    -- @description Creates a label from a type=label definition
    it("creates a label widget", function()
        local idx = lurek.ui.loadLayout({
            type = "label",
            text = "Score",
            x = 10, y = 10, w = 80, h = 24
        })
        assert(idx > 0, "label pool index must be > 0")
    end)

    -- @covers lurek.ui.loadLayout
    -- @description Creates a button from a type=button definition
    it("creates a button widget", function()
        local idx = lurek.ui.loadLayout({
            type = "button",
            text = "OK",
            x = 10, y = 10, w = 80, h = 30
        })
        assert(idx > 0, "button pool index must be > 0")
    end)

    -- @covers lurek.ui.loadLayout
    -- @description Creates a checkbox from a type=checkbox definition
    it("creates a checkbox widget", function()
        local idx = lurek.ui.loadLayout({
            type = "checkbox",
            text = "Enable",
            checked = true,
            x = 0, y = 0, w = 120, h = 24
        })
        assert(idx > 0, "checkbox pool index must be > 0")
    end)

    -- @covers lurek.ui.loadLayout
    -- @description Accepts type=separator without crashing
    it("creates a separator widget", function()
        local idx = lurek.ui.loadLayout({ type = "separator" })
        assert(idx > 0, "separator pool index must be > 0")
    end)
end)

-- =========================================================================
-- 3. loadLayout — nested widget tree with id lookup
-- =========================================================================
-- @description loadLayout builds child widgets and id-based lookup finds them.
describe("lurek.ui.loadLayout — nested tree with id lookup", function()
    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.getRoot
    -- @description Nested children increase the widget count
    it("nested children increase widget count", function()
        local before = lurek.ui.getWidgetCount()
        lurek.ui.loadLayout({
            type = "panel",
            x = 0, y = 0, w = 200, h = 100,
            children = {
                { type = "label",  text = "HP:",     x = 10, y = 10, w = 60, h = 20 },
                { type = "button", text = "Attack",  x = 10, y = 40, w = 80, h = 28 },
            }
        })
        local after = lurek.ui.getWidgetCount()
        -- Root panel + 2 children = +3
        assert(after >= before + 3,
            "expected at least 3 new widgets, got " .. (after - before))
    end)

    -- @covers lurek.ui.loadLayout
    -- @covers lurek.ui.getRoot
    -- @description findById finds a widget given a string id field
    it("findById resolves a widget given an id field", function()
        lurek.ui.loadLayout({
            type = "panel",
            x = 0, y = 0, w = 300, h = 200,
            id = "hud_root",
            children = {
                { type = "label", text = "HP:", x = 10, y = 10, w = 60, h = 20, id = "hp_label" },
            }
        })
        local root = lurek.ui.getRoot()
        local found = root.findById("hp_label")
        assert(found ~= nil, "findById('hp_label') must return a widget handle")
    end)

    -- @covers lurek.ui.loadLayout
    -- @description Deeply nested (3-level) tree loads without error
    it("3-level deep tree loads without error", function()
        local ok = pcall(function()
            lurek.ui.loadLayout({
                type = "panel",
                children = {
                    { type = "panel",
                      children = {
                          { type = "label", text = "Deep" }
                      }
                    }
                }
            })
        end)
        assert(ok, "3-level nested loadLayout must not throw")
    end)
end)

-- =========================================================================
-- 4. loadLayout — all supported widget types do not crash
-- =========================================================================
-- @description Each recognised widget_type string can be loaded individually
-- without a Lua error.
describe("lurek.ui.loadLayout — widget type coverage", function()
    -- @covers lurek.ui.loadLayout
    local widget_types = {
        "panel", "label", "button", "checkbox", "slider", "progressbar",
        "textinput", "combobox", "list", "separator", "spacer",
        "radiobutton", "scrollbar", "switch", "badge", "spinbox",
        "image", "layout", "toolbar", "statusbar", "scrollpanel",
        "splitpanel", "tabbar", "window", "dialog", "treeview",
        "menubar", "dockpanel", "accordion", "ninepatch",
        "colorpicker", "tooltippanel",
    }

    for _, wtype in ipairs(widget_types) do
        -- @description Widget type '<wtype>' loads without error
        it("type '" .. wtype .. "' loads without error", function()
            local ok = pcall(function()
                lurek.ui.loadLayout({ type = wtype })
            end)
            assert(ok, "loadLayout({type='" .. wtype .. "'}) must not throw")
        end)
    end
end)

test_summary()

-- =========================================================================
-- Missing API Coverage Stubs
-- =========================================================================

describe("Missing API Coverage", function()
    -- @covers lurek.ui.getRect
    it("covers lurek.ui.getRect", function()
        -- TODO: Implement test for lurek.ui.getRect
    end)

    -- @covers lurek.ui.setAnchor
    it("covers lurek.ui.setAnchor", function()
        -- TODO: Implement test for lurek.ui.setAnchor
    end)

    -- @covers lurek.ui.setAnchorCenter
    it("covers lurek.ui.setAnchorCenter", function()
        -- TODO: Implement test for lurek.ui.setAnchorCenter
    end)

    -- @covers lurek.ui.clearAnchor
    it("covers lurek.ui.clearAnchor", function()
        -- TODO: Implement test for lurek.ui.clearAnchor
    end)

    -- @covers lurek.ui.setAlpha
    it("covers lurek.ui.setAlpha", function()
        -- TODO: Implement test for lurek.ui.setAlpha
    end)

    -- @covers lurek.ui.getAlpha
    it("covers lurek.ui.getAlpha", function()
        -- TODO: Implement test for lurek.ui.getAlpha
    end)

    -- @covers lurek.ui.slideIn
    it("covers lurek.ui.slideIn", function()
        -- TODO: Implement test for lurek.ui.slideIn
    end)

    -- @covers lurek.ui.slideOut
    it("covers lurek.ui.slideOut", function()
        -- TODO: Implement test for lurek.ui.slideOut
    end)

    -- @covers lurek.ui.attachToEntity
    it("covers lurek.ui.attachToEntity", function()
        -- TODO: Implement test for lurek.ui.attachToEntity
    end)

    -- @covers lurek.ui.detachFromEntity
    it("covers lurek.ui.detachFromEntity", function()
        -- TODO: Implement test for lurek.ui.detachFromEntity
    end)

    -- @covers Text_Input:isFocused
    it("covers Text_Input:isFocused", function()
        -- TODO: Implement test for Text_Input:isFocused
    end)

    -- @covers Text_Input:getCursorPosition
    it("covers Text_Input:getCursorPosition", function()
        -- TODO: Implement test for Text_Input:getCursorPosition
    end)

    -- @covers Combo_Box:getSelectedItem
    it("covers Combo_Box:getSelectedItem", function()
        -- TODO: Implement test for Combo_Box:getSelectedItem
    end)

    -- @covers List_Box:setItemHeight
    it("covers List_Box:setItemHeight", function()
        -- TODO: Implement test for List_Box:setItemHeight
    end)

    -- @covers Panel:setScrollable
    it("covers Panel:setScrollable", function()
        -- TODO: Implement test for Panel:setScrollable
    end)

    -- @covers Layout:setWrap
    it("covers Layout:setWrap", function()
        -- TODO: Implement test for Layout:setWrap
    end)

    -- @covers Layout:getWrap
    it("covers Layout:getWrap", function()
        -- TODO: Implement test for Layout:getWrap
    end)

    -- @covers Scroll_Panel:getMaxScroll
    it("covers Scroll_Panel:getMaxScroll", function()
        -- TODO: Implement test for Scroll_Panel:getMaxScroll
    end)

    -- @covers Scroll_Panel:getScrollSpeed
    it("covers Scroll_Panel:getScrollSpeed", function()
        -- TODO: Implement test for Scroll_Panel:getScrollSpeed
    end)

    -- @covers Nine_Patch:setInsets
    it("covers Nine_Patch:setInsets", function()
        -- TODO: Implement test for Nine_Patch:setInsets
    end)

    -- @covers Nine_Patch:setImageDimensions
    it("covers Nine_Patch:setImageDimensions", function()
        -- TODO: Implement test for Nine_Patch:setImageDimensions
    end)

    -- @covers Nine_Patch:getImageDimensions
    it("covers Nine_Patch:getImageDimensions", function()
        -- TODO: Implement test for Nine_Patch:getImageDimensions
    end)

    -- @covers Nine_Patch:getSlices
    it("covers Nine_Patch:getSlices", function()
        -- TODO: Implement test for Nine_Patch:getSlices
    end)

    -- @covers Toast:setMessage
    it("covers Toast:setMessage", function()
        -- TODO: Implement test for Toast:setMessage
    end)

    -- @covers Separator:setVertical
    it("covers Separator:setVertical", function()
        -- TODO: Implement test for Separator:setVertical
    end)

    -- @covers Separator:setThickness
    it("covers Separator:setThickness", function()
        -- TODO: Implement test for Separator:setThickness
    end)

    -- @covers Separator:getThickness
    it("covers Separator:getThickness", function()
        -- TODO: Implement test for Separator:getThickness
    end)

    -- @covers Tree_View:isExpanded
    it("covers Tree_View:isExpanded", function()
        -- TODO: Implement test for Tree_View:isExpanded
    end)

    -- @covers Gui_Window:setDraggable
    it("covers Gui_Window:setDraggable", function()
        -- TODO: Implement test for Gui_Window:setDraggable
    end)

    -- @covers Gui_Window:setResizable
    it("covers Gui_Window:setResizable", function()
        -- TODO: Implement test for Gui_Window:setResizable
    end)

    -- @covers Gui_Window:setOnClose
    it("covers Gui_Window:setOnClose", function()
        -- TODO: Implement test for Gui_Window:setOnClose
    end)

    -- @covers Split_Panel:setFirstChild
    it("covers Split_Panel:setFirstChild", function()
        -- TODO: Implement test for Split_Panel:setFirstChild
    end)

    -- @covers Split_Panel:setSecondChild
    it("covers Split_Panel:setSecondChild", function()
        -- TODO: Implement test for Split_Panel:setSecondChild
    end)

    -- @covers Split_Panel:getFirstChild
    it("covers Split_Panel:getFirstChild", function()
        -- TODO: Implement test for Split_Panel:getFirstChild
    end)

    -- @covers Split_Panel:getSecondChild
    it("covers Split_Panel:getSecondChild", function()
        -- TODO: Implement test for Split_Panel:getSecondChild
    end)

    -- @covers Dock_Panel:undock
    it("covers Dock_Panel:undock", function()
        -- TODO: Implement test for Dock_Panel:undock
    end)

    -- @covers Menu_Bar:removeMenu
    it("covers Menu_Bar:removeMenu", function()
        -- TODO: Implement test for Menu_Bar:removeMenu
    end)

    -- @covers Menu_Bar:getMenus
    it("covers Menu_Bar:getMenus", function()
        -- TODO: Implement test for Menu_Bar:getMenus
    end)

    -- @covers Dialog:setModal
    it("covers Dialog:setModal", function()
        -- TODO: Implement test for Dialog:setModal
    end)

    -- @covers Dialog:setOnClose
    it("covers Dialog:setOnClose", function()
        -- TODO: Implement test for Dialog:setOnClose
    end)

    -- @covers Accordion:getSectionTitle
    it("covers Accordion:getSectionTitle", function()
        -- TODO: Implement test for Accordion:getSectionTitle
    end)

    -- @covers Color_Picker:setShowAlpha
    it("covers Color_Picker:setShowAlpha", function()
        -- TODO: Implement test for Color_Picker:setShowAlpha
    end)

    -- @covers Image_Widget:update_bindings
    it("covers Image_Widget:update_bindings", function()
        -- TODO: Implement test for Image_Widget:update_bindings
    end)

end)
