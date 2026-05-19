--@api-stub: LUiWidget.setFlexGrow
--@api-stub: LUiWidget.setFlexShrink
--@api-stub: LUiWidget.setId
-- LUiWidget flex and id setters.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(3)
    local fg = w:getFlexGrow()
    w:setFlexShrink(0)
    local fs = w:getFlexShrink()
    w:setId("flex-widget")
    local id = w:getId()
    print("flexGrow:", fg, "flexShrink:", fs, "id:", id)
end

--@api-stub: LUiWidget.setMargin
--@api-stub: LUiWidget.setMaxSize
--@api-stub: LUiWidget.setMinSize
-- LUiWidget margin and size limits.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(2, 4, 2, 4)
    local mt = w:getMargin()
    w:setMaxSize(500, 400)
    local mxw = w:getMaxSize()
    w:setMinSize(60, 30)
    local mnw = w:getMinSize()
    print("margin set ok; maxSize:", mxw, "minSize:", mnw)
end

--@api-stub: LUiWidget.setOnChange
--@api-stub: LUiWidget.setOnClick
--@api-stub: LUiWidget.setOnDraw
-- LUiWidget callbacks.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setOnChange(function() print("changed") end)
    w:setOnClick(function() print("clicked") end)
    w:setOnDraw(function() print("drawing") end)
    local id = w:getId()
    local vis = w:isVisible()
    print("setOnChange/setOnClick/setOnDraw ok; id:", id, "vis:", vis)
end

--@api-stub: LUiWidget.setPadding
--@api-stub: LUiWidget.setPosition
--@api-stub: LUiWidget.setSize
-- LUiWidget layout setters.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(6, 6, 6, 6)
    local pt = w:getPadding()
    w:setPosition(50, 100)
    local px, py = w:getPosition()
    w:setSize(200, 100)
    local sw, sh = w:getSize()
    print("padding:", pt, "position:", px, py, "size:", sw, sh)
end

--@api-stub: LUiWidget.setTooltip
--@api-stub: LUiWidget.setVisible
--@api-stub: LUiWidget.setZOrder
-- LUiWidget tooltip, visibility, z-order.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setTooltip("my tooltip")
    local tip = w:getTooltip()
    w:setVisible(false)
    w:setVisible(true)
    w:setZOrder(10)
    local z = w:getZOrder()
    print("tooltip:", tip, "zOrder:", z)
end

--@api-stub: LUiWidget.slideIn
--@api-stub: LUiWidget.slideOut
--@api-stub: LUiWidget.type
-- LUiWidget slide animations and type.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:slideIn(0, -50)
    w:slideOut(0, 50)
    local t = w:type()
    local ok = w:typeOf("LUiWidget")
    w:unbind()
    print("slideIn/slideOut ok; type:", t, "typeOf:", ok)
end

--@api-stub: LUiWidget.typeOf
--@api-stub: LUiWidget.unbind
-- LUiWidget typeOf and unbind.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:bind("click")
    w:unbind()
    local ok1 = w:typeOf("LUiWidget")
    local ok2 = w:typeOf("LButton")
    local t = w:type()
    print("typeOf LUiWidget:", ok1, "typeOf LButton:", ok2, "type:", t)
end
