-- Evidence tests: imagedata module
-- Artifacts are generated from low-level LImageData operations.
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG


local OUT = "tests/output/imagedata/"

-- @describe evidence: imagedata
describe("evidence: imagedata", function()
    before_each(function()
        ensure_evidence_dir("imagedata")
    end)

    -- @evidence file
    it("PNG: pixel grid from setPixel", function()
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

        local path = OUT .. "pixel_grid.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: shapes", function()
        local img = lurek.image.newImageData(200, 200)
        img:fill(240, 240, 240, 255)
        img:drawRect(10, 10, 80, 60, 200, 60, 60, 255)
        img:drawRect(110, 10, 80, 60, 60, 60, 200, 255)
        img:drawCircle(100, 130, 50, 60, 180, 60, 255)
        img:drawLine(10, 180, 190, 20, 180, 100, 20, 255)

        local path = OUT .. "shapes.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: filters and crop", function()
        local img = lurek.image.newImageData(200, 200)
        img:fill(60, 80, 180, 255)
        img:drawRect(50, 50, 100, 100, 220, 100, 50, 255)

        local cropped = img:crop(40, 40, 120, 120)
        cropped:brightness(1.2)
        cropped:grayscale()

        local path = OUT .. "cropped.png"
        lurek.image.savePNG(cropped, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
