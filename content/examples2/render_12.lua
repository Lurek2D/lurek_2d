--@api-stub: lurek.render.resetCanvas
--@api-stub: lurek.render.saveScreenshot
--@api-stub: lurek.render.setFontLineHeight
-- Render canvas reset, screenshot, font line height.
do
    local canvas = lurek.render.newCanvas(64, 64)
    lurek.render.resetCanvas(canvas)
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("resetCanvas, saveScreenshot, setFontLineHeight ok")
end

--@api-stub: lurek.render.setLayer
--@api-stub: lurek.render.setLayerVisible
--@api-stub: lurek.render.setLayerZOrder
-- Render layer name, visibility, and z-order.
do
    local prev_layer = lurek.render.currentLayer()
    lurek.render.setLayer("default")
    lurek.render.setLayerVisible("default", true)
    lurek.render.setLayerZOrder("default", 0)
    if prev_layer then
        lurek.render.setLayer(prev_layer)
    end
    print("setLayer, setLayerVisible, setLayerZOrder ok")
end

--@api-stub: lurek.render.setStencilTest
-- Render stencil test configuration.
do
    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest("always", 0)
    print("setStencilTest ok")
end
