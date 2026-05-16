-- content/examples/math.lua
-- lurek.math API examples.
-- Run: cargo run -- content/examples/math.lua

--@api-stub: lurek.math.newRandomGenerator -- Creates a deterministic random generator with an optional seed
do -- lurek.math.newRandomGenerator
  local rng = lurek.math.newRandomGenerator(1337)
  local loot_roll = rng:randomInt(1, 100)
  lurek.log.info("loot roll=" .. loot_roll, "rng")
end

--@api-stub: lurek.math.newTransform -- Creates a 2D transform
do -- lurek.math.newTransform
  local t = lurek.math.newTransform(100, 50, math.pi / 4, 2, 2)
  local wx, wy = t:transformPoint(8, 0)
  lurek.log.debug("rotated corner at " .. wx .. "," .. wy, "xform")
end

--@api-stub: lurek.math.newBezierCurve -- Creates a Bezier curve from a flat point table
do -- lurek.math.newBezierCurve
  local curve = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local mid_x, mid_y = curve:evaluate(0.5)
  local d_x, d_y = curve:evaluateAtDistance(120)
  lurek.log.info("bezier midpoint " .. mid_x .. "," .. mid_y, "anim")
  lurek.log.debug("bezier distance sample " .. d_x .. "," .. d_y, "anim")
end

--@api-stub: lurek.math.newTween -- Creates a tween with a duration and optional easing name
do -- lurek.math.newTween
  local tw = lurek.math.newTween(0.5, "outQuad")
  tw:addValue(0, 200)
  function lurek.process(dt) tw:update(dt) end
end

--@api-stub: lurek.math.newSpatialHash -- Creates a spatial hash index with a cell size
do -- lurek.math.newSpatialHash
  local hash = lurek.math.newSpatialHash(64)
  hash:insert("player", 100, 100, 32, 32)
  local hits = hash:queryCircle(110, 110, 50)
end

--@api-stub: lurek.math.newNoiseGenerator -- Creates a procedural noise generator with an optional seed
do -- lurek.math.newNoiseGenerator
  local terrain = lurek.math.newNoiseGenerator(20260422)
  local h = terrain:perlin2d(3.5, 7.25)
  local map = terrain:generateMapCompute(16, 16, {octaves = 3})
  lurek.log.debug("terrain h=" .. h, "noise")
  lurek.log.debug("terrain map samples=" .. #map, "noise")
end

--@api-stub: lurek.math.newRectPacker -- Creates a rectangle packer
do -- lurek.math.newRectPacker
  local packer = lurek.math.newRectPacker(256, 256, 2)
  local x, y = packer:pack(64, 64, "hero")
  lurek.log.info("packed hero at " .. tostring(x) .. "," .. tostring(y), "atlas")
end

--@api-stub: RectPacker:pack
do -- RectPacker:pack
  local packer = lurek.math.newRectPacker(128, 128, 2)
  local x, y = packer:pack(32, 24, "btn_ok")
  if x and y then
    lurek.log.debug("packed btn_ok at " .. x .. "," .. y, "atlas")
  end
end

--@api-stub: RectPacker:getPacked
do -- RectPacker:getPacked
  local packer = lurek.math.newRectPacker(128, 128, 2)
  packer:pack(20, 20, "icon_a")
  packer:pack(30, 18, "icon_b")
  local packed = packer:getPacked()
  lurek.log.debug("packed count=" .. #packed, "atlas")
end

--@api-stub: RectPacker:occupancy
do -- RectPacker:occupancy
  local packer = lurek.math.newRectPacker(128, 128, 2)
  packer:pack(32, 32, "slot1")
  local occ = packer:occupancy()
  lurek.log.debug("occupancy=" .. occ, "atlas")
end

--@api-stub: RectPacker:clear
do -- RectPacker:clear
  local packer = lurek.math.newRectPacker(128, 128, 2)
  packer:pack(40, 16, "tmp")
  packer:clear()
  lurek.log.debug("atlas cleared", "atlas")
end

--@api-stub: lurek.math.perlin2d -- Samples stateless 2D Perlin noise
do -- lurek.math.perlin2d
  local n = lurek.math.perlin2d(0.5, 1.25, 42)
  if n > 0.6 then
    lurek.log.info("hill peak", "terrain")
  end
end

--@api-stub: lurek.math.perlin3d -- Samples stateless 3D Perlin noise
do -- lurek.math.perlin3d
  local t = 0
  function lurek.process(dt)
    t = t + dt
    local cloud = lurek.math.perlin3d(0.1, 0.2, t, 7)
    lurek.log.debug("cloud=" .. cloud, "sky")
  end
end

--@api-stub: lurek.math.simplex2d -- Samples stateless 2D simplex noise
do -- lurek.math.simplex2d
  local s = lurek.math.simplex2d(2.0, 3.0, 99)
  if s > 0 then
    lurek.log.debug("simplex above zero", "noise")
  end
end

--@api-stub: lurek.math.fbm -- Samples stateless fractal Brownian motion noise
do -- lurek.math.fbm
  local h = lurek.math.fbm(4.5, 2.0, 12345, 6, 2.0, 0.5)
  local altitude = math.floor(h * 1000)
  lurek.log.info("fbm altitude=" .. altitude, "world")
end

--@api-stub: lurek.math.applyEasing -- Applies a named easing function to a normalized value
do -- lurek.math.applyEasing
  local name = "outBounce"
  local eased = lurek.math.applyEasing(name, 0.75)
  lurek.log.debug(name .. "(0.75)=" .. eased, "tween")
end

--@api-stub: lurek.math.linear -- Applies linear easing
do -- lurek.math.linear
  local t = 0.42
  local v = lurek.math.linear(t)
  lurek.log.debug("linear " .. t .. "=" .. v, "easing")
end

--@api-stub: lurek.math.inQuad -- Applies quadratic ease-in
do -- lurek.math.inQuad
  local progress = 0.3
  local y = lurek.math.inQuad(progress) * 200
  lurek.log.debug("falling y=" .. y, "anim")
end

--@api-stub: lurek.math.outQuad -- Applies quadratic ease-out
do -- lurek.math.outQuad
  local x = lurek.math.outQuad(0.6) * 480
  lurek.log.debug("panel x=" .. x, "ui")
end

--@api-stub: lurek.math.inOutQuad -- Applies quadratic ease-in-out
do -- lurek.math.inOutQuad
  local t = 0.5
  local cam_x = 100 + lurek.math.inOutQuad(t) * 400
  lurek.log.debug("cam x=" .. cam_x, "cam")
end

--@api-stub: lurek.math.inCubic -- Applies cubic ease-in
do -- lurek.math.inCubic
  local charge = lurek.math.inCubic(0.4)
  if charge > 0.5 then
    lurek.log.info("charge ready", "combat")
  end
end

--@api-stub: lurek.math.outCubic -- Applies cubic ease-out
do -- lurek.math.outCubic
  local opacity = lurek.math.outCubic(0.8)
  lurek.log.debug("tooltip alpha=" .. opacity, "ui")
end

--@api-stub: lurek.math.inOutCubic -- Applies cubic ease-in-out
do -- lurek.math.inOutCubic
  local t = lurek.math.inOutCubic(0.25)
  local panel_y = 600 - t * 400
  lurek.log.debug("panel y=" .. panel_y, "ui")
end

--@api-stub: lurek.math.inQuart -- Applies quartic ease-in
do -- lurek.math.inQuart
  local v = lurek.math.inQuart(0.7)
  lurek.log.debug("inQuart=" .. v, "easing")
end

--@api-stub: lurek.math.outQuart -- Applies quartic ease-out
do -- lurek.math.outQuart
  local v = lurek.math.outQuart(0.2)
  lurek.log.debug("outQuart=" .. v, "easing")
end

--@api-stub: lurek.math.inOutQuart -- Applies quartic ease-in-out
do -- lurek.math.inOutQuart
  local v = lurek.math.inOutQuart(0.5)
  lurek.log.debug("inOutQuart=" .. v, "easing")
end

--@api-stub: lurek.math.inSine -- Applies sine ease-in
do -- lurek.math.inSine
  local pulse = lurek.math.inSine(0.4)
  lurek.log.debug("pulse=" .. pulse, "fx")
end

--@api-stub: lurek.math.outSine -- Applies sine ease-out
do -- lurek.math.outSine
  local v = lurek.math.outSine(0.6)
  lurek.log.debug("icon alpha=" .. v, "ui")
end

--@api-stub: lurek.math.inOutSine -- Applies sine ease-in-out
do -- lurek.math.inOutSine
  local v = lurek.math.inOutSine(0.5)
  lurek.log.debug("drift=" .. v, "bg")
end

--@api-stub: lurek.math.inExpo -- Applies exponential ease-in
do -- lurek.math.inExpo
  local v = lurek.math.inExpo(0.85)
  lurek.log.debug("inExpo=" .. v, "fx")
end

--@api-stub: lurek.math.outExpo -- Applies exponential ease-out
do -- lurek.math.outExpo
  local v = lurek.math.outExpo(0.15)
  lurek.log.debug("outExpo=" .. v, "fx")
end

--@api-stub: lurek.math.inOutExpo -- Applies exponential ease-in-out
do -- lurek.math.inOutExpo
  local v = lurek.math.inOutExpo(0.5)
  lurek.log.debug("inOutExpo=" .. v, "fx")
end

--@api-stub: lurek.math.inElastic -- Applies elastic ease-in
do -- lurek.math.inElastic
  local v = lurek.math.inElastic(0.8)
  lurek.log.debug("inElastic=" .. v, "anim")
end

--@api-stub: lurek.math.outElastic -- Applies elastic ease-out
do -- lurek.math.outElastic
  local v = lurek.math.outElastic(0.6)
  lurek.log.debug("button bounce=" .. v, "ui")
end

--@api-stub: lurek.math.outBounce -- Applies bounce ease-out
do -- lurek.math.outBounce
  local h = lurek.math.outBounce(0.3) * 100
  lurek.log.debug("bounce h=" .. h, "fx")
end

--@api-stub: lurek.math.inBounce -- Applies bounce ease-in
do -- lurek.math.inBounce
  local v = lurek.math.inBounce(0.7)
  lurek.log.debug("inBounce=" .. v, "fx")
end

--@api-stub: lurek.math.inBack -- Applies back ease-in
do -- lurek.math.inBack
  local v = lurek.math.inBack(0.5)
  lurek.log.debug("inBack=" .. v, "ui")
end

--@api-stub: lurek.math.outBack -- Applies back ease-out
do -- lurek.math.outBack
  local v = lurek.math.outBack(0.5)
  lurek.log.debug("outBack=" .. v, "ui")
end

--@api-stub: lurek.math.inOutElastic -- Applies elastic ease-in-out
do -- lurek.math.inOutElastic
  local v = lurek.math.inOutElastic(0.4)
  lurek.log.debug("inOutElastic=" .. v, "fx")
end

--@api-stub: lurek.math.inOutBounce -- Applies bounce ease-in-out
do -- lurek.math.inOutBounce
  local v = lurek.math.inOutBounce(0.5)
  lurek.log.debug("inOutBounce=" .. v, "fx")
end

--@api-stub: lurek.math.inOutBack -- Applies back ease-in-out
do -- lurek.math.inOutBack
  local v = lurek.math.inOutBack(0.5)
  lurek.log.debug("inOutBack=" .. v, "fx")
end

--@api-stub: lurek.math.triangulate -- Triangulates a flat polygon point table
do -- lurek.math.triangulate
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  local tris = lurek.math.triangulate(poly)
  lurek.log.info("triangulated into " .. #tris .. " triangles", "geo")
end

--@api-stub: lurek.math.isConvex -- Returns whether a flat polygon point table is convex
do -- lurek.math.isConvex
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  if lurek.math.isConvex(poly) then
    lurek.log.debug("polygon is convex", "geo")
  end
end

--@api-stub: lurek.math.gammaToLinear -- Converts a gamma-space channel to linear space
do -- lurek.math.gammaToLinear
  local linear = lurek.math.gammaToLinear(0.5)
  lurek.log.debug("0.5 sRGB -> " .. linear .. " linear", "color")
end

--@api-stub: lurek.math.linearToGamma -- Converts a linear-space channel to gamma space
do -- lurek.math.linearToGamma
  local srgb = lurek.math.linearToGamma(0.214)
  lurek.log.debug("linear 0.214 -> " .. srgb .. " sRGB", "color")
end

--@api-stub: lurek.math.angleBetween -- Returns the angle between two points
do -- lurek.math.angleBetween
  local rad = lurek.math.angleBetween(0, 0, 100, 100)
  lurek.log.debug("angle=" .. lurek.math.deg(rad) .. " deg", "geo")
end

--@api-stub: lurek.math.circleContainsPoint -- Returns whether a circle contains a point
do -- lurek.math.circleContainsPoint
  if lurek.math.circleContainsPoint(0, 0, 50, 30, 20) then
    lurek.log.info("inside aura", "trigger")
  end
end

--@api-stub: lurek.math.circleIntersectsCircle -- Returns whether two circles intersect
do -- lurek.math.circleIntersectsCircle
  if lurek.math.circleIntersectsCircle(0, 0, 10, 8, 6, 5) then
    lurek.log.warn("orbs collided", "physics")
  end
end

--@api-stub: lurek.math.circleIntersectsLine -- Returns circle-line intersection state and hit points when present
do -- lurek.math.circleIntersectsLine
  local hit, ix, iy = lurek.math.circleIntersectsLine(0, 0, 50, -100, 0, 100, 0)
  if hit then
    lurek.log.info("laser hit at " .. ix .. "," .. iy, "fx")
  end
end

--@api-stub: lurek.math.circleIntersectsSegment -- Returns circle-segment intersection state and hit points when present
do -- lurek.math.circleIntersectsSegment
  local hit, ix, iy = lurek.math.circleIntersectsSegment(20, 0, 5, 0, 0, 40, 0)
  if hit then
    lurek.log.info("bullet impact " .. ix .. "," .. iy, "combat")
  end
end

--@api-stub: lurek.math.closestPointOnSegment -- Returns the closest point on a segment to an input point
do -- lurek.math.closestPointOnSegment
  local cx, cy = lurek.math.closestPointOnSegment(50, 30, 0, 0, 100, 0)
  lurek.log.debug("nearest=" .. cx .. "," .. cy, "ai")
end

--@api-stub: lurek.math.convexHull -- Computes the convex hull for a flat point table
do -- lurek.math.convexHull
  local pts = {0, 0, 100, 0, 50, 50, 100, 100, 0, 100}
  local hull = lurek.math.convexHull(pts)
  lurek.log.info("hull verts=" .. (#hull / 2), "geo")
end

--@api-stub: lurek.math.delaunayTriangulate -- Computes Delaunay triangles for a flat point table
do -- lurek.math.delaunayTriangulate
  local pts = {0, 0, 100, 0, 50, 80, 60, 30}
  local tris = lurek.math.delaunayTriangulate(pts)
  lurek.log.info("delaunay tris=" .. #tris, "geo")
end

--@api-stub: lurek.math.lineIntersect -- Returns intersection point for two infinite lines when present
do -- lurek.math.lineIntersect
  local ix, iy = lurek.math.lineIntersect(0, 0, 100, 100, 0, 100, 100, 0)
  if ix then
    lurek.log.debug("cross at " .. ix .. "," .. iy, "geo")
  end
end

--@api-stub: lurek.math.pointInPolygon -- Returns whether a point lies inside a polygon
do -- lurek.math.pointInPolygon
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  if lurek.math.pointInPolygon(poly, 50, 50) then
    lurek.log.info("inside zone", "trigger")
  end
end

--@api-stub: lurek.math.polygonArea -- Computes signed area for a flat polygon point table
do -- lurek.math.polygonArea
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  local area = lurek.math.polygonArea(poly)
  lurek.log.info("polygon area=" .. math.abs(area), "geo")
end

--@api-stub: lurek.math.polygonCentroid -- Computes the centroid for a flat polygon point table
do -- lurek.math.polygonCentroid
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  local cx, cy = lurek.math.polygonCentroid(poly)
  lurek.log.debug("centroid " .. cx .. "," .. cy, "geo")
end

--@api-stub: lurek.math.segmentIntersectsSegment -- Returns whether two segments intersect and their intersection point when present
do -- lurek.math.segmentIntersectsSegment
  local hit, ix, iy = lurek.math.segmentIntersectsSegment(0, 0, 100, 0, 50, -50, 50, 50)
  if hit then
    lurek.log.info("blade crossed " .. ix .. "," .. iy, "combat")
  end
end

--@api-stub: lurek.math.bresenham -- Returns integer grid points along a Bresenham line
do -- lurek.math.bresenham
  local pts = lurek.math.bresenham(0, 0, 5, 3)
  lurek.log.info("bresenham steps=" .. #pts, "tile")
end

--@api-stub: lurek.math.rad -- Converts degrees to radians
do -- lurek.math.rad
  local turn_deg = 90
  local turn_rad = lurek.math.rad(turn_deg)
  lurek.log.debug(turn_deg .. " deg = " .. turn_rad .. " rad", "math")
end

--@api-stub: lurek.math.deg -- Converts radians to degrees
do -- lurek.math.deg
  local heading = lurek.math.deg(math.pi / 2)
  lurek.log.info("heading=" .. heading .. " deg", "compass")
end

--@api-stub: lurek.math.sin -- Returns sine of an angle
do -- lurek.math.sin
  local t = 0
  function lurek.process(dt)
    t = t + dt
    local bob = lurek.math.sin(t * 2) * 8
    lurek.log.debug("bob=" .. bob, "fx")
  end
end

--@api-stub: lurek.math.cos -- Returns cosine of an angle
do -- lurek.math.cos
  local t = 1.5
  local x = lurek.math.cos(t) * 50
  lurek.log.debug("orbit x=" .. x, "fx")
end

--@api-stub: lurek.math.tan -- Returns tangent of an angle
do -- lurek.math.tan
  local slope = lurek.math.tan(math.pi / 6)
  lurek.log.debug("30deg slope=" .. slope, "math")
end

--@api-stub: lurek.math.asin -- Returns arcsine of a value
do -- lurek.math.asin
  local angle = lurek.math.asin(0.5)
  lurek.log.debug("asin(0.5)=" .. lurek.math.deg(angle), "math")
end

--@api-stub: lurek.math.acos -- Returns arccosine of a value
do -- lurek.math.acos
  local angle = lurek.math.acos(0.0)
  lurek.log.debug("acos(0)=" .. lurek.math.deg(angle), "math")
end

--@api-stub: lurek.math.atan -- Returns arctangent or two-argument arctangent
do -- lurek.math.atan
  local a = lurek.math.atan(1.0)
  local b = lurek.math.atan(1.0, -1.0)
  lurek.log.debug("atan results " .. a .. " " .. b, "math")
end

--@api-stub: lurek.math.atan2 -- Returns two-argument arctangent
do -- lurek.math.atan2
  local dx, dy = 100 - 0, 50 - 0
  local heading = lurek.math.atan2(dy, dx)
  lurek.log.info("heading rad=" .. heading, "ai")
end

--@api-stub: lurek.math.sqrt -- Returns square root of a value
do -- lurek.math.sqrt
  local hyp = lurek.math.sqrt(3 * 3 + 4 * 4)
  lurek.log.debug("hyp=" .. hyp, "math")
end

--@api-stub: lurek.math.abs -- Returns absolute value
do -- lurek.math.abs
  local axis = -0.7
  if lurek.math.abs(axis) > 0.2 then
    lurek.log.debug("axis active", "input")
  end
end

--@api-stub: lurek.math.floor -- Returns floor of a value
do -- lurek.math.floor
  local raw_x = 123.7
  local pixel_x = lurek.math.floor(raw_x)
  lurek.log.debug("pixel x=" .. pixel_x, "render")
end

--@api-stub: lurek.math.ceil -- Returns ceiling of a value
do -- lurek.math.ceil
  local dmg = lurek.math.ceil(2.3)
  lurek.log.info("damage=" .. dmg, "combat")
end

--@api-stub: lurek.math.round -- Returns rounded value
do -- lurek.math.round
  local snapped = lurek.math.round(127.5)
  lurek.log.debug("rounded=" .. snapped, "ui")
end

--@api-stub: lurek.math.exp -- Returns exponential of a value
do -- lurek.math.exp
  local decay = lurek.math.exp(-0.5)
  lurek.log.debug("decay=" .. decay, "math")
end

--@api-stub: lurek.math.log -- Returns natural logarithm or logarithm with a supplied base
do -- lurek.math.log
  local db = 20 * lurek.math.log(0.5, 10)
  lurek.log.debug("0.5 -> " .. db .. " dB", "audio")
end

--@api-stub: lurek.math.pow -- Raises a value to a power
do -- lurek.math.pow
  local energy = lurek.math.pow(2.0, 8)
  lurek.log.debug("2^8=" .. energy, "math")
end

--@api-stub: lurek.math.min -- Returns the smallest supplied value
do -- lurek.math.min
  local function current_hp_or_default(v) return v end
  local clamp_hp = lurek.math.min(100, current_hp_or_default(85), 90)
  lurek.log.debug("hp=" .. clamp_hp, "combat")
end

--@api-stub: lurek.math.max -- Returns the largest supplied value
do -- lurek.math.max
  local final = lurek.math.max(1, 5 - 7)
  lurek.log.debug("final dmg=" .. final, "combat")
end

--@api-stub: lurek.math.clamp -- Clamps a value to a range
do -- lurek.math.clamp
  local volume = lurek.math.clamp(1.4, 0, 1)
  lurek.log.debug("clamped vol=" .. volume, "audio")
end

--@api-stub: lurek.math.sign -- Returns the sign of a value
do -- lurek.math.sign
  local axis = -0.4
  local dir = lurek.math.sign(axis)
  lurek.log.debug("walk dir=" .. dir, "input")
end

--@api-stub: lurek.math.fmod -- Returns floating-point remainder
do -- lurek.math.fmod
  local wrapped = lurek.math.fmod(7.5, lurek.math.tau)
  lurek.log.debug("wrapped=" .. wrapped, "math")
end

--@api-stub: lurek.math.lerp -- Linearly interpolates between two values
do -- lurek.math.lerp
  local hp_bar = lurek.math.lerp(0, 200, 0.42)
  lurek.log.debug("hp bar pixels=" .. hp_bar, "ui")
end

--@api-stub: lurek.math.distance -- Returns Euclidean distance between two points
do -- lurek.math.distance
  local d = lurek.math.distance(0, 0, 3, 4)
  if d < 10 then
    lurek.log.debug("near target", "ai")
  end
end

--@api-stub: lurek.math.distanceSq -- Returns squared Euclidean distance between two points
do -- lurek.math.distanceSq
  local d2 = lurek.math.distanceSq(0, 0, 3, 4)
  if d2 < 100 then
    lurek.log.debug("within 10 units", "ai")
  end
end

--@api-stub: lurek.math.random -- Returns a Lua math random value, optionally scaled to one or two bounds
do -- lurek.math.random
  local rolled = lurek.math.random(1, 6)
  lurek.log.info("dice=" .. rolled, "rng")
end

--@api-stub: lurek.math.randomInt -- Returns a Lua math random integer in an inclusive range
do -- lurek.math.randomInt
  local slot = lurek.math.randomInt(1, 8)
  lurek.log.debug("loot slot=" .. slot, "rng")
end

--@api-stub: lurek.math.simplexNoise -- Samples 2D or 3D simplex noise
do -- lurek.math.simplexNoise
  local n = lurek.math.simplexNoise(0.5, 1.5, 0.0)
  lurek.log.debug("simplex=" .. n, "noise")
end

--@api-stub: lurek.math.vec2 -- Creates a 2D vector
do -- lurek.math.vec2
  local pos = lurek.math.vec2(3, 4)
  local len = pos:length()
  lurek.log.debug("pos length=" .. len, "math")
end

--@api-stub: lurek.math.Vec2 -- Creates a 2D vector
do -- lurek.math.Vec2
  local v = lurek.math.Vec2(10, 20)
  local n = v:normalize()
  lurek.log.debug("normalised x=" .. n.x, "math")
end

--@api-stub: lurek.math.vec3 -- Creates a 3D vector
do -- lurek.math.vec3
  ---@type LVec3
  local p = lurek.math.vec3(1, 2, 3)
  local len = p:length()
  lurek.log.debug("vec3 len=" .. len, "math")
end

--@api-stub: lurek.math.Vec3 -- Creates a 3D vector
do -- lurek.math.Vec3
  ---@type LVec3
  local p = lurek.math.Vec3(0, 0, 1)
  local s = p:scale(5)
  lurek.log.debug("scaled z=" .. s.z, "math")
end

--@api-stub: lurek.math.catmullRom -- Creates a Catmull-Rom spline from point tables
do -- lurek.math.catmullRom
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=100,y=200},{x=300,y=200},{x=400,y=0}})
  local x, y = cr:sample(0.5)
  lurek.log.debug("catmull mid " .. x .. "," .. y, "spline")
end

--@api-stub: lurek.math.hermite -- Creates a Hermite spline from endpoints and tangents
do -- lurek.math.hermite
  ---@type LHermite
  local h = lurek.math.hermite(0, 0, 100, 100, 50, 0, 0, 50)
  local mx, my = h:sample(0.5)
  lurek.log.debug("hermite mid " .. mx .. "," .. my, "spline")
end

--@api-stub: lurek.math.lerp -- Linearly interpolates between two values
do -- lurek.math.lerp
  local v = lurek.math.lerp(10.0, 20.0, 0.25)
  lurek.log.debug("lerp v=" .. v, "math")
end

--@api-stub: lurek.math.remap -- Remaps a value from one range to another
do -- lurek.math.remap
  local mapped = lurek.math.remap(127, 0, 255, 0, 1)
  lurek.log.debug("normalised input=" .. mapped, "input")
end

--@api-stub: lurek.math.clamp -- Clamps a value to a range
do -- lurek.math.clamp
  local angle = lurek.math.clamp(2.5, -math.pi, math.pi)
  lurek.log.debug("clamped angle=" .. angle, "math")
end

--@api-stub: lurek.math.sign -- Returns the sign of a value
do -- lurek.math.sign
  local s = lurek.math.sign(-3.7)
  lurek.log.debug("sign=" .. s, "math")
end

--@api-stub: lurek.math.smoothstep -- Applies smoothstep interpolation between two edges
do -- lurek.math.smoothstep
  local fade = lurek.math.smoothstep(50, 100, 75)
  lurek.log.debug("fade=" .. fade, "fx")
end

--@api-stub: lurek.math.inverseLerp -- Returns the interpolation factor of a value between two bounds
do -- lurek.math.inverseLerp
  local t = lurek.math.inverseLerp(0, 200, 50)
  lurek.log.debug("t=" .. t, "math")
end

--@api-stub: lurek.math.hslToRgb -- Converts HSL color values to RGBA channels
do -- lurek.math.hslToRgb
  local r, g, b, a = lurek.math.hslToRgb(200, 0.7, 0.5)
  lurek.log.debug("rgb " .. r .. "," .. g .. "," .. b, "color")
end

--@api-stub: lurek.math.fromHex -- Converts a hex color string to RGBA channels
do -- lurek.math.fromHex
  local r, g, b, a = lurek.math.fromHex("#ff8800")
  lurek.log.debug("hex -> " .. r .. "," .. g .. "," .. b, "color")
end

--@api-stub: lurek.math.rgbToHsl -- Converts RGB channels to HSL values
do -- lurek.math.rgbToHsl
  local h, s, l = lurek.math.rgbToHsl(1.0, 0.5, 0.0)
  lurek.log.debug("hsl " .. h .. "," .. s .. "," .. l, "color")
end

--@api-stub: lurek.math.rectUnion -- Returns the union rectangle for two rectangles
do -- lurek.math.rectUnion
  local x, y, w, h = lurek.math.rectUnion(0, 0, 50, 50, 30, 30, 60, 60)
  lurek.log.debug("union " .. w .. "x" .. h, "ui")
end

--@api-stub: lurek.math.rectFromCenter -- Creates a rectangle tuple from center coordinates and size
do -- lurek.math.rectFromCenter
  local x, y, w, h = lurek.math.rectFromCenter(100, 100, 32, 32)
  lurek.log.debug("rect " .. x .. "," .. y, "geo")
end

--@api-stub: lurek.math.polygonClip -- Clips a flat polygon point table against a plane
do -- lurek.math.polygonClip
  local poly = {0, 0, 100, 0, 100, 100, 0, 100}
  local clipped = lurek.math.polygonClip(poly, 1, 0, 50)
  lurek.log.debug("clipped verts=" .. (#clipped / 2), "geo")
end

--@api-stub: lurek.math.aabbTree -- Creates an empty AABB tree
do -- lurek.math.aabbTree
  local tree = lurek.math.aabbTree()
  tree:insert(1, 0, 0, 32, 32)
  lurek.log.debug("tree size=" .. tree:len(), "physics")
end

--@api-stub: lurek.math.newCircle -- Creates a circle primitive
do -- lurek.math.newCircle
  local c = lurek.math.newCircle(0, 0, 25)
  if c:contains(10, 5) then
    lurek.log.debug("inside circle", "geo")
  end
end

--@api-stub: lurek.math.polygonIntersection -- Returns polygon intersection points for two polygon tables
do -- lurek.math.polygonIntersection
  local a = {{x=0,y=0},{x=100,y=0},{x=100,y=100},{x=0,y=100}}
  local b = {{x=50,y=50},{x=150,y=50},{x=150,y=150},{x=50,y=150}}
  local hit = lurek.math.polygonIntersection(a, b)
  lurek.log.info("overlap verts=" .. #hit, "geo")
end

--@api-stub: lurek.math.polygonUnion -- Returns polygon union points for two polygon tables
do -- lurek.math.polygonUnion
  local a = {{x=0,y=0},{x=100,y=0},{x=100,y=100},{x=0,y=100}}
  local b = {{x=80,y=80},{x=180,y=80},{x=180,y=180},{x=80,y=180}}
  local u = lurek.math.polygonUnion(a, b)
  lurek.log.info("union verts=" .. #u, "geo")
end

--@api-stub: lurek.math.polygonDifference -- Returns polygon difference points for two polygon tables
do -- lurek.math.polygonDifference
  local a = {{x=0,y=0},{x=100,y=0},{x=100,y=100},{x=0,y=100}}
  local b = {{x=20,y=20},{x=80,y=20},{x=80,y=80},{x=20,y=80}}
  local diff = lurek.math.polygonDifference(a, b)
  lurek.log.info("diff verts=" .. #diff, "geo")
end

--@api-stub: lurek.math.voronoi -- Builds Voronoi cells from a polygon-style point table
do -- lurek.math.voronoi
  local seeds = {{x=0,y=0},{x=100,y=0},{x=50,y=80}}
  local cells = lurek.math.voronoi(seeds)
  lurek.log.info("voronoi cells=" .. #cells, "geo")
end

--@api-stub: Vec2:dot
do -- Vec2:dot
  local a = lurek.math.vec2(1, 0)
  local b = lurek.math.vec2(0, 1)
  lurek.log.debug("dot=" .. a:dot(b), "math")
end

--@api-stub: Vec2:length
do -- Vec2:length
  local v = lurek.math.vec2(3, 4)
  local len = v:length()
  lurek.log.info("len=" .. len, "math")
end

--@api-stub: Vec2:x
do -- Vec2:x
  local v = lurek.math.vec2(7, 9)
  local x = v.x
  lurek.log.debug("x=" .. x, "math")
end

--@api-stub: Vec2:y
do -- Vec2:y
  local v = lurek.math.vec2(7, 9)
  local y = v.y
  lurek.log.debug("y=" .. y, "math")
end

--@api-stub: Vec2:lengthSquared
do -- Vec2:lengthSquared
  local v = lurek.math.vec2(3, 4)
  if v:lengthSquared() > 25 then
    lurek.log.debug("vector longer than 5", "math")
  end
end

--@api-stub: Vec2:normalize
do -- Vec2:normalize
  local dir = lurek.math.vec2(10, 0):normalize()
  lurek.log.debug("dir x=" .. dir.x, "math")
end

--@api-stub: Vec2:normalized
do -- Vec2:normalized
  local n = lurek.math.vec2(0, 5):normalized()
  lurek.log.debug("n.y=" .. n.y, "math")
end

--@api-stub: Vec2:lerp
do -- Vec2:lerp
  local a = lurek.math.vec2(0, 0)
  local b = lurek.math.vec2(100, 0)
  local mid = a:lerp(b, 0.5)
  lurek.log.debug("mid x=" .. mid.x, "math")
end

--@api-stub: Vec2:distance
do -- Vec2:distance
  local a = lurek.math.vec2(0, 0)
  local b = lurek.math.vec2(3, 4)
  lurek.log.info("dist=" .. a:distance(b), "math")
end

--@api-stub: Vec2:angle
do -- Vec2:angle
  local v = lurek.math.vec2(0, 1)
  lurek.log.debug("angle=" .. lurek.math.deg(v:angle()), "math")
end

--@api-stub: Vec2:rotate
do -- Vec2:rotate
  local v = lurek.math.vec2(10, 0)
  local r = v:rotate(math.pi / 2)
  lurek.log.debug("rotated x=" .. r.x .. " y=" .. r.y, "math")
end

--@api-stub: Vec2:perpendicular
do -- Vec2:perpendicular
  local n = lurek.math.vec2(1, 0):perpendicular()
  lurek.log.debug("perp y=" .. n.y, "math")
end

--@api-stub: Vec2:cross
do -- Vec2:cross
  local a = lurek.math.vec2(1, 0)
  local b = lurek.math.vec2(0, 1)
  lurek.log.debug("cross=" .. a:cross(b), "math")
end

--@api-stub: Vec2:reflect
do -- Vec2:reflect
  local incoming = lurek.math.vec2(1, -1)
  local floor = lurek.math.vec2(0, 1)
  local bounced = incoming:reflect(floor)
  lurek.log.debug("bounce y=" .. bounced.y, "physics")
end

--@api-stub: Vec3:length
do -- Vec3:length
  ---@type LVec3
  local v = lurek.math.vec3(1, 2, 2)
  lurek.log.debug("len=" .. v:length(), "math")
end

--@api-stub: Vec3:lengthSquared
do -- Vec3:lengthSquared
  ---@type LVec3
  local v = lurek.math.vec3(2, 2, 1)
  lurek.log.debug("len2=" .. v:lengthSquared(), "math")
end

--@api-stub: Vec3:normalize
do -- Vec3:normalize
  ---@type LVec3
  local v = lurek.math.vec3(0, 0, 5)
  local n = v:normalize()
  lurek.log.debug("n.z=" .. n.z, "math")
end

--@api-stub: Vec3:dot
do -- Vec3:dot
  ---@type LVec3
  local n = lurek.math.vec3(0, 1, 0)
  ---@type LVec3
  local l = lurek.math.vec3(0, 1, 0)
  lurek.log.debug("ndotl=" .. n:dot(l), "light")
end

--@api-stub: Vec3:cross
do -- Vec3:cross
  ---@type LVec3
  local x = lurek.math.vec3(1, 0, 0)
  ---@type LVec3
  local y = lurek.math.vec3(0, 1, 0)
  local z = x:cross(y)
  lurek.log.debug("z.z=" .. z.z, "math")
end

--@api-stub: Vec3:lerp
do -- Vec3:lerp
  ---@type LVec3
  local a = lurek.math.vec3(0, 0, 0)
  ---@type LVec3
  local b = lurek.math.vec3(10, 10, 10)
  local m = a:lerp(b, 0.5)
  lurek.log.debug("mid.x=" .. m.x, "math")
end

--@api-stub: Vec3:distance
do -- Vec3:distance
  ---@type LVec3
  local a = lurek.math.vec3(0, 0, 0)
  ---@type LVec3
  local b = lurek.math.vec3(3, 4, 0)
  lurek.log.info("dist=" .. a:distance(b), "math")
end

--@api-stub: Vec3:add
do -- Vec3:add
  ---@type LVec3
  local a = lurek.math.vec3(1, 2, 3)
  ---@type LVec3
  local b = lurek.math.vec3(10, 0, 0)
  local s = a:add(b)
  lurek.log.debug("sum.x=" .. s.x, "math")
end

--@api-stub: Vec3:sub
do -- Vec3:sub
  ---@type LVec3
  local a = lurek.math.vec3(5, 5, 5)
  ---@type LVec3
  local b = lurek.math.vec3(1, 2, 3)
  local d = a:sub(b)
  lurek.log.debug("diff.z=" .. d.z, "math")
end

--@api-stub: Vec3:scale
do -- Vec3:scale
  ---@type LVec3
  local base = lurek.math.vec3(1, 0, 0)
  local v = base:scale(9.81)
  lurek.log.debug("scaled.x=" .. v.x, "physics")
end

--@api-stub: CatmullRom:sample
do -- CatmullRom:sample
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=100,y=200},{x=300,y=200},{x=400,y=0}})
  local x, y = cr:sample(0.25)
  lurek.log.debug("sample " .. x .. "," .. y, "spline")
end

--@api-stub: CatmullRom:sampleSegment
do -- CatmullRom:sampleSegment
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=20},{x=100,y=0},{x=150,y=20}})
  local x, y = cr:sampleSegment(0, 0.5)
  lurek.log.debug("seg0 mid " .. x .. "," .. y, "spline")
end

--@api-stub: CatmullRom:len
do -- CatmullRom:len
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=10,y=10},{x=20,y=0},{x=30,y=10}})
  lurek.log.info("control points=" .. cr:len(), "spline")
end

--@api-stub: CatmullRom:addPoint
do -- CatmullRom:addPoint
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=50},{x=100,y=0},{x=150,y=50}})
  cr:addPoint(200, 0)
  lurek.log.debug("after add count=" .. cr:len(), "spline")
end

--@api-stub: CatmullRom:removePoint
do -- CatmullRom:removePoint
  ---@type LCatmullRom
  local cr = lurek.math.catmullRom({{x=0,y=0},{x=50,y=50},{x=100,y=0},{x=150,y=50}})
  local rx, ry = cr:removePoint(1)
  lurek.log.debug("removed " .. rx .. "," .. ry, "spline")
end

--@api-stub: Hermite:sample
do -- Hermite:sample
  ---@type LHermite
  local h = lurek.math.hermite(0, 0, 100, 100, 50, 0, 0, 50)
  local x, y = h:sample(0.5)
  lurek.log.debug("hermite mid " .. x .. "," .. y, "spline")
end

--@api-stub: RandomGenerator:random
do -- RandomGenerator:random
  local rng = lurek.math.newRandomGenerator(42)
  local v = rng:random()
  lurek.log.debug("u01=" .. v, "rng")
end

--@api-stub: RandomGenerator:randomFloat
do -- RandomGenerator:randomFloat
  local rng = lurek.math.newRandomGenerator(7)
  local angle = rng:randomFloat(0, math.pi * 2)
  lurek.log.debug("angle=" .. angle, "rng")
end

--@api-stub: RandomGenerator:randomInt
do -- RandomGenerator:randomInt
  local rng = lurek.math.newRandomGenerator(99)
  local roll = rng:randomInt(1, 20)
  lurek.log.info("d20=" .. roll, "rng")
end

--@api-stub: RandomGenerator:getSeed
do -- RandomGenerator:getSeed
  local rng = lurek.math.newRandomGenerator(20260422)
  local seed = rng:getSeed()
  lurek.log.info("rng seed=" .. seed, "rng")
end

--@api-stub: RandomGenerator:setSeed
do -- RandomGenerator:setSeed
  local rng = lurek.math.newRandomGenerator(0)
  rng:setSeed(12345)
  lurek.log.debug("after reseed=" .. rng:randomInt(1, 6), "rng")
end

--@api-stub: RandomGenerator:getState
do -- RandomGenerator:getState
  local rng = lurek.math.newRandomGenerator(77)
  local snapshot = rng:getState()
  lurek.log.debug("state bytes=" .. #snapshot, "rng")
end

--@api-stub: RandomGenerator:setState
do -- RandomGenerator:setState
  local rng = lurek.math.newRandomGenerator(77)
  local snap = rng:getState()
  rng:random()
  rng:setState(snap)
end

--@api-stub: Transform:translate
do -- Transform:translate
  local t = lurek.math.newTransform()
  t:translate(50, -10)
  lurek.log.debug("translated", "xform")
end

--@api-stub: Transform:rotate
do -- Transform:rotate
  local t = lurek.math.newTransform()
  t:rotate(math.pi / 4)
  lurek.log.debug("rotated 45deg", "xform")
end

--@api-stub: Transform:scale
do -- Transform:scale
  local t = lurek.math.newTransform()
  t:scale(2, 0.5)
  lurek.log.debug("scaled", "xform")
end

--@api-stub: Transform:shear
do -- Transform:shear
  local t = lurek.math.newTransform()
  t:shear(0.2, 0)
  lurek.log.debug("sheared", "xform")
end

--@api-stub: Transform:reset
do -- Transform:reset
  local t = lurek.math.newTransform(10, 20, 0.5)
  t:reset()
  lurek.log.debug("reset to identity", "xform")
end

--@api-stub: Transform:transformPoint
do -- Transform:transformPoint
  local t = lurek.math.newTransform(100, 50, math.pi / 2)
  local wx, wy = t:transformPoint(10, 0)
  lurek.log.debug("world " .. wx .. "," .. wy, "xform")
end

--@api-stub: Transform:inverseTransformPoint
do -- Transform:inverseTransformPoint
  local t = lurek.math.newTransform(50, 50, math.pi / 4)
  local lx, ly = t:inverseTransformPoint(100, 50)
  lurek.log.debug("local " .. lx .. "," .. ly, "xform")
end

--@api-stub: Transform:inverse
do -- Transform:inverse
  local t = lurek.math.newTransform(10, 20, 0.3)
  local inv = t:inverse()
  lurek.log.debug("got inverse", "xform")
end

--@api-stub: Transform:clone
do -- Transform:clone
  local t = lurek.math.newTransform(10, 20)
  local dup = t:clone()
  dup:translate(5, 0)
end

--@api-stub: Transform:getMatrix
do -- Transform:getMatrix
  local t = lurek.math.newTransform(0, 0, math.pi / 2)
  local m = t:getMatrix()
  lurek.log.debug("matrix elems=" .. #m, "xform")
end

--@api-stub: Transform:decompose
do -- Transform:decompose
  local t = lurek.math.newTransform(100, 50, math.pi / 4, 2, 2)
  local x, y, angle, sx, sy = t:decompose()
  lurek.log.info("xform " .. x .. "," .. y .. " a=" .. angle, "xform")
end

--@api-stub: BezierCurve:evaluate
do -- BezierCurve:evaluate
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local x, y = c:evaluate(0.25)
  lurek.log.debug("eval " .. x .. "," .. y, "spline")
end

--@api-stub: BezierCurve:evaluateAtDistance
do -- BezierCurve:evaluateAtDistance
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local x, y = c:evaluateAtDistance(120, 128)
  lurek.log.debug("eval@dist " .. x .. "," .. y, "spline")
end

--@api-stub: BezierCurve:render
do -- BezierCurve:render
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local pts = c:render(32)
  lurek.log.info("polyline points=" .. #pts, "spline")
end

--@api-stub: BezierCurve:getDerivative
do -- BezierCurve:getDerivative
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local d = c:getDerivative()
  lurek.log.debug("derivative ready", "spline")
end

--@api-stub: BezierCurve:getControlPoint
do -- BezierCurve:getControlPoint
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local x, y = c:getControlPoint(2)
  lurek.log.debug("cp2=" .. x .. "," .. y, "spline")
end

--@api-stub: BezierCurve:removeControlPoint
do -- BezierCurve:removeControlPoint
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local ok = c:removeControlPoint(3)
  lurek.log.debug("removed=" .. tostring(ok), "spline")
end

--@api-stub: BezierCurve:getControlPointCount
do -- BezierCurve:getControlPointCount
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local n = c:getControlPointCount()
  lurek.log.info("cp count=" .. n, "spline")
end

--@api-stub: BezierCurve:length
do -- BezierCurve:length
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  local len = c:length()
  lurek.log.info("arc len=" .. len, "spline")
end

--@api-stub: BezierCurve:translate
do -- BezierCurve:translate
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  c:translate(10, 5)
  lurek.log.debug("translated", "spline")
end

--@api-stub: BezierCurve:rotate
do -- BezierCurve:rotate
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  c:rotate(math.pi / 6, 0, 0)
  lurek.log.debug("rotated", "spline")
end

--@api-stub: BezierCurve:scale
do -- BezierCurve:scale
  local c = lurek.math.newBezierCurve({0, 0, 100, 200, 300, 200, 400, 0})
  c:scale(2.0, 0, 0)
  lurek.log.debug("scaled", "spline")
end
-- do  -- Tween:update
--   local tw = lurek.math.newTween(1.0, "outQuad")
--   function lurek.process(dt)
--     if tw:update(dt) then lurek.log.info("done", "tween") end
--   end
-- end

--@api-stub: Tween:reset
do -- Tween:reset
  local tw = lurek.math.newTween(0.5)
  tw:addValue(0, 100)
  tw:reset()
end

--@api-stub: Tween:getValue
do -- Tween:getValue
  local tw = lurek.math.newTween(0.5)
  tw:addValue(0, 200)
  local v = tw:getValue(1)
  lurek.log.debug("value=" .. v, "tween")
end

--@api-stub: Tween:getAllValues
do -- Tween:getAllValues
  local tw = lurek.math.newTween(0.5)
  tw:addValue(0, 1)
  local all = tw:getAllValues()
  lurek.log.debug("count=" .. #all, "tween")
end

--@api-stub: Tween:isComplete
do -- Tween:isComplete
  local tw = lurek.math.newTween(0.2)
  if tw:isComplete() then
    lurek.log.debug("ready", "tween")
  end
end

--@api-stub: Tween:getValueCount
do -- Tween:getValueCount
  local tw = lurek.math.newTween(0.5)
  tw:addValue(0, 10)
  lurek.log.info("count=" .. tw:getValueCount(), "tween")
end

--@api-stub: Tween:getEasingName
do -- Tween:getEasingName
  local tw = lurek.math.newTween(0.5, "outBack")
  lurek.log.debug("easing=" .. tw:getEasingName(), "tween")
end

--@api-stub: Tween:getDuration
do -- Tween:getDuration
  local tw = lurek.math.newTween(2.5)
  lurek.log.info("duration=" .. tw:getDuration(), "tween")
end

--@api-stub: Tween:getTime
do -- Tween:getTime
  local tw = lurek.math.newTween(1.0)
  local pct = tw:getTime() / tw:getDuration()
  lurek.log.debug("pct=" .. pct, "tween")
end

--@api-stub: Tween:getClock
do -- Tween:getClock
  local tw = lurek.math.newTween(1.0)
  local now = tw:getClock()
  lurek.log.debug("now=" .. now, "tween")
end

--@api-stub: Tween:setTime
do -- Tween:setTime
  local tw = lurek.math.newTween(1.0)
  tw:setTime(0.5)
  lurek.log.debug("seeked to 0.5", "tween")
end

--@api-stub: Tween:set
do -- Tween:set
  local tw = lurek.math.newTween(1.0)
  tw:set(0.25)
  lurek.log.debug("clock set", "tween")
end

--@api-stub: Tween:addValue
do -- Tween:addValue
  local tw = lurek.math.newTween(0.5, "outQuad")
  local idx = tw:addValue(0, 200)
  lurek.log.info("value idx=" .. idx, "tween")
end

--@api-stub: SpatialHash:remove
do -- SpatialHash:remove
  local h = lurek.math.newSpatialHash(64)
  h:insert("npc", 0, 0, 32, 32)
  h:remove("npc")
end

--@api-stub: SpatialHash:clear
do -- SpatialHash:clear
  local h = lurek.math.newSpatialHash(64)
  h:insert("a", 0, 0, 16, 16)
  h:clear()
end

--@api-stub: SpatialHash:getCellSize
do -- SpatialHash:getCellSize
  local h = lurek.math.newSpatialHash(96)
  local cs = h:getCellSize()
  lurek.log.debug("cell=" .. cs, "spatial")
end

--@api-stub: SpatialHash:getItemCount
do -- SpatialHash:getItemCount
  local h = lurek.math.newSpatialHash(64)
  h:insert("a", 0, 0, 16, 16)
  lurek.log.info("items=" .. h:getItemCount(), "spatial")
end

--@api-stub: NoiseGenerator:perlin1d
do -- NoiseGenerator:perlin1d
  local n = lurek.math.newNoiseGenerator(1)
  local wind = n:perlin1d(0.4)
  lurek.log.debug("wind=" .. wind, "weather")
end

--@api-stub: NoiseGenerator:perlin2d
do -- NoiseGenerator:perlin2d
  local n = lurek.math.newNoiseGenerator(2)
  local h = n:perlin2d(2.5, 4.5)
  lurek.log.debug("h=" .. h, "noise")
end

--@api-stub: NoiseGenerator:perlin3d
do -- NoiseGenerator:perlin3d
  local n = lurek.math.newNoiseGenerator(3)
  local v = n:perlin3d(1.0, 2.0, 3.0)
  lurek.log.debug("v=" .. v, "noise")
end

--@api-stub: NoiseGenerator:perlin4d
do -- NoiseGenerator:perlin4d
  local n = lurek.math.newNoiseGenerator(4)
  local v = n:perlin4d(0.1, 0.2, 0.3, 0.4)
  lurek.log.debug("v4=" .. v, "noise")
end

--@api-stub: NoiseGenerator:simplex1d
do -- NoiseGenerator:simplex1d
  local n = lurek.math.newNoiseGenerator(5)
  local s = n:simplex1d(0.7)
  lurek.log.debug("s1=" .. s, "noise")
end

--@api-stub: NoiseGenerator:simplex2d
do -- NoiseGenerator:simplex2d
  local n = lurek.math.newNoiseGenerator(6)
  local s = n:simplex2d(0.4, 0.6)
  lurek.log.debug("s2=" .. s, "noise")
end

--@api-stub: NoiseGenerator:simplex3d
do -- NoiseGenerator:simplex3d
  local n = lurek.math.newNoiseGenerator(7)
  local s = n:simplex3d(0.1, 0.2, 0.3)
  lurek.log.debug("s3=" .. s, "noise")
end

--@api-stub: NoiseGenerator:getSeed
do -- NoiseGenerator:getSeed
  local n = lurek.math.newNoiseGenerator(2026)
  lurek.log.info("noise seed=" .. n:getSeed(), "noise")
end

--@api-stub: NoiseGenerator:setSeed
do -- NoiseGenerator:setSeed
  local n = lurek.math.newNoiseGenerator(0)
  n:setSeed(99)
  lurek.log.debug("re-seeded", "noise")
end

--@api-stub: Circle:area
do -- Circle:area
  local c = lurek.math.newCircle(0, 0, 5)
  lurek.log.debug("area=" .. c:area(), "geo")
end

--@api-stub: Circle:perimeter
do -- Circle:perimeter
  local c = lurek.math.newCircle(0, 0, 10)
  lurek.log.debug("perimeter=" .. c:perimeter(), "geo")
end

--@api-stub: Circle:contains
do -- Circle:contains
  local c = lurek.math.newCircle(50, 50, 25)
  if c:contains(60, 60) then
    lurek.log.debug("inside", "geo")
  end
end

--@api-stub: Circle:intersects
do -- Circle:intersects
  local a = lurek.math.newCircle(0, 0, 10)
  local b = lurek.math.newCircle(15, 0, 10)
  lurek.log.debug("hit=" .. tostring(a:intersects(b)), "geo")
end

--@api-stub: Circle:aabb
do -- Circle:aabb
  local c = lurek.math.newCircle(50, 30, 10)
  local x1, y1, x2, y2 = c:aabb()
  lurek.log.debug("aabb " .. x1 .. "," .. y1 .. " to " .. x2 .. "," .. y2, "geo")
end

--@api-stub: Circle:x
do -- Circle:x
  local c = lurek.math.newCircle(72, 18, 5)
  lurek.log.debug("x=" .. c:x(), "geo")
end

--@api-stub: Circle:y
do -- Circle:y
  local c = lurek.math.newCircle(72, 18, 5)
  lurek.log.debug("y=" .. c:y(), "geo")
end

--@api-stub: Circle:radius
do -- Circle:radius
  local c = lurek.math.newCircle(0, 0, 12)
  lurek.log.info("radius=" .. c:radius(), "geo")
end

--@api-stub: AabbTree:remove
do -- AabbTree:remove
  local t = lurek.math.aabbTree()
  t:insert(1, 0, 0, 32, 32)
  local ok = t:remove(1)
  lurek.log.debug("removed=" .. tostring(ok), "physics")
end

--@api-stub: AabbTree:queryPoint
do -- AabbTree:queryPoint
  local t = lurek.math.aabbTree()
  t:insert(1, 0, 0, 32, 32)
  local ids = t:queryPoint(10, 10)
  lurek.log.info("hits=" .. #ids, "physics")
end

--@api-stub: AabbTree:contains
do -- AabbTree:contains
  local t = lurek.math.aabbTree()
  t:insert(42, 0, 0, 16, 16)
  if t:contains(42) then
    lurek.log.debug("entry exists", "physics")
  end
end

--@api-stub: AabbTree:len
do -- AabbTree:len
  local t = lurek.math.aabbTree()
  t:insert(1, 0, 0, 8, 8)
  lurek.log.info("aabb tree size=" .. t:len(), "physics")
end

--@api-stub: AabbTree:isEmpty
do -- AabbTree:isEmpty
  local t = lurek.math.aabbTree()
  if t:isEmpty() then
    lurek.log.debug("tree empty", "physics")
  end
end

--@api-stub: AabbTree:clear
do -- AabbTree:clear
  local t = lurek.math.aabbTree()
  t:insert(1, 0, 0, 16, 16)
  t:clear()
end

--@api-stub: NoiseGenerator:fbm
do -- NoiseGenerator:fbm
  local ng = lurek.math.newNoiseGenerator(42)
  local v = ng:fbm(0.3, 0.7, 6, 2.0, 0.5)
  lurek.log.info("fbm noise: " .. v, "math")
end

--@api-stub: NoiseGenerator:generateMap
do -- NoiseGenerator:generateMap
  local ng = lurek.math.newNoiseGenerator(99)
  local map = ng:generateMap(32, 32, { scale = 0.05, offsetX = 0.0, offsetY = 0.0 })
  lurek.log.info("map size: " .. #map, "math")
end

--@api-stub: NoiseGenerator:generateMapCompute
do -- NoiseGenerator:generateMapCompute
  local ng = lurek.math.newNoiseGenerator(101)
  local map = ng:generateMapCompute(16, 16, { octaves = 3, lacunarity = 2.0, gain = 0.5 })
  lurek.log.info("compute map size: " .. #map, "math")
end

--@api-stub: SpatialHash:insert
do -- SpatialHash:insert
  local sh = lurek.math.newSpatialHash(64)
  sh:insert("entity_01", 100, 100, 32, 32)
  sh:insert("entity_02", 200, 150, 32, 32)
  lurek.log.info("items: " .. sh:getItemCount(), "math")
end

--@api-stub: AabbTree:insert
do -- AabbTree:insert
  local tree = lurek.math.aabbTree()
  tree:insert(1, 10, 10, 50, 50)
  tree:insert(2, 80, 80, 120, 120)
  lurek.log.info("tree len: " .. tree:len(), "math")
end

--@api-stub: BezierCurve:insertControlPoint
do -- BezierCurve:insertControlPoint
  local bc = lurek.math.newBezierCurve({0,0, 100,50, 200,0})
  bc:insertControlPoint(100, 25, 0.5)
  lurek.log.info("ctrl pts: " .. bc:getControlPointCount(), "math")
end

--@api-stub: AabbTree:query
do -- AabbTree:query
  local tree = lurek.math.aabbTree()
  tree:insert(1, 0, 0, 40, 40)
  tree:insert(2, 60, 60, 100, 100)
  local hits = tree:query(10, 10, 50, 50)
  lurek.log.info("hits: " .. #hits, "math")
end

--@api-stub: SpatialHash:queryCircle
do -- SpatialHash:queryCircle
  local sh = lurek.math.newSpatialHash(32)
  sh:insert("e1", 100, 100, 16, 16)
  sh:insert("e2", 500, 500, 16, 16)
  local hits = sh:queryCircle(110, 110, 50)
  lurek.log.info("circle hits: " .. #hits, "math")
end

--@api-stub: SpatialHash:queryRect
do -- SpatialHash:queryRect
  local sh = lurek.math.newSpatialHash(64)
  sh:insert("player", 100, 100, 32, 32)
  sh:insert("enemy", 128, 100, 32, 32)
  local hits = sh:queryRect(90, 90, 170, 150)
  lurek.log.info("rect hits: " .. #hits, "math")
end

--@api-stub: SpatialHash:querySegment
do -- SpatialHash:querySegment
  local sh = lurek.math.newSpatialHash(64)
  sh:insert("wall", 200, 100, 240, 300)
  local hits = sh:querySegment(0, 200, 400, 200)
  lurek.log.info("segment hits: " .. #hits, "math")
end

--@api-stub: RandomGenerator:randomNormal
do -- RandomGenerator:randomNormal
  local rng = lurek.math.newRandomGenerator(12345)
  local v = rng:randomNormal(0, 1)
  lurek.log.info("normal sample: " .. v, "math")
end

--@api-stub: NoiseGenerator:ridged
do -- NoiseGenerator:ridged
  local ng = lurek.math.newNoiseGenerator(7)
  local v = ng:ridged(0.5, 0.5, 5, 2.0, 0.5)
  lurek.log.info("ridged: " .. v, "math")
end

--@api-stub: BezierCurve:setControlPoint
do -- BezierCurve:setControlPoint
  local bc = lurek.math.newBezierCurve({0,0, 100,0, 200,0})
  bc:setControlPoint(2, 100, 80)
  local cx, cy = bc:getControlPoint(2)
  lurek.log.info("ctrl pt 2: " .. cx .. "," .. cy, "math")
end

--@api-stub: Transform:setTransformation
do -- Transform:setTransformation
  local t = lurek.math.newTransform()
  t:setTransformation(100, 200, 0.5, 2.0, 2.0, 16, 16, 0, 0)
  local x, y = t:transformPoint(0, 0)
  lurek.log.info("transformed origin: " .. x .. "," .. y, "math")
end

--@api-stub: NoiseGenerator:turbulence
do -- NoiseGenerator:turbulence
  local ng = lurek.math.newNoiseGenerator(55)
  local v = ng:turbulence(0.4, 0.6, 5, 2.0, 0.5)
  lurek.log.info("turbulence: " .. v, "math")
end

--@api-stub: Tween:update
do -- Tween:update
  local tw = lurek.math.newTween(1.0, "inOutQuad")
  tw:addValue(0, 200)
  tw:update(0.5)
  lurek.log.info("x at t=0.5: " .. tw:getValue(1), "math")
end

--@api-stub: SpatialHash:update
do -- SpatialHash:update
  local sh = lurek.math.newSpatialHash(64)
  sh:insert("player", 100, 100, 32, 32)
  sh:update("player", 110, 105, 32, 32)
  lurek.log.info("player position updated", "math")
end

--@api-stub: NoiseGenerator:warpDomain
do -- NoiseGenerator:warpDomain
  local ng = lurek.math.newNoiseGenerator(101)
  local wx, wy = ng:warpDomain(0.3, 0.3, 0.8)
  wx = wx or 0.0
  wy = wy or 0.0
  local v = ng:perlin2d(wx, wy)
  lurek.log.info("warped: " .. v, "math")
end

--@api-stub: NoiseGenerator:worley2d
do -- NoiseGenerator:worley2d
  local ng = lurek.math.newNoiseGenerator(321)
  local v = ng:worley2d(0.25, 0.75)
  lurek.log.info("worley2d: " .. v, "math")
end

--@api-stub: NoiseGenerator:worley3d
do -- NoiseGenerator:worley3d
  local ng = lurek.math.newNoiseGenerator(654)
  local v = ng:worley3d(0.1, 0.5, 0.9)
  lurek.log.info("worley3d: " .. v, "math")
end

--@api-stub: AabbTree:update
do -- AabbTree:update
  local tree = lurek.math.aabbTree()
  local id = 1
  tree:insert(id, 100, 100, 132, 132)
  tree:update(id, 110, 110, 142, 142)
  lurek.log.info("AABB tree updated", "math")
end

-- =============================================================================
-- COVERAGE: 24 uncovered lurek.math API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Vec3 methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 26 uncovered lurek.math API item(s)
-- Generated by tools/audit/example_add_missing.py
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LAabbTree methods
-- -----------------------------------------------------------------------------

--@api-stub: LAabbTree:type -- Returns the Lua-visible type name for this AABB tree handle
do -- LAabbTree:type
  local aabb_tree_obj = lurek.math.aabbTree()
  local t = aabb_tree_obj:type()
  lurek.log.info("LAabbTree:type = " .. t, "math")
end
--@api-stub: LAabbTree:typeOf -- Returns whether this AABB tree handle matches a supported type name
do -- LAabbTree:typeOf
  local aabb_tree_obj = lurek.math.aabbTree()
  lurek.log.info("is LAabbTree: " .. tostring(aabb_tree_obj:typeOf("LAabbTree")), "math")
  lurek.log.info("is wrong: " .. tostring(aabb_tree_obj:typeOf("Unknown")), "math")
end
--@api-stub: LBezierCurve:type -- Returns the Lua-visible type name for this Bezier curve handle
do -- LBezierCurve:type
  local bezier_curve_obj = lurek.math.newBezierCurve({0,0, 100,50, 200,0})
  local t = bezier_curve_obj:type()
  lurek.log.info("LBezierCurve:type = " .. t, "math")
end
--@api-stub: LBezierCurve:typeOf -- Returns whether this Bezier curve handle matches a supported type name
do -- LBezierCurve:typeOf
  local bezier_curve_obj = lurek.math.newBezierCurve({0,0, 100,50, 200,0})
  lurek.log.info("is LBezierCurve: " .. tostring(bezier_curve_obj:typeOf("LBezierCurve")), "math")
  lurek.log.info("is wrong: " .. tostring(bezier_curve_obj:typeOf("Unknown")), "math")
end
--@api-stub: LCatmullRom:type -- Returns the Lua-visible type name for this spline handle
do -- LCatmullRom:type
  local catmull_rom_obj = lurek.math.catmullRom({{0,0},{100,50},{200,0},{300,50}})
  local t = catmull_rom_obj:type()
  lurek.log.info("LCatmullRom:type = " .. t, "math")
end
--@api-stub: LCatmullRom:typeOf -- Returns whether this spline handle matches a supported type name
do -- LCatmullRom:typeOf
  local catmull_rom_obj = lurek.math.catmullRom({{0,0},{100,50},{200,0},{300,50}})
  lurek.log.info("is LCatmullRom: " .. tostring(catmull_rom_obj:typeOf("LCatmullRom")), "math")
  lurek.log.info("is wrong: " .. tostring(catmull_rom_obj:typeOf("Unknown")), "math")
end
--@api-stub: LCircle:type -- Returns the Lua-visible type name for this circle handle
do -- LCircle:type
  local circle_obj = lurek.math.newCircle(0, 0, 50)
  local t = circle_obj:type()
  lurek.log.info("LCircle:type = " .. t, "math")
end
--@api-stub: LCircle:typeOf -- Returns whether this circle handle matches a supported type name
do -- LCircle:typeOf
  local circle_obj = lurek.math.newCircle(0, 0, 50)
  lurek.log.info("is LCircle: " .. tostring(circle_obj:typeOf("LCircle")), "math")
  lurek.log.info("is wrong: " .. tostring(circle_obj:typeOf("Unknown")), "math")
end
--@api-stub: LHermite:type -- Returns the Lua-visible type name for this spline handle
do -- LHermite:type
  local hermite_obj = lurek.math.hermite(0, 0, 1, 0, 100, 0, 1, 0)
  local t = hermite_obj:type()
  lurek.log.info("LHermite:type = " .. t, "math")
end
--@api-stub: LHermite:typeOf -- Returns whether this spline handle matches a supported type name
do -- LHermite:typeOf
  local hermite_obj = lurek.math.hermite(0, 0, 1, 0, 100, 0, 1, 0)
  lurek.log.info("is LHermite: " .. tostring(hermite_obj:typeOf("LHermite")), "math")
  lurek.log.info("is wrong: " .. tostring(hermite_obj:typeOf("Unknown")), "math")
end
--@api-stub: LNoiseGenerator:type -- Returns the Lua-visible type name for this noise generator handle
do -- LNoiseGenerator:type
  local noise_generator_obj = lurek.math.newNoiseGenerator(42)
  local t = noise_generator_obj:type()
  lurek.log.info("LNoiseGenerator:type = " .. t, "math")
end
--@api-stub: LNoiseGenerator:typeOf -- Returns whether this noise generator handle matches a supported type name
do -- LNoiseGenerator:typeOf
  local noise_generator_obj = lurek.math.newNoiseGenerator(42)
  lurek.log.info("is LNoiseGenerator: " .. tostring(noise_generator_obj:typeOf("LNoiseGenerator")), "math")
  lurek.log.info("is wrong: " .. tostring(noise_generator_obj:typeOf("Unknown")), "math")
end
--@api-stub: LRandomGenerator:type -- Returns the Lua-visible type name for this random generator handle
do -- LRandomGenerator:type
  local random_generator_obj = lurek.math.newRandomGenerator(42)
  local t = random_generator_obj:type()
  lurek.log.info("LRandomGenerator:type = " .. t, "math")
end
--@api-stub: LRandomGenerator:typeOf -- Returns whether this random generator handle matches a supported type name
do -- LRandomGenerator:typeOf
  local random_generator_obj = lurek.math.newRandomGenerator(42)
  lurek.log.info("is LRandomGenerator: " .. tostring(random_generator_obj:typeOf("LRandomGenerator")), "math")
  lurek.log.info("is wrong: " .. tostring(random_generator_obj:typeOf("Unknown")), "math")
end
--@api-stub: LSpatialHash:type -- Returns the Lua-visible type name for this spatial hash handle
do -- LSpatialHash:type
  local spatial_hash_obj = lurek.math.newSpatialHash(64)
  local t = spatial_hash_obj:type()
  lurek.log.info("LSpatialHash:type = " .. t, "math")
end
--@api-stub: LSpatialHash:typeOf -- Returns whether this spatial hash handle matches a supported type name
do -- LSpatialHash:typeOf
  local spatial_hash_obj = lurek.math.newSpatialHash(64)
  lurek.log.info("is LSpatialHash: " .. tostring(spatial_hash_obj:typeOf("LSpatialHash")), "math")
  lurek.log.info("is wrong: " .. tostring(spatial_hash_obj:typeOf("Unknown")), "math")
end
--@api-stub: LTransform:type -- Returns the Lua-visible type name for this transform handle
do -- LTransform:type
  local transform_obj = lurek.math.newTransform()
  local t = transform_obj:type()
  lurek.log.info("LTransform:type = " .. t, "math")
end
--@api-stub: LTransform:typeOf -- Returns whether this transform handle matches a supported type name
do -- LTransform:typeOf
  local transform_obj = lurek.math.newTransform()
  lurek.log.info("is LTransform: " .. tostring(transform_obj:typeOf("LTransform")), "math")
  lurek.log.info("is wrong: " .. tostring(transform_obj:typeOf("Unknown")), "math")
end
--@api-stub: LTween:type -- Returns the type name of this object
do -- LTween:type
  local tween_obj = lurek.tween.tween(0.5, {x=0}, {x=100})
  local t = tween_obj:type()
  lurek.log.info("LTween:type = " .. t, "math")
end
--@api-stub: LTween:typeOf -- Checks whether this object matches the given type name
do -- LTween:typeOf
  local tween_obj = lurek.tween.tween(0.5, {x=0}, {x=100})
  lurek.log.info("is LTween: " .. tostring(tween_obj:typeOf("LTween")), "math")
  lurek.log.info("is wrong: " .. tostring(tween_obj:typeOf("Unknown")), "math")
end
--@api-stub: LVec2:fromAngle
do -- LVec2:fromAngle
  local v = lurek.math.vec2(1, 0)
  local angle = math.pi / 4   -- 45 degrees (northeast)
  local dir = lurek.math.vec2(1, 0).fromAngle(angle)
  lurek.log.info("dir.x=" .. dir.x .. " dir.y=" .. dir.y, "math")
end
--@api-stub: LVec2:type -- Returns the Lua-visible type name for this vector handle
do -- LVec2:type
  local vec2_obj = lurek.math.vec2(0, 0)
  local t = vec2_obj:type()
  lurek.log.info("LVec2:type = " .. t, "math")
end
--@api-stub: LVec2:typeOf -- Returns whether this vector handle matches a supported type name
do -- LVec2:typeOf
  local vec2_obj = lurek.math.vec2(0, 0)
  lurek.log.info("is LVec2: " .. tostring(vec2_obj:typeOf("LVec2")), "math")
  lurek.log.info("is wrong: " .. tostring(vec2_obj:typeOf("Unknown")), "math")
end
--@api-stub: LVec3:splat
do -- LVec3:splat
  local v = lurek.math.vec3(0, 0, 0)
  local ones = lurek.math.vec3(1.0, 1.0, 1.0).splat(1.0)
  lurek.log.info("splat=" .. ones.x .. "," .. ones.y .. "," .. ones.z, "math")
end
--@api-stub: LVec3:type -- Returns the Lua-visible type name for this vector handle
do -- LVec3:type
  local vec3_obj = lurek.math.vec3(0, 0, 0)
  local t = vec3_obj:type()
  lurek.log.info("LVec3:type = " .. t, "math")
end
--@api-stub: LVec3:typeOf -- Returns whether this vector handle matches a supported type name
do -- LVec3:typeOf
  local vec3_obj = lurek.math.vec3(0, 0, 0)
  lurek.log.info("is LVec3: " .. tostring(vec3_obj:typeOf("LVec3")), "math")
  lurek.log.info("is wrong: " .. tostring(vec3_obj:typeOf("Unknown")), "math")
end


