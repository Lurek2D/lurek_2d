-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_image_core_unit.lua
do
-- tests/lua/unit/test_image_core_unit.lua
-- Canonical unit coverage for lurek.image and related userdata APIs.

local DDS_FIXTURE = "tests/fixtures/test_dxt1.dds"
local PROVINCE_FIXTURE = "content/games/strategy/eu2/map.png"
local ROUNDTRIP_IMAGE_PATH = "save/test_image_core_roundtrip.limg"
local ROUNDTRIP_PNG_PATH = "save/test_image_core_roundtrip.png"
local ROUNDTRIP_GIF_PATH = "save/test_image_core_roundtrip.gif"
local ROUNDTRIP_LAYERED_PATH = "save/test_image_core_layered.limg"
local SMALL_PROVINCE_PATH = "save/test_image_core_province.png"

local function solid_image(w, h, r, g, b, a)
    local img = lurek.image.newImageData(w, h)
    if r ~= nil then
        img:fill(r, g, b, a or 255)
    end
    return img
end

local function expect_pixel(img, x, y, r, g, b, a)
    local pr, pg, pb, pa = img:getPixel(x, y)
    expect_equal(r, pr)
    expect_equal(g, pg)
    expect_equal(b, pb)
    expect_equal(a, pa)
end

local function load_compressed_fixture()
    return lurek.image.newCompressedData(DDS_FIXTURE)
end

local function new_layered_fixture()
    local stack = lurek.image.newLayeredImage(4, 4)
    stack:addLayer("base")
    stack:addLayer("top")
    return stack
end

local function write_small_province_map()
    local img = solid_image(4, 4, 0, 0, 0, 0)

    for y = 0, 1 do
        for x = 0, 1 do
            img:setPixel(x, y, 255, 0, 0, 255)
        end
    end

    for y = 0, 1 do
        for x = 2, 3 do
            img:setPixel(x, y, 0, 255, 0, 255)
        end
    end

    for x = 0, 3 do
        img:setPixel(x, 2, 0, 0, 255, 255)
    end

    lurek.image.savePNG(img, SMALL_PROVINCE_PATH)
    return SMALL_PROVINCE_PATH
end

-- @describe lurek.image module functions
describe("lurek.image module functions", function()
    -- @covers lurek.image.newCompressedData
    it("newCompressedData errors on a missing file", function()
        expect_error(function()
            lurek.image.newCompressedData("nonexistent_file.dds")
        end)
    end)

    -- @covers lurek.image.isCompressed
    it("isCompressed returns false for a missing file", function()
        expect_false(lurek.image.isCompressed("nonexistent_file.dds"))
    end)

    -- @covers lurek.image.loadImage
    it("loadImage restores an image saved with saveImage", function()
        local src = solid_image(2, 2, 12, 34, 56, 255)
        lurek.image.saveImage(src, ROUNDTRIP_IMAGE_PATH)

        local loaded = lurek.image.loadImage(ROUNDTRIP_IMAGE_PATH)
        expect_equal(2, loaded:getWidth())
        expect_equal(2, loaded:getHeight())
        expect_pixel(loaded, 0, 0, 12, 34, 56, 255)
    end)

    -- @covers lurek.image.loadLayered
    it("loadLayered restores a layered image saved to disk", function()
        local stack = lurek.image.newLayeredImage(3, 2)
        stack:addLayer("only")
        stack:save(ROUNDTRIP_LAYERED_PATH)

        local loaded = lurek.image.loadLayered(ROUNDTRIP_LAYERED_PATH)
        expect_equal(3, loaded:getWidth())
        expect_equal(2, loaded:getHeight())
        expect_equal(1, loaded:layerCount())
        expect_equal("only", loaded:getName(1))
    end)

    -- @covers lurek.image.newImageData
    it("newImageData creates a blank image with requested dimensions", function()
        local img = lurek.image.newImageData(5, 3)
        expect_equal(5, img:getWidth())
        expect_equal(3, img:getHeight())
        expect_pixel(img, 0, 0, 0, 0, 0, 0)
    end)

    -- @covers lurek.image.newImageData
    it("newImageData rejects negative dimensions", function()
        expect_error(function()
            lurek.image.newImageData(-1, 3)
        end)
    end)

    -- @covers lurek.image.newImageDataFromBytes
    it("newImageDataFromBytes decodes RGBA byte payloads", function()
        local bytes = string.char(
            1, 2, 3, 255,
            4, 5, 6, 255,
            7, 8, 9, 255,
            10, 11, 12, 255
        )
        local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
        expect_pixel(img, 1, 1, 10, 11, 12, 255)
    end)

    -- @covers lurek.image.newLayeredImage
    it("newLayeredImage creates an empty stack with fixed canvas size", function()
        local stack = lurek.image.newLayeredImage(7, 9)
        expect_equal(7, stack:getWidth())
        expect_equal(9, stack:getHeight())
        expect_equal(0, stack:layerCount())
    end)

    -- @covers lurek.image.newLayeredImage
    it("newLayeredImage rejects negative dimensions", function()
        expect_error(function()
            lurek.image.newLayeredImage(-2, 9)
        end)
    end)

    -- @covers lurek.image.newPaletteLut
    it("newPaletteLut starts with no mappings", function()
        local lut = lurek.image.newPaletteLut()
        expect_equal(0, lut:getColorCount())
    end)

    -- @covers lurek.image.newProvinceGrid
    it("newProvinceGrid loads a color province map", function()
        local path = write_small_province_map()
        local grid = lurek.image.newProvinceGrid(path)
        expect_equal(4, grid:getWidth())
        expect_equal(4, grid:getHeight())
        expect_equal(3, grid:provinceCount())
    end)

    -- @covers lurek.image.saveImage
    it("saveImage writes a round-trippable image file", function()
        local src = solid_image(2, 2, 200, 100, 50, 255)
        lurek.image.saveImage(src, ROUNDTRIP_IMAGE_PATH)

        local loaded = lurek.image.loadImage(ROUNDTRIP_IMAGE_PATH)
        expect_pixel(loaded, 0, 0, 200, 100, 50, 255)
    end)

    -- @covers lurek.image.savePNG
    it("savePNG writes a PNG loadable through loadImage", function()
        local src = solid_image(2, 2, 9, 8, 7, 255)
        lurek.image.savePNG(src, ROUNDTRIP_PNG_PATH)

        local loaded = lurek.image.newImageData(ROUNDTRIP_PNG_PATH)
        expect_equal(2, loaded:getWidth())
        expect_equal(2, loaded:getHeight())
    end)

    -- @covers lurek.image.saveGIF
    it("saveGIF writes an animated GIF header and output file", function()
        local frames = {}

        local a = solid_image(12, 8, 220, 40, 40, 255)
        a:drawRect(1, 1, 4, 4, 255, 240, 120, 255)
        frames[1] = a

        local b = solid_image(12, 8, 40, 120, 220, 255)
        b:drawRect(7, 2, 4, 4, 120, 255, 240, 255)
        frames[2] = b

        lurek.image.saveGIF(frames, ROUNDTRIP_GIF_PATH, { delayMs = 100, speed = 10 })

        expect_true(lurek.filesystem.exists(ROUNDTRIP_GIF_PATH))
        local bytes = lurek.filesystem.readBytes(ROUNDTRIP_GIF_PATH)
        expect_true(#bytes > 16, "GIF payload should contain header and frame data")
        expect_equal("GIF", string.sub(bytes, 1, 3))
        expect_true(
            string.sub(bytes, 1, 6) == "GIF89a" or string.sub(bytes, 1, 6) == "GIF87a",
            "GIF signature should be valid"
        )
    end)

    -- @covers lurek.image.fromScreen
    it("fromScreen returns nil or ImageData while polling", function()
        local result = lurek.image.fromScreen()
        expect_true(result == nil or type(result) == "userdata")
    end)
end)

-- @describe LCompressedImageData methods
describe("LCompressedImageData methods", function()
    -- @covers LCompressedImageData:getDimensions
    it("getDimensions matches width and height getters", function()
        local data = load_compressed_fixture()
        local w, h = data:getDimensions()
        expect_equal(data:getWidth(), w)
        expect_equal(data:getHeight(), h)
    end)

    -- @covers LCompressedImageData:getFormat
    it("getFormat returns a non-empty format string", function()
        local data = load_compressed_fixture()
        local format = data:getFormat()
        expect_type("string", format)
        expect_true(#format > 0)
    end)

    -- @covers LCompressedImageData:getHeight
    it("getHeight reports positive height", function()
        local data = load_compressed_fixture()
        expect_true(data:getHeight() > 0)
    end)

    -- @covers LCompressedImageData:getMipmapCount
    it("getMipmapCount returns a non-negative integer", function()
        local data = load_compressed_fixture()
        local count = data:getMipmapCount()
        expect_type("number", count)
        expect_true(count >= 0)
    end)

    -- @covers LCompressedImageData:getWidth
    it("getWidth reports positive width", function()
        local data = load_compressed_fixture()
        expect_true(data:getWidth() > 0)
    end)

    -- @covers LCompressedImageData:type
    it("type returns a userdata type name", function()
        local data = load_compressed_fixture()
        expect_type("string", data:type())
    end)

    -- @covers LCompressedImageData:typeOf
    it("typeOf is callable and returns a boolean", function()
        local data = load_compressed_fixture()
        expect_type("boolean", data:typeOf("LObject"))
    end)
end)

-- @describe LImageData methods
describe("LImageData methods", function()
    -- @covers LImageData:alphaMask
    it("alphaMask scales alpha in place", function()
        local img = solid_image(1, 1, 128, 64, 32, 200)
        img:alphaMask(0.5)
        expect_pixel(img, 0, 0, 128, 64, 32, 100)
    end)

    -- @covers LImageData:applyPaletteLut
    it("applyPaletteLut replaces mapped colors", function()
        local img = solid_image(1, 1, 255, 0, 0, 255)
        local lut = lurek.image.newPaletteLut()
        lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
        img:applyPaletteLut(lut)
        expect_pixel(img, 0, 0, 0, 255, 0, 255)
    end)

    -- @covers LImageData:blit
    it("blit copies source pixels into the destination image", function()
        local dst = solid_image(4, 4, 0, 0, 0, 255)
        local src = solid_image(2, 2, 200, 100, 50, 255)
        dst:blit(src, 1, 1)
        expect_pixel(dst, 1, 1, 200, 100, 50, 255)
    end)

    -- @covers LImageData:blur
    it("blur returns a same-sized image", function()
        local img = solid_image(4, 4, 10, 20, 30, 255)
        local out = img:blur(0)
        expect_equal(4, out:getWidth())
        expect_equal(4, out:getHeight())
    end)

    -- @covers LImageData:brightness
    it("brightness brightens mid-tone pixels", function()
        local img = solid_image(1, 1, 128, 128, 128, 255)
        img:brightness(2.0)
        local r = img:getPixel(0, 0)
        expect_true(r > 128)
    end)

    -- @covers LImageData:contrast
    it("contrast pushes bright values farther from mid-gray", function()
        local img = solid_image(1, 1, 200, 200, 200, 255)
        img:contrast(2.0)
        local r = img:getPixel(0, 0)
        expect_equal(255, r)
    end)

    -- @covers LImageData:convolve
    it("convolve accepts an identity kernel and returns an image", function()
        local img = solid_image(3, 3, 0, 0, 0, 255)
        img:setPixel(1, 1, 50, 60, 70, 255)
        local out = img:convolve({ 0, 0, 0, 0, 1, 0, 0, 0, 0 }, 3)
        expect_pixel(out, 1, 1, 50, 60, 70, 255)
    end)

    -- @covers LImageData:crop
    it("crop returns the selected sub-region", function()
        local img = solid_image(4, 4, 0, 0, 0, 255)
        img:setPixel(1, 1, 200, 100, 50, 255)
        local out = img:crop(1, 1, 2, 2)
        expect_equal(2, out:getWidth())
        expect_equal(2, out:getHeight())
        expect_pixel(out, 0, 0, 200, 100, 50, 255)
    end)

    -- @covers LImageData:diff
    it("diff returns zero for identical images", function()
        local a = solid_image(2, 2, 10, 20, 30, 255)
        local b = solid_image(2, 2, 10, 20, 30, 255)
        expect_equal(0, a:diff(b))
    end)

    -- @covers LImageData:drawCircle
    it("drawCircle colors pixels inside the radius", function()
        local img = solid_image(9, 9, 0, 0, 0, 0)
        img:drawCircle(4, 4, 2, 255, 0, 0, 255)
        local r, g, b, a = img:getPixel(4, 4)
        expect_equal(255, r)
        expect_equal(0, g)
        expect_equal(0, b)
        expect_equal(255, a)
    end)

    -- @covers LImageData:drawLine
    it("drawLine colors pixels along the segment", function()
        local img = solid_image(8, 8, 0, 0, 0, 0)
        img:drawLine(0, 0, 7, 7, 0, 255, 0, 255)
        local _, g, _, a = img:getPixel(7, 7)
        expect_equal(255, g)
        expect_equal(255, a)
    end)

    -- @covers LImageData:drawNineSlice
    it("drawNineSlice stretches the center patch into the target", function()
        local src = solid_image(6, 6, 10, 10, 10, 255)
        local dst = solid_image(20, 20, 0, 0, 0, 0)
        src:drawRect(2, 2, 2, 2, 220, 30, 30, 255)
        dst:drawNineSlice(src, 0, 0, 6, 6, 4, 4, 12, 12, 2, 2, 2, 2)
        expect_pixel(dst, 10, 10, 220, 30, 30, 255)
    end)

    -- @covers LImageData:drawRect
    it("drawRect fills the requested rectangle", function()
        local img = solid_image(8, 8, 0, 0, 0, 0)
        img:drawRect(2, 2, 3, 3, 0, 0, 255, 255)
        expect_pixel(img, 3, 3, 0, 0, 255, 255)
    end)

    -- @covers LImageData:encode
    it("encode returns non-empty binary data", function()
        local img = solid_image(2, 2, 1, 2, 3, 255)
        local blob = img:encode("png")
        expect_true(type(blob) == "string" or type(blob) == "table")
    end)

    -- @covers LImageData:fill
    it("fill writes one color across the entire image", function()
        local img = lurek.image.newImageData(3, 3)
        img:fill(11, 22, 33, 44)
        expect_pixel(img, 2, 2, 11, 22, 33, 44)
    end)

    -- @covers LImageData:flipHorizontal
    it("flipHorizontal mirrors left and right pixels", function()
        local img = solid_image(4, 1, 0, 0, 0, 255)
        img:setPixel(0, 0, 255, 0, 0, 255)
        img:setPixel(3, 0, 0, 0, 255, 255)
        img:flipHorizontal()
        expect_pixel(img, 0, 0, 0, 0, 255, 255)
        expect_pixel(img, 3, 0, 255, 0, 0, 255)
    end)

    -- @covers LImageData:flipVertical
    it("flipVertical mirrors top and bottom pixels", function()
        local img = solid_image(1, 4, 0, 0, 0, 255)
        img:setPixel(0, 0, 255, 0, 0, 255)
        img:setPixel(0, 3, 0, 0, 255, 255)
        img:flipVertical()
        expect_pixel(img, 0, 0, 0, 0, 255, 255)
        expect_pixel(img, 0, 3, 255, 0, 0, 255)
    end)

    -- @covers LImageData:gamma
    it("gamma brightens a mid-tone sample", function()
        local img = solid_image(1, 1, 128, 128, 128, 255)
        img:gamma(2.0)
        local r = img:getPixel(0, 0)
        expect_true(r > 128)
    end)

    -- @covers LImageData:getDimensions
    it("getDimensions returns width and height", function()
        local img = lurek.image.newImageData(4, 6)
        local w, h = img:getDimensions()
        expect_equal(4, w)
        expect_equal(6, h)
    end)

    -- @covers LImageData:getHeight
    it("getHeight returns the image height", function()
        local img = lurek.image.newImageData(2, 7)
        expect_equal(7, img:getHeight())
    end)

    -- @covers LImageData:getPixel
    it("getPixel returns per-channel RGBA values", function()
        local img = solid_image(2, 2, 0, 0, 0, 0)
        img:setPixel(1, 0, 9, 8, 7, 6)
        expect_pixel(img, 1, 0, 9, 8, 7, 6)
    end)

    -- @covers LImageData:getRawBytes
    it("getRawBytes returns one RGBA byte tuple per pixel", function()
        local img = solid_image(2, 2, 1, 2, 3, 4)
        local raw = img:getRawBytes()
        expect_type("string", raw)
        expect_equal(16, #raw)
    end)

    -- @covers LImageData:getRegion
    it("getRegion returns a same-sized copy of the requested area", function()
        local img = solid_image(6, 4, 20, 40, 60, 255)
        local region = img:getRegion(1, 1, 3, 2)
        expect_equal(3, region:getWidth())
        expect_equal(2, region:getHeight())
    end)

    -- @covers LImageData:getString
    it("getString returns a string-like payload", function()
        local img = solid_image(2, 2, 1, 2, 3, 4)
        local payload = img:getString()
        expect_true(type(payload) == "string" or type(payload) == "table")
    end)

    -- @covers LImageData:getWidth
    it("getWidth returns the image width", function()
        local img = lurek.image.newImageData(9, 2)
        expect_equal(9, img:getWidth())
    end)

    -- @covers LImageData:grayscale
    it("grayscale equalizes RGB channels", function()
        local img = solid_image(1, 1, 255, 0, 0, 255)
        img:grayscale()
        local r, g, b = img:getPixel(0, 0)
        expect_equal(r, g)
        expect_equal(g, b)
    end)

    -- @covers LImageData:invert
    it("invert flips RGB channels while preserving alpha", function()
        local img = solid_image(1, 1, 100, 150, 200, 99)
        img:invert()
        expect_pixel(img, 0, 0, 155, 105, 55, 99)
    end)

    -- @covers LImageData:mapPixel
    it("mapPixel is callable with a transformation callback", function()
        local img = solid_image(2, 2, 5, 6, 7, 255)
        local ok = pcall(function()
            img:mapPixel(function(_, _, r, g, b, a)
                return r, g, b, a
            end)
        end)
        expect_true(ok)
    end)

    -- @covers LImageData:mapPixels
    it("mapPixels can recolor every pixel in the image", function()
        local img = solid_image(2, 2, 0, 0, 0, 255)
        img:mapPixels(function()
            return 1, 2, 3, 4
        end)
        expect_pixel(img, 1, 1, 1, 2, 3, 4)
    end)

    -- @covers LImageData:noise
    it("noise with zero amount leaves pixels unchanged", function()
        local img = solid_image(1, 1, 100, 150, 200, 128)
        img:noise(0)
        expect_pixel(img, 0, 0, 100, 150, 200, 128)
    end)

    -- @covers LImageData:paste
    it("paste overlays source pixels into the destination", function()
        local dst = solid_image(4, 4, 0, 0, 0, 255)
        local src = solid_image(2, 2, 40, 50, 60, 255)
        dst:paste(src, 1, 1)
        expect_pixel(dst, 1, 1, 40, 50, 60, 255)
    end)

    -- @covers LImageData:posterize
    it("posterize quantizes channel levels", function()
        local img = solid_image(1, 1, 100, 100, 100, 77)
        img:posterize(4)
        local r, g, b, a = img:getPixel(0, 0)
        expect_true(r == 0 or r == 85 or r == 170 or r == 255)
        expect_true(g == 0 or g == 85 or g == 170 or g == 255)
        expect_true(b == 0 or b == 85 or b == 170 or b == 255)
        expect_equal(77, a)
    end)

    -- @covers LImageData:resize
    it("resize returns an image with requested dimensions", function()
        local img = solid_image(4, 4, 255, 0, 0, 255)
        local out = img:resize(3, 5, "lanczos3")
        local w, h = out:getDimensions()
        expect_equal(3, w)
        expect_equal(5, h)
    end)

    -- @covers LImageData:resize
    it("resize rejects negative output dimensions", function()
        local img = solid_image(4, 4, 255, 0, 0, 255)
        expect_error(function()
            img:resize(-1, 5, "lanczos3")
        end)
    end)

    -- @covers LImageData:resizeNearest
    it("resizeNearest preserves nearest-neighbor source colors", function()
        local img = solid_image(4, 4, 0, 0, 0, 255)
        img:setPixel(0, 0, 200, 100, 50, 255)
        local out = img:resizeNearest(2, 2)
        expect_pixel(out, 0, 0, 200, 100, 50, 255)
    end)

    -- @covers LImageData:rotate90cw
    it("rotate90cw swaps width and height", function()
        local img = solid_image(4, 2, 0, 0, 0, 255)
        local out = img:rotate90cw()
        expect_equal(2, out:getWidth())
        expect_equal(4, out:getHeight())
    end)

    -- @covers LImageData:saturation
    it("saturation with zero factor desaturates the pixel", function()
        local img = solid_image(1, 1, 255, 0, 0, 255)
        img:saturation(0.0)
        local r, g, b = img:getPixel(0, 0)
        expect_true(math.abs(r - g) <= 2)
        expect_true(math.abs(g - b) <= 2)
    end)

    -- @covers LImageData:sepia
    it("sepia produces warm-toned output", function()
        local img = solid_image(1, 1, 200, 100, 50, 128)
        img:sepia()
        local r, g, b, a = img:getPixel(0, 0)
        expect_true(r >= g)
        expect_true(g >= b)
        expect_equal(128, a)
    end)

    -- @covers LImageData:setPixel
    it("setPixel writes RGBA data at one coordinate", function()
        local img = lurek.image.newImageData(2, 2)
        img:setPixel(1, 1, 7, 8, 9, 10)
        expect_pixel(img, 1, 1, 7, 8, 9, 10)
    end)

    -- @covers LImageData:setRawData
    it("setRawData replaces the underlying image bytes", function()
        local img = lurek.image.newImageData(1, 1)
        img:setRawData(string.char(7, 8, 9, 255))
        expect_pixel(img, 0, 0, 7, 8, 9, 255)
    end)

    -- @covers LImageData:sharpen
    it("sharpen returns a same-sized image", function()
        local img = solid_image(4, 4, 30, 40, 50, 255)
        local out = img:sharpen()
        expect_equal(4, out:getWidth())
        expect_equal(4, out:getHeight())
    end)

    -- @covers LImageData:threshold
    it("threshold bins pixels to black or white", function()
        local img = solid_image(1, 1, 10, 10, 10, 99)
        img:threshold(128)
        expect_pixel(img, 0, 0, 0, 0, 0, 99)
    end)

    -- @covers LImageData:tint
    it("tint mixes the image toward the tint color", function()
        local img = solid_image(1, 1, 128, 64, 32, 200)
        img:tint(0, 255, 0, 1.0)
        expect_pixel(img, 0, 0, 0, 255, 0, 200)
    end)

    -- @covers LImageData:type
    it("type returns a userdata type name", function()
        local img = lurek.image.newImageData(1, 1)
        expect_type("string", img:type())
    end)

    -- @covers LImageData:typeOf
    it("typeOf is callable and returns a boolean", function()
        local img = lurek.image.newImageData(1, 1)
        expect_type("boolean", img:typeOf("LObject"))
    end)
end)

-- @describe LLayeredImage methods
describe("LLayeredImage methods", function()
    -- @covers LLayeredImage:addLayer
    it("addLayer appends a named layer and returns its index", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        local idx = stack:addLayer("background")
        expect_equal(1, idx)
        expect_equal(1, stack:layerCount())
    end)

    -- @covers LLayeredImage:getHeight
    it("getHeight reports the layered canvas height", function()
        local stack = lurek.image.newLayeredImage(4, 9)
        expect_equal(9, stack:getHeight())
    end)

    -- @covers LLayeredImage:getLayer
    it("getLayer returns ImageData for a valid layer", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        local img = stack:getLayer(1)
        expect_equal(4, img:getWidth())
        expect_equal(4, img:getHeight())
    end)

    -- @covers LLayeredImage:getName
    it("getName returns the stored layer name", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("myName")
        expect_equal("myName", stack:getName(1))
    end)

    -- @covers LLayeredImage:getOpacity
    it("getOpacity reads the layer opacity", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        stack:setOpacity(1, 0.5)
        expect_true(math.abs(stack:getOpacity(1) - 0.5) < 0.01)
    end)

    -- @covers LLayeredImage:getWidth
    it("getWidth reports the layered canvas width", function()
        local stack = lurek.image.newLayeredImage(8, 4)
        expect_equal(8, stack:getWidth())
    end)

    -- @covers LLayeredImage:isVisible
    it("isVisible reflects the layer visibility flag", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        stack:setVisible(1, false)
        expect_false(stack:isVisible(1))
    end)

    -- @covers LLayeredImage:layerCount
    it("layerCount tracks the number of layers", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("a")
        stack:addLayer("b")
        expect_equal(2, stack:layerCount())
    end)

    -- @covers LLayeredImage:merge
    it("merge composites the visible layers into one image", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        local bg = solid_image(4, 4, 255, 0, 0, 255)
        local fg = solid_image(4, 4, 0, 0, 255, 255)
        stack:addLayer("bg")
        stack:addLayer("fg")
        stack:setLayer(1, bg)
        stack:setLayer(2, fg)
        local out = stack:merge()
        expect_pixel(out, 0, 0, 0, 0, 255, 255)
    end)

    -- @covers LLayeredImage:moveLayer
    it("moveLayer reorders layers by index", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("a")
        stack:addLayer("b")
        stack:addLayer("c")
        expect_true(stack:moveLayer(1, 3))
        expect_equal("b", stack:getName(1))
        expect_equal("a", stack:getName(3))
    end)

    -- @covers LLayeredImage:removeLayer
    it("removeLayer deletes an existing layer", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        expect_true(stack:removeLayer(1))
        expect_equal(0, stack:layerCount())
    end)

    -- @covers LLayeredImage:save
    it("save writes a round-trippable layered image file", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("only")
        stack:save(ROUNDTRIP_LAYERED_PATH)
        local loaded = lurek.image.loadLayered(ROUNDTRIP_LAYERED_PATH)
        expect_equal(1, loaded:layerCount())
    end)

    -- @covers LLayeredImage:setLayer
    it("setLayer replaces the image payload of a layer", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        local src = solid_image(4, 4, 255, 0, 0, 255)
        stack:addLayer("x")
        expect_true(stack:setLayer(1, src))
        expect_pixel(stack:getLayer(1), 0, 0, 255, 0, 0, 255)
    end)

    -- @covers LLayeredImage:setName
    it("setName renames an existing layer", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("old")
        expect_true(stack:setName(1, "new"))
        expect_equal("new", stack:getName(1))
    end)

    -- @covers LLayeredImage:setOpacity
    it("setOpacity stores the requested layer opacity", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        expect_true(stack:setOpacity(1, 0.25))
        expect_true(math.abs(stack:getOpacity(1) - 0.25) < 0.01)
    end)

    -- @covers LLayeredImage:setVisible
    it("setVisible updates the layer visibility flag", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("x")
        expect_true(stack:setVisible(1, false))
        expect_false(stack:isVisible(1))
    end)

    -- @covers LLayeredImage:swapLayers
    it("swapLayers exchanges layer order", function()
        local stack = lurek.image.newLayeredImage(4, 4)
        stack:addLayer("first")
        stack:addLayer("second")
        expect_true(stack:swapLayers(1, 2))
        expect_equal("second", stack:getName(1))
        expect_equal("first", stack:getName(2))
    end)

    -- @covers LLayeredImage:type
    it("type returns a userdata type name", function()
        local stack = lurek.image.newLayeredImage(1, 1)
        expect_type("string", stack:type())
    end)

    -- @covers LLayeredImage:typeOf
    it("typeOf is callable and returns a boolean", function()
        local stack = lurek.image.newLayeredImage(1, 1)
        expect_type("boolean", stack:typeOf("LObject"))
    end)
end)

-- @describe LPaletteLUT methods
describe("LPaletteLUT methods", function()
    -- @covers LPaletteLUT:clear
    it("clear removes every palette mapping", function()
        local lut = lurek.image.newPaletteLut()
        lut:setColor(1, 2, 3, 255, 4, 5, 6, 255)
        lut:setColor(10, 20, 30, 255, 40, 50, 60, 255)
        lut:clear()
        expect_equal(0, lut:getColorCount())
    end)

    -- @covers LPaletteLUT:cycle
    it("cycle rotates mappings between palette entries", function()
        local img = solid_image(1, 1, 255, 0, 0, 255)
        local lut = lurek.image.newPaletteLut()
        lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
        lut:setColor(0, 255, 0, 255, 0, 0, 255, 255)
        lut:cycle(1)
        img:applyPaletteLut(lut)
        expect_pixel(img, 0, 0, 0, 0, 255, 255)
    end)

    -- @covers LPaletteLUT:getColorCount
    it("getColorCount reports the number of mappings", function()
        local lut = lurek.image.newPaletteLut()
        lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
        lut:setColor(0, 0, 255, 255, 255, 255, 0, 255)
        expect_equal(2, lut:getColorCount())
    end)

    -- @covers LPaletteLUT:setColor
    it("setColor registers a palette remap entry", function()
        local img = solid_image(1, 1, 5, 6, 7, 255)
        local lut = lurek.image.newPaletteLut()
        lut:setColor(5, 6, 7, 255, 8, 9, 10, 255)
        img:applyPaletteLut(lut)
        expect_pixel(img, 0, 0, 8, 9, 10, 255)
    end)

    -- @covers LPaletteLUT:type
    it("type returns a userdata type name", function()
        local lut = lurek.image.newPaletteLut()
        expect_type("string", lut:type())
    end)

    -- @covers LPaletteLUT:typeOf
    it("typeOf is callable and returns a boolean", function()
        local lut = lurek.image.newPaletteLut()
        expect_type("boolean", lut:typeOf("LObject"))
    end)
end)

-- @describe LProvinceGrid methods
describe("LProvinceGrid methods", function()
    -- @covers LProvinceGrid:adjacencies
    it("adjacencies reports borders between neighboring provinces", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        local adj = grid:adjacencies()
        expect_type("table", adj)
        expect_true(#adj >= 2)
    end)

    -- @covers LProvinceGrid:borderSegments
    it("borderSegments returns segment geometry for a fixture map", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        expect_type("table", grid:borderSegments())
    end)

    -- @covers LProvinceGrid:deserializeShapeData
    it("deserializeShapeData restores serialized province geometry", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        local decoded = grid:deserializeShapeData(grid:serializeShapeData())
        expect_not_nil(decoded)
        expect_type("table", decoded)
    end)

    -- @covers LProvinceGrid:drawShapes
    it("drawShapes returns a numeric draw count", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        expect_type("number", grid:drawShapes())
    end)

    -- @covers LProvinceGrid:getAt
    it("getAt returns province ids for colored regions and zero for empty space", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        local red = grid:getAt(0, 0)
        local green = grid:getAt(2, 0)
        local blue = grid:getAt(0, 2)
        expect_true(red > 0)
        expect_true(green > 0)
        expect_true(blue > 0)
        expect_true(red ~= green)
        expect_equal(0, grid:getAt(0, 3))
    end)

    -- @covers LProvinceGrid:getHeight
    it("getHeight reports province grid height", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        expect_equal(4, grid:getHeight())
    end)

    -- @covers LProvinceGrid:getPolygons
    it("getPolygons returns polygon tables", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        expect_type("table", grid:getPolygons())
    end)

    -- @covers LProvinceGrid:getPolygonsSimplified
    it("getPolygonsSimplified returns simplified polygon tables", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        expect_type("table", grid:getPolygonsSimplified())
    end)

    -- @covers LProvinceGrid:getWidth
    it("getWidth reports province grid width", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        expect_equal(4, grid:getWidth())
    end)

    -- @covers LProvinceGrid:provinceCount
    it("provinceCount returns the number of colored provinces", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        expect_equal(3, grid:provinceCount())
    end)

    -- @covers LProvinceGrid:provinceSpans
    it("provinceSpans returns span tables for the fixture map", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        expect_type("table", grid:provinceSpans())
    end)

    -- @covers LProvinceGrid:serializeShapeData
    it("serializeShapeData returns a non-empty blob", function()
        local grid = lurek.image.newProvinceGrid(PROVINCE_FIXTURE)
        local blob = grid:serializeShapeData()
        expect_type("string", blob)
        expect_true(#blob > 0)
    end)

    -- @covers LProvinceGrid:type
    it("type returns a userdata type name", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        expect_type("string", grid:type())
    end)

    -- @covers LProvinceGrid:typeOf
    it("typeOf is callable and returns a boolean", function()
        local grid = lurek.image.newProvinceGrid(write_small_province_map())
        expect_type("boolean", grid:typeOf("LObject"))
    end)
end)
end
-- END test_image_core_unit.lua

test_summary()
