--@api-stub: LAccordion.addSection
--@api-stub: LAccordion.getSectionCount
--@api-stub: LAccordion.getSectionTitle
-- LAccordion section management.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Chapter 1")
    acc:addSection("Chapter 2")
    local cnt = acc:getSectionCount()
    local title = acc:getSectionTitle(1)
    print("sections:", cnt, "title:", title)
end

--@api-stub: LAccordion.isExclusive
--@api-stub: LAccordion.isSectionExpanded
--@api-stub: LAccordion.setExclusive
-- LAccordion exclusive mode and expansion.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("A")
    acc:setExclusive(true)
    local ex = acc:isExclusive()
    local expanded = acc:isSectionExpanded(1)
    print("exclusive:", ex, "expanded:", expanded)
end

--@api-stub: LAccordion.toggleSection
--@api-stub: LBadge.getCount
--@api-stub: LBadge.getDisplayText
-- LAccordion toggleSection and LBadge count.
do
    local acc = lurek.ui.newAccordion()
    acc:addSection("Toggle me")
    local newState = acc:toggleSection(1)
    local badge = lurek.ui.newBadge(5)
    local count = badge:getCount()
    local disp = badge:getDisplayText()
    print("toggled:", newState, "badge count:", count, "display:", disp)
end

--@api-stub: LBadge.setCount
--@api-stub: LButton.getText
--@api-stub: LButton.setText
-- LBadge setCount and LButton text.
do
    local badge = lurek.ui.newBadge(0)
    badge:setCount(42)
    local btn = lurek.ui.newButton("Click me")
    local t = btn:getText()
    btn:setText("OK")
    print("badge count:", badge:getCount(), "button text:", btn:getText())
end

--@api-stub: LCheckbox.getText
--@api-stub: LCheckbox.isChecked
--@api-stub: LCheckbox.setChecked
-- LCheckbox text and checked state.
do
    local cb = lurek.ui.newCheckbox("Enable feature")
    local t = cb:getText()
    cb:setChecked(true)
    local checked = cb:isChecked()
    print("checkbox text:", t, "checked:", checked)
end

--@api-stub: LCheckbox.setText
--@api-stub: LAreaChart:addLayer
--@api-stub: LAreaChart:setYMax
-- LCheckbox setText and LAreaChart data.
do
    local cb = lurek.ui.newCheckbox("old")
    cb:setText("new label")
    local chart = lurek.ui.newAreaChart({width = 200, height = 100})
    chart:setYMax(100)
    chart:addLayer("series1", {10, 20, 30, 25, 15}, 1.0, 0.2, 0.2)
    print("checkbox setText ok; addLayer, setYMax ok")
end

--@api-stub: LAreaChart:drawToImage
--@api-stub: LAreaChart:type
--@api-stub: LAreaChart:typeOf
-- LAreaChart rendering and type checks.
do
    local chart = lurek.ui.newAreaChart({width = 64, height = 64})
    chart:setYMax(50)
    chart:addLayer("d", {5, 10, 15}, 0.5, 0.8, 0.2)
    local img = lurek.image.newImageData(64, 64)
    chart:drawToImage(img)
    local t = chart:type()
    local ok = chart:typeOf("LAreaChart")
    print("drawToImage ok, type:", t, "typeOf:", ok)
end

--@api-stub: LBarChart:addCategory
--@api-stub: LBarChart:addSeries
--@api-stub: LBarChart:drawToImage
-- LBarChart series and categories.
do
    local chart = lurek.ui.newBarChart({width = 200, height = 100})
    chart:addSeries("Q1", 0.2, 0.6, 1.0)
    chart:addSeries("Q2", 1.0, 0.5, 0.1)
    chart:addCategory("Jan", {30, 45})
    chart:addCategory("Feb", {40, 35})
    local img = lurek.image.newImageData(200, 100)
    chart:drawToImage(img)
    print("barChart addSeries/addCategory/drawToImage ok")
end

--@api-stub: LBarChart:type
--@api-stub: LBarChart:typeOf
-- LBarChart type checks.
do
    local chart = lurek.ui.newBarChart({width = 100, height = 50})
    local t = chart:type()
    local ok = chart:typeOf("LBarChart")
    local notOk = chart:typeOf("LAreaChart")
    print("LBarChart type:", t, "typeOf:", ok, "typeOf LAreaChart:", notOk)
end
