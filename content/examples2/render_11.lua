--@api-stub: lurek.render.getCanvasSize
--@api-stub: lurek.render.getColorMask
--@api-stub: lurek.render.getDefaultFilter
-- Render canvas size, color mask, default filter.
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    local rm, gm, bm, am = lurek.render.getColorMask()
    local min_f, mag_f, aniso = lurek.render.getDefaultFilter()
    print("canvas size:", w, h, "color mask r:", rm, "filter:", min_f)
end

--@api-stub: lurek.render.getDepthMode
--@api-stub: lurek.render.getFontCellWidth
--@api-stub: lurek.render.getFontDescent
-- Render depth mode and font cell/descent metrics.
do
    local depth_mode, depth_write = lurek.render.getDepthMode()
    local font = lurek.render.getDefaultFont(14)
    local cw = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    print("depth:", depth_mode, depth_write, "cell_w:", cw, "descent:", descent)
end

--@api-stub: lurek.render.getFontHeight
--@api-stub: lurek.render.getFontLineHeight
--@api-stub: lurek.render.getLineWidth
-- Render font height, line height, and current line width.
do
    local font = lurek.render.getDefaultFont(14)
    local fh = lurek.render.getFontHeight(font)
    local flh = lurek.render.getFontLineHeight(font)
    local lw = lurek.render.getLineWidth()
    print("font height:", fh, "line height:", flh, "line width:", lw)
end

--@api-stub: lurek.render.getStencilMode
--@api-stub: lurek.render.isLayerVisible
--@api-stub: lurek.render.loadModel
-- Render stencil mode, layer visibility, and model loading.
do
    local action, compare, ref = lurek.render.getStencilMode()
    local visible = lurek.render.isLayerVisible("default")
    local model = lurek.render.loadModel("assets/models/test.obj")
    -- model may be nil if file doesn't exist; that's okay
    print("stencil:", action, compare, ref, "layer visible:", visible, "model:", model ~= nil)
end

--@api-stub: lurek.render.intersectScissor
-- Render intersect scissor.
do
    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    lurek.render.setScissor()
    print("intersectScissor ok")
end
