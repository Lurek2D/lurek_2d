-- content/examples/font.lua
-- Run: cargo run -- content/examples/font.lua

--- Font Examples: loading, measurement, wrapping, shaping, and font handles

--@api-stub: lurek.font.getDefault
do
    local font = lurek.font.getDefault()
    print("default font = " .. tostring(font ~= nil))
end

--@api-stub: lurek.font.load
do
    local ok, font = pcall(lurek.font.load, "assets/fonts/default.ttf", 16)
    if ok then
        print("loaded font = " .. font:getName())
    else
        print("load error (expected if file missing): " .. tostring(font))
    end
end

--@api-stub: lurek.font.loadBitmap
do
    local ok, font = pcall(lurek.font.loadBitmap, "assets/fonts/bitmap8x8.png", 8, 8)
    if ok then
        print("bitmap font = " .. tostring(font ~= nil))
    else
        print("bitmap load error (expected if file missing): " .. tostring(font))
    end
end

--@api-stub: lurek.font.list
do
    local fonts = lurek.font.list()
    print("registered fonts = " .. #fonts)
end

--@api-stub: lurek.font.availableSizes
do
    local sizes = lurek.font.availableSizes()
    print("available sizes = " .. #sizes)
    print("first size = " .. tostring(sizes[1]))
end

--@api-stub: lurek.font.measure
do
    local font = lurek.font.getDefault()
    local w, h = lurek.font.measure(font, "Hello, Lurek!", 1.0)
    print("measure w=" .. w .. " h=" .. h)
end

--@api-stub: lurek.font.measureLine
do
    local font = lurek.font.getDefault()
    local w, h = lurek.font.measureLine(font, "Single line text", 1.0)
    print("measureLine w=" .. w .. " h=" .. h)
end

--@api-stub: lurek.font.wrapText
do
    local font = lurek.font.getDefault()
    local lines = lurek.font.wrapText(
        font,
        "This is a long text that should wrap at a reasonable width for display.",
        100,
        1.0,
        lurek.font.WRAP_WORD
    )
    print("wrapped lines = " .. #lines)
end

--@api-stub: lurek.font.shapeText
do
    local font = lurek.font.getDefault()
    local shaped = lurek.font.shapeText(
        font,
        "Centered text for layout",
        200,
        1.0,
        lurek.font.ALIGN_CENTER,
        lurek.font.WRAP_WORD
    )
    print("shaped lines = " .. #shaped)
    if #shaped > 0 then
        print("first line width = " .. shaped[1].width)
    end
end

--@api-stub: lurek.font.charAdvance
do
    local font = lurek.font.getDefault()
    local adv = lurek.font.charAdvance(font, "W", 1.0)
    print("charAdvance W = " .. adv)
end

--@api-stub: lurek.font.lineHeight
do
    local font = lurek.font.getDefault()
    local lh = lurek.font.lineHeight(font)
    print("lineHeight = " .. lh)
end

--@api-stub: LuaFont:getName
do
    local font = lurek.font.getDefault()
    local name = font:getName()
    print("font name = " .. name)
end

--@api-stub: LuaFont:getSize
do
    local font = lurek.font.getDefault()
    local size = font:getSize()
    print("font size = " .. size)
end

--@api-stub: LuaFont:getStyle
do
    local font = lurek.font.getDefault()
    local style = font:getStyle()
    print("font style = " .. style)
end

--@api-stub: LuaFont:isBold
do
    local font = lurek.font.getDefault()
    print("isBold = " .. tostring(font:isBold()))
end

--@api-stub: LuaFont:lineHeight
do
    local font = lurek.font.getDefault()
    local lh = font:lineHeight()
    print("method lineHeight = " .. lh)
end

--@api-stub: LuaFont:measure
do
    local font = lurek.font.getDefault()
    local w, h = font:measure("Method call test")
    print("method measure w=" .. w .. " h=" .. h)
end

--@api-stub: LuaFont:wrapText
do
    local font = lurek.font.getDefault()
    local lines = font:wrapText(
        "Wrap this paragraph using the method form for convenience.",
        120,
        1.0
    )
    print("method wrapText lines = " .. #lines)
end

--@api-stub: LuaFont:containsGlyph
do
    local font = lurek.font.getDefault()
    local hasA = font:containsGlyph("A")
    print("contains 'A' = " .. tostring(hasA))
end

--@api-stub: LFont:getName
do
    local fnt = lurek.font.getDefault()
    print("font handle = " .. tostring(fnt ~= nil))
    print("LFont:getName=" .. fnt:getName())
end

--@api-stub: LFont:getSize
do
    local fnt = lurek.font.getDefault()
    print("font name = " .. fnt:getName())
    print("LFont:getSize=" .. fnt:getSize())
end

--@api-stub: LFont:getStyle
do
    local fnt = lurek.font.getDefault()
    print("font size = " .. fnt:getSize())
    print("LFont:getStyle=" .. fnt:getStyle())
end

--@api-stub: LFont:isBold
do
    local fnt = lurek.font.getDefault()
    print("font style = " .. fnt:getStyle())
    print("LFont:isBold=" .. tostring(fnt:isBold()))
end

--@api-stub: LFont:lineHeight
do
    local fnt = lurek.font.getDefault()
    print("font size = " .. fnt:getSize())
    print("LFont:lineHeight=" .. fnt:lineHeight())
end

--@api-stub: LFont:measure
do
    local fnt = lurek.font.getDefault()
    local w, h = fnt:measure("Hello, World!", 1.0)
    print("LFont:measure w=" .. w .. " h=" .. h)
end

--@api-stub: LFont:wrapText
do
    local fnt = lurek.font.getDefault()
    local lines = fnt:wrapText("This is a long line that needs wrapping.", 200, 1.0)
    print("LFont:wrapText lines=" .. #lines)
end

--@api-stub: LFont:containsGlyph
do
    local fnt = lurek.font.getDefault()
    print("font name = " .. fnt:getName())
    print("LFont:containsGlyph A=" .. tostring(fnt:containsGlyph("A")))
end
