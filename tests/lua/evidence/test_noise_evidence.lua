-- Evidence tests: noise module
-- Produces PNG artifacts from lurek.math noise generation functions.
-- @module noise
-- @description Evidence suite for lurek.math noise: perlin2d, simplex2d, and NoiseGenerator map rendering.

describe("evidence: noise", function()
    before_each(function()
        ensure_evidence_dir("noise")
    end)

    -- @covers lurek.math.perlin2d
    -- @evidence file
    -- @description Renders a 64x64 Perlin noise field to a greyscale PNG.
    it("renders a Perlin noise field PNG", function()
        local dir  = evidence_output_dir("noise")
        local path = dir .. "perlin_field.png"
        local W, H = 64, 64
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local v = lurek.math.perlin2d(x * 0.08, y * 0.08)
                local c = math.floor((v + 1) * 0.5 * 255)
                c = math.max(0, math.min(255, c))
                img:setPixel(x, y, c, c, c, 255)
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @covers lurek.math.simplex2d
    -- @evidence file
    -- @description Renders a 64x64 Simplex noise field to a greyscale PNG.
    it("renders a Simplex noise field PNG", function()
        local dir  = evidence_output_dir("noise")
        local path = dir .. "simplex_field.png"
        local W, H = 64, 64
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local v = lurek.math.simplex2d(x * 0.10, y * 0.10)
                local c = math.floor((v + 1) * 0.5 * 255)
                c = math.max(0, math.min(255, c))
                img:setPixel(x, y, c, c, c, 255)
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @covers lurek.math.newNoiseGenerator
    -- @covers NoiseGenerator:perlin2d
    -- @evidence file
    -- @description Creates a seeded NoiseGenerator and renders a reproducible noise PNG.
    it("renders a seeded NoiseGenerator PNG", function()
        local dir  = evidence_output_dir("noise")
        local path = dir .. "noise_generator_seeded.png"
        local W, H = 64, 64
        local ng  = lurek.math.newNoiseGenerator(42)
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local v = ng:perlin2d(x * 0.12, y * 0.12)
                local c = math.floor((v + 1) * 0.5 * 255)
                c = math.max(0, math.min(255, c))
                img:setPixel(x, y, c, c, c, 255)
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @covers lurek.math.fbm
    -- @evidence file
    -- @description Renders a fractal Brownian motion (fBm) noise PNG.
    it("renders an fBm noise field PNG", function()
        local dir  = evidence_output_dir("noise")
        local path = dir .. "fbm_field.png"
        local W, H = 64, 64
        local img = lurek.image.newImageData(W, H)
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local ok, v = pcall(lurek.math.fbm, x * 0.06, y * 0.06)
                if ok then
                    local c = math.floor((v + 1) * 0.5 * 255)
                    c = math.max(0, math.min(255, c))
                    img:setPixel(x, y, c, c, c, 255)
                end
            end
        end
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
