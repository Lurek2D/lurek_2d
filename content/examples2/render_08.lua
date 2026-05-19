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
