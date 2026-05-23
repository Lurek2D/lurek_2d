-- Lurek2D font tests for lurek.render font functions.

-- @describe lurek.render font functions
describe("lurek.render font functions", function()
  -- @covers lurek.render.newFont
  it("newFont is a function", function()
    expect_type("function", lurek.render.newFont)
  end)

  -- @covers lurek.render.setFont
  it("setFont is a function", function()
    expect_type("function", lurek.render.setFont)
  end)

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

  -- @covers lurek.render.newFont
  it("loads bundled fonts by stable font_* name", function()
    local regular = lurek.render.newFont("font_12")
    local bold = lurek.render.newFont("fontb_12")
    expect_type("userdata", regular)
    expect_type("userdata", bold)
  end)

  -- @covers lurek.render.newFont
  it("loads a custom TTF font from file", function()
    local font = lurek.render.newFont("content/examples/assets/fonts/sample_font.ttf", 16)
    expect_type("userdata", font)
    expect_true(font:getWidth("Hello") > 0)
  end)

  -- @covers lurek.render.getFont
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
  -- @covers lurek.render.getFont
  -- @covers lurek.render.setBold
  -- @covers lurek.render.isBold
  it("setDefaultFont switches between regular and bold built-in fonts", function()
    local regular = lurek.render.setDefaultFont(10, false)
    local current = lurek.render.getFont()
    expect_equal(lurek.render.getFontHeight(regular), lurek.render.getFontHeight(current))
    expect_equal(false, lurek.render.isBold())

    local bold = lurek.render.setDefaultFont(10, true)
    current = lurek.render.getFont()
    expect_equal(lurek.render.getFontHeight(bold), lurek.render.getFontHeight(current))
    expect_equal(true, lurek.render.isBold())

    lurek.render.setBold(false)
    expect_equal(false, lurek.render.isBold())
  end)

  -- @covers lurek.render.getFontHeight
  -- @covers lurek.render.getFontWidth
  it("reports positive width and height for a loaded font", function()
    local font = lurek.render.newFont(14)
    expect_true(lurek.render.getFontWidth(font, "Hello") > 0)
    expect_true(lurek.render.getFontHeight(font) > 0)
  end)

  -- @covers lurek.render.printWithFont
  -- @covers lurek.render.printfWithFont
  -- @covers lurek.render.printRotatedWithFont
  -- @covers lurek.render.printRichWithFont
  it("per-call font draw helpers are callable", function()
    local font = lurek.render.newFont("font_12")
    expect_no_error(function()
      lurek.render.printWithFont(font, "A", 0, 0, 1)
      lurek.render.printfWithFont(font, "A B C", 0, 0, 80, "left")
      lurek.render.printRotatedWithFont(font, "A", 12, 14, 0.25, 1)
      lurek.render.printRichWithFont(font, {
        { text = "A", r = 255, g = 255, b = 255, a = 255, scale = 1 },
      }, 0, 0)
    end)
  end)

  -- @covers lurek.render.newFont
  it("newFont errors when file does not exist", function()
    expect_error(function()
      lurek.render.newFont("nonexistent_font.png")
    end)
  end)
end)
test_summary()
