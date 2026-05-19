-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

--- Render Module Part 1: basic drawing — print, rectangle, circle, line, polygon, points, arc, ellipse, triangle

--@api-stub: lurek.render.print
-- Drawing text to the screen.
do
    lurek.render.print("Hello, Lurek2D!", 10, 10)
    lurek.render.print("Scaled text", 10, 30, 2.0)
    lurek.render.print("Small text", 10, 60, 0.5)
    lurek.render.print("", 0, 0)
end

--@api-stub: lurek.render.printf
-- Drawing aligned, word-wrapped text.
do
    lurek.render.printf("Left-aligned paragraph that wraps at 200 pixels width.", 10, 100, 200, "left")
    lurek.render.printf("Centered text within a 300px box.", 10, 140, 300, "center")
    lurek.render.printf("Right-aligned text example.", 10, 180, 250, "right")
    lurek.render.printf("Justified paragraph with multiple words.", 10, 220, 200, "justify")
end

--@api-stub: lurek.render.printRotated
-- Drawing rotated text around its center.
do
    lurek.render.printRotated("Rotated!", 200, 200, math.pi / 4)
    lurek.render.printRotated("Upside down", 300, 200, math.pi)
    lurek.render.printRotated("Scaled rotated", 400, 200, -math.pi / 6, 1.5)
end

--@api-stub: lurek.render.printRich
-- Drawing rich text with per-span styling.
do
    local spans = {
        { text = "Red ",   r = 1, g = 0, b = 0, a = 1, scale = 1 },
        { text = "Green ", r = 0, g = 1, b = 0, a = 1, scale = 1 },
        { text = "Blue",   r = 0, g = 0, b = 1, a = 1, scale = 1.5 },
    }
    lurek.render.printRich(spans, 10, 260)
end

--@api-stub: lurek.render.rectangle
-- Drawing rectangles in fill and line modes.
do
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 50, 300, 100, 60)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("line", 50, 300, 100, 60)
    lurek.render.setColor(0, 0, 1, 0.5)
    lurek.render.rectangle("fill", 80, 320, 100, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.rectangle
-- Drawing rounded rectangles.
do
    lurek.render.setColor(0.8, 0.2, 0.8, 1)
    lurek.render.rectangle("fill", 200, 300, 120, 80, 12)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.rectangle("line", 200, 300, 120, 80, 12, 6)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.circle
-- Drawing circles.
do
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.circle("fill", 500, 340, 40)
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.circle("line", 500, 340, 40)
    lurek.render.setColor(0.5, 0.5, 0.5, 1)
    lurek.render.circle("fill", 600, 340, 20)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.ellipse
-- Drawing ellipses.
do
    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 150, 450, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 150, 450, 60, 30)
    lurek.render.setColor(0.9, 0.3, 0.1, 1)
    lurek.render.ellipse("fill", 300, 450, 30, 60)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.arc
-- Drawing arc segments.
do
    lurek.render.setColor(1, 0.8, 0, 1)
    lurek.render.arc("fill", 500, 450, 50, 0, math.pi / 2)
    lurek.render.setColor(0, 0.8, 0.3, 1)
    lurek.render.arc("line", 500, 450, 50, math.pi, math.pi * 1.5, 16)
    lurek.render.setColor(0.5, 0, 1, 1)
    lurek.render.arc("fill", 620, 450, 40, 0, math.pi * 2, 64)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.line
-- Drawing lines and polylines.
do
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.line(10, 520, 200, 520)
    lurek.render.setColor(0, 1, 1, 1)
    lurek.render.line(10, 540, 50, 560, 90, 540, 130, 560, 170, 540, 200, 560)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.polygon
-- Drawing polygons from vertex lists.
do
    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 300, 520, 350, 500, 400, 520, 380, 570, 320, 570)
end

--@api-stub: lurek.render.triangle
-- Drawing triangles.
do
    lurek.render.setColor(0, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 450, 570, 500, 500, 550, 570)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 560, 570, 610, 500, 660, 570)
end

--@api-stub: lurek.render.points
-- Drawing points with different sizes.
do
    lurek.render.setPointSize(4)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.points(50, 600, 70, 600, 90, 600, 110, 600, 130, 600)
    lurek.render.setPointSize(8)
    lurek.render.setColor(0, 0, 1, 1)
    lurek.render.points({ { 160, 600 }, { 180, 600 }, { 200, 600 } })
    lurek.render.setPointSize(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setLineWidth
--@api-stub: lurek.render.getLineWidth
-- Controlling line width.
do
    lurek.render.setLineWidth(1)
    lurek.render.line(10, 630, 100, 630)
    lurek.render.setLineWidth(3)
    lurek.render.line(10, 640, 100, 640)
    lurek.render.setLineWidth(5)
    lurek.render.line(10, 650, 100, 650)
    local w = lurek.render.getLineWidth()
    print("line width = " .. w)
    lurek.render.setLineWidth(1)
end

--@api-stub: lurek.render.setPointSize
--@api-stub: lurek.render.getPointSize
-- Controlling point size.
do
    lurek.render.setPointSize(2)
    local s = lurek.render.getPointSize()
    print("point size = " .. s)
    lurek.render.setPointSize(1)
end

--@api-stub: lurek.render.drawCubicBezier
--@api-stub: lurek.render.drawQuadBezier
-- Drawing Bezier curves.
do
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.drawCubicBezier(120, 630, 160, 580, 220, 680, 260, 630, 24)
    lurek.render.setColor(0, 1, 0.5, 1)
    lurek.render.drawQuadBezier(300, 630, 350, 580, 400, 630, 16)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawPath
-- Drawing vector paths.
do
    local path = {
        { type = "moveTo", x = 450, y = 620 },
        { type = "lineTo", x = 500, y = 600 },
        { type = "quadTo", cx = 550, cy = 580, x = 580, y = 620 },
        { type = "lineTo", x = 560, y = 660 },
        { type = "cubicTo", cx1 = 530, cy1 = 680, cx2 = 480, cy2 = 680, x = 450, y = 660 },
    }
    lurek.render.setColor(0.6, 0.2, 1, 1)
    lurek.render.drawPath(path, "line", true)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawGradientRect
-- Drawing gradient-filled rectangles.
do
    lurek.render.drawGradientRect(10, 680, 150, 40, { 1, 0, 0 }, { 0, 0, 1 }, "horizontal")
    lurek.render.drawGradientRect(170, 680, 150, 40, { 0, 1, 0 }, { 1, 1, 0 }, "vertical")
    lurek.render.drawGradientRect(330, 680, 80, 80, { 1, 1, 1 }, { 0, 0, 0 }, "radial")
end

--@api-stub: lurek.render.drawColoredPolygon
-- Drawing polygons with per-vertex colors.
do
    local verts = { 450, 680, 520, 680, 520, 740, 450, 740 }
    local colors = {
        { 1, 0, 0, 1 },
        { 0, 1, 0, 1 },
        { 0, 0, 1, 1 },
        { 1, 1, 0, 1 },
    }
    lurek.render.drawColoredPolygon(verts, colors, "fill")
end

--@api-stub: lurek.render.drawHexTile
-- Drawing hexagonal tiles.
do
    lurek.render.setColor(0, 0.6, 0.4, 1)
    lurek.render.drawHexTile(600, 700, 25, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(600, 700, 25, "pointyTop", "line")
    lurek.render.setColor(0.8, 0.4, 0, 1)
    lurek.render.drawHexTile(660, 700, 25, "flatTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(660, 700, 25, "flatTop", "line")
end

--@api-stub: lurek.render.drawBevelRect
-- Drawing beveled 3D-style rectangles.
do
    lurek.render.drawBevelRect(10, 750, 100, 40, 3, "raised")
    lurek.render.drawBevelRect(120, 750, 100, 40, 3, "sunken")
    lurek.render.drawBevelRect(230, 750, 100, 40, 2, "groove")
    lurek.render.drawBevelRect(340, 750, 100, 40, 2, "ridge")
    lurek.render.drawBevelRect(450, 750, 100, 40, 2, "flat", {
        fillColor = { 0.2, 0.3, 0.8, 1 }
    })
end

--- Render Module Part 2: color state, transforms, scissor, clear, blend modes, wireframe, layers, depth

--@api-stub: lurek.render.setColor
-- Color state management.
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(0.5, 0.5, 0.5, 0.8)
    r, g, b, a = lurek.render.getColor()
    print("gray = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setBackgroundColor
-- Background clear color.
do
    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    print("bg = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end

--@api-stub: lurek.render.setColorMask
-- Color channel write mask.
do
    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    print("mask: r=" .. tostring(r) .. " g=" .. tostring(g) .. " b=" .. tostring(b) .. " a=" .. tostring(a))
    lurek.render.setColorMask()
end

--@api-stub: lurek.render.push
-- Basic transform stack.
do
    lurek.render.push()
    lurek.render.translate(100, 100)
    lurek.render.rectangle("fill", 0, 0, 50, 50)
    lurek.render.pop()
    lurek.render.push()
    lurek.render.translate(200, 100)
    lurek.render.rotate(math.pi / 4)
    lurek.render.rectangle("fill", -25, -25, 50, 50)
    lurek.render.pop()
    lurek.render.push()
    lurek.render.translate(350, 100)
    lurek.render.scale(2, 0.5)
    lurek.render.rectangle("fill", 0, 0, 30, 30)
    lurek.render.pop()
end

--@api-stub: lurek.render.shear
-- Shear (skew) transform.
do
    lurek.render.push()
    lurek.render.translate(100, 200)
    lurek.render.shear(0.3, 0)
    lurek.render.setColor(0, 0.8, 0.5, 1)
    lurek.render.rectangle("fill", 0, 0, 80, 40)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

--@api-stub: lurek.render.origin
-- Reset transform to identity.
do
    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.render.pop()
end

--@api-stub: lurek.render.applyTransform
-- Apply a custom 3x3 matrix.
do
    local mat = {
        1, 0, 0,
        0, 1, 0,
        50, 250, 1
    }
    lurek.render.push()
    lurek.render.applyTransform(mat)
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 40, 40)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

--@api-stub: lurek.render.setScissor
-- Scissor rectangle clipping.
do
    lurek.render.setScissor(50, 300, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    print("scissor = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 0, 280, 400, 150)
    lurek.render.intersectScissor(100, 320, 100, 60)
    lurek.render.setColor(0, 0, 1, 1)
    lurek.render.rectangle("fill", 0, 280, 400, 150)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.setScissor()
end

--@api-stub: lurek.render.clear
-- Clearing the render queue.
do
    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    print("cleared render commands")
end

--@api-stub: lurek.render.setBlendMode
-- Blend mode switching.
do
    local original = lurek.render.getBlendMode()
    print("default blend = " .. original)
    lurek.render.setBlendMode("add")
    print("now = " .. lurek.render.getBlendMode())
    lurek.render.setColor(0.5, 0, 0, 1)
    lurek.render.rectangle("fill", 300, 300, 80, 80)
    lurek.render.setColor(0, 0.5, 0, 1)
    lurek.render.rectangle("fill", 340, 320, 80, 80)
    lurek.render.setBlendMode("multiply")
    lurek.render.setColor(1, 0.5, 0.5, 1)
    lurek.render.rectangle("fill", 300, 400, 80, 80)
    lurek.render.setBlendMode("alpha")
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setWireframe
-- Wireframe mode toggle.
do
    print("wireframe = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 450, 300, 60, 60)
    lurek.render.circle("fill", 540, 330, 30)
    lurek.render.setWireframe(false)
end

--@api-stub: lurek.render.newLayer
-- Rendering layers for draw call organization.
do
    lurek.render.newLayer("background", 0)
    lurek.render.newLayer("foreground", 10)
    lurek.render.newLayer("ui", 100)
    lurek.render.setLayer("background")
    print("current layer = " .. lurek.render.currentLayer())
    lurek.render.setColor(0.2, 0.2, 0.4, 1)
    lurek.render.rectangle("fill", 0, 450, 800, 100)
    lurek.render.setLayer("foreground")
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.circle("fill", 100, 500, 20)
    lurek.render.setLayer("ui")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("HUD Layer", 10, 460)
    print("bg visible = " .. tostring(lurek.render.isLayerVisible("background")))
    lurek.render.setLayerVisible("background", false)
    print("bg visible = " .. tostring(lurek.render.isLayerVisible("background")))
    lurek.render.setLayerVisible("background", true)
end

--@api-stub: lurek.render.getLayerZOrder
-- Layer z-order management.
do
    lurek.render.newLayer("midground", 5)
    print("midground z = " .. lurek.render.getLayerZOrder("midground"))
    lurek.render.setLayerZOrder("midground", 50)
    print("midground z = " .. lurek.render.getLayerZOrder("midground"))
end

--@api-stub: lurek.render.pushLayer
-- Compositing layers with alpha and blend mode.
do
    lurek.render.pushLayer(1, 0.5, "alpha")
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 50, 560, 100, 60)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("fill", 80, 580, 100, 60)
    lurek.render.popLayer(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.beginSortGroup
-- Depth-sorted rendering groups.
do
    lurek.render.beginSortGroup(1)
    lurek.render.pushSortKey(10)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 200, 560, 40, 40)
    lurek.render.pushSortKey(5)
    lurek.render.setColor(0, 0, 1, 1)
    lurek.render.rectangle("fill", 210, 570, 40, 40)
    lurek.render.pushSortKey(15)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("fill", 220, 580, 40, 40)
    lurek.render.flushSortGroup(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setDepthMode
-- Depth buffer configuration.
do
    local mode, write = lurek.render.getDepthMode()
    print("depth: mode=" .. mode .. " write=" .. tostring(write))
    lurek.render.setDepthMode("lequal", true)
    mode, write = lurek.render.getDepthMode()
    print("depth: mode=" .. mode .. " write=" .. tostring(write))
    lurek.render.setDepthMode("always", false)
end

--@api-stub: lurek.render.setDefaultFilter
-- Default texture filter settings.
do
    local min, mag, aniso = lurek.render.getDefaultFilter()
    print("filter: min=" .. min .. " mag=" .. mag .. " aniso=" .. aniso)
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    min, mag, aniso = lurek.render.getDefaultFilter()
    print("filter: min=" .. min .. " mag=" .. mag .. " aniso=" .. aniso)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end

--@api-stub: lurek.render.getDimensions
-- Window dimensions query.
do
    local w, h = lurek.render.getDimensions()
    print("dimensions = " .. w .. "x" .. h)
    print("width = " .. lurek.render.getWidth())
    print("height = " .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getStats
-- Render statistics.
do
    local stats = lurek.render.getStats()
    print("drawcalls = " .. stats.drawcalls)
    print("textures = " .. stats.textures)
    print("fonts = " .. stats.fonts)
    print("canvases = " .. stats.canvases)
    print("texture_memory = " .. stats.texture_memory)
    print("gpu_draw_calls = " .. stats.gpu_draw_calls)
    print("cpu_render_ms = " .. string.format("%.2f", stats.cpu_render_ms))
end

--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice

--@api-stub: lurek.render.newImage
-- Loading and drawing images.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    print("image: " .. img:getWidth() .. "x" .. img:getHeight())
    local w, h = img:getDimensions()
    print("dimensions: " .. w .. "x" .. h)
    lurek.render.draw(img, 10, 10)
    lurek.render.draw(img, 120, 10, math.pi / 6, 0.5, 0.5)
    lurek.render.draw(img, 200, 10, 0, 2, 2, w / 2, h / 2)
end

--@api-stub: LImage:getId
--@api-stub: LImage:type
--@api-stub: LImage:typeOf
--@api-stub: LImage:release
-- Image handle inspection and lifecycle.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    print("id = " .. img:getId())
    print("type = " .. img:type())
    print("is LImage = " .. tostring(img:typeOf("LImage")))
    local released = img:release()
    print("released = " .. tostring(released))
end

-- Creating an image from pixel data.
--@api-stub: LImageData:mapPixels
do
    ---@type LImageData
    local data = lurek.image.newImageData(32, 32)
    data:mapPixels(function(x, y, r, g, b, a)
        return x / 32, y / 32, 0.5, 1
    end)
    ---@type LImage
    local img = lurek.render.newImage(data)
    lurek.render.draw(img, 10, 100)
    print("from data: " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.render.newCanvas
-- Off-screen canvas rendering.
do
    ---@type LCanvas
    local canvas = lurek.render.newCanvas(128, 128)
    print("canvas: " .. canvas:getWidth() .. "x" .. canvas:getHeight())
    local cw, ch = canvas:getDimensions()
    print("canvas dims: " .. cw .. "x" .. ch)
    lurek.render.setCanvas(canvas)
    lurek.render.setColor(0.2, 0.5, 0.8, 1)
    lurek.render.rectangle("fill", 0, 0, 128, 128)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.circle("fill", 64, 64, 40)
    lurek.render.setCanvas(nil)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(canvas, 10, 150)
    lurek.render.draw(canvas, 150, 150, 0, 0.5, 0.5)
end

--@api-stub: LCanvas:type
--@api-stub: LCanvas:typeOf
--@api-stub: LCanvas:release
-- Canvas type and lifecycle.
do
    ---@type LCanvas
    local canvas = lurek.render.newCanvas(64, 64)
    print("type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    local released = canvas:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getCanvas
-- Canvas query and reset.
do
    ---@type LCanvas
    local canvas = lurek.render.newCanvas(200, 100)
    lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas()
    print("active canvas = " .. tostring(active))
    local cw, ch = lurek.render.getCanvasSize(canvas)
    print("canvas size = " .. cw .. "x" .. ch)
    lurek.render.setCanvas(nil)
    lurek.render.resetCanvas(canvas)
    print("canvas reset done")
end

--@api-stub: lurek.render.newQuad
-- Quad-based sub-region drawing for sprite sheets.
do
    ---@type LImage
    local sheet = lurek.render.newImage("assets/textures/ray_water.png")
    local sw, sh = sheet:getDimensions()
    ---@type LQuad
    local q1 = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    ---@type LQuad
    local q2 = lurek.render.newQuad(16, 0, 16, 16, sw, sh)
    local x, y, w, h = q1:getViewport()
    print("q1 viewport = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    local tw, th = q1:getTextureDimensions()
    print("texture = " .. tw .. "x" .. th)
    lurek.render.drawq(sheet, q1, 10, 310)
    lurek.render.drawq(sheet, q2, 30, 310)
    lurek.render.drawq(sheet, q1, 60, 310, math.pi / 4, 2, 2)
    q2:setViewport(32, 0, 16, 16)
    lurek.render.drawq(sheet, q2, 120, 310)
end

--@api-stub: LQuad:type
--@api-stub: LQuad:typeOf
-- Quad type inspection.
do
    ---@type LQuad
    local q = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("type = " .. q:type())
    print("is LQuad = " .. tostring(q:typeOf("LQuad")))
end

--@api-stub: lurek.render.newSpriteBatch
-- Batched sprite rendering.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LSpriteBatch
    local batch = lurek.render.newSpriteBatch(img, 100)
    print("batch capacity = " .. batch:getBufferSize())
    for i = 0, 9 do
        local idx = batch:add(i * 20, 380, 0, 0.5, 0.5)
    end
    print("batch count = " .. batch:getCount())
    lurek.render.draw(batch, 10, 0)
    batch:clear()
    print("after clear = " .. batch:getCount())
end

--@api-stub: LSpriteBatch:type
--@api-stub: LSpriteBatch:typeOf
--@api-stub: LSpriteBatch:release
-- Sprite batch lifecycle.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LSpriteBatch
    local batch = lurek.render.newSpriteBatch(img, 50)
    print("type = " .. batch:type())
    print("is LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    local released = batch:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.drawMany
-- Batch-drawing multiple images in one call.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    local list = {
        { img, 10, 420, 0, 0.3, 0.3 },
        { img, 50, 420, math.pi / 8, 0.3, 0.3 },
        { img, 90, 420, math.pi / 4, 0.3, 0.3 },
        { img, 130, 420, math.pi / 2, 0.3, 0.3 },
    }
    lurek.render.drawMany(list)
end

--@api-stub: lurek.render.newNineSlice
-- 9-slice scalable UI panel rendering.
do
    ---@type LImage
    local panelImg = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LNineSlice
    local slice = lurek.render.newNineSlice(panelImg, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    print("insets: " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    local tw, th = slice:getTextureSize()
    print("source texture: " .. tw .. "x" .. th)
    lurek.render.drawNineSlice(slice, 10, 470, 200, 60)
    lurek.render.drawNineSlice(slice, 220, 470, 80, 80)
    print("type = " .. slice:type())
    print("is LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
end

--@api-stub: lurek.render.newDrawLayer
-- Z-ordered draw callback layers.
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
--@api-stub: LDrawLayer:type
--@api-stub: LDrawLayer:typeOf
-- Draw layer lifecycle.
do
    ---@type LDrawLayer
    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() end)
    layer:queue(2, function() end)
    layer:clear()
    print("cleared, count = " .. layer:getCount())
    print("type = " .. layer:type())
    print("is LDrawLayer = " .. tostring(layer:typeOf("LDrawLayer")))
end

--@api-stub: lurek.render.drawIsoCubeTile
-- Isometric cube tile rendering.
do
    lurek.render.drawIsoCubeTile(400, 500, 30, 15, {
        depth = 20,
        topColor = { 0.8, 0.8, 0.8, 1 },
        leftColor = { 0.5, 0.5, 0.5, 1 },
        rightColor = { 0.3, 0.3, 0.3, 1 },
    })
    lurek.render.drawIsoCubeTile(460, 500, 30, 15, {
        depth = 30,
        topColor = { 0.2, 0.7, 0.2, 1 },
        leftColor = { 0.1, 0.5, 0.1, 1 },
        rightColor = { 0.05, 0.3, 0.05, 1 },
    })
end

--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api-stub: lurek.render.newShader
-- Creating and using shaders.
do
    local code = [[
        @vertex
        fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> {
            return vec4<f32>(0.0, 0.0, 0.0, 1.0);
        }
        @fragment
        fn fs_main() -> @location(0) vec4<f32> {
            return vec4<f32>(1.0, 0.0, 0.0, 1.0);
        }
    ]]
    ---@type LShader
    local shader = lurek.render.newShader(code)
    print("type = " .. shader:type())
    print("is LShader = " .. tostring(shader:typeOf("LShader")))
    print("has 'time' = " .. tostring(shader:hasUniform("time")))
    print("has 'missing' = " .. tostring(shader:hasUniform("missing")))
end

--@api-stub: LShader:send
--@api-stub: LShader:setShader
--@api-stub: LShader:getShader
-- Sending uniforms and activating shaders.
do
    local code = [[
        @vertex
        fn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4<f32> {
            return vec4<f32>(0.0, 0.0, 0.0, 1.0);
        }
        @fragment
        fn fs_main() -> @location(0) vec4<f32> {
            return vec4<f32>(0.5, 0.5, 1.0, 1.0);
        }
    ]]
    ---@type LShader
    local shader = lurek.render.newShader(code)
    shader:send("time", 1.5)
    shader:send("enabled", true)
    shader:send("color", { 1.0, 0.5, 0.0 })
    shader:send("offset", { 10, 20 })
    lurek.render.setShader(shader)
    local active = lurek.render.getShader()
    print("shader active = " .. tostring(active))
    lurek.render.rectangle("fill", 10, 10, 100, 100)
    lurek.render.setShader(nil)
end

--@api-stub: LShader:release
-- Shader lifecycle.
do
    local code = [[
        @vertex fn vs(@builtin(vertex_index) i: u32) -> @builtin(position) vec4<f32> { return vec4<f32>(0.0); }
        @fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }
    ]]
    ---@type LShader
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.newMesh
-- Creating and drawing a custom mesh.
do
    local verts = {
        { 100, 100, 0, 0, 1, 0, 0, 1 },
        { 200, 100, 1, 0, 0, 1, 0, 1 },
        { 150, 200, 0.5, 1, 0, 0, 1, 1 },
    }
    ---@type LMesh
    local mesh = lurek.render.newMesh(verts, "triangles")
    print("vertex count = " .. mesh:getVertexCount())
    lurek.render.draw(mesh, 0, 0)
    lurek.render.draw(mesh, 200, 0, math.pi / 4, 0.5, 0.5)
end

--@api-stub: LMesh:setVertex
--@api-stub: LMesh:getVertex
-- Modifying mesh vertices.
do
    local verts = {
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 50, 0.5, 1, 1, 1, 1, 1 },
    }
    ---@type LMesh
    local mesh = lurek.render.newMesh(verts)
    mesh:setVertex(1, { 10, 10, 0, 0, 1, 0, 0, 1 })
    local x, y, u, v, r, g, b, a = mesh:getVertex(1)
    print("v1: x=" .. x .. " y=" .. y .. " r=" .. r .. " g=" .. g .. " b=" .. b)
    mesh:setVertex(3, { 30, 60, 0.5, 1, 0, 1, 0, 1 })
end

--@api-stub: LMesh:setTexture
--@api-stub: LMesh:release
--@api-stub: LMesh:type
--@api-stub: LMesh:typeOf
-- Mesh texture and lifecycle.
do
    local verts = {
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }
    ---@type LMesh
    local mesh = lurek.render.newMesh(verts, "fan")
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mesh:setTexture(img)
    lurek.render.draw(mesh, 300, 100)
    mesh:setTexture(nil)
    print("type = " .. mesh:type())
    print("is LMesh = " .. tostring(mesh:typeOf("LMesh")))
    local released = mesh:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.newShape
-- Retained compound shape with accumulated draw commands.
do
    ---@type LShape
    local shape = lurek.render.newShape()
    shape:setColor(1, 0, 0, 1)
    shape:rectangle("fill", 0, 0, 60, 40)
    shape:setColor(0, 1, 0, 1)
    shape:circle("fill", 80, 20, 15)
    shape:setColor(0, 0, 1, 1)
    shape:line(0, 50, 100, 50)
    shape:setColor(1, 1, 0, 1)
    shape:ellipse("fill", 50, 80, 30, 15)
    shape:setColor(1, 0, 1, 1)
    shape:arc("fill", 120, 30, 20, 0, math.pi)
    shape:setColor(0, 1, 1, 1)
    shape:triangle("fill", 140, 0, 180, 0, 160, 30)
    print("commands = " .. shape:getCommandCount())
    shape:draw(10, 250)
    shape:draw(200, 250, math.pi / 6, 0.8, 0.8)
end

--@api-stub: LShape:polygon
--@api-stub: LShape:polyline
--@api-stub: LShape:roundedRectangle
-- Shape polygon and polyline commands.
do
    ---@type LShape
    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30)
    shape:setColor(1, 1, 1, 1)
    shape:polyline(60, 0, 80, 20, 100, 0, 120, 20)
    shape:setLineWidth(3)
    shape:setColor(0.5, 0.5, 1, 1)
    shape:roundedRectangle("line", 0, 60, 80, 40, 8)
    shape:draw(400, 250)
end

--@api-stub: LShape:clear
--@api-stub: LShape:type
--@api-stub: LShape:typeOf
-- Shape lifecycle.
do
    ---@type LShape
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5)
    print("before clear = " .. shape:getCommandCount())
    shape:clear()
    print("after clear = " .. shape:getCommandCount())
    print("type = " .. shape:type())
    print("is LShape = " .. tostring(shape:typeOf("LShape")))
end

--@api-stub: lurek.render.loadObj
-- Loading and inspecting a 3D OBJ model.
do
    ---@type LObjModel
    local model = lurek.render.loadObj("assets/textures/ray_water.png")
    print("faces = " .. model:getFaceCount())
    print("vertices = " .. model:getVertexCount())
    print("normals = " .. model:getNormalCount())
    print("uvs = " .. model:getUvCount())
end

--@api-stub: LObjModel:projectToMesh
-- Projecting a 3D model to 2D vertex data.
do
    ---@type LObjModel
    local model = lurek.render.loadModel("assets/textures/ray_water.png")
    local camera = {
        x = 0, y = 0, z = -5,
        tx = 0, ty = 0, tz = 0,
        fov = 60
    }
    local verts = model:projectToMesh(camera, 320, 240)
    print("projected vertices = " .. #verts)
    if #verts > 0 then
        print("first: x=" .. verts[1].x .. " y=" .. verts[1].y)
    end
end

--@api-stub: LObjModel:renderToImage
-- Rendering a model to a texture.
do
    ---@type LObjModel
    local model = lurek.render.loadModel("assets/textures/ray_water.png")
    ---@type LImage
    local img = model:renderToImage(64, 64, 0)
    print("rendered: " .. img:getWidth() .. "x" .. img:getHeight())
    lurek.render.draw(img, 10, 400)
    ---@type LImage
    local rotated = model:renderToImage(64, 64, 1)
    lurek.render.draw(rotated, 80, 400)
end

--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density

--@api-stub: lurek.render.newFont
-- Loading and activating fonts.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    print("font type = " .. font:type())
    print("is LFont = " .. tostring(font:typeOf("LFont")))
    lurek.render.setFont(font)
    ---@type LFont
    local active = lurek.render.getFont()
    print("active font = " .. active:type())
    lurek.render.print("Using custom font", 10, 10)
end

--@api-stub: lurek.render.getDefaultFont
-- Using the built-in default font.
do
    ---@type LFont
    local defFont = lurek.render.getDefaultFont()
    print("default font height = " .. defFont:getHeight())
    ---@type LFont
    local bigDefault = lurek.render.getDefaultFont(24)
    print("big default height = " .. bigDefault:getHeight())
    lurek.render.setFont(bigDefault)
    lurek.render.print("Big default font", 10, 30)
end

--@api-stub: LFont:getWidth
--@api-stub: LFont:getHeight
--@api-stub: LFont:getLineHeight
--@api-stub: LFont:getAscent
--@api-stub: LFont:getDescent
-- Font metrics.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 14)
    print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getWrap
--@api-stub: LFont:setLineHeight
-- Word wrapping and line height control.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 12)
    local lines, width = font:getWrap("This is a long paragraph of text that should wrap nicely.", 150)
    print("wrapped lines = " .. #lines .. " width = " .. width)
    for i, line in ipairs(lines) do
        print("  " .. i .. ": " .. line)
    end
    font:setLineHeight(1.5)
    print("new line height = " .. font:getLineHeight())
end

--@api-stub: LFont:release
-- Font lifecycle.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 18)
    local released = font:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getFontSizes
-- Querying available font sizes.
do
    local sizes = lurek.render.getFontSizes()
    print("available sizes = " .. #sizes)
    for i, s in ipairs(sizes) do
        if i <= 5 then
            print("  size " .. i .. " = " .. s)
        end
    end
end

--@api-stub: lurek.render.getFontWidth
-- Font helpers that accept font as first parameter.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 14)
    local w = lurek.render.getFontWidth(font, "Measurement")
    print("font width = " .. w)
    local h = lurek.render.getFontHeight(font)
    print("font height = " .. h)
    local lh = lurek.render.getFontLineHeight(font)
    print("line height = " .. lh)
end

--@api-stub: lurek.render.getFontAscent
-- Advanced font metrics.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    print("ascent = " .. lurek.render.getFontAscent(font))
    print("descent = " .. lurek.render.getFontDescent(font))
    print("cell width = " .. lurek.render.getFontCellWidth(font))
end

--@api-stub: lurek.render.getFontWrap
-- Render-level font wrapping and line height.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 12)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    print("lines = " .. #lines .. " max_width = " .. width)
    lurek.render.setFontLineHeight(font, 2.0)
    print("set line height to 2.0")
end

--@api-stub: lurek.render.stencil
-- Stencil masking for shaped clipping.
do
    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 200, 200, 60)
    lurek.render.stencil()
    lurek.render.setStencilTest("equal", 1)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 100, 100, 200, 200)
    lurek.render.setStencilTest()
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setStencilMode
-- Stencil mode control.
do
    lurek.render.setStencilMode("replace", "always", 1)
    lurek.render.rectangle("fill", 300, 100, 100, 100)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil: action=" .. action .. " compare=" .. compare .. " value=" .. value)
    lurek.render.clearStencil()
    lurek.render.setStencilMode("keep", "always", 0)
end

--@api-stub: lurek.render.captureScreenshot
-- Screenshot capture.
do
    lurek.render.setColor(0.2, 0.4, 0.8, 1)
    lurek.render.rectangle("fill", 0, 0, 320, 240)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.circle("fill", 160, 120, 50)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.captureScreenshot(function(data)
        print("screenshot captured: " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/screenshot_test.png")
    print("screenshot saved")
end

-- Using a canvas as a render texture for post-processing.
--@api-stub: lurek.render.setCanvas
--@api-stub: lurek.render.draw
do
    ---@type LCanvas
    local rt = lurek.render.newCanvas(256, 256)
    lurek.render.setCanvas(rt)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 256, 256)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.circle("fill", 128, 128, 80)
    lurek.render.setCanvas(nil)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(rt, 400, 50, 0, 0.5, 0.5)
end

-- Using fonts directly with print.
--@api-stub: lurek.render.newFont
--@api-stub: lurek.render.setFont
--@api-stub: lurek.render.getDefaultFont
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    lurek.render.setFont(font)
    lurek.render.print("Rendered with custom font", 10, 350)
    lurek.render.print("Second line", 10, 370)
    ---@type LFont
    local def = lurek.render.getDefaultFont()
    lurek.render.setFont(def)
end

--- Render Module Part 5: LCanvas, LFont release/type, LImage release/type, LMesh, LQuad getViewport/type, LShader, LSpriteBatch

--@api-stub: LCanvas:getDimensions
--@api-stub: LCanvas:getHeight
--@api-stub: LCanvas:getWidth
-- Canvas dimension queries, release, and type introspection.
do
    local c = lurek.render.newCanvas(128, 64)
    local w, h = c:getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. c:getWidth())
    print("h=" .. c:getHeight())
    print("type=" .. c:type())
    print("typeOf=" .. tostring(c:typeOf("LCanvas")))
    c:release()
end

--@api-stub: LFont:type
--@api-stub: LFont:typeOf
-- Font release and type introspection.
do
    local f = lurek.render.newFont("assets/fonts/Roboto-Regular.ttf", 16)
    print("type=" .. f:type())
    print("typeOf=" .. tostring(f:typeOf("LFont")))
    f:release()
end

--@api-stub: LMesh:getVertexCount
-- Mesh vertex queries, mutation, texture, and type introspection.
do
    local verts = {
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 100, 0, 1, 0, 1, 1, 1, 1 },
        { 50, 100, 0.5, 1, 1, 1, 1, 1 },
    }
    local mesh = lurek.render.newMesh(verts, "triangles")
    print("vert_count=" .. mesh:getVertexCount())
    local v = mesh:getVertex(1)
    print("v1=" .. tostring(v ~= nil))
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    mesh:setTexture(img)
    mesh:setVertex(1, { 10, 10, 0.1, 0.1, 1, 0.5, 0.5, 1 })
    print("type=" .. mesh:type())
    print("typeOf=" .. tostring(mesh:typeOf("LMesh")))
    mesh:release()
end

--@api-stub: LQuad:getViewport
-- Quad viewport query and type introspection.
do
    local q = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = q:getViewport()
    print("vp=" .. x .. "," .. y .. "," .. w .. "," .. h)
    print("type=" .. q:type())
end

--@api-stub: LShader:hasUniform
--@api-stub: LShader:type
--@api-stub: LShader:typeOf
-- Shader uniform queries, send, and type introspection.
do
    local code = [[
        uniform float time;
        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 fragCoord) {
            return Texel(tex, uv) * color;
        }
    ]]
    local sh = lurek.render.newShader(code)
    print("has_time=" .. tostring(sh:hasUniform("time")))
    sh:send("time", 0.5)
    print("type=" .. sh:type())
    print("typeOf=" .. tostring(sh:typeOf("LShader")))
    sh:release()
end

--@api-stub: LSpriteBatch:add
--@api-stub: LSpriteBatch:clear
--@api-stub: LSpriteBatch:getBufferSize
--@api-stub: LSpriteBatch:getCount
-- Sprite batch operations and type introspection.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    local sb = lurek.render.newSpriteBatch(img, 100)
    local id = sb:add(0, 0, 0, 1, 1, 0, 0)
    sb:add(100, 0, 0, 1, 1, 0, 0)
    print("count=" .. sb:getCount())
    print("buf=" .. sb:getBufferSize())
    sb:clear()
    print("count_after=" .. sb:getCount())
    print("type=" .. sb:type())
    print("typeOf=" .. tostring(sb:typeOf("LSpriteBatch")))
    sb:release()
end

--- Render Module Part 6: module-level functions (clear, color, blend, canvas, shader, transforms, font, wireframe, dims, scissor, line/point)

--@api-stub: lurek.render.getBackgroundColor
-- Get current background color.
do
    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b = lurek.render.getBackgroundColor()
    print("bg=" .. r .. "," .. g .. "," .. b)
end

--@api-stub: lurek.render.getBlendMode
-- Get and set blend mode.
do
    lurek.render.setBlendMode("alpha")
    local mode = lurek.render.getBlendMode()
    print("blend=" .. mode)
end

--@api-stub: lurek.render.getColor
-- Get and set draw color.
do
    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    print("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.render.getHeight
--@api-stub: lurek.render.getWidth
-- Screen dimension queries.
do
    local w, h = lurek.render.getDimensions()
    print("dims=" .. w .. "x" .. h)
    print("w=" .. lurek.render.getWidth())
    print("h=" .. lurek.render.getHeight())
end

--@api-stub: lurek.render.getFont
-- Get and set draw font.
do
    local f = lurek.render.newFont("assets/fonts/Roboto-Regular.ttf", 14)
    lurek.render.setFont(f)
    local cur = lurek.render.getFont()
    print("font=" .. tostring(cur ~= nil))
end

--@api-stub: lurek.render.getScissor
-- Get and set scissor rect.
do
    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    print("scissor=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor(0, 0, 0, 0)
end

--@api-stub: lurek.render.getShader
--@api-stub: lurek.render.setShader
-- Get and set active shader.
do
    local code = "vec4 effect(vec4 c, Image t, vec2 uv, vec2 fc) { return Texel(t, uv) * c; }"
    local sh = lurek.render.newShader(code)
    lurek.render.setShader(sh)
    local cur = lurek.render.getShader()
    print("shader=" .. tostring(cur ~= nil))
    lurek.render.setShader(nil)
end

--@api-stub: lurek.render.isWireframe
-- Get and set wireframe mode.
do
    lurek.render.setWireframe(true)
    print("wireframe=" .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(false)
end

--@api-stub: lurek.render.pop
--@api-stub: lurek.render.rotate
--@api-stub: lurek.render.scale
--@api-stub: lurek.render.translate
-- Transform stack operations.
do
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.scale(2, 2)
    lurek.render.shear(0.1, 0.0)
    lurek.render.draw(lurek.render.newImage("assets/textures/ray_water.png"), 0, 0)
    lurek.render.pop()
    print("transform stack ok")
end

--@api-stub: LImageData:getWidth
--@api-stub: LImageData:getHeight
--@api-stub: LImageData:getRegion
-- LImageData dimensions and region extraction.
do
    local img = lurek.image.newImageData(64, 32)
    local w = img:getWidth()
    local h = img:getHeight()
    local region = img:getRegion(0, 0, 16, 16)
    print("image size:", w, h, "region:", region:getWidth(), region:getHeight())
end

--@api-stub: LImageData:blit
--@api-stub: LImageData:diff
--@api-stub: LImageData:resize
-- LImageData blit, diff and resize operations.
do
    local src = lurek.image.newImageData(32, 32)
    local dst = lurek.image.newImageData(64, 64)
    dst:blit(src, 0, 0)
    local d = dst:diff(src)
    local resized = src:resize(16, 16, "nearest")
    print("blit ok, diff ok, resized:", resized:getWidth())
end

--@api-stub: LImageData:mapPixels
--@api-stub: LImageData:type
--@api-stub: LImageData:typeOf
-- LImageData pixel mapping and type introspection.
do
    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y, r, g, b, a)
        return r, g, b, a
    end)
    local t = img:type()
    local ok = img:typeOf("LImageData")
    print("map done, type:", t)
end

--@api-stub: LImage:getDimensions
--@api-stub: LImage:getWidth
--@api-stub: LImage:getHeight
-- LImage size introspection.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    if img then
        local w, h = img:getDimensions()
        local w2 = img:getWidth()
        local h2 = img:getHeight()
        print("image dims:", w, h)
    end
    print("LImage size API tested")
end

--@api-stub: LNineSlice:getInsets
--@api-stub: LNineSlice:getTextureSize
--@api-stub: LNineSlice:type
-- LNineSlice insets, texture size, and type.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    if img then
        local ns = lurek.render.newNineSlice(img, 4, 4, 4, 4)
        local t, r, b, l = ns:getInsets()
        local tw, th = ns:getTextureSize()
        local tp = ns:type()
        print("nineslice insets:", t, r, b, l, "type:", tp)
    end
    print("LNineSlice tested")
end

--@api-stub: LNineSlice:typeOf
--@api-stub: LObjModel:getFaceCount
--@api-stub: LObjModel:getNormalCount
-- LNineSlice typeOf and LObjModel face/normal counts.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    if img then
        local ns = lurek.render.newNineSlice(img, 2, 2, 2, 2)
        local ok = ns:typeOf("LNineSlice")
        print("NineSlice typeOf:", ok)
    end
    local model = lurek.render.loadModel("assets/models/test.obj")
    if model then
        local fc = model:getFaceCount()
        local nc = model:getNormalCount()
        print("model faces:", fc, "normals:", nc)
    end
    print("NineSlice typeOf + LObjModel tested")
end

--@api-stub: LObjModel:getUvCount
--@api-stub: LObjModel:getVertexCount
--@api-stub: LQuad:getTextureDimensions
-- LObjModel UV/vertex counts and LQuad texture dimensions.
do
    local model = lurek.render.loadModel("assets/models/test.obj")
    if model then
        local uv = model:getUvCount()
        local vc = model:getVertexCount()
        print("model uvs:", uv, "verts:", vc)
    end
    local q = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local tw, th = q:getTextureDimensions()
    print("quad tex dims:", tw, th, "LObjModel + LQuad tested")
end

--@api-stub: LQuad:setViewport
-- LQuad setViewport.
do
    local q = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    q:setViewport(0, 0, 32, 32)
    local x, y, w, h = q:getViewport()
    print("quad viewport:", x, y, w, h)
end

--@api-stub: LShape:arc
--@api-stub: LShape:circle
--@api-stub: LShape:setColor
-- LShape: arc, circle, and color.
do
    local s = lurek.render.newShape()
    s:setColor(1, 0.5, 0, 1)
    s:arc("fill", 100, 100, 40, 0, math.pi)
    s:circle("line", 200, 200, 30)
    local c = s:getCommandCount()
    print("shape cmds:", c)
end

--@api-stub: LShape:ellipse
--@api-stub: LShape:line
--@api-stub: LShape:rectangle
-- LShape: ellipse, line, rectangle drawing.
do
    local s = lurek.render.newShape()
    s:ellipse("fill", 100, 100, 50, 30)
    s:line(10, 10, 90, 90)
    s:rectangle("fill", 20, 20, 60, 40)
    local c = s:getCommandCount()
    print("shape ellipse+line+rect cmds:", c)
end

--@api-stub: LShape:triangle
--@api-stub: LShape:draw
--@api-stub: LShape:setLineWidth
-- LShape: triangle, draw and line width.
do
    local s = lurek.render.newShape()
    s:setLineWidth(2)
    s:triangle("line", 0, 0, 50, 0, 25, 50)
    s:draw(100, 100, 0, 1, 1, 0, 0)
    local c = s:getCommandCount()
    print("shape triangle+draw cmds:", c)
end

--@api-stub: LShape:getCommandCount
-- LShape: getCommandCount after clear.
do
    local s = lurek.render.newShape()
    s:circle("fill", 0, 0, 10)
    s:circle("fill", 50, 50, 10)
    local before = s:getCommandCount()
    s:clear()
    local after = s:getCommandCount()
    print("getCommandCount before:", before, "after clear:", after)
end

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

print("content/examples/render.lua")
