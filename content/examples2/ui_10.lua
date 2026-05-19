--- UI Part 10: LBadge, LDockPanel, LImageWidget, LNinePatch, LRadioButton, LSpinBox, LSplitPanel, LSwitch, LTable, LToast, LTooltipPanel, LTreeView

--@api-stub: LBadge:getCount
--@api-stub: LBadge:getDisplayText
--@api-stub: LBadge:setCount
-- LBadge: numeric indicator badge widget.
do
    local badge = lurek.ui.newBadge(3)
    print("type=" .. badge:type())
    print("count=" .. badge:getCount())
    badge:setCount(7)
    print("count_after=" .. badge:getCount())
    local text = badge:getDisplayText()
    print("text=" .. tostring(text))
end

--@api-stub: LDockPanel:dock
--@api-stub: LDockPanel:getDockedCount
--@api-stub: LDockPanel:getSplitSize
--@api-stub: LDockPanel:setSplitSize
-- LDockPanel: dockable panel container supporting four sides.
do
    local dp = lurek.ui.newDockPanel()
    print("type=" .. dp:type())
    local child = lurek.ui.newPanel()
    dp:dock(0, "left")
    print("docked=" .. dp:getDockedCount())
    local sz = dp:getSplitSize("left")
    print("split_size=" .. tostring(sz))
    dp:setSplitSize("left", 150)
    dp:undock(0)
    print("docked_after=" .. dp:getDockedCount())
end

--@api-stub: LImageWidget:getScaleMode
--@api-stub: LImageWidget:getTint
--@api-stub: LImageWidget:setScaleMode
--@api-stub: LImageWidget:setTint
-- LImageWidget: widget that renders an LImage with scale mode and tint.
do
    local iw = lurek.ui.newImageWidget()
    print("type=" .. iw:type())
    print("scale_mode=" .. tostring(iw:getScaleMode()))
    iw:setScaleMode("stretch")
    print("scale_mode_after=" .. iw:getScaleMode())
    iw:setTint(255, 200, 128, 255)
    local r, g, b, a = iw:getTint()
    print("tint=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LNinePatch:getImageDimensions
--@api-stub: LNinePatch:getInsets
--@api-stub: LNinePatch:getSlices
--@api-stub: LNinePatch:setImageDimensions
--@api-stub: LNinePatch:setInsets
-- LNinePatch: nine-patch scalable border widget.
do
    local np = lurek.ui.newNinePatch()
    print("type=" .. np:type())
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    print("img_dim=" .. w .. "x" .. h)
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    print("insets=" .. l .. "," .. t .. "," .. r .. "," .. b)
    local slices = np:getSlices()
    print("slices=" .. tostring(slices ~= nil))
end

--@api-stub: LRadioButton:getGroup
--@api-stub: LRadioButton:getText
--@api-stub: LRadioButton:isSelected
--@api-stub: LRadioButton:setGroup
-- LRadioButton: exclusive toggle within a named group.
do
    local rb1 = lurek.ui.newRadioButton("Option A", "opt_group")
    local rb2 = lurek.ui.newRadioButton("Option B", "opt_group")
    print("type=" .. rb1:type())
    print("text=" .. rb1:getText())
    print("group=" .. rb1:getGroup())
    print("selected=" .. tostring(rb1:isSelected()))
    rb1:setGroup("new_group")
    print("group_after=" .. rb1:getGroup())
end

--@api-stub: LSpinBox:getValue
--@api-stub: LSpinBox:setValue
-- LSpinBox: numeric spin control with configurable step and range.
do
    local sb = lurek.ui.newSpinBox(1, 10)
    print("type=" .. sb:type())
    sb:setValue(5)
    print("value=" .. sb:getValue())
    sb:setStep(2)
    sb:setRange(0, 100)
    sb:increment()
    print("value_after_inc=" .. sb:getValue())
    sb:decrement()
    print("value_after_dec=" .. sb:getValue())
end

--@api-stub: LSplitPanel:getFirstChild
--@api-stub: LSplitPanel:getMinPanelSize
--@api-stub: LSplitPanel:getOrientation
--@api-stub: LSplitPanel:getSecondChild
--@api-stub: LSplitPanel:getSplitPosition
--@api-stub: LSplitPanel:setFirstChild
--@api-stub: LSplitPanel:setMinPanelSize
--@api-stub: LSplitPanel:setOrientation
--@api-stub: LSplitPanel:setSecondChild
--@api-stub: LSplitPanel:setSplitPosition
-- LSplitPanel: resizable two-pane container.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    print("type=" .. sp:type())
    print("orientation=" .. sp:getOrientation())
    sp:setFirstChild(0)
    sp:setSecondChild(1)
    local fc = sp:getFirstChild()
    print("fc=" .. tostring(fc))
    local sc = sp:getSecondChild()
    print("sc=" .. tostring(sc))
    sp:setSplitPosition(200)
    print("split_pos=" .. sp:getSplitPosition())
    sp:setMinPanelSize(80)
    print("min_panel=" .. sp:getMinPanelSize())
    sp:setOrientation("vertical")
    print("orientation_after=" .. sp:getOrientation())
end

--@api-stub: LSwitch:isOn
--@api-stub: LSwitch:setOnChange
-- LSwitch: toggle switch with on/off state and change callback.
do
    local sw = lurek.ui.newSwitch(false)
    print("type=" .. sw:type())
    print("is_on=" .. tostring(sw:isOn()))
    sw:setOn(true)
    print("is_on_after=" .. tostring(sw:isOn()))
    sw:setOnChange(function(v) print("switch_changed=" .. tostring(v)) end)
end

--@api-stub: LGuiTable:addColumn
--@api-stub: LGuiTable:addRow
--@api-stub: LGuiTable:getCell
--@api-stub: LGuiTable:getColumnCount
--@api-stub: LGuiTable:getRowCount
--@api-stub: LGuiTable:getSelectedRow
--@api-stub: LGuiTable:setCell
--@api-stub: LGuiTable:setSelectedRow
--@api-stub: lurek.ui.newTable
-- LGuiTable: multi-column data table with row selection.
do
    local tbl = lurek.ui.newTable()
    print("type=" .. tbl:type())
    tbl:addColumn("Name")
    tbl:addColumn("Score")
    print("cols=" .. tbl:getColumnCount())
    tbl:addRow({ "Alice", "100" })
    tbl:addRow({ "Bob", "80" })
    print("rows=" .. tbl:getRowCount())
    local cell = tbl:getCell(0, 0)
    print("cell00=" .. tostring(cell))
    tbl:setCell(0, 1, "999")
    tbl:setSelectedRow(1)
    print("selected=" .. tbl:getSelectedRow())
end

--@api-stub: LToast:getDuration
--@api-stub: LToast:getMessage
--@api-stub: LToast:getProgress
--@api-stub: LToast:isExpired
--@api-stub: LToast:setDuration
--@api-stub: LToast:setMessage
-- LToast: transient notification message widget.
do
    local toast = lurek.ui.newToast("File saved", 3.0)
    print("type=" .. toast:type())
    print("msg=" .. toast:getMessage())
    print("dur=" .. toast:getDuration())
    print("progress=" .. toast:getProgress())
    print("expired=" .. tostring(toast:isExpired()))
    toast:setMessage("Updated message")
    toast:setDuration(5.0)
    print("msg_after=" .. toast:getMessage())
    print("dur_after=" .. toast:getDuration())
end

--@api-stub: LTooltipPanel:getDelay
--@api-stub: LTooltipPanel:getText
--@api-stub: LTooltipPanel:setDelay
--@api-stub: LTooltipPanel:setText
-- LTooltipPanel: popup tooltip with configurable text and delay.
do
    local ttp = lurek.ui.newTooltipPanel("Hover info")
    print("type=" .. ttp:type())
    print("text=" .. ttp:getText())
    ttp:setText("Updated tooltip")
    print("text_after=" .. ttp:getText())
    ttp:setDelay(0.5)
    print("delay=" .. ttp:getDelay())
end

--@api-stub: LTreeView:addNode
--@api-stub: LTreeView:clearNodes
--@api-stub: LTreeView:collapseAll
--@api-stub: LTreeView:collapseNode
--@api-stub: LTreeView:expandAll
--@api-stub: LTreeView:expandNode
--@api-stub: LTreeView:getChildNodes
--@api-stub: LTreeView:getNodeCount
--@api-stub: LTreeView:getNodeDepth
--@api-stub: LTreeView:getNodeText
--@api-stub: LTreeView:getParentNode
--@api-stub: LTreeView:getSelectedNode
--@api-stub: LTreeView:isExpanded
--@api-stub: LTreeView:isNodeExpanded
--@api-stub: LTreeView:removeNode
--@api-stub: LTreeView:setNodeIcon
--@api-stub: LTreeView:setNodeText
--@api-stub: LTreeView:setSelectedNode
--@api-stub: LTreeView:toggleNode
-- LTreeView: hierarchical node tree with selection and expand/collapse.
do
    local tv = lurek.ui.newTreeView()
    print("type=" .. tv:type())
    local root = tv:addNode("Root", nil)
    local child1 = tv:addNode("Child A", root)
    local child2 = tv:addNode("Child B", root)
    print("nodes=" .. tv:getNodeCount())
    local children = tv:getChildNodes(root)
    print("children=" .. tostring(children ~= nil))
    print("depth=" .. tv:getNodeDepth(child1))
    print("text=" .. tv:getNodeText(child1))
    local parent = tv:getParentNode(child1)
    print("parent=" .. tostring(parent))
    tv:setNodeText(child1, "Renamed A")
    tv:setNodeIcon(child1, "icon_name")
    tv:setSelectedNode(child1)
    print("selected=" .. tostring(tv:getSelectedNode()))
    tv:expandAll()
    print("expanded=" .. tostring(tv:isExpanded(root)))
    print("node_expanded=" .. tostring(tv:isNodeExpanded(root)))
    tv:collapseNode(root)
    tv:expandNode(root)
    tv:toggleNode(child2)
    tv:collapseAll()
    tv:removeNode(child2)
    print("nodes_after=" .. tv:getNodeCount())
    tv:clearNodes()
    print("nodes_cleared=" .. tv:getNodeCount())
end

print("ui_10.lua")
