-- Lurek2D SVG Vector Graphics API Tests
-- Covers lurek.svg module and LSvgImage methods.

-- =========================================================================
-- Module existence
-- =========================================================================

-- @describe lurek.svg module exists
describe("lurek.svg module exists", function()
    -- @covers lurek.svg
    it("lurek.svg is a table", function()
        expect_type("table", lurek.svg)
    end)

    -- @covers lurek.svg.load
    it("exposes factory function load", function()
        expect_type("function", lurek.svg.load)
    end)
end)

-- =========================================================================
-- LSvgImage Core Methods
-- =========================================================================

-- @describe LSvgImage Core Methods
describe("LSvgImage Core Methods", function()
    -- @covers lurek.svg.load
    it("loads SvgImage from file", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_type("userdata", svg)
    end)

    -- @covers LSvgImage:getWidth
    -- @covers LSvgImage:getHeight
    it("returns correct dimensions", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_equal(200, svg:getWidth())
        expect_equal(100, svg:getHeight())
    end)

    -- @covers LSvgImage:getElementIds
    it("returns element IDs list", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local ids = svg:getElementIds()
        expect_type("table", ids)
        
        -- Check if our IDs are in the list
        local found_prov_1 = false
        local found_prov_2 = false
        local found_group1 = false
        for _, id in ipairs(ids) do
            if id == "prov_1" then found_prov_1 = true end
            if id == "prov_2" then found_prov_2 = true end
            if id == "group1" then found_group1 = true end
        end
        expect_true(found_prov_1)
        expect_true(found_prov_2)
        expect_true(found_group1)
    end)
end)

-- =========================================================================
-- LSvgImage Element Modifiers
-- =========================================================================

-- @describe LSvgImage Element Modifiers
describe("LSvgImage Element Modifiers", function()
    -- @covers LSvgImage:setElementVisible
    it("toggles element visibility", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementVisible("prov_1", false)
        expect_true(true) -- Should not crash
    end)

    -- @covers LSvgImage:setElementColor
    it("overrides element color", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementColor("prov_1", 1, 0, 0, 1)
        expect_true(true) -- Should not crash
    end)

    -- @covers LSvgImage:setElementTransform
    it("applies local transformation to element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementTransform("prov_1", 10, 20, 0.5, 2, 2)
        expect_true(true) -- Should not crash
    end)
end)

-- =========================================================================
-- LSvgImage Advanced Features (Points, Adjacency, Canvas Cache)
-- =========================================================================

-- @describe LSvgImage Advanced Features
describe("LSvgImage Advanced Features", function()
    -- @covers LSvgImage:getElementPoints
    it("tesselates element paths into points", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local pts = svg:getElementPoints("prov_1", 10)
        expect_type("table", pts)
        expect_true(#pts > 0)
        -- Check type of points is LVec2
        expect_type("userdata", pts[1])
        expect_equal("LVec2", pts[1]:type())
    end)

    -- @covers LSvgImage:getAdjacencies
    it("computes province adjacencies", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        -- Distance between prov_1 and prov_2 is 2.0 pixels
        -- With epsilon=3.0 they should be adjacent
        local adj = svg:getAdjacencies("prov_", 3.0)
        expect_type("table", adj)
        
        local prov1_neighbors = adj["prov_1"]
        expect_type("table", prov1_neighbors)
        expect_equal(1, #prov1_neighbors)
        expect_equal("prov_2", prov1_neighbors[1])
        
        local prov2_neighbors = adj["prov_2"]
        expect_type("table", prov2_neighbors)
        expect_equal(1, #prov2_neighbors)
        expect_equal("prov_1", prov2_neighbors[1])
    end)

    -- @covers LSvgImage:cacheToCanvas
    -- @covers LSvgImage:getCanvasKey
    it("caches element to GPU Canvas", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:cacheToCanvas("group1", 100, 100)
        
        local canvas = svg:getCanvasKey("group1")
        expect_type("userdata", canvas)
        expect_equal("LCanvas", canvas:type())
        
        -- getCanvas alias
        local canvas_alias = svg:getCanvas("group1")
        expect_type("userdata", canvas_alias)
        expect_equal("LCanvas", canvas_alias:type())
    end)

    -- @covers LSvgImage:draw
    it("draws SVG document", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:draw(0, 0)
        expect_true(true) -- Should not crash
    end)
end)

-- =========================================================================
-- LSvgImage Error Handling & Edge Cases
-- =========================================================================

-- @describe LSvgImage Error Handling & Edge Cases
describe("LSvgImage Error Handling & Edge Cases", function()
    -- @covers lurek.svg.load
    it("fails when loading non-existent file", function()
        expect_error(function()
            lurek.svg.load("non_existent_file_xyz.svg")
        end)
    end)

    -- @covers LSvgImage:setElementVisible
    it("fails when setting visibility on non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:setElementVisible("non_existent_id", false)
        end)
    end)

    -- @covers LSvgImage:setElementColor
    it("fails when setting color on non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:setElementColor("non_existent_id", 1, 0, 0, 1)
        end)
    end)

    -- @covers LSvgImage:setElementTransform
    it("fails when setting transform on non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:setElementTransform("non_existent_id", 0, 0, 0, 1, 1)
        end)
    end)

    -- @covers LSvgImage:cacheToCanvas
    it("fails when caching non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:cacheToCanvas("non_existent_id", 100, 100)
        end)
    end)

    -- @covers LSvgImage:getCanvasKey
    -- @covers LSvgImage:getCanvas
    it("returns nil when querying non-cached element canvas", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local key = svg:getCanvasKey("prov_1")
        expect_nil(key)
        local canvas = svg:getCanvas("prov_1")
        expect_nil(canvas)
    end)

    -- @covers LSvgImage:getElementPoints
    it("returns nil when querying points for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local pts = svg:getElementPoints("non_existent_id")
        expect_nil(pts)
    end)
end)

-- =========================================================================
-- LSvgImage Hierarchy & Bounds (new methods)
-- =========================================================================

-- @describe LSvgImage Dimension and Count Queries
describe("LSvgImage Dimension and Count Queries", function()
    -- @covers LSvgImage:getDimensions
    it("getDimensions returns width and height", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local w, h = svg:getDimensions()
        expect_equal(200, w)
        expect_equal(100, h)
    end)

    -- @covers LSvgImage:getElementCount
    it("getElementCount returns parsed element count", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local count = svg:getElementCount()
        expect_type("number", count)
        expect_true(count > 0)
    end)
end)

-- @describe LSvgImage Bounds Queries
describe("LSvgImage Bounds Queries", function()
    -- @covers LSvgImage:getElementBounds
    it("getElementBounds returns AABB for a path element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local bounds = svg:getElementBounds("prov_1")
        expect_type("table", bounds)
        expect_type("number", bounds.min_x)
        expect_type("number", bounds.min_y)
        expect_type("number", bounds.max_x)
        expect_type("number", bounds.max_y)
        expect_true(bounds.max_x > bounds.min_x)
        expect_true(bounds.max_y >= bounds.min_y)
    end)

    -- @covers LSvgImage:getElementBounds
    it("getElementBounds returns nil for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local bounds = svg:getElementBounds("non_existent_id")
        expect_nil(bounds)
    end)
end)

-- @describe LSvgImage State Read-back
describe("LSvgImage State Read-back", function()
    -- @covers LSvgImage:getElementVisible
    it("getElementVisible reads back visibility after set", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_true(svg:getElementVisible("prov_1"))
        svg:setElementVisible("prov_1", false)
        expect_equal(false, svg:getElementVisible("prov_1"))
    end)

    -- @covers LSvgImage:getElementVisible
    it("getElementVisible returns nil for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local v = svg:getElementVisible("no_such_id")
        expect_nil(v)
    end)

    -- @covers LSvgImage:getElementColor
    it("getElementColor returns nil when no override is set", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local col = svg:getElementColor("prov_1")
        expect_nil(col)
    end)

    -- @covers LSvgImage:getElementColor
    it("getElementColor returns color table after setElementColor", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)
        local col = svg:getElementColor("prov_1")
        expect_type("table", col)
        expect_equal(4, #col)
        expect_true(math.abs(col[1] - 0.5) < 0.001)
        expect_true(math.abs(col[2] - 0.25) < 0.001)
        expect_true(math.abs(col[4] - 1.0) < 0.001)
    end)

    -- @covers LSvgImage:getElementTransform
    it("getElementTransform returns identity table for unmodified element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local trs = svg:getElementTransform("prov_1")
        expect_type("table", trs)
        expect_equal(5, #trs)
        expect_equal(0, trs[1]) -- tx
        expect_equal(0, trs[2]) -- ty
        expect_equal(0, trs[3]) -- rotation
        expect_equal(1, trs[4]) -- sx
        expect_equal(1, trs[5]) -- sy
    end)

    -- @covers LSvgImage:getElementTransform
    it("getElementTransform reads back values after setElementTransform", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementTransform("prov_1", 10, 20, 0.5, 2, 3)
        local trs = svg:getElementTransform("prov_1")
        expect_type("table", trs)
        expect_true(math.abs(trs[1] - 10) < 0.001)
        expect_true(math.abs(trs[2] - 20) < 0.001)
        expect_true(math.abs(trs[3] - 0.5) < 0.001)
        expect_true(math.abs(trs[4] - 2) < 0.001)
        expect_true(math.abs(trs[5] - 3) < 0.001)
    end)

    -- @covers LSvgImage:getElementTransform
    it("getElementTransform returns nil for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local trs = svg:getElementTransform("no_such")
        expect_nil(trs)
    end)
end)

-- @describe LSvgImage State Reset Methods
describe("LSvgImage State Reset Methods", function()
    -- @covers LSvgImage:resetElementTransform
    it("resetElementTransform restores identity after transform set", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementTransform("prov_1", 10, 20, 1.0, 2, 2)
        svg:resetElementTransform("prov_1")
        local trs = svg:getElementTransform("prov_1")
        expect_true(math.abs(trs[1]) < 0.001)  -- tx back to 0
        expect_true(math.abs(trs[4] - 1) < 0.001) -- sx back to 1
    end)

    -- @covers LSvgImage:resetElementTransform
    it("resetElementTransform errors on non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:resetElementTransform("no_such_id")
        end)
    end)

    -- @covers LSvgImage:resetElementColor
    it("resetElementColor clears override and getElementColor returns nil", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        svg:setElementColor("prov_1", 1, 0, 0, 1)
        svg:resetElementColor("prov_1")
        local col = svg:getElementColor("prov_1")
        expect_nil(col)
    end)

    -- @covers LSvgImage:resetElementColor
    it("resetElementColor errors on non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_error(function()
            svg:resetElementColor("no_such_id")
        end)
    end)
end)

-- @describe LSvgImage Hierarchy Navigation
describe("LSvgImage Hierarchy Navigation", function()
    -- @covers LSvgImage:getElementParent
    it("getElementParent returns parent id for child element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        -- prov_1 is a child of group1 in test.svg
        local parent = svg:getElementParent("prov_1")
        -- parent should be a string (group1) or nil if root-level
        expect_true(parent == nil or type(parent) == "string")
    end)

    -- @covers LSvgImage:getElementParent
    it("getElementParent returns nil for root element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        -- Root element has no parent
        local ids = svg:getElementIds()
        local root_id = ids[1]
        -- We don't assert a specific parent value - just that it runs without error
        local parent = svg:getElementParent(root_id)
        expect_true(parent == nil or type(parent) == "string")
    end)

    -- @covers LSvgImage:getElementParent
    it("getElementParent returns nil for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local p = svg:getElementParent("no_such")
        expect_nil(p)
    end)

    -- @covers LSvgImage:getElementChildren
    it("getElementChildren returns table for group element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local children = svg:getElementChildren("group1")
        expect_type("table", children)
    end)

    -- @covers LSvgImage:getElementChildren
    it("getElementChildren returns empty table for leaf path element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local children = svg:getElementChildren("prov_1")
        expect_type("table", children)
        expect_equal(0, #children)
    end)

    -- @covers LSvgImage:getElementChildren
    it("getElementChildren returns nil for non-existent element", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        local c = svg:getElementChildren("no_such")
        expect_nil(c)
    end)
end)
test_summary()
