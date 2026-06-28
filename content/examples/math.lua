
--@api: lurek.math.pi
do

    lurek.log.info(tostring("pi = " .. lurek.math.pi))
    lurek.log.info(tostring("pi * 2 = " .. lurek.math.pi * 2))
    lurek.log.info(tostring("half turn = " .. lurek.math.pi))
    local quarter_turn = lurek.math.pi / 2
    lurek.log.info(tostring("quarter turn = " .. quarter_turn))
end

--@api: lurek.math.tau
do

    lurek.log.info(tostring("tau = " .. lurek.math.tau))
    lurek.log.info(tostring("tau == 2*pi: " .. tostring(lurek.math.tau == 2 * lurek.math.pi)))
    lurek.log.info(tostring("full orbit = " .. lurek.math.tau))
    local orbit_step = lurek.math.tau / 4
    lurek.log.info(tostring("quarter orbit = " .. orbit_step))
end

--@api: lurek.math.abs
do

    lurek.log.info(tostring("abs(-5) = " .. lurek.math.abs(-5)))
    lurek.log.info(tostring("abs(3) = " .. lurek.math.abs(3)))
    lurek.log.info(tostring("abs(-12) keeps motion positive = " .. lurek.math.abs(-12)))
    local knockback = lurek.math.abs(-12)
    lurek.log.info(tostring("knockback magnitude = " .. knockback))
end

--@api: lurek.math.ceil
do

    lurek.log.info(tostring("ceil(2.3) = " .. lurek.math.ceil(2.3)))
    lurek.log.info(tostring("ceil(-1.7) = " .. lurek.math.ceil(-1.7)))
    lurek.log.info(tostring("ceil keeps partial row = " .. lurek.math.ceil(2.01)))
    local rows = lurek.math.ceil(13 / 5)
    lurek.log.info(tostring("rows for 13 items in 5 columns = " .. rows))
end

--@api: lurek.math.floor
do

    lurek.log.info(tostring("floor(2.9) = " .. lurek.math.floor(2.9)))
    lurek.log.info(tostring("floor(-1.1) = " .. lurek.math.floor(-1.1)))
    lurek.log.info(tostring("floor drops partial tile = " .. lurek.math.floor(2.99)))
    local full_tiles = lurek.math.floor(13 / 5)
    lurek.log.info(tostring("full tiles = " .. full_tiles))
end

--@api: lurek.math.round
do

    lurek.log.info(tostring("round(2.4) = " .. lurek.math.round(2.4)))
    lurek.log.info(tostring("round(2.5) = " .. lurek.math.round(2.5)))
    lurek.log.info(tostring("round snaps grid coord = " .. lurek.math.round(6.51)))
    local snapped = lurek.math.round(12.6)
    lurek.log.info(tostring("snapped tile = " .. snapped))
end

--@api: lurek.math.sign
do

    lurek.log.info(tostring("sign(-7) = " .. lurek.math.sign(-7)))
    lurek.log.info(tostring("sign(0) = " .. lurek.math.sign(0)))
    lurek.log.info(tostring("sign(3) = " .. lurek.math.sign(3)))
    local input_x = -42
    lurek.log.info(tostring("input x direction = " .. lurek.math.sign(input_x)))
end

--@api: lurek.math.clamp
do

    lurek.log.info(tostring("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10)))
    lurek.log.info(tostring("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10)))
    lurek.log.info(tostring("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10)))
    local health = lurek.math.clamp(118, 0, 100)
    lurek.log.info(tostring("health cap = " .. health))
end

--@api: lurek.math.lerp
do

    lurek.log.info(tostring("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5)))
    lurek.log.info(tostring("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25)))
    lurek.log.info(tostring("enemy moves 75% across = " .. lurek.math.lerp(0, 100, 0.75)))
    local ui_fade = lurek.math.lerp(0, 1, 0.3)
    lurek.log.info(tostring("ui fade alpha = " .. ui_fade))
end

--@api: lurek.math.inverseLerp
do

    lurek.log.info(tostring("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50)))
    lurek.log.info(tostring("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15)))
    lurek.log.info(tostring("progress at 75/100 = " .. lurek.math.inverseLerp(0, 100, 75)))
    local charge_fill = lurek.math.inverseLerp(0, 3, 1.5)
    lurek.log.info(tostring("charge fill = " .. charge_fill))
end

--@api: lurek.math.remap
do

    local v = lurek.math.remap(5, 0, 10, 0, 100)
    lurek.log.info(tostring("remap(5, 0-10 â†’ 0-100) = " .. v))
    lurek.log.info(tostring("thumbstick 0.25 -> percent = " .. lurek.math.remap(0.25, 0, 1, 0, 100)))
    local volume_percent = lurek.math.remap(0.75, 0, 1, 0, 100)
    lurek.log.info(tostring("volume percent = " .. volume_percent))
end

--@api: lurek.math.smoothstep
do

    lurek.log.info(tostring("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5)))
    lurek.log.info(tostring("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0)))
    lurek.log.info(tostring("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0)))
    local fade_distance = lurek.math.smoothstep(0, 10, 3)
    lurek.log.info(tostring("fade at distance 3 = " .. fade_distance))
end

--@api: lurek.math.pow
do

    lurek.log.info(tostring("pow(2, 10) = " .. lurek.math.pow(2, 10)))
    lurek.log.info(tostring("pow(3, 3) = " .. lurek.math.pow(3, 3)))
    lurek.log.info(tostring("crit multiplier tier 4 = " .. lurek.math.pow(1.25, 4)))
    local stacked_multiplier = lurek.math.pow(1.1, 5)
    lurek.log.info(tostring("stacked multiplier = " .. stacked_multiplier))
end

--@api: lurek.math.sqrt
do

    lurek.log.info(tostring("sqrt(144) = " .. lurek.math.sqrt(144)))
    lurek.log.info(tostring("sqrt(2) = " .. lurek.math.sqrt(2)))
    lurek.log.info(tostring("speed from sq length 25 = " .. lurek.math.sqrt(25)))
    local tile_diagonal = lurek.math.sqrt(25)
    lurek.log.info(tostring("tile diagonal = " .. tile_diagonal))
end

--@api: lurek.math.exp
do

    lurek.log.info(tostring("exp(1) = " .. lurek.math.exp(1)))
    lurek.log.info(tostring("exp(0) = " .. lurek.math.exp(0)))
    lurek.log.info(tostring("growth step for 2 = " .. lurek.math.exp(2)))
    local growth_factor = lurek.math.exp(2)
    lurek.log.info(tostring("growth factor = " .. growth_factor))
end

--@api: lurek.math.log
do

    lurek.log.info(tostring("log(e) = " .. lurek.math.log(lurek.math.exp(1))))
    lurek.log.info(tostring("log(100, 10) = " .. lurek.math.log(100, 10)))
    lurek.log.info(tostring("log2(8) = " .. lurek.math.log(8, 2)))
    local digits_scale = lurek.math.log(1000, 10)
    lurek.log.info(tostring("digits scale = " .. digits_scale))
end

--@api: lurek.math.fmod
do

    lurek.log.info(tostring("fmod(7, 3) = " .. lurek.math.fmod(7, 3)))
    lurek.log.info(tostring("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3)))
    lurek.log.info(tostring("looped timer = " .. lurek.math.fmod(9.75, 2.0)))
    local animation_phase = lurek.math.fmod(13.5, 2.0)
    lurek.log.info(tostring("animation phase = " .. animation_phase))
end

--@api: lurek.math.min
do

    lurek.log.info(tostring("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9)))
    lurek.log.info(tostring("min(0, -5) = " .. lurek.math.min(0, -5)))
    lurek.log.info(tostring("lowest cooldown = " .. lurek.math.min(0.8, 1.1, 0.6)))
    local slowest_speed = lurek.math.min(8, 5, 12)
    lurek.log.info(tostring("slowest speed = " .. slowest_speed))
end

--@api: lurek.math.max
do

    lurek.log.info(tostring("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9)))
    lurek.log.info(tostring("max(0, -5) = " .. lurek.math.max(0, -5)))
    lurek.log.info(tostring("highest cooldown = " .. lurek.math.max(0.8, 1.1, 0.6)))
    local fastest_speed = lurek.math.max(8, 5, 12)
    lurek.log.info(tostring("fastest speed = " .. fastest_speed))
end

--@api: lurek.math.sin
do

    lurek.log.info(tostring("sin(0) = " .. lurek.math.sin(0)))
    lurek.log.info(tostring("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2)))
    lurek.log.info(tostring("sine wave at pi = " .. lurek.math.sin(lurek.math.pi)))
    local jump_arc = lurek.math.sin(lurek.math.pi / 6)
    lurek.log.info(tostring("jump arc = " .. jump_arc))
end

--@api: lurek.math.cos
do

    lurek.log.info(tostring("cos(0) = " .. lurek.math.cos(0)))
    lurek.log.info(tostring("cos(pi) = " .. lurek.math.cos(lurek.math.pi)))
    lurek.log.info(tostring("cos facing up = " .. lurek.math.cos(lurek.math.rad(90))))
    local facing_x = lurek.math.cos(lurek.math.rad(60))
    lurek.log.info(tostring("facing x = " .. facing_x))
end

--@api: lurek.math.tan
do

    lurek.log.info(tostring("tan(0) = " .. lurek.math.tan(0)))
    lurek.log.info(tostring("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4)))
    lurek.log.info(tostring("tan aiming slope = " .. lurek.math.tan(lurek.math.rad(15))))
    local camera_slope = lurek.math.tan(lurek.math.rad(30))
    lurek.log.info(tostring("camera slope = " .. camera_slope))
end

--@api: lurek.math.asin
do

    lurek.log.info(tostring("asin(1) = " .. lurek.math.asin(1)))
    lurek.log.info(tostring("asin(0) = " .. lurek.math.asin(0)))
    lurek.log.info(tostring("asin(0.5) = " .. lurek.math.asin(0.5)))
    local half_arc = lurek.math.asin(0.5)
    lurek.log.info(tostring("half arc = " .. half_arc))
end

--@api: lurek.math.acos
do

    lurek.log.info(tostring("acos(1) = " .. lurek.math.acos(1)))
    lurek.log.info(tostring("acos(0) = " .. lurek.math.acos(0)))
    lurek.log.info(tostring("acos(0.5) = " .. lurek.math.acos(0.5)))
    local cone_edge = lurek.math.acos(0.5)
    lurek.log.info(tostring("vision cone edge = " .. cone_edge))
end

--@api: lurek.math.atan
do

    lurek.log.info(tostring("atan(1) = " .. lurek.math.atan(1)))
    lurek.log.info(tostring("atan(1, 1) = " .. lurek.math.atan(1, 1)))
    lurek.log.info(tostring("atan(0.25) = " .. lurek.math.atan(0.25)))
    local aim_pitch = lurek.math.atan(0.5)
    lurek.log.info(tostring("aim pitch = " .. aim_pitch))
end

--@api: lurek.math.atan2
do

    lurek.log.info(tostring("atan2(1, 0) = " .. lurek.math.atan2(1, 0)))
    lurek.log.info(tostring("atan2(0, 1) = " .. lurek.math.atan2(0, 1)))
    lurek.log.info(tostring("heading to top-right = " .. lurek.math.atan2(-1, 1)))
    local diagonal_heading = lurek.math.atan2(10, 10)
    lurek.log.info(tostring("diagonal heading = " .. diagonal_heading))
end

--@api: lurek.math.deg
do

    lurek.log.info(tostring("deg(pi) = " .. lurek.math.deg(lurek.math.pi)))
    lurek.log.info(tostring("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2)))
    lurek.log.info(tostring("45deg from rad = " .. lurek.math.deg(lurek.math.rad(45))))
    local ui_angle = lurek.math.deg(lurek.math.pi / 3)
    lurek.log.info(tostring("ui angle = " .. ui_angle))
end

--@api: lurek.math.rad
do

    lurek.log.info(tostring("rad(180) = " .. lurek.math.rad(180)))
    lurek.log.info(tostring("rad(90) = " .. lurek.math.rad(90)))
    lurek.log.info(tostring("30deg in radians = " .. lurek.math.rad(30)))
    local turret_turn = lurek.math.rad(45)
    lurek.log.info(tostring("turret turn = " .. turret_turn))
end

--@api: lurek.math.random
do

    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    lurek.log.info(tostring("random = " .. r1 .. ", " .. r2 .. ", " .. r3))
    local loot_roll = lurek.math.random(100)
end

--@api: lurek.math.randomInt
do

    local r = lurek.math.randomInt(1, 6)
    lurek.log.info(tostring("randomInt(1,6) = " .. r))
    lurek.log.info(tostring("second die = " .. lurek.math.randomInt(1, 6)))
    local reroll = lurek.math.randomInt(1, 6)
    lurek.log.info(tostring("reroll = " .. reroll))
end

--@api: lurek.math.distance
do

    local d = lurek.math.distance(0, 0, 3, 4)
    lurek.log.info(tostring("distance = " .. d))
    lurek.log.info(tostring("distance to 6,8 = " .. lurek.math.distance(0, 0, 6, 8)))
    local tiles_apart = d / 5
    lurek.log.info(tostring("5-unit tiles apart = " .. tiles_apart))
end

--@api: lurek.math.distanceSq
do

    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    lurek.log.info(tostring("distanceSq = " .. d2))
    lurek.log.info(tostring("distanceSq to 6,8 = " .. lurek.math.distanceSq(0, 0, 6, 8)))
    local exact_distance = lurek.math.sqrt(d2)
    lurek.log.info(tostring("distance from sq = " .. exact_distance))
end

--@api: lurek.math.angleBetween
do

    local a = lurek.math.angleBetween(0, 0, 1, 0)
    lurek.log.info(tostring("angle to right = " .. a))
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    lurek.log.info(tostring("angle down = " .. b))
    local turn_delta = b - a
end

--@api: lurek.math.closestPointOnSegment
do

    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    lurek.log.info(tostring("closest on segment = " .. cx .. "," .. cy))
    lurek.log.info(tostring("value types = " .. type(cx) .. "," .. type(cy)))
    local snap_distance = lurek.math.distance(5, 5, cx, cy)
    lurek.log.info(tostring("snap distance = " .. snap_distance))
end

--@api: lurek.math.lineIntersect
do

    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then lurek.log.info(tostring("lines cross at " .. ix .. "," .. iy)) else lurek.log.info(tostring("lines are parallel")) end
    lurek.log.info(tostring("value types = " .. type(ix) .. "," .. type(iy)))
    local crossed = ix ~= nil and iy ~= nil
    lurek.log.info(tostring("crossed = " .. tostring(crossed)))
end

--@api: lurek.math.segmentIntersectsSegment
do

    local hit, ix, iy = lurek.math.segmentIntersectsSegment( 0, 0, 10, 10, 0, 10, 10, 0 )
    if hit and ix then lurek.log.info(tostring("segments cross at " .. ix .. "," .. iy)) else lurek.log.info(tostring("segments do not cross")) end
    lurek.log.info(tostring("value types = " .. type(hit) .. "," .. type(ix) .. "," .. type(iy)))
    local crossed = hit and ix ~= nil
    lurek.log.info(tostring("crossed = " .. tostring(crossed)))
end

--@api: lurek.math.circleContainsPoint
do

    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    lurek.log.info(tostring("inside = " .. tostring(inside)))
    lurek.log.info(tostring("outside = " .. tostring(lurek.math.circleContainsPoint(5, 5, 10, 20, 20))))
    local border = lurek.math.circleContainsPoint(5, 5, 10, 15, 5)
    lurek.log.info(tostring("border point = " .. tostring(border)))
end

--@api: lurek.math.circleIntersectsCircle
do

    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    lurek.log.info(tostring("circles overlap = " .. tostring(hit)))
    lurek.log.info(tostring("touching circles overlap = " .. tostring(lurek.math.circleIntersectsCircle(0, 0, 5, 10, 0, 5))))
    local separated_overlap = lurek.math.circleIntersectsCircle(0, 0, 5, 20, 0, 5)
    lurek.log.info(tostring("separated overlap = " .. tostring(separated_overlap)))
end

--@api: lurek.math.circleIntersectsLine
do

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    lurek.log.info(tostring("circle/line hit = " .. tostring(hit)))
    if hx1 then lurek.log.info(tostring("  hit1 = " .. hx1 .. "," .. hy1)) end
    if hx2 then lurek.log.info(tostring("  hit2 = " .. hx2 .. "," .. hy2)) end
    local two_hits = hx2 ~= nil and hy2 ~= nil
end

--@api: lurek.math.circleIntersectsSegment
do

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    lurek.log.info(tostring("circle/seg hit = " .. tostring(hit)))
    if hx1 then lurek.log.info(tostring("  seg hit1 = " .. hx1 .. "," .. hy1)) end
    _ = hx2
    _ = hy2
end

--@api: lurek.math.pointInPolygon
do

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    lurek.log.info(tostring("inside = " .. tostring(inside) .. " outside = " .. tostring(outside)))
    local edge = lurek.math.pointInPolygon(pts, 0, 5)
end

--@api: lurek.math.polygonArea
do

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    lurek.log.info(tostring("area = " .. area))
    local triangle_area = lurek.math.polygonArea({0, 0, 8, 0, 0, 8})
    lurek.log.info(tostring("triangle area = " .. triangle_area))
end

--@api: lurek.math.polygonCentroid
do

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    lurek.log.info(tostring("centroid = " .. cx .. "," .. cy))
    local cx2, cy2 = lurek.math.polygonCentroid({0, 0, 8, 0, 8, 8, 0, 8})
    lurek.log.info(tostring("square center = " .. cx2 .. "," .. cy2))
end

--@api: lurek.math.isConvex
do

    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    lurek.log.info(tostring("square convex = " .. tostring(lurek.math.isConvex(square))))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    lurek.log.info(tostring("concave = " .. tostring(lurek.math.isConvex(concave))))
    local triangle = {0, 0, 6, 0, 3, 5}
end

--@api: lurek.math.convexHull
do

    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    lurek.log.info(tostring("hull vertices = " .. #hull / 2))
    local input_points = #pts / 2
    lurek.log.info(tostring("input points = " .. input_points))
end

--@api: lurek.math.polygonClip
do

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    lurek.log.info(tostring("clipped vertices = " .. #clipped / 2))
    local original_points = #pts / 2
    lurek.log.info(tostring("original points = " .. original_points))
end

--@api: lurek.math.polygonUnion
do

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonUnion(a, b)
    lurek.log.info(tostring("union vertices = " .. #result))
    lurek.log.info(tostring("source polygons = " .. #a .. " + " .. #b))
end

--@api: lurek.math.polygonIntersection
do

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonIntersection(a, b)
    lurek.log.info(tostring("intersection vertices = " .. #result))
    lurek.log.info(tostring("source polygons = " .. #a .. " + " .. #b))
end

--@api: lurek.math.polygonDifference
do

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonDifference(a, b)
    lurek.log.info(tostring("difference vertices = " .. #result))
    lurek.log.info(tostring("source polygons = " .. #a .. " + " .. #b))
end

--@api: lurek.math.triangulate
do

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    lurek.log.info(tostring("triangles = " .. #tris))
    local source_vertices = #pts / 2
    lurek.log.info(tostring("source vertices = " .. source_vertices))
end

--@api: lurek.math.delaunayTriangulate
do

    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    lurek.log.info(tostring("delaunay triangles = " .. #tris))
    local input_vertices = #pts / 2
    lurek.log.info(tostring("input vertices = " .. input_vertices))
end

--@api: lurek.math.bresenham
do

    local pts = lurek.math.bresenham(0, 0, 5, 3)
    lurek.log.info(tostring("bresenham points = " .. #pts))
    for _, p in ipairs(pts) do
        lurek.log.info(tostring("  " .. p.x .. "," .. p.y))
    end
end

--@api: lurek.math.rectFromCenter
do

    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    lurek.log.info(tostring("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h))
    lurek.log.info(tostring("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h)))
    local center_x = x + w / 2
    lurek.log.info(tostring("center x = " .. center_x))
end

--@api: lurek.math.rectUnion
do

    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    lurek.log.info(tostring("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h))
    lurek.log.info(tostring("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h)))
    local union_area = w * h
    lurek.log.info(tostring("union area = " .. union_area))
end

--@api: lurek.math.newBezierCurve
do

    local curve = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    lurek.log.info(tostring("control points = " .. curve:getControlPointCount()))
    local x, y = curve:evaluate(0.5)
    lurek.log.info(tostring("mid = " .. x .. "," .. y))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
end

--@api: LBezierCurve:evaluate
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = curve:evaluate(0.25)
    lurek.log.info(tostring("t=0.25 = " .. x .. "," .. y))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
end

--@api: LBezierCurve:evaluateAtDistance
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local length = curve:length()
    local x, y = curve:evaluateAtDistance(length * 0.5, 32)
    lurek.log.info(tostring("length = " .. length))
    lurek.log.info(tostring("halfway = " .. x .. "," .. y))
end

--@api: LBezierCurve:getControlPoint
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local x, y = curve:getControlPoint(2)
    lurek.log.info(tostring("cp2 = " .. x .. "," .. y))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
end

--@api: LBezierCurve:setControlPoint
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:getControlPoint(2)
    curve:setControlPoint(2, 50, 80)
    local afterX, afterY = curve:getControlPoint(2)
    lurek.log.info(tostring("before = " .. beforeX .. "," .. beforeY))
    lurek.log.info(tostring("after = " .. afterX .. "," .. afterY))
end

--@api: LBezierCurve:insertControlPoint
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    lurek.log.info(tostring("count before = " .. curve:getControlPointCount()))
    curve:insertControlPoint(50, 50, 2)
    local x, y = curve:getControlPoint(2)
    lurek.log.info(tostring("inserted = " .. x .. "," .. y))
    lurek.log.info(tostring("count after = " .. curve:getControlPointCount()))
end

--@api: LBezierCurve:removeControlPoint
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    lurek.log.info(tostring("count before = " .. curve:getControlPointCount()))
    curve:removeControlPoint(2)
    lurek.log.info(tostring("count after = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
end

--@api: LBezierCurve:length
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    lurek.log.info(tostring("length = " .. curve:length()))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
    lurek.log.info(tostring("curve midpoint x = " .. select(1, curve:evaluate(0.5))))
end

--@api: LBezierCurve:render
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local points = curve:render(4)
    local sample = points[3]
    lurek.log.info(tostring("samples = " .. #points))
    lurek.log.info(tostring("sample 3 = " .. sample[1] .. "," .. sample[2]))
end

--@api: LBezierCurve:getDerivative
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local derivative = curve:getDerivative()
    local x, y = derivative:evaluate(0.5)
    lurek.log.info(tostring("derivative control points = " .. derivative:getControlPointCount()))
    lurek.log.info(tostring("tangent = " .. x .. "," .. y))
end

--@api: LBezierCurve:translate
do

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:evaluate(0)
    curve:translate(10, 20)
    local afterX, afterY = curve:evaluate(0)
    lurek.log.info(tostring("before = " .. beforeX .. "," .. beforeY))
    lurek.log.info(tostring("after = " .. afterX .. "," .. afterY))
end

--@api: LBezierCurve:rotate
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:rotate(lurek.math.pi / 2, 0, 0)
    local x, y = curve:getControlPoint(2)
    lurek.log.info(tostring("end point = " .. x .. "," .. y))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
end

--@api: LBezierCurve:scale
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:scale(2, 0, 0)
    local x, y = curve:getControlPoint(2)
    lurek.log.info(tostring("end point = " .. x .. "," .. y))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
end

--@api: lurek.math.catmullRom
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    lurek.log.info(tostring("points = " .. spline:len()))
    local x, y = spline:sample(0.5)
    lurek.log.info(tostring("mid = " .. x .. "," .. y))
    lurek.log.info(tostring("spline points = " .. spline:len()))
end

--@api: LCatmullRom:sample
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sample(0.25)
    lurek.log.info(tostring("t=0.25 = " .. x .. "," .. y))
    lurek.log.info(tostring("spline points = " .. spline:len()))
    lurek.log.info(tostring("sample x at 0.5 = " .. select(1, spline:sample(0.5))))
end

--@api: LCatmullRom:sampleSegment
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sampleSegment(1, 0.5)
    lurek.log.info(tostring("segment 1 = " .. x .. "," .. y))
    lurek.log.info(tostring("spline points = " .. spline:len()))
    lurek.log.info(tostring("sample x at 0.5 = " .. select(1, spline:sample(0.5))))
end

--@api: LCatmullRom:addPoint
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}})
    lurek.log.info(tostring("before = " .. spline:len()))
    spline:addPoint(150, 60)
    lurek.log.info(tostring("after = " .. spline:len()))
    lurek.log.info(tostring("spline points = " .. spline:len()))
end

--@api: LCatmullRom:removePoint
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:removePoint(1)
    lurek.log.info(tostring("removed = " .. x .. "," .. y))
    lurek.log.info(tostring("after = " .. spline:len()))
    lurek.log.info(tostring("spline points = " .. spline:len()))
end

--@api: lurek.math.hermite
do

    local spline = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100)
    local x0, y0 = spline:sample(0)
    local xm, ym = spline:sample(0.5)
    local x1, y1 = spline:sample(1)
    lurek.log.info(tostring("start = " .. x0 .. "," .. y0))
    lurek.log.info(tostring("mid = " .. xm .. "," .. ym))
    lurek.log.info(tostring("end = " .. x1 .. "," .. y1))
end

--@api: lurek.math.vec2
do

    local v = lurek.math.vec2(3, 4)
    lurek.log.info(tostring("vec2 = " .. v.x .. "," .. v.y))
    lurek.log.info(tostring("heading = " .. v:angle()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: lurek.math.Vec2
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring("vec2 = " .. v.x .. "," .. v.y))
    lurek.log.info(tostring("heading = " .. v:angle()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:length
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring("length = " .. v:length()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec2:lengthSquared
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring("lengthSq = " .. v:lengthSquared()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec2:normalize
do

    local v = lurek.math.vec2(3, 4)
    local n = v:normalize()
    lurek.log.info(tostring("normalized = " .. n.x .. "," .. n.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:normalized
do

    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    lurek.log.info(tostring("normalized = " .. n.x .. "," .. n.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:dot
do

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    lurek.log.info(tostring("dot = " .. a:dot(b)))
    lurek.log.info(tostring("vector length = " .. a:length()))
    lurek.log.info(tostring("unit x = " .. a:normalized().x))
end

--@api: LVec2:cross
do

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    lurek.log.info(tostring("cross = " .. a:cross(b)))
    lurek.log.info(tostring("vector length = " .. a:length()))
    lurek.log.info(tostring("unit x = " .. a:normalized().x))
end

--@api: LVec2:distance
do

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(3, 4)
    lurek.log.info(tostring("distance = " .. a:distance(b)))
    lurek.log.info(tostring("vector length = " .. a:length()))
    lurek.log.info(tostring("unit x = " .. a:normalized().x))
end

--@api: LVec2:angle
do

    local v = lurek.math.vec2(1, 1)
    lurek.log.info(tostring("angle = " .. v:angle()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec2:lerp
do

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    lurek.log.info(tostring("lerp = " .. mid.x .. "," .. mid.y))
    lurek.log.info(tostring("vector length = " .. a:length()))
end

--@api: LVec2:rotate
do

    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(lurek.math.pi / 2)
    lurek.log.info(tostring("rotated = " .. r.x .. "," .. r.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:perpendicular
do

    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    lurek.log.info(tostring("perp = " .. p.x .. "," .. p.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:reflect
do

    local v = lurek.math.vec2(1, -1)
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    lurek.log.info(tostring("reflected = " .. ref.x .. "," .. ref.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
end

--@api: LVec2:fromAngle
do

    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(lurek.math.pi / 4)
    lurek.log.info(tostring("fromAngle(pi/4) = " .. unit.x .. "," .. unit.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: lurek.math.vec3
do

    local v = lurek.math.vec3(1, 2, 3)
    lurek.log.info(tostring("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z))
    lurek.log.info(tostring("lengthSquared = " .. v:lengthSquared()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: lurek.math.Vec3
do

    local v = lurek.math.Vec3(1, 2, 3)
    lurek.log.info(tostring("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z))
    lurek.log.info(tostring("lengthSquared = " .. v:lengthSquared()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: LVec3:length
do

    local v = lurek.math.Vec3(1, 2, 2)
    lurek.log.info(tostring("length = " .. v:length()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
    lurek.log.info(tostring("unit z = " .. v:normalize().z))
end

--@api: LVec3:lengthSquared
do

    local v = lurek.math.Vec3(1, 2, 2)
    lurek.log.info(tostring("lengthSq = " .. v:lengthSquared()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
    lurek.log.info(tostring("unit z = " .. v:normalize().z))
end

--@api: LVec3:normalize
do

    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    lurek.log.info(tostring("normalized = " .. n.x .. "," .. n.y .. "," .. n.z))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: LVec3:dot
do

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    lurek.log.info(tostring("dot = " .. a:dot(b)))
    lurek.log.info(tostring("vector length = " .. a:length()))
    lurek.log.info(tostring("unit x = " .. a:normalize().x))
end

--@api: LVec3:cross
do

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    local c = a:cross(b)
    lurek.log.info(tostring("cross = " .. c.x .. "," .. c.y .. "," .. c.z))
    lurek.log.info(tostring("vector length = " .. a:length()))
end

--@api: LVec3:add
do

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    lurek.log.info(tostring("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z))
    lurek.log.info(tostring("vector length = " .. a:length()))
end

--@api: LVec3:sub
do

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local diff = a:sub(b)
    lurek.log.info(tostring("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z))
    lurek.log.info(tostring("vector length = " .. a:length()))
end

--@api: LVec3:scale
do

    local v = lurek.math.vec3(1, 2, 3)
    local scaled = v:scale(2)
    lurek.log.info(tostring("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: LVec3:distance
do

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    lurek.log.info(tostring("distance = " .. a:distance(b)))
    lurek.log.info(tostring("vector length = " .. a:length()))
    lurek.log.info(tostring("unit x = " .. a:normalize().x))
end

--@api: LVec3:lerp
do

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    local mid = a:lerp(b, 0.5)
    lurek.log.info(tostring("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z))
    lurek.log.info(tostring("vector length = " .. a:length()))
end

--@api: LVec3:splat
do

    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    lurek.log.info(tostring("splat = " .. s.x .. "," .. s.y .. "," .. s.z))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: lurek.math.newTransform
do

    local t = lurek.math.newTransform(100, 200, lurek.math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    lurek.log.info(tostring("origin transformed = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
    lurek.log.info(tostring("origin y = " .. select(2, t:transformPoint(0, 0))))
end

--@api: LTransform:translate
do

    local t = lurek.math.newTransform()
    t:translate(50, 50)
    local x, y = t:transformPoint(0, 0)
    lurek.log.info(tostring("point = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:rotate
do

    local t = lurek.math.newTransform()
    t:rotate(lurek.math.pi / 2)
    local x, y = t:transformPoint(10, 0)
    lurek.log.info(tostring("point = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:scale
do

    local t = lurek.math.newTransform()
    t:scale(2, 3)
    local x, y = t:transformPoint(10, 5)
    lurek.log.info(tostring("point = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:shear
do

    local t = lurek.math.newTransform()
    t:shear(0.25, 0)
    local x, y = t:transformPoint(10, 10)
    lurek.log.info(tostring("point = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:transformPoint
do

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    lurek.log.info(tostring("forward = " .. fx .. "," .. fy))
    lurek.log.info(tostring("inverse = " .. ix .. "," .. iy))
end

--@api: LTransform:inverseTransformPoint
do

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    lurek.log.info(tostring("forward = " .. fx .. "," .. fy))
    lurek.log.info(tostring("inverse = " .. ix .. "," .. iy))
end

--@api: LTransform:clone
do

    local t = lurek.math.newTransform(10, 20, 0.5)
    local clone = t:clone()
    local x, y = clone:transformPoint(0, 0)
    lurek.log.info(tostring("clone point = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:inverse
do

    local t = lurek.math.newTransform(10, 20, 0.5)
    local inv = t:inverse()
    local x, y = t:transformPoint(5, 0)
    local rx, ry = inv:transformPoint(x, y)
    lurek.log.info(tostring("roundtrip = " .. rx .. "," .. ry))
end

--@api: LTransform:decompose
do

    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    lurek.log.info(tostring("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
    lurek.log.info(tostring("origin y = " .. select(2, t:transformPoint(0, 0))))
end

--@api: LTransform:getMatrix
do

    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    lurek.log.info(tostring("matrix elements = " .. #m))
    lurek.log.info(tostring("first row = " .. m[1] .. "," .. m[2] .. "," .. m[3]))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:reset
do

    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x, y = t:transformPoint(10, 10)
    lurek.log.info(tostring("after reset = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: LTransform:setTransformation
do

    local t = lurek.math.newTransform()
    t:setTransformation(0, 0, lurek.math.pi, 1, 1)
    local x, y = t:transformPoint(10, 0)
    lurek.log.info(tostring("after set = " .. x .. "," .. y))
    lurek.log.info(tostring("origin x = " .. select(1, t:transformPoint(0, 0))))
end

--@api: lurek.math.newRandomGenerator
do

    local rng = lurek.math.newRandomGenerator(42)
    lurek.log.info(tostring("seed = " .. rng:getSeed()))
    lurek.log.info(tostring("seed = " .. rng:getSeed()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:random
do

    local rng = lurek.math.newRandomGenerator(100)
    lurek.log.info(tostring("random = " .. rng:random()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:randomFloat
do

    local rng = lurek.math.newRandomGenerator(100)
    lurek.log.info(tostring("float = " .. rng:randomFloat(1.0, 5.0)))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:randomInt
do

    local rng = lurek.math.newRandomGenerator(100)
    lurek.log.info(tostring("int = " .. rng:randomInt(1, 100)))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:randomNormal
do

    local rng = lurek.math.newRandomGenerator(100)
    lurek.log.info(tostring("normal = " .. rng:randomNormal(1.0, 0.0)))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:setSeed
do

    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    lurek.log.info(tostring("seed = " .. rng:getSeed()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:getState
do

    local rng = lurek.math.newRandomGenerator(999)
    lurek.log.info(tostring("state = " .. rng:getState()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:setState
do

    local rng = lurek.math.newRandomGenerator(1)
    local first = rng:random()
    local state = rng:getState()
    local skipped = rng:random()
    rng:setState(state)
    local restored = rng:random()
    lurek.log.info(tostring("restored = " .. tostring(skipped == restored)))
    lurek.log.info(tostring("first = " .. first))
end

--@api: lurek.math.newTween
do

    local tw = lurek.math.newTween(2.0, "inOutCubic")
    lurek.log.info(tostring("duration = " .. tw:getDuration()))
    lurek.log.info(tostring("easing = " .. tw:getEasingName()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
    lurek.log.info(tostring("value count = " .. tw:getValueCount()))
end

--@api: LTween:addValue
do

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    lurek.log.info(tostring("index = " .. index))
    lurek.log.info(tostring("channels = " .. tw:getValueCount()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:getValue
do

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    tw:setTime(0.5)
    lurek.log.info(tostring("value = " .. tw:getValue(index)))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:getAllValues
do

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    tw:setTime(0.5)
    local values = tw:getAllValues()
    lurek.log.info(tostring("count = " .. #values))
    lurek.log.info(tostring("first = " .. values[1]))
end

--@api: LTween:getValueCount
do

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    lurek.log.info(tostring("channels = " .. tw:getValueCount()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:update
do

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    lurek.log.info(tostring("done = " .. tostring(done)))
    lurek.log.info(tostring("value = " .. tw:getValue(1)))
end

--@api: LTween:isComplete
do

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(1.1)
    lurek.log.info(tostring("complete = " .. tostring(tw:isComplete())))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:reset
do

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(0.5)
    tw:reset()
    lurek.log.info(tostring("clock = " .. tw:getClock()))
end

--@api: LTween:set
do

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    lurek.log.info(tostring("value = " .. tw:getValue(1)))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:setTime
do

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    lurek.log.info(tostring("time = " .. tw:getTime()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:getTime
do

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    lurek.log.info(tostring("time = " .. tw:getTime()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: LTween:getClock
do

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    lurek.log.info(tostring("clock = " .. tw:getClock()))
    lurek.log.info(tostring("tween time = " .. tw:getTime()))
end

--@api: lurek.math.aabbTree
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    lurek.log.info(tostring("len = " .. tree:len()))
    lurek.log.info(tostring("empty = " .. tostring(tree:isEmpty())))
end

--@api: LAabbTree:query
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    lurek.log.info(tostring("query hits = " .. #hits))
end

--@api: LAabbTree:queryPoint
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:queryPoint(7, 7)
    lurek.log.info(tostring("point hits = " .. #hits))
end

--@api: LAabbTree:contains
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    lurek.log.info(tostring("contains 1 = " .. tostring(tree:contains(1))))
    lurek.log.info(tostring("tree len = " .. tree:len()))
    lurek.log.info(tostring("tree empty = " .. tostring(tree:isEmpty())))
end

--@api: LAabbTree:remove
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:remove(2)
    lurek.log.info(tostring("len = " .. tree:len()))
end

--@api: LAabbTree:update
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:update(1, 20, 20, 30, 30)
    local hits = tree:query(19, 19, 21, 21)
    lurek.log.info(tostring("query hits = " .. #hits))
end

--@api: lurek.math.newSpatialHash
do

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    lurek.log.info(tostring("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
end

--@api: LSpatialHash:queryRect
do

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryRect(0, 0, 12, 12)
    lurek.log.info(tostring("rect hits = " .. #hits))
end

--@api: LSpatialHash:queryCircle
do

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryCircle(5, 5, 10)
    lurek.log.info(tostring("circle hits = " .. #hits))
end

--@api: LSpatialHash:querySegment
do

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:querySegment(0, 0, 50, 50)
    lurek.log.info(tostring("segment hits = " .. #hits))
end

--@api: LSpatialHash:remove
do

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:remove("b")
    lurek.log.info(tostring("items = " .. sh:getItemCount()))
end

--@api: LSpatialHash:update
do

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:update("a", 200, 200, 10, 10)
    local hits = sh:queryRect(190, 190, 20, 20)
    lurek.log.info(tostring("rect hits = " .. #hits))
end

--@api: lurek.math.newRectPacker
do

    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x, y = rp:pack(32, 32, "icon1")
    lurek.log.info(tostring("icon1 = " .. tostring(x) .. "," .. tostring(y)))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
end

--@api: lurek.math.newCircle
do

    local c = lurek.math.newCircle(50, 50, 25)
    lurek.log.info(tostring("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius()))
    lurek.log.info(tostring("area = " .. c:area()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
end

--@api: LCircle:contains
do

    local circle = lurek.math.newCircle(0, 0, 10)
    lurek.log.info(tostring("contains = " .. tostring(circle:contains(5, 5))))
    lurek.log.info(tostring("radius = " .. circle:radius()))
    lurek.log.info(tostring("center x = " .. circle:x()))
    lurek.log.info(tostring("center y = " .. circle:y()))
end

--@api: LCircle:intersects
do

    local a = lurek.math.newCircle(0, 0, 10)
    local b = lurek.math.newCircle(15, 0, 10)
    lurek.log.info(tostring("intersects = " .. tostring(a:intersects(b))))
    lurek.log.info(tostring("radius = " .. a:radius()))
    lurek.log.info(tostring("center x = " .. a:x()))
end

--@api: LCircle:aabb
do

    local c1 = lurek.math.newCircle(0, 0, 10)
    local minx, miny, maxx, maxy = c1:aabb()
    lurek.log.info(tostring("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy))
    lurek.log.info(tostring("radius = " .. c1:radius()))
    lurek.log.info(tostring("center x = " .. c1:x()))
end

--@api: lurek.math.voronoi
do

    local cells = lurek.math.voronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    lurek.log.info(tostring("cells = " .. #cells))
    lurek.log.info(tostring("has first cell = " .. tostring(cells[1] ~= nil)))
    local first_size = cells[1] and #cells[1] or 0
    lurek.log.info(tostring("first cell points = " .. first_size))
end

--@api: lurek.math.applyEasing
do

    local linear = lurek.math.applyEasing("linear", 0.5)
    local eased = lurek.math.applyEasing("inOutCubic", 0.5)
    lurek.log.info(tostring("linear = " .. linear))
    lurek.log.info(tostring("inOutCubic = " .. eased))
    local finish = lurek.math.applyEasing("inOutCubic", 1.0)
end

--@api: lurek.math.inBack
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inBack(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inBack(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inBack(1.0)))
    local ease_start = lurek.math.inBack(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inBounce
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inBounce(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inBounce(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inBounce(1.0)))
    local ease_start = lurek.math.inBounce(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inCubic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inCubic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inCubic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inCubic(1.0)))
    local ease_start = lurek.math.inCubic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inElastic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inElastic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inElastic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inElastic(1.0)))
    local ease_start = lurek.math.inElastic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inExpo
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inExpo(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inExpo(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inExpo(1.0)))
    local ease_start = lurek.math.inExpo(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inQuad
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inQuad(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inQuad(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inQuad(1.0)))
    local ease_start = lurek.math.inQuad(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inQuart
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inQuart(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inQuart(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inQuart(1.0)))
    local ease_start = lurek.math.inQuart(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inSine
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inSine(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inSine(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inSine(1.0)))
    local ease_start = lurek.math.inSine(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.linear
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.linear(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.linear(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.linear(1.0)))
    local ease_start = lurek.math.linear(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outBack
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outBack(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outBack(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outBack(1.0)))
    local ease_start = lurek.math.outBack(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outBounce
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outBounce(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outBounce(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outBounce(1.0)))
    local ease_start = lurek.math.outBounce(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outCubic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outCubic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outCubic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outCubic(1.0)))
    local ease_start = lurek.math.outCubic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outElastic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outElastic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outElastic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outElastic(1.0)))
    local ease_start = lurek.math.outElastic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outExpo
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outExpo(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outExpo(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outExpo(1.0)))
    local ease_start = lurek.math.outExpo(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outQuad
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outQuad(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outQuad(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outQuad(1.0)))
    local ease_start = lurek.math.outQuad(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outQuart
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outQuart(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outQuart(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outQuart(1.0)))
    local ease_start = lurek.math.outQuart(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.outSine
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.outSine(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.outSine(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.outSine(1.0)))
    local ease_start = lurek.math.outSine(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutBack
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutBack(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutBack(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutBack(1.0)))
    local ease_start = lurek.math.inOutBack(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutBounce
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutBounce(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutBounce(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutBounce(1.0)))
    local ease_start = lurek.math.inOutBounce(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutCubic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutCubic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutCubic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutCubic(1.0)))
    local ease_start = lurek.math.inOutCubic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutElastic
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutElastic(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutElastic(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutElastic(1.0)))
    local ease_start = lurek.math.inOutElastic(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutExpo
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutExpo(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutExpo(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutExpo(1.0)))
    local ease_start = lurek.math.inOutExpo(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutQuad
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutQuad(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutQuad(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutQuad(1.0)))
    local ease_start = lurek.math.inOutQuad(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutQuart
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutQuart(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutQuart(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutQuart(1.0)))
    local ease_start = lurek.math.inOutQuart(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: lurek.math.inOutSine
do

    lurek.log.info(tostring("t=0.25 = " .. lurek.math.inOutSine(0.25)))
    lurek.log.info(tostring("t=0.75 = " .. lurek.math.inOutSine(0.75)))
    lurek.log.info(tostring("finish = " .. lurek.math.inOutSine(1.0)))
    local ease_start = lurek.math.inOutSine(0.0)
    lurek.log.info(tostring("start = " .. ease_start))
end

--@api: LRandomGenerator:getSeed
do

    local rng = lurek.math.newRandomGenerator(77)
    lurek.log.info(tostring("seed = " .. rng:getSeed()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:type
do

    local rng = lurek.math.newRandomGenerator(77)
    lurek.log.info(tostring("type = " .. rng:type()))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
    lurek.log.info(tostring("state token exists = " .. tostring(rng:getState() ~= nil)))
end

--@api: LRandomGenerator:typeOf
do

    local rng = lurek.math.newRandomGenerator(77)
    lurek.log.info(tostring("typeOf = " .. tostring(rng:typeOf("LRandomGenerator"))))
    lurek.log.info(tostring("type = " .. tostring(rng:type())))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:roll
do

    local rng = lurek.math.newRandomGenerator(1)
    local d20 = rng:roll(20)
    lurek.log.info(tostring("d20 = " .. d20))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollN
do

    local rng = lurek.math.newRandomGenerator(2)
    local dice = rng:rollN(3, 6)
    lurek.log.info(tostring("3d6 = " .. dice[1] .. ", " .. dice[2] .. ", " .. dice[3]))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollSum
do

    local rng = lurek.math.newRandomGenerator(3)
    local total = rng:rollSum(4, 6)
    lurek.log.info(tostring("4d6 sum = " .. total))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollKeepHighest
do

    local rng = lurek.math.newRandomGenerator(4)
    local stat = rng:rollKeepHighest(4, 6, 3)
    lurek.log.info(tostring("4d6 keep 3 highest = " .. stat))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollKeepLowest
do

    local rng = lurek.math.newRandomGenerator(5)
    local penalty = rng:rollKeepLowest(4, 6, 3)
    lurek.log.info(tostring("4d6 keep 3 lowest = " .. penalty))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollAdvantage
do

    local rng = lurek.math.newRandomGenerator(6)
    local adv = rng:rollAdvantage(20)
    lurek.log.info(tostring("d20 advantage = " .. adv))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollDisadvantage
do

    local rng = lurek.math.newRandomGenerator(7)
    local dis = rng:rollDisadvantage(20)
    lurek.log.info(tostring("d20 disadvantage = " .. dis))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:rollExploding
do

    local rng = lurek.math.newRandomGenerator(8)
    local ex = rng:rollExploding(3, 6)
    lurek.log.info(tostring("3d6 exploding = " .. ex))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:countSuccesses
do

    local rng = lurek.math.newRandomGenerator(9)
    local hits = rng:countSuccesses(5, 10, 7)
    lurek.log.info(tostring("5d10 successes (7+) = " .. hits))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: LRandomGenerator:chance
do

    local rng = lurek.math.newRandomGenerator(10)
    local crit = rng:chance(0.05)
    lurek.log.info(tostring("critical hit (5%) = " .. tostring(crit)))
    lurek.log.info(tostring("d6 preview = " .. rng:randomInt(1, 6)))
    lurek.log.info(tostring("coin flip = " .. tostring(rng:chance(0.5))))
end

--@api: lurek.math.geometricVoronoi
do

    local cells = lurek.math.geometricVoronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    lurek.log.info(tostring("cells = " .. #cells))
    lurek.log.info(tostring("has first cell = " .. tostring(cells[1] ~= nil)))
    local first_size = cells[1] and #cells[1] or 0
    lurek.log.info(tostring("first cell points = " .. first_size))
end

--@api: LAabbTree:clear
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:clear()
    lurek.log.info(tostring("empty = " .. tostring(tree:isEmpty())))
    lurek.log.info(tostring("tree len = " .. tree:len()))
end

--@api: LAabbTree:insert
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    lurek.log.info(tostring("len = " .. tree:len()))
    lurek.log.info(tostring("tree len = " .. tree:len()))
    lurek.log.info(tostring("tree empty = " .. tostring(tree:isEmpty())))
end

--@api: LAabbTree:isEmpty
do

    local tree = lurek.math.aabbTree()
    lurek.log.info(tostring("empty = " .. tostring(tree:isEmpty())))
    lurek.log.info(tostring("tree len = " .. tree:len()))
    lurek.log.info(tostring("tree empty = " .. tostring(tree:isEmpty())))
    lurek.log.info(tostring("query origin hits = " .. #tree:query(0, 0, 1, 1)))
end

--@api: LAabbTree:len
do

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    lurek.log.info(tostring("len = " .. tree:len()))
    lurek.log.info(tostring("tree len = " .. tree:len()))
end

--@api: LAabbTree:type
do

    local tree = lurek.math.aabbTree()
    lurek.log.info(tostring(tree:type()))
    lurek.log.info(tostring("tree len = " .. tree:len()))
    lurek.log.info(tostring("tree empty = " .. tostring(tree:isEmpty())))
    lurek.log.info(tostring("query origin hits = " .. #tree:query(0, 0, 1, 1)))
end

--@api: LAabbTree:typeOf
do

    local tree = lurek.math.aabbTree()
    lurek.log.info(tostring(tostring(tree:typeOf("LAabbTree"))))
    lurek.log.info(tostring("type = " .. tostring(tree:type())))
    lurek.log.info(tostring("tree len = " .. tree:len()))
    lurek.log.info(tostring("tree empty = " .. tostring(tree:isEmpty())))
end

--@api: LBezierCurve:getControlPointCount
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    lurek.log.info(tostring("count = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
    lurek.log.info(tostring("curve midpoint x = " .. select(1, curve:evaluate(0.5))))
end

--@api: LBezierCurve:type
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    lurek.log.info(tostring(curve:type()))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
    lurek.log.info(tostring("curve midpoint x = " .. select(1, curve:evaluate(0.5))))
end

--@api: LBezierCurve:typeOf
do

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    lurek.log.info(tostring(tostring(curve:typeOf("LBezierCurve"))))
    lurek.log.info(tostring("type = " .. tostring(curve:type())))
    lurek.log.info(tostring("curve points = " .. curve:getControlPointCount()))
    lurek.log.info(tostring("curve length = " .. curve:length()))
end

--@api: LCatmullRom:len
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    lurek.log.info(tostring("len = " .. spline:len()))
    lurek.log.info(tostring("spline points = " .. spline:len()))
    lurek.log.info(tostring("sample x at 0.5 = " .. select(1, spline:sample(0.5))))
    lurek.log.info(tostring("sample y at 0.5 = " .. select(2, spline:sample(0.5))))
end

--@api: LCatmullRom:type
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    lurek.log.info(tostring(spline:type()))
    lurek.log.info(tostring("spline points = " .. spline:len()))
    lurek.log.info(tostring("sample x at 0.5 = " .. select(1, spline:sample(0.5))))
    lurek.log.info(tostring("sample y at 0.5 = " .. select(2, spline:sample(0.5))))
end

--@api: LCatmullRom:typeOf
do

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    lurek.log.info(tostring(tostring(spline:typeOf("LCatmullRom"))))
    lurek.log.info(tostring("type = " .. tostring(spline:type())))
    lurek.log.info(tostring("spline points = " .. spline:len()))
    lurek.log.info(tostring("sample x at 0.5 = " .. select(1, spline:sample(0.5))))
end

--@api: LCircle:area
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring("area = " .. c:area()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LCircle:perimeter
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring("perimeter = " .. c:perimeter()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LCircle:radius
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LCircle:type
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring(c:type()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LCircle:typeOf
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring(tostring(c:typeOf("LCircle"))))
    lurek.log.info(tostring("type = " .. tostring(c:type())))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
end

--@api: LCircle:x
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring("x = " .. c:x()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LCircle:y
do

    local c = lurek.math.newCircle(100, 100, 50)
    lurek.log.info(tostring("y = " .. c:y()))
    lurek.log.info(tostring("radius = " .. c:radius()))
    lurek.log.info(tostring("center x = " .. c:x()))
    lurek.log.info(tostring("center y = " .. c:y()))
end

--@api: LHermite:sample
do

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local x, y = h:sample(0.5)
    lurek.log.info(tostring("sample = " .. x .. "," .. y))
    lurek.log.info(tostring("sample x at 0.25 = " .. select(1, h:sample(0.25))))
    lurek.log.info(tostring("sample y at 0.25 = " .. select(2, h:sample(0.25))))
end

--@api: LHermite:type
do

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    lurek.log.info(tostring(h:type()))
    lurek.log.info(tostring("sample x at 0.25 = " .. select(1, h:sample(0.25))))
    lurek.log.info(tostring("sample y at 0.25 = " .. select(2, h:sample(0.25))))
    lurek.log.info(tostring("sample x at 0.75 = " .. select(1, h:sample(0.75))))
end

--@api: LHermite:typeOf
do

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    lurek.log.info(tostring(tostring(h:typeOf("LHermite"))))
    lurek.log.info(tostring("type = " .. tostring(h:type())))
    lurek.log.info(tostring("sample x at 0.25 = " .. select(1, h:sample(0.25))))
    lurek.log.info(tostring("sample y at 0.25 = " .. select(2, h:sample(0.25))))
end

--@api: LRectPacker:clear
do

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    rp:clear()
    lurek.log.info(tostring("packed = " .. #rp:getPacked()))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
end

--@api: LRectPacker:getPacked
do

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    local packed = rp:getPacked()
    lurek.log.info(tostring("packed = " .. #packed))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
end

--@api: LRectPacker:occupancy
do

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
    lurek.log.info(tostring("packed count = " .. #rp:getPacked()))
end

--@api: LRectPacker:pack
do

    local rp = lurek.math.newRectPacker(512, 512, 2)
    local x, y = rp:pack(64, 64, "box")
    lurek.log.info(tostring("pack = " .. tostring(x) .. "," .. tostring(y)))
    lurek.log.info(tostring("occupancy = " .. rp:occupancy()))
    lurek.log.info(tostring("packed count = " .. #rp:getPacked()))
end

--@api: LSpatialHash:clear
do

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    sh:clear()
    lurek.log.info(tostring("count = " .. sh:getItemCount()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
end

--@api: LSpatialHash:getCellSize
do

    local sh = lurek.math.newSpatialHash(32)
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("item count = " .. sh:getItemCount()))
    lurek.log.info(tostring("origin hits = " .. #sh:queryRect(0, 0, 1, 1)))
end

--@api: LSpatialHash:getItemCount
do

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    lurek.log.info(tostring("items = " .. sh:getItemCount()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("item count = " .. sh:getItemCount()))
end

--@api: LSpatialHash:insert
do

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    lurek.log.info(tostring("items = " .. sh:getItemCount()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("item count = " .. sh:getItemCount()))
end

--@api: LSpatialHash:type
do

    local sh = lurek.math.newSpatialHash(32)
    lurek.log.info(tostring(sh:type()))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("item count = " .. sh:getItemCount()))
    lurek.log.info(tostring("origin hits = " .. #sh:queryRect(0, 0, 1, 1)))
end

--@api: LSpatialHash:typeOf
do

    local sh = lurek.math.newSpatialHash(32)
    lurek.log.info(tostring(tostring(sh:typeOf("LSpatialHash"))))
    lurek.log.info(tostring("type = " .. tostring(sh:type())))
    lurek.log.info(tostring("cell size = " .. sh:getCellSize()))
    lurek.log.info(tostring("item count = " .. sh:getItemCount()))
end

--@api: LTransform:type
do

    local tf = lurek.math.newTransform()
    lurek.log.info(tostring(tf:type()))
    lurek.log.info(tostring("origin x = " .. select(1, tf:transformPoint(0, 0))))
    lurek.log.info(tostring("origin y = " .. select(2, tf:transformPoint(0, 0))))
    lurek.log.info(tostring("unit x after transform = " .. select(1, tf:transformPoint(1, 0))))
end

--@api: LTransform:typeOf
do

    local tf = lurek.math.newTransform()
    lurek.log.info(tostring(tostring(tf:typeOf("LTransform"))))
    lurek.log.info(tostring("type = " .. tostring(tf:type())))
    lurek.log.info(tostring("origin x = " .. select(1, tf:transformPoint(0, 0))))
    lurek.log.info(tostring("origin y = " .. select(2, tf:transformPoint(0, 0))))
end

--@api: LVec2:type
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring(v:type()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec2:typeOf
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring(v:typeOf("LVec2")))
    lurek.log.info(tostring("type = " .. tostring(v:type())))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
end

--@api: LVec2:x
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring("x=" .. v.x))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec2:y
do

    local v = lurek.math.Vec2(3, 4)
    lurek.log.info(tostring("y=" .. v.y))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalized().x))
    lurek.log.info(tostring("unit y = " .. v:normalized().y))
end

--@api: LVec3:type
do

    local v = lurek.math.Vec3(1, 2, 3)
    lurek.log.info(tostring(v:type()))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
    lurek.log.info(tostring("unit z = " .. v:normalize().z))
end

--@api: LVec3:typeOf
do

    local v = lurek.math.Vec3(1, 2, 3)
    lurek.log.info(tostring(tostring(v:typeOf("LVec3"))))
    lurek.log.info(tostring("type = " .. tostring(v:type())))
    lurek.log.info(tostring("vector length = " .. v:length()))
    lurek.log.info(tostring("unit x = " .. v:normalize().x))
end

--@api: lurek.math.easingNames
do

    local names = lurek.math.easingNames()
    lurek.log.info(tostring("easing count = " .. #names))
    lurek.log.info(tostring("contains linear = " .. tostring(names[1] ~= nil)))
    local first_name = names[1] or "none"
    lurek.log.info(tostring("first easing = " .. first_name))
end

--@api: lurek.math.cubicBezier
do

    local y = lurek.math.cubicBezier(0.25, 0.1, 0.25, 1.0, 0.5)
    lurek.log.info(tostring("cubicBezier(0.5) = " .. y))
    lurek.log.info(tostring("ease sample at 0.2 = " .. lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.2)))
    local late_curve = lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.8)
    lurek.log.info(tostring("ease in-out at 0.8 = " .. late_curve))
end

--@api: lurek.math.newLootTable
do

    local loot = lurek.math.newLootTable({ seed = 42 })
    loot:add("common", 10.0, { tier = "c" })
    loot:add("rare", 1.0, { tier = "r" })
    loot:build()
    local pick = loot:sample()
    lurek.log.info(tostring("loot pick = " .. tostring(pick and pick.id)))
end

--@api: lurek.math.lootFromList
do

    local loot = lurek.math.lootFromList({
        { id = "gold", weight = 20.0, meta = { kind = "currency" } },
        { id = "gem", weight = 2.0, meta = { kind = "currency" } },
    })
    lurek.log.info(tostring("fromList count = " .. loot:entryCount()))
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
    lurek.log.info(tostring("pity sample = " .. tostring(id)))
end

--@api: lurek.math.sampleWithPity
do

    local loot = lurek.math.newLootTable(9)
    loot:add("a", 1.0)
    loot:build()
    local pity = lurek.math.newPityTracker("a", 1)
    local id = lurek.math.sampleWithPity(loot, pity)
    lurek.log.info(tostring("sampleWithPity = " .. tostring(id)))
end

--@api: LLootTable:merge
do

    local a = lurek.math.newLootTable(9)
    local b = lurek.math.newLootTable(10)
    a:add("a", 1.0)
    b:add("b", 1.0)
    a:merge(b)
    a:build()
    lurek.log.info(tostring("merged entries = " .. tostring(a:entryCount())))
end

--@api: LLootTable:save
do

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    lurek.log.info(tostring("save blob bytes = " .. tostring(#blob)))
end

--@api: LLootTable:restore
do

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    local restored = lurek.math.newLootTable()
    restored:restore(blob)
    lurek.log.info(tostring("restore count = " .. tostring(restored:entryCount())))
end

--@api: LPityTracker:save
do

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    lurek.log.info(tostring("pity save blob = " .. tostring(pity_blob)))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
end

--@api: LPityTracker:restore
do

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    pity:restore(pity_blob)
    lurek.log.info(tostring("pity restore ok"))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
end

--@api: lurek.math.lootFromToml
do

    local tbl = lurek.math.lootFromToml("save/loot_table_unit_test.toml")
    lurek.log.info(tostring("lootFromToml entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample preview = " .. tostring(tbl:sample())))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
end

--@api: LLootTable:add
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    lurek.log.info(tostring("add ok"))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
end

--@api: LLootTable:build
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    lurek.log.info(tostring("build ok"))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
end

--@api: LLootTable:entryCount
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    lurek.log.info(tostring("entryCount = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
end

--@api: LLootTable:remove
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:remove("wood")
    lurek.log.info(tostring("remove ok"))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
end

--@api: LLootTable:sample
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    lurek.log.info(tostring("sample = " .. tostring(tbl:sample())))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
end

--@api: LLootTable:sampleN
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleN(2)
    lurek.log.info(tostring("sampleN = " .. tostring(#picks)))
end

--@api: LLootTable:sampleUnique
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleUnique(2)
    lurek.log.info(tostring("sampleUnique = " .. tostring(#picks)))
end

--@api: LLootTable:setSeed
do

    local tbl = lurek.math.newLootTable(1)
    tbl:setSeed(7)
    lurek.log.info(tostring("setSeed ok"))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
end

--@api: LLootTable:setWeight
do

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:setWeight("wood", 2.0)
    lurek.log.info(tostring("setWeight ok"))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
end

--@api: LLootTable:type
do

    local tbl = lurek.math.newLootTable(1)
    lurek.log.info(tostring("type = " .. tostring(tbl:type())))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
    lurek.log.info(tostring("save blob exists = " .. tostring(tbl:save() ~= nil)))
end

--@api: LLootTable:typeOf
do

    local tbl = lurek.math.newLootTable(1)
    lurek.log.info(tostring("typeOf = " .. tostring(tbl:typeOf("LLootTable"))))
    lurek.log.info(tostring("type = " .. tostring(tbl:type())))
    lurek.log.info(tostring("entries = " .. tostring(tbl:entryCount())))
    lurek.log.info(tostring("sample now = " .. tostring(tbl:sample())))
end

--@api: LPityTracker:counter
do

    local pity = lurek.math.newPityTracker("rare", 2)
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
    lurek.log.info(tostring("export exists = " .. tostring(pity:export() ~= nil)))
end

--@api: LPityTracker:export
do

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    lurek.log.info(tostring("export ok = " .. tostring(snapshot ~= nil)))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
end

--@api: LPityTracker:import
do

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    pity:import(snapshot)
    lurek.log.info(tostring("import ok"))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
end

--@api: LPityTracker:isPrimed
do

    local pity = lurek.math.newPityTracker("rare", 1)
    pity:notice("common")
    lurek.log.info(tostring("isPrimed = " .. tostring(pity:isPrimed())))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
end

--@api: LPityTracker:notice
do

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    lurek.log.info(tostring("notice ok"))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
end

--@api: LPityTracker:reset
do

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:reset()
    lurek.log.info(tostring("reset counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
end

--@api: LPityTracker:type
do

    local pity = lurek.math.newPityTracker("rare", 2)
    lurek.log.info(tostring("type = " .. tostring(pity:type())))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
    lurek.log.info(tostring("export exists = " .. tostring(pity:export() ~= nil)))
end

--@api: LPityTracker:typeOf
do

    local pity = lurek.math.newPityTracker("rare", 2)
    lurek.log.info(tostring("typeOf = " .. tostring(pity:typeOf("LPityTracker"))))
    lurek.log.info(tostring("type = " .. tostring(pity:type())))
    lurek.log.info(tostring("counter = " .. tostring(pity:counter())))
    lurek.log.info(tostring("primed = " .. tostring(pity:isPrimed())))
end
