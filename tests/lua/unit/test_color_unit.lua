-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_color_core_unit.lua
do
-- Lurek2D Color API Tests

-- @describe lurek.color.new
describe("lurek.color.new", function()
    -- @covers lurek.color.new
    it("creates colors from float components with explicit and default alpha", function()
        local c = lurek.color.new(0.5, 0.3, 0.7, 1.0)
        expect_near(0.5, c[1], 0.01)
        expect_near(0.3, c[2], 0.01)
        expect_near(0.7, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.new(0.2, 0.4, 0.6)
        expect_near(0.2, c[1], 0.01)
        expect_near(0.4, c[2], 0.01)
        expect_near(0.6, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        expect_error(function()
            lurek.color.new(0 / 0, 0.4, 0.6, 1.0)
        end)
    end)
end)

-- @describe lurek.color.fromU8
describe("lurek.color.fromU8", function()
    -- @covers lurek.color.fromU8
    it("creates colors from RGBA bytes and defaults alpha to 255", function()
        local c = lurek.color.fromU8(255, 0, 0, 255)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromU8(0, 128, 255, 128)
        expect_near(0.0, c[1], 0.01)
        expect_near(128 / 255, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(128 / 255, c[4], 0.01)

        c = lurek.color.fromU8(0, 255, 0)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.fromHex
describe("lurek.color.fromHex", function()
    -- @covers lurek.color.fromHex
    it("parses rgb and rgba hex strings and rejects invalid input", function()
        local c = lurek.color.fromHex("#FF0000")
        expect_not_nil(c, "should not be nil")
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromHex("#00FF0080")
        expect_not_nil(c, "should not be nil")
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(128 / 255, c[4], 0.01)

        c = lurek.color.fromHex("invalid")
        expect_equal(nil, c)
    end)
end)

-- @describe lurek.color.fromHsl
describe("lurek.color.fromHsl", function()
    -- @covers lurek.color.fromHsl
    it("produces canonical primary colors", function()
        local c = lurek.color.fromHsl(0, 1, 0.5)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromHsl(120, 1, 0.5)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromHsl(240, 1, 0.5)
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.fromHsv
describe("lurek.color.fromHsv", function()
    -- @covers lurek.color.fromHsv
    it("produces canonical primary colors", function()
        local c = lurek.color.fromHsv(0, 1, 1)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromHsv(120, 1, 1)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.fromHsv(-120, 1, 1)
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
    end)
end)

-- @describe lurek.color.toHsl
describe("lurek.color.toHsl", function()
    -- @covers lurek.color.toHsl
    it("converts primary and neutral colors to expected HSL values", function()
        local h, s, l = lurek.color.toHsl(1, 0, 0)
        expect_near(0, h, 1)
        expect_near(1, s, 0.01)
        expect_near(0.5, l, 0.01)

        h, s, l = lurek.color.toHsl(1, 1, 1)
        expect_near(0, s, 0.01)
        expect_near(1, l, 0.01)
    end)
end)

-- @describe lurek.color.toHex
describe("lurek.color.toHex", function()
    -- @covers lurek.color.toHex
    it("converts rgb values and includes alpha when needed", function()
        local hex = lurek.color.toHex(1, 0, 0, 1)
        expect_equal("#FF0000", hex)

        hex = lurek.color.toHex(0, 1, 0, 1)
        expect_equal("#00FF00", hex)

        hex = lurek.color.toHex(0, 0, 1, 0.5)
        expect_true(#hex > 7, "hex with alpha should be longer than #RRGGBB")
    end)
end)

-- @describe lurek.color.lerp
describe("lurek.color.lerp", function()
    -- @covers lurek.color.lerp
    it("interpolates colors across midpoint and endpoints", function()
        local c = lurek.color.lerp({1, 0, 0, 1}, {0, 0, 1, 1}, 0.5)
        expect_near(0.5, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.5, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)

        c = lurek.color.lerp({1, 0, 0, 1}, {0, 1, 0, 1}, 0.0)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)

        c = lurek.color.lerp({1, 0, 0, 1}, {0, 1, 0, 1}, 1.0)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
    end)
end)

-- @describe lurek.color blending
describe("lurek.color blending", function()
    -- @covers lurek.color.multiply
    it("multiply white by half-gray yields half-gray", function()
        local c = lurek.color.multiply({1, 1, 1, 1}, {0.5, 0.5, 0.5, 1})
        expect_near(0.5, c[1], 0.01)
        expect_near(0.5, c[2], 0.01)
        expect_near(0.5, c[3], 0.01)
    end)

    -- @covers lurek.color.screen
    it("screen of black with any color returns that color", function()
        local c = lurek.color.screen({0, 0, 0, 1}, {0.7, 0.3, 0.5, 1})
        expect_near(0.7, c[1], 0.01)
        expect_near(0.3, c[2], 0.01)
        expect_near(0.5, c[3], 0.01)
    end)

    -- @covers lurek.color.overlay
    it("overlay produces valid result", function()
        local c = lurek.color.overlay({0.5, 0.5, 0.5, 1}, {0.8, 0.2, 0.6, 1})
        expect_true(c[1] >= 0 and c[1] <= 1, "r in range")
        expect_true(c[2] >= 0 and c[2] <= 1, "g in range")
        expect_true(c[3] >= 0 and c[3] <= 1, "b in range")
    end)

    -- @covers lurek.color.additive
    it("additive blend clamps to 1.0", function()
        local c = lurek.color.additive({0.8, 0.5, 0.3, 1}, {0.5, 0.7, 0.9, 1})
        expect_true(c[1] <= 1.0, "r clamped")
        expect_true(c[2] <= 1.0, "g clamped")
        expect_true(c[3] <= 1.0, "b clamped")
    end)

    -- @covers lurek.color.alphaBlend
    it("alphaBlend handles opaque and transparent foreground colors", function()
        local c = lurek.color.alphaBlend({1, 0, 0, 1}, {0, 1, 0, 1})
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)

        c = lurek.color.alphaBlend({1, 0, 0, 0}, {0, 1, 0, 1})
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
    end)
end)

-- @describe lurek.color utilities
describe("lurek.color utilities", function()
    -- @covers lurek.color.invert
    it("invert red produces cyan", function()
        local c = lurek.color.invert(1, 0, 0, 1)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.brightness
    it("brightness distinguishes white and black", function()
        local b = lurek.color.brightness(1, 1, 1)
        expect_near(1.0, b, 0.01)
        b = lurek.color.brightness(0, 0, 0)
        expect_near(0.0, b, 0.01)
    end)

    -- @covers lurek.color.withAlpha
    it("withAlpha replaces alpha channel", function()
        local c = lurek.color.withAlpha(1, 0, 0, 1, 0.5)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(0.5, c[4], 0.01)
    end)

    -- @covers lurek.color.gammaToLinear
    it("gammaToLinear converts endpoint values", function()
        local v = lurek.color.gammaToLinear(1.0)
        expect_near(1.0, v, 0.01)
        v = lurek.color.gammaToLinear(0.0)
        expect_near(0.0, v, 0.01)
        v = lurek.color.gammaToLinear(2.0)
        expect_near(1.0, v, 0.01)

        expect_error(function()
            lurek.color.gammaToLinear(0 / 0)
        end)
    end)

    -- @covers lurek.color.linearToGamma
    it("linearToGamma converts endpoint values", function()
        local v = lurek.color.linearToGamma(1.0)
        expect_near(1.0, v, 0.01)
        v = lurek.color.linearToGamma(0.0)
        expect_near(0.0, v, 0.01)
        v = lurek.color.linearToGamma(-1.0)
        expect_near(0.0, v, 0.01)

        expect_error(function()
            lurek.color.linearToGamma(0 / 0)
        end)
    end)
end)

-- @describe lurek.color.palette
describe("lurek.color.palette", function()
    -- @covers lurek.color.palette
    it("returns known palettes, valid rgba entries, and empty fallback for unknown names", function()
        local pal = lurek.color.palette("pico8")
        expect_equal(16, #pal)

        pal = lurek.color.palette("gameboy")
        expect_equal(4, #pal)

        local first = lurek.color.palette("pico8")[1]
        expect_equal(4, #first)
        expect_true(first[1] >= 0 and first[1] <= 1, "r in range")
        expect_true(first[4] >= 0 and first[4] <= 1, "a in range")

        pal = lurek.color.palette("nonexistent")
        expect_equal(0, #pal)
    end)
end)
end
-- END test_color_core_unit.lua

test_summary()
