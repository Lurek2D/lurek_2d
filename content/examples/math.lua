-- content/examples/math.lua
-- Auto-generated from content/examples2/math_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/math.lua

--- Math Module Part 1: basic math functions and trigonometry


--@api-stub: lurek.math.pi
-- Mathematical constants. Focus: pi.
do
    print("pi = " .. lurek.math.pi)
end

--@api-stub: lurek.math.tau
-- Mathematical constants. Focus: tau.
do
    print("tau = " .. lurek.math.tau)
end

--@api-stub: lurek.math.abs
-- Returns absolute value.
do
    print("abs(-5) = " .. lurek.math.abs(-5))
    print("abs(3) = " .. lurek.math.abs(3))
end

--@api-stub: lurek.math.ceil
-- Returns ceiling of a value.
do
    print("ceil(2.3) = " .. lurek.math.ceil(2.3))
    print("ceil(-1.7) = " .. lurek.math.ceil(-1.7))
end

--@api-stub: lurek.math.floor
-- Returns floor of a value.
do
    print("floor(2.9) = " .. lurek.math.floor(2.9))
    print("floor(-1.1) = " .. lurek.math.floor(-1.1))
end

--@api-stub: lurek.math.round
-- Returns rounded value.
do
    print("round(2.4) = " .. lurek.math.round(2.4))
    print("round(2.5) = " .. lurek.math.round(2.5))
end

--@api-stub: lurek.math.sign
-- Returns sign of a value (-1, 0, or 1).
do
    print("sign(-7) = " .. lurek.math.sign(-7))
    print("sign(0) = " .. lurek.math.sign(0))
    print("sign(3) = " .. lurek.math.sign(3))
end

--@api-stub: lurek.math.clamp
-- Clamps a value to a range.
do
    print("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10))
    print("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10))
    print("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10))
end

--@api-stub: lurek.math.lerp
-- Linearly interpolates between two values.
do
    print("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5))
    print("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25))
end

--@api-stub: lurek.math.inverseLerp
-- Returns interpolation factor of a value between two bounds.
do
    print("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50))
    print("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15))
end

--@api-stub: lurek.math.remap
-- Remaps a value from one range to another.
do
    local v = lurek.math.remap(5, 0, 10, 0, 100)
    print("remap(5, 0-10 → 0-100) = " .. v)
end

--@api-stub: lurek.math.smoothstep
-- Applies smoothstep interpolation.
do
    print("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5))
    print("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0))
    print("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0))
end

--@api-stub: lurek.math.pow
-- Raises a value to a power.
do
    print("pow(2, 10) = " .. lurek.math.pow(2, 10))
    print("pow(3, 3) = " .. lurek.math.pow(3, 3))
end

--@api-stub: lurek.math.sqrt
-- Returns square root.
do
    print("sqrt(144) = " .. lurek.math.sqrt(144))
    print("sqrt(2) = " .. lurek.math.sqrt(2))
end

--@api-stub: lurek.math.exp
-- Returns exponential.
do
    print("exp(1) = " .. lurek.math.exp(1))
    print("exp(0) = " .. lurek.math.exp(0))
end

--@api-stub: lurek.math.log
-- Returns natural logarithm or log with base.
do
    print("log(e) = " .. lurek.math.log(lurek.math.exp(1)))
    print("log(100, 10) = " .. lurek.math.log(100, 10))
end

--@api-stub: lurek.math.fmod
-- Returns floating-point remainder.
do
    print("fmod(7, 3) = " .. lurek.math.fmod(7, 3))
    print("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3))
end

--@api-stub: lurek.math.min
-- Returns minimum or maximum. Focus: min.
do
    print("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
end

--@api-stub: lurek.math.max
-- Returns minimum or maximum. Focus: max.
do
    print("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9))
end

--@api-stub: lurek.math.sin
-- Returns sine of an angle in radians.
do
    print("sin(0) = " .. lurek.math.sin(0))
    print("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2))
end

--@api-stub: lurek.math.cos
-- Returns cosine of an angle in radians.
do
    print("cos(0) = " .. lurek.math.cos(0))
    print("cos(pi) = " .. lurek.math.cos(lurek.math.pi))
end

--@api-stub: lurek.math.tan
-- Returns tangent of an angle in radians.
do
    print("tan(0) = " .. lurek.math.tan(0))
    print("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4))
end

--@api-stub: lurek.math.asin
-- Returns arcsine.
do
    print("asin(1) = " .. lurek.math.asin(1))
    print("asin(0) = " .. lurek.math.asin(0))
end

--@api-stub: lurek.math.acos
-- Returns arccosine.
do
    print("acos(1) = " .. lurek.math.acos(1))
    print("acos(0) = " .. lurek.math.acos(0))
end

--@api-stub: lurek.math.atan
-- Returns arctangent (one or two argument).
do
    print("atan(1) = " .. lurek.math.atan(1))
    print("atan(1, 1) = " .. lurek.math.atan(1, 1))
end

--@api-stub: lurek.math.atan2
-- Returns two-argument arctangent.
do
    print("atan2(1, 0) = " .. lurek.math.atan2(1, 0))
    print("atan2(0, 1) = " .. lurek.math.atan2(0, 1))
end

--@api-stub: lurek.math.deg
-- Converts radians to degrees.
do
    print("deg(pi) = " .. lurek.math.deg(lurek.math.pi))
    print("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2))
end

--@api-stub: lurek.math.rad
-- Converts degrees to radians.
do
    print("rad(180) = " .. lurek.math.rad(180))
    print("rad(90) = " .. lurek.math.rad(90))
end

--@api-stub: lurek.math.random
-- Returns a random value.
do
    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    print("random = " .. r1 .. ", " .. r2 .. ", " .. r3)
end

--@api-stub: lurek.math.randomInt
-- Returns a random integer in an inclusive range.
do
    local r = lurek.math.randomInt(1, 6)
    print("randomInt(1,6) = " .. r)
end

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
    print("union vertices = " .. #result)
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

--- Math Module Part 3: curves — Bezier, Catmull-Rom, Hermite


--@api-stub: lurek.math.newBezierCurve
-- Creates a cubic Bezier curve from a flat point table.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    print("control points = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:evaluate
-- Evaluates the curve at parameter t.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = bz:evaluate(0.5)
    print("mid point = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:evaluateAtDistance
-- Evaluates the curve at arc-length distance.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local len = bz:length()
    local x, y = bz:evaluateAtDistance(len * 0.5, 20)
    print("half-arc point = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:getControlPoint
-- Reads and writes individual control points. Focus: getControlPoint.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local px, py = bz:getControlPoint(2)
    print("cp2 = " .. px .. "," .. py)
    bz:setControlPoint(2, 50, 80)
    local nx, ny = bz:getControlPoint(2)
    print("cp2 moved = " .. nx .. "," .. ny)
end

--@api-stub: LBezierCurve:setControlPoint
-- Reads and writes individual control points. Focus: setControlPoint.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local px, py = bz:getControlPoint(2)
    print("cp2 = " .. px .. "," .. py)
    bz:setControlPoint(2, 50, 80)
    local nx, ny = bz:getControlPoint(2)
    print("cp2 moved = " .. nx .. "," .. ny)
end

--@api-stub: LBezierCurve:insertControlPoint
-- Adds and removes control points. Focus: insertControlPoint.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0})
    print("count before = " .. bz:getControlPointCount())
    bz:insertControlPoint(50, 50)
    print("count after insert = " .. bz:getControlPointCount())
    bz:removeControlPoint(2)
    print("count after remove = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:removeControlPoint
-- Adds and removes control points. Focus: removeControlPoint.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0})
    print("count before = " .. bz:getControlPointCount())
    bz:insertControlPoint(50, 50)
    print("count after insert = " .. bz:getControlPointCount())
    bz:removeControlPoint(2)
    print("count after remove = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:length
-- Returns the arc length of the curve.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0})
    local l = bz:length()
    print("line length = " .. l)
end

--@api-stub: LBezierCurve:render
-- Renders the curve as a polyline.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local pts = bz:render(10)
    print("rendered points = " .. #pts)
end

--@api-stub: LBezierCurve:getDerivative
-- Returns the derivative curve.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local deriv = bz:getDerivative()
    print("derivative CPs = " .. deriv:getControlPointCount())
end

--@api-stub: LBezierCurve:translate
-- Transforms the curve in place. Focus: translate.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:rotate
-- Transforms the curve in place. Focus: rotate.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:scale
-- Transforms the curve in place. Focus: scale.
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: lurek.math.catmullRom
-- Creates a Catmull-Rom spline from point tables.
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    print("catmull-rom points = " .. cr:len())
end

--@api-stub: LCatmullRom:sample
-- Samples a point along the full spline.
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    local x, y = cr:sample(0.5)
    print("mid = " .. x .. "," .. y)
end

--@api-stub: LCatmullRom:sampleSegment
-- Samples on a specific segment.
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    local x, y = cr:sampleSegment(1, 0.5)
    print("seg1 mid = " .. x .. "," .. y)
end

--@api-stub: LCatmullRom:addPoint
-- Adds and removes points. Focus: addPoint.
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20}})
    cr:addPoint(150, 60)
    print("after add = " .. cr:len())
    local rx, ry = cr:removePoint(2)
    print("removed = " .. rx .. "," .. ry .. " len = " .. cr:len())
end

--@api-stub: LCatmullRom:removePoint
-- Adds and removes points. Focus: removePoint.
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20}})
    cr:addPoint(150, 60)
    print("after add = " .. cr:len())
    local rx, ry = cr:removePoint(2)
    print("removed = " .. rx .. "," .. ry .. " len = " .. cr:len())
end

--@api-stub: lurek.math.hermite
-- Creates a Hermite spline from two points and tangents.
do
    ---@type LHermite
    local h = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100)
    local x, y = h:sample(0.5)
    print("hermite mid = " .. x .. "," .. y)

    -- Sampling at t=0 and t=1.
    ---@type LHermite
    local h = lurek.math.hermite(10, 20, 80, 90, 40, 0, -40, 0)
    local x0, y0 = h:sample(0)
    local x1, y1 = h:sample(1)
    print("start = " .. x0 .. "," .. y0)
    print("end   = " .. x1 .. "," .. y1)
end

--- Math Module Part 4: noise — LNoiseGenerator + stateless noise functions


--@api-stub: lurek.math.newNoiseGenerator
-- Creates a noise generator with an optional seed.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(42)
    print("seed = " .. ng:getSeed())
end

--@api-stub: LNoiseGenerator:perlin1d
-- Samples Perlin noise at various dimensions. Focus: perlin1d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(123)
    local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin2d
-- Samples Perlin noise at various dimensions. Focus: perlin2d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(123)
    local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin3d
-- Samples Perlin noise at various dimensions. Focus: perlin3d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(123)
    local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin4d
-- Samples Perlin noise at various dimensions. Focus: perlin4d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(123)
    local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:simplex1d
-- Samples simplex noise at various dimensions. Focus: simplex1d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:simplex2d
-- Samples simplex noise at various dimensions. Focus: simplex2d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:simplex3d
-- Samples simplex noise at various dimensions. Focus: simplex3d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:worley2d
-- Samples Worley (cellular) noise. Focus: worley2d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(55)
    local w2 = ng:worley2d(3.5, 4.5)
    local w2m = ng:worley2d(3.5, 4.5, "manhattan")
    local w2f = ng:worley2d(3.5, 4.5, "euclidean", true)
    local w3 = ng:worley3d(1.0, 2.0, 3.0)
    print("worley2d=" .. w2 .. " manhattan=" .. w2m .. " f2=" .. w2f .. " 3d=" .. w3)
end

--@api-stub: LNoiseGenerator:worley3d
-- Samples Worley (cellular) noise. Focus: worley3d.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(55)
    local w2 = ng:worley2d(3.5, 4.5)
    local w2m = ng:worley2d(3.5, 4.5, "manhattan")
    local w2f = ng:worley2d(3.5, 4.5, "euclidean", true)
    local w3 = ng:worley3d(1.0, 2.0, 3.0)
    print("worley2d=" .. w2 .. " manhattan=" .. w2m .. " f2=" .. w2f .. " 3d=" .. w3)
end

--@api-stub: LNoiseGenerator:fbm
-- Fractal Brownian motion noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:fbm(2.5, 3.5)
    local v2 = ng:fbm(2.5, 3.5, 6, 2.0, 0.5, "simplex")
    print("fbm default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:ridged
-- Ridged fractal noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:ridged(2.5, 3.5)
    local v2 = ng:ridged(2.5, 3.5, 8, 2.5, 0.6, "perlin")
    print("ridged default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:turbulence
-- Turbulence fractal noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:turbulence(1.0, 2.0)
    local v2 = ng:turbulence(1.0, 2.0, 5, 2.0, 0.5, "simplex")
    print("turbulence default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:warpDomain
-- Domain-warped noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(13)
    local v = ng:warpDomain(3.0, 4.0, 0.5)
    print("warped = " .. v)
end

--@api-stub: LNoiseGenerator:generateMap
-- Generates a flat array noise map.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMap(16, 16, {scale = 4.0, octaves = 4, kind = "perlin"})
    print("map size = " .. #map .. " sample = " .. map[1])
end

--@api-stub: LNoiseGenerator:generateMapCompute
-- Generates a noise map through the compute backend.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMapCompute(32, 32, {scale = 8.0})
    print("compute map size = " .. #map)
end

--@api-stub: LNoiseGenerator:setSeed
-- Changes the noise seed. Focus: setSeed.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(0)
    ng:setSeed(999)
    print("new seed = " .. ng:getSeed())
end

--@api-stub: LNoiseGenerator:getSeed
-- Changes the noise seed. Focus: getSeed.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(0)
    ng:setSeed(999)
    print("new seed = " .. ng:getSeed())
end

--@api-stub: lurek.math.perlin2d
-- Stateless 2D Perlin noise.
do
    local v = lurek.math.perlin2d(5.0, 3.0)
    local v2 = lurek.math.perlin2d(5.0, 3.0, 42)
    print("stateless perlin2d = " .. v .. " seeded = " .. v2)
end

--@api-stub: lurek.math.perlin3d
-- Stateless 3D Perlin noise.
do
    local v = lurek.math.perlin3d(1.0, 2.0, 3.0)
    local v2 = lurek.math.perlin3d(1.0, 2.0, 3.0, 77)
    print("stateless perlin3d = " .. v .. " seeded = " .. v2)

    -- Global noise functions (no generator instance needed). Focus: perlin3d.
    local v1 = lurek.math.fbm(0.5, 0.5, 4, 0.5, 2.0)
    local v2 = lurek.math.perlin2d(0.3, 0.7)
    local v3 = lurek.math.perlin3d(0.1, 0.2, 0.3)
    local v4 = lurek.math.simplex2d(0.4, 0.6)
    local v5 = lurek.math.simplexNoise(0.5, 0.5)
    print(v1, v2, v3, v4, v5)
end

--@api-stub: lurek.math.simplex2d
-- Stateless 2D simplex noise.
do
    local v = lurek.math.simplex2d(2.0, 3.0)
    local v2 = lurek.math.simplex2d(2.0, 3.0, 10)
    print("stateless simplex2d = " .. v .. " seeded = " .. v2)
end

--@api-stub: lurek.math.simplexNoise
-- Stateless 2D/3D simplex noise.
do
    local v2d = lurek.math.simplexNoise(4.0, 5.0)
    local v3d = lurek.math.simplexNoise(4.0, 5.0, 6.0)
    print("simplexNoise 2d=" .. v2d .. " 3d=" .. v3d)

    -- Global noise functions (no generator instance needed). Focus: simplexNoise.
    local v1 = lurek.math.fbm(0.5, 0.5, 4, 0.5, 2.0)
    local v2 = lurek.math.perlin2d(0.3, 0.7)
    local v3 = lurek.math.perlin3d(0.1, 0.2, 0.3)
    local v4 = lurek.math.simplex2d(0.4, 0.6)
    local v5 = lurek.math.simplexNoise(0.5, 0.5)
    print(v1, v2, v3, v4, v5)
end

--@api-stub: lurek.math.fbm
-- Stateless fractal Brownian motion.
do
    local v = lurek.math.fbm(1.0, 2.0, 42)
    local v2 = lurek.math.fbm(1.0, 2.0, 42, 6, 2.0, 0.5)
    print("stateless fbm = " .. v .. " custom = " .. v2)
end

--- Math Module Part 5: vectors (LVec2, LVec3) and transforms (LTransform)


--@api-stub: lurek.math.vec2
-- Creates a 2D vector. Focus: vec2.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
end

--@api-stub: lurek.math.Vec2
-- Creates a 2D vector. Focus: Vec2.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:length
-- Vector magnitude. Focus: length.
do
    ---@type LVec2
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec2:lengthSquared
-- Vector magnitude. Focus: lengthSquared.
do
    ---@type LVec2
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec2:normalize
-- Unit vector. Focus: normalize.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
    v:normalize()
    print("after normalize = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:normalized
-- Unit vector. Focus: normalized.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
    v:normalize()
    print("after normalize = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:dot
-- Dot product and cross product. Focus: dot.
do
    ---@type LVec2
    local a = lurek.math.vec2(1, 0)
    ---@type LVec2
    local b = lurek.math.vec2(0, 1)
    print("dot = " .. a:dot(b))
    print("cross = " .. a:cross(b))
end

--@api-stub: LVec2:cross
-- Dot product and cross product. Focus: cross.
do
    ---@type LVec2
    local a = lurek.math.vec2(1, 0)
    ---@type LVec2
    local b = lurek.math.vec2(0, 1)
    print("dot = " .. a:dot(b))
    print("cross = " .. a:cross(b))
end

--@api-stub: LVec2:distance
-- Distance between two vectors.
do
    ---@type LVec2
    local a = lurek.math.vec2(0, 0)
    ---@type LVec2
    local b = lurek.math.vec2(3, 4)
    print("distance = " .. a:distance(b))
end

--@api-stub: LVec2:angle
-- Angle of the vector.
do
    ---@type LVec2
    local v = lurek.math.vec2(1, 1)
    print("angle = " .. v:angle())
end

--@api-stub: LVec2:lerp
-- Interpolates between two vectors.
do
    ---@type LVec2
    local a = lurek.math.vec2(0, 0)
    ---@type LVec2
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y)
end

--@api-stub: LVec2:rotate
-- Rotates the vector.
do
    ---@type LVec2
    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(math.pi / 2)
    print("rotated = " .. r.x .. "," .. r.y)
end

--@api-stub: LVec2:perpendicular
-- Returns the perpendicular vector.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    print("perp = " .. p.x .. "," .. p.y)
end

--@api-stub: LVec2:reflect
-- Reflects the vector against a normal.
do
    ---@type LVec2
    local v = lurek.math.vec2(1, -1)
    ---@type LVec2
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    print("reflected = " .. ref.x .. "," .. ref.y)
end

--@api-stub: LVec2:fromAngle
-- Creates a unit vector from an angle.
do
    ---@type LVec2
    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(0)
    print("fromAngle(0) = " .. unit.x .. "," .. unit.y)
end

--@api-stub: lurek.math.vec3
-- Creates a 3D vector. Focus: vec3.
do
    ---@type LVec3
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
end

--@api-stub: lurek.math.Vec3
-- Creates a 3D vector. Focus: Vec3.
do
    ---@type LVec3
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
end

--@api-stub: LVec3:length
-- 3D vector magnitude. Focus: length.
do
    ---@type LVec3
    local v = lurek.math.Vec3(1, 2, 2)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec3:lengthSquared
-- 3D vector magnitude. Focus: lengthSquared.
do
    ---@type LVec3
    local v = lurek.math.Vec3(1, 2, 2)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec3:normalize
-- Normalizes a 3D vector.
do
    ---@type LVec3
    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    print("normalized = " .. n.x .. "," .. n.y .. "," .. n.z)
end

--@api-stub: LVec3:dot
-- 3D dot and cross products. Focus: dot.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 0, 0)
    ---@type LVec3
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api-stub: LVec3:cross
-- 3D dot and cross products. Focus: cross.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 0, 0)
    ---@type LVec3
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api-stub: LVec3:add
-- 3D vector arithmetic. Focus: add.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 2, 3)
    ---@type LVec3
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    local diff = a:sub(b)
    local scaled = a:scale(2)
    print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:sub
-- 3D vector arithmetic. Focus: sub.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 2, 3)
    ---@type LVec3
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    local diff = a:sub(b)
    local scaled = a:scale(2)
    print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:scale
-- 3D vector arithmetic. Focus: scale.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 2, 3)
    ---@type LVec3
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    local diff = a:sub(b)
    local scaled = a:scale(2)
    print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:distance
-- 3D distance and interpolation. Focus: distance.
do
    ---@type LVec3
    local a = lurek.math.vec3(0, 0, 0)
    ---@type LVec3
    local b = lurek.math.vec3(3, 4, 0)
    print("distance = " .. a:distance(b))
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
end

--@api-stub: LVec3:lerp
-- 3D distance and interpolation. Focus: lerp.
do
    ---@type LVec3
    local a = lurek.math.vec3(0, 0, 0)
    ---@type LVec3
    local b = lurek.math.vec3(3, 4, 0)
    print("distance = " .. a:distance(b))
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
end

--@api-stub: LVec3:splat
-- Creates a vector with all components equal.
do
    ---@type LVec3
    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    print("splat = " .. s.x .. "," .. s.y .. "," .. s.z)
end

--@api-stub: lurek.math.newTransform
-- Creates a 2D affine transform.
do
    ---@type LTransform
    local t = lurek.math.newTransform(100, 200, math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    print("origin transformed = " .. x .. "," .. y)
end

--@api-stub: LTransform:translate
-- Incremental transform operations. Focus: translate.
do
    ---@type LTransform
    local t = lurek.math.newTransform()
    t:translate(50, 50)
    t:rotate(math.pi / 6)
    t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:rotate
-- Incremental transform operations. Focus: rotate.
do
    ---@type LTransform
    local t = lurek.math.newTransform()
    t:translate(50, 50)
    t:rotate(math.pi / 6)
    t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:scale
-- Incremental transform operations. Focus: scale.
do
    ---@type LTransform
    local t = lurek.math.newTransform()
    t:translate(50, 50)
    t:rotate(math.pi / 6)
    t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:shear
-- Incremental transform operations. Focus: shear.
do
    ---@type LTransform
    local t = lurek.math.newTransform()
    t:translate(50, 50)
    t:rotate(math.pi / 6)
    t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:transformPoint
-- Forward and inverse point mapping. Focus: transformPoint.
do
    ---@type LTransform
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api-stub: LTransform:inverseTransformPoint
-- Forward and inverse point mapping. Focus: inverseTransformPoint.
do
    ---@type LTransform
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api-stub: LTransform:clone
-- Cloning and inversion. Focus: clone.
do
    ---@type LTransform
    local t = lurek.math.newTransform(10, 20, 0.5)
    local c = t:clone()
    local inv = t:inverse()
    local x, y = t:transformPoint(0, 0)
    local rx, ry = inv:transformPoint(x, y)
    print("original point = " .. x .. "," .. y)
    print("roundtrip = " .. rx .. "," .. ry)
    _ = c
end

--@api-stub: LTransform:inverse
-- Cloning and inversion. Focus: inverse.
do
    ---@type LTransform
    local t = lurek.math.newTransform(10, 20, 0.5)
    local c = t:clone()
    local inv = t:inverse()
    local x, y = t:transformPoint(0, 0)
    local rx, ry = inv:transformPoint(x, y)
    print("original point = " .. x .. "," .. y)
    print("roundtrip = " .. rx .. "," .. ry)
    _ = c
end

--@api-stub: LTransform:decompose
-- Decomposes into translation, rotation, and scale.
do
    ---@type LTransform
    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    print("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy)
end

--@api-stub: LTransform:getMatrix
-- Gets raw matrix data.
do
    ---@type LTransform
    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    print("matrix elements = " .. #m)
end

--@api-stub: LTransform:reset
-- Resets or completely replaces the transform. Focus: reset.
do
    ---@type LTransform
    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x1, y1 = t:transformPoint(10, 10)
    print("after reset = " .. x1 .. "," .. y1)
    t:setTransformation(0, 0, math.pi, 1, 1)
    local x2, y2 = t:transformPoint(10, 0)
    print("after set = " .. x2 .. "," .. y2)
end

--@api-stub: LTransform:setTransformation
-- Resets or completely replaces the transform. Focus: setTransformation.
do
    ---@type LTransform
    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x1, y1 = t:transformPoint(10, 10)
    print("after reset = " .. x1 .. "," .. y1)
    t:setTransformation(0, 0, math.pi, 1, 1)
    local x2, y2 = t:transformPoint(10, 0)
    print("after set = " .. x2 .. "," .. y2)
end

--- Math Module Part 6: random, tween, spatial, circle, color, easings


--@api-stub: lurek.math.newRandomGenerator
-- Creates a deterministic random generator.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(42)
    print("seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:random
-- Random value generators. Focus: random.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(100)
    local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomFloat
-- Random value generators. Focus: randomFloat.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(100)
    local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomInt
-- Random value generators. Focus: randomInt.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(100)
    local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomNormal
-- Random value generators. Focus: randomNormal.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(100)
    local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:setSeed
-- Seed and state management. Focus: setSeed.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:getState
-- Seed and state management. Focus: getState.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:setState
-- Seed and state management. Focus: setState.
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: lurek.math.newTween
-- Creates a tween with duration and optional easing.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0, "inOutCubic")
    print("duration = " .. tw:getDuration())
    print("easing = " .. tw:getEasingName())
end

--@api-stub: LTween:addValue
-- Tweened value channels. Focus: addValue.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "linear")
    local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
    tw:setTime(0.5)
    print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getValue
-- Tweened value channels. Focus: getValue.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "linear")
    local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
    tw:setTime(0.5)
    print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getAllValues
-- Tweened value channels. Focus: getAllValues.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "linear")
    local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
    tw:setTime(0.5)
    print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getValueCount
-- Tweened value channels. Focus: getValueCount.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "linear")
    local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
    tw:setTime(0.5)
    print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:update
-- Tween playback. Focus: update.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6)
    print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:isComplete
-- Tween playback. Focus: isComplete.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6)
    print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:reset
-- Tween playback. Focus: reset.
do
    ---@type LTween
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6)
    print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:set
-- Direct time control. Focus: set.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:setTime
-- Direct time control. Focus: setTime.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:getTime
-- Direct time control. Focus: getTime.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:getClock
-- Direct time control. Focus: getClock.
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: lurek.math.aabbTree
-- Creates an AABB tree for broad-phase queries.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:insert(3, 100, 100, 110, 110)
    print("len = " .. tree:len() .. " empty = " .. tostring(tree:isEmpty()))
end

--@api-stub: LAabbTree:query
-- Spatial queries and mutation. Focus: query.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:queryPoint
-- Spatial queries and mutation. Focus: queryPoint.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:contains
-- Spatial queries and mutation. Focus: contains.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:remove
-- Spatial queries and mutation. Focus: remove.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:update
-- Spatial queries and mutation. Focus: update.
do
    ---@type LAabbTree
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7)
    print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1)))
    tree:update(1, 20, 20, 30, 30)
    tree:remove(2)
    print("after remove len = " .. tree:len())
end

--@api-stub: lurek.math.newSpatialHash
-- Creates a spatial hash for broad-phase queries.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    print("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:queryRect
-- Spatial hash queries. Focus: queryRect.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:queryCircle
-- Spatial hash queries. Focus: queryCircle.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:querySegment
-- Spatial hash queries. Focus: querySegment.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:remove
-- Spatial hash queries. Focus: remove.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:update
-- Spatial hash queries. Focus: update.
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10)
    local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10)
    local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s)
    sh:update("a", 200, 200, 10, 10)
    sh:remove("c")
    print("items after = " .. sh:getItemCount())
end

--@api-stub: lurek.math.newRectPacker
-- Creates a rectangle packer.
do
    ---@type LRectPacker
    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x1, y1 = rp:pack(32, 32, "icon1")
    local x2, y2 = rp:pack(64, 64, "icon2")
    if x1 and y1 then
        print("icon1 at " .. x1 .. "," .. y1)
    end
    if x2 and y2 then
        print("icon2 at " .. x2 .. "," .. y2)
    end
    print("occupancy = " .. rp:occupancy())
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    rp:clear()
end

--@api-stub: lurek.math.newCircle
-- Creates a circle primitive.
do
    ---@type LCircle
    local c = lurek.math.newCircle(50, 50, 25)
    print("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    print("area = " .. c:area())
    print("perimeter = " .. c:perimeter())
end

--@api-stub: LCircle:contains
-- Circle spatial tests. Focus: contains.
do
    ---@type LCircle
    local c1 = lurek.math.newCircle(0, 0, 10)
    ---@type LCircle
    local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: LCircle:intersects
-- Circle spatial tests. Focus: intersects.
do
    ---@type LCircle
    local c1 = lurek.math.newCircle(0, 0, 10)
    ---@type LCircle
    local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: LCircle:aabb
-- Circle spatial tests. Focus: aabb.
do
    ---@type LCircle
    local c1 = lurek.math.newCircle(0, 0, 10)
    ---@type LCircle
    local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: lurek.math.fromHex
-- Converts a hex color string to RGBA channels.
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("fromHex = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.math.hslToRgb
-- HSL ↔ RGB conversion.
do
    local r, g, b, a = lurek.math.hslToRgb(0.0, 1.0, 0.5)
    print("hsl(0,1,0.5) = " .. r .. "," .. g .. "," .. b .. "," .. a)
    local h, s, l = lurek.math.rgbToHsl(1.0, 0.0, 0.0)
    print("red → hsl = " .. h .. "," .. s .. "," .. l)
end

--@api-stub: lurek.math.gammaToLinear
-- Gamma ↔ linear color space conversion.
do
    local lin = lurek.math.gammaToLinear(0.5)
    local gam = lurek.math.linearToGamma(lin)
    print("gamma→linear→gamma = " .. gam)
end

--@api-stub: lurek.math.applyEasing
-- Applies a named easing function.
do
    local v1 = lurek.math.applyEasing("linear", 0.5)
    local v2 = lurek.math.applyEasing("inOutCubic", 0.5)
    local v3 = lurek.math.applyEasing("outBounce", 0.8)
    print("linear=" .. v1 .. " inOutCubic=" .. v2 .. " outBounce=" .. v3)
end

--@api-stub: lurek.math.inBack
-- Direct easing function calls.
do
    local a = lurek.math.inBack(0.5)
    local b = lurek.math.outBack(0.5)
    local c = lurek.math.inOutBack(0.5)
    print("inBack=" .. a .. " outBack=" .. b .. " inOutBack=" .. c)
end

--@api-stub: lurek.math.inBounce
-- Bounce easing functions.
do
    local a = lurek.math.inBounce(0.7)
    local b = lurek.math.outBounce(0.7)
    local c = lurek.math.inOutBounce(0.7)
    print("inBounce=" .. a .. " outBounce=" .. b .. " inOutBounce=" .. c)
end

--- Math Module: easing functions, applyEasing, LRandomGenerator, LNoiseGenerator


--@api-stub: lurek.math.inCubic
-- In-family easing functions (t in [0,1] → eased value). Focus: inCubic.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inElastic
-- In-family easing functions (t in [0,1] → eased value). Focus: inElastic.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inExpo
-- In-family easing functions (t in [0,1] → eased value). Focus: inExpo.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inQuad
-- In-family easing functions (t in [0,1] → eased value). Focus: inQuad.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inQuart
-- In-family easing functions (t in [0,1] → eased value). Focus: inQuart.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inSine
-- In-family easing functions (t in [0,1] → eased value). Focus: inSine.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.linear
-- In-family easing functions (t in [0,1] → eased value). Focus: linear.
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.outBack
-- Out-family easing functions. Focus: outBack.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outBounce
-- Out-family easing functions. Focus: outBounce.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outCubic
-- Out-family easing functions. Focus: outCubic.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outElastic
-- Out-family easing functions. Focus: outElastic.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outExpo
-- Out-family easing functions. Focus: outExpo.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outQuad
-- Out-family easing functions. Focus: outQuad.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outQuart
-- Out-family easing functions. Focus: outQuart.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outSine
-- Out-family easing functions. Focus: outSine.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.inOutBack
-- InOut-family easing functions. Focus: inOutBack.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutBounce
-- InOut-family easing functions. Focus: inOutBounce.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutCubic
-- InOut-family easing functions. Focus: inOutCubic.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutElastic
-- InOut-family easing functions. Focus: inOutElastic.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutExpo
-- InOut-family easing functions. Focus: inOutExpo.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutQuad
-- InOut-family easing functions. Focus: inOutQuad.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutQuart
-- InOut-family easing functions. Focus: inOutQuart.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutSine
-- InOut-family easing functions. Focus: inOutSine.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: LRandomGenerator:getSeed
-- Random generator extended operations. Focus: getSeed.
do
    local rng = lurek.math.newRandomGenerator()
    local seed = rng:getSeed()
    print("seed = " .. seed)
    local state = rng:getState()
    print("state = " .. tostring(state))
    local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100)
    local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n)
    rng:setState(state)
    print(rng:type())
    print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: LRandomGenerator:type
-- Random generator extended operations. Focus: type.
do
    local rng = lurek.math.newRandomGenerator()
    local seed = rng:getSeed()
    print("seed = " .. seed)
    local state = rng:getState()
    print("state = " .. tostring(state))
    local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100)
    local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n)
    rng:setState(state)
    print(rng:type())
    print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: LRandomGenerator:typeOf
-- Random generator extended operations. Focus: typeOf.
do
    local rng = lurek.math.newRandomGenerator()
    local seed = rng:getSeed()
    print("seed = " .. seed)
    local state = rng:getState()
    print("state = " .. tostring(state))
    local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100)
    local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n)
    rng:setState(state)
    print(rng:type())
    print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: lurek.math.linearToGamma
-- Color conversion utilities. Focus: linearToGamma.
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("hex", r, g, b, a)
    local lr = lurek.math.gammaToLinear(r)
    print("linear", lr)
    local gr = lurek.math.linearToGamma(lr)
    print("gamma", gr)
    local h, s, l = lurek.math.rgbToHsl(r, g, b)
    print("hsl", h, s, l)
    local r2, g2, b2 = lurek.math.hslToRgb(h, s, l)
    print("rgb", r2, g2, b2)
end

--@api-stub: lurek.math.rgbToHsl
-- Color conversion utilities. Focus: rgbToHsl.
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("hex", r, g, b, a)
    local lr = lurek.math.gammaToLinear(r)
    print("linear", lr)
    local gr = lurek.math.linearToGamma(lr)
    print("gamma", gr)
    local h, s, l = lurek.math.rgbToHsl(r, g, b)
    print("hsl", h, s, l)
    local r2, g2, b2 = lurek.math.hslToRgb(h, s, l)
    print("rgb", r2, g2, b2)
end

--- Math Module: object APIs — LAabbTree, LBezierCurve, LCatmullRom, LCircle,
---               LHermite, LRectPacker, LSpatialHash, LTransform, LVec2, LVec3


--@api-stub: LAabbTree:clear
-- AABB spatial tree: insert, query, update, remove, clear. Focus: clear.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LAabbTree:insert
-- AABB spatial tree: insert, query, update, remove, clear. Focus: insert.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LAabbTree:isEmpty
-- AABB spatial tree: insert, query, update, remove, clear. Focus: isEmpty.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LAabbTree:len
-- AABB spatial tree: insert, query, update, remove, clear. Focus: len.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LAabbTree:type
-- AABB spatial tree: insert, query, update, remove, clear. Focus: type.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LAabbTree:typeOf
-- AABB spatial tree: insert, query, update, remove, clear. Focus: typeOf.
do
    local tree = lurek.math.aabbTree()
    print(tree:isEmpty())
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print(tree:len())
    print(tree:contains(1))
    local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits)
    local pt = tree:queryPoint(25, 25)
    print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55)
    tree:remove(2)
    print(tree:type())
    print(tree:typeOf("LAabbTree"))
    tree:clear()
    print(tree:isEmpty())
end

--@api-stub: LBezierCurve:getControlPointCount
-- Bezier curve: control points, evaluation, transform, render. Focus: getControlPointCount.
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 })
    print(bc:getControlPointCount())
    local x, y = bc:getControlPoint(1)
    print("cp1 = " .. x .. ", " .. y)
    bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60)
    bc:removeControlPoint(4)
    local ex, ey = bc:evaluate(0.5)
    print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative()
    print("deriv = " .. dx .. ", " .. dy)
    local dist_x, dist_y = bc:evaluateAtDistance(50, 100)
    print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length())
    local pts = bc:render(20)
    print("render pts = " .. #pts)
    bc:translate(10, 5)
    bc:rotate(0.1, 0, 0)
    bc:scale(1.0, 0, 0)
    print(bc:type())
    print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LBezierCurve:type
-- Bezier curve: control points, evaluation, transform, render. Focus: type.
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 })
    print(bc:getControlPointCount())
    local x, y = bc:getControlPoint(1)
    print("cp1 = " .. x .. ", " .. y)
    bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60)
    bc:removeControlPoint(4)
    local ex, ey = bc:evaluate(0.5)
    print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative()
    print("deriv = " .. dx .. ", " .. dy)
    local dist_x, dist_y = bc:evaluateAtDistance(50, 100)
    print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length())
    local pts = bc:render(20)
    print("render pts = " .. #pts)
    bc:translate(10, 5)
    bc:rotate(0.1, 0, 0)
    bc:scale(1.0, 0, 0)
    print(bc:type())
    print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LBezierCurve:typeOf
-- Bezier curve: control points, evaluation, transform, render. Focus: typeOf.
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 })
    print(bc:getControlPointCount())
    local x, y = bc:getControlPoint(1)
    print("cp1 = " .. x .. ", " .. y)
    bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60)
    bc:removeControlPoint(4)
    local ex, ey = bc:evaluate(0.5)
    print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative()
    print("deriv = " .. dx .. ", " .. dy)
    local dist_x, dist_y = bc:evaluateAtDistance(50, 100)
    print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length())
    local pts = bc:render(20)
    print("render pts = " .. #pts)
    bc:translate(10, 5)
    bc:rotate(0.1, 0, 0)
    bc:scale(1.0, 0, 0)
    print(bc:type())
    print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LCatmullRom:len
-- Catmull-Rom spline: add/remove points, sample. Focus: len.
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 })
    print("len = " .. cr:len())
    cr:addPoint(250, 50)
    cr:removePoint(5)
    local sx, sy = cr:sample(0.5)
    print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5)
    print("segSample = " .. ex .. ", " .. ey)
    print(cr:type())
    print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCatmullRom:type
-- Catmull-Rom spline: add/remove points, sample. Focus: type.
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 })
    print("len = " .. cr:len())
    cr:addPoint(250, 50)
    cr:removePoint(5)
    local sx, sy = cr:sample(0.5)
    print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5)
    print("segSample = " .. ex .. ", " .. ey)
    print(cr:type())
    print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCatmullRom:typeOf
-- Catmull-Rom spline: add/remove points, sample. Focus: typeOf.
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 })
    print("len = " .. cr:len())
    cr:addPoint(250, 50)
    cr:removePoint(5)
    local sx, sy = cr:sample(0.5)
    print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5)
    print("segSample = " .. ex .. ", " .. ey)
    print(cr:type())
    print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCircle:area
-- Circle geometry operations. Focus: area.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:perimeter
-- Circle geometry operations. Focus: perimeter.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:radius
-- Circle geometry operations. Focus: radius.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:type
-- Circle geometry operations. Focus: type.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:typeOf
-- Circle geometry operations. Focus: typeOf.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:x
-- Circle geometry operations. Focus: x.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:y
-- Circle geometry operations. Focus: y.
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius())
    print("area=" .. c:area())
    print("perimeter=" .. c:perimeter())
    local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2)
    local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2)))
    print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type())
    print(c:typeOf("LCircle"))
end

--@api-stub: LHermite:sample
-- Hermite spline sampling and type info. Focus: sample.
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy)
    local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LHermite:type
-- Hermite spline sampling and type info. Focus: type.
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy)
    local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LHermite:typeOf
-- Hermite spline sampling and type info. Focus: typeOf.
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy)
    local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LRectPacker:clear
-- Rectangle packer: atlas packing operations. Focus: clear.
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    local ok, x, y = rp:pack(64, 64)
    print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128)
    print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    local occ = rp:occupancy()
    print("occupancy = " .. occ)
    rp:clear()
    print("cleared")
end

--@api-stub: LRectPacker:getPacked
-- Rectangle packer: atlas packing operations. Focus: getPacked.
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    local ok, x, y = rp:pack(64, 64)
    print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128)
    print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    local occ = rp:occupancy()
    print("occupancy = " .. occ)
    rp:clear()
    print("cleared")
end

--@api-stub: LRectPacker:occupancy
-- Rectangle packer: atlas packing operations. Focus: occupancy.
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    local ok, x, y = rp:pack(64, 64)
    print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128)
    print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    local occ = rp:occupancy()
    print("occupancy = " .. occ)
    rp:clear()
    print("cleared")
end

--@api-stub: LRectPacker:pack
-- Rectangle packer: atlas packing operations. Focus: pack.
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    local ok, x, y = rp:pack(64, 64)
    print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128)
    print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked()
    print("packed count = " .. #packed)
    local occ = rp:occupancy()
    print("occupancy = " .. occ)
    rp:clear()
    print("cleared")
end

--@api-stub: LSpatialHash:clear
-- Spatial hash grid: insert, query, update, remove. Focus: clear.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:getCellSize
-- Spatial hash grid: insert, query, update, remove. Focus: getCellSize.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:getItemCount
-- Spatial hash grid: insert, query, update, remove. Focus: getItemCount.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:insert
-- Spatial hash grid: insert, query, update, remove. Focus: insert.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:type
-- Spatial hash grid: insert, query, update, remove. Focus: type.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:typeOf
-- Spatial hash grid: insert, query, update, remove. Focus: typeOf.
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    sh:insert("a", 50, 50, 10, 10)
    sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10)
    print("count = " .. sh:getItemCount())
    local rect_hits = sh:queryRect(0, 0, 150, 150)
    print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40)
    print("circle hits = " .. #circ_hits)
    local seg_hits = sh:querySegment(40, 40, 100, 100)
    print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10)
    sh:remove("c")
    print(sh:type())
    print(sh:typeOf("LSpatialHash"))
    sh:clear()
    print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LTransform:type
-- Transform: matrix ops, decompose, transform points. Focus: type.
do
    local tf = lurek.math.newTransform()
    tf:translate(50, 100)
    tf:rotate(0.5)
    tf:scale(2, 2)
    tf:shear(0.1, 0.0)
    local wx, wy = tf:transformPoint(10, 20)
    print("transformed = " .. wx .. ", " .. wy)
    local ix, iy = tf:inverseTransformPoint(wx, wy)
    print("inverse = " .. ix .. ", " .. iy)
    local a, b, c, d, e, f, g, h = tf:getMatrix()
    print("matrix", a, b, c, d)
    tf:setTransformation(0, 0, 0, 1, 1, 0, 0, 0, 0)
    local tx, ty, r, sx, sy, ox, oy, kx, ky = tf:decompose()
    print("decompose", tx, ty, r, sx, sy)
    local tf2 = tf:clone()
    print("clone type = " .. tf2:type())
    local inv = tf:inverse()
    print("inv type = " .. inv:type())
    tf:reset()
    print(tf:type())
    print(tf:typeOf("LTransform"))
end

--@api-stub: LTransform:typeOf
-- Transform: matrix ops, decompose, transform points. Focus: typeOf.
do
    local tf = lurek.math.newTransform()
    tf:translate(50, 100)
    tf:rotate(0.5)
    tf:scale(2, 2)
    tf:shear(0.1, 0.0)
    local wx, wy = tf:transformPoint(10, 20)
    print("transformed = " .. wx .. ", " .. wy)
    local ix, iy = tf:inverseTransformPoint(wx, wy)
    print("inverse = " .. ix .. ", " .. iy)
    local a, b, c, d, e, f, g, h = tf:getMatrix()
    print("matrix", a, b, c, d)
    tf:setTransformation(0, 0, 0, 1, 1, 0, 0, 0, 0)
    local tx, ty, r, sx, sy, ox, oy, kx, ky = tf:decompose()
    print("decompose", tx, ty, r, sx, sy)
    local tf2 = tf:clone()
    print("clone type = " .. tf2:type())
    local inv = tf:inverse()
    print("inv type = " .. inv:type())
    tf:reset()
    print(tf:type())
    print(tf:typeOf("LTransform"))
end

--@api-stub: LVec2:type
-- Vec2: all vector operations. Focus: type.
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v:x() .. " y=" .. v:y())
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    print("angle=" .. v:angle())
    local u = v:normalized()
    print("normalized x=" .. u:x() .. " y=" .. u:y())
    local v2 = lurek.math.Vec2(1, 0)
    print("dot=" .. v:dot(v2))
    print("cross=" .. v:cross(v2))
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp x=" .. lv:x())
    local pv = v:perpendicular()
    print("perp x=" .. pv:x() .. " y=" .. pv:y())
    local rv = v:rotate(0.5)
    print("rotated x=" .. rv:x())
    local rfv = v:reflect(v2)
    print("reflect x=" .. rfv:x())
    v:normalize()
    local fa = v:fromAngle(1.57)
    print("fromAngle x=" .. fa:x())
    print(v:type())
    print(v:typeOf("LVec2"))
end

--@api-stub: LVec2:typeOf
-- Vec2: all vector operations. Focus: typeOf.
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v:x() .. " y=" .. v:y())
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    print("angle=" .. v:angle())
    local u = v:normalized()
    print("normalized x=" .. u:x() .. " y=" .. u:y())
    local v2 = lurek.math.Vec2(1, 0)
    print("dot=" .. v:dot(v2))
    print("cross=" .. v:cross(v2))
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp x=" .. lv:x())
    local pv = v:perpendicular()
    print("perp x=" .. pv:x() .. " y=" .. pv:y())
    local rv = v:rotate(0.5)
    print("rotated x=" .. rv:x())
    local rfv = v:reflect(v2)
    print("reflect x=" .. rfv:x())
    v:normalize()
    local fa = v:fromAngle(1.57)
    print("fromAngle x=" .. fa:x())
    print(v:type())
    print(v:typeOf("LVec2"))
end

--@api-stub: LVec2:x
-- Vec2: all vector operations. Focus: x.
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v:x() .. " y=" .. v:y())
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    print("angle=" .. v:angle())
    local u = v:normalized()
    print("normalized x=" .. u:x() .. " y=" .. u:y())
    local v2 = lurek.math.Vec2(1, 0)
    print("dot=" .. v:dot(v2))
    print("cross=" .. v:cross(v2))
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp x=" .. lv:x())
    local pv = v:perpendicular()
    print("perp x=" .. pv:x() .. " y=" .. pv:y())
    local rv = v:rotate(0.5)
    print("rotated x=" .. rv:x())
    local rfv = v:reflect(v2)
    print("reflect x=" .. rfv:x())
    v:normalize()
    local fa = v:fromAngle(1.57)
    print("fromAngle x=" .. fa:x())
    print(v:type())
    print(v:typeOf("LVec2"))
end

--@api-stub: LVec2:y
-- Vec2: all vector operations. Focus: y.
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v:x() .. " y=" .. v:y())
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    print("angle=" .. v:angle())
    local u = v:normalized()
    print("normalized x=" .. u:x() .. " y=" .. u:y())
    local v2 = lurek.math.Vec2(1, 0)
    print("dot=" .. v:dot(v2))
    print("cross=" .. v:cross(v2))
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp x=" .. lv:x())
    local pv = v:perpendicular()
    print("perp x=" .. pv:x() .. " y=" .. pv:y())
    local rv = v:rotate(0.5)
    print("rotated x=" .. rv:x())
    local rfv = v:reflect(v2)
    print("reflect x=" .. rfv:x())
    v:normalize()
    local fa = v:fromAngle(1.57)
    print("fromAngle x=" .. fa:x())
    print(v:type())
    print(v:typeOf("LVec2"))
end

--@api-stub: LVec3:type
-- Vec3: all vector operations. Focus: type.
do
    local v = lurek.math.Vec3(1, 2, 3)
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    local v2 = lurek.math.Vec3(4, 5, 6)
    print("dot=" .. v:dot(v2))
    local cv = v:cross(v2)
    print("cross type=" .. cv:type())
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp=" .. lv:length())
    local av = v:add(v2)
    print("add=" .. av:length())
    local sv = v:sub(v2)
    print("sub=" .. sv:length())
    local sc = v:scale(2.0)
    print("scale=" .. sc:length())
    v:normalize()
    local sp = lurek.math.Vec3(0, 0, 0)
    sp:splat(1.0)
    print(v:type())
    print(v:typeOf("LVec3"))
end

--@api-stub: LVec3:typeOf
-- Vec3: all vector operations. Focus: typeOf.
do
    local v = lurek.math.Vec3(1, 2, 3)
    print("length=" .. v:length())
    print("lengthSq=" .. v:lengthSquared())
    local v2 = lurek.math.Vec3(4, 5, 6)
    print("dot=" .. v:dot(v2))
    local cv = v:cross(v2)
    print("cross type=" .. cv:type())
    print("dist=" .. v:distance(v2))
    local lv = v:lerp(v2, 0.5)
    print("lerp=" .. lv:length())
    local av = v:add(v2)
    print("add=" .. av:length())
    local sv = v:sub(v2)
    print("sub=" .. sv:length())
    local sc = v:scale(2.0)
    print("scale=" .. sc:length())
    v:normalize()
    local sp = lurek.math.Vec3(0, 0, 0)
    sp:splat(1.0)
    print(v:type())
    print(v:typeOf("LVec3"))
end

--@api-stub: LNoiseGenerator:type
-- LNoiseGenerator type introspection and voronoi generation. Focus: type.
do
    local ng = lurek.math.newNoiseGenerator(42)
    local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

--@api-stub: LNoiseGenerator:typeOf
-- LNoiseGenerator type introspection and voronoi generation. Focus: typeOf.
do
    local ng = lurek.math.newNoiseGenerator(42)
    local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

--@api-stub: lurek.math.voronoi
-- LNoiseGenerator type introspection and voronoi generation. Focus: voronoi.
do
    local ng = lurek.math.newNoiseGenerator(42)
    local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

print("content/examples/math.lua")
