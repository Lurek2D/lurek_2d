-- Evidence tests: image module
-- Artifacts are generated from lurek.image drawing/effects APIs.

local OUT = "tests/output/image/"

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

    -- @evidence file
    it("PNG: drawing primitives scene", function()
        local img = make_base(256, 256)
        local path = OUT .. "drawing_combined.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
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

        local path = OUT .. "effects_strip.png"
        lurek.image.savePNG(canvas, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: blur and sharpen pair", function()
        local base = make_base(256, 128)
        local left = base:crop(0, 0, 128, 128)
        local right = base:crop(128, 0, 128, 128)

        left:blur(3)
        right:sharpen()

        local out = lurek.image.newImageData(256, 128)
        out:paste(left, 0, 0)
        out:paste(right, 128, 0)

        local path = OUT .. "effects_blur_sharpen.png"
        lurek.image.savePNG(out, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
