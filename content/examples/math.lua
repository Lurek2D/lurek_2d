--@api: lurek.math.pi
do
    print("pi = " .. lurek.math.pi)
    print("pi * 2 = " .. lurek.math.pi * 2)
    print("lua type = " .. type(lurek.math.pi * 2))
end

--@api: lurek.math.tau
do
    print("tau = " .. lurek.math.tau)
    print("tau == 2*pi: " .. tostring(lurek.math.tau == 2 * lurek.math.pi))
    print("lua type = " .. type(tostring(lurek.math.tau == 2 * lurek.math.pi)))
end

--@api: lurek.math.abs
do
    print("abs(-5) = " .. lurek.math.abs(-5))
    print("abs(3) = " .. lurek.math.abs(3))
    print("lua type = " .. type(lurek.math.abs(3)))
end

--@api: lurek.math.ceil
do
    print("ceil(2.3) = " .. lurek.math.ceil(2.3))
    print("ceil(-1.7) = " .. lurek.math.ceil(-1.7))
    print("lua type = " .. type(lurek.math.ceil(-1.7)))
end

--@api: lurek.math.floor
do
    print("floor(2.9) = " .. lurek.math.floor(2.9))
    print("floor(-1.1) = " .. lurek.math.floor(-1.1))
    print("lua type = " .. type(lurek.math.floor(-1.1)))
end

--@api: lurek.math.round
do
    print("round(2.4) = " .. lurek.math.round(2.4))
    print("round(2.5) = " .. lurek.math.round(2.5))
    print("lua type = " .. type(lurek.math.round(2.5)))
end

--@api: lurek.math.sign
do
    print("sign(-7) = " .. lurek.math.sign(-7))
    print("sign(0) = " .. lurek.math.sign(0))
    print("sign(3) = " .. lurek.math.sign(3))
end

--@api: lurek.math.clamp
do
    print("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10))
    print("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10))
    print("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10))
end

--@api: lurek.math.lerp
do
    print("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5))
    print("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25))
    print("lua type = " .. type(lurek.math.lerp(10, 20, 0.25)))
end

--@api: lurek.math.inverseLerp
do
    print("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50))
    print("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15))
    print("lua type = " .. type(lurek.math.inverseLerp(10, 20, 15)))
end

--@api: lurek.math.remap
do
    local v = lurek.math.remap(5, 0, 10, 0, 100)
    print("remap(5, 0-10 â†’ 0-100) = " .. v)
    print("lua type = " .. type(v))
end

--@api: lurek.math.smoothstep
do
    print("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5))
    print("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0))
    print("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0))
end

--@api: lurek.math.pow
do
    print("pow(2, 10) = " .. lurek.math.pow(2, 10))
    print("pow(3, 3) = " .. lurek.math.pow(3, 3))
    print("lua type = " .. type(lurek.math.pow(3, 3)))
end

--@api: lurek.math.sqrt
do
    print("sqrt(144) = " .. lurek.math.sqrt(144))
    print("sqrt(2) = " .. lurek.math.sqrt(2))
    print("lua type = " .. type(lurek.math.sqrt(2)))
end

--@api: lurek.math.exp
do
    print("exp(1) = " .. lurek.math.exp(1))
    print("exp(0) = " .. lurek.math.exp(0))
    print("lua type = " .. type(lurek.math.exp(0)))
end

--@api: lurek.math.log
do
    print("log(e) = " .. lurek.math.log(lurek.math.exp(1)))
    print("log(100, 10) = " .. lurek.math.log(100, 10))
    print("lua type = " .. type(lurek.math.log(100, 10)))
end

--@api: lurek.math.fmod
do
    print("fmod(7, 3) = " .. lurek.math.fmod(7, 3))
    print("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3))
    print("lua type = " .. type(lurek.math.fmod(10.5, 3)))
end

--@api: lurek.math.min
do
    print("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
    print("min(0, -5) = " .. lurek.math.min(0, -5))
    print("lua type = " .. type(lurek.math.min(0, -5)))
end

--@api: lurek.math.max
do
    print("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9))
    print("max(0, -5) = " .. lurek.math.max(0, -5))
    print("lua type = " .. type(lurek.math.max(0, -5)))
end

--@api: lurek.math.sin
do
    print("sin(0) = " .. lurek.math.sin(0))
    print("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2))
    print("lua type = " .. type(lurek.math.sin(lurek.math.pi / 2)))
end

--@api: lurek.math.cos
do
    print("cos(0) = " .. lurek.math.cos(0))
    print("cos(pi) = " .. lurek.math.cos(lurek.math.pi))
    print("lua type = " .. type(lurek.math.cos(lurek.math.pi)))
end

--@api: lurek.math.tan
do
    print("tan(0) = " .. lurek.math.tan(0))
    print("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4))
    print("lua type = " .. type(lurek.math.tan(lurek.math.pi / 4)))
end

--@api: lurek.math.asin
do
    print("asin(1) = " .. lurek.math.asin(1))
    print("asin(0) = " .. lurek.math.asin(0))
    print("lua type = " .. type(lurek.math.asin(0)))
end

--@api: lurek.math.acos
do
    print("acos(1) = " .. lurek.math.acos(1))
    print("acos(0) = " .. lurek.math.acos(0))
    print("lua type = " .. type(lurek.math.acos(0)))
end

--@api: lurek.math.atan
do
    print("atan(1) = " .. lurek.math.atan(1))
    print("atan(1, 1) = " .. lurek.math.atan(1, 1))
    print("lua type = " .. type(lurek.math.atan(1, 1)))
end

--@api: lurek.math.atan2
do
    print("atan2(1, 0) = " .. lurek.math.atan2(1, 0))
    print("atan2(0, 1) = " .. lurek.math.atan2(0, 1))
    print("lua type = " .. type(lurek.math.atan2(0, 1)))
end

--@api: lurek.math.deg
do
    print("deg(pi) = " .. lurek.math.deg(lurek.math.pi))
    print("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2))
    print("lua type = " .. type(lurek.math.deg(lurek.math.pi / 2)))
end

--@api: lurek.math.rad
do
    print("rad(180) = " .. lurek.math.rad(180))
    print("rad(90) = " .. lurek.math.rad(90))
    print("lua type = " .. type(lurek.math.rad(90)))
end

--@api: lurek.math.random
do
    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    print("random = " .. r1 .. ", " .. r2 .. ", " .. r3)
end

--@api: lurek.math.randomInt
do
    local r = lurek.math.randomInt(1, 6)
    print("randomInt(1,6) = " .. r)
    print("lua type = " .. type(r))
end

--@api: lurek.math.distance
do
    local d = lurek.math.distance(0, 0, 3, 4)
    print("distance = " .. d)
    print("lua type = " .. type(d))
end

--@api: lurek.math.distanceSq
do
    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    print("distanceSq = " .. d2)
    print("lua type = " .. type(d2))
end

--@api: lurek.math.angleBetween
do
    local a = lurek.math.angleBetween(0, 0, 1, 0)
    print("angle to right = " .. a)
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    print("angle down = " .. b)
end

--@api: lurek.math.closestPointOnSegment
do
    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    print("closest on segment = " .. cx .. "," .. cy)
    print("value types = " .. type(cx) .. "," .. type(cy))
end

--@api: lurek.math.lineIntersect
do
    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then print("lines cross at " .. ix .. "," .. iy) else print("lines are parallel") end
    print("value types = " .. type(ix) .. "," .. type(iy))
end

--@api: lurek.math.segmentIntersectsSegment
do
    local hit, ix, iy = lurek.math.segmentIntersectsSegment( 0, 0, 10, 10, 0, 10, 10, 0 )
    if hit and ix then print("segments cross at " .. ix .. "," .. iy) else print("segments do not cross") end
    print("value types = " .. type(hit) .. "," .. type(ix) .. "," .. type(iy))
end

--@api: lurek.math.circleContainsPoint
do
    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    print("inside = " .. tostring(inside))
    print("lua type = " .. type(inside))
end

--@api: lurek.math.circleIntersectsCircle
do
    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    print("circles overlap = " .. tostring(hit))
    print("lua type = " .. type(hit))
end

--@api: lurek.math.circleIntersectsLine
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    print("circle/line hit = " .. tostring(hit))
    if hx1 then print("  hit1 = " .. hx1 .. "," .. hy1) end
    if hx2 then print("  hit2 = " .. hx2 .. "," .. hy2) end
end

--@api: lurek.math.circleIntersectsSegment
do
    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    print("circle/seg hit = " .. tostring(hit))
    if hx1 then print("  seg hit1 = " .. hx1 .. "," .. hy1) end
    _ = hx2
    _ = hy2
end

--@api: lurek.math.pointInPolygon
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    print("inside = " .. tostring(inside) .. " outside = " .. tostring(outside))
end

--@api: lurek.math.polygonArea
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    print("area = " .. area)
end

--@api: lurek.math.polygonCentroid
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    print("centroid = " .. cx .. "," .. cy)
end

--@api: lurek.math.isConvex
do
    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    print("square convex = " .. tostring(lurek.math.isConvex(square)))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    print("concave = " .. tostring(lurek.math.isConvex(concave)))
end

--@api: lurek.math.convexHull
do
    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    print("hull vertices = " .. #hull / 2)
end

--@api: lurek.math.polygonClip
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    print("clipped vertices = " .. #clipped / 2)
end

--@api: lurek.math.polygonUnion
do
    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonUnion(a, b)
    print("union vertices = " .. #result)
end

--@api: lurek.math.polygonIntersection
do
    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonIntersection(a, b)
    print("intersection vertices = " .. #result)
end

--@api: lurek.math.polygonDifference
do
    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonDifference(a, b)
    print("difference vertices = " .. #result)
end

--@api: lurek.math.triangulate
do
    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    print("triangles = " .. #tris)
end

--@api: lurek.math.delaunayTriangulate
do
    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    print("delaunay triangles = " .. #tris)
end

--@api: lurek.math.bresenham
do
    local pts = lurek.math.bresenham(0, 0, 5, 3)
    print("bresenham points = " .. #pts)
    for _, p in ipairs(pts) do
        print("  " .. p.x .. "," .. p.y)
    end
end

--@api: lurek.math.rectFromCenter
do
    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    print("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
end

--@api: lurek.math.rectUnion
do
    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    print("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    print("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
end

--@api: lurek.math.newBezierCurve
do
    local curve = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    print("control points = " .. curve:getControlPointCount())
    local x, y = curve:evaluate(0.5)
    print("mid = " .. x .. "," .. y)
end

--@api: LBezierCurve:evaluate
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = curve:evaluate(0.25)
    print("t=0.25 = " .. x .. "," .. y)
end

--@api: LBezierCurve:evaluateAtDistance
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local length = curve:length()
    local x, y = curve:evaluateAtDistance(length * 0.5, 32)
    print("length = " .. length)
    print("halfway = " .. x .. "," .. y)
end

--@api: LBezierCurve:getControlPoint
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local x, y = curve:getControlPoint(2)
    print("cp2 = " .. x .. "," .. y)
end

--@api: LBezierCurve:setControlPoint
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:getControlPoint(2)
    curve:setControlPoint(2, 50, 80)
    local afterX, afterY = curve:getControlPoint(2)
    print("before = " .. beforeX .. "," .. beforeY)
    print("after = " .. afterX .. "," .. afterY)
end

--@api: LBezierCurve:insertControlPoint
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    print("count before = " .. curve:getControlPointCount())
    curve:insertControlPoint(50, 50, 2)
    local x, y = curve:getControlPoint(2)
    print("inserted = " .. x .. "," .. y)
    print("count after = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:removeControlPoint
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    print("count before = " .. curve:getControlPointCount())
    curve:removeControlPoint(2)
    print("count after = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:length
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    print("length = " .. curve:length())
    print("owner type = " .. tostring(curve:type()))
end

--@api: LBezierCurve:render
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local points = curve:render(4)
    local sample = points[3]
    print("samples = " .. #points)
    print("sample 3 = " .. sample[1] .. "," .. sample[2])
end

--@api: LBezierCurve:getDerivative
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local derivative = curve:getDerivative()
    local x, y = derivative:evaluate(0.5)
    print("derivative control points = " .. derivative:getControlPointCount())
    print("tangent = " .. x .. "," .. y)
end

--@api: LBezierCurve:translate
do
    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:evaluate(0)
    curve:translate(10, 20)
    local afterX, afterY = curve:evaluate(0)
    print("before = " .. beforeX .. "," .. beforeY)
    print("after = " .. afterX .. "," .. afterY)
end

--@api: LBezierCurve:rotate
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:rotate(lurek.math.pi / 2, 0, 0)
    local x, y = curve:getControlPoint(2)
    print("end point = " .. x .. "," .. y)
end

--@api: LBezierCurve:scale
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:scale(2, 0, 0)
    local x, y = curve:getControlPoint(2)
    print("end point = " .. x .. "," .. y)
end

--@api: lurek.math.catmullRom
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    print("points = " .. spline:len())
    local x, y = spline:sample(0.5)
    print("mid = " .. x .. "," .. y)
end

--@api: LCatmullRom:sample
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sample(0.25)
    print("t=0.25 = " .. x .. "," .. y)
end

--@api: LCatmullRom:sampleSegment
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sampleSegment(1, 0.5)
    print("segment 1 = " .. x .. "," .. y)
end

--@api: LCatmullRom:addPoint
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}})
    print("before = " .. spline:len())
    spline:addPoint(150, 60)
    print("after = " .. spline:len())
end

--@api: LCatmullRom:removePoint
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:removePoint(1)
    print("removed = " .. x .. "," .. y)
    print("after = " .. spline:len())
end

--@api: lurek.math.hermite
do
    local spline = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100)
    local x0, y0 = spline:sample(0)
    local xm, ym = spline:sample(0.5)
    local x1, y1 = spline:sample(1)
    print("start = " .. x0 .. "," .. y0)
    print("mid = " .. xm .. "," .. ym)
    print("end = " .. x1 .. "," .. y1)
end

--@api: lurek.math.vec2
do
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
    print("lua type = " .. type(v))
end

--@api: lurek.math.Vec2
do
    local v = lurek.math.Vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
    print("lua type = " .. type(v))
end

--@api: LVec2:length
do
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec2:lengthSquared
do
    local v = lurek.math.Vec2(3, 4)
    print("lengthSq = " .. v:lengthSquared())
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec2:normalize
do
    local v = lurek.math.vec2(3, 4)
    local n = v:normalize()
    print("normalized = " .. n.x .. "," .. n.y)
end

--@api: LVec2:normalized
do
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
end

--@api: LVec2:dot
do
    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    print("dot = " .. a:dot(b))
end

--@api: LVec2:cross
do
    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    print("cross = " .. a:cross(b))
end

--@api: LVec2:distance
do
    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(3, 4)
    print("distance = " .. a:distance(b))
end

--@api: LVec2:angle
do
    local v = lurek.math.vec2(1, 1)
    print("angle = " .. v:angle())
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec2:lerp
do
    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y)
end

--@api: LVec2:rotate
do
    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(lurek.math.pi / 2)
    print("rotated = " .. r.x .. "," .. r.y)
end

--@api: LVec2:perpendicular
do
    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    print("perp = " .. p.x .. "," .. p.y)
end

--@api: LVec2:reflect
do
    local v = lurek.math.vec2(1, -1)
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    print("reflected = " .. ref.x .. "," .. ref.y)
end

--@api: LVec2:fromAngle
do
    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(lurek.math.pi / 4)
    print("fromAngle(pi/4) = " .. unit.x .. "," .. unit.y)
end

--@api: lurek.math.vec3
do
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    print("lua type = " .. type(v))
end

--@api: lurek.math.Vec3
do
    local v = lurek.math.Vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    print("lua type = " .. type(v))
end

--@api: LVec3:length
do
    local v = lurek.math.Vec3(1, 2, 2)
    print("length = " .. v:length())
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec3:lengthSquared
do
    local v = lurek.math.Vec3(1, 2, 2)
    print("lengthSq = " .. v:lengthSquared())
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec3:normalize
do
    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    print("normalized = " .. n.x .. "," .. n.y .. "," .. n.z)
end

--@api: LVec3:dot
do
    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
end

--@api: LVec3:cross
do
    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api: LVec3:add
do
    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    print("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
end

--@api: LVec3:sub
do
    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local diff = a:sub(b)
    print("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
end

--@api: LVec3:scale
do
    local v = lurek.math.vec3(1, 2, 3)
    local scaled = v:scale(2)
    print("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
end

--@api: LVec3:distance
do
    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    print("distance = " .. a:distance(b))
end

--@api: LVec3:lerp
do
    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    local mid = a:lerp(b, 0.5)
    print("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
end

--@api: LVec3:splat
do
    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    print("splat = " .. s.x .. "," .. s.y .. "," .. s.z)
end

--@api: lurek.math.newTransform
do
    local t = lurek.math.newTransform(100, 200, lurek.math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    print("origin transformed = " .. x .. "," .. y)
end

--@api: LTransform:translate
do
    local t = lurek.math.newTransform()
    t:translate(50, 50)
    local x, y = t:transformPoint(0, 0)
    print("point = " .. x .. "," .. y)
end

--@api: LTransform:rotate
do
    local t = lurek.math.newTransform()
    t:rotate(lurek.math.pi / 2)
    local x, y = t:transformPoint(10, 0)
    print("point = " .. x .. "," .. y)
end

--@api: LTransform:scale
do
    local t = lurek.math.newTransform()
    t:scale(2, 3)
    local x, y = t:transformPoint(10, 5)
    print("point = " .. x .. "," .. y)
end

--@api: LTransform:shear
do
    local t = lurek.math.newTransform()
    t:shear(0.25, 0)
    local x, y = t:transformPoint(10, 10)
    print("point = " .. x .. "," .. y)
end

--@api: LTransform:transformPoint
do
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api: LTransform:inverseTransformPoint
do
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api: LTransform:clone
do
    local t = lurek.math.newTransform(10, 20, 0.5)
    local clone = t:clone()
    local x, y = clone:transformPoint(0, 0)
    print("clone point = " .. x .. "," .. y)
end

--@api: LTransform:inverse
do
    local t = lurek.math.newTransform(10, 20, 0.5)
    local inv = t:inverse()
    local x, y = t:transformPoint(5, 0)
    local rx, ry = inv:transformPoint(x, y)
    print("roundtrip = " .. rx .. "," .. ry)
end

--@api: LTransform:decompose
do
    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    print("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy)
end

--@api: LTransform:getMatrix
do
    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    print("matrix elements = " .. #m)
    print("first row = " .. m[1] .. "," .. m[2] .. "," .. m[3])
end

--@api: LTransform:reset
do
    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x, y = t:transformPoint(10, 10)
    print("after reset = " .. x .. "," .. y)
end

--@api: LTransform:setTransformation
do
    local t = lurek.math.newTransform()
    t:setTransformation(0, 0, lurek.math.pi, 1, 1)
    local x, y = t:transformPoint(10, 0)
    print("after set = " .. x .. "," .. y)
end

--@api: lurek.math.newRandomGenerator
do
    local rng = lurek.math.newRandomGenerator(42)
    print("seed = " .. rng:getSeed())
    print("lua type = " .. type(rng))
end

--@api: LRandomGenerator:random
do
    local rng = lurek.math.newRandomGenerator(100)
    print("random = " .. rng:random())
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:randomFloat
do
    local rng = lurek.math.newRandomGenerator(100)
    print("float = " .. rng:randomFloat(1.0, 5.0))
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:randomInt
do
    local rng = lurek.math.newRandomGenerator(100)
    print("int = " .. rng:randomInt(1, 100))
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:randomNormal
do
    local rng = lurek.math.newRandomGenerator(100)
    print("normal = " .. rng:randomNormal(1.0, 0.0))
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:setSeed
do
    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    print("seed = " .. rng:getSeed())
end

--@api: LRandomGenerator:getState
do
    local rng = lurek.math.newRandomGenerator(999)
    print("state = " .. rng:getState())
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:setState
do
    local rng = lurek.math.newRandomGenerator(1)
    local first = rng:random()
    local state = rng:getState()
    local skipped = rng:random()
    rng:setState(state)
    local restored = rng:random()
    print("restored = " .. tostring(skipped == restored))
    print("first = " .. first)
end

--@api: lurek.math.newTween
do
    local tw = lurek.math.newTween(2.0, "inOutCubic")
    print("duration = " .. tw:getDuration())
    print("easing = " .. tw:getEasingName())
end

--@api: LTween:addValue
do
    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    print("index = " .. index)
    print("channels = " .. tw:getValueCount())
end

--@api: LTween:getValue
do
    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    tw:setTime(0.5)
    print("value = " .. tw:getValue(index))
end

--@api: LTween:getAllValues
do
    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    tw:setTime(0.5)
    local values = tw:getAllValues()
    print("count = " .. #values)
    print("first = " .. values[1])
end

--@api: LTween:getValueCount
do
    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    print("channels = " .. tw:getValueCount())
end

--@api: LTween:update
do
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    print("done = " .. tostring(done))
    print("value = " .. tw:getValue(1))
end

--@api: LTween:isComplete
do
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(1.1)
    print("complete = " .. tostring(tw:isComplete()))
end

--@api: LTween:reset
do
    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(0.5)
    tw:reset()
    print("clock = " .. tw:getClock())
end

--@api: LTween:set
do
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    print("value = " .. tw:getValue(1))
end

--@api: LTween:setTime
do
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    print("time = " .. tw:getTime())
end

--@api: LTween:getTime
do
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    print("time = " .. tw:getTime())
end

--@api: LTween:getClock
do
    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    print("clock = " .. tw:getClock())
end

--@api: lurek.math.aabbTree
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    print("len = " .. tree:len())
    print("empty = " .. tostring(tree:isEmpty()))
end

--@api: LAabbTree:query
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    print("query hits = " .. #hits)
end

--@api: LAabbTree:queryPoint
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:queryPoint(7, 7)
    print("point hits = " .. #hits)
end

--@api: LAabbTree:contains
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    print("contains 1 = " .. tostring(tree:contains(1)))
end

--@api: LAabbTree:remove
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:remove(2)
    print("len = " .. tree:len())
end

--@api: LAabbTree:update
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:update(1, 20, 20, 30, 30)
    local hits = tree:query(19, 19, 21, 21)
    print("query hits = " .. #hits)
end

--@api: lurek.math.newSpatialHash
do
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    print("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
end

--@api: LSpatialHash:queryRect
do
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryRect(0, 0, 12, 12)
    print("rect hits = " .. #hits)
end

--@api: LSpatialHash:queryCircle
do
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryCircle(5, 5, 10)
    print("circle hits = " .. #hits)
end

--@api: LSpatialHash:querySegment
do
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:querySegment(0, 0, 50, 50)
    print("segment hits = " .. #hits)
end

--@api: LSpatialHash:remove
do
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:remove("b")
    print("items = " .. sh:getItemCount())
end

--@api: LSpatialHash:update
do
    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:update("a", 200, 200, 10, 10)
    local hits = sh:queryRect(190, 190, 20, 20)
    print("rect hits = " .. #hits)
end

--@api: lurek.math.newRectPacker
do
    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x, y = rp:pack(32, 32, "icon1")
    print("icon1 = " .. tostring(x) .. "," .. tostring(y))
    print("occupancy = " .. rp:occupancy())
end

--@api: lurek.math.newCircle
do
    local c = lurek.math.newCircle(50, 50, 25)
    print("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    print("lua type = " .. type(c))
end

--@api: LCircle:contains
do
    local circle = lurek.math.newCircle(0, 0, 10)
    print("contains = " .. tostring(circle:contains(5, 5)))
    print("owner type = " .. tostring(circle:type()))
end

--@api: LCircle:intersects
do
    local a = lurek.math.newCircle(0, 0, 10)
    local b = lurek.math.newCircle(15, 0, 10)
    print("intersects = " .. tostring(a:intersects(b)))
end

--@api: LCircle:aabb
do
    local c1 = lurek.math.newCircle(0, 0, 10)
    local minx, miny, maxx, maxy = c1:aabb()
    print("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
end

--@api: lurek.math.voronoi
do
    local cells = lurek.math.voronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    print("cells = " .. #cells)
    print("lua type = " .. type(cells))
end

--@api: lurek.math.applyEasing
do
    local linear = lurek.math.applyEasing("linear", 0.5)
    local eased = lurek.math.applyEasing("inOutCubic", 0.5)
    print("linear = " .. linear)
    print("inOutCubic = " .. eased)
end

--@api: lurek.math.inBack
do
    print("t=0.25 = " .. lurek.math.inBack(0.25))
    print("t=0.75 = " .. lurek.math.inBack(0.75))
    print("lua type = " .. type(lurek.math.inBack(0.75)))
end

--@api: lurek.math.inBounce
do
    print("t=0.25 = " .. lurek.math.inBounce(0.25))
    print("t=0.75 = " .. lurek.math.inBounce(0.75))
    print("lua type = " .. type(lurek.math.inBounce(0.75)))
end

--@api: lurek.math.inCubic
do
    print("t=0.25 = " .. lurek.math.inCubic(0.25))
    print("t=0.75 = " .. lurek.math.inCubic(0.75))
    print("lua type = " .. type(lurek.math.inCubic(0.75)))
end

--@api: lurek.math.inElastic
do
    print("t=0.25 = " .. lurek.math.inElastic(0.25))
    print("t=0.75 = " .. lurek.math.inElastic(0.75))
    print("lua type = " .. type(lurek.math.inElastic(0.75)))
end

--@api: lurek.math.inExpo
do
    print("t=0.25 = " .. lurek.math.inExpo(0.25))
    print("t=0.75 = " .. lurek.math.inExpo(0.75))
    print("lua type = " .. type(lurek.math.inExpo(0.75)))
end

--@api: lurek.math.inQuad
do
    print("t=0.25 = " .. lurek.math.inQuad(0.25))
    print("t=0.75 = " .. lurek.math.inQuad(0.75))
    print("lua type = " .. type(lurek.math.inQuad(0.75)))
end

--@api: lurek.math.inQuart
do
    print("t=0.25 = " .. lurek.math.inQuart(0.25))
    print("t=0.75 = " .. lurek.math.inQuart(0.75))
    print("lua type = " .. type(lurek.math.inQuart(0.75)))
end

--@api: lurek.math.inSine
do
    print("t=0.25 = " .. lurek.math.inSine(0.25))
    print("t=0.75 = " .. lurek.math.inSine(0.75))
    print("lua type = " .. type(lurek.math.inSine(0.75)))
end

--@api: lurek.math.linear
do
    print("t=0.25 = " .. lurek.math.linear(0.25))
    print("t=0.75 = " .. lurek.math.linear(0.75))
    print("lua type = " .. type(lurek.math.linear(0.75)))
end

--@api: lurek.math.outBack
do
    print("t=0.25 = " .. lurek.math.outBack(0.25))
    print("t=0.75 = " .. lurek.math.outBack(0.75))
    print("lua type = " .. type(lurek.math.outBack(0.75)))
end

--@api: lurek.math.outBounce
do
    print("t=0.25 = " .. lurek.math.outBounce(0.25))
    print("t=0.75 = " .. lurek.math.outBounce(0.75))
    print("lua type = " .. type(lurek.math.outBounce(0.75)))
end

--@api: lurek.math.outCubic
do
    print("t=0.25 = " .. lurek.math.outCubic(0.25))
    print("t=0.75 = " .. lurek.math.outCubic(0.75))
    print("lua type = " .. type(lurek.math.outCubic(0.75)))
end

--@api: lurek.math.outElastic
do
    print("t=0.25 = " .. lurek.math.outElastic(0.25))
    print("t=0.75 = " .. lurek.math.outElastic(0.75))
    print("lua type = " .. type(lurek.math.outElastic(0.75)))
end

--@api: lurek.math.outExpo
do
    print("t=0.25 = " .. lurek.math.outExpo(0.25))
    print("t=0.75 = " .. lurek.math.outExpo(0.75))
    print("lua type = " .. type(lurek.math.outExpo(0.75)))
end

--@api: lurek.math.outQuad
do
    print("t=0.25 = " .. lurek.math.outQuad(0.25))
    print("t=0.75 = " .. lurek.math.outQuad(0.75))
    print("lua type = " .. type(lurek.math.outQuad(0.75)))
end

--@api: lurek.math.outQuart
do
    print("t=0.25 = " .. lurek.math.outQuart(0.25))
    print("t=0.75 = " .. lurek.math.outQuart(0.75))
    print("lua type = " .. type(lurek.math.outQuart(0.75)))
end

--@api: lurek.math.outSine
do
    print("t=0.25 = " .. lurek.math.outSine(0.25))
    print("t=0.75 = " .. lurek.math.outSine(0.75))
    print("lua type = " .. type(lurek.math.outSine(0.75)))
end

--@api: lurek.math.inOutBack
do
    print("t=0.25 = " .. lurek.math.inOutBack(0.25))
    print("t=0.75 = " .. lurek.math.inOutBack(0.75))
    print("lua type = " .. type(lurek.math.inOutBack(0.75)))
end

--@api: lurek.math.inOutBounce
do
    print("t=0.25 = " .. lurek.math.inOutBounce(0.25))
    print("t=0.75 = " .. lurek.math.inOutBounce(0.75))
    print("lua type = " .. type(lurek.math.inOutBounce(0.75)))
end

--@api: lurek.math.inOutCubic
do
    print("t=0.25 = " .. lurek.math.inOutCubic(0.25))
    print("t=0.75 = " .. lurek.math.inOutCubic(0.75))
    print("lua type = " .. type(lurek.math.inOutCubic(0.75)))
end

--@api: lurek.math.inOutElastic
do
    print("t=0.25 = " .. lurek.math.inOutElastic(0.25))
    print("t=0.75 = " .. lurek.math.inOutElastic(0.75))
    print("lua type = " .. type(lurek.math.inOutElastic(0.75)))
end

--@api: lurek.math.inOutExpo
do
    print("t=0.25 = " .. lurek.math.inOutExpo(0.25))
    print("t=0.75 = " .. lurek.math.inOutExpo(0.75))
    print("lua type = " .. type(lurek.math.inOutExpo(0.75)))
end

--@api: lurek.math.inOutQuad
do
    print("t=0.25 = " .. lurek.math.inOutQuad(0.25))
    print("t=0.75 = " .. lurek.math.inOutQuad(0.75))
    print("lua type = " .. type(lurek.math.inOutQuad(0.75)))
end

--@api: lurek.math.inOutQuart
do
    print("t=0.25 = " .. lurek.math.inOutQuart(0.25))
    print("t=0.75 = " .. lurek.math.inOutQuart(0.75))
    print("lua type = " .. type(lurek.math.inOutQuart(0.75)))
end

--@api: lurek.math.inOutSine
do
    print("t=0.25 = " .. lurek.math.inOutSine(0.25))
    print("t=0.75 = " .. lurek.math.inOutSine(0.75))
    print("lua type = " .. type(lurek.math.inOutSine(0.75)))
end

--@api: LRandomGenerator:getSeed
do
    local rng = lurek.math.newRandomGenerator(77)
    print("seed = " .. rng:getSeed())
    print("owner type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:type
do
    local rng = lurek.math.newRandomGenerator(77)
    print("type = " .. rng:type())
    print("typeOf LObject = " .. tostring(rng:typeOf("LObject")))
end

--@api: LRandomGenerator:typeOf
do
    local rng = lurek.math.newRandomGenerator(77)
    print("typeOf = " .. tostring(rng:typeOf("LRandomGenerator")))
    print("type = " .. tostring(rng:type()))
end

--@api: LRandomGenerator:roll
do
    local rng = lurek.math.newRandomGenerator(1)
    local d20 = rng:roll(20)
    print("d20 = " .. d20)
end

--@api: LRandomGenerator:rollN
do
    local rng = lurek.math.newRandomGenerator(2)
    local dice = rng:rollN(3, 6)
    print("3d6 = " .. dice[1] .. ", " .. dice[2] .. ", " .. dice[3])
end

--@api: LRandomGenerator:rollSum
do
    local rng = lurek.math.newRandomGenerator(3)
    local total = rng:rollSum(4, 6)
    print("4d6 sum = " .. total)
end

--@api: LRandomGenerator:rollKeepHighest
do
    local rng = lurek.math.newRandomGenerator(4)
    local stat = rng:rollKeepHighest(4, 6, 3)
    print("4d6 keep 3 highest = " .. stat)
end

--@api: LRandomGenerator:rollKeepLowest
do
    local rng = lurek.math.newRandomGenerator(5)
    local penalty = rng:rollKeepLowest(4, 6, 3)
    print("4d6 keep 3 lowest = " .. penalty)
end

--@api: LRandomGenerator:rollAdvantage
do
    local rng = lurek.math.newRandomGenerator(6)
    local adv = rng:rollAdvantage(20)
    print("d20 advantage = " .. adv)
end

--@api: LRandomGenerator:rollDisadvantage
do
    local rng = lurek.math.newRandomGenerator(7)
    local dis = rng:rollDisadvantage(20)
    print("d20 disadvantage = " .. dis)
end

--@api: LRandomGenerator:rollExploding
do
    local rng = lurek.math.newRandomGenerator(8)
    local ex = rng:rollExploding(3, 6)
    print("3d6 exploding = " .. ex)
end

--@api: LRandomGenerator:countSuccesses
do
    local rng = lurek.math.newRandomGenerator(9)
    local hits = rng:countSuccesses(5, 10, 7)
    print("5d10 successes (7+) = " .. hits)
end

--@api: LRandomGenerator:chance
do
    local rng = lurek.math.newRandomGenerator(10)
    local crit = rng:chance(0.05)
    print("critical hit (5%) = " .. tostring(crit))
end

--@api: lurek.math.geometricVoronoi
do
    local cells = lurek.math.geometricVoronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    print("cells = " .. #cells)
    print("lua type = " .. type(cells))
end

--@api: LAabbTree:clear
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:clear()
    print("empty = " .. tostring(tree:isEmpty()))
end

--@api: LAabbTree:insert
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    print("len = " .. tree:len())
end

--@api: LAabbTree:isEmpty
do
    local tree = lurek.math.aabbTree()
    print("empty = " .. tostring(tree:isEmpty()))
    print("owner type = " .. tostring(tree:type()))
end

--@api: LAabbTree:len
do
    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    print("len = " .. tree:len())
end

--@api: LAabbTree:type
do
    local tree = lurek.math.aabbTree()
    print(tree:type())
    print("typeOf LObject = " .. tostring(tree:typeOf("LObject")))
end

--@api: LAabbTree:typeOf
do
    local tree = lurek.math.aabbTree()
    print(tostring(tree:typeOf("LAabbTree")))
    print("type = " .. tostring(tree:type()))
end

--@api: LBezierCurve:getControlPointCount
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    print("count = " .. curve:getControlPointCount())
    print("owner type = " .. tostring(curve:type()))
end

--@api: LBezierCurve:type
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    print(curve:type())
    print("typeOf LObject = " .. tostring(curve:typeOf("LObject")))
end

--@api: LBezierCurve:typeOf
do
    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    print(tostring(curve:typeOf("LBezierCurve")))
    print("type = " .. tostring(curve:type()))
end

--@api: LCatmullRom:len
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    print("len = " .. spline:len())
    print("owner type = " .. tostring(spline:type()))
end

--@api: LCatmullRom:type
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    print(spline:type())
    print("typeOf LObject = " .. tostring(spline:typeOf("LObject")))
end

--@api: LCatmullRom:typeOf
do
    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    print(tostring(spline:typeOf("LCatmullRom")))
    print("type = " .. tostring(spline:type()))
end

--@api: LCircle:area
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("area = " .. c:area())
    print("owner type = " .. tostring(c:type()))
end

--@api: LCircle:perimeter
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("perimeter = " .. c:perimeter())
    print("owner type = " .. tostring(c:type()))
end

--@api: LCircle:radius
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("radius = " .. c:radius())
    print("owner type = " .. tostring(c:type()))
end

--@api: LCircle:type
do
    local c = lurek.math.newCircle(100, 100, 50)
    print(c:type())
    print("typeOf LObject = " .. tostring(c:typeOf("LObject")))
end

--@api: LCircle:typeOf
do
    local c = lurek.math.newCircle(100, 100, 50)
    print(tostring(c:typeOf("LCircle")))
    print("type = " .. tostring(c:type()))
end

--@api: LCircle:x
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("x = " .. c:x())
    print("owner type = " .. tostring(c:type()))
end

--@api: LCircle:y
do
    local c = lurek.math.newCircle(100, 100, 50)
    print("y = " .. c:y())
    print("owner type = " .. tostring(c:type()))
end

--@api: LHermite:sample
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local x, y = h:sample(0.5)
    print("sample = " .. x .. "," .. y)
end

--@api: LHermite:type
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    print(h:type())
    print("typeOf LObject = " .. tostring(h:typeOf("LObject")))
end

--@api: LHermite:typeOf
do
    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    print(tostring(h:typeOf("LHermite")))
    print("type = " .. tostring(h:type()))
end

--@api: LRectPacker:clear
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    rp:clear()
    print("packed = " .. #rp:getPacked())
end

--@api: LRectPacker:getPacked
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    local packed = rp:getPacked()
    print("packed = " .. #packed)
end

--@api: LRectPacker:occupancy
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    print("occupancy = " .. rp:occupancy())
end

--@api: LRectPacker:pack
do
    local rp = lurek.math.newRectPacker(512, 512, 2)
    local x, y = rp:pack(64, 64, "box")
    print("pack = " .. tostring(x) .. "," .. tostring(y))
end

--@api: LSpatialHash:clear
do
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    sh:clear()
    print("count = " .. sh:getItemCount())
end

--@api: LSpatialHash:getCellSize
do
    local sh = lurek.math.newSpatialHash(32)
    print("cell size = " .. sh:getCellSize())
    print("owner type = " .. tostring(sh:type()))
end

--@api: LSpatialHash:getItemCount
do
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    print("items = " .. sh:getItemCount())
end

--@api: LSpatialHash:insert
do
    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    print("items = " .. sh:getItemCount())
end

--@api: LSpatialHash:type
do
    local sh = lurek.math.newSpatialHash(32)
    print(sh:type())
    print("typeOf LObject = " .. tostring(sh:typeOf("LObject")))
end

--@api: LSpatialHash:typeOf
do
    local sh = lurek.math.newSpatialHash(32)
    print(tostring(sh:typeOf("LSpatialHash")))
    print("type = " .. tostring(sh:type()))
end

--@api: LTransform:type
do
    local tf = lurek.math.newTransform()
    print(tf:type())
    print("typeOf LObject = " .. tostring(tf:typeOf("LObject")))
end

--@api: LTransform:typeOf
do
    local tf = lurek.math.newTransform()
    print(tostring(tf:typeOf("LTransform")))
    print("type = " .. tostring(tf:type()))
end

--@api: LVec2:type
do
    local v = lurek.math.Vec2(3, 4)
    print(v:type())
    print("typeOf LObject = " .. tostring(v:typeOf("LObject")))
end

--@api: LVec2:typeOf
do
    local v = lurek.math.Vec2(3, 4)
    print(v:typeOf("LVec2"))
    print("type = " .. tostring(v:type()))
end

--@api: LVec2:x
do
    local v = lurek.math.Vec2(3, 4)
    print("x=" .. v.x)
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec2:y
do
    local v = lurek.math.Vec2(3, 4)
    print("y=" .. v.y)
    print("owner type = " .. tostring(v:type()))
end

--@api: LVec3:type
do
    local v = lurek.math.Vec3(1, 2, 3)
    print(v:type())
    print("typeOf LObject = " .. tostring(v:typeOf("LObject")))
end

--@api: LVec3:typeOf
do
    local v = lurek.math.Vec3(1, 2, 3)
    print(tostring(v:typeOf("LVec3")))
    print("type = " .. tostring(v:type()))
end

--@api: lurek.math.easingNames
do
    local names = lurek.math.easingNames()
    print("easing count = " .. #names)
    print("lua type = " .. type(names))
end

--@api: lurek.math.cubicBezier
do
    local y = lurek.math.cubicBezier(0.25, 0.1, 0.25, 1.0, 0.5)
    print("cubicBezier(0.5) = " .. y)
    print("lua type = " .. type(y))
end

--@api: lurek.math.newLootTable
do
    local loot = lurek.math.newLootTable({ seed = 42 })
    loot:add("common", 10.0, { tier = "c" })
    loot:add("rare", 1.0, { tier = "r" })
    loot:build()
    local pick = loot:sample()
    print("loot pick = " .. tostring(pick and pick.id))
end

--@api: lurek.math.lootFromList
do
    local loot = lurek.math.lootFromList({
        { id = "gold", weight = 20.0, meta = { kind = "currency" } },
        { id = "gem", weight = 2.0, meta = { kind = "currency" } },
    })
    print("fromList count = " .. loot:entryCount())
end

--@api: lurek.math.newPityTracker
do
    local loot = lurek.math.newLootTable(7)
    loot:add("common", 100.0)
    loot:add("rare", 0.0, { tier = "r" })
    loot:build()

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:notice("common")
    local id = lurek.math.sampleWithPity(loot, pity)
    print("pity sample = " .. tostring(id))
end

--@api: lurek.math.sampleWithPity
do
    local loot = lurek.math.newLootTable(9)
    loot:add("a", 1.0)
    loot:build()
    local pity = lurek.math.newPityTracker("a", 1)
    local id = lurek.math.sampleWithPity(loot, pity)
    print("sampleWithPity = " .. tostring(id))
end

--@api: LLootTable:merge
do
    local a = lurek.math.newLootTable(9)
    local b = lurek.math.newLootTable(10)
    a:add("a", 1.0)
    b:add("b", 1.0)
    a:merge(b)
    a:build()
    print("merged entries = " .. tostring(a:entryCount()))
end

--@api: LLootTable:save
do
    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    print("save blob = " .. tostring(blob))
end

--@api: LLootTable:restore
do
    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    local restored = lurek.math.newLootTable()
    restored:restore(blob)
    print("restore count = " .. tostring(restored:entryCount()))
end

--@api: LPityTracker:save
do
    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    print("pity save blob = " .. tostring(pity_blob))
end

--@api: LPityTracker:restore
do
    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    pity:restore(pity_blob)
    print("pity restore ok")
end

--@api: lurek.math.lootFromToml
do
    local tbl = lurek.math.lootFromToml("save/loot_table_unit_test.toml")
    print("lootFromToml entries = " .. tostring(tbl:entryCount()))
    print("lua type = " .. type(tbl))
end

--@api: LLootTable:add
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    print("add ok")
end

--@api: LLootTable:build
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    print("build ok")
end

--@api: LLootTable:entryCount
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    print("entryCount = " .. tostring(tbl:entryCount()))
end

--@api: LLootTable:remove
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:remove("wood")
    print("remove ok")
end

--@api: LLootTable:sample
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    print("sample = " .. tostring(tbl:sample()))
end

--@api: LLootTable:sampleN
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleN(2)
    print("sampleN = " .. tostring(#picks))
end

--@api: LLootTable:sampleUnique
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleUnique(2)
    print("sampleUnique = " .. tostring(#picks))
end

--@api: LLootTable:setSeed
do
    local tbl = lurek.math.newLootTable(1)
    tbl:setSeed(7)
    print("setSeed ok")
end

--@api: LLootTable:setWeight
do
    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:setWeight("wood", 2.0)
    print("setWeight ok")
end

--@api: LLootTable:type
do
    local tbl = lurek.math.newLootTable(1)
    print("type = " .. tostring(tbl:type()))
    print("typeOf LObject = " .. tostring(tbl:typeOf("LObject")))
end

--@api: LLootTable:typeOf
do
    local tbl = lurek.math.newLootTable(1)
    print("typeOf = " .. tostring(tbl:typeOf("LLootTable")))
    print("type = " .. tostring(tbl:type()))
end

--@api: LPityTracker:counter
do
    local pity = lurek.math.newPityTracker("rare", 2)
    print("counter = " .. tostring(pity:counter()))
    print("owner type = " .. tostring(pity:type()))
end

--@api: LPityTracker:export
do
    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    print("export ok = " .. tostring(snapshot ~= nil))
end

--@api: LPityTracker:import
do
    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    pity:import(snapshot)
    print("import ok")
end

--@api: LPityTracker:isPrimed
do
    local pity = lurek.math.newPityTracker("rare", 1)
    pity:notice("common")
    print("isPrimed = " .. tostring(pity:isPrimed()))
end

--@api: LPityTracker:notice
do
    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    print("notice ok")
end

--@api: LPityTracker:reset
do
    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:reset()
    print("reset counter = " .. tostring(pity:counter()))
end

--@api: LPityTracker:type
do
    local pity = lurek.math.newPityTracker("rare", 2)
    print("type = " .. tostring(pity:type()))
    print("typeOf LObject = " .. tostring(pity:typeOf("LObject")))
end

--@api: LPityTracker:typeOf
do
    local pity = lurek.math.newPityTracker("rare", 2)
    print("typeOf = " .. tostring(pity:typeOf("LPityTracker")))
    print("type = " .. tostring(pity:type()))
end
