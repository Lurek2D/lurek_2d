-- tests/lua/unit/test_automation_highlight.lua
-- BDD tests for lurek.simulator setHighlightMode / isHighlightMode

-- @description Verifies the highlight overlay hint flag on lurek.simulator.

describe("lurek.simulator highlight mode API types", function()
  -- @covers lurek.simulator.setHighlightMode
  it("setHighlightMode is a function", function()
    expect_type("function", lurek.simulator.setHighlightMode)
  end)

  -- @covers lurek.simulator.isHighlightMode
  it("isHighlightMode is a function", function()
    expect_type("function", lurek.simulator.isHighlightMode)
  end)
end)

describe("lurek.simulator.isHighlightMode default", function()
  -- @covers lurek.simulator.isHighlightMode
  it("default highlight mode is false", function()
    -- Reset state first: enabling then disabling resets to false
    lurek.simulator.setHighlightMode(false)
    local result = lurek.simulator.isHighlightMode()
    expect_equal(false, result)
  end)
end)

describe("lurek.simulator setHighlightMode / isHighlightMode roundtrip", function()
  -- @covers lurek.simulator.setHighlightMode
  -- @covers lurek.simulator.isHighlightMode
  it("enable returns true from isHighlightMode", function()
    lurek.simulator.setHighlightMode(true)
    expect_equal(true, lurek.simulator.isHighlightMode())
    -- clean up
    lurek.simulator.setHighlightMode(false)
  end)

  it("disable after enable returns false", function()
    lurek.simulator.setHighlightMode(true)
    lurek.simulator.setHighlightMode(false)
    expect_equal(false, lurek.simulator.isHighlightMode())
  end)

  it("setting true twice still returns true", function()
    lurek.simulator.setHighlightMode(true)
    lurek.simulator.setHighlightMode(true)
    expect_equal(true, lurek.simulator.isHighlightMode())
    lurek.simulator.setHighlightMode(false)
  end)

  it("isHighlightMode returns a boolean", function()
    local result = lurek.simulator.isHighlightMode()
    expect_type("boolean", result)
  end)
end)

test_summary()
