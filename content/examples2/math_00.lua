--- Math Module Part 1: basic math functions and trigonometry

--@api-stub: lurek.math.pi
--@api-stub: lurek.math.tau
-- Mathematical constants.
do
    print("pi = " .. lurek.math.pi)
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
--@api-stub: lurek.math.max
-- Returns minimum or maximum.
do
    print("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
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

print("math_00.lua")
