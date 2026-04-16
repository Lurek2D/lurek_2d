-- tests/lua/unit/test_math_voronoi.lua
-- BDD tests for lurek.math.voronoi

-- @description Verifies the Voronoi tessellation function: return type, cell count,
-- site coordinates, vertex ordering, and degenerate-input handling.

describe("lurek.math.voronoi type", function()
  -- @covers lurek.math.voronoi
  it("voronoi is a function", function()
    expect_type("function", lurek.math.voronoi)
  end)

  it("returns a table", function()
    local cells = lurek.math.voronoi({{x=0,y=0},{x=1,y=0},{x=0.5,y=1}})
    expect_type("table", cells)
  end)
end)

describe("lurek.math.voronoi empty input", function()
  -- @covers lurek.math.voronoi
  it("empty input returns empty table", function()
    local cells = lurek.math.voronoi({})
    expect_equal(0, #cells)
  end)
end)

describe("lurek.math.voronoi cell count", function()
  -- @covers lurek.math.voronoi
  it("returns one cell per unique site", function()
    local pts = {{x=0,y=0},{x=1,y=0},{x=0.5,y=1},{x=0.5,y=0.5}}
    local cells = lurek.math.voronoi(pts)
    expect_equal(4, #cells)
  end)

  it("three-point input returns three cells", function()
    local pts = {{x=0,y=0},{x=1,y=0},{x=0.5,y=1}}
    local cells = lurek.math.voronoi(pts)
    expect_equal(3, #cells)
  end)
end)

describe("lurek.math.voronoi cell structure", function()
  -- @covers lurek.math.voronoi
  it("each cell has a site table", function()
    local pts = {{x=0,y=0},{x=1,y=0},{x=0.5,y=1}}
    local cells = lurek.math.voronoi(pts)
    for _, cell in ipairs(cells) do
      expect_type("table", cell.site)
    end
  end)

  it("each cell site has x and y keys", function()
    local pts = {{x=0,y=0},{x=1,y=0},{x=0.5,y=1}}
    local cells = lurek.math.voronoi(pts)
    for _, cell in ipairs(cells) do
      expect_type("number", cell.site.x)
      expect_type("number", cell.site.y)
    end
  end)

  it("each cell has a vertices table", function()
    local pts = {{x=0,y=0},{x=1,y=0},{x=0.5,y=1}}
    local cells = lurek.math.voronoi(pts)
    for _, cell in ipairs(cells) do
      expect_type("table", cell.vertices)
    end
  end)
end)

describe("lurek.math.voronoi vertex coordinates", function()
  -- @covers lurek.math.voronoi
  it("vertex entries have x and y as numbers", function()
    local pts = {
      {x=0,y=0},{x=2,y=0},{x=1,y=2},{x=1,y=0.5}
    }
    local cells = lurek.math.voronoi(pts)
    local found_vertex = false
    for _, cell in ipairs(cells) do
      for _, v in ipairs(cell.vertices) do
        expect_type("number", v.x)
        expect_type("number", v.y)
        found_vertex = true
      end
    end
    -- At least one vertex should exist for a 4-point diagram
    expect_equal(true, found_vertex)
  end)
end)

describe("lurek.math.voronoi near-duplicate deduplication", function()
  -- @covers lurek.math.voronoi
  it("near-coincident points are merged into fewer cells", function()
    -- Two points separated by 1e-7 should deduplicate to 1 effective site
    local pts = {
      {x=0, y=0}, {x=0, y=1e-7},
      {x=1, y=0}, {x=0.5, y=1}
    }
    local cells = lurek.math.voronoi(pts)
    -- After deduplication we expect fewer than 4 cells
    expect_equal(true, #cells < 4)
  end)
end)

test_summary()
