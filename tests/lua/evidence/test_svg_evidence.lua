-- Evidence tests: svg module
-- Artifacts are generated from lurek.svg APIs.
-- @covers lurek.svg.load
-- @covers LSvgImage:getWidth
-- @covers LSvgImage:getHeight
-- @covers LSvgImage:draw
-- @covers LSvgImage:getElementIds
-- @covers LSvgImage:setElementVisible
-- @covers LSvgImage:setElementColor
-- @covers LSvgImage:setElementTransform
-- @covers LSvgImage:getElementPoints
-- @covers LSvgImage:getAdjacencies
-- @covers LSvgImage:cacheToCanvas
-- @covers LSvgImage:getCanvasKey
-- @covers LSvgImage:getCanvas
-- @covers LSvgImage:type
-- @covers LSvgImage:typeOf

local OUT = "tests/output/svg/"

-- @describe Evidence: svg
describe("Evidence: svg", function()
    before_each(function()
        ensure_evidence_dir("svg")
    end)

    -- @evidence file
    it("TXT: SVG structure, adjacencies and points report", function()
        local svg = lurek.svg.load("tests/lua/unit/test.svg")
        expect_equal("LSvgImage", svg:type())
        expect_true(svg:typeOf("LSvgImage"))

        local w = svg:getWidth()
        local h = svg:getHeight()
        expect_equal(200, w)
        expect_equal(100, h)

        local ids = svg:getElementIds()
        expect_type("table", ids)

        -- Apply modifiers
        svg:setElementVisible("prov_1", true)
        svg:setElementColor("prov_1", 1, 0, 0, 1)
        svg:setElementTransform("prov_1", 10, 10, 0, 1, 1)

        -- Evaluate points
        local pts = svg:getElementPoints("prov_1", 10.0)
        expect_true(#pts > 0)

        -- Evaluate adjacencies
        local adj = svg:getAdjacencies("prov_", 3.0)
        local neighbors = adj["prov_1"]
        expect_equal(1, #neighbors)
        expect_equal("prov_2", neighbors[1])

        -- Cache to canvas
        svg:cacheToCanvas("group1", 100, 100)
        local canvas = svg:getCanvasKey("group1")
        expect_type("userdata", canvas)

        local canvas_alias = svg:getCanvas("group1")
        expect_type("userdata", canvas_alias)

        -- Draw the image
        svg:draw(0, 0)

        -- Write text report as evidence
        local report_lines = {
            "SVG Size: " .. w .. "x" .. h,
            "Parsed Element IDs: " .. table.concat(ids, ", "),
            "Tesselated Points Count: " .. #pts,
            "Adjacency prov_1 neighbor: " .. neighbors[1],
            "Canvas cached successfully: " .. tostring(canvas ~= nil)
        }
        local report = table.concat(report_lines, "\n")
        local path = OUT .. "svg_report.txt"

        -- Using test-only write_file helper
        write_file(path, report)
        expect_evidence_created(path)
    end)
end)

test_summary()
