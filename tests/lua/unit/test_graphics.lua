-- Lurek2D Graphics API Tests (headless â€” tests lurek.graphic API existence and behaviour)
-- @covers lurek.graphic.captureScreenshot
-- @covers lurek.graphic.circle
-- @covers lurek.graphic.clearStencil
-- @covers lurek.graphic.draw
-- @covers lurek.graphic.drawNineSlice
-- @covers lurek.graphic.ellipse
-- @covers lurek.graphic.getDepthMode
-- @covers lurek.graphic.getDimensions
-- @covers lurek.graphic.getFontAscent
-- @covers lurek.graphic.getFontDescent
-- @covers lurek.graphic.getFontLineHeight
-- @covers lurek.graphic.getLineWidth
-- @covers lurek.graphic.getStencilMode
-- @covers lurek.graphic.line
-- @covers lurek.graphic.newImage
-- @covers lurek.graphic.newNineSlice
-- @covers lurek.graphic.polygon
-- @covers lurek.graphic.print
-- @covers lurek.graphic.rectangle
-- @covers lurek.graphic.saveScreenshot
-- @covers lurek.graphic.setBackgroundColor
-- @covers lurek.graphic.setColor
-- @covers lurek.graphic.setDepthMode
-- @covers lurek.graphic.setFontLineHeight
-- @covers lurek.graphic.setLineWidth
-- @covers lurek.graphic.setStencilMode
-- @covers lurek.graphic.triangle


-- @description Verifies the graphics namespace is exposed on lurek as a table.
describe("lurek.graphic module exists", function()
    -- @description Asserts that lurek.graphic has Lua type "table".
    it("lurek.graphic is a table", function()
        expect_type("table", lurek.graphic)
    end)
end)

-- @description Verifies the color APIs exist and accept the supported RGB and RGBA argument counts without errors.
describe("lurek.graphic color functions", function()
    -- @description Asserts that lurek.graphic.setColor has Lua type "function".
    it("setColor is a function", function()
        expect_type("function", lurek.graphic.setColor)
    end)

    -- @description Confirms setColor(1, 0, 0) executes without raising an error.
    it("setColor accepts 3 args", function()
        expect_no_error(function()
            lurek.graphic.setColor(1, 0, 0)
        end)
    end)

    -- @description Confirms setColor(1, 0, 0, 0.5) executes without raising an error.
    it("setColor accepts 4 args", function()
        expect_no_error(function()
            lurek.graphic.setColor(1, 0, 0, 0.5)
        end)
    end)

    -- @description Asserts that lurek.graphic.setBackgroundColor has Lua type "function".
    it("setBackgroundColor is a function", function()
        expect_type("function", lurek.graphic.setBackgroundColor)
    end)

    -- @description Confirms setBackgroundColor(0.1, 0.1, 0.1) executes without raising an error.
    it("setBackgroundColor accepts 3 args", function()
        expect_no_error(function()
            lurek.graphic.setBackgroundColor(0.1, 0.1, 0.1)
        end)
    end)
end)

-- @description Verifies the basic shape drawing APIs exist and accept representative valid arguments for filled and outlined primitives.
describe("lurek.graphic shape functions", function()
    -- @description Asserts that lurek.graphic.rectangle has Lua type "function".
    it("rectangle is a function", function()
        expect_type("function", lurek.graphic.rectangle)
    end)

    -- @description Confirms rectangle("fill", 10, 10, 100, 50) executes without raising an error.
    it("rectangle fill mode", function()
        expect_no_error(function()
            lurek.graphic.rectangle("fill", 10, 10, 100, 50)
        end)
    end)

    -- @description Confirms rectangle("line", 10, 10, 100, 50) executes without raising an error.
    it("rectangle line mode", function()
        expect_no_error(function()
            lurek.graphic.rectangle("line", 10, 10, 100, 50)
        end)
    end)

    -- @description Asserts that lurek.graphic.circle has Lua type "function".
    it("circle is a function", function()
        expect_type("function", lurek.graphic.circle)
    end)

    -- @description Confirms circle("fill", 50, 50, 25) executes without raising an error.
    it("circle fill mode", function()
        expect_no_error(function()
            lurek.graphic.circle("fill", 50, 50, 25)
        end)
    end)

    -- @description Asserts that lurek.graphic.line has Lua type "function".
    it("line is a function", function()
        expect_type("function", lurek.graphic.line)
    end)

    -- @description Confirms line(0, 0, 100, 100) executes without raising an error.
    it("line accepts 4 args", function()
        expect_no_error(function()
            lurek.graphic.line(0, 0, 100, 100)
        end)
    end)
end)

-- @description Verifies the text drawing API exists and accepts a string plus x and y coordinates without error.
describe("lurek.graphic text functions", function()
    -- @description Asserts that lurek.graphic.print has Lua type "function".
    it("print is a function", function()
        expect_type("function", lurek.graphic.print)
    end)

    -- @description Confirms print("Hello", 10, 10) executes without raising an error.
    it("print accepts text and position", function()
        expect_no_error(function()
            lurek.graphic.print("Hello", 10, 10)
        end)
    end)
end)

-- @description Verifies the image creation and draw entry points are present on lurek.graphic.
describe("lurek.graphic image functions", function()
    -- @description Asserts that lurek.graphic.newImage has Lua type "function".
    it("newImage is a function", function()
        expect_type("function", lurek.graphic.newImage)
    end)

    -- @description Asserts that lurek.graphic.draw has Lua type "function".
    it("draw is a function", function()
        expect_type("function", lurek.graphic.draw)
    end)
end)

-- @description Verifies advanced shape APIs exist, accept representative arguments, and report mutable line width and positive surface dimensions.
describe("lurek.graphic advanced shapes", function()
    -- @description Asserts that lurek.graphic.ellipse has Lua type "function".
    it("ellipse is a function", function()
        expect_type("function", lurek.graphic.ellipse)
    end)

    -- @description Confirms ellipse("fill", 100, 100, 50, 30) executes without raising an error.
    it("ellipse fill mode", function()
        expect_no_error(function()
            lurek.graphic.ellipse("fill", 100, 100, 50, 30)
        end)
    end)

    -- @description Asserts that lurek.graphic.polygon has Lua type "function".
    it("polygon is a function", function()
        expect_type("function", lurek.graphic.polygon)
    end)

    -- @description Confirms polygon("fill", 0, 0, 100, 0, 50, 100) executes without raising an error.
    it("polygon fill mode with vertices", function()
        expect_no_error(function()
            lurek.graphic.polygon("fill", 0, 0, 100, 0, 50, 100)
        end)
    end)

    -- @description Asserts that lurek.graphic.triangle has Lua type "function".
    it("triangle is a function", function()
        expect_type("function", lurek.graphic.triangle)
    end)

    -- @description Confirms triangle("fill", 0, 0, 100, 0, 50, 80) executes without raising an error.
    it("triangle fill mode", function()
        expect_no_error(function()
            lurek.graphic.triangle("fill", 0, 0, 100, 0, 50, 80)
        end)
    end)

    -- @description Asserts that lurek.graphic.setLineWidth has Lua type "function".
    it("setLineWidth is a function", function()
        expect_type("function", lurek.graphic.setLineWidth)
    end)

    -- @description Asserts that lurek.graphic.getLineWidth has Lua type "function".
    it("getLineWidth is a function", function()
        expect_type("function", lurek.graphic.getLineWidth)
    end)

    -- @description Sets the line width to 3.0, expects getLineWidth() to return 3.0 within tolerance, then resets it to 1.0.
    it("setLineWidth and getLineWidth roundtrip", function()
        lurek.graphic.setLineWidth(3.0)
        expect_near(3.0, lurek.graphic.getLineWidth())
        lurek.graphic.setLineWidth(1.0) -- reset
    end)

    -- @description Verifies getDimensions() returns numeric width and height values and that both are greater than zero.
    it("getDimensions returns two numbers", function()
        local w, h = lurek.graphic.getDimensions()
        expect_type("number", w)
        expect_type("number", h)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)
end)

-- =========================================================================
-- Font metrics
-- =========================================================================
-- @description Verifies the font metric getter and setter entry points are present on lurek.graphic.
describe("font metrics", function()
    -- @description Asserts that lurek.graphic.getFontLineHeight has Lua type "function".
    it("getFontLineHeight is a function", function()
        expect_type("function", lurek.graphic.getFontLineHeight)
    end)

    -- @description Asserts that lurek.graphic.setFontLineHeight has Lua type "function".
    it("setFontLineHeight is a function", function()
        expect_type("function", lurek.graphic.setFontLineHeight)
    end)

    -- @description Asserts that lurek.graphic.getFontAscent has Lua type "function".
    it("getFontAscent is a function", function()
        expect_type("function", lurek.graphic.getFontAscent)
    end)

    -- @description Asserts that lurek.graphic.getFontDescent has Lua type "function".
    it("getFontDescent is a function", function()
        expect_type("function", lurek.graphic.getFontDescent)
    end)
end)

-- â”€â”€ Nine-Slice Tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies nine-slice constructors, accessors, draw paths, runtime type checks, and rejection of negative inset values.
describe("lurek.graphic nine-slice", function()
    -- @description Asserts that lurek.graphic.newNineSlice has Lua type "function".
    it("newNineSlice is a function", function()
        expect_type("function", lurek.graphic.newNineSlice)
    end)

    -- @description Asserts that lurek.graphic.drawNineSlice has Lua type "function".
    it("drawNineSlice is a function", function()
        expect_type("function", lurek.graphic.drawNineSlice)
    end)

    -- @description Creates a NineSlice from assets/icon.png and asserts the returned object has Lua type "userdata".
    it("creates a NineSlice from an image", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 10, 10, 10, 10)
        expect_type("userdata", ns)
    end)

    -- @description Creates a NineSlice with insets 12, 8, 15, 6 and asserts getInsets() returns those four values within tolerance.
    it("NineSlice:getInsets returns correct values", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 12, 8, 15, 6)
        local t, r, b, l = ns:getInsets()
        expect_near(12, t)
        expect_near(8, r)
        expect_near(15, b)
        expect_near(6, l)
    end)

    -- @description Creates a NineSlice and asserts getTextureSize() returns positive width and height values.
    it("NineSlice:getTextureSize returns image dimensions", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 5, 5, 5, 5)
        local w, h = ns:getTextureSize()
        assert(w > 0, "texture width should be positive")
        assert(h > 0, "texture height should be positive")
    end)

    -- @description Confirms drawNineSlice(ns, 50, 50, 300, 200) executes without raising an error for a valid NineSlice.
    it("drawNineSlice accepts NineSlice and rect", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 10, 10, 10, 10)
        expect_no_error(function()
            lurek.graphic.drawNineSlice(ns, 50, 50, 300, 200)
        end)
    end)

    -- @description Confirms the NineSlice userdata draw method executes without raising an error for valid coordinates and size.
    it("NineSlice:draw method works", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 5, 5, 5, 5)
        expect_no_error(function()
            ns:draw(10, 20, 400, 300)
        end)
    end)

    -- @description Asserts the NineSlice userdata reports true for typeOf("NineSlice") and typeOf("Object").
    it("NineSlice:typeOf returns NineSlice", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ns = lurek.graphic.newNineSlice(img, 5, 5, 5, 5)
        assert(ns:typeOf("NineSlice"), "should be NineSlice type")
        assert(ns:typeOf("Object"), "should be Object type")
    end)

    -- @description Calls newNineSlice with a negative top inset and asserts the construction fails by checking pcall returns false.
    it("rejects negative border insets", function()
        local img = lurek.graphic.newImage("assets/icon.png")
        local ok = pcall(function()
            lurek.graphic.newNineSlice(img, -5, 10, 10, 10)
        end)
        assert(not ok, "negative insets should error")
    end)
end)

-- â”€â”€ Polymorphic draw() dispatch â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @description Verifies polymorphic draw() rejects invalid inputs and remains exposed as a callable function.
describe("lurek.graphic.draw polymorphic dispatch", function()
    -- @description Asserts draw(nil, 0, 0) raises an error containing "nil".
    it("draw() rejects nil with an error", function()
        expect_error(function()
            lurek.graphic.draw(nil, 0, 0)
        end, "nil")
    end)

    -- @description Asserts draw("not_a_drawable", 0, 0) raises an error containing "drawable".
    it("draw() rejects a non-drawable string with an error", function()
        expect_error(function()
            lurek.graphic.draw("not_a_drawable", 0, 0)
        end, "drawable")
    end)

    -- @description Asserts that lurek.graphic.draw has Lua type "function".
    it("draw() is a function", function()
        expect_type("function", lurek.graphic.draw)
    end)
end)

-- @description Verifies captureScreenshot accepts a callback and passes an ImageData userdata into that callback.
describe("lurek.graphic.captureScreenshot", function()
  -- @description Calls captureScreenshot with a callback under pcall and asserts the call succeeds with ok == true.
  it("accepts a callback without error", function()
    local ok, err = pcall(lurek.graphic.captureScreenshot, function(img)
      -- callback fires synchronously in stub mode; img is ImageData userdata
    end)
    expect_equal(ok, true)
  end)

  -- @description Captures the callback argument type and asserts captureScreenshot passes a userdata value.
  it("callback receives an ImageData userdata", function()
    local received_type = nil
    lurek.graphic.captureScreenshot(function(img)
      received_type = type(img)
    end)
    expect_equal(received_type, "userdata")
  end)
end)

-- @description Verifies saveScreenshot allows save-relative paths and rejects paths outside the save sandbox.
describe("lurek.graphic.saveScreenshot", function()
    -- @description Calls saveScreenshot("save/test_graphics.png") under pcall and asserts the call succeeds.
    it("accepts a save-relative path without error", function()
        local ok = pcall(lurek.graphic.saveScreenshot, "save/test_graphics.png")
        expect_equal(ok, true)
    end)

    -- @description Asserts saveScreenshot("test_graphics.png") raises an error mentioning the required save/ prefix.
    it("rejects paths outside save", function()
        expect_error(function()
            lurek.graphic.saveScreenshot("test_graphics.png")
        end, "save/")
    end)
end)

-- @description Verifies stencil mode state can be set, queried, reset to defaults, and rejects invalid actions while exposing all three stencil functions.
describe("lurek.graphic stencil mode", function()
  -- @description Sets stencil mode to replace/always/1 and asserts getStencilMode() returns exactly those three values.
  it("setStencilMode and getStencilMode round-trip correctly", function()
    lurek.graphic.setStencilMode("replace", "always", 1)
    local action, compare, value = lurek.graphic.getStencilMode()
    expect_equal(action, "replace")
    expect_equal(compare, "always")
    expect_equal(value, 1)
  end)

  -- @description Sets a non-default stencil mode, clears it, and asserts the state resets to keep, always, and 0.
  it("clearStencil resets to keep/always/0", function()
    lurek.graphic.setStencilMode("invert", "equal", 5)
    lurek.graphic.clearStencil()
    local action, compare, value = lurek.graphic.getStencilMode()
    expect_equal(action, "keep")
    expect_equal(compare, "always")
    expect_equal(value, 0)
  end)

  -- @description Calls setStencilMode("zero") with omitted compare and value and asserts getStencilMode() reports zero, always, and 0.
  it("setStencilMode defaults compare to always when omitted", function()
    lurek.graphic.setStencilMode("zero")
    local action, compare, value = lurek.graphic.getStencilMode()
    expect_equal(action, "zero")
    expect_equal(compare, "always")
    expect_equal(value, 0)
  end)

  -- @description Asserts setStencilMode("explode") raises an error for an unknown action.
  it("setStencilMode errors on unknown action", function()
    expect_error(function()
      lurek.graphic.setStencilMode("explode")
    end)
  end)

  -- @description Asserts that lurek.graphic.setStencilMode has Lua type "function".
  it("setStencilMode is a function", function()
    expect_type("function", lurek.graphic.setStencilMode)
  end)

  -- @description Asserts that lurek.graphic.getStencilMode has Lua type "function".
  it("getStencilMode is a function", function()
    expect_type("function", lurek.graphic.getStencilMode)
  end)

  -- @description Asserts that lurek.graphic.clearStencil has Lua type "function".
  it("clearStencil is a function", function()
    expect_type("function", lurek.graphic.clearStencil)
  end)
end)

-- @description Verifies depth mode state can be set and queried, defaults write to false when omitted, rejects invalid modes, and exposes both depth functions.
describe("lurek.graphic depth mode", function()
  -- @description Sets depth mode to less with write enabled and asserts getDepthMode() returns "less" and true.
  it("setDepthMode and getDepthMode round-trip correctly", function()
    lurek.graphic.setDepthMode("less", true)
    local mode, write = lurek.graphic.getDepthMode()
    expect_equal(mode, "less")
    expect_equal(write, true)
  end)

  -- @description Calls setDepthMode("always") without the write flag and asserts getDepthMode() returns "always" and false.
  it("setDepthMode write defaults to false", function()
    lurek.graphic.setDepthMode("always")
    local mode, write = lurek.graphic.getDepthMode()
    expect_equal(mode, "always")
    expect_equal(write, false)
  end)

  -- @description Asserts setDepthMode("turbo") raises an error for an unknown depth mode.
  it("setDepthMode errors on unknown mode", function()
    expect_error(function()
      lurek.graphic.setDepthMode("turbo")
    end)
  end)

  -- @description Asserts that lurek.graphic.setDepthMode has Lua type "function".
  it("setDepthMode is a function", function()
    expect_type("function", lurek.graphic.setDepthMode)
  end)

  -- @description Asserts that lurek.graphic.getDepthMode has Lua type "function".
  it("getDepthMode is a function", function()
    expect_type("function", lurek.graphic.getDepthMode)
  end)
end)

test_summary()
