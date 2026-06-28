-- content/examples/color.lua
-- Run: cargo run -- content/examples/color.lua

--- Color Examples: creation, conversion, blending, palettes, and utilities


--@api: lurek.color.new
do
    local c = lurek.color.new(0.2, 0.6, 0.9, 1.0)
    local h, s, l = lurek.color.toHsl(c[1], c[2], c[3])
    lurek.log.info(tostring("color r=" .. c[1] .. " g=" .. c[2] .. " b=" .. c[3] .. " a=" .. c[4]))
    lurek.log.info(tostring("hex = " .. lurek.color.toHex(c[1], c[2], c[3], c[4])))
    lurek.log.info(tostring("hsl = " .. string.format("%.1f, %.2f, %.2f", h, s, l)))
end

--@api: lurek.color.fromU8
do
    local c = lurek.color.fromU8(255, 128, 0, 255)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("fromU8 r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromU8 a=" .. string.format("%.2f", c[4])))
    lurek.log.info(tostring("fromU8 hex=" .. hex))
end

--@api: lurek.color.fromHex
do
    local c = lurek.color.fromHex("#FF6600")
    if c then
        lurek.log.info(tostring("fromHex r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
        lurek.log.info(tostring("fromHex alpha=" .. string.format("%.2f", c[4])))
    end
end

--@api: lurek.color.fromHsl
do
    local c = lurek.color.fromHsl(210, 0.8, 0.5)
    local h, s, l = lurek.color.toHsl(c[1], c[2], c[3])
    lurek.log.info(tostring("fromHsl r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromHsl hex=" .. lurek.color.toHex(c[1], c[2], c[3], c[4])))
    lurek.log.info(tostring("fromHsl back hsl=" .. string.format("%.1f, %.2f, %.2f", h, s, l)))
end

--@api: lurek.color.fromHsv
do
    local c = lurek.color.fromHsv(120, 1.0, 0.8)
    local lum = lurek.color.brightness(c[1], c[2], c[3])
    lurek.log.info(tostring("fromHsv r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3])))
    lurek.log.info(tostring("fromHsv alpha=" .. string.format("%.2f", c[4])))
    lurek.log.info(tostring("fromHsv brightness=" .. string.format("%.3f", lum)))
end

--@api: lurek.color.toHsl
do
    local h, s, l = lurek.color.toHsl(0.2, 0.6, 0.9)
    local c = lurek.color.fromHsl(h, s, l)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("toHsl h=" .. string.format("%.1f", h) .. " s=" .. string.format("%.2f", s) .. " l=" .. string.format("%.2f", l)))
    lurek.log.info(tostring("roundtrip hex=" .. hex))
end

--@api: lurek.color.toHex
do
    local hex = lurek.color.toHex(1.0, 0.5, 0.0)
    local c = lurek.color.fromHex(hex)
    local brightness = lurek.color.brightness(c[1], c[2], c[3])
    lurek.log.info(tostring("toHex = " .. hex))
    lurek.log.info(tostring("roundtrip r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2])))
    lurek.log.info(tostring("brightness = " .. string.format("%.3f", brightness)))
end

--@api: lurek.color.lerp
do
    local red = lurek.color.new(1, 0, 0)
    local blue = lurek.color.new(0, 0, 1)
    local mid = lurek.color.lerp(red, blue, 0.5)
    lurek.log.info(tostring("lerp r=" .. string.format("%.2f", mid[1]) .. " b=" .. string.format("%.2f", mid[3])))
    lurek.log.info(tostring("lerp alpha=" .. string.format("%.2f", mid[4])))
end

--@api: lurek.color.multiply
do
    local a = lurek.color.new(0.8, 0.6, 0.4)
    local b = lurek.color.new(0.5, 0.5, 0.5)
    local result = lurek.color.multiply(a, b)
    lurek.log.info(tostring("multiply r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("multiply b=" .. string.format("%.2f", result[3])))
end

--@api: lurek.color.screen
do
    local a = lurek.color.new(0.3, 0.3, 0.3)
    local b = lurek.color.new(0.6, 0.6, 0.6)
    local result = lurek.color.screen(a, b)
    lurek.log.info(tostring("screen r=" .. string.format("%.2f", result[1])))
    lurek.log.info(tostring("screen g=" .. string.format("%.2f", result[2])))
end

--@api: lurek.color.overlay
do
    local base = lurek.color.new(0.4, 0.4, 0.4)
    local blend = lurek.color.new(0.8, 0.2, 0.6)
    local result = lurek.color.overlay(base, blend)
    lurek.log.info(tostring("overlay r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("overlay b=" .. string.format("%.2f", result[3])))
end

--@api: lurek.color.additive
do
    local a = lurek.color.new(0.5, 0.3, 0.1)
    local b = lurek.color.new(0.3, 0.4, 0.2)
    local result = lurek.color.additive(a, b)
    lurek.log.info(tostring("additive r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2])))
    lurek.log.info(tostring("additive b=" .. string.format("%.2f", result[3])))
end

--@api: lurek.color.alphaBlend
do
    local fg = lurek.color.new(1, 0, 0, 0.5)
    local bg = lurek.color.new(0, 0, 1, 1.0)
    local result = lurek.color.alphaBlend(fg, bg)
    lurek.log.info(tostring("alphaBlend r=" .. string.format("%.2f", result[1]) .. " b=" .. string.format("%.2f", result[3])))
    lurek.log.info(tostring("alphaBlend a=" .. string.format("%.2f", result[4])))
end

--@api: lurek.color.invert
do
    local inv = lurek.color.invert(0.2, 0.8, 0.4)
    local restored = lurek.color.invert(inv[1], inv[2], inv[3], inv[4])
    lurek.log.info(tostring("invert r=" .. string.format("%.2f", inv[1]) .. " g=" .. string.format("%.2f", inv[2]) .. " b=" .. string.format("%.2f", inv[3])))
    lurek.log.info(tostring("invert a=" .. string.format("%.2f", inv[4])))
    lurek.log.info(tostring("double invert r=" .. string.format("%.2f", restored[1])))
end

--@api: lurek.color.brightness
do
    local lum = lurek.color.brightness(0.5, 0.5, 0.5)
    local dark = lurek.color.brightness(0.1, 0.1, 0.1)
    local bright = lurek.color.brightness(0.9, 0.9, 0.9)
    lurek.log.info(tostring("brightness = " .. string.format("%.3f", lum)))
    lurek.log.info(tostring("dark brightness = " .. string.format("%.3f", dark)))
    lurek.log.info(tostring("bright brightness = " .. string.format("%.3f", bright)))
end

--@api: lurek.color.withAlpha
do
    local c = lurek.color.withAlpha(0.9, 0.2, 0.3, 1.0, 0.5)
    local hex = lurek.color.toHex(c[1], c[2], c[3], c[4])
    lurek.log.info(tostring("withAlpha a=" .. string.format("%.1f", c[4])))
    lurek.log.info(tostring("withAlpha rgb = " .. string.format("%.1f", c[1]) .. ", " .. string.format("%.1f", c[2]) .. ", " .. string.format("%.1f", c[3])))
    lurek.log.info(tostring("withAlpha hex = " .. hex))
end

--@api: lurek.color.gammaToLinear
do
    local linear = lurek.color.gammaToLinear(0.5)
    local gamma = lurek.color.linearToGamma(linear)
    local boosted = lurek.color.withAlpha(linear, linear, linear, 1.0, 0.75)
    lurek.log.info(tostring("gammaToLinear = " .. string.format("%.4f", linear)))
    lurek.log.info(tostring("roundtrip gamma = " .. string.format("%.4f", gamma)))
    lurek.log.info(tostring("boosted alpha = " .. string.format("%.2f", boosted[4])))
end

--@api: lurek.color.linearToGamma
do
    local gamma = lurek.color.linearToGamma(0.2)
    local linear = lurek.color.gammaToLinear(gamma)
    local hex = lurek.color.toHex(gamma, gamma, gamma, 1.0)
    lurek.log.info(tostring("linearToGamma = " .. string.format("%.4f", gamma)))
    lurek.log.info(tostring("roundtrip linear = " .. string.format("%.4f", linear)))
    lurek.log.info(tostring("gray hex = " .. hex))
end

--@api: lurek.color.palette
do
    local pal = lurek.color.palette("pico8")
    lurek.log.info(tostring("pico8 palette count = " .. #pal))
    if #pal > 0 then
        lurek.log.info(tostring("first pico8 color = " .. string.format("%.2f", pal[1][1]) .. ", " .. string.format("%.2f", pal[1][2]) .. ", " .. string.format("%.2f", pal[1][3])))
    end
end
