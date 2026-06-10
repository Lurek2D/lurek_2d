-- Lurek2D Integration Test: Math + Graphics (headless-safe)
-- Tests math operations used in graphics contexts without requiring GPU

-- @describe math for graphics transformations
describe("math for graphics transformations", function()
    -- @covers LArray:transformPoints
    it("scale + translate point", function()
        local x, y = 10, 20
        local sx, sy = 2, 3
        local tx, ty = 100, 200

        local m = lurek.compute.affine2d(tx, ty, 0, sx, sy)
        local pts = lurek.compute.fromTable({ x, y }, nil, "float64"):reshape({ 1, 2 })
        local out = m:transformPoints(pts)

        expect_near(120, out:get(1, 1), 0.001, "scaled + translated x")
        expect_near(260, out:get(1, 2), 0.001, "scaled + translated y")
    end)

end)

-- @describe math geometry utilities
describe("math geometry utilities", function()
    -- @covers lurek.math.rectFromCenter
    it("point inside rectangle", function()
        local px, py = 5, 5
        local rx, ry, rw, rh = lurek.math.rectFromCenter(5, 5, 10, 10)

        local inside = px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
        expect_true(inside, "point is inside rect")

        local outside_x, outside_y = 15, 5
        local outside = outside_x >= rx and outside_x <= rx + rw and outside_y >= ry and outside_y <= ry + rh
        expect_false(outside, "point is outside rect")
    end)

    -- @covers lurek.math.circleContainsPoint
    it("point inside circle", function()
        local px, py = 3, 4
        local cx, cy, cr = 0, 0, 6

        expect_true(lurek.math.circleContainsPoint(cx, cy, cr, px, py), "point inside circle (dist=5, radius=6)")
    end)

end)
test_summary()
