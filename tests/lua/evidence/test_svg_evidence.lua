-- Evidence tests: svg module
-- Artifacts are generated from lurek.svg APIs.

local OUT = "tests/output/svg/"

-- @describe Evidence: svg
describe("Evidence: svg", function()
    before_each(function()
        ensure_evidence_dir("svg")
    end)

    -- @evidence file
    -- @covers LSvgImage:typeOf
    -- @covers LSvgImage:type
    -- @covers LSvgImage:getCanvas
    -- @covers LSvgImage:getCanvasKey
    -- @covers LSvgImage:cacheToCanvas
    -- @covers LSvgImage:getAdjacencies
    -- @covers LSvgImage:getElementPoints
    -- @covers LSvgImage:setElementTransform
    -- @covers LSvgImage:setElementColor
    -- @covers LSvgImage:setElementVisible
    -- @covers LSvgImage:getElementIds
    -- @covers LSvgImage:draw
    -- @covers LSvgImage:getHeight
    -- @covers LSvgImage:getWidth
    -- @covers lurek.svg.load
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

        -- Evaluate adjacencies
        local adj = svg:getAdjacencies("prov_", 3.0)
        local neighbors = adj["prov_1"]
        expect_type("table", neighbors)
        expect_equal(1, #neighbors)
        expect_equal("prov_2", neighbors[1])

        -- Apply modifiers after adjacency extraction so the topology report stays stable.
        svg:setElementVisible("prov_1", true)
        svg:setElementColor("prov_1", 1, 0, 0, 1)
        svg:setElementTransform("prov_1", 10, 10, 0, 1, 1)

        -- Evaluate points
        local pts = svg:getElementPoints("prov_1", 10.0)
        expect_true(#pts > 0)

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
