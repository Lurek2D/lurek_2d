--@api-stub: LUiWidget.getMargin
--@api-stub: LUiWidget.getMaxSize
--@api-stub: LUiWidget.getMinSize
-- LUiWidget margin and size constraints.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setMargin(4, 8, 4, 8)
    local mt, mr, mb, ml = w:getMargin()
    w:setMaxSize(400, 300)
    local mxw, mxh = w:getMaxSize()
    w:setMinSize(50, 25)
    local mnw, mnh = w:getMinSize()
    print("margin:", mt, mr, mb, ml, "max:", mxw, mxh, "min:", mnw, mnh)
end

--@api-stub: LUiWidget.getPadding
--@api-stub: LUiWidget.getPosition
--@api-stub: LUiWidget.getRect
-- LUiWidget padding, position, rect.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setPadding(5, 5, 5, 5)
    local pt, pr, pb, pl = w:getPadding()
    w:setPosition(30, 40)
    local px, py = w:getPosition()
    local rx, ry, rw, rh = w:getRect()
    print("padding:", pt, "position:", px, py, "rect:", rx, ry, rw, rh)
end

--@api-stub: LUiWidget.getSize
--@api-stub: LUiWidget.getState
--@api-stub: LUiWidget.getTooltip
-- LUiWidget size, state, tooltip.
do
    local w = lurek.ui.newCustomWidget({width=120, height=60})
    w:setSize(150, 80)
    local sw, sh = w:getSize()
    local state = w:getState()
    w:setTooltip("hover tip")
    local tip = w:getTooltip()
    print("size:", sw, sh, "state:", state, "tooltip:", tip)
end

--@api-stub: LUiWidget.getZOrder
--@api-stub: LUiWidget.isAnimating
--@api-stub: LUiWidget.isEnabled
-- LUiWidget z-order and enabled state.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setZOrder(5)
    local z = w:getZOrder()
    local animating = w:isAnimating()
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("zOrder:", z, "isAnimating:", animating, "isEnabled:", enabled)
end

--@api-stub: LUiWidget.isVisible
--@api-stub: LUiWidget.removeChild
--@api-stub: LUiWidget.setAlpha
-- LUiWidget visibility and child removal.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local vis = w:isVisible()
    w:setVisible(false)
    local child = lurek.ui.newLabel("removable")
    w:addChild(child)
    w:removeChild(child)
    w:setAlpha(0.9)
    local alpha = w:getAlpha()
    print("isVisible:", vis, "removeChild ok, alpha:", alpha)
end

--@api-stub: LUiWidget.setAnchor
--@api-stub: LUiWidget.setAnchorCenter
--@api-stub: LUiWidget.setEnabled
-- LUiWidget anchor and enabled.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 1)
    w:clearAnchor()
    w:setAnchorCenter(0.5, 0.5)
    w:setEnabled(true)
    local enabled = w:isEnabled()
    w:setEnabled(false)
    print("setAnchor/setAnchorCenter/setEnabled ok")
end
