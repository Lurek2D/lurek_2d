-- content/examples/image.lua
-- Auto-generated from content/examples2/image_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/image.lua

--- Image Module Part 1: factory functions and LImageData basics

--@api-stub: lurek.image.newImageData
do
    local img = lurek.image.newImageData(128, 64)
    print("image " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.newImageDataFromBytes
do
    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    print("from bytes " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.loadImage
do
    local img = lurek.image.loadImage("assets/textures/province_map.png")
    print("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.saveImage
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(1, 0, 0, 1)
    lurek.image.saveImage(img, "save/red_square.png")
    print("saved image")
end

--@api-stub: lurek.image.savePNG
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 1, 0, 1)
    lurek.image.savePNG(img, "save/green_square.png")
    print("saved PNG")
end

--@api-stub: lurek.image.fromScreen
do
    local capture = lurek.image.fromScreen()
    local status = capture and (capture:getWidth() .. "x" .. capture:getHeight()) or "not ready yet"
    print("screen capture " .. status)
end

--@api-stub: lurek.image.isCompressed
do
    local dds = lurek.image.isCompressed("content/examples/assets/images/sample_normal.dds")
    print("is compressed = " .. tostring(dds))
end

--@api-stub: lurek.image.newCompressedData
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("compressed " .. cdata:getWidth() .. "x" .. cdata:getHeight())
    print("format = " .. cdata:getFormat())
    print("mipmaps = " .. cdata:getMipmapCount())
end

--@api-stub: lurek.image.newLayeredImage
do
    local li = lurek.image.newLayeredImage(256, 256)
    print("layered " .. li:getWidth() .. "x" .. li:getHeight())
    print("layers = " .. li:layerCount())
end

--@api-stub: lurek.image.loadLayered
do
    print("loadLayered available = " .. tostring(type(lurek.image.loadLayered) == "function"))
end

--@api-stub: lurek.image.newPaletteLut
do
    local lut = lurek.image.newPaletteLut()
    print("palette LUT colors = " .. lut:getColorCount())
end

--@api-stub: lurek.image.newProvinceGrid
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid " .. grid:getWidth() .. "x" .. grid:getHeight())
    print("provinces = " .. grid:provinceCount())
end

--@api-stub: LImageData:getDimensions
do
    local img = lurek.image.newImageData(100, 50)
    local w, h = img:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
end

--@api-stub: LImageData:getWidth
do
    local img = lurek.image.newImageData(80, 40)
    print("width = " .. img:getWidth())
end

--@api-stub: LImageData:getHeight
do
    local img = lurek.image.newImageData(80, 40)
    print("height = " .. img:getHeight())
end

--@api-stub: LImageData:getPixel
do
    local img = lurek.image.newImageData(10, 10)
    img:fill(1, 0.5, 0, 1)
    local r, g, b, a = img:getPixel(5, 5)
    print("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageData:setPixel
do
    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 1, 1, 1, 1)
    local r, g, b, a = img:getPixel(0, 0)
    print("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageData:fill
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 1, 1)
    print("filled blue")
end

--@api-stub: LImageData:drawLine
do
    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 1, 1, 0, 1)
    print("line drawn")
end

--@api-stub: LImageData:drawRect
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 1, 0, 1)
    print("rect drawn")
end

--@api-stub: LImageData:drawCircle
do
    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 1, 0, 0, 1)
    print("circle drawn")
end

--@api-stub: LImageData:blit
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(1, 1, 0, 1)
    dst:blit(src, 10, 10)
    print("blitted")
end

--@api-stub: LImageData:paste
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 1, 1, 1)
    dst:paste(src, 0, 0)
    print("pasted")
end

--@api-stub: LImageData:crop
do
    local img = lurek.image.newImageData(100, 100)
    local cropped = img:crop(10, 10, 50, 50)
    print("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight())
end

--@api-stub: LImageData:getRegion
do
    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        print("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end

--@api-stub: LImageData:encode
do
    local img = lurek.image.newImageData(4, 4)
    img:fill(1, 0, 0, 1)
    local bytes = img:encode("png")
    print("encoded " .. #bytes .. " bytes")
end

--@api-stub: LImageData:getRawBytes
do
    local img = lurek.image.newImageData(2, 2)
    local raw = img:getRawBytes()
    print("raw bytes = " .. #raw)
end

--@api-stub: LImageData:getString
do
    local img = lurek.image.newImageData(2, 2)
    local str = img:getString()
    print("string bytes = " .. #str)
end

--@api-stub: LImageData:setRawData
do
    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    print("raw data set")
end

--@api-stub: LImageData:type
do
    local img = lurek.image.newImageData(1, 1)
    print("type = " .. img:type())
end

--@api-stub: LImageData:typeOf
do
    local img = lurek.image.newImageData(1, 1)
    print("is ImageData = " .. tostring(img:typeOf("ImageData")))
end

--- Image Module Part 2: LImageData transforms and filters


--@api-stub: LImageData:resize
do
    local img = lurek.image.newImageData(64, 64)
    local resized = img:resize(128, 128, "bilinear")
    print("resized = " .. resized:getWidth() .. "x" .. resized:getHeight())
end

--@api-stub: LImageData:resizeNearest
do
    local img = lurek.image.newImageData(32, 32)
    local resized = img:resizeNearest(64, 64)
    print("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight())
end

--@api-stub: LImageData:rotate90cw
do
    local img = lurek.image.newImageData(20, 40)
    local rotated = img:rotate90cw()
    print("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight())
end

--@api-stub: LImageData:blur
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(1, 0, 0, 1)
    local blurred = img:blur(3)
    print("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight())
end

--@api-stub: LImageData:sharpen
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(0.5, 0.5, 0.5, 1)
    local sharp = img:sharpen()
    print("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight())
end

--@api-stub: LImageData:convolve
do
    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    print("convolved " .. result:getWidth() .. "x" .. result:getHeight())
end

--@api-stub: LImageData:grayscale
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(1, 0, 0, 1)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    print("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api-stub: LImageData:invert
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(1, 0, 0, 1)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    print("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api-stub: LImageData:sepia
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:sepia()
    print("sepia applied")
end

--@api-stub: LImageData:noise
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(0.5, 0.5, 0.5, 1)
    img:noise(0.1)
    print("noise added")
end

--@api-stub: LImageData:posterize
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.7, 0.3, 0.5, 1)
    img:posterize(4)
    print("posterized to 4 levels")
end

--@api-stub: LImageData:threshold
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.6, 0.6, 0.6, 1)
    img:threshold(0.5)
    print("thresholded at 0.5")
end

--@api-stub: LImageData:brightness
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:brightness(1.5)
    print("brightness increased by 1.5x")
end

--@api-stub: LImageData:contrast
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.4, 0.6, 0.5, 1)
    img:contrast(2.0)
    print("contrast doubled")
end

--@api-stub: LImageData:saturation
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 0, 0, 1)
    img:saturation(0.5)
    print("saturation halved")
end

--@api-stub: LImageData:gamma
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:gamma(2.2)
    print("gamma 2.2 applied")
end

--@api-stub: LImageData:tint
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 1, 1, 1)
    img:tint(1, 0, 0, 0.5)
    print("red tint applied at 50%")
end

--@api-stub: LImageData:alphaMask
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 0, 0, 1)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    print("alpha = " .. a)
end

--@api-stub: LImageData:flipHorizontal
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 1, 0, 0, 1)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    print("flipped h, corner r = " .. r)
end

--@api-stub: LImageData:flipVertical
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 1, 0, 1)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    print("flipped v, corner g = " .. g)
end

--@api-stub: LImageData:mapPixel
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(1, 1, 1, 1)
    img:mapPixel(function(_, _, r, g, b, a) return r * 0.5, g * 0.5, b * 0.5, a end)
    print("mapped pixels to half brightness")
end

--@api-stub: LImageData:mapPixels
do
    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y) return x / 8, y / 8, 0, 1 end)
    print("gradient mapped")
end

--@api-stub: LImageData:drawNineSlice
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(32, 32)
    src:fill(0.5, 0.5, 0.5, 1)
    dst:drawNineSlice(src, 0, 0, 32, 32, 0, 0, 64, 64, 8, 8, 8, 8)
    print("nine-slice drawn")
end

--@api-stub: LImageData:applyPaletteLut
do
    local img = lurek.image.newImageData(16, 16)
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    img:applyPaletteLut(lut)
    print("palette LUT applied")
end

--@api-stub: LImageData:diff
do
    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    b:setPixel(0, 0, 1, 0, 0, 1)
    local score = a:diff(b)
    print("diff score = " .. score)
end

--- Image Module Part 3: LLayeredImage, LPaletteLUT, LCompressedImageData, LProvinceGrid


--@api-stub: LLayeredImage:addLayer
do
    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    print("added layer at index " .. idx)
    print("layers = " .. li:layerCount())
end

--@api-stub: LLayeredImage:removeLayer
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("temp")
    li:removeLayer(1)
    print("layers after remove = " .. li:layerCount())
end

--@api-stub: LLayeredImage:getLayer
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("green")
    local data = li:getLayer(1)
    print("layer 1: " .. data:getWidth() .. "x" .. data:getHeight())
end

--@api-stub: LLayeredImage:setLayer
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    li:setLayer(1, lurek.image.newImageData(16, 16))
    print("layer replaced")
end

--@api-stub: LLayeredImage:getName
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("background")
    local name = li:getName(1)
    print("layer name = " .. name)
end

--@api-stub: LLayeredImage:setName
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    print("new name = " .. li:getName(1))
end

--@api-stub: LLayeredImage:getOpacity
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    print("opacity = " .. li:getOpacity(1))
end

--@api-stub: LLayeredImage:setOpacity
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    print("opacity = " .. li:getOpacity(1))
end

--@api-stub: LLayeredImage:isVisible
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    print("visible = " .. tostring(li:isVisible(1)))
end

--@api-stub: LLayeredImage:setVisible
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    print("visible = " .. tostring(li:isVisible(1)))
end

--@api-stub: LLayeredImage:moveLayer
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    print("moved: first is now " .. li:getName(1))
end

--@api-stub: LLayeredImage:swapLayers
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    print("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end

--@api-stub: LLayeredImage:merge
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("base")
    local merged = li:merge()
    print("merged " .. merged:getWidth() .. "x" .. merged:getHeight())
end

--@api-stub: LLayeredImage:save
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("only")
    li:save("save/layered_test.limg")
    print("layered image saved")
end

--@api-stub: LLayeredImage:layerCount
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("empty layers = " .. li:layerCount())
end

--@api-stub: LLayeredImage:getWidth
do
    local li = lurek.image.newLayeredImage(100, 50)
    print("layered size = " .. li:getWidth() .. "x" .. li:getHeight())
end

--@api-stub: LLayeredImage:getHeight
do
    local li = lurek.image.newLayeredImage(100, 50)
    print("layered size = " .. li:getWidth() .. "x" .. li:getHeight())
end

--@api-stub: LLayeredImage:type
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("type = " .. li:type())
    print("is LayeredImage = " .. tostring(li:typeOf("LayeredImage")))
end

--@api-stub: LLayeredImage:typeOf
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("type = " .. li:type())
    print("is LayeredImage = " .. tostring(li:typeOf("LayeredImage")))
end

--@api-stub: LPaletteLUT:setColor
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    print("red → green mapping set")
end

--@api-stub: LPaletteLUT:clear
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 0, 1, 1)
    lut:clear()
    print("LUT cleared, colors = " .. lut:getColorCount())
end

--@api-stub: LPaletteLUT:cycle
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    lut:setColor(0, 1, 0, 1, 0, 0, 1, 1)
    lut:cycle(1)
    print("palette cycled")
end

--@api-stub: LPaletteLUT:getColorCount
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0.5, 0, 0, 1)
    print("color count = " .. lut:getColorCount())
end

--@api-stub: LPaletteLUT:type
do
    local lut = lurek.image.newPaletteLut()
    print("type = " .. lut:type())
    print("is PaletteLUT = " .. tostring(lut:typeOf("PaletteLUT")))
end

--@api-stub: LPaletteLUT:typeOf
do
    local lut = lurek.image.newPaletteLut()
    print("type = " .. lut:type())
    print("is PaletteLUT = " .. tostring(lut:typeOf("PaletteLUT")))
end

--@api-stub: LCompressedImageData:getDimensions
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    print("compressed = " .. w .. "x" .. h)
end

--@api-stub: LCompressedImageData:getFormat
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("format = " .. cdata:getFormat())
end

--@api-stub: LCompressedImageData:getMipmapCount
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("mipmaps = " .. cdata:getMipmapCount())
end

--@api-stub: LCompressedImageData:type
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("type = " .. cdata:type())
    print("is CompressedImageData = " .. tostring(cdata:typeOf("CompressedImageData")))
end

--@api-stub: LCompressedImageData:typeOf
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("type = " .. cdata:type())
    print("is CompressedImageData = " .. tostring(cdata:typeOf("CompressedImageData")))
end

--@api-stub: LProvinceGrid:getAt
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local id = grid:getAt(10, 10)
    print("province at (10,10) = " .. id)
end

--@api-stub: LProvinceGrid:provinceCount
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("provinces = " .. grid:provinceCount())
end

--@api-stub: LProvinceGrid:provinceSpans
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local spans = grid:provinceSpans()
    print("total spans = " .. #spans)
end

--@api-stub: LProvinceGrid:adjacencies
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local adj = grid:adjacencies()
    print("adjacency records = " .. #adj)
end

--@api-stub: LProvinceGrid:borderSegments
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local segs = grid:borderSegments()
    print("border segments = " .. #segs)
end

--@api-stub: LProvinceGrid:getPolygons
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local polys = grid:getPolygons()
    print("polygon records = " .. #polys)
end

--@api-stub: LProvinceGrid:getPolygonsSimplified
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local polys = grid:getPolygonsSimplified()
    print("simplified records = " .. #polys)
end

--@api-stub: LProvinceGrid:drawShapes
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    print("drew " .. count .. " polygons")
end

--@api-stub: LProvinceGrid:serializeShapeData
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    print("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    print("deserialized")
end

--@api-stub: LProvinceGrid:deserializeShapeData
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    print("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    print("deserialized")
end

--@api-stub: LProvinceGrid:getWidth
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api-stub: LProvinceGrid:getHeight
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api-stub: LProvinceGrid:type
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("type = " .. grid:type())
    print("is ProvinceGrid = " .. tostring(grid:typeOf("ProvinceGrid")))
end

--@api-stub: LProvinceGrid:typeOf
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("type = " .. grid:type())
    print("is ProvinceGrid = " .. tostring(grid:typeOf("ProvinceGrid")))
end

--- Image Module: LCompressedImageData and additional newImageData


--@api-stub: LCompressedImageData:getHeight
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    print("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end

--@api-stub: LCompressedImageData:getWidth
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    print("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end

print("content/examples/image.lua")

