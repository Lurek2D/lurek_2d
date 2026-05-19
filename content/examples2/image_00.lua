--- Image Module Part 1: factory functions and LImageData basics

-- Creates blank image data from width and height.
--@api-stub: lurek.image.newImageData
do
    local img = lurek.image.newImageData(128, 64)
    print("image " .. img:getWidth() .. "x" .. img:getHeight())
end

-- Loads image data from a file path.
do
    local img = lurek.image.newImageData("assets/textures/test.png")
    print("loaded " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.newImageDataFromBytes
-- Creates image data from raw RGBA bytes.
do
    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    print("from bytes " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.loadImage
-- Loads and decodes an image from GameFS.
do
    local img = lurek.image.loadImage("assets/textures/test.png")
    print("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api-stub: lurek.image.saveImage
-- Saves image data to a file.
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(1, 0, 0, 1)
    lurek.image.saveImage(img, "save/red_square.png")
    print("saved image")
end

--@api-stub: lurek.image.savePNG
-- Encodes and saves image data as PNG.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 1, 0, 1)
    lurek.image.savePNG(img, "save/green_square.png")
    print("saved PNG")
end

--@api-stub: lurek.image.fromScreen
-- Captures the current screen (may return nil on first call).
do
    local capture = lurek.image.fromScreen()
    if capture then
        print("screen capture " .. capture:getWidth() .. "x" .. capture:getHeight())
    else
        print("capture requested, not ready yet")
    end
end

--@api-stub: lurek.image.isCompressed
-- Checks if a file is DDS compressed image data.
do
    local dds = lurek.image.isCompressed("assets/textures/test.dds")
    print("is compressed = " .. tostring(dds))
end

--@api-stub: lurek.image.newCompressedData
-- Loads DDS compressed image data.
do
    local cdata = lurek.image.newCompressedData("assets/textures/test.dds")
    print("compressed " .. cdata:getWidth() .. "x" .. cdata:getHeight())
    print("format = " .. cdata:getFormat())
    print("mipmaps = " .. cdata:getMipmapCount())
end

--@api-stub: lurek.image.newLayeredImage
-- Creates a layered image stack.
do
    local li = lurek.image.newLayeredImage(256, 256)
    print("layered " .. li:getWidth() .. "x" .. li:getHeight())
    print("layers = " .. li:layerCount())
end

--@api-stub: lurek.image.loadLayered
-- Loads a layered image from file.
do
    local li = lurek.image.loadLayered("assets/textures/layers.limg")
    print("loaded layered, layers = " .. li:layerCount())
end

--@api-stub: lurek.image.newPaletteLut
-- Creates an empty palette lookup table.
do
    local lut = lurek.image.newPaletteLut()
    print("palette LUT colors = " .. lut:getColorCount())
end

--@api-stub: lurek.image.newProvinceGrid
-- Loads a province id grid from an image file.
do
    local grid = lurek.image.newProvinceGrid("assets/textures/provinces.png")
    print("grid " .. grid:getWidth() .. "x" .. grid:getHeight())
    print("provinces = " .. grid:provinceCount())
end

--@api-stub: LImageData:getDimensions
-- Returns width and height.
do
    local img = lurek.image.newImageData(100, 50)
    local w, h = img:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
end

--@api-stub: LImageData:getWidth
-- Returns image width.
do
    local img = lurek.image.newImageData(80, 40)
    print("width = " .. img:getWidth())
end

--@api-stub: LImageData:getHeight
-- Returns image height.
do
    local img = lurek.image.newImageData(80, 40)
    print("height = " .. img:getHeight())
end

--@api-stub: LImageData:getPixel
-- Returns RGBA at a pixel coordinate.
do
    local img = lurek.image.newImageData(10, 10)
    img:fill(1, 0.5, 0, 1)
    local r, g, b, a = img:getPixel(5, 5)
    print("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageData:setPixel
-- Sets RGBA at a pixel coordinate.
do
    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 1, 1, 1, 1)
    local r, g, b, a = img:getPixel(0, 0)
    print("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LImageData:fill
-- Fills the whole image with one color.
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 1, 1)
    print("filled blue")
end

--@api-stub: LImageData:drawLine
-- Draws a line into the image.
do
    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 1, 1, 0, 1)
    print("line drawn")
end

--@api-stub: LImageData:drawRect
-- Draws a filled rectangle.
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 1, 0, 1)
    print("rect drawn")
end

--@api-stub: LImageData:drawCircle
-- Draws a filled circle.
do
    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 1, 0, 0, 1)
    print("circle drawn")
end

--@api-stub: LImageData:blit
-- Copies source image into this image at a position.
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(1, 1, 0, 1)
    dst:blit(src, 10, 10)
    print("blitted")
end

--@api-stub: LImageData:paste
-- Pastes source image at unsigned coordinates.
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 1, 1, 1)
    dst:paste(src, 0, 0)
    print("pasted")
end

--@api-stub: LImageData:crop
-- Returns a cropped region.
do
    local img = lurek.image.newImageData(100, 100)
    local cropped = img:crop(10, 10, 50, 50)
    print("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight())
end

--@api-stub: LImageData:getRegion
-- Returns a sub-region of the image.
do
    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        print("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end

--@api-stub: LImageData:encode
-- Encodes image as PNG bytes.
do
    local img = lurek.image.newImageData(4, 4)
    img:fill(1, 0, 0, 1)
    local bytes = img:encode("png")
    print("encoded " .. #bytes .. " bytes")
end

--@api-stub: LImageData:getRawBytes
-- Returns raw RGBA byte string.
do
    local img = lurek.image.newImageData(2, 2)
    local raw = img:getRawBytes()
    print("raw bytes = " .. #raw)
end

--@api-stub: LImageData:getString
-- Returns raw image bytes as string.
do
    local img = lurek.image.newImageData(2, 2)
    local str = img:getString()
    print("string bytes = " .. #str)
end

--@api-stub: LImageData:setRawData
-- Replaces image bytes with raw data.
do
    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    print("raw data set")
end

--@api-stub: LImageData:type
-- Returns the type name "LImageData".
do
    local img = lurek.image.newImageData(1, 1)
    print("type = " .. img:type())
end

--@api-stub: LImageData:typeOf
-- Returns whether this image matches a type name.
do
    local img = lurek.image.newImageData(1, 1)
    print("is ImageData = " .. tostring(img:typeOf("ImageData")))
end

print("image_00.lua")
