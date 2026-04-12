-- Lurek2D font tests for lurek.graphic font functions.
-- @covers lurek.graphic.getFont
-- @covers lurek.graphic.getFontHeight
-- @covers lurek.graphic.getFontWidth
-- @covers lurek.graphic.newFont
-- @covers lurek.graphic.setFont


-- @description Covers suite: lurek.graphic font functions.
describe("lurek.graphic font functions", function()
  -- @covers lurek.graphic.newFont
  -- @description Verifies the font constructor is exposed on the graphics namespace.
  it("newFont is a function", function()
    expect_type("function", lurek.graphic.newFont)
  end)

  -- @covers lurek.graphic.setFont
  -- @description Verifies the active-font setter is exposed for text rendering state.
  it("setFont is a function", function()
    expect_type("function", lurek.graphic.setFont)
  end)

  -- @covers lurek.graphic.getFont
  -- @description Verifies the current-font getter is exposed.
  it("getFont is a function", function()
    expect_type("function", lurek.graphic.getFont)
  end)

  -- @covers lurek.graphic.getFontWidth
  -- @description Verifies the string-width helper is exposed.
  it("getFontWidth is a function", function()
    expect_type("function", lurek.graphic.getFontWidth)
  end)

  -- @covers lurek.graphic.getFontHeight
  -- @description Verifies the font-height helper is exposed.
  it("getFontHeight is a function", function()
    expect_type("function", lurek.graphic.getFontHeight)
  end)

  -- @covers lurek.graphic.newFont
  -- @description Verifies requesting a built-in bitmap font size returns a font userdata instead of requiring a file path.
  it("loads a built-in bitmap font by size", function()
    local font = lurek.graphic.newFont(14)
    expect_type("userdata", font)
  end)

  -- @covers lurek.graphic.newFont
  -- @covers lurek.graphic.setFont
  -- @covers lurek.graphic.getFont
  -- @description Verifies a created font can be installed as the active font and retrieved again.
  it("setFont and getFont round-trip to a non-nil font", function()
    local font = lurek.graphic.newFont(14)
    lurek.graphic.setFont(font)
    local current = lurek.graphic.getFont()
    expect_type("userdata", current)
  end)

  -- @covers lurek.graphic.newFont
  -- @covers lurek.graphic.getFontWidth
  -- @covers lurek.graphic.getFontHeight
  -- @description Verifies loaded fonts report positive text metrics for width and line height.
  it("reports positive width and height for a loaded font", function()
    local font = lurek.graphic.newFont(14)
    expect_true(lurek.graphic.getFontWidth(font, "Hello") > 0)
    expect_true(lurek.graphic.getFontHeight(font) > 0)
  end)

  -- @covers lurek.graphic.newFont
  -- @description Verifies the constructor rejects nonexistent font asset paths instead of silently creating an invalid font.
  it("newFont errors when file does not exist", function()
    expect_error(function()
      lurek.graphic.newFont("nonexistent_font.png")
    end)
  end)
end)

test_summary()
