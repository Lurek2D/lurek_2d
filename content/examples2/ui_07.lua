-- ui_07.lua: Advanced — color picker, radio button, tree view, toast, tooltip, theme, focus, drag/drop

--@api-stub: lurek.ui.newColorPicker
do
    -- create a color picker and select a color
    ---@type LColorPicker
    local cp = lurek.ui.newColorPicker()
    cp:setColor(0.8, 0.2, 0.5, 1.0)
    local r, g, b, a = cp:getColor()
    print("color:", r, g, b, a)
    cp:setColorMode("hsv")
    print("mode:", cp:getColorMode())
    cp:setShowAlpha(true)
    print("show alpha:", cp:getShowAlpha())
end

--@api-stub: lurek.ui.newColorPicker
do
    -- register a change callback on color picker
    ---@type LColorPicker
    local cp = lurek.ui.newColorPicker()
    cp:setOnChange(function(idx)
        print("color changed on widget:", idx)
    end)
    cp:setColor(0.0, 1.0, 0.0)
    print("green set, mode:", cp:getColorMode())
end

--@api-stub: lurek.ui.newRadioButton
do
    -- create mutually exclusive radio buttons in a group
    ---@type LRadioButton
    local rb1 = lurek.ui.newRadioButton("Small", "size_group")
    ---@type LRadioButton
    local rb2 = lurek.ui.newRadioButton("Medium", "size_group")
    ---@type LRadioButton
    local rb3 = lurek.ui.newRadioButton("Large", "size_group")
    rb2:setSelected(true)
    print("rb1 selected:", rb1:isSelected())
    print("rb2 selected:", rb2:isSelected())
    print("rb2 group:", rb2:getGroup())
    print("rb2 text:", rb2:getText())
end

--@api-stub: lurek.ui.newTreeView
do
    -- create a tree view with nested nodes
    ---@type LTreeView
    local tree = lurek.ui.newTreeView()
    local root = tree:addNode("Project")
    local src = tree:addNode("src", root)
    tree:addNode("main.lua", src)
    tree:addNode("utils.lua", src)
    local assets = tree:addNode("assets", root)
    tree:addNode("sprites.png", assets)
    print("total nodes:", tree:getNodeCount())
    print("root text:", tree:getNodeText(root))
    print("src depth:", tree:getNodeDepth(src))
end

--@api-stub: lurek.ui.newTreeView
do
    -- expand and collapse tree nodes
    ---@type LTreeView
    local tree = lurek.ui.newTreeView()
    local folder = tree:addNode("Documents")
    tree:addNode("readme.txt", folder)
    tree:addNode("notes.md", folder)
    tree:expandNode(folder)
    print("expanded:", tree:isExpanded(folder))
    tree:collapseNode(folder)
    print("after collapse:", tree:isExpanded(folder))
    tree:expandAll()
    tree:setSelectedNode(folder)
    print("selected:", tree:getSelectedNode())
end

--@api-stub: lurek.ui.newToast
do
    -- create a toast notification
    ---@type LToast
    local toast = lurek.ui.newToast("File saved!", 2.5)
    print("message:", toast:getMessage())
    print("duration:", toast:getDuration())
    toast:setMessage("Upload complete")
    toast:setDuration(4.0)
    print("updated message:", toast:getMessage())
    print("expired:", toast:isExpired())
end

--@api-stub: lurek.ui.newTooltipPanel
do
    -- create a tooltip panel attached to a button
    ---@type LButton
    local btn = lurek.ui.newButton("Hover me")
    ---@type LTooltipPanel
    local tip = lurek.ui.newTooltipPanel("Click to submit form")
    tip:setDelay(0.5)
    tip:setTarget(1)
    print("tooltip text:", tip:getText())
    print("delay:", tip:getDelay())
    print("target:", tip:getTarget())
    tip:setText("Updated tooltip text")
    print("new text:", tip:getText())
end

--@api-stub: lurek.ui.newTheme
--@api-stub: lurek.ui.setTheme
--@api-stub: lurek.ui.getTheme
do
    -- create and apply a custom theme
    ---@type LTheme
    local theme = lurek.ui.newTheme()
    theme:setStyle("button", "normal", {
        bg_r = 0.2, bg_g = 0.2, bg_b = 0.3, bg_a = 1.0,
        fg_r = 1.0, fg_g = 1.0, fg_b = 1.0, fg_a = 1.0,
    })
    theme:setStyle("button", "hovered", {
        bg_r = 0.3, bg_g = 0.3, bg_b = 0.5, bg_a = 1.0,
    })
    lurek.ui.setTheme(theme)
    print("theme active:", lurek.ui.getTheme())
    print("theme type:", theme:type())
end

--@api-stub: lurek.ui.getFocus
--@api-stub: lurek.ui.focusPrev
--@api-stub: lurek.ui.clearFocus
do
    -- manage keyboard focus between widgets
    ---@type LButton
    local btn1 = lurek.ui.newButton("First")
    ---@type LButton
    local btn2 = lurek.ui.newButton("Second")
    lurek.ui.setFocus(btn1)
    print("focused widget:", lurek.ui.getFocus())
    lurek.ui.focusNext()
    print("after focusNext:", lurek.ui.getFocus())
    lurek.ui.focusPrev()
    print("after focusPrev:", lurek.ui.getFocus())
    lurek.ui.clearFocus()
    print("after clear:", lurek.ui.getFocus())
end

--@api-stub: lurek.ui.beginDrag
--@api-stub: lurek.ui.getActiveDrag
--@api-stub: lurek.ui.dropOn
do
    -- drag and drop a widget onto a target
    ---@type LPanel
    local source = lurek.ui.newPanel()
    ---@type LPanel
    local target = lurek.ui.newPanel()
    lurek.ui.beginDrag(source)
    print("active drag:", lurek.ui.getActiveDrag())
    lurek.ui.dropOn(target)
    print("after drop, active drag:", lurek.ui.getActiveDrag())
end

print("ui_07.lua")
