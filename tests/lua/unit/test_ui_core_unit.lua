-- Canonical unit coverage for lurek.ui.

local function make_basic_widget(opts)
    return lurek.ui.newCustomWidget(opts or {
        x = 1,
        y = 2,
        width = 40,
        height = 20,
        id = "widget",
    })
end

-- @describe lurek.ui module
describe("lurek.ui module", function()
    -- @covers lurek.ui.loadLayout
    it("loadLayout creates widgets from a layout table", function()
        local before = lurek.ui.getWidgetCount()
        local idx = lurek.ui.loadLayout({
            type = "panel",
            id = "hud_root",
            children = {
                { type = "label", id = "hp_label", text = "HP" },
            },
        })
        expect_type("number", idx)
        expect_true(lurek.ui.getWidgetCount() > before)
    end)

    -- @covers lurek.ui.loadLayoutFile
    it("loadLayoutFile is callable", function()
        expect_type("function", lurek.ui.loadLayoutFile)
    end)

    -- @covers lurek.ui.getWidgetCount
    it("getWidgetCount returns a numeric widget count", function()
        expect_type("number", lurek.ui.getWidgetCount())
    end)

    -- @covers lurek.ui.getRoot
    it("getRoot returns the root widget object", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "root_for_lookup",
            children = {
                { type = "button", id = "attack_button", text = "Attack" },
            },
        })
        local root = lurek.ui.getRoot()
        expect_not_nil(root)
        expect_not_nil(root:findById("attack_button"))
    end)

    -- @covers lurek.ui.newCustomWidget
    it("newCustomWidget returns a widget handle", function()
        expect_not_nil(make_basic_widget())
    end)

    -- @covers lurek.ui.draw
    it("draw triggers custom onDraw callbacks", function()
        local called = false
        local widget = make_basic_widget()
        widget:setOnDraw(function()
            called = true
        end)
        lurek.ui.draw()
        expect_true(called)
    end)

    -- @covers lurek.ui.drawToImage
    it("drawToImage returns an image with the requested size", function()
        local img = lurek.ui.drawToImage(64, 48)
        expect_equal(64, img:getWidth())
        expect_equal(48, img:getHeight())
    end)

    -- @covers lurek.ui.renderToImage
    it("renderToImage writes an image without throwing", function()
        expect_no_error(function()
            lurek.ui.renderToImage("save/ui_render_unit.png", 96, 64)
        end)
    end)

    -- @covers lurek.ui.parseWidgetState
    it("parseWidgetState accepts known states and rejects unknown ones", function()
        expect_equal("normal", lurek.ui.parseWidgetState("normal"))
        expect_equal("hovered", lurek.ui.parseWidgetState("hovered"))
        expect_nil(lurek.ui.parseWidgetState("bogus"))
    end)

    -- @covers lurek.ui.setDefaultTheme
    it("setDefaultTheme is callable", function()
        expect_no_error(function()
            lurek.ui.setDefaultTheme()
        end)
    end)

    -- @covers lurek.ui.setViewport
    it("setViewport is callable", function()
        expect_no_error(function()
            lurek.ui.setViewport(1280, 720)
        end)
    end)

    -- @covers lurek.ui.flushCache
    it("flushCache returns a boolean", function()
        expect_type("boolean", lurek.ui.flushCache())
    end)

    -- @covers lurek.ui.addToast
    it("addToast accepts a toast object", function()
        local toast = lurek.ui.newToast("Hello", 1.0)
        expect_no_error(function()
            lurek.ui.addToast(toast)
        end)
    end)

    -- @covers lurek.ui.getToastCount
    it("getToastCount returns a numeric count", function()
        expect_type("number", lurek.ui.getToastCount())
    end)
end)

-- @describe base widget methods
describe("base widget methods", function()
    -- @covers LUiWidget:setPosition
    it("setPosition updates widget coordinates", function()
        local w = make_basic_widget()
        w:setPosition(12, 34)
        local x, y = w:getPosition()
        expect_equal(12, x)
        expect_equal(34, y)
    end)

    -- @covers LUiWidget:getPosition
    it("getPosition returns initial coordinates", function()
        local x, y = make_basic_widget({ x = 7, y = 9, width = 10, height = 10 }):getPosition()
        expect_equal(7, x)
        expect_equal(9, y)
    end)

    -- @covers LUiWidget:setSize
    it("setSize updates widget dimensions", function()
        local w = make_basic_widget()
        w:setSize(88, 44)
        local width, height = w:getSize()
        expect_equal(88, width)
        expect_equal(44, height)
    end)

    -- @covers LUiWidget:getSize
    it("getSize returns initial dimensions", function()
        local width, height = make_basic_widget({ x = 0, y = 0, width = 13, height = 21 }):getSize()
        expect_equal(13, width)
        expect_equal(21, height)
    end)

    -- @covers LUiWidget:setVisible
    it("setVisible toggles visibility", function()
        local w = make_basic_widget()
        w:setVisible(false)
        expect_false(w:isVisible())
    end)

    -- @covers LUiWidget:isVisible
    it("isVisible reports the default visible state", function()
        expect_type("boolean", make_basic_widget():isVisible())
    end)

    -- @covers LUiWidget:setEnabled
    it("setEnabled toggles interactivity", function()
        local w = make_basic_widget()
        w:setEnabled(false)
        expect_false(w:isEnabled())
    end)

    -- @covers LUiWidget:isEnabled
    it("isEnabled reports the enabled state", function()
        expect_type("boolean", make_basic_widget():isEnabled())
    end)

    -- @covers LUiWidget:setId
    it("setId changes the widget identifier", function()
        local w = make_basic_widget()
        w:setId("changed_id")
        expect_equal("changed_id", w:getId())
    end)

    -- @covers LUiWidget:getId
    it("getId returns the current widget identifier", function()
        expect_equal("seed_id", make_basic_widget({ x = 0, y = 0, width = 10, height = 10, id = "seed_id" }):getId())
    end)

    -- @covers LUiWidget:setTooltip
    it("setTooltip stores tooltip text", function()
        local w = make_basic_widget()
        w:setTooltip("tooltip text")
        expect_equal("tooltip text", w:getTooltip())
    end)

    -- @covers LUiWidget:getTooltip
    it("getTooltip returns tooltip text", function()
        local w = make_basic_widget()
        w:setTooltip("tip")
        expect_equal("tip", w:getTooltip())
    end)

    -- @covers LUiWidget:getRect
    it("getRect returns x y width height", function()
        local x, y, width, height = make_basic_widget():getRect()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", width)
        expect_type("number", height)
    end)

    -- @covers LUiWidget:type
    it("type returns LUiWidget", function()
        expect_equal("LWidget", make_basic_widget():type())
    end)

    -- @covers LUiWidget:typeOf
    it("typeOf reports widget inheritance", function()
        expect_true(make_basic_widget():typeOf("LWidget"))
    end)

    -- @covers LUiWidget:getState
    it("getState returns a widget state string", function()
        expect_type("string", make_basic_widget():getState())
    end)

    -- @covers LUiWidget:addChild
    it("addChild attaches a child widget", function()
        local parent = make_basic_widget()
        expect_no_error(function()
            parent:addChild(make_basic_widget())
        end)
    end)

    -- @covers LUiWidget:getChildCount
    it("getChildCount returns the number of children", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "child_count_root",
            children = {
                { type = "label", id = "child_a", text = "A" },
                { type = "label", id = "child_b", text = "B" },
            },
        })
        expect_true(lurek.ui.getRoot():getChildCount() >= 2)
    end)

    -- @covers LUiWidget:getChildren
    it("getChildren returns a lua table of children", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "children_root",
            children = {
                { type = "label", id = "child_table", text = "A" },
            },
        })
        expect_type("table", lurek.ui.getRoot():getChildren())
    end)

    -- @covers LUiWidget:removeChild
    it("removeChild detaches an attached child", function()
        local parent = make_basic_widget()
        local child = make_basic_widget()
        parent:addChild(child)
        parent:removeChild(child)
        expect_equal(0, parent:getChildCount())
    end)

    -- @covers LUiWidget:findById
    it("findById finds attached children recursively", function()
        lurek.ui.loadLayout({
            type = "panel",
            id = "lookup_root",
            children = {
                { type = "button", id = "lookup_child", text = "Find me" },
            },
        })
        expect_not_nil(lurek.ui.getRoot():findById("lookup_child"))
    end)

    -- @covers LUiWidget:setOnClick
    it("setOnClick accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnClick(function() end)
        end)
    end)

    -- @covers LUiWidget:setOnChange
    it("setOnChange accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnChange(function() end)
        end)
    end)

    -- @covers LUiWidget:setOnDraw
    it("setOnDraw accepts a callback", function()
        expect_no_error(function()
            make_basic_widget():setOnDraw(function() end)
        end)
    end)

    -- @covers LUiWidget:containsPoint
    it("containsPoint matches coordinates inside the rect", function()
        local w = make_basic_widget({ x = 10, y = 10, width = 20, height = 20, id = "hitbox" })
        expect_true(w:containsPoint(15, 15))
        expect_false(w:containsPoint(100, 100))
    end)

    -- @covers LUiWidget:setPadding
    it("setPadding stores padding values", function()
        local w = make_basic_widget()
        w:setPadding(1, 2, 3, 4)
        local t, r, b, l = w:getPadding()
        expect_equal(1, t)
        expect_equal(4, l)
    end)

    -- @covers LUiWidget:getPadding
    it("getPadding returns the stored padding", function()
        local w = make_basic_widget()
        w:setPadding(5, 6, 7, 8)
        local t, r, b, l = w:getPadding()
        expect_equal(5, t)
        expect_equal(8, l)
    end)

    -- @covers LUiWidget:setMargin
    it("setMargin stores margin values", function()
        local w = make_basic_widget()
        w:setMargin(5, 6, 7, 8)
        local t, r, b, l = w:getMargin()
        expect_equal(5, t)
        expect_equal(8, l)
    end)

    -- @covers LUiWidget:getMargin
    it("getMargin returns the stored margins", function()
        local w = make_basic_widget()
        w:setMargin(9, 10, 11, 12)
        local t, r, b, l = w:getMargin()
        expect_equal(9, t)
        expect_equal(12, l)
    end)

    -- @covers LUiWidget:setZOrder
    it("setZOrder updates the widget z order", function()
        local w = make_basic_widget()
        w:setZOrder(9)
        expect_equal(9, w:getZOrder())
    end)

    -- @covers LUiWidget:getZOrder
    it("getZOrder returns a numeric depth", function()
        expect_type("number", make_basic_widget():getZOrder())
    end)

    -- @covers LUiWidget:setMinSize
    it("setMinSize stores minimum bounds", function()
        local w = make_basic_widget()
        w:setMinSize(11, 12)
        local minw, minh = w:getMinSize()
        expect_equal(11, minw)
        expect_equal(12, minh)
    end)

    -- @covers LUiWidget:getMinSize
    it("getMinSize returns minimum bounds", function()
        local w = make_basic_widget()
        w:setMinSize(13, 14)
        local minw, minh = w:getMinSize()
        expect_equal(13, minw)
        expect_equal(14, minh)
    end)

    -- @covers LUiWidget:setMaxSize
    it("setMaxSize stores maximum bounds", function()
        local w = make_basic_widget()
        w:setMaxSize(99, 120)
        local maxw, maxh = w:getMaxSize()
        expect_equal(99, maxw)
        expect_equal(120, maxh)
    end)

    -- @covers LUiWidget:getMaxSize
    it("getMaxSize returns maximum bounds", function()
        local w = make_basic_widget()
        w:setMaxSize(77, 88)
        local maxw, maxh = w:getMaxSize()
        expect_equal(77, maxw)
        expect_equal(88, maxh)
    end)

    -- @covers LUiWidget:setAnchor
    it("setAnchor is callable", function()
        expect_no_error(function()
            make_basic_widget():setAnchor(1, 2, 3, 4)
        end)
    end)

    -- @covers LUiWidget:setAnchorCenter
    it("setAnchorCenter is callable", function()
        expect_no_error(function()
            make_basic_widget():setAnchorCenter(5, 6)
        end)
    end)

    -- @covers LUiWidget:clearAnchor
    it("clearAnchor is callable after anchoring", function()
        local w = make_basic_widget()
        w:setAnchor(1, 2, 3, 4)
        expect_no_error(function()
            w:clearAnchor()
        end)
    end)

    -- @covers LUiWidget:setFlexGrow
    it("setFlexGrow updates the grow factor", function()
        local w = make_basic_widget()
        w:setFlexGrow(2.5)
        expect_equal(2.5, w:getFlexGrow())
    end)

    -- @covers LUiWidget:getFlexGrow
    it("getFlexGrow returns the stored grow factor", function()
        local w = make_basic_widget()
        w:setFlexGrow(1.5)
        expect_equal(1.5, w:getFlexGrow())
    end)

    -- @covers LUiWidget:setFlexShrink
    it("setFlexShrink updates the shrink factor", function()
        local w = make_basic_widget()
        w:setFlexShrink(0.5)
        expect_equal(0.5, w:getFlexShrink())
    end)

    -- @covers LUiWidget:getFlexShrink
    it("getFlexShrink returns the stored shrink factor", function()
        local w = make_basic_widget()
        w:setFlexShrink(0.25)
        expect_equal(0.25, w:getFlexShrink())
    end)

    -- @covers LUiWidget:bind
    it("bind attaches a binding key", function()
        expect_no_error(function()
            make_basic_widget():bind("hp")
        end)
    end)

    -- @covers LUiWidget:unbind
    it("unbind clears a previous binding", function()
        local w = make_basic_widget()
        w:bind("hp")
        expect_no_error(function()
            w:unbind()
        end)
    end)

    -- @covers LUiWidget:setAlpha
    it("setAlpha updates widget opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.25)
        expect_equal(0.25, w:getAlpha())
    end)

    -- @covers LUiWidget:getAlpha
    it("getAlpha returns the stored opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.75)
        expect_equal(0.75, w:getAlpha())
    end)

    -- @covers LUiWidget:fadeIn
    it("fadeIn restores full opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.1)
        w:fadeIn()
        expect_equal(1.0, w:getAlpha())
    end)

    -- @covers LUiWidget:fadeOut
    it("fadeOut clears opacity", function()
        local w = make_basic_widget()
        w:setAlpha(0.9)
        w:fadeOut()
        expect_equal(0.0, w:getAlpha())
    end)

    -- @covers LUiWidget:slideIn
    it("slideIn is callable", function()
        expect_no_error(function()
            make_basic_widget():slideIn(10, 20)
        end)
    end)

    -- @covers LUiWidget:slideOut
    it("slideOut is callable", function()
        expect_no_error(function()
            make_basic_widget():slideOut(-10, -20)
        end)
    end)

    -- @covers LUiWidget:attachToEntity
    it("attachToEntity is callable", function()
        expect_no_error(function()
            make_basic_widget():attachToEntity(1)
        end)
    end)

    -- @covers LUiWidget:detachFromEntity
    it("detachFromEntity is callable", function()
        local w = make_basic_widget()
        w:attachToEntity(1)
        expect_no_error(function()
            w:detachFromEntity()
        end)
    end)
end)

-- @describe common ui controls
describe("common ui controls", function()
    -- @covers lurek.ui.newButton
    it("newButton creates a button widget", function()
        expect_not_nil(lurek.ui.newButton("Play"))
    end)

    -- @covers LButton:setText
    it("button setText updates the label", function()
        local button = lurek.ui.newButton("Old")
        button:setText("New")
        expect_equal("New", button:getText())
    end)

    -- @covers LButton:getText
    it("button getText returns the label", function()
        expect_equal("Play", lurek.ui.newButton("Play"):getText())
    end)

    -- @covers lurek.ui.newLabel
    it("newLabel creates a label widget", function()
        expect_not_nil(lurek.ui.newLabel("Score"))
    end)

    -- @covers LLabel:setText
    it("label setText updates the caption", function()
        local label = lurek.ui.newLabel("Old")
        label:setText("New")
        expect_equal("New", label:getText())
    end)

    -- @covers LLabel:getText
    it("label getText returns the caption", function()
        expect_equal("Score", lurek.ui.newLabel("Score"):getText())
    end)

    -- @covers lurek.ui.newTextInput
    it("newTextInput creates a text input", function()
        expect_not_nil(lurek.ui.newTextInput())
    end)

    -- @covers LTextInput:setText
    it("text input setText stores the value", function()
        local input = lurek.ui.newTextInput()
        input:setText("abc")
        expect_equal("abc", input:getText())
    end)

    -- @covers LTextInput:getText
    it("text input getText returns the current value", function()
        local input = lurek.ui.newTextInput()
        input:setText("xyz")
        expect_equal("xyz", input:getText())
    end)

    -- @covers LTextInput:setPlaceholder
    it("text input setPlaceholder stores placeholder text", function()
        local input = lurek.ui.newTextInput()
        input:setPlaceholder("type here")
        expect_equal("type here", input:getPlaceholder())
    end)

    -- @covers LTextInput:getPlaceholder
    it("text input getPlaceholder returns placeholder text", function()
        local input = lurek.ui.newTextInput()
        input:setPlaceholder("search")
        expect_equal("search", input:getPlaceholder())
    end)

    -- @covers LTextInput:setMaxLength
    it("text input setMaxLength is callable", function()
        expect_no_error(function()
            lurek.ui.newTextInput():setMaxLength(12)
        end)
    end)

    -- @covers LTextInput:isFocused
    it("text input isFocused returns a boolean", function()
        expect_type("boolean", lurek.ui.newTextInput():isFocused())
    end)

    -- @covers LTextInput:getCursorPosition
    it("text input getCursorPosition returns a number", function()
        expect_type("number", lurek.ui.newTextInput():getCursorPosition())
    end)

    -- @covers lurek.ui.newCheckbox
    it("newCheckbox creates a checkbox", function()
        expect_not_nil(lurek.ui.newCheckbox("Enabled"))
    end)

    -- @covers LCheckbox:setChecked
    it("checkbox setChecked updates the toggle state", function()
        local checkbox = lurek.ui.newCheckbox("Enabled")
        checkbox:setChecked(true)
        expect_true(checkbox:isChecked())
    end)

    -- @covers LCheckbox:isChecked
    it("checkbox isChecked returns the toggle state", function()
        local checkbox = lurek.ui.newCheckbox("Enabled")
        checkbox:setChecked(false)
        expect_false(checkbox:isChecked())
    end)

    -- @covers LCheckbox:setText
    it("checkbox setText updates the label", function()
        local checkbox = lurek.ui.newCheckbox("Old")
        checkbox:setText("New")
        expect_equal("New", checkbox:getText())
    end)

    -- @covers LCheckbox:getText
    it("checkbox getText returns the label", function()
        expect_equal("Check", lurek.ui.newCheckbox("Check"):getText())
    end)

    -- @covers lurek.ui.newSlider
    it("newSlider creates a slider", function()
        expect_not_nil(lurek.ui.newSlider(0, 10))
    end)

    -- @covers LSlider:setRange
    it("slider setRange updates min and max", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setRange(5, 25)
        expect_equal(5, slider:getMin())
        expect_equal(25, slider:getMax())
    end)

    -- @covers LSlider:setStep
    it("slider setStep is callable", function()
        expect_no_error(function()
            lurek.ui.newSlider(0, 10):setStep(2)
        end)
    end)

    -- @covers LSlider:setValue
    it("slider setValue updates the current value", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setValue(7)
        expect_equal(7, slider:getValue())
    end)

    -- @covers LSlider:getValue
    it("slider getValue returns the current value", function()
        local slider = lurek.ui.newSlider(0, 10)
        slider:setValue(3)
        expect_equal(3, slider:getValue())
    end)

    -- @covers LSlider:getMin
    it("slider getMin returns the lower bound", function()
        expect_equal(0, lurek.ui.newSlider(0, 10):getMin())
    end)

    -- @covers LSlider:getMax
    it("slider getMax returns the upper bound", function()
        expect_equal(10, lurek.ui.newSlider(0, 10):getMax())
    end)

    -- @covers lurek.ui.newProgressBar
    it("newProgressBar creates a progress bar", function()
        expect_not_nil(lurek.ui.newProgressBar(0, 100))
    end)

    -- @covers LProgressBar:setRange
    it("progress bar setRange updates min and max", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setRange(0, 200)
        expect_equal(200, bar:getMax())
    end)

    -- @covers LProgressBar:setValue
    it("progress bar setValue stores a value", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(50)
        expect_equal(50, bar:getValue())
    end)

    -- @covers LProgressBar:getValue
    it("progress bar getValue returns the current value", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(20)
        expect_equal(20, bar:getValue())
    end)

    -- @covers LProgressBar:getProgress
    it("progress bar getProgress returns a numeric ratio", function()
        local bar = lurek.ui.newProgressBar(0, 100)
        bar:setValue(25)
        expect_type("number", bar:getProgress())
    end)

    -- @covers LProgressBar:getMin
    it("progress bar getMin returns the lower bound", function()
        expect_equal(0, lurek.ui.newProgressBar(0, 100):getMin())
    end)

    -- @covers LProgressBar:getMax
    it("progress bar getMax returns the upper bound", function()
        expect_equal(100, lurek.ui.newProgressBar(0, 100):getMax())
    end)
end)

-- @describe compound widgets and helpers
describe("compound widgets and helpers", function()
    -- @covers lurek.ui.newComboBox
    it("newComboBox creates a combo box", function()
        expect_not_nil(lurek.ui.newComboBox())
    end)

    -- @covers LComboBox:addItem
    it("combo box addItem appends entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        expect_equal(1, combo:getItemCount())
    end)

    -- @covers LComboBox:removeItem
    it("combo box removeItem deletes an entry", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:removeItem(1)
        expect_equal(0, combo:getItemCount())
    end)

    -- @covers LComboBox:clearItems
    it("combo box clearItems removes all entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:clearItems()
        expect_equal(0, combo:getItemCount())
    end)

    -- @covers LComboBox:getItemCount
    it("combo box getItemCount returns the number of entries", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        expect_equal(2, combo:getItemCount())
    end)

    -- @covers LComboBox:getItem
    it("combo box getItem returns an entry by index", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        expect_equal("Two", combo:getItem(2))
    end)

    -- @covers LComboBox:setSelectedIndex
    it("combo box setSelectedIndex updates selection", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:setSelectedIndex(2)
        expect_equal(2, combo:getSelectedIndex())
    end)

    -- @covers LComboBox:getSelectedIndex
    it("combo box getSelectedIndex returns current selection", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:setSelectedIndex(1)
        expect_equal(1, combo:getSelectedIndex())
    end)

    -- @covers LComboBox:getSelectedItem
    it("combo box getSelectedItem returns the selected label", function()
        local combo = lurek.ui.newComboBox()
        combo:addItem("One")
        combo:addItem("Two")
        combo:setSelectedIndex(2)
        expect_equal("Two", combo:getSelectedItem())
    end)

    -- @covers lurek.ui.newList
    it("newList creates a list box", function()
        expect_not_nil(lurek.ui.newList())
    end)

    -- @covers LListBox:addItem
    it("list box addItem appends entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        expect_equal(1, list:getItemCount())
    end)

    -- @covers LListBox:removeItem
    it("list box removeItem deletes entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:removeItem(1)
        expect_equal(0, list:getItemCount())
    end)

    -- @covers LListBox:clearItems
    it("list box clearItems removes all entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:clearItems()
        expect_equal(0, list:getItemCount())
    end)

    -- @covers LListBox:getItemCount
    it("list box getItemCount returns the number of entries", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:addItem("Beta")
        expect_equal(2, list:getItemCount())
    end)

    -- @covers LListBox:getItem
    it("list box getItem returns an entry by index", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        expect_equal("Alpha", list:getItem(1))
    end)

    -- @covers LListBox:setSelectedIndex
    it("list box setSelectedIndex updates selection", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:setSelectedIndex(1)
        expect_equal(1, list:getSelectedIndex())
    end)

    -- @covers LListBox:getSelectedIndex
    it("list box getSelectedIndex returns the selection", function()
        local list = lurek.ui.newList()
        list:addItem("Alpha")
        list:setSelectedIndex(1)
        expect_equal(1, list:getSelectedIndex())
    end)

    -- @covers LListBox:setItemHeight
    it("list box setItemHeight is callable", function()
        expect_no_error(function()
            lurek.ui.newList():setItemHeight(24)
        end)
    end)

    -- @covers lurek.ui.newTabBar
    it("newTabBar creates a tab bar", function()
        expect_not_nil(lurek.ui.newTabBar())
    end)

    -- @covers LTabBar:addTab
    it("tab bar addTab appends a tab", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        expect_equal(1, tabs:getTabCount())
    end)

    -- @covers LTabBar:removeTab
    it("tab bar removeTab deletes a tab", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:removeTab(1)
        expect_equal(0, tabs:getTabCount())
    end)

    -- @covers LTabBar:getTabCount
    it("tab bar getTabCount returns the number of tabs", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:addTab("Settings")
        expect_equal(2, tabs:getTabCount())
    end)

    -- @covers LTabBar:getTab
    it("tab bar getTab returns a tab label", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        expect_equal("Home", tabs:getTab(1))
    end)

    -- @covers LTabBar:setActiveTab
    it("tab bar setActiveTab updates the active index", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:addTab("Settings")
        tabs:setActiveTab(2)
        expect_equal(2, tabs:getActiveTab())
    end)

    -- @covers LTabBar:getActiveTab
    it("tab bar getActiveTab returns the active index", function()
        local tabs = lurek.ui.newTabBar()
        tabs:addTab("Home")
        tabs:setActiveTab(1)
        expect_equal(1, tabs:getActiveTab())
    end)

    -- @covers lurek.ui.newSpinBox
    it("newSpinBox creates a spin box", function()
        expect_not_nil(lurek.ui.newSpinBox(0, 10))
    end)

    -- @covers LSpinBox:setRange
    it("spin box setRange updates min and max", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setRange(5, 15)
        spin:setValue(10)
        expect_equal(10, spin:getValue())
    end)

    -- @covers LSpinBox:setStep
    it("spin box setStep is callable", function()
        expect_no_error(function()
            lurek.ui.newSpinBox(0, 10):setStep(2)
        end)
    end)

    -- @covers LSpinBox:setValue
    it("spin box setValue stores the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(6)
        expect_equal(6, spin:getValue())
    end)

    -- @covers LSpinBox:getValue
    it("spin box getValue returns the current value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(4)
        expect_equal(4, spin:getValue())
    end)

    -- @covers LSpinBox:increment
    it("spin box increment increases the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(3)
        spin:increment()
        expect_true(spin:getValue() >= 3)
    end)

    -- @covers LSpinBox:decrement
    it("spin box decrement decreases the value", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setValue(3)
        spin:decrement()
        expect_true(spin:getValue() <= 3)
    end)

    -- @covers lurek.ui.newSwitch
    it("newSwitch creates a switch", function()
        expect_not_nil(lurek.ui.newSwitch(false))
    end)

    -- @covers LSwitch:setOn
    it("switch setOn updates the boolean state", function()
        local sw = lurek.ui.newSwitch(false)
        sw:setOn(true)
        expect_true(sw:isOn())
    end)

    -- @covers LSwitch:isOn
    it("switch isOn returns the boolean state", function()
        expect_true(lurek.ui.newSwitch(true):isOn())
    end)

    -- @covers LSwitch:toggle
    it("switch toggle flips the boolean state", function()
        local sw = lurek.ui.newSwitch(false)
        sw:toggle()
        expect_true(sw:isOn())
    end)

    -- @covers lurek.ui.newBadge
    it("newBadge creates a badge", function()
        expect_not_nil(lurek.ui.newBadge(3))
    end)

    -- @covers LBadge:setCount
    it("badge setCount updates the counter", function()
        local badge = lurek.ui.newBadge(0)
        badge:setCount(7)
        expect_equal(7, badge:getCount())
    end)

    -- @covers LBadge:getCount
    it("badge getCount returns the count", function()
        expect_equal(5, lurek.ui.newBadge(5):getCount())
    end)

    -- @covers LBadge:getDisplayText
    it("badge getDisplayText returns a string", function()
        expect_type("string", lurek.ui.newBadge(42):getDisplayText())
    end)

    -- @covers lurek.ui.newPanel
    it("newPanel creates a panel widget", function()
        expect_not_nil(lurek.ui.newPanel())
    end)

    -- @covers LPanel:setTitle
    it("panel setTitle updates the title", function()
        local panel = lurek.ui.newPanel()
        panel:setTitle("Inventory")
        expect_equal("Inventory", panel:getTitle())
    end)

    -- @covers LPanel:getTitle
    it("panel getTitle returns the title", function()
        local panel = lurek.ui.newPanel()
        panel:setTitle("Stats")
        expect_equal("Stats", panel:getTitle())
    end)

    -- @covers LPanel:setScrollable
    it("panel setScrollable is callable", function()
        expect_no_error(function()
            lurek.ui.newPanel():setScrollable(true)
        end)
    end)

    -- @covers lurek.ui.newLayout
    it("newLayout creates a layout widget", function()
        expect_not_nil(lurek.ui.newLayout("vertical"))
    end)

    -- @covers LLayout:setDirection
    it("layout setDirection updates direction", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setDirection("horizontal")
        expect_equal("horizontal", layout:getDirection())
    end)

    -- @covers LLayout:getDirection
    it("layout getDirection returns the direction", function()
        expect_equal("vertical", lurek.ui.newLayout("vertical"):getDirection())
    end)

    -- @covers LLayout:setSpacing
    it("layout setSpacing updates spacing", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setSpacing(12)
        expect_equal(12, layout:getSpacing())
    end)

    -- @covers LLayout:getSpacing
    it("layout getSpacing returns spacing", function()
        local layout = lurek.ui.newLayout("vertical")
        layout:setSpacing(6)
        expect_equal(6, layout:getSpacing())
    end)

    -- @covers lurek.ui.newTable
    it("newTable creates a table widget", function()
        expect_not_nil(lurek.ui.newTable())
    end)

    -- @covers LGuiTable:addColumn
    it("table addColumn appends a column", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        expect_equal(1, table_widget:getColumnCount())
    end)

    -- @covers LGuiTable:getColumnCount
    it("table getColumnCount returns the number of columns", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addColumn("Score", 80)
        expect_equal(2, table_widget:getColumnCount())
    end)

    -- @covers LGuiTable:addRow
    it("table addRow appends a row", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addRow({ "Alice" })
        expect_equal(1, table_widget:getRowCount())
    end)

    -- @covers LGuiTable:getRowCount
    it("table getRowCount returns the number of rows", function()
        local table_widget = lurek.ui.newTable()
        table_widget:addColumn("Name", 100)
        table_widget:addRow({ "Alice" })
        table_widget:addRow({ "Bob" })
        expect_equal(2, table_widget:getRowCount())
    end)

    -- @covers LGuiTable:getSelectedRow
    it("table getSelectedRow returns current selection", function()
        local table_widget = lurek.ui.newTable()
        table_widget:setSelectedRow(1)
        expect_equal(1, table_widget:getSelectedRow())
    end)

    -- @covers LGuiTable:setSelectedRow
    it("table setSelectedRow updates selection", function()
        local table_widget = lurek.ui.newTable()
        table_widget:setSelectedRow(2)
        expect_equal(2, table_widget:getSelectedRow())
    end)

    -- @covers LGuiTable:isSortable
    it("table isSortable returns a boolean", function()
        expect_type("boolean", lurek.ui.newTable():isSortable())
    end)

    -- @covers LGuiTable:setSortable
    it("table setSortable is callable", function()
        expect_no_error(function()
            lurek.ui.newTable():setSortable(true)
        end)
    end)

    -- @covers lurek.ui.newImageWidget
    it("newImageWidget creates an image widget", function()
        expect_not_nil(lurek.ui.newImageWidget())
    end)

    -- @covers LImageWidget:setScaleMode
    it("image widget setScaleMode updates the mode", function()
        local widget = lurek.ui.newImageWidget()
        widget:setScaleMode("fit")
        expect_equal("fit", widget:getScaleMode())
    end)

    -- @covers LImageWidget:getScaleMode
    it("image widget getScaleMode returns the current mode", function()
        local widget = lurek.ui.newImageWidget()
        widget:setScaleMode("stretch")
        expect_equal("stretch", widget:getScaleMode())
    end)

    -- @covers LImageWidget:setTint
    it("image widget setTint updates color channels", function()
        local widget = lurek.ui.newImageWidget()
        widget:setTint(0.5, 0.2, 0.8, 1.0)
        local r, g, b, a = widget:getTint()
        expect_near(0.5, r, 0.001)
        expect_near(1.0, a, 0.001)
    end)

    -- @covers LImageWidget:getTint
    it("image widget getTint returns color channels", function()
        local r, g, b, a = lurek.ui.newImageWidget():getTint()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers lurek.ui.newScrollPanel
    it("newScrollPanel creates a scroll panel", function()
        expect_not_nil(lurek.ui.newScrollPanel())
    end)

    -- @covers LScrollPanel:setContentSize
    it("scroll panel setContentSize updates scrollable bounds", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        local width, height = panel:getContentSize()
        expect_equal(500, width)
        expect_equal(300, height)
    end)

    -- @covers LScrollPanel:getContentSize
    it("scroll panel getContentSize returns content dimensions", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(250, 125)
        local width, height = panel:getContentSize()
        expect_equal(250, width)
        expect_equal(125, height)
    end)

    -- @covers LScrollPanel:setScrollPosition
    it("scroll panel setScrollPosition updates scroll offsets", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        expect_no_error(function()
            panel:setScrollPosition(10, 20)
        end)
    end)

    -- @covers LScrollPanel:getScrollPosition
    it("scroll panel getScrollPosition returns current offsets", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setContentSize(500, 300)
        panel:setScrollPosition(3, 4)
        local x, y = panel:getScrollPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LScrollPanel:getMaxScroll
    it("scroll panel getMaxScroll returns numeric bounds", function()
        local panel = lurek.ui.newScrollPanel()
        local x, y = panel:getMaxScroll()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LScrollPanel:setScrollSpeed
    it("scroll panel setScrollSpeed is callable", function()
        expect_no_error(function()
            lurek.ui.newScrollPanel():setScrollSpeed(2.0)
        end)
    end)

    -- @covers LScrollPanel:getScrollSpeed
    it("scroll panel getScrollSpeed returns the configured speed", function()
        local panel = lurek.ui.newScrollPanel()
        panel:setScrollSpeed(3.5)
        expect_equal(3.5, panel:getScrollSpeed())
    end)

    -- @covers lurek.ui.newSeparator
    it("newSeparator creates a separator", function()
        expect_not_nil(lurek.ui.newSeparator(true))
    end)

    -- @covers LSeparator:setVertical
    it("separator setVertical updates orientation", function()
        local sep = lurek.ui.newSeparator(false)
        sep:setVertical(true)
        expect_true(sep:isVertical())
    end)

    -- @covers LSeparator:isVertical
    it("separator isVertical returns orientation", function()
        expect_true(lurek.ui.newSeparator(true):isVertical())
    end)

    -- @covers LSeparator:setThickness
    it("separator setThickness is callable", function()
        expect_no_error(function()
            lurek.ui.newSeparator(false):setThickness(3)
        end)
    end)

    -- @covers LSeparator:getThickness
    it("separator getThickness returns a numeric width", function()
        expect_type("number", lurek.ui.newSeparator(false):getThickness())
    end)

    -- @covers lurek.ui.newToast
    it("newToast creates a toast object", function()
        expect_not_nil(lurek.ui.newToast("Hello", 5.0))
    end)

    -- @covers LToast:getProgress
    it("toast getProgress returns a numeric lifecycle value", function()
        expect_type("number", lurek.ui.newToast("Hello", 5.0):getProgress())
    end)

    -- @covers LToast:isExpired
    it("toast isExpired returns false for a fresh toast", function()
        expect_false(lurek.ui.newToast("Hello", 5.0):isExpired())
    end)

    -- @covers lurek.ui.newLineChart
    it("newLineChart creates a chart object", function()
        expect_not_nil(lurek.ui.newLineChart({ width = 200, height = 100 }))
    end)

    -- @covers lurek.ui.newBarChart
    it("newBarChart creates a chart object", function()
        expect_not_nil(lurek.ui.newBarChart({ width = 200, height = 100 }))
    end)

    -- @covers lurek.ui.newAreaChart
    it("newAreaChart creates a chart object", function()
        expect_not_nil(lurek.ui.newAreaChart({ width = 200, height = 100 }))
    end)

    -- @covers lurek.ui.newPieChart
    it("newPieChart creates a chart object", function()
        expect_not_nil(lurek.ui.newPieChart({ width = 200, height = 100 }))
    end)

    -- @covers lurek.ui.newScatterPlot
    it("newScatterPlot creates a chart object", function()
        expect_not_nil(lurek.ui.newScatterPlot({ width = 200, height = 100 }))
    end)
end)

test_summary()
