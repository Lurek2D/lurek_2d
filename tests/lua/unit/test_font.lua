-- Lurek2D font tests for the current graphics namespace.

describe("lurek.gfx font functions", function()
  it("newFont is a function", function()
    expect_type("function", lurek.gfx.newFont)
  end)

  it("setFont is a function", function()
    expect_type("function", lurek.gfx.setFont)
  end)

  it("getFont is a function", function()
    expect_type("function", lurek.gfx.getFont)
  end)

  it("getFontWidth is a function", function()
    expect_type("function", lurek.gfx.getFontWidth)
  end)

  it("getFontHeight is a function", function()
    expect_type("function", lurek.gfx.getFontHeight)
  end)

  it("loads a bundled font", function()
    local font = lurek.gfx.newFont("assets/fonts/Roboto-Regular.ttf", 16)
    expect_type("userdata", font)
  end)

  it("setFont and getFont round-trip to a non-nil font", function()
    local font = lurek.gfx.newFont("assets/fonts/Roboto-Regular.ttf", 16)
    lurek.gfx.setFont(font)
    local current = lurek.gfx.getFont()
    expect_type("userdata", current)
  end)

  it("reports positive width and height for a loaded font", function()
    local font = lurek.gfx.newFont("assets/fonts/Roboto-Regular.ttf", 16)
    expect_true(lurek.gfx.getFontWidth(font, "Hello") > 0)
    expect_true(lurek.gfx.getFontHeight(font) > 0)
  end)

  it("newFont errors when file does not exist", function()
    expect_error(function()
      lurek.gfx.newFont("nonexistent_font.ttf", 16)
    end)
  end)
end)

test_summary()
