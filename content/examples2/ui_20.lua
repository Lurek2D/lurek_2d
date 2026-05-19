--@api-stub: LUiWidget.addChild
--@api-stub: LUiWidget.animateAlpha
--@api-stub: LUiWidget.animatePosition
-- LUiWidget child and animation.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    local child = lurek.ui.newLabel("label")
    w:addChild(child)
    w:animateAlpha(0.5, 0.3, false)
    w:animatePosition(10, 20, 0.5)
    local cnt = w:getChildCount()
    print("addChild/animateAlpha/animatePosition ok; childCount:", cnt)
end

--@api-stub: LUiWidget.attachToEntity
--@api-stub: LUiWidget.bind
--@api-stub: LUiWidget.cancelAnimations
-- LUiWidget entity attachment and animations.
do
    local w = lurek.ui.newCustomWidget({width=80, height=40})
    w:attachToEntity(1)
    w:animateAlpha(0.0, 1.0, false)
    local animating = w:isAnimating()
    w:cancelAnimations()
    w:bind("click")
    w:detachFromEntity()
    print("attachToEntity/bind/cancelAnimations ok")
end

--@api-stub: LUiWidget.clearAnchor
--@api-stub: LUiWidget.containsPoint
--@api-stub: LUiWidget.detachFromEntity
-- LUiWidget anchor and hit testing.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAnchor(0, 0, 1, 0)
    w:clearAnchor()
    w:setPosition(10, 10)
    local hit = w:containsPoint(15, 15)
    w:attachToEntity(2)
    w:detachFromEntity()
    print("clearAnchor/containsPoint:", hit, "detachFromEntity ok")
end

--@api-stub: LUiWidget.fadeIn
--@api-stub: LUiWidget.fadeOut
--@api-stub: LUiWidget.findById
-- LUiWidget fade and find.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setId("my-panel")
    w:fadeOut()
    w:fadeIn()
    local child = lurek.ui.newLabel("inner")
    child:setId("inner-lbl")
    w:addChild(child)
    local found = w:findById("inner-lbl")
    print("fadeIn/fadeOut ok; findById:", found)
end

--@api-stub: LUiWidget.getAlpha
--@api-stub: LUiWidget.getChildCount
--@api-stub: LUiWidget.getChildren
-- LUiWidget alpha and children.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setAlpha(0.75)
    local alpha = w:getAlpha()
    w:addChild(lurek.ui.newLabel("c1"))
    w:addChild(lurek.ui.newLabel("c2"))
    local cnt = w:getChildCount()
    local children = w:getChildren()
    print("alpha:", alpha, "childCount:", cnt, "children:", children)
end

--@api-stub: LUiWidget.getFlexGrow
--@api-stub: LUiWidget.getFlexShrink
--@api-stub: LUiWidget.getId
-- LUiWidget flex and identity.
do
    local w = lurek.ui.newCustomWidget({width=100, height=50})
    w:setFlexGrow(2)
    local grow = w:getFlexGrow()
    w:setFlexShrink(1)
    local shrink = w:getFlexShrink()
    w:setId("widget-abc")
    local id = w:getId()
    print("flexGrow:", grow, "flexShrink:", shrink, "id:", id)
end
