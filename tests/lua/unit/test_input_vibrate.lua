-- tests/lua/unit/test_input_vibrate.lua
-- BDD tests for lurek.gamepad.vibrate and lurek.gamepad.isVibrationSupported

-- @description Verifies the gamepad vibration stub API.

describe("lurek.gamepad vibration API types", function()
  -- @covers lurek.gamepad.vibrate
  it("vibrate is a function", function()
    expect_type("function", lurek.gamepad.vibrate)
  end)

  -- @covers lurek.gamepad.isVibrationSupported
  it("isVibrationSupported is a function", function()
    expect_type("function", lurek.gamepad.isVibrationSupported)
  end)
end)

describe("lurek.gamepad.isVibrationSupported", function()
  -- @covers lurek.gamepad.isVibrationSupported
  it("returns a boolean", function()
    local result = lurek.gamepad.isVibrationSupported(0)
    expect_type("boolean", result)
  end)

  it("returns false for unknown gamepad id", function()
    local result = lurek.gamepad.isVibrationSupported(99)
    expect_equal(false, result)
  end)
end)

describe("lurek.gamepad.vibrate", function()
  -- @covers lurek.gamepad.vibrate
  it("returns a boolean", function()
    local result = lurek.gamepad.vibrate(0, 0.5, 0.5, 200)
    expect_type("boolean", result)
  end)

  it("returns false on unsupported platform", function()
    local result = lurek.gamepad.vibrate(0, 1.0, 1.0, 500)
    expect_equal(false, result)
  end)

  it("zero duration does not error", function()
    local result = lurek.gamepad.vibrate(0, 0.0, 0.0, 0.0)
    expect_type("boolean", result)
  end)

  it("clamped high-frequency above 1 does not error", function()
    local result = lurek.gamepad.vibrate(0, 5.0, 5.0, 100)
    expect_type("boolean", result)
  end)

  it("negative duration does not error", function()
    local result = lurek.gamepad.vibrate(0, 0.5, 0.5, -100)
    expect_type("boolean", result)
  end)
end)

test_summary()
