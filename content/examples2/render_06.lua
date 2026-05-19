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

print("render_06.lua")
