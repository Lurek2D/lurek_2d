-- Evidence tests: easing module
-- Artifacts are generated from lurek.math easing functions.
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.math.applyEasing
-- @covers lurek.math.inCubic
-- @covers lurek.math.inOutQuad
-- @covers lurek.math.inQuad
-- @covers lurek.math.linear
-- @covers lurek.math.outBounce
-- @covers lurek.math.outCubic
-- @covers lurek.math.outQuad


local OUT = "tests/output/easing/"

-- @describe evidence: easing
describe("evidence: easing", function()
    before_each(function()
        ensure_evidence_dir("easing")
    end)

    local function plot_curve(img, fn, r, g, b)
        local w, h = img:getDimensions()
        for i = 0, w - 1 do
            local t = i / (w - 1)
            local v = fn(t)
            local y = math.floor((1 - v) * (h - 1) + 0.5)
            if y >= 0 and y < h then
                img:setPixel(i, y, r, g, b, 255)
            end
        end
    end

    -- @evidence file
    it("PNG: quad easing curves", function()
        local img = lurek.image.newImageData(420, 220)
        img:fill(245, 245, 245, 255)

        plot_curve(img, lurek.math.linear, 100, 100, 100)
        plot_curve(img, lurek.math.inQuad, 220, 60, 60)
        plot_curve(img, lurek.math.outQuad, 60, 160, 60)
        plot_curve(img, lurek.math.inOutQuad, 60, 60, 220)

        local path = OUT .. "easing_quad.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: cubic and bounce curves", function()
        local img = lurek.image.newImageData(420, 220)
        img:fill(250, 250, 250, 255)

        plot_curve(img, lurek.math.inCubic, 200, 80, 80)
        plot_curve(img, lurek.math.outCubic, 80, 180, 80)
        plot_curve(img, lurek.math.outBounce, 80, 80, 200)

        local path = OUT .. "easing_cubic_bounce.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: applyEasing heatmap", function()
        local names = {
            "linear", "inQuad", "outQuad", "inOutQuad",
            "inCubic", "outCubic", "inOutCubic",
            "inSine", "outSine", "inOutSine",
            "inExpo", "outExpo", "inOutExpo",
            "outBounce", "inBounce",
        }

        local w = 120
        local h = #names
        local img = lurek.image.newImageData(w, h)

        for row, name in ipairs(names) do
            for col = 0, w - 1 do
                local t = col / (w - 1)
                local ok, v = pcall(lurek.math.applyEasing, name, t)
                local bright = ok and math.max(0, math.min(255, math.floor(v * 255))) or 128
                img:setPixel(col, row - 1, bright, math.floor(bright * 0.5), 255 - bright, 255)
            end
        end

        local path = OUT .. "easing_values.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
