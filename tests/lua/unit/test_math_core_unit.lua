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
        local transform = lurek.math.newTransform()
        transform:translate(5, 10)
        local x, y = transform:transformPoint(0, 0)
        expect_near(5, x, 0.0001)
        expect_near(10, y, 0.0001)
    end)

    -- @covers LTransform:transformPoint
    it("transformPoint returns two numbers", function()
        local x, y = lurek.math.newTransform():transformPoint(3, 4)
        expect_type("number", x)
        expect_type("number", y)
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

    -- @covers LBezierCurve:type
    it("type returns LBezierCurve", function()
        expect_equal("LBezierCurve", lurek.math.newBezierCurve({ 0, 0, 10, 10, 20, 0 }):type())
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
end)

test_summary()
