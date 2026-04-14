-- Lurek2D Integration Test: Cellular World Simulation
-- Exercises CellularWorld step simulation: sand falling, water spreading,
-- and serialisation round-trip with non-trivial state.

-- @description Covers suite: cellular world simulation integration.
describe("cellular world simulation integration", function()
    -- @covers lurek.physics.newCellular
    -- @covers LuaCellular:fillRect
    -- @covers LuaCellular:stepN
    -- @covers LuaCellular:countCells
    -- @description Verifies that sand placed at the top of a column falls
    --              over 50 steps, reducing sand count at the original row.
    it("sand migrates downward over 50 steps", function()
        local sim = lurek.physics.newCellular(8, 32)

        -- Fill the top row with sand; all lower rows are air.
        sim:fillRect(0, 0, 8, 1, lurek.physics.CELL_SAND)
        local count_before = sim:countCells(lurek.physics.CELL_SAND)
        expect_equal(8, count_before)

        sim:stepN(50)

        -- Total sand must remain the same (conservation).
        local count_after = sim:countCells(lurek.physics.CELL_SAND)
        expect_equal(count_before, count_after)

        -- None of the original top cells should remain sand.
        local top_sand = 0
        for x = 0, 7 do
            if sim:getCell(x, 0) == lurek.physics.CELL_SAND then
                top_sand = top_sand + 1
            end
        end
        expect_equal(0, top_sand)
    end)

    -- @covers LuaCellular:toImageData
    -- @description Verifies toImageData returns width*height*4 bytes.
    it("toImageData returns correct byte count", function()
        local w, h = 16, 16
        local sim = lurek.physics.newCellular(w, h)
        local img = sim:toImageData()
        expect_equal(w * h * 4, #img)
    end)

    -- @covers LuaCellular:toImageDataRegion
    -- @description Verifies toImageDataRegion returns the sub-region byte count.
    it("toImageDataRegion returns sub-region byte count", function()
        local sim = lurek.physics.newCellular(64, 64)
        local img = sim:toImageDataRegion(0, 0, 8, 8)
        expect_equal(8 * 8 * 4, #img)
    end)

    -- @covers LuaCellular:toBytes
    -- @covers LuaCellular:loadFromBytes
    -- @description Verifies serialisation after a non-trivial simulation is lossless.
    it("serialisation after 20 steps is lossless", function()
        local sim1 = lurek.physics.newCellular(16, 16)
        sim1:fillRect(0, 0, 16, 1, lurek.physics.CELL_SAND)
        sim1:stepN(20)

        local bytes = sim1:toBytes()

        local sim2 = lurek.physics.newCellular(16, 16)
        local ok = sim2:loadFromBytes(bytes)
        expect_true(ok)
        expect_equal(
            sim1:countCells(lurek.physics.CELL_SAND),
            sim2:countCells(lurek.physics.CELL_SAND)
        )
    end)

    -- @covers LuaCellular:fillCircle
    -- @covers LuaCellular:countCells
    -- @description Verifies fillCircle and countCells agree on placed cell count.
    it("fillCircle count matches countCells after fill", function()
        local sim = lurek.physics.newCellular(32, 32)
        sim:fillCircle(16, 16, 4, lurek.physics.CELL_ROCK)
        local n = sim:countCells(lurek.physics.CELL_ROCK)
        expect_true(n > 0, "at least one rock cell placed")
        -- fillCircle with r=4 on a 32×32 grid should place roughly π*16≈50 cells
        expect_true(n >= 20, "circle should cover at least 20 cells")
    end)
end)

test_summary()
