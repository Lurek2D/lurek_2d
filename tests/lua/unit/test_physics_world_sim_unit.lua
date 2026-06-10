-- Lurek2D Integration Test: Cellular World Simulation
-- Exercises CellularWorld step simulation: sand falling, water spreading,
-- and serialisation round-trip with non-trivial state.

-- @describe cellular world simulation integration
describe("cellular world simulation integration", function()
    --              over 50 steps, reducing sand count at the original row.
    -- @covers LCellular:stepN
    it("sand migrates downward over 50 steps", function()
        local sim = lurek.procgen.newCellular(8, 32)

        -- Fill the top row with sand; all lower rows are air.
        sim:fillRect(0, 0, 8, 1, lurek.procgen.CELL_SAND)
        local count_before = sim:countCells(lurek.procgen.CELL_SAND)
        expect_equal(8, count_before)

        sim:stepN(50)

        -- Total sand must remain the same (conservation).
        local count_after = sim:countCells(lurek.procgen.CELL_SAND)
        expect_equal(count_before, count_after)

        -- None of the original top cells should remain sand.
        local top_sand = 0
        for x = 0, 7 do
            if sim:getCell(x, 0) == lurek.procgen.CELL_SAND then
                top_sand = top_sand + 1
            end
        end
        expect_equal(0, top_sand)
    end)

    -- @covers LCellular:toImageData
    it("toImageData returns correct byte count", function()
        local w, h = 16, 16
        local sim = lurek.procgen.newCellular(w, h)
        local img = sim:toImageData()
        expect_equal(w * h * 4, #img)
    end)

    -- @covers LCellular:toImageDataRegion
    it("toImageDataRegion returns sub-region byte count", function()
        local sim = lurek.procgen.newCellular(64, 64)
        local img = sim:toImageDataRegion(0, 0, 8, 8)
        expect_equal(8 * 8 * 4, #img)
    end)

    -- @covers LCellular:loadFromBytes
    it("serialisation after 20 steps is lossless", function()
        local sim1 = lurek.procgen.newCellular(16, 16)
        sim1:fillRect(0, 0, 16, 1, lurek.procgen.CELL_SAND)
        sim1:stepN(20)

        local bytes = sim1:toBytes()

        local sim2 = lurek.procgen.newCellular(16, 16)
        local ok = sim2:loadFromBytes(bytes)
        expect_true(ok)
        expect_equal(
            sim1:countCells(lurek.procgen.CELL_SAND),
            sim2:countCells(lurek.procgen.CELL_SAND)
        )
    end)

    -- @covers LCellular:fillCircle
    it("fillCircle count matches countCells after fill", function()
        local sim = lurek.procgen.newCellular(32, 32)
        sim:fillCircle(16, 16, 4, lurek.procgen.CELL_ROCK)
        local n = sim:countCells(lurek.procgen.CELL_ROCK)
        expect_true(n > 0, "at least one rock cell placed")
        -- fillCircle with r=4 on a 32  32 grid should place roughly   *16   50 cells
        expect_true(n >= 20, "circle should cover at least 20 cells")
    end)
end)
test_summary()
