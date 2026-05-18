--- Render Module Part 3: shaders, meshes, shapes, OBJ models

--@api-stub: lurek.render.newShader / send / hasUniform
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

--@api-stub: LShader:send / setShader / getShader
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

--@api-stub: lurek.render.newMesh / draw mesh
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

--@api-stub: LMesh:setVertex / getVertex
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

--@api-stub: LMesh:setTexture / release / type / typeOf
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

--@api-stub: lurek.render.newShape / drawing commands
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

--@api-stub: LShape:polygon / polyline / roundedRectangle
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

--@api-stub: LShape:clear / type / typeOf
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

--@api-stub: lurek.render.loadObj / LObjModel methods
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

print("render_03.lua")
