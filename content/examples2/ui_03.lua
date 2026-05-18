--- UI Module Part 4: lists, menus, tabs, accordion

--@api-stub: lurek.ui.newList
-- Creating a list box.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    print("type = " .. list:type())
    print("items = " .. list:getItemCount())
end

--@api-stub: LListBox:addItem / getItem / getItemCount
-- Populating a list box.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("Sword")
    list:addItem("Shield")
    list:addItem("Potion")
    list:addItem("Scroll")
    print("count = " .. list:getItemCount())
    print("item 1 = " .. list:getItem(1))
    print("item 3 = " .. list:getItem(3))
end

--@api-stub: LListBox:setSelectedIndex / getSelectedIndex
-- Programmatic selection.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("Option A")
    list:addItem("Option B")
    list:addItem("Option C")
    list:setSelectedIndex(2)
    print("selected = " .. list:getSelectedIndex())
    list:setSelectedIndex(3)
    print("changed to = " .. list:getSelectedIndex())
end

--@api-stub: LListBox:removeItem / clearItems / setItemHeight
-- List manipulation and styling.
do
    ---@type LListBox
    local list = lurek.ui.newList()
    list:addItem("First")
    list:addItem("Second")
    list:addItem("Third")
    list:setItemHeight(30)
    list:removeItem(2)
    print("after remove: count=" .. list:getItemCount())
    print("item 2 now = " .. list:getItem(2))
    list:clearItems()
    print("after clear = " .. list:getItemCount())
end

--@api-stub: lurek.ui.newMenuBar
-- Creating a menu bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    print("type = " .. bar:type())
    print("menu count = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newMenuItem
-- Creating a menu item.
do
    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("File")
    print("type = " .. item:type())
    print("text = " .. item:getText())
    item:setShortcut("Ctrl+F")
    print("shortcut = " .. item:getShortcut())
end

--@api-stub: LMenuItem:setText / setOnClick / setChecked / isChecked
-- Configuring menu item behavior.
do
    ---@type LMenuItem
    local item = lurek.ui.newMenuItem("Toggle Grid")
    item:setOnClick(function()
        print("  grid toggle clicked")
    end)
    item:setChecked(true)
    print("checked = " .. tostring(item:isChecked()))
    item:setText("Show Grid")
    print("renamed = " .. item:getText())
end

--@api-stub: LMenuItem:addSubItem / getSubItems
-- Building nested menu hierarchies.
do
    ---@type LMenuItem
    local fileMenu = lurek.ui.newMenuItem("File")
    ---@type LMenuItem
    local openItem = lurek.ui.newMenuItem("Open")
    openItem:setShortcut("Ctrl+O")
    ---@type LMenuItem
    local saveItem = lurek.ui.newMenuItem("Save")
    saveItem:setShortcut("Ctrl+S")
    ---@type LMenuItem
    local exitItem = lurek.ui.newMenuItem("Exit")
    fileMenu:addSubItem(openItem._idx)
    fileMenu:addSubItem(saveItem._idx)
    fileMenu:addSubItem(exitItem._idx)
    local subs = fileMenu:getSubItems()
    print("File has " .. #subs .. " sub-items")
end

--@api-stub: LMenuBar:addMenu / getMenuCount / getMenus
-- Assembling a complete menu bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    ---@type LMenuItem
    local fileMenu = lurek.ui.newMenuItem("File")
    ---@type LMenuItem
    local editMenu = lurek.ui.newMenuItem("Edit")
    ---@type LMenuItem
    local viewMenu = lurek.ui.newMenuItem("View")
    bar:addMenu(fileMenu._idx)
    bar:addMenu(editMenu._idx)
    bar:addMenu(viewMenu._idx)
    print("menus = " .. bar:getMenuCount())
    local menus = bar:getMenus()
    print("menu indices: " .. #menus .. " entries")
end

--@api-stub: LMenuBar:removeMenu
-- Removing a menu from the bar.
do
    ---@type LMenuBar
    local bar = lurek.ui.newMenuBar()
    ---@type LMenuItem
    local m = lurek.ui.newMenuItem("Tools")
    bar:addMenu(m._idx)
    print("before remove = " .. bar:getMenuCount())
    local ok = bar:removeMenu(m._idx)
    print("removed = " .. tostring(ok))
    print("after remove = " .. bar:getMenuCount())
end

--@api-stub: lurek.ui.newTabBar
-- Creating a tab bar.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    print("type = " .. tabs:type())
    print("tab count = " .. tabs:getTabCount())
end

--@api-stub: LTabBar:addTab / getTab / getTabCount
-- Adding tabs.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("General")
    tabs:addTab("Graphics")
    tabs:addTab("Audio")
    tabs:addTab("Controls")
    print("count = " .. tabs:getTabCount())
    print("tab 1 = " .. tabs:getTab(1))
    print("tab 3 = " .. tabs:getTab(3))
end

--@api-stub: LTabBar:setActiveTab / getActiveTab / removeTab
-- Tab selection and removal.
do
    ---@type LTabBar
    local tabs = lurek.ui.newTabBar()
    tabs:addTab("Home")
    tabs:addTab("Settings")
    tabs:addTab("Help")
    tabs:setActiveTab(2)
    print("active = " .. tabs:getActiveTab())
    local ok = tabs:removeTab(3)
    print("removed Help = " .. tostring(ok))
    print("remaining = " .. tabs:getTabCount())
end

--@api-stub: lurek.ui.newAccordion
-- Creating an accordion widget.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    print("type = " .. acc:type())
    print("sections = " .. acc:getSectionCount())
end

--@api-stub: LAccordion:addSection / getSectionCount / getSectionTitle
-- Building accordion sections.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    acc:addSection("Player Stats")
    acc:addSection("Inventory")
    acc:addSection("Quest Log")
    print("sections = " .. acc:getSectionCount())
    print("section 1 = " .. acc:getSectionTitle(1))
    print("section 2 = " .. acc:getSectionTitle(2))
end

--@api-stub: LAccordion:toggleSection / isSectionExpanded / setExclusive
-- Expanding and collapsing sections.
do
    ---@type LAccordion
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:addSection("B")
    acc:addSection("C")
    acc:setExclusive(true)
    print("exclusive = " .. tostring(acc:isExclusive()))
    acc:toggleSection(1)
    print("section 1 expanded = " .. tostring(acc:isSectionExpanded(1)))
    acc:toggleSection(2)
    print("section 1 after toggle 2 = " .. tostring(acc:isSectionExpanded(1)))
    print("section 2 expanded = " .. tostring(acc:isSectionExpanded(2)))
end

print("ui_03.lua")
