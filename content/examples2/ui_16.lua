--@api-stub: LScatterPlot:addSeries
--@api-stub: LScatterPlot:drawToImage
--@api-stub: LScatterPlot:setXRange
-- LScatterPlot series and rendering.
do
    local sp = lurek.ui.newScatterPlot({width = 200, height = 150})
    sp:setXRange(0, 100)
    sp:setYRange(0, 100)
    sp:addSeries("data1", {{10,20},{30,40},{50,30},{70,60}}, 0.9, 0.2, 0.2)
    local img = lurek.image.newImageData(200, 150)
    sp:drawToImage(img)
    print("ScatterPlot addSeries/setXRange/drawToImage ok")
end

--@api-stub: LScatterPlot:setYRange
--@api-stub: LScatterPlot:type
--@api-stub: LScatterPlot:typeOf
-- LScatterPlot axis and type identity.
do
    local sp = lurek.ui.newScatterPlot({width = 100, height = 80})
    sp:setXRange(0, 50)
    sp:setYRange(0, 50)
    local t = sp:type()
    local ok = sp:typeOf("LScatterPlot")
    print("setYRange ok, type:", t, "typeOf:", ok)
end

--@api-stub: LScrollBar.getContentSize
--@api-stub: LScrollBar.getScrollPosition
--@api-stub: LScrollBar.getViewSize
-- LScrollBar size and position queries.
do
    local sb = lurek.ui.newScrollBar(true)
    local cs = sb:getContentSize()
    local pos = sb:getScrollPosition()
    local vs = sb:getViewSize()
    print("contentSize:", cs, "scrollPos:", pos, "viewSize:", vs)
end

--@api-stub: LScrollBar.isVertical
--@api-stub: LScrollBar.setContentSize
--@api-stub: LScrollBar.setOnChange
-- LScrollBar orientation and content control.
do
    local sb = lurek.ui.newScrollBar(false)
    local vert = sb:isVertical()
    sb:setContentSize(500)
    sb:setOnChange(function(val) print("scroll:", val) end)
    local cs = sb:getContentSize()
    print("isVertical:", vert, "contentSize after set:", cs)
end

--@api-stub: LScrollBar.setScrollPosition
--@api-stub: LScrollBar.setViewSize
--@api-stub: LScrollPanel.getContentSize
-- LScrollBar setters and LScrollPanel content size.
do
    local sb = lurek.ui.newScrollBar(true)
    sb:setContentSize(800)
    sb:setViewSize(200)
    sb:setScrollPosition(100)
    local pos = sb:getScrollPosition()
    local sp = lurek.ui.newScrollPanel()
    local cw, ch = sp:getContentSize()
    print("scrollPos:", pos, "panel contentSize:", cw, ch)
end

--@api-stub: LScrollPanel.getMaxScroll
--@api-stub: LScrollPanel.getScrollPosition
--@api-stub: LScrollPanel.getScrollSpeed
-- LScrollPanel scroll queries.
do
    local sp = lurek.ui.newScrollPanel()
    local mx, my = sp:getMaxScroll()
    local px, py = sp:getScrollPosition()
    local speed = sp:getScrollSpeed()
    print("maxScroll:", mx, my, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LScrollPanel.setContentSize
--@api-stub: LScrollPanel.setScrollPosition
--@api-stub: LScrollPanel.setScrollSpeed
-- LScrollPanel setters.
do
    local sp = lurek.ui.newScrollPanel()
    sp:setContentSize(800, 600)
    local cw, ch = sp:getContentSize()
    sp:setScrollPosition(50, 100)
    local px, py = sp:getScrollPosition()
    sp:setScrollSpeed(3.0)
    local speed = sp:getScrollSpeed()
    print("contentSize:", cw, ch, "scrollPos:", px, py, "speed:", speed)
end

--@api-stub: LSeparator.getThickness
--@api-stub: LSeparator.isVertical
--@api-stub: LSeparator.setThickness
-- LSeparator thickness and orientation.
do
    local sep = lurek.ui.newSeparator(true)
    local vert = sep:isVertical()
    local thick = sep:getThickness()
    sep:setThickness(4)
    local t2 = sep:getThickness()
    print("isVertical:", vert, "thickness:", thick, "→", t2)
end

--@api-stub: LSeparator.setVertical
--@api-stub: LSlider.getMax
--@api-stub: LSlider.getMin
-- LSeparator setVertical and LSlider range.
do
    local sep = lurek.ui.newSeparator(false)
    sep:setVertical(true)
    local sl = lurek.ui.newSlider(0, 100)
    local mn = sl:getMin()
    local mx = sl:getMax()
    print("separator setVertical ok; slider min:", mn, "max:", mx)
end

--@api-stub: LSlider.getValue
--@api-stub: LSlider.setRange
--@api-stub: LSlider.setStep
-- LSlider value and range setters.
do
    local sl = lurek.ui.newSlider(0, 50)
    sl:setRange(0, 100)
    local mx = sl:getMax()
    sl:setStep(5)
    sl:setValue(75)
    local v = sl:getValue()
    print("setRange max:", mx, "getValue:", v)
end

--@api-stub: LSlider.setValue
--@api-stub: LSpinBox.decrement
--@api-stub: LSpinBox.getValue
-- LSlider setValue and LSpinBox operations.
do
    local sl = lurek.ui.newSlider(0, 10)
    sl:setValue(7)
    local v = sl:getValue()
    local sb = lurek.ui.newSpinBox(0, 10)
    sb:setValue(5)
    sb:decrement()
    local sv = sb:getValue()
    print("slider value:", v, "spinbox after decrement:", sv)
end

--@api-stub: LSpinBox.increment
--@api-stub: LSpinBox.setRange
--@api-stub: LSpinBox.setStep
-- LSpinBox range and step.
do
    local sb = lurek.ui.newSpinBox(0, 100)
    sb:setValue(10)
    sb:increment()
    local v = sb:getValue()
    sb:setRange(5, 50)
    sb:setStep(2)
    local v2 = sb:getValue()
    print("after increment:", v, "after setRange/setStep:", v2)
end

--@api-stub: LSpinBox.setValue
-- LSpinBox setValue.
do
    local sb = lurek.ui.newSpinBox(1, 100)
    sb:setValue(42)
    local v = sb:getValue()
    sb:setValue(1)
    local v2 = sb:getValue()
    sb:setValue(100)
    local v3 = sb:getValue()
    print("setValue: 42→", v, "1→", v2, "100→", v3)
end

