--- Image Module Part 2: LImageData transforms and filters

--@api-stub: LImageData:resize
-- Returns a resized copy using bilinear filter.
do
    local img = lurek.image.newImageData(64, 64)
    local resized = img:resize(128, 128, "bilinear")
    print("resized = " .. resized:getWidth() .. "x" .. resized:getHeight())
end

--@api-stub: LImageData:resizeNearest
-- Returns a resized copy using nearest-neighbor.
do
    local img = lurek.image.newImageData(32, 32)
    local resized = img:resizeNearest(64, 64)
    print("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight())
end

--@api-stub: LImageData:rotate90cw
-- Returns a 90-degree clockwise rotation.
do
    local img = lurek.image.newImageData(20, 40)
    local rotated = img:rotate90cw()
    print("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight())
end

--@api-stub: LImageData:blur
-- Returns a blurred copy.
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(1, 0, 0, 1)
    local blurred = img:blur(3)
    print("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight())
end

--@api-stub: LImageData:sharpen
-- Returns a sharpened copy.
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(0.5, 0.5, 0.5, 1)
    local sharp = img:sharpen()
    print("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight())
end

--@api-stub: LImageData:convolve
-- Returns convolved copy using a custom kernel.
do
    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    print("convolved " .. result:getWidth() .. "x" .. result:getHeight())
end

--@api-stub: LImageData:grayscale
-- Converts image to grayscale in place.
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(1, 0, 0, 1)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    print("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api-stub: LImageData:invert
-- Inverts all pixel colors in place.
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(1, 0, 0, 1)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    print("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end

--@api-stub: LImageData:sepia
-- Applies sepia tone in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:sepia()
    print("sepia applied")
end

--@api-stub: LImageData:noise
-- Adds random noise in place.
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(0.5, 0.5, 0.5, 1)
    img:noise(0.1)
    print("noise added")
end

--@api-stub: LImageData:posterize
-- Reduces color levels in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.7, 0.3, 0.5, 1)
    img:posterize(4)
    print("posterized to 4 levels")
end

--@api-stub: LImageData:threshold
-- Converts to binary black/white in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.6, 0.6, 0.6, 1)
    img:threshold(0.5)
    print("thresholded at 0.5")
end

--@api-stub: LImageData:brightness
-- Adjusts brightness in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:brightness(1.5)
    print("brightness increased by 1.5x")
end

--@api-stub: LImageData:contrast
-- Adjusts contrast in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.4, 0.6, 0.5, 1)
    img:contrast(2.0)
    print("contrast doubled")
end

--@api-stub: LImageData:saturation
-- Adjusts saturation in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 0, 0, 1)
    img:saturation(0.5)
    print("saturation halved")
end

--@api-stub: LImageData:gamma
-- Applies gamma correction in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0.5, 0.5, 0.5, 1)
    img:gamma(2.2)
    print("gamma 2.2 applied")
end

--@api-stub: LImageData:tint
-- Applies a color tint in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 1, 1, 1)
    img:tint(1, 0, 0, 0.5)
    print("red tint applied at 50%")
end

--@api-stub: LImageData:alphaMask
-- Modifies alpha channel by a factor.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 0, 0, 1)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    print("alpha = " .. a)
end

--@api-stub: LImageData:flipHorizontal
-- Flips the image horizontally in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 1, 0, 0, 1)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    print("flipped h, corner r = " .. r)
end

--@api-stub: LImageData:flipVertical
-- Flips the image vertically in place.
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 1, 0, 1)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    print("flipped v, corner g = " .. g)
end

--@api-stub: LImageData:mapPixel
-- Transforms each pixel via a callback.
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(1, 1, 1, 1)
    img:mapPixel(function(x, y, r, g, b, a)
        return r * 0.5, g * 0.5, b * 0.5, a
    end)
    print("mapped pixels to half brightness")
end

--@api-stub: LImageData:mapPixels
-- Transforms all pixels via a callback (batch).
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 0, 1)
    img:mapPixels(function(x, y, r, g, b, a)
        return x / 8, y / 8, 0, 1
    end)
    print("gradient mapped")
end

--@api-stub: LImageData:drawNineSlice
-- Draws a 9-slice region from a source image.
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(32, 32)
    src:fill(0.5, 0.5, 0.5, 1)
    dst:drawNineSlice(src, 0, 0, 32, 32, 0, 0, 64, 64, 8, 8, 8, 8)
    print("nine-slice drawn")
end

--@api-stub: LImageData:applyPaletteLut
-- Remaps colors using a palette lookup table.
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(1, 0, 0, 1)
    local lut = lurek.image.newPaletteLut()
    lut:setColor(1, 0, 0, 1, 0, 1, 0, 1)
    img:applyPaletteLut(lut)
    local r, g, _, _ = img:getPixel(0, 0)
    print("after LUT r=" .. r .. " g=" .. g)
end

--@api-stub: LImageData:diff
-- Computes pixel-level difference score.
do
    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    a:fill(1, 0, 0, 1)
    b:fill(0, 1, 0, 1)
    local score = a:diff(b)
    print("diff score = " .. score)
end

print("image_01.lua")
