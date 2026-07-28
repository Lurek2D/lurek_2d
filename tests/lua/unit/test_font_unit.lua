-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_font_core_unit.lua
do
-- Lurek2D Font API Tests

-- @describe lurek.font.getDefault
describe("lurek.font.getDefault", function()
    -- @covers lurek.font.getDefault
    it("returns a userdata value", function()
        local f = lurek.font.getDefault()
        expect_not_nil(f, "default font should exist")
        expect_equal("userdata", type(f))
    end)
end)

-- @describe lurek.font.availableSizes
describe("lurek.font.availableSizes", function()
    -- @covers lurek.font.availableSizes
    it("returns positive numeric built-in sizes", function()
        local sizes = lurek.font.availableSizes()
        expect_true(type(sizes) == "table", "should be a table")
        expect_true(#sizes >= 7, "should have at least 7 sizes")
        for i = 1, #sizes do
            expect_true(type(sizes[i]) == "number", "entry is a number")
            expect_true(sizes[i] > 0, "size is positive")
        end
    end)
end)

-- @describe lurek.font.list
describe("lurek.font.list", function()
    -- @covers lurek.font.list
    it("returns built-in entries and includes runtime-loaded fonts", function()
        local fonts = lurek.font.list()
        expect_true(type(fonts) == "table", "should be a table")
        expect_true(#fonts > 0, "should have at least one font")
        local fonts = lurek.font.list()
        local entry = fonts[1]
        expect_true(type(entry.name) == "string", "name is string")
        expect_true(type(entry.size) == "number", "size is number")
        expect_true(type(entry.style) == "string", "style is string")
        local before = lurek.font.list()
        local loaded = lurek.font.load("content/examples/assets/fonts/sample_font.ttf", 14)
        expect_equal("userdata", type(loaded))
        local after = lurek.font.list()
        expect_true(#after > #before, "runtime-loaded font should appear in lurek.font.list()")
    end)
end)

-- @describe lurek.font.measure
describe("lurek.font.measure", function()
    -- @covers lurek.font.measure
    it("measures visible text and reports zero width for empty text", function()
        local f = lurek.font.getDefault()
        local w, h = lurek.font.measure(f, "Hello", 1.0)
        expect_true(w > 0, "width should be > 0")
        expect_true(h > 0, "height should be > 0")
        local empty_w = lurek.font.measure(f, "", 1.0)
        expect_near(0, empty_w, 0.01)
    end)
end)

-- @describe lurek.font.measureLine
describe("lurek.font.measureLine", function()
    -- @covers lurek.font.measureLine
    it("single line measurement returns width > 0", function()
        local f = lurek.font.getDefault()
        local w, h = lurek.font.measureLine(f, "Test line", 1.0)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)
end)

-- @describe lurek.font.wrapText
describe("lurek.font.wrapText", function()
    -- @covers lurek.font.wrapText
    it("wrapText handles narrow and wide line widths", function()
        local f = lurek.font.getDefault()
        local lines = lurek.font.wrapText(f, "This is a long sentence that should wrap into multiple lines", 50, 1.0, "word")
        expect_true(#lines > 1, "should produce multiple lines")
        local wide_lines = lurek.font.wrapText(f, "Short", 9999, 1.0, "word")
        expect_equal(1, #wide_lines)
    end)
end)

-- @describe lurek.font.load
describe("lurek.font.load", function()
    -- @covers lurek.font.load
    it("loads an existing TTF font file at the requested size", function()
        local font = lurek.font.load("content/examples/assets/fonts/sample_font.ttf", 14)
        expect_equal("userdata", type(font))
        local w, h = font:measure("Sample", 1.0)
        expect_true(w > 0, "loaded font should measure visible text")
        expect_true(h > 0, "loaded font should report positive height")
    end)
end)

-- @describe lurek.font.shapeText
describe("lurek.font.shapeText", function()
    -- @covers lurek.font.shapeText
    it("returns shaped lines and alignment offsets", function()
        local f = lurek.font.getDefault()
        local shaped = lurek.font.shapeText(f, "Hello world", 200, 1.0, "left", "word")
        expect_true(type(shaped) == "table", "returns a table")
        expect_true(#shaped >= 1, "at least one line")
        local first = shaped[1]
        expect_true(type(first.text) == "string", "has text field")
        expect_true(type(first.width) == "number", "has width field")
        expect_true(type(first.xOffset) == "number", "has xOffset field")
        local centered = lurek.font.shapeText(f, "Hi", 500, 1.0, "center", "word")
        expect_true(centered[1].xOffset > 0, "center offset should be > 0")
    end)
end)

-- @describe lurek.font.charAdvance
describe("lurek.font.charAdvance", function()
    -- @covers lurek.font.charAdvance
    it("charAdvance reports positive advances for letters and spaces", function()
        local f = lurek.font.getDefault()
        local adv_a = lurek.font.charAdvance(f, "A", 1.0)
        local adv_space = lurek.font.charAdvance(f, " ", 1.0)
        expect_true(adv_a > 0, "advance should be positive")
        expect_true(adv_space > 0, "space advance should be positive")
    end)
end)

-- @describe lurek.font.lineHeight
describe("lurek.font.lineHeight", function()
    -- @covers lurek.font.lineHeight
    it("returns positive value for default font", function()
        local f = lurek.font.getDefault()
        local lh = lurek.font.lineHeight(f)
        expect_true(lh > 0, "line height should be > 0")
    end)
end)

-- @describe LuaFont methods
describe("LuaFont methods", function()
    -- @covers LFont:getName
    it("getName returns a string", function()
        local f = lurek.font.getDefault()
        local name = f:getName()
        expect_true(type(name) == "string", "name is a string")
        expect_true(#name > 0, "name is not empty")
    end)

    -- @covers LFont:getSize
    it("getSize returns a positive number", function()
        local f = lurek.font.getDefault()
        local size = f:getSize()
        expect_true(type(size) == "number", "size is a number")
        expect_true(size > 0, "size is positive")
    end)

    -- @covers LFont:getStyle
    it("getStyle returns 'regular' or 'bold'", function()
        local f = lurek.font.getDefault()
        local style = f:getStyle()
        expect_true(style == "regular" or style == "bold", "style is valid")
    end)

    -- @covers LFont:isBold
    it("isBold returns boolean", function()
        local f = lurek.font.getDefault()
        local bold = f:isBold()
        expect_true(type(bold) == "boolean", "isBold returns boolean")
    end)
end)

-- @describe lurek.font.loadBitmap
describe("lurek.font.loadBitmap", function()
    -- @covers lurek.font.loadBitmap
    it("loadBitmap validates arguments and rejects missing files", function()
        expect_type("function", lurek.font.loadBitmap)
        local ok, err = pcall(function()
            local bad_path ---@type any
            bad_path = nil
            lurek.font.loadBitmap(bad_path, 8, 8)
        end)
        expect_true(not ok, "must error on nil path")
        expect_true(err ~= nil, "error must be non-nil")
        ok = pcall(function()
            local bad_width ---@type any
            bad_width = "wide"
            lurek.font.loadBitmap("test.png", bad_width, 8)
        end)
        expect_true(not ok, "must error on non-numeric cellWidth")
        ok = pcall(function()
            lurek.font.loadBitmap("nonexistent_bitmap_font.png", 8, 8)
        end)
        expect_true(not ok, "must error when file does not exist")
    end)
end)

-- @describe lurek.font.getDefault methods
describe("lurek.font.getDefault methods", function()
    -- @covers LFont:containsGlyph
    it("containsGlyph reports known glyphs and rejects control characters", function()
        local f = lurek.font.getDefault()
        expect_true(f:containsGlyph("A"), "should contain glyph for A")
        expect_equal(false, f:containsGlyph(string.char(1)))
    end)

    -- @covers LFont:lineHeight
    it("method lineHeight matches module function", function()
        local f = lurek.font.getDefault()
        local method_lh = f:lineHeight()
        local fn_lh = lurek.font.lineHeight(f)
        expect_near(fn_lh, method_lh, 0.01)
    end)

    -- @covers LFont:measure
    it("method measure returns positive dimensions", function()
        local f = lurek.font.getDefault()
        local w, h = f:measure("Test", 1.0)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)

    -- @covers LFont:wrapText
    it("method wrapText splits long text into multiple lines", function()
        local f = lurek.font.getDefault()
        local lines = f:wrapText("This is a long line that needs wrapping.", 80, 1.0)
        expect_type("table", lines)
        expect_true(#lines > 1, "should wrap into multiple lines")
    end)
end)
end
-- END test_font_core_unit.lua

-- BEGIN test_render_font_unit.lua
do
-- Lurek2D font tests for lurek.render font functions.

-- @describe lurek.render font functions
describe("lurek.render font functions", function()
  -- @covers lurek.render.getFont
  it("getFont is a function", function()
    expect_type("function", lurek.render.getFont)
  end)

  -- @covers lurek.render.getFontWidth
  it("accepts a canonical font.load handle", function()
    local font = lurek.font.load("content/examples/assets/fonts/sample_font.ttf", 14)
    expect_true(lurek.render.getFontWidth(font, "owner bridge") > 0)
  end)

  -- @covers lurek.render.getFontHeight
  it("measures a canonical font.load handle", function()
    local font = lurek.font.load("content/examples/assets/fonts/sample_font.ttf", 14)
    expect_true(lurek.render.getFontHeight(font) > 0)
  end)

  -- @covers lurek.render.getBuiltInFontNames
  it("getBuiltInFontNames returns bundled font_* names", function()
    local names = lurek.render.getBuiltInFontNames()
    expect_type("table", names)
    expect_equal("font_8", names[1])
    expect_equal("fontb_8", names[8])
  end)

  -- @covers lurek.render.getFontSizes
  it("getFontSizes returns bundled point sizes", function()
    local sizes = lurek.render.getFontSizes()
    expect_type("table", sizes)
    expect_equal(8, sizes[1])
    expect_equal(10, sizes[2])
  end)

  -- @covers lurek.render.newFont
  it("loads a built-in bitmap font by size", function()
    local font = lurek.render.newFont(14)
    expect_type("userdata", font)
  end)

  -- @covers LFont:getAscent
  it("loads bundled fonts by stable font_* name", function()
    local regular = lurek.render.newFont("font_12")
    local bold = lurek.render.newFont("fontb_12")
    expect_type("userdata", regular)
    expect_type("userdata", bold)
    expect_true(regular:getAscent() > 0)
    expect_true(bold:getAscent() > 0)
  end)

  -- @covers LFont:getDescent
  it("loads a custom TTF font from file", function()
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    expect_type("userdata", font)
    expect_true(font:getWidth("Hello") > 0)
    expect_type("number", font:getDescent())
  end)

  -- @covers lurek.render.setFont
  it("setFont and getFont round-trip to a non-nil font", function()
    local font = lurek.render.newFont(14)
    lurek.render.setFont(font)
    local current = lurek.render.getFont()
    expect_type("userdata", current)
  end)

  -- @covers lurek.render.getDefaultFont
  it("default configured font starts at built-in font_8", function()
    local configured = lurek.render.getDefaultFont()
    local expected = lurek.render.newFont("font_8")
    expect_equal(lurek.render.getFontHeight(expected), lurek.render.getFontHeight(configured))
  end)

  -- @covers lurek.render.setDefaultFont
  it("setDefaultFont switches the active default font", function()
    local regular = lurek.render.setDefaultFont(10, false)
    local current = lurek.render.getFont()
    expect_equal(lurek.render.getFontHeight(regular), lurek.render.getFontHeight(current))
  end)

  -- @covers lurek.render.isBold
  it("isBold reflects the bold font flag", function()
    lurek.render.setDefaultFont(10, false)
    expect_equal(false, lurek.render.isBold())

    lurek.render.setDefaultFont(10, true)
    expect_equal(true, lurek.render.isBold())

    lurek.render.setBold(false)
    expect_equal(false, lurek.render.isBold())
  end)

  -- @covers LFont:getLineHeight
  it("reports positive width and height for a loaded font", function()
    local font = lurek.render.newFont(14)
    expect_true(lurek.render.getFontWidth(font, "Hello") > 0)
    expect_true(lurek.render.getFontHeight(font) > 0)
    expect_type("number", font:getLineHeight())
  end)

  -- @covers lurek.render.printWithFont
  it("printWithFont is callable", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.printWithFont(font, "A", 0, 0, 1)
    end)
  end)

  -- @covers lurek.render.drawTextWithFont
  it("drawTextWithFont accepts GPU transform parameters", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.setColor(0.7, 1.0, 0.8, 0.9)
      lurek.render.drawTextWithFont(font, "A", 12, 14, 0.25, 1.5, 1.25, 2, 3)
      lurek.render.setColor(1, 1, 1, 1)
    end)
  end)

  -- @covers lurek.render.printfWithFont
  it("printfWithFont is callable", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.printfWithFont(font, "A B C", 0, 0, 80, "left")
    end)
  end)

  -- @covers lurek.render.printRotatedWithFont
  it("printRotatedWithFont is callable", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.printRotatedWithFont(font, "A", 12, 14, 0.25, 1)
    end)
  end)

  -- @covers lurek.render.printRichWithFont
  it("printRichWithFont is callable", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.printRichWithFont(font, {
        { text = "A", r = 255, g = 255, b = 255, a = 255, scale = 1 },
      }, 0, 0)
    end)
  end)

end)
end
-- END test_render_font_unit.lua

test_summary()
