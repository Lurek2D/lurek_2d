-- tests/lua/unit/test_procgen_noise_unit.lua
-- Unit tests for lurek.procgen noise generation: standalone functions and generator object methods.

-- @describe Procgen noise generation (consolidated from math)
describe("lurek.procgen noise", function()
    -- @covers lurek.procgen.newNoiseGenerator
    it("creates a noise generator with seed", function()
        local gen = lurek.procgen.newNoiseGenerator(42)
        expect_not_nil(gen, "generator should be created")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("creates a noise generator without seed (defaults to 0)", function()
        local gen = lurek.procgen.newNoiseGenerator()
        expect_not_nil(gen, "generator should be created without seed")
    end)

    -- @covers lurek.procgen.perlin2d
    it("generates deterministic perlin2d values", function()
        local v1 = lurek.procgen.perlin2d(1.5, 2.3, 42)
        local v2 = lurek.procgen.perlin2d(1.5, 2.3, 42)
        expect_near(v1, v2, 0.0001)
    end)

    -- @covers lurek.procgen.perlin2d
    it("perlin2d output in [-1, 1] range", function()
        local v = lurek.procgen.perlin2d(0.5, 0.5, 1)
        expect_in_range(v, -1.0, 1.0, "perlin2d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.perlin3d
    it("perlin3d output in [-1, 1] range", function()
        local v = lurek.procgen.perlin3d(0.5, 0.5, 0.5, 1)
        expect_in_range(v, -1.0, 1.0, "perlin3d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.simplex2d
    it("simplex2d generates values in range", function()
        local v = lurek.procgen.simplex2d(1.0, 1.0)
        expect_in_range(v, -1.0, 1.0, "simplex2d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.fbm
    it("fbm generates fractal brownian motion", function()
        local v = lurek.procgen.fbm(0.5, 0.5, 42, 4, 2.0, 0.5)
        expect_type("number", v, "fbm should return number")
    end)

    -- @covers lurek.procgen.fbm
    it("fbm with default params returns number", function()
        local v = lurek.procgen.fbm(1.0, 1.0)
        expect_type("number", v, "fbm with defaults should return number")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("generator perlin2d method works", function()
        local gen = lurek.procgen.newNoiseGenerator(100)
        local v = gen:perlin2d(0.5, 0.5)
        expect_in_range(v, -1.0, 1.0, "gen:perlin2d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("generator simplex2d method works", function()
        local gen = lurek.procgen.newNoiseGenerator(200)
        local v = gen:simplex2d(1.0, 2.0)
        expect_in_range(v, -1.0, 1.0, "gen:simplex2d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("generator perlin3d method works", function()
        local gen = lurek.procgen.newNoiseGenerator(300)
        local v = gen:perlin3d(0.1, 0.2, 0.3)
        expect_in_range(v, -1.0, 1.0, "gen:perlin3d should be in [-1,1]")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("generator fbm method returns number", function()
        local gen = lurek.procgen.newNoiseGenerator(400)
        local v = gen:fbm(0.5, 0.5, 4, 2.0, 0.5)
        expect_type("number", v, "fbm should return number")
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("different seeds produce different perlin2d values", function()
        local gen1 = lurek.procgen.newNoiseGenerator(1)
        local gen2 = lurek.procgen.newNoiseGenerator(999)
        local v1 = gen1:perlin2d(5.3, 5.7)
        local v2 = gen2:perlin2d(5.3, 5.7)
        -- With different seeds, values should differ (extremely unlikely to match)
        expect_not_equal(v1, v2, "different seeds should produce different perlin2d values")
    end)

    -- @covers lurek.procgen.perlin2d
    it("perlin2d differs with different seeds", function()
        local v1 = lurek.procgen.perlin2d(3.3, 7.7, 10)
        local v2 = lurek.procgen.perlin2d(3.3, 7.7, 20)
        expect_not_equal(v1, v2, "different seeds should produce different values")
    end)
end)

test_summary()
