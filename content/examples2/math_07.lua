--- Math Module: object APIs — LAabbTree, LBezierCurve, LCatmullRom, LCircle,
---               LHermite, LRectPacker, LSpatialHash, LTransform, LVec2, LVec3

--@api-stub: LAabbTree:clear
--@api-stub: LAabbTree:insert
--@api-stub: LAabbTree:isEmpty
--@api-stub: LAabbTree:len
--@api-stub: LAabbTree:type
--@api-stub: LAabbTree:typeOf
-- AABB spatial tree: insert, query, update, remove, clear.
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
--@api-stub: LBezierCurve:type
--@api-stub: LBezierCurve:typeOf
-- Bezier curve: control points, evaluation, transform, render.
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
--@api-stub: LCatmullRom:type
--@api-stub: LCatmullRom:typeOf
-- Catmull-Rom spline: add/remove points, sample.
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
--@api-stub: LCircle:perimeter
--@api-stub: LCircle:radius
--@api-stub: LCircle:type
--@api-stub: LCircle:typeOf
--@api-stub: LCircle:x
--@api-stub: LCircle:y
-- Circle geometry operations.
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
--@api-stub: LHermite:type
--@api-stub: LHermite:typeOf
-- Hermite spline sampling and type info.
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
--@api-stub: LRectPacker:getPacked
--@api-stub: LRectPacker:occupancy
--@api-stub: LRectPacker:pack
-- Rectangle packer: atlas packing operations.
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
--@api-stub: LSpatialHash:getCellSize
--@api-stub: LSpatialHash:getItemCount
--@api-stub: LSpatialHash:insert
--@api-stub: LSpatialHash:type
--@api-stub: LSpatialHash:typeOf
-- Spatial hash grid: insert, query, update, remove.
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
--@api-stub: LTransform:typeOf
-- Transform: matrix ops, decompose, transform points.
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
--@api-stub: LVec2:typeOf
--@api-stub: LVec2:x
--@api-stub: LVec2:y
-- Vec2: all vector operations.
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
--@api-stub: LVec3:typeOf
-- Vec3: all vector operations.
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

print("math_07.lua")
