-- content/examples/math.lua
-- love2d-style usage snippets for the lurek.math API (204 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/math.lua

-- ── lurek.math.* functions ──

--@api-stub: lurek.math.newRandomGenerator
-- Creates a new random number generator with an optional seed.
-- Build once at startup; reuse across frames.
local randomgenerator = lurek.math.newRandomGenerator(seed)
print("created", randomgenerator)
return randomgenerator

--@api-stub: lurek.math.newTransform
-- Creates a new Transform, optionally initialised from full parameters.
-- Build once at startup; reuse across frames.
local transform = lurek.math.newTransform()
print("created", transform)
return transform

--@api-stub: lurek.math.newBezierCurve
-- Creates a new BezierCurve from a flat table of coordinates {x1,y1, x2,y2, ...}.
-- Build once at startup; reuse across frames.
local beziercurve = lurek.math.newBezierCurve(points)
print("created", beziercurve)
return beziercurve

--@api-stub: lurek.math.newTween
-- Creates a new Tween with the given duration and easing name.
-- Build once at startup; reuse across frames.
local tween = lurek.math.newTween(1.0, "main")
print("created", tween)
return tween

--@api-stub: lurek.math.newSpatialHash
-- Creates a new SpatialHash with the given cell size.
-- Build once at startup; reuse across frames.
local spatialhash = lurek.math.newSpatialHash(cell_size)
print("created", spatialhash)
return spatialhash

--@api-stub: lurek.math.newNoiseGenerator
-- Creates a new seeded noise generator.
-- Build once at startup; reuse across frames.
local noisegenerator = lurek.math.newNoiseGenerator(seed)
print("created", noisegenerator)
return noisegenerator

--@api-stub: lurek.math.perlin2d
-- Returns 2D Perlin noise at (x, y) with the given seed.
-- See the module spec for detailed semantics.
local result = lurek.math.perlin2d(100, 100, seed)
print("perlin2d:", result)
return result

--@api-stub: lurek.math.perlin3d
-- Returns 3D Perlin noise at (x, y, z) with the given seed.
-- See the module spec for detailed semantics.
local result = lurek.math.perlin3d(100, 100, 0, seed)
print("perlin3d:", result)
return result

--@api-stub: lurek.math.simplex2d
-- Returns 2D Simplex noise at (x, y) with the given seed.
-- See the module spec for detailed semantics.
local result = lurek.math.simplex2d(100, 100, seed)
print("simplex2d:", result)
return result

--@api-stub: lurek.math.fbm
-- Returns fractal Brownian motion noise at (x, y).
-- See the module spec for detailed semantics.
local result = lurek.math.fbm()
print("fbm:", result)
return result

--@api-stub: lurek.math.applyEasing
-- Applies a named easing function to progress value t.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.math.applyEasing("main", t)
print("applyEasing applied")
print("ok")

--@api-stub: lurek.math.linear
-- Linear easing (identity).
-- See the module spec for detailed semantics.
local result = lurek.math.linear(t)
print("linear:", result)
return result

--@api-stub: lurek.math.inQuad
-- Quadratic ease-in — acceleration that starts at zero and increases.
-- See the module spec for detailed semantics.
local result = lurek.math.inQuad(t)
print("inQuad:", result)
return result

--@api-stub: lurek.math.outQuad
-- Quadratic ease-out — deceleration that starts fast and ends at zero.
-- See the module spec for detailed semantics.
local result = lurek.math.outQuad(t)
print("outQuad:", result)
return result

--@api-stub: lurek.math.inOutQuad
-- Quadratic ease-in-out — slow start, fast middle, slow end.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutQuad(t)
print("inOutQuad:", result)
return result

--@api-stub: lurek.math.inCubic
-- Cubic ease-in — acceleration starts slowly then increases sharply.
-- See the module spec for detailed semantics.
local result = lurek.math.inCubic(t)
print("inCubic:", result)
return result

--@api-stub: lurek.math.outCubic
-- Cubic ease-out — rapid deceleration using a cubic power curve.
-- See the module spec for detailed semantics.
local result = lurek.math.outCubic(t)
print("outCubic:", result)
return result

--@api-stub: lurek.math.inOutCubic
-- Cubic ease-in-out — slow start and end with fast cubic middle.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutCubic(t)
print("inOutCubic:", result)
return result

--@api-stub: lurek.math.inQuart
-- Quartic ease-in — strongly delayed acceleration using a power-of-4 curve.
-- See the module spec for detailed semantics.
local result = lurek.math.inQuart(t)
print("inQuart:", result)
return result

--@api-stub: lurek.math.outQuart
-- Quartic ease-out — rapid deceleration using a power-of-4 curve.
-- See the module spec for detailed semantics.
local result = lurek.math.outQuart(t)
print("outQuart:", result)
return result

--@api-stub: lurek.math.inOutQuart
-- Quartic ease-in-out — very slow start and end with a sharp middle peak.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutQuart(t)
print("inOutQuart:", result)
return result

--@api-stub: lurek.math.inSine
-- Sinusoidal ease-in — gentle acceleration based on a sine curve.
-- See the module spec for detailed semantics.
local result = lurek.math.inSine(t)
print("inSine:", result)
return result

--@api-stub: lurek.math.outSine
-- Sinusoidal ease-out — gentle deceleration based on a cosine curve.
-- See the module spec for detailed semantics.
local result = lurek.math.outSine(t)
print("outSine:", result)
return result

--@api-stub: lurek.math.inOutSine
-- Sinusoidal ease-in-out — smooth S-curve based on cosine interpolation.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutSine(t)
print("inOutSine:", result)
return result

--@api-stub: lurek.math.inExpo
-- Exponential ease-in — very slow start that accelerates sharply near the end.
-- See the module spec for detailed semantics.
local result = lurek.math.inExpo(t)
print("inExpo:", result)
return result

--@api-stub: lurek.math.outExpo
-- Exponential ease-out — sharp initial speed that decelerates exponentially.
-- See the module spec for detailed semantics.
local result = lurek.math.outExpo(t)
print("outExpo:", result)
return result

--@api-stub: lurek.math.inOutExpo
-- Exponential ease-in-out — very slow start and end with an exponential surge.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutExpo(t)
print("inOutExpo:", result)
return result

--@api-stub: lurek.math.inElastic
-- Elastic ease-in — spring-like overshoot at the beginning of the motion.
-- See the module spec for detailed semantics.
local result = lurek.math.inElastic(t)
print("inElastic:", result)
return result

--@api-stub: lurek.math.outElastic
-- Elastic ease-out — spring-like oscillation that settles at the target.
-- See the module spec for detailed semantics.
local result = lurek.math.outElastic(t)
print("outElastic:", result)
return result

--@api-stub: lurek.math.outBounce
-- Bounce ease-out — simulates a ball bouncing against the target value.
-- See the module spec for detailed semantics.
local result = lurek.math.outBounce(t)
print("outBounce:", result)
return result

--@api-stub: lurek.math.inBounce
-- Bounce ease-in — reverse bounce effect that accelerates into the motion.
-- See the module spec for detailed semantics.
local result = lurek.math.inBounce(t)
print("inBounce:", result)
return result

--@api-stub: lurek.math.inBack
-- Back ease-in — overshoots slightly before settling at the target.
-- See the module spec for detailed semantics.
local result = lurek.math.inBack(t)
print("inBack:", result)
return result

--@api-stub: lurek.math.outBack
-- Back ease-out — overshoots the target then snaps back into place.
-- See the module spec for detailed semantics.
local result = lurek.math.outBack(t)
print("outBack:", result)
return result

--@api-stub: lurek.math.inOutElastic
-- Elastic ease-in-out — spring-like oscillation on both ends.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutElastic(t)
print("inOutElastic:", result)
return result

--@api-stub: lurek.math.inOutBounce
-- Bounce ease-in-out — bouncing motion on both ends.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutBounce(t)
print("inOutBounce:", result)
return result

--@api-stub: lurek.math.inOutBack
-- Back ease-in-out — overshoot on both ends.
-- See the module spec for detailed semantics.
local result = lurek.math.inOutBack(t)
print("inOutBack:", result)
return result

--@api-stub: lurek.math.triangulate
-- Triangulates a simple polygon given as a flat table {x1,y1, x2,y2, ...}.
-- See the module spec for detailed semantics.
local result = lurek.math.triangulate(pts)
print("triangulate:", result)
return result

--@api-stub: lurek.math.isConvex
-- Returns true if the polygon (flat table {x1,y1,...}) is convex.
-- Use as a guard inside lurek.update or event handlers.
if lurek.math.isConvex(pts) then
  print("isConvex -> true")
end

--@api-stub: lurek.math.gammaToLinear
-- Converts a gamma-encoded sRGB value to linear space.
-- See the module spec for detailed semantics.
local result = lurek.math.gammaToLinear(c)
print("gammaToLinear:", result)
return result

--@api-stub: lurek.math.linearToGamma
-- Converts a linear-space value to gamma-encoded sRGB.
-- See the module spec for detailed semantics.
local result = lurek.math.linearToGamma(c)
print("linearToGamma:", result)
return result

--@api-stub: lurek.math.angleBetween
-- Returns the angle in radians from (x1, y1) to (x2, y2).
-- See the module spec for detailed semantics.
local result = lurek.math.angleBetween(x1, y1, x2, y2)
print("angleBetween:", result)
return result

--@api-stub: lurek.math.circleContainsPoint
-- Returns true if the point (px, py) lies inside the circle.
-- See the module spec for detailed semantics.
local result = lurek.math.circleContainsPoint(cx, cy, 1, px, py)
print("circleContainsPoint:", result)
return result

--@api-stub: lurek.math.circleIntersectsCircle
-- Returns true if two circles overlap.
-- See the module spec for detailed semantics.
local result = lurek.math.circleIntersectsCircle(x1, y1, r1, x2, y2, r2)
print("circleIntersectsCircle:", result)
return result

--@api-stub: lurek.math.circleIntersectsLine
-- Tests an infinite line against a circle.
-- See the module spec for detailed semantics.
local result = lurek.math.circleIntersectsLine(cx, cy, 1, lx1, ly1, lx2, ly2)
print("circleIntersectsLine:", result)
return result

--@api-stub: lurek.math.circleIntersectsSegment
-- Tests a line segment against a circle.
-- See the module spec for detailed semantics.
local result = lurek.math.circleIntersectsSegment(cx, cy, 1, sx1, sy1, sx2, sy2)
print("circleIntersectsSegment:", result)
return result

--@api-stub: lurek.math.closestPointOnSegment
-- Returns the closest point on segment (x1,y1)-(x2,y2) to point (px,py).
-- See the module spec for detailed semantics.
local result = lurek.math.closestPointOnSegment(px, py, x1, y1, x2, y2)
print("closestPointOnSegment:", result)
return result

--@api-stub: lurek.math.convexHull
-- Computes the convex hull of a flat {x1,y1,...} point list.
-- See the module spec for detailed semantics.
local result = lurek.math.convexHull(pts)
print("convexHull:", result)
return result

--@api-stub: lurek.math.delaunayTriangulate
-- Delaunay triangulation of a flat {x1,y1,...} point list.
-- See the module spec for detailed semantics.
local result = lurek.math.delaunayTriangulate(pts)
print("delaunayTriangulate:", result)
return result

--@api-stub: lurek.math.lineIntersect
-- Infinite line intersection.
-- See the module spec for detailed semantics.
local result = lurek.math.lineIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
print("lineIntersect:", result)
return result

--@api-stub: lurek.math.pointInPolygon
-- Returns true if (px, py) is inside the polygon given as a flat {x1,y1,...} table.
-- See the module spec for detailed semantics.
local result = lurek.math.pointInPolygon(pts, px, py)
print("pointInPolygon:", result)
return result

--@api-stub: lurek.math.polygonArea
-- Returns the signed area of a polygon given as a flat {x1,y1,...} table.
-- See the module spec for detailed semantics.
local result = lurek.math.polygonArea(pts)
print("polygonArea:", result)
return result

--@api-stub: lurek.math.polygonCentroid
-- Returns the centroid (cx, cy) of a polygon given as a flat {x1,y1,...} table.
-- See the module spec for detailed semantics.
local result = lurek.math.polygonCentroid(pts)
print("polygonCentroid:", result)
return result

--@api-stub: lurek.math.segmentIntersectsSegment
-- Tests if two line segments intersect.
-- See the module spec for detailed semantics.
local result = lurek.math.segmentIntersectsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
print("segmentIntersectsSegment:", result)
return result

--@api-stub: lurek.math.bresenham
-- Rasterizes a line from (x1,y1) to (x2,y2) using Bresenham's algorithm.
-- See the module spec for detailed semantics.
local result = lurek.math.bresenham(x1, y1, x2, y2)
print("bresenham:", result)
return result

--@api-stub: lurek.math.rad
-- Converts degrees to radians.
-- See the module spec for detailed semantics.
local result = lurek.math.rad(deg)
print("rad:", result)
return result

--@api-stub: lurek.math.deg
-- Converts radians to degrees.
-- See the module spec for detailed semantics.
local result = lurek.math.deg(rad)
print("deg:", result)
return result

--@api-stub: lurek.math.sin
-- Returns the sine of x (radians).
-- See the module spec for detailed semantics.
local result = lurek.math.sin(100)
print("sin:", result)
return result

--@api-stub: lurek.math.cos
-- Returns the cosine of x (radians).
-- See the module spec for detailed semantics.
local result = lurek.math.cos(100)
print("cos:", result)
return result

--@api-stub: lurek.math.tan
-- Returns the tangent of x (radians).
-- See the module spec for detailed semantics.
local result = lurek.math.tan(100)
print("tan:", result)
return result

--@api-stub: lurek.math.asin
-- Returns the arcsine of x, in radians.
-- See the module spec for detailed semantics.
local result = lurek.math.asin(100)
print("asin:", result)
return result

--@api-stub: lurek.math.acos
-- Returns the arccosine of x, in radians.
-- See the module spec for detailed semantics.
local result = lurek.math.acos(100)
print("acos:", result)
return result

--@api-stub: lurek.math.atan
-- Returns the arctangent of x (or atan2(y, x) when two args given).
-- See the module spec for detailed semantics.
local result = lurek.math.atan(100, 100)
print("atan:", result)
return result

--@api-stub: lurek.math.atan2
-- Returns atan(y/x) using the signs of both args to determine the quadrant.
-- See the module spec for detailed semantics.
local result = lurek.math.atan2(100, 100)
print("atan2:", result)
return result

--@api-stub: lurek.math.sqrt
-- Returns the square root of x.
-- See the module spec for detailed semantics.
local result = lurek.math.sqrt(100)
print("sqrt:", result)
return result

--@api-stub: lurek.math.abs
-- Returns the absolute value of x.
-- See the module spec for detailed semantics.
local result = lurek.math.abs(100)
print("abs:", result)
return result

--@api-stub: lurek.math.floor
-- Returns the largest integer ≤ x.
-- See the module spec for detailed semantics.
local result = lurek.math.floor(100)
print("floor:", result)
return result

--@api-stub: lurek.math.ceil
-- Returns the smallest integer ≥ x.
-- See the module spec for detailed semantics.
local result = lurek.math.ceil(100)
print("ceil:", result)
return result

--@api-stub: lurek.math.round
-- Returns x rounded to the nearest integer (half-up).
-- See the module spec for detailed semantics.
local result = lurek.math.round(100)
print("round:", result)
return result

--@api-stub: lurek.math.exp
-- Returns e raised to the power x.
-- See the module spec for detailed semantics.
local result = lurek.math.exp(100)
print("exp:", result)
return result

--@api-stub: lurek.math.log
-- Returns the natural log of x, or log base b if b is supplied.
-- See the module spec for detailed semantics.
local result = lurek.math.log(100, 0)
print("log:", result)
return result

--@api-stub: lurek.math.pow
-- Returns x raised to the power y.
-- See the module spec for detailed semantics.
local result = lurek.math.pow(100, 100)
print("pow:", result)
return result

--@api-stub: lurek.math.min
-- Returns the smallest of the supplied numbers.
-- See the module spec for detailed semantics.
local result = lurek.math.min()
print("min:", result)
return result

--@api-stub: lurek.math.max
-- Returns the largest of the supplied numbers.
-- See the module spec for detailed semantics.
local result = lurek.math.max()
print("max:", result)
return result

--@api-stub: lurek.math.clamp
-- Returns x clamped to [lo, hi].
-- See the module spec for detailed semantics.
player.hp = lurek.math.clamp(player.hp, 0, 100)
volume    = lurek.math.clamp(volume, 0.0, 1.0)
print(player.hp, volume)

--@api-stub: lurek.math.sign
-- Returns -1, 0, or 1 depending on the sign of x.
-- See the module spec for detailed semantics.
local result = lurek.math.sign(100)
print("sign:", result)
return result

--@api-stub: lurek.math.fmod
-- Returns the remainder of x / y (fmod).
-- See the module spec for detailed semantics.
local result = lurek.math.fmod(100, 100)
print("fmod:", result)
return result

--@api-stub: lurek.math.lerp
-- Linear interpolation between a and b by fraction t.
-- See the module spec for detailed semantics.
local x = lurek.math.lerp(0, 100, 0.5)
local y = lurek.math.lerp(player.y, target.y, 0.1)
print(x, y)

--@api-stub: lurek.math.distance
-- Returns the Euclidean distance between (x1,y1) and (x2,y2).
-- See the module spec for detailed semantics.
local d = lurek.math.distance(p1.x, p1.y, p2.x, p2.y)
if d < 32 then print("collision!") end
return d

--@api-stub: lurek.math.distanceSq
-- Returns the squared Euclidean distance between (x1,y1) and (x2,y2) (avoids sqrt).
-- See the module spec for detailed semantics.
local result = lurek.math.distanceSq(x1, y1, x2, y2)
print("distanceSq:", result)
return result

--@api-stub: lurek.math.random
-- Returns a pseudo-random number in [0,1) with no args,.
-- See the module spec for detailed semantics.
local roll = lurek.math.random(1, 6)
local pct  = lurek.math.random()
print("d6:", roll, "pct:", pct)

--@api-stub: lurek.math.randomInt
-- Returns a pseudo-random integer in [lo, hi] (inclusive).
-- See the module spec for detailed semantics.
local result = lurek.math.randomInt(lo, hi)
print("randomInt:", result)
return result

--@api-stub: lurek.math.simplexNoise
-- Returns a simplex noise value in [-1, 1] for 2D or 3D coordinates.
-- See the module spec for detailed semantics.
local result = lurek.math.simplexNoise(100, 100, 0)
print("simplexNoise:", result)
return result

--@api-stub: lurek.math.vec2
-- Creates a 2D vector with x and y components.
-- See the module spec for detailed semantics.
local result = lurek.math.vec2(100, 100)
print("vec2:", result)
return result

--@api-stub: lurek.math.Vec2
-- Compatibility alias for `vec2`.
-- See the module spec for detailed semantics.
local result = lurek.math.Vec2(100, 100)
print("Vec2:", result)
return result

--@api-stub: lurek.math.vec3
-- Creates a 3D vector `{x, y, z}` table with numeric components.
-- See the module spec for detailed semantics.
local result = lurek.math.vec3(100, 100, 0)
print("vec3:", result)
return result

--@api-stub: lurek.math.Vec3
-- Compatibility alias for `vec3`.
-- See the module spec for detailed semantics.
local result = lurek.math.Vec3(100, 100, 0)
print("Vec3:", result)
return result

--@api-stub: lurek.math.catmullRom
-- Creates a Catmull-Rom spline through the given control points.
-- See the module spec for detailed semantics.
local result = lurek.math.catmullRom(points)
print("catmullRom:", result)
return result

--@api-stub: lurek.math.hermite
-- Creates a Hermite spline defined by two endpoints and tangents.
-- See the module spec for detailed semantics.
local result = lurek.math.hermite(p0x, p0y, p1x, p1y, m0x, m0y, m1x, m1y)
print("hermite:", result)
return result

--@api-stub: lurek.math.lerp
-- Linear interpolation between two numbers: a + (b - a) * t.
-- See the module spec for detailed semantics.
local x = lurek.math.lerp(0, 100, 0.5)
local y = lurek.math.lerp(player.y, target.y, 0.1)
print(x, y)

--@api-stub: lurek.math.remap
-- Remaps `v` from [in_min, in_max] to [out_min, out_max].
-- See the module spec for detailed semantics.
local result = lurek.math.remap(v, in_min, in_max, out_min, out_max)
print("remap:", result)
return result

--@api-stub: lurek.math.clamp
-- Clamps `v` between `min` and `max`.
-- See the module spec for detailed semantics.
player.hp = lurek.math.clamp(player.hp, 0, 100)
volume    = lurek.math.clamp(volume, 0.0, 1.0)
print(player.hp, volume)

--@api-stub: lurek.math.sign
-- Returns -1, 0, or 1 depending on the sign of `v`.
-- See the module spec for detailed semantics.
local result = lurek.math.sign(v)
print("sign:", result)
return result

--@api-stub: lurek.math.smoothstep
-- Hermite smoothstep between `edge0` and `edge1`.
-- See the module spec for detailed semantics.
local result = lurek.math.smoothstep(edge0, edge1, 100)
print("smoothstep:", result)
return result

--@api-stub: lurek.math.inverseLerp
-- Returns the interpolation parameter t for `v` in [a, b].
-- See the module spec for detailed semantics.
local result = lurek.math.inverseLerp(1, 0, v)
print("inverseLerp:", result)
return result

--@api-stub: lurek.math.hslToRgb
-- Converts HSL (h: 0-360, s: 0-1, l: 0-1) to RGBA (r, g, b, a) floats.
-- See the module spec for detailed semantics.
local result = lurek.math.hslToRgb(64, s, l)
print("hslToRgb:", result)
return result

--@api-stub: lurek.math.fromHex
-- Parses a hex color string (#RRGGBB or #RRGGBBAA) into (r, g, b, a) floats.
-- Build once at startup; reuse across frames.
local fromhex = lurek.math.fromHex(hex)
print("created", fromhex)
return fromhex

--@api-stub: lurek.math.rgbToHsl
-- Converts RGBA floats to HSL (h: 0-360, s: 0-1, l: 0-1).
-- See the module spec for detailed semantics.
local result = lurek.math.rgbToHsl(1, 0.5, 0)
print("rgbToHsl:", result)
return result

--@api-stub: lurek.math.rectUnion
-- Returns the union (bounding box) of two rectangles.
-- See the module spec for detailed semantics.
local result = lurek.math.rectUnion(x1, y1, w1, h1, x2, y2, w2, h2)
print("rectUnion:", result)
return result

--@api-stub: lurek.math.rectFromCenter
-- Creates a rectangle centered at (cx, cy) with the given width and height.
-- See the module spec for detailed semantics.
local result = lurek.math.rectFromCenter(cx, cy, 64, 64)
print("rectFromCenter:", result)
return result

--@api-stub: lurek.math.polygonClip
-- Clips a polygon against a single half-plane using the Sutherland-Hodgman algorithm.
-- See the module spec for detailed semantics.
local result = lurek.math.polygonClip(pts, nx, ny, d)
print("polygonClip:", result)
return result

--@api-stub: lurek.math.aabbTree
-- Creates a new empty AABB tree for efficient broad-phase overlap queries.
-- See the module spec for detailed semantics.
local result = lurek.math.aabbTree()
print("aabbTree:", result)
return result

--@api-stub: lurek.math.newCircle
-- Creates a new Circle value type with the given centre and radius.
-- Build once at startup; reuse across frames.
local circle = lurek.math.newCircle(100, 100, radius)
print("created", circle)
return circle

--@api-stub: lurek.math.polygonIntersection
-- Computes the intersection of two convex polygons using the Sutherland-Hodgman.
-- See the module spec for detailed semantics.
local result = lurek.math.polygonIntersection(1, 0)
print("polygonIntersection:", result)
return result

--@api-stub: lurek.math.polygonUnion
-- Computes the approximate union of two convex polygons as the convex hull of.
-- See the module spec for detailed semantics.
local result = lurek.math.polygonUnion(1, 0)
print("polygonUnion:", result)
return result

--@api-stub: lurek.math.polygonDifference
-- Computes the approximate difference `A - B` (the part of A not covered by B).
-- See the module spec for detailed semantics.
local result = lurek.math.polygonDifference(1, 0)
print("polygonDifference:", result)
return result

--@api-stub: lurek.math.voronoi
-- Computes the Voronoi diagram for a list of 2-D seed points.
-- See the module spec for detailed semantics.
local result = lurek.math.voronoi(points)
print("voronoi:", result)
return result

-- ── Vec2 methods ──

--@api-stub: Vec2:dot
-- Returns the dot product with another vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:dot(other)
print("Vec2:dot done")

--@api-stub: Vec2:length
-- Returns the Euclidean length of the vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:length()
print("Vec2:length done")

--@api-stub: Vec2:x
-- Returns the horizontal component of the vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:x()
print("Vec2:x done")

--@api-stub: Vec2:y
-- Returns the vertical component of the vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:y()
print("Vec2:y done")

--@api-stub: Vec2:lengthSquared
-- Returns the squared length of the vector (faster than length).
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:lengthSquared()
print("Vec2:lengthSquared done")

--@api-stub: Vec2:normalize
-- Returns a unit-length copy of this vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:normalize()
print("Vec2:normalize done")

--@api-stub: Vec2:normalized
-- Compatibility alias for `normalize`.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:normalized()
print("Vec2:normalized done")

--@api-stub: Vec2:lerp
-- Returns a linearly interpolated vector between this and other at parameter t.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:lerp(other, t)
print("Vec2:lerp done")

--@api-stub: Vec2:distance
-- Returns the Euclidean distance from this vector to another.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:distance(other)
print("Vec2:distance done")

--@api-stub: Vec2:angle
-- Returns the angle of this vector in radians (atan2(y, x)).
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:angle()
print("Vec2:angle done")

--@api-stub: Vec2:rotate
-- Returns a new vector rotated by the given angle in radians.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:rotate(0)
print("Vec2:rotate done")

--@api-stub: Vec2:perpendicular
-- Returns the perpendicular vector (-y, x).
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:perpendicular()
print("Vec2:perpendicular done")

--@api-stub: Vec2:cross
-- Returns the 2D cross product (scalar) with another vector.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:cross(other)
print("Vec2:cross done")

--@api-stub: Vec2:reflect
-- Reflects this vector off a surface with the given normal.
-- See the module spec for detailed semantics.
local vec2 = lurek.math.newVec2()
vec2:reflect(normal)
print("Vec2:reflect done")

-- ── Vec3 methods ──

--@api-stub: Vec3:length
-- Returns the Euclidean length of the vector.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:length()
print("Vec3:length done")

--@api-stub: Vec3:lengthSquared
-- Returns the squared Euclidean length (avoids sqrt).
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:lengthSquared()
print("Vec3:lengthSquared done")

--@api-stub: Vec3:normalize
-- Returns a unit-length version of this vector.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:normalize()
print("Vec3:normalize done")

--@api-stub: Vec3:dot
-- Dot product with another Vec3.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:dot(other)
print("Vec3:dot done")

--@api-stub: Vec3:cross
-- Cross product with another Vec3.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:cross(other)
print("Vec3:cross done")

--@api-stub: Vec3:lerp
-- Linear interpolation towards another Vec3.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:lerp(other, t)
print("Vec3:lerp done")

--@api-stub: Vec3:distance
-- Euclidean distance to another Vec3.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:distance(other)
print("Vec3:distance done")

--@api-stub: Vec3:add
-- Add another Vec3 and return the result.
-- Side-effecting; safe to call any time after init.
local vec3 = lurek.math.newVec3()
vec3:add(other)
print("Vec3:add done")

--@api-stub: Vec3:sub
-- Subtract another Vec3 and return the result.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:sub(other)
print("Vec3:sub done")

--@api-stub: Vec3:scale
-- Scale this vector by a scalar and return the result.
-- See the module spec for detailed semantics.
local vec3 = lurek.math.newVec3()
vec3:scale(s)
print("Vec3:scale done")

-- ── CatmullRom methods ──

--@api-stub: CatmullRom:sample
-- Sample the spline at global t in [0, 1].
-- See the module spec for detailed semantics.
local catmullRom = lurek.math.newCatmullRom()
catmullRom:sample(t)
print("CatmullRom:sample done")

--@api-stub: CatmullRom:sampleSegment
-- Sample a specific segment at local t in [0, 1].
-- See the module spec for detailed semantics.
local catmullRom = lurek.math.newCatmullRom()
catmullRom:sampleSegment(seg, t)
print("CatmullRom:sampleSegment done")

--@api-stub: CatmullRom:len
-- Number of control points.
-- See the module spec for detailed semantics.
local catmullRom = lurek.math.newCatmullRom()
catmullRom:len()
print("CatmullRom:len done")

--@api-stub: CatmullRom:addPoint
-- Appends a control point to the spline.
-- Side-effecting; safe to call any time after init.
local catmullRom = lurek.math.newCatmullRom()
catmullRom:addPoint(100, 100)
print("CatmullRom:addPoint done")

--@api-stub: CatmullRom:removePoint
-- Removes the control point at `index` (0-based) and returns it.
-- Pair with the matching constructor to free resources.
local catmullRom = lurek.math.newCatmullRom()
catmullRom:removePoint(1)
-- catmullRom is now released
print("ok")

-- ── Hermite methods ──

--@api-stub: Hermite:sample
-- Evaluate the spline at parameter t in [0, 1].
-- See the module spec for detailed semantics.
local hermite = lurek.math.newHermite()
hermite:sample(t)
print("Hermite:sample done")

-- ── RandomGenerator methods ──

--@api-stub: RandomGenerator:random
-- Returns a uniform random number in [0, 1).
-- See the module spec for detailed semantics.
local randomGenerator = lurek.math.newRandomGenerator()
randomGenerator:random()
print("RandomGenerator:random done")

--@api-stub: RandomGenerator:randomFloat
-- Returns a uniform random float in [min, max).
-- See the module spec for detailed semantics.
local randomGenerator = lurek.math.newRandomGenerator()
randomGenerator:randomFloat(0, 100)
print("RandomGenerator:randomFloat done")

--@api-stub: RandomGenerator:randomInt
-- Returns a uniform random integer in [min, max].
-- See the module spec for detailed semantics.
local randomGenerator = lurek.math.newRandomGenerator()
randomGenerator:randomInt(0, 100)
print("RandomGenerator:randomInt done")

--@api-stub: RandomGenerator:getSeed
-- Returns the seed used to initialise this generator.
-- Cheap to call; safe inside callbacks.
local randomGenerator = lurek.math.newRandomGenerator()  -- or your existing handle
local value = randomGenerator:getSeed()
print("RandomGenerator:getSeed ->", value)

--@api-stub: RandomGenerator:setSeed
-- Sets the seed, fully resetting the generator state.
-- Apply at startup or in response to user input.
local randomGenerator = lurek.math.newRandomGenerator()
randomGenerator:setSeed(seed)
print("RandomGenerator:setSeed applied")

--@api-stub: RandomGenerator:getState
-- Serialises the generator state as a string for later restoration.
-- Cheap to call; safe inside callbacks.
local randomGenerator = lurek.math.newRandomGenerator()  -- or your existing handle
local value = randomGenerator:getState()
print("RandomGenerator:getState ->", value)

--@api-stub: RandomGenerator:setState
-- Restores the generator state from a previously serialised string.
-- Apply at startup or in response to user input.
local randomGenerator = lurek.math.newRandomGenerator()
randomGenerator:setState(state)
print("RandomGenerator:setState applied")

-- ── Transform methods ──

--@api-stub: Transform:translate
-- Applies translation to the transform.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:translate(100, 100)
print("Transform:translate done")

--@api-stub: Transform:rotate
-- Applies a rotation in radians.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:rotate(0)
print("Transform:rotate done")

--@api-stub: Transform:scale
-- Applies non-uniform scaling.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:scale(sx, sy)
print("Transform:scale done")

--@api-stub: Transform:shear
-- Applies horizontal and vertical shear factors to this transform matrix.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:shear(kx, ky)
print("Transform:shear done")

--@api-stub: Transform:reset
-- Resets the transform to identity.
-- Pair with the matching constructor to free resources.
local transform = lurek.math.newTransform()
transform:reset()
-- transform is now released
print("ok")

--@api-stub: Transform:transformPoint
-- Transforms a point from local space to world space.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:transformPoint(100, 100)
print("Transform:transformPoint done")

--@api-stub: Transform:inverseTransformPoint
-- Transforms a point from world space back to local space.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:inverseTransformPoint(100, 100)
print("Transform:inverseTransformPoint done")

--@api-stub: Transform:inverse
-- Returns a new Transform that undoes this transform.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:inverse()
print("Transform:inverse done")

--@api-stub: Transform:clone
-- Returns a copy of this transform.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:clone()
print("Transform:clone done")

--@api-stub: Transform:getMatrix
-- Returns the 3x3 matrix as a flat table of 9 numbers (row-major).
-- Cheap to call; safe inside callbacks.
local transform = lurek.math.newTransform()  -- or your existing handle
local value = transform:getMatrix()
print("Transform:getMatrix ->", value)

--@api-stub: Transform:decompose
-- Decomposes this transform into translation, rotation, and scale.
-- See the module spec for detailed semantics.
local transform = lurek.math.newTransform()
transform:decompose()
print("Transform:decompose done")

-- ── BezierCurve methods ──

--@api-stub: BezierCurve:evaluate
-- Evaluates the curve at parameter t, returning (x, y).
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:evaluate(t)
print("BezierCurve:evaluate done")

--@api-stub: BezierCurve:render
-- Renders the curve as a polyline with the given number of segments.
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:render(segments)
print("BezierCurve:render done")

--@api-stub: BezierCurve:getDerivative
-- Returns a new BezierCurve representing the first derivative.
-- Cheap to call; safe inside callbacks.
local bezierCurve = lurek.math.newBezierCurve()  -- or your existing handle
local value = bezierCurve:getDerivative()
print("BezierCurve:getDerivative ->", value)

--@api-stub: BezierCurve:getControlPoint
-- Returns the control point at 1-based index as (x, y), or nil.
-- Cheap to call; safe inside callbacks.
local bezierCurve = lurek.math.newBezierCurve()  -- or your existing handle
local value = bezierCurve:getControlPoint(1)
print("BezierCurve:getControlPoint ->", value)

--@api-stub: BezierCurve:removeControlPoint
-- Removes a control point at 1-based index.
-- Pair with the matching constructor to free resources.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:removeControlPoint(1)
-- bezierCurve is now released
print("ok")

--@api-stub: BezierCurve:getControlPointCount
-- Returns the number of control points.
-- Cheap to call; safe inside callbacks.
local bezierCurve = lurek.math.newBezierCurve()  -- or your existing handle
local value = bezierCurve:getControlPointCount()
print("BezierCurve:getControlPointCount ->", value)

--@api-stub: BezierCurve:length
-- Returns the approximate arc length of the curve.
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:length()
print("BezierCurve:length done")

--@api-stub: BezierCurve:translate
-- Translates all control points by (dx, dy).
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:translate(100, 100)
print("BezierCurve:translate done")

--@api-stub: BezierCurve:rotate
-- Rotates all control points around a pivot by angle radians.
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:rotate(0, ox, oy)
print("BezierCurve:rotate done")

--@api-stub: BezierCurve:scale
-- Scales all control points around a pivot by factor s.
-- See the module spec for detailed semantics.
local bezierCurve = lurek.math.newBezierCurve()
bezierCurve:scale(s, ox, oy)
print("BezierCurve:scale done")

-- ── Tween methods ──

--@api-stub: Tween:update
-- Advances the clock by dt seconds.
-- Apply at startup or in response to user input.
local tween = lurek.math.newTween()
tween:update(dt)
print("Tween:update applied")

--@api-stub: Tween:reset
-- Resets the tween elapsed time to zero, restarting the animation.
-- Pair with the matching constructor to free resources.
local tween = lurek.math.newTween()
tween:reset()
-- tween is now released
print("ok")

--@api-stub: Tween:getValue
-- Returns the interpolated value at 1-based index, or all values as a.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getValue(1)
print("Tween:getValue ->", value)

--@api-stub: Tween:getAllValues
-- Returns all interpolated values as a table.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getAllValues()
print("Tween:getAllValues ->", value)

--@api-stub: Tween:isComplete
-- Returns true if the tween has finished.
-- Use as a guard inside lurek.update or event handlers.
local tween = lurek.math.newTween()
if tween:isComplete() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Tween:getValueCount
-- Returns the number of values in this tween.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getValueCount()
print("Tween:getValueCount ->", value)

--@api-stub: Tween:getEasingName
-- Returns the easing function name.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getEasingName()
print("Tween:getEasingName ->", value)

--@api-stub: Tween:getDuration
-- Returns the tween duration in seconds.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getDuration()
print("Tween:getDuration ->", value)

--@api-stub: Tween:getTime
-- Returns the current clock time.
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getTime()
print("Tween:getTime ->", value)

--@api-stub: Tween:getClock
-- Alias for getTime().
-- Cheap to call; safe inside callbacks.
local tween = lurek.math.newTween()  -- or your existing handle
local value = tween:getClock()
print("Tween:getClock ->", value)

--@api-stub: Tween:setTime
-- Sets the clock to a specific time, clamped to [0, duration].
-- Apply at startup or in response to user input.
local tween = lurek.math.newTween()
tween:setTime(t)
print("Tween:setTime applied")

--@api-stub: Tween:set
-- Alias for setTime().
-- Apply at startup or in response to user input.
local tween = lurek.math.newTween()
tween:set(t)
print("Tween:set applied")

--@api-stub: Tween:addValue
-- Adds a start/target value pair.
-- Side-effecting; safe to call any time after init.
local tween = lurek.math.newTween()
tween:addValue(start, target)
print("Tween:addValue done")

-- ── SpatialHash methods ──

--@api-stub: SpatialHash:remove
-- Removes an item by its ID.
-- Pair with the matching constructor to free resources.
local spatialHash = lurek.math.newSpatialHash()
spatialHash:remove(1)
-- spatialHash is now released
print("ok")

--@api-stub: SpatialHash:clear
-- Removes all registered items from this spatial hash, leaving it empty.
-- Pair with the matching constructor to free resources.
local spatialHash = lurek.math.newSpatialHash()
spatialHash:clear()
-- spatialHash is now released
print("ok")

--@api-stub: SpatialHash:getCellSize
-- Returns the cell size used to partition the spatial hash grid.
-- Cheap to call; safe inside callbacks.
local spatialHash = lurek.math.newSpatialHash()  -- or your existing handle
local value = spatialHash:getCellSize()
print("SpatialHash:getCellSize ->", value)

--@api-stub: SpatialHash:getItemCount
-- Returns the number of items in the hash.
-- Cheap to call; safe inside callbacks.
local spatialHash = lurek.math.newSpatialHash()  -- or your existing handle
local value = spatialHash:getItemCount()
print("SpatialHash:getItemCount ->", value)

-- ── NoiseGenerator methods ──

--@api-stub: NoiseGenerator:perlin1d
-- Returns 1D Perlin noise at x.
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:perlin1d(100)
print("NoiseGenerator:perlin1d done")

--@api-stub: NoiseGenerator:perlin2d
-- Returns 2D Perlin noise at (x, y).
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:perlin2d(100, 100)
print("NoiseGenerator:perlin2d done")

--@api-stub: NoiseGenerator:perlin3d
-- Returns 3D Perlin noise at (x, y, z).
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:perlin3d(100, 100, 0)
print("NoiseGenerator:perlin3d done")

--@api-stub: NoiseGenerator:perlin4d
-- Returns 4D Perlin noise at (x, y, z, w).
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:perlin4d(100, 100, 0, 64)
print("NoiseGenerator:perlin4d done")

--@api-stub: NoiseGenerator:simplex1d
-- Returns 1D Simplex noise at x.
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:simplex1d(100)
print("NoiseGenerator:simplex1d done")

--@api-stub: NoiseGenerator:simplex2d
-- Returns 2D Simplex noise at (x, y).
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:simplex2d(100, 100)
print("NoiseGenerator:simplex2d done")

--@api-stub: NoiseGenerator:simplex3d
-- Returns 3D Simplex noise at (x, y, z).
-- See the module spec for detailed semantics.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:simplex3d(100, 100, 0)
print("NoiseGenerator:simplex3d done")

--@api-stub: NoiseGenerator:getSeed
-- Returns the current seed.
-- Cheap to call; safe inside callbacks.
local noiseGenerator = lurek.math.newNoiseGenerator()  -- or your existing handle
local value = noiseGenerator:getSeed()
print("NoiseGenerator:getSeed ->", value)

--@api-stub: NoiseGenerator:setSeed
-- Sets the seed and rebuilds the permutation table.
-- Apply at startup or in response to user input.
local noiseGenerator = lurek.math.newNoiseGenerator()
noiseGenerator:setSeed(seed)
print("NoiseGenerator:setSeed applied")

-- ── Circle methods ──

--@api-stub: Circle:area
-- Returns the area of the circle (π r²).
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:area()
print("Circle:area done")

--@api-stub: Circle:perimeter
-- Returns the circumference of the circle (2 π r).
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:perimeter()
print("Circle:perimeter done")

--@api-stub: Circle:contains
-- Returns true if the point (px, py) lies inside or on the boundary.
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:contains(px, py)
print("Circle:contains done")

--@api-stub: Circle:intersects
-- Returns true if this circle overlaps another circle.
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:intersects(other)
print("Circle:intersects done")

--@api-stub: Circle:aabb
-- Returns the axis-aligned bounding box as (min_x, min_y, max_x, max_y).
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:aabb()
print("Circle:aabb done")

--@api-stub: Circle:x
-- Returns the circle centre X.
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:x()
print("Circle:x done")

--@api-stub: Circle:y
-- Returns the circle centre Y.
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:y()
print("Circle:y done")

--@api-stub: Circle:radius
-- Returns the circle radius.
-- See the module spec for detailed semantics.
local circle = lurek.math.newCircle()
circle:radius()
print("Circle:radius done")

-- ── AabbTree methods ──

--@api-stub: AabbTree:remove
-- Removes the entry with the given id.
-- Pair with the matching constructor to free resources.
local aabbTree = lurek.math.newAabbTree()
aabbTree:remove(1)
-- aabbTree is now released
print("ok")

--@api-stub: AabbTree:queryPoint
-- Returns the ids of all entries whose AABBs contain the given point.
-- Cheap to call; safe inside callbacks.
local aabbTree = lurek.math.newAabbTree()  -- or your existing handle
local value = aabbTree:queryPoint(100, 100)
print("AabbTree:queryPoint ->", value)

--@api-stub: AabbTree:contains
-- Returns true if an entry with the given id exists in the tree.
-- See the module spec for detailed semantics.
local aabbTree = lurek.math.newAabbTree()
aabbTree:contains(1)
print("AabbTree:contains done")

--@api-stub: AabbTree:len
-- Returns the number of entries in the tree.
-- See the module spec for detailed semantics.
local aabbTree = lurek.math.newAabbTree()
aabbTree:len()
print("AabbTree:len done")

--@api-stub: AabbTree:isEmpty
-- Returns true if the tree contains no entries.
-- Use as a guard inside lurek.update or event handlers.
local aabbTree = lurek.math.newAabbTree()
if aabbTree:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: AabbTree:clear
-- Removes all entries from the tree.
-- Pair with the matching constructor to free resources.
local aabbTree = lurek.math.newAabbTree()
aabbTree:clear()
-- aabbTree is now released
print("ok")

