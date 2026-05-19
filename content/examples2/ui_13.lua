--@api-stub: LGuiTable.getCell
-- LGuiTable column, row, and cell access.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Name", 100)
    tbl:addColumn("Value", 80)
    tbl:addRow({"Alice", "42"})
    tbl:addRow({"Bob", "99"})
    local cell = tbl:getCell(1, 1)
    print("addColumn/addRow/getCell ok, cell:", cell)
end

--@api-stub: LGuiTable.getColumnCount
--@api-stub: LGuiTable.getRowCount
--@api-stub: LGuiTable.getSelectedRow
-- LGuiTable counts and selection.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("Col1")
    tbl:addColumn("Col2")
    tbl:addRow({"A", "1"})
    tbl:addRow({"B", "2"})
    local cols = tbl:getColumnCount()
    local rows = tbl:getRowCount()
    local sel = tbl:getSelectedRow()
    print("cols:", cols, "rows:", rows, "selectedRow:", sel)
end

--@api-stub: LGuiTable.isSortable
--@api-stub: LGuiTable.setCell
--@api-stub: LGuiTable.setOnSelect
-- LGuiTable sortable, setCell, and onSelect.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("ID")
    tbl:addRow({"1"})
    tbl:setSortable(true)
    tbl:setCell(1, 1, "changed")
    tbl:setOnSelect(function(idx) print("row selected", idx) end)
    print("isSortable/setCell/setOnSelect ok")
end

--@api-stub: LGuiTable.setSelectedRow
--@api-stub: LGuiTable.setSortable
--@api-stub: LGuiWindow.getTitle
-- LGuiTable setSelectedRow, setSortable, and LGuiWindow title.
do
    local tbl = lurek.ui.newTable()
    tbl:addColumn("X")
    tbl:addRow({"row1"})
    tbl:setSelectedRow(1)
    local sel = tbl:getSelectedRow()
    tbl:setSortable(false)
    local win = lurek.ui.newWindow("My Window")
    local title = win:getTitle()
    print("setSelectedRow:", sel, "setSortable ok, win title:", title)
end

--@api-stub: LGuiWindow.isCloseable
--@api-stub: LGuiWindow.isDraggable
--@api-stub: LGuiWindow.isResizable
-- LGuiWindow capability queries.
do
    local win = lurek.ui.newWindow("Test Win")
    local closeable = win:isCloseable()
    local draggable = win:isDraggable()
    local resizable = win:isResizable()
    print("isCloseable:", closeable, "isDraggable:", draggable, "isResizable:", resizable)
end

--@api-stub: LGuiWindow.setCloseable
--@api-stub: LGuiWindow.setDraggable
--@api-stub: LGuiWindow.setOnClose
-- LGuiWindow capability setters and onClose.
do
    local win = lurek.ui.newWindow("Config")
    win:setCloseable(true)
    win:setDraggable(true)
    win:setOnClose(function(idx) print("window closed", idx) end)
    print("setCloseable/setDraggable/setOnClose ok")
end

--@api-stub: LGuiWindow.setResizable
--@api-stub: LGuiWindow.setTitle
--@api-stub: LImageWidget.getScaleMode
-- LGuiWindow setResizable, setTitle, and LImageWidget scaleMode.
do
    local win = lurek.ui.newWindow("Old")
    win:setResizable(false)
    win:setTitle("New Title")
    local iw = lurek.ui.newImageWidget()
    local mode = iw:getScaleMode()
    print("setResizable/setTitle ok; scaleMode:", mode)
end

--@api-stub: LImageWidget.getTint
--@api-stub: LImageWidget.setScaleMode
--@api-stub: LImageWidget.setTint
-- LImageWidget tint and scale mode.
do
    local iw = lurek.ui.newImageWidget()
    iw:setTint(1.0, 0.5, 0.25, 1.0)
    local r, g, b, a = iw:getTint()
    iw:setScaleMode("fit")
    print("tint:", r, g, b, a, "scaleMode: fit")
end

--@api-stub: LLabel.getText
--@api-stub: LLabel.setText
--@api-stub: LLayout.getAlign
-- LLabel text and LLayout align.
do
    local lbl = lurek.ui.newLabel("Hello")
    lbl:setText("World")
    local layout = lurek.ui.newLayout("horizontal")
    local align = layout:getAlign()
    print("label text:", lbl:getText(), "layout align:", align)
end

--@api-stub: LLayout.getDirection
--@api-stub: LLayout.getJustify
--@api-stub: LLayout.getSpacing
-- LLayout direction, justify, spacing.
do
    local layout = lurek.ui.newLayout("vertical")
    local dir = layout:getDirection()
    local justify = layout:getJustify()
    local spacing = layout:getSpacing()
    print("direction:", dir, "justify:", justify, "spacing:", spacing)
end

--@api-stub: LLayout.getWrap
--@api-stub: LLayout.setAlign
--@api-stub: LLayout.setColumns
-- LLayout wrap, setAlign, setColumns.
do
    local layout = lurek.ui.newLayout("grid")
    local wrap = layout:getWrap()
    layout:setAlign("center")
    layout:setColumns(3)
    print("getWrap:", wrap, "setAlign: center, setColumns: 3 ok")
end

--@api-stub: LLayout.setDirection
--@api-stub: LLayout.setJustify
--@api-stub: LLayout.setSpacing
-- LLayout direction, justify, spacing setters.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setDirection("vertical")
    layout:setJustify("center")
    layout:setSpacing(8)
    print("setDirection/setJustify/setSpacing ok")
end

--@api-stub: LLayout.setWrap
--@api-stub: LLineChart:addSeries
--@api-stub: LLineChart:drawToImage
-- LLayout setWrap and LLineChart data.
do
    local layout = lurek.ui.newLayout("horizontal")
    layout:setWrap(true)
    local lc = lurek.ui.newLineChart({width = 200, height = 100})
    lc:addSeries("speed", {{1,10},{2,20},{3,15}}, 0.2, 0.8, 0.4)
    local img = lurek.image.newImageData(200, 100)
    lc:drawToImage(img)
    print("setWrap ok; addSeries/drawToImage ok")
end

--@api-stub: LLineChart:setXMax
--@api-stub: LLineChart:setYMax
--@api-stub: LLineChart:type
-- LLineChart axis limits and type.
do
    local lc = lurek.ui.newLineChart({width = 150, height = 80})
    lc:setXMax(100)
    lc:setYMax(50)
    lc:addSeries("data", {{0,0},{100,50}}, 1.0, 0.2, 0.2)
    local t = lc:type()
    print("setXMax/setYMax ok; type:", t)
end

--@api-stub: LLineChart:typeOf
-- LLineChart typeOf.
do
    local lc = lurek.ui.newLineChart({width = 100, height = 60})
    local ok = lc:typeOf("LLineChart")
    local notOk = lc:typeOf("LBarChart")
    print("LLineChart typeOf:", ok, "typeOf LBarChart:", notOk)
end
