
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua


--- Render Module Part 1: basic drawing - print, rectangle, circle, line, polygon, points, arc, ellipse, triangle


--@api: lurek.render.print
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.print("Hello from lurek.render.print", 10, 10)
    lurek.log.info("print font type = " .. font:type())
    lurek.log.info("printed plain text")
end

--@api: LSpriteBatch:addComposite
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local parts = { { x = 0, y = 0, quadX = 0, quadY = 0, quadW = 8, quadH = 8 }, { x = 8, y = 0, quadX = 0, quadY = 0, quadW = 8, quadH = 8 } }
    local count = batch:addComposite(parts)
    lurek.log.info("composite parts added=" .. tostring(count) .. " total=" .. tostring(batch:getCount()))
end

--@api: lurek.render.printf
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printf("Centered text inside a 220 px box.", 10, 40, 220, "center")
    lurek.log.info("printf limit = 220")
    lurek.log.info("printf align = center")
end

--@api: lurek.render.printRotated
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.printRotated("Rotated text", 180, 90, math.pi / 6, 1.0)
    lurek.log.info("printRotated angle = " .. tostring(math.pi / 6))
    lurek.log.info("rotated text drawn")
end

--@api: lurek.render.drawText
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setFont(font)
    lurek.render.setColor(0.65, 0.9, 1.0, 0.9)
    lurek.render.drawText("GPU transformed text", 260, 92, -0.2, 1.4, 1.1, 20, 8)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("drawText rotation = -0.2")
    lurek.log.info("drawText uses tint from setColor")
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
    lurek.log.info("rich spans = " .. #spans)
    lurek.log.info("rich text uses u8 colors")
end

--@api: lurek.render.rectangle
do

    lurek.render.setColor(1, 0.2, 0.2, 1)
    lurek.render.rectangle("fill", 40, 150, 100, 60)
    lurek.render.rectangle("line", 160, 150, 100, 60, 8)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("rectangle fill and rounded line drawn")
    lurek.log.info("rectangle width = 100")
end

--@api: lurek.render.circle
do

    lurek.render.setColor(1, 0.6, 0.1, 1)
    lurek.render.circle("fill", 340, 180, 30)
    lurek.render.setColor(0.2, 0.9, 1, 1)
    lurek.render.circle("line", 410, 180, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("circle radius = 30")
    lurek.log.info("circle fill and line drawn")
end

--@api: lurek.render.ellipse
do

    lurek.render.setColor(0.2, 0.6, 0.9, 1)
    lurek.render.ellipse("fill", 110, 250, 60, 30)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.ellipse("line", 240, 250, 40, 60)
    lurek.log.info("ellipse examples drawn")
    lurek.log.info("ellipse radii = 60x30 and 40x60")
end

--@api: lurek.render.arc
do

    lurek.render.setColor(1, 0.8, 0.1, 1)
    lurek.render.arc("fill", 360, 250, 36, 0, math.pi)
    lurek.render.setColor(0.2, 0.9, 0.4, 1)
    lurek.render.arc("line", 450, 250, 36, math.pi, math.pi * 1.75, 20)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("arc segments = 20 on line arc")
    lurek.log.info("arc examples drawn")
end

--@api: lurek.render.line
do

    lurek.render.setColor(1, 1, 0.2, 1)
    lurek.render.line(10, 320, 160, 320)
    lurek.render.setColor(0.1, 0.9, 1, 1)
    lurek.render.line(10, 340, 40, 360, 70, 340, 100, 360, 130, 340, 160, 360)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("line and polyline drawn")
    lurek.log.info("polyline points = 6")
end

--@api: lurek.render.polygon
do

    lurek.render.setColor(0.8, 0.1, 0.5, 1)
    lurek.render.polygon("fill", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.polygon("line", 210, 300, 260, 280, 310, 300, 290, 350, 230, 350)
    lurek.log.info("polygon vertices = 5")
    lurek.log.info("polygon fill and line drawn")
end

--@api: lurek.render.triangle
do

    lurek.render.setColor(0.1, 0.7, 0.3, 1)
    lurek.render.triangle("fill", 360, 350, 410, 280, 460, 350)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.triangle("line", 480, 350, 530, 280, 580, 350)
    lurek.log.info("triangle fill and line drawn")
    lurek.log.info("triangle count = 2")
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
    lurek.log.info("point size reset to 1")
    lurek.log.info("points drawn with flat and table inputs")
end

--@api: lurek.render.setLineWidth
do

    lurek.render.setLineWidth(4)
    lurek.render.line(200, 390, 280, 390)
    lurek.log.info("line width set to 4")
    lurek.render.setLineWidth(1)
    lurek.log.info("line width restored to 1")
end

--@api: lurek.render.getLineWidth
do

    lurek.render.setLineWidth(3)
    local width = lurek.render.getLineWidth()
    lurek.log.info("line width = " .. tostring(width))
    lurek.render.setLineWidth(1)
    lurek.log.info("line width restored")
end

--@api: lurek.render.setPointSize
do

    lurek.render.setPointSize(6)
    lurek.render.points(320, 390, 340, 390, 360, 390)
    lurek.log.info("point size set to 6")
    lurek.render.setPointSize(1)
    lurek.log.info("point size restored")
end

--@api: lurek.render.getPointSize
do

    lurek.render.setPointSize(7)
    local size = lurek.render.getPointSize()
    lurek.log.info("point size = " .. tostring(size))
    lurek.render.setPointSize(1)
    lurek.log.info("point size restored")
end

--@api: lurek.render.drawCubicBezier
do

    lurek.render.setColor(1, 0.5, 0.1, 1)
    lurek.render.drawCubicBezier(20, 440, 60, 390, 120, 490, 160, 440, 24)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("cubic bezier segments = 24")
    lurek.log.info("cubic bezier drawn")
end

--@api: lurek.render.drawQuadBezier
do

    lurek.render.setColor(0.1, 1, 0.5, 1)
    lurek.render.drawQuadBezier(210, 440, 270, 390, 330, 440, 18)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("quad bezier segments = 18")
    lurek.log.info("quad bezier drawn")
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
    lurek.log.info("path segments = " .. #path)
    lurek.log.info("path closed = true")
end

--@api: lurek.render.drawGradientRect
do

    lurek.render.drawGradientRect(10, 500, 120, 36, { 1, 0, 0, 1 }, { 0, 0, 1, 1 }, "horizontal")
    lurek.render.drawGradientRect(150, 500, 120, 36, { 0, 1, 0, 1 }, { 1, 1, 0, 1 }, "vertical")
    lurek.render.rectangle("line", 10, 500, 120, 36)
    local r, g, b, a = lurek.render.getColor()
    lurek.log.info("gradient cards drawn with active color " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("colored polygon vertices = 4")
    lurek.log.info("colored polygon drawn")
end

--@api: lurek.render.drawHexTile
do

    lurek.render.setColor(0.1, 0.7, 0.5, 1)
    lurek.render.drawHexTile(480, 520, 24, "pointyTop", "fill")
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.drawHexTile(550, 520, 24, "flatTop", "line")
    lurek.log.info("hex tile orientations = pointyTop, flatTop")
    lurek.log.info("hex tiles drawn")
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
    lurek.log.info("bevel styles = raised, sunken, flat")
    lurek.log.info("bevel rectangles drawn")
end


--- Render Module Part 2: color state, transforms, scissor, clear, blend modes, wireframe, layers, depth

--@api: lurek.render.setColor
do

    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    lurek.log.info("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.rectangle("fill", 340, 10, 40, 20)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.log.info("color restored to white")
end

--@api: lurek.render.setBackgroundColor
do

    lurek.render.setBackgroundColor(0.1, 0.1, 0.2)
    local r, g, b, a = lurek.render.getBackgroundColor()
    lurek.log.info("background = " .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
    lurek.log.info("background restored to black")
end

--@api: lurek.render.setColorMask
do

    lurek.render.setColorMask(true, true, false, true)
    local r, g, b, a = lurek.render.getColorMask()
    lurek.log.info("mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
    lurek.log.info("color mask restored")
end

--@api: lurek.render.push
do

    lurek.render.push()
    lurek.render.translate(80, 80)
    lurek.render.rotate(math.pi / 8)
    lurek.render.scale(1.2, 0.8)
    lurek.render.rectangle("line", -20, -20, 40, 40)
    lurek.render.pop()
    lurek.log.info("transform stack push/pop used")
    lurek.log.info("translated, rotated, and scaled rectangle")
end

--@api: lurek.render.shear
do

    lurek.render.push()
    lurek.render.translate(180, 80)
    lurek.render.shear(0.3, 0.0)
    lurek.render.rectangle("fill", 0, 0, 70, 30)
    lurek.render.pop()
    lurek.log.info("shear kx = 0.3")
    lurek.log.info("sheared rectangle drawn")
end

--@api: lurek.render.origin
do

    lurek.render.push()
    lurek.render.translate(999, 999)
    lurek.render.origin()
    lurek.render.rectangle("line", 0, 0, 12, 12)
    lurek.render.pop()
    lurek.log.info("origin reset applied")
    lurek.log.info("origin rectangle drawn at screen origin")
end

--@api: lurek.render.applyTransform
do

    local matrix = { 1, 0, 0, 0, 1, 0, 60, 120, 1 }
    lurek.render.push()
    lurek.render.applyTransform(matrix)
    lurek.render.rectangle("fill", 0, 0, 36, 36)
    lurek.render.pop()
    lurek.log.info("applyTransform matrix entries = " .. #matrix)
    lurek.log.info("flat 3x3 matrix applied")
end

--@api: lurek.render.setScissor
do

    lurek.render.setScissor(20, 140, 120, 60)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("fill", 0, 120, 180, 90)
    lurek.render.intersectScissor(50, 150, 70, 30)
    lurek.render.rectangle("line", 0, 120, 180, 90)
    lurek.render.setScissor()
    lurek.log.info("scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("scissor cleared")
end

--@api: lurek.render.clear
do

    lurek.render.rectangle("fill", 0, 0, 10, 10)
    lurek.render.clear()
    lurek.render.circle("line", 24, 24, 8)
    local mode = lurek.render.getBlendMode()
    lurek.log.info("render queue cleared and resumed in blend mode " .. mode)
end

--@api: lurek.render.setBlendMode
do

    local before = lurek.render.getBlendMode()
    lurek.render.setBlendMode("add")
    lurek.render.rectangle("fill", 180, 140, 40, 40)
    lurek.render.setBlendMode("multiply")
    lurek.render.rectangle("fill", 200, 160, 40, 40)
    lurek.render.setBlendMode("alpha")
    lurek.log.info("blend before = " .. before)
    lurek.log.info("blend restored to alpha")
end

--@api: lurek.render.setWireframe
do

    lurek.log.info("wireframe before = " .. tostring(lurek.render.isWireframe()))
    lurek.render.setWireframe(true)
    lurek.render.rectangle("fill", 260, 140, 50, 50)
    lurek.render.setWireframe(false)
    lurek.log.info("wireframe restored = " .. tostring(lurek.render.isWireframe()))
end

--@api: lurek.render.newLayer
do

    lurek.render.newLayer("background", 0)
    lurek.render.newLayer("foreground", 10)
    lurek.render.setLayer("foreground")
    lurek.log.info("current layer = " .. lurek.render.currentLayer())
    lurek.log.info("foreground z = " .. lurek.render.getLayerZOrder("foreground"))
end

--@api: lurek.render.getLayerZOrder
do

    lurek.render.newLayer("midground", 5)
    lurek.render.setLayer("midground")
    local before = lurek.render.getLayerZOrder("midground")
    lurek.render.setLayerZOrder("midground", 15)
    local after = lurek.render.getLayerZOrder("midground")
    lurek.log.info("midground z changed " .. before .. " -> " .. after)
end

--@api: lurek.render.pushLayer
do

    lurek.render.pushLayer(1, 0.65, "alpha")
    lurek.render.rectangle("fill", 320, 140, 60, 40)
    lurek.render.popLayer(1)
    lurek.log.info("pushLayer id = 1")
    lurek.log.info("popLayer matched id = 1")
end

--@api: lurek.render.beginSortGroup
do

    lurek.render.beginSortGroup(1)
    lurek.render.pushSortKey(10)
    lurek.render.rectangle("fill", 400, 140, 30, 30)
    lurek.render.pushSortKey(5)
    lurek.render.rectangle("fill", 410, 150, 30, 30)
    lurek.render.flushSortGroup(1)
    lurek.log.info("sort group id = 1")
    lurek.log.info("sort keys 10 and 5 queued")
end

--@api: lurek.render.setDepthMode
do

    local mode_before, write_before = lurek.render.getDepthMode()
    lurek.render.setDepthMode("lequal", true)
    local mode_after, write_after = lurek.render.getDepthMode()
    lurek.log.info("depth before = " .. mode_before .. "," .. tostring(write_before))
    lurek.log.info("depth after = " .. mode_after .. "," .. tostring(write_after))
    lurek.render.setDepthMode("always", false)
end

--@api: lurek.render.setDefaultFilter
do

    local min_before, mag_before, aniso_before = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter("nearest", "nearest", 1)
    local min_after, mag_after, aniso_after = lurek.render.getDefaultFilter()
    lurek.log.info("filter before = " .. min_before .. "," .. mag_before .. "," .. aniso_before)
    lurek.log.info("filter after = " .. min_after .. "," .. mag_after .. "," .. aniso_after)
    lurek.render.setDefaultFilter("linear", "linear", 1)
end

--@api: lurek.render.getDimensions
do

    local w, h = lurek.render.getDimensions()
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    lurek.log.info("framebuffer " .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
end

--@api: lurek.render.getStats
do

    local stats = lurek.render.getStats()
    lurek.render.rectangle("fill", 0, 0, 8, 8)
    local draws = tostring(stats.drawcalls)
    local textures = tostring(stats.textures)
    local gpu = tostring(stats.gpu_draw_calls)
    lurek.log.info("stats drawcalls=" .. draws .. " textures=" .. textures .. " gpu=" .. gpu)
end

--@api: lurek.render.getBudgetLimits
do

    local limits = lurek.render.getBudgetLimits()
    local commands = limits.commands
    local indices = limits.geometry_indices
    local uploads = limits.uploads
    local upload_bytes = limits.upload_bytes
    lurek.log.info("render commands=" .. tostring(commands) .. " indices=" .. tostring(indices))
    lurek.log.info("render uploads=" .. tostring(uploads) .. " bytes=" .. tostring(upload_bytes))
end

--@api: lurek.render.getCapabilities
do

    local caps = lurek.render.getCapabilities()
    lurek.log.info("render max texture dimension = " .. tostring(caps.max_texture_dimension_2d))
    lurek.log.info("render max buffer bytes = " .. tostring(caps.max_buffer_size))
    lurek.log.info("timestamp queries = " .. tostring(caps.timestamp_queries))
    lurek.log.info("shader trust mode = " .. caps.shader_trust_mode)
end

--@api: lurek.render.getResourceStats
do

    local resources = lurek.render.getResourceStats()
    lurek.log.info("render retained bytes = " .. tostring(resources.total_bytes))
    lurek.log.info("render evictable bytes = " .. tostring(resources.evictable_bytes))
    lurek.log.info("render live texture count = " .. tostring(resources.texture_count))
    lurek.log.info("render budget bytes = " .. tostring(resources.budget_bytes))
end


--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice

--@api: lurek.render.newImage
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    lurek.render.draw(image, 10, 10)
    lurek.render.draw(image, 90, 10, math.pi / 8, 0.5, 0.5)
    lurek.log.info("image size = " .. w .. "x" .. h)
    lurek.log.info("newImage handle ready")
end

--@api: lurek.render.newTexture
do
    local texture = lurek.render.newTexture("content/examples/assets/images/sample_texture.png", "srgb")
    local width, height = texture:getDimensions()
    lurek.render.draw(texture, 20, 70)
    lurek.log.info("canonical texture size = " .. width .. "x" .. height)
    local texture_id = texture:getId()
    lurek.log.info("canonical texture id = " .. texture_id)
    texture:release()
end

--@api: LImage:getId
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local id = image:getId()
    local w, h = image:getDimensions()
    lurek.log.info("texture id=" .. id .. " size=" .. w .. "x" .. h)
    image:release()
end

--@api: LImage:type
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local type_name = image:type()
    local is_image = image:typeOf("LImage")
    local id = image:getId()
    lurek.log.info(type_name .. " is_image=" .. tostring(is_image) .. " id=" .. id)
    image:release()
end

--@api: LImage:typeOf
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local is_image = image:typeOf("LImage")
    local is_object = image:typeOf("LObject")
    local w = image:getWidth()
    lurek.log.info("image typeOf LImage=" .. tostring(is_image) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
    image:release()
end

--@api: LImage:release
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local before_id = image:getId()
    local before_w = image:getWidth()
    local released = image:release()
    lurek.log.info("image " .. before_id .. " width=" .. before_w .. " released=" .. tostring(released))
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
    lurek.log.info("canvas size = " .. w .. "x" .. h)
    lurek.log.info("canvas rendered and drawn back")
end

--@api: lurek.render.applyShaderToCanvas
do

    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let vignette = smoothstep(0.85, 0.2, distance(uv, vec2<f32>(0.5, 0.5)));
    return vec4<f32>(color.rgb * (0.35 + vignette), color.a);
}
]]
    local shader = lurek.render.newShader(code, { target = "postfx" })
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.applyShaderToCanvas(canvas, shader)
    lurek.render.draw(canvas, 120, 70)
    lurek.log.info("canvas postfx shader target = " .. shader:getTarget())
    lurek.log.info("queued render.applyShaderToCanvas")
end

--@api: lurek.render.applyEffectToCanvas
do

    local source = lurek.render.newCanvas(32, 32)
    local target = lurek.render.newCanvas(64, 64)
    lurek.render.setCanvas(source)
    lurek.render.clear(0.05, 0.05, 0.08, 1.0)
    lurek.render.rectangle("fill", 4, 4, 10, 10)
    lurek.render.circle("fill", 22, 18, 7)
    lurek.render.setCanvas(nil)
    local effect = lurek.effect.newEffect("scale2x")
    local processed = lurek.render.applyEffectToCanvas(source, target, effect)
    lurek.render.draw(processed, 340, 70)
    local w, h = processed:getDimensions()
    lurek.log.info("scale2x canvas output = " .. w .. "x" .. h)
end

--@api: LCanvas:applyShader
do

    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let tint = vec3<f32>(uv.x, 0.4, 1.0 - uv.y);
    return vec4<f32>(mix(color.rgb, tint, 0.35), color.a);
}
]]
    local shader = lurek.render.newShader(code, { target = "postfx" })
    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.circle("fill", 48, 48, 32)
    lurek.render.setCanvas(nil)
    canvas:applyShader(shader)
    lurek.render.draw(canvas, 230, 70)
    lurek.log.info("LCanvas shader target = " .. shader:getTarget())
    lurek.log.info("queued LCanvas:applyShader")
end

--@api: LCanvas:type
do

    local canvas = lurek.render.newCanvas(64, 64)
    local type_name = canvas:type()
    local is_canvas = canvas:typeOf("LCanvas")
    local w, h = canvas:getDimensions()
    lurek.log.info(type_name .. " is_canvas=" .. tostring(is_canvas) .. " size=" .. w .. "x" .. h)
    canvas:release()
end

--@api: LCanvas:typeOf
do

    local canvas = lurek.render.newCanvas(64, 64)
    local is_canvas = canvas:typeOf("LCanvas")
    local is_object = canvas:typeOf("LObject")
    local w = canvas:getWidth()
    lurek.log.info("canvas typeOf LCanvas=" .. tostring(is_canvas) .. " LObject=" .. tostring(is_object) .. " width=" .. w)
    canvas:release()
end

--@api: LCanvas:release
do

    local canvas = lurek.render.newCanvas(64, 64)
    local w, h = canvas:getDimensions()
    local released = canvas:release()
    local pixels = w * h
    lurek.log.info("canvas " .. w .. "x" .. h .. " pixels=" .. pixels .. " released=" .. tostring(released))
end

--@api: lurek.render.getCanvas
do

    local canvas = lurek.render.newCanvas(120, 80)
    lurek.render.setCanvas(canvas)
    local active = lurek.render.getCanvas()
    local w, h = lurek.render.getCanvasSize(canvas)
    lurek.render.setCanvas(nil)
    lurek.render.resetCanvas(canvas)
    lurek.log.info("active canvas exists = " .. tostring(active ~= nil))
    lurek.log.info("canvas size = " .. w .. "x" .. h)
end

--@api: lurek.render.newQuad
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local sw, sh = image:getDimensions()
    local quad = lurek.render.newQuad(0, 0, 16, 16, sw, sh)
    local x, y, w, h = quad:getViewport()
    lurek.render.drawq(image, quad, 10, 170)
    lurek.log.info("quad viewport = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.log.info("quad texture dims = " .. sw .. "x" .. sh)
end

--@api: LQuad:type
do

    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    local type_name = quad:type()
    local is_quad = quad:typeOf("LQuad")
    local x, y, w, h = quad:getViewport()
    lurek.log.info(type_name .. " is_quad=" .. tostring(is_quad) .. " viewport=" .. x .. "," .. y .. "," .. w .. "," .. h)
end

--@api: LQuad:typeOf
do

    local quad = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    local is_quad = quad:typeOf("LQuad")
    local is_object = quad:typeOf("LObject")
    local tex_w, tex_h = quad:getTextureDimensions()
    lurek.log.info("quad typeOf LQuad=" .. tostring(is_quad) .. " LObject=" .. tostring(is_object) .. " tex=" .. tex_w .. "x" .. tex_h)
end

--@api: lurek.render.newSpriteBatch
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 16)
    local last = batch:add(60, 220, 0, 0.5, 0.5, 0, 0)
    batch:add(90, 220, math.pi / 8, 0.5, 0.5, 0, 0)
    lurek.render.draw(batch, 0, 0)
    lurek.log.info("sprite batch count = " .. batch:getCount())
    lurek.log.info("last sprite index = " .. tostring(last))
end

--@api: lurek.render.drawBatch
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:add(120, 220, 0, 0.5, 0.5, 0, 0)
    lurek.render.drawBatch(batch)
    lurek.log.info("drawBatch sprite count = " .. batch:getCount())
    lurek.log.info("drawBatch issued")
end

--@api: LSpriteBatch:type
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    lurek.log.info("batch type = " .. batch:type())
    lurek.log.info("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--@api: LSpriteBatch:typeOf
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    lurek.log.info("batch typeOf LSpriteBatch = " .. tostring(batch:typeOf("LSpriteBatch")))
    lurek.log.info("batch capacity = 8")
    batch:release()
end

--@api: LSpriteBatch:release
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local released = batch:release()
    lurek.log.info("batch released = " .. tostring(released))
    lurek.log.info("batch release tested")
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
    lurek.log.info("drawMany entries = " .. #list)
    lurek.log.info("drawMany issued")
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
    lurek.log.info("queued callbacks = " .. layer:getCount())
    layer:flush()
    lurek.log.info("queued callbacks after flush = " .. layer:getCount())
end

--@api: LDrawLayer:clear
do

    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() end)
    layer:queue(2, function() end)
    layer:clear()
    lurek.log.info("draw layer count after clear = " .. layer:getCount())
    lurek.log.info("draw layer type = " .. layer:type())
end

--@api: LDrawLayer:type
do

    local layer = lurek.render.newDrawLayer()
    layer:queue(1, function() lurek.render.rectangle("fill", 0, 0, 4, 4) end)
    local type_name = layer:type()
    local is_layer = layer:typeOf("LDrawLayer")
    lurek.log.info(type_name .. " is_layer=" .. tostring(is_layer) .. " queued=" .. layer:getCount())
end

--@api: LDrawLayer:typeOf
do

    local layer = lurek.render.newDrawLayer()
    layer:queue(2, function() lurek.render.circle("fill", 4, 4, 2) end)
    local is_layer = layer:typeOf("LDrawLayer")
    local is_object = layer:typeOf("LObject")
    lurek.log.info("draw layer typeOf LDrawLayer=" .. tostring(is_layer) .. " LObject=" .. tostring(is_object) .. " queued=" .. layer:getCount())
end

--@api: lurek.render.drawIsoCubeTile
do

    lurek.render.drawIsoCubeTile(300, 330, 28, 14, {
        depth = 18,
        topColor = { 0.8, 0.8, 0.9, 1 },
        leftColor = { 0.5, 0.5, 0.6, 1 },
        rightColor = { 0.3, 0.3, 0.4, 1 },
    })
    lurek.log.info("iso cube tile depth = 18")
    lurek.log.info("iso cube tile drawn")
end


--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api: lurek.render.newShader
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.25)
    local type_name = shader:type()
    lurek.log.info("compiled shader type=" .. type_name .. " has_u_time=" .. tostring(shader:hasUniform("u_time")))
end

--@api: LShader:send
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.log.info("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 1.5)
    lurek.log.info("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
end

--@api: LShader:getId
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local id = shader:getId()
    lurek.log.info("shader id = " .. tostring(id))
    lurek.log.info("shader id numeric = " .. tostring(type(id) == "number"))
end

--@api: LShader:getTarget
do

    local code = "@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }"
    local shader = lurek.render.newShader(code, { target = "draw" })
    local target = shader:getTarget()
    local id = shader:getId()
    lurek.log.info("shader target = " .. target .. " id=" .. tostring(id))
end

--@api: LShader:getDiagnostics
do

    local code = "@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }"
    local shader = lurek.render.newShader(code)
    local diagnostics = shader:getDiagnostics()
    local first = diagnostics[1] or ""
    lurek.log.info("shader diagnostics = " .. first)
end

--@api: LShader:release
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    local released = shader:release()
    lurek.log.info("shader released = " .. tostring(released))
    lurek.log.info("shader release tested")
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
    lurek.log.info("mesh vertex count = " .. mesh:getVertexCount())
    lurek.log.info("newMesh created triangles mesh")
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
    lurek.log.info("mesh v1 = " .. x .. "," .. y .. "," .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.log.info("setVertex applied to index 1")
end

--@api: LMesh:getVertex
do

    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
    local x, y, u, v, r, g, b, a = mesh:getVertex(2)
    lurek.log.info("mesh v2 = " .. x .. "," .. y .. "," .. u .. "," .. v)
    lurek.log.info("mesh v2 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("mesh texture set from image")
    lurek.log.info("mesh type = " .. mesh:type())
end

--@api: LMesh:release
do

    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    lurek.log.info("mesh released = " .. tostring(mesh:release()))
    lurek.log.info("mesh release tested")
end

--@api: LMesh:type
do

    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    lurek.log.info("mesh type = " .. mesh:type())
    lurek.log.info("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
end

--@api: LMesh:typeOf
do

    local mesh = lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 64, 0, 1, 0, 1, 1, 1, 1 },
        { 64, 64, 1, 1, 1, 1, 1, 1 },
        { 0, 64, 0, 1, 1, 1, 1, 1 },
    }, "fan")
    lurek.log.info("mesh typeOf LMesh = " .. tostring(mesh:typeOf("LMesh")))
    lurek.log.info("mesh bounds ready = " .. tostring(mesh:getVertexCount() > 0))
end

--@api: lurek.render.newShape
do

    local shape = lurek.render.newShape()
    shape:setColor(1, 0, 0, 1)
    shape:rectangle("fill", 0, 0, 40, 24)
    shape:setColor(0, 1, 0, 1)
    shape:circle("line", 60, 12, 12)
    shape:draw(170, 380)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("newShape drew retained commands")
end

--@api: LShape:polygon
do

    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.3, 0, 1)
    shape:polygon("fill", 0, 0, 40, -10, 50, 30, 20, 50, -10, 30)
    shape:draw(250, 380)
    lurek.log.info("shape polygon commands = " .. shape:getCommandCount())
    lurek.log.info("shape polygon drawn")
end

--@api: LShape:polyline
do

    local shape = lurek.render.newShape()
    shape:setLineWidth(3)
    shape:polyline(0, 0, 20, 20, 40, 0, 60, 20)
    shape:draw(330, 380)
    lurek.log.info("shape polyline commands = " .. shape:getCommandCount())
    lurek.log.info("shape polyline drawn")
end

--@api: LShape:roundedRectangle
do

    local shape = lurek.render.newShape()
    shape:setColor(0.5, 0.5, 1, 1)
    shape:roundedRectangle("line", 0, 0, 70, 36, 8)
    shape:draw(410, 380)
    lurek.log.info("shape rounded rectangle commands = " .. shape:getCommandCount())
    lurek.log.info("shape rounded rectangle drawn")
end

--@api: LShape:clear
do

    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    shape:circle("fill", 20, 20, 5)
    lurek.log.info("shape commands before clear = " .. shape:getCommandCount())
    shape:clear()
    lurek.log.info("shape commands after clear = " .. shape:getCommandCount())
end

--@api: LShape:type
do

    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 16, 12)
    local type_name = shape:type()
    local count = shape:getCommandCount()
    lurek.log.info(type_name .. " commands=" .. count .. " is_shape=" .. tostring(shape:typeOf("LShape")))
end

--@api: LShape:typeOf
do

    local shape = lurek.render.newShape()
    shape:line(0, 0, 12, 12)
    local is_shape = shape:typeOf("LShape")
    local is_object = shape:typeOf("LObject")
    lurek.log.info("shape typeOf LShape=" .. tostring(is_shape) .. " LObject=" .. tostring(is_object) .. " commands=" .. shape:getCommandCount())
end

--@api: LShape:setPalette
do
    local shape = lurek.render.newShape()
    local before = shape:getCommandCount()
    shape:setPalette({ primary = { 0.9, 0.2, 0.2, 1 }, outline = { 0.1, 0.1, 0.1 } })
    shape:rectangle("fill", 0, 0, 12, 8)
    local after = shape:getCommandCount()
    lurek.log.info("shape palette commands " .. before .. " -> " .. after)
end

--@api: LShape:setColorRole
do
    local shape = lurek.render.newShape()
    local role = "accent"
    shape:setColorRole(role)
    shape:rectangle("fill", 0, 0, 20, 12)
    local count = shape:getCommandCount()
    lurek.log.info("shape color role " .. role .. " commands = " .. count)
end

--@api: LShape:setStrokeStyle
do
    local shape = lurek.render.newShape()
    local style = { width = 2, cap = "round", join = "bevel", dash = { 4, 2 } }
    shape:setStrokeStyle(style)
    shape:line(0, 0, 24, 12)
    local count = shape:getCommandCount()
    lurek.log.info("shape stroke style commands = " .. count)
end

--@api: LShape:point
do
    local shape = lurek.render.newShape()
    local size = 3
    shape:point(4, 5, size)
    local count = shape:getCommandCount()
    lurek.log.info("shape point size=" .. size)
    lurek.log.info("shape point commands = " .. count)
end

--@api: LShape:points
do
    local shape = lurek.render.newShape()
    local values = { 0, 0, 8, 4, 16, 8, 2 }
    shape:points(unpack(values))
    local count = shape:getCommandCount()
    lurek.log.info("shape points values = " .. #values)
    lurek.log.info("shape points commands = " .. count)
end

--@api: LShape:path
do
    local shape = lurek.render.newShape()
    local segments = { { verb = "moveTo", x = 0, y = 0 }, { verb = "lineTo", x = 24, y = 12 } }
    shape:path(segments, { close = false })
    local count = shape:getCommandCount()
    lurek.log.info("shape path segments = " .. #segments)
    lurek.log.info("shape path commands = " .. count)
end

--@api: LShape:regularPolygon
do
    local shape = lurek.render.newShape()
    local sides = 6
    shape:regularPolygon("fill", 12, 12, 10, sides)
    local count = shape:getCommandCount()
    lurek.log.info("shape regular polygon sides = " .. sides)
    lurek.log.info("shape regular polygon commands = " .. count)
end

--@api: LShape:star
do
    local shape = lurek.render.newShape()
    local points = 5
    shape:star("fill", 12, 12, 10, 4, points)
    local count = shape:getCommandCount()
    lurek.log.info("shape star points = " .. points)
    lurek.log.info("shape star commands = " .. count)
end

--@api: LShape:capsule
do
    local shape = lurek.render.newShape()
    local radius = 4
    shape:capsule("line", 0, 0, 30, 12, radius)
    local count = shape:getCommandCount()
    lurek.log.info("shape capsule radius = " .. radius)
    lurek.log.info("shape capsule commands = " .. count)
end

--@api: LShape:ring
do
    local shape = lurek.render.newShape()
    local segments = 12
    shape:ring("line", 12, 12, 10, 5, segments)
    local count = shape:getCommandCount()
    lurek.log.info("shape ring segments = " .. segments)
    lurek.log.info("shape ring commands = " .. count)
end

--@api: LShape:sector
do
    local shape = lurek.render.newShape()
    local segments = 12
    shape:sector("fill", 12, 12, 10, 0, math.pi, segments)
    local count = shape:getCommandCount()
    lurek.log.info("shape sector segments = " .. segments)
    lurek.log.info("shape sector commands = " .. count)
end

--@api: LShape:arrow
do
    local shape = lurek.render.newShape()
    local width, head = 4, 8
    shape:arrow("fill", 0, 0, 24, 12, width, head)
    local count = shape:getCommandCount()
    lurek.log.info("shape arrow width/head = " .. width .. "/" .. head)
    lurek.log.info("shape arrow commands = " .. count)
end

--@api: LShape:symbol
do
    local shape = lurek.render.newShape()
    local name, size = "diamond", 10
    shape:symbol(name, 12, 12, size, "fill")
    local count = shape:getCommandCount()
    lurek.log.info("shape symbol name/size = " .. name .. "/" .. size)
    lurek.log.info("shape symbol commands = " .. count)
end

--@api: LShape:trail
do
    local shape = lurek.render.newShape()
    local coords, widths = { 0, 0, 12, 4, 24, 0 }, { 2, 3, 1 }
    shape:trail(coords, widths)
    local count = shape:getCommandCount()
    lurek.log.info("shape trail points = " .. (#coords / 2))
    lurek.log.info("shape trail commands = " .. count)
end

--@api: LShape:addShape
do
    local child = lurek.render.newShape()
    child:rectangle("fill", 0, 0, 8, 8)
    local parent = lurek.render.newShape()
    parent:addShape(child, { x = 10, y = 4, rotation = 0.1 })
    lurek.log.info("shape composite commands = " .. parent:getCommandCount())
end

--@api: LShape:compile
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 10, 10)
    local compiled = shape:compile({ tolerance = 0.1 })
    local diagnostics = shape:getDiagnostics()
    lurek.log.info("shape compiled = " .. tostring(compiled))
    lurek.log.info("shape compile revision = " .. diagnostics.revision)
end

--@api: LShape:drawMany
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", 0, 0, 8, 8)
    shape:compile()
    shape:drawMany({ { x = 10, y = 10 }, { x = 24, y = 12, rotation = 0.2 } })
    lurek.log.info("shape instances queued")
end

--@api: LShape:getBounds
do
    local shape = lurek.render.newShape()
    shape:rectangle("fill", -2, -3, 10, 8)
    local bounds = shape:getBounds()
    local area = bounds.w * bounds.h
    lurek.log.info("shape bounds = " .. bounds.w .. "x" .. bounds.h)
    lurek.log.info("shape bounds area = " .. area)
end

--@api: LShape:getDiagnostics
do
    local shape = lurek.render.newShape()
    shape:circle("fill", 5, 5, 3)
    local diagnostics = shape:getDiagnostics()
    local commands = diagnostics.commands
    lurek.log.info("shape diagnostics commands = " .. commands)
    lurek.log.info("shape diagnostics compiled = " .. tostring(diagnostics.compiled))
end

--@api: LShape:release
do
    local shape = lurek.render.newShape()
    local type_name = shape:type()
    local released = shape:release()
    lurek.log.info("shape type before release = " .. type_name)
    lurek.log.info("shape released = " .. tostring(released))
    lurek.log.info("shape release complete")
end

--@api: lurek.render.listBuiltinShapes
do
    local filter = { category = "ui", query = "heart" }
    local shapes = lurek.render.listBuiltinShapes(filter)
    local count = #shapes
    local first = shapes[1] or {}
    local id = first.id or "none"
    lurek.log.info("builtin shape search count=" .. count .. " id=" .. id)
end

--@api: lurek.render.getBuiltinShapeInfo
do
    local id = "ui/heart"
    local info = lurek.render.getBuiltinShapeInfo(id)
    local category = info.category
    lurek.log.info("builtin shape " .. info.id .. " category=" .. category)
    lurek.log.info("builtin shape id queried = " .. id)
end

--@api: lurek.render.loadBuiltinShape
do
    local id = "ui/heart"
    local palette = { primary = { 1, 0.2, 0.2 } }
    local shape = lurek.render.loadBuiltinShape(id, { palette = palette })
    local count = shape:getCommandCount()
    lurek.log.info("builtin shape " .. id .. " commands = " .. count)
end

--@api: lurek.render.loadObj
do

    local model = lurek.render.loadObj("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    lurek.log.info("obj faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
end

--@api: lurek.render.loadVoxel
do

    local function le32(value)
        return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
    end
    local children = "SIZE" .. le32(12) .. le32(0) .. le32(1) .. le32(1) .. le32(1) .. "XYZI" .. le32(8) .. le32(0) .. le32(1) .. string.char(0, 0, 0, 1)
    local path = "save/voxel_example.vox"
    lurek.filesystem.writeBytes(path, "VOX " .. le32(150) .. "MAIN" .. le32(0) .. le32(#children) .. children)
    local model = lurek.render.loadVoxel(path, 0.25)
    local bounds = model:getBounds()
    lurek.log.info("voxel count=" .. model:getVoxelCount() .. " height=" .. bounds.maxY)
end

--@api: LVoxelModel:getVoxelCount
do

    local function le32(value)
        return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
    end
    local children = "SIZE" .. le32(12) .. le32(0) .. le32(1) .. le32(1) .. le32(1) .. "XYZI" .. le32(8) .. le32(0) .. le32(1) .. string.char(0, 0, 0, 1)
    local path = "save/voxel_count_example.vox"
    lurek.filesystem.writeBytes(path, "VOX " .. le32(150) .. "MAIN" .. le32(0) .. le32(#children) .. children)
    local model = lurek.render.loadVoxel(path, 0.5)
    local count = model:getVoxelCount()
    lurek.log.info("source voxels=" .. count)
end

--@api: LVoxelModel:getBounds
do

    local function le32(value)
        return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
    end
    local children = "SIZE" .. le32(12) .. le32(0) .. le32(1) .. le32(2) .. le32(1) .. "XYZI" .. le32(8) .. le32(0) .. le32(1) .. string.char(0, 0, 0, 1)
    local path = "save/voxel_bounds_example.vox"
    lurek.filesystem.writeBytes(path, "VOX " .. le32(150) .. "MAIN" .. le32(0) .. le32(#children) .. children)
    local model = lurek.render.loadVoxel(path, 0.5)
    local bounds = model:getBounds()
    lurek.log.info("voxel bounds y=" .. bounds.minY .. ".." .. bounds.maxY)
end

--@api: LObjModel:projectToMesh
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local camera = { x = 0, y = 0, z = -5, tx = 0, ty = 0, tz = 0, fov = 60 }
    local vertices = model:projectToMesh(camera, 320, 240)
    lurek.log.info("projected vertex rows = " .. #vertices)
    lurek.log.info("projectToMesh camera fov = " .. camera.fov)
end

--@api: LObjModel:renderToImage
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local image = model:renderToImage(64, 64, 0)
    lurek.render.draw(image, 500, 370)
    lurek.log.info("rendered model image = " .. image:getWidth() .. "x" .. image:getHeight())
    lurek.log.info("renderToImage rotation step = 0")
end


--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density

--@api: lurek.render.newFont
do

    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("newFont built-in size 16", 10, 430)
    lurek.log.info("newFont type = " .. font:type())
    lurek.log.info("newFont built from bundled size selector")
end

--@api: lurek.render.getDefaultFont
do

    local font = lurek.render.getDefaultFont(24)
    lurek.render.setFont(font)
    lurek.render.print("Default font size 24", 10, 455)
    lurek.log.info("default font height = " .. font:getHeight())
    lurek.log.info("default font fetched by point size")
end

--@api: lurek.render.setDefaultFont
do

    local regular = lurek.render.setDefaultFont(10, false)
    local bold = lurek.render.setDefaultFont(10, true)
    lurek.render.setFont(regular)
    lurek.log.info("regular height = " .. regular:getHeight())
    lurek.log.info("bold height = " .. bold:getHeight())
end

--@api: LFont:getWidth
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local width = font:getWidth("Inventory")
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    lurek.log.info("font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
end

--@api: LFont:getHeight
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local height = font:getHeight()
    local line_height = font:getLineHeight()
    local sample_width = font:getWidth("HUD")
    lurek.log.info("font height=" .. height .. " line_height=" .. line_height .. " sample_width=" .. sample_width)
end

--@api: LFont:getLineHeight
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local line_height = font:getLineHeight()
    local ascent = font:getAscent()
    local descent = font:getDescent()
    lurek.log.info("font line height=" .. line_height .. " ascent=" .. ascent .. " descent=" .. descent)
end

--@api: LFont:getAscent
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local ascent = font:getAscent()
    local descent = font:getDescent()
    local height = font:getHeight()
    lurek.log.info("font ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
end

--@api: LFont:getDescent
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local descent = font:getDescent()
    local width = font:getWidth("Test")
    local ascent = font:getAscent()
    lurek.log.info("font descent=" .. descent .. " ascent=" .. ascent .. " sample_width=" .. width)
end

--@api: LFont:getWrap
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    local lines, width = font:getWrap("This is a wrapped sentence for the font object.", 120)
    local first = lines[1] or ""
    local line_height = font:getLineHeight()
    lurek.log.info("wrapped lines=" .. #lines .. " width=" .. width .. " line_height=" .. line_height .. " first=" .. first)
end

--@api: LFont:setLineHeight
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 12)
    font:setLineHeight(1.5)
    local line_height = font:getLineHeight()
    local height = font:getHeight()
    lurek.log.info("font line height=" .. line_height .. " height=" .. height)
end

--@api: LFont:release
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 18)
    local width = font:getWidth("HUD")
    local released = font:release()
    local alive_type = font:type()
    lurek.log.info("font type=" .. alive_type .. " width before release=" .. width .. " released=" .. tostring(released))
end

--@api: lurek.render.getFontSizes
do

    local sizes = lurek.render.getFontSizes()
    local first = sizes[1] or -1
    local last = sizes[#sizes] or -1
    local count = #sizes
    lurek.log.info("font sizes=" .. count .. " range=" .. tostring(first) .. "-" .. tostring(last))
end

--@api: lurek.render.getFontWidth
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    local width = lurek.render.getFontWidth(font, "Measure")
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    lurek.log.info("module font width=" .. width .. " height=" .. height .. " line_height=" .. line_height)
end

--@api: lurek.render.getFontAscent
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local ascent = lurek.render.getFontAscent(font)
    local descent = lurek.render.getFontDescent(font)
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("module ascent=" .. ascent .. " descent=" .. descent .. " height=" .. height)
end

--@api: lurek.render.getFontWrap
do

    local font = lurek.render.getDefaultFont(12)
    lurek.render.setFont(font)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    lurek.log.info("module wrapped lines = " .. #lines)
    lurek.log.info("module wrap width = " .. width)
end

--@api: lurek.render.stencil
do

    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 220, 470, 24)
    lurek.render.setStencilTest("equal", 1)
    lurek.render.rectangle("fill", 190, 445, 60, 60)
    lurek.render.setStencilTest()
    lurek.log.info("stencil write value = 1")
    lurek.log.info("stencil test cleared")
end

--@api: lurek.render.setStencilMode
do

    lurek.render.setStencilMode("replace", "always", 2)
    local action, compare, value = lurek.render.getStencilMode()
    lurek.log.info("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
    lurek.log.info("stencil state cleared")
end

--@api: lurek.render.captureScreenshot
do
    local captured = false
    lurek.render.captureScreenshot(function(data)
        captured = data:getWidth() > 0 and data:getHeight() > 0
        lurek.log.info("captureScreenshot size = " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.log.info("captureScreenshot callback invoked=" .. tostring(captured))
end

--@api: lurek.render.setCanvas
do

    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.circle("line", 48, 48, 20)
    lurek.render.setCanvas(nil)
    lurek.log.info("setCanvas switched to off-screen target")
    lurek.log.info("setCanvas restored to screen")
end

--@api: lurek.render.draw
do

    local canvas = lurek.render.newCanvas(96, 96)
    lurek.render.setCanvas(canvas)
    lurek.render.rectangle("fill", 0, 0, 96, 96)
    lurek.render.setCanvas(nil)
    lurek.render.draw(canvas, 280, 430, 0, 0.75, 0.75)
    lurek.log.info("draw used a canvas handle")
    lurek.log.info("draw scale = 0.75")
end

--@api: lurek.render.setFont
do

    local font = lurek.render.newFont(16)
    lurek.render.setFont(font)
    lurek.render.print("setFont switched active font", 10, 500)
    lurek.log.info("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    lurek.log.info("setFont tested with built-in font")
end

--- Render Module Part 5: LCanvas, LFont release/type, LImage release/type, LMesh, LQuad getViewport/type, LShader, LSpriteBatch

--@api: LCanvas:getDimensions
do

    local canvas = lurek.render.newCanvas(128, 64)
    local w, h = canvas:getDimensions()
    lurek.log.info("canvas dimensions = " .. w .. "x" .. h)
    lurek.log.info("canvas type = " .. canvas:type())
    canvas:release()
end

--@api: LCanvas:getHeight
do

    local canvas = lurek.render.newCanvas(128, 64)
    local height = canvas:getHeight()
    local width = canvas:getWidth()
    local dims = width .. "x" .. height
    lurek.log.info("canvas height=" .. height .. " dims=" .. dims)
    canvas:release()
end

--@api: LCanvas:getWidth
do

    local canvas = lurek.render.newCanvas(128, 64)
    local width = canvas:getWidth()
    local is_canvas = canvas:typeOf("LCanvas")
    local height = canvas:getHeight()
    lurek.log.info("canvas width=" .. width .. " height=" .. height .. " is_canvas=" .. tostring(is_canvas))
    canvas:release()
end

--@api: LFont:type
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local type_name = font:type()
    local height = font:getHeight()
    local ascent = font:getAscent()
    lurek.log.info(type_name .. " height=" .. height .. " ascent=" .. ascent)
    font:release()
end

--@api: LFont:typeOf
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    local is_font = font:typeOf("LFont")
    local is_object = font:typeOf("LObject")
    local line_height = font:getLineHeight()
    lurek.log.info("font typeOf LFont=" .. tostring(is_font) .. " LObject=" .. tostring(is_object) .. " line_height=" .. line_height)
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
    lurek.log.info("mesh vertex count = " .. mesh:getVertexCount())
    lurek.log.info("mesh type = " .. mesh:type())
    mesh:release()
end

--@api: LQuad:getViewport
do

    local quad = lurek.render.newQuad(0, 0, 32, 32, 128, 128)
    local x, y, w, h = quad:getViewport()
    local tex_w, tex_h = quad:getTextureDimensions()
    local area = w * h
    lurek.log.info("quad viewport=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h .. " area=" .. area)
end

--@api: LShader:hasUniform
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.log.info("has u_time before send = " .. tostring(shader:hasUniform("u_time")))
    shader:send("u_time", 0.5)
    lurek.log.info("has u_time after send = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api: LShader:type
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    lurek.log.info("shader type = " .. shader:type())
    lurek.log.info("shader has u_time = " .. tostring(shader:hasUniform("u_time")))
    shader:release()
end

--@api: LShader:typeOf
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    shader:send("u_time", 0.5)
    lurek.log.info("shader typeOf LShader = " .. tostring(shader:typeOf("LShader")))
    lurek.log.info("shader source bytes = " .. tostring(#code))
    shader:release()
end

--@api: LSpriteBatch:add
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    local id = batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    lurek.log.info("sprite id = " .. tostring(id))
    lurek.log.info("sprite count = " .. batch:getCount())
    batch:release()
end

--@api: LSpriteBatch:clear
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    batch:clear()
    lurek.log.info("sprite count after clear = " .. batch:getCount())
    lurek.log.info("sprite batch type = " .. batch:type())
    batch:release()
end

--@api: LSpriteBatch:getBufferSize
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    lurek.log.info("sprite batch buffer size = " .. batch:getBufferSize())
    lurek.log.info("sprite batch count = " .. batch:getCount())
    batch:release()
end

--@api: LSpriteBatch:getCount
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 100)
    batch:add(0, 0, 0, 1, 1, 0, 0)
    batch:add(100, 0, 0, 1, 1, 0, 0)
    lurek.log.info("sprite batch count = " .. batch:getCount())
    lurek.log.info("sprite batch typeOf = " .. tostring(batch:typeOf("LSpriteBatch")))
    batch:release()
end

--- Render Module Part 6: module-level functions (clear, color, blend, canvas, shader, transforms, font, wireframe, dims, scissor, line/point)

--@api: lurek.render.getBackgroundColor
do

    lurek.render.setBackgroundColor(0.2, 0.2, 0.3)
    local r, g, b, a = lurek.render.getBackgroundColor()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.log.info("background=" .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setBackgroundColor(0, 0, 0)
end

--@api: lurek.render.getBlendMode
do

    lurek.render.setBlendMode("alpha")
    local mode = lurek.render.getBlendMode()
    lurek.render.rectangle("fill", 0, 0, 4, 4)
    lurek.render.setBlendMode("add")
    lurek.log.info("blend mode=" .. mode)
    lurek.render.setBlendMode("alpha")
end

--@api: lurek.render.getColor
do

    lurek.render.setColor(1, 0, 0, 1)
    local r, g, b, a = lurek.render.getColor()
    lurek.render.rectangle("fill", 6, 6, 8, 8)
    lurek.log.info("color=" .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api: lurek.render.getHeight
do

    local w, h = lurek.render.getDimensions()
    local height = lurek.render.getHeight()
    local width = lurek.render.getWidth()
    local area = width * height
    lurek.log.info("dimensions=" .. w .. "x" .. h .. " height=" .. height .. " width=" .. width .. " area=" .. area)
end

--@api: lurek.render.getWidth
do

    local w, h = lurek.render.getDimensions()
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local area = width * height
    lurek.log.info("dimensions=" .. w .. "x" .. h .. " width=" .. width .. " height=" .. height .. " area=" .. area)
end

--@api: lurek.render.getFont
do

    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 14)
    lurek.render.setFont(font)
    lurek.log.info("active font exists = " .. tostring(lurek.render.getFont() ~= nil))
    lurek.log.info("active font width of test = " .. font:getWidth("test"))
    font:release()
end

--@api: lurek.render.getScissor
do

    lurek.render.setScissor(10, 10, 200, 100)
    local x, y, w, h = lurek.render.getScissor()
    lurek.render.rectangle("line", x, y, w, h)
    lurek.log.info("scissor=" .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api: lurek.render.getShader
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.log.info("getShader returned handle = " .. tostring(lurek.render.getShader() ~= nil))
    lurek.render.setShader(nil)
    shader:release()
end

--@api: lurek.render.setShader
do

    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
    local shader = lurek.render.newShader(code)
    lurek.render.setShader(shader)
    lurek.render.rectangle("fill", 10, 540, 24, 16)
    lurek.log.info("setShader activated custom shader")
    lurek.render.setShader(nil)
    lurek.log.info("shader restored to default")
    shader:release()
end

--@api: lurek.render.isWireframe
do

    lurek.render.setWireframe(true)
    local enabled = lurek.render.isWireframe()
    lurek.render.rectangle("line", 0, 0, 10, 10)
    lurek.log.info("wireframe enabled = " .. tostring(enabled))
    lurek.render.setWireframe(false)
    lurek.log.info("wireframe enabled after reset = " .. tostring(lurek.render.isWireframe()))
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
    lurek.log.info("transform stack pop completed")
end

--@api: lurek.render.rotate
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.rotate(math.pi / 4)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    lurek.log.info("rotation angle = " .. tostring(math.pi / 4))
end

--@api: lurek.render.scale
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.scale(2, 2)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    lurek.log.info("scale = 2x2")
end

--@api: lurek.render.translate
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    lurek.render.push()
    lurek.render.translate(50, 50)
    lurek.render.draw(image, 0, 0)
    lurek.render.pop()
    lurek.log.info("translation = 50,50")
end

--@api: LImage:getDimensions
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local w, h = image:getDimensions()
    lurek.log.info("image dimensions = " .. w .. "x" .. h)
    lurek.log.info("image type = " .. image:type())
    image:release()
end

--@api: LImage:getWidth
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local width = image:getWidth()
    local height = image:getHeight()
    local id = image:getId()
    lurek.log.info("image width=" .. width .. " height=" .. height .. " id=" .. id)
    image:release()
end

--@api: LImage:getHeight
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local height = image:getHeight()
    local width = image:getWidth()
    local id = image:getId()
    lurek.log.info("image height=" .. height .. " width=" .. width .. " id=" .. id)
    image:release()
end

--@api: LNineSlice:getInsets
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    lurek.log.info("nine-slice insets = " .. top .. "," .. right .. "," .. bottom .. "," .. left)
    lurek.log.info("nine-slice type = " .. slice:type())
    image:release()
end

--@api: LNineSlice:getTextureSize
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    local w, h = slice:getTextureSize()
    lurek.log.info("nine-slice texture size = " .. w .. "x" .. h)
    lurek.log.info("nine-slice typeOf = " .. tostring(slice:typeOf("LNineSlice")))
    image:release()
end

--@api: LNineSlice:type
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    lurek.log.info("nine-slice type = " .. slice:type())
    lurek.log.info("nine-slice texture width = " .. select(1, slice:getTextureSize()))
    image:release()
end

--@api: LNineSlice:typeOf
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 2, 2, 2, 2)
    lurek.log.info("nine-slice typeOf LNineSlice = " .. tostring(slice:typeOf("LNineSlice")))
    lurek.log.info("nine-slice width sample = 140")
    image:release()
end

--@api: LObjModel:getFaceCount
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local verts = model:getVertexCount()
    local normals = model:getNormalCount()
    lurek.log.info("model faces=" .. faces .. " verts=" .. verts .. " normals=" .. normals)
end

--@api: LObjModel:getNormalCount
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local normals = model:getNormalCount()
    local faces = model:getFaceCount()
    local uvs = model:getUvCount()
    lurek.log.info("model normals=" .. normals .. " faces=" .. faces .. " uvs=" .. uvs)
end

--@api: LObjModel:getUvCount
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local uvs = model:getUvCount()
    local verts = model:getVertexCount()
    local faces = model:getFaceCount()
    lurek.log.info("model uvs=" .. uvs .. " verts=" .. verts .. " faces=" .. faces)
end

--@api: LObjModel:getVertexCount
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local verts = model:getVertexCount()
    local uvs = model:getUvCount()
    local normals = model:getNormalCount()
    lurek.log.info("model verts=" .. verts .. " uvs=" .. uvs .. " normals=" .. normals)
end

--@api: LQuad:getTextureDimensions
do

    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    local w, h = quad:getTextureDimensions()
    local vx, vy, vw, vh = quad:getViewport()
    local area = vw * vh
    lurek.log.info("quad texture=" .. w .. "x" .. h .. " viewport=" .. vx .. "," .. vy .. "," .. vw .. "," .. vh .. " area=" .. area)
end

--@api: LQuad:setViewport
do

    local quad = lurek.render.newQuad(0, 0, 16, 16, 128, 128)
    quad:setViewport(0, 0, 32, 32)
    local x, y, w, h = quad:getViewport()
    local tex_w, tex_h = quad:getTextureDimensions()
    lurek.log.info("quad viewport after set=" .. x .. "," .. y .. "," .. w .. "," .. h .. " tex=" .. tex_w .. "x" .. tex_h)
end

--@api: LShape:arc
do

    local shape = lurek.render.newShape()
    shape:setColor(1, 0.5, 0, 1)
    shape:arc("fill", 100, 100, 40, 0, math.pi)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape arc added")
end

--@api: LShape:circle
do

    local shape = lurek.render.newShape()
    shape:setColor(0.2, 0.8, 0.4, 1)
    shape:circle("line", 80, 80, 24)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape circle added")
end

--@api: LShape:setColor
do

    local shape = lurek.render.newShape()
    shape:setColor(0.8, 0.2, 0.8, 1)
    shape:rectangle("fill", 0, 0, 20, 20)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape color set before rectangle")
end

--@api: LShape:ellipse
do

    local shape = lurek.render.newShape()
    shape:ellipse("fill", 100, 100, 50, 30)
    shape:setColor(0.4, 0.8, 1.0, 1.0)
    local count = shape:getCommandCount()
    lurek.log.info("shape ellipse commands=" .. count)
end

--@api: LShape:line
do

    local shape = lurek.render.newShape()
    shape:line(10, 10, 90, 90)
    shape:setLineWidth(3)
    local count = shape:getCommandCount()
    lurek.log.info("shape line commands=" .. count)
end

--@api: LShape:rectangle
do

    local shape = lurek.render.newShape()
    shape:rectangle("fill", 20, 20, 60, 40)
    shape:setColor(0.9, 0.4, 0.2, 1.0)
    local count = shape:getCommandCount()
    lurek.log.info("shape rectangle commands=" .. count)
end

--@api: LShape:triangle
do

    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape triangle added")
end

--@api: LShape:draw
do

    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    shape:draw(100, 100, 0, 1, 1, 0, 0)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape draw called")
end

--@api: LShape:setLineWidth
do

    local shape = lurek.render.newShape()
    shape:setLineWidth(2)
    shape:triangle("line", 0, 0, 50, 0, 25, 50)
    lurek.log.info("shape command count = " .. shape:getCommandCount())
    lurek.log.info("shape line width set to 2")
end

--@api: LShape:getCommandCount
do

    local shape = lurek.render.newShape()
    shape:circle("fill", 0, 0, 10)
    shape:circle("fill", 50, 50, 10)
    local before = shape:getCommandCount()
    shape:clear()
    local after = shape:getCommandCount()
    lurek.log.info("shape commands before clear = " .. before)
    lurek.log.info("shape commands after clear = " .. after)
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
    lurek.log.info("draw layer count before flush = " .. layer:getCount())
    layer:flush()
    lurek.log.info("draw layer count after flush = " .. layer:getCount())
end

--@api: LDrawLayer:getCount
do

    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    lurek.log.info("draw layer count = " .. layer:getCount())
    layer:clear()
end

--@api: LDrawLayer:queue
do

    local layer = lurek.render.newDrawLayer()
    layer:queue(1.0, function() end)
    layer:queue(2.0, function() end)
    lurek.log.info("draw layer count after queue = " .. layer:getCount())
    layer:clear()
end

--@api: lurek.render.drawq
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local quad = lurek.render.newQuad(0, 0, 16, 16, 64, 64)
    lurek.render.draw(image, 10, 10, 0, 1, 1)
    lurek.render.drawq(image, quad, 50, 50, 0, 1, 1)
    lurek.log.info("drawq used a 16x16 quad")
    image:release()
end

--@api: lurek.render.drawNineSlice
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    lurek.render.drawNineSlice(slice, 100, 100, 80, 60)
    lurek.log.info("drawNineSlice target size = 80x60")
    image:release()
end

--@api: lurek.render.clearStencil
do

    lurek.render.setStencilMode("replace", "always", 2)
    lurek.render.clearStencil()
    local action, compare, value = lurek.render.getStencilMode()
    lurek.render.rectangle("line", 0, 0, 8, 8)
    lurek.log.info("stencil mode after clear = " .. action .. "," .. compare .. "," .. value)
end

--@api: lurek.render.currentLayer
do

    lurek.render.newLayer("current_layer_stub", 12)
    lurek.render.setLayer("current_layer_stub")
    local current = lurek.render.currentLayer()
    local z = lurek.render.getLayerZOrder("current_layer_stub")
    lurek.log.info("current layer = " .. current .. " z=" .. z)
    lurek.render.setLayer("default")
end

--@api: lurek.render.flushSortGroup
do

    lurek.render.beginSortGroup(7)
    lurek.render.pushSortKey(5)
    lurek.render.circle("fill", 100, 100, 10)
    lurek.render.flushSortGroup(7)
    lurek.log.info("flushSortGroup id = 7")
end

--@api: lurek.render.pushSortKey
do

    lurek.render.beginSortGroup(8)
    lurek.render.pushSortKey(3)
    lurek.render.circle("fill", 120, 100, 10)
    lurek.render.flushSortGroup(8)
    lurek.log.info("pushSortKey depth = 3")
end

--@api: lurek.render.popLayer
do

    lurek.render.pushLayer(99, 1.0, "alpha")
    lurek.render.circle("fill", 140, 100, 10)
    lurek.render.popLayer(99)
    local mode = lurek.render.getBlendMode()
    lurek.log.info("popLayer id=99 blend=" .. mode)
end

--@api: lurek.render.getCanvasSize
do

    local canvas = lurek.render.newCanvas(200, 100)
    local w, h = lurek.render.getCanvasSize(canvas)
    lurek.log.info("canvas size = " .. w .. "x" .. h)
    lurek.log.info("color mask red enabled = " .. tostring(select(1, lurek.render.getColorMask())))
    canvas:release()
end

--@api: lurek.render.getColorMask
do

    lurek.render.setColorMask(true, false, true, true)
    local r, g, b, a = lurek.render.getColorMask()
    lurek.render.rectangle("fill", 0, 0, 6, 6)
    lurek.log.info("color mask = " .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(a))
    lurek.render.setColorMask()
end

--@api: lurek.render.getDefaultFilter
do

    local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
    lurek.render.setDefaultFilter(min_filter, mag_filter, aniso)
    local min_again, mag_again, aniso_again = lurek.render.getDefaultFilter()
    local summary = min_again .. "/" .. mag_again
    lurek.log.info("default filter = " .. summary .. "," .. aniso_again)
end

--@api: lurek.render.getDepthMode
do

    local mode, write = lurek.render.getDepthMode()
    lurek.render.setDepthMode(mode, write)
    local confirm_mode, confirm_write = lurek.render.getDepthMode()
    local width = lurek.render.getWidth()
    lurek.log.info("depth mode = " .. confirm_mode .. " write=" .. tostring(confirm_write) .. " width=" .. width)
end

--@api: lurek.render.getFontCellWidth
do

    local font = lurek.render.getDefaultFont(14)
    local cell_width = lurek.render.getFontCellWidth(font)
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    lurek.log.info("font cell width = " .. cell_width .. " descent=" .. descent .. " ascent=" .. ascent)
end

--@api: lurek.render.getFontDescent
do

    local font = lurek.render.getDefaultFont(14)
    local descent = lurek.render.getFontDescent(font)
    local ascent = lurek.render.getFontAscent(font)
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("font descent = " .. descent .. " ascent=" .. ascent .. " height=" .. height)
end

--@api: lurek.render.getFontHeight
do

    local font = lurek.render.getDefaultFont(14)
    local height = lurek.render.getFontHeight(font)
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    lurek.log.info("font height = " .. height .. " line_height=" .. line_height .. " cell_width=" .. cell_width)
end

--@api: lurek.render.getFontLineHeight
do

    local font = lurek.render.getDefaultFont(14)
    local line_height = lurek.render.getFontLineHeight(font)
    local line_width = lurek.render.getLineWidth()
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("font line height = " .. line_height .. " line_width=" .. line_width .. " height=" .. height)
end

--@api: lurek.render.getStencilMode
do

    lurek.render.setStencilMode("replace", "always", 4)
    local action, compare, value = lurek.render.getStencilMode()
    lurek.render.circle("line", 8, 8, 4)
    lurek.log.info("stencil mode = " .. action .. "," .. compare .. "," .. value)
    lurek.render.clearStencil()
end

--@api: lurek.render.isLayerVisible
do

    lurek.render.newLayer("visibility_stub", 2)
    lurek.render.setLayerVisible("visibility_stub", true)
    lurek.log.info("layer visible = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
    lurek.render.setLayerVisible("visibility_stub", false)
    lurek.log.info("layer visible after hide = " .. tostring(lurek.render.isLayerVisible("visibility_stub")))
end

--@api: lurek.render.loadModel
do

    local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
    local faces = model:getFaceCount()
    local normals = model:getNormalCount()
    local verts = model:getVertexCount()
    lurek.log.info("loadModel faces=" .. faces .. " normals=" .. normals .. " verts=" .. verts)
end

--@api: lurek.render.intersectScissor
do

    lurek.render.setScissor(0, 0, 800, 600)
    lurek.render.intersectScissor(100, 100, 400, 300)
    local x, y, w, h = lurek.render.getScissor()
    lurek.log.info("intersected scissor = " .. x .. "," .. y .. "," .. w .. "," .. h)
    lurek.render.setScissor()
end

--@api: lurek.render.resetCanvas
do

    local canvas = lurek.render.newCanvas(64, 64)
    lurek.render.resetCanvas(canvas)
    local w, h = canvas:getDimensions()
    lurek.log.info("resetCanvas called on " .. w .. "x" .. h .. " canvas")
    canvas:release()
end

--@api: lurek.render.setFontLineHeight
do

    local font = lurek.render.getDefaultFont(14)
    lurek.render.setFontLineHeight(font, 1.2)
    local line_height = lurek.render.getFontLineHeight(font)
    local cell_width = lurek.render.getFontCellWidth(font)
    lurek.log.info("setFontLineHeight line_height=" .. line_height .. " cell_width=" .. cell_width)
end

--@api: lurek.render.setLayer
do

    lurek.render.newLayer("set_layer_stub", 1)
    lurek.render.setLayer("set_layer_stub")
    local current = lurek.render.currentLayer()
    local visible = lurek.render.isLayerVisible("set_layer_stub")
    lurek.log.info("current layer = " .. current .. " visible=" .. tostring(visible))
    lurek.render.setLayer("default")
end

--@api: lurek.render.setLayerVisible
do

    lurek.render.newLayer("visible_layer_stub", 1)
    lurek.render.setLayerVisible("visible_layer_stub", false)
    local hidden = lurek.render.isLayerVisible("visible_layer_stub")
    lurek.log.info("layer visible after hide = " .. tostring(hidden))
    lurek.render.setLayerVisible("visible_layer_stub", true)
end

--@api: lurek.render.setLayerZOrder
do

    lurek.render.newLayer("zorder_layer_stub", 1)
    lurek.render.setLayerZOrder("zorder_layer_stub", 9)
    local z = lurek.render.getLayerZOrder("zorder_layer_stub")
    local visible = lurek.render.isLayerVisible("zorder_layer_stub")
    lurek.log.info("layer z order = " .. z .. " visible=" .. tostring(visible))
end

--@api: lurek.render.setStencilTest
do

    lurek.render.setStencilTest("always", 0)
    lurek.render.circle("fill", 100, 100, 30)
    lurek.render.setStencilTest()
    local action, compare, value = lurek.render.getStencilMode()
    lurek.log.info("setStencilTest enabled and cleared with mode " .. action .. "," .. compare .. "," .. value)
end

--@api: lurek.render.setBold
do

    local previous = lurek.render.isBold()
    lurek.render.setBold(true)
    lurek.render.print("Bold text", 10, 10)
    lurek.log.info("bold after set = " .. tostring(lurek.render.isBold()))
    lurek.render.setBold(previous)
    lurek.log.info("bold restored = " .. tostring(lurek.render.isBold()))
end

--@api: lurek.render.isBold
do

    local v = lurek.render.isBold()
    local font_names = lurek.render.getBuiltInFontNames()
    local first = font_names[1] or "none"
    local count = #font_names
    lurek.log.info("isBold = " .. tostring(v) .. " built_in_fonts=" .. count .. " first=" .. first)
end

--@api: lurek.render.printRotatedWithFont
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.printRotatedWithFont(font, "Rotated text", 100, 100, math.pi / 4, 1.0)
    local ascent = lurek.render.getFontAscent(font)
    local width = lurek.render.getFontWidth(font, "Rotated text")
    lurek.log.info("printRotatedWithFont angle=" .. tostring(math.pi / 4) .. " ascent=" .. ascent .. " width=" .. width)
end

--@api: lurek.render.printWithFont
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.printWithFont(font, "Standard text override", 10, 150)
    local width = lurek.render.getFontWidth(font, "Standard text override")
    local height = lurek.render.getFontHeight(font)
    lurek.log.info("printWithFont width=" .. width .. " height=" .. height)
end

--@api: lurek.render.drawTextWithFont
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.setColor(0.8, 1.0, 0.7, 0.9)
    lurek.render.drawTextWithFont(font, "Font handle transform", 220, 152, 0.18, 1.25, 1.0, 16, 6)
    lurek.render.setColor(1, 1, 1, 1)
    local width = lurek.render.getFontWidth(font, "Font handle transform")
    lurek.log.info("drawTextWithFont width=" .. width .. " rotation=0.18")
end

--@api: lurek.render.printfWithFont
do

    local font = lurek.render.getDefaultFont(16)
    lurek.render.printfWithFont(font, "Formatted text inside a 160 px box.", 10, 200, 160, "left")
    local wrap_lines, wrap_width = font:getWrap("Formatted text inside a 160 px box.", 160)
    local first = wrap_lines[1] or ""
    lurek.log.info("printfWithFont limit=160 align=left lines=" .. #wrap_lines .. " width=" .. wrap_width .. " first=" .. first)
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
    lurek.log.info("printRichWithFont spans = " .. #spans)
    lurek.log.info("printRichWithFont uses byte colors")
end

--@api: lurek.render.getBuiltInFontNames
do

    local names = lurek.render.getBuiltInFontNames()
    local first = names[1] or "none"
    local last = names[#names] or "none"
    local count = #names
    lurek.log.info("built-in font names=" .. count .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end
-- content/examples/render.lua
-- Auto-generated from content/examples2/render_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/render.lua

--@api: lurek.render.newDepthSorter
do

    local sorter = lurek.render.newDepthSorter()
    sorter:add(function() lurek.log.info("draw layer A") end, 10)
    sorter:add(function() lurek.log.info("draw layer B") end, 5)
    sorter:flush()
    lurek.log.info("depth sorter type = " .. sorter:type())
end

--@api: lurek.render.setTextShader
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.7, 0.95, 1.2) + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]], { target = "text" })
    lurek.render.setTextShader(shader)
    lurek.render.print("text shader", 24, 48)
    lurek.render.setTextShader(nil)
    lurek.log.info("text shader target=" .. shader:getTarget())
end

--@api: lurek.render.getTextShader
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "text" })
    lurek.render.setTextShader(shader)
    local active = lurek.render.getTextShader()
    lurek.log.info("active text shader=" .. tostring(active and active:getTarget() or "nil"))
    lurek.render.setTextShader(nil)
end

--@api: lurek.render.setDebugShader
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>) -> @location(0) vec4<f32> {
    let heat = vec3<f32>(uv.x, 0.2 + uv.y * 0.5, 1.0 - uv.x);
    return vec4<f32>(mix(color.rgb, heat, 0.6 + pixel.x * 0.0), color.a);
}
]], { target = "debugviz" })
    lurek.render.setDebugShader(shader)
    lurek.render.rectangle("fill", 24, 24, 64, 20)
    lurek.render.circle("line", 56, 56, 18)
    lurek.render.setDebugShader(nil)
    lurek.log.info("debug shader target=" .. shader:getTarget())
end

--@api: lurek.render.getDebugShader
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(3) resolution: vec2<f32>) -> @location(0) vec4<f32> {
    let scale = clamp(resolution.x / max(resolution.x, 1.0), 0.0, 1.0);
    return vec4<f32>(color.rgb * vec3<f32>(1.0, scale, 0.35), color.a);
}
]], { target = "debugviz" })
    lurek.render.setDebugShader(shader)
    local active = lurek.render.getDebugShader()
    lurek.render.line(8, 96, 128, 96)
    lurek.log.info("active debug shader=" .. tostring(active and active:getTarget() or "nil"))
    lurek.render.setDebugShader(nil)
end
--@api: LSpriteBatch:addMany
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    local added = batch:addMany({ { x = 8, y = 8 }, { x = 24, y = 8 } })
    local count = batch:getCount()
    local version = batch:getVersion()
    lurek.log.info("batch added=" .. tostring(added) .. " count=" .. tostring(count))
    lurek.log.info("batch version=" .. tostring(version))
end

--@api: LSpriteBatch:setEntries
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:addMany({ { x = 0, y = 0 }, { x = 16, y = 0 } })
    local changed = batch:setEntries({ { x = 4, y = 4 }, { x = 20, y = 4 } })
    local diagnostics = batch:getDiagnostics()
    lurek.log.info("set entries=" .. tostring(changed))
    lurek.log.info("remaining=" .. tostring(diagnostics.remaining))
end

--@api: LSpriteBatch:updateEntries
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:addMany({ { x = 0, y = 0 }, { x = 16, y = 0 } })
    local changed = batch:updateEntries({ { index = 2, x = 24, y = 8 } })
    local version = batch:getVersion()
    lurek.log.info("updated entries=" .. tostring(changed))
    lurek.log.info("version=" .. tostring(version))
end

--@api: LSpriteBatch:removeEntries
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 8)
    batch:addMany({ { x = 0 }, { x = 16 }, { x = 32 } })
    local removed = batch:removeEntries({ 2 })
    local count = batch:getCount()
    lurek.log.info("removed entries=" .. tostring(removed))
    lurek.log.info("remaining count=" .. tostring(count))
end

--@api: LSpriteBatch:getVersion
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 4)
    local before = batch:getVersion()
    batch:addMany({ { x = 0, y = 0 }, { x = 16, y = 0 } })
    local after = batch:getVersion()
    local advanced = after == before + 1
    lurek.log.info("version advanced once=" .. tostring(advanced))
end

--@api: LSpriteBatch:getDiagnostics
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local batch = lurek.render.newSpriteBatch(image, 4)
    batch:addMany({ { x = 0 }, { x = 16 } })
    local diagnostics = batch:getDiagnostics()
    local used = diagnostics.count
    local free = diagnostics.remaining
    lurek.log.info("batch used=" .. tostring(used))
    lurek.log.info("batch free=" .. tostring(free))
end

--@api: lurek.render.requestReadback
do
    local request = lurek.render.requestReadback()
    local status = request:status()
    local ready = request:isReady()
    local image = request:result()
    lurek.log.info("readback status=" .. status .. " ready=" .. tostring(ready))
    if image ~= nil then
        lurek.log.info("readback width=" .. tostring(image:getWidth()))
    end
    request:release()
end

--@api: lurek.render.prewarmShaders
do
    local code = "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0, 0.0, 1.0, 1.0); }"
    local shader = lurek.render.newShader(code)
    local request = lurek.render.prewarmShaders({ shader })
    local completed, total = request:progress()
    lurek.log.info("queued shader prewarm " .. completed .. "/" .. total)
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:status
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local status = request:status()
    lurek.log.info("shader prewarm status=" .. status)
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:poll
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local status = request:poll()
    lurek.log.info("shader prewarm poll=" .. status)
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:progress
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local completed, total = request:progress()
    lurek.log.info("shader prewarm progress=" .. completed .. "/" .. total)
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:cancel
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local cancelled = request:cancel()
    local status = request:status()
    lurek.log.info("shader prewarm cancelled=" .. tostring(cancelled) .. " status=" .. status)
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:release
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local type_name = request:type()
    local released = request:release()
    lurek.log.info("released " .. type_name .. "=" .. tostring(released))
    shader:release()
end

--@api: LShaderPrewarmRequest:type
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local type_name = request:type()
    local is_object = request:typeOf("LObject")
    lurek.log.info("prewarm type=" .. type_name .. " object=" .. tostring(is_object))
    request:release()
    shader:release()
end

--@api: LShaderPrewarmRequest:typeOf
do
    local shader = lurek.render.newShader("@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }")
    local request = lurek.render.prewarmShaders({ shader })
    local matches = request:typeOf("LShaderPrewarmRequest")
    local type_name = request:type()
    lurek.log.info("prewarm typeOf=" .. tostring(matches) .. " type=" .. type_name)
    request:release()
    shader:release()
end

--@api: LReadbackRequest:status
do
    local request = lurek.render.requestReadback()
    local status = request:status()
    local is_pending = status == "pending"
    lurek.log.info("readback state=" .. status)
    lurek.log.info("readback pending=" .. tostring(is_pending))
    request:release()
end

--@api: LReadbackRequest:poll
do
    local request = lurek.render.requestReadback()
    local status = request:poll()
    local pending = status == "pending"
    local ready = request:isReady()
    request:release()
    lurek.log.info("readback poll=" .. status)
    lurek.log.info("readback pending=" .. tostring(pending) .. " ready=" .. tostring(ready))
end

--@api: LReadbackRequest:isReady
do
    local request = lurek.render.requestReadback()
    local ready = request:isReady()
    local status = request:status()
    lurek.log.info("readback ready=" .. tostring(ready))
    lurek.log.info("readback status=" .. status)
    request:release()
end

--@api: LReadbackRequest:cancel
do
    local request = lurek.render.requestReadback()
    local cancelled = request:cancel()
    local status = request:status()
    lurek.log.info("readback cancelled=" .. tostring(cancelled))
    lurek.log.info("readback status=" .. status)
    request:release()
end

--@api: LReadbackRequest:result
do
    local request = lurek.render.requestReadback()
    local image = request:result()
    local status = request:status()
    lurek.log.info("readback result=" .. tostring(image ~= nil))
    lurek.log.info("readback status=" .. status)
    request:release()
end

--@api: LReadbackRequest:release
do
    local request = lurek.render.requestReadback()
    local type_name = request:type()
    local released = request:release()
    lurek.log.info("readback released=" .. tostring(released))
    lurek.log.info("readback type=" .. type_name)
end

--@api: LReadbackRequest:type
do
    local request = lurek.render.requestReadback()
    local type_name = request:type()
    local is_object = request:typeOf("LObject")
    lurek.log.info("readback type=" .. type_name)
    lurek.log.info("readback object=" .. tostring(is_object))
    request:release()
end

--@api: LReadbackRequest:typeOf
do
    local request = lurek.render.requestReadback()
    local is_request = request:typeOf("LReadbackRequest")
    local type_name = request:type()
    lurek.log.info("is readback request=" .. tostring(is_request))
    lurek.log.info("readback type=" .. type_name)
    request:release()
end

--@api: lurek.render.saveScreenshot
do
    lurek.render.saveScreenshot("save/test_screenshot.png")
    local width = lurek.render.getWidth()
    local height = lurek.render.getHeight()
    local path = "save/test_screenshot.png"
    lurek.log.info("saveScreenshot requested for " .. path .. " from " .. width .. "x" .. height)
end
