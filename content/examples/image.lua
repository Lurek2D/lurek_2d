-- content/examples/image.lua
-- Auto-generated from content/examples2/image_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/image.lua


--- Image Module Part 1: factory functions and LImageData basics


--@api: lurek.image.newImageData
do

    local img = lurek.image.newImageData(128, 64)
    img:fill(20, 30, 60, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    lurek.log.info("blank minimap canvas " .. w .. "x" .. h .. " bytes=" .. #raw)
end

--@api: lurek.image.newImageDataFromBytes
do

    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    local w, h = img:getDimensions()
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("from bytes " .. w .. "x" .. h .. " first=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: lurek.image.loadImage
do

    local src = lurek.image.newImageData(8, 8)
    src:fill(255, 0, 0, 255)
    lurek.image.saveImage(src, "save/sample_image.limg")
    local img = lurek.image.loadImage("save/sample_image.limg")
    lurek.log.info("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: lurek.image.saveImage
do

    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:drawRect(8, 8, 16, 16, 255, 255, 255, 255)
    lurek.image.saveImage(img, "save/red_square.limg")
    local raw = img:getRawBytes()
    lurek.log.info("saved limg bytes=" .. #raw)
end

--@api: lurek.image.savePNG
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 255, 0, 255)
    img:drawCircle(8, 8, 4, 255, 255, 255, 255)
    lurek.image.savePNG(img, "save/green_square.png")
    local encoded = img:encode("png")
    lurek.log.info("saved png bytes=" .. #encoded)
end

--@api: lurek.image.savePNGWorkspace
do

    local source = "save/example_png_workspace"
    local mountpoint = "example_png_workspace"
    lurek.filesystem.createDirectory(source)
    lurek.filesystem.unmount(mountpoint)
    lurek.filesystem.mountWorkspace(lurek.filesystem.toAbsolutePath(source), mountpoint)
    local image = lurek.image.newImageData(8, 8)
    image:fill(240, 160, 70, 255)
    lurek.image.savePNGWorkspace(image, mountpoint .. "/sprites/example.png")
    lurek.log.info("saved workspace PNG=" .. mountpoint .. "/sprites/example.png")
    lurek.filesystem.unmount(mountpoint)
end

--@api: lurek.image.saveGIF
do

    local frames = {}

    local a = lurek.image.newImageData(32, 32)
    a:fill(20, 30, 60, 255)
    a:drawCircle(10, 16, 6, 255, 210, 80, 255)
    frames[1] = a

    local b = lurek.image.newImageData(32, 32)
    b:fill(20, 30, 60, 255)
    b:drawCircle(22, 16, 6, 80, 210, 255, 255)
    frames[2] = b

    lurek.image.saveGIF(frames, "save/two_frame_orb.gif", { delayMs = 120, speed = 10 })
    lurek.log.info("saved GIF")
end

--@api: lurek.image.fromScreen
do

    local capture = lurek.image.fromScreen()
    local status = capture and (capture:getWidth() .. "x" .. capture:getHeight()) or "not ready yet"
    local sampled_alpha = capture and select(4, capture:getPixel(0, 0)) or -1
    local mode = lurek.render.getBlendMode()
    lurek.log.info("screen capture " .. status .. " alpha=" .. sampled_alpha .. " blend=" .. mode)
end

--@api: lurek.image.isCompressed
do

    local dds_path = "content/examples/assets/images/sample_normal.dds"
    local png_path = "content/examples/assets/images/sample_texture.png"
    local dds = lurek.image.isCompressed(dds_path)
    local png = lurek.image.isCompressed(png_path)
    local ok, err = pcall(lurek.image.newCompressedData, dds_path)
    local status = ok and "loaded" or tostring(err)
    lurek.log.info("dds=" .. tostring(dds) .. " png=" .. tostring(png) .. " status=" .. status)
end

--@api: lurek.image.newCompressedData
do

    local path = "content/examples/assets/images/sample_normal.dds"
    local ok, result = pcall(lurek.image.newCompressedData, path)
    local is_dds = lurek.image.isCompressed(path)
    local status = ok and result:type() or "unsupported"
    local detail = ok and result:getFormat() or tostring(result)
    lurek.log.info("compressed dds=" .. tostring(is_dds) .. " status=" .. status .. " detail=" .. detail)
end

--@api: lurek.image.newLayeredImage
do

    local li = lurek.image.newLayeredImage(256, 256)
    local idx = li:addLayer("paint")
    local paint = li:getLayer(idx)
    paint:drawRect(32, 32, 192, 192, 255, 210, 80, 255)
    local w, h = li:getWidth(), li:getHeight()
    local sample = select(1, paint:getPixel(40, 40))
    lurek.log.info("layered " .. w .. "x" .. h .. " layers=" .. li:layerCount() .. " last=" .. idx .. " sample_r=" .. sample)
end

--@api: lurek.image.loadLayered
do

    local path = "content/examples/assets/sample_layered.limg"
    local loaded = lurek.image.loadLayered(path)
    local count = loaded:layerCount()
    local w, h = loaded:getWidth(), loaded:getHeight()
    lurek.log.info("loaded layered=" .. tostring(loaded ~= nil) .. " size=" .. w .. "x" .. h .. " layers=" .. count)
end

--@api: lurek.image.newPaletteLut
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 255, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 120, 220, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    lurek.log.info("palette LUT colors = " .. count .. " type=" .. kind)
end

--@api: lurek.image.newProvinceGrid
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w, h = grid:getWidth(), grid:getHeight()
    local provinces = grid:provinceCount()
    local sample = grid:getAt(10, 10)
    lurek.log.info("province grid " .. w .. "x" .. h .. " provinces=" .. provinces .. " sample=" .. sample)
end

--@api: LImageData:getDimensions
do

    local img = lurek.image.newImageData(100, 50)
    img:fill(10, 20, 30, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    lurek.log.info("dimensions = " .. w .. "x" .. h .. " bytes=" .. #raw)
end

--@api: LImageData:getWidth
do

    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local width = img:getWidth()
    local height = img:getHeight()
    lurek.log.info("width = " .. width .. " height=" .. height)
end

--@api: LImageData:getHeight
do

    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local height = img:getHeight()
    local width = img:getWidth()
    lurek.log.info("height = " .. height .. " width=" .. width)
end

--@api: LImageData:getPixel
do

    local img = lurek.image.newImageData(10, 10)
    img:fill(255, 128, 0, 255)
    local r, g, b, a = img:getPixel(5, 5)
    local width = img:getWidth()
    lurek.log.info("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end

--@api: LImageData:setPixel
do

    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local width = img:getWidth()
    lurek.log.info("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end

--@api: LImageData:fill
do

    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local w, h = img:getDimensions()
    lurek.log.info("filled blue " .. w .. "x" .. h .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawLine
do

    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 255, 255, 0, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    lurek.log.info("line drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawRect
do

    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 255, 0, 255)
    local r, g, b, a = img:getPixel(4, 4)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    lurek.log.info("rect drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawCircle
do

    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 255, 0, 0, 255)
    local r, g, b, a = img:getPixel(32, 32)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    lurek.log.info("circle drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:blit
do

    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(255, 255, 0, 255)
    dst:blit(src, 10, 10)
    lurek.log.info("blitted")
end

--@api: LImageData:paste
do

    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 255, 255, 255)
    dst:paste(src, 0, 0)
    lurek.log.info("pasted")
end

--@api: LImageData:crop
do

    local img = lurek.image.newImageData(100, 100)
    img:drawRect(10, 10, 50, 50, 255, 0, 0, 255)
    local cropped = img:crop(10, 10, 50, 50)
    local r, g, b, a = cropped:getPixel(0, 0)
    lurek.log.info("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:getRegion
do

    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        lurek.log.info("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end

--@api: LImageData:encode
do

    local img = lurek.image.newImageData(4, 4)
    img:fill(255, 0, 0, 255)
    local bytes = img:encode("png")
    local raw = img:getRawBytes()
    lurek.log.info("encoded " .. #bytes .. " bytes from raw=" .. #raw)
end

--@api: LImageData:getRawBytes
do

    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local raw = img:getRawBytes()
    local width = img:getWidth()
    lurek.log.info("raw bytes = " .. #raw .. " width=" .. width)
end

--@api: LImageData:getString
do

    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local str = img:getString()
    local height = img:getHeight()
    lurek.log.info("string bytes = " .. #str .. " height=" .. height)
end

--@api: LImageData:setRawData
do

    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("raw data set sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:type
do

    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local type_name = img:type()
    local r = select(1, img:getPixel(0, 0))
    lurek.log.info("type = " .. type_name .. " sample_r=" .. r)
end

--@api: LImageData:typeOf
do

    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local is_image = img:typeOf("LImageData")
    local is_object = img:typeOf("LObject")
    lurek.log.info("is ImageData = " .. tostring(is_image) .. " object=" .. tostring(is_object))
end

--- Image Module Part 2: LImageData transforms and filters

--@api: LImageData:resize
do

    local img = lurek.image.newImageData(64, 64)
    img:drawRect(16, 16, 32, 32, 255, 210, 80, 255)
    local resized = img:resize(128, 128, "bilinear")
    local center = select(1, resized:getPixel(64, 64))
    local raw = resized:getRawBytes()
    lurek.log.info("resized = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_r=" .. center .. " bytes=" .. #raw)
end

--@api: LImageData:resizeNearest
do

    local img = lurek.image.newImageData(32, 32)
    img:drawRect(8, 8, 16, 16, 0, 200, 255, 255)
    local resized = img:resizeNearest(64, 64)
    local center = select(2, resized:getPixel(32, 32))
    local raw = resized:getRawBytes()
    lurek.log.info("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_g=" .. center .. " bytes=" .. #raw)
end

--@api: LImageData:rotate90cw
do

    local img = lurek.image.newImageData(20, 40)
    img:setPixel(2, 30, 255, 0, 0, 255)
    local rotated = img:rotate90cw()
    local marker = select(1, rotated:getPixel(9, 2))
    local raw = rotated:getRawBytes()
    lurek.log.info("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight() .. " marker_r=" .. marker .. " bytes=" .. #raw)
end

--@api: LImageData:blur
do

    local img = lurek.image.newImageData(64, 64)
    img:fill(255, 0, 0, 255)
    local blurred = img:blur(3)
    local r, g, b, a = blurred:getPixel(0, 0)
    lurek.log.info("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:sharpen
do

    local img = lurek.image.newImageData(64, 64)
    img:fill(128, 128, 128, 255)
    local sharp = img:sharpen()
    local r, g, b, a = sharp:getPixel(0, 0)
    lurek.log.info("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:convolve
do

    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    local r, g, b, a = result:getPixel(0, 0)
    lurek.log.info("convolved " .. result:getWidth() .. "x" .. result:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:grayscale
do

    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api: LImageData:invert
do

    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 0, 0, 255)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api: LImageData:sepia
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:sepia()
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("sepia sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:noise
do

    local img = lurek.image.newImageData(32, 32)
    img:fill(128, 128, 128, 255)
    img:noise(16)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("noise sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:posterize
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(179, 77, 128, 255)
    img:posterize(4)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("posterized sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:threshold
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(153, 153, 153, 255)
    img:threshold(128)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("threshold sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:brightness
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:brightness(1.5)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("brightness sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:contrast
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(102, 153, 128, 255)
    img:contrast(2.0)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("contrast sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:saturation
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:saturation(0.5)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("saturation sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:gamma
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:gamma(2.2)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("gamma sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:tint
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 255, 255, 255)
    img:tint(255, 0, 0, 0.5)
    local r, g, b, a = img:getPixel(0, 0)
    lurek.log.info("tint sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:alphaMask
do

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    lurek.log.info("alpha = " .. a)
end

--@api: LImageData:flipHorizontal
do

    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 255, 0, 0, 255)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    lurek.log.info("flipped h, corner r = " .. r)
end

--@api: LImageData:flipVertical
do

    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 255, 0, 255)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    lurek.log.info("flipped v, corner g = " .. g)
end

--@api: LImageData:mapPixel
do

    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 255, 255, 255)
    img:mapPixel(function(_, _, r, g, b, a)
        return math.floor(r * 0.5), math.floor(g * 0.5), math.floor(b * 0.5), a
    end)
    lurek.log.info("mapped pixels to half brightness")
end

--@api: LImageData:mapPixels
do

    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y)
        return x * 32, y * 32, 0, 255
    end)
    lurek.log.info("gradient mapped")
end

--@api: LImageData:applyPaletteLut
do

    local img = lurek.image.newImageData(16, 16)
    local lut = lurek.image.newPaletteLut()
    img:fill(255, 0, 0, 255)
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    img:applyPaletteLut(lut)
    lurek.log.info("palette LUT applied")
end

--@api: LImageData:diff
do

    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    b:setPixel(0, 0, 1, 0, 0, 1)
    local score = a:diff(b)
    lurek.log.info("diff score = " .. score)
end

--- Image Module Part 3: LLayeredImage, LPaletteLUT, LCompressedImageData, LProvinceGrid

--@api: LLayeredImage:addLayer
do

    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    local layer = li:getLayer(idx)
    layer:fill(20, 30, 60, 255)
    local count = li:layerCount()
    lurek.log.info("added layer at index " .. idx .. " layers=" .. count .. " sample_a=" .. select(4, layer:getPixel(0, 0)))
end

--@api: LLayeredImage:removeLayer
do

    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("background")
    li:addLayer("temp")
    local before = li:layerCount()
    li:removeLayer(1)
    local after = li:layerCount()
    local first = li:getName(1)
    lurek.log.info("layers " .. before .. " -> " .. after .. " first=" .. first)
end

--@api: LLayeredImage:getLayer
do

    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("green")
    local data = li:getLayer(1)
    data:fill(0, 255, 0, 255)
    local g = select(2, data:getPixel(0, 0))
    lurek.log.info("layer " .. idx .. " size=" .. data:getWidth() .. "x" .. data:getHeight() .. " sample_g=" .. g)
end

--@api: LLayeredImage:setLayer
do

    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    local replacement = lurek.image.newImageData(16, 16)
    replacement:fill(255, 255, 255, 255)
    li:setLayer(1, replacement)
    local sample = select(1, li:getLayer(1):getPixel(0, 0))
    lurek.log.info("layer replaced width=" .. li:getLayer(1):getWidth() .. " sample_r=" .. sample)
end

--@api: LLayeredImage:getName
do

    local li = lurek.image.newLayeredImage(8, 8)
    local idx = li:addLayer("background")
    local name = li:getName(1)
    local count = li:layerCount()
    lurek.log.info("layer " .. idx .. " name=" .. name .. " count=" .. count)
end

--@api: LLayeredImage:setName
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    local name = li:getName(1)
    local count = li:layerCount()
    lurek.log.info("new name = " .. name .. " count=" .. count)
end

--@api: LLayeredImage:getOpacity
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.35)
    local opacity = li:getOpacity(1)
    local visible = li:isVisible(1)
    lurek.log.info("opacity = " .. opacity .. " visible=" .. tostring(visible))
end

--@api: LLayeredImage:setOpacity
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    local opacity = li:getOpacity(1)
    local merged = li:merge()
    local dims = merged:getWidth() .. "x" .. merged:getHeight()
    lurek.log.info("opacity = " .. opacity .. " merged=" .. dims)
end

--@api: LLayeredImage:isVisible
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    lurek.log.info("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end

--@api: LLayeredImage:setVisible
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    lurek.log.info("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end

--@api: LLayeredImage:moveLayer
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    lurek.log.info("moved: first is now " .. li:getName(1))
end

--@api: LLayeredImage:swapLayers
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    lurek.log.info("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end

--@api: LLayeredImage:merge
do

    local li = lurek.image.newLayeredImage(32, 32)
    local base = li:addLayer("base")
    local fx = li:addLayer("fx")
    li:getLayer(base):fill(40, 60, 120, 255)
    li:getLayer(fx):drawCircle(16, 16, 8, 255, 220, 120, 255)
    local merged = li:merge()
    local sample = select(1, merged:getPixel(16, 16))
    lurek.log.info("merged " .. merged:getWidth() .. "x" .. merged:getHeight() .. " sample_r=" .. sample)
end

--@api: LLayeredImage:save
do

    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("only")
    li:getLayer(idx):fill(255, 255, 255, 255)
    li:save("save/layered_test.limg")
    local merged = li:merge()
    lurek.log.info("layered image saved layers=" .. li:layerCount() .. " sample_a=" .. select(4, merged:getPixel(0, 0)))
end

--@api: LLayeredImage:layerCount
do

    local li = lurek.image.newLayeredImage(8, 8)
    local empty = li:layerCount()
    li:addLayer("terrain")
    li:addLayer("roads")
    local total = li:layerCount()
    lurek.log.info("layers " .. empty .. " -> " .. total)
end

--@api: LLayeredImage:getWidth
do

    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    lurek.log.info("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end

--@api: LLayeredImage:getHeight
do

    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    lurek.log.info("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end

--@api: LLayeredImage:type
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    lurek.log.info("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end

--@api: LLayeredImage:typeOf
do

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    lurek.log.info("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end

--@api: LPaletteLUT:setColor
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    lurek.log.info("red → green mapping set")
end

--@api: LPaletteLUT:clear
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 0, 255, 255)
    local before = lut:getColorCount()
    lut:clear()
    local after = lut:getColorCount()
    local kind = lut:type()
    lurek.log.info("LUT cleared, colors = " .. lut:getColorCount())
end

--@api: LPaletteLUT:cycle
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 0, 255, 255)
    lut:cycle(1)
    lurek.log.info("palette cycled")
end

--@api: LPaletteLUT:getColorCount
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 128, 0, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 128, 0, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    lurek.log.info("color count = " .. lut:getColorCount())
end

--@api: LPaletteLUT:type
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local count = lut:getColorCount()
    lurek.log.info("type = " .. lut:type())
    lurek.log.info("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end

--@api: LPaletteLUT:typeOf
do

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local is_object = lut:typeOf("LObject")
    lurek.log.info("type = " .. lut:type())
    lurek.log.info("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end

--@api: LCompressedImageData:getDimensions
do

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w, h = 0, 0
    if ok then
        w, h = cdata:getDimensions()
    end
    local status = ok and (w .. "x" .. h) or "unsupported in PNG runtime"
    lurek.log.info("compressed = " .. status)
end

--@api: LCompressedImageData:getFormat
do

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cdata:getWidth() or 0
    local h = ok and cdata:getHeight() or 0
    local format = ok and cdata:getFormat() or "unsupported"
    lurek.log.info("format = " .. format .. " size=" .. w .. "x" .. h)
end

--@api: LCompressedImageData:getMipmapCount
do

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local w = ok and cdata:getWidth() or 0
    local h = ok and cdata:getHeight() or 0
    local mips = ok and cdata:getMipmapCount() or 0
    lurek.log.info("mipmaps = " .. mips .. " format=" .. fmt .. " size=" .. w .. "x" .. h)
end

--@api: LCompressedImageData:type
do

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local w = ok and cdata:getWidth() or 0
    local type_name = ok and cdata:type() or "nil"
    lurek.log.info("type = " .. type_name .. " format=" .. fmt .. " width=" .. w)
end

--@api: LCompressedImageData:typeOf
do

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local is_object = ok and cdata:typeOf("LObject") or false
    local is_compressed = ok and cdata:typeOf("LCompressedImageData") or false
    lurek.log.info("typeOf object=" .. tostring(is_object) .. " compressed=" .. tostring(is_compressed) .. " format=" .. fmt)
end

--@api: LProvinceGrid:getAt
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local id = grid:getAt(10, 10)
    local neighbor = grid:getAt(11, 10)
    local total = grid:provinceCount()
    lurek.log.info("province at (10,10) = " .. id)
end

--@api: LProvinceGrid:provinceCount
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w = grid:getWidth()
    local h = grid:getHeight()
    local start = grid:getAt(0, 0)
    lurek.log.info("provinces = " .. grid:provinceCount())
end

--@api: LProvinceGrid:provinceSpans
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local spans = grid:provinceSpans()
    local provinces = grid:provinceCount()
    local first = spans[1]
    lurek.log.info("total spans = " .. #spans)
end

--@api: LProvinceGrid:adjacencies
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local adj = grid:adjacencies()
    local borders = grid:borderSegments()
    local first = adj[1]
    lurek.log.info("adjacency records = " .. #adj)
end

--@api: LProvinceGrid:borderSegments
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local segs = grid:borderSegments()
    local polys = grid:getPolygonsSimplified()
    local first = segs[1]
    lurek.log.info("border segments = " .. #segs)
end

--@api: LProvinceGrid:getPolygons
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygons()
    local simplified = grid:getPolygonsSimplified()
    local first = polys[1]
    lurek.log.info("polygon records = " .. #polys)
end

--@api: LProvinceGrid:getPolygonsSimplified
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygonsSimplified()
    local full = grid:getPolygons()
    local first = polys[1]
    lurek.log.info("simplified records = " .. #polys)
end

--@api: LProvinceGrid:drawShapes
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    local provinces = grid:provinceCount()
    local w = grid:getWidth()
    lurek.log.info("drew " .. count .. " polygons")
end

--@api: LProvinceGrid:serializeShapeData
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    lurek.log.info("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    lurek.log.info("deserialized")
end

--@api: LProvinceGrid:deserializeShapeData
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    lurek.log.info("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    lurek.log.info("deserialized")
end

--@api: LProvinceGrid:getWidth
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local height = grid:getHeight()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    lurek.log.info("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api: LProvinceGrid:getHeight
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local width = grid:getWidth()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    lurek.log.info("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api: LProvinceGrid:type
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local provinces = grid:provinceCount()
    lurek.log.info("type = " .. grid:type())
    lurek.log.info("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end

--@api: LProvinceGrid:typeOf
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local is_object = grid:typeOf("LObject")
    lurek.log.info("type = " .. grid:type())
    lurek.log.info("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end

--- Image Module: LCompressedImageData and additional newImageData

--@api: LCompressedImageData:getHeight
do

    local ok, cd = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cd:getWidth() or 0
    local h = ok and cd:getHeight() or 0
    local mips = ok and cd:getMipmapCount() or 0
    lurek.log.info("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end

--@api: LCompressedImageData:getWidth
do

    local ok, cd = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cd:getWidth() or 0
    local h = ok and cd:getHeight() or 0
    local mips = ok and cd:getMipmapCount() or 0
    lurek.log.info("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
--@api: lurek.image.loadAnimated
do
    local a = lurek.image.newImageData(2, 2)
    local b = lurek.image.newImageData(2, 2)
    a:fill(255, 0, 0, 255)
    b:fill(0, 255, 0, 255)
    lurek.image.saveGIF({ a, b }, "save/example_load_animated.gif", { delayMs = 40 })
    local animated = lurek.image.loadAnimated("save/example_load_animated.gif")
    lurek.log.info("[image] animated frames=" .. tostring(animated:frameCount()))
end

--@api: LAnimatedImage:frameCount
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(255, 255, 255, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_count.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_count.gif")
    local count = animated:frameCount()
    lurek.log.info("[image] frameCount=" .. tostring(count))
end

--@api: LAnimatedImage:getFrame
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(20, 40, 80, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_frame.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_frame.gif")
    local first = animated:getFrame(1)
    lurek.log.info("[image] first frame width=" .. tostring(first:getWidth()))
end

--@api: LAnimatedImage:getDuration
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(20, 40, 80, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_duration.gif", { delayMs = 50 })
    local animated = lurek.image.loadAnimated("save/example_anim_duration.gif")
    local duration = animated:getDuration(1)
    lurek.log.info("[image] duration=" .. tostring(duration))
end

--@api: LAnimatedImage:getFrames
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(80, 40, 20, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_frames.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_frames.gif")
    local frames = animated:getFrames()
    lurek.log.info("[image] frames table=" .. tostring(#frames))
end

--@api: LAnimatedImage:getDurations
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(80, 40, 20, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_durations.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_durations.gif")
    local durations = animated:getDurations()
    lurek.log.info("[image] durations table=" .. tostring(#durations))
end

--@api: LAnimatedImage:type
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(1, 2, 3, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_type.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_type.gif")
    local kind = animated:type()
    lurek.log.info("[image] animated type=" .. kind)
end

--@api: LAnimatedImage:typeOf
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(1, 2, 3, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_typeof.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_typeof.gif")
    local ok = animated:typeOf("LObject")
    lurek.log.info("[image] animated typeOf=" .. tostring(ok))
end

--@api: LImageData:clone
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(10, 20, 30, 255)
    local copy = image:clone()
    copy:setPixel(0, 0, 255, 0, 0, 255)
    lurek.log.info("[image] clone width=" .. tostring(copy:getWidth()))
end

--@api: LImageData:copyRegion
do
    local image = lurek.image.newImageData(8, 8)
    image:fill(20, 30, 40, 255)
    local region = image:copyRegion(2, 2, 4, 4)
    local w, h = region:getDimensions()
    lurek.log.info("[image] copied region=" .. tostring(w) .. "x" .. tostring(h))
end

--@api: LImageData:applyEffect
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(20, 30, 40, 255)
    image:applyEffect("invert", { region = { 0, 0, 2, 2 } })
    local r = ({ image:getPixel(0, 0) })[1]
    lurek.log.info("[image] effect red=" .. tostring(r))
end

--@api: LImageData:applyEffects
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(20, 30, 40, 255)
    image:applyEffects({ "grayscale", { name = "posterize", opts = { levels = 3 } } })
    local r = ({ image:getPixel(0, 0) })[1]
    lurek.log.info("[image] effects red=" .. tostring(r))
end

--@api: LImageData:applyMask
do
    local image = lurek.image.newImageData(2, 2)
    local mask = lurek.image.newImageData(2, 2)
    image:fill(255, 255, 255, 255)
    mask:fill(0, 0, 0, 128)
    image:applyMask(mask)
    lurek.log.info("[image] mask applied")
end

--@api: LImageData:transform
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(5, 10, 15, 255)
    local resized = image:transform({ width = 8, height = 6, filter = "linear" })
    local w, h = resized:getDimensions()
    lurek.log.info("[image] transformed=" .. tostring(w) .. "x" .. tostring(h))
end

--@api: LImageData:applyShader
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(40, 80, 160, 255)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(1.0 - color.r, color.g, uv.x, color.a);
}
]], { target = "image" })
    local output = image:applyShader(shader)
    local r, g, b, _ = output:getPixel(0, 0)
    lurek.log.info("[image] shader output=" .. output:getWidth() .. "x" .. output:getHeight() .. " pixel=" .. r .. "," .. g .. "," .. b)
end

--@api: lurek.image.requestShader
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(120, 80, 40, 255)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.b, color.g, color.r, color.a);
}
]], { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:wait(50)
    lurek.log.info("[image] shader job done=" .. tostring(output ~= nil))
end

--@api: LImageShaderJob:poll
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(10, 20, 30, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:poll()
    local ready = output ~= nil and output:getWidth() == image:getWidth()
    lurek.log.info("[image] shader poll ready=" .. tostring(ready))
end

--@api: LImageShaderJob:wait
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(40, 50, 60, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:wait(100)
    local done = output ~= nil and output:getHeight() == image:getHeight()
    lurek.log.info("[image] shader wait done=" .. tostring(done))
end

--@api: LImageShaderJob:cancel
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(70, 80, 90, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    job:cancel()
    local output = job:poll()
    lurek.log.info("[image] shader cancel output=" .. tostring(output))
end
