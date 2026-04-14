-- Lurek2D Physics Cellular API Tests
-- Tests for lurek.physics.newCellular, LuaCellular cell access, fill, step, serialisation.

-- @description Covers suite: lurek.physics cellular factory.
describe("lurek.physics cellular factory", function()
    -- @covers lurek.physics.newCellular
    -- @description Verifies newCellular is exposed as a callable factory.
    it("newCellular is a function", function()
        expect_type("function", lurek.physics.newCellular)
    end)

    -- @covers lurek.physics.newCellular
    -- @description Verifies newCellular returns userdata.
    it("newCellular returns userdata", function()
        local sim = lurek.physics.newCellular(32, 32)
        expect_type("userdata", sim)
    end)
end)

-- @description Covers suite: lurek.physics cellular cell-type constants.
describe("lurek.physics cellular cell-type constants", function()
    -- @covers lurek.physics.CELL_AIR
    -- @description Verifies CELL_AIR is an integer.
    it("CELL_AIR is an integer", function()
        expect_type("number", lurek.physics.CELL_AIR)
        expect_equal(0, lurek.physics.CELL_AIR)
    end)

    -- @covers lurek.physics.CELL_SAND
    it("CELL_SAND is greater than CELL_AIR", function()
        expect_true(lurek.physics.CELL_SAND > lurek.physics.CELL_AIR)
    end)

    -- @covers lurek.physics.CELL_WATER
    it("CELL_WATER is an integer", function()
        expect_type("number", lurek.physics.CELL_WATER)
    end)

    -- @covers lurek.physics.CELL_ROCK
    it("CELL_ROCK is an integer", function()
        expect_type("number", lurek.physics.CELL_ROCK)
    end)

    -- @covers lurek.physics.CELL_FIRE
    it("CELL_FIRE is an integer", function()
        expect_type("number", lurek.physics.CELL_FIRE)
    end)

    -- @covers lurek.physics.CELL_GAS
    it("CELL_GAS is an integer", function()
        expect_type("number", lurek.physics.CELL_GAS)
    end)
end)

-- @description Covers suite: lurek.physics cellular cell access.
describe("lurek.physics cellular cell access", function()
    local sim

    before_each(function()
        sim = lurek.physics.newCellular(16, 16)
    end)

    -- @covers LuaCellular:getCell
    -- @description Verifies all cells start as CELL_AIR.
    it("new grid is all air", function()
        expect_equal(lurek.physics.CELL_AIR, sim:getCell(0, 0))
        expect_equal(lurek.physics.CELL_AIR, sim:getCell(8, 8))
    end)

    -- @covers LuaCellular:setCell
    -- @covers LuaCellular:getCell
    -- @description Verifies setCell changes the material at a position.
    it("setCell changes cell type", function()
        sim:setCell(5, 5, lurek.physics.CELL_SAND)
        expect_equal(lurek.physics.CELL_SAND, sim:getCell(5, 5))
    end)

    -- @covers LuaCellular:setCell
    -- @covers LuaCellular:getCell
    -- @description Verifies setting a cell back to AIR clears it.
    it("setting cell to AIR clears it", function()
        sim:setCell(3, 3, lurek.physics.CELL_ROCK)
        sim:setCell(3, 3, lurek.physics.CELL_AIR)
        expect_equal(lurek.physics.CELL_AIR, sim:getCell(3, 3))
    end)
end)

-- @description Covers suite: lurek.physics cellular bulk fill.
describe("lurek.physics cellular bulk fill", function()
    local sim

    before_each(function()
        sim = lurek.physics.newCellular(32, 32)
    end)

    -- @covers LuaCellular:fillRect
    -- @covers LuaCellular:getCell
    -- @description Verifies fillRect marks cells inside the region.
    it("fillRect fills the specified region", function()
        sim:fillRect(5, 5, 4, 4, lurek.physics.CELL_ROCK)
        expect_equal(lurek.physics.CELL_ROCK, sim:getCell(6, 6))
        -- outside the region should remain air
        expect_equal(lurek.physics.CELL_AIR, sim:getCell(0, 0))
    end)

    -- @covers LuaCellular:fillCircle
    -- @covers LuaCellular:getCell
    -- @description Verifies fillCircle marks the centre cell.
    it("fillCircle marks centre cell", function()
        sim:fillCircle(16, 16, 3, lurek.physics.CELL_WATER)
        expect_equal(lurek.physics.CELL_WATER, sim:getCell(16, 16))
    end)
end)

-- @description Covers suite: lurek.physics cellular step.
describe("lurek.physics cellular step", function()
    -- @covers LuaCellular:setCell
    -- @covers LuaCellular:step
    -- @covers LuaCellular:countCells
    -- @description Verifies sand falls when there is air below it.
    it("sand cell falls after one step", function()
        local sim = lurek.physics.newCellular(8, 8)
        -- Place sand at top row (row 0), air below.
        sim:setCell(4, 0, lurek.physics.CELL_SAND)
        local before = sim:countCells(lurek.physics.CELL_SAND)
        sim:step()
        -- Sand count should remain the same (sand moves, not disappears).
        expect_equal(before, sim:countCells(lurek.physics.CELL_SAND))
        -- Top cell should now be air (sand moved down).
        expect_equal(lurek.physics.CELL_AIR, sim:getCell(4, 0))
    end)

    -- @covers LuaCellular:stepN
    -- @coverage Verifies stepN is callable with n > 1.
    it("stepN accepts a count without error", function()
        local sim = lurek.physics.newCellular(16, 16)
        sim:fillRect(0, 0, 16, 1, lurek.physics.CELL_SAND)
        expect_no_error(function()
            sim:stepN(10)
        end)
    end)
end)

-- @description Covers suite: lurek.physics cellular query.
describe("lurek.physics cellular query", function()
    -- @covers LuaCellular:countCells
    -- @description Verifies countCells returns the precise number of matching cells.
    it("countCells matches manually placed cells", function()
        local sim = lurek.physics.newCellular(16, 16)
        sim:setCell(0, 0, lurek.physics.CELL_ROCK)
        sim:setCell(1, 0, lurek.physics.CELL_ROCK)
        sim:setCell(2, 0, lurek.physics.CELL_ROCK)
        expect_equal(3, sim:countCells(lurek.physics.CELL_ROCK))
    end)

    -- @covers LuaCellular:findCells
    -- @description Verifies findCells returns table entries with x/y fields.
    it("findCells returns x/y tables for each match", function()
        local sim = lurek.physics.newCellular(16, 16)
        sim:setCell(3, 7, lurek.physics.CELL_WATER)
        local found = sim:findCells(lurek.physics.CELL_WATER)
        expect_equal(1, #found)
        expect_type("table", found[1])
        expect_equal(3, found[1].x)
        expect_equal(7, found[1].y)
    end)
end)

-- @description Covers suite: lurek.physics cellular serialisation.
describe("lurek.physics cellular serialisation", function()
    -- @covers LuaCellular:toBytes
    -- @covers LuaCellular:loadFromBytes
    -- @description Verifies round-trip serialisation preserves cell data.
    it("toBytes/loadFromBytes round-trip preserves cells", function()
        local s1 = lurek.physics.newCellular(8, 8)
        s1:setCell(3, 3, lurek.physics.CELL_SAND)
        s1:setCell(6, 1, lurek.physics.CELL_ROCK)

        local bytes = s1:toBytes()
        expect_type("string", bytes)

        local s2 = lurek.physics.newCellular(8, 8)
        local ok = s2:loadFromBytes(bytes)
        expect_true(ok)
        expect_equal(lurek.physics.CELL_SAND, s2:getCell(3, 3))
        expect_equal(lurek.physics.CELL_ROCK, s2:getCell(6, 1))
        expect_equal(lurek.physics.CELL_AIR,  s2:getCell(0, 0))
    end)
end)

test_summary()
