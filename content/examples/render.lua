
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

local function render_log(message)
    lurek.log.info("[render.example] " .. tostring(message))
end

--- Render Module Part 1: basic drawing - print, rectangle, circle, line, polygon, points, arc, ellipse, triangle

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.render.print
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.print("Hello from lurek.render.print", 10, 10)
    example_print_log("print font type = " .. font:type())
    example_print_log("printed plain text")
end

--@api: lurek.render.printf
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printf("Centered text inside a 220 px box.", 10, 40, 220, "center")
    example_print_log("printf limit = 220")
    example_print_log("printf align = center")
end

--@api: lurek.render.printRotated
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printRotated("Rotated text", 180, 90, math.pi / 6, 1.0)
    example_print_log("printRotated angle = " .. tostring(math.pi / 6))
    example_print_log("rotated text drawn")
end

--@api: lurek.render.printRich
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red ", r = 255, g = 80, b = 80, a = 255, scale = 1.0 },
        { text = "Green ", r = 80, g = 220, b = 120, a = 255, scale = 1.0 },
        { text = "Blue", r = 80, g = 120, b = 255, a = 255, scale = 1.2 },
    }
    lurek.render.setFont(font)
    lurek.render.printRich(spans, 10, 120)
    example_print_log("rich spans = " .. #spans)
    example_print_log("rich text uses u8 colors")
end

--@api: lurek.render.rectangle
do
    lurek.render.setColor(1, 0.2, 0.2, 1)
    lurek.render.rectangle("fill", 40, 150, 100, 60)
    lurek.render.rectangle("line", 160, 150, 100, 60, 8)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("rectangle fill and rounded line drawn")
    example_print_log("rectangle width = 100")
end

--@api: lurek.render.circle
do
    lurek.render.setColor(1, 0.6, 0.1, 1)
    lurek.render.circle("fill", 340, 180, 30)
    lurek.render.setColor(0.2, 0.9, 1, 1)
    lurek.render.circle("line", 410, 180, 30)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("circle radius = 30")
    example_print_log("circle fill and line drawn")
end

--@api: lurek.render.ellipse
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 110, 250, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 240, 250, 40, 60)
    example_print_log("ellipse examples drawn")
    example_print_log("ellipse radii = 60x30 and 40x60")
end

--@api: lurek.render.arc
do
    lurek.render.setColor(1, 0.8, 0.1, 1)
    lurek.render.arc("fill", 360, 250, 36, 0, math.pi)
    lurek.render.setColor(0.2, 0.9, 0.4, 1)
    lurek.render.arc("line", 450, 250, 36, math.pi, math.pi * 1.75, 20)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("arc segments = 20 on line arc")
    example_print_log("arc examples drawn")
end

--@api: lurek.render.line
do
    lurek.render.setColor(1, 1, 0.2, 1)
    lurek.render.line(10, 320, 160, 320)
    lurek.render.setColor(0.1, 0.9, 1, 1)
    lurek.render.line(10, 340, 40, 360, 70, 340, 100, 360, 130, 340, 160, 360)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("line and polyline drawn")
    example_print_log("polyline points = 6")
end

--@api: lurek.render.polygon
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    example_print_log("polygon vertices = 5")
    example_print_log("polygon fill and line drawn")
end

--@api: lurek.render.triangle
do
    lurek.render.setColor(0.1, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 360, 350, 410, 280, 460, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 480, 350, 530, 280, 580, 350)
    example_print_log("triangle fill and line drawn")
    example_print_log("triangle count = 2")
end

--@api: lurek.render.points
do
    lurek.render.setPointSize(5)
    lurek.render.setColor(1, 0.1, 0.1, 1)
    lurek.render.points(20, 390, 40, 390, 60, 390, 80, 390)
    lurek.render.setColor(0.1, 0.1, 1, 1)
    lurek.render.points({ { 120, 390 }, { 140, 390 }, { 160, 390 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("point size reset to 1")
    example_print_log("points drawn with flat and table inputs")
end

--@api: lurek.render.setLineWidth
do
    lurek.render.setLineWidth(4)
    lurek.render.line(200, 390, 280, 390)
    example_print_log("line width set to 4")
    lurek.render.setLineWidth(1)
    example_print_log("line width restored to 1")
end

--@api: lurek.render.getLineWidth
do
    lurek.render.setLineWidth(3)
    local width = lurek.render.getLineWidth()
    example_print_log("line width = " .. tostring(width))
    lurek.render.setLineWidth(1)
    example_print_log("line width restored")
end

--@api: lurek.render.setPointSize
do
    lurek.render.setPointSize(6)
    lurek.render.points(320, 390, 340, 390, 360, 390)
    example_print_log("point size set to 6")
    lurek.render.setPointSize(1)
    example_print_log("point size restored")
end

--@api: lurek.render.getPointSize
do
    lurek.render.setPointSize(7)
    local size = lurek.render.getPointSize()
    example_print_log("point size = " .. tostring(size))
    lurek.render.setPointSize(1)
    example_print_log("point size restored")
end

--@api: lurek.render.drawCubicBezier
do
    lurek.render.setColor(1, 0.5, 0.1, 1)
    lurek.render.drawCubicBezier(20, 440, 60, 390, 120, 490, 160, 440, 24)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("cubic bezier segments = 24")
    example_print_log("cubic bezier drawn")
end

--@api: lurek.render.drawQuadBezier
do
    lurek.render.setColor(0.1, 1, 0.5, 1)
    lurek.render.drawQuadBezier(210, 440, 270, 390, 330, 440, 18)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("quad bezier segments = 18")
    example_print_log("quad bezier drawn")
end

--@api: lurek.render.drawPath
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
    example_print_log("path segments = " .. #path)
    example_print_log("path closed = true")
end

--@api: lurek.render.drawGradientRect
do
    lurek.render.drawGradientRect(10, 500, 120, 36, { 1, 0, 0, 1 }, { 0, 0, 1, 1 }, "horizontal")
    lurek.render.drawGradientRect(150, 500, 120, 36, { 0, 1, 0, 1 }, { 1, 1, 0, 1 }, "vertical")
    lurek.render.rectangle("line", 10, 500, 120, 36)
    local r, g, b, a = lurek.render.getColor()
    render_log("gradient cards drawn with active color " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: lurek.render.drawColoredPolygon
do
    local vertices = { 320, 500, 380, 500, 400, 540, 300, 540 }
    local colors = {
        { 1, 0, 0, 1 },
        { 0, 1, 0, 1 },
        { 0, 0, 1, 1 },
        { 1, 1, 0, 1 },
    }
    lurek.render.drawColoredPolygon(vertices, colors, "fill")
    example_print_log("colored polygon vertices = 4")
    example_print_log("colored polygon drawn")
end

--@api: lurek.render.drawHexTile
do
    lurek.render.setColor(0.1, 0.7, 0.5, 1)
    lurek.render.drawHexTile(480, 520, 24, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(550, 520, 24, "flatTop", "line")
    example_print_log("hex tile orientations = pointyTop, flatTop")
    example_print_log("hex tiles drawn")
end

--@api: lurek.render.drawBevelRect
do
    lurek.render.drawBevelRect(10, 560, 90, 32, 3, "raised")
    lurek.render.drawBevelRect(120, 560, 90, 32, 3, "sunken")
    lurek.render.drawBevelRect(230, 560, 90, 32, 2, "flat", {
        fillColor = { 0.2, 0.3, 0.8, 1 },
        highlight = { 1, 1, 1, 1 },
        shadow = { 0.2, 0.2, 0.3, 1 },
    })
    example_print_log("bevel styles = raised, sunken, flat")
    example_print_log("bevel rectangles drawn")
end


--- Render Module Part 2: color state, transforms, scissor, clear, blend modes, wireframe, layers, depth

--@api: lurek.render.setColor
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    example_print_log("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.rectangle("fill", 340, 10, 40, 20)
    lurek.render.setColor(1, 1, 1, 1)
    example_print_log("color restored to white")
end

--@api: lurek.render.setBackgroundColor
do
    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    example_print_log("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
    example_print_log("background restored to black")
end

--@api: lurek.render.setColorMask
do
    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    example_print_log("mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
    example_print_log("color mask restored")
end

--@api: lurek.render.push
do
    lurek.render.push()
    lurek.render.translate(80, 80)
    lurek.render.rotate(math.pi / 8)
    lurek.render.scale(1.2, 0.8)
    lurek.render.rectangle("line", -20, -20, 40, 40)
    lurek.render.pop()
    example_print_log("transform stack push/pop used")
    example_print_log("translated, rotated, and scaled rectangle")
end

--@api: lurek.render.shear
do
    lurek.render.push()
    lurek.render.translate(180, 80)
    lurek.render.shear(0.3, 0.0)
    lurek.render.rectangle("fill", 0, 0, 70, 30)
    lurek.render.pop()
    example_print_log("shear kx = 0.3")
    example_print_log("sheared rectangle drawn")
end

--@api: lurek.render.origin
do
    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 12, 12)
    lurek.render.pop()
    example_print_log("origin reset applied")
    example_print_log("origin rectangle drawn at screen origin")
end

--@api: lurek.render.applyTransform
do
    local matrix = { 1, 0, 0, 0, 1, 0, 60, 120, 1 }
    lurek.render.push()
    lurek.render.applyTransform(matrix)
    lurek.render.rectangle("fill", 0, 0, 36, 36)
    lurek.render.pop()
    example_print_log("applyTransform matrix entries = " .. #matrix)
    example_print_log("flat 3x3 matrix applied")
end

--@api: lurek.render.setScissor
do
    lurek.render.setScissor(20, 140, 120, 60)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("fill", 0, 120, 180, 90)
    lurek.render.intersectScissor(50, 150, 70, 30)
    lurek.render.rectangle("line", 0, 120, 180, 90)
    lurek.render.setScissor()
    example_print_log("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    example_print_log("scissor cleared")
end

--@api: lurek.render.clear
do
    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    lurek.render.circle("line", 24, 24, 8)
    local mode = lurek.render.getBlendMode()
    render_log("render queue cleared and resumed in blend mode " .. mode)
end

--@api: lurek.render.setBlendMode
do
    local before = lurek.render.getBlendMode()
    lurek.render.setBlendMode("add")
    lurek.render.rectangle("fill", 180, 140, 40, 40)
    lurek.render.setBlendMode("multiply")
    lurek.render.rectangle("fill", 200, 160, 40, 40)
    lurek.render.setBlendMode("alpha")
    example_print_log("blend before = " .. before)
    example_print_log("blend restored to alpha")
end

--@api: lurek.render.setWireframe
do
    example_print_log("wireframe before = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 260, 140, 50, 50)
    lurek.render.setWireframe(false)
    example_print_log("wireframe restored = " .. tostring(lurek.render.isWireframe()))
end

--@api: lurek.render.newLayer
do
    lurek.render.newLayer("background", 0)
    lurek.render.newLayer("foreground", 10)
    lurek.render.setLayer("foreground")
    example_print_log("current layer = " .. lurek.render.currentLayer())
    example_print_log("foreground z = " .. lurek.render.getLayerZOrder("foreground"))
end

--@api: lurek.render.getLayerZOrder
do
    lurek.render.newLayer("midground", 5)
    lurek.render.setLayer("midground")
    local before = lurek.render.getLayerZOrder("midground")
    lurek.render.setLayerZOrder("midground", 15)
    local after = lurek.render.getLayerZOrder("midground")
    render_log("midground z changed " .. before .. " -> " .. after)
end

--@api: lurek.render.pushLayer
do
    lurek.render.pushLayer(1, 0.65, "alpha")
    lurek.render.rectangle("fill", 320, 140, 60, 40)
    lurek.render.popLayer(1)
    example_print_log("pushLayer id = 1")
    example_print_log("popLayer matched id = 1")
end

--@api: lurek.render.beginSortGroup
do
    lurek.render.beginSortGroup(1)
    lurek.render.pushSortKey(10)
    lurek.render.rectangle("fill", 400, 140, 30, 30)
    lurek.render.pushSortKey(5)
    lurek.render.rectangle("fill", 410, 150, 30, 30)
    lurek.render.flushSortGroup(1)
    example_print_log("sort group id = 1")
    example_print_log("sort keys 10 and 5 queued")
end

--@api: lurek.render.setDepthMode
do
    local mode_before, write_before = lurek.render.getDepthMode()
    lurek.render.setDepthMode("lequal", true)
    local mode_after, write_after = lurek.render.getDepthMode()
    example_print_log("depth before = " .. mode_before .. "," .. tostring(write_before))
    example_print_log("depth after = " .. mode_after .. "," .. tostring(write_after))
    lurek.render.setDepthMode("always", false)
end

--@api: lurek.render.setDefaultFilter
do
    local min_before, mag_before, aniso_before = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    local min_after, mag_after, aniso_after = lurek.render.getDefaultFilter()
    example_print_log("filter before = " .. min_before .. "," .. mag_before .. "," .. aniso_before)
    example_print_log("filter after = " .. min_after .. "," .. mag_after .. "," .. aniso_after)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end

--@api: lurek.render.getDimensions
do
    local w, h = lurek.render.getDimensions()
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    render_log("framebuffer " .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
end

--@api: lurek.render.getStats
do
    local stats = lurek.render.getStats()
    lurek.render.rectangle("fill", 0, 0, 8, 8)
    local draws = tostring(stats.drawcalls)
    local textures = tostring(stats.textures)
    local gpu = tostring(stats.gpu_draw_calls)
    render_log("stats drawcalls=" .. draws .. " textures=" .. textures .. " gpu=" .. gpu)
end


--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice

--@api: lurek.render.newImage
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    lurek.render.draw(image, 10, 10)
    lurek.render.draw(image, 90, 10, math.pi / 8, 0.5, 0.5)
    example_print_log("image size = " .. w .. "x" .. h)
    example_print_log("newImage handle ready")
end

--@api: LImage:getId
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local id = image:getId()
    local w, h = image:getDimensions()
    render_log("texture id=" .. id .. " size=" .. w .. "x" .. h)
    image:release()
end

--@api: LImage:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local type_name = image:type()
    local is_image = image:typeOf("LImage")
    local id = image:getId()
    render_log(type_name .. " is_image=" .. tostring(is_image) .. " id=" .. id)
    image:release()
end

--@api: LImage:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local is_image = image:typeOf("LImage")
    local is_object = image:typeOf("LObject")
    local w = image:getWidth()
    render_log("image typeOf LImage=" .. tostring(is_image) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
    image:release()
end

--@api: LImage:release
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local before_id = image:getId()
    local before_w = image:getWidth()
    local released = image:release()
    render_log("image " .. before_id .. " width=" .. before_w .. " released=" .. tostring(released))
end

--@api: lurek.render.newCanvas
do
    local canvas = lurek.render.newCanvas(96, 96)
    local w, h = canvas:getDimensions()
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 24)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 10, 70)
    example_print_log("canvas size = " .. w .. "x" .. h)
    example_print_log("canvas rendered and drawn back")
end

--@api: LCanvas:type
do
    local canvas = lurek.render.newCanvas(64, 64)
    local type_name = canvas:type()
    local is_canvas = canvas:typeOf("LCanvas")
    local w, h = canvas:getDimensions()
    render_log(type_name .. " is_canvas=" .. tostring(is_canvas) .. " size=" .. w .. "x" .. h)
    canvas:release()
end

--@api: LCanvas:typeOf
do
    local canvas = lurek.render.newCanvas(64, 64)
    local is_canvas = canvas:typeOf("LCanvas")
    local is_object = canvas:typeOf("LObject")
    local w = canvas:getWidth()
    render_log("canvas typeOf LCanvas=" .. tostring(is_canvas) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
    canvas:release()
end

--@api: LCanvas:release
do
    local canvas = lurek.render.newCanvas(64, 64)
    local w, h = canvas:getDimensions()
    local released = canvas:release()
    local pixels = w * h
    render_log("canvas " .. w .. "x" .. h .. " pixels=" .. pixels .. " released=" .. tostring(released))
end

--@api: lurek.render.getCanvas
do
    local canvas = lurek.render.newCanvas(120, 80)
    lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas()
    local w, h = lurek.render.getCanvasSize(canvas)
    lurek.render.setCanvas(nil)
    lurek.render.resetCanvas(canvas)
    example_print_log("active canvas exists = " .. tostring(active ~= nil))
    example_print_log("canvas size = " .. w .. "x" .. h)
end

--@api: lurek.render.newQuad
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sw, sh = image:getDimensions()
    local quad = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    local x, y, w, h = quad:getViewport()
    lurek.render.drawq(image, quad, 10, 170)
    example_print_log("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    example_print_log("quad texture dims = " .. sw .. "x" .. sh)
end

--@api: LQuad:type
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    local type_name = quad:type()
    local is_quad = quad:typeOf("LQuad")
    local x, y, w, h = quad:getViewport()
    render_log(type_name .. " is_quad=" .. tostring(is_quad) .. " viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LQuad:typeOf
do
    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    local is_quad = quad:typeOf("LQuad")
    local is_object = quad:typeOf("LObject")
    local tex_w, tex_h = quad:getTextureDimensions()
    render_log("quad typeOf LQuad=" .. tostring(is_quad) .. " LObject=" .. tostring(is_object) .. " tex=" .. tex_w .. "x" .. tex_h)
end

--@api: lurek.render.newSpriteBatch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 16)
    local last = batch:add(60, 220, 0, 0.5, 0.5, 0, 0)
    batch:add(90, 220, math.pi / 8, 0.5, 0.5, 0, 0)
    lurek.render.draw(batch, 0, 0)
    example_print_log("sprite batch count = " .. batch:getCount())
    example_print_log("last sprite index = " .. tostring(last))
end

--@api: lurek.render.drawBatch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:add(120, 220, 0, 0.5, 0.5, 0, 0)
    lurek.render.drawBatch(batch)
    example_print_log("drawBatch sprite count = " .. batch:getCount())
    example_print_log("drawBatch issued")
end

--@api: LSpriteBatch:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    example_print_log("batch type = " .. batch:type())
    example_print_log("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--@api: LSpriteBatch:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    example_print_log("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    example_print_log("batch capacity = 8")
    batch:release()
end

--@api: LSpriteBatch:release
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local released = batch:release()
    example_print_log("batch released = " .. tostring(released))
    example_print_log("batch release tested")
end

--@api: lurek.render.drawMany
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local list = {
        { image, 10, 270, 0, 0.3, 0.3, 0, 0 },
        { image, 40, 270, math.pi / 8, 0.3, 0.3, 0, 0 },
        { image, 70, 270, math.pi / 4, 0.3, 0.3, 0, 0 },
    }
    lurek.render.drawMany(list)
    example_print_log("drawMany entries = " .. #list)
    example_print_log("drawMany issued")
end

--@api: lurek.render.newNineSlice
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    lurek.render.drawNineSlice(slice, 10, 310, 140, 48)
    example_print_log("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    example_print_log("nine-slice drawn")
end

--@api: lurek.render.newDrawLayer
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(10, function()
        lurek.render.rectangle("fill", 180, 310, 20, 20)
    end)
    layer:queue(5, function()
        lurek.render.rectangle("fill", 190, 320, 20, 20)
    end)
    example_print_log("queued callbacks = " .. layer:getCount())
    layer:flush()
    example_print_log("queued callbacks after flush = " .. layer:getCount())
end

--@api: LDrawLayer:clear
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() end)
    layer:queue(2, function() end)
    layer:clear()
    example_print_log("draw layer count after clear = " .. layer:getCount())
    example_print_log("draw layer type = " .. layer:type())
end

--@api: LDrawLayer:type
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() lurek.render.rectangle("fill", 0, 0, 4, 4) end)
    local type_name = layer:type()
    local is_layer = layer:typeOf("LDrawLayer")
    render_log(type_name .. " is_layer=" .. tostring(is_layer) .. " queued=" .. layer:getCount())
end

--@api: LDrawLayer:typeOf
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(2, function() lurek.render.circle("fill", 4, 4, 2) end)
    local is_layer = layer:typeOf("LDrawLayer")
    local is_object = layer:typeOf("LObject")
    render_log("draw layer typeOf LDrawLayer=" .. tostring(is_layer) .. " LObject=" .. tostring(is_object) .. " queued=" .. layer:getCount())
end

--@api: lurek.render.drawIsoCubeTile
do
    lurek.render.drawIsoCubeTile(300, 330, 28, 14, {
        depth = 18,
        topColor = { 0.8, 0.8, 0.9, 1 },
        leftColor = { 0.5, 0.5, 0.6, 1 },
        rightColor = { 0.3, 0.3, 0.4, 1 },
    })
    example_print_log("iso cube tile depth = 18")
    example_print_log("iso cube tile drawn")
end


--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api: lurek.render.newShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.25)
    local type_name = shader:type()
    render_log("compiled shader type=" .. type_name .. " has_u_time=" .. tostring(shader:hasUniform("u_time")))
end

--@api: LShader:send
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    example_print_log("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 1.5)
    example_print_log("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
end

--@api: LShader:setShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 380, 30, 20)
    example_print_log("active shader exists = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    example_print_log("shader cleared")
end

--@api: LShader:getShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    local active = lurek.render.getShader()
    example_print_log("getShader returned handle = " .. tostring(active ~= nil))
    lurek.render.setShader(nil)
    example_print_log("shader restored to default")
end

--@api: LShader:release
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    example_print_log("shader released = " .. tostring(released))
    example_print_log("shader release tested")
end

--@api: lurek.render.newMesh
do
    local verts = {
        { 0, 0, 0, 0, 1, 0, 0, 1 },
        { 60, 0, 1, 0, 0, 1, 0, 1 },
        { 30, 50, 0.5, 1, 0, 0, 1, 1 },
    }
    local mesh = lurek.render.newMesh(verts, "triangles")
    lurek.render.draw(mesh, 70, 380)
    example_print_log("mesh vertex count = " .. mesh:getVertexCount())
    example_print_log("newMesh created triangles mesh")
end

--@api: LMesh:setVertex
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    example_print_log("mesh v1 = " .. x .. "," .. y .. "," .. r .. "," .. g .. "," .. b .. "," .. a)
    example_print_log("setVertex applied to index 1")
end

--@api: LMesh:getVertex
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    local x, y, u, v, r, g, b, a = mesh:getVertex(2)
    example_print_log("mesh v2 = " .. x .. "," .. y .. "," .. u .. "," .. v)
    example_print_log("mesh v2 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LMesh:setTexture
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    example_print_log("mesh texture set from image")
    example_print_log("mesh type = " .. mesh:type())
end

--@api: LMesh:release
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    example_print_log("mesh released = " .. tostring(mesh:release()))
    example_print_log("mesh release tested")
end

--@api: LMesh:type
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    example_print_log("mesh type = " .. mesh:type())
    example_print_log("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
end

--@api: LMesh:typeOf
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    example_print_log("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
    example_print_log("mesh bounds ready = " .. tostring(mesh:getVertexCount() > 0))
end

--@api: lurek.render.newShape
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0, 0, 1)
    shape:rectangle("fill", 0, 0, 40, 24)
    shape:setColor(0, 1, 0, 1)
    shape:circle("line", 60, 12, 12)
    shape:draw(170, 380)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("newShape drew retained commands")
end

--@api: LShape:polygon
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30)
    shape:draw(250, 380)
    example_print_log("shape polygon commands = " .. shape:getCommandCount())
    example_print_log("shape polygon drawn")
end

--@api: LShape:polyline
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(3)
    shape:polyline(0, 0, 20, 20, 40, 0, 60, 20)
    shape:draw(330, 380)
    example_print_log("shape polyline commands = " .. shape:getCommandCount())
    example_print_log("shape polyline drawn")
end

--@api: LShape:roundedRectangle
do
    local shape = lurek.render.newShape()
    shape:setColor(0.5, 0.5, 1, 1)
    shape:roundedRectangle("line", 0, 0, 70, 36, 8)
    shape:draw(410, 380)
    example_print_log("shape rounded rectangle commands = " .. shape:getCommandCount())
    example_print_log("shape rounded rectangle drawn")
end

--@api: LShape:clear
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5)
    example_print_log("shape commands before clear = " .. shape:getCommandCount())
    shape:clear()
    example_print_log("shape commands after clear = " .. shape:getCommandCount())
end

--@api: LShape:type
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 16, 12)
    local type_name = shape:type()
    local count = shape:getCommandCount()
    render_log(type_name .. " commands=" .. count .. " is_shape=" .. tostring(shape:typeOf("LShape")))
end

--@api: LShape:typeOf
do
    local shape = lurek.render.newShape()
    shape:line(0, 0, 12, 12)
    local is_shape = shape:typeOf("LShape")
    local is_object = shape:typeOf("LObject")
    render_log("shape typeOf LShape=" .. tostring(is_shape) .. " LObject=" .. tostring(is_object) .. " commands=" .. shape:getCommandCount())
end

--@api: lurek.render.loadObj
do
    local model = lurek.render.loadObj("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    render_log("obj faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
end

--@api: LObjModel:projectToMesh
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local camera = { x = 0, y = 0, z = -5, tx = 0, ty = 0, tz = 0, fov = 60 }
    local vertices = model:projectToMesh(camera, 320, 240)
    example_print_log("projected vertex rows = " .. #vertices)
    example_print_log("projectToMesh camera fov = " .. camera.fov)
end

--@api: LObjModel:renderToImage
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local image = model:renderToImage(64, 64, 0)
    lurek.render.draw(image, 500, 370)
    example_print_log("rendered model image = " .. image:getWidth() .. "x" .. image:getHeight())
    example_print_log("renderToImage rotation step = 0")
end


--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density

--@api: lurek.render.newFont
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("newFont built-in size 16", 10, 430)
    example_print_log("newFont type = " .. font:type())
    example_print_log("newFont built from bundled size selector")
end

--@api: lurek.render.getDefaultFont
do
    local font = lurek.render.getDefaultFont(24)
    lurek.render.setFont(font)
    lurek.render.print("Default font size 24", 10, 455)
    example_print_log("default font height = " .. font:getHeight())
    example_print_log("default font fetched by point size")
end

--@api: lurek.render.setDefaultFont
do
    local regular = lurek.render.setDefaultFont(10, false)
    local bold = lurek.render.setDefaultFont(10, true)
    lurek.render.setFont(regular)
    example_print_log("regular height = " .. regular:getHeight())
    example_print_log("bold height = " .. bold:getHeight())
end

--@api: LFont:getWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local width = font:getWidth("Inventory")
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    render_log("font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
end

--@api: LFont:getHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    local sample_width = font:getWidth("HUD")
    render_log("font height=" .. height .. " line_height=" .. line_height .. " sample_width=" .. sample_width)
end

--@api: LFont:getLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local line_height = font:getLineHeight()
    local ascent = font:getAscent()
    local descent = font:getDescent()
    render_log("font line height=" .. line_height .. " ascent=" .. ascent .. " descent=" .. descent)
end

--@api: LFont:getAscent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local ascent = font:getAscent()
    local descent = font:getDescent()
    local height = font:getHeight()
    render_log("font ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
end

--@api: LFont:getDescent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local descent = font:getDescent()
    local width = font:getWidth("Test")
    local ascent = font:getAscent()
    render_log("font descent=" .. descent .. " ascent=" .. ascent .. " sample_width=" .. width)
end

--@api: LFont:getWrap
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    local lines, width = font:getWrap("This is a wrapped sentence for the font object.", 120)
    local first = lines[1] or ""
    local line_height = font:getLineHeight()
    render_log("wrapped lines=" .. #lines .. " width=" .. width .. " line_height=" .. line_height .. " first=" .. first)
end

--@api: LFont:setLineHeight
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    font:setLineHeight(1.5)
    local line_height = font:getLineHeight()
    local height = font:getHeight()
    render_log("font line height=" .. line_height .. " height=" .. height)
end

--@api: LFont:release
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    local width = font:getWidth("HUD")
    local released = font:release()
    local alive_type = font:type()
    render_log("font type=" .. alive_type .. " width before release=" .. width .. " released=" .. tostring(released))
end

--@api: lurek.render.getFontSizes
do
    local sizes = lurek.render.getFontSizes()
    local first = sizes[1] or -1
    local last = sizes[#sizes] or -1
    local count = #sizes
    render_log("font sizes=" .. count .. " range=" .. tostring(first) .. "-" .. tostring(last))
end

--@api: lurek.render.getFontWidth
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local width = lurek.render.getFontWidth(font, "Measure")
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    render_log("module font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
end

--@api: lurek.render.getFontAscent
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local ascent = lurek.render.getFontAscent(font)
    local descent = lurek.render.getFontDescent(font)
    local height = lurek.render.getFontHeight(font)
    render_log("module ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
end

--@api: lurek.render.getFontWrap
do
    local font = lurek.render.getDefaultFont(12)
    lurek.render.setFont(font)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    example_print_log("module wrapped lines = " .. #lines)
    example_print_log("module wrap width = " .. width)
end

--@api: lurek.render.stencil
do
    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 220, 470, 24)
    lurek.render.setStencilTest("equal", 1)
    lurek.render.rectangle("fill", 190, 445, 60, 60)
    lurek.render.setStencilTest()
    example_print_log("stencil write value = 1")
    example_print_log("stencil test cleared")
end

--@api: lurek.render.setStencilMode
do
    lurek.render.setStencilMode("replace", "always", 2)
    local action, compare, value = lurek.render.getStencilMode()
    example_print_log("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
    example_print_log("stencil state cleared")
end

--@api: lurek.render.captureScreenshot
do
    lurek.render.captureScreenshot(function(data)
        example_print_log("captureScreenshot size = " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/render_capture.png")
    example_print_log("captureScreenshot callback invoked")
    example_print_log("saveScreenshot requested")
end

--@api: lurek.render.setCanvas
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 20)
    lurek.render.setCanvas(nil)
    example_print_log("setCanvas switched to off-screen target")
    example_print_log("setCanvas restored to screen")
end

--@api: lurek.render.draw
do
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 280, 430, 0, 0.75, 0.75)
    example_print_log("draw used a canvas handle")
    example_print_log("draw scale = 0.75")
end

--@api: lurek.render.setFont
do
    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("setFont switched active font", 10, 500)
    example_print_log("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    example_print_log("setFont tested with built-in font")
end

--- Render Module Part 5: LCanvas, LFont release/type, LImage release/type, LMesh, LQuad getViewport/type, LShader, LSpriteBatch

--@api: LCanvas:getDimensions
do
    local canvas = lurek.render.newCanvas(128, 64)
    local w, h = canvas:getDimensions()
    example_print_log("canvas dimensions = " .. w .. "x" .. h)
    example_print_log("canvas type = " .. canvas:type())
    canvas:release()
end

--@api: LCanvas:getHeight
do
    local canvas = lurek.render.newCanvas(128, 64)
    local height = canvas:getHeight()
    local width = canvas:getWidth()
    local dims = width .. "x" .. height
    render_log("canvas height=" .. height .. " dims=" .. dims)
    canvas:release()
end

--@api: LCanvas:getWidth
do
    local canvas = lurek.render.newCanvas(128, 64)
    local width = canvas:getWidth()
    local is_canvas = canvas:typeOf("LCanvas")
    local height = canvas:getHeight()
    render_log("canvas width=" .. width .. " height=" .. height .. " is_canvas=" .. tostring(is_canvas))
    canvas:release()
end

--@api: LFont:type
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local type_name = font:type()
    local height = font:getHeight()
    local ascent = font:getAscent()
    render_log(type_name .. " height=" .. height .. " ascent=" .. ascent)
    font:release()
end

--@api: LFont:typeOf
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local is_font = font:typeOf("LFont")
    local is_object = font:typeOf("LObject")
    local line_height = font:getLineHeight()
    render_log("font typeOf LFont=" .. tostring(is_font) .. " LObject=" .. tostring(is_object) .. " line_height=" .. line_height)
    font:release()
end

--@api: LMesh:getVertexCount
do
    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 100, 0, 1, 0, 1, 1, 1, 1 },
        { 50, 100, 0.5, 1, 1, 1, 1, 1 },
    }, "triangles")
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    mesh:setTexture(image)
    mesh:setVertex(1, { 10, 10, 0.1, 0.1, 1, 0.5, 0.5, 1 })
    example_print_log("mesh vertex count = " .. mesh:getVertexCount())
    example_print_log("mesh type = " .. mesh:type())
    mesh:release()
end

--@api: LQuad:getViewport
do
    local quad = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = quad:getViewport()
    local tex_w, tex_h = quad:getTextureDimensions()
    local area = w * h
    render_log("quad viewport=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h .. " area=" .. area)
end

--@api: LShader:hasUniform
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    example_print_log("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 0.5)
    example_print_log("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api: LShader:type
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    example_print_log("shader type = " .. shader:type())
    example_print_log("shader has u_time = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api: LShader:typeOf
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    example_print_log("shader typeOf LShader = " .. tostring(shader:typeOf("LShader")))
    example_print_log("shader source bytes = " .. tostring(#src))
    shader:release()
end

--@api: LSpriteBatch:add
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    local id = batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    example_print_log("sprite id = " .. tostring(id))
    example_print_log("sprite count = " .. batch:getCount())
    batch:release()
end

--@api: LSpriteBatch:clear
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    batch:clear()
    example_print_log("sprite count after clear = " .. batch:getCount())
    example_print_log("sprite batch type = " .. batch:type())
    batch:release()
end

--@api: LSpriteBatch:getBufferSize
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    example_print_log("sprite batch buffer size = " .. batch:getBufferSize())
    example_print_log("sprite batch count = " .. batch:getCount())
    batch:release()
end

--@api: LSpriteBatch:getCount
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    example_print_log("sprite batch count = " .. batch:getCount())
    example_print_log("sprite batch typeOf = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--- Render Module Part 6: module-level functions (clear, color, blend, canvas, shader, transforms, font, wireframe, dims, scissor, line/point)

--@api: lurek.render.getBackgroundColor
do
    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b, a = lurek.render.getBackgroundColor()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    render_log("background=" .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end

--@api: lurek.render.getBlendMode
do
    lurek.render.setBlendMode("alpha")
    local mode = lurek.render.getBlendMode()
    lurek.render.rectangle("fill", 0, 0, 4, 4)
    lurek.render.setBlendMode("add")
    render_log("blend mode=" .. mode)
    lurek.render.setBlendMode("alpha")
end

--@api: lurek.render.getColor
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    lurek.render.rectangle("fill", 6, 6, 8, 8)
    render_log("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api: lurek.render.getHeight
do
    local w, h = lurek.render.getDimensions()
    local height = lurek.render.getHeight()
    local width = lurek.render.getWidth()
    local area = width * height
    render_log("dimensions=" .. w .. "x" .. h .. " height=" .. height .. " width=" .. width .. " area=" .. area)
end

--@api: lurek.render.getWidth
do
    local w, h = lurek.render.getDimensions()
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    render_log("dimensions=" .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
end

--@api: lurek.render.getFont
do
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    lurek.render.setFont(font)
    example_print_log("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    example_print_log("active font width of test = " .. font:getWidth("test"))
    font:release()
end

--@api: lurek.render.getScissor
do
    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("line", x, y, w, h)
    render_log("scissor=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api: lurek.render.getShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    example_print_log("getShader returned handle = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    shader:release()
end

--@api: lurek.render.setShader
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 540, 24, 16)
    example_print_log("setShader activated custom shader")
    lurek.render.setShader(nil)
    example_print_log("shader restored to default")
    shader:release()
end

--@api: lurek.render.isWireframe
do
    lurek.render.setWireframe(true)
    local enabled = lurek.render.isWireframe()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    example_print_log("wireframe enabled = " .. tostring(enabled))
    lurek.render.setWireframe(false)
    example_print_log("wireframe enabled after reset = " .. tostring(lurek.render.isWireframe()))
end

--@api: lurek.render.pop
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    example_print_log("transform stack pop completed")
end

--@api: lurek.render.rotate
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    example_print_log("rotation angle = " .. tostring(math.pi / 4))
end

--@api: lurek.render.scale
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.scale(2, 2)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    example_print_log("scale = 2x2")
end

--@api: lurek.render.translate
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    example_print_log("translation = 50,50")
end

--@api: LImage:getDimensions
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    example_print_log("image dimensions = " .. w .. "x" .. h)
    example_print_log("image type = " .. image:type())
    image:release()
end

--@api: LImage:getWidth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local width = image:getWidth()
    local height = image:getHeight()
    local id = image:getId()
    render_log("image width=" .. width .. " height=" .. height .. " id=" .. id)
    image:release()
end

--@api: LImage:getHeight
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local height = image:getHeight()
    local width = image:getWidth()
    local id = image:getId()
    render_log("image height=" .. height .. " width=" .. width .. " id=" .. id)
    image:release()
end

--@api: LNineSlice:getInsets
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    example_print_log("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    example_print_log("nine-slice type = " .. slice:type())
    image:release()
end

--@api: LNineSlice:getTextureSize
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    local w, h = slice:getTextureSize()
    example_print_log("nine-slice texture size = " .. w .. "x" .. h)
    example_print_log("nine-slice typeOf = " .. tostring(slice:typeOf("LNineSlice")))
    image:release()
end

--@api: LNineSlice:type
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    example_print_log("nine-slice type = " .. slice:type())
    example_print_log("nine-slice texture width = " .. select(1, slice:getTextureSize()))
    image:release()
end

--@api: LNineSlice:typeOf
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 2, 2, 2, 2)
    example_print_log("nine-slice typeOf LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
    example_print_log("nine-slice width sample = 140")
    image:release()
end

--@api: LObjModel:getFaceCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    render_log("model faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
end

--@api: LObjModel:getNormalCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local normals = model:getNormalCount()
    local faces = model:getFaceCount()
    local uvs = model:getUvCount()
    render_log("model normals=" .. normals .. " faces=" .. faces .. " uvs=" .. uvs)
end

--@api: LObjModel:getUvCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local uvs = model:getUvCount()
    local verts = model:getVertexCount()
    local faces = model:getFaceCount()
    render_log("model uvs=" .. uvs .. " verts=" .. verts .. " faces=" .. faces)
end

--@api: LObjModel:getVertexCount
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local verts = model:getVertexCount()
    local uvs = model:getUvCount()
    local normals = model:getNormalCount()
    render_log("model verts=" .. verts .. " uvs=" .. uvs .. " normals=" .. normals)
end

--@api: LQuad:getTextureDimensions
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local w, h = quad:getTextureDimensions()
    local vx, vy, vw, vh = quad:getViewport()
    local area = vw * vh
    render_log("quad texture=" .. w .. "x" .. h .. " viewport=" .. vx .. "," .. vy .. "," .. vw .. "," .. vh .. " area=" .. area)
end

--@api: LQuad:setViewport
do
    local quad = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    quad:setViewport(0, 0, 32, 32)
    local x, y, w, h = quad:getViewport()
    local tex_w, tex_h = quad:getTextureDimensions()
    render_log("quad viewport after set=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h)
end

--@api: LShape:arc
do
    local shape = lurek.render.newShape()
    shape:setColor(1, 0.5, 0, 1)
    shape:arc("fill", 100, 100, 40, 0, math.pi)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape arc added")
end

--@api: LShape:circle
do
    local shape = lurek.render.newShape()
    shape:setColor(0.2, 0.8, 0.4, 1)
    shape:circle("line", 80, 80, 24)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape circle added")
end

--@api: LShape:setColor
do
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.2, 0.8, 1)
    shape:rectangle("fill", 0, 0, 20, 20)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape color set before rectangle")
end

--@api: LShape:ellipse
do
    local shape = lurek.render.newShape()
    shape:ellipse("fill", 100, 100, 50, 30)
    shape:setColor(0.4, 0.8, 1.0, 1.0)
    local count = shape:getCommandCount()
    render_log("shape ellipse commands=" .. count)
end

--@api: LShape:line
do
    local shape = lurek.render.newShape()
    shape:line(10, 10, 90, 90)
    shape:setLineWidth(3)
    local count = shape:getCommandCount()
    render_log("shape line commands=" .. count)
end

--@api: LShape:rectangle
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 20, 20, 60, 40)
    shape:setColor(0.9, 0.4, 0.2, 1.0)
    local count = shape:getCommandCount()
    render_log("shape rectangle commands=" .. count)
end

--@api: LShape:triangle
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape triangle added")
end

--@api: LShape:draw
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    shape:draw(100, 100, 0, 1, 1, 0, 0)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape draw called")
end

--@api: LShape:setLineWidth
do
    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    example_print_log("shape command count = " .. shape:getCommandCount())
    example_print_log("shape line width set to 2")
end

--@api: LShape:getCommandCount
do
    local shape = lurek.render.newShape()
    shape:circle("fill", 0, 0, 10)
    shape:circle("fill", 50, 50, 10)
    local before = shape:getCommandCount()
    shape:clear()
    local after = shape:getCommandCount()
    example_print_log("shape commands before clear = " .. before)
    example_print_log("shape commands after clear = " .. after)
end

--@api: LDrawLayer:flush
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function()
        lurek.render.circle("fill", 100, 100, 20)
    end)
    layer:queue(2.0, function()
        lurek.render.circle("fill", 200, 100, 20)
    end)
    example_print_log("draw layer count before flush = " .. layer:getCount())
    layer:flush()
    example_print_log("draw layer count after flush = " .. layer:getCount())
end

--@api: LDrawLayer:getCount
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    example_print_log("draw layer count = " .. layer:getCount())
    layer:clear()
end

--@api: LDrawLayer:queue
do
    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    example_print_log("draw layer count after queue = " .. layer:getCount())
    layer:clear()
end

--@api: lurek.render.drawq
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    lurek.render.draw(image, 10, 10, 0, 1, 1)
    lurek.render.drawq(image, quad, 50, 50, 0, 1, 1)
    example_print_log("drawq used a 16x16 quad")
    image:release()
end

--@api: lurek.render.drawNineSlice
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.render.newNineSlice(image, 4, 4, 4, 4)
    lurek.render.drawNineSlice(slice, 100, 100, 80, 60)
    example_print_log("drawNineSlice target size = 80x60")
    image:release()
end

--@api: lurek.render.clearStencil
do
    lurek.render.setStencilMode("replace", "always", 2)
    lurek.render.clearStencil()
    local action, compare, value = lurek.render.getStencilMode()
    lurek.render.rectangle("line", 0, 0, 8, 8)
    render_log("stencil mode after clear = " .. action .. "," .. compare .. "," .. value)
end

--@api: lurek.render.currentLayer
do
    lurek.render.newLayer("current_layer_stub", 12)
    lurek.render.setLayer("current_layer_stub")
    local current = lurek.render.currentLayer()
    local z = lurek.render.getLayerZOrder("current_layer_stub")
    render_log("current layer = " .. current .. " z=" .. z)
    lurek.render.setLayer("default")
end

--@api: lurek.render.flushSortGroup
do
    lurek.render.beginSortGroup(7)
    lurek.render.pushSortKey(5)
    lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(7)
    example_print_log("flushSortGroup id = 7")
end

--@api: lurek.render.pushSortKey
do
    lurek.render.beginSortGroup(8)
    lurek.render.pushSortKey(3)
    lurek.render.circle("fill", 120, 100, 10)
    lurek.render.flushSortGroup(8)
    example_print_log("pushSortKey depth = 3")
end

--@api: lurek.render.popLayer
do
    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.circle("fill", 140, 100, 10)
    lurek.render.popLayer(99)
    local mode = lurek.render.getBlendMode()
    render_log("popLayer id=99 blend=" .. mode)
end

--@api: lurek.render.getCanvasSize
do
    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    example_print_log("canvas size = " .. w .. "x" .. h)
    example_print_log("color mask red enabled = " .. tostring(select(1, lurek.render.getColorMask())))
    canvas:release()
end

--@api: lurek.render.getColorMask
do
    lurek.render.setColorMask(true, false, true, true)
    local r, g, b, a = lurek.render.getColorMask()
    lurek.render.rectangle("fill", 0, 0, 6, 6)
    render_log("color mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
end

--@api: lurek.render.getDefaultFilter
do
    local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter(min_filter, mag_filter, aniso)
    local min_again, mag_again, aniso_again = lurek.render.getDefaultFilter()
    local summary = min_again .. "/" .. mag_again
    render_log("default filter = " .. summary .. "," .. aniso_again)
end

--@api: lurek.render.getDepthMode
do
    local mode, write = lurek.render.getDepthMode()
    lurek.render.setDepthMode(mode, write)
    local confirm_mode, confirm_write = lurek.render.getDepthMode()
    local width = lurek.render.getWidth()
    render_log("depth mode = " .. confirm_mode .. " write=" .. tostring(confirm_write) .. " width=" .. width)
end

--@api: lurek.render.getFontCellWidth
do
    local font = lurek.render.getDefaultFont(14)
    local cell_width = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    render_log("font cell width = " .. cell_width .. " descent=" .. descent .. " ascent=" .. ascent)
end

--@api: lurek.render.getFontDescent
do
    local font = lurek.render.getDefaultFont(14)
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    local height = lurek.render.getFontHeight(font)
    render_log("font descent = " .. descent .. " ascent=" .. ascent .. " height=" .. height)
end

--@api: lurek.render.getFontHeight
do
    local font = lurek.render.getDefaultFont(14)
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    render_log("font height = " .. height .. " line_height=" .. line_height .. " cell_width=" .. cell_width)
end

--@api: lurek.render.getFontLineHeight
do
    local font = lurek.render.getDefaultFont(14)
    local line_height = lurek.render.getFontLineHeight(font)
    local line_width = lurek.render.getLineWidth()
    local height = lurek.render.getFontHeight(font)
    render_log("font line height = " .. line_height .. " line_width=" .. line_width .. " height=" .. height)
end

--@api: lurek.render.getStencilMode
do
    lurek.render.setStencilMode("replace", "always", 4)
    local action, compare, value = lurek.render.getStencilMode()
    lurek.render.circle("line", 8, 8, 4)
    render_log("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
end

--@api: lurek.render.isLayerVisible
do
    lurek.render.newLayer("visibility_stub", 2)
    lurek.render.setLayerVisible("visibility_stub", true)
    example_print_log("layer visible = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
    lurek.render.setLayerVisible("visibility_stub", false)
    example_print_log("layer visible after hide = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
end

--@api: lurek.render.loadModel
do
    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local normals = model:getNormalCount()
    local verts = model:getVertexCount()
    render_log("loadModel faces=" .. faces .. " normals=" .. normals .. " verts=" .. verts)
end

--@api: lurek.render.intersectScissor
do
    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    local x, y, w, h = lurek.render.getScissor()
    example_print_log("intersected scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api: lurek.render.resetCanvas
do
    local canvas = lurek.render.newCanvas(64, 64)
    lurek.render.resetCanvas(canvas)
    local w, h = canvas:getDimensions()
    render_log("resetCanvas called on " .. w .. "x" .. h .. " canvas")
    canvas:release()
end

--@api: lurek.render.saveScreenshot
do
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local path = "save/test_screenshot.png"
    render_log("saveScreenshot requested for " .. path .. " from " .. width .. "x" .. height)
end

--@api: lurek.render.setFontLineHeight
do
    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    render_log("setFontLineHeight line_height=" .. line_height .. " cell_width=" .. cell_width)
end

--@api: lurek.render.setLayer
do
    lurek.render.newLayer("set_layer_stub", 1)
    lurek.render.setLayer("set_layer_stub")
    local current = lurek.render.currentLayer()
    local visible = lurek.render.isLayerVisible("set_layer_stub")
    render_log("current layer = " .. current .. " visible=" .. tostring(visible))
    lurek.render.setLayer("default")
end

--@api: lurek.render.setLayerVisible
do
    lurek.render.newLayer("visible_layer_stub", 1)
    lurek.render.setLayerVisible("visible_layer_stub", false)
    local hidden = lurek.render.isLayerVisible("visible_layer_stub")
    render_log("layer visible after hide = " .. tostring(hidden))
    lurek.render.setLayerVisible("visible_layer_stub", true)
end

--@api: lurek.render.setLayerZOrder
do
    lurek.render.newLayer("zorder_layer_stub", 1)
    lurek.render.setLayerZOrder("zorder_layer_stub", 9)
    local z = lurek.render.getLayerZOrder("zorder_layer_stub")
    local visible = lurek.render.isLayerVisible("zorder_layer_stub")
    render_log("layer z order = " .. z .. " visible=" .. tostring(visible))
end

--@api: lurek.render.setStencilTest
do
    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest()
    local action, compare, value = lurek.render.getStencilMode()
    render_log("setStencilTest enabled and cleared with mode " .. action .. "," .. compare .. "," .. value)
end

--@api: lurek.render.setBold
do
    local previous = lurek.render.isBold()
    lurek.render.setBold(true)
    lurek.render.print("Bold text", 10, 10)
    example_print_log("bold after set = " .. tostring(lurek.render.isBold()))
    lurek.render.setBold(previous)
    example_print_log("bold restored = " .. tostring(lurek.render.isBold()))
end

--@api: lurek.render.isBold
do
    local v = lurek.render.isBold()
    local font_names = lurek.render.getBuiltInFontNames()
    local first = font_names[1] or "none"
    local count = #font_names
    render_log("isBold = " .. tostring(v) .. " built_in_fonts=" .. count .. " first=" .. first)
end

--@api: lurek.render.printRotatedWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printRotatedWithFont(font, "Rotated text", 100, 100, math.pi / 4, 1.0)
    local ascent = lurek.render.getFontAscent(font)
    local width = lurek.render.getFontWidth(font, "Rotated text")
    render_log("printRotatedWithFont angle=" .. tostring(math.pi / 4) .. " ascent=" .. ascent .. " width=" .. width)
end

--@api: lurek.render.printWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printWithFont(font, "Standard text override", 10, 150)
    local width = lurek.render.getFontWidth(font, "Standard text override")
    local height = lurek.render.getFontHeight(font)
    render_log("printWithFont width=" .. width .. " height=" .. height)
end

--@api: lurek.render.printfWithFont
do
    local font = lurek.render.getDefaultFont(16)
    lurek.render.printfWithFont(font, "Formatted text inside a 160 px box.", 10, 200, 160, "left")
    local wrap_lines, wrap_width = font:getWrap("Formatted text inside a 160 px box.", 160)
    local first = wrap_lines[1] or ""
    render_log("printfWithFont limit=160 align=left lines=" .. #wrap_lines .. " width=" .. wrap_width .. " first=" .. first)
end

--@api: lurek.render.printRichWithFont
do
    local font = lurek.render.getDefaultFont(16)
    local spans = {
        { text = "Red", r = 255, g = 0, b = 0, a = 255, scale = 1 },
        { text = " and ", r = 255, g = 255, b = 255, a = 255, scale = 1 },
        { text = "Green", r = 0, g = 255, b = 0, a = 255, scale = 1 },
    }
    lurek.render.printRichWithFont(font, spans, 10, 250)
    example_print_log("printRichWithFont spans = " .. #spans)
    example_print_log("printRichWithFont uses byte colors")
end

--@api: lurek.render.getBuiltInFontNames
do
    local names = lurek.render.getBuiltInFontNames()
    local first = names[1] or "none"
    local last = names[#names] or "none"
    local count = #names
    render_log("built-in font names=" .. count .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

--@api: lurek.render.newDepthSorter
do
    local sorter = lurek.render.newDepthSorter()
    sorter:add(function() example_print_log("draw layer A") end, 10)
    sorter:add(function() example_print_log("draw layer B") end, 5)
    sorter:flush()
    example_print_log("depth sorter type = " .. sorter:type())
end
