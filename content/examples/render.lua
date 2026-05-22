-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

--- Render Module Part 1: basic drawing â€” print, rectangle, circle, line, polygon, points, arc, ellipse, triangle


--@api-stub: lurek.render.print
do
    lurek.render.print("Hello, Lurek2D!", 10, 10)
       -- Removed scaled and small text prints
       lurek.render.print("", 0, 0)
end

--@api-stub: lurek.render.printf
do
       lurek.render.printf("Centered text within a 300px box.", 10, 140, 300, "center")
end

--@api-stub: lurek.render.printRotated
do
    lurek.render.printRotated("Rotated!", 200, 200, math.pi / 4)
end

--@api-stub: lurek.render.printRich
do
    local spans = { { text = "Red ",   r = 1, g = 0, b = 0, a = 1, scale = 1 }, { text = "Green ", r = 0, g = 1, b = 0, a = 1, scale = 1 }, { text = "Blue",   r = 0, g = 0, b = 1, a = 1, scale = 1.5 }, }
    lurek.render.printRich(spans, 10, 260)
end

--@api-stub: lurek.render.rectangle
do
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 50, 300, 100, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.circle
do
    lurek.render.setColor(1, 0.5, 0, 1); lurek.render.circle("fill", 500, 340, 40)
    lurek.render.setColor(0, 1, 1, 1); lurek.render.circle("line", 500, 340, 40)
    lurek.render.setColor(0.5, 0.5, 0.5, 1)
    lurek.render.circle("fill", 600, 340, 20)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.ellipse
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1); lurek.render.ellipse("fill", 150, 450, 60, 30)
    lurek.render.setColor(1, 1, 1, 1); lurek.render.ellipse("line", 150, 450, 60, 30)
    lurek.render.setColor(0.9, 0.3, 0.1, 1)
    lurek.render.ellipse("fill", 300, 450, 30, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.arc
do
    lurek.render.setColor(1, 0.8, 0, 1); lurek.render.arc("fill", 500, 450, 50, 0, math.pi / 2)
    lurek.render.setColor(0, 0.8, 0.3, 1); lurek.render.arc("line", 500, 450, 50, math.pi, math.pi * 1.5, 16)
    lurek.render.setColor(0.5, 0, 1, 1)
    lurek.render.arc("fill", 620, 450, 40, 0, math.pi * 2, 64)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.line
do
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.line(10, 520, 200, 520)
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.line(10, 540, 50, 560, 90, 540, 130, 560, 170, 540, 200, 560)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.polygon
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
end

--@api-stub: lurek.render.triangle
do
    lurek.render.setColor(0, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 450, 570, 500, 500, 550, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 560, 570, 610, 500, 660, 570)
end

--@api-stub: lurek.render.points
do
    lurek.render.setPointSize(4); lurek.render.setColor(1, 0, 0, 1)
    lurek.render.points(50, 600, 70, 600, 90, 600, 110, 600, 130, 600); lurek.render.setPointSize(8)
    lurek.render.setColor(0, 0, 1, 1); lurek.render.points({ { 160, 600 }, { 180, 600 }, { 200, 600 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setLineWidth
do
    lurek.render.setLineWidth(5)
       print("line width set")
    lurek.render.setLineWidth(1)
end

--@api-stub: lurek.render.getLineWidth
do
    lurek.render.setLineWidth(5)
    local w = lurek.render.getLineWidth()
    print("line width = " .. w)
    lurek.render.setLineWidth(1)
end

--@api-stub: lurek.render.setPointSize
do
    lurek.render.setPointSize(2)
    local s = lurek.render.getPointSize()
    print("point size = " .. s)
    lurek.render.setPointSize(1)
end

--@api-stub: lurek.render.getPointSize
do
    lurek.render.setPointSize(2)
    local s = lurek.render.getPointSize()
    print("point size = " .. s)
    lurek.render.setPointSize(1)
end

--@api-stub: lurek.render.drawCubicBezier
do
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.drawCubicBezier(120, 630, 160, 580, 220, 680, 260, 630, 24)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawQuadBezier
do
    lurek.render.setColor(0, 1, 0.5, 1)
    lurek.render.drawQuadBezier(300, 630, 350, 580, 400, 630, 16)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawPath
do
    local path = { { type = "moveTo", x = 450, y = 620 }, { type = "lineTo", x = 500, y = 600 }, { type = "quadTo", cx = 550, cy = 580, x = 580, y = 620 }, { type = "lineTo", x = 560, y = 660 }, { type = "cubicTo", cx1 = 530, cy1 = 680, cx2 = 480, cy2 = 680, x = 450, y = 660 }, }
    lurek.render.setColor(0.6, 0.2, 1, 1)
    lurek.render.drawPath(path, "line", true)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawGradientRect
do
    lurek.render.drawGradientRect(10, 680, 150, 40, { 1, 0, 0 }, { 0, 0, 1 }, "horizontal")
    lurek.render.drawGradientRect(170, 680, 150, 40, { 0, 1, 0 }, { 1, 1, 0 }, "vertical")
    lurek.render.drawGradientRect(330, 680, 80, 80, { 1, 1, 1 }, { 0, 0, 0 }, "radial")
end

--@api-stub: lurek.render.drawColoredPolygon
do
    local verts = { 450, 680, 520, 680, 520, 740, 450, 740 }
    local colors = { { 1, 0, 0, 1 }, { 0, 1, 0, 1 }, { 0, 0, 1, 1 }, { 1, 1, 0, 1 }, }
    lurek.render.drawColoredPolygon(verts, colors, "fill")
end

--@api-stub: lurek.render.drawHexTile
do
    lurek.render.setColor(0, 0.6, 0.4, 1); lurek.render.drawHexTile(600, 700, 25, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1); lurek.render.drawHexTile(600, 700, 25, "pointyTop", "line")
    lurek.render.setColor(0.8, 0.4, 0, 1); lurek.render.drawHexTile(660, 700, 25, "flatTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(660, 700, 25, "flatTop", "line")
end

--@api-stub: lurek.render.drawBevelRect
do
    lurek.render.drawBevelRect(10, 750, 100, 40, 3, "raised")
    lurek.render.drawBevelRect(120, 750, 100, 40, 3, "sunken")
    lurek.render.drawBevelRect(230, 750, 100, 40, 2, "groove")
    lurek.render.drawBevelRect(340, 750, 100, 40, 2, "ridge")
    lurek.render.drawBevelRect(450, 750, 100, 40, 2, "flat", { fillColor = { 0.2, 0.3, 0.8, 1 } })
end

--- Render Module Part 2: color state, transforms, scissor, clear, blend modes, wireframe, layers, depth


--@api-stub: lurek.render.setColor
do
    lurek.render.setColor(1, 0, 0, 1); local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a); lurek.render.setColor(0.5, 0.5, 0.5, 0.8)
    r, g, b, a = lurek.render.getColor()
    print("gray = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setBackgroundColor
do
    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("bg = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end

--@api-stub: lurek.render.setColorMask
do
    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("mask: r=" .. tostring(r) .. " g=" .. tostring(g) .. " b=" .. tostring(b) .. " a=" .. tostring(a))
    lurek.render.setColorMask()
end

--@api-stub: lurek.render.push
do
    lurek.render.push(); lurek.render.translate(100, 100); lurek.render.rectangle("fill", 0, 0, 50, 50)
    lurek.render.pop(); lurek.render.push(); lurek.render.translate(200, 100)
    lurek.render.rotate(math.pi / 4); lurek.render.rectangle("fill", -25, -25, 50, 50); lurek.render.pop()
    lurek.render.push(); lurek.render.translate(350, 100); lurek.render.scale(2, 0.5)
    lurek.render.rectangle("fill", 0, 0, 30, 30); lurek.render.pop()
end

--@api-stub: lurek.render.shear
do
    lurek.render.push(); lurek.render.translate(100, 200)
    lurek.render.shear(0.3, 0); lurek.render.setColor(0, 0.8, 0.5, 1)
    lurek.render.rectangle("fill", 0, 0, 80, 40)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

--@api-stub: lurek.render.origin
do
    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.render.pop()
end

--@api-stub: lurek.render.applyTransform
do
    local mat = { 1, 0, 0, 0, 1, 0, 50, 250, 1 }; lurek.render.push()
    lurek.render.applyTransform(mat); lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 40, 40)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

--@api-stub: lurek.render.setScissor
do
    lurek.render.setScissor(50, 300, 200, 100); local x, y, w, h = lurek.render.getScissor()
    print("scissor = " .. x .. "," .. y .. " " .. w .. "x" .. h); lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 0, 280, 400, 150); lurek.render.intersectScissor(100, 320, 100, 60)
    lurek.render.setColor(0, 0, 1, 1); lurek.render.rectangle("fill", 0, 280, 400, 150)
    lurek.render.setColor(1, 1, 1, 1); lurek.render.setScissor()
end

--@api-stub: lurek.render.clear
do
    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    print("cleared render commands")
end

--@api-stub: lurek.render.setBlendMode
do
    local original = lurek.render.getBlendMode(); print("default blend = " .. original); lurek.render.setBlendMode("add")
    print("now = " .. lurek.render.getBlendMode()); lurek.render.setColor(0.5, 0, 0, 1); lurek.render.rectangle("fill", 300, 300, 80, 80)
    lurek.render.setColor(0, 0.5, 0, 1); lurek.render.rectangle("fill", 340, 320, 80, 80); lurek.render.setBlendMode("multiply")
    lurek.render.setColor(1, 0.5, 0.5, 1); lurek.render.rectangle("fill", 300, 400, 80, 80)
    lurek.render.setBlendMode("alpha"); lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setWireframe
do
    print("wireframe = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 450, 300, 60, 60)
    lurek.render.circle("fill", 540, 330, 30)
    lurek.render.setWireframe(false)
end

--@api-stub: lurek.render.newLayer
do
    lurek.render.newLayer("background", 0); lurek.render.newLayer("foreground", 10); lurek.render.newLayer("ui", 100); lurek.render.setLayer("background")
    print("current layer = " .. lurek.render.currentLayer()); lurek.render.setColor(0.2, 0.2, 0.4, 1); lurek.render.rectangle("fill", 0, 450, 800, 100); lurek.render.setLayer("foreground")
    lurek.render.setColor(0, 1, 0, 1); lurek.render.circle("fill", 100, 500, 20); lurek.render.setLayer("ui")
    lurek.render.setColor(1, 1, 1, 1); lurek.render.print("HUD Layer", 10, 460); print("bg visible = " .. tostring(lurek.render.isLayerVisible("background")))
    lurek.render.setLayerVisible("background", false); print("bg visible = " .. tostring(lurek.render.isLayerVisible("background"))); lurek.render.setLayerVisible("background", true)
end

--@api-stub: lurek.render.getLayerZOrder
do
    lurek.render.newLayer("midground", 5)
    print("midground z = " .. lurek.render.getLayerZOrder("midground"))
    lurek.render.setLayerZOrder("midground", 50)
    print("midground z = " .. lurek.render.getLayerZOrder("midground"))
end

--@api-stub: lurek.render.pushLayer
do
    lurek.render.pushLayer(1, 0.5, "alpha"); lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 50, 560, 100, 60); lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("fill", 80, 580, 100, 60)
    lurek.render.popLayer(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.beginSortGroup
do
    lurek.render.beginSortGroup(1); lurek.render.pushSortKey(10); lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 200, 560, 40, 40); lurek.render.pushSortKey(5); lurek.render.setColor(0, 0, 1, 1)
    lurek.render.rectangle("fill", 210, 570, 40, 40); lurek.render.pushSortKey(15)
    lurek.render.setColor(0, 1, 0, 1); lurek.render.rectangle("fill", 220, 580, 40, 40)
    lurek.render.flushSortGroup(1); lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setDepthMode
do
    local mode, write = lurek.render.getDepthMode(); print("depth: mode=" .. mode .. " write=" .. tostring(write))
    lurek.render.setDepthMode("lequal", true)
    mode, write = lurek.render.getDepthMode()
    print("depth: mode=" .. mode .. " write=" .. tostring(write))
    lurek.render.setDepthMode("always", false)
end

--@api-stub: lurek.render.setDefaultFilter
do
    local min, mag, aniso = lurek.render.getDefaultFilter(); print("filter: min=" .. min .. " mag=" .. mag .. " aniso=" .. aniso)
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    min, mag, aniso = lurek.render.getDefaultFilter()
    print("filter: min=" .. min .. " mag=" .. mag .. " aniso=" .. aniso)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end

--@api-stub: lurek.render.getDimensions
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth())
    print("height = " .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getStats
do
    local stats = lurek.render.getStats(); print("drawcalls = " .. stats.drawcalls)
    print("textures = " .. stats.textures); print("fonts = " .. stats.fonts)
    print("canvases = " .. stats.canvases); print("texture_memory = " .. stats.texture_memory)
    print("gpu_draw_calls = " .. stats.gpu_draw_calls)
    print("cpu_render_ms = " .. string.format("%.2f", stats.cpu_render_ms))
end

--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice


--@api-stub: lurek.render.newImage
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); print("image: " .. img:getWidth() .. "x" .. img:getHeight())
    local w, h = img:getDimensions(); print("dimensions: " .. w .. "x" .. h)
    lurek.render.draw(img, 10, 10)
    lurek.render.draw(img, 120, 10, math.pi / 6, 0.5, 0.5)
    lurek.render.draw(img, 200, 10, 0, 2, 2, w / 2, h / 2)
end

--@api-stub: LImage:getId
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); print("id = " .. img:getId())
    print("type = " .. img:type())
    print("is LImage = " .. tostring(img:typeOf("LImage")))
    local released = img:release()
    print("released = " .. tostring(released))
end

--@api-stub: LImage:type
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); print("id = " .. img:getId())
    print("type = " .. img:type())
    print("is LImage = " .. tostring(img:typeOf("LImage")))
    local released = img:release()
    print("released = " .. tostring(released))
end

--@api-stub: LImage:typeOf
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); print("id = " .. img:getId())
    print("type = " .. img:type())
    print("is LImage = " .. tostring(img:typeOf("LImage")))
    local released = img:release()
    print("released = " .. tostring(released))
end

--@api-stub: LImage:release
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); print("id = " .. img:getId())
    print("type = " .. img:type())
    print("is LImage = " .. tostring(img:typeOf("LImage")))
    local released = img:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.newCanvas
do
    local canvas = lurek.render.newCanvas(128, 128); print("canvas: " .. canvas:getWidth() .. "x" .. canvas:getHeight()); local cw, ch = canvas:getDimensions()
    print("canvas dims: " .. cw .. "x" .. ch); lurek.render.setCanvas(canvas); lurek.render.setColor(0.2, 0.5, 0.8, 1)
    lurek.render.rectangle("fill", 0, 0, 128, 128); lurek.render.setColor(1, 1, 0, 1); lurek.render.circle("fill", 64, 64, 40)
    lurek.render.setCanvas(nil); lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(canvas, 10, 150); lurek.render.draw(canvas, 150, 150, 0, 0.5, 0.5)
end

--@api-stub: LCanvas:type
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    local released = canvas:release()
    print("released = " .. tostring(released))
end

--@api-stub: LCanvas:typeOf
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    local released = canvas:release()
    print("released = " .. tostring(released))
end

--@api-stub: LCanvas:release
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    local released = canvas:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getCanvas
do
    local canvas = lurek.render.newCanvas(200, 100); lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas(); print("active canvas = " .. tostring(active))
    local cw, ch = lurek.render.getCanvasSize(canvas); print("canvas size = " .. cw .. "x" .. ch)
    lurek.render.setCanvas(nil); lurek.render.resetCanvas(canvas)
    print("canvas reset done")
end

--@api-stub: lurek.render.newQuad
do
    local sheet = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local sw, sh = sheet:getDimensions(); local q1 = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    local q2 = lurek.render.newQuad(16, 0, 16, 16, sw, sh); local x, y, w, h = q1:getViewport(); print("q1 viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    local tw, th = q1:getTextureDimensions(); print("texture = " .. tostring(tw) .. "x" .. tostring(th)); lurek.render.drawq(sheet, q1, 10, 310)
    lurek.render.drawq(sheet, q2, 30, 310); lurek.render.drawq(sheet, q1, 60, 310, math.pi / 4, 2, 2)
    q2:setViewport(32, 0, 16, 16); lurek.render.drawq(sheet, q2, 120, 310)
end

--@api-stub: LQuad:type
do
    ---@type LQuad
    local q = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("type = " .. q:type())
    print("is LQuad = " .. tostring(q:typeOf("LQuad")))
end

--@api-stub: LQuad:typeOf
do
    ---@type LQuad
    local q = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("type = " .. q:type())
    print("is LQuad = " .. tostring(q:typeOf("LQuad")))
end

--@api-stub: lurek.render.newSpriteBatch
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local batch = lurek.render.newSpriteBatch(img, 100)
    print("batch capacity = " .. batch:getBufferSize()); for i = 0, 9 do local idx = batch:add(i * 20, 380, 0, 0.5, 0.5) end
    print("batch count = " .. batch:getCount()); lurek.render.draw(batch, 10, 0)
    batch:clear()
    print("after clear = " .. batch:getCount())
end

--@api-stub: LSpriteBatch:type
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local batch = lurek.render.newSpriteBatch(img, 50)
    print("type = " .. batch:type())
    print("is LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    local released = batch:release()
    print("released = " .. tostring(released))
end

--@api-stub: LSpriteBatch:typeOf
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local batch = lurek.render.newSpriteBatch(img, 50)
    print("type = " .. batch:type())
    print("is LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    local released = batch:release()
    print("released = " .. tostring(released))
end

--@api-stub: LSpriteBatch:release
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local batch = lurek.render.newSpriteBatch(img, 50)
    print("type = " .. batch:type())
    print("is LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    local released = batch:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.drawMany
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local list = { { img, 10, 420, 0, 0.3, 0.3 }, { img, 50, 420, math.pi / 8, 0.3, 0.3 }, { img, 90, 420, math.pi / 4, 0.3, 0.3 }, { img, 130, 420, math.pi / 2, 0.3, 0.3 }, }
    lurek.render.drawMany(list)
end

--@api-stub: lurek.render.newNineSlice
do
    local panelImg = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local slice = lurek.render.newNineSlice(panelImg, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets(); print("insets: " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    local tw, th = slice:getTextureSize(); print("source texture: " .. tw .. "x" .. th)
    lurek.render.drawNineSlice(slice, 10, 470, 200, 60); lurek.render.drawNineSlice(slice, 220, 470, 80, 80)
    print("type = " .. slice:type()); print("is LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
end

--@api-stub: lurek.render.newDrawLayer
do
    ---@type LDrawLayer
    local layer = lurek.render.newDrawLayer()
    layer:queue(10, function()
        lurek.render.setColor(1, 0, 0, 1)
        lurek.render.rectangle("fill", 10, 550, 40, 40)
    end)
    layer:queue(5, function()
        lurek.render.setColor(0, 0, 1, 1)
        lurek.render.rectangle("fill", 20, 560, 40, 40)
    end)
    layer:queue(15, function()
        lurek.render.setColor(0, 1, 0, 1)
        lurek.render.rectangle("fill", 30, 570, 40, 40)
    end)
    print("queued = " .. layer:getCount())
    layer:flush()
    print("after flush = " .. layer:getCount())
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: LDrawLayer:clear
do
    local layer = lurek.render.newDrawLayer(); layer:queue(1, function() end)
    layer:queue(2, function() end); layer:clear()
    print("cleared, count = " .. layer:getCount())
    print("type = " .. layer:type())
    print("is LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end

--@api-stub: LDrawLayer:type
do
    local layer = lurek.render.newDrawLayer(); layer:queue(1, function() end)
    layer:queue(2, function() end); layer:clear()
    print("cleared, count = " .. layer:getCount())
    print("type = " .. layer:type())
    print("is LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end

--@api-stub: LDrawLayer:typeOf
do
    local layer = lurek.render.newDrawLayer(); layer:queue(1, function() end)
    layer:queue(2, function() end); layer:clear()
    print("cleared, count = " .. layer:getCount())
    print("type = " .. layer:type())
    print("is LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end

--@api-stub: lurek.render.drawIsoCubeTile
do
    lurek.render.drawIsoCubeTile(400, 500, 30, 15, { depth = 20, topColor = { 0.8, 0.8, 0.8, 1 }, leftColor = { 0.5, 0.5, 0.5, 1 }, rightColor = { 0.3, 0.3, 0.3, 1 }, })
    lurek.render.drawIsoCubeTile(460, 500, 30, 15, { depth = 30, topColor = { 0.2, 0.7, 0.2, 1 }, leftColor = { 0.1, 0.5, 0.1, 1 }, rightColor = { 0.05, 0.3, 0.05, 1 }, })
end

--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api-stub: lurek.render.newShader
do
    local shader = lurek.render.newShader([[ @vertex fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0, 0.0, 0.0, 1.0); } @fragment fn fs_main() -> @location(0) vec4<f32> { return vec4<f32>(0.5, 0.5, 1.0, 1.0); } ]])
    print("type = " .. shader:type())
end

--@api-stub: LShader:send
do
    local shader = lurek.render.newShader([[ @vertex fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0, 0.0, 0.0, 1.0); } @fragment fn fs_main() -> @location(0) vec4<f32> { return vec4<f32>(0.5, 0.5, 1.0, 1.0); } ]])
    shader:send("time", 1.5)
    print("sent time")
end

--@api-stub: LShader:setShader
do
    local shader = lurek.render.newShader([[ @vertex fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0, 0.0, 0.0, 1.0); } @fragment fn fs_main() -> @location(0) vec4<f32> { return vec4<f32>(0.5, 0.5, 1.0, 1.0); } ]])
    lurek.render.setShader(shader)
    print("shader active = " .. tostring(lurek.render.getShader()))
    lurek.render.setShader(nil)
end

--@api-stub: LShader:getShader
do
    local shader = lurek.render.newShader([[ @vertex fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0, 0.0, 0.0, 1.0); } @fragment fn fs_main() -> @location(0) vec4<f32> { return vec4<f32>(0.5, 0.5, 1.0, 1.0); } ]])
    lurek.render.setShader(shader)
    print("shader active = " .. tostring(lurek.render.getShader()))
    lurek.render.setShader(nil)
end

--@api-stub: LShader:release
do
    local code = [[ @vertex fn vs(@builtin(vertex_index) i: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0); } @fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); } ]]
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.newMesh
do
    local verts = { { 100, 100, 0, 0, 1, 0, 0, 1 }, { 200, 100, 1, 0, 0, 1, 0, 1 }, { 150, 200, 0.5, 1, 0, 0, 1, 1 }, }
    local mesh = lurek.render.newMesh(verts, "triangles")
    print("vertex count = " .. mesh:getVertexCount())
    lurek.render.draw(mesh, 0, 0)
    lurek.render.draw(mesh, 200, 0, math.pi / 4, 0.5, 0.5)
end

--@api-stub: LMesh:setVertex
do
    local verts = { { 0, 0, 0, 0, 1, 1, 1, 1 }, { 50, 0, 1, 0, 1, 1, 1, 1 }, { 25, 50, 0.5, 1, 1, 1, 1, 1 }, }; local mesh = lurek.render.newMesh(verts)
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    print("v1: x=" .. x .. " y=" .. y .. " r=" .. r .. " g=" .. g .. " b=" .. b)
    mesh:setVertex(3, { 30, 60, 0.5, 1, 0, 1, 0, 1 })
end

--@api-stub: LMesh:getVertex
do
    local verts = { { 0, 0, 0, 0, 1, 1, 1, 1 }, { 50, 0, 1, 0, 1, 1, 1, 1 }, { 25, 50, 0.5, 1, 1, 1, 1, 1 }, }; local mesh = lurek.render.newMesh(verts)
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    print("v1: x=" .. x .. " y=" .. y .. " r=" .. r .. " g=" .. g .. " b=" .. b)
    mesh:setVertex(3, { 30, 60, 0.5, 1, 0, 1, 0, 1 })
end

--@api-stub: LMesh:setTexture
do
    local mesh = lurek.render.newMesh({ { 0, 0, 0, 0, 1, 1, 1, 1 }, { 64, 0, 1, 0, 1, 1, 1, 1 }, { 64, 64, 1, 1, 1, 1, 1, 1 }, { 0, 64, 0, 1, 1, 1, 1, 1 } }, "fan")
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(img)
    print("texture set")
end

--@api-stub: LMesh:release
do
    local mesh = lurek.render.newMesh({ { 0, 0, 0, 0, 1, 1, 1, 1 }, { 64, 0, 1, 0, 1, 1, 1, 1 }, { 64, 64, 1, 1, 1, 1, 1, 1 }, { 0, 64, 0, 1, 1, 1, 1, 1 } }, "fan")
    print("released = " .. tostring(mesh:release()))
end

--@api-stub: LMesh:type
do
    local mesh = lurek.render.newMesh({ { 0, 0, 0, 0, 1, 1, 1, 1 }, { 64, 0, 1, 0, 1, 1, 1, 1 }, { 64, 64, 1, 1, 1, 1, 1, 1 }, { 0, 64, 0, 1, 1, 1, 1, 1 } }, "fan")
    print("type = " .. mesh:type())
end

--@api-stub: LMesh:typeOf
do
    local mesh = lurek.render.newMesh({ { 0, 0, 0, 0, 1, 1, 1, 1 }, { 64, 0, 1, 0, 1, 1, 1, 1 }, { 64, 64, 1, 1, 1, 1, 1, 1 }, { 0, 64, 0, 1, 1, 1, 1, 1 } }, "fan")
    print("is LMesh = " .. tostring(mesh:typeOf("LMesh")))
end

--@api-stub: lurek.render.newShape
do
    local shape = lurek.render.newShape(); shape:setColor(1, 0, 0, 1); shape:rectangle("fill", 0, 0, 60, 40); shape:setColor(0, 1, 0, 1)
    shape:circle("fill", 80, 20, 15); shape:setColor(0, 0, 1, 1); shape:line(0, 50, 100, 50)
    shape:setColor(1, 1, 0, 1); shape:ellipse("fill", 50, 80, 30, 15); shape:setColor(1, 0, 1, 1)
    shape:arc("fill", 120, 30, 20, 0, math.pi); shape:setColor(0, 1, 1, 1); shape:triangle("fill", 140, 0, 180, 0, 160, 30)
    print("commands = " .. shape:getCommandCount()); shape:draw(10, 250); shape:draw(200, 250, math.pi / 6, 0.8, 0.8)
end

--@api-stub: LShape:polygon
do
    local shape = lurek.render.newShape(); shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30); shape:setColor(1, 1, 1, 1)
    shape:polyline(60, 0, 80, 20, 100, 0, 120, 20); shape:setLineWidth(3)
    shape:setColor(0.5, 0.5, 1, 1); shape:roundedRectangle("line", 0, 60, 80, 40, 8)
    shape:draw(400, 250)
end

--@api-stub: LShape:polyline
do
    local shape = lurek.render.newShape(); shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30); shape:setColor(1, 1, 1, 1)
    shape:polyline(60, 0, 80, 20, 100, 0, 120, 20); shape:setLineWidth(3)
    shape:setColor(0.5, 0.5, 1, 1); shape:roundedRectangle("line", 0, 60, 80, 40, 8)
    shape:draw(400, 250)
end

--@api-stub: LShape:roundedRectangle
do
    local shape = lurek.render.newShape(); shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30); shape:setColor(1, 1, 1, 1)
    shape:polyline(60, 0, 80, 20, 100, 0, 120, 20); shape:setLineWidth(3)
    shape:setColor(0.5, 0.5, 1, 1); shape:roundedRectangle("line", 0, 60, 80, 40, 8)
    shape:draw(400, 250)
end

--@api-stub: LShape:clear
do
    local shape = lurek.render.newShape(); shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5); print("before clear = " .. shape:getCommandCount())
    shape:clear(); print("after clear = " .. shape:getCommandCount())
    print("type = " .. shape:type())
    print("is LShape = " .. tostring(shape:typeOf("LShape")))
end

--@api-stub: LShape:type
do
    local shape = lurek.render.newShape(); shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5); print("before clear = " .. shape:getCommandCount())
    shape:clear(); print("after clear = " .. shape:getCommandCount())
    print("type = " .. shape:type())
    print("is LShape = " .. tostring(shape:typeOf("LShape")))
end

--@api-stub: LShape:typeOf
do
    local shape = lurek.render.newShape(); shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5); print("before clear = " .. shape:getCommandCount())
    shape:clear(); print("after clear = " .. shape:getCommandCount())
    print("type = " .. shape:type())
    print("is LShape = " .. tostring(shape:typeOf("LShape")))
end

--@api-stub: lurek.render.loadObj
do
    local model = lurek.render.loadObj("content/examples/assets/models/sample_tank.obj")
    print("faces = " .. model:getFaceCount())
    print("vertices = " .. model:getVertexCount())
    print("normals = " .. model:getNormalCount())
    print("uvs = " .. model:getUvCount())
end

--@api-stub: LObjModel:projectToMesh
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local camera = { x = 0, y = 0, z = -5, tx = 0, ty = 0, tz = 0, fov = 60 }
    local verts = model:projectToMesh(camera, 320, 240)
    print("projected vertices = " .. #verts)
end

--@api-stub: LObjModel:renderToImage
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"); local img = model:renderToImage(64, 64, 0)
    print("rendered: " .. img:getWidth() .. "x" .. img:getHeight())
    lurek.render.draw(img, 10, 400)
    local rotated = model:renderToImage(64, 64, 1)
    lurek.render.draw(rotated, 80, 400)
end

--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density


--@api-stub: lurek.render.newFont
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16); print("font type = " .. font:type()); print("is LFont = " .. tostring(font:typeOf("LFont")))
    lurek.render.setFont(font); local active = lurek.render.getFont(); print("active font = " .. active:type())
    lurek.render.print("Using custom font", 10, 10); local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16); lurek.render.setFont(font)
    lurek.render.print("Rendered with custom font", 10, 350); lurek.render.print("Second line", 10, 370)
    local def = lurek.render.getDefaultFont(); lurek.render.setFont(def)
end

--@api-stub: lurek.render.getDefaultFont
do
    local defFont = lurek.render.getDefaultFont(); print("default font height = " .. defFont:getHeight()); local bigDefault = lurek.render.getDefaultFont(24)
    print("big default height = " .. bigDefault:getHeight()); lurek.render.setFont(bigDefault); lurek.render.print("Big default font", 10, 30)
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16); lurek.render.setFont(font)
    lurek.render.print("Rendered with custom font", 10, 350); lurek.render.print("Second line", 10, 370)
    local def = lurek.render.getDefaultFont(); lurek.render.setFont(def)
end

--@api-stub: lurek.render.setDefaultFont
do
    local regular = lurek.render.setDefaultFont(10, false)
    lurek.render.print("Built-in regular font_10", 10, 55)
    local bold = lurek.render.setDefaultFont(10, true)
    lurek.render.print("Built-in bold fontb_10", 10, 75)
    lurek.render.setFont(regular)
    print("default font switched, bold height = " .. bold:getHeight())
end

--@api-stub: LFont:getWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getAscent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getDescent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getWrap
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12); local lines, width = font:getWrap("This is a long paragraph of text that should wrap nicely.", 150)
    print("wrapped lines = " .. #lines .. " width = " .. width)
    for i, line in ipairs(lines) do print("  " .. i .. ": " .. line) end
    font:setLineHeight(1.5)
    print("new line height = " .. font:getLineHeight())
end

--@api-stub: LFont:setLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12); local lines, width = font:getWrap("This is a long paragraph of text that should wrap nicely.", 150)
    print("wrapped lines = " .. #lines .. " width = " .. width)
    for i, line in ipairs(lines) do print("  " .. i .. ": " .. line) end
    font:setLineHeight(1.5)
    print("new line height = " .. font:getLineHeight())
end

--@api-stub: LFont:release
do
    ---@type LFont
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    local released = font:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getFontSizes
do
    local sizes = lurek.render.getFontSizes()
    print("available sizes = " .. #sizes)
    for i, s in ipairs(sizes) do if i <= 5 then print("  size " .. i .. " = " .. s) end end
end

--@api-stub: lurek.render.getFontWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14); local w = lurek.render.getFontWidth(font, "Measurement")
    print("font width = " .. w); local h = lurek.render.getFontHeight(font)
    print("font height = " .. h)
    local lh = lurek.render.getFontLineHeight(font)
    print("line height = " .. lh)
end

--@api-stub: lurek.render.getFontAscent
do
    ---@type LFont
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("ascent = " .. lurek.render.getFontAscent(font))
    print("descent = " .. lurek.render.getFontDescent(font))
    print("cell width = " .. lurek.render.getFontCellWidth(font))
end

--@api-stub: lurek.render.getFontWrap
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    print("lines = " .. #lines .. " max_width = " .. width)
    lurek.render.setFontLineHeight(font, 2.0)
    print("set line height to 2.0")
end

--@api-stub: lurek.render.stencil
do
    lurek.render.stencil("replace", 1); lurek.render.circle("fill", 200, 200, 60)
    lurek.render.stencil(); lurek.render.setStencilTest("equal", 1)
    lurek.render.setColor(1, 0, 0, 1); lurek.render.rectangle("fill", 100, 100, 200, 200)
    lurek.render.setStencilTest()
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setStencilMode
do
    lurek.render.setStencilMode("replace", "always", 1); lurek.render.rectangle("fill", 300, 100, 100, 100)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil: action=" .. action .. " compare=" .. compare .. " value=" .. value)
    lurek.render.clearStencil()
    lurek.render.setStencilMode("keep", "always", 0)
end

--@api-stub: lurek.render.captureScreenshot
do
    lurek.render.setColor(0.2, 0.4, 0.8, 1); lurek.render.rectangle("fill", 0, 0, 320, 240)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.circle("fill", 160, 120, 50)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.captureScreenshot(function(data) print("screenshot captured: " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/screenshot_test.png")
    print("screenshot saved")
end

--@api-stub: lurek.render.setCanvas
do
    local rt = lurek.render.newCanvas(256, 256); lurek.render.setCanvas(rt)
    lurek.render.setColor(0, 1, 0, 1); lurek.render.rectangle("fill", 0, 0, 256, 256)
    lurek.render.setColor(1, 0, 0, 1); lurek.render.circle("fill", 128, 128, 80)
    lurek.render.setCanvas(nil); lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(rt, 400, 50, 0, 0.5, 0.5)
end

--@api-stub: lurek.render.draw
do
    local rt = lurek.render.newCanvas(256, 256); lurek.render.setCanvas(rt)
    lurek.render.setColor(0, 1, 0, 1); lurek.render.rectangle("fill", 0, 0, 256, 256)
    lurek.render.setColor(1, 0, 0, 1); lurek.render.circle("fill", 128, 128, 80)
    lurek.render.setCanvas(nil); lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(rt, 400, 50, 0, 0.5, 0.5)
end

--@api-stub: lurek.render.setFont
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16); lurek.render.setFont(font)
    lurek.render.print("Rendered with custom font", 10, 350)
    lurek.render.print("Second line", 10, 370)
    local def = lurek.render.getDefaultFont()
    lurek.render.setFont(def)
end

--- Render Module Part 5: LCanvas, LFont release/type, LImage release/type, LMesh, LQuad getViewport/type, LShader, LSpriteBatch


--@api-stub: LCanvas:getDimensions
do
    local c = lurek.render.newCanvas(128, 64); local w, h = c:getDimensions()
    print("dims=" .. w .. "x" .. h); print("w=" .. c:getWidth())
    print("h=" .. c:getHeight()); print("type=" .. c:type())
    print("typeOf=" .. tostring(c:typeOf("LCanvas")))
    c:release()
end

--@api-stub: LCanvas:getHeight
do
    local c = lurek.render.newCanvas(128, 64); local w, h = c:getDimensions()
    print("dims=" .. w .. "x" .. h); print("w=" .. c:getWidth())
    print("h=" .. c:getHeight()); print("type=" .. c:type())
    print("typeOf=" .. tostring(c:typeOf("LCanvas")))
    c:release()
end

--@api-stub: LCanvas:getWidth
do
    local c = lurek.render.newCanvas(128, 64); local w, h = c:getDimensions()
    print("dims=" .. w .. "x" .. h); print("w=" .. c:getWidth())
    print("h=" .. c:getHeight()); print("type=" .. c:type())
    print("typeOf=" .. tostring(c:typeOf("LCanvas")))
    c:release()
end

--@api-stub: LFont:type
do
    local f = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("type=" .. f:type())
    print("typeOf=" .. tostring(f:typeOf("LFont")))
    f:release()
end

--@api-stub: LFont:typeOf
do
    local f = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("type=" .. f:type())
    print("typeOf=" .. tostring(f:typeOf("LFont")))
    f:release()
end

--@api-stub: LMesh:getVertexCount
do
    local verts = { { 0, 0, 0, 0, 1, 1, 1, 1 }, { 100, 0, 1, 0, 1, 1, 1, 1 }, { 50, 100, 0.5, 1, 1, 1, 1, 1 }, }; local mesh = lurek.render.newMesh(verts, "triangles"); print("vert_count=" .. mesh:getVertexCount())
    local v = mesh:getVertex(1); print("v1=" .. tostring(v ~= nil))
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); mesh:setTexture(img)
    mesh:setVertex(1, { 10, 10, 0.1, 0.1, 1, 0.5, 0.5, 1 }); print("type=" .. mesh:type())
    print("typeOf=" .. tostring(mesh:typeOf("LMesh"))); mesh:release()
end

--@api-stub: LQuad:getViewport
do
    local q = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = q:getViewport()
    print("vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
    print("type=" .. q:type())
end

--@api-stub: LShader:hasUniform
do
    local code = [[ uniform float time; vec4 effect(vec4 color, Image tex, vec2 uv, vec2 fragCoord) { return Texel(tex, uv) * color; } ]]; local sh = lurek.render.newShader(code)
    print("has_time=" .. tostring(sh:hasUniform("time"))); sh:send("time", 0.5)
    print("type=" .. sh:type())
    print("typeOf=" .. tostring(sh:typeOf("LShader")))
    sh:release()
end

--@api-stub: LShader:type
do
    local code = [[ uniform float time; vec4 effect(vec4 color, Image tex, vec2 uv, vec2 fragCoord) { return Texel(tex, uv) * color; } ]]; local sh = lurek.render.newShader(code)
    print("has_time=" .. tostring(sh:hasUniform("time"))); sh:send("time", 0.5)
    print("type=" .. sh:type())
    print("typeOf=" .. tostring(sh:typeOf("LShader")))
    sh:release()
end

--@api-stub: LShader:typeOf
do
    local code = [[ uniform float time; vec4 effect(vec4 color, Image tex, vec2 uv, vec2 fragCoord) { return Texel(tex, uv) * color; } ]]; local sh = lurek.render.newShader(code)
    print("has_time=" .. tostring(sh:hasUniform("time"))); sh:send("time", 0.5)
    print("type=" .. sh:type())
    print("typeOf=" .. tostring(sh:typeOf("LShader")))
    sh:release()
end

--@api-stub: LSpriteBatch:add
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local sb = lurek.render.newSpriteBatch(img, 100); local id = sb:add(0, 0, 0, 1, 1, 0, 0)
    sb:add(100, 0, 0, 1, 1, 0, 0); print("count=" .. sb:getCount())
    print("buf=" .. sb:getBufferSize()); sb:clear()
    print("count_after=" .. sb:getCount()); print("type=" .. sb:type())
    print("typeOf=" .. tostring(sb:typeOf("LSpriteBatch"))); sb:release()
end

--@api-stub: LSpriteBatch:clear
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local sb = lurek.render.newSpriteBatch(img, 100); local id = sb:add(0, 0, 0, 1, 1, 0, 0)
    sb:add(100, 0, 0, 1, 1, 0, 0); print("count=" .. sb:getCount())
    print("buf=" .. sb:getBufferSize()); sb:clear()
    print("count_after=" .. sb:getCount()); print("type=" .. sb:type())
    print("typeOf=" .. tostring(sb:typeOf("LSpriteBatch"))); sb:release()
end

--@api-stub: LSpriteBatch:getBufferSize
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local sb = lurek.render.newSpriteBatch(img, 100); local id = sb:add(0, 0, 0, 1, 1, 0, 0)
    sb:add(100, 0, 0, 1, 1, 0, 0); print("count=" .. sb:getCount())
    print("buf=" .. sb:getBufferSize()); sb:clear()
    print("count_after=" .. sb:getCount()); print("type=" .. sb:type())
    print("typeOf=" .. tostring(sb:typeOf("LSpriteBatch"))); sb:release()
end

--@api-stub: LSpriteBatch:getCount
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png"); local sb = lurek.render.newSpriteBatch(img, 100); local id = sb:add(0, 0, 0, 1, 1, 0, 0)
    sb:add(100, 0, 0, 1, 1, 0, 0); print("count=" .. sb:getCount())
    print("buf=" .. sb:getBufferSize()); sb:clear()
    print("count_after=" .. sb:getCount()); print("type=" .. sb:type())
    print("typeOf=" .. tostring(sb:typeOf("LSpriteBatch"))); sb:release()
end

--- Render Module Part 6: module-level functions (clear, color, blend, canvas, shader, transforms, font, wireframe, dims, scissor, line/point)


--@api-stub: lurek.render.getBackgroundColor
do
    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b = lurek.render.getBackgroundColor()
    print("bg=" .. r .. "," .. g .. "," .. b)
end

--@api-stub: lurek.render.getBlendMode
do
    lurek.render.setBlendMode("alpha")
    local mode = lurek.render.getBlendMode()
    print("blend=" .. mode)
end

--@api-stub: lurek.render.getColor
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.render.getHeight
do
    local w, h = lurek.render.getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. lurek.render.getWidth())
    print("h=" .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getWidth
do
    local w, h = lurek.render.getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. lurek.render.getWidth())
    print("h=" .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getFont
do
    local f = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    lurek.render.setFont(f)
    local cur = lurek.render.getFont()
    print("font=" .. tostring(cur ~= nil))
end

--@api-stub: lurek.render.getScissor
do
    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    print("scissor=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor(0, 0, 0, 0)
end

--@api-stub: lurek.render.getShader
do
    local code = "vec4 effect(vec4 c, Image t, vec2 uv, vec2 fc) { return Texel(t, uv) * c; }"; local sh = lurek.render.newShader(code)
    lurek.render.setShader(sh)
    local cur = lurek.render.getShader()
    print("shader=" .. tostring(cur ~= nil))
    lurek.render.setShader(nil)
end

--@api-stub: lurek.render.setShader
do
    local code = "vec4 effect(vec4 c, Image t, vec2 uv, vec2 fc) { return Texel(t, uv) * c; }"; local sh = lurek.render.newShader(code)
    lurek.render.setShader(sh)
    local cur = lurek.render.getShader()
    print("shader=" .. tostring(cur ~= nil))
    lurek.render.setShader(nil)
end

--@api-stub: lurek.render.isWireframe
do
    lurek.render.setWireframe(true)
    print("wireframe=" .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(false)
end

--@api-stub: lurek.render.pop
do
    lurek.render.push(); lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4); lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0); lurek.render.draw(lurek.render.newImage("content/examples/assets/images/sample_texture.png"), 0, 0)
    lurek.render.pop()
    print("transform stack ok")
end

--@api-stub: lurek.render.rotate
do
    lurek.render.push(); lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4); lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0); lurek.render.draw(lurek.render.newImage("content/examples/assets/images/sample_texture.png"), 0, 0)
    lurek.render.pop()
    print("transform stack ok")
end

--@api-stub: lurek.render.scale
do
    lurek.render.push(); lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4); lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0); lurek.render.draw(lurek.render.newImage("content/examples/assets/images/sample_texture.png"), 0, 0)
    lurek.render.pop()
    print("transform stack ok")
end

--@api-stub: lurek.render.translate
do
    lurek.render.push(); lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4); lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0); lurek.render.draw(lurek.render.newImage("content/examples/assets/images/sample_texture.png"), 0, 0)
    lurek.render.pop()
    print("transform stack ok")
end

--@api-stub: LImage:getDimensions
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local w, h = img:getDimensions() local w2 = img:getWidth() local h2 = img:getHeight() print("image dims:", w, h) end
    print("LImage size API tested")
end

--@api-stub: LImage:getWidth
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local w, h = img:getDimensions() local w2 = img:getWidth() local h2 = img:getHeight() print("image dims:", w, h) end
    print("LImage size API tested")
end

--@api-stub: LImage:getHeight
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local w, h = img:getDimensions() local w2 = img:getWidth() local h2 = img:getHeight() print("image dims:", w, h) end
    print("LImage size API tested")
end

--@api-stub: LNineSlice:getInsets
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4) local t, r, b, l = ns:getInsets() local tw, th = ns:getTextureSize() local tp = ns:type() print("nineslice insets:", t, r, b, l, "type:", tp) end
    print("LNineSlice tested")
end

--@api-stub: LNineSlice:getTextureSize
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4) local t, r, b, l = ns:getInsets() local tw, th = ns:getTextureSize() local tp = ns:type() print("nineslice insets:", t, r, b, l, "type:", tp) end
    print("LNineSlice tested")
end

--@api-stub: LNineSlice:type
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4) local t, r, b, l = ns:getInsets() local tw, th = ns:getTextureSize() local tp = ns:type() print("nineslice insets:", t, r, b, l, "type:", tp) end
    print("LNineSlice tested")
end

--@api-stub: LNineSlice:typeOf
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 2, 2, 2, 2) local ok = ns:typeOf("LNineSlice") print("NineSlice typeOf:", ok) end
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local fc = model:getFaceCount() local nc = model:getNormalCount() print("model faces:", fc, "normals:", nc) end
    print("NineSlice typeOf + LObjModel tested")
end

--@api-stub: LObjModel:getFaceCount
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 2, 2, 2, 2) local ok = ns:typeOf("LNineSlice") print("NineSlice typeOf:", ok) end
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local fc = model:getFaceCount() local nc = model:getNormalCount() print("model faces:", fc, "normals:", nc) end
    print("NineSlice typeOf + LObjModel tested")
end

--@api-stub: LObjModel:getNormalCount
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then local ns = lurek.render.newNineSlice(img, 2, 2, 2, 2) local ok = ns:typeOf("LNineSlice") print("NineSlice typeOf:", ok) end
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local fc = model:getFaceCount() local nc = model:getNormalCount() print("model faces:", fc, "normals:", nc) end
    print("NineSlice typeOf + LObjModel tested")
end

--@api-stub: LObjModel:getUvCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local uv = model:getUvCount() local vc = model:getVertexCount() print("model uvs:", uv, "verts:", vc) end
    local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local tw, th = q:getTextureDimensions()
    print("quad tex dims:", tw, th, "LObjModel + LQuad tested")
end

--@api-stub: LObjModel:getVertexCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local uv = model:getUvCount() local vc = model:getVertexCount() print("model uvs:", uv, "verts:", vc) end
    local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local tw, th = q:getTextureDimensions()
    print("quad tex dims:", tw, th, "LObjModel + LQuad tested")
end

--@api-stub: LQuad:getTextureDimensions
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    if model then local uv = model:getUvCount() local vc = model:getVertexCount() print("model uvs:", uv, "verts:", vc) end
    local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local tw, th = q:getTextureDimensions()
    print("quad tex dims:", tw, th, "LObjModel + LQuad tested")
end

--@api-stub: LQuad:setViewport
do
    local q = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    q:setViewport(0, 0, 32, 32)
    local x, y, w, h = q:getViewport()
    print("quad viewport:", x, y, w, h)
end

--@api-stub: LShape:arc
do
    local s = lurek.render.newShape(); s:setColor(1, 0.5, 0, 1)
    s:arc("fill", 100, 100, 40, 0, math.pi)
    s:circle("line", 200, 200, 30)
    local c = s:getCommandCount()
    print("shape cmds:", c)
end

--@api-stub: LShape:circle
do
    local s = lurek.render.newShape(); s:setColor(1, 0.5, 0, 1)
    s:arc("fill", 100, 100, 40, 0, math.pi)
    s:circle("line", 200, 200, 30)
    local c = s:getCommandCount()
    print("shape cmds:", c)
end

--@api-stub: LShape:setColor
do
    local s = lurek.render.newShape(); s:setColor(1, 0.5, 0, 1)
    s:arc("fill", 100, 100, 40, 0, math.pi)
    s:circle("line", 200, 200, 30)
    local c = s:getCommandCount()
    print("shape cmds:", c)
end

--@api-stub: LShape:ellipse
do
    local s = lurek.render.newShape(); s:ellipse("fill", 100, 100, 50, 30)
    s:line(10, 10, 90, 90)
    s:rectangle("fill", 20, 20, 60, 40)
    local c = s:getCommandCount()
    print("shape ellipse+line+rect cmds:", c)
end

--@api-stub: LShape:line
do
    local s = lurek.render.newShape(); s:ellipse("fill", 100, 100, 50, 30)
    s:line(10, 10, 90, 90)
    s:rectangle("fill", 20, 20, 60, 40)
    local c = s:getCommandCount()
    print("shape ellipse+line+rect cmds:", c)
end

--@api-stub: LShape:rectangle
do
    local s = lurek.render.newShape(); s:ellipse("fill", 100, 100, 50, 30)
    s:line(10, 10, 90, 90)
    s:rectangle("fill", 20, 20, 60, 40)
    local c = s:getCommandCount()
    print("shape ellipse+line+rect cmds:", c)
end

--@api-stub: LShape:triangle
do
    local s = lurek.render.newShape(); s:setLineWidth(2)
    s:triangle("line", 0, 0, 50, 0, 25, 50)
    s:draw(100, 100, 0, 1, 1, 0, 0)
    local c = s:getCommandCount()
    print("shape triangle+draw cmds:", c)
end

--@api-stub: LShape:draw
do
    local s = lurek.render.newShape(); s:setLineWidth(2)
    s:triangle("line", 0, 0, 50, 0, 25, 50)
    s:draw(100, 100, 0, 1, 1, 0, 0)
    local c = s:getCommandCount()
    print("shape triangle+draw cmds:", c)
end

--@api-stub: LShape:setLineWidth
do
    local s = lurek.render.newShape(); s:setLineWidth(2)
    s:triangle("line", 0, 0, 50, 0, 25, 50)
    s:draw(100, 100, 0, 1, 1, 0, 0)
    local c = s:getCommandCount()
    print("shape triangle+draw cmds:", c)
end

--@api-stub: LShape:getCommandCount
do
    local s = lurek.render.newShape(); s:circle("fill", 0, 0, 10)
    s:circle("fill", 50, 50, 10); local before = s:getCommandCount()
    s:clear()
    local after = s:getCommandCount()
    print("getCommandCount before:", before, "after clear:", after)
end

--@api-stub: LDrawLayer:flush
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

--@api-stub: LDrawLayer:getCount
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

--@api-stub: LDrawLayer:queue
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
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then lurek.render.draw(img, 10, 10, 0, 1, 1) local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64) if q then lurek.render.drawq(img, q, 50, 50, 0, 1, 1) end local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4) if ns then lurek.render.drawNineSlice(ns, 100, 100, 80, 60) end end
    print("draw, drawq, drawNineSlice tested")
end

--@api-stub: lurek.render.drawNineSlice
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    if img then lurek.render.draw(img, 10, 10, 0, 1, 1) local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64) if q then lurek.render.drawq(img, q, 50, 50, 0, 1, 1) end local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4) if ns then lurek.render.drawNineSlice(ns, 100, 100, 80, 60) end end
    print("draw, drawq, drawNineSlice tested")
end

--@api-stub: lurek.render.clearStencil
do
    lurek.render.drawQuadBezier(0, 0, 100, 50, 200, 0, 20)
    lurek.render.clearStencil()
    local layer = lurek.render.currentLayer()
    print("bezier drawn, stencil cleared, layer:", layer)
end

--@api-stub: lurek.render.currentLayer
do
    lurek.render.drawQuadBezier(0, 0, 100, 50, 200, 0, 20)
    lurek.render.clearStencil()
    local layer = lurek.render.currentLayer()
    print("bezier drawn, stencil cleared, layer:", layer)
end

--@api-stub: lurek.render.flushSortGroup
do
    lurek.render.pushSortKey(5); lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(0)
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.popLayer(99)
    print("flushSortGroup, pushSortKey, popLayer tested")
end

--@api-stub: lurek.render.pushSortKey
do
    lurek.render.pushSortKey(5); lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(0)
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.popLayer(99)
    print("flushSortGroup, pushSortKey, popLayer tested")
end

--@api-stub: lurek.render.popLayer
do
    lurek.render.pushSortKey(5); lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(0)
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.popLayer(99)
    print("flushSortGroup, pushSortKey, popLayer tested")
end

--@api-stub: lurek.render.getCanvasSize
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    local rm, gm, bm, am = lurek.render.getColorMask()
    local min_f, mag_f, aniso = lurek.render.getDefaultFilter()
    print("canvas size:", w, h, "color mask r:", rm, "filter:", min_f)
end

--@api-stub: lurek.render.getColorMask
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    local rm, gm, bm, am = lurek.render.getColorMask()
    local min_f, mag_f, aniso = lurek.render.getDefaultFilter()
    print("canvas size:", w, h, "color mask r:", rm, "filter:", min_f)
end

--@api-stub: lurek.render.getDefaultFilter
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    local rm, gm, bm, am = lurek.render.getColorMask()
    local min_f, mag_f, aniso = lurek.render.getDefaultFilter()
    print("canvas size:", w, h, "color mask r:", rm, "filter:", min_f)
end

--@api-stub: lurek.render.getDepthMode
do
    local depth_mode, depth_write = lurek.render.getDepthMode()
    local font = lurek.render.getDefaultFont(14)
    local cw = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    print("depth:", depth_mode, depth_write, "cell_w:", cw, "descent:", descent)
end

--@api-stub: lurek.render.getFontCellWidth
do
    local depth_mode, depth_write = lurek.render.getDepthMode()
    local font = lurek.render.getDefaultFont(14)
    local cw = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    print("depth:", depth_mode, depth_write, "cell_w:", cw, "descent:", descent)
end

--@api-stub: lurek.render.getFontDescent
do
    local depth_mode, depth_write = lurek.render.getDepthMode()
    local font = lurek.render.getDefaultFont(14)
    local cw = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    print("depth:", depth_mode, depth_write, "cell_w:", cw, "descent:", descent)
end

--@api-stub: lurek.render.getFontHeight
do
    local font = lurek.render.getDefaultFont(14)
    local fh = lurek.render.getFontHeight(font)
    local flh = lurek.render.getFontLineHeight(font)
    local lw = lurek.render.getLineWidth()
    print("font height:", fh, "line height:", flh, "line width:", lw)
end

--@api-stub: lurek.render.getFontLineHeight
do
    local font = lurek.render.getDefaultFont(14)
    local fh = lurek.render.getFontHeight(font)
    local flh = lurek.render.getFontLineHeight(font)
    local lw = lurek.render.getLineWidth()
    print("font height:", fh, "line height:", flh, "line width:", lw)
end

--@api-stub: lurek.render.getStencilMode
do
    local action, compare, ref = lurek.render.getStencilMode()
    local visible = lurek.render.isLayerVisible("default")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    -- model may be nil if file doesn't exist; that's okay
    print("stencil:", action, compare, ref, "layer visible:", visible, "model:", model ~= nil)
end

--@api-stub: lurek.render.isLayerVisible
do
    local action, compare, ref = lurek.render.getStencilMode()
    local visible = lurek.render.isLayerVisible("default")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    -- model may be nil if file doesn't exist; that's okay
    print("stencil:", action, compare, ref, "layer visible:", visible, "model:", model ~= nil)
end

--@api-stub: lurek.render.loadModel
do
    local action, compare, ref = lurek.render.getStencilMode()
    local visible = lurek.render.isLayerVisible("default")
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    -- model may be nil if file doesn't exist; that's okay
    print("stencil:", action, compare, ref, "layer visible:", visible, "model:", model ~= nil)
end

--@api-stub: lurek.render.intersectScissor
do
    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    lurek.render.setScissor()
    print("intersectScissor ok")
end

--@api-stub: lurek.render.resetCanvas
do
    local canvas = lurek.render.newCanvas(64, 64); lurek.render.resetCanvas(canvas)
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("resetCanvas, saveScreenshot, setFontLineHeight ok")
end

--@api-stub: lurek.render.saveScreenshot
do
    local canvas = lurek.render.newCanvas(64, 64); lurek.render.resetCanvas(canvas)
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("resetCanvas, saveScreenshot, setFontLineHeight ok")
end

--@api-stub: lurek.render.setFontLineHeight
do
    local canvas = lurek.render.newCanvas(64, 64); lurek.render.resetCanvas(canvas)
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("resetCanvas, saveScreenshot, setFontLineHeight ok")
end

--@api-stub: lurek.render.setLayer
do
    local prev_layer = lurek.render.currentLayer(); lurek.render.setLayer("default")
    lurek.render.setLayerVisible("default", true)
    lurek.render.setLayerZOrder("default", 0)
    if prev_layer then lurek.render.setLayer(prev_layer) end
    print("setLayer, setLayerVisible, setLayerZOrder ok")
end

--@api-stub: lurek.render.setLayerVisible
do
    local prev_layer = lurek.render.currentLayer(); lurek.render.setLayer("default")
    lurek.render.setLayerVisible("default", true)
    lurek.render.setLayerZOrder("default", 0)
    if prev_layer then lurek.render.setLayer(prev_layer) end
    print("setLayer, setLayerVisible, setLayerZOrder ok")
end

--@api-stub: lurek.render.setLayerZOrder
do
    local prev_layer = lurek.render.currentLayer(); lurek.render.setLayer("default")
    lurek.render.setLayerVisible("default", true)
    lurek.render.setLayerZOrder("default", 0)
    if prev_layer then lurek.render.setLayer(prev_layer) end
    print("setLayer, setLayerVisible, setLayerZOrder ok")
end

--@api-stub: lurek.render.setStencilTest
do
    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest("always", 0)
    print("setStencilTest ok")
end

--@api-stub: lurek.render.setBold
do
    -- Sets whether text rendering should use a bold font variant if available.
    local prev = lurek.render.isBold()
    lurek.render.setBold(true)
    lurek.render.print("Bold text", 10, 10)
    lurek.render.setBold(prev)
end

--@api-stub: lurek.render.isBold
do
    -- Checks if the bold font variant is currently enabled for text rendering.
    local is_bold = lurek.render.isBold()
    print("Is bold: " .. tostring(is_bold))
end

print("content/examples/render.lua")

--@api-stub: lurek.render.printRotatedWithFont
do
    local font = lurek.render.getDefaultFont(16)
    -- Draws text rotated by 45 degrees
    lurek.render.printRotatedWithFont(font, "Rotated text", 100, 100, math.pi / 4, 1.0)
end

--@api-stub: lurek.render.printWithFont
do
    local font = lurek.render.getDefaultFont(16)
    -- Draws standard text using a specific font
    lurek.render.printWithFont(font, "Standard text override", 10, 150)
end

--@api-stub: lurek.render.printfWithFont
do
    local font = lurek.render.getDefaultFont(16)
    -- Draws formatted text with a specific font
    lurek.render.printfWithFont(font, "Formatted: %d %s", 10, 200, 42, "items")
end

--@api-stub: lurek.render.printRichWithFont
do
    local font = lurek.render.getDefaultFont(16)
    -- Draws rich text with styled span tables.
    lurek.render.printRichWithFont(font, {
        { text = "Red", r = 255, g = 0, b = 0, a = 255, scale = 1 },
        { text = " and ", r = 255, g = 255, b = 255, a = 255, scale = 1 },
        { text = "Green", r = 0, g = 255, b = 0, a = 255, scale = 1 },
    }, 10, 250)
end

--@api-stub: lurek.render.getBuiltInFontNames
do
    -- Lists available system/fallback fonts
    local names = lurek.render.getBuiltInFontNames()
    if #names > 0 then
        lurek.log.info("Available built-in fonts: " .. table.concat(names, ", "))
    end
end

