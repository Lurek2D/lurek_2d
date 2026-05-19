--- Math Module: easing functions, applyEasing, LRandomGenerator, LNoiseGenerator

--@api-stub: lurek.math.inCubic
--@api-stub: lurek.math.inElastic
--@api-stub: lurek.math.inExpo
--@api-stub: lurek.math.inQuad
--@api-stub: lurek.math.inQuart
--@api-stub: lurek.math.inSine
--@api-stub: lurek.math.linear
-- In-family easing functions (t in [0,1] → eased value).
do
    local t = 0.5
    print(lurek.math.inBack(t))
    print(lurek.math.inBounce(t))
    print(lurek.math.inCubic(t))
    print(lurek.math.inElastic(t))
    print(lurek.math.inExpo(t))
    print(lurek.math.inQuad(t))
    print(lurek.math.inQuart(t))
    print(lurek.math.inSine(t))
    print(lurek.math.linear(t))
end

--@api-stub: lurek.math.outBack
--@api-stub: lurek.math.outBounce
--@api-stub: lurek.math.outCubic
--@api-stub: lurek.math.outElastic
--@api-stub: lurek.math.outExpo
--@api-stub: lurek.math.outQuad
--@api-stub: lurek.math.outQuart
--@api-stub: lurek.math.outSine
-- Out-family easing functions.
do
    local t = 0.5
    print(lurek.math.outBack(t))
    print(lurek.math.outBounce(t))
    print(lurek.math.outCubic(t))
    print(lurek.math.outElastic(t))
    print(lurek.math.outExpo(t))
    print(lurek.math.outQuad(t))
    print(lurek.math.outQuart(t))
    print(lurek.math.outSine(t))
end

--@api-stub: lurek.math.inOutBack
--@api-stub: lurek.math.inOutBounce
--@api-stub: lurek.math.inOutCubic
--@api-stub: lurek.math.inOutElastic
--@api-stub: lurek.math.inOutExpo
--@api-stub: lurek.math.inOutQuad
--@api-stub: lurek.math.inOutQuart
--@api-stub: lurek.math.inOutSine
-- InOut-family easing functions.
do
    local t = 0.5
    print(lurek.math.inOutBack(t))
    print(lurek.math.inOutBounce(t))
    print(lurek.math.inOutCubic(t))
    print(lurek.math.inOutElastic(t))
    print(lurek.math.inOutExpo(t))
    print(lurek.math.inOutQuad(t))
    print(lurek.math.inOutQuart(t))
    print(lurek.math.inOutSine(t))
end

--@api-stub: LRandomGenerator:getSeed
--@api-stub: LRandomGenerator:type
--@api-stub: LRandomGenerator:typeOf
-- Random generator extended operations.
do
    local rng = lurek.math.newRandomGenerator()
    local seed = rng:getSeed()
    print("seed = " .. seed)
    local state = rng:getState()
    print("state = " .. tostring(state))
    local f = rng:randomFloat(0.0, 1.0)
    local i = rng:randomInt(1, 100)
    local n = rng:randomNormal(0.0, 1.0)
    print("float=" .. f .. " int=" .. i .. " normal=" .. n)
    rng:setState(state)
    print(rng:type())
    print(rng:typeOf("LRandomGenerator"))
end

--@api-stub: lurek.math.perlin3d
--@api-stub: lurek.math.simplexNoise
-- Global noise functions (no generator instance needed).
do
    local v1 = lurek.math.fbm(0.5, 0.5, 4, 0.5, 2.0)
    local v2 = lurek.math.perlin2d(0.3, 0.7)
    local v3 = lurek.math.perlin3d(0.1, 0.2, 0.3)
    local v4 = lurek.math.simplex2d(0.4, 0.6)
    local v5 = lurek.math.simplexNoise(0.5, 0.5)
    print(v1, v2, v3, v4, v5)
end

--@api-stub: lurek.math.linearToGamma
--@api-stub: lurek.math.rgbToHsl
-- Color conversion utilities.
do
    local r, g, b, a = lurek.math.fromHex("#FF8800FF")
    print("hex", r, g, b, a)
    local lr = lurek.math.gammaToLinear(r)
    print("linear", lr)
    local gr = lurek.math.linearToGamma(lr)
    print("gamma", gr)
    local h, s, l = lurek.math.rgbToHsl(r, g, b)
    print("hsl", h, s, l)
    local r2, g2, b2 = lurek.math.hslToRgb(h, s, l)
    print("rgb", r2, g2, b2)
end

print("math_06.lua")
