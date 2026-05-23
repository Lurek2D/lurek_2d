-- Evidence tests: bezier module
-- Artifacts are produced from lurek.math.newBezierCurve evaluation.
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.math.newBezierCurve


local OUT = "tests/output/bezier/"

-- @describe evidence: bezier
describe("evidence: bezier", function()
    before_each(function()
        ensure_evidence_dir("bezier")
    end)

    local function draw_curve(img, curve, steps, r, g, b)
        local px, py = curve:evaluate(0)
        for i = 1, steps do
            local t = i / steps
            local x, y = curve:evaluate(t)
            img:drawLine(px, py, x, y, r, g, b, 255)
            px, py = x, y
        end
    end

    -- @evidence file
    it("PNG: bezier_quadratic", function()
        local img = lurek.image.newImageData(220, 200)
        img:fill(244, 244, 246, 255)

        local curve = lurek.math.newBezierCurve({ 20, 180, 110, 20, 200, 180 })
        expect_equal(3, curve:getControlPointCount())

        draw_curve(img, curve, 120, 50, 110, 220)

        local path = OUT .. "bezier_quadratic.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: bezier_cubic", function()
        local img = lurek.image.newImageData(220, 200)
        img:fill(248, 248, 248, 255)

        local curve = lurek.math.newBezierCurve({ 20, 170, 60, 20, 160, 20, 200, 170 })
        expect_equal(4, curve:getControlPointCount())

        draw_curve(img, curve, 140, 220, 90, 60)

        local d = curve:getDerivative()
        local tx, ty = curve:evaluate(0.5)
        local dx, dy = d:evaluate(0.5)
        img:drawLine(tx, ty, tx + dx * 20, ty + dy * 20, 40, 40, 40, 255)

        local path = OUT .. "bezier_cubic.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)

test_summary()
