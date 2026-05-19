--@api-stub: LDrawLayer:flush
--@api-stub: LDrawLayer:getCount
--@api-stub: LDrawLayer:queue
-- LDrawLayer: queue draw commands and flush.
do
    local dl = lurek.render.newDrawLayer()
    dl:queue(1.0, function()
        lurek.render.circle("fill", 100, 100, 20)
    end)
    dl:queue(2.0, function()
        lurek.render.circle("fill", 200, 100, 20)
    end)
    local count = dl:getCount()
    dl:flush()
    print("drawlayer count was:", count)
end

--@api-stub: lurek.render.drawq
--@api-stub: lurek.render.drawNineSlice
-- Render draw, drawq, and drawNineSlice.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    if img then
        lurek.render.draw(img, 10, 10, 0, 1, 1)
        local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
        if q then
            lurek.render.drawq(img, q, 50, 50, 0, 1, 1)
        end
        local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4)
        if ns then
            lurek.render.drawNineSlice(ns, 100, 100, 80, 60)
        end
    end
    print("draw, drawq, drawNineSlice tested")
end

--@api-stub: lurek.render.clearStencil
--@api-stub: lurek.render.currentLayer
-- Render quad bezier, clear stencil, current layer.
do
    lurek.render.drawQuadBezier(0, 0, 100, 50, 200, 0, 20)
    lurek.render.clearStencil()
    local layer = lurek.render.currentLayer()
    print("bezier drawn, stencil cleared, layer:", layer)
end

--@api-stub: lurek.render.flushSortGroup
--@api-stub: lurek.render.pushSortKey
--@api-stub: lurek.render.popLayer
-- Render sort group flushing, sort key push, pop layer.
do
    lurek.render.pushSortKey(5)
    lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(0)
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.popLayer(99)
    print("flushSortGroup, pushSortKey, popLayer tested")
end
