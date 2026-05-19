--@api-stub: LListBox.addItem
--@api-stub: LListBox.clearItems
--@api-stub: LListBox.getItem
-- LListBox item management.
do
    local lb = lurek.ui.newList()
    lb:addItem("Apple")
    lb:addItem("Banana")
    lb:addItem("Cherry")
    local item = lb:getItem(2)
    lb:clearItems()
    print("addItem/clearItems/getItem ok, item:", item)
end

--@api-stub: LListBox.getItemCount
--@api-stub: LListBox.getSelectedIndex
--@api-stub: LListBox.removeItem
-- LListBox count, selection, and removal.
do
    local lb = lurek.ui.newList()
    lb:addItem("X")
    lb:addItem("Y")
    lb:addItem("Z")
    local cnt = lb:getItemCount()
    lb:setSelectedIndex(2)
    local sel = lb:getSelectedIndex()
    lb:removeItem(1)
    print("count:", cnt, "selectedIndex:", sel, "removeItem ok")
end

--@api-stub: LListBox.setItemHeight
--@api-stub: LListBox.setSelectedIndex
--@api-stub: LMenuBar.addMenu
-- LListBox item height, selection, and LMenuBar addMenu.
do
    local lb = lurek.ui.newList()
    lb:setItemHeight(20)
    lb:addItem("Item")
    lb:setSelectedIndex(1)
    local mb = lurek.ui.newMenuBar()
    local mi = lurek.ui.newMenuItem("File")
    local idx = mb:addMenu(mi._idx)
    print("setItemHeight ok; addMenu idx:", idx)
end

--@api-stub: LMenuBar.getMenuCount
--@api-stub: LMenuBar.getMenus
--@api-stub: LMenuBar.removeMenu
-- LMenuBar menu queries and removal.
do
    local mb = lurek.ui.newMenuBar()
    local mi1 = lurek.ui.newMenuItem("Edit")
    local mi2 = lurek.ui.newMenuItem("View")
    mb:addMenu(mi1._idx)
    mb:addMenu(mi2._idx)
    local cnt = mb:getMenuCount()
    local menus = mb:getMenus()
    mb:removeMenu(1)
    print("menuCount:", cnt, "getMenus ok; removeMenu ok")
end

--@api-stub: LMenuItem.addSubItem
--@api-stub: LMenuItem.getShortcut
--@api-stub: LMenuItem.getSubItems
-- LMenuItem sub-items and shortcut.
do
    local mi = lurek.ui.newMenuItem("Tools")
    local sub1 = lurek.ui.newMenuItem("Options")
    mi:addSubItem(sub1._idx)
    local subs = mi:getSubItems()
    mi:setShortcut("Ctrl+T")
    local sc = mi:getShortcut()
    print("addSubItem ok; getSubItems:", type(subs), "shortcut:", sc)
end

--@api-stub: LMenuItem.getText
--@api-stub: LMenuItem.isChecked
--@api-stub: LMenuItem.setChecked
-- LMenuItem text and checked state.
do
    local mi = lurek.ui.newMenuItem("Enable")
    local t = mi:getText()
    mi:setChecked(true)
    local checked = mi:isChecked()
    mi:setChecked(false)
    print("getText:", t, "isChecked:", mi:isChecked(), "setChecked ok")
end

--@api-stub: LMenuItem.setOnClick
--@api-stub: LMenuItem.setShortcut
--@api-stub: LMenuItem.setText
-- LMenuItem onClick, shortcut, and text setters.
do
    local mi = lurek.ui.newMenuItem("Old")
    mi:setOnClick(function(idx) print("menu clicked", idx) end)
    mi:setShortcut("Alt+F4")
    mi:setText("New Name")
    print("setOnClick/setShortcut/setText ok")
end
