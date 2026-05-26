
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

--- Render Module Part 1: basic drawing - print, rectangle, circle, line, polygon, points, arc, ellipse, triangle

--@api-stub: lurek.render.print
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.print("Hello from lurek.render.print", 10, 10)
    print("print font type = " .. font:type())
    print("printed plain text")
end

--@api-stub: lurek.render.printf
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printf("Centered text inside a 220 px box.", 10, 40, 220, "center")
    print("printf limit = 220")
    print("printf align = center")
end

--@api-stub: lurek.render.printRotated
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printRotated("Rotated text", 180, 90, math.pi / 6, 1.0)
    print("printRotated angle = " .. tostring(math.pi / 6))
    print("rotated text drawn")
end

--@api-stub: lurek.render.printRich
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red ", r = 255, g = 80, b = 80, a = 255, scale = 1.0 },
        { text = "Green ", r = 80, g = 220, b = 120, a = 255, scale = 1.0 },
        { text = "Blue", r = 80, g = 120, b = 255, a = 255, scale = 1.2 },
    }
    lurek.render.setFont(font)
    lurek.render.printRich(spans, 10, 120)
    print("rich spans = " .. #spans)
    print("rich text uses u8 colors")
end

--@api-stub: lurek.render.rectangle
do
    lurek.render.setColor(1, 0.2, 0.2, 1)
    lurek.render.rectangle("fill", 40, 150, 100, 60)
    lurek.render.rectangle("line", 160, 150, 100, 60, 8)
    lurek.render.setColor(1, 1, 1, 1)
    print("rectangle fill and rounded line drawn")
    print("rectangle width = 100")
end

--@api-stub: lurek.render.circle
do
    lurek.render.setColor(1, 0.6, 0.1, 1)
    lurek.render.circle("fill", 340, 180, 30)
    lurek.render.setColor(0.2, 0.9, 1, 1)
    lurek.render.circle("line", 410, 180, 30)
    lurek.render.setColor(1, 1, 1, 1)
    print("circle radius = 30")
    print("circle fill and line drawn")
end

--@api-stub: lurek.render.ellipse
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 110, 250, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 240, 250, 40, 60)
    print("ellipse examples drawn")
    print("ellipse radii = 60x30 and 40x60")
end

--@api-stub: lurek.render.arc
do
    lurek.render.setColor(1, 0.8, 0.1, 1)
    lurek.render.arc("fill", 360, 250, 36, 0, math.pi)
    lurek.render.setColor(0.2, 0.9, 0.4, 1)
    lurek.render.arc("line", 450, 250, 36, math.pi, math.pi * 1.75, 20)
    lurek.render.setColor(1, 1, 1, 1)
    print("arc segments = 20 on line arc")
    print("arc examples drawn")
end

--@api-stub: lurek.render.line
do
    lurek.render.setColor(1, 1, 0.2, 1)
    lurek.render.line(10, 320, 160, 320)
    lurek.render.setColor(0.1, 0.9, 1, 1)
    lurek.render.line(10, 340, 40, 360, 70, 340, 100, 360, 130, 340, 160, 360)
    lurek.render.setColor(1, 1, 1, 1)
    print("line and polyline drawn")
    print("polyline points = 6")
end

--@api-stub: lurek.render.polygon
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    print("polygon vertices = 5")
    print("polygon fill and line drawn")
end

--@api-stub: lurek.render.triangle
do
    lurek.render.setColor(0.1, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 360, 350, 410, 280, 460, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 480, 350, 530, 280, 580, 350)
    print("triangle fill and line drawn")
    print("triangle count = 2")
end

--@api-stub: lurek.render.points
do
    lurek.render.setPointSize(5)
    lurek.render.setColor(1, 0.1, 0.1, 1)
    lurek.render.points(20, 390, 40, 390, 60, 390, 80, 390)
    lurek.render.setColor(0.1, 0.1, 1, 1)
    lurek.render.points({ { 120, 390 }, { 140, 390 }, { 160, 390 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
    print("point size reset to 1")
    print("points drawn with flat and table inputs")
end

--@api-stub: lurek.render.setLineWidth
do
    lurek.render.setLineWidth(4)
    lurek.render.line(200, 390, 280, 390)
    print("line width set to 4")
    lurek.render.setLineWidth(1)
    print("line width restored to 1")
end

--@api-stub: lurek.render.getLineWidth
do
    lurek.render.setLineWidth(3)
    local width = lurek.render.getLineWidth()
    print("line width = " .. tostring(width))
    lurek.render.setLineWidth(1)
    print("line width restored")
end

--@api-stub: lurek.render.setPointSize
do
    lurek.render.setPointSize(6)
    lurek.render.points(320, 390, 340, 390, 360, 390)
    print("point size set to 6")
    lurek.render.setPointSize(1)
    print("point size restored")
end

--@api-stub: lurek.render.getPointSize
do
    lurek.render.setPointSize(7)
    local size = lurek.render.getPointSize()
    print("point size = " .. tostring(size))
    lurek.render.setPointSize(1)
    print("point size restored")
end

--@api-stub: lurek.render.drawCubicBezier
do
    lurek.render.setColor(1, 0.5, 0.1, 1)
    lurek.render.drawCubicBezier(20, 440, 60, 390, 120, 490, 160, 440, 24)
    lurek.render.setColor(1, 1, 1, 1)
    print("cubic bezier segments = 24")
    print("cubic bezier drawn")
end

--@api-stub: lurek.render.drawQuadBezier
do
    lurek.render.setColor(0.1, 1, 0.5, 1)
    lurek.render.drawQuadBezier(210, 440, 270, 390, 330, 440, 18)
    lurek.render.setColor(1, 1, 1, 1)
    print("quad bezier segments = 18")
    print("quad bezier drawn")
end

--@api-stub: lurek.render.drawPath
do
    local path = {
        { type = "moveTo", x = 380, y = 430 },
        { type = "lineTo", x = 430, y = 410 },
        { type = "quadTo", cx = 470, cy = 390, x = 500, y = 430 },
        { type = "cubicTo", cx1 = 500, cy1 = 470, cx2 = 420, cy2 = 470, x = 380, y = 450 },
    }
    lurek.render.setColor(0.6, 0.2, 1, 1)
    lurek.render.drawPath(path, "line", true)
    lurek.render.setColor(1, 1, 1, 1)
    print("path segments = " .. #path)
    print("path closed = true")
end

--@api-stub: lurek.render.drawGradientRect
do
    lurek.render.drawGradientRect(10, 500, 120, 36, { 1, 0, 0, 1 }, { 0, 0, 1, 1 }, "horizontal")
    lurek.render.drawGradientRect(150, 500, 120, 36, { 0, 1, 0, 1 }, { 1, 1, 0, 1 }, "vertical")
    print("gradient directions = horizontal, vertical")
    print("gradient rectangles drawn")
end

--@api-stub: lurek.render.drawColoredPolygon
do
    local vertices = { 320, 500, 380, 500, 400, 540, 300, 540 }
    local colors = {
        { 1, 0, 0, 1 },
        { 0, 1, 0, 1 },
        { 0, 0, 1, 1 },
        { 1, 1, 0, 1 },
    }
    lurek.render.drawColoredPolygon(vertices, colors, "fill")
    print("colored polygon vertices = 4")
    print("colored polygon drawn")
end

--@api-stub: lurek.render.drawHexTile
do
    lurek.render.setColor(0.1, 0.7, 0.5, 1)
    lurek.render.drawHexTile(480, 520, 24, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(550, 520, 24, "flatTop", "line")
    print("hex tile orientations = pointyTop, flatTop")
    print("hex tiles drawn")
end

--@api-stub: lurek.render.drawBevelRect
do
    lurek.render.drawBevelRect(10, 560, 90, 32, 3, "raised")
    lurek.render.drawBevelRect(120, 560, 90, 32, 3, "sunken")
    lurek.render.drawBevelRect(230, 560, 90, 32, 2, "flat", {
        fillColor = { 0.2, 0.3, 0.8, 1 },
        highlight = { 1, 1, 1, 1 },
        shadow = { 0.2, 0.2, 0.3, 1 },
    })
    print("bevel styles = raised, sunken, flat")
    print("bevel rectangles drawn")
end


--- Render Module Part 2: color state, transforms, scissor, clear, blend modes, wireframe, layers, depth

--@api-stub: lurek.render.setColor
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.rectangle("fill", 340, 10, 40, 20)
    lurek.render.setColor(1, 1, 1, 1)
    print("color restored to white")
end

--@api-stub: lurek.render.setBackgroundColor
do
    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
    print("background restored to black")
end

--@api-stub: lurek.render.setColorMask
do
    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
    print("color mask restored")
end

--@api-stub: lurek.render.push
do
    lurek.render.push()
    lurek.render.translate(80, 80)
    lurek.render.rotate(math.pi / 8)
    lurek.render.scale(1.2, 0.8)
    lurek.render.rectangle("line", -20, -20, 40, 40)
    lurek.render.pop()
    print("transform stack push/pop used")
    print("translated, rotated, and scaled rectangle")
end

--@api-stub: lurek.render.shear
do
    lurek.render.push()
    lurek.render.translate(180, 80)
    lurek.render.shear(0.3, 0.0)
    lurek.render.rectangle("fill", 0, 0, 70, 30)
    lurek.render.pop()
    print("shear kx = 0.3")
    print("sheared rectangle drawn")
end

--@api-stub: lurek.render.origin
do
    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 12, 12)
    lurek.render.pop()
    print("origin reset applied")
    print("origin rectangle drawn at screen origin")
end

--@api-stub: lurek.render.applyTransform
do
    local matrix = { 1, 0, 0, 0, 1, 0, 60, 120, 1 }
    lurek.render.push()
    lurek.render.applyTransform(matrix)
    lurek.render.rectangle("fill", 0, 0, 36, 36)
    lurek.render.pop()
    print("applyTransform matrix entries = " .. #matrix)
    print("flat 3x3 matrix applied")
end

--@api-stub: lurek.render.setScissor
do
    lurek.render.setScissor(20, 140, 120, 60)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("fill", 0, 120, 180, 90)
    lurek.render.intersectScissor(50, 150, 70, 30)
    lurek.render.rectangle("line", 0, 120, 180, 90)
    lurek.render.setScissor()
    print("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("scissor cleared")
end

--@api-stub: lurek.render.clear
do
    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    print("render command queue cleared")
    print("clear called after a draw")
end

--@api-stub: lurek.render.setBlendMode
do
    local before = lurek.render.getBlendMode()
    lurek.render.setBlendMode("add")
    lurek.render.rectangle("fill", 180, 140, 40, 40)
    lurek.render.setBlendMode("multiply")
    lurek.render.rectangle("fill", 200, 160, 40, 40)
    lurek.render.setBlendMode("alpha")
    print("blend before = " .. before)
    print("blend restored to alpha")
end

--@api-stub: lurek.render.setWireframe
do
    print("wireframe before = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 260, 140, 50, 50)
    lurek.render.setWireframe(false)
    print("wireframe restored = " .. tostring(lurek.render.isWireframe()))
end

--@api-stub: lurek.render.newLayer
do
    lurek.render.newLayer("background", 0)
    lurek.render.newLayer("foreground", 10)
    lurek.render.setLayer("foreground")
    print("current layer = " .. lurek.render.currentLayer())
    print("foreground z = " .. lurek.render.getLayerZOrder("foreground"))
end

--@api-stub: lurek.render.getLayerZOrder
do
    lurek.render.newLayer("midground", 5)
    print("midground z before = " .. lurek.render.getLayerZOrder("midground"))
    lurek.render.setLayerZOrder("midground", 15)
    print("midground z after = " .. lurek.render.getLayerZOrder("midground"))
end

--@api-stub: lurek.render.pushLayer
do
    lurek.render.pushLayer(1, 0.65, "alpha")
    lurek.render.rectangle("fill", 320, 140, 60, 40)
    lurek.render.popLayer(1)
    print("pushLayer id = 1")
    print("popLayer matched id = 1")
end

--@api-stub: lurek.render.beginSortGroup
do
    lurek.render.beginSortGroup(1)
    lurek.render.pushSortKey(10)
    lurek.render.rectangle("fill", 400, 140, 30, 30)
    lurek.render.pushSortKey(5)
    lurek.render.rectangle("fill", 410, 150, 30, 30)
    lurek.render.flushSortGroup(1)
    print("sort group id = 1")
    print("sort keys 10 and 5 queued")
end

--@api-stub: lurek.render.setDepthMode
do
    local mode_before, write_before = lurek.render.getDepthMode()
    lurek.render.setDepthMode("lequal", true)
    local mode_after, write_after = lurek.render.getDepthMode()
    print("depth before = " .. mode_before .. "," .. tostring(write_before))
    print("depth after = " .. mode_after .. "," .. tostring(write_after))
    lurek.render.setDepthMode("always", false)
end

--@api-stub: lurek.render.setDefaultFilter
do
    local min_before, mag_before, aniso_before = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    local min_after, mag_after, aniso_after = lurek.render.getDefaultFilter()
    print("filter before = " .. min_before .. "," .. mag_before .. "," .. aniso_before)
    print("filter after = " .. min_after .. "," .. mag_after .. "," .. aniso_after)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end

--@api-stub: lurek.render.getDimensions
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth() .. ", height = " .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getStats
do
    local stats = lurek.render.getStats()
    print("drawcalls = " .. tostring(stats.drawcalls))
    print("textures = " .. tostring(stats.textures) .. ", canvases = " .. tostring(stats.canvases))
    print("gpu_draw_calls = " .. tostring(stats.gpu_draw_calls))
end


--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice

--@api-stub: lurek.render.newImage
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    lurek.render.draw(image, 10, 10)
    lurek.render.draw(image, 90, 10, math.pi / 8, 0.5, 0.5)
    print("image size = " .. w .. "x" .. h)
    print("newImage handle ready")
end

--@api-stub: LImage:getId
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image id = " .. image:getId())
    print("image type = " .. image:type())
    image:release()
end

--@api-stub: LImage:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image type = " .. image:type())
    print("is LImage = " .. tostring(image:typeOf("LImage")))
    image:release()
end

--@api-stub: LImage:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image typeOf LImage = " .. tostring(image:typeOf("LImage")))
    print("image typeOf LObject = " .. tostring(image:typeOf("LObject")))
    image:release()
end

--@api-stub: LImage:release
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local released = image:release()
    print("image released = " .. tostring(released))
    print("release tested on LImage")
end

--@api-stub: lurek.render.newCanvas
do
    local canvas = lurek.render.newCanvas(96, 96)
    local w, h = canvas:getDimensions()
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 24)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 10, 70)
    print("canvas size = " .. w .. "x" .. h)
    print("canvas rendered and drawn back")
end

--@api-stub: LCanvas:type
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("canvas type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    canvas:release()
end

--@api-stub: LCanvas:typeOf
do
    local canvas = lurek.render.newCanvas(64, 64)
    print("canvas typeOf LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    print("canvas typeOf LObject = " .. tostring(canvas:typeOf("LObject")))
    canvas:release()
end

--@api-stub: LCanvas:release
do
    local canvas = lurek.render.newCanvas(64, 64)
    local released = canvas:release()
    print("canvas released = " .. tostring(released))
    print("canvas release tested")
end

--@api-stub: lurek.render.getCanvas
do
    local canvas = lurek.render.newCanvas(120, 80)
    lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas()
    local w, h = lurek.render.getCanvasSize(canvas)
    lurek.render.setCanvas(nil)
    lurek.render.resetCanvas(canvas)
    print("active canvas exists = " .. tostring(active ~= nil))
    print("canvas size = " .. w .. "x" .. h)
end

--@api-stub: lurek.render.newQuad
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sw, sh = image:getDimensions()
    local quad = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    local x, y, w, h = quad:getViewport()
    lurek.render.drawq(image, quad, 10, 170)
    print("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("quad texture dims = " .. sw .. "x" .. sh)
end

--@api-stub: LQuad:type
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("quad type = " .. quad:type())
    print("quad typeOf LQuad = " .. tostring(quad:typeOf("LQuad")))
end

--@api-stub: LQuad:typeOf
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("quad typeOf LQuad = " .. tostring(quad:typeOf("LQuad")))
    print("quad typeOf LObject = " .. tostring(quad:typeOf("LObject")))
end

--@api-stub: lurek.render.newSpriteBatch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 16)
    local last = batch:add(60, 220, 0, 0.5, 0.5, 0, 0)
    batch:add(90, 220, math.pi / 8, 0.5, 0.5, 0, 0)
    lurek.render.draw(batch, 0, 0)
    print("sprite batch count = " .. batch:getCount())
    print("last sprite index = " .. tostring(last))
end

--@api-stub: LSpriteBatch:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    print("batch type = " .. batch:type())
    print("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--@api-stub: LSpriteBatch:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    print("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    print("batch typeOf LObject = " .. tostring(batch:typeOf("LObject")))
    batch:release()
end

--@api-stub: LSpriteBatch:release
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local released = batch:release()
    print("batch released = " .. tostring(released))
    print("batch release tested")
end

--@api-stub: lurek.render.drawMany
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local list = {
        { image, 10, 270, 0, 0.3, 0.3, 0, 0 },
        { image, 40, 270, math.pi / 8, 0.3, 0.3, 0, 0 },
        { image, 70, 270, math.pi / 4, 0.3, 0.3, 0, 0 },
    }
    lurek.render.drawMany(list)
    print("drawMany entries = " .. #list)
    print("drawMany issued")
end

--@api-stub: lurek.render.newNineSlice
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    lurek.render.drawNineSlice(slice, 10, 310, 140, 48)
    print("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    print("nine-slice drawn")
end

--@api-stub: lurek.render.newDrawLayer
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(10, function()
        lurek.render.rectangle("fill", 180, 310, 20, 20)
    end)
    layer:queue(5, function()
        lurek.render.rectangle("fill", 190, 320, 20, 20)
    end)
    print("queued callbacks = " .. layer:getCount())
    layer:flush()
    print("queued callbacks after flush = " .. layer:getCount())
end

--@api-stub: LDrawLayer:clear
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() end)
    layer:queue(2, function() end)
    layer:clear()
    print("draw layer count after clear = " .. layer:getCount())
    print("draw layer type = " .. layer:type())
end

--@api-stub: LDrawLayer:type
do
    local layer = lurek.render.newDrawLayer()
    print("draw layer type = " .. layer:type())
    print("draw layer typeOf LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end

--@api-stub: LDrawLayer:typeOf
do
    local layer = lurek.render.newDrawLayer()
    print("draw layer typeOf LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
    print("draw layer typeOf LObject = " .. tostring(layer:typeOf("LObject")))
end

--@api-stub: lurek.render.drawIsoCubeTile
do
    lurek.render.drawIsoCubeTile(300, 330, 28, 14, {
        depth = 18,
        topColor = { 0.8, 0.8, 0.9, 1 },
        leftColor = { 0.5, 0.5, 0.6, 1 },
        rightColor = { 0.3, 0.3, 0.4, 1 },
    })
    print("iso cube tile depth = 18")
    print("iso cube tile drawn")
end


--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api-stub: lurek.render.newShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("shader type = " .. shader:type())
    print("newShader compiled minimal fragment shader")
end

--@api-stub: LShader:send
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 1.5)
    print("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
end

--@api-stub: LShader:setShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 380, 30, 20)
    print("active shader exists = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    print("shader cleared")
end

--@api-stub: LShader:getShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    local active = lurek.render.getShader()
    print("getShader returned handle = " .. tostring(active ~= nil))
    lurek.render.setShader(nil)
    print("shader restored to default")
end

--@api-stub: LShader:release
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    print("shader released = " .. tostring(released))
    print("shader release tested")
end

--@api-stub: lurek.render.newMesh
do
    local verts = {
        { 0, 0, 0, 0, 1, 0, 0, 1 },
        { 60, 0, 1, 0, 0, 1, 0, 1 },
        { 30, 50, 0.5, 1, 0, 0, 1, 1 },
    }
    local mesh = lurek.render.newMesh(verts, "triangles")
    lurek.render.draw(mesh, 70, 380)
    print("mesh vertex count = " .. mesh:getVertexCount())
    print("newMesh created triangles mesh")
end

--@api-stub: LMesh:setVertex
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    print("mesh v1 = " .. x .. "," .. y .. "," .. r .. "," .. g .. "," .. b .. "," .. a)
    print("setVertex applied to index 1")
end

--@api-stub: LMesh:getVertex
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    local x, y, u, v, r, g, b, a = mesh:getVertex(2)
    print("mesh v2 = " .. x .. "," .. y .. "," .. u .. "," .. v)
    print("mesh v2 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LMesh:setTexture
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    print("mesh texture set from image")
    print("mesh type = " .. mesh:type())
end

--@api-stub: LMesh:release
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh released = " .. tostring(mesh:release()))
    print("mesh release tested")
end

--@api-stub: LMesh:type
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh type = " .. mesh:type())
    print("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
end

--@api-stub: LMesh:typeOf
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    print("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
    print("mesh typeOf LObject = " .. tostring(mesh:typeOf("LObject")))
end

--@api-stub: lurek.render.newShape
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0, 0, 1)
    shape:rectangle("fill", 0, 0, 40, 24)
    shape:setColor(0, 1, 0, 1)
    shape:circle("line", 60, 12, 12)
    shape:draw(170, 380)
    print("shape command count = " .. shape:getCommandCount())
    print("newShape drew retained commands")
end

--@api-stub: LShape:polygon
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30)
    shape:draw(250, 380)
    print("shape polygon commands = " .. shape:getCommandCount())
    print("shape polygon drawn")
end

--@api-stub: LShape:polyline
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(3)
    shape:polyline(0, 0, 20, 20, 40, 0, 60, 20)
    shape:draw(330, 380)
    print("shape polyline commands = " .. shape:getCommandCount())
    print("shape polyline drawn")
end

--@api-stub: LShape:roundedRectangle
do
    local shape = lurek.render.newShape()
    shape:setColor(0.5, 0.5, 1, 1)
    shape:roundedRectangle("line", 0, 0, 70, 36, 8)
    shape:draw(410, 380)
    print("shape rounded rectangle commands = " .. shape:getCommandCount())
    print("shape rounded rectangle drawn")
end

--@api-stub: LShape:clear
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5)
    print("shape commands before clear = " .. shape:getCommandCount())
    shape:clear()
    print("shape commands after clear = " .. shape:getCommandCount())
end

--@api-stub: LShape:type
do
    local shape = lurek.render.newShape()
    print("shape type = " .. shape:type())
    print("shape typeOf LShape = " .. tostring(shape:typeOf("LShape")))
end

--@api-stub: LShape:typeOf
do
    local shape = lurek.render.newShape()
    print("shape typeOf LShape = " .. tostring(shape:typeOf("LShape")))
    print("shape typeOf LObject = " .. tostring(shape:typeOf("LObject")))
end

--@api-stub: lurek.render.loadObj
do
    local model = lurek.render.loadObj("content/examples/assets/models/sample_tank.obj")
    print("obj faces = " .. model:getFaceCount())
    print("obj vertices = " .. model:getVertexCount())
end

--@api-stub: LObjModel:projectToMesh
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local camera = { x = 0, y = 0, z = -5, tx = 0, ty = 0, tz = 0, fov = 60 }
    local vertices = model:projectToMesh(camera, 320, 240)
    print("projected vertex rows = " .. #vertices)
    print("projectToMesh camera fov = " .. camera.fov)
end

--@api-stub: LObjModel:renderToImage
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local image = model:renderToImage(64, 64, 0)
    lurek.render.draw(image, 500, 370)
    print("rendered model image = " .. image:getWidth() .. "x" .. image:getHeight())
    print("renderToImage rotation step = 0")
end


--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density

--@api-stub: lurek.render.newFont
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("newFont built-in size 16", 10, 430)
    print("newFont type = " .. font:type())
    print("newFont built from bundled size selector")
end

--@api-stub: lurek.render.getDefaultFont
do
    local font = lurek.render.getDefaultFont(24)
    lurek.render.setFont(font)
    lurek.render.print("Default font size 24", 10, 455)
    print("default font height = " .. font:getHeight())
    print("default font fetched by point size")
end

--@api-stub: lurek.render.setDefaultFont
do
    local regular = lurek.render.setDefaultFont(10, false)
    local bold = lurek.render.setDefaultFont(10, true)
    lurek.render.setFont(regular)
    print("regular height = " .. regular:getHeight())
    print("bold height = " .. bold:getHeight())
end

--@api-stub: LFont:getWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font width of Hello = " .. font:getWidth("Hello"))
    print("font height = " .. font:getHeight())
end

--@api-stub: LFont:getHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font height = " .. font:getHeight())
    print("font line height = " .. font:getLineHeight())
end

--@api-stub: LFont:getLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font line height = " .. font:getLineHeight())
    print("font ascent = " .. font:getAscent())
end

--@api-stub: LFont:getAscent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font ascent = " .. font:getAscent())
    print("font descent = " .. font:getDescent())
end

--@api-stub: LFont:getDescent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("font descent = " .. font:getDescent())
    print("font width of Test = " .. font:getWidth("Test"))
end

--@api-stub: LFont:getWrap
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    local lines, width = font:getWrap("This is a wrapped sentence for the font object.", 120)
    print("wrapped lines = " .. #lines)
    print("wrapped width = " .. width)
end

--@api-stub: LFont:setLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    font:setLineHeight(1.5)
    print("font line height = " .. font:getLineHeight())
    print("font setLineHeight applied")
end

--@api-stub: LFont:release
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    print("font released = " .. tostring(font:release()))
    print("font release tested")
end

--@api-stub: lurek.render.getFontSizes
do
    local sizes = lurek.render.getFontSizes()
    print("font sizes count = " .. #sizes)
    print("first bundled size = " .. tostring(sizes[1]))
end

--@api-stub: lurek.render.getFontWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    print("module getFontWidth = " .. lurek.render.getFontWidth(font, "Measure"))
    print("module getFontHeight = " .. lurek.render.getFontHeight(font))
end

--@api-stub: lurek.render.getFontAscent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("module ascent = " .. lurek.render.getFontAscent(font))
    print("module descent = " .. lurek.render.getFontDescent(font))
end

--@api-stub: lurek.render.getFontWrap
do
    local font = lurek.render.getDefaultFont(12)
    lurek.render.setFont(font)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    print("module wrapped lines = " .. #lines)
    print("module wrap width = " .. width)
end

--@api-stub: lurek.render.stencil
do
    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 220, 470, 24)
    lurek.render.setStencilTest("equal", 1)
    lurek.render.rectangle("fill", 190, 445, 60, 60)
    lurek.render.setStencilTest()
    print("stencil write value = 1")
    print("stencil test cleared")
end

--@api-stub: lurek.render.setStencilMode
do
    lurek.render.setStencilMode("replace", "always", 2)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
    print("stencil state cleared")
end

--@api-stub: lurek.render.captureScreenshot
do
    lurek.render.captureScreenshot(function(data)
        print("captureScreenshot size = " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/render_capture.png")
    print("captureScreenshot callback invoked")
    print("saveScreenshot requested")
end

--@api-stub: lurek.render.setCanvas
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 20)
    lurek.render.setCanvas(nil)
    print("setCanvas switched to off-screen target")
    print("setCanvas restored to screen")
end

--@api-stub: lurek.render.draw
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 280, 430, 0, 0.75, 0.75)
    print("draw used a canvas handle")
    print("draw scale = 0.75")
end

--@api-stub: lurek.render.setFont
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("setFont switched active font", 10, 500)
    print("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    print("setFont tested with built-in font")
end

--- Render Module Part 5: LCanvas, LFont release/type, LImage release/type, LMesh, LQuad getViewport/type, LShader, LSpriteBatch

--@api-stub: LCanvas:getDimensions
do
    local canvas = lurek.render.newCanvas(128, 64)
    local w, h = canvas:getDimensions()
    print("canvas dimensions = " .. w .. "x" .. h)
    print("canvas type = " .. canvas:type())
    canvas:release()
end

--@api-stub: LCanvas:getHeight
do
    local canvas = lurek.render.newCanvas(128, 64)
    print("canvas height = " .. canvas:getHeight())
    print("canvas dimensions = " .. canvas:getWidth() .. "x" .. canvas:getHeight())
    canvas:release()
end

--@api-stub: LCanvas:getWidth
do
    local canvas = lurek.render.newCanvas(128, 64)
    print("canvas width = " .. canvas:getWidth())
    print("canvas typeOf LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    canvas:release()
end

--@api-stub: LFont:type
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("font type = " .. font:type())
    print("font height = " .. font:getHeight())
    font:release()
end

--@api-stub: LFont:typeOf
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    print("font typeOf LFont = " .. tostring(font:typeOf("LFont")))
    print("font typeOf LObject = " .. tostring(font:typeOf("LObject")))
    font:release()
end

--@api-stub: LMesh:getVertexCount
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 100, 0, 1, 0, 1, 1, 1, 1 },
        { 50, 100, 0.5, 1, 1, 1, 1, 1 },
    }, "triangles")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    mesh:setVertex(1, { 10, 10, 0.1, 0.1, 1, 0.5, 0.5, 1 })
    print("mesh vertex count = " .. mesh:getVertexCount())
    print("mesh type = " .. mesh:type())
    mesh:release()
end

--@api-stub: LQuad:getViewport
do
    local quad = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = quad:getViewport()
    print("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    print("quad type = " .. quad:type())
end

--@api-stub: LShader:hasUniform
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    print("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 0.5)
    print("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api-stub: LShader:type
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    print("shader type = " .. shader:type())
    print("shader has u_time = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api-stub: LShader:typeOf
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    print("shader typeOf LShader = " .. tostring(shader:typeOf("LShader")))
    print("shader typeOf LObject = " .. tostring(shader:typeOf("LObject")))
    shader:release()
end

--@api-stub: LSpriteBatch:add
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    local id = batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    print("sprite id = " .. tostring(id))
    print("sprite count = " .. batch:getCount())
    batch:release()
end

--@api-stub: LSpriteBatch:clear
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    batch:clear()
    print("sprite count after clear = " .. batch:getCount())
    print("sprite batch type = " .. batch:type())
    batch:release()
end

--@api-stub: LSpriteBatch:getBufferSize
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    print("sprite batch buffer size = " .. batch:getBufferSize())
    print("sprite batch count = " .. batch:getCount())
    batch:release()
end

--@api-stub: LSpriteBatch:getCount
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    print("sprite batch count = " .. batch:getCount())
    print("sprite batch typeOf = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--- Render Module Part 6: module-level functions (clear, color, blend, canvas, shader, transforms, font, wireframe, dims, scissor, line/point)

--@api-stub: lurek.render.getBackgroundColor
do
    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end

--@api-stub: lurek.render.getBlendMode
do
    lurek.render.setBlendMode("alpha")
    print("blend mode = " .. lurek.render.getBlendMode())
end

--@api-stub: lurek.render.getColor
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.getHeight
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("height = " .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getWidth
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth())
end

--@api-stub: lurek.render.getFont
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    lurek.render.setFont(font)
    print("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    print("active font width of test = " .. font:getWidth("test"))
    font:release()
end

--@api-stub: lurek.render.getScissor
do
    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    print("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api-stub: lurek.render.getShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    print("getShader returned handle = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    shader:release()
end

--@api-stub: lurek.render.setShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 540, 24, 16)
    print("setShader activated custom shader")
    lurek.render.setShader(nil)
    print("shader restored to default")
    shader:release()
end

--@api-stub: lurek.render.isWireframe
do
    lurek.render.setWireframe(true)
    print("wireframe enabled = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(false)
    print("wireframe enabled after reset = " .. tostring(lurek.render.isWireframe()))
end

--@api-stub: lurek.render.pop
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("transform stack pop completed")
end

--@api-stub: lurek.render.rotate
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("rotation angle = " .. tostring(math.pi / 4))
end

--@api-stub: lurek.render.scale
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.scale(2, 2)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("scale = 2x2")
end

--@api-stub: lurek.render.translate
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    print("translation = 50,50")
end

--@api-stub: LImage:getDimensions
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    print("image dimensions = " .. w .. "x" .. h)
    print("image type = " .. image:type())
    image:release()
end

--@api-stub: LImage:getWidth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image width = " .. image:getWidth())
    print("image height = " .. image:getHeight())
    image:release()
end

--@api-stub: LImage:getHeight
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    print("image height = " .. image:getHeight())
    print("image width = " .. image:getWidth())
    image:release()
end

--@api-stub: LNineSlice:getInsets
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    print("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    print("nine-slice type = " .. slice:type())
    image:release()
end

--@api-stub: LNineSlice:getTextureSize
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local w, h = slice:getTextureSize()
    print("nine-slice texture size = " .. w .. "x" .. h)
    print("nine-slice typeOf = " .. tostring(slice:typeOf("LNineSlice")))
    image:release()
end

--@api-stub: LNineSlice:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    print("nine-slice type = " .. slice:type())
    print("nine-slice texture width = " .. select(1, slice:getTextureSize()))
    image:release()
end

--@api-stub: LNineSlice:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 2, 2, 2, 2)
    print("nine-slice typeOf LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
    print("nine-slice typeOf LObject = " .. tostring(slice:typeOf("LObject")))
    image:release()
end

--@api-stub: LObjModel:getFaceCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model face count = " .. model:getFaceCount())
    print("model vertex count = " .. model:getVertexCount())
end

--@api-stub: LObjModel:getNormalCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model normal count = " .. model:getNormalCount())
    print("model face count = " .. model:getFaceCount())
end

--@api-stub: LObjModel:getUvCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model uv count = " .. model:getUvCount())
    print("model vertex count = " .. model:getVertexCount())
end

--@api-stub: LObjModel:getVertexCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("model vertex count = " .. model:getVertexCount())
    print("model uv count = " .. model:getUvCount())
end

--@api-stub: LQuad:getTextureDimensions
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local w, h = quad:getTextureDimensions()
    print("quad texture dimensions = " .. w .. "x" .. h)
    print("quad type = " .. quad:type())
end

--@api-stub: LQuad:setViewport
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    quad:setViewport(0, 0, 32, 32)
    local x, y, w, h = quad:getViewport()
    print("quad viewport after set = " .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api-stub: LShape:arc
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0.5, 0, 1)
    shape:arc("fill", 100, 100, 40, 0, math.pi)
    print("shape command count = " .. shape:getCommandCount())
    print("shape arc added")
end

--@api-stub: LShape:circle
do
    local shape = lurek.render.newShape()
    shape:setColor(0.2, 0.8, 0.4, 1)
    shape:circle("line", 80, 80, 24)
    print("shape command count = " .. shape:getCommandCount())
    print("shape circle added")
end

--@api-stub: LShape:setColor
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.2, 0.8, 1)
    shape:rectangle("fill", 0, 0, 20, 20)
    print("shape command count = " .. shape:getCommandCount())
    print("shape color set before rectangle")
end

--@api-stub: LShape:ellipse
do
    local shape = lurek.render.newShape()
    shape:ellipse("fill", 100, 100, 50, 30)
    print("shape command count = " .. shape:getCommandCount())
    print("shape ellipse added")
end

--@api-stub: LShape:line
do
    local shape = lurek.render.newShape()
    shape:line(10, 10, 90, 90)
    print("shape command count = " .. shape:getCommandCount())
    print("shape line added")
end

--@api-stub: LShape:rectangle
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 20, 20, 60, 40)
    print("shape command count = " .. shape:getCommandCount())
    print("shape rectangle added")
end

--@api-stub: LShape:triangle
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    print("shape command count = " .. shape:getCommandCount())
    print("shape triangle added")
end

--@api-stub: LShape:draw
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    shape:draw(100, 100, 0, 1, 1, 0, 0)
    print("shape command count = " .. shape:getCommandCount())
    print("shape draw called")
end

--@api-stub: LShape:setLineWidth
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    print("shape command count = " .. shape:getCommandCount())
    print("shape line width set to 2")
end

--@api-stub: LShape:getCommandCount
do
    local shape = lurek.render.newShape()
    shape:circle("fill", 0, 0, 10)
    shape:circle("fill", 50, 50, 10)
    local before = shape:getCommandCount()
    shape:clear()
    local after = shape:getCommandCount()
    print("shape commands before clear = " .. before)
    print("shape commands after clear = " .. after)
end

--@api-stub: LDrawLayer:flush
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function()
        lurek.render.circle("fill", 100, 100, 20)
    end)
    layer:queue(2.0, function()
        lurek.render.circle("fill", 200, 100, 20)
    end)
    print("draw layer count before flush = " .. layer:getCount())
    layer:flush()
    print("draw layer count after flush = " .. layer:getCount())
end

--@api-stub: LDrawLayer:getCount
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    print("draw layer count = " .. layer:getCount())
    layer:clear()
end

--@api-stub: LDrawLayer:queue
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    print("draw layer count after queue = " .. layer:getCount())
    layer:clear()
end

--@api-stub: lurek.render.drawq
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    lurek.render.draw(image, 10, 10, 0, 1, 1)
    lurek.render.drawq(image, quad, 50, 50, 0, 1, 1)
    print("drawq used a 16x16 quad")
    image:release()
end

--@api-stub: lurek.render.drawNineSlice
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    lurek.render.drawNineSlice(slice, 100, 100, 80, 60)
    print("drawNineSlice target size = 80x60")
    image:release()
end

--@api-stub: lurek.render.clearStencil
do
    lurek.render.setStencilMode("replace", "always", 2)
    lurek.render.clearStencil()
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode after clear = " .. action .. "," .. compare .. "," .. value)
end

--@api-stub: lurek.render.currentLayer
do
    lurek.render.newLayer("current_layer_stub", 12)
    lurek.render.setLayer("current_layer_stub")
    print("current layer = " .. lurek.render.currentLayer())
    lurek.render.setLayer("default")
end

--@api-stub: lurek.render.flushSortGroup
do
    lurek.render.beginSortGroup(7)
    lurek.render.pushSortKey(5)
    lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(7)
    print("flushSortGroup id = 7")
end

--@api-stub: lurek.render.pushSortKey
do
    lurek.render.beginSortGroup(8)
    lurek.render.pushSortKey(3)
    lurek.render.circle("fill", 120, 100, 10)
    lurek.render.flushSortGroup(8)
    print("pushSortKey depth = 3")
end

--@api-stub: lurek.render.popLayer
do
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.circle("fill", 140, 100, 10)
    lurek.render.popLayer(99)
    print("popLayer id = 99")
end

--@api-stub: lurek.render.getCanvasSize
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    print("canvas size = " .. w .. "x" .. h)
    print("color mask red enabled = " .. tostring(select(1, lurek.render.getColorMask())))
    canvas:release()
end

--@api-stub: lurek.render.getColorMask
do
    lurek.render.setColorMask(true, false, true, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("color mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
end

--@api-stub: lurek.render.getDefaultFilter
do
    local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
    print("default filter = " .. min_filter .. "," .. mag_filter .. "," .. aniso)
end

--@api-stub: lurek.render.getDepthMode
do
    local mode, write = lurek.render.getDepthMode()
    print("depth mode = " .. mode)
    print("depth write = " .. tostring(write))
end

--@api-stub: lurek.render.getFontCellWidth
do
    local font = lurek.render.getDefaultFont(14)
    print("font cell width = " .. lurek.render.getFontCellWidth(font))
    print("font descent = " .. lurek.render.getFontDescent(font))
end

--@api-stub: lurek.render.getFontDescent
do
    local font = lurek.render.getDefaultFont(14)
    print("font descent = " .. lurek.render.getFontDescent(font))
    print("font ascent = " .. lurek.render.getFontAscent(font))
end

--@api-stub: lurek.render.getFontHeight
do
    local font = lurek.render.getDefaultFont(14)
    print("font height = " .. lurek.render.getFontHeight(font))
    print("font line height = " .. lurek.render.getFontLineHeight(font))
end

--@api-stub: lurek.render.getFontLineHeight
do
    local font = lurek.render.getDefaultFont(14)
    print("font line height = " .. lurek.render.getFontLineHeight(font))
    print("line width = " .. lurek.render.getLineWidth())
end

--@api-stub: lurek.render.getStencilMode
do
    lurek.render.setStencilMode("replace", "always", 4)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
end

--@api-stub: lurek.render.isLayerVisible
do
    lurek.render.newLayer("visibility_stub", 2)
    lurek.render.setLayerVisible("visibility_stub", true)
    print("layer visible = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
    lurek.render.setLayerVisible("visibility_stub", false)
    print("layer visible after hide = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
end

--@api-stub: lurek.render.loadModel
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    print("loadModel face count = " .. model:getFaceCount())
    print("loadModel normal count = " .. model:getNormalCount())
end

--@api-stub: lurek.render.intersectScissor
do
    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    local x, y, w, h = lurek.render.getScissor()
    print("intersected scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api-stub: lurek.render.resetCanvas
do
    local canvas = lurek.render.newCanvas(64, 64)
    lurek.render.resetCanvas(canvas)
    print("resetCanvas called on 64x64 canvas")
    canvas:release()
end

--@api-stub: lurek.render.saveScreenshot
do
    lurek.render.saveScreenshot("save/test_screenshot.png")
    print("saveScreenshot requested for save/test_screenshot.png")
end

--@api-stub: lurek.render.setFontLineHeight
do
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    print("setFontLineHeight called with 1.2")
    print("font line height now = " .. lurek.render.getFontLineHeight(font))
end

--@api-stub: lurek.render.setLayer
do
    lurek.render.newLayer("set_layer_stub", 1)
    lurek.render.setLayer("set_layer_stub")
    print("current layer = " .. lurek.render.currentLayer())
    lurek.render.setLayer("default")
end

--@api-stub: lurek.render.setLayerVisible
do
    lurek.render.newLayer("visible_layer_stub", 1)
    lurek.render.setLayerVisible("visible_layer_stub", false)
    print("layer visible = " .. tostring(lurek.render.isLayerVisible("visible_layer_stub")))
    lurek.render.setLayerVisible("visible_layer_stub", true)
end

--@api-stub: lurek.render.setLayerZOrder
do
    lurek.render.newLayer("zorder_layer_stub", 1)
    lurek.render.setLayerZOrder("zorder_layer_stub", 9)
    print("layer z order = " .. lurek.render.getLayerZOrder("zorder_layer_stub"))
end

--@api-stub: lurek.render.setStencilTest
do
    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest()
    print("setStencilTest enabled and cleared")
end

--@api-stub: lurek.render.setBold
do
    local previous = lurek.render.isBold()
    lurek.render.setBold(true)
    lurek.render.print("Bold text", 10, 10)
    print("bold after set = " .. tostring(lurek.render.isBold()))
    lurek.render.setBold(previous)
    print("bold restored = " .. tostring(lurek.render.isBold()))
end

--@api-stub: lurek.render.isBold
do
    print("isBold = " .. tostring(lurek.render.isBold()))
end

--@api-stub: lurek.render.printRotatedWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printRotatedWithFont(font, "Rotated text", 100, 100, math.pi / 4, 1.0)
    print("printRotatedWithFont angle = " .. tostring(math.pi / 4))
end

--@api-stub: lurek.render.printWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printWithFont(font, "Standard text override", 10, 150)
    print("printWithFont used default font size 16")
end

--@api-stub: lurek.render.printfWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printfWithFont(font, "Formatted text inside a 160 px box.", 10, 200, 160, "left")
    print("printfWithFont limit = 160")
    print("printfWithFont align = left")
end

--@api-stub: lurek.render.printRichWithFont
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red", r = 255, g = 0, b = 0, a = 255, scale = 1 },
        { text = " and ", r = 255, g = 255, b = 255, a = 255, scale = 1 },
        { text = "Green", r = 0, g = 255, b = 0, a = 255, scale = 1 },
    }
    lurek.render.printRichWithFont(font, spans, 10, 250)
    print("printRichWithFont spans = " .. #spans)
    print("printRichWithFont uses byte colors")
end

--@api-stub: lurek.render.getBuiltInFontNames
do
    local names = lurek.render.getBuiltInFontNames()
    print("built-in font name count = " .. #names)
    print("first built-in font = " .. tostring(names[1]))
end
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua
