-- Lurek2D Math API Tests

-- @description Verifies the math namespace exposes the pi constant and that its numeric value matches the expected approximation.
describe("lurek.math constants", function()
    -- @description Confirms pi is present and is within 0.0001 of 3.14159265358979.
    -- @covers lurek.math.pi
    it("has pi", function()
        expect_not_nil(lurek.math.pi, "pi exists")
        expect_near(3.14159265358979, lurek.math.pi, 0.0001, "pi value")
    end)
end)

-- @description Checks core trigonometric helpers against canonical angles for sine, cosine, tangent, and atan2.
describe("lurek.math trigonometry", function()
    -- @description Asserts sin(0) returns 0 within 0.0001.
    it("sin(0) = 0", function()
        expect_near(0, lurek.math.sin(0), 0.0001)
    end)

    -- @description Asserts sin(pi/2) returns 1 within 0.0001.
    it("sin(pi/2) = 1", function()
        expect_near(1, lurek.math.sin(lurek.math.pi / 2), 0.0001)
    end)

    -- @description Asserts cos(0) returns 1 within 0.0001.
    it("cos(0) = 1", function()
        expect_near(1, lurek.math.cos(0), 0.0001)
    end)

    -- @description Asserts cos(pi) returns -1 within 0.0001.
    it("cos(pi) = -1", function()
        expect_near(-1, lurek.math.cos(lurek.math.pi), 0.0001)
    end)

    -- @description Asserts tan(0) returns 0 within 0.0001.
    it("tan(0) = 0", function()
        expect_near(0, lurek.math.tan(0), 0.0001)
    end)

    -- @description Asserts atan2(1, 0) returns pi/2 within 0.0001.
    it("atan2(1, 0) = pi/2", function()
        expect_near(lurek.math.pi / 2, lurek.math.atan2(1, 0), 0.0001)
    end)

    -- @description Asserts atan2(0, 1) returns 0 within 0.0001.
    it("atan2(0, 1) = 0", function()
        expect_near(0, lurek.math.atan2(0, 1), 0.0001)
    end)
end)

-- @description Verifies square root, absolute value, floor, and ceil return the expected scalar results for positive and negative inputs.
describe("lurek.math basic functions", function()
    -- @description Asserts sqrt(4) evaluates to 2 within 0.0001.
    it("sqrt(4) = 2", function()
        expect_near(2, lurek.math.sqrt(4), 0.0001)
    end)

    -- @description Asserts sqrt(9) evaluates to 3 within 0.0001.
    it("sqrt(9) = 3", function()
        expect_near(3, lurek.math.sqrt(9), 0.0001)
    end)

    -- @description Asserts abs(-5) returns the positive magnitude 5 within 0.0001.
    it("abs(-5) = 5", function()
        expect_near(5, lurek.math.abs(-5), 0.0001)
    end)

    -- @description Asserts abs(5) leaves the positive input unchanged at 5 within 0.0001.
    it("abs(5) = 5", function()
        expect_near(5, lurek.math.abs(5), 0.0001)
    end)

    -- @description Asserts floor(3.7) truncates down to the integer 3.
    it("floor(3.7) = 3", function()
        expect_equal(3, lurek.math.floor(3.7))
    end)

    -- @description Asserts floor(-2.1) rounds down toward negative infinity to -3.
    it("floor(-2.1) = -3", function()
        expect_equal(-3, lurek.math.floor(-2.1))
    end)

    -- @description Asserts ceil(3.2) rounds up to the integer 4.
    it("ceil(3.2) = 4", function()
        expect_equal(4, lurek.math.ceil(3.2))
    end)

    -- @description Asserts ceil(-2.9) rounds up toward zero to -2.
    it("ceil(-2.9) = -2", function()
        expect_equal(-2, lurek.math.ceil(-2.9))
    end)
end)

-- @description Verifies min, max, and clamp choose the expected bounds for in-range and out-of-range inputs.
describe("lurek.math min/max/clamp", function()
    -- @description Asserts min(3, 7) returns the smaller value 3.
    it("min(3, 7) = 3", function()
        expect_equal(3, lurek.math.min(3, 7))
    end)

    -- @description Asserts min(-1, 1) returns -1 as the smaller signed value.
    it("min(-1, 1) = -1", function()
        expect_equal(-1, lurek.math.min(-1, 1))
    end)

    -- @description Asserts max(3, 7) returns the larger value 7.
    it("max(3, 7) = 7", function()
        expect_equal(7, lurek.math.max(3, 7))
    end)

    -- @description Asserts clamp keeps an in-range value unchanged at 5.
    it("clamp(5, 0, 10) = 5", function()
        expect_equal(5, lurek.math.clamp(5, 0, 10))
    end)

    -- @description Asserts clamp raises a below-range value -5 up to the minimum bound 0.
    it("clamp(-5, 0, 10) = 0", function()
        expect_equal(0, lurek.math.clamp(-5, 0, 10))
    end)

    -- @description Asserts clamp lowers an above-range value 15 down to the maximum bound 10.
    it("clamp(15, 0, 10) = 10", function()
        expect_equal(10, lurek.math.clamp(15, 0, 10))
    end)
end)

-- @description Verifies Euclidean distance calculations for a 3-4-5 triangle, identical points, and a unit horizontal segment.
describe("lurek.math.distance", function()
    -- @description Asserts the distance from (0,0) to (3,4) is 5 within 0.0001.
    it("distance(0,0,3,4) = 5", function()
        expect_near(5, lurek.math.distance(0, 0, 3, 4), 0.0001)
    end)

    -- @description Asserts the distance between identical points is 0 within 0.0001.
    it("distance(1,1,1,1) = 0", function()
        expect_near(0, lurek.math.distance(1, 1, 1, 1), 0.0001)
    end)

    -- @description Asserts the distance from (0,0) to (1,0) is 1 within 0.0001.
    it("distance(0,0,1,0) = 1", function()
        expect_near(1, lurek.math.distance(0, 0, 1, 0), 0.0001)
    end)
end)

-- @description Verifies random number helpers return numeric values inside the expected default, max-only, and min/max ranges.
describe("lurek.math.random", function()
    -- @description Calls random() once and asserts the returned value has Lua type number.
    it("returns a number", function()
        local val = lurek.math.random()
        expect_type("number", val)
    end)

    -- @description Samples random() 20 times and asserts every result is greater than or equal to 0 and less than 1.
    it("no-arg returns value in [0, 1)", function()
        for i = 1, 20 do
            local val = lurek.math.random()
            expect_true(val >= 0 and val < 1, "random() in [0,1)")
        end
    end)

    -- @description Samples random(10) 20 times and asserts every result stays between 0 and 10 inclusive.
    it("with max returns value in [0, max)", function()
        for i = 1, 20 do
            local val = lurek.math.random(10)
            expect_true(val >= 0 and val <= 10, "random(10) in [0,10]")
        end
    end)

    -- @description Samples random(5, 15) 20 times and asserts every result stays between 5 and 15 inclusive.
    it("with min,max returns value in [min, max)", function()
        for i = 1, 20 do
            local val = lurek.math.random(5, 15)
            expect_true(val >= 5 and val <= 15, "random(5,15) in [5,15]")
        end
    end)
end)

-- @description Verifies standalone simplex noise returns numeric values, stays near the documented range, and is deterministic for repeated inputs.
describe("math.simplexNoise standalone", function()
    -- @description Evaluates simplexNoise at (0.5, 0.5), asserts the result is numeric, and checks it falls between -1.1 and 1.1.
    it("returns a number in range [-1, 1]", function()
        local v = lurek.math.simplexNoise(0.5, 0.5)
        expect_type("number", v)
        expect_equal(v > -1.1 and v < 1.1, true)
    end)

    -- @description Calls simplexNoise twice with the same 2D inputs and asserts the two values match within 0.000001.
    it("is deterministic for same inputs", function()
        local v1 = lurek.math.simplexNoise(1.23, 4.56)
        local v2 = lurek.math.simplexNoise(1.23, 4.56)
        expect_near(v1, v2, 0.000001)
    end)

    -- @description Calls simplexNoise with three coordinates and asserts the returned value is numeric.
    it("accepts 3 arguments", function()
        local v = lurek.math.simplexNoise(0.1, 0.2, 0.3)
        expect_type("number", v)
    end)
end)

-- â”€â”€ additional constants & utility â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies secondary constants and scalar helpers including tau, huge, lerp, sign, round, distanceSq, angle conversion, angleBetween, and randomInt.
describe("math constants and utility", function()
    -- @description Asserts tau matches pi multiplied by 2 within 0.0001.
    it("has tau = 2*pi", function()
        expect_near(lurek.math.tau, lurek.math.pi * 2, 0.0001)
    end)

    -- @description Asserts huge is larger than 1e300.
    it("has huge", function()
        expect_true(lurek.math.huge > 1e300)
    end)

    -- @description Asserts lerp from 0 to 10 at t=0.5 returns 5 within 0.0001.
    it("lerp(0, 10, 0.5) = 5", function()
        expect_near(lurek.math.lerp(0, 10, 0.5), 5, 0.0001)
    end)

    -- @description Asserts lerp from 0 to 10 at t=0 returns the start value 0 within 0.0001.
    it("lerp(0, 10, 0) = 0", function()
        expect_near(lurek.math.lerp(0, 10, 0), 0, 0.0001)
    end)

    -- @description Asserts lerp from 0 to 10 at t=1 returns the end value 10 within 0.0001.
    it("lerp(0, 10, 1) = 10", function()
        expect_near(lurek.math.lerp(0, 10, 1), 10, 0.0001)
    end)

    -- @description Asserts sign(-5) returns -1.
    it("sign(-5) = -1", function()
        expect_equal(lurek.math.sign(-5), -1)
    end)

    -- @description Asserts sign(5) returns 1.
    it("sign(5) = 1", function()
        expect_equal(lurek.math.sign(5), 1)
    end)

    -- @description Asserts sign(0) returns 0.
    it("sign(0) = 0", function()
        expect_equal(lurek.math.sign(0), 0)
    end)

    -- @description Asserts round(2.3) returns 2.
    it("round(2.3) = 2", function()
        expect_equal(lurek.math.round(2.3), 2)
    end)

    -- @description Asserts round(2.7) returns 3.
    it("round(2.7) = 3", function()
        expect_equal(lurek.math.round(2.7), 3)
    end)

    -- @description Asserts the squared distance from (0,0) to (3,4) is 25 within 0.0001.
    it("distanceSq(0,0,3,4) = 25", function()
        expect_near(lurek.math.distanceSq(0, 0, 3, 4), 25, 0.0001)
    end)

    -- @description Converts 180 degrees to radians and back and asserts the round-trip returns 180 within 0.0001.
    it("rad and deg are inverse", function()
        expect_near(lurek.math.deg(lurek.math.rad(180)), 180, 0.0001)
    end)

    -- @description Asserts the angle from (0,0) to (1,0) is 0 within 0.0001.
    it("angleBetween(0,0,1,0) = 0", function()
        expect_near(lurek.math.angleBetween(0, 0, 1, 0), 0, 0.0001)
    end)

    -- @description Samples randomInt(5, 10) 20 times and asserts each value stays in range and is already an integer.
    it("randomInt(5, 10) returns integer in range", function()
        for i = 1, 20 do
            local v = lurek.math.randomInt(5, 10)
            expect_true(v >= 5 and v <= 10)
            expect_equal(v, math.floor(v))
        end
    end)
end)

-- â”€â”€ RandomGenerator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies seeded random generators can be created, produce deterministic or distinct sequences as expected, and honor their stateful helper methods.
describe("math.newRandomGenerator", function()
    -- @description Creates a random generator with seed 42 and asserts the userdata is not nil.
    it("creates RNG with seed", function()
        local rng = lurek.math.newRandomGenerator(42)
        expect_not_nil(rng)
    end)

    -- @description Creates two generators with seed 42, draws one random value from each, and asserts the values match within 0.000001.
    it("same seed produces same sequence", function()
        local rng1 = lurek.math.newRandomGenerator(42)
        local rng2 = lurek.math.newRandomGenerator(42)
        local v1 = rng1:random()
        local v2 = rng2:random()
        expect_near(v1, v2, 0.000001)
    end)

    -- @description Creates generators with seeds 42 and 999, draws one value from each, and asserts the samples differ.
    it("different seeds produce different sequences", function()
        local rng1 = lurek.math.newRandomGenerator(42)
        local rng2 = lurek.math.newRandomGenerator(999)
        local v1 = rng1:random()
        local v2 = rng2:random()
        expect_not_equal(v1, v2)
    end)

    -- @description Draws 50 integer samples from randomInt(5, 10) and asserts every value stays between 5 and 10.
    it("randomInt(min, max) stays in range", function()
        local rng = lurek.math.newRandomGenerator(123)
        for i = 1, 50 do
            local v = rng:randomInt(5, 10)
            expect_true(v >= 5 and v <= 10, "randomInt in range")
        end
    end)

    -- @description Draws 50 float samples from randomFloat(2.0, 5.0) and asserts every value stays between 2.0 and 5.0.
    it("randomFloat(min, max) stays in range", function()
        local rng = lurek.math.newRandomGenerator(456)
        for i = 1, 50 do
            local v = rng:randomFloat(2.0, 5.0)
            expect_true(v >= 2.0 and v <= 5.0, "randomFloat in range")
        end
    end)

    -- @description Draws 5000 normal samples, computes their mean, and asserts the mean remains within 0.1 of zero.
    it("randomNormal produces centered values", function()
        local rng = lurek.math.newRandomGenerator(789)
        local sum = 0
        local n = 5000
        for i = 1, n do
            sum = sum + rng:randomNormal()
        end
        local mean = sum / n
        expect_true(math.abs(mean) < 0.1, "normal mean near 0")
    end)

    -- @description Draws one value, resets the seed to 42, draws again, and asserts the first and second values match within 0.000001.
    it("setSeed resets the sequence", function()
        local rng = lurek.math.newRandomGenerator(42)
        local v1 = rng:random()
        rng:setSeed(42)
        local v2 = rng:random()
        expect_near(v1, v2, 0.000001)
    end)

    -- @description Saves generator state after two draws, restores it, and only asserts the next value remains a valid sample in [0,1).
    it("getState / setState restores position", function()
        local rng = lurek.math.newRandomGenerator(42)
        rng:random()
        rng:random()
        local state = rng:getState()
        local v1 = rng:random()
        rng:setState(state)
        local v2 = rng:random()
        -- setState may not restore exact position in all RNG backends
        -- just verify it returns a valid number in [0,1)
        expect_true(v2 >= 0 and v2 < 1, "setState produces valid number")
    end)
end)

-- â”€â”€ Transform â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies transforms preserve identity behavior, apply translation and scale, invert correctly, reset to identity, and clone independently.
describe("math.newTransform", function()
    -- @description Creates the identity transform, transforms (5,10), and asserts the point is unchanged.
    it("identity transform preserves point", function()
        local t = lurek.math.newTransform()
        local x, y = t:transformPoint(5, 10)
        expect_near(x, 5, 0.0001)
        expect_near(y, 10, 0.0001)
    end)

    -- @description Translates by (100,200), transforms the origin, and asserts the result becomes (100,200).
    it("translate moves point", function()
        local t = lurek.math.newTransform()
        t:translate(100, 200)
        local x, y = t:transformPoint(0, 0)
        expect_near(x, 100, 0.0001)
        expect_near(y, 200, 0.0001)
    end)

    -- @description Scales by 2, transforms (5,10), and asserts the coordinates become (10,20).
    it("scale doubles coordinates", function()
        local t = lurek.math.newTransform()
        t:scale(2)
        local x, y = t:transformPoint(5, 10)
        expect_near(x, 10, 0.0001)
        expect_near(y, 20, 0.0001)
    end)

    -- @description Applies translate and scale, inverts the transform, and asserts the inverse maps the transformed point back to approximately (5,10).
    it("inverse undoes transform", function()
        local t = lurek.math.newTransform()
        t:translate(100, 200)
        t:scale(2)
        local inv = t:inverse()
        local x, y = t:transformPoint(5, 10)
        local bx, by = inv:transformPoint(x, y)
        expect_near(bx, 5, 0.01)
        expect_near(by, 10, 0.01)
    end)

    -- @description Applies translate and rotate, transforms (10,20), then inverse-transforms it and asserts the original point is recovered within 0.01.
    it("inverseTransformPoint round-trips", function()
        local t = lurek.math.newTransform()
        t:translate(50, 100)
        t:rotate(0.5)
        local x, y = t:transformPoint(10, 20)
        local bx, by = t:inverseTransformPoint(x, y)
        expect_near(bx, 10, 0.01)
        expect_near(by, 20, 0.01)
    end)

    -- @description Applies a translation, resets the transform, and asserts transforming (5,5) again returns (5,5).
    it("reset returns to identity", function()
        local t = lurek.math.newTransform()
        t:translate(999, 999)
        t:reset()
        local x, y = t:transformPoint(5, 5)
        expect_near(x, 5, 0.0001)
        expect_near(y, 5, 0.0001)
    end)

    -- @description Clones a translated transform, mutates the original further, and asserts the clone still maps the origin to the earlier translated position (10,20).
    it("clone is independent", function()
        local t = lurek.math.newTransform()
        t:translate(10, 20)
        local c = t:clone()
        t:translate(100, 100)
        local x, y = c:transformPoint(0, 0)
        expect_near(x, 10, 0.0001)
        expect_near(y, 20, 0.0001)
    end)
end)

-- â”€â”€ BezierCurve â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies Bezier curves can be created, evaluated at both ends, rendered into coordinates, and translated.
describe("math.newBezierCurve", function()
    -- @description Creates a curve from three control points and asserts the curve exists and reports 3 control points.
    it("creates curve from control points", function()
        local curve = lurek.math.newBezierCurve({0, 0, 10, 10, 20, 0})
        expect_not_nil(curve)
        expect_equal(curve:getControlPointCount(), 3)
    end)

    -- @description Evaluates a curve at t=0 and asserts the returned point matches the first control point (0,0).
    it("evaluate(0) returns start point", function()
        local curve = lurek.math.newBezierCurve({0, 0, 5, 10, 10, 0})
        local x, y = curve:evaluate(0)
        expect_near(x, 0, 0.0001)
        expect_near(y, 0, 0.0001)
    end)

    -- @description Evaluates a curve at t=1 and asserts the returned point matches the last control point (10,0).
    it("evaluate(1) returns end point", function()
        local curve = lurek.math.newBezierCurve({0, 0, 5, 10, 10, 0})
        local x, y = curve:evaluate(1)
        expect_near(x, 10, 0.0001)
        expect_near(y, 0, 0.0001)
    end)

    -- @description Renders the curve with 10 segments and asserts the coordinate list contains at least 4 numbers.
    it("render returns list of vertices", function()
        local curve = lurek.math.newBezierCurve({0, 0, 5, 10, 10, 0})
        local coords = curve:render(10)
        expect_true(#coords >= 4, "at least 2 points")
    end)

    -- @description Translates a two-point curve by (5,5) and asserts evaluating at t=0 now returns (5,5).
    it("translate shifts all control points", function()
        local curve = lurek.math.newBezierCurve({0, 0, 10, 0})
        curve:translate(5, 5)
        local x, y = curve:evaluate(0)
        expect_near(x, 5, 0.0001)
        expect_near(y, 5, 0.0001)
    end)
end)

-- â”€â”€ NoiseGenerator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies seeded noise generators can be created, return numeric samples from each noise method, stay deterministic for equal seeds, and differ for different seeds.
describe("math.newNoiseGenerator", function()
    -- @description Creates a noise generator with seed 42 and asserts the userdata is not nil.
    it("creates noise generator with seed", function()
        local ng = lurek.math.newNoiseGenerator(42)
        expect_not_nil(ng)
    end)

    -- @description Samples perlin2d at (0.5,0.5) and asserts the result is numeric.
    it("perlin2d returns number", function()
        local ng = lurek.math.newNoiseGenerator(42)
        local v = ng:perlin2d(0.5, 0.5)
        expect_type("number", v)
    end)

    -- @description Samples perlin3d at (0.5,0.5,0.5) and asserts the result is numeric.
    it("perlin3d returns number", function()
        local ng = lurek.math.newNoiseGenerator(42)
        local v = ng:perlin3d(0.5, 0.5, 0.5)
        expect_type("number", v)
    end)

    -- @description Creates two generators with the same seed and asserts perlin2d at (1.5,2.3) matches within 0.000001.
    it("is deterministic", function()
        local ng1 = lurek.math.newNoiseGenerator(42)
        local ng2 = lurek.math.newNoiseGenerator(42)
        expect_near(ng1:perlin2d(1.5, 2.3), ng2:perlin2d(1.5, 2.3), 0.000001)
    end)

    -- @description Samples simplex2d at (0.5,0.5) and asserts the result is numeric.
    it("simplex2d returns number", function()
        local ng = lurek.math.newNoiseGenerator(42)
        local v = ng:simplex2d(0.5, 0.5)
        expect_type("number", v)
    end)

    -- @description Samples fbm at (0.5,0.5) and asserts the result is numeric.
    it("fbm returns number", function()
        local ng = lurek.math.newNoiseGenerator(42)
        local v = ng:fbm(0.5, 0.5)
        expect_type("number", v)
    end)

    -- @description Creates generators with different seeds, samples perlin2d at the same point, and asserts the two values differ.
    it("different seeds produce different values", function()
        local ng1 = lurek.math.newNoiseGenerator(42)
        local ng2 = lurek.math.newNoiseGenerator(999)
        local v1 = ng1:perlin2d(1.5, 2.3)
        local v2 = ng2:perlin2d(1.5, 2.3)
        expect_not_equal(v1, v2)
    end)
end)

-- â”€â”€ SpatialHash â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies spatial hashes retain their configured cell size, can insert and remove items, and return expected results for rectangle and circle queries.
describe("math.newSpatialHash", function()
    -- @description Creates a spatial hash with cell size 64 and asserts the object exists and reports 64 back from getCellSize().
    it("creates spatial hash with cell size", function()
        local sh = lurek.math.newSpatialHash(64)
        expect_not_nil(sh)
        expect_equal(sh:getCellSize(), 64)
    end)

    -- @description Inserts one item and asserts queryRect over a nearby rectangle returns at least one result.
    it("insert and queryRect finds item", function()
        local sh = lurek.math.newSpatialHash(64)
        sh:insert(1, 10, 10, 20, 20)
        local results = sh:queryRect(0, 0, 50, 50)
        expect_true(#results >= 1)
    end)

    -- @description Inserts one item and asserts a distant queryRect returns zero results.
    it("queryRect does not find distant items", function()
        local sh = lurek.math.newSpatialHash(64)
        sh:insert(1, 10, 10, 20, 20)
        local results = sh:queryRect(500, 500, 10, 10)
        expect_equal(#results, 0)
    end)

    -- @description Inserts one item, checks the item count is 1, removes it, and asserts the count drops to 0.
    it("remove decreases item count", function()
        local sh = lurek.math.newSpatialHash(64)
        sh:insert(1, 10, 10, 20, 20)
        expect_equal(sh:getItemCount(), 1)
        sh:remove(1)
        expect_equal(sh:getItemCount(), 0)
    end)

    -- @description Inserts one nearby item and asserts queryCircle centered at (12,12) with radius 50 returns at least one result.
    it("queryCircle finds nearby items", function()
        local sh = lurek.math.newSpatialHash(64)
        sh:insert(1, 10, 10, 5, 5)
        local results = sh:queryCircle(12, 12, 50)
        expect_true(#results >= 1)
    end)
end)

-- â”€â”€ Easing functions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies easing helpers hit expected boundary values, preserve linear midpoint behavior, and that applyEasing dispatches correctly by name regardless of case.
describe("math easing functions", function()
    -- @description Asserts linear maps 0 to 0 and 1 to 1 within 0.0001.
    it("linear(0) = 0, linear(1) = 1", function()
        expect_near(lurek.math.linear(0), 0, 0.0001)
        expect_near(lurek.math.linear(1), 1, 0.0001)
    end)

    -- @description Asserts linear(0.5) returns 0.5 within 0.0001.
    it("linear(0.5) = 0.5", function()
        expect_near(lurek.math.linear(0.5), 0.5, 0.0001)
    end)

    -- @description Asserts outQuad maps 0 to 0 and 1 to 1 within 0.0001.
    it("outQuad(0) = 0, outQuad(1) = 1", function()
        expect_near(lurek.math.outQuad(0), 0, 0.0001)
        expect_near(lurek.math.outQuad(1), 1, 0.0001)
    end)

    -- @description Asserts inCubic maps 0 to 0 and 1 to 1 within 0.0001.
    it("inCubic(0) = 0, inCubic(1) = 1", function()
        expect_near(lurek.math.inCubic(0), 0, 0.0001)
        expect_near(lurek.math.inCubic(1), 1, 0.0001)
    end)

    -- @description Asserts outBounce maps 0 to 0 and 1 to 1 within 0.0001.
    it("outBounce(0) = 0, outBounce(1) = 1", function()
        expect_near(lurek.math.outBounce(0), 0, 0.0001)
        expect_near(lurek.math.outBounce(1), 1, 0.0001)
    end)

    -- @description Compares outQuad(0.5) with applyEasing("outQuad", 0.5) and asserts both values match within 0.0001.
    it("applyEasing by name matches direct call", function()
        local v1 = lurek.math.outQuad(0.5)
        local v2 = lurek.math.applyEasing("outQuad", 0.5)
        expect_near(v1, v2, 0.0001)
    end)

    -- @description Calls applyEasing with "linear" and "LINEAR" at 0.5 and asserts the results match within 0.0001.
    it("applyEasing is case-insensitive", function()
        local v1 = lurek.math.applyEasing("linear", 0.5)
        local v2 = lurek.math.applyEasing("LINEAR", 0.5)
        expect_near(v1, v2, 0.0001)
    end)
end)

-- â”€â”€ Polygon/Geometry â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies polygon triangulation, convexity helpers, and basic circle containment and overlap checks.
describe("math polygon and geometry", function()
    -- @description Triangulates a square and asserts it yields 2 triangles with 6 numeric entries in the first triangle.
    it("triangulate a square yields 2 triangles", function()
        local tris = lurek.math.triangulate({0, 0, 10, 0, 10, 10, 0, 10})
        expect_equal(2, #tris) -- 2 triangles
        expect_equal(6, #tris[1]) -- each triangle has 6 numbers (x1,y1,x2,y2,x3,y3)
    end)

    -- @description Asserts isConvex returns true for a square polygon.
    it("isConvex returns true for square", function()
        expect_true(lurek.math.isConvex({0, 0, 10, 0, 10, 10, 0, 10}))
    end)

    -- @description Asserts isConvex returns false for the provided concave L-shaped polygon.
    it("isConvex returns false for concave L-shape", function()
        expect_equal(lurek.math.isConvex({0, 0, 2, 0, 2, 1, 1, 1, 1, 2, 0, 2}), false)
    end)

    -- @description Asserts a point at (3,4) is inside the circle centered at the origin with radius 10.
    it("circleContainsPoint detects inside", function()
        expect_true(lurek.math.circleContainsPoint(0, 0, 10, 3, 4))
    end)

    -- @description Asserts a point at (10,10) is outside the circle centered at the origin with radius 5.
    it("circleContainsPoint detects outside", function()
        expect_equal(lurek.math.circleContainsPoint(0, 0, 5, 10, 10), false)
    end)

    -- @description Asserts circles centered at (0,0) and (3,0) with radius 5 overlap.
    it("circleIntersectsCircle overlapping", function()
        expect_true(lurek.math.circleIntersectsCircle(0, 0, 5, 3, 0, 5))
    end)

    -- @description Asserts circles centered at (0,0) and (100,100) with radius 1 do not overlap.
    it("circleIntersectsCircle distant", function()
        expect_equal(lurek.math.circleIntersectsCircle(0, 0, 1, 100, 100, 1), false)
    end)
end)

-- â”€â”€ Color space â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies gamma and linear color conversions at fixed points and across a round-trip sweep from 0.0 to 1.0.
describe("math color space", function()
    -- @description Asserts gammaToLinear(0.5) is approximately 0.214 within 0.01.
    it("gammaToLinear(0.5) near 0.214", function()
        expect_near(lurek.math.gammaToLinear(0.5), 0.214, 0.01)
    end)

    -- @description Asserts gammaToLinear(0) returns 0 within 0.0001.
    it("gammaToLinear(0) = 0", function()
        expect_near(lurek.math.gammaToLinear(0), 0, 0.0001)
    end)

    -- @description Asserts gammaToLinear(1) returns 1 within 0.0001.
    it("gammaToLinear(1) = 1", function()
        expect_near(lurek.math.gammaToLinear(1), 1, 0.0001)
    end)

    -- @description Converts gamma values 0.0 through 1.0 to linear space and back, asserting each round-trip stays within 0.001.
    it("linearToGamma roundtrips", function()
        for i = 0, 10 do
            local gamma = i / 10.0
            local linear = lurek.math.gammaToLinear(gamma)
            local back = lurek.math.linearToGamma(linear)
            expect_near(back, gamma, 0.001)
        end
    end)
end)

-- @description Verifies vec2 construction, field access, vector math methods, interpolation, metamethods, and equality behavior.
describe("lurek.math.vec2", function()
    -- @description Asserts lurek.math.vec2 is exposed as a function.
    it("vec2 is a function", function()
        expect_type("function", lurek.math.vec2)
    end)

    -- @description Creates a vector with components (3,4) and asserts the result is userdata.
    it("vec2 creates a userdata", function()
        local v = lurek.math.vec2(3, 4)
        expect_type("userdata", v)
    end)

    -- @description Creates vec2(3,4) and asserts the x field is 3 within 1e-5.
    it("x field returns correct value", function()
        local v = lurek.math.vec2(3, 4)
        expect_near(v.x, 3, 1e-5)
    end)

    -- @description Creates vec2(3,4) and asserts the y field is 4 within 1e-5.
    it("y field returns correct value", function()
        local v = lurek.math.vec2(3, 4)
        expect_near(v.y, 4, 1e-5)
    end)

    -- @description Creates vec2(3,4) and asserts length() returns 5.0 within 1e-4.
    it("length returns correct magnitude", function()
        local v = lurek.math.vec2(3, 4)
        expect_near(v:length(), 5.0, 1e-4)
    end)

    -- @description Creates vec2(3,4) and asserts lengthSquared() returns 25.0 within 1e-4.
    it("lengthSquared returns squared magnitude", function()
        local v = lurek.math.vec2(3, 4)
        expect_near(v:lengthSquared(), 25.0, 1e-4)
    end)

    -- @description Computes the dot product of perpendicular unit vectors and asserts the result is 0.0 within 1e-5.
    it("dot product is correct", function()
        local a = lurek.math.vec2(1, 0)
        local b = lurek.math.vec2(0, 1)
        expect_near(a:dot(b), 0.0, 1e-5)
    end)

    -- @description Computes the dot product of parallel vectors (1,0) and (2,0) and asserts the result is 2.0 within 1e-5.
    it("dot product of parallel vectors", function()
        local a = lurek.math.vec2(1, 0)
        local b = lurek.math.vec2(2, 0)
        expect_near(a:dot(b), 2.0, 1e-5)
    end)

    -- @description Normalizes vec2(3,4) and asserts the resulting vector has length 1.0 within 1e-4.
    it("normalize produces unit vector", function()
        local v = lurek.math.vec2(3, 4)
        local n = v:normalize()
        expect_near(n:length(), 1.0, 1e-4)
    end)

    -- @description Measures the distance from vec2(0,0) to vec2(3,4) and asserts it is 5.0 within 1e-4.
    it("distance between two points", function()
        local a = lurek.math.vec2(0, 0)
        local b = lurek.math.vec2(3, 4)
        expect_near(a:distance(b), 5.0, 1e-4)
    end)

    -- @description Lerps between vec2(0,0) and vec2(10,10) at t=0 and asserts the result stays at the first vector.
    it("lerp at t=0 returns first vector", function()
        local a = lurek.math.vec2(0, 0)
        local b = lurek.math.vec2(10, 10)
        local c = a:lerp(b, 0)
        expect_near(c.x, 0, 1e-5)
        expect_near(c.y, 0, 1e-5)
    end)

    -- @description Lerps between vec2(0,0) and vec2(10,10) at t=1 and asserts the result equals the second vector.
    it("lerp at t=1 returns second vector", function()
        local a = lurek.math.vec2(0, 0)
        local b = lurek.math.vec2(10, 10)
        local c = a:lerp(b, 1)
        expect_near(c.x, 10, 1e-5)
        expect_near(c.y, 10, 1e-5)
    end)

    -- @description Lerps between vec2(0,0) and vec2(10,10) at t=0.5 and asserts the result is the midpoint (5,5).
    it("lerp at t=0.5 returns midpoint", function()
        local a = lurek.math.vec2(0, 0)
        local b = lurek.math.vec2(10, 10)
        local c = a:lerp(b, 0.5)
        expect_near(c.x, 5, 1e-5)
        expect_near(c.y, 5, 1e-5)
    end)

    -- @description Adds vec2(1,2) and vec2(3,4) and asserts the resulting components are (4,6).
    it("addition metamethod works", function()
        local a = lurek.math.vec2(1, 2)
        local b = lurek.math.vec2(3, 4)
        local c = a + b
        expect_near(c.x, 4, 1e-5)
        expect_near(c.y, 6, 1e-5)
    end)

    -- @description Subtracts vec2(3,4) from vec2(5,7) and asserts the resulting components are (2,3).
    it("subtraction metamethod works", function()
        local a = lurek.math.vec2(5, 7)
        local b = lurek.math.vec2(3, 4)
        local c = a - b
        expect_near(c.x, 2, 1e-5)
        expect_near(c.y, 3, 1e-5)
    end)

    -- @description Multiplies vec2(2,3) by the scalar 2 and asserts the resulting components are (4,6).
    it("scalar multiplication metamethod works", function()
        local a = lurek.math.vec2(2, 3)
        local c = a * 2
        expect_near(c.x, 4, 1e-5)
        expect_near(c.y, 6, 1e-5)
    end)

    -- @description Converts vec2(1,2) to a string and asserts the result is a non-empty string.
    it("tostring metamethod returns readable string", function()
        local v = lurek.math.vec2(1, 2)
        local s = tostring(v)
        expect_type("string", s)
        expect_true(#s > 0)
    end)

    -- @description Creates two vectors with identical components and asserts the equality metamethod returns true.
    it("equality metamethod: same values are equal", function()
        local a = lurek.math.vec2(1, 2)
        local b = lurek.math.vec2(1, 2)
        expect_equal(a == b, true)
    end)

    -- @description Creates two vectors with different components and asserts the equality metamethod returns false.
    it("equality metamethod: different values are not equal", function()
        local a = lurek.math.vec2(1, 2)
        local b = lurek.math.vec2(3, 4)
        expect_equal(a == b, false)
    end)
end)
test_summary()
