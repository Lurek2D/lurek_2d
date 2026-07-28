-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_math_core_unit.lua
do
-- Canonical unit coverage for lurek.math.

local function vec2(x, y)
    return lurek.math.vec2(x, y)
end

local function vec3(x, y, z)
    return lurek.math.vec3(x, y, z)
end

local function rng(seed)
    return lurek.math.newRandomGenerator(seed)
end

local function transform()
    return lurek.math.newTransform()
end

local function bezier(points)
    return lurek.math.newBezierCurve(points)
end

local function spline(points)
    return lurek.math.catmullRom(points)
end

local function tween(duration, easing_name)
    return lurek.math.newTween(duration, easing_name)
end

local function spatial_hash(cell_size)
    return lurek.math.newSpatialHash(cell_size)
end

local function circle(x, y, radius)
    return lurek.math.newCircle(x, y, radius)
end

local function rect_packer(width, height, padding)
    return lurek.math.newRectPacker(width, height, padding)
end

local function aabb_tree()
    return lurek.math.aabbTree()
end

local function point_list(...)
    local values = { ... }
    local points = {}
    for i = 1, #values, 2 do
        points[#points + 1] = { x = values[i], y = values[i + 1] }
    end
    return points
end

local function list_contains(list, needle)
    for i = 1, #list do
        if list[i] == needle then
            return true
        end
    end
    return false
end

-- @describe constants and scalars
describe("math constants and scalars", function()
    -- @covers lurek.math.rad
    it("rad converts degrees to radians", function()
        expect_near(lurek.math.pi, lurek.math.rad(180), 0.0001)
    end)

    -- @covers lurek.math.deg
    it("deg converts radians to degrees", function()
        expect_near(180, lurek.math.deg(lurek.math.pi), 0.0001)
    end)

    -- @covers lurek.math.sin
    it("sin of pi over two is one", function()
        expect_near(1, lurek.math.sin(lurek.math.pi / 2), 0.0001)
    end)

    -- @covers lurek.math.cos
    it("cos of pi is negative one", function()
        expect_near(-1, lurek.math.cos(lurek.math.pi), 0.0001)
    end)

    -- @covers lurek.math.tan
    it("tan of zero is zero", function()
        expect_near(0, lurek.math.tan(0), 0.0001)
    end)

    -- @covers lurek.math.asin
    it("asin of one is pi over two", function()
        expect_near(lurek.math.pi / 2, lurek.math.asin(1), 0.0001)
    end)

    -- @covers lurek.math.acos
    it("acos of one is zero", function()
        expect_near(0, lurek.math.acos(1), 0.0001)
    end)

    -- @covers lurek.math.atan
    it("atan of one is pi over four", function()
        expect_near(lurek.math.pi / 4, lurek.math.atan(1), 0.0001)
    end)

    -- @covers lurek.math.atan2
    it("atan2 returns pi over two for an upward vector", function()
        expect_near(lurek.math.pi / 2, lurek.math.atan2(1, 0), 0.0001)
    end)

    -- @covers lurek.math.sqrt
    it("sqrt returns the principal root", function()
        expect_near(3, lurek.math.sqrt(9), 0.0001)
    end)

    -- @covers lurek.math.abs
    it("abs returns the absolute value", function()
        expect_near(5, lurek.math.abs(-5), 0.0001)
    end)

    -- @covers lurek.math.floor
    it("floor rounds toward negative infinity", function()
        expect_equal(-3, lurek.math.floor(-2.1))
    end)

    -- @covers lurek.math.ceil
    it("ceil rounds toward positive infinity", function()
        expect_equal(4, lurek.math.ceil(3.2))
    end)

    -- @covers lurek.math.round
    it("round rounds to the nearest integer", function()
        expect_equal(3, lurek.math.round(2.7))
    end)

    -- @covers lurek.math.exp
    it("exp of zero is one", function()
        expect_near(1, lurek.math.exp(0), 0.0001)
    end)

    -- @covers lurek.math.log
    it("log inverts exp for e", function()
        expect_near(1, lurek.math.log(lurek.math.exp(1)), 0.0001)
    end)

    -- @covers lurek.math.pow
    it("pow raises to a power", function()
        expect_near(8, lurek.math.pow(2, 3), 0.0001)
    end)

    -- @covers lurek.math.min
    it("min returns the smaller value", function()
        expect_equal(3, lurek.math.min(3, 7))
    end)

    -- @covers lurek.math.max
    it("max returns the larger value", function()
        expect_equal(7, lurek.math.max(3, 7))
    end)

    -- @covers lurek.math.fmod
    it("fmod returns the floating remainder", function()
        expect_near(1, lurek.math.fmod(7, 3), 0.0001)
    end)

    -- @covers lurek.math.distance
    it("distance computes euclidean distance", function()
        expect_near(5, lurek.math.distance(0, 0, 3, 4), 0.0001)
    end)

    -- @covers lurek.math.distanceSq
    it("distanceSq avoids the square root", function()
        expect_near(25, lurek.math.distanceSq(0, 0, 3, 4), 0.0001)
    end)

    -- @covers lurek.math.lerp
    it("lerp interpolates between endpoints", function()
        expect_near(5, lurek.math.lerp(0, 10, 0.5), 0.0001)
    end)

    -- @covers lurek.math.remap
    it("remap translates values between ranges", function()
        expect_near(50, lurek.math.remap(5, 0, 10, 0, 100), 0.0001)
    end)

    -- @covers lurek.math.angleBetween
    it("angleBetween returns zero for the x axis", function()
        expect_near(0, lurek.math.angleBetween(0, 0, 1, 0), 0.0001)
    end)
end)

-- @describe easing and randomness
describe("math easing and randomness", function()
    -- @covers lurek.math.applyEasing
    it("applyEasing matches direct easing calls", function()
        expect_near(lurek.math.outQuad(0.5), lurek.math.applyEasing("outQuad", 0.5), 0.0001)
    end)

    -- @covers lurek.math.linear
    it("linear is the identity easing", function()
        expect_near(0.5, lurek.math.linear(0.5), 0.0001)
    end)

    -- @covers lurek.math.inQuad
    it("inQuad eases in quadratically", function()
        expect_near(0.25, lurek.math.inQuad(0.5), 0.0001)
    end)

    -- @covers lurek.math.outQuad
    it("outQuad eases out quadratically", function()
        expect_near(0.75, lurek.math.outQuad(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutQuad
    it("inOutQuad eases symmetrically around the midpoint", function()
        expect_near(0.125, lurek.math.inOutQuad(0.25), 0.0001)
    end)

    -- @covers lurek.math.inCubic
    it("inCubic cubes the input", function()
        expect_near(0.125, lurek.math.inCubic(0.5), 0.0001)
    end)

    -- @covers lurek.math.outCubic
    it("outCubic decelerates to the target", function()
        expect_near(0.875, lurek.math.outCubic(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutCubic
    it("inOutCubic is eased at quarter progress", function()
        expect_near(0.0625, lurek.math.inOutCubic(0.25), 0.0001)
    end)

    -- @covers lurek.math.inQuart
    it("inQuart raises the input to the fourth power", function()
        expect_near(0.0625, lurek.math.inQuart(0.5), 0.0001)
    end)

    -- @covers lurek.math.outQuart
    it("outQuart approaches one quickly", function()
        expect_near(0.9375, lurek.math.outQuart(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutQuart
    it("inOutQuart is heavily eased near the start", function()
        expect_near(0.03125, lurek.math.inOutQuart(0.25), 0.0001)
    end)

    -- @covers lurek.math.inSine
    it("inSine matches cosine-based ease in", function()
        expect_near(1 - math.cos(lurek.math.pi / 4), lurek.math.inSine(0.5), 0.0001)
    end)

    -- @covers lurek.math.outSine
    it("outSine matches sine-based ease out", function()
        expect_near(math.sin(lurek.math.pi / 4), lurek.math.outSine(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutSine
    it("inOutSine returns half at the midpoint", function()
        expect_near(0.5, lurek.math.inOutSine(0.5), 0.0001)
    end)

    -- @covers lurek.math.inExpo
    it("inExpo clamps to zero at the start", function()
        expect_near(0.0, lurek.math.inExpo(0.0), 0.0001)
    end)

    -- @covers lurek.math.outExpo
    it("outExpo clamps to one at the end", function()
        expect_near(1.0, lurek.math.outExpo(1.0), 0.0001)
    end)

    -- @covers lurek.math.inOutExpo
    it("inOutExpo crosses the midpoint at one half", function()
        expect_near(0.5, lurek.math.inOutExpo(0.5), 0.0001)
    end)

    -- @covers lurek.math.inElastic
    it("inElastic clamps to zero at the start", function()
        expect_near(0.0, lurek.math.inElastic(0.0), 0.0001)
    end)

    -- @covers lurek.math.outElastic
    it("outElastic clamps to one at the end", function()
        expect_near(1.0, lurek.math.outElastic(1.0), 0.0001)
    end)

    -- @covers lurek.math.outBounce
    it("outBounce settles at one", function()
        expect_near(1.0, lurek.math.outBounce(1.0), 0.0001)
    end)

    -- @covers lurek.math.inBounce
    it("inBounce starts at zero", function()
        expect_near(0.0, lurek.math.inBounce(0.0), 0.0001)
    end)

    -- @covers lurek.math.inBack
    it("inBack starts at zero", function()
        expect_near(0.0, lurek.math.inBack(0.0), 0.0001)
    end)

    -- @covers lurek.math.outBack
    it("outBack ends at one", function()
        expect_near(1.0, lurek.math.outBack(1.0), 0.0001)
    end)

    -- @covers lurek.math.inOutElastic
    it("inOutElastic crosses the midpoint at one half", function()
        expect_near(0.5, lurek.math.inOutElastic(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutBounce
    it("inOutBounce crosses the midpoint at one half", function()
        expect_near(0.5, lurek.math.inOutBounce(0.5), 0.0001)
    end)

    -- @covers lurek.math.inOutBack
    it("inOutBack crosses the midpoint at one half", function()
        expect_near(0.5, lurek.math.inOutBack(0.5), 0.0001)
    end)

    -- @covers lurek.math.easingNames
    it("easingNames includes canonical built in names", function()
        local names = lurek.math.easingNames()
        expect_true(list_contains(names, "linear"))
        expect_true(list_contains(names, "easeInQuad"))
    end)

    -- @covers lurek.math.cubicBezier
    it("cubicBezier acts like identity for linear control points", function()
        expect_near(0.5, lurek.math.cubicBezier(0.0, 0.0, 1.0, 1.0, 0.5), 0.0001)
    end)

    -- @covers lurek.math.random
    it("random returns values in the unit interval", function()
        local value = lurek.math.random()
        expect_true(value >= 0 and value < 1)
    end)

    -- @covers lurek.math.randomInt
    it("randomInt returns an integer in range", function()
        local value = lurek.math.randomInt(5, 10)
        expect_true(value >= 5 and value <= 10 and value == math.floor(value))
    end)

    -- @covers lurek.math.newRandomGenerator
    it("newRandomGenerator creates userdata", function()
        expect_type("userdata", rng(42))
    end)

    -- @covers LRandomGenerator:random
    it("random is deterministic for the same seed", function()
        expect_near(rng(42):random(), rng(42):random(), 0.000001)
    end)

    -- @covers LRandomGenerator:randomFloat
    it("randomFloat stays within the requested range", function()
        local value = rng(7):randomFloat(2.0, 5.0)
        expect_true(value >= 2.0 and value <= 5.0)
    end)

    -- @covers LRandomGenerator:randomInt
    it("randomInt method stays within the requested range", function()
        local value = rng(9):randomInt(3, 6)
        expect_true(value >= 3 and value <= 6)
    end)

    -- @covers LRandomGenerator:randomNormal
    it("randomNormal honors zero standard deviation", function()
        expect_near(5.0, rng(11):randomNormal(0.0, 5.0), 0.0001)
    end)

    -- @covers LRandomGenerator:getSeed
    it("getSeed returns the configured seed", function()
        expect_equal(42, rng(42):getSeed())
    end)

    -- @covers LRandomGenerator:setSeed
    it("setSeed resets the generator state", function()
        local generator = rng(42)
        generator:random()
        generator:setSeed(42)
        expect_near(rng(42):random(), generator:random(), 0.000001)
    end)

    -- @covers LRandomGenerator:getState
    it("getState returns a non-empty state blob", function()
        expect_true(#rng(3):getState() > 0)
    end)

    -- @covers LRandomGenerator:setState
    it("setState restores the serialized generator state", function()
        local source = rng(19)
        local first = source:random()
        local state = source:getState()
        local expected = source:random()
        local restored = rng(1)
        restored:setState(state)
        expect_true(first ~= expected)
        expect_near(expected, restored:random(), 0.000001)
    end)

    -- @covers LRandomGenerator:roll
    it("roll returns a bounded die value", function()
        local value = rng(21):roll(6)
        expect_true(value >= 1 and value <= 6)
    end)

    -- @covers LRandomGenerator:rollN
    it("rollN returns one result per die", function()
        local values = rng(22):rollN(3, 6)
        expect_equal(3, #values)
        expect_true(values[1] >= 1 and values[1] <= 6)
    end)

    -- @covers LRandomGenerator:rollSum
    it("rollSum returns a value within the possible sum range", function()
        local total = rng(23):rollSum(3, 6)
        expect_true(total >= 3 and total <= 18)
    end)

    -- @covers LRandomGenerator:rollKeepHighest
    it("rollKeepHighest stays inside the kept dice bounds", function()
        local total = rng(24):rollKeepHighest(4, 6, 2)
        expect_true(total >= 2 and total <= 12)
    end)

    -- @covers LRandomGenerator:rollKeepLowest
    it("rollKeepLowest stays inside the kept dice bounds", function()
        local total = rng(25):rollKeepLowest(4, 6, 2)
        expect_true(total >= 2 and total <= 12)
    end)

    -- @covers LRandomGenerator:rollAdvantage
    it("rollAdvantage returns a bounded die value", function()
        local value = rng(26):rollAdvantage(20)
        expect_true(value >= 1 and value <= 20)
    end)

    -- @covers LRandomGenerator:rollDisadvantage
    it("rollDisadvantage returns a bounded die value", function()
        local value = rng(27):rollDisadvantage(20)
        expect_true(value >= 1 and value <= 20)
    end)

    -- @covers LRandomGenerator:rollExploding
    it("rollExploding returns at least the number of dice rolled", function()
        expect_true(rng(28):rollExploding(2, 6) >= 2)
    end)

    -- @covers LRandomGenerator:countSuccesses
    it("countSuccesses returns a bounded success count", function()
        local successes = rng(29):countSuccesses(4, 6, 4)
        expect_true(successes >= 0 and successes <= 4)
    end)

    -- @covers LRandomGenerator:chance
    it("chance respects boundary probabilities", function()
        local generator = rng(5)
        expect_false(generator:chance(0.0))
        expect_true(generator:chance(1.0))
    end)

    -- @covers LRandomGenerator:type
    it("type returns LRandomGenerator", function()
        expect_equal("LRandomGenerator", rng(1):type())
    end)

    -- @covers LRandomGenerator:typeOf
    it("typeOf reports random generator inheritance", function()
        expect_true(rng(1):typeOf("LRandomGenerator"))
    end)
end)

-- @describe vec2
describe("math vec2", function()
    -- @covers lurek.math.vec2
    it("vec2 creates userdata", function()
        expect_type("userdata", vec2(3, 4))
    end)

    -- @covers lurek.math.Vec2
    it("Vec2 alias creates userdata", function()
        expect_type("userdata", lurek.math.Vec2(3, 4))
    end)

    -- @covers LVec2:x
    it("x returns the x component", function()
        expect_near(3, vec2(3, 4).x, 0.0001)
    end)

    -- @covers LVec2:y
    it("y returns the y component", function()
        expect_near(4, vec2(3, 4).y, 0.0001)
    end)

    -- @covers LVec2:length
    it("length returns vector magnitude", function()
        expect_near(5, vec2(3, 4):length(), 0.0001)
    end)

    -- @covers LVec2:lengthSquared
    it("lengthSquared avoids the square root", function()
        expect_near(25, vec2(3, 4):lengthSquared(), 0.0001)
    end)

    -- @covers LVec2:normalize
    it("normalize mutates the vector to unit length", function()
        local value = vec2(3, 4):normalize()
        expect_near(1, value:length(), 0.0001)
    end)

    -- @covers LVec2:normalized
    it("normalized returns a new unit vector", function()
        expect_near(1, vec2(3, 4):normalized():length(), 0.0001)
    end)

    -- @covers LVec2:dot
    it("dot computes scalar projection", function()
        expect_near(11, vec2(1, 2):dot(vec2(3, 4)), 0.0001)
    end)

    -- @covers LVec2:distance
    it("distance computes distance between vectors", function()
        expect_near(5, vec2(0, 0):distance(vec2(3, 4)), 0.0001)
    end)

    -- @covers LVec2:lerp
    it("lerp interpolates between vec2 endpoints", function()
        local value = vec2(0, 0):lerp(vec2(10, 20), 0.5)
        expect_near(5, value.x, 0.0001)
        expect_near(10, value.y, 0.0001)
    end)

    -- @covers LVec2:angle
    it("angle returns the vector heading", function()
        expect_near(lurek.math.pi / 2, vec2(0, 1):angle(), 0.0001)
    end)

    -- @covers LVec2:rotate
    it("rotate turns the vector around the origin", function()
        local rotated = vec2(1, 0):rotate(lurek.math.pi / 2)
        expect_near(0, rotated.x, 0.0001)
        expect_near(1, rotated.y, 0.0001)
    end)

    -- @covers LVec2:perpendicular
    it("perpendicular returns a right angle vector", function()
        local p = vec2(2, 3):perpendicular()
        expect_near(-3, p.x, 0.0001)
        expect_near(2, p.y, 0.0001)
    end)

    -- @covers LVec2:cross
    it("cross returns the scalar z component", function()
        expect_near(1, vec2(1, 0):cross(vec2(0, 1)), 0.0001)
    end)

    -- @covers LVec2:fromAngle
    it("fromAngle constructs a unit vector from radians", function()
        local v = vec2(0, 0):fromAngle(0)
        expect_near(1, v.x, 0.0001)
        expect_near(0, v.y, 0.0001)
    end)

    -- @covers LVec2:reflect
    it("reflect mirrors a vector around a normal", function()
        local r = lurek.math.Vec2(1, -1):reflect(lurek.math.Vec2(0, 1))
        expect_near(1, r.x, 0.0001)
        expect_near(1, r.y, 0.0001)
    end)

    -- @covers LVec2:type
    it("type returns LVec2", function()
        expect_equal("LVec2", vec2(1, 2):type())
    end)

    -- @covers LVec2:typeOf
    it("typeOf reports vec2 inheritance", function()
        expect_true(vec2(1, 2):typeOf("LVec2"))
    end)
end)

-- @describe vec3
describe("math vec3", function()
    -- @covers lurek.math.vec3
    it("vec3 creates userdata", function()
        expect_type("userdata", vec3(1, 2, 3))
    end)

    -- @covers lurek.math.Vec3
    it("Vec3 alias creates userdata", function()
        expect_type("userdata", lurek.math.Vec3(1, 2, 3))
    end)

    -- @covers LVec3:length
    it("length returns vector magnitude", function()
        expect_near(5, vec3(3, 4, 0):length(), 0.0001)
    end)

    -- @covers LVec3:lengthSquared
    it("lengthSquared returns squared magnitude", function()
        expect_near(9, vec3(1, 2, 2):lengthSquared(), 0.0001)
    end)

    -- @covers LVec3:normalize
    it("normalize mutates to unit length", function()
        local value = vec3(3, 0, 0):normalize()
        expect_near(1, value:length(), 0.0001)
    end)

    -- @covers LVec3:dot
    it("dot computes scalar projection", function()
        expect_near(0, vec3(1, 0, 0):dot(vec3(0, 1, 0)), 0.0001)
    end)

    -- @covers LVec3:cross
    it("cross computes a perpendicular vector", function()
        local cross = vec3(1, 0, 0):cross(vec3(0, 1, 0))
        expect_near(0, cross.x, 0.0001)
        expect_near(0, cross.y, 0.0001)
        expect_near(1, cross.z, 0.0001)
    end)

    -- @covers LVec3:lerp
    it("lerp interpolates between vec3 endpoints", function()
        local value = vec3(0, 0, 0):lerp(vec3(10, 20, 30), 0.5)
        expect_near(5, value.x, 0.0001)
        expect_near(10, value.y, 0.0001)
        expect_near(15, value.z, 0.0001)
    end)

    -- @covers LVec3:distance
    it("distance computes separation between vec3 values", function()
        expect_near(1, vec3(0, 0, 0):distance(vec3(1, 0, 0)), 0.0001)
    end)

    -- @covers LVec3:add
    it("add sums vec3 values", function()
        local value = vec3(1, 2, 3):add(vec3(4, 5, 6))
        expect_near(5, value.x, 0.0001)
        expect_near(7, value.y, 0.0001)
        expect_near(9, value.z, 0.0001)
    end)

    -- @covers LVec3:sub
    it("sub subtracts vec3 values", function()
        local value = vec3(5, 5, 5):sub(vec3(2, 3, 1))
        expect_near(3, value.x, 0.0001)
        expect_near(2, value.y, 0.0001)
        expect_near(4, value.z, 0.0001)
    end)

    -- @covers LVec3:scale
    it("scale multiplies vec3 components", function()
        local value = vec3(2, 3, 4):scale(2)
        expect_near(4, value.x, 0.0001)
        expect_near(6, value.y, 0.0001)
        expect_near(8, value.z, 0.0001)
    end)

    -- @covers LVec3:splat
    it("splat replaces all components with one value", function()
        local value = vec3(0, 0, 0):splat(5)
        expect_near(5, value.x, 0.0001)
        expect_near(5, value.y, 0.0001)
        expect_near(5, value.z, 0.0001)
    end)

    -- @covers LVec3:type
    it("type returns LVec3", function()
        expect_equal("LVec3", vec3(1, 2, 3):type())
    end)

    -- @covers LVec3:typeOf
    it("typeOf reports vec3 inheritance", function()
        expect_true(vec3(1, 2, 3):typeOf("LVec3"))
    end)
end)

-- @describe transforms and curves
describe("math transforms and curves", function()
    -- @covers lurek.math.newTransform
    it("newTransform creates userdata", function()
        expect_type("userdata", lurek.math.newTransform())
    end)

    -- @covers LTransform:translate
    it("translate offsets transformed points", function()
        local t = transform()
        t:translate(5, 10)
        local x, y = t:transformPoint(0, 0)
        expect_near(5, x, 0.0001)
        expect_near(10, y, 0.0001)
    end)

    -- @covers LTransform:rotate
    it("rotate turns the x axis onto the y axis", function()
        local t = transform()
        t:rotate(lurek.math.pi / 2)
        local x, y = t:transformPoint(1, 0)
        expect_near(0, x, 0.0001)
        expect_near(1, y, 0.0001)
    end)

    -- @covers LTransform:scale
    it("scale multiplies point coordinates", function()
        local t = transform()
        t:scale(2, 3)
        local x, y = t:transformPoint(1, 1)
        expect_near(2, x, 0.0001)
        expect_near(3, y, 0.0001)
    end)

    -- @covers LTransform:shear
    it("shear offsets x by the y contribution", function()
        local t = transform()
        t:shear(1, 0)
        local x, y = t:transformPoint(1, 1)
        expect_near(2, x, 0.0001)
        expect_near(1, y, 0.0001)
    end)

    -- @covers LTransform:transformPoint
    it("transformPoint returns two numbers", function()
        local x, y = lurek.math.newTransform():transformPoint(3, 4)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LTransform:setTransformation
    it("setTransformation replaces the transform components", function()
        local t = transform()
        t:setTransformation(5, 6, 0, 2, 3)
        local x, y = t:transformPoint(1, 1)
        expect_near(7, x, 0.0001)
        expect_near(9, y, 0.0001)
    end)

    -- @covers LTransform:inverseTransformPoint
    it("inverseTransformPoint undoes a translation", function()
        local t = transform()
        t:translate(5, 10)
        local x, y = t:inverseTransformPoint(8, 14)
        expect_near(3, x, 0.0001)
        expect_near(4, y, 0.0001)
    end)

    -- @covers LTransform:inverse
    it("inverse returns a transform that undoes the original", function()
        local t = transform()
        t:translate(2, 3)
        local inverse_t = t:inverse()
        local x, y = inverse_t:transformPoint(5, 7)
        expect_near(3, x, 0.0001)
        expect_near(4, y, 0.0001)
    end)

    -- @covers LTransform:clone
    it("clone preserves transformed output", function()
        local t = transform()
        t:translate(9, 4)
        local clone_t = t:clone()
        local x, y = clone_t:transformPoint(1, 2)
        expect_near(10, x, 0.0001)
        expect_near(6, y, 0.0001)
    end)

    -- @covers LTransform:getMatrix
    it("getMatrix returns a 3x3 matrix as a flat table", function()
        local matrix = transform():getMatrix()
        expect_equal(9, #matrix)
        expect_near(1, matrix[1], 0.0001)
    end)

    -- @covers LTransform:decompose
    it("decompose returns the configured translation and scale", function()
        local t = lurek.math.newTransform(5, 6, 0, 2, 3)
        local x, y, angle, sx, sy = t:decompose()
        expect_near(5, x, 0.0001)
        expect_near(6, y, 0.0001)
        expect_near(0, angle, 0.0001)
        expect_near(2, sx, 0.0001)
        expect_near(3, sy, 0.0001)
    end)

    -- @covers LTransform:reset
    it("reset restores the identity transform", function()
        local transform = lurek.math.newTransform()
        transform:translate(5, 10)
        transform:reset()
        local x, y = transform:transformPoint(3, 4)
        expect_near(3, x, 0.0001)
        expect_near(4, y, 0.0001)
    end)

    -- @covers LTransform:type
    it("type returns LTransform", function()
        expect_equal("LTransform", lurek.math.newTransform():type())
    end)

    -- @covers LTransform:typeOf
    it("typeOf reports transform inheritance", function()
        expect_true(lurek.math.newTransform():typeOf("LTransform"))
    end)

    -- @covers lurek.math.newBezierCurve
    it("newBezierCurve creates userdata", function()
        expect_type("userdata", lurek.math.newBezierCurve({ 0, 0, 10, 10, 20, 0 }))
    end)

    -- @covers LBezierCurve:getControlPointCount
    it("getControlPointCount returns the number of control points", function()
        expect_equal(3, lurek.math.newBezierCurve({ 0, 0, 10, 10, 20, 0 }):getControlPointCount())
    end)

    -- @covers LBezierCurve:evaluate
    it("evaluate returns two numbers along the curve", function()
        local x, y = lurek.math.newBezierCurve({ 0, 0, 10, 10, 20, 0 }):evaluate(0.5)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LBezierCurve:render
    it("render returns the requested sampled points", function()
        local points = bezier({ 0, 0, 10, 10, 20, 0 }):render(4)
        expect_equal(5, #points)
        expect_equal(2, #points[1])
    end)

    -- @covers LBezierCurve:getDerivative
    it("getDerivative returns another bezier curve userdata", function()
        expect_type("userdata", bezier({ 0, 0, 10, 10, 20, 0 }):getDerivative())
    end)

    -- @covers LBezierCurve:getControlPoint
    it("getControlPoint returns one based coordinates", function()
        local x, y = bezier({ 0, 0, 10, 10, 20, 0 }):getControlPoint(2)
        expect_near(10, x, 0.0001)
        expect_near(10, y, 0.0001)
    end)

    -- @covers LBezierCurve:setControlPoint
    it("setControlPoint mutates the selected control point", function()
        local curve = bezier({ 0, 0, 10, 10, 20, 0 })
        expect_true(curve:setControlPoint(2, 12, 14))
        local x, y = curve:getControlPoint(2)
        expect_near(12, x, 0.0001)
        expect_near(14, y, 0.0001)
    end)

    -- @covers LBezierCurve:insertControlPoint
    it("insertControlPoint increases the control point count", function()
        local curve = bezier({ 0, 0, 10, 10, 20, 0 })
        curve:insertControlPoint(5, 7, 2)
        expect_equal(4, curve:getControlPointCount())
    end)

    -- @covers LBezierCurve:removeControlPoint
    it("removeControlPoint removes a control point when possible", function()
        local curve = bezier({ 0, 0, 10, 10, 20, 0, 30, 0 })
        expect_true(curve:removeControlPoint(2))
        expect_equal(3, curve:getControlPointCount())
    end)

    -- @covers LBezierCurve:length
    it("length returns a positive arc length", function()
        expect_true(bezier({ 0, 0, 10, 10, 20, 0 }):length() > 0)
    end)

    -- @covers LBezierCurve:evaluateAtDistance
    it("evaluateAtDistance returns the start point at zero distance", function()
        local x, y = bezier({ 0, 0, 10, 10, 20, 0 }):evaluateAtDistance(0)
        expect_near(0, x, 0.0001)
        expect_near(0, y, 0.0001)
    end)

    -- @covers LBezierCurve:translate
    it("translate offsets all control points", function()
        local curve = bezier({ 0, 0, 10, 10, 20, 0 })
        curve:translate(3, 4)
        local x, y = curve:getControlPoint(1)
        expect_near(3, x, 0.0001)
        expect_near(4, y, 0.0001)
    end)

    -- @covers LBezierCurve:rotate
    it("rotate spins control points around the origin", function()
        local curve = bezier({ 1, 0, 2, 0, 3, 0 })
        curve:rotate(lurek.math.pi / 2, 0, 0)
        local x, y = curve:getControlPoint(1)
        expect_near(0, x, 0.0001)
        expect_near(1, y, 0.0001)
    end)

    -- @covers LBezierCurve:scale
    it("scale multiplies control point distances from the origin", function()
        local curve = bezier({ 1, 1, 2, 2, 3, 3 })
        curve:scale(2, 0, 0)
        local x, y = curve:getControlPoint(2)
        expect_near(4, x, 0.0001)
        expect_near(4, y, 0.0001)
    end)

    -- @covers LBezierCurve:type
    it("type returns LBezierCurve", function()
        expect_equal("LBezierCurve", lurek.math.newBezierCurve({ 0, 0, 10, 10, 20, 0 }):type())
    end)

    -- @covers LBezierCurve:typeOf
    it("typeOf reports bezier curve inheritance", function()
        expect_true(bezier({ 0, 0, 10, 10, 20, 0 }):typeOf("LBezierCurve"))
    end)

    -- @covers lurek.math.catmullRom
    it("catmullRom creates userdata", function()
        expect_type("userdata", lurek.math.catmullRom({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }))
    end)

    -- @covers LCatmullRom:len
    it("len returns the point count", function()
        expect_equal(4, lurek.math.catmullRom({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }):len())
    end)

    -- @covers LCatmullRom:sample
    it("sample returns a point on the spline", function()
        local x, y = lurek.math.catmullRom({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }):sample(0.5)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCatmullRom:sampleSegment
    it("sampleSegment returns a point on the selected segment", function()
        local x, y = spline({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }):sampleSegment(0, 0.5)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCatmullRom:addPoint
    it("addPoint appends a spline point", function()
        local curve = spline({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } })
        curve:addPoint(4, 2)
        expect_equal(5, curve:len())
    end)

    -- @covers LCatmullRom:removePoint
    it("removePoint returns the removed coordinates", function()
        local curve = spline({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } })
        local x, y = curve:removePoint(1)
        expect_near(1, x, 0.0001)
        expect_near(1, y, 0.0001)
    end)

    -- @covers LCatmullRom:type
    it("type returns LCatmullRom", function()
        expect_equal("LCatmullRom", spline({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }):type())
    end)

    -- @covers LCatmullRom:typeOf
    it("typeOf reports catmull rom inheritance", function()
        expect_true(spline({ { 0, 0 }, { 1, 1 }, { 2, 0 }, { 3, 1 } }):typeOf("LCatmullRom"))
    end)

    -- @covers lurek.math.hermite
    it("hermite creates userdata", function()
        expect_type("userdata", lurek.math.hermite(0, 0, 10, 0, 1, 1, 1, -1))
    end)

    -- @covers LHermite:sample
    it("hermite sample returns two numbers", function()
        local x, y = lurek.math.hermite(0, 0, 10, 0, 1, 1, 1, -1):sample(0.5)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LHermite:type
    it("type returns LHermite", function()
        expect_equal("LHermite", lurek.math.hermite(0, 0, 10, 0, 1, 1, 1, -1):type())
    end)

    -- @covers LHermite:typeOf
    it("typeOf reports hermite inheritance", function()
        expect_true(lurek.math.hermite(0, 0, 10, 0, 1, 1, 1, -1):typeOf("LHermite"))
    end)

    -- @covers lurek.math.newTween
    it("newTween creates userdata", function()
        expect_type("userdata", lurek.math.newTween(1.0, "linear"))
    end)

    -- @covers LTween:getDuration
    it("getDuration returns the configured tween duration", function()
        expect_near(1.0, lurek.math.newTween(1.0, "linear"):getDuration(), 0.0001)
    end)

    -- @covers LTween:getEasingName
    it("getEasingName returns the configured easing name", function()
        expect_equal("linear", lurek.math.newTween(1.0, "linear"):getEasingName())
    end)

    -- @covers LTween:update
    it("update advances tween completion state", function()
        expect_true(tween(1.0, "linear"):update(1.0))
    end)

    -- @covers LTween:reset
    it("reset returns the tween clock to zero", function()
        local tw = tween(1.0, "linear")
        tw:update(0.5)
        tw:reset()
        expect_near(0.0, tw:getTime(), 0.0001)
    end)

    -- @covers LTween:getValue
    it("getValue returns the current value track", function()
        local tw = tween(1.0, "linear")
        tw:addValue(0, 10)
        tw:update(0.5)
        expect_near(5, tw:getValue(1), 0.0001)
    end)

    -- @covers LTween:getAllValues
    it("getAllValues returns every animated value", function()
        local tw = tween(1.0, "linear")
        tw:addValue(0, 10)
        tw:addValue(10, 20)
        local values = tw:getAllValues()
        expect_equal(2, #values)
    end)

    -- @covers LTween:isComplete
    it("isComplete reports completion after the full duration", function()
        local tw = tween(1.0, "linear")
        tw:update(1.0)
        expect_true(tw:isComplete())
    end)

    -- @covers LTween:getValueCount
    it("getValueCount tracks the number of value channels", function()
        local tw = tween(1.0, "linear")
        tw:addValue(0, 10)
        tw:addValue(10, 20)
        expect_equal(2, tw:getValueCount())
    end)

    -- @covers LTween:getTime
    it("getTime returns the tween clock", function()
        local tw = tween(1.0, "linear")
        tw:update(0.25)
        expect_near(0.25, tw:getTime(), 0.0001)
    end)

    -- @covers LTween:getClock
    it("getClock mirrors the tween clock", function()
        local tw = tween(1.0, "linear")
        tw:update(0.25)
        expect_near(0.25, tw:getClock(), 0.0001)
    end)

    -- @covers LTween:setTime
    it("setTime updates the tween clock", function()
        local tw = tween(1.0, "linear")
        tw:setTime(0.75)
        expect_near(0.75, tw:getTime(), 0.0001)
    end)

    -- @covers LTween:set
    it("set is an alias for setTime", function()
        local tw = tween(1.0, "linear")
        tw:set(0.6)
        expect_near(0.6, tw:getTime(), 0.0001)
    end)

    -- @covers LTween:addValue
    it("addValue returns a one based channel index", function()
        expect_equal(1, tween(1.0, "linear"):addValue(0, 10))
    end)

    -- @covers LLootTable:build
    it("build prepares the loot table for sampling", function()
        local lt = lurek.math.newLootTable(7)
        lt:add("gold", 1.0)
        lt:add("gem", 1.0)
        lt:build()
        expect_not_nil(lt:sample())
    end)

    -- @covers LLootTable:restore
    it("restore loads a saved loot table blob", function()
        local source = lurek.math.newLootTable(9)
        source:add("gold", 1.0)
        source:build()
        local blob = source:save()
        local restored = lurek.math.newLootTable()
        restored:restore(blob)
        expect_equal(1, restored:entryCount())
    end)

    -- @covers LLootTable:entryCount
    it("entryCount returns the number of loot entries", function()
        local lt = lurek.math.newLootTable()
        lt:add("gold", 1.0)
        lt:add("gem", 2.0)
        expect_equal(2, lt:entryCount())
    end)

    -- @covers LLootTable:type
    it("type returns LLootTable", function()
        expect_equal("LLootTable", lurek.math.newLootTable():type())
    end)

    -- @covers LPityTracker:isPrimed
    it("isPrimed becomes true after enough misses", function()
        local pt = lurek.math.newPityTracker("rare", 2)
        pt:notice("common")
        pt:notice("common")
        expect_true(pt:isPrimed())
    end)

    -- @covers LPityTracker:restore
    it("restore loads a saved pity tracker blob", function()
        local source = lurek.math.newPityTracker("rare", 3)
        source:notice("common")
        source:notice("common")
        local blob = source:save()
        local restored = lurek.math.newPityTracker("rare", 3)
        restored:restore(blob)
        expect_equal(2, restored:counter())
    end)

    -- @covers LPityTracker:export
    it("export returns a non-empty pity tracker blob", function()
        local pt = lurek.math.newPityTracker("rare", 2)
        pt:notice("common")
        expect_true(#pt:export() > 0)
    end)

    -- @covers LPityTracker:import
    it("import restores pity tracker state from an exported blob", function()
        local source = lurek.math.newPityTracker("rare", 2)
        source:notice("common")
        local blob = source:export()
        local restored = lurek.math.newPityTracker("rare", 2)
        restored:import(blob)
        expect_equal(1, restored:counter())
    end)

    -- @covers LPityTracker:type
    it("type returns LPityTracker", function()
        expect_equal("LPityTracker", lurek.math.newPityTracker("rare", 2):type())
    end)
end)
end
-- END test_math_core_unit.lua

-- BEGIN test_math_render_unit.lua
do
-- Lurek2D Integration Test: Math + Graphics (headless-safe)
-- Tests math operations used in graphics contexts without requiring GPU

local function spatial_hash(cell_size)
    return lurek.math.newSpatialHash(cell_size)
end

local function circle(x, y, radius)
    return lurek.math.newCircle(x, y, radius)
end

local function rect_packer(width, height, padding)
    return lurek.math.newRectPacker(width, height, padding)
end

local function aabb_tree()
    return lurek.math.aabbTree()
end

local function point_list(...)
    local values = { ... }
    local points = {}
    for i = 1, #values, 2 do
        points[#points + 1] = { x = values[i], y = values[i + 1] }
    end
    return points
end

-- @describe math for graphics transformations
describe("math for graphics transformations", function()
    -- @covers LArray:transformPoints
    it("scale + translate point", function()
        local x, y = 10, 20
        local sx, sy = 2, 3
        local tx, ty = 100, 200

        local m = lurek.compute.affine2d(tx, ty, 0, sx, sy)
        local pts = lurek.compute.fromTable({ x, y }, nil, "float64"):reshape({ 1, 2 })
        local out = m:transformPoints(pts)

        expect_near(120, out:get(1, 1), 0.001, "scaled + translated x")
        expect_near(260, out:get(1, 2), 0.001, "scaled + translated y")
    end)

end)

-- @describe math geometry utilities
describe("math geometry utilities", function()
    -- @covers lurek.math.newWrapSpace
    it("wraps coordinates and takes shortest paths across a toroidal arena", function()
        local space = lurek.math.newWrapSpace(0, 0, 100, 80)
        local x, y = space:wrap(103, -2)
        expect_near(3, x, 0.0001)
        expect_near(78, y, 0.0001)
        local dx, dy = space:delta(98, 40, 2, 40)
        expect_near(4, dx, 0.0001)
        expect_near(0, dy, 0.0001)
        expect_near(4, space:distance(98, 40, 2, 40), 0.0001)
    end)

    -- @covers LWrapSpace:wrap
    it("wrap keeps every coordinate in the configured half-open range", function()
        local space = lurek.math.newWrapSpace(-50, 10, 100, 40)
        local x, y = space:wrap(-151, 91)
        expect_near(49, x, 0.0001)
        expect_near(11, y, 0.0001)
    end)

    -- @covers LWrapSpace:delta
    it("delta chooses a stable signed shortest route", function()
        local space = lurek.math.newWrapSpace(0, 0, 100, 80)
        local dx, dy = space:delta(2, 2, 98, 78)
        expect_near(-4, dx, 0.0001)
        expect_near(-4, dy, 0.0001)
    end)

    -- @covers LWrapSpace:distance
    it("distance is based on the toroidal shortest displacement", function()
        local space = lurek.math.newWrapSpace(0, 0, 100, 80)
        expect_near(5, space:distance(98, 40, 2, 43), 0.0001)
    end)

    -- @covers LWrapSpace:type
    it("wrap-space reports its userdata type", function()
        local space = lurek.math.newWrapSpace(0, 0, 1, 1)
        expect_equal("LWrapSpace", space:type())
    end)

    -- @covers LWrapSpace:typeOf
    it("wrap-space recognizes its own public type", function()
        local space = lurek.math.newWrapSpace(0, 0, 1, 1)
        expect_true(space:typeOf("LWrapSpace"))
        expect_true(space:typeOf("LObject"))
    end)

    -- @covers lurek.math.rectFromCenter
    it("point inside rectangle", function()
        local px, py = 5, 5
        local rx, ry, rw, rh = lurek.math.rectFromCenter(5, 5, 10, 10)

        local inside = px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
        expect_true(inside, "point is inside rect")

        local outside_x, outside_y = 15, 5
        local outside = outside_x >= rx and outside_x <= rx + rw and outside_y >= ry and outside_y <= ry + rh
        expect_false(outside, "point is outside rect")
    end)

    -- @covers lurek.math.circleContainsPoint
    it("point inside circle", function()
        local px, py = 3, 4
        local cx, cy, cr = 0, 0, 6

        expect_true(lurek.math.circleContainsPoint(cx, cy, cr, px, py), "point inside circle (dist=5, radius=6)")
    end)

    -- @covers lurek.math.newSpatialHash
    it("newSpatialHash creates userdata and rejects non-positive cell sizes", function()
        expect_type("userdata", spatial_hash(16))
        expect_error(function()
            lurek.math.newSpatialHash(0)
        end)
    end)

    -- @covers lurek.math.newRectPacker
    it("newRectPacker creates userdata", function()
        expect_type("userdata", rect_packer(64, 64, 0))
    end)

    -- @covers lurek.math.triangulate
    it("triangulate decomposes a square into triangles", function()
        local tris = lurek.math.triangulate({ 0, 0, 10, 0, 10, 10, 0, 10 })
        expect_equal(2, #tris)
        expect_equal(6, #tris[1])
    end)

    -- @covers lurek.math.isConvex
    it("isConvex detects a convex square", function()
        expect_true(lurek.math.isConvex({ 0, 0, 10, 0, 10, 10, 0, 10 }))
    end)

    -- @covers lurek.math.circleIntersectsCircle
    it("circleIntersectsCircle detects overlapping circles", function()
        expect_true(lurek.math.circleIntersectsCircle(0, 0, 5, 7, 0, 5))
    end)

    -- @covers lurek.math.circleIntersectsLine
    it("circleIntersectsLine returns line hit points", function()
        local hit, x1, y1 = lurek.math.circleIntersectsLine(0, 0, 5, -10, 0, 10, 0)
        expect_true(hit)
        expect_near(-5, x1, 0.0001)
        expect_near(0, y1, 0.0001)
    end)

    -- @covers lurek.math.circleIntersectsSegment
    it("circleIntersectsSegment returns segment hit points", function()
        local hit, x1, y1 = lurek.math.circleIntersectsSegment(0, 0, 5, -10, 0, 10, 0)
        expect_true(hit)
        expect_near(-5, x1, 0.0001)
        expect_near(0, y1, 0.0001)
    end)

    -- @covers lurek.math.closestPointOnSegment
    it("closestPointOnSegment projects a point onto the segment", function()
        local x, y = lurek.math.closestPointOnSegment(4, 5, 0, 0, 10, 0)
        expect_near(4, x, 0.0001)
        expect_near(0, y, 0.0001)
    end)

    -- @covers lurek.math.convexHull
    it("convexHull returns an enclosing polygon", function()
        local hull = lurek.math.convexHull({ 0, 0, 10, 0, 10, 10, 0, 10, 5, 5 })
        expect_equal(8, #hull)
    end)

    -- @covers lurek.math.delaunayTriangulate
    it("delaunayTriangulate returns triangle index tables", function()
        local tris = lurek.math.delaunayTriangulate({ 0, 0, 10, 0, 10, 10, 0, 10 })
        expect_type("table", tris)
    end)

    -- @covers lurek.math.lineIntersect
    it("lineIntersect returns the crossing point of two lines", function()
        local x, y = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
        expect_near(5, x, 0.0001)
        expect_near(5, y, 0.0001)
    end)

    -- @covers lurek.math.pointInPolygon
    it("pointInPolygon reports interior points", function()
        expect_true(lurek.math.pointInPolygon({ 0, 0, 10, 0, 10, 10, 0, 10 }, 5, 5))
    end)

    -- @covers lurek.math.polygonArea
    it("polygonArea computes square area", function()
        expect_near(100, lurek.math.polygonArea({ 0, 0, 10, 0, 10, 10, 0, 10 }), 0.0001)
    end)

    -- @covers lurek.math.polygonCentroid
    it("polygonCentroid returns the square center", function()
        local x, y = lurek.math.polygonCentroid({ 0, 0, 10, 0, 10, 10, 0, 10 })
        expect_near(5, x, 0.0001)
        expect_near(5, y, 0.0001)
    end)

    -- @covers lurek.math.segmentIntersectsSegment
    it("segmentIntersectsSegment returns the crossing point", function()
        local hit, x, y = lurek.math.segmentIntersectsSegment(0, 0, 10, 10, 0, 10, 10, 0)
        expect_true(hit)
        expect_near(5, x, 0.0001)
        expect_near(5, y, 0.0001)
    end)

    -- @covers lurek.math.bresenham
    it("bresenham returns grid cells including endpoints", function()
        local cells = lurek.math.bresenham(2, 3, 4, 3)
        expect_equal(3, #cells)
        expect_equal(2, cells[1].x)
        expect_equal(4, cells[3].x)
    end)

    -- @covers lurek.math.clamp
    it("clamp limits values to the supplied range", function()
        expect_near(10, lurek.math.clamp(15, 0, 10), 0.0001)
    end)

    -- @covers lurek.math.sign
    it("sign returns the sign of a negative number", function()
        expect_near(-1, lurek.math.sign(-3), 0.0001)
    end)

    -- @covers lurek.math.smoothstep
    it("smoothstep returns half at the midpoint", function()
        expect_near(0.5, lurek.math.smoothstep(0, 1, 0.5), 0.0001)
    end)

    -- @covers lurek.math.inverseLerp
    it("inverseLerp returns midpoint progress for midpoint values", function()
        expect_near(0.5, lurek.math.inverseLerp(10, 20, 15), 0.0001)
    end)

    -- @covers lurek.math.rectUnion
    it("rectUnion returns the bounding box of both rectangles", function()
        local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 6, 4, 8)
        expect_near(0, x, 0.0001)
        expect_near(0, y, 0.0001)
        expect_near(10, w, 0.0001)
        expect_near(14, h, 0.0001)
    end)

    -- @covers lurek.math.polygonClip
    it("polygonClip clips a square against a half plane", function()
        local poly = lurek.math.polygonClip({ 0, 0, 10, 0, 10, 10, 0, 10 }, 1, 0, 5)
        expect_equal(8, #poly)
        expect_near(5, poly[1], 0.0001)
    end)

    -- @covers lurek.math.aabbTree
    it("aabbTree creates userdata", function()
        expect_type("userdata", aabb_tree())
    end)

    -- @covers lurek.math.newCircle
    it("newCircle creates userdata", function()
        expect_type("userdata", circle(1, 2, 3))
    end)

    -- @covers lurek.math.polygonIntersection
    it("polygonIntersection returns overlapping polygon points", function()
        local poly = lurek.math.polygonIntersection(
            point_list(0, 0, 10, 0, 10, 10, 0, 10),
            point_list(5, 0, 15, 0, 15, 10, 5, 10)
        )
        expect_true(#poly >= 4)
        expect_not_nil(poly[1].x)
    end)

    -- @covers lurek.math.polygonUnion
    it("polygonUnion returns a merged polygon", function()
        local poly = lurek.math.polygonUnion(
            point_list(0, 0, 10, 0, 10, 10, 0, 10),
            point_list(5, 0, 15, 0, 15, 10, 5, 10)
        )
        expect_true(#poly >= 4)
        expect_not_nil(poly[1].x)
    end)

    -- @covers lurek.math.polygonDifference
    it("polygonDifference returns remaining polygon points", function()
        local poly = lurek.math.polygonDifference(
            point_list(0, 0, 10, 0, 10, 10, 0, 10),
            point_list(5, 0, 15, 0, 15, 10, 5, 10)
        )
        expect_true(#poly >= 4)
        expect_not_nil(poly[1].x)
    end)

end)

-- @describe math spatial and shape objects
describe("math spatial and shape objects", function()
    -- @covers LSpatialHash:insert
    it("insert stores an item in the spatial hash", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        expect_equal(1, hash:getItemCount())
    end)

    -- @covers LSpatialHash:update
    it("update moves an existing spatial hash item", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        hash:update("player", 40, 0, 8, 8)
        local ids = hash:queryRect(32, -1, 32, 16)
        expect_equal("player", ids[1])
    end)

    -- @covers LSpatialHash:remove
    it("remove deletes an item from the spatial hash", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        hash:remove("player")
        expect_equal(0, hash:getItemCount())
    end)

    -- @covers LSpatialHash:clear
    it("clear removes every spatial hash item", function()
        local hash = spatial_hash(16)
        hash:insert("a", 0, 0, 8, 8)
        hash:insert("b", 20, 0, 8, 8)
        hash:clear()
        expect_equal(0, hash:getItemCount())
    end)

    -- @covers LSpatialHash:queryRect
    it("queryRect returns ids intersecting the area", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        local ids = hash:queryRect(-1, -1, 16, 16)
        expect_equal("player", ids[1])
    end)

    -- @covers LSpatialHash:queryCircle
    it("queryCircle returns ids inside the search radius", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        local ids = hash:queryCircle(4, 4, 10)
        expect_equal("player", ids[1])
    end)

    -- @covers LSpatialHash:querySegment
    it("querySegment returns ids along the segment", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        local ids = hash:querySegment(-10, 4, 20, 4)
        expect_equal("player", ids[1])
    end)

    -- @covers LSpatialHash:getCellSize
    it("getCellSize returns the configured cell size", function()
        expect_near(32, spatial_hash(32):getCellSize(), 0.0001)
    end)

    -- @covers LSpatialHash:getItemCount
    it("getItemCount returns the number of inserted items", function()
        local hash = spatial_hash(16)
        hash:insert("player", 0, 0, 8, 8)
        expect_equal(1, hash:getItemCount())
    end)

    -- @covers LSpatialHash:type
    it("type returns LSpatialHash", function()
        expect_equal("LSpatialHash", spatial_hash(16):type())
    end)

    -- @covers LSpatialHash:typeOf
    it("typeOf reports spatial hash inheritance", function()
        expect_true(spatial_hash(16):typeOf("LSpatialHash"))
    end)

    -- @covers LCircle:area
    it("area returns pi times radius squared", function()
        expect_near(lurek.math.pi * 25, circle(0, 0, 5):area(), 0.0001)
    end)

    -- @covers LCircle:perimeter
    it("perimeter returns two pi r", function()
        expect_near(2 * lurek.math.pi * 5, circle(0, 0, 5):perimeter(), 0.0001)
    end)

    -- @covers LCircle:contains
    it("contains returns true for interior points", function()
        expect_true(circle(0, 0, 5):contains(3, 4))
    end)

    -- @covers LCircle:intersects
    it("intersects returns true for overlapping circles", function()
        expect_true(circle(0, 0, 5):intersects(circle(7, 0, 5)))
    end)

    -- @covers LCircle:aabb
    it("aabb returns min and max circle bounds", function()
        local min_x, min_y, max_x, max_y = circle(3, 4, 2):aabb()
        expect_near(1, min_x, 0.0001)
        expect_near(2, min_y, 0.0001)
        expect_near(5, max_x, 0.0001)
        expect_near(6, max_y, 0.0001)
    end)

    -- @covers LCircle:x
    it("x returns the circle center x", function()
        expect_near(3, circle(3, 4, 2):x(), 0.0001)
    end)

    -- @covers LCircle:y
    it("y returns the circle center y", function()
        expect_near(4, circle(3, 4, 2):y(), 0.0001)
    end)

    -- @covers LCircle:radius
    it("radius returns the stored radius", function()
        expect_near(2, circle(3, 4, 2):radius(), 0.0001)
    end)

    -- @covers LCircle:type
    it("type returns LCircle", function()
        expect_equal("LCircle", circle(0, 0, 1):type())
    end)

    -- @covers LCircle:typeOf
    it("typeOf reports circle inheritance", function()
        expect_true(circle(0, 0, 1):typeOf("LCircle"))
    end)

    -- @covers LRectPacker:pack
    it("pack returns coordinates for a rectangle that fits", function()
        local x, y = rect_packer(32, 32, 0):pack(8, 8, "sprite")
        expect_near(0, x, 0.0001)
        expect_near(0, y, 0.0001)
    end)

    -- @covers LRectPacker:clear
    it("clear removes previously packed rectangles", function()
        local packer = rect_packer(32, 32, 0)
        packer:pack(8, 8, "sprite")
        packer:clear()
        expect_equal(0, #packer:getPacked())
    end)

    -- @covers LRectPacker:occupancy
    it("occupancy reports the used area ratio", function()
        local packer = rect_packer(16, 16, 0)
        packer:pack(8, 8, "sprite")
        expect_near(0.25, packer:occupancy(), 0.0001)
    end)

    -- @covers LRectPacker:getPacked
    it("getPacked returns packed rectangle records", function()
        local packer = rect_packer(32, 32, 0)
        packer:pack(8, 8, "sprite")
        local packed = packer:getPacked()
        expect_equal("sprite", packed[1].id)
    end)

    -- @covers LAabbTree:insert
    it("insert adds an item to the tree", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        expect_equal(1, tree:len())
    end)

    -- @covers LAabbTree:remove
    it("remove deletes an existing item", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        expect_true(tree:remove(1))
    end)

    -- @covers LAabbTree:query
    it("query returns ids overlapping the box", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        local ids = tree:query(2, 2, 8, 8)
        expect_equal(1, ids[1])
    end)

    -- @covers LAabbTree:queryPoint
    it("queryPoint returns ids containing the point", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        local ids = tree:queryPoint(5, 5)
        expect_equal(1, ids[1])
    end)

    -- @covers LAabbTree:update
    it("update moves an existing item", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        expect_true(tree:update(1, 20, 20, 30, 30))
    end)

    -- @covers LAabbTree:contains
    it("contains reports whether an id exists", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        expect_true(tree:contains(1))
    end)

    -- @covers LAabbTree:len
    it("len returns the item count", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        expect_equal(1, tree:len())
    end)

    -- @covers LAabbTree:isEmpty
    it("isEmpty reports whether the tree has no items", function()
        expect_true(aabb_tree():isEmpty())
    end)

    -- @covers LAabbTree:clear
    it("clear removes all items from the tree", function()
        local tree = aabb_tree()
        tree:insert(1, 0, 0, 10, 10)
        tree:clear()
        expect_true(tree:isEmpty())
    end)

    -- @covers LAabbTree:type
    it("type returns LAabbTree", function()
        expect_equal("LAabbTree", aabb_tree():type())
    end)

    -- @covers LAabbTree:typeOf
    it("typeOf reports aabb tree inheritance", function()
        expect_true(aabb_tree():typeOf("LAabbTree"))
    end)
end)
end
-- END test_math_render_unit.lua

test_summary()
