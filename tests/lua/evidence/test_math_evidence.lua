-- test_math_evidence.lua
-- Canonical evidence file for lurek.math visual outputs.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.math.applyEasing
-- @covers lurek.math.bresenham
-- @covers lurek.math.clamp
-- @covers lurek.math.convexHull
-- @covers lurek.math.distance
-- @covers lurek.math.inCubic
-- @covers lurek.math.inOutQuad
-- @covers lurek.math.inQuad
-- @covers lurek.math.lineIntersect
-- @covers lurek.math.linear
-- @covers lurek.math.newBezierCurve
-- @covers lurek.math.outBounce
-- @covers lurek.math.outCubic
-- @covers lurek.math.outQuad
-- @covers lurek.math.pointInPolygon
-- @covers lurek.math.polygonArea
-- @covers lurek.math.polygonCentroid
-- @covers lurek.math.segmentIntersectsSegment
-- @covers lurek.math.triangulate
-- @covers lurek.math.vec2



local OUT = evidence_output_dir("math")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function clamp255(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return math.floor(v)
end

local function to_px(x, y, w, h, scale)
    local cx = math.floor(w * 0.5)
    local cy = math.floor(h * 0.5)
    return math.floor(cx + x * scale + 0.5), math.floor(cy - y * scale + 0.5)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function draw_curve(img, curve, steps, r, g, b)
    local px, py = curve:evaluate(0)
    for i = 1, steps do
        local t = i / steps
        local x, y = curve:evaluate(t)
        img:drawLine(px, py, x, y, r, g, b, 255)
        px, py = x, y
    end
end

local function plot_curve(img, fn, r, g, b)
    local w, h = img:getDimensions()
    for i = 0, w - 1 do
        local t = i / (w - 1)
        local v = fn(t)
        local y = math.floor((1 - v) * (h - 1) + 0.5)
        if y >= 0 and y < h then
            img:setPixel(i, y, r, g, b, 255)
        end
    end
end

local function save_easing_curve(file_name, fn, r, g, b)
    local img = lurek.image.newImageData(220, 220)
    img:fill(245, 245, 245, 255)
    draw_outline(img, 18, 18, 184, 184, 218, 222, 230, 255)
    for gx = 0, 4 do
        local x = 30 + gx * 40
        img:drawLine(x, 30, x, 190, 230, 232, 238, 255)
    end
    for gy = 0, 4 do
        local y = 30 + gy * 40
        img:drawLine(30, y, 190, y, 230, 232, 238, 255)
    end

    local plot = lurek.image.newImageData(161, 161)
    plot_curve(plot, fn, r, g, b)
    img:paste(plot, 30, 30)

    save_png(img, OUT .. file_name)
end

local function draw_control_points(img, coords)
    for i = 1, #coords, 2 do
        img:drawCircle(coords[i], coords[i + 1], 3, 255, 110, 110, 255)
    end
end

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.math visual scenarios
describe("Evidence: lurek.math visual scenarios", function()
    before_each(function()
        ensure_evidence_dir("math")
    end)
    -- Does: Runs "math_vec2_unit_circle.png -- normalized vectors on unit circle" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.vec2 without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_vec2_unit_circle.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.vec2; export helpers are just the container.

    it("PNG: math_vec2_unit_circle.png -- normalized vectors on unit circle", function()
        local w, h = 240, 240
        local img = lurek.image.newImageData(w, h)
        img:fill(240, 244, 250, 255)
        img:drawCircle(120, 120, 92, 160, 170, 190, 255)

        for i = 0, 95 do
            local a = i / 96 * math.pi * 2
            local v = lurek.math.vec2(math.cos(a), math.sin(a))
            local n = v:normalize()
            local x, y = to_px(n.x, n.y, w, h, 92)
            img:drawRect(x - 1, y - 1, 3, 3, 60, 110, 220, 255)
        end

        local path = OUT .. "math_vec2_unit_circle.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_distance_heatmap.png -- radial distance map" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.distance and lurek.math.clamp without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_distance_heatmap.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.distance and lurek.math.clamp; export helpers are just the container.

    it("PNG: math_distance_heatmap.png -- radial distance map", function()
        local w, h = 256, 192
        local img = lurek.image.newImageData(w, h)

        local cx, cy = 128, 96
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local d = lurek.math.distance(x, y, cx, cy)
                local t = lurek.math.clamp(1.0 - d / 130.0, 0.0, 1.0)
                img:setPixel(x, y, clamp255(40 + t * 180), clamp255(40 + t * 120), clamp255(80 + t * 140), 255)
            end
        end

        local path = OUT .. "math_distance_heatmap.png"
        save_png(img, path)
    end)
    -- Does: Runs "applyEasing curve samples" and turns the owner-module result into inspectable artifacts.
    -- Shows: Each PNG should expose one easing mode instead of combining several named modes into one comparison image.
    -- Artifact: tests/artifacts/current/math/math_easing_apply_*.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.applyEasing; export helpers are just the container.

    it("PNG: applyEasing curve samples", function()
        local easings = {
            { "math_easing_apply_linear.png", function(t) return lurek.math.applyEasing("linear", t) end, 230, 80, 80 },
            { "math_easing_apply_inout_quad.png", function(t) return lurek.math.applyEasing("inOutQuad", t) end, 90, 170, 230 },
            { "math_easing_apply_out_bounce.png", function(t) return lurek.math.applyEasing("outBounce", t) end, 70, 190, 120 },
            { "math_easing_apply_out_elastic.png", function(t) return lurek.math.applyEasing("outElastic", t) end, 180, 120, 240 },
        }

        for _, easing in ipairs(easings) do
            save_easing_curve(easing[1], easing[2], easing[3], easing[4], easing[5])
        end
    end)
    -- Does: Runs "math_segment_intersections.png -- segment intersection grid" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.segmentIntersectsSegment without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_segment_intersections.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.segmentIntersectsSegment; export helpers are just the container.

    it("PNG: math_segment_intersections.png -- segment intersection grid", function()
        local w, h = 300, 220
        local img = lurek.image.newImageData(w, h)
        img:fill(18, 22, 30, 255)

        for i = 0, 9 do
            local y = 20 + i * 18
            img:drawLine(20, y, 280, y, 50, 60, 80, 255)
        end

        for i = 0, 8 do
            local x1 = 30 + i * 28
            local y1 = 34
            local x2 = 270 - i * 20
            local y2 = 190
            img:drawLine(x1, y1, x2, y2, 110, 180, 255, 255)

            local hit, ix, iy = lurek.math.segmentIntersectsSegment(x1, y1, x2, y2, 30, 150, 280, 70)
            if hit and ix and iy then
                img:drawCircle(ix --[[@as number]], iy --[[@as number]], 3, 255, 210, 100, 255)
            end
        end
        img:drawLine(30, 150, 280, 70, 255, 120, 120, 255)

        local path = OUT .. "math_segment_intersections.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_polygon_metrics.png -- area, centroid and inside test map" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.polygonCentroid, lurek.math.polygonArea, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_polygon_metrics.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.polygonCentroid, lurek.math.polygonArea, and related owner calls; export helpers are just the container.

    it("PNG: math_polygon_metrics.png -- area, centroid and inside test map", function()
        local w, h = 300, 220
        local img = lurek.image.newImageData(w, h)
        img:fill(242, 246, 252, 255)

        local poly = { 40, 170, 110, 52, 220, 44, 266, 132, 198, 184, 96, 198 }

        local area = lurek.math.polygonArea(poly)
        local cx, cy = lurek.math.polygonCentroid(poly)

        for y = 0, h - 1, 3 do
            for x = 0, w - 1, 3 do
                if lurek.math.pointInPolygon(poly, x, y) then
                    img:drawRect(x, y, 2, 2, 145, 205, 255, 220)
                end
            end
        end

        for i = 1, #poly, 2 do
            local j = i + 2
            if j > #poly then j = 1 end
            img:drawLine(poly[i], poly[i + 1], poly[j], poly[j + 1], 50, 90, 140, 255)
        end

        img:drawCircle(cx, cy, 4, 255, 130, 80, 255)
        img:drawRect(12, 12, math.min(120, math.floor(math.abs(area) * 0.2)), 10, 110, 170, 240, 255)

        local path = OUT .. "math_polygon_metrics.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_bresenham_rays.png -- raster rays from center" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.bresenham without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_bresenham_rays.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.bresenham; export helpers are just the container.

    it("PNG: math_bresenham_rays.png -- raster rays from center", function()
        local w, h = 256, 256
        local img = lurek.image.newImageData(w, h)
        img:fill(12, 14, 20, 255)

        local cx, cy = 128, 128
        for i = 0, 31 do
            local a = i / 32 * math.pi * 2
            local ex = math.floor(cx + math.cos(a) * 112)
            local ey = math.floor(cy + math.sin(a) * 112)
            local pts = lurek.math.bresenham(cx, cy, ex, ey)
            for _, p in ipairs(pts) do
                local t = lurek.math.distance(cx, cy, p[1], p[2]) / 112
                img:setPixel(p[1], p[2], clamp255(80 + 140 * t), clamp255(130 + 100 * (1.0 - t)), 255, 255)
            end
        end

        local path = OUT .. "math_bresenham_rays.png"
        save_png(img, path)
    end)
end)

-- @describe Evidence: lurek.math curves and geometry reports
describe("Evidence: lurek.math curves and geometry reports", function()
    before_each(function()
        ensure_evidence_dir("math")
    end)
    -- Does: Runs "math_bezier_quadratic.png -- quadratic bezier sample curve" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.newBezierCurve and LBezierCurve:evaluate without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_bezier_quadratic.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.newBezierCurve and LBezierCurve:evaluate; export helpers are just the container.

    it("PNG: math_bezier_quadratic.png -- quadratic bezier sample curve", function()
        local img = lurek.image.newImageData(220, 200)
        img:fill(244, 244, 246, 255)

        local curve = lurek.math.newBezierCurve({ 20, 180, 110, 20, 200, 180 })
        expect_equal(3, curve:getControlPointCount())
        draw_curve(img, curve, 120, 50, 110, 220)

        local path = OUT .. "math_bezier_quadratic.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_bezier_cubic_tangent.png -- cubic bezier with tangent probe" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LBezierCurve:getDerivative and LBezierCurve:evaluate without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_bezier_cubic_tangent.png
    -- Why: This is meaningful only if the visible/text output comes from LBezierCurve:getDerivative and LBezierCurve:evaluate; export helpers are just the container.

    it("PNG: math_bezier_cubic_tangent.png -- cubic bezier with tangent probe", function()
        local img = lurek.image.newImageData(220, 200)
        img:fill(248, 248, 248, 255)

        local curve = lurek.math.newBezierCurve({ 20, 170, 60, 20, 160, 20, 200, 170 })
        expect_equal(4, curve:getControlPointCount())
        draw_curve(img, curve, 140, 220, 90, 60)

        local d = curve:getDerivative()
        local tx, ty = curve:evaluate(0.5)
        local dx, dy = d:evaluate(0.5)
        img:drawLine(tx, ty, tx + dx * 20, ty + dy * 20, 40, 40, 40, 255)

        local path = OUT .. "math_bezier_cubic_tangent.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_bezier_cubic_showcase.png -- single cubic bezier showcase" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.newBezierCurve and LBezierCurve:evaluate without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_bezier_cubic_showcase.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.newBezierCurve and LBezierCurve:evaluate; export helpers are just the container.

    it("PNG: math_bezier_cubic_showcase.png -- single cubic bezier showcase", function()
        local img = lurek.image.newImageData(256, 256)
        img:fill(25, 25, 25, 255)

        local points = { 16, 208, 64, 28, 184, 28, 240, 236 }
        local curve = lurek.math.newBezierCurve(points)
        draw_curve(img, curve, 140, 80, 80, 255)
        draw_control_points(img, points)

        local path = OUT .. "math_bezier_cubic_showcase.png"
        save_png(img, path)
    end)
    -- Does: Runs "math_bezier_crossing_pair.png -- paired bezier crossings" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.newBezierCurve and LBezierCurve:evaluate without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_bezier_crossing_pair.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.newBezierCurve and LBezierCurve:evaluate; export helpers are just the container.

    it("PNG: math_bezier_crossing_pair.png -- paired bezier crossings", function()
        local img = lurek.image.newImageData(256, 256)
        img:fill(25, 25, 25, 255)

        local a_points = { 16, 128, 80, 18, 172, 238, 240, 128 }
        local b_points = { 16, 128, 80, 238, 172, 18, 240, 128 }
        local a_curve = lurek.math.newBezierCurve(a_points)
        local b_curve = lurek.math.newBezierCurve(b_points)

        draw_curve(img, a_curve, 140, 255, 90, 90)
        draw_curve(img, b_curve, 140, 90, 255, 120)
        draw_control_points(img, a_points)
        draw_control_points(img, b_points)

        local path = OUT .. "math_bezier_crossing_pair.png"
        save_png(img, path)
    end)
    -- Does: Runs "quadratic easing curves" and turns the owner-module result into inspectable artifacts.
    -- Shows: Each PNG should expose one direct easing function instead of combining a whole family into one file.
    -- Artifact: tests/artifacts/current/math/math_easing_*.png
    -- Why: This is meaningful only if the visible/text output comes from direct lurek.math easing calls; export helpers are just the container.

    it("PNG: quadratic easing curves", function()
        save_easing_curve("math_easing_linear.png", lurek.math.linear, 100, 100, 100)
        save_easing_curve("math_easing_in_quad.png", lurek.math.inQuad, 220, 60, 60)
        save_easing_curve("math_easing_out_quad.png", lurek.math.outQuad, 60, 160, 60)
        save_easing_curve("math_easing_inout_quad.png", lurek.math.inOutQuad, 60, 60, 220)
    end)
    -- Does: Runs "cubic and bounce easing curves" and turns the owner-module result into inspectable artifacts.
    -- Shows: Each PNG should expose one direct easing function instead of combining cubic and bounce curves into one comparison file.
    -- Artifact: tests/artifacts/current/math/math_easing_*.png
    -- Why: This is meaningful only if the visible/text output comes from direct lurek.math easing calls; export helpers are just the container.

    it("PNG: cubic and bounce easing curves", function()
        save_easing_curve("math_easing_in_cubic.png", lurek.math.inCubic, 200, 80, 80)
        save_easing_curve("math_easing_out_cubic.png", lurek.math.outCubic, 80, 180, 80)
        save_easing_curve("math_easing_out_bounce.png", lurek.math.outBounce, 80, 80, 200)
    end)
    -- Does: Runs "math_line_intersection_report.txt -- line intersection coordinates" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.lineIntersect without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_line_intersection_report.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.lineIntersect; export helpers are just the container.

    it("TXT: math_line_intersection_report.txt -- line intersection coordinates", function()
        local x, y = lurek.math.lineIntersect(20, 20, 180, 180, 20, 180, 180, 20)
        local path = OUT .. "math_line_intersection_report.txt"
        write_text(path, string.format("ix=%.4f\niy=%.4f\n", tonumber(x) or -1, tonumber(y) or -1))
        expect_evidence_created(path)
    end)
    -- Does: Runs "math_polygon_algorithms_report.txt -- triangulation and convex hull counts" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.math.triangulate and lurek.math.convexHull without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/math/math_polygon_algorithms_report.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.math.triangulate and lurek.math.convexHull; export helpers are just the container.

    it("TXT: math_polygon_algorithms_report.txt -- triangulation and convex hull counts", function()
        local poly = { 140,20, 240,20, 190,120 }
        local tris = lurek.math.triangulate(poly)
        local hull = lurek.math.convexHull({ 20,20, 120,20, 120,120, 20,120, 70,70 })
        local path = OUT .. "math_polygon_algorithms_report.txt"
        local text = string.format(
            "triangles=%d\nhull_vertices=%d\n",
            type(tris) == "table" and #tris or 0,
            type(hull) == "table" and #hull or 0
        )
        write_text(path, text)
        expect_evidence_created(path)
    end)
end)
test_summary()
