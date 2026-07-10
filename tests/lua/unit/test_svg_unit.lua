-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_svg_unit.lua
do
-- Lurek2D SVG Vector Graphics API Tests
-- Canonical unit coverage for lurek.svg and LSvgImage methods.

local function load_test_svg()
    return lurek.svg.load("tests/lua/fixtures/test.svg")
end

local function expect_canvas_userdata(value)
    expect_type("userdata", value)
    expect_equal("LCanvas", value:type())
end

-- @describe lurek.svg module exists
describe("lurek.svg module exists", function()
    -- @covers lurek.svg.load
    it("load exposes the factory, opens valid files, and errors on missing files", function()
        expect_type("function", lurek.svg.load)

        local svg = load_test_svg()
        expect_type("userdata", svg)

        expect_error(function()
            lurek.svg.load("non_existent_file_xyz.svg")
        end)
    end)
end)

-- @describe LSvgImage dimensions and identity
describe("LSvgImage dimensions and identity", function()
    -- @covers LSvgImage:getWidth
    it("getWidth returns the parsed document width", function()
        local svg = load_test_svg()
        expect_equal(200, svg:getWidth())
    end)

    -- @covers LSvgImage:getHeight
    it("getHeight returns the parsed document height", function()
        local svg = load_test_svg()
        expect_equal(100, svg:getHeight())
    end)

    -- @covers LSvgImage:getDimensions
    it("getDimensions returns width and height", function()
        local svg = load_test_svg()
        local width, height = svg:getDimensions()
        expect_equal(200, width)
        expect_equal(100, height)
    end)

    -- @covers LSvgImage:type
    it("type returns the svg image userdata name", function()
        local svg = load_test_svg()
        expect_equal("LSvgImage", svg:type())
    end)

    -- @covers LSvgImage:typeOf
    it("typeOf recognizes svg image and object inheritance", function()
        local svg = load_test_svg()
        expect_true(svg:typeOf("LSvgImage"))
        expect_true(svg:typeOf("LObject"))
    end)

    -- @covers LSvgImage:getElementCount
    it("getElementCount returns a positive parsed element count", function()
        local svg = load_test_svg()
        local count = svg:getElementCount()
        expect_type("number", count)
        expect_true(count > 0)
    end)

    -- @covers LSvgImage:getElementIds
    it("getElementIds lists the known test element ids", function()
        local svg = load_test_svg()
        local ids = svg:getElementIds()
        local seen = {}

        expect_type("table", ids)
        for _, id in ipairs(ids) do
            seen[id] = true
        end

        expect_true(seen["prov_1"] ~= nil, "expected prov_1 in element ids")
        expect_true(seen["prov_2"] ~= nil, "expected prov_2 in element ids")
        expect_true(seen["group1"] ~= nil, "expected group1 in element ids")
    end)
end)

-- @describe LSvgImage geometry queries
describe("LSvgImage geometry queries", function()
    -- @covers LSvgImage:getElementPoints
    it("getElementPoints returns tessellated points for existing ids and nil for missing ids", function()
        local svg = load_test_svg()
        local pts = svg:getElementPoints("prov_1", 10)

        expect_type("table", pts)
        expect_true(#pts > 0)
        expect_type("userdata", pts[1])
        expect_equal("LVec2", pts[1]:type())
        expect_nil(svg:getElementPoints("non_existent_id"))
    end)

    -- @covers LSvgImage:getElementBounds
    it("getElementBounds returns bounds for existing ids and nil for missing ids", function()
        local svg = load_test_svg()
        local bounds = svg:getElementBounds("prov_1")

        expect_type("table", bounds)
        expect_type("number", bounds.min_x)
        expect_type("number", bounds.min_y)
        expect_type("number", bounds.max_x)
        expect_type("number", bounds.max_y)
        expect_true(bounds.max_x > bounds.min_x)
        expect_true(bounds.max_y >= bounds.min_y)
        expect_nil(svg:getElementBounds("non_existent_id"))
    end)

    -- @covers LSvgImage:getAdjacencies
    it("getAdjacencies computes neighboring provinces for the fixture", function()
        local svg = load_test_svg()
        local adj = svg:getAdjacencies("prov_", 3.0)

        expect_type("table", adj)
        expect_type("table", adj["prov_1"])
        expect_type("table", adj["prov_2"])
        expect_equal(1, #adj["prov_1"])
        expect_equal(1, #adj["prov_2"])
        expect_equal("prov_2", adj["prov_1"][1])
        expect_equal("prov_1", adj["prov_2"][1])
    end)

    -- @covers LSvgImage:containsPoint
    it("containsPoint reports point-in-polygon state for visible elements", function()
        local svg = load_test_svg()

        expect_equal(true, svg:containsPoint("prov_1", 20, 20))
        expect_equal(false, svg:containsPoint("prov_1", 120, 20))
        svg:setElementVisible("prov_1", false)
        expect_equal(false, svg:containsPoint("prov_1", 20, 20))
        expect_nil(svg:containsPoint("non_existent_id", 20, 20))
    end)

    -- @covers LSvgImage:getElementAtPoint
    it("getElementAtPoint returns the first matching visible element by prefix", function()
        local svg = load_test_svg()

        expect_equal("prov_1", svg:getElementAtPoint("prov_", 20, 20))
        expect_equal("prov_2", svg:getElementAtPoint("prov_", 100, 20))
        svg:setElementVisible("prov_2", false)
        expect_nil(svg:getElementAtPoint("prov_", 100, 20))
        expect_nil(svg:getElementAtPoint("missing_", 20, 20))
    end)
end)

-- @describe LSvgImage element state
describe("LSvgImage element state", function()
    -- @covers LSvgImage:setElementVisible
    it("setElementVisible toggles an element and errors for missing ids", function()
        local svg = load_test_svg()

        svg:setElementVisible("prov_1", false)
        expect_equal(false, svg:getElementVisible("prov_1"))

        expect_error(function()
            svg:setElementVisible("non_existent_id", false)
        end)
    end)

    -- @covers LSvgImage:getElementVisible
    it("getElementVisible returns current visibility and nil for missing ids", function()
        local svg = load_test_svg()

        expect_true(svg:getElementVisible("prov_1"))
        svg:setElementVisible("prov_1", false)
        expect_equal(false, svg:getElementVisible("prov_1"))
        expect_nil(svg:getElementVisible("no_such_id"))
    end)

    -- @covers LSvgImage:setElementColor
    it("setElementColor applies overrides and errors for missing ids", function()
        local svg = load_test_svg()

        svg:setElementColor("prov_1", 1, 0, 0, 1)
        local col = svg:getElementColor("prov_1")
        expect_type("table", col)
        expect_equal(4, #col)

        expect_error(function()
            svg:setElementColor("non_existent_id", 1, 0, 0, 1)
        end)
    end)

    -- @covers LSvgImage:getElementColor
    it("getElementColor returns nil before override and color data after override", function()
        local svg = load_test_svg()

        expect_nil(svg:getElementColor("prov_1"))
        svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)

        local col = svg:getElementColor("prov_1")
        expect_type("table", col)
        expect_equal(4, #col)
        expect_near(0.5, col[1], 0.001)
        expect_near(0.25, col[2], 0.001)
        expect_near(1.0, col[4], 0.001)
    end)

    -- @covers LSvgImage:setElementTransform
    it("setElementTransform applies transforms and errors for missing ids", function()
        local svg = load_test_svg()

        svg:setElementTransform("prov_1", 10, 20, 0.5, 2, 2)
        local trs = svg:getElementTransform("prov_1")
        expect_type("table", trs)
        expect_near(10, trs[1], 0.001)
        expect_near(20, trs[2], 0.001)
        expect_near(0.5, trs[3], 0.001)
        expect_near(2, trs[4], 0.001)
        expect_near(2, trs[5], 0.001)

        expect_error(function()
            svg:setElementTransform("non_existent_id", 0, 0, 0, 1, 1)
        end)
    end)

    -- @covers LSvgImage:getElementTransform
    it("getElementTransform returns identity by default, updated values after set, and nil for missing ids", function()
        local svg = load_test_svg()
        local initial = svg:getElementTransform("prov_1")

        expect_type("table", initial)
        expect_equal(5, #initial)
        expect_equal(0, initial[1])
        expect_equal(0, initial[2])
        expect_equal(0, initial[3])
        expect_equal(1, initial[4])
        expect_equal(1, initial[5])

        svg:setElementTransform("prov_1", 10, 20, 0.5, 2, 3)
        local updated = svg:getElementTransform("prov_1")
        expect_near(10, updated[1], 0.001)
        expect_near(20, updated[2], 0.001)
        expect_near(0.5, updated[3], 0.001)
        expect_near(2, updated[4], 0.001)
        expect_near(3, updated[5], 0.001)

        expect_nil(svg:getElementTransform("no_such"))
    end)

    -- @covers LSvgImage:resetElementTransform
    it("resetElementTransform restores identity and errors for missing ids", function()
        local svg = load_test_svg()

        svg:setElementTransform("prov_1", 10, 20, 1.0, 2, 2)
        svg:resetElementTransform("prov_1")

        local trs = svg:getElementTransform("prov_1")
        expect_near(0, trs[1], 0.001)
        expect_near(0, trs[2], 0.001)
        expect_near(0, trs[3], 0.001)
        expect_near(1, trs[4], 0.001)
        expect_near(1, trs[5], 0.001)

        expect_error(function()
            svg:resetElementTransform("no_such_id")
        end)
    end)

    -- @covers LSvgImage:resetElementColor
    it("resetElementColor clears overrides and errors for missing ids", function()
        local svg = load_test_svg()

        svg:setElementColor("prov_1", 1, 0, 0, 1)
        svg:resetElementColor("prov_1")
        expect_nil(svg:getElementColor("prov_1"))

        expect_error(function()
            svg:resetElementColor("no_such_id")
        end)
    end)
end)

-- @describe LSvgImage canvas integration
describe("LSvgImage canvas integration", function()
    -- @covers LSvgImage:cacheToCanvas
    it("cacheToCanvas caches valid elements and errors for missing ids", function()
        local svg = load_test_svg()

        expect_no_error(function()
            svg:cacheToCanvas("group1", 100, 100)
        end)

        expect_error(function()
            svg:cacheToCanvas("non_existent_id", 100, 100)
        end)
    end)

    -- @covers LSvgImage:getCanvasKey
    it("getCanvasKey returns nil before caching and a canvas handle after caching", function()
        local svg = load_test_svg()

        expect_nil(svg:getCanvasKey("prov_1"))
        svg:cacheToCanvas("group1", 100, 100)
        expect_canvas_userdata(svg:getCanvasKey("group1"))
    end)

    -- @covers LSvgImage:getCanvas
    it("getCanvas returns nil before caching and a canvas handle after caching", function()
        local svg = load_test_svg()

        expect_nil(svg:getCanvas("prov_1"))
        svg:cacheToCanvas("group1", 100, 100)
        expect_canvas_userdata(svg:getCanvas("group1"))
    end)
end)

-- @describe LSvgImage rendering
describe("LSvgImage rendering", function()
    -- @covers LSvgImage:draw
    it("draw renders the svg without error", function()
        local svg = load_test_svg()
        expect_no_error(function()
            svg:draw(0, 0)
        end)
    end)
end)

-- @describe LSvgImage hierarchy navigation
describe("LSvgImage hierarchy navigation", function()
    -- @covers LSvgImage:getElementParent
    it("getElementParent returns a parent-like value for children and nil for missing ids", function()
        local svg = load_test_svg()
        local ids = svg:getElementIds()
        local root_parent = svg:getElementParent(ids[1])
        local child_parent = svg:getElementParent("prov_1")

        expect_true(child_parent == nil or type(child_parent) == "string")
        expect_true(root_parent == nil or type(root_parent) == "string")
        expect_nil(svg:getElementParent("no_such"))
    end)

    -- @covers LSvgImage:getElementChildren
    it("getElementChildren returns group children, empty leaves, and nil for missing ids", function()
        local svg = load_test_svg()
        local group_children = svg:getElementChildren("group1")
        local leaf_children = svg:getElementChildren("prov_1")

        expect_type("table", group_children)
        expect_type("table", leaf_children)
        expect_equal(0, #leaf_children)
        expect_nil(svg:getElementChildren("no_such"))
    end)
end)
end
-- END test_svg_unit.lua

test_summary()
