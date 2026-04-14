-- Stress test: large cellular world simulation
-- Steps a 128x128 CellularWorld 500 times and verifies no crash.

-- @description Covers suite: stress: cellular world simulation.
describe("stress: cellular world simulation", function()
    -- @covers lurek.physics.newCellular
    -- @covers LuaCellular:fillRect
    -- @covers LuaCellular:stepN
    -- @covers LuaCellular:countCells
    -- @description Steps a 128x128 grid for 500 ticks with mixed materials
    --              and verifies simulation completes without error.
    it("128x128 cellular steps 500 ticks without error", function()
        local W, H = 128, 128
        local sim = lurek.physics.newCellular(W, H)

        -- Place a layer of sand at the top.
        sim:fillRect(0, 0, W, 4, lurek.physics.CELL_SAND)
        -- Place a water layer in the middle.
        sim:fillRect(0, H // 2, W, 4, lurek.physics.CELL_WATER)
        -- Rock floor.
        sim:fillRect(0, H - 2, W, 2, lurek.physics.CELL_ROCK)

        local sand_initial = sim:countCells(lurek.physics.CELL_SAND)
        local rock_initial = sim:countCells(lurek.physics.CELL_ROCK)

        expect_no_error(function()
            sim:stepN(500)
        end)

        -- Rock is immutable — count must remain the same.
        expect_equal(rock_initial, sim:countCells(lurek.physics.CELL_ROCK))

        -- Sand is conserved.
        expect_equal(sand_initial, sim:countCells(lurek.physics.CELL_SAND))
    end)

    -- @covers LuaCellular:toImageData
    -- @description Verifies toImageData on a 128x128 grid still returns correct byte count
    --              after a long simulation run.
    it("toImageData returns correct size after 200 steps", function()
        local W, H = 128, 128
        local sim = lurek.physics.newCellular(W, H)
        sim:fillRect(0, 0, W, 1, lurek.physics.CELL_SAND)
        sim:stepN(200)
        local raw = sim:toImageData()
        expect_equal(W * H * 4, #raw)
    end)
end)

test_summary()
