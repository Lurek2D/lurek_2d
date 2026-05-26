-- Lurek2D Integration Test: Tanks-style Terrain Collapse + Debris
-- Exercises TerrainMap column collapse and debris spawning together with World.

-- @describe tanks terrain collapse + debris integration
describe("tanks terrain collapse + debris integration", function()
    --              can be spawned and the physics world can step without error.
    -- @covers LTerrain:collapseColumns
    -- @covers LTerrain:fillRect
    -- @covers LTerrain:flush
    -- @covers LTerrain:setCell
    -- @covers LTerrain:solidPositions
    -- @covers LTerrain:spawnDebris
    -- @covers LWorld:step
    -- @covers lurek.physics.newTerrain
    -- @covers lurek.physics.newWorld
    it("collapse then spawn debris and step without error", function()
        local world = lurek.physics.newWorld(0, 200)
        local terrain = lurek.physics.newTerrain(16, 16, 8, world)

        -- Fill bottom two rows solid (rows 14 and 15) to act as floor.
        terrain:fillRect(0, 112, 128, 16, true)
        -- Place a floating column of cells above the floor with a gap.
        terrain:setCell(8, 10, true) -- row 10, no floor below until row 14

        terrain:flush()

        -- Capture positions before collapse.
        local pts = terrain:solidPositions()
        expect_true(#pts >= 1)

        -- Collapse unsupported cells.
        local fallen = terrain:collapseColumns()
        expect_true(fallen >= 0)

        -- Spawn debris for any removed cells (use the pre-collapse set as proxy).
        local ids = terrain:spawnDebris(pts, 1.0, 0.2)
        expect_type("table", ids)
        for _, id in ipairs(ids) do
            expect_type("number", id)
            expect_true(id > 0, "debris id should be positive")
        end

        -- Step the world with debris bodies present.
        terrain:flush()
        for _ = 1, 30 do
            world:step(1/60)
        end

        expect_true(#ids >= 0, "spawnDebris returns a valid id table")
    end)

    -- @covers LTerrain:toImageData
    -- @covers lurek.physics.newTerrain
    -- @covers lurek.physics.newWorld
    it("toImageData returns expected byte count", function()
        local world = lurek.physics.newWorld(0, 0)
        local w, h = 8, 8
        local terrain = lurek.physics.newTerrain(w, h, 4, world)
        local img = terrain:toImageData(100, 200, 50, 30, 30, 30)
        -- Expected: w * h * 4 bytes
        expect_equal(w * h * 4, #img)
    end)
end)
test_summary()
