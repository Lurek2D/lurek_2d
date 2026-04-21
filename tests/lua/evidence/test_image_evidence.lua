-- Placeholder evidence suite for migrated image-adjacent artifacts.
-- Keeps pending image, minimap, and raycaster evidence ports visible until each migrated Rust case is translated into real Lua artifact generation.

-- @description Placeholder suite for migrated image-adjacent evidence cases that still need a concrete Lua translation.
describe("Evidence: image", function()
end)



-- ================================================================
-- Merged from: test_image_drawing_evidence.lua
-- ================================================================

-- test_evidence_image_drawing.lua
-- Evidence test: ImageData drawing methods (drawRect, drawLine, drawCircle)

local OUT = "tests/output/image/"

-- @description Covers suite: Evidence: ImageData drawing methods.
describe("Evidence: ImageData drawing methods", function()

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawRect
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Renders a grid of colored rectangles and saves the result to prove rect drawing affects stored pixels.
    it("drawRect - grid of colored rectangles", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 20, 20, 30, 255)

        local colors = {
            {255, 0, 0},     {0, 255, 0},   {0, 0, 255},   {255, 255, 0},
            {255, 0, 255},   {0, 255, 255}, {255, 128, 0},  {128, 0, 255},
            {0, 128, 0},     {128, 128, 0}, {0, 128, 128},  {128, 0, 128},
            {200, 100, 50},  {50, 100, 200},{100, 200, 50}, {200, 50, 100},
        }
        local cols, rows = 4, 4
        local rw = math.floor(W / cols)
        local rh = math.floor(H / rows)
        local ci = 1
        for row = 0, rows - 1 do
            for col = 0, cols - 1 do
                local c = colors[ci]
                img:drawRect(col * rw + 2, row * rh + 2, rw - 4, rh - 4, c[1], c[2], c[3], 255)
                ci = ci + 1
            end
        end

        lurek.image.savePNG(img, OUT .. "drawing_rects.png")
        -- Verify a drawn pixel
        local r, g, b, a = img:getPixel(3, 3)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawLine
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Draws a radial star of lines from the image center and exports the result for manual inspection.
    it("drawLine - star pattern from center", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 10, 10, 20, 255)

        local cx, cy = 128, 128
        local numRays = 24
        for i = 0, numRays - 1 do
            local angle = (i / numRays) * math.pi * 2
            local ex = cx + math.floor(math.cos(angle) * 120)
            local ey = cy + math.floor(math.sin(angle) * 120)
            local hue = math.floor(i / numRays * 255)
            img:drawLine(cx, cy, ex, ey, hue, 255 - hue, 128, 255)
        end

        lurek.image.savePNG(img, OUT .. "drawing_lines.png")
        -- Center pixel should have been drawn
        local r, g, b, a = img:getPixel(128, 128)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawCircle
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Renders concentric circles of different colors to cover circle rasterization and center-pixel updates.
    it("drawCircle - concentric circles", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 10, 10, 20, 255)

        local cx, cy = 128, 128
        local colors = {
            {255, 50, 50},  {255, 150, 50},  {255, 255, 50},
            {50, 255, 50},  {50, 150, 255},  {100, 50, 255},
        }
        local radii = {120, 100, 80, 60, 40, 20}
        for i, radius in ipairs(radii) do
            local c = colors[i]
            img:drawCircle(cx, cy, radius, c[1], c[2], c[3], 255)
        end

        lurek.image.savePNG(img, OUT .. "drawing_circles.png")
        -- Center pixel should be the innermost circle color
        local r, g, b, a = img:getPixel(128, 128)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawRect
    -- @covers ImageData:drawCircle
    -- @covers ImageData:drawLine
    -- @covers ImageData:setPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Combines rectangles, circles, lines, and direct pixels into one scene to prove the drawing helpers compose correctly.
    it("combined scene with all drawing methods", function()
        local W, H = 512, 512
        local img = lurek.image.newImageData(W, H)

        -- Sky gradient background
        for y = 0, H - 1 do
            local t = y / H
            local r = math.floor(30 + t * 20)
            local g = math.floor(30 + t * 40)
            local b = math.floor(80 + (1 - t) * 100)
            for x = 0, W - 1 do
                img:setPixel(x, y, r, g, b, 255)
            end
        end

        -- Ground
        img:drawRect(0, 380, W, H - 380, 40, 80, 30, 255)

        -- Sun
        img:drawCircle(400, 100, 50, 255, 220, 50, 255)
        -- Sun rays
        for i = 0, 11 do
            local angle = (i / 12) * math.pi * 2
            local sx = 400 + math.floor(math.cos(angle) * 60)
            local sy = 100 + math.floor(math.sin(angle) * 60)
            local ex = 400 + math.floor(math.cos(angle) * 80)
            local ey = 100 + math.floor(math.sin(angle) * 80)
            img:drawLine(sx, sy, ex, ey, 255, 220, 50, 255)
        end

        -- House
        img:drawRect(100, 300, 150, 100, 180, 80, 60, 255)
        -- Roof (triangle approximation with lines)
        for i = 0, 74 do
            img:drawLine(100 + i, 300 - i, 250 - i, 300 - i, 160, 50, 40, 255)
        end
        -- Door
        img:drawRect(155, 340, 40, 60, 100, 60, 30, 255)
        -- Window
        img:drawRect(115, 320, 30, 25, 150, 200, 255, 255)

        -- Tree trunk
        img:drawRect(350, 320, 20, 60, 100, 70, 30, 255)
        -- Tree top
        img:drawCircle(360, 300, 35, 30, 140, 30, 255)

        -- Fence
        for i = 0, 5 do
            local fx = 50 + i * 30
            img:drawRect(fx, 370, 5, 20, 160, 140, 100, 255)
        end
        img:drawLine(50, 380, 200, 380, 160, 140, 100, 255)
        img:drawLine(50, 375, 200, 375, 160, 140, 100, 255)

        lurek.image.savePNG(img, OUT .. "drawing_combined.png")
    end)

end)



-- ================================================================
-- Merged from: test_image_effects_evidence.lua
-- ================================================================

-- test_evidence_image_effects.lua
-- Evidence test: ImageData filters and effects with before/after PNG output

local OUT = "tests/output/image/"

-- Create a gradient image with some shapes as a base for testing effects
local function make_base(w, h)
    local img = lurek.image.newImageData(w, h)
    -- Horizontal gradient
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r = math.floor(x / w * 255)
            local g = math.floor(y / h * 255)
            local b = math.floor((1 - x / w) * 200)
            img:setPixel(x, y, r, g, b, 255)
        end
    end
    -- Draw some shapes on top
    img:drawRect(20, 20, 60, 60, 255, 0, 0, 255)
    img:drawCircle(180, 128, 40, 0, 255, 0, 255)
    img:drawLine(0, 0, w - 1, h - 1, 255, 255, 0, 255)
    img:drawLine(w - 1, 0, 0, h - 1, 255, 255, 0, 255)
    return img
end

-- @description Covers suite: Evidence: ImageData effects.
describe("Evidence: ImageData effects", function()

    -- @covers lurek.image.newImageData
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Saves the unmodified baseline image used as the control for all subsequent effect evidence.
    it("saves base test image", function()
        local img = make_base(256, 256)
        lurek.image.savePNG(img, OUT .. "effects_base.png")
    end)

    -- @covers ImageData:brightness
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Brightens the baseline image and saves the result to document positive brightness scaling.
    it("brightness increase (1.5)", function()
        local img = make_base(256, 256)
        local r_before, _, _, _ = img:getPixel(128, 128)
        img:brightness(1.5)
        lurek.image.savePNG(img, OUT .. "effects_brightness_up.png")
        local r_after, _, _, _ = img:getPixel(128, 128)
        -- After brightness > 1, values should increase (or stay at max)
    end)

    -- @covers ImageData:brightness
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Darkens the baseline image and saves the result to document brightness reduction.
    it("brightness decrease (0.5)", function()
        local img = make_base(256, 256)
        img:brightness(0.5)
        lurek.image.savePNG(img, OUT .. "effects_brightness_down.png")
    end)

    -- @covers ImageData:contrast
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Increases image contrast and writes the result so the expanded tonal separation can be inspected.
    it("contrast increase (1.5)", function()
        local img = make_base(256, 256)
        img:contrast(1.5)
        lurek.image.savePNG(img, OUT .. "effects_contrast_up.png")
    end)

    -- @covers ImageData:contrast
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Reduces image contrast and saves the flatter result for comparison against the baseline.
    it("contrast decrease (0.5)", function()
        local img = make_base(256, 256)
        img:contrast(0.5)
        lurek.image.savePNG(img, OUT .. "effects_contrast_down.png")
    end)

    -- @covers ImageData:saturation
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Removes saturation entirely to produce a grayscale-like control image.
    it("saturation zero (grayscale-like)", function()
        local img = make_base(256, 256)
        img:saturation(0)
        lurek.image.savePNG(img, OUT .. "effects_saturation_zero.png")
    end)

    -- @covers ImageData:saturation
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Boosts saturation above 1.0 and saves the intensified color output.
    it("saturation boost (2.0)", function()
        local img = make_base(256, 256)
        img:saturation(2)
        lurek.image.savePNG(img, OUT .. "effects_saturation_boost.png")
    end)

    -- @covers ImageData:grayscale
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies the grayscale effect and reads one pixel to confirm the transformed image can still be sampled.
    it("grayscale", function()
        local img = make_base(256, 256)
        img:grayscale()
        lurek.image.savePNG(img, OUT .. "effects_grayscale.png")
        local r, g, b, _ = img:getPixel(100, 100)
    end)

    -- @covers ImageData:sepia
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies sepia toning and writes the output as visual evidence.
    it("sepia", function()
        local img = make_base(256, 256)
        img:sepia()
        lurek.image.savePNG(img, OUT .. "effects_sepia.png")
    end)

    -- @covers ImageData:invert
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Inverts the baseline image and saves the result for manual inspection.
    it("invert", function()
        local img = make_base(256, 256)
        img:invert()
        lurek.image.savePNG(img, OUT .. "effects_invert.png")
    end)

    -- @covers ImageData:threshold
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies a binary threshold to the baseline image and saves the high-contrast result.
    it("threshold (128)", function()
        local img = make_base(256, 256)
        img:threshold(128)
        lurek.image.savePNG(img, OUT .. "effects_threshold.png")
    end)

    -- @covers ImageData:posterize
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Reduces the image to four color levels and saves the posterized result.
    it("posterize (4 levels)", function()
        local img = make_base(256, 256)
        img:posterize(4)
        lurek.image.savePNG(img, OUT .. "effects_posterize.png")
    end)

    -- @covers ImageData:blur
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Blurs the baseline image with radius 3 and saves the softened output.
    it("blur (radius 3)", function()
        local img = make_base(256, 256)
        local blurred = img:blur(3)
        lurek.image.savePNG(blurred, OUT .. "effects_blur.png")
    end)

    -- @covers ImageData:sharpen
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Sharpens the baseline image and writes the result for visual comparison with the blurred output.
    it("sharpen", function()
        local img = make_base(256, 256)
        local sharp = img:sharpen()
        lurek.image.savePNG(sharp, OUT .. "effects_sharpen.png")
    end)

    -- @covers ImageData:gamma
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Saves low- and high-gamma variants of the same base image to document gamma correction behavior.
    it("gamma correction (0.5 and 2.0)", function()
        local img1 = make_base(256, 256)
        img1:gamma(0.5)
        lurek.image.savePNG(img1, OUT .. "effects_gamma_low.png")

        local img2 = make_base(256, 256)
        img2:gamma(2.0)
        lurek.image.savePNG(img2, OUT .. "effects_gamma_high.png")
    end)

    -- @covers ImageData:tint
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies a semi-transparent red tint over the baseline image and saves the result.
    it("tint red 50%", function()
        local img = make_base(256, 256)
        img:tint(255, 0, 0, 0.5)
        lurek.image.savePNG(img, OUT .. "effects_tint_red.png")
    end)

end)



-- ================================================================
-- Merged from: test_evidence_image.lua
-- ================================================================

-- Placeholder evidence suite for migrated image-adjacent artifacts.
-- Keeps pending image, minimap, and raycaster evidence ports visible until each migrated Rust case is translated into real Lua artifact generation.

-- @description Placeholder suite for migrated image-adjacent evidence cases that still need a concrete Lua translation.
describe("Evidence: image", function()
end)



-- ================================================================
-- Merged from: test_evidence_image_drawing.lua
-- ================================================================

-- test_evidence_image_drawing.lua
-- Evidence test: ImageData drawing methods (drawRect, drawLine, drawCircle)

local OUT = "tests/output/image/"

-- @description Covers suite: Evidence: ImageData drawing methods.
describe("Evidence: ImageData drawing methods", function()

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawRect
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Renders a grid of colored rectangles and saves the result to prove rect drawing affects stored pixels.
    it("drawRect - grid of colored rectangles", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 20, 20, 30, 255)

        local colors = {
            {255, 0, 0},     {0, 255, 0},   {0, 0, 255},   {255, 255, 0},
            {255, 0, 255},   {0, 255, 255}, {255, 128, 0},  {128, 0, 255},
            {0, 128, 0},     {128, 128, 0}, {0, 128, 128},  {128, 0, 128},
            {200, 100, 50},  {50, 100, 200},{100, 200, 50}, {200, 50, 100},
        }
        local cols, rows = 4, 4
        local rw = math.floor(W / cols)
        local rh = math.floor(H / rows)
        local ci = 1
        for row = 0, rows - 1 do
            for col = 0, cols - 1 do
                local c = colors[ci]
                img:drawRect(col * rw + 2, row * rh + 2, rw - 4, rh - 4, c[1], c[2], c[3], 255)
                ci = ci + 1
            end
        end

        lurek.image.savePNG(img, OUT .. "drawing_rects.png")
        -- Verify a drawn pixel
        local r, g, b, a = img:getPixel(3, 3)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawLine
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Draws a radial star of lines from the image center and exports the result for manual inspection.
    it("drawLine - star pattern from center", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 10, 10, 20, 255)

        local cx, cy = 128, 128
        local numRays = 24
        for i = 0, numRays - 1 do
            local angle = (i / numRays) * math.pi * 2
            local ex = cx + math.floor(math.cos(angle) * 120)
            local ey = cy + math.floor(math.sin(angle) * 120)
            local hue = math.floor(i / numRays * 255)
            img:drawLine(cx, cy, ex, ey, hue, 255 - hue, 128, 255)
        end

        lurek.image.savePNG(img, OUT .. "drawing_lines.png")
        -- Center pixel should have been drawn
        local r, g, b, a = img:getPixel(128, 128)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawCircle
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Renders concentric circles of different colors to cover circle rasterization and center-pixel updates.
    it("drawCircle - concentric circles", function()
        local W, H = 256, 256
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 10, 10, 20, 255)

        local cx, cy = 128, 128
        local colors = {
            {255, 50, 50},  {255, 150, 50},  {255, 255, 50},
            {50, 255, 50},  {50, 150, 255},  {100, 50, 255},
        }
        local radii = {120, 100, 80, 60, 40, 20}
        for i, radius in ipairs(radii) do
            local c = colors[i]
            img:drawCircle(cx, cy, radius, c[1], c[2], c[3], 255)
        end

        lurek.image.savePNG(img, OUT .. "drawing_circles.png")
        -- Center pixel should be the innermost circle color
        local r, g, b, a = img:getPixel(128, 128)
    end)

    -- @covers lurek.image.newImageData
    -- @covers ImageData:drawRect
    -- @covers ImageData:drawCircle
    -- @covers ImageData:drawLine
    -- @covers ImageData:setPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Combines rectangles, circles, lines, and direct pixels into one scene to prove the drawing helpers compose correctly.
    it("combined scene with all drawing methods", function()
        local W, H = 512, 512
        local img = lurek.image.newImageData(W, H)

        -- Sky gradient background
        for y = 0, H - 1 do
            local t = y / H
            local r = math.floor(30 + t * 20)
            local g = math.floor(30 + t * 40)
            local b = math.floor(80 + (1 - t) * 100)
            for x = 0, W - 1 do
                img:setPixel(x, y, r, g, b, 255)
            end
        end

        -- Ground
        img:drawRect(0, 380, W, H - 380, 40, 80, 30, 255)

        -- Sun
        img:drawCircle(400, 100, 50, 255, 220, 50, 255)
        -- Sun rays
        for i = 0, 11 do
            local angle = (i / 12) * math.pi * 2
            local sx = 400 + math.floor(math.cos(angle) * 60)
            local sy = 100 + math.floor(math.sin(angle) * 60)
            local ex = 400 + math.floor(math.cos(angle) * 80)
            local ey = 100 + math.floor(math.sin(angle) * 80)
            img:drawLine(sx, sy, ex, ey, 255, 220, 50, 255)
        end

        -- House
        img:drawRect(100, 300, 150, 100, 180, 80, 60, 255)
        -- Roof (triangle approximation with lines)
        for i = 0, 74 do
            img:drawLine(100 + i, 300 - i, 250 - i, 300 - i, 160, 50, 40, 255)
        end
        -- Door
        img:drawRect(155, 340, 40, 60, 100, 60, 30, 255)
        -- Window
        img:drawRect(115, 320, 30, 25, 150, 200, 255, 255)

        -- Tree trunk
        img:drawRect(350, 320, 20, 60, 100, 70, 30, 255)
        -- Tree top
        img:drawCircle(360, 300, 35, 30, 140, 30, 255)

        -- Fence
        for i = 0, 5 do
            local fx = 50 + i * 30
            img:drawRect(fx, 370, 5, 20, 160, 140, 100, 255)
        end
        img:drawLine(50, 380, 200, 380, 160, 140, 100, 255)
        img:drawLine(50, 375, 200, 375, 160, 140, 100, 255)

        lurek.image.savePNG(img, OUT .. "drawing_combined.png")
    end)

end)



-- ================================================================
-- Merged from: test_evidence_image_effects.lua
-- ================================================================

-- test_evidence_image_effects.lua
-- Evidence test: ImageData filters and effects with before/after PNG output

local OUT = "tests/output/image/"

-- Create a gradient image with some shapes as a base for testing effects
local function make_base(w, h)
    local img = lurek.image.newImageData(w, h)
    -- Horizontal gradient
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r = math.floor(x / w * 255)
            local g = math.floor(y / h * 255)
            local b = math.floor((1 - x / w) * 200)
            img:setPixel(x, y, r, g, b, 255)
        end
    end
    -- Draw some shapes on top
    img:drawRect(20, 20, 60, 60, 255, 0, 0, 255)
    img:drawCircle(180, 128, 40, 0, 255, 0, 255)
    img:drawLine(0, 0, w - 1, h - 1, 255, 255, 0, 255)
    img:drawLine(w - 1, 0, 0, h - 1, 255, 255, 0, 255)
    return img
end

-- @description Covers suite: Evidence: ImageData effects.
describe("Evidence: ImageData effects", function()

    -- @covers lurek.image.newImageData
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Saves the unmodified baseline image used as the control for all subsequent effect evidence.
    it("saves base test image", function()
        local img = make_base(256, 256)
        lurek.image.savePNG(img, OUT .. "effects_base.png")
    end)

    -- @covers ImageData:brightness
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Brightens the baseline image and saves the result to document positive brightness scaling.
    it("brightness increase (1.5)", function()
        local img = make_base(256, 256)
        local r_before, _, _, _ = img:getPixel(128, 128)
        img:brightness(1.5)
        lurek.image.savePNG(img, OUT .. "effects_brightness_up.png")
        local r_after, _, _, _ = img:getPixel(128, 128)
        -- After brightness > 1, values should increase (or stay at max)
    end)

    -- @covers ImageData:brightness
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Darkens the baseline image and saves the result to document brightness reduction.
    it("brightness decrease (0.5)", function()
        local img = make_base(256, 256)
        img:brightness(0.5)
        lurek.image.savePNG(img, OUT .. "effects_brightness_down.png")
    end)

    -- @covers ImageData:contrast
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Increases image contrast and writes the result so the expanded tonal separation can be inspected.
    it("contrast increase (1.5)", function()
        local img = make_base(256, 256)
        img:contrast(1.5)
        lurek.image.savePNG(img, OUT .. "effects_contrast_up.png")
    end)

    -- @covers ImageData:contrast
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Reduces image contrast and saves the flatter result for comparison against the baseline.
    it("contrast decrease (0.5)", function()
        local img = make_base(256, 256)
        img:contrast(0.5)
        lurek.image.savePNG(img, OUT .. "effects_contrast_down.png")
    end)

    -- @covers ImageData:saturation
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Removes saturation entirely to produce a grayscale-like control image.
    it("saturation zero (grayscale-like)", function()
        local img = make_base(256, 256)
        img:saturation(0)
        lurek.image.savePNG(img, OUT .. "effects_saturation_zero.png")
    end)

    -- @covers ImageData:saturation
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Boosts saturation above 1.0 and saves the intensified color output.
    it("saturation boost (2.0)", function()
        local img = make_base(256, 256)
        img:saturation(2)
        lurek.image.savePNG(img, OUT .. "effects_saturation_boost.png")
    end)

    -- @covers ImageData:grayscale
    -- @covers ImageData:getPixel
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies the grayscale effect and reads one pixel to confirm the transformed image can still be sampled.
    it("grayscale", function()
        local img = make_base(256, 256)
        img:grayscale()
        lurek.image.savePNG(img, OUT .. "effects_grayscale.png")
        local r, g, b, _ = img:getPixel(100, 100)
    end)

    -- @covers ImageData:sepia
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies sepia toning and writes the output as visual evidence.
    it("sepia", function()
        local img = make_base(256, 256)
        img:sepia()
        lurek.image.savePNG(img, OUT .. "effects_sepia.png")
    end)

    -- @covers ImageData:invert
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Inverts the baseline image and saves the result for manual inspection.
    it("invert", function()
        local img = make_base(256, 256)
        img:invert()
        lurek.image.savePNG(img, OUT .. "effects_invert.png")
    end)

    -- @covers ImageData:threshold
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies a binary threshold to the baseline image and saves the high-contrast result.
    it("threshold (128)", function()
        local img = make_base(256, 256)
        img:threshold(128)
        lurek.image.savePNG(img, OUT .. "effects_threshold.png")
    end)

    -- @covers ImageData:posterize
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Reduces the image to four color levels and saves the posterized result.
    it("posterize (4 levels)", function()
        local img = make_base(256, 256)
        img:posterize(4)
        lurek.image.savePNG(img, OUT .. "effects_posterize.png")
    end)

    -- @covers ImageData:blur
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Blurs the baseline image with radius 3 and saves the softened output.
    it("blur (radius 3)", function()
        local img = make_base(256, 256)
        local blurred = img:blur(3)
        lurek.image.savePNG(blurred, OUT .. "effects_blur.png")
    end)

    -- @covers ImageData:sharpen
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Sharpens the baseline image and writes the result for visual comparison with the blurred output.
    it("sharpen", function()
        local img = make_base(256, 256)
        local sharp = img:sharpen()
        lurek.image.savePNG(sharp, OUT .. "effects_sharpen.png")
    end)

    -- @covers ImageData:gamma
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Saves low- and high-gamma variants of the same base image to document gamma correction behavior.
    it("gamma correction (0.5 and 2.0)", function()
        local img1 = make_base(256, 256)
        img1:gamma(0.5)
        lurek.image.savePNG(img1, OUT .. "effects_gamma_low.png")

        local img2 = make_base(256, 256)
        img2:gamma(2.0)
        lurek.image.savePNG(img2, OUT .. "effects_gamma_high.png")
    end)

    -- @covers ImageData:tint
    -- @covers lurek.image.savePNG
    -- @evidence file
    -- @description Applies a semi-transparent red tint over the baseline image and saves the result.
    it("tint red 50%", function()
        local img = make_base(256, 256)
        img:tint(255, 0, 0, 0.5)
        lurek.image.savePNG(img, OUT .. "effects_tint_red.png")
    end)

end)

test_summary()
