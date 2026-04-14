-- Stress test: large terrain fill/dig/flush cycle
-- Exercises TerrainMap with a 128x128 grid, multiple fill + dig + flush iterations.

-- @description Covers suite: stress: physics terrain fill/dig/flush.
describe("stress: physics terrain fill/dig/flush", function()
    -- @covers lurek.physics.newTerrain
    -- @covers LuaTerrain:fillAll
    -- @covers LuaTerrain:fillCircle
    -- @covers LuaTerrain:flush
    -- @covers LuaTerrain:isDirty
    -- @description Performs 20 fill/dig/flush cycles on a 128x128 terrain
    --              and verifies the dirty flag is cleared each time.
    it("20 fill/dig/flush cycles complete without error on 128x128", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(128, 128, 4, world)

        expect_no_error(function()
            for i = 1, 20 do
                terrain:fillAll(true)
                -- Dig a different circle each iteration.
                local cx = 64 + (i % 5) * 8
                local cy = 64 + math.floor(i / 5) * 8
                terrain:fillCircle(cx * 4, cy * 4, 32, false)
                terrain:flush()
                expect_false(terrain:isDirty())
            end
        end)
    end)

    -- @covers LuaTerrain:collapseColumns
    -- @covers LuaTerrain:solidPositions
    -- @description Verifies collapse + solidPositions returns consistent
    --              counts on a partially-filled grid.
    it("collapse then solidPositions is consistent", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(64, 64, 4, world)
        -- Fill top half only (rows 0-31); rows 32-63 are air → all top cells will collapse.
        terrain:fillRect(0, 0, 256, 128, true) -- world coords for rows 0-31
        local before = #terrain:solidPositions()
        terrain:collapseColumns()
        local after = #terrain:solidPositions()
        -- Can only check after <= before (collapseColumns removes cells).
        expect_true(after <= before, "solidPositions count must not increase after collapse")
    end)
end)

test_summary()
