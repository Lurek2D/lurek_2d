-- content/examples/color.lua
-- Run: cargo run -- content/examples/color.lua

--- Color Examples: creation, conversion, blending, palettes, and utilities

--@api-stub: lurek.color.new
do
    local c = lurek.color.new(0.2, 0.6, 0.9, 1.0)
    print("color r=" .. c[1] .. " g=" .. c[2] .. " b=" .. c[3] .. " a=" .. c[4])
    print("hex = " .. lurek.color.toHex(c[1], c[2], c[3], c[4]))
end

--@api-stub: lurek.color.fromU8
do
    local c = lurek.color.fromU8(255, 128, 0, 255)
    print("fromU8 r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromU8 a=" .. string.format("%.2f", c[4]))
end

--@api-stub: lurek.color.fromHex
do
    local c = lurek.color.fromHex("#FF6600")
    if c then
        print("fromHex r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
        print("fromHex alpha=" .. string.format("%.2f", c[4]))
    end
end

--@api-stub: lurek.color.fromHsl
do
    local c = lurek.color.fromHsl(210, 0.8, 0.5)
    print("fromHsl r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromHsl hex=" .. lurek.color.toHex(c[1], c[2], c[3], c[4]))
end

--@api-stub: lurek.color.fromHsv
do
    local c = lurek.color.fromHsv(120, 1.0, 0.8)
    print("fromHsv r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("fromHsv alpha=" .. string.format("%.2f", c[4]))
end

--@api-stub: lurek.color.toHsl
do
    local h, s, l = lurek.color.toHsl(0.2, 0.6, 0.9)
    print("toHsl h=" .. string.format("%.1f", h) .. " s=" .. string.format("%.2f", s) .. " l=" .. string.format("%.2f", l))
end

--@api-stub: lurek.color.toHex
do
    local hex = lurek.color.toHex(1.0, 0.5, 0.0)
    print("toHex = " .. hex)
end

--@api-stub: lurek.color.lerp
do
    local red = lurek.color.new(1, 0, 0)
    local blue = lurek.color.new(0, 0, 1)
    local mid = lurek.color.lerp(red, blue, 0.5)
    print("lerp r=" .. string.format("%.2f", mid[1]) .. " b=" .. string.format("%.2f", mid[3]))
    print("lerp alpha=" .. string.format("%.2f", mid[4]))
end

--@api-stub: lurek.color.multiply
do
    local a = lurek.color.new(0.8, 0.6, 0.4)
    local b = lurek.color.new(0.5, 0.5, 0.5)
    local result = lurek.color.multiply(a, b)
    print("multiply r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("multiply b=" .. string.format("%.2f", result[3]))
end

--@api-stub: lurek.color.screen
do
    local a = lurek.color.new(0.3, 0.3, 0.3)
    local b = lurek.color.new(0.6, 0.6, 0.6)
    local result = lurek.color.screen(a, b)
    print("screen r=" .. string.format("%.2f", result[1]))
    print("screen g=" .. string.format("%.2f", result[2]))
end

--@api-stub: lurek.color.overlay
do
    local base = lurek.color.new(0.4, 0.4, 0.4)
    local blend = lurek.color.new(0.8, 0.2, 0.6)
    local result = lurek.color.overlay(base, blend)
    print("overlay r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("overlay b=" .. string.format("%.2f", result[3]))
end

--@api-stub: lurek.color.additive
do
    local a = lurek.color.new(0.5, 0.3, 0.1)
    local b = lurek.color.new(0.3, 0.4, 0.2)
    local result = lurek.color.additive(a, b)
    print("additive r=" .. string.format("%.2f", result[1]) .. " g=" .. string.format("%.2f", result[2]))
    print("additive b=" .. string.format("%.2f", result[3]))
end

--@api-stub: lurek.color.alphaBlend
do
    local fg = lurek.color.new(1, 0, 0, 0.5)
    local bg = lurek.color.new(0, 0, 1, 1.0)
    local result = lurek.color.alphaBlend(fg, bg)
    print("alphaBlend r=" .. string.format("%.2f", result[1]) .. " b=" .. string.format("%.2f", result[3]))
    print("alphaBlend a=" .. string.format("%.2f", result[4]))
end

--@api-stub: lurek.color.invert
do
    local inv = lurek.color.invert(0.2, 0.8, 0.4)
    print("invert r=" .. string.format("%.2f", inv[1]) .. " g=" .. string.format("%.2f", inv[2]) .. " b=" .. string.format("%.2f", inv[3]))
    print("invert a=" .. string.format("%.2f", inv[4]))
end

--@api-stub: lurek.color.brightness
do
    local lum = lurek.color.brightness(0.5, 0.5, 0.5)
    print("brightness = " .. string.format("%.3f", lum))
end

--@api-stub: lurek.color.withAlpha
do
    local c = lurek.color.withAlpha(0.9, 0.2, 0.3, 1.0, 0.5)
    print("withAlpha a=" .. string.format("%.1f", c[4]))
    print("withAlpha rgb = " .. string.format("%.1f", c[1]) .. ", " .. string.format("%.1f", c[2]) .. ", " .. string.format("%.1f", c[3]))
end

--@api-stub: lurek.color.gammaToLinear
do
    local linear = lurek.color.gammaToLinear(0.5)
    print("gammaToLinear = " .. string.format("%.4f", linear))
end

--@api-stub: lurek.color.linearToGamma
do
    local gamma = lurek.color.linearToGamma(0.2)
    print("linearToGamma = " .. string.format("%.4f", gamma))
end

--@api-stub: lurek.color.palette
do
    local pal = lurek.color.palette("pico8")
    print("pico8 palette count = " .. #pal)
    if #pal > 0 then
        print("first pico8 color = " .. string.format("%.2f", pal[1][1]) .. ", " .. string.format("%.2f", pal[1][2]) .. ", " .. string.format("%.2f", pal[1][3]))
    end
end
