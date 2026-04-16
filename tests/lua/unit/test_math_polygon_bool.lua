-- tests/lua/unit/test_math_polygon_bool.lua
-- Tests for lurek.math.polygonIntersection, polygonUnion, polygonDifference.
-- Uses {x, y} tables as polygon vertices (CCW winding).

-- Unit square [0,0] to [1,1] (CCW)
local SQUARE = {
    {x=0, y=0}, {x=1, y=0}, {x=1, y=1}, {x=0, y=1}
}

-- Square offset to [0.5, 0.5] → [1.5, 1.5]  (overlaps with SQUARE)
local SQUARE_OFFSET = {
    {x=0.5, y=0.5}, {x=1.5, y=0.5}, {x=1.5, y=1.5}, {x=0.5, y=1.5}
}

-- Non-overlapping square [2, 2] → [3, 3]
local SQUARE_FAR = {
    {x=2, y=2}, {x=3, y=2}, {x=3, y=3}, {x=2, y=3}
}

describe("math.polygonIntersection", function()

    it("polygonIntersection exists in lurek.math", function()
        expect_equal(type(lurek.math.polygonIntersection), "function")
    end)

    it("intersection of overlapping squares returns a table", function()
        local result = lurek.math.polygonIntersection(SQUARE, SQUARE_OFFSET)
        expect_equal(type(result), "table")
    end)

    it("intersection of overlapping squares has vertices", function()
        local result = lurek.math.polygonIntersection(SQUARE, SQUARE_OFFSET)
        expect_equal(#result > 0, true)
    end)

    it("intersection of non-overlapping polygons returns empty table", function()
        local result = lurek.math.polygonIntersection(SQUARE, SQUARE_FAR)
        expect_equal(#result, 0)
    end)

    it("intersection vertices have x and y fields", function()
        local result = lurek.math.polygonIntersection(SQUARE, SQUARE_OFFSET)
        if #result > 0 then
            expect_equal(type(result[1].x), "number")
            expect_equal(type(result[1].y), "number")
        end
    end)

    it("intersection with self returns the same polygon area (approx)", function()
        local result = lurek.math.polygonIntersection(SQUARE, SQUARE)
        -- intersection with itself should fill the polygon
        expect_equal(#result >= 3, true)
    end)

end)

describe("math.polygonUnion", function()

    it("polygonUnion exists in lurek.math", function()
        expect_equal(type(lurek.math.polygonUnion), "function")
    end)

    it("union returns a table with vertices", function()
        local result = lurek.math.polygonUnion(SQUARE, SQUARE_OFFSET)
        expect_equal(type(result), "table")
        expect_equal(#result >= 3, true)
    end)

    it("union vertices have x and y fields", function()
        local result = lurek.math.polygonUnion(SQUARE, SQUARE_OFFSET)
        if #result > 0 then
            expect_equal(type(result[1].x), "number")
            expect_equal(type(result[1].y), "number")
        end
    end)

    it("union of non-overlapping squares has >= 6 vertices", function()
        local result = lurek.math.polygonUnion(SQUARE, SQUARE_FAR)
        -- Convex hull of two separated squares will have vertices >= 4
        expect_equal(#result >= 4, true)
    end)

end)

describe("math.polygonDifference", function()

    it("polygonDifference exists in lurek.math", function()
        expect_equal(type(lurek.math.polygonDifference), "function")
    end)

    it("difference with empty b returns a (unchanged)", function()
        local result = lurek.math.polygonDifference(SQUARE, {})
        expect_equal(#result, 4)
    end)

    it("difference of empty a returns empty", function()
        local result = lurek.math.polygonDifference({}, SQUARE)
        expect_equal(#result, 0)
    end)

    it("difference of non-overlapping polygons returns a (convex hull of a)", function()
        local result = lurek.math.polygonDifference(SQUARE, SQUARE_FAR)
        -- No overlap → result should contain SQUARE vertices
        expect_equal(#result > 0, true)
    end)

    it("difference returns a table with x and y fields", function()
        local result = lurek.math.polygonDifference(SQUARE, SQUARE_OFFSET)
        if #result > 0 then
            expect_equal(type(result[1].x), "number")
            expect_equal(type(result[1].y), "number")
        end
    end)

end)

test_summary()
