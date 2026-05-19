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

print("render_05.lua")
