--@api-stub: LSplitPanel.getFirstChild
--@api-stub: LSplitPanel.getMinPanelSize
--@api-stub: LSplitPanel.getOrientation
-- LSplitPanel child and orientation queries.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    local fc = sp:getFirstChild()
    local sc = sp:getSecondChild()
    local ori = sp:getOrientation()
    local mps = sp:getMinPanelSize()
    print("firstChild:", fc, "secondChild:", sc, "orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.getSecondChild
--@api-stub: LSplitPanel.getSplitPosition
--@api-stub: LSplitPanel.setFirstChild
-- LSplitPanel setters and split position.
do
    local sp = lurek.ui.newSplitPanel("vertical")
    local lbl = lurek.ui.newLabel("left")
    local btn = lurek.ui.newButton("right")
    sp:setFirstChild(lbl:getId() and 1 or 1)
    local fc = sp:getFirstChild()
    sp:setSecondChild(btn:getId() and 2 or 2)
    local pos = sp:getSplitPosition()
    print("firstChild after set:", fc, "splitPos:", pos)
end

--@api-stub: LSplitPanel.setMinPanelSize
--@api-stub: LSplitPanel.setOrientation
--@api-stub: LSplitPanel.setSecondChild
-- LSplitPanel orientation and min size.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setOrientation("vertical")
    local ori = sp:getOrientation()
    sp:setMinPanelSize(80)
    local mps = sp:getMinPanelSize()
    local lbl = lurek.ui.newLabel("panel")
    sp:setSecondChild(lbl:getId() and 1 or 1)
    print("orientation:", ori, "minPanel:", mps)
end

--@api-stub: LSplitPanel.setSplitPosition
--@api-stub: LStatusBar.addSection
--@api-stub: LStatusBar.getSectionCount
-- LSplitPanel position and LStatusBar sections.
do
    local sp = lurek.ui.newSplitPanel("horizontal")
    sp:setSplitPosition(200)
    local pos = sp:getSplitPosition()
    local sb = lurek.ui.newStatusBar()
    sb:addSection("Ready", 100)
    local cnt = sb:getSectionCount()
    print("splitPos:", pos, "statusBar sectionCount:", cnt)
end

--@api-stub: LStatusBar.getSectionText
--@api-stub: LStatusBar.setSectionCount
--@api-stub: LStatusBar.setSectionText
-- LStatusBar text manipulation.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(3)
    local cnt = sb:getSectionCount()
    sb:setSectionText(1, "Line 1")
    local txt = sb:getSectionText(1)
    sb:setSectionText(2, "Col 5")
    print("sectionCount:", cnt, "section1:", txt)
end

--@api-stub: LStatusBar.setSectionWidget
--@api-stub: LSwitch.isOn
--@api-stub: LSwitch.setOn
-- LStatusBar widget and LSwitch state.
do
    local sb = lurek.ui.newStatusBar()
    sb:setSectionCount(2)
    local lbl = lurek.ui.newLabel("status")
    sb:setSectionWidget(1, lbl)
    local sw = lurek.ui.newSwitch(false)
    local on = sw:isOn()
    sw:setOn(true)
    print("sectionWidget set ok; switch isOn:", sw:isOn())
end

--@api-stub: LSwitch.toggle
--@api-stub: LTabBar.addTab
--@api-stub: LTabBar.getActiveTab
-- LSwitch toggle and LTabBar add.
do
    local sw = lurek.ui.newSwitch(false)
    sw:toggle()
    local on = sw:isOn()
    local tb = lurek.ui.newTabBar()
    tb:addTab("Tab 1")
    tb:addTab("Tab 2")
    local active = tb:getActiveTab()
    print("switch after toggle:", on, "activeTab:", active)
end

--@api-stub: LTabBar.getTab
--@api-stub: LTabBar.getTabCount
--@api-stub: LTabBar.removeTab
-- LTabBar queries.
do
    local tb = lurek.ui.newTabBar()
    tb:addTab("Alpha")
    tb:addTab("Beta")
    tb:addTab("Gamma")
    local cnt = tb:getTabCount()
    local label = tb:getTab(1)
    tb:removeTab(3)
    local cnt2 = tb:getTabCount()
    print("tabCount:", cnt, "tab1:", label, "after remove:", cnt2)
end

--@api-stub: LTabBar.setActiveTab
-- LTabBar setActiveTab.
do
    local tb = lurek.ui.newTabBar()
    tb:addTab("First")
    tb:addTab("Second")
    tb:setActiveTab(2)
    local active = tb:getActiveTab()
    tb:setActiveTab(1)
    local a2 = tb:getActiveTab()
    print("setActiveTab to 2:", active, "then to 1:", a2)
end
