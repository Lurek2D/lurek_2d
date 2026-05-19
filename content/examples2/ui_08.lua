--- UI Part 8: LAccordion, LColorPicker, LProgressBar, LMenuBar

--@api-stub: LAccordion:isExclusive
-- LAccordion: collapsible sections for grouping UI content.
do
    local acc = lurek.ui.newAccordion()
    print("type=" .. acc:type())
    local panel1 = lurek.ui.newPanel()
    local panel2 = lurek.ui.newPanel()
    acc:addSection("Section A", 0)
    acc:addSection("Section B", 1)
    print("count=" .. acc:getSectionCount())
    print("title0=" .. acc:getSectionTitle(0))
    print("expanded0=" .. tostring(acc:isSectionExpanded(0)))
    acc:toggleSection(0)
    print("expanded0_after=" .. tostring(acc:isSectionExpanded(0)))
    print("exclusive=" .. tostring(acc:isExclusive()))
    acc:setExclusive(true)
    print("exclusive_after=" .. tostring(acc:isExclusive()))
end

--@api-stub: LColorPicker:getColor
--@api-stub: LColorPicker:getColorMode
--@api-stub: LColorPicker:getShowAlpha
--@api-stub: LColorPicker:setColor
--@api-stub: LColorPicker:setColorMode
--@api-stub: LColorPicker:setOnChange
--@api-stub: LColorPicker:setShowAlpha
-- LColorPicker: RGBA color selection widget with mode and alpha controls.
do
    local cp = lurek.ui.newColorPicker()
    print("type=" .. cp:type())
    cp:setColor(255, 128, 0, 255)
    local r, g, b, a = cp:getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    print("mode=" .. tostring(cp:getColorMode()))
    cp:setColorMode("hsv")
    print("mode_after=" .. cp:getColorMode())
    print("show_alpha=" .. tostring(cp:getShowAlpha()))
    cp:setShowAlpha(true)
    cp:setOnChange(function(r2, g2, b2, a2) print("changed") end)
end

--@api-stub: LProgressBar:getMax
--@api-stub: LProgressBar:getMin
--@api-stub: LProgressBar:getProgress
--@api-stub: LProgressBar:getValue
--@api-stub: LProgressBar:setRange
--@api-stub: LProgressBar:setValue
-- LProgressBar: numeric progress indicator with configurable range.
do
    local pb = lurek.ui.newProgressBar(0, 100)
    print("type=" .. pb:type())
    print("min=" .. pb:getMin())
    print("max=" .. pb:getMax())
    pb:setValue(75)
    print("value=" .. pb:getValue())
    print("progress=" .. pb:getProgress())
    pb:setRange(0, 200)
    print("max_after=" .. pb:getMax())
end

print("ui_08.lua")
