-- Evidence tests: geometry module
-- Output-only evidence from direct lurek.math API calls.


local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

-- @describe evidence: geometry
describe("evidence: geometry", function()
    before_each(function()
        ensure_evidence_dir("geometry")
    end)

    -- @evidence file
    it("exports line intersection evidence as JSON", function()
        local dir = evidence_output_dir("geometry")
        local path = dir .. "line_intersection.json"
        local x, y = lurek.math.lineIntersect(20, 20, 180, 180, 20, 180, 180, 20)
        local json = string.format('{"ix":%.4f,"iy":%.4f}', tonumber(x) or -1, tonumber(y) or -1)
        write_text(path, json)
    end)

    -- @evidence file
    it("exports point-in-polygon classification as JSON", function()
        local dir = evidence_output_dir("geometry")
        local path = dir .. "point_in_polygon.json"
        local poly = { 40,160, 160,160, 100,40 }
        local pts = {
            {100,120}, {50,50}, {130,150}, {170,170}
        }
        local out = {}
        for i, p in ipairs(pts) do
            local inside = lurek.math.pointInPolygon(poly, p[1], p[2]) and "true" or "false"
            out[i] = string.format('{"x":%d,"y":%d,"inside":%s}', p[1], p[2], inside)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)

    -- @evidence file
    it("exports polygon area and centroid metrics as JSON", function()
        local dir = evidence_output_dir("geometry")
        local path = dir .. "polygon_metrics.json"

        local poly1 = { 20,20, 120,20, 120,120, 20,120 }
        local area1 = lurek.math.polygonArea(poly1)
        local cx1, cy1 = lurek.math.polygonCentroid(poly1)

        local poly2 = { 140,20, 240,20, 190,120 }
        local area2 = lurek.math.polygonArea(poly2)
        local cx2, cy2 = lurek.math.polygonCentroid(poly2)

        local tris = lurek.math.triangulate(poly2)
        local hull = lurek.math.convexHull({ 20,20, 120,20, 120,120, 20,120, 70,70 })

        local json = string.format(
            '{"square":{"area":%.4f,"cx":%.4f,"cy":%.4f},"triangle":{"area":%.4f,"cx":%.4f,"cy":%.4f},"triangles":%d,"hull_vertices":%d}',
            tonumber(area1) or 0,
            tonumber(cx1) or 0,
            tonumber(cy1) or 0,
            tonumber(area2) or 0,
            tonumber(cx2) or 0,
            tonumber(cy2) or 0,
            type(tris) == "table" and #tris or 0,
            type(hull) == "table" and #hull or 0
        )
        write_text(path, json)
    end)
end)

test_summary()
