-- Canonical evidence file for lurek.svg data and visual outputs.

local OUT = evidence_output_dir("svg")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function plot_points(img, pts, ox, oy, scale, r, g, b)
    for _, pt in ipairs(pts) do
        local px = math.floor(ox + pt.x * scale + 0.5)
        local py = math.floor(oy + pt.y * scale + 0.5)
        for dy = -1, 1 do
            for dx = -1, 1 do
                img:setPixel(px + dx, py + dy, r, g, b, 255)
            end
        end
    end
end

local function draw_bounds(img, bounds, ox, oy, scale, r, g, b)
    local x = math.floor(ox + bounds.min_x * scale + 0.5)
    local y = math.floor(oy + bounds.min_y * scale + 0.5)
    local w = math.max(1, math.floor((bounds.max_x - bounds.min_x) * scale + 0.5))
    local h = math.max(1, math.floor((bounds.max_y - bounds.min_y) * scale + 0.5))
    img:drawRect(x, y, w, h, r, g, b, 255)
end

-- @describe Evidence: svg
describe("Evidence: svg", function()
    before_each(function()
        ensure_evidence_dir("svg")
    end)

    -- @evidence lurek.svg.load
    -- @evidence LSvgImage:type
    -- @evidence LSvgImage:typeOf
    -- @evidence LSvgImage:getWidth
    -- @evidence LSvgImage:getHeight
    -- @evidence LSvgImage:getElementIds
    -- @evidence LSvgImage:getAdjacencies
    -- @evidence LSvgImage:setElementVisible
    -- @evidence LSvgImage:setElementColor
    -- @evidence LSvgImage:setElementTransform
    -- @evidence LSvgImage:getElementPoints
    -- @evidence LSvgImage:cacheToCanvas
    -- @evidence LSvgImage:getCanvasKey
    -- @evidence LSvgImage:getCanvas
    -- @evidence LSvgImage:draw
    it("TXT: SVG structure, adjacencies and points report", function()
        local svg = lurek.svg.load("tests/lua_reorg/fixtures/test.svg")
        expect_equal("LSvgImage", svg:type())
        expect_true(svg:typeOf("LSvgImage"))

        local w = svg:getWidth()
        local h = svg:getHeight()
        expect_equal(200, w)
        expect_equal(100, h)

        local ids = svg:getElementIds()
        expect_type("table", ids)
        table.sort(ids)

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

        write_text(path, report)
    end)

    -- @evidence lurek.svg.load
    -- @evidence LSvgImage:getElementPoints
    -- @evidence LSvgImage:getElementBounds
    -- @evidence lurek.image.savePNG
    it("PNG: SVG province geometry debug view", function()
        local svg = lurek.svg.load("tests/lua_reorg/fixtures/test.svg")
        local img = lurek.image.newImageData(240, 140)
        img:fill(14, 16, 20, 255)

        local p1 = svg:getElementPoints("prov_1", 6.0) or {}
        local p2 = svg:getElementPoints("prov_2", 6.0) or {}
        local b1 = svg:getElementBounds("prov_1")
        local b2 = svg:getElementBounds("prov_2")

        draw_bounds(img, b1, 20, 20, 1.0, 255, 120, 120)
        draw_bounds(img, b2, 20, 20, 1.0, 120, 255, 140)
        plot_points(img, p1, 20, 20, 1.0, 255, 220, 120)
        plot_points(img, p2, 20, 20, 1.0, 120, 220, 255)

        local path = OUT .. "svg_geometry_debug.png"
        save_png(img, path)
    end)

    -- @evidence LSvgImage:setElementVisible
    -- @evidence LSvgImage:getElementVisible
    -- @evidence LSvgImage:setElementTransform
    -- @evidence LSvgImage:getElementTransform
    -- @evidence lurek.image.savePNG
    it("PNG: SVG transformed visibility state view", function()
        local svg = lurek.svg.load("tests/lua_reorg/fixtures/test.svg")
        svg:setElementVisible("prov_2", false)
        svg:setElementTransform("prov_1", 22, 8, 0, 1.15, 0.85)

        local visible_2 = svg:getElementVisible("prov_2")
        local trs = svg:getElementTransform("prov_1")
        expect_equal(false, visible_2)
        expect_not_nil(trs)

        local pts = svg:getElementPoints("prov_1", 6.0) or {}
        local tx, ty, _, sx, sy = trs[1], trs[2], trs[3], trs[4], trs[5]
        local img = lurek.image.newImageData(260, 160)
        img:fill(14, 16, 20, 255)

        for _, pt in ipairs(pts) do
            local px = math.floor(30 + (pt.x * sx + tx) + 0.5)
            local py = math.floor(30 + (pt.y * sy + ty) + 0.5)
            for dy = -1, 1 do
                for dx = -1, 1 do
                    img:setPixel(px + dx, py + dy, 255, 150, 90, 255)
                end
            end
        end

        if not visible_2 then
            img:drawRect(160, 22, 70, 40, 200, 60, 70, 255)
            img:drawLine(160, 22, 230, 62, 255, 220, 220, 255)
            img:drawLine(230, 22, 160, 62, 255, 220, 220, 255)
        end

        local path = OUT .. "svg_transform_visibility.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
end)
test_summary()
