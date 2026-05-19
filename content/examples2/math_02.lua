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
--@api-stub: LBezierCurve:setControlPoint
-- Reads and writes individual control points.
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
--@api-stub: LBezierCurve:removeControlPoint
-- Adds and removes control points.
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
--@api-stub: LBezierCurve:rotate
--@api-stub: LBezierCurve:scale
-- Transforms the curve in place.
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
--@api-stub: LCatmullRom:removePoint
-- Adds and removes points.
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
end

--@api-stub: LHermite:sample (edge cases)
-- Sampling at t=0 and t=1.
do
    ---@type LHermite
    local h = lurek.math.hermite(10, 20, 80, 90, 40, 0, -40, 0)
    local x0, y0 = h:sample(0)
    local x1, y1 = h:sample(1)
    print("start = " .. x0 .. "," .. y0)
    print("end   = " .. x1 .. "," .. y1)
end

print("math_02.lua")
