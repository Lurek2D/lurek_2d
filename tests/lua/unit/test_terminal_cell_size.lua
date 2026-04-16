-- tests/lua/unit/test_terminal_cell_size.lua
-- BDD tests for terminal:setCellSize, terminal:resetCellSize, terminal:getCellSize

-- @description Verifies the per-terminal cell pixel size override API.

describe("terminal:setCellSize type guards", function()
  -- @covers lurek.terminal.new
  it("setCellSize is a function", function()
    local t = lurek.terminal.new(20, 10)
    expect_type("function", t.setCellSize)
  end)

  it("resetCellSize is a function", function()
    local t = lurek.terminal.new(20, 10)
    expect_type("function", t.resetCellSize)
  end)

  it("getCellSize is a function", function()
    local t = lurek.terminal.new(20, 10)
    expect_type("function", t.getCellSize)
  end)
end)

describe("terminal getCellSize default", function()
  -- @covers lurek.terminal.new
  it("getCellSize returns nil before any override is set", function()
    local t = lurek.terminal.new(20, 10)
    local result = t:getCellSize()
    expect_equal(nil, result)
  end)
end)

describe("terminal setCellSize / getCellSize roundtrip", function()
  -- @covers lurek.terminal.new
  it("getCellSize returns set values after setCellSize", function()
    local t = lurek.terminal.new(20, 10)
    t:setCellSize(12, 20)
    local cs = t:getCellSize()
    expect_type("table", cs)
    expect_near(12.0, cs.w, 0.001)
    expect_near(20.0, cs.h, 0.001)
  end)

  it("setCellSize clamps values below 1 to 1", function()
    local t = lurek.terminal.new(20, 10)
    t:setCellSize(0, -5)
    local cs = t:getCellSize()
    expect_type("table", cs)
    expect_equal(true, cs.w >= 1.0)
    expect_equal(true, cs.h >= 1.0)
  end)

  it("setCellSize with large values is stored correctly", function()
    local t = lurek.terminal.new(20, 10)
    t:setCellSize(64, 128)
    local cs = t:getCellSize()
    expect_near(64.0, cs.w, 0.001)
    expect_near(128.0, cs.h, 0.001)
  end)
end)

describe("terminal resetCellSize", function()
  -- @covers lurek.terminal.new
  it("getCellSize returns nil after resetCellSize", function()
    local t = lurek.terminal.new(20, 10)
    t:setCellSize(10, 18)
    t:resetCellSize()
    local cs = t:getCellSize()
    expect_equal(nil, cs)
  end)

  it("override can be set again after reset", function()
    local t = lurek.terminal.new(20, 10)
    t:setCellSize(10, 18)
    t:resetCellSize()
    t:setCellSize(5, 9)
    local cs = t:getCellSize()
    expect_type("table", cs)
    expect_near(5.0, cs.w, 0.001)
    expect_near(9.0, cs.h, 0.001)
  end)
end)

test_summary()
