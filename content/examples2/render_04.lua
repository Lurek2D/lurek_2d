--- Render Module Part 4: fonts, stencil, screenshots, text measurement, pixel density

--@api-stub: lurek.render.newFont / setFont / getFont
-- Loading and activating fonts.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    print("font type = " .. font:type())
    print("is LFont = " .. tostring(font:typeOf("LFont")))
    lurek.render.setFont(font)
    ---@type LFont
    local active = lurek.render.getFont()
    print("active font = " .. active:type())
    lurek.render.print("Using custom font", 10, 10)
end

--@api-stub: lurek.render.getDefaultFont
-- Using the built-in default font.
do
    ---@type LFont
    local defFont = lurek.render.getDefaultFont()
    print("default font height = " .. defFont:getHeight())
    ---@type LFont
    local bigDefault = lurek.render.getDefaultFont(24)
    print("big default height = " .. bigDefault:getHeight())
    lurek.render.setFont(bigDefault)
    lurek.render.print("Big default font", 10, 30)
end

--@api-stub: LFont:getWidth / getHeight / getLineHeight / getAscent / getDescent
-- Font metrics.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 14)
    print("width of 'Hello' = " .. font:getWidth("Hello"))
    print("height = " .. font:getHeight())
    print("line height = " .. font:getLineHeight())
    print("ascent = " .. font:getAscent())
    print("descent = " .. font:getDescent())
end

--@api-stub: LFont:getWrap / setLineHeight
-- Word wrapping and line height control.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 12)
    local lines, width = font:getWrap("This is a long paragraph of text that should wrap nicely.", 150)
    print("wrapped lines = " .. #lines .. " width = " .. width)
    for i, line in ipairs(lines) do
        print("  " .. i .. ": " .. line)
    end
    font:setLineHeight(1.5)
    print("new line height = " .. font:getLineHeight())
end

--@api-stub: LFont:release
-- Font lifecycle.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 18)
    local released = font:release()
    print("released = " .. tostring(released))
end

--@api-stub: lurek.render.getFontSizes
-- Querying available font sizes.
do
    local sizes = lurek.render.getFontSizes()
    print("available sizes = " .. #sizes)
    for i, s in ipairs(sizes) do
        if i <= 5 then
            print("  size " .. i .. " = " .. s)
        end
    end
end

--@api-stub: lurek.render.getFontWidth / getFontHeight / getFontLineHeight
-- Font helpers that accept font as first parameter.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 14)
    local w = lurek.render.getFontWidth(font, "Measurement")
    print("font width = " .. w)
    local h = lurek.render.getFontHeight(font)
    print("font height = " .. h)
    local lh = lurek.render.getFontLineHeight(font)
    print("line height = " .. lh)
end

--@api-stub: lurek.render.getFontAscent / getFontDescent / getFontCellWidth
-- Advanced font metrics.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    print("ascent = " .. lurek.render.getFontAscent(font))
    print("descent = " .. lurek.render.getFontDescent(font))
    print("cell width = " .. lurek.render.getFontCellWidth(font))
end

--@api-stub: lurek.render.getFontWrap / setFontLineHeight
-- Render-level font wrapping and line height.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 12)
    local lines, width = lurek.render.getFontWrap("A long sentence for wrap testing at 200 px limit.", 200)
    print("lines = " .. #lines .. " max_width = " .. width)
    lurek.render.setFontLineHeight(font, 2.0)
    print("set line height to 2.0")
end

--@api-stub: lurek.render.stencil / setStencilTest
-- Stencil masking for shaped clipping.
do
    lurek.render.stencil("replace", 1)
    lurek.render.circle("fill", 200, 200, 60)
    lurek.render.stencil()
    lurek.render.setStencilTest("equal", 1)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.rectangle("fill", 100, 100, 200, 200)
    lurek.render.setStencilTest()
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.setStencilMode / getStencilMode / clearStencil
-- Stencil mode control.
do
    lurek.render.setStencilMode("replace", "always", 1)
    lurek.render.rectangle("fill", 300, 100, 100, 100)
    local action, compare, value = lurek.render.getStencilMode()
    print("stencil: action=" .. action .. " compare=" .. compare .. " value=" .. value)
    lurek.render.clearStencil()
    lurek.render.setStencilMode("keep", "always", 0)
end

--@api-stub: lurek.render.captureScreenshot / saveScreenshot
-- Screenshot capture.
do
    lurek.render.setColor(0.2, 0.4, 0.8, 1)
    lurek.render.rectangle("fill", 0, 0, 320, 240)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.circle("fill", 160, 120, 50)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.captureScreenshot(function(data)
        print("screenshot captured: " .. data:getWidth() .. "x" .. data:getHeight())
    end)
    lurek.render.saveScreenshot("save/screenshot_test.png")
    print("screenshot saved")
end

--@api-stub: lurek.render.newCanvas as render target
-- Using a canvas as a render texture for post-processing.
do
    ---@type LCanvas
    local rt = lurek.render.newCanvas(256, 256)
    lurek.render.setCanvas(rt)
    lurek.render.setColor(0, 1, 0, 1)
    lurek.render.rectangle("fill", 0, 0, 256, 256)
    lurek.render.setColor(1, 0, 0, 1)
    lurek.render.circle("fill", 128, 128, 80)
    lurek.render.setCanvas(nil)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(rt, 400, 50, 0, 0.5, 0.5)
end

--@api-stub: lurek.render.print with font
-- Using fonts directly with print.
do
    ---@type LFont
    local font = lurek.render.newFont("assets/fonts/default.ttf", 16)
    lurek.render.setFont(font)
    lurek.render.print("Rendered with custom font", 10, 350)
    lurek.render.print("Second line", 10, 370)
    ---@type LFont
    local def = lurek.render.getDefaultFont()
    lurek.render.setFont(def)
end

--@api-stub: lurek.render.setLineWidth / thick shapes
-- Drawing shapes with thick line widths.
do
    lurek.render.setLineWidth(4)
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.line(10, 400, 60, 380, 110, 400)
    lurek.render.setColor(0, 0.8, 0.4, 1)
    lurek.render.rectangle("line", 130, 380, 60, 40)
    lurek.render.setColor(0.5, 0, 1, 1)
    lurek.render.circle("line", 240, 400, 20)
    lurek.render.setLineWidth(1)
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: lurek.render.drawMany / batch with transforms
-- Batch drawing multiple images with different transforms.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    local draws = {}
    for i = 0, 7 do
        local angle = i * math.pi / 4
        table.insert(draws, { img, 350 + math.cos(angle) * 40, 420 + math.sin(angle) * 40, angle, 0.25, 0.25 })
    end
    lurek.render.drawMany(draws)
end

print("render_04.lua")
