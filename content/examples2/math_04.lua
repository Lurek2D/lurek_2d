--- Math Module Part 5: vectors (LVec2, LVec3) and transforms (LTransform)

--@api-stub: lurek.math.vec2 / lurek.math.Vec2
-- Creates a 2D vector.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    print("vec2 = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:length / lengthSquared
-- Vector magnitude.
do
    ---@type LVec2
    local v = lurek.math.Vec2(3, 4)
    print("length = " .. v:length())
    print("lengthSq = " .. v:lengthSquared())
end

--@api-stub: LVec2:normalize / normalized
-- Unit vector.
do
    ---@type LVec2
    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    print("normalized = " .. n.x .. "," .. n.y)
    v:normalize()
    print("after normalize = " .. v.x .. "," .. v.y)
end

--@api-stub: LVec2:dot / cross
-- Dot product and cross product.
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

--@api-stub: lurek.math.vec3 / lurek.math.Vec3
-- Creates a 3D vector.
do
    ---@type LVec3
    local v = lurek.math.vec3(1, 2, 3)
    print("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
end

--@api-stub: LVec3:length / lengthSquared
-- 3D vector magnitude.
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

--@api-stub: LVec3:dot / cross
-- 3D dot and cross products.
do
    ---@type LVec3
    local a = lurek.math.vec3(1, 0, 0)
    ---@type LVec3
    local b = lurek.math.vec3(0, 1, 0)
    print("dot = " .. a:dot(b))
    local c = a:cross(b)
    print("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
end

--@api-stub: LVec3:add / sub / scale
-- 3D vector arithmetic.
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

--@api-stub: LVec3:distance / lerp
-- 3D distance and interpolation.
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

--@api-stub: LTransform:translate / rotate / scale / shear
-- Incremental transform operations.
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

--@api-stub: LTransform:transformPoint / inverseTransformPoint
-- Forward and inverse point mapping.
do
    ---@type LTransform
    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    print("forward = " .. fx .. "," .. fy)
    print("inverse = " .. ix .. "," .. iy)
end

--@api-stub: LTransform:clone / inverse
-- Cloning and inversion.
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

--@api-stub: LTransform:reset / setTransformation
-- Resets or completely replaces the transform.
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

print("math_04.lua")
