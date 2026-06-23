
--@api: lurek.math.pi
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("pi = " .. lurek.math.pi)
    example_print_log("pi * 2 = " .. lurek.math.pi * 2)
    example_print_log("half turn = " .. lurek.math.pi)
    local quarter_turn = lurek.math.pi / 2
    example_print_log("quarter turn = " .. quarter_turn)
end

--@api: lurek.math.tau
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("tau = " .. lurek.math.tau)
    example_print_log("tau == 2*pi: " .. tostring(lurek.math.tau == 2 * lurek.math.pi))
    example_print_log("full orbit = " .. lurek.math.tau)
    local orbit_step = lurek.math.tau / 4
    example_print_log("quarter orbit = " .. orbit_step)
end

--@api: lurek.math.abs
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("abs(-5) = " .. lurek.math.abs(-5))
    example_print_log("abs(3) = " .. lurek.math.abs(3))
    example_print_log("abs(-12) keeps motion positive = " .. lurek.math.abs(-12))
    local knockback = lurek.math.abs(-12)
    example_print_log("knockback magnitude = " .. knockback)
end

--@api: lurek.math.ceil
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("ceil(2.3) = " .. lurek.math.ceil(2.3))
    example_print_log("ceil(-1.7) = " .. lurek.math.ceil(-1.7))
    example_print_log("ceil keeps partial row = " .. lurek.math.ceil(2.01))
    local rows = lurek.math.ceil(13 / 5)
    example_print_log("rows for 13 items in 5 columns = " .. rows)
end

--@api: lurek.math.floor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("floor(2.9) = " .. lurek.math.floor(2.9))
    example_print_log("floor(-1.1) = " .. lurek.math.floor(-1.1))
    example_print_log("floor drops partial tile = " .. lurek.math.floor(2.99))
    local full_tiles = lurek.math.floor(13 / 5)
    example_print_log("full tiles = " .. full_tiles)
end

--@api: lurek.math.round
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("round(2.4) = " .. lurek.math.round(2.4))
    example_print_log("round(2.5) = " .. lurek.math.round(2.5))
    example_print_log("round snaps grid coord = " .. lurek.math.round(6.51))
    local snapped = lurek.math.round(12.6)
    example_print_log("snapped tile = " .. snapped)
end

--@api: lurek.math.sign
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sign(-7) = " .. lurek.math.sign(-7))
    example_print_log("sign(0) = " .. lurek.math.sign(0))
    example_print_log("sign(3) = " .. lurek.math.sign(3))
    local input_x = -42
    example_print_log("input x direction = " .. lurek.math.sign(input_x))
end

--@api: lurek.math.clamp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10))
    example_print_log("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10))
    example_print_log("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10))
    local health = lurek.math.clamp(118, 0, 100)
    example_print_log("health cap = " .. health)
end

--@api: lurek.math.lerp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5))
    example_print_log("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25))
    example_print_log("enemy moves 75% across = " .. lurek.math.lerp(0, 100, 0.75))
    local ui_fade = lurek.math.lerp(0, 1, 0.3)
    example_print_log("ui fade alpha = " .. ui_fade)
end

--@api: lurek.math.inverseLerp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50))
    example_print_log("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15))
    example_print_log("progress at 75/100 = " .. lurek.math.inverseLerp(0, 100, 75))
    local charge_fill = lurek.math.inverseLerp(0, 3, 1.5)
    example_print_log("charge fill = " .. charge_fill)
end

--@api: lurek.math.remap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.remap(5, 0, 10, 0, 100)
    example_print_log("remap(5, 0-10 â†’ 0-100) = " .. v)
    example_print_log("thumbstick 0.25 -> percent = " .. lurek.math.remap(0.25, 0, 1, 0, 100))
    local volume_percent = lurek.math.remap(0.75, 0, 1, 0, 100)
    example_print_log("volume percent = " .. volume_percent)
end

--@api: lurek.math.smoothstep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5))
    example_print_log("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0))
    example_print_log("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0))
    local fade_distance = lurek.math.smoothstep(0, 10, 3)
    example_print_log("fade at distance 3 = " .. fade_distance)
end

--@api: lurek.math.pow
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("pow(2, 10) = " .. lurek.math.pow(2, 10))
    example_print_log("pow(3, 3) = " .. lurek.math.pow(3, 3))
    example_print_log("crit multiplier tier 4 = " .. lurek.math.pow(1.25, 4))
    local stacked_multiplier = lurek.math.pow(1.1, 5)
    example_print_log("stacked multiplier = " .. stacked_multiplier)
end

--@api: lurek.math.sqrt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sqrt(144) = " .. lurek.math.sqrt(144))
    example_print_log("sqrt(2) = " .. lurek.math.sqrt(2))
    example_print_log("speed from sq length 25 = " .. lurek.math.sqrt(25))
    local tile_diagonal = lurek.math.sqrt(25)
    example_print_log("tile diagonal = " .. tile_diagonal)
end

--@api: lurek.math.exp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("exp(1) = " .. lurek.math.exp(1))
    example_print_log("exp(0) = " .. lurek.math.exp(0))
    example_print_log("growth step for 2 = " .. lurek.math.exp(2))
    local growth_factor = lurek.math.exp(2)
    example_print_log("growth factor = " .. growth_factor)
end

--@api: lurek.math.log
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("log(e) = " .. lurek.math.log(lurek.math.exp(1)))
    example_print_log("log(100, 10) = " .. lurek.math.log(100, 10))
    example_print_log("log2(8) = " .. lurek.math.log(8, 2))
    local digits_scale = lurek.math.log(1000, 10)
    example_print_log("digits scale = " .. digits_scale)
end

--@api: lurek.math.fmod
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("fmod(7, 3) = " .. lurek.math.fmod(7, 3))
    example_print_log("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3))
    example_print_log("looped timer = " .. lurek.math.fmod(9.75, 2.0))
    local animation_phase = lurek.math.fmod(13.5, 2.0)
    example_print_log("animation phase = " .. animation_phase)
end

--@api: lurek.math.min
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
    example_print_log("min(0, -5) = " .. lurek.math.min(0, -5))
    example_print_log("lowest cooldown = " .. lurek.math.min(0.8, 1.1, 0.6))
    local slowest_speed = lurek.math.min(8, 5, 12)
    example_print_log("slowest speed = " .. slowest_speed)
end

--@api: lurek.math.max
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9))
    example_print_log("max(0, -5) = " .. lurek.math.max(0, -5))
    example_print_log("highest cooldown = " .. lurek.math.max(0.8, 1.1, 0.6))
    local fastest_speed = lurek.math.max(8, 5, 12)
    example_print_log("fastest speed = " .. fastest_speed)
end

--@api: lurek.math.sin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sin(0) = " .. lurek.math.sin(0))
    example_print_log("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2))
    example_print_log("sine wave at pi = " .. lurek.math.sin(lurek.math.pi))
    local jump_arc = lurek.math.sin(lurek.math.pi / 6)
    example_print_log("jump arc = " .. jump_arc)
end

--@api: lurek.math.cos
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("cos(0) = " .. lurek.math.cos(0))
    example_print_log("cos(pi) = " .. lurek.math.cos(lurek.math.pi))
    example_print_log("cos facing up = " .. lurek.math.cos(lurek.math.rad(90)))
    local facing_x = lurek.math.cos(lurek.math.rad(60))
    example_print_log("facing x = " .. facing_x)
end

--@api: lurek.math.tan
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("tan(0) = " .. lurek.math.tan(0))
    example_print_log("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4))
    example_print_log("tan aiming slope = " .. lurek.math.tan(lurek.math.rad(15)))
    local camera_slope = lurek.math.tan(lurek.math.rad(30))
    example_print_log("camera slope = " .. camera_slope)
end

--@api: lurek.math.asin
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("asin(1) = " .. lurek.math.asin(1))
    example_print_log("asin(0) = " .. lurek.math.asin(0))
    example_print_log("asin(0.5) = " .. lurek.math.asin(0.5))
    local half_arc = lurek.math.asin(0.5)
    example_print_log("half arc = " .. half_arc)
end

--@api: lurek.math.acos
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("acos(1) = " .. lurek.math.acos(1))
    example_print_log("acos(0) = " .. lurek.math.acos(0))
    example_print_log("acos(0.5) = " .. lurek.math.acos(0.5))
    local cone_edge = lurek.math.acos(0.5)
    example_print_log("vision cone edge = " .. cone_edge)
end

--@api: lurek.math.atan
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("atan(1) = " .. lurek.math.atan(1))
    example_print_log("atan(1, 1) = " .. lurek.math.atan(1, 1))
    example_print_log("atan(0.25) = " .. lurek.math.atan(0.25))
    local aim_pitch = lurek.math.atan(0.5)
    example_print_log("aim pitch = " .. aim_pitch)
end

--@api: lurek.math.atan2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("atan2(1, 0) = " .. lurek.math.atan2(1, 0))
    example_print_log("atan2(0, 1) = " .. lurek.math.atan2(0, 1))
    example_print_log("heading to top-right = " .. lurek.math.atan2(-1, 1))
    local diagonal_heading = lurek.math.atan2(10, 10)
    example_print_log("diagonal heading = " .. diagonal_heading)
end

--@api: lurek.math.deg
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("deg(pi) = " .. lurek.math.deg(lurek.math.pi))
    example_print_log("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2))
    example_print_log("45deg from rad = " .. lurek.math.deg(lurek.math.rad(45)))
    local ui_angle = lurek.math.deg(lurek.math.pi / 3)
    example_print_log("ui angle = " .. ui_angle)
end

--@api: lurek.math.rad
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("rad(180) = " .. lurek.math.rad(180))
    example_print_log("rad(90) = " .. lurek.math.rad(90))
    example_print_log("30deg in radians = " .. lurek.math.rad(30))
    local turret_turn = lurek.math.rad(45)
    example_print_log("turret turn = " .. turret_turn)
end

--@api: lurek.math.random
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    example_print_log("random = " .. r1 .. ", " .. r2 .. ", " .. r3)
    local loot_roll = lurek.math.random(100)
end

--@api: lurek.math.randomInt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local r = lurek.math.randomInt(1, 6)
    example_print_log("randomInt(1,6) = " .. r)
    example_print_log("second die = " .. lurek.math.randomInt(1, 6))
    local reroll = lurek.math.randomInt(1, 6)
    example_print_log("reroll = " .. reroll)
end

--@api: lurek.math.distance
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local d = lurek.math.distance(0, 0, 3, 4)
    example_print_log("distance = " .. d)
    example_print_log("distance to 6,8 = " .. lurek.math.distance(0, 0, 6, 8))
    local tiles_apart = d / 5
    example_print_log("5-unit tiles apart = " .. tiles_apart)
end

--@api: lurek.math.distanceSq
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    example_print_log("distanceSq = " .. d2)
    example_print_log("distanceSq to 6,8 = " .. lurek.math.distanceSq(0, 0, 6, 8))
    local exact_distance = lurek.math.sqrt(d2)
    example_print_log("distance from sq = " .. exact_distance)
end

--@api: lurek.math.angleBetween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.angleBetween(0, 0, 1, 0)
    example_print_log("angle to right = " .. a)
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    example_print_log("angle down = " .. b)
    local turn_delta = b - a
end

--@api: lurek.math.closestPointOnSegment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    example_print_log("closest on segment = " .. cx .. "," .. cy)
    example_print_log("value types = " .. type(cx) .. "," .. type(cy))
    local snap_distance = lurek.math.distance(5, 5, cx, cy)
    example_print_log("snap distance = " .. snap_distance)
end

--@api: lurek.math.lineIntersect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then example_print_log("lines cross at " .. ix .. "," .. iy) else example_print_log("lines are parallel") end
    example_print_log("value types = " .. type(ix) .. "," .. type(iy))
    local crossed = ix ~= nil and iy ~= nil
    example_print_log("crossed = " .. tostring(crossed))
end

--@api: lurek.math.segmentIntersectsSegment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, ix, iy = lurek.math.segmentIntersectsSegment( 0, 0, 10, 10, 0, 10, 10, 0 )
    if hit and ix then example_print_log("segments cross at " .. ix .. "," .. iy) else example_print_log("segments do not cross") end
    example_print_log("value types = " .. type(hit) .. "," .. type(ix) .. "," .. type(iy))
    local crossed = hit and ix ~= nil
    example_print_log("crossed = " .. tostring(crossed))
end

--@api: lurek.math.circleContainsPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    example_print_log("inside = " .. tostring(inside))
    example_print_log("outside = " .. tostring(lurek.math.circleContainsPoint(5, 5, 10, 20, 20)))
    local border = lurek.math.circleContainsPoint(5, 5, 10, 15, 5)
    example_print_log("border point = " .. tostring(border))
end

--@api: lurek.math.circleIntersectsCircle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    example_print_log("circles overlap = " .. tostring(hit))
    example_print_log("touching circles overlap = " .. tostring(lurek.math.circleIntersectsCircle(0, 0, 5, 10, 0, 5)))
    local separated_overlap = lurek.math.circleIntersectsCircle(0, 0, 5, 20, 0, 5)
    example_print_log("separated overlap = " .. tostring(separated_overlap))
end

--@api: lurek.math.circleIntersectsLine
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    example_print_log("circle/line hit = " .. tostring(hit))
    if hx1 then example_print_log("  hit1 = " .. hx1 .. "," .. hy1) end
    if hx2 then example_print_log("  hit2 = " .. hx2 .. "," .. hy2) end
    local two_hits = hx2 ~= nil and hy2 ~= nil
end

--@api: lurek.math.circleIntersectsSegment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    example_print_log("circle/seg hit = " .. tostring(hit))
    if hx1 then example_print_log("  seg hit1 = " .. hx1 .. "," .. hy1) end
    _ = hx2
    _ = hy2
end

--@api: lurek.math.pointInPolygon
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    example_print_log("inside = " .. tostring(inside) .. " outside = " .. tostring(outside))
    local edge = lurek.math.pointInPolygon(pts, 0, 5)
end

--@api: lurek.math.polygonArea
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    example_print_log("area = " .. area)
    local triangle_area = lurek.math.polygonArea({0, 0, 8, 0, 0, 8})
    example_print_log("triangle area = " .. triangle_area)
end

--@api: lurek.math.polygonCentroid
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    example_print_log("centroid = " .. cx .. "," .. cy)
    local cx2, cy2 = lurek.math.polygonCentroid({0, 0, 8, 0, 8, 8, 0, 8})
    example_print_log("square center = " .. cx2 .. "," .. cy2)
end

--@api: lurek.math.isConvex
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    example_print_log("square convex = " .. tostring(lurek.math.isConvex(square)))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    example_print_log("concave = " .. tostring(lurek.math.isConvex(concave)))
    local triangle = {0, 0, 6, 0, 3, 5}
end

--@api: lurek.math.convexHull
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    example_print_log("hull vertices = " .. #hull / 2)
    local input_points = #pts / 2
    example_print_log("input points = " .. input_points)
end

--@api: lurek.math.polygonClip
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    example_print_log("clipped vertices = " .. #clipped / 2)
    local original_points = #pts / 2
    example_print_log("original points = " .. original_points)
end

--@api: lurek.math.polygonUnion
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonUnion(a, b)
    example_print_log("union vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end

--@api: lurek.math.polygonIntersection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonIntersection(a, b)
    example_print_log("intersection vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end

--@api: lurek.math.polygonDifference
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonDifference(a, b)
    example_print_log("difference vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end

--@api: lurek.math.triangulate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    example_print_log("triangles = " .. #tris)
    local source_vertices = #pts / 2
    example_print_log("source vertices = " .. source_vertices)
end

--@api: lurek.math.delaunayTriangulate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    example_print_log("delaunay triangles = " .. #tris)
    local input_vertices = #pts / 2
    example_print_log("input vertices = " .. input_vertices)
end

--@api: lurek.math.bresenham
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = lurek.math.bresenham(0, 0, 5, 3)
    example_print_log("bresenham points = " .. #pts)
    for _, p in ipairs(pts) do
        example_print_log("  " .. p.x .. "," .. p.y)
    end
end

--@api: lurek.math.rectFromCenter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    example_print_log("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    example_print_log("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
    local center_x = x + w / 2
    example_print_log("center x = " .. center_x)
end

--@api: lurek.math.rectUnion
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    example_print_log("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    example_print_log("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
    local union_area = w * h
    example_print_log("union area = " .. union_area)
end

--@api: lurek.math.newBezierCurve
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    example_print_log("control points = " .. curve:getControlPointCount())
    local x, y = curve:evaluate(0.5)
    example_print_log("mid = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:evaluate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = curve:evaluate(0.25)
    example_print_log("t=0.25 = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end

--@api: LBezierCurve:evaluateAtDistance
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local length = curve:length()
    local x, y = curve:evaluateAtDistance(length * 0.5, 32)
    example_print_log("length = " .. length)
    example_print_log("halfway = " .. x .. "," .. y)
end

--@api: LBezierCurve:getControlPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local x, y = curve:getControlPoint(2)
    example_print_log("cp2 = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end

--@api: LBezierCurve:setControlPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:getControlPoint(2)
    curve:setControlPoint(2, 50, 80)
    local afterX, afterY = curve:getControlPoint(2)
    example_print_log("before = " .. beforeX .. "," .. beforeY)
    example_print_log("after = " .. afterX .. "," .. afterY)
end

--@api: LBezierCurve:insertControlPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    example_print_log("count before = " .. curve:getControlPointCount())
    curve:insertControlPoint(50, 50, 2)
    local x, y = curve:getControlPoint(2)
    example_print_log("inserted = " .. x .. "," .. y)
    example_print_log("count after = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:removeControlPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    example_print_log("count before = " .. curve:getControlPointCount())
    curve:removeControlPoint(2)
    example_print_log("count after = " .. curve:getControlPointCount())
    example_print_log("curve points = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:length
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    example_print_log("length = " .. curve:length())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end

--@api: LBezierCurve:render
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local points = curve:render(4)
    local sample = points[3]
    example_print_log("samples = " .. #points)
    example_print_log("sample 3 = " .. sample[1] .. "," .. sample[2])
end

--@api: LBezierCurve:getDerivative
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local derivative = curve:getDerivative()
    local x, y = derivative:evaluate(0.5)
    example_print_log("derivative control points = " .. derivative:getControlPointCount())
    example_print_log("tangent = " .. x .. "," .. y)
end

--@api: LBezierCurve:translate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:evaluate(0)
    curve:translate(10, 20)
    local afterX, afterY = curve:evaluate(0)
    example_print_log("before = " .. beforeX .. "," .. beforeY)
    example_print_log("after = " .. afterX .. "," .. afterY)
end

--@api: LBezierCurve:rotate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:rotate(lurek.math.pi / 2, 0, 0)
    local x, y = curve:getControlPoint(2)
    example_print_log("end point = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end

--@api: LBezierCurve:scale
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:scale(2, 0, 0)
    local x, y = curve:getControlPoint(2)
    example_print_log("end point = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end

--@api: lurek.math.catmullRom
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    example_print_log("points = " .. spline:len())
    local x, y = spline:sample(0.5)
    example_print_log("mid = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
end

--@api: LCatmullRom:sample
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sample(0.25)
    example_print_log("t=0.25 = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end

--@api: LCatmullRom:sampleSegment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sampleSegment(1, 0.5)
    example_print_log("segment 1 = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end

--@api: LCatmullRom:addPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}})
    example_print_log("before = " .. spline:len())
    spline:addPoint(150, 60)
    example_print_log("after = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
end

--@api: LCatmullRom:removePoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:removePoint(1)
    example_print_log("removed = " .. x .. "," .. y)
    example_print_log("after = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
end

--@api: lurek.math.hermite
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100)
    local x0, y0 = spline:sample(0)
    local xm, ym = spline:sample(0.5)
    local x1, y1 = spline:sample(1)
    example_print_log("start = " .. x0 .. "," .. y0)
    example_print_log("mid = " .. xm .. "," .. ym)
    example_print_log("end = " .. x1 .. "," .. y1)
end

--@api: lurek.math.vec2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    example_print_log("vec2 = " .. v.x .. "," .. v.y)
    example_print_log("heading = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: lurek.math.Vec2
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("vec2 = " .. v.x .. "," .. v.y)
    example_print_log("heading = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:length
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("length = " .. v:length())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec2:lengthSquared
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("lengthSq = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec2:normalize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local n = v:normalize()
    example_print_log("normalized = " .. n.x .. "," .. n.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:normalized
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    example_print_log("normalized = " .. n.x .. "," .. n.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:dot
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    example_print_log("dot = " .. a:dot(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end

--@api: LVec2:cross
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    example_print_log("cross = " .. a:cross(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end

--@api: LVec2:distance
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(3, 4)
    example_print_log("distance = " .. a:distance(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end

--@api: LVec2:angle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, 1)
    example_print_log("angle = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec2:lerp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    example_print_log("lerp = " .. mid.x .. "," .. mid.y)
    example_print_log("vector length = " .. a:length())
end

--@api: LVec2:rotate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(lurek.math.pi / 2)
    example_print_log("rotated = " .. r.x .. "," .. r.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:perpendicular
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    example_print_log("perp = " .. p.x .. "," .. p.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:reflect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, -1)
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    example_print_log("reflected = " .. ref.x .. "," .. ref.y)
    example_print_log("vector length = " .. v:length())
end

--@api: LVec2:fromAngle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(lurek.math.pi / 4)
    example_print_log("fromAngle(pi/4) = " .. unit.x .. "," .. unit.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: lurek.math.vec3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(1, 2, 3)
    example_print_log("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    example_print_log("lengthSquared = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: lurek.math.Vec3
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    example_print_log("lengthSquared = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: LVec3:length
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 2)
    example_print_log("length = " .. v:length())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end

--@api: LVec3:lengthSquared
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 2)
    example_print_log("lengthSq = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end

--@api: LVec3:normalize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    example_print_log("normalized = " .. n.x .. "," .. n.y .. "," .. n.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: LVec3:dot
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    example_print_log("dot = " .. a:dot(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalize().x)
end

--@api: LVec3:cross
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    local c = a:cross(b)
    example_print_log("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
    example_print_log("vector length = " .. a:length())
end

--@api: LVec3:add
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    example_print_log("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    example_print_log("vector length = " .. a:length())
end

--@api: LVec3:sub
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local diff = a:sub(b)
    example_print_log("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    example_print_log("vector length = " .. a:length())
end

--@api: LVec3:scale
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(1, 2, 3)
    local scaled = v:scale(2)
    example_print_log("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: LVec3:distance
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    example_print_log("distance = " .. a:distance(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalize().x)
end

--@api: LVec3:lerp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    local mid = a:lerp(b, 0.5)
    example_print_log("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
    example_print_log("vector length = " .. a:length())
end

--@api: LVec3:splat
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    example_print_log("splat = " .. s.x .. "," .. s.y .. "," .. s.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: lurek.math.newTransform
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 200, lurek.math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    example_print_log("origin transformed = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, t:transformPoint(0, 0)))
end

--@api: LTransform:translate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:translate(50, 50)
    local x, y = t:transformPoint(0, 0)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:rotate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:rotate(lurek.math.pi / 2)
    local x, y = t:transformPoint(10, 0)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:scale
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:scale(2, 3)
    local x, y = t:transformPoint(10, 5)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:shear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:shear(0.25, 0)
    local x, y = t:transformPoint(10, 10)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:transformPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    example_print_log("forward = " .. fx .. "," .. fy)
    example_print_log("inverse = " .. ix .. "," .. iy)
end

--@api: LTransform:inverseTransformPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    example_print_log("forward = " .. fx .. "," .. fy)
    example_print_log("inverse = " .. ix .. "," .. iy)
end

--@api: LTransform:clone
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 0.5)
    local clone = t:clone()
    local x, y = clone:transformPoint(0, 0)
    example_print_log("clone point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:inverse
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 0.5)
    local inv = t:inverse()
    local x, y = t:transformPoint(5, 0)
    local rx, ry = inv:transformPoint(x, y)
    example_print_log("roundtrip = " .. rx .. "," .. ry)
end

--@api: LTransform:decompose
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    example_print_log("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, t:transformPoint(0, 0)))
end

--@api: LTransform:getMatrix
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    example_print_log("matrix elements = " .. #m)
    example_print_log("first row = " .. m[1] .. "," .. m[2] .. "," .. m[3])
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x, y = t:transformPoint(10, 10)
    example_print_log("after reset = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: LTransform:setTransformation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:setTransformation(0, 0, lurek.math.pi, 1, 1)
    local x, y = t:transformPoint(10, 0)
    example_print_log("after set = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end

--@api: lurek.math.newRandomGenerator
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(42)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:random
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("random = " .. rng:random())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:randomFloat
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("float = " .. rng:randomFloat(1.0, 5.0))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:randomInt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("int = " .. rng:randomInt(1, 100))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:randomNormal
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("normal = " .. rng:randomNormal(1.0, 0.0))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:setSeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:getState
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(999)
    example_print_log("state = " .. rng:getState())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:setState
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    local first = rng:random()
    local state = rng:getState()
    local skipped = rng:random()
    rng:setState(state)
    local restored = rng:random()
    example_print_log("restored = " .. tostring(skipped == restored))
    example_print_log("first = " .. first)
end

--@api: lurek.math.newTween
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0, "inOutCubic")
    example_print_log("duration = " .. tw:getDuration())
    example_print_log("easing = " .. tw:getEasingName())
    example_print_log("tween time = " .. tw:getTime())
    example_print_log("value count = " .. tw:getValueCount())
end

--@api: LTween:addValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    example_print_log("index = " .. index)
    example_print_log("channels = " .. tw:getValueCount())
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:getValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    tw:setTime(0.5)
    example_print_log("value = " .. tw:getValue(index))
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:getAllValues
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    tw:setTime(0.5)
    local values = tw:getAllValues()
    example_print_log("count = " .. #values)
    example_print_log("first = " .. values[1])
end

--@api: LTween:getValueCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    example_print_log("channels = " .. tw:getValueCount())
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    example_print_log("done = " .. tostring(done))
    example_print_log("value = " .. tw:getValue(1))
end

--@api: LTween:isComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(1.1)
    example_print_log("complete = " .. tostring(tw:isComplete()))
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(0.5)
    tw:reset()
    example_print_log("clock = " .. tw:getClock())
end

--@api: LTween:set
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    example_print_log("value = " .. tw:getValue(1))
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:setTime
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("time = " .. tw:getTime())
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:getTime
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("time = " .. tw:getTime())
    example_print_log("tween time = " .. tw:getTime())
end

--@api: LTween:getClock
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("clock = " .. tw:getClock())
    example_print_log("tween time = " .. tw:getTime())
end

--@api: lurek.math.aabbTree
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    example_print_log("len = " .. tree:len())
    example_print_log("empty = " .. tostring(tree:isEmpty()))
end

--@api: LAabbTree:query
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    example_print_log("query hits = " .. #hits)
end

--@api: LAabbTree:queryPoint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:queryPoint(7, 7)
    example_print_log("point hits = " .. #hits)
end

--@api: LAabbTree:contains
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    example_print_log("contains 1 = " .. tostring(tree:contains(1)))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end

--@api: LAabbTree:remove
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:remove(2)
    example_print_log("len = " .. tree:len())
end

--@api: LAabbTree:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:update(1, 20, 20, 30, 30)
    local hits = tree:query(19, 19, 21, 21)
    example_print_log("query hits = " .. #hits)
end

--@api: lurek.math.newSpatialHash
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    example_print_log("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
end

--@api: LSpatialHash:queryRect
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryRect(0, 0, 12, 12)
    example_print_log("rect hits = " .. #hits)
end

--@api: LSpatialHash:queryCircle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryCircle(5, 5, 10)
    example_print_log("circle hits = " .. #hits)
end

--@api: LSpatialHash:querySegment
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:querySegment(0, 0, 50, 50)
    example_print_log("segment hits = " .. #hits)
end

--@api: LSpatialHash:remove
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:remove("b")
    example_print_log("items = " .. sh:getItemCount())
end

--@api: LSpatialHash:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:update("a", 200, 200, 10, 10)
    local hits = sh:queryRect(190, 190, 20, 20)
    example_print_log("rect hits = " .. #hits)
end

--@api: lurek.math.newRectPacker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x, y = rp:pack(32, 32, "icon1")
    example_print_log("icon1 = " .. tostring(x) .. "," .. tostring(y))
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("occupancy = " .. rp:occupancy())
end

--@api: lurek.math.newCircle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(50, 50, 25)
    example_print_log("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    example_print_log("area = " .. c:area())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
end

--@api: LCircle:contains
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local circle = lurek.math.newCircle(0, 0, 10)
    example_print_log("contains = " .. tostring(circle:contains(5, 5)))
    example_print_log("radius = " .. circle:radius())
    example_print_log("center x = " .. circle:x())
    example_print_log("center y = " .. circle:y())
end

--@api: LCircle:intersects
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newCircle(0, 0, 10)
    local b = lurek.math.newCircle(15, 0, 10)
    example_print_log("intersects = " .. tostring(a:intersects(b)))
    example_print_log("radius = " .. a:radius())
    example_print_log("center x = " .. a:x())
end

--@api: LCircle:aabb
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c1 = lurek.math.newCircle(0, 0, 10)
    local minx, miny, maxx, maxy = c1:aabb()
    example_print_log("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
    example_print_log("radius = " .. c1:radius())
    example_print_log("center x = " .. c1:x())
end

--@api: lurek.math.voronoi
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cells = lurek.math.voronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    example_print_log("cells = " .. #cells)
    example_print_log("has first cell = " .. tostring(cells[1] ~= nil))
    local first_size = cells[1] and #cells[1] or 0
    example_print_log("first cell points = " .. first_size)
end

--@api: lurek.math.applyEasing
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local linear = lurek.math.applyEasing("linear", 0.5)
    local eased = lurek.math.applyEasing("inOutCubic", 0.5)
    example_print_log("linear = " .. linear)
    example_print_log("inOutCubic = " .. eased)
    local finish = lurek.math.applyEasing("inOutCubic", 1.0)
end

--@api: lurek.math.inBack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inBack(0.75))
    example_print_log("finish = " .. lurek.math.inBack(1.0))
    local ease_start = lurek.math.inBack(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inBounce
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inBounce(0.75))
    example_print_log("finish = " .. lurek.math.inBounce(1.0))
    local ease_start = lurek.math.inBounce(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inCubic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inCubic(0.75))
    example_print_log("finish = " .. lurek.math.inCubic(1.0))
    local ease_start = lurek.math.inCubic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inElastic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inElastic(0.75))
    example_print_log("finish = " .. lurek.math.inElastic(1.0))
    local ease_start = lurek.math.inElastic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inExpo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inExpo(0.75))
    example_print_log("finish = " .. lurek.math.inExpo(1.0))
    local ease_start = lurek.math.inExpo(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inQuad
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inQuad(0.75))
    example_print_log("finish = " .. lurek.math.inQuad(1.0))
    local ease_start = lurek.math.inQuad(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inQuart
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inQuart(0.75))
    example_print_log("finish = " .. lurek.math.inQuart(1.0))
    local ease_start = lurek.math.inQuart(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inSine
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inSine(0.75))
    example_print_log("finish = " .. lurek.math.inSine(1.0))
    local ease_start = lurek.math.inSine(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.linear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.linear(0.25))
    example_print_log("t=0.75 = " .. lurek.math.linear(0.75))
    example_print_log("finish = " .. lurek.math.linear(1.0))
    local ease_start = lurek.math.linear(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outBack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outBack(0.75))
    example_print_log("finish = " .. lurek.math.outBack(1.0))
    local ease_start = lurek.math.outBack(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outBounce
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outBounce(0.75))
    example_print_log("finish = " .. lurek.math.outBounce(1.0))
    local ease_start = lurek.math.outBounce(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outCubic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outCubic(0.75))
    example_print_log("finish = " .. lurek.math.outCubic(1.0))
    local ease_start = lurek.math.outCubic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outElastic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outElastic(0.75))
    example_print_log("finish = " .. lurek.math.outElastic(1.0))
    local ease_start = lurek.math.outElastic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outExpo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outExpo(0.75))
    example_print_log("finish = " .. lurek.math.outExpo(1.0))
    local ease_start = lurek.math.outExpo(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outQuad
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outQuad(0.75))
    example_print_log("finish = " .. lurek.math.outQuad(1.0))
    local ease_start = lurek.math.outQuad(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outQuart
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outQuart(0.75))
    example_print_log("finish = " .. lurek.math.outQuart(1.0))
    local ease_start = lurek.math.outQuart(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.outSine
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outSine(0.75))
    example_print_log("finish = " .. lurek.math.outSine(1.0))
    local ease_start = lurek.math.outSine(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutBack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutBack(0.75))
    example_print_log("finish = " .. lurek.math.inOutBack(1.0))
    local ease_start = lurek.math.inOutBack(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutBounce
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutBounce(0.75))
    example_print_log("finish = " .. lurek.math.inOutBounce(1.0))
    local ease_start = lurek.math.inOutBounce(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutCubic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutCubic(0.75))
    example_print_log("finish = " .. lurek.math.inOutCubic(1.0))
    local ease_start = lurek.math.inOutCubic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutElastic
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutElastic(0.75))
    example_print_log("finish = " .. lurek.math.inOutElastic(1.0))
    local ease_start = lurek.math.inOutElastic(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutExpo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutExpo(0.75))
    example_print_log("finish = " .. lurek.math.inOutExpo(1.0))
    local ease_start = lurek.math.inOutExpo(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutQuad
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutQuad(0.75))
    example_print_log("finish = " .. lurek.math.inOutQuad(1.0))
    local ease_start = lurek.math.inOutQuad(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutQuart
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutQuart(0.75))
    example_print_log("finish = " .. lurek.math.inOutQuart(1.0))
    local ease_start = lurek.math.inOutQuart(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: lurek.math.inOutSine
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutSine(0.75))
    example_print_log("finish = " .. lurek.math.inOutSine(1.0))
    local ease_start = lurek.math.inOutSine(0.0)
    example_print_log("start = " .. ease_start)
end

--@api: LRandomGenerator:getSeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("type = " .. rng:type())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end

--@api: LRandomGenerator:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("typeOf = " .. tostring(rng:typeOf("LRandomGenerator")))
    example_print_log("type = " .. tostring(rng:type()))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:roll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    local d20 = rng:roll(20)
    example_print_log("d20 = " .. d20)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollN
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(2)
    local dice = rng:rollN(3, 6)
    example_print_log("3d6 = " .. dice[1] .. ", " .. dice[2] .. ", " .. dice[3])
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollSum
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(3)
    local total = rng:rollSum(4, 6)
    example_print_log("4d6 sum = " .. total)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollKeepHighest
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(4)
    local stat = rng:rollKeepHighest(4, 6, 3)
    example_print_log("4d6 keep 3 highest = " .. stat)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollKeepLowest
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(5)
    local penalty = rng:rollKeepLowest(4, 6, 3)
    example_print_log("4d6 keep 3 lowest = " .. penalty)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollAdvantage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(6)
    local adv = rng:rollAdvantage(20)
    example_print_log("d20 advantage = " .. adv)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollDisadvantage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(7)
    local dis = rng:rollDisadvantage(20)
    example_print_log("d20 disadvantage = " .. dis)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:rollExploding
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(8)
    local ex = rng:rollExploding(3, 6)
    example_print_log("3d6 exploding = " .. ex)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:countSuccesses
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(9)
    local hits = rng:countSuccesses(5, 10, 7)
    example_print_log("5d10 successes (7+) = " .. hits)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: LRandomGenerator:chance
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(10)
    local crit = rng:chance(0.05)
    example_print_log("critical hit (5%) = " .. tostring(crit))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end

--@api: lurek.math.geometricVoronoi
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cells = lurek.math.geometricVoronoi({{x = 0.2, y = 0.3}, {x = 0.7, y = 0.8}, {x = 0.5, y = 0.1}})
    example_print_log("cells = " .. #cells)
    example_print_log("has first cell = " .. tostring(cells[1] ~= nil))
    local first_size = cells[1] and #cells[1] or 0
    example_print_log("first cell points = " .. first_size)
end

--@api: LAabbTree:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:clear()
    example_print_log("empty = " .. tostring(tree:isEmpty()))
    example_print_log("tree len = " .. tree:len())
end

--@api: LAabbTree:insert
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    example_print_log("len = " .. tree:len())
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end

--@api: LAabbTree:isEmpty
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log("empty = " .. tostring(tree:isEmpty()))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
    example_print_log("query origin hits = " .. #tree:query(0, 0, 1, 1))
end

--@api: LAabbTree:len
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    example_print_log("len = " .. tree:len())
    example_print_log("tree len = " .. tree:len())
end

--@api: LAabbTree:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log(tree:type())
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
    example_print_log("query origin hits = " .. #tree:query(0, 0, 1, 1))
end

--@api: LAabbTree:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log(tostring(tree:typeOf("LAabbTree")))
    example_print_log("type = " .. tostring(tree:type()))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end

--@api: LBezierCurve:getControlPointCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log("count = " .. curve:getControlPointCount())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end

--@api: LBezierCurve:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log(curve:type())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end

--@api: LBezierCurve:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log(tostring(curve:typeOf("LBezierCurve")))
    example_print_log("type = " .. tostring(curve:type()))
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end

--@api: LCatmullRom:len
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log("len = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
    example_print_log("sample y at 0.5 = " .. select(2, spline:sample(0.5)))
end

--@api: LCatmullRom:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log(spline:type())
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
    example_print_log("sample y at 0.5 = " .. select(2, spline:sample(0.5)))
end

--@api: LCatmullRom:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log(tostring(spline:typeOf("LCatmullRom")))
    example_print_log("type = " .. tostring(spline:type()))
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end

--@api: LCircle:area
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("area = " .. c:area())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LCircle:perimeter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("perimeter = " .. c:perimeter())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LCircle:radius
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("radius = " .. c:radius())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LCircle:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log(c:type())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LCircle:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log(tostring(c:typeOf("LCircle")))
    example_print_log("type = " .. tostring(c:type()))
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
end

--@api: LCircle:x
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("x = " .. c:x())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LCircle:y
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("y = " .. c:y())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end

--@api: LHermite:sample
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local x, y = h:sample(0.5)
    example_print_log("sample = " .. x .. "," .. y)
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
end

--@api: LHermite:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    example_print_log(h:type())
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
    example_print_log("sample x at 0.75 = " .. select(1, h:sample(0.75)))
end

--@api: LHermite:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    example_print_log(tostring(h:typeOf("LHermite")))
    example_print_log("type = " .. tostring(h:type()))
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
end

--@api: LRectPacker:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    rp:clear()
    example_print_log("packed = " .. #rp:getPacked())
    example_print_log("occupancy = " .. rp:occupancy())
end

--@api: LRectPacker:getPacked
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    local packed = rp:getPacked()
    example_print_log("packed = " .. #packed)
    example_print_log("occupancy = " .. rp:occupancy())
end

--@api: LRectPacker:occupancy
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("packed count = " .. #rp:getPacked())
end

--@api: LRectPacker:pack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    local x, y = rp:pack(64, 64, "box")
    example_print_log("pack = " .. tostring(x) .. "," .. tostring(y))
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("packed count = " .. #rp:getPacked())
end

--@api: LSpatialHash:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    sh:clear()
    example_print_log("count = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
end

--@api: LSpatialHash:getCellSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
    example_print_log("origin hits = " .. #sh:queryRect(0, 0, 1, 1))
end

--@api: LSpatialHash:getItemCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    example_print_log("items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end

--@api: LSpatialHash:insert
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    example_print_log("items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end

--@api: LSpatialHash:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log(sh:type())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
    example_print_log("origin hits = " .. #sh:queryRect(0, 0, 1, 1))
end

--@api: LSpatialHash:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log(tostring(sh:typeOf("LSpatialHash")))
    example_print_log("type = " .. tostring(sh:type()))
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end

--@api: LTransform:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tf = lurek.math.newTransform()
    example_print_log(tf:type())
    example_print_log("origin x = " .. select(1, tf:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, tf:transformPoint(0, 0)))
    example_print_log("unit x after transform = " .. select(1, tf:transformPoint(1, 0)))
end

--@api: LTransform:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tf = lurek.math.newTransform()
    example_print_log(tostring(tf:typeOf("LTransform")))
    example_print_log("type = " .. tostring(tf:type()))
    example_print_log("origin x = " .. select(1, tf:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, tf:transformPoint(0, 0)))
end

--@api: LVec2:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log(v:type())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec2:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log(v:typeOf("LVec2"))
    example_print_log("type = " .. tostring(v:type()))
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end

--@api: LVec2:x
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("x=" .. v.x)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec2:y
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("y=" .. v.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end

--@api: LVec3:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log(v:type())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end

--@api: LVec3:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log(tostring(v:typeOf("LVec3")))
    example_print_log("type = " .. tostring(v:type()))
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end

--@api: lurek.math.easingNames
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local names = lurek.math.easingNames()
    example_print_log("easing count = " .. #names)
    example_print_log("contains linear = " .. tostring(names[1] ~= nil))
    local first_name = names[1] or "none"
    example_print_log("first easing = " .. first_name)
end

--@api: lurek.math.cubicBezier
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local y = lurek.math.cubicBezier(0.25, 0.1, 0.25, 1.0, 0.5)
    example_print_log("cubicBezier(0.5) = " .. y)
    example_print_log("ease sample at 0.2 = " .. lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.2))
    local late_curve = lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.8)
    example_print_log("ease in-out at 0.8 = " .. late_curve)
end

--@api: lurek.math.newLootTable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable({ seed = 42 })
    loot:add("common", 10.0, { tier = "c" })
    loot:add("rare", 1.0, { tier = "r" })
    loot:build()
    local pick = loot:sample()
    example_print_log("loot pick = " .. tostring(pick and pick.id))
end

--@api: lurek.math.lootFromList
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.lootFromList({
        { id = "gold", weight = 20.0, meta = { kind = "currency" } },
        { id = "gem", weight = 2.0, meta = { kind = "currency" } },
    })
    example_print_log("fromList count = " .. loot:entryCount())
end

--@api: lurek.math.newPityTracker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable(7)
    loot:add("common", 100.0)
    loot:add("rare", 0.0, { tier = "r" })
    loot:build()

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:notice("common")
    local id = lurek.math.sampleWithPity(loot, pity)
    example_print_log("pity sample = " .. tostring(id))
end

--@api: lurek.math.sampleWithPity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable(9)
    loot:add("a", 1.0)
    loot:build()
    local pity = lurek.math.newPityTracker("a", 1)
    local id = lurek.math.sampleWithPity(loot, pity)
    example_print_log("sampleWithPity = " .. tostring(id))
end

--@api: LLootTable:merge
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    local b = lurek.math.newLootTable(10)
    a:add("a", 1.0)
    b:add("b", 1.0)
    a:merge(b)
    a:build()
    example_print_log("merged entries = " .. tostring(a:entryCount()))
end

--@api: LLootTable:save
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    example_print_log("save blob bytes = " .. tostring(#blob))
end

--@api: LLootTable:restore
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    local restored = lurek.math.newLootTable()
    restored:restore(blob)
    example_print_log("restore count = " .. tostring(restored:entryCount()))
end

--@api: LPityTracker:save
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    example_print_log("pity save blob = " .. tostring(pity_blob))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end

--@api: LPityTracker:restore
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    pity:restore(pity_blob)
    example_print_log("pity restore ok")
    example_print_log("counter = " .. tostring(pity:counter()))
end

--@api: lurek.math.lootFromToml
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.lootFromToml("save/loot_table_unit_test.toml")
    example_print_log("lootFromToml entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample preview = " .. tostring(tbl:sample()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end

--@api: LLootTable:add
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    example_print_log("add ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end

--@api: LLootTable:build
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    example_print_log("build ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end

--@api: LLootTable:entryCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    example_print_log("entryCount = " .. tostring(tbl:entryCount()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end

--@api: LLootTable:remove
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:remove("wood")
    example_print_log("remove ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end

--@api: LLootTable:sample
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    example_print_log("sample = " .. tostring(tbl:sample()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end

--@api: LLootTable:sampleN
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleN(2)
    example_print_log("sampleN = " .. tostring(#picks))
end

--@api: LLootTable:sampleUnique
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleUnique(2)
    example_print_log("sampleUnique = " .. tostring(#picks))
end

--@api: LLootTable:setSeed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:setSeed(7)
    example_print_log("setSeed ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end

--@api: LLootTable:setWeight
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:setWeight("wood", 2.0)
    example_print_log("setWeight ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end

--@api: LLootTable:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    example_print_log("type = " .. tostring(tbl:type()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
    example_print_log("save blob exists = " .. tostring(tbl:save() ~= nil))
end

--@api: LLootTable:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    example_print_log("typeOf = " .. tostring(tbl:typeOf("LLootTable")))
    example_print_log("type = " .. tostring(tbl:type()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end

--@api: LPityTracker:counter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
    example_print_log("export exists = " .. tostring(pity:export() ~= nil))
end

--@api: LPityTracker:export
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    example_print_log("export ok = " .. tostring(snapshot ~= nil))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end

--@api: LPityTracker:import
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    pity:import(snapshot)
    example_print_log("import ok")
    example_print_log("counter = " .. tostring(pity:counter()))
end

--@api: LPityTracker:isPrimed
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 1)
    pity:notice("common")
    example_print_log("isPrimed = " .. tostring(pity:isPrimed()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end

--@api: LPityTracker:notice
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    example_print_log("notice ok")
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end

--@api: LPityTracker:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:reset()
    example_print_log("reset counter = " .. tostring(pity:counter()))
    example_print_log("counter = " .. tostring(pity:counter()))
end

--@api: LPityTracker:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("type = " .. tostring(pity:type()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
    example_print_log("export exists = " .. tostring(pity:export() ~= nil))
end

--@api: LPityTracker:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("typeOf = " .. tostring(pity:typeOf("LPityTracker")))
    example_print_log("type = " .. tostring(pity:type()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
