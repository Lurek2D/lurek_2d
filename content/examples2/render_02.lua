--- Render Module Part 3: images, canvases, quads, sprite batches, draw, drawq, drawMany, nine-slice

--@api-stub: lurek.render.newImage / draw
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

--@api-stub: LImage:getId / type / typeOf / release
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

--@api-stub: lurek.render.newImage from LImageData
-- Creating an image from pixel data.
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

--@api-stub: lurek.render.newCanvas / setCanvas / getCanvas / draw canvas
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

--@api-stub: LCanvas:type / typeOf / release
-- Canvas type and lifecycle.
do
    ---@type LCanvas
    local canvas = lurek.render.newCanvas(64, 64)
    print("type = " .. canvas:type())
    print("is LCanvas = " .. tostring(canvas:typeOf("LCanvas")))
    local released = canvas:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getCanvas / getCanvasSize / resetCanvas
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

--@api-stub: lurek.render.newQuad / drawq
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

--@api-stub: LQuad:type / typeOf
-- Quad type inspection.
do
    ---@type LQuad
    local q = lurek.render.newQuad(0, 0, 8, 8, 64, 64)
    print("type = " .. q:type())
    print("is LQuad = " .. tostring(q:typeOf("LQuad")))
end

--@api-stub: lurek.render.newSpriteBatch / add / draw batch
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

--@api-stub: LSpriteBatch:type / typeOf / release
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

--@api-stub: lurek.render.newNineSlice / drawNineSlice
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

--@api-stub: lurek.render.newDrawLayer / queue / flush
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

--@api-stub: LDrawLayer:clear / type / typeOf
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

print("render_02.lua")
