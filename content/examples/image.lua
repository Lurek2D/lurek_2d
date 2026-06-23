-- content/examples/image.lua
-- Auto-generated from content/examples2/image_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/image.lua


--- Image Module Part 1: factory functions and LImageData basics


--@api: lurek.image.newImageData
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(128, 64)
    img:fill(20, 30, 60, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    image_log("blank minimap canvas " .. w .. "x" .. h .. " bytes=" .. #raw)
end

--@api: lurek.image.newImageDataFromBytes
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    local w, h = img:getDimensions()
    local r, g, b, a = img:getPixel(0, 0)
    image_log("from bytes " .. w .. "x" .. h .. " first=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: lurek.image.loadImage
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local src = lurek.image.newImageData(8, 8)
    src:fill(255, 0, 0, 255)
    lurek.image.saveImage(src, "save/sample_image.limg")
    local img = lurek.image.loadImage("save/sample_image.limg")
    example_print_log("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: lurek.image.saveImage
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:drawRect(8, 8, 16, 16, 255, 255, 255, 255)
    lurek.image.saveImage(img, "save/red_square.limg")
    local raw = img:getRawBytes()
    image_log("saved limg bytes=" .. #raw)
end

--@api: lurek.image.savePNG
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 255, 0, 255)
    img:drawCircle(8, 8, 4, 255, 255, 255, 255)
    lurek.image.savePNG(img, "save/green_square.png")
    local encoded = img:encode("png")
    image_log("saved png bytes=" .. #encoded)
end

--@api: lurek.image.saveGIF
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("saved GIF")
end

--@api: lurek.image.fromScreen
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local capture = lurek.image.fromScreen()
    local status = capture and (capture:getWidth() .. "x" .. capture:getHeight()) or "not ready yet"
    local sampled_alpha = capture and select(4, capture:getPixel(0, 0)) or -1
    local mode = lurek.render.getBlendMode()
    image_log("screen capture " .. status .. " alpha=" .. sampled_alpha .. " blend=" .. mode)
end

--@api: lurek.image.isCompressed
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dds_path = "content/examples/assets/images/sample_normal.dds"
    local png_path = "content/examples/assets/images/sample_texture.png"
    local dds = lurek.image.isCompressed(dds_path)
    local png = lurek.image.isCompressed(png_path)
    local cdata = lurek.image.newCompressedData(dds_path)
    local fmt = cdata:getFormat()
    image_log("dds=" .. tostring(dds) .. " png=" .. tostring(png) .. " format=" .. fmt)
end

--@api: lurek.image.newCompressedData
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    local fmt = cdata:getFormat()
    local mips = cdata:getMipmapCount()
    image_log("compressed " .. w .. "x" .. h .. " format=" .. fmt .. " mips=" .. mips)
end

--@api: lurek.image.newLayeredImage
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(256, 256)
    local idx = li:addLayer("paint")
    local paint = li:getLayer(idx)
    paint:drawRect(32, 32, 192, 192, 255, 210, 80, 255)
    local w, h = li:getWidth(), li:getHeight()
    local sample = select(1, paint:getPixel(40, 40))
    image_log("layered " .. w .. "x" .. h .. " layers=" .. li:layerCount() .. " last=" .. idx .. " sample_r=" .. sample)
end

--@api: lurek.image.loadLayered
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/sample_layered.limg"
    local loaded = lurek.image.loadLayered(path)
    local count = loaded:layerCount()
    local w, h = loaded:getWidth(), loaded:getHeight()
    image_log("loaded layered=" .. tostring(loaded ~= nil) .. " size=" .. w .. "x" .. h .. " layers=" .. count)
end

--@api: lurek.image.newPaletteLut
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 255, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 120, 220, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    image_log("palette LUT colors = " .. count .. " type=" .. kind)
end

--@api: lurek.image.newProvinceGrid
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w, h = grid:getWidth(), grid:getHeight()
    local provinces = grid:provinceCount()
    local sample = grid:getAt(10, 10)
    image_log("province grid " .. w .. "x" .. h .. " provinces=" .. provinces .. " sample=" .. sample)
end

--@api: LImageData:getDimensions
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(100, 50)
    img:fill(10, 20, 30, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    image_log("dimensions = " .. w .. "x" .. h .. " bytes=" .. #raw)
end

--@api: LImageData:getWidth
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local width = img:getWidth()
    local height = img:getHeight()
    image_log("width = " .. width .. " height=" .. height)
end

--@api: LImageData:getHeight
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local height = img:getHeight()
    local width = img:getWidth()
    image_log("height = " .. height .. " width=" .. width)
end

--@api: LImageData:getPixel
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(10, 10)
    img:fill(255, 128, 0, 255)
    local r, g, b, a = img:getPixel(5, 5)
    local width = img:getWidth()
    image_log("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end

--@api: LImageData:setPixel
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local width = img:getWidth()
    image_log("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end

--@api: LImageData:fill
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local w, h = img:getDimensions()
    image_log("filled blue " .. w .. "x" .. h .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawLine
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 255, 255, 0, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("line drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawRect
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 255, 0, 255)
    local r, g, b, a = img:getPixel(4, 4)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("rect drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:drawCircle
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 255, 0, 0, 255)
    local r, g, b, a = img:getPixel(32, 32)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("circle drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:blit
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(255, 255, 0, 255)
    dst:blit(src, 10, 10)
    example_print_log("blitted")
end

--@api: LImageData:paste
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 255, 255, 255)
    dst:paste(src, 0, 0)
    example_print_log("pasted")
end

--@api: LImageData:crop
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(100, 100)
    img:drawRect(10, 10, 50, 50, 255, 0, 0, 255)
    local cropped = img:crop(10, 10, 50, 50)
    local r, g, b, a = cropped:getPixel(0, 0)
    image_log("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:getRegion
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        example_print_log("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end

--@api: LImageData:encode
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(4, 4)
    img:fill(255, 0, 0, 255)
    local bytes = img:encode("png")
    local raw = img:getRawBytes()
    image_log("encoded " .. #bytes .. " bytes from raw=" .. #raw)
end

--@api: LImageData:getRawBytes
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local raw = img:getRawBytes()
    local width = img:getWidth()
    image_log("raw bytes = " .. #raw .. " width=" .. width)
end

--@api: LImageData:getString
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local str = img:getString()
    local height = img:getHeight()
    image_log("string bytes = " .. #str .. " height=" .. height)
end

--@api: LImageData:setRawData
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("raw data set sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:type
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local type_name = img:type()
    local r = select(1, img:getPixel(0, 0))
    image_log("type = " .. type_name .. " sample_r=" .. r)
end

--@api: LImageData:typeOf
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local is_image = img:typeOf("LImageData")
    local is_object = img:typeOf("LObject")
    image_log("is ImageData = " .. tostring(is_image) .. " object=" .. tostring(is_object))
end

--- Image Module Part 2: LImageData transforms and filters

--@api: LImageData:resize
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(64, 64)
    img:drawRect(16, 16, 32, 32, 255, 210, 80, 255)
    local resized = img:resize(128, 128, "bilinear")
    local center = select(1, resized:getPixel(64, 64))
    local raw = resized:getRawBytes()
    image_log("resized = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_r=" .. center .. " bytes=" .. #raw)
end

--@api: LImageData:resizeNearest
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:drawRect(8, 8, 16, 16, 0, 200, 255, 255)
    local resized = img:resizeNearest(64, 64)
    local center = select(2, resized:getPixel(32, 32))
    local raw = resized:getRawBytes()
    image_log("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_g=" .. center .. " bytes=" .. #raw)
end

--@api: LImageData:rotate90cw
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(20, 40)
    img:setPixel(2, 30, 255, 0, 0, 255)
    local rotated = img:rotate90cw()
    local marker = select(1, rotated:getPixel(9, 2))
    local raw = rotated:getRawBytes()
    image_log("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight() .. " marker_r=" .. marker .. " bytes=" .. #raw)
end

--@api: LImageData:blur
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(64, 64)
    img:fill(255, 0, 0, 255)
    local blurred = img:blur(3)
    local r, g, b, a = blurred:getPixel(0, 0)
    image_log("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:sharpen
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(64, 64)
    img:fill(128, 128, 128, 255)
    local sharp = img:sharpen()
    local r, g, b, a = sharp:getPixel(0, 0)
    image_log("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:convolve
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    local r, g, b, a = result:getPixel(0, 0)
    image_log("convolved " .. result:getWidth() .. "x" .. result:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:grayscale
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    example_print_log("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api: LImageData:invert
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 0, 0, 255)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    example_print_log("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api: LImageData:sepia
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:sepia()
    local r, g, b, a = img:getPixel(0, 0)
    image_log("sepia sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:noise
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(32, 32)
    img:fill(128, 128, 128, 255)
    img:noise(16)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("noise sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:posterize
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(179, 77, 128, 255)
    img:posterize(4)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("posterized sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:threshold
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(153, 153, 153, 255)
    img:threshold(128)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("threshold sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:brightness
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:brightness(1.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("brightness sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:contrast
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(102, 153, 128, 255)
    img:contrast(2.0)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("contrast sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:saturation
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:saturation(0.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("saturation sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:gamma
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:gamma(2.2)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("gamma sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:tint
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 255, 255, 255)
    img:tint(255, 0, 0, 0.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("tint sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LImageData:alphaMask
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    example_print_log("alpha = " .. a)
end

--@api: LImageData:flipHorizontal
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 255, 0, 0, 255)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    example_print_log("flipped h, corner r = " .. r)
end

--@api: LImageData:flipVertical
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 255, 0, 255)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    example_print_log("flipped v, corner g = " .. g)
end

--@api: LImageData:mapPixel
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 255, 255, 255)
    img:mapPixel(function(_, _, r, g, b, a)
        return math.floor(r * 0.5), math.floor(g * 0.5), math.floor(b * 0.5), a
    end)
    example_print_log("mapped pixels to half brightness")
end

--@api: LImageData:mapPixels
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y)
        return x * 32, y * 32, 0, 255
    end)
    example_print_log("gradient mapped")
end

--@api: LImageData:applyPaletteLut
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.image.newImageData(16, 16)
    local lut = lurek.image.newPaletteLut()
    img:fill(255, 0, 0, 255)
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    img:applyPaletteLut(lut)
    example_print_log("palette LUT applied")
end

--@api: LImageData:diff
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    b:setPixel(0, 0, 1, 0, 0, 1)
    local score = a:diff(b)
    example_print_log("diff score = " .. score)
end

--- Image Module Part 3: LLayeredImage, LPaletteLUT, LCompressedImageData, LProvinceGrid

--@api: LLayeredImage:addLayer
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    local layer = li:getLayer(idx)
    layer:fill(20, 30, 60, 255)
    local count = li:layerCount()
    image_log("added layer at index " .. idx .. " layers=" .. count .. " sample_a=" .. select(4, layer:getPixel(0, 0)))
end

--@api: LLayeredImage:removeLayer
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("background")
    li:addLayer("temp")
    local before = li:layerCount()
    li:removeLayer(1)
    local after = li:layerCount()
    local first = li:getName(1)
    image_log("layers " .. before .. " -> " .. after .. " first=" .. first)
end

--@api: LLayeredImage:getLayer
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("green")
    local data = li:getLayer(1)
    data:fill(0, 255, 0, 255)
    local g = select(2, data:getPixel(0, 0))
    image_log("layer " .. idx .. " size=" .. data:getWidth() .. "x" .. data:getHeight() .. " sample_g=" .. g)
end

--@api: LLayeredImage:setLayer
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    local replacement = lurek.image.newImageData(16, 16)
    replacement:fill(255, 255, 255, 255)
    li:setLayer(1, replacement)
    local sample = select(1, li:getLayer(1):getPixel(0, 0))
    image_log("layer replaced width=" .. li:getLayer(1):getWidth() .. " sample_r=" .. sample)
end

--@api: LLayeredImage:getName
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    local idx = li:addLayer("background")
    local name = li:getName(1)
    local count = li:layerCount()
    image_log("layer " .. idx .. " name=" .. name .. " count=" .. count)
end

--@api: LLayeredImage:setName
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    local name = li:getName(1)
    local count = li:layerCount()
    image_log("new name = " .. name .. " count=" .. count)
end

--@api: LLayeredImage:getOpacity
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.35)
    local opacity = li:getOpacity(1)
    local visible = li:isVisible(1)
    image_log("opacity = " .. opacity .. " visible=" .. tostring(visible))
end

--@api: LLayeredImage:setOpacity
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    local opacity = li:getOpacity(1)
    local merged = li:merge()
    local dims = merged:getWidth() .. "x" .. merged:getHeight()
    image_log("opacity = " .. opacity .. " merged=" .. dims)
end

--@api: LLayeredImage:isVisible
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    image_log("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end

--@api: LLayeredImage:setVisible
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    image_log("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end

--@api: LLayeredImage:moveLayer
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    example_print_log("moved: first is now " .. li:getName(1))
end

--@api: LLayeredImage:swapLayers
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    example_print_log("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end

--@api: LLayeredImage:merge
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(32, 32)
    local base = li:addLayer("base")
    local fx = li:addLayer("fx")
    li:getLayer(base):fill(40, 60, 120, 255)
    li:getLayer(fx):drawCircle(16, 16, 8, 255, 220, 120, 255)
    local merged = li:merge()
    local sample = select(1, merged:getPixel(16, 16))
    image_log("merged " .. merged:getWidth() .. "x" .. merged:getHeight() .. " sample_r=" .. sample)
end

--@api: LLayeredImage:save
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("only")
    li:getLayer(idx):fill(255, 255, 255, 255)
    li:save("save/layered_test.limg")
    local merged = li:merge()
    image_log("layered image saved layers=" .. li:layerCount() .. " sample_a=" .. select(4, merged:getPixel(0, 0)))
end

--@api: LLayeredImage:layerCount
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    local empty = li:layerCount()
    li:addLayer("terrain")
    li:addLayer("roads")
    local total = li:layerCount()
    image_log("layers " .. empty .. " -> " .. total)
end

--@api: LLayeredImage:getWidth
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    image_log("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end

--@api: LLayeredImage:getHeight
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    image_log("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end

--@api: LLayeredImage:type
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    image_log("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end

--@api: LLayeredImage:typeOf
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    image_log("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end

--@api: LPaletteLUT:setColor
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    example_print_log("red → green mapping set")
end

--@api: LPaletteLUT:clear
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 0, 255, 255)
    local before = lut:getColorCount()
    lut:clear()
    local after = lut:getColorCount()
    local kind = lut:type()
    example_print_log("LUT cleared, colors = " .. lut:getColorCount())
end

--@api: LPaletteLUT:cycle
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 0, 255, 255)
    lut:cycle(1)
    example_print_log("palette cycled")
end

--@api: LPaletteLUT:getColorCount
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 128, 0, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 128, 0, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    example_print_log("color count = " .. lut:getColorCount())
end

--@api: LPaletteLUT:type
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local count = lut:getColorCount()
    example_print_log("type = " .. lut:type())
    example_print_log("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end

--@api: LPaletteLUT:typeOf
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local is_object = lut:typeOf("LObject")
    example_print_log("type = " .. lut:type())
    example_print_log("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end

--@api: LCompressedImageData:getDimensions
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    local fmt = cdata:getFormat()
    local mips = cdata:getMipmapCount()
    example_print_log("compressed = " .. w .. "x" .. h)
end

--@api: LCompressedImageData:getFormat
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cdata:getWidth()
    local h = cdata:getHeight()
    local mips = cdata:getMipmapCount()
    example_print_log("format = " .. cdata:getFormat())
end

--@api: LCompressedImageData:getMipmapCount
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local w = cdata:getWidth()
    local h = cdata:getHeight()
    example_print_log("mipmaps = " .. cdata:getMipmapCount())
end

--@api: LCompressedImageData:type
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local w = cdata:getWidth()
    example_print_log("type = " .. cdata:type())
    example_print_log("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end

--@api: LCompressedImageData:typeOf
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local is_object = cdata:typeOf("LObject")
    example_print_log("type = " .. cdata:type())
    example_print_log("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end

--@api: LProvinceGrid:getAt
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local id = grid:getAt(10, 10)
    local neighbor = grid:getAt(11, 10)
    local total = grid:provinceCount()
    example_print_log("province at (10,10) = " .. id)
end

--@api: LProvinceGrid:provinceCount
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w = grid:getWidth()
    local h = grid:getHeight()
    local start = grid:getAt(0, 0)
    example_print_log("provinces = " .. grid:provinceCount())
end

--@api: LProvinceGrid:provinceSpans
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local spans = grid:provinceSpans()
    local provinces = grid:provinceCount()
    local first = spans[1]
    example_print_log("total spans = " .. #spans)
end

--@api: LProvinceGrid:adjacencies
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local adj = grid:adjacencies()
    local borders = grid:borderSegments()
    local first = adj[1]
    example_print_log("adjacency records = " .. #adj)
end

--@api: LProvinceGrid:borderSegments
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local segs = grid:borderSegments()
    local polys = grid:getPolygonsSimplified()
    local first = segs[1]
    example_print_log("border segments = " .. #segs)
end

--@api: LProvinceGrid:getPolygons
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygons()
    local simplified = grid:getPolygonsSimplified()
    local first = polys[1]
    example_print_log("polygon records = " .. #polys)
end

--@api: LProvinceGrid:getPolygonsSimplified
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygonsSimplified()
    local full = grid:getPolygons()
    local first = polys[1]
    example_print_log("simplified records = " .. #polys)
end

--@api: LProvinceGrid:drawShapes
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    local provinces = grid:provinceCount()
    local w = grid:getWidth()
    example_print_log("drew " .. count .. " polygons")
end

--@api: LProvinceGrid:serializeShapeData
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    example_print_log("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    example_print_log("deserialized")
end

--@api: LProvinceGrid:deserializeShapeData
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    example_print_log("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    example_print_log("deserialized")
end

--@api: LProvinceGrid:getWidth
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local height = grid:getHeight()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    example_print_log("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api: LProvinceGrid:getHeight
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local width = grid:getWidth()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    example_print_log("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end

--@api: LProvinceGrid:type
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local provinces = grid:provinceCount()
    example_print_log("type = " .. grid:type())
    example_print_log("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end

--@api: LProvinceGrid:typeOf
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local is_object = grid:typeOf("LObject")
    example_print_log("type = " .. grid:type())
    example_print_log("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end

--- Image Module: LCompressedImageData and additional newImageData

--@api: LCompressedImageData:getHeight
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    example_print_log("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end

--@api: LCompressedImageData:getWidth
do
    local function image_log(message)
        lurek.log.info("[image.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    example_print_log("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
