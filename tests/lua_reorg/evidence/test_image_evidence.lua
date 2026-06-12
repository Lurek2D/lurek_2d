-- test_image_evidence.lua
-- Canonical evidence file for lurek.image visual outputs.

local OUT = evidence_output_dir("image")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

-- @describe Evidence: image
describe("Evidence: image", function()
    before_each(function()
        ensure_evidence_dir("image")
    end)

    local function make_base(w, h)
        local img = lurek.image.newImageData(w, h)
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local r = math.floor(x / (w - 1) * 255)
                local g = math.floor(y / (h - 1) * 255)
                local b = math.floor((1 - x / (w - 1)) * 220)
                img:setPixel(x, y, r, g, b, 255)
            end
        end
        img:drawRect(20, 20, 64, 64, 240, 70, 60, 255)
        img:drawCircle(math.floor(w * 0.7), math.floor(h * 0.6), 38, 70, 220, 90, 255)
        img:drawLine(0, 0, w - 1, h - 1, 255, 255, 120, 255)
        return img
    end

    -- @evidence LImageData:drawRect
    -- @evidence LImageData:drawCircle
    -- @evidence LImageData:drawLine
    -- @evidence lurek.image.savePNG
    it("PNG: drawing primitives scene", function()
        local img = make_base(256, 256)
        local path = OUT .. "image_drawing_primitives_scene.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:grayscale
    -- @evidence LImageData:invert
    -- @evidence LImageData:posterize
    -- @evidence lurek.image.savePNG
    it("PNG: effects strip", function()
        local cell = 96
        local canvas = lurek.image.newImageData(cell * 4, cell)
        canvas:fill(20, 20, 24, 255)

        local a = make_base(cell, cell)
        local b = make_base(cell, cell)
        b:grayscale()
        local c = make_base(cell, cell)
        c:invert()
        local d = make_base(cell, cell)
        d:posterize(4)

        canvas:paste(a, 0, 0)
        canvas:paste(b, cell, 0)
        canvas:paste(c, cell * 2, 0)
        canvas:paste(d, cell * 3, 0)

        local path = OUT .. "image_effects_variant_strip.png"
        save_png(canvas, path)
    end)

    -- @evidence LImageData:crop
    -- @evidence LImageData:blur
    -- @evidence LImageData:sharpen
    -- @evidence lurek.image.savePNG
    it("PNG: blur and sharpen pair", function()
        local base = make_base(256, 128)
        local left = base:crop(0, 0, 128, 128)
        local right = base:crop(128, 0, 128, 128)

        left:blur(3)
        right:sharpen()

        local out = lurek.image.newImageData(256, 128)
        out:paste(left, 0, 0)
        out:paste(right, 128, 0)

        local path = OUT .. "image_blur_sharpen_pair.png"
        save_png(out, path)
    end)

    -- @evidence LImageData:flipHorizontal
    -- @evidence LImageData:flipVertical
    -- @evidence LImageData:rotate90cw
    -- @evidence lurek.image.savePNG
    it("PNG: transform atlas with flips and rotation", function()
        local cell = 96
        local canvas = lurek.image.newImageData(cell * 4, cell)
        canvas:fill(20, 20, 24, 255)

        local a = make_base(cell, cell)
        local b = make_base(cell, cell)
        b:flipHorizontal()
        local c = make_base(cell, cell)
        c:flipVertical()
        local d = make_base(cell, cell):rotate90cw()
        d = d:resizeNearest(cell, cell)

        canvas:paste(a, 0, 0)
        canvas:paste(b, cell, 0)
        canvas:paste(c, cell * 2, 0)
        canvas:paste(d, cell * 3, 0)

        local path = OUT .. "transform_atlas.png"
        save_png(canvas, path)
    end)

    -- @evidence LImageData:resize
    -- @evidence LImageData:resizeNearest
    -- @evidence LImageData:threshold
    -- @evidence lurek.image.savePNG
    it("PNG: resize and threshold comparison atlas", function()
        local base = make_base(128, 128)
        local smooth = base:resize(96, 96, "bilinear")
        local nearest = base:resizeNearest(96, 96)
        local thresholded = make_base(96, 96)
        thresholded:threshold(128)

        local canvas = lurek.image.newImageData(96 * 3, 96)
        canvas:fill(16, 18, 22, 255)
        canvas:paste(smooth, 0, 0)
        canvas:paste(nearest, 96, 0)
        canvas:paste(thresholded, 192, 0)

        local path = OUT .. "resize_threshold_atlas.png"
        save_png(canvas, path)
    end)
end)

-- @describe Evidence: lurek.image fixture atlas outputs
describe("Evidence: lurek.image fixture atlas outputs", function()
    before_each(function()
        ensure_evidence_dir("image")
    end)

    -- @evidence lurek.image.newImageData
    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: sprite_8x8.png -- compact pixel sprite fixture", function()
        local img = lurek.image.newImageData(8, 8)
        img:fill(0, 0, 0, 0)
        img:setPixel(2, 2, 255, 255, 255, 255)
        img:setPixel(5, 2, 255, 255, 255, 255)
        img:setPixel(2, 5, 255, 255, 255, 255)
        img:setPixel(3, 6, 255, 255, 255, 255)
        img:setPixel(4, 6, 255, 255, 255, 255)
        img:setPixel(5, 5, 255, 255, 255, 255)

        local path = OUT .. "sprite_8x8.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: sprite_16x16.png -- orthogonal cross sprite fixture", function()
        local img = lurek.image.newImageData(16, 16)
        for i = 0, 15 do
            img:setPixel(7, i, 255, 0, 0, 255)
            img:setPixel(8, i, 255, 0, 0, 255)
            img:setPixel(i, 7, 0, 0, 255, 255)
            img:setPixel(i, 8, 0, 0, 255, 255)
        end

        local path = OUT .. "sprite_16x16.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: sprite_32x32.png -- radial alpha sprite fixture", function()
        local img = lurek.image.newImageData(32, 32)
        for y = 0, 31 do
            for x = 0, 31 do
                local dx = x - 15.5
                local dy = y - 15.5
                local dist = math.sqrt(dx * dx + dy * dy)
                local alpha = 255 - math.min(255, math.floor(dist * 16))
                img:setPixel(x, y, 0, 255, 0, alpha)
            end
        end

        local path = OUT .. "sprite_32x32.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: sprite_64x64.png -- checkerboard sprite fixture", function()
        local img = lurek.image.newImageData(64, 64)
        for y = 0, 63 do
            for x = 0, 63 do
                local checker = (math.floor(x / 8) + math.floor(y / 8)) % 2 == 0
                if checker then
                    img:setPixel(x, y, 200, 200, 200, 255)
                else
                    img:setPixel(x, y, 50, 50, 50, 255)
                end
            end
        end

        local path = OUT .. "sprite_64x64.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: tileset_128x128.png -- tileset color swatch sheet", function()
        local img = lurek.image.newImageData(128, 128)
        for ty = 0, 7 do
            for tx = 0, 7 do
                local r = tx * 36
                local g = ty * 36
                local b = 128
                for y = 0, 15 do
                    for x = 0, 15 do
                        img:setPixel(tx * 16 + x, ty * 16 + y, r, g, b, 255)
                    end
                end
            end
        end

        local path = OUT .. "tileset_128x128.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: gradient_horizontal.png -- horizontal RGB gradient strip", function()
        local img = lurek.image.newImageData(256, 32)
        for y = 0, 31 do
            for x = 0, 255 do
                img:setPixel(x, y, x, 0, 255 - x, 255)
            end
        end

        local path = OUT .. "gradient_horizontal.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:setPixel
    -- @evidence lurek.image.savePNG
    it("PNG: gradient_vertical.png -- vertical RGB gradient strip", function()
        local img = lurek.image.newImageData(32, 256)
        for y = 0, 255 do
            for x = 0, 31 do
                img:setPixel(x, y, 0, y, 255 - y, 255)
            end
        end

        local path = OUT .. "gradient_vertical.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:brightness
    -- @evidence LImageData:contrast
    -- @evidence LImageData:grayscale
    -- @evidence LImageData:sepia
    -- @evidence LImageData:invert
    -- @evidence LImageData:threshold
    -- @evidence LImageData:posterize
    -- @evidence LImageData:tint
    -- @evidence LImageData:saturation
    -- @evidence LImageData:gamma
    -- @evidence LImageData:noise
    -- @evidence LImageData:alphaMask
    -- @evidence LImageData:flipHorizontal
    -- @evidence LImageData:flipVertical
    -- @evidence LImageData:rotate90cw
    -- @evidence LImageData:blur
    -- @evidence LImageData:sharpen
    -- @evidence lurek.image.savePNG
    it("PNG: all_effects_grid.png -- image effect gallery grid", function()
        local tile = 64
        local cols = 5
        local rows = 4
        local canvas = lurek.image.newImageData(tile * cols, tile * rows)
        canvas:fill(30, 30, 30, 255)

        local function make_effect_base()
            local img = lurek.image.newImageData(tile, tile)
            for y = 0, tile - 1 do
                for x = 0, tile - 1 do
                    img:setPixel(x, y, x * 4, y * 4, 128, 255)
                end
            end
            return img
        end

        local effects = {
            function(i) return i end,
            function(i) i:brightness(0.3); return i end,
            function(i) i:contrast(2.0); return i end,
            function(i) i:grayscale(); return i end,
            function(i) i:sepia(); return i end,
            function(i) i:invert(); return i end,
            function(i) i:threshold(128); return i end,
            function(i) i:posterize(4); return i end,
            function(i) i:tint(255, 0, 0, 127); return i end,
            function(i) i:saturation(0.0); return i end,
            function(i) i:gamma(0.5); return i end,
            function(i) i:gamma(2.2); return i end,
            function(i) i:noise(60); return i end,
            function(i) i:alphaMask(0.5); return i end,
            function(i) i:flipHorizontal(); return i end,
            function(i) i:flipVertical(); return i end,
            function(i)
                local rotate = i.rotate90cw or i.rotate90Cw or i.rotate90CW
                if type(rotate) == "function" then
                    rotate(i)
                end
                return i
            end,
            function(i) i:blur(2); return i end,
            function(i) i:sharpen(); return i end,
            function(i)
                local cropped = i:crop(8, 8, 48, 48)
                cropped:resizeNearest(tile, tile)
                return cropped
            end,
        }

        for i, apply in ipairs(effects) do
            local base = make_effect_base()
            local result = apply(base)
            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)
            canvas:paste(result, col * tile, row * tile)
        end

        local path = OUT .. "all_effects_grid.png"
        save_png(canvas, path)
    end)
end)

-- @describe Evidence: lurek.image low-level pixel operations
describe("Evidence: lurek.image low-level pixel operations", function()
    before_each(function()
        ensure_evidence_dir("image")
    end)

    -- @evidence lurek.image.newImageData
    -- @evidence LImageData:setPixel
    -- @evidence LImageData:getPixel
    -- @evidence lurek.image.savePNG
    it("PNG: image_pixel_grid.png -- pixel grid from setPixel", function()
        local w, h, cell = 64, 64, 8
        local img = lurek.image.newImageData(w, h)
        img:fill(20, 20, 20, 255)

        for row = 0, math.floor(h / cell) - 1 do
            for col = 0, math.floor(w / cell) - 1 do
                local r = math.floor((row / 7) * 200) + 55
                local g = math.floor((col / 7) * 200) + 55
                for dy = 1, cell - 2 do
                    for dx = 1, cell - 2 do
                        img:setPixel(col * cell + dx, row * cell + dy, r, g, 180, 255)
                    end
                end
            end
        end

        local _, _, _, a = img:getPixel(cell + 1, 1)
        expect_equal(255, a)

        local path = OUT .. "image_pixel_grid.png"
        save_png(img, path)
    end)

    -- @evidence LImageData:brightness
    -- @evidence LImageData:grayscale
    -- @evidence lurek.image.savePNG
    it("PNG: image_cropped_grayscale.png -- cropped brightness and grayscale output", function()
        local img = lurek.image.newImageData(200, 200)
        img:fill(60, 80, 180, 255)
        img:drawRect(50, 50, 100, 100, 220, 100, 50, 255)

        local cropped = img:crop(40, 40, 120, 120)
        cropped:brightness(1.2)
        cropped:grayscale()

        local path = OUT .. "image_cropped_grayscale.png"
        save_png(cropped, path)
    end)
end)

-- @describe Evidence: lurek.image layered composition
describe("Evidence: lurek.image layered composition", function()
    before_each(function()
        ensure_evidence_dir("image")
    end)

    -- @evidence lurek.image.newLayeredImage
    -- @evidence LLayeredImage:addLayer
    -- @evidence LLayeredImage:getLayer
    -- @evidence LLayeredImage:merge
    -- @evidence lurek.image.savePNG
    it("PNG: image_layered_merge_scene.png -- merged three-layer composition", function()
        local w, h = 160, 120
        local layers = lurek.image.newLayeredImage(w, h)

        local bg_idx = layers:addLayer("background")
        local bg = layers:getLayer(bg_idx)
        bg:fill(100, 150, 220, 255)

        local mg_idx = layers:addLayer("midground")
        local mg = layers:getLayer(mg_idx)
        mg:fill(0, 0, 0, 0)
        mg:drawRect(0, 80, w, 40, 60, 160, 60, 255)

        local fg_idx = layers:addLayer("foreground")
        local fg = layers:getLayer(fg_idx)
        fg:fill(0, 0, 0, 0)
        fg:drawCircle(80, 70, 18, 220, 60, 60, 255)

        local merged = layers:merge()
        local path = OUT .. "image_layered_merge_scene.png"
        save_png(merged, path)
    end)

    -- @evidence LLayeredImage:setVisible
    -- @evidence LLayeredImage:isVisible
    -- @evidence LLayeredImage:setOpacity
    -- @evidence LLayeredImage:getOpacity
    -- @evidence LLayeredImage:merge
    -- @evidence lurek.image.savePNG
    it("PNG: image_layered_opacity_visibility.png -- visibility and opacity stack", function()
        local w, h = 160, 120
        local layers = lurek.image.newLayeredImage(w, h)

        local a_idx = layers:addLayer("alpha_layer")
        layers:getLayer(a_idx):fill(200, 80, 80, 255)

        local b_idx = layers:addLayer("hidden_layer")
        layers:getLayer(b_idx):fill(80, 200, 80, 255)
        layers:setVisible(b_idx, false)
        expect_false(layers:isVisible(b_idx))

        local c_idx = layers:addLayer("half_opaque")
        layers:getLayer(c_idx):fill(80, 80, 200, 255)
        layers:setOpacity(c_idx, 0.5)
        expect_true(math.abs(layers:getOpacity(c_idx) - 0.5) < 0.01)

        local merged = layers:merge()
        local path = OUT .. "image_layered_opacity_visibility.png"
        save_png(merged, path)
    end)

    -- @evidence LLayeredImage:swapLayers
    -- @evidence LLayeredImage:save
    it("LIMG: image_layered_swapped.limg -- swapped layer ordering persisted", function()
        local layers = lurek.image.newLayeredImage(64, 64)
        local i1 = layers:addLayer("first")
        layers:getLayer(i1):fill(255, 0, 0, 255)
        local i2 = layers:addLayer("second")
        layers:getLayer(i2):fill(0, 0, 255, 255)
        layers:swapLayers(i1, i2)

        local path = OUT .. "image_layered_swapped.limg"
        layers:save(path)
        expect_evidence_created(path)
    end)
end)

-- @describe Evidence: lurek.image shape galleries
describe("Evidence: lurek.image shape galleries", function()
    before_each(function()
        ensure_evidence_dir("image")
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: image_shape_rect_grid.png -- coloured rectangle grid", function()
        local path = OUT .. "image_shape_rect_grid.png"
        local W, H = 200, 200
        local CELL = 50
        local img = lurek.image.newImageData(W, H)
        img:fill(30, 30, 30, 255)
        local colours = {
            {220, 60, 60}, {60, 180, 60}, {60, 60, 220}, {220, 180, 60},
            {180, 60, 180}, {60, 180, 180}, {220, 120, 60}, {120, 60, 220},
            {60, 220, 120}, {220, 220, 60}, {60, 220, 220}, {220, 60, 120},
            {120, 220, 60}, {180, 180, 180}, {220, 100, 100}, {100, 100, 220},
        }
        local ci = 1
        for row = 0, math.floor(W / CELL) - 1 do
            for col = 0, math.floor(H / CELL) - 1 do
                local c = colours[ci]
                img:drawRect(col * CELL + 2, row * CELL + 2, CELL - 4, CELL - 4, c[1], c[2], c[3], 255)
                ci = (ci % #colours) + 1
            end
        end
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: image_shape_concentric_circles.png -- concentric circle palette", function()
        local path = OUT .. "image_shape_concentric_circles.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 40, 255)
        local radii = {90, 72, 54, 36, 18}
        local cs = {
            {220, 50, 50}, {220, 150, 50}, {50, 200, 80}, {50, 120, 220}, {180, 50, 220},
        }
        for i, r in ipairs(radii) do
            local c = cs[i]
            img:drawCircle(100, 100, r, c[1], c[2], c[3], 255)
        end
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: image_shape_radiating_lines.png -- radial line fan", function()
        local path = OUT .. "image_shape_radiating_lines.png"
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(15, 15, 30, 255)
        local cx, cy = 100, 100
        local steps = 36
        for i = 0, steps - 1 do
            local angle = (i / steps) * math.pi * 2
            local ex = math.floor(cx + math.cos(angle) * 90 + 0.5)
            local ey = math.floor(cy + math.sin(angle) * 90 + 0.5)
            local r = math.floor((math.cos(angle) + 1) * 0.5 * 200) + 55
            local g = math.floor((math.sin(angle) + 1) * 0.5 * 200) + 55
            local b = math.floor(255 - r * 0.5)
            img:drawLine(cx, cy, ex, ey, r, g, b, 220)
        end
        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: image_paste_composite.png -- pasted circle stamp composite", function()
        local path = OUT .. "image_paste_composite.png"
        local base = lurek.image.newImageData(200, 200)
        base:fill(60, 100, 160, 255)
        base:drawRect(10, 10, 180, 180, 80, 120, 200, 255)

        local stamp = lurek.image.newImageData(60, 60)
        stamp:fill(0, 0, 0, 0)
        stamp:drawCircle(30, 30, 28, 220, 80, 50, 255)

        base:paste(stamp, 70, 70)
        save_png(base, path)
    end)
end)
test_summary()
