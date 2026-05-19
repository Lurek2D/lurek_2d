--- Image Module Part 3: LLayeredImage, LPaletteLUT, LCompressedImageData, LProvinceGrid

--@api-stub: LLayeredImage:addLayer
-- Adds a blank layer with an optional name. Returns one-based index.
do
    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    print("added layer at index " .. idx)
    print("layers = " .. li:layerCount())
end

--@api-stub: LLayeredImage:removeLayer
-- Removes a layer by index.
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("temp")
    li:removeLayer(1)
    print("layers after remove = " .. li:layerCount())
end

--@api-stub: LLayeredImage:getLayer
-- Returns image data for a specific layer.
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("green")
    local data = li:getLayer(1)
    print("layer 1: " .. data:getWidth() .. "x" .. data:getHeight())
end

--@api-stub: LLayeredImage:setLayer
-- Replaces a layer's image data.
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    local replacement = lurek.image.newImageData(16, 16)
    replacement:fill(0, 0, 1, 1)
    li:setLayer(1, replacement)
    print("layer replaced")
end

--@api-stub: LLayeredImage:getName
-- Returns name of a layer.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("background")
    local name = li:getName(1)
    print("layer name = " .. name)
end

--@api-stub: LLayeredImage:setName
-- Sets a layer name.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    print("new name = " .. li:getName(1))
end

--@api-stub: LLayeredImage:getOpacity
-- Returns layer opacity (0.0 to 1.0).
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    print("opacity = " .. li:getOpacity(1))
end

--@api-stub: LLayeredImage:setOpacity
-- Sets layer opacity.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    print("opacity = " .. li:getOpacity(1))
end

--@api-stub: LLayeredImage:isVisible
-- Returns whether a layer is visible.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    print("visible = " .. tostring(li:isVisible(1)))
end

--@api-stub: LLayeredImage:setVisible
-- Toggles layer visibility.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    print("visible = " .. tostring(li:isVisible(1)))
end

--@api-stub: LLayeredImage:moveLayer
-- Moves a layer to a new index.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    print("moved: first is now " .. li:getName(1))
end

--@api-stub: LLayeredImage:swapLayers
-- Swaps two layers.
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    print("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end

--@api-stub: LLayeredImage:merge
-- Merges all visible layers into one image.
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("base")
    local merged = li:merge()
    print("merged " .. merged:getWidth() .. "x" .. merged:getHeight())
end

--@api-stub: LLayeredImage:save
-- Saves layered image to file.
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("only")
    li:save("save/layered_test.limg")
    print("layered image saved")
end

--@api-stub: LLayeredImage:layerCount
-- Returns number of layers.
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("empty layers = " .. li:layerCount())
end

--@api-stub: LLayeredImage:getWidth
--@api-stub: LLayeredImage:getHeight
-- Returns dimensions of the layered image.
do
    local li = lurek.image.newLayeredImage(100, 50)
    print("layered size = " .. li:getWidth() .. "x" .. li:getHeight())
end

--@api-stub: LLayeredImage:type
--@api-stub: LLayeredImage:typeOf
-- Type identity checks.
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("type = " .. li:type())
    print("is LayeredImage = " .. tostring(li:typeOf("LayeredImage")))
end

--@api-stub: LPaletteLUT:setColor
-- Maps one RGBA color to another in the lookup table.
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    print("red → green mapping set")
end

--@api-stub: LPaletteLUT:clear
-- Clears all color mappings.
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 0, 1, 1)
    lut:clear()
    print("LUT cleared, colors = " .. lut:getColorCount())
end

--@api-stub: LPaletteLUT:cycle
-- Cycles all palette entries by an offset.
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    lut:setColor(0, 1, 0, 1, 0, 0, 1, 1)
    lut:cycle(1)
    print("palette cycled")
end

--@api-stub: LPaletteLUT:getColorCount
-- Returns number of palette entries.
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0.5, 0, 0, 1)
    print("color count = " .. lut:getColorCount())
end

--@api-stub: LPaletteLUT:type
--@api-stub: LPaletteLUT:typeOf
-- Type checks.
do
    local lut = lurek.image.newPaletteLut()
    print("type = " .. lut:type())
    print("is PaletteLUT = " .. tostring(lut:typeOf("PaletteLUT")))
end

--@api-stub: LCompressedImageData:getDimensions
-- Returns width and height of compressed data.
do
    local cdata = lurek.image.newCompressedData("assets/textures/test.dds")
    local w, h = cdata:getDimensions()
    print("compressed = " .. w .. "x" .. h)
end

--@api-stub: LCompressedImageData:getFormat
-- Returns the DDS format name.
do
    local cdata = lurek.image.newCompressedData("assets/textures/test.dds")
    print("format = " .. cdata:getFormat())
end

--@api-stub: LCompressedImageData:getMipmapCount
-- Returns mipmap level count.
do
    local cdata = lurek.image.newCompressedData("assets/textures/test.dds")
    print("mipmaps = " .. cdata:getMipmapCount())
end

--@api-stub: LCompressedImageData:type
--@api-stub: LCompressedImageData:typeOf
-- Type identity checks.
do
    local cdata = lurek.image.newCompressedData("assets/textures/test.dds")
    print("type = " .. cdata:type())
    print("is CompressedImageData = " .. tostring(cdata:typeOf("CompressedImageData")))
end

--@api-stub: LProvinceGrid:getAt
-- Returns province ID at pixel coordinate.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local id = grid:getAt(10, 10)
    print("province at (10,10) = " .. id)
end

--@api-stub: LProvinceGrid:provinceCount
-- Returns total province count.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    print("provinces = " .. grid:provinceCount())
end

--@api-stub: LProvinceGrid:provinceSpans
-- Returns all horizontal province spans.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local spans = grid:provinceSpans()
    print("total spans = " .. #spans)
end

--@api-stub: LProvinceGrid:adjacencies
-- Returns province adjacency records.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local adj = grid:adjacencies()
    print("adjacency records = " .. #adj)
end

--@api-stub: LProvinceGrid:borderSegments
-- Returns border line segments between provinces.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local segs = grid:borderSegments()
    print("border segments = " .. #segs)
end

--@api-stub: LProvinceGrid:getPolygons
-- Returns polygon rings for every province.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local polys = grid:getPolygons()
    print("polygon records = " .. #polys)
end

--@api-stub: LProvinceGrid:getPolygonsSimplified
-- Returns simplified polygon rings.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local polys = grid:getPolygonsSimplified()
    print("simplified records = " .. #polys)
end

--@api-stub: LProvinceGrid:drawShapes
-- Draws province polygons, optionally culled to viewport.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    print("drew " .. count .. " polygons")
end

--@api-stub: LProvinceGrid:serializeShapeData
--@api-stub: LProvinceGrid:deserializeShapeData
-- Serializes and deserializes shape data for caching.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    local data = grid:serializeShapeData()
    print("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    print("deserialized")
end

--@api-stub: LProvinceGrid:getWidth
--@api-stub: LProvinceGrid:getHeight
-- Returns grid dimensions.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api-stub: LProvinceGrid:type
--@api-stub: LProvinceGrid:typeOf
-- Type identity checks.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    print("type = " .. grid:type())
    print("is ProvinceGrid = " .. tostring(grid:typeOf("ProvinceGrid")))
end

print("image_02.lua")
