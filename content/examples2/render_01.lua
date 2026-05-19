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

print("render_01.lua")
