-- content/examples/math.lua
-- Auto-generated from content/examples2/math_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/math.lua

--- Math Module Part 1: basic math functions and trigonometry


--@api-stub: lurek.math.pi
do
    print("pi = " .. lurek.math.pi)
end

--@api-stub: lurek.math.tau
do
    print("tau = " .. lurek.math.tau)
end

--@api-stub: lurek.math.abs
do
    print("abs(-5) = " .. lurek.math.abs(-5))
    print("abs(3) = " .. lurek.math.abs(3))
end

--@api-stub: lurek.math.ceil
do
    print("ceil(2.3) = " .. lurek.math.ceil(2.3))
    print("ceil(-1.7) = " .. lurek.math.ceil(-1.7))
end

--@api-stub: lurek.math.floor
do
    print("floor(2.9) = " .. lurek.math.floor(2.9))
    print("floor(-1.1) = " .. lurek.math.floor(-1.1))
end

--@api-stub: lurek.math.round
do
    print("round(2.4) = " .. lurek.math.round(2.4))
    print("round(2.5) = " .. lurek.math.round(2.5))
end

--@api-stub: lurek.math.sign
do
    print("sign(-7) = " .. lurek.math.sign(-7))
    print("sign(0) = " .. lurek.math.sign(0))
    print("sign(3) = " .. lurek.math.sign(3))
end

--@api-stub: lurek.math.clamp
do
    print("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10))
    print("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10))
    print("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10))
end

--@api-stub: lurek.math.lerp
do
    print("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5))
    print("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25))
end

--@api-stub: lurek.math.inverseLerp
do
    print("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50))
    print("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15))
end

--@api-stub: lurek.math.remap
do
    local v = lurek.math.remap(5, 0, 10, 0, 100)
    print("remap(5, 0-10 → 0-100) = " .. v)
end

--@api-stub: lurek.math.smoothstep
do
    print("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5))
    print("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0))
    print("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0))
end

--@api-stub: lurek.math.pow
do
    print("pow(2, 10) = " .. lurek.math.pow(2, 10))
    print("pow(3, 3) = " .. lurek.math.pow(3, 3))
end

--@api-stub: lurek.math.sqrt
do
    print("sqrt(144) = " .. lurek.math.sqrt(144))
    print("sqrt(2) = " .. lurek.math.sqrt(2))
end

--@api-stub: lurek.math.exp
do
    print("exp(1) = " .. lurek.math.exp(1))
    print("exp(0) = " .. lurek.math.exp(0))
end

--@api-stub: lurek.math.log
do
    print("log(e) = " .. lurek.math.log(lurek.math.exp(1)))
    print("log(100, 10) = " .. lurek.math.log(100, 10))
end

--@api-stub: lurek.math.fmod
do
    print("fmod(7, 3) = " .. lurek.math.fmod(7, 3))
    print("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3))
end

--@api-stub: lurek.math.min
do
    print("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
end

--@api-stub: lurek.math.max
do
    print("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9))
end

--@api-stub: lurek.math.sin
do
    print("sin(0) = " .. lurek.math.sin(0))
    print("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2))
end

--@api-stub: lurek.math.cos
do
    print("cos(0) = " .. lurek.math.cos(0))
    print("cos(pi) = " .. lurek.math.cos(lurek.math.pi))
end

--@api-stub: lurek.math.tan
do
    print("tan(0) = " .. lurek.math.tan(0))
    print("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4))
end

--@api-stub: lurek.math.asin
do
    print("asin(1) = " .. lurek.math.asin(1))
    print("asin(0) = " .. lurek.math.asin(0))
end

--@api-stub: lurek.math.acos
do
    print("acos(1) = " .. lurek.math.acos(1))
    print("acos(0) = " .. lurek.math.acos(0))
end

--@api-stub: lurek.math.atan
do
    print("atan(1) = " .. lurek.math.atan(1))
    print("atan(1, 1) = " .. lurek.math.atan(1, 1))
end

--@api-stub: lurek.math.atan2
do
    print("atan2(1, 0) = " .. lurek.math.atan2(1, 0))
    print("atan2(0, 1) = " .. lurek.math.atan2(0, 1))
end

--@api-stub: lurek.math.deg
do
    print("deg(pi) = " .. lurek.math.deg(lurek.math.pi))
    print("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2))
end

--@api-stub: lurek.math.rad
do
    print("rad(180) = " .. lurek.math.rad(180))
    print("rad(90) = " .. lurek.math.rad(90))
end

--@api-stub: lurek.math.random
do
    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    print("random = " .. r1 .. ", " .. r2 .. ", " .. r3)
end

--@api-stub: lurek.math.randomInt
do
    local r = lurek.math.randomInt(1, 6)
    print("randomInt(1,6) = " .. r)
end

--- Math Module Part 2: geometry — distances, intersections, polygons


--@api-stub: lurek.math.distance
do
    local d = lurek.math.distance(0, 0, 3, 4)
    print("distance = " .. d)
end

--@api-stub: lurek.math.distanceSq
do
    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    print("distanceSq = " .. d2)
end

--@api-stub: lurek.math.angleBetween
do
    local a = lurek.math.angleBetween(0, 0, 1, 0)
    print("angle to right = " .. a)
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    print("angle down = " .. b)
end

--@api-stub: lurek.math.closestPointOnSegment
do
    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    print("closest on segment = " .. cx .. "," .. cy)
end

--@api-stub: lurek.math.lineIntersect
do
    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then print("lines cross at " .. ix .. "," .. iy) else print("lines are parallel") end
end

--@api-stub: lurek.math.segmentIntersectsSegment
do
    local hit, ix, iy = lurek.math.segmentIntersectsSegment( 0, 0, 10, 10, 0, 10, 10, 0 )
    if hit and ix then print("segments cross at " .. ix .. "," .. iy) else print("segments do not cross") end
end

--@api-stub: lurek.math.circleContainsPoint
do
    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    print("inside = " .. tostring(inside))
end

--@api-stub: lurek.math.circleIntersectsCircle
do
    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    print("circles overlap = " .. tostring(hit))
end

--@api-stub: lurek.math.circleIntersectsLine
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    print("circle/line hit = " .. tostring(hit))
    if hx1 then print("  hit1 = " .. hx1 .. "," .. hy1) end
    if hx2 then print("  hit2 = " .. hx2 .. "," .. hy2) end
end

--@api-stub: lurek.math.circleIntersectsSegment
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    print("circle/seg hit = " .. tostring(hit))
    if hx1 then print("  seg hit1 = " .. hx1 .. "," .. hy1) end
    _ = hx2
    _ = hy2
end

--@api-stub: lurek.math.pointInPolygon
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    print("inside = " .. tostring(inside) .. " outside = " .. tostring(outside))
end

--@api-stub: lurek.math.polygonArea
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    print("area = " .. area)
end

--@api-stub: lurek.math.polygonCentroid
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    print("centroid = " .. cx .. "," .. cy)
end

--@api-stub: lurek.math.isConvex
do
    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    print("square convex = " .. tostring(lurek.math.isConvex(square)))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    print("concave = " .. tostring(lurek.math.isConvex(concave)))
end

--@api-stub: lurek.math.convexHull
do
    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    print("hull vertices = " .. #hull / 2)
end

--@api-stub: lurek.math.polygonClip
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    print("clipped vertices = " .. #clipped / 2)
end

--@api-stub: lurek.math.polygonUnion
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonUnion(a, b)
    print("union vertices = " .. #result)
end

--@api-stub: lurek.math.polygonIntersection
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonIntersection(a, b)
    print("intersection vertices = " .. #result / 2)
end

--@api-stub: lurek.math.polygonDifference
do
    local a = {0, 0, 10, 0, 10, 10, 0, 10}
    local b = {5, 5, 15, 5, 15, 15, 5, 15}
    local result = lurek.math.polygonDifference(a, b)
    print("difference vertices = " .. #result / 2)
end

--@api-stub: lurek.math.triangulate
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    print("triangles = " .. #tris)
end

--@api-stub: lurek.math.delaunayTriangulate
do
    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    print("delaunay triangles = " .. #tris)
end

--@api-stub: lurek.math.bresenham
do
    local pts = lurek.math.bresenham(0, 0, 5, 3)
    print("bresenham points = " .. #pts)
    for _, p in ipairs(pts) do
        print("  " .. p.x .. "," .. p.y)
    end
end

--@api-stub: lurek.math.rectFromCenter
do
    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--@api-stub: lurek.math.rectUnion
do
    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    print("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
end

--- Math Module Part 3: curves — Bezier, Catmull-Rom, Hermite


--@api-stub: lurek.math.newBezierCurve
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    print("control points = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:evaluate
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = bz:evaluate(0.5)
    print("mid point = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:evaluateAtDistance
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local len = bz:length()
    local x, y = bz:evaluateAtDistance(len * 0.5, 20)
    print("half-arc point = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:getControlPoint
do
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0}); local px, py = bz:getControlPoint(2)
    print("cp2 = " .. px .. "," .. py)
    bz:setControlPoint(2, 50, 80)
    local nx, ny = bz:getControlPoint(2)
    print("cp2 moved = " .. nx .. "," .. ny)
end

--@api-stub: LBezierCurve:setControlPoint
do
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0}); local px, py = bz:getControlPoint(2)
    print("cp2 = " .. px .. "," .. py)
    bz:setControlPoint(2, 50, 80)
    local nx, ny = bz:getControlPoint(2)
    print("cp2 moved = " .. nx .. "," .. ny)
end

--@api-stub: LBezierCurve:insertControlPoint
do
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0}); print("count before = " .. bz:getControlPointCount())
    bz:insertControlPoint(50, 50)
    print("count after insert = " .. bz:getControlPointCount())
    bz:removeControlPoint(2)
    print("count after remove = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:removeControlPoint
do
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0}); print("count before = " .. bz:getControlPointCount())
    bz:insertControlPoint(50, 50)
    print("count after insert = " .. bz:getControlPointCount())
    bz:removeControlPoint(2)
    print("count after remove = " .. bz:getControlPointCount())
end

--@api-stub: LBezierCurve:length
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 100, 0})
    local l = bz:length()
    print("line length = " .. l)
end

--@api-stub: LBezierCurve:render
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local pts = bz:render(10)
    print("rendered points = " .. #pts)
end

--@api-stub: LBezierCurve:getDerivative
do
    ---@type LBezierCurve
    local bz = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local deriv = bz:getDerivative()
    print("derivative CPs = " .. deriv:getControlPointCount())
end

--@api-stub: LBezierCurve:translate
do
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0}); bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:rotate
do
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0}); bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: LBezierCurve:scale
do
    local bz = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0}); bz:translate(10, 20)
    bz:rotate(math.pi / 4, 50, 25)
    bz:scale(2, 50, 25)
    local x, y = bz:evaluate(0)
    print("start after transforms = " .. x .. "," .. y)
end

--@api-stub: lurek.math.catmullRom
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    print("catmull-rom points = " .. cr:len())
end

--@api-stub: LCatmullRom:sample
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    local x, y = cr:sample(0.5)
    print("mid = " .. x .. "," .. y)
end

--@api-stub: LCatmullRom:sampleSegment
do
    ---@type LCatmullRom
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20},{x=150,y=60}})
    local x, y = cr:sampleSegment(1, 0.5)
    print("seg1 mid = " .. x .. "," .. y)
end

--@api-stub: LCatmullRom:addPoint
do
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20}})
    cr:addPoint(150, 60)
    print("after add = " .. cr:len())
    local rx, ry = cr:removePoint(2)
    print("removed = " .. rx .. "," .. ry .. " len = " .. cr:len())
end

--@api-stub: LCatmullRom:removePoint
do
    local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=80},{x=100,y=20}})
    cr:addPoint(150, 60)
    print("after add = " .. cr:len())
    local rx, ry = cr:removePoint(2)
    print("removed = " .. rx .. "," .. ry .. " len = " .. cr:len())
end

--@api-stub: lurek.math.hermite
do
    local h = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100); local x, y = h:sample(0.5)
    print("hermite mid = " .. x .. "," .. y); local h = lurek.math.hermite(10, 20, 80, 90, 40, 0, -40, 0)
    local x0, y0 = h:sample(0); local x1, y1 = h:sample(1)
    print("start = " .. x0 .. "," .. y0)
    print("end   = " .. x1 .. "," .. y1)
end

--- Math Module Part 4: noise — LNoiseGenerator + stateless noise functions


--@api-stub: lurek.math.newNoiseGenerator
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(42)
    print("seed = " .. ng:getSeed())
end

--@api-stub: LNoiseGenerator:perlin1d
do
    local ng = lurek.math.newNoiseGenerator(123); local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin2d
do
    local ng = lurek.math.newNoiseGenerator(123); local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin3d
do
    local ng = lurek.math.newNoiseGenerator(123); local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:perlin4d
do
    local ng = lurek.math.newNoiseGenerator(123); local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:simplex1d
do
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:simplex2d
do
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:simplex3d
do
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:worley2d
do
    local ng = lurek.math.newNoiseGenerator(55); local w2 = ng:worley2d(3.5, 4.5)
    local w2m = ng:worley2d(3.5, 4.5, "manhattan")
    local w2f = ng:worley2d(3.5, 4.5, "euclidean", true)
    local w3 = ng:worley3d(1.0, 2.0, 3.0)
    print("worley2d=" .. w2 .. " manhattan=" .. w2m .. " f2=" .. w2f .. " 3d=" .. w3)
end

--@api-stub: LNoiseGenerator:worley3d
do
    local ng = lurek.math.newNoiseGenerator(55); local w2 = ng:worley2d(3.5, 4.5)
    local w2m = ng:worley2d(3.5, 4.5, "manhattan")
    local w2f = ng:worley2d(3.5, 4.5, "euclidean", true)
    local w3 = ng:worley3d(1.0, 2.0, 3.0)
    print("worley2d=" .. w2 .. " manhattan=" .. w2m .. " f2=" .. w2f .. " 3d=" .. w3)
end

--@api-stub: LNoiseGenerator:fbm
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:fbm(2.5, 3.5)
    local v2 = ng:fbm(2.5, 3.5, 6, 2.0, 0.5, "simplex")
    print("fbm default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:ridged
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:ridged(2.5, 3.5)
    local v2 = ng:ridged(2.5, 3.5, 8, 2.5, 0.6, "perlin")
    print("ridged default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:turbulence
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:turbulence(1.0, 2.0)
    local v2 = ng:turbulence(1.0, 2.0, 5, 2.0, 0.5, "simplex")
    print("turbulence default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:warpDomain
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(13)
    local v = ng:warpDomain(3.0, 4.0, 0.5)
    print("warped = " .. v)
end

--@api-stub: LNoiseGenerator:generateMap
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMap(16, 16, {scale = 4.0, octaves = 4, kind = "perlin"})
    print("map size = " .. #map .. " sample = " .. map[1])
end

--@api-stub: LNoiseGenerator:generateMapCompute
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMapCompute(32, 32, {scale = 8.0})
    print("compute map size = " .. #map)
end

--@api-stub: LNoiseGenerator:setSeed
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(0)
    ng:setSeed(999)
    print("new seed = " .. ng:getSeed())
end

--@api-stub: LNoiseGenerator:getSeed
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(0)
    ng:setSeed(999)
    print("new seed = " .. ng:getSeed())
end

--@api-stub: lurek.math.perlin2d
do
    local v = lurek.math.perlin2d(5.0, 3.0)
    local v2 = lurek.math.perlin2d(5.0, 3.0, 42)
    print("stateless perlin2d = " .. v .. " seeded = " .. v2)
end

--@api-stub: lurek.math.perlin3d
do
    local v = lurek.math.perlin3d(1.0, 2.0, 3.0); local v2 = lurek.math.perlin3d(1.0, 2.0, 3.0, 77)
    print("stateless perlin3d = " .. v .. " seeded = " .. v2); local v1 = lurek.math.fbm(0.5, 0.5, 4, 0.5, 2.0)
    local v2 = lurek.math.perlin2d(0.3, 0.7); local v3 = lurek.math.perlin3d(0.1, 0.2, 0.3)
    local v4 = lurek.math.simplex2d(0.4, 0.6); local v5 = lurek.math.simplexNoise(0.5, 0.5)
    print(v1, v2, v3, v4, v5)
end

--@api-stub: lurek.math.simplex2d
do
    local v = lurek.math.simplex2d(2.0, 3.0)
    local v2 = lurek.math.simplex2d(2.0, 3.0, 10)
    print("stateless simplex2d = " .. v .. " seeded = " .. v2)
end

--@api-stub: lurek.math.simplexNoise
do
    local v2d = lurek.math.simplexNoise(4.0, 5.0); local v3d = lurek.math.simplexNoise(4.0, 5.0, 6.0)
    print("simplexNoise 2d=" .. v2d .. " 3d=" .. v3d); local v1 = lurek.math.fbm(0.5, 0.5, 4, 0.5, 2.0)
    local v2 = lurek.math.perlin2d(0.3, 0.7); local v3 = lurek.math.perlin3d(0.1, 0.2, 0.3)
    local v4 = lurek.math.simplex2d(0.4, 0.6); local v5 = lurek.math.simplexNoise(0.5, 0.5)
    print(v1, v2, v3, v4, v5)
end

--@api-stub: lurek.math.fbm
do
    local v = lurek.math.fbm(1.0, 2.0, 42)
    local v2 = lurek.math.fbm(1.0, 2.0, 42, 6, 2.0, 0.5)
    print("stateless fbm = " .. v .. " custom = " .. v2)
end

--- Math Module Part 5: vectors (LVec2, LVec3) and transforms (LTransform)


--@api-stub: lurek.math.vec2
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
end

--@api-stub: lurek.math.Vec2
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:length
do
    ---@type LVec2
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec2:lengthSquared
do
    ---@type LVec2
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec2:normalize
do
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
    v:normalize()
    print("after normalize = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:normalized
do
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
    v:normalize()
    print("after normalize = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:dot
do
    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    print("dot = " .. a:dot(b))
    print("cross = " .. a:cross(b))
end

--@api-stub: LVec2:cross
do
    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    print("dot = " .. a:dot(b))
    print("cross = " .. a:cross(b))
end

--@api-stub: LVec2:distance
do
    ---@type LVec2
    local a = lurek.math.vec2(0, 0)
    ---@type LVec2
    local b = lurek.math.vec2(3, 4)
    print("distance = " .. a:distance(b))
end

--@api-stub: LVec2:angle
do
    ---@type LVec2
    local v = lurek.math.vec2(1, 1)
    print("angle = " .. v:angle())
end

--@api-stub: LVec2:lerp
do
    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y)
end

--@api-stub: LVec2:rotate
do
    ---@type LVec2
    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(math.pi / 2)
    print("rotated = " .. r.x .. "," .. r.y)
end

--@api-stub: LVec2:perpendicular
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    print("perp = " .. p.x .. "," .. p.y)
end

--@api-stub: LVec2:reflect
do
    local v = lurek.math.vec2(1, -1)
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    print("reflected = " .. ref.x .. "," .. ref.y)
end

--@api-stub: LVec2:fromAngle
do
    ---@type LVec2
    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(0)
    print("fromAngle(0) = " .. unit.x .. "," .. unit.y)
end

--@api-stub: lurek.math.vec3
do
    ---@type LVec3
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
end

--@api-stub: lurek.math.Vec3
do
    ---@type LVec3
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
end

--@api-stub: LVec3:length
do
    ---@type LVec3
    local v = lurek.math.Vec3(1, 2, 2)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec3:lengthSquared
do
    ---@type LVec3
    local v = lurek.math.Vec3(1, 2, 2)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec3:normalize
do
    ---@type LVec3
    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    print("normalized = " .. n.x .. "," .. n.y .. "," .. n.z)
end

--@api-stub: LVec3:dot
do
    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api-stub: LVec3:cross
do
    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api-stub: LVec3:add
do
    local a = lurek.math.vec3(1, 2, 3); local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b); local diff = a:sub(b)
    local scaled = a:scale(2); print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:sub
do
    local a = lurek.math.vec3(1, 2, 3); local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b); local diff = a:sub(b)
    local scaled = a:scale(2); print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:scale
do
    local a = lurek.math.vec3(1, 2, 3); local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b); local diff = a:sub(b)
    local scaled = a:scale(2); print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api-stub: LVec3:distance
do
    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    print("distance = " .. a:distance(b))
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
end

--@api-stub: LVec3:lerp
do
    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    print("distance = " .. a:distance(b))
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
end

--@api-stub: LVec3:splat
do
    ---@type LVec3
    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    print("splat = " .. s.x .. "," .. s.y .. "," .. s.z)
end

--@api-stub: lurek.math.newTransform
do
    ---@type LTransform
    local t = lurek.math.newTransform(100, 200, math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    print("origin transformed = " .. x .. "," .. y)
end

--@api-stub: LTransform:translate
do
    local t = lurek.math.newTransform(); t:translate(50, 50)
    t:rotate(math.pi / 6); t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:rotate
do
    local t = lurek.math.newTransform(); t:translate(50, 50)
    t:rotate(math.pi / 6); t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:scale
do
    local t = lurek.math.newTransform(); t:translate(50, 50)
    t:rotate(math.pi / 6); t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:shear
do
    local t = lurek.math.newTransform(); t:translate(50, 50)
    t:rotate(math.pi / 6); t:scale(2, 2)
    t:shear(0.1, 0)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api-stub: LTransform:transformPoint
do
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api-stub: LTransform:inverseTransformPoint
do
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api-stub: LTransform:clone
do
    local t = lurek.math.newTransform(10, 20, 0.5); local c = t:clone()
    local inv = t:inverse(); local x, y = t:transformPoint(0, 0)
    local rx, ry = inv:transformPoint(x, y); print("original point = " .. x .. "," .. y)
    print("roundtrip = " .. rx .. "," .. ry)
    _ = c
end

--@api-stub: LTransform:inverse
do
    local t = lurek.math.newTransform(10, 20, 0.5); local c = t:clone()
    local inv = t:inverse(); local x, y = t:transformPoint(0, 0)
    local rx, ry = inv:transformPoint(x, y); print("original point = " .. x .. "," .. y)
    print("roundtrip = " .. rx .. "," .. ry)
    _ = c
end

--@api-stub: LTransform:decompose
do
    ---@type LTransform
    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    print("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy)
end

--@api-stub: LTransform:getMatrix
do
    ---@type LTransform
    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    print("matrix elements = " .. #m)
end

--@api-stub: LTransform:reset
do
    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2); t:reset()
    local x1, y1 = t:transformPoint(10, 10); print("after reset = " .. x1 .. "," .. y1)
    t:setTransformation(0, 0, math.pi, 1, 1)
    local x2, y2 = t:transformPoint(10, 0)
    print("after set = " .. x2 .. "," .. y2)
end

--@api-stub: LTransform:setTransformation
do
    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2); t:reset()
    local x1, y1 = t:transformPoint(10, 10); print("after reset = " .. x1 .. "," .. y1)
    t:setTransformation(0, 0, math.pi, 1, 1)
    local x2, y2 = t:transformPoint(10, 0)
    print("after set = " .. x2 .. "," .. y2)
end

--- Math Module Part 6: random, tween, spatial, circle, color, easings


--@api-stub: lurek.math.newRandomGenerator
do
    ---@type LRandomGenerator
    local rng = lurek.math.newRandomGenerator(42)
    print("seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:random
do
    local rng = lurek.math.newRandomGenerator(100); local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomFloat
do
    local rng = lurek.math.newRandomGenerator(100); local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomInt
do
    local rng = lurek.math.newRandomGenerator(100); local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:randomNormal
do
    local rng = lurek.math.newRandomGenerator(100); local r = rng:random()
    local rf = rng:randomFloat(1.0, 5.0)
    local ri = rng:randomInt(1, 100)
    local rn = rng:randomNormal(1.0, 0.0)
    print("random=" .. r .. " float=" .. rf .. " int=" .. ri .. " normal=" .. rn)
end

--@api-stub: LRandomGenerator:setSeed
do
    local rng = lurek.math.newRandomGenerator(1); rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:getState
do
    local rng = lurek.math.newRandomGenerator(1); rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: LRandomGenerator:setState
do
    local rng = lurek.math.newRandomGenerator(1); rng:setSeed(999)
    local state = rng:getState()
    rng:random()
    rng:setState(state)
    print("state restored, seed = " .. rng:getSeed())
end

--@api-stub: lurek.math.newTween
do
    ---@type LTween
    local tw = lurek.math.newTween(2.0, "inOutCubic")
    print("duration = " .. tw:getDuration())
    print("easing = " .. tw:getEasingName())
end

--@api-stub: LTween:addValue
do
    local tw = lurek.math.newTween(1.0, "linear"); local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200); print("channels = " .. tw:getValueCount())
    tw:setTime(0.5); print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getValue
do
    local tw = lurek.math.newTween(1.0, "linear"); local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200); print("channels = " .. tw:getValueCount())
    tw:setTime(0.5); print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getAllValues
do
    local tw = lurek.math.newTween(1.0, "linear"); local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200); print("channels = " .. tw:getValueCount())
    tw:setTime(0.5); print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:getValueCount
do
    local tw = lurek.math.newTween(1.0, "linear"); local idx1 = tw:addValue(0, 100)
    local idx2 = tw:addValue(50, 200); print("channels = " .. tw:getValueCount())
    tw:setTime(0.5); print("ch1 = " .. tw:getValue(idx1) .. " ch2 = " .. tw:getValue(idx2))
    local all = tw:getAllValues()
    print("all count = " .. #all)
end

--@api-stub: LTween:update
do
    local tw = lurek.math.newTween(1.0, "outBounce"); tw:addValue(0, 10)
    local done = tw:update(0.5); print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6); print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:isComplete
do
    local tw = lurek.math.newTween(1.0, "outBounce"); tw:addValue(0, 10)
    local done = tw:update(0.5); print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6); print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:reset
do
    local tw = lurek.math.newTween(1.0, "outBounce"); tw:addValue(0, 10)
    local done = tw:update(0.5); print("half done = " .. tostring(done) .. " val = " .. tw:getValue())
    tw:update(0.6); print("complete = " .. tostring(tw:isComplete()))
    tw:reset()
    print("after reset clock = " .. tw:getClock())
end

--@api-stub: LTween:set
do
    local tw = lurek.math.newTween(2.0); tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:setTime
do
    local tw = lurek.math.newTween(2.0); tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:getTime
do
    local tw = lurek.math.newTween(2.0); tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: LTween:getClock
do
    local tw = lurek.math.newTween(2.0); tw:addValue(0, 100)
    tw:set(0.75)
    print("set 75%% = " .. tw:getValue())
    tw:setTime(1.0)
    print("time 1.0 = " .. tw:getTime() .. " clock = " .. tw:getClock())
end

--@api-stub: lurek.math.aabbTree
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:insert(3, 100, 100, 110, 110)
    print("len = " .. tree:len() .. " empty = " .. tostring(tree:isEmpty()))
end

--@api-stub: LAabbTree:query
do
    local tree = lurek.math.aabbTree(); tree:insert(1, 0, 0, 10, 10); tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6); print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7); print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1))); tree:update(1, 20, 20, 30, 30)
    tree:remove(2); print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:queryPoint
do
    local tree = lurek.math.aabbTree(); tree:insert(1, 0, 0, 10, 10); tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6); print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7); print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1))); tree:update(1, 20, 20, 30, 30)
    tree:remove(2); print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:contains
do
    local tree = lurek.math.aabbTree(); tree:insert(1, 0, 0, 10, 10); tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6); print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7); print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1))); tree:update(1, 20, 20, 30, 30)
    tree:remove(2); print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:remove
do
    local tree = lurek.math.aabbTree(); tree:insert(1, 0, 0, 10, 10); tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6); print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7); print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1))); tree:update(1, 20, 20, 30, 30)
    tree:remove(2); print("after remove len = " .. tree:len())
end

--@api-stub: LAabbTree:update
do
    local tree = lurek.math.aabbTree(); tree:insert(1, 0, 0, 10, 10); tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6); print("query hits = " .. #hits)
    local pt = tree:queryPoint(7, 7); print("point hits = " .. #pt)
    print("contains 1 = " .. tostring(tree:contains(1))); tree:update(1, 20, 20, 30, 30)
    tree:remove(2); print("after remove len = " .. tree:len())
end

--@api-stub: lurek.math.newSpatialHash
do
    ---@type LSpatialHash
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    print("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:queryRect
do
    local sh = lurek.math.newSpatialHash(16); sh:insert("a", 0, 0, 10, 10); sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10); local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10); local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s); sh:update("a", 200, 200, 10, 10)
    sh:remove("c"); print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:queryCircle
do
    local sh = lurek.math.newSpatialHash(16); sh:insert("a", 0, 0, 10, 10); sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10); local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10); local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s); sh:update("a", 200, 200, 10, 10)
    sh:remove("c"); print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:querySegment
do
    local sh = lurek.math.newSpatialHash(16); sh:insert("a", 0, 0, 10, 10); sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10); local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10); local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s); sh:update("a", 200, 200, 10, 10)
    sh:remove("c"); print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:remove
do
    local sh = lurek.math.newSpatialHash(16); sh:insert("a", 0, 0, 10, 10); sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10); local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10); local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s); sh:update("a", 200, 200, 10, 10)
    sh:remove("c"); print("items after = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:update
do
    local sh = lurek.math.newSpatialHash(16); sh:insert("a", 0, 0, 10, 10); sh:insert("b", 5, 5, 10, 10)
    sh:insert("c", 100, 100, 10, 10); local r = sh:queryRect(0, 0, 12, 12)
    local c = sh:queryCircle(5, 5, 10); local s = sh:querySegment(0, 0, 50, 50)
    print("rect=" .. #r .. " circle=" .. #c .. " seg=" .. #s); sh:update("a", 200, 200, 10, 10)
    sh:remove("c"); print("items after = " .. sh:getItemCount())
end

--@api-stub: lurek.math.newRectPacker
do
    local rp = lurek.math.newRectPacker(256, 256, 1); local x1, y1 = rp:pack(32, 32, "icon1")
    local x2, y2 = rp:pack(64, 64, "icon2"); if x1 and y1 then print("icon1 at " .. x1 .. "," .. y1) end
    if x2 and y2 then print("icon2 at " .. x2 .. "," .. y2) end; print("occupancy = " .. rp:occupancy())
    local packed = rp:getPacked(); print("packed count = " .. #packed)
    rp:clear()
end

--@api-stub: lurek.math.newCircle
do
    ---@type LCircle
    local c = lurek.math.newCircle(50, 50, 25)
    print("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    print("area = " .. c:area())
    print("perimeter = " .. c:perimeter())
end

--@api-stub: LCircle:contains
do
    local c1 = lurek.math.newCircle(0, 0, 10); local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: LCircle:intersects
do
    local c1 = lurek.math.newCircle(0, 0, 10); local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: LCircle:aabb
do
    local c1 = lurek.math.newCircle(0, 0, 10); local c2 = lurek.math.newCircle(15, 0, 10)
    print("contains(5,5) = " .. tostring(c1:contains(5, 5)))
    print("intersects = " .. tostring(c1:intersects(c2)))
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api-stub: lurek.math.fromHex
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("fromHex = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.math.hslToRgb
do
    local r, g, b, a = lurek.math.hslToRgb(0.0, 1.0, 0.5)
    print("hsl(0,1,0.5) = " .. r .. "," .. g .. "," .. b .. "," .. a)
    local h, s, l = lurek.math.rgbToHsl(1.0, 0.0, 0.0)
    print("red → hsl = " .. h .. "," .. s .. "," .. l)
end

--@api-stub: lurek.math.gammaToLinear
do
    local lin = lurek.math.gammaToLinear(0.5)
    local gam = lurek.math.linearToGamma(lin)
    print("gamma→linear→gamma = " .. gam)
end

--@api-stub: lurek.math.applyEasing
do
    local v1 = lurek.math.applyEasing("linear", 0.5)
    local v2 = lurek.math.applyEasing("inOutCubic", 0.5)
    local v3 = lurek.math.applyEasing("outBounce", 0.8)
    print("linear=" .. v1 .. " inOutCubic=" .. v2 .. " outBounce=" .. v3)
end

--@api-stub: lurek.math.inBack
do
    local a = lurek.math.inBack(0.5)
    local b = lurek.math.outBack(0.5)
    local c = lurek.math.inOutBack(0.5)
    print("inBack=" .. a .. " outBack=" .. b .. " inOutBack=" .. c)
end

--@api-stub: lurek.math.inBounce
do
    local a = lurek.math.inBounce(0.7)
    local b = lurek.math.outBounce(0.7)
    local c = lurek.math.inOutBounce(0.7)
    print("inBounce=" .. a .. " outBounce=" .. b .. " inOutBounce=" .. c)
end

--- Math Module: easing functions, applyEasing, LRandomGenerator, LNoiseGenerator


--@api-stub: lurek.math.inCubic
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inElastic
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inExpo
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inQuad
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inQuart
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.inSine
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.linear
do
    local t = 0.5; print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t)); print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t)); print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t)); print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t)); print(lurek.math.linear(t))
end

--@api-stub: lurek.math.outBack
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outBounce
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outCubic
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outElastic
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outExpo
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outQuad
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outQuart
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.outSine
do
    local t = 0.5; print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t)); print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t)); print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t)); print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.inOutBack
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutBounce
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutCubic
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutElastic
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutExpo
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutQuad
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutQuart
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: lurek.math.inOutSine
do
    local t = 0.5; print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t)); print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t)); print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t)); print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: LRandomGenerator:getSeed
do
    local rng = lurek.math.newRandomGenerator(); local seed = rng:getSeed(); print("seed = " .. seed)
    local state = rng:getState(); print("state = " .. tostring(state)); local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100); local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n); rng:setState(state)
    print(rng:type()); print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: LRandomGenerator:type
do
    local rng = lurek.math.newRandomGenerator(); local seed = rng:getSeed(); print("seed = " .. seed)
    local state = rng:getState(); print("state = " .. tostring(state)); local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100); local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n); rng:setState(state)
    print(rng:type()); print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: LRandomGenerator:typeOf
do
    local rng = lurek.math.newRandomGenerator(); local seed = rng:getSeed(); print("seed = " .. seed)
    local state = rng:getState(); print("state = " .. tostring(state)); local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100); local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n); rng:setState(state)
    print(rng:type()); print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: lurek.math.linearToGamma
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF"); print("hex", r, g, b, a)
    local lr = lurek.math.gammaToLinear(r); print("linear", lr)
    local gr = lurek.math.linearToGamma(lr); print("gamma", gr)
    local h, s, l = lurek.math.rgbToHsl(r, g, b); print("hsl", h, s, l)
    local r2, g2, b2 = lurek.math.hslToRgb(h, s, l); print("rgb", r2, g2, b2)
end

--@api-stub: lurek.math.rgbToHsl
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF"); print("hex", r, g, b, a)
    local lr = lurek.math.gammaToLinear(r); print("linear", lr)
    local gr = lurek.math.linearToGamma(lr); print("gamma", gr)
    local h, s, l = lurek.math.rgbToHsl(r, g, b); print("hsl", h, s, l)
    local r2, g2, b2 = lurek.math.hslToRgb(h, s, l); print("rgb", r2, g2, b2)
end

--- Math Module: object APIs — LAabbTree, LBezierCurve, LCatmullRom, LCircle,
---               LHermite, LRectPacker, LSpatialHash, LTransform, LVec2, LVec3


--@api-stub: LAabbTree:clear
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LAabbTree:insert
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LAabbTree:isEmpty
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LAabbTree:len
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LAabbTree:type
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LAabbTree:typeOf
do
    local tree = lurek.math.aabbTree(); print(tree:isEmpty()); tree:insert(1, 0, 0, 50, 50); tree:insert(2, 30, 30, 80, 80)
    print(tree:len()); print(tree:contains(1)); local hits = tree:query(10, 10, 60, 60)
    print("query hits = " .. #hits); local pt = tree:queryPoint(25, 25); print("point hits = " .. #pt)
    tree:update(1, 5, 5, 55, 55); tree:remove(2); print(tree:type())
    print(tree:typeOf("LAabbTree")); tree:clear(); print(tree:isEmpty())
end

--@api-stub: LBezierCurve:getControlPointCount
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 }); print(bc:getControlPointCount()); local x, y = bc:getControlPoint(1); print("cp1 = " .. x .. ", " .. y); bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60); bc:removeControlPoint(4); local ex, ey = bc:evaluate(0.5); print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative(); print("deriv = " .. dx .. ", " .. dy); local dist_x, dist_y = bc:evaluateAtDistance(50, 100); print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length()); local pts = bc:render(20); print("render pts = " .. #pts); bc:translate(10, 5)
    bc:rotate(0.1, 0, 0); bc:scale(1.0, 0, 0); print(bc:type()); print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LBezierCurve:type
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 }); print(bc:getControlPointCount()); local x, y = bc:getControlPoint(1); print("cp1 = " .. x .. ", " .. y); bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60); bc:removeControlPoint(4); local ex, ey = bc:evaluate(0.5); print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative(); print("deriv = " .. dx .. ", " .. dy); local dist_x, dist_y = bc:evaluateAtDistance(50, 100); print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length()); local pts = bc:render(20); print("render pts = " .. #pts); bc:translate(10, 5)
    bc:rotate(0.1, 0, 0); bc:scale(1.0, 0, 0); print(bc:type()); print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LBezierCurve:typeOf
do
    local bc = lurek.math.newBezierCurve({ 0, 0, 100, 50, 200, 0 }); print(bc:getControlPointCount()); local x, y = bc:getControlPoint(1); print("cp1 = " .. x .. ", " .. y); bc:insertControlPoint(150, 75, 3)
    bc:setControlPoint(2, 110, 60); bc:removeControlPoint(4); local ex, ey = bc:evaluate(0.5); print("eval = " .. ex .. ", " .. ey)
    local dx, dy = bc:getDerivative(); print("deriv = " .. dx .. ", " .. dy); local dist_x, dist_y = bc:evaluateAtDistance(50, 100); print("atDist = " .. dist_x .. ", " .. dist_y)
    print("length = " .. bc:length()); local pts = bc:render(20); print("render pts = " .. #pts); bc:translate(10, 5)
    bc:rotate(0.1, 0, 0); bc:scale(1.0, 0, 0); print(bc:type()); print(bc:typeOf("LBezierCurve"))
end

--@api-stub: LCatmullRom:len
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 }); print("len = " .. cr:len())
    cr:addPoint(250, 50); cr:removePoint(5)
    local sx, sy = cr:sample(0.5); print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5); print("segSample = " .. ex .. ", " .. ey)
    print(cr:type()); print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCatmullRom:type
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 }); print("len = " .. cr:len())
    cr:addPoint(250, 50); cr:removePoint(5)
    local sx, sy = cr:sample(0.5); print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5); print("segSample = " .. ex .. ", " .. ey)
    print(cr:type()); print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCatmullRom:typeOf
do
    local cr = lurek.math.catmullRom({ 0, 0, 50, 100, 150, 100, 200, 0 }); print("len = " .. cr:len())
    cr:addPoint(250, 50); cr:removePoint(5)
    local sx, sy = cr:sample(0.5); print("sample = " .. sx .. ", " .. sy)
    local ex, ey = cr:sampleSegment(1, 0.5); print("segSample = " .. ex .. ", " .. ey)
    print(cr:type()); print(cr:typeOf("LCatmullRom"))
end

--@api-stub: LCircle:area
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:perimeter
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:radius
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:type
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:typeOf
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:x
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LCircle:y
do
    local c = lurek.math.newCircle(100, 100, 50); print("x=" .. c:x() .. " y=" .. c:y() .. " r=" .. c:radius()); print("area=" .. c:area())
    print("perimeter=" .. c:perimeter()); local x1, y1, x2, y2 = c:aabb()
    print("aabb", x1, y1, x2, y2); local c2 = lurek.math.newCircle(120, 120, 30)
    print("intersects=" .. tostring(c:intersects(c2))); print("contains pt=" .. tostring(c:contains(100, 100)))
    print(c:type()); print(c:typeOf("LCircle"))
end

--@api-stub: LHermite:sample
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2); local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy); local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LHermite:type
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2); local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy); local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LHermite:typeOf
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2); local hx, hy = h:sample(0.5)
    print("hermite sample = " .. hx .. ", " .. hy); local hx2, hy2 = h:sample(0.0)
    print("hermite t=0 = " .. hx2 .. ", " .. hy2)
    print(h:type())
    print(h:typeOf("LHermite"))
end

--@api-stub: LRectPacker:clear
do
    local rp = lurek.math.newRectPacker(512, 512, 2); local ok, x, y = rp:pack(64, 64); print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128); print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked(); print("packed count = " .. #packed)
    local occ = rp:occupancy(); print("occupancy = " .. occ)
    rp:clear(); print("cleared")
end

--@api-stub: LRectPacker:getPacked
do
    local rp = lurek.math.newRectPacker(512, 512, 2); local ok, x, y = rp:pack(64, 64); print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128); print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked(); print("packed count = " .. #packed)
    local occ = rp:occupancy(); print("occupancy = " .. occ)
    rp:clear(); print("cleared")
end

--@api-stub: LRectPacker:occupancy
do
    local rp = lurek.math.newRectPacker(512, 512, 2); local ok, x, y = rp:pack(64, 64); print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128); print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked(); print("packed count = " .. #packed)
    local occ = rp:occupancy(); print("occupancy = " .. occ)
    rp:clear(); print("cleared")
end

--@api-stub: LRectPacker:pack
do
    local rp = lurek.math.newRectPacker(512, 512, 2); local ok, x, y = rp:pack(64, 64); print("pack ok=" .. tostring(ok) .. " x=" .. tostring(x) .. " y=" .. tostring(y))
    local ok2, x2, y2 = rp:pack(128, 128); print("pack2 ok=" .. tostring(ok2))
    local packed = rp:getPacked(); print("packed count = " .. #packed)
    local occ = rp:occupancy(); print("occupancy = " .. occ)
    rp:clear(); print("cleared")
end

--@api-stub: LSpatialHash:clear
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:getCellSize
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:getItemCount
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:insert
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:type
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LSpatialHash:typeOf
do
    local sh = lurek.math.newSpatialHash(32); print("cell size = " .. sh:getCellSize()); sh:insert("a", 50, 50, 10, 10); sh:insert("b", 80, 80, 10, 10)
    sh:insert("c", 200, 200, 10, 10); print("count = " .. sh:getItemCount()); local rect_hits = sh:queryRect(0, 0, 150, 150); print("rect hits = " .. #rect_hits)
    local circ_hits = sh:queryCircle(65, 65, 40); print("circle hits = " .. #circ_hits); local seg_hits = sh:querySegment(40, 40, 100, 100); print("seg hits = " .. #seg_hits)
    sh:update("a", 60, 60, 10, 10); sh:remove("c"); print(sh:type())
    print(sh:typeOf("LSpatialHash")); sh:clear(); print("count after clear = " .. sh:getItemCount())
end

--@api-stub: LTransform:type
do
    local tf = lurek.math.newTransform(); tf:translate(50, 100); tf:rotate(0.5); tf:scale(2, 2); tf:shear(0.1, 0.0)
    local wx, wy = tf:transformPoint(10, 20); print("transformed = " .. wx .. ", " .. wy); local ix, iy = tf:inverseTransformPoint(wx, wy); print("inverse = " .. ix .. ", " .. iy)
    local a, b, c, d, e, f, g, h = tf:getMatrix(); print("matrix", a, b, c, d); tf:setTransformation(0, 0, 0, 1, 1, 0, 0, 0, 0); local tx, ty, r, sx, sy, ox, oy, kx, ky = tf:decompose()
    print("decompose", tx, ty, r, sx, sy); local tf2 = tf:clone(); print("clone type = " .. tf2:type()); local inv = tf:inverse()
    print("inv type = " .. inv:type()); tf:reset(); print(tf:type()); print(tf:typeOf("LTransform"))
end

--@api-stub: LTransform:typeOf
do
    local tf = lurek.math.newTransform(); tf:translate(50, 100); tf:rotate(0.5); tf:scale(2, 2); tf:shear(0.1, 0.0)
    local wx, wy = tf:transformPoint(10, 20); print("transformed = " .. wx .. ", " .. wy); local ix, iy = tf:inverseTransformPoint(wx, wy); print("inverse = " .. ix .. ", " .. iy)
    local a, b, c, d, e, f, g, h = tf:getMatrix(); print("matrix", a, b, c, d); tf:setTransformation(0, 0, 0, 1, 1, 0, 0, 0, 0); local tx, ty, r, sx, sy, ox, oy, kx, ky = tf:decompose()
    print("decompose", tx, ty, r, sx, sy); local tf2 = tf:clone(); print("clone type = " .. tf2:type()); local inv = tf:inverse()
    print("inv type = " .. inv:type()); tf:reset(); print(tf:type()); print(tf:typeOf("LTransform"))
end

--@api-stub: LVec2:type
do
    local v = lurek.math.Vec2(3, 4)
    print(v:type())
end

--@api-stub: LVec2:typeOf
do
    local v = lurek.math.Vec2(3, 4)
    print(v:typeOf("LVec2"))
end

--@api-stub: LVec2:x
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v:x())
end

--@api-stub: LVec2:y
do
    local v = lurek.math.Vec2(3, 4)
    print("y=" .. v:y())
end

--@api-stub: LVec3:type
do
    local v = lurek.math.Vec3(1, 2, 3)
    print(v:type())
end

--@api-stub: LVec3:typeOf
do
    local v = lurek.math.Vec3(1, 2, 3); print("length=" .. v:length()); print("lengthSq=" .. v:lengthSquared()); local v2 = lurek.math.Vec3(4, 5, 6); print("dot=" .. v:dot(v2))
    local cv = v:cross(v2); print("cross type=" .. cv:type()); print("dist=" .. v:distance(v2)); local lv = v:lerp(v2, 0.5)
    print("lerp=" .. lv:length()); local av = v:add(v2); print("add=" .. av:length()); local sv = v:sub(v2)
    print("sub=" .. sv:length()); local sc = v:scale(2.0); print("scale=" .. sc:length()); v:normalize()
    local sp = lurek.math.Vec3(0, 0, 0); sp:splat(1.0); print(v:type()); print(v:typeOf("LVec3"))
end

--@api-stub: LNoiseGenerator:type
do
    local ng = lurek.math.newNoiseGenerator(42); local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

--@api-stub: LNoiseGenerator:typeOf
do
    local ng = lurek.math.newNoiseGenerator(42); local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

--@api-stub: lurek.math.voronoi
do
    local ng = lurek.math.newNoiseGenerator(42); local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

print("content/examples/math.lua")
