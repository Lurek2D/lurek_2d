-- Lurek2D font tests for lurek.render font functions.

-- @describe lurek.render font functions
describe("lurek.render font functions", function()
  -- @covers lurek.render.getFont
  it("getFont is a function", function()
    expect_type("function", lurek.render.getFont)
  end)

  -- @covers lurek.render.getFontWidth
  it("getFontWidth is a function", function()
    expect_type("function", lurek.render.getFontWidth)
  end)

  -- @covers lurek.render.getFontHeight
  it("getFontHeight is a function", function()
    expect_type("function", lurek.render.getFontHeight)
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
test_summary()
