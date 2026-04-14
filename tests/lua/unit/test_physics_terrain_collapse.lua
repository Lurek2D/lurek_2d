-- Lurek2D Physics Terrain Collapse Tests
-- Tests for TerrainMap::collapse_columns (column-gravity simulation).

-- @description Covers suite: lurek.physics terrain collapse columns.
describe("lurek.physics terrain collapse columns", function()
    -- @covers LuaTerrain:collapseColumns
    -- @description Verifies collapseColumns returns a non-negative integer.
    it("collapseColumns returns a non-negative integer", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(16, 16, 8, world)
        local n = terrain:collapseColumns()
        expect_true(n >= 0, "count must be non-negative")
    end)

    -- @covers LuaTerrain:fillAll
    -- @covers LuaTerrain:collapseColumns
    -- @description Verifies that a fully solid terrain has zero cells to collapse
    --              (every cell has its neighbour below it).
    it("fully solid terrain collapses zero cells", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        terrain:fillAll(true)
        local n = terrain:collapseColumns()
        expect_equal(0, n)
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:collapseColumns
    -- @covers LuaTerrain:getCell
    -- @description Verifies a lone floating cell collapses to empty when
    --              it has no floor, no left neighbour, and no right neighbour.
    it("isolated floating cell collapses", function()
        local world = lurek.physics.newWorld(0, 0)
        -- 8 columns, 8 rows, 8px cells
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        -- Place one solid cell in the middle of the top row (row 0, col 4).
        -- Below it (row 1) is empty.  No horizontal neighbours.
        terrain:setCell(4, 0, true)
        local n = terrain:collapseColumns()
        expect_true(n >= 1, "at least one cell should collapse")
        expect_false(terrain:getCell(4, 0))
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:collapseColumns
    -- @covers LuaTerrain:getCell
    -- @description Verifies that a cell resting on a solid floor does NOT collapse.
    it("cell on solid floor does not collapse", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        -- Stack: solid at row 6, solid at row 7 (floor row = height-1).
        terrain:setCell(3, 6, true)
        terrain:setCell(3, 7, true) -- floor
        local n = terrain:collapseColumns()
        expect_equal(0, n)
        expect_true(terrain:getCell(3, 6))
    end)

    -- @covers LuaTerrain:collapseColumns
    -- @covers LuaTerrain:isDirty
    -- @description Verifies isDirty is set after a collapse removes cells.
    it("collapseColumns marks terrain dirty when cells fall", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        terrain:setCell(4, 0, true)
        terrain:flush() -- clear dirty flag first
        terrain:collapseColumns()
        expect_true(terrain:isDirty())
    end)
end)

-- @description Covers suite: lurek.physics terrain solid positions.
describe("lurek.physics terrain solid positions", function()
    -- @covers LuaTerrain:solidPositions
    -- @description Verifies solidPositions returns an empty table for a blank grid.
    it("solidPositions empty for blank terrain", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        local pts = terrain:solidPositions()
        expect_equal(0, #pts)
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:solidPositions
    -- @description Verifies solidPositions returns one entry after one cell is set.
    it("solidPositions returns one entry after one setCell", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(8, 8, 8, world)
        terrain:setCell(2, 2, true)
        local pts = terrain:solidPositions()
        expect_equal(1, #pts)
        expect_type("table", pts[1])
        expect_true(pts[1].x ~= nil, "entry has x field")
        expect_true(pts[1].y ~= nil, "entry has y field")
    end)
end)

test_summary()
