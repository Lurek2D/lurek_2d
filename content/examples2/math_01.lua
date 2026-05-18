--- Math Module Part 2: geometry — distances, intersections, polygons

--@api-stub: lurek.math.distance
-- Euclidean distance between two points.
do
    local d = lurek.math.distance(0, 0, 3, 4)
    print("distance = " .. d)
end

--@api-stub: lurek.math.distanceSq
-- Squared distance between two points.
do
    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    print("distanceSq = " .. d2)
end

--@api-stub: lurek.math.angleBetween
-- Angle in radians between two points.
do
    local a = lurek.math.angleBetween(0, 0, 1, 0)
    print("angle to right = " .. a)
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    print("angle down = " .. b)
end

--@api-stub: lurek.math.closestPointOnSegment
-- Closest point on a line segment to a query point.
do
    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    print("closest on segment = " .. cx .. "," .. cy)
end

--@api-stub: lurek.math.lineIntersect
-- Infinite line-line intersection.
do
    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then
        print("lines cross at " .. ix .. "," .. iy)
    else
        print("lines are parallel")
    end
end

--@api-stub: lurek.math.segmentIntersectsSegment
-- Finite segment-segment intersection.
do
    local hit, ix, iy = lurek.math.segmentIntersectsSegment(
        0, 0, 10, 10,
        0, 10, 10, 0
    )
    if hit and ix then
        print("segments cross at " .. ix .. "," .. iy)
    else
        print("segments do not cross")
    end
end

--@api-stub: lurek.math.circleContainsPoint
-- Checks if a circle contains a point.
do
    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    print("inside = " .. tostring(inside))
end

--@api-stub: lurek.math.circleIntersectsCircle
-- Checks if two circles overlap.
do
    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    print("circles overlap = " .. tostring(hit))
end

--@api-stub: lurek.math.circleIntersectsLine
-- Checks if a circle intersects an infinite line.
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    print("circle/line hit = " .. tostring(hit))
    if hx1 then
        print("  hit1 = " .. hx1 .. "," .. hy1)
    end
    if hx2 then
        print("  hit2 = " .. hx2 .. "," .. hy2)
    end
end

--@api-stub: lurek.math.circleIntersectsSegment
-- Checks if a circle intersects a segment.
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    print("circle/seg hit = " .. tostring(hit))
    if hx1 then
        print("  seg hit1 = " .. hx1 .. "," .. hy1)
    end
    _ = hx2
    _ = hy2
end

--@api-stub: lurek.math.pointInPolygon
-- Tests if a point is inside a polygon.
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    print("inside = " .. tostring(inside) .. " outside = " .. tostring(outside))
end

--@api-stub: lurek.math.polygonArea
-- Returns area of a polygon.
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    print("area = " .. area)
end

--@api-stub: lurek.math.polygonCentroid
-- Returns centroid of a polygon.
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    print("centroid = " .. cx .. "," .. cy)
end

--@api-stub: lurek.math.isConvex
-- Tests if a polygon is convex.
do
    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    print("square convex = " .. tostring(lurek.math.isConvex(square)))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    print("concave = " .. tostring(lurek.math.isConvex(concave)))
end

--@api-stub: lurek.math.convexHull
-- Computes convex hull of a point set.
do
    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    print("hull vertices = " .. #hull / 2)
end

--@api-stub: lurek.math.polygonClip
-- Clips a polygon by a half-plane.
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    print("clipped vertices = " .. #clipped / 2)
end

--@api-stub: lurek.math.polygonUnion
-- Computes union of two polygons.
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonUnion(a, b)
    print("union vertices = " .. #result / 2)
end

--@api-stub: lurek.math.polygonIntersection
-- Computes intersection of two polygons.
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonIntersection(a, b)
    print("intersection vertices = " .. #result / 2)
end

--@api-stub: lurek.math.polygonDifference
-- Subtracts polygon b from polygon a.
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonDifference(a, b)
    print("difference vertices = " .. #result / 2)
end

--@api-stub: lurek.math.triangulate
-- Triangulates a polygon into triangles.
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    print("triangles = " .. #tris)
end

--@api-stub: lurek.math.delaunayTriangulate
-- Computes Delaunay triangulation of points.
do
    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    print("delaunay triangles = " .. #tris)
end

--@api-stub: lurek.math.bresenham
-- Generates integer points along a line.
do
    local pts = lurek.math.bresenham(0, 0, 5, 3)
    print("bresenham points = " .. #pts)
    for _, p in ipairs(pts) do
        print("  " .. p.x .. "," .. p.y)
    end
end

--@api-stub: lurek.math.rectFromCenter
-- Constructs a rect from center and dimensions.
do
    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: lurek.math.rectUnion
-- Merges two rectangles into their bounding rect.
do
    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    print("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

print("math_01.lua")
