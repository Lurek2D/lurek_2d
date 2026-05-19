--@api-stub: LNinePatch.getImageDimensions
--@api-stub: LNinePatch.getInsets
--@api-stub: LNinePatch.getSlices
-- LNinePatch dimension and slice queries.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(64, 64)
    local w, h = np:getImageDimensions()
    np:setInsets(8, 8, 8, 8)
    local l, t, r, b = np:getInsets()
    local slices = np:getSlices()
    print("imgDims:", w, h, "insets:", l, t, r, b, "slices:", type(slices))
end

--@api-stub: LNinePatch.setImageDimensions
--@api-stub: LNinePatch.setInsets
--@api-stub: LPanel.getTitle
-- LNinePatch setters and LPanel title.
do
    local np = lurek.ui.newNinePatch()
    np:setImageDimensions(32, 32)
    np:setInsets(4, 4, 4, 4)
    local l, t, r, b = np:getInsets()
    local panel = lurek.ui.newPanel()
    panel:setTitle("My Panel")
    local title = panel:getTitle()
    print("setInsets ok; panel title:", title)
end

--@api-stub: LPanel.setScrollable
--@api-stub: LPanel.setTitle
--@api-stub: LPieChart:addSegment
-- LPanel scrollable/title and LPieChart segment.
do
    local panel = lurek.ui.newPanel()
    panel:setScrollable(true)
    panel:setTitle("Data")
    local pc = lurek.ui.newPieChart({width = 128, height = 128})
    pc:addSegment("A", 30, 0.9, 0.2, 0.2)
    pc:addSegment("B", 50, 0.2, 0.9, 0.2)
    pc:addSegment("C", 20, 0.2, 0.2, 0.9)
    print("panel scrollable ok; pie segments added")
end

--@api-stub: LPieChart:drawToImage
--@api-stub: LPieChart:type
--@api-stub: LPieChart:typeOf
-- LPieChart render and type identity.
do
    local pc = lurek.ui.newPieChart({width = 64, height = 64})
    pc:addSegment("X", 60, 1.0, 0.5, 0.1)
    pc:addSegment("Y", 40, 0.1, 0.5, 1.0)
    local img = lurek.image.newImageData(64, 64)
    pc:drawToImage(img)
    local t = pc:type()
    local ok = pc:typeOf("LPieChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LProgressBar.getMax
--@api-stub: LProgressBar.getMin
--@api-stub: LProgressBar.getProgress
-- LProgressBar range and progress queries.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    local mn = pb:getMin()
    local mx = pb:getMax()
    pb:setValue(75)
    local prog = pb:getProgress()
    print("min:", mn, "max:", mx, "progress:", prog)
end

--@api-stub: LProgressBar.getValue
--@api-stub: LProgressBar.setRange
--@api-stub: LProgressBar.setValue
-- LProgressBar value setters.
do
    local pb = lurek.ui.newProgressBar(0, 200)
    pb:setValue(100)
    local v = pb:getValue()
    pb:setRange(10, 90)
    pb:setValue(50)
    print("getValue:", v, "setRange ok, setValue ok")
end

--@api-stub: LRadioButton.getGroup
--@api-stub: LRadioButton.getText
--@api-stub: LRadioButton.isSelected
-- LRadioButton group, text, and selection.
do
    local rb = lurek.ui.newRadioButton("Option A", "group1")
    local grp = rb:getGroup()
    local t = rb:getText()
    local sel = rb:isSelected()
    print("group:", grp, "text:", t, "isSelected:", sel)
end

--@api-stub: LRadioButton.setGroup
--@api-stub: LRadioButton.setOnChange
--@api-stub: LRadioButton.setSelected
-- LRadioButton setters.
do
    local rb = lurek.ui.newRadioButton("B", "g1")
    rb:setGroup("g2")
    rb:setSelected(true)
    rb:setOnChange(function(idx) print("radio changed", idx) end)
    rb:setText("New B")
    print("setGroup/setSelected/setOnChange/setText ok")
end

--@api-stub: LRadioButton.setText
-- LRadioButton setText verification.
do
    local rb = lurek.ui.newRadioButton("original", "group_test")
    rb:setText("updated")
    print("LRadioButton setText:", rb:getText())
end
