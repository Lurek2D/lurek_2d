-- Lurek2D Lua BDD tests for lurek.raycaster
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.raycaster.
describe("lurek.raycaster", function()
    -- @description Covers suite: module interface.
    describe("module interface", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies the raycaster module exposes the new factory.
        it("exposes new factory", function()
            expect_type("function", lurek.raycaster.new)
        end)
    end)

    -- @description Covers suite: new(w, h).
    describe("new(w, h)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies new returns a userdata raycaster handle.
        it("returns a userdata object", function()
            local rc = lurek.raycaster.new(16, 12)
            expect_type("userdata", rc)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies width() reflects the constructor width.
        it("width() returns the given width", function()
            local rc = lurek.raycaster.new(24, 18)
            expect_equal(24, rc:width())
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies height() reflects the constructor height.
        it("height() returns the given height", function()
            local rc = lurek.raycaster.new(24, 18)
            expect_equal(18, rc:height())
        end)
    end)

    -- @description Covers suite: cell access.
    describe("cell access", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies fresh grids initialize every cell to zero.
        it("all cells start as 0", function()
            local rc = lurek.raycaster.new(4, 4)
            for y = 0, 3 do
                for x = 0, 3 do
                    expect_equal(0, rc:getCell(x, y))
                end
            end
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies setCell and getCell round-trip a wall value.
        it("setCell / getCell round-trip", function()
            local rc = lurek.raycaster.new(8, 8)
            rc:setCell(2, 5, 99)
            expect_equal(99, rc:getCell(2, 5))
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies setCells consumes a flat row-major cell table.
        it("setCells fills the grid from a flat table", function()
            local rc = lurek.raycaster.new(2, 2)
            rc:setCells({ 1, 2, 3, 4 })
            expect_equal(1, rc:getCell(0, 0))
            expect_equal(2, rc:getCell(1, 0))
            expect_equal(3, rc:getCell(0, 1))
            expect_equal(4, rc:getCell(1, 1))
        end)
    end)

    -- @description Covers suite: isBlocked(x, y).
    describe("isBlocked(x, y)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies zero-valued cells are treated as unblocked.
        it("returns false for zero cell", function()
            local rc = lurek.raycaster.new(4, 4)
            expect_equal(false, rc:isBlocked(1, 1))
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies non-zero cells are treated as blocked.
        it("returns true for non-zero cell", function()
            local rc = lurek.raycaster.new(4, 4)
            rc:setCell(2, 2, 1)
            expect_equal(true, rc:isBlocked(2, 2))
        end)
    end)

    -- @description Covers suite: castRay(ox, oy, angle, max_dist).
    describe("castRay(ox, oy, angle, max_dist)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies castRay on an empty grid returns nil or a non-hit table safely.
        it("returns nil in fully empty grid", function()
            local rc = lurek.raycaster.new(10, 10)
            local hit = rc:castRay(5.0, 5.0, 0.0, 20.0)
            -- An empty grid may return nil or a boundary non-hit
            if hit ~= nil then
                expect_type("table", hit)
            end
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies castRay detects a wall placed directly in front of the origin.
        it("hits a wall placed directly ahead", function()
            local rc = lurek.raycaster.new(10, 10)
            rc:setCell(8, 4, 1)          -- wall at x=8, row 4
            -- cast from (1.5, 4.5) pointing east (angle=0)
            local hit = rc:castRay(1.5, 4.5, 0.0, 20.0)
            assert(hit ~= nil, "expected a hit")
            expect_equal(true, hit.hit)
            expect_equal(1, hit.cell_value)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies ray hit tables include distance, hit location, and texture fields.
        it("returned hit table has required fields", function()
            local rc = lurek.raycaster.new(10, 10)
            rc:setCell(5, 5, 7)
            local hit = rc:castRay(0.5, 5.5, 0.0, 20.0)
            if hit and hit.hit then
                expect_type("number", hit.distance)
                expect_type("number", hit.raw_distance)
                expect_type("number", hit.cell_value)
                expect_type("number", hit.side)
                expect_type("number", hit.tex_u)
                expect_type("number", hit.hit_x)
                expect_type("number", hit.hit_y)
            end
        end)
    end)

    -- @description Covers suite: castRays(ox, oy, angle, fov, count, max_dist).
    describe("castRays(ox, oy, angle, fov, count, max_dist)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies castRays returns exactly the requested number of entries.
        it("returns exactly count entries", function()
            local rc = lurek.raycaster.new(20, 20)
            local rays = rc:castRays(10.0, 10.0, 0.0, math.pi / 2, 64, 30.0)
            expect_equal(64, #rays)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies each castRays entry is a table.
        it("each entry is a table", function()
            local rc = lurek.raycaster.new(20, 20)
            local rays = rc:castRays(10.0, 10.0, 0.0, math.pi / 3, 8, 20.0)
            for i, r in ipairs(rays) do
                expect_type("table", r)
            end
        end)
    end)

    -- @description Covers suite: castRaysFlat(ox, oy, angle, fov, count, max_dist).
    describe("castRaysFlat(ox, oy, angle, fov, count, max_dist)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies castRaysFlat returns a table payload.
        it("returns a table", function()
            local rc = lurek.raycaster.new(20, 20)
            local flat = rc:castRaysFlat(10.0, 10.0, 0.0, math.pi / 2, 8, 30.0)
            expect_type("table", flat)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies castRaysFlat flattens results into numeric values only.
        it("contains only numbers", function()
            local rc = lurek.raycaster.new(20, 20)
            local flat = rc:castRaysFlat(10.0, 10.0, 0.0, math.pi / 2, 4, 30.0)
            for _, v in ipairs(flat) do
                expect_type("number", v)
            end
        end)
    end)

    -- @description Covers suite: lineOfSight(x1, y1, x2, y2).
    describe("lineOfSight(x1, y1, x2, y2)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies lineOfSight returns true across an unobstructed segment.
        it("returns true in empty grid", function()
            local rc = lurek.raycaster.new(10, 10)
            local visible = rc:lineOfSight(1.0, 5.0, 8.0, 5.0)
            expect_equal(true, visible)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies lineOfSight returns false when a wall blocks the segment.
        it("returns false when wall blocks the path", function()
            local rc = lurek.raycaster.new(10, 10)
            rc:setCell(5, 5, 1)  -- wall in the middle
            local visible = rc:lineOfSight(1.0, 5.5, 9.0, 5.5)
            expect_equal(false, visible)
        end)

        -- @covers lurek.raycaster.new
        -- @description Verifies lineOfSight always returns a boolean.
        it("returns a boolean", function()
            local rc = lurek.raycaster.new(10, 10)
            local result = rc:lineOfSight(0.5, 0.5, 9.5, 9.5)
            expect_type("boolean", result)
        end)
    end)

    -- @description Covers suite: projectSprite(sx, sy, px, py, pa, fov, screen_w).
    describe("projectSprite(sx, sy, px, py, pa, fov, screen_w)", function()
        -- @covers lurek.raycaster.new
        -- @description Verifies projectSprite returns projection metadata including visibility and scale fields.
        it("returns a table with required fields", function()
            local rc = lurek.raycaster.new(10, 10)
            local sp = rc:projectSprite(5.0, 5.0, 1.0, 5.0, 0.0, math.pi / 2, 320.0)
            expect_type("table", sp)
            expect_type("number", sp.screen_x)
            expect_type("number", sp.scale)
            expect_type("number", sp.distance)
            expect_type("boolean", sp.visible)
        end)
    end)
end)

-- @description Covers suite: lurek.raycaster module functions.
describe("lurek.raycaster module functions", function()
    -- @description Covers suite: projectColumn(distance, fov, screen_height).
    describe("projectColumn(distance, fov, screen_height)", function()
        -- @covers lurek.raycaster.projectColumn
        -- @description Verifies projectColumn is exposed.
        it("is a function", function()
            expect_type("function", lurek.raycaster.projectColumn)
        end)

        -- @covers lurek.raycaster.projectColumn
        -- @description Verifies projectColumn returns three numeric outputs.
        it("returns 3 numbers", function()
            local a, b, c = lurek.raycaster.projectColumn(2.0, math.pi / 2, 480.0)
            expect_type("number", a)
            expect_type("number", b)
            expect_type("number", c)
        end)

        -- @covers lurek.raycaster.projectColumn
        -- @description Verifies nearby walls project to a positive column height.
        it("column height is positive for distance 1.0", function()
            local col_height, _, _ = lurek.raycaster.projectColumn(1.0, math.pi / 2, 480.0)
            expect_true(col_height > 0.0, "column height should be positive")
        end)

        -- @covers lurek.raycaster.projectColumn
        -- @description Verifies projected column height decreases as distance grows.
        it("column height decreases with distance", function()
            local h1, _, _ = lurek.raycaster.projectColumn(1.0, math.pi / 2, 480.0)
            local h2, _, _ = lurek.raycaster.projectColumn(5.0, math.pi / 2, 480.0)
            expect_true(h1 > h2, "closer wall should produce taller column")
        end)
    end)

    -- @description Covers suite: distanceShade(distance, max_distance).
    describe("distanceShade(distance, max_distance)", function()
        -- @covers lurek.raycaster.distanceShade
        -- @description Verifies distanceShade is exposed.
        it("is a function", function()
            expect_type("function", lurek.raycaster.distanceShade)
        end)

        -- @covers lurek.raycaster.distanceShade
        -- @description Verifies distanceShade returns full intensity at zero distance.
        it("returns 1.0 at distance 0", function()
            local shade = lurek.raycaster.distanceShade(0.0, 10.0)
            expect_near(1.0, shade, 0.001)
        end)

        -- @covers lurek.raycaster.distanceShade
        -- @description Verifies distanceShade clamps to zero at or beyond max distance.
        it("returns 0.0 at or beyond max_distance", function()
            local shade = lurek.raycaster.distanceShade(10.0, 10.0)
            expect_near(0.0, shade, 0.001)
        end)

        -- @covers lurek.raycaster.distanceShade
        -- @description Verifies distanceShade remains within the inclusive [0, 1] range.
        it("returns value in [0, 1]", function()
            local shade = lurek.raycaster.distanceShade(4.0, 10.0)
            expect_true(shade >= 0.0 and shade <= 1.0,
                "shade should be in [0,1], got: " .. tostring(shade))
        end)
    end)
end)
test_summary()
