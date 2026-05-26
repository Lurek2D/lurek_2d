-- Lurek2D Color API Tests

-- @describe lurek.color constants
describe("lurek.color constants", function()
    -- @covers lurek.color.WHITE
    it("WHITE is {1,1,1,1}", function()
        local c = lurek.color.WHITE
        expect_near(1.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.BLACK
    it("BLACK is {0,0,0,1}", function()
        local c = lurek.color.BLACK
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.RED
    it("RED is {1,0,0,1}", function()
        local c = lurek.color.RED
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.GREEN
    it("GREEN is {0,1,0,1}", function()
        local c = lurek.color.GREEN
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.BLUE
    it("BLUE is {0,0,1,1}", function()
        local c = lurek.color.BLUE
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.YELLOW
    it("YELLOW is {1,1,0,1}", function()
        local c = lurek.color.YELLOW
        expect_near(1.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.CYAN
    it("CYAN is {0,1,1,1}", function()
        local c = lurek.color.CYAN
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.MAGENTA
    it("MAGENTA is {1,0,1,1}", function()
        local c = lurek.color.MAGENTA
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.TRANSPARENT
    it("TRANSPARENT is {0,0,0,0}", function()
        local c = lurek.color.TRANSPARENT
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(0.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.new
describe("lurek.color.new", function()
    -- @covers lurek.color.new
    it("creates color from float components", function()
        local c = lurek.color.new(0.5, 0.3, 0.7, 1.0)
        expect_near(0.5, c[1], 0.01)
        expect_near(0.3, c[2], 0.01)
        expect_near(0.7, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.new
    it("defaults alpha to 1.0 when omitted", function()
        local c = lurek.color.new(0.2, 0.4, 0.6)
        expect_near(0.2, c[1], 0.01)
        expect_near(0.4, c[2], 0.01)
        expect_near(0.6, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.fromU8
describe("lurek.color.fromU8", function()
    -- @covers lurek.color.fromU8
    it("creates RED from (255, 0, 0, 255)", function()
        local c = lurek.color.fromU8(255, 0, 0, 255)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.fromU8
    it("creates half-alpha color from (0, 128, 255, 128)", function()
        local c = lurek.color.fromU8(0, 128, 255, 128)
        expect_near(0.0, c[1], 0.01)
        expect_near(128 / 255, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(128 / 255, c[4], 0.01)
    end)

    -- @covers lurek.color.fromU8
    it("defaults alpha to 255 when omitted", function()
        local c = lurek.color.fromU8(0, 255, 0)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.fromHex
describe("lurek.color.fromHex", function()
    -- @covers lurek.color.fromHex
    it("parses #FF0000 as RED", function()
        local c = lurek.color.fromHex("#FF0000")
        expect_not_nil(c, "should not be nil")
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.fromHex
    it("parses #00FF0080 with alpha ~0.5", function()
        local c = lurek.color.fromHex("#00FF0080")
        expect_not_nil(c, "should not be nil")
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(128 / 255, c[4], 0.01)
    end)

    -- @covers lurek.color.fromHex
    it("returns nil on invalid hex string", function()
        local c = lurek.color.fromHex("invalid")
        expect_equal(nil, c)
    end)
end)

-- @describe lurek.color.fromHsl
describe("lurek.color.fromHsl", function()
    -- @covers lurek.color.fromHsl
    it("h=0, s=1, l=0.5 produces RED", function()
        local c = lurek.color.fromHsl(0, 1, 0.5)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.fromHsl
    it("h=120, s=1, l=0.5 produces GREEN", function()
        local c = lurek.color.fromHsl(120, 1, 0.5)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.fromHsl
    it("h=240, s=1, l=0.5 produces BLUE", function()
        local c = lurek.color.fromHsl(240, 1, 0.5)
        expect_near(0.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(1.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.fromHsv
describe("lurek.color.fromHsv", function()
    -- @covers lurek.color.fromHsv
    it("h=0, s=1, v=1 produces RED", function()
        local c = lurek.color.fromHsv(0, 1, 1)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.fromHsv
    it("h=120, s=1, v=1 produces GREEN", function()
        local c = lurek.color.fromHsv(120, 1, 1)
        expect_near(0.0, c[1], 0.01)
        expect_near(1.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)
end)

-- @describe lurek.color.toHsl
describe("lurek.color.toHsl", function()
    -- @covers lurek.color.toHsl
    it("converts pure red to h=0, s=1, l=0.5", function()
        local h, s, l = lurek.color.toHsl(1, 0, 0)
        expect_near(0, h, 1)
        expect_near(1, s, 0.01)
        expect_near(0.5, l, 0.01)
    end)

    -- @covers lurek.color.toHsl
    it("converts white to l=1, s=0", function()
        local h, s, l = lurek.color.toHsl(1, 1, 1)
        expect_near(0, s, 0.01)
        expect_near(1, l, 0.01)
    end)
end)

-- @describe lurek.color.toHex
describe("lurek.color.toHex", function()
    -- @covers lurek.color.toHex
    it("converts pure red to #FF0000", function()
        local hex = lurek.color.toHex(1, 0, 0, 1)
        expect_equal("#FF0000", hex)
    end)

    -- @covers lurek.color.toHex
    it("converts green to #00FF00", function()
        local hex = lurek.color.toHex(0, 1, 0, 1)
        expect_equal("#00FF00", hex)
    end)

    -- @covers lurek.color.toHex
    it("includes alpha when < 1", function()
        local hex = lurek.color.toHex(0, 0, 1, 0.5)
        -- alpha 0.5 * 255 ≈ 128 → hex 80
        expect_true(#hex > 7, "hex with alpha should be longer than #RRGGBB")
    end)
end)

-- @describe lurek.color.lerp
describe("lurek.color.lerp", function()
    -- @covers lurek.color.lerp
    it("interpolates red to blue at t=0.5", function()
        local c = lurek.color.lerp({1, 0, 0, 1}, {0, 0, 1, 1}, 0.5)
        expect_near(0.5, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.5, c[3], 0.01)
        expect_near(1.0, c[4], 0.01)
    end)

    -- @covers lurek.color.lerp
    it("t=0 returns start color", function()
        local c = lurek.color.lerp({1, 0, 0, 1}, {0, 1, 0, 1}, 0.0)
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
    end)

    -- @covers lurek.color.lerp
    it("t=1 returns end color", function()
        local c = lurek.color.lerp({1, 0, 0, 1}, {0, 1, 0, 1}, 1.0)
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
    it("alphaBlend with opaque foreground covers background", function()
        local c = lurek.color.alphaBlend({1, 0, 0, 1}, {0, 1, 0, 1})
        expect_near(1.0, c[1], 0.01)
        expect_near(0.0, c[2], 0.01)
        expect_near(0.0, c[3], 0.01)
    end)

    -- @covers lurek.color.alphaBlend
    it("alphaBlend with transparent foreground shows background", function()
        local c = lurek.color.alphaBlend({1, 0, 0, 0}, {0, 1, 0, 1})
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
    it("brightness of white is ~1.0", function()
        local b = lurek.color.brightness(1, 1, 1)
        expect_near(1.0, b, 0.01)
    end)

    -- @covers lurek.color.brightness
    it("brightness of black is ~0.0", function()
        local b = lurek.color.brightness(0, 0, 0)
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
    it("gammaToLinear converts 1.0 to 1.0", function()
        local v = lurek.color.gammaToLinear(1.0)
        expect_near(1.0, v, 0.01)
    end)

    -- @covers lurek.color.gammaToLinear
    it("gammaToLinear converts 0.0 to 0.0", function()
        local v = lurek.color.gammaToLinear(0.0)
        expect_near(0.0, v, 0.01)
    end)

    -- @covers lurek.color.linearToGamma
    it("linearToGamma converts 1.0 to 1.0", function()
        local v = lurek.color.linearToGamma(1.0)
        expect_near(1.0, v, 0.01)
    end)

    -- @covers lurek.color.linearToGamma
    it("linearToGamma converts 0.0 to 0.0", function()
        local v = lurek.color.linearToGamma(0.0)
        expect_near(0.0, v, 0.01)
    end)
end)

-- @describe lurek.color.palette
describe("lurek.color.palette", function()
    -- @covers lurek.color.palette
    it("pico8 palette has 16 entries", function()
        local pal = lurek.color.palette("pico8")
        expect_equal(16, #pal)
    end)

    -- @covers lurek.color.palette
    it("gameboy palette has 4 entries", function()
        local pal = lurek.color.palette("gameboy")
        expect_equal(4, #pal)
    end)

    -- @covers lurek.color.palette
    it("palette entries are RGBA tables", function()
        local pal = lurek.color.palette("pico8")
        local first = pal[1]
        expect_equal(4, #first)
        expect_true(first[1] >= 0 and first[1] <= 1, "r in range")
        expect_true(first[4] >= 0 and first[4] <= 1, "a in range")
    end)

    -- @covers lurek.color.palette
    it("unknown palette returns empty table", function()
        local pal = lurek.color.palette("nonexistent")
        expect_equal(0, #pal)
    end)
end)

test_summary()
