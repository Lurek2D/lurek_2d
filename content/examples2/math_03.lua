--- Math Module Part 4: noise — LNoiseGenerator + stateless noise functions

--@api-stub: lurek.math.newNoiseGenerator
-- Creates a noise generator with an optional seed.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(42)
    print("seed = " .. ng:getSeed())
end

--@api-stub: LNoiseGenerator:perlin1d
--@api-stub: LNoiseGenerator:perlin2d
--@api-stub: LNoiseGenerator:perlin3d
--@api-stub: LNoiseGenerator:perlin4d
-- Samples Perlin noise at various dimensions.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(123)
    local v1 = ng:perlin1d(1.5)
    local v2 = ng:perlin2d(1.5, 2.5)
    local v3 = ng:perlin3d(1.0, 2.0, 3.0)
    local v4 = ng:perlin4d(1.0, 2.0, 3.0, 4.0)
    print("perlin1d=" .. v1 .. " 2d=" .. v2 .. " 3d=" .. v3 .. " 4d=" .. v4)
end

--@api-stub: LNoiseGenerator:simplex1d
--@api-stub: LNoiseGenerator:simplex2d
--@api-stub: LNoiseGenerator:simplex3d
-- Samples simplex noise at various dimensions.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(99)
    local s1 = ng:simplex1d(0.7)
    local s2 = ng:simplex2d(0.7, 1.3)
    local s3 = ng:simplex3d(0.7, 1.3, 2.1)
    print("simplex1d=" .. s1 .. " 2d=" .. s2 .. " 3d=" .. s3)
end

--@api-stub: LNoiseGenerator:worley2d
--@api-stub: LNoiseGenerator:worley3d
-- Samples Worley (cellular) noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(55)
    local w2 = ng:worley2d(3.5, 4.5)
    local w2m = ng:worley2d(3.5, 4.5, "manhattan")
    local w2f = ng:worley2d(3.5, 4.5, "euclidean", true)
    local w3 = ng:worley3d(1.0, 2.0, 3.0)
    print("worley2d=" .. w2 .. " manhattan=" .. w2m .. " f2=" .. w2f .. " 3d=" .. w3)
end

--@api-stub: LNoiseGenerator:fbm
-- Fractal Brownian motion noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:fbm(2.5, 3.5)
    local v2 = ng:fbm(2.5, 3.5, 6, 2.0, 0.5, "simplex")
    print("fbm default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:ridged
-- Ridged fractal noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:ridged(2.5, 3.5)
    local v2 = ng:ridged(2.5, 3.5, 8, 2.5, 0.6, "perlin")
    print("ridged default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:turbulence
-- Turbulence fractal noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(7)
    local v = ng:turbulence(1.0, 2.0)
    local v2 = ng:turbulence(1.0, 2.0, 5, 2.0, 0.5, "simplex")
    print("turbulence default=" .. v .. " custom=" .. v2)
end

--@api-stub: LNoiseGenerator:warpDomain
-- Domain-warped noise.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(13)
    local v = ng:warpDomain(3.0, 4.0, 0.5)
    print("warped = " .. v)
end

--@api-stub: LNoiseGenerator:generateMap
-- Generates a flat array noise map.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMap(16, 16, {scale = 4.0, octaves = 4, kind = "perlin"})
    print("map size = " .. #map .. " sample = " .. map[1])
end

--@api-stub: LNoiseGenerator:generateMapCompute
-- Generates a noise map through the compute backend.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(1)
    local map = ng:generateMapCompute(32, 32, {scale = 8.0})
    print("compute map size = " .. #map)
end

--@api-stub: LNoiseGenerator:setSeed
--@api-stub: LNoiseGenerator:getSeed
-- Changes the noise seed.
do
    ---@type LNoiseGenerator
    local ng = lurek.math.newNoiseGenerator(0)
    ng:setSeed(999)
    print("new seed = " .. ng:getSeed())
end

-- Stateless 2D Perlin noise.
--@api-stub: lurek.math.perlin2d
do
    local v = lurek.math.perlin2d(5.0, 3.0)
    local v2 = lurek.math.perlin2d(5.0, 3.0, 42)
    print("stateless perlin2d = " .. v .. " seeded = " .. v2)
end

-- Stateless 3D Perlin noise.
do
    local v = lurek.math.perlin3d(1.0, 2.0, 3.0)
    local v2 = lurek.math.perlin3d(1.0, 2.0, 3.0, 77)
    print("stateless perlin3d = " .. v .. " seeded = " .. v2)
end

-- Stateless 2D simplex noise.
--@api-stub: lurek.math.simplex2d
do
    local v = lurek.math.simplex2d(2.0, 3.0)
    local v2 = lurek.math.simplex2d(2.0, 3.0, 10)
    print("stateless simplex2d = " .. v .. " seeded = " .. v2)
end

-- Stateless 2D/3D simplex noise.
do
    local v2d = lurek.math.simplexNoise(4.0, 5.0)
    local v3d = lurek.math.simplexNoise(4.0, 5.0, 6.0)
    print("simplexNoise 2d=" .. v2d .. " 3d=" .. v3d)
end

-- Stateless fractal Brownian motion.
--@api-stub: lurek.math.fbm
do
    local v = lurek.math.fbm(1.0, 2.0, 42)
    local v2 = lurek.math.fbm(1.0, 2.0, 42, 6, 2.0, 0.5)
    print("stateless fbm = " .. v .. " custom = " .. v2)
end

print("math_03.lua")
