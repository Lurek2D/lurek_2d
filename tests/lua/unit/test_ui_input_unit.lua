-- tests/lua/integration/test_input_ui.lua
-- Unit: lurek.input <-> lurek.ui
-- Tests that UI widget state responds correctly to input events.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end
-- @describe input + ui integration
describe("input + ui integration", function()
    -- @covers LTextInput.getText
    -- @covers lurek.ui.getFocus
    -- @covers lurek.ui.newTextInput
    -- @covers lurek.ui.setFocus
    -- @covers lurek.ui.textinput
    it("processes keyboard focus to ui widget", function()
        local input = lurek.ui.newTextInput()

        lurek.ui.clearFocus()
        lurek.ui.setFocus(input)
        local consumed = lurek.ui.textinput("a")

        expect_equal("a", input:getText())
        expect_type("number", lurek.ui.getFocus())
        expect_type("boolean", consumed)
    end)

    -- @covers LButton.setOnClick
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.update
    it("routes mouse click to button callback", function()
        local clicked = 0
        local button = lurek.ui.newButton("Play")
        button:setPosition(10, 10)
        button:setSize(120, 40)
        button:setOnClick(function()
            clicked = clicked + 1
        end)

        local pressed = lurek.ui.mousepressed(20, 20, 1)
        local released = lurek.ui.mousereleased(20, 20, 1)
    lurek.ui.update(0.0)

        expect_true(clicked >= 1, "button click callback should run at least once")
        expect_type("boolean", pressed)
        expect_type("boolean", released)
    end)

    -- @covers LUiWidget.addChild
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers LButton.setOnClick
    -- @covers lurek.ui.getRoot
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newPanel
    -- @covers lurek.ui.update
    it("uses computed rectangles for nested button hit tests", function()
        local root = lurek.ui.getRoot()
        local panel = lurek.ui.newPanel()
        panel:setPosition(280, 10)
        panel:setSize(180, 80)
        panel:setZOrder(100)

        local button = lurek.ui.newButton("Nested")
        button:setPosition(20, 15)
        button:setSize(80, 30)
        button:setZOrder(101)

        root:addChild(panel)
        panel:addChild(button)

        local clicked = 0
        button:setOnClick(function()
            clicked = clicked + 1
        end)

        local pressed = lurek.ui.mousepressed(305, 30, 1)
        local released = lurek.ui.mousereleased(305, 30, 1)
        lurek.ui.update(0.0)

        expect_true(pressed, "nested button press should be consumed")
        expect_true(released, "nested button release should be consumed")
        expect_equal(1, clicked)
    end)

    -- @covers LTabBar.addTab
    -- @covers LTabBar.getActiveTab
    -- @covers LUiWidget.setOnChange
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newTabBar
    -- @covers lurek.ui.update
    it("selects tab by mouse click", function()
        local tabs = lurek.ui.newTabBar()
        tabs:setPosition(10, 120)
        tabs:setSize(300, 30)
        tabs:setZOrder(200)
        tabs:addTab("Home")
        tabs:addTab("Reports")
        tabs:addTab("Settings")

        local changed = 0
        tabs:setOnChange(function()
            changed = changed + 1
        end)

        lurek.ui.mousepressed(150, 135, 1)
        lurek.ui.mousereleased(150, 135, 1)
        lurek.ui.update(0.0)

        expect_equal(2, tabs:getActiveTab())
        expect_equal(1, changed)
    end)

    -- @covers LComboBox.addItem
    -- @covers LComboBox.getSelectedIndex
    -- @covers LComboBox.getSelectedItem
    -- @covers LUiWidget.setOnChange
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newComboBox
    -- @covers lurek.ui.update
    it("opens combo box and selects item by mouse", function()
        local combo = lurek.ui.newComboBox()
        combo:setPosition(10, 170)
        combo:setSize(160, 30)
        combo:setZOrder(300)
        combo:addItem("One")
        combo:addItem("Two")
        combo:addItem("Three")

        local changed = 0
        combo:setOnChange(function()
            changed = changed + 1
        end)

        lurek.ui.mousepressed(20, 185, 1)
        lurek.ui.mousereleased(20, 185, 1)
        lurek.ui.mousepressed(20, 245, 1)
        lurek.ui.mousereleased(20, 245, 1)
        lurek.ui.update(0.0)

        expect_equal(2, combo:getSelectedIndex())
        expect_equal("Two", combo:getSelectedItem())
        expect_equal(1, changed)
    end)

    -- @covers LSlider.getValue
    -- @covers LUiWidget.setOnChange
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousemoved
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newSlider
    -- @covers lurek.ui.update
    it("updates slider value on press and drag", function()
        local slider = lurek.ui.newSlider(0, 100)
        slider:setPosition(10, 230)
        slider:setSize(200, 20)
        slider:setZOrder(400)

        local changed = 0
        slider:setOnChange(function()
            changed = changed + 1
        end)

        lurek.ui.mousepressed(60, 240, 1)
        lurek.ui.mousemoved(190, 240)
        lurek.ui.mousereleased(190, 240, 1)
        lurek.ui.update(0.0)

        expect_true(slider:getValue() > 80, "slider drag should move value toward the right edge")
        expect_true(changed >= 1, "slider change callback should run after update")
    end)

    -- @covers LGuiTable.addColumn
    -- @covers LGuiTable.addRow
    -- @covers LGuiTable.getCell
    -- @covers LGuiTable.getSelectedRow
    -- @covers LGuiTable.setOnSelect
    -- @covers LGuiTable.setSortable
    -- @covers LUiWidget.setOnChange
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newTable
    -- @covers lurek.ui.update
    it("selects table rows and sorts by header click", function()
        local table_widget = lurek.ui.newTable()
        table_widget:setPosition(10, 300)
        table_widget:setSize(260, 90)
        table_widget:setZOrder(500)
        table_widget:addColumn("Name", 120)
        table_widget:addColumn("Amount", 80)
        table_widget:addRow({"B", "20"})
        table_widget:addRow({"A", "10"})
        table_widget:addRow({"C", "30"})
        table_widget:setSortable(true)

        local selected_zero_based = -1
        local selected_count = 0
        local sorted_count = 0
        table_widget:setOnSelect(function(_, row_index)
            selected_zero_based = row_index
            selected_count = selected_count + 1
        end)
        table_widget:setOnChange(function()
            sorted_count = sorted_count + 1
        end)

        lurek.ui.mousepressed(20, 352, 1)
        lurek.ui.mousereleased(20, 352, 1)
        lurek.ui.update(0.0)

        expect_equal(2, table_widget:getSelectedRow())
        expect_equal(1, selected_zero_based)
        expect_equal(1, selected_count)

        lurek.ui.mousepressed(20, 310, 1)
        lurek.ui.mousereleased(20, 310, 1)
        lurek.ui.update(0.0)

        expect_equal("A", table_widget:getCell(1, 1))
        expect_equal(1, sorted_count)
    end)

    -- @covers LScrollPanel.getScrollPosition
    -- @covers LScrollPanel.setContentSize
    -- @covers LUiWidget.setPosition
    -- @covers LUiWidget.setSize
    -- @covers lurek.ui.mousemoved
    -- @covers lurek.ui.newScrollPanel
    -- @covers lurek.ui.wheelmoved
    it("scrolls list widget on scroll wheel event", function()
        lurek.ui.clearFocus()
        local panel = lurek.ui.newScrollPanel()
        panel:setPosition(320, 120)
        panel:setSize(120, 80)
        panel:setZOrder(600)
        panel:setContentSize(120, 400)

        local start_x, start_y = panel:getScrollPosition()
        local hovered = lurek.ui.mousemoved(330, 130)
        local consumed = lurek.ui.wheelmoved(0, -4)
        local end_x, end_y = panel:getScrollPosition()

        expect_type("boolean", hovered)
        expect_type("boolean", consumed)
        expect_equal(start_x, end_x)
        expect_true(end_y > start_y, "hovered scroll panel should scroll without focus")
    end)

    -- @covers LTextInput.getCursorPosition
    -- @covers LTextInput.isFocused
    -- @covers LTextInput.setMaxLength
    -- @covers LTextInput.setOnChange
    -- @covers LTextInput.setText
    -- @covers lurek.ui.clearFocus
    -- @covers lurek.ui.keypressed
    -- @covers lurek.ui.setFocus
    -- @covers lurek.ui.textinput
    -- @covers lurek.ui.update
    it("syncs text focus and queues changes only for real edits", function()
        local input = lurek.ui.newTextInput()
        input:setPosition(20, 430)
        input:setSize(160, 30)
        input:setZOrder(1000)

        local changes = 0
        input:setOnChange(function()
            changes = changes + 1
        end)

        lurek.ui.clearFocus()
        expect_false(input:isFocused())

        lurek.ui.setFocus(input)
        expect_true(input:isFocused())
        expect_true(lurek.ui.textinput("ab"))
        lurek.ui.update(0.0)
        expect_equal("ab", input:getText())
        expect_equal(2, input:getCursorPosition())
        expect_equal(1, changes)

        expect_true(lurek.ui.keypressed("left"))
        expect_equal(1, input:getCursorPosition())
        expect_true(lurek.ui.textinput("X"))
        lurek.ui.update(0.0)
        expect_equal("aXb", input:getText())
        expect_equal(2, changes)

        expect_true(lurek.ui.keypressed("home"))
        expect_true(lurek.ui.textinput("Y"))
        lurek.ui.update(0.0)
        expect_equal("YaXb", input:getText())
        expect_equal(3, changes)

        input:setMaxLength(4)
        expect_true(lurek.ui.textinput("Z"))
        lurek.ui.update(0.0)
        expect_equal("YaXb", input:getText())
        expect_equal(3, changes)

        expect_true(lurek.ui.keypressed("end"))
        expect_true(lurek.ui.keypressed("backspace"))
        lurek.ui.update(0.0)
        expect_equal("YaX", input:getText())
        expect_equal(4, changes)

        lurek.ui.clearFocus()
        expect_false(input:isFocused())
    end)

    -- @covers LButton.setOnClick
    -- @covers LMenuItem.setOnClick
    -- @covers LSwitch.isOn
    -- @covers LSwitch.setOnChange
    -- @covers lurek.ui.keypressed
    -- @covers lurek.ui.newButton
    -- @covers lurek.ui.newMenuItem
    -- @covers lurek.ui.newSwitch
    -- @covers lurek.ui.setFocus
    -- @covers lurek.ui.update
    it("activates focused buttons toggles and menu items from keyboard", function()
        local button = lurek.ui.newButton("Keyboard")
        button:setPosition(220, 430)
        button:setSize(120, 32)
        button:setZOrder(1010)

        local button_clicks = 0
        button:setOnClick(function()
            button_clicks = button_clicks + 1
        end)
        lurek.ui.setFocus(button)
        expect_true(lurek.ui.keypressed("return"))
        lurek.ui.update(0.0)
        expect_equal(1, button_clicks)

        local switch = lurek.ui.newSwitch(false)
        switch:setPosition(360, 430)
        switch:setSize(64, 32)
        switch:setZOrder(1020)

        local switch_changes = 0
        switch:setOnChange(function()
            switch_changes = switch_changes + 1
        end)
        lurek.ui.setFocus(switch)
        expect_true(lurek.ui.keypressed("space"))
        lurek.ui.update(0.0)
        expect_true(switch:isOn())
        expect_equal(1, switch_changes)

        local menu_item = lurek.ui.newMenuItem("Open")
        menu_item:setPosition(450, 430)
        menu_item:setSize(100, 30)
        menu_item:setZOrder(1030)

        local menu_clicks = 0
        menu_item:setOnClick(function()
            menu_clicks = menu_clicks + 1
        end)
        lurek.ui.setFocus(menu_item)
        expect_true(lurek.ui.keypressed("space"))
        lurek.ui.update(0.0)
        expect_equal(1, menu_clicks)
    end)

    -- @covers LComboBox.addItem
    -- @covers LComboBox.getSelectedIndex
    -- @covers LListBox.addItem
    -- @covers LListBox.getSelectedIndex
    -- @covers LSlider.getValue
    -- @covers LSlider.setStep
    -- @covers LSpinBox.getValue
    -- @covers LTabBar.addTab
    -- @covers LTabBar.getActiveTab
    -- @covers lurek.ui.keypressed
    -- @covers lurek.ui.newComboBox
    -- @covers lurek.ui.newList
    -- @covers lurek.ui.newSlider
    -- @covers lurek.ui.newSpinBox
    -- @covers lurek.ui.newTabBar
    -- @covers lurek.ui.setFocus
    -- @covers lurek.ui.update
    it("uses arrow keys for focused value and selection widgets", function()
        local slider = lurek.ui.newSlider(0, 100)
        slider:setStep(10)
        slider:setPosition(20, 480)
        slider:setSize(120, 20)
        slider:setZOrder(1040)

        lurek.ui.setFocus(slider)
        expect_true(lurek.ui.keypressed("right"))
        lurek.ui.update(0.0)
        expect_equal(10, slider:getValue())

        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setPosition(160, 480)
        spin:setSize(120, 32)
        spin:setZOrder(1050)

        lurek.ui.setFocus(spin)
        expect_true(lurek.ui.keypressed("up"))
        lurek.ui.update(0.0)
        expect_equal(1, spin:getValue())

        local list = lurek.ui.newList()
        list:setPosition(300, 480)
        list:setSize(120, 80)
        list:setZOrder(1060)
        list:addItem("One")
        list:addItem("Two")
        list:addItem("Three")

        lurek.ui.setFocus(list)
        expect_true(lurek.ui.keypressed("down"))
        expect_true(lurek.ui.keypressed("down"))
        lurek.ui.update(0.0)
        expect_equal(2, list:getSelectedIndex())

        local combo = lurek.ui.newComboBox()
        combo:setPosition(440, 480)
        combo:setSize(120, 30)
        combo:setZOrder(1070)
        combo:addItem("One")
        combo:addItem("Two")
        combo:addItem("Three")

        lurek.ui.setFocus(combo)
        expect_true(lurek.ui.keypressed("down"))
        expect_true(lurek.ui.keypressed("down"))
        lurek.ui.update(0.0)
        expect_equal(2, combo:getSelectedIndex())

        local tabs = lurek.ui.newTabBar()
        tabs:setPosition(580, 480)
        tabs:setSize(180, 28)
        tabs:setZOrder(1080)
        tabs:addTab("A")
        tabs:addTab("B")

        lurek.ui.setFocus(tabs)
        expect_true(lurek.ui.keypressed("right"))
        lurek.ui.update(0.0)
        expect_equal(2, tabs:getActiveTab())
    end)

    -- @covers LComboBox.addItem
    -- @covers LComboBox.getSelectedIndex
    -- @covers LDialog.addButton
    -- @covers LDialog.isOpen
    -- @covers LDialog.open
    -- @covers LDialog.setOnClose
    -- @covers lurek.ui.keypressed
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newComboBox
    -- @covers lurek.ui.newDialog
    -- @covers lurek.ui.update
    it("closes open combo boxes and dialogs with escape", function()
        local combo = lurek.ui.newComboBox()
        combo:setPosition(20, 580)
        combo:setSize(140, 30)
        combo:setZOrder(1090)
        combo:addItem("Alpha")
        combo:addItem("Beta")

        lurek.ui.mousepressed(30, 595, 1)
        lurek.ui.mousereleased(30, 595, 1)
        expect_true(lurek.ui.keypressed("escape"))
        local dropdown_consumed = lurek.ui.mousepressed(30, 635, 1)
        lurek.ui.mousereleased(30, 635, 1)
        lurek.ui.update(0.0)
        expect_false(dropdown_consumed)
        expect_equal(0, combo:getSelectedIndex())

        local dialog = lurek.ui.newDialog("Confirm")
        dialog:setPosition(190, 580)
        dialog:setSize(180, 100)
        dialog:setZOrder(1100)
        dialog:addButton("Close")
        dialog:open()

        local closed = 0
        dialog:setOnClose(function()
            closed = closed + 1
        end)
        expect_true(dialog:isOpen())
        expect_true(lurek.ui.keypressed("escape"))
        lurek.ui.update(0.0)
        expect_false(dialog:isOpen())
        expect_equal(1, closed)
    end)

    -- @covers LRadioButton.isSelected
    -- @covers LRadioButton.setOnChange
    -- @covers LUiWidget.setOnClick
    -- @covers lurek.ui.keypressed
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newRadioButton
    -- @covers lurek.ui.setFocus
    -- @covers lurek.ui.update
    it("selects radio buttons by mouse and keyboard as an exclusive group", function()
        local small = lurek.ui.newRadioButton("Small", "ui_input_size")
        small:setPosition(400, 580)
        small:setSize(120, 24)
        small:setZOrder(1110)

        local large = lurek.ui.newRadioButton("Large", "ui_input_size")
        large:setPosition(400, 610)
        large:setSize(120, 24)
        large:setZOrder(1120)

        local small_changes = 0
        local large_changes = 0
        local large_clicks = 0
        small:setOnChange(function()
            small_changes = small_changes + 1
        end)
        large:setOnChange(function()
            large_changes = large_changes + 1
        end)
        large:setOnClick(function()
            large_clicks = large_clicks + 1
        end)

        lurek.ui.mousepressed(410, 590, 1)
        lurek.ui.mousereleased(410, 590, 1)
        lurek.ui.update(0.0)
        expect_true(small:isSelected())
        expect_false(large:isSelected())
        expect_equal(1, small_changes)

        lurek.ui.setFocus(large)
        expect_true(lurek.ui.keypressed("space"))
        lurek.ui.update(0.0)
        expect_false(small:isSelected())
        expect_true(large:isSelected())
        expect_equal(2, small_changes)
        expect_equal(1, large_changes)
        expect_equal(1, large_clicks)
    end)

    -- @covers LTreeView.addNode
    -- @covers LTreeView.getSelectedNode
    -- @covers LTreeView.isExpanded
    -- @covers LTreeView.setOnChange
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newTreeView
    -- @covers lurek.ui.update
    it("selects and toggles visible tree rows by mouse", function()
        local tree = lurek.ui.newTreeView()
        tree:setPosition(20, 700)
        tree:setSize(180, 90)
        tree:setZOrder(1130)
        local root = tree:addNode("Root", nil)
        local child = tree:addNode("Child", root)

        local changes = 0
        tree:setOnChange(function()
            changes = changes + 1
        end)

        lurek.ui.mousepressed(30, 710, 1)
        lurek.ui.mousereleased(30, 710, 1)
        lurek.ui.update(0.0)
        expect_equal(root, tree:getSelectedNode())
        expect_true(tree:isExpanded(root))
        expect_equal(1, changes)

        lurek.ui.mousepressed(45, 730, 1)
        lurek.ui.mousereleased(45, 730, 1)
        lurek.ui.update(0.0)
        expect_equal(child, tree:getSelectedNode())
        expect_equal(2, changes)
    end)

    -- @covers LSpinBox.getValue
    -- @covers LSpinBox.setOnChange
    -- @covers LSpinBox.setValue
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newSpinBox
    -- @covers lurek.ui.update
    it("increments and decrements spin boxes from mouse step zones", function()
        local spin = lurek.ui.newSpinBox(0, 10)
        spin:setPosition(230, 700)
        spin:setSize(120, 32)
        spin:setZOrder(1140)
        spin:setValue(5)

        local changes = 0
        spin:setOnChange(function()
            changes = changes + 1
        end)

        lurek.ui.mousepressed(340, 708, 1)
        lurek.ui.mousereleased(340, 708, 1)
        lurek.ui.mousepressed(340, 724, 1)
        lurek.ui.mousereleased(340, 724, 1)
        lurek.ui.update(0.0)

        expect_equal(5, spin:getValue())
        expect_equal(2, changes)
    end)

    -- @covers LAccordion.addSection
    -- @covers LAccordion.isSectionExpanded
    -- @covers LAccordion.setExclusive
    -- @covers LAccordion.setOnChange
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newAccordion
    -- @covers lurek.ui.update
    it("toggles accordion headers and respects exclusive mode", function()
        local accordion = lurek.ui.newAccordion()
        accordion:setPosition(390, 700)
        accordion:setSize(180, 120)
        accordion:setZOrder(1150)
        accordion:addSection("Income")
        accordion:addSection("Costs")
        accordion:setExclusive(true)

        local changes = 0
        accordion:setOnChange(function()
            changes = changes + 1
        end)

        lurek.ui.mousepressed(400, 710, 1)
        lurek.ui.mousereleased(400, 710, 1)
        lurek.ui.update(0.0)
        expect_true(accordion:isSectionExpanded(1))
        expect_false(accordion:isSectionExpanded(2))

        lurek.ui.mousepressed(400, 770, 1)
        lurek.ui.mousereleased(400, 770, 1)
        lurek.ui.update(0.0)
        expect_false(accordion:isSectionExpanded(1))
        expect_true(accordion:isSectionExpanded(2))
        expect_equal(2, changes)
    end)

    -- @covers LScrollBar.getScrollPosition
    -- @covers LScrollBar.setContentSize
    -- @covers LScrollBar.setOnChange
    -- @covers LScrollBar.setViewSize
    -- @covers lurek.ui.mousemoved
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newScrollBar
    -- @covers lurek.ui.update
    it("updates scroll bar position from track clicks and drags", function()
        local bar = lurek.ui.newScrollBar(true)
        bar:setPosition(610, 700)
        bar:setSize(20, 100)
        bar:setZOrder(1160)
        bar:setContentSize(300)
        bar:setViewSize(100)

        local changes = 0
        bar:setOnChange(function()
            changes = changes + 1
        end)

        lurek.ui.mousepressed(620, 760, 1)
        local after_click = bar:getScrollPosition()
        lurek.ui.mousemoved(620, 792)
        lurek.ui.mousereleased(620, 792, 1)
        lurek.ui.update(0.0)

        expect_true(after_click > 0, "track click should move the scroll bar")
        expect_true(bar:getScrollPosition() >= after_click, "drag should keep moving downward")
        expect_true(changes >= 1, "scroll bar change callback should run")
    end)

    -- @covers LColorPicker.getColor
    -- @covers LColorPicker.setOnChange
    -- @covers LDialog.addButton
    -- @covers LDialog.isOpen
    -- @covers LDialog.open
    -- @covers LDialog.setOnClose
    -- @covers LGuiWindow.setOnClose
    -- @covers LToolbar.addButton
    -- @covers LToolbar.isButtonToggled
    -- @covers LToolbar.setOnChange
    -- @covers LUiWidget.isVisible
    -- @covers lurek.ui.mousepressed
    -- @covers lurek.ui.mousereleased
    -- @covers lurek.ui.newColorPicker
    -- @covers lurek.ui.newDialog
    -- @covers lurek.ui.newToolbar
    -- @covers lurek.ui.newWindow
    -- @covers lurek.ui.update
    it("handles window close toolbar buttons dialog footer and color picking", function()
        local window = lurek.ui.newWindow("Tools")
        window:setPosition(20, 840)
        window:setSize(160, 90)
        window:setZOrder(1170)

        local window_closed = 0
        window:setOnClose(function()
            window_closed = window_closed + 1
        end)
        lurek.ui.mousepressed(170, 850, 1)
        lurek.ui.mousereleased(170, 850, 1)
        lurek.ui.update(0.0)
        expect_false(window:isVisible())
        expect_equal(1, window_closed)

        local toolbar = lurek.ui.newToolbar("horizontal")
        toolbar:setPosition(220, 840)
        toolbar:setSize(120, 32)
        toolbar:setZOrder(1180)
        toolbar:addButton("bold", "Bold")

        local toolbar_changes = 0
        toolbar:setOnChange(function()
            toolbar_changes = toolbar_changes + 1
        end)
        lurek.ui.mousepressed(230, 856, 1)
        lurek.ui.mousereleased(230, 856, 1)
        lurek.ui.update(0.0)
        expect_true(toolbar:isButtonToggled("bold"))
        expect_equal(1, toolbar_changes)

        local picker = lurek.ui.newColorPicker()
        picker:setPosition(380, 840)
        picker:setSize(100, 100)
        picker:setZOrder(1190)

        local color_changes = 0
        picker:setOnChange(function()
            color_changes = color_changes + 1
        end)
        local start_r, start_g, start_b = picker:getColor()
        lurek.ui.mousepressed(430, 927, 1)
        lurek.ui.mousereleased(430, 927, 1)
        lurek.ui.update(0.0)
        local end_r, end_g, end_b = picker:getColor()
        expect_true(
            start_r ~= end_r or start_g ~= end_g or start_b ~= end_b,
            "hue bar click should update picker color"
        )
        expect_equal(1, color_changes)

        local dialog = lurek.ui.newDialog("Footer")
        dialog:setPosition(520, 840)
        dialog:setSize(180, 100)
        dialog:setZOrder(1200)
        dialog:addButton("Close")
        dialog:open()

        local dialog_closed = 0
        dialog:setOnClose(function()
            dialog_closed = dialog_closed + 1
        end)
        lurek.ui.mousepressed(630, 914, 1)
        lurek.ui.mousereleased(630, 914, 1)
        lurek.ui.update(0.0)
        expect_false(dialog:isOpen())
        expect_equal(1, dialog_closed)
    end)
end)
test_summary()
