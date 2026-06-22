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

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
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
    draw_outline(img, x, y, w, h, r, g, b, 255)
end

local function fill_from_points(img, pts, r, g, b)
    for _, pt in ipairs(pts) do
        img:drawRect(math.floor(pt.x - 1), math.floor(pt.y - 1), 3, 3, r, g, b, 200)
    end
end

local function format_color(col)
    if not col then
        return "nil"
    end
    return table.concat({
        tostring(col[1]),
        tostring(col[2]),
        tostring(col[3]),
        tostring(col[4]),
    }, ",")
end

-- @describe Evidence: svg
describe("Evidence: svg", function()
    before_each(function()
        ensure_evidence_dir("svg")
    end)
    -- Does: Runs "SVG structure, adjacencies and points report" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.svg.load, LSvgImage:type, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/svg/svg_report.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.svg.load, LSvgImage:type, and related owner calls; export helpers are just the container.

    it("TXT: SVG structure, adjacencies and points report", function()
        local svg = lurek.svg.load("tests/lua/fixtures/test.svg")
        expect_equal("LSvgImage", svg:type())
        expect_true(svg:typeOf("LSvgImage"))

        local w = svg:getWidth()
        local h = svg:getHeight()
        local ids = svg:getElementIds()
        table.sort(ids)
        local adj = svg:getAdjacencies("prov_", 3.0)
        local neighbors = adj["prov_1"] or {}
        svg:setElementVisible("prov_1", true)
        svg:setElementColor("prov_1", 1, 0, 0, 1)
        svg:setElementTransform("prov_1", 10, 10, 0, 1, 1)
        local pts = svg:getElementPoints("prov_1", 10.0)
        svg:cacheToCanvas("group1", 100, 100)
        local canvas = svg:getCanvasKey("group1")
        local canvas_alias = svg:getCanvas("group1")
        svg:draw(0, 0)

        local report = table.concat({
            "size=" .. tostring(w) .. "x" .. tostring(h),
            "ids=" .. table.concat(ids, ","),
            "prov_1_neighbors=" .. table.concat(neighbors, ","),
            "prov_1_points=" .. tostring(#pts),
            "canvas_key=" .. tostring(canvas ~= nil),
            "canvas_alias=" .. tostring(canvas_alias ~= nil),
        }, "\n") .. "\n"
        write_text(OUT .. "svg_report.txt", report)
    end)
    -- Does: Runs "SVG province geometry debug view" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.svg.load, LSvgImage:getElementPoints, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/svg/svg_geometry_debug.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.svg.load, LSvgImage:getElementPoints, and related owner calls; export helpers are just the container.

    it("PNG: SVG province geometry debug view", function()
        local svg = lurek.svg.load("tests/lua/fixtures/test.svg")
        local img = lurek.image.newImageData(280, 180)
        img:fill(14, 16, 20, 255)
        img:drawRect(16, 16, 248, 148, 24, 28, 36, 255)
        draw_outline(img, 16, 16, 248, 148, 232, 236, 244, 255)

        local p1 = svg:getElementPoints("prov_1", 6.0) or {}
        local p2 = svg:getElementPoints("prov_2", 6.0) or {}
        local b1 = svg:getElementBounds("prov_1")
        local b2 = svg:getElementBounds("prov_2")

        fill_from_points(img, p1, 255, 120, 120)
        fill_from_points(img, p2, 120, 255, 140)
        draw_bounds(img, b1, 20, 20, 1.0, 255, 220, 180)
        draw_bounds(img, b2, 20, 20, 1.0, 180, 240, 220)
        plot_points(img, p1, 20, 20, 1.0, 255, 245, 200)
        plot_points(img, p2, 20, 20, 1.0, 200, 245, 255)

        save_png(img, OUT .. "svg_geometry_debug.png")
    end)
    -- Does: Runs "SVG transformed visibility state view" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LSvgImage:setElementVisible, LSvgImage:getElementVisible, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/svg/svg_transform_visibility.png
    -- Why: This is meaningful only if the visible/text output comes from LSvgImage:setElementVisible, LSvgImage:getElementVisible, and related owner calls; export helpers are just the container.

    it("PNG: SVG transformed visibility state view", function()
        local svg = lurek.svg.load("tests/lua/fixtures/test.svg")
        svg:setElementVisible("prov_2", false)
        svg:setElementTransform("prov_1", 22, 8, 0, 1.15, 0.85)

        local visible_2 = svg:getElementVisible("prov_2")
        local trs = svg:getElementTransform("prov_1")
        local pts = svg:getElementPoints("prov_1", 6.0) or {}
        local tx, ty, _, sx, sy = trs[1], trs[2], trs[3], trs[4], trs[5]
        local img = lurek.image.newImageData(320, 180)
        img:fill(14, 16, 20, 255)
        img:drawRect(18, 20, 136, 116, 24, 28, 36, 255)
        img:drawRect(176, 20, 126, 116, 24, 28, 36, 255)
        draw_outline(img, 18, 20, 136, 116, 232, 236, 244, 255)
        draw_outline(img, 176, 20, 126, 116, 232, 236, 244, 255)

        for _, pt in ipairs(pts) do
            local px = math.floor(32 + pt.x + 0.5)
            local py = math.floor(34 + pt.y + 0.5)
            img:drawRect(px - 1, py - 1, 3, 3, 80, 180, 255, 220)

            local tpx = math.floor(190 + (pt.x * sx + tx) + 0.5)
            local tpy = math.floor(34 + (pt.y * sy + ty) + 0.5)
            img:drawRect(tpx - 1, tpy - 1, 3, 3, 255, 160, 90, 220)
        end

        if not visible_2 then
            img:drawRect(210, 110, 60, 18, 180, 56, 66, 255)
            draw_outline(img, 210, 110, 60, 18, 255, 220, 220, 255)
        end

        save_png(img, OUT .. "svg_transform_visibility.png")
    end)
    -- Does: Runs "svg hierarchy and reset trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LSvgImage:getDimensions, LSvgImage:getElementCount, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/svg/svg_hierarchy_reset_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LSvgImage:getDimensions, LSvgImage:getElementCount, and related owner calls; export helpers are just the container.

    it("TXT: svg hierarchy and reset trace", function()
        local svg = lurek.svg.load("tests/lua/fixtures/test.svg")
        local w, h = svg:getDimensions()
        local count = svg:getElementCount()
        local before = svg:getElementColor("prov_1")
        svg:setElementColor("prov_1", 0.2, 0.8, 0.3, 1.0)
        svg:setElementTransform("prov_1", 14, 9, 0.0, 1.1, 0.9)
        svg:resetElementColor("prov_1")
        svg:resetElementTransform("prov_1")
        local after = svg:getElementColor("prov_1")
        local parent = svg:getElementParent("prov_1")
        local children = parent and (svg:getElementChildren(parent) or {}) or {}
        local lines = {
            string.format("dimensions=%sx%s", tostring(w), tostring(h)),
            "element_count=" .. tostring(count),
            "prov_1_color_before=" .. format_color(before),
            "prov_1_color_after=" .. format_color(after),
            "prov_1_parent=" .. tostring(parent),
            "parent_child_count=" .. tostring(#children),
        }
        write_text(OUT .. "svg_hierarchy_reset_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
